function Get-STRunningServices {
    [CmdletBinding()]
    param()

    Get-Service | Where-Object { $_.Status -eq "Running" } | Sort-Object Name | Select-Object Name, DisplayName, Status, StartType
}

function Get-STStoppedServices {
    [CmdletBinding()]
    param()

    Get-Service | Where-Object { $_.Status -eq "Stopped" } | Sort-Object Name | Select-Object Name, DisplayName, Status, StartType
}

Export-ModuleMember -Function Get-STRunningServices, Get-STStoppedServices
