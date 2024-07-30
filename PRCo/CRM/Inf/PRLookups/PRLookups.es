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
// ATTRIBUTE START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'Attribute';
var EntityCaption = 'Attribute';
var EntityCaptionPlural = 'Attributes';
var ColPrefix = 'prat';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'Name';

// ------> CREATE SCREENS
// Main entity search screen
ObjectName = EntityName + 'SearchBox';

AddCustom_ScreenObjects(ObjectName, 'SearchScreen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, NameField, LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'Type', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'IPDFlag', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// Main entity new screen
ObjectName = EntityName + 'NewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, NameField, LN_New, 1, 2, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'Type', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'IPDFlag', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// ------> CREATE LISTS
// Main entity list
ObjectName = EntityName + 'Grid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', NameField, '', '', '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '2', ColPrefix + '_' + 'Type', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '3', ColPrefix + '_' + 'IPDFlag', '', OR_Allow, '', '', '', '', '', '', '', 0);

// ------> CREATE TABS
// Create the tab group
AddCustom_ScreenObjects(EntityName, 'TabGroup', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

// Create the tabs
AddCustom_Tabs('0', '0', '10', EntityName, 'Summary', 'customfile', EntityName + '/' + EntityName + 'Summary.asp', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// BUSINESS EVENT TYPE START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'BusinessEventType';
var EntityCaption = 'Business Event Type';
var EntityCaptionPlural = 'Business Event Types';
var ColPrefix = 'prbt';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'Name';

// ------> CREATE SCREENS
// Main entity search screen
ObjectName = EntityName + 'SearchBox';

AddCustom_ScreenObjects(ObjectName, 'SearchScreen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, NameField, LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'PublishDefaultTime', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

// Main entity new screen
ObjectName = EntityName + 'NewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, NameField, LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'PublishDefaultTime', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

// ------> CREATE LISTS
// Main entity list
ObjectName = EntityName + 'Grid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', NameField, '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '2', ColPrefix + '_' + 'PublishDefaultTime', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);

// ------> CREATE TABS
// Create the tab group
AddCustom_ScreenObjects(EntityName, 'TabGroup', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

// Create the tabs
AddCustom_Tabs('0', '0', '10', EntityName, 'Summary', 'customfile', EntityName + '/' + EntityName + 'Summary.asp', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// CITY START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'City';
var EntityCaption = 'City';
var EntityCaptionPlural = 'Cities';
var ColPrefix = 'prci';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'City';

// ------> CREATE SCREENS
// Search screen
ObjectName = EntityName + 'SearchBox';

AddCustom_ScreenObjects(ObjectName, 'SearchScreen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'City', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'County', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'StateId', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'RatingTerritory', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'RatingUserId', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 6, ColPrefix + '_' + 'SalesTerritory', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 7, ColPrefix + '_' + 'InsideSalesRepId', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 8, ColPrefix + '_' + 'FieldSalesRepId', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 9, ColPrefix + '_' + 'ListingSpecialistId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

// Main entity new screen
ObjectName = EntityName + 'NewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'City', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'County', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'StateId', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'RatingTerritory', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'RatingUserId', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 6, ColPrefix + '_' + 'SalesTerritory', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 7, ColPrefix + '_' + 'InsideSalesRepId', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 8, ColPrefix + '_' + 'FieldSalesRepId', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 9, ColPrefix + '_' + 'ListingSpecialistId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

// ------> CREATE LISTS
// Main entity list
ObjectName = EntityName + 'Grid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', ColPrefix + '_' + 'City', '', '', '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '2', ColPrefix + '_' + 'County', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '3', ColPrefix + '_' + 'StateId', '', OR_Allow, '', '', '', '', '', '', '', 0);

// PRCO Account Team screen
ObjectName = 'PRCoAccountTeam';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'ListingSpecialistId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'RatingUserId', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'CustomerServiceId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'InsideSalesRepId', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'FieldSalesRepId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');


// ------> CREATE TABS
// Create the tab group
AddCustom_ScreenObjects(EntityName, 'TabGroup', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

// Create the tabs
AddCustom_Tabs('0', '0', '10', EntityName, 'Summary', 'customfile', EntityName + '/' + EntityName + 'Summary.asp', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// CREDIT WORTH RATING START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'CreditWorthRating';
var EntityCaption = 'Credit Worth Rating';
var EntityCaptionPlural = 'Credit Worth Ratings';
var ColPrefix = 'prcw';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'Name';

// ------> CREATE SCREENS
// Main entity search screen
ObjectName = EntityName + 'SearchBox';

AddCustom_ScreenObjects(ObjectName, 'SearchScreen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'Name', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'Description', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'Order', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// Main entity new screen
ObjectName = EntityName + 'NewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'Name', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'Description', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'Order', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// ------> CREATE LISTS
// Main entity list
ObjectName = EntityName + 'Grid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', ColPrefix + '_' + 'Name', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '2', ColPrefix + '_' + 'Order', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);

// ------> CREATE TABS
// Create the tab group
AddCustom_ScreenObjects(EntityName, 'TabGroup', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

// Create the tabs
AddCustom_Tabs('0', '0', '10', EntityName, 'Summary', 'customfile', EntityName + '/' + EntityName + 'Summary.asp', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// INTEGRITY RATING START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'IntegrityRating';
var EntityCaption = 'Integrity Rating';
var EntityCaptionPlural = 'Integrity Ratings';
var ColPrefix = 'prin';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'Name';

// ------> CREATE SCREENS
// Main entity search screen
ObjectName = EntityName + 'SearchBox';

AddCustom_ScreenObjects(ObjectName, 'SearchScreen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'Name', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'Description', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'SpanishDescription', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'Weight', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// Main entity new screen
ObjectName = EntityName + 'NewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'Name', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'Description', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'SpanishDescription', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'Weight', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// ------> CREATE LISTS
// Main entity list
ObjectName = EntityName + 'Grid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', ColPrefix + '_' + 'Name', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '2', ColPrefix + '_' + 'Description', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);

// ------> CREATE TABS
// Create the tab group
AddCustom_ScreenObjects(EntityName, 'TabGroup', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

// Create the tabs
AddCustom_Tabs('0', '0', '10', EntityName, 'Summary', 'customfile', EntityName + '/' + EntityName + 'Summary.asp', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// PAY RATING START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'PayRating';
var EntityCaption = 'Pay Rating';
var EntityCaptionPlural = 'Pay Ratings';
var ColPrefix = 'prpy';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'Name';

// ------> CREATE SCREENS
// Main entity search screen
ObjectName = EntityName + 'SearchBox';

AddCustom_ScreenObjects(ObjectName, 'SearchScreen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'Name', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'Description', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'SpanishDescription', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

// Main entity new screen
ObjectName = EntityName + 'NewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'Name', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'Description', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'SpanishDescription', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

// ------> CREATE LISTS
// Main entity list
ObjectName = EntityName + 'Grid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', ColPrefix + '_' + 'Name', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '2', ColPrefix + '_' + 'Description', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);

// ------> CREATE TABS
// Create the tab group
AddCustom_ScreenObjects(EntityName, 'TabGroup', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

// Create the tabs
AddCustom_Tabs('0', '0', '10', EntityName, 'Summary', 'customfile', EntityName + '/' + EntityName + 'Summary.asp', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// PERSON EVENT TYPE START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'PersonEventType';
var EntityCaption = 'Person Event Type';
var EntityCaptionPlural = 'Person Event Types';
var ColPrefix = 'prpt';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'Name';

// ------> CREATE SCREENS
// Main entity search screen
ObjectName = EntityName + 'SearchBox';

AddCustom_ScreenObjects(ObjectName, 'SearchScreen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'Name', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'PublishDefaultTime', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

// Main entity new screen
ObjectName = EntityName + 'NewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'Name', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'PublishDefaultTime', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

// ------> CREATE LISTS
// Main entity list
ObjectName = EntityName + 'Grid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', ColPrefix + '_' + 'Name', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '2', ColPrefix + '_' + 'PublishDefaultTime', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);

// ------> CREATE TABS
// Create the tab group
AddCustom_ScreenObjects(EntityName, 'TabGroup', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

// Create the tabs
AddCustom_Tabs('0', '0', '10', EntityName, 'Summary', 'customfile', EntityName + '/' + EntityName + 'Summary.asp', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// RATING NUMERAL START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'RatingNumeral';
var EntityCaption = 'Rating Numeral';
var EntityCaptionPlural = 'Rating Numerals';
var ColPrefix = 'prrn';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'Name';

// ------> CREATE SCREENS
// Main entity search screen
ObjectName = EntityName + 'SearchBox';

AddCustom_ScreenObjects(ObjectName, 'SearchScreen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'Name', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'Type', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'EnglishDescription', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'SpanishDescription', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
//AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'SuppressFullRating', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
//AddCustom_Screens(ObjectName, 6, ColPrefix + '_' + 'SuppressIntegrityRating', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
//AddCustom_Screens(ObjectName, 7, ColPrefix + '_' + 'SuppressPayRating', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// Main entity new screen
ObjectName = EntityName + 'NewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'Name', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'Type', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'EnglishDescription', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'SpanishDescription', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
//AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'SuppressFullRating', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
//AddCustom_Screens(ObjectName, 6, ColPrefix + '_' + 'SuppressIntegrityRating', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
//AddCustom_Screens(ObjectName, 7, ColPrefix + '_' + 'SuppressPayRating', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// ------> CREATE LISTS
// Main entity list
ObjectName = EntityName + 'Grid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', ColPrefix + '_' + 'Name', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '2', ColPrefix + '_' + 'Type', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '3', ColPrefix + '_' + 'EnglishDescription', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);

// ------> CREATE TABS
// Create the tab group
AddCustom_ScreenObjects(EntityName, 'TabGroup', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

// Create the tabs
AddCustom_Tabs('0', '0', '10', EntityName, 'Summary', 'customfile', EntityName + '/' + EntityName + 'Summary.asp', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// RELATIONSHIP TYPE START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'RelationshipType';
var EntityCaption = 'Relationship Type';
var EntityCaptionPlural = 'Relationship Types';
var ColPrefix = 'prrt';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'Name';

// ------> CREATE SCREENS
// Main entity search screen
ObjectName = EntityName + 'SearchBox';

AddCustom_ScreenObjects(ObjectName, 'SearchScreen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'Name', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'Description', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'Category', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

// Main entity new screen
ObjectName = EntityName + 'NewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'Name', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'Description', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'Category', LN_New, 1, 1, RQ_Required, 0, '', '', '');

// ------> CREATE LISTS
// Main entity list
ObjectName = EntityName + 'Grid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', ColPrefix + '_' + 'Name', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '2', ColPrefix + '_' + 'Description', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '3', ColPrefix + '_' + 'Category', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);

// ------> CREATE TABS
// Create the tab group
AddCustom_ScreenObjects(EntityName, 'TabGroup', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

// Create the tabs
AddCustom_Tabs('0', '0', '10', EntityName, 'Summary', 'customfile', EntityName + '/' + EntityName + 'Summary.asp', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// STATE START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'State';
var EntityCaption = 'State';
var EntityCaptionPlural = 'States';
var ColPrefix = 'prst';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'State';

// ------> CREATE SCREENS
// Main entity new screen
ObjectName = EntityName + 'NewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, 'vPRSearchListState', '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, NameField, LN_New, 1, 2, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'CountryId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'Abbreviation', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// Main entity search screen
ObjectName = EntityName + 'SearchBox';

AddCustom_ScreenObjects(ObjectName, 'SearchScreen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, NameField, LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, 'prcn_CountryId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'Abbreviation', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// ------> CREATE LISTS
// Main entity list
ObjectName = EntityName + 'Grid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, 'vPRSearchListState', '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', NameField, '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '2', 'prcn_Country', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '3', ColPrefix + '_' + 'Abbreviation', '', OR_Allow, '', '', '', '', '', '', '', 0);

// ------> CREATE TABS
// Create the tab group
AddCustom_ScreenObjects(EntityName, 'TabGroup', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

// Create the tabs
AddCustom_Tabs('0', '0', '10', EntityName, 'Summary', 'customfile', EntityName + '/' + EntityName + 'Summary.asp', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// STOCK EXCHANGE START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'StockExchange';
var EntityCaption = 'Stock Exchange';
var EntityCaptionPlural = 'Stock Exchanges';
var ColPrefix = 'prex';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'Name';

// ------> CREATE SCREENS
// Main entity search screen
ObjectName = 'PRStockExchangeSearchBox';

AddCustom_ScreenObjects(ObjectName, 'SearchScreen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, NameField, LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'Publish', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'Order', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// Main entity new screen
ObjectName = 'PRStockExchangeNewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, NameField, LN_New, 1, 2, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'Publish', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'Order', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// ------> CREATE LISTS
// Main entity list
ObjectName = 'PRStockExchangeGrid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', NameField, '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '2', ColPrefix + '_' + 'Publish', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '3', ColPrefix + '_' + 'Order', '', OR_Allow, '', '', '', '', '', '', '', 0);

// ------> CREATE TABS
// Create the tab group
AddCustom_ScreenObjects(EntityName, 'TabGroup', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

// Create the tabs
AddCustom_Tabs('0', '0', '10', EntityName, 'Summary', 'customfile', EntityName + '/' + EntityName + 'Summary.asp', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// TERMINAL MARKET START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'TerminalMarket';
var EntityCaption = 'Terminal Market';
var EntityCaptionPlural = 'Terminal Markets';
var ColPrefix = 'prtm';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = 'prtm_FullMarketName';

// ------> CREATE SCREENS
// Main entity search screen
ObjectName = EntityName + 'SearchBox';

AddCustom_ScreenObjects(ObjectName, 'SearchScreen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 2, 'prtm_FullMarketName', LN_New, 1, 3, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, 'prtm_ListedMarketName', LN_New, 1, 3, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 20, 'prtm_City', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 25, 'prtm_State', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 27, 'prtm_Zip', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// Main entity new screen
ObjectName = EntityName + 'NewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, 'prtm_FullMarketName', LN_New, 1, 3, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 10, 'prtm_ListedMarketName', LN_New, 1, 3, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 20, 'prtm_Address', LN_New, 1, 3, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 30, 'prtm_City', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 31, 'prtm_State', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 32, 'prtm_Zip', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// ------> CREATE LISTS
// Main entity list
ObjectName = EntityName + 'Grid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', 'prtm_FullMarketName', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '2', 'prtm_ListedMarketName', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '3', 'prtm_City', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '4', 'prtm_State', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '5', 'prtm_Zip', '', OR_Allow, '', '', '', '', '', '', '', 0);

// ------> CREATE TABS
// Create the tab group
AddCustom_ScreenObjects(EntityName, 'TabGroup', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

// Create the tabs
AddCustom_Tabs('0', '0', '10', EntityName, 'Summary', 'customfile', EntityName + '/' + EntityName + 'Summary.asp', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');




////////////////////////////////////////////////////////////////////////
// *********************************************************************
// vPRLocation
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'vPRLocation';
var EntityCaption = 'Location';
var EntityCaptionPlural = 'Locations';

var EntityName = 'vPRLocation';

// Main entity search screen
ObjectName = EntityName + 'SearchBox';
AddCustom_ScreenObjects(ObjectName, 'SearchScreen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, 'prci_CityID',    LN_New,  1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, 'prst_StateId',   LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, 'prcn_CountryId', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');


// Main entity search screen
ObjectName = EntityName + 'Grid';
AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', 'prci_City',    '', OR_Allow, '', '', 'Y', '', '', '', 'prci_CityID', 0);
AddCustom_Lists(ObjectName, '2', 'prst_State',   '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '3', 'prcn_Country', '', OR_Allow, '', '', '', '', '', '', '', 0);


// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, 'CityStateCountry', 'prci_CityID', '', '');



////////////////////////////////////////////////////////////////////////
// *********************************************************************
// Country
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'Country';
var EntityCaption = 'Country';
var EntityCaptionPlural = 'Countries';
var ColPrefix = 'prcn';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'Country';


// Main entity search screen
ObjectName = EntityName + 'SearchBox';
AddCustom_ScreenObjects(ObjectName, 'SearchScreen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, 'prcn_Country',     LN_New,  1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, 'prcn_CountryCode', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, 'prcn_Language',    LN_New,  1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, 'prcn_IATACode',    LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');


// Main entity search screen
ObjectName = EntityName + 'Grid';
AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', 'prcn_Country',     '', OR_Allow, '', '', 'Y', '', '', '', IdField, 0);
AddCustom_Lists(ObjectName, '2', 'prcn_CountryCode', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '3', 'prcn_Language',    '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '4', 'prcn_IATACode',    '', OR_Allow, '', '', '', '', '', '', '', 0);


// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');
