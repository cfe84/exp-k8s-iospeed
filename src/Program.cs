using System;

namespace DiskIO
{
    class Program
    {
        static void Main(string[] args)
        {
            var p = Params.LoadFromEnv();
            var test = new IOTest(p);
            test.RunAsync().Wait();
        }
    }
}
