using System.Management;
using System.Net.NetworkInformation;
using System.Net.Sockets;
using SysAdminToolkit.Models;

namespace SysAdminToolkit.Services;

public sealed class SystemInfoService
{
    public DashboardData GetDashboardData()
    {
        var hostname = Environment.MachineName;
        var domain = Environment.UserDomainName;
        var windows = GetWindowsCaption();
        var uptime = GetUptime();
        var ip = GetPrimaryIpv4Address();

        return new DashboardData
        {
            Hostname = hostname,
            WindowsVersion = windows,
            Domain = $"Domain: {domain}",
            Uptime = uptime,
            IpAddress = $"IP: {ip}",
            Health = "OK"
        };
    }

    private static string GetWindowsCaption()
    {
        try
        {
            using var searcher = new ManagementObjectSearcher("SELECT Caption, Version FROM Win32_OperatingSystem");
            foreach (var item in searcher.Get())
            {
                var caption = item["Caption"]?.ToString() ?? "Windows";
                var version = item["Version"]?.ToString() ?? string.Empty;
                return string.IsNullOrWhiteSpace(version) ? caption : $"{caption} ({version})";
            }
        }
        catch
        {
            return Environment.OSVersion.VersionString;
        }

        return Environment.OSVersion.VersionString;
    }

    private static string GetUptime()
    {
        var uptime = TimeSpan.FromMilliseconds(Environment.TickCount64);
        return $"{(int)uptime.TotalDays}d {uptime.Hours}h";
    }

    private static string GetPrimaryIpv4Address()
    {
        foreach (var networkInterface in NetworkInterface.GetAllNetworkInterfaces())
        {
            if (networkInterface.OperationalStatus != OperationalStatus.Up)
            {
                continue;
            }

            var properties = networkInterface.GetIPProperties();
            var address = properties.UnicastAddresses
                .FirstOrDefault(a => a.Address.AddressFamily == AddressFamily.InterNetwork && !a.Address.ToString().StartsWith("169.254"));

            if (address is not null)
            {
                return address.Address.ToString();
            }
        }

        return "No IP detected";
    }
}
