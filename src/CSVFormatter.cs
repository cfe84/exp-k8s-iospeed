using System;

namespace DiskIO
{
    internal class CSVFormatter : IFormatter
    {
        Params param;

        public CSVFormatter(Params param)
        {
            this.param = param;
        }

        public string FormatParameters(Params param)
        {
            return "";
        }

        private string header()
        {
            string result = "";
            result += OutputField("Run name");
            result += OutputField("Date");
            result += OutputField("File count");
            result += OutputField("File size");
            result += OutputField("Iterations");
            result += OutputField("Write (Mb/s)");
            result += OutputField("Read (Mb/s)");
            result += OutputField("Write/Read (Mb/s)");
            result += Environment.NewLine;
            return result;
        }

        private string OutputField(object value)
        {
            return $"\"{value}\",";
        }

        public string FormatResults(RunResults results)
        {
            string result = "";
            if (!param.HideHeader)
                result += header();
            result += OutputField(param.RunName);
            result += OutputField(DateTime.Now);
            result += OutputField(param.FileCount);
            result += OutputField(param.FileSizeInBytes);
            result += OutputField(param.Iterations);
            result += OutputField(results.WriteResults.AverageBandWidthMbps);
            result += OutputField(results.ReadResults.AverageBandWidthMbps);
            result += OutputField(results.WriteAndReadFiles.AverageBandWidthMbps);
            result += Environment.NewLine;
            return result;
        }
    }
}