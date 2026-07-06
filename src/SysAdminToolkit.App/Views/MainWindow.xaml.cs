using System.Windows;
using SysAdminToolkit.ViewModels;

namespace SysAdminToolkit.Views;

public partial class MainWindow : Window
{
    public MainWindow()
    {
        InitializeComponent();
        DataContext = new MainViewModel();
    }
}
