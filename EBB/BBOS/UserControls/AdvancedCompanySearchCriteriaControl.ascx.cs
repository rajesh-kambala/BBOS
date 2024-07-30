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

 ClassName: AdvancedCompanySearchCriteria
 Description:

 Notes:

***********************************************************************
***********************************************************************/

using System;
using System.Data;
using System.Text;

using PRCo.EBB.BusinessObjects;
using System.Text.RegularExpressions;
using System.Collections.Generic;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// The search criteria control will be used to list all selected search criteria
    /// for each of the company search pages.  This will include the general company search,
    /// company location search, company classification search, company commodity search,
    /// company rating search, company profile search, and company custom search criteria.
    /// </summary>
    public partial class AdvancedCompanySearchCriteriaControl : SearchCriteriaControlBase
    {
        public CompanySearchCriteria CompanySearchCriteria;

        private CompanySearchBase oCompanySearchBase;
        public const string REF_DATA_COMPANY_TYPE = "Comp_PRType";
        public const string REF_DATA_NEW_LISTINGS_ONLY = "NewListingDaysOld";
        public const string REF_DATA_NUMBER_OF_STORES = "prc2_StoreCount";
        public const string REF_DATA_LICENSETYPE = "prli_Type";
        public const string REF_DATA_CORPSTRUCTURE = "prcp_CorporateStructure";
        public const string REF_DATA_VOLUME = "prcp_Volume";
        public const string REF_DATA_LUMBER_VOLUME = "prcp_VolumeL";
        public const string REF_DATA_INTEGRITYRATING = "prin_Name";
        public const string REF_DATA_PAYDESCRIPTION = "prpy_Name";

        public const string COL_INTEGRITYRATING_CODE = "prin_IntegrityRatingId";
        public const string COL_INTEGRITYRATING_MEANING = "prin_Name";

        public const string COL_PAYRATING_CODE = "prpy_PayRatingId";
        public const string COL_PAYRATING_MEANING = "prpy_Name";

        public const string COL_CREDITWORTHRATING_CODE = "prcw_CreditWorthRatingId";
        public const string COL_CREDITWORTHRATING_MEANING = "prcw_Name";

        public bool _bIncludeClearButton = true;

        /// <summary>
        /// Calls functions required to build this control.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);
            oCompanySearchBase = new CompanySearchBase();

            if (CompanySearchCriteria == null)
            {
                return;
            }

            BuildSearchCriteria();
        }

        public bool IncludeClearButton
        {
            get { return _bIncludeClearButton; }
            set { _bIncludeClearButton = value; }
        }

        private string GetSearchCriteriaGroup(int searchPanelType, string title, List<Tuple<string, string, bool>> lstData)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append(@"<div class='search-criteria-group'>");
            sb.Append("<div class='title-container'>");
            sb.Append($"<div class='label'>{title}</div>");

            if (searchPanelType > 0 && IncludeClearButton)
                sb.Append($"<button class='bbsButton bbsButton-tertiary' onclick='clearCriteria({searchPanelType})'><span class='msicon notranslate'>clear</span><span>{Resources.Global.Clear}</span></button>");

            sb.Append("</div>");
            sb.Append("<div class='content-container'>");

            foreach (Tuple<string, string, bool> d in lstData)
            {
                sb.Append("<div class='input-container'>");
                sb.Append($"<p class='subheading'>{d.Item1}</p>");
                if (d.Item3)
                {
                    sb.Append($"<div class='tag-container'><span class='tag'>{d.Item2}</span></div>");
                }
                sb.Append("</div>");
            }

            sb.Append("</div>");
            sb.Append("</div>");

            return sb.ToString();
        }

        /// <summary>
        /// This function builds the search criteria to display for each section including
        /// industry type, company, location, classification, commodity, rating, profile, and
        /// custom criteria.
        /// </summary>
        /// <returns>String containing HTML to display the selected search criteria.</returns>
        public string BuildSearchCriteria()
        {
            List<Tuple<string, string, bool>> lstData; //Label, value, show value
            StringBuilder sbSearchCriteria = new StringBuilder();

            if (oPageBase == null)
                oPageBase = new PageBase();

            #region Industry Type Search Criteria
            lstData = new List<Tuple<string, string, bool>>();

            // Industry Type
            if (!string.IsNullOrEmpty(CompanySearchCriteria.IndustryType))
                lstData.Add(NewRow(Resources.Global.IndustryType, oPageBase.GetReferenceValue("comp_PRIndustryType", CompanySearchCriteria.IndustryType)));

            if (lstData.Count > 0)
            {
                sbSearchCriteria.Append(GetSearchCriteriaGroup(AdvancedCompanySearchBase.SEARCH_PANEL_INDUSTRY, Resources.Global.IndustryType, lstData));
            }
            #endregion

            #region Company Search Criteria
            lstData = new List<Tuple<string, string, bool>>();

            // New Listings Only
            if (CompanySearchCriteria.NewListingOnly)
                lstData.Add(NewRow(Resources.Global.NewListingsOnly, Resources.Global.ListedInPast + " " + oPageBase.GetReferenceValue(REF_DATA_NEW_LISTINGS_ONLY, CompanySearchCriteria.NewListingDaysOld)));

            // Company Name
            if (!string.IsNullOrEmpty(CompanySearchCriteria.CompanyName))
                lstData.Add(NewRow(Resources.Global.Name_Cap, CompanySearchCriteria.CompanyName));

            // BB #
            if (CompanySearchCriteria.BBID > 0)
                lstData.Add(NewRow(Resources.Global.BBNumber, CompanySearchCriteria.BBID.ToString()));

            // Company Type
            if (!string.IsNullOrEmpty(CompanySearchCriteria.CompanyType))
                lstData.Add(NewRow(Resources.Global.Type, oPageBase.GetReferenceValue(REF_DATA_COMPANY_TYPE, CompanySearchCriteria.CompanyType)));

            // Listing Status
            if (!string.IsNullOrEmpty(CompanySearchCriteria.ListingStatus))
                lstData.Add(NewRow(Resources.Global.ListingStatus, oPageBase.GetReferenceValue("BBOSListingStatusSearchBBSi", CompanySearchCriteria.ListingStatus)));

            // Company Phone and Area Code
            if (!string.IsNullOrEmpty(CompanySearchCriteria.PhoneAreaCode) || !string.IsNullOrEmpty(CompanySearchCriteria.PhoneNumber))
            {
                string szFullPhone = "";
                if (!string.IsNullOrEmpty(CompanySearchCriteria.PhoneAreaCode))
                    szFullPhone += CompanySearchCriteria.PhoneAreaCode + " ";
                if (!string.IsNullOrEmpty(CompanySearchCriteria.PhoneNumber))
                    szFullPhone += CompanySearchCriteria.PhoneNumber;

                lstData.Add(NewRow(Resources.Global.CompanyPhone, szFullPhone));
            }

            // Must have phone number
            if (CompanySearchCriteria.PhoneNotNull)
                lstData.Add(NewRow(Resources.Global.MustHaveAPhoneNumber, Resources.Global.Yes, false));

            // Company Fax
            if (CompanySearchCriteria.FaxNotNull)
            {
                lstData.Add(NewRow(Resources.Global.CompanyFax, Resources.Global.MustHaveFaxShort, false));
            }
            else
            {
                if (!string.IsNullOrEmpty(CompanySearchCriteria.FaxAreaCode))
                {
                    lstData.Add(NewRow(Resources.Global.CompanyFax, CompanySearchCriteria.FaxAreaCode + " " + CompanySearchCriteria.FaxNumber));
                }
            }

            // Email
            if (!string.IsNullOrEmpty(CompanySearchCriteria.Email))
                lstData.Add(NewRow(Resources.Global.CompanyEmail, CompanySearchCriteria.Email));
            if (CompanySearchCriteria.EmailNotNull)
                lstData.Add(NewRow(Resources.Global.MustHaveAnEmailAddress, Resources.Global.Yes, false));



            if (lstData.Count > 0)
            {
                sbSearchCriteria.Append(GetSearchCriteriaGroup(AdvancedCompanySearchBase.SEARCH_PANEL_COMPANY_DETAILS, Resources.Global.CompanyDetails, lstData));
            }
            #endregion

            #region Rating Search Criteria
            lstData = new List<Tuple<string, string, bool>>();

            // Membership Year
            if (CompanySearchCriteria.IsTMFM)
            {
                lstData.Add(NewRow(Resources.Global.TradingTransportationMembersOnly, Resources.Global.All));
            }

            // BB Score
            if (CompanySearchCriteria.BBScore > 0)
            {
                lstData.Add(NewRow(Resources.Global.BBScore, CompanySearchCriteria.BBScoreSearchType + " " + CompanySearchCriteria.BBScore));
            }

            //// Pay Report Count
            //if (CompanySearchCriteria.PayReportCount > -1)
            //{
            //    sbRatingSearchCriteria.Append(GetCriteriaHTML(Resources.Global.NumberofCurrentIndustryPayReports,
            //        CompanySearchCriteria.PayReportCountSearchType + " " + CompanySearchCriteria.PayReportCount,
            //        true));
            //}

            // Integrity/Ability Rating
            if (!string.IsNullOrEmpty(CompanySearchCriteria.RatingIntegrityIDs))
            {
                //In the selcted criteria box, if you choose an X rating or pay rating, just put the X in that box or the AA, B, etc.�
                //not the entire description.
                string strRefDisplayValue = GetReferenceDisplayValues(CompanySearchCriteria.RatingIntegrityIDs, "IntegrityRating2_All");
                strRefDisplayValue = RemoveBetween(strRefDisplayValue, '-', ',');
                strRefDisplayValue = strRefDisplayValue.Substring(0, strRefDisplayValue.IndexOf("-")).Trim(); //remove final description
                strRefDisplayValue = strRefDisplayValue.Replace("  ", ", ");

                lstData.Add(NewRow(Resources.Global.IntegrityAbilityRating, strRefDisplayValue));
            }

            // Pay Description
            if (!string.IsNullOrEmpty(CompanySearchCriteria.RatingPayIDs))
            {
                //In the selcted criteria box, if you choose an X rating or pay rating, just put the X in that box or the AA, B, etc.�
                //not the entire description.
                string strRefDisplayValue = GetReferenceDisplayValues(CompanySearchCriteria.RatingPayIDs, "PayRating2");
                strRefDisplayValue = RemoveBetween(strRefDisplayValue, '-', ',');
                strRefDisplayValue = strRefDisplayValue.Substring(0, strRefDisplayValue.IndexOf("-")).Trim(); //remove final description
                strRefDisplayValue = strRefDisplayValue.Replace("  ", ", ");

                lstData.Add(NewRow(Resources.Global.PayDescription, strRefDisplayValue));
            }

            //TODO:JMT LUMBER rating BuildSearchCriteria()
            //// Pay Indicator (for Lumber)
            //if (!String.IsNullOrEmpty(CompanySearchCriteria.PayIndicator))
            //{
            //    sbRatingSearchCriteria.Append(GetCriteriaHTML(Resources.Global.PayDescription,
            //                                                  GetReferenceDisplayValues(CompanySearchCriteria.PayIndicator, "PayIndicator"),
            //                                                  true));
            //}

            // Credit Worth Rating
            if (!string.IsNullOrEmpty(CompanySearchCriteria.RatingCreditWorthMinID) ||
                !string.IsNullOrEmpty(CompanySearchCriteria.RatingCreditWorthMaxID))
            {
                // Calculate display value
                string szCreditWorthZerosRemoved = string.Empty;
                if (!string.IsNullOrEmpty(CompanySearchCriteria.RatingCreditWorthMinID))
                    szCreditWorthZerosRemoved += CompanySearchCriteria.RatingCreditWorthMinID + ",";
                if (!string.IsNullOrEmpty(CompanySearchCriteria.RatingCreditWorthMaxID) && CompanySearchCriteria.RatingCreditWorthMinID != CompanySearchCriteria.RatingCreditWorthMaxID)
                {
                    szCreditWorthZerosRemoved += CompanySearchCriteria.RatingCreditWorthMaxID;
                }
                if (szCreditWorthZerosRemoved.EndsWith(","))
                    szCreditWorthZerosRemoved = szCreditWorthZerosRemoved.Remove(szCreditWorthZerosRemoved.Length - 1);

                if (CompanySearchCriteria.IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                {
                    if (!string.IsNullOrEmpty(szCreditWorthZerosRemoved))
                    {
                        string strRefDisplayValue = GetReferenceDisplayValues(szCreditWorthZerosRemoved, "CreditWorthRating2L2");
                        strRefDisplayValue = strRefDisplayValue.Replace(", ", " - ");
                        lstData.Add(NewRow(Resources.Global.CreditWorthRating, strRefDisplayValue));
                    }
                }
                else
                {
                    if (!string.IsNullOrEmpty(szCreditWorthZerosRemoved))
                    {
                        string strRefDisplayValue = GetReferenceDisplayValues(szCreditWorthZerosRemoved, "CreditWorthRating2");
                        strRefDisplayValue = strRefDisplayValue.Replace(", ", " - ");
                        lstData.Add(NewRow(Resources.Global.CreditWorthRating, strRefDisplayValue));
                    }
                }
            }

            if (lstData.Count > 0)
            {
                sbSearchCriteria.Append(GetSearchCriteriaGroup(AdvancedCompanySearchBase.SEARCH_PANEL_RATINGS, Resources.Global.Rating, lstData));
            }
            #endregion

            #region Location Search Criteria
            lstData = new List<Tuple<string, string, bool>>();

            // Listing Country
            if (!string.IsNullOrEmpty(CompanySearchCriteria.ListingCountryIDs))
            {
                string[] aszCountries = CompanySearchCriteria.ListingCountryIDs.Split(new char[] { ',' });
                DataTable dtCountryList = searchBase.GetCountryList();

                string strDisplayValue = searchBase.TranslateListValues(aszCountries, dtCountryList, "prcn_CountryId", "prcn_Country");
                lstData.Add(NewRow(Resources.Global.ListingCountry, strDisplayValue));
            }

            // Listing State/Province
            if (!string.IsNullOrEmpty(CompanySearchCriteria.ListingStateIDs))
            {
                string[] aszStates = CompanySearchCriteria.ListingStateIDs.Split(new char[] { ',' });
                DataTable dtStateList = searchBase.GetStateList();

                string strDisplayValue = searchBase.TranslateListValues(aszStates, dtStateList, "prst_StateId", "prst_State");
                lstData.Add(NewRow(Resources.Global.ListingStateProvince, strDisplayValue));
            }

            // Listing City
            if (!string.IsNullOrEmpty(CompanySearchCriteria.ListingCity))
            {
                lstData.Add(NewRow(Resources.Global.ListingCity, CompanySearchCriteria.ListingCity));
            }

            // Terminal Market
            if (!string.IsNullOrEmpty(CompanySearchCriteria.TerminalMarketIDs))
            {
                string[] aszTerminalMarkets = CompanySearchCriteria.TerminalMarketIDs.Split(new char[] { ',' });
                DataTable dtTerminalMarketList = searchBase.GetTerminalMarketList();

                string strDisplayValue = searchBase.TranslateListValues(aszTerminalMarkets, dtTerminalMarketList, "prtm_TerminalMarketId", "prtm_FullMarketName");
                lstData.Add(NewRow(Resources.Global.TerminalMarket, strDisplayValue));
            }

            // Listing Postal Code
            if (!string.IsNullOrEmpty(CompanySearchCriteria.ListingPostalCode))
            {
                lstData.Add(NewRow(Resources.Global.ListingPostalCode, CompanySearchCriteria.ListingPostalCode));
            }

            // Within Radius
            if (CompanySearchCriteria.Radius >= 0 &&
                !string.IsNullOrEmpty(CompanySearchCriteria.RadiusType))
            {
                lstData.Add(NewRow(Resources.Global.WithinRadius, CompanySearchCriteria.Radius.ToString() + " " + Resources.Global.MilesOf + " " + CompanySearchCriteria.RadiusType));
            }

            if (lstData.Count > 0)
            {
                sbSearchCriteria.Append(GetSearchCriteriaGroup(AdvancedCompanySearchBase.SEARCH_PANEL_LOCATION, Resources.Global.Location, lstData));
            }
            #endregion

            #region Commodity Search Criteria
            lstData = new List<Tuple<string, string, bool>>();

            // Commodity
            if (!string.IsNullOrEmpty(CompanySearchCriteria.CommodityIDs))
            {
                // Commodity Search Type
                if (!string.IsNullOrEmpty(CompanySearchCriteria.CommoditySearchType))
                {
                    string szCommoditySearchType;
                    switch (CompanySearchCriteria.CommoditySearchType)
                    {
                        case "Any":
                            szCommoditySearchType = Resources.Global.Any;
                            break;
                        case "All":
                            szCommoditySearchType = Resources.Global.All;
                            break;
                        case "Only":
                            szCommoditySearchType = Resources.Global.Only;
                            break;
                        default:
                            szCommoditySearchType = CompanySearchCriteria.CommoditySearchType;
                            break;
                    }

                    lstData.Add(NewRow(Resources.Global.CommoditySelectionType, szCommoditySearchType));
                }

                string[] aszCommodities = CompanySearchCriteria.CommodityIDs.Split(CompanySearchBase.achDelimiter);
                DataTable dtCommodityList = oCompanySearchBase.GetCommodityList();

                string strDisplayValue = searchBase.TranslateListValues(aszCommodities, dtCommodityList, "prcm_CommodityId", "prcm_Name");
                lstData.Add(NewRow(Resources.Global.Commodities, strDisplayValue));
            }

            // Growing Method
            if (CompanySearchCriteria.CommodityGMAttributeID > 0)
            {
                DataTable dtAttributeList = oCompanySearchBase.GetAttributeList();
                lstData.Add(NewRow(Resources.Global.GrowingMethod, oCompanySearchBase.GetValueFromList(dtAttributeList, "prat_AttributeId = " + CompanySearchCriteria.CommodityGMAttributeID.ToString(), "prat_Name")));
            }

            // Attribute
            if (CompanySearchCriteria.CommodityAttributeID > 0)
            {
                DataTable dtAttributeList = oCompanySearchBase.GetAttributeList();
                lstData.Add(NewRow(Resources.Global.Attribute, oCompanySearchBase.GetValueFromList(dtAttributeList, "prat_AttributeId = " + CompanySearchCriteria.CommodityAttributeID.ToString(), "prat_Name")));
            }

            if (lstData.Count > 0)
            {
                sbSearchCriteria.Append(GetSearchCriteriaGroup(AdvancedCompanySearchBase.SEARCH_PANEL_COMMODITIES, Resources.Global.Commodities, lstData));
            }
            #endregion

            #region Specie Search Criteria
            lstData = new List<Tuple<string, string, bool>>();
            StringBuilder sbSpecieSearchCriteria = new StringBuilder();

            // Species
            if (!String.IsNullOrEmpty(CompanySearchCriteria.SpecieIDs))
            {
                // Specie Search Type
                if (!String.IsNullOrEmpty(CompanySearchCriteria.SpecieSearchType))
                {
                    sbSpecieSearchCriteria.Append(GetCriteriaHTML(Resources.Global.SelectionType,
                                                  CompanySearchCriteria.SpecieSearchType,
                                                  true));
                }

                string[] aszIDs = CompanySearchCriteria.SpecieIDs.Split(CompanySearchBase.achDelimiter);
                DataTable dtList = oCompanySearchBase.GetSpecieList();

                sbSpecieSearchCriteria.Append(GetCriteriaHTML(Resources.Global.Selections,
                                               oCompanySearchBase.TranslateListValues(aszIDs, dtList, "prspc_SpecieID", "prspc_Name"),
                                               true));
            }
            if (sbSpecieSearchCriteria.Length > 0)
            {
                sbSearchCriteria.Append(GetSectionHeaderHTML(Resources.Global.Species));
                sbSearchCriteria.Append(sbSpecieSearchCriteria.ToString());
            }
            #endregion

            #region ProductProvided Search Criteria
            lstData = new List<Tuple<string, string, bool>>();
            StringBuilder sbProductProvidedCriteria = new StringBuilder();
            if (!String.IsNullOrEmpty(CompanySearchCriteria.ProductProvidedIDs))
            {
                // Product Search Type
                if (!string.IsNullOrEmpty(CompanySearchCriteria.ProductProvidedSearchType))
                {
                    sbProductProvidedCriteria.Append(GetCriteriaHTML(Resources.Global.SelectionType,
                                                     CompanySearchCriteria.ProductProvidedSearchType,
                                                     true));
                }

                string[] aszIDs = CompanySearchCriteria.ProductProvidedIDs.Split(CompanySearchBase.achDelimiter);
                DataTable dtList = oCompanySearchBase.GetProductProvidedList();

                sbProductProvidedCriteria.Append(GetCriteriaHTML(Resources.Global.Selections,
                                                 oCompanySearchBase.TranslateListValues(aszIDs, dtList, "prprpr_ProductProvidedID", "prprpr_Name"),
                                                 true));
            }
            if (sbProductProvidedCriteria.Length > 0)
            {
                sbSearchCriteria.Append(GetSectionHeaderHTML(Resources.Global.Product));
                sbSearchCriteria.Append(sbProductProvidedCriteria.ToString());
            }
            #endregion

            #region ServiceProvided Search Criteria
            lstData = new List<Tuple<string, string, bool>>();
            StringBuilder sbServiceProvidedCriteria = new StringBuilder();
            if (!string.IsNullOrEmpty(CompanySearchCriteria.ServiceProvidedIDs))
            {
                // Service Provided Search Type
                if (!string.IsNullOrEmpty(CompanySearchCriteria.ServiceProvidedSearchType))
                {
                    sbServiceProvidedCriteria.Append(GetCriteriaHTML(Resources.Global.SelectionType,
                                                     CompanySearchCriteria.ServiceProvidedSearchType,
                                                     true));
                }

                string[] aszIDs = CompanySearchCriteria.ServiceProvidedIDs.Split(CompanySearchBase.achDelimiter);
                DataTable dtList = oCompanySearchBase.GetServiceProvidedList();

                sbServiceProvidedCriteria.Append(GetCriteriaHTML(Resources.Global.Selections,
                                                 oCompanySearchBase.TranslateListValues(aszIDs, dtList, "prserpr_ServiceProvidedID", "prserpr_Name"),
                                                 true));
            }
            if (sbServiceProvidedCriteria.Length > 0)
            {
                sbSearchCriteria.Append(GetSectionHeaderHTML(Resources.Global.Service));
                sbSearchCriteria.Append(sbServiceProvidedCriteria.ToString());
            }
            #endregion

            #region Classification Search Criteria
            // Classifications
            lstData = new List<Tuple<string, string, bool>>();

            //DistressedProduce / rejected shipments
            if (CompanySearchCriteria.SalvageDistressedProduce)
                lstData.Add(NewRow(Resources.Global.SalvagesDistressedLoads_Title, Resources.Global.Yes, false));

            if (!string.IsNullOrEmpty(CompanySearchCriteria.ClassificationIDs))
            {
                // Classification Search Type
                string szClassificationSearchType;
                switch (CompanySearchCriteria.ClassificationSearchType)
                {
                    case "Any":
                        szClassificationSearchType = Resources.Global.Any;
                        break;
                    case "All":
                        szClassificationSearchType = Resources.Global.All;
                        break;
                    case "Only":
                        szClassificationSearchType = Resources.Global.Only;
                        break;
                    default:
                        szClassificationSearchType = CompanySearchCriteria.ClassificationSearchType;
                        break;
                }

                if (!string.IsNullOrEmpty(CompanySearchCriteria.ClassificationSearchType))
                {
                    lstData.Add(NewRow(Resources.Global.ClassificationSelectionType, szClassificationSearchType));
                }

                string[] aszClassifications = CompanySearchCriteria.ClassificationIDs.Split(CompanySearchBase.achDelimiter);
                DataTable dtClassList = oCompanySearchBase.GetClassificationList();

                string strDisplayValue = searchBase.TranslateListValues(aszClassifications, dtClassList, "prcl_ClassificationID", "prcl_Name");
                lstData.Add(NewRow(Resources.Global.Classifications, strDisplayValue));
            }

            // Number of Retail Stores
            if (!string.IsNullOrEmpty(CompanySearchCriteria.NumberOfRetailStores))
            {
                string szRetailStoreValueList = "";
                string[] aszRetailStores = CompanySearchCriteria.NumberOfRetailStores.Split(CompanySearchBase.achDelimiter);

                foreach (string szRetailStore in aszRetailStores)
                {
                    if (!string.IsNullOrEmpty(szRetailStore))
                    {
                        if (szRetailStoreValueList.Length > 0)
                            szRetailStoreValueList += ", ";
                        szRetailStoreValueList += oPageBase.GetReferenceValue(REF_DATA_NUMBER_OF_STORES, szRetailStore);
                    }
                }

                lstData.Add(NewRow(Resources.Global.NumberOfRetailStores2, szRetailStoreValueList));
            }

            // Number of Restaurant Stores
            if (!string.IsNullOrEmpty(CompanySearchCriteria.NumberOfRestaurantStores))
            {
                string szRestaurantStoreValueList = "";
                string[] aszRestaurantStores = CompanySearchCriteria.NumberOfRestaurantStores.Split(CompanySearchBase.achDelimiter);

                foreach (string szRestaurantStore in aszRestaurantStores)
                {
                    if (!string.IsNullOrEmpty(szRestaurantStore))
                    {
                        if (szRestaurantStoreValueList.Length > 0)
                            szRestaurantStoreValueList += ", ";
                        szRestaurantStoreValueList += oPageBase.GetReferenceValue(REF_DATA_NUMBER_OF_STORES, szRestaurantStore);
                    }
                }

                lstData.Add(NewRow(Resources.Global.NumberOfRestaurantStores2, szRestaurantStoreValueList));
            }

            if (lstData.Count > 0)
            {
                sbSearchCriteria.Append(GetSearchCriteriaGroup(AdvancedCompanySearchBase.SEARCH_PANEL_CLASSIFICATIONS, Resources.Global.Classification, lstData));
            }
            #endregion

            #region Profile Search Criteria
            lstData = new List<Tuple<string, string, bool>>();
            string tmp = string.Empty;
            if (CompanySearchCriteria.Organic)
            {
                tmp = Resources.Global.CertifiedOrganic;
                //sbProfileSearchCriteria.Append(GetCriteriaHTML("Certified Ogranic", "Certified Ogranic", true));
            }

            if (CompanySearchCriteria.FoodSafetyCertified)
            {
                if (!string.IsNullOrEmpty(tmp))
                {
                    tmp += ", ";
                }
                tmp += Resources.Global.FoodSafetyCertified;
            }

            if (!string.IsNullOrEmpty(tmp))
            {
                lstData.Add(NewRow(Resources.Global.Certifications, tmp));
            }

            // License Type
            if (!string.IsNullOrEmpty(CompanySearchCriteria.LicenseTypes))
            {
                string szLicenseTypeValueList = "";
                string[] aszLicenseTypes = CompanySearchCriteria.LicenseTypes.Split(CompanySearchBase.achDelimiter);

                foreach (string szLicenseType in aszLicenseTypes)
                {
                    if (!string.IsNullOrEmpty(szLicenseType))
                    {
                        if (szLicenseTypeValueList.Length > 0)
                            szLicenseTypeValueList += ", ";
                        if (szLicenseType != "DRC")
                            szLicenseTypeValueList += oPageBase.GetReferenceValue(REF_DATA_LICENSETYPE, szLicenseType);
                        else
                            szLicenseTypeValueList += Resources.Global.LicenseTypeDRC;
                    }
                }

                lstData.Add(NewRow(Resources.Global.LicenseType, szLicenseTypeValueList));
            }

            // License Number
            if (!string.IsNullOrEmpty(CompanySearchCriteria.LicenseNumber))
            {
                lstData.Add(NewRow(Resources.Global.LicenseNumber, CompanySearchCriteria.LicenseNumber));
            }

            // FT Employees
            if (!string.IsNullOrEmpty(CompanySearchCriteria.FullTimeEmployeeCodes))
            {
                string szFTEmpList = "";
                string[] aszFTempCodes = CompanySearchCriteria.FullTimeEmployeeCodes.Split(CompanySearchBase.achDelimiter);

                foreach (string ftEmpCode in aszFTempCodes)
                {
                    if (!String.IsNullOrEmpty(ftEmpCode))
                    {
                        if (szFTEmpList.Length > 0)
                            szFTEmpList += ", ";
                        szFTEmpList += oPageBase.GetReferenceValue("NumEmployees", ftEmpCode);
                    }
                }

                lstData.Add(NewRow(Resources.Global.FulltimeEmployees, szFTEmpList));
            }

            // Brands
            if (!string.IsNullOrEmpty(CompanySearchCriteria.Brands))
            {
                lstData.Add(NewRow(Resources.Global.Brands, CompanySearchCriteria.Brands));
            }

            // Corporate Structure
            if (!string.IsNullOrEmpty(CompanySearchCriteria.CorporateStructure))
            {
                string szCorpStructValueList = "";
                string[] aszCorpStructures = CompanySearchCriteria.CorporateStructure.Split(CompanySearchBase.achDelimiter);

                foreach (string szCorpStruct in aszCorpStructures)
                {
                    if (!string.IsNullOrEmpty(szCorpStruct))
                    {
                        if (szCorpStructValueList.Length > 0)
                            szCorpStructValueList += ", ";
                        szCorpStructValueList += oPageBase.GetReferenceValue(REF_DATA_CORPSTRUCTURE, szCorpStruct);
                    }
                }

                lstData.Add(NewRow(Resources.Global.CorporateStructure, szCorpStructValueList));
            }

            if (!string.IsNullOrEmpty(CompanySearchCriteria.PubliclyTraded))
            {
                string szValue = "Yes";
                if (CompanySearchCriteria.PubliclyTraded == "N")
                {
                    szValue = "No";
                }

                lstData.Add(NewRow(Resources.Global.PubliclyTraded, szValue));
            }

            if (!string.IsNullOrEmpty(CompanySearchCriteria.StockSymbol))
            {

                lstData.Add(NewRow(Resources.Global.StockSymbol, CompanySearchCriteria.StockSymbol));
            }

            // Miscellaneous Listing Info
            if (!string.IsNullOrEmpty(CompanySearchCriteria.DescriptiveLines))
            {
                lstData.Add(NewRow(Resources.Global.MiscListingInfo, CompanySearchCriteria.DescriptiveLines));
            }

            // Volume Prep
            string szRefDataName = REF_DATA_VOLUME;
            if (CompanySearchCriteria.IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                szRefDataName = REF_DATA_LUMBER_VOLUME;
            }

            // Volume - old
            if (!string.IsNullOrEmpty(CompanySearchCriteria.Volume))
            {
                string szVolumeValueList = "";
                string[] aszVolumes = CompanySearchCriteria.Volume.Split(CompanySearchBase.achDelimiter);

                foreach (string szVolume in aszVolumes)
                {
                    if (!string.IsNullOrEmpty(szVolume))
                    {
                        if (szVolumeValueList.Length > 0)
                            szVolumeValueList += ", ";
                        szVolumeValueList += oPageBase.GetReferenceValue(szRefDataName, szVolume);
                    }
                }

                lstData.Add(NewRow(Resources.Global.Volume, szVolumeValueList));
            }

            // Volume - New
            if (!string.IsNullOrEmpty(CompanySearchCriteria.VolumeMin) ||
                !string.IsNullOrEmpty(CompanySearchCriteria.VolumeMax))
            {
                const string hyphen = " - ";
                // Calculate display value
                string szVolume = string.Empty;
                if (!string.IsNullOrEmpty(CompanySearchCriteria.VolumeMin))
                    szVolume += oPageBase.GetReferenceValue(szRefDataName, CompanySearchCriteria.VolumeMin) + hyphen;

                if (!string.IsNullOrEmpty(CompanySearchCriteria.VolumeMax) && CompanySearchCriteria.VolumeMin != CompanySearchCriteria.VolumeMax)
                    szVolume += oPageBase.GetReferenceValue(szRefDataName, CompanySearchCriteria.VolumeMax);

                if (szVolume.EndsWith(hyphen))
                    szVolume = szVolume.Replace(hyphen, "");

                lstData.Add(NewRow(Resources.Global.Volume, szVolume));
            }

            if (lstData.Count > 0)
            {
                sbSearchCriteria.Append(GetSearchCriteriaGroup(AdvancedCompanySearchBase.SEARCH_PANEL_LICENSES_CERTS, Resources.Global.Profile, lstData));
            }
            #endregion

            #region "Local Source"

            if (CompanySearchCriteria.WebUser.prwu_IndustryType != GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                lstData = new List<Tuple<string, string, bool>>();

                if (!string.IsNullOrEmpty(CompanySearchCriteria.IncludeLocalSource))
                {
                    lstData.Add(NewRow(Resources.Global.LocalSourceData2, oPageBase.GetReferenceValue("BBOSSearchLocalSoruce", CompanySearchCriteria.IncludeLocalSource)));
                }

                if (CompanySearchCriteria.CertifiedOrganic)
                {
                    lstData.Add(NewRow(Resources.Global.GrowsOrganic, Resources.Global.GrowsOrganic));
                }

                if (!string.IsNullOrEmpty(CompanySearchCriteria.AlsoOperates))
                {
                    string szAlsoOperatesList = "";
                    string[] aszAlsoOperates = CompanySearchCriteria.AlsoOperates.Split(CompanySearchBase.achDelimiter);

                    foreach (string szAlsoOperates in aszAlsoOperates)
                    {
                        if (!string.IsNullOrEmpty(szAlsoOperates))
                        {
                            if (szAlsoOperatesList.Length > 0)
                                szAlsoOperatesList += ", ";
                            szAlsoOperatesList += oPageBase.GetReferenceValue("prls_AlsoOperates", szAlsoOperates);
                        }
                    }

                    lstData.Add(NewRow(Resources.Global.AlsoOperates, szAlsoOperatesList));
                }

                if (!string.IsNullOrEmpty(CompanySearchCriteria.TotalAcres))
                {
                    string szTotalAcresList = "";
                    string[] aszTotalAcres = CompanySearchCriteria.TotalAcres.Split(CompanySearchBase.achDelimiter);

                    foreach (string szTotalAcres in aszTotalAcres)
                    {
                        if (!string.IsNullOrEmpty(szTotalAcres))
                        {
                            if (szTotalAcresList.Length > 0)
                                szTotalAcresList += ", ";
                            szTotalAcresList += oPageBase.GetReferenceValue("prls_TotalAcres", szTotalAcres);
                        }
                    }
                    
                    lstData.Add(NewRow(Resources.Global.TotalAcres, szTotalAcresList));
                }


                if (lstData.Count > 0)
                {
                    sbSearchCriteria.Append(GetSearchCriteriaGroup(AdvancedCompanySearchBase.SEARCH_PANEL_LOCAL_SOURCE, Resources.Global.LocalSourceData, lstData));
                }
            }
            #endregion

            //Spot BuildSearchCriteria()
            #region "Custom Filters"
            lstData = new List<Tuple<string, string, bool>>();

            string customSearchCriteria = GetCustomCriteria(CompanySearchCriteria, true, lstData);
            if (lstData.Count > 0)
            {
                sbSearchCriteria.Append(GetSearchCriteriaGroup(AdvancedCompanySearchBase.SEARCH_PANEL_CUSTOM, Resources.Global.Custom, lstData));
            }
            #endregion

            #region Internal Criteria
            lstData = new List<Tuple<string, string, bool>>();

            // Corporate Structure
            if (!string.IsNullOrEmpty(CompanySearchCriteria.SalesTerritories))
            {
                string szList = "";
                string[] aszSalesTerritories = CompanySearchCriteria.SalesTerritories.Split(CompanySearchBase.achDelimiter);

                foreach (string szSalesTerritory in aszSalesTerritories)
                {
                    if (!string.IsNullOrEmpty(szSalesTerritory))
                    {
                        if (szList.Length > 0)
                            szList += ", ";
                        szList += oPageBase.GetReferenceValue("SalesTerritorySearch", szSalesTerritory);
                    }
                }

                lstData.Add(NewRow(Resources.Global.SalesTerritory, szList));
            }

            if (!string.IsNullOrEmpty(CompanySearchCriteria.TerritoryCode))
            {
                lstData.Add(NewRow("Territory Code", oPageBase.GetReferenceValue("prci_SalesTerritory", CompanySearchCriteria.TerritoryCode)));
            }

            if (!string.IsNullOrEmpty(CompanySearchCriteria.MemberTypeCode))
            {
                lstData.Add(NewRow("Membership Type", oPageBase.GetReferenceValue("MembershipTypeCode", CompanySearchCriteria.MemberTypeCode)));
            }

            if (!string.IsNullOrEmpty(CompanySearchCriteria.PrimaryServiceCodes))
            {
                string szList = "";
                string[] aszPrimaryServiceCodes = CompanySearchCriteria.PrimaryServiceCodes.Split(CompanySearchBase.achDelimiter);

                foreach (string szPrimaryServiceCode in aszPrimaryServiceCodes)
                {
                    if (!String.IsNullOrEmpty(szPrimaryServiceCode))
                    {
                        if (szList.Length > 0)
                            szList += ", ";
                        szList += oPageBase.GetReferenceValue("NewProduct", szPrimaryServiceCode);
                    }
                }

                lstData.Add(NewRow("Primary Services", szList));
            }

            if ((CompanySearchCriteria.NumberLicenses > -1) &&
                (!string.IsNullOrEmpty(CompanySearchCriteria.NumberLicenseSearchType)))
            {
                lstData.Add(NewRow("# of Avail Licences", CompanySearchCriteria.NumberLicenseSearchType + " " + CompanySearchCriteria.NumberLicenses.ToString()));
            }

            if ((CompanySearchCriteria.ActiveLicenses > -1) &&
                (!string.IsNullOrEmpty(CompanySearchCriteria.ActiveLicenseSearchType)))
            {
                lstData.Add(NewRow("# of Active Licenses", CompanySearchCriteria.ActiveLicenseSearchType + " " + CompanySearchCriteria.ActiveLicenses.ToString()));
            }

            if ((CompanySearchCriteria.AvailableUnits > -1) &&
                (!string.IsNullOrEmpty(CompanySearchCriteria.AvailableUnitsSearchType)))
            {
                lstData.Add(NewRow("# of Units Avail", CompanySearchCriteria.AvailableUnitsSearchType + " " + CompanySearchCriteria.AvailableUnits.ToString("###,##0")));
            }

            if ((CompanySearchCriteria.UsedUnits > -1) &&
                (!string.IsNullOrEmpty(CompanySearchCriteria.UsedUnitsSearchType)))
            {
                lstData.Add(NewRow("# of Units Used", CompanySearchCriteria.UsedUnitsSearchType + " " + CompanySearchCriteria.UsedUnits.ToString("###,##0")));
            }

            if (CompanySearchCriteria.ReceivesPromoFaxes)
            {
                lstData.Add(NewRow("Receives Promo Faxes", "", false));
            }

            if (CompanySearchCriteria.ReceivesPromoEmails)
            {
                lstData.Add(NewRow("Receives Promo Emails", "", false));
            }

            if ((CompanySearchCriteria.MembershipRevenue > -1) &&
                (!string.IsNullOrEmpty(CompanySearchCriteria.MembershipRevenueSearchType)))
            {
                lstData.Add(NewRow("Membership Revenue", CompanySearchCriteria.MembershipRevenueSearchType + " $" + CompanySearchCriteria.MembershipRevenue.ToString("###,###,##0.00")));
            }

            if ((CompanySearchCriteria.AdvertisingRevenue > -1) &&
                (!string.IsNullOrEmpty(CompanySearchCriteria.AdvertisingRevenueSearchType)))
            {
                lstData.Add(NewRow("Advertising Revenue", CompanySearchCriteria.AdvertisingRevenueSearchType + " $" + CompanySearchCriteria.AdvertisingRevenue.ToString("###,###,##0.00")));
            }

            if (lstData.Count > 0)
            {
                sbSearchCriteria.Append(GetSearchCriteriaGroup(AdvancedCompanySearchBase.SEARCH_PANEL_INTERNAL, Resources.Global.btnInternalCriteria, lstData));
            }
            #endregion

            if (sbSearchCriteria.Length == 0)
            {
                sbSearchCriteria.Append("<span style=\"font-weight:bold;\">" + Resources.Global.NoCriteriaSelected + "</span>");
            }

            litSearchCriteria.Text = sbSearchCriteria.ToString();
            return sbSearchCriteria.ToString();
        }

        string RemoveBetween(string s, char begin, char end)
        {
            Regex regex = new Regex(string.Format("\\{0}.*?\\{1}", begin, end));
            return regex.Replace(s, string.Empty);
        }
    }
}