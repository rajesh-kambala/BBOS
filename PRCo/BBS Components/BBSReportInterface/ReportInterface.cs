/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Company 2006-2023

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: ReportInterface
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Net;
using System.Reflection;
using System.Xml;
using PRCo.BBS.ReportExecution;
using PRCo.BBS.ReportService;

namespace PRCo.BBS
{
    /// <summary>
    /// Interface to retrieve reports from Reporting Services.  The public
    /// methods are for specific reports.  There are several protected helper
    /// method
    /// </summary>
    public class ReportInterface
	{
        public ReportExecutionService _oReportExecution;
        public ReportingService2005 _oReportService;

		public ReportInterface() {
        }

		/// <summary>
		/// The main entry point for the application.  Used for
        /// debugging/testing
		/// </summary>
		[STAThread]
		static void Main(string[] args) {

            ReportInterface oTest = null;
			try
            {
                oTest = new ReportInterface();

                oTest.WriteSettings();
                //byte[] oResult = oTest.GenerateBBScoreGauge(102030, false);

                //GenerateBBScoreGauges(oTest);
                //GenerateTradeActivityGauges(oTest);
            }
            catch (Exception e) {
                System.Console.WriteLine(oTest._oReportService.Url);

				System.Console.WriteLine(e.Message);
                System.Console.WriteLine(e.StackTrace);
			}

            Console.Write("Press any key to continue . . . ");
            Console.ReadKey(true);

		}

        private static void GenerateTradeActivityGauges(ReportInterface oTest)
        {
            //const string Language = "E"; //comment one or the other out
            const string Language = "S"; //comment one or the other out

            //Generate 300 images for TradeActivityGauges
            for (decimal decScore = 1.00M; decScore <= 4.00M; decScore += 0.01M)
            {
                byte[] oResult = oTest.GenerateTradeActivitySummaryGauge(decScore, true, Language);
                string szFileName = string.Format("TradeActivityGauge_{0:0.00}.jpg", decScore);
                using (FileStream stream = File.Create(szFileName, oResult.Length))
                {
                    stream.Write(oResult, 0, oResult.Length);
                }
            }
        }

        private static void GenerateBBScoreGauges(ReportInterface oTest)
        {
            //const string Language = "E"; //comment one or the other out
            const string Language = "S"; //comment one or the other out

            //Generate 2000 images for BBScoreGauges
            for (int intScore = 500; intScore <= 999; intScore++)
            {
                byte[] oResult = oTest.GenerateBBScoreGauge3(intScore, "P", true, Language);
                string szFileName = string.Format("BBScore_Text_{0:000}.jpg",  intScore); //BBScore_Text_500.jpg
                using (FileStream stream = File.Create(szFileName, oResult.Length))
                {
                    stream.Write(oResult, 0, oResult.Length);
                }

                oResult = oTest.GenerateBBScoreGauge3(intScore, "P", false, Language);
                szFileName = string.Format("BBScore_NoText_{0:000}.jpg", intScore); //BBScore_NoText_500.jpg
                using (FileStream stream = File.Create(szFileName, oResult.Length))
                {
                    stream.Write(oResult, 0, oResult.Length);
                }

                oResult = oTest.GenerateBBScoreGauge3(intScore, "L", true, Language);
                szFileName = string.Format("BBScore_Text_{0:000}_Lumber.jpg", intScore); //BBScore_Text_500_Lumber.jpg
                using (FileStream stream = File.Create(szFileName, oResult.Length))
                {
                    stream.Write(oResult, 0, oResult.Length);
                }

                oResult = oTest.GenerateBBScoreGauge3(intScore, "L", false, Language);
                szFileName = string.Format("BBScore_NoText_{0:000}_Lumber.jpg", intScore); //BBScore_NoText_500_Lumber.jpg
                using (FileStream stream = File.Create(szFileName, oResult.Length))
                {
                    stream.Write(oResult, 0, oResult.Length);
                }
            }
        }

        public Byte[] GenerateARAnalysisReport(int companyID, DateTime dtStartDate, DateTime dtEndDate)
        {
            string szReportName = GetConfigValue("BBOSMemberReports", "/BBOSMemberReports/Accounts Receivable Analysis");
            List<ReportParameter> reportParms = GetReportParmList("CompanyID", companyID.ToString());
            reportParms.Add(new ReportParameter("StartDate", dtStartDate.ToString()));
            reportParms.Add(new ReportParameter("EndDate", dtEndDate.ToString()));
            return GenerateReport(szReportName, reportParms, "EXCELOPENXML");
        }


        public Byte[] GenerateARReportsReport(int companyID, int ARAgingThresold, string industryType)
        {
            string szReportName = null;
            if(industryType == "L") {
                szReportName = GetConfigValue("ARReportsLumber", "/BBOSMemberReports/AR Reports - Lumber");
            } else {
                szReportName = GetConfigValue("ARReports", "/BBOSMemberReports/AR Reports");
            }
                
            List<ReportParameter> reportParms = GetReportParmList("SubjectCompanyID", companyID.ToString());
            reportParms.Add(new ReportParameter("ARAgingThresold", ARAgingThresold.ToString()));
            return GenerateReport(szReportName, reportParms);
        }

        public Byte[] GenerateBBScoreGauge(int companyID, bool displayText)
        {
            string szReportName = GetConfigValue("BBScoreGuage", "/BusinessReport/BBScoreGauge");
            List<ReportParameter> reportParms = GetReportParmList("CompanyID", companyID.ToString());
            reportParms.Add(new ReportParameter("DisplayText", displayText.ToString()));
            return GenerateReport(szReportName, reportParms, "IMAGE (JPEG)");
        }

        public Byte[] GenerateBBScoreGauge2(int BBScore, string IndustryType, bool displayText, string Language)
        {
            string szReportName = GetConfigValue("BBScoreGuage2", "/BusinessReport/BBScoreGauge2");
            List<ReportParameter> reportParms = GetReportParmList("prbs_BBScore", BBScore.ToString());
            reportParms.Add(new ReportParameter("comp_PRIndustryType", IndustryType));
            reportParms.Add(new ReportParameter("DisplayText", displayText.ToString()));
            reportParms.Add(new ReportParameter("Language", Language));
            return GenerateReport(szReportName, reportParms, "IMAGE (JPEG)");
        }

        public Byte[] GenerateBBScoreGauge3(int BBScore, string IndustryType, bool displayText, string Language)
        {
            string szReportName = GetConfigValue("BBScoreGauge3", "/BusinessReport/BBScoreGauge3");
            List<ReportParameter> reportParms = GetReportParmList("prbs_BBScore", BBScore.ToString());
            reportParms.Add(new ReportParameter("comp_PRIndustryType", IndustryType));
            reportParms.Add(new ReportParameter("DisplayText", displayText.ToString()));
            reportParms.Add(new ReportParameter("Language", Language));
            return GenerateReport(szReportName, reportParms, "IMAGE (JPEG)");
        }

        public Byte[] GenerateTradeActivitySummaryGauge(decimal tradeActivityScore, bool displayText, string Language)
        {
            string szReportName = GetConfigValue("TradeActivitySummaryGauge", "/BusinessReport/TradeActivitySummaryGauge");
            List<ReportParameter> reportParms = GetReportParmList("TradeActivityScore", tradeActivityScore.ToString());
            reportParms.Add(new ReportParameter("DisplayText", displayText.ToString()));
            reportParms.Add(new ReportParameter("Language", Language));
            return GenerateReport(szReportName, reportParms, "IMAGE (JPEG)");
        }


        public Byte[] GenerateCreditMonitor(int webUserID)
        {
            string szReportName = GetConfigValue("CreditMonitor", "/BBOSMemberReports/Credit Monitor");
            List<ReportParameter> reportParms = GetReportParmList("WebUserID", webUserID.ToString());
            return GenerateReport(szReportName, reportParms);
        }


        public Byte[] GenerateInvoice(string szInvoiceNo)
        {
            string szReportName = GetConfigValue("Invoice", "/Accounting/Invoice");
            List<ReportParameter> reportParms = GetReportParmList("InvoiceNo", szInvoiceNo);
            return GenerateReport(szReportName, reportParms);
        }

        public Byte[] GenerateInvoiceStripe(string szInvoiceNo)
        {
            string szReportName = GetConfigValue("Invoice", "/Accounting/InvoiceStripe");
            List<ReportParameter> reportParms = GetReportParmList("InvoiceNo", szInvoiceNo);
            return GenerateReport(szReportName, reportParms);
        }

        public Byte[] GenerateInvoiceBatch(string szBatchNo, string szBillingException)
        {
            string szReportName = GetConfigValue("InvoiceBatch", "/Accounting/InvoiceBatch");
            List<ReportParameter> reportParms = GetReportParmList("BatchNo", szBatchNo);
            reportParms.Add(new ReportParameter("BillingException", szBillingException));
            return GenerateReport(szReportName, reportParms);
        }

        public Byte[] GenerateFaxErrorsByUserReport(string szLogonID, int iDaysThreshold)
        {
            string szReportName = GetConfigValue("FaxErrorsByUserReport", "/BBSReporting/FaxErrorsByUser");
            List<ReportParameter> reportParms = GetReportParmList("UserID", szLogonID);
            reportParms.Add(new ReportParameter("DaysThrehold", iDaysThreshold.ToString()));
            return GenerateReport(szReportName, reportParms);
        }


