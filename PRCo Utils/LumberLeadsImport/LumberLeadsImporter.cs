using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.OleDb;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Net.Mail;
using System.Net;
using System.Text;


using CommandLine.Utility;

namespace LumberLeadsImport
{
    class LumberLeadsImporter
    {
        protected const string DELIMITER = "\t";

        protected string _szFileID = null;
 
        protected List<string> _lszOutputBuffer = new List<string>();
        protected List<string> _lszSkippedBuffer = new List<string>();
        protected List<string> _lszTranslateBuffer = new List<string>();

        protected List<string> _lszMatchedClosedLeads = new List<string>();

        protected SqlConnection _dbConn = null;
        protected SqlConnection _dbLeadsConn = null;

        protected int _iLeadCount = 0;
        protected int _iMatchCount = 0;
        protected int _iInsertedCount = 0;
        protected int _iUpdatedCount = 0;
        protected int _iSkippedCount = 0;
        protected int iResultCount = 0;

        public void Import(string[] args)
        {
            Console.Clear();
            Console.Title = "Lumber Leads Import Utility";
            WriteLine("Lumber Leads Import Utility 1.2");
            WriteLine("Copyright (c) 2009-2017 Blue Book Services, Inc.");
            WriteLine("All Rights Reserved.");
            WriteLine("  OS Version: " + System.Environment.OSVersion.ToString());
            WriteLine(" CLR Version: " + System.Environment.Version.ToString());
            WriteLine(string.Empty);

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


            if (oCommandLine["File"] != null)
            {
                if (!File.Exists(oCommandLine["File"]))
                {
                    WriteLine("FILE NOT FOUND: " + oCommandLine["File"]);
                    return;
                }
            }


            try
            {
                switch (oCommandLine["Type"]) {
                    case "UAR":
                        ImportUnmatchedAR();
                        break;
                    case "CL":
                        ImportConnectionList(oCommandLine["File"]);
                        break;
                    case "RB":
                        ImportRedBook(oCommandLine["File"]);
                        break;
                    case "EN":
                        EnumerateWorksheets(oCommandLine["File"]);
                        break;
                }
             
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

                string errMsg = e.Message + Environment.NewLine + Environment.NewLine + e.StackTrace;

                SendMail("supportbbos@bluebookservices.com",
                         "bluebookservices@bluebookservices.com",
                         "LumberLeadsImporter Exception",
                         errMsg,
                         false);

            }
        }


        #region Redbook Methods
        protected const string SQL_SELECT_REDBOOK =
            //"SELECT State, City, [Main Company name], Description, Rating, [Alternate Company Name], [First Address Line 1], [First Address Line 2], [First Address City], [First Address State], [First Address Zip], [Second Address Line 1], [Second Address Line 2], [Second Address City], [Second Address State], [Second Address Zip], [Misc Info], Phone, FAX " +
            "SELECT * " +
             "FROM [Redbook$]";

        protected void ImportRedBook(string szFileName)
        {

            DateTime dtStart = DateTime.Now;

            _szFileID = "Redbook_" + dtStart.ToString("yyyyMMdd_HHmmss") + "_";

            WriteLine("Importing Redbook File " + szFileName);

            _dbConn = new SqlConnection(ConfigurationManager.ConnectionStrings["CRM"].ConnectionString);
            _dbLeadsConn = new SqlConnection(ConfigurationManager.ConnectionStrings["LumberLeads"].ConnectionString);

            OleDbConnection msExcelConn = new OleDbConnection("Provider=Microsoft.Jet.OLEDB.4.0;" +
                                                             "Data Source=" + szFileName + ";" +
                                                             "Extended Properties=\"Excel 8.0;HDR=Yes\"");

            try
            {
                _dbConn.Open();
                _dbLeadsConn.Open();
                msExcelConn.Open();

                OleDbCommand cmdRedbook = msExcelConn.CreateCommand();
                cmdRedbook.CommandText = SQL_SELECT_REDBOOK;

                using (IDataReader drRedbook = cmdRedbook.ExecuteReader())
                {
                    while (drRedbook.Read())
                    {
                        Lead oLead = new Lead();
                        oLead.Source = "Redbook";

                        oLead.CompanyName = TranslateName(GetValue(drRedbook, "Main Company name"));
                        oLead.OriginalRedBookName = GetValue(drRedbook, "Main Company name");
                        oLead.AlternateName  = GetValue(drRedbook, "Alternate Company Name");

                        oLead.ListingCity    = GetValue(drRedbook, "City");
                        oLead.ListingState   = GetValue(drRedbook, "State");

                        oLead.FirstAddress1  = GetValue(drRedbook, "First Address Line 1");
                        oLead.FirstAddress2  = GetValue(drRedbook, "First Address Line 2");
                        oLead.FirstCity      = GetValue(drRedbook, "First Address City");
                        oLead.FirstState     = GetValue(drRedbook, "First Address State");
                        oLead.FirstPostCode  = GetValue(drRedbook, "First Address Zip");

                        oLead.SecondAddress1 = GetValue(drRedbook, "Second Address Line 1");
                        oLead.SecondAddress2 = GetValue(drRedbook, "Second Address Line 2");
                        oLead.SecondCity     = GetValue(drRedbook, "Second Address City");
                        oLead.SecondState    = GetValue(drRedbook, "Second Address State");
                        oLead.SecondPostCode = GetValue(drRedbook, "Second Address Zip");

                        oLead.PhoneNumber    = GetValue(drRedbook, "Phone");
                        oLead.FaxNumber      = GetValue(drRedbook, "Fax");

                        oLead.Rating         = GetValue(drRedbook, "Rating");
                        oLead.MiscInfo       = GetValue(drRedbook, "Misc Info");

                        oLead.Description    = GetValue(drRedbook, "Description");

                        _iLeadCount++;
                        Write("Processing " + oLead.CompanyName);

                        if (FindCRMMatch(oLead))
                        {

                            WriteLine(" - Skipped because found CRM");
                            _iSkippedCount++;
                            //InsertRedbookSkipped(oLead);
                            InsertRedbookSkipped2(oLead);
                            /*
                                                        _lszSkippedBuffer.Add(oLead.AssociatedCompanyID.ToString() + DELIMITER +
                                                                              oLead.ListingStatus + DELIMITER +
                                                                              oLead.MatchType + DELIMITER +
                                                                              oLead.CompanyName + DELIMITER +
                                                                              oLead.ListingCity + DELIMITER +
                                                                              oLead.ListingState + DELIMITER +
                                                                              oLead.Rating);
                            */
                        }
                        else
                        {
                            WriteLine(string.Empty);
                        }
                        
                        //else
                        //{
                        //    WriteLine(" - Inserting");
                        //    // Find out if it's matched to anything first
                        //    bool bMatched = FindMatchingLead(oLead);
                        //    if (bMatched)
                        //    {
                        //        _iMatchCount++;
                        //    }

                        //    _iInsertedCount++;
                        //    InsertLead(oLead);
                        //    InsertBatch(oLead);

                        //}
                    }
                }
            }
            catch (Exception e)
            {
                WriteLine(string.Empty);
                WriteLine(string.Empty);
                WriteLine(e.Message);
                WriteLine(e.StackTrace);

                throw;
            }

            finally
            {
                _dbConn.Close();
                msExcelConn.Close();
                _dbLeadsConn.Close();

                WriteLine(string.Empty);
                WriteLine(string.Empty);
                WriteLine("    Lead Count: " + _iLeadCount.ToString("###,##0"));
                //WriteLine("  Insert Count: " + _iInsertedCount.ToString("###,##0"));
                //WriteLine("   Match Count: " + _iMatchCount.ToString("###,##0"));
                WriteLine(" Skipped Count: " + _iSkippedCount.ToString("###,##0"));
                WriteLine(string.Empty);
                WriteLine("Execution Time: " + DateTime.Now.Subtract(dtStart).ToString());

                string szOutputDirectory = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Substring(6);
                string szOutputFile = Path.Combine(szOutputDirectory, _szFileID + "Log.txt");

                using (StreamWriter sw = new StreamWriter(szOutputFile))
                {
                    foreach (string szLine in _lszOutputBuffer)
                    {
                        sw.WriteLine(szLine);
                    }
                }


                szOutputFile = Path.Combine(szOutputDirectory, _szFileID + "Translated.txt");
                using (StreamWriter sw = new StreamWriter(szOutputFile))
                {
                    sw.WriteLine("Redbook Name" + DELIMITER + "Translated Name");
                    foreach (string szLine in _lszTranslateBuffer)
                    {
                        sw.WriteLine(szLine);
                    }
                }

/*
                szOutputFile = Path.Combine(szOutputDirectory, _szFileID + "Skipped.txt");
                using (StreamWriter sw = new StreamWriter(szOutputFile))
                {
                    sw.WriteLine("BB ID" + DELIMITER + "Listing Status" + DELIMITER + "Match Type" + DELIMITER + "Redbook Name" + DELIMITER + "Redbook City" + DELIMITER + "Redbook State" + DELIMITER + "Redbook Rating");
                    foreach (string szLine in _lszSkippedBuffer)
                    {
                        sw.WriteLine(szLine);
                    }
                }
 */
            }
        }

