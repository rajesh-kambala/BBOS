// http://www.codeproject.com/Articles/9258/A-Fast-CSV-Reader

using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using CommandLine.Utility;
using LumenWorks.Framework.IO.Csv;

namespace QCSS_Call_Campaign
{
    public class QCSSImporter
    {
        const string VERSION = "1.6";

        const string FILE_INSERTED = "QCSS_Inserted.txt";
        const string FILE_SKIPPED = "QCSS_Skipped.txt";
        const string FILE_IGNORED = "QCSS_Ignored.txt";
        const string FILE_SPECIE_NOT_FOUND = "QCSS_Specie_Not_Found.txt";

        protected bool _commit = false;

        protected string _szInsertedFileNamePath;
        protected string _szSkippedFileNamePath;
        protected string _szIgnoredFileNamePath;
        protected string _szIgnoredSpecieFileNamePath;

        protected string _szOutputDataFile;
        protected string _szPath;

        protected List<string> _lszBufferInserted = new List<string>();
        protected List<string> _lszBufferSkipped = new List<string>();
        protected List<string> _lszBufferIgnored = new List<string>();
        protected List<string> _lszIgnoredSpecie = new List<string>();

        protected List<string> _lszNumEmployees = new List<string>();
        protected List<string> _lszProductDescription = new List<string>();

        protected List<string> _log = new List<string>();

        protected string _defaultCallDate;
        protected string _defaultSubject;
        protected string _szRuleSet;
        protected const string RULE_SET_SERVICES = "services";
        protected const string RULE_SET_SALES = "sales";
        protected const string RULE_SET_CLASSIC = "classic";
        protected const string RULE_SET_SPECIE = "specie";
        protected const string RULE_SET_SALES_2017 = "sales2017";
        protected const string RULE_SET_PRODUCE = "produce";
        protected const string RULE_SET_PRODUCE_2018 = "produce2018";


        public void Import(string[] args)
        {
            Console.Clear();
            Console.Title = "QCSS Call Campaign Import Utility";
            WriteLine(String.Format("QCSS Call Campaign Import Utility {0}", VERSION));
            WriteLine("Copyright (c) 2016-2018 Blue Book Services, Inc.");
            WriteLine("All Rights Reserved.");
            WriteLine("  OS Version: " + System.Environment.OSVersion.ToString());
            WriteLine(" CLR Version: " + System.Environment.Version.ToString());

            //Write instructions to be placed at the top of each time that needed explanation.
            WriteLine(_lszBufferSkipped, Environment.NewLine + "SKIPPED Records are skipped because of some formatting error or corruption in the source CSV file (often times if double-quotes are contained in any row).");
            WriteLine(_lszBufferIgnored, Environment.NewLine + "IGNORED Records are ignored because of processing rules that exclude that record from being inserted.");

            WriteLine(string.Empty);
            WriteLine(DateTime.Now.ToString("M/dd/yyyy hh:mm tt"));

            _szPath = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Substring(6);

            // Command line parsing
            Arguments oCommandLine = new Arguments(args);

            if ((oCommandLine["help"] != null) ||
                    (oCommandLine["?"] != null))
            {
                DisplayHelp();
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
                DisplayHelp();
                return;
            }

            if (oCommandLine["Commit"].ToUpper() == "Y")
                _commit = true;


            if (string.IsNullOrEmpty(oCommandLine["RuleSet"]))
            {
                WriteLine("/RuleSet= parameter missing.");
                DisplayHelp();
                return;
            }

            _szRuleSet = oCommandLine["RuleSet"].ToLower();
            if ((_szRuleSet != RULE_SET_SALES) &&
                (_szRuleSet != RULE_SET_SERVICES) &&
                (_szRuleSet != RULE_SET_CLASSIC) &&
                (_szRuleSet != RULE_SET_SPECIE) &&
                (_szRuleSet != RULE_SET_SALES_2017) &&
                (_szRuleSet != RULE_SET_PRODUCE) &&
                (_szRuleSet != RULE_SET_PRODUCE_2018))
            {
                WriteLine("/RuleSet= parameter is invalid.");
                DisplayHelp();
                return;
            }

            if (!string.IsNullOrEmpty(oCommandLine["CallDate"]))
            {
                _defaultCallDate = oCommandLine["CallDate"];
                DateTime dtDummy = new DateTime();
                if (!DateTime.TryParse(_defaultCallDate, out dtDummy))
                {
                    WriteLine("/CallDate= parameter is invalid.");
                    DisplayHelp();
                    return;
                }
            }


            _szInsertedFileNamePath = Path.Combine(_szPath, FILE_INSERTED);
            _szSkippedFileNamePath = Path.Combine(_szPath, FILE_SKIPPED);
            _szIgnoredFileNamePath = Path.Combine(_szPath, FILE_IGNORED);
            _szIgnoredSpecieFileNamePath = Path.Combine(_szPath, FILE_SPECIE_NOT_FOUND);



            //_szOutputDataFile = Path.Combine(_szPath, FILE_RESULTS_CSV);

            File.Delete(_szInsertedFileNamePath);
            File.Delete(_szSkippedFileNamePath);
            File.Delete(_szIgnoredFileNamePath);
            File.Delete(_szIgnoredSpecieFileNamePath);
            //File.Delete(_szOutputDataFile);

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
            }
            finally
            {
                string _outputPath = Path.Combine(_szPath, "QCSSImporter.txt");
                using (StreamWriter sw = new StreamWriter(_outputPath))
                {
                    foreach (string line in _log)
                    {
                        sw.WriteLine(line);
                    }
                }


            }
        }

        int dupCount = 0;
        bool existingInteraction = false;

