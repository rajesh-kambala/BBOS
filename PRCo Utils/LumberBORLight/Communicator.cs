using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;


using PRCO.BBS;

using CommandLine.Utility;

namespace PRCo.BBOS.LumberBORLight
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

        protected const string CATEGORY = "Lumber BORLight";

        public void GenerateCommunications(string[] args)
        {
            Console.Clear();
            Console.Title = "BBOS Lumber BORLight Communicator Utility";
            Console.WriteLine("BBOS Lumber BORLight Communicator Utility 1.0");
            Console.WriteLine("Copyright (c) 2009-2010 Blue Book Services, Inc.");
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
                Regex r = new Regex(@"\s+");
                _szCompanyIDs = r.Replace(ConfigurationManager.AppSettings["CompanyIDList"], @" ");
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


            bool bSend = false;
            if (oCommandLine["Send"] != null)
            {
                bSend = true;
            }

            GenerateCommunications(bSend);
        }

        protected const string SQL_SELECT_WAVE_ID =
            "SELECT ISNULL(MAX(CONVERT(int, comm_PRSubcategory)), 0) " +
              "FROM Communication WITH (NOLOCK) " +
             "WHERE comm_PRCategory = '" + CATEGORY + "' ";

        protected const string SQL_SELECT_WAVE =
            "SELECT cmli_Comm_CompanyID  " +
              "FROM Comm_Link WITH (NOLOCK)  " +
                   "INNER JOIN Communication WITH (NOLOCK) ON cmli_Comm_CommunicationID = comm_CommunicationID  " +
             "WHERE comm_PRCategory = '" + CATEGORY + "' ";

        // Select companies w/Fax numbers 
        private const string SQL_SELECT_COMPANIES =
            "SELECT {1} comp_CompanyID, comp_PRCorrTradeStyle, dbo.ufn_GetCompanyPhone(comp_CompanyID, 'Y', NULL, 'F', NULL) " +
              "FROM Company WITH (NOLOCK) " +
                   "INNER JOIN Phone WITH (NOLOCK) on comp_CompanyID = phon_CompanyID AND phon_PersonID IS NULL " +
             "WHERE comp_PRListingStatus IN ('L', 'H', 'LUV') AND comp_PRIndustryType = 'L' " +
               "AND phon_Type IN ('F', 'SF', 'PF') " +
               "AND phon_Default = 'Y' " +
             " {0} " +
          "ORDER BY comp_CompanyID;";


        protected ReportInterface _oRI;
        public string GetBORLightReport(int iCompanyID)
        {
            if (_oRI == null)
            {
                _oRI = new ReportInterface();
            }

            WriteVerboseMsg(" - Generating BORLight Report");

            byte[] abRReport = _oRI.GenerateBORLightReport(iCompanyID);

            string szSaveFileName = Path.Combine(ConfigurationManager.AppSettings["TempReportsFolder"], "LumberBORLightFax_" + iCompanyID.ToString() + ".pdf");
            SaveFile(abRReport, szSaveFileName);
            return  szSaveFileName;     
        }


        private void SaveFile(Byte[] abFile, string szFileName) {
            FileStream fs = File.Create(szFileName);
            BinaryWriter binaryWriter = new BinaryWriter(fs);
            binaryWriter.Write(abFile);
            binaryWriter.Close();     
        
        }

        protected void GenerateCommunications(bool bSend)
        {
            DateTime dtStart = DateTime.Now;
            int iCompanyCount = 0;
            int iFaxCount = 0;
            int iSkipCount = 0;

            bool bSkip = false;

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

            
            string szCompanyTypeList = ConfigurationManager.AppSettings["CompanyTypeList"];
            if (string.IsNullOrEmpty(szCompanyTypeList))
            {
                szCompanyTypeList = "'H'";        
            }

            string szCompanyTypeClause = " AND comp_PRType IN (" + szCompanyTypeList + ")";

            string szSQL = string.Format(SQL_SELECT_COMPANIES, szCompanyTypeClause + szClause, szTopClause);
            Console.WriteLine(szSQL);

            IDbConnection oConn = new SqlConnection(ConfigurationManager.AppSettings["DBConnectionString"]);
            IDbConnection oTaskConn = new SqlConnection(ConfigurationManager.AppSettings["DBConnectionString"]);

            IDataReader oReader = null;
            StreamWriter oLogFile = null;

            try {
                Console.WriteLine();

                oConn.Open();
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

                string szLogFile = Path.Combine(_szRootPath, "LumberBOR.txt");
                if (File.Exists(szLogFile))
                {
                    File.Delete(szLogFile);
                }

                oLogFile = new StreamWriter(szLogFile);
                oLogFile.WriteLine("Wave;Company ID;Company Name;Fax;Skipped");



                IDbCommand oSelectCommand = oConn.CreateCommand();
                oSelectCommand.CommandText = szSQL;
                oSelectCommand.CommandTimeout = 300;
                oSelectCommand.CommandType = CommandType.Text;

                oReader = oSelectCommand.ExecuteReader();
                while (oReader.Read())
                {
                    iCompanyCount++;
                    bSkip = false;

                    int iCompanyID = oReader.GetInt32(0);
                    string szCompanyName = oReader["comp_PRCorrTradestyle"].ToString();
                    string szFax = oReader.GetString(2);

                    Console.WriteLine("Processing {0} - {1}", iCompanyID, szCompanyName);

                    string szAttachmentName = null;
                    string szAction = null;
                    string szTo = null;

                    if (string.IsNullOrEmpty(szFax))
                    {
                        bSkip = true;
                        iSkipCount++;
                        WriteErrorMsg(" - No Fax Found, Skipping Company...");
                    }

                    if (!bSkip)  {
                        GetBORLightReport(iCompanyID);

                        if (bSend) {
                            szAttachmentName = Path.Combine(ConfigurationManager.AppSettings["SQLReportsFolder"], "LumberBORLightFax_" + iCompanyID.ToString() + ".pdf");
                            iFaxCount++;
                            szAction = "FaxOut";
                            szTo = szFax;

                            WriteVerboseMsg(" - Sending to " + szTo);

                            SqlCommand oSendCommand = (SqlCommand)oTaskConn.CreateCommand();
                            oSendCommand.CommandText = "usp_CreateEmail";
                            oSendCommand.CommandTimeout = 300;
                            oSendCommand.CommandType = CommandType.StoredProcedure;
                            oSendCommand.Parameters.AddWithValue("@To", szTo);
                            oSendCommand.Parameters.AddWithValue("@RelatedCompanyId", iCompanyID);
                            oSendCommand.Parameters.AddWithValue("@Action", szAction);
                            oSendCommand.Parameters.AddWithValue("@AttachmentFileName", szAttachmentName);
                            oSendCommand.Parameters.AddWithValue("@PRCategory", CATEGORY);
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
                                    szTo,
                                    szSkip};

                    oLogFile.WriteLine("{0};{1};{2};{3};{4}", args2);
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
                sw.WriteLine("     Execution Time: " + DateTime.Now.Subtract(dtStart).ToString());
            }

            Console.WriteLine("              Input: " + _szSummary);
            Console.WriteLine("               Wave: " + _iWave.ToString("000"));
            Console.WriteLine("    Companies Found: " + iCompanyCount.ToString("###,##0"));
            Console.WriteLine("Companies Processed: " + (iCompanyCount - iSkipCount).ToString("###,##0"));
            Console.WriteLine("  Companies Skipped: " + iSkipCount.ToString("###,##0"));
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
