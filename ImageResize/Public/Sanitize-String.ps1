Function Sanitize-String{
    [CmdLetBinding(
        SupportsShouldProcess = $true, 
        PositionalBinding = $false,
        ConfirmImpact = "Low",
        DefaultParameterSetName = "Absolute"
    )]
    Param 
    (
        [Parameter(Mandatory = $True)][String[]]$path
    )  

    $charsToSanitize = @{"'" = "``'"}

    foreach($key in $charsToSanitize){
        $path[0] = $path[0].Replace($key, $charsToSanitize[$key])
    }
    
    return $path
}