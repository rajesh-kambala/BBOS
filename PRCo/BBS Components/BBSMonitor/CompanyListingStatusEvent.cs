/***********************************************************************
 Copyright Blue Book Services, Inc. 2014

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CompanyListingStatus.cs
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
    public class CompanyListingStatusEvent: BBSMonitorEvent {
    
        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex) {
            _szName = "CompanyListingStatusEvent";

            base.Initialize(iIndex);

            try {
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("CompanyListingStatusInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("CompanyListingStatus Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("CompanyListingStatusStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

                _oLogger.LogMessage("CompanyListingStatus Start: " + _dtNextDateTime.ToString());

            } catch (Exception e) {
                LogEventError("Error initializing CompanyListingStatus event.", e);
                throw;
            }
        }


        private const string SQL_SELECT_COMPANIES =
            @"SELECT comp_CompanyID
                  FROM Company WITH (NOLOCK)
                 WHERE comp_PRListingStatus = 'N5'
                   AND comp_PRDelistedDate <= @Threshold;";

        private const string SQL_UPDATE_COMPANY =
            @"UPDATE Company
                 SET comp_PRListingStatus='N6'
               WHERE comp_CompanyID = @CompanyID";

        /// <summary>
        /// Go update the company listing status
        /// </summary>
        override public void ProcessEvent()
        {
            DateTime dtExecutionStartDate = DateTime.Now;
            SqlTransaction sqlTran = null;

            using (SqlConnection sqlConn = new SqlConnection(GetConnectionString()))
            {
                try
                {
                    sqlConn.Open();

                    List<Int32> companyIDs = new List<int>();

                    SqlCommand sqlCommand = new SqlCommand(SQL_SELECT_COMPANIES, sqlConn);
                    sqlCommand.Parameters.AddWithValue("Threshold", DateTime.Today.AddDays(0 - Utilities.GetIntConfigValue("CompanyListingStatusRecentlyClosedThreshold", 60)));

                    using (SqlDataReader reader = sqlCommand.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            companyIDs.Add(reader.GetInt32(0));
                        }
                    }


                    foreach (int companyID in companyIDs)
                    {
                        sqlTran = sqlConn.BeginTransaction();
                        int transactionID = CreatePIKSTransaction(sqlConn, companyID, 0, null, "Changed listing status to \"Not Listed - Out of Business\".", sqlTran);

                        SqlCommand updateCompany = new SqlCommand(SQL_UPDATE_COMPANY, sqlConn, sqlTran);
                        updateCompany.Parameters.AddWithValue("CompanyID", companyID);
                        updateCompany.ExecuteNonQuery();

                        ClosePIKSTransaction(sqlConn, transactionID, sqlTran);
                        sqlTran.Commit();
                    }


                    if (Utilities.GetBoolConfigValue("CompanyListingStatusWriteResultsToEventLog", true))
                    {
                        _oBBSMonitorService.LogEvent(string.Format("CompanyListingStatus Executed Successfully.  Updated {0} companies.", companyIDs.Count));
                    }

                    if (Utilities.GetBoolConfigValue("CompanyListingStatusSendResultsToSupport", false))
                    {
                        if (companyIDs.Count > 0)
                        {
                            SendMail("Company Listing Status Event Success", string.Format("CompanyListingStatus Executed Successfully.  Updated {0} companies.", companyIDs.Count));
                        }
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
                    LogEventError("Error Procesing CompanyListingStatus Event.", e);
                }
            }
        }
    }
}
