function Get-Size-Item-mb
{
    param([string]$pth)
    $size = "{0:n2}" -f ((Get-Item -path $pth | measure-object -property length -sum).sum /1mb)
    Return [float]$size
}