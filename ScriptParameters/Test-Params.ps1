param (
    [string]$price = 100, 
    [string]$ComputerName = $env:computername,    
    [string]$username = $(throw "-username is required."),
    [string]$password = $( Read-Host -asSecureString "Input password" ),
    [switch]$SaveData = $false
)
write-output "The price is $price"
write-output "The Computer Name is $ComputerName"
write-output "The True/False switch argument is $SaveData"
write-output "Password is a secret: $password"
