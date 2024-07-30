/***********************************************************************
 Copyright Blue Book Services, Inc. 2011-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: PublishLogoEvent.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Timers;
using TSI.Utils;

namespace PRCo.BBS.BBSMonitor {

    /// <summary>
    /// Event handler that calculates the number of companies assigned
    /// to each classficiation and stores the results in the PRClassification
    /// table.  
    /// </summary>
    class PublishLogoEvent : BBSMonitorEvent {
    
        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex) {
            _szName = "PublishLogoEvent";

            base.Initialize(iIndex);

            try {
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("PublishLogoInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("PublishLogo Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("PublishLogoStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

                _oLogger.LogMessage("PublishLogo Start: " + _dtNextDateTime.ToString());

            } catch (Exception e) {
                LogEventError("Error initializing PublishLogo event.", e);
                throw;
            }
        }

        const string SQL_SELECT_UNPUBLISHED_LOGOS =
           @"SELECT DISTINCT comp_CompanyID, comp_PRLogo 
              FROM Company WITH (NOLOCK) 
                   INNER JOIN PRService WITH (NOLOCK) ON comp_CompanyID = prse_CompanyID 
             WHERE prse_ServiceCode IN ('LOGO', 'LMBLOGO', 'LOGO-ADD', 'LMBLOGO-ADD')
               AND comp_PRLogo IS NOT NULL 
               AND comp_PRPublishLogo IS NULL
               AND comp_PRLocalSource IS NULL;";

        const string SQL_PUBLISH_LOGOS =
            @"UPDATE Company 
               SET comp_PRPublishLogo = 'Y', 
                   comp_UpdatedBy = -1, 
                   comp_UpdatedDate = GETDATE(), 
                   comp_TimeStamp = GETDATE() 
             WHERE comp_CompanyID IN ({0})
               --AND comp_PRHQId NOT IN (SELECT prse_HQID FROM PRService WHERE prse_ServiceCode IN ('STANDARD', 'PREMIUM', 'ENTERPRISE'))
               AND comp_PRLocalSource IS NULL;";

        const string SQL_UPDATE_CANCELLED_LOGOS =
            @"UPDATE Company 
                 SET comp_PRPublishLogo = NULL 
               WHERE comp_PRPublishLogo = 'Y' 
                 AND comp_PRHQId NOT IN (SELECT prse_HQID FROM PRService WHERE prse_ServiceCode IN ('STANDARD', 'PREMIUM', 'ENTERPRISE'))
                 AND comp_PRHQId NOT IN ( 
		               SELECT prse_HQID 
			             FROM PRService 
			            WHERE prse_ServiceCode IN ('LOGO', 'LMBLOGO', 'LOGO-ADD', 'LMBLOGO-ADD'))
                 AND comp_PRLocalSource IS NULL;";

        /// <summary>
        /// 
        /// </summary>
        override public void ProcessEvent() {

            if (!IsBusinessHours("PublishLogoBusinessHoursOnly"))
                return;

            DateTime dtExecutionStartDate = DateTime.Now;

            int publishCount = 0;
            int cancelCount = 0;
            int notFoundCount = 0;
            StringBuilder sbPublishLogos = new StringBuilder();
            StringBuilder sbNotFoundLogos = new StringBuilder();
            string logoRoot = Utilities.GetConfigValue("LogoRootPath", @"\\bhs2\Logos\");

            SqlConnection oConn = new SqlConnection(GetConnectionString());

            try {
                oConn.Open();

                SqlCommand oSQLUnpublishLogos = new SqlCommand(SQL_SELECT_UNPUBLISHED_LOGOS, oConn);
                using (IDataReader reader = oSQLUnpublishLogos.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string logoFile = Path.Combine(logoRoot, reader.GetString(1));
                        if (File.Exists(logoFile))
                        {
                            if (sbPublishLogos.Length > 0)
                                sbPublishLogos.Append(",");

                            sbPublishLogos.Append(reader.GetInt32(0).ToString());
                        }
                        else
                        {
                            sbNotFoundLogos.Append(logoFile + Environment.NewLine);
                            notFoundCount++;
                        }
                    }
                }

                if (sbPublishLogos.Length > 0)
                {
                    string sql = string.Format(SQL_PUBLISH_LOGOS, sbPublishLogos.ToString());
                    _oLogger.LogMessage(sql);
                    SqlCommand oSQLPublishLogos = new SqlCommand(sql, oConn);
                    publishCount = oSQLPublishLogos.ExecuteNonQuery();
                }

                _oLogger.LogMessage(SQL_UPDATE_CANCELLED_LOGOS);
                SqlCommand oSQLCancelLogos = new SqlCommand(SQL_UPDATE_CANCELLED_LOGOS, oConn);
                cancelCount = oSQLCancelLogos.ExecuteNonQuery();

                StringBuilder sbMsg = new StringBuilder();
                sbMsg.Append("PublishLogo Executed Successfully." + Environment.NewLine + Environment.NewLine);
                sbMsg.Append("Logos Published: " + publishCount.ToString("###,##0") + Environment.NewLine);
                sbMsg.Append("Logos Cancelled: " + cancelCount.ToString("###,##0") + Environment.NewLine);
                sbMsg.Append("Logos Not Found: " + notFoundCount.ToString("###,##0") + Environment.NewLine);
                
                if (Utilities.GetBoolConfigValue("PublishLogoWriteResultsToEventLog", true))
                    _oBBSMonitorService.LogEvent(sbMsg.ToString());

                if (Utilities.GetBoolConfigValue("PublishLogoSendResultsToSupport", false))
                {
                    if (notFoundCount > 0)
                    {
                        sbMsg.Append(Environment.NewLine + "Image Files Not Found" + Environment.NewLine);
                        sbMsg.Append("=====================" + Environment.NewLine);
                        sbMsg.Append(sbNotFoundLogos);
                    }

                    SendMail("PublishLogo Success", sbMsg.ToString());
                }

            } catch (Exception e) {
                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("Error Procesing PublishLogo Event.", e);
            } finally {
                if (oConn != null) 
                    oConn.Close();

                oConn = null;
            }
        }
    }
}

