/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2022

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: UserListList
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Data;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using TSI.BusinessObjects;
using TSI.DataAccess;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This page displays the user lists the current user has view access to.
    /// 
    /// Only lists "owned" by the current user can be edited.  In addition, connection lists cannot
    /// be edited from this page.
    /// 
    /// The current user has view access to lists that they own, as well as any public lists associated
    /// with their company HQID.
    /// </summary>
    public partial class UserListList : UserListBase
    {
        // SQL used to retrieve the last updated by user and location based on the 
        // data avaiable for this list in the PWebUserListDetail table
        protected const string SQL_GET_USER_LIST_UPDATEDBY =
            @"SELECT dbo.ufn_FormatPerson(Pers_FirstName, Pers_LastName, Pers_MiddleName, pers_PRNickname1, Pers_Suffix) AS UpdatedBy, 
                     dbo.ufn_GetWebUserLocation(prwucl_UpdatedBy) AS UpdatedByLocation 
                FROM PRWebUserList WITH (NOLOCK) 
                     INNER JOIN PRWebUser WITH (NOLOCK) ON prwucl_UpdatedBy = prwu_WebUserID 
                     INNER JOIN Person_Link WITH (NOLOCK) ON prwu_PersonLinkID = PeLi_PersonLinkId 
                     INNER JOIN Person WITH (NOLOCK) ON dbo.Person_Link.PeLi_PersonId = Pers_PersonId 
               WHERE prwucl_WebUserListID = {0} 
                 AND prwucl_TypeCode <> 'CL'";

        private string szListTypeCode;

        private int iOwnedByWebUserID;
        private int iListHQID;

        private bool bIsPrivate;

        /// <summary>
        /// Calls page functions required to build and process this page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            // Set page title and add any additional javascript files required for processing 
            // the page
            SetPageTitle(Resources.Global.WatchdogListsAlerts);
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_FUNCTIONS2_FILE));
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_VALIDATION_FILE));
            btnEdit.Attributes.Add("onclick", "return confirmOneSelected('" + Resources.Global.WatchdogList + "', 'rbUserListID')");

            if (!IsPostBack)
            {
                SetReturnURL(PageConstants.BROWSE_COMPANIES);
                SetSortField(gvUserList, "prwucl_Name");

                PopulateForm();

                // Add javascript functions                 
                btnDelete.Attributes.Add("onclick", "if (confirmOneSelected('" + Resources.Global.WatchdogList + "', 'rbUserListID')) {return confirm(\"" + Resources.Global.ConfirmDeleteWatchdogGroups + "\");} else {return false;}");
            }
        }

        /// <summary>
        /// Check users page level authorization
        /// </summary>
        /// <returns></returns>
        override protected bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.WatchdogListsPage).HasPrivilege;
        }

        /// <summary>        
        /// Check users control/data level authorization
        /// </summary>
        /// <returns></returns>
        override protected bool IsAuthorizedForData()
        {
            // The lists displayed on this page will be limited to those created by the current 
            // user or public and associated with the the current user's enterprise.  This 
            // filter will be set on the SQL used to retrieve the user lists for this page.
            return true;
        }

        /// <summary>
        /// Populates the form controls.
        /// </summary>
        protected void PopulateForm()
        {
            PopulateUserListsAll(gvUserList);

            ApplySecurity(btnNew, SecurityMgr.Privilege.WatchdogListNew);
            ApplySecurity(btnDelete, SecurityMgr.Privilege.WatchdogListAdd);

            ApplyReadOnlyCheck(btnNew);
            ApplyReadOnlyCheck(btnDelete);
            ApplyReadOnlyCheck(btnEdit);

            //Defect 6769 - Enforce 5 watchdog groups for L200 STANDARD
            hidIsLumber_STANDARD.Value = _oUser.IsLumber_STANDARD().ToString();
            hidWatchdogGroupMax.Value = Configuration.WatchdogGroupsMax_L200.ToString(); //5
            hidWatchdogGroupCount.Value = _oUser.GetWatchdogCustomCount().ToString();
        }

        /// <summary>
        /// Helper method used by the GridView to populate the Last updated by 
        /// contents of the user list.
        /// </summary>
        /// <param name="iListID"></param>
        /// <returns></returns>
        protected string GetUserListLastUpdatedBy(int iListID)
        {
            StringBuilder sbList = new StringBuilder();

            // We want our own connection to avoid conflicts with
            // an open DataReader
            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            oDBAccess.Logger = _oLogger;

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prwuld_WebUserListID", iListID));

            string szSQL = GetObjectMgr().FormatSQL(SQL_GET_USER_LIST_UPDATEDBY, oParameters);
            using (IDataReader oReader = oDBAccess.ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null))
            {
                while (oReader.Read())
                {
                    sbList.Append(oReader.GetString(0));
                    sbList.Append("<br />");
                    sbList.Append(oReader.GetString(1));
                }
            }

            return sbList.ToString();
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
        }

        /// <summary>
        /// Handles the New Watchdog List on click event.  Takes the user to the UserListEdit.aspx
        /// page specifying an ID of 0 for a new list
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnNew_Click(object sender, EventArgs e)
        {
            Response.Redirect(PageConstants.Format(PageConstants.USER_LIST_EDIT, 0));
        }

        /// <summary>
        /// Handles the Edit user list on click event.  Takes the user to the UserListEdit.aspx page 
        /// specifying the selected list id.  Only lists owned by the current user can be edited.  
        /// In addition, connection lists cannot be edited.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnEdit_Click(object sender, EventArgs e)
        {
            bool bAuthorizedForEdit;

            // Retrieve the selected user list id
            int iUserListID = Convert.ToInt32(GetRequestParameter("rbUserListID", true));

            // Retrieve the additional data required to determine if the current user is 
            // authorized to edit this list.  
            bAuthorizedForEdit = IsAuthorizedForEdit(iUserListID);

            if (bAuthorizedForEdit)
            {
                GetUserListData(iUserListID);

                // Verify that this is not a connection list
                if (szListTypeCode != CODE_LIST_TYPE_CONNECTIONLIST)
                {
                    // Redirect the user to edit page
                    Response.Redirect(PageConstants.Format(PageConstants.USER_LIST_EDIT, GetRequestParameter("rbUserListID")));
                }
                else
                {
                    // Connection Lists cannot be edited from this page                    
                    AddUserMessage(Resources.Global.ErrorCannotEditConnectionList, true);
                }
            }
            else
            {
                // Display message that the current user is not authorized to edit the list
                AddUserMessage(Resources.Global.UnauthorizedForActionMsg, true);
            }
        }

        /// <summary>
        /// Handles the delete on click event.  If the delete has been confirmed, this method will delete
        /// the selected user list and refresh the page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnDelete_Click(object sender, EventArgs e)
        {
            bool bAuthorizedForDelete;

            // Retrieve the selected user list id
            int iUserListID = Convert.ToInt32(GetRequestParameter("rbUserListID", true));
            bAuthorizedForDelete = IsAuthorizedForDelete(iUserListID);

            if (bAuthorizedForDelete)
            {
                DeletePRWebUserList(iUserListID);

                // Refresh the user list page list
                Response.Redirect(PageConstants.BROWSE_COMPANIES);
            }
            else
            {
                // Display message that the current user is not authorized to delete the list
                AddUserMessage(Resources.Global.UnauthorizedForActionMsg, true);
            }
        }

        private const string SQL_GET_USER_LISTS_ALL =
            @"SELECT prwucl_WebUserListID, 
                     prwucl_Name, 
                     prwucl_Description,
                     prwucl_IsPrivate, 
                     prwucl_Pinned, 
                     prwucl_CategoryIcon,
					           prwucl_TypeCode,
                     MAX(prwucl_UpdatedDate) AS UpdatedDate, 
                     COUNT(prwuld_WebUserListDetailID) As CompanyCount 
                FROM PRWebUserList WITH (NOLOCK) 
                     LEFT OUTER JOIN PRWebUserListDetail WITH (NOLOCK) ON prwucl_WebUserListID = prwuld_WebUserListID AND prwuld_Deleted IS NULL 
                     LEFT OUTER JOIN Company WITH (NOLOCK) ON prwuld_AssociatedID = comp_CompanyID
                                                          AND comp_PRListingStatus IN ('L', 'H', 'N3', 'N5', 'N6', 'LUV') 
               WHERE ((prwucl_HQID = {0} AND prwucl_IsPrivate IS NULL) 
                      OR (prwucl_WebUserID={1} AND prwucl_IsPrivate = 'Y'))
                AND prwucl_Deleted IS NULL";

        private const string SQL_GROUP_BY = " GROUP BY prwucl_WebUserListID, prwucl_Name, prwucl_Description, prwucl_IsPrivate, prwucl_Pinned, prwucl_CategoryIcon, prwucl_TypeCode";
        private const string SQL_INITIAL_ORDER_BY = " ORDER BY CASE prwucl_TypeCode WHEN 'AUS' THEN 1 WHEN 'CL' THEN 2 ELSE 3 END, ";

        /// <summary>
        /// Populates the UserList section of the page.  This will include any lists created that do not 
        /// contain any companies.  This is to allow newly created lists to be edited to included companies
        /// selected via the search results.  
        /// 
        /// If the user does not have Level 3 member access, and custom lists will be excluded.
        /// </summary>
        protected void PopulateUserListsAll(GridView gvUserList)
        {
            ArrayList oParameters = new ArrayList();

            oParameters.Add(new ObjectParameter("prwucl_HQID", _oUser.prwu_HQID));
            oParameters.Add(new ObjectParameter("prwucl_WebUserID", _oUser.prwu_WebUserID));

            string[] aszKeyName = { "prwucl_WebUserListID" };

            string szSQL;

            // Level 3 access is required to view custom user lists
            if (_oUser.HasPrivilege(SecurityMgr.Privilege.WatchdogListAdd).HasPrivilege)
                szSQL = GetObjectMgr().FormatSQL(SQL_GET_USER_LISTS_ALL, oParameters);
            else
                szSQL = GetObjectMgr().FormatSQL(SQL_GET_USER_LISTS_ALL + SQL_EXCLUDE_CUSTOM_LISTS, oParameters);

            // Defect 7052 - L150 only get the Alerts List
            if(_oUser.prwu_AccessLevel == PRWebUser.SECURITY_LEVEL_BASIC_PLUS)
            {
                szSQL += " AND prwucl_TypeCode = 'AUS' ";
            }

            szSQL += SQL_GROUP_BY;
            szSQL += SQL_INITIAL_ORDER_BY + GetOrderByClause(gvUserList, false);

            //((EmptyGridView)gvUserList).EmptyTableRowText = GetNoResultsFoundMsg(Resources.Global.WatchdogLists);
            gvUserList.ShowHeaderWhenEmpty = true;
            gvUserList.EmptyDataText = GetNoResultsFoundMsg(Resources.Global.WatchdogLists);

            gvUserList.DataKeyNames = aszKeyName;
            gvUserList.DataSource = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            gvUserList.DataBind();
            EnableBootstrapFormatting(gvUserList);
        }

        private const string SQL_GET_USER_LIST_DATA =
            @"SELECT prwucl_TypeCode, prwucl_WebUserID, 
                     prwucl_IsPrivate, prwucl_HQID,
                     prwucl_Pinned, prwucl_CategoryIcon
                FROM PRWebUserList WITH (NOLOCK) 
               WHERE prwucl_WebUserListID = {0}";

        /// <summary>
        /// Helper method used to retrieve the additional data needed to validate whether or not 
        /// a user has access to edit the selected list.
        /// </summary>
        /// <param name="iListID"></param>
        private void GetUserListData(int iListID)
        {
            // We want our own connection to avoid conflicts with
            // an open DataReader
            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            oDBAccess.Logger = _oLogger;

            ArrayList oParameters = new ArrayList();

            oParameters.Add(new ObjectParameter("prwuld_WebUserListID", iListID));

            string szSQL = GetObjectMgr().FormatSQL(SQL_GET_USER_LIST_DATA, oParameters);
            IDataReader oReader = oDBAccess.ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            try
            {
                while (oReader.Read())
                {
                    szListTypeCode = oReader.GetString(0);
                    iOwnedByWebUserID = oReader.GetInt32(1);
                    bIsPrivate = GetObjectMgr().TranslateFromCRMBool(oReader[2]);
                    iListHQID = oReader.GetInt32(3);
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
    }
}
