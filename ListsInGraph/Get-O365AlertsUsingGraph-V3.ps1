<#
.SYNOPSIS
This script will retrieve the list of current O365 Service Alerts from GraphAPI, and update a SPO List with the alerts flagged as 'serviceDegradation'

.DESCRIPTION
This script will retrieve the list of current O365 Service Alerts with a status of 'serviceDegradation' from GraphAPI, and update a SPO/Teams List with the alert data
This script will also remove any items in the SPO list where the Status of the Alert has changed from 'serviceDegradation' to any other status
Note:   This script uses only GraphAPI, no other modules are required.
        This script requires a json file with the AppID Key and encrypted secret.  The script can be modified to support a certificate or Azure keystore

The SPO list is a standard SharePoint Online list that has the following columns:
title,id,impactDescription,classification,featureGroup,feature,service,status,startDateTime

This script requires an Azure AD ApplicationRegistration that has the following GraphAPI Application Permissions consented:
     ServiceMessage.Read.All
     ServiceHealth.Read.All
     Sites.Manage.All
     or
     Sites.Selected (If you can get this working)

Date Written: 01/12/2022
CR/SR/INC: N/A
Author: Bob Dillon
Version:  3.0

.EXAMPLE
(Get-Content -Raw "C:\Temp\O365IssuesScriptData.json") | ConvertFrom-Json | C:\Temp\Get-O365AlertsUsingGraph-V3.ps1

.EXAMPLE
Get-O365AlertsUsingGraph.ps1 -tenantID 648ce928-1175-4c5e-b65d-eeac50fc6258 -clientFile "C:\Temp\SomeCredFile.json" -siteID a1d0bdc1-1758-49db-a703-e082a4f5b465 -listId 167c6b88-044a-4f6f-b6d1-7785b8e75f65
#>

[CmdletBinding()]
param (
	[parameter(ValueFromPipelineByPropertyName=$true,Mandatory=$true)][GUID]$tenantID,
	[parameter(ValueFromPipelineByPropertyName=$true,Mandatory=$true)][string]$clientFile,
	[parameter(ValueFromPipelineByPropertyName=$true,Mandatory=$true)][GUID]$siteID,
	[parameter(ValueFromPipelineByPropertyName=$true,Mandatory=$true)][GUID]$listID
)

# Create the credential object from the encrypted AppID file ($clientFile)
$applicationReg = (ConvertFrom-Json -InputObject (Get-Content $clientFile -ReadCount 0 | Out-String)) | ForEach-Object{New-Object -TypeName System.Management.Automation.PSCredential ($_.UserName, (ConvertTo-SecureString $_.PasswdEncrStr))}

#Create an object item with data for each Site/List to write alert data to (including filtering)
$dataforeachTeam = @()
# Productivity Management Team
$alertstoCheck = $null
$dataforeachTeam += [PSCustomObject]@{"SiteID"='eb4abad1-46d7-4ac2-bbf3-a207a5a4fe2f';"ListID"='b0b43225-063a-47ab-9a70-8ecc22b39d2e';"Filter"= $alertstoCheck}
# Security Team
$alertstoCheck = $null;$alertstoCheck = "Azure Information Protection","Dynamics 365 Apps","Dynamics 365 Business Central","Identity Service","Microsoft 365 Apps","Microsoft 365 Defender","Microsoft 365 suite","Microsoft Defender for Cloud Apps","Microsoft Intune","Microsoft Power Automate","Microsoft Power Automate in Microsoft 365","Mobile Device Management for Office 365","Office for the web","OneDrive for Business","Power Apps","Power Apps in Microsoft 365","Power BI"
$dataforeachTeam += [PSCustomObject]@{"SiteID"='8cb554da-0d5c-4806-8f2a-f0232bf57c69';"ListID"='104d17a0-6893-48c2-8711-1b939e0fceef';"Filter"= $alertstoCheck}
# RCD Demo Team
$alertstoCheck = $null
$dataforeachTeam += [PSCustomObject]@{"SiteID"='1e9c3e68-77d1-43aa-b7d1-3dd7d95d7ae0';"ListID"='b26282ee-6a08-4082-ba75-a3067639c03f';"Filter"= $alertstoCheck}

