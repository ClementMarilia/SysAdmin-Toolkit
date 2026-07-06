function Get-STIpConfiguration {
    [CmdletBinding()]
    param()

    Get-NetIPConfiguration | Select-Object InterfaceAlias, InterfaceDescription, IPv4Address, IPv6Address, IPv4DefaultGateway, DNSServer
}

function Test-STInternetConnection {
    [CmdletBinding()]
    param(
        [string]$Target = "google.com",
        [int]$Port = 443
    )

    Test-NetConnection -ComputerName $Target -Port $Port
}

function Test-STDnsResolution {
    [CmdletBinding()]
    param(
        [string]$Name = "google.com"
    )

    Resolve-DnsName -Name $Name -ErrorAction Stop
}

Export-ModuleMember -Function Get-STIpConfiguration, Test-STInternetConnection, Test-STDnsResolution