        private const string SQL_MATCH_CRM_PHONE =
            "SELECT phon_CompanyID, comp_PRListingStatus FROM Phone WITH (NOLOCK) INNER JOIN Company WITH (NOLOCK) ON phon_CompanyID = comp_CompanyID WHERE comp_PRIndustryType = 'L' AND phon_PersonID IS NULL AND (phon_PhoneMatch = dbo.ufn_GetLowerAlpha(@Phone) OR phon_PhoneMatch = dbo.ufn_GetLowerAlpha(@Fax))";

        private const string SQL_MATCH_CRM_NAME =
            "SELECT comp_CompanyID, comp_PRListingStatus FROM Company WITH (NOLOCK) INNER JOIN PRCompanySearch WITH (NOLOCK) ON comp_CompanyID = prcse_CompanyId WHERE comp_PRIndustryType = 'L' AND (prcse_NameAlphaOnly = dbo.ufn_GetLowerAlpha(@Name) OR comp_PRLegalName = dbo.ufn_GetLowerAlpha(@Name))";

        private SqlCommand cmdCRMPhoneMatch = null;
        private SqlCommand cmdCRMNameMatch = null;

        protected bool FindCRMMatch(Lead oLead)
        {
            if (cmdCRMPhoneMatch == null)
            {
                cmdCRMPhoneMatch = _dbConn.CreateCommand();
                cmdCRMPhoneMatch.CommandText = SQL_MATCH_CRM_PHONE;
            }
            
            cmdCRMPhoneMatch.Parameters.Clear();
            AddParameter(cmdCRMPhoneMatch, "Phone", oLead.PhoneNumber);
            AddParameter(cmdCRMPhoneMatch, "Fax", oLead.FaxNumber);

            using (IDataReader drCRMPhoneMatch = cmdCRMPhoneMatch.ExecuteReader())
            {
                if (drCRMPhoneMatch.Read())
                {
                    oLead.ExistsInCRM = true;
                    oLead.MatchType = "Phone";
                    oLead.AssociatedCompanyID = drCRMPhoneMatch.GetInt32(0);
                    oLead.ListingStatus = drCRMPhoneMatch.GetString(1);

                    return true;
                }
            }


            if (cmdCRMNameMatch == null)
            {
                cmdCRMNameMatch = _dbConn.CreateCommand();
                cmdCRMNameMatch.CommandText = SQL_MATCH_CRM_NAME;
            }
              
            cmdCRMNameMatch.Parameters.Clear();
            AddParameter(cmdCRMNameMatch, "Name", oLead.CompanyName);

            using (IDataReader drCRMNameMatch = cmdCRMNameMatch.ExecuteReader())
            {
                if (drCRMNameMatch.Read())
                {
                    oLead.ExistsInCRM = true;
                    oLead.MatchType = "Name";
                    oLead.AssociatedCompanyID = drCRMNameMatch.GetInt32(0);
                    oLead.ListingStatus = drCRMNameMatch.GetString(1);

                    return true;
                }
            }



            return false;
        }


        private const string SQL_REDBOOKSKIPPED_INSERT2 =
            "INSERT INTO RedbookSkipped2 (CompanyID, MatchType, RedbookName, RedbookFirstAddress1, RedbookFirstAddress2, RedbookCity, RedbookState, RedbookPostal, RedbookPhone, RedbookFax, RedbookRating, RedbookMiscInfo) " +
            "VALUES (@CompanyID, @MatchType, @RedbookName, @RedbookFirstAddress1, @RedbookFirstAddress2, @RedbookCity, @RedbookState, @RedbookPostal, @RedbookPhone, @RedbookFax, @RedbookRating, @RedbookMiscInfo); ";

        private SqlCommand cmdInsertRedbookSkipped2;
        protected void InsertRedbookSkipped2(Lead oLead)
        {

            if (cmdInsertRedbookSkipped2 == null)
            {
                cmdInsertRedbookSkipped2 = _dbLeadsConn.CreateCommand();
                cmdInsertRedbookSkipped2.CommandText = SQL_REDBOOKSKIPPED_INSERT2;
            }

            cmdInsertRedbookSkipped2.Parameters.Clear();
            AddParameter(cmdInsertRedbookSkipped2, "CompanyID", oLead.AssociatedCompanyID);
            AddParameter(cmdInsertRedbookSkipped2, "MatchType", oLead.MatchType);
            AddParameter(cmdInsertRedbookSkipped2, "RedbookName", oLead.CompanyName);
            AddParameter(cmdInsertRedbookSkipped2, "RedbookFirstAddress1", oLead.FirstAddress1);
            AddParameter(cmdInsertRedbookSkipped2, "RedbookFirstAddress2", oLead.FirstAddress2);
            AddParameter(cmdInsertRedbookSkipped2, "RedbookCity", oLead.ListingCity);
            AddParameter(cmdInsertRedbookSkipped2, "RedbookState", oLead.ListingState);
            AddParameter(cmdInsertRedbookSkipped2, "RedbookPostal", oLead.FirstPostCode); 
            AddParameter(cmdInsertRedbookSkipped2, "RedbookPhone", oLead.PhoneNumber);
            AddParameter(cmdInsertRedbookSkipped2, "RedbookFax", oLead.FaxNumber);
            AddParameter(cmdInsertRedbookSkipped2, "RedbookRating", oLead.Rating);
            AddParameter(cmdInsertRedbookSkipped2, "RedbookMiscInfo", oLead.MiscInfo);
            cmdInsertRedbookSkipped2.ExecuteNonQuery();
        }


