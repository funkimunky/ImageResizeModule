function Compress-Image() {
    [CmdLetBinding(
        SupportsShouldProcess = $true, 
        PositionalBinding = $false,
        ConfirmImpact = "Low",
        DefaultParameterSetName = "Absolute"
    )]
    param(
        [Parameter(Mandatory = $True)][System.String]$type,
        [Parameter(Mandatory = $True)][string]$path,
        [Parameter(Mandatory = $False)][Switch]$report
    )

    $params = switch ($type) {
        "jpg" { "-compress jpeg -quality 82" }
        "gif" { "-fuzz 10% -layers Optimize" }
        "png" { "-depth 24 -define png:compression-filter=2 -define png:compression-level=9 -define png:compression-strategy=1" }
    }

    if ($report) {
        # Write-Output ""
        # Write-Output "Listing $type files that would be included for compression with params: $params"
    } else {
        # Write-Output ""
        # Write-Output "Compressing $type files with parameters: $params"
    }
    
    Get-Item $path -Include "*.$type" | 
        Where-Object {
            $_.Length/1kb -gt $minSize
        } | 
        Sort-Object -Descending length |
        ForEach-Object {
            $file = "'" + $_.FullName + "'"
        
            if ($report) {
                # $fSize = Get-Size-Kb($file)
                # Write-Output "$file - $fSize"
            } else {
                if ($verbose) {
                    # Write-Output "Compressing $file"
                    # $fileStartSize = Get-Size-Kb($file)
                }
        
                # compress image
                if ($report -eq $False) {
                    Invoke-Expression "magick $file $params $file"
                }

                if ($verbose) {
                    # $fileEndSize = Get-Size-Kb($file)
                    # Write-Output "Reduced from $fileStartSize to $fileEndSize"
                }

                $Global:FinalTotal += Get-Size-Item-mb($path)                
            }
        }
}