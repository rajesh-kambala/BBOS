/* RSH TODO: 
   2. Make number of surveys a parameter (already available in storedproc).
*/

/***********************************************************************
 Copyright Produce Reporter Company 2006-2021

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: SurveyEvent.cs
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
    /// <summary>
    /// Provides the functionality to send out customer surveys on
    /// a periodic basis.
    /// </summary>
    public class SurveyEvent : BBSMonitorEvent {

        protected const string SQL_CS_SURVEYS = "usp_SendCSSurveys";
        protected const string SQL_SS_SURVEYS = "usp_SendSSSurveys";

        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex) {
            _szName = "Survey";

            base.Initialize(iIndex);

            try {
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("SurveyInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("Survey Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("SurveyStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

            } catch (Exception e) {
                LogEventError("Error initializing Survey event.", e);
                throw;
            }
        }

        /// <summary>
        /// execute the stored proc to fax out customer service surveys
        /// </summary>
        override public void ProcessEvent() {
            SendCustomerServiceSurvey();
            SendSpecialServiceSurvey();
        }

        private void SendCustomerServiceSurvey()
        {
            // We actually only run once a week, on Mondays
            if (DateTime.Today.DayOfWeek != GetDayOfWeek(Utilities.GetConfigValue("CSSurveyDayOfWeek", "Monday")))
            {
                return;
            }

            DateTime dtExecutionStartDate = DateTime.Now;
            StringBuilder sbMsg = new StringBuilder();

            SqlConnection oConn = new SqlConnection(GetConnectionString());

            try
            {
                oConn.Open();

                // Create the form records
                SqlCommand oSQLCommand = new SqlCommand(SQL_CS_SURVEYS, oConn);
                oSQLCommand.CommandType = CommandType.StoredProcedure;
                oSQLCommand.CommandTimeout = Utilities.GetIntConfigValue("SurveyQueryTimeout", 300);
                
                int iCount = 0;
                object oCount = oSQLCommand.ExecuteScalar();
                if (oCount == null || oCount == System.DBNull.Value)
                    iCount = 0;
                else
                {
                    try
                    {
                        iCount = Convert.ToInt32(oCount);
                    } catch (FormatException fE)
                    {
                        throw new ApplicationException($"Returned oCount={oCount}", fE);
                    }
                }

                sbMsg.Append($"Surveys Sent: {iCount}");

                TimeSpan tsDiff = DateTime.Now.Subtract(dtExecutionStartDate);
                sbMsg.Append("\n\nExecution time: " + tsDiff.ToString());

                if (Utilities.GetBoolConfigValue("CSSurveyResultsToEventLog", true))
                {
                    _oBBSMonitorService.LogEvent(sbMsg.ToString());
                }

                if (Utilities.GetBoolConfigValue("CSSurveyResultsToSupport", true))
                {
                    SendMail("Customer Service Survey Success", sbMsg.ToString());
                }
            }
            catch (Exception e)
            {
                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("Error Procesing CSSurvey Event.", e);
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

        private void SendSpecialServiceSurvey()
        {
            // We actually only run once a week, on Mondays
            if (DateTime.Today.DayOfWeek != GetDayOfWeek(Utilities.GetConfigValue("SSSurveyDayOfWeek", "Monday")))
            {
                return;
            }

            DateTime dtExecutionStartDate = DateTime.Now;
            StringBuilder sbMsg = new StringBuilder();

            SqlConnection oConn = new SqlConnection(GetConnectionString());

            try
            {
                oConn.Open();

                // Create the form records
                SqlCommand oSQLCommand = new SqlCommand(SQL_SS_SURVEYS, oConn); 
                oSQLCommand.CommandType = CommandType.StoredProcedure;
                oSQLCommand.CommandTimeout = Utilities.GetIntConfigValue("SurveyQueryTimeout", 300);

                int iCount = 0;
                object oCount = oSQLCommand.ExecuteScalar();
                if (oCount == null || oCount == System.DBNull.Value)
                    iCount = 0;
                else
                {
                    try
                    {
                        iCount = Convert.ToInt32(oCount);
                    }
                    catch (FormatException fE)
                    {
                        throw new ApplicationException($"Returned oCount={oCount}", fE);
                    }
                }

                sbMsg.Append($"Surveys Sent: {iCount}");

                TimeSpan tsDiff = DateTime.Now.Subtract(dtExecutionStartDate);
                sbMsg.Append("\n\nExecution time: " + tsDiff.ToString());

                if (Utilities.GetBoolConfigValue("SSSurveyResultsToEventLog", true))
                {
                    _oBBSMonitorService.LogEvent(sbMsg.ToString());
                }

                if (Utilities.GetBoolConfigValue("SSSurveyResultsToSupport", true))
                {
                    SendMail("Special Service Survey Success", sbMsg.ToString());
                }
            }
            catch (Exception e)
            {
                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("Error Procesing SSSurvey Event.", e);
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

        protected DayOfWeek GetDayOfWeek(string szDayOfWeek) {
            switch (szDayOfWeek.Substring(0, 2).ToLower()) {
                case "mo": return DayOfWeek.Monday;
                case "tu": return DayOfWeek.Tuesday;
                case "we": return DayOfWeek.Wednesday;
                case "th": return DayOfWeek.Thursday;
                case "fr": return DayOfWeek.Friday;
                case "sa": return DayOfWeek.Thursday;
                case "su": return DayOfWeek.Sunday;
            }

            throw new Exception("Invalid day of week: " + szDayOfWeek);
        }

    }
}
