using System;
using System.Threading.Tasks;

namespace DiskIO
{
    internal class ConsoleOutput : IOutput
    {
        public Task CloseAsync() => Task.CompletedTask;

        public Task OpenAsync() => Task.CompletedTask;

        public Task OutputAsync(string v)
        {
            Console.Write(v);
            return Task.CompletedTask;
        }
    }
}