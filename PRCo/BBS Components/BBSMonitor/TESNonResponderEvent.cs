/***********************************************************************
 Copyright Produce Reporter Company 2006-2015

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: TESFormFaxEvent.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Data;
using System.Data.SqlClient;
using System.Timers;

using TSI.Utils;

namespace PRCo.BBS.BBSMonitor {
    
    /// <summary>
    /// Provides the functionality to mark companies as TES Non-Responders
    /// when specific criteria is met.
    /// </summary>
    public class TESNonResponderEvent : BBSMonitorEvent {

        protected const string SQL_CREATE_TES_NONRESPONDER_TASKS = "usp_CreateTESNonResponderTasks";

        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex) {
            _szName = "TESNonResponder";

            base.Initialize(iIndex);

            try {
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("TESNonResponderInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("TESNonResponder Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("TESNonResponderStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

            } catch (Exception e) {
                LogEventError("Error initializing TESNonResponder event.", e);
                throw;
            }
        }

        /// <summary>
        /// Process any TES Non-Responders
        /// </summary>
        override public void ProcessEvent() {

            SqlConnection oConn = new SqlConnection(GetConnectionString());

            try {

                oConn.Open();

                // Create the form records
                SqlCommand oSQLCommand = new SqlCommand(SQL_CREATE_TES_NONRESPONDER_TASKS, oConn);
                oSQLCommand.CommandType = CommandType.StoredProcedure;
                oSQLCommand.CommandTimeout = Utilities.GetIntConfigValue("TESNonResponderQueryTimeout", 300);
                int iCount = Convert.ToInt32(oSQLCommand.ExecuteScalar());

                string szMsg = "Found " + iCount.ToString() + " TES Non-Resonders.";
                if (Utilities.GetBoolConfigValue("TESNonResponderResultsToEventLog", true)) {
                    _oBBSMonitorService.LogEvent(szMsg);
                }


            } catch (Exception e) {
                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("Error Procesing TESNonResponder Event.", e);
            } finally {
                if (oConn != null) {
                    oConn.Close();
                }

                oConn = null;
            }
        }
    }
}