        public Byte[] GenerateCreditSheetReportEmail(string szReportType, string szIndustryType, string szReportDate)
        {
            string szReportName = GetConfigValue("CreditSheetReportEmail", "/BBOSMemberReports/CreditSheetReportEmail");
            List<ReportParameter> reportParms = GetReportParmList("ReportType", szReportType);
            reportParms.Add(new ReportParameter("IndustryType", szIndustryType));
            reportParms.Add(new ReportParameter("ReportDate", szReportDate));
            return GenerateReport(szReportName, reportParms);
        }

        public Byte[] GenerateCreditSheetReportFax(string szReportType, string szIndustryType, string szReportDate)
        {
            string szReportName = GetConfigValue("CreditSheetReportFax", "/BBOSMemberReports/CreditSheetReportFax");
            List<ReportParameter> reportParms = GetReportParmList("ReportType", szReportType);
            reportParms.Add(new ReportParameter("IndustryType", szIndustryType));
            reportParms.Add(new ReportParameter("ReportDate", szReportDate));
            return GenerateReport(szReportName, reportParms);
        }

        public Byte[] GenerateCreditSheetReportEmail(string szReportType, string szIndustryType, string szReportDate, string sortType, string messageHdr, string message, bool bHighlightMarketingMsg)
        {
            string szReportName = GetConfigValue("CreditSheetReportEmail", "/BBOSMemberReports/CreditSheetReportEmail");
            List<ReportParameter> reportParms = GetReportParmList("ReportType", szReportType);
            reportParms.Add(new ReportParameter("IndustryType", szIndustryType));
            reportParms.Add(new ReportParameter("ReportDate", szReportDate));
            reportParms.Add(new ReportParameter("SortType", sortType));
            reportParms.Add(new ReportParameter("MessageHdr", messageHdr));
            reportParms.Add(new ReportParameter("Message", message));
            reportParms.Add(new ReportParameter("HighlightMarketingMsg", bHighlightMarketingMsg.ToString()));
            return GenerateReport(szReportName, reportParms);
        }

        public Byte[] GenerateCreditSheetReportFax(string szReportType, string szIndustryType, string szReportDate, string sortType, string messageHdr, string message)
        {
            string szReportName = GetConfigValue("CreditSheetReportFax", "/BBOSMemberReports/CreditSheetReportFax");
            List<ReportParameter> reportParms = GetReportParmList("ReportType", szReportType);
            reportParms.Add(new ReportParameter("IndustryType", szIndustryType));
            reportParms.Add(new ReportParameter("ReportDate", szReportDate));
            reportParms.Add(new ReportParameter("SortType", sortType));
            reportParms.Add(new ReportParameter("MessageHdr", messageHdr));
            reportParms.Add(new ReportParameter("Message", message));
            return GenerateReport(szReportName, reportParms);
        }



        /// <summary>
        /// Generate a BOR Light Report which is currently
        /// lumber specific.
        /// </summary>
        /// <param name="iCompanyID"></param>
        /// <returns></returns>
        public Byte[] GenerateBORLightReport(int iCompanyID)
        {
            string szReportName = GetConfigValue("BORLight", "/BBOSMemberReports/BORLight");
            List<ReportParameter> reportParms = GetReportParmList("CompanyID", iCompanyID.ToString());
            return GenerateReport(szReportName, reportParms);
        }

        /// <summary>
        /// Generate a Publishable Information Report which is a 
        /// variation of the Business Report.
        /// </summary>
        /// <param name="iCompanyID"></param>
        /// <returns></returns>
        public Byte[] GeneratePublishableInformationReport(int iCompanyID)
        {
            string szReportName = GetConfigValue("PublishableInformationReport", "/BusinessReport/PublishableInformationReport");
            List<ReportParameter> reportParms = GetReportParmList("CompanyID", iCompanyID.ToString());
            return GenerateReport(szReportName, reportParms);
        }


        public Byte[] GenerateLumberPreReleaseFaxReport(int iCompanyID, bool bDisplayCoverLetter, bool bDisplayListing, bool bDisplayPIR) {
            string szReportName = GetConfigValue("LumberPreReleaseFax", "/BusinessReport/LumberPreReleaseFax");
            List<ReportParameter> reportParms = GetReportParmList("CompanyID", iCompanyID.ToString());
            reportParms.Add(new ReportParameter("DisplayCoverLetter", bDisplayCoverLetter.ToString()));
            reportParms.Add(new ReportParameter("DisplayListing", bDisplayListing.ToString()));
            reportParms.Add(new ReportParameter("DisplayPIR", bDisplayPIR.ToString()));
            return GenerateReport(szReportName, reportParms);
        }

        /// <summary>
        /// Generates the specified Jeopardy Letters for the 
        /// specified company
        /// </summary>
        /// <param name="szCompanyIDList"></param>
        /// <param name="iType"></param>
        /// <returns></returns>
        public Byte[] GenerateJeopardyLetter(string szCompanyIDList, int iType) {

            List<ReportParameter> reportParms = GetReportParmList("CompanyIDs", szCompanyIDList);
            reportParms.Add(new ReportParameter("LetterType", iType.ToString()));

            string szReportName = null;
            switch (iType) {
                case 1:
                    szReportName = GetConfigValue("JeopardyLetter1Report", "/JeopardyLetters/JeopardyLetterList");
                    break;
                case 2:
                    szReportName = GetConfigValue("JeopardyLetter2Report", "/JeopardyLetters/JeopardyLetterList");
                    break;
                case 3:
                    szReportName = GetConfigValue("JeopardyLetter3Report", "/JeopardyLetters/JeopardyLetter3");
                    reportParms[0].Name = "CompanyID";
                    break;
            }

            return GenerateReport(szReportName, reportParms);
        }

        public Byte[] GenerateJeopardyLetter(int CompanyID, string Type)
        {

            List<ReportParameter> reportParms = GetReportParmList("CompanyID", CompanyID.ToString());
            reportParms.Add(new ReportParameter("LetterType", Type));

            string szReportName = GetConfigValue("JeopardyLetter", "/JeopardyLetters/JeopardyLetter");
            return GenerateReport(szReportName, reportParms);
        }

        public Byte[] GenerateJeopardyLetters(string CompanyIDs, string Type)
        {

            List<ReportParameter> reportParms = GetReportParmList("CompanyIDs", CompanyIDs);
            reportParms.Add(new ReportParameter("LetterType", Type));

            string szReportName = GetConfigValue("JeopardyLetter", "/JeopardyLetters/JeopardyLetters");
            return GenerateReport(szReportName, reportParms);
        }

        /// <summary>
        /// Generate a Transaction Listing Report for only open transactions
        /// for the specified user.
        /// </summary>
        /// <param name="iCreatedBy"></param>
        /// <returns></returns>
        public Byte[] GenerateOpenTransactionListingReport(int iCreatedBy) {
            string szReportName = GetConfigValue("TransactionListingReport", "/BBSReporting/TransactionList");
            List<ReportParameter> reportParms = GetReportParmList("paramCreatedBy", iCreatedBy.ToString());
            reportParms.Add(new ReportParameter("paramStatus", "O"));

            return GenerateReport(szReportName, reportParms);
        }

        /// <summary>
        /// Generates the Transaction Listing report using the 
        /// specified parameters.
        /// </summary>
        /// <param name="dtStartDate"></param>
        /// <param name="dtEndDate"></param>
        /// <param name="szType"></param>
        /// <param name="iCreatedBy"></param>
        /// <param name="szStatus"></param>
        /// <returns></returns>
        public Byte[] GenerateTransactionListingReport(DateTime dtStartDate,
                                                       DateTime dtEndDate,
                                                       string szType,
                                                       int iCreatedBy,
                                                       string szStatus) {

            string szReportName = GetConfigValue("TransactionListingReport", "/BBSReporting/TransactionList");
            List<ReportParameter> reportParms = GetReportParmList("FromDate", dtStartDate.ToShortDateString());
            reportParms.Add(new ReportParameter("ThroughDate", dtEndDate.ToShortDateString()));
            reportParms.Add(new ReportParameter("TrxType", szType));
            reportParms.Add(new ReportParameter("paramCreatedBy", iCreatedBy.ToString()));
            reportParms.Add(new ReportParameter("paramStatus", szStatus));
            return GenerateReport(szReportName, reportParms);
        }


        /// <summary>
        /// Generates the TES Single report.  The report
        /// determines if the English or Spanish version
        /// should be used.
        /// </summary>
        /// <param name="iSerialNumber"></param>
        /// <returns></returns>
        public Byte[] GenerateTESReport(int iSerialNumber) {
            string szReportName = GetConfigValue("TESReportName", "/TESForms/TES");
            List<ReportParameter> reportParms = GetReportParmList("SerialNumber", iSerialNumber.ToString());
            return GenerateReport(szReportName, reportParms);
        }



        /// <summary>
        /// Generates the BBScore report.
        /// </summary>
        /// <param name="iCompanyID"></param>
        /// <returns></returns>
        public Byte[] GenerateBBScoreReport(int iCompanyID) {
            string szReportName = GetConfigValue("BBScoreReportName", "/BBScoreReports/BBScore");
            List<ReportParameter> reportParms = GetReportParmList("CompanyID", iCompanyID.ToString());
            return GenerateReport(szReportName, reportParms);

        }

