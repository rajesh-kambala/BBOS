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

 ClassName: CompanySearch
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/

using System;
using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This page contains the general search fields for searching companies
    /// including the company name, bb #, type, listing status, company phone, company fax, 
    /// company email, and new listings.
    /// </summary>
    public partial class CompanySearch : CompanySearchBase
    {
        private const string REF_DATA_COMPANY_TYPE = "Comp_PRType";
        private const string REF_DATA_NEW_LISTINGS_ONLY = "NewListingDaysOld";

        /// <summary>
        /// Calls page functions required to build and process this page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            // Set page title, sub-title
            SetPageTitle(Resources.Global.CompanySearch, Resources.Global.CompanyCriteria);

            // Add company submenu to this page
            SetSubmenu("btnCompany");
           
            if (!IsPostBack)
            {
                LoadLookupValues();

                PopulateForm();                

                // Add toggle functions 
                chkFaxNotNull.Attributes.Add("onclick", "ToggleMustHave(this, 'Fax');");
                chkEmailNotNull.Attributes.Add("onclick", "ToggleMustHave(this, 'Email');");
                chkNewListingsOnly.Attributes.Add("onclick", "ToggleNewListing(this);");
            }

            // Make sure we have the latest search object updated before setting 
            // the search criteria control
            StoreCriteria();

            // Set Search Criteria User Control
            ucCompanySearchCriteriaControl.CompanySearchCriteria = _oCompanySearchCriteria;

            // See issue #54.  Hiding it from the user for now.
            // We should probably remove the code at some point but
            // restoring it would be a pain so let's make sure this
            // is want we want to do first.
            btnNewSearch.Visible = false;          
        }

        /// <summary>
        /// Check users page level authorization
        /// </summary>
        /// <returns></returns>
        override protected bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.CompanySearchPage).HasPrivilege;
        }

        /// <summary>        
        /// Check users control/data level authorization
        /// </summary>
        /// <returns></returns>
        protected override bool IsAuthorizedForData()
        {
            // Listing Status security
			List<Control> lListingStatusControls = new List<Control>();
			lListingStatusControls.Add(lblListingStatus);
            lListingStatusControls.Add(ddlListingStatus);
            ApplySecurity(lListingStatusControls, SecurityMgr.Privilege.CompanySearchByListingStatus);

            // New Listings security
			List<Control> lNewListingControls = new List<Control>();
			lNewListingControls.Add(lblNewListingsOnly);
            lNewListingControls.Add(chkNewListingsOnly);
            lNewListingControls.Add(lblListedInPast);
            lNewListingControls.Add(ddlNewListingRange);
            ApplySecurity(lNewListingControls, SecurityMgr.Privilege.CompanySearchByNewListings);

            // Save Search Criteria security
			List<Control> lSaveSearchControls = new List<Control>();
			lSaveSearchControls.Add(btnSaveSearch);
            lSaveSearchControls.Add(btnLoadSearch);
            ApplySecurity(lSaveSearchControls, SecurityMgr.Privilege.SaveSearches);
            ApplyReadOnlyCheck(btnSaveSearch);

			// Phone security
			List<Control> lPhoneControls = new List<Control>();
			lPhoneControls.Add(lblPhone);
			lPhoneControls.Add(txtPhoneAreaCode);
			lPhoneControls.Add(txtPhone);
            lPhoneControls.Add(lblFax);
            lPhoneControls.Add(txtFaxAreaCode);
            lPhoneControls.Add(txtFaxNumber);
            ApplySecurity(lPhoneControls, SecurityMgr.Privilege.CompanySearchByPhoneFaxNumber);

			List<Control> lFaxControls = new List<Control>();
			lFaxControls.Add(chkFaxNotNull);
			lFaxControls.Add(lblMustHaveFax);
            ApplySecurity(lFaxControls, SecurityMgr.Privilege.CompanySearchByHasFax);
            hdnFaxSecurityEnabled.Value = (_oUser.HasPrivilege(SecurityMgr.Privilege.CompanySearchByHasFax).HasPrivilege ? 1 : 0).ToString();

			// Email security
			List<Control> lEmailControls = new List<Control>();
			lEmailControls.Add(lblEmail);
			lEmailControls.Add(txtEmail);
            ApplySecurity(lEmailControls, SecurityMgr.Privilege.CompanySearchByEmail);


            lEmailControls.Clear();
			lEmailControls.Add(chkEmailNotNull);
			lEmailControls.Add(lblMustHaveEmail);
            ApplySecurity(lEmailControls, SecurityMgr.Privilege.CompanySearchByHasEmail);
            hdnEmailSecurityEnabled.Value = (_oUser.HasPrivilege(SecurityMgr.Privilege.CompanySearchByHasEmail).HasPrivilege ? 1 : 0).ToString();

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
        /// Loads all of the databound controls setting 
        /// thier default values.
        /// </summary>
        protected void LoadLookupValues()
        {
            // Bind Company Type drop-down
            // NOTE: Add "Any" option
            BindLookupValues(ddlCompanyType, GetReferenceData(REF_DATA_COMPANY_TYPE));
            ListItem oItem = new ListItem(Resources.Global.SelectAny, "");
            ddlCompanyType.Items.Insert(0, oItem);

            if (IsPRCoUser())
            {
                BindLookupValues(ddlListingStatus, GetReferenceData("BBOSListingStatusSearchBBSi"));
            }
            else
            {
                BindLookupValues(ddlListingStatus, GetReferenceData("BBOSListingStatusSearch"));
            }
            
            // Bind New Listings Days Old drop-down
            BindLookupValues(ddlNewListingRange, GetReferenceData(REF_DATA_NEW_LISTINGS_ONLY));

            // Bind Industry Type control
            BindLookupValues(rblIndustryType, GetReferenceData(REF_DATA_INDUSTRY_TYPE));
            ModifyIndustryType(rblIndustryType);
        }

        /// <summary>
        /// Populates the form controls.
        /// </summary>
        protected void PopulateForm()
        {
            // Set Company Search Information
            // Industry Type 
            SetListDefaultValue(rblIndustryType, _oCompanySearchCriteria.IndustryType);

            ApplySecurity(pnlIndustryType, SecurityMgr.Privilege.CompanySearchByIndustry);
            //if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER) {
            //    pnlIndustryType.Visible = false;
            //}

            // Company Name
            txtCompanyName.Text = _oCompanySearchCriteria.CompanyName;
            
            // BB #
            //txtBBNum.Text = UIUtils.GetStringFromInt(_oCompanySearchCriteria.BBID, true);

            // Company Type
            foreach(ListItem oItem in ddlCompanyType.Items)
            {
                if(oItem.Value == _oCompanySearchCriteria.CompanyType)
                    oItem.Selected = true;
            }            

            // Listing Status
            foreach(ListItem oItem in ddlListingStatus.Items)
            {
                if(oItem.Value == _oCompanySearchCriteria.ListingStatus)
                    oItem.Selected = true;
            }            

            // Company Phone
            txtPhoneAreaCode.Text = _oCompanySearchCriteria.PhoneAreaCode;
            txtPhone.Text = _oCompanySearchCriteria.PhoneNumber;            

            // Company Fax
            txtFaxAreaCode.Text = _oCompanySearchCriteria.FaxAreaCode;
            txtFaxNumber.Text = _oCompanySearchCriteria.FaxNumber;
            chkFaxNotNull.Checked = _oCompanySearchCriteria.FaxNotNull;

            // Company Email
            txtEmail.Text = _oCompanySearchCriteria.Email;
            chkEmailNotNull.Checked = _oCompanySearchCriteria.EmailNotNull;

            // New Listings Only
            chkNewListingsOnly.Checked = _oCompanySearchCriteria.NewListingOnly;
            foreach(ListItem oItem in ddlNewListingRange.Items)
            {
                if (Convert.ToInt32(oItem.Value) == _oCompanySearchCriteria.NewListingDaysOld)
                    oItem.Selected = true;
            }            
        }

        /// <summary>
        /// Collects and stores the search criteria on the users current company search
        /// criteria object 
        /// </summary>
        protected override void StoreCriteria()
        {
            // Save Company Search Criteria

            // Industry Type
            if (_oUser.prwu_IndustryType != GeneralDataMgr.INDUSTRY_TYPE_LUMBER) 
            {
                _oCompanySearchCriteria.IndustryType = rblIndustryType.SelectedValue;
            }
                    
            // Company Name 
            _oCompanySearchCriteria.CompanyName = txtCompanyName.Text.Trim();

            // BB #
            //if (txtBBNum.Text.Length > 0)
            //    _oCompanySearchCriteria.BBID = Convert.ToInt32(txtBBNum.Text);
            //else
            //    _oCompanySearchCriteria.BBID = 0;

            // CompanyType, Listing Status
            _oCompanySearchCriteria.CompanyType = ddlCompanyType.SelectedValue;
            _oCompanySearchCriteria.ListingStatus = ddlListingStatus.SelectedValue;

            // CompanyPhone
            _oCompanySearchCriteria.PhoneAreaCode = txtPhoneAreaCode.Text.Trim();
            _oCompanySearchCriteria.PhoneNumber = txtPhone.Text.Trim();

            // CompanyFax
            _oCompanySearchCriteria.FaxAreaCode = txtFaxAreaCode.Text.Trim();
            _oCompanySearchCriteria.FaxNumber = txtFaxNumber.Text.Trim();
            _oCompanySearchCriteria.FaxNotNull = chkFaxNotNull.Checked;

            //CompanyEmail
            _oCompanySearchCriteria.Email = txtEmail.Text.Trim();
            _oCompanySearchCriteria.EmailNotNull = chkEmailNotNull.Checked;

            //NewListings
            _oCompanySearchCriteria.NewListingOnly = chkNewListingsOnly.Checked;
            if (!String.IsNullOrEmpty(ddlNewListingRange.SelectedValue))
                _oCompanySearchCriteria.NewListingDaysOld = Convert.ToInt32(ddlNewListingRange.SelectedValue);
            else
                _oCompanySearchCriteria.NewListingDaysOld = 0;

            base.StoreCriteria();
        }

        /// <summary>
        /// Clears and stores the search criteria on the users current company search
        /// criteria object 
        /// </summary>
        protected override void ClearCriteria()
        {
            // Clear the corresponding Company Search Criteria object and 
            // reload the page

            // Company Name 
            txtCompanyName.Text = "";

            // BB #
            //txtBBNum.Text = "";

            // CompanyType, Listing Status
            ddlCompanyType.SelectedIndex = -1;
            ddlListingStatus.SelectedIndex = -1;

            // CompanyPhone
            txtPhoneAreaCode.Text = "";
            txtPhone.Text = "";

            // CompanyFax
            txtFaxAreaCode.Text = "";
            txtFaxNumber.Text = "";
            chkFaxNotNull.Checked = false;

            //CompanyEmail
            txtEmail.Text = "";
            chkEmailNotNull.Checked = false;

            //NewListings
            chkNewListingsOnly.Checked = false;
            ddlNewListingRange.SelectedIndex = -1;

            _szRedirectURL = PageConstants.COMPANY_SEARCH;            
        }

        /// <summary>
        /// Make sure our ToggleInitialState JS function gets
        /// called to set come control states appropriately.
        /// </summary>
        public override void PreparePageFooter() {
            base.PreparePageFooter();
            Page.ClientScript.RegisterStartupScript(this.GetType(), "OnPageLoadJS", "ToggleInitialState();", true);
        }
    }
}
