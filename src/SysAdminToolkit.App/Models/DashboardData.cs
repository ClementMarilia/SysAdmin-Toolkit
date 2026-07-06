namespace SysAdminToolkit.Models;

public sealed class DashboardData
{
    public string Hostname { get; init; } = "Unknown";
    public string WindowsVersion { get; init; } = "Unknown";
    public string Domain { get; init; } = "Workgroup";
    public string IpAddress { get; init; } = "No IP detected";
    public string Uptime { get; init; } = "Unknown";
    public string Health { get; init; } = "OK";
}
