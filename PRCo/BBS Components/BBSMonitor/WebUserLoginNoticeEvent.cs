/***********************************************************************
 Copyright Blue Book Services, Inc. 2019-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: WebUserLoginNoticeEvent.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Timers;
using System.Text;
using TSI.Utils;

namespace PRCo.BBS.BBSMonitor
{
    public class WebUserLoginNoticeEvent : BBSMonitorEvent
    {
        List<int> _lstTaskCompanies = new List<int>();

        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex)
        {
            _szName = "WebUserLoginNoticeEvent";

            base.Initialize(iIndex);

            try
            {
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("WebUserLoginNoticeInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("WebUserLoginNotice Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("WebUserLoginNoticeStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

                _oLogger.LogMessage("WebUserLoginNotice Start: " + _dtNextDateTime.ToString());

            }
            catch (Exception e)
            {
                LogEventError("Error initializing WebUserLoginNotice event.", e);
                throw;
            }
        }

        override public void ProcessEvent()
        {

            try
            {
                GenerateWebUserNotifications();
                GenerateNewSubscriberTasks();
            }
            catch (Exception e)
            {
                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("Error Procesing WebUserLoginNoticeEvent.", e);
            }
        }

        protected void GenerateWebUserNotifications()
        {
            DateTime dtExecutionStartDate = DateTime.Now;

            int userCount = 0;

            SqlConnection sqlConn = new SqlConnection(GetConnectionString());
            SqlTransaction sqlTran = null;

            try
            {
                sqlConn.Open();

                string szSubject_ES = Utilities.GetConfigValue("WebUserLoginNoticeSubject_Spanish", "Valiosos Datos Empresariales que Necesita Saber");
                string szSubject_EN = Utilities.GetConfigValue("WebUserLoginNoticeSubject", "Valuable Business Data You Need to Know");
                string szEmailTemplate_ES = GetEmailTemplate("WebUserLoginNotice_Spanish.html");
                string szEmailTemplate_EN = GetEmailTemplate("WebUserLoginNotice.html");

                int iMaxUserCount = Utilities.GetIntConfigValue("WebUserLoginNoticeMaxUserCount", Int32.MaxValue);

                List<ReportUser> reportUsers = GetReportUsers(sqlConn, Utilities.GetIntConfigValue("WebUserLoginNoticeDaysThreshold", 120)); 
                userCount = reportUsers.Count;

                int iProcessedCount = 0;

                string emailContent = null;
                string invalidUsers = string.Empty;
                int invalidCount = 0;

                foreach (ReportUser reportUser in reportUsers)
                {
                    if (reportUser.Invalid)
                    {
                        invalidUsers += string.Format("BBID {0} - No email address found." + Environment.NewLine, reportUser.CompanyID);
                        invalidCount++;
                    }
                    else
                    {
                        string szSubject;
                        string szEmailTemplate;
                        switch (reportUser.Culture)
                        {
                            case "es-mx":
                                szSubject = szSubject_ES;
                                szEmailTemplate = szEmailTemplate_ES;
                                break;
                            default:
                                szSubject = szSubject_EN;
                                szEmailTemplate = szEmailTemplate_EN;
                                break;
                        }


                        sqlTran = sqlConn.BeginTransaction();

                        _oLogger.LogMessage(string.Format("Sending to {0}, {1} at {2} using culture {3}", reportUser.CompanyName, reportUser.PersonName, reportUser.Destination, reportUser.Culture));

                        //Get counts
                        const string SQL_LOGIN_NOTICE_USER_COUNTS =
                            @"SELECT (SELECT COUNT(1) FROM Company WHERE comp_PRListedDate > '{0}' AND comp_PRIndustryType IN ({1})) NewListings, 
			                         (SELECT COUNT(1) FROM PRCreditSheet INNER JOIN Company ON Comp_CompanyId = prcs_CompanyId
                                        WHERE prcs_KeyFlag='Y' AND prcs_PublishableDate > '{0}' AND comp_PRIndustryType IN ({1})) KeyRatingChanges";

                        string szIndustryInClause = "'P','S','T'";
                        if (reportUser.IndustryType == "L")
                            szIndustryInClause = "'L'";

                        //FaxPassword contains the composite ISNULL(prwu_LastLoginDateTime, prwu_CreatedDate) -- see line 306 where it is set
                        SqlCommand sqlCommandNewListingsCount = new SqlCommand(string.Format(SQL_LOGIN_NOTICE_USER_COUNTS, reportUser.FaxPassword, szIndustryInClause), sqlConn, sqlTran);

                        int intNewListingsCount = 0;
                        int intKeyRatingChangesCount = 0;

                        using (SqlDataReader reader = sqlCommandNewListingsCount.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                intNewListingsCount = GetInt(reader[0]);
                                intKeyRatingChangesCount = GetInt(reader[1]);
                            }
                        }

                        emailContent = string.Format(szEmailTemplate, string.Format("{0:n0}", intNewListingsCount), string.Format("{0:n0}", intKeyRatingChangesCount));

                        userCount++;

                        string szCategory = "";
                        string szSubcategory = "";

                        string formattedEmail = GetFormattedEmail(sqlConn, sqlTran, reportUser.CompanyID, reportUser.PersonID, szSubject, emailContent, reportUser.Culture);

                        SendEmail(sqlTran,
                                    reportUser,
                                    szSubject,
                                    formattedEmail,
                                    szCategory,
                                    szSubcategory,
                                    true,
                                    "Web User Login Notice Event",
                                    "HTML");

                        sqlTran.Commit();

                        //Create company task if first in that company for this event
                        CreateTask(sqlConn, reportUser);
                    }

                    iProcessedCount++;

                    if (iProcessedCount >= iMaxUserCount)
                        break;
                }

                string msg = string.Format("{0} users processed successfully.", userCount);
                if (Utilities.GetBoolConfigValue("WebUserLoginNoticeWriteResultsToEventLog", true))
                    _oBBSMonitorService.LogEvent("Web User Login Notice Event Executed Successfully. " + msg);

                if (userCount > 0)
                {
                    msg += Environment.NewLine + Environment.NewLine;
                    msg += "Users" + Environment.NewLine;
                    msg += string.Format("Users: {0}", userCount) + Environment.NewLine;

                    if (!string.IsNullOrEmpty(invalidUsers))
                    {
                        msg += string.Format("Unable to Notify {0} Users.", invalidCount) + Environment.NewLine;
                        msg += invalidUsers;
                    }

                    if (Utilities.GetBoolConfigValue("WebUserLoginNoticeSendResultsToSupport", false))
                        SendMail("Web User Login Notice Event", "WebUserLoginNotice Executed Successfully. " + msg);

                    if (!string.IsNullOrEmpty(invalidUsers))
                        SendMail(Utilities.GetConfigValue("WebUserLoginNoticeIssuesEmail", "dmartin@bluebookservices.com"), "Web User Login Notice Event Issues", "WebUserLoginNotice Executed Successfully. " + msg);
                }
            }
            catch (Exception e)
            {
                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("Error Procesing WebUserLoginNoticeEvent.", e);
            }
            finally
            {
                if (sqlConn != null)
                    sqlConn.Close();

                sqlConn = null;
            }
        }

        private string GetTaskSubject()
        {
            return Utilities.GetConfigValue("WebUserLoginNoticeTaskSubject", "Auto email sent to users to encourage BBOS login");
        }

        // {0} = daysThreshold
        // {1} = Task Subject
        private const string SQL_LOGIN_NOTICE_REMINDER_USERS =
            @"SELECT prwu_WebUserID, 
		        ISNULL(prwu_LastLoginDateTime, prwu_CreatedDate) prwu_LastLoginDateTime,
		        prwu_CreatedDate, 
		        PeLi_PersonId, 
		        PeLi_CompanyID, 
		        prwu_HQID,
		        RTRIM(pers_FirstName) + ' ' + RTRIM(pers_LastName) AS prwu_PersonName, 
		        comp_Name, 
		        prwu_Email,
		        comp_PRIndustryType,
                prwu_Culture
            FROM PRWebUser WITH (NOLOCK)
		        INNER JOIN Person_Link WITH (NOLOCK) on peli_personlinkid = prwu_personlinkid
                INNER JOIN Person WITH (NOLOCK) ON peli_PersonID = pers_PersonID
		        INNER JOIN Company WITH (NOLOCK) on Comp_CompanyId = PeLi_CompanyID
            WHERE 
	            prwu_Disabled IS NULL
	            AND prwu_ServiceCode IS NOT NULL
                AND prwu_Email IS NOT NULL
	            AND prwu_HQID IN 
	            (
			        SELECT prwu_HQID
			        FROM PRWebUser
				        LEFT OUTER JOIN 
				        (
					        SELECT CmLi_Comm_CompanyId, MAX(Comm_DateTime) Comm_DateTime 
                              FROM Communication WITH (NOLOCK)
					               INNER JOIN Comm_Link WITH (NOLOCK) ON CmLi_Comm_CommunicationId = Comm_CommunicationId
					         WHERE Comm_Type='Task'
						       AND Comm_Action='EmailOut'
						       AND Comm_PRCategory='CS'
						       AND comm_PRSubcategory='CE'
						       AND Comm_Subject = '{1}'
                          GROUP BY CmLi_Comm_CompanyId
				        ) AS C1 ON prwu_HQID = CmLi_Comm_CompanyId
				        WHERE
					        prwu_Disabled IS NULL
					        AND prwu_ServiceCode IS NOT NULL
					        AND prwu_HQID IS NOT NULL
					        AND (C1.Comm_DateTime IS NULL OR C1.Comm_DateTime < DATEADD(day,-{0}, GETDATE()))
				        GROUP BY prwu_HQID, Comm_DateTime
				        HAVING MAX(ISNULL(prwu_LastLoginDateTime, prwu_CreatedDate)) < DATEADD(day, -{0}, GETDATE()) 
	            )
            ORDER BY prwu_HQID";

        private List<ReportUser> GetReportUsers(SqlConnection sqlConn, int daysThreshold)
        {
            List<ReportUser> lReportUsers = new List<ReportUser>();

            //Subject Task defaulted to "Auto email sent to users to encourage BBOS login", but can be overridden in config file
            SqlCommand sqlCommand = new SqlCommand(string.Format(SQL_LOGIN_NOTICE_REMINDER_USERS, daysThreshold, GetTaskSubject()), sqlConn);
            using (SqlDataReader reader = sqlCommand.ExecuteReader())
            {
                while (reader.Read())
                {
                    ReportUser oReportUser = new ReportUser(reader.GetInt32(3), reader.GetInt32(4));
                    lReportUsers.Add(oReportUser);

                    oReportUser.FaxUserID = GetString(reader[0]); //Storing WebUserID in FaxUserID -- not really fax, but need it later to update the PRWebUserRecored
                    oReportUser.FaxPassword = GetString(reader[1]); //Storing effective last login date in FaxPassword to use later (temp storage)
                    oReportUser.CompanyID = GetInt(reader[5]); //HQID stored here
                    oReportUser.PersonName = GetString(reader[6]);
                    oReportUser.CompanyName = GetString(reader[7]);
                    oReportUser.Method = "email";
                    oReportUser.MethodID = DELIVERY_METHOD_EMAIL;
                    oReportUser.Destination = GetString(reader[8]);
                    if (GetString(reader[9]) != "L")
                        oReportUser.IndustryType = "P";
                    else
                        oReportUser.IndustryType = GetString(reader[9]);

                    if (string.IsNullOrEmpty(oReportUser.Destination))
                        oReportUser.Invalid = true;

                    oReportUser.Culture = GetString(reader[10]);
                }
            }
            return lReportUsers;
        }

        private void CreateTask(SqlConnection sqlConn, ReportUser reportUser)
        {
            //Skip if another user in same company has already created the task
            if (_lstTaskCompanies.Contains(reportUser.CompanyID))
                return;

            SqlCommand cmdCreateTask = new SqlCommand("usp_CreateTask", sqlConn);
            cmdCreateTask.CommandType = CommandType.StoredProcedure;

            cmdCreateTask.Parameters.AddWithValue("CreatorUserId", -1);
            cmdCreateTask.Parameters.AddWithValue("AssignedToUserId", -1);
            cmdCreateTask.Parameters.AddWithValue("TaskNotes", "An email reminder to login was sent to all BBOS users with a password, because no one at this company has logged in to BBOS in 120 days.");
            cmdCreateTask.Parameters.AddWithValue("RelatedCompanyID", reportUser.CompanyID);
            cmdCreateTask.Parameters.AddWithValue("StartDateTime", DateTime.Now);
            cmdCreateTask.Parameters.AddWithValue("Action", "EmailOut");
            cmdCreateTask.Parameters.AddWithValue("Status", "Complete");
            cmdCreateTask.Parameters.AddWithValue("PRCategory", "CS");
            cmdCreateTask.Parameters.AddWithValue("PRSubcategory", "CE");
            cmdCreateTask.Parameters.AddWithValue("ChannelIDOverride", 6);
            cmdCreateTask.Parameters.AddWithValue("Subject", GetTaskSubject());  //"Auto email sent to users to encourage BBOS login";
            cmdCreateTask.ExecuteNonQuery();

            //Flag company task as having been created so it can be skipped by other ReportUsers with same HQID
            _lstTaskCompanies.Add(reportUser.CompanyID);
        }


        private const string SQL_SELECT_NEW_SUBSCRIBERS =
            @"SELECT comp_PRHQID,
                   comp_Name, 
	               peli_PersonID,
                   RTRIM(pers_FirstName) + ' ' + RTRIM(pers_LastName) AS prwu_PersonName, 
	               peli_PRTitle,
                   prwu_Email
                        FROM PRWebUser WITH (NOLOCK)
		                    INNER JOIN Person_Link WITH (NOLOCK) on peli_personlinkid = prwu_personlinkid
                            INNER JOIN Person WITH (NOLOCK) ON peli_PersonID = pers_PersonID
		                    INNER JOIN Company WITH (NOLOCK) on Comp_CompanyId = PeLi_CompanyID
                        WHERE 
	                        prwu_Disabled IS NULL
	                        AND prwu_ServiceCode IS NOT NULL
				            AND comp_PRListedDate >= @NewlyListedThresholdDate 
                            AND prwu_Email IS NOT NULL
	                        AND prwu_HQID IN 
	                        (
			                    SELECT prwu_HQID
			                    FROM PRWebUser
				                    LEFT OUTER JOIN 
				                    (
					                    SELECT CmLi_Comm_CompanyId, MAX(Comm_DateTime) Comm_DateTime 
                                          FROM Communication WITH (NOLOCK)
					                           INNER JOIN Comm_Link WITH (NOLOCK) ON CmLi_Comm_CommunicationId = Comm_CommunicationId
					                     WHERE Comm_Type='Task'
						                   AND Comm_Action='ToDo'
						                   AND Comm_PRCategory='CS'
						                   AND comm_PRSubcategory='CE'
						                   AND Comm_Subject = @Subject
                                      GROUP BY CmLi_Comm_CompanyId
				                    ) AS C1 ON prwu_HQID = CmLi_Comm_CompanyId
				                    WHERE
					                    prwu_Disabled IS NULL
					                    AND prwu_ServiceCode IS NOT NULL
					                    AND prwu_HQID IS NOT NULL
					                    AND (C1.Comm_DateTime IS NULL OR C1.Comm_DateTime < @ThresholdDate)
				                    GROUP BY prwu_HQID, Comm_DateTime
				                    HAVING MAX(ISNULL(prwu_LastLoginDateTime, prwu_CreatedDate)) < @ThresholdDate
	                        )
            ORDER BY prwu_HQID, Pers_LastName, Pers_FirstName";


        protected void GenerateNewSubscriberTasks()
        {
            DateTime dtExecutionStartDate = DateTime.Now;

            int loginDays =  Utilities.GetIntConfigValue("NewSubscriberTasksLoginTheshold", 60);
            string subject = Utilities.GetConfigValue("NewSubscriberTasksSubject", "New Subscriber (first 13 months) Touch Points");
            DateTime threadholdDate = DateTime.Today.AddDays(0 - loginDays);
            DateTime newlyListedThresholdDate = DateTime.Today.AddMonths(0 - Utilities.GetIntConfigValue("NewSubscriberTasksNewlyListedThreshold", 13));

            int count = 0;
            int companyID = 0;
            StringBuilder taskMsg = new StringBuilder();

            using (SqlConnection sqlConn = new SqlConnection(GetConnectionString()))
            {
                sqlConn.Open();

                SqlCommand sqlCommand = new SqlCommand(SQL_SELECT_NEW_SUBSCRIBERS, sqlConn);
                sqlCommand.Parameters.AddWithValue("Subject", subject);
                sqlCommand.Parameters.AddWithValue("ThresholdDate", threadholdDate);
                sqlCommand.Parameters.AddWithValue("NewlyListedThresholdDate", newlyListedThresholdDate);

                using (SqlDataReader reader = sqlCommand.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        if (companyID != reader.GetInt32(0))
                        {
                            if (companyID > 0)
                                CreateNewSubscriberTask(companyID, subject, taskMsg.ToString());

                            count++;
                            companyID = reader.GetInt32(0);

                            taskMsg.Clear();
                            taskMsg.Append($"The following BBOS users have not logged into BBOS in the past {loginDays} days.  Please reach out to them to encourage login and usage.");
                            taskMsg.Append(Environment.NewLine + Environment.NewLine);
                        }

                        string personName = reader.GetString(3);
                        string title = reader.GetString(4);
                        string email = reader.GetString(5);

                        taskMsg.Append($" - {personName} - {title}: {email}{Environment.NewLine}");
                    }
                }

                // Get that last company
                CreateNewSubscriberTask(companyID, subject, taskMsg.ToString());

                string msg = string.Format("{0} companies processed successfully.", count);

                if (Utilities.GetBoolConfigValue("NewSubscriberTasksWriteResultsToEventLog", true))
                    _oBBSMonitorService.LogEvent("New Subscriber Tasks Event Executed Successfully. " + msg);

                if ((count > 0) &&
                    (Utilities.GetBoolConfigValue("NewSubscriberTasksSendResultsToSupport", false)))
                    SendMail("New Subscriber Tasks Event", "New Subscriber Tasks Executed Successfully. " + msg);

            }
        }

        private void CreateNewSubscriberTask(int companyID, string subject, string taskMsg)
        {
            using (SqlConnection sqlConn = new SqlConnection(GetConnectionString()))
            {
                sqlConn.Open();
                SqlCommand cmdCreateTask = new SqlCommand("usp_CreateTask", sqlConn);
                cmdCreateTask.CommandType = CommandType.StoredProcedure;

                cmdCreateTask.Parameters.AddWithValue("CreatorUserId", -1);
                cmdCreateTask.Parameters.AddWithValue("AssignedToUserId", Utilities.GetIntConfigValue("NewSubscriberTasksAssignedToUserID", 1075));
                cmdCreateTask.Parameters.AddWithValue("TaskNotes", taskMsg);
                cmdCreateTask.Parameters.AddWithValue("RelatedCompanyID", companyID);

                cmdCreateTask.Parameters.AddWithValue("StartDateTime", DateTime.Now);
                cmdCreateTask.Parameters.AddWithValue("Action", "ToDo");
                cmdCreateTask.Parameters.AddWithValue("Status", "Pending");
                cmdCreateTask.Parameters.AddWithValue("PRCategory", "CS");
                cmdCreateTask.Parameters.AddWithValue("PRSubcategory", "CE");
                cmdCreateTask.Parameters.AddWithValue("Subject", subject);
                cmdCreateTask.Parameters.AddWithValue("ChannelIDOverride", Utilities.GetIntConfigValue("NewSubscriberTasksChannelID", 6));
                cmdCreateTask.ExecuteNonQuery();
            }
        }
    }
}