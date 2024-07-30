using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.IO;

using PRCo.EBB.BusinessObjects;

using CommandLine.Utility;

namespace PRCo.BBOS.Communicator {
    class Communicator {
    
        protected string _szRootPath;
        protected int _iQueryType = 0;

        protected DateTime _dtStart;
        protected DateTime _dtEnd;
        protected int _iExpMonth = 0;
        protected int _iWave = 0;
        protected int _iInputWave = 0;
        protected string _szServiceCodes = null;
        protected string _szCompanyIDs = null;
        protected string _szSummary;
        
        protected bool _bVersbose = false;
    
    
        public void GenerateCommunications(string[] args) {

            Console.Clear();
            Console.Title = "BBOS Communicator Utility";
            Console.WriteLine("BBOS Communicator Utility 1.0");
            Console.WriteLine("Copyright (c) 2007-" + DateTime.Now.Year.ToString() + " Produce Reporter Co.");
            Console.WriteLine("All Rights Reserved.");
            Console.WriteLine("  OS Version: " + System.Environment.OSVersion.ToString());
            Console.WriteLine(" CLR Version: " + System.Environment.Version.ToString());

            if (args.Length == 0) {
                DisplayHelp();
                return;
            }

            // Command line parsing
            Arguments oCommandLine = new Arguments(args);

            if ((oCommandLine["help"] != null) ||
                (oCommandLine["?"] != null)) {
                DisplayHelp();
                return;
            }


            if (oCommandLine["OutputDir"] != null) {
                _szRootPath = oCommandLine["OutputDir"];
            } else {
                _szRootPath = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Substring(6);
            }


            if (oCommandLine["Config"] != null) {
                _szCompanyIDs = ConfigurationManager.AppSettings["CompanyIDList"];
                _iQueryType = 1;
                
                _szSummary = "Using CompanyIDs found in config file.";

            } else if (oCommandLine["CompanyID"] != null) {
                int iCompanyID = 0;
                if (!int.TryParse(oCommandLine["CompanyID"], out iCompanyID)) {
                    WriteErrorMsg("ERROR: Invalid /CompanyID parameter specified.");
                    return;
                }

                _szCompanyIDs = iCompanyID.ToString();
                _iQueryType = 2;

                _szSummary = "Using Specified CompanyIDs: " + _szCompanyIDs;
                
            } else if ((oCommandLine["Start"] != null) || (oCommandLine["End"] != null) || (oCommandLine["ServiceCodes"] != null)) {
                if (!DateTime.TryParse(oCommandLine["Start"], out _dtStart)) {
                    WriteErrorMsg("ERROR: Invalid /Start parameter specified.");
                    return;
                }

                if (!DateTime.TryParse(oCommandLine["End"], out _dtEnd)) {
                    WriteErrorMsg("ERROR: Invalid /End parameter specified.");
                    return;
                }

                if (oCommandLine["ServiceCodes"] == null) {
                    WriteErrorMsg("ERROR: Invalid /ServiceCodes parameter specified.");
                    return;
                }
                
                _szServiceCodes = oCommandLine["ServiceCodes"];
                _iQueryType = 3;

                _szSummary = "Start=" + _dtStart.ToShortDateString() + " End=" + _dtEnd.ToShortDateString() + " ServiceCodes=" + _szServiceCodes;
                
            } else if (oCommandLine["Wave"] != null) {
                if (!int.TryParse(oCommandLine["Wave"], out _iInputWave)) {
                    WriteErrorMsg("ERROR: Invalid /Wave parameter specified.");
                    return;
                }

                _iQueryType = 4;
                _szSummary = "Re-execute Wave=" + _iInputWave.ToString();
            }

            bool bSend = false;
            if (oCommandLine["Send"] != null) {
                bSend = true;
            }


            GenerateCommunications(bSend);
        }
        
