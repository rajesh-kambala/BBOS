/***********************************************************************
 Copyright Blue Book Services, Inc. 2017-2018

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: OnlineRetailerEvent.cs
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

namespace PRCo.BBS.BBSMonitor
{
    class OnlineRetailerEvent: BBSMonitorEvent
    {

        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex)
        {
            _szName = "OnlineRetailerEvent";

            base.Initialize(iIndex);

            try
            {
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("OnlineRetailerInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("OnlineRetailer Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("OnlineRetailerStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

                _oLogger.LogMessage("OnlineRetailer Start: " + _dtNextDateTime.ToString());

            }
            catch (Exception e)
            {
                LogEventError("Error initializing OnlineRetailer event.", e);
                throw;
            }
        }

        const string SQL_SELECT_NEW_ONLINE_RETAILERS =
           @"SELECT c.comp_CompanyID, c.comp_Name, CityStateCountryShort
              FROM Company c WITH (NOLOCK)
                   INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
                   INNER JOIN (SELECT comp_PRHQID, COUNT(1) as CompanyCount
				                 FROM Company WITH (NOLOCK)
				                WHERE comp_PROnlineOnlyReasonCode IS NULL
				                  AND comp_PRHQID IN (SELECT comp_PRHQID FROM vPRRetailersOnlineOnly)
			                 GROUP BY comp_PRHQID) T1 ON c.comp_PRHQID = T1.comp_PRHQId
	               INNER JOIN (SELECT comp_PRHQID, COUNT(1) as CompanyCount
                                 FROM vPRRetailersOnlineOnly
                             GROUP BY comp_PRHQID) T2 ON T1.comp_PRHQId = T2.comp_PRHQID
             WHERE T1.CompanyCount = T2.CompanyCount  -- Make sure all companies in the enterprise meet the critiera
            ORDER BY c.comp_Name";

        const string SQL_SELECT_OLD_ONLINE_RETAILERS =
                @"SELECT c.comp_CompanyID, c.comp_Name, CityStateCountryShort
                  FROM Company c WITH (NOLOCK)
                       INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
                       INNER JOIN (SELECT comp_PRHQID, COUNT(1) as CompanyCount
				                     FROM Company WITH (NOLOCK)
				                    WHERE comp_PROnlineOnlyReasonCode = 'R'
			                     GROUP BY comp_PRHQID) T1 ON c.comp_PRHQID = T1.comp_PRHQId
	                   INNER JOIN (SELECT comp_PRHQID, COUNT(1) as CompanyCount
                                     FROM vPRRetailersOnlineOnly
                                 GROUP BY comp_PRHQID) T2 ON T1.comp_PRHQId = T2.comp_PRHQID
                 WHERE T1.CompanyCount <> T2.CompanyCount  -- Make sure all companies in the enterprise meet the critiera
			       AND comp_PROnlineOnlyReasonCode = 'R'
                ORDER BY c.comp_Name";

        const string SQL_SELECT_NEW_MEXICAN_ONLINE_ONLY =
           @"SELECT c.comp_CompanyID, c.comp_Name, CityStateCountryShort
              FROM Company c WITH (NOLOCK)
                   INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
                   INNER JOIN (SELECT comp_PRHQID, COUNT(1) as CompanyCount
				                 FROM Company WITH (NOLOCK)
				                WHERE comp_PROnlineOnlyReasonCode IS NULL
				                  AND comp_PRHQID IN (SELECT comp_PRHQID FROM vPRMexicanOnlineOnly)
			                 GROUP BY comp_PRHQID) T1 ON c.comp_PRHQID = T1.comp_PRHQId
	               INNER JOIN (SELECT comp_PRHQID, COUNT(1) as CompanyCount
                                 FROM vPRMexicanOnlineOnly
                             GROUP BY comp_PRHQID) T2 ON T1.comp_PRHQId = T2.comp_PRHQID
             WHERE T1.CompanyCount = T2.CompanyCount  -- Make sure all companies in the enterprise meet the critiera
            ORDER BY c.comp_Name";

        const string SQL_SELECT_OLD_MEXICAN_ONLINE_ONLY =
                @"SELECT c.comp_CompanyID, c.comp_Name, CityStateCountryShort
                  FROM Company c WITH (NOLOCK)
                       INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
                       INNER JOIN (SELECT comp_PRHQID, COUNT(1) as CompanyCount
				                     FROM Company WITH (NOLOCK)
				                    WHERE comp_PROnlineOnlyReasonCode = 'M'
			                     GROUP BY comp_PRHQID) T1 ON c.comp_PRHQID = T1.comp_PRHQId
	                   INNER JOIN (SELECT comp_PRHQID, COUNT(1) as CompanyCount
                                     FROM vPRMexicanOnlineOnly
                                 GROUP BY comp_PRHQID) T2 ON T1.comp_PRHQId = T2.comp_PRHQID
                 WHERE T1.CompanyCount <> T2.CompanyCount  -- Make sure all companies in the enterprise meet the critiera
			       AND comp_PROnlineOnlyReasonCode = 'M'
                ORDER BY c.comp_Name";

        /// <summary>
        /// Go update the classification company counts.
        /// </summary>
        override public void ProcessEvent()
        {

            DateTime dtExecutionStartDate = DateTime.Now;

            SqlConnection sqlConn = new SqlConnection(GetConnectionString());
            SqlTransaction sqlTran = null;
            try
            {
                sqlConn.Open();
                sqlTran = sqlConn.BeginTransaction();

                List<ReportUser> newOnlineRetailers = BuildCompanyList(sqlConn, sqlTran, SQL_SELECT_NEW_ONLINE_RETAILERS, "Y", "Listing online only", "R", "Per Retail Listing Logic");
                List <ReportUser> oldOnlineRetailers = BuildCompanyList(sqlConn, sqlTran, SQL_SELECT_OLD_ONLINE_RETAILERS, string.Empty, "Listing no longer online only", "R", "Per Retail Listing Logic");

                List<ReportUser> newMexicanOnline = BuildCompanyList(sqlConn, sqlTran, SQL_SELECT_NEW_MEXICAN_ONLINE_ONLY, "Y", "Listing online only", "M", "Per Mexican Online Listing Logic");
                List<ReportUser> oldMexicanOnline = BuildCompanyList(sqlConn, sqlTran, SQL_SELECT_OLD_MEXICAN_ONLINE_ONLY, string.Empty, "Listing no longer online only", "M", "Per Mexican Online Listing Logic");

                StringBuilder details = new StringBuilder("Online Retailer Success");
                details.Append(Environment.NewLine);
                

                if ((newOnlineRetailers.Count > 0) ||
                    (oldOnlineRetailers.Count > 0) ||
                    (newMexicanOnline.Count > 0) ||
                    (oldMexicanOnline.Count > 0))
                {
                    details.Append(Environment.NewLine);
                    buildDetails(newOnlineRetailers, details, "The following {0} retailers are now 'Online Only'.");
                    details.Append(Environment.NewLine);
                    buildDetails(newMexicanOnline, details, "The following {0} Mexican companies are now 'Online Only'.");
                    details.Append(Environment.NewLine);

                    buildDetails(oldOnlineRetailers, details, "The following {0} retailers are no longer 'Online Only'.");
                    details.Append(Environment.NewLine);
                    buildDetails(oldMexicanOnline, details, "The following {0} Mexican companies are no longer 'Online Only'.");

                    if (!string.IsNullOrEmpty(Utilities.GetConfigValue("OnlineRetailerUserNotification", string.Empty)))
                    {
                        SendMail(Utilities.GetConfigValue("OnlineRetailerUserNotification"), "Online Retailer Success", details.ToString());
                    }
                }

                // Now summarize what happened and log 
                // it somewhere.
                TimeSpan tsDiff = DateTime.Now.Subtract(dtExecutionStartDate);
                details.Append(Environment.NewLine);
                details.Append("Execution time: " + tsDiff.ToString());

                sqlTran.Commit();

                if (Utilities.GetBoolConfigValue("OnlineRetailerWriteResultsToEventLog", true))
                {
                    _oBBSMonitorService.LogEvent("OnlineRetailer Executed Successfully.");
                }

                if (Utilities.GetBoolConfigValue("OnlineRetailerSendResultsToSupport", false))
                {
                    SendMail("Online Retailer Success", details.ToString());
                }
            }
            catch (Exception e)
            {
                if (sqlTran != null)
                {
                    sqlTran.Rollback();
                }

                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("Error Procesing OnlineRetailer Event.", e);
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

        private const string SQL_UPDATE_COMPANY =
            @"UPDATE Company
                 SET comp_PROnlineOnlyReasonCode = @ReasonCode,
                     comp_PROnlineOnly = @Val,
                     comp_UpdatedBy = -1,
                     comp_UpdatedDate = @Start 
               WHERE comp_CompanyID = @CompanyID";

        private List<ReportUser> BuildCompanyList(SqlConnection sqlConn, SqlTransaction sqlTran, string sql, string value, string explanation, string reasonCode, string szAuthorizationInfo)
        {
            List<ReportUser> companyList = new List<ReportUser>();

            SqlCommand sqlCommand = new SqlCommand(sql, sqlConn, sqlTran);
            sqlCommand.CommandTimeout = Utilities.GetIntConfigValue("OnlineRetailerQueryTimeout", 300);

            using (SqlDataReader reader = sqlCommand.ExecuteReader())
            {
                while (reader.Read())
                {
                    ReportUser oReportUser = new ReportUser(0, reader.GetInt32(0));
                    companyList.Add(oReportUser);
                    oReportUser.CompanyName = reader.GetString(1);
                }
            }

            int transactionID = 0;
            SqlCommand updCommand = new SqlCommand(SQL_UPDATE_COMPANY, sqlConn, sqlTran);
            updCommand.Parameters.AddWithValue("CompanyID", 0);
            updCommand.Parameters.AddWithValue("Val", "");
            updCommand.Parameters.AddWithValue("Start", DateTime.Now);
            updCommand.Parameters.AddWithValue("ReasonCode", "");

            foreach (ReportUser oReportUser in companyList)
            {
                transactionID = CreatePIKSTransaction(sqlConn, oReportUser.CompanyID, 0, szAuthorizationInfo, explanation, sqlTran);

                updCommand.Parameters[0].Value = oReportUser.CompanyID;

                if (string.IsNullOrEmpty(value))
                {
                    updCommand.Parameters[1].Value = DBNull.Value;
                } else
                {
                    updCommand.Parameters[1].Value = value;
                }

                if (string.IsNullOrEmpty(reasonCode))
                {
                    updCommand.Parameters[3].Value = DBNull.Value;
                }
                else
                {
                    updCommand.Parameters[3].Value = reasonCode;
                }

                updCommand.ExecuteNonQuery();

                ClosePIKSTransaction(sqlConn, transactionID, sqlTran);
            }

            return companyList;
        }

        private void buildDetails(List<ReportUser> companyList, StringBuilder details, string headerMsg)
        {
            if (companyList.Count > 0)
            {
                details.Append(string.Format(headerMsg, companyList.Count) + Environment.NewLine);
                foreach (ReportUser oReportUser in companyList)
                {
                    details.Append(string.Format(" - BB# {0} {1}", oReportUser.CompanyID, oReportUser.CompanyName) + Environment.NewLine);
                }
            }
        }
    }
}
