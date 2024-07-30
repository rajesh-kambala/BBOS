/***********************************************************************
 Copyright Produce Reporter Company 2006-2013

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: BBSMonitor.cs
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
    /// Generates the AUS Settings report
    /// </summary>
    public class AUSSettingsReportEvent: AUSReportEventBase {

        protected DateTime _dtExecutionDate;

        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex) {
            _szName = "AUSSettingsReport";

            base.Initialize(iIndex);

            try {
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("AUSSettingsInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("AUSSettings Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("AUSSettingsStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _dtExecutionDate = Convert.ToDateTime(Utilities.GetConfigValue("AUSSettingsExecutionDateTime"));

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

            } catch (Exception e) {
                LogEventError("Error initializing AUSSettingsReport event.", e);
                throw;
            }
        }

        /// <summary>
        /// Process any AUS Settings reports.
        /// </summary>
        override public void ProcessEvent() {

            // Determine if we should execute today.  Ignore the year portion of our execution datetime.
            // Build a new date with the execution month and day, but the current year.
            DateTime dtTempDate = new DateTime(DateTime.Now.Year, _dtExecutionDate.Month, _dtExecutionDate.Day);
            if (dtTempDate != DateTime.Today) {
                return;
            }

            DateTime dtExecutionStartDate = DateTime.Now;

            List<ReportUser> lReportUser = new List<ReportUser>();
            List<string> lAUSErrors = new List<string>();
            List<string> lAUSDetails = new List<string>();

            SqlConnection oConn = new SqlConnection(GetConnectionString());
            SqlDataReader oReader = null;
            SqlTransaction oTran = null;

            try {

                oConn.Open();

                SqlCommand oSQLCommand = new SqlCommand(SQL_SELECT_AUS_SETTINGS, oConn);
                oSQLCommand.CommandTimeout = Utilities.GetIntConfigValue("AUSSettingsQueryTimeout", 300);

                try {
                    oReader = oSQLCommand.ExecuteReader();
                    while (oReader.Read()) {
                        ReportUser oReportUser = new ReportUser(oReader.GetInt32(0), oReader.GetInt32(1));
                        lReportUser.Add(oReportUser);
                    }
                } finally {
                    if (oReader != null) {
                        oReader.Close();
                    }
                }

                // Now go execte a report for each one of 
                // these and send it out
                int iReportCount = 0;
                int iErrorCount = 0;
                int iEmailCount = 0;
                int iFaxCount = 0;
                int iMaxErrorCount = Utilities.GetIntConfigValue("AUSSettingsMaxErrorCount", 0);
                int iMaxReportCount = Utilities.GetIntConfigValue("AUSSettingsMaxReportCount", 999999999);

                string szAttachmentName = Utilities.GetConfigValue("AUSSettingAttachmentName", "AUS_Setting_Report_{0}_{1}.pdf");
                string szSubject = Utilities.GetConfigValue("AUSSettingsSubject", "Blue Book Services AUS Settings Report");
                string szCategory = Utilities.GetConfigValue("AUSSettingsCategory", string.Empty);
                string szSubcategory = Utilities.GetConfigValue("AUSSettingsSubcategory", string.Empty);
                bool bDoNotRecordCommunication = Utilities.GetBoolConfigValue("AUSSettingsDoNotRecordCommunication", false);

                ReportInterface oReportInterface = new ReportInterface();
                byte[] abAUSSettingsReport = null;
                //oTran = oConn.BeginTransaction();

                foreach (ReportUser oReportUser in lReportUser) {
                    try {
                        abAUSSettingsReport = null;

                        GetAlertsReportHeader(oConn, oReportUser);

                        if (oReportUser.Invalid) {
                            string[] aArgs = { "generating the AUS Settings report", 
                                           oReportUser.PersonName, 
                                           oReportUser.CompanyName, 
                                           oReportUser.CompanyID.ToString(),
                                           "NULL AUS Settings Found."};

                            lAUSErrors.Add(string.Format(MSG_DETAIL_ERROR, aArgs));

                        } else {
                            iReportCount++;

                            string szContent = string.Format(GetEmailTemplate("AUSSettingsContent.txt"), oReportUser.PersonName, oReportUser.Method.ToLower(), dtExecutionStartDate.ToString("MMMM d, yyyy"));
                            if (oReportUser.MethodID == DELIVERY_METHOD_EMAIL)
                            {
                                szContent = GetFormattedEmail(oConn, oTran, oReportUser.CompanyID, oReportUser.PersonID, szSubject, szContent);
                            }

                            abAUSSettingsReport = oReportInterface.GenerateAUSSettingsReport(oReportUser.PersonID, oReportUser.CompanyID);
                            SendReport(oTran, 
                                       oReportUser,
                                       szSubject, 
                                       szContent, 
                                       abAUSSettingsReport,
                                       string.Format(szAttachmentName, oReportUser.CompanyID, oReportUser.PersonID),
                                       szCategory,
                                       szSubcategory,
                                       bDoNotRecordCommunication,
                                       "AUS Settings Report Event",
                                       "HTML");

                            if (iReportCount >= iMaxReportCount) {
                                break;
                            }
                        }
                    } catch (Exception e) {
                        LogEventError("Error Generating AUS Settings Report.", e);

                        string[] aArgs = { "generating the AUS Settings report", 
                                           oReportUser.PersonName, 
                                           oReportUser.CompanyName, 
                                           oReportUser.CompanyID.ToString(),
                                           e.Message};

                        lAUSErrors.Add(string.Format(MSG_DETAIL_ERROR, aArgs));

                        // If we exceed our max error count, abort
                        // the entire operation.
                        iErrorCount++;
                        if (iErrorCount > iMaxErrorCount) {
                            throw new ApplicationException("Maximum number of allowable errors exceeded.");
                        }
                    }
                }

                // Commit and set to NULL.
                oTran.Commit();
                oTran = null;

                // Now summarize what happened and log 
                // it somewhere.
                StringBuilder sbMsg = new StringBuilder();
                object[] aMsgArgs = {iReportCount,
                                     iEmailCount,
                                     iFaxCount};
                sbMsg.Append(string.Format(MSG_AUS_SETTINGS_SUMMARY, aMsgArgs));

                AddListToBuffer(sbMsg, lAUSErrors, "Error(s)");

                TimeSpan tsDiff = DateTime.Now.Subtract(dtExecutionStartDate);
                sbMsg.Append("\n\nExecution time: " + tsDiff.ToString());

                if (Utilities.GetBoolConfigValue("AUSSettingsWriteResultsToEventLog", true)) {
                    LogEvent(sbMsg.ToString());
                }

                if (Utilities.GetBoolConfigValue("AUSSettingsSendResultsToSupprt", true)) {
                    SendMail("AUS Settings Reports Success", sbMsg.ToString());
                }


            } catch (Exception e) {
                LogEventError("Error Procesing AUS Settings Reports.", e);

                if (oTran != null) {
                    oTran.Rollback();
                }

                StringBuilder sbMsg = new StringBuilder();

                sbMsg.Append(MSG_ERROR);

                AddListToBuffer(sbMsg, lAUSErrors, "Error(s)");

                sbMsg.Append("\n\n" + e.Message);
                sbMsg.Append("\n\n" + e.StackTrace);
                SendMail("AUS Settings Reports Error", sbMsg.ToString());

            } finally {
                if (oConn != null) {
                    oConn.Close();
                }

                oConn = null;
                lAUSErrors = null;
            }
        }
    }
}
