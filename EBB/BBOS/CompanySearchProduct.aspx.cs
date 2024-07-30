/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2009-2017

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CompanySearchProduct
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data;
using PRCo.EBB.Util;
using PRCo.EBB.BusinessObjects;

namespace PRCo.BBOS.UI.Web
{
    public partial class CompanySearchProduct : CompanySearchBase
    {
        /// <summary>
        /// Calls page functions required to build and process this page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            // Set page title, sub-title
            SetPageTitle(Resources.Global.CompanySearch, Resources.Global.ProductCriteria);

            // Add company submenu to this page
            SetSubmenu("btnProduct");

            if (!IsPostBack)
            {
                LoadLookupValues();
                PopulateForm();
            }
            else
            {
                StoreCriteria();
            }

            // Set Search Criteria User Control
            ucCompanySearchCriteriaControl.CompanySearchCriteria = _oCompanySearchCriteria;
        }

        /// <summary>
        /// Loads all of the databound controls setting 
        /// their default values.
        /// </summary>
        protected void LoadLookupValues()
        {
            // Bind Search Type control
            List<ICustom_Caption> lSearchType = GetSearchTypeList(Resources.Global.ProductSearchTypeAny, Resources.Global.ProductSearchTypeAll);
            BindLookupValues(rblSearchType, lSearchType, CODE_SEARCH_TYPE_ANY);
        }

        protected void PopulateForm()
        {
            DataTable dtProductProvided = GetProductProvidedList();

            cblProductProvided.DataTextField = "prprpr_Name";
            cblProductProvided.DataValueField = "prprpr_ProductProvidedID";
            cblProductProvided.DataSource = dtProductProvided;
            cblProductProvided.DataBind();

            SetListValue(rblSearchType, _oCompanySearchCriteria.ProductProvidedSearchType);
            SetListValues(cblProductProvided, _oCompanySearchCriteria.ProductProvidedIDs);

            ApplyReadOnlyCheck(btnSaveSearch);
        }

        /// <summary>
        /// Collects and stores the search criteria on the users current company search
        /// criteria object 
        /// </summary>
        protected override void StoreCriteria()
        {
            _oCompanySearchCriteria.ProductProvidedSearchType = rblSearchType.SelectedValue;
            _oCompanySearchCriteria.ProductProvidedIDs = GetSelectedValues(cblProductProvided);
            base.StoreCriteria();
        }

        /// <summary>
        /// Clears and stores the search criteria on the users current company search
        /// criteria object 
        /// </summary>
        protected override void ClearCriteria()
        {
            rblSearchType.SelectedIndex = -1;
            cblProductProvided.SelectedIndex = -1;

            _szRedirectURL = PageConstants.COMPANY_SEARCH_PRODUCT;
        }

        /// <summary>
        /// Check users page level authorization
        /// </summary>
        /// <returns></returns>
        override protected bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.CompanySearchProductsPage).HasPrivilege;
        }

        protected override bool IsAuthorizedForData()
        {
            return true;
        }
    }
}
