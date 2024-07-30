using System;
using System.Configuration;
using System.Collections.Generic;
using System.Collections;
using System.Linq;
using System.Text;
using System.IO;
using System.Data;
using System.Data.OleDb;
using System.Data.SqlClient;
using CommandLine.Utility;
using System.Data.Common;
using System.Text.RegularExpressions;

namespace CompanyMatching
{
    class NRLACompanyComparer
    {
        DateTime _startTime;

        List<NRLACompany> _allLumberCompanies = new List<NRLACompany>();

        int _companiesSearchedCounter = 0;
        int _companiesMatchedCounter = 0;
        int _companiesUnmatchedCounter = 0;
        int _sectionOneCompaniesMatched = 0;
        int _sectionOneCompaniesUnmatched = 0;

        string _matchedCompaniesFile = null;
        string _unMatchedCompaniesFile = null;

        private const string OUTPUT_FILE_MATCHED = "Matched";
        private const string OUTPUT_FILE_UNMATCHED = "UnMatched";

        private const string SQL_GET_ALL_LUMBER_COMPANIES =
            "SELECT comp_CompanyID, comp_Name, comp_PRIndustryType, comp_PRListingStatus, comp_PRLegalName, comp_PRHQId, " +
            "ma.Addr_Address1 as MailingAddress1, ma.Addr_Address2 as MailingAddress2, ma.Addr_Address3 as MailingAddress3, ma.CityStateCountryShort as MailingAddressCSCS, ma.Addr_PostCode as MailingAddressPostCode, " +
            "pa.Addr_Address1 as PhysicalAddress1, pa.Addr_Address2 as PhysicalAddress2, pa.Addr_Address3 as PhysicalAddress3, pa.CityStateCountryShort as PhysicalAddressCSCS, pa.Addr_PostCode as PhysicalAddressPostCode, " +
            "phon_PhoneMatch, " +
            "dbo.ufn_GetCompanyPhone(comp_CompanyID, 'Y', null, 'P', null) As 'DefaultPhone', " +
            "dbo.ufn_GetCompanyPhone(comp_CompanyID, 'Y', null, 'F', null) As 'DefaultFax', " +
            "emai_PRWebAddress As 'DefaultWeb', " +
            "dbo.ufn_GetCompanyEmail(comp_CompanyID, 'Y', null) As 'DefaultEmail' " +
            "FROM Company WITH (NOLOCK) " +
            "LEFT OUTER JOIN vPRAddress ma WITH (NOLOCK) ON ma.adli_CompanyID = comp_CompanyID AND ma.adli_Type = 'M' " +
            "LEFT OUTER JOIN vPRAddress pa WITH (NOLOCK) ON pa.adli_CompanyID = comp_CompanyID AND pa.adli_Type = 'PH' " +
            "LEFT OUTER JOIN Email WITH (NOLOCK) ON Emai_CompanyID = comp_CompanyID AND Emai_PersonID IS NULL AND Emai_Type = 'W' " +
            "LEFT OUTER JOIN Phone WITH (NOLOCK) ON Phon_CompanyID = comp_CompanyID AND phon_PersonID IS NULL " +
            "WHERE comp_PRIndustryType = 'L'";

        private const string SQL_SCAN_EXCEL_FILE =
            "SELECT NRLA_COMPANY, NRLA_ADDRESS_PRIMARY, NRLA_ADDRESS_SECONDARY, NRLA_CITY, NRLA_STATE, " +
            "NRLA_ZIPCODE, NRLA_COUNTRY, NRLA_PHONE, NRLA_URL, NRLA_STATUS, " +
            "HQ_COMPANY, HQ_ADDRESS_PRIMARY, HQ_ADDRESS_SECONDARY, HQ_CITY, HQ_STATE, " +
            "HQ_ZIPCODE, HQ_COUNTRY, HQ_PHONE, HQ_TOLL_FREE, HQ_FAX, HQ_URL, HQ_EMAIL, HQ_REC_ID, OKS_BATCH_ID, OKS_COMMENT " +
            "FROM {0}";

