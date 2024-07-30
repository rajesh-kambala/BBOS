using System;
using System.Configuration;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;

using CommandLine.Utility;

namespace PRCo.BBOS.BBOSConversion {
    class BBOSConverter {
    
        protected string _szFullPath;

        public void ConvertMembers(string[] args) {

            Console.Clear();
            Console.Title = "BBOS Conversion Utility";
            Console.WriteLine("BBOS Conversion Utility 1.0");
            Console.WriteLine("Copyright (c) 2007-" + DateTime.Now.Year.ToString() + " Produce Reporter Co.");
            Console.WriteLine("All Rights Reserved.");
            Console.WriteLine("  OS Version: " + System.Environment.OSVersion.ToString());
            Console.WriteLine(" CLR Version: " + System.Environment.Version.ToString());
            Console.WriteLine();


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
                _szFullPath = Path.Combine(szRootPath, "BBOSConversion.txt");
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

            } else if (oCommandLine["HQID"] != null) {
                int iCompanyID = 0;
                if (!int.TryParse(oCommandLine["HQID"], out iCompanyID)) {
                    Console.WriteLine("ERROR: Invalid /HQID parameter specified.");
                    return;
                }

                szCompanyIDs = iCompanyID.ToString();
            }

            ExecuteConversion(iTop, szCompanyIDs);
        }

        protected const string SQL_SELECT_ENTERPRISE = "SELECT {0} DISTINCT prse_HQID, comp_Name " +
                                                         "FROM PRService " +
                                                              "INNER JOIN Company on prse_HQID = comp_CompanyID " +
                                                        "WHERE prse_Primary = 'Y' " +
                                                          "AND prse_CancelCode IS NULL " +
                                                          "AND prse_HQID NOT IN (SELECT DISTINCT prwu_HQID FROM PRWebUser) " +
                                                          "{1}" +
                                                        "ORDER BY prse_HQID, comp_Name;";

        protected const string SQL_SELECT_SERVICES = "SELECT prse_ServiceID, prse_ServiceCode, prod_PRWebAccessLevel, prod_PRWebUsers, prse_Primary " +
                                                       "FROM PRService " +
                                                            "INNER JOIN NewProduct on prse_ServiceCode = prod_code " +
                                                      "WHERE prod_PRWebAccess = 'Y' " +
                                                        "AND prse_HQID = {0} " +
                                                        "AND prse_CancelCode IS NULL " +
                                                   "ORDER BY prse_Primary DESC";
                                                   
