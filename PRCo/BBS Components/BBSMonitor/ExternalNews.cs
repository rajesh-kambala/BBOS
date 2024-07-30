/***********************************************************************
 Copyright Produce Reporter Company 2006-2014

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: ExternalNews.cs
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
using PRCo.BBOS.ExternalNews;

namespace PRCo.BBS.BBSMonitor
{
    public class ExternalNewsEvent : BBSMonitorEvent
    {

        /// <summary>
        /// Initializes the service setting up the logger, timer, etc.
        /// </summary>
        override public void Initialize(int iIndex)
        {
            _szName = "ExternalNews";

            base.Initialize(iIndex);

            try
            {

                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("ExternalNewsInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("External News Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("ExternalNewsStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

                _oLogger.LogMessage("External News Start: " + _dtNextDateTime.ToString());

            }
            catch (Exception e)
            {
                LogEventError("Error initializing ExternalNews event.", e);
                throw;
            }
        }

        /// <summary>
        /// Refreshes the news for all companies.
        /// </summary>
        override public void ProcessEvent()
        {
            try
            {
                //ExternalNewsMgr externalNewsManager = new ExternalNewsMgr();
                //externalNewsManager.RefreshAllCompanies();

                int totalDeleted = 0;
                StringBuilder sbMsg = new StringBuilder();

                using (SqlConnection oConn = new SqlConnection(GetConnectionString()))
                {
                    oConn.Open();

                    int externalNewSourceCount = Utilities.GetIntConfigValue("ExternalNewsSourceCount");
                    for (int i = 0; i < externalNewSourceCount; i++)
                    {
                        string primarySourceCode = Utilities.GetConfigValue("ExternalNewsSourceCode" + i.ToString());
                        int daysOldThreshold = Utilities.GetIntConfigValue("ExternalNewsSourceCodeDeleteDaysOld" + i.ToString());

                        DateTime deleteThreshold = DateTime.Today.AddDays(0 - daysOldThreshold);

                        int results = DeleteOldArticles(oConn, primarySourceCode, deleteThreshold);

                        totalDeleted += results;
                        sbMsg.Append(" - " + primarySourceCode + ", " + deleteThreshold.ToShortDateString() + ": " + results.ToString("###,##0") + Environment.NewLine);
                    }
                }


                if (Utilities.GetBoolConfigValue("ExternalNewsResultsToEventLog", true))
                {
                    _oBBSMonitorService.LogEvent(string.Format("Deleted {0} total articles.", totalDeleted));
                }

                if (Utilities.GetBoolConfigValue("ExternalNewsSendResultsToSupport", false))
                {
                    SendMail("External News Success", "Delete articles for the following external news sources:" + Environment.NewLine + Environment.NewLine + sbMsg.ToString());
                }
            }
            catch (Exception e)
            {
                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("External News Failed.", e);
            }
        }

        protected int DeleteOldArticles(SqlConnection oConn, string priamrySourceCode, DateTime deleteThreshold) {

            SqlCommand delete = new SqlCommand("DELETE FROM PRExternalNews WHERE pren_PrimarySourceCode=@SourceCode AND pren_PublishDateTime < @DeleteThreshold", oConn);
            delete.Parameters.AddWithValue("SourceCode", priamrySourceCode);
            delete.Parameters.AddWithValue("DeleteThreshold", deleteThreshold);

            int results = delete.ExecuteNonQuery();

            return results;
        }

    }
}
