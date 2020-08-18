$actualDir = "F:\"
$getFiles =  Get-ChildItem -Path $actualDir -Recurse | where {!$_.PsIsContainer -and $_.FullName -notlike "*HEVC.mkv" -and $_.FullName -notlike "* - h265.mkv" -and $_.FullName -notlike "*.nfo" -and $_.FullName -notlike "*.jpg" -and $_.FullName -notlike "*.png" -and $_.FullName -notlike "*.bif"}

function Get-Files {
    Write-Output ( $getFiles  | Measure-Object ).Count
}

Get-Files
while ($num -clt 0) {
    $FullPath = $getFiles | Sort-Object -Property Length | Select-Object BaseName, Name, DirectoryName, FullName -First 1
    $h264Path = $FullPath.FullName
    $BaseName = $FullPath.BaseName.Substring(0, ($FullPath.BaseName).LastIndexOf(" - "))
    $h265Path = $FullPath.DirectoryName + "\" + $BaseName + " - h265.mkv"
    $h264Path = $FullPath.FullName
    Write-Host($h265Path)
    HandBrakeCLI.exe --preset-import-file "C:\Users\alexa\OneDrive\H.265\presetv3.json" -Z "H265v3" -i $h264Path -o $h265Path
    Remove-Item -Path "$h264Path"
    Get-Files
}

