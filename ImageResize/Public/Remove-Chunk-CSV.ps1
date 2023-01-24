function Remove-Chunk-CSV{
    [CmdLetBinding(
        SupportsShouldProcess = $true, 
        PositionalBinding = $false,
        ConfirmImpact = "Low",
        DefaultParameterSetName = "Absolute"
    )]
    param()

    $chunk_path = ".\tmp\"

    Get-ChildItem -Path $chunk_path | 
    Where-Object {($_ -like "*tmp_paths*.csv")}|
    Remove-Item   

}