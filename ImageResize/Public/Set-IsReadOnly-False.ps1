Function Set-IsReadOnly-False{
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
    
    if(Get-ChildItem -LiteralPath $path -File){
        if((Get-ChildItem -LiteralPath $path).IsReadOnly){
            Set-ItemProperty -LiteralPath $path -Name IsReadOnly -Value $false
        }       
    }
}