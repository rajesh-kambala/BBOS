/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc 2010

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: DowJonesNewsProvider
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Net;
using System.Threading;
using System.Web;
using System.Xml;
using PRCo.BBOS.ExternalNews.DowJones;
using TSI.Utils;


namespace PRCo.BBOS.ExternalNews
{
    public class DowJonesNewsProvider:NewsProvider
    {
        private string _xmlResult = null;
        private List<string> _lErrors = new List<string>();
        private List<string> _lMultipleMatchingResults = new List<string>();


        /// <summary>
        /// This is a public property that has the unique name of this external news source as determined by BBSi.  
        /// It is used when storing/querying for records on the PRCompanyExternalNews and PRExternalNews tables.
        /// </summary>
        override public string NewsProviderName
        {
            get { return "DowJones"; }
        }

        /// <summary>
        /// This method is for those news sources that maintain their own list of unique IDs for companies.  
        /// Using the appropriate mechanism, this method should query the news source for the unique ID for 
        /// every Company record that does not already have a record in PRCompanyExternalNews.  For each 
        /// new unique ID found, insert a new record into the PRCompanyExternalNews table.
        /// </summary>
        override public void RefreshCodes()
        {
            GetFCode(Utilities.GetConfigValue("DowJonesCoreSelectAdditionalCriteria", string.Empty));
        }

        public void FindCode(int companyID)
        {
            GetFCode(" AND comp_CompanyID=" + companyID.ToString());
        }

        /// <summary>
        /// Refreshes the news articles for the specified company, honoring the cache
        /// settings, meaning that we only query the external source if the cache time
        /// limit has expired.
        /// </summary>
        /// <param name="companyID"></param>
        override public void RefreshCompany(int companyID)
        {
            RefreshCompany(companyID, false);
        }

        /// <summary>
        /// Refreshes the news articles for the specified company.
        /// </summary>
        /// <param name="companyID"></param>
        /// <param name="overrideCache">If true, then we query the external news source
        /// regardless if the cache time limit has expired. </param>
        override public void RefreshCompany(int companyID, bool overrideCache)
        {
            string additionalCriteria = " AND prcen_CompanyID=" + companyID;

            if (!overrideCache)
            {
                additionalCriteria += GetHonorCacheClause();
            }

            GetArticles(additionalCriteria);
        }

        /// <summary>
        /// Refreshes the news articles for the all companies, honoring the cache
        /// settings, meaning that we only query the external source if the cache time
        /// limit has expired.
        /// </summary>        
        override public void RefreshAllCompanies()
        {
            RefreshAllCompanies(false);
        }

        /// <summary>
        /// Refreshes the news articles for all companies.
        /// </summary>
        /// <param name="overrideCache">If true, then we query the external news source
        /// regardless if the cache time limit has expired. </param>
        override public void RefreshAllCompanies(bool overrideCache)
        {
            string additionalCriteria = string.Empty;
            if (!overrideCache)
            {
                additionalCriteria = GetHonorCacheClause();
            }

            GetArticles(additionalCriteria);
        }

        private string GetHonorCacheClause()
        {
            return " AND (prcen_LastRetrievalDateTime IS NULL OR prcen_LastRetrievalDateTime <= '" + DateTime.Now.AddMinutes(0 - Utilities.GetIntConfigValue("DowJonesArticleCacheTimelimit", 1440)).ToString("MM/dd/yyyy HH:mm:ss", new System.Globalization.CultureInfo("en-US")) + "')";
        }
        #region CompanySearchMethods
        private const string COMPANY_SEARCH = "/Company/search/xml?Name={1}&SearchOperator={4}&EncryptedToken={0}";

        private const string SQL_CORE_SEARCH_SELECT =
            "SELECT comp_CompanyID " +
              "FROM Company WITH (NOLOCK) " +
             "WHERE comp_PRListingStatus IN ('L', 'H', 'LUV')  " +
               "AND comp_PRType = 'H' " +
               "AND comp_CompanyID NOT IN (SELECT prcen_CompanyID FROM PRCompanyExternalNews WITH (NOLOCK) WHERE prcen_Code IS NOT NULL AND prcen_PrimarySourceCode='DowJones') " +
               "{0}";

        private const string SQL_SELECT_COMPANIES_SEARCH =
            "SELECT comp_CompanyID, " +
                   "comp_PRCorrTradestyle, " +
                   "CASE WHEN ISNULL(prc4_Symbol1, ISNULL(prc4_Symbol1, ISNULL(prc4_Symbol1, 'X'))) = 'X' THEN 'Private' ELSE 'Public' END As OwnershipType " +
              "FROM Company WITH (NOLOCK) " +
                   "LEFT OUTER JOIN PRCompanyStockExchange WITH (NOLOCK) ON comp_CompanyID = prc4_CompanyID " +
             "WHERE comp_CompanyID IN ({0}) " +
             "ORDER BY comp_CompanyID";

