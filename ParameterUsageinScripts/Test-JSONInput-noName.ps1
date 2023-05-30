[CmdletBinding()]
param (
    #[parameter(ValueFromPipelineByPropertyName=$true,Mandatory=$true)][string[]]$ProdDomains
    [parameter(ValueFromPipeline=$true,Mandatory=$true)][string[]]$ProdDomains
)

$ProdDomains

# Works with line 3 enabled, parameters by Property Name coming from an data file of some sorts (json, csv)
# (get-content .\ArrayOfStrings.json -Raw) | convertfrom-json | .\Test-JSONInput-noName.ps1

# Line 4 enabled so the script can accept an array of strings from pipeline
# "ad1.contoso.com","ad2.contoso.com","ad3.contoso.com","ad4.contoso.com","ad5.contoso.com" | .\Test-JSONInput-noName.ps1
# Hmmm, on only shows the last item from the array of strings...

# .\Test-JSONInput-noName.ps1 -ProdDomains "ad1.contoso.com","ad2.contoso.com","ad3.contoso.com","ad4.contoso.com","ad5.contoso.com"
# This one works with line 4 enabled

# So, how to get the script to accept an array of strings in the pipeline with no property name
# Add Begin/Process/End codeblocks to allow the script to use each parameter from the pipeline
# Process {Write-Host "ProdDomains:  $ProdDomains"}

# Within a pipeline, the Process block executes once for each input object that reaches the function.
# The END scriptblock processes the last item in an array of strings, which is the default behavior of a script without the END
# Just having an END statement will process the last item in the array of strings from the pipeline

# Get-Help -Full about_Functions_Advanced_Methods
