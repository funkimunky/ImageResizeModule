function Export-Chunk-CSV{
    [CmdLetBinding(
        SupportsShouldProcess = $true, 
        PositionalBinding = $false,
        ConfirmImpact = "Low",
        DefaultParameterSetName = "Absolute"
    )]
    param(
        $pathlist,
        [int]$chunk_number    
    )

    $csv_path = ".\tmp\tmp_paths_$chunk_number.csv"
    
    $newarr = @()  
    foreach($recPath in $pathlist){
        $obj = New-Object PSObject        
        $obj | Add-Member -MemberType NoteProperty -Name "path" -Value $recPath
        $newarr+=$obj
        $obj=$null    
    }

    $newarr | Export-CSV -Path $csv_path  -NoTypeInformation 
   
}