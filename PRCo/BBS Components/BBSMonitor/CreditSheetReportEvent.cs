/***********************************************************************
 Copyright Produce Reporter Company 2009-2018

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CreditSheetReportEvent.cs
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
    /// This event generates the Credit Sheet report for
    /// lumber users.
    /// </summary>
    public class CreditSheetReportEvent : BBSMonitorEvent
    {

        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex)
        {
            _szName = "CreditSheetReport";

            base.Initialize(iIndex);

            try
            {
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("CreditSheetReportInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("CreditSheetReport Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("CreditSheetReportStartDateTime"));
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


        protected const string MSG_CSR_SUMMARY = "A total of {0:###,###,##0} lumber credit sheet items were found.  {1:###,##0} Credit sheet reports delievered.";

        protected const string SQL_UDPATE_CS_PUDDATE =
                "UPDATE PRCreditSheet " +
                   "SET prcs_WeeklyCSPubDate = @ReportDate " +
                  "FROM PRCreditSheet " +
                       "INNER JOIN Company ON prcs_CompanyID = comp_CompanyID " +
                 "WHERE comp_PRIndustryType = 'L' " +
                   "AND prcs_Status = 'P' " +
                   "AND prcs_WeeklyCSPubDate IS NULL";


        override public void ProcessEvent()
        {
            DateTime dtExecutionStartDate = DateTime.Now;

            //DateTime dtStartDate = new DateTime();
            DateTime dtEndDate = _dtNextDateTime;

            SqlConnection oConn = new SqlConnection(GetConnectionString());
            SqlDataReader oReader = null;
            SqlTransaction oTran = null;

            int iCSItemCount = 0;   
            int iReportCount = 0;
            int iMaxReportCount = Utilities.GetIntConfigValue("CreditSheetReportMaxReportCount", 999999999);

            try {
                oConn.Open();

                DateTime dtReportDate = DateTime.Now;
                _oLogger.LogMessage("dtReportDate=" + dtReportDate.ToString());



                SqlCommand cmdUpdateWeeklyCSDate = new SqlCommand(SQL_UDPATE_CS_PUDDATE, oConn);
                cmdUpdateWeeklyCSDate.Parameters.AddWithValue("ReportDate", dtReportDate);
                cmdUpdateWeeklyCSDate.ExecuteNonQuery();


                // Determine if any CS items have been published
                // since we last exectued.
                SqlCommand oSQLCommand = new SqlCommand("usp_GetCreditSheetCount", oConn);
                oSQLCommand.CommandType = CommandType.StoredProcedure;
                oSQLCommand.Parameters.AddWithValue("@ReportDate", dtReportDate);
                oSQLCommand.Parameters.AddWithValue("@IndustryTypeList", "L");

                
                using(oReader = oSQLCommand.ExecuteReader()) {
                    if (oReader.Read()) {
                        iCSItemCount = oReader.GetInt32(0);
                    }
                }

                if (iCSItemCount > 0)
                {
                    string szSubject = Utilities.GetConfigValue("CreditSheetReportSubject", "Your Weekly Company Update Report is Attached");
                    string szCategory = Utilities.GetConfigValue("CreditSheetReportCategory", string.Empty);
                    string szSubcategory = Utilities.GetConfigValue("CreditSheetReportSubcategory", string.Empty);
                    string szAttachmentName = Utilities.GetConfigValue("CreditSheetReportAttachmentName", "Company_Update_Report.pdf");
                    bool bDoNotRecordCommunication = Utilities.GetBoolConfigValue("CreditSheetReportDoNotRecordCommunication", true);


                    // First get our report
                    ReportInterface oReportInterface = new ReportInterface();
                    byte[] abCSReport = oReportInterface.GenerateCreditSheetByPeriodReport(dtReportDate);
                    if (Utilities.GetBoolConfigValue("CreditSheetReportSaveReport", true)) {
                        string szReportFile = Path.Combine(Utilities.GetConfigValue("CreditSheetReportExportFolder"), "Lumber Credit Sheet " + dtReportDate.ToString("yyyy-MM-dd") + ".pdf");
                        WriteReportToDisk(abCSReport, szReportFile);
                    }

                    if (Utilities.GetBoolConfigValue("CreditSheetReportSaveBBOSReport", true))
                    {
                        string szReportFile = Path.Combine(Utilities.GetConfigValue("CreditSheetReportBBOSFolder"), "Lumber Credit Sheet " + dtReportDate.ToString("yyyy-MM-dd") + ".pdf");
                        WriteReportToDisk(abCSReport, szReportFile);
                    }

                    // Now get the users that get the report
                    List<ReportUser> lReportUser = GetCSReportInfo(oConn);


                    foreach (ReportUser oReportUser in lReportUser)
                    {
                        oTran = oConn.BeginTransaction();
                        if (!oReportUser.Invalid)
                        {
                            iReportCount++;
                            string szContent = string.Format(GetEmailTemplate("CreditSheetReportContent.txt"), oReportUser.PersonName, "email", _dtNextDateTime.ToString("MMMM d, yyyy"));
                            szContent = GetFormattedEmail(oConn, oTran, oReportUser.CompanyID, oReportUser.PersonID, szSubject, szContent);

                            _oLogger.LogMessage(string.Format("Sending to {0}, {1} at {2}", oReportUser.CompanyName, oReportUser.PersonName, oReportUser.Destination));

                            SendReport(oTran,
                                       oReportUser,
                                       szSubject,
                                       szContent,
                                       abCSReport,
                                       szAttachmentName,
                                       szCategory,
                                       szSubcategory,
                                       bDoNotRecordCommunication,
                                       "Lumber Credit Sheet Report Event",
                                       "HTML");
                        }

                        // Commit and set to NULL.
                        oTran.Commit();
                        oTran = null;

                        if (iReportCount >= iMaxReportCount)
                        {
                            break;
                        }
                    }
                }

                // Now summarize what happened and log 
                // it somewhere.
                StringBuilder sbMsg = new StringBuilder();

                object[] aMsgArgs = {iCSItemCount, 
                                     iReportCount};
                sbMsg.Append(string.Format(MSG_CSR_SUMMARY, aMsgArgs));

                TimeSpan tsDiff = DateTime.Now.Subtract(dtExecutionStartDate);
                sbMsg.Append("\n\nExecution time: " + tsDiff.ToString());

                if (Utilities.GetBoolConfigValue("CreditSheetReportWriteResultsToEventLog", true))
                {
                    _oBBSMonitorService.LogEvent(sbMsg.ToString());
                }

                if (Utilities.GetBoolConfigValue("CreditSheetReportSendResultsToSupport", false))
                {
                    SendMail("CreditSheetReport Reports Success", sbMsg.ToString());
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
                LogEventError("Error Procesing Credit Sheet Reports.", e);
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
            @"SELECT pers_PersonID, comp_CompanyID, dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_MiddleName, pers_PRNickName1, pers_Suffix) As FullName, comp_PRCorrTradestyle, RTRIM(emai_EmailAddress) As Email 
                FROM Person_Link WITH (NOLOCK)
                     INNER JOIN Person WITH (NOLOCK) ON peli_PersonID = pers_PersonID 
                     INNER JOIN Company WITH (NOLOCK) ON peli_CompanyID = comp_CompanyID 
                     INNER JOIN PRWebUser WITH (NOLOCK) ON peli_PersonLinkID = prwu_PersonLinkID 
                     INNER JOIN PRCompanyIndicators WITH (NOLOCK) ON peli_CompanyID = prci2_CompanyID
                     LEFT OUTER JOIN vPersonEmail WITH (NOLOCK) ON peli_PersonID = elink_RecordID AND peli_CompanyID = emai_CompanyID AND elink_Type='E' AND emai_PRPreferredInternal = 'Y' 
                     LEFT OUTER JOIN (SELECT prcoml_CommunicationLog, prcoml_CompanyID, prcoml_PersonID  
						                FROM PRCommunicationLog WITH (NOLOCK)
						                WHERE prcoml_Source = 'Lumber Credit Sheet Report Event'
						                AND CAST(prcoml_CreatedDate as Date) = CAST('{0}' as Date)) T1 ON peli_PersonID = prcoml_PersonID 
						                AND peli_CompanyID = prcoml_CompanyID
               WHERE peli_PRReceivesCreditSheetReport = 'Y' 
                 AND comp_PRIndustryType = 'L' 
                 AND peli_PRStatus In ('1', '2') 
                 AND CAST(prwu_AccessLevel as INT) > 10
                 AND prci2_Suspended IS NULL
                 AND prcoml_CommunicationLog IS NULL
                 AND comp_CompanyID NOT IN (SELECT prcta_CompanyID FROM PRCompanyTradeAssociation WHERE prcta_IsIntlTradeAssociation = 'Y')";


//        protected const string SQL_GET_PERSONS =
//            @"SELECT pers_PersonID, comp_CompanyID, dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_MiddleName, pers_PRNickName1, pers_Suffix) As FullName, comp_PRCorrTradestyle, RTRIM(emai_EmailAddress) As Email 
//                FROM Person_Link WITH (NOLOCK)
//                     INNER JOIN Person WITH (NOLOCK) ON peli_PersonID = pers_PersonID 
//                     INNER JOIN Company WITH (NOLOCK) ON peli_CompanyID = comp_CompanyID 
//                     INNER JOIN PRWebUser WITH (NOLOCK) ON peli_PersonLinkID = prwu_PersonLinkID 
//                     INNER JOIN PRCompanyIndicators WITH (NOLOCK) ON peli_CompanyID = prci2_CompanyID
//                     LEFT OUTER JOIN Email WITH (NOLOCK) ON peli_CompanyID = emai_CompanyID AND peli_PersonID = emai_PersonID AND emai_Type='E' AND emai_PRPreferredInternal = 'Y' 
//                     LEFT OUTER JOIN (SELECT prcoml_CommunicationLog, prcoml_CompanyID, prcoml_PersonID  
//						                FROM PRCommunicationLog WITH (NOLOCK)
//						                WHERE prcoml_Source = 'Lumber Credit Sheet Report Event'
//						                AND CAST(prcoml_CreatedDate as Date) = CAST('{0}' as Date)) T1 ON peli_PersonID = prcoml_PersonID 
//						                AND peli_CompanyID = prcoml_CompanyID
//               WHERE peli_PRReceivesCreditSheetReport = 'Y' 
//                 AND comp_PRIndustryType = 'L' 
//                 AND peli_PRStatus In ('1', '2') 
//                 AND CAST(prwu_AccessLevel as INT) > 10
//                 AND prci2_Suspended IS NULL
//                 AND prcoml_CommunicationLog IS NULL";


        /// <summary>
        /// Populates the ReportUser object with the report header
        /// information.
        /// </summary>
        /// <param name="oConn"></param>
        private List<ReportUser> GetCSReportInfo(SqlConnection oConn)
        {

            List<ReportUser> lReportUsers = new List<ReportUser>();

            DateTime excludeDate = Utilities.GetDateTimeConfigValue("CreditSheetReportCommLogExcludeDate", DateTime.Today);
            SqlCommand oSQLCommand = new SqlCommand(string.Format(SQL_GET_PERSONS, excludeDate), oConn);
            oSQLCommand.CommandTimeout = Utilities.GetIntConfigValue("CSReportQueryTimeout", 300);

            using (SqlDataReader oReader = oSQLCommand.ExecuteReader())
            {
                while (oReader.Read())
                {
                    ReportUser oReportUser = new ReportUser(oReader.GetInt32(0), oReader.GetInt32(1));

                    lReportUsers.Add(oReportUser);

                    oReportUser.PersonName = oReader.GetString(2);
                    oReportUser.CompanyName = oReader.GetString(3);

                    oReportUser.Method = "email";
                    oReportUser.MethodID = DELIVERY_METHOD_EMAIL;

                    if (oReader[4] == DBNull.Value)
                    {
                        oReportUser.Invalid = true;
                        oReportUser.Destination = "[NULL]";
                    }
                    else
                    {
                        oReportUser.Destination = oReader.GetString(4);
                    }
                }
            }
            return lReportUsers;
        }
    }
}
