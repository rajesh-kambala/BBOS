/***********************************************************************
 Copyright Produce Reporter Company 2006-2018

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: JeopardyLetterEvent.cs
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

namespace PRCo.BBS.BBSMonitor {

    /// <summary>
    /// Provides the functionality to generate the Jeopardy 1, Jeopardy 2
    /// and Jeopardy 3 letters.
    /// </summary>
    public class JeopardyLetterEvent : BBSMonitorEvent {

        
        private const string SQL_GET_USER_EMAIL = "SELECT user_EmailAddress FROM Users where user_UserID=@UserID";

        protected const string MSG_DETAIL = " - {0} sent to {1} via {2}.\n";

        private const string MSG_JEOPARDY_LETTER_SUMMARY = "\nSummary by Jeopardy Letter\n\nJeopardy Letter #1: {0:###,##0}\nJeopardy Letter #2: {1:###,##0}\nJeopardy Letter #3: {2:###,##0}\n";
        private const string MSG_JEOPARDY_LETTER_SUMMARY2= "\nSummary by Sent Method\n\nFax: {0:###,##0}\nEmail: {1:###,##0}\nPostal: {2:###,##0}\n";

        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex) {
            _szName = "JeopardyLetter";

            base.Initialize(iIndex);

            try {
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("JeopardyLetterInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("JeopardyLetter Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("JeopardyLetterStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

            } catch (Exception e) {
                LogEventError("Error initializing JeopardyLetter event.", e);
                throw;
            }
        }


        private ReportInterface oReportInterface;
    
       /// <summary>
       /// Process any BBScore reports.
       /// </summary>
        override public void ProcessEvent() {
            DateTime dtExecutionStartDate = DateTime.Now;

            StringBuilder sbMsg = new StringBuilder();
            int iLetter1Count = 0;
            int iLetter2Count = 0;
            int iLetter3Count = 0;

            // We can only execute on certain days
            // of the month
            if (!CanExecute(dtExecutionStartDate))
            {
                return;
            }

            string szAttachmentName = Utilities.GetConfigValue("JeopardyLetterAttachmentName", "JeopardyLetter_{0}.pdf");
            string szSubject = Utilities.GetConfigValue("JeopardyLetterSubject", "Blue Book Services Jeopardy Letter");
            bool bDoNotRecordCommunication = Utilities.GetBoolConfigValue("JeopardyLettersDoNotRecordCommunication", false);
            string szEmailTemplate = GetEmailTemplate("JeopardyLetterContent.html");
            string szCategory = Utilities.GetConfigValue("JeopardyLetterCategory", "R");
            string szSubcategory = null;


            oReportInterface = new ReportInterface();
            byte[] abJeopardyLetterReport = null;

            List<string> lErrors = new List<string>();
            List<string> lDetails = new List<string>();

            List<int> lLetter1PostalIDs = new List<int>();
            List<int> lLetter2PostalIDs = new List<int>();
            List<int> lLetter3PostalIDs = new List<int>();

            int iReportCount = 0;
            int iFaxCount = 0;
            int iEmailCount = 0;
            int iPostalCount = 0;
            int iErrorCount = 0;
            int iMaxErrorCount = Utilities.GetIntConfigValue("JeopardyLetterMaxErrorCount", 0);
            int iMaxReportCount = Utilities.GetIntConfigValue("JeopardyLetterMaxReportCount", 999999999);

            SqlTransaction sqlTran = null;
            using (SqlConnection sqlConn = new SqlConnection(GetConnectionString()))
            {

                try
                {

                    sqlConn.Open();
                    List<ReportUser> lReportUsers = GetReporUsers(sqlConn);

                    foreach (ReportUser reportUser in lReportUsers)
                    {
                        if (reportUser.Invalid)
                        {
                            string personName = "Person not found";
                            if (reportUser.PersonID > 0)
                            {
                                personName = reportUser.PersonName + " (" + reportUser.PersonID.ToString() + ")";
                            }


                            string[] aArgs = {"generating the Jeopardy Letter",
                                              personName,
                                              reportUser.CompanyName,
                                              reportUser.CompanyID.ToString(),
                                              "Jeopardy Letter Settings Not Found."};

                            lErrors.Add(string.Format(MSG_DETAIL_ERROR, aArgs));

                        }
                        else
                        {
                            iReportCount++;

                            sqlTran = sqlConn.BeginTransaction();
                            try
                            {

                                if (reportUser.MethodID == DELIVERY_METHOD_POSTAL)
                                {
                                    iPostalCount++;

                                    switch (reportUser.LetterType)
                                    {
                                        case "N1":
                                        case "T1":
                                            lLetter1PostalIDs.Add(reportUser.CompanyID);
                                            szSubcategory = "JL1";
                                            iLetter1Count++;
                                            break;
                                        case "N2":
                                        case "T2":
                                            lLetter2PostalIDs.Add(reportUser.CompanyID);
                                            szSubcategory = "JL2";
                                            iLetter2Count++;
                                            break;
                                        case "N3":
                                        case "T3":
                                            lLetter3PostalIDs.Add(reportUser.CompanyID);
                                            szSubcategory = "JL3";
                                            iLetter3Count++;
                                            break;
                                    }

                                    if (!bDoNotRecordCommunication)
                                    {
                                        SqlCommand cmdCreateTask = new SqlCommand("usp_CreateTask", sqlConn, sqlTran);
                                        cmdCreateTask.CommandType = CommandType.StoredProcedure;


                                        cmdCreateTask.Parameters.AddWithValue("CreatorUserId", -1);
                                        cmdCreateTask.Parameters.AddWithValue("TaskNotes", szSubject);
                                        cmdCreateTask.Parameters.AddWithValue("RelatedCompanyID", reportUser.CompanyID);
                                        if (reportUser.PersonID > 0)
                                        {
                                            cmdCreateTask.Parameters.AddWithValue("RelatedPersonID", reportUser.PersonID);
                                        }

                                        cmdCreateTask.Parameters.AddWithValue("StartDateTime", dtExecutionStartDate);
                                        cmdCreateTask.Parameters.AddWithValue("Action", "LetterOut");
                                        cmdCreateTask.Parameters.AddWithValue("Status", "Complete");
                                        cmdCreateTask.Parameters.AddWithValue("PRCategory", szCategory);
                                        cmdCreateTask.Parameters.AddWithValue("PRSubcategory", szSubcategory);
                                        cmdCreateTask.Parameters.AddWithValue("Subject", szSubject);
                                        cmdCreateTask.ExecuteNonQuery();
                                    }
                                }
                                else
                                {
                                    abJeopardyLetterReport = oReportInterface.GenerateJeopardyLetter(reportUser.CompanyID, reportUser.LetterType.Substring(1, 1));

                                    string szContent = null;
                                    if (reportUser.MethodID == DELIVERY_METHOD_FAX)
                                    {
                                        iFaxCount++;
                                    }
                                    else
                                    {
                                        iEmailCount++;
                                        szContent = GetFormattedEmail(sqlConn, sqlTran, reportUser.CompanyID, reportUser.PersonID, szSubject, szEmailTemplate);
                                    }

                                    switch (reportUser.LetterType)
                                    {
                                        case "N1":
                                        case "T1":
                                            szSubcategory = "JL1";
                                            iLetter1Count++;
                                            break;
                                        case "N2":
                                        case "T2":
                                            szSubcategory = "JL2";
                                            iLetter2Count++;
                                            break;
                                        case "N3":
                                        case "T3":
                                            szSubcategory = "JL3";
                                            iLetter3Count++;
                                            break;
                                    }

                                    _oLogger.LogMessage(string.Format("Sending to {0}, {1} at {2}", reportUser.CompanyName, reportUser.PersonName, reportUser.Destination));

                                    SendReport(sqlTran,
                                            reportUser,
                                            szSubject,
                                            szContent,
                                            abJeopardyLetterReport,
                                            string.Format(szAttachmentName, reportUser.CompanyID),
                                            szCategory,
                                            szSubcategory,
                                            bDoNotRecordCommunication,
                                            "Jeopardy Letter Event",
                                            "HTML");
                                }

                                string[] aArgs = { reportUser.LetterType,
                                                   reportUser.CompanyID.ToString(),
                                                   reportUser.Method};
                                lDetails.Add(string.Format(MSG_DETAIL, aArgs));


                                // Commit and set to NULL.
                                sqlTran.Commit();
                                sqlTran = null;

                            }
                            catch (Exception e)
                            {

                                if (sqlTran != null)
                                {
                                    sqlTran.Rollback();
                                }

                                LogEventError("Error Generating Jeopardy Letter Report.", e);

                                string[] aArgs = { "generating the Jeopardy Letter report",
                                               reportUser.PersonName  + " (" + reportUser.PersonID.ToString() + ")",
                                               reportUser.CompanyName,
                                               reportUser.CompanyID.ToString(),
                                               e.Message};

                                lErrors.Add(string.Format(MSG_DETAIL_ERROR, aArgs));

                                // If we exceed our max error count, abort
                                // the entire operation.
                                iErrorCount++;
                                if (iErrorCount > iMaxErrorCount)
                                {
                                    if (lErrors.Count > 0)
                                    {
                                        sbMsg.Append(Environment.NewLine + "The following letters could not be generated." + Environment.NewLine);
                                        foreach (string error in lErrors)
                                        {
                                            sbMsg.Append(error + Environment.NewLine);
                                        }
                                    }

                                    throw new ApplicationException("Maximum number of allowable errors exceeded.");
                                }
                            }

                        }


                        if (iReportCount >= iMaxReportCount)
                        {
                            break;
                        }
                    } // End ForEach


                    byte[] abPostalJeopardyLetter1 = GetJeopardyLetterList(lLetter1PostalIDs, 1);
                    byte[] abPostalJeopardyLetter2 = GetJeopardyLetterList(lLetter2PostalIDs, 2);
                    byte[] abPostalJeopardyLetter3 = GetJeopardyLetterList(lLetter3PostalIDs, 3);


                    List<EmailAttachment> attachments = new List<EmailAttachment>();
                    if (abPostalJeopardyLetter1 != null)
                    {
                        attachments.Add(new EmailAttachment("Jeopardy Letters - 1.pdf", abPostalJeopardyLetter1));
                    }
                    if (abPostalJeopardyLetter2 != null)
                    {
                        attachments.Add(new EmailAttachment("Jeopardy Letters - 2.pdf", abPostalJeopardyLetter2));
                    }
                    if (abPostalJeopardyLetter3 != null)
                    {
                        attachments.Add(new EmailAttachment("Jeopardy Letters - 3.pdf", abPostalJeopardyLetter3));
                    }

                    object[] aMsgArgs = {iLetter1Count,
                                             iLetter2Count,
                                             iLetter3Count};

                    sbMsg.Append(string.Format(MSG_JEOPARDY_LETTER_SUMMARY, aMsgArgs));

                    object[] aMsgArgs2 = {iFaxCount,
                                             iEmailCount,
                                             iPostalCount};

                    sbMsg.Append(string.Format(MSG_JEOPARDY_LETTER_SUMMARY2, aMsgArgs2));

                    if (lErrors.Count > 0)
                    {
                        sbMsg.Append(Environment.NewLine + "The following letters could not be generated." + Environment.NewLine);
                        foreach (string error in lErrors)
                        {
                            sbMsg.Append(error + Environment.NewLine);
                        }
                    }
                    

                    string content = "Jeopardy Letters Successfully Generated and sent.\n" + sbMsg.ToString() + "\n\n Please print and send the attached letters.";
                    string szEmailAddress = Utilities.GetConfigValue("JeopardyLetterPostalMailingEmailAddress", "cwalls@travant.com");
                    SendInternalEmail(sqlConn, null, szSubject, szEmailAddress, content, attachments, "Jeopardy Letter Event");

                }
                catch (Exception e)
                {
                    // This logs the error in the Event Log, Trace File,
                    // and sends the appropriate email.
                    LogEventError("Error Procesing JeopardyLetter Reports.", e);
                }
            }

            // Now summarize what happened and log 
            // it somewhere.
            TimeSpan tsDiff = DateTime.Now.Subtract(dtExecutionStartDate);
            sbMsg.Append("\n\nExecution time: " + tsDiff.ToString());

            if (Utilities.GetBoolConfigValue("JeopardyLetterWriteResultsToEventLog", true)) {
                _oBBSMonitorService.LogEvent(sbMsg.ToString());
            }

            if (Utilities.GetBoolConfigValue("JeopardyLetterSendResultsToSupport", true)) {
                SendMail("JeopardyLetter Reports Success", sbMsg.ToString());
            }
        }

        private const string SQL_GetCompaniesForJeopardyLetter = "usp_GetCompaniesForJeopardyLetter";

        private byte[] GetJeopardyLetterList(List<int> companyIDs, int letterType)
        {
            byte[] jepLetterList = null;
            if (companyIDs.Count > 0)
            {
                string szCompanyIDs = string.Join(",", companyIDs);
                jepLetterList = oReportInterface.GenerateJeopardyLetters(szCompanyIDs, letterType.ToString());
            }

            return jepLetterList;
        }

        private List<ReportUser> GetReporUsers(SqlConnection sqlConn)
        {
            SqlCommand sqlCommand = new SqlCommand(SQL_GetCompaniesForJeopardyLetter, sqlConn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = Utilities.GetIntConfigValue("JeopardyLetterQueryTimeout", 300);

            List<ReportUser> lReportUsers = new List<ReportUser>();
            using (SqlDataReader reader = sqlCommand.ExecuteReader())
            {
                while (reader.Read())
                {
                    ReportUser reportUser = new ReportUser();
                    lReportUsers.Add(reportUser);

                    reportUser.CompanyID = GetInt(reader["CompanyID"]);
                    reportUser.CompanyName = GetString(reader["CompanyName"]);

                    reportUser.PersonID = GetInt(reader["PersonID"]);
                    reportUser.PersonName = GetString(reader["Addressee"]);

                    if (reader["CommType"] == DBNull.Value)
                    {
                        reportUser.Invalid = true;
                    } else
                    {
                        if (reader["CommType"].ToString() == "FaxOut")
                        {
                            reportUser.Method = "fax";
                            reportUser.MethodID = DELIVERY_METHOD_FAX;
                            reportUser.Destination = GetString(reader["Fax"]);

                            if (string.IsNullOrEmpty(reportUser.Destination))
                            {
                                reportUser.Invalid = true;
                            }
                        }

                        if (reader["CommType"].ToString() == "EmailOut")
                        {
                            reportUser.Method = "email";
                            reportUser.MethodID = DELIVERY_METHOD_EMAIL;
                            reportUser.Destination = GetString(reader["Email"]);

                            if (string.IsNullOrEmpty(reportUser.Destination))
                            {
                                reportUser.Invalid = true;
                            }
                        }

                        if (reader["CommType"].ToString() == "LetterOut")
                        {
                            reportUser.MethodID = DELIVERY_METHOD_POSTAL;
                        }



                    }

                    reportUser.LetterType = GetString(reader["LetterType"]);
                }
            }

            return lReportUsers;
        }

        private bool CanExecute(DateTime dtDate)
        {
            int iOccurence = Utilities.GetIntConfigValue("JeopardyLetterOccurenceInMonth", 1);
            DayOfWeek targetDayOfWeek = (DayOfWeek)Enum.ToObject(typeof(DayOfWeek),
                                                                 Utilities.GetIntConfigValue("JeopardyLetterDayOfWeek", 2));

            if (dtDate.DayOfWeek == targetDayOfWeek)
            {
                int iStart = 1 + ((iOccurence - 1) * 7);
                int iEnd = iStart + 6;

                if ((dtDate.Day >= iStart) &&
                    (dtDate.Day <= iEnd))
                {
                    return true;
                }
            }

            return false;
        }
    }
}
