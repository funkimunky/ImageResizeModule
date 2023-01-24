function Count-Chunk-CSV{
    [CmdLetBinding(
        SupportsShouldProcess = $true, 
        PositionalBinding = $false,
        ConfirmImpact = "Low",
        DefaultParameterSetName = "Absolute"
    )]
    param()

    $chunk_path = ".\tmp\"
    $count = (Get-ChildItem -Path $chunk_path | 
    Where-Object {($_ -like "*tmp_paths*.csv")}| 
    Measure-Object).Count

    return $count


   

}