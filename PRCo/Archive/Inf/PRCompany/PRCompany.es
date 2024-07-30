// This file builds the tables for the PRCo CRM system

// Client Prefix
var ClientId = 'PR';

// Null value options
var NL_Allow = 'true';
var NL_Deny = 'false';

// Required field values
var RQ_Required = 'Y';
var RQ_NotRequired = 'N';

// Allow Edit value options
var RO_Edit = 'Y';
var RO_ReadOnly = 'N';

// New line values
var LN_New = 1;
var LN_Same = 0;

// Order values
var OR_Allow = 'Y';

// Entity variables
var ShortEntityName = '';
var EntityCaption = '';
var EntityCaptionPlural = '';
var ColPrefix = '';

var EntityName = '';
var IdField = '';
var NameField = '';

// Script variables
var CreateScript = '';
var ChangeScript = '';
var ValidateScript = '';

// View variables
var sView = '';

// Current screen or grid name
var ObjectName = '';


function DefineCaptions (EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, ProgressEntityName, ProgressIdField) {
   // Main entity search results
   AddCustom_Captions('Tags', EntityName, 'NoRecordsFound', 0, 'No ' + EntityCaptionPlural, '', '', '', '', '', '');
   AddCustom_Captions('Tags', EntityName, 'RecordsFound', 0, EntityCaptionPlural, '', '', '', '', '', '');
   AddCustom_Captions('Tags', EntityName, 'RecordFound', 0, EntityCaption, '', '', '', '', '', '');

   // SS Captions -- REQUIRED
   AddCustom_Captions('Tags', 'SS_ViewFields', EntityName, 0, NameField, '', '', '', '', '', '');
   AddCustom_Captions('Tags', 'SS_idfields', EntityName, 0, IdField, '', '', '', '', '', '');
   AddCustom_Captions('Tags', 'SS_Entities', EntityName, 0, EntityName, '', '', '', '', '', '');

   // Progress Entity SS Captions
   if (ProgressEntityName != '') {
      AddCustom_Captions('Tags', 'SS_idfields', ProgressEntityName, 0, ProgressIdField, '', '', '', '', '', '');
      AddCustom_Captions('Tags', 'SS_Entities', ProgressEntityName, 0, ProgressEntityName, '', '', '', '', '', '');
      AddCustom_Captions('Tags', 'SS_SearchTables', ProgressEntityName, 0, ProgressEntityName, '', '', '', '', '', '');
   }
   
   // Define key fields
   AddCustom_Captions('Tags', EntityName, EntityName, 0, EntityCaption, '', '', '', '', '', '');
   AddCustom_Captions('Tags', EntityName, 'NameColumn', 0, NameField, '', '', '', '', '', '');
   AddCustom_Captions('Tags', EntityName, 'IdColumn', 0, IdField, '', '', '', '', '', '');
   AddCustom_Captions('Tags', EntityName, 'SummaryPage', 0, EntityName + 'Summary.asp', '', '', '', '', '', '');
   
   return true;
}

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// COMPANY START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var EntityName = 'Company';
var ColPrefix = 'comp';

// Modify existing fields
// Allow Company Id to be seen and change caption to BB Id
AddCustom_Captions('Tags', 'ColNames', 'comp_CompanyId', 0, 'BB Id', '', '', '', '', '', '');
AddCustom_Captions('Tags', EntityName, 'NameColumn', 0, 'comp_Name', '', '', '', '', '', '');

// ------> CREATE SCREENS
// Search screen
ObjectName = EntityName + 'SearchBox';

// delete the native "CompanySearchBox" Screen Object
DeleteCustom_ScreenObject(ObjectName,'',1);

// Create the custom content for the search screen
var sCustomContent = 
		"<script language=javascript src=\"/CRM/CustomPages/PRCoGeneral.js\"></script>" +
        "<script language=javascript > " + 
            "document.body.onload=function()" + 
            "{" +
                " var oTables = document.getElementsByTagName(\"table\"); " +
                " for (n=0; n<oTables.length; n++) "+
                " { "+
                " if (oTables[n].className == \"workflow\") "+
                " { oTables[n].style.display = \"none\"; break; } "+
                " } " +
                " RemoveDropdownItemByName(\"comp_prtype\", \"--None--\"); " +
                " RemoveDropdownItemByName(\"comp_prlistingstatus\", \"--None--\"); " +
                " RemoveDropdownItemByName(\"comp_prindustrytype\", \"--None--\"); " +
                " LoadComplete(\"\");" +
            "} "+
        "</script>";


// we'll use our customized version of vSearchListCompany (vPRSearchListCompany)
AddCustom_ScreenObjects(ObjectName, 'SearchScreen', EntityName, 'N', 0, 'vPRSearchListCompany', '', sCustomContent, '', '', '', '');
AddCustom_Screens(ObjectName, 1, 'comp_CompanyId',      LN_New,  1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, 'comp_name',           LN_Same,  1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 10, 'comp_PRType',         LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 15, 'comp_PRIndustryType', LN_Same, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 20, 'comp_PRListingCityId',  LN_New,  1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 25, 'prst_StateId', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 50, 'comp_PRListingStatus',LN_New,  1, 2, RQ_NotRequired, 0, '', '', '');

// The main listing for companies off the Find menu
ObjectName = 'CompanyGrid';

// Add custom captions for the fields defined in vPRSearchListCompany
AddCustom_Captions('Tags', 'ColNames', 'comp_CompanyIdDisplay', 0, 'BB Id', '', '', '', '', '', '');
AddCustom_Captions('Tags', 'ColNames', 'comp_ListingCityStateCountry', 0, 'Listing Location', '', '', '', '', '', '');
AddCustom_Captions('Tags', 'ColNames', 'comp_StatusDisplay', 0, 'Listed', '', '', '', '', '', '');
AddCustom_Captions('Tags', 'ColNames', 'comp_TypeDisplay', 0, 'Type', '', '', '', '', '', '');

DeleteCustom_ScreenObject(ObjectName,'',1);
// Note: we tried to use a customized version of vSearchListCompany (named vPRSearchListCompany) to do this
// search,;however, accpac always uses vSearchListCompany for CompanyGrid display.  Therefore, we had to 
// modify the native accpac vSearchListCompany view.
AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, 'vSearchListCompany', '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '10', 'comp_CompanyIdDisplay', '', OR_Allow, '', 'LEFT', 'company', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '20', 'comp_prindustrytype', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '30', 'comp_TypeDisplay', '', OR_Allow, '', 'CENTER', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '40', 'comp_name', '', OR_Allow, '', 'LEFT', 'company', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '50', 'comp_ListingCityStateCountry', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '60', 'comp_StatusDisplay', '', OR_Allow, '', 'CENTER', '', '', '', '', '', 0);

