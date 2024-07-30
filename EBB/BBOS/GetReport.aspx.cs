/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2007-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: GetReport
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Data;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;

using PRCo.BBS;
using PRCo.EBB.BusinessObjects;

using TSI.Arch;
using TSI.BusinessObjects;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web {

    /// <summary>
    /// Wraps the ReportInterface.dll providing the functionality to execute
    /// the specified reports.  Returns the report to the client with the
    /// specified type and as an attachment.
    /// </summary>
    public partial class GetReport : PageBase {
    
        protected ReportInterface _oRI;
        protected string _szReportName = null;
        protected string _szContentType = null;
        protected byte[] _oReport = null;
    
        public const string AD_CAMPAING_SUMMARY_REPORT = "ADSR";
        public const string BANKRUPCTY_REPORT = "BRR";
        public const string BANKRUPCTY_REPORT_NR = "BRRNR";
        public const string BLUE_BOOK_SCORE_REPORT = "BBSR";
        public const string BUSINESS_REPORT = "BR";
        public const string BUSINESS_REPORT_4 = "BR4";
        public const string BUSINESS_REPORT_FREE = "BRF";
        public const string COMPANY_ANALYSIS_REPORT = "CAR";
        public const string COMPANY_ANALYSIS_EXPORT = "CAE";
        public const string COMPANY_CONTACTS_EXPORT = "CCE";
        public const string COMPANY_DATA_EXPORT = "CDE";
        public const string COMPANY_DATA_EXPORT_LUMBER = "CDEL";
        public const string CONTACT_EXPORT = "CE";
        public const string CONTACT_EXPORT_LUMBER = "CEL";
        public const string COMPANY_UPDATE_LIST_REPORT = "CULR";
        public const string CREDIT_SHEET_REPORT = "CSR";
        public const string CREDIT_SHEET_EXPORT = "CSE";
        public const string MAILING_LABELS_REPORT = "MLR";
        public const string QUICK_REPORT = "QR";
        public const string QUICK_REPORT_LUMBER = "QRL";
        public const string FULL_LISTING_REPORT = "FLR";
        public const string NOTES_REPORT = "NR";
        public const string RATINGS_COMPARISON_REPORT = "RCR";
        public const string COMPANY_LISTING_REPORT = "CLR";
        public const string COMPANY_LISTING_REPORT_BASIC = "CLR_BASIC";
        public const string COMPANY_COMMODITY_REPORT = "CCR";
        public const string LISTING_REPORT_LETTER = "LRL";
        public const string INTERNAL_EXPORT = "BBSi_IE";
        //public const string TRAINING = "TRN";
        public const string PERSON_EXPORT = "PE";
        public const string PERSON_REPORT = "PR";

        public const string AR_REPORTS = "ARReports";

        override protected void Page_Load(object sender, EventArgs e) {

            base.Page_Load(sender, e);

            _oRI = new ReportInterface();
            
            string szReportType = GetRequestParameter("ReportType", true, false, true);
            switch(szReportType) {
                case AD_CAMPAING_SUMMARY_REPORT:
                    GetAdCampaignReport();
                    break;

                case BANKRUPCTY_REPORT:
                    GetBankruptcyReport();
                    break;

                case BANKRUPCTY_REPORT_NR:
                    GetBankruptcyReportNR();
                    return;

                case BLUE_BOOK_SCORE_REPORT:
                    GetBlueBookScoreReport();
                    break;

                case BUSINESS_REPORT:
                case BUSINESS_REPORT_4:
                    GetBusinessReport(true);
                    break;

                case BUSINESS_REPORT_FREE:
                    GetBusinessReport(false);
                    break;

                case COMPANY_ANALYSIS_REPORT:
                    GetCompanyAnalysisReport();
                    break;

                case COMPANY_ANALYSIS_EXPORT:
                    GetCompanyAnalysisExport();
                    break;

                case COMPANY_CONTACTS_EXPORT:
                    GetCompanyContactExport();
                    break;

                case COMPANY_DATA_EXPORT:
                    GetCompanyDataExport();
                    break;

                case COMPANY_DATA_EXPORT_LUMBER:
                    GetCompanyDataExportLumber();
                    break;

                case CONTACT_EXPORT:
                case CONTACT_EXPORT_LUMBER:
                    GetContactExport();
                    break;

                case COMPANY_UPDATE_LIST_REPORT:
                    GetCompanyUpdateListReport();
                    break;

                case CREDIT_SHEET_REPORT:
                    GetCreditSheetReport();
                    break;

                case CREDIT_SHEET_EXPORT:
                    GetCreditSheetExport();
                    break;

                case MAILING_LABELS_REPORT:
                    GetMailingLabelsReport();
                    break;

                case QUICK_REPORT:
                    GetQuickReport();
                    break;

                case QUICK_REPORT_LUMBER:
                    GetQuickReportLumber();
                    break;

                case FULL_LISTING_REPORT:
                    GetFullListingReport();
                    break;

                case NOTES_REPORT:
                    GetNotesReport();
                    break;

                case RATINGS_COMPARISON_REPORT:
                    GetRatingComparisonReport();
                    break;

                case COMPANY_LISTING_REPORT:
                    GetCompanyListingReport();
                    break;

                case COMPANY_LISTING_REPORT_BASIC:
                    GetCompanyListingReport_Basic();
                    break;

                case COMPANY_COMMODITY_REPORT:
                    GetCompanyCommodityReport();
                    break;

                case LISTING_REPORT_LETTER:
                    GetListingReportLetter();
                    break;

                case INTERNAL_EXPORT:
                    GenerateInternalExport();
                    break;

                case PERSON_EXPORT:
                    GeneratePersonExport();
                    break;

                case PERSON_REPORT:
                    GetPersonnelReport();
                    break;

                case AR_REPORTS:
                    GetARReportsReport();
                    break;

                default:
                    throw new ApplicationUnexpectedException("Invalid report type specified: " + szReportType);
            }
            
            // Now deliver our report to the client
            Response.ClearContent();
            Response.ClearHeaders();

            Response.AddHeader("Content-Disposition", "attachment; filename=\"" + _szReportName + "\"");
            Response.ContentType = _szContentType;

            Response.BinaryWrite(_oReport);
        }

        /// <summary>
        /// Generates the Business Report
        /// </summary>
        protected void GetARReportsReport()
        {
            int companyID = Convert.ToInt32(GetRequestParameter("CompanyID", true, false, true));
            int arAgingThreshold = Convert.ToInt32(GetRequestParameter("Threshold", true, false, true));
            string industryType = GetRequestParameter("IndustryType", true, false, true);

            _szContentType = "application/pdf";
            _szReportName = string.Format(Resources.Global.ARReportsName, GetApplicationNameAbbr(), companyID);
            _oReport = _oRI.GenerateARReportsReport(companyID, arAgingThreshold, industryType);
        }

        /// <summary>
        /// Generates the Business Report
        /// </summary>
        protected void GetBusinessReport(bool blnEquifaxRequest = false) {

            bool bIncludeBalanceSheet = false;
            bool bIncludeSurvey = false;
            
            string szCompanyID = GetRequestParameter("CompanyID", true, false, true);
            int iReportLevel = Convert.ToInt32(GetRequestParameter("Level", true, false, true));
            int iRequestID = Convert.ToInt32(GetRequestParameter("RequestID", true, false, true));

            // Check to see if the requesting company is eligible
            bool bIsEligibleForEquifaxData = false;
            if (blnEquifaxRequest)
            {
                bIsEligibleForEquifaxData = IsEligibleForEquifaxData();
            }

            _szContentType = "application/pdf";
            _szReportName = string.Format(Resources.Global.BusinessReportName, GetApplicationNameAbbr(), szCompanyID);
            _oReport = _oRI.GenerateBusinessReport(szCompanyID, iReportLevel, bIncludeBalanceSheet, bIncludeSurvey, iRequestID, bIsEligibleForEquifaxData, _oUser.prwu_HQID);

            //SendBRSurvey()
            GeneralDataMgr oGeneralDataMgr = new GeneralDataMgr(_oLogger, _oUser);
            oGeneralDataMgr.User = _oUser;
            oGeneralDataMgr.SendBRSurvey(iRequestID, _oUser.prwu_PersonLinkID, _oUser.prwu_Culture, null);
        }

        /// <summary>
        /// Helper method used to retrieve the Ad Campaign Report from the report server using the report
        /// interface component.
        /// </summary>
        protected void GetAdCampaignReport() {
            // Check security for this report
            HasPrivilege(SecurityMgr.Privilege.ReportAdCampaign);

            // Setup parameters required for this report
            int iAdCampaignID = Convert.ToInt32(GetRequestParameter("AdCampaignID", true, false, true));

            // Set report type and name
            _szContentType = "application/pdf";
            _szReportName = string.Format(Resources.Global.AdCampaignReportName, GetApplicationNameAbbr());

            // Retrieve report
            _oReport = _oRI.GenerateAdCampaignReport(_oUser.prwu_Culture, iAdCampaignID);
        }
        
        /// <summary>
        /// Helper method used to retrieve the Bankruptcy Report from the report server using the 
        /// report interface component.
        /// </summary>
        protected void GetBankruptcyReport() {
            // Check security for this report
            HasPrivilege(SecurityMgr.Privilege.ReportBankruptcy);
            
            // Setup parameters for this report
            string szHeaderText = GetRequestParameter("HeaderText", false);
            string szFromDate = GetRequestParameter("FromDate", false);
            string szToDate = GetRequestParameter("ToDate", false);
            DateTime dtFromDate;
            DateTime dtToDate;

            // Use the From Date provided if available, otherwise default this to 90 days ago
            if (szFromDate != null)
                dtFromDate = Convert.ToDateTime(szFromDate);
            else
                dtFromDate = System.DateTime.Now.AddDays(-90);

            // Use the To Date provided if available, otherwise default to today
            if (szToDate != null)
                dtToDate = Convert.ToDateTime(szToDate);
            else
                dtToDate = System.DateTime.Now;
            
            // Set report type and name
            _szContentType = "application/pdf";
            _szReportName = string.Format(Resources.Global.BankruptcyReportName, GetApplicationNameAbbr());

            // Retrieve report
            _oReport = _oRI.GenerateBankruptcyReport(_oUser.prwu_Culture, dtFromDate, dtToDate, szHeaderText, "Produce");        
        }

        /// Helper method used to retrieve the Bankruptcy Report from disk without rendering it
        /// NR = no render
        protected void GetBankruptcyReportNR()
        {
            FileInfo fi;
            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                fi = new FileInfo(Utilities.GetConfigValue("BankruptcyReportLumber"));
            else
                fi = new FileInfo(Utilities.GetConfigValue("BankruptcyReport"));

            // Now deliver our report to the client
            Response.ClearContent();
            Response.ClearHeaders();

            Response.AddHeader("Content-Disposition", "attachment; filename=\"" + Resources.Global.BankruptcyReportDownloadName + "\"");
            Response.AddHeader("Content-Length", fi.Length.ToString());
            Response.ContentType = "application/pdf";

            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                Response.WriteFile(Utilities.GetConfigValue("BankruptcyReportLumber"));
            else
                Response.WriteFile(Utilities.GetConfigValue("BankruptcyReport"));
        }

        /// <summary>
        /// Helper method used to retrieve the Company Analysis Report from the report server using 
        /// the report interface component.
        /// </summary>
        protected void GetCompanyAnalysisReport() {
            // Check security 
            HasPrivilege(SecurityMgr.Privilege.ReportCompanyAnalysis);
            
            // Setup parameters required for this report
            string szCompanyIDList = GetRequestParameter("CompanyIDList", true, false, true);
            string szHeaderText = GetRequestParameter("HeaderText", false);
            int iBBScoreConfidenceThreshold = Configuration.BBScoreConfidenceThreshold;
            string szReportSortOption = GetRequestParameter("ReportSortOption", false);

            // Set report type and name
            _szContentType = "application/pdf";
            _szReportName = string.Format(Resources.Global.CompanyAnalysisReportName, GetApplicationNameAbbr());

            // Retrieve Report
            _oReport = _oRI.GenerateCompanyAnalysisReport(szCompanyIDList, szHeaderText, _oUser.prwu_Culture, iBBScoreConfidenceThreshold, szReportSortOption);
        }

        /// <summary>
        /// Helper method used to retrieve the Company Analysis Export Report using the report interface component.
        /// </summary>
        protected void GetCompanyAnalysisExport() {
            // Check security for this report
            HasPrivilege(SecurityMgr.Privilege.ReportCompanyAnalysisExport);

            // Setup parameters required for this report
            string szCompanyIDList = GetRequestParameter("CompanyIDList", true, false, true);
            int iBBScoreConfidenceThreshold = Configuration.BBScoreConfidenceThreshold;            

            // Set report type and name
            _szContentType = "application/csv";
            _szReportName = string.Format(Resources.Global.CompanyAnalysisExportName, GetApplicationNameAbbr());

            // Retrieve report 
           _oReport = _oRI.GenerateCompanyAnalysisExport(szCompanyIDList, _oUser.prwu_Culture, iBBScoreConfidenceThreshold, _oUser.prwu_BBID);
        }

        protected void GetListingReportLetter()
        {
            // Set report type and name
            _szContentType = "application/pdf";
            _szReportName = string.Format(Resources.Global.CompanyUpdateListReportName, GetApplicationNameAbbr());

            // Retrieve report
            _oReport = _oRI.GenerateListingReportLetter(_oUser.prwu_HQID);
        }

        /// <summary>
        /// Helper method used to retrieve the Company Contact Export report from the report server using
        /// the report interface component.
        /// </summary>
        protected void GetCompanyContactExport() {
            // Check security for this report
            HasPrivilege(SecurityMgr.Privilege.DataExportBasicCompanyDataExport);

            // Setup parameters required for this report
            string szCompanyIDList = GetRequestParameter("CompanyIDList", true, false, true);
            string szExportType = GetRequestParameter("ExportType");

            // Set report type and name
            _szContentType = "application/csv";
            _szReportName = string.Format(Resources.Global.CompanyContactExportName, GetApplicationNameAbbr());

            // Retrieve report
            if (szExportType == "MSO") {
                _oReport = GenerateCompanyContactExportMSOReport(szCompanyIDList);
            } else {
                //_oReport = _oRI.GenerateCompanyContactExport(szCompanyIDList, szExportType, _oUser.prwu_BBID, _oUser.prwu_WebUserID);
                //DEFECT 5696 - due to dynamic columns, we need to roll-our-own CSV instead of using SSRS
                _oReport = GenerateCompanyContactExportReport(szCompanyIDList, szExportType, _oUser.prwu_BBID, _oUser.prwu_WebUserID);
            }
        }

        /// <summary>
        /// Generate CompanyContactExportReport CSV - roll our own ala Defect 5696 because pivot SQL doesn't work in SSRS
        /// </summary>
        /// <param name="szCompanyIDList"></param>
        /// <param name="szExportType"></param>
        /// <param name="iUserCompanyID"></param>
        /// <param name="iWebUserID"></param>
        /// <returns></returns>
        protected byte[] GenerateCompanyContactExportReport(string szCompanyIDList, string szExportType, int iUserCompanyID, int iWebUserID)
        {
            StringBuilder sbExport = new StringBuilder();

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyIDs", szCompanyIDList));
            oParameters.Add(new ObjectParameter("UserCompanyID", iUserCompanyID));
            oParameters.Add(new ObjectParameter("WebUserID", iWebUserID));

            DataSet oData = GetDBAccess().ExecuteStoredProcedure("usp_GetCompanyContactDataExportCSV", oParameters);

            RemoveUnwantedDynamicColums(ref oData);

            foreach (DataColumn column in oData.Tables[0].Columns)
            {
                sbExport.Append(CSVQuoteWrap(column.ColumnName));
                if(column.Ordinal < oData.Tables[0].Columns.Count-1)
                    sbExport.Append(",");
            }

            sbExport.Append(Environment.NewLine);

            foreach (DataRow row in oData.Tables[0].Rows)
            {
                foreach(DataColumn col in oData.Tables[0].Columns)
                {
                    string fieldValue = CSVQuoteWrap(row[col].ToString());
                    sbExport.Append(fieldValue);
                    if(col.Ordinal < oData.Tables[0].Columns.Count-1)
                        sbExport.Append(",");
                }

                sbExport.Append(Environment.NewLine);
            }

            return Encoding.UTF8.GetBytes(sbExport.ToString());
        }

        private string CSVQuoteWrap(string data)
        {
            string newVal;
            newVal = data.Replace("\"", "\"\""); //escape double-quotes
            newVal = "\"" + newVal + "\"";
            return newVal;
        }

        /// <summary>
        /// Helper method used to retrieve the Company Data Export report from the report server using the
        /// report interface component.
        /// </summary>
        protected void GetCompanyDataExport() {
            // Check security for this report
            HasPrivilege(SecurityMgr.Privilege.DataExportDetailedCompanyDataExport);

            // Setup parameters required for this report
            string szCompanyIDList = GetRequestParameter("CompanyIDList", true, false, true);
            int iLevel = Convert.ToInt32(GetRequestParameter("Level"));

            // Set report type and name
            _szContentType = "application/csv";
            _szReportName = string.Format(Resources.Global.CompanyDataExportName, GetApplicationNameAbbr());

            // Retrieve report
            //_oReport = _oRI.GenerateCompanyDataExport(szCompanyIDList, iLevel, _oUser.prwu_BBID);
            //DEFECT 5696 - due to dynamic columns, we need to roll-our-own CSV instead of using SSRS
            _oReport = GenerateCompanyDataExportReport(szCompanyIDList, iLevel, _oUser.prwu_BBID, _oUser.prwu_WebUserID, _oUser.prwu_Culture);
        }

        /// <summary>
        /// Generate CompanyDataExport CSV - roll our own ala Defect 5696 because pivot SQL doesn't work in SSRS
        /// </summary>
        /// <returns></returns>
        protected byte[] GenerateCompanyDataExportReport(string szCompanyIDList, int iLevel, int iUserCompanyID, int iWebUserID, string szCulture)
        {
            StringBuilder sbExport = new StringBuilder();

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyIDs", szCompanyIDList));
            oParameters.Add(new ObjectParameter("UserCompanyID", iUserCompanyID));
            oParameters.Add(new ObjectParameter("WebUserID", iWebUserID));
            oParameters.Add(new ObjectParameter("Culture", szCulture));

            DataSet oData = GetDBAccess().ExecuteStoredProcedure("usp_GetCompanyDataExportReportCSV", oParameters);

            //Level 1 don't get some fields
            if (iLevel == 1)
            {
                oData.Tables[0].Columns.Remove("BBScore");
            }

            oData.Tables[0].Columns.Remove("prcp_Volume");

            RemoveUnwantedDynamicColums(ref oData);

            foreach (DataColumn column in oData.Tables[0].Columns)
            {
                sbExport.Append(CSVQuoteWrap(column.ColumnName));
                if (column.Ordinal < oData.Tables[0].Columns.Count - 1)
                    sbExport.Append(",");
            }

            sbExport.Append(Environment.NewLine);

            foreach (DataRow row in oData.Tables[0].Rows)
            {
                foreach (DataColumn col in oData.Tables[0].Columns)
                {
                    string fieldValue = CSVQuoteWrap(row[col].ToString());
                    sbExport.Append(fieldValue);
                    if (col.Ordinal < oData.Tables[0].Columns.Count - 1)
                        sbExport.Append(",");
                }

                sbExport.Append(Environment.NewLine);
            }

            return Encoding.UTF8.GetBytes(sbExport.ToString());
        }

        protected void GetCompanyDataExportLumber()
        {
            // Check security for this report
            HasPrivilege(SecurityMgr.Privilege.DataExportDetailedCompanyDataExport);

            // Setup parameters required for this report
            string szCompanyIDList = GetRequestParameter("CompanyIDList", true, false, true);

            // Set report type and name
            _szContentType = "application/csv";
            _szReportName = string.Format(Resources.Global.CompanyDataExportName, GetApplicationNameAbbr());

            // Retrieve report
            //_oReport = _oRI.GenerateCompanyDataExportLumber(szCompanyIDList, _oUser.prwu_AccessLevel > 300); //Defect 6840 L100 (access level 300) can't see BBScore
            //DEFECT 5696 - due to dynamic columns, we need to roll-our-own CSV instead of using SSRS
            _oReport = GenerateCompanyDataExportReportLumber(szCompanyIDList, _oUser.prwu_BBID, _oUser.prwu_WebUserID, _oUser.prwu_Culture);
        }

        private void RemoveUnwantedDynamicColums(ref DataSet oData)
        {
            if (oData.Tables[0].Columns["comp_PRIndustryType"] != null)
                oData.Tables[0].Columns.Remove("comp_PRIndustryType");

            if (oData.Tables[0].Columns["comp_PRType"] != null)
                oData.Tables[0].Columns.Remove("comp_PRType");

            if (oData.Tables[0].Columns["prwucd_AssociatedID"] != null)
                oData.Tables[0].Columns.Remove("prwucd_AssociatedID");

            if (oData.Tables[0].Columns["prwucf_Label"] != null)
                oData.Tables[0].Columns.Remove("prwucf_Label");

            if (oData.Tables[0].Columns["prwucd_Value"] != null)
                oData.Tables[0].Columns.Remove("prwucd_Value");

            if (oData.Tables[0].Columns["prc2_NumberOfStores"] != null)
                oData.Tables[0].Columns.Remove("prc2_NumberOfStores");
        }

        /// <summary>
        /// Generate CompanyDataExport CSV - roll our own ala Defect 5696 because pivot SQL doesn't work in SSRS
        /// </summary>
        /// <param name="szCompanyIDList"></param>
        /// <param name="szExportType"></param>
        /// <param name="iUserCompanyID"></param>
        /// <param name="iWebUserID"></param>
        /// <returns></returns>
        protected byte[] GenerateCompanyDataExportReportLumber(string szCompanyIDList, int iUserCompanyID, int iWebUserID, string szCulture)
        {
            StringBuilder sbExport = new StringBuilder();

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyIDs", szCompanyIDList));
            oParameters.Add(new ObjectParameter("UserCompanyID", iUserCompanyID));
            oParameters.Add(new ObjectParameter("WebUserID", iWebUserID));
            oParameters.Add(new ObjectParameter("Culture", szCulture));

            DataSet oData = GetDBAccess().ExecuteStoredProcedure("usp_GetCompanyDataExportReportLumberCSV", oParameters);

            //Defect 6840 L100 (access level 300) can't see BBScore
            if (_oUser.prwu_AccessLevel <= 300)
            {
                oData.Tables[0].Columns.Remove("BBScore");
            }

            RemoveUnwantedDynamicColums(ref oData);

            foreach (DataColumn column in oData.Tables[0].Columns)
            {
                sbExport.Append(CSVQuoteWrap(column.ColumnName));
                if (column.Ordinal < oData.Tables[0].Columns.Count - 1)
                    sbExport.Append(",");
            }

            sbExport.Append(Environment.NewLine);

            foreach (DataRow row in oData.Tables[0].Rows)
            {
                foreach (DataColumn col in oData.Tables[0].Columns)
                {
                    string fieldValue = CSVQuoteWrap(row[col].ToString());
                    sbExport.Append(fieldValue);
                    if (col.Ordinal < oData.Tables[0].Columns.Count - 1)
                        sbExport.Append(",");
                }

                sbExport.Append(Environment.NewLine);
            }

            return Encoding.UTF8.GetBytes(sbExport.ToString());
        }

        /// <summary>
        /// Helper method used to retrieve the Contact Export report from the report server using the
        /// report interface component.
        /// </summary>
        protected void GetContactExport() {
            // Check security for this report
            HasPrivilege(SecurityMgr.Privilege.DataExportContactExportAllContacts);

            // Setup parameters required for this report
            string szCompanyIDList = GetRequestParameter("CompanyIDList", true, false, true);
            string szContactType = GetRequestParameter("ContactType");
            string szExportType = GetRequestParameter("ExportType");

            // Set report type and name
            _szContentType = "application/csv";
            _szReportName = string.Format(Resources.Global.ContactExportName, GetApplicationNameAbbr());

            // Retrieve report
            if (szExportType == "MSO") { 
                _oReport = GenerateContactExportMSOReport(szContactType, szCompanyIDList);
            } else {

                if (GetRequestParameter("ReportType") == CONTACT_EXPORT_LUMBER)
                {
                    _oReport = _oRI.GenerateContactExportLumber(szCompanyIDList, szContactType, szExportType, _oUser.prwu_BBID);
                }
                else
                {
                    _oReport = _oRI.GenerateContactExport(szCompanyIDList, szContactType, szExportType, _oUser.prwu_BBID);
                }
            }
        }

        /// <summary>
        /// Helper method used to retrieve the Credit Sheet List report from the report server using
        /// the report interface component.
        /// </summary>
        protected void GetCompanyUpdateListReport() {
            // Check security for this report
            HasPrivilege(SecurityMgr.Privilege.ReportCompanyUpdateList);

            // Setup parameters required for this report
            int iCompanyID = Convert.ToInt32(GetRequestParameter("CompanyID", true, false, true));
            string szDateFrom = PageControlBaseCommon.ForceEnglishDate(GetRequestParameter("FromDate"), _oUser.prwu_Culture);
            string szDateTo = PageControlBaseCommon.ForceEnglishDate(GetRequestParameter("ToDate"), _oUser.prwu_Culture);
            bool bKeyChangesOnly = Convert.ToBoolean(GetRequestParameter("KeyChangesOnly"));
            bool bIncludeListing = Convert.ToBoolean(GetRequestParameter("IncludeListing"));

            // Set report type and name
            _szContentType = "application/pdf";
            _szReportName = string.Format(Resources.Global.CompanyUpdateListReportName, GetApplicationNameAbbr());

            // Retrieve report
            _oReport = _oRI.GenerateCompanyUpdateListReport(iCompanyID, szDateFrom, szDateTo, bKeyChangesOnly, 
                bIncludeListing);
        }

        /// <summary>
        /// Helper method used to retrieve the Credit Sheet Report from the report server using the report
        /// interface components.
        /// </summary>
        protected void GetCreditSheetReport() {
            // Check security for this report
            HasPrivilege(SecurityMgr.Privilege.ReportCreditSheet);

            // Setup parameters required for this report
            string szCreditSheetIDList = GetRequestParameter("CreditSheetIDList", true, false, true);

            // Set report type and name
            _szContentType = "application/pdf";
            _szReportName = string.Format(Resources.Global.CreditSheetReportName, GetApplicationNameAbbr());

            // Retrieve report
            _oReport = _oRI.GenerateCreditSheetReport(szCreditSheetIDList);
        }

        /// <summary>
        /// Helper method used to retrieve the Credit Sheet Export from the report server using the report
        /// interface components.
        /// </summary>
        protected void GetCreditSheetExport()
        {
            // Check security for this report
            HasPrivilege(SecurityMgr.Privilege.ReportCreditSheetExport);

            // Setup parameters required for this report
            string szCreditSheetIDList = GetRequestParameter("CreditSheetIDList", true, false, true);

            // Set report type and name
            _szContentType = "application/csv";
            _szReportName = string.Format(Resources.Global.CreditSheetExportName, GetApplicationNameAbbr());

            // Retrieve report
            _oReport = _oRI.GenerateCreditSheetExport(szCreditSheetIDList);
        }
        /// <summary>
        /// Helper method used to retrieve the Mailing Labels Report from the report server using the report
        /// interface components.
        /// </summary>
        protected void GetMailingLabelsReport() {
            // Check security for this report
            HasPrivilege(SecurityMgr.Privilege.ReportMailingLabels);

            // Setup parameters required for this report
            string szCompanyIDList = GetRequestParameter("CompanyIDList", true, false, true);
            int iLabelsPerPage = Convert.ToInt32(GetRequestParameter("LabelsPerPage"));
            string szCustomAttentionLine = GetRequestParameter("CustomAttentionLine", false);
            bool bIncludeHeadExecutive = Convert.ToBoolean(GetRequestParameter("IncludeHeadExecutive"));
            bool bIncludeCountry = Convert.ToBoolean(GetRequestParameter("IncludeCountry"));

            // Set report type and name
            _szContentType = "application/pdf";
            _szReportName = string.Format(Resources.Global.MailingLabelReportName, GetApplicationNameAbbr());

            // Retrieve report
            _oReport = _oRI.GenerateMailingLabelsReport(szCompanyIDList, iLabelsPerPage,
                                                        bIncludeHeadExecutive, szCustomAttentionLine, bIncludeCountry);
        }


        /// <summary>
        /// Helper method used to retrieve the MPR Quick Report from the report server using the 
        /// report interface component.
        /// </summary>
        protected void GetQuickReport() {
            // Check security for this report
            HasPrivilege(SecurityMgr.Privilege.ReportQuickList);

            // Setup parameters required for this report
            string szCompanyIDList = GetRequestParameter("CompanyIDList", true, false, true);
            string szHeaderText = GetRequestParameter("HeaderText", false);
            string szReportSortOption = GetRequestParameter("ReportSortOption", false);

            bool bIncludeHeadExecutive = Convert.ToBoolean(GetRequestParameter("IncludeHeadExecutive"));

            // Set report type and name
            _szContentType = "application/pdf";
            _szReportName = string.Format(Resources.Global.QuickReportName, GetApplicationNameAbbr());

            // Retrieve report
            _oReport = _oRI.GenerateMPRQuickListReport(szCompanyIDList, bIncludeHeadExecutive, szHeaderText,
                                                       _oUser.prwu_Culture, _oUser.prwu_AccessLevel, szReportSortOption);
        }

        /// <summary>
        /// Helper method used to retrieve the MPR Quick Report for lumber companies from the report server using the 
        /// report interface component.
        /// </summary>
        protected void GetQuickReportLumber()
        {
            // Check security for this report
            HasPrivilege(SecurityMgr.Privilege.ReportQuickList);

            // Setup parameters required for this report
            string szCompanyIDList = GetRequestParameter("CompanyIDList", true, false, true);
            string szHeaderText = GetRequestParameter("HeaderText", false);
            string szReportSortOption = GetRequestParameter("ReportSortOption", false);

            bool bIncludeHeadExecutive = Convert.ToBoolean(GetRequestParameter("IncludeHeadExecutive"));

            // Set report type and name
            _szContentType = "application/pdf";
            _szReportName = string.Format(Resources.Global.QuickReportName, GetApplicationNameAbbr());

            // Retrieve report
            _oReport = _oRI.GenerateMPRQuickListReportLumber(szCompanyIDList, bIncludeHeadExecutive, szHeaderText,
                                                             _oUser.prwu_Culture, _oUser.prwu_AccessLevel, szReportSortOption);
        }


        /// <summary>
        /// Helper method used to retrieve the MPR Full Blue Book Listing Report from the report server 
        /// using the report interface component.
        /// </summary>
        protected void GetFullListingReport()
        {
            // Check security for this report
            HasPrivilege(SecurityMgr.Privilege.ReportFullBlueBookListing);

            // Setup parameters required for this report
            string szCompanyIDList = GetRequestParameter("CompanyIDList", true, false, true);
            string szHeaderText = GetRequestParameter("HeaderText", false);
            string szReportSortOption = GetRequestParameter("ReportSortOption", false);

            // Set report type and name
            _szContentType = "application/pdf";
            _szReportName = string.Format(Resources.Global.FullListingReportName, GetApplicationNameAbbr());

            // Retrieve report
            _oReport = _oRI.GenerateMPRFullBlueBookListingReport(szCompanyIDList, szHeaderText, _oUser.prwu_Culture, szReportSortOption);
        }
        
        /// <summary>
        /// Helper method used to retrieve the MPR Notes Report from the report server using the report 
        /// interface component.
        /// </summary>
        protected void GetNotesReport() {
            // Check security for this report
            HasPrivilege(SecurityMgr.Privilege.ReportNotes);

            // Setup parameters required for this report
            string szNoteIDList = GetRequestParameter("NoteIDList", false);
            string szHeaderText = GetRequestParameter("HeaderText", false);
            string szReportSortOption = GetRequestParameter("ReportSortOption", false);

            int iCompanyID = 0;
            if (GetRequestParameter("CompanyID", false) != null) {
                iCompanyID = Convert.ToInt32(GetRequestParameter("CompanyID"));
            }

            int iPersonID = 0;
            if (GetRequestParameter("PersonID", false) != null) {
                iPersonID = Convert.ToInt32(GetRequestParameter("PersonID"));
            }            

            // Set report type and name
            _szContentType = "application/pdf";
            _szReportName = string.Format(Resources.Global.NotesReportName, GetApplicationNameAbbr());

            // Retrieve report
            _oReport = _oRI.GenerateMPRNotesReport(iCompanyID, szNoteIDList, iPersonID, _oUser.prwu_WebUserID, 
                _oUser.prwu_HQID, szHeaderText, _oUser.prwu_Culture, szReportSortOption);
        }

        /// <summary>
        /// Helper method used to retrieve the Rating Comparison Report from the report server using the
        /// report interface component.
        /// </summary>
        protected void GetRatingComparisonReport() {
            // Check security for this report
            HasPrivilege(SecurityMgr.Privilege.ReportRatingComparison);

            // Setup parameters required for this report
            string szCompanyIDList = GetRequestParameter("CompanyIDList", false);
            string szHeaderText = GetRequestParameter("HeaderText", false);
            string szReportSortOption = GetRequestParameter("ReportSortOption", false);

            // Set report type and name
            _szContentType = "application/pdf";
            _szReportName = string.Format(Resources.Global.RatingComparisonReportName, GetApplicationNameAbbr());

            // Retrieve report
            _oReport = _oRI.GenerateRatingComparisonReport(szCompanyIDList, _oUser.prwu_Culture, szHeaderText, szReportSortOption);
        }

        /// <summary>
        /// Helper method used to retrieve the Company Listing report from the report server using the 
        /// report interface components
        /// </summary>
        protected void GetCompanyListingReport() {
            // Check security for this report
            HasPrivilege(SecurityMgr.Privilege.ReportCompanyListing);

            // Setup parameters required for this report
            string szCompanyID = GetRequestParameter("CompanyID", true, false, true);
            bool bIncludeBranches = Convert.ToBoolean(GetRequestParameter("IncludeBranches"));
            bool bIncludeAffiliations = Convert.ToBoolean(GetRequestParameter("IncludeAffiliations"));

            // Set report type and name
            _szContentType = "application/pdf";
            _szReportName = string.Format("{0} Listing.pdf", GetApplicationNameAbbr());

            // Retrieve report
            _oReport = _oRI.GenerateCompanyListingReport(szCompanyID, bIncludeBranches, bIncludeAffiliations);
        }

        /// <summary>
        /// Helper method used to retrieve the Company Listing report from the report server using the 
        /// report interface components - this is for the shortened version that is used for ITA users
        /// and was previously called non-member listing
        /// </summary>
        protected void GetCompanyListingReport_Basic()
        {
            // Check security for this report
            if(!(_oUser.HasPrivilege(SecurityMgr.Privilege.ReportCompanyListing).HasPrivilege || _oUser.prwu_AccessLevel == PRWebUser.SECURITY_LEVEL_TRADE_ASSOCIATION_ACCESS))
                HasPrivilege(SecurityMgr.Privilege.ReportCompanyListing);

            // Setup parameters required for this report
            string szCompanyID = GetRequestParameter("CompanyID", true, false, true);
            //bool bIncludeBranches = false; // Convert.ToBoolean(GetRequestParameter("IncludeBranches"));

            // Set report type and name
            _szContentType = "application/pdf";
            _szReportName = string.Format("{0} Listing.pdf", GetApplicationNameAbbr());

            // Retrieve report
            _oReport = _oRI.GenerateCompanyListingReport_Basic(szCompanyID);
        }

        /// <summary>
        /// Helper method used to retrieve the Company Commodity report from the report server using the 
        /// report interface components
        /// </summary>
        protected void GetCompanyCommodityReport()
        {
            // Check security for this report
            HasPrivilege(SecurityMgr.Privilege.CompanyDetailsClassificationsCommoditesPage);

            // Setup parameters required for this report
            string szCompanyID = GetRequestParameter("CompanyID", true, false, true);
            string szCulture = GetRequestParameter("Culture").ToLower();

            // Set report type and name
            _szContentType = "application/pdf";
            _szReportName = string.Format("Commodity Listing ({0}).pdf", szCompanyID);

            // Retrieve report
            _oReport = _oRI.GenerateCompanyCommodityReport(szCompanyID, szCulture);
        }

        /// <summary>
        /// Helper method used to retrieve the Blue Book Score Report from the report server using the 
        /// report interface components.
        /// </summary>
        protected void GetBlueBookScoreReport()
        {
            // Check Security for this report
            HasPrivilege(SecurityMgr.Privilege.ReportBBScore);

            // Setup parameters required for this report            
            string szCompanyIDList = GetRequestParameter("CompanyIDList", true);
            string szHeaderText = GetRequestParameter("HeaderText", false);            
            int iCompanyID = _oUser.prwu_BBID;
            int iBBScoreConfidenceThreshold = Configuration.BBScoreConfidenceThreshold;

            // Set report type and name
            _szContentType = "application/pdf";
            _szReportName = string.Format(Resources.Global.BlueBookScoreReportName, GetApplicationNameAbbr());

            // Retrieve report
            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                _oReport = _oRI.GenerateBlueBookScoreReport_Lumber(iCompanyID, szHeaderText, szCompanyIDList, iBBScoreConfidenceThreshold);
            else
                _oReport = _oRI.GenerateBlueBookScoreReport(iCompanyID, szHeaderText, szCompanyIDList, iBBScoreConfidenceThreshold);
        }
        
        /// <summary>
        /// Since different reports can be accessed by different security
        /// levels, the security will be implemented by each report method.
        /// </summary>
        /// <returns></returns>
        protected override bool IsAuthorizedForPage() {
            return true;            
        }
        
        protected override bool IsAuthorizedForData() {
            return true;
        }


        protected void HasPrivilege(SecurityMgr.Privilege privilege)
        {
            if (!_oUser.HasPrivilege(privilege).HasPrivilege)
            {
                throw new AuthorizationException(Resources.Global.UnauthorizedForReportMsg);
            }
        }


        public override void PreparePageFooter() {
            // Do nothing
        }

        protected const string COMPANY_CONTACT_EXPORT_RECORD = "{0},\"{1}\",\"{2}\",\"{3}\",\"{4}\",\"{5}\",\"{6}\",\"{7}\",\"{8}\",\"{9}\",\"{10}\",\"{11}\",\"{12}\",\"{13}\",{14},{15},\"{16}\",\"{17}\",\"{18}\"";

        /// <summary>
        /// This data extract is implemented in code instead of SSRS due to issues with the character-encoding
        /// when importing into MS Outlook.
        /// </summary>
        /// <param name="szCompanyIDList"></param>
        /// <returns></returns>
        protected byte[] GenerateCompanyContactExportMSOReport(string szCompanyIDList) {
            StringBuilder sbExport = new StringBuilder("OrganizationalIDNumber,Company,BusinessStreet,BusinessStreet2,BusinessCity,BusinessState,BusinessPostalCode,BusinessCountry,OtherStreet,OtherStreet2,OtherCity,OtherState,OtherPostalCode,OtherCountry,CompanyMainPhone,BusinessFax,E-mailAddress,WebPage,Notes" + Environment.NewLine);

            string szSQL = "SELECT * FROM vPRCompanyContactExportMSO WHERE OrganizationalIDNumber IN (" + szCompanyIDList + ") ORDER BY Company";
            IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection);
            try {
                while (oReader.Read()) {
                    object[] args = {oReader[0],
                                   oReader[1],
                                   oReader[2],
                                   oReader[3],
                                   oReader[4],
                                   oReader[5],
                                   oReader[6],
                                   oReader[7],
                                   oReader[8],
                                   oReader[9],
                                   oReader[10],
                                   oReader[11],
                                   oReader[12],
                                   oReader[13],
                                   oReader[14],
                                   oReader[15],
                                   oReader[16],
                                   oReader[17],
                                   string.Format(Resources.Global.VCardComment, 
                                                 GetCompanyName(),
                                                 GetApplicationName(),
                                                 DateTime.Now.ToString())};

                    sbExport.Append(string.Format(COMPANY_CONTACT_EXPORT_RECORD, args) + Environment.NewLine);
                }        
                
            } finally {
                if (oReader != null) {
                    oReader.Close();
                }
            }

            return System.Text.Encoding.UTF8.GetBytes(sbExport.ToString());
        }

        protected const string CONTACT_EXPORT_RECORD = "{0},\"{1}\",\"{2}\",\"{3}\",\"{4}\",\"{5}\",\"{6}\",\"{7}\",\"{8}\",\"{9}\",\"{10}\",\"{11}\",\"{12}\",\"{13}\",{14},{15},\"{16}\",\"{17}\",\"{18}\",\"{19}\",\"{20}\",\"{21}\",\"{22}\",\"{23}\",\"{24}\"";
        protected const string SQL_CONTACT_EXPORT_MSO =
            @"SELECT * 
                FROM {0} 
               WHERE OrganizationalIDNumber IN ({1}) 
              ORDER BY Company";

        protected const string CONTACT_EXPORT_MSO_HEADER = "OrganizationalIDNumber,Company,FirstName,MiddleName,LastName,Suffix,Title,BusinessStreet,BusinessStreet2,BusinessCity,BusinessState,BusinessPostalCode,BusinessCountry,OtherStreet,OtherStreet2,OtherCity,OtherState,OtherPostalCode,OtherCountry,CompanyMainPhone,CompanyFax,BusinessPhone,BusinessFax,E-mailAddress,Notes";

        protected byte[] GenerateContactExportMSOReport(string szContactType, string szCompanyIDList) {
            StringBuilder sbExport = new StringBuilder(CONTACT_EXPORT_MSO_HEADER + Environment.NewLine);

            string szFrom = null;
            if (szContactType == "AC") {
                szFrom = "vPRContactExportAllMSO";
            } else {
                szFrom = "vPRContactExportHEMSO";
            }

            string szSQL = string.Format(SQL_CONTACT_EXPORT_MSO, szFrom, szCompanyIDList);
            IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection);
            try {
                while (oReader.Read()) {
                    object[] args = {oReader[0],oReader[1],oReader[2],oReader[3],
                                     oReader[4],oReader[5],oReader[6],oReader[7],
                                     oReader[8],oReader[9],oReader[10],oReader[11],
                                     oReader[12],oReader[13],oReader[14],oReader[15],
                                     oReader[16],oReader[17],oReader[18],oReader[19],
                                     oReader[20],oReader[21],oReader[22],oReader[23],
                                     string.Format(Resources.Global.VCardComment, 
                                                   GetCompanyName(),
                                                   GetApplicationName(),
                                                   DateTime.Now.ToString())};

                    sbExport.Append(string.Format(CONTACT_EXPORT_RECORD, args) + Environment.NewLine);
                }

            } finally {
                if (oReader != null) {
                    oReader.Close();
                }
            }

            return System.Text.Encoding.UTF8.GetBytes(sbExport.ToString());
        }

        protected const string PERSON_EXPORT_RECORD_HEADER = "FirstName,MiddleName,LastName,Suffix,Title,Company,Industry,MailingStreet1,MailingStreet2,MailingStreet3,MailingStreet4,MailingCity,MailingState,MailingPostalCode,MailingCountry,PhysicalStreet1,PhysicalStreet2,PhysicalStreet3,PhysicalStreet14,PhysicalCity,PhysicalState,PhysicalPostalCode,PhysicalCountry,CompanyPhone,BusinessPhone,BusinessFax,Email,BBID";
        protected const string PERSON_EXPORT_RECORD = "\"{0}\",\"{1}\",\"{2}\",\"{3}\",\"{4}\",\"{5}\",\"{6}\",\"{7}\",\"{8}\",\"{9}\",\"{10}\",\"{11}\",\"{12}\",\"{13}\",\"{14}\",\"{15}\",\"{16}\",\"{17}\",\"{18}\",\"{19}\",\"{20}\",\"{21}\",\"{22}\",\"{23}\",\"{24}\",\"{25}\",\"{26}\",\"{27}\"";
        protected const string SQL_SELECT_PERSON_EXPORT =
            "SELECT * FROM vPRPersonExport WHERE pers_PersonID IN ({0}) ORDER BY LastName, FirstName, Company, Title ";

        protected void GeneratePersonExport()
        {
            string szPersonIDList = GetRequestParameter("PersonIDList", true, false, true);
            string szExportType = GetRequestParameter("ExportType");



            StringBuilder sbExport = new StringBuilder();
            if (szExportType == "MSO")
            {
                sbExport.Append(CONTACT_EXPORT_MSO_HEADER + Environment.NewLine);
            }
            else
            {
                sbExport.Append(PERSON_EXPORT_RECORD_HEADER + Environment.NewLine);
            }

            string szSQL = string.Format(SQL_SELECT_PERSON_EXPORT, szPersonIDList);
            using (IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection)) 
            {
                while (oReader.Read())
                {
                    if (szExportType == "MSO") { 
                        object[] args = {oReader[27],oReader[6],oReader[1],oReader[2],
                                         oReader[3],oReader[4],oReader[5],
                                         oReader[7], oReader[8],oReader[11],oReader[12],oReader[13],oReader[14],
                                         oReader[15],oReader[16],oReader[19],oReader[20],oReader[21],oReader[22],
                                         oReader[23],oReader[24],oReader[25],oReader[26],
                                         string.Format(Resources.Global.VCardComment, 
                                                       GetCompanyName(),
                                                       GetApplicationName(),
                                                       DateTime.Now.ToString()),
                                        string.Empty,string.Empty};

                        sbExport.Append(string.Format(CONTACT_EXPORT_RECORD, args) + Environment.NewLine);
                    } else {

                        object[] args = {oReader[1],oReader[2],oReader[3],oReader[4],oReader[5],oReader[6],oReader[28], 
                                          oReader[7], oReader[8], oReader[9],oReader[10],oReader[11],oReader[12],oReader[13],oReader[14],
                                         oReader[15],oReader[16],oReader[17],oReader[18],oReader[19],oReader[20],oReader[21],oReader[22],
                                         oReader[23],oReader[24],oReader[25],oReader[26],oReader[27]};

                        sbExport.Append(string.Format(PERSON_EXPORT_RECORD, args) + Environment.NewLine);
                
                    }
                }

            }

            // Set report type and name
            _szContentType = "application/csv";
            _szReportName = string.Format("{0} Person Export.csv", GetApplicationNameAbbr());
            _oReport = System.Text.Encoding.UTF8.GetBytes(sbExport.ToString());
        }


        protected void GetPersonnelReport()
        {
            HasPrivilege(SecurityMgr.Privilege.ReportPersonnel);

            // Setup parameters required for this report
            string szPersonIDList = GetRequestParameter("PersonIDList", true, false, true);
            string szHeaderText = GetRequestParameter("HeaderText", false);

            // Set report type and name
            _szContentType = "application/pdf";
            _szReportName = string.Format("{0} Personnel Report.pdf", GetApplicationNameAbbr());
            // Retrieve report
            _oReport = _oRI.GeneratePersonnelReport(szPersonIDList, szHeaderText);
        }

        private string SQL_INTERNAL_EXPORT =
            @"SELECT * FROM vPRBBOSInternalExport WHERE [Company ID] IN ({0}) ORDER BY [Company ID]";

        protected void GenerateInternalExport()
        {
            if (!IsPRCoUser())
            {
                throw new AuthorizationException(Resources.Global.UnauthorizedForReportMsg);
            }

            // Setup parameters required for this report
            string szCompanyIDList = GetRequestParameter("CompanyIDList", true, false, true);

            // Set report type and name
            _szContentType = "application/csv";
            _szReportName = "BBOS Internal Export.csv";

            StringBuilder sbExport = new StringBuilder();
            StringBuilder sbWork = new StringBuilder();
            string szSQL = string.Format(SQL_INTERNAL_EXPORT, szCompanyIDList);
            using (IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection))
            {
                bool header = false;

                while (oReader.Read())
                {
                    if (!header)
                    {
                        for (int i = 0; i < oReader.FieldCount; i++)
                        {
                            AddCSVValue(sbExport, oReader.GetName(i));
                        }
                        sbExport.Append(Environment.NewLine);
                        header = true;
                    }

                    sbWork.Clear();
                    for (int i = 0; i < oReader.FieldCount; i++)
                    {
                        AddCSVValue(sbWork, oReader[i]);
                    }
                    sbExport.Append(sbWork);
                    sbExport.Append(Environment.NewLine);
                }

            }

            _oReport = System.Text.Encoding.UTF8.GetBytes(sbExport.ToString());
        }

        private void AddCSVValue(StringBuilder csv, object value)
        {
            if (csv.Length > 0)
                csv.Append(",");

            if (value is string)
                csv.Append("\"");

            csv.Append(value);

            if (value is string)
                csv.Append("\"");
        }
    }   
}
