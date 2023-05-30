param (
    [Parameter(ValueFromPipelineByPropertyName)]
    [string]$price = 100, 
    [Parameter(ValueFromPipelineByPropertyName)]
    [string]$ComputerName = $env:computername,    
    [Parameter(ValueFromPipelineByPropertyName)]
    [string]$username = $(throw "-username is required."),
    [Parameter(ValueFromPipelineByPropertyName)]
    [string]$pass1 = $( Read-Host -asSecureString "Input password" ),
    [Parameter(ValueFromPipelineByPropertyName)]
    [switch]$SaveData = $false
)
write-output "The price is $price"
write-output "The Computer Name is $ComputerName"
write-output "The True/False switch argument is $SaveData"
write-output "Password is a secret: $pass1"
