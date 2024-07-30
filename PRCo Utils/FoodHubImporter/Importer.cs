// http://www.codeproject.com/Articles/9258/A-Fast-CSV-Reader

using CommandLine.Utility;
using LumenWorks.Framework.IO.Csv;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Text;

namespace FoodHubImporter
{
	public class Importer
	{
		protected bool _commit = false;
		protected bool _processNonFactorCompanies = false;

		public void Import(string[] args)
		{
			Console.Clear();
			Console.Title = "Food Hub Importer Utility";
			WriteLine("Food Hub Importer Utility 1.0");
			WriteLine("Copyright (c) 2015-2016 Blue Book Services, Inc.");
			WriteLine("All Rights Reserved.");
			WriteLine("  OS Version: " + System.Environment.OSVersion.ToString());
			WriteLine(" CLR Version: " + System.Environment.Version.ToString());
			WriteLine(string.Empty);
			WriteLine(DateTime.Now.ToString("M/dd/yyyy hh:mm tt"));

			_szPath = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Substring(6);

			if(args.Length == 0)
			{
				//DisplayHelp();
				//return;
			}

			// Command line parsing
			Arguments oCommandLine = new Arguments(args);


			if((oCommandLine["help"] != null) ||
					(oCommandLine["?"] != null))
			{
				DisplayHelp();
				return;
			}

			string inputFile = null;
			if(oCommandLine["File"] != null)
			{
				inputFile = Path.Combine(_szPath, oCommandLine["File"]);
			}
			else
			{
				WriteLine("/File= parameter missing.");
				DisplayHelp();
				return;
			}

			//string emailSupressionFile = null;
			//if(oCommandLine["EmailSuprresionFile"] != null)
			//{
			//	emailSupressionFile = Path.Combine(_szPath, oCommandLine["EmailSuprresionFile"]);
			//}

			if(oCommandLine["Commit"] == "Y")
			{
				_commit = true;
			}

			if(oCommandLine["ProcessNonFactorCompanies"] == "Y")
			{
				_commit = true;
			}

			_szOutputFile = Path.Combine(_szPath, "FoodHub Import.txt");
			_szOutputDataFile = Path.Combine(_szPath, "FoodHub Results.csv");

			try
			{
				ExecuteImport(inputFile); //, emailSupressionFile);
			}
			catch(Exception e)
			{
				Console.WriteLine();
				Console.WriteLine();
				Console.ForegroundColor = ConsoleColor.Red;
				Console.WriteLine("An unexpected exception occurred: " + e.Message);
				Console.WriteLine(e.StackTrace);
				Console.WriteLine("Terminating execution.");
				Console.ForegroundColor = ConsoleColor.Gray;

				WriteOuptutBuffer();

				using(StreamWriter sw = new StreamWriter(Path.Combine(_szPath, "FoodHub_Exception.txt")))
				{
					sw.WriteLine(e.Message + Environment.NewLine);
					sw.WriteLine(e.StackTrace);
				}

				//if (e is SqlException)
				//{
				//    SqlException sqlE = (SqlException)e;
				//    sqlE.s
				//}
			}
		}

		protected void ExecuteImport(string inputFile)
		{
			DateTime dtStart = DateTime.Now;

            SqlTransaction sqlTrans = null;
			using(SqlConnection sqlConn = new SqlConnection(ConfigurationManager.ConnectionStrings["SQLServer"].ConnectionString))
			{
				sqlConn.Open();

				Dictionary<string, Company> oCompanies = new Dictionary<string, Company>();

				if(!LoadFile(sqlConn, inputFile, oCompanies))
				{
					Console.ForegroundColor = ConsoleColor.Red;
					Console.WriteLine("There were data errors.  Please correct them in the database and then re-run this import.");
					Console.ForegroundColor = ConsoleColor.Gray;
					return;
				}

				int count = 0;
				WriteLine("");

                if (!_commit)
                    WriteLine(string.Format("Not processing database INSERT statements because /commit was not Y"));
                else
                {
                    foreach (Company oCompany in oCompanies.Values)
                    {
                        count++;
                        WriteLine(string.Format("Processing Company {0:###,##0} of {1:###,##0}: FMID {2}", count, oCompanies.Keys.Count, oCompany.FMID));

                        sqlTrans = sqlConn.BeginTransaction();
                        try
                        {
                            oCompany.SaveCompany(sqlTrans);


                            if (_commit)
                            {
                                WriteLine(" - Company Saved - CompanyID: " + oCompany.CompanyID.ToString());
                                sqlTrans.Commit();
                            }
                            else
                            {
                                WriteLine(" - Company Not Saved (/commit param) - CompanyID: " + oCompany.CompanyID.ToString());
                                sqlTrans.Rollback();
                            }
                        }
                        catch
                        {
                            sqlTrans.Rollback();
                            WriteOutputFiles(oCompanies);
                            throw;
                        }
                    }
                }

                WriteOutputFiles(oCompanies);

                WriteLine(string.Empty);
                WriteLine("            Record Count: " + (oCompanies.Count).ToString("###,##0"));
                WriteLine("          Execution Time: " + DateTime.Now.Subtract(dtStart).ToString());

                WriteOuptutBuffer();
            }
		}

