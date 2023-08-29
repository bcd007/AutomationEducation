
<#
.SYNOPSIS
This script will find all Guest accounts in a given tenant and delete those accounts that show no activity in a given date range.

.DESCRIPTION
This script will find all Guest accounts in a given tenant and delete those accounts that show no activity in a given date range
Ensure the account object was created more than the given past date days ago

Each Guest account that is removed will have their account information written to a Teams list in case the accounts needs to be recovered from the Azure AD Recycle Bin

This script is written specifically to run in Azure Automation.  The credential and tenant data, and SharePoint Online site info will come from the Azure Automation Runbook variables/credentials.

This script uses an Application-Registration with a Key/Secret that has the following GraphAPI Application Permissions consented:

    user.FullControl
    group.ReadAll
    Active elevation of the PIM Role User Administration
    Granted R/W access to the SharePoint Online Site where the deleted user Info will be written

Date Written: 05/21/2022
CR/SR/INC: N/A
Author: Bob Dillon
Version:  1.0
#>

# Load the Azure Automation module that has the credential cmdlets
Import-Module Orchestrator.AssetManagement.Cmdlets

# Create the credential object from the Azure Credentials (must populate and assing in Azure Automation)
$applicationReg = Get-AutomationPSCredential -Name "GuestAccount-LCM"

# TenantID should come from Azure Automation variable
$tenantID = Get-AutomationVariable -Name "tenantID"

# SharePoint Online Site and List ID
$SiteID = Get-AutomationVariable -Name "sharePointOnlineSiteID"
$listID = Get-AutomationVariable -Name "sharePointOnlineListID"

# Create security body object for accessing Group Memberships for Guest Accounts
$body = @{
	"securityEnabledOnly" = $false
}

# Get past date for aged out Guest accounts, set the Teams List URI to write log data to
$dateToCheck = (get-date).AddDays(-180)
$listItemstoAddURI = "https://graph.microsoft.com/v1.0/sites/$SiteID/lists/$ListID/items"

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

$listItems = "https://graph.microsoft.com/v1.0/sites/$SiteID/lists/$ListID/items?expand=fields"
$listItemstoCheck = (Invoke-RestMethod -Headers $Header -Uri $listItems -Method GET -ContentType "application/json").value

$GuestToCheck = @()
$guestAcctsFromGraph = Invoke-RestMethod -Headers $Header -Uri "https://graph.microsoft.com/beta/users?`$filter=userType eq 'Guest'&`$select=id,displayName,userPrincipalName,createdDateTime,externalUserState,userType,signInActivity" -Method Get -ContentType "application/json"
$GuestToCheck = $guestAcctsFromGraph.value | select-object -property id,displayName,userPrincipalName,createdDateTime,externalUserState,userType,@{n="lastSignInDateTime";e={$_.signInActivity.lastSignInDateTime}},@{n="lastNonInteractiveSignInDateTime";e={$_.signInActivity.lastNonInteractiveSignInDateTime}},@{n="TrueLoginDate";e={$_.signInActivity.lastSignInDateTime,$_.signInActivity.lastNonInteractiveSignInDateTime | Sort-Object | Select-Object -last 1 }}

while($null -ne $guestAcctsFromGraph.'@odata.nextLink') {
     $guestAcctsFromGraph = Invoke-RestMethod -Headers $Header -Uri $guestAcctsFromGraph.'@odata.nextLink' -Method Get -ContentType "application/json"
     $GuestToCheck += ($guestAcctsFromGraph).Value| select-object -property id,displayName,userPrincipalName,createdDateTime,externalUserState,userType,@{n="lastSignInDateTime";e={$_.signInActivity.lastSignInDateTime}},@{n="lastNonInteractiveSignInDateTime";e={$_.signInActivity.lastNonInteractiveSignInDateTime}},@{n="TrueLoginDate";e={$_.signInActivity.lastSignInDateTime,$_.signInActivity.lastNonInteractiveSignInDateTime | Sort-Object | Select-Object -last 1 }}
}

# Find and deleted Guest accounts that show no activity in the given past date range of $dateToCheck
$GuestToCheck | Where-Object{$_.TrueLoginDate -le $dateToCheck -AND $_.createdDateTime -le $dateToCheck} |ForEach-Object{
    Set-Variable groupMembers,deletestatusCode -Value $null
    If($listItemstoCheck.fields.Title -notcontains $_.id){
		$accountToDeleteURI = "https://graph.microsoft.com/v1.0/users/$($_.id)"
        $groupMembers = (Invoke-RestMethod -Headers $Header -Uri "https://graph.microsoft.com/beta/users/$($_.id)/getMemberGroups" -Method Post -ContentType "application/json" -Body ($body | ConvertTo-Json) | select-object -expand Value | ForEach-Object{Invoke-RestMethod -Headers $Header -Uri "https://graph.microsoft.com/v1.0/groups/$($_)" -Method Get -ContentType "application/json"} | Select-Object -expand DisplayName) -join ","
        $bodyToWrite = @{fields = $_ | Select-Object -Property @{n="Title"; e={$_.id}},displayName,userPrincipalName,createdDateTime,externalUserState,userType,@{n="TrueLoginDate"; e={($_.TrueLoginDate).DateTime}},@{n="groupMembership"; e={$groupMembers}},@{n="EmailAddress";e={($_.userPrincipalName).Split("#")[0].Replace("_","@")}}}
        $killtheWabbit = Invoke-RestMethod -Headers $Header -Uri $accountToDeleteURI -Method Delete -ContentType application/json -StatusCodeVariable deletestatusCode
        # Only write the account information to the Teams list if the account was successfully deleted
		If($deletestatusCode -eq 204){
			Invoke-RestMethod -Headers $Header -Uri $listItemstoAddURI -Method POST -ContentType "application/json" -Body ($bodyToWrite | ConvertTo-Json)
		}
    }
}
