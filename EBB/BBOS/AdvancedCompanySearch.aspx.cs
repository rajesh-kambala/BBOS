/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2023-2024

 The use, disclosure, reproduction, modification, transfer, or
 transmittal of  this work for any purpose in any form or by any
 means without the written  permission of Produce Reporter Co is
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: AdvancedCompanySearch
 Description:

 Notes:

***********************************************************************
***********************************************************************/

using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using PRCo.EBB.Util;
using Resources;
using TSI.BusinessObjects;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This page contains the general search fields for searching companies
    /// including the company name, bb #, type, listing status, company phone, company fax,
    /// company email, and new listings.
    /// </summary>
    public partial class AdvancedCompanySearch : AdvancedCompanySearchBase
    {
        private const string REF_DATA_COMPANY_TYPE = "Comp_PRType";
        private const string REF_DATA_NEW_LISTINGS_ONLY = "NewListingDaysOld";

        private const string REF_DATA_LICENSETYPE = "prli_Type";
        private const string REF_DATA_CORPSTRUCTURE = "prcp_CorporateStructure";

        protected CompanySearchBase oCompanySearchBase;
        protected bool bResetUserList = false;
        protected bool bResetCustomFields = false;

        /// <summary>
        /// Calls page functions required to build and process this page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);
            oCompanySearchBase = new CompanySearchBase();
            ((BBOS)Master).HideOldTopMenu();

            // Add company submenu to this page
            SetApplicationMenu();

            if (!IsPostBack)
            {
                LoadLookupValues();
                PopulateForm();

                // Hide/Show items based on current form values
                SetVisibility();

                //Defect 7045 - Limited Access restrictions
                if (_oUser.prwu_AccessLevel == PRWebUser.SECURITY_LEVEL_LIMITED_ACCESS)
                {
                    cblSalesTerritory.Enabled = false;
                    ddlTerritoryCode.Enabled = false;
                    ddlMembershipTypeCode.Enabled = false;
                    cblPrimaryService.Enabled = false;
                    ddlAvailLicenseSearchType.Enabled = false;
                    txtAvailLicense.Enabled = false;
                    ddlActiveLicenseSearchType.Enabled = false;
                    txtActiveLicense.Enabled = false;
                    ddlAvailableUnitsSearchType.Enabled = false;
                    txtAvailableUnits.Enabled = false;
                    ddlUsedUnitsSearchType.Enabled = false;
                    txtUsedUnits.Enabled = false;
                    cbReceivesPromoFaxes.Disabled = true;
                    cbReceivesPromoEmails.Disabled = true;
                    ddlMembershipRevenueSearchType.Enabled = false;
                    txtMembershipRevenue.Enabled = false;
                    ddlAdvertisingRevenueSearchType.Enabled = false;
                    txtAdvertisingRevenue.Enabled = false;
                }

                bResetUserList = true;
            }
            else
            {
                ProcessClearCriteria();
            }

            // Make sure we have the latest search object updated before setting
            // the search criteria control
            StoreCriteria();

            // Set Search Criteria User Control
            ucAdvancedCompanySearchCriteriaControl.CompanySearchCriteria = _oCompanySearchCriteria;

            ((BBOS)Master).SelectedMenu = "advanced-search-dropdown";
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

            _oUser = (IPRWebUser)Session["oUser"];

            // If we don't have a user, take them to the login
            // page.  Sometimes we end up here after the user's auth
            // ticket times out, but for some reason ASP.NET does not
            // take the user to the login page.
            if (_oUser == null)
            {
                Response.Redirect(PageConstants.BBOS_HOME);
                return;
            }

            #region "Rating"
            // Build Integrity/Ability Rating controls
            BuildControlTable(phIntegrityRating, PREFIX_INTEGRITYRATING, UpdatePanel1);

            // Build Pay Description controls
            BuildControlTable(phPayDescription, PREFIX_PAYDESCRIPTION, UpdatePanel1);
            #endregion

            #region "Classification"
            BuildClassificationsTable(pnlProduceClass, "0", 1, true, true, UpdatePanel1) ;
            BuildClassificationsTable(pnlTransportationClass, "1", 4, false, true, UpdatePanel1);
            BuildClassificationsTable(pnlSupplyClass, "2", 3, false, true, UpdatePanel1);
            BuildClassificationsTable(pnlLumberClass, "3", 1, false, false, UpdatePanel1);
            #endregion


            #region "Licenses and Certifications"
            IBusinessObjectSet osLicenseType = GetReferenceData(REF_DATA_LICENSETYPE);
            Custom_Caption ccDRC = new Custom_Caption();
            ccDRC.Code = "DRC";
            osLicenseType.Add(ccDRC);
            #endregion

            #region "Local Source"
            BuildControlTable(phTotalAcres, PREFIX_TOTAL_ACRES, UpdatePanel1);
            #endregion

            //spot OnInit()
            #region "Custom Filters"

            if (!string.IsNullOrEmpty(Request["SearchID"]))
                Int32.TryParse(GetRequestParameter("SearchID"), out _iSearchID);
            else
                _iSearchID = 0;

            RetrieveObject();

            PopulateCustomFields();
            #endregion
        }

        /// <summary>
        /// Check users page level authorization
        /// </summary>
        /// <returns></returns>
        override protected bool IsAuthorizedForPage()
        {
            //SPOT IsAuthorizedForPage()

            return _oUser.HasPrivilege(SecurityMgr.Privilege.CompanySearchPage).HasPrivilege ||
                _oUser.HasPrivilege(SecurityMgr.Privilege.CompanySearchRatingPage).HasPrivilege ||
                _oUser.HasPrivilege(SecurityMgr.Privilege.CompanySearchLocationPage).HasPrivilege ||
                HasPrivilege_ITA_Always_True(SecurityMgr.Privilege.CompanySearchCommoditiesPage) ||
                HasPrivilege_ITA_Always_True(SecurityMgr.Privilege.CompanySearchClassificationsPage) ||
                HasPrivilege_ITA_Always_True(SecurityMgr.Privilege.CompanySearchProfilePage) ||
                HasPrivilege_ITA_Always_True(SecurityMgr.Privilege.LocalSourceDataAccess) ||
                HasPrivilege_ITA_Always_True(SecurityMgr.Privilege.CompanySearchCustomPage);
        }

        /// <summary>
        /// Check users control/data level authorization
        /// </summary>
        /// <returns></returns>
        protected override bool IsAuthorizedForData()
        {
            #region "Company Details"
            // Listing Status security
            List<Control> lListingStatusControls = new List<Control>();
            lListingStatusControls.Add(ddlListingStatus);
            ApplySecurity(lListingStatusControls, SecurityMgr.Privilege.CompanySearchByListingStatus);

            // New Listings security
            List<Control> lNewListingControls = new List<Control>();
            lNewListingControls.Add(chkNewListingsOnly);
            lNewListingControls.Add(ddlNewListingRange);
            ApplySecurity(lNewListingControls, SecurityMgr.Privilege.CompanySearchByNewListings);

            // Save Search Criteria security
            List<Control> lSaveSearchControls = new List<Control>();
            lSaveSearchControls.Add(hlSavedSearches);
            ApplySecurity(lSaveSearchControls, SecurityMgr.Privilege.SaveSearches, bBBOS9: true);
            ApplyReadOnlyCheck(hlSavedSearches);

            // Phone security
            List<Control> lPhoneControls = new List<Control>();
            lPhoneControls.Add(txtPhoneNumber);
            lPhoneControls.Add(chkPhoneNotNull);
            ApplySecurity(lPhoneControls, SecurityMgr.Privilege.CompanySearchByPhoneFaxNumber, bBBOS9: true);

            // Email security
            List<Control> lEmailControls = new List<Control>();
            lEmailControls.Add(txtEmail);
            ApplySecurity(lEmailControls, SecurityMgr.Privilege.CompanySearchByEmail, bBBOS9: true);

            //Has Email security
            lEmailControls.Clear();
            lEmailControls.Add(chkEmailNotNull);
            ApplySecurity(lEmailControls, SecurityMgr.Privilege.CompanySearchByHasEmail, bBBOS9: true);
            #endregion
            #region "Rating"
            // Trading Membership Year
            List<Control> lMembershipYearControls = new List<Control>();
            lMembershipYearControls.Add(chkTMFMNotNull);
            ApplySecurity(lMembershipYearControls, SecurityMgr.Privilege.CompanySearchByTMFMMembershipYear, bBBOS9: true);

            // BB Score
            List<Control> lBBScoreControls = new List<Control>();
            lBBScoreControls.Add(ddlBBScoreSearchType);
            lBBScoreControls.Add(txtBBScore);
            ApplySecurity(lBBScoreControls, SecurityMgr.Privilege.CompanySearchByBBScore, bBBOS9: true);

            // Credit Worth
            List<Control> lCreditWorthControls = new List<Control>();
            lCreditWorthControls.Add(pnlCreditWorthRating);
            lCreditWorthControls.Add(pnlCreditWorthRating_L);
            ApplySecurity(lCreditWorthControls, SecurityMgr.Privilege.CompanySearchByCreditWorthRating);

            // Integrity / Ability
            List<Control> lIntegrityRatingControls = new List<Control>();
            lIntegrityRatingControls.Add(trIntegrityRating);
            ApplySecurity(lIntegrityRatingControls, SecurityMgr.Privilege.CompanySearchByIntegrityRating);

            //// Pay Description
            List<Control> lPayDescriptionControls = new List<Control>();
            lPayDescriptionControls.Add(pnlPayDescription);
            ApplySecurity(lPayDescriptionControls, SecurityMgr.Privilege.CompanySearchByPayRating);

            //// Pay Indicator  //TODO:JMT LUMBER IsAuthorizedForData()
            //List<Control> lPayIndicatorControls = new List<Control>();
            ////lPayIndicatorControls.Add(lblPayIndicator);
            //lPayIndicatorControls.Add(pnlPayIndicatorLinks);
            //lPayIndicatorControls.Add(tblPayIndicator);
            //ApplySecurity(lPayIndicatorControls, SecurityMgr.Privilege.CompanySearchByPayIndicator);

            //// Pay Report Count //TODO:JMT LUMBER IsAuthorizedForData()
            //List<Control> lPayReportCountControls = new List<Control>();
            ////lPayReportCountControls.Add(lblPayReportCount);
            //lPayReportCountControls.Add(ddlPayReportCountSearchType);
            //lPayReportCountControls.Add(txtPayReportCount);
            //ApplySecurity(lPayReportCountControls, SecurityMgr.Privilege.CompanySearchByPayReportCount);
            #endregion
            #region "Location"
            // Terminal Markets
            List<Control> lTerminalMarketControls = new List<Control>();
            lTerminalMarketControls.Add(pnlTerminalMarkets);
            lTerminalMarketControls.Add(fsTerminalMarkets);

            ApplySecurity(lTerminalMarketControls, SecurityMgr.Privilege.CompanySearchByTerminalMarket);

            // Radius Search
            List<Control> lRadiusSearch = new List<Control>();
            lRadiusSearch.Add(pnlRadius);
            lRadiusSearch.Add(fsRadius);

            ApplySecurity(lRadiusSearch, SecurityMgr.Privilege.CompanySearchByRadius);
            #endregion
            #region "Commodity"
            #endregion
            #region "Classifications"

            // Number of Stores
            List<Control> lNumberOfRestaurantControls = new List<Control>();
            lNumberOfRestaurantControls.Add(lblRestaurantStores);
            lNumberOfRestaurantControls.Add(cblNumOfRestaurants);
            ApplySecurity(lNumberOfRestaurantControls, SecurityMgr.Privilege.CompanySearchByNumberofRestaraunts);

            // Retail
            List<Control> lNumberOfRetailControls = new List<Control>();
            lNumberOfRetailControls.Add(lblRetailStores);
            lNumberOfRetailControls.Add(cblNumOfRetail);
            ApplySecurity(lNumberOfRetailControls, SecurityMgr.Privilege.CompanySearchByNumberofRetailStores);

            if (_oUser.prwu_IndustryType != GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                // Classification Search Type
                List<Control> lClassificationSearchType = new List<Control>();
                lClassificationSearchType.Add(rblClassSearchType);
                ApplySecurity(lSaveSearchControls, SecurityMgr.Privilege.CompanySearchByClassifications);

                // Produce Class
                List<Control> lProduceClass = new List<Control>();
                lProduceClass.Add(pnlProduceClass);
                ApplySecurity(lProduceClass, SecurityMgr.Privilege.CompanySearchByClassifications);

                // Transportation
                List<Control> lTransporationClass = new List<Control>();
                lTransporationClass.Add(pnlTransportationClass);
                ApplySecurity(lTransporationClass, SecurityMgr.Privilege.CompanySearchByClassifications);

                // Supply
                List<Control> lSupplyClass = new List<Control>();
                lSupplyClass.Add(pnlSupplyClass);
                ApplySecurity(lSupplyClass, SecurityMgr.Privilege.CompanySearchByClassifications);
            }
            else
            {
                // Lumber
                List<Control> lLumberClass = new List<Control>();
                lLumberClass.Add(pnlLumberClass);
                ApplySecurity(lLumberClass, SecurityMgr.Privilege.CompanySearchByClassifications);
            }
            #endregion

            #region "Licenses and Certifications"
            // Brand
            List<Control> lBrandControls = new List<Control>();
            lBrandControls.Add(txtBrands);
            //lBrandControls.Add(lblBrands);
            ApplySecurity(lBrandControls, SecurityMgr.Privilege.CompanySearchByBrand);

            // Miscellaneous Listing Info
            List<Control> lMiscListInfoControls = new List<Control>();
            lMiscListInfoControls.Add(txtMiscListingInfo);
            ApplySecurity(lMiscListInfoControls, SecurityMgr.Privilege.CompanySearchByMiscListing);

            // Company License
            List<Control> lLicenseTypeControls = new List<Control>();
            lLicenseTypeControls.Add(cblLicenseType);
            ApplySecurity(lLicenseTypeControls, SecurityMgr.Privilege.CompanySearchByLicense);

            // Volume
            List<Control> lVolumeControls = new List<Control>();
            //lVolumeControls.Add(lblVolume);
            //lVolumeControls.Add(lblVolumeText);
            //lVolumeControls.Add(tblVolume);
            //lVolumeControls.Add(pnlVolumeLinks);
            //ApplySecurity(lVolumeControls, SecurityMgr.Privilege.CompanySearchByVolume);

            // FullTime Employees
            //List<Control> lFTEmployeeControls = new List<Control>();
            ////lFTEmployeeControls.Add(lblFTEmployees);
            //lFTEmployeeControls.Add(pnlFTEmployees);
            //lFTEmployeeControls.Add(tblFTEmployees);
            //ApplySecurity(lFTEmployeeControls, SecurityMgr.Privilege.CompanySearchByFTEmployees);
            #endregion

            //Spot IsAuthorizedForData()
            #region "Local Source"
            // Save Search Criteria requires Level 3 access
            lSaveSearchControls = new List<Control>();
            lSaveSearchControls.Add(btnSaveSearch);
            ApplySecurity(lSaveSearchControls, SecurityMgr.Privilege.SaveSearches);
            #endregion
            #region "Custom Filters"
            // Notes
            List<Control> lHasNotesControls = new List<Control>();
            lHasNotesControls.Add(chkCompanyHasNotes);
            ApplySecurity(lHasNotesControls, SecurityMgr.Privilege.CompanySearchByHasNotes);

            // Watchdog list
            List<Control> lWatchdogControls = new List<Control>();
            lWatchdogControls.Add(pnlWatchdogList);
            ApplySecurity(lWatchdogControls, SecurityMgr.Privilege.CompanySearchByWatchdogList);
            #endregion

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
            #region "Company Details"
            // Bind Company Type drop-down
            BindLookupValues(rblCompanyType, GetReferenceData(AdvancedCompanySearchCriteriaControl.REF_DATA_COMPANY_TYPE));
            ListItem oItem = new ListItem(Resources.Global.Any, "");
            rblCompanyType.Items.Insert(0, oItem);

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
            #endregion

            #region "Rating"
            // Create Search Type list
            List<ICustom_Caption> lSearchTypeValues = GetSearchTypeValues();

            // Bind BB Score search type drop-down
            BindLookupValues(ddlBBScoreSearchType, lSearchTypeValues);

            // Bind Credit Worth Rating list
            BindLookupValues(ddlCreditWorthRating_Min, GetReferenceData("CreditWorthRating2"), true);
            BindLookupValues(ddlCreditWorthRating_Max, GetReferenceData("CreditWorthRating2"), true);
            BindLookupValues(ddlCreditWorthRating_Min_L, GetReferenceData("CreditWorthRating2L"), true);
            BindLookupValues(ddlCreditWorthRating_Max_L, GetReferenceData("CreditWorthRating2L"), true);

            // Bind Pay Report Count search type drop-down
            //BindLookupValues(ddlPayReportCountSearchType, lSearchTypeValues);

            // Bind Integrity/Ability Rating controls
            // NOTE: Dynamic control - done in page OnInit to correctly process viewstate

            // Bind Pay Description Controls
            // NOTE: Dynamic control - done in page OnInit to correctly process viewstate

            // Bind Credit Worth Rating Controls
            // NOTE: Dynamic control - done in page OnInit to correctly process viewstate
            #endregion

            #region "Location"
            #endregion

            #region "Commodities"
            List<ICustom_Caption> lSearchType = CompanySearchBase.GetSearchTypeList(Resources.Global.CommoditySearchTypeAny, Resources.Global.CommoditySearchTypeAll);
            BindLookupValues(rblCommoditySearchType, lSearchType, CompanySearchBase.CODE_SEARCH_TYPE_ANY);

            ICustom_Caption oAll = new Custom_Caption();
            oAll.Code = "0";
            oAll.Meaning = "All";

            // Bind Growing Method control
            DataTable dtAttributeList = oCompanySearchBase.GetAttributeList();

            List<ICustom_Caption> lGrowingMethodValues = new List<ICustom_Caption>();
            lGrowingMethodValues.Add(oAll);

            DataRow[] adrGrowingMethodList = dtAttributeList.Select("prat_Type = 'GM'");
            foreach (DataRow drRow in adrGrowingMethodList)
            {
                ICustom_Caption oCustom_Caption4 = new Custom_Caption();
                oCustom_Caption4.Code = drRow["prat_AttributeId"].ToString();
                oCustom_Caption4.Meaning = drRow["prat_Name"].ToString();
                lGrowingMethodValues.Add(oCustom_Caption4);
            }
            BindLookupValues(rblGrowingMethod, lGrowingMethodValues);

            litAttributes.Text = getAttributesControl();
            Page.ClientScript.RegisterStartupScript(Page.GetType(), "scriptAtt", "$('#attributes').val(" + _oCompanySearchCriteria.CommodityAttributeID + "); ", true);
            #endregion

            #region "Classifications"
            lSearchType = CompanySearchBase.GetSearchTypeList(Resources.Global.ClassificationSearchTypeAny, Resources.Global.ClassificationSearchTypeAll);
            BindLookupValues(rblClassSearchType, lSearchType, CompanySearchBase.CODE_SEARCH_TYPE_ANY);

            // Bind Classifications checkbox list

            // Bind Number of Retail Stores control
            BindLookupValues(cblNumOfRetail, GetReferenceData(REF_DATA_NUMBER_OF_STORES));

            // Bind Number of Restaurant Stores control
            BindLookupValues(cblNumOfRestaurants, GetReferenceData(REF_DATA_NUMBER_OF_STORES));
            #endregion

            #region "Licenses and Certifications"

            // Bind License Type drop-down
            // NOTE: Add "DRC" option
            BindLookupValues(cblLicenseType, GetReferenceData(REF_DATA_LICENSETYPE));
            oItem = new ListItem(Resources.Global.LicenseTypeDRC, "DRC");
            cblLicenseType.Items.Insert(2, oItem);

            // Bind Volume checkbox list
            string szVolumeField = "prcp_Volume";

            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                szVolumeField = "prcp_VolumeL";
            else

            BindLookupValues(ddlVolume_Min, GetReferenceData(szVolumeField), true);
            BindLookupValues(ddlVolume_Max, GetReferenceData(szVolumeField), true);
            #endregion

            //Spot LoadLookupValues()
            #region "Internal Criteria"
            BindLookupValues(cblSalesTerritory, GetReferenceData("SalesTerritorySearch"));
            BindLookupValues(ddlTerritoryCode, GetReferenceData("prci_SalesTerritory"), true);

            BindLookupValues(ddlMembershipTypeCode, GetReferenceData("MembershipTypeCode"));
            ddlMembershipTypeCode.Attributes.Add("onchange", "togglePrimaryService();");

            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                BindLookupValues(cblPrimaryService, GetReferenceData("NewProduct_Lumber"));
            else
                BindLookupValues(cblPrimaryService, GetReferenceData("NewProduct_Produce"));

            //List<ICustom_Caption> lSearchTypeValues = GetSearchTypeValues();
            BindLookupValues(ddlAvailLicenseSearchType, lSearchTypeValues);
            BindLookupValues(ddlActiveLicenseSearchType, lSearchTypeValues);
            BindLookupValues(ddlAdvertisingRevenueSearchType, lSearchTypeValues);
            BindLookupValues(ddlMembershipRevenueSearchType, lSearchTypeValues);
            BindLookupValues(ddlAvailableUnitsSearchType, lSearchTypeValues);
            BindLookupValues(ddlUsedUnitsSearchType, lSearchTypeValues);
            #endregion

            #region "Local Source"
            // Bind Industry Type control
            BindLookupValues(ddlIncludeLocalSource, GetReferenceData("BBOSSearchLocalSoruce"));
            BindLookupValues(cblAlsoOperates, GetReferenceData("prls_AlsoOperates"));
            #endregion
        }

        /// <summary>
        /// Populates the form controls.
        /// </summary>
        protected void PopulateForm()
        {
            SelectIndustryClass();

            #region "Company Details"
            txtCompanyName.Attributes.Add("placeholder", Resources.Global.FullOrPartOfTheName);
            txtCompanyName.Attributes.Add("aria-label", Resources.Global.FullOrPartOfTheName);

            txtPhoneNumber.Attributes.Add("placeholder", Resources.Global.EGOrPartOfTheNumber);
            txtPhoneNumber.Attributes.Add("aria-label", Resources.Global.FullOrPartOfThePhoneNumber);

            txtEmail.Attributes.Add("placeholder", Resources.Global.EmailOrPartOfEmail);
            txtEmail.Attributes.Add("aria-label", Resources.Global.FullOrPartOfEmail);

            // Set Company Search Information

            //New Listings Only
            chkNewListingsOnly.Checked = _oCompanySearchCriteria.NewListingOnly;
            foreach (ListItem oItem in ddlNewListingRange.Items)
            {
                if (Convert.ToInt32(oItem.Value) == _oCompanySearchCriteria.NewListingDaysOld)
                    oItem.Selected = true;
            }

            // Company Name
            txtCompanyName.Text = _oCompanySearchCriteria.CompanyName;

            // Company Type
            foreach (ListItem oItem in rblCompanyType.Items)
            {
                if (oItem.Value == _oCompanySearchCriteria.CompanyType)
                    oItem.Selected = true;
            }

            // Listing Status
            foreach (ListItem oItem in ddlListingStatus.Items)
            {
                if (oItem.Value == _oCompanySearchCriteria.ListingStatus)
                    oItem.Selected = true;
            }

            // Company Phone
            txtPhoneNumber.Text = _oCompanySearchCriteria.PhoneNumber;

            // Must have phone
            chkPhoneNotNull.Checked = _oCompanySearchCriteria.PhoneNotNull;

            // Company Email
            txtEmail.Text = _oCompanySearchCriteria.Email;

            chkEmailNotNull.Checked = _oCompanySearchCriteria.EmailNotNull;
            #endregion
            #region "Rating"
            txtBBScore.Attributes.Add("placeholder", Resources.Global.EnterANumber0To1000);
            txtBBScore.Attributes.Add("aria-label", Resources.Global.EnterANumber0To1000);


            //Rating Tab
            // Set Rating Criteria Information

            //// Set Profile Criteria Information
            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                //TODO:JMT LUMBER rating tab PopulateForm()

                // Pay Report Count
                //SetListDefaultValue(ddlPayReportCountSearchType, _oCompanySearchCriteria.PayReportCountSearchType);
                //if (_oCompanySearchCriteria.PayReportCount > -1)
                //{
                //txtPayReportCount.Text = _oCompanySearchCriteria.PayReportCount.ToString();
                //}

                // Pay Indicator
                //string[] aszPayIndicator = UIUtils.GetString(_oCompanySearchCriteria.PayIndicator).Split(new char[] { ',' });
                //SetTableValues(aszPayIndicator, tblPayIndicator, PREFIX_PAYINDICATOR);
            }
            else
            {
                chkTMFMNotNull.Checked = _oCompanySearchCriteria.IsTMFM;

                // Integrity / Ability Rating
                string[] aszIntegrityRating = UIUtils.GetString(_oCompanySearchCriteria.RatingIntegrityIDs).Split(new char[] { ',' });
                SetPlaceholderValues(aszIntegrityRating, phIntegrityRating, PREFIX_INTEGRITYRATING);

                // Pay Description
                string[] aszPayDescriptions = UIUtils.GetString(_oCompanySearchCriteria.RatingPayIDs).Split(new char[] { ',' });
                SetPlaceholderValues(aszPayDescriptions, phPayDescription, PREFIX_PAYDESCRIPTION);
            }

            // BB Score
            SetListDefaultValue(ddlBBScoreSearchType, _oCompanySearchCriteria.BBScoreSearchType);
            txtBBScore.Text = UIUtils.GetStringFromInt(_oCompanySearchCriteria.BBScore, true);

            // Credit Worth Rating
            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                if(!string.IsNullOrEmpty(_oCompanySearchCriteria.RatingCreditWorthMinID))
                    SetListDefaultValue(ddlCreditWorthRating_Min_L, _oCompanySearchCriteria.RatingCreditWorthMinID);
                if (!string.IsNullOrEmpty(_oCompanySearchCriteria.RatingCreditWorthMaxID))
                    SetListDefaultValue(ddlCreditWorthRating_Max_L, _oCompanySearchCriteria.RatingCreditWorthMaxID);
            }
            else
            {
                if (!string.IsNullOrEmpty(_oCompanySearchCriteria.RatingCreditWorthMinID))
                    SetListDefaultValue(ddlCreditWorthRating_Min, _oCompanySearchCriteria.RatingCreditWorthMinID);
                if (!string.IsNullOrEmpty(_oCompanySearchCriteria.RatingCreditWorthMaxID))
                    SetListDefaultValue(ddlCreditWorthRating_Max, _oCompanySearchCriteria.RatingCreditWorthMaxID);
            }
            #endregion
            #region "Location"
            txtListingCity.Attributes.Add("placeholder", Resources.Global.SearchForCityFromAboveCountry);
            txtListingCity.Attributes.Add("aria-label", Resources.Global.SearchForCityFromAboveCountry);

            txtRadius.Attributes.Add("placeholder", Resources.Global.DistanceInMiles);
            txtRadius.Attributes.Add("aria-label", Resources.Global.DistanceInMiles);
            txtZipCode.Attributes.Add("aria-label", Resources.Global.ZipCodeOrPostalCode);

            bool blnRefreshCountryState = false;

            if (string.IsNullOrEmpty(_oCompanySearchCriteria.ListingCountryIDs))
            {
                radio_country_none.Checked = true;
            }
            else
            {
                blnRefreshCountryState = true;

                foreach (string szCountry in _oCompanySearchCriteria.ListingCountryIDs.Split(','))
                {
                    switch (szCountry.Trim())
                    {
                        case "1": radio_country_usa.Checked = true; break;
                        case "2": radio_country_canada.Checked = true; break;
                        case "3": radio_country_mexico.Checked = true; break;
                        default:
                            radio_country_other.Checked = true;
                            break;
                    }
                }
            }

            if (!string.IsNullOrEmpty(_oCompanySearchCriteria.ListingStateIDs))
            {
                hidSelectedStates.Value = _oCompanySearchCriteria.ListingStateIDs;
                blnRefreshCountryState = true;
            }

            // CountryState region
            if (blnRefreshCountryState)
            {
                string f = $"countryState_setData({_oCompanySearchCriteria.ListingCountryIDs}, \"{_oCompanySearchCriteria.ListingStateIDs}\");";
                RegisterDocReadyScriptBlock("scriptCS", f);
            }

            // City Name
            txtListingCity.Text = UIUtils.GetString(_oCompanySearchCriteria.ListingCity);
            if (!string.IsNullOrEmpty(_oCompanySearchCriteria.ListingCity))
            {
                string f = $"$(\"#{txtListingCity.ClientID}\").val(\"{_oCompanySearchCriteria.ListingCity}\").trigger('change');";
                RegisterDocReadyScriptBlock("scriptCN", f);
            }

            // Terminal Markets
            if (!string.IsNullOrEmpty(_oCompanySearchCriteria.TerminalMarketIDs))
            {
                string f = $"mulSel_filldata('terminalMkt-mulSel', \"{_oCompanySearchCriteria.TerminalMarketIDs}\");";
                RegisterDocReadyScriptBlock("scriptTM", f);
            }

            txtZipCode.Value = _oCompanySearchCriteria.ListingPostalCode;

            // Within Radius
            if (_oCompanySearchCriteria.Radius >= 0)
                txtRadius.Value = UIUtils.GetStringFromInt(_oCompanySearchCriteria.Radius, false);

            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                zipcode_distance.Checked = true;
            }
            else
            {
                if (string.IsNullOrEmpty(_oCompanySearchCriteria.RadiusType))
                {
                    zipcode_distance.Checked = true;
                }
                else
                {
                    if (_oCompanySearchCriteria.RadiusType == SearchCriteriaBase.CODE_RADIUSTYPE_LISTINGPOSTALCODE)
                        zipcode_distance.Checked = true;
                    else if (_oCompanySearchCriteria.RadiusType == SearchCriteriaBase.CODE_RADIUSTYPE_TERMINALMARKET)
                        terminal_market_distance.Checked = true;
                }
            }

            #endregion
            #region "Commodity"
            // Commodity Search Type
            if (!string.IsNullOrEmpty(_oCompanySearchCriteria.CommoditySearchType))
            {
                SetListDefaultValue(rblCommoditySearchType, _oCompanySearchCriteria.CommoditySearchType);
            }

            // Commodities
            if (!string.IsNullOrEmpty(_oCompanySearchCriteria.CommodityIDs))
            {
                string f = $"mulSel_filldata('commodity-mulSel', \"{_oCompanySearchCriteria.CommodityIDs}\");";
                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "scriptCommodity", "$(document).ready(function() { " + f + "});", true);
            }

            // Growing Method
            SetListDefaultValue(rblGrowingMethod, _oCompanySearchCriteria.CommodityGMAttributeID);

            if (_oCompanySearchCriteria.IncludeLocalSource == "LSO")
            {
                foreach (ListItem listItem in rblGrowingMethod.Items)
                {
                    if (listItem.Value == "24")
                    {
                        listItem.Enabled = false;
                        listItem.Selected = false;
                    }
                }
            }

            // Attributes
            #endregion
            #region "Classifications"
            cbSalvageDistressedProduce.Checked = _oCompanySearchCriteria.SalvageDistressedProduce;

            // Classification Search Type
            if (!string.IsNullOrEmpty(_oCompanySearchCriteria.ClassificationSearchType))
            {
                SetListDefaultValue(rblClassSearchType, _oCompanySearchCriteria.ClassificationSearchType);
            }

            // Classification Search Type
            if (!string.IsNullOrEmpty(_oCompanySearchCriteria.ClassificationSearchType))
            {
                SetListDefaultValue(rblClassSearchType, _oCompanySearchCriteria.ClassificationSearchType);
            }

            // Classifications
            string[] aszClassifications = UIUtils.GetString(_oCompanySearchCriteria.ClassificationIDs).Split(CompanySearchBase.achDelimiter);
            SetTableValues_Bootstrap(aszClassifications, pnlProduceClass, PREFIX_CLASS, _oUser.HasPrivilege(SecurityMgr.Privilege.CompanySearchByClassifications).HasPrivilege, false, false);
            SetTableValues_Bootstrap(aszClassifications, pnlTransportationClass, PREFIX_CLASS, _oUser.HasPrivilege(SecurityMgr.Privilege.CompanySearchByClassifications).HasPrivilege, false, false);
            SetTableValues_Bootstrap(aszClassifications, pnlSupplyClass, PREFIX_CLASS, _oUser.HasPrivilege(SecurityMgr.Privilege.CompanySearchByClassifications).HasPrivilege, false, false);
            SetTableValues_Bootstrap(aszClassifications, pnlLumberClass, PREFIX_CLASS, _oUser.HasPrivilege(SecurityMgr.Privilege.CompanySearchByClassifications).HasPrivilege, false, false);

            // Number of Retail Stores
            string[] aszNumOfRetailStores = UIUtils.GetString(_oCompanySearchCriteria.NumberOfRetailStores).Split(CompanySearchBase.achDelimiter);
            foreach (string szNumOfRetailStores in aszNumOfRetailStores)
            {
                if (!string.IsNullOrEmpty(szNumOfRetailStores))
                {
                    foreach (ListItem oItem in cblNumOfRetail.Items)
                    {
                        if (szNumOfRetailStores == oItem.Value)
                            oItem.Selected = true;
                    }
                }
            }
            if (!string.IsNullOrEmpty(_oCompanySearchCriteria.NumberOfRetailStores))
            {
                string rs = $"checkboxes_filldata('{cblNumOfRetail.ClientID}', \"{_oCompanySearchCriteria.NumberOfRetailStores}\"); Update_UpdatePanel();";
                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "scriptRetailStores", "$(document).ready(function() { " + rs + "});", true);
            }

            // Number of Restaurant Stores
            string[] aszNumOfRestaurantStores = UIUtils.GetString(_oCompanySearchCriteria.NumberOfRestaurantStores).Split(CompanySearchBase.achDelimiter);
            foreach (string szNumOfRestaurantStores in aszNumOfRestaurantStores)
            {
                if (!string.IsNullOrEmpty(szNumOfRestaurantStores))
                {
                    foreach (ListItem oItem in cblNumOfRestaurants.Items)
                    {
                        if (szNumOfRestaurantStores == oItem.Value)
                            oItem.Selected = true;
                    }
                }
            }
            if (!string.IsNullOrEmpty(_oCompanySearchCriteria.NumberOfRestaurantStores))
            {
                string rs = $"checkboxes_filldata('{cblNumOfRestaurants.ClientID}', \"{_oCompanySearchCriteria.NumberOfRestaurantStores}\"); Update_UpdatePanel();";
                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "scriptRestStores", "$(document).ready(function() { " + rs + "});", true);
            }

            if (_oCompanySearchCriteria.IncludeLocalSource == "ELS")
            {
                CheckGrowerIncludeLSS.Value = "Y";
            }

            // Classifications
            if (!string.IsNullOrEmpty(_oCompanySearchCriteria.ClassificationIDs))
            {
                string f = "";

                if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                {
                    f = $"checkboxes_filldata('{pnlLumberClass.ClientID}', \"{_oCompanySearchCriteria.ClassificationIDs}\"); Update_UpdatePanel();";
                }
                else
                {

                    switch (_oCompanySearchCriteria.IndustryType)
                    {
                        case GeneralDataMgr.INDUSTRY_TYPE_PRODUCE:
                            f = $"checkboxes_filldata('{pnlProduceClass.ClientID}', \"{_oCompanySearchCriteria.ClassificationIDs}\"); Update_UpdatePanel();";
                            break;
                        case GeneralDataMgr.INDUSTRY_TYPE_TRANSPORTATION:
                            f = $"checkboxes_filldata('{pnlTransportationClass.ClientID}', \"{_oCompanySearchCriteria.ClassificationIDs}\"); Update_UpdatePanel();";
                            break;
                        case GeneralDataMgr.INDUSTRY_TYPE_SUPPLY:
                            f = $"checkboxes_filldata('{pnlSupplyClass.ClientID}', \"{_oCompanySearchCriteria.ClassificationIDs}\"); Update_UpdatePanel();";
                            break;
                    }
                }

                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "scriptClassification", "$(document).ready(function() { " + f + "});", true);
            }

            #endregion
            #region "Licenses and Certifications"
            SetListValues(cblLicenseType, _oCompanySearchCriteria.LicenseTypes);
            txtBrands.Text = UIUtils.GetString(_oCompanySearchCriteria.Brands);
            txtMiscListingInfo.Text = UIUtils.GetString(_oCompanySearchCriteria.DescriptiveLines);

            //Volume
            //string[] aszVolumes = UIUtils.GetString(_oCompanySearchCriteria.Volume).Split(achDelimiter);
            if (!string.IsNullOrEmpty(_oCompanySearchCriteria.VolumeMin))
                SetListDefaultValue(ddlVolume_Min, _oCompanySearchCriteria.VolumeMin);
            if (!string.IsNullOrEmpty(_oCompanySearchCriteria.VolumeMax))
                SetListDefaultValue(ddlVolume_Max, _oCompanySearchCriteria.VolumeMax);


            string[] aszFTEmployees = UIUtils.GetString(_oCompanySearchCriteria.FullTimeEmployeeCodes).Split(achDelimiter);
            //SetTableValues(aszFTEmployees, tblFTEmployees, PREFIX_LUMBER_FT_EMPLOYEE, _oUser.HasPrivilege(SecurityMgr.Privilege.CompanySearchByFTEmployees).HasPrivilege);

            cbOrganic.Checked = _oCompanySearchCriteria.Organic;
            cbFoodSafety.Checked = _oCompanySearchCriteria.FoodSafetyCertified;
            #endregion

            #region "Local Source"
            SetListDefaultValue(ddlIncludeLocalSource, _oCompanySearchCriteria.IncludeLocalSource);
            cbCertifiedOrganic.Checked = _oCompanySearchCriteria.CertifiedOrganic;
            SetListValues(cblAlsoOperates, _oCompanySearchCriteria.AlsoOperates);

            string[] aszTotalAcres = UIUtils.GetString(_oCompanySearchCriteria.TotalAcres).Split(achDelimiter);
            SetTableValues_Bootstrap(aszTotalAcres, phTotalAcres, PREFIX_TOTAL_ACRES, _oUser.HasPrivilege(SecurityMgr.Privilege.LocalSourceDataAccess).HasPrivilege);
            #endregion

            #region "Custom Filters"
            // Company Has Notes
            chkCompanyHasNotes.Checked = _oCompanySearchCriteria.HasNotes;

            // Watchdog Lists
            PopulateUserLists(gvUserList);

            #endregion

            #region "Internal Criteria"
            SetListValues(cblSalesTerritory, _oCompanySearchCriteria.SalesTerritories);
            SetListValues(ddlTerritoryCode, _oCompanySearchCriteria.TerritoryCode);

            ddlMembershipTypeCode.SelectedValue = _oCompanySearchCriteria.MemberTypeCode;
            SetListValues(cblPrimaryService, _oCompanySearchCriteria.PrimaryServiceCodes);

            SetIntValue(_oCompanySearchCriteria.ActiveLicenses, txtActiveLicense);
            SetListValues(ddlActiveLicenseSearchType, _oCompanySearchCriteria.ActiveLicenseSearchType);

            SetIntValue(_oCompanySearchCriteria.NumberLicenses, txtAvailLicense);
            SetListValues(ddlAvailLicenseSearchType, _oCompanySearchCriteria.NumberLicenseSearchType);

            cbReceivesPromoEmails.Checked = _oCompanySearchCriteria.ReceivesPromoEmails;
            cbReceivesPromoFaxes.Checked = _oCompanySearchCriteria.ReceivesPromoFaxes;

            SetIntValue(_oCompanySearchCriteria.AvailableUnits, txtAvailableUnits);
            SetListValues(ddlAvailableUnitsSearchType, _oCompanySearchCriteria.AvailableUnitsSearchType);

            SetIntValue(_oCompanySearchCriteria.UsedUnits, txtUsedUnits);
            SetListValues(ddlUsedUnitsSearchType, _oCompanySearchCriteria.UsedUnitsSearchType);

            SetDecimalValue(_oCompanySearchCriteria.MembershipRevenue, txtMembershipRevenue);
            SetListValues(ddlMembershipRevenueSearchType, _oCompanySearchCriteria.MembershipRevenueSearchType);

            SetDecimalValue(_oCompanySearchCriteria.AdvertisingRevenue, txtAdvertisingRevenue);
            SetListValues(ddlAdvertisingRevenueSearchType, _oCompanySearchCriteria.AdvertisingRevenueSearchType);
            #endregion

            //spot PopulateForm()
        }

        private void SetIntValue(int value, TextBox textBox)
        {
            if (value == -1)
            {
                textBox.Text = string.Empty;
            }
            else
            {
                textBox.Text = UIUtils.GetStringFromInt(value, false);
            }
        }

        private void SetDecimalValue(decimal value, TextBox textBox)
        {
            if (value == -1)
            {
                textBox.Text = string.Empty;
            }
            else
            {
                textBox.Text = UIUtils.GetStringFromDecimal(value, false);
            }
        }

        protected void RegisterDocReadyScriptBlock(string szScriptName, string szScript)
        {
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), szScriptName, "$(document).ready(function() { " + szScript + "});", true);
        }

        protected void ProcessClearCriteria()
        {
            if(!string.IsNullOrEmpty(hidClearCriteria.Value ))
            {
                switch(hidClearCriteria.Value)
                {
                    case "attributes":
                        _oCompanySearchCriteria.CommodityAttributeID = 0;
                        _oCompanySearchCriteria.CommodityGMAttributeID = 0;
                        break;
                }
                hidClearCriteria.Value = "";
            }
        }

        /// <summary>
        /// Used to show/hide form elements based on the current page
        /// settings
        /// </summary>
        protected void SetVisibility()
        {
            #region "Rating"
            // If the Produce or Transportation industry type is not selected,
            // do not display the ratings search form and discard any selected criteria.
            if (_oCompanySearchCriteria.IndustryType == GeneralDataMgr.INDUSTRY_TYPE_SUPPLY)
            {
                pnlRatingForm.Visible = false;
                _oCompanySearchCriteria.MemberYear = 0;
                _oCompanySearchCriteria.MemberYearSearchType = "";
                _oCompanySearchCriteria.BBScoreSearchType = "";
                _oCompanySearchCriteria.BBScore = 0;
                _oCompanySearchCriteria.RatingIntegrityIDs = "";
                _oCompanySearchCriteria.RatingPayIDs = "";
                _oCompanySearchCriteria.RatingCreditWorthIDs = "";
                _oCompanySearchCriteria.RatingCreditWorthMinID = "";
                _oCompanySearchCriteria.RatingCreditWorthMaxID = "";
                _oCompanySearchCriteria.PayIndicator = "";
            }
            else
                pnlRatingForm.Visible = true;

            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                pnlCreditWorthRating.Visible = false;

                //trPayRating.Visible = false;
                //trMembershipYear.Visible = false;
                trIntegrityRating.Visible = false;
            }
            else
            {
                pnlCreditWorthRating_L.Visible = false;

                //trPayReportCount.Visible = false;
                //trPayIndicator.Visible = false;
            }
            #endregion
            #region "Location"
            // Only show terminal markets if Produce or Transportation or Supply is selected as the industry type
            if((_oCompanySearchCriteria.IndustryType != GeneralDataMgr.INDUSTRY_TYPE_PRODUCE) &&
                (_oCompanySearchCriteria.IndustryType != GeneralDataMgr.INDUSTRY_TYPE_TRANSPORTATION) &&
                (_oCompanySearchCriteria.IndustryType != GeneralDataMgr.INDUSTRY_TYPE_SUPPLY))
            {
                pnlTerminalMarkets.Visible = false;
            }

            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                pnlRadius.Visible = false;
            }
            #endregion
            #region "Commodity"
            // If the Produce industry type is not selected, do not display the
            // commodities and discard any selected criteria.
            if (_oCompanySearchCriteria.IndustryType != GeneralDataMgr.INDUSTRY_TYPE_PRODUCE)
            {
                pnlCommodityForm.Visible = false;
                pnlExpandedContents.Visible = false;
                pnlCommodityList.Visible = false;
                _oCompanySearchCriteria.CommodityIDs = "";
                _oCompanySearchCriteria.CommodityGMAttributeID = 0;
                _oCompanySearchCriteria.CommodityAttributeID = 0;
                _oCompanySearchCriteria.ClassificationSearchType = "";
            }
            else
            {
                pnlCommodityForm.Visible = true;
                pnlExpandedContents.Visible = true;
                pnlCommodityList.Visible = true;
            }

            if (HasPrivilege_ITA_Always_True(SecurityMgr.Privilege.CompanySearchByCommodities))
                btnSearch.Enabled = true;
            else
                btnSearch.Enabled = false;
            #endregion
            #region "Classifications"
            ApplySecurity(cbSalvageDistressedProduce, SecurityMgr.Privilege.CompanySearchBySalvageDistressedProduce);

            // Determine what classification tables to show based on the
            // Industry type selected
            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                pnlProduceClass.Visible = false;
                pnlTransportationClass.Visible = false;
                pnlSupplyClass.Visible = false;
                pnlLumberClass.Visible = true;
                setPanelVisibility_TW(pnlNumberOfStores, true);
            }
            else
            {
                switch (_oCompanySearchCriteria.IndustryType)
                {
                    case GeneralDataMgr.INDUSTRY_TYPE_PRODUCE:
                        pnlProduceClass.Visible = true;
                        pnlTransportationClass.Visible = false;
                        pnlSupplyClass.Visible = false;
                        setPanelVisibility_TW(pnlNumberOfStores, true);
                        pnlLumberClass.Visible = false;
                        break;
                    case GeneralDataMgr.INDUSTRY_TYPE_TRANSPORTATION:
                        pnlProduceClass.Visible = false;
                        pnlTransportationClass.Visible = true;
                        pnlSupplyClass.Visible = false;
                        setPanelVisibility_TW(pnlNumberOfStores, false);
                        pnlLumberClass.Visible = false;

                        //Defect 7295
                        pnlRejectedShipments.Visible = false;
                        pnlCertifiedOrganic.Visible = false;
                        pnlBrands.Visible = false;

                        break;
                    case GeneralDataMgr.INDUSTRY_TYPE_SUPPLY:
                        pnlProduceClass.Visible = false;
                        pnlTransportationClass.Visible = false;
                        pnlSupplyClass.Visible = true;
                        setPanelVisibility_TW(pnlNumberOfStores, false);
                        pnlLumberClass.Visible = false;
                        break;
                }
            }

            // Enable Number of Retail Stores if retail classification is selected
            setPanelVisibility_TW(pnlNumberOfStores, false); //only make visible later if Retail or Restaurant is chosen

            if (!string.IsNullOrEmpty(_oCompanySearchCriteria.ClassificationIDs))
            {
                if ((_oCompanySearchCriteria.ClassificationIDs.Contains(CLASSIFICATION_ID_RETAIL)) ||
                    (_oCompanySearchCriteria.ClassificationIDs.Contains(CLASSIFICATION_ID_RETAIL_YARD_DEALER)))
                {
                    setPanelVisibility_TW(pnlNumberOfStores, true);
                    lblRetailStores.Enabled = true;
                    setEnabled_TW(fsNumOfRetail, true);
                }
                else
                {
                    lblRetailStores.Enabled = false;
                    cblNumOfRetail.SelectedIndex = -1;
                    setEnabled_TW(fsNumOfRetail, false);
                    _oCompanySearchCriteria.NumberOfRetailStores = "";
                }
            }
            else
            {
                lblRetailStores.Enabled = false;
                cblNumOfRetail.SelectedIndex = -1;
                setEnabled_TW(fsNumOfRetail, false);
                _oCompanySearchCriteria.NumberOfRetailStores = "";
            }

            // Enable Number of Restaurant Stores if restaurant classification is selected
            if (!string.IsNullOrEmpty(_oCompanySearchCriteria.ClassificationIDs))
            {
                if (_oCompanySearchCriteria.ClassificationIDs.Contains(CLASSIFICATION_ID_RESTAURANT))
                {
                    setPanelVisibility_TW(pnlNumberOfStores, true);
                    lblRestaurantStores.Enabled = true;
                    setEnabled_TW(fsNumOfRestaurant, true);
                }
                else
                {
                    lblRestaurantStores.Enabled = false;
                    cblNumOfRestaurants.SelectedIndex = -1;
                    setEnabled_TW(fsNumOfRestaurant, false);
                    _oCompanySearchCriteria.NumberOfRestaurantStores = "";
                }
            }
            else
            {
                lblRestaurantStores.Enabled = false;
                cblNumOfRestaurants.SelectedIndex = -1;
                setEnabled_TW(fsNumOfRestaurant, false);
                _oCompanySearchCriteria.NumberOfRestaurantStores = "";
            }


            // If a Level 1 classification has been selected, disable only and all search types and
            // default the search type to any.  This applies only to Produce classifications.  Trans and
            // Supply industry types do not have selectable top level items.
            bool blnAnyLevel1Checked = false;

            foreach (CheckBox oCheckBox in pnlProduceClass.FindDescendants<CheckBox>())
            {
                if (oCheckBox.Checked && oCheckBox.InputAttributes["ParentID"] == null)
                {
                    blnAnyLevel1Checked = true;
                }
            }

            if (blnAnyLevel1Checked)
            {
                _oCompanySearchCriteria.ClassificationSearchType = CompanySearchBase.CODE_SEARCH_TYPE_ANY;
                rblClassSearchType.SelectedIndex = 0;

                rblClassSearchType.Items[1].Enabled = false;
            }
            else
            {
                rblClassSearchType.Items[1].Enabled = true;
            }
            #endregion


            #region "Licenses and Certifications"
            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                //pnlIndustryType.Visible = false; //defect 5698 disabled for lumber

                // License Type
                //lblLicenseType.Visible = false;
                cblLicenseType.Visible = false;
                //lblLTDefinitions.Visible = false;

                //lblVolumeText.Text = Resources.Global.LumberVolumeText;

                trCertifications.Visible = false;
                trLicenseType.Visible = false;
                return;
            }

            //trFTEmployees.Visible = false;

            // If the Supply and Service industry type is selected,
            // disable the License Type, License Number, Corporate Structure, and
            // volume search elements
            if (_oCompanySearchCriteria.IndustryType == GeneralDataMgr.INDUSTRY_TYPE_SUPPLY)
            {
                // License Type
                //lblLicenseType.Enabled = false;
                cblLicenseType.Enabled = false;

                // Volume
                //pnlVolumeLinks.Enabled = false;
                //DisableTableControls(tblVolume);

                // defect 7305 : hide : Handle rejected shipment, Certifications, Licenses and Volume
                pnlRejectedShipments.Visible = false;
                trCertifications.Visible = false;
                trLicenseType.Visible = false;
                trVolume.Visible = false;

                licensesCertificationLabel.InnerText = Resources.Global.Brands + " & " + Resources.Global.MiscListingInfo2;
                licensesCertificationCaption.InnerText = "";
            }
            else
            {
                licensesCertificationLabel.InnerText = Resources.Global.LicensesAndCertsProfile;
                licensesCertificationCaption.InnerText = Resources.Global.LicensesAndCertsProfileCaption;

                txtBrands.Enabled = _oUser.HasPrivilege(SecurityMgr.Privilege.CompanySearchByBrand).HasPrivilege;

                //lblLicenseType.Enabled = _oUser.HasPrivilege(SecurityMgr.Privilege.CompanySearchByLicense).HasPrivilege;
                //cblLicenseType.Enabled = lblLicenseType.Enabled;

                if (_oUser.HasPrivilege(SecurityMgr.Privilege.CompanySearchByVolume).HasPrivilege)
                {
                    // a little overkill here, but won't hurt anything
                    //pnlVolumeLinks.Enabled = true;
                    //EnableTableControls(tblVolume);
                }
                else
                {
                    //pnlVolumeLinks.Enabled = false;
                    //DisableTableControls(tblVolume);
                }
            }
            #endregion

            #region "Internal Criteria"
            if (IsPRCoUser())
                pnlInternalCriteriaForm.Visible = true;
            else
                pnlInternalCriteriaForm.Visible = false;
            #endregion

            //Spot SetVisibility()
            #region "Local Source"
            // If anything other than Produce is selected, disable the controls
            if (_oCompanySearchCriteria.IndustryType != GeneralDataMgr.INDUSTRY_TYPE_PRODUCE)
            {
                ddlIncludeLocalSource.Enabled = true;
                cbCertifiedOrganic.Disabled = true;
                cblAlsoOperates.Enabled = false;
            }
            else
            {
                cbCertifiedOrganic.Disabled = false;
                cblAlsoOperates.Enabled = true;
            }
            #endregion
        }

        protected void PopulateCustomFields()
        {
            if (!_oUser.HasPrivilege(SecurityMgr.Privilege.CustomFields).HasPrivilege)
            {
                return;
            }

            IBusinessObjectSet customFields = new PRWebUserCustomFieldMgr(_oLogger, _oUser).GetByHQ(_oUser.prwu_HQID);
            repCustomFields.DataSource = customFields;
            repCustomFields.DataBind();
        }

        private void SelectIndustryClass()
        {
            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                btnLumber.Visible = true;
                btnProduce.Visible = false;
                btnSupply.Visible = false;
                btnTransport.Visible = false;
                _oCompanySearchCriteria.IndustryType = GeneralDataMgr.INDUSTRY_TYPE_LUMBER;
            }
            else
            {
                btnLumber.Visible = false;
                btnProduce.Visible = true;
                btnSupply.Visible = true;
                btnTransport.Visible = true;
                if (_oCompanySearchCriteria.IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                    _oCompanySearchCriteria.IndustryType = _oUser.prwu_IndustryType; //default if switching from lumber due to QA impersonate
            }

            btnProduce.CssClass = btnProduce.CssClass.Replace("selected", "");
            btnTransport.CssClass = btnTransport.CssClass.Replace("selected", "");
            btnSupply.CssClass = btnSupply.CssClass.Replace("selected", "");
            btnLumber.CssClass = btnLumber.CssClass.Replace("selected", "");

            switch (_oCompanySearchCriteria.IndustryType)
            {
                case GeneralDataMgr.INDUSTRY_TYPE_PRODUCE:
                    btnProduce.CssClass += " selected";
                    litHeader.Text = Resources.Global.SearchProduceCompanies;
                    break;
                case GeneralDataMgr.INDUSTRY_TYPE_SUPPLY:
                    btnSupply.CssClass += " selected";
                    litHeader.Text = Resources.Global.SearchSupplyCompanies;
                    break;
                case GeneralDataMgr.INDUSTRY_TYPE_TRANSPORTATION:
                    btnTransport.CssClass += " selected";
                    litHeader.Text = Resources.Global.SearchTransportationCompanies;
                    break;
                case GeneralDataMgr.INDUSTRY_TYPE_LUMBER:
                    btnLumber.CssClass += " selected";
                    litHeader.Text = Resources.Global.SearchLumberCompanies;
                    break;
            }
        }

        /// <summary>
        /// Collects and stores the search criteria on the users current company search
        /// criteria object
        /// </summary>
        protected override void StoreCriteria()
        {
            #region "Company Details"
            //NewListings
            _oCompanySearchCriteria.NewListingOnly = chkNewListingsOnly.Checked;
            if (!string.IsNullOrEmpty(ddlNewListingRange.SelectedValue))
                _oCompanySearchCriteria.NewListingDaysOld = Convert.ToInt32(ddlNewListingRange.SelectedValue);
            else
                _oCompanySearchCriteria.NewListingDaysOld = 0;

            // Company Name
            _oCompanySearchCriteria.CompanyName = txtCompanyName.Text.Trim();

            // CompanyType, Listing Status
            _oCompanySearchCriteria.CompanyType = rblCompanyType.SelectedValue;
            _oCompanySearchCriteria.ListingStatus = ddlListingStatus.SelectedValue;

            // CompanyPhone
            _oCompanySearchCriteria.PhoneNumber = txtPhoneNumber.Text.Trim();

            // Must have phone number
            _oCompanySearchCriteria.PhoneNotNull = chkPhoneNotNull.Checked;

            //Email
            _oCompanySearchCriteria.Email = txtEmail.Text.Trim();
            _oCompanySearchCriteria.EmailNotNull = chkEmailNotNull.Checked;
            #endregion
            #region "Rating"

            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                //TODO:JMT LUMBER implement Lumber rating StoreCriteria()
                //_oCompanySearchCriteria.PayReportCountSearchType = ddlPayReportCountSearchType.SelectedValue;
                //if (txtPayReportCount.Text.Length > 0)
                //_oCompanySearchCriteria.PayReportCount = Convert.ToInt32(txtPayReportCount.Text);
                //else
                //_oCompanySearchCriteria.PayReportCount = -1; // Magic Number

                _oCompanySearchCriteria.RatingCreditWorthMinID = ddlCreditWorthRating_Min_L.SelectedValue;
                _oCompanySearchCriteria.RatingCreditWorthMaxID = ddlCreditWorthRating_Max_L.SelectedValue;

                //_oCompanySearchCriteria.PayIndicator = GetTableValues(tblPayIndicator, PREFIX_PAYINDICATOR);
            }
            else
            {
                _oCompanySearchCriteria.IsTMFM = chkTMFMNotNull.Checked;

                _oCompanySearchCriteria.RatingIntegrityIDs = GetPlaceholderValues(phIntegrityRating, PREFIX_INTEGRITYRATING);
                _oCompanySearchCriteria.RatingPayIDs = GetPlaceholderValues(phPayDescription, PREFIX_PAYDESCRIPTION);

                _oCompanySearchCriteria.RatingCreditWorthMinID = ddlCreditWorthRating_Min.SelectedValue;
                _oCompanySearchCriteria.RatingCreditWorthMaxID = ddlCreditWorthRating_Max.SelectedValue;
            }

            // BBScore
            if (txtBBScore.Text.Length > 0)
                _oCompanySearchCriteria.BBScore = Convert.ToInt32(txtBBScore.Text);
            else
                _oCompanySearchCriteria.BBScore = 0;
            _oCompanySearchCriteria.BBScoreSearchType = ddlBBScoreSearchType.SelectedValue;
            #endregion
            #region "Location"
            // Listing Country
            _oCompanySearchCriteria.ListingCountryIDs = string.Empty;
            _oCompanySearchCriteria.ListingCountryIDs = addValue(_oCompanySearchCriteria.ListingCountryIDs, radio_country_usa);
            _oCompanySearchCriteria.ListingCountryIDs = addValue(_oCompanySearchCriteria.ListingCountryIDs, radio_country_canada);
            _oCompanySearchCriteria.ListingCountryIDs = addValue(_oCompanySearchCriteria.ListingCountryIDs, radio_country_mexico);
            _oCompanySearchCriteria.ListingCountryIDs = addValue(_oCompanySearchCriteria.ListingCountryIDs, hidOtherCountries.Value);

            // Listing State
            _oCompanySearchCriteria.ListingStateIDs = "";
            _oCompanySearchCriteria.ListingStateIDs = addValue(_oCompanySearchCriteria.ListingStateIDs, hidSelectedStates.Value);

            // City Name
            _oCompanySearchCriteria.ListingCity = txtListingCity.Text.Trim();

            // Terminal Markets
            _oCompanySearchCriteria.TerminalMarketIDs = "";
            _oCompanySearchCriteria.TerminalMarketIDs = addValue(_oCompanySearchCriteria.TerminalMarketIDs, hidTerminalMarkets.Value);

            // Listing Postal Code
            if (!string.IsNullOrEmpty(txtZipCode.Value.Trim()))
            {
                _oCompanySearchCriteria.ListingPostalCode = txtZipCode.Value;
                // This search type is only valid with radius, so if the user has not
                // entered a value radius value, then default one
                if (txtRadius.Value.Length == 0)
                    txtRadius.Value = "0";
            }
            else
            {
                _oCompanySearchCriteria.ListingPostalCode = "";
            }

            // Within Radius - NOTE: 0 is a valid radius value
            if (txtRadius.Value.Trim().Length == 0)
            {
                _oCompanySearchCriteria.Radius = -1;
            }
            else
            {
                int intValue;
                if (int.TryParse(txtRadius.Value, out intValue) && intValue >= 0)
                    _oCompanySearchCriteria.Radius = intValue;
                else
                    _oCompanySearchCriteria.Radius = -1;
            }

            // Radius Search Type
            if (zipcode_distance.Checked)
                _oCompanySearchCriteria.RadiusType = zipcode_distance.Value;
            else if(terminal_market_distance.Checked)
                _oCompanySearchCriteria.RadiusType = terminal_market_distance.Value;

            #endregion
            #region "Commodity"
            // Commodity Search Type
            _oCompanySearchCriteria.CommoditySearchType = rblCommoditySearchType.SelectedValue;

            //Commodities
            _oCompanySearchCriteria.CommodityIDs = hidCommodities.Value;

            // Growing Method
            _oCompanySearchCriteria.CommodityGMAttributeID = 0;
            if (!(rblGrowingMethod.SelectedIndex < 0))
                _oCompanySearchCriteria.CommodityGMAttributeID = Convert.ToInt32(rblGrowingMethod.SelectedValue);

            //Attribute
            if (hidAttributes.Value != "")
                _oCompanySearchCriteria.CommodityAttributeID = Convert.ToInt32(hidAttributes.Value);

            #endregion
            #region "Classifications"
            _oCompanySearchCriteria.SalvageDistressedProduce = cbSalvageDistressedProduce.Checked;
            _oCompanySearchCriteria.ClassificationSearchType = rblClassSearchType.SelectedValue;
            _oCompanySearchCriteria.ClassificationIDs = hidClassifications.Value;

            // Number of Retail Stores
            StringBuilder sbNumOfRetailStores = new StringBuilder();

            foreach (ListItem oListItem in cblNumOfRetail.Items)
            {
                if (oListItem.Selected)
                {
                    AddDelimitedValue(sbNumOfRetailStores, oListItem.Value);
                }
            }

            _oCompanySearchCriteria.NumberOfRetailStores = sbNumOfRetailStores.ToString();

            //// Number of Restaurant Stores
            StringBuilder sbNumOfRestaurantStores = new StringBuilder();

            foreach (ListItem oListItem in cblNumOfRestaurants.Items)
            {
                if (oListItem.Selected)
                {
                    AddDelimitedValue(sbNumOfRestaurantStores, oListItem.Value);
                }
            }

            _oCompanySearchCriteria.NumberOfRestaurantStores = sbNumOfRestaurantStores.ToString();

            if (GrowerIncludeLSS.Value == "Y")
            {
                _oCompanySearchCriteria.IncludeLocalSource = "ILS";
            }
            #endregion
            #region "Licenses and Certifications"

            _oCompanySearchCriteria.LicenseTypes = GetSelectedValues(cblLicenseType);
            _oCompanySearchCriteria.Brands = txtBrands.Text.Trim();
            _oCompanySearchCriteria.DescriptiveLines = txtMiscListingInfo.Text.Trim();

            _oCompanySearchCriteria.VolumeMin = ddlVolume_Min.SelectedValue;
            _oCompanySearchCriteria.VolumeMax = ddlVolume_Max.SelectedValue;

            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                //_oCompanySearchCriteria.FullTimeEmployeeCodes = GetTableValues(tblFTEmployees, PREFIX_LUMBER_FT_EMPLOYEE);
            }

            _oCompanySearchCriteria.Organic = cbOrganic.Checked;
            _oCompanySearchCriteria.FoodSafetyCertified = cbFoodSafety.Checked;
            #endregion

            #region "Local Source"
            if (_oUser.HasPrivilege(SecurityMgr.Privilege.LocalSourceDataAccess).HasPrivilege)
            {
                _oCompanySearchCriteria.IncludeLocalSource = ddlIncludeLocalSource.SelectedValue;
                _oCompanySearchCriteria.AlsoOperates = GetSelectedValues(cblAlsoOperates);
                _oCompanySearchCriteria.TotalAcres = GetCheckboxValues_Bootstrap(phTotalAcres, PREFIX_TOTAL_ACRES);
                _oCompanySearchCriteria.CertifiedOrganic = cbCertifiedOrganic.Checked;
            }
            #endregion

            #region "Custom Filters"
            // Company Has Notes
            _oCompanySearchCriteria.HasNotes = chkCompanyHasNotes.Checked;

            // Store User List selections
            if (!bResetUserList)
            {
                _oCompanySearchCriteria.UserListIDs = GetRequestParameter("cbUserListID", false);
            }

            if (_oCompanySearchCriteria.CustomFieldSearchCriteria != null)
            {
                _oCompanySearchCriteria.CustomFieldSearchCriteria.Clear();
            }

            if (!bResetCustomFields)
            {
                IBusinessObjectSet customFields = new PRWebUserCustomFieldMgr(_oLogger, _oUser).GetByHQ(_oUser.prwu_HQID);
                foreach (IPRWebUserCustomField customField in customFields)
                {
                    CheckBox cbControl = (CheckBox)FindControlRecursive(this, "cbCustomDataField_" + customField.prwucf_WebUserCustomFieldID.ToString());
                    if ((cbControl != null) &&
                        (cbControl.Checked))
                    {
                        _oCompanySearchCriteria.AddCustomFieldSearchCriteria(customField.prwucf_WebUserCustomFieldID, true);
                    }

                    if (customField.prwucf_FieldTypeCode == "Text")
                    {
                        TextBox textControl = (TextBox)FindControlRecursive(this, "CustomDataField_" + customField.prwucf_WebUserCustomFieldID.ToString());

                        if ((cbControl != null) &&
                            (cbControl.Checked))
                        {
                            textControl.Enabled = false;
                        }
                        else
                        {
                            if (textControl != null && !string.IsNullOrEmpty(textControl.Text))
                            {
                                _oCompanySearchCriteria.AddCustomFieldSearchCriteria(customField.prwucf_WebUserCustomFieldID, textControl.Text);
                            }
                        }
                    }

                    if ((customField.prwucf_FieldTypeCode == "DDL") &&
                        (customField.GetLookupValues().Count > 0))
                    {
                        DropDownList ddlControl = (DropDownList)FindControlRecursive(this, "CustomDataField_" + customField.prwucf_WebUserCustomFieldID.ToString());

                        if (ddlControl != null)
                        {
                            if ((cbControl != null) &&
                                (cbControl.Checked))
                            {
                                ddlControl.Enabled = false;
                            }
                            else
                            {
                                if ((!string.IsNullOrEmpty(ddlControl.SelectedValue)) &&
                                    (ddlControl.SelectedValue != "0"))
                                {
                                    _oCompanySearchCriteria.AddCustomFieldSearchCriteria(customField.prwucf_WebUserCustomFieldID, Convert.ToInt32(ddlControl.SelectedValue));
                                }
                            }
                        }
                    }
                }
            }
            #endregion

            //Spot StoreCriteria()
            #region "Internal Criteria"
            _oCompanySearchCriteria.SalesTerritories = GetSelectedValues(cblSalesTerritory);
            _oCompanySearchCriteria.TerritoryCode = ddlTerritoryCode.SelectedValue;
            _oCompanySearchCriteria.MemberTypeCode = ddlMembershipTypeCode.SelectedValue;
            _oCompanySearchCriteria.PrimaryServiceCodes = GetSelectedValues(cblPrimaryService);

            _oCompanySearchCriteria.ActiveLicenses = GetIntValue(txtActiveLicense.Text);
            _oCompanySearchCriteria.ActiveLicenseSearchType = ddlActiveLicenseSearchType.SelectedValue;

            _oCompanySearchCriteria.NumberLicenses = GetIntValue(txtAvailLicense.Text);
            _oCompanySearchCriteria.NumberLicenseSearchType = ddlAvailLicenseSearchType.SelectedValue;

            _oCompanySearchCriteria.AvailableUnits = GetIntValue(txtAvailableUnits.Text);
            _oCompanySearchCriteria.AvailableUnitsSearchType = ddlAvailableUnitsSearchType.SelectedValue;

            _oCompanySearchCriteria.UsedUnits = GetIntValue(txtUsedUnits.Text);
            _oCompanySearchCriteria.UsedUnitsSearchType = ddlUsedUnitsSearchType.SelectedValue;

            _oCompanySearchCriteria.ReceivesPromoEmails = cbReceivesPromoEmails.Checked;
            _oCompanySearchCriteria.ReceivesPromoFaxes = cbReceivesPromoFaxes.Checked;

            _oCompanySearchCriteria.AdvertisingRevenue = GetDecimalValue(txtAdvertisingRevenue.Text);
            _oCompanySearchCriteria.AdvertisingRevenueSearchType = ddlAdvertisingRevenueSearchType.SelectedValue;

            _oCompanySearchCriteria.MembershipRevenue = GetDecimalValue(txtMembershipRevenue.Text);
            _oCompanySearchCriteria.MembershipRevenueSearchType = ddlMembershipRevenueSearchType.SelectedValue;
            #endregion

            base.StoreCriteria();
        }

        private int GetIntValue(string value)
        {
            if (value.Length > 0)
                return Convert.ToInt32(value);
            else
                return -1; // Magic Number
        }

        private decimal GetDecimalValue(string value)
        {
            if (value.Length > 0)
                return Convert.ToDecimal(value);
            else
                return -1; // Magic Number
        }

        /// <summary>
        /// Clears and stores the search criteria on the users current company search
        /// criteria object
        /// </summary>
        protected override void ClearCriteria()
        {
            // Clear the corresponding Search Criteria object and reload the page
            #region "Company Details"

            //NewListings
            chkNewListingsOnly.Checked = false;
            ddlNewListingRange.SelectedIndex = -1;

            // Company Name
            txtCompanyName.Text = "";

            // CompanyType, Listing Status
            rblCompanyType.SelectedIndex = -1;
            ddlListingStatus.SelectedIndex = -1;

            // CompanyPhone
            txtPhoneNumber.Text = "";

            // Phone Not Null
            chkPhoneNotNull.Checked = false;

            //CompanyEmail
            txtEmail.Text = "";
            chkEmailNotNull.Checked = false;
            #endregion
            #region "Rating"

            // Rating tab
            chkTMFMNotNull.Checked = false;

            // BB Score
            ddlBBScoreSearchType.SelectedIndex = -1;
            txtBBScore.Text = "";

            // Integrity/Ability Rating
            ClearPlaceholderValues(phIntegrityRating);

            // Pay Description
            ClearPlaceholderValues(phPayDescription);

            // Pay Indicator
            //ClearTableValues(tblPayIndicator); //TODO:JMT LUMBER rating ClearCriteria()

            // Credit Worth Rating
            ddlCreditWorthRating_Min.SelectedIndex = -1;
            ddlCreditWorthRating_Max.SelectedIndex = -1;
            ddlCreditWorthRating_Min_L.SelectedIndex = -1;
            ddlCreditWorthRating_Max_L.SelectedIndex = -1;

            //ddlPayReportCountSearchType.SelectedIndex = -1;
            //txtPayReportCount.Text = ""; //TODO:JMT LUMBER rating ClearCriteria()
            #endregion
            #region "Location"
            hidOtherCountries.Value = "";
            hidSelectedStates.Value = "";
            hidTerminalMarkets.Value = "";
            radio_country_usa.Checked = true;
            radio_country_canada.Checked = false;
            radio_country_mexico.Checked = false;
            radio_country_none.Checked = false;
            radio_country_other.Checked = false;
            txtCompanyName.Text = "";
            txtZipCode.Value = "";
            #endregion
            #region "Commodity"
            // Commodity Search Type
            rblCommoditySearchType.SelectedIndex = -1;
            // Growing Method
            rblGrowingMethod.SelectedIndex = -1;
            // Attributes
            hidAttributes.Value = "";
            #endregion
            #region "Classifications"
            cbSalvageDistressedProduce.Checked = false;

            // Classification Search Type
            rblClassSearchType.SelectedIndex = -1;

            // Classifications
            ClearTableValues_AllCheckboxes(pnlProduceClass);
            ClearTableValues_AllCheckboxes(pnlTransportationClass);
            ClearTableValues_AllCheckboxes(pnlSupplyClass);
            ClearTableValues_AllCheckboxes(pnlLumberClass);

            // Number of Retail Stores
            cblNumOfRetail.SelectedIndex = -1;

            // Number of Restaurant Stores
            cblNumOfRestaurants.SelectedIndex = -1;
            #endregion
            #region "Licenses and Certifications"
            // Clear the corresponding Company Search Criteria object and
            // reload the page
            cblLicenseType.SelectedIndex = -1;
            txtBrands.Text = "";
            txtMiscListingInfo.Text = "";
            ddlVolume_Min.SelectedIndex = -1;
            ddlVolume_Max.SelectedIndex = -1;

            //ClearTableValues(tblFTEmployees);
            cbOrganic.Checked = false;
            cbFoodSafety.Checked = false;
            #endregion

            #region "Local Source"
            ddlIncludeLocalSource.SelectedIndex = -1;
            cblAlsoOperates.SelectedIndex = -1;
            cbCertifiedOrganic.Checked = false;
            ClearTableValues_AllCheckboxes(phTotalAcres);
            #endregion

            #region "Custom Filters"
            // Has Notes
            chkCompanyHasNotes.Checked = false;

            // Clear User List selections
            bResetUserList = true;
            _oCompanySearchCriteria.UserListIDs = "";

            bResetCustomFields = true;
            if (_oCompanySearchCriteria.CustomFieldSearchCriteria != null)
            {
                _oCompanySearchCriteria.CustomFieldSearchCriteria.Clear();
            }
            #endregion

            //Spot ClearCriteria()
            #region "Internal Criteria"
            cblSalesTerritory.SelectedIndex = -1;
            ddlMembershipTypeCode.SelectedValue = string.Empty;
            cblPrimaryService.SelectedIndex = -1;
            txtActiveLicense.Text = string.Empty;
            ddlActiveLicenseSearchType.SelectedIndex = 0;

            txtAvailLicense.Text = string.Empty;
            ddlAvailLicenseSearchType.SelectedIndex = 0;

            txtAvailableUnits.Text = string.Empty;
            ddlAvailableUnitsSearchType.SelectedIndex = 0;

            txtUsedUnits.Text = string.Empty;
            ddlUsedUnitsSearchType.SelectedIndex = 0;

            txtMembershipRevenue.Text = string.Empty;
            ddlMembershipRevenueSearchType.SelectedIndex = 0;

            txtAdvertisingRevenue.Text = string.Empty;
            ddlAdvertisingRevenueSearchType.SelectedIndex = 0;

            cbReceivesPromoEmails.Checked = false;
            cbReceivesPromoFaxes.Checked = false;
            #endregion

            _szRedirectURL = PageConstants.ADVANCED_COMPANY_SEARCH;
        }

        /// <summary>
        /// Make sure our ToggleInitialState JS function gets
        /// called to set come control states appropriately.
        /// </summary>
        public override void PreparePageFooter()
        {
            base.PreparePageFooter();
        }

        private void SetApplicationMenu()
        {
            if (hlSavedSearches.Enabled)
                hlSavedSearches.NavigateUrl = PageConstants.SAVED_SEARCHES;

            if (hlCompanyUpdateSearch.Enabled)
                hlCompanyUpdateSearch.NavigateUrl = PageConstants.COMPANY_UPDATE_SEARCH;

            if (hlRecentViews.Enabled)
                hlRecentViews.NavigateUrl = PageConstants.RECENT_VIEWS;

            if (hlLastCompanySearch.Enabled)
                hlLastCompanySearch.NavigateUrl = PageConstants.COMPANY_SEARCH_RESULTS_EXECUTE_LAST;

            if (hlClaimActivitySearch.Enabled)
                hlClaimActivitySearch.NavigateUrl = PageConstants.CLAIMS_ACTIVITY_SEARCH;

            ApplySecurity(_oUser);
        }

        /// <summary>
        /// Disables menu options based on the specified user's
        /// security access and assigned roles.
        /// </summary>
        public void ApplySecurity(IPRWebUser webUser)
        {
            if (webUser == null)
            {
                return;
            }

            ApplySecurity(null, hlPersonSearch, SecurityMgr.Privilege.PersonSearchPage);
            ApplySecurity(null, hlCompanyUpdateSearch, SecurityMgr.Privilege.CompanyUpdatesSearchPage);
            ApplySecurity(null, hlSavedSearches, SecurityMgr.Privilege.SaveSearches);

            ApplySecurity(null, hlRecentViews, SecurityMgr.Privilege.RecentViewsPage);
            ApplySecurity(null, hlLastCompanySearch, SecurityMgr.Privilege.CompanySearchPage);

            if (webUser.IsLimitado)
            {
                //Override security application above and force Limitado into correct button enabling despite security privileges
                //so that applying 100 security / Limitado = true works properly
                hlSavedSearches.Visible = false;
            }

            if (webUser.prwu_LastCompanySearchID == 0)
            {
                hlLastCompanySearch.Enabled = false;
            }

            if ((webUser.prwu_PersonLinkID == 0) ||
                (webUser.prwu_BBID == 0))
            {
                //DisableMenuItem(hlSpecialServices);
            }

            //PageBase.ApplyReadOnlyCheck(hlCustomFields);

            //SetSubMenu()
            if (!_oUser.HasPrivilege(SecurityMgr.Privilege.CompanySearchPage).Visible)
                pnlCompanyDetailsForm.Visible = false;
            if (!_oUser.HasPrivilege(SecurityMgr.Privilege.CompanySearchRatingPage).Visible)
                pnlRatingForm.Visible = false;
            if (!_oUser.HasPrivilege(SecurityMgr.Privilege.CompanySearchLocationPage).Visible)
                pnlLocationForm.Visible = false;
            if (!HasPrivilege_ITA_Always_True(SecurityMgr.Privilege.CompanySearchCommoditiesPage))
                pnlCommodityForm.Visible = false;

            //TODO:LUMBER Specie
            //TODO:LUMBER Product
            //TODO:LUMBER Service

            if (!_oUser.HasPrivilege(SecurityMgr.Privilege.CompanySearchClassificationsPage).Visible)
                pnlClassificationForm.Visible = false;
            if (!_oUser.HasPrivilege(SecurityMgr.Privilege.CompanySearchProfilePage).Visible)
                pnlLicensesForm.Visible = false;
            if (!_oUser.HasPrivilege(SecurityMgr.Privilege.LocalSourceDataAccess).Visible)
                pnlLocalSourceForm.Visible = false;
            if (!_oUser.HasPrivilege(SecurityMgr.Privilege.CompanySearchCustomPage).Visible)
                pnlCustomFiltersForm.Visible = false;

            if (IsPRCoUser())
                pnlInternalCriteriaForm.Visible = true;
            else
                pnlInternalCriteriaForm.Visible = false;
        }

        protected void btnPersonSearchOnClick(object sender, EventArgs e)
        {
            Session["oWebUserSearchCriteria"] = null;
            Response.Redirect(PageConstants.PERSON_SEARCH);
        }

        protected void btnIndustry_Click(object sender, EventArgs e)
        {
            string szClientID = ((LinkButton)sender).ClientID.ToLower();
            if (szClientID.EndsWith("btnproduce"))
                _oCompanySearchCriteria.IndustryType = GeneralDataMgr.INDUSTRY_TYPE_PRODUCE;
            else if (szClientID.EndsWith("btntransport"))
                _oCompanySearchCriteria.IndustryType = GeneralDataMgr.INDUSTRY_TYPE_TRANSPORTATION;
            else if (szClientID.EndsWith("btnsupply"))
                _oCompanySearchCriteria.IndustryType = GeneralDataMgr.INDUSTRY_TYPE_SUPPLY;
            else if (szClientID.EndsWith("btnlumber"))
                _oCompanySearchCriteria.IndustryType = GeneralDataMgr.INDUSTRY_TYPE_LUMBER;
            else
                _oCompanySearchCriteria.IndustryType = "";

            Response.Redirect(Request.RawUrl); //force screen to refresh with new industry
        }

        protected void repCustomFields_ItemCreated(object sender, RepeaterItemEventArgs e)
        {
            Label space = new Label();
            space.Text = "&nbsp;";

            // Execute the following logic for Items and Alternating Items.
            if (e.Item.ItemType == ListItemType.Item ||
                e.Item.ItemType == ListItemType.AlternatingItem)
            {
                //Get the MyClass instance for this repeater item
                IPRWebUserCustomField customField = (IPRWebUserCustomField)e.Item.DataItem;

                if ((customField.prwucf_FieldTypeCode == "DDL") &&
                    (customField.GetLookupValues().Count == 0))
                {
                    return;
                }

                PRWebUserCustomFieldSearchCriteria customFieldCriteria = null;
                if (_oCompanySearchCriteria.CustomFieldSearchCriteria != null)
                {
                    foreach (PRWebUserCustomFieldSearchCriteria customFieldCriteria2 in _oCompanySearchCriteria.CustomFieldSearchCriteria)
                    {
                        if (customField.prwucf_WebUserCustomFieldID == customFieldCriteria2.CustomFieldID)
                        {
                            customFieldCriteria = customFieldCriteria2;
                            break;
                        }
                    }
                }

                PlaceHolder ph = (PlaceHolder)e.Item.FindControl("phCustomField");

                HtmlGenericControl divRow = new HtmlGenericControl();
                divRow.Attributes["class"] = "input-wrapper";
                divRow.TagName = "div";

                HtmlGenericControl divLabel = new HtmlGenericControl();
                divLabel.TagName = "label";
                divLabel.InnerText = customField.prwucf_Label;

                divRow.Controls.Add(divLabel);

                HtmlGenericControl p = new HtmlGenericControl();
                p.TagName = "p";

                if (customField.prwucf_FieldTypeCode == "DDL")
                {
                    IList lookupValues = customField.GetLookupValues();
                    lookupValues.Insert(0, new PRWebUserCustomFieldLookup());
                    ((PRWebUserCustomFieldLookup)lookupValues[0]).prwucfl_LookupValue = Resources.Global.SelectAny; //"[Any]"

                    DropDownList dropDownList = new DropDownList();
                    dropDownList.ID = "CustomDataField_" + customField.prwucf_WebUserCustomFieldID.ToString();
                    dropDownList.DataSource = customField.GetLookupValues();
                    dropDownList.DataTextField = "prwucfl_LookupValue";
                    dropDownList.DataValueField = "prwucfl_WebUserCustomFieldLookupID";
                    dropDownList.CssClass = "tw-w-full postback";
                    dropDownList.DataBind();
                    //dropDownList.Enabled = true;

                    if (customFieldCriteria != null)
                    {
                        dropDownList.SelectedIndex = dropDownList.Items.IndexOf(dropDownList.Items.FindByValue(customFieldCriteria.CustomFieldLookupID.ToString()));
                    }

                    p.Controls.Add(dropDownList);
                }
                else
                {
                    TextBox textBox = new TextBox();
                    textBox.ID = "CustomDataField_" + customField.prwucf_WebUserCustomFieldID.ToString();
                    textBox.MaxLength = 100;
                    textBox.CssClass = "full-width postback";

                    if (customFieldCriteria != null)
                    {
                        textBox.Text = customFieldCriteria.SearchValue;
                    }

                    p.Controls.Add(textBox);
                }

                divRow.Controls.Add(p);

                HtmlGenericControl divMustHaveValue = new HtmlGenericControl();
                divMustHaveValue.Attributes["class"] = "bbs-checkbox-input small postback";
                divMustHaveValue.TagName = "div";

                CheckBox checkBox = new CheckBox();
                checkBox.ID = "cbCustomDataField_" + customField.prwucf_WebUserCustomFieldID.ToString();

                if (customFieldCriteria != null)
                {
                    checkBox.Checked = customFieldCriteria.MustHaveValue;
                }

                HtmlGenericControl spanMustHaveValueText = new HtmlGenericControl();
                spanMustHaveValueText.TagName = "label";
                spanMustHaveValueText.InnerText = Resources.Global.MustHaveValue; // "Must have a value";

                divMustHaveValue.Controls.Add(checkBox);
                divMustHaveValue.Controls.Add(spanMustHaveValueText);
                divRow.Controls.Add(divMustHaveValue);

                ph.Controls.Add(divRow);
            }
        }

        protected void GridView_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            SetSortIndicator((GridView)sender, e);
        }

        /// <summary>
        /// Helper method that helps with bi-directional sorting
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void UserListGridView_Sorting(Object sender, GridViewSortEventArgs e)
        {
            SetSortingAttributes((GridView)sender, e);

            _oCompanySearchCriteria.UserListIDs = GetRequestParameter("cbUserListID", false);
            PopulateUserLists(gvUserList);
        }

        protected void btnHelp_ServerClick(object sender, EventArgs e)
        {
            Response.Redirect(Utilities.GetConfigValue("CorporateWebSite") + "/contact-us/");
        }
    }
}