        private const string SQL_INSERT_MATCHED_COMPANY_OUTPUT =
            "INSERT INTO [Sheet1$] " +
            "(Match_Type, BBID, COMP_PRHQ_ID, Industry_Type, Listing_Status, CRM_Company_Name, CRM_Mailing_Address, CRM_Physical_Address, CRM_Default_Phone, " +
            "CRM_Default_Fax, CRM_Default_Web, CRM_Default_Email, " +
            "NRLA_COMPANY, NRLA_ADDRESS_PRIMARY, NRLA_ADDRESS_SECONDARY, NRLA_CITY, NRLA_STATE, " +
            "NRLA_ZIPCODE, NRLA_COUNTRY, NRLA_PHONE, NRLA_URL, NRLA_STATUS, " +
            "HQ_COMPANY, HQ_ADDRESS_PRIMARY, HQ_ADDRESS_SECONDARY, HQ_CITY, HQ_STATE, " +
            "HQ_ZIPCODE, HQ_COUNTRY, HQ_PHONE, HQ_TOLL_FREE, HQ_FAX, HQ_URL, HQ_EMAIL, HQ_REC_ID, OKS_BATCH_ID, OKS_COMMENT) " +
            "VALUES " +
            "(\"{0}\",{1},{2},\"{3}\",\"{4}\",\"{5}\",\"{6}\",\"{7}\",\"{8}\",\"{9}\",\"{10}\",\"{11}\",\"{12}\",\"{13}\", " +
            "\"{14}\",\"{15}\",\"{16}\",\"{17}\",\"{18}\",\"{19}\",\"{20}\",\"{21}\",\"{22}\",\"{23}\",\"{24}\",\"{25}\", " +
            "\"{26}\",\"{27}\",\"{28}\",\"{29}\",\"{30}\",\"{31}\",\"{32}\",\"{33}\",{34},{35},\"{36}\")";

        private const string SQL_INSERT_UNMATCHED_COMPANY_OUTPUT =
           "INSERT INTO [Sheet1$] " +
           "(NRLA_COMPANY, NRLA_ADDRESS_PRIMARY, NRLA_ADDRESS_SECONDARY, NRLA_CITY, NRLA_STATE, " +
           "NRLA_ZIPCODE, NRLA_COUNTRY, NRLA_PHONE, NRLA_URL, NRLA_STATUS, " +
           "HQ_COMPANY, HQ_ADDRESS_PRIMARY, HQ_ADDRESS_SECONDARY, HQ_CITY, HQ_STATE, " +
           "HQ_ZIPCODE, HQ_COUNTRY, HQ_PHONE, HQ_TOLL_FREE, HQ_FAX, HQ_URL, HQ_EMAIL, HQ_REC_ID, OKS_BATCH_ID, OKS_COMMENT) " +
           "VALUES " +
           "(\"{0}\",\"{1}\",\"{2}\",\"{3}\",\"{4}\",\"{5}\",\"{6}\",\"{7}\",\"{8}\",\"{9}\",\"{10}\",\"{11}\", " +
           "\"{12}\",\"{13}\",\"{14}\",\"{15}\",\"{16}\",\"{17}\",\"{18}\",\"{19}\",\"{20}\",\"{21}\",{22},{23},\"{24}\")";

        protected SqlConnection _dbConn = null;

        public NRLACompanyComparer()
        {
            _startTime = DateTime.Now;

            try
            {
                ConsoleWriter.InitializeConsole();
                TextLogWriter.InitializeLog(_startTime);

                CreateExcelFile(OUTPUT_FILE_MATCHED, _startTime);
                CreateExcelFile(OUTPUT_FILE_UNMATCHED, _startTime);

                GetAllLumberCompanies();
                Compare();

                DateTime endTime = DateTime.Now;

                TextLogWriter.FinalizeLog(_startTime, endTime);
                ConsoleWriter.FinalizeConsole(_startTime, endTime);
            }
            catch (Exception e)
            {
                TextLogWriter.WriteException(e);
                ConsoleWriter.WriteException(e);
                return;
            }
        }

