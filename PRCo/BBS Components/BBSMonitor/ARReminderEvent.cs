/***********************************************************************
 Copyright Blue Book Services, Inc. 2016-2018

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: ARReminderEvent.cs
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
    public class ARReminderEvent : BBSMonitorEvent
    {
        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex)
        {
            _szName = "ARReminderEvent";

            base.Initialize(iIndex);

            try
            {
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("ARReminderInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("ARReminder Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("ARReminderStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

                _oLogger.LogMessage("ARReminder Start: " + _dtNextDateTime.ToString());

            }
            catch (Exception e)
            {
                LogEventError("Error initializing ARReminder event.", e);
                throw;
            }
        }

        override public void ProcessEvent()
        {

            DateTime dtExecutionStartDate = DateTime.Now;

            int level1CountProduce = 0;
            int level2CountProduce = 0;
            int level3CountProduce = 0;

            int level1CountLumber = 0;
            int level2CountLumber = 0;
            int level3CountLumber = 0;

            int companyCount = 0;

            SqlConnection sqlConn = new SqlConnection(GetConnectionString());
            SqlTransaction sqlTran = null;

            try
            {
                sqlConn.Open();

                int level1Threshold = Utilities.GetIntConfigValue("ARReminderLevel1Days", 35);
                int level2Threshold = Utilities.GetIntConfigValue("ARReminderLevel2Days", 45);
                int level3Threshold = Utilities.GetIntConfigValue("ARReminderLevel3Days", 60);

                List<ReportUser> reportUsers = GetReportUsers(sqlConn, level1Threshold, 0);
                reportUsers.AddRange(GetReportUsers(sqlConn, level2Threshold, 1));
                companyCount = reportUsers.Count;

                string szBBOSURL = Utilities.GetConfigValue("BBOSURL", "https://apps.bluebookservices.com/bbos");

                string szSubjectLevel1 = Utilities.GetConfigValue("ARReminderLevel1Subject", "Update AR Aging File Reminder");
                string szSubjectLevel2 = Utilities.GetConfigValue("ARReminderLevel1Subject", "Update AR Aging File Request");
                string szEmailTemplateLevel1Produce = string.Format(GetEmailTemplate("ARReminderLevel1ContentProduce.html"), szBBOSURL);
                string szEmailTemplateLevel2Produce = string.Format(GetEmailTemplate("ARReminderLevel2ContentProduce.html"), szBBOSURL);
                string szEmailTemplateLevel1Lumber = string.Format(GetEmailTemplate("ARReminderLevel1ContentLumber.html"), szBBOSURL);
                string szEmailTemplateLevel2Lumber = string.Format(GetEmailTemplate("ARReminderLevel2ContentLumber.html"), szBBOSURL);

                string szCategory = Utilities.GetConfigValue("ARReminderCategory", "ARSub");
                string szSubcategory = Utilities.GetConfigValue("ARReminderSubcategory", "ARR");
                string emailContent = null;
                string szSubject = null;

                string invalidUsers = string.Empty;
                int invalidCount = 0;

                foreach (ReportUser reportUser in reportUsers)
                {
                    if (reportUser.Invalid)
                    {
                        invalidUsers += string.Format("BBID {0} - No email address found." + Environment.NewLine, reportUser.CompanyID);
                        invalidCount++;
                    } else { 
                        sqlTran = sqlConn.BeginTransaction();

                        _oLogger.LogMessage(string.Format("Sending to {0}, {1} at {2}", reportUser.CompanyName, reportUser.PersonName, reportUser.Destination));


                        if (reportUser.Level == 1 && reportUser.IndustryType == "P")
                        {
                            emailContent = szEmailTemplateLevel1Produce;
                            szSubject = szSubjectLevel1;
                            level1CountProduce++;
                        } else if (reportUser.Level == 2 && reportUser.IndustryType == "P")
                        {
                            emailContent = szEmailTemplateLevel2Produce;
                            szSubject = szSubjectLevel2;
                            level2CountProduce++;
                        }
                        else if (reportUser.Level == 1 && reportUser.IndustryType == "L")
                        {
                            emailContent = szEmailTemplateLevel1Lumber;
                            szSubject = szSubjectLevel1;
                            level1CountLumber++;
                        }
                        else if (reportUser.Level == 2 && reportUser.IndustryType == "L")
                        {
                            emailContent = szEmailTemplateLevel2Lumber;
                            szSubject = szSubjectLevel2;
                            level2CountLumber++;
                        }

                        string formattedEmail = GetFormattedEmail(sqlConn, sqlTran, reportUser.CompanyID, reportUser.PersonID, szSubject, emailContent);
                        SendEmail(sqlTran,
                                    reportUser,
                                    szSubject,
                                    formattedEmail,
                                    szCategory,
                                    szSubcategory,
                                    false,
                                    "AR Reminder Event",
                                    "HTML");
                        sqlTran.Commit();
                    }
                }

                reportUsers = GetReportUsers(sqlConn, level3Threshold, 2);
                companyCount = companyCount + reportUsers.Count;

                int iAssignedToUserID = 0;
                szSubject = Utilities.GetConfigValue("ARReminderLevel1Subject", "Delinquent AR Submitter");
                string msg = string.Format("Subject aging submitter is now {0} days beyond last received file – Call for update.", level3Threshold);
                

                SqlCommand cmdCreateTask = new SqlCommand("usp_CreateTask", sqlConn, sqlTran);
                cmdCreateTask.CommandType = CommandType.StoredProcedure;

                foreach (ReportUser reportUser in reportUsers)
                {

                    if (reportUser.IndustryType == "P")
                    {
                        level3CountProduce++;
                        iAssignedToUserID = Utilities.GetIntConfigValue("ARReminderTaskProduceUserID", 19); // DTM
                    }
                    else
                    {
                        level3CountLumber++;
                        iAssignedToUserID = Utilities.GetIntConfigValue("ARReminderTaskLumberUserID", 1022); // ZMC
                    }

                    cmdCreateTask.Parameters.Clear();
                    cmdCreateTask.Parameters.AddWithValue("AssignedToUserId", iAssignedToUserID);
                    cmdCreateTask.Parameters.AddWithValue("CreatorUserId", -1);
                    cmdCreateTask.Parameters.AddWithValue("TaskNotes", msg);
                    cmdCreateTask.Parameters.AddWithValue("RelatedCompanyID", reportUser.CompanyID);
                    if (reportUser.PersonID > 0)
                    {
                        cmdCreateTask.Parameters.AddWithValue("RelatedPersonID", reportUser.PersonID);
                    }

                    cmdCreateTask.Parameters.AddWithValue("StartDateTime", dtExecutionStartDate);
                    cmdCreateTask.Parameters.AddWithValue("Action", "ToDo");
                    cmdCreateTask.Parameters.AddWithValue("Status", "Pending");
                    cmdCreateTask.Parameters.AddWithValue("PRCategory", szCategory);
                    cmdCreateTask.Parameters.AddWithValue("PRSubcategory", szSubcategory);
                    cmdCreateTask.Parameters.AddWithValue("Subject", szSubject);
                    cmdCreateTask.ExecuteNonQuery();

                }

                msg = string.Format("{0} companies processed successfully.", companyCount);
                if (Utilities.GetBoolConfigValue("ARReminderWriteResultsToEventLog", true))
                {
                    _oBBSMonitorService.LogEvent("AR Reminder Event Executed Successfully. " + msg);
                }


                if (companyCount > 0)
                {

                    msg += Environment.NewLine + Environment.NewLine;
                    msg += "Produce" + Environment.NewLine;
                    msg += string.Format("Level 1: {0}", level1CountProduce) + Environment.NewLine;
                    msg += string.Format("Level 2: {0}", level2CountProduce) + Environment.NewLine;
                    msg += string.Format("Level 3: {0}", level3CountProduce) + Environment.NewLine + Environment.NewLine;

                    msg += "Lumber" + Environment.NewLine;
                    msg += string.Format("Level 1: {0}", level1CountLumber) + Environment.NewLine;
                    msg += string.Format("Level 2: {0}", level2CountLumber) + Environment.NewLine;
                    msg += string.Format("Level 3: {0}", level3CountLumber) + Environment.NewLine + Environment.NewLine;

                    if (!string.IsNullOrEmpty(invalidUsers))
                    {
                        msg += string.Format("Unable to Notify {0} Companies.", invalidCount) + Environment.NewLine;
                        msg += invalidUsers;
                    }


                    if (Utilities.GetBoolConfigValue("ARReminderSendResultsToSupport", false))
                    {
                        SendMail("AR Reminder Event", "ARReminder Executed Successfully. " + msg);
                    }

                    if (!string.IsNullOrEmpty(invalidUsers))
                    {
                        SendMail(Utilities.GetConfigValue("ARReminderIssuesEmail", "dmartin@bluebookservices.com"), "AR Reminder Event Issues", "ARReminder Executed Successfully. " + msg);
                    }

                }
            }
            catch (Exception e)
            {
                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("Error Procesing ARReminder Event.", e);
            }
            finally
            {
                if (sqlConn != null)
                {
                    sqlConn.Close();
                }

                sqlConn = null;
            }
        }
        
        private const string SQL_AR_REMINDER_2 =
                  @"SELECT comp_CompanyID,
                        Company.comp_Name,
                        comp_PRIndustryType,
                        ISNULL(prattn_PersonID, 0) prattn_PersonID, 
                        Addressee,
                        DeliveryAddress,
                        ISNULL(CommCount, 0) as CommCount,
					    MostRecentARDate,
					    prc5_ARLastSubmittedDate,
					    dbo.ufn_GetMostRecentDate(MostRecentARDate,prc5_ARLastSubmittedDate) CompareDate
                    FROM Company WITH (NOLOCK)
                        INNER JOIN PRCompanyInfoProfile WITH (NOLOCK) ON comp_CompanyID = prc5_CompanyID
                        LEFT OUTER JOIN (
                                            SELECT praa_CompanyID, MAX(praa_CreatedDate) as MostRecentARDate 
										    FROM (
											        SELECT praa_CompanyID, praa_CreatedDate
											        FROM Company WITH (NOLOCK)
													INNER JOIN CRM.dbo.PRARAging WITH (NOLOCK) ON comp_CompanyID = praa_CompanyID

											        UNION

											        SELECT praa_CompanyID, praa_CreatedDate
											        FROM Company WITH (NOLOCK)
													INNER JOIN CRMArchive.dbo.PRARAging WITH (NOLOCK) ON comp_CompanyID = praa_CompanyID
											     ) T1	
                                            GROUP BY praa_CompanyID
                                        ) T3 ON comp_CompanyID = praa_CompanyID
                      
                        LEFT OUTER JOIN vPRCompanyAttentionLine ON comp_CompanyID = prattn_CompanyID AND prattn_ItemCode = 'ARD'
                        LEFT OUTER JOIN (
                                            SELECT cmli_comm_CompanyID,
							                    COUNT(1) as CommCount
						                    FROM vCommunication
                                            LEFT JOIN (
                                                            SELECT praa_CompanyID, MAX(praa_CreatedDate) as MostRecentARDate 
		                                                    FROM PRARAging WITH (NOLOCK) 
                                                            GROUP BY praa_CompanyID
                                                      ) T3 ON cmli_comm_CompanyID = praa_CompanyID
                                            LEFT JOIN (
												            SELECT prc5_CompanyId, MAX(prc5_ARLastSubmittedDate) as prc5_ARLastSubmittedDate 
												            FROM PRCompanyInfoProfile WITH (NOLOCK) 
												            GROUP BY prc5_CompanyId
                                                      ) T4 ON cmli_comm_CompanyID = prc5_CompanyId
						                    WHERE comm_PRCategory = 'ARSub'
						                        AND comm_PRSubcategory = 'ARR'
						                        AND comm_CreatedDate >= ISNULL(dbo.ufn_GetMostRecentDate(MostRecentARDate,prc5_ARLastSubmittedDate), DATEADD(day, {0}, GETDATE()))  -- Created since the last AR upload
						                        AND comm_CreatedBy = -1  -- System Generated
						                    GROUP BY cmli_comm_CompanyID
                                        ) T2 ON comp_CompanyID = T2.cmli_comm_CompanyID
                        WHERE prc5_ARSubmitter = 'Y'
                            AND prc5_ReceiveARReminder = 'Y'
                            AND ISNULL(CommCount, 0) = {1}
                            AND (dbo.ufn_GetMostRecentDate(MostRecentARDate,prc5_ARLastSubmittedDate) IS NULL
                                OR dbo.ufn_GetMostRecentDate(MostRecentARDate,prc5_ARLastSubmittedDate) < DATEADD(day, {0}, GETDATE()))";

        private List<ReportUser> GetReportUsers(SqlConnection sqlConn, int daysThreshold, int previousNotificationCount)
        {

            List<ReportUser> lReportUsers = new List<ReportUser>();

            SqlCommand sqlCommand = new SqlCommand(string.Format(SQL_AR_REMINDER_2, 0-daysThreshold, previousNotificationCount), sqlConn);
            using (SqlDataReader reader = sqlCommand.ExecuteReader())
            {
                while (reader.Read())
                {
                    ReportUser oReportUser = new ReportUser(reader.GetInt32(3), reader.GetInt32(0));
                    lReportUsers.Add(oReportUser);

                    oReportUser.PersonName = GetString(reader[4]);
                    oReportUser.CompanyName = GetString(reader[1]);
                    oReportUser.Method = "email";
                    oReportUser.MethodID = DELIVERY_METHOD_EMAIL;
                    oReportUser.Destination = GetString(reader[5]);
                    if (GetString(reader[2]) != "L")
                    {
                        oReportUser.IndustryType = "P";
                    } else
                    {
                        oReportUser.IndustryType = GetString(reader[2]);
                    }

                    if (string.IsNullOrEmpty(oReportUser.Destination))
                    {
                        oReportUser.Invalid = true;
                    }

                    oReportUser.Level = previousNotificationCount + 1;
                }
            }
            return lReportUsers;
        }
    }
}

