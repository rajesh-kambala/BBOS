using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading;
using PRCO.BBS;

using CommandLine.Utility;

namespace PRCo.BBOS.LumberPreLaunch
{
    class Communicator
    {
        protected string _szRootPath;
        protected bool _bVerbose = true;
        protected int _iWave = 0;
        protected int _iQueryType;
        protected int _iInputWave;
        protected int _iTop;
        protected string _szCompanyIDs;
        protected string _szSummary;
        protected string _szListingStatusCondition;

        public void GenerateCommunications(string[] args)
        {
            Console.Clear();
            Console.Title = "BBOS Lumber Pre-Launch Communicator Utility";
            Console.WriteLine("BBOS Lumber Pre-Launch Communicator Utility 1.0");
            Console.WriteLine("Copyright (c) 2009 Produce Reporter Co.");
            Console.WriteLine("All Rights Reserved.");
            Console.WriteLine("  OS Version: " + System.Environment.OSVersion.ToString());
            Console.WriteLine(" CLR Version: " + System.Environment.Version.ToString());

            if (args.Length == 0)
            {
                DisplayHelp();
                return;
            }

            Arguments oCommandLine = new Arguments(args);

            if ((oCommandLine["help"] != null) ||
                (oCommandLine["?"] != null))
            {
                DisplayHelp();
                return;
            }

            if (oCommandLine["OutputDir"] != null)
            {
                _szRootPath = oCommandLine["OutputDir"];
            }
            else
            {
                _szRootPath = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Substring(6);
            }


            if (oCommandLine["Config"] != null)
            {
                _szCompanyIDs = ConfigurationManager.AppSettings["CompanyIDList"];
                _iQueryType = 1;

                _szSummary = "Using CompanyIDs found in config file.";

            }
            else if (oCommandLine["CompanyID"] != null)
            {
                int iCompanyID = 0;
                if (!int.TryParse(oCommandLine["CompanyID"], out iCompanyID))
                {
                    WriteErrorMsg("ERROR: Invalid /CompanyID parameter specified.");
                    return;
                }

                _szCompanyIDs = iCompanyID.ToString();
                _iQueryType = 2;

                _szSummary = "Using Specified CompanyID: " + _szCompanyIDs;

            }

            else if (oCommandLine["Top"] != null)
            {
                if (!int.TryParse(oCommandLine["Top"], out _iTop))
                {
                    WriteErrorMsg("ERROR: Invalid /Top parameter specified.");
                    return;
                }

                _iQueryType = 3;
                _szSummary = "Querying for the top:" + _iTop.ToString();
            }

            else if (oCommandLine["Wave"] != null)
            {
                if (!int.TryParse(oCommandLine["Wave"], out _iInputWave))
                {
                    WriteErrorMsg("ERROR: Invalid /Wave parameter specified.");
                    return;
                }

                _iQueryType = 4;
                _szSummary = "Re-execute Wave=" + _iInputWave.ToString();
            }

            else if (oCommandLine["All"] != null)
            {
                _iQueryType = 5;
                _szSummary = "All Remaining Companies";
            }

            _szListingStatusCondition = " AND comp_PRListingStatus IN ('L', 'H', 'LUV') ";
            if (oCommandLine["ListingStatus"] != null)
            {
                _szListingStatusCondition = " AND comp_PRListingStatus = '" + oCommandLine["ListingStatus"] + "'";
            }




            bool bSend = false;
            if (oCommandLine["Send"] != null)
            {
                bSend = true;
            }

            GenerateCommunications(bSend);
        }

        protected const string SQL_SELECT_WAVE_ID =
            "SELECT ISNULL(MAX(CONVERT(int, comm_PRSubcategory)), 0) " +
              "FROM Communication " +
             "WHERE comm_PRCategory = 'Lumber PreLaunch Confirmation' ";

        protected const string SQL_SELECT_WAVE =
            "SELECT cmli_Comm_CompanyID  " +
              "FROM Comm_Link  " +
                   "INNER JOIN Communication ON cmli_Comm_CommunicationID = comm_CommunicationID  " +
             "WHERE comm_PRCategory = 'Lumber PreLaunch Confirmation' ";

