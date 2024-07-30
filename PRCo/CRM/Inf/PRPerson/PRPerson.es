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
// PERSON START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var EntityName = 'Person';
var ColPrefix = 'pers';

// ------> HIDE TABS
// Hide some of the Person tabs
sEntityName = 'Person';

// Moved hiding tabs to database scripting
// HideTab(sEntityName, 'QuickLook');
// HideTab(sEntityName, 'Marketing');
// HideTab(sEntityName, 'SelfService');
   
// ------> CHANGE TABS
AddCustom_Data('Custom_Tabs','Tabs','Tabs_TabId','Tabs_Entity, Tabs_Caption, Tabs_Action, Tabs_CustomFileName', 'Person, Summary, customfile, PRPerson/PRPersonSummary.asp','1, 2');

// Modify existing fields
AddCustom_Captions('Tags', 'ColNames', 'pers_PersonId', 0, 'Person Id', '', '', '', '', '', '');

// ------> CREATE TABS
// Add tab to Person section
//AddCustom_Tabs('0', '0', '20', 'Person', 'Phones', 'customfile', 'PRPerson/PRPersonPhone.asp', '', '', 0);
AddCustom_Tabs('0', '0', '02', 'Person', 'Contact Info', 'customfile', 'PRPerson/PRPersonContactInfoListing.asp', '', '', 0);
AddCustom_Tabs('0', '0', '05', 'Person', 'Events', 'customfile', 'PRPerson/PRPersonEventListing.asp', '', '', 0);
AddCustom_Tabs('0', '0', '10', 'Person', 'Relationships', 'customfile', 'PRPerson/PRPersonRelationshipListing.asp', '', '', 0);
AddCustom_Tabs('0', '0', '15', 'Person', 'AUS List', 'customfile', 'PRPerson/PRPersonAUSListing.asp', '', '', 0);
AddCustom_Tabs('0', '0', '20', 'Person', 'Transactions', 'customfile', 'PRPerson/PRPersonTransaction.asp', '', '', 0);
AddCustom_Tabs('0', '0', '25', 'Person', 'History', 'customfile', 'PRPerson/PRPersonLinkListing.asp', '', '', 0);
AddCustom_Tabs('0', '0', '30', 'Person', 'Background', 'customfile', 'PRPerson/PRPersonBackgroundListing.asp', '', '', 0);

// Main screen
ObjectName = 'PRPersonEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

AddCustom_Screens(ObjectName, 1, 'pers_LastName',   LN_New,  1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, 'pers_FirstName',  LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, 'pers_MiddleName', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, 'pers_Gender',     LN_New,  1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, 'pers_Salutation', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 6, 'pers_Suffix',     LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 7, 'pers_PRYearBorn', LN_New,  1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 8, 'pers_PRDeathDate',LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 9, 'pers_PRIndustryStartDate',LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 10,'pers_PRPaternalLastName', LN_New,  1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 11,'pers_PRMaternalLastName', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 12,'pers_PRMaidenName',       LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 13,'pers_PRNickname1',LN_New,  1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 14,'pers_PRNickname2',LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 15,'pers_PRLanguageSpoken',   LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 16,'pers_PRNotes',            LN_New, 1, 3, RQ_NotRequired, 0, '', '', '');


// Main List
ObjectName = 'PRPersonList';

AddCustom_ScreenObjects(ObjectName, 'List', 'vPRPersonnelListing', 'N', 0, 'vPRPersonnelListing', '', '', '', '', '', '');

AddCustom_Lists(ObjectName, '10', 'pers_FullName', '', OR_Allow, '', '', 'Person', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '20', 'peli_PRStatus', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '30', 'peli_PRTitle', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '40', 'peli_PRTitleCode', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '50', 'pers_PRLanguageSpoken', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '60', 'peli_PRRole', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '70', 'peli_WebStatus', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '80', 'peli_PRBRPublish', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '90', 'peli_PREBBPublish', '', OR_Allow, '', '', '', '', '', '', '', 0);

// Main entity search results
AddCustom_Captions('Tags', 'Person', 'NoRecordsFound', 0, 'No People', '', '', '', '', '', '');
AddCustom_Captions('Tags', 'Person', 'RecordsFound', 0, 'People', '', '', '', '', '', '');
AddCustom_Captions('Tags', 'Person', 'RecordFound', 0, 'Person', '', '', '', '', '', '');


