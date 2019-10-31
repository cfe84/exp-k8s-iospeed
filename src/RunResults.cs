namespace DiskIO
{
    internal class RunResults
    {
        private Params param;

        public RunResults(Params param)
        {
            this.param = param;
        }

        public TimingsAggregate WriteResults { get; internal set; }
        public TimingsAggregate ReadResults { get; internal set; }
        public TimingsAggregate WriteAndReadFiles { get; internal set; }
    }
}