        private const string SQL_SELECT_COMPANIES =
            "SELECT {1} comp_CompanyID, comp_PRCorrTradeStyle, dbo.ufn_GetCompanyEmail(comp_CompanyID, 'Y', NULL), dbo.ufn_GetCompanyPhone(comp_CompanyID, 'Y', NULL, 'F', NULL), comp_PRListingStatus " +
              "FROM Company " +
             "WHERE comp_PRListingStatus IN ('L', 'H', 'LUV') AND comp_PRType = 'H' AND comp_PRIndustryType = 'L' " +
             " {0} " +
          "ORDER BY comp_CompanyID;";


        protected ReportInterface _oRI;
        public string GetPublishableInformationReport(int iCompanyID)
        {
            if (_oRI == null)
            {
                _oRI = new ReportInterface();
            }

            WriteVerboseMsg(" - Generating Publishable Information Report");

            byte[] abPIRReport = _oRI.GeneratePublishableInformationReport(iCompanyID);

            string szSaveFileName = Path.Combine(ConfigurationManager.AppSettings["TempReportsFolder"], "BBOS Publishable Information Report.pdf");

            SaveFile(abPIRReport, szSaveFileName);
            return  szSaveFileName;     
        }

        public string GetListingReport(int iCompanyID) {
            if (_oRI == null) {
                _oRI = new ReportInterface();
            }

            WriteVerboseMsg(" - Generating Listing Report");
            
            byte[] abListingReport = _oRI.GenerateCompanyListingReport(iCompanyID.ToString(), true);

            string szSaveFileName = Path.Combine(ConfigurationManager.AppSettings["TempReportsFolder"], "BBOS Listing Report.pdf");

            SaveFile(abListingReport, szSaveFileName);
            return szSaveFileName;
        }

        public string GetLumberPreReleaseFaxReport(int iCompanyID, bool bIncludePIR) {
            if (_oRI == null) {
                _oRI = new ReportInterface();
            }

            WriteVerboseMsg(" - Generating Lumber PreRelease Fax Report");

            byte[] abFaxReport = _oRI.GenerateLumberPreReleaseFaxReport(iCompanyID, true, true, bIncludePIR);

            string szSaveFileName = Path.Combine(ConfigurationManager.AppSettings["TempReportsFolder"], "LumberPreReleaseFax_" + iCompanyID.ToString() + ".pdf");

            SaveFile(abFaxReport, szSaveFileName);
            return szSaveFileName;
        } 

        private void SaveFile(Byte[] abFile, string szFileName) {
            FileStream fs = File.Create(szFileName);
            BinaryWriter binaryWriter = new BinaryWriter(fs);
            binaryWriter.Write(abFile);
            binaryWriter.Close();     
        
        }


        private const string SQL_GET_WEBUSER_EMAIL =
            "SELECT RTRIM(prwu_Email), peli_PersonID " +
              "FROM PRWebUser " +
                   "INNER JOIN Person_Link ON prwu_PersonLinkID = peli_PersonLinkID " +
             "WHERE prwu_BBID = @CompanyID " +
               "AND prwu_CDSWBBID IS NOT NULL " +
               "AND prwu_Email IS NOT NULL;";

        private const string SQL_GET_EMAIL_BY_ROLE =
            "SELECT RTRIM(emai_EmailAddress), peli_PersonID " +
              "FROM Person_Link " +
                   "INNER JOIN Email ON peli_CompanyID = emai_CompanyID AND peli_PersonID = emai_PersonID " +
                   "INNER JOIN Custom_Captions ON peli_PRTitleCode = capt_code AND  capt_family = 'pers_TitleCode' " +
             "WHERE peli_CompanyID=@CompanyID " +
               "AND peli_PRStatus IN (1,2) " +
          "ORDER BY capt_order;";