// Branch list
ObjectName = 'PRCompanyBranchGrid';
AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, 'vPRCompanyBranchForListing', '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '10', 'comp_CompanyIdDisplay', '', OR_Allow, '', 'LEFT', 'company', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '40', 'comp_name', '', OR_Allow, '', 'LEFT', 'company', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '50', 'comp_ListingCityStateCountry', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '60', 'comp_prindustrytype', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '70', 'comp_StatusDisplay', '', OR_Allow, '', 'CENTER', '', '', '', '', '', 0);

// Relationship screen
ObjectName = 'PRRelationshipHeader';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'PRConnectionListDate', LN_New, 1, 1, RQ_NotRequired, 0, '', '', 'ReadOnly=true;');

// Special Instructions screen
ObjectName = 'PRSpecialInstructions';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'PRSpecialInstruction', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

// DL screen
ObjectName = 'PRDL';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'PRDL', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

// DL Phrase screen
ObjectName = 'PRDLPhrase';

var sCustomContent = "<table><tr><td><a class=ButtonItem href=javascript:document.EntryForm.submit();><img align=left border=0 src=\"../../img/Buttons/new.gif\" id=one>Add Phrase</a></td></tr></table>"
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', sCustomContent, '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'PRDLPhrase', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

// Unload Hours screen
ObjectName = 'PRUnloadHours';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'PRUnloadHours', LN_New, 4, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'PRPublishUnloadHours', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// Services Through Block
ObjectName = 'PRServicesThrough';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, 'comp_PRServicesThroughCompanyId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

// Field List screen
ObjectName = 'PRFieldList';

var sCustomContent = "<table><tr><td><a class=ButtonItem href=javascript:document.EntryForm.submit();><img align=left border=0 src=\"../../img/Buttons/new.gif\" id=one>Add Field</a></td></tr></table>"
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', sCustomContent, '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'PRSelectCompany', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'PRFieldList', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'PRRecord', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');