        protected const string SQL_SELECT_MEMBERS =
            "SELECT prse_CompanyID, comp_PRCorrTradestyle, prse_ServiceCode, prod_PRWebUsers, ISNULL(AddlUsers, 0) AddlUsers, dbo.ufn_GetCompanyPhone(prse_CompanyID, 'Y', null, 'F', null) As Fax, prse_NextAnniversaryDate, RTRIM(prod_Name) as prod_Name " +
              "FROM PRService  " +
                   "INNER JOIN NewProduct ON prse_ServiceCode = prod_code  " +
                   "INNER JOIN Company ON prse_CompanyID = comp_CompanyID " +
                   "LEFT OUTER JOIN (SELECT prse_CompanyID As CompanyID, SUM(prod_PRWebUsers) As AddlUsers FROM PRService INNER JOIN NewProduct ON prse_ServiceCode = prod_code WHERE prse_ServiceCode IN ('LTDLIC','BSCLIC','ADVLIC','PRMLIC') AND prse_CancelCode IS NULL GROUP BY prse_CompanyID) FL3 ON prse_CompanyID = CompanyID  " +
             "WHERE prse_Primary = 'Y' " +
               "AND prse_CancelCode IS NULL " +
               "{0}" +
            "ORDER BY prse_CompanyID";

        protected const string SQL_SELECT_NONWAVE = 
               "AND prse_ServiceCode IN (SELECT value FROM dbo.Tokenize('{0}', ',')) " +
               "AND prse_NextAnniversaryDate BETWEEN '{1}' AND '{2}' {3}";
        
        
        protected const string SQL_SELECT_WAVE = 
            "SELECT cmli_Comm_CompanyID  " +
              "FROM Comm_Link  " +
                   "INNER JOIN Communication ON cmli_Comm_CommunicationID = comm_CommunicationID  " +
             "WHERE comm_PRCategory = 'BBOS Wave' ";
        
        protected const string SQL_SELECT_PERSON =
            "SELECT peli_PersonID, ISNULL(dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_MiddleName, NULL, pers_Suffix), 'Valued Blue Book Member') As AttenionLine,   " +
                   "RTRIM(dbo.ufn_GetPersonDefaultEmail(peli_PersonID, peli_CompanyID, null)) As Email, peli_WebPassword, peli_PersonLinkID, RTRIM(pers_FirstName) as pers_FirstName  " +
              "FROM Person_Link  " +
	               "INNER JOIN Person ON peli_PersonID = pers_PersonID  " +
             "WHERE peli_CompanyID = {0}  " +
               "AND peli_PersonID IN (  " +
            "SELECT TOP 1 PersonID FROM (  " +
            "SELECT addr_PRAttentionLinePersonID As PersonID, 1 As Seq  " +
              "FROM Address  " +
                   "INNER JOIN Address_Link on addr_AddressID = adli_AddressID  " +
                   "INNER JOIN Person_Link on adli_CompanyID = peli_CompanyID AND addr_PRAttentionLinePersonID = peli_PersonID " +
             "WHERE adli_Type IN ('M', 'P')  " +
               "AND addr_PRAttentionLinePersonID IS NOT NULL  " +
               "AND peli_PRStatus = 1 " +
               "AND adli_CompanyID = {0}  " +
            "UNION  " +
            "SELECT peli_PersonID As PersonID, 2 As Seq  " +
              "FROM Person_Link  " +
             "WHERE peli_PRRecipientRole LIKE '%,RCVLIST,%'  " +
               "AND peli_PRStatus = 1 " +
               "AND peli_CompanyID={0}  " +
            "UNION  " +
            "SELECT peli_PersonID As PersonID, 3 As Seq  " +
              "FROM Person_Link  " +
             "WHERE peli_PRRecipientRole LIKE '%,RCVBILL,%'  " +
               "AND peli_PRStatus = 1 " +
               "AND peli_CompanyID={0}  " +
            "UNION  " +
            "SELECT * FROM ( " +
                "SELECT TOP 1 peli_PersonID As PersonID, 4 As Seq " +  
                  "FROM Person_Link  " + 
	                   "INNER JOIN Person on peli_PersonID = pers_PersonID " +
                  "WHERE peli_WebStatus = 'Y' " +
                    "AND peli_CompanyID={0} " + 
                    "AND peli_PRStatus = 1 " +
                  "ORDER BY pers_LastName, pers_FirstName " +
            ") T10 " +
            "UNION " +
            "SELECT * FROM ( " +
                "SELECT TOP 1 peli_PersonID As PersonID, 5 As Seq " +  
                  "FROM Person_Link " +  
	                   "INNER JOIN Person on peli_PersonID = pers_PersonID " +
                  "WHERE peli_WebStatus IS NULL " +
                    "AND peli_CompanyID={0} " + 
                    "AND peli_PRStatus = 1 " +
                "ORDER BY pers_LastName, pers_FirstName " +
            ") T20  " +              
            ") T1 ORDER BY Seq);";