        /// <summary>
        /// Generates the BBScore report.
        /// </summary>
        /// <param name="iCompanyID"></param>
        /// <param name="dtReportDate"></param>
        /// <returns></returns>
        public Byte[] GenerateBBScoreReport(int iCompanyID, DateTime dtReportDate) {
            string szReportName = GetConfigValue("BBScoreReportName", "/BBScoreReports/BBScore");
            List<ReportParameter> reportParms = GetReportParmList("CompanyID", iCompanyID.ToString());
            reportParms.Add(new ReportParameter("ReportDate", dtReportDate.ToString()));
            return GenerateReport(szReportName, reportParms);
        }

        /// <summary>
        /// Generates the BBScore Lumber report.
        /// </summary>
        /// <param name="iCompanyID"></param>
        /// <param name="dtReportDate"></param>
        /// <param name="iWebUserID"></param>
        /// <returns></returns>
        public Byte[] GenerateBBScoreReport_Lumber(int iCompanyID, DateTime dtReportDate, int iWebUserID)
        {
            string szReportName = GetConfigValue("BBScoreReportName_Lumber", "/BBScoreReports/BBScoreLumber");
            List<ReportParameter> reportParms = GetReportParmList("CompanyID", iCompanyID.ToString());
            reportParms.Add(new ReportParameter("ReportDate", dtReportDate.ToString()));
            reportParms.Add(new ReportParameter("WebUserID", iWebUserID.ToString()));
            return GenerateReport(szReportName, reportParms);
        }

        /// <summary>
        /// Generates the BBScore export CSV file.
        /// </summary>
        /// <param name="iCompanyID"></param>
        /// <returns></returns>
        public Byte[] GenerateBBScoreExport(int iCompanyID) {
            string szReportName = GetConfigValue("BBScoreExtractName", "/BBScoreReports/BBScoreExtract");
            List<ReportParameter> reportParms = GetReportParmList("CompanyID", iCompanyID.ToString());
            return GenerateReport(szReportName, reportParms, "csv");
        }


        /// <summary>
        /// Generates the BBScore export CSV file.
        /// </summary>
        /// <param name="iCompanyID"></param>
        /// <param name="dtReportDate"></param>
        /// <returns></returns>
        public Byte[] GenerateBBScoreExport(int iCompanyID, DateTime dtReportDate) {
            string szReportName = GetConfigValue("BBScoreExtractName", "/BBScoreReports/BBScoreExtract");
            List<ReportParameter> reportParms = GetReportParmList("CompanyID", iCompanyID.ToString());
            reportParms.Add(new ReportParameter("ReportDate", dtReportDate.ToString()));
            return GenerateReport(szReportName, reportParms, "csv");
        }



        /// <summary>
        /// Generates the BBScore export CSV file.
        /// </summary>
        /// <param name="iCompanyID"></param>
        /// <param name="dtReportDate"></param>
        /// <returns></returns>
        public Byte[] GenerateBBScoreExcel(int iCompanyID, DateTime dtReportDate)
        {
            string szReportName = GetConfigValue("BBScoreExtractName", "/BBScoreReports/BBScore Excel");
            List<ReportParameter> reportParms = GetReportParmList("CompanyID", iCompanyID.ToString());
            reportParms.Add(new ReportParameter("ReportDate", dtReportDate.ToString()));
            return GenerateReport(szReportName, reportParms, "EXCELOPENXML");
        }

        /// <summary>
        /// Generates the AUSSettings report with the specified parameters.
        /// </summary>
        /// <param name="iPersonID"></param>
        /// <param name="iCompanyID"></param>
        /// <returns></returns>
        public Byte[] GenerateAUSSettingsReport(int iPersonID, int iCompanyID) {
            string szReportName = GetConfigValue("AUSSettingsReportName", "/AUSReports/AUSSettings");
            List<ReportParameter> reportParms = GetReportParmList("PersonID", iPersonID.ToString());
            reportParms.Add(new ReportParameter("CompanyID", iCompanyID.ToString()));
            return GenerateReport(szReportName, reportParms);
        }


        /// <summary>
        /// Generates the AUS report with the specified parameters.
        /// </summary>
        /// <param name="iPersonID"></param>
        /// <param name="iCompanyID"></param>
        /// <param name="dtStartDate"></param>
        /// <param name="dtEndDate"></param>
        /// <returns></returns>
        public Byte[] GenerateAUSReport(int iPersonID, int iCompanyID, DateTime dtStartDate, DateTime dtEndDate) {
               return GenerateAUSReport(iPersonID, iCompanyID, dtStartDate, dtEndDate, -1);
        }

        /// <summary>
        /// Generates the AUS report with the specified parameters.
        /// </summary>
        /// <param name="iPersonID"></param>
        /// <param name="iCompanyID"></param>
        /// <param name="dtStartDate"></param>
        /// <param name="dtEndDate"></param>
        /// <param name="iMonitoredCompanyID"></param>
        /// <returns></returns>
        public Byte[] GenerateAUSReport(int iPersonID, int iCompanyID, DateTime dtStartDate, DateTime dtEndDate, int iMonitoredCompanyID) {
            string szReportName = GetConfigValue("AUSReportName", "/AUSReports/AUS");

            List<ReportParameter> reportParms = GetReportParmList("PersonID", iPersonID.ToString());
            reportParms.Add(new ReportParameter("CompanyID", iCompanyID.ToString()));
            reportParms.Add(new ReportParameter("StartDate", dtStartDate.ToString()));
            reportParms.Add(new ReportParameter("EndDate", dtEndDate.ToString()));
            reportParms.Add(new ReportParameter("MonitoredCompanyID", iMonitoredCompanyID.ToString()));

            // If a negative Monitored Company value is 
            // specified, treat is as NULL.
            if (iMonitoredCompanyID < 0) {
                reportParms[4].Value = null;
            }

            return GenerateReport(szReportName, reportParms);
        }

        /// <summary>
        /// ALWAYS ALLOW THIS DEFINITION TO BE FIRST AS IT IS CALLED FROM ASP
        ///   -- it seems that the first defnition is the prototype that is available when
        ///   -- invoked from a standard asp page
        /// Generates the Business Report for the specified BBID 
        /// returning a byte array representation of a PDF.
        /// </summary>
        /// <param name="szBBID"></param>
        /// <param name="iReportLevel"></param>
        /// <param name="bIncludeBalanceSheet"></param>
        /// <param name="bIncludeSurvey"></param>
        /// <param name="iRequestingCompanyID"></param>
        /// <returns></returns>
        public Byte[] GenerateBusinessReport(string szBBID, int iReportLevel, bool bIncludeBalanceSheet, bool bIncludeSurvey, int iRequestingCompanyID)
        {
            return GenerateBusinessReport(szBBID, iReportLevel, bIncludeBalanceSheet, bIncludeSurvey, 0, false, iRequestingCompanyID, false);
        }

        public Byte[] GenerateBusinessReport(string szBBID, int iReportLevel, bool bIncludeBalanceSheet, bool bIncludeSurvey, int iRequestID, bool bIncludeEquifaxData, int iRequestingCompanyID)
        {
            return GenerateBusinessReport(szBBID, iReportLevel, bIncludeBalanceSheet, bIncludeSurvey, iRequestID, bIncludeEquifaxData, iRequestingCompanyID, false);
        }

        public Byte[] GenerateBusinessReport(string szBBID, int iReportLevel, bool bIncludeBalanceSheet, bool bIncludeSurvey, int iRequestID, bool bIncludeEquifaxData, int iRequestingCompanyID, bool bIncludeBackgroundCheckData)
        {
            string szReportName = GetConfigValue("BusinessReportName", "/BusinessReport/BusinessReport");
            List<ReportParameter> reportParms = GetReportParmList("CompanyID", szBBID);
            reportParms.Add(new ReportParameter("ReportLevel", iReportLevel.ToString()));
            reportParms.Add(new ReportParameter("IncludeBalanceSheet", bIncludeBalanceSheet.ToString()));
            reportParms.Add(new ReportParameter("IncludeSurvey", bIncludeSurvey.ToString()));
            reportParms.Add(new ReportParameter("RequestID", iRequestID.ToString()));
            reportParms.Add(new ReportParameter("IncludeEquifaxData", bIncludeEquifaxData.ToString()));
            reportParms.Add(new ReportParameter("RequestingCompanyID", iRequestingCompanyID.ToString()));
            reportParms.Add(new ReportParameter("IncludeBackgroundCheckData", bIncludeBackgroundCheckData.ToString()));

            return GenerateReport(szReportName, reportParms);
        }

        /// <summary>
        /// Generates the Business Report for the specified BBID 
        /// returning a byte array representation of a PDF.
        /// </summary>
        /// <param name="szBBID"></param>
        /// <returns></returns>
        public Byte[] GenerateBusinessReport(string szBBID) {
            return GenerateBusinessReport(szBBID, 3, false, false, 0);
		}

		public Byte[] GenerateBusinessReport(string szBBID, int iReportLevel) {
            return GenerateBusinessReport(szBBID, iReportLevel, false, false, 0);
		}