        private const string SQL_REDBOOKSKIPPED_INSERT =
            "INSERT INTO RedbookSkipped (CompanyID, MatchType, RedbookName, RedbookCity, RedbookState, RedbookPhone, RedbookFax, RedbookRating) " +
            "VALUES (@CompanyID, @MatchType, @RedbookName, @RedbookCity, @RedbookState, @RedbookPhone, @RedbookFax, @RedbookRating); ";

        private SqlCommand cmdInsertRedbookSkipped;
        protected void InsertRedbookSkipped(Lead oLead)
        {

            if (cmdInsertRedbookSkipped == null)
            {
                cmdInsertRedbookSkipped = _dbLeadsConn.CreateCommand();
                cmdInsertRedbookSkipped.CommandText = SQL_REDBOOKSKIPPED_INSERT;
            }

            cmdInsertRedbookSkipped.Parameters.Clear();
            AddParameter(cmdInsertRedbookSkipped, "CompanyID",     oLead.AssociatedCompanyID);
            AddParameter(cmdInsertRedbookSkipped, "MatchType",     oLead.MatchType);
            AddParameter(cmdInsertRedbookSkipped, "RedbookName",   oLead.CompanyName);
            AddParameter(cmdInsertRedbookSkipped, "RedbookCity",   oLead.ListingCity);
            AddParameter(cmdInsertRedbookSkipped, "RedbookState",  oLead.ListingState);
            AddParameter(cmdInsertRedbookSkipped, "RedbookPhone",  oLead.PhoneNumber);
            AddParameter(cmdInsertRedbookSkipped, "RedbookFax",    oLead.FaxNumber);
            AddParameter(cmdInsertRedbookSkipped, "RedbookRating", oLead.Rating);
            cmdInsertRedbookSkipped.ExecuteNonQuery();
        }


        protected string TranslateName(string szName)
        {
            string szTemp = szName;

            szTemp = szTemp.Replace(" Agrl ", " Agricultural ");
            szTemp = szTemp.Replace(" Assn ", " Association ");
            szTemp = szTemp.Replace(" Bldg ", " Building ");
            szTemp = szTemp.Replace(" Br ", " Branch ");
            szTemp = szTemp.Replace(" Coll ", " Collector ");
            szTemp = szTemp.Replace(" Coml ", " Commercial ");
            szTemp = szTemp.Replace(" Contr ", " Contractor ");
            szTemp = szTemp.Replace(" Elev ", " Elevator ");
            szTemp = szTemp.Replace(" Est ", " Estate ");
            szTemp = szTemp.Replace(" Exch ", " Exchange ");
            szTemp = szTemp.Replace(" Furn ", " Furniture ");
            szTemp = szTemp.Replace(" Hdwe ", " Hardware ");
            szTemp = szTemp.Replace(" Invest ", " Investment ");
            szTemp = szTemp.Replace(" Lbr ", " Lumber ");
            szTemp = szTemp.Replace(" Machy ", " Machinery ");
            szTemp = szTemp.Replace(" Matl ", " Material ");
            szTemp = szTemp.Replace(" Matls ", " Materials ");
            szTemp = szTemp.Replace(" Merc ", " Mercantile ");
            szTemp = szTemp.Replace(" Mfrs ", " Manufacturers ");
            szTemp = szTemp.Replace(" Mfg ", " Manufacturing ");
            szTemp = szTemp.Replace(" Nat ", " National ");
            szTemp = szTemp.Replace(" Natl ", " National ");
            szTemp = szTemp.Replace(" Par ", " Parish ");
            szTemp = szTemp.Replace(" Pop ", " Population ");
            szTemp = szTemp.Replace(" Purch ", " Purchasing ");
            szTemp = szTemp.Replace(" R R ", " Railroad ");
            szTemp = szTemp.Replace(" Ry ", " Railway ");
            szTemp = szTemp.Replace(" Subsid ", " Subsidiary ");
            szTemp = szTemp.Replace(" Tr ", " Trust ");

            szTemp = szTemp.Replace(" (a Subchapter S Corp)", string.Empty);
            szTemp = szTemp.Replace(" (A Subchapter S Corp)", string.Empty);
            szTemp = szTemp.Replace(" (a Subchyapter S Corp)", string.Empty);

            szTemp = szTemp.Replace(" (not inc)", string.Empty);
            szTemp = szTemp.Replace(" (Not inc)", string.Empty);
            szTemp = szTemp.Replace(" (not Inc)", string.Empty);
            szTemp = szTemp.Replace(" (Not Inc)", string.Empty);

            szTemp = szTemp.Replace(" (no yd here)", string.Empty);
            szTemp = szTemp.Replace(" (Inc)", string.Empty);
            szTemp = szTemp.Replace(" (inc)", string.Empty);

            szTemp = szTemp.Replace(" (LP)", string.Empty);
            szTemp = szTemp.Replace(" (a limited partnership)", string.Empty);
            szTemp = szTemp.Replace(" (a limited  partnership)", string.Empty);
            szTemp = szTemp.Replace(" {a limited partnership)", string.Empty);
            

            if (szName != szTemp)
            {
                _lszTranslateBuffer.Add(szName + DELIMITER + szTemp);
                //WriteLine("Translated " + szName + " to " + szTemp);
            }


            return szTemp;
        }
        #endregion

        #region Connection List Methods 
        protected const string SQL_SELECT_CL =
            "SELECT AssociatedCompanyID, CompanyName, FirstAddress1, FirstAddress2, FirstCity, FirstState, FirstCountry, FirstPostCode, PhoneAreaCode, PhoneNumber, FaxAreaCode, FaxNumber, Email, WebSite " +
             "FROM [Lead$] " +
         "ORDER BY AssociatedCompanyID, CompanyName";