        protected const string SQL_SELECT_WAVE_ID =
            "SELECT ISNULL(MAX(CONVERT(int, comm_PRSubcategory)), 0) " +
              "FROM Communication " +
             "WHERE comm_PRCategory = 'BBOS Wave' ";                
        
        protected void GenerateCommunications(bool bSend) {
            DateTime dtStart = DateTime.Now;
            int iCompanyCount = 0;
            int iEmailCount = 0;
            int iFaxCount = 0;
            int iSkipCount = 0;
            
            bool bSkip = false;
            
            string szClause = null;
            
            switch(_iQueryType) {
                case 0:
                    WriteErrorMsg("Invalid query parameter specified.");
                    DisplayHelp();
                    return;
                case 1:
                case 2:
                    szClause = " AND prse_CompanyID IN (" + _szCompanyIDs + ") ";
                    break;
                case 3:
                    szClause = string.Format(SQL_SELECT_NONWAVE, _szServiceCodes, _dtStart.ToString("MM-dd-yyyy"), _dtEnd.ToString("MM-dd-yyyy"), " AND prse_CompanyID NOT IN (" + SQL_SELECT_WAVE + ") ");
                    break;
                case 4:
                    szClause = " AND prse_CompanyID IN (" + SQL_SELECT_WAVE + " AND comm_PRSubcategory='" + _iInputWave.ToString() + "') ";
                    break;
            
            }

            
            string szSQL = string.Format(SQL_SELECT_MEMBERS, szClause);
            //Console.WriteLine(szSQL);

            IDbConnection oConn = new SqlConnection(ConfigurationManager.AppSettings["DBConnectionString"]);
            IDbConnection oPersonConn = new SqlConnection(ConfigurationManager.AppSettings["DBConnectionString"]);
            IDataReader oReader = null;
            StreamWriter oLogFile = null;

            try {
                Console.WriteLine();

                string szMessage = null;

                using (StreamReader sr = new StreamReader(Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Substring(6) + "/Template.txt")) {
                    szMessage = sr.ReadToEnd();
                }
                
                oConn.Open();
                oPersonConn.Open();
                
                IDbCommand oWaveCommand = oConn.CreateCommand();
                oWaveCommand.CommandText = SQL_SELECT_WAVE_ID;
                oWaveCommand.CommandTimeout = 300;
                oWaveCommand.CommandType = CommandType.Text;

                _iWave = (int)oWaveCommand.ExecuteScalar();
                _iWave++;
    
                string szResultsPath = "Wave" + _iWave.ToString("000") + "_" + DateTime.Now.ToString("yyyyMMdd_HHmmss") + @"\";
                _szRootPath = Path.Combine(_szRootPath, szResultsPath);

                if (!Directory.Exists(_szRootPath)) {
                    Directory.CreateDirectory(_szRootPath);
                }

                string szLogFile = Path.Combine(_szRootPath, "BBOSCommunicatorLog.txt");
                if (File.Exists(szLogFile)) {
                    File.Delete(szLogFile);
                }

                oLogFile = new StreamWriter(szLogFile);
                oLogFile.WriteLine("Wave;Company ID;Company Name;Service Code;Anniversary;Person ID;Person Name;Fax;Email;Generated Password;Skipped;Notes");


                
                Console.WriteLine("Processing Wave " + _iWave.ToString());
                
                IDbCommand oSelectCommand = oConn.CreateCommand();
                oSelectCommand.CommandText = szSQL;
                oSelectCommand.CommandTimeout = 300;
                oSelectCommand.CommandType = CommandType.Text;

                oReader = oSelectCommand.ExecuteReader();
                while (oReader.Read()) {
                    iCompanyCount++;
                    bSkip = false;
                    
                    
                    int iCompanyID = oReader.GetInt32(0);
                    string szCompanyName = oReader["comp_PRCorrTradestyle"].ToString();
                    string szServiceCode = oReader.GetString(2);
                    string szProductName = oReader["prod_Name"].ToString();

                    DateTime dtAnniversaryDate = oReader.GetDateTime(6);
                    Console.WriteLine("Processing {0} - {1}", iCompanyID, szCompanyName);

                    string szFax = string.Empty;
                    string szEmail = string.Empty;
                    string szAddress = string.Empty;
                    string szPassword = string.Empty;
                    string szNotes = string.Empty;
                    string szGeneratedPassword = string.Empty;

                    int iPersonID = 0;
                    string szPersonName = string.Empty;
                    string szFirstName = string.Empty;
                    int iUsers = 0;

                    bool bFax = true;

                    if (oReader[3] == DBNull.Value) {
                        WriteErrorMsg(" - The primary service does not have web access, Skipping Company...");
                        szNotes = "The primary service does not have web access.  No communciation sent.";
                        bSkip = true;
                        iSkipCount++;
                    }  else {                   
                        iUsers = oReader.GetInt32(3) + oReader.GetInt32(4);
                      
                        if (oReader[5] != DBNull.Value) {
                            szFax = oReader.GetString(5);
                            szAddress = szFax;
                        }
                        
                        string szPersonSQL = string.Format(SQL_SELECT_PERSON, iCompanyID);
                        //Console.WriteLine(szPersonSQL);
                        
                        IDbCommand oPersonCommand = oPersonConn.CreateCommand();
                        oPersonCommand.CommandText = szPersonSQL;
                        oPersonCommand.CommandTimeout = 300;
                        oPersonCommand.CommandType = CommandType.Text;

                        IDataReader oPersonReader = oPersonCommand.ExecuteReader();                    
                        try {
                            if (!oPersonReader.Read()) {
                                //szPersonName = "Valued Blue Book Member";
                                WriteErrorMsg(" - No Email/Fax Found, Skipping Company...");
                                szNotes = "No Person Found.  No communciation sent.";
                                bSkip = true;
                                iSkipCount++;
                                
                            } else {
                                WriteVerboseMsg(" - Found Person: " + oPersonReader.GetString(1));

                                iPersonID = oPersonReader.GetInt32(0);
                                szPersonName = oPersonReader.GetString(1);
                                szFirstName = oPersonReader["pers_FirstName"].ToString();

                                if (oPersonReader[2] != DBNull.Value) {
                                    szEmail = oPersonReader.GetString(2);
                                }

                                if (oPersonReader[3] != DBNull.Value) {
                                    szPassword = oPersonReader.GetString(3);
                                } else {
                                    
                                    if (bSend) {
                                        szPassword = GeneratePassword(iPersonID, oPersonReader.GetInt32(4));
                                    } else {
                                        szPassword = "[TO BE GENERATED]";
                                    }                                    
                                    WriteVerboseMsg(" - Generated Password");
                                    szGeneratedPassword = "Y";
                                }

                                if ((string.IsNullOrEmpty(szEmail)) &&
                                    (string.IsNullOrEmpty(szFax))) {
                                    WriteErrorMsg(" - No Email/Fax Found, Skipping Company...");
                                    szNotes = "No Email/Fax Found.  No communciation sent.";
                                    bSkip = true;
                                    iSkipCount++;
                                } else {
                                    if (!string.IsNullOrEmpty(szEmail)) {
                                        bFax = false;
                                        szAddress = szEmail;
                                    }
                                }
                            }
                                           
                        } finally {
                            if (oPersonReader != null) {
                                oPersonReader.Close();
                            }
                        }
                    }          

                    if (!bSkip) {
                        object[] args = {szFirstName,
                                         szCompanyName,
                                         szProductName,
                                         iUsers,
                                         iCompanyID.ToString(),
                                         szPassword};                    

                        string szAttachmentName = null;                                         
                        string szOutMsg = string.Format(szMessage, args);
                        using (StreamWriter sw = new StreamWriter(Path.Combine(_szRootPath, iCompanyID.ToString() + ".txt"))) {
                            sw.WriteLine(szOutMsg);
                        }                            
                    
                        string szAction = null;
                        if (bFax) {
                            szAction = "FaxOut";
                            iFaxCount++;
                            szFax = szAddress;
                            WriteVerboseMsg(" - Sending Fax to " + szAddress);
                            
                            if (bSend) {
                                szAttachmentName = "BBOS_Wave" + _iWave.ToString("000") + "_" + iCompanyID.ToString() + ".txt";
                                using (StreamWriter sw = new StreamWriter(Path.Combine(ConfigurationManager.AppSettings["TempReportsFolder"], szAttachmentName))) {
                                    sw.WriteLine(szOutMsg);
                                }                            
                            }                            
                        } else {
                            szAction = "EmailOut";
                            iEmailCount++;
                            szEmail = szAddress;
                            WriteVerboseMsg(" - Sending Email to " + szAddress);
                        }
                        
                        if (bSend) {
                            SqlCommand oSendCommand = (SqlCommand)oPersonConn.CreateCommand();
                            oSendCommand.CommandText = "usp_CreateEmail";
                            oSendCommand.CommandTimeout = 300;
                            oSendCommand.CommandType = CommandType.StoredProcedure;
                            oSendCommand.Parameters.AddWithValue("@To", szAddress);
                            oSendCommand.Parameters.AddWithValue("@Subject", ConfigurationManager.AppSettings["EmailSubject"]);
                            oSendCommand.Parameters.AddWithValue("@Content", szOutMsg);
                            oSendCommand.Parameters.AddWithValue("@Content_Format", "TEXT");
                            oSendCommand.Parameters.AddWithValue("@RelatedCompanyId", iCompanyID);
                            oSendCommand.Parameters.AddWithValue("@RelatedPersonId", iPersonID);
                            oSendCommand.Parameters.AddWithValue("@Action", szAction);
                            oSendCommand.Parameters.AddWithValue("@AttachmentFileName", szAttachmentName);
                            oSendCommand.Parameters.AddWithValue("@PRCategory", "BBOS Wave");
                            oSendCommand.Parameters.AddWithValue("@PRSubcategory", _iWave.ToString());
                            
                            //oSendCommand.Parameters.AddWithValue("@DoNotSend", 1);

                            
                            oSendCommand.ExecuteScalar();
                        }
                    }
                                                
                    string szSkip = string.Empty;
                    if (bSkip) {
                        szSkip = "Y";
                    }

                    object[] args2 = {_iWave,
                                    iCompanyID,
                                    szCompanyName,
                                    szServiceCode,
                                    dtAnniversaryDate.ToString("MM/dd/yyyy"),
                                    iPersonID,
                                    szPersonName,
                                    szFax,
                                    szEmail,
                                    szGeneratedPassword,
                                    szSkip,
                                    szNotes};

                    oLogFile.WriteLine("{0};{1};{2};{3};{4};{5};{6};{7};{8};{9};{10};{11}", args2);

                }

                Console.WriteLine();

            } catch (Exception e) {
                Console.WriteLine();
                WriteErrorMsg("An unexpected exception occurred: " + e.Message);
                Console.WriteLine(e.StackTrace);
                WriteErrorMsg("Terminating execution.");
            } finally {
                if (oReader != null) {
                    oReader.Close();
                }

                if (oConn != null) {
                    oConn.Close();
                }

                if (oPersonConn != null) {
                    oPersonConn.Close();
                }

                if (oLogFile != null) {
                    oLogFile.Close();
                }
            }
            using (StreamWriter sw = new StreamWriter(Path.Combine(_szRootPath, "BBOSCommunicatorSummary.txt"))) {
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
        /// <summary>
        /// Displays the application help message
        /// </summary>
        protected void DisplayHelp() {
            Console.WriteLine(string.Empty);
            Console.WriteLine("BBOS Communicator Utility");
            Console.WriteLine("/Start=        The start date when applied to the anniversary date.");
            Console.WriteLine("/End=          The end date when applied to the anniverary date.");
            Console.WriteLine("/ServiceCodes= Comma-delimited list of service codes.");
            Console.WriteLine("/Config        Generate communications for those companies specified in the configuration file.");
            Console.WriteLine("/CompanyID=    Generate communications for only the specified company.");
            Console.WriteLine("/Wave=         Regenerates the communications for the specified wave.");
            Console.WriteLine("/Send=         Indicates the communications should actually be sent.");
            Console.WriteLine(string.Empty);
            Console.WriteLine("/OutputDir=    The fully qualified directory to write any the output to.");
            Console.WriteLine("/Help          This help message");
        }

        protected void WriteErrorMsg(string szMsg) {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine(szMsg);
            Console.ForegroundColor = ConsoleColor.Gray;
        }
        
        protected void WriteVerboseMsg(string szMsg) {
            if (_bVersbose) {
                Console.WriteLine(szMsg);
            }
        }

        
        protected const string SQL_SET_PASSWORD = 
            "UPDATE Person_Link SET peli_WebPassword = '{0}' WHERE peli_PersonLinkID={1}";
        
        protected string GeneratePassword(int iPersonID, int iPersonLinkID) {
            IDbConnection oConn = new SqlConnection(ConfigurationManager.AppSettings["DBConnectionString"]);
            
            try {
                oConn.Open();
                SqlCommand oCommand = (SqlCommand)oConn.CreateCommand();
                oCommand.CommandText = "usp_GeneratePassword";
                oCommand.CommandType = CommandType.StoredProcedure;
                
                SqlParameter oSqlParm = new SqlParameter();
                oSqlParm.ParameterName = "@Password";
                oSqlParm.Direction = ParameterDirection.Output;
                oSqlParm.Size = 100;
                oCommand.Parameters.Add(oSqlParm);
                
                oCommand.ExecuteNonQuery();
                string szPassword = (string)oCommand.Parameters[0].Value;
                
                if (szPassword.Length > 8) {
                    szPassword = szPassword.Substring(0, 8);
                }

                GeneralDataMgr oObjectMgr = new GeneralDataMgr();
                int iTransactionID = oObjectMgr.CreatePIKSTransaction(0, iPersonID, "BBOS Communicator", "Generating password to give user access to the BBOS Access Management utility.", null);

                string szSQL = string.Format(SQL_SET_PASSWORD, szPassword, iPersonLinkID);
                oCommand = (SqlCommand)oConn.CreateCommand();
                oCommand.CommandText = szSQL;
                oCommand.CommandType = CommandType.Text;
                int iRows = oCommand.ExecuteNonQuery();

                oObjectMgr.ClosePIKSTransaction(iTransactionID, null);
                                
                if (iRows == 0) {
                    throw new Exception("Password update failed: " + szSQL);
                }
                                
                return szPassword;
            } finally {
                oConn.Close();
            }
        }

       
    }
}
