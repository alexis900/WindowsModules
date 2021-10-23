function Get-Cpu-Info {
    $data = (Get-ComputerInfo).CsProcessors | Select-Object Name, Architecture, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed
    $data2 = $data.Name
    return $data2 
}

$cpuInfo = Get-Cpu-Info

$data = @(
    ("CPU Info", "Number of Cores", "Number of Theads"),
    ($cpuInfo)
    )

$data | ForEach-Object { $_ -join ','} |  out-file .\WhyNotRunW11TEST.csv
