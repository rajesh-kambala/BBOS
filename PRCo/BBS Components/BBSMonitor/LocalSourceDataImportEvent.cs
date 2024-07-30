/***********************************************************************
 Copyright Blue Book Services, Inc. 2021-2023

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: LocalSourceDataImportEvent.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using LocalSourceImporter;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using System.Net;
using System.Timers;
using Renci.SshNet;
using Renci.SshNet.Sftp;


using TSI.Utils;

namespace PRCo.BBS.BBSMonitor
{

    /// <summary>
    /// Event handler that calculates the number of companies assigned
    /// to each classficiation and stores the results in the PRClassification
    /// table.  
    /// </summary>
    public class LocalSourceDataImportEvent : BBSMonitorEvent
    {

        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex)
        {
            _szName = "LocalSourceDataImportEvent";

            base.Initialize(iIndex);

            try
            {
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("LocalSourceDataImportInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("LocalSourceDataImport Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("LocalSourceDataImportStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

                _oLogger.LogMessage("LocalSourceDataImport Start: " + _dtNextDateTime.ToString());

            }
            catch (Exception e)
            {
                LogEventError("Error initializing LocalSourceDataImport event.", e);
                throw;
            }
        }

        

        /// <summary>
        /// Go update the classification company counts.
        /// </summary>
        override public void ProcessEvent()
        {

            DateTime dtExecutionStartDate = DateTime.Now;
            string msg = string.Empty;
            try
            {
                string outputDir = Path.Combine(Utilities.GetConfigValue("LocalSourceDataImportFolder"), DateTime.Today.ToString("yyyy-MM-dd"));
                if (!Directory.Exists(outputDir))
                    Directory.CreateDirectory(outputDir);

                List<string> files = DownloadFiles_Sftp(outputDir);

                if (files.Count == 0)
                {
                    Directory.Delete(outputDir);
                    return;
                }
                else
                {
                    msg = "The following Local Source data files have been downloaded to " + outputDir + ".\n\n";
                    foreach (string file in files)
                    {
                        msg += " - " + file + Environment.NewLine;
                    }
                }

                //Defect 6876 - auto-process the imported files
                Importer importer = new Importer();

                foreach (string file in files)
                {
                    importer.Commit = Utilities.GetBoolConfigValue("LocalSourceDataImportCommit", true);
                    importer.ProcessNonFactorCompanies = Utilities.GetBoolConfigValue("LocalSourceDataImportProcessNonFactorCompanies", true);
                    importer.OutputPath = outputDir;
                    importer.OutputFile = Path.Combine(importer.OutputPath, "LocalSource Import.txt");
                    importer.FileNameTimestamp = DateTime.Now.ToString("yyyyMMdd_hhmmss");
                    importer.ExecuteImport(file);

                    UploadFile_Sftp(importer.FileNewMatches);

                    using (SqlConnection oConn = new SqlConnection(GetConnectionString()))
                    {
                        oConn.Open();
                        string multipleMatchFileName = Path.GetFileName(importer.FileMulitpleMatches);
                        byte[] abAttachment = File.ReadAllBytes(importer.FileMulitpleMatches);

                        SendInternalEmail(oConn,
                                            "LocalSource Data Import Multiple CRM Match File",
                                            Utilities.GetConfigValue("LocalSourceDataImportMultipleCRMMatchEmail", "korlowski@bluebookservices.com"),
                                            abAttachment, multipleMatchFileName, "LocalSource Data Import Event");
                    }
                }


                if (Utilities.GetBoolConfigValue("LocalSourceDataImportWriteResultsToEventLog", true))
                    _oBBSMonitorService.LogEvent("LocalSourceDataImport Executed Successfully." + msg);

                if (Utilities.GetBoolConfigValue("LocalSourceDataImportSendResultsToSupport", true))
                    SendMail("LocalSourceDataImport Success", "LocalSourceDataImport Executed Successfully." + msg);

            }
            catch (Exception e)
            {
                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("Error Procesing LocalSourceDataImport Event.", e);
            }
        }

        private List<string> DownloadFiles_Sftp(string outputDir)
        {
            var connectionInfo = new PasswordConnectionInfo(Utilities.GetConfigValue("LocalSourceDataImportFTPServer"),
                                                            Utilities.GetConfigValue("LocalSourceDataImportFTPUsername"),
                                                            Utilities.GetConfigValue("LocalSourceDataImportFTPPassword"));

            List<string> files = new List<string>();
            string fileExtension = Utilities.GetConfigValue("LocalSourceDataImportFileExtension", ".txt");
            string fileStartsWith = Utilities.GetConfigValue("LocalSourceDataImportFileStartsWith", "blue book licensing project_us_final file_");

            using (SftpClient client = new SftpClient(connectionInfo))
            {
                client.Connect();

                System.Collections.Generic.IEnumerable<SftpFile> lstFiles = client.ListDirectory("/");
                foreach (SftpFile ftpFile in lstFiles)
                {
                    if ((ftpFile.FullName.ToLower().EndsWith(fileExtension)) &&
                        (ftpFile.FullName.ToLower().StartsWith("/" + fileStartsWith)))
                    {
                        string targetFile = Path.Combine(outputDir, ftpFile.FullName.Substring(1));

                        using (var file = File.OpenWrite(targetFile))
                        {
                            client.DownloadFile(ftpFile.FullName, file);
                        }

                        files.Add(targetFile);

                        //Make sure via config that we need to move this file --- should be true on prod, and probably false on qa/test
                        if (Utilities.GetBoolConfigValue("LocalSourceDataImportProcessedMove"))
                        {
                            //Now move it to sub-folder Lumber_Scores_Processed
                            string strFolderRemoteProcessed = ftpFile.FullName.Substring(0, ftpFile.FullName.IndexOf(ftpFile.Name));
                            strFolderRemoteProcessed = Path.Combine(strFolderRemoteProcessed, "/processed");
                            strFolderRemoteProcessed = strFolderRemoteProcessed.Replace("\\", "/");

                            //Move file from old location to new location using SFTP commands
                            string strNewFileName = Path.Combine(strFolderRemoteProcessed, ftpFile.Name);
                            strNewFileName = strNewFileName.Replace("\\", "/");
                            ftpFile.MoveTo(strNewFileName);
                        }
                    }
                }

                client.Disconnect();
            }

            return files;
        }

        private void UploadFile_Sftp(string fileName)
        {
            var connectionInfo = new PasswordConnectionInfo(Utilities.GetConfigValue("LocalSourceDataImportFTPServer"),
                                                           Utilities.GetConfigValue("LocalSourceDataImportFTPUsername"),
                                                           Utilities.GetConfigValue("LocalSourceDataImportFTPPassword"));

            try
            {
                using (SftpClient client = new SftpClient(connectionInfo))
                {
                    client.Connect();

                    // Read our file into memory
                    using (FileStream stream = File.OpenRead(fileName))
                    {
                        client.UploadFile(stream, Path.GetFileName(fileName));
                    }

                    client.Disconnect();
                }
            }
            catch (WebException wEx)
            {
                throw new ApplicationException($"Error uploading file {fileName} to {Utilities.GetConfigValue("LocalSourceDataImportFTPServer")}.  {wEx.Message}", wEx);
            }
        }
    }
}