        protected void GetAllLumberCompanies()
        {
            ConsoleWriter.WriteExecutionStatus("Fetching CRM Companies...");

            _dbConn = new SqlConnection(ConfigurationManager.ConnectionStrings["CRM"].ConnectionString);

            SqlCommand cmd = _dbConn.CreateCommand();
            cmd.CommandTimeout = Convert.ToInt32(ConfigurationManager.AppSettings["CommandTimeout"]);
            cmd.CommandText = SQL_GET_ALL_LUMBER_COMPANIES;

            _dbConn.Open();

            using (IDataReader dr = cmd.ExecuteReader())
            {
                while (dr.Read())
                {
                    NRLACompany company = new NRLACompany();
                    company.BBID = GetIntValue(dr, "comp_CompanyID");
                    company.CRMCompanyName = GetStringValue(dr, "comp_Name");
                    company.CRMLegalName = GetStringValue(dr, "comp_PRLegalName");
                    company.CRMCompPRHQID = GetIntValue(dr, "comp_PRHQId");
                    company.IndustryType = GetStringValue(dr, "comp_PRIndustryType");
                    company.ListingStatus = GetStringValue(dr, "comp_PRListingStatus");

                    StringBuilder address = new StringBuilder();
                    address.Append(GetStringValue(dr, "MailingAddress1"));
                    address.Append(string.Empty);
                    address.Append(GetStringValue(dr, "MailingAddress2"));
                    address.Append(string.Empty);
                    address.Append(GetStringValue(dr, "MailingAddress3"));
                    address.Append(string.Empty);
                    address.Append(GetStringValue(dr, "MailingAddressCSCS"));
                    address.Append(string.Empty);
                    address.Append(GetStringValue(dr, "MailingAddressPostCode"));

                    company.CRMMailingAddress = address.ToString();

                    address.Remove(0, address.Length);
                    address.Append(GetStringValue(dr, "PhysicalAddress1"));
                    address.Append(string.Empty);
                    address.Append(GetStringValue(dr, "PhysicalAddress2"));
                    address.Append(string.Empty);
                    address.Append(GetStringValue(dr, "PhysicalAddress3"));
                    address.Append(string.Empty);
                    address.Append(GetStringValue(dr, "PhysicalAddressCSCS"));
                    address.Append(string.Empty);
                    address.Append(GetStringValue(dr, "PhysicalAddressPostCode"));

                    company.CRMPhysicalAddress = address.ToString();
                    company.CRMDefaultPhone = GetStringValue(dr, "DefaultPhone");
                    company.CRMDefaultFax = GetStringValue(dr, "DefaultFax");
                    company.CRMDefaultWeb = GetStringValue(dr, "DefaultWeb");
                    company.CRMDefaultEmail = GetStringValue(dr, "DefaultEmail");
                    company.PhoneForMatch = GetStringValue(dr, "phon_PhoneMatch");

                    _allLumberCompanies.Add(company);
                }
            }

            _dbConn.Close();

        }

        protected void Compare()
        {
            string filePath = ConfigurationManager.AppSettings["InputDataFile"].ToString();
            string msExcelConn = String.Format(ConfigurationManager.AppSettings["msExcelConn"].ToString(), filePath);

            DbProviderFactory factory = DbProviderFactories.GetFactory("System.Data.OleDb");

            using (DbConnection connection = factory.CreateConnection())
            {
                connection.ConnectionString = msExcelConn;
                connection.Open();

                ConsoleWriter.WriteCompanyComparedText();

                SearchSectionOne(connection);

                connection.Close();

                ConsoleWriter.WriteTotalAnalysis(_companiesMatchedCounter, _companiesUnmatchedCounter);
                TextLogWriter.WriteSectionData("Total Analysis", _companiesSearchedCounter, _companiesMatchedCounter, _companiesUnmatchedCounter);
            }
        }


        protected void InsertExcelMatchedCompany(NRLACompany company)
        {
            DbProviderFactory factory = DbProviderFactories.GetFactory("System.Data.OleDb");

            using (DbConnection connection = factory.CreateConnection())
            {
                string msExcelConn = String.Format(ConfigurationManager.AppSettings["msExcelConn"].ToString(), _matchedCompaniesFile);

                connection.ConnectionString = msExcelConn;
                connection.Open();

                using (DbCommand command = connection.CreateCommand())
                {
                    object[] values = { company.MatchType, company.BBID, company.CRMCompPRHQID, company.IndustryType, company.ListingStatus, company.CRMCompanyName,
                                        company.CRMMailingAddress, company.CRMPhysicalAddress, company.CRMDefaultPhone, company.CRMDefaultFax,
                                        company.CRMDefaultWeb, company.CRMDefaultEmail, company.NRLACompanyName, company.NRLAddressPrimary,
                                        company.NRLAddressSecondary, company.NRLACity, company.NRLAState, company.NRLAZipCode, company.NRLACountry,
                                        company.NRLAPhone, company.NRLAURL, company.NRLAStatus, company.HQCompany, company.HQAddressPrimary,
                                        company.HQAddressSecondary, company.HQCity, company.HQState, company.HQZipCode, company.HQCountry,
                                        company.HQPhone, company.HQTollFree, company.HQFax, company.HQURL, company.HQEmail, company.HQRecID,
                                        company.OKsBatchID, company.OKsComment};     


                    command.CommandText = String.Format(SQL_INSERT_MATCHED_COMPANY_OUTPUT, values);
                    command.ExecuteNonQuery();
                }
            }
        }

