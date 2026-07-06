function Get-STLanguage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RootPath,

        [Parameter(Mandatory = $true)]
        [string]$LanguageCode
    )

    $languagePath = Join-Path $RootPath "Languages\$LanguageCode.json"

    if (-not (Test-Path $languagePath)) {
        $languagePath = Join-Path $RootPath 'Languages\it.json'
    }

    return Get-Content $languagePath -Raw | ConvertFrom-Json
}

function Get-STText {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Key
    )

    if ($null -eq $Script:Language) {
        return $Key
    }

    $value = $Script:Language.$Key

    if ([string]::IsNullOrWhiteSpace($value)) {
        return $Key
    }

    return $value
}