		public Byte[] GenerateBusinessReport(string szBBID, bool bIncludeBalanceSheet, bool bIncludeSurvey) {
			return GenerateBusinessReport(szBBID, 3, bIncludeBalanceSheet, bIncludeSurvey, 0);
		}

        /// <summary>
        /// Generates the Company Listing Report for the specified BBID 
        /// returning a byte array representation of a PDF.
        /// </summary>
        /// <param name="szBBID"></param>
        /// <returns></returns>
        public Byte[] GenerateCompanyListingReport(string szBBID) {
            return GenerateCompanyListingReport(szBBID, false, false);
        }

        /// <summary>
        /// Generates the Company Listing Report for the specified BBID 
        /// returning a byte array representation of a PDF.
        /// </summary>
        /// <param name="szBBID"></param>
        /// <param name="bIncludeBranches"></param>
        /// <param name="bIncludeAffiliations"></param>
        /// <returns></returns>
        public Byte[] GenerateCompanyListingReport(string szBBID, bool bIncludeBranches, bool bIncludeAffiliations) 
        {
            string szReportName = GetConfigValue("ListingReportName", "/BBSReporting/CompanyListing");
            List<ReportParameter> reportParms = GetReportParmList("CompanyID", szBBID);
            reportParms.Add(new ReportParameter("IncludeBranches", bIncludeBranches.ToString()));
            reportParms.Add(new ReportParameter("IncludeAffiliations", bIncludeAffiliations.ToString()));
            return GenerateReport(szReportName, reportParms);
        }

        /// <summary>
        /// Generates the Company Listing Report for the specified BBID 
        /// returning a byte array representation of a PDF.
        /// this is for the shortened version that is used for ITA users
        /// and was previously called non-member listing
        /// </summary>
        /// <param name="szBBID"></param>
        /// <returns></returns>
        public Byte[] GenerateCompanyListingReport_Basic(string szBBID)
        {
            string szReportName = GetConfigValue("ListingReportName", "/BBSReporting/CompanyListing_Basic");
            List<ReportParameter> reportParms = GetReportParmList("CompanyID", szBBID);
            return GenerateReport(szReportName, reportParms);
        }

        /// <summary>
        /// Generates the Company Commodity Report for the specified BBID 
        /// returning a byte array representation of a PDF.
        /// </summary>
        /// <param name="szBBID"></param>
        /// <param name="szCulture"></param>
        /// <returns></returns>
        public Byte[] GenerateCompanyCommodityReport(string szBBID, string szCulture="en-us")
        {
            string szReportName = GetConfigValue("CompanyCommodityReportName", "/BBSReporting/CompanyCommodity");
            List<ReportParameter> reportParms = GetReportParmList("prcca_CompanyID", szBBID);
            reportParms.Add(new ReportParameter("Culture", szCulture));
            return GenerateReport(szReportName, reportParms);
        }

        #region Member Reports
        /// <summary>
        /// This method is used to download the CompanyAnalysis.rdl from the report server.  The report 
        /// requires the following parameters: 
        /// - CompanyIDs (string)
        /// - Culture (string)
        /// - HeaderText (string)
        /// - ConfidenceThreshold (int)
        /// </summary>
        /// <param name="szCompanyIDs"></param>
        /// <param name="szHeaderText"></param>
        /// <param name="szCulture"></param>
        /// <param name="iConfidenceThreshold"></param>
        /// <param name="szReportSortOption"></param>
        /// <returns></returns>
        public Byte[] GenerateCompanyAnalysisReport(string szCompanyIDs, string szHeaderText, string szCulture, int iConfidenceThreshold, string szReportSortOption) 
        {
            if (string.IsNullOrEmpty(szHeaderText)) {
                szHeaderText = " ";
            }

            if (string.IsNullOrEmpty(szReportSortOption))
            {
                szReportSortOption = "";
            }

            string szReportName = GetConfigValue("CompanyAnalysisReport", "/BBOSMemberReports/CompanyAnalysis");

            List<ReportParameter> reportParms = GetReportParmList("CompanyIDs", szCompanyIDs);
            reportParms.Add(new ReportParameter("HeaderText", szHeaderText));
            reportParms.Add(new ReportParameter("Culture", szCulture));
            reportParms.Add(new ReportParameter("ConfidenceThreshold", iConfidenceThreshold.ToString()));
            reportParms.Add(new ReportParameter("ReportSortOption", szReportSortOption));

            return GenerateReport(szReportName, reportParms);
        }

        /// <summary>
        /// This method is used to download the CompanyAnalysisExport.rdl from the report server.  The report 
        /// requires the following parameters: 
        /// - CompanyIDs (string)
        /// - Culture (string)
        /// - ConfidenceThreshold (int)
        /// </summary>
        /// <param name="szCompanyIDs"></param>
        /// <param name="szCulture"></param>
        /// <param name="iConfidenceThreshold"></param>
        /// <param name="iUserCompanyID"></param>
        /// <returns></returns>
        public Byte[] GenerateCompanyAnalysisExport(string szCompanyIDs, string szCulture, int iConfidenceThreshold, int iUserCompanyID) 
        {
            string szReportName = GetConfigValue("CompanyAnalysisExport", "/BBOSMemberReports/CompanyAnalysisExport");

            List<ReportParameter> reportParms = GetReportParmList("CompanyIDs", szCompanyIDs);
            reportParms.Add(new ReportParameter("Culture", szCulture));
            reportParms.Add(new ReportParameter("ConfidenceThreshold", iConfidenceThreshold.ToString()));
            reportParms.Add(new ReportParameter("UserCompanyID", iUserCompanyID.ToString()));

            return GenerateReport(szReportName, reportParms, "csv");
        }

        /// <summary>
        /// This method is used to download the MPRFullBlueBookListingReport.rdl from the report server.  The report 
        /// requires the following parameters: 
        /// - CompanyIDs (string)
        /// - Culture (string)
        /// - HeaderText (string)
        /// </summary>
        /// <param name="szCompanyIDs"></param>
        /// <param name="szHeaderText"></param>
        /// <param name="szCulture"></param>
        /// <param name="szReportSortOption"></param>
        /// <returns></returns>
        public Byte[] GenerateMPRFullBlueBookListingReport(string szCompanyIDs, string szHeaderText, string szCulture, string szReportSortOption) {
            if (string.IsNullOrEmpty(szHeaderText)) {
                szHeaderText = " ";
            }

            if (string.IsNullOrEmpty(szReportSortOption))
            {
                szReportSortOption = "";
            }

            string szReportName = GetConfigValue("MPRFullBlueBookListingReport", "/BBOSMemberReports/MPRFullBlueBookListingReport");

            List<ReportParameter> reportParms = GetReportParmList("CompanyIDs", szCompanyIDs);
            reportParms.Add(new ReportParameter("HeaderText", szHeaderText));
            reportParms.Add(new ReportParameter("Culture", szCulture));
            reportParms.Add(new ReportParameter("ReportSortOption", szReportSortOption));

            return GenerateReport(szReportName, reportParms);
        }

        /// <summary>
        /// This method is used to download the MPRNotesReport.rdl from the report server.  The report requires the
        /// following parameters:
        /// - NoteIDs (string)
        /// - CompanyID (int)
        /// - PersonID (int)
        /// - Culture (string)
        /// - HeaderText (string)
        /// - WebUserID (int)
        /// - HQID (int)
        /// </summary>
        /// <param name="iCompanyID"></param>
        /// <param name="szNoteIDs"></param>
        /// <param name="iPersonID"></param>
        /// <param name="iWebUserID"></param>
        /// <param name="iHQID"></param>
        /// <param name="szHeaderText"></param>
        /// <param name="szCulture"></param>
        /// <param name="szReportSortOption"></param>
        /// <returns></returns>
        public Byte[] GenerateMPRNotesReport(int iCompanyID, 
                                             string szNoteIDs,  
                                             int iPersonID,
                                             int iWebUserID,
                                             int iHQID,
                                             string szHeaderText, 
                                             string szCulture,
                                             string szReportSortOption) {
            if (string.IsNullOrEmpty(szHeaderText)) {
                szHeaderText = " "; 
            }

            if (string.IsNullOrEmpty(szReportSortOption))
            {
                szReportSortOption = "";
            }

            string szReportName = GetConfigValue("MPRNotesReport", "/BBOSMemberReports/MPRNotesReport");

            List<ReportParameter> reportParms = GetReportParmList("CompanyID", iCompanyID.ToString());
            reportParms.Add(new ReportParameter("NoteIDs", szNoteIDs));
            reportParms.Add(new ReportParameter("PersonID", iPersonID.ToString()));
            reportParms.Add(new ReportParameter("WebUserID", iWebUserID.ToString()));
            reportParms.Add(new ReportParameter("HQID", iHQID.ToString()));
            reportParms.Add(new ReportParameter("HeaderText", szHeaderText));
            reportParms.Add(new ReportParameter("Culture", szCulture));
            reportParms.Add(new ReportParameter("ReportSortOption", szReportSortOption));

            return GenerateReport(szReportName, reportParms);
        }

