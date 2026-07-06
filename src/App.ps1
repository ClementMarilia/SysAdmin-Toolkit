Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

$Script:AppRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

. "$Script:AppRoot\Core\Config.ps1"
. "$Script:AppRoot\Core\Localization.ps1"
. "$Script:AppRoot\Core\Logger.ps1"
. "$Script:AppRoot\Core\ModuleLoader.ps1"
. "$Script:AppRoot\Core\Navigation.ps1"

$Script:Config = Get-STConfig -RootPath $Script:AppRoot
$Script:Language = Get-STLanguage -RootPath $Script:AppRoot -LanguageCode $Script:Config.defaultLanguage
$Script:Modules = Get-STModules -RootPath $Script:AppRoot

$mainWindowPath = Join-Path $Script:AppRoot 'Views\MainWindow.xaml'
[xml]$xaml = Get-Content $mainWindowPath -Raw
$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

$controls = @{}
$xaml.SelectNodes('//*[@Name]') | ForEach-Object {
    $controls[$_.Name] = $window.FindName($_.Name)
}

function Set-STMainLanguage {
    $controls.TxtAppTitle.Text = Get-STText 'app.title'
    $controls.TxtSubtitle.Text = Get-STText 'app.subtitle'
    $controls.TxtSearch.Text = Get-STText 'search.placeholder'
    $controls.TxtDashboard.Text = Get-STText 'menu.dashboard'
    $controls.TxtServer.Text = Get-STText 'menu.server'
    $controls.TxtNetwork.Text = Get-STText 'menu.network'
    $controls.TxtServices.Text = Get-STText 'menu.services'
    $controls.TxtStorage.Text = Get-STText 'menu.storage'
    $controls.TxtEventViewer.Text = Get-STText 'menu.eventViewer'
    $controls.TxtTools.Text = Get-STText 'menu.tools'
    $controls.TxtMainTitle.Text = Get-STText 'dashboard.title'
    $controls.TxtMainSubtitle.Text = Get-STText 'dashboard.subtitle'
}

function Set-STDashboard {
    try {
        $serverInfo = Get-STDashboardData
        $controls.TxtHostname.Text = $serverInfo.Hostname
        $controls.TxtWindows.Text = $serverInfo.Windows
        $controls.TxtDomain.Text = $serverInfo.Domain
        $controls.TxtUptime.Text = $serverInfo.Uptime
        $controls.TxtIp.Text = $serverInfo.IP
        $controls.TxtHealth.Text = $serverInfo.Health
        $controls.TxtStatus.Text = Get-STText 'status.ready'
    }
    catch {
        Write-STLog -Level 'ERROR' -Message $_.Exception.Message
        $controls.TxtStatus.Text = Get-STText 'status.error'
    }
}

function Get-STDashboardData {
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $cs = Get-CimInstance -ClassName Win32_ComputerSystem
    $ip = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
        Where-Object { $_.IPAddress -notlike '169.254*' -and $_.IPAddress -ne '127.0.0.1' } |
        Select-Object -First 1 -ExpandProperty IPAddress

    $uptime = (Get-Date) - $os.LastBootUpTime

    [PSCustomObject]@{
        Hostname = $env:COMPUTERNAME
        Windows  = $os.Caption
        Domain   = $cs.Domain
        Uptime   = '{0}d {1}h' -f [int]$uptime.TotalDays, $uptime.Hours
        IP       = $ip
        Health   = 'OK'
    }
}

Set-STMainLanguage
Set-STDashboard

$controls.LanguageSelector.Add_SelectionChanged({
    if ($controls.LanguageSelector.SelectedItem -ne $null) {
        $code = $controls.LanguageSelector.SelectedItem.Tag
        $Script:Language = Get-STLanguage -RootPath $Script:AppRoot -LanguageCode $code
        Set-STMainLanguage
    }
})

$controls.BtnRefresh.Add_Click({ Set-STDashboard })

$window.ShowDialog() | Out-Null
