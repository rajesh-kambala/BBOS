/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CompanyUpdateSearch.aspx.cs
 Description:	

 Notes:	Created By Travant Solutions

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using TSI.BusinessObjects;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Allows the user to search for company updates (formerly
    /// credit sheets) across companies.
    /// </summary>
    public partial class CompanyUpdateSearch : PageBase
    {
        IPRWebUserSearchCriteria _oSearch = null;
        CreditSheetSearchCriteria _oCriteria = null;

        bool _bProcessSearchAudit = true;
        bool _bPopulateFromForm = true;
        bool _bIsDirty = false;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            SetPageTitle(Resources.Global.NewCompanyUpdateSearch);
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_TOGGLE_FUNCTIONS_FILE));
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_FUNCTIONS2_FILE));
            EnableFormValidation();

            string szExportClick = "if(!confirmSelect('" + Resources.Global.Updates + "', 'cbCreditSheetID') || !ValidateExportsCount()) return false;";

            btnCompanyUpdateReport1.Attributes.Add("onclick", szExportClick);

            btnCompanyUpdateExport1.Attributes.Add("onclick", szExportClick);

            btnAddToWatchdogList1.Attributes.Add("onclick", "return confirmSelect('" + Resources.Global.Updates + "', 'cbCreditSheetID')");

            SetSortField(gvUserList, "prwucl_Name");

            SetPopover();

            if (!IsPostBack)
            {
                txtDateFrom.Attributes.Add("placeholder", GetCultureInfo_ShortDatePattern().ToUpper());
                txtDateTo.Attributes.Add("placeholder", GetCultureInfo_ShortDatePattern().ToUpper());

                GetSearchCriteria();
                BindLookupValues();
                dpeRatingNumeralDefinition.ContextKey = _oUser.prwu_IndustryType;

                SetSortField(gvSearchResults, "prcs_PublishableDate");
                SetSortAsc(gvSearchResults, false);

                PopulateForm();

                // If Search has been specified as the action, search based off the id specified
                if (GetRequestParameter("Action", false) == "Search")
                {
                    Search();
                }

                // If we have our ExecuteLastSearch parameter, go do just that.
                if (!string.IsNullOrEmpty(GetRequestParameter("ExecuteLastSearch", false)))
                {
                    Search();
                }

                // Determine if are you sure confirmation messages should be displayed
                if (_bIsDirty)
                    ClientScript.RegisterClientScriptBlock(this.GetType(), "script1", "var bDisplayConfirmations = true;", true);
                else
                    ClientScript.RegisterClientScriptBlock(this.GetType(), "script1", "var bDisplayConfirmations = false;", true);
            }

            // See issue #54.  Hiding it from the user for now.
            // We should probably remove the code at some point but
            // restoring it would be a pain so let's make sure this
            // is want we want to do first.
            btnNewSearch1.Visible = false;
        }

        protected void SetPopover()
        {
            //popBBNumber.Attributes.Add("data-bs-title", Resources.Global.BBNumberDefinition);

            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                popKeyChangesOnly.Attributes.Add("data-bs-title", Resources.Global.KeyChangeDefinitionL);
            else
                popKeyChangesOnly.Attributes.Add("data-bs-title", Resources.Global.KeyChangeDefinition);
        }

        protected void BindLookupValues()
        {
            BindLookupValues(ddlDateRange, GetReferenceData("RelativeDateRange"), _oCriteria.DateRangeType);
            ddlDateRange.Attributes.Add("onchange", "ToggleCalendar();");
        }

        /// <summary>
        /// Populates the criteria page with the contents of the
        /// current search.
        /// </summary>
        protected void PopulateForm()
        {
            ToggleResults(false);

            //txtCompany.Text = _oCritiera.CompanyName;
            txtDateFrom.Text = GetStringFromDate(_oCriteria.FromDate);
            txtDateTo.Text = GetStringFromDate(_oCriteria.ToDate);

            cbKeyChangesOnly.Checked = _oCriteria.KeyOnly;

            PopulateUserLists(gvUserList);

            //Exports management
            ExportsManagement(hidExportsPeriod, hidExportsMax, hidExportsUsed);
        }

        /// <summary>
        /// Prepares the criteria object by populating it from the
        /// form and then executes the search.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnSearchOnClick(object sender, EventArgs e)
        {
            GetSearchCriteria();
            PopulateSearchCriteria();
            Search();

            // We need to do this to preserve the 
            // selected user lists.
            PopulateUserLists(gvUserList);
        }

        protected void PopulateSearchCriteria()
        {
            // If we're sorting, we already have our critiera.
            // That plus we don't have the "cbUserListID" being
            // posted back to us.
            if (_bPopulateFromForm)
            {
                if ((string.IsNullOrEmpty(ddlDateRange.SelectedValue)) &&
                    ((string.IsNullOrEmpty(txtDateFrom.Text)) ||
                     (string.IsNullOrEmpty(txtDateTo.Text))))
                {
                    AddUserMessage(Resources.Global.PleaseSpecifyDateRange);
                    return;
                }

                //_oCritiera.CompanyName = txtCompany.Text;
                _oCriteria.DateRangeType = ddlDateRange.SelectedValue;
                _oCriteria.FromDate = UIUtils.GetDateTime(txtDateFrom.Text, GetCultureInfo(_oUser));
                _oCriteria.ToDate = UIUtils.GetDateTime(txtDateTo.Text, GetCultureInfo(_oUser));
                _oCriteria.KeyOnly = cbKeyChangesOnly.Checked;
                //_oCriteria.OnlyNewListings = cbOnlyNewListings.Checked;
                _oCriteria.IncludeNewListings = cbIncludeNewListing.Checked;

                _oCriteria.UserListIDs = GetRequestParameter("cbUserListID", false);
            }
        }

        protected void ProcessSearchAudit()
        {
            if (IsImpersonating())
            {
                return;
            }

            _oSearch.prsc_ExecutionCount++;
            _oSearch.prsc_LastExecutionDateTime = DateTime.Now;
            _oSearch.prsc_LastExecutionResultCount = gvSearchResults.Rows.Count;

            PRWebUserSearchCriteriaMgr oWebUserSearchCriteriaMgr = new PRWebUserSearchCriteriaMgr(_oLogger, _oUser);
            oWebUserSearchCriteriaMgr.SaveLastSearch((PRWebUserSearchCriteria)_oSearch, null);

            try
            {
                IDbTransaction oTran = GetObjectMgr().BeginTransaction();
                GetObjectMgr().InsertSearchAuditTrail(_oSearch, oTran);
                GetObjectMgr().Commit();
            }
            catch (Exception eX)
            {
                GetObjectMgr().Rollback();

                // There's nothing the end user can do about this so
                // just log it and keep moving.
                LogError(eX);

                if (Configuration.ThrowDevExceptions)
                {
                    throw;
                }
            }
        }

        /// <summary>
        /// Executes the search populating the results grid.
        /// </summary>
        protected void Search()
        {
            DisplayAd();
            litAdWidget.Text = Utilities.GetConfigValue("WidgetsRootURL") + "javascript/GetAdsWidget.min.js";
            ToggleResults(true);

            ArrayList oParameters = null;
            string szSQL = _oCriteria.GetSearchSQL(out oParameters);
            szSQL += GetOrderByClause(gvSearchResults);

            //((EmptyGridView)gvSearchResults).EmptyTableRowText = GetNoResultsFoundMsg(Resources.Global.Updates);
            gvSearchResults.ShowHeaderWhenEmpty = true;
            gvSearchResults.EmptyDataText = GetNoResultsFoundMsg(Resources.Global.Updates);

            gvSearchResults.DataSource = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            gvSearchResults.DataBind();
            EnableBootstrapFormatting(gvSearchResults);

            OptimizeViewState(gvSearchResults);

            // Only query for the total number of rows if our
            // limit was reached on the main query.
            if (gvSearchResults.Rows.Count == Configuration.CompanyUpdateSearchMaxResults)
            {
                ArrayList oCountParameters;
                string szCountSQL = _oCriteria.GetSearchCountSQL(out oCountParameters);
                oCountParameters.Add(new ObjectParameter("HQID", _oUser.prwu_HQID));
                oCountParameters.Add(new ObjectParameter("WebUserID", _oUser.prwu_WebUserID));

                int iCount = (int)GetDBAccess().ExecuteScalar(szCountSQL, oCountParameters);
                if (iCount > Configuration.CompanyUpdateSearchMaxResults)
                {
                    AddUserMessage(string.Format(GetMaxResultsMsg(), iCount.ToString("###,##0"), Configuration.CompanyUpdateSearchMaxResults.ToString("###,##0")));
                }
            }

            lblRecordCount.Text = string.Format(Resources.Global.RecordCountFoundMsg, gvSearchResults.Rows.Count, Resources.Global.Updates);

            if (gvSearchResults.Rows.Count == 0)
            {
                btnCompanyUpdateReport1.Enabled = false;

                btnCompanyUpdateExport1.Enabled = false;
            }

            btnSaveCriteria1.Enabled = true;

            ApplyReadOnlyCheck(btnSaveCriteria1);

            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "DisableValidation", "DisableValidation();", true);

            if (_bProcessSearchAudit)
            {
                ProcessSearchAudit();
            }

            ApplySecurity(btnAddToWatchdogList1, SecurityMgr.Privilege.WatchdogListAdd);

            ApplySecurity(btnCompanyUpdateReport1, SecurityMgr.Privilege.ReportCreditSheet);

            ApplySecurity(btnCompanyUpdateExport1, SecurityMgr.Privilege.ReportCreditSheetExport);
        }

        /// <summary>
        /// Returns the appropriate Search object depending on if we're executing
        /// the last search, a saved search, or a new search.
        /// </summary>
        protected void GetSearchCriteria()
        {
            if (_oSearch != null)
            {
                return;
            }

            bool bNew = false;

            // If we already have a search ID, then don't look for
            // another.
            if (string.IsNullOrEmpty(hidSearchID.Text))
            {
                if (!string.IsNullOrEmpty(GetRequestParameter("ExecuteLastSearch", false)))
                {
                    hidSearchID.Text = _oUser.prwu_LastCreditSheetSearchID.ToString();
                }
                else if (!string.IsNullOrEmpty(GetRequestParameter("SearchID", false)))
                {
                    hidSearchID.Text = GetRequestParameter("SearchID");
                }
                else
                {
                    bNew = true;
                    hidSearchID.Text = "0";
                }
            }

            _oSearch = GetSearchCritieria(Convert.ToInt32(hidSearchID.Text), PRWebUserSearchCriteria.SEARCH_TYPE_COMPANY_UPDATE);
            _oCriteria = (CreditSheetSearchCriteria)_oSearch.Criteria;
            _bIsDirty = _oCriteria.IsDirty;
            _oCriteria.WebUser = _oUser;

            // If this is a new search, set our criteria defaults.
            if (bNew)
            {
                /*
                 * Set defaults.
                 * If User has a default "days old" set, then use it for the range, else default to the config value.
                 * Also, if the user's range is set, then set the type to "custom"
                */
                int? daysOld = _oUser.prwu_CompanyUpdateDaysOld ?? Configuration.CompanyUpdateDaysOld;
                _oCriteria.FromDate = DateTime.Today.AddDays(0 - Convert.ToDouble(daysOld));
                _oCriteria.ToDate = DateTime.Today;
                if (_oUser.prwu_CompanyUpdateDaysOld == null)
                {
                    _oCriteria.DateRangeType = "Yesterday";
                }
                else
                {
                    _oCriteria.DateRangeType = "Custom";
                }

                // If Search has been specified the key parameter, then reset
                // the default values to immediately execute the search
                if (GetRequestParameter("Key", false) == "Y")
                {
                    _oCriteria.KeyOnly = true;
                    _oCriteria.DateRangeType = "Custom";

                    if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                    {
                        _oCriteria.IncludeNewListings = true;
                    }
                }

                if (GetRequestParameter("NonKey", false) == "Y")
                {
                    _oCriteria.KeyOnly = false;
                    _oCriteria.DateRangeType = "Custom";

                    if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                    {
                        _oCriteria.IncludeNewListings = true;
                    }
                }
            }
        }

        List<string> _lSelectedIDs = null;

        /// <summary>
        /// Determines if the specified ID is part of the
        /// selected list.  If so, returns " checked ".
        /// </summary>
        /// <param name="iID"></param>
        /// <returns></returns>
        protected string GetChecked(int iID)
        {
            string szID = iID.ToString();

            // Only build our list of IDs once.
            if (_lSelectedIDs == null)
            {
                _lSelectedIDs = new List<string>();

                if (_oCriteria != null)
                {
                    if (!string.IsNullOrEmpty(_oCriteria.UserListIDs))
                    {
                        string[] aszIDs = _oCriteria.UserListIDs.Split(',');
                        _lSelectedIDs.AddRange(aszIDs);
                    }
                }
            }

            if (_lSelectedIDs.Contains(szID))
            {
                return " checked ";
            }
            else
            {
                return string.Empty;
            }
        }

        /// <summary>
        /// Hides the results and displays the criteria
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnRefineOnClick(object sender, EventArgs e)
        {
            ToggleResults(false);
        }

        protected void ToggleResults(bool bDisplayResults)
        {
            if (bDisplayResults)
            {
                pnlCriteria.Visible = false;
                pnlResults.Visible = true;

                btnRefine1.Visible = true;

                btnClearCriteria1.Visible = false;

                btnSearch1.Visible = false;

                btnCompanyUpdateReport1.Visible = true;

                btnCompanyUpdateExport1.Visible = true;

                btnAddToWatchdogList1.Visible = true;
            }
            else
            {
                pnlCriteria.Visible = true;
                pnlResults.Visible = false;

                btnRefine1.Visible = false;

                btnClearCriteria1.Visible = true;

                btnSearch1.Visible = true;

                btnCompanyUpdateReport1.Visible = false;

                btnCompanyUpdateExport1.Visible = false;

                btnAddToWatchdogList1.Visible = false;
            }
        }

        /// <summary>
        /// Select the unique company IDs associated with the selected
        /// company update items.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnBusinessReportOnClick(object sender, EventArgs e)
        {
            SetReturnURL(PageConstants.COMPANY_UPDATE_SEARCH + "?ExecuteLastSearch=1");
            Session["CompanyIDList"] = GetSelectedCompanies();
            Response.Redirect(string.Format(PageConstants.BUSINESS_REPORT_CONFIRM_SELECTIONS, string.Empty, string.Empty));
        }

        protected void btnAddToWatchdogListOnClick(object sender, EventArgs e)
        {
            SetReturnURL(PageConstants.COMPANY_UPDATE_SEARCH + "?ExecuteLastSearch=1");
            Session["CompanyIDList"] = GetSelectedCompanies();
            Response.Redirect(PageConstants.USER_LIST_ADD_TO);
        }

        protected const string SQL_SELECT_COMPANY = "SELECT DISTINCT prcs_CompanyID FROM PRCreditSheet WITH (NOLOCK) where prcs_CreditSheetID IN ({0})";
        /// <summary>
        /// Helper method that returns a distinct list of company IDs
        /// from the selected credit sheet IDs.
        /// </summary>
        /// <returns></returns>
        protected string GetSelectedCompanies()
        {
            string szSelectedList = GetRequestParameter("cbCreditSheetID");
            string szSQL = string.Format(SQL_SELECT_COMPANY, szSelectedList);

            string szSelectedCompanies = string.Empty;
            IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection);
            try
            {
                while (oReader.Read())
                {
                    if (szSelectedCompanies.Length > 0)
                    {
                        szSelectedCompanies += ",";
                    }
                    szSelectedCompanies += oReader.GetInt32(0).ToString();
                }
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }

            return szSelectedCompanies;
        }

        protected void btnCompanyUpdateReportOnClick(object sender, EventArgs e)
        {
            //Session Timeout Prevention
            if (Configuration.RedirectHomeOnException && GetRequestParameter("cbCreditSheetID", false) == null)
            {
                Response.Redirect(PageConstants.BBOS_HOME);
            }

            string szSelectedList = GetRequestParameter("cbCreditSheetID");
            Session["CreditSheetIDList"] = szSelectedList;
            Response.Redirect(PageConstants.Format(PageConstants.GET_REPORT, GetReport.CREDIT_SHEET_REPORT));
        }

        protected void btnCompanyUpdateExportOnClick(object sender, EventArgs e)
        {
            //Session Timeout Prevention
            if (Configuration.RedirectHomeOnException && GetRequestParameter("cbCreditSheetID", false) == null)
            {
                Response.Redirect(PageConstants.BBOS_HOME);
            }

            string szSelectedList = GetRequestParameter("cbCreditSheetID");
            Session["CreditSheetIDList"] = szSelectedList;

            // CreateRequest (specify appropriate code, Request.Referrer aspx)           
            string szRequestType = "CSE";
            try
            {
                GetObjectMgr().CreateRequest(szRequestType, szSelectedList, GetReferer(), null);
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

            Response.Redirect(PageConstants.Format(PageConstants.GET_REPORT, GetReport.CREDIT_SHEET_EXPORT));
        }

        /// <summary>
        /// Helper method that helps with bi-directional sorting
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void GridView_Sorting(Object sender, GridViewSortEventArgs e)
        {
            SetSortingAttributes((GridView)sender, e);

            // We don't want to audit the search again just because
            // the user is sorting.          
            _bProcessSearchAudit = false;

            // We don't want to populate the search from the form.  Normally this is fine
            // but because we have unbound checkboxes, this presents a problem so just use
            // the last criteria object from the session.
            _bPopulateFromForm = false;

            // Now re-execute the search with the new order by parameters.
            btnSearchOnClick(null, null);
        }

        /// <summary>
        /// Helper method that helps with bi-directional sorting
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void UserListGridView_Sorting(Object sender, GridViewSortEventArgs e)
        {
            SetSortingAttributes((GridView)sender, e);

            GetSearchCriteria();
            _oCriteria.UserListIDs = GetRequestParameter("cbUserListID", false);
            PopulateUserLists(gvUserList);
        }

        /// <summary>
        /// Adds the sort indicator to the appropriate column
        /// header.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void gvUserList_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            SetSortIndicator((GridView)sender, e);
        }

        protected void gvSearchResults_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            SetSortIndicator((GridView)sender, e);

            if (e.Row.RowType == DataControlRowType.DataRow)
            {

                if (_oUser.prwu_CompanyLinksNewTab)
                {
                    HyperLink hlCompanyDetails = (HyperLink)e.Row.FindControl("hlCompanyDetails");
                    hlCompanyDetails.Target = "_blank";
                }
            }
        }

        protected override bool IsAuthorizedForData()
        {
            return true;
        }

        protected override bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.CompanyUpdatesSearchPage).HasPrivilege;
        }

        public override bool EnableJSClientIDTranslation()
        {
            return true;
        }

        protected void btnSaveCritiera_Click(object sender, EventArgs e)
        {
            GetSearchCriteria();
            PopulateSearchCriteria();
            _oSearch.Save();
            hidSearchID.Text = _oSearch.prsc_SearchCriteriaID.ToString();

            // Redirect the user to the Search Edit page
            Response.Redirect(PageConstants.Format(PageConstants.SEARCH_EDIT, hidSearchID.Text, PRWebUserSearchCriteria.SEARCH_TYPE_COMPANY_UPDATE));
        }

        /// <summary>
        /// Handles the New Search on click event for the person search pages.  
        /// If the search criteria has been modified, ask "Are you sure you want to overrite the 
        /// search criteria already entered and begin a new search?"
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnNewSearch_Click(object sender, EventArgs e)
        {
            Response.Redirect(PageConstants.SAVED_SEARCHES);
        }

        /// <summary>
        /// Handles the Load Search Criteria on click event for the person search pages.
        /// If the search criteria has been modified, ask "Are you sure you want
        /// to overwrite the search criteria already entered?
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnLoadCriteria_Click(object sender, EventArgs e)
        {
            Response.Redirect(PageConstants.SAVED_SEARCHES);
        }

        protected void btnClearCriteria_Click(object sender, EventArgs e)
        {
            Session["oWebUserSearchCriteria"] = null;
            _oSearch = null;
            hidSearchID.Text = string.Empty;
            ddlDateRange.SelectedValue = string.Empty;
            GetSearchCriteria();
            PopulateForm();
        }

        private const string SQL_EMAIL_AD =
                     @"SELECT pradc_AdCampaignID,
                       pradc_TargetURL,
	                   pracf_FileName_Disk,
                       pradc_IndustryType
                  FROM vPRAdCampaignImage
                 WHERE pradc_AdCampaignTypeDigital = 'CSEU'
                   AND pracf_FileTypeCode = 'DI'
                   AND pradc_IndustryType LIKE '%,P,%'
                   AND pradc_CreativeStatus='A'
                   AND GETDATE() BETWEEN pradc_StartDate AND pradc_EndDate";

        protected void DisplayAd()
        {
            int adAuditTrailID = 0;
            int adCampaignID = 0;
            string imageURL = null;
            string industryType = null;

            using (IDataReader reader = GetDBAccess().ExecuteReader(SQL_EMAIL_AD, CommandBehavior.CloseConnection))
            {
                if (reader.Read())
                {
                    adCampaignID = reader.GetInt32(0);
                    imageURL = reader.GetString(2);
                    industryType = reader.GetString(3);
                }
            }

            if (string.IsNullOrEmpty(industryType))
                return;

            if ((!IsPRCoUser()) ||
                (Configuration.AdCampaignTesting))
            {
                // Exclude the PRCo company from any auditing
                // Add the audit trail first beacause we need it to 
                // build any hyperlinks.
                AdUtils _adUtils = new AdUtils(LoggerFactory.GetLogger(), _oUser);
                adAuditTrailID = _adUtils.InsertAdAuditTrail(adCampaignID, 0, 1, null, 0, null);
            }

            if (industryType.Contains("," + _oUser.prwu_IndustryType + ","))
            {
                hlAd.NavigateUrl = $"AdClick.aspx?AdCampaignID={adCampaignID}&AdAuditTrailID={adAuditTrailID}";
                hlAd.ImageUrl = $"{Utilities.GetConfigValue("AdImageRootURL", "Campaigns/")}{imageURL}";
                hlAd.Visible = true;
            }
        }
    }
}