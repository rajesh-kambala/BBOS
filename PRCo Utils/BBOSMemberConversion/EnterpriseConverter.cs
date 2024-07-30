using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.IO;

using CommandLine.Utility;


namespace PRCo.BBOS.MemberConversion {

    class EnterpriseConverter {

        protected string _szFullPath;

        public void ConvertEnterprises(string[] args) {

            Console.Clear();
            Console.Title = "BBOS Enterprise Conversion Utility";
            Console.WriteLine("BBOS Enterprise Conversion Utility 1.0");
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
                _szFullPath = oCommandLine["OutputDir"];
            } else {
                string szRootPath = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Substring(6);
                _szFullPath = Path.Combine(szRootPath, "EnterpriseConverter.txt");
            }

            int iTop = -1;
            string szHQIDs = null;

            if (oCommandLine["All"] != null) {
                iTop = 0;

            } else if (oCommandLine["Top"] != null) {
                if (!int.TryParse(oCommandLine["Top"], out iTop)) {
                    Console.WriteLine("ERROR: Invalid /Top parameter specified.");
                    return;
                }

            } else if (oCommandLine["Config"] != null) {
                szHQIDs = ConfigurationManager.AppSettings["HQIDList"];

            } else if (oCommandLine["HQID"] != null) {
                int iHQID = 0;
                if (!int.TryParse(oCommandLine["HQID"], out iHQID)) {
                    Console.WriteLine("ERROR: Invalid /HQID parameter specified.");
                    return;
                }

                szHQIDs = iHQID.ToString();
            }

            ExecuteConversion(iTop, szHQIDs);
        }

        protected const string SQL_SELECT_ENTERPRISES =
         "SELECT {0} * FROM ( " +
            "SELECT comp_CompanyID, comp_Name, LicenseCount, ConvertFlagCount " +
              "FROM Company (NOLOCK) " +
                   "INNER JOIN (SELECT prse_HQID, SUM(prod_PRWebUsers) As LicenseCount " +
                                 "FROM PRService (NOLOCK) " +
                                      "INNER JOIN NewProduct (NOLOCK) on prse_ServiceCode = prod_code " +
                                "WHERE prod_PRWebAccess = 'Y' " +
                                  "AND prse_CancelCode IS NULL " +
                             "GROUP BY prse_HQID) T2 ON prse_HQID = comp_CompanyID " +
                   "INNER JOIN (SELECT comp_PRHQID As HQID, COUNT(1) As ConvertFlagCount " +
                                 "FROM Company " +
                                      "INNER JOIN Person_Link on comp_CompanyID = peli_CompanyID " +
                                "WHERE peli_PRStatus IN (1,2) " +
                                  "AND peli_PRConvertToBBOS = 'Y' " +
                             "GROUP BY comp_PRHQID) T3 ON HQID = comp_CompanyID " +
             "WHERE comp_PRType='H' " +
               "AND LicenseCount > ConvertFlagCount " +  // We only want those that have addtional licenses
               "AND comp_CompanyID NOT IN (SELECT DISTINCT prbbosua_HQID FROM PRBBOSUserAudit) " + // That haven't viewd our web utility
               "  " +
            ") T1 " +
            "{1} ORDER BY comp_CompanyID";
               



        protected const string SQL_UPDATE_COMPANY =
            "UPDATE Person_Link  " +
               "SET peli_PRConvertToBBOS = 'Y' " +
             "WHERE peli_PersonLinkID IN ( " +
                    "SELECT TOP {0} peli_PersonLinkID " +
               "FROM Person_Link " +
                    "INNER JOIN Person on peli_PersonID = pers_PersonID " +
                    "LEFT OUTER JOIN Email a ON peli_PersonID = a.emai_PersonID AND peli_CompanyID = a.emai_CompanyID " +
                    "LEFT OUTER JOIN Email b ON peli_PersonID = b.emai_PersonID AND peli_CompanyID = b.emai_CompanyID " +
                    "LEFT OUTER JOIN (SELECT DISTINCT prau_CompanyID, prau_PersonID FROM PRAUS) FL2 ON  peli_PersonID = prau_PersonID AND peli_CompanyID = prau_CompanyID " +
              "WHERE peli_CompanyID IN (SELECT comp_CompanyID FROM Company WHERE comp_PRHQID ={1}) " +
                "AND peli_PRStatus IN (1,2) " +
                "AND peli_PersonID NOT IN (SELECT DISTINCT peli_PersonID FROM Person_Link WHERE peli_PRConvertToBBOS = 'Y') " +
           "ORDER BY peli_WebStatus DESC, a.emai_EmailAddress DESC, CASE WHEN prau_CompanyID IS NULL THEN NULL ELSE 'Y' END DESC, b.emai_EmailAddress DESC, pers_LastName, pers_FirstName);";