        protected void ImportConnectionList(string szFileName)
        {

            DateTime dtStart = DateTime.Now;
            _szFileID = "ConnectionList_" + dtStart.ToString("yyyyMMdd_HHmmss") + "_";


            WriteLine("Importing Connection List " + szFileName);

            _dbLeadsConn = new SqlConnection(ConfigurationManager.ConnectionStrings["LumberLeads"].ConnectionString);

            OleDbConnection msExcelConn = new OleDbConnection("Provider=Microsoft.Jet.OLEDB.4.0;" +
                                                             "Data Source=" + szFileName + ";" +
                                                             "Extended Properties=\"Excel 8.0;HDR=Yes\"");

            try
            {
                _dbLeadsConn.Open();
                msExcelConn.Open ();

                OleDbCommand cmdConnectionList = msExcelConn.CreateCommand();
                cmdConnectionList.CommandText = SQL_SELECT_CL;

                using (IDataReader drConnectionList = cmdConnectionList.ExecuteReader())
                {
                    while (drConnectionList.Read())
                    {
                        Lead oLead = new Lead();
                        oLead.Source = "Connection List";
                        oLead.AssociatedCompanyID = Convert.ToInt32(drConnectionList["AssociatedCompanyID"]);
                        oLead.CompanyName = GetValue(drConnectionList, "CompanyName");
                        oLead.FirstAddress1 = GetValue(drConnectionList, "FirstAddress1");
                        oLead.FirstAddress2 = GetValue(drConnectionList, "FirstAddress2");
                        oLead.FirstCity = GetValue(drConnectionList, "FirstCity");
                        oLead.FirstState = GetValue(drConnectionList, "FirstState");
                        oLead.FirstPostCode = GetValue(drConnectionList, "FirstPostCode");
                        oLead.Email = GetValue(drConnectionList, "Email");
                        oLead.WebSite = GetValue(drConnectionList, "WebSite");

                        if (drConnectionList["PhoneNumber"] != DBNull.Value) {
                            string szPhone = GetValue(drConnectionList, "PhoneNumber");
                            oLead.PhoneNumber = GetValue(drConnectionList, "PhoneAreaCode");

                            if (szPhone.Contains('-')) {
                                oLead.PhoneNumber += "-";
                            }
                            oLead.PhoneNumber += szPhone;;
                        }

                        if (drConnectionList["FaxNumber"] != DBNull.Value) {
                            string szFax = GetValue(drConnectionList, "FaxNumber");
                            oLead.FaxNumber = GetValue(drConnectionList, "FaxAreaCode");

                            if (szFax.Contains('-')) {
                                oLead.FaxNumber += "-";
                            }
                            oLead.FaxNumber += szFax;;
                        }

                        _iLeadCount++;
                        Write("Submitter BB ID " + oLead.AssociatedCompanyID.ToString() + " for " + oLead.CompanyName);

                        // Find out if it's matched to anything first
                        bool bMatched = FindMatchingLead(oLead);
                        if (bMatched)
                        {
                            _iMatchCount++;
                        }

                        _iInsertedCount++;
                        InsertLead(oLead);
                        InsertBatch(oLead);
                    }                        
                }
            }
            catch (Exception e)
            {
                WriteLine(string.Empty);
                WriteLine(string.Empty);
                WriteLine(e.Message);
                WriteLine(e.StackTrace);

                throw;
            }

            finally
            {
                msExcelConn.Close();
                _dbLeadsConn.Close();

                WriteLine(string.Empty);
                WriteLine(string.Empty);
                WriteLine("    Lead Count: " + _iLeadCount.ToString("###,##0"));
                WriteLine("  Insert Count: " + _iInsertedCount.ToString("###,##0"));
                WriteLine("   Match Count: " + _iMatchCount.ToString("###,##0"));
                WriteLine(string.Empty);
                WriteLine("Execution Time: " + DateTime.Now.Subtract(dtStart).ToString());

                string szOutputDirectory = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Substring(6);
                string szOutputFile = Path.Combine(szOutputDirectory, _szFileID + "Log.txt");

                using (StreamWriter sw = new StreamWriter(szOutputFile))
                {
                    foreach (string szLine in _lszOutputBuffer)
                    {
                        sw.WriteLine(szLine);
                    }
                }

            }
        }
        #endregion

        #region Unmatched AR Methods 
        protected const string SQL_SELECT_UNMATCHED_AR =
            @"SELECT praa_CompanyID, praad_ARCustomerId, praad_FileCompanyName, praad_FileCityName, praad_FileStateName, praad_FileZipCode, 
                     praad_PhoneNumber,                     
                     COUNT(1) As ARDetailCount, MAX(praa_Date) As LastARDate
               FROM Company WITH (NOLOCK) 
                    INNER JOIN PRARAging WITH (NOLOCK) ON comp_CompanyID = praa_CompanyID 
                    INNER JOIN PRARAgingDetail WITH (NOLOCK) ON praa_ARAgingID = praad_ARAgingID 
              WHERE comp_PRIndustryType = 'L' 
                AND praad_CreatedDate >= @LastExecutionDate 
                AND praad_SubjectCompanyID IS NULL
                AND praa_Date IS NOT NULL 
                AND praad_FileCompanyName IS NOT NULL
                AND praad_FileCompanyName <> ''
             GROUP BY praa_CompanyID, praad_ARCustomerId, praad_FileCompanyName, praad_FileCityName, praad_FileStateName, praad_FileZipCode, 
                      praad_PhoneNumber
             ORDER BY praa_CompanyID, praad_FileCompanyName";