OnChangeScript='" onkeyup="UpdateTradestyles();';
// definition for the new company screen
ObjectName = 'PRCompanyNew'
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'PRType', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'PRHQId', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'PRTradestyle1', LN_New, 1, 1, RQ_Required, 0, OnChangeScript, '', '');
AddCustom_Screens(ObjectName, 21, ColPrefix + '_' + 'PRTradestyle2', LN_Same, 1, 1, RQ_NotRequired, 0, OnChangeScript, '', '');
AddCustom_Screens(ObjectName, 31, ColPrefix + '_' + 'PRTradestyle3', LN_New, 1, 1, RQ_NotRequired, 0, OnChangeScript, '', '');
AddCustom_Screens(ObjectName, 41, ColPrefix + '_' + 'PRTradestyle4', LN_Same, 1, 1, RQ_NotRequired, 0, OnChangeScript, '', '');
AddCustom_Screens(ObjectName, 61, ColPrefix + '_' + 'Name', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 71, ColPrefix + '_' + 'PRCorrTradestyle', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 81, ColPrefix + '_' + 'PRBookTradestyle', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 91, ColPrefix + '_' + 'PRListingCityId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 94, ColPrefix + '_' + 'PRCommunicationLanguage', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 101, ColPrefix + '_' + 'Source', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 111, ColPrefix + '_' + 'PRMethodSourceReceived', LN_Same, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 121, ColPrefix + '_' + 'PRIndustryType', LN_New, 1, 1, RQ_Required, 0, '', '', '');


OnChangeScript='" onkeyup="UpdateTradestyles();';
// Company Info screen
ObjectName = 'PRCompanyInfo';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 10, ColPrefix + '_' + 'PRType', LN_New, 1, 1, RQ_NotRequired, 0, '', '', 'ReadOnly=true;');
AddCustom_Screens(ObjectName, 20, ColPrefix + '_' + 'PRHQId', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', 'ReadOnly=true;');
AddCustom_Screens(ObjectName, 30, ColPrefix + '_' + 'PRListingStatus', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 35, ColPrefix + '_' + 'PRListingCityId', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 37, ColPrefix + '_' + 'PRCommunicationLanguage', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 40, ColPrefix + '_' + 'PRIndustryType', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 41, ColPrefix + '_' + 'PRDataQualityTier', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 42, ColPrefix + '_' + 'PRAccountTier', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 50, ColPrefix + '_' + 'PRTradestyle1', LN_New, 1, 1, RQ_Required, 0, OnChangeScript, '', '');
AddCustom_Screens(ObjectName, 60, ColPrefix + '_' + 'PRTradestyle2', LN_Same, 1, 1, RQ_NotRequired, 0, OnChangeScript, '', '');
AddCustom_Screens(ObjectName, 65, ColPrefix + '_' + 'PRTradestyle3', LN_New, 1, 1, RQ_NotRequired, 0, OnChangeScript, '', '');
AddCustom_Screens(ObjectName, 70, ColPrefix + '_' + 'PRTradestyle4', LN_Same, 1, 1, RQ_NotRequired, 0, OnChangeScript, '', '');
AddCustom_Screens(ObjectName, 75, ColPrefix + '_' + 'PRLegalName', LN_New, 1, 3, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 80, ColPrefix + '_' + 'Name', LN_New, 1, 3, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 85, ColPrefix + '_' + 'PRCorrTradestyle', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 87, ColPrefix + '_' + 'PRBookTradestyle', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 90, ColPrefix + '_' + 'PROriginalName', LN_New, 1, 3, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 100, ColPrefix + '_' + 'PROldName1', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 110, ColPrefix + '_' + 'PROldName1Date', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 120, ColPrefix + '_' + 'PROldName2', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 130, ColPrefix + '_' + 'PROldName2Date', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 140, ColPrefix + '_' + 'PROldName3', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 150, ColPrefix + '_' + 'PROldName3Date', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 160, ColPrefix + '_' + 'Source', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 161, ColPrefix + '_' + 'PRHandlesInvoicing', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
//AddCustom_Screens(ObjectName, 163, ColPrefix + '_' + 'PRReceiveLRL', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 170, ColPrefix + '_' + 'PRConnectionListDate', LN_New, 1, 1, RQ_NotRequired, 0, '', '', 'ReadOnly=true;');
AddCustom_Screens(ObjectName, 175, ColPrefix + '_' + 'PRConfidentialFS', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 176, ColPrefix + '_' + 'PRFinancialStatementDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', 'ReadOnly=true;');
AddCustom_Screens(ObjectName, 180, ColPrefix + '_' + 'PRInvestigationMethodGroup', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 181, ColPrefix + '_' + 'PRReceiveTES', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 185, ColPrefix + '_' + 'PRReceiveCSSurvey', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 190, ColPrefix + '_' + 'PRReceivePromoFaxes', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 195, ColPrefix + '_' + 'PRReceivePromoEmails', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 200, ColPrefix + '_' + 'PRWebActivated', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 201, ColPrefix + '_' + 'PRWebActivatedDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 210, ColPrefix + '_' + 'PRAdministrativeUsage', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 211, ColPrefix + '_' + 'PRReceivesBBScoreReport', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 220, ColPrefix + '_' + 'PRLastVisitDate', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 221, ColPrefix + '_' + 'PRLastVisitedBy', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 230, ColPrefix + '_' + 'PRBusinessReport', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 240, ColPrefix + '_' + 'PRPrincipalsBackgroundText', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');


// PRCO Logo / Spotlight screen
ObjectName = 'PRLogoSpotlight';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'PRLogo', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'PRSpotlight', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

// PRCO T/M screen
ObjectName = 'PRTradingMember';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'PRTMFMCandidate', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'PRTMFMCandidateDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'PRTMFMAward', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'PRTMFMAwardDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'PRTMFMComments', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

// Line Count screen
ObjectName = 'PRCompanyLineCount';

DeleteCustom_ScreenObject(ObjectName,'',1);
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'PRPaidLines', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'PRBodyLines', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'PRTotalLines', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

// Record Info screen
ObjectName = 'PRCreditWorthCap';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'CompanyId', LN_New, 1, 1, RQ_Required, 0, '', '', 'Hidden=true;');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'PRCreditWorthCapReason', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');




// Advanced Search screen
ObjectName = EntityName + 'AdvancedSearchBox';

// Create the custom content for the search screen
var sCustomContent = 
		"<script language=javascript src=\"/CRM/CustomPages/PRCoGeneral.js\"></script>" +
        "<script language=javascript > " + 
            "document.body.onload=function()" + 
            "{" +
                " RemoveDropdownItemByName(\"comp_prtype\", \"--None--\"); " +
                " RemoveDropdownItemByName(\"comp_prlistingstatus\", \"--None--\"); " +
                " LoadComplete(\"\");" +
            "} "+
        "</script>";
        
AddCustom_ScreenObjects(ObjectName, 'SearchScreen', EntityName, 'N', 0, '', '', sCustomContent, '', '', '', '');
AddCustom_Screens(ObjectName, 1,  'comp_name',            LN_New,  1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2,  'comp_PRType',          LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3,  'comp_PRListingCityId', LN_New,  1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4,  'prst_StateId',         LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5,  'comp_PRListingStatus', LN_New,  1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 6,  'prdr_LicenseNumber',   LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 7,  'emai_EmailAddress',    LN_New,  1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 8,  'prc3_Brand',           LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 9,  'phon_AreaCode',        LN_New,  1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 10, 'phon_Number',          LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 11, 'prse_ServiceID',       LN_New,  1, 1, RQ_NotRequired, 0, '', '', '');


// Add Company Advanced File to Find dropdwon  
// Set the sequence to 2 so it follows the Company find
AddCustom_Tabs('0', '0', '2', 'Find', 'Company - Advanced', 'customfile', 'PRCompany/PRCompanyAdvancedSearch.asp', '', 'Company.gif', 0);  



// ------> HIDE TABS
// Hide some of the Company tabs
sEntityName = 'Company';
// Moved to Database script

// ------> CHANGE TABS
// Cannot do this here!!!!  Apparently AddCustom_Data inadvertently sets the tabs_Order field to NULL;
// moved modifications to the Company.SQL file.
//AddCustom_Data('Custom_Tabs','Tabs','Tabs_TabId','Tabs_Entity, Tabs_Caption, Tabs_Action, Tabs_CustomFileName', 'Company, Summary, customfile, PRCompany/PRCompanySummary.asp','1, 2');
//AddCustom_Data('Custom_Tabs','Tabs','Tabs_TabId','Tabs_Entity, Tabs_Caption, Tabs_Action, Tabs_CustomFileName', 'Company, Opportunities, customfile, PROpportunity/OpportunityListing.asp','1, 2');

// ------> CREATE TABS
// Create the tabs
AddCustom_Tabs('0', '0', '02', 'Company', 'Profile', 'customfile', 'PRCompany/PRCompanyProfile.asp', '', '', 0);
AddCustom_Tabs('0', '0', '03', 'Company', 'Contact Info', 'customfile', 'PRCompany/PRCompanyContactInfoListing.asp', '', '', 0);
AddCustom_Tabs('0', '0', '04', 'Company', 'Personnel', 'customfile', 'PRCompany/PRCompanyPeople.asp', '', '', 0);
AddCustom_Tabs('0', '0', '05', 'Company', 'Transactions', 'customfile', 'PRCompany/PRCompanyTransaction.asp', '', '', 0);
AddCustom_Tabs('0', '0', '06', 'Company', 'Rating', 'customfile', 'PRCompany/PRCompanyRatingListing.asp', '', '', 0);
AddCustom_Tabs('0', '0', '07', 'Company', 'Trade Activity', 'customfile', 'PRCompany/PRCompanyTradeActivityListing.asp', '', '', 0);
AddCustom_Tabs('0', '0', '08', 'Company', 'Relationships', 'customfile', 'PRCompany/PRCompanyRelationshipListing.asp', '', '', 0);
AddCustom_Tabs('0', '0', '09', 'Company', 'Bus. Events', 'customfile', 'PRCompany/PRCompanyBusinessEventListing.asp', '', '', 0);
AddCustom_Tabs('0', '0', '10', 'Company', 'Services', 'customfile', 'PRCompany/PRCompanyService.asp', '', '', 0);
// set in build script 
//ChangeTabOrder(sEntityName, 'Opportunities', '11');
//ChangeTabOrder(sEntityName, 'Cases', '12');
AddCustom_Tabs('0', '0', '13', 'Company', 'SS Files', 'customfile', 'PRFile/PRFileListing.asp', '', '', 0);
// set in build script 
//ChangeTabOrder(sEntityName, 'Communications', '14');
//ChangeTabOrder(sEntityName, 'Library', '15');

// AddCustom_Tabs('0', '0', '20', 'Company', 'C/S Items', 'customfile', 'PRCompany/PRCompanyCreditSheet.asp', '', '', 0);
// AddCustom_Tabs('0', '0', '20', 'Company', 'Investigation', 'customfile', 'PRCompany/PRCompanyInvestigation.asp', '', '', 0);
// AddCustom_Tabs('0', '0', '20', 'Company', 'B/R Requests', 'customfile', 'PRCompany/PRCompanyBusinessReport.asp', '', '', 0);
// AddCustom_Tabs('0', '0', '20', 'Company', 'Classifications', 'customfile', 'PRCompany/PRCompanyClassification.asp', '', '', 0);
// AddCustom_Tabs('0', '0', '20', 'Company', 'Commodities', 'customfile', 'PRCompany/PRCompanyCommodityListing.asp', '', '', 0);
// AddCustom_Tabs('0', '0', '20', 'Company', 'Branches', 'customfile', 'PRCompany/PRCompanyBranchListing.asp', '', '', 0);
// AddCustom_Tabs('0', '0', '20', 'Company', 'Financials', 'customfile', 'PRCompany/PRCompanyFinancial.asp', '', '', 0);
// AddCustom_Tabs('0', '0', '20', 'Company', 'Licenses', 'customfile', 'PRCompany/PRCompanyLicense.asp', '', '', 0);

// Main entity search results
AddCustom_Captions('Tags', 'Company', 'NoRecordsFound', 0, 'No Companies', '', '', '', '', '', '');
AddCustom_Captions('Tags', 'Company', 'RecordsFound', 0, 'Companies', '', '', '', '', '', '');
AddCustom_Captions('Tags', 'Company', 'RecordFound', 0, 'Company', '', '', '', '', '', '');


////////////////////////////////////////////////////////////////////////
// *********************************************************************
// COMPANY ALIAS START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'CompanyAlias';
var EntityCaption = 'Alias';
var EntityCaptionPlural = 'Aliases';
var ColPrefix = 'pral';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = 'pral_Alias';

// ------> CREATE SCREENS
// Main entity new screen
ObjectName = 'PRCompanyAliasNewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

CreateScript = 'ReadOnly = true;';
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'CompanyId', LN_New, 1, 1, RQ_Required, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'Alias', LN_Same, 1, 1, RQ_Required, 0, '', '', '');