        /// <summary>
        /// This method is used to download the MPRQuickReport.rdl from the report server.  The report requires
        /// the following parameters: 
        /// - CompanyIDs (string)
        /// - Culture (string)
        /// - IncludeHeadExecutive (bool)
        /// - HeaderText (string)
        /// - Level (int)
        /// </summary>
        /// <param name="szCompanyIDs"></param>
        /// <param name="bIncludeHeadExecutive"></param>
        /// <param name="szHeaderText"></param>
        /// <param name="szCulture"></param>
        /// <param name="iLevel"></param>
        /// <param name="szReportSortOption"></param>
        /// <returns></returns>
        public Byte[] GenerateMPRQuickListReport(string szCompanyIDs, bool bIncludeHeadExecutive, string szHeaderText, string szCulture, int iLevel, string szReportSortOption) {
            if (string.IsNullOrEmpty(szHeaderText)) {
                szHeaderText = " ";
            }

            if (string.IsNullOrEmpty(szReportSortOption))
            {
                szReportSortOption = "";
            }

            string szReportName = GetConfigValue("MPRQuickReport", "/BBOSMemberReports/MPRQuickReport");
            List<ReportParameter> reportParms = GetReportParmList("CompanyIDs", szCompanyIDs);
            reportParms.Add(new ReportParameter("HeaderText", szHeaderText));
            reportParms.Add(new ReportParameter("Culture", szCulture));
            reportParms.Add(new ReportParameter("IncludeHeadExecutive", bIncludeHeadExecutive.ToString()));
            reportParms.Add(new ReportParameter("Level", iLevel.ToString()));
            reportParms.Add(new ReportParameter("ReportSortOption", szReportSortOption));

            return GenerateReport(szReportName, reportParms);
        }

        /// <summary>
        /// This method is used to download the GeneratePersonnelReport.rdl from the report server.  The report requires
        /// the following parameters: 
        /// - PersonIDs (string)
        /// - HeaderText (string)
        /// </summary>
        /// <param name="szPersonIDs"></param>
        /// <param name="szHeaderText"></param>
        /// <returns></returns>
        public Byte[] GeneratePersonnelReport(string szPersonIDs, string szHeaderText)
        {
            if (string.IsNullOrEmpty(szHeaderText))
            {
                szHeaderText = " ";
            }

            string szReportName = GetConfigValue("PersonnelReport", "/BBOSMemberReports/Personnel Report");
            List<ReportParameter> reportParms = GetReportParmList("PersonIDs", szPersonIDs);
            reportParms.Add(new ReportParameter("HeaderText", szHeaderText));

            return GenerateReport(szReportName, reportParms);
        }

        /// <summary>
        /// This method is used to download the MPRQuickReportLumber.rdl from the report server.  The report requires
        /// the following parameters: 
        /// - CompanyIDs (string)
        /// - Culture (string)
        /// - IncludeHeadExecutive (bool)
        /// - HeaderText (string)
        /// - Level (int)
        /// </summary>
        /// <param name="szCompanyIDs"></param>
        /// <param name="bIncludeHeadExecutive"></param>
        /// <param name="szHeaderText"></param>
        /// <param name="szCulture"></param>
        /// <param name="iLevel"></param>
        /// <param name="szReportSortOption"></param>
        /// <returns></returns>
        public Byte[] GenerateMPRQuickListReportLumber(string szCompanyIDs, bool bIncludeHeadExecutive, string szHeaderText, string szCulture, int iLevel, string szReportSortOption)
        {
            if (string.IsNullOrEmpty(szHeaderText))
            {
                szHeaderText = " ";
            }

            if (string.IsNullOrEmpty(szReportSortOption))
            {
                szReportSortOption = "";
            }

            string szReportName = GetConfigValue("MPRQuickReportLumber", "/BBOSMemberReports/MPRQuickReportLumber");
            List<ReportParameter> reportParms = GetReportParmList("CompanyIDs", szCompanyIDs);
            reportParms.Add(new ReportParameter("HeaderText", szHeaderText));
            reportParms.Add(new ReportParameter("Culture", szCulture));
            reportParms.Add(new ReportParameter("IncludeHeadExecutive", bIncludeHeadExecutive.ToString()));
            reportParms.Add(new ReportParameter("Level", iLevel.ToString()));
            reportParms.Add(new ReportParameter("ReportSortOption", szReportSortOption));

            return GenerateReport(szReportName, reportParms);
        }

        /// <summary>
        /// This method is used to download the AdCampaignSummary.rdl from the report server.  The report requires
        /// the following parameters: 
        /// - Culture (string)
        /// - AdvertisingCampaignID (int)
        /// </summary>
        /// <param name="szCulture"></param>
        /// <param name="iAdCampaignID"></param>
        /// <returns></returns>
        public Byte[] GenerateAdCampaignReport(string szCulture, int iAdCampaignID)
        {
            string szReportName = GetConfigValue("AdCampaignSummary", "/BBOSMemberReports/AdCampaignSummary");
            List<ReportParameter> reportParms = GetReportParmList("Culture", szCulture);
            reportParms.Add(new ReportParameter("AdvertisingCampaignID", iAdCampaignID.ToString()));

            return GenerateReport(szReportName, reportParms);
        }

        /// <summary>
        /// This method is used to download the BankruptcyReport.rdl from the report server.  The report requires
        /// the following parameters:
        /// - Culture (string)
        /// - FromDate (datetime)
        /// - ToDate (datetime)
        /// - HeaderText (string)
        /// </summary>
        /// <param name="szCulture"></param>
        /// <param name="dtFromDate"></param>
        /// <param name="dtToDate"></param>
        /// <param name="szHeaderText"></param>
        /// <param name="szIndustryType">Produce (default) or Lumber</param>
        /// <returns></returns>
        public Byte[] GenerateBankruptcyReport(string szCulture, DateTime dtFromDate, DateTime dtToDate, string szHeaderText, string szIndustryType = "Produce")
        {
            if (string.IsNullOrEmpty(szHeaderText))
            {
                szHeaderText = " ";
            }

            string szReportName = GetConfigValue("BankruptcyReport", "/BBOSMemberReports/BankruptcyReport");
            List<ReportParameter> reportParms = GetReportParmList("Culture", szCulture);
            reportParms.Add(new ReportParameter("FromDate", dtFromDate.ToString()));
            reportParms.Add(new ReportParameter("ToDate", dtToDate.ToString()));
            reportParms.Add(new ReportParameter("HeaderText", szHeaderText));
            reportParms.Add(new ReportParameter("IndustryType", szIndustryType));

            return GenerateReport(szReportName, reportParms);
        }

        /// <summary>
        /// This method is used to download the PACADRCViolators.rdl from the report server.  The report requires
        /// the following parameters:
        /// - FromDate (datetime)
        /// - ToDate (datetime)
        /// - HeaderText (string)
        /// </summary>
        /// <param name="dtFromDate"></param>
        /// <param name="dtToDate"></param>
        /// <param name="szHeaderText"></param>
        /// <returns></returns>
        public Byte[] GeneratePACADRCViolatorsReport(DateTime dtFromDate, DateTime dtToDate, string szHeaderText)
        {
            if (string.IsNullOrEmpty(szHeaderText))
            {
                szHeaderText = " ";
            }

            string szReportName = GetConfigValue("PACADRCViolatorsReport", "/BBOSMemberReports/PACADRCViolators");
            List<ReportParameter> reportParms = GetReportParmList("FromDate", dtFromDate.ToString());
            reportParms.Add(new ReportParameter("ToDate", dtToDate.ToString()));
            reportParms.Add(new ReportParameter("HeaderText", szHeaderText));

            return GenerateReport(szReportName, reportParms);
        }

        /// <summary>
        /// This method is used to download the CompanyContactExport[CSV,MSO].rdl from the report server.  The report 
        /// requires the following parameters:
        /// - CompanyIDs (string)
        /// NOTE: ExportType will be used to determine which version of the report to pull due to CSV export issues.
        /// </summary>
        /// <param name="szCompanyIDs"></param>
        /// <param name="szExportType"></param>
        /// <param name="iUserCompanyID"></param>
        /// <returns></returns>
        public Byte[] GenerateCompanyContactExport(string szCompanyIDs, string szExportType, int iUserCompanyID)
        {
            string szReportName = GetConfigValue("CompanyContactExport", "/BBOSMemberReports/CompanyContactExport");
            // Append export type to file name
            szReportName += szExportType;

            List<ReportParameter> reportParms = GetReportParmList("CompanyIDs", szCompanyIDs);
            reportParms.Add(new ReportParameter("UserCompanyID", iUserCompanyID.ToString()));

            return GenerateReport(szReportName, reportParms, "csv");
        }

        /// <summary>
        /// This method is used to download the CompanyDataExport[Level1,Level2].rdl from the report server.  The
        /// report requires the following parameters:
        /// - CompanyIDs (string)
        /// NOTE: Level will be used to determine which version of the report to pull due to CSV export issues.
        /// </summary>
        /// <param name="szCompanyIDs"></param>
        /// <param name="iLevel"></param>
        /// <param name="iUserCompanyID"></param>
        /// <returns></returns>
        public Byte[] GenerateCompanyDataExport(string szCompanyIDs, int iLevel, int iUserCompanyID)
        {
            string szReportName = GetConfigValue("CompanyDataExport", "/BBOSMemberReports/CompanyDataExport");
            // Append level to file name
            szReportName += "Level" + iLevel.ToString();

            List<ReportParameter> reportParms = GetReportParmList("CompanyIDs", szCompanyIDs);
            reportParms.Add(new ReportParameter("UserCompanyID", iUserCompanyID.ToString()));

            return GenerateReport(szReportName, reportParms, "csv");
        }

