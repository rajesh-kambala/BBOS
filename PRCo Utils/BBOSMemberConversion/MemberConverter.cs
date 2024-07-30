using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.IO;

using CommandLine.Utility;

namespace PRCo.BBOS.MemberConversion {

    class MemberConverter {
    
        protected string _szFullPath;

        public void ConvertMembers(string[] args) {

            Console.Clear();
            Console.Title ="BBOS Member Conversion Utility";
            Console.WriteLine("BBOS Member Conversion Utility 1.0");
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
                _szFullPath = Path.Combine(szRootPath, "MemberConverter.txt");
            }

            int iTop = -1;
            string szCompanyIDs = null;

            if (oCommandLine["All"] != null) {
                iTop = 0;

            } else if (oCommandLine["Top"] != null) {
                if (!int.TryParse(oCommandLine["Top"], out iTop)) {
                    Console.WriteLine("ERROR: Invalid /Top parameter specified.");
                    return;
                }

            } else if (oCommandLine["Config"] != null) {
                szCompanyIDs = ConfigurationManager.AppSettings["CompanyIDList"];

            } else if (oCommandLine["CompanyID"] != null) {
                int iCompanyID = 0;
                if (!int.TryParse(oCommandLine["CompanyID"], out iCompanyID)) {
                    Console.WriteLine("ERROR: Invalid /CompanyID parameter specified.");
                    return;
                }

               szCompanyIDs = iCompanyID.ToString();
            }

            bool bResetConvertFlag = false;
            if (oCommandLine["Reset"] != null) {
                bResetConvertFlag = true;
            }
            ExecuteConversion(iTop, szCompanyIDs, bResetConvertFlag);
        }

        protected const string SQL_SELECT_COMPANIES = 
            "SELECT {0} * FROM ( " +
                "SELECT prse_CompanyID, comp_Name, prod_Name, prod_PRWebUsers, ISNULL(AddlUsers, 0) AddlUsers, prod_PRWebAccessLevel, COUNT(1) PersonCount, SUM(CASE peli_WebStatus WHEN 'Y' THEN 1 ELSE 0 END) AS WebAccessCount, SUM(CASE WHEN prau_CompanyID IS NULL THEN 0 ELSE 1 END) AS AUSCount " +
                  "FROM PRService  " +
                       "INNER JOIN NewProduct ON prse_ServiceCode = prod_code  " +
                       "INNER JOIN Company ON prse_CompanyID = comp_CompanyID " +
                       "INNER JOIN Person_Link ON comp_CompanyID = peli_CompanyID " +
                       "LEFT OUTER JOIN (SELECT DISTINCT prau_CompanyID, prau_PersonID FROM PRAUS) FL2 ON  peli_PersonID = prau_PersonID AND peli_CompanyID = prau_CompanyID " +
                       "LEFT OUTER JOIN (SELECT prse_CompanyID As CompanyID, SUM(prod_PRWebUsers) As AddlUsers FROM PRService INNER JOIN NewProduct ON prse_ServiceCode = prod_code WHERE prod_ProductFamilyID = 6 AND prse_CancelCode IS NULL GROUP BY prse_CompanyID) FL3 ON prse_CompanyID = CompanyID  " +
                 "WHERE prse_CancelCode IS NULL   " +
                   "AND prse_Primary = 'Y' " +
                   "AND prod_PRWebAccess = 'Y' " +
                   "AND peli_PRStatus IN (1,2,4) " +
                "GROUP BY prse_CompanyID, comp_Name, prod_Name, prod_PRWebUsers, AddlUsers, prod_PRWebAccessLevel " +
	            "UNION " +
                "SELECT prse_CompanyID, comp_Name, prod_Name, 0 prod_PRWebUsers, ISNULL(AddlUsers, 0) AddlUsers, prod_PRWebAccessLevel, COUNT(1) PersonCount, SUM(CASE peli_WebStatus WHEN 'Y' THEN 1 ELSE 0 END) AS WebAccessCount, SUM(CASE WHEN prau_CompanyID IS NULL THEN 0 ELSE 1 END) AS AUSCount " +
                  "FROM (SELECT prse_CompanyID, MAX(prod_Name) prod_Name, COUNT(1) AddlUsers, MAX(prod_PRWebAccessLevel) prod_PRWebAccessLevel FROM PRService INNER JOIN NewProduct ON prse_ServiceCode = prod_code WHERE prse_CancelCode IS NULL AND prse_Primary IS NULL AND prod_PRWebAccess = 'Y' GROUP BY prse_CompanyID) T1 " +
                       "INNER JOIN Company ON prse_CompanyID = comp_CompanyID " +
                       "INNER JOIN Person_Link ON comp_CompanyID = peli_CompanyID " +
                       "LEFT OUTER JOIN (SELECT DISTINCT prau_CompanyID, prau_PersonID FROM PRAUS) FL2 ON  peli_PersonID = prau_PersonID AND peli_CompanyID = prau_CompanyID " +
                 "WHERE peli_PRStatus IN (1,2,4) " +
                   "AND prse_CompanyID NOT IN (SELECT prse_CompanyID FROM PRService WHERE prse_Primary = 'Y' AND prse_CancelCode IS NULL) " +
                "GROUP BY prse_CompanyID, comp_Name, prod_Name, AddlUsers, prod_PRWebAccessLevel " +
            ") T1 " +
            "{1} ORDER BY prse_CompanyID";
        
        
            //"SELECT {0} prse_CompanyID, comp_Name, prod_Name, prod_PRWebUsers, ISNULL(AddlUsers, 0) AddlUsers, prod_PRWebAccessLevel, COUNT(1) PersonCount, SUM(CASE peli_WebStatus WHEN 'Y' THEN 1 ELSE 0 END) AS WebAccessCount, SUM(CASE WHEN prau_CompanyID IS NULL THEN 0 ELSE 1 END) AS AUSCount " +
            //  "FROM PRService  " +
            //       "INNER JOIN NewProduct ON prse_ServiceCode = prod_code  " +
            //       "INNER JOIN Company ON prse_CompanyID = comp_CompanyID " +
            //       "INNER JOIN Person_Link ON comp_CompanyID = peli_CompanyID " +
            //       "LEFT OUTER JOIN (SELECT DISTINCT prau_CompanyID, prau_PersonID FROM PRAUS) FL2 ON  peli_PersonID = prau_PersonID AND peli_CompanyID = prau_CompanyID " +
            //       "LEFT OUTER JOIN (SELECT prse_CompanyID As CompanyID, SUM(prod_PRWebUsers) As AddlUsers FROM PRService INNER JOIN NewProduct ON prse_ServiceCode = prod_code WHERE prod_ProductFamilyID = 6 AND prse_CancelCode IS NULL GROUP BY prse_CompanyID) FL3 ON prse_CompanyID = CompanyID  " +
            // "WHERE prse_Primary = 'Y' " +
            //   "AND prse_CancelCode IS NULL " +
            //   "AND prod_PRWebAccess = 'Y' " +
            //   "AND peli_PRStatus IN (1,2,4) " +
            //   " {1} " +
            //"GROUP BY prse_CompanyID, comp_Name, prod_Name, prod_PRWebUsers, AddlUsers, prod_PRWebAccessLevel " +
            //"ORDER BY prse_CompanyID;";

