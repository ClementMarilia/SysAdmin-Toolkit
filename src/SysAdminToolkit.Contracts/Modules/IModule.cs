namespace SysAdminToolkit.Contracts.Modules;

public interface IModule
{
    string Id { get; }
    string Name { get; }
    string Description { get; }
    string Version { get; }
    int Order { get; }

    Task InitializeAsync(CancellationToken cancellationToken = default);
}
