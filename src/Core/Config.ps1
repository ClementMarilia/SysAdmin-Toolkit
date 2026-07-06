function Get-STConfig {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RootPath
    )

    $configPath = Join-Path $RootPath 'config.json'

    if (-not (Test-Path $configPath)) {
        throw "Configuration file not found: $configPath"
    }

    return Get-Content $configPath -Raw | ConvertFrom-Json
}
