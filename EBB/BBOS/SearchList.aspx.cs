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

 ClassName: SearchList
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/

using System;
using System.Collections;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using TSI.BusinessObjects;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This page lists all saved searches for the current user.  The list contains all search objects
    /// that belong to the current user or are public for the current user's enterprise.
    /// 
    /// Only searches owned by the current user can be edited or deleted from this page.
    /// 
    /// The Last Unsaved Searches also cannot be edited.
    /// </summary>
    public partial class SearchList : PageBase
    {
        protected const string SQL_SELECT_SAVED_SEARCHES = "SELECT prsc_SearchCriteriaID, prsc_Name, dbo.ufn_GetCustomCaptionValue('prsc_SearchType', prsc_SearchType, '{0}') AS prsc_SearchType, prsc_IsPrivate, prsc_LastExecutionDateTime, prsc_ExecutionCount, prsc_LastExecutionResultCount, prsc_UpdatedBy, dbo.ufn_FormatPerson(Pers_FirstName, Pers_LastName, Pers_MiddleName, pers_PRNickname1, Pers_Suffix) AS UpdatedBy, prwu_BBID, dbo.ufn_GetWebUserLocation(prsc_UpdatedBy) AS UpdatedByLocation, prsc_IsLastUnsavedSearch ";
        protected const string SQL_FROM_SAVED_SEARCHES = "FROM PRWebUserSearchCriteria " +
                  "INNER JOIN PRWebUser ON prsc_UpdatedBy = prwu_WebUserID " +
                  "INNER JOIN Person_Link ON prwu_PersonLinkID = PeLi_PersonLinkId  " +
                  "INNER JOIN Person ON dbo.Person_Link.PeLi_PersonId = Pers_PersonId " +
            "WHERE prsc_Deleted IS NULL " +
            "AND ((prsc_HQID = {0} AND prsc_IsPrivate IS NULL) OR (prsc_WebUserID = {1} AND prsc_IsPrivate = 'Y'))";

        /// <summary>
        /// Calls page functions required to build and process this page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            // Set page title, sub-title and add any additional javascript functions
            // required for processing this page
            SetPageTitle(Resources.Global.Search, Resources.Global.SavedSearchCriteria);
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_FUNCTIONS2_FILE));
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_VALIDATION_FILE));

            // Add javascript functions                 
            btnDelete.Attributes.Add("onclick", "return confirmDelete('" + Resources.Global.SavedSearch + "', 'rbSearchID');");
            btnSearch.Attributes.Add("onclick", "return confirmSelect('" + Resources.Global.SavedSearch + "', 'rbSearchID')");
            //btnEdit.Attributes.Add("onclick", "return confirmSelect('" + Resources.Global.SavedSearch + "', 'rbSearchID')");
            btnLoadSearch.Attributes.Add("onclick", "return confirmSelect('" + Resources.Global.SavedSearch + "', 'rbSearchID')");

            ApplyReadOnlyCheck(btnDelete);
            //ApplyReadOnlyCheck(btnEdit);

            if (!IsPostBack)
            {
                SetSortField(gvSavedSearches, "prsc_LastExecutionDateTime");
                SetSortAsc(gvSavedSearches, false);
                PopulateForm();
            }
        }

        /// <summary>
        /// Check users page level authorization
        /// </summary>
        /// <returns></returns>
        override protected bool IsAuthorizedForPage()
        {
            return true;
        }

        /// <summary>
        /// Check users control/data level authorization
        /// </summary>
        /// <returns></returns>
        protected override bool IsAuthorizedForData()
        {
            // NOTE: Only search objects that belong to the current user or are public
            // for the current user's enterprise can be viewed.  This is handled through
            // the SQL Where clause
            return _oUser.HasPrivilege(SecurityMgr.Privilege.SaveSearches).HasPrivilege;
        }

        /// <summary>
        /// Populates the form controls.
        /// </summary>
        protected void PopulateForm()
        {
            // Retrieve the current users saved searches
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prwun_HQID", _oUser.prwu_HQID));
            oParameters.Add(new ObjectParameter("prsc_WebUserId", _oUser.prwu_WebUserID));

            string szSQL = string.Format(SQL_SELECT_SAVED_SEARCHES, _oUser.prwu_Culture) + GetObjectMgr().FormatSQL(SQL_FROM_SAVED_SEARCHES, oParameters);
            szSQL += GetOrderByClause(gvSavedSearches);

            // Setup empty grid view in case no results are returned
            //((EmptyGridView)gvSavedSearches).EmptyTableRowText = GetNoResultsFoundMsg(Resources.Global.SavedSearches);
            gvSavedSearches.ShowHeaderWhenEmpty = true;
            gvSavedSearches.EmptyDataText = GetNoResultsFoundMsg(Resources.Global.SavedSearches);

            // Retrieve data and bind to grid
            gvSavedSearches.DataSource = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            gvSavedSearches.DataBind();
            EnableBootstrapFormatting(gvSavedSearches);

            //OptimizeViewState(gvSavedSearches);

            // Display record count
            lblRecordCount.Text = string.Format(Resources.Global.RecordCountFoundMsg, gvSavedSearches.Rows.Count.ToString("###,###,##0"), Resources.Global.SavedSearches);
        }

        /// <summary>
        /// Helper method that helps with bi-directional sorting
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

            if(e.Row.RowType == DataControlRowType.DataRow)
            {
                LinkButton EditSearch = (LinkButton)e.Row.FindControl("EditSearch");
                string isLastUnsavedSearch = Convert.ToString(((IDataRecord)(e.Row.DataItem))["prsc_IsLastUnsavedSearch"]);

                if (isLastUnsavedSearch == "Y")
                {
                    EditSearch.Visible = false;
                }
            }
        }

        /// <summary>
        /// Handles the search on click event.  Takes the user to the appropriate search 
        /// results page based on the selected search type specifying the search id.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            // Retrieve the selected search object so we
            // know what type it is.  It's stored in the session so it
            // won't have to be queried again.
            PRWebUserSearchCriteriaMgr oWebUserSearchCriteriaMgr = new PRWebUserSearchCriteriaMgr(_oLogger, _oUser);
            IPRWebUserSearchCriteria oWebUserSearchCriteria;

            try
            {
                oWebUserSearchCriteria = oWebUserSearchCriteria = (IPRWebUserSearchCriteria)oWebUserSearchCriteriaMgr.GetObjectByKey(GetRequestParameter("rbSearchID"));
                oWebUserSearchCriteria.WebUser = _oUser;
            }
            catch (TSI.BusinessObjects.ObjectNotFoundException)
            {
                // It's possible for a user to have multiple tabs open and attempt to use a deleted item.
                AddUserMessage(Resources.Global.SavedSearchesPreviouslyDeleted, true);
                Response.Redirect(PageConstants.SAVED_SEARCHES);
                return;
            }

            // Redirect the user the appropriate search results page
            switch (oWebUserSearchCriteria.prsc_SearchType)
            {
                case PRWebUserSearchCriteria.SEARCH_TYPE_PERSON:
                    Response.Redirect(PageConstants.Format(PageConstants.PERSON_SEARCH_RESULTS, GetRequestParameter("rbSearchID")));
                    break;
                case PRWebUserSearchCriteria.SEARCH_TYPE_COMPANY:
                    Response.Redirect(PageConstants.Format(PageConstants.COMPANY_SEARCH_RESULTS, GetRequestParameter("rbSearchID")));
                    break;
                case PRWebUserSearchCriteria.SEARCH_TYPE_COMPANY_UPDATE:
                    Response.Redirect(PageConstants.Format(PageConstants.COMPANY_UPDATE_SEARCH + "?SearchID={0}&Action=Search", GetRequestParameter("rbSearchID")));
                    break;

                case PRWebUserSearchCriteria.SEARCH_TYPE_CLAIM_ACTIVITY:
                    Response.Redirect(PageConstants.Format(PageConstants.CLAIMS_ACTIVITY_SEARCH + "?SearchID={0}&Action=Search", GetRequestParameter("rbSearchID")));
                    break;
            }
        }

        /// <summary>
        /// Handles the Load Search Criteria on click event.  Takes the user to the appropriate search
        /// criteria page based on the selected search type specifying the selected search id.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnLoadSearch_Click(object sender, EventArgs e)
        {
            // Retrieve the selected search object
            PRWebUserSearchCriteriaMgr oWebUserSearchCriteriaMgr = new PRWebUserSearchCriteriaMgr();
            IPRWebUserSearchCriteria oWebUserSearchCriteria;

            try
            {
                oWebUserSearchCriteria = oWebUserSearchCriteria = (IPRWebUserSearchCriteria)oWebUserSearchCriteriaMgr.GetObjectByKey(GetRequestParameter("rbSearchID"));
            }
            catch (TSI.BusinessObjects.ObjectNotFoundException)
            {
                // It's possible for a user to have multiple tabs open and attempt to use a deleted item.
                AddUserMessage(Resources.Global.SavedSearchesPreviouslyDeleted, true);
                Response.Redirect(PageConstants.SAVED_SEARCHES);
                return;
            }

            string szSearchType = oWebUserSearchCriteria.prsc_SearchType;

            // Redirect the user to the appropriate search criteria page based on the search type
            switch (szSearchType)
            {
                case PRWebUserSearchCriteria.SEARCH_TYPE_COMPANY:
                    if(_oUser != null && _oUser.prwu_IndustryType == "L")
                        Response.Redirect(PageConstants.Format(PageConstants.COMPANY_SEARCH + "?SearchID={0}", GetRequestParameter("rbSearchID")));
                    else
                        Response.Redirect(PageConstants.Format(PageConstants.ADVANCED_COMPANY_SEARCH + "?SearchID={0}", GetRequestParameter("rbSearchID")));
                    break;
                case PRWebUserSearchCriteria.SEARCH_TYPE_PERSON:
                    Response.Redirect(PageConstants.Format(PageConstants.PERSON_SEARCH + "?SearchID={0}", GetRequestParameter("rbSearchID")));
                    break;
                case PRWebUserSearchCriteria.SEARCH_TYPE_COMPANY_UPDATE:
                    Response.Redirect(PageConstants.Format(PageConstants.COMPANY_UPDATE_SEARCH + "?SearchID={0}", GetRequestParameter("rbSearchID")));
                    break;

                case PRWebUserSearchCriteria.SEARCH_TYPE_CLAIM_ACTIVITY:
                    Response.Redirect(PageConstants.Format(PageConstants.CLAIMS_ACTIVITY_SEARCH + "?SearchID={0}", GetRequestParameter("rbSearchID")));
                    break;
            }
        }

        /// <summary>
        /// Handles the Edit on click event.  Takes the user to the Search Edit page specifying the selected
        /// search ID.  Only searches owned by the current user can be edited.  The Last Unsaved Searches also 
        /// cannot be edited.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnEdit_Click(object sender, EventArgs e)
        {
            // Retrieve the selected search object
            PRWebUserSearchCriteriaMgr oWebUserSearchCriteriaMgr = new PRWebUserSearchCriteriaMgr();
            IPRWebUserSearchCriteria oWebUserSearchCriteria;

            try
            {
                oWebUserSearchCriteria = oWebUserSearchCriteria = (IPRWebUserSearchCriteria)oWebUserSearchCriteriaMgr.GetObjectByKey(GetRequestParameter("rbSearchID"));
            }
            catch (TSI.BusinessObjects.ObjectNotFoundException)
            {
                // It's possible for a user to have multiple tabs open and attempt to use an item deleted from another tab item.
                AddUserMessage(Resources.Global.SavedSearchesPreviouslyDeleted, true);
                Response.Redirect(PageConstants.SAVED_SEARCHES);
                return;
            }

            // If a search is the LastUnsavedSearch, these searches cannot be edited 
            if (oWebUserSearchCriteria.prsc_IsLastUnsavedSearch)
            {
                AddUserMessage(Resources.Global.LastUnsavedCannotBeEdited);
                return;
            }

            bool bAuthorizedToEdit = false;

            // Determine if the current user is authorized to edit this search
            if (oWebUserSearchCriteria.prsc_IsPrivate)
            {
                // Private Search, user must be the search owner to edit
                if (oWebUserSearchCriteria.prsc_WebUserID == _oUser.prwu_WebUserID)
                {
                    bAuthorizedToEdit = true;
                }
            }
            else
            {
                // Public search, search must belong to the current user's enterprise                
                if (oWebUserSearchCriteria.prsc_HQID == _oUser.prwu_HQID)
                {
                    bAuthorizedToEdit = true;
                }
            }

            if (!bAuthorizedToEdit)
            {
                // Display message box that the user is not authorized to edit this search
                AddUserMessage(Resources.Global.SavedSearchEditError, true);
            }
            else
            {
                // Redirect user to search edit page
                string szSearchType = oWebUserSearchCriteria.prsc_SearchType;
                Response.Redirect(PageConstants.Format(PageConstants.SEARCH_EDIT, GetRequestParameter("rbSearchID"), szSearchType));
            }
        }

        /// <summary>
        /// Handles the delete on click event.  If the delete has been confirmed, this method will delete
        /// the selected search and refresh the search list.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnDelete_Click(object sender, EventArgs e)
        {
            // Retrieve the selected search object
            PRWebUserSearchCriteriaMgr oWebUserSearchCriteriaMgr = new PRWebUserSearchCriteriaMgr();
            IPRWebUserSearchCriteria oWebUserSearchCriteria;

            try
            {
                oWebUserSearchCriteria = (IPRWebUserSearchCriteria)oWebUserSearchCriteriaMgr.GetObjectByKey(GetRequestParameter("rbSearchID"));
            }
            catch (TSI.BusinessObjects.ObjectNotFoundException)
            {
                // It's possible for a user to have multiple tabs open and attempt to delete from each tab.
                // The second attempt will throw this exception. We'll just eat it since the object really does not exist
                AddUserMessage(Resources.Global.SavedSearchesPreviouslyDeleted, true);
                Response.Redirect(PageConstants.SAVED_SEARCHES);
                return;
            }

            // Delete the selected object
            oWebUserSearchCriteria.Delete();

            // Refresh the search page list
            Response.Redirect(PageConstants.SAVED_SEARCHES);
        }

        /// <summary>
        /// Helper method to determine if the statistic data should be displayed for the current cell.
        /// Last Unsaved Search statistic data should not be displayed.
        /// </summary>
        /// <param name="bIsLastUnsavedSearch">Is this a last unsaved search</param>
        /// <param name="iData">Statistic data value</param>
        /// <returns>Statistic data for cell</returns>
        protected string GetStatisticDataForCell(bool bIsLastUnsavedSearch, int iData)
        {
            if (bIsLastUnsavedSearch)
                // NOTE: Sort expressions is still including these values, for now
                // we will just display the last unsaved search statistics 
                //return String.Empty;                
                return iData.ToString("###,##0");
            else
                return iData.ToString("###,##0");
        }

        protected void btnEditSearch_Click(object sender, EventArgs e)
        {
            string searchCriteriaID = ((LinkButton)sender).CommandArgument; //prsc_SearchCriteriaID

            // Retrieve the selected search object
            PRWebUserSearchCriteriaMgr oWebUserSearchCriteriaMgr = new PRWebUserSearchCriteriaMgr();
            IPRWebUserSearchCriteria oWebUserSearchCriteria;

            try
            {
                oWebUserSearchCriteria = oWebUserSearchCriteria = (IPRWebUserSearchCriteria)oWebUserSearchCriteriaMgr.GetObjectByKey(searchCriteriaID);
            }
            catch (TSI.BusinessObjects.ObjectNotFoundException)
            {
                // It's possible for a user to have multiple tabs open and attempt to use an item deleted from another tab item.
                AddUserMessage(Resources.Global.SavedSearchesPreviouslyDeleted, true);
                Response.Redirect(PageConstants.SAVED_SEARCHES);
                return;
            }

            // If a search is the LastUnsavedSearch, these searches cannot be edited 
            if (oWebUserSearchCriteria.prsc_IsLastUnsavedSearch)
            {
                AddUserMessage(Resources.Global.LastUnsavedCannotBeEdited);
                return;
            }

            bool bAuthorizedToEdit = false;

            // Determine if the current user is authorized to edit this search
            if (oWebUserSearchCriteria.prsc_IsPrivate)
            {
                // Private Search, user must be the search owner to edit
                if (oWebUserSearchCriteria.prsc_WebUserID == _oUser.prwu_WebUserID)
                {
                    bAuthorizedToEdit = true;
                }
            }
            else
            {
                // Public search, search must belong to the current user's enterprise                
                if (oWebUserSearchCriteria.prsc_HQID == _oUser.prwu_HQID)
                {
                    bAuthorizedToEdit = true;
                }
            }

            if (!bAuthorizedToEdit)
            {
                // Display message box that the user is not authorized to edit this search
                AddUserMessage(Resources.Global.SavedSearchEditError, true);
            }
            else
            {
                // Popup search edit page in iFrame
                string szSearchType = oWebUserSearchCriteria.prsc_SearchType;
                //Response.Redirect(PageConstants.Format(PageConstants.SEARCH_EDIT, GetRequestParameter("rbSearchID"), szSearchType));
                //Response.Redirect(PageConstants.Format(PageConstants.SEARCH_EDIT, _iSearchID, PRWebUserSearchCriteria.SEARCH_TYPE_PERSON));
                displaySearchIFrame(string.Format("?SearchID={0}&Type={1}", searchCriteriaID, szSearchType));
            }
        }

        protected void displaySearchIFrame(string parms)
        {
            //Session["CompanyHeader_szCompanyID"] = hidCompanyID.Text;
            ifrmSearchEdit.Attributes.Add("src", PageConstants.SEARCH_EDIT_POPUP + parms);
            ModalPopupExtender3.Show();
        }
    }
}
