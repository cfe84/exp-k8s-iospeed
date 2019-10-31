using System.Threading.Tasks;

namespace DiskIO
{
    internal class BlobStorageOutput : IOutput
    {
        private string storageConnectionString;
        private string containerName;

        public BlobStorageOutput(string storageConnectionString, string containerName)
        {
            this.storageConnectionString = storageConnectionString;
            this.containerName = containerName;
        }

        public Task CloseAsync()
        {
            throw new System.NotImplementedException();
        }

        public Task OpenAsync()
        {
            throw new System.NotImplementedException();
        }

        public Task OutputAsync(string v)
        {
            throw new System.NotImplementedException();
        }
    }
}