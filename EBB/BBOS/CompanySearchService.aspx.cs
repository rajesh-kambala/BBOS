/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2009-2018

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CompanySearchService
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;

using PRCo.EBB.BusinessObjects;
using PRCo.EBB.Util;
using PRCo.BBOS.UI.Web.UserControls;

using TSI.Utils;

namespace PRCo.BBOS.UI.Web
{
    public partial class CompanySearchService : CompanySearchBase
    {
        /// <summary>
        /// Initialize the page controls.  All dynamic page controls
        /// must be pre-built in order for viewstate to be set correctly on 
        /// page load
        /// </summary>
        /// <param name="e"></param>
        override protected void OnInit(EventArgs e)
        {
            base.OnInit(e);

            List<CheckBoxGroup> lstCBG = BuildTable_Bootstrap(phServiceProvided, 
                    GetServiceProvidedList().Select("1=1", "prserpr_DisplayOrder ASC"), 
                    "prserpr_Level",
                    "prserpr_ServiceProvidedID", 
                    "prserpr_Name", 
                    "prserpr_CompanyCount",
                    Utilities.GetBoolConfigValue("ServiceProvidedCountEnabled", false));

            foreach(CheckBoxGroup oCBG in lstCBG)
            {
                CheckBoxPanel ucCheckBoxPanel = (CheckBoxPanel)LoadControl("~/UserControls/CheckBoxPanel.ascx");
                ucCheckBoxPanel.ID = "ucCheckBoxPanel_" + oCBG.root.id;
                ucCheckBoxPanel.PanelID = oCBG.root.id;
                ucCheckBoxPanel.CheckBoxChanged += new EventHandler(oCheckbox_CheckChanged);

                ucCheckBoxPanel.CBG = oCBG;

                phServiceProvided.Controls.Add(ucCheckBoxPanel);
            }
        }

        /// <summary>
        /// Calls page functions required to build and process this page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            // Set page title, sub-title
            SetPageTitle(Resources.Global.CompanySearch, Resources.Global.ServiceCriteria);

            // Add company submenu to this page
            SetSubmenu("btnService");
            SetPopover();

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

        protected void SetPopover()
        {
            //popIndustryType.Attributes.Add("data-bs-title", Resources.Global.IndustryTypeText);
        }

        /// <summary>
        /// Loads all of the databound controls setting 
        /// their default values.
        /// </summary>
        protected void LoadLookupValues()
        {
            List<ICustom_Caption> lSearchType = GetSearchTypeList(Resources.Global.ServiceSearchTypeAny, Resources.Global.ServiceSearchTypeAll);
            BindLookupValues(rblSearchType, lSearchType, CODE_SEARCH_TYPE_ANY);
        }

        protected void PopulateForm()
        {
            string[] aszIDs = UIUtils.GetString(_oCompanySearchCriteria.ServiceProvidedIDs).Split(CompanySearchBase.achDelimiter);

            //SetTableValues(aszIDs, tblServiceProvided, PREFIX_CLASS);
            SetTableValues_Bootstrap(aszIDs, phServiceProvided, PREFIX_CLASS);

            SetListValue(rblSearchType, _oCompanySearchCriteria.ServiceProvidedSearchType);

            ApplyReadOnlyCheck(btnSaveSearch);
        }

        /// <summary>
        /// Collects and stores the search criteria on the users current company search
        /// criteria object 
        /// </summary>
        protected override void StoreCriteria()
        {
            _oCompanySearchCriteria.ServiceProvidedSearchType = rblSearchType.SelectedValue;
            //_oCompanySearchCriteria.ServiceProvidedIDs = GetTableValues(tblServiceProvided, PREFIX_CLASS);
            _oCompanySearchCriteria.ServiceProvidedIDs = GetCheckboxValues_Bootstrap(phServiceProvided, PREFIX_CLASS);
            base.StoreCriteria();
        }

        /// <summary>
        /// Clears and stores the search criteria on the users current company search
        /// criteria object 
        /// </summary>
        protected override void ClearCriteria()
        {
            rblSearchType.SelectedIndex = -1;
            ClearTableValues_AllCheckboxes(phServiceProvided);
            _szRedirectURL = PageConstants.COMPANY_SEARCH_SERVICE;
        }

        /// <summary>
        /// Process on check changed events for checkboxes in the table.
        /// If the level 1 item is selected, all children should be disabled 
        /// and included in the search.  Reset the table values, store updated criteria, and 
        /// refresh page to update the search criteria user control.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        override protected void oCheckbox_CheckChanged(object sender, EventArgs e)
        {
            string[] aszIDs = UIUtils.GetString(_oCompanySearchCriteria.ServiceProvidedIDs).Split(achDelimiter);
            //SetTableValues(aszIDs, tblServiceProvided, PREFIX_CLASS);
            SetTableValues_Bootstrap(aszIDs, phServiceProvided, PREFIX_CLASS);

            // Store search criteria and refresh page
            StoreCriteria();
            //Response.Redirect(PageConstants.COMPANY_SEARCH_SERVICE);
        }

        /// <summary>
        /// Check users page level authorization
        /// </summary>
        /// <returns></returns>
        override protected bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.CompanySearchServicesPage).HasPrivilege;
        }

        protected override bool IsAuthorizedForData()
        {
            return true;
        }
    }
}
