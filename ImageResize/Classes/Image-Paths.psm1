Using module ..\..\files\ImportExcel
using module .\MyErrorRecord.psm1
using module .\MyEXCP1.psm1
using module .\MyEXCP2.psm1


class Paths {
    [hashtable]$pathHash = @{}
    [System.Collections.ArrayList]$exclude_list
    [System.Collections.ArrayList]$include_list
    [System.Collections.ArrayList]$image_paths = [System.Collections.ArrayList]::new()
    [int]$Longerside = 2500
    [Int]$BatchAmount = 200
    $FinalTotal = 0
    $OrigionalTotal = 0
    $imagesProcessed = 0

    Paths($BatchAmount){
        Write-Log "Started processing $(Get-Date -Format u)"
        
        $this.BatchAmount = $BatchAmount
        $this.PathFromExcel()
        $this.imagelist()
        
        $outputString = "Origional storage used {0} MB : Storage used after compression {1} MB) : Images Processed {2}" -f $this.OrigionalTotal, $this.FinalTotal, $this.imagesProcessed
        Write-Log $outputString
        Write-Log "end processing $(Get-Date -Format u)"  
    }


    [void]PathFromExcel(){
    
        # Set-Location -Path $IncludeExcludePath
        # Get-Help Import-Excel
        # $excel_obj = Import-Excel -Path .\financial.xlsx | Where-Object 'Month Number' -eq 12
        $excelPath = "$Global:RootPath\files\path_list.xlsx"
        $paths_include = Import-Excel -Path $excelPath -WorkSheetname 'include'
        $paths_exclude = Import-Excel -Path $excelPath -WorkSheetname 'exclude'        
        
        $include_array = [System.Collections.ArrayList]::new()
        $exclude_array = [System.Collections.ArrayList]::new()
        
        foreach ($row in $paths_include)
        {
            if($row.type -eq 'path'){
                [void]$include_array.Add($row.value)
            }   
        }
        
        foreach ($row in $paths_exclude)
        {
            if($row.type -eq 'path'){
                [void]$exclude_array.Add($row.value)
            }   
        }
        
        $this.include_list = $include_array
        $this.exclude_list = $exclude_array
       
    }

    [bool] check_path($path){
        
        if($this.exclude_list.count -eq 0){
            return $true
        }

        foreach($e in $this.exclude_list){
            if($path -match [System.Text.RegularExpressions.Regex]::Escape($e)){
                return $false
            }
        }

        return $true
    }
    
    #get-imagelist
    [Void]imagelist()
    {    
        $c = 0
        $break = $false
       
        get-childitem -path $this.include_list -recurse | Where-Object { 
            ($break -eq $false) -and 
            (".jpg" -eq $_.Extension) -and 
            ($_.Length -ne 0) -and
            $this.check_path($_.FullName)            
        } | ForEach-Object{
                # Parameters for FileStream: Open/Read/SequentialScan
            $FileStreamArgs = @(
                $_
                [System.IO.FileMode]::Open
                [System.IO.FileAccess]::Read
                [System.IO.FileShare]::Read
                1024,     # Buffer size
                [System.IO.FileOptions]::SequentialScan
            )


            Try {
                $FileStream = New-Object System.IO.FileStream -ArgumentList $FileStreamArgs
                $Img = [System.Drawing.Imaging.Metafile]::FromStream($FileStream)
                
                if(($Img) -and (($Img.PhysicalDimension.Width -gt $this.Longerside) -or ($Img.PhysicalDimension.Height -gt $this.Longerside))){
                    $this.image_paths.Add($_.FullName)  
                    $c++          
                }
                If ($Img) {$Img.Dispose()}
                If ($FileStream) {$FileStream.Close()}
            }
            Catch{
                $warningString = "{0} - {1}" -f $_.Exception.ErrorRecord.Exception.Message, $FileStream.Name
                Write-Warning -Message $warningString
                If ($Img) {$Img.Dispose()}
                If ($FileStream) {$FileStream.Close()}
            }

            # used to limit batch processing size it will still process but not reach time expensive part
            # https://www.delftstack.com/howto/powershell/exit-from-foreach-object-in-powershell/
            if($c -ge $this.BatchAmount){
                [string]$outputStr = 'batch limit of {0} reached' -f $this.BatchAmount 
                Write-Log -Text $outputStr     
                $break = $true
            }
        }

        if($this.image_paths.Count -gt 0){
            $this.ResizeImage() #calling this even if nothing is in the image_paths
        }      
    }

    #Resize-Image
    [void]ResizeImage(){ 
        $this.OrigionalTotal        
        ForEach ($Image in $this.image_paths){ 

            #make sure image can be written to
            Set-IsReadOnly-False -path $Image

            try 
            {
                $this.OrigionalTotal += Get-Size-Item-mb($Image)
                $this.CompressImage($Image) 
                $this.FinalTotal += Get-Size-Item-mb($Image)            
            }
            catch 
            {
                Write-Log -Text $Image
                Write-Log -Text $_.Exception.Message
            }
        }         
    }


    #Compress-Image
    [Void]CompressImage($path) {
    
        $params= 'mogrify -quality 82 -resize {0}x{0}' -f $this.Longerside    
        $expression = 'magick {0} "{1}"' -f $params, $path 

        Try
        {
            #this does the work
            $er = (Invoke-Expression $expression) 2>&1 
     
            #this is all error handling below
            if($er -is [System.Management.Automation.ErrorRecord]){               
                throw [MyErrorRecord]::new($er)
            }
            if ($er.Length -gt 0) {               
                throw [MyEXCP1]::new($er)
            }
            if ($lastexitcode){                
                throw [MyEXCP2]::new($er)
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
            if($_.Exception.Emessage.CategoryInfo.TargetName.Contains("SOS parameters for sequential"))
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
            Write-Log -Text $_.Exception.ToString()
        }

        $this.imagesProcessed ++
    }


}