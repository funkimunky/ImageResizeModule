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
        [Parameter(Mandatory = $False, ParameterSetName = "Longerside")][Int]$Longerside
    )

    $params = switch ($type) {
        "jpg" { 'mogrify -quality 82 -resize {0}x{0}' -f $Longerside }       
    }
   
    Get-Item $path -Include "*.$type" | 
        Where-Object {
            $_.Length/1kb -gt $minSize
        } | 
        Sort-Object -Descending length |
        ForEach-Object {
            $file = "'" + $_.FullName + "'"
            Invoke-Expression "magick $params $file"
            $Global:FinalTotal += Get-Size-Item-mb($path) 
        }
}