/***********************************************************************
 Copyright Produce Reporter Company 2020-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: AUSAlertEvent.cs
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
    /// Generates the AUS report
    /// </summary>
    public class AUSAlertEvent : AUSReportEventBase {
        DateTime _dtExecutionStartDate;
        SqlConnection _oConn;
        SqlTransaction _oTran = null;
        DateTime _dtStartDate = new DateTime();
        DateTime _dtEndDate = new DateTime();

        List<string> _lAUSErrors = new List<string>();
        List<string> _lAUSDetails = new List<string>();

        int _iMonitoredCompanyID = 0;
        int _iTotalChanges = 0;
        int _iReportCount = 0;
        int _iEmailCount = 0;
        int _iErrorCount = 0;

        int _iMaxErrorCount = 0;
        int _iMaxReportCount = 0;
        string _szSubject;
        string _szCategory;
        string _szSubcategory;
        bool _bDoNotRecordCommunication;
        string _szMethod = "Email";

        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex) {
            _szName = "AUSAlert";

            base.Initialize(iIndex);

            try {
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("AUSAlertInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("AUS Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("AUSAlertStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

            } catch (Exception e) {
                LogEventError("Error initializing AUS Alert event.", e);
                throw;
            }
        }

        /// <summary>
        /// Process any AUS reports.
        /// </summary>
        override public void ProcessEvent() {
            _dtExecutionStartDate = DateTime.Now;

            // Look to see if this is a special run to report
            // on a specific company.
            _iMonitoredCompanyID = Utilities.GetIntConfigValue("AUSAlertMonitoredCompanyID", 0);

            _dtStartDate = new DateTime();
            _dtEndDate = _dtNextDateTime;

            _lAUSErrors = new List<string>();
            _lAUSDetails = new List<string>();

            _oConn = new SqlConnection(GetConnectionString());
            _oTran = null;

            try {
                _oConn.Open();

                _dtStartDate = GetDateTimeCustomCaption(_oConn, "prau_LastAlertDateTime");

                _oLogger.LogMessage("dtStartDate=" + _dtStartDate.ToString());
                _oLogger.LogMessage("dtEndDate=" + _dtEndDate.ToString());

                _iReportCount = 0;
                _iTotalChanges = 0;
                _iErrorCount = 0;
                _iEmailCount = 0;
                _iMaxErrorCount = Utilities.GetIntConfigValue("AUSAlertMaxErrorCount", 0);
                _iMaxReportCount = Utilities.GetIntConfigValue("AUSAlertMaxReportCount", 999999999);
                _szSubject = Utilities.GetConfigValue("AUSAlertSubject", "Your Blue Book Alerts");
                _szCategory = Utilities.GetConfigValue("AUSAlertCategory", string.Empty);
                _szSubcategory = Utilities.GetConfigValue("AUSAlertSubcategory", string.Empty);
                _bDoNotRecordCommunication = Utilities.GetBoolConfigValue("AUSAlertDoNotRecordCommunication", true);

                GenerateEmail();

                if (_iMonitoredCompanyID <= 0) {
                    // Update our date/time for our next run.
                    UpdateDateTimeCustomCaption(_oConn, "prau_LastAlertDateTime", _dtEndDate);
                }

                // Now summarize what happened and log 
                // it somewhere.
                StringBuilder sbMsg = new StringBuilder();

                if (_iMonitoredCompanyID > 0) {
                    sbMsg.Append(string.Format(MSG_AUS_LIMITED, _iMonitoredCompanyID));
                }

                object[] aMsgArgs = {_iTotalChanges, 
                                     _dtStartDate,
                                     _dtEndDate,
                                     _iReportCount,
                                     _iEmailCount,
                                     0};
                sbMsg.Append(string.Format(MSG_AUS_SUMMARY, aMsgArgs));

                AddListToBuffer(sbMsg, _lAUSErrors, "Errors");
                if (Utilities.GetBoolConfigValue("AUSAlertSendResultsDetails", true)) {
                    AddListToBuffer(sbMsg, _lAUSDetails, "Detail(s)");
                }

                TimeSpan tsDiff = DateTime.Now.Subtract(_dtExecutionStartDate);
                sbMsg.Append("\n\nExecution time: " + tsDiff.ToString());

                if (Utilities.GetBoolConfigValue("AUSAlertWriteResultsToEventLog", true)) {
                    LogEvent(sbMsg.ToString());
                }

                if (Utilities.GetBoolConfigValue("AUSAlertSendResultsToSupport", true)) {
                    SendMail("AUS Alerts Success", sbMsg.ToString());
                }
            } catch (Exception e) {
                LogEventError("Error Procesing AUS Alerts.", e);


                StringBuilder sbMsg = new StringBuilder();

                if (_iMonitoredCompanyID > 0) {
                    sbMsg.Append(string.Format(MSG_AUS_LIMITED, _iMonitoredCompanyID));
                }

                sbMsg.Append(MSG_ERROR);

                AddListToBuffer(sbMsg, _lAUSErrors, "Error(s)");

                sbMsg.Append("\n\n" + e.Message);
                sbMsg.Append("\n\n" + e.StackTrace);
                SendMail("AUS Alerts Error", sbMsg.ToString());

            } finally {
                if (_oConn != null) {
                    _oConn.Close();
                }

                _oConn = null;
                _lAUSDetails = null;
                _lAUSErrors = null;
            }
        }

        public void GenerateEmail()
        {
            List<ReportUser> lReportUser = new List<ReportUser>();

            // Get list of who needs reports
            SqlCommand oSQLCommand = null;
            if (_iMonitoredCompanyID > 0)
            {
                oSQLCommand = new SqlCommand("usp_GetAUSReportItemsForMonitoredCompany", _oConn);
                oSQLCommand.Parameters.AddWithValue("@MonitoredCompanyID", _iMonitoredCompanyID);
            }
            else
            {
                oSQLCommand = new SqlCommand("usp_GetAUSReportItems", _oConn);
            }
            
            oSQLCommand.CommandType = CommandType.StoredProcedure;
            oSQLCommand.CommandTimeout = Utilities.GetIntConfigValue("AUSQueryTimeout", 300);
            oSQLCommand.Parameters.AddWithValue("@StartDate", _dtStartDate);
            oSQLCommand.Parameters.AddWithValue("@EndDate", _dtEndDate);
            oSQLCommand.Parameters.AddWithValue("@ReceiveMethod", "4"); //Email -- Immediately

            using (SqlDataReader oReader = oSQLCommand.ExecuteReader(CommandBehavior.Default))
            {
                while (oReader.Read())
                {
                    ReportUser oReportUser = new ReportUser(oReader.GetInt32(0), oReader.GetInt32(1), oReader.GetString(2), oReader.GetInt32(3));
                    lReportUser.Add(oReportUser);
                }
            }

            // Now go execute the email for each one of
            // these and send it out

            string szEmailImageHTML_TOP = "";
            string szEmailImageHTML_BOTTOM = "";

            foreach (ReportUser oReportUser in lReportUser)
            {
                //oTran = oConn.BeginTransaction();
                try
                {
                    const string SQL_GET_INDUSTRY_TYPE = @"
                            SELECT comp_PRIndustryType
                            FROM PRWebUser WITH(NOLOCK)
                                INNER JOIN Person_Link WITH(NOLOCK) ON prwu_PersonLinkID = peli_PersonLinkID
                                INNER JOIN Company WITH(NOLOCK) on peli_CompanyID = comp_CompanyID
                            WHERE peli_PersonID = @PersonID
                                AND peli_CompanyID = @CompanyID";

                    SqlCommand oSQLCommandIndustryType = new SqlCommand(SQL_GET_INDUSTRY_TYPE, _oConn);
                    oSQLCommandIndustryType.CommandType = CommandType.Text;
                    oSQLCommandIndustryType.CommandTimeout = Utilities.GetIntConfigValue("BBSMonitorQueryTimeout", 300);

                    oSQLCommandIndustryType.Parameters.AddWithValue("@PersonID", oReportUser.PersonID);
                    oSQLCommandIndustryType.Parameters.AddWithValue("@CompanyID", oReportUser.CompanyID);

                    string szIndustryType = Convert.ToString(oSQLCommandIndustryType.ExecuteScalar());
                    oReportUser.IndustryType = szIndustryType;

                    szEmailImageHTML_TOP = GetEmailImage(_oConn, "1", "T", szIndustryType);
                    szEmailImageHTML_BOTTOM = GetEmailImage(_oConn, "1", "B", szIndustryType);

                    _iTotalChanges += oReportUser.ChangeCount;

                    GetAlertsReportHeader(_oConn, oReportUser);

                    if (oReportUser.Invalid)
                    {
                        string[] aArgs = {"generating the AUS report",
                                              oReportUser.PersonName  + " (" + oReportUser.PersonID.ToString() + ")",
                                              oReportUser.CompanyName,
                                              oReportUser.CompanyID.ToString(),
                                              "NULL AUS Settings Found."};

                        _lAUSErrors.Add(string.Format(MSG_DETAIL_ERROR, aArgs));

                    }
                    else
                    {
                        _iReportCount++;

                        string _szContent;
                        if (oReportUser.Culture == "es-mx")
                            _szContent = string.Format(GetEmailTemplate("AUSContent_S.html"), "correo electr&oacute;nico", _dtNextDateTime.ToString("MMMM d, yyyy")); 
                        else
                            _szContent = string.Format(GetEmailTemplate("AUSContent.html"), "email", _dtNextDateTime.ToString("MMMM d, yyyy")); 

                        _szContent += GenerateAlertEmail(_oConn, oReportUser.PersonID, oReportUser.CompanyID, oReportUser.IndustryType, oReportUser.Culture, _dtStartDate, _dtEndDate);

                        _iEmailCount++;
                        _szContent = GetFormattedEmail(_oConn, _oTran, oReportUser.CompanyID, oReportUser.PersonID, _szSubject, _szContent, szEmailImageHTML_TOP, szEmailImageHTML_BOTTOM);

                        _oLogger.LogMessage(string.Format("Sending to {0}, {1} at {2}", oReportUser.CompanyName, oReportUser.PersonName, oReportUser.Destination));

                        SqlTransaction oTranEmail = _oConn.BeginTransaction();

                        SendEmail(oTranEmail,
                                    oReportUser,
                                    _szSubject,
                                    _szContent,
                                    _szCategory,
                                    _szSubcategory,
                                    _bDoNotRecordCommunication,
                                    "AUS Alert Event",
                                    "HTML");
                        oTranEmail.Commit();
                        oTranEmail = null;

                        string[] aArgs = { _szMethod,
                                           oReportUser.Destination,
                                           oReportUser.PersonName  + " (" + oReportUser.PersonID.ToString() + ")",
                                           oReportUser.CompanyName,
                                           oReportUser.CompanyID.ToString(),
                                           oReportUser.ChangeCount.ToString() };

                        _lAUSDetails.Add(string.Format(MSG_AUS_DETAIL, aArgs));

                        if (_iReportCount >= _iMaxReportCount)
                        {
                            break;
                        }
                    }

                    // Commit and set to NULL.
                    //oTran.Commit();
                    //oTran = null;

                }
                catch (Exception e)
                {

                    //if (oTran != null)
                    //{
                    //    oTran.Rollback();
                    //}

                    LogEventError("Error Generating AUS Alert Report.", e);

                    string[] aArgs = { "generating the AUS Alert report",
                                           oReportUser.PersonName  + " (" + oReportUser.PersonID.ToString() + ")",
                                           oReportUser.CompanyName,
                                           oReportUser.CompanyID.ToString(),
                                           e.Message};

                    _lAUSErrors.Add(string.Format(MSG_DETAIL_ERROR, aArgs));

                    // If we exceed our max error count, abort
                    // the entire operation.
                    _iErrorCount++;
                    if (_iErrorCount > _iMaxErrorCount)
                    {
                        throw new ApplicationException("Maximum number of allowable errors exceeded.");
                    }
                }
            }
        }
    }
}