// This file builds the tables for the PRCo CRM system

// Client Prefix
var ClientId = 'PR';

// Null value options
var NL_Allow = 'true';
var NL_Deny = 'false';

// Unique value options
var UQ_True = 'true';
var UQ_False = 'false';

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


function HideTab(sEntityName, sTabName) {
   // Hide the tab by setting the Deleted flag to 1 (true)
   AddCustom_Data('Custom_Tabs','Tabs','Tabs_TabId','Tabs_Entity, Tabs_Caption, Tabs_Deleted', sEntityName + ', ' + sTabName + ', 1','1, 2');

   return true;
}

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
// AR AGING START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'ARAging';
var EntityCaption = 'A/R Aging';
var EntityCaptionPlural = 'A/R Aging';
var ColPrefix = 'praa';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'Date';


// Create a filter for the AR Aging screens; this is also used on the TES listing screen
// in conjunction with the CompanyTradeActivityFilterInclude.asp
ObjectName = 'TradeActivityFilterBox';
AddCustom_ScreenObjects(ObjectName, 'SearchScreen', EntityName, 'N', 0, 'vPRTradeReportFilter', '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, 'prtr_ResponderID', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, '_StartDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, '_EndDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, '_Exception', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');



// ------> CREATE SCREENS
// Main entity new screen
ObjectName = EntityName + 'NewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

CreateScript = 'ReadOnly = true;';
AddCustom_Screens(ObjectName, 1, 'praa_CompanyId', LN_New, 1, 1, RQ_Required, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 2, 'praa_PersonId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, 'praa_Date', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, 'praa_RunDate', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, 'praa_DateSelectionCriteria', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 6, 'praa_ARAgingImportFormatID', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// Main entity new screen
ObjectName = 'PRARAgingTotal';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'Amount0to29', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'Amount30to44', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'Amount45to60', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'Amount61Plus', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'TotalAmount', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 6, ColPrefix + '_' + 'Amount0to29Pct', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 7, ColPrefix + '_' + 'Amount30to44Pct', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 8, ColPrefix + '_' + 'Amount45to60Pct', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 9, ColPrefix + '_' + 'Amount61PlusPct', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 10, ColPrefix + '_' + 'TotalAmountPct', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');


// Grid for displaying ARAging ON records; these are primarily ARAGing Detail records
ObjectName = 'PRARAgingOnGrid';
// set up the column headers
AddCustom_Captions('Tags', 'ColNames', 'praad_ReportingCompanyId', 0, 'Company ID', '', '', '', '', '', '');
AddCustom_Captions('Tags', 'ColNames', 'praad_ReportingCompanyName', 0, 'Company Name', '', '', '', '', '', '');
AddCustom_Captions('Tags', 'ColNames', 'Level1ClassificationValues', 0, 'Classifications', '', '', '', '', '', '');
AddCustom_Captions('Tags', 'ColNames', 'praad_TotalAmount', 0, 'Total Amount', '', '', '', '', '', '');
AddCustom_Captions('Tags', 'ColNames', 'praad_Amount0to29Percent', 0, '0-29 (%)', '', '', '', '', '', '');
AddCustom_Captions('Tags', 'ColNames', 'praad_Amount30to44Percent', 0, '30-44 (%)', '', '', '', '', '', '');
AddCustom_Captions('Tags', 'ColNames', 'praad_Amount45to60Percent', 0, '45-60 (%)', '', '', '', '', '', '');
AddCustom_Captions('Tags', 'ColNames', 'praad_Amount61PlusPercent', 0, '61+ (%)', '', '', '', '', '', '');
// set up the grid format
AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, 'vPRARAgingDetailOn', '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', 'praa_Date', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '2', 'praad_ReportingCompanyId', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '3', 'praad_ReportingCompanyName', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '4', 'Level1ClassificationValues', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '5', 'praad_TotalAmount', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '6', 'praad_Amount0to29', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '6', 'praad_Amount0to29Percent', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '7', 'praad_Amount30to44', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '7', 'praad_Amount30to44Percent', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '8', 'praad_Amount45to60', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '8', 'praad_Amount45to60Percent', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '9', 'praad_Amount61Plus', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '9', 'praad_Amount61PlusPercent', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '11', 'praad_Exception', '', OR_Allow, '', '', '', '', '', '', '', 0);