        protected void InsertExcelUnmatchedCompany(NRLACompany company)
        {
            DbProviderFactory factory = DbProviderFactories.GetFactory("System.Data.OleDb");

            using (DbConnection connection = factory.CreateConnection())
            {
                string msExcelConn = String.Format(ConfigurationManager.AppSettings["msExcelConn"].ToString(), _unMatchedCompaniesFile);

                connection.ConnectionString = msExcelConn;
                connection.Open();

                using (DbCommand command = connection.CreateCommand())
                {
                    object[] values = { company.NRLACompanyName, company.NRLAddressPrimary,company.NRLAddressSecondary, company.NRLACity, 
                                        company.NRLAState, company.NRLAZipCode, company.NRLACountry, company.NRLAPhone, company.NRLAURL, 
                                        company.NRLAStatus, company.HQCompany, company.HQAddressPrimary,
                                        company.HQAddressSecondary, company.HQCity, company.HQState, company.HQZipCode, company.HQCountry,
                                        company.HQPhone, company.HQTollFree, company.HQFax, company.HQURL, company.HQEmail, company.HQRecID,
                                        company.OKsBatchID, company.OKsComment};         
                    
                    command.CommandText = String.Format(SQL_INSERT_UNMATCHED_COMPANY_OUTPUT, values);
                    command.ExecuteNonQuery();
                }
            }
        }

        protected void SearchSectionOne(DbConnection connection)
        {
            using (DbCommand command = connection.CreateCommand())
            {
                command.CommandText = String.Format(SQL_SCAN_EXCEL_FILE, "[NRLA_RETAIL$]");

                using (DbDataReader dr = command.ExecuteReader())
                {
                    ConsoleWriter.WriteExecutionStatus("Scanning Section NRLA_RETAIL...   ");

                    int i = 0;

                    while (dr.Read())
                    {
                        NRLACompany company = InitializeCompany(dr, 1);

                        if (!string.IsNullOrEmpty(company.NRLACompanyName))
                        {
                            i++;
                            _companiesSearchedCounter++;

                            ConsoleWriter.WriteCurrentCompanySearched(_companiesSearchedCounter);

                            if (IsCompanyMatchFound(company))
                            {
                                _sectionOneCompaniesMatched++;
                                _companiesMatchedCounter++;
                                InsertExcelMatchedCompany(company);
                            }
                            else
                            {
                                _sectionOneCompaniesUnmatched++;
                                _companiesUnmatchedCounter++;
                                InsertExcelUnmatchedCompany(company);
                            }

                        }
                    }

                    ConsoleWriter.WriteSectionData("Section NRLA_RETAIL Analysis", i, _sectionOneCompaniesMatched, _sectionOneCompaniesUnmatched);
                    TextLogWriter.WriteSectionData("Section NRLA_RETAIL Analysis", i, _sectionOneCompaniesMatched, _sectionOneCompaniesUnmatched);
                }
            }
        }

        protected bool IsCompanyMatchFound(NRLACompany company)
        {
            if (IsMatchedByHQPhone(company))
                return true;
            else if (IsMatchedByHQFax(company))
                return true;
            else if (IsMatchedByHQURL(company))
                return true;
            else if (IsMatchedByHQCompanyName(company))
                return true;
            else if (IsMatchedByNRLAPhone(company))
                return true;
            else if (IsMatchedByNRLAURL(company))
                return true;
            else if (IsMatchedByNRLACompanyName(company))
                return true;
            else
                return false;
        }

