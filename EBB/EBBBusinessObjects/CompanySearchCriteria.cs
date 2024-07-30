/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2024

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

 Notes:	Created By Sharon Cole on 7/17/2007 3:17:32 PM

***********************************************************************
***********************************************************************/

using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Text;

using TSI.Arch;
using TSI.BusinessObjects;
using TSI.DataAccess;
using TSI.Utils;


namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Provides the functionality for the CompanySearchCriteria
    /// </summary>
    [Serializable]
    public class CompanySearchCriteria : SearchCriteriaBase
    {
        protected string _szCompanyType;
        protected string _szListingStatus;
        protected string _szPhoneAreaCode;
        protected string _szPhoneNumber;
        protected string _szFaxAreaCode;
        protected string _szFaxNumber;
        protected string _szEmail;

        protected string _szFTEmployeeCodes;
        protected string _szClassificationIDs;
        protected string _szClassificationSearchType;
        protected string _szCommodityDisplayType;
        protected string _szCommodityIDs;
        protected string _szNumberOfRetailStores;
        protected string _szNumberOfRestaurantStores;
        protected string _szCommoditySearchType;
        protected string _szMemberYearSearchType;
        protected string _szBBScoreSearchType;
        protected string _szPayReportCountSearchType;
        protected string _szRatingCreditWorthIDs;
        protected string _szRatingCreditWorthMinID;
        protected string _szRatingCreditWorthMaxID;
        protected string _szRatingIntegrityIDs;
        protected string _szRatingPayIDs;
        protected string _szPayIndicator;
        protected string _szRatingNumeralIDs;
        protected string _szRatingNumeralSearchType;
        protected string _szLicenseTypes;
        protected string _szLicenseNumber;
        protected string _szBrands;
        protected string _szCorporateStructure;
        protected string _szDescriptiveLines;
        protected string _szVolume;
        protected string _szVolumeMin;
        protected string _szVolumeMax;
        protected string _szSpecieIDs;
        protected string _szSpecieSearchType;
        protected string _szServiceProvidedIDs;
        protected string _szServiceProvidedSearchType;
        protected string _szProductProvidedIDs;
        protected string _szProductProvidedSearchType;
        protected string _szPubliclyTraded;
        protected string _szStockSymbol;

        protected string _szSalesTerritories;
		protected string _szTerritoryCode; 
        protected string _szPrimaryServiceCodes;
        protected string _szMemberTypeCode;
        protected int _iNumberLicenses = -1;
        protected string _szNumberLicenseSearchType;
        protected int _iActiveLicenses = -1;
        protected string _szActiveLicenseSearchType;
        protected bool _bReceivesPromoEmails;
        protected bool _bReceivesPromoFaxes;
        protected decimal _dMembershipRevenue = -1;
        protected string _szMembershipRevenueSearchType;
        protected decimal _dAdvertisingRevenue = -1;
        protected string _szAdvertisingRevenueSearchType;
        protected int _iAvailableUnits = -1;
        protected string _szAvailableUnitsSearchType;
        protected int _iUsedUnits = -1;
        protected string _szUsedUnitsSearchType;

        protected bool _bFaxNotNull;
        protected bool _bPhoneNotNull;

        protected bool _bEmailNotNull;
        protected bool _bNewListingOnly;
        protected bool _bIsTMFM;
        protected bool _bOrganic;
        protected bool _bFoodSafetyCertified;
        protected bool _bUnratedCompaniesOnly;

        protected bool _bSalvageDistressedProduce;

        protected int _iNewListingDaysOld;
        protected int _iCommodityGMAttributeID;
        protected int _iCommodityAttributeID;
        protected int _iMemberYear;
        protected int _iBBScore;
        protected int _iPayReportCount;


        // CRM Company Table Constants
        public const string COL_COMPANY_TYPE = "Comp_PRType";
        public const string COL_COMPANY_INDUSTRYTYPE = "comp_PRIndustryType";
        public const string COL_COMPANY_LISTEDDATE = "comp_PRListedDate";
        public const string COL_COMPANY_LISTINGCITYID = "comp_PRListingCityId";
        public const string COL_COMPANY_LISTINGSTATUS = "comp_PRListingStatus";
        public const string COL_COMPANY_MEMBERYEAR = "YEAR(comp_PRTMFMAwardDate)";

        // CRM Email Table Constants
        public const string TAB_EMAIL = "Email";

        public const string COL_EMAIL_COMPANYID = "elink_RecordID";
        public const string COL_EMAIL_EMAILADDRESS = "Emai_EmailAddress";
        public const string COL_EMAIL_TYPE = "elink_Type";
        public const string COL_EMAIL_PUBLISH = "Emai_PRPublish";

        public const string CODE_EMAILTYPE_E = "E";

        public const string CODE_PHONETYPE_PHONE = "P";
        public const string CODE_PHONETYPE_FAX = "F";

        // CRM PRCompanyBrand Table Constants
        public const string TAB_PRCOMPANYBRAND = "PRCompanyBrand";

        public const string COL_PRCOMPANYBRAND_COMPANYID = "prc3_CompanyId";
        public const string COL_PRCOMPANYBRAND_BRAND = "prc3_Brand";
        public const string COL_PRCOMPANYBRAND_PUBLISH = "prc3_Publish";

        // CRM PRCompanyClassification Table Constants
        public const string TAB_PRCOMPANYCLASSIFICATION = "PRCompanyClassification";

        public const string COL_PRCOMPANYCLASSIFICATION_COMPANYID = "prc2_CompanyId";
        public const string COL_PRCOMPANYCLASSIFICATION_CLASSIFICATIONID = "prc2_ClassificationId";
        public const string COL_PRCOMPANYCLASSIFICATION_NUMOFRETAIL = "prc2_NumberOfStores";
        public const string COL_PRCOMPANYCLASSIFICATION_NUMOFRESTAURANT = "prc2_NumberOfStores";

        // CRM PRCompanyCommodityAttribute table constants
        public const string TAB_PRCOMPANYCOMMODITYATTRIBUTE = "PRCompanyCommodityAttribute";

        public const string COL_PRCOMPANYCOMMODITYATTRIBUTE_COMPANYID = "prcca_CompanyId";
        public const string COL_PRCOMPANYCOMMODITYATTRIBUTE_COMMODITYID = "prcca_CommodityId";
        public const string COL_PRCOMPANYCOMMODITYATTRIBUTE_ATTRIBUTEID = "prcca_AttributeId";
        public const string COL_PRCOMPANYCOMMODITYATTRIBUTE_GMATTRIBUTEID = "prcca_GrowingMethodId";
        public const string COL_PRCOMPANYCOMMODITYATTRIBUTE_PUBLISH = "prcca_Publish";

        // CRM PRCompanyLicense table constants
        public const string TAB_PRCOMPANYLICENSE = "PRCompanyLicense";

        public const string COL_PRCOMPANYLICENSE_COMPANYID = "prli_CompanyId";
        public const string COL_PRCOMPANYLICENSE_TYPE = "prli_Type";
        public const string COL_PRCOMPANYLICENSE_NUMBER = "prli_Number";
        public const string COL_PRCOMPANYLICENSE_PUBLISH = "prli_Publish";

        // CRM PRCompanyProfile table constants
        public const string TAB_PRCOMPANYPROFILE = "PRCompanyProfile";
        public const string TAB_PRCOMPANYPROFILE_LEFT_JOIN_PRCOMPANYEXPERIAN =
                @"Company WITH (NOLOCK) LEFT OUTER JOIN PRCompanyProfile WITH (NOLOCK) ON comp_CompanyID = prcp_CompanyId 
                                        LEFT OUTER JOIN PRCompanyExperian WITH(NOLOCK) ON comp_CompanyID = prcex_CompanyID";

        public const string COL_PRCOMPANYPROFILE_COMPANYID = "prcp_CompanyId";
        public const string COL_COMP_COMPANYID = "comp_CompanyId";
        public const string COL_PRCOMPANYPROFILE_CORPSTRUCTURE = "prcp_CorporateStructure";
        public const string COL_PRCOMPANYPROFILE_VOLUME = "prcp_Volume";

        // CRM PRDescriptiveLine table constants
        public const string TAB_PRDESCRIPTIVELINE = "PRDescriptiveLine";

        public const string COL_PRDESCRIPTIVELINE_COMPANYID = "prdl_CompanyId";
        public const string COL_PRDESCRIPTIVELINE_LINECONTENT = "prdl_LineContent";

        // CRM PRDRCLicense table constants
        public const string TAB_PRDRCLICENSE = "PRDRCLicense";

        public const string COL_PRDRCLICENSE_COMPANYID = "prdr_CompanyId";
        public const string COL_PRDRCLICENSE_PUBLISH = "prdr_Publish";

        // CRM PRPACALicense table constants
        public const string TAB_PRPACALICENSE = "PRPACALicense";

        public const string COL_PRPACALICENSE_COMPANYID = "prpa_CompanyId";
        public const string COL_PRPACALICENSE_PUBLISH = "prpa_Publish";

        // CRM PRRating table constants
        public const string TAB_PRRATING = "PRRating";

        public const string COL_PRRATING_COMPANYID = "prra_CompanyId";
        public const string COL_PRRATING_CREDITWORTHID = "prra_CreditWorthId";
        public const string COL_PRRATING_INTEGRITYID = "prra_IntegrityId";
        public const string COL_PRRATING_PAYID = "prra_PayRatingId";
        public const string COL_PRRATING_CURRENT = "prra_Current";

        // CRM PRCompanyPayIndicator table constants
        public const string COL_PRCOMPANY_PAYINDICATORID = "prcpi_PayIndicator";

        // Other Search Constants
        public const string CODE_SEARCHTYPE_ANY = "Any";
        public const string CODE_SEARCHTYPE_ALL = "All";
        public const string CODE_SEARCHTYPE_ONLY = "Only";

        // SQL Constants
        protected const string SQL_SUB_SELECT_LISTING_CITY_ID = COL_COMPANY_LISTINGCITYID + " IN (SELECT {0} FROM {1} WHERE {2})";

        protected const string SQL_MISC_LISTING_TEXT =
            @"SELECT prlst_CompanyID 
                FROM PRListing WITH (NOLOCK)  
               WHERE prlst_Listing ";

        protected const string SELECT_ALL = 
            @"SELECT {1} 
			    FROM {0} WITH (NOLOCK) 
			   WHERE {2} IN ({3}) 
		    GROUP BY {1} 
			  HAVING COUNT(DISTINCT {2}) = {4} ";

        /// <summary>
        /// Constructor
        /// </summary>
        public CompanySearchCriteria() { }

        #region Property Accessors

        public int UsedUnits
        {
            get { return _iUsedUnits; }
            set
            {
                SetDirty(value, _iUsedUnits);
                _iUsedUnits = value;
            }
        }

        public string UsedUnitsSearchType
        {
            get { return _szUsedUnitsSearchType; }
            set
            {
                SetDirty(value, _szUsedUnitsSearchType);
                _szUsedUnitsSearchType = value;
            }
        }

        public int AvailableUnits
        {
            get { return _iAvailableUnits; }
            set
            {
                SetDirty(value, _iAvailableUnits);
                _iAvailableUnits = value;
            }
        }

        public string AvailableUnitsSearchType
        {
            get { return _szAvailableUnitsSearchType; }
            set
            {
                SetDirty(value, _szAvailableUnitsSearchType);
                _szAvailableUnitsSearchType = value;
            }
        }

        public decimal AdvertisingRevenue
        {
            get { return _dAdvertisingRevenue; }
            set
            {
                SetDirty(value, _dAdvertisingRevenue);
                _dAdvertisingRevenue = value;
            }
        }

        public string AdvertisingRevenueSearchType
        {
            get { return _szAdvertisingRevenueSearchType; }
            set
            {
                SetDirty(value, _szAdvertisingRevenueSearchType);
                _szAdvertisingRevenueSearchType = value;
            }
        }


        public decimal MembershipRevenue
        {
            get { return _dMembershipRevenue; }
            set
            {
                SetDirty(value, _dMembershipRevenue);
                _dMembershipRevenue = value;
            }
        }

        public string MembershipRevenueSearchType
        {
            get { return _szMembershipRevenueSearchType; }
            set
            {
                SetDirty(value, _szMembershipRevenueSearchType);
                _szMembershipRevenueSearchType = value;
            }
        }

        public string SalesTerritories
        {
            get { return _szSalesTerritories; }
            set
            {
                SetDirty(value, _szSalesTerritories);
                _szSalesTerritories = value;
            }
        }

		public string TerritoryCode
		{
			get { return _szTerritoryCode; }
			set
			{
				SetDirty(value, _szTerritoryCode);
				_szTerritoryCode = value;
			}
		}

		public string PrimaryServiceCodes
        {
            get { return _szPrimaryServiceCodes; }
            set
            {
                SetDirty(value, _szPrimaryServiceCodes);
                _szPrimaryServiceCodes = value;
            }
        }

        public string MemberTypeCode
        {
            get { return _szMemberTypeCode; }
            set
            {
                SetDirty(value, _szMemberTypeCode);
                _szMemberTypeCode = value;
            }
        }

        public int NumberLicenses
        {
            get { return _iNumberLicenses; }
            set
            {
                SetDirty(value, _iNumberLicenses);
                _iNumberLicenses = value;
            }
        }

        public int ActiveLicenses
        {
            get { return _iActiveLicenses; }
            set
            {
                SetDirty(value, _iActiveLicenses);
                _iActiveLicenses = value;
            }
        }

        public string NumberLicenseSearchType
        {
            get { return _szNumberLicenseSearchType; }
            set
            {
                SetDirty(value, _szNumberLicenseSearchType);
                _szNumberLicenseSearchType = value;
            }
        }


        public string ActiveLicenseSearchType
        {
            get { return _szActiveLicenseSearchType; }
            set
            {
                SetDirty(value, _szActiveLicenseSearchType);
                _szActiveLicenseSearchType = value;
            }
        }


        /// <summary>
        /// Accessor for the CompanyType property
        /// </summary>
        public string CompanyType
        {
            get { return _szCompanyType; }
            set
            {
                SetDirty(value, _szCompanyType);
                _szCompanyType = value;
            }
        }

        /// <summary>
        /// Accessor for the ListingStatus property
        /// </summary>
        public string ListingStatus
        {
            get { return _szListingStatus; }
            set
            {
                SetDirty(value, _szListingStatus);
                _szListingStatus = value;
            }
        }

        /// <summary>
        /// Accessor for the PhoneAreaCode property
        /// </summary>
        public string PhoneAreaCode
        {
            get { return _szPhoneAreaCode; }
            set
            {
                SetDirty(value, _szPhoneAreaCode);
                _szPhoneAreaCode = value;
            }
        }

        /// <summary>
        /// Accessor for the PhoneNumber property
        /// </summary>
        public string PhoneNumber
        {
            get { return _szPhoneNumber; }
            set
            {
                SetDirty(value, _szPhoneNumber);
                _szPhoneNumber = value;
            }
        }

        /// <summary>
        /// Accessor for the FaxAreaCode property
        /// </summary>
        public string FaxAreaCode
        {
            get { return _szFaxAreaCode; }
            set
            {
                SetDirty(value, _szFaxAreaCode);
                _szFaxAreaCode = value;
            }
        }

        /// <summary>
        /// Accessor for the FaxNumber property
        /// </summary>
        public string FaxNumber
        {
            get { return _szFaxNumber; }
            set
            {
                SetDirty(value, _szFaxNumber);
                _szFaxNumber = value;
            }
        }

        /// <summary>
        /// Accessor for the Email property
        /// </summary>
        public string Email
        {
            get { return _szEmail; }
            set
            {
                SetDirty(value, _szEmail);
                _szEmail = value;
            }
        }

        /// <summary>
        /// Accessor for the ClassificationIDs property
        /// </summary>
        public string ClassificationIDs
        {
            get { return _szClassificationIDs; }
            set
            {
                SetDirty(value, _szClassificationIDs);
                _szClassificationIDs = value;
            }
        }

        /// <summary>
        /// Accessor for the ClassificationSearchType property
        /// </summary>
        public string ClassificationSearchType
        {
            get { return _szClassificationSearchType; }
            set
            {
                SetDirty(value, _szClassificationSearchType);
                _szClassificationSearchType = value;
            }
        }

        /// <summary>
        /// Accessor for the CommodityIDs property
        /// </summary>
        public string CommodityIDs
        {
            get { return _szCommodityIDs; }
            set
            {
                SetDirty(value, _szCommodityIDs);
                _szCommodityIDs = value;
            }
        }

        /// <summary>
        /// Accessor for the CommodityDisplayType property
        /// </summary>
        public string CommodityDisplayType
        {
            get { return _szCommodityDisplayType; }
            set
            {
                SetDirty(value, _szCommodityDisplayType);
                _szCommodityDisplayType = value;
            }
        }

        /// <summary>
        /// Accessor for the NumberOfRetailStores property
        /// </summary>
        public string NumberOfRetailStores
        {
            get { return _szNumberOfRetailStores; }
            set
            {
                SetDirty(value, _szNumberOfRetailStores);
                _szNumberOfRetailStores = value;
            }
        }

        /// <summary>
        /// Accessor for the NumberOfRestaurantStores property
        /// </summary>
        public string NumberOfRestaurantStores
        {
            get { return _szNumberOfRestaurantStores; }
            set
            {
                SetDirty(value, _szNumberOfRestaurantStores);
                _szNumberOfRestaurantStores = value;
            }
        }

        /// <summary>
        /// Accessor for the CommoditySearchType property
        /// </summary>
        public string CommoditySearchType
        {
            get { return _szCommoditySearchType; }
            set
            {
                SetDirty(value, _szCommoditySearchType);
                _szCommoditySearchType = value;
            }
        }

        /// <summary>
        /// Accessor for the MemberYearSearchType property
        /// </summary>
        public string MemberYearSearchType
        {
            get { return _szMemberYearSearchType; }
            set
            {
                SetDirty(value, _szMemberYearSearchType);
                _szMemberYearSearchType = value;
            }
        }

        /// <summary>
        /// Accessor for the BBScoreSearchType property
        /// </summary>
        public string BBScoreSearchType
        {
            get { return _szBBScoreSearchType; }
            set
            {
                SetDirty(value, _szBBScoreSearchType);
                _szBBScoreSearchType = value;
            }
        }

        /// <summary>
        /// Accessor for the PayReportCountSearchType property
        /// </summary>
        public string PayReportCountSearchType
        {
            get { return _szPayReportCountSearchType; }
            set
            {
                SetDirty(value, _szPayReportCountSearchType);
                _szPayReportCountSearchType = value;
            }
        }
        /// <summary>
        /// Accessor for the RatingCreditWorthIDs property
        /// </summary>
        public string RatingCreditWorthIDs
        {
            get { return _szRatingCreditWorthIDs; }
            set
            {
                SetDirty(value, _szRatingCreditWorthIDs);
                _szRatingCreditWorthIDs = value;
            }
        }
        /// <summary>
        /// Accessor for the RatingCreditWorthMinID property
        /// </summary>
        public string RatingCreditWorthMinID
        {
            get { return _szRatingCreditWorthMinID; }
            set
            {
                SetDirty(value, _szRatingCreditWorthMinID);
                _szRatingCreditWorthMinID = value;
            }
        }
        /// <summary>
        /// Accessor for the RatingCreditWorthMaxID property
        /// </summary>
        public string RatingCreditWorthMaxID
        {
            get { return _szRatingCreditWorthMaxID; }
            set
            {
                SetDirty(value, _szRatingCreditWorthMaxID);
                _szRatingCreditWorthMaxID = value;
            }
        }

        public bool UnratedCompaniesOnly
        {
            get { return _bUnratedCompaniesOnly; }
            set
            {
                SetDirty(value, _bUnratedCompaniesOnly);
                _bUnratedCompaniesOnly = value;
            }
        }

        public bool SalvageDistressedProduce
        {
            get { return _bSalvageDistressedProduce; }
            set
            {
                SetDirty(value, _bSalvageDistressedProduce);
                _bSalvageDistressedProduce = value;
            }
        }
            
        public string FullTimeEmployeeCodes
        {
            get { return _szFTEmployeeCodes; }
            set
            {
                SetDirty(value, _szFTEmployeeCodes);
                _szFTEmployeeCodes = value;
            }
        }

        /// <summary>
        /// Accessor for the RatingIntegrityIDs property
        /// </summary>
        public string RatingIntegrityIDs
        {
            get { return _szRatingIntegrityIDs; }
            set
            {
                SetDirty(value, _szRatingIntegrityIDs);
                _szRatingIntegrityIDs = value;
            }
        }

        /// <summary>
        /// Accessor for the RatingPayIDs property
        /// </summary>
        public string RatingPayIDs
        {
            get { return _szRatingPayIDs; }
            set
            {
                SetDirty(value, _szRatingPayIDs);
                _szRatingPayIDs = value;
            }
        }

        /// <summary>
        /// Accessor for the PayIndicator property
        /// </summary>
        public string PayIndicator
        {
            get { return _szPayIndicator; }
            set
            {
                SetDirty(value, _szPayIndicator);
                _szPayIndicator = value;
            }
        }

        /// <summary>
        /// Accessor for the RatingNumeralIDs property
        /// </summary>
        public string RatingNumeralIDs
        {
            get { return _szRatingNumeralIDs; }
            set
            {
                SetDirty(value, _szRatingNumeralIDs);
                _szRatingNumeralIDs = value;
            }
        }

        /// <summary>
        /// Accessor for the RatingNumeralSearchType property
        /// </summary>
        public string RatingNumeralSearchType
        {
            get { return _szRatingNumeralSearchType; }
            set
            {
                SetDirty(value, _szRatingNumeralSearchType);
                _szRatingNumeralSearchType = value;
            }
        }

        /// <summary>
        /// Accessor for the LicenseTypes property
        /// </summary>
        public string LicenseTypes
        {
            get { return _szLicenseTypes; }
            set
            {
                SetDirty(value, _szLicenseTypes);
                _szLicenseTypes = value;
            }
        }

        /// <summary>
        /// Accessor for the LicenseNumber property
        /// </summary>
        public string LicenseNumber
        {
            get { return _szLicenseNumber; }
            set
            {
                SetDirty(value, _szLicenseNumber);
                _szLicenseNumber = value;
            }
        }

        /// <summary>
        /// Accessor for the Brands property
        /// </summary>
        public string Brands
        {
            get { return _szBrands; }
            set
            {
                SetDirty(value, _szBrands);
                _szBrands = value;
            }
        }

        /// <summary>
        /// Accessor for the CorporateStructure property
        /// </summary>
        public string CorporateStructure
        {
            get { return _szCorporateStructure; }
            set
            {
                SetDirty(value, _szCorporateStructure);
                _szCorporateStructure = value;
            }
        }

        /// <summary>
        /// Accessor for the DescriptiveLines property
        /// </summary>
        public string DescriptiveLines
        {
            get { return _szDescriptiveLines; }
            set
            {
                SetDirty(value, _szDescriptiveLines);
                _szDescriptiveLines = value;
            }
        }

        /// <summary>
        /// Accessor for the Volume property
        /// </summary>
        public string Volume
        {
            get { return _szVolume; }
            set
            {
                SetDirty(value, _szVolume);
                _szVolume = value;
            }
        }

        /// <summary>
        /// Accessor for the VolumeMin property
        /// </summary>
        public string VolumeMin
        {
            get { return _szVolumeMin; }
            set
            {
                SetDirty(value, _szVolumeMin);
                _szVolumeMin = value;
            }
        }

        /// <summary>
        /// Accessor for the VolumeMax property
        /// </summary>
        public string VolumeMax
        {
            get { return _szVolumeMax; }
            set
            {
                SetDirty(value, _szVolumeMax);
                _szVolumeMax = value;
            }
        }

        /// <summary>
        /// Accessor for the FaxNotNull property
        /// </summary>
        public bool FaxNotNull
        {
            get { return _bFaxNotNull; }
            set
            {
                SetDirty(value, _bFaxNotNull);
                _bFaxNotNull = value;
            }
        }

        /// <summary>
        /// Accessor for the PhoneNotNull property
        /// </summary>
        public bool PhoneNotNull
        {
            get { return _bPhoneNotNull; }
            set
            {
                SetDirty(value, _bPhoneNotNull);
                _bPhoneNotNull = value;
            }
        }

        /// <summary>
        /// Accessor for the EmailNotNull property
        /// </summary>
        public bool EmailNotNull
        {
            get { return _bEmailNotNull; }
            set
            {
                SetDirty(value, _bEmailNotNull);
                _bEmailNotNull = value;
            }
        }

        /// <summary>
        /// Accessor for the NewListingOnly property
        /// </summary>
        public bool NewListingOnly
        {
            get { return _bNewListingOnly; }
            set
            {
                SetDirty(value, _bNewListingOnly);
                _bNewListingOnly = value;
            }
        }

        /// <summary>
        /// Accessor for the IsTMFM property
        /// </summary>
        public bool IsTMFM
        {
            get { return _bIsTMFM; }
            set
            {
                SetDirty(value, _bIsTMFM);
                _bIsTMFM = value;
            }
        }


        /// <summary>
        /// Accessor for the Organic property
        /// </summary>
        public bool Organic
        {
            get { return _bOrganic; }
            set
            {
                SetDirty(value, _bOrganic);
                _bOrganic = value;
            }
        }


        /// <summary>
        /// Accessor for the FoodSafetyCertified property
        /// </summary>
        public bool FoodSafetyCertified
        {
            get { return _bFoodSafetyCertified; }
            set
            {
                SetDirty(value, _bFoodSafetyCertified);
                _bFoodSafetyCertified = value;
            }
        }

        /// <summary>
        /// Accessor for the NewListingDaysOld property
        /// </summary>
        public int NewListingDaysOld
        {
            get { return _iNewListingDaysOld; }
            set
            {
                SetDirty(value, _iNewListingDaysOld);
                _iNewListingDaysOld = value;
            }
        }


        public bool ReceivesPromoEmails
        {
            get { return _bReceivesPromoEmails; }
            set
            {
                SetDirty(value, _bReceivesPromoEmails);
                _bReceivesPromoEmails = value;
            }
        }

        public bool ReceivesPromoFaxes
        {
            get { return _bReceivesPromoFaxes; }
            set
            {
                SetDirty(value, _bReceivesPromoFaxes);
                _bReceivesPromoFaxes = value;
            }
        }

        /// <summary>
        /// Accessor for the CommodityGMAttributeID property
        /// </summary>
        public int CommodityGMAttributeID
        {
            get { return _iCommodityGMAttributeID; }
            set
            {
                SetDirty(value, _iCommodityGMAttributeID);
                _iCommodityGMAttributeID = value;
            }
        }

        /// <summary>
        /// Accessor for the CommodityAttributeID property
        /// </summary>
        public int CommodityAttributeID
        {
            get { return _iCommodityAttributeID; }
            set
            {
                SetDirty(value, _iCommodityAttributeID);
                _iCommodityAttributeID = value;
            }
        }

        /// <summary>
        /// Accessor for the MemberYear property
        /// </summary>
        public int MemberYear
        {
            get { return _iMemberYear; }
            set
            {
                SetDirty(value, _iMemberYear);
                _iMemberYear = value;
            }
        }

        /// <summary>
        /// Accessor for the BBScore property
        /// </summary>
        public int BBScore
        {
            get { return _iBBScore; }
            set
            {
                SetDirty(value, _iBBScore);
                _iBBScore = value;
            }
        }

        /// <summary>
        /// Accessor for the PayReportCount property
        /// </summary>
        public int PayReportCount
        {
            get { return _iPayReportCount; }
            set
            {
                SetDirty(value, _iPayReportCount);
                _iPayReportCount = value;
            }
        }
        /// <summary>
        /// Accessor for the SpecieID property
        /// </summary>
        public string SpecieIDs
        {
            get { return _szSpecieIDs; }
            set
            {
                SetDirty(value, _szSpecieIDs);
                _szSpecieIDs = value;
            }
        }

        /// <summary>
        /// Accessor for the SpecieSearchType property
        /// </summary>
        public string SpecieSearchType
        {
            get { return _szSpecieSearchType; }
            set
            {
                SetDirty(value, _szSpecieSearchType);
                _szSpecieSearchType = value;
            }
        }

        /// <summary>
        /// Accessor for the ServiceProvidedIDs property
        /// </summary>
        public string ServiceProvidedIDs
        {
            get { return _szServiceProvidedIDs; }
            set
            {
                SetDirty(value, _szServiceProvidedIDs);
                _szServiceProvidedIDs = value;
            }
        }

        /// <summary>
        /// Accessor for the ServiceProvidedSearchType property
        /// </summary>
        public string ServiceProvidedSearchType
        {
            get { return _szServiceProvidedSearchType; }
            set
            {
                SetDirty(value, _szServiceProvidedSearchType);
                _szServiceProvidedSearchType = value;
            }
        }


        /// <summary>
        /// Accessor for the ProductProvidedIDs property
        /// </summary>
        public string ProductProvidedIDs
        {
            get { return _szProductProvidedIDs; }
            set
            {
                SetDirty(value, _szProductProvidedIDs);
                _szProductProvidedIDs = value;
            }
        }

        /// <summary>
        /// Accessor for the ProductProvidedSearchType property
        /// </summary>
        public string ProductProvidedSearchType
        {
            get { return _szProductProvidedSearchType; }
            set
            {
                SetDirty(value, _szProductProvidedSearchType);
                _szProductProvidedSearchType = value;
            }
        }

        public string PubliclyTraded
        {
            get { return _szPubliclyTraded; }
            set
            {
                SetDirty(value, _szPubliclyTraded);
                _szPubliclyTraded = value;
            }
        }

        public string StockSymbol
        {
            get { return _szStockSymbol; }
            set
            {
                SetDirty(value, _szStockSymbol);
                _szStockSymbol = value;
            }
        }


        protected string _szAlsoOperates;
        protected string _szTotalAcres;
        protected bool _bCertifiedOrganic;

        public string AlsoOperates
        {
            get { return _szAlsoOperates; }
            set
            {
                SetDirty(value, _szAlsoOperates);
                _szAlsoOperates = value;
            }
        }

        public string TotalAcres
        {
            get { return _szTotalAcres; }
            set
            {
                SetDirty(value, _szTotalAcres);
                _szTotalAcres = value;
            }
        }

        public bool CertifiedOrganic
        {
            get { return _bCertifiedOrganic; }
            set
            {
                SetDirty(value, _bCertifiedOrganic);
                _bCertifiedOrganic = value;
            }
        }






        private IList<PRWebUserCustomFieldSearchCriteria> _customFieldSearchCriteria = null;

        public IList<PRWebUserCustomFieldSearchCriteria> CustomFieldSearchCriteria
        {
            get { return _customFieldSearchCriteria; }
        }

        #endregion

        public void ClearCustomFieldSearchCriteria()
        {
            _customFieldSearchCriteria = null;
        }

        public void AddCustomFieldSearchCriteria(int customFieldID, int customFieldLookupID) {
            PRWebUserCustomFieldSearchCriteria customFieldSearchCriteria = AddCompanySearchCriteria(customFieldID);
            customFieldSearchCriteria.CustomFieldLookupID = customFieldLookupID;
        }
            
        public void AddCustomFieldSearchCriteria(int customFieldID, string searchValue) {
            PRWebUserCustomFieldSearchCriteria customFieldSearchCriteria = AddCompanySearchCriteria(customFieldID);
            customFieldSearchCriteria.SearchValue = searchValue;
        }

        public void AddCustomFieldSearchCriteria(int customFieldID, bool mustHaveValue)
        {
            PRWebUserCustomFieldSearchCriteria customFieldSearchCriteria = AddCompanySearchCriteria(customFieldID);
            customFieldSearchCriteria.MustHaveValue = mustHaveValue;
        }

        private PRWebUserCustomFieldSearchCriteria AddCompanySearchCriteria(int customFieldID)
        {
            PRWebUserCustomFieldSearchCriteria customFieldSearchCriteria = new PRWebUserCustomFieldSearchCriteria();
            customFieldSearchCriteria.CustomFieldID = customFieldID;

            if (_customFieldSearchCriteria == null)
            {
                _customFieldSearchCriteria = new List<PRWebUserCustomFieldSearchCriteria>();
            }
            _customFieldSearchCriteria.Add(customFieldSearchCriteria);

            return customFieldSearchCriteria;
        }




        /// <summary>
        /// Generates the Search SQL based on the Search
        /// Criteria.
        /// </summary>
        /// <param name="oParams">Parameter List</param>
        /// <returns>Search SQL String</returns>
        override public string GetSearchSQL(out ArrayList oParams)
        {
            oParams = new ArrayList();

            string szFrom = BuildFromClause();
            string szWhere = BuildWhereClause(oParams);

            if (string.IsNullOrEmpty(szWhere))
            {
                throw new ApplicationUnexpectedException("No Search Criteria Found.");
            }

            string szOrderBy = BuildOrderByClause();
            string szSQL = "SELECT Comp_CompanyID " + szFrom + " WHERE " + szWhere + szOrderBy;

            return szSQL;
        }

        /// <summary>
        /// Returns the SQL to count the number of rows that would be 
        /// returned by the specified criteria.
        /// </summary>
        /// <param name="oParams"></param>
        /// <returns></returns>
        override public string GetSearchCountSQL(out ArrayList oParams)
        {
            oParams = new ArrayList();

            string szFrom = BuildFromClause();
            string szWhere = BuildWhereClause(oParams);
            
            if (string.IsNullOrEmpty(szWhere)) {
                throw new ApplicationUnexpectedException("No company search criteria found.");
            }

            return "SELECT COUNT(DISTINCT comp_CompanyID) As CNT " + szFrom + " WHERE " + szWhere;
        }

        /// <summary>
        /// Builds the appropriate WHERE clause based on the criteria
        /// specified.
        /// </summary>
        /// <param name="oParameters">Parameter List</param>
        /// <returns>WHERE Clause</returns>
        override protected string BuildWhereClause(IList oParameters)
        {
            StringBuilder sbWhereClause = new StringBuilder();
            StringBuilder sbSubSelectWhere = new StringBuilder();

            // Process Quick Search Items
            if (_bIsQuickSearch)
            {
                // NOTE: For Quick Search, if multiple fields are populated, these should be OR'd together
                // instead of using AND

                // Company Name Criteria
                if (!String.IsNullOrEmpty(_szCompanyName))
                {
                    sbSubSelectWhere.Length = 0;
                    SetOrConnector();

                    // If the name is surrounded by double quotes, we want to search the
                    // company name field, not the search field that strips all punctuation.
                    if (IsExactSearch(_szCompanyName)) {
                        string parmValue = " " + _szCompanyName.Substring(1, _szCompanyName.Length - 2) + " ";
                        oParameters.Add(new ObjectParameter("CompanyName", _oDBAccess.TranslateWildCards(parmValue)));

                        AddNameSearchCondition(sbWhereClause, "CompanyName", "comp_Name", "LIKE");
                        AddNameSearchCondition(sbWhereClause, "CompanyName", "comp_PRLegalName", "LIKE");

                        sbSubSelectWhere.Length = 0;
                        AddNameSearchCondition(sbSubSelectWhere, "CompanyName", "pral_Alias", "LIKE");
                        AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, "pral_CompanyId", "PRCompanyAlias", sbSubSelectWhere);

                    } else {
                        string parmValue = prepareName(_szCompanyName, true);
                        oParameters.Add(new ObjectParameter("CompanyName", _oDBAccess.TranslateWildCards(parmValue)));

                        AddNameSearchCondition(sbWhereClause, "CompanyName", "prcse_NameMatch", "LIKE");
                        AddNameSearchCondition(sbWhereClause, "CompanyName", "prcse_LegalNameMatch", "LIKE");

                        sbSubSelectWhere.Length = 0;
                        AddNameSearchCondition(sbSubSelectWhere, "CompanyName", "pral_NameAlphaOnly", "LIKE");
                        AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, "pral_CompanyId", "PRCompanyAlias", sbSubSelectWhere);
                    }
                    ResetConnector();
                }

                //// Custom Identifier Criteria
                //if (!String.IsNullOrEmpty(_szCustomIdentifier))
                //{
                //    sbSubSelectWhere.Length = 0;
                    
                //    // Surround the Custom Identifier with wildcards
                //    AddStringCondition(sbSubSelectWhere, oParameters, COL_PRWEBUSERCUSTOMDATA_VALUE, _szCustomIdentifier);
                //    AddCondition(sbSubSelectWhere, oParameters, COL_PRWEBUSERCUSTOMDATA_LABELCODE, "=", CODE_LABELCODE_CUSTOMIDENTIFIER);
                //    AddCondition(sbSubSelectWhere, oParameters, "prwucd_HQID", "=", _oUser.prwu_HQID);

                //    SetOrConnector();
                //    AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, COL_PRWEBUSERCUSTOMDATA_COMPANYID, TAB_PRWEBUSERCUSTOMDATA, sbSubSelectWhere);
                //    ResetConnector();
                //}

                // BBID 
                if (_iBBID > 0)
                {
                    SetOrConnector();
                    AddCondition(sbWhereClause, oParameters, COL_COMPANY_COMPANYID, "=", _iBBID);
                    ResetConnector();
                }

                if (sbWhereClause.Length > 0)
                {
                    sbWhereClause.Insert(0, "(");
                    sbWhereClause.Append(")");
                }

                // Listing Status Criteria
                if (!String.IsNullOrEmpty(_szListingStatus)) {
                    AddInCondition(sbWhereClause, COL_COMPANY_LISTINGSTATUS, _szListingStatus, true);
                }

                AddConnector(sbWhereClause);
                if (IsLocalSourceCountOverride)
                {
                    sbWhereClause.Append("comp_PRLocalSource = 'Y'");
                }
                else
                {
                    sbWhereClause.Append(GetObjectMgr().GetLocalSourceCondition());
                }

                sbWhereClause.Append(" AND " + GetObjectMgr().GetIntlTradeAssociationCondition());

                switch (WebUser.prwu_IndustryType)
                {
                    case GeneralDataMgr.INDUSTRY_TYPE_LUMBER:
                        AddCondition(sbWhereClause, oParameters, COL_COMPANY_INDUSTRYTYPE, "=", GeneralDataMgr.INDUSTRY_TYPE_LUMBER);
                        break;

                    case GeneralDataMgr.INDUSTRY_TYPE_WINEGRAPE:
                        AddCondition(sbWhereClause, oParameters, COL_COMPANY_INDUSTRYTYPE, "=", GeneralDataMgr.INDUSTRY_TYPE_WINEGRAPE);
                        break;
                    
                    default:
                        AddCondition(sbWhereClause, oParameters, COL_COMPANY_INDUSTRYTYPE, "<>", GeneralDataMgr.INDUSTRY_TYPE_LUMBER);
                        AddCondition(sbWhereClause, oParameters, COL_COMPANY_INDUSTRYTYPE, "<>", GeneralDataMgr.INDUSTRY_TYPE_WINEGRAPE);
                        break;
                }

                return sbWhereClause.ToString(); ;
            }

            sbWhereClause.Append(base.BuildWhereClause(oParameters, false, false));

            AddConnector(sbWhereClause);
            sbWhereClause.Append(GetObjectMgr().GetIntlTradeAssociationCondition());

            // Industry Type Criteria
            if (_bIndustryTypeSkip)
            {
                //Intentionally skip by request
            }
            else if (!string.IsNullOrEmpty(_szIndustryType))
            {
                if(_bIndustryTypeNotEqual)
                    AddCondition(sbWhereClause, oParameters, COL_COMPANY_INDUSTRYTYPE, "<>", _szIndustryType);
                else
                    AddCondition(sbWhereClause, oParameters, COL_COMPANY_INDUSTRYTYPE, "=", _szIndustryType);
            } else {

                switch (WebUser.prwu_IndustryType)
                {
                    case GeneralDataMgr.INDUSTRY_TYPE_LUMBER:
                        AddCondition(sbWhereClause, oParameters, COL_COMPANY_INDUSTRYTYPE, "=", GeneralDataMgr.INDUSTRY_TYPE_LUMBER);
                        break;

                    case GeneralDataMgr.INDUSTRY_TYPE_WINEGRAPE:
                        AddCondition(sbWhereClause, oParameters, COL_COMPANY_INDUSTRYTYPE, "=", GeneralDataMgr.INDUSTRY_TYPE_WINEGRAPE);
                        break;

                    default:
                        AddCondition(sbWhereClause, oParameters, COL_COMPANY_INDUSTRYTYPE, "<>", GeneralDataMgr.INDUSTRY_TYPE_LUMBER);
                        AddCondition(sbWhereClause, oParameters, COL_COMPANY_INDUSTRYTYPE, "<>", GeneralDataMgr.INDUSTRY_TYPE_WINEGRAPE);
                        break;
                }
            }

            #region Company Search Criteria
            // Company Type Criteria
            if (!String.IsNullOrEmpty(_szCompanyType))
            {
                AddCondition(sbWhereClause, oParameters, COL_COMPANY_TYPE, "=", _szCompanyType);
            }

            // Listing Status Criteria
            if (!String.IsNullOrEmpty(_szListingStatus))
            {
                AddInCondition(sbWhereClause, COL_COMPANY_LISTINGSTATUS, _szListingStatus, true);

                // For the "Previously Listed", make sure the company has a
                // Delisted Date.
                if (_szListingStatus == "N3,N5,N6")
                {
                    AddIsNotNullCondition(sbWhereClause, "comp_PRDelistedDate");
                }
            }

            // Phone and Area Code Criteria
            if ((!string.IsNullOrEmpty(_szPhoneAreaCode)) || (!string.IsNullOrEmpty(_szPhoneNumber)))
            {
                sbSubSelectWhere.Length = 0;
                AddInCondition(sbSubSelectWhere, COL_PHONE_TYPE, "'P', 'TF'");
                AddCondition(sbSubSelectWhere, oParameters, COL_PHONE_PUBLISH, "=", CODE_PUBLISHED);

                if ((!string.IsNullOrEmpty(_szPhoneAreaCode)))
                {
                    AddCondition(sbSubSelectWhere, oParameters, COL_PHONE_AREACODE, "=", _szPhoneAreaCode);
                }

                if (!string.IsNullOrEmpty(_szPhoneNumber)) {
                    string szPreparedPhoneNumber = CleanString(_szPhoneNumber);
                    AddCondition(sbSubSelectWhere, oParameters, COL_PHONE_PHONE_MATCH, "LIKE", "%" + szPreparedPhoneNumber + "%");
                }

                AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, "plink_RecordID", "vPRCompanyPhone", sbSubSelectWhere);
            }


            // Fax Area Code Criteria
            if (!String.IsNullOrEmpty(_szFaxAreaCode))
            {
                sbSubSelectWhere.Length = 0;
                AddCondition(sbSubSelectWhere, oParameters, COL_PHONE_AREACODE, "=", _szFaxAreaCode);
                AddCondition(sbSubSelectWhere, oParameters, COL_PHONE_TYPE, "=", CODE_PHONETYPE_FAX);
                AddCondition(sbSubSelectWhere, oParameters, COL_PHONE_PUBLISH, "=", CODE_PUBLISHED);
                AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, "plink_RecordID", "vPRCompanyPhone", sbSubSelectWhere);
            }

            // Fax Number Criteria
            if (!String.IsNullOrEmpty(_szFaxNumber))
            {
                sbSubSelectWhere.Length = 0;
                AddCondition(sbSubSelectWhere, oParameters, COL_PHONE_NUMBER, "=", _szFaxNumber);
                AddCondition(sbSubSelectWhere, oParameters, COL_PHONE_TYPE, "=", CODE_PHONETYPE_FAX);
                AddCondition(sbSubSelectWhere, oParameters, COL_PHONE_PUBLISH, "=", CODE_PUBLISHED);
                AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, "plink_RecordID", "vPRCompanyPhone", sbSubSelectWhere);
            }

            // Fax Not Null Criteria
            if (_bFaxNotNull)
            {
                sbSubSelectWhere.Length = 0;
                AddIsNotNullCondition(sbSubSelectWhere, COL_PHONE_NUMBER);
                AddCondition(sbSubSelectWhere, oParameters, COL_PHONE_TYPE, "=", CODE_PHONETYPE_FAX);
                AddCondition(sbSubSelectWhere, oParameters, COL_PHONE_PUBLISH, "=", CODE_PUBLISHED);
                AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, "plink_RecordID", "vPRCompanyPhone", sbSubSelectWhere);
            }

            // Phone Not Null Criteria
            if (_bPhoneNotNull)
            {
                sbSubSelectWhere.Length = 0;
                AddIsNotNullCondition(sbSubSelectWhere, COL_PHONE_NUMBER);
                AddCondition(sbSubSelectWhere, oParameters, COL_PHONE_TYPE, "=", CODE_PHONETYPE_PHONE);
                AddCondition(sbSubSelectWhere, oParameters, COL_PHONE_PUBLISH, "=", CODE_PUBLISHED);
                AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, "plink_RecordID", "vPRCompanyPhone", sbSubSelectWhere);
            }

            // Email Critiera
            if (!String.IsNullOrEmpty(_szEmail))
            {
                sbSubSelectWhere.Length = 0;
                AddStringCondition(sbSubSelectWhere, oParameters, COL_EMAIL_EMAILADDRESS, _szEmail);
                AddCondition(sbSubSelectWhere, oParameters, COL_EMAIL_TYPE, "=", CODE_EMAILTYPE_E);
                AddCondition(sbSubSelectWhere, oParameters, COL_EMAIL_PUBLISH, "=", CODE_PUBLISHED);
                AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, COL_EMAIL_COMPANYID, "vCompanyEmail", sbSubSelectWhere);
            }

            // Email Not Null Criteria
            if (_bEmailNotNull)
            {
                sbSubSelectWhere.Length = 0;
                AddIsNotNullCondition(sbSubSelectWhere, COL_EMAIL_EMAILADDRESS);
                AddCondition(sbSubSelectWhere, oParameters, COL_EMAIL_TYPE, "=", CODE_EMAILTYPE_E);
                AddCondition(sbSubSelectWhere, oParameters, COL_EMAIL_PUBLISH, "=", CODE_PUBLISHED);
                AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, COL_EMAIL_COMPANYID, "vCompanyEmail", sbSubSelectWhere);
            }

            // New Listing Only Criteria,
            // New Listing Days Old Criteria
            if (_bNewListingOnly)
            {
                AddCondition(sbWhereClause, oParameters, COL_COMPANY_LISTEDDATE, ">=", DateTime.Today.AddDays(0 - _iNewListingDaysOld));
            }
            #endregion

            #region Location Search Criteria
            BuildLocationCriteria(sbWhereClause, oParameters);
            #endregion

            #region Classification Search Criteria
            // Classification IDs Criteria,
            // Classification Search Type Criteria
            if (!String.IsNullOrEmpty(_szClassificationIDs))
            {
                switch (_szClassificationSearchType)
                {
                    case CODE_SEARCHTYPE_ANY:
                        sbSubSelectWhere.Length = 0;
                        AddInCondition(sbSubSelectWhere, COL_PRCOMPANYCLASSIFICATION_CLASSIFICATIONID, _szClassificationIDs);
                        AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, COL_PRCOMPANYCLASSIFICATION_COMPANYID, TAB_PRCOMPANYCLASSIFICATION, sbSubSelectWhere);
                        break;

                    case CODE_SEARCHTYPE_ALL:
                        // Add a condition for each value
                        string[] szClassificationValues = _szClassificationIDs.Split(new char[] { ',' });


                        if (Utilities.GetBoolConfigValue("ClassicCompanyAllSearchEnabled", false)) {
                            foreach (string szClassificationValue in szClassificationValues)
                            {
                                sbSubSelectWhere.Length = 0;
                                AddInCondition(sbSubSelectWhere, COL_PRCOMPANYCLASSIFICATION_CLASSIFICATIONID, szClassificationValue);
                                AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, COL_PRCOMPANYCLASSIFICATION_COMPANYID, TAB_PRCOMPANYCLASSIFICATION, sbSubSelectWhere);
                            }
                        } else {
                            string[] args = {TAB_PRCOMPANYCLASSIFICATION,
                                             COL_PRCOMPANYCLASSIFICATION_COMPANYID,
                                             COL_PRCOMPANYCLASSIFICATION_CLASSIFICATIONID,
                                             _szClassificationIDs,
                                             szClassificationValues.Length.ToString()};

                            sbWhereClause = AddConnector(sbWhereClause);
                            sbWhereClause.Append("comp_CompanyID IN (" + string.Format(SELECT_ALL, args) + ")");
                        }
                        break;

                    case CODE_SEARCHTYPE_ONLY:
                        // Add a condition for each value
                        string[] szClassificationValues2 = _szClassificationIDs.Split(new char[] { ',' });

                        foreach (string szClassificationValue in szClassificationValues2)
                        {
                            sbSubSelectWhere.Length = 0;
                            AddInCondition(sbSubSelectWhere, COL_PRCOMPANYCLASSIFICATION_CLASSIFICATIONID, szClassificationValue);
                            AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, COL_PRCOMPANYCLASSIFICATION_COMPANYID, TAB_PRCOMPANYCLASSIFICATION, sbSubSelectWhere);
                        }

                        AddHavingCountSubSelect(sbWhereClause, SQL_SUB_SELECT_HAVING_COUNT, COL_PRCOMPANYCLASSIFICATION_COMPANYID, TAB_PRCOMPANYCLASSIFICATION, COL_PRCOMPANYCLASSIFICATION_COMPANYID, "=", szClassificationValues2.Length.ToString());
                        break;
                }
            }

            // Number Of Retail Stores Criteria
            if (!String.IsNullOrEmpty(_szNumberOfRetailStores))
            {
                sbSubSelectWhere.Length = 0;
                AddInCondition(sbSubSelectWhere, COL_PRCOMPANYCLASSIFICATION_NUMOFRETAIL, _szNumberOfRetailStores);
                AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, COL_PRCOMPANYCLASSIFICATION_COMPANYID, TAB_PRCOMPANYCLASSIFICATION, sbSubSelectWhere);
            }

            // Number Of Restaraunt Stores Criteria
            if (!String.IsNullOrEmpty(_szNumberOfRestaurantStores))
            {
                sbSubSelectWhere.Length = 0;
                AddInCondition(sbSubSelectWhere, COL_PRCOMPANYCLASSIFICATION_NUMOFRESTAURANT, _szNumberOfRestaurantStores);
                AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, COL_PRCOMPANYCLASSIFICATION_COMPANYID, TAB_PRCOMPANYCLASSIFICATION, sbSubSelectWhere);
            }
            #endregion

            #region Commodity Search Criteria

            string localSourceAlsoOperatesOverride = null;
            string localSourceGrowsOrganicOverride = null;
            string szLocalSourceFromClause = string.Empty;

            if (!String.IsNullOrEmpty(_szCommodityIDs))
            {
                // Recursively expand commodity IDs - all child levels should be included
                string szExpandedCommodityIDs = _szCommodityIDs;
                string szChildCommodityIDs = GetChildCommodityValuesForList(szExpandedCommodityIDs);
                if (!String.IsNullOrEmpty(szChildCommodityIDs))
                    szExpandedCommodityIDs += "," + szChildCommodityIDs;

                switch (_szCommoditySearchType)
                {
                    case CODE_SEARCHTYPE_ANY:
                        sbSubSelectWhere.Length = 0;
                        AddInCondition(sbSubSelectWhere, COL_PRCOMPANYCOMMODITYATTRIBUTE_COMMODITYID, szExpandedCommodityIDs);

                        // Defect #2285 - Publish flag does not matter
                        // AddCondition(sbSubSelectWhere, oParameters, COL_PRCOMPANYCOMMODITYATTRIBUTE_PUBLISH, "=", CODE_PUBLISHED);

                        if (_iCommodityGMAttributeID > 0)
                        {

                            // If the search is restricted to LSS compaanies only, then searchginb by these growing
                            // method will yield no results.  Because of this, set the correspoidning LSS
                            // search critiera.
                            if (_szIncludeLocalSource == "LSO")
                            {
                                if (_iCommodityGMAttributeID == 23)
                                {
                                    localSourceAlsoOperatesOverride = "Greenhouse";
                                }

                                if (_iCommodityGMAttributeID == 25)
                                {
                                    localSourceGrowsOrganicOverride = "Organic";
                                }

                            }
                            else
                            {
                                if ((_szIncludeLocalSource == "ILS") &&
                                    (_iCommodityGMAttributeID == 23))
                                {
                                    StringBuilder work = new StringBuilder();

                                    sbSubSelectWhere = AddConnector(sbSubSelectWhere);
                                    AddCondition(sbSubSelectWhere, oParameters, COL_PRCOMPANYCOMMODITYATTRIBUTE_GMATTRIBUTEID, "=", _iCommodityGMAttributeID);
                                    AddSubSelect(work, SQL_SUB_SELECT_COMPANY_ID, COL_PRCOMPANYCOMMODITYATTRIBUTE_COMPANYID, TAB_PRCOMPANYCOMMODITYATTRIBUTE, sbSubSelectWhere);

                                    sbSubSelectWhere.Clear();
                                    AddCondition(sbSubSelectWhere, oParameters, "prls_AlsoOperates", " LIKE ", "%Greenhouse%");
                                    SetOrConnector();
                                    AddSubSelect(work, SQL_SUB_SELECT_COMPANY_ID, "prls_CompanyID", "PRLocalSource", sbSubSelectWhere);
                                    ResetConnector();

                                    // Now add our compound OR condition to the main where clause
                                    AddConnector(sbWhereClause);
                                    sbWhereClause.Append("(");
                                    sbWhereClause.Append(work);
                                    sbWhereClause.Append(")");

                                    sbSubSelectWhere.Clear();

                                } else if ((_szIncludeLocalSource == "ILS") &&
                                          (_iCommodityGMAttributeID == 25))
                                {
                                    StringBuilder work = new StringBuilder();

                                    sbSubSelectWhere = AddConnector(sbSubSelectWhere);
                                    AddCondition(sbSubSelectWhere, oParameters, COL_PRCOMPANYCOMMODITYATTRIBUTE_GMATTRIBUTEID, "=", _iCommodityGMAttributeID);
                                    AddSubSelect(work, SQL_SUB_SELECT_COMPANY_ID, COL_PRCOMPANYCOMMODITYATTRIBUTE_COMPANYID, TAB_PRCOMPANYCOMMODITYATTRIBUTE, sbSubSelectWhere);

                                    sbSubSelectWhere.Clear();
                                    AddIsNotNullCondition(sbSubSelectWhere, "prls_Organic");

                                    SetOrConnector();
                                    AddSubSelect(work, SQL_SUB_SELECT_COMPANY_ID, "prls_CompanyID", "PRLocalSource", sbSubSelectWhere);
                                    ResetConnector();


                                    // Now add our compound OR condition to the main where clause
                                    AddConnector(sbWhereClause);
                                    sbWhereClause.Append("(");
                                    sbWhereClause.Append(work);
                                    sbWhereClause.Append(")");

                                    sbSubSelectWhere.Clear();
                                }
                                else
                                {
                                    AddCondition(sbSubSelectWhere, oParameters, COL_PRCOMPANYCOMMODITYATTRIBUTE_GMATTRIBUTEID, "=", _iCommodityGMAttributeID);
                                }
                            }

                        }

                        if (_iCommodityAttributeID > 0)
                        {
                            AddCondition(sbSubSelectWhere, oParameters, COL_PRCOMPANYCOMMODITYATTRIBUTE_ATTRIBUTEID, "=", _iCommodityAttributeID);
                        }
                        //AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, COL_PRCOMPANYCOMMODITYATTRIBUTE_COMPANYID, TAB_PRCOMPANYCOMMODITYATTRIBUTE, sbSubSelectWhere);

                        if (sbSubSelectWhere.Length > 0)
                        {
                            sbWhereClause = AddConnector(sbWhereClause);
                            sbWhereClause.Append(string.Format(SQL_SUB_SELECT_COMPANY_ID, COL_PRCOMPANYCOMMODITYATTRIBUTE_COMPANYID, "PRCompanyCommodityAttribute WITH (NOLOCK)" + szLocalSourceFromClause, sbSubSelectWhere.ToString()));
                        }

                        break;

                    case CODE_SEARCHTYPE_ALL:
                        // Add a condition for each value
                        // NOTE: For now, this will not include child commodities
                        string[] szCommodityValues = _szCommodityIDs.Split(new char[] { ',' });

                        // We can only use the "SELECT ALL" Clause if only commodities are selected.
                        // If the user selected a Growing Method or other attbribute, then we need 
                        // to use the 'Classic' method
                        if ((Utilities.GetBoolConfigValue("ClassicCompanyAllSearchEnabled", false)) ||
                           (_iCommodityGMAttributeID > 0) ||
                           (_iCommodityAttributeID > 0))
                        {
                            foreach (string szCommodityValue in szCommodityValues)
                            {
                                sbSubSelectWhere.Length = 0;
                                AddInCondition(sbSubSelectWhere, COL_PRCOMPANYCOMMODITYATTRIBUTE_COMMODITYID, szCommodityValue);

                                if (_iCommodityGMAttributeID > 0)
                                {
                                    AddCondition(sbSubSelectWhere, oParameters, COL_PRCOMPANYCOMMODITYATTRIBUTE_GMATTRIBUTEID, "=", _iCommodityGMAttributeID);
                                }

                                if (_iCommodityAttributeID > 0)
                                {
                                    AddCondition(sbSubSelectWhere, oParameters, COL_PRCOMPANYCOMMODITYATTRIBUTE_ATTRIBUTEID, "=", _iCommodityAttributeID);
                                }
                                AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, COL_PRCOMPANYCOMMODITYATTRIBUTE_COMPANYID, TAB_PRCOMPANYCOMMODITYATTRIBUTE, sbSubSelectWhere);
                            }
                        }
                        else
                        {
                            string[] args = {TAB_PRCOMPANYCOMMODITYATTRIBUTE,
                                             COL_PRCOMPANYCOMMODITYATTRIBUTE_COMPANYID,
                                             COL_PRCOMPANYCOMMODITYATTRIBUTE_COMMODITYID,
                                             _szCommodityIDs,
                                             szCommodityValues.Length.ToString()};

                            sbWhereClause = AddConnector(sbWhereClause);
                            sbWhereClause.Append("comp_CompanyID IN (" + string.Format(SELECT_ALL, args) + ")");
                        }

                        break;

                        //case CODE_SEARCHTYPE_ONLY:
                        //    // Add a condition for each value
                        //    // NOTE: For now, this will not include child commodities
                        //    string[] szCommodityValues2 = _szCommodityIDs.Split(new char[] { ',' });

                        //    foreach (string szCommodityValue in szCommodityValues2)
                        //    {

                        //        sbSubSelectWhere.Length = 0;
                        //        AddInCondition(sbSubSelectWhere, COL_PRCOMPANYCOMMODITYATTRIBUTE_COMMODITYID, szCommodityValue);
                        //        // Defect #2285 - Publish flag does not matter
                        //        // AddCondition(sbSubSelectWhere, oParameters, COL_PRCOMPANYCOMMODITYATTRIBUTE_PUBLISH, "=", CODE_PUBLISHED);

                        //        if (_iCommodityGMAttributeID > 0)
                        //        {
                        //            AddCondition(sbSubSelectWhere, oParameters, COL_PRCOMPANYCOMMODITYATTRIBUTE_GMATTRIBUTEID, "=", _iCommodityGMAttributeID);
                        //        }




                        //        if (_iCommodityAttributeID > 0)
                        //        {

                        //            AddCondition(sbSubSelectWhere, oParameters, COL_PRCOMPANYCOMMODITYATTRIBUTE_ATTRIBUTEID, "=", _iCommodityAttributeID);
                        //        }


                        //        AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, COL_PRCOMPANYCOMMODITYATTRIBUTE_COMPANYID, TAB_PRCOMPANYCOMMODITYATTRIBUTE, sbSubSelectWhere);
                        //    }


                        //    AddHavingCountSubSelect(sbWhereClause, SQL_SUB_SELECT_HAVING_COUNT, COL_PRCOMPANYCOMMODITYATTRIBUTE_COMPANYID, TAB_PRCOMPANYCOMMODITYATTRIBUTE, COL_PRCOMPANYCOMMODITYATTRIBUTE_COMPANYID, "=", szCommodityValues2.Length.ToString());
                        //    break;

                }

            }
            else
            {

                // Commodity Growing Method Attribute ID Criteria
                if (_iCommodityGMAttributeID > 0)
                {

                    // If the search is restricted to LSS compaanies only, then searchginb by these growing
                    // method will yield no results.  Because of this, set the correspoidning LSS
                    // search critiera.
                    if (_szIncludeLocalSource == "LSO")
                    {
                        if (_iCommodityGMAttributeID == 23)
                        {
                            localSourceAlsoOperatesOverride = "Greenhouse";
                        }

                        if (_iCommodityGMAttributeID == 25)
                        {
                            localSourceGrowsOrganicOverride = "Organic";
                        }

                    }
                    else
                    {
                        if ((_szIncludeLocalSource == "ILS") &&
                            (_iCommodityGMAttributeID == 23))
                        {
                            StringBuilder work = new StringBuilder();

                            sbSubSelectWhere.Clear();
                            AddCondition(sbSubSelectWhere, oParameters, COL_PRCOMPANYCOMMODITYATTRIBUTE_GMATTRIBUTEID, "=", _iCommodityGMAttributeID);
                            AddSubSelect(work, SQL_SUB_SELECT_COMPANY_ID, COL_PRCOMPANYCOMMODITYATTRIBUTE_COMPANYID, TAB_PRCOMPANYCOMMODITYATTRIBUTE, sbSubSelectWhere);

                            sbSubSelectWhere.Clear();
                            AddCondition(sbSubSelectWhere, oParameters, "prls_AlsoOperates", " LIKE ", "%Greenhouse%");
                            SetOrConnector();
                            AddSubSelect(work, SQL_SUB_SELECT_COMPANY_ID, "prls_CompanyID", "PRLocalSource", sbSubSelectWhere);
                            ResetConnector();

                            // Now add our compound OR condition to the main where clause
                            AddConnector(sbWhereClause);
                            sbWhereClause.Append("(");
                            sbWhereClause.Append(work);
                            sbWhereClause.Append(")");

                            sbSubSelectWhere.Clear();
                        }
                        else if ((_szIncludeLocalSource == "ILS") &&
                                (_iCommodityGMAttributeID == 25))
                        {

                            StringBuilder work = new StringBuilder();

                            sbSubSelectWhere.Clear();
                            AddCondition(sbSubSelectWhere, oParameters, COL_PRCOMPANYCOMMODITYATTRIBUTE_GMATTRIBUTEID, "=", _iCommodityGMAttributeID);
                            AddSubSelect(work, SQL_SUB_SELECT_COMPANY_ID, COL_PRCOMPANYCOMMODITYATTRIBUTE_COMPANYID, TAB_PRCOMPANYCOMMODITYATTRIBUTE, sbSubSelectWhere);

                            sbSubSelectWhere.Clear();
                            AddIsNotNullCondition(sbSubSelectWhere, "prls_Organic");

                            SetOrConnector();
                            AddSubSelect(work, SQL_SUB_SELECT_COMPANY_ID, "prls_CompanyID", "PRLocalSource", sbSubSelectWhere);
                            ResetConnector();

    
                            // Now add our compound OR condition to the main where clause
                            AddConnector(sbWhereClause);
                            sbWhereClause.Append("(");
                            sbWhereClause.Append(work);
                            sbWhereClause.Append(")");

                            sbSubSelectWhere.Clear();
                        }
                        else
                        {
                            // 6/2008 -- Removed the reliance on the search type.
                            sbSubSelectWhere.Length = 0;
                            AddCondition(sbSubSelectWhere, oParameters, COL_PRCOMPANYCOMMODITYATTRIBUTE_GMATTRIBUTEID, "=", _iCommodityGMAttributeID);
                            //AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, COL_PRCOMPANYCOMMODITYATTRIBUTE_COMPANYID, TAB_PRCOMPANYCOMMODITYATTRIBUTE, sbSubSelectWhere);
                        }

                        if (sbSubSelectWhere.Length > 0)
                        {
                            sbWhereClause = AddConnector(sbWhereClause);
                            sbWhereClause.Append(string.Format(SQL_SUB_SELECT_COMPANY_ID, COL_PRCOMPANYCOMMODITYATTRIBUTE_COMPANYID, "PRCompanyCommodityAttribute WITH (NOLOCK)" + szLocalSourceFromClause, sbSubSelectWhere.ToString()));
                        }

                    }
                }

                // Commodity Attribute ID Criteria
                if (_iCommodityAttributeID > 0)
                {
                    // 8/2008 -- Removed reliance on the search type -- It should always be "And"
                    sbSubSelectWhere.Length = 0;
                    AddCondition(sbSubSelectWhere, oParameters, COL_PRCOMPANYCOMMODITYATTRIBUTE_ATTRIBUTEID, "=", _iCommodityAttributeID);
                    AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, COL_PRCOMPANYCOMMODITYATTRIBUTE_COMPANYID, TAB_PRCOMPANYCOMMODITYATTRIBUTE, sbSubSelectWhere);
                }
            }
            #endregion

            #region Rating Search Criteria

            if (_bIsTMFM)
            {
                AddIsNotNullCondition(sbWhereClause, "comp_PRTMFMAward");
            }
            else
            {
                // Member Year Criteria
                if (_iMemberYear > 0)
                {
                    AddCondition(sbWhereClause, oParameters, COL_COMPANY_MEMBERYEAR, _szMemberYearSearchType, _iMemberYear);
                    AddIsNotNullCondition(sbWhereClause, "comp_PRTMFMAward");
                }
            }

            // BB Score / BB Score Search Type Criteria
            if ((_iBBScore > 0) &&
                (!string.IsNullOrEmpty(_szBBScoreSearchType)))
            {
                sbSubSelectWhere.Length = 0;
                AddCondition(sbSubSelectWhere, oParameters, "prbs_Current", "=", "Y");
                AddCondition(sbSubSelectWhere, oParameters, "prbs_PRPublish", "=", "Y");
                AddCondition(sbWhereClause, oParameters, "comp_PRPublishBBScore", "=", "Y");
                AddCondition(sbSubSelectWhere, oParameters, "prbs_BBScore", _szBBScoreSearchType, _iBBScore);
                AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, "prbs_CompanyID", "PRBBScore", sbSubSelectWhere);
            }


            // Pay Report Count / Pay Report Count Search Type Criteria
            if ((_iPayReportCount > -1) &&
                (!string.IsNullOrEmpty(_szPayReportCountSearchType))) 
            {
                AddCondition(sbWhereClause, oParameters, "PayReportCount", _szPayReportCountSearchType, _iPayReportCount);
            }

            // Rating Credit Worth IDs Criteria
            if (!string.IsNullOrEmpty(_szRatingCreditWorthIDs))
            {
                AddInCondition(sbWhereClause, COL_PRRATING_CREDITWORTHID, _szRatingCreditWorthIDs);
            }
            
            //Min and Max variations of RatingCreditWorthID
            if (!string.IsNullOrEmpty(_szRatingCreditWorthMinID) && !string.IsNullOrEmpty(_szRatingCreditWorthMaxID))
                sbWhereClause.Append($" AND {COL_PRRATING_CREDITWORTHID} BETWEEN {_szRatingCreditWorthMinID} AND {_szRatingCreditWorthMaxID} ");
            else if (!string.IsNullOrEmpty(_szRatingCreditWorthMinID) && string.IsNullOrEmpty(_szRatingCreditWorthMaxID))
                sbWhereClause.Append($" AND {COL_PRRATING_CREDITWORTHID} >= {_szRatingCreditWorthMinID} ");
            else if (string.IsNullOrEmpty(_szRatingCreditWorthMinID) && !string.IsNullOrEmpty(_szRatingCreditWorthMaxID))
                sbWhereClause.Append($" AND {COL_PRRATING_CREDITWORTHID} <= {_szRatingCreditWorthMaxID} ");

            // Rating Integrity IDs Criteria
            if (!string.IsNullOrEmpty(_szRatingIntegrityIDs))
            {
                string strRatingIntegrityIDs = _szRatingIntegrityIDs;
                if(strRatingIntegrityIDs.Contains("5") && !strRatingIntegrityIDs.Contains("4"))
                    strRatingIntegrityIDs += ",4";
                if (strRatingIntegrityIDs.Contains("2") && !strRatingIntegrityIDs.Contains("3"))
                    strRatingIntegrityIDs += ",3";
                AddInCondition(sbWhereClause, COL_PRRATING_INTEGRITYID, strRatingIntegrityIDs);
            }

            // Rating Pay IDs Criteria
            if (!String.IsNullOrEmpty(_szRatingPayIDs))
            {
                AddInCondition(sbWhereClause, COL_PRRATING_PAYID, _szRatingPayIDs);
            }

            // Pay Indicator Criteria
            if (!String.IsNullOrEmpty(_szPayIndicator))
            {

                // If the user is only interested in the "NoneReported" option, don't
                // bother querying the pay indicator data.
                if (_szPayIndicator != "None")
                {
                    sbSubSelectWhere.Length = 0;
                    AddInCondition(sbSubSelectWhere, COL_PRCOMPANY_PAYINDICATORID, _szPayIndicator, true);
                    AddIsNotNullCondition(sbSubSelectWhere, COL_PRCOMPANY_PAYINDICATORID);
                    AddCondition(sbSubSelectWhere, oParameters, "prcpi_Current", "=", "Y");
                    AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, "prcpi_CompanyID", "PRCompanyPayIndicator", sbSubSelectWhere);
                    AddCondition(sbWhereClause, oParameters, "comp_PRPublishPayIndicator", "=", "Y");
                }

                if (_szPayIndicator.Contains("None"))
                {
                    if (sbWhereClause.Length > 0)
                    {
                        sbWhereClause.Append(" AND ");
                    }
                    sbWhereClause.Append("Comp_CompanyId NOT IN (SELECT prcpi_CompanyID FROM PRCompanyPayIndicator WITH (NOLOCK) WHERE prcpi_Current = 'Y' AND prcpi_PayIndicator IS NOT NULL)");
                }

            }

            if (_bUnratedCompaniesOnly)
            {
                if (sbWhereClause.Length > 0)
                {
                    sbWhereClause.Append(" AND ");
                }
                sbWhereClause.Append("Comp_CompanyId IN (SELECT comp_CompanyID FROM vPRUnratedCompanies)");
                

            }

            // Rating Numeral IDs Criteria
            // Rating Numeral Search Type Criteria
            // [DEFERRED] 
            #endregion

            #region Profile Search Criteria
            // License Types Criteria
            if ((!string.IsNullOrEmpty(_szLicenseTypes)) ||
                (!string.IsNullOrEmpty(_szLicenseNumber))) 
            
            
            {
                if (sbWhereClause.Length > 0)
                    sbWhereClause.Append(" AND (");
                else
                    sbWhereClause.Append(" (");

                // If DRC is included in the license types, we need to look into the
                // PRDRCLicense table for the data.
                if ((!string.IsNullOrEmpty(_szLicenseTypes)) &&
                    (_szLicenseTypes.Contains("DRC")))
                {
                    sbSubSelectWhere.Length = 0;
                    
                    if (!String.IsNullOrEmpty(_szLicenseNumber)) {
                        AddCondition(sbSubSelectWhere, oParameters, "prdr_LicenseNumber", "=", _szLicenseNumber);
                    }
                    
                    AddCondition(sbSubSelectWhere, oParameters, COL_PRDRCLICENSE_PUBLISH, "=", CODE_PUBLISHED);
                    AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, COL_PRDRCLICENSE_COMPANYID, TAB_PRDRCLICENSE, sbSubSelectWhere);
                    sbWhereClause.Append(" OR ");
                }

                // If PACA is included in the license types, we need to also look into the
                // PRPACALicense table for data.
                if ((!string.IsNullOrEmpty(_szLicenseTypes)) &&
                    (_szLicenseTypes.Contains("PACA")))
                {
                    sbSubSelectWhere.Length = 0;

                    if (!String.IsNullOrEmpty(_szLicenseNumber)) {
                        AddCondition(sbSubSelectWhere, oParameters, "prpa_LicenseNumber", "=", _szLicenseNumber);
                    }
                    
                    AddCondition(sbSubSelectWhere, oParameters, COL_PRPACALICENSE_PUBLISH, "=", CODE_PUBLISHED);
                    AddCondition(sbSubSelectWhere, oParameters, "prpa_Current", "=", "Y");
                    AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, COL_PRPACALICENSE_COMPANYID, TAB_PRPACALICENSE, sbSubSelectWhere);
                    sbWhereClause.Append(" OR ");
                }

                // Now search the generic license table
                sbSubSelectWhere.Length = 0;

                if (!String.IsNullOrEmpty(_szLicenseTypes)) {
                    AddInCondition(sbSubSelectWhere, COL_PRCOMPANYLICENSE_TYPE, _szLicenseTypes, true);
                }

                if (!String.IsNullOrEmpty(_szLicenseNumber)) {
                    AddCondition(sbSubSelectWhere, oParameters, COL_PRCOMPANYLICENSE_NUMBER, "=", _szLicenseNumber);
                }

                AddCondition(sbSubSelectWhere, oParameters, COL_PRCOMPANYLICENSE_PUBLISH, "=", CODE_PUBLISHED);
                AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, COL_PRCOMPANYLICENSE_COMPANYID, TAB_PRCOMPANYLICENSE, sbSubSelectWhere);

                sbWhereClause.Append(")");
            }

            // Brands Criteria
            // We now search all brands, even if
            // they are not published.
            if (!String.IsNullOrEmpty(_szBrands))
            {
                sbSubSelectWhere.Length = 0;
                AddStringCondition(sbSubSelectWhere, oParameters, COL_PRCOMPANYBRAND_BRAND, _szBrands);
                AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, COL_PRCOMPANYBRAND_COMPANYID, TAB_PRCOMPANYBRAND, sbSubSelectWhere);
            }

            // Even though the variable names are "DescriptiveLines", this has been
            // changed to search the entire listing via the PRTransaction table.
            if (!String.IsNullOrEmpty(_szDescriptiveLines))
            {
                sbSubSelectWhere.Length = 0;
                AddStringCondition(sbSubSelectWhere, oParameters, SQL_MISC_LISTING_TEXT, _szDescriptiveLines);
                if (sbSubSelectWhere.Length > 0)
                {
                    sbWhereClause.Append(" AND");
                }
                sbWhereClause.Append(" comp_CompanyID IN (" + sbSubSelectWhere + ")");
            }

            if (_bOrganic || _bFoodSafetyCertified || (!string.IsNullOrEmpty(_szVolume)) || (!string.IsNullOrEmpty(_szVolumeMin)) || (!string.IsNullOrEmpty(_szVolumeMax)) || (!String.IsNullOrEmpty(_szCorporateStructure)) || (!String.IsNullOrEmpty(_szFTEmployeeCodes)))
            {
                sbSubSelectWhere.Length = 0;

                // Corporate Structure Criteria
                if (!String.IsNullOrEmpty(_szCorporateStructure))
                {
                    AddInCondition(sbSubSelectWhere, COL_PRCOMPANYPROFILE_CORPSTRUCTURE, _szCorporateStructure, true);
                }

                // Volume Criteria
                if (!string.IsNullOrEmpty(_szVolume))
                {
                    AddInCondition(sbSubSelectWhere, COL_PRCOMPANYPROFILE_VOLUME, _szVolume);
                }

                //Min and max variations of Volume
                if (!string.IsNullOrEmpty(_szVolumeMin) && !string.IsNullOrEmpty(_szVolumeMax))
                    sbWhereClause.Append($" AND {COL_PRCOMPANYPROFILE_VOLUME} BETWEEN {_szVolumeMin} AND {_szVolumeMax} ");
                else if (!string.IsNullOrEmpty(_szVolumeMin) && string.IsNullOrEmpty(_szVolumeMax))
                    sbWhereClause.Append($" AND {COL_PRCOMPANYPROFILE_VOLUME} >= {_szVolumeMin} ");
                else if (string.IsNullOrEmpty(_szVolumeMin) && !string.IsNullOrEmpty(_szVolumeMax))
                    sbWhereClause.Append($" AND {COL_PRCOMPANYPROFILE_VOLUME} <= {_szVolumeMax} ");

                if (_bOrganic)
                {
                    AddIsNotNullCondition(sbSubSelectWhere, "prcp_Organic");
                }

                if (_bFoodSafetyCertified)
                {
                    AddIsNotNullCondition(sbSubSelectWhere, "prcp_FoodSafetyCertified");
                }

                if (!string.IsNullOrEmpty(_szFTEmployeeCodes))
                {
                    AddInCondition(sbSubSelectWhere, "ISNULL(prcp_FTEmployees,prcex_Employees)", _szFTEmployeeCodes, true);
                }

                AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, COL_COMP_COMPANYID, TAB_PRCOMPANYPROFILE_LEFT_JOIN_PRCOMPANYEXPERIAN, sbSubSelectWhere, false);
            }

            if (_bSalvageDistressedProduce)
            {
                sbWhereClause = AddConnector(sbWhereClause);
                sbWhereClause.Append("prcp_SalvageDistressedProduce = 'Y'");
            }

            if (!String.IsNullOrEmpty(_szPubliclyTraded))
            {
                if (_szPubliclyTraded == "Y") {
                    sbWhereClause = AddConnector(sbWhereClause);
                    sbWhereClause.Append(COL_COMPANY_COMPANYID + " IN (SELECT DISTINCT prc4_CompanyId FROM PRCompanyStockExchange WITH (NOLOCK))");
                } else if (_szPubliclyTraded == "N") {
                    sbWhereClause = AddConnector(sbWhereClause);
                    sbWhereClause.Append(COL_COMPANY_COMPANYID + " NOT IN (SELECT DISTINCT prc4_CompanyId FROM PRCompanyStockExchange WITH (NOLOCK))");
                }
            }

            if (!String.IsNullOrEmpty(_szStockSymbol))
            {
                oParameters.Add(new ObjectParameter("StockSymbol", _szStockSymbol));
                sbWhereClause = AddConnector(sbWhereClause);
                sbWhereClause.Append(COL_COMPANY_COMPANYID + " IN (SELECT DISTINCT prc4_CompanyId FROM PRCompanyStockExchange WITH (NOLOCK) WHERE prc4_Symbol1 = @StockSymbol OR prc4_Symbol2 = @StockSymbol OR prc4_Symbol3 = @StockSymbol)");
            }

            #endregion

            #region Custom Search Criteria
            // Has Notes
            if (_bHasNotes)
            {
                // If HasNotes is specified, limit the result set to those companies that have an 
                // associated note that the user can see
                sbSubSelectWhere.Length = 0;
                AddCondition(sbSubSelectWhere, oParameters, COL_PRWEBUSERNOTE_TYPECODE, "=", CODE_PRWEBUSERNOTE_TYPECOMPANY);
                sbSubSelectWhere.Append(" AND ((");

                AddCondition(sbSubSelectWhere, oParameters, COL_PRWEBUSERNOTE_WEBUSERID, "=", _oUser.prwu_WebUserID);
                AddCondition(sbSubSelectWhere, oParameters, COL_PRWEBUSERNOTE_PRIVATE, "=", CODE_PRIVATE);

                sbSubSelectWhere.Append(") OR (");
                AddCondition(sbSubSelectWhere, oParameters, COL_PRWEBUSERNOTE_HQID, "=", _oUser.prwu_HQID);
                AddIsNullCondition(sbSubSelectWhere, COL_PRWEBUSERNOTE_PRIVATE);
                sbSubSelectWhere.Append("))");
                AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, COL_PRWEBUSERNOTE_COMPANYID, TAB_PRWEBUSERNOTE, sbSubSelectWhere);
            }

            //// Custom Identifier Criteria
            //if (!String.IsNullOrEmpty(_szCustomIdentifier))
            //{
            //    sbSubSelectWhere.Length = 0;
            //    AddStringCondition(sbSubSelectWhere, oParameters, COL_PRWEBUSERCUSTOMDATA_VALUE, _szCustomIdentifier);
            //    AddCondition(sbSubSelectWhere, oParameters, COL_PRWEBUSERCUSTOMDATA_LABELCODE, "=", CODE_LABELCODE_CUSTOMIDENTIFIER);
            //    AddCondition(sbSubSelectWhere, oParameters, "prwucd_HQID", "=", _oUser.prwu_HQID);
            //    AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, COL_PRWEBUSERCUSTOMDATA_COMPANYID, TAB_PRWEBUSERCUSTOMDATA, sbSubSelectWhere);
                
            //}

            //// Custom Identifier Not Null Criteria
            //if (_bCustomIdentifierNotNull)
            //{
            //    sbSubSelectWhere.Length = 0;
            //    AddIsNotNullCondition(sbSubSelectWhere, COL_PRWEBUSERCUSTOMDATA_VALUE);
            //    AddCondition(sbSubSelectWhere, oParameters, COL_PRWEBUSERCUSTOMDATA_LABELCODE, "=", CODE_LABELCODE_CUSTOMIDENTIFIER);
            //    AddCondition(sbSubSelectWhere, oParameters, "prwucd_HQID", "=", _oUser.prwu_HQID);
            //    AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, COL_PRWEBUSERCUSTOMDATA_COMPANYID, TAB_PRWEBUSERCUSTOMDATA, sbSubSelectWhere);
            //}
            #endregion

            #region Specie Search Criteria
            if (!String.IsNullOrEmpty(_szSpecieIDs))
            {
                // Recursively expand specie IDs - all child levels should be included
                string szExpandedSpecieIDs = _szSpecieIDs;
                string szChildSpecieIDs = GetChildSpecieValuesForList(szExpandedSpecieIDs);
                if (!String.IsNullOrEmpty(szChildSpecieIDs))
                    szExpandedSpecieIDs += "," + szChildSpecieIDs;

                switch (_szSpecieSearchType)
                {
                    case CODE_SEARCHTYPE_ANY:
                        sbSubSelectWhere.Length = 0;
                        AddInCondition(sbSubSelectWhere, "prcspc_SpecieID", szExpandedSpecieIDs);
                        AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, "prcspc_CompanyID", "PRCompanySpecie", sbSubSelectWhere);
                        break;

                    case CODE_SEARCHTYPE_ALL:
                        // Add a condition for each value
                        string[] szValues = _szSpecieIDs.Split(new char[] { ',' });

                        if (Utilities.GetBoolConfigValue("ClassicCompanyAllSearchEnabled", false))
                        {
                            foreach (string szID in szValues)
                            {
                                sbSubSelectWhere.Length = 0;
                                AddInCondition(sbSubSelectWhere, "prcspc_SpecieID", szID);
                                AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, "prcspc_CompanyID", "PRCompanySpecie", sbSubSelectWhere);
                            }
                        }
                        else
                        {
                            string[] args = {"PRCompanySpecie",
                                             "prcspc_CompanyID",
                                             "prcspc_SpecieID",
                                             _szSpecieIDs,
                                             szValues.Length.ToString()};

                            sbWhereClause = AddConnector(sbWhereClause);
                            sbWhereClause.Append("comp_CompanyID IN (" + string.Format(SELECT_ALL, args) + ")");
                        }
                        break;
                }
            }
            #endregion

            #region ProductProvided Search Criteria
            if (!String.IsNullOrEmpty(_szProductProvidedIDs))
            {
                switch (_szProductProvidedSearchType)
                {
                    case CODE_SEARCHTYPE_ANY:
                        sbSubSelectWhere.Length = 0;
                        AddInCondition(sbSubSelectWhere, "prcprpr_ProductProvidedID", _szProductProvidedIDs);
                        AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, "prcprpr_CompanyID", "PRCompanyProductProvided", sbSubSelectWhere);
                        break;

                    case CODE_SEARCHTYPE_ALL:
                        // Add a condition for each value
                        string[] szValues = _szProductProvidedIDs.Split(new char[] { ',' });

                        if (Utilities.GetBoolConfigValue("ClassicCompanyAllSearchEnabled", false))
                        {
                            foreach (string szID in szValues)
                            {
                                sbSubSelectWhere.Length = 0;
                                AddInCondition(sbSubSelectWhere, "prcprpr_ProductProvidedID", szID);
                                AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, "prcprpr_CompanyID", "PRCompanyProductProvided", sbSubSelectWhere);
                            }
                        }
                        else
                        {
                            string[] args = {"PRCompanyProductProvided",
                                             "prcprpr_CompanyID",
                                             "prcprpr_ProductProvidedID",
                                             _szProductProvidedIDs,
                                             szValues.Length.ToString()};

                            sbWhereClause = AddConnector(sbWhereClause);
                            sbWhereClause.Append("comp_CompanyID IN (" + string.Format(SELECT_ALL, args) + ")");
                        }
                        break;
                }
            }
            #endregion

            #region ServiceProvided Search Criteria
            if (!String.IsNullOrEmpty(_szServiceProvidedIDs))
            {
                switch (_szServiceProvidedSearchType)
                {
                    case CODE_SEARCHTYPE_ANY:
                        sbSubSelectWhere.Length = 0;
                        AddInCondition(sbSubSelectWhere, "prcserpr_ServiceProvidedID", _szServiceProvidedIDs);
                        AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, "prcserpr_CompanyID", "PRCompanyServiceProvided", sbSubSelectWhere);
                        break;

                    case CODE_SEARCHTYPE_ALL:
                        string[] szValues = _szServiceProvidedIDs.Split(new char[] { ',' });

                        if (Utilities.GetBoolConfigValue("ClassicCompanyAllSearchEnabled", false))
                        {
                            foreach (string szID in szValues)
                            {
                                sbSubSelectWhere.Length = 0;
                                AddInCondition(sbSubSelectWhere, "prcserpr_ServiceProvidedID", szID);
                                AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, "prcserpr_CompanyID", "PRCompanyServiceProvided", sbSubSelectWhere);
                            }
                        }
                        else
                        {
                            string[] args = {"PRCompanyServiceProvided",
                                             "prcserpr_CompanyID",
                                             "prcserpr_ServiceProvidedID",
                                             _szServiceProvidedIDs,
                                             szValues.Length.ToString()};

                            sbWhereClause = AddConnector(sbWhereClause);
                            sbWhereClause.Append("comp_CompanyID IN (" + string.Format(SELECT_ALL, args) + ")");
                        }
                        break;
                }
            }
            #endregion



            if (!IsLocalSourceCountOverride &&
                !WebUser.HasLocalSourceDataAccess())
            {
                sbWhereClause = AddConnector(sbWhereClause);
                sbWhereClause.Append("comp_PRLocalSource IS NULL");
            } else {

                if (_szIncludeLocalSource == "ELS")
                {
                    sbWhereClause = AddConnector(sbWhereClause);
                    sbWhereClause.Append("comp_PRLocalSource IS NULL");
                }
                
                if (_szIncludeLocalSource == "LSO")
                {
                    sbWhereClause = AddConnector(sbWhereClause);
                    sbWhereClause.Append("comp_PRLocalSource = 'Y'");
                }


                if (!IsLocalSourceCountOverride)
                {
                    sbWhereClause = AddConnector(sbWhereClause);
                    sbWhereClause.Append(string.Format("(LocalSourceStateID IS NULL OR LocalSourceStateID IN (SELECT DISTINCT prlsr_StateID FROM PRLocalSourceRegion WITH (NOLOCK) WHERE prlsr_ServiceCode IN ({0})))", WebUser.GetLocalSourceDataAccessServiceCodes()));
                }


                if ((!string.IsNullOrEmpty(_szTotalAcres)) ||
                    (_bCertifiedOrganic) ||
                    (!string.IsNullOrEmpty(localSourceGrowsOrganicOverride)))
                {

                    if (sbWhereClause.Length > 0)
                        sbWhereClause.Append(" AND (");
                    else
                        sbWhereClause.Append(" (");

                    sbSubSelectWhere.Length = 0;



                    if (!String.IsNullOrEmpty(_szTotalAcres))
                    {
                        AddInCondition(sbSubSelectWhere, "prls_TotalAcres", _szTotalAcres, true);
                    }

                    if ((_bCertifiedOrganic) ||
                        (!string.IsNullOrEmpty(localSourceGrowsOrganicOverride)))
                    {
                        AddIsNotNullCondition(sbSubSelectWhere, "prls_Organic");
                    }


                    AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, "prls_CompanyID", "PRLocalSource", sbSubSelectWhere);
                    sbWhereClause.Append(")");
                }

                if ((!string.IsNullOrEmpty(_szAlsoOperates)) ||
                    (!string.IsNullOrEmpty(localSourceAlsoOperatesOverride)))
                {
                    if (sbWhereClause.Length > 0)
                        sbWhereClause.Append(" AND (");
                    else
                        sbWhereClause.Append(" (");



                    List<string> temp = new List<string>(_szAlsoOperates.Split(new char[] { ',' }));
                    if ((!string.IsNullOrEmpty(localSourceAlsoOperatesOverride)) &&
                        (_szAlsoOperates.IndexOf(localSourceAlsoOperatesOverride) < 0))
                    {
                        temp.Add(localSourceAlsoOperatesOverride);
                    }

                    sbSubSelectWhere.Length = 0;
                    _bUseOrConnector = true;
                    foreach (string alsoOperates in temp)
                    {
                        if (!string.IsNullOrEmpty(alsoOperates))
                        {
                            AddCondition(sbSubSelectWhere, oParameters, "prls_AlsoOperates", "LIKE", "%" + alsoOperates + "%");
                        }
                    }

                    _bUseOrConnector = false;
                    AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, "prls_CompanyID", "PRLocalSource", sbSubSelectWhere);
                    sbWhereClause.Append(")");
                }
                //}
            }

            #region Internal Critiera
            if (!string.IsNullOrEmpty(_szSalesTerritories))
            {
                AddInCondition(sbWhereClause, "SUBSTRING(prci_SalesTerritory, 1, 2)", _szSalesTerritories, true);
            }

            if (!string.IsNullOrEmpty(_szPrimaryServiceCodes))
            {
                sbSubSelectWhere.Length = 0;
                AddInCondition(sbSubSelectWhere, "ServiceType", _szPrimaryServiceCodes, true);
                AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, "CompanyID", "vPRPrimaryMembers", sbSubSelectWhere);
            }

            if (!string.IsNullOrEmpty(_szMemberTypeCode))
            {
                if (_szMemberTypeCode == "M")
                {
                    sbSubSelectWhere.Length = 0;
                    sbSubSelectWhere.Append("1=1");
                    AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, "CompanyID", "vPRPrimaryMembers", sbSubSelectWhere);
                }

                if (_szMemberTypeCode == "NM")
                {
                    sbSubSelectWhere.Length = 0;
                    sbSubSelectWhere.Append("1=1");
                    AddSubSelect(sbWhereClause, SQL_SUB_SELECT_NOT_COMPANY_ID, "CompanyID", "vPRPrimaryMembers", sbSubSelectWhere);
                }
            }

            if ((_iNumberLicenses > -1) &&
                (!string.IsNullOrEmpty(_szNumberLicenseSearchType)))
            {
                sbSubSelectWhere.Length = 0;
                AddCondition(sbSubSelectWhere, oParameters, "Category2", "=", "License");
                sbSubSelectWhere.Append(" GROUP BY prse_CompanyID HAVING SUM(QuantityOrdered) " + _szNumberLicenseSearchType + " " + _iNumberLicenses.ToString());
                AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, "prse_CompanyID", "PRService", sbSubSelectWhere);
            }


			if(!String.IsNullOrEmpty(_szTerritoryCode))
			{
				// Listing where here.
				AddInCondition(sbWhereClause, "prci_SalesTerritory", _szTerritoryCode, true);
			}

			if ((_iActiveLicenses > -1) &&
                (!string.IsNullOrEmpty(_szActiveLicenseSearchType)))
            {
                sbSubSelectWhere.Length = 0;
                AddCondition(sbSubSelectWhere, oParameters, "prwsat_CreatedDate", ">=", DateTime.Today.AddMonths(0-Utilities.GetIntConfigValue("ActiveLicenseSearchThreshold", 6)));
                sbSubSelectWhere.Append(" GROUP BY prwsat_CompanyID HAVING COUNT(DISTINCT prwsat_WebUserID) " + _szActiveLicenseSearchType + " " + _iActiveLicenses.ToString());
                AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, "prwsat_CompanyID", "PRWebAuditTrail", sbSubSelectWhere);
            }

            if (_bReceivesPromoEmails)
            {
                AddIsNotNullCondition(sbWhereClause, "comp_PRReceivePromoEmails");
            }

            if (_bReceivesPromoFaxes)
            {
                AddIsNotNullCondition(sbWhereClause, "comp_PRReceivePromoFaxes");
            }

            if ((_dMembershipRevenue > -1) &&
                (!string.IsNullOrEmpty(_szMembershipRevenueSearchType)))
            {
                sbSubSelectWhere.Length = 0;
                AddCondition(sbSubSelectWhere, oParameters, "OrderType", "=", "R");
                sbSubSelectWhere.Append(" GROUP BY CustomerNo HAVING SUM(DiscountAmt + TaxableAmt + NonTaxableAmt+ SalesTaxAmt) " + _szMembershipRevenueSearchType + " " + _dMembershipRevenue.ToString());
                AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, "CAST(CustomerNo as Int) CompanyID", "MAS_PRC.dbo.SO_SalesOrderHeader", sbSubSelectWhere);
            }

            if ((_dAdvertisingRevenue > -1) &&
                (!string.IsNullOrEmpty(_szAdvertisingRevenueSearchType)))
            {
                sbSubSelectWhere.Length = 0;
                AddCondition(sbSubSelectWhere, oParameters, "Category2", "=", "Adverts");
                AddCondition(sbSubSelectWhere, oParameters, "InvoiceDate", ">=", DateTime.Today.AddMonths(0 - Utilities.GetIntConfigValue("ActiveLicenseSearchThreshold", 12)));
                sbSubSelectWhere.Append(" GROUP BY CustomerNo HAVING SUM(ExtensionAmt) " + _szAdvertisingRevenueSearchType + " " + _dAdvertisingRevenue.ToString());
                AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, "CAST(CustomerNo as Int) CompanyID", "MAS_PRC.dbo.vBBSiInvoiceDetails", sbSubSelectWhere);
            }


            if ((_iAvailableUnits > -1) &&
                (!string.IsNullOrEmpty(_szAvailableUnitsSearchType)))
            {
                sbSubSelectWhere.Length = 0;
                sbSubSelectWhere.Append(" GETDATE() BETWEEN prun_StartDate AND prun_ExpirationDate");
                sbSubSelectWhere.Append(" GROUP BY prun_CompanyID HAVING SUM(prun_UnitsRemaining) " + _szAvailableUnitsSearchType + " " + _iAvailableUnits.ToString());
                AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, "prun_CompanyID", "PRServiceUnitAllocation", sbSubSelectWhere);
            }


            if ((_iUsedUnits > -1) &&
                (!string.IsNullOrEmpty(_szUsedUnitsSearchType)))
            {
                sbSubSelectWhere.Length = 0;
                AddCondition(sbSubSelectWhere, oParameters, "prsuu_CreatedDate", ">=", new DateTime(DateTime.Today.Year, 1, 1));
                sbSubSelectWhere.Append(" GROUP BY prsuu_CompanyID HAVING SUM(prsuu_Units) " + _szUsedUnitsSearchType + " " + _iUsedUnits.ToString());
                AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, "prsuu_CompanyID", "PRServiceUnitUsage", sbSubSelectWhere);
            }
            #endregion

            if (_customFieldSearchCriteria != null)
            {
                foreach (PRWebUserCustomFieldSearchCriteria customFieldSearch in _customFieldSearchCriteria)
                {
                    AddInCondition(sbWhereClause, COL_COMPANY_COMPANYID, customFieldSearch.GetSearchSQL(oParameters, _oDBAccess));
                }
            }


            return sbWhereClause.ToString();
        }

        /// <summary>
        /// Helper method used to recursively retrieve the ids of the child commodities for the given 
        /// commodity id list.  
        /// </summary>
        /// <param name="szCommodityList">Comma-delimited commodity id list</param>
        /// <returns>comma-delimited list of all child commodity ids</returns>
        private string GetChildCommodityValuesForList(string szCommodityList)
        {
            StringBuilder sbExpandedValueList = new StringBuilder();
            List<string> lCurrentCommodityIDs = new List<string>();

            // Get Each of the current Commodity ids
            string[] aszCurrentCommodityIDs = szCommodityList.Split(new char[] { ',' });
            lCurrentCommodityIDs.AddRange(aszCurrentCommodityIDs);

            // For each commodity in the list, check if there are child commodities
            foreach (string szCommodityID in aszCurrentCommodityIDs)
            {
                // Retrieve Children IDs 
                string szChildCommodityList = "";

                //string szSQL = "SELECT prcm_CommodityID FROM PRCommodity " + GetNoLock() + " WHERE prcm_ParentId = " + szCommodityID;
                string szSQL = "SELECT prcomcat_commodityid FROM PRCommodityCategory " + GetNoLock() + " WHERE prcomcat_ParentId = " + szCommodityID;

                IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();

                IDataReader oReader = oDBAccess.ExecuteReader(szSQL, CommandBehavior.CloseConnection);
                try
                {
                    while (oReader.Read())
                    {
                        // Only add this value if it is not already included in the id list
                        if (!lCurrentCommodityIDs.Contains(oReader.GetInt32(0).ToString()))
                        {
                            if (szChildCommodityList.Length > 0)
                                szChildCommodityList += ", ";

                            szChildCommodityList += oReader.GetInt32(0).ToString();
                        }
                    }
                }
                finally
                {
                    oReader.Close();
                }

                // If children have been found
                if (szChildCommodityList.Length > 0)
                {
                    // Add these to the main list
                    if (sbExpandedValueList.Length > 0)
                        sbExpandedValueList.Append(",");
                    sbExpandedValueList.Append(szChildCommodityList);
                }
            }

            // Return the child commodity list
            return sbExpandedValueList.ToString();
        }


        /// <summary>
        /// Helper method used to recursively retrieve the ids of the child species for the given 
        /// specie id list.  
        /// </summary>
        /// <param name="szSpecieList">Comma-delimited specie id list</param>
        /// <returns>comma-delimited list of all child specie ids</returns>
        private string GetChildSpecieValuesForList(string szSpecieList)
        {
            StringBuilder sbExpandedValueList = new StringBuilder();
            List<string> lCurrentIDs = new List<string>();

            // Get Each of the current ids
            string[] aszCurrentIDs = szSpecieList.Split(new char[] { ',' });
            lCurrentIDs.AddRange(aszCurrentIDs);

            // For each item in the list, check if there are children
            foreach (string szSpecieID in aszCurrentIDs)
            {
                // Retrieve Children IDs 
                string szChildList = "";

                string szSQL = "SELECT prspc_SpecieID " +
                                 "FROM PRSpecie " + GetNoLock() +
                               " WHERE prspc_ParentID = " + szSpecieID;
                IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();

                IDataReader oReader = oDBAccess.ExecuteReader(szSQL, CommandBehavior.CloseConnection);
                try
                {
                    while (oReader.Read())
                    {
                        // Only add this value if it is not already included in the id list
                        if (!lCurrentIDs.Contains(oReader.GetInt32(0).ToString()))
                        {
                            if (szChildList.Length > 0)
                                szChildList += ",";
                            szChildList += oReader.GetInt32(0).ToString();
                        }
                    }
                }
                finally
                {
                    oReader.Close();
                }

                // If children have been found
                if (szChildList.Length > 0)
                {
                    // Add these to the main list
                    if (sbExpandedValueList.Length > 0)
                        sbExpandedValueList.Append(",");
                    sbExpandedValueList.Append(szChildList);

                    // Now go see if there are children for these children
                    string szChildList2 = GetChildSpecieValuesForList(szChildList);
                    if (szChildList2.Length > 0)
                        sbExpandedValueList.Append(",");
                    sbExpandedValueList.Append(szChildList2);
                }
            }

            // Return the child list
            return sbExpandedValueList.ToString();
        }

        protected string BuildFromClause() {
            StringBuilder sbFrom = new StringBuilder("FROM vPRBBOSCompanyList_ALL ");
            sbFrom.Append(GetNoLock());

            if ((!string.IsNullOrEmpty(_szCompanyName)) &&
                (!IsExactSearch(_szCompanyName))) {
                sbFrom.Append(" INNER JOIN PRCompanySearch " + GetNoLock() + " ON comp_CompanyID = prcse_CompanyId ");
            }
            
            if ((!string.IsNullOrEmpty(_szRatingCreditWorthIDs)) ||
                (!string.IsNullOrEmpty(_szRatingCreditWorthMinID)) ||
                (!string.IsNullOrEmpty(_szRatingCreditWorthMaxID)) ||
                (!string.IsNullOrEmpty(_szRatingIntegrityIDs)) ||
                (!string.IsNullOrEmpty(_szRatingPayIDs))) {

                    if (_szCompanyType != "H") 
                    {
                        sbFrom.Append(" INNER JOIN vPRBranchRating " + GetNoLock() + " ON comp_CompanyID = prra_CompanyID ");
                    }
                    else
                    {
                        sbFrom.Append(" INNER JOIN PRRating " + GetNoLock() + " ON comp_CompanyID = prra_CompanyID AND prra_Current = 'Y' ");
                    }
            }

            if ((!string.IsNullOrEmpty(_szListingCountryIDs)) ||
                (!string.IsNullOrEmpty(_szListingStateIDs)) ||
                (!string.IsNullOrEmpty(_szListingCity)) ||
                (!string.IsNullOrEmpty(_szSalesTerritories)) ||
								(!string.IsNullOrEmpty(_szTerritoryCode)))
            {
                sbFrom.Append(" INNER JOIN vPRLocation " + GetNoLock() + " ON comp_PRListingCityID = vPRLocation.prci_CityID ");
            }

            if ((!string.IsNullOrEmpty(_szVolume)) ||
                (!string.IsNullOrEmpty(_szVolumeMax)) ||
                (!string.IsNullOrEmpty(_szVolumeMin)))
            {
                sbFrom.Append(" INNER JOIN PRCompanyProfile " + GetNoLock() + " ON prcp_CompanyID = comp_CompanyID ");
            }

            if (!string.IsNullOrEmpty(_szListingCounty))
            {
                sbFrom.Append(" INNER JOIN vPRAddress " + GetNoLock() + " On comp_CompanyID = vPRAddress.adli_CompanyID ");
            }

            if ((_iPayReportCount > -1) &&
                (!string.IsNullOrEmpty(_szPayReportCountSearchType)))
            {
                sbFrom.Append(" INNER JOIN vPRCompanyARAgingReportCount ON comp_CompanyID = CompanyID ");
            }

            return sbFrom.ToString();
        }        
    }
}


