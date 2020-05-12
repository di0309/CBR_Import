using System;
using System.Collections.Concurrent;
using System.IO;
using System.Text;
using System.Threading.Tasks;

namespace CBR_Import
{
    public static class Logger
    {
        private static BlockingCollection<string> blockingCollection;
        private static string filename = "log.txt";
        private static Task task;

        static Logger()
        {
            blockingCollection = new BlockingCollection<string>();

            task = Task.Factory.StartNew(() =>
            {
                using (var streamWriter = new StreamWriter(filename, true, Encoding.UTF8))
                {
                    streamWriter.AutoFlush = true;

                    foreach (var s in blockingCollection.GetConsumingEnumerable())
                        streamWriter.WriteLine(s);
                }
            },
            TaskCreationOptions.LongRunning);
        }

        public static void WriteLog(string action)
        {
            blockingCollection.Add($"{DateTime.Now.ToString("dd.MM.yyyy HH:mm:ss.fff")} действие: {action}");
        }

        public static void Flush()
        {
            blockingCollection.CompleteAdding();
            task.Wait();
        }
    }
}