        private const string SQL_SELECT_STOCK_SYMBOLS =
            "SELECT prc4_CompanyID, StockSymbol " +
              "FROM ( " +
                "SELECT prc4_CompanyID, prc4_Symbol1 As StockSymbol " +
                  "FROM PRCompanyStockExchange WITH (NOLOCK) " +
                "UNION   " +
                "SELECT prc4_CompanyID, prc4_Symbol2 As StockSymbol " +
                  "FROM PRCompanyStockExchange WITH (NOLOCK) " +
                "UNION   " +
                "SELECT prc4_CompanyID, prc4_Symbol3 As StockSymbol " +
                  "FROM PRCompanyStockExchange WITH (NOLOCK)) T1 " +
             "WHERE StockSymbol IS NOT NULL ";

        private const string SQL_SELECT_ADDRESSES =
            "SELECT adli_CompanyID, addr_Address1, prci_City, prst_State, prst_Abbreviation, prcn_Country, prcn_CountryID, addr_PostCode, addr_uszipfive, adli_Type, CityStateCountryShort " +
              "FROM vPRAddress " +
             "WHERE adli_CompanyID IN ({0}) " +
               "AND CityStateCountryShort IS NOT NULL " +
          "ORDER BY adli_CompanyID, dbo.ufn_GetAddressListSeq(adli_Type)";

        private const string SQL_SELECT_PHONES =
            "SELECT plink_RecordID, phon_PhoneID, phon_CountryCode, phon_AreaCode, phon_Number " +
              "FROM vPRCompanyPhone WITH (NOLOCK) " +
             "WHERE plink_RecordID IN ({0}) " +
          "ORDER BY plink_RecordID";


        private void GetFCode(string additionalCriteria)
        {
            action = "DowJonesCompanySearch";

            List<Company> lCompanies = new List<Company>();

            string szCoreSelect = string.Format(SQL_CORE_SEARCH_SELECT, additionalCriteria);

            SqlConnection dbConn = new SqlConnection(GetConnectionString());
            dbConn.Open();
            try
            {
                // The first thing we're going to do is query for the relevant data from CRM and
                // cache it in datatables in memory.  This is quicker than querying the tables
                // on per company basis.
                SqlDataAdapter daPhones = new SqlDataAdapter(string.Format(SQL_SELECT_PHONES, szCoreSelect), dbConn);
                DataSet dsPhones = new DataSet();
                daPhones.Fill(dsPhones, "Phones");
                DataView dvPhones = new DataView(dsPhones.Tables["Phones"]);
                dvPhones.Sort = "plink_RecordID";

                SqlDataAdapter daAddresses = new SqlDataAdapter(string.Format(SQL_SELECT_ADDRESSES, szCoreSelect), dbConn);
                DataSet dsAddresses = new DataSet();
                daAddresses.Fill(dsAddresses, "Address");
                DataView dvAddresses = new DataView(dsAddresses.Tables["Address"]);
                dvAddresses.Sort = "adli_CompanyID";

                SqlDataAdapter daStockSymbols = new SqlDataAdapter(SQL_SELECT_STOCK_SYMBOLS, dbConn);
                DataSet dsStockSymbols = new DataSet();
                daStockSymbols.Fill(dsStockSymbols, "StockSymbol");
                DataView dvStockSymbols = new DataView(dsStockSymbols.Tables["StockSymbol"]);
                dvStockSymbols.Sort = "prc4_CompanyID";

                // Now build a list of CRM companies and populate the company instances using the 
                // cached data.
                SqlCommand sqlCommandCompanies = new SqlCommand(string.Format(SQL_SELECT_COMPANIES_SEARCH, szCoreSelect), dbConn);
                using (IDataReader oReader = sqlCommandCompanies.ExecuteReader())
                {
                    while (oReader.Read())
                    {
                        lCompanies.Add(new Company(oReader, dvAddresses, dvPhones, dvStockSymbols));
                    }
                }


                List<DowJonesCompany> oDowJonesCompanies = null;

                int iFoundFCodeCount = 0;
                int iFoundDJCompanyButNoMatchCount = 0;
                int iErrorCount = 0;
                int iExceptionCount = 0;

                foreach (Company oCompany in lCompanies)
                {
                    // Execute the Dow Jones company search 
                    oDowJonesCompanies = ExecuteCompanySearch(oCompany);

                    xmlResult = _xmlResult;


                    if (Utilities.GetBoolConfigValue("DowJonesAlwaysWriteXMLToDisk", false))
                    {
                        WriteXMLToDisk(oCompany);
                    }

                    if (oCompany.DowJonesError)
                    {
                        iErrorCount++;
                        StatusCode = STATUS_ERROR;
                        StatusMessage = "Dow Jones Error";
                    }
                    else if (oCompany.ProcessingException)
                    {
                        iExceptionCount++;
                        StatusCode = STATUS_PROCESSING_EXCEPTION;
                        StatusMessage = oCompany.exception.Message;

                    } else
                    {
                        // Now try to match the Dow Jones data to our CRM
                        // company.
                        MatchDowJonesResult(oCompany, oDowJonesCompanies);

                        if (oCompany.Matched)
                        {

                            iFoundFCodeCount++;
                            WriteToLog(oCompany.CompanyID, "Found FCode " + oCompany.NewsCode);
                            if (Utilities.GetBoolConfigValue("DowJonesSaveMatchedFile", true))
                            {
                                WriteXMLToDisk(oCompany);
                            }
                            InsertFCode(dbConn, oCompany);

                            StatusCode = STATUS_SUCCESS;
                            StatusMessage = "FCode found and record created.";

                        }
                        else
                        {
                            InsertFCodeLookupAttempt(dbConn, oCompany);

                            if ((oDowJonesCompanies.Count > 0) &&
                                (!oCompany.MultipeMatches))
                            {
                                iFoundDJCompanyButNoMatchCount++;

                                WriteToLog(oCompany.CompanyID, "Found Dow Jones companies, but none matched.");

                                // We found Dow Jones companies, but were not able to 
                                // match any of them to our CRM company.  If the users want,
                                // let's write the Dow Jones XML to disk for manual review.
                                if (Utilities.GetBoolConfigValue("DowJonesSaveUnmatchedFile", true))
                                {
                                    WriteXMLToDisk(oCompany);                                   
                                }

                                StatusCode = STATUS_NO_MATCH;
                                StatusMessage = "Found Dow Jones companies, but none matched.";
                            }

                            if ((oDowJonesCompanies.Count > 1) &&
                                (oCompany.MultipeMatches))
                            {
                                StatusCode = STATUS_MULTIPLE_MATCH;
                                StatusMessage = "Found Dow Jones companies and multiple possible matches.";
                            }

                            if (oDowJonesCompanies.Count == 0)
                            {
                                StatusCode = STATUS_NOT_FOUND;
                                StatusMessage = "No Dow Jones Companies Found.";
                            }
                        }


                    }
                } // End For Companies

                WriteToLog(Environment.NewLine);
                WriteToLog("Company Count: " + lCompanies.Count.ToString("###,##0"));
                WriteToLog("Found FCode Count: " + iFoundFCodeCount.ToString("###,##0"));
                WriteToLog("Found DJ Company, But No Match Count: " + iFoundDJCompanyButNoMatchCount.ToString("###,##0"));
                WriteToLog("Found Multiple DJ Company Matches: " + _lMultipleMatchingResults.Count.ToString("###,##0"));
                WriteToLog("Dow Jones Error Count: " + iErrorCount.ToString("###,##0"));
                WriteToLog("Processing Exception Count: " + iExceptionCount.ToString("###,##0"));

            }
            finally
            {
                dbConn.Close();
            }

        }

