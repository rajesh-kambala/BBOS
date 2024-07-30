using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using CommandLine.Utility;

namespace BBOSEmailer
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.Clear();
            Console.Title = "BBOS Emailer Utility";
            Console.WriteLine("BBOS Emailer Utility 1.0");
            Console.WriteLine("Copyright (c) 2020 Blue Book Services, Inc.");
            Console.WriteLine("All Rights Reserved.");
            Console.WriteLine("  OS Version: " + System.Environment.OSVersion.ToString());
            Console.WriteLine(" CLR Version: " + System.Environment.Version.ToString());

            if (args.Length == 0)
            {
                DisplayHelp();
                return;
            }

            // Command line parsing
            Arguments oCommandLine = new Arguments(args);

            if ((oCommandLine["help"] != null) ||
                (oCommandLine["?"] != null))
            {
                DisplayHelp();
                return;
            }

            if (oCommandLine["Template"] == null)
            {
                WriteErrorMsg("ERROR: Invalid /Template parameter specified.");
                return;
            }
            if (oCommandLine["Subject"] == null)
            {
                WriteErrorMsg("ERROR: Invalid /Subject parameter specified.");
                return;
            }
            if (oCommandLine["FromName"] == null)
            {
                WriteErrorMsg("ERROR: Invalid /FromName parameter specified.");
                return;
            }
            //if (oCommandLine["Industry"] == null)
            //{
            //    WriteErrorMsg("ERROR: Invalid /Industry parameter specified.");
            //    return;
            //}
            
            string template = oCommandLine["Template"];
            string subject = oCommandLine["Subject"];
            string fromName = oCommandLine["FromName"];
            string industry = oCommandLine["Industry"];

            string emailListFile = oCommandLine["EmailListFile"];

            int limit = 999999;
            if (oCommandLine["EmailLimit"] != null)
            {
                if (!int.TryParse(oCommandLine["EmailLimit"], out limit))
                {
                    WriteErrorMsg("ERROR: Invalid /EmailLimit parameter specified.");
                    return;
                }
            }


            try
            {
                Emailer emailer = new Emailer();

                if (!string.IsNullOrEmpty(emailListFile))
                    emailer.SendEmail(template, subject, fromName, emailListFile);
                //else 
                //    emailer.SendEmail(template, subject, fromName, industry, limit);
            }
            catch (Exception e)
            {
                Console.WriteLine();
                Console.WriteLine();
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine("An unexpected exception occurred: " + e.Message);
                Console.WriteLine(e.StackTrace);
                Console.WriteLine("Terminating execution.");
                Console.ForegroundColor = ConsoleColor.Gray;
            }

            Console.Write("Press any key to continue . . . ");
            Console.ReadKey(true);
        }

        static protected void DisplayHelp()
        {
            Console.WriteLine(string.Empty);
            Console.WriteLine("BBOS Emailer Utility");
            Console.WriteLine("/Template=     Just the file name.");
            Console.WriteLine("/Subject=      Email subject");
            Console.WriteLine("/FromName=     The from name for the email.  Not email address.");
            Console.WriteLine("/Industry      P or L");
            Console.WriteLine("/EmailLimit=   Defaults to 999999");
            Console.WriteLine(string.Empty);
            Console.WriteLine("/Help          This help message");
        }

        static protected void WriteErrorMsg(string szMsg)
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine(szMsg);
            Console.ForegroundColor = ConsoleColor.Gray;
        }
    }
}
