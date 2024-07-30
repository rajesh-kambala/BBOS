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
    public class ExpressUpdateReportProduceEvent : BBSMonitorEvent
    {
        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex)
        {
            _szName = "ExpressUpdateReportProduce";

            base.Initialize(iIndex);

            try
            {
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("ExpressUpdateReportProduceInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("ExpressUpdateReportProduce Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("ExpressUpdateReportProduceStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

            }
            catch (Exception e)
            {
                LogEventError("Error initializing ExpressUpdateReportProduce event.", e);
                throw;
            }
        }

        protected const string MSG_CSR_SUMMARY = "{0:###,###,##0} express update credit sheet reports were sent: {1:###,##0} faxed and {2:###,##0} emailed.";
        protected const string SQL_SELECT_BATCH =
            @"SELECT prcsb_CreditSheetBatchID, prcsb_ReportDateTime, prcsb_ReportHdr, prcsb_ReportMsg, prcsb_EmailImgURL, dbo.ufn_GetCustomCaptionValue('BBOS', 'URL', 'en-us') as BBOSURL, prcsb_EmailURL
                FROM PRCreditSheetBatch 
               WHERE prcsb_TypeCode = 'EXUPD' 
                 AND prcsb_StatusCode = 'S';";

        protected const string SQL_UDPATE_EX_PUBDATE =
                @"UPDATE PRCreditSheet 
                     SET prcs_ExpressUpdatePubDate = @ReportDate, 
                         prcs_UpdatedBy = -1, 
                         prcs_UpdatedDate = GETDATE(), 
                         prcs_Timestamp = GETDATE() 
                    FROM PRCreditSheet 
                         INNER JOIN Company ON prcs_CompanyID = comp_CompanyID 
                   WHERE comp_PRIndustryType <> 'L' 
                     AND prcs_Status = 'P' 
                     AND prcs_ExpressUpdatePubDate IS NULL";

        override public void ProcessEvent()
        {
            DateTime dtExecutionStartDate = DateTime.Now;

            SqlConnection oConn = new SqlConnection(GetConnectionString());
            SqlTransaction oTran = null;

            int reportCount = 0;
            int emailCount = 0;
            int faxCount = 0;
            int creditSheetBatchID = -1;
            int iMaxReportCount = Utilities.GetIntConfigValue("ExpressUpdateReportProduceMaxReportCount", 999999999);

            try
            {
                string emailContentCultureApplied;
                string emailSubjectCultureApplied;
                string culture;

                string szSubject = Utilities.GetConfigValue("ExpressUpdateReportProduceSubject", "Your Daily Express Update Report is Attached");
                string szSubject_S = Utilities.GetConfigValue("CreditSheetReportProduceSubject_S", "Se adjunta su informe de actualización de Daily Express");
                string szCategory = Utilities.GetConfigValue("ExpressUpdateReportProduceCategory", string.Empty);
                string szSubcategory = Utilities.GetConfigValue("ExpressUpdateReportProduceSubcategory", string.Empty);
                string szAttachmentName = Utilities.GetConfigValue("ExpressUpdateReportProduceAttachmentName", "Express Update {0} {1} {2}.pdf");

                string szEmailTemplate = GetEmailTemplate("ExpressUpdateReportProduceContent.html");
                string szEmailTemplate_S = GetEmailTemplate("ExpressUpdateReportProduceContent_S.html");

                bool bDoNotRecordCommunication = Utilities.GetBoolConfigValue("ExpressUpdateReportProduceDoNotRecordCommunication", true);

                oConn.Open();

                DateTime reportDate = DateTime.Now;

                SqlCommand cmdUpdateEXPubDate = new SqlCommand(SQL_UDPATE_EX_PUBDATE, oConn);
                cmdUpdateEXPubDate.CommandTimeout = Utilities.GetIntConfigValue("ExpressUpdateReportProduceQueryTimeout", 300);
                cmdUpdateEXPubDate.Parameters.AddWithValue("ReportDate", reportDate);
                int itemCount = cmdUpdateEXPubDate.ExecuteNonQuery();

                _oLogger.LogMessage("ItemCount: " + itemCount.ToString("###,##0"));

                HashSet<string> sentFaxNumbers = new HashSet<string>();
                StringBuilder skippedMembers = new StringBuilder();

                if (itemCount > 0)
                {
                    string messageHdr = string.Empty;
                    string message = string.Empty;
                    string emailImgURL = string.Empty;
                    string BBOSURL = string.Empty;
                    string emailURL = string.Empty;

                    SqlCommand cmdGetBatch = new SqlCommand(SQL_SELECT_BATCH, oConn);
                    using (IDataReader reader = cmdGetBatch.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            creditSheetBatchID = reader.GetInt32(0);
                            messageHdr = GetString(reader[2]);
                            message = GetString(reader[3]);
                            emailImgURL = GetString(reader[4]);
                            BBOSURL = GetString(reader[5]);
                            emailURL = GetString(reader[6]);
                        }
                    }

                    if (!string.IsNullOrEmpty(emailImgURL))
                    {
                        emailImgURL = "<img src=\"" + BBOSURL + emailImgURL + "\" />";

                        if (!string.IsNullOrEmpty(emailURL))
                        {
                            if ((!emailURL.ToLower().StartsWith("http://")) &&
                                (!emailURL.ToLower().StartsWith("https://")) &&
                                (!emailURL.ToLower().StartsWith("mailto:")))
                            {
                                emailURL = "http://" + emailURL;
                            }

                            emailImgURL = "<a href=\"" + emailURL + "\" />" + emailImgURL + "</a>"; ;
                        }
                    }

                    string adImgURL = GetAdvertisingLink(oConn, "P", BBOSURL, "CSEU", "DIE");
                    string userProfileURL = Utilities.GetConfigValue("BBOSURL") + "UserProfile.aspx";
                    string emailContent = string.Format(szEmailTemplate, "email", dtExecutionStartDate.ToString("MMMM d, yyyy"), emailImgURL, userProfileURL, adImgURL);
                    string emailContent_S = string.Format(szEmailTemplate_S, "email", dtExecutionStartDate.ToString("MMMM d, yyyy"), emailImgURL, userProfileURL, adImgURL);

                    // We are going to cache the versions of the Email and Fax credit sheet
                    // report using the available sort options.  Rendering this report 10 times 
                    // and storing it (currently) in memory is better than 4k+ times.
                    ReportInterface oReportInterface = new ReportInterface();
                    Dictionary<string, byte[]> cachedReports = new Dictionary<string, byte[]>();
                    List<string> sortTypes = GetSortTypes(oConn);
                    byte[] abCSReport = null;
                    string reportDateParm = reportDate.ToString("yyyy-MM-dd HH:mm:ss.fff");
                    foreach (string sortType in sortTypes)
                    {
                        abCSReport = oReportInterface.GenerateCreditSheetReportFax("EXUPD", "'P','T','S'", reportDateParm, sortType, messageHdr, message);
                        cachedReports.Add(sortType + "Fax", abCSReport);

                        abCSReport = oReportInterface.GenerateCreditSheetReportEmail("EXUPD", "'P','T','S'", reportDateParm, sortType, messageHdr, message, false);
                        cachedReports.Add(sortType + "Email", abCSReport);
                    }

                    // Build a list of recipients
                    List<ReportUser> lReportUser = GetCSReportInfo(oConn);

                    _oLogger.LogMessage("ItemCount: " + lReportUser.Count.ToString("###,##0"));

                    string fileName = null;
                    //oTran = oConn.BeginTransaction();
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
                                }
                                else {
                                    emailContentCultureApplied = emailContent;
                                    emailSubjectCultureApplied = szSubject;
                                    culture = "en-us";
                                }

                                string formattedEmail = GetFormattedEmail(oConn, oTran, oReportUser.CompanyID, oReportUser.PersonID, szSubject, emailContentCultureApplied, culture);

                                //oTran = oConn.BeginTransaction();
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
                                            "Express Update Credit Sheet Report Event",
                                            "HTML");
                                //oTran.Commit();
                                oTran = null;

                                if (reportCount >= iMaxReportCount)
                                {
                                    break;
                                }
                            }
                        }
                    }

                    // Commit and set to NULL.
                    //oTran.Commit();
                    //oTran = null;


                    try
                    {
                        SaveFile(" Email", reportDate, cachedReports["I-KEmail"]);
                        SaveFile(" Fax", reportDate, cachedReports["I-KFax"]);
                    }
                    catch (Exception e)
                    {
                        LogEventError("Error Procesing ExpressUpdateReportProduce.  Unable to save PDF reports to network.  Reports sent regardless.", e);
                    }
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

                if (Utilities.GetBoolConfigValue("ExpressUpdateReportProduceWriteResultsToEventLog", true))
                {
                    _oBBSMonitorService.LogEvent(sbMsg.ToString());
                }

                if (itemCount > 0)
                {
                    if (Utilities.GetBoolConfigValue("ExpressUpdateReportProduceSendResultsToSupport", true))
                    {
                        if (skippedMembers.Length > 0)
                        {
                            sbMsg.Append(Environment.NewLine + Environment.NewLine);
                            sbMsg.Append("The following persons were skipped due to a previous fax being sent to the same fax number." + Environment.NewLine);
                            sbMsg.Append("CompanyID\tPersonID\tFax Number" + Environment.NewLine);
                            sbMsg.Append(skippedMembers);
                        }

                        SendMail("ExpressUpdateReportProduce Success", sbMsg.ToString());
                    }
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
                LogEventError("Error Procesing ExpressUpdateReportProduce.", e);
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
						                                                  WHERE prcoml_Source = 'Express Update Credit Sheet Report Event'
						                                                    AND CAST(prcoml_CreatedDate as Date) = CAST('{0}' as Date)) T1 ON peli_PersonID = prcoml_PersonID 
						                                                    AND peli_CompanyID = prcoml_CompanyID
                    WHERE peli_PRCSReceiveMethod IN ('1', '2')
                        AND comp_PRIndustryType NOT IN ('L')
                        AND peli_PRStatus In ('1', '2') 
                        AND CAST(prwu_AccessLevel as INT) > 10
                        AND prci2_Suspended IS NULL
                        AND prcoml_CommunicationLog IS NULL
                        AND
                        (
		                    comp_PRHQID IN (SELECT prse_HQID FROM PRService WHERE prse_ServiceCode = 'EXUPD')
		                    OR
		                    Comp_CompanyId IN (SELECT prse_CompanyID FROM PRService WHERE prse_ServiceCode = 'EXUPD')
	                    )
                    ORDER BY peli_PRCSReceiveMethod DESC, comp_CompanyID, pers_PersonID";

        /// <summary>
        /// Populates the ReportUser object with the report header
        /// information.
        /// </summary>
        /// <param name="sqlConn"></param>
        private List<ReportUser> GetCSReportInfo(SqlConnection sqlConn)
        {
            List<ReportUser> lReportUsers = new List<ReportUser>();

            DateTime excludeDate = Utilities.GetDateTimeConfigValue("ExpressUpdateReportProduceCommLogExcludeDate", DateTime.Today);

            SqlCommand sqlCommand = new SqlCommand(string.Format(SQL_GET_PERSONS, excludeDate), sqlConn);
            sqlCommand.CommandTimeout = Utilities.GetIntConfigValue("ExpressUpdateReportProduceQueryTimeout", 300);

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

        protected const string SQL_SELECT_SORT_TYPES =
                @"SELECT RTRIM(capt_code) FROM Custom_Captions WHERE capt_family = 'peli_PRCSSortOption' ORDER BY capt_order";

        private List<string> GetSortTypes(SqlConnection sqlConn)
        {
            List<string> sortTypes = new List<string>();

            SqlCommand sqlCommand = new SqlCommand(SQL_SELECT_SORT_TYPES, sqlConn);
            SqlDataReader reader = null;

            using (reader = sqlCommand.ExecuteReader())
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
            string saveFolder = Utilities.GetConfigValue("ExpressUpdateReportProduceExportFolder");
            string saveFileName = Path.Combine(saveFolder, string.Format(Utilities.GetConfigValue("ExpressUpdateReportProduceFileName", "Express Update{0} {1}.pdf"), deliveyType, reportDate.ToString("yyyy-MM-dd")));
            if (File.Exists(saveFileName))
            {
                File.Delete(saveFileName);
            }

            using (FileStream oFStream = File.Create(saveFileName, abReport.Length))
            {

                oFStream.Write(abReport, 0, abReport.Length);
            }
        }
    }
}