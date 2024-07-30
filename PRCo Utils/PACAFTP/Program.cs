using System;
using System.Configuration;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Net;

namespace PACAFTP
{
    class Program
    {
        private static List<string> _lszOutputBuffer = new List<string>();

        static void Main(string[] args)
        {
            Console.Clear();
            Console.Title = "PACA FTP Utility";
            WriteLine("PACA FTP Utility 1.0");
            WriteLine("Copyright (c) 2010 Blue Book Services, Inc.");
            WriteLine("All Rights Reserved.");
            WriteLine("  OS Version: " + System.Environment.OSVersion.ToString());
            WriteLine(" CLR Version: " + System.Environment.Version.ToString());
            WriteLine(string.Empty);

            DateTime fileDate = DateTime.Today.AddDays(-1);

            if (args.Length > 0)
            {
                if (!string.IsNullOrEmpty(args[0]))
                {
                    if (DateTime.TryParse(args[0], out fileDate))
                    {
                        WriteLine("Found date override on command line: " + args[0]);
                        WriteLine(string.Empty);
                    }
                }
            }

            downloadPACAFiles(fileDate);
        }

        private static void downloadPACAFiles(DateTime fileDate)
        {
            DateTime start = DateTime.Now;

            WebClient ftpClient = new WebClient();
            ftpClient.Credentials = new NetworkCredential(ConfigurationManager.AppSettings["PACAUserID"],
                                                          ConfigurationManager.AppSettings["PACAPassword"]);

            string outputDir = ConfigurationManager.AppSettings["PACAFolder"];
            string serverURL = ConfigurationManager.AppSettings["PACAURL"];


            string timestamp = fileDate.ToString("yyyyMMdd");

            downloadFile(ftpClient, serverURL + timestamp + "license.csv", Path.Combine(outputDir, timestamp + "license.csv"));
            downloadFile(ftpClient, serverURL + timestamp + "trade.csv", Path.Combine(outputDir, timestamp + "trade.csv"));
            downloadFile(ftpClient, serverURL + timestamp + "principal.csv", Path.Combine(outputDir, timestamp + "principal.csv"));

            TimeSpan elapsedTime = DateTime.Now.Subtract(start);
            WriteLine(string.Empty);
            WriteLine("Elapsed Time: " + elapsedTime.Hours.ToString("00") + ":" + elapsedTime.Minutes.ToString("00") + ":" + elapsedTime.Seconds.ToString("00") + "." + elapsedTime.Milliseconds.ToString("000"));


            string outputFile = Path.Combine(outputDir, DateTime.Now.ToString("yyyyMMdd_hhmmss") + "_PACAFTP_Log.txt");
            using (StreamWriter sw = new StreamWriter(outputFile))
            {
                foreach (string szLine in _lszOutputBuffer)
                {
                    sw.WriteLine(szLine);
                }
            }
        }

        private static void downloadFile(WebClient ftpClient, string url, string fileName)
        {
            WriteLine("Downloading " + url + ".");
            try
            {
                byte[] fileData = ftpClient.DownloadData(url);


                if (File.Exists(fileName))
                {
                    File.Delete(fileName);
                }

                using (FileStream file = File.Create(fileName))
                {
                    file.Write(fileData, 0, fileData.Length);
                    file.Close();
                    WriteLine(" - Saved to " + fileName + ".");
                }
            }
            catch (WebException wEx)
            {
                WriteLine(" - Exception downloading file: " + wEx.Message);
            }
            catch (IOException ioEx)
            {
                WriteLine(" - Exception saving file: " + ioEx.Message);
            }
        }

        private static void WriteLine(string szLine)
        {
            Console.WriteLine(szLine);
            _lszOutputBuffer.Add(szLine);
        }
    }
}