		private bool LoadFile(SqlConnection sqlConn, string fileName, Dictionary<string, Company> oCompanies)
		{
			int count = 0;

			int totalCount = 0;
			using(CsvReader csvCount = new CsvReader(new StreamReader(fileName), true))
			{
				while(csvCount.ReadNextRecord())
					totalCount++;
			}

			List<string> lstErrors = new List<string>();

			using(CsvReader csv = new CsvReader(new StreamReader(fileName), true))
			{
				int fieldCount = csv.FieldCount;
				csv.MissingFieldAction = MissingFieldAction.ReplaceByNull;
				csv.UseColumnDefaults = true;

				while(csv.ReadNextRecord())
				{
					count++;
					WriteLine(string.Format("Loading Record {0:###,##0} of {1:###,##0}: FMID {2}", count, totalCount, csv["FMID"]));

					// Load the data into something usable
					Company oCompany = new Company();
					if(oCompany.Load(sqlConn, csv, lstErrors))
						oCompanies.Add(oCompany.GetKey(), oCompany); //Only add the company to the list if there were no errors
				}
			}

			if(lstErrors.Count > 0)
			{
				WriteErrorFile(lstErrors);
				return true;  //rely on the /commit command-line param to determine whether to write or not -- continue processing even if there are errors
			}

			return true;
		}

		private void WriteErrorFile(List<string> lstErrors)
		{
			using(StreamWriter sw = new StreamWriter(Path.Combine(_szPath, "FoodHub_Errors.txt")))
			{
				sw.WriteLine("The following data errors were encountered with the Food Hub import file.");
				foreach(string strError in lstErrors)
				{
					sw.WriteLine(strError);
				}
			}
		}

		private string _szOutputDataFile;
		private void WriteResultsFile()
		{

			StringBuilder line = new StringBuilder();

			using(StreamWriter sw = new StreamWriter(_szOutputDataFile))
			{
				sw.WriteLine("MemberID,CompanyID,Phone");
			}
		}

		protected string _szOutputFile;
		protected string _szPath;
		protected List<string> _lszOutputBuffer = new List<string>();

		private void WriteLine(string msg)
		{
			Console.WriteLine(msg);
			_lszOutputBuffer.Add(msg);
		}


		private void WriteOuptutBuffer()
		{
			using(StreamWriter sw = new StreamWriter(_szOutputFile))
			{
				foreach(string line in _lszOutputBuffer)
				{
					sw.WriteLine(line);
				}
			}
		}

		private void WriteOutputFiles(Dictionary<string, Company> oCompanies)
		{

			using(StreamWriter sw = new StreamWriter(Path.Combine(_szPath, "FoodHub_Data.csv")))
			{
				sw.WriteLine("CompanyID, CompanyName, FMID");
				foreach(string key in oCompanies.Keys)
				{
					Company oCompany = oCompanies[key];
					if(oCompany.CompanyID > 0)
					{
					    sw.WriteLine(string.Format("{0},\"{1}\",{2}", oCompany.CompanyID, oCompany.CompanyName, oCompany.FMID));
					}
				}
			}
		}

		/// <summary>
		/// Displays the application help message
		/// </summary>
		protected void DisplayHelp()
		{
			Console.WriteLine(string.Empty);
			Console.WriteLine("Local Source Importer Utility");
			Console.WriteLine("/File= - The CSV import file.");
			Console.WriteLine("/EmailSuprresionFile= - The CSV Email Suppression file.");
			Console.WriteLine("/ProcessNonFactorCompanies= - [Y/N] Determines if local source companies not found in the input file are listed as Non-Factor.");
			Console.WriteLine("/Commit= - [Y/N] Determines if the database changes should be committed." + Environment.NewLine + "           Defaults to N.");
			Console.WriteLine(string.Empty);
			Console.WriteLine("/Help - This help message");
		}
	}
}