        protected void ImportUnmatchedAR()
        {
            DateTime dtStart = DateTime.Now;
            _szFileID = "UnmatchedAR_" + dtStart.ToString("yyyyMMdd_HHmmss") + "_";

            WriteLine("Importing Unmatched AR Aging");

            _dbConn = new SqlConnection(ConfigurationManager.ConnectionStrings["CRM"].ConnectionString);
            _dbLeadsConn = new SqlConnection(ConfigurationManager.ConnectionStrings["LumberLeads"].ConnectionString);

            try
            {
                _dbConn.Open();
                _dbLeadsConn.Open();

                SqlCommand cmdUnmatchedAR = _dbConn.CreateCommand();
                cmdUnmatchedAR.CommandText = SQL_SELECT_UNMATCHED_AR;
                cmdUnmatchedAR.Parameters.AddWithValue("LastExecutionDate", GetARLastExecution());

                using (IDataReader drUnmatchedAR = cmdUnmatchedAR.ExecuteReader())
                {
                    while (drUnmatchedAR.Read())
                    {
                        Lead oLead = new Lead();
                        oLead.Source = "Unmatched AR";
                        oLead.AssociatedCompanyID = Convert.ToInt32(drUnmatchedAR["praa_CompanyID"]);
                        oLead.CustomerNumber = GetValue(drUnmatchedAR, "praad_ARCustomerId");
                        oLead.CompanyName = GetValue(drUnmatchedAR, "praad_FileCompanyName");
                        oLead.PhoneNumber = GetValue(drUnmatchedAR, "praad_PhoneNumber");
                        oLead.FirstCity = GetValue(drUnmatchedAR, "praad_FileCityName");
                        oLead.FirstState = GetValue(drUnmatchedAR, "praad_FileStateName");
                        oLead.FirstPostCode = GetValue(drUnmatchedAR, "praad_FileZipCode");
                        oLead.ARDetailCount = Convert.ToInt32(drUnmatchedAR["ARDetailCount"]);
                        oLead.LastARDate = Convert.ToDateTime(drUnmatchedAR["LastARDate"]);

                        oLead.ValidatePhone();

                        _iLeadCount++;
                        Write("Submitter BB ID " + oLead.AssociatedCompanyID.ToString() + " for " + oLead.CompanyName);

                        // Step 1.
                        // Look to see if we already have a record for this
                        // submitter on this subject.  If so, we want to update
                        // that existing Lead record.
                        FindARMatch(oLead);

                        if (oLead.Exists)
                        {
                            if ((ConfigurationManager.AppSettings["UnmatchedARIngoreExportedForValidation"] != "true") &&
                                (oLead.ExportedForValidation))
                            {
                                WriteLine(" - Skipped because already exported");
                                _iSkippedCount++;
                                _lszSkippedBuffer.Add(oLead.AssociatedCompanyID.ToString() + DELIMITER +
                                                      oLead.CompanyName + DELIMITER +
                                                      oLead.FirstCity + DELIMITER +
                                                      oLead.FirstState + DELIMITER +
                                                      oLead.FirstPostCode + DELIMITER +
                                                      oLead.PhoneNumber + DELIMITER +
                                                      oLead.ARDetailCount);

                            }
                            else
                            {
                                WriteLine(" - Updating");

                                UpdateARLead(oLead);
                                _iUpdatedCount++;

                                if ((oLead.Status == "Closed: Non-Factor") &&
                                    (oLead.StatusChangedBy == "System"))
                                {
                                    _lszMatchedClosedLeads.Add(oLead.AssociatedCompanyID.ToString() + DELIMITER +
                                                          oLead.LeadID.ToString() + DELIMITER +
                                                          oLead.CompanyName + DELIMITER +
                                                          oLead.FirstCity + DELIMITER +
                                                          oLead.FirstState + DELIMITER +
                                                          oLead.FirstPostCode + DELIMITER +
                                                          oLead.PhoneNumber + DELIMITER +
                                                          oLead.ARDetailCount + DELIMITER +
                                                          oLead.StatusChangedBy + DELIMITER +
                                                          oLead.StatusChangedDate);

                                }

                            }
                        }
                        else
                        {
                            WriteLine(" - Inserting");

                            // Step 2.
                            // We are creating a new lead record.  We 
                            // need to determine if it matches to an 
                            // existing batch if we need to create a
                            // new batch.
                            bool bMatched = FindMatchingLead(oLead);
                            if (bMatched)
                            {
                                _iMatchCount++;
                            }

                            _iInsertedCount++;
                            InsertLead(oLead);
                            InsertBatch(oLead);
                        }
                    }
                }
                UpdateARLastExeuction(dtStart);

            }
            catch (Exception e)
            {
                WriteLine(string.Empty);
                WriteLine(string.Empty);
                WriteLine(e.Message);
                WriteLine(e.StackTrace);

                throw;
            }
            
            finally
            {
                _dbConn.Close();
                _dbLeadsConn.Close();

                WriteLine(string.Empty);
                WriteLine("The starting batch ID was " + _iStartBatchID.ToString());
                WriteLine(string.Empty);
                WriteLine(string.Empty);
                WriteLine("    Lead Count: " + _iLeadCount.ToString("###,##0"));
                WriteLine("  Insert Count: " + _iInsertedCount.ToString("###,##0"));
                WriteLine("   Match Count: " + _iMatchCount.ToString("###,##0"));
                WriteLine("  Update Count: " + _iUpdatedCount.ToString("###,##0"));
                WriteLine("    Skip Count: " + _iSkippedCount.ToString("###,##0"));
                WriteLine(string.Empty);
                WriteLine("Execution Time: " + DateTime.Now.Subtract(dtStart).ToString());

                string szOutputDirectory = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Substring(6);
                string szOutputFile = Path.Combine(szOutputDirectory, _szFileID + "Log.txt");

                using (StreamWriter sw = new StreamWriter(szOutputFile))
                {
                    foreach (string szLine in _lszOutputBuffer)
                    {
                        sw.WriteLine(szLine);
                    }
                }

                if (_lszSkippedBuffer.Count > 0)
                {
                    szOutputFile = Path.Combine(szOutputDirectory, _szFileID + "Skipped.txt");
                    using (StreamWriter sw = new StreamWriter(szOutputFile))
                    {
                        sw.WriteLine("Company ID" + DELIMITER + "Company Name" + DELIMITER + "City" + DELIMITER + "State" + DELIMITER + "Postal Code" + DELIMITER + "Phone" + DELIMITER + "AR Detail Count");
                        foreach (string szLine in _lszSkippedBuffer)
                        {
                            sw.WriteLine(szLine);
                        }
                    }
                }


                if (_lszMatchedClosedLeads.Count > 0)
                {
                    StringBuilder buffer = new StringBuilder();
                    buffer.Append("The following system closed non-factor leads were matched to imported AR." + Environment.NewLine + Environment.NewLine);

                    szOutputFile = Path.Combine(szOutputDirectory, _szFileID + "_Matched_Closed_Leads.txt");
                    using (StreamWriter sw = new StreamWriter(szOutputFile))
                    {
                        sw.WriteLine("Submiter BBID" + DELIMITER + "Lead ID" + DELIMITER + "Subject Company Name" + DELIMITER + "Subject City" + DELIMITER + "Subject State" + DELIMITER + "Subject Postal Code" + DELIMITER + "Subject Phone" + DELIMITER + "AR Detail Count" + DELIMITER + "Closed By" + DELIMITER + "Closed Date");
                        buffer.Append("Submiter BBID" + DELIMITER + "Lead ID" + DELIMITER + "Subject Company Name" + DELIMITER + "Subject City" + DELIMITER + "Subject State" + DELIMITER + "Subject Postal Code" + DELIMITER + "Subject Phone" + DELIMITER + "AR Detail Count" + DELIMITER + "Closed By" + DELIMITER + "Closed Date" + Environment.NewLine);
                        foreach (string szLine in _lszMatchedClosedLeads)
                        {
                            sw.WriteLine(szLine);
                            buffer.Append(szLine + Environment.NewLine);
                        }
                    }

                    string toEmail = ConfigurationManager.AppSettings["MatchedClosedLeadsEmail"];
                    if (string.IsNullOrEmpty(toEmail))
                    {
                        toEmail = "supportbbos@bluebookservices.com";
                    }
                    
                    SendMail(toEmail,
                             "bluebookservices@bluebookservices.com",
                             "LLLD Closed: Non-Factor Leads matched to AR",
                             buffer.ToString(),
                             false);
                }
            }
        }


        private const string SQL_FIND_AR_MATCH =
                @"SELECT LeadID, ExportedForValidation, [Status], StatusChangedBy, StatusChangedDate 
                  FROM Lead 
                 WHERE AssociatedCompanyID = @CompanyID 
                   AND Source = 'Unmatched AR' ";
        
        private SqlCommand cmdFindARMatchPhone;
        private SqlCommand cmdFindARMatchName;
        private SqlCommand cmdFindARMatchCustomerNumber;

