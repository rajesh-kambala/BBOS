/***********************************************************************
 Copyright Produce Reporter Company 2006-2014

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: TransactionListingReport.cs
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
    /// Provides the functionality to generate the internal
    /// BBS Open Transaction report.
    /// </summary>
    public class TransactionListingReportEvent : BBSMonitorEvent {

        private const string SQL_SELECT_OPEN_TRANS_REPORT = "SELECT DISTINCT user_userid, user_EmailAddress, RTRIM(user_firstname) + ' ' + RTRIM(user_lastname) FROM PRTransaction INNER JOIN Users on prtx_CreatedBy = user_UserID WHERE prtx_Status = 'O';";
        private const string MSG_OPEN_TRANS_DETAIL_ERROR = " - {0}: {1}\n";
        private const string MSG_OPEN_TRANS_SUMMARY = "{0:###,##0} Open Transaction Listing reports delievered.";

        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex) {
            _szName = "TransactionListingReport";

            base.Initialize(iIndex);

            try {
                //
                // Configure our TransactionListing Report
                //
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("OpenTransactionListingInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("OpenTransactionListing Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("OpenTransactionListingStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

                _oLogger.LogMessage("OpenTransactionListing Start: " + _dtNextDateTime.ToString());

            } catch (Exception e) {
                LogEventError("Error initializing OpenTransactionListing event.", e);
                throw;
            }
        }

        /// <summary>
        /// Process any Transaction Listing Reports reports.
        /// </summary>
        override public void ProcessEvent() {

            DateTime dtExecutionStartDate = DateTime.Now;

            List<ReportUser> lReportUser = new List<ReportUser>();
            List<string> lErrors = new List<string>();
            List<string> lDetails = new List<string>();

            SqlConnection oConn = new SqlConnection(GetConnectionString());

            try {
                oConn.Open();

                lReportUser = GetReportUsersInfo(oConn);

                int iReportCount = 0;
                int iErrorCount = 0;

                int iMaxErrorCount = Utilities.GetIntConfigValue("OpenTransactionListingMaxErrorCount", 0);
                int iMaxReportCount = Utilities.GetIntConfigValue("OpenTransactionListingReportCount", 999999999);
                string szAttachmentName = Utilities.GetConfigValue("OpenTransactionListingAttachmentName", "OpenTransactionReport.pdf");
                string szSubject = Utilities.GetConfigValue("OpenTransactionListingSubject", "BBS Open Transaction Report");

                ReportInterface oReportInterface = new ReportInterface();
                byte[] abOpenTransactionListingReport = null;


                foreach (ReportUser oReportUser in lReportUser) {
                    try {
                        abOpenTransactionListingReport = null;

                        if (oReportUser.Invalid) {
                            string[] aArgs = {"generating the Open Transaction Listing report", 
                                              oReportUser.PersonName,
                                              "NULL email address Found."};

                            lErrors.Add(string.Format(MSG_DETAIL_ERROR, aArgs));

                        } else {
                            iReportCount++;

                            abOpenTransactionListingReport = oReportInterface.GenerateOpenTransactionListingReport(oReportUser.UserID);
                            SendInternalEmail(oConn, szSubject, oReportUser.Destination, abOpenTransactionListingReport, szAttachmentName, "Transaction Listing Report Event");

                            if (iReportCount >= iMaxReportCount) {
                                break;
                            }
                        }

                    } catch (Exception e) {
                        LogEventError("Error Generating OpenTransactionListing Report.", e);

                        string[] aArgs = { oReportUser.Destination,
                                           e.Message};

                        lErrors.Add(string.Format(MSG_OPEN_TRANS_DETAIL_ERROR, aArgs));

                        // If we exceed our max error count, abort
                        // the entire operation.
                        iErrorCount++;
                        if (iErrorCount > iMaxErrorCount) {
                            throw new ApplicationException("Maximum number of allowable errors exceeded.");
                        }
                    }
                }

                // Now summarize what happened and log 
                // it somewhere.
                StringBuilder sbMsg = new StringBuilder();


                object[] aMsgArgs = {iReportCount};
                sbMsg.Append(string.Format(MSG_OPEN_TRANS_SUMMARY, aMsgArgs));

                AddListToBuffer(sbMsg, lErrors, "Errors");
                if (Utilities.GetBoolConfigValue("OpenTransactionListingSendResultsDetails", true)) {
                    AddListToBuffer(sbMsg, lDetails, "Detail(s)");
                }

                TimeSpan tsDiff = DateTime.Now.Subtract(dtExecutionStartDate);
                sbMsg.Append("\n\nExecution time: " + tsDiff.ToString());

                if (Utilities.GetBoolConfigValue("OpenTransactionListingWriteResultsToEventLog", true)) {
                    _oBBSMonitorService.LogEvent(sbMsg.ToString());
                }

                if (Utilities.GetBoolConfigValue("OpenTransactionListingSendResultsToSupport", true)) {
                    SendMail("OpenTransactionListing Reports Success", sbMsg.ToString());
                }


            } catch (Exception e) {
                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("Error Procesing OpenTransactionListing Reports.", e);
            } finally {
                if (oConn != null) {
                    oConn.Close();
                }

                oConn = null;
                lDetails = null;
                lErrors = null;
            }
        }

        /// <summary>
        /// Populates the ReportUser object with the report header
        /// information.
        /// </summary>
        /// <param name="oConn"></param>
        private List<ReportUser> GetReportUsersInfo(SqlConnection oConn) {

            List<ReportUser> lReportUsers = new List<ReportUser>();

            SqlCommand oSQLCommand = new SqlCommand(SQL_SELECT_OPEN_TRANS_REPORT, oConn);
            oSQLCommand.CommandTimeout = Utilities.GetIntConfigValue("OpenTransactionListingQueryTimeout", 300);
            SqlDataReader oReader = null;

            try {
                oReader = oSQLCommand.ExecuteReader();
                while (oReader.Read()) {
                    ReportUser oReportUser = new ReportUser();
                    lReportUsers.Add(oReportUser);

                    oReportUser.UserID   = oReader.GetInt32(0);
                    oReportUser.Method   = "email";
                    oReportUser.MethodID = DELIVERY_METHOD_EMAIL;

                    if (oReader[1] == DBNull.Value) {
                        oReportUser.Invalid = true;
                        oReportUser.Destination = "[NULL]";
                    } else {
                        oReportUser.Destination = oReader.GetString(1);
                    }
                }

                return lReportUsers;
            } finally {
                if (oReader != null) {
                    oReader.Close();
                }
            }
        }

    }
}
