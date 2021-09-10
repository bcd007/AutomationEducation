# non-pipeline method for searching by name
get-service -Name WebClient
get-service WebClient

# To have the ability to provide parameters to a cmdlet in a script from pipeline, we first must know if that cmddlet has parameters that can take pipeline input
# To do that, use Get-Help to see the available parameter information

get-help get-service -Parameter * | select-object name,required,pipelineInput,position,@{Name="Type";Expression={$_.Type.Name}} | Format-Table -AutoSize

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
"WebClient" | get-service

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
import-csv .\services.csv

import-csv .\services.csv | get-service
import-csv .\services.csv | .\Get-ServiceUsingParameterFile.ps1

# JSON
# Read the JSON File
(Get-Content -Raw ".\services.json")
# Lets convert that from a string to a custom object so PowerShell can more better use it!
(Get-Content -Raw ".\services.json") | ConvertFrom-Json

# Put it all together...
(Get-Content -Raw ".\services.json") | ConvertFrom-Json | get-service
(Get-Content -Raw ".\services.json") | ConvertFrom-Json | .\Get-ServiceUsingParameterFile.ps1