// Search
AddCustom_Screens('PersonSearchBox', 1, 'pers_PersonID',   LN_New,  1, 1, RQ_NotRequired, 0, '', '', '');

AddCustom_Lists('PersonGrid', '1', 'pers_FullName', '', OR_Allow, '', '', 'Person', '', '', '', '', 0);
AddCustom_Lists('PersonGrid', '2', 'pers_PersonID', '', OR_Allow, '', '', 'Person', '', '', '', '', 0);



// Advanced Search screen
ObjectName = EntityName + 'AdvancedSearchBox';
      
AddCustom_ScreenObjects(ObjectName, 'SearchScreen', EntityName, 'N', 0, '', '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1,  'pers_LastName',   LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2,  'pers_FirstName',  LN_Same,  1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3,  'pers_PRMaidenName', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4,  'phon_AreaCode',   LN_New,  1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5,  'phon_Number',     LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 6,  'prci_CityID',     LN_New,  1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 7,  'prst_StateId',    LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// Main List
ObjectName = EntityName + 'AdvancedSearchGrid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, 'vPRPersonnelListing', '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '10', 'pers_FullName', '', OR_Allow, '', '', 'Person', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '20', 'pers_PersonID', '', OR_Allow, '', '', 'Person', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '30', 'pers_PRMaidenName', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '40', 'CompanyList', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '50', 'pers_PRNotes', '', OR_Allow, '', '', '', '', '', '', '', 0);

// Add Person Advanced File to Find dropdwon  
// Set the sequence to 3 so it follows the Person find
AddCustom_Tabs('0', '0', '3', 'Find', 'Person - Advanced', 'customfile', 'PRPerson/PRPersonAdvancedSearch.asp', '', 'Person.gif', 0);  




////////////////////////////////////////////////////////////////////////
// *********************************************************************
// PERSON AUS START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'AUS';
var EntityCaption = 'AUS';
var EntityCaptionPlural = 'AUS';
var ColPrefix = 'prau';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'PersonId';

// ------> CREATE SCREENS
// Summary and add new screen
ObjectName = 'PRAUSNewEntry';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'PersonId', LN_New, 1, 1, RQ_Required, 0, '', '', '');
//AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'CompanyId', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'MonitoredCompanyId', LN_New, 1, 1, RQ_Required, 0, '', '', '');

// Preferences - note that these are Person table fields
ObjectName = 'PRAUSPreferences';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, 'Person_Link', '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 3, 'peli_PRAUSReceiveMethod', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, 'peli_PRAUSChangePreference', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// AUS Company List
ObjectName = 'PRAUSGrid';
AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, 'vPRAUSCompanyList', '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', ColPrefix + '_' + 'CompanyId', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '1', ColPrefix + '_' + 'MonitoredCompanyId', '', OR_Allow, '', '', 'Custom', '', '', 'PRPerson/PRPersonAUS.asp', IdField, 0);
AddCustom_Lists(ObjectName, '2', 'prci_City', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '3', 'prst_State', '', OR_Allow, '', '', '', '', '', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// AUS DETAIL START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'AUSDetail';
var EntityCaption = 'AUS List';
var EntityCaptionPlural = 'AUS List';
var ColPrefix = 'prad';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'CompanyId';

// ------> CREATE SCREENS
// Main entity new screen
ObjectName = 'PRAUSDetailNewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

CreateScript = 'ReadOnly = true;';
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'AUSId', LN_New, 1, 1, RQ_Required, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'CompanyId', LN_Same, 1, 1, RQ_Required, 0, '', '', '');

// ------> CREATE LISTS
// Summary list
ObjectName = 'PRAUSDetailGrid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', ColPrefix + '_' + 'CompanyId', '', OR_Allow, '', '', 'Custom', '', '', 'PRAUS/PRAUSSummary.asp', IdField, 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');


////////////////////////////////////////////////////////////////////////
// *********************************************************************
// PERSON BACKGROUND START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'PersonBackground';
var EntityCaption = 'Background Record';
var EntityCaptionPlural = 'Background Records';
var ColPrefix = 'prba';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'Company';

// ------> CREATE SCREENS
// Main entity new screen
ObjectName = 'PRPersonBackgroundNewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

