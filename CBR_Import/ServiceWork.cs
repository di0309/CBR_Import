using System;
using System.Configuration;
using System.Data.SqlTypes;
using System.IO;
using System.IO.Compression;
using System.Net;
using System.Xml;

namespace CBR_Import
{
    class ServiceWork
    {
        public static void Main()
        {
            string downloadUrl = ConfigurationManager.AppSettings["downloadUrl"];
            string pathToFile = ConfigurationManager.AppSettings["pathToFile"];

            DownloadFile(downloadUrl, pathToFile);
            string fileName = UnzipFile(pathToFile);
            DeleteFile(pathToFile);
            DeleteFile(fileName);
        }
        private static void DownloadFile(string downloadUrl, string pathToFile)
        {
            WebClient client = new WebClient();
            client.DownloadFile(downloadUrl, pathToFile);
        }
        private static string UnzipFile(string pathToFile)
        {
            string fileName = string.Empty;
            if (!File.Exists(pathToFile))
            {
                Logger.WriteLog("Файл не найден.");
                return string.Empty;
            }

            string extractPath = Path.GetDirectoryName(pathToFile);
            if (!extractPath.EndsWith(Path.DirectorySeparatorChar.ToString(), StringComparison.Ordinal))
                extractPath += Path.DirectorySeparatorChar;
            using (ZipArchive archive = ZipFile.OpenRead(pathToFile))
            {
                foreach (ZipArchiveEntry entry in archive.Entries)
                {
                    if (entry.FullName.EndsWith(".xml", StringComparison.OrdinalIgnoreCase))
                    {
                        string destinationPath = Path.GetFullPath(Path.Combine(extractPath, entry.FullName));

                        if (destinationPath.StartsWith(extractPath, StringComparison.Ordinal))
                        {
                            entry.ExtractToFile(destinationPath);
                            fileName = pathToFile.Substring(0, 3) + entry.Name;
                            ReadXmlFile(fileName);
                        }
                    }
                }
            }

            Logger.WriteLog("Файл распакован");
            return fileName;
        }
        private static void DeleteFile(string pathToFile)
        {
            if (File.Exists(pathToFile))
            {
                File.Delete(pathToFile);
            }
        }
        private static void ReadXmlFile(string filename)
        {
            XmlDocument doc = new XmlDocument();
            DbClass dbClass = new DbClass();

            doc.Load(filename);

            StringWriter sw = new StringWriter();
            XmlTextWriter xw = new XmlTextWriter(sw);
            doc.WriteTo(xw);
            StringReader transactionXml = new StringReader(sw.ToString());
            XmlTextReader xmlReader = new XmlTextReader(transactionXml);
            SqlXml sqlXml = new SqlXml(xmlReader);
            dbClass.ImportData(sqlXml);
        }
    }
}
