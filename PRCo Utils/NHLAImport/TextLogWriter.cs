using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Configuration;

namespace NHLAImport
{
    public static class TextLogWriter
    {
        public static string _fileDetails;
        public static string _generalLogfile;
        public static string _citiesFailedLogfile;
        public static string _companiesInsertedLogfile;
        public static string _companiesInsertedLogfile2;

        public static void InitializeGeneralLog(DateTime startTime)
        {
            _fileDetails = String.Format("{0:s}", startTime).Replace("-", "").Replace(":", "").Replace("T", "_");
            _generalLogfile = ConfigurationManager.AppSettings["TextLogFile"].ToString() + "_" + _fileDetails + ".txt";

            StreamWriter writer;
            writer = File.CreateText(_generalLogfile);
            writer.WriteLine("NHLA Importer Utility 1.0");
            writer.WriteLine("Copyright (c) 2010 Produce Reporter Co.");
            writer.WriteLine("All Rights Reserved.");
            writer.WriteLine("OS Version: " + System.Environment.OSVersion.ToString());
            writer.WriteLine("CLR Version: " + System.Environment.Version.ToString());

            writer.WriteLine();
            writer.WriteLine();
            writer.Close();
        }

        public static void InitializeCompaniesInsertedLog(DateTime startTime)
        {
            _fileDetails = String.Format("{0:s}", startTime).Replace("-", "").Replace(":", "").Replace("T", "_");
            _companiesInsertedLogfile = ConfigurationManager.AppSettings["CompaniesInsertedLogFile"].ToString() + "_" + _fileDetails + ".txt";
            _companiesInsertedLogfile2 = ConfigurationManager.AppSettings["CompaniesInsertedLogFile"].ToString() + "2_" + _fileDetails + ".txt";

            StreamWriter writer;
            writer = File.CreateText(_companiesInsertedLogfile);
            writer.WriteLine("NHLA Importer Utility 1.0");
            writer.WriteLine("Copyright (c) 2010 Produce Reporter Co.");
            writer.WriteLine("All Rights Reserved.");
            writer.WriteLine("OS Version: " + System.Environment.OSVersion.ToString());
            writer.WriteLine("CLR Version: " + System.Environment.Version.ToString());

            writer.WriteLine();
            writer.WriteLine();
            writer.WriteLine("The following companies were succesfully inserted:");
            writer.WriteLine("--------------------------------------------------");
            writer.Close();
        }

        public static void FinalizeGeneralLog(DateTime startTime, DateTime endTime)
        {
            StreamWriter writer;
            writer = File.AppendText(_generalLogfile);

            writer.WriteLine();
            writer.WriteLine("Execution Start Time: " + startTime.ToString());
            writer.WriteLine("Execution End Time: " + endTime.ToString());
            writer.Write("Total Execution Time: " + endTime.Subtract(startTime).ToString());

            writer.Close();
        }

        public static void WriteUnresolvedCity(DateTime startTime, Company company)
        {
            _fileDetails = String.Format("{0:s}", startTime).Replace("-", "").Replace(":", "").Replace("T", "_");
            _citiesFailedLogfile = ConfigurationManager.AppSettings["CitiesNotFoundLogFile"].ToString() + "_" + _fileDetails + ".txt";

            StreamWriter writer;

            if (!File.Exists(_citiesFailedLogfile))
            {
                writer = File.CreateText(_citiesFailedLogfile);
                writer.WriteLine("Section\tOKS Sequence\tNHLA Company Name\tNHLA City\tNHLA State");
            }
            else
            {
                writer = File.AppendText(_citiesFailedLogfile);
            }
            writer.WriteLine(company.Section.ToString() + "\t" + company.OksSequenceID.ToString() + "\t" + company.NHLACompany + "\t" + company.NHLACity + "\t" + company.NHLAState);
            //writer.WriteLine(" - Company: " + companyName + " --- City: " + city + " --- State: " + state + " --- NHLA Sequence ID: " + sequenceID.ToString());
            writer.Close();
        }

        public static void WriteInsertedCompanyLog(DateTime startTime, string companyName, int companyID, int sequenceID, int sectionID)
        {
            StreamWriter writer;
            writer = File.AppendText(_companiesInsertedLogfile);
            writer.WriteLine(" - Company: " + companyName + " --- CRM Company ID: " + companyID.ToString() + " --- NHLA Sequence ID: " + sequenceID.ToString());
            writer.Close();


            if (!File.Exists(_companiesInsertedLogfile2))
            {
                writer = File.CreateText(_companiesInsertedLogfile2);
                writer.WriteLine("Section\tOKS Sequence\tCRM Company ID");
            }
            else
            {
                writer = File.AppendText(_companiesInsertedLogfile2);
            }
            writer.WriteLine(sectionID.ToString() + "\t" + sequenceID.ToString() + "\t" + companyID.ToString());
            writer.Close();

        }

        public static void WriteSectionData(string header, int totalCompanies, int companiesImported)
        {
            StreamWriter writer;
            writer = File.AppendText(_generalLogfile);

            writer.WriteLine();
            writer.WriteLine(header);
            writer.WriteLine("--------------------------------------------------------");
            writer.WriteLine("Total Companies: " + totalCompanies);
            writer.WriteLine("Companies Imported: " + companiesImported);
            writer.WriteLine();

            writer.Close();
        }

        public static void WriteDataIssues(List<DataIssue> dataIssues)
        {
            StreamWriter writer;
            writer = File.AppendText(_generalLogfile);
            writer.WriteLine();
            writer.WriteLine();

            writer.WriteLine("Data Issues Found");
            writer.WriteLine("---------------------------------------------------------");

            var sortedIssues = from issue in dataIssues
                               orderby issue.Type
                               select issue;

            foreach (DataIssue dataIssue in sortedIssues)
                writer.WriteLine(dataIssue.Issue);

            writer.Close();
        }

        public static void WriteException(Exception e)
        {
            try
            {
                StreamWriter writer;
                writer = File.AppendText(_generalLogfile);

                writer.WriteLine();
                writer.WriteLine();
                writer.WriteLine("-------------------------- Execution Terminated ---------------------------");
                writer.WriteLine();
                writer.WriteLine("An unexpected exception occurred: " + e.Message);
                writer.WriteLine(e.StackTrace);

                writer.Close();
            }
            catch 
            {
                //If there is an exception here it means there is a problem with the txt file being accessed.
                //Therefore just do nothing and have the original exception show on the console.
            }
        }

    }
}