// ------> CREATE LISTS
// Summary list
ObjectName = 'PRCompanyAliasGrid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', 'pral_Alias', '', OR_Allow, '', '', 'Custom', '', '', 'PRCompany/PRCompanyAlias.asp', IdField, 0);

// ------> CREATE TABS
// Create the tab group
AddCustom_ScreenObjects(EntityName, 'TabGroup', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

// Create the tabs
AddCustom_Tabs('0', '0', '10', EntityName, 'Summary', 'customfile', EntityName + '/' + EntityName + '.asp', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// COMPANY BANK START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'CompanyBank';
var EntityCaption = 'Bank';
var EntityCaptionPlural = 'Banks';
var ColPrefix = 'prcb';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'BankId';

// ------> CREATE SCREENS
// Main entity new screen
ObjectName = 'PRCompanyBankNewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

CreateScript = 'Hidden=true; ReadOnly = true;';
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'CompanyId', LN_New, 1, 3, RQ_Required, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'Publish', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'Name', LN_New, 1, 3, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'Address1', LN_New, 1, 3, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'Address2', LN_New, 1, 3, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 6, ColPrefix + '_' + 'City', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 7, ColPrefix + '_' + 'State', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 8, ColPrefix + '_' + 'PostalCode', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 9, ColPrefix + '_' + 'Telephone', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 10, ColPrefix + '_' + 'Fax', LN_Same, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 11, ColPrefix + '_' + 'Website', LN_New, 1, 3, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 12, ColPrefix + '_' + 'AdditionalInfo', LN_New, 1, 3, RQ_NotRequired, 0, '', '', '');

// ------> CREATE LISTS
// Summary list
ObjectName = 'PRCompanyBankGrid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, 1, ColPrefix + '_Name', '', OR_Allow, '', '', 'Custom', '', '', 'PRCompany/PRCompanyBank.asp', IdField, 0);
AddCustom_Lists(ObjectName, 10, ColPrefix + '_Publish', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, 20, ColPrefix + '_Telephone', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, 30, ColPrefix + '_Website', '', OR_Allow, '', '', '', '', '', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// COMPANY BRAND START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'CompanyBrand';
var EntityCaption = 'Brand';
var EntityCaptionPlural = 'Brands';
var ColPrefix = 'prc3';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'Brand';

// ------> CREATE SCREENS
// Main entity new screen
ObjectName = 'PRCompanyBrandNewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

CreateScript = 'ReadOnly = true;';
//AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'CompanyId', LN_New, 1, 1, RQ_Required, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'Brand', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 7, ColPrefix + '_' + 'Publish', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 10, ColPrefix + '_' + 'Description', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');

// ------> CREATE LISTS
// Summary list
ObjectName = 'PRCompanyBrandGrid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', ColPrefix + '_' + 'Brand', '', OR_Allow, '', '', 'Custom', '', '', 'PRCompany/PRCompanyBrand.asp', IdField, 0);
AddCustom_Lists(ObjectName, '5', ColPrefix + '_' + 'Publish', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '10', ColPrefix + '_' + 'Description', '', OR_Allow, '', '', '', '', '', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// COMPANY CLASSIFICATION START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'CompanyClassification';
var EntityCaption = 'Classification';
var EntityCaptionPlural = 'Classifications';
var ColPrefix = 'prc2';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'ClassificationId';

// ------> CREATE LISTS
// Summary list
ObjectName = 'PRCompanyClassificationGrid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, 'vPRCompanyClassification', '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', ColPrefix + '_' + 'ClassificationId', '', OR_Allow, '', '', 'Custom', '', '', 'PRCompany/PRCompanyClassification.asp', IdField, 0);
AddCustom_Lists(ObjectName, '2', 'prcl_Abbreviation', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '3', ColPrefix + '_' + 'Percentage', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '4', ColPrefix + '_' + 'PercentageSource', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '5', ColPrefix + '_' + 'NumberOfStores', '', OR_Allow, '', '', '', '', '', '', '', 0);

// Additional attributes for Retail
ObjectName = 'PRCompClassProps_Ret';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

// Additional attributes for All classifications
ObjectName = 'PRCompClassProps_All';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'Percentage', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'PercentageSource', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// Additional attributes for Retail
ObjectName = 'PRCompClassProps_Restaurant';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'NumberOfStores', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

// Additional attributes for Retail
ObjectName = 'PRCompClassProps_Ret';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'NumberOfStores', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'ComboStores', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'NumberOfComboStores', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'ConvenienceStores', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'NumberOfConvenienceStores', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 6, ColPrefix + '_' + 'GourmetStores', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 7, ColPrefix + '_' + 'NumberOfGourmetStores', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 8, ColPrefix + '_' + 'HealthFoodStores', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 9, ColPrefix + '_' + 'NumberOfHealthFoodStores', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 10, ColPrefix + '_' + 'ProduceOnlyStores', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 11, ColPrefix + '_' + 'NumberOfProduceOnlyStores', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 12, ColPrefix + '_' + 'SupermarketStores', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 13, ColPrefix + '_' + 'NumberOfSupermarketStores', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 14, ColPrefix + '_' + 'SuperStores', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 15, ColPrefix + '_' + 'NumberOfSuperStores', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 16, ColPrefix + '_' + 'WarehouseStores', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 17, ColPrefix + '_' + 'NumberOfWarehouseStores', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// Additional attributes for the freight forwarder
ObjectName = 'PRCompClassProps_FgtF';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'AirFreight', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'GroundFreight', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'OceanFreight', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'RailFreight', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// COMPANY COMMODITY START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'CompanyCommodity';
var EntityCaption = 'Commodity';
var EntityCaptionPlural = 'Commodities';
var ColPrefix = 'prcc';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';

// ------> CREATE LISTS
// Detail list
ObjectName = 'CompanyPRCommodityDetailGrid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', ColPrefix + '_' + 'CommodityNumber', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '2', ColPrefix + '_' + 'AttributeId', '', OR_Allow, '', '', '', '', '', '', '', 0);

// Summary list
ObjectName = 'CompanyPRCommodityGrid';

AddCustom_ScreenObjects(ObjectName, 'List', 'prcca_CompanyCommodityAttributeId', 'N', 0, 'vListingPRCompanyCommodity', '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', 'prcca_Sequence', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '2', 'prcca_Publish', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '3', 'prcca_ListingCol1', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '4', 'prcca_ListingCol2', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '5', 'AttributeName', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '6', 'GrowingMethod', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '7', 'prcca_PublishedDisplay', '', OR_Allow, '', '', '', '', '', '', '', 0);

AddCustom_Captions('Tags', 'ColNames', 'AttributeName', 0, 'Attribute', '', '', '', '', '', '');
AddCustom_Captions('Tags', 'ColNames', 'GrowingMethod', 0, 'Growing Method', '', '', '', '', '', '');
AddCustom_Captions('Tags', 'ColNames', 'prcca_ListingCol1', 0, 'Commodity/Category/Group', '', '', '', '', '', '');
AddCustom_Captions('Tags', 'ColNames', 'prcca_ListingCol2', 0, 'Variety/Group/Refinement', '', '', '', '', '', '');
AddCustom_Captions('Tags', 'ColNames', 'prcca_PublishedDisplay', 0, 'Display', '', '', '', '', '', '');


// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');


////////////////////////////////////////////////////////////////////////
// *********************************************************************
// COMPANY DOMESTIC REGION START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'CompanyDomesticRegion';
var EntityCaption = 'Domestic Region';
var EntityCaptionPlural = 'Domestic Regions';
var ColPrefix = 'prcd';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';

// ------> CREATE SCREENS
// Main entity new screen
ObjectName = 'PRCompanyDomesticRegionNewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

CreateScript = 'ReadOnly = true;';
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'CompanyId', LN_New, 1, 1, RQ_Required, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'DomesticRegionId', LN_Same, 1, 1, RQ_Required, 0, '', '', '');

