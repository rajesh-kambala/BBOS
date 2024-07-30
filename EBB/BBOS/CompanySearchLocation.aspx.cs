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

 ClassName: CompanySearchLocation
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using PRCo.EBB.Util;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This page contains the location search fields for searching companies
    /// including the listing country, listing state/province, listing city, listing postal code,
    /// and terminal market.
    /// 
    /// This page includes radius searching for companies within x miles of the specified 
    /// postal code or terminal market.
    /// 
    /// A Basic and Expanded view are available.  When viewing in Basic mode, the country list should
    /// be limited to USA, Canada, and Mexico.
    /// </summary>
    public partial class CompanySearchLocation : CompanySearchBase
    {
        private const string PAGE_VIEW_EXPANDED = "1";
        private const string PAGE_VIEW_BASIC = "0";

        /// <summary>
        /// Calls page functions required to build and process this page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            // Set page title, sub-title
            SetPageTitle(Resources.Global.CompanySearch, Resources.Global.LocationCriteria);

            // Add company submenu to this page
            SetSubmenu("btnLocation");
            SetPopover();

            if (!IsPostBack)
            {
                // Retrieve requested page view 
                if (!String.IsNullOrEmpty(Request["LocationExpanded"]))
                    hPageView.Value = Request["LocationExpanded"];

                CheckForExpandedCriteria();
                LoadLookupValues();

                PopulateForm();

                // Add toggle functions, but only if radius is active
                if (_oUser.HasPrivilege(SecurityMgr.Privilege.CompanySearchByRadius).HasPrivilege)
				{
					txtPostalCode.Attributes.Add("onkeyup", "ToggleRadius(null, this, false);");
					cblTerminalMarket.Attributes.Add("onclick", "ToggleRadius(this, null, false);");
				}
            }
           
            // Make sure we have the latest search object updated before setting 
            // the search criteria control
            StoreCriteria();

            // Hide/Show items based on current form values
            SetVisibility();

            BindTerminalMarkets();

            // Set Search Criteria User Control
            ucCompanySearchCriteriaControl.CompanySearchCriteria = _oCompanySearchCriteria;

            // See issue #54.  Hiding it from the user for now.
            // We should probably remove the code at some point but
            // restoring it would be a pain so let's make sure this
            // is want we want to do first.
            btnNewSearch.Visible = false;          
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
            return _oUser.HasPrivilege(SecurityMgr.Privilege.CompanySearchLocationPage).HasPrivilege;
        }

        /// <summary>        
        /// Check users control/data level authorization
        /// </summary>
        /// <returns></returns>
        protected override bool IsAuthorizedForData()
        {
			// Terminal Markets
            List<Control> lTerminalMarketControls = new List<Control>();
            //lTerminalMarketControls.Add(lblTerminalMarket);
            lTerminalMarketControls.Add(cblTerminalMarket);

            //lTerminalMarketControls.Add(tmHide);
            //lTerminalMarketControls.Add(tmView);
            lTerminalMarketControls.Add(pnlTMButtons);
            ApplySecurity(lTerminalMarketControls, SecurityMgr.Privilege.CompanySearchByTerminalMarket);

			// Radius Search
			List<Control> lRadiusSearch = new List<Control>();
			lRadiusSearch.Add(txtRadius);
			lRadiusSearch.Add(rblRadiusSearchType);
			lRadiusSearch.Add(lblRadiusSearchText);
            lRadiusSearch.Add(btnLookupPostalCode);
            ApplySecurity(lRadiusSearch, SecurityMgr.Privilege.CompanySearchByRadius);

            // Save Search Criteria requires Level 3 access
            List<Control> lSaveSearchControls = new List<Control>();
            lSaveSearchControls.Add(btnSaveSearch);
            lSaveSearchControls.Add(btnLoadSearch);
            ApplySecurity(lSaveSearchControls, SecurityMgr.Privilege.SaveSearches);

            ApplyReadOnlyCheck(btnSaveSearch);

            return true;
        }

        int countryCount = 0;
        private void LoadCountryRegion(CheckBoxList regionList, Literal regionLabel, string regionCode)
        {
            BindCountryValues(regionList, "prcn_Region = '" + regionCode + "'");
            countryCount += regionList.Items.Count;
            if (regionList.Items.Count > 0)
            {
                regionLabel.Text = GetReferenceValue("prcn_Region", regionCode);
            }
        }

        /// <summary>
        /// Loads all of the databound controls setting 
        /// thier default values.
        /// </summary>
        protected void LoadLookupValues()
        {
            BindCountryValues(cblCountryNA, "prcn_Region = 'NA'", "prcn_CountryID");

            LoadCountryRegion(cblCountryCA, lblCA, "CA");
            LoadCountryRegion(cblCountryCR, lblCR, "CR");
            LoadCountryRegion(cblCountrySA, lblSA, "SA");
            LoadCountryRegion(cblCountryEU, lblEU, "EU");
            LoadCountryRegion(cblCountryCSAME, lblCSAME, "CSAME");
            LoadCountryRegion(cblCountryEAP, lblEAP, "EAP");
            LoadCountryRegion(cblCountryAF, lblAF, "AF");

            if (countryCount == 0)
            {
                countryRegions.Visible = false;
                cnHide.Visible = false;
                cnView.Visible = false;
            }

            // Bind State checkbox lists
            // NOTE: Currently State lists for USA, Mexico, and Canada will be handled.
            // Issues arose with AJAX and using the dynamically generated state checkbox 
            // list controls, also an issue when stubbing out these countrols inside a 
            // repeater - 08/21/2007 SSC            
            DataTable dtStateList = GetStateList();
            for (int i = 1; i <= 3; i++)
            {
                List<ICustom_Caption> lStateValues = new List<ICustom_Caption>();

                DataRow[] adrStateList = dtStateList.Select("prst_CountryId = " + i.ToString());

                foreach (DataRow drRow in adrStateList)
                {
                    ICustom_Caption oCustom_Caption = new Custom_Caption();
                    oCustom_Caption.Code = drRow["prst_StateId"].ToString();
                    oCustom_Caption.Meaning = drRow["prst_State"].ToString();
                    lStateValues.Add(oCustom_Caption);
                }

                string szControlName = "cblStatesFor_" + i.ToString();
                CheckBoxList cblStates = (CheckBoxList)this.Master.FindControl("form1").FindControl("contentMain").FindControl(szControlName);

                BindLookupValues(cblStates, lStateValues);      
          
                // Also populate the country name label
                szControlName = "lblCountryName_" + i.ToString();
                Label lblCountryName = (Label)this.Master.FindControl("form1").FindControl("contentMain").FindControl(szControlName);

                lblCountryName.Text = GetValueFromList(GetCountryList(), "prcn_CountryId = " + i.ToString(), "prcn_Country");
            }

            // Bind Radius Type Search control
            List<ICustom_Caption> lRadiusTypeValues = new List<ICustom_Caption>();

            ICustom_Caption oCustom_Caption3 = new Custom_Caption();
            oCustom_Caption3.Code = "Listing Postal Code";
            oCustom_Caption3.Meaning = Resources.Global.ListingPostalCode;
            lRadiusTypeValues.Add(oCustom_Caption3);

            SecurityMgr.SecurityResult privTerminalMarkets = _oUser.HasPrivilege(SecurityMgr.Privilege.CompanySearchByTerminalMarket);
            if (privTerminalMarkets.HasPrivilege)
            {
                ICustom_Caption oCustom_Caption4 = new Custom_Caption();
                oCustom_Caption4.Code = "Terminal Market";
                oCustom_Caption4.Meaning = Resources.Global.TerminalMarket;
                lRadiusTypeValues.Add(oCustom_Caption4);
            }

            BindLookupValues(rblRadiusSearchType, lRadiusTypeValues);

            string szPostalCodeURL = Utilities.GetConfigValue("PostalCodeLookupURL");
            lblRadiusSearchText.Text = Resources.Global.RadiusTypeSearchText;
            btnLookupPostalCode.NavigateUrl = szPostalCodeURL;

            // Bind Industry Type control
            BindLookupValues(rblIndustryType, GetReferenceData(REF_DATA_INDUSTRY_TYPE));
            ModifyIndustryType(rblIndustryType);
        }

        /// <summary>
        /// Populates the form controls based on the current 
        /// company search criteria object
        /// </summary>
        protected void PopulateForm()
        {
            // Set Location Criteria Information

            // Industry Type 
            SetListDefaultValue(rblIndustryType, _oCompanySearchCriteria.IndustryType);

            // Listing Country
            SetListValues(cblCountryNA, _oCompanySearchCriteria.ListingCountryIDs);
            SetListValues(cblCountryCA, _oCompanySearchCriteria.ListingCountryIDs);
            SetListValues(cblCountryCR, _oCompanySearchCriteria.ListingCountryIDs);
            SetListValues(cblCountrySA, _oCompanySearchCriteria.ListingCountryIDs);
            SetListValues(cblCountryEU, _oCompanySearchCriteria.ListingCountryIDs);
            SetListValues(cblCountryCSAME, _oCompanySearchCriteria.ListingCountryIDs);
            SetListValues(cblCountryEAP, _oCompanySearchCriteria.ListingCountryIDs);
            SetListValues(cblCountryAF, _oCompanySearchCriteria.ListingCountryIDs);

            // Listing State
            if (!string.IsNullOrEmpty(_oCompanySearchCriteria.ListingStateIDs))
            {
                string[] aszStates = _oCompanySearchCriteria.ListingStateIDs.Split(CompanySearchBase.achDelimiter);
                for (int i = 1; i <= 3; i++)
                {
                    foreach (string szState in aszStates)
                    {
                        if (!String.IsNullOrEmpty(szState))
                        {
                            string szControlName = "cblStatesFor_" + i.ToString();
                            CheckBoxList oCheckboxList = (CheckBoxList)this.Master.FindControl("form1").FindControl("contentMain").FindControl(szControlName);
                            SetListValue(oCheckboxList, szState);
                        }
                    }
                }
            }

            txtListingCity.Text = _oCompanySearchCriteria.ListingCity;
            //txtListingCounty.Text = _oCompanySearchCriteria.ListingCounty;
            SetListValues(cblTerminalMarket, _oCompanySearchCriteria.TerminalMarketIDs);
            txtPostalCode.Text = _oCompanySearchCriteria.ListingPostalCode;

            // Within Radius
            if(_oCompanySearchCriteria.Radius >= 0)
                txtRadius.Text = UIUtils.GetStringFromInt(_oCompanySearchCriteria.Radius, false);

            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                SetListDefaultValue(rblRadiusSearchType, CompanySearchCriteria.CODE_RADIUSTYPE_LISTINGPOSTALCODE);
            }
            else
            {
                if (string.IsNullOrEmpty(_oCompanySearchCriteria.RadiusType)) {
                    SetListDefaultValue(rblRadiusSearchType, CompanySearchCriteria.CODE_RADIUSTYPE_LISTINGPOSTALCODE);
                } else {
                    SetListDefaultValue(rblRadiusSearchType, _oCompanySearchCriteria.RadiusType);
                }
            }
        }

        /// <summary>
        /// Used to show/hide form elements based on the current page
        /// settings
        /// </summary>
        protected void SetVisibility()
        {
            // Only show terminal markets if Produce is selected as the industry type
            if ((rblIndustryType.SelectedValue != GeneralDataMgr.INDUSTRY_TYPE_PRODUCE) &&
                (rblIndustryType.SelectedValue != GeneralDataMgr.INDUSTRY_TYPE_TRANSPORTATION))
            {
                pnlTerminalMarket.Visible = false;
            }

            // Determine what state lists to show
            pnlStatesFor_1.Visible = false;
            pnlStatesFor_2.Visible = false;
            pnlStatesFor_3.Visible = false;

            if (string.IsNullOrEmpty(_oCompanySearchCriteria.ListingCountryIDs))
                // If nothing is selected, show the USA states by default
                pnlStatesFor_1.Visible = true;
            else
            {
                foreach (ListItem oListItem in cblCountryNA.Items)
                {
                    if (oListItem.Selected)
                    {
                        // Currently we are only working with USA, Canada, and Mexico 
                        // state lists
                        switch (oListItem.Value)
                        {
                            case "1":
                                pnlStatesFor_1.Visible = true;
                                break;
                            case "2":
                                pnlStatesFor_2.Visible = true;
                                break;
                            case "3":
                                pnlStatesFor_3.Visible = true;
                                break;
                        }
                    }
                }
            }

            lblMilesOf.Text = Resources.Global.MilesOf;
            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                //pnlIndustryType.Visible = false;
                rblRadiusSearchType.Visible = false;
                lblMilesOf.Text = Resources.Global.MilesOfPostalCode;
            }

            ApplySecurity(pnlIndustryType, SecurityMgr.Privilege.CompanySearchByIndustry);
        }

        /// <summary>
        /// Collects and stores the location search criteria on the users current company search
        /// criteria object.
        /// </summary>
        protected override void StoreCriteria()
        {
            // Save Company Location Search Criteria

            // Industry Type
            if (_oUser.prwu_IndustryType != GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                _oCompanySearchCriteria.IndustryType = rblIndustryType.SelectedValue;
            }

            // Listing Country
            _oCompanySearchCriteria.ListingCountryIDs = string.Empty;
            _oCompanySearchCriteria.ListingCountryIDs = SetValue(_oCompanySearchCriteria.ListingCountryIDs, cblCountryNA);
            _oCompanySearchCriteria.ListingCountryIDs = SetValue(_oCompanySearchCriteria.ListingCountryIDs, cblCountryCA);
            _oCompanySearchCriteria.ListingCountryIDs = SetValue(_oCompanySearchCriteria.ListingCountryIDs, cblCountryCR);
            _oCompanySearchCriteria.ListingCountryIDs = SetValue(_oCompanySearchCriteria.ListingCountryIDs, cblCountrySA);
            _oCompanySearchCriteria.ListingCountryIDs = SetValue(_oCompanySearchCriteria.ListingCountryIDs, cblCountryEU);
            _oCompanySearchCriteria.ListingCountryIDs = SetValue(_oCompanySearchCriteria.ListingCountryIDs, cblCountryCSAME);
            _oCompanySearchCriteria.ListingCountryIDs = SetValue(_oCompanySearchCriteria.ListingCountryIDs, cblCountryEAP);
            _oCompanySearchCriteria.ListingCountryIDs = SetValue(_oCompanySearchCriteria.ListingCountryIDs, cblCountryAF);

            // Listing State/Province
            StringBuilder sbStates = new StringBuilder();
            for (int i = 1; i <= 3; i++)
            {
                string szControlName = "cblStatesFor_" + i.ToString();
                CheckBoxList oCheckboxList = (CheckBoxList)this.Master.FindControl("form1").FindControl("contentMain").FindControl(szControlName);


                string szTemp = GetSelectedValues(oCheckboxList);
                if (!string.IsNullOrEmpty(szTemp))
                {
                    if (sbStates.Length > 0)
                    {
                        sbStates.Append(",");
                    }
                    sbStates.Append(GetSelectedValues(oCheckboxList));
                }
            }
            _oCompanySearchCriteria.ListingStateIDs = sbStates.ToString();

            _oCompanySearchCriteria.ListingCity = txtListingCity.Text.Trim();
            //_oCompanySearchCriteria.ListingCounty = txtListingCounty.Text.Trim();
            _oCompanySearchCriteria.TerminalMarketIDs = GetSelectedValues(cblTerminalMarket);

            // Listing Postal Code
            if (!string.IsNullOrEmpty(txtPostalCode.Text.Trim()))
            {
                _oCompanySearchCriteria.ListingPostalCode = txtPostalCode.Text;
                // This search type is only valid with radius, so if the user has not 
                // entered a value radius value, then default one
                if (txtRadius.Text.Length == 0)
                    txtRadius.Text = "0";
            }
            else
            {
                _oCompanySearchCriteria.ListingPostalCode = "";
            }

            // Within Radius - NOTE: 0 is a valid radius value
            if (txtRadius.Text.Length > 0 && Convert.ToInt32(txtRadius.Text) >= 0)
            {
                _oCompanySearchCriteria.Radius = Convert.ToInt32(txtRadius.Text);                
            }
            else
            {
                _oCompanySearchCriteria.Radius = -1;                
            }

            // Radius Search Type
            _oCompanySearchCriteria.RadiusType = rblRadiusSearchType.SelectedValue;

            base.StoreCriteria();
        }

        /// <summary>
        /// Clears and stores the search criteria on the users current company search
        /// criteria object 
        /// </summary>
        protected override void ClearCriteria()
        {
            // Clear the corresponding Company Search Criteria for this page
            // by resetting the form values

            cblCountryNA.SelectedIndex = -1;
            cblCountryCA.SelectedIndex = -1;
            cblCountryCR.SelectedIndex = -1;
            cblCountrySA.SelectedIndex = -1;
            cblCountryEU.SelectedIndex = -1;
            cblCountryCSAME.SelectedIndex = -1;
            cblCountryEAP.SelectedIndex = -1;
            cblCountryAF.SelectedIndex = -1;

            cblStatesFor_1.SelectedIndex = -1;
            cblStatesFor_2.SelectedIndex = -1;
            cblStatesFor_3.SelectedIndex = -1;

            txtListingCity.Text = string.Empty;
            //txtListingCounty.Text = string.Empty;
            txtPostalCode.Text = string.Empty;
            cblTerminalMarket.SelectedIndex = -1;
            txtRadius.Text = string.Empty;
            rblRadiusSearchType.SelectedIndex = -1;

            _szRedirectURL = PageConstants.COMPANY_SEARCH_LOCATION;
        }

        /// <summary>
        /// The method will scan through the selected search criteria to determine if the user
        /// has selected elements on the expanded criteria view.  This will be used to determine
        /// the toggle state for loaded searches.
        /// </summary>
        protected void CheckForExpandedCriteria()
        {
            // Check if the user has selected a country from our expanded list
            string[] aszCountries = UIUtils.GetString(_oCompanySearchCriteria.ListingCountryIDs).Split(achDelimiter);
            foreach (string szCountry in aszCountries)
            {
                if (!String.IsNullOrEmpty(szCountry))
                {
                    if (Convert.ToInt32(szCountry) > 3)
                    {
                        hPageView.Value = PAGE_VIEW_EXPANDED;
                    }
                }
            }     
       
            // Check if the user has selected terminal markets
            if (!String.IsNullOrEmpty(_oCompanySearchCriteria.TerminalMarketIDs))
            {
                hPageView.Value = PAGE_VIEW_EXPANDED;
            }
        }

        /// <summary>
        /// Set page to auto-generate javascript variables for form elements.
        /// This is required for the toggle radius form items.
        /// </summary>
        /// <returns></returns>
        public override bool EnableJSClientIDTranslation()
        {
            return true;
        }

        /// <summary>
        /// Make sure our ToggleInitialState JS function gets
        /// called to set some control states appropriately.
        /// </summary>
        public override void PreparePageFooter()
        {
            base.PreparePageFooter();

            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                Page.ClientScript.RegisterStartupScript(this.GetType(), "OnPageLoadJS", "ToggleInitialState();", true);
            }
            else
            {
                if (!String.IsNullOrEmpty(_oCompanySearchCriteria.TerminalMarketIDs) ||
                    !string.IsNullOrEmpty(_oCompanySearchCriteria.ListingPostalCode))
                {
                    Page.ClientScript.RegisterStartupScript(this.GetType(), "OnPageLoadJS", "ToggleInitialState();", true);
                }
            }
        }
        
        protected void BindTerminalMarkets() {
            // Bind Terminal Market control
            List<ICustom_Caption> lTerminalMarketValues = new List<ICustom_Caption>();
            DataTable dtTerminalMarketList = GetTerminalMarketList();
           
            bool bFoundUS = false;
            if (!string.IsNullOrEmpty(_oCompanySearchCriteria.ListingCountryIDs)) {
                string[] aszCountryIDs = _oCompanySearchCriteria.ListingCountryIDs.Split(',');
                foreach(string szCountryID in aszCountryIDs) {
                    if (szCountryID == "1") {
                        bFoundUS = true;
                        break;
                    }
                }
            } else {
                bFoundUS = true;
            }

            DataRow[] drTerminalMarkets = null;
            if (!bFoundUS) {
                return;
            }            
            
            if (string.IsNullOrEmpty(_oCompanySearchCriteria.ListingStateIDs)) {
                drTerminalMarkets = dtTerminalMarketList.Select();
            } else {
                drTerminalMarkets = dtTerminalMarketList.Select("prst_StateID IN (" + _oCompanySearchCriteria.ListingStateIDs + ")", "prtm_State, prtm_City, prtm_ListedMarketName");
            }

            foreach (DataRow drRow in drTerminalMarkets) {
                // Display all country values
                ICustom_Caption oCustom_Caption2 = new Custom_Caption();
                oCustom_Caption2.Code = drRow["prtm_TerminalMarketId"].ToString();
                oCustom_Caption2.Meaning = drRow["prtm_FullMarketName"].ToString() + "&nbsp;|&nbsp;" + drRow["prtm_City"].ToString() + ", " + drRow["prtm_State"].ToString();
                lTerminalMarketValues.Add(oCustom_Caption2);
            }
            BindLookupValues(cblTerminalMarket, lTerminalMarketValues);

            // Now that we've reset our TS list, we have to
            // maintain state ourselves.
            string szSelectedIDs = string.Empty;
            if (!string.IsNullOrEmpty(_oCompanySearchCriteria.TerminalMarketIDs)) {
                string[] aszTSIDs = _oCompanySearchCriteria.TerminalMarketIDs.Split(',');
                foreach(string szID in aszTSIDs) {
                    foreach(ListItem oLI in cblTerminalMarket.Items) {
                        if (szID == oLI.Value) {
                            oLI.Selected = true;
                            
                            if (szSelectedIDs.Length > 0) {
                                szSelectedIDs += ",";
                            }
                            szSelectedIDs += oLI.Value;
                        }
                    }
                }
                
                // We are resetting the selected IDs to ensure only those markets
                // currently available to be selected are actually selected.
                _oCompanySearchCriteria.TerminalMarketIDs = szSelectedIDs;
            }
        }

        protected void States_OnDataBound(object sender, EventArgs e)
        {
            CheckBoxList cblStates = (CheckBoxList)(sender);
            foreach (ListItem item in cblStates.Items)
            {
                item.Attributes.Add("StateID", item.Value);
            }
        }
    }
}
