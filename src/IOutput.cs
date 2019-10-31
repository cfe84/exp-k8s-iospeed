using System.Threading.Tasks;

namespace DiskIO
{
    internal interface IOutput
    {
        Task OpenAsync();
        Task OutputAsync(string v);
        Task CloseAsync();
    }
}