﻿Function Resize-Image() {    
    [CmdLetBinding(
        SupportsShouldProcess = $true, 
        PositionalBinding = $false,
        ConfirmImpact = "Low",
        DefaultParameterSetName = "Absolute"
    )]
    Param 
    (
        [Parameter(Mandatory = $True)]
        [ValidateScript({$_ | ForEach-Object { Test-Path $_ } })][String[]]$ImagePath,
        [Parameter(Mandatory = $False)][Switch]$MaintainRatio,
        [Parameter(Mandatory = $False, ParameterSetName = "Longerside")][Int]$Longerside,
        [Parameter(Mandatory = $False, ParameterSetName = "Absolute")][Int]$Height,
        [Parameter(Mandatory = $False, ParameterSetName = "Absolute")][Int]$Width,        
        [Parameter(Mandatory = $False, ParameterSetName = "Percent")][Double]$Percentage,
        [Parameter(Mandatory = $False)][System.Drawing.Drawing2D.SmoothingMode]$SmoothingMode = "HighQuality",
        [Parameter(Mandatory = $False)][System.Drawing.Drawing2D.InterpolationMode]$InterpolationMode = "HighQualityBicubic",
        [Parameter(Mandatory = $False)][System.Drawing.Drawing2D.PixelOffsetMode]$PixelOffsetMode = "HighQuality",
        [Parameter(Mandatory = $False)][String]$NameModifier = "resized",
        [Parameter(Mandatory = $False)][System.Management.Automation.SwitchParameter]$OverWrite
    )
    
    Begin 
    {
        $Global:OrigionalTotal

        If ($Width -and $Height -and $MaintainRatio) {
            Throw "Absolute Width and Height cannot be given with the MaintainRatio parameter."
        }
 
        If (($Width -xor $Height) -and (-not $MaintainRatio)) {
            Throw "MaintainRatio must be set with incomplete size parameters (Missing height or width without MaintainRatio)"
        }
 
        If ($Percentage -and $MaintainRatio) {
            Write-Warning "The MaintainRatio flag while using the Percentage parameter does nothing"
        }

        If ($Longerside -and $Width -or $Longerside -and $height) {
            Throw "Should only be longer side in pixels"
        }

        If ($Percentage -and $Longerside -or $MaintainRatio -and $Longerside) {
            Throw "Percentage or maintain ratio cannot be used with longerside pixels flag"
        }

        
    }
    Process 
    {
        
        try 
        {
            ForEach ($Image in $ImagePath) {                
                $Path = (Resolve-Path $Image).Path
                $Dot = $Path.LastIndexOf(".")
                
    
                switch ($OverWrite.IsPresent) {
                    $true {
                            # Overite images
                            $OutputPath = $Path.Substring(0, $Dot) + $Path.Substring($Dot, $Path.Length - $Dot)
                        }
                    $false {
                            # rename images
                            $OutputPath = $Path.Substring(0, $Dot) + "_" + $NameModifier + $Path.Substring($Dot, $Path.Length - $Dot)
                        }
                                      
                }

                $Global:OrigionalTotal += Get-Size-Item-mb($Image)

                $OldImage = New-Object -TypeName System.Drawing.Bitmap -ArgumentList $Path
                # Grab these for use in calculations below. 
                $OldHeight = $OldImage.Height
                $OldWidth = $OldImage.Width

                If ($MaintainRatio) {                
                    If ($Height) {
                        $Width = $OldWidth / $OldHeight * $Height
                    }
                    If ($Width) {
                        $Height = $OldHeight / $OldWidth * $Width
                    }
                }

                If ($Percentage) {
                    $Product = ($Percentage / 100)
                    $Height = $OldHeight * $Product
                    $Width = $OldWidth * $Product
                }

                If ($Longerside) {
                    If ($OldWidth -gt $OldHeight) {
                        $ratio = $OldHeight / $OldWidth
                        $width = $Longerside
                        $height = $ratio * $Longerside

                    }
                    If ($OldWidth -lt $OldHeight) {
                        $ratio = $OldWidth / $OldHeight
                        $height = $Longerside
                        $width = $ratio * $Longerside
                    }
                    If ($OldWidth -eq $OldHeight) {
                        $Width = $Longerside
                        $Height = $Longerside
                    }
                }



                $Bitmap = New-Object -TypeName System.Drawing.Bitmap -ArgumentList $Width, $Height
                $NewImage = [System.Drawing.Graphics]::FromImage($Bitmap)
        
                #Retrieving the best quality possible
                $NewImage.SmoothingMode = $SmoothingMode
                $NewImage.InterpolationMode = $InterpolationMode
                $NewImage.PixelOffsetMode = $PixelOffsetMode
                $NewImage.DrawImage($OldImage, $(New-Object -TypeName System.Drawing.Rectangle -ArgumentList 0, 0, $Width, $Height))
               
                #
                # probably need to use
                # Exception calling "Save" with "1" argument(s): "A generic error occurred in GDI+."
                # https://stackoverflow.com/questions/15862810/a-generic-error-occurred-in-gdi-in-bitmap-save-method
                # This error message is displayed if the path you pass to Bitmap.Save() is invalid (folder doesn't exist etc).
                #
                $OldImage.Dispose()                

                If ($PSCmdlet.ShouldProcess("Resized image based on $Path", "save to $OutputPath")) {
                    $Bitmap.Save($OutputPath)                   
                    Compress-Image -type "jpg" -path $OutputPath        
                }
    
                $Bitmap.Dispose()
                $NewImage.Dispose()            
        }
                    }
        catch 
        {
            Throw "$($_.Exception.Message)"
        }
        
    }
}