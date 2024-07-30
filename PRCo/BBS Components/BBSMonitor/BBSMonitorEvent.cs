/***********************************************************************
 Copyright Produce Reporter Company 2006-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: BBSMonitorEvent.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.IO;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Timers;
using Microsoft.Win32;
using Renci.SshNet;
using TSI.BusinessObjects;
using TSI.Utils;

namespace PRCo.BBS.BBSMonitor {

    /// <summary>
    /// Provides the common functionality for all BBS Monitor
    /// events.
    /// </summary>
    abstract public class BBSMonitorEvent : IBBSMonitorEvent
    {

        protected BBSMonitor _oBBSMonitorService;
        protected Timer _oEventTimer;
        protected long _lEventInterval;
        protected DateTime _dtStartDateTime;
        protected DateTime _dtNextDateTime;
        protected int _iEventIndex;
        protected string _szName;
        private EventLog _oEventLog;
        protected ILogger _oLogger;
        protected Dictionary<string, string> _htEmailTemplates = null;


        protected const string CONN_STRING = "server={0};User ID={1};Password={2};Initial Catalog={3};Application Name=BBSMonitor";

        protected const string MSG_DETAIL_ERROR = " - {1} with {2} BBID {3}: {4}\n";
        protected const string MSG_ERROR = "Some number of errors occured during processing.  The exception description and stack trace are included below, as well as any individual errors.";

        protected const int DELIVERY_METHOD_FAX = 1;
        protected const int DELIVERY_METHOD_EMAIL = 2;
        protected const int DELIVERY_METHOD_POSTAL = 3;
        protected const long ONE_MINUTE_IN_MILLISECONDS = 60000;
        protected const string SQL_SELECT_CUSTOM_CAPTION = "SELECT RTRIM(capt_code) AS capt_code FROM Custom_Captions WHERE capt_family = @capt_family";
        protected const string SQL_SELECT_CUSTOM_CAPTION_US = "SELECT RTRIM(capt_US) AS capt_US FROM Custom_Captions WHERE capt_family = @capt_family";
        protected const string SQL_UPDATE_CUSTOM_CAPTION = "UPDATE Custom_Captions SET capt_code = @capt_code WHERE capt_family = @capt_family";

        #region Properties
        protected virtual bool IsInitialized
        {
            get
            {
                return (_dtNextDateTime != DateTime.MinValue);
            }
        }

        virtual public BBSMonitor BBSMonitorService
        {
            get { return _oBBSMonitorService; }
            set { _oBBSMonitorService = value; }
        }


        virtual public int EventIndex
        {
            get { return _iEventIndex; }
            set { _iEventIndex = value; }
        }

        protected virtual EventLog EventLog
        {
            get
            {
                if (_oEventLog == null)
                {
                    _oEventLog = BBSMonitorService.EventLog;
                }
                return _oEventLog;
            }
            set { _oEventLog = value; }
        }

        protected virtual ILogger Logger
        {
            get { return _oLogger; }
            set { _oLogger = value; }
        }

        public virtual System.Timers.Timer EventTimer
        {
            get
            {
                if (_oEventTimer == null)
                    _oEventTimer = new Timer();
                return _oEventTimer;
            }
            set
            {
                if (IsInitialized)
                {
                    throw new NotSupportedException("Cannot set EventTimer after initialization!");
                }
                _oEventTimer = value;
            }
        }

        protected virtual long EventInterval
        {
            get
            {
                if (_lEventInterval == Int64.MinValue)
                    _lEventInterval = Utilities.GetIntConfigValue(this.Name + "Interval");

                return _lEventInterval * (60 * 1000);  // Convert from minutes to milliseconds
            }
            set { _lEventInterval = value; }
        }

        protected virtual string Name
        {
            get
            {
                if (_szName == null)
                    _szName = GetType().Name;
                return _szName;
            }
            set { _szName = value; }
        }

        protected virtual DateTime StartDateTime
        {
            get
            {
                if (_dtStartDateTime == DateTime.MinValue)
                {
                    var szConfigVal = Utilities.GetConfigValue(Name + "StartDateTime", string.Empty);
                    if (string.IsNullOrEmpty(szConfigVal))
                        _dtStartDateTime = DateTime.Now;
                    else
                        _dtStartDateTime = Convert.ToDateTime(szConfigVal);
                }
                return _dtStartDateTime;
            }
            set
            {
                if (IsInitialized)
                {
                    throw new NotSupportedException("Cannot set StartDateTime after initialization!");
                }
                _dtStartDateTime = value;
            }
        }

        protected virtual bool WriteResultsToEventLog
        {
            get
            {
                return Utilities.GetBoolConfigValue(Name + "WriteResultsToEventLog", true);
            }
        }

        protected virtual bool SendResultsToSupport
        {
            get
            {
                return Utilities.GetBoolConfigValue(Name + "SendResultsToSupport", false);
            }
        }
        #endregion


        #region Logging-related methods

        protected virtual void LogMessage(string szMsg)
        {
            Logger.RequestName = GetType().Name;
            Logger.LogMessage(szMsg);
        }

        protected virtual void LogEventError(string szMsg, Exception e)
        {
            Logger.LogError(szMsg, e);
        }

        /// <summary>
        /// Writes an error message to the Event Log.
        /// </summary>
        /// <param name="szMessage">Message</param>
        /// <param name="oEventType">Event Type</param>
        protected virtual void LogEvent(string szMessage, EventLogEntryType oEventType)
        {
            EventLog.WriteEntry(szMessage, oEventType);
        }

        /// <summary>
        /// Writes the information message to the Event Log.
        /// </summary>
        /// <param name="szMessage">Message</param>
        protected virtual void LogEvent(string szMessage)
        {
            LogEvent(szMessage, EventLogEntryType.Information);
        }

        #endregion


        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        virtual public void Initialize(int iIndex)
        {
            EventIndex = iIndex;

            _oLogger = LoggerFactory.GetLogger();
            _oLogger.RequestName = _szName;
        }

        /// <summary>
        /// Time to light this candle!
        /// </summary>
        virtual public void OnStart()
        {

            // Treat an interval of 0 as "disabled"
            if (_lEventInterval <= 0)
            {
                _oLogger.LogMessage("Event is disabled");
                return;
            }

            _oLogger.LogMessage("OnStart - dtNextExecution:" + _dtNextDateTime.ToString());
            if (_dtNextDateTime < DateTime.Now)
                ConfigureTimer(false);

            _oEventTimer.AutoReset = true;
            _oEventTimer.Enabled = true;
            _oEventTimer.Start();
        }

        /// <summary>
        /// Whoa, hold the horses!
        /// </summary>
        virtual public void OnStop()
        {
            _oEventTimer.AutoReset = false;
            _oEventTimer.Enabled = false;
            _oEventTimer.Stop();
        }

        /// <summary>
        /// Event handler
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        virtual public void ProcessTick(object sender, System.Timers.ElapsedEventArgs e)
        {
            // Just in case we run long, stop the timer to this handler cannot
            // fire again until we're done with this execution.
            _oEventTimer.Stop();

            _oLogger.LogMessage("Execution Begin");

            try
            {
                ProcessEvent();
            }
            catch (Exception eX)
            {
                // If we hit an exception trying to send this message, we should eat it because half of the time
                // we send email, it's from an exception handler.
                LogEventError("Exception in ProcessEvent for " + _szName + ".", eX);
            }

            ConfigureTimer(true);
            _oLogger.LogMessage("Execution End");

            _oEventTimer.Start();
        }

        /// <summary>
        /// This method does the actual heavy lifting.  It must be implemented by all
        /// BBSMonitor events, as it is event specific.
        /// </summary>
        abstract public void ProcessEvent();


        /// <summary>
        /// Sets the timer interval to the next future date based on the
        /// specified date/time and interval.
        /// </summary>
        /// <param name="bExecutedEvent">Configures the timer differently if an event has executed.</param>
        virtual protected void ConfigureTimer(bool bExecutedEvent)
        {

            // Treat an interval of 0 as "disabled"
            if (_lEventInterval <= 0)
            {
                _oLogger.LogMessage("Event is disabled");
                return;
            }

            DateTime dtNow = DateTime.Now;

            // If we executed an event, make sure we add at least one (1) interval
            // to our _dtNextDateTime.  There are no situations were we execute an event
            // where this should not happened.  We cannot rely on the subsequent loop
            // below to accomplish this because the event may have fired off early and 
            // finished prior to the current _dtNextDateTime.
            if (bExecutedEvent)
                _dtNextDateTime = _dtNextDateTime.AddMilliseconds(_lEventInterval);

            // Make sure our next execution time is in 
            // the future.
            while (_dtNextDateTime <= dtNow)
            {
                _dtNextDateTime = _dtNextDateTime.AddMilliseconds(_lEventInterval);
            }

            long lComputedInterval = Convert.ToInt32(_dtNextDateTime.Subtract(dtNow).TotalMilliseconds);
            _oEventTimer.Interval = lComputedInterval;

            _oLogger.LogMessage("dtNextExecution:" + _dtNextDateTime.ToString());
            _oLogger.LogMessage("lComputedInterval:" + lComputedInterval.ToString());
        }

        /// <summary>
        /// Sends email to our support address
        /// </summary>
        /// <param name="szSubject">Subject</param>
        /// <param name="szMessage">Message</param>
        virtual protected void SendMail(string szSubject,
                                        string szMessage)
        {

            SendMail(Utilities.GetConfigValue("EmailSupportTo", "cwalls@travant.com"), szSubject, szMessage);
        }

        /// <summary>
        /// Stored procedure version that doesn't use SMTPClient
        /// Defect 3768 - April 2022
        /// </summary>
        /// <param name="szTo"></param>
        /// <param name="szSubject"></param>
        /// <param name="szMessage"></param>
        virtual protected void SendMail(string szTo,
                                        string szSubject,
                                        string szMessage)
        {
            string szFrom = Utilities.GetConfigValue("EmailSupportFrom", "bluebookservices@bluebookservices.com");
            string szCommAction = "EmailOut";

            szTo = szTo.Replace(",", ";"); //replace comma w/ semicolon

            szSubject = Utilities.GetConfigValue("EmailSubjectPrefix", string.Empty) + szSubject;

            string sSQL = "EXEC usp_CreateEmail " +
                        "@To=@To, " +
                        "@From=@From, " +
                        "@Subject=@Subject, " +
                        "@Content=@Content, " +
                        "@Action=@Action, " +
                        "@Source='BBSMonitor', " +
                        "@Content_Format='TEXT';"; 

            SqlConnection oConn = new SqlConnection(GetConnectionString());

            try
            {
                oConn.Open();
                SqlCommand oSQLSendMail = new SqlCommand(sSQL, oConn);
                oSQLSendMail.CommandType = CommandType.Text;

                oSQLSendMail.Parameters.AddWithValue("To", szTo);
                oSQLSendMail.Parameters.AddWithValue("From", szFrom);
                oSQLSendMail.Parameters.AddWithValue("Subject", szSubject);
                oSQLSendMail.Parameters.AddWithValue("Content", szMessage);
                oSQLSendMail.Parameters.AddWithValue("Action", szCommAction);

                oSQLSendMail.CommandTimeout = Utilities.GetIntConfigValue("BBSMonitorQueryTimeout", 300);
                oSQLSendMail.ExecuteScalar();
            }
            catch (Exception e)
            {
                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("Error in SendMail", e);
            }
            finally
            {
                if (oConn != null)
                    oConn.Close();

                oConn = null;
            }
        }


        /// <summary>
        /// Helper method to write the byte array to disk.
        /// </summary>
        /// <param name="abReport"></param>
        /// <param name="szFileName"></param>
        virtual protected void WriteReportToDisk(byte[] abReport, string szFileName)
        {
            string szFullName = Path.Combine(Utilities.GetConfigValue("ReportPath"), szFileName);
            using (FileStream oFStream = File.Create(szFullName, abReport.Length))
            {
                oFStream.Write(abReport, 0, abReport.Length);
            }
        }

        virtual protected void WriteReportToDisk(byte[] abReport, string szFileName, string szPath)
        {
            string szFullName = Path.Combine(szPath, szFileName);
            using (FileStream oFStream = File.Create(szFullName, abReport.Length))
            {
                oFStream.Write(abReport, 0, abReport.Length);
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="oTran"></param>
        /// <param name="oReportUser"></param>
        /// <param name="szSubject"></param>
        /// <param name="szContent"></param>
        /// <param name="abReport"></param>
        /// <param name="szAttachmentName"></param>
        /// <param name="szCategory"></param>
        /// <param name="szSubCategory"></param>
        /// <param name="DoNotRecordCommunication"></param>
        /// <param name="source"></param>
        /// <param name="emailFormat"></param>
        virtual protected void SendReport(SqlTransaction oTran,
                                          ReportUser oReportUser,
                                          string szSubject,
                                          string szContent,
                                          byte[] abReport,
                                          string szAttachmentName,
                                          string szCategory,
                                          string szSubCategory,
                                          bool DoNotRecordCommunication,
                                          string source,
                                          string emailFormat,
                                          string profile = "Blue Book Services")
        {
            string[] aszAttachments = { szAttachmentName };
            List<byte[]> lReportFiles = new List<byte[]>();
            lReportFiles.Add(abReport);
            SendReport(oTran.Connection, oTran, oReportUser, szSubject, szContent, lReportFiles, aszAttachments, szCategory, szSubCategory, DoNotRecordCommunication, source, emailFormat, profile);

        }

        virtual protected void SendReport(SqlConnection dbConn,
                                          SqlTransaction oTran,
                                          ReportUser oReportUser,
                                          string szSubject,
                                          string szContent,
                                          byte[] abReport,
                                          string szAttachmentName,
                                          string szCategory,
                                          string szSubCategory,
                                          bool DoNotRecordCommunication,
                                          string source,
                                          string emailFormat,
                                          string profile = "Blue Book Services")
        {

            string[] aszAttachments = { szAttachmentName };
            List<byte[]> lReportFiles = new List<byte[]>();
            lReportFiles.Add(abReport);
            SendReport(dbConn, oTran, oReportUser, szSubject, szContent, lReportFiles, aszAttachments, szCategory, szSubCategory, DoNotRecordCommunication, source, emailFormat, profile);
        }

        virtual protected void SendEmail(SqlTransaction oTran,
                                          ReportUser oReportUser,
                                          string szSubject,
                                          string szContent,
                                          string szCategory,
                                          string szSubCategory,
                                          bool DoNotRecordCommunication,
                                          string source,
                                          string emailFormat)
        {
            SendReport(oTran,
                        oReportUser,
                        szSubject,
                        szContent,
                        new List<byte[]>(),
                        null,
                        szCategory,
                        szSubCategory,
                        DoNotRecordCommunication,
                        source,
                        emailFormat);
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="oTran"></param>
        /// <param name="oReportUser"></param>
        /// <param name="lReportFiles"></param>
        /// <param name="szSubject"></param>
        /// <param name="szContent"></param>
        /// <param name="aszAttachmentName"></param>
        /// <param name="szCategory"></param>
        /// <param name="szSubCategory"></param>
        /// <param name="DoNotRecordCommunication"></param>
        /// <param name="source"></param>
        /// <param name="emailFormat"></param>
        virtual protected void SendReport(SqlTransaction oTran,
                                          ReportUser oReportUser,
                                          string szSubject,
                                          string szContent,
                                          List<byte[]> lReportFiles,
                                          string[] aszAttachmentName,
                                          string szCategory,
                                          string szSubCategory,
                                          bool DoNotRecordCommunication,
                                          string source,
                                          string emailFormat)
        {
            SendReport(oTran.Connection,
                        oTran,
                        oReportUser,
                        szSubject,
                        szContent,
                        lReportFiles,
                        aszAttachmentName,
                        szCategory,
                        szSubCategory,
                        DoNotRecordCommunication,
                        source,
                        emailFormat);

        }

        virtual protected void SendReport(SqlConnection dbConn,
                                          SqlTransaction oTran,
                                          ReportUser oReportUser,
                                          string szSubject,
                                          string szContent,
                                          List<byte[]> lReportFiles,
                                          string[] aszAttachmentName,
                                          string szCategory,
                                          string szSubCategory,
                                          bool DoNotRecordCommunication,
                                          string source,
                                          string emailFormat,
                                          string profile = "Blue Book Services")
        {

            SqlCommand oSQLCommand = new SqlCommand("usp_CreateEmail", dbConn, oTran);
            oSQLCommand.CommandType = CommandType.StoredProcedure;
            oSQLCommand.CommandTimeout = Utilities.GetIntConfigValue("BBSMonitorQueryTimeout", 300);
            oSQLCommand.Parameters.AddWithValue("@CreatorUserId", -1);
            oSQLCommand.Parameters.AddWithValue("@From", Utilities.GetConfigValue("CommunicationFrom", "System"));
            oSQLCommand.Parameters.AddWithValue("ProfileName", profile);
            oSQLCommand.Parameters.AddWithValue("@Subject", szSubject);
            oSQLCommand.Parameters.AddWithValue("@Content", szContent);
            oSQLCommand.Parameters.AddWithValue("@RelatedPersonId", oReportUser.PersonID);
            oSQLCommand.Parameters.AddWithValue("@RelatedCompanyId", oReportUser.CompanyID);


            if (DoNotRecordCommunication)
                oSQLCommand.Parameters.AddWithValue("@DoNotRecordCommunication", 1);

            if (!string.IsNullOrEmpty(szCategory))
                oSQLCommand.Parameters.AddWithValue("@PRCategory", szCategory);

            if (!string.IsNullOrEmpty(szSubCategory))
                oSQLCommand.Parameters.AddWithValue("@PRSubcategory", szSubCategory);

            if (!string.IsNullOrEmpty(source))
                oSQLCommand.Parameters.AddWithValue("@Source", source);

            if (!string.IsNullOrEmpty(emailFormat))
                oSQLCommand.Parameters.AddWithValue("@Content_Format", emailFormat);

            if (oReportUser.MethodID == DELIVERY_METHOD_FAX)
            {
                oSQLCommand.Parameters.AddWithValue("@To", Utilities.GetConfigValue("TestFax", oReportUser.Destination));
                oSQLCommand.Parameters.AddWithValue("@Action", "FaxOut");
            }
            else
            {
                oSQLCommand.Parameters.AddWithValue("@To", Utilities.GetConfigValue("TestEmail", oReportUser.Destination));
                oSQLCommand.Parameters.AddWithValue("@Action", "EmailOut");
            }

            if ((lReportFiles != null) && (lReportFiles.Count > 0))
            {

                // Spin through our attachments
                string szAttachmentList = string.Empty;
                for (int i = 0; i < aszAttachmentName.Length; i++)
                {
                    WriteReportToDisk(lReportFiles[i], aszAttachmentName[i]);

                    if (szAttachmentList.Length > 0)
                        szAttachmentList += ";";

                    szAttachmentList += Utilities.GetConfigValue("SQLReportPath") + aszAttachmentName[i];
                }

                oSQLCommand.Parameters.AddWithValue("@AttachmentDir", Utilities.GetConfigValue("SQLReportPath"));
                oSQLCommand.Parameters.AddWithValue("@AttachmentFileName", szAttachmentList);
            }

            int iReturn = Convert.ToInt32(oSQLCommand.ExecuteScalar());
            if (iReturn != 0)
                throw new ApplicationException("Non-zero return code sending " + szSubject + " for person " + oReportUser.PersonID.ToString() + ", company " + oReportUser.CompanyID.ToString() + ": " + iReturn.ToString());

            // Clean up after ourselves
            if (!Utilities.GetBoolConfigValue("WriteReportToDisk", false))
            {
                foreach (string szAttachmentName in aszAttachmentName)
                {
                    File.Delete(string.Concat(Utilities.GetConfigValue("ReportPath"), szAttachmentName));
                }
            }
        }

        /// <summary>
        /// Sends a fax using the values in the ReportUser object
        /// </summary>
        /// <param name="oTran"></param>
        /// <param name="oReportUser"></param>
        /// <param name="abFaxFile"></param>
        /// <param name="szAttachmentName"></param>
        /// <param name="szSubject"></param>
        /// <param name="szCategory"></param>
        /// <param name="szSubCategory"></param>
        /// <param name="DoNotRecordCommunication"></param>
        /// <param name="szSource"></param>
        virtual protected void SendFax(SqlTransaction oTran,
                                       ReportUser oReportUser,
                                       byte[] abFaxFile,
                                       string szAttachmentName,
                                       string szSubject,
                                       string szCategory,
                                       string szSubCategory,
                                       bool DoNotRecordCommunication,
                                       string szSource)
        {

            SqlCommand oSQLCommand = new SqlCommand("usp_CreateEmail", oTran.Connection, oTran);
            oSQLCommand.CommandType = CommandType.StoredProcedure;
            oSQLCommand.CommandTimeout = Utilities.GetIntConfigValue("BBSMonitorQueryTimeout", 300);
            oSQLCommand.Parameters.AddWithValue("@CreatorUserId", oReportUser.UserID);
            oSQLCommand.Parameters.AddWithValue("@From", Utilities.GetConfigValue("CommunicationFrom", "System"));
            oSQLCommand.Parameters.AddWithValue("@To", Utilities.GetConfigValue("TestFax", oReportUser.Destination));
            oSQLCommand.Parameters.AddWithValue("@Action", "FaxOut");
            oSQLCommand.Parameters.AddWithValue("@RelatedCompanyId", oReportUser.CompanyID);
            oSQLCommand.Parameters.AddWithValue("@RightFaxEmbeddedCodes", oReportUser.RightFaxEmbeddedCodes);
            oSQLCommand.Parameters.AddWithValue("@Source", szSource);

            if (DoNotRecordCommunication)
                oSQLCommand.Parameters.AddWithValue("@DoNotRecordCommunication", 1);

            if (!string.IsNullOrEmpty(szSubject))
                oSQLCommand.Parameters.AddWithValue("@Subject", szSubject);

            if (!string.IsNullOrEmpty(szCategory))
                oSQLCommand.Parameters.AddWithValue("@PRCategory", szCategory);

            if (!string.IsNullOrEmpty(szSubCategory))
                oSQLCommand.Parameters.AddWithValue("@PRSubcategory", szSubCategory);

            // Save the report to disk
            WriteReportToDisk(abFaxFile, szAttachmentName);
            string szAttachmentList = Utilities.GetConfigValue("SQLReportPath") + szAttachmentName;

            oSQLCommand.Parameters.AddWithValue("@AttachmentDir", Utilities.GetConfigValue("SQLReportPath"));
            oSQLCommand.Parameters.AddWithValue("@AttachmentFileName", szAttachmentList);

            int iReturn = Convert.ToInt32(oSQLCommand.ExecuteScalar());
            if (iReturn != 0)
                throw new ApplicationException("Non-zero return code sending fax to " + oReportUser.Destination + ": " + iReturn.ToString());

            // Clean up after ourselves
            if (!Utilities.GetBoolConfigValue("WriteReportToDisk", false))
                File.Delete(string.Concat(Utilities.GetConfigValue("ReportPath"), szAttachmentName));
        }


        /// <summary>
        /// Sends an email.
        /// </summary>
        /// <param name="oConn"></param>
        /// <param name="szSubject"></param>
        /// <param name="szEmail"></param>
        /// <param name="abAttachment"></param>
        /// <param name="szAttachmentName"></param>
        /// <param name="source"></param>
        virtual protected void SendInternalEmail(SqlConnection oConn, string szSubject, string szEmail, byte[] abAttachment, string szAttachmentName, string source)
        {
            SendInternalEmail(oConn, null, szSubject, szEmail, abAttachment, szAttachmentName, source);
        }

        /// <summary>
        /// Sends an email.
        /// </summary>
        /// <param name="oConn"></param>
        /// <param name="oTran"></param>
        /// <param name="szSubject"></param>
        /// <param name="szEmail"></param>
        /// <param name="abAttachment"></param>
        /// <param name="szAttachmentName"></param>
        /// <param name="source"></param>
        virtual protected void SendInternalEmail(SqlConnection oConn, SqlTransaction oTran, string szSubject, string szEmail, byte[] abAttachment, string szAttachmentName, string source)
        {
            List<EmailAttachment> attachments = new List<EmailAttachment>();
            if (abAttachment != null)
                attachments.Add(new EmailAttachment(szAttachmentName, abAttachment));

            SendInternalEmail(oConn, null, szSubject, szEmail, null, attachments, source);
        }

        virtual protected void SendInternalEmail(SqlConnection oConn, SqlTransaction oTran, string szSubject, string szEmail, string szContent, List<EmailAttachment> attachments, string source)
        {

            SqlCommand oSQLCommand = null;
            if (oTran == null)
                oSQLCommand = new SqlCommand("usp_CreateEmail", oConn);
            else
                oSQLCommand = new SqlCommand("usp_CreateEmail", oTran.Connection, oTran);

            oSQLCommand.CommandType = CommandType.StoredProcedure;
            oSQLCommand.CommandTimeout = Utilities.GetIntConfigValue("BBSMonitorQueryTimeout", 300);
            oSQLCommand.Parameters.AddWithValue("@Subject", szSubject);
            oSQLCommand.Parameters.AddWithValue("@Content", szContent);
            oSQLCommand.Parameters.AddWithValue("@From", Utilities.GetConfigValue("CommunicationFrom", "System"));
            oSQLCommand.Parameters.AddWithValue("@To", Utilities.GetConfigValue("TestEmail", szEmail));
            oSQLCommand.Parameters.AddWithValue("@Action", "EmailOut");
            oSQLCommand.Parameters.AddWithValue("@DoNotRecordCommunication", 1);

            if (!string.IsNullOrEmpty(source))
                oSQLCommand.Parameters.AddWithValue("@Source", source);

            if ((attachments != null) &&
                (attachments.Count > 0))
            {

                StringBuilder attachmentList = new StringBuilder();
                foreach (EmailAttachment attachment in attachments)
                {
                    // Save the report to disk
                    WriteReportToDisk(attachment.File, attachment.Name);

                    if (attachmentList.Length > 0)
                        attachmentList.Append(";");

                    attachmentList.Append(Utilities.GetConfigValue("SQLReportPath") + attachment.Name);
                }

                oSQLCommand.Parameters.AddWithValue("@AttachmentDir", Utilities.GetConfigValue("SQLReportPath"));
                oSQLCommand.Parameters.AddWithValue("@AttachmentFileName", attachmentList.ToString());
            }


            int iReturn = Convert.ToInt32(oSQLCommand.ExecuteScalar());
            if (iReturn != 0)
            {
                throw new ApplicationException("Non-zero return code sending email to " + szEmail + ": " + iReturn.ToString());
            }


            // Clean up after ourselves
            if (!Utilities.GetBoolConfigValue("WriteReportToDisk", false))
            {
                if ((attachments != null) &&
                    (attachments.Count > 0))
                {
                    foreach (EmailAttachment attachment in attachments)
                    {
                        File.Delete(string.Concat(Utilities.GetConfigValue("ReportPath"), attachment.Name));
                    }
                }
            }
        }


        /// <summary>
        /// Helper method that retrieves the template from disk.
        /// </summary>
        /// <param name="szTemplateName"></param>
        /// <returns></returns>
        virtual protected string GetEmailTemplate(string szTemplateName)
        {
            if (_htEmailTemplates == null)
                _htEmailTemplates = new Dictionary<string, string>();

            if (!_htEmailTemplates.ContainsKey(szTemplateName))
            {
                using (StreamReader srTemplate = new StreamReader(Utilities.GetConfigValue("TemplateFolder") + szTemplateName))
                {
                    _htEmailTemplates.Add(szTemplateName, srTemplate.ReadToEnd());
                }
            }

            return _htEmailTemplates[szTemplateName];
        }

        /// <summary>
        /// Helper method that adds the contents of the list to the buffer with
        /// the specified label.
        /// </summary>
        /// <param name="sbMsg"></param>
        /// <param name="lMessages"></param>
        /// <param name="szLabel"></param>
        virtual protected void AddListToBuffer(StringBuilder sbMsg, List<string> lMessages, string szLabel)
        {
            if ((lMessages != null) &&
                (lMessages.Count > 0))
            {
                sbMsg.Append("\n\n" + lMessages.Count.ToString() + " " + szLabel + "\n");
                sbMsg.Append("=======\n");

                foreach (string szMsg in lMessages)
                {
                    sbMsg.Append(szMsg);
                }
            }
        }

        /// <summary>
        /// Go get our custom caption date/time value.
        /// </summary>
        /// <param name="oConn"></param>
        /// <param name="szFamilyName"></param>
        /// <returns></returns>
        virtual protected DateTime GetDateTimeCustomCaption(SqlConnection oConn, string szFamilyName)
        {
            return GetDateTimeCustomCaption(oConn, szFamilyName, DateTime.Now);
        }

        virtual protected DateTime GetDateTimeCustomCaption(SqlConnection oConn, string szFamilyName, DateTime defaultValue)
        {
            SqlCommand oDBCommand = new SqlCommand(SQL_SELECT_CUSTOM_CAPTION, oConn);
            oDBCommand.Parameters.AddWithValue("@capt_family", szFamilyName);

            object oValue = oDBCommand.ExecuteScalar();

            // If we don't have a value, return
            // the current datetime because this means a 
            // new install and the way the data migration works
            // all records have the same created date.
            if ((oValue == DBNull.Value) ||
                (string.IsNullOrEmpty((string)oValue)))
                return defaultValue;

            return DateTime.Parse((string)oValue);
        }
        
        /// <summary>
        /// Go get a custom caption bool value.
        /// </summary>
        /// <param name="oConn"></param>
        /// <param name="szFamilyName"></param>
        /// <returns></returns>
        virtual protected bool GetBoolCustomCaption(SqlConnection oConn, string szFamilyName)
        {
            SqlCommand oDBCommand = new SqlCommand(SQL_SELECT_CUSTOM_CAPTION_US, oConn);
            oDBCommand.Parameters.AddWithValue("@capt_family", szFamilyName);

            object oValue = oDBCommand.ExecuteScalar();

            // If we don't have a value, return false
            if ((oValue == DBNull.Value) ||
                (string.IsNullOrEmpty((string)oValue)))
                return false;

            return bool.Parse((string)oValue);
        }

        /// <summary>
        /// Update our custom caption value appropriately
        /// </summary>
        /// <param name="oConn"></param>
        /// <param name="szFamilyName"></param>
        /// <param name="dtValue"></param>
        virtual protected void UpdateDateTimeCustomCaption(SqlConnection oConn, string szFamilyName, DateTime dtValue)
        {
            SqlCommand oDBCommand = new SqlCommand(SQL_UPDATE_CUSTOM_CAPTION, oConn);
            oDBCommand.Parameters.AddWithValue("@capt_family", szFamilyName);
            oDBCommand.Parameters.AddWithValue("@capt_code", dtValue);

            object oValue = oDBCommand.ExecuteNonQuery();
        }

        /// <summary>
        /// Helper method to retreive the DB connection information.
        /// It first looks in the config file and then in the registry.
        /// </summary>
        /// <returns></returns>
        virtual protected string GetConnectionString()
        {

            string szConnection = ConfigurationManager.ConnectionStrings["TSIUtils"].ConnectionString;
            if (!string.IsNullOrEmpty(szConnection))
            {
                return szConnection;
            }

            szConnection = Utilities.GetConfigValue("DBConnectionString");
            if (!string.IsNullOrEmpty(szConnection))
            {
                return szConnection;
            }

            string szUserID = null;
            string szPassword = null;
            string szServer = null;
            string szDatabase = null;

            RegistryKey regCRM = Registry.LocalMachine;
            regCRM = regCRM.OpenSubKey(@"SOFTWARE\eware\Config");

            szUserID = (string)regCRM.GetValue("BBSDatabaseUserID");
            szPassword = (string)regCRM.GetValue("BBSDatabasePassword");
            regCRM.Close();

            RegistryKey regCRM2 = Registry.LocalMachine;
            regCRM2 = regCRM2.OpenSubKey(@"SOFTWARE\eware\Config\/CRM");

            szDatabase = (string)regCRM2.GetValue("DefaultDatabase");
            szServer = (string)regCRM2.GetValue("DefaultDatabaseServer");
            regCRM2.Close();

            string[] aArgs = { szServer, szUserID, szPassword, szDatabase };

            return Utilities.GetConfigValue("DBConnectionString", string.Format(CONN_STRING, aArgs));
        }

        /// <summary>
        /// Helper method to determine if the specified value
        /// is empty or null
        /// </summary>
        /// <param name="oValue"></param>
        /// <returns></returns>
        virtual protected bool IsNullOrEmpty(object oValue)
        {

            if (oValue == DBNull.Value)
                return true;

            if (oValue == null)
                return true;

            return string.IsNullOrEmpty(Convert.ToString(oValue));
        }

        virtual protected DateTime GetDateTimeConfigValue(string szValueName, DateTime dtDefaultValue)
        {
            return Convert.ToDateTime(Utilities.GetConfigValue(szValueName, dtDefaultValue.ToString()));
        }

        protected byte[] GetTestReport()
        {
            string szPath = Utilities.GetConfigValue("TemplateFolder") + "NoReport.pdf";
            FileInfo fInfo = new FileInfo(szPath);
            long lByteCount = fInfo.Length;

            FileStream fs = File.OpenRead(szPath);
            BinaryReader oBR = new BinaryReader(fs);
            byte[] bTestFile = oBR.ReadBytes((int)lByteCount);

            return bTestFile;
        }



        /// <summary>
        /// Returns an ID from the CRM usp_getNextId stored procedure
        /// for the specified table.
        /// </summary>
        /// <param name="oConn"></param>
        /// <param name="szTableName"></param>
        /// <param name="oTran"></param>
        /// <returns></returns>
        public int GetRecordID(SqlConnection oConn, string szTableName, SqlTransaction oTran)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("TableName", szTableName));


            SqlCommand oSQLCommand = new SqlCommand("usp_getNextId", oConn);
            oSQLCommand.Transaction = oTran;
            oSQLCommand.CommandType = CommandType.StoredProcedure;

            oSQLCommand.Parameters.AddWithValue("TableName", szTableName);

            SqlParameter returnParameter = new SqlParameter();
            returnParameter.ParameterName = "Return";
            returnParameter.DbType = DbType.Int32;
            returnParameter.Direction = ParameterDirection.Output;
            oSQLCommand.Parameters.Add(returnParameter);

            oSQLCommand.ExecuteNonQuery();

            return Convert.ToInt32(returnParameter.Value);
        }

        private const string INSERT_COMMUNICATION =
        @"INSERT INTO Communication
            (Comm_CommunicationId, Comm_CreatedBy, Comm_UpdatedBy, Comm_CreatedDate, Comm_UpdatedDate, Comm_TimeStamp,
             Comm_Type, Comm_Action, Comm_Status, Comm_DateTime,
             Comm_Note, Comm_PRCategory, Comm_PRSubcategory, Comm_Subject)
         VALUES
            (@CommunicationId, @CreatorUserId, @CreatorUserId, @Now, @Now, @Now,
             @Type, @Action, @Status, @DateTime,
             @Note, @PRCategory, @PRSubcategory, @Subject)";

        private const string INSERT_COMM_LINK =
        @"INSERT INTO Comm_Link
               (CmLi_CommLinkId, CmLi_CreatedBy, CmLi_UpdatedBy, CmLi_CreatedDate, CmLi_UpdatedDate, CmLi_TimeStamp
               , CmLi_Comm_UserId, CmLi_Comm_CommunicationId, CmLi_Comm_CompanyId)
         VALUES
               (@CmLi_CommLinkId, @CreatorUserId, @CreatorUserId, @Now, @Now, @Now
               , @CreatorUserId, @CommunicationId, @RelatedCompanyId)";

        // Overload this method as necessary
        protected void CreateInteraction(SqlConnection oConn, int companyID, string action, DateTime dateTime,
                                      string subject, string Note, string category, string subCategory,
                                      SqlTransaction oTran)
        {
            long communicationID = GetRecordID(oConn, "Communication", oTran);

            SqlCommand cmdCommunication = new SqlCommand(INSERT_COMMUNICATION, oConn, oTran);
            cmdCommunication.Parameters.AddWithValue("CommunicationId", communicationID);
            cmdCommunication.Parameters.AddWithValue("CreatorUserId", -1);
            cmdCommunication.Parameters.AddWithValue("Now", DateTime.Now);
            cmdCommunication.Parameters.AddWithValue("Type", "Note");
            cmdCommunication.Parameters.AddWithValue("Action", action);
            cmdCommunication.Parameters.AddWithValue("Status", "Complete");
            cmdCommunication.Parameters.AddWithValue("DateTime", dateTime);
            cmdCommunication.Parameters.AddWithValue("Subject", subject);
            cmdCommunication.Parameters.AddWithValue("Note", Note);
            cmdCommunication.Parameters.AddWithValue("PRCategory", category);
            cmdCommunication.Parameters.AddWithValue("PRSubcategory", subCategory);
            cmdCommunication.ExecuteNonQuery();

            long comm_LinkID = GetRecordID(oConn, "Comm_Link", oTran);

            SqlCommand cmdCommLink = new SqlCommand(INSERT_COMM_LINK, oConn, oTran);
            cmdCommLink.Parameters.AddWithValue("CmLi_CommLinkId", comm_LinkID);
            cmdCommLink.Parameters.AddWithValue("CommunicationId", communicationID);
            cmdCommLink.Parameters.AddWithValue("CreatorUserId", -1);
            cmdCommLink.Parameters.AddWithValue("Now", DateTime.Now);
            cmdCommLink.Parameters.AddWithValue("RelatedCompanyId", companyID);
            cmdCommLink.ExecuteNonQuery();
        }

        protected const string SQL_PRTTRANSACTION_INSERT =
            @"INSERT INTO PRTransaction (prtx_TransactionId, prtx_CompanyId, prtx_PersonId, prtx_EffectiveDate, prtx_AuthorizedInfo, prtx_Explanation, prtx_Status, prtx_CreatedBy, prtx_CreatedDate, prtx_UpdatedBy, prtx_UpdatedDate, prtx_TimeStamp)
               VALUES ({0}, {1}, {2}, '{3}', '{4}', '{5}', '{6}', -1, GETDATE(), -1, GETDATE(), GETDATE())";

        /// <summary>
        /// Creates a new open PRTransaction
        /// </summary>
        /// <param name="oConn"></param>
        /// <param name="iCompanyID"></param>
        /// <param name="iPersonID"></param>
        /// <param name="szAuthorizationInfo"></param>
        /// <param name="szExplanation"></param>
        /// <param name="oTran"></param>
        /// <returns></returns>
        public int CreatePIKSTransaction(SqlConnection oConn,
                                         int iCompanyID,
                                         int iPersonID,
                                         string szAuthorizationInfo,
                                         string szExplanation,
                                         SqlTransaction oTran)
        {

            int iTransactionID = GetRecordID(oConn, "PRTransaction", oTran);

            string companyID = "null";
            if (iCompanyID != 0)
                companyID = iCompanyID.ToString();

            string personID = "null";
            if (iPersonID != 0)
                personID = iPersonID.ToString();

            string[] args = {iTransactionID.ToString(),
                             companyID,
                             personID,
                             DateTime.Now.ToString(),
                             szAuthorizationInfo,
                             szExplanation,
                             "O"};

            string szSQL = string.Format(SQL_PRTTRANSACTION_INSERT, args);
            SqlCommand oSQLCommand = new SqlCommand(szSQL, oConn, oTran);
            oSQLCommand.ExecuteNonQuery();

            return iTransactionID;
        }


        protected const string SQL_PRTRANSACTION_CLOSE =
            @"UPDATE PRTransaction 
                 SET prtx_Status='C', 
                     prtx_CloseDate=GETDATE(), 
                     prtx_UpdatedBy=-1, 
                     prtx_UpdatedDate=GETDATE(), 
                     prtx_Timestamp=GETDATE() 
               WHERE prtx_TransactionId={0}";
        /// <summary>
        /// Updates the specified PRTransaction setting the appropriate
        /// values to close it.
        /// </summary>
        /// <param name="oConn"></param>
        /// <param name="iTransactionID"></param>
        /// <param name="oTran"></param>
        public void ClosePIKSTransaction(SqlConnection oConn,
                                         int iTransactionID,
                                         SqlTransaction oTran)
        {
            string szSQL = string.Format(SQL_PRTRANSACTION_CLOSE, iTransactionID);
            SqlCommand oSQLCommand = new SqlCommand(szSQL, oConn, oTran);
            oSQLCommand.ExecuteNonQuery();
        }

        protected string GetString(object value)
        {
            if (value == DBNull.Value)
                return null;

            return Convert.ToString(value).Trim();
        }

        protected int GetInt(object value)
        {
            if (value == DBNull.Value)
                return 0;

            return Convert.ToInt32(value);
        }

        protected string GetPercentValue(object value)
        {
            if (value == DBNull.Value)
                return String.Empty;

            decimal dValue = Convert.ToDecimal(value);
            if (dValue == 0)
                return String.Empty;

            return dValue.ToString("0.00") + "%";
        }

        protected void WriteFile(StringBuilder sbData, string outputFolder, string fileName)
        {
            if (sbData.Length > 0)
            {
                using (System.IO.StreamWriter file = new System.IO.StreamWriter(Path.Combine(outputFolder, fileName)))
                {
                    file.Write(sbData.ToString());
                }
            }
        }

        protected void ExecuteMASImport(SqlConnection sqlConn, string outputFolder, string dataFile, string VIJobName, string MASJobName)
        {
            if (!File.Exists(Path.Combine(outputFolder, dataFile)))
                return;

            DateTime startTime = DateTime.Now;

            string msg = "Executing VI Job " + MASJobName + " (" + VIJobName + ") for file " + Path.Combine(outputFolder, dataFile);
            _oLogger.LogMessage(msg);

            try
            {
                DateTime startDate = DateTime.Now;
                int executionCount = GetVIJobExecutionCount(sqlConn, startDate, MASJobName);

                System.Diagnostics.Process process = new System.Diagnostics.Process();
                process.StartInfo.FileName = Utilities.GetConfigValue("MASVIBatchJob");
                process.StartInfo.Arguments = VIJobName;
                process.StartInfo.CreateNoWindow = true;
                process.StartInfo.RedirectStandardError = true;
                process.StartInfo.RedirectStandardOutput = true;
                process.StartInfo.UseShellExecute = false;
                process.StartInfo.WindowStyle = System.Diagnostics.ProcessWindowStyle.Hidden;
                process.StartInfo.ErrorDialog = false;
                process.EnableRaisingEvents = true;

                process.Start();

                int currentCount = executionCount;
                //int saveMinutes = 0;
                while (currentCount == executionCount)
                {
                    int totalMinutes = Convert.ToInt32(DateTime.Now.Subtract(startDate).TotalMinutes);

                    // Let's only log the long waiting jobs once
                    // every minute
                    //if (totalMinutes != saveMinutes) {
                    //    _oLogger.LogMessage("Waiting for VI Job " + MASJobName + " (" + VIJobName + ") to finish: " + totalMinutes.ToString("00"));
                    //    saveMinutes = totalMinutes;
                    //}


                    if (totalMinutes > Utilities.GetIntConfigValue("MASVIExecutionWaitTimeout", 60))
                    {
                        _oLogger.LogMessage("Timeout waiting for VI Job " + MASJobName + " (" + VIJobName + ") to finish.");
                        break;
                    }

                    System.Threading.Thread.Sleep(Utilities.GetIntConfigValue("MASVIExecutionWait", 1000));
                    currentCount = GetVIJobExecutionCount(sqlConn, startDate, MASJobName);
                }

                // The exit code check is occassionaly throwing an error, but we haven't seen
                // a non-zero return code ever, so we are just removing the check.
                //if (process.ExitCode != 0) {
                //    _oLogger.LogError(new Exception(process.StartInfo.Arguments + " exited with a non-zero return code: " + process.ExitCode.ToString()));
                //}
            }
            catch (Exception eX)
            {
                throw new ApplicationException("Exception: " + msg, eX);
            }
            finally
            {
                _oLogger.LogMessage("Finished Executing VI Job " + MASJobName + " (" + VIJobName + ") for file " + Path.Combine(outputFolder, dataFile));
            }
        }

        private const string SQL_VI_RESULTS =
            @"SELECT LogDescription
                FROM MAS_SYSTEM.dbo.SY_ActivityLog 
               WHERE logdate = @Today
                 AND CompanyCode = @Company
                 AND UserLogon = @UserLogon
                 AND ModuleCode = 'V/I'
                 AND LogTime >= @LogTime
                 AND LogDescription LIKE @VIJobName";


        private const string SQL_VI_ERRORS =
            @"SELECT LogDescription
                FROM MAS_SYSTEM.dbo.SY_ActivityLog 
               WHERE logdate = @Today
                 AND CompanyCode = @Company
                 AND UserLogon = @UserLogon
                 AND ModuleCode = 'V/I'
                 AND LogType = 'E'
                 AND LogTime >= @LogTime
                 AND LogDescription LIKE @VIJobName";

        protected bool GetMASImportResults(SqlConnection sqlConn, DateTime startDate, string MASJobName, StringBuilder sbResults)
        {
            int recordsRead = 0;
            int recordsImported = 0;
            int recordsSkipped = 0;
            int recordsInvalid = 0;

            DateTime dateOnly = new DateTime(startDate.Year, startDate.Month, startDate.Day);

            SqlCommand sqlCommand = new SqlCommand(SQL_VI_RESULTS, sqlConn);
            sqlCommand.Parameters.AddWithValue("Today", dateOnly);
            sqlCommand.Parameters.AddWithValue("Company", Utilities.GetConfigValue("MASCompany", "PRC"));
            sqlCommand.Parameters.AddWithValue("UserLogon", Utilities.GetConfigValue("MASUserLogon", "CRMDataImport"));
            sqlCommand.Parameters.AddWithValue("LogTime", (startDate - dateOnly).TotalHours);
            sqlCommand.Parameters.AddWithValue("VIJobName", $"VI Job {MASJobName}%");

            using (SqlDataReader reader = sqlCommand.ExecuteReader())
            {
                if (reader.Read())
                {
                    if (sbResults.Length > 0)
                        sbResults.Append(Environment.NewLine);

                    sbResults.Append(reader.GetString(0));

                    string buffer = reader.GetString(0);
                    GetActivityLogValue(buffer, "records read: ", ref recordsRead);
                    GetActivityLogValue(buffer, "records imported: ", ref recordsImported);
                    GetActivityLogValue(buffer, "records skipped: ", ref recordsSkipped);
                    GetActivityLogValue(buffer, "records invalid: ", ref recordsInvalid);
                }

                if (sbResults.Length > 0)
                    sbResults.Append(Environment.NewLine);
            }

            bool foundError = false;
            sqlCommand = new SqlCommand(SQL_VI_ERRORS, sqlConn);
            sqlCommand.Parameters.AddWithValue("Today", dateOnly);
            sqlCommand.Parameters.AddWithValue("Company", Utilities.GetConfigValue("MASCompany", "PRC"));
            sqlCommand.Parameters.AddWithValue("UserLogon", Utilities.GetConfigValue("MASUserLogon", "CRMDataImport"));
            sqlCommand.Parameters.AddWithValue("LogTime", (startDate - dateOnly).TotalHours);
            sqlCommand.Parameters.AddWithValue("VIJobName", "%" + MASJobName + "%");
            using (SqlDataReader reader = sqlCommand.ExecuteReader())
            {
                while (reader.Read())
                {
                    foundError = true;
                    if (sbResults.Length > 0)
                        sbResults.Append(Environment.NewLine);

                    sbResults.Append("ERROR: " + reader.GetString(0));
                }
            }


            if ((recordsInvalid > 0) ||
                (recordsSkipped > 0) ||
                foundError)
            {
                return false;
            }

            return true;
        }

        private bool GetActivityLogValue(string buffer, string label, ref int count)
        {
            if (buffer.IndexOf(label) > -1)
            {
                char lineTerminator = Convert.ToChar(10);
                int lineTerminatorIndex = buffer.IndexOf(lineTerminator);

                int start = buffer.IndexOf(label) + label.Length;
                int length = lineTerminatorIndex - start;

                count = Int32.Parse(buffer.Substring(start, length));
                return true;
            }

            return false;
        }


        private const string SQL_VI_EXECUTION_COUNT =
            @"SELECT COUNT(1)
                FROM MAS_SYSTEM.dbo.SY_ActivityLog 
               WHERE logdate = @Today
                 AND CompanyCode = @Company
                 AND UserLogon = @UserLogon
                 AND ModuleCode = 'V/I'
                 AND LogDescription LIKE @VIJobName";

        protected int GetVIJobExecutionCount(SqlConnection sqlConn, DateTime startDate, string MASJobName)
        {
            DateTime dateOnly = new DateTime(startDate.Year, startDate.Month, startDate.Day);

            SqlCommand sqlCommand = new SqlCommand(SQL_VI_EXECUTION_COUNT, sqlConn);
            sqlCommand.Parameters.AddWithValue("Today", dateOnly);
            sqlCommand.Parameters.AddWithValue("Company", Utilities.GetConfigValue("MASCompany", "PRC"));
            sqlCommand.Parameters.AddWithValue("UserLogon", Utilities.GetConfigValue("MASUserLogon", "CRMDataImport"));
            sqlCommand.Parameters.AddWithValue("VIJobName", $"VI Job {MASJobName}%Records imported:%");

            object oResult = sqlCommand.ExecuteScalar();
            if ((oResult == DBNull.Value) ||
                (oResult == null))
                return 0;

            return Convert.ToInt32(oResult);
        }

        protected void ArchiveFile(string outputFolder, string dataFile, string archiveFolder, DateTime startDate)
        {
            if (!File.Exists(Path.Combine(outputFolder, dataFile)))
                return;

            if (!Directory.Exists(archiveFolder))
                Directory.CreateDirectory(archiveFolder);

            string archiveFileName = startDate.ToString("yyyy-MM-dd HH-mm-ss") + "_" + dataFile;
            _oLogger.LogMessage("Archiving file: " + Path.Combine(outputFolder, dataFile) + " to " + Path.Combine(archiveFolder, archiveFileName));

            // VI could still be executing and holding onto these files
            int count = 0;
            while (true)
            {
                try
                {
                    count++;
                    File.Move(Path.Combine(outputFolder, dataFile), Path.Combine(archiveFolder, archiveFileName));
                    break;
                }
                catch (IOException eX)
                {
                    if (count > Utilities.GetIntConfigValue("ArchiveFileSleepThreshold", 240))
                        throw new Exception("Error archiving file: " + dataFile, eX);

                    System.Threading.Thread.Sleep(1000 * 30);  //60 seconds
                }
            }
        }

        virtual protected string GetFormattedEmail(SqlConnection oConn, SqlTransaction oTran, int companyID, int personID, string subject, string Text)
        {
            return GetFormattedEmail(oConn, oTran, companyID, personID, subject, Text, "en-us");
        }

        virtual protected string GetFormattedEmail(SqlConnection oConn, SqlTransaction oTran, int companyID, int personID, string subject, string Text, string szEmailImageHTML_TOP, string szEmailImageHTML_BOTTOM)
        {
            return GetFormattedEmail(oConn, oTran, companyID, personID, subject, Text, "en-us", szEmailImageHTML_TOP, szEmailImageHTML_BOTTOM);
        }


        private const string SQL_GET_FORMATTED_EMAIL = "SELECT dbo.ufn_GetFormattedEmail4(@CompanyID, @PersonID, 0, @Subject, @Text, NULL, @Culture, @TopImage, @BottomImage)";
        virtual protected string GetFormattedEmail(SqlConnection oConn, SqlTransaction oTran, int companyID, int personID, string subject, string Text, string culture, string szEmailImageHTML_TOP=null, string szEmailImageHTML_BOTTOM=null)
        {
            SqlCommand oDBCommand = new SqlCommand(SQL_GET_FORMATTED_EMAIL, oConn, oTran);
            oDBCommand.Parameters.AddWithValue("CompanyID", companyID);
            oDBCommand.Parameters.AddWithValue("PersonID", personID);
            oDBCommand.Parameters.AddWithValue("Subject", subject);
            oDBCommand.Parameters.AddWithValue("Text", Text);
            oDBCommand.Parameters.AddWithValue("Culture", culture);
            AddSqlParameter(oDBCommand, "TopImage", szEmailImageHTML_TOP);
            AddSqlParameter(oDBCommand, "BottomImage", szEmailImageHTML_BOTTOM);

            object oValue = oDBCommand.ExecuteScalar();
            string szValue = (string)oValue;

            return szValue;
        }

        protected void AddSqlParameter(SqlCommand command, string name, string value)
        {
            if (string.IsNullOrEmpty(value))
                command.Parameters.AddWithValue(name, DBNull.Value);
            else
                command.Parameters.AddWithValue(name, value);
        }

        protected bool IsBusinessHours()
        {
            int businessHourStart = Utilities.GetIntConfigValue("BusinessHoursStart", 6);
            int businessHourEnd = Utilities.GetIntConfigValue("BusinessHourEnd", 18);

            int currentHour = DateTime.Now.Hour;
            if ((currentHour < businessHourStart) ||
                (currentHour > businessHourEnd))
                return false;

            return true;
        }

        protected bool IsBusinessHours(string configValueName)
        {

            if (Utilities.GetBoolConfigValue(configValueName, true))
                return IsBusinessHours();

            return false;
        }

        protected void UploadFile(string ftpURL,
                                  string username,
                                  string password,
                                  string fileName)
        {
            UploadFile(ftpURL,
                       username,
                       password,
                       fileName,
                       Utilities.GetBoolConfigValue("FTPUploadUsePassive", false),
                       Utilities.GetBoolConfigValue("FTPUploadUseBinary", true),
                       Utilities.GetBoolConfigValue("FTPUploadKeepAlive", false));
        }

        protected void UploadFile(string ftpURL,
                                  string username,
                                  string password,
                                  string fileName,
                                  bool usePassive,
                                  bool useBinary,
                                  bool keepAlive)
        {
            FtpWebRequest request = (FtpWebRequest)FtpWebRequest.Create(ftpURL + "/" + Path.GetFileName(fileName));
            request.Method = WebRequestMethods.Ftp.UploadFile;
            request.Credentials = new NetworkCredential(username, password);
            request.UsePassive = usePassive;
            request.UseBinary = useBinary;
            request.KeepAlive = keepAlive;

            // Read our file into memory
            using (FileStream stream = File.OpenRead(fileName))
            {
                using (Stream reqStream = request.GetRequestStream())
                {
                    stream.CopyTo(reqStream);
                    reqStream.Close();
                }
            }
        }


        protected void UploadFileSFTP(string ftpURL,
                                      int port,
                                      string username,
                                      string password,
                                      string localFileName,
                                      string remoteFileName)
        {
            var connectionInfo = new PasswordConnectionInfo(ftpURL, port, username, password); ;

            using (SftpClient client = new SftpClient(connectionInfo))
            {
                client.ConnectionInfo.Timeout = TimeSpan.FromSeconds(Utilities.GetIntConfigValue("SFTPTimeoutSeconds", 120));
                client.Connect();

                using (FileStream filestream = new FileStream(localFileName, FileMode.Open))
                {
                    client.BufferSize = 4 * 1024; // bypass Payload error large files
                    client.UploadFile(filestream, remoteFileName);
                }
            }

        }

        #region PREmailImages
        /* 
         * These GetEmailImnages() methods are also used in CRMBase.cs.
         * When changing anything here, also change it there, and vice versa.
         */ 
        const string SQL_GET_EMAIL_IMAGE = @"SELECT 
                                                prei_EmailImgDiskFileName,
                                                dbo.ufn_GetCustomCaptionValue('BBOS', 'URL', 'en-us') as BBOSURL,
	                                            capt_US AS [EmailType],
	                                            prei_EmailImageID,
	                                            prei_Industry,
	                                            prei_Hyperlink
                                            FROM PREmailImages
		                                        INNER JOIN Custom_Captions ON Capt_Family='prei_EmailTypeCode' AND Capt_Code=prei_EmailTypeCode
                                            WHERE
	                                            prei_EmailTypeCode = @EmailTypeCode
	                                            AND prei_LocationCode = @LocationCode
	                                            AND @SpecifiedDate >= prei_StartDate
                                                AND @SpecifiedDate <= prei_EndDate 
                                                AND prei_Deleted IS NULL
                                                {0}";
        protected string GetEmailImage(SqlConnection oConn, string szEmailTypeCode, string szIndustryCode, DateTime dtSpecifiedDate)
        {
            return GetEmailImage(oConn, szEmailTypeCode, "T", szIndustryCode, dtSpecifiedDate);
        }

        protected string GetEmailImage(SqlConnection oConn, string szEmailTypeCode, string szIndustryCode)
        {
            return GetEmailImage(oConn, szEmailTypeCode, "T", szIndustryCode, new DateTime(DateTime.Now.Year, DateTime.Now.Month, DateTime.Now.Day));
        }

        protected string GetEmailImage(SqlConnection oConn, string szEmailTypeCode, string szLocationCode, string szIndustryCode)
        {
            return GetEmailImage(oConn, szEmailTypeCode, szLocationCode, szIndustryCode, new DateTime(DateTime.Now.Year, DateTime.Now.Month, DateTime.Now.Day));
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="oConn"></param>
        /// <param name="szEmailTypeCode"></param>
        /// <param name="szLocationCode"></param>
        /// <param name="szIndustryCode">P, T, S, or L single char -- if blank then treat like PTS</param>
        /// <param name="dtSpecifiedDate"></param>
        /// <returns></returns>
        protected string GetEmailImage(SqlConnection oConn, string szEmailTypeCode, string szLocationCode, string szIndustryCode, DateTime dtSpecifiedDate)
        {
            StringBuilder sb = new StringBuilder();

            string szParm1 = "";

            switch (szIndustryCode)
            {
                case "L":
                    szParm1 = " AND prei_Industry IN ('B', 'L') ";
                    break;
                default:
                    //Default assumed for P, T, S, or blank szIndustryCode
                    szParm1 = " AND prei_Industry IN ('B', 'PTS') ";
                    break;
            }

            SqlCommand oSQLCommand = new SqlCommand(string.Format(SQL_GET_EMAIL_IMAGE, szParm1), oConn);
            oSQLCommand.CommandType = CommandType.Text;

            oSQLCommand.Parameters.AddWithValue("@SpecifiedDate", dtSpecifiedDate);
            oSQLCommand.Parameters.AddWithValue("@EmailTypeCode", szEmailTypeCode);
            oSQLCommand.Parameters.AddWithValue("@LocationCode", szLocationCode);

            bool bImageHeaderRendered = false;
            bool bImageFooterRendered = false;

            using (SqlDataReader oReader = oSQLCommand.ExecuteReader(CommandBehavior.Default))
            {
                while (oReader.Read())
                {
                    if (!bImageHeaderRendered)
                    {
                        sb.Append("<div style='text-align:center'>");
                        bImageHeaderRendered = true;
                    }

                    string prei_EmailImgDiskFileName = (string)oReader["prei_EmailImgDiskFileName"];
                    string BBOSURL = (string)oReader["BBOSURL"];
                    string EmailType = (string)oReader["EmailType"];
                    int prei_EmailImageID = (int)oReader["prei_EmailImageID"];


                    string prei_Hyperlink = "";
                    if (oReader["prei_Hyperlink"] != System.DBNull.Value)
                        prei_Hyperlink = (string)oReader["prei_Hyperlink"];

                    bool bHasHyperlink = (!string.IsNullOrEmpty(prei_Hyperlink));

                    if (!string.IsNullOrEmpty(prei_EmailImgDiskFileName))
                    {
                        //Ex: https://azqa.apps.bluebookservices.com/bbos/Campaigns/Alerts/6000/Top.jpg
                        if (bHasHyperlink)
                            sb.Append($"<a href='{prei_Hyperlink}'>");

                        sb.Append($"<img src='{BBOSURL}Campaigns/{EmailType}/{prei_EmailImageID}/{prei_EmailImgDiskFileName}' />");

                        if (bHasHyperlink)
                            sb.Append($"</a>");

                        sb.Append($"<br>");
                    }
                }

                if (bImageHeaderRendered && !bImageFooterRendered)
                {
                    sb.Append("</div>");
                    bImageHeaderRendered = true;
                }
            }

            return sb.ToString();
        }
        #endregion

        private const string SQL_EMAIL_AD =
            @"SELECT pradc_AdCampaignID,
                       pradc_TargetURL,
	                   pracf_FileName_Disk
                  FROM vPRAdCampaignImage
                 WHERE pradc_AdCampaignTypeDigital = @DigitalAdTypeCode
                   AND pracf_FileTypeCode = @FileTypeCode
                   AND pradc_IndustryType LIKE @IndustryType
                   AND pradc_CreativeStatus='A'
                   AND GETDATE() BETWEEN pradc_StartDate AND pradc_EndDate";

        protected string GetAdvertisingLink(SqlConnection sqlConn, string industryType, string BBOSURL, string digitalAdTypeCode, string fileTypeCode)
        {
            string adLink = string.Empty;
            string adClickURL = Utilities.GetConfigValue("AdClickURL", $"{BBOSURL}AdClick.aspx");

            SqlCommand sqlCommand = new SqlCommand(SQL_EMAIL_AD, sqlConn);
            sqlCommand.Parameters.AddWithValue("DigitalAdTypeCode", digitalAdTypeCode);
            sqlCommand.Parameters.AddWithValue("FileTypeCode", fileTypeCode);
            sqlCommand.Parameters.AddWithValue("IndustryType", $"%,{industryType},%");

            using (SqlDataReader reader = sqlCommand.ExecuteReader())
            {
                if (reader.Read())
                    adLink = $"<a href=\"{adClickURL}?AdCampaignID={reader.GetInt32(0)}&AdAuditTrailID=0\"><img src=\"{BBOSURL}{Utilities.GetConfigValue("AdImageRootURL", "Campaigns/")}{reader.GetString(2)}\" border=\"0\"></a>";
            }

            return adLink;
        }
    }

    public class EmailAttachment {

        public string Name;
        public byte[] File;


        public EmailAttachment(string name, byte[] file)
        {
            Name = name;
            File = file;
        }
    }
}