        protected bool IsMatchedByHQPhone(NRLACompany company)
        {
            if (!string.IsNullOrEmpty(company.HQPhone))
            {
                string phoneCleared = company.HQPhone.Replace("-", "");

                var matchedCompany = _allLumberCompanies.FirstOrDefault(p => p.PhoneForMatch.Replace("-", "") == phoneCleared);

                if (matchedCompany != null)
                {
                    SetCompanyAttributes(company, matchedCompany, Enum.GetName(typeof(NRLACompany.MatchTypes), NRLACompany.MatchTypes.HQPhone));
                    return true;
                }
            }

            return false;
        }

        protected bool IsMatchedByHQFax(NRLACompany company)
        {
            if (!string.IsNullOrEmpty(company.HQFax))
            {
                string faxCleared = company.HQFax.Replace("-", "");

                var matchedCompany = _allLumberCompanies.FirstOrDefault(p => p.PhoneForMatch.Replace("-", "") == faxCleared);

                if (matchedCompany != null)
                {
                    SetCompanyAttributes(company, matchedCompany, Enum.GetName(typeof(NRLACompany.MatchTypes), NRLACompany.MatchTypes.HQFax));
                    return true;
                }
            }

            return false;
        }

        protected bool IsMatchedByHQURL(NRLACompany company)
        {
            if (!string.IsNullOrEmpty(company.HQURL))
            {
                var matchedCompany = _allLumberCompanies.FirstOrDefault(p => p.CRMDefaultWeb == company.HQURL);

                if (matchedCompany != null)
                {
                    SetCompanyAttributes(company, matchedCompany, Enum.GetName(typeof(NRLACompany.MatchTypes), NRLACompany.MatchTypes.HQURL));
                    return true;
                }
            }

            return false;
        }

        protected bool IsMatchedByHQCompanyName(NRLACompany company)
        {
            if (!string.IsNullOrEmpty(company.HQCompany))
            {
                var matchedCompany = _allLumberCompanies.FirstOrDefault(p => ProcessCompanyName(p.CRMCompanyName) == ProcessCompanyName(company.HQCompany)
                        || ProcessCompanyName(p.CRMLegalName) == ProcessCompanyName(company.HQCompany));

                if (matchedCompany != null)
                {
                    SetCompanyAttributes(company, matchedCompany, Enum.GetName(typeof(NRLACompany.MatchTypes), NRLACompany.MatchTypes.HQCompanyName));
                    return true;
                }
            }

            return false;
        }

        protected bool IsMatchedByNRLAPhone(NRLACompany company)
        {
            if (!string.IsNullOrEmpty(company.NRLAPhone))
            {
                string phoneCleared = company.NRLAPhone.Replace("-", "");

                var matchedCompany = _allLumberCompanies.FirstOrDefault(p => p.PhoneForMatch.Replace("-", "") == phoneCleared);

                if (matchedCompany != null)
                {
                    SetCompanyAttributes(company, matchedCompany, Enum.GetName(typeof(NRLACompany.MatchTypes), NRLACompany.MatchTypes.NRLAPhone));
                    return true;
                }
            }

            return false;
        }

        protected bool IsMatchedByNRLAURL(NRLACompany company)
        {
            if (!string.IsNullOrEmpty(company.NRLAURL))
            {
                var matchedCompany = _allLumberCompanies.FirstOrDefault(p => p.CRMDefaultWeb == company.NRLAURL);

                if (matchedCompany != null)
                {
                    SetCompanyAttributes(company, matchedCompany, Enum.GetName(typeof(NRLACompany.MatchTypes), NRLACompany.MatchTypes.NRLAURL));
                    return true;
                }
            }

            return false;
        }

        protected bool IsMatchedByNRLACompanyName(NRLACompany company)
        {
            if (!string.IsNullOrEmpty(company.NRLACompanyName))
            {
                var matchedCompany = _allLumberCompanies.FirstOrDefault(p => ProcessCompanyName(p.CRMCompanyName) == ProcessCompanyName(company.NRLACompanyName)
                        || ProcessCompanyName(p.CRMLegalName) == ProcessCompanyName(company.NRLACompanyName));

                if (matchedCompany != null)
                {
                    SetCompanyAttributes(company, matchedCompany, Enum.GetName(typeof(NRLACompany.MatchTypes), NRLACompany.MatchTypes.NRLACompanyName));
                    return true;
                }
            }

            return false;
        }

