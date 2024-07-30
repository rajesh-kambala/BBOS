/***********************************************************************
 Copyright Blue Book Services, Inc. 2013-2015

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: UpdateServiceDatesEvent.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Data;
using System.Data.SqlClient;
using System.Timers;

using TSI.Utils;

namespace PRCo.BBS.BBSMonitor
{
    public class UpdateServiceDatesEvent: BBSMonitorEvent
    {
        protected const string SQL_UPDATE_SERVICE_DATES = "usp_UpdateServiceStartEndDates";

        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex)
        {
            _szName = "UpdateServiceDates";

            base.Initialize(iIndex);

            try
            {
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("UpdateServiceDatesInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("UpdateServiceDates Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("UpdateServiceDatesStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

            }
            catch (Exception e)
            {
                LogEventError("Error initializing UpdateServiceDates event.", e);
                throw;
            }
        }

        /// <summary>
        /// execute the stored proc to renew all "M" type service unit allocations
        /// </summary>
        override public void ProcessEvent()
        {
            if (!IsBusinessHours("UpdateServiceDatesBusinessHoursOnly"))
            {
                return;
            }


            SqlConnection oConn = new SqlConnection(GetConnectionString());

            try
            {

                oConn.Open();

                // Create the form records
                SqlCommand oSQLCommand = new SqlCommand(SQL_UPDATE_SERVICE_DATES, oConn);
                oSQLCommand.CommandType = CommandType.StoredProcedure;
                oSQLCommand.CommandTimeout = 300;
                oSQLCommand.ExecuteNonQuery();

                string szMsg = "Service dates updated successfully.";
                if (Utilities.GetBoolConfigValue("UpdateServiceDatesResultsToEventLog", false))
                {
                    _oBBSMonitorService.LogEvent(szMsg);
                }

                if (Utilities.GetBoolConfigValue("UpdateServiceDatesResultsToSupport", false))
                {
                    SendMail("Update Service Dates Success", szMsg);
                }


            }
            catch (Exception e)
            {
                LogEventError("Error Procesing UpdateServiceDates Event.", e);
            }
            finally
            {
                if (oConn != null)
                {
                    oConn.Close();
                }

                oConn = null;
            }
        }
    }
}
