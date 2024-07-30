/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2015-2022

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CustomFieldList.aspx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using TSI.Utils;

namespace PRCo.EBB.UI.Web
{
    public class Configuration
    {
        static public string AdImageVirtualFolder {
            get { return Utilities.GetConfigValue("AdImageVirtualFolder", "Campaigns/"); }
        }

        static public string AdClickURL
        {
            get { return Utilities.GetConfigValue("AdClickURL", "AdClick.aspx"); }
        }

        static public int AdCampaignTopSpotThreshold
        {
            get { return Utilities.GetIntConfigValue("AdCampaignTopSpotThreshold", 1); }
        }

        static public bool AdCampaignTesting
        {
            get { return Utilities.GetBoolConfigValue("AdCampaignTesting", false); }
        }

        static public string BusinessReportSampleFile
        {
            get { return Utilities.GetConfigValue("BusinessReportSampleFile"); }
        }

        static public bool IsBeta
        {
            get { return Utilities.GetBoolConfigValue("IsBeta", false); }
        }

        static public bool ThrowDevExceptions
        {
            get { return Utilities.GetBoolConfigValue("ThrowDevExceptions", false); }
        }

        static public int ClaimActivityNewThresholdIndicatorDays
        {
            get { return Utilities.GetIntConfigValue("ClaimActivityNewThresholdIndicatorDays", 21); }
        }

        static public int ClaimActivityMeritoriousThresholdIndicatorDays
        {
            get { return Utilities.GetIntConfigValue("ClaimActivityMeritoriousThresholdIndicatorDays", 60); }
        }

        static public int ClaimActivitySearchMaxResults
        {
            get { return Utilities.GetIntConfigValue("ClaimActivitySearchMaxResults", 2000); }
        }


        static public int ClaimActivityFederalCivilCasesThresholdMonths
        {
            get { return Utilities.GetIntConfigValue("ClaimActivityFederalCivilCasesThresholdMonths", 24); }
        }

        static public int ClaimActivityBBSiClaimsThresholdMonths
        {
            get { return Utilities.GetIntConfigValue("ClaimActivityBBSiClaimsThresholdMonths", 24); }
        }

        static public int CompanyUpdateDaysOld
        {
            get { return Utilities.GetIntConfigValue("CompanyUpdateDaysOld", 7); }
        }

        static public int CompanyDetailsUpdateDaysOld
        {
            get { return Utilities.GetIntConfigValue("CompanyDetailsUpdateDaysOld", 90); }
        }

        static public int NewListingDaysThreshold
        {
            get { return Utilities.GetIntConfigValue("NewListingDaysThreshold", 270); }
        }

        static public int CompanyLastChangeThreshold
        {
            get { return Utilities.GetIntConfigValue("CompanyLastChangeThreshold", 90); }
        }

        static public int CompanySearchMaxResults
        {
            get { return Utilities.GetIntConfigValue("CompanySearchMaxResults", 2000); }
        }


        static public string CorporateWebSite
        {
            get { return Utilities.GetConfigValue("CorporateWebSite"); }
        }

        static public int CompanyHeaderKeyNoteLength
        {
            get { return Utilities.GetIntConfigValue("CompanyHeaderKeyNoteLength", 125); }
        }

        static public int PersonSearchMaxResults
        {
            get { return Utilities.GetIntConfigValue("PersonSearchMaxResults", 2000); }
        }

        static public int CompanyUpdateSearchMaxResults
        {
            get { return Utilities.GetIntConfigValue("CompanyUpdateSearchMaxResults", 2000); }
        }

        static public string BlueBookProductID
        {
            get { return Utilities.GetConfigValue("BlueBookProductID", "17"); }
        }

        static public string BlueprintsProductID
        {
            get { return Utilities.GetConfigValue("BlueprintsProductID", "18"); }
        }

        static public string ExpressUpdateProductID
        {
            get { return Utilities.GetConfigValue("ExpressUpdateProductID", "21"); }
        }

        static public string LSSProductID
        {
            get { return Utilities.GetConfigValue("LSSProductID", "83"); }
        }

        static public string LSSAdditionalProductID
        {
            get { return Utilities.GetConfigValue("LSSAdditionalProductID", "84"); }
        }

        static public int BBScoreConfidenceThreshold
        {
            get { return Utilities.GetIntConfigValue("BBScoreConfidenceThreshold", 5); }
        }


        static public string EMailSupportAddress
        {
            get { return Utilities.GetConfigValue("EMailSupportAddress"); }
        }

        static public string WebSiteHome
        {
            get { return Utilities.GetConfigValue("WebSiteHome", "/"); }
        }


        static public string CompanyLogoURL
        {
            get { return Utilities.GetConfigValue("CompanyLogoURL", "/BBSUtils/GetLogo.aspx?LogoFile={0}"); }
        }

        static public bool DisplayDetailsForOneResult
        {
            get { return Utilities.GetBoolConfigValue("DisplayDetailsForOneResult", false); }
        }

        static public string NotEnoughUnitsCSREmail
        {
            get { return Utilities.GetConfigValue("NotEnoughUnitsCSREmail", "customerservice@bluebookservices.com"); }
        }
        
        static public int CompanySearchResultsOneAdPerCompanyCount
        {
            get { return Utilities.GetIntConfigValue("CompanySearchResultsOneAdPerCompanyCount", 10); }
        }

        static public int CompanySearchResultsMinAdCount
        {
            get { return Utilities.GetIntConfigValue("CompanySearchResultsMinAdCount", 3); }
        }

        static public int CompanySearchResultsMaxAdCount
        {
            get { return Utilities.GetIntConfigValue("CompanySearchResultsMaxAdCount", 20); }
        }

        static public string AdvertiserMediaKitURL
        {
            get { return Utilities.GetConfigValue("AdvertiserMediaKitURL", "downloads/Blueprints_Blue Book Online MediaKit.pdf"); }
        }

        static public bool ReadOnlyEnabled
        {
            get { return Utilities.GetBoolConfigValue("ReadOnlyEnabled", false); }
        }

        static public bool CompanySearchLocalSourceCountMsgEnabled
        {
            get { return Utilities.GetBoolConfigValue("CompanySearchLocalSourceCountMsgEnabled", false); }
        }

        static public int CompanyDetailsARReportsTheshold
        {
            get { return Utilities.GetIntConfigValue("CompanyDetailsARReportsTheshold", 24); }
        }

        static public string ARReportsMarketingPage
        {
            get { return Utilities.GetConfigValue("ARReportsMarketingPage", "http://www.producebluebook.com"); }
        }

        static public string ReCaptchaSiteKey
        {
            get { return Utilities.GetConfigValue("ReCaptchaSiteKey", ""); }
        }
        static public string ReCaptchaSecretKey
        {
            get { return Utilities.GetConfigValue("ReCaptchaSecretKey", ""); }
        }
    }
}