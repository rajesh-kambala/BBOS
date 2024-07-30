/***********************************************************************
 Copyright Blue Book Services, Inc. 2014-2019

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: ImageAdVerificationEvent.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Timers;
using TSI.Utils;

namespace PRCo.BBS.BBSMonitor
{
    public class ImageAdVerificationEvent : BBSMonitorEvent
    {
        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex)
        {
            _szName = "ImageAdVerificationEvent";

            base.Initialize(iIndex);

            try
            {
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("ImageAdVerificationInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("ImageAdVerification Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("ImageAdVerificationStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

                _oLogger.LogMessage("ImageAdVerification Start: " + _dtNextDateTime.ToString());

            }
            catch (Exception e)
            {
                LogEventError("Error initializing ImageAdVerification event.", e);
                throw;
            }
        }

        private const string SQL_SELECT_BAD_ADS =
            @"SELECT prcse_FullName, pradc_AdCampaignID, pradch_Name
                  FROM PRAdCampaignHeader WITH (NOLOCK)
					   INNER JOIN PRAdCampaign WITH (NOLOCK) ON pradc_AdCampaignHeaderID = pradch_AdCampaignHeaderID
                       INNER JOIN PRCompanySearch WITH (NOLOCK) ON pradc_CompanyID = prcse_CompanyID
                       LEFT OUTER JOIN PRAdCampaignFile ON pracf_AdCampaignID = pradc_AdCampaignID
                 WHERE pradc_AdCampaignType LIKE 'IA%'
                   AND pradc_StartDate BETWEEN  GETDATE() AND DATEADD(day, @DayThreshold, GETDATE())
                   AND pracf_FileName IS NULL";

        protected const string SQL_UPDATE_BAD_ADS =
              @"UPDATE t
                    SET t.pradc_StartDate = DATEADD(day, 1, t.pradc_StartDate)
                FROM PRAdCampaign t
                    LEFT OUTER JOIN PRAdCampaignFile t2 ON t2.pracf_AdCampaignID = t.pradc_AdCampaignID
                WHERE t.pradc_AdCampaignType LIKE 'IA%'
                    AND t.pradc_StartDate BETWEEN  GETDATE() AND DATEADD(day, @DayThreshold, GETDATE())
                    AND t2.pracf_FileName IS NULL";

        /// <summary>
        /// Go update the classification company counts.
        /// </summary>
        override public void ProcessEvent()
        {
            if (!IsBusinessHours("ImageAdVerificationBusinessHoursOnly"))
            {
                return;
            }

            DateTime dtExecutionStartDate = DateTime.Now;

            using (SqlConnection oConn = new SqlConnection(GetConnectionString()))
            {
                try {
                    oConn.Open();

                    int theshold = Utilities.GetIntConfigValue("ImageAdVerificationThreshold", 2);
                    int resultCount = 0;
                    StringBuilder results = new StringBuilder();

                    SqlCommand oSQLCommand = new SqlCommand(SQL_SELECT_BAD_ADS, oConn);
                    oSQLCommand.Parameters.AddWithValue("DayThreshold",theshold);

                    using (IDataReader reader = oSQLCommand.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            resultCount++;
                            results.Append(string.Format(" - {0}: {1}", reader.GetString(0), reader.GetString(2)) + Environment.NewLine);
                        }
                    }

                    if (resultCount > 0)
                    {
                        oSQLCommand = new SqlCommand(SQL_UPDATE_BAD_ADS, oConn);
                        oSQLCommand.Parameters.AddWithValue("DayThreshold", theshold);
                        oSQLCommand.ExecuteNonQuery();

                        string message = string.Format("{0} invalid image ad campaigns starting in the next {1} days were found.  The start date for these ad campaigns have been pushed back one day.", resultCount, theshold) + Environment.NewLine + Environment.NewLine;
                        SendMail(Utilities.GetConfigValue("ImageAdVerificationEmails", "mniemiec@bluebookservices.com, jlair@bluebookservices.com"), "Invalid Image Ads Found", message + results.ToString());

                        if (Utilities.GetBoolConfigValue("ImageAdVerificationWriteResultsToEventLog", true))
                        {
                            _oBBSMonitorService.LogEvent("ImageAdVerification Executed Successfully.");
                        }

                        if (Utilities.GetBoolConfigValue("ImageAdVerificationSendResultsToSupport", false))
                        {
                            SendMail("ImageAd Verification Success", "ImageAdVerification Executed Successfully.");
                        }

                    }

                }
                catch (Exception e)
                {
                    // This logs the error in the Event Log, Trace File,
                    // and sends the appropriate email.
                    LogEventError("Error Procesing ImageAdVerification Event.", e);
                }
            }
        }
    }
}
