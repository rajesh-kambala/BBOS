/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2008-2015

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: EquifaxUtils
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using System.Net;
using System.Security.Principal;
using System.Xml;
using Microsoft.SqlServer.Server;

/// <summary>
/// This class is intended to be used by SQL Server to retrieve
/// Equifax data.
/// </summary>
public class EquifaxUtils {

    protected const string STATUS_CODE_DATA = "R";
    protected const string STATUS_CODE_NO_DATA = "N";
    protected const string STATUS_CODE_ERROR = "E";

    protected const string XML_RPT_ROOT = "EfxTransmit/CommercialCreditReport/Folder/ReportAttributes/";

   
    protected const string SQL_INSERT_AUDIT =
        "INSERT INTO PREquifaxAuditLog (preqfal_RequestID, preqfal_WebUserID, preqfal_RequestingCompanyID, preqfal_SubjectCompanyID, preqfal_StatusCode, preqfal_HasBankingData, preqfal_HasNonBankingData, preqfal_HasCreditUsageData, preqfal_ActiveBankingTradelineCount, preqfal_InactiveBankingTradelineCount, preqfal_ActiveNonBankingTradelineCount, preqfal_InactiveNonBankingTradelineCount, preqfal_SuccessfulAddressID, preqfal_LookupCount, preqfal_ExceptionMsg, preqfal_CreatedBy, preqfal_CreatedDate, preqfal_UpdatedBy, preqfal_UpdatedDate, preqfal_TimeStamp) " +
        "VALUES (@preqfal_RequestID,@UserID,@preqfal_RequestingCompanyID,@preqfal_SubjectCompanyID,@preqfal_StatusCode,@preqfal_HasBankingData, @preqfal_HasNonBankingData, @preqfal_HasCreditUsageData,@preqfal_ActiveBankingTradelineCount,@preqfal_InactiveBankingTradelineCount,@preqfal_ActiveNonBankingTradelineCount,@preqfal_InactiveNonBankingTradelineCount,@preqfal_SuccessfulAddressID,@preqfal_LookupCount,@preqfal_ExceptionMsg,@UserID,@Now,@UserID,@Now,@Now);SELECT SCOPE_IDENTITY();";

    protected const string SQL_INSERT_AUDIT_DETAIL =
        "INSERT INTO PREquifaxAuditLogDetail (preqfald_EquifaxAuditLogID, preqfald_Type, preqfald_Code, preqfald_Description, preqfald_RequestedAddressID, preqfald_CreatedBy, preqfald_CreatedDate, preqfald_UpdatedBy, preqfald_UpdatedDate, preqfald_TimeStamp) " +
        "VALUES (@preqfald_EquifaxAuditLogID,@preqfald_Type,@preqfald_Code,@preqfald_Description,@preqfald_RequestedAddressID,@UserID,@Now,@UserID,@Now,@Now)";

    protected const string SQL_INSERT_EQUIFAX_NO_DATA =
        "INSERT INTO PREquifaxData (preqf_RequestID, preqf_SubjectCompanyID, preqf_StatusCode, preqf_CreatedBy, preqf_CreatedDate, preqf_UpdatedBy, preqf_UpdatedDate, preqf_TimeStamp) " +
        "VALUES (@preqf_RequestID,@preqf_SubjectCompanyID,@preqf_StatusCode,@UserID,@Now,@UserID,@Now,@Now)";

    protected const string SQL_INSERT_EQUIFAX_DATA =
        "INSERT INTO PREquifaxData (preqf_RequestID, preqf_SubjectCompanyID, preqf_StatusCode, preqf_RecentSinceDate, preqf_PRS_NumberOfBankruptcies, preqf_PRS_NumberOfJudgments, preqf_PRS_TotalSatisfiedJudgments, preqf_PRS_NumberOfLiens, preqf_PRS_TotalReleasedLiens, preqf_PRS_TotalBankruptcyAmount, preqf_PRS_TotalJudgmentAmount, preqf_PRS_TotalSatisfiedJudgmentAmount, preqf_PRS_TotalLienAmount, preqf_PRS_TotalReleasedLienAmount, preqf_PRS_RecentBankruptcyDate, preqf_PRS_RecentJudgmentDate, preqf_PRS_RecentLienDate, preqf_PRS_TotalFiledJudgments, preqf_PRS_TotalFiledJudgmentAmount, preqf_PRS_TotalFiledLiens, preqf_PRS_TotalFiledLienAmount, preqf_FS_SA_NumberOfAccounts, preqf_FS_SA_CreditActiveSince, preqf_FS_SA_NumberOfChargeOffs, preqf_FS_SA_TotalPastDue, preqf_FS_SA_MostSevereStatus24Months, preqf_FS_SA_HighestCredit, preqf_FS_SA_TotalExposure, preqf_FS_SA_MedianBalance, preqf_FS_SA_AverageOpenBalance, preqf_FS_SA_NewDelinquencies, preqf_FS_SA_NewAccounts, preqf_FS_SA_NewInquiries, preqf_FS_SA_NewUpdates, preqf_FS_SA_CurrentCreditLimitTotals, preqf_FS_SA_HiCreditOrOrigLoanAmtTotals, preqf_FS_SA_NumberOfActiveTrades, preqf_FS_SA_BalanceTotals, preqf_FS_SA_PastDueAmtTotals, preqf_FS_CU_TotalCreditLimit, preqf_FS_CU_TotalBalance, preqf_FS_CU_PercentBalance, preqf_FS_CU_AvailableCredit, preqf_FS_CU_PercentAvailableCredit, preqf_NFS_SA_NumberOfAccounts, preqf_NFS_SA_CreditActiveSince, preqf_NFS_SA_NumberOfChargeOffs, preqf_NFS_SA_TotalPastDue, preqf_NFS_SA_MostSevereStatus24Months, preqf_NFS_SA_HighestCredit, preqf_NFS_SA_TotalExposure, preqf_NFS_SA_MedianBalance, preqf_NFS_SA_AverageOpenBalance, preqf_NFS_SA_NewDelinquencies, preqf_NFS_SA_NewAccounts, preqf_NFS_SA_NewInquiries, preqf_NFS_SA_NewUpdates, preqf_NFS_SA_BalanceTotals, preqf_NFS_SA_PastDueAmtTotals, preqf_NFS_SA_NumberOfActiveTrades, preqf_NFS_SA_HiCreditOrOrigLoanAmtTotals, preqf_NFS_SA_CurrentCreditLimitTotals, preqf_CreatedBy,preqf_CreatedDate,preqf_UpdatedBy,preqf_UpdatedDate,preqf_TimeStamp) " +
                          "VALUES (@preqf_RequestID,@preqf_SubjectCompanyID,@preqf_StatusCode,@preqf_RecentSinceDate,@preqf_PRS_NumberOfBankruptcies,@preqf_PRS_NumberOfJudgments,@preqf_PRS_TotalSatisfiedJudgments,@preqf_PRS_NumberOfLiens,@preqf_PRS_TotalReleasedLiens,@preqf_PRS_TotalBankruptcyAmount,@preqf_PRS_TotalJudgmentAmount,@preqf_PRS_TotalSatisfiedJudgmentAmount,@preqf_PRS_TotalLienAmount,@preqf_PRS_TotalReleasedLienAmount,@preqf_PRS_RecentBankruptcyDate,@preqf_PRS_RecentJudgmentDate,@preqf_PRS_RecentLienDate,@preqf_PRS_TotalFiledJudgments,@preqf_PRS_TotalFiledJudgmentAmount,@preqf_PRS_TotalFiledLiens,@preqf_PRS_TotalFiledLienAmount,@preqf_FS_SA_NumberOfAccounts,@preqf_FS_SA_CreditActiveSince,@preqf_FS_SA_NumberOfChargeOffs,@preqf_FS_SA_TotalPastDue,@preqf_FS_SA_MostSevereStatus24Months,@preqf_FS_SA_HighestCredit,@preqf_FS_SA_TotalExposure,@preqf_FS_SA_MedianBalance,@preqf_FS_SA_AverageOpenBalance,@preqf_FS_SA_NewDelinquencies,@preqf_FS_SA_NewAccounts,@preqf_FS_SA_NewInquiries,@preqf_FS_SA_NewUpdates,@preqf_FS_SA_CurrentCreditLimitTotals,@preqf_FS_SA_HiCreditOrOrigLoanAmtTotals,@preqf_FS_SA_NumberOfActiveTrades,@preqf_FS_SA_BalanceTotals,@preqf_FS_SA_PastDueAmtTotals,@preqf_FS_CU_TotalCreditLimit,@preqf_FS_CU_TotalBalance,@preqf_FS_CU_PercentBalance,@preqf_FS_CU_AvailableCredit,@preqf_FS_CU_PercentAvailableCredit,@preqf_NFS_SA_NumberOfAccounts,@preqf_NFS_SA_CreditActiveSince,@preqf_NFS_SA_NumberOfChargeOffs,@preqf_NFS_SA_TotalPastDue,@preqf_NFS_SA_MostSevereStatus24Months,@preqf_NFS_SA_HighestCredit,@preqf_NFS_SA_TotalExposure,@preqf_NFS_SA_MedianBalance,@preqf_NFS_SA_AverageOpenBalance,@preqf_NFS_SA_NewDelinquencies,@preqf_NFS_SA_NewAccounts,@preqf_NFS_SA_NewInquiries,@preqf_NFS_SA_NewUpdates,@preqf_NFS_SA_BalanceTotals,@preqf_NFS_SA_PastDueAmtTotals,@preqf_NFS_SA_NumberOfActiveTrades,@preqf_NFS_SA_HiCreditOrOrigLoanAmtTotals,@preqf_NFS_SA_CurrentCreditLimitTotals,@UserID,@Now,@UserID,@Now,@Now);SELECT SCOPE_IDENTITY();";

