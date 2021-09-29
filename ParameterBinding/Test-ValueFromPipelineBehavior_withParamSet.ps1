<# .Description
    Test the binding of parameter values from pipeline, with results that are more expected, thanks to the ParameterSets
#>

[CmdletBinding(DefaultParameterSetName="ByName")]
param(
    ## Name(s) of the whatsie to get
    [parameter(ValueFromPipeline=$true, ParameterSetName = "ByName")][String[]]$Name,

    ## Number of times to do the thing
    [parameter(ValueFromPipeline=$true, ParameterSetName = "ByCount")][Int]$Count,

    ## Datetime back to which to look for things
    [parameter(ValueFromPipeline=$true, ParameterSetName = "ByStart")][Datetime]$Start
)

process {
    ## Just returning the params hashtable
    $PSBoundParameters
}