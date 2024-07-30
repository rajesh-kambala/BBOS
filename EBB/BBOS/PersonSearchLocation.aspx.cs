/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2012-2020

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: PersonSearchLocation
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
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    public partial class PersonSearchLocation : PersonSearchBase
    {
        private const string PAGE_VIEW_EXPANDED = "1";
        private const string PAGE_VIEW_BASIC = "0";

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            // Set page title, sub-title
            SetPageTitle(Resources.Global.PeopleSearch, Resources.Global.LocationCriteria);
            SetSubmenu("btnLocation");

            if (!IsPostBack)
            {
                // Retrieve requested page view 
                if (!String.IsNullOrEmpty(Request["LocationExpanded"]))
                    hPageView.Value = Request["LocationExpanded"];

                CheckForExpandedCriteria();
                LoadLookupValues();

                PopulateForm();

                // Add toggle functions, but only if radius is active
                if (_oUser.HasPrivilege(SecurityMgr.Privilege.PersonSearchByRadius).HasPrivilege)
                {
                    txtPostalCode.Attributes.Add("onkeyup", "ToggleRadius(null, this, false);");
                    cblTerminalMarket.Attributes.Add("onclick", "ToggleRadius(this, null, false);");
                }

                BindTerminalMarkets();
            }

            // Make sure we have the latest search object updated before setting 
            // the search criteria control
            StoreCriteria();
            ucSearchCriteriaControl.PersonSearchCriteria = _oPersonSearchCriteria;

            // Hide/Show items based on current form values
            SetVisibility();
        }

        /// <summary>
        /// Loads all of the databound controls setting 
        /// thier default values.
        /// </summary>
        protected void LoadLookupValues()
        {
            BindCountryValues(cblCountryNA, "prcn_Region = 'NA'", "prcn_CountryID");

            lblCA.Text = GetReferenceValue("prcn_Region", "CA");
            BindCountryValues(cblCountryCA, "prcn_Region = 'CA'");

            lblCR.Text = GetReferenceValue("prcn_Region", "CR");
            BindCountryValues(cblCountryCR, "prcn_Region = 'CR'");

            lblSA.Text = GetReferenceValue("prcn_Region", "SA");
            BindCountryValues(cblCountrySA, "prcn_Region = 'SA'");

            lblEU.Text = GetReferenceValue("prcn_Region", "EU");
            BindCountryValues(cblCountryEU, "prcn_Region = 'EU'");

            lblCSAME.Text = GetReferenceValue("prcn_Region", "CSAME");
            BindCountryValues(cblCountryCSAME, "prcn_Region = 'CSAME'");

            lblEAP.Text = GetReferenceValue("prcn_Region", "EAP");
            BindCountryValues(cblCountryEAP, "prcn_Region = 'EAP'");

            lblAF.Text = GetReferenceValue("prcn_Region", "AF");
            BindCountryValues(cblCountryAF, "prcn_Region = 'AF'");

            // Bind State checkbox lists
            // NOTE: Currently State lists for USA, Mexico, and Canada will be handled.
            // Issues arouse with AJAX and using the dynamically generated state checkbox 
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
            lblRadiusSearchText.Text = String.Format(Resources.Global.RadiusTypeSearchText, szPostalCodeURL);
            btnLookupPostalCode.NavigateUrl = szPostalCodeURL;
        }

        /// <summary>
        /// Populates the form controls based on the current 
        /// company search criteria object
        /// </summary>
        protected void PopulateForm()
        {
            // Listing Country
            SetListValues(cblCountryNA, _oPersonSearchCriteria.ListingCountryIDs);
            SetListValues(cblCountryCA, _oPersonSearchCriteria.ListingCountryIDs);
            SetListValues(cblCountryCR, _oPersonSearchCriteria.ListingCountryIDs);
            SetListValues(cblCountrySA, _oPersonSearchCriteria.ListingCountryIDs);
            SetListValues(cblCountryEU, _oPersonSearchCriteria.ListingCountryIDs);
            SetListValues(cblCountryCSAME, _oPersonSearchCriteria.ListingCountryIDs);
            SetListValues(cblCountryEAP, _oPersonSearchCriteria.ListingCountryIDs);
            SetListValues(cblCountryAF, _oPersonSearchCriteria.ListingCountryIDs);

            // Listing State
            if (!string.IsNullOrEmpty(_oPersonSearchCriteria.ListingStateIDs))
            {
                string[] aszStates = _oPersonSearchCriteria.ListingStateIDs.Split(CompanySearchBase.achDelimiter);
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

            txtListingCity.Text = _oPersonSearchCriteria.ListingCity;
            //txtListingCounty.Text = _oPersonSearchCriteria.ListingCounty;
            SetListValues(cblTerminalMarket, _oPersonSearchCriteria.TerminalMarketIDs);
            txtPostalCode.Text = _oPersonSearchCriteria.ListingPostalCode;

            // Within Radius
            if (_oPersonSearchCriteria.Radius >= 0)
                txtRadius.Text = UIUtils.GetStringFromInt(_oPersonSearchCriteria.Radius, false);

            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                SetListDefaultValue(rblRadiusSearchType, CompanySearchCriteria.CODE_RADIUSTYPE_LISTINGPOSTALCODE);
            }
            else
            {
                if (string.IsNullOrEmpty(_oPersonSearchCriteria.RadiusType))
                {
                    SetListDefaultValue(rblRadiusSearchType, CompanySearchCriteria.CODE_RADIUSTYPE_LISTINGPOSTALCODE);
                }
                else
                {
                    SetListDefaultValue(rblRadiusSearchType, _oPersonSearchCriteria.RadiusType);
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
            if ((_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER))
            {
                pnlTerminalMarket.Visible = false;
            }

            // Determine what state lists to show
            pnlStatesFor_1.Visible = false;
            pnlStatesFor_2.Visible = false;
            pnlStatesFor_3.Visible = false;

            if (string.IsNullOrEmpty(_oPersonSearchCriteria.ListingCountryIDs))
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

            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                rblRadiusSearchType.Visible = false;
                lblMilesOf.Text = Resources.Global.MilesOfPostalCode;
            }
        }

        /// <summary>
        /// Collects and stores the location search criteria on the users current company search
        /// criteria object.
        /// </summary>
        protected override void StoreCriteria()
        {
            // Listing Country
            _oPersonSearchCriteria.ListingCountryIDs = string.Empty;
            _oPersonSearchCriteria.ListingCountryIDs = SetValue(_oPersonSearchCriteria.ListingCountryIDs, cblCountryNA);
            _oPersonSearchCriteria.ListingCountryIDs = SetValue(_oPersonSearchCriteria.ListingCountryIDs, cblCountryCA);
            _oPersonSearchCriteria.ListingCountryIDs = SetValue(_oPersonSearchCriteria.ListingCountryIDs, cblCountryCR);
            _oPersonSearchCriteria.ListingCountryIDs = SetValue(_oPersonSearchCriteria.ListingCountryIDs, cblCountrySA);
            _oPersonSearchCriteria.ListingCountryIDs = SetValue(_oPersonSearchCriteria.ListingCountryIDs, cblCountryEU);
            _oPersonSearchCriteria.ListingCountryIDs = SetValue(_oPersonSearchCriteria.ListingCountryIDs, cblCountryCSAME);
            _oPersonSearchCriteria.ListingCountryIDs = SetValue(_oPersonSearchCriteria.ListingCountryIDs, cblCountryEAP);
            _oPersonSearchCriteria.ListingCountryIDs = SetValue(_oPersonSearchCriteria.ListingCountryIDs, cblCountryAF);

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

            _oPersonSearchCriteria.ListingStateIDs = sbStates.ToString();

            _oPersonSearchCriteria.ListingCity = txtListingCity.Text.Trim();
            //_oPersonSearchCriteria.ListingCounty = txtListingCounty.Text.Trim();
            _oPersonSearchCriteria.TerminalMarketIDs = GetSelectedValues(cblTerminalMarket);

            // Listing Postal Code
            if (!string.IsNullOrEmpty(txtPostalCode.Text.Trim()))
            {
                _oPersonSearchCriteria.ListingPostalCode = txtPostalCode.Text;
                // This search type is only valid with radius, so if the user has not 
                // entered a value radius value, then default one
                if (txtRadius.Text.Length == 0)
                    txtRadius.Text = "0";
            }
            else
            {
                _oPersonSearchCriteria.ListingPostalCode = "";
            }

            // Within Radius - NOTE: 0 is a valid radius value
            if (txtRadius.Text.Length > 0 && Convert.ToInt32(txtRadius.Text) >= 0)
            {
                _oPersonSearchCriteria.Radius = Convert.ToInt32(txtRadius.Text);
            }
            else
            {
                _oPersonSearchCriteria.Radius = -1;
            }

            // Radius Search Type
            _oPersonSearchCriteria.RadiusType = rblRadiusSearchType.SelectedValue;

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

            _szRedirectURL = PageConstants.PERSON_SEARCH_LOCATION;
        }

        /// <summary>
        /// The method will scan through the selected search criteria to determine if the user
        /// has selected elements on the expanded criteria view.  This will be used to determine
        /// the toggle state for loaded searches.
        /// </summary>
        protected void CheckForExpandedCriteria()
        {
            string[] aszCountries = UIUtils.GetString(_oPersonSearchCriteria.ListingCountryIDs).Split(achDelimiter);
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
            if (!String.IsNullOrEmpty(_oPersonSearchCriteria.TerminalMarketIDs))
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
                if (!String.IsNullOrEmpty(_oPersonSearchCriteria.TerminalMarketIDs) ||
                    !string.IsNullOrEmpty(_oPersonSearchCriteria.ListingPostalCode))
                {
                    Page.ClientScript.RegisterStartupScript(this.GetType(), "OnPageLoadJS", "ToggleInitialState();", true);
                }
            }
        }

        protected void BindTerminalMarkets()
        {
            // Bind Terminal Market control
            List<ICustom_Caption> lTerminalMarketValues = new List<ICustom_Caption>();
            DataTable dtTerminalMarketList = GetTerminalMarketList();

            bool bFoundUS = false;
            if (!string.IsNullOrEmpty(_oPersonSearchCriteria.ListingCountryIDs))
            {
                string[] aszCountryIDs = _oPersonSearchCriteria.ListingCountryIDs.Split(',');
                foreach (string szCountryID in aszCountryIDs)
                {
                    if (szCountryID == "1")
                    {
                        bFoundUS = true;
                        break;
                    }
                }
            }
            else
            {
                bFoundUS = true;
            }

            DataRow[] drTerminalMarkets = null;
            if (!bFoundUS)
            {
                return;
            }

            if (string.IsNullOrEmpty(_oPersonSearchCriteria.ListingStateIDs))
            {
                drTerminalMarkets = dtTerminalMarketList.Select();
            }
            else
            {
                drTerminalMarkets = dtTerminalMarketList.Select("prst_StateID IN (" + _oPersonSearchCriteria.ListingStateIDs + ")", "prtm_State, prtm_City, prtm_ListedMarketName");
            }

            foreach (DataRow drRow in drTerminalMarkets)
            {
                // Display all country values
                ICustom_Caption oCustom_Caption2 = new Custom_Caption();
                oCustom_Caption2.Code = drRow["prtm_TerminalMarketId"].ToString();
                oCustom_Caption2.Meaning = drRow["prtm_FullMarketName"].ToString() + "<br/>" +
                    "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" +
                    drRow["prtm_City"].ToString() + ", " + drRow["prtm_State"].ToString();
                lTerminalMarketValues.Add(oCustom_Caption2);
            }

            BindLookupValues(cblTerminalMarket, lTerminalMarketValues);

            // Now that we've reset our TS list, we have to
            // maintain state ourselves.
            string szSelectedIDs = string.Empty;
            if (!string.IsNullOrEmpty(_oPersonSearchCriteria.TerminalMarketIDs))
            {
                string[] aszTSIDs = _oPersonSearchCriteria.TerminalMarketIDs.Split(',');
                foreach (string szID in aszTSIDs)
                {
                    foreach (ListItem oLI in cblTerminalMarket.Items)
                    {
                        if (szID == oLI.Value)
                        {
                            oLI.Selected = true;

                            if (szSelectedIDs.Length > 0)
                            {
                                szSelectedIDs += ",";
                            }
                            szSelectedIDs += oLI.Value;
                        }
                    }
                }

                // We are resetting the selected IDs to ensure only those markets
                // currently available to be selected are actually selected.
                _oPersonSearchCriteria.TerminalMarketIDs = szSelectedIDs;
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

        override protected bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.PersonSearchLocationPage).HasPrivilege;
        }
    }
}