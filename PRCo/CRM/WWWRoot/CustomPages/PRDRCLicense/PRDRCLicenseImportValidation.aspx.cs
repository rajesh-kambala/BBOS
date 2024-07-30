/***********************************************************************
 Copyright Produce Reporter Company 2006

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

***********************************************************************
***********************************************************************/
using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.OleDb;
using System.Configuration;
using System.Collections;
using System.IO;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

namespace PRCo.BBS.CRM  {
    public partial class PRDRCLicenseImportValidation : PageBase {

        protected string sSID = "";
        protected int _iUserID;

        protected int _iNewCount;
        protected int _iChangedCount;
        protected int _iUnchangedCount;
        protected int _iRecordCount;

        protected string _szChangedRowCSSClass = "Row2";
        protected string _szUnchangedRowCSSClass = "Row2";
        protected string _szNewRowCSSClass = "Row2";

        protected const string SQL_SELECT_DRC_LICENSE = "SELECT prdr_LicenseNumber, prdr_MemberName, prdr_LicenseStatus, prdr_CoverageDate, prdr_PaidToDate, ISNULL(prdr_Address + ' ', '') + ISNULL(prdr_City + ' ', '') + ISNULL(prdr_State + ', ', '') + ISNULL(prdr_Country + ' ', '') + ISNULL(prdr_PostalCode, '') As MailAddress, ISNULL(prdr_Address2 + ' ', '') + ISNULL(prdr_City2 + ' ', '') + ISNULL(prdr_State2 + ', ', '') + ISNULL(prdr_Country2 + ' ', '') + ISNULL(prdr_PostalCode2, '') As PhysicalAddress, prdr_BusinessType, ISNULL(prdr_Salutation + ' ', '') + ISNULL(prdr_ContactFirstAndMiddleName + ' ', '') + ISNULL(prdr_ContactLastName, '') As ContactName, prdr_ContactJobTitle, prdr_Phone, prdr_Fax, prdr_CompanyID FROM PRDRCLicense WHERE prdr_LicenseNumber=@prdr_LiceneseNumber";
        protected const string SQL_SELECT_DRC_LICENSE_EXCEL = "SELECT [DRC Number], [Company Name], Status , [Date Coverage], [Date Paid To], [Mailing Address], [Physical Address], [Business Type], [Contact Name], [Job Title], Phone, Fax FROM [Sheet1$]";

        private const int COL_INDEX_DRC_NUMBER = 0;
        private const int COL_INDEX_COMPANY_NAME = 1;
        private const int COL_INDEX_STATUS = 2;
        private const int COL_INDEX_DATE_COVERAGE = 3;
        private const int COL_INDEX_DATE_PAID_TO = 4;
        private const int COL_INDEX_MAILING_ADDRESS = 5;
        private const int COL_INDEX_PHYSICAL_ADDRESS = 6;
        private const int COL_INDEX_BUSINESS_TYPE = 7;
        private const int COL_INDEX_CONTACT_NAME = 8;
        private const int COL_INDEX_JOB_TITLE = 9;
        private const int COL_INDEX_PHONE = 10;
        private const int COL_INDEX_FAX = 11;
        private const int COL_INDEX_COMPANY_ID = 12;

        /// <summary>
        /// Provides the functionality to validate the DRC License file.
        /// No data is actually stored.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        override protected void Page_Load(object sender, EventArgs e) {
            base.Page_Load(sender, e);

            Server.ScriptTimeout = GetConfigValue("DRCLicenseImportValidationScriptTimeout", 3600);

            lblError.Text = string.Empty;
            //lblDRCFileCount.Text = string.Empty;


            // Upload link
            lnkUpload.NavigateUrl = "javascript:upload();";
            this.lnkUpload.Text = "Validate DRC License File";
            this.lnkUploadImage.NavigateUrl = "javascript:upload();";
            this.lnkUploadImage.ImageUrl = "/" + this._szAppName + "/img/Buttons/Attachment.gif";
            this.lnkUploadImage.Text = "Upload";

            // Upload link
            //this.lnkContinue.NavigateUrl = "javascript:pageContinue();";
            //this.lnkContinue.Text = "Continue";
            //this.lnkContinueImage.NavigateUrl = "javascript:pageContinue();";
            //this.lnkContinueImage.ImageUrl = "/" + this._szAppName + "/img/Buttons/Continue.gif";
            //this.lnkContinueImage.Text = "Continue";

            if (!IsPostBack) {
                sSID = Request.Params.Get("SID");
                hidSID.Text = this.sSID;

            } else {
                sSID = hidSID.Text;
                ProcessForm();
            }
        }

        /// <summary>
        /// Helper methos that sets the stylesheets for the current page.
        /// </summary>
        override protected void SetStyleSheets() {
            AddStyleSheet("eware.css");
        }

