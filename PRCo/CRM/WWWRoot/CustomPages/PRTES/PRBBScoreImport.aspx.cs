/***********************************************************************
 Copyright Produce Reporter Company 2006-2021

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: PRBBScoreImport
 Description:	

 Notes:
 * 2008-05-06 TME
 *		Removed fields P80Surveys and P95Surveys from the import.
 * 2021-10-05 CHW
 *      Refactored for the new file format.  
 *      Implemented optimizations substantially improving performance.
***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using System.Text;

namespace PRCo.BBS.CRM {

    /// <summary>
    /// Provides the functionality to load the BB Score data from
    /// OpenData
    /// </summary>
    public partial class PRBBScoreImport : PageBase {

        protected const string SQL_INSERT_BBSCORE_OLD =
            @"INSERT INTO PRBBScore (prbs_CreatedBy,prbs_CreatedDate,prbs_UpdatedBy,prbs_UpdatedDate,prbs_TimeStamp,prbs_CompanyId,prbs_Date,prbs_P90Surveys,prbs_MinimumTradeReportCount,prbs_BBScore,prbs_NewBBScore,prbs_ConfidenceScore,prbs_Recency,prbs_ObservationPeriodTES,prbs_RecentTES,prbs_Model,prbs_RunDate,prbs_IndustryAve, prbs_IndustryPercentile) 
              VALUES (@prbs_CreatedBy,GETDATE(),@prbs_UpdatedBy,GETDATE(),GETDATE(),@prbs_CompanyId, @prbs_Date,@prbs_P90Surveys,@prbs_MinimumTradeReportCount,@prbs_BBScore,@prbs_NewBBScore,@prbs_ConfidenceScore,@prbs_Recency,@prbs_ObservationPeriodTES,@prbs_RecentTES,@prbs_Model,@prbs_RunDate, @prbs_IndustryAve, @prbs_IndustryPercentile)";

        protected const string SQL_INSERT_BBSCORE =
            @"INSERT INTO PRBBScore (prbs_CompanyId,prbs_Date,prbs_MinimumTradeReportCount,prbs_BBScore,prbs_ConfidenceScore,prbs_Recency,prbs_Model,prbs_RunDate,prbs_IndustryAve, prbs_IndustryPercentile,
					   prbs_ARLag, prbs_ARNage, prbs_ARScore, prbs_ARNagePercentile, prbs_ARWeight, prbs_ARStatisticalWeight,
					   prbs_SurveyLag, prbs_SurveyNage, prbs_SurveyScore, prbs_SurveyNagePercentile, prbs_SurveyWeight, prbs_SurveyStatisticalWeight,
					   prbs_CreatedBy,prbs_CreatedDate,prbs_UpdatedBy,prbs_UpdatedDate,prbs_TimeStamp) 
              VALUES ( @prbs_CompanyId, @prbs_Date,@prbs_MinimumTradeReportCount,@prbs_BBScore,@prbs_ConfidenceScore,@prbs_Recency,@prbs_Model,@prbs_RunDate, @prbs_IndustryAve, @prbs_IndustryPercentile,
	                   @prbs_ARLag, @prbs_ARNage, @prbs_ARScore, @prbs_ARNagePercentile, @prbs_ARWeight, @prbs_ARStatisticalWeight,
					   @prbs_SurveyLag, @prbs_SurveyNage, @prbs_SurveyScore, @prbs_SurveyNagePercentile, @prbs_SurveyWeight, @prbs_SurveyStatisticalWeight,
 			           @prbs_CreatedBy,GETDATE(),@prbs_UpdatedBy,GETDATE(),GETDATE())";

        protected const string SQL_DUP_CHECK = "SELECT COUNT(1) FROM PRBBScore WHERE prbs_CompanyID=@prbs_CompanyID AND prbs_Date=@prbs_Date AND prbs_RunDate=@prbs_RunDate";
        protected const string SQL_VALIDATION_CHECK = "SELECT prbs_BBScore, prbs_MinimumTradeReportCount FROM PRBBScore WHERE prbs_CompanyID=@prbs_CompanyID AND prbs_Current='Y'";
        protected const string SQL_UPDATE_STATS = "UPDATE STATISTICS {0};";
        // Adding a delete process for all current flags not in this run date.
        protected const string SQL_UPDATE_BBSCORE_CURRENT_FLAG = "UPDATE PRBBScore SET prbs_Current = NULL FROM Company WHERE prbs_CompanyID = comp_CompanyID AND comp_PRIndustryType IN ('P', 'T', 'S') AND prbs_Current = 'Y' AND prbs_Rundate != @prbs_RunDate ";

        protected string sSID = "";
        protected int _iUserID;

        // Input Record Variables
        protected int _iCompanyID;
        protected decimal _dBBScore;
        protected decimal _dConfidenceScore;   
        protected string _szRecency;   
        protected string _szObservationPeriodTES;      
        protected string _szRecentTES; 
        protected int _iP90Surveys;
        protected int _iMinimumTradeReportCount;       
        protected DateTime _dtDate;
        protected string _szModel;
        protected DateTime _dtRunDate;
        protected decimal _dNewBBScore;
        protected decimal _dIndustryAverage = 0;
        protected int _iIndustryPercentile = 0;
        protected bool _bHasNewScore;

        protected int _prbs_ARLag;
        protected int _prbs_ARNage;
        protected int _prbs_ARScore;
        protected decimal _prbs_ARNagePercentile;
        protected decimal _prbs_ARWeight;
        protected decimal _prbs_ARStatisticalWeight;

        protected int _prbs_SurveyLag;
        protected int _prbs_SurveyNage;
        protected int _prbs_SurveyScore;
        protected decimal _prbs_SurveyNagePercentile;
        protected decimal _prbs_SurveyWeight;
        protected decimal _prbs_SurveyStatisticalWeight;

        protected SqlConnection _dbConn;

        protected decimal _dRecordCount = 0;
        protected decimal _dExistingRecordCount = 0;
        protected decimal _dMinimumTradeReportCountUnchangedCount = 0;
        protected decimal _dBBScoreUnchangedCount = 0;
        protected decimal _dBBScoreChangeExceedThresholdCount = 0;
        protected bool _bRunDateInFuture = false;
        protected bool _bDateInFuture = false;

        protected decimal _dScoreChangeThreshold = 0M;

        protected string _szUploadedFile;
        protected ArrayList _alDuplicateCompanyIDs;
        protected ArrayList _alChangeExceedThresholdCompanyIDs;

        override protected void Page_Load(object sender, EventArgs e) {
            base.Page_Load(sender, e);

            Server.ScriptTimeout = GetConfigValue("BBScoreImportScriptTimeout", 3600);

            lblError.Text = string.Empty;
            lblBBScoresCount.Text = string.Empty;

            if (!IsPostBack) {
                hidUserID.Text = Request["user_userid"];
            }

            _iUserID = Int32.Parse(hidUserID.Text);

            // Upload link
            lnkUpload.NavigateUrl = "javascript:upload();";
            this.lnkUpload.Text = "Import BB Score File";
            this.lnkUploadImage.NavigateUrl = "javascript:upload();";
            this.lnkUploadImage.ImageUrl = "/" + this._szAppName + "/img/Buttons/Attachment.gif";
            this.lnkUploadImage.Text = "Upload";

            if (!IsPostBack) {
                sSID = Request.Params.Get("SID");
                hidSID.Text = this.sSID;

            } else {
                sSID = hidSID.Text;
                ProcessForm();
            }
        }

        protected void ProcessForm() {

            DateTime dtStart;
            DateTime dtEnd;
            DateTime dtValidationStart = new DateTime();
            DateTime dtValidationEnd = new DateTime();

            _alDuplicateCompanyIDs = new ArrayList();
            _alChangeExceedThresholdCompanyIDs = new ArrayList();

            // Check to see if a license file was uploaded
            if (fileBBScoreUpload.PostedFile == null
                || fileBBScoreUpload.PostedFile.FileName == null
                || fileBBScoreUpload.PostedFile.FileName.Length == 0
                || fileBBScoreUpload.PostedFile.ContentLength == 0) {

                lblError.Text = "No file found to process";
                return;
            }

            try {
                // Since we are going to process this file twice, we need to
                // save it to disk first.
                _szUploadedFile = Path.Combine(GetConfigValue("BBScoreErrorReportFolder"), Path.GetFileName(fileBBScoreUpload.PostedFile.FileName));
                fileBBScoreUpload.PostedFile.SaveAs(_szUploadedFile);

                _dScoreChangeThreshold = GetConfigValue("BBScoreScoreChangeThreshold", 30M);

                dtStart = DateTime.Now;
                //LogEventMessage("Begin BBScore Import: " + dtStart.ToString());
                string szDuplicateErrorFile = "BBScoreImport_" + dtStart.ToString("yyyyMMdd_HHmm") + "_DuplicateCompanyIDs.txt";
                string szChangeExceedThresholdErrorFile = "BBScoreImport_" + dtStart.ToString("yyyyMMdd_HHmm") + "_ChangeExceedThresholdCompanyIDs.txt";

                bool bValidate = GetConfigValue("BBScoreValidationEnabled", true);

                if (bValidate) {
                    dtValidationStart = DateTime.Now;
                    ProcessFile(_szUploadedFile, true);
                    WriteArrayListToFile(szChangeExceedThresholdErrorFile, _alChangeExceedThresholdCompanyIDs);
                    dtValidationEnd = DateTime.Now;
                }

                if ((!bValidate) || (HasPassedValidation())) {
                    ProcessFile(_szUploadedFile, false);
                    lblBBScoresCount.Text = _dRecordCount.ToString("###,###,##0") + " BB Score Records Imported";

                    WriteArrayListToFile(szDuplicateErrorFile, _alDuplicateCompanyIDs);
                }

                // reset all current flags for "Current" BBScore records not in this file.
                if (_dtRunDate != null)
                    ResetBBScoreCurrentFlag();

                // Set our last run date so other functionality knows that BBScores
                // have been imported.
                _dbConn = OpenDBConnection("CRM BBScoreImport");
                try {
                    UpdateDateTimeCustomCaption(_dbConn, "LastBBScoreRunDate", DateTime.Now);
                }
                finally
                {
                    _dbConn.Close();
                }
                

                dtEnd = DateTime.Now;

                
                // Format our messages for screen and t
                StringBuilder sbScreenMsg = new StringBuilder();
                StringBuilder sbEventMsg = new StringBuilder();

                sbScreenMsg.Append("<p>Start DateTime: " + dtStart.ToString());
                sbEventMsg.Append("Start DateTime: " + dtStart.ToString());

                if (lblBBScoresCount.Text.Length > 0) {
                    sbEventMsg.Append(Environment.NewLine + lblBBScoresCount.Text);
                }

                if (_alDuplicateCompanyIDs.Count > 0) {
                    sbScreenMsg.Append("<br>" + _alDuplicateCompanyIDs.Count.ToString("###,###,##0") + " duplicate records found.  <a href=\"" + GetVirtualPath(GetConfigValue("BBScoreErrorReportVirtualFolder") + szDuplicateErrorFile) + "\" target=_blank>View Duplicate Company IDs File</a>.");
                    sbEventMsg.Append(Environment.NewLine + _alDuplicateCompanyIDs.Count.ToString("###,###,##0") + " duplicate records found.  See " + GetConfigValue("BBScoreErrorReportFolder") + @"\" + szDuplicateErrorFile + " for more details.");
                }

                if (_alChangeExceedThresholdCompanyIDs.Count > 0) {
                    sbScreenMsg.Append("<br>" + _alChangeExceedThresholdCompanyIDs.Count.ToString("###,###,##0") + "  records that exceed the change threshold found.  <a href=\"" + GetVirtualPath(GetConfigValue("BBScoreErrorReportVirtualFolder") + szChangeExceedThresholdErrorFile) + "\" target=_blank>View Change Exceeds Threshold Company IDs File</a>.");
                    sbEventMsg.Append(Environment.NewLine + _alChangeExceedThresholdCompanyIDs.Count.ToString("###,###,##0") + " records that exceed the change threshold found.  See " + GetConfigValue("BBScoreErrorReportFolder") + @"\" + szChangeExceedThresholdErrorFile + " for more details.");
                }

                if (bValidate) {
                    sbScreenMsg.Append("<br>Validation Start DateTime:   " + dtValidationStart.ToString());
                    sbScreenMsg.Append("<br>Validation End DateTime:   " + dtValidationEnd.ToString());
                    sbEventMsg.Append(Environment.NewLine + "Validation Start DateTime:   " + dtValidationStart.ToString());
                    sbEventMsg.Append(Environment.NewLine + "Validation End DateTime:   " + dtValidationEnd.ToString());
                }

                sbScreenMsg.Append("<br>End DateTime:   " + dtEnd.ToString());
                sbEventMsg.Append(Environment.NewLine + "End DateTime:   " + dtEnd.ToString());

                pnlBBScoresStats.Visible = true;
                lblBBScoresCount.Text += sbScreenMsg.ToString();
                //LogEventMessage("End BBScore Import " + Environment.NewLine + sbEventMsg.ToString());

                SendMail("Importing BBScore Records Completed", sbEventMsg.ToString());

            } catch (Exception e) {
                lblError.Text = "An unexpected error has occured.  " + e.Message;
                lblError.Text += "<p><pre>" + e.StackTrace + "</pre>";

                if (_iCompanyID > 0) 
                    lblError.Text += "  Last CompanyID read: " + _iCompanyID.ToString();

                string szErrorMsg = "An unexpected error has occured.  " + e.Message;
                szErrorMsg += Environment.NewLine + "Last CompanyID read: " + _iCompanyID.ToString();
                szErrorMsg += Environment.NewLine + Environment.NewLine + e.StackTrace;

                SendMail("Error Importing BBScore Records", szErrorMsg);
            }
        }


        /// <summary>
        /// Process a delmited input file
        /// </summary>
        /// <param name="_szUploadedFile"></param>
        /// <param name="bValidate"></param>
        protected void ProcessFile(string _szUploadedFile, bool bValidate) {

            StreamReader srBBScoreFile = null;
            _dbConn = OpenDBConnection("CRM BBScoreImport");

            _dRecordCount = 0M;
            _bHasNewScore = false;
            try {

                //using (StreamReader srBBScoreFile = new StreamReader(oPostedFile.InputStream)) {
                srBBScoreFile = new StreamReader(_szUploadedFile);

                bool headerRow = true;

                string szInputLine = null;
                while ((szInputLine = srBBScoreFile.ReadLine()) != null) {
                    
                    if (headerRow)
                    {
                        headerRow = false;
                        continue;
                    }


                    // Load our CSV values into member variables
                    string[] aszInputValues = ParseCSVValues(szInputLine);
                    _dRecordCount++;

                    if (OldBBScoreFormatEnabled())
                        LoadOldBBScoreRecord(aszInputValues);
                    else
                        LoadBBScoreRecord(aszInputValues);

                    if (bValidate)
                        ValidateBBScoreRecord();
                     else 
                        InsertBBScoreRecord();

                } // End While
                
            } finally {
                if (srBBScoreFile != null) {
                    srBBScoreFile.Close();
                    srBBScoreFile.Dispose();
                }

                _dbConn.Close();
            }
        }

        private void LoadOldBBScoreRecord(string[] aszInputValues)
        {
            // Note: Release 3.2 (5/08), eliminated _iP80Surveys (column 7) and _iP95Surveys (column 9).
            _iCompanyID = Int32.Parse(aszInputValues[0]);
            _dBBScore = decimal.Parse(aszInputValues[1]);

            if (!string.IsNullOrEmpty(aszInputValues[2]))
            {
                _bHasNewScore = true;
                _dNewBBScore = decimal.Parse(aszInputValues[2]);
            }
            _dConfidenceScore = decimal.Parse(aszInputValues[3]);
            _szRecency = aszInputValues[4];
            _szObservationPeriodTES = aszInputValues[5];
            _szRecentTES = aszInputValues[6];
            _iP90Surveys = Int32.Parse(aszInputValues[7]);
            _iMinimumTradeReportCount = Int32.Parse(aszInputValues[8]);
            _dtDate = DateTime.Parse(aszInputValues[9]);
            _szModel = aszInputValues[10];
            _dtRunDate = DateTime.Parse(aszInputValues[11]);

            if (aszInputValues.Length > 12)
            {
                _dIndustryAverage = decimal.Parse(aszInputValues[12]);
                _iIndustryPercentile = Int32.Parse(aszInputValues[13]);
            }
        }

        private void LoadBBScoreRecord(string[] aszInputValues)
        {
            _iCompanyID = Int32.Parse(aszInputValues[0]);

            _dtDate = DateTime.Parse(aszInputValues[1]);
            _dtRunDate = DateTime.Parse(aszInputValues[1]);

            _prbs_ARLag = Int32.Parse(aszInputValues[2]);
            _prbs_ARNage = Int32.Parse(aszInputValues[3]);
            _prbs_ARScore = Int32.Parse(aszInputValues[4]);
            _prbs_ARNagePercentile = decimal.Parse(aszInputValues[5]);
            _prbs_ARWeight = decimal.Parse(aszInputValues[17]);
            _prbs_ARStatisticalWeight = decimal.Parse(aszInputValues[6]);

            _prbs_SurveyLag = Int32.Parse(aszInputValues[12]);
            _prbs_SurveyNage = Int32.Parse(aszInputValues[13]);
            _prbs_SurveyScore = Int32.Parse(aszInputValues[7]);
            _prbs_SurveyNagePercentile = decimal.Parse(aszInputValues[14]);
            _prbs_SurveyWeight = decimal.Parse(aszInputValues[18]);
            _prbs_SurveyStatisticalWeight = decimal.Parse(aszInputValues[15]);

            _dConfidenceScore = decimal.Parse(aszInputValues[8]);
            _iMinimumTradeReportCount = Int32.Parse(aszInputValues[9]);

            _dBBScore = decimal.Parse(aszInputValues[16]);
            _szRecency = aszInputValues[12];

            _szModel = aszInputValues[19];
            _dIndustryAverage = decimal.Parse(aszInputValues[10]);
            _iIndustryPercentile = Int32.Parse(aszInputValues[11]);
        }


        /// <summary>
        /// Inserts an PRBBScore record for this import file.
        /// </summary>
        protected void InsertBBScoreRecord() {

            // Does this record already exist? We will either throw
            // an exception or skip the record.
            if (IsDuplicateRecord(_iCompanyID)) {
                if (GetConfigValue("BBScoreDuplicateRecordIsError", true)) {
                    throw new ApplicationException("BB Score data already exists for the found prbs_Date (" + _dtDate.ToShortDateString() + ") and prbs_RunDate (" + _dtRunDate.ToShortDateString() + ").");
                } else {
                    if (_alDuplicateCompanyIDs.Count == 0) {
                        _alDuplicateCompanyIDs.Add("CompanyID,Date,RunDate");
                    }
                    _alDuplicateCompanyIDs.Add(_iCompanyID.ToString() + "," + _dtDate.ToString() + "," + _dtRunDate.ToString());
                }
                return;
            }


            UpdateStatistics();


            if (OldBBScoreFormatEnabled())
                InsertOldBBScoreRecord();
            else
                InsertBBScoreRecordNew();
        }

        private void InsertBBScoreRecordNew()
        {
            SqlTransaction dbTran = _dbConn.BeginTransaction();
            try
            {
                SqlCommand cmdInsert = new SqlCommand(SQL_INSERT_BBSCORE, dbTran.Connection, dbTran);
                cmdInsert.Parameters.AddWithValue("@prbs_CompanyId", _iCompanyID);
                cmdInsert.Parameters.AddWithValue("@prbs_Date", _dtDate);
                cmdInsert.Parameters.AddWithValue("@prbs_MinimumTradeReportCount", _iMinimumTradeReportCount);
                cmdInsert.Parameters.AddWithValue("@prbs_BBScore", _dBBScore);
                cmdInsert.Parameters.AddWithValue("@prbs_ConfidenceScore", _dConfidenceScore);
                cmdInsert.Parameters.AddWithValue("@prbs_Recency", _szRecency);
                cmdInsert.Parameters.AddWithValue("@prbs_Model", _szModel);
                cmdInsert.Parameters.AddWithValue("@prbs_RunDate", _dtRunDate);
                cmdInsert.Parameters.AddWithValue("@prbs_IndustryAve", _dIndustryAverage);
                cmdInsert.Parameters.AddWithValue("@prbs_IndustryPercentile", _iIndustryPercentile);

                cmdInsert.Parameters.AddWithValue("@prbs_ARLag", _prbs_ARLag);
                cmdInsert.Parameters.AddWithValue("@prbs_ARNage", _prbs_ARNage);
                cmdInsert.Parameters.AddWithValue("@prbs_ARScore", _prbs_ARScore);
                cmdInsert.Parameters.AddWithValue("@prbs_ARNagePercentile", _prbs_ARNagePercentile);
                cmdInsert.Parameters.AddWithValue("@prbs_ARWeight", _prbs_ARWeight);
                cmdInsert.Parameters.AddWithValue("@prbs_ARStatisticalWeight", _prbs_ARStatisticalWeight);
                cmdInsert.Parameters.AddWithValue("@prbs_SurveyLag", _prbs_SurveyLag);
                cmdInsert.Parameters.AddWithValue("@prbs_SurveyNage", _prbs_SurveyNage);
                cmdInsert.Parameters.AddWithValue("@prbs_SurveyScore", _prbs_SurveyScore);
                cmdInsert.Parameters.AddWithValue("@prbs_SurveyNagePercentile", _prbs_SurveyNagePercentile);
                cmdInsert.Parameters.AddWithValue("@prbs_SurveyWeight", _prbs_SurveyWeight);
                cmdInsert.Parameters.AddWithValue("@prbs_SurveyStatisticalWeight", _prbs_SurveyStatisticalWeight);


                cmdInsert.Parameters.AddWithValue("@prbs_CreatedBy", _iUserID);
                cmdInsert.Parameters.AddWithValue("@prbs_UpdatedBy", _iUserID);


                cmdInsert.ExecuteNonQuery();

                dbTran.Commit();
            }
            catch
            {
                if (dbTran != null)
                    dbTran.Rollback();
                throw;
            }
        }

        private void InsertOldBBScoreRecord()
        {
            SqlTransaction dbTran = _dbConn.BeginTransaction();
            try
            {
                SqlCommand cmdInsert = new SqlCommand(SQL_INSERT_BBSCORE_OLD, dbTran.Connection, dbTran);
                //cmdInsert.CommandTimeout = 600; // only necessary if the server times out

                cmdInsert.Parameters.AddWithValue("@prbs_CreatedBy", _iUserID);
                cmdInsert.Parameters.AddWithValue("@prbs_UpdatedBy", _iUserID);
                cmdInsert.Parameters.AddWithValue("@prbs_CompanyId", _iCompanyID);
                cmdInsert.Parameters.AddWithValue("@prbs_Date", _dtDate);
                cmdInsert.Parameters.AddWithValue("@prbs_P90Surveys", _iP90Surveys);
                cmdInsert.Parameters.AddWithValue("@prbs_MinimumTradeReportCount", _iMinimumTradeReportCount);
                cmdInsert.Parameters.AddWithValue("@prbs_BBScore", _dBBScore);

                if (_bHasNewScore)
                    cmdInsert.Parameters.AddWithValue("@prbs_NewBBScore", _dNewBBScore);
                else
                    cmdInsert.Parameters.AddWithValue("@prbs_NewBBScore", DBNull.Value);

                cmdInsert.Parameters.AddWithValue("@prbs_ConfidenceScore", _dConfidenceScore);
                cmdInsert.Parameters.AddWithValue("@prbs_Recency", _szRecency);
                cmdInsert.Parameters.AddWithValue("@prbs_ObservationPeriodTES", _szObservationPeriodTES);
                cmdInsert.Parameters.AddWithValue("@prbs_RecentTES", _szRecentTES);
                cmdInsert.Parameters.AddWithValue("@prbs_Model", _szModel);
                cmdInsert.Parameters.AddWithValue("@prbs_RunDate", _dtRunDate);

                cmdInsert.Parameters.AddWithValue("@prbs_IndustryAve", _dIndustryAverage);
                cmdInsert.Parameters.AddWithValue("@prbs_IndustryPercentile", _iIndustryPercentile);

                cmdInsert.ExecuteNonQuery();

                dbTran.Commit();
            }
            catch
            {
                if (dbTran != null)
                    dbTran.Rollback();
                throw;
            }
        }


        private const string SQL_DUP_CHECK2 =
            "SELECT prbs_CompanyID, prbs_Date, prbs_RunDate FROM PRBBScore WITH (NOLOCK) INNER JOIN Company WITH (NOLOCK) ON prbs_CompanyId=Comp_CompanyId WHERE prbs_Date=@prbs_Date AND prbs_RunDate=@prbs_RunDate AND comp_PRIndustryType IN ('P', 'T') ORDER BY prbs_CompanyID";

        private Dictionary<Int32, bool> _dupCheck = null;

        /// <summary>
        /// Determines if a PRBBScore file already 
        /// exists for this company and run date.
        /// </summary>
        /// <returns></returns>
        protected bool IsDuplicateRecord(int iCompanyID) {

            if (_dupCheck == null)
            {
                _dupCheck = new Dictionary<int, bool>();

                SqlCommand cmdDupCheck = new SqlCommand(SQL_DUP_CHECK2, _dbConn);
                cmdDupCheck.Parameters.AddWithValue("@prbs_Date", _dtDate);
                cmdDupCheck.Parameters.AddWithValue("@prbs_RunDate", _dtRunDate);

                using (SqlDataReader reader = cmdDupCheck.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        _dupCheck.Add(reader.GetInt32(0), true);
                    }
                }
            }

            if (!_dupCheck.ContainsKey(iCompanyID))
                return false;

            return _dupCheck[iCompanyID];
        }


        private const string SQL_GET_CURRENT_SCORES =
            "SELECT prbs_CompanyID, prbs_BBScore, prbs_MinimumTradeReportCount FROM PRBBScore WITH (NOLOCK) INNER JOIN Company WITH (NOLOCK) ON prbs_CompanyId=Comp_CompanyId WHERE prbs_Current='Y' AND comp_PRIndustryType IN ('P', 'T') ORDER BY prbs_CompanyID";

        private Dictionary<Int32, CurrentBBScore> _currentBBScores = null;

        /// <summary>
        /// Helper method to retreive the current values for
        /// the specified company ID.
        /// </summary>
        /// <param name="iCompanyID"></param>
        /// <returns></returns>
        protected CurrentBBScore GetCurrentValues(int iCompanyID) {

            if (_currentBBScores == null)
            {
                _currentBBScores = new Dictionary<int, CurrentBBScore>();

                SqlCommand cmdCurrentScores = new SqlCommand(SQL_GET_CURRENT_SCORES, _dbConn);
                using(SqlDataReader reader = cmdCurrentScores.ExecuteReader())
                {
                    while(reader.Read())
                    {
                        CurrentBBScore oCurrentBBScore = new CurrentBBScore();
                        oCurrentBBScore.BBScore = reader.GetDecimal(1);
                        if (reader[2] != DBNull.Value)
                            oCurrentBBScore.MinimumTradeReportCount = reader.GetInt32(2);

                        _currentBBScores.Add(reader.GetInt32(0), oCurrentBBScore);
                    }
                }
            }

            if (!_currentBBScores.ContainsKey(iCompanyID))
                return null;

            return _currentBBScores[iCompanyID];
        }


        /// <summary>
        /// Helper method that validate the BBScore record to be
        /// imported against the current BBSCore record in PIKS.
        /// </summary>
        protected void ValidateBBScoreRecord() {
            CurrentBBScore oCurrentBBScore = GetCurrentValues(_iCompanyID);

            if (oCurrentBBScore != null) {
                _dExistingRecordCount++;

                if (_iMinimumTradeReportCount == oCurrentBBScore.MinimumTradeReportCount)
                    _dMinimumTradeReportCountUnchangedCount++;

                if (_dBBScore == oCurrentBBScore.BBScore) 
                    _dBBScoreUnchangedCount++;

                if (Math.Abs(_dBBScore - oCurrentBBScore.BBScore) > _dScoreChangeThreshold) {
                    if (_alChangeExceedThresholdCompanyIDs.Count == 0) 
                        _alChangeExceedThresholdCompanyIDs.Add("CompanyID,Input BBScore,CRM BBScore");

                    _alChangeExceedThresholdCompanyIDs.Add(_iCompanyID.ToString() + "," + _dBBScore.ToString() + "," + oCurrentBBScore.BBScore.ToString());
                    _dBBScoreChangeExceedThresholdCount++;
                }

                if (_dtDate > DateTime.Today) 
                    _bDateInFuture = true;

                if (_dtRunDate > DateTime.Today) 
                    _bRunDateInFuture = true;
            }
        }


        /// <summary>
        /// Calculates the percentages and determines if the file had
        /// passed validation.  If not, a message is written to the
        /// screen and false returned.
        /// </summary>
        /// <returns></returns>
        protected bool HasPassedValidation() {
            if (_dRecordCount == 0) 
                return true;

            bool bPassed = true;
            StringBuilder sbValidationMsg = new StringBuilder();
            decimal dMinimumTradeReportCountUnchangedThreshold = GetConfigValue("BBScoreP975UnchangedThreshold", .75M);
            decimal dBBScoreUnchangedThreshold = GetConfigValue("BBScoreBBScoreUnchangedThreshold", .10M);
            decimal dBBScoreChangedThreshold   = GetConfigValue("BBScoreBBScoreChangedThreshold", .10M);

            decimal dMinimumTradeReportCountUnchanged = 0;
            decimal dBBScoreUnchanged = 0;
            decimal dBBScoreChanged   = 0;
            
            if (_dExistingRecordCount > 0) {
                dMinimumTradeReportCountUnchanged = _dMinimumTradeReportCountUnchangedCount / _dExistingRecordCount;
                dBBScoreUnchanged = _dBBScoreUnchangedCount / _dExistingRecordCount;
                dBBScoreChanged = _dBBScoreChangeExceedThresholdCount / _dExistingRecordCount;
            }

            if (dMinimumTradeReportCountUnchanged > dMinimumTradeReportCountUnchangedThreshold)
            {
                bPassed = false;
                sbValidationMsg.Append(string.Format("<li>{0:#0%} of the current MinimumTradeReportCount values are unchanged which exceeds the threshold of {1:#0%}.<br>", dMinimumTradeReportCountUnchanged, dMinimumTradeReportCountUnchangedThreshold));
            }

            if (dBBScoreUnchanged > dBBScoreUnchangedThreshold) {
                bPassed = false;
                sbValidationMsg.Append(string.Format("<li>{0:#0%} of the current BBScore values are unchanged which exceeds the threshold of {1:#0%}.<br>", dBBScoreUnchanged, dBBScoreUnchangedThreshold));
            }

            if (dBBScoreChanged > dBBScoreChangedThreshold) {
                bPassed = false;
                sbValidationMsg.Append(string.Format("<li>{0:#0%} of the current BBScore values have a change of more than {2} which exceeds the threshold of {1:#0%}.<br>", dBBScoreChanged, dBBScoreChangedThreshold, _dScoreChangeThreshold));
            }

            if (_bDateInFuture) {
                bPassed = false;
                sbValidationMsg.Append("<li>The 'Date' field is in the future.<br>");
            }

            if (_bRunDateInFuture) {
                bPassed = false;
                sbValidationMsg.Append("<li>The 'RunDate' field is in the future.<br>");
            }

            if (!bPassed) {
                lblError.Text = "BBScore input file failed validation and was not loaded for the following reason(s):<ul>" + sbValidationMsg.ToString() + "</ul>";
            }
            return bPassed;
        }

        /// <summary>
        /// Helper method that writes the content of the ArrayList to disk.
        /// </summary>
        /// <param name="szFileName"></param>
        /// <param name="alData"></param>
        protected void WriteArrayListToFile(string szFileName, ArrayList alData) {
            string szFolder = Path.Combine(GetConfigValue("BBScoreErrorReportFolder"), szFileName);
            using (TextWriter tw = new StreamWriter(szFolder)) {
                foreach(string szValue in alData) {
                    tw.WriteLine(szValue);
                }
            }
        }

        /// <summary>
        /// Helper class to hold the current values
        /// for the preprocessing validation
        /// </summary>
        protected class CurrentBBScore {
            public decimal BBScore;
            public int MinimumTradeReportCount;       
        }

        /// <summary>
        /// Helper method that updates the statistics on the tables updated
        /// by the BBScore import process.
        /// </summary>
        protected void UpdateStatistics() {
            if (!GetConfigValue("BBScoreUpdateStatisticsEnabled", false))
                return;

            if ((_dRecordCount % GetConfigValue("BBScoreUpdateStatsEveryNRecords", 3000)) == 0) {
                SqlCommand cmdUpdateStats = new SqlCommand(string.Format(SQL_UPDATE_STATS, "PRTESRequest"), _dbConn);
                cmdUpdateStats.ExecuteNonQuery();
                cmdUpdateStats = new SqlCommand(string.Format(SQL_UPDATE_STATS, "PRBBScore"), _dbConn);
                cmdUpdateStats.ExecuteNonQuery();
           }
        }

        /// <summary>
        /// removes the current flag for all BBSCores that were not in this import file.
        /// </summary>
        protected void ResetBBScoreCurrentFlag()
        {
            _dbConn = OpenDBConnection("CRM BBScoreImport");
            SqlTransaction dbTran = _dbConn.BeginTransaction();
            try
            {
                SqlCommand cmdUpdate = new SqlCommand(SQL_UPDATE_BBSCORE_CURRENT_FLAG, dbTran.Connection, dbTran);

                cmdUpdate.Parameters.AddWithValue("@prbs_RunDate", _dtRunDate);
                cmdUpdate.ExecuteNonQuery();
                dbTran.Commit();
            }
            catch
            {
                if (dbTran != null)
                    dbTran.Rollback();
                throw;
            }
            finally
            {
                _dbConn.Close();
            }
        }

        protected bool OldBBScoreFormatEnabled()
        {
            return (GetConfigValue("BBScoreImportVersion", "OLD") == "OLD");
        }
    }
}