        /// <summary>
        /// This method connects to the Dow Jones Company web service and
        /// executes a search.  It parses the XML result and returns a list
        /// of DJ company objects.
        /// </summary>
        /// <param name="company"></param>
        /// <returns></returns>
        private List<DowJonesCompany> ExecuteCompanySearch(Company company)
        {
            string token = Utilities.GetConfigValue("DowJonesToken", "S00YcJpZXJs0WNb2tmnOHmnM96qN9UuMpar5DByWWNK2FfYSdMmVqv8McrBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUEA");
            string url = Utilities.GetConfigValue("DowJonesURL", "http://api.beta.dowjones.com/api/1.0");
            string searchCommand = Utilities.GetConfigValue("DowJonesCompanySearchService", "/Company/search/xml?Name={1}&SearchOperator={2}&EncryptedToken={0}");

            string[] aArgs = {token,
                              HttpUtility.UrlEncode(Utils.FuzzifyCompanyName(company.CompanyName)),
                              "BeginsWith"};

            url = url + string.Format(searchCommand, aArgs);

            if (!GetDowJonesResponse(url, company))
            {
                return null;
            }

            XmlDocument xd = null;
            xd = new XmlDocument();
            xd.Load(new StringReader(_xmlResult));

            // If the DJ service returned any error nodes,
            // then we cannot return any DJ company objects.
            // Write the XML to disk so someone can look
            // into this.
            if (CheckForError(company, xd))
            {
                WriteXMLToDisk(company);
                return null;
            }

            List<DowJonesCompany> oDJCompanies = new List<DowJonesCompany>();
            XmlNodeList xmlCompanyList = xd.SelectNodes("CompanyResponse/Companies/CompanyProfile/Company");
            foreach (XmlNode oCompanyNode in xmlCompanyList)
            {
                oDJCompanies.Add(new DowJonesCompany(oCompanyNode));
            }

            return oDJCompanies;
        }
        #endregion