        protected void FindARMatch(Lead oLead)
        {
            // PASS: Name & Customer Number
            if ((!string.IsNullOrEmpty(oLead.CompanyName)) &&
                (!string.IsNullOrEmpty(oLead.CustomerNumber)))
            {
                if (cmdFindARMatchCustomerNumber == null)
                {
                    cmdFindARMatchCustomerNumber = _dbLeadsConn.CreateCommand();
                    cmdFindARMatchCustomerNumber.CommandText = SQL_FIND_AR_MATCH;
                    cmdFindARMatchCustomerNumber.CommandText += "AND CompanyNameMatch = CRM.dbo.GetLowerAlpha(dbo.ufn_PrepareCompanyName(@CompanyName)) ";
                    cmdFindARMatchCustomerNumber.CommandText += "AND CustomerNumber = @CustomerNumber ";
                }

                cmdFindARMatchCustomerNumber.Parameters.Clear();
                AddParameter(cmdFindARMatchCustomerNumber, "CompanyID", oLead.AssociatedCompanyID);
                AddParameter(cmdFindARMatchCustomerNumber, "CompanyName", oLead.CompanyName);
                AddParameter(cmdFindARMatchCustomerNumber, "CustomerNumber", oLead.CustomerNumber);

                using (IDataReader drFindARMatch = cmdFindARMatchCustomerNumber.ExecuteReader())
                {
                    if (drFindARMatch.Read())
                    {
                        oLead.Exists = true;
                        oLead.LeadID = drFindARMatch.GetInt32(0);

                        oLead.Status = GetValue(drFindARMatch, "Status");
                        oLead.StatusChangedBy = GetValue(drFindARMatch, "StatusChangedBy");
                        if (drFindARMatch["StatusChangedDate"] != DBNull.Value)
                        {
                            oLead.StatusChangedDate = Convert.ToDateTime(drFindARMatch["StatusChangedDate"]).ToShortDateString();
                        }

                        if (drFindARMatch[1] != DBNull.Value)
                        {
                            oLead.ExportedForValidation = true;
                        }
                        return;
                    }

                }
            }

            //PASS: Phone
            if (isValidPhoneForMatch(oLead.PhoneNumber))
            {
                if (cmdFindARMatchPhone == null)
                {
                    cmdFindARMatchPhone = _dbLeadsConn.CreateCommand();
                    cmdFindARMatchPhone.CommandText = SQL_FIND_AR_MATCH;
                    cmdFindARMatchPhone.CommandText += "AND CompanyNameMatch = CRM.dbo.GetLowerAlpha(dbo.ufn_PrepareCompanyName(@CompanyName)) ";
                    cmdFindARMatchPhone.CommandText += "AND PhoneMatch = CRM.dbo.ufn_GetLowerAlpha(@Phone) ";
                }

                cmdFindARMatchPhone.Parameters.Clear();
                AddParameter(cmdFindARMatchPhone, "CompanyID", oLead.AssociatedCompanyID);
                AddParameter(cmdFindARMatchPhone, "CompanyName", oLead.CompanyName);
                AddParameter(cmdFindARMatchPhone, "Phone", oLead.PhoneNumber);
                

                using (IDataReader drFindARMatch = cmdFindARMatchPhone.ExecuteReader())
                {
                    if (drFindARMatch.Read())
                    {
                        oLead.Exists = true;
                        oLead.LeadID = drFindARMatch.GetInt32(0);

                        oLead.Status = GetValue(drFindARMatch, "Status");
                        oLead.StatusChangedBy = GetValue(drFindARMatch, "StatusChangedBy");
                        if (drFindARMatch["StatusChangedDate"] != DBNull.Value)
                        {
                            oLead.StatusChangedDate = Convert.ToDateTime(drFindARMatch["StatusChangedDate"]).ToShortDateString();
                        }


                        if (drFindARMatch[1] != DBNull.Value)
                        {
                            oLead.ExportedForValidation = true;
                        }

                        // Since we found our match,
                        return;
                    }
                }
            }



            // PASS: Name, City & State
            if ((!string.IsNullOrEmpty(oLead.CompanyName)) &&
                (!string.IsNullOrEmpty(oLead.FirstCity)) &&
                (!string.IsNullOrEmpty(oLead.FirstState)))
            {
                if (cmdFindARMatchName == null)
                {
                    cmdFindARMatchName = _dbLeadsConn.CreateCommand();
                    cmdFindARMatchName.CommandText = SQL_FIND_AR_MATCH;
                    cmdFindARMatchName.CommandText += "AND CompanyNameMatch = CRM.dbo.GetLowerAlpha(dbo.ufn_PrepareCompanyName(@CompanyName)) ";
                    cmdFindARMatchName.CommandText += "AND FirstCity = @City ";
                    cmdFindARMatchName.CommandText += "AND FirstState = @State ";
                }

                cmdFindARMatchName.Parameters.Clear();
                AddParameter(cmdFindARMatchName, "CompanyID", oLead.AssociatedCompanyID);
                AddParameter(cmdFindARMatchName, "CompanyName", oLead.CompanyName);
                AddParameter(cmdFindARMatchName, "City", oLead.FirstCity);
                AddParameter(cmdFindARMatchName, "State", oLead.FirstState);

                using (IDataReader drFindARMatch = cmdFindARMatchName.ExecuteReader())
                {
                    if (drFindARMatch.Read())
                    {
                        oLead.Exists = true;
                        oLead.LeadID = drFindARMatch.GetInt32(0);

                        if (drFindARMatch[1] != DBNull.Value)
                        {
                            oLead.ExportedForValidation = true;
                        }
                        return;
                    }
                }
            }



        }

        private const string SQL_AR_LEAD_UPDATE =
            @"UPDATE Lead 
               SET ARDetailCount=ARDetailCount+@NewCount, 
                   LastARDate=@LastARDate,
				   [Status] = CASE WHEN StatusChangedBy = 'System' AND Status NOT IN ('Open', 'Reopened') THEN 'Reopened' ELSE [Status] END,
				   StatusChangedBy = CASE WHEN StatusChangedBy = 'System' AND Status NOT IN ('Open', 'Reopened') THEN 'System'  ELSE StatusChangedBy END,
				   StatusChangedDate = CASE WHEN StatusChangedBy = 'System' AND Status NOT IN ('Open', 'Reopened') THEN GETDATE() ELSE StatusChangedDate END 
             WHERE LeadID = @LeadID";

        private SqlCommand cmdLeadUpdate;

        protected void UpdateARLead(Lead oLead)
        {
            if (cmdLeadUpdate == null)
            {
                cmdLeadUpdate = _dbLeadsConn.CreateCommand();
                cmdLeadUpdate.CommandText = SQL_AR_LEAD_UPDATE;
            }
            cmdLeadUpdate.Parameters.Clear();

            cmdLeadUpdate.Parameters.AddWithValue("NewCount", oLead.ARDetailCount);
            cmdLeadUpdate.Parameters.AddWithValue("LastARDate", oLead.LastARDate);
            cmdLeadUpdate.Parameters.AddWithValue("LeadID", oLead.LeadID);
            iResultCount = cmdLeadUpdate.ExecuteNonQuery();

            if (iResultCount == 0)
            {
                throw new ApplicationException("Unable to update existing lead.");
            }

        }
        #endregion

        #region Shared Lead Methods
        private const string SQL_BATCH_INSERT =
               "INSERT INTO Match (BatchID, MatchedLeadID, LeadID, MatchType) " +
                         "VALUES (@BatchID,@MatchedLeadID,@LeadID,@MatchType)";

        protected int _iBatchID = -1;
        protected int _iStartBatchID = -1;
        private const string SQL_BATCH_GET_ID =
                "SELECT ISNULL(MAX(BatchID), 0) FROM Match";


        private SqlCommand _cmdInsertBatch;
        protected void InsertBatch(Lead oLead)
        {
            if (_cmdInsertBatch == null) {
                _cmdInsertBatch = _dbLeadsConn.CreateCommand();
                _cmdInsertBatch.CommandText = SQL_BATCH_INSERT;
            }
            _cmdInsertBatch.Parameters.Clear();
            _cmdInsertBatch.Parameters.AddWithValue("LeadID", oLead.LeadID);            

            if (oLead.MatchedLeadID == 0)
            {
                if (_iBatchID == -1)
                {
                    SqlCommand cmdGetBatchID = _dbLeadsConn.CreateCommand();
                    cmdGetBatchID.CommandText = SQL_BATCH_GET_ID;
                    object oBatchID = cmdGetBatchID.ExecuteScalar();
                    _iBatchID = Convert.ToInt32(oBatchID);
                    _iBatchID++;
                    _iStartBatchID = _iBatchID;
                    
                    
                }
                oLead.BatchID = _iBatchID++;

                _cmdInsertBatch.Parameters.AddWithValue("MatchedLeadID", DBNull.Value);
                _cmdInsertBatch.Parameters.AddWithValue("MatchType", DBNull.Value);
            }
            else
            {
                _cmdInsertBatch.Parameters.AddWithValue("MatchedLeadID", oLead.MatchedLeadID);
                _cmdInsertBatch.Parameters.AddWithValue("MatchType", oLead.MatchType);
            }

            _cmdInsertBatch.Parameters.AddWithValue("BatchID", oLead.BatchID);
            _cmdInsertBatch.ExecuteNonQuery();
        }


