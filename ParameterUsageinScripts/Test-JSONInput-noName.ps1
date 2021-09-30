[CmdletBinding()]
param (
    #[parameter(ValueFromPipelineByPropertyName=$true,Mandatory=$true)][string[]]$ProdDomains
    [parameter(ValueFromPipeline=$true,Mandatory=$true)][string[]]$ProdDomains
)

Write-Host "ProdDomains:  $ProdDomains"

# Works with line 3 enabled, parameters by Property Name coming from an data file of some sorts (json, csv)
# (get-content .\ArrayOfStrings.json -Raw) | convertfrom-json | .\Test-JSONInput-noName.ps1

# Line 4 enabled so the script can accept an array of strings from pipeline
# "ad1.contoso.com","ad2.contoso.com","ad3.contoso.com","ad4.am.contoso.com","ad5.am.contoso.com" | .\Test-JSONInput-noName.ps1
# Hmmm, on only shows the last item from the array of strings...

# .\Test-JSONInput-noName.ps1 -ProdDomains "ad1.contoso.com","ad2.contoso.com","ad3.contoso.com","ad4.am.contoso.com","ad5.am.contoso.com"

# Add Begin/Process/End codeblocks to allow the script to use each parameter from the pipeline
# This one works with line 4 enabled

# So, how to get the script to accept an array of strings in the pipeline with no property name

# Process {Write-Host "ProdDomains:  $ProdDomains"}
