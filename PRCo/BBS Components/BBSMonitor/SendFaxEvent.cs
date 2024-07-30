/***********************************************************************
 Copyright Produce Reporter Company 2006-2016

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: SendFax.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Timers;
using Microsoft.Win32.SafeHandles;
using PRCo.BBOS.FaxInterface;
using TSI.Utils;

namespace PRCo.BBS.BBSMonitor {

    /// <summary>
    /// Provides the functionality to send faxes from BBS via
    /// RightFax.
    /// </summary>
    public class SendFaxEvent : BBSMonitorEvent {

        /// <summary>
        /// Our declaration to make a call into Kernal32 to open a printer as
        /// a file.  Cannot do this natively in .NET.
        /// </summary>
        [DllImport("Kernel32.dll", SetLastError = true, CharSet = CharSet.Auto)]
        static extern SafeFileHandle CreateFile(
            string fileName,
            [MarshalAs(UnmanagedType.U4)] FileAccess fileAccess,
            [MarshalAs(UnmanagedType.U4)] FileShare fileShare,
            IntPtr securityAttributes,
            [MarshalAs(UnmanagedType.U4)] FileMode creationDisposition,
            int flags,
            IntPtr template);


        private const string SQL_SELECT_FAX_QUEUE =
                @"SELECT ID, Who, Attachment, FaxNumber, PersonName, Priority, IsLibraryDocument, ScheduledDateTime, RightFaxEmbeddedCodes, CommunicationLogID, user_FaxUserID, user_FaxPassword, User_EmailAddress
                      FROM PRFaxQueue
                           LEFT OUTER JOIN users ON Who = user_logon
                    ORDER BY CreatedDate";
        private const string SQL_DELETE_FAX_QUEUE = "DELETE FROM PRFaxQueue WHERE ID=@ID;";

        private const string FAX_TEXT = @"<TOFAXNUM:{0}><WHO:{1}><TONAME:{2}><NOCOVER>{3}";
        private const string FAX_COMMAND_ATTACHMENT = "<ADDDOC:{0}>";
        private const string FAX_COMMAND_LIB_DOC = "<LIBDOC:{0}>";
        private const string FAX_COMMAND_PRIORITY = "<PRIORITY:{0}>";
        private const string FAX_COMMAND_SEND_DATE = "<SENDAT:{0}>";
        private const string FAX_COMMAND_PREVIEW = "<PREVIEW>";
        private const string FAX_COMMAND_UNIQUEID = "<UNIQUEID:{0}>";

        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex) {
            _szName = "SendFax";

            base.Initialize(iIndex);

            try {
                //
                // Configure our Send Fax event
                //
                // Defaults to 5 minutes.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("SendFaxInterval", 5)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("SendFax Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("SendFaxStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

                _oLogger.LogMessage("SendFax Start: " + _dtNextDateTime.ToString());

            } catch (Exception e) {
                LogEventError("Error initializing SendFax event.", e);
                throw;
            }
        }


        override public void ProcessEvent()
        {
            if (Utilities.GetBoolConfigValue("ConcordFaxEnabled", true))
            {
                ProcessConcord();
            }
            else
            {
                ProcessRightFax();
            }

        }


        protected void ProcessConcord()
        {
            DateTime dtExecutionStartDate = DateTime.Now;

            List<ReportUser> lReportUser = new List<ReportUser>();
            SqlConnection oConn = new SqlConnection(GetConnectionString());
            int iFaxCount = 0;

            string szTemplateFolder = Utilities.GetConfigValue("TemplateFolder");
            string szAttachmentFolder = Utilities.GetConfigValue("SendFaxAttachmentFolder", @"\\sql01\tempreports\");
            string szAttachmentFile = null;
            

            FaxResult faxResult = null;

            try
            {
                oConn.Open();

                lReportUser = GetFaxInfo(oConn);

                foreach (ReportUser oReportUser in lReportUser)
                {
                    iFaxCount++;

                    if (oReportUser.IsLibraryDoc)
                    {
                        szAttachmentFile = Path.Combine(szTemplateFolder, oReportUser.Attachment + ".pdf");
                    }
                    else
                    {
                        szAttachmentFile = Path.Combine(szAttachmentFolder, Path.GetFileName(oReportUser.Attachment));
                    }

                    if (string.IsNullOrEmpty(oReportUser.FaxUserID))
                    {
                        oReportUser.FaxUserID = Utilities.GetConfigValue("ConcordDefaultFaxUserID", "mbx14561504");
                        oReportUser.FaxPassword = Utilities.GetConfigValue("ConcordDefaultFaxPassword", "8105");
                        oReportUser.Email = Utilities.GetConfigValue("ConcordDefaultNotificationEmail", "scan@bluebookservices.com");
                    }


                    faxResult = ConcordFaxProvider.SendFax(oReportUser.FaxUserID, oReportUser.FaxPassword, oReportUser.Email, oReportUser.Destination, oReportUser.PersonName, szAttachmentFile);

                    if (oReportUser.CommunicationLogID > 0)
                    {
                        SqlCommand oUpdateCommand = new SqlCommand("UPDATE PRCommunicationLog SET prcoml_FaxID=@FaxID, prcoml_FaxStatus=@FaxStatus, prcoml_UpdatedDate=GETDATE() WHERE prcoml_CommunicationLog=@CommID", oConn);
                        oUpdateCommand.CommandTimeout = Utilities.GetIntConfigValue("SendFaxQueryTimeout", 300);

                        if (string.IsNullOrEmpty(faxResult.FaxID)) {
                            oUpdateCommand.Parameters.AddWithValue("@FaxID", DBNull.Value);
                        } else {
                            oUpdateCommand.Parameters.AddWithValue("@FaxID", faxResult.FaxID);
                        }

                        oUpdateCommand.Parameters.AddWithValue("@FaxStatus", faxResult.ResultMessage);
                        oUpdateCommand.Parameters.AddWithValue("@CommID", oReportUser.CommunicationLogID);
                        oUpdateCommand.ExecuteNonQuery();
                    }

                    // Now delete the record from the fax queue
                    SqlCommand oDeleteCommand = new SqlCommand(SQL_DELETE_FAX_QUEUE, oConn);
                    oDeleteCommand.Parameters.AddWithValue("@ID", oReportUser.FaxQueueID);
                    oDeleteCommand.ExecuteNonQuery();
                    oDeleteCommand.CommandTimeout = Utilities.GetIntConfigValue("SendFaxQueryTimeout", 300);

                    if (faxResult.ResultCode != FaxResult.SUCCESS)
                    {
                        throw new ApplicationException("Concord Fax Error " + faxResult.ResultCode.ToString() + ": " + faxResult.ResultMessage + " sending to " + oReportUser.Destination + " from " + oReportUser.Email);
                    }

                }

                TimeSpan tsDiff = DateTime.Now.Subtract(dtExecutionStartDate);

            }
            catch (Exception e)
            {
                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("Error in SendFax.", e);
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



        /// <summary>
        /// 
        /// </summary>
        protected void ProcessRightFax() {
            DateTime dtExecutionStartDate = DateTime.Now;

            List<ReportUser> lReportUser = new List<ReportUser>();
            SqlConnection oConn = new SqlConnection(GetConnectionString());
            int iFaxCount = 0;

            string szFaxPrinter = Utilities.GetConfigValue("SendFaxPrinter", @"\\ARTOO\HPFAX");
            string szAttachmentFolder = Utilities.GetConfigValue("SendFaxAttachmentFolder", @"\\sql01\tempreports\");

            string szAttachmentCommand = string.Empty;
            string szFaxCommands = string.Empty;
            try {
                oConn.Open();

                lReportUser = GetFaxInfo(oConn);

                foreach (ReportUser oReportUser in lReportUser) {
                    iFaxCount++;

                    if (oReportUser.IsLibraryDoc) {
                        szAttachmentCommand = string.Format(FAX_COMMAND_LIB_DOC, oReportUser.Attachment);
                    } else {
                        szAttachmentCommand = string.Format(FAX_COMMAND_ATTACHMENT, Path.Combine(szAttachmentFolder, Path.GetFileName(oReportUser.Attachment)));
                    }

                    // If preview is enabled, append it to the attachment command
                    // as it is then added to the end of the command string.
                    if (Utilities.GetBoolConfigValue("SendFaxEnablePreview", false)) {
                        szAttachmentCommand += FAX_COMMAND_PREVIEW;
                    }

                    // if any additional right fax commands are stored on the fax record, append them here
                    if (oReportUser.RightFaxEmbeddedCodes != null) {
                        szAttachmentCommand += oReportUser.RightFaxEmbeddedCodes;
                    }

                    if (oReportUser.CommunicationLogID > 0)
                    {
                        szAttachmentCommand += string.Format(FAX_COMMAND_UNIQUEID, "BBSi" + oReportUser.CommunicationLogID.ToString());
                    }


                    // Get a handle to our fax printer
                    SafeFileHandle ptr = CreateFile(szFaxPrinter,
                                                    FileAccess.ReadWrite,
                                                    FileShare.ReadWrite,
                                                    IntPtr.Zero,
                                                    FileMode.Create,
                                                    0,
                                                    IntPtr.Zero);

                    // If we don't have a valid handle, then something went
                    // wrong.  Ask the framework to throw an exception for
                    // the Win32 error code.
                    if (ptr.IsInvalid) {
                        Marshal.ThrowExceptionForHR(Marshal.GetHRForLastWin32Error());
                    }

                    FileStream fsPrinter = null;
                    StreamWriter swPrinter = null;
                    try {

                        // Open our fax printer as a file using
                        // our win32 handle
                        fsPrinter = new FileStream(ptr, FileAccess.Write);
                        swPrinter = new StreamWriter(fsPrinter);

                        // Format our text string
                        string[] aszArgs = {Utilities.GetConfigValue("TestFax", oReportUser.Destination),
                                            oReportUser.Who,
                                            oReportUser.PersonName,
                                            szAttachmentCommand};

                        // Write it to the fax printer.
                        szFaxCommands = string.Format(FAX_TEXT, aszArgs);

                        _oLogger.LogMessage("szFaxCommands=" + szFaxCommands);
                        swPrinter.WriteLine(szFaxCommands);

                    } finally {
                        swPrinter.Close();
                        fsPrinter.Close();
                    }


                    

                    // Now delete the record from the fax queue
                    SqlCommand oCommand = new SqlCommand(SQL_DELETE_FAX_QUEUE, oConn);
                    oCommand.Parameters.AddWithValue("@ID", oReportUser.FaxQueueID);
                    oCommand.ExecuteNonQuery();
                }

                TimeSpan tsDiff = DateTime.Now.Subtract(dtExecutionStartDate);

            } catch (Exception e) {
                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("Error in SendFax.  Fax Commands: " + szFaxCommands, e);
            } finally {
                if (oConn != null) {
                    oConn.Close();
                }
                oConn = null;
            }
        }


        /// <summary>
        /// Populates the ReportUser object with the fax
        /// information.
        /// </summary>
        /// <param name="oConn"></param>
        private List<ReportUser> GetFaxInfo(SqlConnection oConn) {

            List<ReportUser> lReportUsers = new List<ReportUser>();

            SqlCommand oSQLCommand = new SqlCommand(SQL_SELECT_FAX_QUEUE, oConn);
            oSQLCommand.CommandTimeout = Utilities.GetIntConfigValue("SendFaxQueryTimeout", 300);
            SqlDataReader oReader = null;

            try {
                oReader = oSQLCommand.ExecuteReader();
                while (oReader.Read()) {
                    ReportUser oReportUser = new ReportUser();
                    lReportUsers.Add(oReportUser);

                    oReportUser.FaxQueueID  = oReader.GetInt32(0);
                    if (oReader[1] == DBNull.Value) {
                        oReportUser.Who = Utilities.GetConfigValue("SendFaxUnknownWho", "CRM"); 
                    } else {
                        oReportUser.Who = oReader.GetString(1);
                    }
                    oReportUser.Attachment  = oReader.GetString(2);
                    oReportUser.Destination =  PrepareFaxNumber(oReader.GetString(3));

                    if (oReader[4] == DBNull.Value) {
                        oReportUser.PersonName = Utilities.GetConfigValue("SendFaxUnknownPerson", "Blue Book Services Recipient");
                    } else {
                        oReportUser.PersonName = oReader.GetString(4);
                    }

                    oReportUser.Priority = oReader.GetString(5);

                    if ((oReader[6] != DBNull.Value) &&
                        (oReader.GetString(6) == "1")) {
                        oReportUser.IsLibraryDoc = true;
                    }

                    if (oReader[7] != DBNull.Value) {
                        oReportUser.ScheduledDateTime = oReader.GetDateTime(7);
                    }

                    oReportUser.RightFaxEmbeddedCodes = GetString(oReader[8]);

                    if (oReader[9] != DBNull.Value)
                    {
                        oReportUser.CommunicationLogID = oReader.GetInt32(9);
                    }

                    oReportUser.FaxUserID = GetString(oReader[10]);
                    oReportUser.FaxPassword = GetString(oReader[11]);
                    oReportUser.Email = GetString(oReader[12]);
                }

                return lReportUsers;
            } finally {
                if (oReader != null) {
                    oReader.Close();
                }
            }
        }

        private const string SQL_INSERT_FAX_LOG =
            "INSERT INTO PRFaxErrorLog (prfel_FileName, prfel_FaxSource, prfel_Codes) " +
            "VALUES ({0}, {1}, {2}); " +
            "SELECT @@SCOPE_IDENTITY ";
        private int InsertLogRecord(SqlConnection oConn, string szFileName, string szSource, string FaxCodes)
        {
            string szSQL = string.Format(SQL_INSERT_FAX_LOG, szFileName, szSource, FaxCodes);
            SqlCommand oSQLCommand = new SqlCommand(szSQL, oConn);
            int iLogID = (int)oSQLCommand.ExecuteScalar();

            return iLogID;
        }

        /// <summary>
        /// Helper method to transalate vanity numbers
        /// into valid numbers.
        /// </summary>
        /// <param name="szFaxNumber"></param>
        private void TranslateVanityNumber(string szFaxNumber) {

            StringBuilder sbTranslatedFax = new StringBuilder();
 
            szFaxNumber = szFaxNumber.ToLower();
            for (int i = 0; i < szFaxNumber.Length; i++) {
                switch (szFaxNumber[i]) {
                    case 'a':
                    case 'b':
                    case 'c':
                        sbTranslatedFax.Append("2");
                        break;
                    case 'd':
                    case 'e':
                    case 'f':
                        sbTranslatedFax.Append("3");
                        break;
                    case 'g':
                    case 'h':
                    case 'i':
                        sbTranslatedFax.Append("4");
                        break;
                    case 'j':
                    case 'k':
                    case 'l':
                        sbTranslatedFax.Append("5");
                        break;
                    case 'm':
                    case 'n':
                    case 'o':
                        sbTranslatedFax.Append("6");
                        break;
                    case 'p':
                    case 'r':
                    case 's':
                        sbTranslatedFax.Append("7");
                        break;
                    case 't':
                    case 'u':
                    case 'v':
                        sbTranslatedFax.Append("8");
                        break;
                    case 'w':
                    case 'x':
                    case 'y':
                        sbTranslatedFax.Append("9");
                        break;
                    default:
                        sbTranslatedFax.Append(szFaxNumber[i]);
                        break;
                }

            }

        }


        private string PrepareFaxNumber(string faxNumber)
        {

            faxNumber = new string(faxNumber.Where(c => char.IsDigit(c)).ToArray());

            if ((faxNumber.Length == 10) &&
                (!faxNumber.StartsWith("1"))) {
            
                faxNumber = "1" + faxNumber;
            }

            return faxNumber;
        }
    }
}
