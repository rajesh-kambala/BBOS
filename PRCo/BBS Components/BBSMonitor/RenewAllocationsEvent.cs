/***********************************************************************
 Copyright Produce Reporter Company 2006-2007

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: RenewAllocationsEvent.cs
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

namespace PRCo.BBS.BBSMonitor {

    /// <summary>
    /// Provides the functionality to renew annual service units
    /// </summary>
    public class RenewAllocationsEvent : BBSMonitorEvent {

        protected DateTime _dtExecutionDate;

        protected const string SQL_RENEW_ALLOCATIONS = "usp_RenewServiceUnitAllocations";

        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex) {
            _szName = "RenewAllocations";

            base.Initialize(iIndex);

            try {
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("RenewAllocationsInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("RenewAllocations Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("RenewAllocationsStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _dtExecutionDate = Convert.ToDateTime(Utilities.GetConfigValue("RenewAllocationsExecutionDateTime"));

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

            } catch (Exception e) {
                LogEventError("Error initializing RenewAllocations event.", e);
                throw;
            }
        }

        /// <summary>
        /// execute the stored proc to renew all "M" type service unit allocations
        /// </summary>
        override public void ProcessEvent() {


            // Determine if we should execute today.  Ignore the year portion of our execution datetime.
            // Build a new date with the execution month and day, but the current year.
            DateTime dtTempDate = new DateTime(DateTime.Now.Year, _dtExecutionDate.Month, _dtExecutionDate.Day);
            if (dtTempDate != DateTime.Today)
            {
                return;
            }

            SqlConnection oConn = new SqlConnection(GetConnectionString());

            try {

                oConn.Open();

                // Create the form records
                SqlCommand oSQLCommand = new SqlCommand(SQL_RENEW_ALLOCATIONS, oConn);
                oSQLCommand.CommandType = CommandType.StoredProcedure;
                int iCount = Convert.ToInt32(oSQLCommand.ExecuteScalar());

                string szMsg = "New Allocations Created: " + iCount.ToString();
                if (Utilities.GetBoolConfigValue("RenewAllocationsResultsToEventLog", true)) {
                    _oBBSMonitorService.LogEvent(szMsg);
                }

                if (Utilities.GetBoolConfigValue("RenewAllocationsResultsToSupport", true)) {
                    SendMail("Renew Allocations Success", szMsg);
                }


            } catch (Exception e) {
                LogEventError("Error Procesing RenewAllocations Event.", e);

                StringBuilder sbMsg = new StringBuilder();
                sbMsg.Append(MSG_ERROR);

                sbMsg.Append("\n\n" + e.Message);
                sbMsg.Append("\n\n" + e.StackTrace);
                SendMail("Renew Allocations Error", sbMsg.ToString());

            } finally {
                if (oConn != null) {
                    oConn.Close();
                }

                oConn = null;
            }
        }
    }
}