        protected void GenerateCommunications(bool bSend)
        {
            DateTime dtStart = DateTime.Now;
            int iCompanyCount = 0;
            int iEmailCount = 0;
            int iFaxCount = 0;
            int iSkipCount = 0;

            bool bSkip = false;

            int iEmailPause = Convert.ToInt32(ConfigurationManager.AppSettings["EmailPause"]) * 1000;
            int iEmailPauseEvery = Convert.ToInt32(ConfigurationManager.AppSettings["EmailPauseEvery"]);
            int iEmailPauseCount = 0;


            string szClause = string.Empty;
            string szTopClause = string.Empty;

            switch (_iQueryType)
            {
                case 0:
                    WriteErrorMsg("Invalid query parameter specified.");
                    DisplayHelp();
                    return;
                case 1:
                case 2:
                    szClause = " AND comp_CompanyID IN (" + _szCompanyIDs + ") ";
                    break;
                case 3:
                    szTopClause = " TOP " + _iTop.ToString() + " ";
                    szClause = " AND comp_CompanyID NOT IN (" + SQL_SELECT_WAVE + ") ";
                    break;
                case 4:
                    szClause = " AND comp_CompanyID IN (" + SQL_SELECT_WAVE + " AND comm_PRSubcategory='" + _iInputWave.ToString() + "') ";
                    break;
                case 5:
                    szClause = " AND comp_CompanyID NOT IN (" + SQL_SELECT_WAVE + ") ";
                    break;

            }

            string szSQL = string.Format(SQL_SELECT_COMPANIES, szClause + _szListingStatusCondition, szTopClause);
            Console.WriteLine(szSQL);

            IDbConnection oConn = new SqlConnection(ConfigurationManager.AppSettings["DBConnectionString"]);
            IDbConnection oEmailConn = new SqlConnection(ConfigurationManager.AppSettings["DBConnectionString"]);
            IDbConnection oTaskConn = new SqlConnection(ConfigurationManager.AppSettings["DBConnectionString"]);

            IDataReader oReader = null;
            StreamWriter oLogFile = null;

            try {
                Console.WriteLine();

                string szListedMessage = null;
                using (StreamReader sr = new StreamReader(Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Substring(6) + "/Template.txt")) {
                    szListedMessage = sr.ReadToEnd();
                }

                string szLUVMessage = null;
                using (StreamReader sr = new StreamReader(Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Substring(6) + "/TemplateLUV.txt")) {
                    szLUVMessage = sr.ReadToEnd();
                }

                oConn.Open();
                oEmailConn.Open();
                oTaskConn.Open();

                IDbCommand oWaveCommand = oConn.CreateCommand();
                oWaveCommand.CommandText = SQL_SELECT_WAVE_ID;
                oWaveCommand.CommandTimeout = 300;
                oWaveCommand.CommandType = CommandType.Text;

                _iWave = (int)oWaveCommand.ExecuteScalar();
                _iWave++;

                string szResultsPath = "Wave" + _iWave.ToString("000") + "_" + DateTime.Now.ToString("yyyyMMdd_HHmmss") + @"\";
                _szRootPath = Path.Combine(_szRootPath, szResultsPath);

                if (!Directory.Exists(_szRootPath))
                {
                    Directory.CreateDirectory(_szRootPath);
                }

                string szLogFile = Path.Combine(_szRootPath, "LumberPreLaunch.txt");
                if (File.Exists(szLogFile))
                {
                    File.Delete(szLogFile);
                }

                oLogFile = new StreamWriter(szLogFile);
                oLogFile.WriteLine("Wave;Company ID;Company Name;Person ID;Email;Skipped");



                IDbCommand oSelectCommand = oConn.CreateCommand();
                oSelectCommand.CommandText = szSQL;
                oSelectCommand.CommandTimeout = 300;
                oSelectCommand.CommandType = CommandType.Text;


                SqlCommand oEmailCommand = (SqlCommand)oEmailConn.CreateCommand();
                oEmailCommand.CommandText = SQL_GET_WEBUSER_EMAIL;

                SqlCommand oEmailCommand2 = (SqlCommand)oEmailConn.CreateCommand();
                oEmailCommand2.CommandText = SQL_GET_EMAIL_BY_ROLE;

                oReader = oSelectCommand.ExecuteReader();
                while (oReader.Read())
                {
                    iCompanyCount++;
                    bSkip = false;

                    int iCompanyID = oReader.GetInt32(0);
                    string szCompanyName = oReader["comp_PRCorrTradestyle"].ToString();
                    string szListingStatus = oReader.GetString(4);

                    Console.WriteLine("Processing {0} - {1}", iCompanyID, szCompanyName);



                    string szEmail = null;
                    string szFax = null;
                    int iPersonID = 0;

                    if (oReader[3] != DBNull.Value) {
                        szFax = oReader.GetString(3);
                    }

                    // Now determine who we should send the report to
                    oEmailCommand.Parameters.Clear();
                    oEmailCommand.Parameters.AddWithValue("CompanyID", iCompanyID);
                    using (IDataReader oEmailReader = oEmailCommand.ExecuteReader())
                    {
                        if (oEmailReader.Read())
                        {
                            szEmail = oEmailReader.GetString(0);
                            iPersonID = oEmailReader.GetInt32(1);
                        }
                    }
                    
                    if (string.IsNullOrEmpty(szEmail))
                    {
                        oEmailCommand2.Parameters.Clear();
                        oEmailCommand2.Parameters.AddWithValue("CompanyID", iCompanyID);
                        using (IDataReader oEmailReader2 = oEmailCommand2.ExecuteReader())
                        {
                            if (oEmailReader2.Read())
                            {
                                szEmail = oEmailReader2.GetString(0);
                                iPersonID = oEmailReader2.GetInt32(1);
                            }
                        }
                    }

                    // If we don't find a person email, then
                    // use a company email
                    if (string.IsNullOrEmpty(szEmail)) {
                        if (oReader[2] != DBNull.Value) {
                            szEmail = oReader.GetString(2);
                        }
                    }

                    string szAttachmentName = null;
                    string szAction = null;
                    string szTo = null;

                    if ((string.IsNullOrEmpty(szEmail)) &&
                        (string.IsNullOrEmpty(szFax)))
                    {
                        bSkip = true;
                        iSkipCount++;
                        WriteErrorMsg(" - No Email or Fax Found, Skipping Company...");
                    }

                    string szMessage = null;
                    
                    if (!bSkip) {
                        if (!string.IsNullOrEmpty(szEmail)) {
                            if (iEmailPauseCount >= iEmailPauseEvery)
                            {
                                Console.WriteLine("Pausing...");
                                Thread.Sleep(iEmailPause);
                                iEmailPauseCount = 0;
                            }
                            iEmailPauseCount++;

                            
                            if (szListingStatus == "LUV") {
                                szMessage = szLUVMessage;
                            }
                            else {
                                szMessage = szListedMessage;
                            }

                            GetListingReport(iCompanyID);
                            szAttachmentName = Path.Combine(ConfigurationManager.AppSettings["SQLReportsFolder"], "BBOS Listing Report.pdf");
                            
                            if (szListingStatus == "L") {
                                GetPublishableInformationReport(iCompanyID);
                                szAttachmentName += ";" + Path.Combine(ConfigurationManager.AppSettings["SQLReportsFolder"], "BBOS Publishable Information Report.pdf");
                            }

                            iEmailCount++;
                            szAction = "EmailOut";
                            szTo = szEmail;
                        } else {
                            bool bIncludePIR = false;

                            if (szListingStatus == "L") {
                                bIncludePIR = true;
                            }
                            
                            GetLumberPreReleaseFaxReport(iCompanyID, bIncludePIR);
                            szAttachmentName = Path.Combine(ConfigurationManager.AppSettings["SQLReportsFolder"], "LumberPreReleaseFax_" + iCompanyID.ToString() + ".pdf");

                            iFaxCount++;
                            szAction = "FaxOut";
                            szTo = szFax;
                        }

                        if (bSend) {

                            WriteVerboseMsg(" - Sending to " + szTo);

                            SqlCommand oSendCommand = (SqlCommand)oTaskConn.CreateCommand();
                            oSendCommand.CommandText = "usp_CreateEmail";
                            oSendCommand.CommandTimeout = 300;
                            oSendCommand.CommandType = CommandType.StoredProcedure;
                            oSendCommand.Parameters.AddWithValue("@To", szTo);
                            oSendCommand.Parameters.AddWithValue("@Subject", ConfigurationManager.AppSettings["EmailSubject"]);
                            
                            if (!string.IsNullOrEmpty(szMessage)) {
                                oSendCommand.Parameters.AddWithValue("@Content", szMessage);
                            }
                            
                            oSendCommand.Parameters.AddWithValue("@Content_Format", "TEXT");
                            oSendCommand.Parameters.AddWithValue("@RelatedCompanyId", iCompanyID);
                            
                            if (iPersonID > 0) {
                                oSendCommand.Parameters.AddWithValue("@RelatedPersonId", iPersonID);
                            }
                            
                            oSendCommand.Parameters.AddWithValue("@Action", szAction);
                            oSendCommand.Parameters.AddWithValue("@AttachmentFileName", szAttachmentName);
                            oSendCommand.Parameters.AddWithValue("@PRCategory", "Lumber PreLaunch Confirmation ");
                            oSendCommand.Parameters.AddWithValue("@PRSubcategory", _iWave.ToString());

                            oSendCommand.ExecuteScalar();
                        }
                    }
                    string szSkip = string.Empty;
                    if (bSkip)
                    {
                        szSkip = "Y";
                    }

                    object[] args2 = {_iWave,
                                    iCompanyID,
                                    szCompanyName,
                                    iPersonID,
                                    szTo,
                                    szSkip};

                    oLogFile.WriteLine("{0};{1};{2};{3};{4};{5}", args2);
                }

            }
            catch (Exception e)
            {
                Console.WriteLine();
                WriteErrorMsg("An unexpected exception occurred: " + e.Message);
                Console.WriteLine(e.StackTrace);
                WriteErrorMsg("Terminating execution.");
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }

                if (oConn != null)
                {
                    oConn.Close();
                }

                if (oEmailConn != null)
                {
                    oEmailConn.Close();
                }


                if (oTaskConn != null)
                {
                    oTaskConn.Close();
                }

                if (oLogFile != null)
                {
                    oLogFile.Close();
                }
            }
            using (StreamWriter sw = new StreamWriter(Path.Combine(_szRootPath, "LumberPreLaunchSummary.txt")))
            {
                sw.WriteLine("           DateTime: " + dtStart.ToString());
                sw.WriteLine("              Input: " + _szSummary);
                sw.WriteLine("               Wave: " + _iWave.ToString("000"));
                sw.WriteLine("    Companies Found: " + iCompanyCount.ToString("###,##0"));
                sw.WriteLine("Companies Processed: " + (iCompanyCount - iSkipCount).ToString("###,##0"));
                sw.WriteLine("  Companies Skipped: " + iSkipCount.ToString("###,##0"));
                sw.WriteLine("        Emails Sent: " + iEmailCount.ToString("###,##0"));
                sw.WriteLine("         Faxes Sent: " + iFaxCount.ToString("###,##0"));
                sw.WriteLine("     Execution Time: " + DateTime.Now.Subtract(dtStart).ToString());
            }

