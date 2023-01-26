function Import-Chunk-CSV{
    [CmdLetBinding(
        SupportsShouldProcess = $true, 
        PositionalBinding = $false,
        ConfirmImpact = "Low",
        DefaultParameterSetName = "Absolute"
    )]
    param([int]$chunk_number)

    $csv_path = ".\tmp\tmp_paths_$chunk_number.csv"

    $test_import = Import-Csv -Path $csv_path
    $myTestArray  = [System.Collections.ArrayList]::new()
    foreach($testPath in $test_import){
        $myTestArray.Add($testPath.path)
    }
    
    return $myTestArray

}