// ------> CREATE LISTS
// Summary list
ObjectName = 'PRCompanyDomesticRegionGrid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, 'PRCompanyRegion', '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', 'prd2_Name', '', OR_Allow, '', '', 'Custom', '', '', 'PRCompany/PRCompanyDomesticRegionSummary.asp', IdField, 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// COMPANY STOCK EXCHANGE START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'CompanyStockExchange';
var EntityCaption = 'Company Stock Exchange';
var EntityCaptionPlural = 'Company Stock Exchanges';
var ColPrefix = 'prc4';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'ExchangeId';

// ------> CREATE VIEWS
// Main view
sView = "CREATE VIEW vPRCompanyStockExchange AS ";
sView = sView + "SELECT dbo.PRCompanyStockExchange.*, ";
sView = sView + "       dbo.PRStockExchange.prex_Name ";
sView = sView + "FROM dbo.PRCompanyStockExchange ";
sView = sView + "     LEFT OUTER JOIN dbo.PRStockExchange ON dbo.PRCompanyStockExchange.prc4_StockExchangeId = dbo.PRStockExchange.prex_StockExchangeId ";
AddView("vPRCompanyStockExchange", EntityName, "Sets view for Company Stock Exchange", sView, false, false, false, false, false);

// ------> CREATE SCREENS
// Main entity new screen
ObjectName = 'PRCompanyStockExchangeNewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

