#Requires -RunAsAdministrator

function Get-Computer-Info {
    Get-ComputerInfo
} 

function Get-Total-Memory {
    $capacity = (Get-CimInstance -Class CIM_PhysicalMemory -ErrorAction Stop).Capacity
    for ($i = 0; $i -lt $capacity.Count; $i++) {
        $totalCapacity += $capacity[$i]
    }
    $totalCapacity
}
function Convert-Size {            
    [cmdletbinding()]            
    param(            
        [validateset("Bytes","KB","MB","GB","TB")]            
        [string]$From,            
        [validateset("Bytes","KB","MB","GB","TB")]            
        [string]$To,            
        [Parameter(Mandatory=$true)]            
        [double]$Value,            
        [int]$Precision = 4            
    )            
    switch($From) {            
        "Bytes" {$value = $Value }            
        "KB" {$value = $Value * 1024 }            
        "MB" {$value = $Value * 1024 * 1024}            
        "GB" {$value = $Value * 1024 * 1024 * 1024}            
        "TB" {$value = $Value * 1024 * 1024 * 1024 * 1024}            
    }            
         
    switch ($To) {            
        "Bytes" {return $value}            
        "KB" {$Value = $Value/1KB}            
        "MB" {$Value = $Value/1MB}            
        "GB" {$Value = $Value/1GB}            
        "TB" {$Value = $Value/1TB}                   
    }                     
    return [Math]::Round($value,$Precision,[MidPointRounding]::AwayFromZero)            
}

function Get-Firmware-Type {
    return $env:firmware_type
}

function Get-Partition-Style {
    return (Get-Partition -DriveLetter C | Get-Disk).PartitionStyle
}

function Get-OS-Arch {
    return (Get-CimInstance Win32_operatingsystem).OSArchitecture
}

function Get-Tpm-A {
    $versionTPM = (wmic /namespace:\\root\cimv2\security\microsofttpm path win32_tpm get IsActivated_InitialValue /format:Wmiclivalueformat.xsl) -match '\S'
    $versionTPM = $versionTPM.split("=")
    return $versionTPM[1]
}

function Get-Tpm-V {
    $versionTPM = (wmic /namespace:\\root\cimv2\security\microsofttpm path win32_tpm get SpecVersion /format:Wmiclivalueformat.xsl) -match '\S'
    $versionTPM = $versionTPM.split("=").split(",")
    return $versionTPM[1]
}

function Get-Cpu-Info {
    $data = (Get-ComputerInfo).CsProcessors | Select-Object -Property Name, Architecture, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed

    $cpuName = $data.Name
    $cpuArch = $data.Architecture
    $cpuNumCores = $data.NumberOfCores
    $cpuNumLogicalProcessors = $data.NumberOfLogicalProcessors
    $cpuMaxClockSpeed = $data.MaxClockSpeed

    return @($cpuName, $cpuArch, $cpuNumCores, $cpuNumLogicalProcessors, $cpuMaxClockSpeed) 
}



$firmware = Get-Firmware-Type
$secureBoot = Confirm-SecureBootUEFI
$partitionStyle = Get-Partition-Style
$cpuArch = Get-OS-Arch
$getTPMactive = Get-Tpm-A
$getTPMversion = Get-Tpm-V
$totalMemory = Get-Total-Memory
$totalMemory = Convert-Size -From Bytes -To GB $totalMemory -Precision 2
$cpuInfo = Get-Cpu-Info

    $data = @(
        ("Firmware", "SecureBoot", "PartitionStyle", "CPU Arch", "TPM Active", "TPM Version", "Total Memory (in GB)", "CPU Info", "Number of Cores", "Number of Theads", "MaxClock"),
        ($firmware, $secureBoot, $partitionStyle, $cpuArch, $getTPMactive, $getTPMversion, $totalMemory, $cpuInfo[0], $cpuInfo[2], $cpuInfo[3], $cpuInfo[4])
    )



$data | ForEach-Object { $_ -join ','} |  out-file .\WhyNotRunW11.csv

$check = "✔"
$cross = "❌"
$warn = "❗"

if ($data[1][0] -eq "UEFI") {
    Write-Host($check + " " + $data[0][0] + " - " + $data[1][0] )
} else {
    Write-Host($cross + " " + $data[0][0] + " - " + $data[1][0] )
}

if ($data[1][1] -eq "True") {
    Write-Host($check + " " + $data[0][1] + " - " + $data[1][1] )
} else {
    Write-Host($cross + " " + $data[0][1] + " - " + $data[1][1] )
}

if ($data[1][2] -eq "GPT") {
    Write-Host($check + " " + $data[0][2] + " - " + $data[1][2] )
} else {
    Write-Host($cross + " " + $data[0][2] + " - " + $data[1][2] )
}

if ($data[1][3] -eq "64 bits") {
    Write-Host($check + " " + $data[0][3] + " - " + $data[1][3] )
} else {
    Write-Host($cross + " " + $data[0][3] + " - " + $data[1][3] )
}

if ($data[1][4] -eq "TRUE") {
    Write-Host($check + " " + $data[0][4] + " - " + $data[1][4] )
} else {
    Write-Host($cross + " " + $data[0][4] + " - " + $data[1][4] )
}

if ($data[1][5] -ge 2.0) {
    Write-Host($check + " " + $data[0][5] + " - " + $data[1][5] )
} elseif ($data[1][5] -lt 2.0 -and $data[1][5] -ge 1.2) {
    Write-Host($warn + " " + $data[0][5] + " - " + $data[1][5] )
}else {
    Write-Host($cross + " " + $data[0][5] + " - " + $data[1][5] )
}

if ($data[1][6] -ge 4) {
    Write-Host($check + " " + $data[0][6] + " - " + $data[1][6] )
} else {
    Write-Host($cross + " " + $data[0][6] + " - " + $data[1][6] )
}

Write-Host($warn + " " + $data[0][7] + " - " + $data[1][7] )

if ($data[1][8] -ge 2) {
    Write-Host($check + " " + $data[0][8] + " - " + $data[1][8] + " x " + $data[1][9]  )
} else {
    Write-Host($cross + " " + $data[0][8] + " - " + $data[1][8] + " x " + $data[1][9]  )
}