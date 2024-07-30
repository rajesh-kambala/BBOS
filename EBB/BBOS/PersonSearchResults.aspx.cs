/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc., 2012-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: PersonSearchResults
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using TSI.BusinessObjects;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    public partial class PersonSearchResults : PersonSearchBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            SetPageTitle(Resources.Global.PersonSearchResults);
            Session["ReturnURL"] = PageConstants.PERSON_SEARCH_RESULTS_EXECUTE_LAST;

            SetVisibility();
            string szExportClick = "if (!confirmSelect('" + Resources.Global.Persons_Paren + "', 'cbPersonID') || !ValidateExportsCount()) return false;";
            btnExportData.Attributes.Add("onclick", szExportClick );
            btnPrintList.Attributes.Add("onclick", szExportClick);

            if (!IsPostBack)
            {
                // Populate form -> execute search
                ExecuteSearch();
                
                //Exports management
                ExportsManagement(hidExportsPeriod, hidExportsMax, hidExportsUsed);
            }

            // See issue #54.  Hiding it from the user for now.
            // We should probably remove the code at some point but
            // restoring it would be a pain so let's make sure this
            // is want we want to do first.
            btnNewSearch.Visible = false;
        }

        protected StringBuilder personIDList = new StringBuilder();
        protected StringBuilder webUserContactIDList = new StringBuilder();

        /// <summary>
        /// Executes the person search given the criteria specified on the search form.
        /// </summary>        
        private void ExecuteSearch()
        {
            IPRWebUserSearchCriteria oWebUserSearchCriteria;

            // Retrieve the search object for this user
            if (!string.IsNullOrEmpty(GetRequestParameter("ExecuteLastSearch", false)))
            {
                // If requested, retrieve the last executed search
                oWebUserSearchCriteria = new PRWebUserSearchCriteriaMgr(_oLogger, _oUser).GetLastExecuted(PRWebUserSearchCriteria.SEARCH_TYPE_PERSON);
                oWebUserSearchCriteria.WebUser = _oUser;
                Session["oWebUserSearchCriteria"] = oWebUserSearchCriteria;
            }
            else
            {
                // Retrieve the current search criteria object
                oWebUserSearchCriteria = GetSearchCritieria(_iSearchID, PRWebUserSearchCriteria.SEARCH_TYPE_PERSON);
            }

            string orderBy = GetOrderByClause(gvSearchResults);
            ArrayList oParameters;

            // Build a list of PersonIDs for use later when querying for the companies each person is associated with.
            string szSQL = ((PersonSearchCriteria)oWebUserSearchCriteria.Criteria).GetPersonIDsSQL(out oParameters);
            using (IDataReader reader = GetDBAccess().ExecuteReader(szSQL + orderBy, oParameters, CommandBehavior.CloseConnection, null))
            {
                while (reader.Read())
                {
                    if (personIDList.Length > 0)
                    {
                        personIDList.Append(",");
                    }
                    personIDList.Append(reader[0]);
                }
            }

            // Build a list of WebUserContactIDs for use later when querying for the companies each WebUserContact is associated with.
            szSQL = ((PersonSearchCriteria)oWebUserSearchCriteria.Criteria).GetWebUserContactIDsSQL(out oParameters);
            using (IDataReader reader = GetDBAccess().ExecuteReader(szSQL + orderBy, oParameters, CommandBehavior.CloseConnection, null))
            {
                while (reader.Read())
                {
                    if (webUserContactIDList.Length > 0)
                    {
                        webUserContactIDList.Append(",");
                    }
                    webUserContactIDList.Append(reader[0]);
                }
            }

            // Retrieve previously selected ids so we can recheck selections on grid
            szSelectedIDs = oWebUserSearchCriteria.prsc_SelectedIDs;

            szSQL = oWebUserSearchCriteria.Criteria.GetSearchSQL(out oParameters);
            szSQL += orderBy;

            // Setup empty grid in case no results are returned
            //((EmptyGridView)gvSearchResults).EmptyTableRowText = GetNoResultsFoundMsg(Resources.Global.Persons);
            gvSearchResults.ShowHeaderWhenEmpty = true;
            gvSearchResults.EmptyDataText = GetNoResultsFoundMsg(Resources.Global.Persons);

            // Execute search and bind results to the data grid
            gvSearchResults.DataSource = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            gvSearchResults.DataBind();
            EnableBootstrapFormatting(gvSearchResults);

            OptimizeViewState(gvSearchResults);

            // Only query for the total number of rows if our
            // limit was reached on the main query.
            if (gvSearchResults.Rows.Count == Configuration.PersonSearchMaxResults)
            {
                // Get the Search SQL based on the current search criteria
                ArrayList oCountParameters;
                string szCountSQL = oWebUserSearchCriteria.Criteria.GetSearchCountSQL(out oCountParameters);
                oCountParameters.Add(new ObjectParameter("HQID", _oUser.prwu_HQID));
                oCountParameters.Add(new ObjectParameter("WebUserID", _oUser.prwu_WebUserID));

                int iCount = (int)GetDBAccess().ExecuteScalar(szCountSQL, oCountParameters);
                if (iCount > Configuration.PersonSearchMaxResults)
                {
                    AddUserMessage(string.Format(GetMaxResultsMsg(), iCount.ToString("###,##0"), Configuration.PersonSearchMaxResults.ToString("###,##0")));
                }
            }

            if (gvSearchResults.Rows.Count == 0)
            {
                btnExportData.Enabled = false;
                btnPrintList.Enabled = false;
            }

            if (_oUser.IsTrialPeriodActive())
            {
                btnExportData.Enabled = false;
            }

            // Display the results count
            lblRecordCount.Text = string.Format(Resources.Global.RecordCountFoundMsg, gvSearchResults.Rows.Count, Resources.Global.Persons);

            // Update the search stats
            oWebUserSearchCriteria.prsc_ExecutionCount++;
            oWebUserSearchCriteria.prsc_LastExecutionDateTime = DateTime.Now;
            oWebUserSearchCriteria.prsc_LastExecutionResultCount = gvSearchResults.Rows.Count;

            // The user isn't required to enter any criteria, meaning that a new search's dirty
            // flag can be false.  In order for this to fall into the "Last Unsaved Search" logic,
            // the dirty flag has to be true.  So let's set it here to make that happen.
            if ((oWebUserSearchCriteria.prsc_SearchCriteriaID == 0) &&
                (!oWebUserSearchCriteria.Criteria.IsDirty))
            {
                oWebUserSearchCriteria.Criteria.IsDirty = true;
            }

            if (!IsImpersonating())
            {
                // Save the updated search data
                PRWebUserSearchCriteriaMgr oWebUserSearchCriteriaMgr = new PRWebUserSearchCriteriaMgr(_oLogger, _oUser);
                oWebUserSearchCriteriaMgr.SaveLastSearch((PRWebUserSearchCriteria)oWebUserSearchCriteria, null);

                try
                {
                    IDbTransaction oTran = GetObjectMgr().BeginTransaction();
                    GetObjectMgr().InsertSearchAuditTrail(oWebUserSearchCriteria, oTran);
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

            // Setup return url
            Session["ReturnURL"] = PageConstants.PERSON_SEARCH;

            // Determine if we should redirect to the person details if only one user was found
            if (gvSearchResults.Rows.Count == 1)
            {
                if (Configuration.DisplayDetailsForOneResult)
                {
                    int iPersonID = Convert.ToInt32(gvSearchResults.DataKeys[0].Values[0].ToString());
                    string szSourceTable = gvSearchResults.DataKeys[0].Values[1].ToString();

                    if (szSourceTable == SOURCE_TABLE_PRWEBUSERCONTACT)
                    {
                        Response.Redirect(PageConstants.Format(PageConstants.USER_CONTACT, iPersonID));
                    }
                    else
                    {
                        Response.Redirect(PageConstants.Format(PageConstants.PERSON_DETAILS, iPersonID));
                    }
                }
            }
        }

        /// <summary>
        /// Handles the New Search on click event for the person search pages.  
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnNewSearch_Click(object sender, EventArgs e)
        {
            Response.Redirect(PageConstants.SAVED_SEARCHES);
        }

        /// <summary>
        /// Handles the Edit Search Criteria on click event for the person search pages.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnEditSearchCriteria_Click(object sender, EventArgs e)
        {
            IPRWebUserSearchCriteria oWebUserSearchCriteria = GetSearchCritieria(_iSearchID, PRWebUserSearchCriteria.SEARCH_TYPE_PERSON, true);

            if (oWebUserSearchCriteria == null)
            {
                Response.Redirect(PageConstants.PERSON_SEARCH + "?SearchID=" + _iSearchID.ToString());
            }
            else
            {
                Response.Redirect(GetEditCriteriaURL((PersonSearchCriteria)oWebUserSearchCriteria.Criteria));
            }
        }

        /// <summary>
        /// Helper method that helps with bi-directional sorting
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void GridView_Sorting(Object sender, GridViewSortEventArgs e)
        {
            SetSortingAttributes((GridView)sender, e);
            ExecuteSearch();
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
        /// Helper method assumes the other sort helper methods are used to
        /// store current sort information on the specified GridView.
        /// </summary>
        /// <param name="oGridView"></param>
        /// <returns></returns>
        public static string GetOrderByClause(GridView oGridView)
        {
            if (GetSortField(oGridView) == "LastName")
            {
                string szOrder = string.Empty;
                if (!GetSortAsc(oGridView))
                {
                    szOrder = " DESC ";
                }

                return " ORDER BY LastName " + szOrder + ", FirstName " + szOrder;

            }
            else
            {
                return GetOrderByClause(oGridView);
            }
        }

        /// <summary>
        /// Used to show/hide form elements based on the current page
        /// settings
        /// </summary>
        protected void SetVisibility()
        {
            // Save Search Criteria should only be available if the current user owns the selected
            // search
            btnSaveSearch.Enabled = bCurrentUserOwnsSearch;

            // See issue #54.  Hiding it from the user for now.
            // We should probably remove the code at some point but
            // restoring it would be a pain so let's make sure this
            // is want we want to do first.
            btnNewSearch.Visible = false;

            ApplySecurity(btnExportData, SecurityMgr.Privilege.PersonDataExport);
            ApplySecurity(btnPrintList, SecurityMgr.Privilege.PersonReportsPage);
        }

        protected string GetEditCriteriaURL(PersonSearchCriteria oCriteria)
        {
            if (!string.IsNullOrEmpty(oCriteria.CompanyName) ||
                (oCriteria.BBID > 0) ||
                !string.IsNullOrEmpty(oCriteria.LastName) ||
                !string.IsNullOrEmpty(oCriteria.FirstName) ||
                !string.IsNullOrEmpty(oCriteria.Title) ||
                !string.IsNullOrEmpty(oCriteria.PhoneAreaCode) ||
                !string.IsNullOrEmpty(oCriteria.PhoneNumber) ||
                !string.IsNullOrEmpty(oCriteria.Email))
            {
                return PageConstants.PERSON_SEARCH + "?SearchID=" + _iSearchID.ToString();
            }

            if (!string.IsNullOrEmpty(oCriteria.ListingCountryIDs) ||
                !string.IsNullOrEmpty(oCriteria.ListingStateIDs) ||
                !string.IsNullOrEmpty(oCriteria.ListingCity) ||
                !string.IsNullOrEmpty(oCriteria.ListingCounty) ||
                !string.IsNullOrEmpty(oCriteria.TerminalMarketIDs) ||
                !string.IsNullOrEmpty(oCriteria.ListingPostalCode))
            {
                return "PersonSearchLocation.aspx?SearchID=" + _iSearchID.ToString();
            }

            if (oCriteria.HasNotes)
            {
                return "PersonSearchCustom.aspx?SearchID=" + _iSearchID.ToString();
            }

            return PageConstants.PERSON_SEARCH;
        }

        protected string GetPersonCompanies(int iPersonID, string szSourceTable)
        {
            return GetPersonCompanies(iPersonID, szSourceTable, personIDList.ToString());
        }

        protected string GetBBNumbers(int iPersonID, string szSourceTable)
        {
            return GetBBNumbers(iPersonID, szSourceTable, personIDList.ToString());
        }

        protected string GetCompanyNames(int iPersonID, string szSourceTable, bool bIncludeIcons, bool bIncludeCompanyNameLink)
        {
            return GetCompanyNames(iPersonID, szSourceTable, personIDList.ToString(), bIncludeIcons:bIncludeIcons, bIncludeCompanyNameLink:bIncludeCompanyNameLink, bCompanyLinksNewTab:_oUser.prwu_CompanyLinksNewTab);
        }

        protected string GetCompanyLocations(int iPersonID, string szSourceTable)
        {
            return GetCompanyLocations(iPersonID, szSourceTable, personIDList.ToString());
        }

        private List<string> _lSelectedIDs = null;
        private string szSelectedIDs = "";

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

                // Check SelectedIDs on web user search criteria object
                if (!String.IsNullOrEmpty(szSelectedIDs))
                {
                    string[] aszIDs = szSelectedIDs.Split(',');
                    _lSelectedIDs.AddRange(aszIDs);
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
        /// Saves the selected company IDs
        /// </summary>
        private void SaveSelected()
        {
            string[] aPersonIDs = GetRequestParameter("cbPersonID").Split(',');
            if (aPersonIDs.Length <= Utilities.GetIntConfigValue("PersonSearchResultsSelectedThreshold", 1100))
            {
                IPRWebUserSearchCriteria oWebUserSearchCriteria = GetSearchCritieria(_iSearchID, PRWebUserSearchCriteria.SEARCH_TYPE_PERSON);
                oWebUserSearchCriteria.prsc_SelectedIDs = GetRequestParameter("cbPersonID");

                PRWebUserSearchCriteriaMgr oWebUserSearchCriteriaMgr = new PRWebUserSearchCriteriaMgr(_oLogger, _oUser);
                oWebUserSearchCriteriaMgr.SaveLastSearch((PRWebUserSearchCriteria)oWebUserSearchCriteria, null); //fix bug where 1st search wasn't saved to database - Defect 3847 (jeff and chris debugged this together)
                oWebUserSearchCriteriaMgr.SaveSelected(oWebUserSearchCriteria, null);
            }
        }

        protected void btnExportData_Click(object sender, EventArgs e)
        {
            SaveSelected();
            SetRequestParameter("PersonIDList", GetRequestParameter("cbPersonID"));
            Response.Redirect("PersonConfirmSelections.aspx?Type=DE");
        }

        /// <summary>
        /// Handles the Reports on click event.  Invokes the Save Selected function to save
        /// the selected company's on the form, and takes the user to the ReportsConfirmSelections.aspx page 
        /// for the selected companies.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnPrintList_Click(object sender, EventArgs e)
        {
            SaveSelected();
            SetRequestParameter("PersonIDList", GetRequestParameter("cbPersonID"));
            Response.Redirect("PersonConfirmSelections.aspx?Type=R");
        }
    }
}