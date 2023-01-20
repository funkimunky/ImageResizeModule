Add-Type -AssemblyName System.Drawing
Function Get-imagelist{
    [cmdletbinding()]
    param (
        [Parameter(Position = 0, Mandatory=$true)][ValidateNotNullOrEmpty()][System.Array]$paths,
        [Int]$Width,
        [Int]$Height,
        [Int]$BatchAmount = 0
    )
    $ImageList = [System.Collections.ArrayList]::new()
    $arrpathlist = [System.Collections.ArrayList]$paths

    $counter = 1
    :outer
    foreach($path in $arrpathlist){
        Get-ChildItem -Path $path -Filter *.jpg |         
        ForEach-Object {
            $t = [System.Drawing.Image]::FromFile($_.FullName)             
            if ($t.Width -gt $Width -or $t.Height -gt $Height ) {
                if($counter -gt $BatchAmount){
                    [string]$outputStr = 'batch limit of {0} reached' -f $BatchAmount #need to add this to a log out
                    Write-Host $outputStr -ForegroundColor Magenta | Out-Null
                    $t.Dispose()
                    break outer #breaking named loop https://stackoverflow.com/questions/36025696/break-out-of-inner-loop-only-in-nested-loop                    
                }    
                $ImageList.Add($_) 
                $t.Dispose()     
                                   
            }else{
                $t.Dispose() #need to close connection to bitmap so it can be overwritten  
            }
            $counter++
        } | 
        Out-Null         
    } 

    return [System.Collections.ArrayList]$ImageList

}