ObjectName = 'PRARAgingDetailByGrid';
AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, 'vPRARAgingDetailBy', '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', 'praa_Date', '', OR_Allow, '', '', '', '', '', '', '', 0);
//AddCustom_Lists(ObjectName, '2', 'prar_PRCoCompanyId', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '3', 'praad_CompanyName', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '4', 'Level1ClassificationValues', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '5', 'praad_LineTotal', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '5', 'praad_LinePercent', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '6', 'praad_Amount0to29', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '6', 'praad_Amount0to29Percent', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '7', 'praad_Amount30to44', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '7', 'praad_Amount30to44Percent', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '8', 'praad_Amount45to60', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '8', 'praad_Amount45to60Percent', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '9', 'praad_Amount61Plus', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '9', 'praad_Amount61PlusPercent', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '11', 'praad_Exception', '', OR_Allow, '', '', '', '', '', '', '', 0);


// General grid for displaying ARAging Detail records
ObjectName = 'PRARAgingDetailGrid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, 'vPRARAgingDetail', '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', 'praa_Date', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '2', 'praad_CompanyName', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '3', 'praad_State', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '4', 'Level1ClassificationValues', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '5', 'praad_TotalAmount', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '6', 'praad_Amount0to29', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '7', 'praad_Amount30to44', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '8', 'praad_Amount45to60', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '9', 'praad_Amount61Plus', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '11', 'praad_Exception', '', OR_Allow, '', '', '', '', '', '', '', 0);

// Main entity list
ObjectName = 'PRARAgingGrid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', ColPrefix + '_' + 'Date', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '2', ColPrefix + '_' + 'CompanyId', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '3', ColPrefix + '_' + 'State', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '4', ColPrefix + '_' + 'BusinessType', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '5', ColPrefix + '_' + 'Amount0to29', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '6', ColPrefix + '_' + 'Amount30to44', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '7', ColPrefix + '_' + 'Amount45to60', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '8', ColPrefix + '_' + 'Amount61Plus', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '9', ColPrefix + '_' + 'TotalAmount', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '10', ColPrefix + '_' + 'Exception', '', OR_Allow, '', '', '', '', '', '', '', 0);

