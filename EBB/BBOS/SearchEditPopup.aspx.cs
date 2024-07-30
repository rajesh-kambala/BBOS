/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2018

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: SearchEditPopup.aspx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/

using System;
using PRCo.EBB.BusinessObjects;
using TSI.Arch;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This page allows search meta data to be saved.  The form will be populated based on the current search
    /// data.  If this is a new saved search, a record will be created.  Otherwise the current record will be
    /// updated.  
    /// 
    /// Only the current search owner can edit the saved search information.
    /// </summary>
    public partial class SearchEditPopup : PageBase
    {
        private string szSearchType;
        private int iSearchID;
        private IPRWebUserSearchCriteria oWebUserSearchCriteria;

        /// <summary>
        /// Calls page functions required to build and process this page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            // Set page title
            SetPageTitle(Resources.Global.SaveSearchCriteria);

            EnableFormValidation();
            btnCancel.OnClientClick = "bEnableValidation=false;";
            btnSave.OnClientClick = "bEnableValidation=true;";

            // Retrieve Search Type and ID
            szSearchType = GetRequestParameter("Type", true);
            iSearchID = Convert.ToInt32(GetRequestParameter("SearchID", true));

            RetrieveObject();

            if (!IsPostBack)
            {
                PopulateForm();
            }
        }

        /// <summary>
        /// Check users page level authorization        
        /// </summary>
        /// <returns></returns>
        override protected bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.SaveSearches).HasPrivilege;
        }

        /// <summary>        
        /// Check users control/data level authorization        
        /// </summary>
        /// <returns></returns>
        protected override bool IsAuthorizedForData()
        {
            // NOTE: Only searches owned by the current user can be edited.  This check 
            // will be done after the search object is retrieved.
            return true;
        }

        /// <summary>
        /// Retrieves the current users web user search criteria object
        /// </summary>
        protected void RetrieveObject()
        {
            // Retrieve the Web User Search Criteria Object
            oWebUserSearchCriteria = GetSearchCritieria(iSearchID, szSearchType, false);
            if (oWebUserSearchCriteria == null)
            {
                throw new ApplicationUnexpectedException("Search Criteria Not Found: " + iSearchID.ToString() + ", " + szSearchType);
            }

            bool bAuthorizedToEdit = false;

            // Determine if the current user is authorized to edit this search
            if (oWebUserSearchCriteria.prsc_IsPrivate)
            {
                // Private Search, user must be the search owner to edit
                if (oWebUserSearchCriteria.prsc_WebUserID == _oUser.prwu_WebUserID)
                    bAuthorizedToEdit = true;
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
                throw new AuthorizationException(Resources.Global.SavedSearchEditError);
            }
        }

        /// <summary>
        /// Populates the form controls.
        /// </summary>
        protected void PopulateForm()
        {
            txtSearchName.Text = oWebUserSearchCriteria.prsc_Name;
            chkPrivate.Checked = oWebUserSearchCriteria.prsc_IsPrivate;

            if ((oWebUserSearchCriteria.IsInDB) &&
                (!oWebUserSearchCriteria.prsc_IsPrivate))
            {
                chkPrivate.Enabled = false;
            }

            //lblSearchType.Text = GetReferenceValue("prsc_SearchType", szSearchType);

            switch(Request["Return"])
            {
                case "sl":
                    returnURL.Value = PageConstants.SAVED_SEARCHES;
                    break;
                default:
                    returnURL.Value = PageConstants.SAVED_SEARCHES;
                    break;
            }
        }

        /// <summary>
        /// Handles the Save on click event.  Saved the current record and takes the user to the
        /// Search Listing page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnSave_Click(object sender, EventArgs e)
        {
            // Save the record
            oWebUserSearchCriteria.prsc_Name = txtSearchName.Text;
            oWebUserSearchCriteria.prsc_IsPrivate = chkPrivate.Checked;
            oWebUserSearchCriteria.prsc_IsLastUnsavedSearch = false;

            oWebUserSearchCriteria.prsc_CompanyID = _oUser.prwu_BBID;
            oWebUserSearchCriteria.prsc_WebUserID = _oUser.prwu_WebUserID;

            oWebUserSearchCriteria.Save();
            oWebUserSearchCriteria.Criteria.IsDirty = false;

            // Take the user to the Saved search listing page
            //Response.Redirect(PageConstants.SAVED_SEARCHES);
            Close();
        }

        /// <summary>
        /// Handles the cancel on click event.  Takes the user to the search listing page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnCancel_Click(object sender, EventArgs e)
        {
            // Take the user to the saved search listing page
            //Response.Redirect(PageConstants.SAVED_SEARCHES);
            Close();
        }

        protected void Close()
        {
            ClientScript.RegisterStartupScript(this.GetType(), "close", "closeReload() ", true);
        }
    }
}