        protected const string SQL_SELECT_PERSON_LINK = "SELECT peli_PersonLinkID " +
                                                          "FROM Person_Link " +
                                                         "WHERE peli_CompanyID IN (SELECT comp_CompanyID FROM Company WHERE comp_PRHQID={0}) " +
                                                           "AND peli_PRConvertToBBOS = 'Y' " +
                                                           "AND peli_PRStatus IN (1,2) " +
                                                      "ORDER BY peli_PersonLinkID ";
                                                    

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
                szFilterClause = "AND prse_HQID IN (" + szHQIDs + ")";
            }

            string szSQL = string.Format(SQL_SELECT_ENTERPRISE, szTopClause, szFilterClause);

            IDbConnection oConn = new SqlConnection(ConfigurationManager.AppSettings["ConnectionString"]);
            IDataReader oReader = null;
            List<Int32> lHQIDs = new List<int>();

            StreamWriter oOutputFile = null;
            try {
                oConn.Open();
                            
                // Go get a list of the enterprises we need
                // to convert.
                IDbCommand oEnterpriseCommand = oConn.CreateCommand();
                oEnterpriseCommand.CommandText = szSQL;
                oReader = oEnterpriseCommand.ExecuteReader();
                try {
                    while (oReader.Read()) {
                        lHQIDs.Add(oReader.GetInt32(0));                            
                    }
                } finally {
                    if (oReader != null) {
                        oReader.Close();
                    }
                }

                if (File.Exists(_szFullPath)) {
                    File.Delete(_szFullPath);
                }

                oOutputFile = new StreamWriter(_szFullPath);
                oOutputFile.WriteLine("HQID;License Count;Converted User Count");
                

                foreach(int iHQID in lHQIDs) {

                    Console.Write("Converting " + iHQID.ToString() + ": ");

                    List<PRCoService> lServices = new List<PRCoService>();
                    int iMaxWebUsers = 0;

                    // Now figure out what services we have
                    IDbCommand oServiceCommand = oConn.CreateCommand();
                    oServiceCommand.CommandText = string.Format(SQL_SELECT_SERVICES, iHQID);
                    oServiceCommand.CommandTimeout = 300;
                    oReader = oServiceCommand.ExecuteReader();
                    try {
                        while (oReader.Read()) {
                            PRCoService oService = new PRCoService();
                            oService.ServiceID = oReader.GetInt32(0);
                            oService.AccessLevel = oReader.GetInt32(2);
                            oService.WebUsers = oReader.GetInt32(3);
                            lServices.Add(oService);
                            
                            iMaxWebUsers += oService.WebUsers;
                        }
                    } finally {
                        if (oReader != null) {
                            oReader.Close();
                        }
                    }


                    // Now figure out what person_link records we need to convert
                    List<Int32> lPersonLinkIDs = new List<int>();
                    IDbCommand oPersonLinkCommand = oConn.CreateCommand();
                    oPersonLinkCommand.CommandText = string.Format(SQL_SELECT_PERSON_LINK, iHQID);
                    oPersonLinkCommand.CommandTimeout = 300;
                    oReader = oPersonLinkCommand.ExecuteReader();
                    try {
                        while (oReader.Read()) {
                            lPersonLinkIDs.Add(oReader.GetInt32(0));
                        }
                    } finally {
                        if (oReader != null) {
                            oReader.Close();
                        }
                    }                

                    int iOffset = 0;
                    int iHQPersonCount = 0;
                    bool bBreak = false;
                    foreach(PRCoService oService in lServices) {
                        for (int i=0; i<oService.WebUsers; i++) {
                
                            if ((i + iOffset) >= lPersonLinkIDs.Count) {
                                bBreak = true;
                                break;
                            }
    
                            SqlCommand oConvertCommand = (SqlCommand)oConn.CreateCommand();
                            oConvertCommand.CommandText = "usp_ConvertPersonLinkToBBOS";
                            oConvertCommand.CommandType = CommandType.StoredProcedure;
                            oConvertCommand.CommandTimeout = 300;
                            oConvertCommand.Parameters.AddWithValue("PersonLinkID", lPersonLinkIDs[i + iOffset]);
                            oConvertCommand.Parameters.AddWithValue("AccessLevel ", oService.AccessLevel);
                            oConvertCommand.Parameters.AddWithValue("ServiceID", oService.ServiceID);
                            
                            SqlTransaction oTran = (SqlTransaction)oConn.BeginTransaction();
                            try {
                                oConvertCommand.Transaction = oTran;
                                oConvertCommand.ExecuteNonQuery();
                                oTran.Commit();
                            } catch {
                                oTran.Rollback();
                                throw;
                            }
                            
                            iConvertedUserCount++;
                            iHQPersonCount++;
                        }
                        
                        if (bBreak) {
                            break;
                        }
                        
                        iOffset += oService.WebUsers;
                    }
                    
                    iHQCount++;

                    Console.WriteLine(" Found " + iMaxWebUsers.ToString() + " licenses.  Converted " + iHQPersonCount.ToString() + " associated persons.");
                    oOutputFile.WriteLine(iHQID.ToString() + ";" + iMaxWebUsers.ToString() + ";" + iHQPersonCount.ToString());
                }


            } catch (Exception e) {
                Console.WriteLine();
                Console.WriteLine();
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine("An unexpected exception occurred: " + e.Message);
                Console.WriteLine("Terminating execution.");
                Console.ForegroundColor = ConsoleColor.Gray;
            } finally {

                if (oConn != null) {
                    oConn.Close();
                }

                if (oOutputFile != null) {
                    oOutputFile.Close();
                }
            }

            Console.WriteLine();
            Console.WriteLine("Converted " + iHQCount.ToString("###,##0") + " Enterprises");
            Console.WriteLine("Converted " + iConvertedUserCount.ToString("###,##0") + " Persons");
            Console.WriteLine("Execution Time: " + DateTime.Now.Subtract(dtStart).ToString());
        }        

        /// <summary>
        /// Displays the application help message
        /// </summary>
        protected void DisplayHelp() {
            Console.WriteLine(string.Empty);
            Console.WriteLine("BBOS Conversion Utility");
            Console.WriteLine("/All           Convert all enterprises.");
            Console.WriteLine("/Top=          Convert the top N enterprises.");
            Console.WriteLine("/Config        Convert those enterprises specified in the configuration file.");
            Console.WriteLine("/HQID=        Convert only the specified enterprise.");
            Console.WriteLine(string.Empty);
            Console.WriteLine("/Help          This help message");
        }

        protected class PRCoService {
            public int ServiceID;
            public int AccessLevel;
            public int WebUsers;
        }

    }
}
