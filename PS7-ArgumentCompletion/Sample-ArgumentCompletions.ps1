# Note:  'ArgumentCompletions' is only available in PowerShell 6.0 and above
# For Windows PowerShell, use Register-ArgumentCompleter with a scriptblock

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



<<<<<<< HEAD
function Test-ArgumentCompletions {
    [CmdletBinding()]
    param(
        [Parameter()]
=======
function Test-FruitsAndVegValidation{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
>>>>>>> f96b0918dadfa7ea6140ecc633162d8ec27bf658
        [ArgumentCompletions('Apple', 'Banana', 'Orange')]
        $Fruit,

        [Parameter(Mandatory=$true)]
        [ArgumentCompletions('Tomato', 'Corn', 'Squash')]
        $Vegetable
    )
    Return $Fruit,$Vegetable
}


<<<<<<< HEAD

function Test-ArgumentValidation {
=======
function Test-FruitValidation {
>>>>>>> f96b0918dadfa7ea6140ecc633162d8ec27bf658
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('Apple', 'Banana', 'Pear')]
        [string[]]
        $Fruit
    )
    Return $Fruit
}



# Argument completion for Windows PowerShell & PowerShell
function Test-ArgCompletionTimezone {
    [CmdletBinding()]
    param(
        [Parameter()]
        $TZone
        )
    Return $TZone
}


$timeZonescriptBlock = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    (Get-TimeZone -ListAvailable).DisplayName | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {"'$_'"}
}
Register-ArgumentCompleter -CommandName Test-ArgCompletionTimezone -ParameterName TZone -ScriptBlock $timeZonescriptBlock



function Test-ArgCompletionFiles {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        $clientFile        
    )
    Return $clientFile
}


$clientFileScriptBlock = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    (Get-ChildItem -Path /Users/V0X9585/Documents/Argument-Completion/*.json -File).FullName | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {"'$_'"}
}
Register-ArgumentCompleter -CommandName Test-ArgCompletionFiles -ParameterName clientFile -ScriptBlock $clientFileScriptBlock


get-help about_Functions_Argument_Completion


$tenantIDScriptBlock = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    "d9d47063-3f5e-4de9-bf99-f083657fa0fe","17e717f1-f026-462d-b77e-4468a7f8126b"| Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {"'$_'"}
}
Register-ArgumentCompleter -CommandName Initialize-GraphToken -ParameterName tenantID -ScriptBlock $tenantIDScriptBlock 
