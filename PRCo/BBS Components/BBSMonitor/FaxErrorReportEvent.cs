/***********************************************************************
 Copyright Blue Book Services, Inc. 2010

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: RightFaxErrorReportEvent.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Timers;
using TSI.Utils;

namespace PRCo.BBS.BBSMonitor
{
    public class FaxErrorReportEvent : BBSMonitorEvent
    {
        private const string MSG_FAX_ERROR_REPORT_DETAIL_ERROR = " - {0}: {1}\n";
        private const string MSG_FAX_ERROR_REPORT_SUMMARY = "{0:###,##0} Fax Error reports delievered.";

        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex)
        {
            _szName = "FaxErrorReport";

            base.Initialize(iIndex);

            try
            {
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("FaxErrorReportInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("FaxErrorReport Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("FaxErrorReportStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

                _oLogger.LogMessage("FaxErrorReport Start: " + _dtNextDateTime.ToString());

            }
            catch (Exception e)
            {
                LogEventError("Error initializing FaxErrorReport event.", e);
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

                int iMaxErrorCount = Utilities.GetIntConfigValue("FaxErrorReportMaxErrorCount", 0);
                int iMaxReportCount = Utilities.GetIntConfigValue("FaxErrorReportReportCount", 999999999);
                string szAttachmentName = Utilities.GetConfigValue("FaxErrorReportAttachmentName", "FaxErrors.pdf");
                string szSubject = Utilities.GetConfigValue("FaxErrorReportSubject", "Fax Errors Report");

                ReportInterface oReportInterface = new ReportInterface();
                byte[] abFaxErrorReport = null;

                int iDaysThreshold = Utilities.GetIntConfigValue("FaxErrorReportDaysThreshold", 1);

                foreach (ReportUser oReportUser in lReportUser) {
                    try {
                        abFaxErrorReport = null;

                        if (oReportUser.Invalid) {
                            string[] aArgs = {"generating the Fax Error report", 
                                              oReportUser.PersonName,
                                              "NULL email address Found."};

                            lErrors.Add(string.Format(MSG_DETAIL_ERROR, aArgs));

                        } else {
                            iReportCount++;

                            abFaxErrorReport = oReportInterface.GenerateFaxErrorsByUserReport(oReportUser.Logon, iDaysThreshold);
                            SendInternalEmail(oConn, szSubject, oReportUser.Destination, abFaxErrorReport, szAttachmentName, "Fax Error Report Event");

                            if (iReportCount >= iMaxReportCount) {
                                break;
                            }
                        }

                    } catch (Exception e) {
                        LogEventError("Error Generating FaxError Report.", e);

                        string[] aArgs = { oReportUser.Destination,
                                           e.Message};

                        lErrors.Add(string.Format(MSG_FAX_ERROR_REPORT_DETAIL_ERROR, aArgs));

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
                sbMsg.Append(string.Format(MSG_FAX_ERROR_REPORT_SUMMARY, aMsgArgs));

                AddListToBuffer(sbMsg, lErrors, "Errors");
                if (Utilities.GetBoolConfigValue("FaxErrorReportSendResultsDetails", true))
                {
                    AddListToBuffer(sbMsg, lDetails, "Detail(s)");
                }

                TimeSpan tsDiff = DateTime.Now.Subtract(dtExecutionStartDate);
                sbMsg.Append("\n\nExecution time: " + tsDiff.ToString());

                if (Utilities.GetBoolConfigValue("FaxErrorReportWriteResultsToEventLog", true))
                {
                    _oBBSMonitorService.LogEvent(sbMsg.ToString());
                }

                if (Utilities.GetBoolConfigValue("FaxErrorReportSendResultsToSupport", true))
                {
                    SendMail("Fax Error Report Success", sbMsg.ToString());
                }


            } catch (Exception e) {
                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("Error Procesing Fax Error Reports.", e);
            } finally {
                if (oConn != null) {
                    oConn.Close();
                }

                oConn = null;
                lDetails = null;
                lErrors = null;
            }
        }


        private const string SQL_SELECT_FAX_ERROR_USERS =
            "SELECT user_userid, user_EmailAddress, user_Logon, " +
                   "COUNT(DISTINCT Destination) As DistinctFaxCount,  " +
                   "COUNT(1) As ErrorCount " +
              "FROM ARToo.RightFax.dbo.Documents d " +
                   "INNER JOIN ARToo.RightFax.dbo.Users u on u.handle = OwnerID " +
                   "INNER JOIN Users ON UserID = user_Logon " +
             "WHERE ErrorCode > 0 " +
               "AND CreationTime >= DATEADD(day, 0-@DaysThreshold, GETDATE()) " +
               "AND user_EmailAddress IS NOT NULL " +
          "GROUP BY user_userid, user_EmailAddress, user_Logon " +
            "HAVING COUNT(1) >= 0 " +
          "ORDER BY user_userid; ";


        /// <summary>
        /// Populates the ReportUser object with the report header
        /// information.
        /// </summary>
        /// <param name="oConn"></param>
        private List<ReportUser> GetReportUsersInfo(SqlConnection oConn) {

            List<ReportUser> lReportUsers = new List<ReportUser>();


            SqlCommand oSQLCommand = new SqlCommand(SQL_SELECT_FAX_ERROR_USERS, oConn);
            oSQLCommand.Parameters.AddWithValue("DaysThreshold", Utilities.GetIntConfigValue("FaxErrorReportDaysThreshold", 1));
            SqlDataReader oReader = null;

            try {
                oReader = oSQLCommand.ExecuteReader();
                while (oReader.Read()) {
                    ReportUser oReportUser = new ReportUser();
                    lReportUsers.Add(oReportUser);

                    oReportUser.UserID   = oReader.GetInt32(0);
                    oReportUser.Method   = "email";
                    oReportUser.MethodID = DELIVERY_METHOD_EMAIL;
                    oReportUser.Logon = oReader.GetString(2);

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
