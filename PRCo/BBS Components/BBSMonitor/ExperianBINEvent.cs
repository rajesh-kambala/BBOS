/***********************************************************************
 Copyright Produce Reporter Company 2018-2018

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: ExperianBINEvent.cs
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

    /// <summary>
    /// Generates the Experian BIN report
    /// </summary>
    public class ExperianBINEvent : BBSMonitorEvent
    {
        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex)
        {
            _szName = "ExperianBIN";

            base.Initialize(iIndex);

            try
            {
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("ExperianBINInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("ExperianBIN Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("ExperianBINStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

            }
            catch (Exception e)
            {
                LogEventError("Error initializing ExperianBIN event.", e);
                throw;
            }
        }

        protected const string SQL_EXPERIAN_BIN_COMPANIES =
           @" SELECT DISTINCT comp_CompanyID, comp_PRListedDate
	                FROM Company
		                INNER JOIN PRWebAuditTrail ON comp_CompanyID = prwsat_CompanyID
		                LEFT OUTER JOIN PRCompanyExperian ON comp_CompanyID = prcex_CompanyID
	                WHERE comp_PRType = 'H'
	                AND comp_PRListingStatus IN ('L', 'H', 'LUV')
	                AND prcex_BIN IS NULL
                ORDER BY comp_CompanyID ASC"; //TODO: possibly add AND prcex_LastLookupDateTime criteria to make this smarter

        protected const string SQL_EXPERIAN_BIN_SEARCH =
            @" EXEC usp_ExperianBINSearch {0}, {1}";

        protected const string MSG_EXPERIAN_DETAIL = " - BBID {0}: Code: {1} Msg: {2}\n";
        protected const string MSG_EXPERIAN_SUMMARY = "A total of {0} Experian BINs were processed with {1} errors.";

        /// <summary>
        /// Process any Experian BIN updates and reports.
        /// </summary>
        override public void ProcessEvent()
        {
            DateTime dtExecutionStartDate = DateTime.Now;

            List<string> lExperianBINErrors = new List<string>();

            List<string> lExperianBINDetailsError = new List<string>();
            List<string> lExperianBINDetails0 = new List<string>();
            List<string> lExperianBINDetails1 = new List<string>();
            List<string> lExperianBINDetails2 = new List<string>();
            List<string> lExperianBINDetails3 = new List<string>();

            SqlConnection oConn = new SqlConnection(GetConnectionString());
            SqlTransaction oTran = null;

            // Get list of companies to check Experian BINs to check
            SqlCommand cmdExperianBINCompanies = new SqlCommand(SQL_EXPERIAN_BIN_COMPANIES, oConn);
            cmdExperianBINCompanies.CommandTimeout = 240;

            bool bIncludeNotMatchResults = Utilities.GetBoolConfigValue("ExperianBINIncludeNotMatch", false);

            try
            {
                oConn.Open();

                int iCompanyCount = 0;
                //Dictionary<int, int> dictResultCount = new Dictionary<int, int>(); //code, count

                int[] aryResultCount = new int[5];
                //0 = Successful Match
                //1 = Not found
                //2 = found matches, with none above threshold
                //3 = found matches, with multiple
                //999 = found matches, with multiple

                SqlDataReader drCompanies = cmdExperianBINCompanies.ExecuteReader();
                DataTable dtCompanies = new DataTable();
                dtCompanies.Load(drCompanies);

                foreach(DataRow drCompany in dtCompanies.Rows)
                {
                    oTran = oConn.BeginTransaction();

                    int iCompanyID = Convert.ToInt32(drCompany[0]);
                    iCompanyCount++;

                    try
                    {
                        SqlCommand cmdExperianBINSearch = new SqlCommand(string.Format(SQL_EXPERIAN_BIN_SEARCH, iCompanyID, -1), oConn);
                        cmdExperianBINSearch.Transaction = oTran;
                        cmdExperianBINSearch.CommandTimeout = 240;
                        using (SqlDataReader drExperian = cmdExperianBINSearch.ExecuteReader())
                        {
                            if (drExperian.Read())
                            {
                                int sCode = (int)drExperian["ReturnCode"];
                                string sMessage = (string)drExperian["Message"];

                                if (sCode == -1)
                                    aryResultCount[999] = aryResultCount[sCode] + 1;
                                else
                                    aryResultCount[sCode] = aryResultCount[sCode] + 1;

                                string[] aArgs = {  iCompanyID.ToString(),
                                                    sCode.ToString(),
                                                    sMessage };

                                switch (sCode)
                                {
                                    case -1:
                                        lExperianBINDetailsError.Add(string.Format(MSG_EXPERIAN_DETAIL, aArgs));
                                        break;
                                    case 0:
                                        lExperianBINDetails0.Add(string.Format(MSG_EXPERIAN_DETAIL, aArgs));
                                        break;
                                    case 1:
                                        lExperianBINDetails1.Add(string.Format(MSG_EXPERIAN_DETAIL, aArgs));
                                        break;
                                    case 2:
                                        lExperianBINDetails2.Add(string.Format(MSG_EXPERIAN_DETAIL, aArgs));
                                        break;
                                    case 3:
                                        lExperianBINDetails3.Add(string.Format(MSG_EXPERIAN_DETAIL, aArgs));
                                        break;
                                }
                            }
                        }

                        // Commit and set to NULL.
                        oTran.Commit();
                        oTran = null;
                    }
                    catch (Exception e)
                    {
                        if (oTran != null)
                        {
                            oTran.Rollback();
                        }

                        LogEventError("Error Generating Experian BIN event.", e);

                        string[] aArgs = { iCompanyID.ToString(), e.Message };
                        lExperianBINErrors.Add(string.Format("Error processing Experian BIN for BBID {0}: {1}", aArgs));
                    }
                }

                // Now summarize what happened and log 
                // it somewhere.
                StringBuilder sbMsg = new StringBuilder();
                
                object[] aMsgArgs = {iCompanyCount,
                                     lExperianBINErrors.Count};
                sbMsg.Append(string.Format(MSG_EXPERIAN_SUMMARY, aMsgArgs));

                sbMsg.Append("\n\nResult Counts:\n");
                sbMsg.Append(string.Format("  Successful Match: {0}\n", aryResultCount[0]));
                sbMsg.Append(string.Format("  Found Matches (With None Above Threshold): {0}\n", aryResultCount[2]));
                sbMsg.Append(string.Format("  Found Matches (With Multiple): {0}\n", aryResultCount[3]));
                sbMsg.Append(string.Format("  Errors: {0}\n", aryResultCount[4]));

                if (bIncludeNotMatchResults)
                    sbMsg.Append(string.Format("  Not Found: {0}\n", aryResultCount[1]));

                AddListToBuffer(sbMsg, lExperianBINErrors, "Errors");

                TimeSpan tsDiff = DateTime.Now.Subtract(dtExecutionStartDate);
                sbMsg.Append("\n\nExecution time: " + tsDiff.ToString());

                if (Utilities.GetBoolConfigValue("ExperianBINWriteResultsToEventLog", true))
                {
                    _oBBSMonitorService.LogEvent(sbMsg.ToString());
                }

                StringBuilder sbMsgLevel3 = new StringBuilder();

                AddListToBuffer(sbMsg, lExperianBINDetailsError, "ERRORS");

                if (Utilities.GetBoolConfigValue("ExperianBINSendResultsDetails", true))
                {
                    AddListToBuffer(sbMsg, lExperianBINDetails2, "Details (Matches With None Above Threshold)");
                    AddListToBuffer(sbMsg, lExperianBINDetails3, "Details (Matches With Multiple)");

                    if (bIncludeNotMatchResults)
                        AddListToBuffer(sbMsg, lExperianBINDetails1, "Details (Not Found)");

                    //AddListToBuffer(sbMsgSupport, lExperianBINDetails0, "Details (Successful Match)");
                }

                if (Utilities.GetBoolConfigValue("ExperianBINSendResultsToSupport", true))
                {
                    SendMail("Experian BIN Reports Success", sbMsg.ToString());
                }

                if(lExperianBINDetails3.Count > 0)
                {
                    sbMsgLevel3.Append("Experian BIN match event executed and the following CRM companies were matched to multiple records in Experian.\n\n");
                    AddListToBuffer(sbMsgLevel3, lExperianBINDetails3, "Details (Matches With Multiple)");

                    SendMail(Utilities.GetConfigValue("ExperianBINEmailCode3", "cwalls@travant.com"), "Experian BIN Report (Matches With Multiple)", sbMsgLevel3.ToString());
                }
            }
            catch (Exception e)
            {
                LogEventError("Error Procesing Experian BIN event.", e);

                StringBuilder sbMsg = new StringBuilder();
                sbMsg.Append(MSG_ERROR);

                AddListToBuffer(sbMsg, lExperianBINErrors, "Error(s)");

                sbMsg.Append("\n\n" + e.Message);
                sbMsg.Append("\n\n" + e.StackTrace);
                SendMail("Experian BIN Error", sbMsg.ToString());
            }
            finally
            {
                if (oConn != null)
                {
                    oConn.Close();
                }

                oConn = null;
                lExperianBINErrors = null;
                lExperianBINDetails0 = null;
                lExperianBINDetails1 = null;
                lExperianBINDetails2 = null;
                lExperianBINDetails3 = null;
            }
        }
    }
}