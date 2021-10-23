$actualDir = "I:\"

function Get-Files { 
    Get-ChildItem -Path $actualDir -Recurse | Where-Object {!$_.PsIsContainer -and !$_.PsIsContainer -and $_.FullName -notlike "*HEVC.mkv" -and $_.FullName -notlike "* - h265.mkv" -and $_.FullName -notlike "*.nfo" -and $_.FullName -notlike "*.jpg" -and $_.FullName -notlike "*.png" -and $_.FullName -notlike "*.bif" -and $_.FullName -notlike "*.mp3" -and $_.FullName -notlike "*tmm_3.1.15_win\*"
    }
}
function Get-NumFiles {
    Write-Output ( Get-Files  | Measure-Object ).Count
}

Get-NumFiles
while ($num -clt 0) {
    $FullPath = Get-Files | Sort-Object -Property Length | Select-Object BaseName, Name, DirectoryName, FullName, Length -First 1
    $h264Path = $FullPath.FullName
    $h264Length = $FullPath.Length
    $BaseName = $FullPath.BaseName.Substring(0, ($FullPath.BaseName).LastIndexOf(" - "))
    $h265Path = $FullPath.DirectoryName + "\" + $BaseName + " - h265.mkv"
    $h264Path = $FullPath.FullName
    HandBrakeCLI.exe --preset-import-file "C:\Users\aleja\OneDrive\WindowsModules\H.265\preset.json" -Z "H265v6" -i $h264Path -o $h265Path
    Remove-Item -Path "$h264Path"
    Get-NumFiles
}

