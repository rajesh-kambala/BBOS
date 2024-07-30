/***********************************************************************
 Copyright Blue Book Services, Inc. 2013-2017

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: SupportedRatingEvent.cs
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
    public class SupportedRatingEvent: BBSMonitorEvent
    {
        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex)
        {
            _szName = "SupportedRatingEvent";

            base.Initialize(iIndex);

            try
            {
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("SupportedRatingInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("SupportedRatingNumeral Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("SupportedRatingStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

                _oLogger.LogMessage("SupportedRating Start: " + _dtNextDateTime.ToString());

            }
            catch (Exception e)
            {
                LogEventError("Error initializing SupportedRating event.", e);
                throw;
            }
        }

//        protected const string SQL_SELECT_COMPANIES_OLD =
//          @"SELECT prcl2_CompanyID, Company.comp_Name, CityStateCountryShort, prra_RatingLine, prci_RatingUserId, prcl2_CreatedDate, CLCount
//              FROM vPRConnectionList
//                   INNER JOIN Company WITH (NOLOCK) ON prcl2_CompanyID = comp_CompanyID 
//	               INNER JOIN vPRCompanyRating ON comp_CompanyID = prra_CompanyID and prra_Current = 'Y' AND prra_Rated = 'Y'
//	               INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
//             WHERE CLCount < @CLThreshold
//               AND comp_PRListingStatus = 'L'
//               AND prra_IntegrityID IN (5, 6)
//               AND prcl2_Current = 'Y'
//               AND prcl2_CreatedDate > @LastRunDate
//          ORDER BY prcl2_CompanyID";


        protected const string SQL_SELECT_COMPANIES =
          @"SELECT prcr_LeftCompanyID, Company.comp_Name, CityStateCountryShort, prra_RatingLine, prci_RatingUserId, MAX(prcr_LastReportedDate) as LastReportedDate, COUNT(DISTINCT prcr_RightCompanyID) as CLCount
              FROM PRCompanyRelationship WITH (NOLOCK)
                   INNER JOIN Company WITH (NOLOCK) ON prcr_LeftCompanyID = comp_CompanyID 
                   INNER JOIN vPRCompanyRating ON comp_CompanyID = prra_CompanyID and prra_Current = 'Y' AND prra_Rated = 'Y'
                   INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
             WHERE prcr_Type IN ('09', '10', '11', '12', '13', '15')
               AND prcr_Active IS NOT NULL
               AND comp_PRListingStatus = 'L'
               AND prra_IntegrityID IN (5, 6)
          GROUP BY prcr_LeftCompanyID, Company.comp_Name, CityStateCountryShort, prra_RatingLine, prci_RatingUserId   
            HAVING COUNT(DISTINCT prcr_RightCompanyID) < @CLThreshold
               AND MAX(prcr_LastReportedDate) > @LastRunDate";

        protected const string TASK_MSG = "{0}, {1}, {2} is rated {4} and has only {3} companies on their connection list.";

        /// <summary>
        /// 
        /// </summary>
        override public void ProcessEvent()
        {
            DateTime dtExecutionStartDate = DateTime.Now;

            StringBuilder sbMsg = new StringBuilder();
            SqlConnection oConn = new SqlConnection(GetConnectionString());

            try
            {
                oConn.Open();

                DateTime lastExecuteDate = GetDateTimeCustomCaption(oConn, "SupportedRatingLastRunDate");

                SqlCommand sqlCommand = new SqlCommand(SQL_SELECT_COMPANIES, oConn);
                sqlCommand.CommandTimeout = 600;
                sqlCommand.Parameters.AddWithValue("CLThreshold", Utilities.GetIntConfigValue("SupportedRatingCLThreshold", 10));
                sqlCommand.Parameters.AddWithValue("LastRunDate", lastExecuteDate);

                List<Company> companies = new List<Company>();

                using (IDataReader reader = sqlCommand.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        Company company = new Company();
                        company.CompanyID = reader.GetInt32(0);
                        company.Name = reader.GetString(1);
                        company.ListingLocation = reader.GetString(2);
                        company.Rating = reader.GetString(3);
                        company.RatingAnalystID = reader.GetInt32(4);
                        company.ConnectionListCount = reader.GetInt32(6);

                        companies.Add(company);
                    }
                }


                SqlCommand taskCommand = new SqlCommand("usp_CreateTask", oConn);
                taskCommand.CommandType = CommandType.StoredProcedure;
               

                foreach (Company company in companies)
                {
                    taskCommand.Parameters.Clear();
                    taskCommand.Parameters.AddWithValue("StartDateTime", dtExecutionStartDate);
                    taskCommand.Parameters.AddWithValue("AssignedToUserId", company.RatingAnalystID);
                    taskCommand.Parameters.AddWithValue("RelatedCompanyId", company.CompanyID);
                    taskCommand.Parameters.AddWithValue("PRCategory", Utilities.GetConfigValue("SupportedRatingTaskCategory", "R"));
                    taskCommand.Parameters.AddWithValue("PRSubcategory", Utilities.GetConfigValue("SupportedRatingTaskSubcategory", string.Empty));
                    taskCommand.Parameters.AddWithValue("Status", "Pending");

                    object[] args = {company.Name, company.CompanyID, company.ListingLocation, company.ConnectionListCount, company.Rating };
                    string msg = string.Format(TASK_MSG, args);
                    taskCommand.Parameters.AddWithValue("TaskNotes", msg);

                    taskCommand.ExecuteNonQuery();

                    sbMsg.Append(company.CompanyID.ToString() + Environment.NewLine);

                }

                UpdateDateTimeCustomCaption(oConn, "SupportedRatingLastRunDate", dtExecutionStartDate);


                if (companies.Count > 0)
                {
                    sbMsg.Insert(0, string.Format("Created {0} new tasks for the following company IDs:" + Environment.NewLine + Environment.NewLine, companies.Count));
                }


                if (Utilities.GetBoolConfigValue("SupportedRatingWriteResultsToEventLog", true))
                {
                    _oBBSMonitorService.LogEvent("SupportedRatinge Executed Successfully.");
                }

                if (Utilities.GetBoolConfigValue("SupportedRatingSendResultsToSupport", false))
                {
                    SendMail("Supported Ratings Success", sbMsg.ToString());
                }

            }
            catch (Exception e)
            {
                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("Error Procesing SupportedRatings Event.", e);
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

        class Company
        {
            public int CompanyID;
            public string Name;
            public string ListingLocation;
            public int RatingAnalystID;
            public string Rating;
            public int ConnectionListCount;

        }
    }


        
}
