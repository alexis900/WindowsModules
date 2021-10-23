#Import-Module Appx

#$url = 'https://github.com/microsoft/winget-cli/releases/download/v1.0.11692/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle'
#$filename = $url.split('/') | Select-Object -Last 1

#If (Test-Path $filename) {
#    Add-AppxPackage -Path $filename
#} Else {
#    Invoke-WebRequest -Uri $url -OutFile $filename
#    Add-AppxPackage -Path $filename
#}

Copy-Item .\settings.json -Destination "C:\Users\$env:UserName\AppData\Local\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json"

winget install --id Microsoft.WindowsTerminal -s msstore
winget install --id 7zip.7zip.Alpha.msi
winget install --id Microsoft.VisualStudioCode
winget install --id VideoLAN.VLC