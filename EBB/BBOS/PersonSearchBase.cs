/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2017

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: PersonSearchBase
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/

using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;

using PRCo.EBB.BusinessObjects;
using TSI.Arch;

namespace PRCo.BBOS.UI.Web
{
    public class PersonSearchBase : SearchBase
    {
        protected PersonSearchCriteria _oPersonSearchCriteria;
        protected bool bCurrentUserOwnsSearch = false;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            EnableFormValidation();

            if (!String.IsNullOrEmpty(Request["SearchID"]))
                Int32.TryParse(GetRequestParameter("SearchID"), out _iSearchID);
            else
                _iSearchID = 0;

            RetrieveObject();

            // Determine if are you sure confirmation messages should be displayed
            if (_bIsDirty)
            {
                ClientScript.RegisterClientScriptBlock(Page.GetType(), "script1", "var bDisplayConfirmations = true;", true);
            }
            else
            {
                ClientScript.RegisterClientScriptBlock(Page.GetType(), "script1", "var bDisplayConfirmations = false;", true);
            }

            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_FUNCTIONS2_FILE));
        }

        /// <summary>
        /// Retrieves the current person search criteria object from
        /// the current users web user search criteria object
        /// </summary>
        protected void RetrieveObject()
        {
            // Check for an existing Person Search Criteria Object
            IPRWebUserSearchCriteria oWebUserSearchCriteria = GetSearchCritieria(_iSearchID, PRWebUserSearchCriteria.SEARCH_TYPE_PERSON);
            _oPersonSearchCriteria = (PersonSearchCriteria)oWebUserSearchCriteria.Criteria;

            _bIsDirty = _oPersonSearchCriteria.IsDirty;

            // Check if this is an unsaved search or new search
            if (_iSearchID == 0
                && oWebUserSearchCriteria.prsc_WebUserID == _oUser.prwu_WebUserID)
            {
                bCurrentUserOwnsSearch = true;
            }

            // Determine if the current user is the search owner
            if (oWebUserSearchCriteria.prsc_WebUserID == _oUser.prwu_WebUserID &&
                oWebUserSearchCriteria.prsc_IsPrivate)
            {
                // Current user is search owner
                bCurrentUserOwnsSearch = true;
            }
            else
            {
                // If the current user is not the search owner, and if this is not a public search
                // for the current user's enterprise, then the user is not authorized to view this search
                if (!(oWebUserSearchCriteria.prsc_HQID == _oUser.prwu_HQID &&
                    !oWebUserSearchCriteria.prsc_IsPrivate))
                    throw new AuthorizationException(Resources.Global.UnauthorizedForSearchMsg);
            }
        }

        protected virtual void StoreCriteria()
        {
            IPRWebUserSearchCriteria oWebUserSearchCriteria = GetSearchCritieria(_iSearchID, PRWebUserSearchCriteria.SEARCH_TYPE_PERSON);
            oWebUserSearchCriteria.Criteria = _oPersonSearchCriteria;
        }

        /// <summary>
        /// Restores the updated company search criteria object with
        /// the corresponding values cleared.  Subpages should handle clearing 
        /// corresponding form values and updating person search criteria 
        /// object accordingly
        /// </summary>
        protected virtual void ClearCriteria()
        {
            // Store updated company search criteria object
            StoreCriteria();
        }

        /// <summary>
        /// Handles the Search on click event for each of the person search pages
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            StoreCriteria();
            Response.Redirect(PageConstants.Format(PageConstants.PERSON_SEARCH_RESULTS, _iSearchID));
        }

        /// <summary>
        /// Handles the Clear All Criteria on click event for each of the person
        /// search pages
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnClearAllCriteria_Click(object sender, EventArgs e)
        {
            // Clear this search criteria object
            Session["oWebUserSearchCriteria"] = null;
            Response.Redirect(PageConstants.PERSON_SEARCH);
        }

        /// <summary>
        /// Handles the Clear This Criteria on click event for each of the person 
        /// search pages
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnClearCriteria_Click(object sender, EventArgs e)
        {
            // Reset current form only 
            ClearCriteria();

            // Store reset values on search criteria object
            StoreCriteria();

            // Reload Current page 
            // NOTE: This is required to correctly refresh search criteria panel.
            Response.Redirect(_szRedirectURL);
        }

        /// <summary>
        /// Handles the Save Search Criteria on click event for each of the company
        /// search pages
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnSaveSearch_Click(object sender, EventArgs e)
        {
            // Save the search criteria object 
            StoreCriteria();

            // Redirect the user to the Search Edit page
            Response.Redirect(PageConstants.Format(PageConstants.SEARCH_EDIT, _iSearchID, PRWebUserSearchCriteria.SEARCH_TYPE_PERSON));
        }

        /// <summary>
        /// Handles the Load Search Criteria on click event for each of the company 
        /// search pages
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnLoadSearch_Click(object sender, EventArgs e)
        {
            Response.Redirect(PageConstants.SAVED_SEARCHES);
        }

        /// <summary>
        /// Sets the submenu items for the Person search pages
        /// </summary>
        protected void SetSubmenu(string strDefaultID)
        {
            List<SubMenuItem> oMenuItems = new List<SubMenuItem>();

            AddSubmenuItemButton(oMenuItems, Resources.Global.Person, "btnPerson", SecurityMgr.Privilege.PersonSearchPage);
            AddSubmenuItemButton(oMenuItems, Resources.Global.Location, "btnLocation", SecurityMgr.Privilege.PersonSearchLocationPage);
            AddSubmenuItemButton(oMenuItems, Resources.Global.CustomFilters, "btnCustom", SecurityMgr.Privilege.PersonSearchLocationPage);

            SubMenuBar oSubMenuBar = (SubMenuBar)Master.FindControl("SubmenuBar");
            oSubMenuBar.MenuItemEvent += new EventHandler(oSubMenuBar_MenuItemEvent);
            oSubMenuBar.LoadMenuButtons(oMenuItems, strDefaultID);
        }

        /// <summary>
        /// Handles the on click event for each of the submenu items.  The
        /// current person search criteria object will be stored and the 
        /// user will be redirected accordingly.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void oSubMenuBar_MenuItemEvent(object sender, EventArgs e)
        {
            // If we are currently working with a specified search id, 
            // create a querystring to pass this along
            string szQueryString = "";

            if (!String.IsNullOrEmpty(Request.QueryString.ToString()))
                szQueryString = "?" + Request.QueryString.ToString();

            // Store search criteria
            StoreCriteria();

            switch (((WebControl)sender).ID)
            {
                case "btnPerson":
                    Response.Redirect(PageConstants.PERSON_SEARCH + szQueryString);
                    break;
                case "btnLocation":
                    Response.Redirect(PageConstants.PERSON_SEARCH_LOCATION + szQueryString);
                    break;
                case "btnCustom":
                    Response.Redirect(PageConstants.PERSON_SEARCH_CUSTOM + szQueryString);
                    break;
            }
        }

        /// <summary>
        /// Check users page level authorization        
        /// </summary>
        /// <returns></returns>
        override protected bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.PersonSearchPage).HasPrivilege;
        }

        /// <summary>        
        /// Check users control/data level authorization        
        /// </summary>
        /// <returns></returns>
        protected override bool IsAuthorizedForData()
        {
            // NOTE: The current user must be the search owner, or the search must be public
            // and belong to the current user's enterprise.  These checks are done after the corresponding
            // search object has been retrieved.           
            return true;
        }
    }
}