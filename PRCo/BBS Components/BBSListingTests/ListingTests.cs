/***********************************************************************
 Copyright Produce Reporter Company 2007

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: ListingTests.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.IO;

using CommandLine.Utility;

namespace PRCo.BBS.QA {

    /// <summary>
    /// Queries for all listed companies in the test source and compares the generated listing
    /// from a control source to the generated listing in the test source.  If not identical,
    /// an HTML file is created with the listings side-by-side.
    /// </summary>
    public class ListingTests {

        IDbConnection connTest = null;
        IDbConnection connControl = null;

        string _szFullPath = null;
        List<string> lErrorFiles = null;
        
        bool _bVerboseOutput = false;
        
        int _iErrorCount = 0;
        int _iMaxErrors = Int32.MaxValue;
        int _iMaxDiff = Int32.MaxValue;
        int _iCompareCount = 0;
        
        private const string SQL_SELECT_LISTING = "SELECT {0} comp_CompanyID FROM Company WHERE comp_PRListingStatus = 'L' {1} ORDER BY comp_CompanyID";
        public void CompareListings(string[] args) {

            Console.WriteLine("BBS CRM Listing Comparer 1.0");
            Console.WriteLine("Copyright (c) 2007-" + DateTime.Now.Year.ToString() + " Produce Reporter Co.");
            Console.WriteLine("All Rights Reserved.");
            Console.WriteLine("  OS Version: " + System.Environment.OSVersion.ToString());
            Console.WriteLine(" CLR Version: " + System.Environment.Version.ToString());

            if (args.Length == 0) {
                DisplayHelp();
                return;
            }

            string szSQL = null;

            // Command line parsing
            Arguments oCommandLine = new Arguments(args);

            if ((oCommandLine["help"] != null) ||
                (oCommandLine["?"] != null)) {
                DisplayHelp();
                return;
            }
        
            if (oCommandLine["All"] != null) {
                szSQL = string.Format(SQL_SELECT_LISTING, string.Empty, string.Empty);
            
            } else if (oCommandLine["Top"] != null) {
                int iTop = 0;
                if (!int.TryParse(oCommandLine["Top"], out iTop)) {
                    Console.WriteLine("ERROR: Invalid /Top parameter specified.");
                    return;
                }

                szSQL = string.Format(SQL_SELECT_LISTING, " TOP " + iTop.ToString() + " ", string.Empty);
            
            } else if (oCommandLine["Config"] != null) {
                string szCompanyIDs = ConfigurationManager.AppSettings["CompanyIDList"];
                szSQL = string.Format(SQL_SELECT_LISTING, string.Empty, " AND comp_CompanyID IN (" + szCompanyIDs + ")");
            
            } else if (oCommandLine["CompanyID"] != null) {
                int iCompanyID = 0;
                if (!int.TryParse(oCommandLine["CompanyID"], out iCompanyID)) {
                    Console.WriteLine("ERROR: Invalid /CompanyID parameter specified.");
                    return;
                }

                szSQL = string.Format(SQL_SELECT_LISTING, string.Empty, " AND comp_CompanyID=" + iCompanyID.ToString());
            }


            if (oCommandLine["OutputDir"] != null) {
                _szFullPath = oCommandLine["OutputDir"];
            } else {
                string szResultsPath = DateTime.Now.ToString("yyyyMMdd_HHmmss") + @"\";
                string szRootPath = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Substring(6);
                _szFullPath = Path.Combine(szRootPath, szResultsPath);
            }

            if (!Directory.Exists(_szFullPath)) {
                Directory.CreateDirectory(_szFullPath);
            }
        
            if (oCommandLine["Verbose"] != null) {
                _bVerboseOutput = true;
            }

            if (!string.IsNullOrEmpty(ConfigurationManager.AppSettings["MaxErrors"])) {
                if (!int.TryParse(ConfigurationManager.AppSettings["MaxErrors"], out _iMaxErrors)) {
                    Console.WriteLine("ERROR: Invalid MaxErrors configuration value found.");
                    return;
                }
            }

            if (!string.IsNullOrEmpty(ConfigurationManager.AppSettings["MaxDifferences"])) {
                if (!int.TryParse(ConfigurationManager.AppSettings["MaxDifferences"], out _iMaxDiff)) {
                    Console.WriteLine("ERROR: Invalid MaxDifferences configuration value found.");
                    return;
                }
            }



        
            DateTime dtStart = DateTime.Now;
        
            connTest = new SqlConnection(ConfigurationManager.AppSettings["TestConnectionString"]);
            connControl = new SqlConnection(ConfigurationManager.AppSettings["ControlConnectionString"]);

            List<int> _lTestCompanyIDs = new List<int>();
            IDataReader oReader = null;
            
            try {
                connTest.Open();
                IDbCommand oTestCommand = connTest.CreateCommand();
                oTestCommand.CommandText = szSQL;
                oTestCommand.CommandType = CommandType.Text;

                oReader = oTestCommand.ExecuteReader();
                while (oReader.Read()) {
                    _lTestCompanyIDs.Add(oReader.GetInt32(0));
                }
            
            } finally {
                if (oReader != null) {
                    oReader.Close();
                }

                if (connTest != null) {
                    connTest.Close();
                }
            }


            Console.WriteLine("Found " + _lTestCompanyIDs.Count.ToString("###,##0") + " listed companies in test.");
            lErrorFiles = new List<string>();

            try {
                connTest.Open();
                connControl.Open();

                foreach(int iTestCompanyID in _lTestCompanyIDs) {
                    CompareListings(iTestCompanyID);
                    _iCompareCount++;

                    if (lErrorFiles.Count >= _iMaxDiff) {
                        Console.WriteLine("Maximum configured error count exceeded.");
                        break;
                    }
                }

                DateTime dtEnd = DateTime.Now;
                TimeSpan tsDiff = dtEnd.Subtract(dtStart);

                Console.WriteLine();
                Console.WriteLine(_iCompareCount.ToString("###,##0") + " listings compared.");
                Console.WriteLine(lErrorFiles.Count.ToString("###,##0") + " differences found.");

                if (lErrorFiles.Count > 0) {
                    using (StreamWriter sw = new StreamWriter(Path.Combine(_szFullPath, "BBSCompareListings.html"))) {
                        sw.WriteLine("<html><body>");
                        sw.WriteLine("<H2>BBS CRM Listing Test Failures</H2>");
                        sw.WriteLine("<table>");
                        sw.WriteLine("<tr><td><b>Execution Date/Time:</b></td><td>" + DateTime.Now.ToShortDateString() + " " + DateTime.Now.ToShortTimeString() + "</td></tr>");
                        sw.WriteLine("<tr><td><b>Listings Found:</b></td><td>" + _lTestCompanyIDs.Count.ToString("###,##0") + "</td></tr>");
                        sw.WriteLine("<tr><td><b>Listings Compared:</b></td><td>" + _iCompareCount.ToString("###,##0") + "</td></tr>");
                        sw.WriteLine("<tr><td><b>Differences Found:</b></td><td>" + lErrorFiles.Count.ToString("###,##0") + "</td></tr>");
                        sw.WriteLine("<tr><td><b>Control:</b></td><td>" + connControl.ConnectionString + "</td></tr>");
                        sw.WriteLine("<tr><td><b>Test:</b></td><td>" + connTest.ConnectionString + "</td></tr>");
                        sw.WriteLine("<tr><td><b>Execution Duration:</b></td><td>" + tsDiff.ToString() + "</td></tr>");
                        sw.WriteLine("</table>");
                        sw.WriteLine("<p>");

                        sw.WriteLine("<b>Listings with Differences:</b>");
                        sw.WriteLine("<ul>");
                        foreach(string szFileName in lErrorFiles) {
                            sw.WriteLine("<li><a href=\"{0}\">{0}</a>", szFileName);
                        }
            
                        sw.WriteLine("</ul>");
                        sw.WriteLine("</body></html>");
                    }
                    
                    
                    if ((!string.IsNullOrEmpty(ConfigurationManager.AppSettings["LaunchBrowserOnError"])) &&
                        (ConfigurationManager.AppSettings["LaunchBrowserOnError"].ToLower() == "true")) {
                        System.Diagnostics.Process.Start(Path.Combine(_szFullPath, "BBSCompareListings.html")); 
                    }
                }
            } catch (Exception e) {
                Console.WriteLine();
                Console.ForegroundColor = ConsoleColor.Yellow;
                Console.WriteLine("An unexpected exception occurred: " + e.Message);
                Console.WriteLine("Terminating execution.");
                Console.ForegroundColor = ConsoleColor.Gray;
            } finally {
                if (connControl != null) {
                    connControl.Close();
                }

                if (connTest != null) {
                    connTest.Close();
                }
            }
              
        }

        protected const string SQL_GET_LISTING = "SELECT dbo.ufn_GetListingFromCompany({0}, 2, 0)";
        
        /// <summary>
        /// Compares the listing in the test and control data sources
        /// for the specified company 
        /// </summary>
        /// <param name="iCompanyID"></param>
        protected void CompareListings(int iCompanyID) {
            string szDatabaseName = string.Empty;
            
            try {
                string szSQL = string.Format(SQL_GET_LISTING, iCompanyID);

                
                IDbCommand oTestCommand = connTest.CreateCommand();
                oTestCommand.CommandText = szSQL;
                oTestCommand.CommandType = CommandType.Text;
                szDatabaseName = "Test";
                string szTestListing = (string)oTestCommand.ExecuteScalar();
                szDatabaseName = string.Empty;
                
                IDbCommand oControlCommand = connControl.CreateCommand();
                oControlCommand.CommandText = szSQL;
                oControlCommand.CommandType = CommandType.Text;
                szDatabaseName = "Control";
                string szControlListing = (string)oControlCommand.ExecuteScalar();
                szDatabaseName = string.Empty;
                
                
                
                bool bSame = true;
                if (szControlListing.Length != szTestListing.Length) {
                    bSame = false;
                } else {
                    if (szControlListing != szTestListing) {
                        bSame = false;
                    }
                }
                
                if (bSame) {
                
                    if (_bVerboseOutput) {
                        Console.Write("Comparing Company ID " + iCompanyID.ToString() + ": ");
                        Console.ForegroundColor = ConsoleColor.Green;
                        Console.WriteLine(" Passed.");
                    }
                } else {
                    string szFileName = iCompanyID.ToString() + ".html";
                    lErrorFiles.Add(szFileName);

                    using (StreamWriter sw = new StreamWriter(Path.Combine(_szFullPath, szFileName))) {
                        object[] args = {szControlListing,
                                         szTestListing,
                                         iCompanyID,
                                         GetLineNumbers()};
                        sw.WriteLine(szHTMLFormat, args);
                    }

                    Console.Write("Comparing Company ID " + iCompanyID.ToString() + ": ");
                    Console.ForegroundColor = ConsoleColor.Red;
                    Console.WriteLine(" Failed.");
                }
            } catch (Exception e) {
                _iErrorCount++;
                if (_iErrorCount >= _iMaxErrors) {
                    throw e;
                }

                Console.Write("Comparing Company ID " + iCompanyID.ToString() + ": ");
                Console.ForegroundColor = ConsoleColor.Yellow;

                string szMsg = string.Empty;
                if (e is SqlException) {
                    SqlException eSQL = (SqlException)e;
                    szMsg = " from the " + szDatabaseName + " database on " + eSQL.Server;
                }

                Console.WriteLine( " Exception" + szMsg + ": " + e.Message);
                
                
            } finally {
                Console.ForegroundColor = ConsoleColor.Gray;
            }
        }

        protected string _szLineNumbers = null;
        protected string GetLineNumbers() {
            if (_szLineNumbers == null) {
                for(int i=1; i<=150; i++) {
                    _szLineNumbers = _szLineNumbers + i.ToString() + Environment.NewLine;
                }
            }
        
            return _szLineNumbers;
        
        }

        protected const string szHTMLFormat = "<html><body><h2>CompanyID: {2}</h2><table><tr><td></td><td align=center><b>Control</b></td><td align=center><b>Test</b></td></tr> <tr><td></td><td><pre>1234567890123456789012345678901234567890</pre></td> <td><pre>1234567890123456789012345678901234567890</pre></td></tr> <tr><td valign=top align=right><pre>{3}</pre></td><td valign=top style=border:inset;><pre>{0}</pre></td><td valign=top style=border:inset;><pre>{1}</pre></td></tr></table></body></html>";

        /// <summary>
        /// Displays the application help message
        /// </summary>
        protected void DisplayHelp() {
            Console.WriteLine(string.Empty);
            Console.WriteLine("BBS CRM Listing Comparer");
            Console.WriteLine("The following options are mutually exclusive and are processed in the order below:");
            Console.WriteLine("/All           Compare all listed companies.");
            Console.WriteLine("/Top=          Compare the top N listed companies.");
            Console.WriteLine("/Config        Compare those companies specified in the configuration file.");
            Console.WriteLine("/CompanyID=    Compare only the specified company.");            
            Console.WriteLine(string.Empty);
            Console.WriteLine("/OutputDir=    The fully qualified directory to write any failure output to.");
            Console.WriteLine("/Verbose       Write a message for each company being tested.  Otherwise only those that failed will be written.");
            Console.WriteLine("/Help          This help message");            
        }

    }
}