        protected void ExecuteImport(string inputFile)
        {
            DateTime dtStart = DateTime.Now;

            int skipCount = 0; //could not load from csv file, likely due to double-quotes in a field
            int insertCount = 0; //inserted into database
            int ignoredCount = 0; //ignored because of CallResultCode

            List<CallRecord> lstCallRecords = new List<CallRecord>();

            skipCount = LoadFile(inputFile, lstCallRecords);

            SqlTransaction sqlTrans = null;
            using (SqlConnection sqlConn = new SqlConnection(ConfigurationManager.ConnectionStrings["SQLServer"].ConnectionString))
            {
                sqlConn.Open();

                try
                {
                    sqlTrans = sqlConn.BeginTransaction();

                    int intRecordNum = 0;
                    foreach (CallRecord oCallRecord in lstCallRecords)
                    {
                        intRecordNum++;

                        existingInteraction = false;

                        if (addInteraction(sqlTrans, oCallRecord))
                        {
                            insertCount++;
                            WriteLine(_lszBufferInserted, String.Format(" - Processing Record {0} of {1} - {2} {3}", intRecordNum, lstCallRecords.Count, oCallRecord.BBID, oCallRecord.CompanyName));
                        }
                        else
                        {
                            ignoredCount++;
                            if (existingInteraction)
                            {
                                WriteLine(_lszBufferIgnored, String.Format(" - Ignoring Record {0} of {1} - {2} {3}: QCSS interaction already exists for the specified date.", intRecordNum, lstCallRecords.Count, oCallRecord.BBID, oCallRecord.CompanyName));
                            }
                            else
                            {
                                WriteLine(_lszBufferIgnored, String.Format(" - Ignoring Record {0} of {1} - {2} {3}", intRecordNum, lstCallRecords.Count, oCallRecord.BBID, oCallRecord.CompanyName));
                            }


                        }

                        //if (intRecordNum > 500)
                        //{
                        //    break;
                        //}
                    }

                    if (_szRuleSet == RULE_SET_SALES_2017) 
                    {

                        GenerateProductListFile(sqlTrans, lstCallRecords);
                        GenerateEmployeeExceptionFile();
                    }

                    DeleteEmptyCRMTransactions(sqlTrans);

                    if (_commit)
                    {
                        WriteLine(string.Empty);
                        WriteLine("Commiting Changes.");
                        WriteLine(string.Empty);

                        sqlTrans.Commit();
                    }
                    else
                    {
                        WriteLine(string.Empty);
                        WriteLine("Rolling Back Changes.");
                        WriteLine(string.Empty);
                        sqlTrans.Rollback();
                    }
                }
                catch (Exception ex)
                {
                    sqlTrans.Rollback();
                    throw;
                }

                WriteSummaryData(dtStart, skipCount, insertCount, ignoredCount);

                //Inserted records
                using (StreamWriter sw = new StreamWriter(_szInsertedFileNamePath))
                {
                    foreach (string line in _lszBufferInserted)
                        sw.WriteLine(line);
                }

                //Ignored records
                using (StreamWriter sw = new StreamWriter(_szIgnoredFileNamePath))
                {
                    foreach (string line in _lszBufferIgnored)
                        sw.WriteLine(line);
                }

                //Skipped records
                using (StreamWriter sw = new StreamWriter(_szSkippedFileNamePath))
                {
                    foreach (string skippedLine in _lszBufferSkipped)
                        sw.WriteLine(skippedLine);
                }

                if (_lszIgnoredSpecie.Count > 0)
                {
                    using (StreamWriter sw = new StreamWriter(_szIgnoredSpecieFileNamePath))
                    {
                        foreach (string skippedLine in _lszIgnoredSpecie)
                            sw.WriteLine(skippedLine);
                    }
                }
            }
        }

        /// <summary>
        /// Write summary at bottom of all 3 buffers and console
        /// </summary>
        /// <param name="dtStart"></param>
        /// <param name="skipCount"></param>
        /// <param name="insertCount"></param>
        /// <param name="ignoredCount"></param>
        private void WriteSummaryData(DateTime dtStart, int skipCount, int insertCount, int ignoredCount)
        {
            WriteLine(string.Empty);
            WriteLine(String.Format("     Skipped Count: {0}  (see {1})", skipCount.ToString("###,##0"), FILE_SKIPPED));
            WriteLine(String.Format("      Insert Count: {0}  (see {1})", insertCount.ToString("###,##0"), FILE_INSERTED));
            WriteLine(String.Format("     Ignored Count: {0}  (see {1})", ignoredCount.ToString("###,##0"), FILE_IGNORED));
            WriteLine("Total Record Count: " + (skipCount + insertCount + ignoredCount).ToString("###,##0"));
            WriteLine(string.Empty);
            WriteLine("Execution Time: " + DateTime.Now.Subtract(dtStart).ToString());
        }

        protected const string INSERT_Interaction = @"EXEC dbo.usp_CreateInteractions @CompanyID, @Note, @Date, @Action, @Category, null, @Status, @Priority, @Type, @Subject, 1, 1";

        protected const string SQL_DUP_CHECK =
            @"SELECT 'x' FROM vCommunication WHERE CAST(comm_DateTime as Date) = CAST(@Date as DATE) AND cmli_Comm_CompanyID=@CompanyID AND Comm_Subject LIKE '%QCSS%'";

