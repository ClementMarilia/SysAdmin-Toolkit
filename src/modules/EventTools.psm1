function Get-STSystemErrors {
    [CmdletBinding()]
    param(
        [int]$MaxEvents = 20
    )

    Get-WinEvent -FilterHashtable @{ LogName = "System"; Level = 2 } -MaxEvents $MaxEvents |
        Select-Object TimeCreated, ProviderName, Id, LevelDisplayName, Message
}

Export-ModuleMember -Function Get-STSystemErrors
