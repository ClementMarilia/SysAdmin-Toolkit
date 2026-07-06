using System.Windows.Input;
using SysAdminToolkit.Commands;
using SysAdminToolkit.Models;
using SysAdminToolkit.Services;

namespace SysAdminToolkit.ViewModels;

public sealed class MainViewModel : ViewModelBase
{
    private readonly SystemInfoService _systemInfoService = new();
    private DashboardData _dashboard = new();
    private string _statusMessage = "Ready";
    private string _currentLanguage = "it";

    public MainViewModel()
    {
        RefreshCommand = new RelayCommand(_ => RefreshDashboard());
        RefreshDashboard();
    }

    public DashboardData Dashboard
    {
        get => _dashboard;
        private set => SetProperty(ref _dashboard, value);
    }

    public string StatusMessage
    {
        get => _statusMessage;
        private set => SetProperty(ref _statusMessage, value);
    }

    public string CurrentLanguage
    {
        get => _currentLanguage;
        set => SetProperty(ref _currentLanguage, value);
    }

    public ICommand RefreshCommand { get; }

    private void RefreshDashboard()
    {
        try
        {
            Dashboard = _systemInfoService.GetDashboardData();
            StatusMessage = "Dashboard updated";
        }
        catch (Exception ex)
        {
            StatusMessage = $"Error: {ex.Message}";
        }
    }
}
