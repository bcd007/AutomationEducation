<# .Description
    Test the binding of parameter values from pipeline
#>

[CmdletBinding()]
param(
    ## Name(s) of the whatsie to get
    [parameter(ValueFromPipeline=$true)][String[]]$Name,

    ## Number of times to do the thing
    [parameter(ValueFromPipeline=$true)][Int]$Count,

    ## Datetime back to which to look for things
    [parameter(ValueFromPipeline=$true)][Datetime]$Start
)

process {
    ## Just returning the params hashtable
    $PSBoundParameters
}