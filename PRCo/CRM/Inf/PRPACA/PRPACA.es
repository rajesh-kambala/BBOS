// Client Prefix
var ClientId = 'PR';

// New line values
var LN_New = 1;
var LN_Same = 0;

// Required field values
var RQ_Required = 'Y';
var RQ_NotRequired = 'N';

// Order values
var OR_Allow = 'Y';
var OR_NotAllowed = 'N';

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
// IMPORT PACA LICENSE START
// *********************************************************************
////////////////////////////////////////////////////////////////////////

AddCustom_Tabs('0', '0', '120', 'Find', 'Pending PACA License', 'customfile', 'PRPACALicense/PRImportPACALicenseFind.asp', '', 'PRImportPACALicense.gif', 0);


// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'ImportPACALicense';
var EntityCaption = 'PACA License';
var EntityCaptionPlural = 'PACA Licenses';
var ColPrefix = 'pril';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'LicenseNumber';

// ------> CREATE SCREENS
// Main entity search screen
ObjectName = 'PRImportPACALicenseSearchBox';

AddCustom_ScreenObjects(ObjectName, 'SearchScreen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, NameField, LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'CompanyName', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'TypeFruitVeg', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'PACARunDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'ImportDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// Main entity new screen
ObjectName = 'PRImportPACALicenseNewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'LicenseNumber', LN_New, 1, 1, RQ_Required, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'CompanyName', LN_Same, 1, 4, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'Address1', LN_New, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 6, ColPrefix + '_' + 'Address2', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 7, ColPrefix + '_' + 'City', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 8, ColPrefix + '_' + 'State', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 9, ColPrefix + '_' + 'PostCode', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 10, ColPrefix + '_' + 'MailAddress1', LN_New, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 11, ColPrefix + '_' + 'MailAddress2', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 12, ColPrefix + '_' + 'MailCity', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 13, ColPrefix + '_' + 'MailState', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 14, ColPrefix + '_' + 'MailPostCode', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 15, ColPrefix + '_' + 'Telephone', LN_New, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 16, ColPrefix + '_' + 'TypeFruitVeg', LN_Same, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 17, ColPrefix + '_' + 'ProfCode', LN_Same, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 18, ColPrefix + '_' + 'OwnCode', LN_Same, 1, 2, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 19, ColPrefix + '_' + 'PACARunDate', LN_New, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 20, ColPrefix + '_' + 'ExpirationDate', LN_Same, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 21, ColPrefix + '_' + 'FileName', LN_Same, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 22, ColPrefix + '_' + 'ImportDate', LN_Same, 1, 2, RQ_Required, 0, '', '', '');

// ------> CREATE LISTS
// Main entity list
ObjectName = 'PRImportPACALicenseGrid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', NameField, '', OR_Allow, '', '', 'Custom', '', '', 'PRPACALicense/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, 2, ColPrefix + '_' + 'CompanyName', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, 3, ColPrefix + '_' + 'ImportDate', '', OR_Allow, '', '', '', '', '', '', '', 0);

// ------> CREATE TABS
// Create the tab group
AddCustom_ScreenObjects(EntityName, 'TabGroup', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

// Create the tabs
AddCustom_Tabs('0', '0', '10', EntityName, 'Summary', 'customfile', 'PRPACALicense/' + EntityName + 'Summary.asp', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

// ------> CREATE SELECTION LISTS
////////////////////////////////////////////////////////////////////////
// *********************************************************************
// PACA LICENSE START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'PACALicense';
var EntityCaption = 'PACA License';
var EntityCaptionPlural = 'PACA Licenses';
var ColPrefix = 'prpa';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'LicenseNumber';

// ------> CREATE SCREENS
// Main entity search screen
ObjectName = 'PRPACALicenseSearchBox';

AddCustom_ScreenObjects(ObjectName, 'SearchScreen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, NameField, LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'CompanyId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
//AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'EffectiveDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'Current', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'Address1', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 6, ColPrefix + '_' + 'Address2', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 7, ColPrefix + '_' + 'City', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 8, ColPrefix + '_' + 'State', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
//AddCustom_Screens(ObjectName, 9, ColPrefix + '_' + 'Country', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 10, ColPrefix + '_' + 'PostCode', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 11, ColPrefix + '_' + 'TypeFruitVeg', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 12, ColPrefix + '_' + 'ProfCode', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// Search screen for Import PACA License assignment
ObjectName = 'PRPACALicenseAssignSearchBox';

AddCustom_ScreenObjects(ObjectName, 'SearchScreen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'CompanyId', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, NameField, LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'Current', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'Address1', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 6, ColPrefix + '_' + 'Address2', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 7, ColPrefix + '_' + 'City', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 8, ColPrefix + '_' + 'State', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
//AddCustom_Screens(ObjectName, 9, ColPrefix + '_' + 'Country', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 10, ColPrefix + '_' + 'PostCode', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'ProfCode', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
//AddCustom_Screens(ObjectName, 11, ColPrefix + '_' + 'EffectiveDate', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
//AddCustom_Screens(ObjectName, 12, ColPrefix + '_' + 'LicenseStatus', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');


// Assignment of an existing BBId 
ObjectName = 'PRPACALicenseAssignBBId';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'CompanyId', LN_New, 1, 1, RQ_Required, 0, '', '', '');


// Assignment of an PACA License Id 
ObjectName = 'PRPACALicenseAssign';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, 'prpa_PACALicenseId', LN_New, 1, 1, RQ_Required, 0, '', '', '');

// Main entity new screen
ObjectName = 'PRPACALicenseSummary';


CreateScript = 'ReadOnly = true;';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'CompanyId', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'LicenseNumber', LN_New, 1, 2, RQ_Required, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'CompanyName', LN_Same, 1, 4, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'Address1', LN_New, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 6, ColPrefix + '_' + 'Address2', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 7, ColPrefix + '_' + 'City', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 8, ColPrefix + '_' + 'State', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 9, ColPrefix + '_' + 'PostCode', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 10, ColPrefix + '_' + 'MailAddress1', LN_New, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 11, ColPrefix + '_' + 'MailAddress2', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 12, ColPrefix + '_' + 'MailCity', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 13, ColPrefix + '_' + 'MailState', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 14, ColPrefix + '_' + 'MailPostCode', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 15, ColPrefix + '_' + 'Telephone', LN_New, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 16, ColPrefix + '_' + 'TypeFruitVeg', LN_Same, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 17, ColPrefix + '_' + 'ProfCode', LN_Same, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 18, ColPrefix + '_' + 'OwnCode', LN_Same, 1, 2, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 60, ColPrefix + '_' + 'Current', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 61, ColPrefix + '_' + 'Publish', LN_Same, 1, 1, RQ_Required, 0, '', '', '');

// ------> CREATE LISTS
// Main entity list
ObjectName = 'PRPACALicenseGrid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', ColPrefix + '_' + 'Current', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '2', NameField, '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '3', ColPrefix + '_' + 'EffectiveDate', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '4', ColPrefix + '_' + 'ExpirationDate', '', OR_Allow, '', '', '', '', '', '', '', 0);

AddCustom_Lists(ObjectName, '5', ColPrefix + '_' + 'CompanyId', '', OR_Allow, '', '', '', '', '', '', '', 0);
//AddCustom_Lists(ObjectName, '6', ColPrefix + '_' + 'EffectiveDate', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '7', ColPrefix + '_' + 'TypeFruitVeg', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '8', ColPrefix + '_' + 'ProfCode', '', OR_Allow, '', '', '', '', '', '', '', 0);

// List for PACA Records for Imported PACA to be assigned
ObjectName = 'PRPACALicenseAssignGrid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', NameField, '', OR_Allow, '', '', 'Custom', '', '', 'PRPACALicense/PRPACALicenseAssignConfirm.asp', IdField, 0);
AddCustom_Lists(ObjectName, '2', ColPrefix + '_' + 'CompanyId', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '3', ColPrefix + '_' + 'CompanyName', '', OR_Allow, '', '', '', '', '', '', '', 0);

// Company list
ObjectName = 'PRCompanyPACALicenseGrid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', NameField, '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '2', ColPrefix + '_' + 'ExpirationDate', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '3', ColPrefix + '_' + 'TypeFruitVeg', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '4', ColPrefix + '_' + 'Telephone', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);

// ------> CREATE TABS
// Create the tab group
AddCustom_ScreenObjects(EntityName, 'TabGroup', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

// Create the tabs
AddCustom_Tabs('0', '0', '10', EntityName, 'Summary', 'customfile', EntityName + '/' + EntityName + 'Summary.asp', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// IMPORT PACA PRINCIPAL START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'ImportPACAPrincipal';
var EntityCaption = 'PACA Principal';
var EntityCaptionPlural = 'PACA Principals';
var ColPrefix = 'prip';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'LicenseNumber';

// ------> CREATE SCREENS

// Main entity new screen
ObjectName = 'PRImportPACAPrincipalNewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

CreateScript = 'ReadOnly = true;';
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'PACALicenseId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'Sequence', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'LastName', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'FirstName', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'MiddleInitial', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 6, ColPrefix + '_' + 'Title', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 7, ColPrefix + '_' + 'City', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 8, ColPrefix + '_' + 'State', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 9, ColPrefix + '_' + 'LicenseNumber', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// ------> CREATE LISTS
// Main entity list
ObjectName = 'PRImportPACAPrincipalGrid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, 1, ColPrefix + '_' + 'LastName', '', OR_NotAllowed, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, 2, ColPrefix + '_' + 'FirstName', '', OR_NotAllowed, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, 3, ColPrefix + '_' + 'City', '', OR_NotAllowed, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, 4, ColPrefix + '_' + 'State', '', OR_NotAllowed, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, 5, ColPrefix + '_' + 'Title', '', OR_NotAllowed, '', '', '', '', '', '', '', 0);

// ------> CREATE TABS
// Create the tab group
AddCustom_ScreenObjects(EntityName, 'TabGroup', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

// Create the tabs
AddCustom_Tabs('0', '0', '10', EntityName, 'Summary', 'customfile', EntityName + '/' + EntityName + 'Summary.asp', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// PACA PRINCIPAL START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'PACAPrincipal';
var EntityCaption = 'PACA Principal';
var EntityCaptionPlural = 'PACA Principals';
var ColPrefix = 'prpp';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'Name';

// ------> CREATE SCREENS
// Main entity new screen
ObjectName = 'PRPACAPrincipalNewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

CreateScript = 'ReadOnly = true;';
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'PACALicenseId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'Sequence', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'LastName', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'FirstName', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'MiddleInitial', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 6, ColPrefix + '_' + 'Title', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 7, ColPrefix + '_' + 'City', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 8, ColPrefix + '_' + 'State', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 9, ColPrefix + '_' + 'License', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// ------> CREATE LISTS
// Main entity list
ObjectName = 'PRPACAPrincipalGrid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, 1, ColPrefix + '_' + 'LastName', '', OR_NotAllowed, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, 2, ColPrefix + '_' + 'FirstName', '', OR_NotAllowed, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, 3, ColPrefix + '_' + 'City', '', OR_NotAllowed, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, 4, ColPrefix + '_' + 'State', '', OR_NotAllowed, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, 5, ColPrefix + '_' + 'Title', '', OR_NotAllowed, '', '', '', '', '', '', '', 0);
//AddCustom_Lists(ObjectName, '1', ColPrefix + '_' + 'Sequence', '', OR_NotAllowed, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);

// ------> CREATE TABS
// Create the tab group
AddCustom_ScreenObjects(EntityName, 'TabGroup', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

// Create the tabs
AddCustom_Tabs('0', '0', '10', EntityName, 'Summary', 'customfile', EntityName + '/' + EntityName + 'Summary.asp', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// IMPORT PACA TRADE START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'ImportPACATrade';
var EntityCaption = 'Other Trade Name';
var EntityCaptionPlural = 'Other Trade Names';
var ColPrefix = 'prit';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'LicenseNumber';

// ------> CREATE LISTS
// Main entity list
ObjectName = 'PRImportPACATradeGrid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, 1, ColPrefix + '_' + 'AdditionalTradeName', '', OR_NotAllowed, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, 3, ColPrefix + '_' + 'City', '', OR_NotAllowed, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, 4, ColPrefix + '_' + 'State', '', OR_NotAllowed, '', '', '', '', '', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// PACA TRADE START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'PACATrade';
var EntityCaption = 'Additional Trade Name';
var EntityCaptionPlural = 'Additional Trade Names';
var ColPrefix = 'ptrd';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'Name';

ObjectName = 'PRPACATradeGrid';
AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, 1, ColPrefix + '_' + 'AdditionalTradeName', '', OR_NotAllowed, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, 2, ColPrefix + '_' + 'City', '', OR_NotAllowed, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, 3, ColPrefix + '_' + 'State', '', OR_NotAllowed, '', '', '', '', '', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');