        private const string SQL_COMPANY_ARTICLE_SEARCH =
            "SELECT prcen_CompanyID, prcen_Code, prcen_LastRetrievalDateTime " +
              "FROM PRCompanyExternalNews " +
             "WHERE prcen_Code IS NOT NULL " +
               "AND prcen_PrimarySourceCode = 'DowJones' " +
             " {0} ";

        /// <summary>
        /// This method retrieves the news articles for those companies
        /// meeting the specified additional criteria.
        /// </summary>
        /// <param name="additionalCriteria"></param>
        private void GetArticles(string additionalCriteria)
        {
            action = "DowJonesArticleSearch";
            List<Company> lCompanies = new List<Company>();

            SqlConnection dbConn = new SqlConnection(GetConnectionString());
            dbConn.Open();
            try
            {

                SqlCommand sqlCommandCompanies = new SqlCommand(string.Format(SQL_COMPANY_ARTICLE_SEARCH, additionalCriteria), dbConn);
                using (IDataReader oReader = sqlCommandCompanies.ExecuteReader())
                {
                    while (oReader.Read())
                    {
                        Company company = new Company();
                        company.CompanyID = oReader.GetInt32(0);
                        company.NewsCode = oReader.GetString(1);
                        if (oReader[2] != DBNull.Value)
                        {
                            company.LastArticleRetrieval = oReader.GetDateTime(2);
                        }

                        lCompanies.Add(company);
                    }
                }

                int iCompanyWithArticlesCount = 0;
                int iInsertedArticleCount = 0;
                int iSkippedArticleCount = 0;
                int iErrorCount = 0;
                int iExceptionCount = 0;

                foreach (Company oCompany in lCompanies)
                {
                    XmlDocument xd = ExecuteArticleSearch(oCompany);

                    if (oCompany.DowJonesError)
                    {
                        iErrorCount++;
                    }
                    else if (oCompany.ProcessingException)
                    {
                        iExceptionCount++;
                    }
                    else if (xd != null)
                    {
                        SaveArticles(dbConn, oCompany, xd);
                        UpdateCacheDate(dbConn, oCompany);

                        if (oCompany.ArticleCount > 0)
                        {
                            iCompanyWithArticlesCount++;
                        }

                        iInsertedArticleCount += oCompany.InsertedArticleCount;
                        iSkippedArticleCount += (oCompany.ArticleCount - oCompany.InsertedArticleCount);

                        if (Utilities.GetBoolConfigValue("DowJonesSaveArticleFile", false))
                        {
                            WriteXMLToDisk(oCompany);
                        }
                    }
                }

                // We need to make sure the cache date is also
                // updated for those companies we did not find
                // any articles for.
                if (lCompanies.Count > 0) { 
                    UpdateCacheDate(dbConn, additionalCriteria);
                }


                WriteToLog(Environment.NewLine);
                WriteToLog("Company Count: " + lCompanies.Count.ToString("###,##0"));
                WriteToLog("Companies with Articles: " + iCompanyWithArticlesCount.ToString("###,##0"));
                WriteToLog("Inserted Articles: " + iInsertedArticleCount.ToString("###,##0"));
                WriteToLog("Skipped Articles: " + iSkippedArticleCount.ToString("###,##0"));
                WriteToLog("Dow Jones Error Count: " + iErrorCount.ToString("###,##0"));
                WriteToLog("Processing Exception Count: " + iExceptionCount.ToString("###,##0"));
            }
            finally
            {
                dbConn.Close();
            }
        }


        private XmlDocument ExecuteArticleSearch(Company company)
        {
            string token = Utilities.GetConfigValue("DowJonesToken", "S00YcJpZXJs0WNb2tmnOHmnM96qN9UuMpar5DByWWNK2FfYSdMmVqv8McrBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUEA");
            string url = Utilities.GetConfigValue("DowJonesURL", "http://integration.beta.dowjones.com/api/1.0");
            string searchCommand = Utilities.GetConfigValue("DowJonesArticleSearchService", "/Content/search/XML?QueryString=fds:{1}{2}&ServerRedirect=false&sourcegenre=newssites|websites|blogs&EncryptedToken={0}");

            string dateParameters = string.Empty;
            if (company.LastArticleRetrieval != DateTime.MinValue)
            {
                //dateParameters = string.Format("&StartDate={0}&EndDate={1}", company.LastArticleRetrieval.ToUniversalTime().ToString("s"), DateTime.Now.ToUniversalTime().ToString("s"));
                dateParameters = string.Format("&StartDate={0}&EndDate={1}", new DateTime(2015, 6, 1).ToUniversalTime().ToString("s"), DateTime.Now.ToUniversalTime().ToString("s"));
            }

            string[] aArgs = {token,
                              company.NewsCode,
                              dateParameters};

            url = url + string.Format(searchCommand, aArgs);

            if (!GetDowJonesResponse(url, company))
            {
                return null;
            }


            XmlDocument xd = null;
            xd = new XmlDocument();
            xd.Load(new StringReader(_xmlResult));

            if (CheckForError(company, xd))
            {
                WriteXMLToDisk(company);
                return null;
            }

            return xd;
        }

