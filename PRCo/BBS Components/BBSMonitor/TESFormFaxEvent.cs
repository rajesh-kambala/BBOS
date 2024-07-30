/***********************************************************************
 Copyright Produce Reporter Company 2006-2015

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: TESFormFaxEvent.cs
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

namespace PRCo.BBS.BBSMonitor {

    /// <summary>
    /// Provides the functionality to fax TES forms
    /// </summary>
    public class TESFormFaxEvent : BBSMonitorEvent {

        protected const string SQL_GENERATE_TES_FAX_FORMS = "usp_GenerateTESFormBatch";
        protected const string SQL_SELECT_FAX_TES =
           @"SELECT prtf_TESFormID, prtf_SerialNumber, prtesr_ResponderCompanyID, 
                    ISNULL(prtesr_OverrideAddress, DeliveryAddress) As FaxNumber, 
                    MAX(prtesr_CreatedBy)  
              FROM PRTESForm WITH (NOLOCK)
                   INNER JOIN PRTESRequest WITH (NOLOCK) on prtf_TESFormID = prtesr_TESFormID 
                   LEFT OUTER JOIN vPRCompanyAttentionLine ON prtf_CompanyID = prattn_CompanyID AND prattn_ItemCode = 'TES-E' AND prattn_PhoneID IS NOT NULL 
             WHERE prtf_SentMethod = 'F' 
               AND prtf_SentDateTime IS NULL 
               AND ISNULL(prtesr_OverrideAddress, DeliveryAddress) IS NOT NULL 
          GROUP BY prtf_TESFormID, prtf_SerialNumber, prtesr_ResponderCompanyID, prtesr_OverrideAddress, DeliveryAddress";

        protected const string SQL_UPDATE_TES_FORM = "UPDATE PRTESForm SET prtf_SentDateTime=@prtf_SentDateTime WHERE prtf_TESFormID = @prtf_TESFormID";

        protected const string MSG_TES_DETAIL_ERROR = " - BBID {0}, Fax Number {1}: {2}\n";
        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex) {
            _szName = "TESFax";

            base.Initialize(iIndex);

            try {
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("TESFaxInterval", 5)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("TESFax Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("TESFaxStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

            } catch (Exception e) {
                LogEventError("Error initializing TESFax event.", e);
                throw;
            }
        }

        /// <summary>
        /// Process any TES Custom Fax requests.
        /// </summary>
        override public void ProcessEvent() {

            DateTime dtExecutionStartDate = DateTime.Now;
            StringBuilder sbMsg = new StringBuilder();

            SqlConnection oConn = new SqlConnection(GetConnectionString());
            SqlDataReader oReader = null;
            SqlTransaction oTran = null;

            List<ReportUser> lReportUsers = new List<ReportUser>();
            List<string> lErrors = new List<string>();
            List<string> lDetails = new List<string>();

            int iCount = 0;
            int iErrorCount = 0;
            int iMaxErrorCount = Utilities.GetIntConfigValue("TESFaxMaxErrorCount", 0);
            int iMaxFaxCount = Utilities.GetIntConfigValue("TESFaxCount", 999999999);

            string szSubject = Utilities.GetConfigValue("TESFaxSubject", "TES Sent");
            string szCategory = Utilities.GetConfigValue("TESFaxCategory", string.Empty);
            string szSubcategory = Utilities.GetConfigValue("TESFaxSubcategory", string.Empty);
            bool bDoNotRecordCommunication = Utilities.GetBoolConfigValue("TESFaxDoNotRecordCommunication", true);

            try {

                oConn.Open();

                ReportInterface oReportInterface = new ReportInterface();
                byte[] abTESFormReport = null;

                
                SqlCommand oSQLCommand = null;

                // Create the form records
                oSQLCommand = new SqlCommand(SQL_GENERATE_TES_FAX_FORMS, oConn);
                oSQLCommand.Parameters.AddWithValue("SentMethod", "F");

                oSQLCommand.CommandType = CommandType.StoredProcedure;
                oSQLCommand.CommandTimeout = Utilities.GetIntConfigValue("TESFaxQueryTimeout", 300);
                oSQLCommand.ExecuteNonQuery();

                // Get list of who needs reports
                oSQLCommand = new SqlCommand(SQL_SELECT_FAX_TES, oConn);
                try {
                    oReader = oSQLCommand.ExecuteReader();
                    while (oReader.Read()) {
                        ReportUser oReportUser = new ReportUser();
                        oReportUser.TESFormID = oReader.GetInt32(0);
                        oReportUser.SerialNumber  = oReader.GetInt32(1);
                        oReportUser.CompanyID = oReader.GetInt32(2);
                        oReportUser.Destination =  oReader.GetString(3).Trim();
                        oReportUser.MethodID = DELIVERY_METHOD_FAX;
                        oReportUser.UserID = oReader.GetInt32(4);
                        lReportUsers.Add(oReportUser);
                    }
                } finally {
                    if (oReader != null) {
                        oReader.Close();
                    }
                }

                // Now generate the TES Fax for each user
                foreach(ReportUser oReportUser in lReportUsers) {
                    abTESFormReport = oReportInterface.GenerateTESReport(oReportUser.SerialNumber);

                    oTran = oConn.BeginTransaction();
                    try {
                        SendFax(oTran, 
                                oReportUser, 
                                abTESFormReport, 
                                "TESForm_" + oReportUser.TESFormID.ToString() + ".pdf",
                                szSubject,
                                szCategory,
                                szSubcategory,
                                bDoNotRecordCommunication,
                                "TES Form Fax Event");

                        // Now update the form record to record that it was
                        // actually sent.
                        SqlCommand oDBCommand = new SqlCommand(SQL_UPDATE_TES_FORM, oTran.Connection, oTran);
                        oDBCommand.Parameters.AddWithValue("@prtf_TESFormID", oReportUser.TESFormID);
                        oDBCommand.Parameters.AddWithValue("@prtf_SentDateTime", DateTime.Now);

                        object oValue = oDBCommand.ExecuteNonQuery();

                        iCount++;
                        oTran.Commit();
                    } catch(Exception e) {
                        oTran.Rollback();

                        string[] aArgs = {oReportUser.CompanyID.ToString(),
                                          oReportUser.Destination,
                                          e.Message};

                        lErrors.Add(string.Format(MSG_TES_DETAIL_ERROR, aArgs));

                        // If we exceed our max error count, abort
                        // the entire operation.
                        iErrorCount++;
                        if (iErrorCount > iMaxErrorCount) {
                            throw new ApplicationException("Maximum number of allowable errors exceeded.");
                        }
                    }
                }



                sbMsg.Append("TES Faxes Sent: " + iCount.ToString("###,##0"));
                sbMsg.Append("\nTES Fax Errors: " + iErrorCount.ToString("###,##0"));
                

                TimeSpan tsDiff = DateTime.Now.Subtract(dtExecutionStartDate);
                sbMsg.Append("\n\nExecution time: " + tsDiff.ToString());

                if (Utilities.GetBoolConfigValue("TESFaxtWriteResultsToEventLog", true))
                {
                    _oBBSMonitorService.LogEvent(sbMsg.ToString());
                }

                if (Utilities.GetBoolConfigValue("TESFaxSendResultsToSupport", false))
                {
                    SendMail("TESFax Reports Success", sbMsg.ToString());
                }


            } catch (Exception e) {
                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("Error Procesing TES Fax.", e);
            } finally {
                if (oConn != null) {
                    oConn.Close();
                }

                oConn = null;
            }
        }
    }
}