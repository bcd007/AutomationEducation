# non-pipeline method for searching by name
# "Named" parameter
Get-Service -Name WebClient
# "Positional" parameter
Get-Service WebClient

# To have the ability to provide parameters to a cmdlet in a script from pipeline, we first must know if that cmdlet has parameters that can take pipeline input
# To do that, use Get-Help to see the available parameter information

Get-Help Get-Service -Parameter * | Select-Object name,required,pipelineInput,position,@{Name="Type";Expression={$_.Type.Name}} | Format-Table -AutoSize

# name              required pipelineInput                  position Type
# ----              -------- -------------                  -------- ----
# ComputerName      false    True (ByPropertyName)          named    System.String[]
# DependentServices false    False                          named    System.Management.Automation.SwitchParameter
# DisplayName       true     False                          named    System.String[]
# Exclude           false    False                          named    System.String[]
# Include           false    False                          named    System.String[]
# InputObject       false    True (ByValue)                 named    System.ServiceProcess.ServiceController[]
# Name              false    True (ByPropertyName, ByValue) 0        System.String[]
# RequiredServices  false    False                          named    System.Management.Automation.SwitchParameter

# Use PipeLine input for Name parameter
"WebClient" | Get-Service

[CmdletBinding()]
param (
    [parameter(ValueFromPipelineByPropertyName=$true,Mandatory=$true)][string]$Name,
    [parameter(ValueFromPipelineByPropertyName=$true)][string]$computerName
)

# [CmdletBinding()] allows functions in script to more act like true cmdlets.  Or, from Microsoft:
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_cmdletbindingattribute?view=powershell-7.1
# The CmdletBinding attribute is an attribute of functions that makes them operate like compiled cmdlets written in C#. It provides access to the features of cmdlets.

# CSV?
# Name,Computername
# "WebClient","."

# JSON?
{
    "Name" : "WebClient",
    "ComputerName" : "."
}

# Using those documents to provide parameter data to a script
# CSV
Import-Csv .\services.csv

Import-Csv .\services.csv | Get-Service
Import-Csv .\services.csv | .\Get-ServiceUsingParameterFile.ps1

# JSON
# Read the JSON File
(Get-Content -Raw .\services.json)
# Lets convert that from a string to a custom object so PowerShell can more better use it!
(Get-Content -Raw .\services.json) | ConvertFrom-Json

# Put it all together...
(Get-Content -Raw .\services.json) | ConvertFrom-Json | Get-Service
(Get-Content -Raw .\services.json) | ConvertFrom-Json | .\Get-ServiceUsingParameterFile.ps1

## Can see the ParameterBinding/ folder and its Jupyter notebook for even more info about parameter binding, types, parameter sets, etc.