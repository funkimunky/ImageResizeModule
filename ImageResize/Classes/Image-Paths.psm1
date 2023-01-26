Using module ..\..\files\ImportExcel
using module .\MyErrorRecord.psm1
using module .\MyEXCP1.psm1
using module .\MyEXCP2.psm1

Add-Type -AssemblyName System.Drawing

class Paths {    
    [int]$chunk_size
    [hashtable]$pathHash = @{}
    [System.Collections.ArrayList]$exclude_list
    [System.Collections.ArrayList]$include_list
    [System.Collections.ArrayList]$recursive_paths
    [System.Collections.ArrayList]$image_paths
    [int]$Longerside = 2500
    [Int]$BatchAmount = 200
    [bool]$batchLimitReached = $false
    $FinalTotal = 0
    $OrigionalTotal = 0
    $imagesProcessed = 0

    Paths($chunk_size = 10){
        Write-Log "Started processing $(Get-Date -Format u)"
        
        $this.chunk_size = $chunk_size
        $this.PathFromExcel()
        $this.PathChildren()
        
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


    #Get-Imagepaths
    [Void]PathChildren()
    {   
        $this.recursive_paths = [System.Collections.ArrayList]::new()
        $counter = 0        
        
        :outer
        foreach($path in $this.include_list){
            $systempath = Get-Item -Path $path
            $this.recursive_paths.Add($systempath.FullName) | Out-Null # https://stackoverflow.com/questions/10286164/function-return-value-in-powershell

            Get-ChildItem -Path $this.include_list -Directory -Recurse 
            | ForEach-Object{
                $allowed = $true
                foreach ($exclude in $this.exclude_list) { 
                    if (($_.Parent -ilike $exclude) -Or ($_ -ilike $exclude)) {
                        $allowed = $false
                        break
                    }
                }
                if ($allowed) {
                    $this.recursive_paths.Add($_.FullName)
                    $counter ++
                }    
                if($counter -ge $this.chunk_size){
                    [System.GC]::Collect()
                    [string]$outputStr = 'Chunk limit of {0} reached' -f $this.chunk_size
                    Write-Log -Text $outputStr 

                    $this.imagelist()

                    $this.recursive_paths = [System.Collections.ArrayList]::new()                   
                    
                    if($this.batchLimitReached){
                        break outer
                    }                    
                }        
            } | Out-Null # https://stackoverflow.com/questions/7325900/powershell-2-array-size-differs-between-return-value-and-caller
        }
    }

    
    #get-imagelist
    [Void]imagelist()
    { 
        $this.image_paths = [System.Collections.ArrayList]::new()

        $counter = 1
        :outer
        foreach($path in $this.recursive_paths){
            Get-ChildItem -Path $path -Filter *.jpg |         
            ForEach-Object {
                $t = [System.Drawing.Image]::FromFile($_.FullName)             
                if ($t.Width -gt $this.Longerside -or $t.Height -gt $this.Longerside ) {
                    if($counter -gt $this.BatchAmount){
                        [string]$outputStr = 'batch limit of {0} reached' -f $this.BatchAmount 
                        Write-Log -Text $outputStr                       
                        $t.Dispose()
                        [System.GC]::Collect()
                        $this.batchLimitReached = $true
                        break outer #breaking named loop https://stackoverflow.com/questions/36025696/break-out-of-inner-loop-only-in-nested-loop                    
                    }    
                    $this.image_paths.Add($_.FullName) 
                    $t.Dispose()     
                    $counter++                  
                }else{
                    $t.Dispose() #need to close connection to bitmap so it can be overwritten  
                }            
            } | 
            Out-Null         
        } 
        $this.ResizeImage()
    }

    #Resize-Image
    [void]ResizeImage(){ 
        $this.OrigionalTotal        
        ForEach ($Image in $this.image_paths){                
            # $Path = (Resolve-Path $Image).Path
            # $Dot = $Path.LastIndexOf(".")
            
            #make sure image can be written to
            Set-IsReadOnly-False -path $Image

            try 
            {
                # $OutputPath = $Path.Substring(0, $Dot) + $Path.Substring($Dot, $Path.Length - $Dot)                
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