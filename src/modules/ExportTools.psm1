function Export-STTextReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Content,

        [string]$Path = "$env:USERPROFILE\Desktop\SysAdminToolkit-Report.txt"
    )

    $Content | Out-File -FilePath $Path -Encoding UTF8
    return $Path
}

Export-ModuleMember -Function Export-STTextReport