    protected const string SQL_INSERT_EQUIFAX_DATA_TRADE_INFO =
        "INSERT INTO PREquifaxDataTradeInfo (preqfti_EquifaxDataID,preqfti_TradeInfoType,preqfti_AccountReference,preqfti_AccountIndicator,preqfti_OverallStatus,preqfti_TraitActivityReportedDate,preqfti_AcctOpenedDate,preqfti_DateClosed,preqfti_ReasonClosed,preqfti_HiCreditOrOrigLoanAmount,preqfti_OriginalCreditLimit,preqfti_CurrentCreditLimit,preqfti_LastPaymentAmount,preqfti_LastPaymentDate,preqfti_SecuredAccountIndicator,preqfti_ActiveAccount,preqfti_MaturityOrExpDate,preqfti_ScheduledPaymentAmount,preqfti_RepaymentFrequency,preqfti_BalanceAmount,preqfti_PastDueAmount,preqfti_Terms,preqfti_HighCreditDate,preqtfi_PastDueLength,preqtfi_AvgDaysToPayDesc,preqtfi_AvgDaysToPay,preqtfi_YearsSold,preqtfi_LastSaleAmount,preqtfi_LastSaleDate,preqtfi_Collateral,preqtfi_AccountComments,preqtfi_ChargeOffAmount,preqtfi_ChargeOffDate,preqtfi_PaymentIndicator,preqtfi_PaymentHistoryPeriod,preqtfi_IS_IndustryCode,preqtfi_ReportedDate,preqfti_IsBanking,preqfti_PRCoActiveAccount,preqfti_CreatedBy,preqfti_CreatedDate,preqfti_UpdatedBy,preqfti_UpdatedDate,preqfti_TimeStamp) " +
        "VALUES (@preqfti_EquifaxDataID,@preqfti_TradeInfoType,@preqfti_AccountReference,@preqfti_AccountIndicator,@preqfti_OverallStatus,@preqfti_TraitActivityReportedDate,@preqfti_AcctOpenedDate,@preqfti_DateClosed,@preqfti_ReasonClosed,@preqfti_HiCreditOrOrigLoanAmount,@preqfti_OriginalCreditLimit,@preqfti_CurrentCreditLimit,@preqfti_LastPaymentAmount,@preqfti_LastPaymentDate,@preqfti_SecuredAccountIndicator,@preqfti_ActiveAccount,@preqfti_MaturityOrExpDate,@preqfti_ScheduledPaymentAmount,@preqfti_RepaymentFrequency,@preqfti_BalanceAmount,@preqfti_PastDueAmount,@preqfti_Terms,@preqfti_HighCreditDate,@preqtfi_PastDueLength,@preqtfi_AvgDaysToPayDesc,@preqtfi_AvgDaysToPay,@preqtfi_YearsSold,@preqtfi_LastSaleAmount,@preqtfi_LastSaleDate,@preqtfi_Collateral,@preqtfi_AccountComments,@preqtfi_ChargeOffAmount,@preqtfi_ChargeOffDate,@preqtfi_PaymentIndicator,@preqtfi_PaymentHistoryPeriod,@preqtfi_IS_IndustryCode,@preqtfi_ReportedDate,@preqfti_IsBanking,@preqfti_PRCoActiveAccount,@UserID,@Now,@UserID,@Now,@Now)";