CreateScript = 'ReadOnly = true;';
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'CompanyId', LN_New, 1, 1, RQ_Required, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'StockExchangeId', LN_Same, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'Symbol1', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'Symbol2', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'Symbol3', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// ------> CREATE LISTS
// Main entity list
ObjectName = 'PRCompanyStockExchangeGrid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, 'vPRCompanyStockExchange', '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', 'prex_Name', '', OR_Allow, '', '', 'Custom', '', '', 'PRCompany/PRCompanyStockExchange.asp', IdField, 0);
AddCustom_Lists(ObjectName, '2', ColPrefix + '_' + 'Symbol1', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '3', ColPrefix + '_' + 'Symbol2', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '4', ColPrefix + '_' + 'Symbol3', '', OR_Allow, '', '', '', '', '', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// COMPANY INFO PROFILE START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
var ShortEntityName = 'CompanyInfoProfile';
var EntityCaption = 'Info Profile';
var EntityCaptionPlural = 'Info Profile';
var ColPrefix = 'prc5';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'CompanyId';

// ------> CREATE SCREENS
// Main entity new screen
ObjectName = 'PRCompanyInfoProfileHeader';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

//AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'InformationProfileDate', LN_New, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
//AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'InformationProfileUserId', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'UpdatedDate', LN_New, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'UpdatedBy', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);

// Main entity new screen
ObjectName = 'PRCompanyCompetitiveInfo';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'BBUse', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'BBServiceBenefits', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'BBRankingUsage', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'BBAmountSpent', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'BBComments', LN_New, 1, 3, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 6, ColPrefix + '_' + 'RBCSUse', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 7, ColPrefix + '_' + 'RBCSServiceBenefits', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 8, ColPrefix + '_' + 'RBCSRankingUsage', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 9, ColPrefix + '_' + 'RBCSAmountSpent', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 10, ColPrefix + '_' + 'RBCSComments', LN_New, 1, 3, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 11, ColPrefix + '_' + 'DBUse', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 12, ColPrefix + '_' + 'DBServiceBenefits', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 13, ColPrefix + '_' + 'DBRankingUsage', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 14, ColPrefix + '_' + 'DBAmountSpent', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 15, ColPrefix + '_' + 'DBComments', LN_New, 1, 3, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 16, ColPrefix + '_' + 'ExperianUse', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 17, ColPrefix + '_' + 'ExperianServiceBenefits', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 18, ColPrefix + '_' + 'ExperianRankingUsage', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 19, ColPrefix + '_' + 'ExperianAmountSpent', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 20, ColPrefix + '_' + 'ExperianComments', LN_New, 1, 3, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 21, ColPrefix + '_' + 'CompunetUse', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 22, ColPrefix + '_' + 'CompunetServiceBenefits', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 23, ColPrefix + '_' + 'CompunetRankingUsage', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 24, ColPrefix + '_' + 'CompunetAmountSpent', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 25, ColPrefix + '_' + 'CompunetComments', LN_New, 1, 3, RQ_NotRequired, 0, '', '', '');

// Main entity new screen
ObjectName = 'PRCompanyCreditProcess';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'CreditApplication', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'CreditPolicy', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'NewSaleCreditApprover', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'CreditIncreaseApprover', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'CreditCutoffApprover', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 6, ColPrefix + '_' + 'NoPayApprover', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 7, ColPrefix + '_' + 'CreditComments', LN_New, 1, 3, RQ_NotRequired, 0, '', '', '');

// Main entity new screen
ObjectName = 'PRCompanyAccountingSoftware';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'AccountingSoftware', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'OtherActgSoftware', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 20, ColPrefix + '_' + 'ARAgingImportFormatId', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// LICENSE START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'CompanyLicense';
var EntityCaption = 'License';
var EntityCaptionPlural = 'Licenses';
var ColPrefix = 'prli';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'Number';

// ------> CREATE SCREENS
// Search screen
ObjectName = EntityName + 'NewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

CreateScript = 'Hidden=true; ReadOnly = true;';
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'CompanyId', LN_New, 1, 2, RQ_Required, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'Number', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'Publish', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'Type', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');

// ------> CREATE LISTS
// Main entity list
ObjectName = EntityName + 'Grid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', NameField, '', OR_Allow, '', '', 'Custom', '', '', 'PRCompany/' + EntityName + '.asp', IdField, 0);
AddCustom_Lists(ObjectName, '2', ColPrefix + '_' + 'CompanyId', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '3', ColPrefix + '_' + 'Type', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '4', ColPrefix + '_' + 'Publish', '', OR_Allow, '', '', '', '', '', '', '', 0);