CreateScript = 'Hidden = true;';
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'PersonId', LN_New, 1, 1, RQ_Required, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'Company', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'Title', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'StartDate', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'EndDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// ------> CREATE LISTS
// Main entity list
ObjectName = 'PRPersonBackgroundGrid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', ColPrefix + '_' + 'StartDate', '', OR_Allow, '', '', 'Custom', '', '', 'PRPerson/PRPersonBackground.asp', IdField, 0);
AddCustom_Lists(ObjectName, '2', ColPrefix + '_' + 'EndDate', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '3', ColPrefix + '_' + 'Company', '', OR_Allow, '', '', 'Custom', '', '', 'PRPerson/PRPersonBackground.asp', IdField, 0);
AddCustom_Lists(ObjectName, '4', ColPrefix + '_' + 'Title', '', OR_Allow, '', '', '', '', '', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// PERSON EVENT START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'PersonEvent';
var EntityCaption = 'Person Event';
var EntityCaptionPlural = 'Person Events';
var ColPrefix = 'prpe';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'PersonEventTypeId';

// ------> CREATE SCREENS
// Search screen
ObjectName = EntityName + 'NewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

CreateScript = 'Hidden = true;';
AddCustom_Screens(ObjectName,  3, ColPrefix + '_' + 'Date', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName,  4, ColPrefix + '_' + 'EducationalInstitution', LN_New, 1, 3, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName,  5, ColPrefix + '_' + 'EducationalDegree', LN_New, 1, 3, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName,  6, ColPrefix + '_' + 'BankruptcyType', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName,  7, ColPrefix + '_' + 'USBankruptcyVoluntary', LN_Same, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName,  8, ColPrefix + '_' + 'USBankruptcyCourt', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName,  9, ColPrefix + '_' + 'CaseNumber', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 10, ColPrefix + '_' + 'DischargeType', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 11, ColPrefix + '_' + 'InternalAnalysis', LN_New, 1, 3, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 12, ColPrefix + '_' + 'PublishedAnalysis', LN_New, 1, 3, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 13, ColPrefix + '_' + 'PublishUntilDate', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 14, ColPrefix + '_' + 'PublishCreditSheet', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// ------> CREATE LISTS
// Main entity list
ObjectName = EntityName + 'Grid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '2', ColPrefix + '_' + 'PersonEventTypeId', '', '', '', '', 'Custom', '', '', 'PRPerson/PRPersonEvent.asp', IdField, 0);
AddCustom_Lists(ObjectName, '3', ColPrefix + '_' + 'Date', '', '', '', '', '', '', '', '', '', 0);



// ------> CREATE TABS
// Create the tab group
AddCustom_ScreenObjects(EntityName, 'TabGroup', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

// Create the tabs
AddCustom_Tabs('0', '0', '10', EntityName, 'Summary', 'customfile', EntityName + '/' + EntityName + 'Summary.asp', '', '', 0);
AddCustom_Tabs('0', '0', '20', EntityName, 'Notes', 'customfile', EntityName + '/' + EntityName + 'Note.asp', '', '', 0);
AddCustom_Tabs('0', '0', '30', EntityName, 'Communnications', 'customfile', EntityName + '/' + EntityName + 'Communication.asp', '', '', 0);
AddCustom_Tabs('0', '0', '40', EntityName, 'Library', 'customfile', EntityName + '/' + EntityName + 'Library.asp', '', '', 0);
AddCustom_Tabs('0', '0', '50', EntityName, 'Transactions', 'customfile', EntityName + '/' + EntityName + 'Transaction.asp', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// PERSON LINK START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var EntityName = 'Person_Link';
var ColPrefix = 'peli';
var IdField = 'peli_PersonLinkId';

AddCustom_Captions('Tags', 'ColNames', 'peli_companyid', 0, 'Company', '', '', '', '', '', '');

// ------> CREATE SCREENS
// Search screen
ObjectName = 'PRPersonLinkNewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

CreateScript = 'ReadOnly = true;';
//AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'PersonId', LN_New, 1, 1, RQ_Required, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'PRCompanyId', LN_New, 1, 2, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'PROwnershipRole', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 10, ColPrefix + '_' + 'PRStatus', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 14, ColPrefix + '_' + 'PRTitleCode', LN_Same, 1, 1, RQ_Required, 0, 'onTitleCodeChange()', '', '');
AddCustom_Screens(ObjectName, 20, ColPrefix + '_' + 'PRDLTitle', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 24, ColPrefix + '_' + 'PRTitle', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 30, ColPrefix + '_' + 'PRRole', LN_New, 1, 3, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 37, ColPrefix + '_' + 'PRRecipientRole', LN_Same, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 40, ColPrefix + '_' + 'PRResponsibilities', LN_New, 1, 3, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 50, ColPrefix + '_' + 'PRBRPublish', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 54, ColPrefix + '_' + 'PREBBPublish', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 60, ColPrefix + '_' + 'PRPctOwned', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 70, ColPrefix + '_' + 'PRStartDate', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 74, ColPrefix + '_' + 'PREndDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 80, ColPrefix + '_' + 'PRExitReason', LN_New, 1, 3, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 90, 'peli_PRAUSReceiveMethod', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 92, 'peli_PRAUSChangePreference', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 110, 'peli_WebStatus', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 112, 'peli_WebPassword', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 120, 'peli_PRReceivesBBScoreReport', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 122, 'peli_PRWhenVisited', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// Filterbox 
ObjectName = 'PRPerson_LinkFilterBox';

AddCustom_ScreenObjects(ObjectName, 'SearchScreen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, '1', ColPrefix + '_' + 'PRStatus', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

// ------> CREATE LISTS
// Main entity list
ObjectName = 'PRPerson_LinkGrid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, 'vPRListPerson', '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', 'comp_CompanyID', '', OR_Allow, '', '', 'Custom', '', '', 'PRCompany/PRCompanySummary.asp', 'comp_CompanyId', 0);
AddCustom_Lists(ObjectName, '2', 'comp_Name', '', OR_Allow, '', '', 'Custom', '', '', 'PRCompany/PRCompanySummary.asp', 'comp_CompanyId', 0);
AddCustom_Lists(ObjectName, '3', ColPrefix + '_' + 'PRTitleCode', '', OR_Allow, '', '', 'Custom', '', '', 'PRPerson/PRPersonLink.asp', 'peli_PersonLinkId', 0);
AddCustom_Lists(ObjectName, '4', ColPrefix + '_' + 'PRStartDate', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '5', ColPrefix + '_' + 'PREndDate', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '6', ColPrefix + '_' + 'PRStatus', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '7', 'peli_PRBRPublish', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '8', 'peli_PREBBPublish', '', OR_Allow, '', '', '', '', '', '', '', 0);



// ------> DEFINE CAPTIONS
// Main entity search results
AddCustom_Captions('Tags', 'Person_Link', 'NoRecordsFound', 0, 'No Employment Records', '', '', '', '', '', '');
AddCustom_Captions('Tags', 'Person_Link', 'RecordsFound', 0, 'Employment Records', '', '', '', '', '', '');
AddCustom_Captions('Tags', 'Person_Link', 'RecordFound', 0, 'Employment Record', '', '', '', '', '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// PERSON RELATIONSHIP START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'PersonRelationship';
var EntityCaption = 'Relationship';
var EntityCaptionPlural = 'Relationships';
var ColPrefix = 'prpr';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'Description';

// ------> CREATE SCREENS
// Main entity new screen
ObjectName = EntityName + 'NewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

CreateScript = 'ReadOnly = true;';
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'LeftPersonId', LN_Same, 1, 1, RQ_Required, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'RightPersonId', LN_Same, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'Description', LN_Same, 1, 1, RQ_Required, 0, '', '', '');

AddCustom_Captions('Tags', EntityName, 'NameColumn', 0, NameField, '', '', '', '', '', '');

// ------> CREATE LISTS
// Main entity list
ObjectName = EntityName + 'Grid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', ColPrefix + '_' + 'LeftPersonId', '', OR_Allow, '', '', 'Custom', '', '', 'PRPerson/PRPersonRelationship.asp', IdField, 0);
AddCustom_Lists(ObjectName, '1', ColPrefix + '_' + 'RightPersonId', '', OR_Allow, '', '', 'Custom', '', '', 'PRPerson/PRPersonRelationship.asp', IdField, 0);
AddCustom_Lists(ObjectName, '2', ColPrefix + '_' + 'Description', '', OR_Allow, '', '', '', '', '', '', '', 0);

// ------> CREATE TABS
// Create the tab group
AddCustom_ScreenObjects(EntityName, 'TabGroup', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

// Create the tabs
AddCustom_Tabs('0', '0', '10', EntityName, 'Summary', 'customfile', EntityName + '/' + EntityName + 'Summary.asp', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

