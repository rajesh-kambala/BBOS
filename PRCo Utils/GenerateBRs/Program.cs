using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Text;
using System.Net;

using PRCo.BBS;
using CommandLine.Utility;

namespace GenerateBRs
{
    /// <summary>
    /// Hello World
    /// </summary>
    class Program
    {
        static void Main(string[] args)
        {

            Program program = new Program();
            program.GenerateBRs(args);
        }


        public void GenerateBRs(string[] args)
        {
            Console.Clear();
            Console.Title = "Generate BRs Utility";
            Console.WriteLine("Generate BRs Utility 1.0");
            Console.WriteLine("Copyright (c) 2011 Produce Reporter Co.");
            Console.WriteLine("All Rights Reserved.");
            Console.WriteLine("  OS Version: " + System.Environment.OSVersion.ToString());
            Console.WriteLine(" CLR Version: " + System.Environment.Version.ToString());
            Console.WriteLine(string.Empty);

            // Command line parsing
            Arguments oCommandLine = new Arguments(args);

            string companyIDList = null;
            if (oCommandLine["BBIDs="] != null)
            {
                companyIDList = oCommandLine["BBIDs="];
            }
            else
            {
                companyIDList = ConfigurationManager.AppSettings["BBIDs"];
            }


            if (string.IsNullOrEmpty(companyIDList))
            {

                Console.WriteLine();
                Console.WriteLine("No company IDs found.  Either specify in the config file using a key of 'BBID' or specify on the command line with BBID=");
            }
            else
            {

                string outputFolder = ConfigurationManager.AppSettings["OutputFolder"];
                if (!Directory.Exists(outputFolder))
                {
                    Directory.CreateDirectory(outputFolder);
                }

                try
                {


                    string[] companyIDs = companyIDList.Split(',');
                    foreach (string companyID in companyIDs)
                    {
                        Console.WriteLine(" - Generating reports for " + companyID);
                        generateProdMirrorBR(companyID, outputFolder);
                        generateQABR(companyID, outputFolder);
                    }

                    Console.WriteLine();
                    Console.WriteLine("Generated Business Reports for " + companyIDs.Length.ToString() + " companies.");

                }
                catch (Exception e)
                {
                    Console.WriteLine();
                    Console.WriteLine();
                    Console.ForegroundColor = ConsoleColor.Red;
                    Console.WriteLine("An unexpected exception occurred: " + e.Message);
                    Console.WriteLine("Terminating execution.");
                    Console.ForegroundColor = ConsoleColor.Gray;
                }
            }

            Console.WriteLine("Press any key to continue...");
            Console.ReadKey(true);

        }




        protected void generateProdMirrorBR(string companyID, string outputFolder)
        {


            Uri uri = new Uri(string.Format(ConfigurationManager.AppSettings["ProdMirrorBRReportURL"], companyID));
            HttpWebRequest httpRequest = (HttpWebRequest)WebRequest.Create(uri);
            httpRequest.Credentials = new NetworkCredential(ConfigurationManager.AppSettings["SRSWebServiceUserID"],
                                                            ConfigurationManager.AppSettings["SRSWebServicePassword"],
                                                            ConfigurationManager.AppSettings["SRSWebServiceDomain"]);
            
            HttpWebResponse httpResponse = (HttpWebResponse)httpRequest.GetResponse();

            try
            {
                if (httpResponse.StatusCode != HttpStatusCode.OK)
                {
                    throw new ApplicationException("Non-OK HTTP Status Code: " + httpResponse.StatusDescription);
                }

                Stream report = httpResponse.GetResponseStream();
                using (var fileStream = File.Create(getFileName(companyID, outputFolder, "PM")))
                { 
                    report.CopyTo(fileStream); 
                } 

            }
            finally
            {
                httpResponse.Close();
            }
        }

        protected void generateQABR(string companyID, string outputFolder)
        {
            ReportInterface oReportInterface = new ReportInterface();
            byte[] abReport = oReportInterface.GenerateBusinessReport(companyID, 4);

            using (FileStream oFStream = File.Create(getFileName(companyID, outputFolder, "QA"), abReport.Length))
            {
                oFStream.Write(abReport, 0, abReport.Length);
            }
        }

        protected string getFileName(string companyID, string outputFolder, string server)
        {
            return Path.Combine(outputFolder, "BR_" + companyID.ToString() + "_" + server + ".pdf");
        }
    }
}