// ------> CREATE TABS
// Create the tab group
AddCustom_ScreenObjects(EntityName, 'TabGroup', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

// Create the tabs
AddCustom_Tabs('0', '0', '10', EntityName, 'Summary', 'customfile', EntityName + '/' + EntityName + 'Summary.asp', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// AR AGING DETAIL START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'ARAgingDetail';
var EntityCaption = 'A/R Aging Detail';
var EntityCaptionPlural = 'A/R Aging Detail';
var ColPrefix = 'praad';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'ARTranslationId';

// ------> CREATE SCREENS
// Main entity new screen
ObjectName = EntityName + 'NewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

CreateScript = "ReadOnly = true;";
//AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'ARAgingId', LN_New, 1, 1, RQ_Required, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'ManualCompanyId', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'Amount0to29', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'Amount30to44', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'Amount45to60', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 6, ColPrefix + '_' + 'Amount61Plus', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// ------> DEFINE CAPTIONS
// Main entity search results
AddCustom_Captions('Tags', EntityName, 'NoRecordsFound', 0, 'No ' + EntityCaptionPlural, '', '', '', '', '', '');
AddCustom_Captions('Tags', EntityName, 'RecordsFound', 0, EntityCaptionPlural, '', '', '', '', '', '');
AddCustom_Captions('Tags', EntityName, 'RecordFound', 0, EntityCaption, '', '', '', '', '', '');

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// AR TRANSLATION START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'ARTranslation';
var EntityCaption = 'A/R Translation';
var EntityCaptionPlural = 'A/R Translation';
var ColPrefix = 'prar';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'CustomerNumber';

// ------> CREATE SCREENS
// Main entity new screen
ObjectName = EntityName + 'NewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

CreateScript = 'ReadOnly = true;';
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'CompanyId', LN_New, 1, 1, RQ_Required, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'CustomerNumber', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'PRCoCompanyId', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// ------> CREATE LISTS
// Main entity list
ObjectName = EntityName + 'Grid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', ColPrefix + '_' + 'CustomerNumber', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '2', ColPrefix + '_' + 'PRCoCompanyId', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);

// ------> DEFINE CAPTIONS
// Main entity search results
AddCustom_Captions('Tags', EntityName, 'NoRecordsFound', 0, 'No ' + EntityCaptionPlural, '', '', '', '', '', '');
AddCustom_Captions('Tags', EntityName, 'RecordsFound', 0, EntityCaptionPlural, '', '', '', '', '', '');
AddCustom_Captions('Tags', EntityName, 'RecordFound', 0, EntityCaption, '', '', '', '', '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// TES START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'TES';
var EntityCaption = 'TES';
var EntityCaptionPlural = 'TES';
var ColPrefix = 'prte';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'Date';

// ------> CREATE SCREENS
// Main entity new screen
ObjectName = 'PRTESNewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

CreateScript = 'ReadOnly = true;';
//AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'SerialNumber', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'Date', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'HowSent', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'ResponseDate', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
//AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'HowReceived', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// ------> CREATE LISTS
// List of Companies to receive Custom TES request
ObjectName = 'TESCustomRequestGrid';
AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '2', 'prte_ResponderCompanyId', '', OR_Allow, '', '', 'Company Id', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '3', 'company_name', '', OR_Allow, '', '', 'Company Name', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '4', 'FaxNumber', '', OR_Allow, '', '', 'Fax Number', '', '', '', '', 0);

// Grid to display the TES Forms (Sent To) listing
ObjectName = 'PRTESToGrid';
AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', 'prte_Date', '', OR_Allow, '', '', 'Custom', '', '', 'PRCompany/PRCompanyTES.asp', IdField, 0);
AddCustom_Lists(ObjectName, '2', 'prte_ResponseDate', '', OR_Allow, '', '', '', '', '', '', '', 0);

// Create a filter for use on the Hand-Picked Custom TES screen (Custom Option 5)
// The entity name value will not matter; we just use this screen to capture the 
// criteria then we pass the values to the database call
ObjectName = 'CustomTESOption5FilterBox';
AddCustom_ScreenObjects(ObjectName, 'SearchScreen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, '_StartDate', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, '_EndDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, 'prcr_Type', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, 'comp_PRListingStatus', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// ------> CREATE TABS
// Create the tab group
AddCustom_ScreenObjects(EntityName, 'TabGroup', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

// Create the tabs
AddCustom_Tabs('0', '0', '10', EntityName, 'Summary', 'customfile', EntityName + '/' + EntityName + 'Summary.asp', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// TES DETAIL START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'TESDetail';
var EntityCaption = 'TES Detail';
var EntityCaptionPlural = 'TES Details';
var ColPrefix = 'prt2';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'CompanyId';

// ------> CREATE SCREENS
// This screen has only one field for the entry of the Subject Company of the TES
ObjectName = 'PRTESDetailNewEntry';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 2, 'prt2_SubjectCompanyId', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// ------> CREATE LISTS
// Main entity list
ObjectName = 'PRTESDetailGrid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', 'prt2_SubjectCompanyId', '', OR_Allow, '', '', 'Custom', '', '', 'PRCompany/PRCompanyTESDetail.asp', IdField, 0);

// Main entity list
ObjectName = 'PRTESAboutGrid';
AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, 'vPRTES', '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', 'prte_Date', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '2', 'prte_ResponderCompanyId', '', OR_Allow, '', '', 'Company', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '3', 'prte_ResponseDate', '', OR_Allow, '', '', '', '', '', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// TRADE REPORT START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'TradeReport';
var EntityCaption = 'Trade Report';
var EntityCaptionPlural = 'Trade Reports';
var ColPrefix = 'prtr';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'SubjectId';

// ------> CREATE SCREENS
// Main entity new screen
ObjectName = 'PRTradeReportNewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

CreateScript = 'ReadOnly = true;';
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'SubjectId', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'ResponderId', LN_Same, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'Date', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'NoTrade', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'OutOfBusiness', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

AddCustom_Screens(ObjectName, 6, ColPrefix + '_' + 'LastDealtDate', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 7, ColPrefix + '_' + 'RelationshipLength', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 8, ColPrefix + '_' + 'Regularity', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 9, ColPrefix + '_' + 'Seasonal', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

AddCustom_Screens(ObjectName, 10, ColPrefix + '_' + 'RelationshipType', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 11, ColPrefix + '_' + 'Terms', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

AddCustom_Screens(ObjectName, 12, ColPrefix + '_' + 'ProductKickers', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 13, ColPrefix + '_' + 'CollectRemit', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 14, ColPrefix + '_' + 'PromptHandling', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 15, ColPrefix + '_' + 'ProperEquipment', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

AddCustom_Screens(ObjectName, 16, ColPrefix + '_' + 'Pack', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 17, ColPrefix + '_' + 'DoubtfulAccounts', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 18, ColPrefix + '_' + 'PayFreight', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 19, ColPrefix + '_' + 'TimelyArrivals', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

//AddCustom_Screens(ObjectName, 21, ColPrefix + '_' + 'IntegrityNumber', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
//AddCustom_Screens(ObjectName, 22, ColPrefix + '_' + 'PayDescriptionNumber', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 23, ColPrefix + '_' + 'HighCredit', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 24, ColPrefix + '_' + 'CreditTerms', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

AddCustom_Screens(ObjectName, 25, ColPrefix + '_' + 'AmountPastDue', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 26, ColPrefix + '_' + 'InvoiceOnDayShipped', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 27, ColPrefix + '_' + 'DisputeInvolved', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

AddCustom_Screens(ObjectName, 28, ColPrefix + '_' + 'PaymentTrend', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 29, ColPrefix + '_' + 'LoadsPerYear', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

AddCustom_Screens(ObjectName, 30, ColPrefix + '_' + 'Comments', LN_New, 1, 4, RQ_NotRequired, 0, '', '', '');

// Filter Box on Listing Page
ObjectName = EntityName + 'SearchBox';
DeleteCustom_ScreenObject(ObjectName,'',1);
AddCustom_ScreenObjects(ObjectName, 'SearchScreen', EntityName, 'N', 0, 'vPRTradeReportFilter', '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'StartDate', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'EndDate', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, '_ExceptionSelect', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, '_DisputeInvolvedSelect', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
//AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'Exception', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');


// ------> CREATE LISTS
AddCustom_Captions('Tags', 'ColNames', 'prtr_Level1ClassificationValues', 0, 'Classifications', '', '', '', '', '', '');

// Trade Report ON Listing
ObjectName = 'PRTradeReportOnGrid';
AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, 'vPRTradeReportOn', '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', ColPrefix + '_' + 'Date', '', OR_Allow, '', '', 'Custom', '', '', 'PRCompany/PRCompanyTradeReport.asp', IdField, 0);
AddCustom_Lists(ObjectName, '2', ColPrefix + '_' + 'ResponderId', '', OR_Allow, '', '', 'Custom', '', '', 'PRCompany/PRCompanyTradeReport.asp', IdField, 0);
AddCustom_Lists(ObjectName, '4', 'prtr_Level1ClassificationValues', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '5', 'prin_TradeReportDescription', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '6', 'prpy_TradeReportDescription', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '7', ColPrefix + '_' + 'CreditTerms', '', OR_Allow, '', '', '', '', '', '', '', 0);
//AddCustom_Lists(ObjectName, '8', ColPrefix + '_' + 'Terms', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '9', ColPrefix + '_' + 'HighCredit', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '10', ColPrefix + '_' + 'Exception', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '11', ColPrefix + '_' + 'DisputeInvolved', '', OR_Allow, '', '', '', '', '', '', '', 0);

// Trade Report BY Listing
ObjectName = 'PRTradeReportByGrid';
AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, 'vPRTradeReportBy', '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', ColPrefix + '_' + 'Date', '', OR_Allow, '', '', 'Custom', '', '', 'PRCompany/PRCompanyTradeReport.asp', IdField, 0);
AddCustom_Lists(ObjectName, '2', ColPrefix + '_' + 'SubjectId', '', OR_Allow, '', '', 'Custom', '', '', 'PRCompany/PRCompanyTradeReport.asp', IdField, 0);
AddCustom_Lists(ObjectName, '4', 'prtr_Level1ClassificationValues', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '5', 'prin_TradeReportDescription', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '6', 'prpy_TradeReportDescription', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '7', ColPrefix + '_' + 'CreditTerms', '', OR_Allow, '', '', '', '', '', '', '', 0);
//AddCustom_Lists(ObjectName, '8', ColPrefix + '_' + 'Terms', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '9', ColPrefix + '_' + 'HighCredit', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '10', ColPrefix + '_' + 'Exception', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '11', ColPrefix + '_' + 'DisputeInvolved', '', OR_Allow, '', '', '', '', '', '', '', 0);

// ------> CREATE TABS
// Create the tab group
AddCustom_ScreenObjects(EntityName, 'TabGroup', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

// Create the tabs
AddCustom_Tabs('0', '0', '10', EntityName, 'Summary', 'customfile', EntityName + '/' + EntityName + 'Summary.asp', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');


////////////////////////////////////////////////////////////////////////
// *********************************************************************
// AR AGING IMPORT FORMAT START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'ARAgingImportFormat';
var EntityCaption = 'A/R Aging Import Format';
var EntityCaptionPlural = 'A/R Aging Import Formats';
var ColPrefix = 'praaif';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'Name';

// A/R Aging Import Format Listing
ObjectName = 'PRARAgingImportFormatGrid';
AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', 'praaif_Name', '', OR_Allow, '', '', 'Custom', '', '', 'PRGeneral/PRARAgingImportFormat.asp', IdField, 0);

// Add this guy to the search dropdown
AddCustom_Tabs('0', '0', '150', 'Find', 'A/R Aging Import Formats', 'customfile', 'PRGeneral/PRARAgingImportFormatListing.asp', '', 'PRARAgingImportFormat.gif', 0);

// Main entity new screen
ObjectName = 'PRARAgingImportNewEntryHeader';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

CreateScript = 'Hidden=true; ReadOnly = true;';
AddCustom_Screens(ObjectName, 1,  'praaif_ARAgingImportFormatID', LN_New, 1, 1, RQ_Required, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 10, 'praaif_Name', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 11, 'praaif_FileFormat', LN_Same, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 12, 'praaif_DateFormat', LN_Same, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 20, 'praaif_NumberHeaderLines', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 21, 'praaif_DelimiterChar', LN_Same, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 22, 'praaif_DefaultDateSelectionCriteria', LN_Same, 1, 1, RQ_Required, 0, '', '', '');

AddCustom_Screens(ObjectName, 40, 'praaif_DateSelectionCriteriaColIndex', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 41, 'praaif_DateSelectionCriteriaRowIndex', LN_Same, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 50, 'praaif_RunDateColIndex', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 51, 'praaif_RunDateRowIndex', LN_Same, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 31, 'praaif_AsOfDateColIndex', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 32, 'praaif_AsOfDateRowIndex', LN_Same, 1, 1, RQ_Required, 0, '', '', '');



// Main entity new screen
ObjectName = 'PRARAgingImportNewEntry';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

CreateScript = 'Hidden=true; ReadOnly = true;';
AddCustom_Screens(ObjectName, 33, 'praaif_CompanyIDColIndex', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 40, 'praaif_CompanyNameColIndex', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 41, 'praaif_CityNameColIndex', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 42, 'praaif_StateNameColIndex', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 43, 'praaif_ZipCodeColIndex', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 50, 'praaif_Amount0to29ColIndex', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 51, 'praaif_Amount30to44ColIndex', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 52, 'praaif_Amount45to60ColIndex', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 53, 'praaif_Amount61PlusColIndex', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 60, 'praaif_CreditTermsColIndex', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 61, 'praaif_TimeAgedColIndex', LN_New, 1, 1, RQ_Required, 0, '', '', '');



// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');