        /// <summary>
        /// Helper method that executes the actual web service implementing
        /// some fault tolerance.
        /// </summary>
        /// <param name="url"></param>
        /// <param name="company"></param>
        /// <returns></returns>
        private bool GetDowJonesResponse(string url, Company company)
        {
            WebRequest webRequest = WebRequest.Create(url);
            webRequest.Method = "GET";

            bool retry = true;
            int iRetryMaxCount = Utilities.GetIntConfigValue("DowJonesRetryCount", 3);
            int iRetryCount = 0;

            while (retry)
            {
                iRetryCount++;
                try
                {
                    WebResponse webResponse = webRequest.GetResponse();
                    StreamReader sr = new StreamReader(webResponse.GetResponseStream(), System.Text.Encoding.UTF8);

                    _xmlResult = sr.ReadToEnd();

                    sr.Close();
                    webResponse.Close();

                    // If we made it this far, then no 
                    // exception has occured
                    retry = false;
                }
                catch (System.Net.WebException e)
                {
                    // We can overwhelm the DJ servers (at least in test) such that we'll occassionally
                    // get a time out error.  This code allows us to retry the operation a limited number
                    // of times, pausing between each attempt.  Once we hit our retry limit, we'll handle
                    // this as a processing error.
                    WriteToLog(company.CompanyID, "Exception on attempt " + iRetryCount.ToString() + ": " + e.Message);
                    if (iRetryCount >= iRetryMaxCount)
                    {
                        company.ProcessingException = true;
                        company.exception = e;
                        WriteToLog(company.CompanyID, "Unable to retrieve data.");
                        return false;
                    }

                    Thread.Sleep(Utilities.GetIntConfigValue("DowJonesExceptionSleeep", 1000));
                }
            }

            return true;
        }

        /// <summary>
        /// This method iterates through the Dow Jones Companies looking for 
        /// a match to the specified CRM company.
        /// </summary>
        /// <param name="oCompany"></param>
        /// <param name="oDowJonesCompanies"></param>
        private void MatchDowJonesResult(Company oCompany,
                                           List<DowJonesCompany> oDowJonesCompanies)
        {
            if ((oDowJonesCompanies == null) ||
                (oDowJonesCompanies.Count == 0))
                return;

            int iMatchScore = 0;
            List<DowJonesCompany> lMatchedDowJonesCompanies = new List<DowJonesCompany>();

            foreach (DowJonesCompany oDowJonesCompany in oDowJonesCompanies)
            {
                // Calculate a match score for this DJ company.
                oDowJonesCompany.MatchCompany(oCompany);

                // This condition should catch multiple Dow Jones companies
                // that have the same match score.
                if ((iMatchScore > 0) &&
                    (oDowJonesCompany.CalculateMatchScore() == iMatchScore) &&
                    (oDowJonesCompany.MatchResults.AnyKeyFieldMatched))
                {
                    lMatchedDowJonesCompanies.Add(oDowJonesCompany);
                }

                if (oDowJonesCompany.CalculateMatchScore() > iMatchScore)
                {
                    bool bMatched = true;

                    // If the match score is 1, that one field must
                    // be a key field.
                    if ((oDowJonesCompany.CalculateMatchScore() == 1) &&
                        (!oDowJonesCompany.MatchResults.AnyKeyFieldMatched))
                    {
                        bMatched = false;
                    }

                    if (bMatched)
                    {
                        iMatchScore = oDowJonesCompany.CalculateMatchScore();

                        // Clear out any previously matched DJ companies
                        lMatchedDowJonesCompanies.Clear();
                        lMatchedDowJonesCompanies.Add(oDowJonesCompany);
                    }

                }
            } // Foreach DowJonesResult


            if (lMatchedDowJonesCompanies.Count == 1)
            {
                oCompany.Matched = true;
                oCompany.NewsCode = lMatchedDowJonesCompanies[0].FCode;
                return;
            }

            // If we found multiple DJ companies that match our CRM company
            // then set our processing flags, write a message to the log, and
            // write the XML to disk.  A user will have to manually handle this.
            if (lMatchedDowJonesCompanies.Count > 1)
            {
                oCompany.MultipeMatches = true;
                _lMultipleMatchingResults.Add(oCompany.CompanyID.ToString());
                WriteToLog(oCompany.CompanyID, "Found Multiple DJ Matches");
                WriteXMLToDisk(oCompany);
            }
        }

        private const string SQL_INSERT_FCODE =
            "INSERT INTO PRCompanyExternalNews (prcen_CompanyID, prcen_Code, prcen_PrimarySourceCode, prcen_CreatedBy, prcen_CreatedDate, prcen_UpdatedBy, prcen_UpdatedDate, prcen_Timestamp) " +
            "VALUES (@CompanyID, @Code, @PrimarySourceCode, -1, GETDATE(), -1, GETDATE(), GETDATE());";

