[CmdletBinding()]
param (
    [parameter(ValueFromPipelineByPropertyName=$true,Mandatory=$true)][string]$Name,
    [parameter(ValueFromPipelineByPropertyName=$true)][string]$computerName
)

get-service -Name $Name -ComputerName $computerName