        /// <summary>
        /// Returns true if record was inserted into database, or false if ignored due to CallResultCode
        /// </summary>
        /// <param name="sqlTrans"></param>
        /// <param name="oCallRecord"></param>
        /// <returns></returns>
        protected bool addInteraction(SqlTransaction sqlTrans, CallRecord oCallRecord)
        {
            SqlCommand cmdInsertInteraction = new SqlCommand();
            cmdInsertInteraction.Connection = sqlTrans.Connection;
            cmdInsertInteraction.Transaction = sqlTrans;
            cmdInsertInteraction.CommandText = INSERT_Interaction;

            cmdInsertInteraction.Parameters.Clear();

            cmdInsertInteraction.Parameters.AddWithValue("CompanyID", oCallRecord.BBID);
            cmdInsertInteraction.Parameters.AddWithValue("Status", "Complete");
            cmdInsertInteraction.Parameters.AddWithValue("Priority", "Normal");
            cmdInsertInteraction.Parameters.AddWithValue("Type", "Note");


            string category = "SM";  //Sales & Marketing
            string action = "PhoneOut";
            string note = null;
            string subject = null;


            if (_szRuleSet == RULE_SET_SPECIE)
            {
                subject = "QCSS Data Collection Campaign";
                note = "A QCSS rep called company to obtain data on species, number of employees, updated web site and/or address.";
                category = "C";  // Content


                if (!string.IsNullOrEmpty(oCallRecord.Comments1))
                {
                    note += "Any additional QCSS notes include: " + oCallRecord.Comments1;

                    note += Environment.NewLine;
                    note += "Spoke with: " + oCallRecord.FirstName + " " + oCallRecord.LastName + " " + oCallRecord.Title;

                    string work = string.Empty;
                    foreach (string specie in oCallRecord.Species)
                    {
                        if (work.Length > 0)
                        {
                            work += ", ";
                        }
                        work += specie;
                    }
                    if (work.Length > 0)
                    {
                        work += ", ";
                    }
                    work += oCallRecord.Website;
                    if (work.Length > 0)
                    {
                        work += ", ";
                    }
                    work += oCallRecord.NumberEmployees;


                    note += Environment.NewLine;
                    note += "Added: " + work;
                }


            }

            if (_szRuleSet == RULE_SET_CLASSIC)
            {
                if (oCallRecord.CallResultCode == "")
                    return false;

                subject = "QCSS Call Campaign";
                action = "PhoneOut";

                switch (oCallRecord.CallResultCode.ToLower())
                {
                    case "no response":
                        return false;
                    case "budget_constraint":
                        note = GenerateNote("A QCSS rep called company to ask if they would be interested in a free online demo of BBOS.  They were not interested due to lack of budget.  Any additional QCSS notes include: ", oCallRecord);
                        break;
                    case "fax":
                        return false;
                    case "lead":
                        note = GenerateNote("A QCSS rep called company to ask if they would be interested in a free online demo of BBOS.  Some interest expressed.  Any additional QCSS notes include: ", oCallRecord);
                        break;
                    case "not interested":
                        note = GenerateNote("A QCSS rep called company to ask if they would be interested in a free online demo of BBOS.  They indicated no interest.  Any additional QCSS notes include: ", oCallRecord);
                        break;
                    case "not_qualified":
                        note = GenerateNote("A QCSS rep called company to ask if they would be interested in a free online demo of BBOS.  QCSS rep was unable to qualify.  Any additional QCSS notes include: ", oCallRecord);
                        break;
                    case "phone appointment":
                    case "rescheduled_appointment":
                        note = GenerateNote("A QCSS rep called company to ask if they would be interested in a free online demo of BBOS.  An appointment was scheduled.  Any additional QCSS notes include: ", oCallRecord);
                        break;
                    case "system callback":
                        note = GenerateNote("A QCSS rep called company to ask if they would be interested in a free online demo of BBOS and was asked to call back later.  Any additional QCSS notes include: ", oCallRecord);
                        break;
                    case "uses_another_vendor":
                        note = GenerateNote("A QCSS rep called company to ask if they would be interested in a free online demo of BBOS.  Prospect indicated they use another information resource.  Any additional QCSS notes include: ", oCallRecord);
                        break;
                    case "wn_disc_uwn":
                        return false;
                    default:
                        return false;
                }

                if (!string.IsNullOrEmpty(oCallRecord.NumberEmployees))
                {
                    note += "  Confirmed # of Employees = " + oCallRecord.NumberEmployees;
                }
            }

            if (_szRuleSet == RULE_SET_SERVICES)
            {
                subject = "QCSS Call Campaign";

                switch (oCallRecord.CallResultCode.ToLower())
                {
                    case "":
                    case "no response":
                    case "fax":
                    case "wn_disc_uwn":
                        oCallRecord.DateTimeOfCall = "12/31/2016";
                        action = "Internal Note";
                        note = "This company was part of the QCSS Call Campaign list in 2016 but was not contacted. ";
                        break;
                    case "budget_constraint":
                        note = GenerateNote("A QCSS rep called company to ask if they would be interested in a free online demo of BBOS.  They were not interested due to lack of budget.  Any additional QCSS notes include: ", oCallRecord);
                        break;
                    case "lead":
                        note = GenerateNote("A QCSS rep called company to ask if they would be interested in a free online demo of BBOS.  Some interest expressed.  Any additional QCSS notes include: ", oCallRecord);
                        break;
                    case "not interested":
                        note = GenerateNote("A QCSS rep called company to ask if they would be interested in a free online demo of BBOS.  They indicated no interest.  Any additional QCSS notes include: ", oCallRecord);
                        break;
                    case "not_qualified":
                        note = GenerateNote("A QCSS rep called company to ask if they would be interested in a free online demo of BBOS.  QCSS rep was unable to qualify.  Any additional QCSS notes include: ", oCallRecord);
                        break;
                    case "phone appointment":
                    case "rescheduled_appointment":
                        note = GenerateNote("A QCSS rep called company to ask if they would be interested in a free online demo of BBOS.  An appointment was scheduled.  Any additional QCSS notes include: ", oCallRecord);
                        break;
                    case "system callback":
                        note = GenerateNote("A QCSS rep called company to ask if they would be interested in a free online demo of BBOS and was asked to call back later.  Any additional QCSS notes include: ", oCallRecord);
                        break;
                    case "uses_another_vendor":
                        note = GenerateNote("A QCSS rep called company to ask if they would be interested in a free online demo of BBOS.  Prospect indicated they use another information resource.  Any additional QCSS notes include: ", oCallRecord);
                        break;
                    default:
                        return false;
                }
            }

            if (_szRuleSet == RULE_SET_SALES)
            {
                subject = "QCSS Direct Sales Call Campaign";

                switch (oCallRecord.CallResultCode.ToLower())
                {
                    case "":
                    case "no response":
                    case "system callback":
                        note = GenerateNote("A QCSS rep called company as part of a direct sales campaign.  QCSS notes include: ", oCallRecord);
                        break;
                    case "wn_disc_uwn":
                        note = GenerateNote("Phone disconnected or issues.  Any additional QCSS notes include:  ", oCallRecord);
                        break;
                    case "lead":
                        note = GenerateNote("A QCSS rep called company as part of a direct sales campaign.  Any additional QCSS notes include:  ", oCallRecord);
                        break;
                    case "not interested":
                        note = GenerateNote("A QCSS rep called company as part of a direct sales campaign.  They indicated no interest.  Any additional QCSS notes include: ", oCallRecord);
                        break;
                    case "not_qualified":
                        note = GenerateNote("A QCSS rep called company as part of a direct sales campaign. QCSS rep was unable to qualify.  Any additional QCSS notes include:  ", oCallRecord);
                        break;
                    case "presentation scheduled":
                        note = GenerateNote("A QCSS rep called company as part of a direct sales campaign.  An appointment for a presentation was scheduled.  Any additional QCSS notes include: ", oCallRecord);
                        break;
                    default:
                        return false;
                }
            }

            if (_szRuleSet == RULE_SET_SALES_2017) 
            {
                subject = "QCSS 2017 Direct Sales Call Campaign";

                switch (oCallRecord.CallResultCode.ToLower())
                {
                    case "":
                    case "no response":
                    case "system callback":
                    case "no answer":
                    case "alternate called":
                        note = GenerateNote("A QCSS rep called company as part of a direct sales campaign.  QCSS notes include: ", oCallRecord);
                        break;
                    case "wn_disc_uwn":
                        note = GenerateNote("Phone disconnected or issues.  Any additional QCSS notes include:  ", oCallRecord);
                        break;
                    case "not interested":
                    case "budget_constraint":
                    case "cancelled_appointment":
                    case "uses_another_vendor":
                        note = GenerateNote("A QCSS rep called company as part of a direct sales campaign.  They indicated no interest.  Any additional QCSS notes include: ", oCallRecord);
                        break;
                    case "not_qualified":
                        note = GenerateNote("A QCSS rep called company as part of a direct sales campaign. QCSS rep was unable to qualify.  Any additional QCSS notes include:  ", oCallRecord);
                        break;
                    case "phone appointment":
                    case "rescheduled_appointment":
                        note = GenerateNote("A QCSS rep called company as part of a direct sales campaign.  An appointment for a presentation was scheduled.  Any additional QCSS notes include:  ", oCallRecord);
                        break;
                    default:
                        return false;
                }
            }

            if ((_szRuleSet == RULE_SET_PRODUCE) ||
                (_szRuleSet == RULE_SET_PRODUCE_2018))
            {
                subject = "QCSS 2017 Direct Sales Call Campaign";
                if (_szRuleSet == RULE_SET_PRODUCE_2018)
                {
                    subject = "QCSS 2018 Direct Sales Call Campaign";
                }

                    switch (oCallRecord.CallResultCode.ToLower())
                {
                    case "":
                    case "lead":
                    case "no response":
                    case "system callback":
                    case "no answer":
                    case "alternate called":
                        note = GenerateNote("A QCSS rep called company as part of a direct sales campaign.  QCSS notes include: ", oCallRecord);
                        break;
                    case "wn_disc_uwn":
                        note = GenerateNote("Phone disconnected or issues.  Any additional QCSS notes include:  ", oCallRecord);
                        break;
                    case "not interested":
                    case "budget_constraint":
                    case "cancelled_appointment":
                    case "uses_another_vendor":
                    case "refusal-budget_constraints":
                        note = GenerateNote("A QCSS rep called company as part of a direct sales campaign.  They indicated no interest.  Any additional QCSS notes include: ", oCallRecord);
                        break;
                    case "not qualified-no produce business":
                    case "not_qualified":
                        note = GenerateNote("A QCSS rep called company as part of a direct sales campaign. QCSS rep was unable to qualify.  Any additional QCSS notes include:  ", oCallRecord);
                        break;
                    case "appointment":
                        note = GenerateNote("A QCSS rep called company as part of a direct sales campaign.  An appointment for a presentation was scheduled.  Any additional QCSS notes include:  ", oCallRecord);
                        note += " Demonstration Interest: " + oCallRecord.DemonstratoinInterest;
                        note += " Relationship Improvements: " + oCallRecord.RelationshipImprovements;
                        break;
                    default:
                        return false;
                }
            }

            cmdInsertInteraction.Parameters.AddWithValue("Category", category);
            cmdInsertInteraction.Parameters.AddWithValue("Subject", subject);
            cmdInsertInteraction.Parameters.AddWithValue("Date", oCallRecord.DateTimeOfCall);
            cmdInsertInteraction.Parameters.AddWithValue("Action", action);
            cmdInsertInteraction.Parameters.AddWithValue("Note", note);

            if (_szRuleSet == RULE_SET_SERVICES)
            {
                SqlCommand cmdDupCheck = new SqlCommand();
                cmdDupCheck.Connection = sqlTrans.Connection;
                cmdDupCheck.Transaction = sqlTrans;
                cmdDupCheck.CommandText = SQL_DUP_CHECK;
                cmdDupCheck.Parameters.AddWithValue("CompanyID", oCallRecord.BBID);
                cmdDupCheck.Parameters.AddWithValue("Date", oCallRecord.DateTimeOfCall);

                object result = cmdDupCheck.ExecuteScalar();
                if ((result != DBNull.Value) &&
                    (result != null))
                {

                    existingInteraction = true;
                    return false;
                }
            }
            cmdInsertInteraction.ExecuteNonQuery();


            int iPIKSCompanyTransID = 0;
            if ((_szRuleSet == RULE_SET_CLASSIC) ||
                (_szRuleSet == RULE_SET_SPECIE))
            {
                string addlExplanation = string.Empty;
                if (_szRuleSet == RULE_SET_SPECIE)
                {
                    addlExplanation = "  See interaction for this date for further information.";
                }

                iPIKSCompanyTransID = OpenPIKSTransaction(Convert.ToInt32(oCallRecord.BBID),
                                                          oCallRecord.DateTimeOfCall,
                                                          addlExplanation,
                                                          sqlTrans);
            }


            if ((_szRuleSet == RULE_SET_CLASSIC) ||
                (_szRuleSet == RULE_SET_SPECIE))
            {
                UpdateProfile(sqlTrans, Convert.ToInt32(oCallRecord.BBID), oCallRecord.NumberEmployees, oCallRecord.DateTimeOfCall);
            }

            if (_szRuleSet == RULE_SET_SPECIE)
            {
                foreach (string specie in oCallRecord.Species)
                {
                    AddSpecie(sqlTrans, Convert.ToInt32(oCallRecord.BBID), specie);
                }

                UpdateWebSite(sqlTrans, Convert.ToInt32(oCallRecord.BBID), oCallRecord.Website);
            }



            if ((_szRuleSet == RULE_SET_CLASSIC) ||
                (_szRuleSet == RULE_SET_SPECIE))
            {
                ClosePIKSTransaction(iPIKSCompanyTransID, sqlTrans);
            }

            if (_szRuleSet == RULE_SET_SALES_2017) 
            {
                HasNumEmployees(sqlTrans, oCallRecord);

                if ((!string.IsNullOrEmpty(oCallRecord.NumberEmployees)) &&
                    (!oCallRecord.HasEmployeesInCRM))
                {
                    _lszNumEmployees.Add(string.Format("{0},{1}", oCallRecord.BBID, oCallRecord.NumberEmployees));
                }

                if (!string.IsNullOrEmpty(oCallRecord.ProductDescription))
                {
                    _lszProductDescription.Add(oCallRecord.BBID.ToString());
                }
            }
            return true;
        }