// ------> CREATE TABS
// Create the tab group
AddCustom_ScreenObjects(EntityName, 'TabGroup', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

// Create the tabs
AddCustom_Tabs('0', '0', '10', EntityName, 'Summary', 'customfile', + 'PRCompany/' + EntityName + '.asp', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');


////////////////////////////////////////////////////////////////////////
// *********************************************************************
// COMPANY PERSONNEL START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// Define the Search screen for the company personnel screen
ObjectName = 'CompanyPersonnelSearchBox';

AddCustom_ScreenObjects(ObjectName, 'SearchScreen', EntityName, 'N', 0, 'vPRPersonnelListing', '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 10, 'pers_FullName',  LN_New,  1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 12, 'peli_PRStatus',  LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 16, 'peli_PRRole',   LN_Same, 5, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 18, 'peli_PRRecipientRole',   LN_Same, 5, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 20, 'peli_PRTitleCode',   LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 22, 'peli_PRTitle',   LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 30, 'peli_WebStatus',   LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 32, 'peli_PROwnershipRole',   LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');




////////////////////////////////////////////////////////////////////////
// *********************************************************************
// COMPANY PROFILE START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
var ShortEntityName = 'CompanyProfile';
var EntityCaption = 'Profile';
var EntityCaptionPlural = 'Profiles';
var ColPrefix = 'prcp';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'CompanyId';

// The main profile screen
ObjectName = 'PRCompanyProfile';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'CorporateStructure', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'MigratedProfileDescription', LN_New, 1, 4, RQ_NotRequired, 0, '', '', 'ReadOnly=true;');

AddCustom_Screens(ObjectName, 11, ColPrefix + '_' + 'Volume', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 12, ColPrefix + '_' + 'FTEmployees', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 13, ColPrefix + '_' + 'PTEmployees', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

AddCustom_Screens(ObjectName, 21, ColPrefix + '_' + 'SrcBuyBrokersPct', LN_New, 1, 2, RQ_NotRequired, 0, '', '', ''); 
AddCustom_Screens(ObjectName, 22, ColPrefix + '_' + 'SrcBuyWholesalePct', LN_Same, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 23, ColPrefix + '_' + 'SrcBuyShippersPct', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 24, ColPrefix + '_' + 'SrcBuyExportersPct', LN_Same, 1, 2, RQ_NotRequired, 0, '', '', '');

AddCustom_Screens(ObjectName, 31, ColPrefix + '_' + 'SellBrokersPct', LN_New, 1, 2, RQ_NotRequired, 0, '', '',  '');
AddCustom_Screens(ObjectName, 32, ColPrefix + '_' + 'SellDomesticAccountTypes', LN_Same, 3, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 33, ColPrefix + '_' + 'SellWholesalePct', LN_New, 1, 2, RQ_NotRequired, 0, '', '',  '');
AddCustom_Screens(ObjectName, 34, ColPrefix + '_' + 'SellBuyOthers', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 36, ColPrefix + '_' + 'SellDomesticBuyersPct', LN_New, 1, 2, RQ_NotRequired, 0, '', '',  '');
AddCustom_Screens(ObjectName, 37, ColPrefix + '_' + 'SellExportersPct', LN_Same, 1, 2, RQ_NotRequired, 0, '', '',  '');

AddCustom_Screens(ObjectName, 51, ColPrefix + '_' + 'BkrTakeTitlePct', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 52, ColPrefix + '_' + 'BkrTakePossessionPct', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 53, ColPrefix + '_' + 'BkrCollectPct', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 54, ColPrefix + '_' + 'BkrTakeFrieght', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 55, ColPrefix + '_' + 'BkrConfirmation', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 56, ColPrefix + '_' + 'BkrReceive', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 57, ColPrefix + '_' + 'BkrGroundInspections', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

AddCustom_Screens(ObjectName, 71, ColPrefix + '_' + 'TrkrDirectHaulsPct', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 72, ColPrefix + '_' + 'TrkrTPHaulsPct', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
//AddCustom_Screens(ObjectName, 73, ColPrefix + '_' + 'TrkrDomesticRegion', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

AddCustom_Screens(ObjectName, 81, ColPrefix + '_' + 'TrkrProducePct', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 82, ColPrefix + '_' + 'TrkrOtherColdPct', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 83, ColPrefix + '_' + 'TrkrOtherWarmPct', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 84, ColPrefix + '_' + 'TrkrTeams', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

AddCustom_Screens(ObjectName, 91, ColPrefix + '_' + 'TrkrTrucksOwned', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 92, ColPrefix + '_' + 'TrkrTrucksLeased', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 93, ColPrefix + '_' + 'TrkrTrailersOwned', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 94, ColPrefix + '_' + 'TrkrTrailersLeased', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 95, ColPrefix + '_' + 'TrkrPowerUnits', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 96, ColPrefix + '_' + 'TrkrReefer', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 97, ColPrefix + '_' + 'TrkrDryVan', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 98, ColPrefix + '_' + 'TrkrFlatbed', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 99, ColPrefix + '_' + 'TrkrPiggyback', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 100, ColPrefix + '_' + 'TrkrTanker', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 101, ColPrefix + '_' + 'TrkrContainer', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 102, ColPrefix + '_' + 'TrkrOther', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

AddCustom_Screens(ObjectName, 121, ColPrefix + '_' + 'TrkrLiabilityAmount', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 122, ColPrefix + '_' + 'TrkrLiabilityCarrier', LN_Same, 1, 3, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 123, ColPrefix + '_' + 'TrkrCargoAmount', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 124, ColPrefix + '_' + 'TrkrCargoCarrier', LN_Same, 1, 3, RQ_NotRequired, 0, '', '', '');

AddCustom_Screens(ObjectName, 131, ColPrefix + '_' + 'StorageWarehouses', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 132, ColPrefix + '_' + 'ColdStorage', LN_Same, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 133, ColPrefix + '_' + 'StorageSF', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 134, ColPrefix + '_' + 'RipeningStorage', LN_Same, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 135, ColPrefix + '_' + 'StorageCF', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 136, ColPrefix + '_' + 'HumidityStorage', LN_Same, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 137, ColPrefix + '_' + 'StorageBushel', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 138, ColPrefix + '_' + 'AtmosphereStorage', LN_Same, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 139, ColPrefix + '_' + 'StorageCarlots', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 140, ColPrefix + '_' + 'ColdStorageLeased', LN_Same, 1, 2, RQ_NotRequired, 0, '', '', '');

AddCustom_Screens(ObjectName, 151, ColPrefix + '_' + 'HAACP', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 152, ColPrefix + '_' + 'HAACPCertifiedBy', LN_Same, 1, 3, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 153, ColPrefix + '_' + 'QTV', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 154, ColPrefix + '_' + 'QTVCertifiedBy', LN_Same, 1, 3, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 155, ColPrefix + '_' + 'Organic', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 156, ColPrefix + '_' + 'OrganicCertifiedBy', LN_Same, 1, 3, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 157, ColPrefix + '_' + 'OtherCertification', LN_New, 1, 4, RQ_NotRequired, 0, '', '', '');

// ------> CREATE SCREENS
// Entity Type screen
ObjectName = 'PRCompanyEntityType';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'CorporateStructure', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

// Company Size screen
ObjectName = 'PRCompanySize';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'Volume', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'FTEmployees', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'PTEmployees', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// Trucking Equipment
ObjectName = 'PRCompanyTruckingEquipment';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'TrkrTrucksOwned', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'TrkrTrucksLeased', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'TrkrTrailersOwned', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'TrkrTrailersLeased', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'TrkrPowerUnits', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 6, ColPrefix + '_' + 'TrkrReefer', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 7, ColPrefix + '_' + 'TrkrDryVan', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 8, ColPrefix + '_' + 'TrkrFlatbed', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 9, ColPrefix + '_' + 'TrkrPiggyback', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 10, ColPrefix + '_' + 'TrkrTanker', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 11, ColPrefix + '_' + 'TrkrContainer', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 12, ColPrefix + '_' + 'TrkrOther', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// Trucking Equipment
ObjectName = 'PRCompanyTruckingInsurance';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'TrkrLiabilityAmount', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'TrkrLiabilityCarrier', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'TrkrCargoAmount', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'TrkrCargoCarrier', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// Storage screen
ObjectName = 'PRCompanyStorage';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'StorageWarehouses', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'StorageSF', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'StorageCF', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'StorageBushel', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'StorageCarlots', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 6, ColPrefix + '_' + 'ColdStorage', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 7, ColPrefix + '_' + 'RipeningStorage', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 8, ColPrefix + '_' + 'HumidityStorage', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 9, ColPrefix + '_' + 'AtmosphereStorage', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// COMPANY RELATIONSHIP START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'CompanyRelationship';
var EntityCaption = 'Relationship';
var EntityCaptionPlural = 'Relationships';
var ColPrefix = 'prcr';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'TypeId';

AddCustom_Captions('Tags', 'ColNames', ColPrefix + '_' + 'UpdatedDate', 0, 'Last Updated', '', '', '', '', '', '');
AddCustom_Captions('Tags', 'ColNames', ColPrefix + '_' + 'CreatedDate', 0, 'Date First Entered', '', '', '', '', '', '');

AddCustom_Captions('Tags', 'ColNames', 'prcr_RelatedCompanyId', 0, 'Related Company Id', '', '', '', '', '', '');
AddCustom_Captions('Tags', 'ColNames', 'prcr_TypeDescription', 0, 'Relationship Type', '', '', '', '', '', '');
AddCustom_Captions('Tags', 'ColNames', 'CityStateCountry', 0, 'City, State, Country', '', '', '', '', '', '');

// ------> CREATE SCREENS

// Main entity new screen
ObjectName = EntityName + 'NewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

CreateScript = 'ReadOnly = true;';
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'LeftCompanyId', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'RightCompanyId', LN_Same, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'Type', LN_Same, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'Source', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'Active', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 6, ColPrefix + '_' + 'TransactionVolume', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 7, ColPrefix + '_' + 'TransactionFrequency', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 8, ColPrefix + '_' + 'CreatedDate', LN_New, 1, 1, RQ_Required, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 9, ColPrefix + '_' + 'LastReportedDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 20, ColPrefix + '_' + 'OwnershipPct', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 21, ColPrefix + '_' + 'OwnershipDescription', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// Main entity new screen
ObjectName = EntityName + 'FilterBox';

AddCustom_ScreenObjects(ObjectName, 'SearchScreen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 5, 'prcr_ReportingCompanyType', LN_New, 1, 5, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 10, 'prcr_RightCompanyId', LN_New, 1, 5, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 20, 'prcr_Type', LN_New, 1, 5, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 25, 'prcr_CategoryType', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 50, 'comp_prlistingstatus', LN_New, 1, 5, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 55, 'comp_prindustrytype', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 70, '_startdate', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 71, '_enddate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

ObjectName = EntityName + 'UnattributedOwner';

AddCustom_ScreenObjects(ObjectName, 'Screen', 'Company', 'N', 0, 'Company', '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, 'comp_PRUnattributedOwnerPct', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, 'comp_PRUnattributedOwnerDesc', LN_New, 4, 1, RQ_NotRequired, 0, '', '', '');

// ------> CREATE LISTS
// Main entity list
ObjectName = EntityName + 'Grid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, 'vPRCompanyRelationshipListing', '', '', '', '', '', '');
//AddCustom_Lists(ObjectName, '1', 'prcr_SubjectCompanyID', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '2', 'prcr_RelatedCompanyId', '', OR_Allow, '', '', 'Custom', '', '', 'PRCompany/PRCompanySummary.asp', 'comp_CompanyID', 0);
AddCustom_Lists(ObjectName, '3', 'prcr_RightCompanyId', '', OR_Allow, '', '', 'Custom', '', '', 'PRCompany/PRCompanySummary.asp', 'comp_CompanyID', 0);
AddCustom_Lists(ObjectName, '4', 'CityStateCountry', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '5', 'prcr_LastReportedDate', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '6', 'prcr_Active', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '7', 'prcr_TypeDescription', '', OR_Allow, '', '', 'Custom', '', '', 'PRCompany/PRCompanyRelationship.asp', IdField, 0);

ObjectName = EntityName + 'OwnershipByCompGrid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, 'vPROwnershipByCompany', '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', ColPrefix + '_' + 'RelatedBBID', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '2', ColPrefix + '_' + 'LeftCompanyId', '', OR_Allow, '', '', 'Custom', '', '', 'PRCompany/' + EntityName + '.asp', IdField, 0);
AddCustom_Lists(ObjectName, '3', 'prci_City', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '4', 'prst_Abbreviation', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '5', 'prcn_Country', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '6', ColPrefix + '_' + 'Type', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '7', ColPrefix + '_' + 'OwnershipPct', '', OR_Allow, '', '', '', '', '', '', '', 0);
//AddCustom_Lists(ObjectName, '8', ColPrefix + '_' + 'OwnershipPctHigh', '', OR_Allow, '', '', '', '', '', '', '', 0);

ObjectName = EntityName + 'OwnershipByPersGrid';

AddCustom_ScreenObjects(ObjectName, 'List', 'Person', 'N', 0, 'vPROwnershipByPerson', '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', 'pers_PersonId', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '2', 'pers_FirstName', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '3', 'pers_LastName', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '4', 'peli_PRTitle', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '5', 'peli_PRPctOwned', '', OR_Allow, '', '', '', '', '', '', '', 0);


// ------> CREATE TABS
// Create the tab group
AddCustom_ScreenObjects(EntityName, 'TabGroup', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

// Create the tabs
AddCustom_Tabs('0', '0', '10', EntityName, 'Summary', 'customfile', EntityName + '/' + EntityName + 'Summary.asp', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');


////////////////////////////////////////////////////////////////////////
// *********************************************************************
// COMPANY TERMINAL MARKET START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'CompanyTerminalMarket';
var EntityCaption = 'Terminal Market';
var EntityCaptionPlural = 'Terminal Markets';
var ColPrefix = 'prct';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'TerminalMarketId';

// ------> CREATE SCREENS
// Main entity new screen
ObjectName = 'PRCompanyTerminalMarketNewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

CreateScript = 'ReadOnly = true;';
AddCustom_Screens(ObjectName, 1, 'prct_CompanyId', LN_New, 1, 1, RQ_Required, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 2, 'prct_TerminalMarketId', LN_Same, 1, 1, RQ_Required, 0, '', '', '');

// ------> CREATE LISTS
// Summary list
ObjectName = 'PRCompanyTerminalMarketGrid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, 'vPRCompanyTerminalMarket', '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', 'prtm_FullMarketName', '', OR_Allow, '', '', 'Custom', '', '', 'PRCompany/PRCompanyTerminalMarket.asp', IdField, 0);
AddCustom_Lists(ObjectName, '2', 'prtm_City', '', OR_Allow, '', '', '', '', '', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

