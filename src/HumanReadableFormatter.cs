using System;

namespace DiskIO
{
    internal class HumanReadableFormatter : IFormatter
    {
        public string FormatParameters(Params param)
        {
            string result = "";
            result += $"          ---- Parameters ----";
            result += $"              Files: {param.FileCount}";
            result += $"          File size: {param.FileSizeInBytes / (1024 * 1024)}Mb";
            result += $"         Iterations: {param.Iterations}";
            return result;
        }

        public string FormatResults(RunResults results)
        {
            string result = "";
            result += $"          ----   Results  ----";
            result += $"     Writing files | {results.WriteResults}";
            result += $"     Reading files | {results.ReadResults}";
            result += $"Writing/Read files | {results.WriteAndReadFiles}";
            return result;
        }

    }
}