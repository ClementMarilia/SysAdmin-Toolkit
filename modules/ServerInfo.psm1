function Get-STServerInfo {
    [CmdletBinding()]
    param()

    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $cs = Get-CimInstance -ClassName Win32_ComputerSystem
    $bios = Get-CimInstance -ClassName Win32_BIOS

    [PSCustomObject]@{
        Hostname     = $env:COMPUTERNAME
        Domain       = $cs.Domain
        Manufacturer = $cs.Manufacturer
        Model        = $cs.Model
        Windows      = $os.Caption
        Version      = $os.Version
        Build        = $os.BuildNumber
        Architecture = $os.OSArchitecture
        LastBoot     = $os.LastBootUpTime
        Uptime       = (Get-Date) - $os.LastBootUpTime
        SerialNumber = $bios.SerialNumber
    }
}

Export-ModuleMember -Function Get-STServerInfo
