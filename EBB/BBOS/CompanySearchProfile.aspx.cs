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

 ClassName: CompanySearchProfile
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This page contains the profile search fields for searching companies
    /// including the license type, license number, brands, corporate structure, miscellaneous
    /// listing informtion, and volume.
    /// 
    /// If a Supply and Service company is selected for the Industry Type, the Brands, License Type,
    /// License, Corporate Structure, and Volume fields should be disabled.
    /// </summary>
    public partial class CompanySearchProfile : CompanySearchBase
    {
        //private const string CONTAINER_NAME = "ctl00_contentMain";

        private const string REF_DATA_LICENSETYPE = "prli_Type";
        private const string REF_DATA_CORPSTRUCTURE = "prcp_CorporateStructure";

        /// <summary>
        /// Calls page functions required to build and process this page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            // Set page title, sub-title
            SetPageTitle(Resources.Global.CompanySearch, Resources.Global.ProfileCriteria);

            // Add company submenu to this page
            SetSubmenu("btnProfile");
            SetPopover();

            if (!IsPostBack)
            {
                LoadLookupValues();
                PopulateForm();
            }

            // Hide/Show items based on current form values
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

            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                BuildControlTable(tblVolume, 5, PREFIX_LUMBER_VOLUME, pnlVolumeLinks, UpdatePanel1, true);
                BuildControlTable(tblFTEmployees, 5, PREFIX_LUMBER_FT_EMPLOYEE, pnlFTEmployees, UpdatePanel1, true);
            }
            else
            {
                BuildControlTable(tblVolume, 5, PREFIX_VOLUME, pnlVolumeLinks, UpdatePanel1, true);
            }

            //Defect 7045 - Limited Access restrictions
            if (_oUser.prwu_AccessLevel == PRWebUser.SECURITY_LEVEL_LIMITED_ACCESS)
            {
                trCertifications.Enabled = false;
            }
        }

        protected void SetPopover()
        {
            popIndustryType.Attributes.Add("data-bs-title", Resources.Global.IndustryTypeText);
        }

        /// <summary>
        /// Check users page level authorization
        /// </summary>
        /// <returns></returns>
        override protected bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.CompanySearchProfilePage).HasPrivilege;
        }

        /// <summary>
        /// Check users control/data level authorization
        /// </summary>
        /// <returns></returns>
        protected override bool IsAuthorizedForData()
        {
            // Brand
            List<Control> lBrandControls = new List<Control>();
            lBrandControls.Add(txtBrands);
            lBrandControls.Add(lblBrands);
            ApplySecurity(lBrandControls, SecurityMgr.Privilege.CompanySearchByBrand);

            // Corporate Structure
            //List<Control> lCorpStructControls = new List<Control>();
            //lCorpStructControls.Add(lblCorporateStructure);
            //lCorpStructControls.Add(cblCorporateStructure);
            //ApplySecurity(lCorpStructControls, SecurityMgr.Privilege.CompanySearchByCorporateStructure);

            // Miscellaneous Listing Info
            List<Control> lMiscListInfoControls = new List<Control>();
            lMiscListInfoControls.Add(lblMiscListingInfo);
            lMiscListInfoControls.Add(txtMiscListingInfo);
            ApplySecurity(lMiscListInfoControls, SecurityMgr.Privilege.CompanySearchByMiscListing);

            // Company License
            List<Control> lLicenseTypeControls = new List<Control>();
            lLicenseTypeControls.Add(lblLicenseType);
            lLicenseTypeControls.Add(cblLicenseType);
            //lLicenseTypeControls.Add(lblLicenseNumber);
            //lLicenseTypeControls.Add(txtLicenseNumber);
            ApplySecurity(lLicenseTypeControls, SecurityMgr.Privilege.CompanySearchByLicense);

            // Volume 
            List<Control> lVolumeControls = new List<Control>();
            //lVolumeControls.Add(lblVolume);
            lVolumeControls.Add(lblVolumeText);
            lVolumeControls.Add(tblVolume);
            lVolumeControls.Add(pnlVolumeLinks);
            ApplySecurity(lVolumeControls, SecurityMgr.Privilege.CompanySearchByVolume);

            // Save Search Criteria requires Level 3 access
            List<Control> lSaveSearchControls = new List<Control>();
            lSaveSearchControls.Add(btnSaveSearch);
            lSaveSearchControls.Add(btnLoadSearch);
            ApplySecurity(lSaveSearchControls, SecurityMgr.Privilege.SaveSearches);
            ApplyReadOnlyCheck(btnSaveSearch);

            // FullTime Employees
            List<Control> lFTEmployeeControls = new List<Control>();
            //lFTEmployeeControls.Add(lblFTEmployees);
            lFTEmployeeControls.Add(pnlFTEmployees);
            lFTEmployeeControls.Add(tblFTEmployees);
            ApplySecurity(lFTEmployeeControls, SecurityMgr.Privilege.CompanySearchByFTEmployees);

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

            // Bind Corporate Structure checkbox list
            //BindLookupValues(cblCorporateStructure, GetReferenceData(REF_DATA_CORPSTRUCTURE));

            // Bind License Type drop-down
            // NOTE: Add "DRC" option
            BindLookupValues(cblLicenseType, GetReferenceData(REF_DATA_LICENSETYPE));
            ListItem oItem = new ListItem(Resources.Global.LicenseTypeDRC, "DRC");
            cblLicenseType.Items.Insert(2, oItem);

            // Bind Volume checkbox list
            // NOTE: Dynamic control - done in page OnInit to correctly process viewstate
        }

        /// <summary>
        /// Populates the form controls based on the current 
        /// company search criteria object
        /// </summary>
        protected void PopulateForm()
        {
            // Set Profile Criteria Information
            if (_oUser.prwu_IndustryType != GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                SetListDefaultValue(rblIndustryType, _oCompanySearchCriteria.IndustryType);
            }

            SetListValues(cblLicenseType, _oCompanySearchCriteria.LicenseTypes);
            //txtLicenseNumber.Text = UIUtils.GetString(_oCompanySearchCriteria.LicenseNumber);
            txtBrands.Text = UIUtils.GetString(_oCompanySearchCriteria.Brands);
            //SetListValues(cblCorporateStructure, _oCompanySearchCriteria.CorporateStructure);
            txtMiscListingInfo.Text = UIUtils.GetString(_oCompanySearchCriteria.DescriptiveLines);

            string[] aszVolumes = UIUtils.GetString(_oCompanySearchCriteria.Volume).Split(achDelimiter);
            SetTableValues(aszVolumes, tblVolume, PREFIX_VOLUME, _oUser.HasPrivilege(SecurityMgr.Privilege.CompanySearchByVolume).HasPrivilege);

            string[] aszFTEmployees = UIUtils.GetString(_oCompanySearchCriteria.FullTimeEmployeeCodes).Split(achDelimiter);
            SetTableValues(aszFTEmployees, tblFTEmployees, PREFIX_LUMBER_FT_EMPLOYEE, _oUser.HasPrivilege(SecurityMgr.Privilege.CompanySearchByFTEmployees).HasPrivilege);

            //SetListValue(ddlPubliclyTraded, _oCompanySearchCriteria.PubliclyTraded);
            //txtStockSymbol.Text = _oCompanySearchCriteria.StockSymbol;

            cbOrganic.Checked = _oCompanySearchCriteria.Organic;
            cbFoodSafety.Checked = _oCompanySearchCriteria.FoodSafetyCertified;

            cbSalvageDistressedProduce.Checked = _oCompanySearchCriteria.SalvageDistressedProduce;
        }

        /// <summary>
        /// Used to show/hide form elements based on the current page
        /// settings
        /// </summary>
        protected void SetVisibility()
        {
            ApplySecurity(cbSalvageDistressedProduce, SecurityMgr.Privilege.CompanySearchBySalvageDistressedProduce);

            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                pnlIndustryType.Visible = false; //defect 5698 disabled for lumber

                // License Type
                lblLicenseType.Visible = false;
                cblLicenseType.Visible = false;
                lblLTDefinitions.Visible = false;

                lblVolumeText.Text = Resources.Global.LumberVolumeText;

                trCertifications.Visible = false;
                trLicenseType.Visible = false;
                return;
            }

            ApplySecurity(pnlIndustryType, SecurityMgr.Privilege.CompanySearchByIndustry);

            trFTEmployees.Visible = false;

            // If the Supply and Service industry type is selected, 
            // disable the License Type, License Number, Corporate Structure, and 
            // volume search elements
            if (rblIndustryType.SelectedValue == GeneralDataMgr.INDUSTRY_TYPE_SUPPLY)
            {
                // License Type
                lblLicenseType.Enabled = false;
                cblLicenseType.Enabled = false;

                // License Number
                //lblLicenseNumber.Enabled = false;
                //txtLicenseNumber.Enabled = false;

                // Corporate Structure
                //lblCorporateStructure.Enabled = false;
                //cblCorporateStructure.Enabled = false;

                // Volume
                //lblVolume.Enabled = false;
                pnlVolumeLinks.Enabled = false;
                //lblVolumeText.Enabled = false;
                DisableTableControls(tblVolume);
            }
            else
            {
                lblBrands.Enabled = _oUser.HasPrivilege(SecurityMgr.Privilege.CompanySearchByBrand).HasPrivilege;
                txtBrands.Enabled = lblBrands.Enabled;

                lblLicenseType.Enabled = _oUser.HasPrivilege(SecurityMgr.Privilege.CompanySearchByLicense).HasPrivilege;
                cblLicenseType.Enabled = lblLicenseType.Enabled;
                //lblLicenseNumber.Enabled = lblLicenseType.Enabled;
                //txtLicenseNumber.Enabled = lblLicenseType.Enabled;

                //lblCorporateStructure.Enabled = _oUser.HasPrivilege(SecurityMgr.Privilege.CompanySearchByCorporateStructure).HasPrivilege;
                //cblCorporateStructure.Enabled = lblCorporateStructure.Enabled;

                if (_oUser.HasPrivilege(SecurityMgr.Privilege.CompanySearchByVolume).HasPrivilege)
                {
                    // a little overkill here, but won't hurt anything
                    //lblVolume.Enabled = true;
                    pnlVolumeLinks.Enabled = true;
                    //lblVolumeText.Enabled = true;
                    EnableTableControls(tblVolume);
                }
                else
                {
                    //lblVolume.Enabled = false;
                    pnlVolumeLinks.Enabled = false;
                    //lblVolumeText.Enabled = false;
                    DisableTableControls(tblVolume);
                }
            }

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

            _oCompanySearchCriteria.LicenseTypes = GetSelectedValues(cblLicenseType);
            //_oCompanySearchCriteria.LicenseNumber = txtLicenseNumber.Text.Trim();
            _oCompanySearchCriteria.Brands = txtBrands.Text.Trim();
            //_oCompanySearchCriteria.CorporateStructure = GetSelectedValues(cblCorporateStructure);
            _oCompanySearchCriteria.DescriptiveLines = txtMiscListingInfo.Text.Trim();

            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                _oCompanySearchCriteria.Volume = GetTableValues(tblVolume, PREFIX_LUMBER_VOLUME);
                _oCompanySearchCriteria.FullTimeEmployeeCodes = GetTableValues(tblFTEmployees, PREFIX_LUMBER_FT_EMPLOYEE);
            }
            else
            {
                _oCompanySearchCriteria.Volume = GetTableValues(tblVolume, PREFIX_VOLUME);
            }

            //_oCompanySearchCriteria.PubliclyTraded = ddlPubliclyTraded.SelectedValue;
            //_oCompanySearchCriteria.StockSymbol = txtStockSymbol.Text;

            _oCompanySearchCriteria.Organic = cbOrganic.Checked;
            _oCompanySearchCriteria.FoodSafetyCertified = cbFoodSafety.Checked;
            _oCompanySearchCriteria.SalvageDistressedProduce = cbSalvageDistressedProduce.Checked;

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
            cblLicenseType.SelectedIndex = -1;
            //txtLicenseNumber.Text = "";
            txtBrands.Text = "";
            //cblCorporateStructure.SelectedIndex = -1;
            txtMiscListingInfo.Text = "";
            ClearTableValues(tblVolume);
            ClearTableValues(tblFTEmployees);
            cbOrganic.Checked = false;
            cbFoodSafety.Checked = false;
            cbSalvageDistressedProduce.Checked = false;

            _szRedirectURL = PageConstants.COMPANY_SEARCH_PROFILE;
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
            // If the user selects a new industy type, discard the previously selected
            // classification criteria
            if (rblIndustryType.SelectedValue == GeneralDataMgr.INDUSTRY_TYPE_SUPPLY)
            {
                _oCompanySearchCriteria.Brands = "";
                _oCompanySearchCriteria.LicenseTypes = "";
                //_oCompanySearchCriteria.LicenseNumber = "";
                //_oCompanySearchCriteria.CorporateStructure = "";
                _oCompanySearchCriteria.Volume = "";

                // Store search criteria and refresh page
                StoreCriteria();
                Response.Redirect(PageConstants.COMPANY_SEARCH_PROFILE);
            }
        }
    }
}