/***********************************************************************
 Copyright Blue Book Services, Inc. 2022

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact 
 by e-mail at info@travant.com

 ClassName: AdCampaignAuditSummaryEvent.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Data.SqlClient;
using System.Timers;

using TSI.Utils;

namespace PRCo.BBS.BBSMonitor
{
    public class AdCampaignAuditSummaryEvent : BBSMonitorEvent
    {
        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex)
        {
            _szName = "AdCampaignAuditSummaryEvent";

            base.Initialize(iIndex);
            _oLogger.RequestName = _szName;
            try
            {
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("AdCampaignAuditSummaryInterval", 15)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("AdCampaignAuditSummary Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("AdCampaignAuditSummaryStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

                _oLogger.LogMessage("AdCampaignAuditSummary Start: " + _dtNextDateTime.ToString());

            }
            catch (Exception e)
            {
                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("Error initializing AdCampaignAuditSummary event.", e);
                throw;
            }
        }


        private const string SQL_DELETE_AUDIT_TRAIL_SUMMARY =
            @"DELETE FROM PRAdCampaignAuditTrailSummary WHERE pradcats_DisplayDate >= @StartDate";

        private const string SQL_INSERT_AUDIT_TRAIL_SUMMARY =
            @"INSERT INTO CRM.dbo.PRAdCampaignAuditTrailSummary (pradcats_AdCampaignID, pradcats_DisplayDate, pradcats_ImpressionCount, pradcats_ClickCount)
	            SELECT pradcat_AdCampaignID,
                    CAST(pradcat_CreatedDate as Date) [DisplayDate],
		            COUNT(1) ImpressionCount,
		            COUNT(pradcat_Clicked) ClickCount
	            FROM PRAdCampaignAuditTrail WITH(NOLOCK)
	            WHERE pradcat_CreatedDate >= @StartDate
	            GROUP BY pradcat_AdCampaignID,
                    CAST(pradcat_CreatedDate as Date)
	            ORDER BY pradcat_AdCampaignID,
		            CAST(pradcat_CreatedDate as Date)";
        private const string SQL_DELETE_AUDIT_TRAIL =
            @"DELETE FROM PRAdCampaignAuditTrail WHERE pradcat_CreatedDate <= @EndDate";


        override public void ProcessEvent()
        {
            DateTime dtExecutionStartDate = DateTime.Now;

            using (SqlConnection oConn = new SqlConnection(GetConnectionString()))
            {
                try
                {
                    oConn.Open();

                    DateTime dtStartDate = DateTime.Today.AddDays(-1);

                    //Delete Yesterday and today's Audit Trail Summary records
                    SqlCommand  oSQLCommand = new SqlCommand(SQL_DELETE_AUDIT_TRAIL_SUMMARY, oConn);
                    oSQLCommand.Parameters.AddWithValue("StartDate", dtStartDate);
                    oSQLCommand.ExecuteNonQuery();

                    //Insert records
                    oSQLCommand = new SqlCommand(SQL_INSERT_AUDIT_TRAIL_SUMMARY, oConn);
                    oSQLCommand.Parameters.AddWithValue("StartDate", dtStartDate);
                    oSQLCommand.ExecuteNonQuery();

                    //Delete Audit Trail records older than yesterday.
                    DateTime dtEndDate = dtStartDate.AddDays(-1 * Utilities.GetIntConfigValue("PRAdCampaignAuditSummaryKeepDays", 1));
                    oSQLCommand = new SqlCommand(SQL_DELETE_AUDIT_TRAIL, oConn);
                    oSQLCommand.CommandTimeout = Utilities.GetIntConfigValue("PRAdCampaignAuditSummaryDeleteTimeout", 360);
                    oSQLCommand.Parameters.AddWithValue("EndDate", dtEndDate);
                    oSQLCommand.ExecuteNonQuery();

                    if (Utilities.GetBoolConfigValue("AdCampaignAuditSummaryWriteResultsToEventLog", false))
                        _oBBSMonitorService.LogEvent("The AdCampaignAuditSummary Event completed successfully.");

                    if (Utilities.GetBoolConfigValue("AdCampaignAuditSummarySendResultsToSupport", false))
                    {
                        string szSubject = "AdCampaignAuditSummary Event Success";
                        SendMail(szSubject, $"{szSubject}.");
                    }
                }
                catch (Exception e)
                {
                    // This logs the error in the Event Log, Trace File,
                    // and sends the appropriate email.
                    LogEventError("Error Procesing AdCampaignAuditSummary Event.", e);
                }
            }
        }
    }
}