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

 ClassName: UserListAddTo
 Description:	

 Notes:	

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
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This page allows the user to add companies to multiple lists.  
    /// 
    /// The selected companies will be added to the selected lists.  The user will then be returned
    /// the CompanySearchResults.aspx page.  
    /// </summary>
    public partial class UserListAddTo : UserListBase
    {
        /// <summary>
        /// Calls page functions required to build and process this page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            // Set page title, sub-title, and include any additonal javascript
            // files required for this page.
            SetPageTitle(Resources.Global.AddToWatchdogLists);
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_TOGGLE_FUNCTIONS_FILE));
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_FUNCTIONS2_FILE));
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_VALIDATION_FILE));

            btnSave.Attributes.Add("onclick", "return confirmSelect('" + Resources.Global.WatchdogList + "', 'cbUserListID')");

            if (!IsPostBack)
            {
                SetSortField(gvSelectedCompanies, "comp_PRBookTradestyle");
                SetSortField(gvUserList, "prwucl_Name");
                PopulateForm();

                if (Session["ReturnURL2"] != null)
                {
                    Session["ReturnURL"] = Session["ReturnURL2"];
                    Session.Remove("ReturnURL2");
                }

                ApplySecurity(btnNew, SecurityMgr.Privilege.WatchdogListNew);
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
        override protected bool IsAuthorizedForData()
        {
            // The user must "own" the list in order to edit it.  This check will be done after the
            // user list data has been retrieved.            
            return true;
        }

        /// <summary>
        /// Populates the form controls.
        /// </summary>
        protected void PopulateForm()
        {
            // Populate selected company list
            PopulateCompanyList();

            // Watchdog Lists
            PopulateMyUserLists(gvUserList);

            //Defect 6769 - Enforce 5 watchdog groups for L200 STANDARD
            hidIsLumber_STANDARD.Value = _oUser.IsLumber_STANDARD().ToString();
            hidWatchdogGroupMax.Value = Configuration.WatchdogGroupsMax_L200.ToString(); //5
            hidWatchdogGroupCount.Value = _oUser.GetWatchdogCustomCount().ToString();
        }

        /// <summary>
        /// Populates the Company list grid view control on the form
        /// </summary>
        protected void PopulateCompanyList()
        {
            // Restrieve the selected companies to use to populate the selected companies 
            // data grid 
            string szSelectedCompanyIDs = GetRequestParameter("CompanyIDList", true, true);

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

            //OptimizeViewState(gvSelectedCompanies);

            // Display the number of matching records found
            lblRecordCount.Text = string.Format(Resources.Global.RecordSelectedMsg, gvSelectedCompanies.Rows.Count, Resources.Global.Companies);

            // If no results are found, disable the buttons that require a company            
            if (gvSelectedCompanies.Rows.Count == 0)
            {
                btnSave.Enabled = false;
                btnCancel.Enabled = false;
            }
        }

        /// <summary>
        /// Handles the Save on click event.  Saves the changes adding the companies to the selected
        /// lists.  Takes the user to the CompanySearchResults.aspx page specifying the ExecuteLastSearch
        /// parameter.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnSave_Click(object sender, EventArgs e)
        {
            string szSelectedLists = GetRequestParameter("cbUserListID");
            string[] aszSelectedLists = szSelectedLists.Split(new char[] { ',' });

            string szSelectedCompanyIDs = GetRequestParameter("CompanyIDList", true);
            string[] aszSelectedCompanies = szSelectedCompanyIDs.Split(new char[] { ',' });

            bool bListUpdated;

            oTran = GetObjectMgr().BeginTransaction();
            try
            {
                foreach (string szList in aszSelectedLists)
                {
                    bListUpdated = false;

                    foreach (string szCompanyID in aszSelectedCompanies)
                    {
                        // Check if a PRWebUserListDetail record already exists
                        //if (!(GetObjectMgr().PRWebUserListDetailRecordExists(Convert.ToInt32(szList), Convert.ToInt32(szCompanyID), oTran)))
                        if (!PRWebUserListDetailRecordExists(szList, szCompanyID))
                        {
                            // Insert new PRWebUserListDetail record for this company and list
                            GetObjectMgr().AddPRWebUserListDetail(Convert.ToInt32(szList), Convert.ToInt32(szCompanyID), GetAUSListID(), oTran);
                            bListUpdated = true;
                        }
                    }

                    if (bListUpdated)
                        GetObjectMgr().UpdatePRWebUserList(Convert.ToInt32(szList), oTran);
                }

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

            // Take the user to the Company Search Results page
            PageControlBaseCommon.ResetCompanyDataSession();
            Response.Redirect(GetReturnURL(PageConstants.COMPANY_SEARCH_RESULTS_EXECUTE_LAST));
        }

        HashSet<Int32> userListAssociatedIDs = null;
        /// <summary>
        /// This has to be better than executing the same "Select"  statement
        /// over and over in a loop for each selected company ID
        /// </summary>
        /// <param name="listID"></param>
        /// <param name="companyID"></param>
        /// <returns></returns>
        protected bool PRWebUserListDetailRecordExists(string listID, string companyID)
        {
            //if (userListAssociatedIDs == null)
            //{
            userListAssociatedIDs = GetUserListCompanyIDAsHashSet(Convert.ToInt32(listID));
            //}

            return userListAssociatedIDs.Contains(Convert.ToInt32(companyID));
        }

        /// <summary>
        /// Handles the cancel on click event.  Takes the user to the CompanySearchResults.aspx page 
        /// specifying the ExecuteLastSearch parameter.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Response.Redirect(GetReturnURL(PageConstants.COMPANY_SEARCH_RESULTS_EXECUTE_LAST));
        }

        protected void btnNew_Click(object sender, EventArgs e)
        {
            Session["ReturnURL2"] = GetReturnURL(PageConstants.COMPANY_SEARCH_RESULTS_EXECUTE_LAST);
            SetReturnURL(PageConstants.USER_LIST_ADD_TO);
            Response.Redirect(PageConstants.Format(PageConstants.USER_LIST_EDIT, 0));
        }

        /// <summary>
        /// Helper method that helps with bi-directional sorting
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void UserListGridView_Sorting(Object sender, GridViewSortEventArgs e)
        {
            SetSortingAttributes((GridView)sender, e);
            PopulateMyUserLists(gvUserList);
        }

        /// <summary>
        /// Helper method that helps with bi-directional sorting
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void GridView_Sorting(Object sender, GridViewSortEventArgs e)
        {
            SetSortingAttributes((GridView)sender, e);
            PopulateCompanyList();
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

                string szSelectedUserLists = GetRequestParameter("cbUserListID", false);
                if (!String.IsNullOrEmpty(szSelectedUserLists))
                {
                    string[] aszIDs = szSelectedUserLists.Split(',');
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

        protected const string SQL_GET_MY_USER_LISTS =
            @"SELECT prwucl_WebUserListID, prwucl_Name, 
                     prwucl_IsPrivate, prwucl_CategoryIcon,
                     MAX(prwucl_UpdatedDate) AS UpdatedDate, COUNT(prwuld_WebUserListDetailID) As CompanyCount 
                FROM PRWebUserList WITH (NOLOCK) 
                     LEFT OUTER JOIN PRWebUserListDetail WITH (NOLOCK) ON prwucl_WebUserListID = prwuld_WebUserListID 
               WHERE ((prwucl_HQID={0} AND prwucl_IsPrivate IS NULL) OR (prwucl_WebUserID={1} AND prwucl_IsPrivate = 'Y')) 
                 AND prwucl_TypeCode <> '" + CODE_LIST_TYPE_CONNECTIONLIST + "'";

        private const string SQL_GROUP_BY = " GROUP BY prwucl_WebUserListID, prwucl_Name, prwucl_IsPrivate, prwucl_CategoryIcon";

        /// <summary>
        /// Populates the UserList section of the page.
        /// </summary>
        protected void PopulateMyUserLists(GridView gvUserList)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prwucl_HQID", _oUser.prwu_HQID));
            oParameters.Add(new ObjectParameter("prwucl_WebUserID", _oUser.prwu_WebUserID));

            string[] aszKeyName = { "prwucl_WebUserListID" };

            string szSQL;
            // Level 3 access is required to view custom user lists
            if (_oUser.HasPrivilege(SecurityMgr.Privilege.WatchdogListAdd).HasPrivilege)
                szSQL = GetObjectMgr().FormatSQL(SQL_GET_MY_USER_LISTS, oParameters);
            else
                szSQL = GetObjectMgr().FormatSQL(SQL_GET_MY_USER_LISTS + SQL_EXCLUDE_CUSTOM_LISTS, oParameters);

            // Defect 7052 - L150 only get the Alerts List
            if (_oUser.prwu_AccessLevel == PRWebUser.SECURITY_LEVEL_BASIC_PLUS)
            {
                szSQL += " AND prwucl_TypeCode = 'AUS' ";
            }

            szSQL += SQL_GROUP_BY;
            szSQL += GetOrderByClause(gvUserList);

            //((EmptyGridView)gvUserList).EmptyTableRowText = GetNoResultsFoundMsg(Resources.Global.WatchdogLists);
            gvUserList.ShowHeaderWhenEmpty = true;
            gvUserList.EmptyDataText = GetNoResultsFoundMsg(Resources.Global.WatchdogLists);

            gvUserList.DataKeyNames = aszKeyName;
            gvUserList.DataSource = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            gvUserList.DataBind();
            EnableBootstrapFormatting(gvUserList);

            if (gvUserList.Rows.Count == 0)
            {
                btnSave.Enabled = false;
            }
        }
    }
}
