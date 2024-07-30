/***********************************************************************
 Copyright Blue Book Services, Inc. 2011

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: ExpireRatingNumeralEvent.cs
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
    public class ExpireRatingNumeralEvent : BBSMonitorEvent
    {
        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex) {
            _szName = "ExpireRatingNumeralEvent";

            base.Initialize(iIndex);

            try {
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("ExpireRatingNumeralInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("ExpireRatingNumeral Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("ExpireRatingNumeralStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

                _oLogger.LogMessage("ExpireRatingNumeral Start: " + _dtNextDateTime.ToString());

            } catch (Exception e) {
                LogEventError("Error initializing ExpireRatingNumeral event.", e);
                throw;
            }
        }

  
        
        /// <summary>
        /// Go expire the appropriate rating numerals.
        /// </summary>
        override public void ProcessEvent()
        {

            DateTime dtExecutionStartDate = DateTime.Now;

            try
            {
                StringBuilder sbMsg = new StringBuilder();

                List<int> expiredCompanyIDs = ExpireRatingNumeral("55");
                BuildResultsMsg(sbMsg, "55", expiredCompanyIDs);

                expiredCompanyIDs = ExpireRatingNumeral("56");
                BuildResultsMsg(sbMsg, "56", expiredCompanyIDs);

                expiredCompanyIDs = ExpireRatingNumeral("58");
                BuildResultsMsg(sbMsg, "58", expiredCompanyIDs);

                if (Utilities.GetBoolConfigValue("ExpireRatingNumeralWriteResultsToEventLog", true))
                {
                    _oBBSMonitorService.LogEvent("ExpireRatingNumeral Executed Successfully.");
                }

                if (Utilities.GetBoolConfigValue("ExpireRatingNumeralSendResultsToSupport", false))
                {
                    if (sbMsg.Length > 0) {
                        SendMail("Expire Rating Numerals Success", sbMsg.ToString());
                    }
                }


            }
            catch (Exception e)
            {
                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("Error Procesing ExpireRatingNumeral Event.", e);
            }
        }
        protected const string SQL_SELECT_RATINGS =
            @"SELECT prra_CompanyID, prra_RatingID, max(prcs_PublishableDate) As RatingNumeralAssignedDate
                FROM PRRatingNumeralAssigned
                     INNER JOIN PRRating ON pran_RatingID = prra_RatingID AND prra_Current = 'Y'
                     INNER JOIN Company on prra_CompanyID = comp_CompanyID
                     INNER JOIN PRCreditSheet ON prra_CompanyID = prcs_CompanyID
               WHERE pran_RatingNumeralID = {0}
                 AND comp_PRListingStatus IN ('L', 'H')
                 AND prcs_Status = 'P'
                 AND (prcs_Numeral LIKE '%({0})%'
                      OR prcs_Change LIKE '%({0})%')
            GROUP BY prra_CompanyID, prra_RatingID";

        protected List<int> ExpireRatingNumeral(string ratingNumeral)
        {
            List<int> expiredCompanyIDs = new List<int>();
            SqlConnection oConn = new SqlConnection(GetConnectionString());

            try {
                oConn.Open();

                string szSQL = string.Format(SQL_SELECT_RATINGS, ratingNumeral);
                _oLogger.LogMessage(szSQL);
                SqlCommand oSQLCommand = new SqlCommand(szSQL, oConn);
                using (IDataReader reader = oSQLCommand.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        int companyID = reader.GetInt32(0);
                        int ratingID = reader.GetInt32(1);
                        DateTime ratingNumberAssignedDate = reader.GetDateTime(2);

                        if (ratingNumberAssignedDate.AddDays(Utilities.GetIntConfigValue("ExpireRatingNumeralThreshold", 60)) < DateTime.Now)
                        {
                            _oLogger.LogMessage("Removing rating numeral (" + ratingNumeral + ") from " + companyID.ToString());
                            RemoveRatingNumeral(companyID, ratingID, ratingNumeral);
                            expiredCompanyIDs.Add(companyID);
                        }
                    }
                }

                return expiredCompanyIDs;
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

        protected const string INSERT_RATING =
            @"INSERT INTO PRRating
			      (prra_RatingId, prra_CreatedBy, prra_CreatedDate, prra_UpdatedBy, prra_UpdatedDate, prra_TimeStamp,
				   prra_CompanyId, prra_Date, prra_Current, prra_CreditWorthId, prra_IntegrityId, prra_PayRatingId, prra_InternalAnalysis, prra_PublishedAnalysis)
			SELECT {1},  -1, GETDATE(), -1, GETDATE(), GETDATE(), 
				   prra_CompanyId, GETDATE(), 'Y', prra_CreditWorthId, prra_IntegrityId, prra_PayRatingId, prra_InternalAnalysis, prra_PublishedAnalysis
			  FROM PRRating 
			 WHERE prra_Current = 'Y' 
               AND prra_CompanyId = {0}";

        protected const string INSERT_RATING_NUMERALS =
            @"INSERT INTO PRRatingNumeralAssigned
				(pran_RatingNumeralAssignedId, pran_CreatedBy, pran_CreatedDate, pran_UpdatedBy, pran_UpdatedDate, pran_TimeStamp,
						 pran_RatingId, pran_RatingNumeralId)
				SELECT NULL, -1, GETDATE(), -1, GETDATE(), GETDATE(), 
						 {1}, pran_RatingNumeralId
				  FROM PRRatingNumeralAssigned
			     WHERE pran_RatingID = {0}
				   AND pran_RatingNumeralId <> {2}";


        protected void RemoveRatingNumeral(int companyID, int ratingID, string ratingNumeral)
        {
            SqlTransaction oTran = null;
            SqlConnection oConn = new SqlConnection(GetConnectionString());
            oConn.Open();

            try
            {
                oTran = oConn.BeginTransaction();

                int transactionID = CreatePIKSTransaction(oConn, companyID, 0, null, "Rating numeral (" + ratingNumeral + ") expired.", oTran);
                int newRatingID = GetRecordID(oConn, "PRRating", oTran);

                string szSQL = string.Format(INSERT_RATING, companyID, newRatingID);
                _oLogger.LogMessage(szSQL);
                SqlCommand commandInsertRating = new SqlCommand(szSQL, oConn, oTran);
                commandInsertRating.ExecuteNonQuery();

                szSQL = string.Format(INSERT_RATING_NUMERALS, ratingID, newRatingID, ratingNumeral);
                _oLogger.LogMessage(szSQL);
                SqlCommand commandInsertNumerals = new SqlCommand(szSQL, oConn, oTran);
                commandInsertNumerals.ExecuteNonQuery();


                ClosePIKSTransaction(oConn, transactionID, oTran);
                oTran.Commit();
            }
            catch
            {
                if (oTran != null)
                {
                    oTran.Rollback();
                }
                throw;
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

        protected void BuildResultsMsg(StringBuilder sbMsg, string ratingNumeral, List<int> expiredCompanyIDs)
        {
            if (expiredCompanyIDs.Count > 0)
            {
                if (sbMsg.Length > 0)
                {
                    sbMsg.Append(Environment.NewLine + Environment.NewLine);
                }
                sbMsg.Append(string.Format("Expired rating numeral {0} on the following {1} companies:" + Environment.NewLine, ratingNumeral, expiredCompanyIDs.Count));
                foreach (int companyID in expiredCompanyIDs)
                {
                    sbMsg.Append(" - " + companyID.ToString() + Environment.NewLine);
                }
            }
        }
    }
}

