/***********************************************************************
 Copyright Blue Book Services, Inc. 2013-2014

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
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Timers;
using TSI.Utils;

namespace PRCo.BBS.BBSMonitor
{

    /// <summary>
    /// Event handler that calculates the number of companies assigned
    /// to each classficiation and stores the results in the PRClassification
    /// table.  
    /// </summary>
    class IndustryAverageRatingsEvent : BBSMonitorEvent
    {

        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex)
        {
            _szName = "IndustryAverageRatingsEvent";

            base.Initialize(iIndex);

            try
            {
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("IndustryAverageRatingsInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("IndustryAverageRatings Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("IndustryAverageRatingsStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

                _oLogger.LogMessage("PublishLogo Start: " + _dtNextDateTime.ToString());

            }
            catch (Exception e)
            {
                LogEventError("Error initializing IndustryAverageRatings event.", e);
            }
        }

        /// <summary>
        /// 
        /// </summary>
        override public void ProcessEvent()
        {

            DateTime dtExecutionStartDate = DateTime.Now;

            int currentPeriodMonths = Utilities.GetIntConfigValue("IndustryAverageRatingsCurrentPeriodMonths", 6);
            int previousPeriodMonths = Utilities.GetIntConfigValue("IndustryAverageRatingsPerviousPeriodMonths", 6);

            StringBuilder sbMsg = new StringBuilder();
            SqlConnection oConn = new SqlConnection(GetConnectionString());

            try
            {
                oConn.Open();

                sbMsg.Append("IndustryAverageRatings Executed Successfully." + Environment.NewLine + Environment.NewLine);

                CalcuateMetrics(oConn, sbMsg, "P", currentPeriodMonths, previousPeriodMonths);
                sbMsg.Append(Environment.NewLine);
                CalcuateMetrics(oConn, sbMsg, "T", currentPeriodMonths, previousPeriodMonths);

                DateTime dtExecutionEndDateTime = DateTime.Now;
                TimeSpan tsDiff = dtExecutionEndDateTime.Subtract(dtExecutionStartDate);
                sbMsg.Append(Environment.NewLine);
                sbMsg.Append("\n\nExecution time: " + tsDiff.ToString());


                if (Utilities.GetBoolConfigValue("IndustryAverageRatingsWriteResultsToEventLog", true))
                {
                    _oBBSMonitorService.LogEvent(sbMsg.ToString());
                }

                if (Utilities.GetBoolConfigValue("IndustryAverageRatingsSendResultsToSupport", false))
                {
                    SendMail("IndustryAverageRatings Success", sbMsg.ToString());
                }


            }
            catch (Exception e)
            {
                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("Error Procesing IndustryAverageRatings Event.", e);
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


        private void CalcuateMetrics(SqlConnection oConn,
                                     StringBuilder sbMsg,
                                     string industryType,
                                     int currentPeriodMonths,
                                     int previousPeriodMonths)
        {
            SqlCommand cmdCalcIndustryAverageRatings = new SqlCommand("usp_CalculateIndustryAverageRatings", oConn);
            cmdCalcIndustryAverageRatings.CommandTimeout = 600;  // 10 minutes
            cmdCalcIndustryAverageRatings.CommandType = CommandType.StoredProcedure;
            cmdCalcIndustryAverageRatings.Parameters.AddWithValue("CurrentPeriodMonths", currentPeriodMonths);
            cmdCalcIndustryAverageRatings.Parameters.AddWithValue("PreviousPeriodMonths", previousPeriodMonths);
            cmdCalcIndustryAverageRatings.Parameters.AddWithValue("IndustryType", industryType);


            sbMsg.Append("Industry Type = " + industryType + Environment.NewLine);
            using (IDataReader reader = cmdCalcIndustryAverageRatings.ExecuteReader())
            {
                while (reader.Read())
                {
                    string code = reader.GetString(1).Trim();
                    string value = reader.GetString(2).Trim();
                    switch (code)
                    {
                        case "IntegrityAverage_Current":
                            sbMsg.Append("Integrity Average Current Period = ");
                            break;
                        case "IntegrityAverage_Previous":
                            sbMsg.Append("Integrity Average Previous Period = ");
                            break;
                        case "PayMedian_Current":
                            sbMsg.Append("Pay Median Current Period = ");
                            break;
                        case "PayMedian_Previous":
                            sbMsg.Append("Pay Median Prevoius Period = ");
                            break;
                    }

                    sbMsg.Append(value + Environment.NewLine);
                }
            }

        }
    }
}

