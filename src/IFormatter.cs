namespace DiskIO
{
    internal interface IFormatter
    {
        string FormatParameters(Params param);
        string FormatResults(RunResults results);
    }
}