        protected const string SQL_SELECT_COMPANY_PERSONS =
             "SELECT peli_PersonLinkID, peli_PersonID " +
               "FROM Person_Link " +
                    "INNER JOIN Person on peli_PersonID = pers_PersonID " +
                    "LEFT OUTER JOIN Email a ON peli_PersonID = a.emai_PersonID AND peli_CompanyID = a.emai_CompanyID " +
                    "LEFT OUTER JOIN Email b ON peli_PersonID = b.emai_PersonID AND peli_CompanyID = b.emai_CompanyID " +
                    "LEFT OUTER JOIN (SELECT DISTINCT prau_CompanyID, prau_PersonID FROM PRAUS) FL2 ON  peli_PersonID = prau_PersonID AND peli_CompanyID = prau_CompanyID " +
              "WHERE peli_CompanyID IN (SELECT comp_CompanyID FROM Company WHERE comp_PRHQID =@comp_PRHQID) " +
                "AND peli_PRStatus IN (1,2) " +
                "AND peli_PersonID NOT IN (SELECT DISTINCT peli_PersonID FROM Person_Link WHERE peli_PRConvertToBBOS = 'Y') " +
           "ORDER BY peli_WebStatus DESC, a.emai_EmailAddress DESC, CASE WHEN prau_CompanyID IS NULL THEN NULL ELSE 'Y' END DESC, b.emai_EmailAddress DESC, pers_LastName, pers_FirstName";

        protected const string SQL_DUP_CHECK = "SELECT 'x' FROM Person_Link WHERE peli_PersonID=@peli_PersonID AND peli_PRConvertToBBOS = 'Y'";
        protected const string SQL_UPDATE_PL = "UPDATE Person_Link SET peli_PRConvertToBBOS = 'Y' WHERE peli_PersonLinkID=@peli_PersonLinkID";

        protected void ExecuteConversion(int iTop, string szHQIDs) {
            DateTime dtStart = DateTime.Now;

            int iHQCount = 0;
            int iConvertedUserCount = 0;

            string szTopClause = string.Empty;
            if (iTop > 0) {
                szTopClause = " TOP " + iTop.ToString();
            }

            string szFilterClause = string.Empty;
            if (!string.IsNullOrEmpty(szHQIDs)) {
                szFilterClause = "WHERE comp_CompanyID IN (" + szHQIDs + ")";
            }

            string szSQL = string.Format(SQL_SELECT_ENTERPRISES, szTopClause, szFilterClause);

            IDbConnection oConn = new SqlConnection(ConfigurationManager.AppSettings["ConnectionString"]);
            IDbConnection oPLConn = new SqlConnection(ConfigurationManager.AppSettings["ConnectionString"]);
            IDbConnection oDupCheckConn = new SqlConnection(ConfigurationManager.AppSettings["ConnectionString"]);
            IDbConnection oUpdateConn = new SqlConnection(ConfigurationManager.AppSettings["ConnectionString"]);
            IDataReader oReader = null;

            StreamWriter oOutputFile = null;
            int iResetCount = 0;
            try {
                if (File.Exists(_szFullPath)) {
                    File.Delete(_szFullPath);
                }

                oOutputFile = new StreamWriter(_szFullPath);
                oOutputFile.WriteLine("CompanyID;Company Name;License Count;Previous Converted Flag Count;Converted This Time Count");

                oConn.Open();
                oPLConn.Open();
                oDupCheckConn.Open();
                oUpdateConn.Open();

                //Console.WriteLine();
                IDbCommand oResetCommand = oConn.CreateCommand();

                oResetCommand.CommandText = "UPDATE Person_Link SET peli_PRConvertToBBOS = NULL WHERE peli_PRConvertToBBOS = 'Y' AND peli_PRStatus IN (3,4)";
                oResetCommand.CommandType = CommandType.Text;
                oResetCommand.CommandTimeout = 300;
                iResetCount = (int)oResetCommand.ExecuteNonQuery();


                IDbCommand oSelectCommand = oConn.CreateCommand();
                oSelectCommand.CommandText = szSQL;
                oSelectCommand.CommandType = CommandType.Text;

                oReader = oSelectCommand.ExecuteReader();
                while (oReader.Read()) {
                    iHQCount++;

                    int iMaxUsers = oReader.GetInt32(2) - oReader.GetInt32(3);

                    SqlCommand oSelectPLCommand = (SqlCommand)oPLConn.CreateCommand();
                    oSelectPLCommand.CommandText = SQL_SELECT_COMPANY_PERSONS;
                    oSelectPLCommand.Parameters.AddWithValue("@comp_PRHQID", oReader["comp_CompanyID"]);
                    IDataReader oPLReader = oSelectPLCommand.ExecuteReader();
                    
                    int iConvertedUsers = 0;
                    try {
                        while (oPLReader.Read()) {
                            SqlCommand oDupCheckCommand = (SqlCommand)oDupCheckConn.CreateCommand();
                            oDupCheckCommand.CommandText = SQL_DUP_CHECK;
                            oDupCheckCommand.Parameters.AddWithValue("@peli_PersonID", oPLReader["peli_PersonID"]);
                            object oExists = oDupCheckCommand.ExecuteScalar();
                            if (oExists == null) {

                                SqlCommand oUpdateCommand = (SqlCommand)oUpdateConn.CreateCommand();
                                oUpdateCommand.CommandText = SQL_UPDATE_PL;
                                oUpdateCommand.Parameters.AddWithValue("@peli_PersonLinkID", oPLReader["peli_PersonLinkID"]);
                                oUpdateCommand.ExecuteNonQuery();

                                iConvertedUsers++;                        
                            }
                            
                            if (iConvertedUsers == iMaxUsers) {
                                break;
                            }
                        }
                    } finally {
                        if (oPLReader != null) {
                            oPLReader.Close();
                        }
                    }                    
                    

                    Console.WriteLine("Converted {0} - {1}: Granted Access to {2} Persons", oReader["comp_CompanyID"], oReader["comp_Name"], iConvertedUsers);
                    iConvertedUserCount += iConvertedUsers;

                    object[] args = {oReader[0],
                                    oReader[1],
                                    oReader[2],
                                    oReader[3],
                                    iConvertedUsers};

                    oOutputFile.WriteLine("{0};{1};{2};{3};{4}", args);
                }

                Console.WriteLine();
                Console.ForegroundColor = ConsoleColor.Green;
                Console.WriteLine("Conversion Completed.");
                Console.ForegroundColor = ConsoleColor.Gray;

            } catch (Exception e) {
                Console.WriteLine();
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine("An unexpected exception occurred: " + e.Message);
                Console.WriteLine("Terminating execution.");
                Console.ForegroundColor = ConsoleColor.Gray;
            } finally {
                if (oReader != null) {
                    oReader.Close();
                }

                if (oConn != null) {
                    oConn.Close();
                }

                if (oUpdateConn != null) {
                    oUpdateConn.Close();
                }
                
                if (oPLConn != null) {
                    oPLConn.Close();
                }

                if (oDupCheckConn != null) {
                    oDupCheckConn.Close();
                }

                if (oOutputFile != null) {
                    oOutputFile.Close();
                }
            }

            Console.WriteLine();
            Console.WriteLine("Reset " + iResetCount.ToString("###,##0") + " Person_Link records having a status of 3 or 4.");
            Console.WriteLine("Converted " + iHQCount.ToString("###,##0") + " Enterprises");
            Console.WriteLine("Converted " + iConvertedUserCount.ToString("###,##0") + " Persons");

            if (iHQCount > 0) {
                Console.WriteLine("Output Log File for MS Excel Import: " + _szFullPath);
            }

            Console.WriteLine("Execution Time: " + DateTime.Now.Subtract(dtStart).ToString());
            //Console.WriteLine(ConfigurationManager.AppSettings["ConnectionString"]);
        }

