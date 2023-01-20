Function Resize-Image() {    
    [CmdLetBinding(
        SupportsShouldProcess = $true, 
        PositionalBinding = $false,
        ConfirmImpact = "Low",
        DefaultParameterSetName = "Absolute"
    )]
    Param 
    (
        [Parameter(Mandatory = $True)][String[]]$ImagePath,
        [Parameter(Mandatory = $False)][Switch]$MaintainRatio,
        [Parameter(Mandatory = $False, ParameterSetName = "Longerside")][Int]$Longerside,
        # [Parameter(Mandatory = $False, ParameterSetName = "Absolute")][Int]$Height,
        # [Parameter(Mandatory = $False, ParameterSetName = "Absolute")][Int]$Width,        
        # [Parameter(Mandatory = $False, ParameterSetName = "Percent")][Double]$Percentage,       
        [Parameter(Mandatory = $False)][String]$NameModifier = "resized",
        [Parameter(Mandatory = $False)][System.Management.Automation.SwitchParameter]$OverWrite
    )
    
    Begin 
    {
        $Global:OrigionalTotal

        # If ($Width -and $Height -and $MaintainRatio) {
        #     Throw "Absolute Width and Height cannot be given with the MaintainRatio parameter."
        # }
 
        # If (($Width -xor $Height) -and (-not $MaintainRatio)) {
        #     Throw "MaintainRatio must be set with incomplete size parameters (Missing height or width without MaintainRatio)"
        # }
 
        # If ($Percentage -and $MaintainRatio) {
        #     Write-Warning "The MaintainRatio flag while using the Percentage parameter does nothing"
        # }

        # If ($Longerside -and $Width -or $Longerside -and $height) {
        #     Throw "Should only be longer side in pixels"
        # }

        # If ($Percentage -and $Longerside -or $MaintainRatio -and $Longerside) {
        #     Throw "Percentage or maintain ratio cannot be used with longerside pixels flag"
        # }

        
    }
    Process 
    {
        
      
            ForEach ($Image in $ImagePath) {                
                $Path = (Resolve-Path $Image).Path
                $Dot = $Path.LastIndexOf(".")
                
                try 
                {
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

            
                    If ($PSCmdlet.ShouldProcess("Resized image based on $Path", "save to $OutputPath")) {  
                        # If ($MaintainRatio) {                
                        
                        # }

                        # If ($Percentage) {
                        
                        # }

                        If ($Longerside) {
                            Compress-Image -type "jpg" -path $OutputPath -Longerside $Longerside
                        }                   
                            
                    }   
                
                }
                catch 
                {
                    Write-Log -Text $Image
                    Write-Log -Text $_.Exception.Message
                    Throw "$($_.Exception.Message)"
                }
            }
      
        
    }
}