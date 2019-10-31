using System;
using System.Diagnostics;
using System.IO;
using System.Threading.Tasks;

namespace DiskIO
{
    internal class Runner
    {


        Params param;
        public Runner(Params p)
        {
            this.param = p;
        }

        public async Task<RunResults> RunAsync()
        {
            RunResults results = new RunResults(param);
            CreateFolder(param.Folder);
            var files = CreateFileNames(param.Folder, "test1", param.FileCount);
            results.WriteResults = await WriteFiles(files, param.Iterations, param.FileSizeInBytes);
            results.ReadResults = await ReadFiles(files, param.Iterations, param.FileSizeInBytes);
            results.WriteAndReadFiles = await WriteAndReadFiles(files, param.Iterations, param.FileSizeInBytes);
            return results;
        }

        private void CreateFolder(string folder)
        {
            if (!Directory.Exists(folder))
            {
                Directory.CreateDirectory(folder);
            }
        }

        private string[] CreateFileNames(string folder, string stem, int fileCount)
        {
            var res = new string[fileCount];
            for (int i = 0; i < fileCount; i++)
            {
                res[i] = Path.Combine(folder, $"{stem}-{i}.txt");
            }
            return res;
        }

        private void DeleteFiles(string[] files)
        {
            foreach (string file in files)
            {
                File.Delete(file);
            }
        }

        private async Task<TimingsAggregate> WriteFiles(string[] files,
                                      int numberOfWrites,
                                      int fileSizeInBytes)
        {
            var content = new byte[fileSizeInBytes];
            var timings = new TimeSpan[files.Length * numberOfWrites];
            for (int loopCount = 0; loopCount < numberOfWrites; loopCount++)
            {
                for (int i = 0; i < files.Length; i++)
                {
                    var watch = Stopwatch.StartNew();
                    await File.WriteAllBytesAsync(files[i], content);
                    watch.Stop();
                    timings[i + loopCount * files.Length] = watch.Elapsed;
                }
                DeleteFiles(files);
            }
            return new TimingsAggregate(timings, fileSizeInBytes);
        }


        private async Task CreateFiles(string[] files,
                                      int fileSizeInBytes)
        {
            var content = new byte[fileSizeInBytes];
            for (int i = 0; i < files.Length; i++)
                await File.WriteAllBytesAsync(files[i], content);
        }

        private async Task<TimingsAggregate> ReadFiles(string[] files,
                                                 int numberOfReads,
                                                 int fileSizeInBytes)
        {
            var timings = new TimeSpan[files.Length * numberOfReads];
            for (int loopCount = 0; loopCount < numberOfReads; loopCount++)
            {
                await CreateFiles(files, fileSizeInBytes);
                for (int i = 0; i < files.Length; i++)
                {
                    var watch = Stopwatch.StartNew();
                    var content = await File.ReadAllBytesAsync(files[i]);
                    watch.Stop();
                    timings[i + loopCount * files.Length] = watch.Elapsed;
                }
                DeleteFiles(files);
            }
            return new TimingsAggregate(timings, fileSizeInBytes);
        }

        private async Task<TimingsAggregate> WriteAndReadFiles(string[] files,
                                             int numberOfWrites,
                                             int fileSizeInBytes)
        {
            var content = new byte[fileSizeInBytes];
            var timings = new TimeSpan[files.Length * numberOfWrites];
            for (int loopCount = 0; loopCount < numberOfWrites; loopCount++)
            {
                for (int i = 0; i < files.Length; i++)
                {
                    var watch = Stopwatch.StartNew();
                    await File.WriteAllBytesAsync(files[i], content);
                    var ctt = await File.ReadAllBytesAsync(files[i]);
                    watch.Stop();
                    timings[i + loopCount * files.Length] = watch.Elapsed;
                }
                DeleteFiles(files);
            }

            return new TimingsAggregate(timings, fileSizeInBytes);
        }
    }
}