        private string GenerateNote(string strPrefix, CallRecord oCallRecord)
        {
            return String.Format("{0} {1} {2} {3}", strPrefix, oCallRecord.ProductDescription, oCallRecord.BiggestChallenge, oCallRecord.Comments1);
        }

        private int LoadFile(string fileName, List<CallRecord> lstCallRecords)
        {
            StringBuilder sbSkipped = new StringBuilder();
            int skipCount = 0;

            using (CsvReader csv = new CsvReader(new StreamReader(fileName), true))
            {
                int fieldCount = csv.FieldCount;
                int rowIndex = 1;
                csv.MissingFieldAction = MissingFieldAction.ReplaceByNull;

                string colName = null;
                while (csv.ReadNextRecord())
                {
                    if (string.IsNullOrEmpty(csv["BBID"]))
                    {
                        continue;
                    }


                    CallRecord oCallRecord = new CallRecord();
                    rowIndex++;

                    try
                    {

                        if (string.IsNullOrEmpty(oCallRecord.DateTimeOfCall))
                        {
                            //oCallRecord.DateTimeOfCall = "8/1/2016";
                            oCallRecord.DateTimeOfCall = _defaultCallDate;
                        }

                        oCallRecord.BBID = csv["BBID"];

                        if (_szRuleSet == RULE_SET_SPECIE)
                        {
                            oCallRecord.DateTimeOfCall = csv["saledate"];
                            oCallRecord.EmailAddress = csv["email"];
                            oCallRecord.Website = csv["Updated_Website"];
                            oCallRecord.Comments1 = csv["EXPLANATION"];
                            oCallRecord.FirstName = csv["Survey_First_Name"];
                            oCallRecord.LastName = csv["Survey_Last_Name"];
                            oCallRecord.Title = csv["Survey_Job_Title"];
                            oCallRecord.NumberEmployees = csv["Number_of_Employees"];

                            oCallRecord.Species = new List<string>();
                            for (int i = 1; i <= 5; i++)
                            {
                                colName = "Wood_Capture" + i.ToString();
                                if (!string.IsNullOrEmpty(csv[colName]))
                                {
                                    oCallRecord.Species.Add(csv[colName]);
                                }
                            }
                        }
                        else if ((_szRuleSet == RULE_SET_PRODUCE) ||
                                 (_szRuleSet == RULE_SET_PRODUCE_2018))
                        {
                            oCallRecord.DateTimeOfCall = csv["DateTimeOfCall"];
                            oCallRecord.CallResultCode = csv["CallResultCode"];
                            oCallRecord.CompanyName = csv["CompanyName"];
                            oCallRecord.DemonstratoinInterest = csv["Demonstration_Interest"];
                            oCallRecord.RelationshipImprovements = csv["Relationship_Improvements"];
                            oCallRecord.Comments1 = csv["Comments1"];
                        }
                        else
                        {
                            oCallRecord.DateTimeOfCall = csv["DateTimeOfCall"];
                            oCallRecord.CallResultCode = csv["CallResultCode"];
                            oCallRecord.ContactNumber = csv["ContactNumber"];
                            oCallRecord.FirstName = csv["FirstName"];
                            oCallRecord.LastName = csv["LastName"];
                            oCallRecord.Title = csv["Title"];
                            oCallRecord.CompanyName = csv["CompanyName"];
                            oCallRecord.Address1 = csv["Address1"];
                            oCallRecord.City = csv["City"];
                            oCallRecord.State = csv["State"];
                            oCallRecord.Zip = csv["Zip"];
                            oCallRecord.Comments1 = csv["Comments1"];
                        }

                        if (_szRuleSet == RULE_SET_SERVICES)
                        {
                            oCallRecord.ProductDescription = csv["Product_Description"];
                            oCallRecord.BiggestChallenge = csv["Biggest_Challenge"];
                            oCallRecord.EmailAddress = csv["EmailAddress"];
                        }

                        if (_szRuleSet == RULE_SET_SALES)
                        {
                            oCallRecord.EmailAddress = csv["Email_Address"];
                        }

                        if ((_szRuleSet == RULE_SET_CLASSIC) ||
                            (_szRuleSet == RULE_SET_SALES_2017))
                        {
                            oCallRecord.EmailAddress = csv["EmailAddress"];
                            oCallRecord.ProductDescription = csv["Product_Description"];
                            oCallRecord.BiggestChallenge = csv["Biggest_Challenge"];
                            oCallRecord.NumberEmployees = csv["Number_of_Employees"];
                        }


                        lstCallRecords.Add(oCallRecord);
                    }
                    catch (Exception ex)
                    {
                        skipCount++;
                        string strErrorMsg = ex.Message.Substring(0, ex.Message.IndexOf('.'));
                        _lszBufferSkipped.Add(String.Format("Skipping Record {0} - {1} - Source file may contain double-quotes", rowIndex.ToString(), strErrorMsg));
                    }
                }

                return skipCount;
            }
        }



