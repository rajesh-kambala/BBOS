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
    class CompanyComparer
    {
        DateTime _startTime;

        List<NHLACompany> _allLumberCompanies = new List<NHLACompany>();

        int _companiesSearchedCounter = 0;
        int _companiesMatchedCounter = 0;
        int _companiesUnmatchedCounter = 0;
        int _sectionOneCompaniesMatched = 0;
        int _sectionOneCompaniesUnmatched = 0;
        int _sectionTwoCompaniesMatched = 0;
        int _sectionTwoCompaniesUnmatched = 0;
        int _sectionThreeCompaniesMatched = 0;
        int _sectionThreeCompaniesUnmatched = 0;

        string _matchedCompaniesFile = null;
        string _unMatchedCompaniesFile = null;

        private const string OUTPUT_FILE_MATCHED = "Matched";
        private const string OUTPUT_FILE_UNMATCHED = "UnMatched";

        private const string SQL_GET_ALL_LUMBER_COMPANIES =
            "SELECT comp_CompanyID, comp_Name, comp_PRIndustryType, comp_PRListingStatus, comp_PRLegalName, " +
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
            "SELECT NHLA_COMPANY, NHLA_PHONE, NHLA_FAX, NHLA_WEB, NHLA_EMAIL,  " +
            "NHLA_ADDRESS_PRIMARY, NHLA_ADDRESS_SECONDARY, NHLA_CITY, NHLA_STATE, NHLA_ZIPCODE, " +
            "NHLA_COUNTRY, OKS_SEQUENCE_ID " +
            "FROM {0}";

        private const string SQL_INSERT_MATCHED_COMPANY_OUTPUT =
            "INSERT INTO [Sheet1$] " +
            "(Match_Type, BBID, Industry_Type, Listing_Status, CRM_Company_Name, CRM_Mailing_Address, CRM_Physical_Address, CRM_Default_Phone, " +
            "CRM_Default_Fax, CRM_Default_Web, CRM_Default_Email, NHLA_COMPANY, NHLA_ADDRESS_PRIMARY, NHLA_ADDRESS_SECONDARY, NHLA_CITY, NHLA_STATE, " +
            "NHLA_ZIPCODE, NHLA_COUNTRY, NHLA_PHONE, NHLA_FAX, NHLA_WEB, NHLA_EMAIL, [Section], OKS_SEQUENCE_ID) " +
            "VALUES " +
            "(\"{0}\",{1},\"{2}\",\"{3}\",\"{4}\",\"{5}\",\"{6}\",\"{7}\",\"{8}\",\"{9}\",\"{10}\",\"{11}\",\"{12}\", " +
            "\"{13}\",\"{14}\",\"{15}\",\"{16}\",\"{17}\",\"{18}\",\"{19}\",\"{20}\",\"{21}\",{22},{23})";

        private const string SQL_INSERT_UNMATCHED_COMPANY_OUTPUT =
           "INSERT INTO [Sheet1$] " +
           "(NHLA_COMPANY, NHLA_ADDRESS_PRIMARY, NHLA_ADDRESS_SECONDARY, NHLA_CITY, NHLA_STATE, " +
           "NHLA_ZIPCODE, NHLA_COUNTRY, NHLA_PHONE, NHLA_FAX, NHLA_WEB, NHLA_EMAIL, [Section], OKS_SEQUENCE_ID) " +
           "VALUES " +
           "(\"{0}\",\"{1}\",\"{2}\",\"{3}\",\"{4}\",\"{5}\",\"{6}\",\"{7}\",\"{8}\",\"{9}\",\"{10}\",{11},{12})";

        protected SqlConnection _dbConn = null;

        public CompanyComparer()
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
                    NHLACompany company = new NHLACompany();
                    company.BBID = GetIntValue(dr, "comp_CompanyID");
                    company.CRMCompanyName = GetStringValue(dr, "comp_Name");
                    company.CRMLegalName = GetStringValue(dr, "comp_PRLegalName");

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
                SearchSectionTwo(connection);
                SearchSectionThree(connection);

                connection.Close();

                ConsoleWriter.WriteTotalAnalysis(_companiesMatchedCounter, _companiesUnmatchedCounter);
                TextLogWriter.WriteSectionData("Total Analysis", _companiesSearchedCounter, _companiesMatchedCounter, _companiesUnmatchedCounter);
            }
        }


        protected void InsertExcelMatchedCompany(NHLACompany company)
        {
            DbProviderFactory factory = DbProviderFactories.GetFactory("System.Data.OleDb");

            using (DbConnection connection = factory.CreateConnection())
            {
                string msExcelConn = String.Format(ConfigurationManager.AppSettings["msExcelConn"].ToString(), _matchedCompaniesFile);

                connection.ConnectionString = msExcelConn;
                connection.Open();

                using (DbCommand command = connection.CreateCommand())
                {
                    object[] values = { company.MatchType, company.BBID, company.IndustryType, company.ListingStatus, company.CRMCompanyName,
                                        company.CRMMailingAddress, company.CRMPhysicalAddress, company.CRMDefaultPhone, company.CRMDefaultFax,
                                        company.CRMDefaultWeb, company.CRMDefaultEmail, company.NHLACompanyName, company.NHLAddressPrimary,
                                        company.NHLAddressSecondary, company.NHLCity, company.NHLAState, company.NHLZipCode, company.NHLACountry,
                                        company.NHLAPhone, company.NHLAFax, company.NHLAWeb, company.NHLAEmail, company.Section, company.OksSequenceID};


                    command.CommandText = String.Format(SQL_INSERT_MATCHED_COMPANY_OUTPUT, values);
                    command.ExecuteNonQuery();
                }
            }
        }

        protected void InsertExcelUnmatchedCompany(NHLACompany company)
        {
            DbProviderFactory factory = DbProviderFactories.GetFactory("System.Data.OleDb");

            using (DbConnection connection = factory.CreateConnection())
            {
                string msExcelConn = String.Format(ConfigurationManager.AppSettings["msExcelConn"].ToString(), _unMatchedCompaniesFile);

                connection.ConnectionString = msExcelConn;
                connection.Open();

                using (DbCommand command = connection.CreateCommand())
                {
                    object[] values = { company.NHLACompanyName, company.NHLAddressPrimary,
                                                company.NHLAddressSecondary, company.NHLCity, company.NHLAState, company.NHLZipCode, company.NHLACountry,
                                                company.NHLAPhone, company.NHLAFax, company.NHLAWeb, company.NHLAEmail, company.Section, company.OksSequenceID};

                    command.CommandText = String.Format(SQL_INSERT_UNMATCHED_COMPANY_OUTPUT, values);
                    command.ExecuteNonQuery();
                }
            }
        }

        protected void SearchSectionOne(DbConnection connection)
        {
            using (DbCommand command = connection.CreateCommand())
            {
                command.CommandText = String.Format(SQL_SCAN_EXCEL_FILE, "[Section 1$]"); 

                using (DbDataReader dr = command.ExecuteReader())
                {
                    ConsoleWriter.WriteExecutionStatus("Scanning Section One...   ");
                    
                    int i = 0;

                    while (dr.Read())
                    {
                        NHLACompany company = InitializeCompany(dr, 1);

                        if (!string.IsNullOrEmpty(company.NHLACompanyName))
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

                    ConsoleWriter.WriteSectionData("Section One Analysis", i, _sectionOneCompaniesMatched, _sectionOneCompaniesUnmatched);
                    TextLogWriter.WriteSectionData("Section One Analysis", i, _sectionOneCompaniesMatched, _sectionOneCompaniesUnmatched);
                }
            }
        }

        protected void SearchSectionTwo(DbConnection connection)
        {
            using (DbCommand command = connection.CreateCommand())
            {
                command.CommandText = String.Format(SQL_SCAN_EXCEL_FILE, "[Section 2$]");

                using (DbDataReader dr = command.ExecuteReader())
                {
                    ConsoleWriter.WriteExecutionStatus("Scanning Section Two...   ");
 
                    int i = 0;

                    while (dr.Read())
                    {
                        NHLACompany company = InitializeCompany(dr, 2);

                        if (!string.IsNullOrEmpty(company.NHLACompanyName))
                        {
                            i++;
                            _companiesSearchedCounter++;

                            ConsoleWriter.WriteCurrentCompanySearched(_companiesSearchedCounter);

                            if (IsCompanyMatchFound(company))
                            {
                                _sectionTwoCompaniesMatched++;
                                _companiesMatchedCounter++;
                                InsertExcelMatchedCompany(company);
                            }
                            else
                            {
                                _sectionTwoCompaniesUnmatched++;
                                _companiesUnmatchedCounter++;
                                InsertExcelUnmatchedCompany(company);
                            }

                        }
                    }

                    ConsoleWriter.WriteSectionData("Section Two Analysis", i, _sectionTwoCompaniesMatched, _sectionTwoCompaniesUnmatched);
                    TextLogWriter.WriteSectionData("Section Two Analysis", i, _sectionTwoCompaniesMatched, _sectionTwoCompaniesUnmatched);
                }
            }
        }

        protected void SearchSectionThree(DbConnection connection)
        {
            using (DbCommand command = connection.CreateCommand())
            {
                command.CommandText = String.Format(SQL_SCAN_EXCEL_FILE, "[Section 3$]");

                using (DbDataReader dr = command.ExecuteReader())
                {
                    ConsoleWriter.WriteExecutionStatus("Scanning Section Three...   ");

                    int i = 0;

                    while (dr.Read())
                    {
                        NHLACompany company = InitializeCompany(dr, 3);

                        if (!string.IsNullOrEmpty(company.NHLACompanyName))
                        {
                            i++;
                            _companiesSearchedCounter++;

                            ConsoleWriter.WriteCurrentCompanySearched(_companiesSearchedCounter);

                            if (IsCompanyMatchFound(company))
                            {
                                _sectionThreeCompaniesMatched++;
                                _companiesMatchedCounter++;
                                InsertExcelMatchedCompany(company);
                            }
                            else
                            {
                                _sectionThreeCompaniesUnmatched++;
                                _companiesUnmatchedCounter++;
                                InsertExcelUnmatchedCompany(company);
                            }

                        }
                    }

                    ConsoleWriter.WriteSectionData("Section Three Analysis", i, _sectionThreeCompaniesMatched, _sectionThreeCompaniesUnmatched);
                    TextLogWriter.WriteSectionData("Section Three Analysis", i, _sectionThreeCompaniesMatched, _sectionThreeCompaniesUnmatched);

                }
            }
        }

        protected bool IsCompanyMatchFound(NHLACompany company)
        {
            if (IsMatchedByPhone(company))          
                return true;
            else if (IsMatchedByFax(company))
                return true;
            else if (IsMatchedByWeb(company))
                return true;
            else if (IsMatchedByCompanyName(company))
                return true;
            else
                return false;
        }

        protected bool IsMatchedByPhone(NHLACompany company)
        {
            if (!string.IsNullOrEmpty(company.NHLAPhone))
            {
                string phoneCleared = company.NHLAPhone.Replace("-", "");

                var matchedCompany = _allLumberCompanies.FirstOrDefault(p => p.PhoneForMatch.Replace("-", "") == phoneCleared);

                if (matchedCompany != null)
                {
                    SetCompanyAttributes(company, matchedCompany, Enum.GetName(typeof(NHLACompany.MatchTypes), NHLACompany.MatchTypes.Phone));
                    return true;
                }
            }

            return false;
        }

        protected bool IsMatchedByFax(NHLACompany company)
        {
            if (!string.IsNullOrEmpty(company.NHLAFax))
            {
                string faxCleared = company.NHLAFax.Replace("-", "");

                var matchedCompany = _allLumberCompanies.FirstOrDefault(p => p.PhoneForMatch.Replace("-", "") == faxCleared);

                if (matchedCompany != null)
                {
                    SetCompanyAttributes(company, matchedCompany, Enum.GetName(typeof(NHLACompany.MatchTypes), NHLACompany.MatchTypes.Fax));
                    return true;
                }
            }

            return false;
        }

        protected bool IsMatchedByWeb(NHLACompany company)
        {
            if (!string.IsNullOrEmpty(company.NHLAWeb))
            {
                var matchedCompany = _allLumberCompanies.FirstOrDefault(p => p.CRMDefaultWeb == company.NHLAWeb);

                if (matchedCompany != null)
                {
                    SetCompanyAttributes(company, matchedCompany, Enum.GetName(typeof(NHLACompany.MatchTypes), NHLACompany.MatchTypes.Web));
                    return true;
                }
            }

            return false;
        }

        //protected bool IsMatchedByEmail(Company company)
        //{
        //    if (!string.IsNullOrEmpty(company.NHLAEmail))
        //    {
        //        int indexOfDomainAtChar = company.NHLAEmail.IndexOf('@', 0);

        //        if (indexOfDomainAtChar > -1)
        //        {
        //            string emailDomain = company.NHLAEmail.Substring(indexOfDomainAtChar);

        //            if (emailDomain != "@hotmail.com" && emailDomain != "@yahoo.com" && emailDomain != "@gmail.com" && emailDomain != "@aol.com" &&
        //                emailDomain != "@comcast.net" && emailDomain != "@bellsouth.net" && emailDomain != "@ameritech.net" && emailDomain != "@centurytel.net" &&
        //                emailDomain != "@sbcglobal.net" && emailDomain != "@earthlink.net" && emailDomain != "@hughes.net" && emailDomain != "@verizon.net" &&
        //                emailDomain != "@swbell.net" && emailDomain != "@msn.com" && emailDomain != "@choiceonemail.com" && emailDomain != "@charter.net" &&
        //                emailDomain != "@frontiernet.net" && emailDomain != "@netins.net" && emailDomain != "@globetrotter.net" && emailDomain != "@blomand.net" &&
        //                emailDomain != "@nep.net" && emailDomain != "@blomand.net" && emailDomain != "@embarqmail.com" && emailDomain != "hiwaay.net")
        //            {
        //                var matchedCompany = _allLumberCompanies.FirstOrDefault(p => (p.CRMDefaultEmail.IndexOf('@', 0) > -1 ? p.CRMDefaultEmail.Substring(p.CRMDefaultEmail.IndexOf('@', 0)) : string.Empty) == emailDomain);
                        
        //                if (matchedCompany != null)
        //                {
        //                    SetCompanyAttributes(company, matchedCompany, Enum.GetName(typeof(Company.MatchTypes), Company.MatchTypes.Email));
        //                    return true;
        //                }
        //            }
        //        }
        //    }

        //    return false;
        //}

        protected bool IsMatchedByCompanyName(NHLACompany company)
        {
            if (!string.IsNullOrEmpty(company.NHLACompanyName))
            {
                var matchedCompany = _allLumberCompanies.FirstOrDefault(p => ProcessCompanyName(p.CRMCompanyName) == ProcessCompanyName(company.NHLACompanyName) 
                        || ProcessCompanyName(p.CRMLegalName) == ProcessCompanyName(company.NHLACompanyName));

                if (matchedCompany != null)
                {
                    SetCompanyAttributes(company, matchedCompany, Enum.GetName(typeof(NHLACompany.MatchTypes), NHLACompany.MatchTypes.CompanyName));
                    return true;
                }
            }

            return false;
        }

        protected void SetCompanyAttributes(NHLACompany company, NHLACompany matchedCompany, string matchType)
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

        protected NHLACompany InitializeCompany(DbDataReader dr, int section)
        {
            NHLACompany company = new NHLACompany();

            company.NHLACompanyName = GetStringValue(dr, "NHLA_COMPANY");
            company.NHLAPhone = GetStringValue(dr, "NHLA_PHONE");
            company.NHLAFax = GetStringValue(dr, "NHLA_FAX");
            company.NHLAWeb = GetStringValue(dr, "NHLA_WEB");
            company.NHLAEmail = GetStringValue(dr, "NHLA_EMAIL");

            company.NHLAddressPrimary = GetStringValue(dr, "NHLA_ADDRESS_PRIMARY");
            company.NHLAddressSecondary = GetStringValue(dr, "NHLA_ADDRESS_SECONDARY");
            company.NHLCity = GetStringValue(dr, "NHLA_CITY");
            company.NHLAState = GetStringValue(dr, "NHLA_STATE");
            company.NHLZipCode = GetStringValue(dr, "NHLA_ZIPCODE");
            company.NHLACountry = GetStringValue(dr, "NHLA_COUNTRY");
            company.Section = section;
            company.OksSequenceID = GetIntValue(dr, "OKS_SEQUENCE_ID");

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
                xlWorkSheet.Cells[1, 3] = "Industry_Type";
                xlWorkSheet.Cells[1, 4] = "Listing_Status";
                xlWorkSheet.Cells[1, 5] = "CRM_Company_Name";
                xlWorkSheet.Cells[1, 6] = "CRM_Mailing_Address";
                xlWorkSheet.Cells[1, 7] = "CRM_Physical_Address";
                xlWorkSheet.Cells[1, 8] = "CRM_Default_Phone";
                xlWorkSheet.Cells[1, 9] = "CRM_Default_Fax";
                xlWorkSheet.Cells[1, 10] = "CRM_Default_Web";
                xlWorkSheet.Cells[1, 11] = "CRM_Default_Email";
                xlWorkSheet.Cells[1, 12] = "NHLA_COMPANY";
                xlWorkSheet.Cells[1, 13] = "NHLA_ADDRESS_PRIMARY";
                xlWorkSheet.Cells[1, 14] = "NHLA_ADDRESS_SECONDARY";
                xlWorkSheet.Cells[1, 15] = "NHLA_CITY";
                xlWorkSheet.Cells[1, 16] = "NHLA_STATE";
                xlWorkSheet.Cells[1, 17] = "NHLA_ZIPCODE";
                xlWorkSheet.Cells[1, 18] = "NHLA_COUNTRY";
                xlWorkSheet.Cells[1, 19] = "NHLA_PHONE";
                xlWorkSheet.Cells[1, 20] = "NHLA_FAX";
                xlWorkSheet.Cells[1, 21] = "NHLA_WEB";
                xlWorkSheet.Cells[1, 22] = "NHLA_EMAIL";
                xlWorkSheet.Cells[1, 23] = "Section";
                xlWorkSheet.Cells[1, 24] = "OKS_SEQUENCE_ID";

                _matchedCompaniesFile = ConfigurationManager.AppSettings["MatchedCompaniesFile"].ToString() + "_" + fileDetails + ".xls";
                xlWorkBook.SaveAs(_matchedCompaniesFile, Microsoft.Office.Interop.Excel.XlFileFormat.xlWorkbookNormal, misValue, misValue, misValue, misValue, Microsoft.Office.Interop.Excel.XlSaveAsAccessMode.xlExclusive, misValue, misValue, misValue, misValue, misValue);
            }
            else
            {
                xlWorkSheet = (Microsoft.Office.Interop.Excel.Worksheet)xlWorkBook.Worksheets.get_Item(1);
                xlWorkSheet.Cells[1, 1] = "NHLA_COMPANY";
                xlWorkSheet.Cells[1, 2] = "NHLA_ADDRESS_PRIMARY";
                xlWorkSheet.Cells[1, 3] = "NHLA_ADDRESS_SECONDARY";
                xlWorkSheet.Cells[1, 4] = "NHLA_CITY";
                xlWorkSheet.Cells[1, 5] = "NHLA_STATE";
                xlWorkSheet.Cells[1, 6] = "NHLA_ZIPCODE";
                xlWorkSheet.Cells[1, 7] = "NHLA_COUNTRY";
                xlWorkSheet.Cells[1, 8] = "NHLA_PHONE";
                xlWorkSheet.Cells[1, 9] = "NHLA_FAX";
                xlWorkSheet.Cells[1, 10] = "NHLA_WEB";
                xlWorkSheet.Cells[1, 11] = "NHLA_EMAIL";
                xlWorkSheet.Cells[1, 12] = "Section";
                xlWorkSheet.Cells[1, 13] = "OKS_SEQUENCE_ID";

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


