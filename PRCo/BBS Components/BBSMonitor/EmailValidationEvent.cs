/***********************************************************************
 Copyright Blue Book Services, Inc. 2023

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: EmailValidationEvent.cs
 Description:	

 Notes:	Using the following SendGrid end point
            https://docs.sendgrid.com/api-reference/e-mail-address-validation/validate-an-email

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Threading.Tasks;
using System.Threading;
using System.Timers;
using Newtonsoft.Json;
using SendGrid;
using SendGrid.Helpers.Mail;
using TSI.Utils;


namespace PRCo.BBS.BBSMonitor
{
    public class EmailValidationEvent : BBSMonitorEvent
    {
        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex)
        {
            _szName = "EmailValidationEvent";

            base.Initialize(iIndex);

            try
            {
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("EmailValidationInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("EmailValidation Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("EmailValidationStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new System.Timers.Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

                _oLogger.LogMessage("EmailValidation Start: " + _dtNextDateTime.ToString());

            }
            catch (Exception e)
            {
                LogEventError("Error initializing EmailValidation event.", e);
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
                ValidateEmailAddresses().Wait();
            }
            catch (Exception e)
            {
                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("Error Procesing EmailValidation Event.", e);
            }
        }

        public async Task ValidateEmailAddresses()
        {
            StringBuilder msg = new StringBuilder();

            string fileRoot = Utilities.GetConfigValue("SQLReportPath");
            string membershipFile = null;
            string dlFile = null;
            List<string> attachments = new List<string>();


            if (DateTime.Today.Day == Utilities.GetIntConfigValue("EmailValidationDayOfMonth", 1))
            {
                string billingCycle = DateTime.Today.AddMonths(Utilities.GetIntConfigValue("EmailValidationMembershipMonthsAhead", 2)).Month.ToString("00");

                msg.AppendLine($"Validiating Membership Email Addresses for Cycle {billingCycle}.");
                List <BBEmailAddress> bbEmails = GetMembershipBillingEmails(billingCycle);
                List<EmailValidationResult> results = await ScoreEmailAddresses(bbEmails);

                msg.AppendLine($"- Found {results.Count} emails with potential issues.");

                membershipFile = Path.Combine(fileRoot, $"Membership Billng Email Validation-{billingCycle}.csv");
                attachments.Add(membershipFile);
                WriteDataFile(results, membershipFile);
            }

            if ((DateTime.Today.Month == Utilities.GetIntConfigValue("EmailValidationDLMonthOfYear", 12)) &&
                (DateTime.Today.Day == Utilities.GetIntConfigValue("EmailValidationDLDayOfMonth", 15)))
            {
                msg.AppendLine($"Validiating DL Billing Email Addresses.");
                List<BBEmailAddress> bbEmails = GetDLBillingEmails();
                List<EmailValidationResult> results = await ScoreEmailAddresses(bbEmails);

                msg.AppendLine($"- Found {results.Count} emails with potential issues.");

                dlFile = Path.Combine(fileRoot, "DLBillingEmailValidation.csv");
                attachments.Add(dlFile);
                WriteDataFile(results, dlFile);
            }

            if ((membershipFile == null) && (dlFile == null))
                msg.AppendLine("Validation skipped.");
            else
            {
                using (SqlConnection sqlConn = new SqlConnection(GetConnectionString()))
                {
                    sqlConn.Open();
                    await SendEmail(sqlConn,
                              Utilities.GetConfigValue("EmailValidationResultsEmail", "jmangini@bluebookservices.com;korlowski@bluebookservices.com"),
                              Utilities.GetConfigValue("EmailValidationResultsSubject", "Email Validation Results"),
                              msg.ToString(),
                              attachments.ToArray());
                }
            }


            if (Utilities.GetBoolConfigValue("EmailValidationWriteResultsToEventLog", true))
                _oBBSMonitorService.LogEvent("EmailValiation Executed Successfully. " + Environment.NewLine + Environment.NewLine + msg.ToString());

            if (Utilities.GetBoolConfigValue("EmailValidationSendResultsToSupport", false))
                SendMail("EmailValidattion Success", msg.ToString());
        }

        public async Task<List<EmailValidationResult>> ScoreEmailAddresses(List<BBEmailAddress> bbEmails)
        {
            List<EmailValidationResult> results = new List<EmailValidationResult>();
            foreach (BBEmailAddress bbEmail in bbEmails)
            {
                WriteLine($"Validating {bbEmail.CompanyID} - {bbEmail.Email}");
                EmailValidationResult validationResult = await ScoreEmailAddress(bbEmail.Email);
                validationResult.BBID = bbEmail.CompanyID;
                validationResult.PersonID = bbEmail.PersonID;

                if (validationResult.verdict.ToLower() != "valid")
                    results.Add(validationResult);

                Thread.Sleep(200);
            }

            return results;
        }

        public async Task<EmailValidationResult> ScoreEmailAddress(string emailAddress)
        {
            var apiKey = Utilities.GetConfigValue("SENDGRID_VALIDATION_API_KEY");
            var client = new SendGridClient(apiKey: apiKey);

            string data = $"{{\"email\":\"{emailAddress}\",\"source\": \"crmpoc\"}}";

            var response = await client.RequestAsync(method: SendGridClient.Method.POST, urlPath: "validations/email", requestBody: data);
            string jsonPayload = response.Body.ReadAsStringAsync().Result;

            //WriteLine(response.StatusCode.ToString());
            //WriteLine(jsonPayload);
            //WriteLine(response.Headers.ToString());

            jsonPayload = jsonPayload.Substring(10);
            jsonPayload = jsonPayload.Substring(0, jsonPayload.Length - 1);
            jsonPayload = jsonPayload.Trim();

            EmailValidationResult emailResult = JsonConvert.DeserializeObject<EmailValidationResult>(jsonPayload);
            return emailResult;
        }

        protected string _szOutputFile;
        protected List<string> _lszOutputBuffer = new List<string>();

        private void WriteLine(string msg)
        {
            //if (_szOutputFile == null)
            //{
            //    _szOutputFile = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Substring(6);
            //    _szOutputFile = Path.Combine(_szOutputFile, "SendGrid.txt");
            //}

            //Console.WriteLine(msg);
            //_lszOutputBuffer.Add(msg);
        }

        private void WriteDataFile(List<EmailValidationResult> emailResults, string fileName)
        {
            using (StreamWriter sw = new StreamWriter(fileName))
            {
                sw.WriteLine("CompanyID,PersonID,Email,Verdict,Score,Has Valid Address Syntax,Has MX or A Record,Is Suspected Disposable Address,Is Suspected Role Address,Has Known Bounces,Has Suspected Bounces");

                foreach (EmailValidationResult emailResult in emailResults)
                {
                    sw.WriteLine($"{emailResult.BBID},{emailResult.PersonID},{emailResult.email},{emailResult.verdict},{emailResult.score},{emailResult.checks.domain.has_valid_address_syntax},{emailResult.checks.domain.has_mx_or_a_record},{emailResult.checks.domain.is_suspected_disposable_address},{emailResult.checks.local_part.is_suspected_role_address},{emailResult.checks.additional.has_known_bounces},{emailResult.checks.additional.has_suspected_bounces}");
                }
            }
        }

        private const string SQL_SELECT_MEMBERSHIP_BILLING_EMAIL =
            @"SELECT prattn_CompanyID, prattn_PersonID, prattn_EmailID, RTRIM(emai_EmailAddress) emai_EmailAddress
                FROM PRAttentionLine WITH (NOLOCK)
                     INNER JOIN Company WITH (NOLOCK) ON prattn_CompanyID= comp_CompanyID
	                 INNER JOIN Email WITH (NOLOCK) ON Emai_EmailId = prattn_EmailID
		             INNER JOIN PRService WITH (NOLOCK) ON prattn_CompanyID = prse_CompanyID AND prse_Primary='Y'
               WHERE BillingMonth = '{0}'
                 AND prattn_Disabled IS NULL
                 AND prattn_ItemCode IN ('BILL')
                 AND prattn_EmailID IS NOT NULL
            ORDER BY prattn_CompanyID";

        private List<BBEmailAddress> GetMembershipBillingEmails(string billingMonth)
        {
            return GetEmailAddresses(string.Format(SQL_SELECT_MEMBERSHIP_BILLING_EMAIL, billingMonth));
        }

        private const string SQL_SELECT_DL_BILLING_EMAIL =
            @"SELECT prattn_CompanyID, prattn_PersonID, prattn_EmailID, RTRIM(emai_EmailAddress) emai_EmailAddress
                FROM PRAttentionLine WITH (NOLOCK)
                    INNER JOIN Company WITH (NOLOCK) ON prattn_CompanyID= comp_CompanyID
	                INNER JOIN Email WITH (NOLOCK) ON Emai_EmailId = prattn_EmailID
		            LEFT OUTER JOIN PRService ON prattn_CompanyID = prse_CompanyID AND prse_Primary='Y'
		            LEFT OUTER JOIN (SELECT DISTINCT prdl_CompanyId FROM PRDescriptiveLine WITH (NOLOCK)) T1 ON prattn_CompanyID = prdl_CompanyId
              WHERE prse_ServiceCode IS NULL
                AND comp_PRPublishDL='Y'
	            AND prdl_CompanyId IS NOT NULL
                AND prattn_Disabled IS NULL
                AND prattn_ItemCode IN ('BILL')
            ORDER BY prattn_CompanyID";


        private List<BBEmailAddress> GetDLBillingEmails()
        {
            return GetEmailAddresses(SQL_SELECT_DL_BILLING_EMAIL);
        }

        private List<BBEmailAddress> GetEmailAddresses(string sql)
        {
            List<BBEmailAddress> bbEmails = new List<BBEmailAddress>();

            using (SqlConnection sqlConn = new SqlConnection(GetConnectionString()))
            {
                sqlConn.Open();
                SqlCommand commandCompanies = new SqlCommand();
                commandCompanies.Connection = sqlConn;
                commandCompanies.CommandText = sql;

                using (SqlDataReader reader = commandCompanies.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        BBEmailAddress bbEmail = new BBEmailAddress();
                        bbEmail.CompanyID = reader.GetInt32(0);

                        if (reader[1] != DBNull.Value)
                            bbEmail.PersonID = reader.GetInt32(1);

                        bbEmail.EmailID = reader.GetInt32(2);
                        bbEmail.Email = reader.GetString(3);
                        bbEmails.Add(bbEmail);
                    }
                }
            }

            return bbEmails;
        }

#pragma warning disable CS1998 // This async method lacks 'await' operators and will run synchronously. Consider using the 'await' operator to await non-blocking API calls, or 'await Task.Run(...)' to do CPU-bound work on a background thread.
        protected async Task SendEmail(SqlConnection dbConn,
#pragma warning restore CS1998 // This async method lacks 'await' operators and will run synchronously. Consider using the 'await' operator to await non-blocking API calls, or 'await Task.Run(...)' to do CPU-bound work on a background thread.
                                 string emailAddress,
                                 string szSubject,
                                 string szContent,
                                 string[] aszAttachmentName)
        {

            SqlCommand oSQLCommand = new SqlCommand("usp_CreateEmail", dbConn, null);
            oSQLCommand.CommandType = CommandType.StoredProcedure;
            oSQLCommand.CommandTimeout = Utilities.GetIntConfigValue("BBSMonitorQueryTimeout", 300);
            oSQLCommand.Parameters.AddWithValue("@CreatorUserId", -1);
            oSQLCommand.Parameters.AddWithValue("@From", Utilities.GetConfigValue("CommunicationFrom", "System"));
            oSQLCommand.Parameters.AddWithValue("@Subject", szSubject);
            oSQLCommand.Parameters.AddWithValue("@Content", szContent);
            oSQLCommand.Parameters.AddWithValue("@DoNotRecordCommunication", 1);
            oSQLCommand.Parameters.AddWithValue("@Content_Format", "Text");
            oSQLCommand.Parameters.AddWithValue("@To", Utilities.GetConfigValue("TestEmail", emailAddress));

            // Spin through our attachments
            string szAttachmentList = string.Empty;
            for (int i = 0; i < aszAttachmentName.Length; i++)
            {
                if (szAttachmentList.Length > 0)
                    szAttachmentList += ";";

                szAttachmentList += aszAttachmentName[i];
            }

            oSQLCommand.Parameters.AddWithValue("@AttachmentDir", Utilities.GetConfigValue("SQLReportPath"));
            oSQLCommand.Parameters.AddWithValue("@AttachmentFileName", szAttachmentList);

            int iReturn = Convert.ToInt32(oSQLCommand.ExecuteScalar());
            if (iReturn != 0)
                throw new ApplicationException("Non-zero return code sending Email Validation results email: " + iReturn.ToString());
        }
    }

    public class BBEmailAddress
    {
        public int CompanyID;
        public int PersonID;
        public int EmailID;
        public string Email;
    }

    public class EmailValidationResult
    {
        public int BBID;
        public int PersonID;
        public string email;
        public string verdict;
        public decimal score;
        public string local;
        public string host;
        public string suggestion;
        public string source;
        public string ip_address;
        public Checks checks;
    }

    public class Checks
    {
        public Domain domain;
        public Local_part local_part;
        public Additional additional;
    }

    public class Domain
    {
        public bool has_valid_address_syntax;
        public bool has_mx_or_a_record;
        public bool is_suspected_disposable_address;
    }

    public class Local_part
    {
        public bool is_suspected_role_address;
    }

    public class Additional
    {
        public bool has_known_bounces;
        public bool has_suspected_bounces;
    }
}
