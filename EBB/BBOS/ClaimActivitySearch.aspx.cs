/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2013-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: ClaimActivitySearch
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    public partial class ClaimActivitySearch : PageBase
    {
        IPRWebUserSearchCriteria _oSearch = null;
        ClaimActivitySearchCriteria _oCritiera = null;

        private const string PAGE_VIEW_EXPANDED = "1";
        private const string PAGE_VIEW_BASIC = "0";

        bool _bPopulateFromForm = true;
        bool _bIsDirty = false;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            SetPageTitle(Resources.Global.ClaimsActivityTableCATSearch); 
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_TOGGLE_FUNCTIONS_FILE));
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_FUNCTIONS2_FILE));
            EnableFormValidation();

            SetPopover();

            if (!IsPostBack)
            {
                GetSearchCriteria();

                // Retrieve requested page view 
                if (!string.IsNullOrEmpty(Request["ClaimActivityExpanded"]))
                    hPageView.Value = Request["ClaimActivityExpanded"];
                else
                    CheckForExpandedCriteria();

                aceCompanyName.ContextKey = _oUser.prwu_IndustryType;

                SetSortField(gvUserList, "prwucl_Name");
                SetSortAsc(gvUserList, false);

                BindLookupValues();

                PopulateForm();

                // Determine if are you sure confirmation messages should be displayed
                if (_bIsDirty)
                    ClientScript.RegisterClientScriptBlock(this.GetType(), "script1", "var bDisplayConfirmations = true;", true);
                else
                    ClientScript.RegisterClientScriptBlock(this.GetType(), "script1", "var bDisplayConfirmations = false;", true);
            }
        }

        protected void SetPopover()
        {
            popBBNumber.Attributes.Add("data-bs-title", Resources.Global.BBNumberDefinition);
        }

        protected void BindLookupValues()
        {
            BindLookupValues(ddlDateRange, GetReferenceData("RelativeDateRange2"), _oCritiera.DateRangeType);
            ddlDateRange.Attributes.Add("onchange", "ToggleCalendar();");
        }

        /// <summary>
        /// Populates the criteria page with the contents of the
        /// current search.
        /// </summary>
        protected void PopulateForm()
        {
            SetVisibility();

            if(!litWatchdogListText.Text.EndsWith(":"))
                litWatchdogListText.Text = litWatchdogListText.Text + ":";

            if (_oCritiera.BBID > 0)
            {
                if (_oCritiera.IsQuickSearch)
                {
                    hCompanyID.Value = _oCritiera.BBID.ToString();
                }
                else
                {
                    txtBBID.Text = _oCritiera.BBID.ToString();
                }
            }
            else
            {
                txtBBID.Text = string.Empty;
            }

            txtCompany.Text = _oCritiera.CompanyName;
            txtDateFrom.Text = GetStringFromDate(_oCritiera.FromDate);
            txtDateTo.Text = GetStringFromDate(_oCritiera.ToDate);
            SetListDefaultValue(ddlClaimType, _oCritiera.ClaimType);
            PopulateUserLists(gvUserList);
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

            Response.Redirect(PageConstants.Format("ClaimActivitySearchResults.aspx", _oSearch.prsc_SearchCriteriaID));

            //Search();

            // We need to do this to preserve the 
            // selected user lists.
            //PopulateUserLists(gvUserList);
        }

        protected void PopulateSearchCriteria()
        {
            // If we're sorting, we already have our critiera.
            // That plus we don't have the "cbUserListID" being
            // posted back to us.
            if (_bPopulateFromForm)
            {
                if (hPageView.Value == PAGE_VIEW_BASIC)
                {
                    hlBasic.Visible = false;
                    hlExpanded.Visible = true;

                    if (!string.IsNullOrEmpty(hCompanyID.Value))
                    {
                        _oCritiera.IsQuickSearch = true;
                        _oSearch.prsc_LastExecutionDateTime = DateTime.Now;
                        _oSearch.prsc_ExecutionCount += 1;

                        _oCritiera.BBID = Convert.ToInt32(hCompanyID.Value);
                        ProcessSearchAudit();

                        Response.Redirect(string.Format(PageConstants.COMPANY_CLAIMS_ACTIVITY_BBOS9, Convert.ToInt32(hCompanyID.Value)));
                        return;
                    }
                    else
                    {
                        _oCritiera.CompanyName = txtCompany.Text;
                    }
                }
                else
                {
                    _oCritiera.IsQuickSearch = false;

                    hlBasic.Visible = false;
                    hlExpanded.Visible = false;
                }

                if ((string.IsNullOrEmpty(ddlDateRange.SelectedValue)) &&
                    ((string.IsNullOrEmpty(txtDateFrom.Text)) ||
                     (string.IsNullOrEmpty(txtDateTo.Text))))
                {
                    AddUserMessage(Resources.Global.PleaseSpecifyDateRange);
                    return;
                }

                if (string.IsNullOrEmpty(txtBBID.Text))
                {
                    _oCritiera.BBID = 0;
                }
                else
                {
                    _oCritiera.BBID = Convert.ToInt32(txtBBID.Text);
                }

                _oCritiera.CompanyName = txtCompany.Text;
                _oCritiera.DateRangeType = ddlDateRange.SelectedValue;
                _oCritiera.FromDate = UIUtils.GetDateTime(txtDateFrom.Text, GetCultureInfo(_oUser));
                _oCritiera.ToDate = UIUtils.GetDateTime(txtDateTo.Text, GetCultureInfo(_oUser));
                _oCritiera.UserListIDs = GetRequestParameter("cbUserListID", false);
                _oCritiera.ClaimType = ddlClaimType.SelectedValue;
            }
        }

        protected void ProcessSearchAudit()
        {
            _oSearch.prsc_ExecutionCount++;
            _oSearch.prsc_LastExecutionDateTime = DateTime.Now;
            _oSearch.prsc_LastExecutionResultCount = 1;

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
                // just log it and keep moving
                LogError(eX);

                if (Configuration.ThrowDevExceptions)
                {
                    throw;
                }
            }
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
                    hidSearchID.Text = _oUser.prwu_LastClaimsActivitySearchID.ToString();
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

            _oSearch = GetSearchCritieria(Convert.ToInt32(hidSearchID.Text), PRWebUserSearchCriteria.SEARCH_TYPE_CLAIM_ACTIVITY);
            _oCritiera = (ClaimActivitySearchCriteria)_oSearch.Criteria;
            _bIsDirty = _oCritiera.IsDirty;
            _oCritiera.WebUser = _oUser;

            // If this is a new search, set our criteria defaults.
            if (bNew)
            {
                _oCritiera.IsQuickSearch = true;
                _oCritiera.BBID = 0;
                _oCritiera.DateRangeType = ClaimActivitySearchCriteria.CODE_DATERANGE_ALL;
            }
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
            _oCritiera.UserListIDs = GetRequestParameter("cbUserListID", false);
            PopulateUserLists(gvUserList);
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

        protected override bool IsAuthorizedForData()
        {
            return true;
        }

        protected override bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.ClaimActivitySearchPage).HasPrivilege;
        }

        public override bool EnableJSClientIDTranslation()
        {
            return true;
        }

        protected void btnSaveCritiera_Click(object sender, EventArgs e)
        {
            GetSearchCriteria();
            PopulateSearchCriteria();
            //_oSearch.Save();
            hidSearchID.Text = _oSearch.prsc_SearchCriteriaID.ToString();

            // Redirect the user to the Search Edit page
            Response.Redirect(PageConstants.Format(PageConstants.SEARCH_EDIT, hidSearchID.Text, PRWebUserSearchCriteria.SEARCH_TYPE_CLAIM_ACTIVITY));
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
            Response.Redirect(Request.RawUrl);

            //hidSearchID.Text = string.Empty;
            //hCompanyID.Value = string.Empty;
            //ddlDateRange.SelectedValue = string.Empty;
            //txtBBID.Text = "";
            //txtCompany.Text = "";

            //GetSearchCriteria();
            //PopulateForm();
        }

        /// <summary>
        /// The method will scan through the selected search criteria to determine if the user
        /// has selected elements on the expanded criteria view.  This will be used to determine
        /// the toggle state for loaded searches.
        /// </summary>
        protected void CheckForExpandedCriteria()
        {
            if (!_oCritiera.IsQuickSearch)
            {
                hPageView.Value = PAGE_VIEW_EXPANDED;
            }
        }

        /// <summary>
        /// Used to show/hide form elements based on the current page
        /// settings
        /// </summary>
        protected void SetVisibility()
        {
            // Determine if user has selected expanded or basic view
            if (hPageView.Value == PAGE_VIEW_BASIC)
            {
                pnlViewBasicButton.Visible = false;
                hlBasic.Visible = false;

                pnlViewExpandedButton.Visible = true;
                hlExpanded.Visible = true;

                // User is currently in basic view
                trBBNumber.Visible = false;
                trClaimType.Visible = false;
                trDateRange1.Visible = false;
                trDateRange2.Visible = false;
                gvUserList.Visible = false;
                litWatchdogListText.Visible = false;
                pnlWatchdogList.Visible = false;
                aceCompanyName.Enabled = true;

                btnSearch.Visible = false;
                btnClearCriteria.Visible = false;
                //btnSaveCritiera.Visible = false;
                //btnLoadCriteria.Visible = false;
            }
            else
            {
                pnlViewBasicButton.Visible = false;
                hlBasic.Visible = false;

                pnlViewExpandedButton.Visible = false;
                hlExpanded.Visible = false;

                // User is currently in expanded view
                trBBNumber.Visible = true;
                trClaimType.Visible = true;
                trDateRange1.Visible = true;
                trDateRange2.Visible = true;
                gvUserList.Visible = true;
                litWatchdogListText.Visible = true;
                pnlWatchdogList.Visible = true;
                aceCompanyName.Enabled = false;

                btnSearch.Visible = true;
                btnClearCriteria.Visible = true;
                //btnSaveCritiera.Visible = true;
                //btnLoadCriteria.Visible = true;
            }
        }

        protected string GetSearchPostBack()
        {
            return Page.ClientScript.GetPostBackEventReference(btnSearch, string.Empty);
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

                if (_oCritiera != null)
                {
                    if (!string.IsNullOrEmpty(_oCritiera.UserListIDs))
                    {
                        string[] aszIDs = _oCritiera.UserListIDs.Split(',');
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

        protected void hlExpanded_Click(object sender, EventArgs e)
        {
            Response.Redirect("ClaimActivitySearch.aspx?ClaimActivityExpanded=1&SearchID=" + hidSearchID.Text);
        }

        protected void hlBasic_Click(object sender, EventArgs e)
        {
            Response.Redirect("ClaimActivitySearch.aspx?ClaimActivityExpanded=0&SearchID=" + hidSearchID.Text);
        }
    }
}
