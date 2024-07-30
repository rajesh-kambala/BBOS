/***********************************************************************
 Copyright Produce Reporter Company 2006-2007

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: DelistedCompanyReport.cs
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


namespace PRCo.BBS.BBSMonitor {

    /// <summary>
    /// Event handler that generates the appropriate Delisted Company
    /// report for those users that have custom data (i.e. notes, user
    /// contacts) associated with recently delisted companies.  This custom
    /// data is not longer accessible if the company is not listed.
    /// </summary>
    class DelistedCompanyReport : BBSMonitorEvent {

        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex) {
            _szName = "DelistedCompanyReport";

            base.Initialize(iIndex);

            try {
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("DelistedCompanyReportInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("DelistedCompanyReport Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("DelistedCompanyReportStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

                _oLogger.LogMessage("DelistedCompanyReport Start: " + _dtNextDateTime.ToString());

            } catch (Exception e) {
                LogEventError("Error initializing DelistedCompanyReport event.", e);
                throw;
            }
        }

        const string SQL_SELECT_DELISTED_COMPANIES = "SELECT comp_CompanyID FROM Company WHERE comp_PRListingStatus NOT IN ('L', 'H') AND comp_PRDelistedDate > @LastRunDate";

        const string SQL_SELECT_USERS = "SELECT DISTINCT UserID, prwu_Email, prwu_FirstName, prwu_LastName FROM ( " +
	                                          "SELECT DISTINCT prwuc_CreatedBy AS UserID FROM PRWebUserContact WHERE prwuc_AssociatedCompanyID IN ({0}) " +
	                                          "UNION " +
                                              "SELECT DISTINCT prwun_CreatedBy AS UserID FROM PRWebUserNote WHERE prwun_AssociatedType='C' AND prwun_AssociatedID IN ({0}) " +
	                                          "UNION " +
                                              "SELECT DISTINCT prwun_CreatedBy AS UserID FROM PRWebUserNote INNER JOIN Person ON prwun_AssociatedID = pers_PersonID INNER JOIN Person_Link ON pers_PersonID = peli_PersonID WHERE prwun_AssociatedType='P' AND peli_CompanyID IN ({0}) " +
	                                          ") T1 "  +
	                                          "INNER JOIN PRWebUser ON UserID = prwu_WebUserID";

        /// <summary>
        /// Look to generate the DelistedCompany Report.
        /// </summary>
        override public void ProcessEvent() {

            DateTime dtExecutionStartDate = DateTime.Now;
            int iReportCount = 0;


            SqlConnection oConn = new SqlConnection(GetConnectionString());

            try {

                StringBuilder sbCompanyIDs = new StringBuilder();
                oConn.Open();

                DateTime dtLastExecution = GetDateTimeCustomCaption(oConn, "DelistedReportLastExecution");
                SqlParameter oParm = new SqlParameter("LastRunDate", dtLastExecution);
                
                // Create the form records
                SqlCommand oSQLCommand = new SqlCommand(SQL_SELECT_DELISTED_COMPANIES, oConn);
                oSQLCommand.Parameters.Add(oParm);
                
                IDataReader oReader = oSQLCommand.ExecuteReader();
                try {
                    while (oReader.Read()) {
                        if (sbCompanyIDs.Length > 0) {
                            sbCompanyIDs.Append(",");
                        }   
                        sbCompanyIDs.Append(oReader.GetInt32(0).ToString());                                 
                    }
                } finally {
                    if (oReader != null) {
                        oReader.Close();
                    }
                }
                
                string szResultsMsg = null;
                if (sbCompanyIDs.Length == 0) {
                    szResultsMsg = "DelistedCompanyReport Executed Successfully: No delisted companies found.";
                } else {

                    // Build a list of those users that have custom data associated
                    // with the delisted companies.
                    List<ReportUser> lReportUser = new List<ReportUser>();
    
                    oSQLCommand = new SqlCommand(string.Format(SQL_SELECT_USERS, sbCompanyIDs.ToString()), oConn);
                    oReader = oSQLCommand.ExecuteReader();
                    try {
                        while (oReader.Read()) {
                            ReportUser oReportUser = new ReportUser();
                            oReportUser.UserID = oReader.GetInt32(0);
                            oReportUser.Destination = oReader.GetString(1);
                            oReportUser.MethodID = DELIVERY_METHOD_EMAIL;
                            oReportUser.PersonName = oReader.GetString(2) + " " + oReader.GetString(3);
                            
                            lReportUser.Add(oReportUser);
                        }
                    } finally {
                        if (oReader != null) {
                            oReader.Close();
                        }
                    }

                    string szAttachmentName = Utilities.GetConfigValue("DelistedCompanyReportAttachmentName", "Delisted_Company_Report_{0}.pdf");
                    string szSubject = Utilities.GetConfigValue("DelistedCompanyReportSubject", "Blue Book Services Delisted Company Report");
                    string szCategory = Utilities.GetConfigValue("DelistedCompanyReportCategory", string.Empty);
                    string szSubcategory = Utilities.GetConfigValue("DelistedCompanyReportSubcategory", string.Empty);
                    bool bDoNotRecordCommunication = Utilities.GetBoolConfigValue("DelistedCompanyReportDoNotRecordCommunication", false);

                    SqlTransaction oTran = oConn.BeginTransaction();
                    try {
                        foreach (ReportUser oReportUser in lReportUser) {
                            byte[] abReport = GetTestReport();
                            iReportCount++;

                            // TODO: Update when the Delisted report is implemented.
                            //abReport = oReportInterface.GenerateDelistedReport();

                            string szContent = string.Format(GetEmailTemplate("DelistedReportContent.txt"), oReportUser.PersonName);
                            SendReport(oTran,
                                       oReportUser,
                                       szSubject,
                                       szContent,
                                       abReport,
                                       string.Format(szAttachmentName, oReportUser.UserID),
                                       szCategory,
                                       szSubcategory,
                                       bDoNotRecordCommunication,
                                       "Delisted Company Report Event",
                                       "HTML");
                        }
                        
                        szResultsMsg = "DelistedCompanyReport Executed Successfully: Found the following delisted companies: " + sbCompanyIDs.ToString();
                        
                        oTran.Commit();
                    } catch {
                        oTran.Rollback();
                        throw;
                    }
                }


                UpdateDateTimeCustomCaption(oConn, "DelistedReportLastExecution", dtExecutionStartDate);
                
                if (Utilities.GetBoolConfigValue("DelistedCompanyReportWriteResultsToEventLog", true)) {
                    _oBBSMonitorService.LogEvent(szResultsMsg);
                }

                if (Utilities.GetBoolConfigValue("DelistedCompanyReportSendResultsToSupport", false)) {
                    SendMail("DelistedCompanyReport Success", szResultsMsg);
                }


            } catch (Exception e) {
                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("Error Procesing DelistedCompanyReport Event.", e);

            } finally {
                if (oConn != null) {
                    oConn.Close();
                }

                oConn = null;
            }
        }
    }
}
