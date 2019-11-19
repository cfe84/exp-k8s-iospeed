using System.IO;
using System.Threading.Tasks;

namespace DiskIO
{
    class FsFile : IFile
    {
        public string CombinePath(string a, string b)
        {
            return Path.Combine(a, b);
        }

        public Task CreateDirectoryAsync(string directoryName)
        {
            Directory.CreateDirectory(directoryName);
            return Task.CompletedTask;
        }

        public Task DeleteAsync(string file)
        {
            Directory.Delete(file);
            return Task.CompletedTask;
        }

        public Task<bool> DirectoryExistsAsync(string directoryName)
        {
            return Task.FromResult(Directory.Exists(directoryName));
        }

        public Task<byte[]> ReadAllBytesAsync(string path)
        {
            return File.ReadAllBytesAsync(path);
        }

        public Task WriteAllBytesAsync(string path, byte[] bytes)
        {
            return File.WriteAllBytesAsync(path, bytes);
        }
    }
}