/***********************************************************************
 Copyright Produce Reporter Company 2019-2022

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: PACAImportEvent.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Net;
using System.Text;
using System.Text.RegularExpressions;
using System.Timers;

using Renci.SshNet;
using LumenWorks.Framework.IO.Csv;
using ICSharpCode.SharpZipLib.Zip;
using TSI.Utils;

namespace PRCo.BBS.BBSMonitor
{
    public class PACAImportEvent : BBSMonitorEvent
    {
        override public void Initialize(int iIndex)
        {
            _szName = "PACAImport";

            base.Initialize(iIndex);

            try {
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("PACAImportInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("PACAImport Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("PACAImportStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

                _oLogger.LogMessage("PACAImport Start: " + _dtNextDateTime.ToString());

            }
            catch (Exception e) {
                LogEventError("Error initializing PACAImport event.", e);
                throw;
            }
        }

        /// <summary>
        /// Import the PACA Files
        /// </summary>
        override public void ProcessEvent()
        {
            DateTime dtExecutionStartDate = DateTime.Now;

            int intPACACommandTimeout = Utilities.GetIntConfigValue("PACACommandTimeout", 900);
            _oLogger.LogMessage("PACACommandTimeout: " + intPACACommandTimeout.ToString());

            StringBuilder sbMsg = new StringBuilder();
            string zipFileName = null;

            // If we don't find a test date, default to yesterday.
            DateTime fileDate = Utilities.GetDateTimeConfigValue("PACAImportTestDate", DateTime.Today.AddDays(-1));

            timestamp = fileDate.ToString("yyyyMMdd");
            _oLogger.LogMessage("Calculated timestamp: " + timestamp);

            outputDir = Utilities.GetConfigValue("PACAImportFolder");

            license = new PACAFile(timestamp + "license.csv", PACAFile.FileType.License);
            trade = new PACAFile(timestamp + "trade.csv", PACAFile.FileType.Trade);
            principal = new PACAFile(timestamp + "principal.csv", PACAFile.FileType.Principal);
            complaints = new PACAFile(timestamp + "complaint.csv", PACAFile.FileType.Complaints);

            try {

                int fileCount = downloadPACAFiles();

                if (fileCount == 0) {
                    sbMsg.Append("No files downloaded");
                }
                else {

                    int iMatchedLicenses = 0;
                    SqlConnection oConn = new SqlConnection(GetConnectionString());
                    oConn.Open();

                    SqlTransaction oTran = null;

                    try
                    {
                        oTran = oConn.BeginTransaction();

                        LoadFile(oConn, oTran, license);
                        LoadFile(oConn, oTran, trade);
                        LoadFile(oConn, oTran, principal);
                        LoadFile(oConn, oTran, complaints);

                        // Now we execute the stored procedure that processes
                        // the newly imported records.
                        SqlCommand cmdCreate = new SqlCommand("usp_PACAProcessImports", oConn);
                        cmdCreate.CommandType = CommandType.StoredProcedure;
                        cmdCreate.Transaction = oTran;
                        cmdCreate.CommandTimeout = intPACACommandTimeout;

                        SqlParameter parmCreate = cmdCreate.Parameters.Add("ReturnValue", SqlDbType.Int);
                        parmCreate.Direction = ParameterDirection.ReturnValue;
                        cmdCreate.ExecuteNonQuery();

                        iMatchedLicenses = Convert.ToInt32(cmdCreate.Parameters["ReturnValue"].Value);

                        if (File.Exists(Path.Combine(outputDir, complaints.FileName))) { 
                            //Process Complaints (3.1.2.5)
                            SqlCommand cmdProcessComplaints = new SqlCommand("usp_PACAProcessComplaints", oConn);
                            cmdProcessComplaints.CommandType = CommandType.StoredProcedure;
                            cmdProcessComplaints.Transaction = oTran;
                            cmdProcessComplaints.CommandTimeout = intPACACommandTimeout;
                            cmdProcessComplaints.ExecuteNonQuery();
                        }

                        zipFileName = cleanupFiles();

                        if (Utilities.GetBoolConfigValue("PACAImportCommitImport", true)) 
                            oTran.Commit();
                        else 
                            oTran.Rollback();

                    }
                    catch {
                        if (oTran != null) {
                            oTran.Rollback();
                        }

                        throw;
                    }
                    finally {
                        if (oConn != null) {
                            oConn.Close();
                        }

                        oConn = null;
                    }

                    sbMsg.Append("PACA import results for date " + fileDate.ToString("MM-dd-yyyy") + ".  The input files have been saved to " + zipFileName + "." + Environment.NewLine + Environment.NewLine);

                    if (!string.IsNullOrEmpty(complaintsMsg))
                    {
                        sbMsg.Append(complaintsMsg);
                        sbMsg.Append(Environment.NewLine);
                        sbMsg.Append(Environment.NewLine);
                    }

                    WriteFileDetails(sbMsg, license, iMatchedLicenses);
                    sbMsg.Append(Environment.NewLine);
                    WriteFileDetails(sbMsg, trade, 0);
                    sbMsg.Append(Environment.NewLine);
                    WriteFileDetails(sbMsg, principal, 0);
                    sbMsg.Append(Environment.NewLine);
                    WriteFileDetails(sbMsg, complaints, 0);
                }

                //See if there were any Failed counts, and if so always send to support regardless of config flag
                string szTitle = "PACA Import Success";

                int intTotalFailedCount = 0;
                intTotalFailedCount += license.FailedCount;
                intTotalFailedCount += trade.FailedCount;
                intTotalFailedCount += principal.FailedCount;
                intTotalFailedCount += complaints.FailedCount;

                if(intTotalFailedCount > 0)
                    szTitle = string.Format("PACA Import Failures", intTotalFailedCount);

                DateTime dtExecutionEndDateTime = DateTime.Now;
                sbMsg.Append(Environment.NewLine);
                sbMsg.Append("Start Date/Time:" + dtExecutionStartDate.ToString() + Environment.NewLine);
                sbMsg.Append("End Date/Time:" + dtExecutionEndDateTime.ToString() + Environment.NewLine);

                TimeSpan tsDiff = dtExecutionEndDateTime.Subtract(dtExecutionStartDate);
                sbMsg.Append("\n\nExecution time: " + tsDiff.ToString());

                if (Utilities.GetBoolConfigValue("PACAImportWriteResultsToEventLog", true)) {
                    _oBBSMonitorService.LogEvent(sbMsg.ToString());
                }
                
                if (intTotalFailedCount >0 || Utilities.GetBoolConfigValue("PACAImportSendResultsToSupport", true)) {
                    SendMail(szTitle, sbMsg.ToString());
                }

                if (!string.IsNullOrEmpty(Utilities.GetConfigValue("PACAImportSendResultsToAdditionalEmail", string.Empty))) {
                    SendMail(Utilities.GetConfigValue("PACAImportSendResultsToAdditionalEmail"),
                             szTitle,
                             sbMsg.ToString());
                }
            }
            catch (Exception e) {
                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("Error Procesing PACAImport Event.", e);
            }
        }

        private void WriteFileDetails(StringBuilder sbMsg, PACAFile pacaFile, int iMatchedLicenses)
        {
            sbMsg.Append("File: " + pacaFile.FileName + Environment.NewLine);
            sbMsg.Append(" - Success Count: " + pacaFile.SuccessCount.ToString("###,##0") + Environment.NewLine);
            sbMsg.Append(" - Failed Count: " + pacaFile.FailedCount.ToString("###,##0") + Environment.NewLine);
            sbMsg.Append(" - Wrong Format Count: " + pacaFile.WrongFormatCount.ToString("###,##0") + Environment.NewLine);
            if (iMatchedLicenses > 0)
                sbMsg.Append(" - Match Count: " + iMatchedLicenses.ToString("###,##0") + Environment.NewLine);

            if (pacaFile.Errors.Count > 0) {
                sbMsg.Append(" - Failed Record Details: " + Environment.NewLine);
                foreach (string error in pacaFile.Errors) {
                    sbMsg.Append("   * " + error + Environment.NewLine);
                }
            }
        }

        /// <summary>
        /// This method loads the specified file into the CRM database.
        /// </summary>
        /// <param name="dbConn"></param>
        /// <param name="oTran"></param>
        /// <param name="pacaFile"></param>
		private void LoadFile(SqlConnection dbConn,
                              SqlTransaction oTran,
                              PACAFile pacaFile)
        {
            // Create a name for the file to store
            string sFilename = Path.GetFileName(pacaFile.FileName);

            // Make all date references one consistent time
            DateTime dtNow = DateTime.Now;

            SqlCommand cmdCreate = null;
            SqlParameter parm = null;
            int iReturn;

            //create some variables for statistics
            int iWrongCount = 0;
            int iFailedLoad = 0;
            int iSuccessLoad = 0;

            int iCSVRecordCount = 0;
            string szPACAComplaintError = "";
            string szPACALicenseError = "";

            try {
                cmdCreate = new SqlCommand(pacaFile.StoredProc, dbConn);
                cmdCreate.CommandType = CommandType.StoredProcedure;
                cmdCreate.Transaction = oTran;
                cmdCreate.CommandTimeout = Utilities.GetIntConfigValue("PACACommandTimeout", 900);

                // Process each line of input
                int iSequence = 0; //used by Principal
                string licenseNumber = string.Empty;

                bool bProcessFile = true;
                if (pacaFile.Type == PACAFile.FileType.Complaints)
                {
                    //Make sure complaints file exists, else skip it
                    string szComplaintFileName = Path.Combine(outputDir, pacaFile.FileName);
                    if (!File.Exists(szComplaintFileName))
                        bProcessFile = false;
                    else
                    {
                        var csvFileLen = new FileInfo(szComplaintFileName).Length;
                        if (csvFileLen == 0)
                        {
                            bProcessFile = false;
                            szPACAComplaintError += string.Format("The latest PACA Complaints file {0} is empty", pacaFile.FileName);
                        }
                    }
                }
                else if (pacaFile.Type == PACAFile.FileType.License)
                {
                    //Make sure license file doesn't exceed file size limit, else skip it (Defect 6847)
                    string szLicenseFileName = Path.Combine(outputDir, pacaFile.FileName);
                    if (File.Exists(szLicenseFileName))
                    {
                        var intMaxLicenseFileSize = Utilities.GetIntConfigValue("PACAImportLicenseMaxSize", 153600);
                        var csvFileLen = new FileInfo(szLicenseFileName).Length;
                        if (csvFileLen > intMaxLicenseFileSize)
                        {
                            bProcessFile = false;
                            szPACALicenseError += string.Format("The latest PACA License file {0} exceeds the file size limit of {1} bytes and has been skipped.  Please use the command line utility to import it manually.", pacaFile.FileName, intMaxLicenseFileSize);
                        }
                    }
                }

                if (bProcessFile)
                {
                    using (CsvReader csv = new CsvReader(new StreamReader(Path.Combine(outputDir, pacaFile.FileName)), true))
                    {
                        while (csv.ReadNextRecord())
                        {
                            // Cursory validation of this line says that it 
                            // should have <iExpectedCount> fields
                            // If it doesn't we cannot process it.
                            if (csv.FieldCount != pacaFile.ColumnCount)
                            {
                                iWrongCount++;
                                continue;
                            }

                            iCSVRecordCount++;

                            // this record may have a fighting chance at being processed
                            for (int i = 0; i < csv.FieldCount; i++)
                            {
                                // Skip our last field becuase we are ignoring it
                                // for now.
                                if ((Utilities.GetBoolConfigValue("PACALicenseDeletedFieldEnabled", false)) &&
                                    (pacaFile.Type == PACAFile.FileType.License) &&
                                    (i == 27))
                                    continue;


                                // if the value is empty, set our string value property to null
                                if (csv[i].Length == 0)
                                    pacaFile.Parameters[i].ParamValue = null;
                                else
                                    pacaFile.Parameters[i].ParamValue = csv[i];
                            }

                            try
                            {
                                // clear all stored procedure parameters
                                cmdCreate.Parameters.Clear();

                                // create the return parameter
                                parm = cmdCreate.Parameters.Add("ReturnValue", SqlDbType.Int);
                                parm.Direction = ParameterDirection.ReturnValue;

                                // Load the stored procedure based upon file type
                                switch (pacaFile.Type)
                                {
                                    case PACAFile.FileType.License:
                                        // load sp parameters common for each call
                                        parm = cmdCreate.Parameters.AddWithValue("@pril_FileName", sFilename);
                                        parm = cmdCreate.Parameters.AddWithValue("@pril_ImportDate", dtNow);
                                        break;

                                    case PACAFile.FileType.Principal:

                                        // load sp parameters common for each call
                                        parm = cmdCreate.Parameters.AddWithValue("@prip_FileName", sFilename);
                                        parm = cmdCreate.Parameters.AddWithValue("@prip_ImportDate", dtNow);

                                        // load the sequence
                                        parm = cmdCreate.Parameters.AddWithValue("@prip_Sequence", iSequence);
                                        iSequence++;
                                        break;

                                    case PACAFile.FileType.Trade:
                                        // load sp parameters common for each call
                                        parm = cmdCreate.Parameters.AddWithValue("@prit_FileName", sFilename);
                                        parm = cmdCreate.Parameters.AddWithValue("@prit_ImportDate", dtNow);
                                        break;

                                    case PACAFile.FileType.Complaints:
                                        // load sp parameters common for each call
                                        parm = cmdCreate.Parameters.AddWithValue("@pripc_FileName", sFilename);
                                        parm = cmdCreate.Parameters.AddWithValue("@pripc_ImportDate", dtNow);
                                        break;
                                }

                                pacaFile.LoadParameters(cmdCreate);

                                bool saveRecord = true;
                                StringBuilder sbSQL = new StringBuilder("EXEC " + cmdCreate.CommandText + " ");
                                foreach (SqlParameter parm2 in cmdCreate.Parameters)
                                {

                                    if ((parm2.ParameterName == "@pril_LicenseNumber") ||
                                        (parm2.ParameterName == "@prip_LicenseNumber") ||
                                        (parm2.ParameterName == "@prit_LicenseNumber") ||
                                        (parm2.ParameterName == "@pripc_LicenseNumber"))
                                    {

                                        licenseNumber = Convert.ToString(parm2.Value);

                                        if (string.IsNullOrEmpty(licenseNumber))
                                        {
                                            saveRecord = false;
                                            iFailedLoad++;
                                            pacaFile.Errors.Add(pacaFile.FileName + ": No License # specified");

                                        }

                                        if (licenseNumber.StartsWith("Z"))
                                        {
                                            saveRecord = false;
                                            iFailedLoad++;
                                            pacaFile.Errors.Add(pacaFile.FileName + ": License # begins with 'Z' - " + licenseNumber);
                                        }

                                        if (licenseNumber.Length > 8)
                                        {
                                            saveRecord = false;
                                            iFailedLoad++;
                                            pacaFile.Errors.Add(pacaFile.FileName + ": License # is greater than 8 characters - " + licenseNumber);
                                        }
                                    }

                                    if (skipLicenses.Contains(licenseNumber))
                                    {
                                        saveRecord = false;
                                        iFailedLoad++;
                                        pacaFile.Errors.Add(pacaFile.FileName + ": This license # was previously skipped - " + licenseNumber);
                                    }

                                    if (parm2.ParameterName == "@pril_TerminateCode")
                                    {
                                        if (Convert.ToString(parm2.Value) == "0")
                                        {
                                            saveRecord = false;
                                            skipLicenses.Add(licenseNumber);

                                            iFailedLoad++;
                                            pacaFile.Errors.Add(pacaFile.FileName + ": Status Code = No License (0) - " + licenseNumber);
                                        }
                                    }

                                    sbSQL.Append(Environment.NewLine);
                                    sbSQL.Append(parm2.ParameterName);
                                    sbSQL.Append("=");
                                    if (parm2.Value == null)
                                        sbSQL.Append("null");
                                    else
                                    {
                                        sbSQL.Append("'");
                                        sbSQL.Append(parm2.Value.ToString());
                                        sbSQL.Append("'");
                                    }
                                    sbSQL.Append(", ");
                                }
                                //_oLogger.LogMessage(sbSQL.ToString());

                                if (saveRecord)
                                {
                                    cmdCreate.ExecuteNonQuery();

                                    // This return value is the ID of the record inserted
                                    // We don't use it here.
                                    iReturn = Convert.ToInt32(cmdCreate.Parameters["ReturnValue"].Value);
                                    iSuccessLoad++;
                                }
                            }
                            catch (Exception e)
                            {
                                if (csv != null && csv.FieldCount > 1)
                                {
                                    pacaFile.Errors.Add(pacaFile.FileName + ": " + e.Message + " License #: [" + csv[0] + "]");

                                    // If this is for a license record, add it to the skip list
                                    // so we don't bother with any associated trade or principal
                                    // records.
                                    if (pacaFile.Type == PACAFile.FileType.License)
                                        skipLicenses.Add(csv[0]);
                                }
                                else
                                {
                                    pacaFile.Errors.Add(pacaFile.FileName + ": " + e.Message);
                                }

                                iFailedLoad++;
                            }
                        }
                    }

                    if (pacaFile.Type == PACAFile.FileType.Complaints && iCSVRecordCount == 0)
                        szPACAComplaintError += string.Format("There were no records in the latest PACA Complaints file {0}", pacaFile.FileName);
                }

                //if(pacaFile.Type == PACAFile.FileType.Complaints && !string.IsNullOrEmpty(szPACAComplaintError))
                //{
                //    //Send support email if PACA Complaint file is 0-length or has headers but no records
                //    SendMail("PACA Complaint File Issue", szPACAComplaintError);
                //}

                if(pacaFile.Type == PACAFile.FileType.License && !string.IsNullOrEmpty(szPACALicenseError))
                {
                    //Send support email if PACA License file is too large (Defect 6847)
                    SendMail("PACA License File Issue", szPACALicenseError);
                }
            }
            finally {

                pacaFile.SuccessCount = iSuccessLoad;
                pacaFile.FailedCount = iFailedLoad;
                pacaFile.WrongFormatCount = iWrongCount;
            }
        }

        private string timestamp = null;
        private string outputDir = null;
        private PACAFile license = null;
        private PACAFile trade = null;
        private PACAFile principal = null;
        private PACAFile complaints = null;
        private List<string> skipLicenses = new List<string>();
        private string complaintsMsg = string.Empty;

        /// <summary>
        /// This method connects to the PACA FTP server and downloads the three
        /// PACA files.
        /// </summary>
        /// <returns></returns>
        private int downloadPACAFiles()
        {
            int fileCount = 0;
            fileCount += downloadFile(license.FileName);
            fileCount += downloadFile(trade.FileName);
            fileCount += downloadFile(principal.FileName);
            downloadFile(complaints.FileName); //not required -- may not be present -- don't add to fileCount

            if (fileCount != 3) {
                throw new ApplicationException("File download count mismatch.  Expected three (3) core PACA files but only found " + fileCount.ToString() + ".");
            }

            return fileCount;
        }

        /// <summary>
        /// This method downloads the specific file and saves it to disk.
        /// </summary>
        /// <param name="ftpClient"></param>
        /// <param name="url"></param>
        /// <param name="fileName"></param>
        /// <returns></returns>
        private int downloadFile(WebClient ftpClient, string url, string fileName)
        {
            try {
                byte[] fileData = ftpClient.DownloadData(url);

                if (File.Exists(fileName)) {
                    File.Delete(fileName);
                }

                using (FileStream file = File.Create(fileName)) {
                    file.Write(fileData, 0, fileData.Length);
                    file.Close();
                }

                return 1;
            }
            catch (WebException wEx) {
                _oLogger.LogMessage("Error downloading file " + url + ": " + wEx.Message);
                return 0;
            }
        }

        private int downloadFile(string fileName)
        {
            string ftpFile = Path.Combine(Utilities.GetConfigValue("PACAImportFTPFolder"), fileName);
            string downloadFile = Path.Combine(outputDir, fileName);

            try {

                if (File.Exists(downloadFile)) {
                    File.Delete(downloadFile);
                }

                var connectionInfo = new PasswordConnectionInfo(Utilities.GetConfigValue("PACAImportURL"),
                                                                Utilities.GetIntConfigValue("PACAImportFTPPort", 22),
                                                                Utilities.GetConfigValue("PACAImportUserID"),
                                                                Utilities.GetConfigValue("PACAImportPassword"));

                using (SftpClient client = new SftpClient(connectionInfo)) {
                    client.Connect();

                    if (!client.Exists(ftpFile))
                    {
                        if (fileName == complaints.FileName)
                            complaintsMsg = $"The {fileName} file was not found.";

                        return 0;
                    }
                        
                    using (FileStream file = File.OpenWrite(downloadFile)) {
                        client.DownloadFile(ftpFile, file);
                    }
                }

                if (fileName == license.FileName)
                {
                    if (CheckFileSize(downloadFile, Convert.ToInt64(Utilities.GetConfigValue("PACALicenseFileMaxFileSize", "120000"))))
                        throw new ApplicationException($"The PACA License file size exceeds max file threshold of {Utilities.GetConfigValue("PACALicenseFileMaxFileSize", "120000")} bytes.");
                }

                // The complaints file is variable.  It is not always present.
                if (fileName == complaints.FileName)
                    return 0;

                return 1;
            }
            catch (Exception wEx) {
                //_oLogger.LogMessage("Error downloading file " + ftpFile + ": " + wEx.Message);
                //return 0;
                throw new ApplicationException($"Error downloading file {ftpFile}", wEx);
            }
        }

        private bool CheckFileSize(string fileName, long sizeThreshold)
        {
            FileInfo fileInfo = new System.IO.FileInfo(fileName);
            if (fileInfo.Length > sizeThreshold)
                return true;

            return false;
        }

        private string cleanupFiles()
        {
            string zipName = compressFiles();
            File.Delete(Path.Combine(outputDir, license.FileName));
            File.Delete(Path.Combine(outputDir, trade.FileName));
            File.Delete(Path.Combine(outputDir, principal.FileName));

            if (File.Exists(Path.Combine(outputDir, complaints.FileName)))
                File.Delete(Path.Combine(outputDir, complaints.FileName));

            return zipName;
        }

        /// <summary>
        /// Helper method that compresses the PACA Files after processing.
        /// </summary>
        private string compressFiles()
        {
            string zipName = Path.Combine(outputDir, "PACAImport_" + timestamp + ".zip");

            int count = 1;
            while (File.Exists(zipName)) {
                count++;
                zipName = Path.Combine(outputDir, "PACAImport_" + timestamp + "_" + count.ToString() + ".zip");
            }

            using (ZipOutputStream zipOutputStream = new ZipOutputStream(File.Create(zipName))) {
                zipOutputStream.SetLevel(9); // 0-9, 9 being the highest compression

                addZipEntry(zipOutputStream, license.FileName);
                addZipEntry(zipOutputStream, trade.FileName);
                addZipEntry(zipOutputStream, principal.FileName);

                if (File.Exists(Path.Combine(outputDir, complaints.FileName)))
                    addZipEntry(zipOutputStream, complaints.FileName);

                zipOutputStream.Finish();
                zipOutputStream.Close();
            }

            return zipName;
        }

        protected void addZipEntry(ZipOutputStream zipOutputStream, string fileName)
        {
            byte[] buffer = new byte[4096];

            ZipEntry zipEntry = new ZipEntry(fileName);
            zipEntry.DateTime = DateTime.Now;
            zipOutputStream.PutNextEntry(zipEntry);

            using (FileStream fs = File.OpenRead(Path.Combine(outputDir, fileName))) {
                int sourceBytes;
                do {
                    sourceBytes = fs.Read(buffer, 0, buffer.Length);
                    zipOutputStream.Write(buffer, 0, sourceBytes);

                } while (sourceBytes > 0);
            }
        }
    }

    /// <summary>
    /// Helper class that represents a PACA input file.  It has methods that help
    /// populate the parameters for the SQL Command to insert the data.
    /// </summary>
    public class PACAFile
    {
        public enum FileType { License, Principal, Trade, Complaints }

        public string FileName;
        public FileType Type;
        public int FailedCount;
        public int SuccessCount;
        public int WrongFormatCount;

        public List<String> Errors = new List<string>();
        public List<DBParam> Parameters = new List<DBParam>();

        public string StoredProc;
        public int ColumnCount;

        public PACAFile(string fileName, FileType type)
        {
            FileName = fileName;
            Type = type;

            Initialize();
        }

        private void Initialize()
        {
            switch (Type) {
                case FileType.License:

                    StoredProc = "usp_CreateImportPACALicense";
                    
                    if (Utilities.GetBoolConfigValue("PACALicenseDeletedFieldEnabled", false))
                        ColumnCount = 28;  // There is an extra "Deleted" field that we are ignoring for now.
                    else
                        ColumnCount = 27;

                    Parameters.Add(new DBParam("@pril_LicenseNumber", SqlDbType.NVarChar));//license number
                    Parameters.Add(new DBParam("@pril_ExpirationDate", SqlDbType.DateTime));//Expiration date
                    Parameters.Add(new DBParam("@pril_CompanyName", SqlDbType.NVarChar));//customer name
                    Parameters.Add(new DBParam("@pril_CustomerFirstName", SqlDbType.NVarChar));//customer first name
                    Parameters.Add(new DBParam("@pril_CustomerMiddleInitial", SqlDbType.NVarChar));//customer middle initial
                    Parameters.Add(new DBParam("@pril_City", SqlDbType.NVarChar));//city
                    Parameters.Add(new DBParam("@pril_State", SqlDbType.NVarChar));//state
                    Parameters.Add(new DBParam("@pril_Address1", SqlDbType.NVarChar));//address line 1
                    Parameters.Add(new DBParam("PostCode", SqlDbType.NVarChar));//zip 
                    Parameters.Add(new DBParam("@pril_PostCode", SqlDbType.NVarChar));// zip plu
                    Parameters.Add(new DBParam("@pril_TypeFruitVeg", SqlDbType.NVarChar));//type fruit / veg
                    Parameters.Add(new DBParam("@pril_ProfCode", SqlDbType.NVarChar));//type business code
                    Parameters.Add(new DBParam("@pril_OwnCode", SqlDbType.NVarChar));//ownership
                    Parameters.Add(new DBParam("@pril_IncState", SqlDbType.NVarChar));//state incorporated
                    Parameters.Add(new DBParam("@pril_IncDate", SqlDbType.DateTime));//date incorporated
                    Parameters.Add(new DBParam("@pril_MailAddress1", SqlDbType.NVarChar));//mailing address line 1
                    Parameters.Add(new DBParam("@pril_MailCity", SqlDbType.NVarChar));//mailing city
                    Parameters.Add(new DBParam("@pril_MailState", SqlDbType.NVarChar));//mailing state
                    Parameters.Add(new DBParam("MailPostCode", SqlDbType.NVarChar));//mailing zip
                    Parameters.Add(new DBParam("@pril_MailPostCode", SqlDbType.NVarChar));//mailing zip+4
                    Parameters.Add(new DBParam("@pril_Telephone", SqlDbType.NVarChar));//number
                    Parameters.Add(new DBParam("@pril_Email", SqlDbType.NVarChar));
                    Parameters.Add(new DBParam("@pril_WebAddress", SqlDbType.NVarChar));
                    Parameters.Add(new DBParam("@pril_Fax", SqlDbType.NVarChar));//number
                    Parameters.Add(new DBParam("@pril_TerminateDate", SqlDbType.DateTime));//termination date
                    Parameters.Add(new DBParam("@pril_TerminateCode", SqlDbType.NVarChar));//termination code
                    Parameters.Add(new DBParam("@pril_PACARunDate", SqlDbType.DateTime));//run date
                    break;

                case FileType.Principal:

                    StoredProc = "usp_CreateImportPACAPrincipal";
                    ColumnCount = 6;

                    Parameters.Add(new DBParam("@prip_LicenseNumber", SqlDbType.NVarChar));
                    Parameters.Add(new DBParam("@prip_LastName", SqlDbType.NVarChar));
                    Parameters.Add(new DBParam("@prip_Title", SqlDbType.NVarChar));
                    Parameters.Add(new DBParam("@prip_City", SqlDbType.NVarChar));
                    Parameters.Add(new DBParam("@prip_State", SqlDbType.NVarChar));
                    Parameters.Add(new DBParam("@prip_PACARunDate", SqlDbType.DateTime));
                    break;

                case FileType.Trade:

                    StoredProc = "usp_CreateImportPACATrade";
                    ColumnCount = 5;

                    Parameters.Add(new DBParam("@prit_LicenseNumber", SqlDbType.NVarChar));
                    Parameters.Add(new DBParam("@prit_AdditionalTradeName", SqlDbType.NVarChar));
                    Parameters.Add(new DBParam("@prit_City", SqlDbType.NVarChar));
                    Parameters.Add(new DBParam("@prit_State", SqlDbType.NVarChar));
                    Parameters.Add(new DBParam("@prit_PACARunDate", SqlDbType.DateTime));
                    break;

                case FileType.Complaints:
                    StoredProc = "usp_CreateImportPACAComplaint";
                    ColumnCount = 7;

                    Parameters.Add(new DBParam("@pripc_BusinessName", SqlDbType.NVarChar));
                    Parameters.Add(new DBParam("@pripc_LicenseNumber", SqlDbType.NVarChar));
                    Parameters.Add(new DBParam("@pripc_DisInfRepComplaintCount", SqlDbType.Int));
                    Parameters.Add(new DBParam("@pripc_InfRepComplaintCount", SqlDbType.Int));
                    Parameters.Add(new DBParam("@pripc_DisForRepCompaintCount", SqlDbType.Int));
                    Parameters.Add(new DBParam("@pripc_ForRepComplaintCount", SqlDbType.Int));
                    Parameters.Add(new DBParam("@pripc_TotalFormalClaimAmt", SqlDbType.Decimal));

                    break;
            }
        }

        /// <summary>
        /// Create the stored procedure parameters for the loading of a
        /// PACA License Record
        /// </summary>
        /// <param name="cmdCreate"></param>
        public void LoadParameters(SqlCommand cmdCreate)
        {
            string sParamName = null;
            string sParamValue = null;
            string sTempPhone = string.Empty;
            string sTempZip = string.Empty;
            string sAbbreviation = string.Empty;

            Regex digitsOnly = new Regex(@"[^\d]");

            SqlDbType iType = SqlDbType.NVarChar;

            for (int i = 0; i < Parameters.Count; i++) {

                SqlParameter parm = null;
                sParamName = Parameters[i].SPParamName;
                sParamValue = Parameters[i].ParamValue;
                iType = Parameters[i].Type;

                try {

                    // Determine what to do with the input value
                    if (sParamName == null) {
                        // shouldn't ever be
                        continue;
                    }
                    else if (sParamName.Equals("unused")) {
                        // we don't use this field from the input table
                        continue;
                    }

                    // Part 1 of our Zip Code
                    else if (sParamName.Equals("PostCode")) {
                        sTempZip = sParamValue;
                    }

                    // Part 2 of our Zip Code
                    else if (sParamName.Equals("@pril_PostCode")) {
                        if ((!string.IsNullOrEmpty(sParamValue)) &&
                            (sParamValue != "0"))
                            sTempZip += sParamValue;

                        parm = cmdCreate.Parameters.AddWithValue(sParamName, sTempZip);
                        sTempZip = string.Empty;
                    }

                    // Part 1 of our Zip Code
                    else if (sParamName.Equals("MailPostCode")) {
                        sTempZip = sParamValue;
                    }

                    // Part 2 of our Zip Code
                    else if (sParamName.Equals("@pril_MailPostCode")) {
                        if ((!string.IsNullOrEmpty(sParamValue)) &&
                            (sParamValue != "0"))
                            sTempZip += sParamValue;

                        parm = cmdCreate.Parameters.AddWithValue(sParamName, sTempZip);
                        sTempZip = string.Empty;
                    }

                    else if (sParamName.Equals("@pril_Telephone") ||
                             sParamName.Equals("@pril_Fax")) {
                        // Remove all non-numeric characters
                        sTempPhone = string.Empty;
                        if (sParamValue != null)
                            sTempPhone = digitsOnly.Replace(sParamValue, string.Empty);

                        parm = cmdCreate.Parameters.AddWithValue(sParamName, sTempPhone);
                    }

                    else if (sParamName.Equals("@pril_TypeFruitVeg") ||
                             sParamName.Equals("@pril_ProfCode") ||
                             sParamName.Equals("@pril_OwnCode") ||
                             sParamName.Equals("@pril_TerminateCode")) {

                        string family = null;
                        switch (sParamName) {
                            case "@pril_TypeFruitVeg":
                                family = "TypeFruitVegRL";
                                break;
                            case "@pril_ProfCode":
                                family = "ProfCodeRL";
                                break;
                            case "@pril_OwnCode":
                                family = "OwnershipTypeCodeRL";
                                break;
                            case "@pril_TerminateCode":
                                family = "prpa_TerminateCodeRL";
                                break;
                        }

                        sAbbreviation = translateCustomCaption(cmdCreate, family, sParamValue);
                        parm = cmdCreate.Parameters.AddWithValue(sParamName, sAbbreviation);
                        sAbbreviation = string.Empty;
                    }

                    // Translate the state name into an abbreviation.  This is what the 
                    // import logic further downstream expects.
                    else if (sParamName.Equals("@pril_State") ||
                             sParamName.Equals("@pril_MailState") ||
                             sParamName.Equals("@prip_State") ||
                             sParamName.Equals("@prit_State") ||
                             sParamName.Equals("@pril_IncState")) {

                        sAbbreviation = translateState(cmdCreate, sParamValue);
                        parm = cmdCreate.Parameters.AddWithValue(sParamName, sAbbreviation);
                        sAbbreviation = string.Empty;
                    }

                    else if (sParamName.Equals("@prip_LastName")) {

                        string[] tokens = sParamValue.Split(' ');
                        if (tokens.Length == 1) {
                            cmdCreate.Parameters.AddWithValue(sParamName, tokens[0].Trim());
                        }

                        if (tokens.Length == 2) {
                            cmdCreate.Parameters.AddWithValue("@prip_FirstName", tokens[0].Trim());
                            cmdCreate.Parameters.AddWithValue(sParamName, tokens[1].Trim());
                        }

                        if (tokens.Length >= 3) {
                            cmdCreate.Parameters.AddWithValue("@prip_FirstName", tokens[0].Trim());

                            int tokenIndex = 1;
                            if (tokens[1].Trim().Length == 1) {
                                cmdCreate.Parameters.AddWithValue("@prip_MiddleInitial", tokens[1].Trim());
                                tokenIndex = 2;
                            }

                            string tempName = string.Empty;
                            while (tokenIndex < tokens.Length) {
                                if (tempName.Length > 0)
                                    tempName += " ";

                                tempName += tokens[tokenIndex];
                                tokenIndex++;
                            }

                            cmdCreate.Parameters.AddWithValue(sParamName, tempName);
                        }
                    }
                    else {
                        // determine the type and store the sp parameter 
                        if (iType == SqlDbType.NVarChar) //string
                            parm = cmdCreate.Parameters.AddWithValue(sParamName, sParamValue);
                        else if (iType == SqlDbType.Int) //int
                            parm = cmdCreate.Parameters.AddWithValue(sParamName, int.Parse(sParamValue));
                        else if (iType == SqlDbType.Decimal) //decimal
                            parm = cmdCreate.Parameters.AddWithValue(sParamName, decimal.Parse(sParamValue));
                        else if (iType == SqlDbType.DateTime) //date
                        {
                            DateTime dtReturn = InputToDate(sParamValue);
                            // if the date is null, don't add the param; the sp
                            // will set the value to null
                            if (dtReturn != DateTime.MinValue)
                                parm = cmdCreate.Parameters.AddWithValue(sParamName, dtReturn);
                        }
                    }

                    if ((sParamName == "@pril_LicenseNumber") ||
                        (sParamName == "@prip_LicenseNumber") ||
                        (sParamName == "@prit_LicenseNumber") ||
                        (sParamName == "@pripc_LicenseNumber")) {

                        if (string.IsNullOrEmpty(sParamValue))
                            return;

                        if (sParamValue.StartsWith("Z"))
                            return;
                    }

                }
                catch (Exception eX) {
                    string exMsg = sParamName + "=" + sParamValue + ": " + eX.Message;
                    throw new ApplicationException(exMsg);
                }
            }
        }

        /// <summary>
        /// Helper method that converts the PACA data format
        /// into a Date/Time structure.
        /// </summary>
        /// <param name="sDate"></param>
        /// <returns></returns>
        private DateTime InputToDate(string sDate)
        {
            DateTime dtReturn = DateTime.MinValue;
            if (sDate == null || sDate.Trim().Length == 0) {
                return dtReturn;
            }

            try {
                //// these values come in the format YYYY-MM-DD
                int iYear = int.Parse(sDate.Substring(0, 4));
                int iMonth = int.Parse(sDate.Substring(5, 2));
                int iDay = int.Parse(sDate.Substring(8, 2));

                // Sanity check
                if (iYear < 1900)
                    throw new Exception("Invalid date specified: " + sDate);

                dtReturn = new DateTime(iYear, iMonth, iDay);

                return dtReturn;
            }
            catch {
                throw new Exception("Invalid date specified: " + sDate);
            }
        }

        private Dictionary<string, string> _stateCache = new Dictionary<string, string>();

        private string translateState(SqlCommand cmdCreate, string stateName)
        {
            if (string.IsNullOrEmpty(stateName))
                return null;

            // If the state is only two characters, assume
            // it is an abbreviation.
            if (stateName.Length == 2)
                return stateName;

            if (!_stateCache.ContainsKey(stateName)) {

                SqlCommand sqlCommand = new SqlCommand("SELECT prst_Abbreviation FROM PRState WHERE prst_State=@State");
                sqlCommand.Connection = cmdCreate.Connection;
                sqlCommand.Transaction = cmdCreate.Transaction;
                sqlCommand.Parameters.AddWithValue("State", stateName);

                object result = sqlCommand.ExecuteScalar();
                if ((result != DBNull.Value) && (result != null))
                    _stateCache.Add(stateName, Convert.ToString(result));
                else {

                    // See if this is a country.
                    string countryAbbr = translateCountry(cmdCreate, stateName);
                    if (countryAbbr == null)
                        throw new Exception("Unknown State/Country specified: " + stateName);
                    else
                        return countryAbbr;
                }
            }

            return _stateCache[stateName];
        }

        private Dictionary<string, string> _countryCache = new Dictionary<string, string>();
        private string translateCountry(SqlCommand cmdCreate, string countryName)
        {
            if (string.IsNullOrEmpty(countryName))
                return null;


            if (!_countryCache.ContainsKey(countryName)) {

                SqlCommand sqlCommand = new SqlCommand("SELECT prcn_IATACode FROM PRCountry WHERE prcn_Country=@Country");
                sqlCommand.Connection = cmdCreate.Connection;
                sqlCommand.Transaction = cmdCreate.Transaction;
                sqlCommand.Parameters.AddWithValue("Country", countryName);

                object result = sqlCommand.ExecuteScalar();
                if ((result != DBNull.Value) && (result != null))
                    _countryCache.Add(countryName, Convert.ToString(result));
                else
                    return null;
            }

            return _countryCache[countryName];
        }

        private Dictionary<string, string> _customCaptionCache = new Dictionary<string, string>();

        private string translateCustomCaption(SqlCommand cmdCreate, string family, string meaning)
        {
            if (string.IsNullOrEmpty(meaning))
                return null;

            string key = family + ":" + meaning;

            if (!_customCaptionCache.ContainsKey(key)) {

                SqlCommand sqlCommand = new SqlCommand("SELECT capt_code FROM Custom_Captions WHERE capt_Family=@Family AND capt_US = @Meaning");
                sqlCommand.Connection = cmdCreate.Connection;
                sqlCommand.Transaction = cmdCreate.Transaction;
                sqlCommand.Parameters.AddWithValue("Family", family);
                sqlCommand.Parameters.AddWithValue("Meaning", meaning);

                object result = sqlCommand.ExecuteScalar();
                if ((result != DBNull.Value) && (result != null))
                    _customCaptionCache.Add(key, Convert.ToString(result));
                else
                    throw new Exception("Unknown field value specified: " + family + "-" + meaning);

            }

            return _customCaptionCache[key];
        }
    }

    public class DBParam
    {
        public string SPParamName;
        public SqlDbType Type;
        public string ParamValue;

        public DBParam(string SPParamName, SqlDbType Type)
        {
            this.SPParamName = SPParamName;
            this.Type = Type;
        }

        public DBParam(string SPParamName, SqlDbType Type, string ParamValue)
        {
            this.SPParamName = SPParamName;
            this.Type = Type;
            this.ParamValue = ParamValue;
        }
    }
}