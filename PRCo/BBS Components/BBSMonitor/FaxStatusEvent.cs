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

 ClassName: FaxStatusEvent.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Timers;
using PRCo.BBOS.FaxInterface;
using TSI.Utils;

namespace PRCo.BBS.BBSMonitor
{
    public class FaxStatusEvent : BBSMonitorEvent
    {
        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex)
        {
            _szName = "FaxStatusEvent";

            base.Initialize(iIndex);

            try
            {
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("FaxStatusInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("FaxStatus Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("FaxStatusStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

                _oLogger.LogMessage("FaxStatus Start: " + _dtNextDateTime.ToString());

            }
            catch (Exception e)
            {
                LogEventError("Error initializing FaxStatus event.", e);
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

                DateTime dtReportEndDate = DateTime.Now.AddHours(0 - Utilities.GetIntConfigValue("FaxStatusThreshold", 24));
                DateTime dtReportStartDate = dtReportEndDate.AddHours(0 - Utilities.GetIntConfigValue("FaxStatusThreshold", 24));
                List<FaxResult> faxResults = ConcordFaxProvider.GetFaxResponseReport(Utilities.GetConfigValue("ConcordFaxAdminLogin", "cthoms@bluebookservices.com"),
                                                                                     Utilities.GetConfigValue("ConcordFaxAdminPassword", "cc0rd_2011"),
                                                                                     Utilities.GetIntConfigValue("ConcordFaxAdminCustomerID", 138224),
                                                                                     dtReportStartDate,
                                                                                     dtReportEndDate);

                if (faxResults.Count > 0)
                {
                    using (SqlConnection oConn = new SqlConnection(GetConnectionString()))
                    {
                        try
                        {
                            sqlUpdateCommLog = null;
                            oConn.Open();

                            foreach (FaxResult faxResult in faxResults)
                            {
                                UpdateCommunicationLog(oConn, faxResult);
                            }

                        }
                        catch (Exception e)
                        {
                            // This logs the error in the Event Log, Trace File,
                            // and sends the appropriate email.
                            LogEventError("Error Procesing FaxStatus Event.", e);
                        }
                    }
                }


                string msg = "Processed failures for " + faxResults.Count.ToString("###,##0") + " faxes.";

                if (Utilities.GetBoolConfigValue("FaxStatusWriteResultsToEventLog", true))
                {
                    _oBBSMonitorService.LogEvent("FaxStatus Executed Successfully. " + msg);
                }

                if (Utilities.GetBoolConfigValue("FaxStatusSendResultsToSupport", false))
                {
                    SendMail("FaxStatus Success", msg);
                }

            }
            catch (Exception e)
            {
                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("Error Procesing FaxStatus Event.", e);
            }
        }

        private const string SQL_UPDATE_COMM_LOG =
            @"UPDATE PRCommunicationLog
                SET prcoml_Failed = 'Y',
                    prcoml_FailedMessage = @Message,
	                prcoml_UpdatedBy = -1,
	                prcoml_UpdatedDate = GETDATE()
                WHERE prcoml_TranslatedFaxID = @FaxID";


        private SqlCommand sqlUpdateCommLog = null;

        private void UpdateCommunicationLog(SqlConnection oConn, FaxResult faxResult)
        {
            if (sqlUpdateCommLog == null)
            {
                sqlUpdateCommLog = new SqlCommand();
                sqlUpdateCommLog.Connection = oConn;
                sqlUpdateCommLog.CommandText = SQL_UPDATE_COMM_LOG;
            }

            sqlUpdateCommLog.Parameters.Clear();
            sqlUpdateCommLog.Parameters.AddWithValue("FaxID", faxResult.TranslatedFaxID);
            sqlUpdateCommLog.Parameters.AddWithValue("Message", faxResult.FailedMsg);
            sqlUpdateCommLog.ExecuteNonQuery();
        }
    }
}
