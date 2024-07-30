/***********************************************************************
 Copyright Blue Book Services, Inc. 2010-2016

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CalculatePayIndicatorEvent.cs
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
using BBSI.PayIndicator;

namespace PRCo.BBS.BBSMonitor {

    /// <summary>
    /// Event handler that calculates the pay indicator for eligible
    /// lumber companies.
    /// </summary>
    public class CalculatePayIndicatorEvent : BBSMonitorEvent
    {
    
        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex) {
            _szName = "CalculatePayIndicatorEvent";

            base.Initialize(iIndex);

            try {
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("CalculatePayIndicatorInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("CalculatePayIndicator Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("CalculatePayIndicatorStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

                _oLogger.LogMessage("CalculatePayIndicator Start: " + _dtNextDateTime.ToString());

            } catch (Exception e) {
                LogEventError("Error initializing CalculatePayIndicator event.", e);
                throw;
            }
        }


        protected const string SQL_SELECT_ELIGBILE_COMPANIES =
            @"SELECT * FROM vPRPayIndicatorEligibleCompany
              ORDER BY SubjectCompanyID";

        protected const string SQL_DELETE_BRANCH_PAY_INDICATOR =
           @"DELETE PRCompanyPayIndicator
	          FROM PRCompanyPayIndicator
	 	           INNER JOIN Company WITH (NOLOCK) ON comp_CompanyID = prcpi_CompanyID
	         WHERE prcpi_Current = 'Y'
	           AND comp_PRType = 'B'";

        protected const string SQL_SELECT_COMPANY_AR_DETAILS =
            @"SELECT * 
               FROM vPRPayIndicatorCompanyDetail 
              WHERE praa_Date >= DATEADD(month, @DateThreshold, GETDATE()) 
                AND SubjectCompanyID = @SubjectCompanyID ORDER BY praa_Date DESC";

        protected const string SQL_INSERT_PAY_INDICATOR =
            @"INSERT INTO PRCompanyPayIndicator (prcpi_CompanyID, prcpi_TotalCount, prcpi_CurrentCount, prcpi_CurrentAmount, prcpi_TotalAmount, prcpi_PayIndicatorScore, prcpi_PayIndicator, prcpi_Current, prcpi_CreatedBy, prcpi_CreatedDate, prcpi_UpdatedBy, prcpi_UpdatedDate, prcpi_TimeStamp) 
              VALUES (@CompanyID, @TotalCount, @CurrentCount, @CurrentAmount, @TotalAmount, @PayIndicatorScore, @PayIndicator, @Current, -1, GETDATE(), -1, GETDATE(), GETDATE())";



        protected const string DETAIL_MSG = "{0}\t{1}\t{2}\t{3}\t{4}\t{5}\t{6}\t{7}\t{8}\t{9}\t{10}\t{11}\t{12}\t{13}";
        protected const string AR_DETAIL_MSG = "{0}\t{1}\t{2}\t{3}\t{4}\t{5}\t{6}\t{7}\t{8}\t{9}\t{10}\t{11}\t{12}";

        override public void ProcessEvent()
        {

            DateTime dtExecutionStartDate = DateTime.Now;
            SqlConnection oConn = new SqlConnection(GetConnectionString());
            SqlTransaction oTran = null;

            int iCompanyCount = 0;
            int iFailedSubmitterCountThreshold = 0;
            int iFailedARDetailCountThreshold = 0;
            int iFailedARDateThreshold = 0;
            int iRemovedCurrentIndicatorCount = 0;
            int iNoRecordCreatedCount = 0;
            int iChangedIndicatorCount = 0;
            int iSameIndicatorCount = 0;
            int iNuisanceCount = 0;

            List<string> lDetails = new List<string>();

            string[] aszHeader = {"Company ID",
                                  "Submitter Count",
                                  "AR Detail Count",
                                  "Most Recent AR Date",
                                  "Old Pay Indicator",
                                  "Old Pay Indicator Score",
                                  "Current Count",
                                  "Total Count",
                                  "Current Amount",
                                  "Total Amount",
                                  "New Pay IndicatorScore",
                                  "New Pay Indicator",
                                  "Action Code",
                                  "Total Milliseconds"};

            lDetails.Add(string.Format(DETAIL_MSG, aszHeader) + Environment.NewLine);

            string[] aszARHeader = {"Subject Company ID",
                                    "AR Date",
                                    "Current Amount",
                                    "Total Amount",
                                    "Current Count",
                                    "Total Count",
                                    "Discount",
                                    "Is Valid",
                                    "Amount Current",
                                    "Amount 1-30",
                                    "Amount 31-60",
                                    "Amount 61-90",
                                    "Amount 90+"};
            List<string> lARDetails = new List<string>();
            lARDetails.Add(string.Format(AR_DETAIL_MSG, aszARHeader) + Environment.NewLine);


            try
            {
                oConn.Open();
                IList<PayIndicatorEligibleCompany> lEligibleCompanies = new List<PayIndicatorEligibleCompany>();

                SqlCommand oSQLCommand = new SqlCommand(SQL_SELECT_ELIGBILE_COMPANIES, oConn);
                using (SqlDataReader oReader = oSQLCommand.ExecuteReader())
                {
                    while (oReader.Read())
                    {
                        lEligibleCompanies.Add(new PayIndicatorEligibleCompany(oReader));
                    }

                }

                decimal dCurrentCount = 0;
                decimal dTotalCount = 0;
                decimal dCurrentAmount = 0;
                decimal dTotalDollars = 0;
                decimal dScore = 0;
                int iARDetailCount = 0;


                // Define all of our per company variables here so that we can reuse them
                // in each iteration of the loop, instead of allocating more and more memory
                // on the heap.
                DateTime dtCompanyStartDate = DateTime.Now;
                DateTime dtCompanyEndDate = DateTime.Now;
                TimeSpan tsCompanyDiff = new TimeSpan(); ;


                oTran = oConn.BeginTransaction();

                List<Int32> lSubmitterIDs = new List<int>();

                CalculatePayIndicator calculatePayIndcator = new CalculatePayIndicator();

                iCompanyCount = lEligibleCompanies.Count;
                foreach (PayIndicatorEligibleCompany pieCompany in lEligibleCompanies)
                {
                    dtCompanyStartDate = DateTime.Now;

                    calculatePayIndcator.Calculate(oConn, oTran, pieCompany);

                    if (Utilities.GetBoolConfigValue("CalculatePayIndicatorIncludeARDetailsInResults", false))
                    {
                        lARDetails.AddRange(pieCompany.ARDetails);
                    }

                    if (pieCompany.FailedSubmitterCountThreshold)
                    {
                        iFailedSubmitterCountThreshold++;
                    }

                    if (pieCompany.FailedARDetailCountThreshold)
                    {
                        iFailedARDetailCountThreshold++;
                    }

                    iARDetailCount += pieCompany.ARDetails.Count;

                    if (pieCompany.FailedARDateThreshold)
                    {
                        iFailedARDateThreshold++;
                    }

                    if (pieCompany.Nuisance)
                    {
                        iNuisanceCount++;
                    }

                    switch(pieCompany.ActionCode)
                    {
                        case "R":
                            iRemovedCurrentIndicatorCount++;
                            break;
                        case "NR":
                            iNoRecordCreatedCount++;
                            break;
                        case "C":
                            iChangedIndicatorCount++;
                            break;
                        case "UC":
                            iSameIndicatorCount++;
                            break;
                    }

                    dtCompanyEndDate = DateTime.Now;
                    tsCompanyDiff = dtCompanyEndDate.Subtract(dtCompanyStartDate);

                    object[] aArgs = {pieCompany.SubjectCompanyID,
                                      pieCompany.SubmitterCount,
                                      pieCompany.ARDetailCount,
                                      pieCompany.MostRecentARDate,
                                      pieCompany.PayIndicator,
                                      pieCompany.PayIndicatorScore,
                                      dCurrentCount,
                                      dTotalCount,
                                      dCurrentAmount,
                                      dTotalDollars,
                                      pieCompany.PayIndicator,
                                      dScore,
                                      pieCompany.ActionCode,
                                      tsCompanyDiff.TotalMilliseconds};
                    lDetails.Add(string.Format(DETAIL_MSG, aArgs) + Environment.NewLine);

                }

                SqlCommand deleteCommand = new SqlCommand(SQL_DELETE_BRANCH_PAY_INDICATOR, oConn, oTran);
                deleteCommand.ExecuteNonQuery();

                oTran.Commit();

                DateTime dtExecutionEndDateTime = DateTime.Now;

                StringBuilder sbMsg = new StringBuilder();
                sbMsg.Append("Company Count: " + iCompanyCount.ToString("###,##0") + Environment.NewLine);
                sbMsg.Append(Environment.NewLine);
                sbMsg.Append("Changed Pay Indicator Count: " + iChangedIndicatorCount.ToString("###,##0") + Environment.NewLine);
                sbMsg.Append("Unchanged Pay Indicator Count: " + iSameIndicatorCount.ToString("###,##0") + Environment.NewLine);
                sbMsg.Append("Removed Pay Indicator Count: " + iRemovedCurrentIndicatorCount.ToString("###,##0") + Environment.NewLine);
                sbMsg.Append("No Record Created Count: " + iNoRecordCreatedCount.ToString("###,##0") + Environment.NewLine);
                sbMsg.Append(Environment.NewLine);
                sbMsg.Append("Failed Submitter Threshold Count: " + iFailedSubmitterCountThreshold.ToString("###,##0") + Environment.NewLine);
                sbMsg.Append("Failed AR Detail Threshold Count: " + iFailedARDetailCountThreshold.ToString("###,##0") + Environment.NewLine);
                sbMsg.Append("Failed AR Date Threshold Count: " + iFailedARDateThreshold.ToString("###,##0") + Environment.NewLine);
                sbMsg.Append("Nuisance Skipped Count: " + iNuisanceCount.ToString("###,##0") + Environment.NewLine);
                sbMsg.Append(Environment.NewLine);
                sbMsg.Append("Start Date/Time:" + dtExecutionStartDate.ToString() + Environment.NewLine);
                sbMsg.Append("End Date/Time:" + dtExecutionEndDateTime.ToString() + Environment.NewLine);

                TimeSpan tsDiff = dtExecutionEndDateTime.Subtract(dtExecutionStartDate);
                sbMsg.Append("Execution time: " + tsDiff.ToString());

                if (Utilities.GetBoolConfigValue("CalculatePayIndicatorWriteResultsToEventLog", true))
                {
                    _oBBSMonitorService.LogEvent(sbMsg.ToString());
                }

                // Add the details after writing to the event log because the event log does have 
                // a character limit.
                if (Utilities.GetBoolConfigValue("CalculatePayIndicatorIncludeDetailsInResults", false))
                {
                    sbMsg.Append(Environment.NewLine + Environment.NewLine);
                    AddListToBuffer(sbMsg, lDetails, "Details");
                }

                if (Utilities.GetBoolConfigValue("CalculatePayIndicatorIncludeARDetailsInResults", false))
                {
                    sbMsg.Append(Environment.NewLine + Environment.NewLine);
                    AddListToBuffer(sbMsg, lARDetails, "AR Aging Details");
                }

                if (Utilities.GetBoolConfigValue("CalculatePayIndicatorSendResultsToSupport", true))
                {
                    SendMail("Calculate Pay Indicator Success", sbMsg.ToString());
                }

            }
            catch (Exception e)
            {
                if (oTran != null)
                {
                    oTran.Rollback();
                }

                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("Error Procesing CalculatePayIndicator Event.", e);

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