    [SqlProcedure()]
    public static int PopulateEquifaxData(int iRequestID, int iSubjectCompanyID) {
        int iWebUserID = 0;
        int iRequestingCompanyID = 0;

        string szHasBankingData = null;
        string szHasNonBankingData = null;
        string szHasCreditUsageData = null;
        
        using (SqlConnection oSQLConn = new SqlConnection("context connection=true")) {
        //using (SqlConnection oSQLConn = new SqlConnection("server=sql.bluebookservices.local;User ID=accpac;Password=2006PIKS1204;Initial Catalog=CRM;Application Name=CHW;"))
        //{

            


            try {
                int iActiveBankingTradelineCount = 0;
                int iInactiveBankingTradelineCount = 0;
                int iActiveNonBankingTradelineCount = 0;
                int iInactiveNonBankingTradelineCount = 0;
                
                oSQLConn.Open();


                SqlCommand oSQLCommand = new SqlCommand("SELECT dbo.ufn_GetCustomCaptionValue('EquifaxIntegration', 'Enabled', 'en-us')", oSQLConn);
                object result = oSQLCommand.ExecuteScalar();
                if ((result == DBNull.Value) ||
                    (result == null) ||
                    (Convert.ToString(result) != "1"))
                {
                    return 0;
                }




                GetRequestInfo(oSQLConn, iRequestID, out iWebUserID, out iRequestingCompanyID);

                int iLookupCount = 0;
                int iAddressID = 0;
                List<ApplicationErrorNode> lAppErrorNodes = null;

                XmlDocument xd = GetEquifaxXML(oSQLConn, 
                                               iRequestID, 
                                               iSubjectCompanyID, 
                                               out iAddressID, 
                                               out iLookupCount, 
                                               out lAppErrorNodes);

                // If we don't find a company, insert not only an audit log record,
                // but also a data record so the report has something to act on.
                if (xd == null) {
                    SqlCommand oSQLEquifaxData2 = new SqlCommand(SQL_INSERT_EQUIFAX_NO_DATA, oSQLConn);
                    oSQLEquifaxData2.Parameters.AddWithValue("@preqf_RequestID", iRequestID);
                    oSQLEquifaxData2.Parameters.AddWithValue("@preqf_SubjectCompanyID", iSubjectCompanyID);
                    oSQLEquifaxData2.Parameters.AddWithValue("@preqf_StatusCode", STATUS_CODE_NO_DATA);
                    oSQLEquifaxData2.Parameters.AddWithValue("@UserID", iWebUserID);
                    oSQLEquifaxData2.Parameters.AddWithValue("@Now", DateTime.Now);
                    oSQLEquifaxData2.ExecuteNonQuery();

                    return InsertAuditRecord(xd, 
                                             oSQLConn, 
                                             iRequestID, 
                                             iRequestingCompanyID, 
                                             iSubjectCompanyID, 
                                             STATUS_CODE_NO_DATA, 
                                             iLookupCount,
                                             iWebUserID,
                                             lAppErrorNodes);
                }

                
                SqlTransaction oSQLTran = oSQLConn.BeginTransaction();
                try {
                    // Create the data record.
                    SqlCommand oSQLEquifaxData = new SqlCommand(SQL_INSERT_EQUIFAX_DATA, oSQLConn, oSQLTran);
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_RequestID", iRequestID);
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_SubjectCompanyID", iSubjectCompanyID);
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_StatusCode", STATUS_CODE_DATA);
                    oSQLEquifaxData.Parameters.AddWithValue("@UserID", iWebUserID);
                    oSQLEquifaxData.Parameters.AddWithValue("@Now", DateTime.Now);
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_RecentSinceDate", GetNodeValue(xd, XML_RPT_ROOT + "RecentSinceDate"));
                    
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_PRS_NumberOfBankruptcies", GetNodeValue(xd, XML_RPT_ROOT + "PublicRecordsSummary/NumberOfBankruptcies"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_PRS_NumberOfJudgments", GetNodeValue(xd, XML_RPT_ROOT + "PublicRecordsSummary/NumberOfJudgments"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_PRS_TotalSatisfiedJudgments", GetNodeValue(xd, XML_RPT_ROOT + "PublicRecordsSummary/TotalSatisfiedJudgments"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_PRS_NumberOfLiens", GetNodeValue(xd, XML_RPT_ROOT + "PublicRecordsSummary/NumberOfLiens"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_PRS_TotalReleasedLiens", GetNodeValue(xd, XML_RPT_ROOT + "PublicRecordsSummary/TotalReleasedLiens"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_PRS_TotalBankruptcyAmount", GetNodeValue(xd, XML_RPT_ROOT + "PublicRecordsSummary/TotalBankruptcyAmount"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_PRS_TotalJudgmentAmount", GetNodeValue(xd, XML_RPT_ROOT + "PublicRecordsSummary/TotalJudgmentAmount"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_PRS_TotalSatisfiedJudgmentAmount", GetNodeValue(xd, XML_RPT_ROOT + "PublicRecordsSummary/TotalSatisfiedJudgmentAmount"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_PRS_TotalLienAmount", GetNodeValue(xd, XML_RPT_ROOT + "PublicRecordsSummary/TotalLienAmount"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_PRS_TotalReleasedLienAmount", GetNodeValue(xd, XML_RPT_ROOT + "PublicRecordsSummary/TotalReleasedLienAmount"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_PRS_RecentBankruptcyDate", GetNodeValue(xd, XML_RPT_ROOT + "PublicRecordsSummary/RecentBankruptcyDate"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_PRS_RecentJudgmentDate", GetNodeValue(xd, XML_RPT_ROOT + "PublicRecordsSummary/RecentJudgmentDate"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_PRS_RecentLienDate", GetNodeValue(xd, XML_RPT_ROOT + "PublicRecordsSummary/RecentLienDate"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_PRS_TotalFiledJudgments", GetNodeValue(xd, XML_RPT_ROOT + "PublicRecordsSummary/TotalFiledJudgments"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_PRS_TotalFiledJudgmentAmount", GetNodeValue(xd, XML_RPT_ROOT + "PublicRecordsSummary/TotalFiledJudgmentAmount"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_PRS_TotalFiledLiens", GetNodeValue(xd, XML_RPT_ROOT + "PublicRecordsSummary/TotalFiledLiens"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_PRS_TotalFiledLienAmount", GetNodeValue(xd, XML_RPT_ROOT + "PublicRecordsSummary/TotalFiledLienAmount"));

                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_FS_SA_NumberOfAccounts", GetNodeValue(xd, XML_RPT_ROOT + "FinancialSummary/SummaryAttributes/NumberOfAccounts"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_FS_SA_CreditActiveSince", GetNodeValue(xd, XML_RPT_ROOT + "FinancialSummary/SummaryAttributes/CreditActiveSince"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_FS_SA_NumberOfChargeOffs", GetNodeValue(xd, XML_RPT_ROOT + "FinancialSummary/SummaryAttributes/NumberOfChargeOffs"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_FS_SA_TotalPastDue", GetNodeValue(xd, XML_RPT_ROOT + "FinancialSummary/SummaryAttributes/TotalPastDue"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_FS_SA_MostSevereStatus24Months", GetNodeValue(xd, XML_RPT_ROOT + "FinancialSummary/SummaryAttributes/MostSevereStatus24Months"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_FS_SA_HighestCredit", GetNodeValue(xd, XML_RPT_ROOT + "FinancialSummary/SummaryAttributes/HighestCredit"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_FS_SA_TotalExposure", GetNodeValue(xd, XML_RPT_ROOT + "FinancialSummary/SummaryAttributes/TotalExposure"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_FS_SA_MedianBalance", GetNodeValue(xd, XML_RPT_ROOT + "FinancialSummary/SummaryAttributes/MedianBalance"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_FS_SA_AverageOpenBalance", GetNodeValue(xd, XML_RPT_ROOT + "FinancialSummary/SummaryAttributes/AverageOpenBalance"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_FS_SA_NewDelinquencies", GetNodeValue(xd, XML_RPT_ROOT + "FinancialSummary/SummaryAttributes/NewDelinquencies"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_FS_SA_NewAccounts", GetNodeValue(xd, XML_RPT_ROOT + "FinancialSummary/SummaryAttributes/NewAccounts"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_FS_SA_NewInquiries", GetNodeValue(xd, XML_RPT_ROOT + "FinancialSummary/SummaryAttributes/NewInquiries"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_FS_SA_NewUpdates", GetNodeValue(xd, XML_RPT_ROOT + "FinancialSummary/SummaryAttributes/NewUpdates"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_FS_SA_CurrentCreditLimitTotals", GetNodeValue(xd, XML_RPT_ROOT + "FinancialSummary/SummaryAttributes/CurrentCreditLimitTotals"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_FS_SA_HiCreditOrOrigLoanAmtTotals", GetNodeValue(xd, XML_RPT_ROOT + "FinancialSummary/SummaryAttributes/HiCreditOrOrigLoanAmtTotals"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_FS_SA_NumberOfActiveTrades", GetNodeValue(xd, XML_RPT_ROOT + "FinancialSummary/SummaryAttributes/NumberOfActiveTrades"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_FS_SA_BalanceTotals", GetNodeValue(xd, XML_RPT_ROOT + "FinancialSummary/SummaryAttributes/BalanceTotals"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_FS_SA_PastDueAmtTotals", GetNodeValue(xd, XML_RPT_ROOT + "FinancialSummary/SummaryAttributes/PastDueAmtTotals"));

                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_FS_CU_TotalCreditLimit", GetNodeValue(xd, XML_RPT_ROOT + "FinancialSummary/CreditUtilization/TotalCreditLimit"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_FS_CU_TotalBalance", GetNodeValue(xd, XML_RPT_ROOT + "FinancialSummary/CreditUtilization/TotalBalance"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_FS_CU_PercentBalance", GetNodeValue(xd, XML_RPT_ROOT + "FinancialSummary/CreditUtilization/PercentBalance"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_FS_CU_AvailableCredit", GetNodeValue(xd, XML_RPT_ROOT + "FinancialSummary/CreditUtilization/AvailableCredit"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_FS_CU_PercentAvailableCredit", GetNodeValue(xd, XML_RPT_ROOT + "FinancialSummary/CreditUtilization/PercentAvailableCredit"));

                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_NFS_SA_NumberOfAccounts", GetNodeValue(xd, XML_RPT_ROOT + "NonFinancialSummary/SummaryAttributes/NumberOfAccounts"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_NFS_SA_CreditActiveSince", GetNodeValue(xd, XML_RPT_ROOT + "NonFinancialSummary/SummaryAttributes/CreditActiveSince"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_NFS_SA_NumberOfChargeOffs", GetNodeValue(xd, XML_RPT_ROOT + "NonFinancialSummary/SummaryAttributes/NumberOfChargeOffs"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_NFS_SA_TotalPastDue", GetNodeValue(xd, XML_RPT_ROOT + "NonFinancialSummary/SummaryAttributes/TotalPastDue"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_NFS_SA_MostSevereStatus24Months", GetNodeValue(xd, XML_RPT_ROOT + "NonFinancialSummary/SummaryAttributes/MostSevereStatus24Months"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_NFS_SA_HighestCredit", GetNodeValue(xd, XML_RPT_ROOT + "NonFinancialSummary/SummaryAttributes/HighestCredit"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_NFS_SA_TotalExposure", GetNodeValue(xd, XML_RPT_ROOT + "NonFinancialSummary/SummaryAttributes/TotalExposure"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_NFS_SA_MedianBalance", GetNodeValue(xd, XML_RPT_ROOT + "NonFinancialSummary/SummaryAttributes/MedianBalance"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_NFS_SA_AverageOpenBalance", GetNodeValue(xd, XML_RPT_ROOT + "NonFinancialSummary/SummaryAttributes/AverageOpenBalance"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_NFS_SA_NewDelinquencies", GetNodeValue(xd, XML_RPT_ROOT + "NonFinancialSummary/SummaryAttributes/NewDelinquencies"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_NFS_SA_NewAccounts", GetNodeValue(xd, XML_RPT_ROOT + "NonFinancialSummary/SummaryAttributes/NewAccounts"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_NFS_SA_NewInquiries", GetNodeValue(xd, XML_RPT_ROOT + "NonFinancialSummary/SummaryAttributes/NewInquiries"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_NFS_SA_NewUpdates", GetNodeValue(xd, XML_RPT_ROOT + "NonFinancialSummary/SummaryAttributes/NewUpdates"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_NFS_SA_BalanceTotals", GetNodeValue(xd, XML_RPT_ROOT + "NonFinancialSummary/SummaryAttributes/BalanceTotals"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_NFS_SA_PastDueAmtTotals", GetNodeValue(xd, XML_RPT_ROOT + "NonFinancialSummary/SummaryAttributes/PastDueAmtTotals"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_NFS_SA_NumberOfActiveTrades", GetNodeValue(xd, XML_RPT_ROOT + "NonFinancialSummary/SummaryAttributes/NumberOfActiveTrades"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_NFS_SA_HiCreditOrOrigLoanAmtTotals", GetNodeValue(xd, XML_RPT_ROOT + "NonFinancialSummary/SummaryAttributes/HiCreditOrOrigLoanAmtTotals"));
                    oSQLEquifaxData.Parameters.AddWithValue("@preqf_NFS_SA_CurrentCreditLimitTotals", GetNodeValue(xd, XML_RPT_ROOT + "NonFinancialSummary/SummaryAttributes/CurrentCreditLimitTotals"));
                    
                    int iEquifaxDataID = Convert.ToInt32(oSQLEquifaxData.ExecuteScalar());

                    // Create the data detail record for each TradeInfo node found.
                    XmlNodeList xmlNodeList = xd.SelectNodes("EfxTransmit/CommercialCreditReport/Folder/TradeInfo");
                    foreach (XmlNode oTradeInfoNode in xmlNodeList) {

                        XmlNode oCurrentTrade = GetChildNode(oTradeInfoNode, "CurrentTrade");
                        
                        SqlCommand oSQLEquifaxDataTradeInfo = new SqlCommand(SQL_INSERT_EQUIFAX_DATA_TRADE_INFO, oSQLConn, oSQLTran);
                        oSQLEquifaxDataTradeInfo.Parameters.AddWithValue("@preqfti_EquifaxDataID", iEquifaxDataID);
                        oSQLEquifaxDataTradeInfo.Parameters.AddWithValue("@UserID", iWebUserID);
                        oSQLEquifaxDataTradeInfo.Parameters.AddWithValue("@Now", DateTime.Now);
                        oSQLEquifaxDataTradeInfo.Parameters.AddWithValue("@preqfti_TradeInfoType", "CT");
                        oSQLEquifaxDataTradeInfo.Parameters.AddWithValue("@preqfti_AccountReference", GetNodeValue(oCurrentTrade, "AccountReference"));
                        oSQLEquifaxDataTradeInfo.Parameters.AddWithValue("@preqfti_AccountIndicator", GetNodeValue(oCurrentTrade, "AccountIndicator"));
                        oSQLEquifaxDataTradeInfo.Parameters.AddWithValue("@preqfti_OverallStatus", GetNodeValue(oCurrentTrade, "OverallStatus"));
                        oSQLEquifaxDataTradeInfo.Parameters.AddWithValue("@preqfti_AcctOpenedDate", GetNodeValue(oCurrentTrade, "AcctOpenedDate"));
                        oSQLEquifaxDataTradeInfo.Parameters.AddWithValue("@preqfti_DateClosed", GetNodeValue(oCurrentTrade, "DateClosed"));
                        oSQLEquifaxDataTradeInfo.Parameters.AddWithValue("@preqfti_ReasonClosed", GetNodeValue(oCurrentTrade, "ReasonClosed"));
                        oSQLEquifaxDataTradeInfo.Parameters.AddWithValue("@preqfti_HiCreditOrOrigLoanAmount", GetNodeValue(oCurrentTrade, "HiCreditOrOrigLoanAmount"));
                        oSQLEquifaxDataTradeInfo.Parameters.AddWithValue("@preqfti_OriginalCreditLimit", GetNodeValue(oCurrentTrade, "OriginalCreditLimit"));
                        oSQLEquifaxDataTradeInfo.Parameters.AddWithValue("@preqfti_CurrentCreditLimit", GetNodeValue(oCurrentTrade, "CurrentCreditLimit"));
                        oSQLEquifaxDataTradeInfo.Parameters.AddWithValue("@preqfti_LastPaymentAmount", GetNodeValue(oCurrentTrade, "LastPaymentAmount"));
                        oSQLEquifaxDataTradeInfo.Parameters.AddWithValue("@preqfti_LastPaymentDate", GetNodeValue(oCurrentTrade, "LastPaymentDate"));
                        oSQLEquifaxDataTradeInfo.Parameters.AddWithValue("@preqfti_SecuredAccountIndicator", GetNodeValue(oCurrentTrade, "SecuredAccountIndicator"));
                        oSQLEquifaxDataTradeInfo.Parameters.AddWithValue("@preqfti_ActiveAccount", GetNodeValue(oCurrentTrade, "ActiveAccount"));
                        oSQLEquifaxDataTradeInfo.Parameters.AddWithValue("@preqfti_MaturityOrExpDate", GetNodeValue(oCurrentTrade, "MaturityOrExpDate"));
                        oSQLEquifaxDataTradeInfo.Parameters.AddWithValue("@preqfti_ScheduledPaymentAmount", GetNodeValue(oCurrentTrade, "ScheduledPaymentAmount"));
                        oSQLEquifaxDataTradeInfo.Parameters.AddWithValue("@preqfti_RepaymentFrequency", GetNodeValue(oCurrentTrade, "RepaymentFrequency"));
                        oSQLEquifaxDataTradeInfo.Parameters.AddWithValue("@preqfti_BalanceAmount", GetNodeValue(oCurrentTrade, "BalanceAmount"));
                        oSQLEquifaxDataTradeInfo.Parameters.AddWithValue("@preqfti_PastDueAmount", GetNodeValue(oCurrentTrade, "PastDueAmount"));
                        oSQLEquifaxDataTradeInfo.Parameters.AddWithValue("@preqfti_Terms", GetNodeValue(oCurrentTrade, "Terms"));
                        oSQLEquifaxDataTradeInfo.Parameters.AddWithValue("@preqfti_HighCreditDate", GetNodeValue(oCurrentTrade, "HighCreditDate"));
                        oSQLEquifaxDataTradeInfo.Parameters.AddWithValue("@preqtfi_PastDueLength", GetNodeValue(oCurrentTrade, "PastDueLength"));
                        oSQLEquifaxDataTradeInfo.Parameters.AddWithValue("@preqtfi_AvgDaysToPayDesc", GetNodeValue(oCurrentTrade, "AvgDaysToPayDesc"));
                        oSQLEquifaxDataTradeInfo.Parameters.AddWithValue("@preqtfi_AvgDaysToPay", GetNodeValue(oCurrentTrade, "AvgDaysToPay"));
                        oSQLEquifaxDataTradeInfo.Parameters.AddWithValue("@preqtfi_YearsSold", GetNodeValue(oCurrentTrade, "YearsSold"));
                        oSQLEquifaxDataTradeInfo.Parameters.AddWithValue("@preqtfi_LastSaleAmount", GetNodeValue(oCurrentTrade, "LastSaleAmount"));
                        oSQLEquifaxDataTradeInfo.Parameters.AddWithValue("@preqtfi_LastSaleDate", GetNodeValue(oCurrentTrade, "LastSaleDate"));
                        oSQLEquifaxDataTradeInfo.Parameters.AddWithValue("@preqtfi_Collateral", GetNodeValue(oCurrentTrade, "Collateral"));
                        oSQLEquifaxDataTradeInfo.Parameters.AddWithValue("@preqtfi_AccountComments", GetNodeValue(oCurrentTrade, "AccountComments"));
                        oSQLEquifaxDataTradeInfo.Parameters.AddWithValue("@preqtfi_ChargeOffAmount", GetNodeValue(oCurrentTrade, "ChargeOffAmount"));
                        oSQLEquifaxDataTradeInfo.Parameters.AddWithValue("@preqtfi_ChargeOffDate", GetNodeValue(oCurrentTrade, "ChargeOffDate"));
                        oSQLEquifaxDataTradeInfo.Parameters.AddWithValue("@preqtfi_PaymentIndicator", GetNodeValue(oCurrentTrade, "PaymentIndicator"));
                        oSQLEquifaxDataTradeInfo.Parameters.AddWithValue("@preqtfi_PaymentHistoryPeriod", GetNodeValue(oCurrentTrade, "PaymentHistoryPeriod"));
                        
                        string szIsActive = "Y";
                        bool bIsActive = true;
                        
                        if ((string)(GetNodeValue(oCurrentTrade, "ActiveAccount")) == "N") {
                            bIsActive = false;
                            szIsActive = null;
                        } else if ((string)(GetNodeValue(oCurrentTrade, "ActiveAccount")) != "Y") {
                            if (GetNodeValue(oCurrentTrade, "DateClosed") != null) {
                                bIsActive = false;
                                szIsActive = null;
                            }
                        }
                        
                        object szReportedDate = null;
                        object szIndustryCode = null;
                        object szAccountIndicator = null;
                        
                        string szTradeInfoIsBanking = null;
                        XmlNode oTraitActivity = GetChildNode(oCurrentTrade, "TraitActivity");
                        
                        if (oTraitActivity != null) {
                            szReportedDate = GetNodeValue(oTraitActivity, "ReportedDate");

                            XmlNode oInformationSource = GetChildNode(oTraitActivity, "InformationSource");  
                            if (oInformationSource != null) {
                                szIndustryCode = GetNodeValue(oInformationSource, "IndustryCode");
                                szAccountIndicator = GetNodeValue(oCurrentTrade, "AccountIndicator");

                                if (IsBankingData((string)szAccountIndicator, (string)szIndustryCode)) {
                                    szHasBankingData = "Y";
                                    szTradeInfoIsBanking = "Y";
                                    
                                    if (bIsActive) {
                                        iActiveBankingTradelineCount++;
                                    } else {
                                        iInactiveBankingTradelineCount++;
                                    }
                                    
                                } else {
                                    szHasNonBankingData = "Y";

                                    if (bIsActive) {
                                        iActiveNonBankingTradelineCount++;
                                    } else {
                                        iInactiveNonBankingTradelineCount++;
                                    }
                                }
                            }
                        }

                        oSQLEquifaxDataTradeInfo.Parameters.AddWithValue("@preqfti_TraitActivityReportedDate", szReportedDate);
                        oSQLEquifaxDataTradeInfo.Parameters.AddWithValue("@preqtfi_ReportedDate", szReportedDate);
                        oSQLEquifaxDataTradeInfo.Parameters.AddWithValue("@preqtfi_IS_IndustryCode", szIndustryCode);
                        oSQLEquifaxDataTradeInfo.Parameters.AddWithValue("@preqfti_IsBanking", szTradeInfoIsBanking);
                        oSQLEquifaxDataTradeInfo.Parameters.AddWithValue("@preqfti_PRCoActiveAccount", szIsActive);
                        oSQLEquifaxDataTradeInfo.ExecuteNonQuery();
                    }
                    
                    oSQLTran.Commit();
                } catch {
                    if (oSQLTran != null) {
                        oSQLTran.Rollback();
                    }
                    throw;
                }
                
               
                
                if (HasCreditUsageData(xd)) {
                    szHasCreditUsageData = "Y";
                }

                // Create the audit record.
                return InsertAuditRecord(xd, 
                                        oSQLConn, 
                                        iRequestID, 
                                        iRequestingCompanyID, 
                                        iSubjectCompanyID, 
                                        STATUS_CODE_DATA, 
                                        szHasBankingData, 
                                        szHasNonBankingData, 
                                        szHasCreditUsageData,
                                        iActiveBankingTradelineCount,
                                        iInactiveBankingTradelineCount,
                                        iActiveNonBankingTradelineCount,
                                        iInactiveNonBankingTradelineCount,
                                        iAddressID,
                                        iLookupCount,
                                        iWebUserID,
                                        lAppErrorNodes);

            } catch (Exception e) {
                SqlCommand oSQLEquifaxData = new SqlCommand(SQL_INSERT_EQUIFAX_NO_DATA, oSQLConn);
                oSQLEquifaxData.Parameters.AddWithValue("@preqf_RequestID", iRequestID);
                oSQLEquifaxData.Parameters.AddWithValue("@preqf_SubjectCompanyID", iSubjectCompanyID);
                oSQLEquifaxData.Parameters.AddWithValue("@preqf_StatusCode", STATUS_CODE_ERROR);
                oSQLEquifaxData.Parameters.AddWithValue("@UserID", iWebUserID);
                oSQLEquifaxData.Parameters.AddWithValue("@Now", DateTime.Now);
                oSQLEquifaxData.ExecuteNonQuery();

                // Create the audit record.
                return InsertAuditRecord(null,
                                        oSQLConn,
                                        iRequestID,
                                        iRequestingCompanyID,
                                        iSubjectCompanyID,
                                        STATUS_CODE_ERROR,
                                        e.Message + ' ' + e.StackTrace,
                                        iWebUserID);            
            }
        }
    }
    
    /// <summary>
    /// This method creates the Request XML, establishes a connection to Equifax, and then
    /// retreives the Response XML.
    /// </summary>
    /// <param name="oSQLConn"></param>
    /// <param name="iRequestID"></param>
    /// <param name="iAddressID"></param>
    /// <param name="iLookupCount"></param>
    /// <param name="iSubjectCompanyID"></param>
    /// <param name="lAppErrorNodes"></param>
    /// <returns></returns>
    protected static XmlDocument GetEquifaxXML(SqlConnection oSQLConn, 
                                               int iRequestID, 
                                               int iSubjectCompanyID, 
                                               out int iAddressID, 
                                               out int iLookupCount, 
                                               out List<ApplicationErrorNode> lAppErrorNodes) {

        XmlDocument xd = null;
        lAppErrorNodes = new List<ApplicationErrorNode>();

        string szEquifaxURL = GetCustomCaptionValue(oSQLConn, "ExquifaxURL");
        string szServiceName = GetCustomCaptionValue(oSQLConn, "ServiceName");
        string szUserID = GetCustomCaptionValue(oSQLConn, "UserID");
        string szPassword = GetCustomCaptionValue(oSQLConn, "Password");
        string szCustomerNumber = GetCustomCaptionValue(oSQLConn, "CustomerNumber");
        string szSecurityCode = GetCustomCaptionValue(oSQLConn, "SecurityCode");
        string szEquifaxLogEnabled = GetCustomCaptionValue(oSQLConn, "EquifaxLogEnabled");

        bool bEquifaxLogEnabled = true;
        if ((string.IsNullOrEmpty(szEquifaxLogEnabled)) ||
            (szEquifaxLogEnabled != "1")) {
            bEquifaxLogEnabled = false;
        }
        
        //bEquifaxLogEnabled=false;

        string szLogFilePath = GetCustomCaptionValue(oSQLConn, "LogFilePath");
        if (string.IsNullOrEmpty(szLogFilePath)) {
            szLogFilePath = @"C:\";
        }

        iAddressID = 0;
        iLookupCount = 0;
        string szCompanyName = GetCompanyName(oSQLConn, iSubjectCompanyID);
        
        // Query for all of the addresses associated with this company.  We will iterate through them
        // in a specific order and try them one-at-a-time until we either get data from Equifax or
        // all have been tried.
        SqlCommand oSQLCommand = new SqlCommand(string.Format(SQL_SELECT_ADDRESS, iSubjectCompanyID), oSQLConn);
        using (SqlDataReader oReader = oSQLCommand.ExecuteReader()) {
            while (oReader.Read()) {

                iLookupCount++;

                iAddressID = oReader.GetInt32(0);
                string szAddressLine1 = GetStringValue(oReader, 1);
                string szCity = GetStringValue(oReader, 2);
                string szState = GetStringValue(oReader, 3);
                string szPostal = GetStringValue(oReader, 4);
                szPostal = szPostal.Replace("-", string.Empty);

                string[] aszArgs = {szAddressLine1,
                                    szCity,
                                    szState,
                                    szPostal};
                string szAddressTrait = string.Format(EQUIFAX_REQUEST_ADDRESS_TRAIT, aszArgs);                                    
            

                string[] aszEquifaxRequestArgs = {szCustomerNumber,
                                                  szSecurityCode,
                                                  szCompanyName,
                                                  szAddressTrait};
                string xmlEquifaxRequest = string.Format(EQUIFAX_REQUEST_XML, aszEquifaxRequestArgs);



                if (bEquifaxLogEnabled) {
                    string szRequestFile = Path.Combine(szLogFilePath, iSubjectCompanyID.ToString() + "_Request_" + iLookupCount.ToString() + ".xml");
                    WriteFile(szRequestFile, xmlEquifaxRequest);
                }

                HttpWebRequest httpRequest = null;
                HttpWebResponse httpResponse = null;

                try {
                    httpRequest = (HttpWebRequest)WebRequest.Create(szEquifaxURL);
                    httpRequest.UserAgent = "Produce Reporter Co.";
                    httpRequest.Method = "POST";

                    // The UserID and Password get concatenated into a single string
                    // and then encoded into Base64.
                    string szUserIDPassword = szUserID + ":" + szPassword;
                    byte[] baUserIDPassword = new byte[szUserIDPassword.Length];
                    for (int i = 0; i < baUserIDPassword.Length; i++)
                        baUserIDPassword[i] = (byte)(szUserIDPassword[i]);
                    string szBasic = "BASIC " + Convert.ToBase64String(baUserIDPassword);

                    httpRequest.Headers.Add("Authorization", szBasic);
                    httpRequest.Headers.Add("service_name", szServiceName);
                    httpRequest.ContentType = "text/xml";
                    httpRequest.Timeout = httpRequest.Timeout * 10;

                    // Send the request as a stream of bytes.
                    byte[] baXmlRequest = System.Text.Encoding.ASCII.GetBytes(xmlEquifaxRequest);
                    httpRequest.ContentLength = baXmlRequest.Length;
                    using (Stream stream = httpRequest.GetRequestStream()) {
                        stream.Write(baXmlRequest, 0, baXmlRequest.Length);
                    }

                    // Receive our response.
                    httpResponse = (HttpWebResponse)httpRequest.GetResponse();
                    if (httpResponse.StatusCode != HttpStatusCode.OK) {
                        throw new ApplicationException("Non-OK HTTP Status Code: " + httpResponse.StatusDescription);
                    }

                    string szResponse = null;
                    using (StreamReader tr = new StreamReader(httpResponse.GetResponseStream())) {
                        szResponse = tr.ReadToEnd();
                        tr.Close();
                    }
            
                    if (bEquifaxLogEnabled) {
                        string szResponseFile = Path.Combine(szLogFilePath, iSubjectCompanyID.ToString() + "_Response_" + iLookupCount.ToString() + ".xml");
                        WriteFile(szResponseFile, szResponse);
                    }

                    if (szResponse == "Internal Service Logic Error") {
                        throw new ApplicationException(szResponse);
                    }

                    xd = new XmlDocument();
                    xd.Load(new StringReader(szResponse));

                    CheckForProcessingError(xd);

                    // If we found a company, then return the
                    // XML document.
                    if (IsCompanyFound(xd)) {
                        return xd;
                    } else {
                        // If not, store any application error nodes in a placeholder so we can log them
                        // all later.
                        XmlNodeList xmlErrorNodeList = xd.SelectNodes("EfxTransmit/StandardRequest/Folder/ApplicationError");
                        foreach (XmlNode oErrorNode in xmlErrorNodeList) {
                            lAppErrorNodes.Add(new ApplicationErrorNode(oErrorNode.ChildNodes[0].InnerText,
                                                                        oErrorNode.ChildNodes[1].InnerText,
                                                                        iAddressID));
                        }
                     }
                } finally {
                    if (httpResponse != null) {
                        httpResponse.Close();
                    }
                }    
            }                            
        } 
        
        return null;           
    }

    
    protected const string SQL_SELECT_COMPANY_NAME =
        @"SELECT ISNULL(comp_PRLegalName, comp_PRCorrTradestyle) 
           FROM Company WITH (NOLOCK)
          WHERE comp_CompanyID={0};";
         
    /// <summary>
    /// Returns the name for the specified company
    /// </summary>
    /// <param name="oSQLConn"></param>
    /// <param name="iSubjectCompanyID"></param>
    /// <returns></returns>
    protected static string GetCompanyName(SqlConnection oSQLConn, int iSubjectCompanyID) {
        SqlCommand oSQLCommand = new SqlCommand(string.Format(SQL_SELECT_COMPANY_NAME, iSubjectCompanyID), oSQLConn);
        return GetXmlString((string)oSQLCommand.ExecuteScalar());
    }

    protected const string SQL_SELECT_ADDRESS =
        "SELECT addr_AddressID, addr_Address1, prci_City, prst_Abbreviation, addr_PostCode " +
          "FROM Address_Link WITH (NOLOCK) " +
               "INNER JOIN Address WITH (NOLOCK) ON adli_AddressID = addr_AddressID " +
               "INNER JOIN vPRLocation ON addr_PRCityID = prci_CityID " +
        "WHERE adli_CompanyID={0} " +
          "AND addr_PRPublish = 'Y' " +
     "ORDER BY ISNULL(addr_PRPublish, 'Z'), " +
         "CASE adli_Type  " +
			"WHEN 'PH' THEN 1  " +
			"WHEN 'M' THEN 2  " +
			"WHEN 'S' THEN 3  " +
			"WHEN 'W' THEN 4  " +
			"WHEN 'I' THEN 5  " +
			"WHEN 'O' THEN 6  " +
			"WHEN 'T' THEN 7  " +
			"WHEN 'PS' THEN 8  " +
			"WHEN 'PM' THEN 9  " +
            "ELSE 99 " +
         "END;";

   	           
  
    protected const string SQL_SELECT_REQUEST = "SELECT prreq_WebUserID, prreq_CompanyID FROM PRRequest WHERE prreq_RequestID={0}";
    protected static void GetRequestInfo(SqlConnection oSQLConn, int iRequestID, out int iWebUserID, out int iRequestingCompanyID) {
        SqlCommand oSQLCommand = new SqlCommand(string.Format(SQL_SELECT_REQUEST, iRequestID), oSQLConn);
        using (SqlDataReader oReader = oSQLCommand.ExecuteReader()) {
            oReader.Read();
            iWebUserID = oReader.GetInt32(0);
            iRequestingCompanyID = oReader.GetInt32(1);
        }
    }

    #region Helper Functions
    protected const string SQL_SELECT_CUSTOM_CAPTION_VALUE = "SELECT capt_us FROM custom_captions WHERE capt_family='EquifaxIntegration' AND capt_code='{0}'";
    /// <summary>
    /// Helper function that returns the specified custom_caption
    /// value.
    /// </summary>
    /// <param name="oSQLConn"></param>
    /// <param name="szCode"></param>
    /// <returns></returns>
    protected static string GetCustomCaptionValue(SqlConnection oSQLConn, string szCode) {
        SqlCommand oSQLCommand = new SqlCommand(string.Format(SQL_SELECT_CUSTOM_CAPTION_VALUE, szCode), oSQLConn);
        return (string)oSQLCommand.ExecuteScalar();
    }
    
    
    /// <summary>
    /// Helper function that returns a string value, or an 
    /// empty string if the value is DBNull.
    /// </summary>
    /// <param name="oReader"></param>
    /// <param name="iOrdinal"></param>
    /// <returns></returns>
    protected static string GetStringValue(SqlDataReader oReader, int iOrdinal) {
        if (oReader[iOrdinal] == DBNull.Value) {
            return string.Empty;
        }
        return GetXmlString(oReader.GetString(iOrdinal));
    }

    /// <summary>
    /// Helper function that ensure the specified string is 
    /// formatted for XML.
    /// </summary>
    /// <param name="szValue"></param>
    /// <returns></returns>
    protected static string GetXmlString(string szValue) {
        if (szValue == null) {
            return string.Empty;
        }
        return szValue.Trim().ToUpper().Replace("&", "&amp;");
    }

    /// <summary>
    /// Helper function that writes debug information to a specified
    /// file.
    /// </summary>
    /// <param name="szFileName"></param>
    /// <param name="szContents"></param>
    protected static void WriteFile(string szFileName, string szContents) {
        
    
        WindowsImpersonationContext OriginalContext = null;
        try
        {
            //Impersonate the current SQL Security context
            WindowsIdentity CallerIdentity = SqlContext.WindowsIdentity;

            //WindowsIdentity might be NULL if calling context is a SQL login
            if (CallerIdentity != null)
            {
                OriginalContext = CallerIdentity.Impersonate();
            }

            using (StreamWriter oWriter = File.CreateText(szFileName)) {
                oWriter.Write(szContents);
                oWriter.Close();
            }            
            
        } finally {
            //Revert the impersonation context; note that impersonation is needed only            
            //when opening the file.             
            //SQL Server will raise an exception if the impersonation is not undone             
            // before returning from the function.            
            if (OriginalContext != null)
                OriginalContext.Undo();
        }    
    }

    /// <summary>
    /// Helper method that returns the value for the specified
    /// XPath
    /// </summary>
    /// <param name="xd"></param>
    /// <param name="szXPath"></param>
    /// <returns></returns>
    protected static object GetNodeValue(XmlDocument xd, string szXPath) {

         //WriteFile(@"C:\Debug.txt", szXPath);
         XmlNodeList xmlNodeList = xd.SelectNodes(szXPath);
         if (xmlNodeList.Count == 0) {
            return null;
        }
        return xmlNodeList[0].InnerText;
    }

    /// <summary>
    /// Helper method that returns the value for the specified
    /// parent/child nodes.  If more than one node is found it
    /// is concatenated to our value.
    /// </summary>
    /// <param name="oParentNode"></param>
    /// <param name="szChildNodeName"></param>
    /// <returns></returns>
    protected static object GetNodeValue(XmlNode oParentNode, string szChildNodeName) {
        string szValue = string.Empty;

        foreach (XmlNode oNode in oParentNode.ChildNodes) {
            if (oNode.Name == szChildNodeName) {
                if (szValue.Length > 0) {
                    szValue += ", ";
                }
                szValue += oNode.InnerText;
            }
        }

        if (szValue.Length == 0) {
            return null;
        } else {
            return szValue;
        }
    }
    
    /// <summary>
    /// Helper method that returns the specified child of the parent node.
    /// </summary>
    /// <param name="oParentNode"></param>
    /// <param name="szChildNodeName"></param>
    /// <returns></returns>
    protected static XmlNode GetChildNode(XmlNode oParentNode, string szChildNodeName) {
        
        foreach (XmlNode oNode in oParentNode.ChildNodes) {
            if (oNode.Name == szChildNodeName) {
                return oNode;
            }
        }
        
        return null;
    }   


    protected const string XML_NOT_FOUND_NODE = "EfxTransmit/NoRecord";
    
    /// <summary>
    /// Helper method that determines if the subject company was found
    /// by Equifax
    /// </summary>
    /// <param name="xd"></param>
    /// <returns></returns>
    protected static bool IsCompanyFound(XmlDocument xd) {

        XmlNodeList xmlNodeList = xd.SelectNodes(XML_NOT_FOUND_NODE);
        if (xmlNodeList.Count == 1) {
            return false;
        }

        return true;
    }


    /// <summary>
    /// Helper method that determines if the subject company was found
    /// by Equifax
    /// </summary>
    /// <param name="xd"></param>
    /// <returns></returns>
    protected static void CheckForProcessingError(XmlDocument xd) {

        string szErrorMsg = null;
        XmlNodeList xmlErrNodeList = xd.SelectNodes("EfxTransmit/CodedErrorReport/ProcessingError");
        foreach (XmlNode oNode in xmlErrNodeList) {
            if (!string.IsNullOrEmpty(szErrorMsg)) {
                szErrorMsg += " ";
            }
            szErrorMsg += oNode.Attributes["description"].Value;
        }

        if (!string.IsNullOrEmpty(szErrorMsg)) {
            throw new ApplicationException(szErrorMsg);
        }
    }

    /// <summary>
    /// Helper method determines if the specified industry code is
    /// for a banking institution or not.  Have seen some data contain
    /// the codes and other data contain the values, so we are
    /// checking for both here.
    /// </summary>
    /// <param name="szAccountIndicator"></param>
    /// <param name="szIndustryCode"></param>
    /// <returns></returns>
    protected static bool IsBankingData(string szAccountIndicator, string szIndustryCode) {


        if (!string.IsNullOrEmpty(szAccountIndicator)) {
            switch (szAccountIndicator.ToLower().Trim()) {
                case "commercial card":
                case "business lease":
                case "open ended credit line":
                case "line of credit":
                case "term":
                case "Letter of credit":
                case "other":
                    return true;            
            }
        } else {
            if (szIndustryCode.Length == 2) {
                switch(szIndustryCode) {
                    case "BB":
                    case "BX":
                    case "FA":
                    case "FB":
                    case "FC":
                    case "FF":
                    case "FP":
                    case "FY":
                    case "FZ":
                    case "IZ":
                    case "ON":
                        return true;            
                }
            } else {
                switch(szIndustryCode) {
                    case "Finance - Banks":
                    case "Finance - Demand Deposit Account":
                    case "Finance - Automotive":
                    case "Finance - Brokerage":
                    case "Finance - Credit Unions":
                    case "Finance - Sales":
                    case "Finance - Personal Loan Companies":
                    case "Finance - Factoring":
                    case "Finance - Sales Financing, Securities and all other":
                    case "Insurance":
                    case "Finance - Credit Card":
                        return true; 
                }                            
            }
        }
        return false;
    }

    /// <summary>
    /// Helper method determines if "Credit Usage" data
    /// has been returned.
    /// </summary>
    /// <param name="xd"></param>
    /// <returns></returns>
    protected static bool HasCreditUsageData(XmlDocument xd) {
    
        string szTotalCreditLimit = (string)GetNodeValue(xd, XML_RPT_ROOT + "FinancialSummary/CreditUtilization/TotalCreditLimit");
        string szTotalBalance = (string)GetNodeValue(xd, XML_RPT_ROOT + "FinancialSummary/CreditUtilization/TotalBalance");
        string szPercentBalance = (string)GetNodeValue(xd, XML_RPT_ROOT + "FinancialSummary/CreditUtilization/PercentBalance");
        string szAvailableCredit = (string)GetNodeValue(xd, XML_RPT_ROOT + "FinancialSummary/CreditUtilization/AvailableCredit");
        string szPercentAvailableCredit = (string)GetNodeValue(xd, XML_RPT_ROOT + "FinancialSummary/CreditUtilization/PercentAvailableCredit");

        if ((string.IsNullOrEmpty(szTotalCreditLimit)) &&
            (string.IsNullOrEmpty(szTotalBalance)) &&
            (string.IsNullOrEmpty(szPercentBalance)) &&
            (string.IsNullOrEmpty(szAvailableCredit)) &&
            (string.IsNullOrEmpty(szPercentAvailableCredit))) {
            return false;            
        }
        
        return true;
    }

    protected static int InsertAuditRecord(XmlDocument xd,
                                            SqlConnection oSQLConn, 
                                            int iRequestID, 
                                            int iRequestingCompanyID, 
                                            int iSubjectCompanyID, 
                                            string szStatusCode,
                                            int iLookupCount,
                                            int iWebUserID,
                                            List<ApplicationErrorNode> lAppErrorNodes) {
        return InsertAuditRecord(xd, oSQLConn, iRequestID, iRequestingCompanyID, iSubjectCompanyID, szStatusCode, string.Empty, string.Empty, string.Empty, 0, 0, 0, 0, 0, iLookupCount, string.Empty, iWebUserID, lAppErrorNodes);
    }

    protected static int InsertAuditRecord(XmlDocument xd,
                                            SqlConnection oSQLConn,
                                            int iRequestID,
                                            int iRequestingCompanyID,
                                            int iSubjectCompanyID,
                                            string szStatusCode,
                                            string szExceptionMsg,
                                            int iWebUserID) {
        return InsertAuditRecord(xd, oSQLConn, iRequestID, iRequestingCompanyID, iSubjectCompanyID, szStatusCode, string.Empty, string.Empty, string.Empty, 0, 0, 0, 0, 0, 0, szExceptionMsg, iWebUserID, null);
    }


    protected static int InsertAuditRecord(XmlDocument xd,
                                            SqlConnection oSQLConn,
                                            int iRequestID,
                                            int iRequestingCompanyID,
                                            int iSubjectCompanyID,
                                            string szStatusCode,
                                            string szHasBankingData,
                                            string szHasNonBankingData,
                                            string szHasCreditUsageData,
                                            int iActiveBankingTradelineCount,
                                            int iInactiveBankingTradelineCount,
                                            int iActiveNonBankingTradelineCount,
                                            int iInactiveNonBankingTradelineCount,
                                            int iSuccessfulAddressID,
                                            int iLookupCount,
                                            int iWebUserID,
                                            List<ApplicationErrorNode> lAppErrorNodes) {
        return InsertAuditRecord(xd, oSQLConn, iRequestID, iRequestingCompanyID, iSubjectCompanyID, szStatusCode, szHasBankingData, szHasNonBankingData, szHasCreditUsageData, iActiveBankingTradelineCount, iInactiveBankingTradelineCount, iActiveNonBankingTradelineCount, iInactiveNonBankingTradelineCount, iSuccessfulAddressID, iLookupCount, null, iWebUserID, lAppErrorNodes);
    }                                           

    /// <summary>
    /// Inserts an Audit record and then iterates through the XML inserts Audit Detail
    /// records for any alert or error nodes found.
    /// <remarks>
    /// We are purposely not wrapping these inserts in a transaction because if an 
    /// error occurs, we need as much of this saved as possible.
    /// </remarks>
    /// </summary>
    /// <param name="xd"></param>
    /// <param name="oSQLConn"></param>
    /// <param name="iRequestID"></param>
    /// <param name="iRequestingCompanyID"></param>
    /// <param name="iSubjectCompanyID"></param>
    /// <param name="szStatusCode"></param>
    /// <param name="szHasBankingData"></param>
    /// <param name="szHasNonBankingData"></param>
    /// <param name="szHasCreditUsageData"></param>
    /// <param name="iActiveBankingTradelineCount"></param>
    /// <param name="iInactiveBankingTradelineCount"></param>
    /// <param name="iActiveNonBankingTradelineCount"></param>
    /// <param name="iInactiveNonBankingTradelineCount"></param>
    /// <param name="iSuccessfulAddressID"></param>
    /// <param name="iLookupCount"></param>
    /// <param name="szExceptionMessage"></param>
    /// <param name="iWebUserID"></param>
    /// <param name="lAppErrorNodes"></param>
    /// <returns></returns>
    protected static int InsertAuditRecord(XmlDocument xd,
                                            SqlConnection oSQLConn, 
                                            int iRequestID, 
                                            int iRequestingCompanyID, 
                                            int iSubjectCompanyID, 
                                            string szStatusCode, 
                                            string szHasBankingData, 
                                            string szHasNonBankingData, 
                                            string szHasCreditUsageData,
                                            int iActiveBankingTradelineCount,
                                            int iInactiveBankingTradelineCount,
                                            int iActiveNonBankingTradelineCount,
                                            int iInactiveNonBankingTradelineCount,
                                            int iSuccessfulAddressID,
                                            int iLookupCount,
                                            string szExceptionMessage,
                                            int iWebUserID,
                                            List<ApplicationErrorNode> lAppErrorNodes) {

        // Create the audit record.
        SqlCommand oSQLAuditLogCommand = new SqlCommand(SQL_INSERT_AUDIT, oSQLConn);
        oSQLAuditLogCommand.Parameters.AddWithValue("@preqfal_RequestID", iRequestID);
        oSQLAuditLogCommand.Parameters.AddWithValue("@preqfal_RequestingCompanyID", iRequestingCompanyID);
        oSQLAuditLogCommand.Parameters.AddWithValue("@preqfal_SubjectCompanyID", iSubjectCompanyID);
        oSQLAuditLogCommand.Parameters.AddWithValue("@preqfal_StatusCode", szStatusCode);
        oSQLAuditLogCommand.Parameters.AddWithValue("@preqfal_HasBankingData", szHasBankingData);
        oSQLAuditLogCommand.Parameters.AddWithValue("@preqfal_HasNonBankingData", szHasNonBankingData);
        oSQLAuditLogCommand.Parameters.AddWithValue("@preqfal_HasCreditUsageData", szHasCreditUsageData);
        oSQLAuditLogCommand.Parameters.AddWithValue("@preqfal_ActiveBankingTradelineCount", iActiveBankingTradelineCount);
        oSQLAuditLogCommand.Parameters.AddWithValue("@preqfal_InactiveBankingTradelineCount", iInactiveBankingTradelineCount);
        oSQLAuditLogCommand.Parameters.AddWithValue("@preqfal_ActiveNonBankingTradelineCount", iActiveNonBankingTradelineCount);
        oSQLAuditLogCommand.Parameters.AddWithValue("@preqfal_InactiveNonBankingTradelineCount", iInactiveNonBankingTradelineCount);
        oSQLAuditLogCommand.Parameters.AddWithValue("@preqfal_SuccessfulAddressID", iSuccessfulAddressID);
        oSQLAuditLogCommand.Parameters.AddWithValue("@preqfal_LookupCount", iLookupCount);
        oSQLAuditLogCommand.Parameters.AddWithValue("@preqfal_ExceptionMsg", szExceptionMessage);
        oSQLAuditLogCommand.Parameters.AddWithValue("@UserID", iWebUserID);
        oSQLAuditLogCommand.Parameters.AddWithValue("@Now", DateTime.Now);

        int iAuditLogID = Convert.ToInt32(oSQLAuditLogCommand.ExecuteScalar());

        if (xd != null) {
            // If we have application error nodes, then process those
            // instead of looking in the XML result.
            if (lAppErrorNodes != null) {
            
                foreach(ApplicationErrorNode oAENode in lAppErrorNodes) {
                    InsertAuditLogDetail(oSQLConn,
                                         iAuditLogID,
                                         "E",
                                         oAENode.Code,
                                         oAENode.Description,
                                         oAENode.AddressID,
                                         iWebUserID);
                }
            
            } else {
                XmlNodeList xmlErrorNodeList = xd.SelectNodes("EfxTransmit/StandardRequest/Folder/ApplicationError");
                foreach (XmlNode oErrorNode in xmlErrorNodeList) {
                    InsertAuditLogDetail(oSQLConn,
                                         iAuditLogID,
                                         "E",
                                         oErrorNode.ChildNodes[0].InnerText,
                                         oErrorNode.ChildNodes[1].InnerText,
                                         iSuccessfulAddressID,
                                         iWebUserID);
                }
            }

            XmlNodeList xmlAlertNodeList = xd.SelectNodes("EfxTransmit/CommercialCreditReport/Folder/Alert");
            foreach (XmlNode oAlertNode in xmlAlertNodeList) {
                InsertAuditLogDetail(oSQLConn,
                                     iAuditLogID,
                                     "A",
                                     oAlertNode.ChildNodes[0].InnerText,
                                     oAlertNode.ChildNodes[1].InnerText,
                                     iSuccessfulAddressID,
                                     iWebUserID);
            }
        }
        
        return iAuditLogID;
    }

    /// <summary>
    /// Inserts an Audit Detail record using the specified
    /// parameters.
    /// </summary>
    /// <param name="oSQLConn"></param>
    /// <param name="iAuditLogID"></param>
    /// <param name="szType"></param>
    /// <param name="szCode"></param>
    /// <param name="szDescription"></param>
    /// <param name="iAddressID"></param>
    /// <param name="iWebUserID"></param>
    protected static void InsertAuditLogDetail(SqlConnection oSQLConn,
                                               int iAuditLogID,
                                               string szType,
                                               string szCode,
                                               string szDescription,
                                               int iAddressID,
                                               int iWebUserID) {

        SqlCommand oSQLCommandDetail = new SqlCommand(SQL_INSERT_AUDIT_DETAIL, oSQLConn);
        oSQLCommandDetail.Parameters.AddWithValue("@preqfald_EquifaxAuditLogID", iAuditLogID);
        oSQLCommandDetail.Parameters.AddWithValue("@preqfald_Type", szType);
        oSQLCommandDetail.Parameters.AddWithValue("@preqfald_Code", szCode);
        oSQLCommandDetail.Parameters.AddWithValue("@preqfald_Description", szDescription);
        oSQLCommandDetail.Parameters.AddWithValue("@preqfald_RequestedAddressID", iAddressID);
        oSQLCommandDetail.Parameters.AddWithValue("@UserID", iWebUserID);
        oSQLCommandDetail.Parameters.AddWithValue("@Now", DateTime.Now);
        oSQLCommandDetail.ExecuteNonQuery();    
    }

    #endregion
    
    #region EquifaxXML
    protected const string EQUIFAX_REQUEST_XML = 
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
        "<EfxCommercialRequest serviceCode=\"SB1\" customerReference=\"SAMPLE REQUEST\" efxInternalTranId=\"XXXXXXXXX\" tranID=\"XSOF\" customerNumber=\"{0}\" securityCode=\"{1}\" version=\"5.0\">" +
	        "<CustomerSecurityInfo>" +
		        "<CustomerNumber>{0}</CustomerNumber>" +
		        "<ProductCode name=\"RPT\" code=\"0001\">Standard Full</ProductCode>" +
		        "<ProductCode name=\"SCR\" code=\"0010\">Supplier Score</ProductCode>" +
                "<SecurityCode>{1}</SecurityCode>" +
	        "</CustomerSecurityInfo>" +
	        "<StandardRequest>" +
		        "<Folder>" +
			        "<IdTrait>" +
				        "<CompanyNameTrait>" +
					        "<BusinessName>{2}</BusinessName>" +
				        "</CompanyNameTrait>" +
                        "{3}" +
			        "</IdTrait>" +
		        "</Folder>" +
	        "</StandardRequest>" +
        "</EfxCommercialRequest>";
        
        
    protected const string EQUIFAX_REQUEST_ADDRESS_TRAIT =
        "<AddressTrait>" +
	        "<AddressLine1>{0}</AddressLine1>" +
	        "<City>{1}</City>" +
	        "<State>{2}</State>" +
	        "<PostalCode>{3}</PostalCode>" +
        "</AddressTrait>";  
    #endregion              

    protected class ApplicationErrorNode {
        public string Code;
        public string Description;
        public int AddressID;
        
        public ApplicationErrorNode(string szCode, string szDescription, int iAddressID) {
            Code = szCode;
            Description = szDescription;
            AddressID = iAddressID;
        }
    
    }
}