        protected void ProcessForm() {

            // Check to see if a license file was uploaded
            if (fileDRCFileUpload.PostedFile == null
                || fileDRCFileUpload.PostedFile.FileName == null
                || fileDRCFileUpload.PostedFile.FileName.Length == 0
                || fileDRCFileUpload.PostedFile.ContentLength == 0) {

                lblError.Text = "No file found to process";
                return;
            }

            if (!fileDRCFileUpload.PostedFile.FileName.ToLower().EndsWith(".xls")) {
                lblError.Text = "The DRC License file must be an MS Excel file.";
                return;
            }

            try {
                ProcessFile(fileDRCFileUpload.PostedFile);
            } catch (Exception e) {
                lblError.Text = "An unexpected error has occured.  " + e.Message;
            }
        }


        /// <summary>
        /// Process uploaded file
        /// </summary>
        /// <param name="oPostedFile"></param>
        protected void ProcessFile(HttpPostedFile oPostedFile) {

            string szFileName = GetConfigValue("DRCLicenseFileTempFile", @"C:\Temp\DRCLicense.xls");

            // First we need to save the file to disk                
            oPostedFile.SaveAs(szFileName);

            string szExcelConnectionString = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + szFileName + ";Extended Properties=\"Excel 8.0;HDR=YES;\"";
            OleDbConnection oExcelConnection = new OleDbConnection(szExcelConnectionString);
            OleDbCommand oExcelCommand = new OleDbCommand(SQL_SELECT_DRC_LICENSE_EXCEL, oExcelConnection);
            
            SqlConnection dbConn = OpenDBConnection();
            oExcelConnection.Open();

            try {
                using (OleDbDataReader oExcelReader = oExcelCommand.ExecuteReader()) {
                    while (oExcelReader.Read()) {
                        _iRecordCount++;
                        ProcessDRCRow(dbConn, oExcelReader);
                    }
                }
            } finally {
                dbConn.Close();
                oExcelConnection.Close();

                File.Delete(szFileName);
            }

            pnlDRCFileStats.Visible = true;
            lblDRCChangeCount.Text = _iChangedCount.ToString("###,###,##0") + " Changed DRC License Records Found.";
            lblDRCNewCount.Text = _iNewCount.ToString("###,###,##0") + " New DRC License Records Found.";
            lblDRCUnchangedCount.Text = _iUnchangedCount.ToString("###,###,##0") + " Unchanged DRC License Records Found.";

            if (_iNewCount == 0) {
                TableRow oRow = new TableRow();
                oRow.CssClass = "ROW1";
                tblNew.Rows.Add(oRow);

                TableCell oCell = AddCell(oRow, "No records found.");
                oCell.ColumnSpan = 14;
            }

            if (_iChangedCount == 0) {
                TableRow oRow = new TableRow();
                oRow.CssClass = "ROW1";
                tblChanged.Rows.Add(oRow);

                TableCell oCell = AddCell(oRow, "No records found.");
                oCell.ColumnSpan = 14;
            }


            if (_iUnchangedCount == 0) {
                TableRow oRow = new TableRow();
                oRow.CssClass = "ROW1";
                tblUnchanged.Rows.Add(oRow);

                TableCell oCell = AddCell(oRow, "No records found.");
                oCell.ColumnSpan = 3;
            }
        }