        /// <summary>
        /// Displays the application help message
        /// </summary>
        protected void DisplayHelp() {
            Console.WriteLine(string.Empty);
            Console.WriteLine("BBOS Member Conversion Utility");
            Console.WriteLine("/All           Convert all listed companies.");
            Console.WriteLine("/Top=          Convert the top N enterprises.");
            Console.WriteLine("/Config        Convert those companies specified in the configuration file.");
            Console.WriteLine("/HQID=         Convert only the specified enterporise.");
            Console.WriteLine(string.Empty);
            Console.WriteLine("/OutputDir=    The fully qualified directory to write the output to.");
            Console.WriteLine("/Help          This help message");
        }

    }
}



                //oReader = oSelectCommand.ExecuteReader();
                //while (oReader.Read()) {
                //    iHQCount++;

                //    int iMaxUsers = oReader.GetInt32(2) - oReader.GetInt32(3);
                //    string szUpdateSQL = string.Format(SQL_UPDATE_COMPANY, iMaxUsers, oReader["comp_CompanyID"]);

                //    IDbCommand oUpdateCommand = oUpdateConn.CreateCommand();
                //    oUpdateCommand.CommandText = szUpdateSQL;
                //    oUpdateCommand.CommandType = CommandType.Text;
                //    int iConvertedUsers = oUpdateCommand.ExecuteNonQuery();

                //    Console.WriteLine("Converted {0} - {1}: Granted Access to {2} Persons", oReader["comp_CompanyID"], oReader["comp_Name"], iConvertedUsers);
                //    iConvertedUserCount += iConvertedUsers;

                //    object[] args = {oReader[0],
                //                    oReader[1],
                //                    oReader[2],
                //                    oReader[3],
                //                    iConvertedUsers};

                //    oOutputFile.WriteLine("{0};{1};{2};{3};{4}", args);
                //}