# Create the GraphAPI connection and token to use throughout the script
$ReqTokenBody = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    client_Id     = $applicationReg.UserName
    Client_Secret = $applicationReg.GetNetworkCredential().password
} 
$TokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantID/oauth2/v2.0/token" -Method POST -Body $ReqTokenBody
$Header = @{
    Authorization = "$($TokenResponse.token_type) $($TokenResponse.access_token)"
    ConsistencyLevel = "eventual"
}

# Retrieves the list of services with current impacts in O365 and creates an object with just the .value property of the Graph REST call
$serviceHealthresults = @()
$serviceStatusReturnURI = "https://graph.microsoft.com/v1.0/admin/serviceAnnouncement/healthOverviews?`$expand=issues"
$SvcHealthAlerts = Invoke-RestMethod -Headers $Header -Uri $serviceStatusReturnURI -Method Get -ContentType "application/json"
$serviceHealthresults = $SvcHealthAlerts.value | Where-Object{$_.status -eq "serviceDegradation"} | Select-Object -expand issues | Where-Object{$_.status -eq "serviceDegradation"}
$serviceHealthresultsToRemove = $SvcHealthAlerts.value | Select-Object -expand Issues| Where-Object{$_.status -eq "serviceRestored"}

ForEach($team in $dataforeachTeam){

    # Filter just on Security Events if a Filter exists in the site/list object
    $serviceHealthresultstoWrite = $null
    If($null -ne $team.Filter){
        $serviceHealthresultstoWrite = $serviceHealthresults | Where-Object{$_.service -in $team.Filter}
    }
    Else{
        $serviceHealthresultstoWrite = $serviceHealthresults
    }

    # Get the List and List Items via Graph, and set up the Add List Item URI
    $listItemsURI = "https://graph.microsoft.com/v1.0/sites/$($team.SiteID)/lists/$($team.ListID)/items?expand=fields"
    $listItemsToExamine = Invoke-RestMethod -Headers $Header -Uri $listItemsURI -Method Get -ContentType "application/json"
    $currentListItems = $listItemsToExamine.value
    $listItemstoAddURI = "https://graph.microsoft.com/v1.0/sites/$($team.SiteID)/lists/$($team.ListID)/items"

    # Parse through each service alert and determine if the individual alert needs to be added to or removed from the List.
    ForEach($svcAlertToAnalyze in $serviceHealthresultstoWrite){
        If($currentListItems.fields.Id0 -notcontains $svcAlertToAnalyze.Id){
            # Create a nested hashtable to match the JSON format/case needed to add a list item via GraphAPI
            $bodyToWrite = @{fields = $svcAlertToAnalyze | Select-Object -Property @{n="Title"; e={$_.title}},@{n="id0"; e={$_.Id}},impactDescription,classification,feature,featureGroup,service,status,startDateTime}

            # Add any new alerts with an status of 'serviceDegradation' that are not in the list already
            Invoke-RestMethod -Headers $Header -Uri $listItemstoAddURI -Method POST -ContentType "application/json" -Body ($bodyToWrite | ConvertTo-Json)
        }
    }

    # Remove any list items where the status has changed from 'serviceDegradation' to 'serviceRestored'
    ForEach($serviceHealthresultToRemove in $serviceHealthresultsToRemove){
        If($currentListItems.fields.Id0 -contains $serviceHealthresultToRemove.Id){
            $currentlistitems | Where-Object{$_.fields.Id0 -eq $serviceHealthresultToRemove.Id} | ForEach-Object{
                $deleteListItemURI = "https://graph.microsoft.com/v1.0/sites/$($team.SiteID)/lists/$($team.ListID)/items/$($_.id)"
                Invoke-RestMethod -Headers $Header -Uri $deleteListItemURI -Method DELETE -ContentType "application/json"
            }
        }
    }
}
