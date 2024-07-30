/***********************************************************************
 Copyright Blue Book Services, Inc. 2018-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: ARAnalysisReportEvent.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.IO;
using System.Text;
using System.Timers;
using TSI.Utils;


namespace PRCo.BBS.BBSMonitor
{
    public class ARAnalysisReportEvent : BBSMonitorEvent
    {
        private int hoursThreshold;

        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex)
        {
            _szName = "ARAnalysisReportEvent";

            base.Initialize(iIndex);

            try
            {
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("ARAnalysisReportInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("ARAnalysisReport Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("ARAnalysisReportStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

                _oLogger.LogMessage("ARAnalysisReport Start: " + _dtNextDateTime.ToString());

            }
            catch (Exception e)
            {
                LogEventError("Error initializing ARAnalysisReport event.", e);
                throw;
            }
        }

        override public void ProcessEvent()
        {

            DateTime dtExecutionStartDate = DateTime.Now;
            SqlConnection oConn = new SqlConnection(GetConnectionString());
            SqlTransaction oTran = null;

            try
            {
                oConn.Open();

                List<string> lErrors = new List<string>();
                List<string> lDetails = new List<string>();

                ProcessMissingARAttnLine(oConn); //Defect 5697

                int iReportCount = 0;
                int iErrorCount = 0;

                string szContent = GetEmailTemplate("ARAnalysisReportContent.html");
                string szSubject = Utilities.GetConfigValue("ARAnalysisReportSubject", "Your Accounts Receivable Analysis Report is Attached");
                string szAttachmentName = Utilities.GetConfigValue("ARAnalysisReportAttachmentName", "AR Analysis Report.xlsx");
                string szCategory = Utilities.GetConfigValue("ARAnalysisReportCategory", string.Empty);
                string szSubcategory = Utilities.GetConfigValue("ARAnalysisReportSubcategory", string.Empty);
                bool bDoNotRecordCommunication = Utilities.GetBoolConfigValue("ARAnalysisReportDoNotRecordCommunication", false);
                
                DateTime dtDefault = DateTime.Now.AddDays(-5);
                DateTime dtLastExecutionDate = GetDateTimeCustomCaption(oConn, "ARAnalysisReportLastRunDate", dtDefault);

                hoursThreshold = Utilities.GetIntConfigValue("ARReceivalbeReportHoursTheshold", 24);
                DateTime reportPeriodStart = DateTime.Now.AddDays(0 - Utilities.GetIntConfigValue("ARAnalysisReportDays", 35)).AddHours(0 - hoursThreshold);
                DateTime reportPeriodEnd = DateTime.Now.AddHours(0 - hoursThreshold);

                List<ReportUser> lReportUsers = GetReportUsers(oConn, dtLastExecutionDate);
                ReportInterface oReportInterface = new ReportInterface();

                foreach (ReportUser oReportUser in lReportUsers)
                {
                    try
                    {
                        oTran = oConn.BeginTransaction();
                        byte[] abReport = null;

                        if (oReportUser.Invalid)
                        {
                            string[] aArgs = { "generating the AR Receivable report",
                                           oReportUser.PersonName,
                                           oReportUser.CompanyName,
                                           oReportUser.CompanyID.ToString(),
                                           "NULL AR Receivable Settings Found."};

                            lErrors.Add(string.Format(MSG_DETAIL_ERROR, aArgs));

                        }
                        else
                        {
                            iReportCount++;

                            abReport = oReportInterface.GenerateARAnalysisReport(oReportUser.CompanyID, reportPeriodStart, reportPeriodEnd);
                            _oLogger.LogMessage(string.Format("Sending to {0}, {1} at {2}", oReportUser.CompanyName, oReportUser.PersonName, oReportUser.Destination));

                            
                            string szBody = GetFormattedEmail(oConn, oTran, oReportUser.CompanyID, oReportUser.PersonID, szSubject, szContent);

                            SendReport(oTran,
                                       oReportUser,
                                       szSubject,
                                       szBody,
                                       abReport,
                                       szAttachmentName,
                                       szCategory,
                                       szSubcategory,
                                       bDoNotRecordCommunication,
                                       "AR Analysis Report Event",
                                       "HTML");
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
                            oTran = null;
                        }
                        LogEventError("Error Generating AR Analysis Report.", e);

                        string[] aArgs = { "generating the AR Analysis report",
                                           oReportUser.PersonName,
                                           oReportUser.CompanyName,
                                           oReportUser.CompanyID.ToString(),
                                           e.Message};

                        lErrors.Add(string.Format(MSG_DETAIL_ERROR, aArgs));

                        // If we exceed our max error count, abort
                        // the entire operation.
                        iErrorCount++;
                    }
                }

                UpdateDateTimeCustomCaption(oConn, "ARAnalysisReportLastRunDate", dtExecutionStartDate);

                // Now summarize what happened and log 
                // it somewhere.
                StringBuilder sbMsg = new StringBuilder("Generated reports for " + lReportUsers.Count.ToString("###,##0") + " companies.");

                if (Utilities.GetBoolConfigValue("ARAnalysisReportWriteResultsToEventLog", true))
                {
                    _oBBSMonitorService.LogEvent("AR Analysis Report Executed Successfully. " + sbMsg.ToString());
                }

                AddListToBuffer(sbMsg, lErrors, "Errors");
                if (Utilities.GetBoolConfigValue("ARAnalysisReportSendResultsToSupport", false))
                {
                    SendMail("AR Analysis Report Success", sbMsg.ToString());
                }

            }
            catch (Exception e)
            {
                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("Error Procesing ARAnalysisReport Event.", e);
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

        private const string SQL_SELECT_MISSING_ATTN_LINE_COMPANIES =
            @"SELECT DISTINCT comp_CompanyId, comp_Name FROM Company WITH (NOLOCK)
                LEFT OUTER JOIN vPRCompanyAttentionLine ON comp_CompanyID = prattn_CompanyID AND prattn_ItemCode = 'ARD'
                LEFT OUTER JOIN  PRCompanyInfoProfile prcip ON prcip.prc5_CompanyId = comp_companyid
            WHERE 
                comp_PRType = 'H'
                AND prc5_PRARReportAccess = 'Y'
                AND prc5_ARSubmitter='Y'
                AND prattn_Disabled IS NULL
	            AND
	            (
		            prattn_AttentionLineID IS NULL 
		            OR 
		            ISNULL(DeliveryAddress,'') = ''
	            )
            ORDER BY comp_Name
            ";

        private void ProcessMissingARAttnLine(SqlConnection oConn)
        {
            //Defect 5697
            string szMessage = "";
            int iCount = 0;
            SqlCommand oSQLCommand = new SqlCommand(SQL_SELECT_MISSING_ATTN_LINE_COMPANIES, oConn);

            using (SqlDataReader oReader = oSQLCommand.ExecuteReader())
            {
                while (oReader.Read())
                {
                    int BBID = oReader.GetInt32(0);
                    string CompanyName = oReader.GetString(1);
                    szMessage += string.Format("{0} - {1}\r\n", BBID, CompanyName);
                    iCount++;
                }
            }

            if (iCount > 0)
            {
                string szRecipients = Utilities.GetConfigValue("ARAnalysisReportMissingAttentionLineRecipients", "korlowski@bluebookservices.com, zchampagne@bluebookservices.com, jbrown@bluebookservices.com, vbetancourt@bluebookservices.com, tjohnson@bluebookservices.com");
                string szHeader = Utilities.GetConfigValue("ARAnalysisReportMissingAttentionLineHeader", "The following AR companies have a missing or incomplete Attention Line.\r\n");

                if (Utilities.GetBoolConfigValue("ARAnalysisReportSendMissingAttentionLineEmail", false))
                {
                    _oLogger.LogMessage(string.Format("Found {0} companies with a missing or incomplete Attention Line record.  Sending email to {1}", iCount, szRecipients));
                    SendMail(szRecipients, szHeader + "\r\n" + szMessage);
                }
                else
                {
                    //Not sending email so log results instead
                    _oLogger.LogMessage(string.Format("Found {0} companies with a missing or incomplete Attention Line record.\r\n\r\n{1}", iCount, szMessage));
                }
            }
        }

        private const string SQL_SELECT_USERS =
            @"SELECT DISTINCT comp_CompanyID,
                    comp_Name,
	                ISNULL(prattn_PersonID, 0) prattn_PersonID, 
	                Addressee,
	                DeliveryAddress
              FROM Company WITH (NOLOCK)
                   INNER JOIN PRARAging WITH (NOLOCK) ON comp_CompanyID = praa_CompanyID
                    LEFT OUTER JOIN vPRCompanyAttentionLine ON comp_CompanyID = prattn_CompanyID
	                                                        AND prattn_ItemCode = 'ARD'
                    LEFT OUTER JOIN  PRCompanyInfoProfile prcip ON prcip.prc5_CompanyId = comp_companyid
             WHERE prc5_PRARReportAccess = 'Y'
               AND comp_PRIndustryType IN ('P', 'T', 'S')
               AND praa_CreatedDate BETWEEN @BeginRange AND @EndRange";

        /// <summary>
        /// Populates the ReportUser object with the report header
        /// information.
        /// </summary>
        private List<ReportUser> GetReportUsers(SqlConnection oConn, DateTime lastExecution)
        {

            List<ReportUser> lReportUsers = new List<ReportUser>();

            SqlCommand oSQLCommand = new SqlCommand(SQL_SELECT_USERS, oConn);

            oSQLCommand.Parameters.AddWithValue("BeginRange", lastExecution.AddHours(0 - hoursThreshold));
            oSQLCommand.Parameters.AddWithValue("EndRange", DateTime.Now.AddHours(0 - hoursThreshold));
            oSQLCommand.CommandTimeout = Utilities.GetIntConfigValue("ARReceivalbeReportQueryTimeout", 300);

            using (SqlDataReader oReader = oSQLCommand.ExecuteReader()) { 
                while (oReader.Read())
                {
                    ReportUser oReportUser = new ReportUser(oReader.GetInt32(2), oReader.GetInt32(0));

                    lReportUsers.Add(oReportUser);

                    oReportUser.PersonName = oReader.GetString(3);
                    oReportUser.CompanyName = oReader.GetString(1);

                    oReportUser.Method = "email";
                    oReportUser.MethodID = DELIVERY_METHOD_EMAIL;

                    if ((oReader[4] == DBNull.Value) ||
                        (string.IsNullOrEmpty(oReader.GetString(4))))
                    {
                        oReportUser.Invalid = true;
                        oReportUser.Destination = "[NULL]";
                    }
                    else
                    {
                        oReportUser.Destination = oReader.GetString(4);
                    }
                }

                return lReportUsers;
            }
        }
    }
}