        private const string SQL_UPDATE_FCODE =
            "UPDATE PRCompanyExternalNews SET  prcen_Code=@Code, prcen_UpdatedBy=-1, prcen_UpdatedDate=GETDATE() WHERE prcen_CompanyCodeID=@ID";

        private SqlCommand cenCommand = null;

        /// <summary>
        /// Helper method that inserts the PRCompanyExternalNews
        /// record.
        /// </summary>
        /// <param name="dbConn"></param>
        /// <param name="company"></param>
        private void InsertFCode(SqlConnection dbConn, Company company)
        {
            int iRecordID = FCodeRecordExists(dbConn, company);

            if (cenCommand == null)
            {
                cenCommand = dbConn.CreateCommand();

            }
            cenCommand.Parameters.Clear();

            if (iRecordID == 0)
            {
                cenCommand.CommandText = SQL_INSERT_FCODE;


                cenCommand.Parameters.AddWithValue("CompanyID", company.CompanyID);
                cenCommand.Parameters.AddWithValue("Code", company.NewsCode);
                cenCommand.Parameters.AddWithValue("PrimarySourceCode", "DowJones");
            }
            else
            {
                cenCommand.CommandText = SQL_UPDATE_FCODE;
                cenCommand.Parameters.AddWithValue("ID", iRecordID);
                cenCommand.Parameters.AddWithValue("Code", company.NewsCode);
            }

            cenCommand.ExecuteNonQuery();
        }

        private const string SQL_CEN_EXISTS =
            "SELECT prcen_CompanyCodeID FROM PRCompanyExternalNews WHERE prcen_CompanyID=@CompanyID AND prcen_PrimarySourceCode=@PrimarySourceCode;";
        private SqlCommand CENExistsCommand = null;
        private int FCodeRecordExists(SqlConnection dbConn, Company company)
        {
            if (CENExistsCommand == null)
            {
                CENExistsCommand = dbConn.CreateCommand();
                CENExistsCommand.CommandText = SQL_CEN_EXISTS;
            }

            CENExistsCommand.Parameters.Clear();
            CENExistsCommand.Parameters.AddWithValue("CompanyID", company.CompanyID);
            CENExistsCommand.Parameters.AddWithValue("PrimarySourceCode", "DowJones");
            object result = CENExistsCommand.ExecuteScalar();

            if (result == DBNull.Value)
            {
                return 0;
            }
            return Convert.ToInt32(result);
        }

        private SqlCommand cmdFCodeLookup = null;
        private const string SQL_INSERT_FCODE_LOOKUP =
            "INSERT INTO PRCompanyExternalNews (prcen_CompanyID, prcen_PrimarySourceCode, prcen_LastLookupDateTime, prcen_LookupCount, prcen_CreatedBy, prcen_CreatedDate, prcen_UpdatedBy, prcen_UpdatedDate, prcen_Timestamp) " +
            "VALUES (@CompanyID, @PrimarySourceCode, GETDATE(), 1, -1, GETDATE(), -1, GETDATE(), GETDATE());";

        private const string SQL_UPDATE_FCODE_LOOKUP =
            "UPDATE PRCompanyExternalNews SET  prcen_LastLookupDateTime=GETDATE(), prcen_LookupCount = prcen_LookupCount + 1, prcen_UpdatedBy=-1, prcen_UpdatedDate=GETDATE() WHERE prcen_CompanyCodeID=@ID";

        private void InsertFCodeLookupAttempt(SqlConnection dbConn, Company company)
        {
            int iRecordID = FCodeRecordExists(dbConn, company);

            if (cmdFCodeLookup == null)
            {
                cmdFCodeLookup = dbConn.CreateCommand();
            }
            cmdFCodeLookup.Parameters.Clear();
            
            if (iRecordID == 0)
            {
                cmdFCodeLookup.CommandText = SQL_INSERT_FCODE_LOOKUP;
                cmdFCodeLookup.Parameters.AddWithValue("CompanyID", company.CompanyID);
                cmdFCodeLookup.Parameters.AddWithValue("PrimarySourceCode", "DowJones");
            }
            else
            {
                cmdFCodeLookup.CommandText = SQL_UPDATE_FCODE_LOOKUP;
                cmdFCodeLookup.Parameters.AddWithValue("ID", iRecordID);
            }
            cmdFCodeLookup.ExecuteNonQuery();
        }