        protected void SetCompanyAttributes(NRLACompany company, NRLACompany matchedCompany, string matchType)
        {
            company.MatchType = matchType;
            company.BBID = matchedCompany.BBID;
            company.CRMCompanyName = matchedCompany.CRMCompanyName;
            company.CRMLegalName = matchedCompany.CRMLegalName;
            company.IndustryType = matchedCompany.IndustryType;
            company.ListingStatus = matchedCompany.ListingStatus;
            company.CRMMailingAddress = matchedCompany.CRMMailingAddress;
            company.CRMPhysicalAddress = matchedCompany.CRMPhysicalAddress;
            company.CRMDefaultPhone = matchedCompany.CRMDefaultPhone;
            company.CRMDefaultFax = matchedCompany.CRMDefaultFax;
            company.CRMDefaultWeb = matchedCompany.CRMDefaultWeb;
            company.CRMDefaultEmail = matchedCompany.CRMDefaultEmail;
        }

        protected NRLACompany InitializeCompany(DbDataReader dr, int section)
        {
            NRLACompany company = new NRLACompany();

            company.NRLACompanyName = GetStringValue(dr, "NRLA_COMPANY");
            company.NRLAPhone = GetStringValue(dr, "NRLA_PHONE");
            company.NRLAURL = GetStringValue(dr, "NRLA_URL");
            company.NRLAddressPrimary = GetStringValue(dr, "NRLA_ADDRESS_PRIMARY");
            company.NRLAddressSecondary = GetStringValue(dr, "NRLA_ADDRESS_SECONDARY");
            company.NRLACity = GetStringValue(dr, "NRLA_CITY");
            company.NRLAState = GetStringValue(dr, "NRLA_STATE");
            company.NRLAZipCode = GetStringValue(dr, "NRLA_ZIPCODE");
            company.NRLACountry = GetStringValue(dr, "NRLA_COUNTRY");
            company.NRLAStatus = GetStringValue(dr, "NRLA_STATUS");
            company.HQCompany = GetStringValue(dr, "HQ_COMPANY");
            company.HQAddressPrimary = GetStringValue(dr, "HQ_ADDRESS_PRIMARY");
            company.HQAddressSecondary = GetStringValue(dr, "HQ_ADDRESS_SECONDARY");

            company.HQCity = GetStringValue(dr, "HQ_CITY");
            company.HQState = GetStringValue(dr, "HQ_STATE");
            company.HQZipCode = GetStringValue(dr, "HQ_ZIPCODE");
            company.HQCountry = GetStringValue(dr, "HQ_COUNTRY");
            company.HQPhone = GetStringValue(dr, "HQ_PHONE");
            company.HQTollFree = GetStringValue(dr, "HQ_TOLL_FREE");
            company.HQFax = GetStringValue(dr, "HQ_FAX");
            company.HQURL = GetStringValue(dr, "HQ_URL");
            company.HQEmail = GetStringValue(dr, "HQ_EMAIL");

            company.HQRecID = GetIntValue(dr, "HQ_REC_ID");
            company.OKsBatchID = GetIntValue(dr, "OKS_BATCH_ID");
            company.OKsComment = GetStringValue(dr, "OKS_COMMENT");

            return company;
        }

