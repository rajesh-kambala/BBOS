/***********************************************************************
 Copyright Produce Reporter Company 2006-2022

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CompanyARAgingImport
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.IO;
using System.Web;

namespace PRCo.BBS.CRM
{

    /// <summary>
    /// Provides the functionality to load the specified company's
    /// aged A/R data.
    /// </summary>
    public partial class PRCompanyARAgingImport : PageBase {

        protected const string SQL_SELECT_IMPORT_FORMAT = "SELECT PRARAgingImportFormat.* FROM PRARAgingImportFormat INNER JOIN PRCompanyInfoProfile ON praaif_ARAgingImportFormatID = prc5_ARAgingImportFormatID WHERE prc5_CompanyID = @Parm01";
        protected const string SQL_INSERT_PRARAGING = "INSERT INTO PRARAging (praa_ARAgingId,praa_CreatedBy,praa_CreatedDate,praa_UpdatedBy,praa_UpdatedDate,praa_TimeStamp,praa_CompanyId,praa_Date,praa_RunDate,praa_DateSelectionCriteria,praa_ImportedDate,praa_ImportedByUserId,praa_ARAgingImportFormatID) VALUES (@praa_ARAgingId,@praa_CreatedBy,GETDATE(),@praa_UpdatedBy,GETDATE(),GETDATE(),@praa_CompanyId,@praa_Date,@praa_RunDate,@praa_DateSelectionCriteria,GETDATE(),@praa_ImportedByUserId,@praa_ARAgingImportFormatID)";
        protected const string SQL_INSERT_PRARAGING_DETAIL = "INSERT INTO PRARAgingDetail (praad_ARAgingDetailId, praad_CreatedBy, praad_CreatedDate, praad_UpdatedBy, praad_UpdatedDate, praad_TimeStamp, praad_ARAgingId, praad_ARCustomerId, praad_FileCompanyName, praad_FileCityName, praad_FileStateName, praad_FileZipCode, praad_Amount0to29, praad_Amount30to44, praad_Amount45to60, praad_Amount61Plus, praad_CreditTerms, praad_TimeAged, praad_Amount1to30, praad_Amount31to60, praad_Amount61to90, praad_Amount91Plus, praad_AmountCurrent, praad_CreditTermsText, praad_PhoneNumber) VALUES (@praad_ARAgingDetailId, @praad_CreatedBy, GETDATE(), @praad_UpdatedBy, GETDATE(), GETDATE(), @praad_ARAgingId, @praad_ARCustomerId, @praad_FileCompanyName, @praad_FileCityName, @praad_FileStateName, @praad_FileZipCode, @praad_Amount0to29, @praad_Amount30to44, @praad_Amount45to60, @praad_Amount61Plus, @praad_CreditTerms, @praad_TimeAged, @praad_Amount1to30, @praad_Amount31to60, @praad_Amount61to90, @praad_Amount91Plus, @praad_AmountCurrent, @praad_CreditTermsText, @praad_PhoneNumber)";
        protected const string SQL_COUNT_UNMATCHED = "SELECT COUNT(DISTINCT praad_ARCustomerID) FROM PRARAgingDetail WHERE praad_ARCustomerID NOT IN (SELECT prar_CustomerNumber FROM PRARTranslation WHERE prar_CompanyID = @prar_CompanyID) AND praad_ARAgingID=@praad_ARAgingID";
        protected const string SQL_DUP_CHECK = "SELECT COUNT(1) FROM PRARAging WHERE praa_CompanyID=@praa_CompanyID AND praa_Date=@praa_Date";

        protected const string DATE_FORMAT_MMDDYY   = "MMDDYY";
        protected const string DATE_FORMAT_MMDDYYYY = "MMDDYYYY";
        protected const string DATE_FORMAT_DDMMYY   = "DDMMYY";
        protected const string DATE_FORMAT_DDMMYYYY = "DDMMYYYY";
        protected const string DATE_FORMAT_YYMMDD   = "YYMMDD";
        protected const string DATE_FORMAT_YYYYMMDD = "YYYYMMDD";

        protected const string FILE_FORMAT_DELIMITED = "DEL";
        protected const string FILE_FORMAT_XML = "XML";

        protected string sSID = "";
        protected int _iUserID;
        protected int _iCompanyID; 
        
        // Processing Values
        protected string _szName;
        protected string _szDateFormat;
        protected string _szFileFormat;
        protected string _szDefaultDateSelectionCriteria;
        protected char _cDelimiterChar;
        protected int _iNumberHeaderLines;
        protected int _iPRARAgingImportFormatID;

                
        // Header Indexes
        protected int _iDateSelectionCriteriaColIndex;
        protected int _iDateSelectionCriteriaRowIndex;
        protected int _iRunDateColIndex;
        protected int _iRunDateRowndex;
        protected int _iAsOfDateColIndex;
        protected int _iAsOfDateRowIndex;
        
        // Detail Indexes
        protected int _iCompanyIDColIndex;
        protected int _iCompanyNameColIndex;
        protected int _iCityNameColIndex;
        protected int _iStateNameColIndex;
        protected int _iZipCodeColIndex; 
        protected int _iAmount0to29ColIndex;
        protected int _iAmount30to44ColIndex; 
        protected int _iAmount45to60ColIndex;
        protected int _iAmount61PlusColIndex;
        protected int _iCreditTermsColIndex;
        protected int _iTimeAgedColIndex;
        protected int _iPhoneNumberColIndex;

            // Lumber
        protected int _iAmount1to30ColIndex;
        protected int _iAmount31to60ColIndex;
        protected int _iAmount61to90ColIndex;
        protected int _iAmount91PlusColIndex;
        protected int _iAmountCurrentColIndex;
        protected int _iCreditTermsTextColIndex;

        // Header Values
        protected DateTime _dtAsOfDate;
        protected DateTime _dtRunDate;
        protected string _szDateSelectionCriteria;
        protected int _iPRAgingID;

        // Detail Values
        protected string _szCompanyID;
        protected string _szCompanyName;
        protected string _szCity;
        protected string _szState;
        protected string _szZip;
        protected string _szPhoneNumber;
        protected decimal _dAmount0to29;
        protected decimal _dAmount30to44;
        protected decimal _dAmount45to60;
        protected decimal _dAmount61Plus;
        protected int _iCreditTerms;
            // Lumber
        protected decimal _dAmount1to30;
        protected decimal _dAmount31to60;
        protected decimal _dAmount61to90;
        protected decimal _dAmount91Plus;
        protected decimal _dAmountCurrent;
        protected string  _szCreditTermsText;

        protected string _szTimeAged;

        protected SqlConnection _dbConn;
        protected SqlTransaction _dbTran;


        override protected void Page_Load(object sender, EventArgs e) {
            base.Page_Load(sender, e);

            lblError.Text = string.Empty;
            lblARAgingCount.Text = string.Empty;
            lblARAgingUnmatchedCount.Text = string.Empty;

            if (!IsPostBack) {
                hidCompanyID.Text = Request["comp_CompanyId"];
                hidUserID.Text = Request["user_userid"];
            }

            _iCompanyID = Int32.Parse(hidCompanyID.Text);
            _iUserID = Int32.Parse(hidUserID.Text);

            LoadImportFormat();

            imgARAgingDate.ImageUrl = "/" + this._szAppName + "/img/Buttons/calCalendar.gif";

            if (!IsPostBack) {
                hidCompanyID.Text = Request["comp_CompanyId"];

                sSID = Request.Params.Get("SID");
                hidSID.Text = this.sSID;

                // Upload link
                lnkUpload.NavigateUrl = "javascript:upload();";
                this.lnkUpload.Text = "Import A/R Aging File";
                this.lnkUploadImage.NavigateUrl = "javascript:upload();";
                this.lnkUploadImage.ImageUrl = "/" + this._szAppName + "/img/Buttons/Attachment.gif";
                this.lnkUploadImage.Text = "Upload";

                // Upload link
                this.lnkContinue.NavigateUrl = "javascript:pageContinue();";
                this.lnkContinue.Text = "Continue";
                this.lnkContinueImage.NavigateUrl = "javascript:pageContinue();";
                this.lnkContinueImage.ImageUrl = "/" + this._szAppName + "/img/Buttons/Continue.gif";
                this.lnkContinueImage.Text = "Continue";

            } else {
                sSID = hidSID.Text;
                ProcessForm();
            }
        }

        /// <summary>
        /// Loads the File Import Settings
        /// </summary>
        protected void LoadImportFormat() {
            SqlConnection dbConn = OpenDBConnection();
            SqlCommand dbCmd = new SqlCommand(SQL_SELECT_IMPORT_FORMAT, dbConn);
            dbCmd.Parameters.AddWithValue("Parm01", _iCompanyID);
            dbCmd.CommandType = CommandType.Text;
            dbCmd.CommandTimeout = GetConfigValue("ARAgingImportTimeout", 120);

            SqlDataReader oReader = dbCmd.ExecuteReader(CommandBehavior.CloseConnection);
            try {
                if (oReader.Read()) {

                    int iOffSet = 1;

                    // Processing Values
                    _szName = Convert.ToString(oReader["praaif_Name"]);
                    _szDateFormat = Convert.ToString(oReader["praaif_DateFormat"]);
                    _szFileFormat = Convert.ToString(oReader["praaif_FileFormat"]);
                    _cDelimiterChar = Convert.ToChar(oReader["praaif_DelimiterChar"]);
                    _iNumberHeaderLines = Convert.ToInt32(oReader["praaif_NumberHeaderLines"]);
                    _iPRARAgingImportFormatID = Convert.ToInt32(oReader["praaif_ARAgingImportFormatID"]);

                    // Header Values
                    _iDateSelectionCriteriaColIndex = Convert.ToInt32(oReader["praaif_DateSelectionCriteriaColIndex"]) - iOffSet;
                    _iDateSelectionCriteriaRowIndex = Convert.ToInt32(oReader["praaif_DateSelectionCriteriaRowIndex"]);
                    _iRunDateColIndex = Convert.ToInt32(oReader["praaif_RunDateColIndex"]) - iOffSet;
                    _iRunDateRowndex = Convert.ToInt32(oReader["praaif_RunDateRowIndex"]);
                    _iAsOfDateColIndex = Convert.ToInt32(oReader["praaif_AsOfDateColIndex"]) - iOffSet;
                    _iAsOfDateRowIndex = Convert.ToInt32(oReader["praaif_AsOfDateRowIndex"]);
                    _szDefaultDateSelectionCriteria = Convert.ToString(oReader["praaif_DefaultDateSelectionCriteria"]);

                    // Detail Values
                    _iCompanyIDColIndex = Convert.ToInt32(oReader["praaif_CompanyIDColIndex"]) - iOffSet;
                    _iCompanyNameColIndex = Convert.ToInt32(oReader["praaif_CompanyNameColIndex"]) - iOffSet;
                    _iCityNameColIndex = Convert.ToInt32(oReader["praaif_CityNameColIndex"]) - iOffSet;
                    _iStateNameColIndex = Convert.ToInt32(oReader["praaif_StateNameColIndex"]) - iOffSet;
                    _iZipCodeColIndex = Convert.ToInt32(oReader["praaif_ZipCodeColIndex"]) - iOffSet;
                    _iAmount0to29ColIndex = Convert.ToInt32(oReader["praaif_Amount0to29ColIndex"]) - iOffSet;
                    _iAmount30to44ColIndex = Convert.ToInt32(oReader["praaif_Amount30to44ColIndex"]) - iOffSet;
                    _iAmount45to60ColIndex = Convert.ToInt32(oReader["praaif_Amount45to60ColIndex"]) - iOffSet;
                    _iAmount61PlusColIndex = Convert.ToInt32(oReader["praaif_Amount61PlusColIndex"]) - iOffSet;
                    _iCreditTermsColIndex = Convert.ToInt32(oReader["praaif_CreditTermsColIndex"]) - iOffSet;
                    _iTimeAgedColIndex = Convert.ToInt32(oReader["praaif_TimeAgedColIndex"]) - iOffSet;
                    _iPhoneNumberColIndex = Convert.ToInt32(oReader["praaif_PhoneNumberColIndex"]) - iOffSet;
                    
                    // Lumber
                    _iAmount1to30ColIndex = Convert.ToInt32(oReader["praaif_Amount1to30ColIndex"]) - iOffSet;
                    _iAmount31to60ColIndex = Convert.ToInt32(oReader["praaif_Amount31to60ColIndex"]) - iOffSet;
                    _iAmount61to90ColIndex = Convert.ToInt32(oReader["praaif_Amount61to90ColIndex"]) - iOffSet;
                    _iAmount91PlusColIndex = Convert.ToInt32(oReader["praaif_Amount91PlusColIndex"]) - iOffSet;
                    _iAmountCurrentColIndex = Convert.ToInt32(oReader["praaif_AmountCurrentColIndex"]) - iOffSet;
                    _iCreditTermsTextColIndex = Convert.ToInt32(oReader["praaif_CreditTermsTextColIndex"]) - iOffSet;

                    if (_iAsOfDateColIndex < 0) {
                        pnlARAgingDate.Visible = true;
                    }

                    lblFileFormatName.Text = _szName;
                } else {
                    lblFileFormatName.Text = "None";
                    lblError.Text = "The current company is not associated with an A/R Aging File Format.";
                    lnkUpload.Enabled = false;
                    lnkUploadImage.Enabled = false;
                    fileARAgingUpload.Disabled = true;
                }
            } finally {
                oReader.Close();
            }
        }

        /// <summary>
        /// Processes the uploaded form.
        /// </summary>
        protected void ProcessForm() {
            // If the user is required to enter an
            // A/R Aging Date, validate it.
            if (_iAsOfDateColIndex < 0) {
                if (!DateTime.TryParse(txtARAgingDate.Text, out _dtAsOfDate)) {
                    lblError.Text = "Invalid A/R Aging Date Specified.";
                    return;
                }
            }

            // Check to see if a license file was uploaded
            if (fileARAgingUpload.PostedFile == null
                || fileARAgingUpload.PostedFile.FileName == null
                || fileARAgingUpload.PostedFile.FileName.Length == 0
                || fileARAgingUpload.PostedFile.ContentLength == 0) {

                lblError.Text = "No file found to process";
                return;
            }

            try {
                if (_szFileFormat == FILE_FORMAT_DELIMITED) {
                    ProcessDelimitedFile(fileARAgingUpload.PostedFile);
                }
            } catch (Exception e) {
                lblError.Text = "An unexpected error has occured.  " + e.Message;

                Exception eX = e.InnerException;
                while (eX != null) {
                    lblError.Text += eX.Message;

                    lblError.Text += "<p><pre>" + eX.StackTrace + "</pre></p>";

                    eX = eX.InnerException;
                }

                
            }
        }



        /// <summary>
        /// Process a delmited input file
        /// </summary>
        /// <param name="oPostedFile"></param>
        protected void ProcessDelimitedFile(HttpPostedFile oPostedFile) {

            _dbConn = OpenDBConnection();
            _dbTran = _dbConn.BeginTransaction();
            try {

                int iARCustomerIDMaxLength = GetConfigValue("ARAgingImportARCustomerIDMaxLength", 15);
                int iCompanyNameMaxLength = GetConfigValue("ARAgingImportCompanyNameMaxLength", 200);
                int iCityMaxLength = GetConfigValue("ARAgingImportCityMaxLength", 100);
                int iStateMaxLength = GetConfigValue("ARAgingImportStateMaxLength", 10);
                int iZipMaxLength = GetConfigValue("ARAgingImportZipMaxLength", 10);
                int iPhoneMaxLength = GetConfigValue("ARAgingImportCompanyNameMaxLength", 50);
                int iCreditTermsMaxLength = GetConfigValue("ARAgingImportCreditTermsMaxLength", 50);
                int iTimeAgedMaxLength = GetConfigValue("ARAgingImportTimeAgedMaxLength", 50);

                int iExpectedFieldCount = GetExpectedDetailFieldCount();

                int iRecordIndex = 0;
                int iDetailRecordCount = 0;
                int iSkippedLineCount = 0;

                int iFieldIndex = 0;

                using (StreamReader srARFile = new StreamReader(oPostedFile.InputStream)) {

                    string szInputLine = null;
                    while ((szInputLine = srARFile.ReadLine()) != null) {

                        string[] aszInputValues = ParseCSVValues(szInputLine, _cDelimiterChar);
                        iRecordIndex++;


                        // Are we still processing the header records?
                        if (_iPRAgingID == 0) {
                            _dtAsOfDate = GetHeaderDateValue(aszInputValues, iRecordIndex, _iAsOfDateRowIndex, _iAsOfDateColIndex, _dtAsOfDate);
                            _dtRunDate = GetHeaderDateValue(aszInputValues, iRecordIndex, _iRunDateRowndex, _iRunDateColIndex, _dtRunDate);
                            _szDateSelectionCriteria = GetHeaderDateSelectionValue(aszInputValues, iRecordIndex, _iDateSelectionCriteriaRowIndex, _iDateSelectionCriteriaColIndex, _szDateSelectionCriteria);

                            IsPRAgingCompleted();
                        } 
                         
                        if (iRecordIndex > _iNumberHeaderLines) {

                            iDetailRecordCount++;
                            if ((GetConfigValue("ARAgingImportValidateDetailColumnCount", false)) &&
                                (aszInputValues.Length != iExpectedFieldCount))
                                throw new ApplicationException("Expecting " + iExpectedFieldCount.ToString() + " fields but detail row " + iDetailRecordCount.ToString() + " has " + aszInputValues.Length.ToString() + ".");

                            try
                            {
                                iFieldIndex = _iCompanyIDColIndex;
                                _szCompanyID = GetStringValue(aszInputValues, _iCompanyIDColIndex);
                                CheckFieldLength(_szCompanyID, iARCustomerIDMaxLength, "CompanyID");

                                iFieldIndex = _iCompanyNameColIndex;
                                _szCompanyName = GetStringValue(aszInputValues, _iCompanyNameColIndex);
                                CheckFieldLength(_szCompanyName, iCompanyNameMaxLength, "CompanyName");

                                iFieldIndex = _iCityNameColIndex;
                                _szCity = GetStringValue(aszInputValues, _iCityNameColIndex);
                                CheckFieldLength(_szCity, iCityMaxLength, "City");

                                iFieldIndex = _iStateNameColIndex;
                                _szState = GetStringValue(aszInputValues, _iStateNameColIndex);
                                CheckFieldLength(_szState, iStateMaxLength, "State");

                                iFieldIndex = _iZipCodeColIndex;
                                _szZip = GetStringValue(aszInputValues, _iZipCodeColIndex);
                                CheckFieldLength(_szZip, iZipMaxLength, "Zip");

                                iFieldIndex = _iPhoneNumberColIndex;
                                _szPhoneNumber = GetStringValue(aszInputValues, _iPhoneNumberColIndex);
                                CheckFieldLength(_szPhoneNumber, iPhoneMaxLength, "Phone");

                                iFieldIndex = _iAmount0to29ColIndex;
                                _dAmount0to29 = GetDecimalValue(aszInputValues, _iAmount0to29ColIndex);

                                iFieldIndex = _iAmount30to44ColIndex;
                                _dAmount30to44 = GetDecimalValue(aszInputValues, _iAmount30to44ColIndex);

                                iFieldIndex = _iAmount45to60ColIndex;
                                _dAmount45to60 = GetDecimalValue(aszInputValues, _iAmount45to60ColIndex);

                                iFieldIndex = _iAmount61PlusColIndex;
                                _dAmount61Plus = GetDecimalValue(aszInputValues, _iAmount61PlusColIndex);

                                iFieldIndex = _iCreditTermsColIndex;
                                _iCreditTerms = GetIntValue(aszInputValues, _iCreditTermsColIndex);

                                // Lumber
                                iFieldIndex = _iAmount1to30ColIndex;
                                _dAmount1to30 = GetDecimalValue(aszInputValues, _iAmount1to30ColIndex);

                                iFieldIndex = _iAmount31to60ColIndex;
                                _dAmount31to60 = GetDecimalValue(aszInputValues, _iAmount31to60ColIndex);

                                iFieldIndex = _iAmount61to90ColIndex;
                                _dAmount61to90 = GetDecimalValue(aszInputValues, _iAmount61to90ColIndex);

                                iFieldIndex = _iAmount91PlusColIndex;
                                _dAmount91Plus = GetDecimalValue(aszInputValues, _iAmount91PlusColIndex);

                                iFieldIndex = _iAmountCurrentColIndex;
                                _dAmountCurrent = GetDecimalValue(aszInputValues, _iAmountCurrentColIndex);

                                iFieldIndex = _iCreditTermsTextColIndex;
                                _szCreditTermsText = GetStringValue(aszInputValues, _iCreditTermsTextColIndex);
                                CheckFieldLength(_szCreditTermsText, iCreditTermsMaxLength, "CreditTerms");

                                iFieldIndex = _iTimeAgedColIndex;
                                _szTimeAged = GetStringValue(aszInputValues, _iTimeAgedColIndex);
                                CheckFieldLength(_szTimeAged, iTimeAgedMaxLength, "TimeAged");
                            }
                            catch (Exception innerE)
                            {
                                throw new ApplicationException("Exception processing detail record " + iDetailRecordCount.ToString("###,##0") + ", field index " + iFieldIndex.ToString() + ": " + innerE.Message);
                            }

                            if ((string.IsNullOrEmpty(_szCompanyID)) &&
                                (string.IsNullOrEmpty(_szCompanyName)))
                            {
                                iDetailRecordCount--;
                                iSkippedLineCount++;
                                continue;
                            }


                            InsertARAgingDetailRecord();
                        }
                    } // End Wile
                } // End Using

                if (iDetailRecordCount > 0)
                {
                    if (!GetConfigValue("UseCRMForARAgindDetailID", false))
                    {
                        SqlCommand cmdUpdateStats = new SqlCommand("usp_DTSPostExecute", _dbTran.Connection, _dbTran);
                        cmdUpdateStats.CommandType = CommandType.StoredProcedure;
                        cmdUpdateStats.Parameters.AddWithValue("@TableName", "PRARAgingDetail");
                        cmdUpdateStats.Parameters.AddWithValue("@PrimaryKeyName", "praad_ARAgingDetailId");
                        cmdUpdateStats.CommandTimeout = GetConfigValue("ARAgingImportTimeout", 120);

                        cmdUpdateStats.ExecuteNonQuery();
                    }

                    SqlCommand cmdUpdateTotals = new SqlCommand("usp_UpdateARAgingTotals", _dbTran.Connection, _dbTran);
                    cmdUpdateTotals.CommandType = CommandType.StoredProcedure;
                    cmdUpdateTotals.Parameters.AddWithValue("@ARAgingID", _iPRAgingID);
                    cmdUpdateTotals.CommandTimeout = GetConfigValue("ARAgingImportTimeout", 120);
                    cmdUpdateTotals.ExecuteNonQuery();


                    //SqlCommand cmdDoNotMatchCheck = new SqlCommand("SELECT 'x' FROM PRARAgingDetails WHERE praad_ARAgingID=@ARAgingID AND praad_DoNotMatch='Y'; ", _dbTran.Connection, _dbTran);
                    //cmdDoNotMatchCheck.Parameters.AddWithValue("@ARAgingID", _iPRAgingID);
                    //object result = cmdDoNotMatchCheck.ExecuteScalar();
                    //if ((result != null) &&
                    //    (result != DBNull.Value))
                    //{
                    //    lblError.Text = "This Aging file contains subject companies that are out-of-business.  These AR details records have not been matched to these companies.";
                    //}
                }

                pnlARAgingStats.Visible = true;
                lblARAgingCount.Text = iDetailRecordCount.ToString("###,###,##0") + " A/R Aging Records Imported";
                lblARAgingUnmatchedCount.Text = GetUnmatchedCount().ToString("###,###,##0") + " unmatched A/R company IDs found.";
                lblARAgingUnmatchedCount.Text = iSkippedLineCount.ToString("###,###,##0") + " detail lines skipped.";

                _dbTran.Commit();
            
            } catch {
                if (_dbTran != null) {
                    _dbTran.Rollback();
                }
                throw;
            } finally {
                _dbConn.Close();
            }
        }


        /// <summary>
        /// Determine if we have completed processing 
        /// our PRAging record
        /// </summary>
        /// <returns></returns>
        protected bool IsPRAgingCompleted() {

            // If we have a PRAgingID, then
            // we've completed the record.
            if (_iPRAgingID > 0) {
                return true;
            }

            if ((_iAsOfDateColIndex > -1) &&
                (_dtAsOfDate == DateTime.MinValue)) {
                return false;
            }

            if ((_iRunDateColIndex > -1) &&
                (_dtRunDate == DateTime.MinValue)) {
                return false;
            }

            if ((_iDateSelectionCriteriaColIndex > -1) &&
                (string.IsNullOrEmpty(_szDateSelectionCriteria))) {
                return false;
            }

            // If we made it this far, then we have our values
            // so we should save them.
            if (_iPRAgingID == 0) {

                if (IsDuplicateImport()) {
                    throw new ApplicationException("An A/R Aging record already exists for this company and specified aging date (" + _dtAsOfDate.ToShortDateString() + ").");
                }

                InsertARAgingRecord();
            }

            return true;
        }

        /// <summary>
        /// Inserts an ARAging record for this import file.
        /// </summary>
        protected void InsertARAgingRecord() {
            _iPRAgingID = GetNextRecordID(_dbTran, "PRARAging");

            SqlCommand cmdInsert = new SqlCommand(SQL_INSERT_PRARAGING, _dbTran.Connection, _dbTran);
            cmdInsert.CommandTimeout = GetConfigValue("ARAgingImportTimeout", 120);

            cmdInsert.Parameters.AddWithValue("@praa_ARAgingId", _iPRAgingID);
            cmdInsert.Parameters.AddWithValue("@praa_CreatedBy", _iUserID);
            cmdInsert.Parameters.AddWithValue("@praa_UpdatedBy", _iUserID);
            cmdInsert.Parameters.AddWithValue("@praa_CompanyId", _iCompanyID);
            cmdInsert.Parameters.AddWithValue("@praa_ImportedByUserId", _iUserID);
            cmdInsert.Parameters.AddWithValue("@praa_ARAgingImportFormatID", _iPRARAgingImportFormatID);

            AddParmValue(cmdInsert, "@praa_Date", _dtAsOfDate);
            AddParmValue(cmdInsert, "@praa_RunDate", _dtRunDate);
            AddParmValue(cmdInsert, "@praa_DateSelectionCriteria", _szDateSelectionCriteria);

            cmdInsert.ExecuteNonQuery();
        }

        /// <summary>
        /// Inserts an ARAgingDetail record for this import file.
        /// </summary>
        protected void InsertARAgingDetailRecord() {

            if (_iPRAgingID == 0) {
                throw new ApplicationException("Attempting to insert PRARAgingDetail recored without first inserting PRARAging record.");
            }

            //int _iPRAgingDetailID = GetNextRecordID(_dbTran, "PRARAgingDetail");
            int _iPRAgingDetailID = GetARAgingDetailID();

            SqlCommand cmdInsert = new SqlCommand(SQL_INSERT_PRARAGING_DETAIL, _dbTran.Connection, _dbTran);
            cmdInsert.CommandTimeout = GetConfigValue("ARAgingImportTimeout", 120);

            cmdInsert.Parameters.AddWithValue("@praad_ARAgingDetailId", _iPRAgingDetailID);
            cmdInsert.Parameters.AddWithValue("@praad_CreatedBy", _iUserID);
            cmdInsert.Parameters.AddWithValue("@praad_UpdatedBy", _iUserID);
            cmdInsert.Parameters.AddWithValue("@praad_ARAgingId", _iPRAgingID);

            AddParmValue(cmdInsert, "@praad_ARCustomerId",      _szCompanyID);
            AddParmValue(cmdInsert, "@praad_FileCompanyName",   _szCompanyName);
            AddParmValue(cmdInsert, "@praad_FileCityName",      _szCity);
            AddParmValue(cmdInsert, "@praad_FileStateName",     _szState);
            AddParmValue(cmdInsert, "@praad_FileZipCode",       _szZip);
            AddParmValue(cmdInsert, "@praad_PhoneNumber",       _szPhoneNumber);
            AddParmValue(cmdInsert, "@praad_Amount0to29",       _dAmount0to29);
            AddParmValue(cmdInsert, "@praad_Amount30to44",      _dAmount30to44);
            AddParmValue(cmdInsert, "@praad_Amount45to60",      _dAmount45to60);
            AddParmValue(cmdInsert, "@praad_Amount61Plus",      _dAmount61Plus);
            AddParmValue(cmdInsert, "@praad_CreditTerms",       _iCreditTerms);
                // Lumber
            AddParmValue(cmdInsert, "@praad_Amount1to30",     _dAmount1to30);
            AddParmValue(cmdInsert, "@praad_Amount31to60",    _dAmount31to60);
            AddParmValue(cmdInsert, "@praad_Amount61to90",    _dAmount61to90);
            AddParmValue(cmdInsert, "@praad_Amount91Plus",    _dAmount91Plus);
            AddParmValue(cmdInsert, "@praad_AmountCurrent",   _dAmountCurrent);
            AddParmValue(cmdInsert, "@praad_CreditTermsText", _szCreditTermsText);

            AddParmValue(cmdInsert, "@praad_TimeAged",          _szTimeAged);

            cmdInsert.ExecuteNonQuery();
        }

        private int _iCurrentID = -1;
        private int GetARAgingDetailID()
        {
            if (GetConfigValue("UseCRMForARAgindDetailID", false))
            {
                return GetNextRecordID(_dbTran, "PRARAgingDetail");
            }

            if (_iCurrentID == -1)
            {
                SqlCommand cmdGetMaxID = new SqlCommand("SELECT MAX(praad_ARAgingDetailId) AS ID FROM PRARAgingDetail;", _dbTran.Connection, _dbTran);
                cmdGetMaxID.CommandTimeout = GetConfigValue("ARAgingImportTimeout", 120);
                _iCurrentID = Convert.ToInt32(cmdGetMaxID.ExecuteScalar());
            }

            _iCurrentID++;
            return _iCurrentID;
        }


        /// <summary>
        /// Helper method to add the parameter and value to the command.
        /// </summary>
        /// <param name="dbCmd"></param>
        /// <param name="szParmName"></param>
        /// <param name="oParmValue"></param>
        protected void AddParmValue(SqlCommand dbCmd, string szParmName, object oParmValue) {
            if ((oParmValue is DateTime) &&
                (((DateTime)oParmValue) == DateTime.MinValue)) {
                dbCmd.Parameters.AddWithValue(szParmName, DBNull.Value);
            } else if ((oParmValue is int) &&
                    (((int)oParmValue) == -1)) {
                   dbCmd.Parameters.AddWithValue(szParmName, DBNull.Value);
            } else if ((oParmValue is decimal) &&
                    (((decimal)oParmValue) == -1M)) {
                dbCmd.Parameters.AddWithValue(szParmName, DBNull.Value);
            } else if (oParmValue == null) {
                dbCmd.Parameters.AddWithValue(szParmName, DBNull.Value);
            } else {
                dbCmd.Parameters.AddWithValue(szParmName, oParmValue);
            }
        }

        /// <summary>
        /// Helper method that returns the specified value provided
        /// it is expected.
        /// </summary>
        /// <param name="aszInputValues"></param>
        /// <param name="iValColIndex"></param>
        /// <returns></returns>
        protected int GetIntValue(string[] aszInputValues, int iValColIndex) {
            // Are we expecting this value?
            if (iValColIndex < 0) {
                return -1;
            }

            if ((string.IsNullOrEmpty(aszInputValues[iValColIndex])) ||
                (aszInputValues[iValColIndex].Trim() == string.Empty) ||
                (aszInputValues[iValColIndex].Trim() == "-")) {
                return 0;
            }

            return int.Parse(aszInputValues[iValColIndex]);
        }

        /// <summary>
        /// Helper method that returns the specified value provided
        /// it is expected.
        /// </summary>
        /// <param name="aszInputValues"></param>
        /// <param name="iValColIndex"></param>
        /// <returns></returns>
        protected decimal GetDecimalValue(string[] aszInputValues, int iValColIndex) {
            if (iValColIndex < 0) {
                return -1M;
            }

            if ((string.IsNullOrEmpty(aszInputValues[iValColIndex])) ||
                (aszInputValues[iValColIndex].Trim() == string.Empty) ||
                (aszInputValues[iValColIndex].Trim() == "-")) {
                return 0M;
            }

            return decimal.Parse(aszInputValues[iValColIndex].Replace("$", string.Empty).Replace(",", string.Empty).Replace("&", string.Empty).Replace("(", string.Empty).Replace(")", string.Empty).Replace("[", string.Empty).Replace("]", string.Empty).Replace("#", string.Empty));
        }

        /// <summary>
        /// Helper method that returns the specified value provided
        /// it is expected.
        /// </summary>
        /// <param name="aszInputValues"></param>
        /// <param name="iValColIndex"></param>
        /// <returns></returns>
        protected string GetStringValue(string[] aszInputValues, int iValColIndex) {
            if (iValColIndex < 0) {
                return null;
            }
            return aszInputValues[iValColIndex].Trim();
        }

        /// <summary>
        /// Looks for our value in the current header row.  If not the correct
        /// row, the current value is returned.
        /// </summary>
        /// <param name="aszInputValues"></param>
        /// <param name="iRowIndex"></param>
        /// <param name="iValRowIndex"></param>
        /// <param name="iValColIndex"></param>
        /// <param name="dtCurrentValue"></param>
        /// <returns></returns>
        protected DateTime GetHeaderDateValue(string[] aszInputValues, int iRowIndex, int iValRowIndex, int iValColIndex, DateTime dtCurrentValue) {

            // Are we expecting this value?
            if (iValColIndex < 0) {
                return dtCurrentValue;
            }

            // If we're looking for a specific row
            // and this isn't it, return nothing.
            if  ((iValRowIndex > -1) &&
                (iRowIndex != iValRowIndex)) {
                return dtCurrentValue;
            }

            // If we're looking for a detail row,
            // then skip the header rows.
            if ((iValRowIndex == -1) &&
                (iRowIndex <= _iNumberHeaderLines)) {
                return dtCurrentValue;
            }

            return GetDateValue(aszInputValues[iValColIndex]);
        }

        /// <summary>
        /// Helper method that returns a header value (i.e. PRARAging)
        /// if we expect one.
        /// </summary>
        /// <param name="aszInputValues"></param>
        /// <param name="iRowIndex"></param>
        /// <param name="iValRowIndex"></param>
        /// <param name="iValColIndex"></param>
        /// <param name="szCurrentValue"></param>
        /// <returns></returns>
        protected string GetHeaderDateSelectionValue(string[] aszInputValues, int iRowIndex, int iValRowIndex, int iValColIndex, string szCurrentValue) {

            // Are we expecting this value?
            if (iValColIndex < 0) {
                return _szDefaultDateSelectionCriteria;
            }
            
            // If we're looking for a specific row
            // and this isn't it, return nothing.
            if ((iValRowIndex > -1) &&
                (iRowIndex != iValRowIndex)) {
                return szCurrentValue;
            }

            // If we're looking for a detail row,
            // then skip the header rows.
            if ((iValRowIndex == -1) &&
                (iRowIndex <= _iNumberHeaderLines)) {
                return szCurrentValue;
            }

            return GetDateCriteriaCustomCaption(aszInputValues[iValColIndex]);
        }

        /// <summary>
        /// Translates the input Date Criteria value to the
        /// PIKS custom caption value.
        /// </summary>
        /// <param name="szInputDateSelectionCriteria"></param>
        /// <returns></returns>
        protected string GetDateCriteriaCustomCaption(string szInputDateSelectionCriteria) {
            if (string.IsNullOrEmpty(szInputDateSelectionCriteria)) {
                return szInputDateSelectionCriteria;
            }
            
            string szInputAsLower = szInputDateSelectionCriteria.ToLower();


            if (szInputAsLower.IndexOf("due") >= 0) {
                return "DUE";  
            }

            if (szInputAsLower.IndexOf("invoice") >= 0) {
                return "INV";
            }

            if (szInputAsLower.IndexOf("ship") >= 0) {
                return "SHP";
            }

            throw new ApplicationException("Unknown Date Selection Criteria value found: " + szInputDateSelectionCriteria);
        }


        /// <summary>
        /// Parse our date string into a DateTime value based
        /// on the specified value.  We don't just blindly try
        /// to convert the date 'cause formats such as ddmmyyyy
        /// and mmddyyyy will often convert to each other easily
        /// in the early part of the month.
        /// </summary>
        /// <param name="szDateValue"></param>
        /// <returns></returns>
        protected DateTime GetDateValue(string szDateValue) {

            string szDateOnly = string.Empty;
            int iValue = 0;

            // If this is a standard US format, attempt
            // to parse
            if ((_szDateFormat == DATE_FORMAT_MMDDYY) ||
                (_szDateFormat == DATE_FORMAT_MMDDYYYY)) {
                DateTime dtResult = new DateTime();

                if (DateTime.TryParse(szDateValue, out dtResult)) {
                    return dtResult;
                }
            }

            // If this is a European format, attempt
            // to parse
            if ((_szDateFormat == DATE_FORMAT_MMDDYY) ||
                (_szDateFormat == DATE_FORMAT_MMDDYYYY)) {
                DateTime dtResult = new DateTime();
                CultureInfo oCulture = new CultureInfo("fr-FR", true);

                if (DateTime.TryParse(szDateValue, oCulture, DateTimeStyles.None, out dtResult)) {
                    return dtResult;
                }
            }


            // Some of our header values are mixed strings and
            // numbers.  We need to extract the numbers first.
            for (int i = 0; i < szDateValue.Length; i++) {
                if (int.TryParse(szDateValue[i].ToString(), out iValue)) {
                    szDateOnly += szDateValue[i];
                }
            }

            
            if (szDateOnly.Length < 6) {
                throw new ApplicationException("Invalid Date Value Found: " + szDateValue);
            }

            // Now we have a numeric value.  It's time
            // to convert it based on the format.
            int iDay = 0;
            int iMonth = 0;
            int iYear = 0;

            switch (_szDateFormat) {
                case DATE_FORMAT_DDMMYY:
                    iDay = int.Parse(szDateOnly.Substring(0, 2));
                    iMonth = int.Parse(szDateOnly.Substring(2, 2));
                    iYear = int.Parse(szDateOnly.Substring(4, 2));
                    iYear += GetConfigValue("CenturyOffset", 2000);
                    break;
                case DATE_FORMAT_DDMMYYYY:
                    iDay = int.Parse(szDateOnly.Substring(0, 2));
                    iMonth = int.Parse(szDateOnly.Substring(2, 2));
                    iYear = int.Parse(szDateOnly.Substring(4, 4));
                    break;
                case DATE_FORMAT_MMDDYY:


                    iDay = int.Parse(szDateOnly.Substring(2, 2));
                    iMonth = int.Parse(szDateOnly.Substring(0, 2));
                    iYear = int.Parse(szDateOnly.Substring(4, 2));
                    iYear += GetConfigValue("CenturyOffset", 2000);
                    break;
                case DATE_FORMAT_MMDDYYYY:
                    iDay = int.Parse(szDateOnly.Substring(2, 2));
                    iMonth = int.Parse(szDateOnly.Substring(0, 2));
                    iYear = int.Parse(szDateOnly.Substring(4, 4));
                    break;
                case DATE_FORMAT_YYMMDD:
                    iDay = int.Parse(szDateOnly.Substring(4, 2));
                    iMonth = int.Parse(szDateOnly.Substring(2, 2));
                    iYear = int.Parse(szDateOnly.Substring(0, 2));
                    iYear += GetConfigValue("CenturyOffset", 2000);
                    break;
                case DATE_FORMAT_YYYYMMDD:
                    iDay = int.Parse(szDateOnly.Substring(6, 2));
                    iMonth = int.Parse(szDateOnly.Substring(4, 2));
                    iYear = int.Parse(szDateOnly.Substring(0, 4));
                    break;
            }
            return new DateTime(iYear, iMonth, iDay);
        }

        /// <summary>
        /// Returns the count of distinct input company IDs that do not have an
        /// associated PRCo BBID.
        /// </summary>
        /// <returns></returns>
        protected int GetUnmatchedCount() {
            SqlCommand cmdCount = new SqlCommand(SQL_COUNT_UNMATCHED, _dbTran.Connection, _dbTran);
            cmdCount.CommandTimeout = GetConfigValue("ARAgingImportTimeout", 120);

            cmdCount.Parameters.AddWithValue("@prar_CompanyID", _iCompanyID);
            cmdCount.Parameters.AddWithValue("@praad_ARAgingID", _iPRAgingID);

            SqlDataReader oReader = cmdCount.ExecuteReader();
            try {
                oReader.Read();
                return oReader.GetInt32(0);
            } finally {
                oReader.Close();
            }
        }

        /// <summary>
        /// Determines if a PRARAging file already 
        /// exists for this company and run date.
        /// </summary>
        /// <returns></returns>
        protected bool IsDuplicateImport() {

            SqlCommand cmdCount = new SqlCommand(SQL_DUP_CHECK, _dbTran.Connection, _dbTran);
            cmdCount.CommandTimeout = GetConfigValue("ARAgingImportTimeout", 120);

            cmdCount.Parameters.AddWithValue("@praa_CompanyID", _iCompanyID);
            cmdCount.Parameters.AddWithValue("@praa_Date", _dtAsOfDate);

            SqlDataReader oReader = cmdCount.ExecuteReader();
            try {
                oReader.Read();
                if (oReader.GetInt32(0) > 0) {
                    return true;
                }

                return false;
            } finally {
                oReader.Close();
            }
        }

        private const string FIELD_LENGTH_ERROR = "{0} field length of {1} exceeds maximum allowable length of {2}.";
        protected void CheckFieldLength(string fieldValue,
                                        int maxLength,
                                        string fieldName) {
            if (string.IsNullOrEmpty(fieldValue)) {
                return;
            }

            if (fieldValue.Length > maxLength)
            {
                throw new ApplicationException(string.Format(FIELD_LENGTH_ERROR,
                                                             fieldName,
                                                             fieldValue.Length.ToString(),
                                                             maxLength.ToString()));
            }
        }

        protected int GetExpectedDetailFieldCount()
        {
            int iMaxColIndex = 0;

            iMaxColIndex = GetHigherValue(iMaxColIndex, _iCompanyIDColIndex);
            iMaxColIndex = GetHigherValue(iMaxColIndex, _iCompanyNameColIndex);
            iMaxColIndex = GetHigherValue(iMaxColIndex, _iCityNameColIndex);
            iMaxColIndex = GetHigherValue(iMaxColIndex, _iStateNameColIndex);
            iMaxColIndex = GetHigherValue(iMaxColIndex, _iZipCodeColIndex);
            iMaxColIndex = GetHigherValue(iMaxColIndex, _iAmount0to29ColIndex);
            iMaxColIndex = GetHigherValue(iMaxColIndex, _iAmount30to44ColIndex);
            iMaxColIndex = GetHigherValue(iMaxColIndex, _iAmount45to60ColIndex);
            iMaxColIndex = GetHigherValue(iMaxColIndex, _iAmount61PlusColIndex);
            iMaxColIndex = GetHigherValue(iMaxColIndex, _iCreditTermsColIndex);
            iMaxColIndex = GetHigherValue(iMaxColIndex, _iTimeAgedColIndex);
            iMaxColIndex = GetHigherValue(iMaxColIndex, _iPhoneNumberColIndex);
            iMaxColIndex = GetHigherValue(iMaxColIndex, _iAmount1to30ColIndex);
            iMaxColIndex = GetHigherValue(iMaxColIndex, _iAmount31to60ColIndex);
            iMaxColIndex = GetHigherValue(iMaxColIndex, _iAmount61to90ColIndex);
            iMaxColIndex = GetHigherValue(iMaxColIndex, _iAmount91PlusColIndex);
            iMaxColIndex = GetHigherValue(iMaxColIndex, _iAmountCurrentColIndex);
            iMaxColIndex = GetHigherValue(iMaxColIndex, _iCreditTermsTextColIndex);

            return iMaxColIndex + 1;
        }

        protected int GetHigherValue(int Val1, int Val2)
        {
            if (Val1 > Val2)
            {
                return Val1;
            }

            return Val2;
        }
    }
}