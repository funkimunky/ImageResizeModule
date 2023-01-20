function Get-Size-Item-Kb
{
    param([string]$pth)
    $size = "{0:n2}" -f ((Get-Item -path $pth | measure-object -property length -sum).sum /1kb) + " kb"
    Return $size
}
