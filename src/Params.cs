using System;
using System.Text.RegularExpressions;

namespace DiskIO
{
    internal class Params
    {
        public IFile FileDriver { get; set; }
        public int Iterations { get; set; }
        public string Folder { get; set; }
        public int FileCount { get; set; }
        public int FileSizeInBytes { get; set; }
        public string Format { get; set; }
        public bool HideHeader { get; set; } = false;
        public string RunName { get; set; }
        const int MEGABYTE = 1024 * 1024;
        const int KILOBYTE = 1024;

        internal static int parseSize(string inputSize)
        {
            var regex = new Regex(@"^(\d+)[ ]?([Mk]?)i?b?$");
            string[] res = regex.Split(inputSize);
            int size = int.Parse(res[1]);
            var unit = res[2];
            if (unit == "M")
                size *= MEGABYTE;
            if (unit == "k")
                size *= KILOBYTE;
            return size;
        }
        internal static Params LoadFromEnv()
        {
            var result = new Params();
            result.RunName = Environment.GetEnvironmentVariable("RUN_NAME");
            result.Folder = Environment.GetEnvironmentVariable("FOLDER");
            result.Iterations = int.Parse(Environment.GetEnvironmentVariable("ITERATIONS"));
            result.FileCount = int.Parse(Environment.GetEnvironmentVariable("FILE_COUNT"));
            result.FileSizeInBytes = parseSize(Environment.GetEnvironmentVariable("FILE_SIZE"));
            result.Format = Environment.GetEnvironmentVariable("FORMAT");
            result.HideHeader = Environment.GetEnvironmentVariable("HIDE_HEADER") == "true";
            result.FileDriver = LoadDriver(Environment.GetEnvironmentVariable("FILE_DRIVER"));
            return result;
        }

        private static IFile LoadDriver(string driverName)
        {
            switch (driverName)
            {
                case "blob":
                    var connectionString = Environment.GetEnvironmentVariable("CONNECTION_STRING");
                    var containerName = Environment.GetEnvironmentVariable("CONTAINER_NAME") ?? "speedtest";
                    return new BlobStorageFile(connectionString, containerName);
                case "fs":
                default:
                    return new FsFile();
            }
        }

        internal static Params Parse(string[] args)
        {
            var result = new Params();
            result.Folder = args[0];
            result.Iterations = int.Parse(args[1]);
            result.FileCount = int.Parse(args[2]);
            result.FileSizeInBytes = int.Parse(args[3]);
            return result;
        }
    }
}