        private List<ExcludedSource> excludedSources = null;
        private bool IsSourceExcluded(string sourceCode, DateTime publishDate)
        {
            if (excludedSources == null)
            {
                excludedSources = new List<ExcludedSource>();
                int iCount = 0;


                string excludeSourceName = Utilities.GetConfigValue("DowJonesExcludeSourceCode" + iCount.ToString(), string.Empty);
                while (excludeSourceName.Length > 0)
                {
                    excludedSources.Add(new ExcludedSource(excludeSourceName.ToLower(),
                                                           Utilities.GetDateTimeConfigValue("DowJonesExcludeSourceCodeStartDate" + iCount.ToString())));

                    iCount++;
                    excludeSourceName = Utilities.GetConfigValue("DowJonesExcludeSourceCode" + iCount.ToString(), string.Empty);
                }
            }

            foreach (ExcludedSource excludedSource in excludedSources)
            {
                if ((sourceCode.ToLower() == excludedSource.SourceCode) &&
                    (publishDate >= excludedSource.ExcludeStartDate))
                {
                    return true;
                }
            }

            return false;
        }

        private const string SQL_INSERT_EXTERNAL_NEWS =
            "INSERT INTO PRExternalNews (pren_SubjectCompanyID, pren_Name, pren_Description, pren_URL, pren_PrimarySourceCode, pren_SecondarySourceCode, pren_SecondarySourceName, pren_PublishDateTime, pren_ExternalID, pren_CreatedBy, pren_CreatedDate, pren_UpdatedBy, pren_UpdatedDate, pren_Timestamp) " +
            "VALUES (@CompanyID, @Name, @Description, @URL, 'DowJones', @SecondarySourceCode, @SecondarySourceName, @PublishDateTime, @ExternalID, -1, GETDATE(), -1, GETDATE(), GETDATE());";

        private SqlCommand insertENCommand = null;

        /// <summary>
        /// This method saves the DJ data into our cache
        /// </summary>
        /// <param name="dbConn"></param>
        /// <param name="company"></param>
        /// <param name="xd"></param>
        private void SaveArticles(SqlConnection dbConn, Company company, XmlDocument xd)
        {
            List<string> lArticleList = new List<string>();


            XmlNodeList xmlNewsArticleList = xd.SelectNodes("News/Articles/Article");
            company.ArticleCount = xmlNewsArticleList.Count;

            foreach (XmlNode oNewsArticleNode in xmlNewsArticleList)
            {
                string szArticleID = Utils.GetNodeValue(oNewsArticleNode, "ArticleId");
                string szHeadline = Utils.GetNodeValue(oNewsArticleNode, "Headline");
                string szURL = Utils.GetNodeValue(oNewsArticleNode, "Link");
                string szSourceCode = Utils.GetNodeValue(oNewsArticleNode, "SourceCode");
                string szSourceName = Utils.GetNodeValue(oNewsArticleNode, "SourceName");
                DateTime dtPublishDate = Convert.ToDateTime(Utils.GetNodeValue(oNewsArticleNode, "PubDateTime"));
                string szSnippet = Utils.GetNodeValue(oNewsArticleNode, "Snippet");

                if ((!IsSourceExcluded(szSourceCode, dtPublishDate)) &&
                    (!DoesArticleExist(dbConn, company.CompanyID, szArticleID)))
                {
                    company.InsertedArticleCount++;

                    if (insertENCommand == null)
                    {
                        insertENCommand = dbConn.CreateCommand();
                        insertENCommand.CommandText = SQL_INSERT_EXTERNAL_NEWS;
                    }

                    insertENCommand.Parameters.Clear();
                    insertENCommand.Parameters.AddWithValue("CompanyID", company.CompanyID);
                    insertENCommand.Parameters.AddWithValue("Name", szHeadline);
                    insertENCommand.Parameters.AddWithValue("Description", GetStringForDB(szSnippet));
                    insertENCommand.Parameters.AddWithValue("URL", szURL);
                    insertENCommand.Parameters.AddWithValue("SecondarySourceCode", GetStringForDB(szSourceCode));
                    insertENCommand.Parameters.AddWithValue("SecondarySourceName", GetStringForDB(szSourceName));
                    insertENCommand.Parameters.AddWithValue("PublishDateTime", dtPublishDate);
                    insertENCommand.Parameters.AddWithValue("ExternalID", GetStringForDB(szArticleID));
                    insertENCommand.ExecuteNonQuery();
                }
            }
        }

        private const string SQL_DOES_ARTICLE_EXIST =
            "SELECT 'x' FROM PRExternalNews WHERE pren_SubjectCompanyID=@CompanyID AND pren_ExternalID=@ExternalID AND pren_PrimarySourceCode='DowJones'";
        private SqlCommand dupENCommand = null;

        protected bool DoesArticleExist(SqlConnection dbConn, int companyID, string articleID)
        {
            if (dupENCommand == null)
            {
                dupENCommand = dbConn.CreateCommand();
                dupENCommand.CommandText = SQL_DOES_ARTICLE_EXIST;
            }

            dupENCommand.Parameters.Clear();
            dupENCommand.Parameters.AddWithValue("CompanyID", companyID);
            dupENCommand.Parameters.AddWithValue("ExternalID", articleID);
            object result = dupENCommand.ExecuteScalar();

            if ((result == DBNull.Value) ||
                (result == null))
            {
                return false;
            }
            return true;
        }

