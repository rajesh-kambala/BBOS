/***********************************************************************
 Copyright Blue Book Services, Inc. 2015-2020

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: DeleteCompanyEvent.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;
using System.Timers;
using TSI.Utils;

namespace PRCo.BBS.BBSMonitor
{
    class DeleteCompanyEvent : BBSMonitorEvent
    {
        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex)
        {
            _szName = "DeleteCompanyEvent";

            base.Initialize(iIndex);

            try
            {
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("DeleteCompanyInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("DeleteCompany Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("DeleteCompanyStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

                _oLogger.LogMessage("DeleteCompany Start: " + _dtNextDateTime.ToString());

            }
            catch (Exception e)
            {
                LogEventError("Error initializing DeleteCompany event.", e);
                throw;
            }
        }

 
        const string SQL_SELECT_COMPANIES =
              @"SELECT prdq_CompanyID, ISNULL(comp_Name, 'Unknown Name') comp_Name, user_logon
                  FROM PRDeleteQueue
                       INNER JOIN Company WITH (NOLOCK) ON prdq_CompanyID = comp_CompanyID
	                   INNER JOIN Users WITH (NOLOCK) ON prdq_CreatedBy = user_userid
                ORDER BY prdq_PRDeleteQueueID";

        /// <summary>
        /// Go update the classification company counts.
        /// </summary>
        override public void ProcessEvent()
        {

            DateTime dtExecutionStartDate = DateTime.Now;
            StringBuilder sbMsg = new StringBuilder();
            SqlConnection sqlConn = new SqlConnection(GetConnectionString());

            try
            {

                sqlConn.Open();

                List<Company> companies = new List<Company>();

                SqlCommand sqlCommand = new SqlCommand(SQL_SELECT_COMPANIES, sqlConn);
                using (SqlDataReader reader = sqlCommand.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        Company company = new Company(reader.GetInt32(0), reader.GetString(1), reader.GetString(2));
                        companies.Add(company);
                    }
                }

                sbMsg.Append("Deleted Companies:" + Environment.NewLine);

                SqlCommand cmdDeleteCompany = new SqlCommand("usp_DeleteCompany", sqlConn);
                cmdDeleteCompany.CommandType = System.Data.CommandType.StoredProcedure;
                cmdDeleteCompany.CommandTimeout = 600;

                SqlCommand cmdDeleteQueue = new SqlCommand("DELETE FROM PRDeleteQueue WHERE prdq_CompanyID=@CompanyID", sqlConn);

                foreach (Company company in companies)
                {
                    sbMsg.Append(company.FullName + " deleted by " + company.User + Environment.NewLine);

                    // Delete the company records
                    cmdDeleteCompany.Parameters.Clear();
                    cmdDeleteCompany.Parameters.AddWithValue("CompanyID", company.BBID);
                    cmdDeleteCompany.ExecuteNonQuery();

                    // Remove the company from the queue
                    cmdDeleteQueue.Parameters.Clear();
                    cmdDeleteQueue.Parameters.AddWithValue("CompanyID", company.BBID);
                    cmdDeleteQueue.ExecuteNonQuery();
                }

                TimeSpan tsDiff = DateTime.Now.Subtract(dtExecutionStartDate);
                sbMsg.Append("\n\nExecution time: " + tsDiff.ToString());


                if (Utilities.GetBoolConfigValue("DeleteCompanyWriteResultsToEventLog", true))
                {
                    _oBBSMonitorService.LogEvent("DeleteCompany Executed Successfully.  Deleted " + companies.Count.ToString("###,##0") + " companies.");
                }

                if (Utilities.GetBoolConfigValue("DeleteCompanySendResultsToSupport", false))
                {
                    if (companies.Count > 0)
                    {
                        string msg = string.Format("Successfully deleted {0} companies", companies.Count) + Environment.NewLine + Environment.NewLine;
                        msg += sbMsg.ToString();
                        SendMail("Delete Company Success", msg);
                    }
                }


            }
            catch (Exception e)
            {
                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("Error Procesing DeleteCompany Event.", e);
            }
            finally
            {
                if (sqlConn != null)
                {
                    sqlConn.Close();
                }

                sqlConn = null;
            }
        }

        class Company
        {
            public int BBID;
            public string FullName;
            public string User;

            public Company(int bbID, string fullName, string user)
            {
                BBID = bbID;
                FullName = fullName;
                User = user;
            }
        }
    }
}