        public Byte[] GenerateCompanyDataExportLumber(string szCompanyIDs, bool bBBScoreVisible)
        {
            string szReportName = GetConfigValue("CompanyDataExportLumber", "/BBOSMemberReports/CompanyDataExportLumber");
            List<ReportParameter> reportParms = GetReportParmList("CompanyIDs", szCompanyIDs);
            reportParms.Add(new ReportParameter("BBScoreVisible", bBBScoreVisible.ToString()));

            return GenerateReport(szReportName, reportParms, "csv");
        }

        /// <summary>
        /// This method is used to download the ContactExport[CSV,MSO].rdl from the report server.  The 
        /// report requires the following parameters:
        /// - CompanyIDs (string)
        /// - ContactType (string) [All,Head]
        /// NOTE: Export type will be used to determine which version of the report to pull due to CSV export issues.
        /// </summary>
        /// <param name="szCompanyIDs"></param>
        /// <param name="szContactType"></param>
        /// <param name="szExportType"></param>
        /// <param name="iUserCompanyID"></param>
        /// <returns></returns>
        public Byte[] GenerateContactExport(string szCompanyIDs, string szContactType, string szExportType, int iUserCompanyID)
        {
            string szReportName = GetConfigValue("ContactExport", "/BBOSMemberReports/ContactExport");
            // Append level to file name
            szReportName += szExportType;

            List<ReportParameter> reportParms = GetReportParmList("CompanyIDs", szCompanyIDs);
            reportParms.Add(new ReportParameter("ContactType", szContactType));
            reportParms.Add(new ReportParameter("UserCompanyID", iUserCompanyID.ToString()));

            return GenerateReport(szReportName, reportParms, "csv");
        }

        public Byte[] GenerateContactExportLumber(string szCompanyIDs, string szContactType, string szExportType, int iUserCompanyID)
        {
            string szReportName = GetConfigValue("ContactExport", "/BBOSMemberReports/ContactExportLumber");
            // Append level to file name
            szReportName += szExportType;

            List<ReportParameter> reportParms = GetReportParmList("CompanyIDs", szCompanyIDs);
            reportParms.Add(new ReportParameter("ContactType", szContactType));
            reportParms.Add(new ReportParameter("UserCompanyID", iUserCompanyID.ToString()));

            return GenerateReport(szReportName, reportParms, "csv");
        }

        /// <summary>
        /// This method is used to download the CreditSheetList.rdl from the report server.  The report requires the
        /// following parameters:
        /// - CompanyID (int)
        /// - FromDate (datetime)
        /// - ToDate (datetime)
        /// - KeyChangesOnly (bool)
        /// - IncludeListing (bool)
        /// </summary>
        /// <param name="iCompanyID"></param>
        /// <param name="szFromDate"></param>
        /// <param name="szToDate"></param>
        /// <param name="bKeyChangesOnly"></param>
        /// <param name="bIncludeListing"></param>
        /// <returns></returns>
        public Byte[] GenerateCompanyUpdateListReport(int iCompanyID, string szFromDate, string szToDate,
            bool bKeyChangesOnly, bool bIncludeListing)
        {
            string szReportName = GetConfigValue("CompanyUpdateListReport", "/BBOSMemberReports/CreditSheetList");

            List<ReportParameter> reportParms = GetReportParmList("CompanyID", iCompanyID.ToString());
            reportParms.Add(new ReportParameter("FromDate", szFromDate));
            reportParms.Add(new ReportParameter("ToDate", szToDate));
            reportParms.Add(new ReportParameter("KeyChangesOnly", bKeyChangesOnly.ToString()));
            reportParms.Add(new ReportParameter("IncludeListing", bIncludeListing.ToString()));

            return GenerateReport(szReportName, reportParms);
        }

        /// <summary>
        /// This method is used to download the CreditSheetExport.rdl from the report server.  
        /// </summary>
        /// <param name="szCreditSheetIDs"></param>
        /// <returns></returns>
        public Byte[] GenerateCreditSheetExport(string szCreditSheetIDs)
        {
            string szReportName = GetConfigValue("CreditSheetExport", "/BBOSMemberReports/CreditSheetExport");
            List<ReportParameter> reportParms = GetReportParmList("CreditSheetIDs", szCreditSheetIDs);
            return GenerateReport(szReportName, reportParms, "csv");
        }

        /// <summary>
        /// This method is used to download the CreditSheetReport.rdl from the report server.  
        /// </summary>
        /// <param name="szCreditSheetIDs"></param>
        /// <returns></returns>
        public Byte[] GenerateCreditSheetReport(string szCreditSheetIDs)
        {
            string szReportName = GetConfigValue("CreditSheetReport", "/BBOSMemberReports/CreditSheetReport");
            List<ReportParameter> reportParms = GetReportParmList("CreditSheetIDs", szCreditSheetIDs);
            return GenerateReport(szReportName, reportParms);
        }

        /// <summary>
        /// This method is used to download the MailingLabels.rdl from the report server.  The report requires the
        /// following parameters:
        /// </summary>
        /// <param name="szCompanyIDs"></param>
        /// <param name="iLabelsPerPage"></param>
        /// <param name="bIncludeHeadExecutive"></param>
        /// <param name="szCustomAttnLine"></param>
        /// <param name="bIncludeCountry"></param>
        /// <returns></returns>
        public Byte[] GenerateMailingLabelsReport(string szCompanyIDs, int iLabelsPerPage,
                                                  bool bIncludeHeadExecutive, string szCustomAttnLine, bool bIncludeCountry)
        {

            // We no longer call the master Mailing Labels Report because the different mailing label versions
            // have different margins, which thows off the column breaks.  Just call the sub-reports directly.
            string szReportName = null;
            switch (iLabelsPerPage)
            {
                case 6:
                    szReportName = GetConfigValue("MailingLabelsReport06PerPage", "/BBOSMemberReports/MailingLabels06PerPage");
                    break;
                case 10:
                    szReportName = GetConfigValue("MailingLabelsReport10PerPage", "/BBOSMemberReports/MailingLabels10PerPage");
                    break;
                case 20:
                    szReportName = GetConfigValue("MailingLabelsReport20PerPage", "/BBOSMemberReports/MailingLabels20PerPage");
                    break;
                case 30:
                    szReportName = GetConfigValue("MailingLabelsReport30PerPage", "/BBOSMemberReports/MailingLabels30PerPage");
                    break;

            }

            List<ReportParameter> reportParms = GetReportParmList("CompanyIDs", szCompanyIDs);
            reportParms.Add(new ReportParameter("IncludeHeadExecutive", bIncludeHeadExecutive.ToString()));
            reportParms.Add(new ReportParameter("CustomAttentionLine", szCustomAttnLine));
            reportParms.Add(new ReportParameter("IncludeCountry", bIncludeCountry.ToString()));

            return GenerateReport(szReportName, reportParms);
        }

        /// <summary>
        /// This method is used to download the MarketingList.rdl from the report server.  The report requires the
        /// following parameters:
        /// - CompanyIDs (string)
        /// - Level (int)
        /// </summary>
        /// <param name="szCompanyIDs"></param>
        /// <param name="iLevel"></param>
        /// <returns></returns>
        public Byte[] GenerateMarketingListReport(string szCompanyIDs, int iLevel)
        {
            string szReportName = null;
            
            if (iLevel == 1) {
                szReportName = GetConfigValue("MarketingListLevel1Report", "/BBOSMemberReports/MarketingListLevel1");
            } else {
                szReportName = GetConfigValue("MarketingListLevel2Report", "/BBOSMemberReports/MarketingListLevel2");
            }

            List<ReportParameter> reportParms = GetReportParmList("CompanyIDs", szCompanyIDs);
            return GenerateReport(szReportName, reportParms);
        }

        /// <summary>
        /// This method is used to download the MarketingListExport[Level1,Level2].rdl from the report server.  The
        /// report requires the following parameters:
        /// - CompanyIDs (string)
        /// NOTE: Level will be used to determine which version of the report to pull due to CSV export issues.
        /// </summary>
        /// <param name="szCompanyIDs"></param>
        /// <param name="iLevel"></param>
        /// <returns></returns>
        public Byte[] GenerateMarketingListExportReport(string szCompanyIDs, int iLevel)
        {
            string szReportName = GetConfigValue("MarketingListExport", "/BBOSMemberReports/MarketingListExport");
            // Append level to file name
            szReportName += "Level" + iLevel.ToString();

            List<ReportParameter> reportParms = GetReportParmList("CompanyIDs", szCompanyIDs);
            return GenerateReport(szReportName, reportParms, "csv");
        }

