/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2007-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: PageConstants
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Contains constants for the EBB page
    /// URLS with paramters.
    /// </summary>
    public class PageConstants
    {
        public const string SYSTEM_INFO = "SystemInfo.aspx";

        public const string AUTO_LOGOFF = "Login.aspx?AutoLogoff=true";
        public const string LOGOFF = "Login.aspx?Logoff=true";
        public const string LOGIN = "Login.aspx";
        public const string LIMITADO = "Limitado.aspx";

        public const string FEEDBACK = "Feedback.aspx";

        public const string ABOUT_BBOS = "About.aspx";
        public const string BBOS_HOME = "~/default.aspx";
        public const string BBOS_DEFAULT = "default.aspx";
        public const string SAVED_SEARCHES = "SearchList.aspx";

        public const string SEARCH_EDIT = "SearchEdit.aspx?SearchID={0}&Type={1}";
        public const string SEARCH_EDIT_POPUP = "SearchEditPopup.aspx";

        public const string BUSINESS_REPORT_CONFIRM_SELECTIONS = "BusinessReportConfirmSelections.aspx?SourceID={0}&SourceEntityType={1}";
        public const string BUSINESS_REPORT_CONFIRM_SELECTIONS_COMPANYIDLIST = "BusinessReportConfirmSelections.aspx?CompanyIDList={0}";
        public const string DATA_EXPORT_CONFIRM_SELECTIONS = "DataExportConfirmSelections.aspx";

        public const string COMPANY_SEARCH = "CompanySearch.aspx";
        public const string COMPANY_SEARCH_LOCATION = "CompanySearchLocation.aspx";
        public const string COMPANY_SEARCH_CLASSIFICATION = "CompanySearchClassification.aspx";
        public const string COMPANY_SEARCH_COMMODITY = "CompanySearchCommodity.aspx";
        public const string COMPANY_SEARCH_RATING = "CompanySearchRating.aspx";
        public const string COMPANY_SEARCH_PROFILE = "CompanySearchProfile.aspx";
        public const string COMPANY_SEARCH_CUSTOM = "CompanySearchCustom.aspx";
        public const string COMPANY_SEARCH_PRODUCT = "CompanySearchProduct.aspx";
        public const string COMPANY_SEARCH_SERVICE = "CompanySearchService.aspx";
        public const string COMPANY_SEARCH_SPECIE = "CompanySearchSpecie.aspx";
        public const string COMPANY_SEARCH_LOCAL_SOURCE = "CompanySearchLocalSource.aspx";

        public const string ADVANCED_COMPANY_SEARCH = "AdvancedCompanySearch.aspx";

        public const string LIMITADO_SEARCH = "LimitadoSearch.aspx";

        public const string SELECT_COMPANY = "SelectCompany.aspx";

        public const string PERSON_SEARCH = "PersonSearch.aspx";
        public const string PERSON_SEARCH_LOCATION = "PersonSearchLocation.aspx";
        public const string PERSON_SEARCH_CUSTOM = "PersonSearchCustom.aspx";
        public const string PERSON_SEARCH_RESULTS_NEW = "PersonSearchResults.aspx";
        public const string PERSON_SEARCH_RESULTS = "PersonSearchResults.aspx?SearchID={0}";
        public const string PERSON_SEARCH_RESULTS_EXECUTE_LAST = "PersonSearchResults.aspx?ExecuteLastSearch=true";

        public const string COMPANY_UPDATE_SEARCH = "CompanyUpdateSearch.aspx";
        public const string SEARCH_WIZARDS = "SearchWizards.aspx";

        public const string NEW_HIRE_ACADEMY = "NewHireAcademy.aspx";

        public const string BROWSE_NOTES = "NoteList.aspx";
        public const string NOTE_EDIT = "NoteEdit.aspx";
        public const string CUSTOM_FIELDS = "CustomFieldList.aspx";
        public const string CUSTOM_FIELD_EDIT = "CustomFieldEdit.aspx?ID={0}";
        public const string CUSTOM_FIELD_LIST = "CustomFieldList.aspx";
        public const string BROWSE_PURCHASES = "Purchases.aspx";
        public const string DOWNLOADS = "Downloads.aspx";
        public const string INDUSTRY_FORMS = "IndustryForms.aspx";

        public const string TES = "TradeExperienceSurvey.aspx";
        public const string TES_SUBJECT = "TradeExperienceSurvey.aspx?CompanyID={0}";
        //public const string EDIT_COMPANY = "EMCW_CompanyListing.aspx";

        public const string CDSW_ADDRESS = "CDSW_Address.aspx";
        public const string CDSW_CONTACT = "CDSW_Contact.aspx";
        public const string CDSW_ENTITY = "CDSW_Entity.aspx";
        public const string CDSW_FINAL = "CDSW_Final.aspx";
        public const string CDSW_FINANCIAL = "CDSW_Financial.aspx";
        public const string CDSW_INDUSTRY_SELECTION = "CDSW_IndustrySelection.aspx";
        public const string CDSW_PERSON = "CDSW_Person.aspx";
        public const string CDSW_PERSON_LIST = "CDSW_PersonList.aspx";
        public const string CDSW_PRODUCE_BROKER = "CDSW_ProduceBroker.aspx";
        public const string CDSW_PRODUCE_BUYER = "CDSW_ProduceBuyer.aspx";
        public const string CDSW_PRODUCE_HANDLING = "CDSW_ProduceHandling.aspx";
        public const string CDSW_PRODUCE_SELLER = "CDSW_ProduceSeller.aspx";
        public const string CDSW_TRANSPORTATION = "CDSW_Transportation.aspx";
        public const string CDSW_TRANSPORTATION_TRUCKING = "CDSW_TransportationTrucking.aspx";
        public const string CDSW_SUPPLIER = "CDSW_Supplier.aspx";
        public const string CDSW_LUMBER_BUYER = "CDSW_LumberBuyer.aspx";
        public const string CDSW_LUMBER_SELLER = "CDSW_LumberSeller.aspx";
        public const string CDSW_LUMBER_HANDLING = "CDSW_LumberHandling.aspx";
        public const string CDSW_LUMBERPRODUCT_HANDLING = "CDSW_LumberProductHandling.aspx";
        public const string CDSW_LUMBERSERVICE_HANDLING = "CDSW_LumberServiceHandling.aspx";
        public const string CDSW_LUMBERSPECIE_HANDLING = "CDSW_LumberSpecieHandling.aspx";

        public const string MEMBERSHIP_SUMMARY = "MembershipSummary.aspx";
        public const string PURCHASE_MEMBERSHIP = "PurchaseMembership.aspx";

        public const string USER_PROFILE = "UserProfile.aspx";
        public const string REGISTER_SELECT = "RegisterSelect.aspx";
        public const string REGISTER_USER_PRODUCE = "RegisterUserProduce.aspx";
        public const string REGISTER_USER_LUMBER = "RegisterUserLumber.aspx";
        public const string RECENT_VIEWS = "RecentViews.aspx";

        public const string AD_CLICK = "AdClick.aspx";
        public const string QA = "QA.aspx";
        public const string ERROR = "Error.aspx";
        public const string EMCW_LISTING = "EMCW_Listing.aspx";
        public const string SYSTEM_MESSAGE = "SystemMessage.aspx";

        public const string LOCAL_SOURCE_MARKETING = "LocalSourceMarketing.aspx";

        /// <summary>
        /// Note: When using this Page you should most likey use the 
        /// PageBase.GetFullSSLURL() method.
        /// </summary>
        public const string CREDIT_CARD_PAYMENT = "CreditCardPayment.aspx";
        public const string CREDIT_CARD_PAYMENT_RECEIPT = "CreditCardPaymentReceipt.aspx";

        public const string MEMBERSHIP_COMPLETE = "MembershipComplete.aspx";

        public const string COMPANY_SEARCH_RESULTS_NEW = "CompanySearchResults.aspx";
        public const string COMPANY_SEARCH_RESULTS = "CompanySearchResults.aspx?SearchID={0}";
        public const string COMPANY_SEARCH_RESULTS_EXECUTE_LAST = "CompanySearchResults.aspx?ExecuteLastSearch=true";

        public const string COMPANY_DETAILS_SUMMARY = "CompanyDetailsSummary.aspx?CompanyID={0}";
        
        public const string LIMITADO_COMPANY = "LimitadoCompany.aspx?CompanyID={0}";

        public const string COMPANY_DETAILS_COMPANY_UPDATES = "CompanyDetailsCompanyUpdates.aspx?CompanyID={0}";
        public const string COMPANY_DETAILS_CONTACTS = "CompanyDetailsContacts.aspx?CompanyID={0}";
        public const string COMPANY_DETAILS_CLASSIFICATIONS = "CompanyDetailsClassifications.aspx?CompanyID={0}";
        public const string COMPANY_NEWS = "CompanyDetailsNews.aspx?CompanyID={0}";

        public const string COMPANY = "Company.aspx?CompanyID={0}";
        public const string COMPANY_CONTACTS_BBOS9 = "CompanyContacts.aspx?CompanyID={0}";
        public const string COMPANY_AR_REPORTS_BBOS9 = "CompanyARReports.aspx?CompanyID={0}";
        public const string COMPANY_CLAIMS_ACTIVITY_BBOS9 = "CompanyClaimsActivity.aspx?CompanyID={0}";

        public const string COMPANY_BRANCHES_BBOS9 = "CompanyBranches.aspx?CompanyID={0}";
        public const string COMPANY_NEWS_BBOS9 = "CompanyNews.aspx?CompanyID={0}";
        public const string COMPANY_UPDATES_BBOS9 = "CompanyUpdates.aspx?CompanyID={0}";
        public const string COMPANY_NOTES_BBOS9 = "CompanyNotes.aspx?CompanyID={0}";
        public const string COMPANY_CSG_BBOS9 = "CompanyCSG.aspx?CompanyID={0}";
        public const string COMANY_PROFILE_VIEWS = "CompanyProfileViews.aspx";

        public const string COMPANY_DETAILS_BRANCHES = "CompanyDetailsBranches.aspx?CompanyID={0}";
        public const string COMPANY_DETAILS_CUSTOM = "CompanyDetailsCustom.aspx?CompanyID={0}";
        public const string COMPANY_DETAILS_NOTE_EDIT = "CompanyDetailsNoteEdit.aspx?CompanyID={0}";
        public const string COMPANY_DETAILS_CUSTOM_EDIT = "CompanyDetailsCustomEdit.aspx?CompanyID={0}";
        public const string COMPANY_DETAILS_CUSTOM_FIELD_EDIT = "CompanyDetailsCustomFieldEdit.aspx?CompanyID={0}";
        public const string COMPANY_DETAILS_CSG = "CompanyDetailsCSG.aspx?CompanyID={0}";
        
        public const string COMPANY_DETAILS_AR_REPORTS = "CompanyDetailsARReports.aspx?CompanyID={0}";

        public const string CLAIMS_ACTIVITY_SEARCH = "ClaimActivitySearch.aspx";
        public const string CLAIMS_ACTIVITY_SEARCH_RESULTS = "ClaimActivitySearchResults.aspx";

        public const string EMCW_COMPANY_LISTING = "EMCW_CompanyListing.aspx";
        public const string EMCW_EDIT_PERSONNEL = "EMCW_EditPersonnel.aspx";
        public const string EMCW_LOGO = "EMCW_Logo.aspx";

        public const string USER_LIST = "UserList.aspx?UserListID={0}";
        public const string USER_LIST_EDIT = "UserListEdit.aspx?UserListID={0}";

        public const string GET_VCARD = "GetVCard.aspx?CompanyID={0}&PersonID={1}";

        public const string EXTERNAL_LINK = "ExternalLink.aspx?BBOSURL={0}&BBOSID={1}&BBOSType={2}";
        public const string EXTERNAL_LINK_TRIGGER = "ExternalLink.aspx?BBOSURL={0}&BBOSID={1}&BBOSType={2}&TriggerPage={3}";

        public const string GET_REPORT = "GetReport.aspx?ReportType={0}";

        public const string COMPANY_UPDATE_DOWNLOAD = "CompanyUpdateDownload.aspx";

        public const string COMPANY_LISTING = "CompanyListing.aspx?CompanyID={0}";
        public const string PERSON_DETAILS = "PersonDetails.aspx?PersonID={0}";
        public const string PERSON_DETAILS_USER_EDIT = "PersonDetailsUserEdit.aspx?PersonID={0}";

        public const string USER_CONTACT = "UserContact.aspx?UserContactID={0}";
        public const string USER_CONTACT_ADD = "UserContactEdit.aspx?CompanyID={0}";
        public const string USER_CONTACT_EDIT = "UserContactEdit.aspx?UserContactID={0}";

        public const string EBB_CONVERSION = "EBBConversion.aspx";

        public const string NEWS_ARTICLE = "NewsArticle.aspx?ArticleID={0}";
        public const string NEWS_ARTICLE_VIEW = "NewsArticleView.aspx?ArticleID={0}";
        //public const string BLUEPRINTS_EDITION = "BlueprintsEdition.aspx?EditionID={0}";
        public const string BLUEPRINTS_ONLINE = "BlueprintsOnline.aspx";
        public const string BLUEPRINTS_ONLINE_ARTICLE = "BlueprintsOnline.aspx?ArticleID={0}";
        public const string BLUEPRINTS_ARCHIVE = "BlueprintsArchive.aspx";
        public const string BLUEPRINTS_FLIPBOOK_ARCHIVE = "BlueprintsFlipbookArchive.aspx";
        public const string BLUEPRINTS_VIEW = "BlueprintsView.aspx?ArticleID={0}";
        public const string BLUEBOOK_REFERENCE = "BlueBookReference.aspx";
        public const string KNOW_YOUR_COMMODITY = "KnowYourCommodity.aspx";
        public const string KNOW_YOUR_COMMODITY_VIEW = "KnowYourCommodityView.aspx?ArticleID={0}";

        public const string GET_PUBLICATION_FILE = "GetPublicationFile.aspx";

        public const string SERVICE_UNIT_PURCHASE = "BusReportPurchase.aspx";
        public const string MEMBERSHIP_SELECT = "MembershipSelect.aspx";
        public const string MEMBERSHIP_SELECT_OPTION = "MembershipSelectOption.aspx";
        public const string MEMBERSHIP_ADDTIONAL_LICENSES = "MembershipAdditionalLicenses.aspx";
        public const string MEMBERSHIP_USERS = "MembershipUsers.aspx";
        public const string MEMBERSHIP_UPGRADE = "MembershipUpgrade.aspx";
        public const string TERMS = "Terms.aspx";
        public const string PERSON_ACCESS_LIST = "PersonAccessList.aspx";

        public const string AD_CAMPAIGN_LIST = "AdCampaignList.aspx";

        public const string SPECIAL_SERVICES_FILE = "SpecialServicesFile.aspx?SSFileID={0}";
        public const string CONTACT_TRADING_ASSISTANCE = "ContactTradingAssistance.aspx"; //public const string SPECIAL_SERVICES_GET_ADVICE = "SpecialServicesGetAdvice.aspx";

        public const string SPECIAL_SERVICES_FILE_CLAIM = "SpecialServicesFileClaim.aspx";
        public const string SPECIAL_SERVICES_COURTESY_CONTACT = "SpecialServicesCourtesyContact.aspx";

        public const string EMCW_REFERENCELIST = "EMCW_ReferenceList.aspx"; //public const string EMCW_CONNECTIONLIST = "EMCW_ConnectionList.aspx";
        public const string EMCW_REFERENCELIST_ADD = "EMCW_ReferenceList.aspx?Add=Y"; //public const string EMCW_CONNECTIONLIST_ADD = "EMCW_ConnectionList.aspx?Add=Y";
        public const string EMCW_FINANCIAL_STATEMENT = "EMCW_FinancialStatement.aspx";
        public const string EMCW_AR_REPORTS = "EMCW_ARReports.aspx";

        public const string USER_LIST_ADD_TO = "UserListAddTo.aspx";
        public const string BROWSE_COMPANIES = "UserListList.aspx";
        public const string REPORTS_CONFIRM_SELECTION = "ReportConfirmSelections.aspx";
        public const string COMPANY_ANALYSIS = "CompanyAnalysis.aspx";
        public const string BLUEPRINTS = "Blueprints.aspx";
        public const string BLUEBOOK_SERVICES = "BlueBookServices.aspx";
        public const string LEARNING_CENTER = "LearningCenter.aspx";
        public const string SPECIAL_SERVICES = "SpecialServicesList.aspx";
        
        public const string BUSINESS_VALUATION = "BusinessValuation.aspx";
        public const string BUSINESS_VALUATION_PURCHSE = "BusinessValuationPurchase.aspx";
        public const string BUSINESS_VALUATION_DOWNLOAD = "BusinessValuationDownload.aspx";

        public const string NEWS = "News.aspx";

        public const string BBOS_SESSIONID = "BBOS_SessionID";
        public const string SESSION_TRACKER = "SessionTracker";
        public const string BBOS_EVENT_SOURCE = "BBOS";

        public const string LSS_PURCHASE = "LSSPurchase.aspx";
        public const string LSS_PURCHASE_CONFIRM = "LSSPurchaseConfirm.aspx";

        public const string EXPRESSUPDATES_PURCHASE = "ExpressUpdatesPurchase.aspx";
        public const string EXPRESSUPDATES_PURCHASE_CONFIRM = "ExpressUpdatesPurchaseConfirm.aspx";

        public const string ALERTS = "Alerts.aspx";

        /// <summary>
        /// Helper method to format URLs.  The string.Format allows up to three (3) object
        /// parameters before requiring them to be in an array.  This makes for a little
        /// cleaner code.
        /// </summary>
        /// <param name="szURL">URL to format</param>
        /// <param name="oParm1">Parameter 1</param>
        /// <returns></returns>
        public static string Format(string szURL, object oParm1)
        {
            return string.Format(szURL, oParm1);
        }
        public static string FormatFromRoot(string szURL, object oParm1)
        {
            return "~/" + string.Format(szURL, oParm1);
        }

        /// <summary>
        /// Helper method to format URLs.  The string.Format allows up to three (3) object
        /// parameters before requiring them to be in an array.  This makes for a little
        /// cleaner code.
        /// </summary>
        /// <param name="szURL">URL to format</param>
        /// <param name="oParm1">Parameter 1</param>
        /// <param name="oParm2">Parameter 2</param>
        /// <returns></returns>
        public static string Format(string szURL, object oParm1, object oParm2)
        {
            return string.Format(szURL, oParm1, oParm2);
        }
        public static string FormatFromRoot(string szURL, object oParm1, object oParm2)
        {
            return "~/" + string.Format(szURL, oParm1, oParm2);
        }

        /// <summary>
        /// Helper method to format URLs.  The string.Format allows up to three (3) object
        /// parameters before requiring them to be in an array.  This makes for a little
        /// cleaner code.
        /// </summary>
        /// <param name="szURL">URL to format</param>
        /// <param name="oParm1">Parameter 1</param>
        /// <param name="oParm2">Parameter 2</param>
        /// <param name="oParm3">Parameter 3</param>
        /// <returns></returns>
        public static string Format(string szURL, object oParm1, object oParm2, object oParm3)
        {
            return string.Format(szURL, oParm1, oParm2, oParm3);
        }
        public static string FormatFromRoot(string szURL, object oParm1, object oParm2, object oParm3)
        {
            return "~/" + string.Format(szURL, oParm1, oParm2, oParm3);
        }

        /// <summary>
        /// Helper method to format URLs.  The string.Format allows up to three (3) object
        /// parameters before requiring them to be in an array.  This makes for a little
        /// cleaner code.
        /// </summary>
        /// <param name="szURL">URL to format</param>
        /// <param name="oParm1">Parameter 1</param>
        /// <param name="oParm2">Parameter 2</param>
        /// <param name="oParm3">Parameter 3</param>
        /// <param name="oParm4">Parameter 4</param>
        /// <returns></returns>
        public static string Format(string szURL, object oParm1, object oParm2, object oParm3, object oParm4)
        {
            object[] args = { oParm1, oParm2, oParm3, oParm4 };
            return string.Format(szURL, args);
        }
        public static string FormatFromRoot(string szURL, object oParm1, object oParm2, object oParm3, object oParm4)
        {
            object[] args = { oParm1, oParm2, oParm3, oParm4 };
            return "~/" + string.Format(szURL, args);
        }

        /// <summary>
        /// Helper method to format URLs.  The string.Format allows up to three (3) object
        /// parameters before requiring them to be in an array.  This makes for a little
        /// cleaner code.
        /// </summary>
        /// <param name="szURL">URL to format</param>
        /// <param name="oParm1">Parameter 1</param>
        /// <param name="oParm2">Parameter 2</param>
        /// <param name="oParm3">Parameter 3</param>
        /// <param name="oParm4">Parameter 4</param>
        /// <param name="oParm5">Parameter 5</param>
        /// <returns></returns>
        public static string Format(string szURL, object oParm1, object oParm2, object oParm3, object oParm4, object oParm5)
        {
            object[] args = { oParm1, oParm2, oParm3, oParm4, oParm5 };
            return string.Format(szURL, args);
        }
        public static string FormatFromRoot(string szURL, object oParm1, object oParm2, object oParm3, object oParm4, object oParm5)
        {
            object[] args = { oParm1, oParm2, oParm3, oParm4, oParm5 };
            return "~/" + string.Format(szURL, args);
        }
    }
}
