# Note:  'ArgumentCompletions' is only available in PowerShell 6.0 and above
# For Windows PowerShell, use Register-ArgumentCompleter with a scriptblock

function Test-ArgumentCompletions {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        $clientFile,

        [Parameter()]
        $TZone,
        
        [Parameter()]
        $ServiceName,

        [Parameter]
        [ArgumentCompletions('Fruits', 'Vegetables')]
        $Type,

        [Parameter()]
        [ArgumentCompletions('Apple', 'Banana', 'Orange')]
        $Fruit,

        [Parameter()]
        [ArgumentCompletions('Tomato', 'Corn', 'Squash')]
        $Vegetable
    )
    Return $clientFile,$TZone,$ServiceName,$Type,$Fruit,$Vegetable
}

$clientFileScriptBlock = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    (Get-ChildItem -Path *.json -Recurse).FullName | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {"'$_'"}
}
Register-ArgumentCompleter -CommandName Test-ArgumentCompletions -ParameterName clientFile -ScriptBlock $clientFileScriptBlock

$timeZonescriptBlock = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    (Get-TimeZone -ListAvailable).Id | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {"'$_'"}
}

Register-ArgumentCompleter -CommandName Test-ArgumentCompletions -ParameterName TZone -ScriptBlock $timeZonescriptBlock


$serviceNameScriptBlock = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $services = Get-Service | Where-Object {$_.Status -eq "Running" -and $_.Name -like "$wordToComplete*"}
    $services | ForEach-Object {
        New-Object -Type System.Management.Automation.CompletionResult -ArgumentList $_.Name,$_.Name,"ParameterValue",$_.Name}
}

Register-ArgumentCompleter -CommandName Test-ArgumentCompletions -ParameterName ServiceName -ScriptBlock $serviceNameScriptBlock


function Test-ArgumentCompletionsSmall {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ArgumentCompletions('Fruits', 'Vegetables')]
        $Type,

        [Parameter()]
        [ArgumentCompletions('Apple', 'Banana', 'Orange')]
        $Fruit,

        [Parameter()]
        [ArgumentCompletions('Tomato', 'Corn', 'Squash')]
        $Vegetable
    )
    Return $Type,$Fruit,$Vegetable
}

function Test-ArgumentValidation {
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('Apple', 'Banana', 'Pear')]
        [string[]]
        $Fruit
    )
    Return $Fruit
}


# Argument completion for Windows PowerShell & PowerShell
function Test-ArgCompletionWindowPShell {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        $clientFile,

        [Parameter()]
        $TZone
        
    )
    Return $clientFile,$TZone
}

$clientFileScriptBlock = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    (Get-ChildItem -Path *.json -Recurse).FullName | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {"'$_'"}
}
Register-ArgumentCompleter -CommandName Test-ArgCompletionWindowPShell -ParameterName clientFile -ScriptBlock $clientFileScriptBlock


$timeZonescriptBlock = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    (Get-TimeZone -ListAvailable).Id | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {"'$_'"}
}
Register-ArgumentCompleter -CommandName Test-ArgCompletionWindowPShell -ParameterName TZone -ScriptBlock $timeZonescriptBlock

$tenantIDScriptBlock = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    "d9d47063-3f5e-4de9-bf99-f083657fa0fe","17e717f1-f026-462d-b77e-4468a7f8126b"| Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {"'$_'"}
}
Register-ArgumentCompleter -CommandName Initialize-GraphToken -ParameterName tenantID -ScriptBlock $tenantIDScriptBlock 
