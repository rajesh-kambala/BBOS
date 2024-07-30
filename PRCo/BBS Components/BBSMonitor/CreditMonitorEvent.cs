/***********************************************************************
 Copyright Blue Book Services, Inc. 2013-2017

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. 
 is strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CreditMonitorEvent.cs
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
    public class CreditMonitorEvent: BBSMonitorEvent
    {

        private const string MSG_CREDIT_SCORE_SUMMARY = "{0:###,##0} Credit Monitor reports were emailed.";
        private const string MSG_CREDIT_SCORE_DETAIL = " - Sent to {0} at {1} with {2} BBID.\n";

        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex) {
            _szName = "CreditMonitor";

            base.Initialize(iIndex);
            
            try {
                //
                // Configure our BBScore Report
                //
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("CreditMonitorInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("CreditMonitorStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

                _oLogger.LogMessage("CreditMonitor Start: " + _dtNextDateTime.ToString());

            } catch (Exception e) {
                LogEventError("Error initializing CreditMonitor event.", e);
                throw;
            }
        }


        /// <summary>
        /// Process any CreditMonitor reports.
        /// </summary>
        override public void ProcessEvent()
        {
            DateTime dtExecutionStartDate = DateTime.Now;

            List<ReportUser> lReportUser = new List<ReportUser>();
            List<string> lErrors = new List<string>();
            List<string> lDetails = new List<string>();

            SqlConnection oConn = new SqlConnection(GetConnectionString());
            SqlTransaction oTran = null;
            try
            {
                oConn.Open();


                DateTime lastRunDate = GetDateTimeCustomCaption(oConn, "CreditMonitorReportDate", DateTime.Now.AddYears(-1));
                string lastRunQuarter = GetQuarter(lastRunDate);
                string currentQuarter = GetQuarter(DateTime.Today);

                if (lastRunQuarter == currentQuarter)
                {
                    return;
                }

                lReportUser = GetReportUsers(oConn);
                

                // Now go execte a report for each one of 
                // these and send it out
                string szMethod = null;

                int iReportCount = 0;
                int iErrorCount = 0;
                int iEmailCount = 0;

                DateTime dtReportDate = GetDateTimeConfigValue("CreditMonitorReportDate", dtExecutionStartDate);


                int iMaxErrorCount = Utilities.GetIntConfigValue("CreditMonitorMaxErrorCount", 0);
                int iMaxReportCount = Utilities.GetIntConfigValue("CreditMonitorMaxReportCount", 999999999);
                string[] aszAttachments = { Utilities.GetConfigValue("CreditMonitorAttachmentName", "BBSi Credit Monitor Reprt.pdf"),};

                string szSubject = Utilities.GetConfigValue("CreditMonitorSubject", "Your Credit Monitor Report is Attached");
                string szCategory = Utilities.GetConfigValue("CreditMonitorCategory", "O");
                string szSubcategory = Utilities.GetConfigValue("CreditMonitorSubcategory", string.Empty);
                bool bDoNotRecordCommunication = Utilities.GetBoolConfigValue("CreditMonitorDoNotRecordCommunication", true);

                string szInteractionSubject = Utilities.GetConfigValue("CreditMonitorInteractionSubject", "Quarterly Credit Monitor");
                string szInteractionNote = Utilities.GetConfigValue("CreditMonitorInteractionNote", "Quarterly Credit Monitor Report sent to AUS users.");

                ReportInterface oReportInterface = new ReportInterface();
                byte[] abCreditMonitorReport = null;


                List<Int32> companyIDs = new List<Int32>();

                foreach (ReportUser oReportUser in lReportUser)
                {
                    try
                    {
                        oTran = oConn.BeginTransaction();

                        abCreditMonitorReport = null;

                        if (oReportUser.Invalid)
                        {
                            string[] aArgs = { "generating the Credit Monitor report", 
                                           oReportUser.PersonName, 
                                           oReportUser.CompanyName, 
                                           oReportUser.CompanyID.ToString(),
                                           "NULL Credit Monitor Settings Found."};

                            lErrors.Add(string.Format(MSG_DETAIL_ERROR, aArgs));

                        }
                        else
                        {
                            iReportCount++;

                            abCreditMonitorReport = oReportInterface.GenerateCreditMonitor(oReportUser.WebUserID);


                            List<byte[]> lReportFiles = new List<byte[]>();
                            lReportFiles.Add(abCreditMonitorReport);

                            iEmailCount++;
                            szMethod = "Email";

                            _oLogger.LogMessage(string.Format("Sending to {0}, {1} at {2}", oReportUser.CompanyName, oReportUser.PersonName, oReportUser.Destination));
                            string szContent = string.Format(GetEmailTemplate("CreditMonitorContent.html"), oReportUser.PersonName, szMethod.ToLower(), dtReportDate.ToString("MMMM, yyyy"));
                            szContent = GetFormattedEmail(oConn, oTran, oReportUser.CompanyID, oReportUser.PersonID, szSubject, szContent);

                            SendReport(oTran,
                                       oReportUser,
                                       szSubject,
                                       szContent,
                                       lReportFiles,
                                       aszAttachments,
                                       szCategory,
                                       szSubcategory,
                                       bDoNotRecordCommunication,
                                       "Credit Monitor Event",
                                       "HTML");

                            lDetails.Add(string.Format(MSG_CREDIT_SCORE_DETAIL, 
                                                       oReportUser.PersonName,
                                                       oReportUser.CompanyName,
                                                       oReportUser.CompanyID));


                            if (!companyIDs.Contains(oReportUser.CompanyID))
                            {
                                CreateInteraction(oConn, oReportUser.CompanyID, "EmailOut", dtExecutionStartDate,
                                                  szInteractionSubject,
                                                  szInteractionNote,
                                                  szCategory, szSubcategory, oTran);

                                companyIDs.Add(oReportUser.CompanyID);
                            }

                            if (iReportCount >= iMaxReportCount)
                            {
                                break;
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
                            oTran = null;
                        }

                        LogEventError("Error Generating Credit Monitor Report.", e);

                        string[] aArgs = { "generating the Credit Monitor report", 
                                           oReportUser.PersonName, 
                                           oReportUser.CompanyName, 
                                           oReportUser.CompanyID.ToString(),
                                           e.Message};

                        lErrors.Add(string.Format(MSG_DETAIL_ERROR, aArgs));

                        // If we exceed our max error count, abort
                        // the entire operation.
                        iErrorCount++;
                        if (iErrorCount > iMaxErrorCount)
                        {
                            throw new ApplicationException("Maximum number of allowable errors exceeded.");
                        }
                    }
                }



                UpdateDateTimeCustomCaption(oConn, "CreditMonitorReportDate", dtExecutionStartDate);

                // Now summarize what happened and log 
                // it somewhere.
                StringBuilder sbMsg = new StringBuilder();


                object[] aMsgArgs = {iReportCount};
                sbMsg.Append(string.Format(MSG_CREDIT_SCORE_SUMMARY, aMsgArgs));

                AddListToBuffer(sbMsg, lErrors, "Errors");
                if (Utilities.GetBoolConfigValue("CreditMonitorSendResultsDetails", true))
                {
                    AddListToBuffer(sbMsg, lDetails, "Detail(s)");
                }

                TimeSpan tsDiff = DateTime.Now.Subtract(dtExecutionStartDate);
                sbMsg.Append("\n\nExecution time: " + tsDiff.ToString());

                if (Utilities.GetBoolConfigValue("CreditMonitorWriteResultsToEventLog", true))
                {
                    _oBBSMonitorService.LogEvent(sbMsg.ToString());
                }

                if (Utilities.GetBoolConfigValue("CreditMonitorSendResultsToSupprt", true))
                {
                    SendMail("Credit Monitor Reports Success", sbMsg.ToString());
                }


            }
            catch (Exception e)
            {
                LogEventError("Error Procesing Credit Monitor Reports.", e);

                if (oTran != null)
                {
                    oTran.Rollback();
                }

                StringBuilder sbMsg = new StringBuilder();


                sbMsg.Append(MSG_ERROR);

                AddListToBuffer(sbMsg, lErrors, "Error(s)");

                sbMsg.Append("\n\n" + e.Message);
                sbMsg.Append("\n\n" + e.StackTrace);
                SendMail("Credit Monitor Reports Error", sbMsg.ToString());

            }
            finally
            {
                if (oConn != null)
                {
                    oConn.Close();
                }

                oConn = null;
                lDetails = null;
                lErrors = null;
            }
        }


        private const string SQL_SELECT_USERS =
            @"SELECT prwu_WebUserID, peli_PersonID, prwu_BBID, Comp_Name, prwu_Email, dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_MiddleName, pers_PRNickName1, pers_Suffix) As FullName, COUNT(1)
              FROM PRWebUser WITH (NOLOCK)
                   INNER JOIN Person_Link WITH (NOLOCK) ON prwu_PersonLinkID = PeLi_PersonLinkId
                   INNER JOIN Person WITH (NOLOCK) ON PeLi_PersonId = pers_PersonID
                   INNER JOIN PRWebUserList WITH (NOLOCK) on prwu_WebUserID = prwucl_WebUserID
                   INNER JOIN Company WITH (NOLOCK) ON prwu_BBID = comp_CompanyID	      
                   INNER JOIN PRWebUserListDetail ON prwucl_WebUserListID = prwuld_WebUserListID 
             WHERE comp_PRListingStatus IN ('L', 'H', 'N3', 'LUV')
               AND comp_PRIndustryType = 'L'
               AND prwucl_TypeCode = 'AUS'
               AND CAST(prwu_AccessLevel as Int) >= 100
               AND peli_PRStatus = '1'
          GROUP BY  prwu_WebUserID, peli_PersonID, prwu_BBID, Comp_Name, prwu_Email, pers_FirstName, pers_LastName, pers_MiddleName, pers_PRNickName1, pers_Suffix  
          ORDER BY prwu_BBID, peli_PersonID";

        /// <summary>
        /// Populates the ReportUser object with the report header
        /// information.
        /// </summary>
        /// <param name="oConn"></param>
        private List<ReportUser> GetReportUsers(SqlConnection oConn)
        {

            List<ReportUser> lReportUsers = new List<ReportUser>();

            SqlCommand oSQLCommand = new SqlCommand(SQL_SELECT_USERS, oConn);
            oSQLCommand.CommandTimeout = Utilities.GetIntConfigValue("CreditMonitorQueryTimeout", 300);
            SqlDataReader oReader = null;

            try
            {
                oReader = oSQLCommand.ExecuteReader();
                while (oReader.Read())
                {
                    ReportUser oReportUser = new ReportUser(oReader.GetInt32(1), oReader.GetInt32(2));

                    lReportUsers.Add(oReportUser);
                    oReportUser.WebUserID = oReader.GetInt32(0);
                    oReportUser.PersonName = oReader.GetString(5);
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

                return lReportUsers;
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }
        }


        private string GetQuarter(DateTime dtValue)
        {
            string quarter = null;

            if (dtValue.Month <= 3)
            {
                quarter = "1";
            }
            else if (dtValue.Month <= 6)
            {
                quarter = "2";
            }
            else if (dtValue.Month <= 9)
            {
                quarter = "3 ";
            } else 
            {
                quarter = "4";
            }

            return dtValue.Year.ToString("0000") + "-" + quarter;
        }
    }
}