        protected const int UPDATED_BY = -55;
        protected DateTime UPDATED_DATE = DateTime.Now;
        private const string SQL_COMPANYPROFILE_SELECT = "SELECT prcp_CompanyProfileID FROM PRCompanyProfile WHERE prcp_CompanyID=@CompanyID";
        private const string SQL_COMPANYPROFILE_UPDATE = "UPDATE PRCompanyProfile SET prcp_FTEmployees=@Employees, prcp_CreatedBy=@UpdatedBy, prcp_CreatedDate=@UpdatedDate, prcp_UpdatedBy=@UpdatedBy, prcp_UpdatedDate=@UpdatedDate, prcp_Timestamp=@UpdatedDate WHERE prcp_CompanyProfileID = @CompanyProfileID";
        private const string SQL_COMPANYPROFILE_INSERT = "INSERT INTO PRCompanyProfile (prcp_CompanyProfileID, prcp_CompanyID, prcp_FTEmployees, prcp_CreatedBy, prcp_CreatedDate, prcp_UpdatedBy, prcp_UpdatedDate, prcp_Timestamp) " +
                                                         "VALUES (@CompanyProfileID, @CompanyID, @Employees, @UpdatedBy, @UpdatedDate, @UpdatedBy, @UpdatedDate, @Timestamp)";

