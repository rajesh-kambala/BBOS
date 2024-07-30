using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using CommandLine.Utility;
using LumenWorks.Framework.IO.Csv;


namespace BBSI.CompanyImport
{
    

    public class Importer
    {
        protected bool _commit = false;

        protected string _szOutputFile;
        protected string _szOutputDataFile;
        protected string _szPath;
        protected List<string> _lszOutputBuffer = new List<string>();
        protected List<string> _lszDataBuffer = new List<string>();

        private void WriteLine(string msg)
        {
            Console.WriteLine(msg);
            _lszOutputBuffer.Add(msg);
        }

        private void WriteOuptutBuffer()
        {
            using (StreamWriter sw = new StreamWriter(_szOutputFile))
            {
                foreach (string line in _lszOutputBuffer)
                {
                    sw.WriteLine(line);
                }
            }

            using (StreamWriter sw = new StreamWriter(_szOutputDataFile))
            {
                foreach (string line in _lszDataBuffer)
                {
                    sw.WriteLine(line);
                }
            }
            
        }

        public void Import(string[] args)
        {
            Console.Clear();
            Console.Title = "Company Importer Utility";
            WriteLine("Company Importer Utility 1.2");
            WriteLine("Copyright (c) 2017 Blue Book Services, Inc.");
            WriteLine("All Rights Reserved.");
            WriteLine("  OS Version: " + System.Environment.OSVersion.ToString());
            WriteLine(" CLR Version: " + System.Environment.Version.ToString());
            WriteLine(string.Empty);
            WriteLine(DateTime.Now.ToString("M/dd/yyyy hh:mm tt"));


            _szPath = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Substring(6);


            if (args.Length == 0)
            {
                //DisplayHelp();
                //return;
            }

            // Command line parsing
            Arguments oCommandLine = new Arguments(args);


            if ((oCommandLine["help"] != null) ||
                (oCommandLine["?"] != null))
            {
                //DisplayHelp();
                return;
            }

            string inputFile = null;
            if (oCommandLine["File"] != null)
            {
                inputFile = Path.Combine(_szPath, oCommandLine["File"]);
            }
            else
            {
                WriteLine("/File= parameter missing.");
                //DisplayHelp();
                return;
            }

            if (oCommandLine["Commit"] == "Y")
            {
                _commit = true;
            }


            _szOutputFile = Path.Combine(_szPath, "CompanyImport.txt");
            _szOutputDataFile = Path.Combine(_szPath, "CompanyImportData.csv");

            try
            {
                ExecuteImport(inputFile);
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

                WriteOuptutBuffer();

                using (StreamWriter sw = new StreamWriter(Path.Combine(_szPath, "CompanyImportException.txt")))
                {
                    sw.WriteLine(e.Message + Environment.NewLine);
                    sw.WriteLine(e.StackTrace);
                }
            }
        }

        private int _invalidCount;

        protected void ExecuteImport(string inputFile)
        {
            DateTime dtStart = DateTime.Now;

            SqlTransaction sqlTrans = null;
            using (SqlConnection sqlConn = new SqlConnection(ConfigurationManager.ConnectionStrings["SQLServer"].ConnectionString))
            {
                sqlConn.Open();

                List<Company> companies = new List<Company>();

                LoadFile(sqlConn, inputFile, companies);

                WriteLine(string.Empty);
                WriteLine("Saving Companies");

                int count = 0;
                foreach (Company company in companies)
                {
                    count++;
                    if (company.CityID == 0)
                    {
                        company.SetInvalid("Unable to find city in CRM: " + company.Addresses[0].City + ", " + company.Addresses[0].State + " " + company.Addresses[0].Zip);
                    }


                    if (!company.IsValid)
                    {
                        _invalidCount++;
                    } else
                    {
                        sqlTrans = sqlConn.BeginTransaction();

                        try
                        {
                            WriteLine(string.Format("Saving company {0:###,##0} of {1:###,##0}: Company {2}", count, companies.Count, company.CompanyName));
                            company.SaveCompany(sqlTrans);
                            _lszDataBuffer.Add(string.Format("{0},\"{1}\"", company.CompanyID, company.CompanyName));

                            if (_commit)
                            {
                                sqlTrans.Commit();
                            }
                            else
                            {
                                sqlTrans.Rollback();
                            }
                        }
                        catch
                        {
                            sqlTrans.Rollback();
                            throw;
                        }
                    }
                }



                WriteLine(string.Empty);
                WriteLine("  Record Count: " + companies.Count.ToString("###,##0"));
                WriteLine(" Invalid Count: " + _invalidCount.ToString("###,##0"));
                WriteLine("Execution Time: " + DateTime.Now.Subtract(dtStart).ToString());

                WriteOuptutBuffer();
            }
        }

        private void LoadFile(SqlConnection sqlConn, string fileName, List<Company> companies)
        {
            int count = 0;
            int totalCount = 0;

            WriteLine("Importing " + fileName);

            using (CsvReader csvCount = new CsvReader(new StreamReader(fileName), true))
            {
                while (csvCount.ReadNextRecord())
                {
                    totalCount++;
                }
            }


            using (CsvReader csv = new CsvReader(new StreamReader(fileName), true))
            {
                int fieldCount = csv.FieldCount;
                csv.MissingFieldAction = MissingFieldAction.ReplaceByNull;
                //csv.UseColumnDefaults = true;

                while (csv.ReadNextRecord())
                {
                    count++;

                    WriteLine(string.Format("Loading record {0:###,##0} of {1:###,##0}: Company {2}", count, totalCount, csv["Company Name"]));


                    // Load the data into something usable
                    Company company = new Company();
                    company.Load(sqlConn, csv);
                    companies.Add(company);

                }
            }

        }
    }
}
