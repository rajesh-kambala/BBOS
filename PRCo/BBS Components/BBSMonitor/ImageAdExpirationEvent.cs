/***********************************************************************
 Copyright Blue Book Services, Inc. 2020

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: ImageAdExpirationEvent.cs
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
    class ImageAdExpirationEvent : BBSMonitorEvent
    {
        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex)
        {
            _szName = "ImageAdExpirationEvent";

            base.Initialize(iIndex);

            try
            {
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("ImageAdExpirationInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("ImageAdExpiration Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("ImageAdExpirationStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

                _oLogger.LogMessage("ImageAdExpiration Start: " + _dtNextDateTime.ToString());

            }
            catch (Exception e)
            {
                LogEventError("Error initializing ImageAdExpiration event.", e);
                throw;
            }
        }

        const string SQL_SELECT_EXPIRING_CAMPAIGNS =
              @"SELECT  
	                pradc_CompanyID, pradch_AdCampaignHeaderId, pradch_Name, pradc_AdCampaignID, pradc_Name, pradc_EndDate,
	                user_EmailAddress, comp_Name, comp_PRType, CityStateCountryShort
                FROM PRAdCampaignHeader WITH(NOLOCK)
	                INNER JOIN PRAdCampaign WITH(NOLOCK) ON pradch_AdCampaignHeaderID = pradc_AdCampaignHeaderID
	                INNER JOIN (SELECT user_UserId, user_EmailAddress FROM Users) fsr ON fsr.User_UserId = dbo.ufn_GetPRCoSpecialistUserId(pradc_CompanyID,2)
					INNER JOIN Company WITH (NOLOCK) ON Comp_CompanyId = pradc_CompanyID
					INNER JOIN vPRLocation on prci_CityID = comp_PRListingCityID
                WHERE
	                pradch_TypeCode='D'
	                AND CAST(pradc_EndDate AS DATE) = CAST(@TargetExpirationDate AS DATE)
	                AND pradc_ExpirationEmailDate IS NULL
                    AND pradc_CompanyID <> 100002
                    ORDER BY pradc_CompanyID, pradc_AdCampaignID";

        const string SQL_MARK_AS_SENT =
                    @"UPDATE PRAdCampaign SET pradc_ExpirationEmailDate = GETDATE() WHERE pradc_AdCampaignID = {0}";  

        private class Email
        {
            public string EmailAddress { get; set; }
            public string Subject { get; set; }
            public string Body{ get; set; }
            public int AdId { get; set; }

            public Email(string email, string subject, string body, int adid)
            {
                EmailAddress = email;
                Subject = subject;
                Body = body;
                AdId = adid;
            }
        }

        /// <summary>
        /// Go update the classification company counts.
        /// </summary>
        override public void ProcessEvent()
        {
            DateTime dtExecutionStartDate = DateTime.Now;
            StringBuilder sbMsg = new StringBuilder();
            SqlConnection sqlConn = new SqlConnection(GetConnectionString());

            try
            {
                sqlConn.Open();

                DateTime targetExpirationDate = DateTime.Today.AddDays(Utilities.GetIntConfigValue("ImageAdExpirationThreshold", 30));

                List<Email> lstEmails = new List<Email>();

                int adCount = 0;
                SqlCommand sqlCommand = new SqlCommand(SQL_SELECT_EXPIRING_CAMPAIGNS, sqlConn);
                sqlCommand.Parameters.AddWithValue("TargetExpirationDate", targetExpirationDate);
                using (SqlDataReader reader = sqlCommand.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        adCount++;
                        string[] args = { reader.GetString(7), 
                                            reader[0].ToString(), 
                                            reader.GetString(8), 
                                            reader.GetString(9) 
                                        };

                        int adid = reader.GetInt32(3);
                        string subject = string.Format("Digital Ad For {0}, {1} ({2}), {3} Expiring Soon", args );
                        string body = subject;

                        string emailAddress = reader.GetString(6); //field rep user's email

                        lstEmails.Add(new Email(emailAddress, subject, body, adid));

                        sbMsg.Append(body + Environment.NewLine);
                    }
                }

                //Send emails to field reps
                foreach (Email email in lstEmails)
                {
                    SqlCommand cmdCreateEmail = new SqlCommand("usp_CreateEmail", sqlConn);
                    cmdCreateEmail.CommandType = CommandType.StoredProcedure;
                    cmdCreateEmail.Parameters.AddWithValue("To", email.EmailAddress);
                    cmdCreateEmail.Parameters.AddWithValue("Subject", email.Subject);
                    cmdCreateEmail.Parameters.AddWithValue("Content", email.Body);
                    cmdCreateEmail.Parameters.AddWithValue("DoNotRecordCommunication", 1);
                    cmdCreateEmail.Parameters.AddWithValue("Action", "EmailOut");
                    cmdCreateEmail.ExecuteNonQuery();

                    string szMarkSent = string.Format(SQL_MARK_AS_SENT, email.AdId);
                    SqlCommand cmdFlagSent = new SqlCommand(szMarkSent, sqlConn);
                    cmdFlagSent.CommandType = CommandType.Text;
                    cmdFlagSent.ExecuteNonQuery();
                }

                string msg = null;
                if (adCount > 0)
                {
                    msg = string.Format("Found {0} expiring ads", adCount) + Environment.NewLine + Environment.NewLine;
                    msg += sbMsg.ToString();
                }

                TimeSpan tsDiff = DateTime.Now.Subtract(dtExecutionStartDate);
                msg += "\n\nExecution time: " + tsDiff.ToString();

                if (Utilities.GetBoolConfigValue("ImageAdExpirationWriteResultsToEventLog", true))
                {
                    _oBBSMonitorService.LogEvent("ImageAdExpiration Executed Successfully.  Found " + adCount.ToString("###,##0") + " expiring image ads.");
                }

                if (Utilities.GetBoolConfigValue("ImageAdExpirationSendResultsToSupport", true))
                {
                    if (adCount > 0)
                    {
                        SendMail("Image Ad Expiration Success", msg);
                    }
                }
            }
            catch (Exception e)
            {
                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("Error Procesing ImageAdExpiration Event.", e);
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
    }
}
