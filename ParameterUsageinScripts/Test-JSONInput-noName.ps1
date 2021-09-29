[CmdletBinding()]
param (
    #[parameter(ValueFromPipelineByPropertyName=$true,Mandatory=$true)][string[]]$ProdDomains
    [parameter(ValueFromPipeline=$true,Mandatory=$true)][string[]]$ProdDomains
)

Write-Host "ProdDomains:  $ProdDomains"

# (get-content .\ArrayOfStrings.json -Raw) | convertfrom-json | .\Test-JSONInput-array-NW.ps1

# "ad1.contoso.com","ad2.contoso.com","ad3.contoso.com","ad4.am.contoso.com","ad5.am.contoso.com" | .\Test-JSONInput-array-NW.ps1

# .\Test-JSONInput-array-NW.ps1 -ProdDomains "ad1.contoso.com","ad2.contoso.com","ad3.contoso.com","ad4.am.contoso.com","ad5.am.contoso.com"
