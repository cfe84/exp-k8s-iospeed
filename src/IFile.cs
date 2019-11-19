using System.Threading.Tasks;

namespace DiskIO
{
    interface IFile
    {
        string CombinePath(string a, string b);
        Task<byte[]> ReadAllBytesAsync(string path);
        Task WriteAllBytesAsync(string path, byte[] bytes);
        Task DeleteAsync(string file);
        Task<bool> DirectoryExistsAsync(string directoryName);
        Task CreateDirectoryAsync(string directoryName);

    }
}