        protected void CreateExcelFile(string fileType, DateTime startTime)
        {
            Microsoft.Office.Interop.Excel.Application xlApp;
            Microsoft.Office.Interop.Excel.Workbook xlWorkBook;
            Microsoft.Office.Interop.Excel.Worksheet xlWorkSheet;
            object misValue = System.Reflection.Missing.Value;

            xlApp = new Microsoft.Office.Interop.Excel.ApplicationClass();
            xlWorkBook = xlApp.Workbooks.Add(misValue);

            string fileDetails = String.Format("{0:s}", startTime).Replace("-", "").Replace(":", "").Replace("T", "_");

            if (fileType == OUTPUT_FILE_MATCHED)
            {
                xlWorkSheet = (Microsoft.Office.Interop.Excel.Worksheet)xlWorkBook.Worksheets.get_Item(1);
                xlWorkSheet.Cells[1, 1] = "Match_Type";
                xlWorkSheet.Cells[1, 2] = "BBID";
                xlWorkSheet.Cells[1, 3] = "COMP_PRHQ_ID";
                xlWorkSheet.Cells[1, 4] = "Industry_Type";
                xlWorkSheet.Cells[1, 5] = "Listing_Status";
                xlWorkSheet.Cells[1, 6] = "CRM_Company_Name";
                xlWorkSheet.Cells[1, 7] = "CRM_Mailing_Address";
                xlWorkSheet.Cells[1, 8] = "CRM_Physical_Address";
                xlWorkSheet.Cells[1, 9] = "CRM_Default_Phone";
                xlWorkSheet.Cells[1, 10] = "CRM_Default_Fax";
                xlWorkSheet.Cells[1, 11] = "CRM_Default_Web";
                xlWorkSheet.Cells[1, 12] = "CRM_Default_Email";
                xlWorkSheet.Cells[1, 13] = "NRLA_COMPANY";
                xlWorkSheet.Cells[1, 14] = "NRLA_ADDRESS_PRIMARY";
                xlWorkSheet.Cells[1, 15] = "NRLA_ADDRESS_SECONDARY";
                xlWorkSheet.Cells[1, 16] = "NRLA_CITY";
                xlWorkSheet.Cells[1, 17] = "NRLA_STATE";
                xlWorkSheet.Cells[1, 18] = "NRLA_ZIPCODE";
                xlWorkSheet.Cells[1, 19] = "NRLA_COUNTRY";
                xlWorkSheet.Cells[1, 20] = "NRLA_PHONE";
                xlWorkSheet.Cells[1, 21] = "NRLA_URL";
                xlWorkSheet.Cells[1, 22] = "NRLA_STATUS";
                xlWorkSheet.Cells[1, 23] = "HQ_COMPANY";
                xlWorkSheet.Cells[1, 24] = "HQ_ADDRESS_PRIMARY";
                xlWorkSheet.Cells[1, 25] = "HQ_ADDRESS_SECONDARY";
                xlWorkSheet.Cells[1, 26] = "HQ_CITY";
                xlWorkSheet.Cells[1, 27] = "HQ_STATE";
                xlWorkSheet.Cells[1, 28] = "HQ_ZIPCODE";
                xlWorkSheet.Cells[1, 29] = "HQ_COUNTRY";
                xlWorkSheet.Cells[1, 30] = "HQ_PHONE";
                xlWorkSheet.Cells[1, 31] = "HQ_TOLL_FREE";
                xlWorkSheet.Cells[1, 32] = "HQ_FAX";
                xlWorkSheet.Cells[1, 33] = "HQ_URL";
                xlWorkSheet.Cells[1, 34] = "HQ_EMAIL";
                xlWorkSheet.Cells[1, 35] = "HQ_REC_ID";
                xlWorkSheet.Cells[1, 36] = "OKS_BATCH_ID";
                xlWorkSheet.Cells[1, 37] = "OKS_COMMENT";

                _matchedCompaniesFile = ConfigurationManager.AppSettings["MatchedCompaniesFile"].ToString() + "_" + fileDetails + ".xls";
                xlWorkBook.SaveAs(_matchedCompaniesFile, Microsoft.Office.Interop.Excel.XlFileFormat.xlWorkbookNormal, misValue, misValue, misValue, misValue, Microsoft.Office.Interop.Excel.XlSaveAsAccessMode.xlExclusive, misValue, misValue, misValue, misValue, misValue);
            }
            else
            {
                xlWorkSheet = (Microsoft.Office.Interop.Excel.Worksheet)xlWorkBook.Worksheets.get_Item(1);
                xlWorkSheet.Cells[1, 1] = "NRLA_COMPANY";
                xlWorkSheet.Cells[1, 2] = "NRLA_ADDRESS_PRIMARY";
                xlWorkSheet.Cells[1, 3] = "NRLA_ADDRESS_SECONDARY";
                xlWorkSheet.Cells[1, 4] = "NRLA_CITY";
                xlWorkSheet.Cells[1, 5] = "NRLA_STATE";
                xlWorkSheet.Cells[1, 6] = "NRLA_ZIPCODE";
                xlWorkSheet.Cells[1, 7] = "NRLA_COUNTRY";
                xlWorkSheet.Cells[1, 8] = "NRLA_PHONE";
                xlWorkSheet.Cells[1, 9] = "NRLA_URL";
                xlWorkSheet.Cells[1, 10] = "NRLA_STATUS";
                xlWorkSheet.Cells[1, 11] = "HQ_COMPANY";
                xlWorkSheet.Cells[1, 12] = "HQ_ADDRESS_PRIMARY";
                xlWorkSheet.Cells[1, 13] = "HQ_ADDRESS_SECONDARY";
                xlWorkSheet.Cells[1, 14] = "HQ_CITY";
                xlWorkSheet.Cells[1, 15] = "HQ_STATE";
                xlWorkSheet.Cells[1, 16] = "HQ_ZIPCODE";
                xlWorkSheet.Cells[1, 17] = "HQ_COUNTRY";
                xlWorkSheet.Cells[1, 18] = "HQ_PHONE";
                xlWorkSheet.Cells[1, 19] = "HQ_TOLL_FREE";
                xlWorkSheet.Cells[1, 20] = "HQ_FAX";
                xlWorkSheet.Cells[1, 21] = "HQ_URL";
                xlWorkSheet.Cells[1, 22] = "HQ_EMAIL";
                xlWorkSheet.Cells[1, 23] = "HQ_REC_ID";
                xlWorkSheet.Cells[1, 24] = "OKS_BATCH_ID";
                xlWorkSheet.Cells[1, 25] = "OKS_COMMENT";

                _unMatchedCompaniesFile = ConfigurationManager.AppSettings["UnMatchedCompaniesFile"].ToString() + "_" + fileDetails + ".xls";
                xlWorkBook.SaveAs(_unMatchedCompaniesFile, Microsoft.Office.Interop.Excel.XlFileFormat.xlWorkbookNormal, misValue, misValue, misValue, misValue, Microsoft.Office.Interop.Excel.XlSaveAsAccessMode.xlExclusive, misValue, misValue, misValue, misValue, misValue);
            }

            xlWorkBook.Close(true, misValue, misValue);
            xlApp.Quit();

            releaseObject(xlWorkSheet);
            releaseObject(xlWorkBook);
            releaseObject(xlApp);
        }