        private bool isValidPhoneForMatch(string phoneNumber)
        {
            if (string.IsNullOrEmpty(phoneNumber))
                return false;

            if (phoneNumber.ToLower() == "unknown") 
                return false;

            if (phoneNumber.StartsWith("000 000-0000"))
                return false;

            if (phoneNumber.StartsWith("000-000-0000"))
                return false;

            if (phoneNumber.StartsWith("000-0000"))
                return false;

            if (phoneNumber.ToLower() == "disconnected")
                return false;

            if (phoneNumber.ToLower() == "no info")
                return false;

            if (phoneNumber.ToLower() == "none")
                return false;

            if (phoneNumber.ToLower() == "no.n/a")
                return false;

            if (phoneNumber.ToLower() == "0")
                return false;

            if (phoneNumber.ToLower() == "phoneandfax")
                return false;



            
            return true;
        }


        private const string SQL_PHONE_MATCH =
            @"SELECT TOP 1 Match.BatchID, Match.LeadID 
                FROM Lead 
                     INNER JOIN Match ON Lead.LeadID = Match.LeadID 
               WHERE PhoneMatch IS NOT NULL 
                 AND PhoneMatch <> '' 
                 AND PhoneMatch = CRM.dbo.ufn_GetLowerAlpha(@Phone) ORDER BY BatchID";

        private const string SQL_NAME_MATCH =
            @"SELECT TOP 1 Match.BatchID, Match.LeadID 
                FROM Lead 
                     INNER JOIN Match ON Lead.LeadID = Match.LeadID 
               WHERE CompanyNameMatch = CRM.dbo.ufn_GetLowerAlpha(dbo.ufn_PrepareCompanyName(@Name)) 
                 --AND ISNULL(Lead.FirstCity, 'x') = @City
                 --AND ISNULL(Lead.FirstState, 'x') = @State
            ORDER BY BatchID";


        private SqlCommand cmdPhoneMatch;
        private SqlCommand cmdNameMatch;
        protected bool FindMatchingLead(Lead oLead)
        {

            if (isValidPhoneForMatch(oLead.PhoneNumber))
            {
                if (cmdPhoneMatch == null)
                {
                    cmdPhoneMatch = _dbLeadsConn.CreateCommand();
                    cmdPhoneMatch.CommandText = SQL_PHONE_MATCH;
                }
                cmdPhoneMatch.Parameters.Clear();
                cmdPhoneMatch.Parameters.AddWithValue("Phone", oLead.PhoneNumber);

                using (IDataReader drPhoneMatch = cmdPhoneMatch.ExecuteReader())
                {
                    if (drPhoneMatch.Read())
                    {
                        oLead.BatchID = drPhoneMatch.GetInt32(0);
                        oLead.MatchedLeadID = drPhoneMatch.GetInt32(1);
                        oLead.MatchType = "Phone";
                        return true;
                    }
                }
            }


            if (cmdNameMatch == null)
            {
                cmdNameMatch = _dbLeadsConn.CreateCommand();
                cmdNameMatch.CommandText = SQL_NAME_MATCH;
            }
            cmdNameMatch.Parameters.Clear();
            cmdNameMatch.Parameters.AddWithValue("Name", oLead.CompanyName);

            using (IDataReader drNameMatch = cmdNameMatch.ExecuteReader())
            {
                if (drNameMatch.Read())
                {
                    oLead.BatchID = drNameMatch.GetInt32(0);
                    oLead.MatchedLeadID = drNameMatch.GetInt32(1);
                    oLead.MatchType = "Name";
                    return true;
                }
            }

            return false;
        }

        private const string SQL_LEAD_INSERT =
            "INSERT INTO Lead (Source, AssociatedCompanyID, CompanyName, AlternateName, Rating, MiscInfo, FirstAddress1, FirstAddress2, FirstCity, FirstState, FirstCountry, FirstPostCode, SecondAddress1, SecondAddress2, SecondCity, SecondState, SecondCountry, SecondPostCode, PhoneNumber, FaxNumber, Email, WebSite, ARDetailCount, ListingCity, ListingState, OriginalRedBookName, LastARDate, CustomerNumber, Status) " +
                     "VALUES (@Source,@AssociatedCompanyID,@CompanyName,@AlternateName,@Rating,@MiscInfo,@FirstAddress1,@FirstAddress2,@FirstCity,@FirstState,@FirstCountry,@FirstPostCode,@SecondAddress1,@SecondAddress2,@SecondCity,@SecondState,@SecondCountry,@SecondPostCode,@PhoneNumber,@FaxNumber,@Email,@WebSite,@ARDetailCount, @ListingCity, @ListingState, @OriginalRedBookName, @LastARDate, @CustomerNumber, 'Open'); " +
            "SELECT SCOPE_IDENTITY();";


        private SqlCommand cmdInsertLead;
        protected void InsertLead(Lead oLead)
        {
            if (cmdInsertLead == null)
            {
                cmdInsertLead = _dbLeadsConn.CreateCommand();
                cmdInsertLead.CommandText = SQL_LEAD_INSERT;
            }
            cmdInsertLead.Parameters.Clear();

            AddParameter(cmdInsertLead, "Source", oLead.Source);

            AddParameter(cmdInsertLead, "AssociatedCompanyID", oLead.AssociatedCompanyID);
            AddParameter(cmdInsertLead, "CompanyName", oLead.CompanyName);
            AddParameter(cmdInsertLead, "AlternateName", oLead.AlternateName);
            AddParameter(cmdInsertLead, "Rating", oLead.Rating);
            AddParameter(cmdInsertLead, "MiscInfo", oLead.MiscInfo);
            AddParameter(cmdInsertLead, "FirstAddress1", oLead.FirstAddress1);
            AddParameter(cmdInsertLead, "FirstAddress2", oLead.FirstAddress2);
            AddParameter(cmdInsertLead, "FirstCity", oLead.FirstCity);
            AddParameter(cmdInsertLead, "FirstState", oLead.FirstState);
            AddParameter(cmdInsertLead, "FirstPostCode", oLead.FirstPostCode);
            AddParameter(cmdInsertLead, "FirstCountry", oLead.FirstCountry);
            AddParameter(cmdInsertLead, "SecondAddress1", oLead.SecondAddress1);
            AddParameter(cmdInsertLead, "SecondAddress2", oLead.SecondAddress2);
            AddParameter(cmdInsertLead, "SecondCity", oLead.SecondCity);
            AddParameter(cmdInsertLead, "SecondState", oLead.SecondState);
            AddParameter(cmdInsertLead, "SecondPostCode", oLead.SecondPostCode);
            AddParameter(cmdInsertLead, "SecondCountry", oLead.SecondCountry);

            AddParameter(cmdInsertLead, "PhoneNumber", oLead.PhoneNumber);
            AddParameter(cmdInsertLead, "FaxNumber", oLead.FaxNumber);
            AddParameter(cmdInsertLead, "Email", oLead.Email);
            AddParameter(cmdInsertLead, "WebSite", oLead.WebSite);

            AddParameter(cmdInsertLead, "OriginalRedBookName", oLead.OriginalRedBookName);
            AddParameter(cmdInsertLead, "ListingCity", oLead.ListingCity);
            AddParameter(cmdInsertLead, "ListingState", oLead.ListingState);

            AddParameter(cmdInsertLead, "ARDetailCount", oLead.ARDetailCount);

            AddParameter(cmdInsertLead, "CustomerNumber", oLead.CustomerNumber);

            if (oLead.LastARDate != DateTime.MinValue)
            {
                cmdInsertLead.Parameters.AddWithValue("LastARDate", oLead.LastARDate);
            }
            else
            {
                cmdInsertLead.Parameters.AddWithValue("LastARDate", DBNull.Value);
            }

            try
            {
                object oLeadID = cmdInsertLead.ExecuteScalar();
                oLead.LeadID = Convert.ToInt32(oLeadID);

                InsertDescription(oLead);
            } catch (Exception eX)
            {
                Console.Write(eX.Message);
                throw;
            }
        }