        protected const string SQL_UPDATE_COMPANY = 
            "UPDATE Person_Link  " +
               "SET peli_PRConvertToBBOS = 'Y' " +
             "WHERE peli_PersonLinkID IN ( " +
		            "SELECT TOP {0} peli_PersonLinkID " +
		              "FROM Person_Link " +
			               "INNER JOIN Person on peli_PersonID = pers_PersonID " +
			               "LEFT OUTER JOIN (SELECT DISTINCT prau_CompanyID, prau_PersonID FROM PRAUS) FL2 ON  peli_PersonID = prau_PersonID AND peli_CompanyID = prau_CompanyID " +
		             "WHERE peli_CompanyID={1} " +
		               "AND peli_PRStatus IN (1,2,4) " +
		               "AND peli_PersonID NOT IN (SELECT DISTINCT peli_PersonID FROM Person_Link WHERE peli_PRConvertToBBOS = 'Y') " +
		            "ORDER BY peli_WebStatus DESC, CASE WHEN prau_CompanyID IS NULL THEN NULL ELSE 'Y' END DESC, pers_LastName, pers_FirstName);";



        protected void ExecuteConversion(int iTop, string szCompanyIDs, bool bResetConvertFlag) {
            DateTime dtStart = DateTime.Now;
    
            int iCompanyCount = 0;
            int iConvertedUserCount = 0;
            
            string szTopClause = string.Empty;
            if (iTop > 0) {
                szTopClause = " TOP " + iTop.ToString();
            }
            
            string szFilterClause = string.Empty;
            if (!string.IsNullOrEmpty(szCompanyIDs)) {
                szFilterClause = "WHERE prse_CompanyID IN (" + szCompanyIDs + ")";
            }
            
            string szSQL = string.Format(SQL_SELECT_COMPANIES, szTopClause, szFilterClause);

            IDbConnection oConn = new SqlConnection(ConfigurationManager.AppSettings["ConnectionString"]);
            IDbConnection oUpdateConn = new SqlConnection(ConfigurationManager.AppSettings["ConnectionString"]);
            IDataReader oReader = null;

            StreamWriter oOutputFile = null;

            try {
                if (File.Exists(_szFullPath)) {
                    File.Delete(_szFullPath);
                }

                oOutputFile = new StreamWriter(_szFullPath);
                oOutputFile.WriteLine("CompanyID;Company Name;License Name;Membership Users;Additional Users;Access Level;Active Person Count;Web User Count;AUS Count;Converted Users;Has Extra Licenses;May Need Addtional Licenses");

                oConn.Open();
                oUpdateConn.Open();

                //Console.WriteLine();
                IDbCommand oResetCommand = oConn.CreateCommand();

                oResetCommand.CommandText = "SELECT COUNT(1) FROM Person_Link WHERE peli_PRConvertToBBOS = 'Y'";
                oResetCommand.CommandType = CommandType.Text;
                oResetCommand.CommandTimeout = 300;
                int iFlagCount = (int)oResetCommand.ExecuteScalar();
                
                if (iFlagCount > 0) {
                    if (bResetConvertFlag) {
                        Console.WriteLine("Resetting peli_PRConvertToBBOS flag.  This may take several minutes...");
                        oResetCommand.CommandText = "UPDATE Person_Link SET peli_PRConvertToBBOS = NULL WHERE peli_PRConvertToBBOS = 'Y'";
                        oResetCommand.CommandType = CommandType.Text;
                        oResetCommand.CommandTimeout = 300;
                        oResetCommand.ExecuteNonQuery();
                        Console.WriteLine();
                        
                        
                    } else {
                        Console.ForegroundColor = ConsoleColor.Red;
                        Console.WriteLine("Person_Link records were found that have the peli_PRConvertToBBOS set.  If you wish to execute anyway, re-execute specifying /Reset=true");
                        Console.WriteLine("Terminating execution.");
                        Console.ForegroundColor = ConsoleColor.Gray;
                        return;
                    }
                }                    
               
                //Console.WriteLine(szSQL);
                IDbCommand oSelectCommand = oConn.CreateCommand();
                oSelectCommand.CommandText = szSQL;
                oSelectCommand.CommandType = CommandType.Text;

                oReader = oSelectCommand.ExecuteReader();
                while (oReader.Read()) {
                    iCompanyCount++;                
                   
                    int iMaxUsers = oReader.GetInt32(3) + oReader.GetInt32(4);
                    string szUpdateSQL = string.Format(SQL_UPDATE_COMPANY, iMaxUsers, oReader["prse_CompanyID"]);

                    IDbCommand oUpdateCommand = oUpdateConn.CreateCommand();
                    oUpdateCommand.CommandText = szUpdateSQL;
                    oUpdateCommand.CommandType = CommandType.Text;
                    int iConvertedUsers = oUpdateCommand.ExecuteNonQuery();

                    Console.WriteLine("Converted {0} - {1}: Granted Access to {2} Persons", oReader["prse_CompanyID"], oReader["comp_Name"], iConvertedUsers);
                    iConvertedUserCount += iConvertedUsers;
                    
                    string szExtraLicenses = string.Empty;
                    if (iConvertedUsers < (oReader.GetInt32(3) + oReader.GetInt32(4))) {
                        szExtraLicenses = "Y";
                    }

                    string szNeedAdditionalLicenses = string.Empty;
                    if ((oReader.GetInt32(3) + oReader.GetInt32(4)) < oReader.GetInt32(7)) {
                        szNeedAdditionalLicenses = "Y";
                    }
                    
                    object[] args = {oReader[0],
                                    oReader[1],
                                    oReader[2],
                                    oReader[3],
                                    oReader[4],
                                    oReader[5],
                                    oReader[6],
                                    oReader[7],
                                    oReader[8],
                                    iConvertedUsers,
                                    szExtraLicenses,
                                    szNeedAdditionalLicenses};

                    oOutputFile.WriteLine("{0};{1};{2};{3};{4};{5};{6};{7};{8};{9};{10};{11}", args);
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

                if (oOutputFile != null) {
                    oOutputFile.Close();
                }
            }

            Console.WriteLine("Converted " + iCompanyCount.ToString("###,##0") + " Companies");
            Console.WriteLine("Converted " + iConvertedUserCount.ToString("###,##0") + " Persons");
            
            if (iCompanyCount > 0) {
                Console.WriteLine("Output Log File for MS Excel Import: " +_szFullPath);                
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
            Console.WriteLine("/Top=          Convert the top N listed companies.");
            Console.WriteLine("/Config        Convert those companies specified in the configuration file.");
            Console.WriteLine("/CompanyID=    Convert only the specified company.");
            Console.WriteLine(string.Empty);
            Console.WriteLine("/OutputDir=    The fully qualified directory to write the output to.");
            Console.WriteLine("/Reset         Resets the BBOS Conversion Flag to NULL prior to setting it for the specified companies.");
            Console.WriteLine("/Help          This help message");
        }

    }
}