        protected void UpdateProfile(SqlTransaction sqlTrans, int iCompanyID, string szEmployees, string dateTimeOfCall)
        {

            if (string.IsNullOrEmpty(szEmployees))
            {
                return;
            }

            if (szEmployees == "0")
            {
                return;
            }

            string szEmployeeCustomCaption = null;
            int employees = Convert.ToInt32(szEmployees.Replace(",", string.Empty));

            if (employees >= 1000)
            {
                szEmployeeCustomCaption = "9";
            }
            else if (employees >= 1000)
            {
                szEmployeeCustomCaption = "9";
            }
            else if (employees >= 500)
            {
                szEmployeeCustomCaption = "8";
            }
            else if (employees >= 250)
            {
                szEmployeeCustomCaption = "7";
            }
            else if (employees >= 100)
            {
                szEmployeeCustomCaption = "6";
            }
            else if (employees >= 50)
            {
                szEmployeeCustomCaption = "5";
            }
            else if (employees >= 20)
            {
                szEmployeeCustomCaption = "4";
            }
            else if (employees >= 10)
            {
                szEmployeeCustomCaption = "3";
            }
            else if (employees >= 5)
            {
                szEmployeeCustomCaption = "2";
            }
            else if (employees >= 1)
            {
                szEmployeeCustomCaption = "1";
            }




            // First we need to see if we have an existing record.
            SqlCommand cmdProfileSelect = new SqlCommand();
            cmdProfileSelect.CommandText = SQL_COMPANYPROFILE_SELECT;
            cmdProfileSelect.Connection = sqlTrans.Connection;
            cmdProfileSelect.Transaction = sqlTrans;
            cmdProfileSelect.Parameters.AddWithValue("CompanyID", iCompanyID);

            bool bUpdate = false;
            int iCompanyProfileID = 0;

            object result = cmdProfileSelect.ExecuteScalar();
            if ((result != null) &&
                (result != DBNull.Value))
            {

                iCompanyProfileID = Convert.ToInt32(result);
                bUpdate = true;
            }

            SqlCommand cmdProfile = new SqlCommand();
            cmdProfile.Connection = sqlTrans.Connection;
            cmdProfile.Transaction = sqlTrans;

            if (bUpdate)
            {
                cmdProfile.CommandText = SQL_COMPANYPROFILE_UPDATE;
            }
            else
            {

                iCompanyProfileID = GetPIKSID("PRCompanyProfile", sqlTrans);
                cmdProfile.CommandText = SQL_COMPANYPROFILE_INSERT;
            }

            cmdProfile.Parameters.AddWithValue("CompanyProfileID", iCompanyProfileID);
            cmdProfile.Parameters.AddWithValue("CompanyID", iCompanyID);
            cmdProfile.Parameters.AddWithValue("Employees", szEmployeeCustomCaption);
            cmdProfile.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
            cmdProfile.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
            cmdProfile.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            cmdProfile.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            cmdProfile.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
            cmdProfile.ExecuteNonQuery();


        }



        /// <summary>
        /// Write a line of text to the console and the specified output buffer: _lszBufferInserted, _lszBufferSkipped , or _lszBufferIgnored 
        /// </summary>
        /// <param name="msg"></param>
        private void WriteLine(List<string> lstBuffer, string msg)
        {
            Console.WriteLine(msg);
            lstBuffer.Add(msg);
            _log.Add(msg);
        }

        //Write to console and all output buffers: _lszBufferInserted, _lszBufferSkipped , or _lszBufferIgnored 
        private void WriteLine(string msg)
        {
            Console.WriteLine(msg);
            _log.Add(msg);
            _lszBufferInserted.Add(msg);
            _lszBufferSkipped.Add(msg);
            _lszBufferIgnored.Add(msg);
        }

        /// <summary>
        /// Displays the application help message
        /// </summary>
        protected void DisplayHelp()
        {
            Console.WriteLine(string.Empty);
            Console.WriteLine(String.Format("QCSS Call Campaign Import Utility {0}", VERSION));
            Console.WriteLine("/File= - The CSV import file.");
            Console.WriteLine("/RuleSet= - [Sales/Services/Classic/Specie/Produce] Which set of rules to use to process the data and generate the interaction note.");
            Console.WriteLine("/CallDate= - The date to use in the interaction if no call date is found.");

            Console.WriteLine("/Commit= - [Y/N] Determines if the database changes should be committed." + Environment.NewLine + "           Defaults to N.");
            Console.WriteLine(string.Empty);
            Console.WriteLine("/Help - This help message");
        }

        protected int GetPIKSID(string szTableName, SqlTransaction sqlTrans)
        {
            SqlCommand sqlGetID = new SqlCommand();
            sqlGetID.Connection = sqlTrans.Connection;
            sqlGetID.Transaction = sqlTrans;
            sqlGetID.CommandText = "usp_getNextId";
            sqlGetID.CommandType = CommandType.StoredProcedure;

            sqlGetID.Parameters.Add(new SqlParameter("TableName", szTableName));

            SqlParameter oReturnParm = new SqlParameter();
            oReturnParm.ParameterName = "Return";
            oReturnParm.Value = 0;
            oReturnParm.Direction = ParameterDirection.Output;
            sqlGetID.Parameters.Add(oReturnParm);

            sqlGetID.ExecuteNonQuery();

            return Convert.ToInt32(oReturnParm.Value);
        }

        protected int OpenPIKSTransaction(int iCompanyID,
                                          string dateTimeOfCall,
                                          string addlExplanation,
                                          SqlTransaction oTran)
        {
            SqlCommand sqlOpenPIKSTransaction = new SqlCommand();
            sqlOpenPIKSTransaction.Connection = oTran.Connection;
            sqlOpenPIKSTransaction.Transaction = oTran;
            sqlOpenPIKSTransaction.CommandText = "usp_CreateTransaction";
            sqlOpenPIKSTransaction.CommandType = CommandType.StoredProcedure;
            sqlOpenPIKSTransaction.Parameters.AddWithValue("UserId", UPDATED_BY);

            sqlOpenPIKSTransaction.Parameters.AddWithValue("prtx_CompanyId", iCompanyID);
            sqlOpenPIKSTransaction.Parameters.AddWithValue("prtx_Explanation", "Data changes resulting from QCSS call campaign." + addlExplanation);
            sqlOpenPIKSTransaction.Parameters.AddWithValue("prtx_EffectiveDate", dateTimeOfCall);

            SqlParameter oReturnParm = new SqlParameter();
            oReturnParm.ParameterName = "NextId";
            oReturnParm.Value = 0;
            oReturnParm.Direction = ParameterDirection.ReturnValue;
            sqlOpenPIKSTransaction.Parameters.Add(oReturnParm);

            sqlOpenPIKSTransaction.ExecuteNonQuery();
            return Convert.ToInt32(oReturnParm.Value);
        }

