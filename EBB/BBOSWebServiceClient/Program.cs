using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using CommandLine.Utility;

namespace BBOSWebServiceClient
{
    class Program
    {
        private static List<string> _lszOutputBuffer = new List<string>();
        private static string _szFilePrefix = null;

        static void Main(string[] args)
        {

            Console.Clear();
            Console.Title = "BB Web Services Client";
            WriteLine("BB Web Services Client 1.3");
            WriteLine("Copyright (c) 2009-2024 Blue Book Services");
            WriteLine("All Rights Reserved.");
            WriteLine("  OS Version: " + System.Environment.OSVersion.ToString());
            WriteLine(" CLR Version: " + System.Environment.Version.ToString());
            WriteLine(string.Empty);

            string szOutputDirectory = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Substring(6);

            // Command line parsing
            Arguments oCommandLine = new Arguments(args);

            string szWebMethod = oCommandLine["WebMethod"];
            string szParmValue = oCommandLine["ParmValue"];

            if (string.IsNullOrEmpty(szWebMethod))
            {
                WriteLine("ERROR: Missing WebMethod Parameter");
                DisplayHelp();
                return;
            }

            if ((szWebMethod != "GetListingDataForAllCompanies") &&
                (szWebMethod != "GetListingAndPersonDataForAllCompanies") &&
                (string.IsNullOrEmpty(szParmValue)))
            {
                WriteLine("ERROR: Missing ParmValue Parameter");
                DisplayHelp();
                return;
            }


            DateTime dtStart = DateTime.Now;
            try
            {
                BBServicesClient oBBServicesClient = new BBServicesClient();
                WriteLine(dtStart.ToString());
                WriteLine("Executing " + szWebMethod + "...");

                int iCompanyCount = 0;

                switch (szWebMethod)
                {
                    case "GetListingDataForAllCompanies":
                        iCompanyCount = oBBServicesClient.GetListingDataForAllCompanies();
                        break;

                    case "GetListingDataForCompany":
                        iCompanyCount = oBBServicesClient.GetListingDataForCompany(Convert.ToInt32(szParmValue));
                        break;

                    case "GetListingAndPersonDataForAllCompanies":
                        iCompanyCount = oBBServicesClient.GetListingAndPersonDataForAllCompanies();
                        break;

                    case "GetListingDataForWatchdogList":
                        iCompanyCount = oBBServicesClient.GetListingDataForWatchdogList(szParmValue);
                        break;

                    case "GetGeneralCompanyData":
                        iCompanyCount = oBBServicesClient.GetGeneralCompanyData(szParmValue);
                        break;

                    case "GetRatingCompanyData":
                        iCompanyCount = oBBServicesClient.GetRatingCompanyData(szParmValue);
                        break;

                    case "GetListingDataForCompanyList":
                        iCompanyCount = oBBServicesClient.GetListingDataForCompanyList(szParmValue);
                        break;

                    case "GetBusinessReport":
                        iCompanyCount = oBBServicesClient.GetBusinessReport(Convert.ToInt32(szParmValue));
                        break;

                    //case "GetUserBBID":
                    //    iCompanyCount = oBBServicesClient.GetUserBBID();
                    //    break;

                    default:
                        WriteLine("Unknown WebMethod Specified: " + szWebMethod);
                        break;
                }
                _szFilePrefix = oBBServicesClient.FilePrefix;
                WriteLine(iCompanyCount.ToString("###,##0") + " companies returned.");

            }
            catch (Exception e)
            {
                WriteLine(string.Empty);
                WriteLine(string.Empty);
                Console.ForegroundColor = ConsoleColor.Red;
                WriteLine("An unexpected exception occurred: " + e.Message);
                WriteLine("Terminating execution.");
                Console.ForegroundColor = ConsoleColor.Gray;
                WriteLine(string.Empty);
                WriteLine("Stack Trace: ");
                WriteLine(e.StackTrace);

            }
            finally
            {
                WriteLine(string.Empty);
                WriteLine("Execution Time: " + DateTime.Now.Subtract(dtStart).ToString());

                string szLogFile = Path.Combine(szOutputDirectory, _szFilePrefix + "_" + szWebMethod + ".txt");
                using (StreamWriter sw = new StreamWriter(szLogFile, false, Encoding.Unicode))
                {
                    foreach (string szLine in _lszOutputBuffer)
                    {
                        sw.WriteLine(szLine);
                    }
                }
            }

            Console.WriteLine("Press any key to continue...");
            Console.ReadKey(true);
        }

        static void WriteLine(string szLine)
        {
            Console.WriteLine(szLine);
            _lszOutputBuffer.Add(szLine);
        }

        static void DisplayHelp() {

            WriteLine(string.Empty);
            WriteLine("USAGE:");
            WriteLine("BBOSWebServiceClient.exe /WebMethod=[WebMethod] /ParmValue=[ParmValue]");
            WriteLine(string.Empty);
            WriteLine("/WebMethod = This is the BBOS Web Method to execute.");
            WriteLine("/ParmValue = This is the parameter for the BBOS Web Method");
            WriteLine(string.Empty);

            Console.WriteLine("Press any key to continue...");
            Console.ReadKey(true);
        }
    }


}

