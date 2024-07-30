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
// TRANSACTION START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'Transaction';
var EntityCaption = 'Transaction';
var EntityCaptionPlural = 'Transactions';
var ColPrefix = 'prtx';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'Explanation';

// ------> CREATE SCREENS
// new screen
ObjectName = EntityName + 'NewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, 'vPRTransaction', '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'Status', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 6, ColPrefix + '_' + 'AuthorizedById', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 7, ColPrefix + '_' + 'AuthorizedInfo', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 8, ColPrefix + '_' + 'NotificationType', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 9, ColPrefix + '_' + 'NotificationStimulus', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 10, ColPrefix + '_' + 'EffectiveDate', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 11, ColPrefix + '_' + 'Explanation', LN_Same, 2, 3, RQ_NotRequired, 0, '', '', '');
//AddCustom_Screens(ObjectName, 12, ColPrefix + '_' + 'CreditSheetId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 13, ColPrefix + '_' + 'RedbookDate', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

// Company list
ObjectName = 'Company' + EntityName + 'Grid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', ColPrefix + '_' + 'CreatedBy', '', OR_Allow, 'Y', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '2', ColPrefix + '_' + 'CreatedDate', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '3', ColPrefix + '_' + 'Explanation', '', OR_Allow, '', '', 'Custom', '', '', 'PRTransaction/PRTransaction.asp', IdField, 0);
AddCustom_Lists(ObjectName, '4', ColPrefix + '_' + 'EffectiveDate', '', OR_Allow, '', '', 'Custom', '', '', 'PRTransaction/PRTransaction.asp', IdField, 0);
//AddCustom_Lists(ObjectName, '5', ColPrefix + '_' + 'CreditSheetId', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '6', ColPrefix + '_' + 'Status', '', OR_Allow, '', '', 'Custom', '', '', 'PRTransaction/PRTransaction.asp', IdField, 0);

// Person list
ObjectName = 'Person' + EntityName + 'Grid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', ColPrefix + '_' + 'EffectiveDate', '', OR_Allow, '', '', 'Custom', '', '', 'PRTransaction/PRTransaction.asp', IdField, 0);
AddCustom_Lists(ObjectName, '2', ColPrefix + '_' + 'Explanation', '', OR_Allow, '', '', 'Custom', '', '', 'PRTransaction/PRTransaction.asp', IdField, 0);
AddCustom_Lists(ObjectName, '3', ColPrefix + '_' + 'Status', '', OR_Allow, '', '', 'Custom', '', '', 'PRTransaction/PRTransaction.asp', IdField, 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');


////////////////////////////////////////////////////////////////////////
// *********************************************************************
// TRANSACTION DETAIL START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'TransactionDetail';
var EntityCaption = 'Transaction Detail';
var EntityCaptionPlural = 'Transaction Details';
var ColPrefix = 'prtd';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'ColumnName';

// ------> CREATE LISTS
// Transaction Detail list
ObjectName = EntityName + 'Grid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', ColPrefix + '_' + 'CreatedDate', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '2', ColPrefix + '_' + 'Action', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '3', ColPrefix + '_' + 'EntityName', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '4', ColPrefix + '_' + 'ColumnName', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '5', ColPrefix + '_' + 'OldValue', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '6', ColPrefix + '_' + 'NewValue', '', OR_Allow, '', '', '', '', '', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