        private void releaseObject(object obj)
        {
            try
            {
                System.Runtime.InteropServices.Marshal.ReleaseComObject(obj);
                obj = null;
            }
            catch (Exception ex)
            {
                obj = null;
            }
            finally
            {
                GC.Collect();
            }
        }

        public string ProcessCompanyName(string name)
        {
            if (!String.IsNullOrEmpty(name))
            {
                string nameAlphaOnly = Regex.Replace(name, "[\\W]", "").ToLower();

                if (nameAlphaOnly.EndsWith("companyinc"))
                {
                    return nameAlphaOnly.Substring(0, nameAlphaOnly.Length - 10);
                }

                if (nameAlphaOnly.EndsWith("company"))
                {
                    return nameAlphaOnly.Substring(0, nameAlphaOnly.Length - 7);
                }

                if ((nameAlphaOnly.EndsWith("coinc")) ||
                    (nameAlphaOnly.EndsWith("collc")) ||
                    (nameAlphaOnly.EndsWith("coltd")))
                {
                    return nameAlphaOnly.Substring(0, nameAlphaOnly.Length - 5);
                }

                if (nameAlphaOnly.EndsWith("corp"))
                {
                    return nameAlphaOnly.Substring(0, nameAlphaOnly.Length - 4);
                }

                if ((nameAlphaOnly.EndsWith("inc")) ||
                  (nameAlphaOnly.EndsWith("llc")) ||
                  (nameAlphaOnly.EndsWith("ltd")))
                {
                    return nameAlphaOnly.Substring(0, nameAlphaOnly.Length - 3);
                }

                if (nameAlphaOnly.EndsWith("co"))
                {
                    return nameAlphaOnly.Substring(0, nameAlphaOnly.Length - 2);
                }
            }

            return name;
        }

        protected string GetStringValue(IDataReader drReader, string szColName)
        {
            if (drReader[szColName] == DBNull.Value)
            {
                return String.Empty;
            }
            return Convert.ToString(drReader[szColName]).Trim();
        }

        protected int GetIntValue(IDataReader drReader, string szColName)
        {
            if (drReader[szColName] == DBNull.Value)
            {
                return 0;
            }
            return Convert.ToInt32(drReader[szColName]);
        }

        protected void AddParameter(SqlCommand sqlCommand, string szParmName, string szParmValue)
        {
            if (string.IsNullOrEmpty(szParmValue))
            {
                sqlCommand.Parameters.AddWithValue(szParmName, DBNull.Value);
            }
            else
            {
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
    }
}


