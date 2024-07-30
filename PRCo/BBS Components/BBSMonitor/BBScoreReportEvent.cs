/***********************************************************************
 Copyright Produce Reporter Company 2006-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: BBScoreReportEvent.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;
using System.Timers;

using TSI.Utils;

namespace PRCo.BBS.BBSMonitor {

    /// <summary>
    /// Generates the BBScore report
    /// </summary>
    public class BBScoreReportEvent: BBSMonitorEvent {

        private const string SQL_SELECT_BBSCORE_REPORT =
            @"SELECT comp_CompanyID, pers_PersonID, dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_MiddleName, pers_PRNickName1, pers_Suffix) As FullName, comp_PRCorrTradestyle, RTRIM(emai_EmailAddress) AS Destination, prse_ServiceCode
                FROM Person_Link WITH (NOLOCK) 
	                INNER JOIN Person WITH (NOLOCK) ON peli_PersonID = pers_PersonID 
	                INNER JOIN Company WITH (NOLOCK) ON peli_CompanyID = comp_CompanyID 
                    INNER JOIN PRCompanyIndicators WITH (NOLOCK) ON peli_CompanyID = prci2_CompanyID
                    INNER JOIN PRService WITH (NOLOCK) ON prse_CompanyID = Comp_CompanyId AND prse_Primary='Y'
	                INNER JOIN vPersonEmail WITH (NOLOCK) ON peli_PersonID = elink_RecordID AND peli_CompanyID = emai_CompanyID AND elink_Type='E' AND emai_PRPreferredInternal = 'Y' 
                WHERE	comp_PRReceivesBBScoreReport = 'Y' 
                    AND peli_PRReceivesBBScoreReport = 'Y' 
                    AND peli_PRStatus='1'
                    AND comp_PRIndustryType IN ('P','S','T')
		            AND prse_ServiceCode in ({0})
                    AND prci2_Suspended IS NULL
                    AND emai_EmailAddress IS NOT NULL
                ORDER BY comp_CompanyID, pers_PersonID";

        private const string SQL_SELECT_BBSCORE_REPORT_LUMBER =
            @"SELECT comp_CompanyID, pers_PersonID,
                dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_MiddleName, pers_PRNickName1, pers_Suffix) As FullName, comp_PRCorrTradestyle, RTRIM(emai_EmailAddress) AS Destination,
                prwu_WebUserID
            FROM Person_Link WITH (NOLOCK)
                INNER JOIN Person WITH (NOLOCK) ON peli_PersonID = pers_PersonID
                INNER JOIN Company WITH (NOLOCK) ON peli_CompanyID = comp_CompanyID
                INNER JOIN PRCompanyIndicators WITH (NOLOCK) ON peli_CompanyID = prci2_CompanyID
                INNER JOIN PRWebUser WITH (NOLOCK) ON prwu_PersonLinkID = PeLi_PersonLinkId
                INNER JOIN (SELECT DISTINCT prwucl_WebUserID, 'Y' HasAUSList
						      FROM PRWebUserList WITH (NOLOCK)
							       INNER JOIN PRWebUserListDetail WITH (NOLOCK) ON prwucl_WebUserListID = prwuld_WebUserListID
						     WHERE prwucl_TypeCode='AUS') T1 ON prwu_WebUserID = prwucl_WebUserID
                INNER JOIN vPersonEmail WITH (NOLOCK) ON peli_PersonID = elink_RecordID AND peli_CompanyID = emai_CompanyID AND elink_Type='E' AND emai_PRPreferredInternal = 'Y'
            WHERE comp_PRReceivesBBScoreReport = 'Y'
                AND peli_PRReceivesBBScoreReport = 'Y'
                AND peli_PRStatus='1'
                AND comp_PRIndustryType = 'L'
			    AND prwu_ServiceCode IS NOT NULL
			    AND prwu_Disabled IS NULL
                AND prwu_AccessLevel > 300
                AND prci2_Suspended IS NULL
                AND emai_EmailAddress IS NOT NULL
            ORDER BY comp_CompanyID, pers_PersonID"; //L100 users can't receive reports

        private const string MSG_BBSCORE_SUMMARY = "{0:###,##0} BBReports reports delievered.\n - {1:###,##0} were emailed\n - {2:###,##0} were faxed";

        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex) {
            _szName = "BBScoreReport";

            base.Initialize(iIndex);
            
            try {
                //
                // Configure our BBScore Report
                //
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("BBScoreInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("BBScoreStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

                _oLogger.LogMessage("BBScoreReport Start: " + _dtNextDateTime.ToString());

            } catch (Exception e) {
                LogEventError("Error initializing BBScoreReport event.", e);
                throw;
            }
        }

        /// <summary>
        /// Process any BBScore reports.
        /// </summary>
        override public void ProcessEvent()
        {
            ProcessProduceReports();
            ProcessLumberReports();
        }

        private void ProcessProduceReports()
        {
            List<string> lErrors = new List<string>();
            List<string> lDetails = new List<string>();

            SqlConnection oConn = new SqlConnection(GetConnectionString());
            SqlTransaction oTran = null;

            try
            {
                oConn.Open();

                if (GetBoolCustomCaption(oConn, "BBSSuppressAUSandReport"))
                {
                    _oLogger.LogMessage("Skipping ProcessProduceReports() because flag BBSSuppressAUSandReport is set");
                    return;
                }

                _oLogger.LogMessage("Starting ProcessProduceReports()");

                DateTime dtLastBBScoreRunDate = GetDateTimeCustomCaption(oConn, "LastBBScoreRunDate");
                DateTime dtLastBBScoreReportDate = GetDateTimeCustomCaption(oConn, "LastBBScoreReportDate");

                if (dtLastBBScoreReportDate > dtLastBBScoreRunDate)
                {
                    _oLogger.LogMessage("dtLastBBScoreReportDate: " + dtLastBBScoreReportDate.ToString());
                    _oLogger.LogMessage("dtLastBBScoreRunDate: " + dtLastBBScoreRunDate.ToString());
                    _oLogger.LogMessage("Exiting ProcessProduceReports()");
                    return;
                }

                DateTime dtExecutionStartDate = DateTime.Now;

                List<ReportUser> lReportUser = new List<ReportUser>();
                lReportUser = GetBBSReportInfo(oConn);

                _oLogger.LogMessage($"lReportUser Produce Count: {lReportUser.Count}");

                if (lReportUser.Count == 0)
                    _oLogger.LogMessage("No Produce users found that need report");

                // Now go execute a report for each one of 
                // these and send it out
                string szMethod = null;

                int iReportCount = 0;
                int iErrorCount = 0;
                int iEmailCount = 0;
                int iFaxCount = 0;

                DateTime dtReportDate = GetDateTimeConfigValue("BBScoreReportDate", dtExecutionStartDate);

                int iMaxErrorCount = Utilities.GetIntConfigValue("BBScoreMaxErrorCount", 0);
                int iMaxReportCount = Utilities.GetIntConfigValue("BBScoreMaxReportCount", 999999999);

                string szSubject = Utilities.GetConfigValue("BBScoreSubject", "Your Blue Book Score Report is Attached");
                string szCategory = Utilities.GetConfigValue("BBScoreCategory", string.Empty);
                string szSubcategory = Utilities.GetConfigValue("BBScoreSubcategory", string.Empty);
                bool bDoNotRecordCommunication = Utilities.GetBoolConfigValue("BBScoreDoNotRecordCommunication", true);

                ReportInterface oReportInterface = new ReportInterface();
                byte[] abBBScoreReport = null;
                byte[] abBBScoreExport = null;
                byte[] abBBScoreExcel = null;
                List<string> attachments = new List<string>();

                foreach (ReportUser oReportUser in lReportUser)
                {
                    try
                    {
                        //oTran = oConn.BeginTransaction();

                        abBBScoreReport = null;
                        abBBScoreExport = null;
                        abBBScoreExcel = null;
                        attachments.Clear();

                        if (oReportUser.Invalid)
                        {
                            string[] aArgs = { "generating the BBScore report",
                                           oReportUser.PersonName,
                                           oReportUser.CompanyName,
                                           oReportUser.CompanyID.ToString(),
                                           "NULL BBScore Settings Found."};

                            lErrors.Add(string.Format(MSG_DETAIL_ERROR, aArgs));

                        }
                        else
                        {
                            iReportCount++;

                            abBBScoreReport = oReportInterface.GenerateBBScoreReport(oReportUser.CompanyID, dtReportDate);
                            attachments.Add(Utilities.GetConfigValue("BBScoreAttachmentName", "BBScore.pdf"));

                            List<byte[]> lReportFiles = new List<byte[]>();
                            lReportFiles.Add(abBBScoreReport);

                            if (oReportUser.MethodID == DELIVERY_METHOD_FAX)
                            {
                                iFaxCount++;
                                szMethod = "Fax";
                            }
                            else
                            {
                                iEmailCount++;
                                szMethod = "Email";

                                if (CSVFileEnabled)
                                {
                                    abBBScoreExport = oReportInterface.GenerateBBScoreExport(oReportUser.CompanyID, dtReportDate);
                                    lReportFiles.Add(abBBScoreExport);
                                    attachments.Add(Utilities.GetConfigValue("BBScoreExportAttachmentName", "BBScore.csv"));
                                }

                                if (ExcelFileEnabled)
                                {
                                    abBBScoreExcel = oReportInterface.GenerateBBScoreExcel(oReportUser.CompanyID, dtReportDate);
                                    lReportFiles.Add(abBBScoreExcel);
                                    attachments.Add(Utilities.GetConfigValue("BBScoreExcelAttachmentName", "BBScore.xlsx"));
                                }
                            }

                            _oLogger.LogMessage(string.Format("Sending to {0}, {1} at {2}", oReportUser.CompanyName, oReportUser.PersonName, oReportUser.Destination));

                            string szContent = string.Format(GetEmailTemplate("BBScoreContent.html"), oReportUser.PersonName, szMethod.ToLower(), dtReportDate.ToString("MMMM, yyyy"));
                            szContent = GetFormattedEmail(oConn, oTran, oReportUser.CompanyID, oReportUser.PersonID, szSubject, szContent);

                            oTran = oConn.BeginTransaction();
                            SendReport(oTran,
                                       oReportUser,
                                       szSubject,
                                       szContent,
                                       lReportFiles,
                                       attachments.ToArray(),
                                       szCategory,
                                       szSubcategory,
                                       bDoNotRecordCommunication,
                                       "BBScore Report Event",
                                       "HTML");
                            oTran.Commit();
                            oTran = null;


                            if (iReportCount >= iMaxReportCount)
                            {
                                _oLogger.LogMessage(string.Format("Stop sending reports because iReportCount ({0} >= iMaxReportCount ({1})", iReportCount, iMaxReportCount));
                                break;
                            }
                        }

                        // Commit and set to NULL.
                        //oTran.Commit();
                        //oTran = null;

                    }
                    catch (Exception e)
                    {

                        //if (oTran != null)
                        //{
                        //    oTran.Rollback();
                        //    oTran = null;
                        //}
                        LogEventError("Error Generating BBScore Report (Produce).", e);

                        string[] aArgs = { "generating the BBScore report (Produce)",
                                           oReportUser.PersonName,
                                           oReportUser.CompanyName,
                                           oReportUser.CompanyID.ToString(),
                                           e.Message};

                        lErrors.Add(string.Format(MSG_DETAIL_ERROR, aArgs));

                        // If we exceed our max error count, abort
                        // the entire operation.
                        iErrorCount++;
                        if (iErrorCount > iMaxErrorCount)
                        {
                            throw new ApplicationException("Maximum number of allowable errors exceeded.");
                        }
                    }
                }

                // Now summarize what happened and log 
                // it somewhere.
                StringBuilder sbMsg = new StringBuilder();

                object[] aMsgArgs = {iReportCount,
                                     iEmailCount,
                                     iFaxCount};
                sbMsg.Append(string.Format(MSG_BBSCORE_SUMMARY, aMsgArgs));

                AddListToBuffer(sbMsg, lErrors, "Errors");
                if (Utilities.GetBoolConfigValue("BBScoreSendResultsDetails", true))
                {
                    AddListToBuffer(sbMsg, lDetails, "Detail(s)");
                }

                UpdateDateTimeCustomCaption(oConn, "LastBBScoreReportDate", DateTime.Now);

                TimeSpan tsDiff = DateTime.Now.Subtract(dtExecutionStartDate);
                sbMsg.Append("\n\nExecution time: " + tsDiff.ToString());

                if (Utilities.GetBoolConfigValue("BBScoreWriteResultsToEventLog", true))
                {
                    _oBBSMonitorService.LogEvent(sbMsg.ToString());
                }

                if (Utilities.GetBoolConfigValue("BBScoreSendResultsToSupprt", true))
                {
                    SendMail("BBScore Reports Success (Produce)", sbMsg.ToString());
                }


            }
            catch (Exception e)
            {
                LogEventError("Error Processing BBScore Reports (Produce).", e);

                if (oTran != null)
                {
                    oTran.Rollback();
                }

                StringBuilder sbMsg = new StringBuilder();


                sbMsg.Append(MSG_ERROR);

                AddListToBuffer(sbMsg, lErrors, "Error(s)");

                sbMsg.Append("\n\n" + e.Message);
                sbMsg.Append("\n\n" + e.StackTrace);
                SendMail("BBScore Reports Error", sbMsg.ToString());

            }
            finally
            {
                if (oConn != null)
                {
                    oConn.Close();
                }

                oConn = null;
                lDetails = null;
                lErrors = null;
            }
        }
        private void ProcessLumberReports()
        {
            _oLogger.LogMessage("Starting ProcessLumberReports()");

            List<string> lErrors = new List<string>();
            List<string> lDetails = new List<string>();

            SqlConnection oConn = new SqlConnection(GetConnectionString());
            SqlTransaction oTran = null;
            try
            {
                oConn.Open();

                DateTime dtLastBBScoreRunDate_Lumber = GetDateTimeCustomCaption(oConn, "LastBBScoreRunDate_Lumber");
                DateTime dtLastBBScoreReportDate_Lumber = GetDateTimeCustomCaption(oConn, "LastBBScoreReportDate_Lumber");

                if (dtLastBBScoreReportDate_Lumber > dtLastBBScoreRunDate_Lumber)
                {
                    _oLogger.LogMessage("dtLastBBScoreReportDate_Lumber: " + dtLastBBScoreReportDate_Lumber.ToString());
                    _oLogger.LogMessage("dtLastBBScoreRunDate_Lumber: " + dtLastBBScoreRunDate_Lumber.ToString());
                    _oLogger.LogMessage("Exiting ProcessLumberReports()");
                    return;
                }

                DateTime dtExecutionStartDate = DateTime.Now;

                List<ReportUser> lReportUser = new List<ReportUser>();
                lReportUser = GetBBSReportInfo_Lumber(oConn);

                _oLogger.LogMessage($"lReportUser Lumber Count: {lReportUser.Count}");

                if (lReportUser.Count == 0)
                    _oLogger.LogMessage("No Lumber users found that need report");

                // Now go execute a report for each one of 
                // these and send it out
                string szMethod = null;

                int iReportCount = 0;
                int iErrorCount = 0;
                int iEmailCount = 0;
                int iFaxCount = 0;

                DateTime dtReportDate = GetDateTimeConfigValue("BBScoreReportDate_Lumber", dtExecutionStartDate);

                int iMaxErrorCount = Utilities.GetIntConfigValue("BBScoreMaxErrorCount", 0); 
                int iMaxReportCount = Utilities.GetIntConfigValue("BBScoreMaxReportCount", 999999999); 

                string szSubject = Utilities.GetConfigValue("BBScoreSubject", "Your Blue Book Score Report is Attached");
                string szCategory = Utilities.GetConfigValue("BBScoreCategory", string.Empty);
                string szSubcategory = Utilities.GetConfigValue("BBScoreSubcategory", string.Empty);
                bool bDoNotRecordCommunication = Utilities.GetBoolConfigValue("BBScoreDoNotRecordCommunication", true);

                ReportInterface oReportInterface = new ReportInterface();
                byte[] abBBScoreReport = null;
                List<string> attachments = new List<string>();

                foreach (ReportUser oReportUser in lReportUser)
                {
                    try
                    {
                        //oTran = oConn.BeginTransaction();

                        abBBScoreReport = null;
                        attachments.Clear();

                        if (oReportUser.Invalid)
                        {
                            string[] aArgs = { "generating the BBScore report",
                                           oReportUser.PersonName,
                                           oReportUser.CompanyName,
                                           oReportUser.CompanyID.ToString(),
                                           "NULL BBScore Settings Found."};

                            lErrors.Add(string.Format(MSG_DETAIL_ERROR, aArgs));
                        }
                        else
                        {
                            iReportCount++;

                            abBBScoreReport = oReportInterface.GenerateBBScoreReport_Lumber(oReportUser.CompanyID, dtReportDate, oReportUser.WebUserID);
                            attachments.Add(Utilities.GetConfigValue("BBScoreAttachmentName", "BBScore.pdf"));

                            List<byte[]> lReportFiles = new List<byte[]>();
                            lReportFiles.Add(abBBScoreReport);

                            if (oReportUser.MethodID == DELIVERY_METHOD_FAX)
                            {
                                iFaxCount++;
                                szMethod = "Fax";
                            }
                            else
                            {
                                iEmailCount++;
                                szMethod = "Email";
                            }

                            _oLogger.LogMessage(string.Format("Sending to {0}, {1} at {2}", oReportUser.CompanyName, oReportUser.PersonName, oReportUser.Destination));

                            string szContent = string.Format(GetEmailTemplate("BBScoreContentLumber.html"), oReportUser.PersonName, szMethod.ToLower(), dtReportDate.ToString("MMMM, yyyy"));
                            szContent = GetFormattedEmail(oConn, oTran, oReportUser.CompanyID, oReportUser.PersonID, szSubject, szContent);

                            oTran = oConn.BeginTransaction();
                            SendReport(oTran,
                                       oReportUser,
                                       szSubject,
                                       szContent,
                                       lReportFiles,
                                       attachments.ToArray(),
                                       szCategory,
                                       szSubcategory,
                                       bDoNotRecordCommunication,
                                       "BBScore Report Event",
                                       "HTML");
                            oTran.Commit();
                            oTran = null;


                            if (iReportCount >= iMaxReportCount)
                            {
                                _oLogger.LogMessage(string.Format("Stop sending reports because iReportCount ({0} >= iMaxReportCount ({1})", iReportCount, iMaxReportCount));
                                break;
                            }
                        }

                        // Commit and set to NULL.
                        //oTran.Commit();
                        //oTran = null;

                    }
                    catch (Exception e)
                    {

                        //if (oTran != null)
                        //{
                        //    oTran.Rollback();
                        //    oTran = null;
                        //}
                        LogEventError("Error Generating BBScore Report (Lumber).", e);

                        string[] aArgs = { "generating the BBScore report (Lumber)",
                                           oReportUser.PersonName,
                                           oReportUser.CompanyName,
                                           oReportUser.CompanyID.ToString(),
                                           e.Message};

                        lErrors.Add(string.Format(MSG_DETAIL_ERROR, aArgs));

                        // If we exceed our max error count, abort
                        // the entire operation.
                        iErrorCount++;
                        if (iErrorCount > iMaxErrorCount)
                        {
                            throw new ApplicationException("Maximum number of allowable errors exceeded.");
                        }
                    }
                }

                // Now summarize what happened and log 
                // it somewhere.
                StringBuilder sbMsg = new StringBuilder();

                object[] aMsgArgs = {iReportCount,
                                     iEmailCount,
                                     iFaxCount};
                sbMsg.Append(string.Format(MSG_BBSCORE_SUMMARY, aMsgArgs));

                AddListToBuffer(sbMsg, lErrors, "Errors");
                if (Utilities.GetBoolConfigValue("BBScoreSendResultsDetails", true))
                {
                    AddListToBuffer(sbMsg, lDetails, "Detail(s)");
                }

                UpdateDateTimeCustomCaption(oConn, "LastBBScoreReportDate_Lumber", DateTime.Now);

                TimeSpan tsDiff = DateTime.Now.Subtract(dtExecutionStartDate);
                sbMsg.Append("\n\nExecution time: " + tsDiff.ToString());

                if (Utilities.GetBoolConfigValue("BBScoreWriteResultsToEventLog", true))
                {
                    _oBBSMonitorService.LogEvent(sbMsg.ToString());
                }

                if (Utilities.GetBoolConfigValue("BBScoreSendResultsToSupprt", true))
                {
                    SendMail("BBScore Reports Success (Lumber)", sbMsg.ToString());
                }


            }
            catch (Exception e)
            {
                LogEventError("Error Processing BBScore Reports (Lumber).", e);

                if (oTran != null)
                {
                    oTran.Rollback();
                }

                StringBuilder sbMsg = new StringBuilder();


                sbMsg.Append(MSG_ERROR);

                AddListToBuffer(sbMsg, lErrors, "Error(s)");

                sbMsg.Append("\n\n" + e.Message);
                sbMsg.Append("\n\n" + e.StackTrace);
                SendMail("BBScore Reports Error", sbMsg.ToString());

            }
            finally
            {
                if (oConn != null)
                {
                    oConn.Close();
                }

                oConn = null;
                lDetails = null;
                lErrors = null;
            }
        }

        /// <summary>
        /// Populates the ReportUser object with the report header information (for non-lumber)
        /// </summary>
        /// <param name="oConn"></param>
        private List<ReportUser> GetBBSReportInfo(SqlConnection oConn) {
            List<ReportUser> lReportUsers = new List<ReportUser>();

            string szNonLumberServiceCodes = Utilities.GetConfigValue("BBScoreNonLumberServiceCodes"); //ex: 'BBS150', 'BBS200', 'BBS250', 'BBS300', 'BBS350', 'BBS355', 'BBS375', 'BBS395'

            SqlCommand oSQLCommand = new SqlCommand(string.Format(SQL_SELECT_BBSCORE_REPORT, szNonLumberServiceCodes), oConn);
            oSQLCommand.CommandTimeout = Utilities.GetIntConfigValue("BBScoreQueryTimeout", 300);
            SqlDataReader oReader = null;

            try {
                oReader = oSQLCommand.ExecuteReader();
                while (oReader.Read()) {
                    ReportUser oReportUser = new ReportUser(oReader.GetInt32(1), oReader.GetInt32(0));

                    lReportUsers.Add(oReportUser);

                    oReportUser.PersonName = oReader.GetString(2);
                    oReportUser.CompanyName = oReader.GetString(3);

                    oReportUser.Method = "email";
                    oReportUser.MethodID = DELIVERY_METHOD_EMAIL;

                    if (oReader[4] == DBNull.Value) {
                        oReportUser.Invalid = true;
                        oReportUser.Destination = "[NULL]";
                    } else {
                        oReportUser.Destination = oReader.GetString(4);
                    }
                }

                return lReportUsers;
            } finally {
                if (oReader != null) {
                    oReader.Close();
                }
            }
        }

        /// <summary>
        /// Populates the ReportUser object with the report header information (for lumber)
        /// </summary>
        /// <param name="oConn"></param>
        private List<ReportUser> GetBBSReportInfo_Lumber(SqlConnection oConn)
        {
            List<ReportUser> lReportUsers = new List<ReportUser>();

            SqlCommand oSQLCommand = new SqlCommand(SQL_SELECT_BBSCORE_REPORT_LUMBER, oConn);
            oSQLCommand.CommandTimeout = Utilities.GetIntConfigValue("BBScoreQueryTimeout", 300);
            SqlDataReader oReader = null;

            try
            {
                oReader = oSQLCommand.ExecuteReader();
                while (oReader.Read())
                {
                    ReportUser oReportUser = new ReportUser(oReader.GetInt32(1), oReader.GetInt32(0));

                    lReportUsers.Add(oReportUser);

                    oReportUser.PersonName = oReader.GetString(2);
                    oReportUser.CompanyName = oReader.GetString(3);
                    oReportUser.WebUserID = oReader.GetInt32(5);

                    oReportUser.Method = "email";
                    oReportUser.MethodID = DELIVERY_METHOD_EMAIL;

                    if (oReader[4] == DBNull.Value)
                    {
                        oReportUser.Invalid = true;
                        oReportUser.Destination = "[NULL]";
                    }
                    else
                    {
                        oReportUser.Destination = oReader.GetString(4);
                    }
                }

                return lReportUsers;
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }
        }

        private bool ExcelFileEnabled {
            get { return Utilities.GetBoolConfigValue("BBScoreReportExcelEnabled", false); }
        }

        private bool CSVFileEnabled {
            get { return Utilities.GetBoolConfigValue("BBScoreReportCSVEnabled", false); }
        }
    }
}
