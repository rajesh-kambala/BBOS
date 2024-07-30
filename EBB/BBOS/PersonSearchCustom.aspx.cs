/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2012-2018

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: PersonSearchCustom
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/

using System;
using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.WebControls;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

using PRCo.EBB.BusinessObjects;

namespace PRCo.BBOS.UI.Web
{
    public partial class PersonSearchCustom : PersonSearchBase
    {
        private bool bResetUserList = false;

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
            SetPageTitle(Resources.Global.PeopleSearch, Resources.Global.CustomFilters);
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_TOGGLE_FUNCTIONS_FILE));
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_FUNCTIONS2_FILE));

            // Add company submenu to this page
            SetSubmenu("btnCustom");

            if (!IsPostBack)
            {
                PopulateForm();

                bResetUserList = true;
            }

            // Make sure we have the latest search object updated before setting 
            // the search criteria control

            StoreCriteria();
            ucPersonSearchCriteriaControl.PersonSearchCriteria = _oPersonSearchCriteria;
        }

        /// <summary>
        /// Check users page level authorization
        /// </summary>
        /// <returns></returns>
        override protected bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.PersonSearchCustomPage).HasPrivilege;
        }

        /// <summary>
        /// Check users control/data level authorization
        /// </summary>
        /// <returns></returns>
        protected override bool IsAuthorizedForData()
        {
            // Notes
            List<Control> lHasNotesControls = new List<Control>();
            lHasNotesControls.Add(lblHasNotes);
            lHasNotesControls.Add(chkCompanyHasNotes);
            ApplySecurity(lHasNotesControls, SecurityMgr.Privilege.PersonSearchByNotes);

            // Watchdog list
            List<Control> lWatchdogControls = new List<Control>();
            lWatchdogControls.Add(pnlWatchdogList);
            ApplySecurity(lWatchdogControls, SecurityMgr.Privilege.PersonSearchByWatchdogList);

            // Save Search Criteria requires Level 3 access
            List<Control> lSaveSearchControls = new List<Control>();
            lSaveSearchControls.Add(btnSaveSearch);
            lSaveSearchControls.Add(btnLoadSearch);
            ApplySecurity(lSaveSearchControls, SecurityMgr.Privilege.SaveSearches);

            return true;
        }

        /// <summary>
        /// Set page to auto-generate javascript variables for form elements.
        /// This is required for the [must have] checkboxes on the fax and email
        /// form items.
        /// </summary>
        /// <returns></returns>
        public override bool EnableJSClientIDTranslation()
        {
            return true;
        }

        /// <summary>
        /// Populates the form controls.
        /// </summary>
        protected void PopulateForm()
        {
            // Custom Identifier
            chkCompanyHasNotes.Checked = _oPersonSearchCriteria.HasNotes;

            // Watchdog Lists
            PopulateUserLists(gvUserList);
        }

        /// <summary>
        /// Collects and stores the search criteria on the users current company search
        /// criteria object 
        /// </summary>
        protected override void StoreCriteria()
        {
            _oPersonSearchCriteria.HasNotes = chkCompanyHasNotes.Checked;

            // Store User List selections
            if (!bResetUserList)
            {
                _oPersonSearchCriteria.UserListIDs = GetRequestParameter("cbUserListID", false);
            }

            base.StoreCriteria();
        }

        /// <summary>
        /// Clears and stores the search criteria on the users current company search
        /// criteria object 
        /// </summary>
        protected override void ClearCriteria()
        {
            // Has Notes
            chkCompanyHasNotes.Checked = false;

            // Clear User List selections
            bResetUserList = true;
            _oPersonSearchCriteria.UserListIDs = "";

            _szRedirectURL = PageConstants.PERSON_SEARCH_CUSTOM;
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

                if (_oPersonSearchCriteria != null)
                {
                    if (!string.IsNullOrEmpty(_oPersonSearchCriteria.UserListIDs))
                    {
                        string[] aszIDs = _oPersonSearchCriteria.UserListIDs.Split(',');
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
        /// Helper method that helps with bi-directional sorting
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void UserListGridView_Sorting(Object sender, GridViewSortEventArgs e)
        {
            SetSortingAttributes((GridView)sender, e);

            _oPersonSearchCriteria.UserListIDs = GetRequestParameter("cbUserListID", false);
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
    }
}