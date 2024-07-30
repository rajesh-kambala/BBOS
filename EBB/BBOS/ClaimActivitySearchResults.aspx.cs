/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2014-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: ClaimActivitySearchResults
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using TSI.BusinessObjects;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    public partial class ClaimActivitySearchResults : PageBase
    {
        IPRWebUserSearchCriteria _oSearch = null;
        ClaimActivitySearchCriteria _oCritiera = null;
        bool _bProcessSearchAudit = true;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            SetPageTitle(Resources.Global.ClaimActivitySearch);

            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_TOGGLE_FUNCTIONS_FILE));
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_FUNCTIONS2_FILE));
            EnableFormValidation();
            btnAddToWatchdogList.Attributes.Add("onclick", "return confirmSelect('" + Resources.Global.Company + "', 'cbCompanyID')");

            GetSearchCriteria();

            if (!IsPostBack)
            {
                SetSortField(gvSearchResults, "FiledDate");
                SetSortAsc(gvSearchResults, false);

                Search();
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
                    hidSearchID.Text = "0";
                }
            }

            _oSearch = GetSearchCritieria(Convert.ToInt32(hidSearchID.Text), PRWebUserSearchCriteria.SEARCH_TYPE_CLAIM_ACTIVITY);

            // Finnally just throw an exception.
            if (_oSearch == null)
            {
                Response.Redirect(PageConstants.CLAIMS_ACTIVITY_SEARCH);
                return;
            }

            _oCritiera = (ClaimActivitySearchCriteria)_oSearch.Criteria;

            // Retrieve previously selected ids so we can recheck selections on grid
            szSelectedIDs = _oSearch.prsc_SelectedIDs;
        }

        /// <summary>
        /// Executes the search populating the results grid.
        /// </summary>
        protected void Search()
        {
            ArrayList oParameters = null;
            string szSQL = _oCritiera.GetSearchSQL(out oParameters);
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
            if (gvSearchResults.Rows.Count == Configuration.ClaimActivitySearchMaxResults)
            {
                ArrayList oCountParameters;
                string szCountSQL = _oCritiera.GetSearchCountSQL(out oCountParameters);
                oCountParameters.Add(new ObjectParameter("HQID", _oUser.prwu_HQID));
                oCountParameters.Add(new ObjectParameter("WebUserID", _oUser.prwu_WebUserID));

                int iCount = (int)GetDBAccess().ExecuteScalar(szCountSQL, oCountParameters);
                if (iCount > Configuration.ClaimActivitySearchMaxResults)
                {
                    AddUserMessage(string.Format(GetMaxResultsMsg(), iCount.ToString("###,##0"), Configuration.ClaimActivitySearchMaxResults.ToString("###,##0")));
                }
            }

            lblRecordCount.Text = string.Format(Resources.Global.RecordCountFoundMsg, gvSearchResults.Rows.Count, "Claims");

            if (gvSearchResults.Rows.Count == 0)
            {
                btnAddToWatchdogList.Enabled = false;
            }
            //btnSaveCritiera.Enabled = true;

            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "DisableValidation", "DisableValidation();", true);

            if (_bProcessSearchAudit)
            {
                ProcessSearchAudit();
            }

            ApplySecurity(btnAddToWatchdogList, SecurityMgr.Privilege.WatchdogListAdd);

            // Determine if we should redirect to the company claim activity details if only one record was found
            // The user must have the appropriate security access for this.
            if (gvSearchResults.Rows.Count > 0)
            {
                List<int> lstBBID = new List<int>();
                foreach(GridViewRow gvRow in gvSearchResults.Rows)
                {
                    int iCompanyID = Convert.ToInt32(gvRow.Cells[1].Text);
                    lstBBID.Add(iCompanyID);
                }

                if (lstBBID.Select(t => t.ToString()).Distinct().Count() == 1)
                {
                    if ((_oUser.HasPrivilege(SecurityMgr.Privilege.CompanyDetailsClaimActivityPage).HasPrivilege) &&
                        (Configuration.DisplayDetailsForOneResult))
                    {
                        int iCompanyID = Convert.ToInt32(gvSearchResults.Rows[0].Cells[1].Text);
                        Response.Redirect(PageConstants.Format(PageConstants.COMPANY_CLAIMS_ACTIVITY_BBOS9, lstBBID.Select(t => t.ToString()).ToList()[0]));
                        return;
                    }
                }
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
            SetReturnURL(PageConstants.CLAIMS_ACTIVITY_SEARCH_RESULTS + "?ExecuteLastSearch=1");
            SetRequestParameter("CompanyIDList", GetRequestParameter("cbCompanyID"));
            SaveSelected();
            Response.Redirect(string.Format(PageConstants.BUSINESS_REPORT_CONFIRM_SELECTIONS, string.Empty, string.Empty));
        }

        protected void btnAddToWatchdogListOnClick(object sender, EventArgs e)
        {
            SetReturnURL(PageConstants.CLAIMS_ACTIVITY_SEARCH_RESULTS + "?ExecuteLastSearch=1");
            SetRequestParameter("CompanyIDList", GetRequestParameter("cbCompanyID"));
            SaveSelected();
            Response.Redirect(PageConstants.USER_LIST_ADD_TO);
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
            Search();
        }

        List<string> _lSelectedCompanyIDs = null;
        string szSelectedIDs = null;

        /// <summary>
        /// Determines if the specified ID is part of the
        /// selected list.  If so, returns " checked ".
        /// </summary>
        /// <param name="iID"></param>
        /// <returns></returns>
        protected string GetCompanyChecked(int iID)
        {
            string szID = iID.ToString();

            // Only build our list of IDs once.
            if (_lSelectedCompanyIDs == null)
            {
                _lSelectedCompanyIDs = new List<string>();

                if (_oCritiera != null)
                {
                    if (!string.IsNullOrEmpty(szSelectedIDs))
                    {
                        string[] aszIDs = szSelectedIDs.Split(',');
                        _lSelectedCompanyIDs.AddRange(aszIDs);
                    }
                }
            }

            if (_lSelectedCompanyIDs.Contains(szID))
            {
                return " checked ";
            }
            else
            {
                return string.Empty;
            }
        }

        /// <summary>
        /// Saves the selected company IDs
        /// </summary>
        private void SaveSelected()
        {
            string[] aCompanyIDs = GetRequestParameter("cbCompanyID").Split(',');
            IPRWebUserSearchCriteria oWebUserSearchCriteria = GetSearchCritieria(Convert.ToInt32(hidSearchID.Text), PRWebUserSearchCriteria.SEARCH_TYPE_CLAIM_ACTIVITY);
            oWebUserSearchCriteria.prsc_SelectedIDs = GetRequestParameter("cbCompanyID");

            PRWebUserSearchCriteriaMgr oWebUserSearchCriteriaMgr = new PRWebUserSearchCriteriaMgr(_oLogger, _oUser);
            oWebUserSearchCriteriaMgr.SaveLastSearch((PRWebUserSearchCriteria)oWebUserSearchCriteria, null); //fix bug where 1st search wasn't saved to database - Defect 3847 (jeff and chris debugged this together)
            oWebUserSearchCriteriaMgr.SaveSelected(oWebUserSearchCriteria, null);
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

        /// <summary>
        /// Adds the sort indicator to the appropriate column
        /// header.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void GridView_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            SetSortIndicator((GridView)sender, e);

            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                Literal litLegalName = (Literal)e.Row.FindControl("litLegalName");
                if (string.IsNullOrEmpty(litLegalName.Text) || litLegalName.Text == "<br/>")
                    litLegalName.Visible = false;

                if (_oUser.prwu_CompanyLinksNewTab)
                {
                    HyperLink hlCompanyDetails = (HyperLink)e.Row.FindControl("hlCompanyDetails");
                    hlCompanyDetails.Target = "_blank";
                }
            }
        }

        protected void btnSaveCritiera_Click(object sender, EventArgs e)
        {
            GetSearchCriteria();
            //_oSearch.Save();
            hidSearchID.Text = _oSearch.prsc_SearchCriteriaID.ToString();

            // Redirect the user to the Search Edit page
            Response.Redirect(PageConstants.Format(PageConstants.SEARCH_EDIT, hidSearchID.Text, PRWebUserSearchCriteria.SEARCH_TYPE_CLAIM_ACTIVITY));
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

        /// <summary>
        /// Hides the results and displays the criteria
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnRefineOnClick(object sender, EventArgs e)
        {
            Response.Redirect(PageConstants.CLAIMS_ACTIVITY_SEARCH);
        }
    }
}