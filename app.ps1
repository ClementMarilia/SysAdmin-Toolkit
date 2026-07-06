Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

$RootPath = Split-Path -Parent $MyInvocation.MyCommand.Path

Import-Module "$RootPath\modules\ServerInfo.psm1" -Force
Import-Module "$RootPath\modules\NetworkTools.psm1" -Force
Import-Module "$RootPath\modules\ServiceTools.psm1" -Force
Import-Module "$RootPath\modules\StorageTools.psm1" -Force
Import-Module "$RootPath\modules\EventTools.psm1" -Force
Import-Module "$RootPath\modules\ExportTools.psm1" -Force

$configPath = Join-Path $RootPath "config.json"
$config = Get-Content $configPath -Raw | ConvertFrom-Json
$currentLanguage = $config.defaultLanguage

function Get-LanguageData {
    param([string]$LanguageCode)

    $languagePath = Join-Path $RootPath "lang\$LanguageCode.json"
    if (-not (Test-Path $languagePath)) {
        $languagePath = Join-Path $RootPath "lang\it.json"
    }

    return Get-Content $languagePath -Raw | ConvertFrom-Json
}

$lang = Get-LanguageData -LanguageCode $currentLanguage

function Convert-ToText {
    param($Data)

    if ($null -eq $Data) {
        return ""
    }

    return ($Data | Format-List | Out-String)
}

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="SysAdmin Toolkit"
        Height="720"
        Width="1100"
        WindowStartupLocation="CenterScreen"
        Background="#111827">
    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="240" />
            <ColumnDefinition Width="*" />
        </Grid.ColumnDefinitions>

        <Border Grid.Column="0" Background="#0B1220" Padding="16">
            <StackPanel>
                <TextBlock Name="TxtAppTitle" Text="SysAdmin Toolkit" Foreground="White" FontSize="22" FontWeight="Bold" Margin="0,0,0,20" />

                <TextBlock Name="TxtLanguage" Text="Lingua" Foreground="#9CA3AF" Margin="0,0,0,6" />
                <ComboBox Name="LanguageSelector" SelectedIndex="0" Margin="0,0,0,18">
                    <ComboBoxItem Content="Italiano" Tag="it" />
                    <ComboBoxItem Content="Português" Tag="pt" />
                    <ComboBoxItem Content="English" Tag="en" />
                    <ComboBoxItem Content="Español" Tag="es" />
                </ComboBox>

                <Button Name="BtnServerInfo" Height="36" Margin="0,0,0,8" />
                <Button Name="BtnIpConfig" Height="36" Margin="0,0,0,8" />
                <Button Name="BtnInternetTest" Height="36" Margin="0,0,0,8" />
                <Button Name="BtnDnsTest" Height="36" Margin="0,0,0,8" />
                <Button Name="BtnRunningServices" Height="36" Margin="0,0,0,8" />
                <Button Name="BtnStoppedServices" Height="36" Margin="0,0,0,8" />
                <Button Name="BtnDiskUsage" Height="36" Margin="0,0,0,8" />
                <Button Name="BtnSystemErrors" Height="36" Margin="0,0,0,8" />
                <Button Name="BtnExportTxt" Height="36" Margin="0,20,0,8" />
                <Button Name="BtnClear" Height="36" Margin="0,0,0,8" />
            </StackPanel>
        </Border>

        <Grid Grid.Column="1" Margin="20">
            <Grid.RowDefinitions>
                <RowDefinition Height="80" />
                <RowDefinition Height="*" />
            </Grid.RowDefinitions>

            <Border Grid.Row="0" Background="#1F2937" CornerRadius="10" Padding="18">
                <StackPanel>
                    <TextBlock Name="TxtHeader" Text="Dashboard" Foreground="White" FontSize="24" FontWeight="Bold" />
                    <TextBlock Text="Windows Server daily administration toolkit" Foreground="#9CA3AF" FontSize="13" />
                </StackPanel>
            </Border>

            <TextBox Name="OutputBox"
                     Grid.Row="1"
                     Margin="0,18,0,0"
                     Background="#030712"
                     Foreground="#E5E7EB"
                     BorderBrush="#374151"
                     FontFamily="Consolas"
                     FontSize="13"
                     TextWrapping="Wrap"
                     VerticalScrollBarVisibility="Auto"
                     HorizontalScrollBarVisibility="Auto"
                     AcceptsReturn="True"
                     IsReadOnly="True" />
        </Grid>
    </Grid>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

