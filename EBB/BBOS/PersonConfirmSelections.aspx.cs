/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc., 2014-2018

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: PersonConfirmSelections
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/

using System;
using System.Data;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using TSI.Arch;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    public partial class PersonConfirmSelections : PageBase
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
            SetPageTitle(String.Format(Resources.Global.ConfirmSelections, string.Empty));


            if (!IsPostBack)
            {
                LoadLookupValues();

                PopulateForm();

                // Store referring page in trigger variable to be used for the 
                // Create Requests
                hidTriggerPage.Value = GetReferer();
            }
        }

        /// <summary>
        /// Loads all of the databound controls setting 
        /// thier default values.
        /// </summary>
        protected void LoadLookupValues()
        {
            // Bind Contact export format drop-down
            // Note: CSV or MS Outlook.  
            BindLookupValues(ddlExportFormat, GetReferenceData("ContactExportFormat"));
        }

        /// <summary>
        /// Handles the GenerateExport on click event.  Invokes the GetReport.aspx
        /// specifying the DataExport.rdl report.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnGenerateExport_Click(object sender, EventArgs e)
        {
            string selectedIDs = GetRequestParameter("PersonIDList");
            CheckDataExport(selectedIDs.Split(',').Length);

            string szReportURL = PageConstants.Format(PageConstants.GET_REPORT, GetReport.PERSON_EXPORT);
            szReportURL += "&ExportType=" + ddlExportFormat.SelectedValue;
            AddRequestRecord("PE");
            Response.Redirect(szReportURL);
        }

        /// <summary>
        /// Handles the Generate Report on click event.  This should take the user the GetReports.aspx
        /// page specifying the report type and the related required parameters for that report.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnGenerateReport_Click(object sender, EventArgs e)
        {
            string szReportURL = PageConstants.Format(PageConstants.GET_REPORT, GetReport.PERSON_REPORT);
            // If entered, store the Custom Header so it can be used to generate the report
            Session["HeaderText"] = null;
            if (!string.IsNullOrEmpty(txtCustomHeader.Text))
            {
                Session["HeaderText"] = txtCustomHeader.Text;
            }

            AddRequestRecord("PR");
            Response.Redirect(szReportURL);
        }

        protected void AddRequestRecord(string requestType)
        {
            try
            {
                GetObjectMgr().CreateRequest(requestType, GetRequestParameter("PersonIDList"), hidTriggerPage.Value, null);
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
        }

        protected string GetPersonCompanies(int iPersonID)
        {
            return GetPersonCompanies(iPersonID, SOURCE_TABLE_PERSON, szSelectedPersonIDs);
        }

        protected string GetBBNumbers(int iPersonID)
        {
            return GetBBNumbers(iPersonID, SOURCE_TABLE_PERSON, szSelectedPersonIDs);
        }

        protected string GetCompanyNames(int iPersonID, string szSourceTable, bool bIncludeIcons, bool bIncludeCompanyNameLink)
        {
            return GetCompanyNames(iPersonID, szSourceTable, szSelectedPersonIDs, bIncludeIcons: bIncludeIcons, bIncludeCompanyNameLink: bIncludeCompanyNameLink, bCompanyLinksNewTab:false);
        }

        protected string GetCompanyLocations(int iPersonID, string szSourceTable)
        {
            return GetCompanyLocations(iPersonID, szSourceTable, szSelectedPersonIDs);
        }

        /// <summary>
        /// Used to show/hide form elements based on the current page
        /// settings
        /// </summary>
        protected void SetVisibility()
        {
            if (rbExport.Checked)
            {
                ddlExportFormat.Enabled = true;
            }
            else
            {
                ddlExportFormat.Enabled = false;
            }
        }

        /// <summary>
        /// Handles the Revise Selections on click event.  This should take the user to 
        /// the CompanySearchResults page specifying the ExecuteLastSearch parameter
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnReviseSelections_Click(object sender, EventArgs e)
        {
            Response.Redirect(GetReturnURL(PageConstants.PERSON_SEARCH_RESULTS_EXECUTE_LAST));
        }

        /// <summary>
        /// Handles the Cancel on click event.  This should take the user to the page 
        /// specified by the PRWebUser default company search page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Response.Redirect(PageConstants.PERSON_SEARCH);
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

        protected const string SQL_GET_SELECTED_PERSONS =
            @"SELECT DISTINCT Pers_FirstName AS FirstName, Pers_LastName AS LastName, Pers_PersonId AS PersonId, dbo.ufn_FormatPerson(Pers_FirstName, Pers_LastName, Pers_MiddleName, Pers_PRNickname1, Pers_Suffix) As PersonName 
                FROM Person WITH (NOLOCK)
                     INNER JOIN Person_Link WITH (NOLOCK) ON pers_PersonID = peli_PersonID
                     INNER JOIN Company WITH (NOLOCK) ON peli_CompanyID = comp_CompanyID 
               WHERE pers_PersonID IN ({0})
                 AND peli_PRStatus='1' 
                 AND peli_PREBBPublish='Y'
                 {1}";

        protected string szSelectedPersonIDs;

        /// <summary>
        /// Populates the form controls.
        /// </summary>
        protected void PopulateForm()
        {
            if (string.IsNullOrEmpty(GetRequestParameter("PersonIDList", false)))
            {
                throw new ApplicationExpectedException(Resources.Global.BookmarkError);
            }

            string excludeLocalSource = string.Empty;
            switch (GetRequestParameter("Type"))
            {
                case "DE":
                    // Setup formatted page text
                    litHeaderText.Text = String.Format(Resources.Global.FollowingPersonsSelectedForDataExport); //"The following persons have been selected for a Data Export."
                    litSelect.Text = Resources.Global.SelectFormat; // "Select Format"
                    btnGenerateReport.Visible = false;
                    trReport.Visible = false;
                    fsReportOptions.Visible = false;
                    rbExport.Checked = true;
                    excludeLocalSource = " AND comp_PRLocalSource IS NULL";
                    pnlMsg.Visible = true;
                    break;
                case "R":
                    litHeaderText.Text = String.Format(Resources.Global.FollowingPersonsSelectedForReport);   //"The following persons have been selected for a Report."
                    litSelect.Text = Resources.Global.SelectReport; // "Select Report"
                    btnGenerateExport.Visible = false;
                    trExport.Visible = false;
                    fsExportOptions.Visible = false;
                    rbReport.Checked = true;
                    break;
                default:
                    throw new Exception(Resources.Global.InvalidPersonConfirmationTypeSpecified); // "An invalid person confirmation type has been specified")
            }

            // Restrieve the selected companies to use to populate the selected companies 
            // data grid 
            szSelectedPersonIDs = GetRequestParameter("PersonIDList", true);

            //// Generate the sql required to retrieve the selected persons            
            string szSQL = string.Format(SQL_GET_SELECTED_PERSONS, szSelectedPersonIDs, excludeLocalSource);
            szSQL += GetOrderByClause(gvSelectedPersons);

            //// Create empty grid view in case 0 results are found
            //((EmptyGridView)gvSelectedPersons).EmptyTableRowText = GetNoResultsFoundMsg(Resources.Global.Persons);
            gvSelectedPersons.ShowHeaderWhenEmpty = true;
            gvSelectedPersons.EmptyDataText = GetNoResultsFoundMsg(Resources.Global.Persons);

            //// Execute search and bind results to grid
            gvSelectedPersons.DataSource = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection);
            gvSelectedPersons.DataBind();

            OptimizeViewState(gvSelectedPersons);

            //// Display the number of matching records found
            lblRecordCount.Text = string.Format(Resources.Global.RecordSelectedMsg, gvSelectedPersons.Rows.Count, Resources.Global.Persons);

            //// If no results are found, disable the buttons that require a company            
            if (gvSelectedPersons.Rows.Count == 0)
            {
                btnReviseSelections.Enabled = false;
                btnCancel.Enabled = false;
                btnGenerateExport.Enabled = false;
            }
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
        }

        /// <summary>
        /// Check users page level authorization
        /// </summary>
        /// <returns></returns>
        override protected bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.PersonSearchPage).HasPrivilege;
        }

        /// <summary>
        /// Check users control/data level authorization
        /// </summary>
        /// <returns></returns>onon
        protected override bool IsAuthorizedForData()
        {
            return true;
        }
    }
}