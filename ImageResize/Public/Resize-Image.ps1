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
        [Parameter(Mandatory = $False)][String]$NameModifier = "resized",
        [Parameter(Mandatory = $False)][System.Management.Automation.SwitchParameter]$OverWrite
    )
    
    Begin 
    {
        $Global:OrigionalTotal        
    }
    Process 
    {
        ForEach ($Image in $ImagePath) {                
            $Path = (Resolve-Path $Image).Path
            $Dot = $Path.LastIndexOf(".")
            
            #make sure image can be written to
            Set-IsReadOnly-False -path $Path

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