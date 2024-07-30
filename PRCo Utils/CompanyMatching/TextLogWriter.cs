using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Configuration;

namespace CompanyMatching
{
    public static class TextLogWriter
    {
        public static string _fileDetails;
        public static string _file;

        public static void InitializeLog(DateTime startTime)
        {           
            _fileDetails = String.Format("{0:s}", startTime).Replace("-", "").Replace(":", "").Replace("T", "_");
            _file = ConfigurationManager.AppSettings["TextLogFile"].ToString() + "_" + _fileDetails + ".txt";

            StreamWriter writer;
            writer = File.CreateText(_file);
            writer.WriteLine("Company Matching Utility 1.0");
            writer.WriteLine("Copyright (c) 2010 Produce Reporter Co.");
            writer.WriteLine("All Rights Reserved.");
            writer.WriteLine("OS Version: " + System.Environment.OSVersion.ToString());
            writer.WriteLine("CLR Version: " + System.Environment.Version.ToString());

            writer.WriteLine();
            writer.WriteLine();
            writer.Close();
        }

        public static void FinalizeLog(DateTime startTime, DateTime endTime)
        {         
            StreamWriter writer;
            writer = File.AppendText(_file);

            writer.WriteLine();
            writer.WriteLine("Execution Start Time: " + startTime.ToString());
            writer.WriteLine("Execution End Time: " + endTime.ToString());
            writer.Write("Total Execution Time: " + endTime.Subtract(startTime).ToString());

            writer.Close();
        }

        public static void WriteSectionData(string header, int totalCompaniesSearched, int companiesMatched, int companiesUmnatched)
        {
            StreamWriter writer;
            writer = File.AppendText(_file);

            writer.WriteLine();
            writer.WriteLine(header);
            writer.WriteLine("--------------------------------------------------------");
            writer.WriteLine("Total Companies Compared: " + totalCompaniesSearched);
            writer.WriteLine("Companies Matched: " + companiesMatched);
            writer.WriteLine("Companies Unmatched: " + companiesUmnatched);
            writer.WriteLine();

            writer.Close();
        }


        public static void WriteException(Exception e)
        {
            try
            {
                StreamWriter writer;
                writer = File.AppendText(_file);

                writer.WriteLine();
                writer.WriteLine();
                writer.WriteLine("-------------------------- Execution Terminated ---------------------------");
                writer.WriteLine();
                writer.WriteLine("An unexpected exception occurred: " + e.Message);
                writer.WriteLine(e.StackTrace);

                writer.Close();
            }
            catch (Exception ex)
            {
                //If there is an exception here it means there is a problem with the txt file being accessed.
                //Therefore just do nothing and have the original exception show on the console.
            }
        }

    }
}
