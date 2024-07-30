/***********************************************************************
 Copyright Blue Book Services, Inc. 2014-2023

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: EmailStatusEvent.cs
 Description:	

 Notes:	Updated to use SendGrid API for bouncebacks in August 2023
            https://docs.sendgrid.com/api-reference/bounces-api/retrieve-all-bounces

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;
using System.Threading.Tasks;
using System.Timers;
using Newtonsoft.Json;
using PRCo.BBOS.EmailInterface;
using SendGrid;
using SendGrid.Helpers.Mail;
using TSI.Utils;


namespace PRCo.BBS.BBSMonitor
{
    public class EmailStatusEvent : BBSMonitorEvent
    {
        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex)
        {
            _szName = "EmailStatusEvent";

            base.Initialize(iIndex);

            try
            {
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("EmailStatusInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("EmailStatus Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("EmailStatusStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

                _oLogger.LogMessage("EmailStatus Start: " + _dtNextDateTime.ToString());

            }
            catch (Exception e)
            {
                LogEventError("Error initializing EmailStatus event.", e);
                throw;
            }
        }


        /// <summary>
        /// Go update the classification company counts.
        /// </summary>
        override public void ProcessEvent()
        {
            DateTime dtExecutionStartDate = DateTime.Now;

            try
            {
                SendGrid_Bounces().Wait();
            }
            catch (Exception e)
            {
                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("Error Procesing EmailStatus Event.", e);
            }
        }

        static async Task SendGrid_SendTestMail(string szToEmail)
        {
            string szFromEmail = Utilities.GetConfigValue("SENDGRID_FROM_EMAIL");
            var apiKey = Utilities.GetConfigValue("SENDGRID_API_KEY");
            var client = new SendGridClient(apiKey);
            var from = new EmailAddress(szFromEmail, "Example User");
            var subject = "Sending with SendGrid is Fun";
            var to = new EmailAddress(szToEmail, "Example User");
            var plainTextContent = "and easy to do anywhere, even with C#";
            var htmlContent = "<strong>and easy to do anywhere, even with C#</strong>";
            var msg = MailHelper.CreateSingleEmail(from, to, subject, plainTextContent, htmlContent);
            var response = await client.SendEmailAsync(msg);
        }

        private async Task SendGrid_Bounces()
        {
            //https://docs.sendgrid.com/api-reference/bounces-api/retrieve-all-bounces

            DateTime dtReportEndDate = DateTime.Now.AddHours(0 - Utilities.GetIntConfigValue("EmailStatusEndThreshold", 24));
            DateTime dtReportStartDate = dtReportEndDate.AddHours(0 - Utilities.GetIntConfigValue("EmailStatusStartThreshold", 24));

            long endTimeUnix = ((DateTimeOffset)dtReportEndDate).ToUnixTimeSeconds();
            long startTimeUnix = ((DateTimeOffset)dtReportStartDate).ToUnixTimeSeconds();

            var apiKey = Utilities.GetConfigValue("SENDGRID_API_KEY");
            var client = new SendGridClient(apiKey: apiKey);
            string queryParams = "{'end_time': " + endTimeUnix + ", 'start_time': " + startTimeUnix + "}";

            var bouncesResponse = await client.RequestAsync(method: SendGridClient.Method.GET, urlPath: "suppression/bounces", queryParams: queryParams);
            int count = SendGrid_ProcessBounces(bouncesResponse.Body.ReadAsStringAsync().Result, "BNC");

            var blocksResponse = await client.RequestAsync(method: SendGridClient.Method.GET, urlPath: "suppression/blocks", queryParams: queryParams);
            count += SendGrid_ProcessBounces(blocksResponse.Body.ReadAsStringAsync().Result, "BLK");


            string msg = "Processed failures for " + count.ToString("###,##0") + " emails.";

            if (Utilities.GetBoolConfigValue("EmailStatusWriteResultsToEventLog", true))
            {
                _oBBSMonitorService.LogEvent("EmailStatus Executed Successfully. " + msg);
            }

            if (Utilities.GetBoolConfigValue("EmailStatusSendResultsToSupport", false))
            {
                if (sbNonUpdates.Length > 0)
                {
                    msg += Environment.NewLine + Environment.NewLine;
                    msg += "Unable to find PRCommunicationLog records for the following:" + Environment.NewLine;
                    msg += sbNonUpdates;
                }

                SendMail("EmailStatus Success", msg);
            }
        }

        private int SendGrid_ProcessBounces(string json, string failedTypeCode)
        {
            dynamic emailResults = JsonConvert.DeserializeObject(json);

            if (emailResults.Count > 0)
            {
                using (SqlConnection oConn = new SqlConnection(GetConnectionString()))
                {
                    try
                    {
                        sqlUpdateCommLog = null;
                        oConn.Open();

                        foreach (var emailResult in emailResults)
                        {
                            long created = emailResult.created;
                            string email = emailResult.email;
                            string reason = emailResult.reason;

                            if ((!string.IsNullOrEmpty(reason)) &&
                                (reason.Length > 500))
                                reason = reason.Substring(0, 500);

                            UpdateCommunicationLog(oConn, created, email, reason, failedTypeCode);
                        }
                    }
                    catch (Exception e)
                    {
                        // This logs the error in the Event Log, Trace File,
                        // and sends the appropriate email.
                        LogEventError("Error Procesing EmailStatus Event.", e);
                    }

                }
            }

            return emailResults.Count;
        }

        private const string SQL_UPDATE_COMM_LOG =
            @"UPDATE PRCommunicationLog
                SET prcoml_Failed = 'Y',
                    prcoml_FailedMessage = @Message,
                    prcoml_FailedCategory = @Category,
                    prcoml_FailedTypeCode = @FailedTypeCode,
	                prcoml_UpdatedBy = -1,
	                prcoml_UpdatedDate = GETDATE()
              WHERE prcoml_Destination = @Email 
                AND prcoml_CreatedDate BETWEEN @FromSentDateTime AND @ToSentDateTime";

        private StringBuilder sbNonUpdates = new StringBuilder();
        private SqlCommand sqlUpdateCommLog = null;

        private void UpdateCommunicationLog(SqlConnection oConn, long created, string email, string reason, string failedTypeCode)
        {
            DateTime createdDt = DateTimeOffset.FromUnixTimeSeconds(created).DateTime;
            createdDt = createdDt.AddHours(Convert.ToInt32(Utilities.GetIntConfigValue("EmailStatusSendGridHourOffset", -5))); //adjust the datetime that SendGrid stores vs. that which BBS database stores

            if (sqlUpdateCommLog == null)
            {
                sqlUpdateCommLog = new SqlCommand();
                sqlUpdateCommLog.Connection = oConn;
                sqlUpdateCommLog.CommandText = SQL_UPDATE_COMM_LOG;
            }

            string errorCategory = SetCategory(reason);

            int updateCount = 0;

            if (!string.IsNullOrEmpty(email))
            {
                sqlUpdateCommLog.Parameters.Clear();
                AddSqlParameter(sqlUpdateCommLog, "Message", reason);
                AddSqlParameter(sqlUpdateCommLog, "Category", errorCategory); 
                sqlUpdateCommLog.Parameters.AddWithValue("Email", email);
                sqlUpdateCommLog.Parameters.AddWithValue("FromSentDateTime", createdDt.AddHours(-1));
                sqlUpdateCommLog.Parameters.AddWithValue("ToSentDateTime", createdDt.AddHours(1));
                sqlUpdateCommLog.Parameters.AddWithValue("FailedTypeCode", failedTypeCode);
                updateCount = sqlUpdateCommLog.ExecuteNonQuery();
            }

            if (updateCount == 0)
            {
                object[] displayArgs = new object[] {
                            email,
                            createdDt,
                            reason,
                            errorCategory};

                sbNonUpdates.Append(string.Format("{0}\t{1}\t{2}\t{3}\n", displayArgs));
            }
        }

        // http://community.spiceworks.com/how_to/show/939-ndr-non-delivery-receipts-codes-and-their-meanings
        private string SetCategory(string reason)
        {
            if (string.IsNullOrEmpty(reason))
            {
                return "";
            }

            string work = reason.ToLower();

            if (reason.IndexOf("5.4.0") > 0)
            {
                return "Unable to Find Email Server";  // Check for misspellings in the email address and confirm the company still exists.
            }

            if ((reason.IndexOf("4.4.2") > 0) ||
                (reason.IndexOf("4.4.7") > 0) ||
                (reason.IndexOf("hop count exceeded") > 0) ||
                (reason.IndexOf("unable to relay") > 0) ||
                (reason.IndexOf("relay access denied") > 0) ||
                (reason.IndexOf("sender denied") > 0) ||
                (reason.IndexOf("does not comply with required standards") > 0) ||
                (reason.IndexOf("helo command rejected") > 0) ||
                (reason.IndexOf("spf check failed") > 0)
                )
            {
                return "Technical Issue";  // Contact BBS IT to research further.
            }

            if ( (reason.IndexOf("5.1.10") > 0) ||
                 (work.IndexOf("does not exist") > 0) ||
                 (work.IndexOf("user unknown") > 0) ||
                 (work.IndexOf("user account is unavailable") > 0) ||
                 (work.IndexOf("no such user") > 0) ||
                 (work.IndexOf("is disabled") > 0) ||
                 (work.IndexOf("recipient not found") > 0) ||
                 (work.IndexOf("recipient doesn't exist") > 0) ||
                 (work.IndexOf("recipient rejected") > 0) ||
                 (work.IndexOf("invalid recipient") > 0) ||
                 (work.IndexOf("unknown or illegal alias") > 0) ||
                 (work.IndexOf("invalid mailbox") > 0) ||
                 (work.IndexOf("mailbox unavailable") > 0) ||
                 (work.IndexOf("address rejected") > 0) ||
                 (work.IndexOf("recipnotfound") > 0) ||
                 (work.IndexOf("message rejected") > 0) ||
                 (work.IndexOf("there is no one at this address") > 0) ||
                 (work.IndexOf("mailbox is inactive") > 0) ||
                 (work.IndexOf("not liste d ") > 0) ||   // Misspelling is intentional
                 (work.IndexOf("account has been disabled") > 0))
            {
                return "Email Address Not Found";  // Check for misspellings in the email address and confirm this person is still with the organization.
            }

            if ((work.IndexOf("is over quota") > 0) ||
                (work.IndexOf("quota exceeded") > 0) ||
                (work.IndexOf("exceed quota") > 0) ||
                (work.IndexOf("mailbox is full") > 0) ||
                (work.IndexOf("mailfolder is full") > 0))
            {
                return "Email Address Rejecting Email";  // Confirm this person is still with the organization
            }

            if ((work.IndexOf("looks like spam") > 0) ||
                (work.IndexOf("spam") > 0))
            {
                return "Rejected as Spam/Junk";  // Contact company and ask to add ‘bluebookservices.com” to white list.
            }

            return "";
        }
    }
}
