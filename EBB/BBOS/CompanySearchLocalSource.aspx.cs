/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2016-2018

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc
 is strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CompanySearchLocalSource
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;

using PRCo.EBB.BusinessObjects;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web
{
    public partial class CompanySearchLocalSource : CompanySearchBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            // Set page title, sub-title
            SetPageTitle(Resources.Global.CompanySearch, Resources.Global.LocalSourceCriteria);

            // Add company submenu to this page
            SetSubmenu("btnLocalSourceData");
            SetPopover();

            if (!IsPostBack)
            {
                LoadLookupValues();

                PopulateForm();
            }

            SetVisibility();

            // Make sure we have the latest search object updated before setting 
            // the search criteria control
            StoreCriteria();

            // Set Search Criteria User Control
            ucCompanySearchCriteriaControl.CompanySearchCriteria = _oCompanySearchCriteria;

            // Required for checkbox selection functions [Select All/Deselect All]
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_FUNCTIONS2_FILE));

            // See issue #54.  Hiding it from the user for now.
            // We should probably remove the code at some point but
            // restoring it would be a pain so let's make sure this
            // is want we want to do first.
            btnNewSearch.Visible = false;
        }

        protected void SetPopover()
        {
            popIndustryType.Attributes.Add("data-bs-title", Resources.Global.IndustryTypeText);
            popLocalSourceData.Attributes.Add("data-bs-title", Resources.Global.LocalSourceDataString);
        }

        /// <summary>
        /// Initialize the page controls.  All dynamic page controls
        /// must be pre-built in order for viewstate to be set correctly on 
        /// page load
        /// </summary>
        /// <param name="e"></param>
        override protected void OnInit(EventArgs e)
        {
            base.OnInit(e);

            // Build Volume controls
            _oUser = (IPRWebUser)Session["oUser"];

            if (_oUser == null)
            {
                if (string.IsNullOrEmpty(HttpContext.Current.User.Identity.Name))
                {
                    return;
                }

                if (_oLogger == null)
                {
                    _oLogger = (ILogger)Session["Logger"];
                }
                InitializeUser(HttpContext.Current.User.Identity.Name);
            }

            if (_oUser == null)
            {
                return;
            }

            BuildControlTable(tblTotalAcres, 2, PREFIX_TOTAL_ACRES, pnlTotalAcresLinks, UpdatePanel1, true);
        }

        /// <summary>
        /// Check users page level authorization
        /// </summary>
        /// <returns></returns>
        override protected bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.LocalSourceDataAccess).HasPrivilege;
        }

        /// <summary>
        /// Check users control/data level authorization
        /// </summary>
        /// <returns></returns>
        protected override bool IsAuthorizedForData()
        {
            // Save Search Criteria requires Level 3 access
            List<Control> lSaveSearchControls = new List<Control>();
            lSaveSearchControls.Add(btnSaveSearch);
            lSaveSearchControls.Add(btnLoadSearch);
            ApplySecurity(lSaveSearchControls, SecurityMgr.Privilege.SaveSearches);
            ApplyReadOnlyCheck(btnSaveSearch);

            return true;
        }

        /// <summary>
        /// Loads all of the databound controls setting 
        /// thier default values.
        /// </summary>
        protected void LoadLookupValues()
        {
            // Bind Industry Type control
            BindLookupValues(rblIndustryType, GetReferenceData(REF_DATA_INDUSTRY_TYPE));
            ModifyIndustryType(rblIndustryType);

            BindLookupValues(ddlIncludeLocalSource, GetReferenceData("BBOSSearchLocalSoruce"));
            BindLookupValues(cblAlsoOperates, GetReferenceData("prls_AlsoOperates"));
        }

        /// <summary>
        /// Used to show/hide form elements based on the current page
        /// settings
        /// </summary>
        protected void SetVisibility()
        {
            // If anything other than Produce is selected, disable the controls
            if (rblIndustryType.SelectedValue != GeneralDataMgr.INDUSTRY_TYPE_PRODUCE)
            {
                //lblIncludeLocalSource.Enabled = false;
                ddlIncludeLocalSource.Enabled = true;

                //lblCertifiedOrganic.Enabled = false;
                cbCertifiedOrganic.Enabled = false;

                //lblAlsoOperates.Enabled = false;
                cblAlsoOperates.Enabled = false;

                //lblTotalAcres.Enabled = false;
                pnlTotalAcresLinks.Enabled = false;
                DisableTableControls(tblTotalAcres);
            }
            else
            {
                //lblCertifiedOrganic.Enabled = true;
                cbCertifiedOrganic.Enabled = true;

                //lblAlsoOperates.Enabled = true;
                cblAlsoOperates.Enabled = true;

                //lblTotalAcres.Enabled = true;
                pnlTotalAcresLinks.Enabled = true;
                EnableTableControls(tblTotalAcres);
            }

            ApplySecurity(pnlIndustryType, SecurityMgr.Privilege.CompanySearchByIndustry);
        }

        /// <summary>
        /// Populates the form controls based on the current 
        /// company search criteria object
        /// </summary>
        protected void PopulateForm()
        {
            SetListDefaultValue(ddlIncludeLocalSource, _oCompanySearchCriteria.IncludeLocalSource);
            SetListDefaultValue(rblIndustryType, _oCompanySearchCriteria.IndustryType);
            cbCertifiedOrganic.Checked = _oCompanySearchCriteria.CertifiedOrganic;
            SetListValues(cblAlsoOperates, _oCompanySearchCriteria.AlsoOperates);

            string[] aszTotalAcres = UIUtils.GetString(_oCompanySearchCriteria.TotalAcres).Split(achDelimiter);
            SetTableValues(aszTotalAcres, tblTotalAcres, PREFIX_TOTAL_ACRES, _oUser.HasPrivilege(SecurityMgr.Privilege.LocalSourceDataAccess).HasPrivilege);
        }

        /// <summary>
        /// Collects and stores the search criteria on the users current company search
        /// criteria object 
        /// </summary>
        protected override void StoreCriteria()
        {
            // Industry Type
            if (_oUser.prwu_IndustryType != GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                _oCompanySearchCriteria.IndustryType = rblIndustryType.SelectedValue;
            }

            _oCompanySearchCriteria.IncludeLocalSource = ddlIncludeLocalSource.SelectedValue;
            _oCompanySearchCriteria.AlsoOperates = GetSelectedValues(cblAlsoOperates);
            _oCompanySearchCriteria.TotalAcres = GetTableValues(tblTotalAcres, PREFIX_TOTAL_ACRES);
            _oCompanySearchCriteria.CertifiedOrganic = cbCertifiedOrganic.Checked;
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
            ddlIncludeLocalSource.SelectedIndex = -1;
            cblAlsoOperates.SelectedIndex = -1;
            cbCertifiedOrganic.Checked = false;
            ClearTableValues(tblTotalAcres);

            _szRedirectURL = PageConstants.COMPANY_SEARCH_LOCAL_SOURCE;
        }

        /// <summary>
        /// Process the selected index changed event for the industry type radio button list.
        /// If the supply and servic industry has been selected, discard the previously selected
        /// criteria.  Store updated criteria and refresh page to update the search criteria user control.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void rblIndustryType_SelectedIndexChanged(object sender, EventArgs e)
        {
            ddlIncludeLocalSource.SelectedIndex = -1;
            cblAlsoOperates.SelectedIndex = -1;
            cbCertifiedOrganic.Checked = false;
            ClearTableValues(tblTotalAcres);

            // Store search criteria and refresh page
            StoreCriteria();
            Response.Redirect(PageConstants.COMPANY_SEARCH_LOCAL_SOURCE);
        }
    }
}