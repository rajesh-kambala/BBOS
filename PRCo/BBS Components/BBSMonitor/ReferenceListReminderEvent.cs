/***********************************************************************
 Copyright Blue Book Services, Inc. 2017-2019

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: ReferenceListReminderEvent.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using System.Timers;
using TSI.Utils;

namespace PRCo.BBS.BBSMonitor
{
    public class ReferenceListReminderEvent : BBSMonitorEvent
    {
        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex)
        {
            _szName = "ReferenceListReminderEvent";

            base.Initialize(iIndex);

            try
            {
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("ReferenceListReminderInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("ReferenceListReminder Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("ReferenceListReminderStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

                _oLogger.LogMessage("ReferenceListReminder Start: " + _dtNextDateTime.ToString());

            }
            catch (Exception e)
            {
                LogEventError("Error initializing ReferenceListReminder event.", e);
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        override public void ProcessEvent()
        {
            DateTime dtExecutionStartDate = DateTime.Now;
            SqlConnection oConn = new SqlConnection(GetConnectionString());
            SqlTransaction oTran = null;

            string szAttchmentName = Utilities.GetConfigValue("ReferenceListReminderAttachmentName", "Blue Book Reference List Form.pdf");
            string szAttchmentNameSP = Utilities.GetConfigValue("ReferenceListReminderAttachmentName-SP", "Blue Book Reference List Form.pdf");

            string szAttchmentNameWhatsBBRating = Utilities.GetConfigValue("ReferenceListReminderAttachmentNameWhatsBBRating", "BB Rating.pdf");
            string szAttchmentNameWhatsBBRatingSP = Utilities.GetConfigValue("ReferenceListReminderAttachmentNameWhatsBBRating-SP", "BB Rating.pdf");

            string szCategory = Utilities.GetConfigValue("ReferenceListReminderSubcategory", "R");
            string szSubcategory1 = Utilities.GetConfigValue("ReferenceListReminderSubcategory1", "RFR60");
            string szSubcategory2 = Utilities.GetConfigValue("ReferenceListReminderSubcategory2", "RFR120");
            string szSubcategory3 = Utilities.GetConfigValue("ReferenceListReminderSubcategory3", "RFR270");

            int dayThreshold1 = Utilities.GetIntConfigValue("ReferenceListReminderThreshold1", 60);
            int dayThreshold2 = Utilities.GetIntConfigValue("ReferenceListReminderThreshold2", 120);
            int dayThreshold3 = Utilities.GetIntConfigValue("ReferenceListReminderThreshold3", 270);

            DateTime thresholdDate1 = DateTime.Today.AddDays(0 - dayThreshold1);
            DateTime thresholdDate2 = DateTime.Today.AddDays(0 - dayThreshold2);
            DateTime thresholdDate3 = DateTime.Today.AddDays(0 - dayThreshold3);

            string szSubject = Utilities.GetConfigValue("ReferenceListReminderSubject", "Blue Book Services Needs Your Reference List!");
            string szSubjectSP = Utilities.GetConfigValue("ReferenceListReminderSubject-SP", "¡El Blue Book Necesita su lista de referencia!");

            string szEmailTemplate = GetEmailTemplate("ReferenceListReminder.html");
            string szEmailTemplateSP = GetEmailTemplate("ReferenceListReminder-SP.html");



            byte[] abRFProduce = ReadFile("Reference List (Produce) fill-in.pdf");
            byte[] abRFTransportation = ReadFile("Reference List (Transportation) fill-in.pdf");
            byte[] abRFProduceSP = ReadFile("Reference List (Produce) Spanish fill-in.pdf");
            byte[] abRFTransportationSP = ReadFile("Reference List (Transportation) Spanish fill-in.pdf");

            byte[] abWhatsBBRating = ReadFile("What's a BB Rating_Earn A BB Rating.pdf");
            byte[] abWhatsBBRatingSP = ReadFile("What's a BB Rating_Earn a BB Rating_Spanish.pdf");

            int reportCount = 0;
            int iMaxReportCount = Utilities.GetIntConfigValue("ReferenceListReminderMaxReportCount", 999999999);
            string msg = string.Empty;
            string culture = string.Empty;
            try
            {
                oConn.Open();

                // Pass 1
                List<ReportUser> lReportUser = GetReportUsers(oConn, szSubcategory1, thresholdDate1);
                lReportUser.AddRange(GetReportUsers(oConn, szSubcategory2, thresholdDate2));
                lReportUser.AddRange(GetReportUsers(oConn, szSubcategory3, thresholdDate3));

                List<Int32> companyIDs = new List<Int32>();

                foreach (ReportUser oReportUser in lReportUser)
                {
                    string emailContent = null;
                    string subject = null;
                    List<byte[]> lReportFiles = new List<byte[]>();
                    List<string> attachments = new List<string>();

                    if (oReportUser.CommunicationLanguage == "S")
                    {
                        culture = "es-mx";
                        emailContent = szEmailTemplateSP;
                        subject = szSubjectSP;
                        attachments.Add(szAttchmentNameSP);
                        if (oReportUser.IndustryType == "P")
                        {
                            lReportFiles.Add(abRFProduceSP);
                        } else
                        {
                            lReportFiles.Add(abRFTransportationSP);
                        }

                        attachments.Add(szAttchmentNameWhatsBBRatingSP);
                        lReportFiles.Add(abWhatsBBRatingSP);
                    }
                    else
                    {
                        culture = "en-us";
                        emailContent = szEmailTemplate;
                        subject = szSubject;
                        attachments.Add(szAttchmentName);
                        if (oReportUser.IndustryType == "P")
                        {
                            lReportFiles.Add(abRFProduce);
                        }
                        else
                        {
                            lReportFiles.Add(abRFTransportation);
                        }

                        attachments.Add(szAttchmentNameWhatsBBRating);
                        lReportFiles.Add(abWhatsBBRating);
                    }

                    //attchmentName += " " + oReportUser.PersonID.ToString();

                    oTran = oConn.BeginTransaction();

                    string formattedEmail = GetFormattedEmail(oConn, oTran, oReportUser.CompanyID, oReportUser.PersonID, subject, emailContent, culture);

                    SendReport(oTran,
                                oReportUser,
                                subject,
                                formattedEmail,
                                lReportFiles,
                                attachments.ToArray(),
                                szCategory,
                                oReportUser.LetterType,
                                true,
                                "Reference List Reminder Event",
                                "HTML");

                    //Defect 4513 - create interaction when email goes out
                    string szInteractionSubject = Utilities.GetConfigValue("ReferenceListReminderInteractionSubject", "Auto-email Reference List Reminder sent");
                    string szInteractionNote = Utilities.GetConfigValue("ReferenceListReminderInteractionNote", "An automated Email was sent to ALL BBOS users with a password at this company because they have not returned a Reference list.");

                    if (!companyIDs.Contains(oReportUser.CompanyID))
                    {
                        CreateInteraction(oConn,
                                        oReportUser.CompanyID,
                                        "EmailOut",
                                        dtExecutionStartDate,
                                        szInteractionSubject,
                                        szInteractionNote,
                                        szCategory,
                                        oReportUser.LetterType,
                                        oTran);

                        companyIDs.Add(oReportUser.CompanyID);
                    }

                    oTran.Commit();
                    oTran = null;

                    reportCount++;
                    if (reportCount >= iMaxReportCount)
                    {
                        break;
                    }
                }

                if (Utilities.GetBoolConfigValue("ReferenceListReminderWriteResultsToEventLog", true))
                {
                    _oBBSMonitorService.LogEvent("ReferenceListReminder Executed Successfully. " + msg);
                }

                if (Utilities.GetBoolConfigValue("ReferenceListReminderSendResultsToSupport", false))
                {
                    SendMail("ReferenceListReminder Success", msg);
                }

            }
            catch (Exception e)
            {
                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("Error Procesing ReferenceListReminder Event.", e);
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
                    @"SELECT peli_PersonID, comp_CompanyID, comp_PRListedDate,
	                       comp_PRConnectionListDate,
	                       prwu_Email,
	                       comp_PRCommunicationLanguage,
                           comp_PRIndustryType
                      FROM Company WITH (NOLOCK)
                           INNER JOIN PRWebUser WITH (NOLOCK) ON comp_CompanyID = prwu_BBID
	                       INNER JOIN Person_Link WITH (NOLOCK) ON prwu_PersonLinkID = peli_PersonLinkID
                     WHERE comp_PRListingStatus = 'L'
                       AND comp_PRIndustryType IN ('P', 'T')
                       AND comp_PRType = 'H'
                       AND comp_PRConnectionListDate IS NULL
                       AND comp_PRLocalSource IS NULL
                       AND comp_PRIsIntlTradeAssociation IS NULL
                       AND prwu_Disabled IS NULL
                       AND prwu_Email IS NOT NULL
                       AND comp_PRListedDate IS NOT NULL
                       AND comp_PRListedDate < @DateThreshold
                       AND comp_PRListedDate >= @FunctionalityStartDate
                       AND comp_CompanyID NOT IN (SELECT cmli_comm_CompanyID FROM vCommunication WHERE comm_PRCategory='R' AND comm_PRSubCategory=@Subcategory)
                  ORDER BY comp_CompanyID, peli_PersonID";


        /// <summary>
        /// Populates the ReportUser object with the report header
        /// information.
        /// </summary>
        private List<ReportUser> GetReportUsers(SqlConnection sqlConn, string subCategory, DateTime dateThrehold)
        {
            List<ReportUser> lReportUsers = new List<ReportUser>();

            SqlCommand sqlCommand = new SqlCommand(SQL_GET_PERSONS, sqlConn);
            sqlCommand.CommandTimeout = Utilities.GetIntConfigValue("ReferenceListReminderQueryTimeout", 300);
            sqlCommand.Parameters.AddWithValue("DateThreshold", dateThrehold);
            sqlCommand.Parameters.AddWithValue("Subcategory", subCategory);
            sqlCommand.Parameters.AddWithValue("FunctionalityStartDate", Utilities.GetDateTimeConfigValue("ReferenceListReminderLaunchDate"));
            
            using (SqlDataReader reader = sqlCommand.ExecuteReader())
            {
                while (reader.Read())
                {
                    ReportUser oReportUser = new ReportUser(reader.GetInt32(0), reader.GetInt32(1));

                    lReportUsers.Add(oReportUser);
                    oReportUser.Method = "email";
                    oReportUser.Destination = GetString(reader[4]);
                    oReportUser.CommunicationLanguage = GetString(reader[5]);
                    oReportUser.IndustryType = GetString(reader[6]);
                    oReportUser.LetterType = subCategory;
                }
            }
            return lReportUsers;
        }

        private byte[] ReadFile(string fileNmae)
        {
            return File.ReadAllBytes(Path.Combine(Utilities.GetConfigValue("TemplateFolder"), fileNmae));
        }
    }
}
