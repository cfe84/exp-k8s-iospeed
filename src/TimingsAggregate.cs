using System;
using System.Linq;

namespace DiskIO
{
    class TimingsAggregate
    {
        private TimeSpan CalculateTotal(TimeSpan[] spans) =>
            spans.Aggregate(TimeSpan.Zero, (total, thisOne) => total.Add(thisOne));

        public override string ToString() => $"operations: {OperationCount}, total: {Total.TotalSeconds}s, average: {Average.TotalMilliseconds}ms, bandwidth: {Math.Round(AverageBandWidthMbps, 2)}MB/s, max: {Max.TotalMilliseconds}ms, min: {Min.TotalMilliseconds}ms";
        public int OperationCount { get; set; }
        public TimeSpan Max { get; set; }
        public TimeSpan Min { get; set; }
        public TimeSpan Average { get; set; }
        public double AverageBandWidthMbps { get; set; }
        public TimeSpan Total { get; set; }
        public TimingsAggregate(TimeSpan[] timings, int fileSizeInBytes)
        {
            OperationCount = timings.Length;
            Max = timings.Max();
            Min = timings.Min();
            Total = CalculateTotal(timings);
            Average = Total.Divide(OperationCount);
            var totalFileSizeInMb = (timings.Length * fileSizeInBytes) / (1024 * 1024);
            AverageBandWidthMbps = totalFileSizeInMb / Total.TotalSeconds;
        }
    }
}