        /// <summary>
        /// This method is used to download the RatingComparisonReport.rdl from the report server.  The report requires
        /// the following parameters: 
        /// - CompanyIDs (string)
        /// - Culture (string)
        /// - HeaderText (string)
        /// </summary>
        /// <param name="szCompanyIDs"></param>
        /// <param name="szCulture"></param>
        /// <param name="szHeaderText"></param>
        /// <param name="szReportSortOption"></param>
        /// <returns></returns>
        public Byte[] GenerateRatingComparisonReport(string szCompanyIDs, string szCulture, string szHeaderText, string szReportSortOption)
        {
            if (string.IsNullOrEmpty(szHeaderText))
            {
                szHeaderText = " ";
            }

            if (string.IsNullOrEmpty(szReportSortOption))
            {
                szReportSortOption = "";
            }

            string szReportName = GetConfigValue("RatingComparisonReport", "/BBOSMemberReports/RatingComparisonReport");
            List<ReportParameter> reportParms = GetReportParmList("CompanyIDs", szCompanyIDs);
            reportParms.Add(new ReportParameter("HeaderText", szHeaderText));
            reportParms.Add(new ReportParameter("Culture", szCulture));
            reportParms.Add(new ReportParameter("ReportSortOption", szReportSortOption));

            return GenerateReport(szReportName, reportParms);
        }

        /// <summary>
        /// This method is used to download the BBOSBBScore.rdl from the report server.  The report requires the 
        /// following parameters:
        /// - CompanyID of the current user(int) 
        /// - HeaderText (string)
        /// - CompanyIDList
        /// </summary>
        /// <param name="iCompanyID"></param>
        /// <param name="szHeaderText"></param>
        /// <param name="szCompanyIDList"></param>
        /// <param name="iConfidenceThreshold"></param>
        /// <returns></returns>
        public Byte[] GenerateBlueBookScoreReport(int iCompanyID, string szHeaderText, string szCompanyIDList, int iConfidenceThreshold)
        {
            if (string.IsNullOrEmpty(szHeaderText))
            {
                szHeaderText = " ";
            }

            string szReportName = GetConfigValue("BBScoreReport", "/BBScoreReports/BBOSBBScore");
            List<ReportParameter> reportParms = GetReportParmList("CompanyID", iCompanyID.ToString());
            reportParms.Add(new ReportParameter("HeaderText", szHeaderText));
            reportParms.Add(new ReportParameter("CompanyIDList", szCompanyIDList));
            reportParms.Add(new ReportParameter("ConfidenceThreshold", iConfidenceThreshold.ToString()));

            return GenerateReport(szReportName, reportParms);            
        }

        /// <summary>
        /// This method is used to download the BBOSBBScore_Lumber.rdl from the report server.  The report requires the 
        /// following parameters:
        /// - CompanyID of the current user(int) 
        /// - HeaderText (string)
        /// - CompanyIDList
        /// </summary>
        /// <param name="iCompanyID"></param>
        /// <param name="szHeaderText"></param>
        /// <param name="szCompanyIDList"></param>
        /// <param name="iConfidenceThreshold"></param>
        /// <returns></returns>
        public Byte[] GenerateBlueBookScoreReport_Lumber(int iCompanyID, string szHeaderText, string szCompanyIDList, int iConfidenceThreshold)
        {
            if (string.IsNullOrEmpty(szHeaderText))
            {
                szHeaderText = " ";
            }

            string szReportName = GetConfigValue("BBScoreReport", "/BBScoreReports/BBOSBBScore_Lumber");
            List<ReportParameter> reportParms = GetReportParmList("CompanyID", iCompanyID.ToString());
            reportParms.Add(new ReportParameter("HeaderText", szHeaderText));
            reportParms.Add(new ReportParameter("CompanyIDList", szCompanyIDList));
            reportParms.Add(new ReportParameter("ConfidenceThreshold", iConfidenceThreshold.ToString()));

            return GenerateReport(szReportName, reportParms);
        }

        /// <summary>
        /// This method is used to download the DelistedCompany.rdl from the report server.  The report requires
        /// the following parameters: 
        /// - CompanyIDs (string)
        /// - Culture (string)
        /// - WebUserID (int)
        /// - HQID (int)
        /// </summary>
        /// <param name="szCompanyIDs"></param>
        /// <param name="szCulture"></param>
        /// <param name="iWebUserID"></param>
        /// <param name="iHQID"></param>
        /// <returns></returns>
        public Byte[] GenerateDelistedCompanyReport(string szCompanyIDs, string szCulture, int iWebUserID, int iHQID)
        {
            string szReportName = GetConfigValue("DelistedCompanyReport", "/BBOSMemberReports/DelistedCompany");
            List<ReportParameter> reportParms = GetReportParmList("CompanyIDs", szCompanyIDs);
            reportParms.Add(new ReportParameter("Culture", szCulture));
            reportParms.Add(new ReportParameter("WebUserID", iWebUserID.ToString()));
            reportParms.Add(new ReportParameter("HQID", iHQID.ToString()));

            return GenerateReport(szReportName, reportParms);
        }
        #endregion

        public Byte[] GenerateCreditSheetByPeriodReport(DateTime dtReportDate)
        {
            string szReportName = GetConfigValue("CreditSheetReportByPeriod", "/BBOSMemberReports/CreditSheetReportByPeriod");
            List<ReportParameter> reportParms = GetReportParmList("ReportDate", dtReportDate.ToString("yyyy-MM-dd HH:mm:ss.fff"));
            return GenerateReport(szReportName, reportParms);
        }

        public Byte[] GenerateListingReportLetter(int iCompanyID, bool bBRE=false, bool bInsert1=false, bool bInsert2=false)
        {
            string szReportName = GetConfigValue("ListingReportLetter", "/BBOSMemberReports/ListingReportLetter");
            List<ReportParameter> reportParms = GetReportParmList("CompanyID", iCompanyID.ToString());
            reportParms.Add(new ReportParameter("XStartBRE", bBRE ? "1" : "0"));
            reportParms.Add(new ReportParameter("XStartInsert1", bInsert1 ? "1" : "0"));
            reportParms.Add(new ReportParameter("XStartInsert2", bInsert2 ? "1" : "0"));
            return GenerateReport(szReportName, reportParms);
        }

        #region Helper Methods
        /// <summary>
        /// Generates the specified report using the provided parameter names
        /// and parameter values.
        /// </summary>
        /// <param name="szReportName">Fully qualified report name.</param>
        /// <param name="aInputParms">Input Parameters</param>
        /// <returns></returns>
        protected Byte[] GenerateReport(string szReportName, List<ReportParameter> aInputParms)
        {
            return GenerateReport(szReportName, aInputParms, "PDF");
        }

        protected Byte[] GenerateReport(string szReportName)
        {
            return GenerateReport(szReportName, new List<ReportParameter>(), "PDF");
        }

        /// <summary>
        /// Generates the specified report using the provided parameter names
        /// and parameter values.
        /// </summary>
        /// <param name="szReportName">Fully qualified report name.</param>
        /// <param name="aInputParms">Input Parameters</param>
        /// <param name="szFormat"></param>
        /// <returns></returns>
        protected Byte[] GenerateReport(string szReportName, List<ReportParameter> aInputParms, string szFormat)
        {
            DateTime dtStart = DateTime.Now;
            try
            {
                GetReportExecution();
                GetReportService();

                // Go get the defined parameters
                // in order to create our parameters
                // for execution.
                ReportService.ReportParameter[] oDefinedParms = GetParameters(szReportName, aInputParms.ToArray());
                ReportExecution.ParameterValue[] aReportParms = BuildParameters(szReportName, aInputParms.ToArray(), oDefinedParms);

                // Setup our out parameters
                string encoding;
                string mimetype;
                string extension;
                ReportExecution.Warning[] warnings;
                string[] streamids;
                string szHistoryID = null;
                string devInfo = @"<DeviceInfo><Toolbar>False</Toolbar></DeviceInfo>";

                ExecutionInfo execInfo = new ExecutionInfo();
                ExecutionHeader execHeader = new ExecutionHeader();

                _oReportExecution.ExecutionHeaderValue = execHeader;
                execInfo = _oReportExecution.LoadReport(szReportName, szHistoryID);

                _oReportExecution.SetExecutionParameters(aReportParms, "en-us");
                Byte[] result = _oReportExecution.Render(szFormat, devInfo, out extension, out mimetype, out encoding, out warnings, out streamids);

                return result;

            }
            finally
            {
                TimeSpan oTS = DateTime.Now.Subtract(dtStart);
            }
        }

        /// <summary>
        /// Retrieves the parameter definitions for the specified report.  If
        /// any parameters have dependencies, the parameters are requeried using
        /// the appropriate specified parameter values.
        /// </summary>
        /// <param name="szReportName">Fully qualified report name.</param>
        /// <param name="aInputParms">Array of parameter</param>
        /// <returns>Report Parameters with valid defaults</returns>
        protected ReportService.ReportParameter[] GetParameters(string szReportName, ReportInterface.ReportParameter[] aInputParms)
        {
            ReportService.ReportParameter[] oDefinedParms = _oReportService.GetReportParameters(szReportName, null, true, null, null);

            ArrayList alParmDependencies = new ArrayList();
            ArrayList alFoundDependencies = new ArrayList();


            // Spin through the parameters looking for dependencies.
            foreach (ReportService.ReportParameter rpParm in oDefinedParms)
            {

                // Does this parm have a dependency?
                if (rpParm.Dependencies != null)
                {

                    // Spin through them and see if we have any values
                    foreach (string szDependency in rpParm.Dependencies)
                    {

                        // Look at the provided parms and values to see if
                        // we have a match for our dependency
                        foreach (ReportInterface.ReportParameter inputParm in aInputParms)
                        {


                            if (inputParm.Name.ToLower() == szDependency.ToLower())
                            {

                                // Make sure we haven't already created a ParmValue
                                // for this dependency in case another parm shares
                                // this dependency.
                                if (!alFoundDependencies.Contains(szDependency))
                                {
                                    ReportService.ParameterValue oParmValue = new ReportService.ParameterValue();
                                    oParmValue.Name = szDependency;
                                    oParmValue.Value = inputParm.Value;

                                    alParmDependencies.Add(oParmValue);
                                    alFoundDependencies.Add(szDependency);
                                }
                            }
                        } // End for
                    } // End foreach
                }
            } // End foreach

            // If we found dependencies, requery
            // for the parms
            if (alParmDependencies.Count > 0)
            {
                ReportService.ParameterValue[] oParmValues = new ReportService.ParameterValue[alParmDependencies.Count];

                int iIndex = 0;
                foreach (ReportService.ParameterValue oParmValue in alParmDependencies)
                {
                    oParmValues[iIndex] = oParmValue;
                    iIndex++;
                }
                oDefinedParms = _oReportService.GetReportParameters(szReportName, null, true, oParmValues, null);
            }

            return oDefinedParms;
        }