        protected const string SQL_PRTRANSACTION_CLOSE = "UPDATE PRTransaction SET prtx_Status='C', prtx_CloseDate=GETDATE(), prtx_UpdatedBy=-1, prtx_UpdatedDate=GETDATE(), prtx_Timestamp=GETDATE() WHERE prtx_TransactionId=@TransactionID";

        /// <summary>
        /// Updates the specified PRTransaction setting the appropriate
        /// values to close it.
        /// </summary>
        /// <param name="iTransactionID"></param>
        /// <param name="oTran"></param>
        public void ClosePIKSTransaction(int iTransactionID, SqlTransaction oTran)
        {
            if (iTransactionID <= 0)
            {
                return;
            }

            SqlCommand sqlCloseTransaction = new SqlCommand();
            sqlCloseTransaction.Connection = oTran.Connection;
            sqlCloseTransaction.Transaction = oTran;
            sqlCloseTransaction.Parameters.Add(new SqlParameter("TransactionID", iTransactionID));
            sqlCloseTransaction.CommandText = SQL_PRTRANSACTION_CLOSE;

            if (sqlCloseTransaction.ExecuteNonQuery() == 0)
            {
                throw new ApplicationException("Unable to close transaction: " + iTransactionID.ToString());
            }
        }

        private const string SQL_WEBSITE_SELECT = "SELECT emai_EmailId FROM vCompanyEmail WHERE elink_RecordID=@CompanyID AND ELink_Type='W'";
        private const string SQL_WEBSITE_UPDATE = "UPDATE Email SET emai_PRWebAddress=@Website, emai_CreatedBy=@UpdatedBy, emai_CreatedDate=@UpdatedDate, emai_UpdatedBy=@UpdatedBy, emai_UpdatedDate=@UpdatedDate, emai_Timestamp=@UpdatedDate WHERE Emai_EmailId = @EmailID";

        protected void UpdateWebSite(SqlTransaction sqlTrans, int iCompanyID, string website)
        {

            if (string.IsNullOrEmpty(website))
            {
                return;
            }

            // First we need to see if we have an existing record.
            SqlCommand cmdWebsiteSelect = new SqlCommand();
            cmdWebsiteSelect.CommandText = SQL_WEBSITE_SELECT;
            cmdWebsiteSelect.Connection = sqlTrans.Connection;
            cmdWebsiteSelect.Transaction = sqlTrans;
            cmdWebsiteSelect.Parameters.AddWithValue("CompanyID", iCompanyID);

            bool bUpdate = false;
            int iEmailID = 0;

            object result = cmdWebsiteSelect.ExecuteScalar();
            if ((result != null) &&
                (result != DBNull.Value))
            {
                iEmailID = Convert.ToInt32(result);
                bUpdate = true;
            }

            SqlCommand cmdWebsite = new SqlCommand();
            cmdWebsite.Connection = sqlTrans.Connection;
            cmdWebsite.Transaction = sqlTrans;

            if (bUpdate)
            {
                cmdWebsite.CommandText = SQL_WEBSITE_UPDATE;
                cmdWebsite.Parameters.AddWithValue("EmailID", iEmailID);
                cmdWebsite.Parameters.AddWithValue("CompanyID", iCompanyID);
                cmdWebsite.Parameters.AddWithValue("Website", website);
                cmdWebsite.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
                cmdWebsite.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
                cmdWebsite.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
                cmdWebsite.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
                cmdWebsite.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
                cmdWebsite.ExecuteNonQuery();
            }
            else
            {
                cmdWebsite.CommandText = "usp_InsertEmail";
                cmdWebsite.CommandType = CommandType.StoredProcedure;
                cmdWebsite.Parameters.AddWithValue("RecordID", iCompanyID);
                cmdWebsite.Parameters.AddWithValue("EntityID", 5);
                cmdWebsite.Parameters.AddWithValue("EmailAddress", DBNull.Value);
                cmdWebsite.Parameters.AddWithValue("WebAddress", website);
                cmdWebsite.Parameters.AddWithValue("Description", DBNull.Value);
                cmdWebsite.Parameters.AddWithValue("Type", 'W');
                cmdWebsite.Parameters.AddWithValue("Publish", 'Y');
                cmdWebsite.Parameters.AddWithValue("PreferredInternal", 'Y');
                cmdWebsite.Parameters.AddWithValue("PreferredPublish", 'Y');
                cmdWebsite.Parameters.AddWithValue("UserID", UPDATED_BY);
                cmdWebsite.ExecuteNonQuery();
            }
        }

        private const string SQL_SPECIE_EXISTS = "SELECT 'x' FROM vPRCompanySpecie WHERE prcspc_CompanyID=@CompanyID AND prspc_SpecieID=@SpecieID";
        private const string SQL_SPECIE_INSERT = "INSERT INTO PRCompanySpecie (prcspc_CompanySpecieID, prcspc_CompanyID, prcspc_SpecieID, prcspc_CreatedBy, prcspc_CreatedDate, prcspc_UpdatedBy, prcspc_UpdatedDate, prcspc_Timestamp) " +
                                                         "VALUES (@CompanySpecieID, @CompanyID, @SpecieID, @UpdatedBy, @UpdatedDate, @UpdatedBy, @UpdatedDate, @Timestamp)";

        private const string SQL_CACHE_SPECIE = "SELECT prspc_SpecieID, prspc_Name FROM PRSpecie";
        private Dictionary<string, int> specieCache = null;

