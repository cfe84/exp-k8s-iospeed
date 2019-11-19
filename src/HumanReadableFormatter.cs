using System;

namespace DiskIO
{
    internal class HumanReadableFormatter : IFormatter
    {
        public string FormatParameters(Params param)
        {
            string result = "";
            result += $"          ---- Parameters ----" + Environment.NewLine;
            result += $"              Files: {param.FileCount}" + Environment.NewLine;
            result += $"          File size: {param.FileSizeInBytes / (1024 * 1024)}Mb" + Environment.NewLine;
            result += $"         Iterations: {param.Iterations}" + Environment.NewLine;
            return result;
        }

        public string FormatResults(RunResults results)
        {
            string result = "";
            result += $"          ----   Results  ----" + Environment.NewLine;
            result += $"     Writing files | {results.WriteResults}" + Environment.NewLine;
            result += $"     Reading files | {results.ReadResults}" + Environment.NewLine;
            result += $"Writing/Read files | {results.WriteAndReadFiles}" + Environment.NewLine;
            return result;
        }

    }
}