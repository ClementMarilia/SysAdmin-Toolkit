Write-Host "Building SysAdmin Toolkit..."

$Root = Split-Path -Parent $PSScriptRoot
$Source = Join-Path $Root 'src'
$Release = Join-Path $Root 'release\SysAdminToolkit'

Remove-Item $Release -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $Release | Out-Null

Copy-Item "$Source\config.json" $Release
Copy-Item "$Source\app.ps1" "$Release\app.ps1"
Copy-Item "$Source\lang" $Release -Recurse
Copy-Item "$Source\modules" $Release -Recurse

Write-Host 'Release folder created.'
Write-Host $Release
