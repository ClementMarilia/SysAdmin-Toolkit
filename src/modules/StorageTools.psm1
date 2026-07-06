function Get-STDiskUsage {
    [CmdletBinding()]
    param()

    Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" |
        Select-Object DeviceID, VolumeName,
            @{Name="SizeGB";Expression={[math]::Round($_.Size / 1GB, 2)}},
            @{Name="FreeGB";Expression={[math]::Round($_.FreeSpace / 1GB, 2)}},
            @{Name="UsedPercent";Expression={[math]::Round((($_.Size - $_.FreeSpace) / $_.Size) * 100, 2)}}
}

Export-ModuleMember -Function Get-STDiskUsage
