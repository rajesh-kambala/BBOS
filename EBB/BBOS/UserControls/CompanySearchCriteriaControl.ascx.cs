/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2019

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CompanySearchCriteria
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/

using System;
using System.Data;
using System.Text;

using PRCo.EBB.BusinessObjects;
using System.Text.RegularExpressions;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// The search criteria control will be used to list all selected search criteria 
    /// for each of the company search pages.  This will include the general company search,
    /// company location search, company classification search, company commodity search, 
    /// company rating search, company profile search, and company custom search criteria.
    /// </summary>
    public partial class CompanySearchCriteriaControl : SearchCriteriaControlBase
    {
        public CompanySearchCriteria CompanySearchCriteria;

        private CompanySearchBase oCompanySearchBase;
        private const string REF_DATA_COMPANY_TYPE = "Comp_PRType";
        private const string REF_DATA_NEW_LISTINGS_ONLY = "NewListingDaysOld";
        private const string REF_DATA_NUMBER_OF_STORES = "prc2_StoreCount";
        private const string REF_DATA_LICENSETYPE = "prli_Type";
        private const string REF_DATA_CORPSTRUCTURE = "prcp_CorporateStructure";
        private const string REF_DATA_VOLUME = "prcp_Volume";
        private const string REF_DATA_LUMBER_VOLUME = "prcp_VolumeL";
        private const string REF_DATA_INTEGRITYRATING = "prin_Name";
        private const string REF_DATA_PAYDESCRIPTION = "prpy_Name";

        private const string COL_INTEGRITYRATING_CODE = "prin_IntegrityRatingId";
        private const string COL_INTEGRITYRATING_MEANING = "prin_Name";

        private const string COL_PAYRATING_CODE = "prpy_PayRatingId";
        private const string COL_PAYRATING_MEANING = "prpy_Name";

        private const string COL_CREDITWORTHRATING_CODE = "prcw_CreditWorthRatingId";
        private const string COL_CREDITWORTHRATING_MEANING = "prcw_Name";

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

            if (_bHorizontalDisplay)
            {
                pnlCriteria.Attributes.CssStyle.Add("width", "100% !important");
                pnlExpander.Visible = true;

                //Defect 4473 - make default state of horizontal be collapsed
                string szScript = "Set_Expand('Criteria',false);";
                Page.ClientScript.RegisterStartupScript(this.GetType(), "hidecriteria", szScript, true);

            }

            BuildSearchCriteria();
        }

        public bool HorizontalDisplay
        {
            get { return _bHorizontalDisplay; }
            set { _bHorizontalDisplay = value; }
        }

        /// <summary>
        /// This function builds the search criteria to display for each section including
        /// industry type, company, location, classification, commodity, rating, profile, and
        /// custom criteria.  
        /// </summary>
        /// <returns>String containing HTML to display the selected search criteria.</returns>
        public string BuildSearchCriteria()
        {
            StringBuilder sbSearchCriteria = new StringBuilder();

            #region Industry Type Search Criteria
            StringBuilder sbIndustryType = new StringBuilder();

            // Industry Type
            if (!String.IsNullOrEmpty(CompanySearchCriteria.IndustryType))
            {
                sbIndustryType.Append(GetCriteriaHTML(Resources.Global.IndustryType,
                    oPageBase.GetReferenceValue("comp_PRIndustryType", CompanySearchCriteria.IndustryType),
                    false));
            }

            if (sbIndustryType.Length > 0)
            {
                sbSearchCriteria.Append(GetSectionHeaderHTML(Resources.Global.IndustryType));
                sbSearchCriteria.Append(sbIndustryType.ToString());
            }
            #endregion

            #region Company Search Criteria
            StringBuilder sbCompanySearchCriteria = new StringBuilder();

            // Company Name
            if (!String.IsNullOrEmpty(CompanySearchCriteria.CompanyName))
            {
                sbCompanySearchCriteria.Append(GetCriteriaHTML(Resources.Global.Name_Cap, CompanySearchCriteria.CompanyName, true));
            }

            // BB #
            if (CompanySearchCriteria.BBID > 0)
            {
                sbCompanySearchCriteria.Append(GetCriteriaHTML(Resources.Global.BBNumber, CompanySearchCriteria.BBID.ToString(), true));
            }

            // Company Type
            if (!String.IsNullOrEmpty(CompanySearchCriteria.CompanyType))
            {
                sbCompanySearchCriteria.Append(GetCriteriaHTML(Resources.Global.Type,
                    oPageBase.GetReferenceValue(REF_DATA_COMPANY_TYPE, CompanySearchCriteria.CompanyType),
                    true));
            }

            // Listing Status
            if (!String.IsNullOrEmpty(CompanySearchCriteria.ListingStatus))
            {
                sbCompanySearchCriteria.Append(GetCriteriaHTML(Resources.Global.ListingStatus,
                                               oPageBase.GetReferenceValue("BBOSListingStatusSearchBBSi", CompanySearchCriteria.ListingStatus),
                                               true));
            }

            // Company Phone
            if (!String.IsNullOrEmpty(CompanySearchCriteria.PhoneAreaCode))
            {
                sbCompanySearchCriteria.Append(GetCriteriaHTML(Resources.Global.CompanyPhone, CompanySearchCriteria.PhoneAreaCode + " " + CompanySearchCriteria.PhoneNumber, true));
            }

            // Company Fax
            if (CompanySearchCriteria.FaxNotNull)
            {
                sbCompanySearchCriteria.Append(GetCriteriaHTML(Resources.Global.CompanyFax, Resources.Global.MustHaveFaxShort, true));
            }
            else
            {
                if (!String.IsNullOrEmpty(CompanySearchCriteria.FaxAreaCode))
                {
                    sbCompanySearchCriteria.Append(GetCriteriaHTML(Resources.Global.CompanyFax, CompanySearchCriteria.FaxAreaCode + " " + CompanySearchCriteria.FaxNumber, true));
                }
            }

            // Email
            if (CompanySearchCriteria.EmailNotNull)
            {
                sbCompanySearchCriteria.Append(GetCriteriaHTML(Resources.Global.CompanyEmail, Resources.Global.MustHaveEmailShort, true));
            }
            else
            {
                if (!String.IsNullOrEmpty(CompanySearchCriteria.Email))
                {
                    sbCompanySearchCriteria.Append(GetCriteriaHTML(Resources.Global.CompanyEmail, CompanySearchCriteria.Email, true));
                }
            }

            // New Listings Only
            if (CompanySearchCriteria.NewListingOnly)
            {
                sbCompanySearchCriteria.Append(GetCriteriaHTML(Resources.Global.NewListingsOnly,
                    Resources.Global.ListedInPast + " " + oPageBase.GetReferenceValue(REF_DATA_NEW_LISTINGS_ONLY, CompanySearchCriteria.NewListingDaysOld),
                    true));
            }

            if (sbCompanySearchCriteria.Length > 0)
            {
                sbSearchCriteria.Append(GetSectionHeaderHTML(Resources.Global.Company));
                sbSearchCriteria.Append(sbCompanySearchCriteria.ToString());
            }
            #endregion

            #region Rating Search Criteria
            StringBuilder sbRatingSearchCriteria = new StringBuilder();

            // Membership Year
            if (CompanySearchCriteria.IsTMFM)
            {
                sbRatingSearchCriteria.Append(GetCriteriaHTML(Resources.Global.TradingTransportationMembershipYear,
                    "All",
                    true));
            }

            // Membership Year
            if (CompanySearchCriteria.MemberYear > 0)
            {
                sbRatingSearchCriteria.Append(GetCriteriaHTML(Resources.Global.TradingTransportationMembershipYear,
                    CompanySearchCriteria.MemberYearSearchType + " " + CompanySearchCriteria.MemberYear,
                    true));
            }

            // BB Score
            if (CompanySearchCriteria.BBScore > 0)
            {
                sbRatingSearchCriteria.Append(GetCriteriaHTML(Resources.Global.BBScore,
                    CompanySearchCriteria.BBScoreSearchType + " " + CompanySearchCriteria.BBScore,
                    true));
            }

            // Pay Report Count
            if (CompanySearchCriteria.PayReportCount > -1)
            {
                sbRatingSearchCriteria.Append(GetCriteriaHTML(Resources.Global.NumberofCurrentIndustryPayReports,
                    CompanySearchCriteria.PayReportCountSearchType + " " + CompanySearchCriteria.PayReportCount,
                    true));
            }

            // Integrity/Ability Rating
            if (!String.IsNullOrEmpty(CompanySearchCriteria.RatingIntegrityIDs))
            {
                //In the selcted criteria box, if you choose an X rating or pay rating, just put the X in that box or the AA, B, etc. 
                //not the entire description.
                string strRefDisplayValue = GetReferenceDisplayValues(CompanySearchCriteria.RatingIntegrityIDs, "IntegrityRating2_All");
                strRefDisplayValue = RemoveBetween(strRefDisplayValue, '-', ',');
                strRefDisplayValue = strRefDisplayValue.Substring(0, strRefDisplayValue.IndexOf("-")).Trim(); //remove final description
                strRefDisplayValue = strRefDisplayValue.Replace("  ", ", ");

                sbRatingSearchCriteria.Append(GetCriteriaHTML(Resources.Global.IntegrityAbilityRating,
                                                              strRefDisplayValue,
                                                              true));
            }

            // Pay Description
            if (!String.IsNullOrEmpty(CompanySearchCriteria.RatingPayIDs))
            {
                //In the selcted criteria box, if you choose an X rating or pay rating, just put the X in that box or the AA, B, etc. 
                //not the entire description.
                string strRefDisplayValue = GetReferenceDisplayValues(CompanySearchCriteria.RatingPayIDs, "PayRating2");
                strRefDisplayValue = RemoveBetween(strRefDisplayValue, '-', ',');
                strRefDisplayValue = strRefDisplayValue.Substring(0, strRefDisplayValue.IndexOf("-")).Trim(); //remove final description
                strRefDisplayValue = strRefDisplayValue.Replace("  ", ", ");

                sbRatingSearchCriteria.Append(GetCriteriaHTML(Resources.Global.PayDescription,
                                                              strRefDisplayValue,
                                                              true));
            }

            // Pay Indicator
            if (!String.IsNullOrEmpty(CompanySearchCriteria.PayIndicator))
            {
                sbRatingSearchCriteria.Append(GetCriteriaHTML(Resources.Global.PayDescription,
                                                              GetReferenceDisplayValues(CompanySearchCriteria.PayIndicator, "PayIndicator"),
                                                              true));
            }

            // Credit Worth Rating
            if (!String.IsNullOrEmpty(CompanySearchCriteria.RatingCreditWorthIDs))
            {
                if (CompanySearchCriteria.IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                {
                    sbRatingSearchCriteria.Append(GetCriteriaHTML(Resources.Global.CreditWorthRating,
                                                                  GetReferenceDisplayValues(CompanySearchCriteria.RatingCreditWorthIDs, "CreditWorthRating2L"),
                                                                  true));
                }
                else
                {
                    sbRatingSearchCriteria.Append(GetCriteriaHTML(Resources.Global.CreditWorthRating,
                                                                  GetReferenceDisplayValues(CompanySearchCriteria.RatingCreditWorthIDs, "CreditWorthRating2"),
                                                                  true));
                }
            }

            if (sbRatingSearchCriteria.Length > 0)
            {
                sbSearchCriteria.Append(GetSectionHeaderHTML(Resources.Global.Rating));
                sbSearchCriteria.Append(sbRatingSearchCriteria.ToString());
            }
            #endregion

            #region Location Search Criteria
            string locationSearchCriteria = GetLocationCriteria(CompanySearchCriteria);
            if (locationSearchCriteria.Length > 0)
            {
                sbSearchCriteria.Append(GetSectionHeaderHTML(Resources.Global.Location));
                sbSearchCriteria.Append(locationSearchCriteria);
            }
            #endregion

            #region Commodity Search Criteria
            StringBuilder sbCommoditySearchCriteria = new StringBuilder();

            // Growing Method
            if (CompanySearchCriteria.CommodityGMAttributeID > 0)
            {
                DataTable dtAttributeList = oCompanySearchBase.GetAttributeList();
                sbCommoditySearchCriteria.Append(GetCriteriaHTML(Resources.Global.GrowingMethod,
                    oCompanySearchBase.GetValueFromList(dtAttributeList, "prat_AttributeId = " + CompanySearchCriteria.CommodityGMAttributeID.ToString(), "prat_Name"),
                    true));
            }

            // Attribute
            if (CompanySearchCriteria.CommodityAttributeID > 0)
            {
                DataTable dtAttributeList = oCompanySearchBase.GetAttributeList();
                sbCommoditySearchCriteria.Append(GetCriteriaHTML(Resources.Global.Attribute,
                    oCompanySearchBase.GetValueFromList(dtAttributeList, "prat_AttributeId = " + CompanySearchCriteria.CommodityAttributeID.ToString(), "prat_Name"),
                    true));
            }

            // Commodity
            if (!String.IsNullOrEmpty(CompanySearchCriteria.CommodityIDs))
            {
                // Commodity Search Type
                if (!String.IsNullOrEmpty(CompanySearchCriteria.CommoditySearchType))
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

                    sbCommoditySearchCriteria.Append(GetCriteriaHTML(Resources.Global.CommoditySelectionType,
                                    szCommoditySearchType,
                                    true));
                }

                string[] aszCommodities = CompanySearchCriteria.CommodityIDs.Split(CompanySearchBase.achDelimiter);
                DataTable dtCommodityList = oCompanySearchBase.GetCommodityList();

                sbCommoditySearchCriteria.Append(GetCriteriaHTML(Resources.Global.Commodities,
                    oCompanySearchBase.TranslateListValues(aszCommodities, dtCommodityList, "prcm_CommodityId", "prcm_Name"),
                    true));
            }

            if (sbCommoditySearchCriteria.Length > 0)
            {
                sbSearchCriteria.Append(GetSectionHeaderHTML(Resources.Global.Commodity));
                sbSearchCriteria.Append(sbCommoditySearchCriteria.ToString());
            }
            #endregion

            #region Specie Search Criteria
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
            StringBuilder sbProductProvidedCriteria = new StringBuilder();
            if (!String.IsNullOrEmpty(CompanySearchCriteria.ProductProvidedIDs))
            {
                // Product Search Type
                if (!String.IsNullOrEmpty(CompanySearchCriteria.ProductProvidedSearchType))
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
            StringBuilder sbServiceProvidedCriteria = new StringBuilder();
            if (!String.IsNullOrEmpty(CompanySearchCriteria.ServiceProvidedIDs))
            {
                // Service Provided Search Type
                if (!String.IsNullOrEmpty(CompanySearchCriteria.ServiceProvidedSearchType))
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
            StringBuilder sbClassificationSearchCriteria = new StringBuilder();

            // Classifications
            if (!String.IsNullOrEmpty(CompanySearchCriteria.ClassificationIDs))
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

                if (!String.IsNullOrEmpty(CompanySearchCriteria.ClassificationSearchType))
                {
                    sbClassificationSearchCriteria.Append(GetCriteriaHTML(Resources.Global.ClassificationSelectionType,
                        szClassificationSearchType,
                        true));
                }

                string[] aszClassifications = CompanySearchCriteria.ClassificationIDs.Split(CompanySearchBase.achDelimiter);
                DataTable dtClassList = oCompanySearchBase.GetClassificationList();

                sbClassificationSearchCriteria.Append(GetCriteriaHTML(Resources.Global.Classifications,
                    oCompanySearchBase.TranslateListValues(aszClassifications, dtClassList, "prcl_ClassificationID", "prcl_Name"),
                    true));
            }

            // Number of Retail Stores
            StringBuilder sbRetailStoresSearchCriteria = new StringBuilder();

            if (!String.IsNullOrEmpty(CompanySearchCriteria.NumberOfRetailStores))
            {
                string szRetailStoreValueList = "";
                string[] aszRetailStores = CompanySearchCriteria.NumberOfRetailStores.Split(CompanySearchBase.achDelimiter);

                foreach (string szRetailStore in aszRetailStores)
                {
                    if (!String.IsNullOrEmpty(szRetailStore))
                    {
                        if (szRetailStoreValueList.Length > 0)
                            szRetailStoreValueList += ", ";
                        szRetailStoreValueList += oPageBase.GetReferenceValue(REF_DATA_NUMBER_OF_STORES, szRetailStore);
                    }
                }

                sbClassificationSearchCriteria.Append(GetCriteriaHTML(Resources.Global.NumberOfRetailStores,
                    szRetailStoreValueList,
                    true));
            }

            // Number of Restaurant Stores
            StringBuilder sbRestaurantStoresSearchCriteria = new StringBuilder();

            if (!String.IsNullOrEmpty(CompanySearchCriteria.NumberOfRestaurantStores))
            {
                string szRestaurantStoreValueList = "";
                string[] aszRestaurantStores = CompanySearchCriteria.NumberOfRestaurantStores.Split(CompanySearchBase.achDelimiter);

                foreach (string szRestaurantStore in aszRestaurantStores)
                {
                    if (!String.IsNullOrEmpty(szRestaurantStore))
                    {
                        if (szRestaurantStoreValueList.Length > 0)
                            szRestaurantStoreValueList += ", ";
                        szRestaurantStoreValueList += oPageBase.GetReferenceValue(REF_DATA_NUMBER_OF_STORES, szRestaurantStore);
                    }
                }

                sbClassificationSearchCriteria.Append(GetCriteriaHTML(Resources.Global.NumberOfRestaurantStores,
                    szRestaurantStoreValueList,
                    true));
            }

            if (sbClassificationSearchCriteria.Length > 0)
            {
                sbSearchCriteria.Append(GetSectionHeaderHTML(Resources.Global.Classification));
                sbSearchCriteria.Append(sbClassificationSearchCriteria.ToString());
            }
            #endregion

            #region Profile Search Criteria
            StringBuilder sbProfileSearchCriteria = new StringBuilder();

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
                sbProfileSearchCriteria.Append(GetCriteriaHTML(Resources.Global.Certifications, tmp, true));
            }


            #region "Salvages Distressed Loads"
            if (CompanySearchCriteria.SalvageDistressedProduce)
            {
                sbProfileSearchCriteria.Append(GetCriteriaHTML(Resources.Global.SalvagesDistressedLoads_Title, "Yes", true));
            }
            #endregion  

            // License Type
            if (!String.IsNullOrEmpty(CompanySearchCriteria.LicenseTypes))
            {
                string szLicenseTypeValueList = "";
                string[] aszLicenseTypes = CompanySearchCriteria.LicenseTypes.Split(CompanySearchBase.achDelimiter);

                foreach (string szLicenseType in aszLicenseTypes)
                {
                    if (!String.IsNullOrEmpty(szLicenseType))
                    {
                        if (szLicenseTypeValueList.Length > 0)
                            szLicenseTypeValueList += ", ";
                        if (szLicenseType != "DRC")
                            szLicenseTypeValueList += oPageBase.GetReferenceValue(REF_DATA_LICENSETYPE, szLicenseType);
                        else
                            szLicenseTypeValueList += Resources.Global.LicenseTypeDRC;
                    }
                }

                sbProfileSearchCriteria.Append(GetCriteriaHTML(Resources.Global.LicenseType,
                    szLicenseTypeValueList,
                    true));
            }

            // License Number
            if (!String.IsNullOrEmpty(CompanySearchCriteria.LicenseNumber))
            {
                sbProfileSearchCriteria.Append(GetCriteriaHTML(Resources.Global.LicenseNumber,
                    CompanySearchCriteria.LicenseNumber,
                    true));
            }

            // FT Employees
            if (!String.IsNullOrEmpty(CompanySearchCriteria.FullTimeEmployeeCodes))
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

                sbProfileSearchCriteria.Append(GetCriteriaHTML(Resources.Global.FulltimeEmployees,
                    szFTEmpList,
                    true));
            }

            // Brands
            if (!String.IsNullOrEmpty(CompanySearchCriteria.Brands))
            {
                sbProfileSearchCriteria.Append(GetCriteriaHTML(Resources.Global.Brands,
                    CompanySearchCriteria.Brands,
                    true));
            }

            // Corporate Structure
            if (!String.IsNullOrEmpty(CompanySearchCriteria.CorporateStructure))
            {
                string szCorpStructValueList = "";
                string[] aszCorpStructures = CompanySearchCriteria.CorporateStructure.Split(CompanySearchBase.achDelimiter);

                foreach (string szCorpStruct in aszCorpStructures)
                {
                    if (!String.IsNullOrEmpty(szCorpStruct))
                    {
                        if (szCorpStructValueList.Length > 0)
                            szCorpStructValueList += ", ";
                        szCorpStructValueList += oPageBase.GetReferenceValue(REF_DATA_CORPSTRUCTURE, szCorpStruct);
                    }
                }

                sbProfileSearchCriteria.Append(GetCriteriaHTML(Resources.Global.CorporateStructure,
                    szCorpStructValueList,
                    true));
            }




            if (!String.IsNullOrEmpty(CompanySearchCriteria.PubliclyTraded))
            {
                string szValue = "Yes";
                if (CompanySearchCriteria.PubliclyTraded == "N")
                {
                    szValue = "No";
                }
                sbProfileSearchCriteria.Append(GetCriteriaHTML(Resources.Global.PubliclyTraded,
                                                               szValue,
                                                               true));
            }

            if (!String.IsNullOrEmpty(CompanySearchCriteria.StockSymbol))
            {
                sbProfileSearchCriteria.Append(GetCriteriaHTML(Resources.Global.StockSymbol,
                                                               CompanySearchCriteria.StockSymbol,
                                                               true));
            }

            // Miscellaneous Listing Info
            if (!String.IsNullOrEmpty(CompanySearchCriteria.DescriptiveLines))
            {
                sbProfileSearchCriteria.Append(GetCriteriaHTML(Resources.Global.MiscListingInfo,
                    CompanySearchCriteria.DescriptiveLines,
                    true));
            }

            // Volume
            if (!String.IsNullOrEmpty(CompanySearchCriteria.Volume))
            {
                string szRefDataName = REF_DATA_VOLUME;
                if (CompanySearchCriteria.IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                {
                    szRefDataName = REF_DATA_LUMBER_VOLUME;
                }


                string szVolumeValueList = "";
                string[] aszVolumes = CompanySearchCriteria.Volume.Split(CompanySearchBase.achDelimiter);

                foreach (string szVolume in aszVolumes)
                {
                    if (!String.IsNullOrEmpty(szVolume))
                    {
                        if (szVolumeValueList.Length > 0)
                            szVolumeValueList += ", ";
                        szVolumeValueList += oPageBase.GetReferenceValue(szRefDataName, szVolume);
                    }
                }

                sbProfileSearchCriteria.Append(GetCriteriaHTML(Resources.Global.Volume,
                    szVolumeValueList,
                    true));
            }

            if (sbProfileSearchCriteria.Length > 0)
            {
                sbSearchCriteria.Append(GetSectionHeaderHTML(Resources.Global.Profile));
                sbSearchCriteria.Append(sbProfileSearchCriteria.ToString());
            }
            #endregion

            if (CompanySearchCriteria.WebUser.prwu_IndustryType != GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                StringBuilder sbLocalSourceSearchCriteria = new StringBuilder();
                if (!String.IsNullOrEmpty(CompanySearchCriteria.IncludeLocalSource))
                {
                    sbLocalSourceSearchCriteria.Append(GetCriteriaHTML("Local Source Data",
                                                                   oPageBase.GetReferenceValue("BBOSSearchLocalSoruce", CompanySearchCriteria.IncludeLocalSource),
                                                                   true));
                }

                if (CompanySearchCriteria.CertifiedOrganic)
                {
                    sbLocalSourceSearchCriteria.Append(GetCriteriaHTML(Resources.Global.GrowsOrganic,
                                                                   Resources.Global.GrowsOrganic,
                                                                    true));
                }

                if (!String.IsNullOrEmpty(CompanySearchCriteria.AlsoOperates))
                {
                    string szAlsoOperatesList = "";
                    string[] aszAlsoOperates = CompanySearchCriteria.AlsoOperates.Split(CompanySearchBase.achDelimiter);

                    foreach (string szAlsoOperates in aszAlsoOperates)
                    {
                        if (!String.IsNullOrEmpty(szAlsoOperates))
                        {
                            if (szAlsoOperatesList.Length > 0)
                                szAlsoOperatesList += ", ";
                            szAlsoOperatesList += oPageBase.GetReferenceValue("prls_AlsoOperates", szAlsoOperates);
                        }
                    }

                    sbLocalSourceSearchCriteria.Append(GetCriteriaHTML(Resources.Global.AlsoOperates,
                                                                    szAlsoOperatesList,
                                                                    true));
                }

                if (!String.IsNullOrEmpty(CompanySearchCriteria.TotalAcres))
                {
                    string szTotalAcresList = "";
                    string[] aszTotalAcres = CompanySearchCriteria.TotalAcres.Split(CompanySearchBase.achDelimiter);

                    foreach (string szTotalAcres in aszTotalAcres)
                    {
                        if (!String.IsNullOrEmpty(szTotalAcres))
                        {
                            if (szTotalAcresList.Length > 0)
                                szTotalAcresList += ", ";
                            szTotalAcresList += oPageBase.GetReferenceValue("prls_TotalAcres", szTotalAcres);
                        }
                    }

                    sbLocalSourceSearchCriteria.Append(GetCriteriaHTML(Resources.Global.TotalAcres,
                                                                    szTotalAcresList,
                                                                    true));
                }


                if (sbLocalSourceSearchCriteria.Length > 0)
                {
                    sbSearchCriteria.Append(GetSectionHeaderHTML(Resources.Global.LocalSourceData));
                    sbSearchCriteria.Append(sbLocalSourceSearchCriteria.ToString());
                }
            }

            #region Custom Search Criteria
            string customSearchCriteria = GetCustomCriteria(CompanySearchCriteria);
            if (customSearchCriteria.Length > 0)
            {
                sbSearchCriteria.Append(GetSectionHeaderHTML(Resources.Global.Custom));
                sbSearchCriteria.Append(customSearchCriteria);
            }
            #endregion

            #region Internal Criteria
            StringBuilder sbInternalCriteria = new StringBuilder();

            // Corporate Structure
            if (!String.IsNullOrEmpty(CompanySearchCriteria.SalesTerritories))
            {
                string szList = "";
                string[] aszSalesTerritories = CompanySearchCriteria.SalesTerritories.Split(CompanySearchBase.achDelimiter);

                foreach (string szSalesTerritory in aszSalesTerritories)
                {
                    if (!String.IsNullOrEmpty(szSalesTerritory))
                    {
                        if (szList.Length > 0)
                            szList += ", ";
                        szList += oPageBase.GetReferenceValue("SalesTerritorySearch", szSalesTerritory);
                    }
                }

                sbInternalCriteria.Append(GetCriteriaHTML("Sales Territory",
                                            szList,
                                            true));
            }

            if (!String.IsNullOrEmpty(CompanySearchCriteria.TerritoryCode))
            {
                sbInternalCriteria.Append(GetCriteriaHTML("Territory Code",
                                                                    oPageBase.GetReferenceValue("prci_SalesTerritory", CompanySearchCriteria.TerritoryCode),
                                                                    true));
            }

            if (!String.IsNullOrEmpty(CompanySearchCriteria.MemberTypeCode))
            {
                sbInternalCriteria.Append(GetCriteriaHTML("Membership Type",
                                          oPageBase.GetReferenceValue("MembershipTypeCode", CompanySearchCriteria.MemberTypeCode),
                                          true));
            }

            if (!String.IsNullOrEmpty(CompanySearchCriteria.PrimaryServiceCodes))
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

                sbInternalCriteria.Append(GetCriteriaHTML("Primary Services",
                                            szList,
                                            true));
            }

            if ((CompanySearchCriteria.NumberLicenses > -1) &&
                (!string.IsNullOrEmpty(CompanySearchCriteria.NumberLicenseSearchType)))
            {
                sbInternalCriteria.Append(GetCriteriaHTML("# of Avail Licences",
                                                            CompanySearchCriteria.NumberLicenseSearchType + " " + CompanySearchCriteria.NumberLicenses.ToString(),
                                                            true));
            }

            if ((CompanySearchCriteria.ActiveLicenses > -1) &&
                (!string.IsNullOrEmpty(CompanySearchCriteria.ActiveLicenseSearchType)))
            {
                sbInternalCriteria.Append(GetCriteriaHTML("# of Active Licenses",
                                                            CompanySearchCriteria.ActiveLicenseSearchType + " " + CompanySearchCriteria.ActiveLicenses.ToString(),
                                                            true));
            }

            if ((CompanySearchCriteria.AvailableUnits > -1) &&
                (!string.IsNullOrEmpty(CompanySearchCriteria.AvailableUnitsSearchType)))
            {
                sbInternalCriteria.Append(GetCriteriaHTML("# of Units Avail",
                                                            CompanySearchCriteria.AvailableUnitsSearchType + " " + CompanySearchCriteria.AvailableUnits.ToString("###,##0"),
                                                            true));
            }

            if ((CompanySearchCriteria.UsedUnits > -1) &&
                (!string.IsNullOrEmpty(CompanySearchCriteria.UsedUnitsSearchType)))
            {
                sbInternalCriteria.Append(GetCriteriaHTML("# of Units Used",
                                                            CompanySearchCriteria.UsedUnitsSearchType + " " + CompanySearchCriteria.UsedUnits.ToString("###,##0"),
                                                            true));
            }

            if (CompanySearchCriteria.ReceivesPromoFaxes)
            {
                sbInternalCriteria.Append(GetCriteriaHTML("Receives Promo Faxes",
                                                          "Receives Promo Faxes",
                                                          true));
            }


            if (CompanySearchCriteria.ReceivesPromoEmails)
            {
                sbInternalCriteria.Append(GetCriteriaHTML("Receives Promo Emails",
                                                          "Receives Promo Emails",
                                                          true));
            }

            if ((CompanySearchCriteria.MembershipRevenue > -1) &&
                (!string.IsNullOrEmpty(CompanySearchCriteria.MembershipRevenueSearchType)))
            {
                sbInternalCriteria.Append(GetCriteriaHTML("Membership Revenue",
                                                            CompanySearchCriteria.MembershipRevenueSearchType + " $" + CompanySearchCriteria.MembershipRevenue.ToString("###,###,##0.00"),
                                                            true));
            }


            if ((CompanySearchCriteria.AdvertisingRevenue > -1) &&
                (!string.IsNullOrEmpty(CompanySearchCriteria.AdvertisingRevenueSearchType)))
            {
                sbInternalCriteria.Append(GetCriteriaHTML("Advertising Revenue",
                                                            CompanySearchCriteria.AdvertisingRevenueSearchType + " $" + CompanySearchCriteria.AdvertisingRevenue.ToString("###,###,##0.00"),
                                                            true));
            }



            if (sbInternalCriteria.Length > 0)
            {
                sbSearchCriteria.Append(GetSectionHeaderHTML("Internal Criteria"));
                sbSearchCriteria.Append(sbInternalCriteria.ToString());
            }
            #endregion

            if (sbSearchCriteria.Length == 0)
            {
                sbSearchCriteria.Append("<span style=\"font-weight:bold;\">" + Resources.Global.NoCriteriaSelected + "</span>");
            }

            lblSearchCriteria.Text = sbSearchCriteria.ToString();
            return sbSearchCriteria.ToString();
        }

        string RemoveBetween(string s, char begin, char end)
        {
            Regex regex = new Regex(string.Format("\\{0}.*?\\{1}", begin, end));
            return regex.Replace(s, string.Empty);
        }
    }
}