/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2021

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: EMCW_FinancialStatement
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.IO;
using System.Text;
using PRCo.EBB.BusinessObjects;
using PRCo.EBB.Util;
using TSI.Arch;
using TSI.BusinessObjects;
using TSI.DataAccess;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This page is part of the Edit My Company Wizard.  It allows users to upload financial statements.
    /// 
    /// The jeopardy date range for this page is a configurable value.
    /// 
    /// If the specified company's industry type is supply and service, display an error message.  This
    /// page does not apply to these types of companies.
    /// 
    /// On save, the files will be uploaded to the specified root folder (config value) using the BBID
    /// and statement date in the same manner that PIKS looks for it.
    ///
    /// A task will be created for the appropriate user (config value) that containts the BBID, hyperlink 
    /// to the uploaded file, and the name of the file as it should be entered into the Financial Statement
    /// screen.
    /// </summary>
    public partial class EMCW_FinancialStatement : EMCWizardBase
    {
        private const string SQL_GET_LAST_FINANCIAL_STMT = "SELECT TOP 1 prfs_FinancialId, prfs_StatementDate, " +
            "prfs_Type " +
            "FROM PRFinancial WITH (NOLOCK) " +
            "WHERE prfs_CompanyID = {0} " +
            "AND prfs_Deleted IS NULL " +
            "ORDER BY prfs_StatementDate DESC";

        protected const string SQL_INSERT_PRFINANCIAL = "INSERT INTO PRFinancial " +
            "(prfs_CreatedBy, prfs_CreatedDate, prfs_UpdatedBy, prfs_UpdatedDate, prfs_TimeStamp, " +
            "prfs_CompanyId, prfs_StatementDate, prfs_Type, prfs_InterimMonth, prfs_FinancialId, prfs_StatementImageFile) " +
            "VALUES " +
            "({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10})";

        private DateTime dtLastStatementDate;
        private string szLastStatementType;

        /// <summary>
        /// Calls page functions required to build and process this page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            // If the specified company's industry type is supply and service, then display an 
            // error message.  
            if (szIndustryType == GeneralDataMgr.INDUSTRY_TYPE_SUPPLY)
                throw new ApplicationUnexpectedException(Resources.Global.ErrorInvalidIndustryType);

            // Set page title, sub-title
            SetPageTitle(Resources.Global.EditCompany, Resources.Global.FinancialStatement);

            // Add company submenu to this page
            SetSubmenu("btnFinancialStatement", blnDisableValidation: true);

            // Setup page for file upload
            AddDoubleClickPreventionJS(btnSave);
            EnableFormValidation();
            Form.Attributes.Add("enctype", "multipart/form-data");

            btnCancel.OnClientClick = "bEnableValidation=false;";

            QuickFind oQuickFind = (QuickFind)this.Master.FindControl("QuickFind");
            oQuickFind.GetSearchButton().OnClientClick = "DisableValidation();";

            if (!IsPostBack)
            {
                LoadLookupValues();

                PopulateForm();

                // Add toggle functions 
                ddlStatementType.Attributes.Add("onclick", "ToggleStatementMonths(this);");
            }
        }

        /// <summary>
        /// Helper method to return a handle to the Company Details Header used on the page to display 
        /// the company BB #, name, and location
        /// </summary>
        /// <returns></returns>
        protected override EMCW_CompanyHeader GetEditCompanyWizardHeader()
        {
            return ucCompanyDetailsHeader;
        }

        /// <summary>
        /// Populates the form controls for the specified
        /// company
        /// </summary>
        protected void PopulateForm()
        {
            litHeaderText.Visible = false;
            if (dtJeopardyDate > DateTime.MinValue)
            {
                // Setup jeopardy date notice
                DateTime dtJeopardyWindowStart = dtJeopardyDate.AddDays(0 - Utilities.GetIntConfigValue("FinancialStatementJeopardyStartDays", 60));
                DateTime dtJeoparydWindowEnd = dtJeopardyDate.AddDays(Utilities.GetIntConfigValue("FinancialStatementJeopardyEndDays", 0));
                if (System.DateTime.Now >= dtJeopardyWindowStart
                    && System.DateTime.Now <= dtJeoparydWindowEnd)
                {
                    litHeaderText.Text = String.Format(Resources.Global.EditFinancialStatementHeader, dtJeopardyDate.ToShortDateString());
                    litHeaderText.Visible = true;
                }
            }

            // Setup Last Statement Date fields
            GetLastFinancialStatementInfo();

            if (dtLastStatementDate != DateTime.MinValue)
                lblLastStatementDate.Text = dtLastStatementDate.ToShortDateString();

            if (!String.IsNullOrEmpty(szLastStatementType))
                lblLastStatementType.Text = GetReferenceValue("prfs_Type", szLastStatementType);
        }

        /// <summary>
        /// Loads all of the databound controls setting 
        /// thier default values.
        /// </summary>
        protected void LoadLookupValues()
        {
            // Bind statement type drop down list
            BindLookupValues(ddlStatementType, GetReferenceData("prfs_Type"));

            // Bind number of months list
            List<ICustom_Caption> lLookupValues = new List<ICustom_Caption>();
            for (int i = 1; i <= 12; i++)
            {
                ICustom_Caption oCustom_Caption = new Custom_Caption();
                oCustom_Caption.Code = i.ToString("00");
                oCustom_Caption.Meaning = i.ToString("00");
                lLookupValues.Add(oCustom_Caption);
            }
            BindLookupValues(ddlMonths, lLookupValues);
        }

        /// <summary>
        /// Handles the Save on click event.  Creates the task and displays a message informing the user 
        /// the data has been saved.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnSave_Click(object sender, EventArgs e)
        {
            // Check to see if a file was uploaded
            if (!fileStatement.HasFile)
            {
                AddUserMessage(string.Format(Resources.Global.UploadFileMissingMsg, "").Replace("  ", " "));
                return;
            }

            // Validate file upload types to : CSV, TXT, XLS, DOC, PSR, PDF, TIF, GIF, JPG
            if (!(fileStatement.PostedFile.FileName.ToLower().EndsWith(".csv") ||
                fileStatement.PostedFile.FileName.ToLower().EndsWith(".txt") ||
                fileStatement.PostedFile.FileName.ToLower().EndsWith(".xls") ||
                fileStatement.PostedFile.FileName.ToLower().EndsWith(".xlsx") ||
                fileStatement.PostedFile.FileName.ToLower().EndsWith(".doc") ||
                fileStatement.PostedFile.FileName.ToLower().EndsWith(".psr") ||
                fileStatement.PostedFile.FileName.ToLower().EndsWith(".pdf") ||
                fileStatement.PostedFile.FileName.ToLower().EndsWith(".tif") ||
                fileStatement.PostedFile.FileName.ToLower().EndsWith(".gif") ||
                fileStatement.PostedFile.FileName.ToLower().EndsWith(".jpg")))
            {
                AddUserMessage(string.Format(Resources.Global.ErrorInvalidFileType, "CSV, TXT, XLS, XLSX, DOC, PSR, PDF, TIF, GIF, JPG"));
                return;
            }

            string szRelativePath = null;
            DateTime dtStatementDate;

            try
            {
                // Retrieve full file upload path
                string strFilePath = Utilities.GetConfigValue("FinancialStatementUploadPath");

                // Create the new file name
                
                // Use current culture when converting date to prevent runtime on date conversion   
                //DateTime dtStatementDate = Convert.ToDateTime(txtStatementDate.Text);
                CultureInfo culture = CultureInfo.CurrentCulture;
                DateTimeStyles styles = DateTimeStyles.None;
                DateTime.TryParse(txtStatementDate.Text, culture, styles, out dtStatementDate);

                string strFileName = iCompanyID.ToString() + "_" + dtStatementDate.ToString("yyMMdd") + "_" + DateTime.Now.ToString("yyMMdd-hhmmss");
                string strFileExtension = Path.GetExtension(fileStatement.PostedFile.FileName);

                //strFileName += strFileExtension;

                // Create the full file name using the file path and name created
                string strFullFileName = strFilePath + strFileName + strFileExtension;
                szRelativePath = strFileName + strFileExtension;

                // Check if a file with this name already exists
                int count = 1;
                while (File.Exists(strFullFileName))
                {
                    count++;
                    string suffix = " (" + count.ToString() + ")";
                    strFullFileName = strFilePath + strFileName + suffix + strFileExtension;
                    szRelativePath = strFileName + suffix + strFileExtension;
                }

                // Save the uploaded file to disk
                fileStatement.SaveAs(strFullFileName);
            }
            catch (Exception ex)
            {
                throw new ApplicationUnexpectedException(String.Format(Resources.Global.ErrorFileUpload, ex.Message));
            }

            IDbTransaction oTran = GetObjectMgr().BeginTransaction();
            try
            {
                // Create the PRFinancial record
                ArrayList oParameters = new ArrayList();

                oParameters.Add(new ObjectParameter("prfs_CreatedBy", _oUser.prwu_WebUserID));
                oParameters.Add(new ObjectParameter("prfs_CreatedDate", DateTime.Now.ToString("g", DateTimeFormatInfo.InvariantInfo)));
                oParameters.Add(new ObjectParameter("prfs_UpdatedBy", _oUser.prwu_WebUserID));
                oParameters.Add(new ObjectParameter("prfs_UpdatedDate", DateTime.Now.ToString("g", DateTimeFormatInfo.InvariantInfo)));
                oParameters.Add(new ObjectParameter("prfs_TimeStamp", DateTime.Now.ToString("g", DateTimeFormatInfo.InvariantInfo)));
                oParameters.Add(new ObjectParameter("prfs_CompanyId", iCompanyID));
                oParameters.Add(new ObjectParameter("prfs_StatementDate", dtStatementDate.ToString("d", DateTimeFormatInfo.InvariantInfo))); 
                oParameters.Add(new ObjectParameter("prfs_Type", ddlStatementType.SelectedValue));
                if (ddlStatementType.SelectedValue == "I")
                    oParameters.Add(new ObjectParameter("prfs_InterimMonth", ddlMonths.SelectedValue));
                else
                    oParameters.Add(new ObjectParameter("prfs_InterimMonth", null));
                oParameters.Add(new ObjectParameter("prfs_FinancialId", GetObjectMgr().GetRecordID("PRFinancial", oTran)));
                oParameters.Add(new ObjectParameter("prfs_StatementImageFile", szRelativePath));

                string szSQL = GetObjectMgr().FormatSQL(SQL_INSERT_PRFINANCIAL, oParameters);
                GetObjectMgr().ExecuteInsert("PRFinancial", szSQL, oParameters, oTran);

                // Generate a task for the appropriate user that contains the BBID, Hyperlink to the
                // uploaded file, and the name of the file as it should be created into the Financial
                // Statement screen    
                StringBuilder sbMsg = new StringBuilder();

                sbMsg.Append("A new financial statement was uploaded with statement date " + dtStatementDate.ToString("d", DateTimeFormatInfo.InvariantInfo) + "."); //txtStatementDate.Text

                GetObjectMgr().CreateTask(Utilities.GetIntConfigValue("CompanyUploadFinancialStatementAssignedToUserID", 1010),
                                          "Pending",
                                          sbMsg.ToString(),
                                          Utilities.GetConfigValue("CompanyUploadFinancialStatementCategory", ""),
                                          Utilities.GetConfigValue("CompanyUploadFinancialStatementSubcategory", ""),
                                          oTran);

                // Insert a self service audit trail record
                List<string> lCategoryCodes = new List<string>();
                lCategoryCodes.Add("FS");
                GetObjectMgr().InsertSelfServiceAuditTrail(lCategoryCodes, oTran);

                oTran.Commit();
            }
            catch
            {
                if (oTran != null)
                {
                    oTran.Rollback();
                }
                throw;
            }

            // Display message to user informing them that the data has been saved
            AddUserMessage(Resources.Global.SaveMsgFinancialStatement, true);

            // Refresh page
            Response.Redirect(PageConstants.EMCW_FINANCIAL_STATEMENT);
        }

        /// <summary>
        /// Handles the cancel on click event.  Takes the user to the member home page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnCancel_Click(object sender, EventArgs e)
        {
            // Takes the user to the member home page
            Response.Redirect(PageConstants.BBOS_HOME);
        }

        /// <summary>
        /// Helper method used to retrieve the last financial statement information required for 
        /// display on this page.  This includes the last statement date and type.
        /// </summary>
        protected void GetLastFinancialStatementInfo()
        {
            ArrayList oParameters = new ArrayList();

            oParameters.Add(new ObjectParameter("prfs_CompanyID", iCompanyID));
            string szSQL = GetObjectMgr().FormatSQL(SQL_GET_LAST_FINANCIAL_STMT, oParameters);

            // Use our own DBAccess object to 
            // avoid conflicts with open readers.
            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            oDBAccess.Logger = _oLogger;

            IDataReader oReader = oDBAccess.ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            try
            {
                while (oReader.Read())
                {
                    dtLastStatementDate = GetDBAccess().GetDateTime(oReader, "prfs_StatementDate");
                    szLastStatementType = GetDBAccess().GetString(oReader, "prfs_Type");
                }
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }
        }

        /// <summary>
        /// Set page to auto-generate javascript variables for form elements.
        /// </summary>
        /// <returns></returns>
        public override bool EnableJSClientIDTranslation()
        {
            return true;
        }


        protected override bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.CompanyEditFinancialStatementPage).HasPrivilege;
        }
    }
}
