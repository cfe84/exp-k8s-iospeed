using System;
using System.Threading.Tasks;

namespace DiskIO
{
    internal class IOTest
    {
        private Params p;
        private IFormatter formatter;
        private IOutput output;

        public IOTest(Params p)
        {
            this.p = p;
            if (p.Format == "csv")
                formatter = new CSVFormatter(p);
            else
                formatter = new HumanReadableFormatter();
            output = new ConsoleOutput();
        }

        public async Task RunAsync()
        {
            await output.OpenAsync();
            await output.OutputAsync(formatter.FormatParameters(p));
            var runner = new Runner(p);
            var results = await runner.RunAsync();
            await output.OutputAsync(formatter.FormatResults(results));
            await output.CloseAsync();
        }
    }
}