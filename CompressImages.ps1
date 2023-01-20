$Global:FinalTotal = 0
$Global:OrigionalTotal = 0
Import-Module -Name .\ImageResize -Force

$longerSide = 2500
Write-Log "Started processing $(Get-Date -Format u)" #change this to output log file
$ExcelPaths = Get-pathfile -IncludeExcludePath $PSScriptRoot
$paths = Get-Imagepaths -ExcelPaths $ExcelPaths
$image_list = Get-imagelist -paths $paths -Width $longerSide -Height $longerSide -batch 5000
if($null -ne $image_list){
    Resize-Image -ImagePath $image_list -Longerside $longerSide -OverWrite   
    Write-Log "Origional storage used $Global:OrigionalTotal MB : Storage used after compression $Global:FinalTotal MB)"  #change this to output log file
    Write-Log "end processing $(Get-Date -Format u)"  #change this to output log file
}else{
    Write-Log "No images to process"  #change this to output log file
    Write-Log "end processing $(Get-Date -Format u)"  #change this to output log file    
}
