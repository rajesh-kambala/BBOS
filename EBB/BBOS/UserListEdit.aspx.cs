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

 ClassName: UserListEdit
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
using TSI.DataAccess;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;
using TSI.Arch;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This page allows the user to edit the list details and remove companies.  This page will also
    /// be used to create new lists.
    /// 
    /// Any records selected to be "removed" should be deleted from the PRWebUserListDetail table.
    /// 
    /// Names for public lists must be unique within the user's company.  Names for private lists must be unique 
    /// for the user.
    /// </summary>
    public partial class UserListEdit : UserListBase
    {
        /// <summary>
        /// Calls page functions required to build and process this page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            // Retrieve the user list id (required for processing this page)
            hidUserListID.Value = GetRequestParameter("UserListID", false);

            // Set page title and add any additional javascript files required for processing
            // this page
            SetPageTitle(Resources.Global.WatchdogList, Resources.Global.Edit);
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_FUNCTIONS2_FILE));
            //Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_VALIDATION_FILE));

            EnableFormValidation();

            btnCancel.OnClientClick = "return DisableValidation();";

            if (!IsPostBack)
            {
                PopulateForm();
            }

            SetVisibility();
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
            return true;
        }

        /// <summary>
        /// Populates the form controls.
        /// </summary>
        protected void PopulateForm()
        {
            // If this is an existing user list, go retrieve the current list field values
            if (Convert.ToInt32(hidUserListID.Value) > 0)
            {
                GetUserListDetails();
                pnlRecordCnt.Visible = true;
            }
            else
                pnlRecordCnt.Visible = false;

            // If there are companies associated with this list, retrieve the companies and 
            // populate the associated companies data grid 
            if (!String.IsNullOrEmpty(hidCompanyIDs.Value))
            {
                PopulateCompanyList();
            }

            repIcon.DataSource = GetReferenceData("prwucl_CategoryIcon");
            repIcon.DataBind();

            PinAvailable.Value = "true";
            int pinnedCount = GetPinnedCount();
            if ((pinnedCount >= Utilities.GetIntConfigValue("UserListPinThreshold", 3)))
            {
                //cbPinned.Enabled = false;
                PinAvailable.Value = "false";
            }

            //litWhatIsPinned.Text = string.Format(litWhatIsPinned.Text, Utilities.GetIntConfigValue("UserListPinThreshold", 3));
        }

        /// <summary>
        /// Used to show/hide form elements based on the current page
        /// settings
        /// </summary>
        protected void SetVisibility()
        {
            // If the list type = AUS then disable the name, description, and private
            // controls
            if (hidListType.Value == CODE_LIST_TYPE_AUS)
            {
                txtListName.Enabled = false;
                txtListDescription.Enabled = false;
                chkIsPrivate.Enabled = false;
            }
        }

        /// <summary>
        /// Populates the Company list grid view control on the form
        /// </summary>
        protected void PopulateCompanyList()
        {
            string szListCompanyIDs = hidCompanyIDs.Value;

            if (string.IsNullOrEmpty(szListCompanyIDs))
            {
                return;
            }

            // Generate the sql required to retrieve the selected companies            
            object[] args = {_oUser.prwu_Culture,
                             _oUser.prwu_WebUserID,
                             _oUser.prwu_HQID,
                             szListCompanyIDs,
                             DateTime.Today.AddDays(0 - Configuration.ClaimActivityNewThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss"),
                             DateTime.Today.AddDays(0 - Configuration.ClaimActivityMeritoriousThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss"),
                             GetObjectMgr().GetLocalSourceCondition(),
                             GetObjectMgr().GetIntlTradeAssociationCondition()};
            string szSQL = string.Format(SQL_GET_SELECTED_COMPANIES, args);
            szSQL += GetOrderByClause(gvCompanyList);

            // Create empty grid view in case 0 results are found
            //((EmptyGridView)gvCompanyList).EmptyTableRowText = GetNoResultsFoundMsg(Resources.Global.Companies);
            gvCompanyList.ShowHeaderWhenEmpty = true;
            gvCompanyList.EmptyDataText = GetNoResultsFoundMsg(Resources.Global.Companies);

            // Execute search and bind results to grid
            gvCompanyList.DataSource = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection);
            gvCompanyList.DataBind();
            EnableBootstrapFormatting(gvCompanyList);

            OptimizeViewState(gvCompanyList);

            // Display the number of matching records found
            userListTableCard.Visible = true;
            lblRecordCount.Visible = true;
            lblRecordCount.Text = string.Format(Resources.Global.RecordCountFoundMsg, gvCompanyList.Rows.Count, Resources.Global.Companies);
        }

        private string _categoryIcon = string.Empty;

        /// <summary>
        /// Helper method used to retrieve the user list details displayed on the page as well as
        /// the list of current companies contained in the list.
        /// </summary>
        private void GetUserListDetails()
        {
            bool bRecordFound = false;

            ArrayList oParameters = new ArrayList();

            oParameters.Add(new ObjectParameter("prwucl_WebUserListID", hidUserListID.Value));
            oParameters.Add(new ObjectParameter("prwucl_WebUserID", _oUser.prwu_WebUserID));
            oParameters.Add(new ObjectParameter("prwucl_HQID", _oUser.prwu_HQID));

            // Level 3 access is required to edit custom lists
            string szSQL;
            if (_oUser.HasPrivilege(SecurityMgr.Privilege.WatchdogListAdd).HasPrivilege)
                szSQL = GetObjectMgr().FormatSQL(SQL_GET_WEB_USER_LIST_DATA, oParameters);
            else
                szSQL = GetObjectMgr().FormatSQL(SQL_GET_WEB_USER_LIST_DATA + SQL_EXCLUDE_CUSTOM_LISTS, oParameters);

            // Use our own DBAccess object to 
            // avoid conflicts with open readers.
            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            oDBAccess.Logger = _oLogger;

            using (IDataReader oReader = oDBAccess.ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null))
            {
                while (oReader.Read())
                {
                    bRecordFound = true;
                    txtListName.Text = GetDBAccess().GetString(oReader, "prwucl_Name");
                    txtListDescription.Text = GetDBAccess().GetString(oReader, "prwucl_Description");
                    chkIsPrivate.Checked = GetObjectMgr().TranslateFromCRMBool(GetDBAccess().GetString(oReader, "prwucl_IsPrivate"));
                    lblCreatedBy.Text = GetDBAccess().GetString(oReader, "CreatedBy");
                    lblCreatedByLocation.Text = GetDBAccess().GetString(oReader, "CreatedByLocation");
                    hidListType.Value = GetDBAccess().GetString(oReader, "prwucl_TypeCode");
                    //cbPinned.Checked = GetObjectMgr().TranslateFromCRMBool(GetDBAccess().GetString(oReader, "prwucl_Pinned"));

                    _categoryIcon = GetDBAccess().GetString(oReader, "prwucl_CategoryIcon");

                }
            }

            // If no record was found, then the user does not have authorized access to this record.
            // Throw authorization exception
            if (!bRecordFound)
                throw new AuthorizationException(Resources.Global.UnauthorizedForPageMsg);

            hidCompanyIDs.Value = GetUserListCompanyIDs(Convert.ToInt32(hidUserListID.Value));

            if (!chkIsPrivate.Checked)
            {
                chkIsPrivate.Enabled = false;
            }
        }

        protected string GetIconChecked(string icon)
        {
            if (_categoryIcon == icon)
            {
                return " checked ";
            }
            return string.Empty;
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
        /// Handles the Save on click event.  If this is a new list, takes the user to the UserListList.aspx
        /// page, otherwise the UserList.aspx page.  Any record checked in the "Remove" section will
        /// be deleted from the PRWebUserListDetail table.  Names for public lists must be unique within the
        /// user's company.  Names for private lists must be unique for the user.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnSave_Click(object sender, EventArgs e)
        {
            bool bAddNew = false;

            oTran = GetObjectMgr().BeginTransaction();
            try
            {
                // If this is a new PRWebUserList, add it
                if (Convert.ToInt32(hidUserListID.Value) == 0)
                {
                    // Verify list name - Names for public lists must be unique within the user's company.
                    // Names for private lists must be unique for the user.
                    if (!IsListNameUnique(txtListName.Text, chkIsPrivate.Checked))
                    {
                        AddUserMessage(Resources.Global.ErrorInvalidListName);
                        PopulateCompanyList();
                        return;
                    }

                    AddPRWebUserList(txtListName.Text, txtListDescription.Text, chkIsPrivate.Checked, false, GetRequestParameter("rbIcon", false), oTran);
                    bAddNew = true;
                }
                else
                {
                    // Update the existing record 
                    UpdatePRWebUserList(Convert.ToInt32(hidUserListID.Value), txtListName.Text, txtListDescription.Text, chkIsPrivate.Checked, false, GetRequestParameter("rbIcon", false));

                    // Delete any PRWebUserDetail records for those companies checked "Remove"
                    string szCompaniesToRemove = GetRequestParameter("cbCompanyID", false);
                    if (!String.IsNullOrEmpty(szCompaniesToRemove))
                    {
                        string[] aszCompaniesToRemove = szCompaniesToRemove.Split(new char[] { ',' });

                        foreach (string szCompanyID in aszCompaniesToRemove)
                        {
                            if (!String.IsNullOrEmpty(szCompanyID))
                            {
                                // Remove PRWebUserDetail Record
                                DeletePRWebUserListDetail(Convert.ToInt32(hidUserListID.Value), Convert.ToInt32(szCompanyID));
                            }
                        }
                    }
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

            if (bAddNew)
                Response.Redirect(GetReturnURL(PageConstants.BROWSE_COMPANIES));
            else
                Response.Redirect(PageConstants.Format(PageConstants.USER_LIST, hidUserListID.Value));
        }

        /// <summary>
        /// Handles the Cancel on click event.  If this is a new list, takes the user to the UserListList.aspx
        /// page, otherwise takes the user to the UserList.aspx page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnCancel_Click(object sender, EventArgs e)
        {
            if (Convert.ToInt32(hidUserListID.Value) == 0)
                Response.Redirect(GetReturnURL(PageConstants.BROWSE_COMPANIES));
            else
                Response.Redirect(PageConstants.Format(PageConstants.USER_LIST, hidUserListID.Value));
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
            _lSelectedIDs = new List<string>();

            string szSelectedIDs = GetRequestParameter("cbCompanyID", false);
            if (!String.IsNullOrEmpty(szSelectedIDs))
            {
                string[] aszIDs = szSelectedIDs.Split(',');
                _lSelectedIDs.AddRange(aszIDs);
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

        protected int GetPinnedCount()
        {
            IList parmList = new ArrayList();
            parmList.Add(new ObjectParameter("HQID", _oUser.prwu_HQID));
            return (int)GetDBAccess().ExecuteScalar("SELECT COUNT(1) FROM PRWebUserList WTIH (NOLOCK) WHERE prwucl_HQID = @HQID AND prwucl_Pinned='Y'", parmList);
        }
    }
}
