Using module .\ImageResize 
Using module .\ImageResize\Classes\Image-Paths.psm1 

$FullPath = $MyInvocation.MyCommand.Path
$Global:RootPath = Split-Path $FullPath -Parent

[Paths]::new(2000)