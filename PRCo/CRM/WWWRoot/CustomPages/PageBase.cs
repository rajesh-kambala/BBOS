/***********************************************************************
***********************************************************************
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

 ClassName: PageBase
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.IO;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using ICSharpCode.SharpZipLib.Zip;
using Microsoft.Win32;
using Renci.SshNet;
using Stripe;

namespace PRCo.BBS.CRM {

    /// <summary>
    /// Provides common functionality for all derived
    /// web pages.  Has no visual component.
    /// </summary>
    public class PageBase : System.Web.UI.Page {

        private EventLog _oEventLog;

        protected const string SQL_GET_NEXT_RECORD_ID = "usp_getNextId";
        protected const string CONN_STRING = "server={0};User ID={1};Password={2};Initial Catalog={3};Application Name={4}";        
        

        protected string _szDBConnection;
        protected string _szAppName;

        virtual protected void Page_Load(object sender, EventArgs e) {
            
            SetStyleSheets();
            
            _szAppName = GetConfigValue("AppName");
            //InitializeEWare();


            _oEventLog = new System.Diagnostics.EventLog();
            _oEventLog.Log = "Application";
            _oEventLog.Source = "CRM";
        }

        
        /// <summary>
        /// Helper method that returns a new database connection. 
        /// </summary>
        /// <returns></returns>
        virtual protected SqlConnection OpenDBConnection() {
            return OpenDBConnection("CRM .NET Custom Page");
        }

        public static SqlConnection OpenDBConnectionStatic()
        {
            return OpenDBConnectionStatic("CRM .NET Custom Page");
        }

        /// <summary>
        /// Helper method that returns a new database connection. 
        /// </summary>
        /// <returns></returns>
        virtual protected SqlConnection OpenDBConnection(string szActionName) {

            if (_szDBConnection == null) {
                _szDBConnection = GetDBConnectionString(szActionName);
            }

            SqlConnection dbConn = new SqlConnection(_szDBConnection);
            dbConn.Open();
            return dbConn;
        }

        public static SqlConnection OpenDBConnectionStatic(string szActionName)
        {
            string _szDBConnection = GetDBConnectionString(szActionName);

            SqlConnection dbConn = new SqlConnection(_szDBConnection);
            dbConn.Open();
            return dbConn;
        }

        /// <summary>
        /// Helper method that returns a new database connection. 
        /// </summary>
        /// <returns></returns>
        static string GetDBConnectionString(string szActionName)
        {
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

            string[] aArgs = { szServer, szUserID, szPassword, szDatabase, szActionName };
            return string.Format(CONN_STRING, aArgs);
        }

        /// <summary>
        /// Helper method that closes the specified connection.
        /// </summary>
        /// <param name="dbConn"></param>
        virtual protected void CloseDBConnection(SqlConnection dbConn) {
            if (dbConn != null) {
                dbConn.Close();
            }
        }

        /// <summary>
        /// Helper methos that sets the stylesheets for the current page.
        /// </summary>
        virtual protected void SetStyleSheets() {
            AddStyleSheet("/CRM/prco.css");
            AddStyleSheet("/crm/Themes/Kendo/kendo.default.min.css");
            AddStyleSheet("/crm/Themes/Kendo/kendo.common.min.css");
            AddStyleSheet("/crm/Themes/ergonomic.css?83568");
        }

        /// <summary>
        /// Helper method that adds the specified style sheet
        /// to the page.
        /// </summary>
        /// <param name="szCSSName"></param>
        virtual protected void AddStyleSheet(string szCSSName) {
            HtmlLink link = new HtmlLink();
            link.Href = szCSSName;
            link.Attributes.Add("rel", "stylesheet");
            link.Attributes.Add("type", "text/css");
            Page.Header.Controls.Add(link);
        }


        protected string _szRowClass = "ROW1";
        /// <summary>
        /// Helper method used to set the correct class on
        /// table rows
        /// </summary>
        /// <returns></returns>
        virtual protected string GetRowClass() {
            if (_szRowClass == "ROW1") {
                _szRowClass = "ROW2";
            } else {
                _szRowClass = "ROW1";
            }

            return _szRowClass;
        }

        /// <summary>
        /// Helper method that returns a valid string type, though
        /// possibly NULL.
        /// </summary>
        /// <param name="oStringVal"></param>
        /// <returns></returns>
        virtual protected string GetString(object oStringVal) {
            if (oStringVal == DBNull.Value) {
                return null;
            }

            return Convert.ToString(oStringVal);
        }

        protected int GetInt(object value) {
            if (value == DBNull.Value) {
                return 0;
            }

            return Convert.ToInt32(value);
        }

        protected string GetDateAsString(object value, string format) {
            if (value == DBNull.Value) {
                return string.Empty;
            }

            return Convert.ToDateTime(value).ToString(format);
        }

        /// <summary>
        /// Helper method that returns the value for the specified
        /// configuration value name.  Throws an exception if the
        /// value name is not found.
        /// </summary>
        /// <param name="szValueName"></param>
        /// <returns></returns>
        virtual protected string GetConfigValue(string szValueName) {
            string szValue = GetConfigValue(szValueName, null);
            if (szValue == null) {
                throw new ApplicationException("Configuration value name '" + szValueName + "' was not found.");
            }
            return szValue;
        }

        /// <summary>
        /// Helper method that returns the value for the specified
        /// configuration value name.  If no value is found, then
        /// the specified default is returned.
        /// </summary>
        /// <param name="szValueName"></param>
        /// <param name="szDefault"></param>
        /// <returns></returns>
        virtual protected string GetConfigValue(string szValueName, string szDefault) {
            if (string.IsNullOrEmpty(ConfigurationManager.AppSettings[szValueName])) {
                return szDefault;
            }

            return ConfigurationManager.AppSettings[szValueName];
        }

        /// <summary>
        /// Helper method that returns the specified configuration name
        /// value as an int.  Returns the specified default value if no
        /// value is found.
        /// </summary>
        /// <param name="szValueName"></param>
        /// <param name="iDefault"></param>
        /// <returns></returns>
        virtual protected int GetConfigValue(string szValueName, int iDefault) {
            string szValue = GetConfigValue(szValueName, null);
            if (szValue == null) {
                return iDefault;
            }

            int iValue = 0;
            if (!Int32.TryParse(szValue, out iValue)) {
                throw new ApplicationException("Configuration value '" + szValueName + "' is not a valid integer.");
            }

            return iValue;
        }


        /// <summary>
        /// Helper method that returns the specified configuration name
        /// value as an decimal.  Returns the specified default value if no
        /// value is found.
        /// </summary>
        /// <param name="szValueName"></param>
        /// <param name="dDefault"></param>
        /// <returns></returns>
        virtual protected decimal GetConfigValue(string szValueName, decimal dDefault) {
            string szValue = GetConfigValue(szValueName, null);
            if (szValue == null) {
                return dDefault;
            }

            decimal dValue = 0;
            if (!Decimal.TryParse(szValue, out dValue)) {
                throw new ApplicationException("Configuration value '" + szValueName + "' is not a valid decimal.");
            }

            return dValue;
        }



        /// <summary>
        /// Helper method that returns the specified configuration name
        /// value as an decimal.  Returns the specified default value if no
        /// value is found.
        /// </summary>
        /// <param name="szValueName"></param>
        /// <param name="bDefault"></param>
        /// <returns></returns>
        virtual protected bool GetConfigValue(string szValueName, bool bDefault) {
            string szValue = GetConfigValue(szValueName, null);
            if (szValue == null) {
                return bDefault;
            }

            bool bValue = false;
            if (!bool.TryParse(szValue, out bValue)) {
                throw new ApplicationException("Configuration value '" + szValueName + "' is not a valid boolean.");
            }

            return bValue;
        }

        /// <summary>
        /// Returns the next record ID for the specified table.
        /// </summary>
        /// <param name="szTableName"></param>
        /// <returns></returns>
        virtual protected int GetNextRecordID(string szTableName) {
            SqlConnection dbConn = OpenDBConnection();
            SqlTransaction dbTran = dbConn.BeginTransaction();
            try {
                int iNextID = GetNextRecordID(dbTran, szTableName);
                dbTran.Commit();
                return iNextID;
            } catch {
                dbTran.Rollback();
                throw;
            } finally {
                dbConn.Close();
            }
        }

        /// <summary>
        /// Returns the next record ID for the specified table.
        /// </summary>
        /// <param name="dbTran"></param>
        /// <param name="szTableName"></param>
        /// <returns></returns>
        virtual protected int GetNextRecordID(SqlTransaction dbTran, string szTableName) {

            SqlCommand cmdGetNextRecordID = new SqlCommand(SQL_GET_NEXT_RECORD_ID, dbTran.Connection, dbTran);
            cmdGetNextRecordID.CommandType = CommandType.StoredProcedure;

            cmdGetNextRecordID.Parameters.AddWithValue("@TableName", szTableName);

			// Create the return parameter
            SqlParameter sqlParm = cmdGetNextRecordID.Parameters.Add("@Return", SqlDbType.Int);
			sqlParm.Direction = ParameterDirection.Output;

            cmdGetNextRecordID.ExecuteNonQuery();
            int iReturn = Convert.ToInt32(cmdGetNextRecordID.Parameters["@Return"].Value);

            return iReturn;
        }

        /// <summary>
        /// Parses the specified string value into comma-separated values.
        /// Handles string values enclosed in double-quotes that havea a
        /// comma-within them.
        /// </summary>
        /// <param name="szInputLine"></param>
        /// <returns></returns>
        protected string[] ParseCSVValues(string szInputLine) {
            return ParseCSVValues(szInputLine, ',');
        }

        /// <summary>
        /// Parses the specified string value into comma-separated values.
        /// Handles string values enclosed in double-quotes that havea a
        /// delimiter them.
        /// </summary>
        /// <param name="szInputLine"></param>
        /// <param name="cDelimiterChar"></param>
        /// <returns></returns>
        protected string[] ParseCSVValues(string szInputLine, char cDelimiterChar) {
            string[] aszInputValues = szInputLine.Split(cDelimiterChar);


            ArrayList alInputValues = new ArrayList();
            string szWork = null;

            try
            {
                foreach (string szValue in aszInputValues)
                {

                    if (szWork == null)
                    {
                        if ((szValue.StartsWith("\"")) &&
                            (szValue.EndsWith("\"")))
                        {

                            // Our value starts and ends with double-quotes so
                            // remove them.
                            alInputValues.Add(szValue.Substring(1, szValue.Length - 2));

                        }
                        else if (szValue.StartsWith("\""))
                        {

                            // Our value starts with double-quotes, but does not end with
                            // them.  Thus the original value must have had a delimiter embedded in
                            // it.  Save this portion of the value so we can rebuild it.
                            szWork = szValue;
                        }
                        else
                        {

                            alInputValues.Add(szValue);
                        }
                    }
                    else
                    {
                        // We have something in our work area so we rebuilding a value.
                        // If our current value ends in a double quote, we're done rebuilding
                        // and add it to the array.  Otherwise keep rebuilding.
                        szWork += cDelimiterChar + szValue;
                        if (szValue.EndsWith("\""))
                        {
                            alInputValues.Add(szWork.Substring(1, szWork.Length - 2));
                            szWork = null;
                        }
                    }
                } // End Foreach


                return (string[])alInputValues.ToArray(string.Empty.GetType());

            } catch(Exception eX)
            {
                throw new Exception($"Exception with {szInputLine}", eX);
            }
        }

        protected string GetInstallName() {

            string szInstallName = string.Empty;
            string szURL = Request.RawUrl.ToLower();            
    		int iEndChar=0,iStartChar=0;

		    iEndChar = szURL.IndexOf("/custompages");
		    if (iEndChar != -1) {
			    //find the first '/' before this
			    iStartChar = szURL.Substring(0,iEndChar).LastIndexOf('/');
                iStartChar++;
                szInstallName = szURL.Substring(iStartChar, iEndChar); 
		    }
            
            return szInstallName;
    	}


        /// <summary>
        /// Splits the specified Input into an ArrayList with each string
        /// not exceeding the specified max length.
        /// </summary>
        /// <param name="szInput"></param>
        /// <param name="iMaxLength"></param>
        /// <returns></returns>
        protected ArrayList LimitStringLength(string szInput, int iMaxLength) {
            ArrayList oStringList = new ArrayList();
            
            
            

            // Remove any line feeds (\r). The newline (\n) is in both migrated
            // and new data.  The line feed is only in the new data.
            szInput = szInput.Replace("\r", "");

            
            string[] aszWords = szInput.Split(' ');

            string szWorkArea = string.Empty;
            foreach (string szWord in aszWords) {

                string szCurrentWord = szWord;

                

                // Handle embedded new lines.  After this block of code, the
                // szCurrentWord should be the last token in aszTemp.
                if (szCurrentWord.IndexOf('\n') > -1) {

                    string[] aszTemp = szCurrentWord.Split('\n');

                    // Leave the last token for further processing
                    for (int i=0; i<aszTemp.Length-1; i++) {

                        // When processing the first token, we need
                        // to take the current work area into account.
                        if (i == 0) {
                            if ((szWorkArea.Length + aszTemp[i].Length + 1) > iMaxLength) {
                                oStringList.Add(szWorkArea);
                                szWorkArea = string.Empty;
                            } 
                        }

                        if (szWorkArea.Length > 0) {
                            szWorkArea += " ";
                        }
                        szWorkArea += aszTemp[i];
                        oStringList.Add(szWorkArea);

                        // Reset the work area
                        szWorkArea = string.Empty;
                    }
                    
                    // Set the current word to the last token
                    szCurrentWord = aszTemp[aszTemp.Length - 1];
                }

                if ((szWorkArea.Length + szCurrentWord.Length + 1) > iMaxLength) {
                    oStringList.Add(szWorkArea);
                    szWorkArea = szCurrentWord;
                } else {
                    if (szWorkArea.Length > 0) {
                        szWorkArea += " ";
                    }
                    szWorkArea += szCurrentWord;
                }
            }

            oStringList.Add(szWorkArea);
            return oStringList;
        }

        /// <summary>
        /// Writes an error message to the Event Log.
        /// </summary>
        /// <param name="szMessage">Message</param>
        /// <param name="oEventType">Event Type</param>
        protected void LogEvent(string szMessage, EventLogEntryType oEventType) {
            _oEventLog.WriteEntry(szMessage, oEventType);
        }

        /// <summary>
        /// Writes the information message to the Event Log.
        /// </summary>
        /// <param name="szMessage">Message</param>
        protected void LogEventMessage(string szMessage) {
            LogEvent(szMessage, EventLogEntryType.Information);
        }

        /// <summary>
        /// Writes an error message to the Event Log.
        /// </summary>
        /// <param name="szMessage">Message</param>
        /// <param name="e">Exception</param>
        protected void LogEventError(string szMessage, Exception e) {
            LogEvent(szMessage + " " + e.Message, EventLogEntryType.Error);
        }

        /// <summary>
        /// Helper method to build a URL using the appropriate
        /// virtual root.
        /// </summary>
        /// <param name="szPage"></param>
        /// <returns></returns>
        protected string GetVirtualPath(string szPage) {
            return "/" + GetConfigValue("AppName") + "/" + szPage;

        }


        /// <summary>
        /// Sends email.
        /// </summary>
        /// <param name="szSubject">Subject</param>
        /// <param name="szMessage">Message</param>
        virtual protected void SendMail(string szSubject,
                                        string szMessage) {

            MailAddress oFrom = new MailAddress(GetConfigValue("EmailSupportFrom", "bluebookservices@bluebookservices.com"));
            MailAddress oTo = new MailAddress(GetConfigValue("EmailSupportTo", "cwalls@travant.com"));
            MailMessage oMessage = new MailMessage(oFrom, oTo);

            oMessage.Subject = GetConfigValue("EmailSubjectPrefix", "") + szSubject;
            oMessage.Body = szMessage;

            SmtpClient oSMTPClient = new SmtpClient(GetConfigValue("EMailSMTPServer"));
            //oSMTPClient.Send(oMessage);
        }

        /// <summary>
        /// Helper method that retrieves an INT value
        /// from a data reader.
        /// </summary>
        /// <param name="oReader"></param>
        /// <param name="iOrdinal"></param>
        /// <returns></returns>
        protected int GetInt(IDataReader oReader, int iOrdinal)
        {
            if (oReader[iOrdinal] == DBNull.Value)
            {
                return 0;
            }
            return oReader.GetInt32(iOrdinal);
        }

        /// <summary>
        /// Helper method that retrieves an STRING value
        /// from a data reader
        /// </summary>
        /// <param name="oReader"></param>
        /// <param name="iOrdinal"></param>
        /// <returns></returns>
        protected string GetString(IDataReader oReader, int iOrdinal)
        {
            if (oReader[iOrdinal] == DBNull.Value)
            {
                return null;
            }
            return oReader.GetString(iOrdinal);
        }

        /// <summary>
        /// Helper method that retreives a BOOL value
        /// from the data reader.
        /// </summary>
        /// <param name="oReader"></param>
        /// <param name="iOrdinal"></param>
        /// <returns></returns>
        protected bool GetBool(IDataReader oReader, int iOrdinal)
        {
            if (oReader[iOrdinal] == DBNull.Value) {
                return false;
            }

            if (oReader.GetString(iOrdinal) == "Y")
            {
                return true;
            }

            return false;
        }



        private string _szLogFile = null;
        private void WriteToLog(string szText)
        {
            if (_szLogFile == null)
            {
                _szLogFile = GetConfigValue("LogFile", @"C:\Temp\WWWRoot.log");
            }
            System.IO.File.AppendAllText(_szLogFile, szText + Environment.NewLine);
        }

        protected void DisplayUserMessage(string szMessage)
        {
            string szAlert = "alert('" + szMessage.Replace(@"\", @"\\") + "');";
            Page.ClientScript.RegisterStartupScript(this.GetType(), "UserMessage", szAlert, true);
        }

        private const string SQL_SELECT_USER_GROUPS =
            "SELECT user_PrimaryChannelId As ChannelID FROM Users WITH (NOLOCK) WHERE User_UserId={0} " +
            "UNION " +
            "SELECT chli_Channel_Id As ChannelID FROM Channel_Link WITH (NOLOCK) WHERE chli_User_id={0}";
        protected string _szUserGroups;

        protected bool IsUserInGroup(SqlConnection dbConn, string szUserID, string szGroupIDs)
        {
            if (string.IsNullOrEmpty(_szUserGroups))
            {
                StringBuilder sbUserGroups = new StringBuilder(",");
                string szSQL = string.Format(SQL_SELECT_USER_GROUPS, szUserID);
                SqlCommand cmdGroups = new SqlCommand(szSQL, dbConn);
                using (SqlDataReader drGroups = cmdGroups.ExecuteReader())
                {
                    while (drGroups.Read())
                    {
                        sbUserGroups.Append(drGroups.GetInt32(0).ToString());
                        sbUserGroups.Append(",");
                    }
                }

                _szUserGroups = sbUserGroups.ToString();
            }

            string[] aszGroupIDs = szGroupIDs.Split(',');
            foreach (string szGroupID in aszGroupIDs)
            {
                if (_szUserGroups.IndexOf("," + szGroupID + ",") > -1)
                {
                    return true;
                }
            }

            return false;
        }


        protected const string SQL_UPDATE_CUSTOM_CAPTION = "UPDATE Custom_Captions SET capt_code = CAST(@capt_code as VARCHAR(50)), capt_us=CAST(@capt_code as VARCHAR(50)) WHERE capt_family = @capt_family";
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

        protected void addZipEntry(ZipOutputStream zipOutputStream,
                                   string folder,
                                   string fileName)
        {
            addZipEntry(zipOutputStream, folder, fileName, fileName);
        }

        protected void addZipEntry(ZipOutputStream zipOutputStream,
                                   string folder,
                                   string fileName,
                                   string zipEntryName)
        {
            ZipEntry zipEntry = new ZipEntry(ZipEntry.CleanName(zipEntryName));
            zipEntry.DateTime = DateTime.Now;
            zipEntry.AESKeySize = 256;
            zipOutputStream.PutNextEntry(zipEntry);

            byte[] buffer = new byte[4096];
            using (FileStream fs = System.IO.File.OpenRead(Path.Combine(folder, fileName)))
            {
                int sourceBytes;
                do
                {
                    sourceBytes = fs.Read(buffer, 0, buffer.Length);
                    zipOutputStream.Write(buffer, 0, sourceBytes);

                } while (sourceBytes > 0);
            }
            zipOutputStream.CloseEntry();
        }

        protected void UploadFile(string ftpURL,
                                  string username,
                                  string password,
                                  string fileName)
        {
            FtpWebRequest request = (FtpWebRequest)FtpWebRequest.Create(ftpURL + "/" + Path.GetFileName(fileName));
            request.Method = WebRequestMethods.Ftp.UploadFile;
            request.Credentials = new NetworkCredential(username, password);
            request.UsePassive = GetConfigValue("FTPUploadUsePassive", false);
            request.UseBinary = GetConfigValue("FTPUploadUseBinary", true);
            request.KeepAlive = GetConfigValue("FTPUploadKeepAlive", false);
            request.EnableSsl = false;

            // Read our file into memory
            using (FileStream stream = System.IO.File.OpenRead(fileName))
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
                client.Connect();

                using (FileStream filestream = new FileStream(localFileName, FileMode.Open))
                {
                    client.BufferSize = 4 * 1024; // bypass Payload error large files
                    client.UploadFile(filestream, remoteFileName);
                }
            }

        }


        protected int _iRowCount = 0;
        protected string IncrementRowCount()
        {
            _iRowCount++;
            return string.Empty;
        }

        protected void WriteFileToDisk(string fullName, byte[] abReport)
        {
            using (FileStream oFStream = System.IO.File.Create(fullName, abReport.Length))
            {
                oFStream.Write(abReport, 0, abReport.Length);
            }
        }


        virtual protected string GetFormattedEmail(SqlConnection oConn, SqlTransaction oTran, int companyID, int personID, string subject, string Text, string overrideAddressee)
        {
            return GetFormattedEmail(oConn, oTran, companyID, personID, subject, Text, overrideAddressee, "en-us");
        }

        virtual protected string GetFormattedEmail(SqlConnection oConn, SqlTransaction oTran, int companyID, int personID, string subject, string Text, string overrideAddressee, string culture)
        {
            return GetFormattedEmail(oConn, oTran, companyID, personID, subject, Text, overrideAddressee, culture, null);
        }

        private const string SQL_GET_FORMATTED_EMAIL = "SELECT dbo.ufn_GetFormattedEmail3(@CompanyID, @PersonID, 0, @Subject, @Text, @AddresseeOverride, @Culture, @IndustryType, null, null)";
        virtual protected string GetFormattedEmail(SqlConnection oConn, SqlTransaction oTran, int companyID, int personID, string subject, string Text, string overrideAddressee, string culture, string industryType)
        {
            SqlCommand oDBCommand = new SqlCommand(SQL_GET_FORMATTED_EMAIL, oConn, oTran);
            oDBCommand.Parameters.AddWithValue("CompanyID", companyID);
            oDBCommand.Parameters.AddWithValue("PersonID", personID);
            oDBCommand.Parameters.AddWithValue("Subject", subject);
            oDBCommand.Parameters.AddWithValue("Text", Text);
            oDBCommand.Parameters.AddWithValue("AddresseeOverride", overrideAddressee);
            oDBCommand.Parameters.AddWithValue("Culture", culture);

            if (string.IsNullOrEmpty(industryType))
                oDBCommand.Parameters.AddWithValue("IndustryType", DBNull.Value);
            else
                oDBCommand.Parameters.AddWithValue("IndustryType", industryType);
            
            object oValue = oDBCommand.ExecuteScalar();
            return ((string)oValue);
        }

        protected string stripCharacter(string input, string character)
        {
            return input.Replace(character, string.Empty);
        }


        protected const string SQL_SELECT_CUSTOM_CAPTION =
            "SELECT RTRIM(capt_code) As capt_code, capt_us FROM Custom_Captions WITH(NOLOCK) WHERE capt_Family = @capt_Family ORDER BY capt_order";

        protected void BindLookupValue(SqlConnection sqlConn, ListControl oControl, string szCaptFamily)
        {
            SqlCommand cmdCustomCaption = new SqlCommand(SQL_SELECT_CUSTOM_CAPTION, sqlConn);
            cmdCustomCaption.Parameters.AddWithValue("capt_Family", szCaptFamily);

            oControl.DataTextField = "capt_us";
            oControl.DataValueField = "capt_code";

            using (IDataReader drCustomCaption = cmdCustomCaption.ExecuteReader(CommandBehavior.Default))
            {
                oControl.DataSource = drCustomCaption;
                oControl.DataBind();
            }
        }

        private const string SQL_SELECT_CUSTOM_CAPTION_VALUE =
             "SELECT capt_us FROM Custom_Captions WITH(NOLOCK) WHERE capt_Family = @capt_Family AND capt_Code = @capt_Code";

        protected string GetLookupCodeMeaning(SqlConnection sqlConn, string captFamily, string captCode)
        {
            SqlCommand cmdCustomCaption = new SqlCommand(SQL_SELECT_CUSTOM_CAPTION_VALUE, sqlConn);
            cmdCustomCaption.Parameters.AddWithValue("capt_Family", captFamily);
            cmdCustomCaption.Parameters.AddWithValue("capt_Code", captCode);

            return (string)cmdCustomCaption.ExecuteScalar();
        }

        #region "PREmailImages"
        /* 
         * These GetEmailImnages() methods are also used in BBSMonitorEvent.cs.
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


        private string emailImageLumberT = null;
        private string emailImageLumberB = null;
        private string emailImageProduceT = null;
        private string emailImageProduceB = null;
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

            string szParm1 = "";

            switch (szIndustryCode)
            {
                case "L":
                    if (szLocationCode == "T")
                    {
                        if (emailImageLumberT != null)
                            return emailImageLumberT;
                    }
                    else
                    {
                        if (emailImageLumberB != null)
                            return emailImageLumberB;
                    }
                    szParm1 = " AND prei_Industry IN ('B', 'L') ";
                    break;
                default:
                    if (szLocationCode == "T")
                    {
                        if (emailImageProduceT != null)
                            return emailImageProduceT;
                    }
                    else
                    {
                        if (emailImageProduceB != null)
                            return emailImageProduceB;
                    }

                    //Default assumed for P, T, S, or blank szIndustryCode
                    szParm1 = " AND prei_Industry IN ('B', 'PTS') ";
                    break;
            }

            StringBuilder sb = new StringBuilder();

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

            switch (szIndustryCode)
            {
                case "L":
                    if (szLocationCode == "T")
                        emailImageLumberT = sb.ToString();
                    else
                        emailImageLumberB = sb.ToString();
                    
                    break;
                default:
                    if (szLocationCode == "T")
                        emailImageProduceT = sb.ToString();
                    else
                        emailImageProduceB = sb.ToString();

                    break;
            }
            return sb.ToString();
        }

        #endregion

        protected const string SQL_STRIPE_INVOICE_ENABLED =
            @"SELECT Capt_US FROM Custom_Captions WHERE capt_family='StripeInvoice' AND capt_code='StripeInvoiceEnabled'";

        protected bool StripeInvoiceEnabled()
        {
            using (SqlConnection oConn = OpenDBConnection())
            {
                SqlCommand sqlCommand = oConn.CreateCommand();
                sqlCommand.CommandText = SQL_STRIPE_INVOICE_ENABLED;
                object value = sqlCommand.ExecuteScalar();
                if (value != null)
                {
                    string szResult = Convert.ToString(value);
                    if (szResult.ToLower() == "true")
                        return true;
                }
            }

            return false; //default (anything but "true")
        }

        protected string GetStripeHostedURL(string customerNo, string stripeCustomerId, IDataReader drInvoices, string inclusionType)
        {
            SqlConnection _dbConn2 = OpenDBConnection("GenerateInvoices");
            try
            {
                int _iUserID = 0;
                Int32.TryParse(Request["user_userid"], out _iUserID);

                if (stripeCustomerId == null)
                {
                    //Create a stripe customer
                    StripeError stripeCustomerError;
                    Customer stripeCustomer = Stripe.Customer_Create(customerNo,
                            (string)drInvoices["BillToName"],
                            (string)drInvoices["BillToAddress1"],
                            (string)drInvoices["BillToAddress2"],
                            (string)drInvoices["BillToCity"],
                            (string)drInvoices["BillToState"],
                            (string)drInvoices["BillToZipCode"],
                            "", //TODO:JMT phone from where??
                            (string)drInvoices["EmailAddress"],
                            out stripeCustomerError);

                    if (stripeCustomerError != null)
                        throw new Exception(stripeCustomerError.Message);

                    Stripe.StripeCustomerId_Update(customerNo, stripeCustomer.Id, _iUserID, _dbConn2);
                    stripeCustomerId = stripeCustomer.Id;
                }

                DateTime? nextAnniversaryDate = null;
                if (drInvoices["prse_NextAnniversaryDate"] != DBNull.Value)
                    nextAnniversaryDate = Convert.ToDateTime(drInvoices["prse_NextAnniversaryDate"]);

                decimal salesTaxAmt = (decimal)drInvoices["SalesTaxAmt"];

                DataRowView[] drvDetails = null;
                if (inclusionType == "I")                                                               
                    drvDetails = GetInvoiceDetails(_dbConn2, (string)drInvoices["JournalNoGLBatchNo"], (string)drInvoices["UDF_MASTER_INVOICE"]);
                else {
                    SqlDataAdapter adapter = new SqlDataAdapter(SQL_INVOICE_DETAILS_2, _dbConn2);
                    adapter.SelectCommand.CommandTimeout = 180;
                    adapter.SelectCommand.Parameters.AddWithValue("InvoiceNbr", (string)drInvoices["UDF_MASTER_INVOICE"]);

                    DataSet ds = new DataSet();
                    adapter.Fill(ds);

                    DataView dvInvoiceDetails = new DataView(ds.Tables[0]);
                    dvInvoiceDetails.Sort = "UDF_MASTER_INVOICE";
                    drvDetails = dvInvoiceDetails.FindRows((string)drInvoices["UDF_MASTER_INVOICE"]);
                }

                //Create stripe invoice
                StripeError stripeInvoiceError;
                Invoice stripeInvoice = Stripe.Invoice_Create(stripeCustomerId, customerNo, (string)drInvoices["UDF_MASTER_INVOICE"], nextAnniversaryDate, salesTaxAmt, drvDetails, out stripeInvoiceError);
                if (stripeInvoiceError != null)
                    throw new Exception(stripeInvoiceError.Message);

                //Create PRInvoice record
                 string szSentMethodCode = "";
                if (!string.IsNullOrEmpty((string)drInvoices["EmailAddress"]))
                    szSentMethodCode = Stripe.PRINV_SENT_METHOD_CODE_EMAIL;
                else if (!string.IsNullOrEmpty((string)drInvoices["FaxNo"]))
                    szSentMethodCode = Stripe.PRINV_SENT_METHOD_CODE_FAX;

                Stripe.PRInvoice_Insert(customerNo,
                                        (string)drInvoices["UDF_MASTER_INVOICE"],
                                        szSentMethodCode,
                                        DateTime.Now,
                                        stripeInvoice.HostedInvoiceUrl,
                                        stripeInvoice.Id,
                                        _iUserID, _dbConn2);

                return stripeInvoice.HostedInvoiceUrl;

            } finally {
                _dbConn2.Close();
            }
        }

        private const string SQL_PAID_PAYMENT_URL =
              @"SELECT prinv_StripePaymentURL  
                FROM PRInvoice WITH (NOLOCK)
               WHERE prinv_InvoiceNbr = @InvoiceNbr
                 AND prinv_PaymentImportedIntoMAS = 'Y'";

        protected string GetPaidStripePaymentURL(SqlConnection sqlConnection, string invoiceNumber) 
        {
            SqlCommand cmdPaidURL = new SqlCommand(SQL_PAID_PAYMENT_URL, sqlConnection);
            cmdPaidURL.Parameters.AddWithValue("InvoiceNbr", invoiceNumber);
            object paidURL = cmdPaidURL.ExecuteScalar();

            if ((paidURL == null) ||
                (paidURL == DBNull.Value))
                return null;

            return Convert.ToString(paidURL);
        }

        private const string SQL_MOST_RECENT_PAYMENT_URL =
            @"SELECT TOP 1 prinv_StripePaymentURL, prinv_CreatedDate
                FROM PRInvoice WITH (NOLOCK)
               WHERE prinv_InvoiceNbr = @InvoiceNbr
                 AND prinv_StripePaymentURL IS NOT NULL
            ORDER BY prinv_CreatedDate DESC";

        protected string GetMostRecentStripePaymentURL(SqlConnection sqlConnection, string invoiceNumber)
        {
            SqlCommand cmdMostRecentURL = new SqlCommand(SQL_MOST_RECENT_PAYMENT_URL, sqlConnection);
            cmdMostRecentURL.Parameters.AddWithValue("InvoiceNbr", invoiceNumber);

            using (IDataReader reader = cmdMostRecentURL.ExecuteReader(CommandBehavior.Default))
            {
                if (reader.Read())
                {
                    string paymentURL = reader.GetString(0);
                    DateTime createdDateTime = reader.GetDateTime(1);

                    if (DateTime.Today.Subtract(createdDateTime).TotalDays < GetConfigValue("StripeInvoiceLinkExpiration", 28))
                        return paymentURL;
                }
            }

            return null;
        }

        private string SQL_INVOICE_DETAILS_2 =
           @"SELECT ihh.UDF_MASTER_INVOICE, ihh.CustomerNo, PRCompanySearch.prcse_FullName AS ServiceLocation, ihd.ItemCodeDesc, ExtensionAmt,
                    QuantityOrdered, ItemCodeDesc, ISNULL(prod_PRRecurring,'') IsRecognition,
                    PRCompanySearch.prcse_FullName AS ServiceLocation,
		            ISNULL(LAG(PRCompanySearch.prcse_FullName, 1) OVER(ORDER BY UDF_MASTER_INVOICE, ISNULL(T1.PrimarySort, 9999), ShipToState, ShipToCity, DetailSeqNo), '') ServiceLocation_Prev,
                    ISNULL(T1.PrimarySort, 9999) PrimarySort, ShipToState, ShipToCity, DetailSeqNo
               FROM MAS_PRC.dbo.AR_InvoiceHistoryHeader ihh WITH (NOLOCK) 
                    INNER JOIN MAS_PRC.dbo.AR_InvoiceHistoryDetail ihd WITH (NOLOCK) ON ihh.InvoiceNo = ihd.InvoiceNo AND ihh.HeaderSeqNo = ihd.HeaderSeqNo
 	                INNER JOIN PRCompanySearch WITH (NOLOCK) ON PRCompanySearch.prcse_CompanyId = CustomerNo
                    INNER JOIN CRM.dbo.Company WITH (NOLOCK) ON Comp_CompanyId = prcse_CompanyId
                    INNER JOIN CRM.dbo.vPRLocation ON comp_PRListingCityID = prci_CityID
                    LEFT OUTER JOIN NewProduct  WITH (NOLOCK) ON prod_code = ItemCode AND prod_PRRecurring='Y' AND Prod_ProductID <> 85 -- Exclude the old L100 code
                    LEFT OUTER JOIN (
			            SELECT DISTINCT CustomerNo As PrimaryCompanyID, 1 as PrimarySort
			              FROM MAS_PRC.dbo.AR_InvoiceHistoryHeader ihh WITH (NOLOCK)
				               INNER JOIN MAS_PRC.dbo.AR_InvoiceHistoryDetail ihd WITH (NOLOCK) ON ihh.InvoiceNo = ihd.InvoiceNo AND ihh.HeaderSeqNo = ihd.HeaderSeqNo 
				               INNER JOIN MAS_PRC.dbo.CI_Item ON ihd.ItemCode = CI_Item.ItemCode
			             WHERE Category2 = 'PRIMARY') T1 ON CustomerNo = PrimaryCompanyID
               WHERE UDF_MASTER_INVOICE = @InvoiceNbr 
                 AND ExplodedKitItem <> 'C'
            ORDER BY UDF_MASTER_INVOICE, ShipToState, ShipToCity, DetailSeqNo";


        protected DataView _dvInvoiceDetails = null;

        protected string GetInvoiceForEmail(SqlConnection sqlConnection, string invoiceNumber, DateTime invoiceDate, DateTime dueDate, decimal salesTaxAmt, decimal total, decimal balance, string journalBatchNo = null)
        {
            StringBuilder emailDetails = new StringBuilder();
            string custommerNo = string.Empty;

            if (journalBatchNo != null) {
                custommerNo = string.Empty;

                DataRowView[] adrRows = GetInvoiceDetails(sqlConnection, journalBatchNo, invoiceNumber);
                foreach (DataRowView drRow in adrRows)
                {
                    if (custommerNo != drRow[1].ToString())
                    {
                        emailDetails.Append($"<tr><td colspan=4 class=bbsBottomBorder><strong>{drRow[2]}</strong></td></tr>");
                        custommerNo = drRow[1].ToString();
                    }

                    emailDetails.Append($"<tr><td>{drRow[3].ToString()}</td><td align=right>{Convert.ToDecimal(drRow[4]):c}</td></tr>");
                }                
            }
            else
            {
                SqlCommand cmdInvoiceDetails = new SqlCommand(SQL_INVOICE_DETAILS_2, sqlConnection);
                cmdInvoiceDetails.Parameters.AddWithValue("InvoiceNbr", invoiceNumber);

                using (IDataReader reader = cmdInvoiceDetails.ExecuteReader(CommandBehavior.Default))
                {
                    custommerNo = string.Empty;
                    while (reader.Read())
                    {
                        if (custommerNo != reader.GetString(1))
                        {
                            emailDetails.Append($"<tr><td colspan=4 class=bbsBottomBorder><strong>{reader.GetString(2)}</strong></td></tr>");
                            custommerNo = reader.GetString(1);
                        }

                        emailDetails.Append($"<tr><td>{reader.GetString(3)}</td><td align=right>{reader.GetDecimal(4):c}</td></tr>");
                    }
                }
            }

            string emailBody = string.Empty;
            string emailTemplate = ReadTemplate("InvoiceInfoHeader.html");

            string[] args = { invoiceNumber,
                                invoiceDate.ToShortDateString(),
                                dueDate.ToShortDateString(),
                                total.ToString("c"),
                                emailDetails.ToString(),
                                balance.ToString("c"),
                                salesTaxAmt.ToString("c"),
                                balance.ToString("c") };

            emailBody = string.Format(emailTemplate, args);

            return emailBody;
        }


        private string SQL_INVOICE_DETAILS =
           @"SELECT ihh.UDF_MASTER_INVOICE, ihh.CustomerNo, PRCompanySearch.prcse_FullName AS ServiceLocation, ihd.ItemCodeDesc, ExtensionAmt,
                    QuantityOrdered, ItemCodeDesc, ISNULL(prod_PRRecurring,'') IsRecognition,
                    PRCompanySearch.prcse_FullName AS ServiceLocation,
		            ISNULL(LAG(PRCompanySearch.prcse_FullName, 1) OVER(ORDER BY UDF_MASTER_INVOICE, ISNULL(T1.PrimarySort, 9999), ShipToState, ShipToCity, DetailSeqNo), '') ServiceLocation_Prev,
                    ISNULL(T1.PrimarySort, 9999) PrimarySort, ShipToState, ShipToCity, DetailSeqNo
               FROM MAS_PRC.dbo.AR_InvoiceHistoryHeader ihh WITH (NOLOCK) 
                    INNER JOIN MAS_PRC.dbo.AR_InvoiceHistoryDetail ihd WITH (NOLOCK) ON ihh.InvoiceNo = ihd.InvoiceNo AND ihh.HeaderSeqNo = ihd.HeaderSeqNo
 	                INNER JOIN PRCompanySearch WITH (NOLOCK) ON PRCompanySearch.prcse_CompanyId = CustomerNo
                    INNER JOIN CRM.dbo.Company WITH (NOLOCK) ON Comp_CompanyId = prcse_CompanyId
                    INNER JOIN CRM.dbo.vPRLocation ON comp_PRListingCityID = prci_CityID
                    LEFT OUTER JOIN NewProduct  WITH (NOLOCK) ON prod_code = ItemCode AND prod_PRRecurring='Y' AND Prod_ProductID <> 85 -- Exclude the old L100 code
                    LEFT OUTER JOIN (
			            SELECT DISTINCT CustomerNo As PrimaryCompanyID, 1 as PrimarySort
			              FROM MAS_PRC.dbo.AR_InvoiceHistoryHeader ihh WITH (NOLOCK)
				               INNER JOIN MAS_PRC.dbo.AR_InvoiceHistoryDetail ihd WITH (NOLOCK) ON ihh.InvoiceNo = ihd.InvoiceNo AND ihh.HeaderSeqNo = ihd.HeaderSeqNo 
				               INNER JOIN MAS_PRC.dbo.CI_Item ON ihd.ItemCode = CI_Item.ItemCode
			             WHERE Category2 = 'PRIMARY') T1 ON CustomerNo = PrimaryCompanyID
              WHERE JournalNoGLBatchNo = @JournalBatchNum
                AND ExplodedKitItem <> 'C'
           ORDER BY ihh.UDF_MASTER_INVOICE, ISNULL(T1.PrimarySort, 9999), ShipToState, ShipToCity, DetailSeqNo";

        protected DataRowView[] GetInvoiceDetails(SqlConnection sqlConnection, string journalBatchNo, string invoiceNumber)
        {
            if (_dvInvoiceDetails == null)
            {
                SqlDataAdapter adapter = new SqlDataAdapter(SQL_INVOICE_DETAILS, sqlConnection);
                adapter.SelectCommand.CommandTimeout = 180;
                adapter.SelectCommand.Parameters.AddWithValue("JournalBatchNum", journalBatchNo);

                DataSet ds = new DataSet();
                adapter.Fill(ds);

                _dvInvoiceDetails = new DataView(ds.Tables[0]);
                _dvInvoiceDetails.Sort = "UDF_MASTER_INVOICE";
            }

            DataRowView[] adrRows = _dvInvoiceDetails.FindRows(invoiceNumber);
            return adrRows;
        }


        private const string SQL_GET_INVOICE_DOWNLOAD_URL =
            @"SELECT TOP 1 prinv_PaymentURLKey
                FROM PRInvoice WITH (NOLOCK)
               WHERE prinv_InvoiceNbr = @InvoiceNbr
            ORDER BY prinv_CreatedDate DESC";

        private static string bbosURL = null;

        protected string GetInvoiceDownloadURL(SqlConnection sqlConnection, string invoiceNumber)
        {
            if (bbosURL == null)
            {
                string szSQL = "SELECT dbo.ufn_GetCustomCaptionValue('BBOS', 'URL', 'en-us')";
                SqlCommand cmdBBOSURL = new SqlCommand(szSQL, sqlConnection);
                bbosURL = (string)cmdBBOSURL.ExecuteScalar();
            }

            SqlCommand cmdMostRecentURL = new SqlCommand(SQL_GET_INVOICE_DOWNLOAD_URL, sqlConnection);
            cmdMostRecentURL.Parameters.AddWithValue("InvoiceNbr", invoiceNumber);

            using (IDataReader reader = cmdMostRecentURL.ExecuteReader(CommandBehavior.Default))
            {
                if (reader.Read())
                    return $"{bbosURL}/PI.aspx?k={reader.GetString(0)}&a=d";
            }

            return null;
        }
    
        protected string GetPaymentButton(string language, decimal amountDue, string paymentURL)
        {
            if (amountDue == 0)
            {
                if (language == "S")
                    return $"<strong>PAGADO EN SU TOTALIDAD</strong>";

                return $"<strong>PAID IN FULL</strong>";
            }

            string culture = "en-us";
            if (language == "S")
                culture = "es-mx";

            return $"<a href=\"{paymentURL}\"><img src=\"https://apps.bluebookservices.com/BBOS/{culture}/images/Pay-Now.png\" border=\"0\" align=\"center\" /></a>";
        }

        protected string GetBottomMessageTemplate(string comp_PRIndustryType, string commLanguage)
        {
            string szTemplate = "";

            switch(comp_PRIndustryType)
            {
                case "L":
                    if (commLanguage == "S")
                        szTemplate = "Invoice Email - Spanish MSG_L.html";
                    else
                        szTemplate = "Invoice Email - English MSG_L.html";

                    break;
                default:
                    if (commLanguage == "S")
                        szTemplate = "Invoice Email - Spanish MSG_P.html";
                    else
                        szTemplate = "Invoice Email - English MSG_P.html";

                    break;
            }

            return ReadTemplate(szTemplate, true); //if template is missing return empty string
        }

        protected string ReadTemplate(string templateFileName)
        {
            return ReadTemplate(templateFileName, false);
        }

        protected string ReadTemplate(string templateFileName, bool bReturnBlankIfMissing)
        {
            string templatesFolder = GetConfigValue("TemplatesPath");
            string szFile = Path.Combine(templatesFolder, templateFileName);

            if (bReturnBlankIfMissing)
            {
                if (System.IO.File.Exists(szFile))
                    return System.IO.File.ReadAllText(szFile);
                else
                    return ""; //don't error in case file is missing
            }
            else
                return System.IO.File.ReadAllText(szFile);
        }
    }
}
