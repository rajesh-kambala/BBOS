/***********************************************************************
 Copyright Blue Book Services, Inc. 2014-2023

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CreditSheetReportProduceEvent.cs
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
    public class CreditSheetReportProduceEvent : BBSMonitorEvent
    {
        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex)
        {
            _szName = "CreditSheetReportProduce";

            base.Initialize(iIndex);

            try
            {
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("CreditSheetReportProduceInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("CreditSheetReportProduce Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("CreditSheetReportProduceStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

            }
            catch (Exception e)
            {
                LogEventError("Error initializing CreditSheetReportReport event.", e);
                throw;
            }
        }

        protected const string MSG_CSR_SUMMARY = "{0:###,###,##0} produce credit sheet reports were sent: {1:###,##0} faxed and {2:###,##0} emailed.";
        protected const string SQL_SELECT_BATCH =
            @"SELECT prcsb_CreditSheetBatchID, 
                     prcsb_ReportDateTime, 
                     prcsb_ReportHdr, 
                     prcsb_ReportMsg, 
                     prcsb_EmailImgURL, 
                     dbo.ufn_GetCustomCaptionValue('BBOS', 'URL', 'en-us') as BBOSURL,
                     prcsb_EmailURL, 
                     prcsb_Test, 
                     prcsb_TestLogons,
                     prcsb_HighlightMsg
                FROM PRCreditSheetBatch 
               WHERE prcsb_TypeCode = 'CSUPD' 
                 AND prcsb_StatusCode = 'P';";


        override public void ProcessEvent()
        {
            DateTime dtExecutionStartDate = DateTime.Now;

            SqlConnection oConn = new SqlConnection(GetConnectionString());
            SqlTransaction oTran = null;

            int reportCount = 0;
            int emailCount = 0;
            int faxCount = 0;
            int creditSheetBatchID = -1;
            int iMaxReportCount = Utilities.GetIntConfigValue("CreditSheetReportProduceMaxReportCount", 999999999);

            try
            {
                string emailContentCultureApplied;
                string emailSubjectCultureApplied;
                string culture = null;

                string szSubject = Utilities.GetConfigValue("CreditSheetReportProduceSubject", "Your Weekly Credit Sheet Update Report is Attached");
                string szSubject_S = Utilities.GetConfigValue("CreditSheetReportProduceSubject_S", "Su informe semanal de actualización de la hoja de crédito está adjunto");
                string szCategory = Utilities.GetConfigValue("CreditSheetReportProduceCategory", string.Empty);
                string szSubcategory = Utilities.GetConfigValue("CreditSheetReportProduceSubcategory", string.Empty);
                string szAttachmentName = Utilities.GetConfigValue("CreditSheetReportProduceAttachmentName", "Credit Sheet Update {0} {1} {2}.pdf");

                string szEmailTemplate = GetEmailTemplate("CreditSheetReportProduceContent.html");
                string szEmailTemplate_S = GetEmailTemplate("CreditSheetReportProduceContent_S.html");

                bool bDoNotRecordCommunication = Utilities.GetBoolConfigValue("CreditSheetReportProduceDoNotRecordCommunication", true);
                
                DateTime reportDate = DateTime.Today;
                string messageHdr = string.Empty;
                string message = string.Empty;
                string emailImgURL = string.Empty;
                string BBOSURL = string.Empty;
                string emailURL = string.Empty;
                bool isTest = false;
                bool isHighlightMarketingMsg = false;
                string testLogons = string.Empty;

                oConn.Open();
                SqlCommand cmdGetBatch = new SqlCommand(SQL_SELECT_BATCH, oConn);
                using (IDataReader reader = cmdGetBatch.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        if (reader[7] != DBNull.Value)
                        {
                            isTest = true;
                            testLogons = reader.GetString(8);
                        }
                        else
                        {
                            reportDate = reader.GetDateTime(1);
                        }

                        creditSheetBatchID = reader.GetInt32(0);
                        messageHdr = GetString(reader[2]);
                        message = GetString(reader[3]);
                        emailImgURL = GetString(reader[4]);
                        BBOSURL = GetString(reader[5]);
                        emailURL = GetString(reader[6]);

                        if(reader[9] != DBNull.Value)
                            isHighlightMarketingMsg = true;
                    }
                }

                // If there's no batch to process, then just exit.
                if (creditSheetBatchID == -1)
                    return;

                // This is the BBS Internal Ad
                if (!string.IsNullOrEmpty(emailImgURL))
                {
                    emailImgURL = "<img src=\"" + BBOSURL + emailImgURL + "\" style=\"border:0;\" />";

                    if (!string.IsNullOrEmpty(emailURL))
                    {
                        if ((!emailURL.ToLower().StartsWith("http://")) &&
                            (!emailURL.ToLower().StartsWith("https://")) &&
                            (!emailURL.ToLower().StartsWith("mailto:")))
                            emailURL = $"https://{emailURL}";

                        emailImgURL = $"<a href=\"{emailURL}\" />{emailImgURL}</a>";
                    }
                }

                string adImgURL = GetAdvertisingLink(oConn, "P", BBOSURL, "CSEU", "DIE");
                string userProfileURL = Utilities.GetConfigValue("BBOSURL") + "UserProfile.aspx";

                string emailContent = string.Format(szEmailTemplate, "email", dtExecutionStartDate.ToString("MMMM d, yyyy"), emailImgURL, userProfileURL, adImgURL);
                string emailContent_S = string.Format(szEmailTemplate_S, "email", dtExecutionStartDate.ToString("MMMM d, yyyy"), emailImgURL, userProfileURL, adImgURL);

                int minutes = DateTime.Now.Minute;

                // If this is not a test batch, then we only 
                // want to run this as the top of the hour.
                if ((!isTest) &&
                    (minutes >= Utilities.GetIntConfigValue("CreditSheetReportProduceWindow", 15)))
                {
                    // Ignore any non-test batches  
                    // unless we're in the first 15 minutes
                    // of the hour
                    return;
                }

                UpdateBatchStatus(oConn, creditSheetBatchID, "IP", dtExecutionStartDate);

                // We are going to cache the versions of the Email and Fax credit sheet
                // report using the available sort options.  Rendering this report 10 times 
                // and storing it (currently) in memory is better than 4k+ times.
                ReportInterface oReportInterface = new ReportInterface();
                Dictionary<string, byte[]> cachedReports = new Dictionary<string, byte[]>();
                List<string> sortTypes = GetSortTypes(oConn);
                byte[] abCSReport = null;
                string reportDateParm = null;

                if (!isTest)
                {
                    reportDateParm = reportDate.ToString("yyyy-MM-dd HH:mm:ss.fff");
                }

                foreach (string sortType in sortTypes)
                {
                    abCSReport = oReportInterface.GenerateCreditSheetReportFax("CSUPD", "'P','T','S'", reportDateParm, sortType, messageHdr, message);
                    cachedReports.Add(sortType + "Fax", abCSReport);

                    abCSReport = oReportInterface.GenerateCreditSheetReportEmail("CSUPD", "'P','T','S'", reportDateParm, sortType, messageHdr, message, isHighlightMarketingMsg);
                    cachedReports.Add(sortType + "Email", abCSReport);
                }

                // Build a list of recipients
                List<ReportUser> lReportUser = GetCSReportInfo(oConn, isTest, testLogons);

                HashSet<string> sentFaxNumbers = new HashSet<string>();
                StringBuilder skippedMembers = new StringBuilder();

                string fileName = null;
               
                foreach (ReportUser oReportUser in lReportUser)
                {
                    if (!oReportUser.Invalid)
                    {
                        if ((oReportUser.MethodID == DELIVERY_METHOD_FAX) &&
                            (sentFaxNumbers.Contains(oReportUser.Destination)))
                        {
                            skippedMembers.Append(oReportUser.CompanyID.ToString() + "\t" +
                                                   oReportUser.PersonID.ToString() + "\t" +
                                                   oReportUser.Destination + Environment.NewLine);
                        }
                        else
                        {

                            reportCount++;

                            if (oReportUser.MethodID == DELIVERY_METHOD_FAX)
                            {
                                faxCount++;
                                abCSReport = cachedReports[oReportUser.SortType + "Fax"];
                                sentFaxNumbers.Add(oReportUser.Destination);
                            }
                            else
                            {
                                emailCount++;
                                abCSReport = cachedReports[oReportUser.SortType + "Email"];
                            }

                            fileName = string.Format(szAttachmentName, reportDate.ToString("yyyy-MM-dd"), oReportUser.CompanyID, oReportUser.PersonID);
                            _oLogger.LogMessage(string.Format("Sending to {0}, {1} at {2}", oReportUser.CompanyName, oReportUser.PersonName, oReportUser.Destination));

                            if (oReportUser.CommunicationLanguage == "S") {
                                emailContentCultureApplied = emailContent_S;
                                emailSubjectCultureApplied = szSubject_S;
                                culture = "es-mx";
                            } else {
                                emailContentCultureApplied = emailContent;
                                emailSubjectCultureApplied = szSubject;
                                culture = "en-us";
                            }
                            string formattedEmail = GetFormattedEmail(oConn, oTran, oReportUser.CompanyID, oReportUser.PersonID, emailSubjectCultureApplied, emailContentCultureApplied, culture);

                            SendReport(oConn,
                                       null,
                                        oReportUser,
                                        emailSubjectCultureApplied,
                                        formattedEmail,
                                        abCSReport,
                                        fileName,
                                        szCategory,
                                        szSubcategory,
                                        bDoNotRecordCommunication,
                                        "Credit Sheet Report Event",
                                        "HTML");

                            if (reportCount >= iMaxReportCount)
                                break;
                        }
                    }
                }

                CompleteBatch(oConn, creditSheetBatchID, faxCount, emailCount);

                try
                {
                    SaveFile(" Email", reportDate, cachedReports["IEmail"]);
                    SaveFile(" Fax", reportDate, cachedReports["IFax"]);
                }
                catch (Exception e)
                {
                    LogEventError("Error Procesing CreditSheetReportProduce.  Unable to save PDF reports to network.  Reports sent regardless.", e);
                }

                // Now summarize what happened and log 
                // it somewhere.
                StringBuilder sbMsg = new StringBuilder();

                object[] aMsgArgs = {reportCount, 
                                     faxCount,
                                    emailCount};
                sbMsg.Append(string.Format(MSG_CSR_SUMMARY, aMsgArgs));

                TimeSpan tsDiff = DateTime.Now.Subtract(dtExecutionStartDate);
                sbMsg.Append("\n\nExecution time: " + tsDiff.ToString());

                if (Utilities.GetBoolConfigValue("CreditSheetReportProduceWriteResultsToEventLog", true))
                {
                    _oBBSMonitorService.LogEvent(sbMsg.ToString());
                }

                if (Utilities.GetBoolConfigValue("CreditSheetReportRroduceSendResultsToSupport", true))
                {
                    if (skippedMembers.Length > 0)
                    {
                        sbMsg.Append(Environment.NewLine + Environment.NewLine);
                        sbMsg.Append("The following persons were skipped due to a previous fax being sent to the same fax number." + Environment.NewLine);
                        sbMsg.Append("CompanyID\tPersonID\tFax Number" + Environment.NewLine);
                        sbMsg.Append(skippedMembers);
                    }

                    SendMail("CreditSheetReportProduce Success", sbMsg.ToString());
                }
            }
            catch (Exception e)
            {
                if (oTran != null)
                {
                    oTran.Rollback();
                }

                UpdateBatchStatus(oConn, creditSheetBatchID, "A", dtExecutionStartDate);

                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("Error Procesing CreditSheetReportProduce.", e);
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

        protected const string SQL_GET_PERSONS =
                    @"SELECT pers_PersonID, comp_CompanyID, dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_MiddleName, pers_PRNickName1, pers_Suffix) As FullName, comp_PRCorrTradestyle, 
	                       RTRIM(prwu_Email) As Email,
	                       dbo.ufn_FormatPhone(phon_CountryCode, phon_AreaCode, phon_Number, phon_PRExtension) as Fax,
	                       peli_PRCSReceiveMethod,
                           CASE peli_PRCSReceiveMethod WHEN '1' THEN dbo.ufn_FormatPhone(phon_CountryCode, phon_AreaCode, phon_Number, phon_PRExtension) WHEN '2' THEN RTRIM(prwu_Email) ELSE NULL END AS Destination,
                           peli_PRCSSortOption,
                           comp_PRCommunicationLanguage
                    FROM Person_Link WITH (NOLOCK)
                            INNER JOIN Person WITH (NOLOCK) ON peli_PersonID = pers_PersonID 
                            INNER JOIN Company WITH (NOLOCK) ON peli_CompanyID = comp_CompanyID 
                            INNER JOIN PRWebUser WITH (NOLOCK) ON peli_PersonLinkID = prwu_PersonLinkID 
                            INNER JOIN PRCompanyIndicators WITH (NOLOCK) ON peli_CompanyID = prci2_CompanyID
		                    LEFT OUTER JOIN vPRPersonEmail WITH (NOLOCK) ON peli_PersonID = elink_RecordID AND peli_CompanyID = emai_CompanyID AND elink_Type='E' AND emai_PRPreferredInternal = 'Y' 
                            LEFT OUTER JOIN vPRPersonPhone WITH (NOLOCK) ON peli_PersonID = plink_RecordID AND peli_CompanyID = phon_CompanyID AND phon_PRIsFax='Y' AND phon_PRPreferredInternal = 'Y'
                            LEFT OUTER JOIN (SELECT prcoml_CommunicationLog, prcoml_CompanyID, prcoml_PersonID  
						                       FROM PRCommunicationLog WITH (NOLOCK)
						                      WHERE prcoml_Source = 'Credit Sheet Report Event'
						                        AND CAST(prcoml_CreatedDate as Date) = CAST('{2}' as Date)) T1 ON peli_PersonID = prcoml_PersonID 
						                        AND peli_CompanyID = prcoml_CompanyID
                    WHERE peli_PRCSReceiveMethod IN ('1', '2')
                        AND comp_PRIndustryType NOT IN ('L')
                        AND peli_PRStatus In ('1', '2') 
                        AND CAST(prwu_AccessLevel as INT) > 10
                        AND prci2_Suspended IS NULL
                        AND comp_PRHQID NOT IN (SELECT prse_HQID FROM PRService WHERE prse_ServiceCode = 'EXUPD')
                        AND comp_PRIsIntlTradeAssociation IS NULL
                        {0}
                        {1}
                    ORDER BY peli_PRCSReceiveMethod DESC, comp_CompanyID, pers_PersonID";


        /// <summary>
        /// Populates the ReportUser object with the report header
        /// information.
        /// </summary>
        /// <param name="sqlConn"></param>
        /// <param name="isTest"></param>
        /// <param name="testLogons"></param>
        private List<ReportUser> GetCSReportInfo(SqlConnection sqlConn, bool isTest, string testLogons)
        {
            DateTime excludeDate = Utilities.GetDateTimeConfigValue("CreditSheetReportProduceCommLogExcludeDate", DateTime.Today);
            string excludeClause = "AND prcoml_CommunicationLog IS NULL ";
            string testClause = string.Empty;
            if (isTest)
            {
                StringBuilder logonINClause = new StringBuilder();
                string[] logons = testLogons.Split(',');
                foreach (string logon in logons)
                {
                    if (logonINClause.Length > 0)
                    {
                        logonINClause.Append(", ");
                    }
                    
                    logonINClause.Append("'");
                    logonINClause.Append(logon.Trim());
                    logonINClause.Append("'");
                }


                testClause = string.Format(" AND prwu_Email IN (SELECT RTRIM(User_EmailAddress) as Email FROM Users WHERE user_logon IN ({0})) ", logonINClause);
                excludeClause = string.Empty;  // Allow the users to test multiple times per day
            }

            List<ReportUser> lReportUsers = new List<ReportUser>();


            SqlCommand sqlCommand = new SqlCommand(string.Format(SQL_GET_PERSONS, testClause, excludeClause, excludeDate), sqlConn);
            sqlCommand.CommandTimeout = Utilities.GetIntConfigValue("CreditSheetReportProduceQueryTimeout", 300);

            using (SqlDataReader reader = sqlCommand.ExecuteReader())
            {
                while (reader.Read())
                {
                    ReportUser oReportUser = new ReportUser(reader.GetInt32(0), reader.GetInt32(1));

                    lReportUsers.Add(oReportUser);


                    oReportUser.PersonName = reader.GetString(2);
                    oReportUser.CompanyName = reader.GetString(3);

                    if (reader.GetString(6) == "1")
                    {
                        oReportUser.Method = "fax";
                        oReportUser.MethodID = DELIVERY_METHOD_FAX;
                    }
                    else
                    {
                        oReportUser.Method = "email";
                        oReportUser.MethodID = DELIVERY_METHOD_EMAIL;
                    }
                    oReportUser.Destination = GetString(reader[7]);
                    oReportUser.SortType = GetString(reader[8]);
                    oReportUser.CommunicationLanguage = GetString(reader[9]);

                    if (string.IsNullOrEmpty(oReportUser.Destination))
                    {
                        oReportUser.Invalid = true;
                    }


                }
            }
            return lReportUsers;
        }

        protected const string SQL_UPDATE_BATCH_STATUS =
            "UPDATE PRCreditSheetBatch SET prcsb_StatusCode = @StatusCode, prcsb_StartDateTime = @StartDateTime WHERE prcsb_CreditSheetBatchID = @CreditSheetBatchID;";

        private void UpdateBatchStatus(SqlConnection sqlConn, int batchID, string statusCode, DateTime startDateTime)
        {
            SqlCommand sqlCommand = new SqlCommand(SQL_UPDATE_BATCH_STATUS, sqlConn);
            sqlCommand.Parameters.AddWithValue("@CreditSheetBatchID", batchID);
            sqlCommand.Parameters.AddWithValue("@StatusCode", statusCode);
            sqlCommand.Parameters.AddWithValue("@StartDateTime", startDateTime);
            sqlCommand.ExecuteNonQuery();
        }


        protected const string SQL_COMPLETE_BATCH =
            "UPDATE PRCreditSheetBatch SET prcsb_StatusCode = @StatusCode, prcsb_EndDateTime=@EndDateiIme, prcsb_EmailCount=@EmailCount, prcsb_FaxCount=@FaxCount WHERE prcsb_CreditSheetBatchID = @CreditSheetBatchID;";

        private void CompleteBatch(SqlConnection sqlConn, int batchID, int faxCount, int emailCount)
        {
            SqlCommand sqlCommand = new SqlCommand(SQL_COMPLETE_BATCH, sqlConn);
            sqlCommand.Parameters.AddWithValue("@CreditSheetBatchID", batchID);
            sqlCommand.Parameters.AddWithValue("@StatusCode", "C");
            sqlCommand.Parameters.AddWithValue("@FaxCount", faxCount);
            sqlCommand.Parameters.AddWithValue("@EmailCount", emailCount);
            sqlCommand.Parameters.AddWithValue("@EndDateiIme", DateTime.Now);
            sqlCommand.ExecuteNonQuery();
        }

        protected const string SQL_SELECT_SORT_TYPES =
                @"SELECT RTRIM(capt_code) FROM Custom_Captions WHERE capt_family = 'peli_PRCSSortOption' ORDER BY capt_order";

        private List<string> GetSortTypes(SqlConnection sqlConn)
        {
            List<string> sortTypes = new List<string>();

            SqlCommand sqlCommand = new SqlCommand(SQL_SELECT_SORT_TYPES, sqlConn);
            using (SqlDataReader reader = sqlCommand.ExecuteReader())
            {
                while (reader.Read())
                {
                    sortTypes.Add(reader.GetString(0));
                }
            }

            return sortTypes;
        }

        private void SaveFile(string deliveyType, DateTime reportDate, byte[] abReport)
        {
            string saveFolder = Utilities.GetConfigValue("CreditSheetReportProduceExportFolder");
            string saveFileName = Path.Combine(saveFolder, string.Format(Utilities.GetConfigValue("CreditSheetReportProduceReportFileName", "Weekly Credit Sheet{0} {1}.pdf"), deliveyType, reportDate.ToString("yyyy-MM-dd")));
            if (File.Exists(saveFileName))
                File.Delete(saveFileName);

            using (FileStream oFStream = File.Create(saveFileName, abReport.Length))
            {
                oFStream.Write(abReport, 0, abReport.Length);
            }
        }


    }
}