$controls = @{}
$xaml.SelectNodes("//*[@Name]") | ForEach-Object {
    $controls[$_.Name] = $window.FindName($_.Name)
}

function Set-UiLanguage {
    param($LanguageObject)

    $controls.TxtAppTitle.Text = $LanguageObject.app_title
    $controls.TxtHeader.Text = $LanguageObject.dashboard
    $controls.TxtLanguage.Text = $LanguageObject.language
    $controls.BtnServerInfo.Content = $LanguageObject.server_info
    $controls.BtnIpConfig.Content = $LanguageObject.ip_configuration
    $controls.BtnInternetTest.Content = $LanguageObject.internet_test
    $controls.BtnDnsTest.Content = $LanguageObject.dns_test
    $controls.BtnRunningServices.Content = $LanguageObject.running_services
    $controls.BtnStoppedServices.Content = $LanguageObject.stopped_services
    $controls.BtnDiskUsage.Content = $LanguageObject.disk_usage
    $controls.BtnSystemErrors.Content = $LanguageObject.system_errors
    $controls.BtnExportTxt.Content = $LanguageObject.export_txt
    $controls.BtnClear.Content = $LanguageObject.clear
}

function Write-OutputBox {
    param(
        [string]$Title,
        [scriptblock]$Action
    )

    $controls.OutputBox.Text = "$($lang.executing): $Title`r`n"
    $controls.OutputBox.AppendText(("=" * 90) + "`r`n`r`n")

    try {
        $result = & $Action
        $controls.OutputBox.AppendText((Convert-ToText -Data $result))
        $controls.OutputBox.AppendText("`r`n$($lang.completed).")
    }
    catch {
        $controls.OutputBox.AppendText("$($lang.error): $($_.Exception.Message)")
    }
}

Set-UiLanguage -LanguageObject $lang

$controls.LanguageSelector.Add_SelectionChanged({
    if ($controls.LanguageSelector.SelectedItem -ne $null) {
        $script:currentLanguage = $controls.LanguageSelector.SelectedItem.Tag
        $script:lang = Get-LanguageData -LanguageCode $script:currentLanguage
        Set-UiLanguage -LanguageObject $script:lang
    }
})

$controls.BtnServerInfo.Add_Click({ Write-OutputBox -Title $lang.server_info -Action { Get-STServerInfo } })
$controls.BtnIpConfig.Add_Click({ Write-OutputBox -Title $lang.ip_configuration -Action { Get-STIpConfiguration } })
$controls.BtnInternetTest.Add_Click({ Write-OutputBox -Title $lang.internet_test -Action { Test-STInternetConnection } })
$controls.BtnDnsTest.Add_Click({ Write-OutputBox -Title $lang.dns_test -Action { Test-STDnsResolution } })
$controls.BtnRunningServices.Add_Click({ Write-OutputBox -Title $lang.running_services -Action { Get-STRunningServices } })
$controls.BtnStoppedServices.Add_Click({ Write-OutputBox -Title $lang.stopped_services -Action { Get-STStoppedServices } })
$controls.BtnDiskUsage.Add_Click({ Write-OutputBox -Title $lang.disk_usage -Action { Get-STDiskUsage } })
$controls.BtnSystemErrors.Add_Click({ Write-OutputBox -Title $lang.system_errors -Action { Get-STSystemErrors } })

$controls.BtnExportTxt.Add_Click({
    try {
        $path = Export-STTextReport -Content $controls.OutputBox.Text
        [System.Windows.MessageBox]::Show("Report exported:`n$path", "SysAdmin Toolkit") | Out-Null
    }
    catch {
        [System.Windows.MessageBox]::Show($_.Exception.Message, "SysAdmin Toolkit") | Out-Null
    }
})

$controls.BtnClear.Add_Click({ $controls.OutputBox.Clear() })

$window.ShowDialog() | Out-Null