        /// <summary>
        /// Builds the report parameters based on the defined 
        /// parameters.  If a parameter value is provided, we will use it
        /// Otherwise we try to use the default value, if one exists.
        /// </summary>
        /// <param name="szReportName">Fully qualified report name.</param>
        /// <param name="aInputParms">Array of parameter</param>
        /// <param name="oDefinedParms">Defined Parameters from Web Service</param>
        /// <returns>Parameters for rendering report</returns>
        protected ReportExecution.ParameterValue[] BuildParameters(string szReportName, ReportInterface.ReportParameter[] aInputParms, ReportService.ReportParameter[] oDefinedParms)
        {

            ReportExecution.ParameterValue[] aReportParms = null;

            if (oDefinedParms == null)
            {
                return aReportParms;
            }

            List<ReportExecution.ParameterValue> alReportParms = new List<ReportExecution.ParameterValue>();

            foreach (ReportService.ReportParameter rpParm in oDefinedParms)
            {


                ReportExecution.ParameterValue oParameterValue = new ReportExecution.ParameterValue();
                oParameterValue.Name = rpParm.Name;
                alReportParms.Add(oParameterValue);

                // Has the user supplied a report value?
                // Look at the provided parms and values to see if
                // we have a match for our dependency
                bool bProvided = false;
                foreach (ReportInterface.ReportParameter inputParm in aInputParms)
                {

                    if (inputParm.Name.ToLower() == rpParm.Name.ToLower())
                    {

                        // If this is a multi-value parm, we are assuming it
                        // is comma-delimited
                        if (rpParm.MultiValue)
                        {
                            string szMultiValues = inputParm.Value;
                            string[] aszValues = szMultiValues.Split(',');

                            // Use the first element for our current parameter
                            oParameterValue.Value = aszValues[0];

                            // Now spin through the rest of the values creating
                            // parm values with the same name.
                            for (int iMultiIndex = 1; iMultiIndex < aszValues.Length; iMultiIndex++)
                            {
                                ReportExecution.ParameterValue oParameterValueMulti = new ReportExecution.ParameterValue();
                                oParameterValueMulti.Name = rpParm.Name;
                                oParameterValueMulti.Value = aszValues[iMultiIndex];
                                alReportParms.Add(oParameterValueMulti);
                            }

                        }
                        else
                        {
                            oParameterValue.Value = inputParm.Value;
                        }

                        bProvided = true;
                    }
                }

                if (!bProvided)
                {
                    // Does this parameter have a default value?
                    if ((rpParm.DefaultValues != null) &&
                        (rpParm.DefaultValues.Length > 0))
                    {
                        oParameterValue.Value = rpParm.DefaultValues[0];
                    }
                }
            }


            aReportParms = alReportParms.ToArray();
            return aReportParms;
        }

		/// <summary>
		/// Helper method to return the specified configuration value or
		/// a default value if the name is not found.
        /// Note** We are assuming for simplicity that values are in a 
        ///     web.config file at the executable level (or one level 
        ///     higher). All values are in the appSettings node with a
        ///     child node name of "add" and attributes of "key" and "value".
		/// </summary>
		/// <param name="szName"></param>
		/// <param name="szDefault"></param>
		/// <returns></returns>
		protected string GetConfigValue(string szName, string szDefault) {
            string szValue = null;
            
            if (ConfigurationManager.AppSettings.Keys.Count != 0)
            {
                szValue = ConfigurationManager.AppSettings[szName];
            }
            else
            {
                // try finding a web.config in the current directory
                XmlReaderSettings oConfigSettings = new XmlReaderSettings();
                oConfigSettings.ConformanceLevel = ConformanceLevel.Fragment;
                oConfigSettings.IgnoreWhitespace = true;
                oConfigSettings.IgnoreComments = true;

                XmlReader reader = null;
                Assembly oAssembly = Assembly.GetAssembly(this.GetType());
                string sLoadLocation = oAssembly.Location;
                string sLocation = sLoadLocation.Substring(0, sLoadLocation.LastIndexOf("\\"));

                try
                {
                    reader = XmlReader.Create(sLocation + "\\web.config", oConfigSettings);
                }
                catch (FileNotFoundException)
                {
                    //    // assume location issues; try one level higher
                    try
                    {
                        sLocation = sLocation.Substring(0, sLocation.LastIndexOf("\\"));
                        reader = XmlReader.Create(sLocation + "\\web.config", oConfigSettings);
                    }
                    catch (FileNotFoundException)
                    {
                        //now we admit defeat and let the default be used
                    }
                }
                if (reader != null)
                {
                    using (reader)
                    {
                        // position the reader at the appSettings node
                        reader.ReadToFollowing("appSettings");
                        // iterate through the add nodes
                        reader.ReadToFollowing("add");
                        do
                        {
                            if (reader.GetAttribute("key") == szName)
                            {
                                szValue = reader.GetAttribute("value");
                                break;
                            }
                        } while (reader.ReadToNextSibling("add"));
                    }
                }
            }            

			if ((szValue == null) ||
				(szValue.Trim().Length == 0)) {
				szValue = szDefault;
			}

			return szValue;
		}


        protected void GetReportService()
        {
            //string szURL = GetConfigValue("SRSWebServiceRSURL", "http://qa.reports.bluebookservices.local/ReportServer/ReportService2005.asmx");
            string szURL = GetConfigValue("SRSWebServiceRSURL", "http:/10.2.1.99/ReportServer/ReportService2005.asmx");
            string szUserID = GetConfigValue("SRSWebServiceUserID", "rsuser");
            string szPassword = GetConfigValue("SRSWebServicePassword", "rs_1901");
            string szDomain = GetConfigValue("SRSWebServiceDomain", "Enterprise");

            _oReportService = new ReportingService2005();
            _oReportService.Url = szURL;
            _oReportService.Credentials = new NetworkCredential(szUserID, szPassword, szDomain);
            _oReportService.Timeout = Convert.ToInt32(GetConfigValue("ReportInterfaceTimeout", "600000"));

        }

        protected void GetReportExecution()
        {
            string szURL = GetConfigValue("SRSWebServiceREURL", "http://qa.reports.bluebookservices.local/ReportServer/ReportExecution2005.asmx");
            string szUserID = GetConfigValue("SRSWebServiceUserID", "rsuser");
            string szPassword = GetConfigValue("SRSWebServicePassword", "rs_1901");
            string szDomain = GetConfigValue("SRSWebServiceDomain", "Enterprise");

            _oReportExecution = new ReportExecutionService();
            _oReportExecution.Url = szURL;
            _oReportExecution.Credentials = new NetworkCredential(szUserID, szPassword, szDomain);
            _oReportExecution.Timeout = Convert.ToInt32(GetConfigValue("ReportInterfaceTimeout", "600000"));

        }

        public void WriteSettings()
        {
            System.Console.WriteLine(GetConfigValue("SRSWebServiceRSURL", string.Empty));
            System.Console.WriteLine(GetConfigValue("SRSWebServiceREURL", string.Empty));
            System.Console.WriteLine(GetConfigValue("SRSWebServiceDomain", string.Empty));
            System.Console.WriteLine(GetConfigValue("SRSWebServiceUserID", string.Empty));
            System.Console.WriteLine(GetConfigValue("SRSWebServicePassword", string.Empty));
        }

        public string GetSettings()
        {
            String output = string.Empty;
            output += GetConfigValue("SRSWebServiceRSURL", string.Empty) + "<br/>";
            output += GetConfigValue("SRSWebServiceREURL", string.Empty) + "<br/>";
            output += GetConfigValue("SRSWebServiceDomain", string.Empty) + "<br/>";
            output += GetConfigValue("SRSWebServiceUserID", string.Empty) + "<br/>";
            output += GetConfigValue("SRSWebServicePassword", string.Empty) + "<br/>";
            return output;
        }

        protected List<ReportParameter> GetReportParmList(string name, string value)
        {
            List<ReportParameter> reportParms = new List<ReportParameter>();
            reportParms.Add(new ReportParameter(name, value));
            return reportParms;
        }

        protected class ReportParameter
        {
            public string Name;
            public string Value;

            public ReportParameter()
            {
            }

            public ReportParameter(string name, string value)
            {
                Name = name;
                Value = value;
            }

        }
		#endregion
	}
}
