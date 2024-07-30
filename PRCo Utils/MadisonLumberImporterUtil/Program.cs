using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CommandLine.Utility;
using MadisonLumberImporter;
using TSI.Utils;

namespace MadisonLumberImporterUtil
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.Clear();
            Console.Title = "Madison Lumber Importer Utility";
            Console.WriteLine("Madison Lumber Importer Utility 1.0");
            Console.WriteLine("Copyright (c) 2021 Blue Book Services, Inc.");
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

            if (oCommandLine["FileInput"] == null)
            {
                WriteErrorMsg("ERROR: Invalid /FileInput parameter specified.");
                return;
            }
            if (oCommandLine["OutputPath"] == null)
            {
                WriteErrorMsg("ERROR: Invalid /OutputPath parameter specified.");
                return;
            }
            if (oCommandLine["FileOutput"] == null)
            {
                WriteErrorMsg("ERROR: Invalid /FileOutput parameter specified.");
                return;
            }

            string fileInput = oCommandLine["FileInput"];
            string outputPath = oCommandLine["OutputPath"];

            try
            {
                string szImportFileName = fileInput;;
                Importer oMadisonLumberImporter = new Importer();

                if (oCommandLine["Commit"] != null)
                    oMadisonLumberImporter.Commit = Convert.ToBoolean(oCommandLine["Commit"]);
                else
                    oMadisonLumberImporter.Commit = false;

                oMadisonLumberImporter.DeleteData();
                
                oMadisonLumberImporter.OutputPath = outputPath;
                oMadisonLumberImporter.FileNameTimestamp = DateTime.Now.ToString("yyyyMMdd_hhmmss");
                oMadisonLumberImporter.ExecuteImport(szImportFileName);
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
            Console.WriteLine("Madison Lumber Importer Utility");
            Console.WriteLine("/Commit=     True/false whether to commit changes to database.");
            Console.WriteLine("/FileInput=     The fully qualified path and filename of the import csv file.");
            Console.WriteLine("/OutputPath=     The fully qualified path where to write the output files.");
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