        protected void AddSpecie(SqlTransaction sqlTrans, int iCompanyID, string specie)
        {

            if (string.IsNullOrEmpty(specie))
            {
                return;
            }

            if (specieCache == null)
            {
                specieCache = new Dictionary<string, int>();

                using (SqlDataReader reader = new SqlCommand(SQL_CACHE_SPECIE, sqlTrans.Connection, sqlTrans).ExecuteReader())
                {
                    while (reader.Read())
                    {
                        specieCache.Add(reader.GetString(1).ToLower(), reader.GetInt32(0));
                    }
                }
            }

            if (!specieCache.ContainsKey(specie.ToLower()))
            {
                _lszIgnoredSpecie.Add(specie);
                WriteLine(iCompanyID.ToString() + ": " + specie + " not found in CRM.");
                return;
            }

            int specieID = specieCache[specie.ToLower()];

            // First we need to see if we have an existing record.
            SqlCommand cmdSpecieSelect = new SqlCommand();
            cmdSpecieSelect.CommandText = SQL_SPECIE_EXISTS;
            cmdSpecieSelect.Connection = sqlTrans.Connection;
            cmdSpecieSelect.Transaction = sqlTrans;
            cmdSpecieSelect.Parameters.AddWithValue("CompanyID", iCompanyID);
            cmdSpecieSelect.Parameters.AddWithValue("SpecieID", specieID);

            object result = cmdSpecieSelect.ExecuteScalar();
            if ((result != null) &&
                (result != DBNull.Value))
            {
                return;
            }


            int iCompanySpecieID = GetPIKSID("PRCompanySpecie", sqlTrans);

            SqlCommand cmdSpecie = new SqlCommand();
            cmdSpecie.Connection = sqlTrans.Connection;
            cmdSpecie.Transaction = sqlTrans;
            cmdSpecie.CommandText = SQL_SPECIE_INSERT;
            cmdSpecie.Parameters.AddWithValue("CompanySpecieID", iCompanySpecieID);
            cmdSpecie.Parameters.AddWithValue("CompanyID", iCompanyID);
            cmdSpecie.Parameters.AddWithValue("SpecieID", specieID);
            cmdSpecie.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
            cmdSpecie.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
            cmdSpecie.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            cmdSpecie.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            cmdSpecie.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
            cmdSpecie.ExecuteNonQuery();
        }

        private const string SQL_DELETE_EMPTY_TRANSACTION =
            @"DELETE FROM PRTRansaction
             WHERE prtx_TransactionID IN (
	            SELECT prtx_TransactionId--, COUNT(prtd_TransactionDetailId)
	              FROM PRTransaction
		               LEFT OUTER JOIN PRTransactionDetail ON prtx_TransactionID = prtd_TransactionId
	             WHERE CAST(prtx_Explanation as varchar(max)) = 'Data changes resulting from QCSS call campaign.'
	            GROUP BY prtx_TransactionId
	            HAVING COUNT(prtd_TransactionDetailId) = 0)";

        protected void DeleteEmptyCRMTransactions(SqlTransaction sqlTrans)
        {
            SqlCommand cmdDelete = new SqlCommand();
            cmdDelete.Connection = sqlTrans.Connection;
            cmdDelete.Transaction = sqlTrans;
            cmdDelete.CommandText = SQL_DELETE_EMPTY_TRANSACTION;
            cmdDelete.ExecuteNonQuery();
        }


        private const string SQL_HAS_NUM_EMPLOYEES =
            @"SELECT 'x' FROM PRCompanyProfile WHERE prcp_CompanyID=@CompanyID AND prcp_FTEmployees IS NOT NULL";
        protected bool HasNumEmployees(SqlTransaction sqlTrans, CallRecord oCallRecord)
        {
            SqlCommand cmdProfileSelect = new SqlCommand();
            cmdProfileSelect.CommandText = SQL_HAS_NUM_EMPLOYEES;
            cmdProfileSelect.Connection = sqlTrans.Connection;
            cmdProfileSelect.Transaction = sqlTrans;
            cmdProfileSelect.Parameters.AddWithValue("CompanyID", oCallRecord.BBID);

            object result = cmdProfileSelect.ExecuteScalar();
            if (result == DBNull.Value || result == null)
            {
                oCallRecord.HasEmployeesInCRM = false;
                return false;
            }

            //WriteLine(" - Has Employees in CRM");
            oCallRecord.HasEmployeesInCRM = true;
            return true;
        }

        private const string SQL_PRODUCT_QUERY =
            @"SELECT comp_CompanyID,
                       comp_name,
	                   CityStateCountryShort,
	                   dbo.ufn_GetClassificationsForList(comp_CompanyID) Classifications,
                       dbo.ufn_GetProductsProvidedForList(comp_CompanyID) Products,
	                   dbo.ufn_GetSpeciesForList(comp_CompanyID) Specie
                 FROM Company
                      INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
                 WHERE comp_CompanyID IN ({0})
                 ORDER BY comp_CompanyID";

        protected void GenerateProductListFile(SqlTransaction sqlTrans, List<CallRecord> lstCallRecords)
        {
            string companyIDs = string.Join(",", _lszProductDescription);
            if (string.IsNullOrEmpty(companyIDs))
            {
                return;
            }

            //WriteLine(companyIDs);

            string sql = string.Format(SQL_PRODUCT_QUERY, companyIDs);
            //WriteLine(sql);

            string _outputPath = Path.Combine(_szPath, "QCSS_Product_Description.csv");
            using (StreamWriter sw = new StreamWriter(_outputPath))
            {
                sw.WriteLine("BBID,\"Company Name\",\"Location\",\"Product_Description\",\"Classifications\",\"Products\",\"Species\"");

                using (SqlDataReader reader = new SqlCommand(sql, sqlTrans.Connection, sqlTrans).ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string productDescription = GetProductDescription(lstCallRecords, reader.GetInt32(0));
                        object[] args = { reader[0], reader[1], reader[2], productDescription, reader[3], reader[4], reader[5] };
                        string line = string.Format("{0},\"{1}\",\"{2}\",\"{3}\",\"{4}\",\"{5}\",\"{6}\"", args);
                        sw.WriteLine(line);
                    }
                }
            }
        }

        private string GetProductDescription(List<CallRecord> lstCallRecords, int bbid)
        {
            foreach (CallRecord callRecord in lstCallRecords)
            {
                if (callRecord.BBID == bbid.ToString())
                {
                    return callRecord.ProductDescription;
                }
            }

            return string.Empty;
        }

        private void GenerateEmployeeExceptionFile()
        {
            string _outputPath = Path.Combine(_szPath, "QCSS_NumEmployee_Exception.csv");
            using (StreamWriter sw = new StreamWriter(_outputPath))
            {
                sw.WriteLine("BBID,\"Number_of_Employees\"");
                foreach (string line in _lszNumEmployees)
                {
                    sw.WriteLine(line);
                }
            }
        }
    }

    public class CallRecord
    {
        public string CallResultCode;
        public string DateTimeOfCall;
        public string BBID;
        public string ContactNumber;
        public string FirstName;
        public string LastName;
        public string Title;
        public string EmailAddress;
        public string CompanyName;
        public string Address1;
        public string City;
        public string State;
        public string Zip;
        public string ProductDescription;
        public string BiggestChallenge;
        public string Comments1;
        public string NumberEmployees;
        public string DemonstratoinInterest;
        public string RelationshipImprovements;

        public string Website;
        public List<string> Species;
        public bool HasEmployeesInCRM;

    }
}