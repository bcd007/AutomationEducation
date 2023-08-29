get-help about_Functions_Argument_Completion


# Note:  'ArgumentCompletions' is only available in PowerShell 6.0 and above
# For Windows PowerShell, use Register-ArgumentCompleter with a scriptblock

#
#   Time Parameter Validations
#

function Test-FunctionParameterTypes {
    [CmdletBinding()]

    Param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $UserName,

        [Parameter(Mandatory)]
        [ValidateLength(1,10)]
        [string[]]
        $ComputerName,

        [Parameter(Mandatory)]
        [Int32[]]
        $ComputerNumber
    )

    $userName,$ComputerName,$ComputerNumber
}

#
#   ArguementCompletions type (Requires PowerShell Core and up)
#
function Test-ArgumentCompletions {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ArgumentCompletions('Apple', 'Banana', 'Orange')]
        $Fruit,

        [Parameter(Mandatory=$true)]
        [ArgumentCompletions('Tomato', 'Corn', 'Squash')]
        $Vegetable
    )
    Return $Fruit,$Vegetable
}


# Argument completion for Windows PowerShell & PowerShell

#
#   Validate Set Example
#

function Test-ArgumentValidation {
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('Dev', 'QA', 'Prod')]
        [string[]]
        $adEnvironment
    )
    Return $adEnvironment
}

#
#   Time Zone Arguement Completions
#
function Test-ArgCompletionTimezone {
    [CmdletBinding()]
    param(
        [Parameter()]
        $TZone
        )
    Return $TZone
}

$timeZonescriptBlock = {
    param($commandName, $parameterName, $wordToComplete)
    (Get-TimeZone -ListAvailable).Id | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {"'$_'"}
}
Register-ArgumentCompleter -CommandName Test-ArgCompletionTimezone -ParameterName TZone -ScriptBlock $timeZonescriptBlock


$timeZonescriptBlock = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    (Get-TimeZone -ListAvailable).DisplayName | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {"'$_'"}
}

#
#   JSON File Type Completions
#

function Test-ArgCompletionFiles {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        $clientFile        
    )
    Return $clientFile
}

$clientFileScriptBlock = {
    param($commandName, $parameterName, $wordToComplete)
    (Get-ChildItem -Path C:\Users\v0x9585-ad\Documents\ -File -Filter *.json -Recurse).FullName | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {"'$_'"}
}
Register-ArgumentCompleter -CommandName Test-ArgCompletionFiles -ParameterName clientFile -ScriptBlock $clientFileScriptBlock


#
#   Domain Controller Completions
#

function Test-ArgDCs {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        $dcName        
    )
    Return $dcName
}

$getadDomainControllers = {
    param($commandName, $parameterName, $wordToComplete)
    ((get-addomain).ReplicaDirectoryServers) | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {"'$_'"}
}

Register-ArgumentCompleter -CommandName Test-ArgDCs -ParameterName dcName -ScriptBlock $getadDomainControllers

#
#   PowerShell 6+ Using Classes to do arguement completions
#

class jsonFiles : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        $Global:jsonFiles = (Get-ChildItem -Path .\Documents\ -File -Filter *.json -Recurse).FullName
        return ($Global:jsonFiles)
    }
}
Function Get-jsonFiles {
    Param(
        [Parameter(Mandatory)]
        [ValidateSet([jsonFiles],ErrorMessage="Value '{0}' is invalid. Try one of: {1}")]
        $jsonFiles
    )
}

class jsonFilesMac : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        $Global:jsonFiles = (Get-ChildItem -Path /Documents/Argument-Completion/ -File -Filter *.json -Recurse).FullName
        return ($Global:jsonFiles)
    }
}

Function Get-jsonFiles {
    Param(
        [Parameter(Mandatory)]
        [ValidateSet([jsonFilesMac],ErrorMessage="Value '{0}' is invalid. Try one of: {1}")]
        $jsonFiles
    )
}
