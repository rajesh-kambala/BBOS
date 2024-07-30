/***********************************************************************
 Copyright Blue Book Services, Inc. 2015

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: WebServiceKeyExpirationEvent.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Data.SqlClient;
using System.Text;
using System.Timers;
using TSI.Utils;

namespace PRCo.BBS.BBSMonitor
{
    class WebServiceKeyExpirationEvent : BBSMonitorEvent
    {
        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex)
        {
            _szName = "WebServiceKeyExpirationEvent";

            base.Initialize(iIndex);

            try
            {
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("WebServiceKeyExpirationInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("WebServiceKeyExpiration Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("WebServiceKeyExpirationStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

                _oLogger.LogMessage("WebServiceKeyExpiration Start: " + _dtNextDateTime.ToString());

            }
            catch (Exception e)
            {
                LogEventError("Error initializing WebServiceKeyExpiration event.", e);
                throw;
            }
        }

 
        const string SQL_SELECT_KEYS =
              @"SELECT comp_CompanyID as BBID,
                       Company.comp_Name as [Company Name],
	                   CityStateCountryShort as [Listing Location],
	                   prwslk_LicenseKey,
	                   prwslk_ExpirationDate
                  FROM PRWebServiceLicenseKey
                       INNER JOIN Company ON prwslk_HQID = comp_CompanyID
	                   INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
                 WHERE prwslk_ExpirationDate = @TargetExpirationDate";

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

                DateTime targetExpirationDate = DateTime.Today.AddDays(Utilities.GetIntConfigValue("WebServiceKeyExpirationThreshold", 60));
                string sql = string.Format(SQL_SELECT_KEYS, targetExpirationDate);

                int keyCount = 0;
                SqlCommand sqlCommand = new SqlCommand(SQL_SELECT_KEYS, sqlConn);
                sqlCommand.Parameters.AddWithValue("TargetExpirationDate", targetExpirationDate);
                using (SqlDataReader reader = sqlCommand.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        keyCount++;
                        string[] args = {reader[0].ToString(),
                                         reader.GetString(1),
                                         reader.GetString(2),
                                         reader.GetString(3),
                                         reader.GetDateTime(4).ToShortDateString()};
                        sbMsg.Append(string.Format("BBID {0} {1}, {2} with Key {3} will expire on {4}", args) + Environment.NewLine);
                    }
                }

                string msg = null;
                if (keyCount > 0)
                {
                    msg = string.Format("Found {0} expiring web service keys", keyCount) + Environment.NewLine + Environment.NewLine;
                    msg += sbMsg.ToString();
                    SendMail(Utilities.GetConfigValue("WebServiceKeyExpirationEmails", "merickson@bluebookservices.com, korlowski@bluebookservices.com"), "Expiring Web Service Keys Found", msg);
                }


                TimeSpan tsDiff = DateTime.Now.Subtract(dtExecutionStartDate);
                msg += "\n\nExecution time: " + tsDiff.ToString();


                if (Utilities.GetBoolConfigValue("WebServiceKeyExpirationWriteResultsToEventLog", true))
                {
                    _oBBSMonitorService.LogEvent("WebServiceKeyExpiration Executed Successfully.  Found " + keyCount.ToString("###,##0") + " expiring web service keys.");
                }

                if (Utilities.GetBoolConfigValue("WebServiceKeyExpirationSendResultsToSupport", true))
                {
                    if (keyCount > 0)
                    {
                        SendMail("Web ServiceKey Expiration Success", msg);
                    }
                }


            }
            catch (Exception e)
            {
                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("Error Procesing WebServiceKeyExpiration Event.", e);
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
