# using module ../Private/MyEXCP1.psm1
# using module ../Private/MyEXCP2.psm1
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



    class MyEXCP1: System.Exception{
        $Emessage
        MyEXCP1([string]$msg){
            $this.Emessage=$msg
        }
    }
    class MyEXCP2: System.Exception{
        $Emessage
        MyEXCP2([string]$msg){
            $this.Emessage=$msg
        }
    }

    class MyErrorRecord: System.Exception{
        $Emessage
        MyErrorRecord($msg){
            $this.Emessage=$msg
        }
    }
   
    Try
    {
        $er = (Invoke-Expression $expression) 2>&1   
 
        if($er -is [System.Management.Automation.ErrorRecord]){
            throw [MyErrorRecord]$er
        }
        if ($er.Length -gt 0) {
            throw [MyEXCP1]$er
        }
        if ($lastexitcode){
            throw [MyEXCP2]$er
        }
    }
    catch [MyEXCP1]
    {
        Write-Log -Text $_.Exception.Emessage        
    }
    catch [MyEXCP2]
    {
        Write-Log -Text $_.Exception.Emessage
    }
    catch [MyErrorRecord]
    {
        if($er.CategoryInfo.TargetName.Contains("SOS parameters for sequential"))
        {
            $errorString = '{0} - {1}' -f "Sequential warning", $_.Exception.Emessage
            Write-Log -Text $errorString
        }
        else
        {
            $errorString = '{0} - {1}' -f "File is read only",$_.Exception.Emessage
            Write-Log -Text $errorString
        }
        
    }
    catch {
        Write-Log -Text $path
        # Write-Log -Text $_.Exception.Message
        Write-Log -Text $_.ToString()
    }

   

    $Global:FinalTotal += Get-Size-Item-mb($path) 
 
}