/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2020

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: ReportConfirmSelections
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
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This page displays the selected companies to report on.  The user will be allowed to select a 
    /// report type, as well as report options including custom header text, and attention line, and whether
    /// or not to include the country informatinon in the report.
    /// 
    /// The report sample links will take the users to sample reports for each of the report types.
    /// </summary>
    public partial class ReportConfirmSelections : PageBase
    {
        protected const string SQL_GET_SELECTED_COMPANIES_ALL =
            @"SELECT *, 
                     dbo.ufn_GetCustomCaptionValue('comp_PRIndustryType', comp_PRIndustryType, '{0}') As IndustryType, 
                     dbo.ufn_GetCustomCaptionValue('comp_PRType_BBOS', comp_PRType, '{0}') As CompanyType, 
                     dbo.ufn_HasNote({1}, {2}, comp_CompanyID, 'C') As HasNote,
                     dbo.ufn_HasNewClaimActivity(comp_PRHQID, '{4}') as HasNewClaimActivity, 
                     dbo.ufn_HasMeritoriousClaim(comp_PRHQID, '{5}') as HasMeritoriousClaim,
                     dbo.ufn_HasCertification(comp_PRHQID) as HasCertification,
                     dbo.ufn_HasCertification_Organic(comp_PRHQID) as HasCertification_Organic,
                     dbo.ufn_HasCertification_FoodSafety(comp_PRHQID) as HasCertification_FoodSafety
                FROM vPRBBOSCompanyList
               WHERE comp_CompanyID IN ({3})";

        protected const string SQL_GET_NOTEIDS_FOR_COMPANIES =
                  @"SELECT prwun_WebUserNoteID 
                      FROM PRWebUserNote WITH (NOLOCK) 
                     WHERE prwun_AssociatedID IN ({0}) 
                       AND prwun_AssociatedType = 'C' 
                       AND ((prwun_IsPrivate = 'Y' AND prwun_WebUserID = {1}) 
                           OR (prwun_IsPrivate IS NULL AND prwun_HQID = {2}))";

        private int _firstEnabledIndex = -1;

        /// <summary>
        /// Calls page functions required to build and process this page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            // Set page title
            SetPageTitle(String.Format(Resources.Global.ConfirmSelections, Resources.Global.Report));

            // Setup formatted page text
            litHeaderText.Text = String.Format(Resources.Global.ConfirmSelectionsHeaderText, Resources.Global.PDFReport);

            if (!IsPostBack)
            {
                LoadLookupValues();

                PopulateForm();

                // Store referring page in trigger variable to be used for the 
                // Create Requests
                hidTriggerPage.Value = GetReferer();
            }

            SetVisibility();
        }

        /// <summary>
        /// Check users page level authorization
        /// </summary>
        /// <returns></returns>
        override protected bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.CompanyReportsPage).HasPrivilege;
        }

        /// <summary>
        /// Check users control/data level authorization
        /// </summary>
        /// <returns></returns>
        protected override bool IsAuthorizedForData()
        {
            return true;
        }

        /// <summary>
        /// Loads all of the databound controls setting 
        /// thier default values.
        /// </summary>
        protected void LoadLookupValues()
        {
            AddReportItem(Resources.Global.BlueBookScoreReport,
                            Utilities.GetConfigValue("BlueBookScoreReportSampleFile", "#"),
                            GetReport.BLUE_BOOK_SCORE_REPORT,
                            SecurityMgr.Privilege.ReportBBScore);

            AddReportItem(Resources.Global.CompanyAnalysisReport,
                            Utilities.GetConfigValue("CompanyAnalysisReportSampleFile", "#"),
                            GetReport.COMPANY_ANALYSIS_REPORT,
                            SecurityMgr.Privilege.ReportCompanyAnalysis);

            AddReportItem(Resources.Global.FullBlueBookListingReport,
                          Utilities.GetConfigValue("FullBlueBookListingReportSampleFile", "#"),
                          GetReport.FULL_LISTING_REPORT,
                          SecurityMgr.Privilege.ReportFullBlueBookListing);

            //AddReportItem(Resources.Global.MailingLabelsReport,
            //              Utilities.GetConfigValue("MailingLabelsReportSampleFile", "#"),
            //              GetReport.MAILING_LABELS_REPORT,
            //              SecurityMgr.Privilege.ReportMailingLabels);

            AddReportItem(Resources.Global.NotesReport,
                          Utilities.GetConfigValue("NotesReportSampleFile", "#"),
                          GetReport.NOTES_REPORT,
                          SecurityMgr.Privilege.ReportNotes);

            string reportCode = GetReport.QUICK_REPORT;
            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                reportCode = GetReport.QUICK_REPORT_LUMBER;
            }
            AddReportItem(Resources.Global.QuickListReport,
                          Utilities.GetConfigValue("QuickListReportSampleFile", "#"),
                          reportCode,
                          SecurityMgr.Privilege.ReportQuickList);

            AddReportItem(Resources.Global.RatingComparisonReport,
                            Utilities.GetConfigValue("RatingComparisonReportSampleFile", "#"),
                            GetReport.RATINGS_COMPARISON_REPORT,
                            SecurityMgr.Privilege.ReportRatingComparison);

            //rblReportType.SelectedIndex = _firstEnabledIndex; //this was causing 1st item in list to not fire postback like other radio buttons
            //Used technique from https://stackoverflow.com/questions/37738031/asp-net-radio-button-checked-changed-event-not-firing-for-first-radio-button to fix
            string szScript = string.Format("document.getElementById('contentMain_rblReportType_{0}').checked = true;", _firstEnabledIndex);
            ClientScript.RegisterStartupScript(GetType(), "InitRadio", szScript, true);

            // Bind attention line control
            //ListItem oItem8 = new ListItem();
            //oItem8.Text = Resources.Global.NoAttentionLine;
            //oItem8.Value = "1";
            //rblAttentionLine.Items.Add(oItem8);

            //ListItem oItem9 = new ListItem();
            //oItem9.Text = Resources.Global.HeadExecutiveNameTitle;
            //oItem9.Value = "2";
            //rblAttentionLine.Items.Add(oItem9);

            //ListItem oItem10 = new ListItem();
            //oItem10.Text = Resources.Global.CustomAttentionLine;
            //oItem10.Value = "3";
            //rblAttentionLine.Items.Add(oItem10);

            //rblAttentionLine.SelectedIndex = 0;
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
                             DateTime.Today.AddDays(0 - Configuration.ClaimActivityMeritoriousThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss")};
            string szSQL = string.Format(SQL_GET_SELECTED_COMPANIES_ALL, args);
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
                btnReviseSelections.Enabled = false;
                btnGenerateReport.Enabled = false;
            }
        }

        /// <summary>
        /// Used to show/hide form elements based on the current page
        /// settings
        /// </summary>
        protected void SetVisibility()
        {
            // Toggle Report Options based on the report selected.  If the mailing labels report
            // is selected, disable the Custom Header control, and enable the Attention Line and
            // Include Country controls
            if (rblReportType.SelectedValue == GetReport.MAILING_LABELS_REPORT)
            {
                txtCustomHeader.Enabled = false;
                lblCustomHeaderText.Enabled = false;
            }
            else
            {
                txtCustomHeader.Enabled = true;
                lblCustomHeaderText.Enabled = true;
            }

            if(rblReportType.SelectedValue == GetReport.BLUE_BOOK_SCORE_REPORT || rblReportType.SelectedValue == "")
            {
                lblSortOption.Enabled = false;
                ddlSortOption.Enabled = false;
                ddlSortOption.SelectedValue = "";
            }
            else
            {
                lblSortOption.Enabled = true;
                ddlSortOption.Enabled = true;
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
            Response.Redirect(GetReturnURL(PageConstants.COMPANY_SEARCH_RESULTS_EXECUTE_LAST));
        }

        /// <summary>
        /// Handles the Home on click event.  This should take the user to the page 
        /// specified by the PRWebUser default company search page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnHome_Click(object sender, EventArgs e)
        {
            Response.Redirect(PageConstants.BBOS_HOME);
        }

        /// <summary>
        /// Handles the Generate Report on click event.  This should take the user the GetReports.aspx
        /// page specifying the report type and the related required parameters for that report.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnGenerateReport_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(GetRequestParameter("CompanyIDList", false)))
            {
                throw new ApplicationExpectedException(Resources.Global.BookmarkError);
            }

            try
            {
                GetObjectMgr().CreateRequest(rblReportType.SelectedValue, GetRequestParameter("CompanyIDList"), hidTriggerPage.Value, null);
            }
            catch (Exception eX)
            {
                // There's nothing the end user can do about this so
                // just log it and keep moving.
                LogError(eX);

                if (Utilities.GetBoolConfigValue("ThrowDevExceptions", false))
                {
                    throw;
                }
            }

            if (rblReportType.SelectedValue == GetReport.MAILING_LABELS_REPORT)
            {
                // Include Mailing Label Report Parameters
                //if (rblAttentionLine.SelectedIndex == 1)
                //    Session["IncludeHeadExecutive"] = true;
                //else
                //    Session["IncludeHeadExecutive"] = false;

                Session["CustomAttentionLine"] = null;
                //if (rblAttentionLine.SelectedIndex == 2 && !String.IsNullOrEmpty(txtAttentionLine.Text))
                //    Session["CustomAttentionLine"] = txtAttentionLine.Text;

                //if (chkIncludeCountry.Checked)
                //    Session["IncludeCountry"] = true;
                //else
                //    Session["IncludeCountry"] = false;

                // Retrieve the Mailing Labels Per Page value and pass this to be used by the
                // Get Reports page
                //Session["LabelsPerPage"] = ddlLabelsPerPage.SelectedValue;
            }
            else
            {
                // If entered, store the Custom Header so it can be used to generate the report
                Session["HeaderText"] = null;
                if (!string.IsNullOrEmpty(txtCustomHeader.Text))
                {
                    Session["HeaderText"] = txtCustomHeader.Text;
                }

                if (rblReportType.SelectedValue == GetReport.QUICK_REPORT || rblReportType.SelectedValue == GetReport.QUICK_REPORT_LUMBER)
                {
                    // IncludeHeadExecutive is required for quick report
                    Session["IncludeHeadExecutive"] = true;
                }
            }

            if (rblReportType.SelectedValue == GetReport.NOTES_REPORT)
            {
                string szNoteIDs = GetNoteIDsFromCompanyList(GetRequestParameter("CompanyIDList", true));
                if (szNoteIDs.Trim().Length > 0)
                    Session["NoteIDList"] = szNoteIDs;
                else
                {
                    AddUserMessage(Resources.Global.NotesNotFound, true);
                    PopulateForm();
                    return;
                }
            }

            Session["ReportSortOption"] = ddlSortOption.SelectedValue;

            Response.Redirect(PageConstants.Format(PageConstants.GET_REPORT, rblReportType.SelectedValue));
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

            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                string isLocalSource = Convert.ToString(((IDataRecord)(e.Row.DataItem))["comp_PRLocalSource"]);

                if (isLocalSource == "Y")
                {
                    pnlMsg.Visible = true;
                }
            }
        }

        private string GetNoteIDsFromCompanyList(string szCompanyIDList)
        {
            StringBuilder sbNoteIDs = new StringBuilder();

            // Generate the sql to check the additional fields for each company
            string szSQL = String.Format(SQL_GET_NOTEIDS_FOR_COMPANIES, szCompanyIDList, _oUser.prwu_WebUserID, _oUser.prwu_HQID);

            IDBAccess oDataAccess = DBAccessFactory.getDBAccessProvider();
            oDataAccess.Logger = _oLogger;
            IDataReader oReader = oDataAccess.ExecuteReader(szSQL, CommandBehavior.CloseConnection);
            try
            {
                while (oReader.Read())
                {
                    AddDelimitedValue(sbNoteIDs, oReader[0].ToString());
                }
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }

            return sbNoteIDs.ToString();
        }

        /// <summary>
        /// Helper function that builds the radio button list item
        /// for the specified report
        /// </summary>
        /// <param name="szItemText"></param>
        /// <param name="szSampleFile"></param>
        /// <param name="szReportCode"></param>
        /// <param name="privilege"></param>
        protected void AddReportItem(string szItemText,
                                     string szSampleFile,
                                     string szReportCode,
                                     SecurityMgr.Privilege privilege)
        {

            SecurityMgr.SecurityResult result = _oUser.HasPrivilege(privilege);
            if (!result.Visible)
            {
                return;
            }

            ListItem oItem = new ListItem();
            oItem.Text = "<nobr>" + szItemText;

            // This is a bit of a hack to work around the fact that we're embedding a hyperlink in 
            // the item text and that we want that link active even if the item is disabled.
            if (!result.Enabled)
            {
                oItem.Text += "</span><span>";
            }

            oItem.Text += " <a href=\"" + GetSamplesPath(szSampleFile) + "\" target='_blank' class='explicitlink'>" + Resources.Global.Sample + "</a></nobr>";

            oItem.Value = szReportCode;
            oItem.Enabled = result.Enabled;
            rblReportType.Items.Add(oItem);

            if ((result.Enabled) &&
                (_firstEnabledIndex == -1))
            {
                _firstEnabledIndex = rblReportType.Items.Count - 1;
            }
        }

        protected const string SQL_VERIFY_ELIGIBILITY =
                   @"SELECT comp_CompanyID FROM Company WITH (NOLOCK) WHERE comp_CompanyID IN ({0}) AND (comp_PRLocalSource='Y')";

        protected List<string> lIneligibleCompanies;
        protected void GetIneligibleCompanies(string szCompanyIDs)
        {
            if (lIneligibleCompanies == null)
            {
                lIneligibleCompanies = new List<string>();

                // For the reports screen, users with supply companies cannot include
                // any LSS data in any report.  For other users, LSS data may be included
                // in some reports.
                if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_SUPPLY)
                {
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
}
