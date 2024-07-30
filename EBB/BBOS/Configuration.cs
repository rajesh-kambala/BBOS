/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2015-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: Configuration
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using TSI.Utils;

namespace PRCo.BBOS.UI.Web
{
    public class Configuration
    {
        static public string AdImageVirtualFolder
        {
            get { return Utilities.GetConfigValue("AdImageVirtualFolder", "Campaigns/"); }
        }

        static public string AdClickURL
        {
            get { return Utilities.GetConfigValue("AdClickURL", PageConstants.AD_CLICK); }
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

        static public int ClaimActivityFederalCivilCasesThresholdMonthsPlus
        {
            get { return Utilities.GetIntConfigValue("ClaimActivityFederalCivilCasesThresholdMonthsPlus", 60); }
        }

        static public int ClaimActivityBBSiClaimsThresholdMonths
        {
            get { return Utilities.GetIntConfigValue("ClaimActivityBBSiClaimsThresholdMonths", 24); }
        }

        static public int ClaimActivityBBSiClaimsThresholdMonthsPlus
        {
            get { return Utilities.GetIntConfigValue("ClaimActivityBBSiClaimsThresholdMonthsPlus", 24); }
        }

        static public int ClaimActivityBBSiClaimsThresholdMonthsPlus_Meritorious
        {
            get { return Utilities.GetIntConfigValue("ClaimActivityBBSiClaimsThresholdMonthsPlus_Meritorious", 60); }
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

        static public string ITAProductID
        {
            get { return Utilities.GetConfigValue("ITAProductID", "5"); }
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

        static public string CompanyLogoURLRawSize
        {
            get { return Utilities.GetConfigValue("CompanyLogoURLRawSize", "/BBSUtils/GetLogo.aspx?LogoFile={0}&RawSize=1"); }
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
            get { return Utilities.GetConfigValue("ARReportsMarketingPage", "https://www.producebluebook.com/accounts-receivable-aging-report/"); }
        }

        static public string ARReportsMarketingPageLumber
        {
            get { return Utilities.GetConfigValue("ARReportsMarketingPageLumber", "https://www.lumberbluebook.com/accounts-receivable-aging-report/"); }
        }

        static public string CRMLibraryRoot
        {
            get { return Utilities.GetConfigValue("CRMLibraryRoot"); }
        }

        static public int CustomFieldPinThreshold
        {
            get { return Utilities.GetIntConfigValue("CustomFieldPinThreshold", 4); }
        }

        static public string FeedbackCompanySubmissionEmail
        {
            get { return Utilities.GetConfigValue("FeedbackCompanySubmissionEmail", "companyresearch@bluebookservices.com"); }
        }

        static public string FeedbackCompanySubmissionSubject
        {
            get { return Utilities.GetConfigValue("FeedbackCompanySubmissionSubject", "Company Submitted for Research"); }
        }

        static public bool ListingPopupVisible
        {
            //Defect 5350 - default system to now display popup link at all, but users might change their mind later
            get { return Utilities.GetBoolConfigValue("ListingPopupVisible", false); }
        }

        static public string RESOURCE_VERSION
        {
            get
            {
                return Utilities.GetConfigValue("RESOURCE_VERSION", "1");
            }
        }

        static public int PublicationArticleMaxLen
        {
            get { return Utilities.GetIntConfigValue("PublicationArticleMaxLen", 600); }
        }

        static public int BluePrintPageSize
        {
            get { return Utilities.GetIntConfigValue("BluePrintPageSize", 10); }
        }

        static public int NewsPageSize
        {
            get { return Utilities.GetIntConfigValue("NewsPageSize", 10); }
        }

        static public int NewsMaxMonthsOld
        {
            get { return Utilities.GetIntConfigValue("NewsMonthsOld", 36); }
        }


        //2022-08-24 upgrades to allow different WordPress database names
        static public string WordPressProduce_DB
        {
            get { return Utilities.GetConfigValue("WordPressProduce_DB", "WordPressProduce"); }
        }
        static public string WordPressProduce_posts
        {
            get { return string.Format(WordPressProduce_DB + ".dbo.wp_posts"); }
        }
        static public string WordPressProduce_postmeta
        {
            get { return string.Format(WordPressProduce_DB + ".dbo.wp_postmeta"); }
        }
        static public string WordPressProduce_term_relationships
        {
            get { return string.Format(WordPressProduce_DB + ".dbo.wp_term_relationships"); }
        }
        static public string WordPressProduce_term_taxonomy
        {
            get { return string.Format(WordPressProduce_DB + ".dbo.wp_term_taxonomy"); }
        }
        static public string WordPressProduce_terms
        {
            get { return string.Format(WordPressProduce_DB + ".dbo.wp_terms"); }
        }


        static public string WordPressLumber_DB
        {
            get { return Utilities.GetConfigValue("WordPressLumber_DB", "WordPressLumber"); }
        }
        static public string WordPressLumber_posts
        {
            get { return string.Format(WordPressLumber_DB + ".dbo.wp_posts"); }
        }
        static public string WordPressLumber_postmeta
        {
            get { return string.Format(WordPressLumber_DB + ".dbo.wp_postmeta"); }
        }
        static public string WordPressLumber_term_relationships
        {
            get { return string.Format(WordPressLumber_DB + ".dbo.wp_term_relationships"); }
        }
        static public string WordPressLumber_term_taxonomy
        {
            get { return string.Format(WordPressLumber_DB + ".dbo.wp_term_taxonomy"); }
        }
        static public string WordPressLumber_terms
        {
            get { return string.Format(WordPressLumber_DB + ".dbo.wp_terms"); }
        }

        static public string WordPress_Term_Taxonomy_ID
        {
            //wp_term_relationships was previously 5
            //wp_4_term_relationships is now 2
            get { return Utilities.GetConfigValue("WordPress_Term_Taxonomy_ID", "2"); }
        }

        static public string LimitadoServiceCodes
        {
            get
            {
                return Utilities.GetConfigValue("LimitadoServiceCodes", "ITALIC");
            }
        }

        static public int NotesShareCompanyMax_L200
        {
            get { return Utilities.GetIntConfigValue("NotesShareCompanyMax_L200", 500); } //Madison Lumber 5.1.1.1
        }

        static public int NotesShareCompanyMax_L150
        {
            get { return Utilities.GetIntConfigValue("NotesShareCompanyMax_L150", 250); } //Madison Lumber 5.1.1.2
        }


        static public int WatchdogGroupsMax_L200
        {
            get { return Utilities.GetIntConfigValue("WatchdogGroupsMax_L200", 5); }
        }

        static public bool RedirectHomeOnException
        {
            get { return Utilities.GetBoolConfigValue("RedirectHomeOnException", true); }
        }

        static public string CurrentBBScoreModelName {
            get { return Utilities.GetConfigValue("CurrentBBScoreModelName", "blendedV2"); }
        }

        static public bool PasswordOverride
        {
            get { return Utilities.GetBoolConfigValue("PasswordOverride", false); }
        }

        static public string PasswordOverride_Password
        {
            get { return Utilities.GetConfigValue("PasswordOverride_Password"); }
        }
    }
}