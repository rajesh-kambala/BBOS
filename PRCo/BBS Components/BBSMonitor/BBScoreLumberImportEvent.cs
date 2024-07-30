/***********************************************************************
 Copyright Blue Book Services, Inc. 2016-2020

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: BBScoreLumberEvent.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Data.SqlClient;
using System.IO;
using System.Timers;
using LumenWorks.Framework.IO.Csv;
using Renci.SshNet;
using Renci.SshNet.Sftp;
using TSI.Utils;


namespace PRCo.BBS.BBSMonitor
{
    public class BBScoreLumberImportEvent : BBSMonitorEvent
	{
        const string BBSCORE_LUMBER_IMPORT_V2 = "BBScoreLumberImportV2";
        const string BB_SCORE_LUMBER_FILE_EMAIL = "BBScoreLumberFileEmail";

        /// <summary>
        /// Runs the BB Score Lumber Import process
        /// </summary>
        override public void Initialize(int iIndex)
		{
			_szName = "BBScoreLumberImportEvent";

			base.Initialize(iIndex);

			try
			{
				_lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("BBScoreLumberImportInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
				_oLogger.LogMessage("BBScoreLumberImport Interval: " + _lEventInterval.ToString());

				_dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("BBScoreLumberImportStartDateTime"));
				_dtNextDateTime = _dtStartDateTime;

				_oEventTimer = new System.Timers.Timer();
				_oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
				ConfigureTimer(false);

				_oLogger.LogMessage("BBScoreLumberImport Start: " + _dtNextDateTime.ToString());

			}
			catch(Exception e)
			{
				LogEventError("Error initializing BBScoreLumberImport event.", e);
				throw;
			}
		}

		/// <summary>
		/// Run import process.
		/// </summary>
		override public void ProcessEvent()
		{
			SqlConnection oConn = new SqlConnection(GetConnectionString());
			const string CUSTOM_CAPTION = "LastBBScoreRunDate_Lumber"; //was prlumberscoreimport_LastRun

            try
			{
				string importFolder = Utilities.GetConfigValue("BBScoreLumberImportFolder");

                oConn.Open();

                //Go out to Open Data Group SFTP server and see if there are any new lumber_scores_yyyymmdd.csv files
                OpenDataGroup_TransferNewLumberScores();

				foreach(string strCSVFile in Directory.GetFiles(importFolder, "*.csv"))
				{
                    //Skip file based on _v2_ and the configuration value
                    if (Utilities.GetBoolConfigValue(BBSCORE_LUMBER_IMPORT_V2, false))
                    {
                        if (!strCSVFile.Contains("_v2_"))
                        {
                            _oLogger.LogMessage($"Skipping {strCSVFile} because it's not V2 and we are in V2 configuration.");
                            continue;
                        }
                    }
                    else
                    {
                        if (strCSVFile.Contains("_v2_"))
                        {
                            _oLogger.LogMessage($"Skipping {strCSVFile} because it's V2 and we're not in V2 configuration.");
                            continue;
                        }
                    }

                    //Import new BBScore data from CSV file that was found
                    _oLogger.LogMessage($"Processing new BBScore data from {strCSVFile}");

                    //Before importing a file, check to see if any records exist with that prbs_Date value.
                    //Prevents situation when I erroneously loaded the January file several times.
                    //If we find the file has already been loaded, let’s throw an exception.
                    DateTime dtFirstScoreDate = GetFirstScoreDate(strCSVFile, oConn);
                    if (ScoreRecordCount(dtFirstScoreDate, oConn) > 0)
                        throw new Exception(String.Format("Records already existed on {0}", dtFirstScoreDate.ToString()));

                    // start trans, pass into import, and rollback all if anything fails
                    SqlTransaction oTran = null;

                    try
                    {
                        oTran = oConn.BeginTransaction();
                        if (Utilities.GetBoolConfigValue(BBSCORE_LUMBER_IMPORT_V2, false))
                            ImportBBScoreFileV2(strCSVFile, oConn, oTran);
                        else
                            ImportBBScoreFile(strCSVFile, oConn, oTran);

                        oTran.Commit();
                    }
                    catch(Exception)
                    {
                        oTran.Rollback();
                        throw;
                    }

                    byte[] abAttachment = File.ReadAllBytes(strCSVFile);
                    MoveFileToProcessedFolder(strCSVFile);

                    //FINALIZE
                    UpdateDateTimeCustomCaption(oConn, CUSTOM_CAPTION, DateTime.Now);

                    if (Utilities.GetBoolConfigValue("BBScoreLumberImportWriteResultsToEventLog", true))
                        _oBBSMonitorService.LogEvent(String.Format("Lumber BBScore data was successfully imported for {0}", strCSVFile));

                    if (Utilities.GetBoolConfigValue("BBScoreLumberImportSendResultsToSupport", true))
                        SendMail("Lumber BBScore Import Success", String.Format("Lumber BBScore data was successfully imported for {0}", strCSVFile));

                    // Regardless of the config flag, look for a new BBScoreLumberFileEmail config value.
                    // If it exists, send the downloaded lumber BB Score file to the address.
                    // Include the message “The attached {filename} file was imported into CRM.”
                    string szBBScoreLumberFileEmail = Utilities.GetConfigValue(BB_SCORE_LUMBER_FILE_EMAIL, "");

                    if (!string.IsNullOrEmpty(szBBScoreLumberFileEmail))
                    {
                        string azFileName = new FileInfo(strCSVFile).Name;
                        string szSubject = $"Attached {azFileName} Imported into CRM";
                        SendInternalEmail(oConn, szSubject, szBBScoreLumberFileEmail, abAttachment, azFileName, "BBScore Lumber Import Event");
                    }

                }
            }
			catch(Exception e)
			{
				LogEventError("Error Procesing BBScoreLumberImport Event inside ProcessEvent.", e);
			}
			finally
			{
				if(oConn != null)
					oConn.Close();

				oConn = null;
			}
		}

        private void OpenDataGroup_TransferNewLumberScores()
		{
			string importFolder = Utilities.GetConfigValue("BBScoreLumberImportFolder");
			string ftpURL = Utilities.GetConfigValue("BBScoreLumberImportFTPServer", "dropbox.modelop.com");

			var connectionInfo = new PasswordConnectionInfo(ftpURL,
				Utilities.GetIntConfigValue("BBScoreLumberImportFTPPort", 9210),
				Utilities.GetConfigValue("BBScoreLumberImportFTPUsername"),
				Utilities.GetConfigValue("BBScoreLumberImportFTPPassword"));

            string szFullName;
            if (Utilities.GetBoolConfigValue(BBSCORE_LUMBER_IMPORT_V2, false))
                szFullName = "lumber_v2_scores_";
            else
                szFullName = "lumber_scores_";

            using (SftpClient client = new SftpClient(connectionInfo))
			{
                client.Connect();

                System.Collections.Generic.IEnumerable<SftpFile> lstFiles = client.ListDirectory("/data/");
				foreach(SftpFile lumberFile in lstFiles)
				{
					if(lumberFile.FullName.StartsWith($"/data/{szFullName}")) //originally /data/lumber_scores_
                    {
						//We have a lumber score file that we want to pull down and then delete from FTP server
						string strFilenameLocal = Path.Combine(importFolder, lumberFile.Name);
						using(var file = File.OpenWrite(strFilenameLocal))
						{
							client.DownloadFile(lumberFile.FullName, file);
						}

						//Make sure via config that we need to move this file --- should be true on prod, and probably false on qa/test
						if(Utilities.GetBoolConfigValue("BBScoreLumberImportMoveFTPFile"))
						{
							//Now move it to sub-folder Lumber_Scores_Processed
							string strFolderRemoteProcessed = lumberFile.FullName.Substring(0, lumberFile.FullName.IndexOf(lumberFile.Name));
							strFolderRemoteProcessed = Path.Combine(strFolderRemoteProcessed, "Lumber_Scores_Processed");
							strFolderRemoteProcessed = strFolderRemoteProcessed.Replace("\\", "/");

                            //Move file from old location to new location using SFTP commands
                            string strNewFileName = Path.Combine(strFolderRemoteProcessed, lumberFile.Name);
                            strNewFileName = strNewFileName.Replace("\\", "/");
                            lumberFile.MoveTo(strNewFileName);
						}
					}
				}

				client.Disconnect();
			}
		}

        protected const string SQL_UPDATE_BBSCORE_CURRENT_FLAG = "UPDATE PRBBScore SET prbs_Current = NULL FROM Company WHERE prbs_CompanyID = comp_CompanyID AND comp_PRIndustryType = 'L') AND prbs_Current = 'Y' AND prbs_Rundate != @prbs_RunDate";

        private int ScoreRecordCount(DateTime dtScoreDate, SqlConnection oConn)
        {
            // We need to add an industry check as to not accidentally retreive a produce record
            string strSQL = "SELECT COUNT(*) FROM PRBBScore INNER JOIN Company on Comp_CompanyId = prbs_CompanyId WHERE prbs_Date = @prbsDate AND comp_PRIndustryType = 'L'";

            SqlCommand oSQLCommand = new SqlCommand(strSQL, oConn);
            oSQLCommand.Parameters.AddWithValue("@prbsDate", dtScoreDate);
            int intScoreCount = (int)oSQLCommand.ExecuteScalar();

            return intScoreCount;
        }

        private DateTime GetFirstScoreDate(string strCSVFile, SqlConnection oConn)
        {
            string strFirstScoreDate = String.Empty;
            DateTime dtFirstScoreDate;

            using (CsvReader csv = new CsvReader(new StreamReader(strCSVFile), true))
            {
                csv.MissingFieldAction = MissingFieldAction.ReplaceByNull;

                //validate field headers that they are what we expect
                string[] lstFieldHeaders = csv.GetFieldHeaders();

                while (csv.ReadNextRecord())
                {
                    string strSubjectID ;
                    string strModel1Score;
                    string strModel2Score;
                    string strScoreDate;

                    if (Utilities.GetBoolConfigValue(BBSCORE_LUMBER_IMPORT_V2, false))
                    {
                        strSubjectID = csv["SubjectID"];
                        strModel1Score = csv["predicted_credit_score"];
                        strScoreDate = csv["scoring_date"];
                    }
                    else
                    {
                        strSubjectID = csv["SubjectID"];
                        strModel1Score = csv["Model1Score"]; 
                        strModel2Score = csv["Model2Score"]; 
                        strScoreDate = csv["ScoreDate"]; 
                    }

                    strFirstScoreDate = strScoreDate;
                    dtFirstScoreDate = DateTime.Parse(strFirstScoreDate);
                    return dtFirstScoreDate;
                }
            }

            throw new Exception("Unable to obtain the ScoreDate from this file.  It should be in the 4th column.");
        }

        private void ImportBBScoreFile(string strCSVFile, SqlConnection oConn, SqlTransaction oTran)
        {
            string strFirstScoreDate = String.Empty;
            DateTime dtFirstScoreDate;

            //Example SQL: INSERT INTO PRBBScore (prbs_CompanyId, prbs_Date, prbs_BBScore, prbs_NewBBScore) VALUES (100073, '01/01/2016', 930, 918)
            using (CsvReader csv = new CsvReader(new StreamReader(strCSVFile), true))
            {
                csv.MissingFieldAction = MissingFieldAction.ReplaceByNull;

                //validate field headers that they are what we expect
                string[] lstFieldHeaders = csv.GetFieldHeaders();
                bool blnHeadersCorrect = false;

                if (lstFieldHeaders.Length >= 4)
                {
                    if (lstFieldHeaders[0] == "SubjectID" &&
                         lstFieldHeaders[1] == "Model1Score" &&
                         lstFieldHeaders[2] == "Model2Score" &&
                         lstFieldHeaders[3] == "ScoreDate")
                        blnHeadersCorrect = true;
                }

                if (!blnHeadersCorrect)
                {
                    _oLogger.LogMessage(String.Format("File did not have the correct headers and doesn't conform to expected format: {0}", strCSVFile));
                    return;
                }

                while (csv.ReadNextRecord())
                {
                    string strSubjectID = csv["SubjectID"];
                    string strModel1Score = csv["Model1Score"];
                    string strModel2Score = csv["Model2Score"];
                    string strScoreDate = csv["ScoreDate"];

                    if (strFirstScoreDate == String.Empty)
                        strFirstScoreDate = strScoreDate; //used later after all records are imported to do the mass update of Current fields

                    DateTime dtScoreDate = DateTime.Parse(strScoreDate); //current score date to use

                    //See if the company is a lumber company -- if not, skip this record
                    string RETRIEVE_COMPANY_RECORD = string.Format("SELECT COUNT(*) FROM Company WITH (NOLOCK) WHERE Comp_CompanyId = {0} AND Comp_PRIndustryType = 'L'", strSubjectID);
                    SqlCommand oCompanyCommand = new SqlCommand(RETRIEVE_COMPANY_RECORD, oConn, oTran);
                    int intLumberCompanyCount = (int)oCompanyCommand.ExecuteScalar();
                    if (intLumberCompanyCount == 0)
                        continue;

                    //Example: INSERT INTO PRBBScore (prbs_CompanyId, prbs_Date, prbs_BBScore, prbs_NewBBScore) VALUES (100073, '01/01/2016', 930, 918)
                    //string strSQL = String.Format("INSERT INTO PRBBScore (prbs_CompanyId, prbs_Date, prbs_BBScore, prbs_NewBBScore) VALUES ({0}, '{1}', {2}, {3})", strSubjectID, strScoreDate, strModel1Score, strModel2Score);
                    string strSQL = "INSERT INTO PRBBScore (prbs_CompanyId, prbs_Date, prbs_RunDate, prbs_BBScore, prbs_NewBBScore) VALUES (@CompanyId, @ScoreDate, @ScoreDate, @Model1Score, @Model2Score)";

                    SqlCommand oSQLCommand = new SqlCommand(strSQL, oConn, oTran);
                    oSQLCommand.Parameters.AddWithValue("@CompanyId", strSubjectID);
                    oSQLCommand.Parameters.AddWithValue("@ScoreDate", dtScoreDate);
                    oSQLCommand.Parameters.AddWithValue("@Model1Score", strModel1Score);
                    oSQLCommand.Parameters.AddWithValue("@Model2Score", strModel2Score);
                    oSQLCommand.ExecuteNonQuery();
                }
            }

            //After inserting all of the lumber BBScore records, we should execute the following query, but changing the industry criteria to be for Lumber, i.e. ‘L’.  The run date should be the value used to populate the prbs_Date value for the current file.
            //protected const string SQL_UPDATE_BBSCORE_CURRENT_FLAG = "UPDATE PRBBScore SET prbs_Current = NULL FROM Company WHERE prbs_CompanyID = comp_CompanyID AND comp_PRIndustryType IN ('L') AND prbs_Current = 'Y' AND prbs_Rundate != @prbs_RunDate ";
            dtFirstScoreDate = DateTime.Parse(strFirstScoreDate);

            string SQL_UPDATE_BBSCORE_CURRENT_FLAG = "UPDATE PRBBScore SET prbs_Current = NULL FROM Company WHERE prbs_CompanyID = comp_CompanyID AND comp_PRIndustryType IN ('L') AND prbs_Current = 'Y' AND prbs_Rundate != @prbs_RunDate";
            SqlCommand oDBCommand = new SqlCommand(SQL_UPDATE_BBSCORE_CURRENT_FLAG, oConn, oTran);
            oDBCommand.Parameters.AddWithValue("@prbs_RunDate", dtFirstScoreDate);
            oDBCommand.ExecuteNonQuery();

            oDBCommand = new SqlCommand("usp_UpdateBBScoreStatistics", oConn, oTran);
            oDBCommand.CommandType = System.Data.CommandType.StoredProcedure;
            oDBCommand.Parameters.AddWithValue("@RunDate", dtFirstScoreDate);
            oDBCommand.ExecuteNonQuery();
        }
        
        private void ImportBBScoreFileV2(string strCSVFile, SqlConnection oConn, SqlTransaction oTran)
        {
            string strFirstScoreDate = String.Empty;
            DateTime dtFirstScoreDate;

            //Example SQL: INSERT INTO PRBBScore (prbs_CompanyId, prbs_Date, prbs_BBScore) VALUES (100073, '01/01/2016', 930)
            using (CsvReader csv = new CsvReader(new StreamReader(strCSVFile), true))
            {
                csv.MissingFieldAction = MissingFieldAction.ReplaceByNull;

                //validate field headers that they are what we expect
                string[] lstFieldHeaders = csv.GetFieldHeaders();
                bool blnHeadersCorrect = false;

                if (lstFieldHeaders.Length >= 12)
                {
                    if (lstFieldHeaders[0] == "SubjectID" &&
                         lstFieldHeaders[10] == "predicted_credit_score" &&
                         lstFieldHeaders[11] == "scoring_date")
                        blnHeadersCorrect = true;
                }

                if (!blnHeadersCorrect)
                {
                    _oLogger.LogMessage(String.Format("File did not have the correct headers and doesn't conform to expected V2 format: {0}", strCSVFile));
                    return;
                }

                while (csv.ReadNextRecord())
                {
                    string strSubjectID = csv["SubjectID"];
                    string strModel1Score = csv["predicted_credit_score"];
                    string strScoreDate = csv["scoring_date"];

                    if (strFirstScoreDate == String.Empty)
                        strFirstScoreDate = strScoreDate; //used later after all records are imported to do the mass update of Current fields

                    DateTime dtScoreDate = DateTime.Parse(strScoreDate); //current score date to use

                    //See if the company is a lumber company -- if not, skip this record
                    string RETRIEVE_COMPANY_RECORD = string.Format("SELECT COUNT(*) FROM Company WITH (NOLOCK) WHERE Comp_CompanyId = {0} AND Comp_PRIndustryType = 'L'", strSubjectID);
                    SqlCommand oCompanyCommand = new SqlCommand(RETRIEVE_COMPANY_RECORD, oConn, oTran);
                    int intLumberCompanyCount = (int)oCompanyCommand.ExecuteScalar();
                    if (intLumberCompanyCount == 0)
                        continue;

                    //Example: INSERT INTO PRBBScore (prbs_CompanyId, prbs_Date, prbs_BBScore) VALUES (100073, '01/01/2016', 930)
                    string strSQL = "INSERT INTO PRBBScore (prbs_CompanyId, prbs_Date, prbs_RunDate, prbs_BBScore) VALUES (@CompanyId, @ScoreDate, @ScoreDate, @Model1Score)";

                    SqlCommand oSQLCommand = new SqlCommand(strSQL, oConn, oTran);
                    oSQLCommand.Parameters.AddWithValue("@CompanyId", strSubjectID);
                    oSQLCommand.Parameters.AddWithValue("@ScoreDate", dtScoreDate); //scoring_date
                    oSQLCommand.Parameters.AddWithValue("@Model1Score", strModel1Score); //predicted_credit_score
                    oSQLCommand.ExecuteNonQuery();
                }
            }

            //After inserting all of the lumber BBScore records, we should execute the following query, but changing the industry criteria to be for Lumber, i.e. ‘L’.  The run date should be the value used to populate the prbs_Date value for the current file.
            //protected const string SQL_UPDATE_BBSCORE_CURRENT_FLAG = "UPDATE PRBBScore SET prbs_Current = NULL FROM Company WHERE prbs_CompanyID = comp_CompanyID AND comp_PRIndustryType IN ('L') AND prbs_Current = 'Y' AND prbs_Rundate != @prbs_RunDate ";
            dtFirstScoreDate = DateTime.Parse(strFirstScoreDate);

            string SQL_UPDATE_BBSCORE_CURRENT_FLAG = "UPDATE PRBBScore SET prbs_Current = NULL FROM Company WHERE prbs_CompanyID = comp_CompanyID AND comp_PRIndustryType IN ('L') AND prbs_Current = 'Y' AND prbs_Rundate != @prbs_RunDate";
            SqlCommand oDBCommand = new SqlCommand(SQL_UPDATE_BBSCORE_CURRENT_FLAG, oConn, oTran);
            oDBCommand.Parameters.AddWithValue("@prbs_RunDate", dtFirstScoreDate);
            oDBCommand.ExecuteNonQuery();

            oDBCommand = new SqlCommand("usp_UpdateBBScoreStatistics", oConn, oTran);
            oDBCommand.CommandType = System.Data.CommandType.StoredProcedure;
            oDBCommand.Parameters.AddWithValue("@RunDate", dtFirstScoreDate);
            oDBCommand.ExecuteNonQuery();
        }

        private void MoveFileToProcessedFolder(string strCSVFile)
		{
			if(File.Exists(strCSVFile))
			{
				string strPath = Path.GetDirectoryName(strCSVFile);
				string strFileName = Path.GetFileName(strCSVFile);
                string strProcessedFolder = Path.Combine(strPath, "Processed");

                // If the "Processed" folder does not exist, create the folder.
                if (!Directory.Exists(strProcessedFolder))
                    Directory.CreateDirectory(strProcessedFolder);

                string strNewFileName = Path.Combine(strProcessedFolder, strFileName);

				try
				{
                    if (File.Exists(strNewFileName))
                        File.Delete(strNewFileName);

					File.Move(strCSVFile, strNewFileName);
				}
				catch(Exception ex)
				{
					throw new Exception(String.Format("Unable to move file {0} to {1}", strCSVFile, strNewFileName), ex);
				}
			}
		}
	}
}