        private const string SQL_DESCRIPTION_INSERT =
            "INSERT INTO RedbookDescription (LeadID, Description) VALUES (@LeadID, @Description); ";

        private SqlCommand cmdInsertDescription;
        protected void InsertDescription(Lead oLead)
        {

            if (string.IsNullOrEmpty(oLead.Description))
            {
                return;
            }

            if (cmdInsertDescription == null)
            {
                cmdInsertDescription = _dbLeadsConn.CreateCommand();
                cmdInsertDescription.CommandText = SQL_DESCRIPTION_INSERT;
            }


            string[] aszDescription = oLead.Description.Split(new char[] { '/' });
            foreach (string szDescription in aszDescription)
            {
                if (!string.IsNullOrEmpty(szDescription.Trim())) {
                    cmdInsertDescription.Parameters.Clear();
                    cmdInsertDescription.Parameters.AddWithValue("LeadID", oLead.LeadID);
                    AddParameter(cmdInsertDescription, "Description", szDescription.Trim());
                    cmdInsertDescription.ExecuteNonQuery();
                }
            }
        }
    #endregion


#region Helper Methods

        protected void AddParameter(SqlCommand sqlCommand, string szParmName, string szParmValue)
        {
            if (string.IsNullOrEmpty(szParmValue))
            {
                // Due to the reports and the multi-value paramters, we don't ever 
                // want this to be NULL
                if (szParmName == "Rating")
                {
                    sqlCommand.Parameters.AddWithValue(szParmName, string.Empty);
                }
                else
                {
                    sqlCommand.Parameters.AddWithValue(szParmName, DBNull.Value);
                }

            } else {
                sqlCommand.Parameters.AddWithValue(szParmName, szParmValue);
            }
        }

        protected void AddParameter(SqlCommand sqlCommand, string szParmName, int iParmValue)
        {
            if (iParmValue == 0)
            {
                sqlCommand.Parameters.AddWithValue(szParmName, DBNull.Value);
            }
            else
            {
                sqlCommand.Parameters.AddWithValue(szParmName, iParmValue);
            }
        }

        protected string GetValue(IDataReader drReader, string szColName)
        {
            if (drReader[szColName] == DBNull.Value)
            {
                return null;
            }

            return Convert.ToString(drReader[szColName]).Trim();
        }

        private string szTempWrite = string.Empty;
        protected void Write(string szLine)
        {
            Console.Write(szLine);
            szTempWrite += szLine;
        }

        protected void WriteLine(string szLine)
        {
            Console.WriteLine(szLine);
            _lszOutputBuffer.Add(szTempWrite + szLine);

            if (!string.IsNullOrEmpty(szTempWrite))
            {
                szTempWrite = string.Empty;
            }
        }

        protected string GetCamelCase(string szText)
        {
            if (string.IsNullOrEmpty(szText))
            {
                return string.Empty;
            }

            string szTemp = szText.Trim();

            return szTemp.Substring(0, 1) + szTemp.Substring(1, szTemp.Length - 1).ToLower();
        }

        private DateTime GetARLastExecution()
        {
            if (ConfigurationManager.AppSettings["UnmatchedARIngoreLastExecutionDate"] == "true")
            {
                return new DateTime(2006, 12, 4);
            }

            SqlCommand cmdLastExecution = _dbLeadsConn.CreateCommand();
            cmdLastExecution.CommandText = "SELECT Value FROM LookupValues WHERE Name = 'LastARUnmatchedExecution'";

            object oLastExecution = cmdLastExecution.ExecuteScalar();

            if (oLastExecution == null)
            {
                //return new DateTime(2006, 12, 4);
                throw new ApplicationException("LastARUnmatchedExecution Lookup Value Not Found.");
            }

            WriteLine("Last AR Import: " + Convert.ToDateTime(oLastExecution).ToString());

            return Convert.ToDateTime(oLastExecution);
        }

        private void UpdateARLastExeuction(DateTime dtLastExecution)
        {
            SqlCommand cmdLastExecution = _dbLeadsConn.CreateCommand();
            cmdLastExecution.CommandText = "UPDATE LookupValues SET Value=@Value WHERE Name = 'LastARUnmatchedExecution'";
            cmdLastExecution.Parameters.AddWithValue("Value", dtLastExecution);
            cmdLastExecution.ExecuteNonQuery();
        }


        private void EnumerateWorksheets(string szFileName)
        {
            OleDbConnection msExcelConn = new OleDbConnection("Provider=Microsoft.Jet.OLEDB.4.0;" +
                                                             "Data Source=" + szFileName + ";" +
                                                             "Extended Properties=\"Excel 8.0;HDR=Yes\"");

            msExcelConn.Open();

            WriteLine("Worksheets found in " + szFileName);

            DataTable schemaTable = msExcelConn.GetOleDbSchemaTable(OleDbSchemaGuid.Tables, new object[] { null, null, null, "TABLE" });
            foreach (DataRow schemaRow in schemaTable.Rows)
            {
                string sheet = schemaRow["TABLE_NAME"].ToString();
                WriteLine(" - " + sheet);
            }
            
            msExcelConn.Close();

        }
        #endregion


        static public void SendMail(string szToAddress,
                                    string szFromAddress,
                                    string szSubject,
                                    string szMessage,
                                    bool bIsBodyHTML)
        {

            MailMessage oMessage = new MailMessage();
            oMessage.From = new MailAddress(szFromAddress);

            string[] aszToAddresses = szToAddress.Split(',');
            foreach (string szAddress in aszToAddresses)
            {
                oMessage.To.Add(new MailAddress(szAddress.Trim()));
            }

            oMessage.Subject = szSubject;
            oMessage.Body = szMessage;
            oMessage.IsBodyHtml = bIsBodyHTML;

            SmtpClient oClient = new SmtpClient(ConfigurationManager.AppSettings["EMailSMTPServer"]);
            oClient.Send(oMessage);
        }
    }
}

