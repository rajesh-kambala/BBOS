/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2023

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: DataExportConfirmSelections
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using TSI.Arch;
using TSI.DataAccess;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This screen provides the functionality for the user to download various data extracts.
    /// 
    /// The data export selections will include Contact Export - Company Only, Contact Export -
    /// Head Contacts Only, Contact Export - All Companies, and Company Data Export.  
    /// 
    /// The contact data exports will allow the user to select either a CSV or MS Outlook export
    /// format.
    /// 
    /// After selecting a data export and format the selected data the user will be redirected
    /// to the GetReport.aspx page where the download is processed.
    /// </summary>
    public partial class DataExportConfirmSelections : PageBase
    {
        /// <summary>
        /// Calls page functions required to build and process this page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            // Set page title
            SetPageTitle(String.Format(Resources.Global.ConfirmSelections, Resources.Global.DataExport));

            // Setup formatted page text
            litHeaderText.Text = String.Format(Resources.Global.ConfirmSelectionsHeaderText, Resources.Global.DataExport);
            SetPopover();

            if (!IsPostBack)
            {
                LoadLookupValues();

                PopulateForm();
                SetVisibility();

                // Store referring page in trigger variable to be used for the 
                // Create Requests
                hidTriggerPage.Value = GetReferer();
            }
        }
        protected void SetPopover()
        {
            lbWhatIsContactExportCO.Attributes.Add("data-bs-title", Resources.Global.WhatIsContactExportCO);

            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                lbWhatIsCompanyDataExport.Attributes.Add("data-bs-title", Resources.Global.WhatIsCompanyDataExport_L);
                lbWhatIsContactExportCHE.Attributes.Add("data-bs-title", Resources.Global.WhatIsContactExportCHE_L);
                lbWhatIsContactExportAll.Attributes.Add("data-bs-title", Resources.Global.WhatIsContactExportAll_L);
            }
            else
            {
                lbWhatIsCompanyDataExport.Attributes.Add("data-bs-title", Resources.Global.WhatIsCompanyDataExport);
                lbWhatIsContactExportCHE.Attributes.Add("data-bs-title", Resources.Global.WhatIsContactExportCHE);
                lbWhatIsContactExportAll.Attributes.Add("data-bs-title", Resources.Global.WhatIsContactExportAll);
            }
        }

        /// <summary>
        /// Check users page level authorization
        /// </summary>
        /// <returns></returns>
        override protected bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.DataExportPage).HasPrivilege;
        }

        /// <summary>
        /// Check users control/data level authorization
        /// </summary>
        /// <returns></returns>
        protected override bool IsAuthorizedForData()
        {
            return (!_oUser.IsTrialPeriodActive());
        }

        /// <summary>
        /// Loads all of the databound controls setting 
        /// thier default values.
        /// </summary>
        protected void LoadLookupValues()
        {
            // Bind Contact export format drop-down
            // Note: CSV or MS Outlook.  
            //BindLookupValues(ddlExportFormat, GetReferenceData("ContactExportFormat"));

            ApplySecurity(trExportCO, rbExportCO, SecurityMgr.Privilege.DataExportBasicCompanyDataExport);
            ApplySecurity(trExportCDE, rbExportCDE, SecurityMgr.Privilege.DataExportDetailedCompanyDataExport);
            ApplySecurity(trExportHCO, rbExportHCO, SecurityMgr.Privilege.DataExportContactExportHeadExecutive);
            ApplySecurity(trExportAC, rbExportAC, SecurityMgr.Privilege.DataExportContactExportAllContacts);
            if (IsPRCoUser())
            {
                trExportBBSi.Visible = true;
            }


        }

        /// <summary>
        /// Populates the form controls.
        /// </summary>
        protected void PopulateForm()
        {
            if (string.IsNullOrEmpty(GetRequestParameter("CompanyIDList", false)))
            {
                throw new ApplicationExpectedException(Resources.Global.BookmarkError);
            }

            // Restrieve the selected companies to use to populate the selected companies 
            // data grid 
            string szSelectedCompanyIDs = GetRequestParameter("CompanyIDList", true);
            ViewState["szSelectedCompanyIDs"] = szSelectedCompanyIDs;

            GetIneligibleCompanies(szSelectedCompanyIDs);

            if (lIneligibleCompanies.Count > 0)
            {
                StringBuilder sbCompanyIDList = new StringBuilder();
                string[] aszCompanyIDList = szSelectedCompanyIDs.Split(new char[] { ',' });
                foreach (string companyID in aszCompanyIDList)
                {
                    if (!lIneligibleCompanies.Contains(companyID))
                    {
                        if (sbCompanyIDList.Length > 0)
                        {
                            sbCompanyIDList.Append(",");
                        }
                        sbCompanyIDList.Append(companyID);
                    }
                }

                szSelectedCompanyIDs = sbCompanyIDList.ToString();
                SetRequestParameter("CompanyIDList", szSelectedCompanyIDs);
                pnlMsg.Visible = true;

                if (string.IsNullOrEmpty(szSelectedCompanyIDs))
                {
                    szSelectedCompanyIDs = "0";
                }
            }

            // Generate the sql required to retrieve the selected companies   
            object[] args = {_oUser.prwu_Culture,
                             _oUser.prwu_WebUserID,
                             _oUser.prwu_HQID,
                             szSelectedCompanyIDs,
                             DateTime.Today.AddDays(0 - Configuration.ClaimActivityNewThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss"),
                             DateTime.Today.AddDays(0 - Configuration.ClaimActivityMeritoriousThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss"),
                             GetObjectMgr().GetLocalSourceCondition(),
                             GetObjectMgr().GetIntlTradeAssociationCondition()};

            string szSQL = string.Format(SQL_GET_SELECTED_COMPANIES, args);
            szSQL += GetOrderByClause(gvSelectedCompanies);

            // Create empty grid view in case 0 results are found
            //((EmptyGridView)gvSelectedCompanies).EmptyTableRowText = GetNoResultsFoundMsg(Resources.Global.Companies);
            gvSelectedCompanies.ShowHeaderWhenEmpty = true;
            gvSelectedCompanies.EmptyDataText = GetNoResultsFoundMsg(Resources.Global.Companies);

            // Execute search and bind results to grid
            gvSelectedCompanies.DataSource = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection);
            gvSelectedCompanies.DataBind();
            EnableBootstrapFormatting(gvSelectedCompanies);

            OptimizeViewState(gvSelectedCompanies);

            // Display the number of matching records found
            lblRecordCount.Text = string.Format(Resources.Global.RecordSelectedMsg, gvSelectedCompanies.Rows.Count, Resources.Global.Companies);

            // If no results are found, disable the buttons that require a company            
            if (gvSelectedCompanies.Rows.Count == 0)
            {
                //btnReviseSelections.Enabled = false;
                //btnCancel.Enabled = false;
                btnGenerateExport.Enabled = false;
            }

            // Set a default value for the Select Data Export control
            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                rbExportCDE.Checked = true;
            else
                rbExportCO.Checked = true;
        }

        /// <summary>
        /// Used to show/hide form elements based on the current page
        /// settings
        /// </summary>
        protected void SetVisibility()
        {

        }

        /// <summary>
        /// Handles the Revise Selections on click event.  This should take the user to 
        /// the CompanySearchResults page specifying the ExecuteLastSearch parameter
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnReviseSelections_Click(object sender, EventArgs e)
        {
            Response.Redirect(GetReturnURL(PageConstants.COMPANY_SEARCH_RESULTS_EXECUTE_LAST));
        }

        /// <summary>
        /// Handles the Cancel on click event.  This should take the user to the page 
        /// specified by the PRWebUser default company search page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnHome_Click(object sender, EventArgs e)
        {
            Response.Redirect(PageConstants.BBOS_HOME);
        }

        /// <summary>
        /// Handles the GenerateExport on click event.  Invokes the GetReport.aspx
        /// specifying the DataExport.rdl report.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnGenerateExport_Click(object sender, EventArgs e)
        {
            string selectedIDs = (string)ViewState["szSelectedCompanyIDs"];
            CheckDataExport(selectedIDs.Split(',').Length);

            string szReportURL = "";
            string szRequestType = "";

            if (rbExportAC.Checked ||
                rbExportCO.Checked ||
                rbExportHCO.Checked)
            {
                string contactType = null;
                if (rbExportAC.Checked)
                {
                    contactType = "AC";
                }
                else if (rbExportCO.Checked)
                {
                    contactType = "CO";
                }
                else if (rbExportHCO.Checked)
                {
                    contactType = "HCO";
                }

                // Create contact export url with appropriate parameters
                // Check if the Company Contact Export was selected
                if (rbExportCO.Checked)
                {
                    szReportURL = PageConstants.Format(PageConstants.GET_REPORT, GetReport.COMPANY_CONTACTS_EXPORT);
                    szRequestType = GetReport.COMPANY_CONTACTS_EXPORT;
                }
                else
                {
                    if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                    {
                        szReportURL = PageConstants.Format(PageConstants.GET_REPORT, GetReport.CONTACT_EXPORT_LUMBER);
                    }
                    else
                    {
                        szReportURL = PageConstants.Format(PageConstants.GET_REPORT, GetReport.CONTACT_EXPORT);
                    }

                    szRequestType = GetReport.CONTACT_EXPORT;
                }

                szReportURL += "&ContactType=" + contactType;
                szReportURL += "&ExportType=" + "CSV";
            }

            if (rbExportCDE.Checked)
            {
                if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                {
                    szReportURL = PageConstants.Format(PageConstants.GET_REPORT, GetReport.COMPANY_DATA_EXPORT_LUMBER);
                    szRequestType = GetReport.COMPANY_DATA_EXPORT_LUMBER;
                }
                else
                {
                    // Create company data export url with appropriate parameters
                    szReportURL = PageConstants.Format(PageConstants.GET_REPORT, GetReport.COMPANY_DATA_EXPORT);

                    // Set what report level to pull based on user access
                    if (_oUser.HasPrivilege(SecurityMgr.Privilege.DataExportCompanyDataExportWBBScore).HasPrivilege)
                        Session["Level"] = 2;
                    else
                        Session["Level"] = 1;

                    szRequestType = GetReport.COMPANY_DATA_EXPORT;
                }
            }

            if (rbBBSiExport.Checked)
            {
                szReportURL = PageConstants.Format(PageConstants.GET_REPORT, GetReport.INTERNAL_EXPORT);
                szRequestType = GetReport.INTERNAL_EXPORT;
            }

            // CreateRequest (specify appropriate code, Request.Referrer aspx)           
            try
            {
                GetObjectMgr().CreateRequest(szRequestType, selectedIDs, hidTriggerPage.Value, null);
            }
            catch (Exception eX)
            {
                // There's nothing the end user can do about this so
                // just log it and keep moving.
                LogError(eX);

                if (Configuration.ThrowDevExceptions)
                {
                    throw;
                }
            }

            Response.Redirect(szReportURL);
        }

        /// <summary>
        /// Helper method that helps with bi-directional sorting.  The default sort order
        /// for this grid should be by company name
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void GridView_Sorting(Object sender, GridViewSortEventArgs e)
        {
            SetSortingAttributes((GridView)sender, e);
            PopulateForm();
        }

        /// <summary>
        /// Adds the sort indicator to the appropriate column
        /// header.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void GridView_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            SetSortIndicator((GridView)sender, e);
            DisplayLocalSource(e);
        }

        /// <summary>
        /// Handles the Select Export Type control selected index changed event.  If a contact
        /// export type is selected, the export format drop-down list will be enabled, otherwise
        /// if a company data export has been selected, this control will be disabled
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void rbExportType_CheckedChanged(object sender, EventArgs e)
        {
            SetVisibility();
        }

        protected const string SQL_VERIFY_ELIGIBILITY =
            @"SELECT comp_CompanyID FROM Company WITH (NOLOCK) WHERE comp_CompanyID IN ({0}) AND (comp_PRLocalSource='Y')";

        protected List<string> lIneligibleCompanies;
        protected void GetIneligibleCompanies(string szCompanyIDs)
        {
            if (lIneligibleCompanies == null)
            {
                lIneligibleCompanies = new List<string>();

                string szSQL = String.Format(SQL_VERIFY_ELIGIBILITY, szCompanyIDs);

                IDBAccess oDataAccess = DBAccessFactory.getDBAccessProvider();
                oDataAccess.Logger = _oLogger;
                using (IDataReader oReader = oDataAccess.ExecuteReader(szSQL, CommandBehavior.CloseConnection))
                {
                    while (oReader.Read())
                    {
                        lIneligibleCompanies.Add(oReader[0].ToString());
                    }
                }
            }
        }
    }
}