        /// <summary>
        /// Processes the DRC License data represented by the curren record
        /// in the specified oExcelReader.
        /// </summary>
        /// <param name="dbConn"></param>
        /// <param name="oExcelReader"></param>
        protected void ProcessDRCRow(SqlConnection dbConn, OleDbDataReader oExcelReader) {

            SqlCommand cmdCount = new SqlCommand(SQL_SELECT_DRC_LICENSE, dbConn);
            cmdCount.Parameters.AddWithValue("@prdr_LiceneseNumber", GetString(oExcelReader.GetString(COL_INDEX_DRC_NUMBER)));

            using (SqlDataReader oReader = cmdCount.ExecuteReader()) {

                if (!oReader.Read()) {
                    // If we didn't find it, this must be a
                    // new DRC License
                    _iNewCount++;

                    if (_szNewRowCSSClass == "ROW2") {
                        _szNewRowCSSClass = "ROW1";
                    } else {
                        _szNewRowCSSClass = "ROW2";
                    }

                    AddRowToTable(tblNew, oExcelReader, _szNewRowCSSClass, false);
                } else {

                    // Now determine if it has changed or not
                    if ((GetString(oExcelReader[COL_INDEX_COMPANY_NAME]) == GetString(oReader[COL_INDEX_COMPANY_NAME])) &&
                        (GetString(oExcelReader[COL_INDEX_STATUS]) == GetString(oReader[COL_INDEX_STATUS])) &&
                        (GetString(oExcelReader[COL_INDEX_DATE_COVERAGE]) == GetString(oReader[COL_INDEX_DATE_COVERAGE])) &&
                        (GetString(oExcelReader[COL_INDEX_DATE_PAID_TO]) == GetString(oReader[COL_INDEX_DATE_PAID_TO])) &&
                        (GetString(oExcelReader[COL_INDEX_MAILING_ADDRESS]) == GetString(oReader[COL_INDEX_MAILING_ADDRESS])) &&
                        (GetString(oExcelReader[COL_INDEX_PHYSICAL_ADDRESS]) == GetString(oReader[COL_INDEX_PHYSICAL_ADDRESS])) &&
                        (GetString(oExcelReader[COL_INDEX_BUSINESS_TYPE]) == GetString(oReader[COL_INDEX_BUSINESS_TYPE])) &&
                        (GetString(oExcelReader[COL_INDEX_CONTACT_NAME]) == GetString(oReader[COL_INDEX_CONTACT_NAME])) &&
                        (GetString(oExcelReader[COL_INDEX_JOB_TITLE]) == GetString(oReader[COL_INDEX_JOB_TITLE])) &&
                        (GetString(oExcelReader[COL_INDEX_PHONE]) == GetString(oReader[COL_INDEX_PHONE])) &&
                        (GetString(oExcelReader[COL_INDEX_FAX]) == GetString(oReader[COL_INDEX_FAX]))) {
                        _iUnchangedCount++;

                        TableRow oRow = new TableRow();
                        if (_szUnchangedRowCSSClass == "ROW2") {
                            _szUnchangedRowCSSClass = "ROW1";
                        } else {
                            _szUnchangedRowCSSClass = "ROW2";
                        }
                        oRow.CssClass = _szUnchangedRowCSSClass;

                        tblUnchanged.Rows.Add(oRow);

                        AddCell(oRow, GetString(oReader[COL_INDEX_COMPANY_ID]));
                        AddCell(oRow, GetString(oReader[COL_INDEX_COMPANY_NAME]));
                        AddCell(oRow, GetString(oReader[COL_INDEX_DRC_NUMBER]));


                    } else {
                        _iChangedCount++;

                        if (_szChangedRowCSSClass == "ROW2") {
                            _szChangedRowCSSClass = "ROW1";
                        } else {
                            _szChangedRowCSSClass = "ROW2";
                        }

                        AddRowToTable(tblChanged, oReader, _szChangedRowCSSClass, true);

                        if (_szChangedRowCSSClass == "ROW2") {
                            _szChangedRowCSSClass = "ROW1";
                        } else {
                            _szChangedRowCSSClass = "ROW2";
                        }

                        AddRowToTable(tblChanged, oExcelReader, _szChangedRowCSSClass, false);
                    }
                }
            }
        }
        
        /// <summary>
        /// Helper method that returns an empty string instead of 
        /// NULL if no value is found.
        /// </summary>
        /// <param name="oValue"></param>
        /// <returns></returns>
        override protected string GetString(object oValue) {
            string szValue = base.GetString(oValue);
            if (szValue == null) {
                return string.Empty;
            }

            return szValue;
        }

        /// <summary>
        /// Helper method that adds a DRC License data row to the specified table.
        /// </summary>
        /// <param name="oTable"></param>
        /// <param name="oReader"></param>
        /// <param name="szRowCSSClass"></param>
        /// <param name="IsBBS"></param>
        protected void AddRowToTable(Table oTable, IDataReader oReader, string szRowCSSClass, bool IsBBS) {

            TableRow oRow = new TableRow();
            oRow.CssClass = szRowCSSClass;
            oTable.Rows.Add(oRow);

            if (IsBBS) {
                AddCell(oRow, "BBS");
            } else {
                AddCell(oRow, "DRC File");
            }

            if (IsBBS) {
                AddCell(oRow, GetString(oReader[COL_INDEX_COMPANY_ID]));
            } else {
                AddCell(oRow, "&nbsp;");
            }

            AddCell(oRow, GetString(oReader[COL_INDEX_COMPANY_NAME]));
            AddCell(oRow, GetString(oReader[COL_INDEX_DRC_NUMBER]));
            AddCell(oRow, GetString(oReader[COL_INDEX_STATUS]));
            AddCell(oRow, GetString(oReader[COL_INDEX_DATE_COVERAGE]));
            AddCell(oRow, GetString(oReader[COL_INDEX_DATE_PAID_TO]));
            AddCell(oRow, GetString(oReader[COL_INDEX_MAILING_ADDRESS]));
            AddCell(oRow, GetString(oReader[COL_INDEX_PHYSICAL_ADDRESS]));
            AddCell(oRow, GetString(oReader[COL_INDEX_BUSINESS_TYPE]));
            AddCell(oRow, GetString(oReader[COL_INDEX_CONTACT_NAME]));
            AddCell(oRow, GetString(oReader[COL_INDEX_JOB_TITLE]));
            AddCell(oRow, GetString(oReader[COL_INDEX_PHONE]));
            AddCell(oRow, GetString(oReader[COL_INDEX_FAX]));
        }

        /// <summary>
        /// Helper method that adds a cell to the specified row
        /// with the specified text
        /// </summary>
        /// <param name="oRow"></param>
        /// <param name="szText"></param>
        /// <returns></returns>
        protected TableCell AddCell(TableRow oRow, string szText) {
            TableCell oCell = new TableCell();
            oCell.Text = szText;
            oRow.Cells.Add(oCell);

            return oCell;
        }
    }
}
