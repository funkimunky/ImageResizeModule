Function Get-Imagepaths{
    [cmdletbinding()]
    param( 
        [Parameter(Position = 0, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [hashtable]$ExcelPaths 
        ) 

    $exclude_list = $ExcelPaths['exclude']
    $include_list = $ExcelPaths['include']

    $recursive_paths = [System.Collections.ArrayList]::new()

    foreach($path in $include_list){
        $systempath = Get-Item -Path $path
        $recursive_paths.Add($systempath.FullName) | Out-Null # https://stackoverflow.com/questions/10286164/function-return-value-in-powershell

        Get-ChildItem -Path $include_list -Directory -Recurse 
        | ForEach-Object{
            $allowed = $true
            foreach ($exclude in $exclude_list) { 
                if (($_.Parent -ilike $exclude) -Or ($_ -ilike $exclude)) {
                    $allowed = $false
                    break
                }
            }
            if ($allowed) {
                $recursive_paths.Add($_.FullName)
            }
        } | Out-Null # https://stackoverflow.com/questions/7325900/powershell-2-array-size-differs-between-return-value-and-caller

    }
    
    return $recursive_paths
}
