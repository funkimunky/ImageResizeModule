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
    
    if((Get-ChildItem -Path $path).IsReadOnly){
        Set-ItemProperty -Path $path -Name IsReadOnly -Value $false
    }

}