        private const string SQL_UPDATE_CACHE_DATE =
            "UPDATE PRCompanyExternalNews SET prcen_LastRetrievalDateTime=GETDATE(), prcen_UpdatedDate=GETDATE(), prcen_UpdatedBy=-1, prcen_Timestamp=GETDATE() WHERE prcen_CompanyID = @CompanyID";

        private SqlCommand updateCacheDate = null;

        /// <summary>
        /// This method updates the cache date for the specified company
        /// for this news provider.
        /// </summary>
        /// <param name="dbConn"></param>
        /// <param name="company"></param>
        private void UpdateCacheDate(SqlConnection dbConn, Company company)
        {
            if (updateCacheDate == null)
            {
                updateCacheDate = dbConn.CreateCommand();
                updateCacheDate.CommandText = SQL_UPDATE_CACHE_DATE;
            }

            updateCacheDate.Parameters.Clear();
            updateCacheDate.Parameters.AddWithValue("CompanyID", company.CompanyID);
            updateCacheDate.ExecuteNonQuery();
        }

        private const string SQL_UPDATE_REMAINING_CACHE_DATE =
        "UPDATE PRCompanyExternalNews SET prcen_LastRetrievalDateTime=GETDATE(), prcen_UpdatedDate=GETDATE(), prcen_UpdatedBy=-1, prcen_Timestamp=GETDATE() WHERE 1=1 {0}";

        /// <summary>
        /// This method updates the cache date for multiple companies
        /// using the specified additional criteria.
        /// </summary>
        /// <param name="dbConn"></param>
        /// <param name="additionalCriteria"></param>
        private void UpdateCacheDate(SqlConnection dbConn, string additionalCriteria)
        {
            SqlCommand updateRemainingCacheDate = dbConn.CreateCommand();
            updateRemainingCacheDate.CommandText = string.Format(SQL_UPDATE_REMAINING_CACHE_DATE, additionalCriteria);
            updateRemainingCacheDate.ExecuteNonQuery();
        }

        private string _szXMLFilePath = null;

        /// <summary>
        /// Helper method that writes the last read XML stream
        /// to a file on disk.  Though this may be called multiple
        /// times on a CRM company the file is only written once.
        /// </summary>
        /// <param name="company"></param>
        private void WriteXMLToDisk(Company company)
        {
            if (!company.WrittenToDisk)
            {

                if (_szXMLFilePath == null)
                {
                    _szXMLFilePath = Utilities.GetConfigValue("DowJonesXMLFilePath",
                                                              Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location));
                }

                string szOutputDirectory = Utilities.GetConfigValue("DowJonesXMLFolder", _szXMLFilePath);
                string szOutputFile = Path.Combine(szOutputDirectory, action + "_" + company.CompanyID.ToString() + ".xml");
                using (StreamWriter sw = new StreamWriter(szOutputFile))
                {
                    sw.Write(_xmlResult);
                }

                company.WrittenToDisk = true;
            }
        }

        /// <summary>
        /// This method iterates through the XML looking for Dow Jones
        /// error codes.  If any are found, the codes are added to the
        /// error buffer and a message written to the log.
        /// </summary>
        /// <param name="company"></param>
        /// <param name="xd"></param>
        /// <returns></returns>
        protected bool CheckForError(Company company, XmlDocument xd)
        {
            bool error = false;

            XmlNodeList xmlErrNodeList = xd.SelectNodes("ErrorResponse/Error/Error");
            foreach (XmlNode oNode in xmlErrNodeList)
            {
                string szCode = Utils.GetNodeValue(oNode, "Code");
                string szMessage = Utils.GetNodeValue(oNode, "Message");

                // 520150 really means the FCode is not "NewsCoded".  We have no way of know which 
                // FCodes are "NewsCoded", so let's not consider this an error.
                if (szCode != "520160")
                {
                    error = true;

                    _lErrors.Add(company.CompanyID + " " + szCode + ": " + szMessage);
                    WriteToLog(company.CompanyID, "DowJones Error " + szCode + ": " + szMessage);
                }
            }

            if (error)
            {
                company.DowJonesError = true;
                return true;
            }

            return false;
        }

        public List<string> GetErrorList()
        {
            return _lErrors;
        }

        public List<string> GetMultipleMatchingResultsList()
        {
            return _lMultipleMatchingResults;
        }

        /// <summary>
        /// These following properietes are intended for use when
        /// searching for FCodes on a single company.
        /// </summary>
        public int MatchCount = 0;
        public string xmlResult = null;
        public int StatusCode = 0;
        public string StatusMessage = null;

        public const int STATUS_SUCCESS = 0;

        public const int STATUS_NOT_FOUND = 10;
        public const int STATUS_NO_MATCH = 20;
        public const int STATUS_MULTIPLE_MATCH = 30;
        public const int STATUS_ERROR = 100;
        public const int STATUS_PROCESSING_EXCEPTION = 200;
    }
}
