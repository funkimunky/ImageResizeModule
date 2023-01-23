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
    
    # $path = Sanitize-String -path $path

    $expression = 'magick {0} "{1}"' -f $params, $path

    Try
    {
        # $er = (Invoke-Expression $expression) 2>&1   
        $er = (Invoke-Expression $expression)   
        if ($er.Length -gt 0) {throw $er}
    }
    Catch
    {
        Write-Log -Text $er           
    }

   

    $Global:FinalTotal += Get-Size-Item-mb($path) 
 
}