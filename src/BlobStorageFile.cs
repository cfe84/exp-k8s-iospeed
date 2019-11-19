using System.IO;
using System.Threading.Tasks;
using Azure.Storage.Blobs;

namespace DiskIO
{
    class BlobStorageFile : IFile
    {
        BlobContainerClient client;

        public BlobStorageFile(string connectionString, string containerName)
        {
            var blobServiceClient = new BlobServiceClient(connectionString);
            client = blobServiceClient.GetBlobContainerClient(containerName);
            client.CreateIfNotExists();
        }

        public string CombinePath(string a, string b)
        {
            return $"{a}/{b}";
        }

        public Task CreateDirectoryAsync(string directoryName)
        {
            return Task.CompletedTask;
        }

        public async Task DeleteAsync(string file)
        {
            await client.DeleteBlobAsync(file);
        }

        public Task<bool> DirectoryExistsAsync(string directoryName)
        {
            return Task.FromResult(true);
        }

        public async Task<byte[]> ReadAllBytesAsync(string path)
        {
            var blobClient = client.GetBlobClient(path);
            var blob = await blobClient.DownloadAsync();
            var reader = new BinaryReader(blob.Value.Content);
            var res = reader.ReadBytes((int)blob.Value.ContentLength);
            return res;
        }

        public async Task WriteAllBytesAsync(string path, byte[] bytes)
        {
            var blobClient = client.GetBlobClient(path);
            var stream = new MemoryStream(bytes);
            var blob = await blobClient.UploadAsync(stream, true);
        }
    }
}