            Console.WriteLine("              Input: " + _szSummary);
            Console.WriteLine("               Wave: " + _iWave.ToString("000"));
            Console.WriteLine("    Companies Found: " + iCompanyCount.ToString("###,##0"));
            Console.WriteLine("Companies Processed: " + (iCompanyCount - iSkipCount).ToString("###,##0"));
            Console.WriteLine("  Companies Skipped: " + iSkipCount.ToString("###,##0"));
            Console.WriteLine("        Emails Sent: " + iEmailCount.ToString("###,##0"));
            Console.WriteLine("         Faxes Sent: " + iFaxCount.ToString("###,##0"));
            Console.WriteLine("     Execution Time: " + DateTime.Now.Subtract(dtStart).ToString());
        }


        protected void WriteErrorMsg(string szMsg)
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine(szMsg);
            Console.ForegroundColor = ConsoleColor.Gray;
        }

        protected void WriteVerboseMsg(string szMsg)
        {
            if (_bVerbose)
            {
                Console.WriteLine(szMsg);
            }
        }

        /// <summary>
        /// Displays the application help message
        /// </summary>
        protected void DisplayHelp()
        {
            Console.WriteLine(string.Empty);
            Console.WriteLine("BBOS Lumber Pre-Launch Communicator Utility");
            Console.WriteLine("/Top=            Generate communications for the first N companies found that are not part of any previous wave.");
            Console.WriteLine("/Config          Generate communications for those companies specified in the configuration file, regardless if they are part of a previous wave or not.");
            Console.WriteLine("/CompanyID=      Generate communications for only the specified company, regardless if they are part of a previous wave or not.");
            Console.WriteLine("/All=            Generate communications for all companies that are not part of any previous wave.");
            Console.WriteLine("/Wave=           Regenerates the communications for the specified wave.  ");
            Console.WriteLine("/Send=           Indicates the communications should actually be sent.");
            Console.WriteLine("/ListingStatus=  Generates the communications for those companies having the specified listing status.");
            
            Console.WriteLine(string.Empty);
            Console.WriteLine("/OutputDir=    The fully qualified directory to write any the output to.");
            Console.WriteLine("/Help          This help message");
        }
    }

}
