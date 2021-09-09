# To have the ability to provide parameters to a cmdlet in a script from pipeline, we first must know if that cmddlet has parameters that can take pipeline input

get-help get-service -Parameter * | select-object name,required,pipelineInput,position

# non-pipeline method for searching by name
get-service -Name WebClient

# Use PipeLine input for Name parameter
"WebClient" | get-service

# Why did the cmdlet apply "WebClient" as "Name" instead of <some other parameter>?  It's the Position indicator for the parameter, Name is Position 0:

# When parameters are positional, the parameter name is optional. PowerShell associates unnamed parameter values with the function parameters according to the order or position of the unnamed parameter values in the function command.
# When parameters are not positional (they are "named"), the parameter name (or an abbreviation or alias of the name) is required in the command.

# name              required pipelineInput                  position
# ----              -------- -------------                  --------
# ComputerName      false    True (ByPropertyName)          named
# DependentServices false    False                          named
# DisplayName       true     False                          named
# Exclude           false    False                          named
# Include           false    False                          named
# InputObject       false    True (ByValue)                 named
# Name              false    True (ByPropertyName, ByValue) 0

# Can we take that pipeline object and place it in a file of <some> type, and use that the provide a script with parameters?
# First, take a look at what allows us to provide pipeline parameters to a script:

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

import-csv .\services.csv | .\Get-ServiceUsingParameterFile.ps1

# JSON
# Read the JSON File
(Get-Content -Raw ".\services.json")
# Lets convert that from a string to a custom object so PowerShell can more better use it!
(Get-Content -Raw ".\services.json") | ConvertFrom-Json
# Put it all together...
(Get-Content -Raw ".\services.json") | ConvertFrom-Json | .\Get-ServiceUsingParameterFile.ps1
