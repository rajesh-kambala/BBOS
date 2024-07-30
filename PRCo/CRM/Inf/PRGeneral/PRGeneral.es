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
	AddCustom_Captions('Tags', EntityName, 'SummaryPage', 0, EntityName + '.asp', '', '', '', '', '', '');
   
   return true;
}

function AddCustomTableData(Table, Prefix, IdField, ColNames, ColData,SQLWhereFields) {
	AddCustom_Data(table, prefix, idfield, colnames, ColData, SQLWhereFields);
	return(true);
}

function pcg_UpdateCaption(sFamilyType, sFamily, sCode, sCaption) {
    AddCustom_Data("Custom_Captions", "Capt", "Capt_CaptionId", "Capt_FamilyType, Capt_Family, Capt_Code, Capt_US", sFamilyType + ", " + sFamily + ", " + sCode + ", " + sCaption, "1,2,3"); 
}

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// SYSTEM START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------ CREATE TABS
AddCustom_Tabs('0', '0', '50', 'Find', 'Credit Sheet', 'customfile', 'PRCreditSheet/PRCreditSheetFind.asp', '', 'PRCreditSheet.gif', 0);
AddCustom_Tabs('0', '0', '57', 'Find', 'SS File', 'customfile', 'PRFile/PRFileListing.asp', '', 'PRFile.gif', 0);
AddCustom_Tabs('0', '0', '65', 'Find', 'PACA License', 'customfile', 'PRPACALicense/PRPACALicenseFind.asp', '', 'PRPACALicense.gif', 0);
AddCustom_Tabs('0', '0', '100', 'Find', 'Stock Exchange', 'customfile', 'PRStockExchange/PRStockExchangeFind.asp', '', 'PRStockExchange.gif', 0);
AddCustom_Tabs('0', '0', '105', 'Find', 'Terminal Market', 'customfile', 'PRTerminalMarket/PRTerminalMarketFind.asp', '', 'PRTerminalMarket.gif', 0);

// My CRM screen
AddCustom_Tabs('0', '0', '20', 'User', 'Credit Sheet Items', 'customfile', 'PRCreditSheet/PRCreditSheetListing.asp', '', 'PRCreditSheet.gif', 0);
//AddCustom_Tabs('0', '0', '20', 'User', 'Transactions', 'customfile', 'PRUser/PRUserTransaction.asp', '', 'PRTransaction.gif', 0);
AddCustom_Tabs('0', '0', '20', 'User', 'Exception Queue', 'customfile', 'PRExceptionQueue/PRExceptionQueueListing.asp', '', 'PRException.gif', 0);
AddCustom_Tabs('0', '0', '20', 'User', 'SS Files', 'customfile', 'PRFile/PRFileListing.asp', '', 'PRFile.gif', 0);

// Team CRM screen
AddCustom_Tabs('0', '0', '20', 'Channel', 'Credit Sheet Items', 'customfile', 'PRCreditSheet/PRCreditSheetListing.asp', '', 'PRCreditSheet.gif', 0);
//AddCustom_Tabs('0', '0', '20', 'Channel', 'Transactions', 'customfile', 'PRChannel/PRChannelTransaction.asp', '', 'PRTransaction.gif', 0);
AddCustom_Tabs('0', '0', '20', 'Channel', 'Exception Queue', 'customfile', 'PRExceptionQueue/PRExceptionQueueListing.asp', '', 'PRException.gif', 0);
AddCustom_Tabs('0', '0', '20', 'Channel', 'SS Files', 'customfile', 'PRFile/PRFileListing.asp', '', 'PRFile.gif', 0);

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// ADDRESS START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var EntityName = 'Address';
var ColPrefix = 'addr';

// ------> CREATE SCREENS
// Address new screen

ObjectName = 'PRAddressNewEntry';
AddCustom_ScreenObjects(ObjectName, 'Screen', 'Address', 'N', 0, 'vPRAddress', '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_Address1', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_Address2', LN_Same, 1, 3, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_Address3', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_Address4', LN_Same, 1, 3, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, ColPrefix + '_PRCityID', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
//AddCustom_Screens(ObjectName, 6, ColPrefix + '_State', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 7, ColPrefix + '_PostCode', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
//AddCustom_Screens(ObjectName, 8, ColPrefix + '_Country', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 9, ColPrefix + '_PRCounty', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 10, ColPrefix + '_PRPublish', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
CreateScript = "ReadOnly = true;"; 
AddCustom_Screens(ObjectName, 11, 'adli_PRSlot', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);

AddCustom_Screens(ObjectName, 12, 'adli_Type', LN_Same, 1, 3, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 13, 'adli_PRDefaultMailing', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 14, 'adli_PRDefaultShipping', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 15, 'adli_PRDefaultBilling', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 16, 'adli_PRDefaultListing', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 17, 'adli_PRDefaultTax', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 18, 'adli_PRDefaultTES', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 19, 'adli_PRDefaultJeopardy', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 26, ColPrefix + '_PRDescription', LN_New, 1, 4, RQ_NotRequired, 0, '', '', '');

//AddCustom_Screens(ObjectName, 10, ColPrefix + '_Type', LN_New, 1, 2, RQ_Required, 0, '', '', '');
//AddCustom_Screens(ObjectName, 11, ColPrefix + '_PRCompanyId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', 'ReadOnly=true;');
//AddCustom_Screens(ObjectName, 12, ColPrefix + '_PRPersonId', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', 'ReadOnly=true;');

ObjectName = 'PRPersonAddressNewEntry';
AddCustom_ScreenObjects(ObjectName, 'Screen', 'Address', 'N', 0, 'vPRAddress', '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_Address1', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_Address2', LN_Same, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_Address3', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_Address4', LN_Same, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, ColPrefix + '_PRCityID', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 7, ColPrefix + '_PostCode', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 9, ColPrefix + '_PRCounty', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 12, 'adli_PRDefaultMailing', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 13, 'adli_Type', LN_Same, 1, 2, RQ_NotRequired, 0, '', '', '');

// Address new screen
ObjectName = 'PRAddressBoxShort';

AddCustom_ScreenObjects(ObjectName, 'Screen', 'Address', 'N', 0, 'vPRAddress', '', '', '', '', '', '');
//AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'Type', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, 'Addr_Street', LN_New, 2, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, 'prci_City', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, 'prst_State', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, 'addr_PostCode', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 6, 'prcn_Country', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// ------> CREATE LISTS
// Company Address list
ObjectName = 'PRCompanyAddressGrid';

AddCustom_Captions('Tags', 'ColNames', 'adli_TypeDisplay', 0, 'Type', '', '', '', '', '', '');

AddCustom_ScreenObjects(ObjectName, 'List', 'Address', 'N', 0, 'vPRAddress', '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', 'adli_TypeDisplay', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '2', 'addr_Address1', '', OR_Allow, '', '', 'Custom', '', '', 'PRCompany/PRCompanyAddress.asp', 'Addr_AddressId', 0);
AddCustom_Lists(ObjectName, '3', 'prci_City', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '4', 'prst_State', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '5', 'addr_PostCode', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '6', 'prcn_Country', '', OR_Allow, '', '', '', '', '', '', '', 0);

// Person Address list
ObjectName = 'PRPersonAddressGrid';

AddCustom_ScreenObjects(ObjectName, 'List', 'Address', 'N', 0, 'vPRAddress', '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', 'adli_TypeDisplay', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '2', ColPrefix + '_Address1', '', OR_Allow, '', '', 'Custom', '', '', 'PRPerson/PRPersonAddress.asp', 'Addr_AddressId', 0);
AddCustom_Lists(ObjectName, '3', 'prci_City', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '4', 'prst_State', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '5', 'addr_PostCode', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '6', 'prcn_Country', '', OR_Allow, '', '', '', '', '', '', '', 0);


// ------> DEFINE CAPTIONS
// Main entity search results
AddCustom_Captions('Tags', 'Address', 'NoRecordsFound', 0, 'No Addresses', '', '', '', '', '', '');
AddCustom_Captions('Tags', 'Address', 'RecordsFound', 0, 'Addresses', '', '', '', '', '', '');
AddCustom_Captions('Tags', 'Address', 'RecordFound', 0, 'Address', '', '', '', '', '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// ADDRESS LINK START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var EntityName = 'Address_Link';
var ColPrefix = 'adli';
ObjectName = 'AddressLinkNewEntry';
AddCustom_ScreenObjects(ObjectName, 'Screen', 'Address_Link', 'N', 0, 'Address_Link', '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'Type', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'PRPublish', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'PRSequence', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'PRDescription', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
////////////////////////////////////////////////////////////////////////
// *********************************************************************
// BUSINESS EVENT START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'BusinessEvent';
var EntityCaption = 'Bus Event';
var EntityCaptionPlural = 'Bus Events';
var ColPrefix = 'prbe';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'BusinessEventTypeId';

// ------> CREATE SCREENS
// Search screen
ObjectName = EntityName + 'NewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

CreateScript = 'ReadOnly = true;';
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'CompanyId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);

/*
 *  RAO -- To facilitate the most effective display of the Business Event screens, we will create
 *  several small blocks that will represent the "additional info" for a selected type.
 *  The interface will first determine the type of business event, then on a "step 2" page,
 *  enter the additional info. Items in "Core" show up on all business events.
 */ 

ObjectName = EntityName + '_Core';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
//AddCustom_Screens(ObjectName, 10, 'prbe_CompanyId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 11, 'prbe_BusinessEventTypeId', LN_Same, 1, 3, RQ_NotRequired, 0, '', '', 'ReadOly = true;');
AddCustom_Screens(ObjectName, 12, 'prbe_EffectiveDate', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 12, 'prbe_DisplayedEffectiveDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 12, 'prbe_DisplayedEffectiveDateStyle', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 13, 'prbe_CreditSheetPublish', LN_New, 1, 3, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 14, 'prbe_CreditSheetNote', LN_New, 1, 3, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 15, 'prbe_PublishedAnalysis', LN_New, 1, 3, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 16, 'prbe_InternalAnalysis', LN_New, 1, 3, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 18, 'prbe_PublishUntilDate', LN_New, 1, 3, RQ_NotRequired, 0, '', '', '');

ObjectName = EntityName + '_Acquisition';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 41, 'prbe_RelatedCompany1Id', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 42, 'prbe_DetailedType', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 44, 'prbe_OtherDescription', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

// Agreement will also be used for Letter of Intent
ObjectName = EntityName + '_Agreement';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 41, 'prbe_RelatedCompany1Id', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 42, 'prbe_DetailedType', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 43, 'prbe_AgreementCategory', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 45, 'prbe_AnticipatedCompletionDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 47, 'prbe_OtherDescription', LN_New, 1, 3, RQ_NotRequired, 0, '', '', '');

ObjectName = EntityName + '_Assignment';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 47, 'prbe_AssigneeTrusteeName', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 48, 'prbe_AssigneeTrusteeAddress', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 49, 'prbe_AssigneeTrusteePhone', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

ObjectName = EntityName + '_USBankrupcy';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 10, 'prbe_DetailedType', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 11, 'prbe_USBankruptcyEntity', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 20, 'prbe_SpecifiedCSNumeral', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 21, 'prbe_USBankruptcyVoluntary', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 30, 'prbe_USBankruptcyCourt', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 31, 'prbe_CaseNumber', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 40, 'prbe_AttorneyName', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 41, 'prbe_AttorneyPhone', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 50, 'prbe_AssigneeTrusteeName', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 51, 'prbe_AssigneeTrusteePhone', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 60, 'prbe_AssetAmount', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 61, 'prbe_LiabilityAmount', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');


ObjectName = EntityName + '_CanBankrupcy';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 10, 'prbe_DetailedType', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

ObjectName = EntityName + '_BusinessClosed';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 10, 'prbe_DetailedType', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

ObjectName = EntityName + '_BusinessChange';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 10, 'prbe_DetailedType', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 11, 'prbe_StateId', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

ObjectName = EntityName + '_BusinessStarted';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 10, 'prbe_DetailedType', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 11, 'prbe_StateId', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 20, 'prbe_Names', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');

ObjectName = EntityName + '_OwnershipSale';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 10, 'prbe_DetailedType', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 11, 'prbe_PercentSold', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 30, 'prbe_IndividualBuyerId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 31, 'prbe_IndividualSellerId', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

ObjectName = EntityName + '_BusinessSale';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 40, 'prbe_DetailedType', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 41, 'prbe_IndividualBuyerId', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 44, 'prbe_OtherDescription', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');

ObjectName = EntityName + '_DRCIssue';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 40, 'prbe_DetailedType', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

ObjectName = EntityName + '_Extension';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 40, 'prbe_DetailedType', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

ObjectName = EntityName + '_Injunction';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 10, 'prbe_CourtDistrict', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 11, 'prbe_CaseNumber', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 20, 'prbe_AttorneyName', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 21, 'prbe_AttorneyPhone', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// Judgement will also be used for Lien, PACA Trust Procedure, 
ObjectName = EntityName + '_Judgement';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 20, 'prbe_RelatedCompany1Id', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 21, 'prbe_Amount', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

ObjectName = EntityName + '_Disaster';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 20, 'prbe_DetailedType', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 22, 'prbe_DisasterImpact', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 29, 'prbe_Amount', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 47, 'prbe_OtherDescription', LN_New, 1, 3, RQ_NotRequired, 0, '', '', '');

ObjectName = EntityName + '_PACAEvent';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 40, 'prbe_DetailedType', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

ObjectName = EntityName + '_PACASuspended';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 10, 'prbe_Names', LN_New, 1, 3, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 20, 'prbe_NumberSellers', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 21, 'prbe_Amount', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 22, 'prbe_StateId', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 30, 'prbe_NonPromptStart', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 31, 'prbe_NonPromptEnd', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 40, 'prbe_BusinessOperateUntil', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 41, 'prbe_IndividualOperateUntil', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 50, 'prbe_DetailedType', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

// Receivership will be used for Receivership applied for, Receivership appointed, 
ObjectName = EntityName + '_Receivership';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 20, 'prbe_RelatedCompany1Id', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 21, 'prbe_RelatedCompany2Id', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

ObjectName = EntityName + '_TreasuryStock';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 29, 'prbe_Amount', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

ObjectName = EntityName + '_TRO';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 10, 'prbe_CourtDistrict', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 11, 'prbe_CaseNumber', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 20, 'prbe_RelatedCompany1Id', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 21, 'prbe_Amount', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');


// ------> CREATE LISTS
// Main entity list
ObjectName = EntityName + 'Grid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '2', ColPrefix + '_' + 'BusinessEventTypeId', '', '', '', '', 'Custom', '', '', 'PRCompany/PRCompanyBusinessEvent.asp', IdField, 0);
AddCustom_Lists(ObjectName, '3', ColPrefix + '_' + 'EffectiveDate', '', '', '', '', '', '', '', '', '', 0);

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
// BUSINESS REPORT REQUEST START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'BusinessReportRequest';
var EntityCaption = 'Business Report Request';
var EntityCaptionPlural = 'Business Report Requests';
var ColPrefix = 'prbr';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'Date';

// ------> CREATE SCREENS
// Main entity search screen
ObjectName = EntityName + 'SearchBox';

AddCustom_ScreenObjects(ObjectName, 'SearchScreen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'RequestingCompanyId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'RequestingPersonId', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'RequestedCompanyId', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'Date', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'MethodSent', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 6, ColPrefix + '_' + 'SendToId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 7, ColPrefix + '_' + 'Address', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 8, ColPrefix + '_' + 'CityStateZip', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 9, ColPrefix + '_' + 'Fax', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

// Main entity new screen
ObjectName = 'PRBusinessReportRequestBlock';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'RequestingCompanyId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'RequestingPersonId', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'DoNotChargeUnits', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 20, ColPrefix + '_' + 'MethodSent', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 30, ColPrefix + '_' + 'RequestorInfo', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 40, ColPrefix + '_' + 'AddressLine1', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 50, ColPrefix + '_' + 'AddressLine2', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 60, ColPrefix + '_' + 'CityStateZip', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 70, ColPrefix + '_' + 'Country', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 80, ColPrefix + '_' + 'Fax', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 85, ColPrefix + '_' + 'EmailAddress', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 100, ColPrefix + '_' + 'RequestedCompanyId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

// Company list
ObjectName = 'PRCompanyBusinessReportGrid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', ColPrefix + '_' + 'RequestingPersonId', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '2', ColPrefix + '_' + 'RequestedCompanyId', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '3', ColPrefix + '_' + 'Date', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '4', ColPrefix + '_' + 'MethodSent', '', OR_Allow, '', '', '', '', '', '', '', 0);

// ------> CREATE TABS
// Create the tab group
AddCustom_ScreenObjects(EntityName, 'TabGroup', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

// Create the tabs
AddCustom_Tabs('0', '0', '10', EntityName, 'Summary', 'customfile', EntityName + '/' + EntityName + 'Summary.asp', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// CLASSIFICATION START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'Cases';
var EntityName = 'Cases';
var EntityCaption = 'Cases';
var EntityCaptionPlural = 'Cases';
var ColPrefix = 'case';


// ------> CREATE SCREENS
// Search screen
ObjectName = 'CasesSearchBox';

AddCustom_ScreenObjects(ObjectName, 'SearchScreen', 'vCustomerCareWorkflowListing', 'N', 0, 'vCustomerCareWorkflowListing', '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, '_StartDate', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, '_EndDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 6, 'case_AssignedUserId', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 12, 'case_ProblemType', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 18, 'case_Priority', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 19, 'case_ProductArea', LN_Same, 8, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 24, 'case_Stage', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 25, 'case_Status', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 38, 'case_ProblemNote', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 39, 'case_SolutionNote', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// Main entity new screens
ObjectName = 'CasesContact';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, 'case_PrimaryCompanyId', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, 'case_PrimaryPersonId', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, 'case_PRCompanyITRep', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

ObjectName = 'CasesDetails';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, 'case_ReferenceId', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, 'case_Source', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 6, 'case_ProductArea', LN_Same, 5, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 30, 'case_PRCallDuration', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 40, 'case_PRServiceOffering', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

ObjectName = 'CasesTechDetails';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, 'case_PROperatingSystem', LN_New, 5, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, 'case_PREBBNetworkStatus', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, 'case_ProblemType', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, 'case_ProblemNote', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, 'case_SolutionNote', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');

ObjectName = 'CasesStatus';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 10, 'case_Opened', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 12, 'case_OpenedBy', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 14, 'case_Closed', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 15, 'case_ClosedBy', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 16, 'case_PRClosedReason', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 20, 'case_AssignedUserId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 22, 'case_Priority', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 24, 'case_Stage', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 26, 'case_Status', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 30, 'case_PRResearchingReason', LN_New, 1, 4, RQ_NotRequired, 0, '', '', '');


// Main entity list
ObjectName = 'CasesGrid';
AddCustom_ScreenObjects(ObjectName, 'List', 'vCustomerCareWorkflowListing', 'N', 0, 'vCustomerCareWorkflowListing', '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', 'case_Opened', '', OR_Allow, '', '', 'Custom', '', '', 'PRCase/PRCustomerCare.asp', 'wkin_InstanceId', 0);
AddCustom_Lists(ObjectName, '2', 'case_ReferenceId', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '3', 'case_PrimaryCompanyId', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '4', 'case_PrimaryPersonId', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '5', 'case_AssignedUserId', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '5', 'case_Status', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '5', 'case_Stage', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '5', 'case_Closed', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '5', 'case_ProductArea', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '5', 'case_Priority', '', OR_Allow, '', '', '', '', '', '', '', 0);



////////////////////////////////////////////////////////////////////////
// *********************************************************************
// CLASSIFICATION START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'Classification';
var EntityCaption = 'Classification';
var EntityCaptionPlural = 'Classifications';
var ColPrefix = 'prcl';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'Name';

// ------> CREATE SCREENS
// Search screen
ObjectName = 'ClassificationSearchBox';

AddCustom_ScreenObjects(ObjectName, 'SearchScreen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, NameField, LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'Level', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'Level1Parent', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'Description', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'Abbreviation', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 6, ColPrefix + '_' + 'SpanishDescription', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');

// Main entity new screen
ObjectName = 'ClassificationNewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, NameField, LN_New, 1, 2, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'Level', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'Level1Parent', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'Description', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'Abbreviation', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 6, ColPrefix + '_' + 'SpanishDescription', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');

// ------> CREATE LISTS
// Main entity list
ObjectName = EntityName + 'Grid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', NameField, '', '', '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '2', ColPrefix + '_' + 'Level', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '3', ColPrefix + '_' + 'Level1Parent', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '4', ColPrefix + '_' + 'Description', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '5', ColPrefix + '_' + 'Abbreviation', '', OR_Allow, '', '', '', '', '', '', '', 0);

// Main entity Detail list
ObjectName = EntityName + 'DetailGrid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', NameField, '', '', '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '2', ColPrefix + '_' + 'Level', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '3', ColPrefix + '_' + 'Level1Parent', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '4', ColPrefix + '_' + 'Description', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '5', ColPrefix + '_' + 'Abbreviation', '', OR_Allow, '', '', '', '', '', '', '', 0);

// ------> CREATE TABS
// Create the tab group
AddCustom_ScreenObjects(EntityName, 'TabGroup', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

// Create the tabs
AddCustom_Tabs('0', '0', '10', EntityName, 'Summary', 'customfile', EntityName + '/' + EntityName + 'Summary.asp', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// COMMODITY START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'Commodity';
var EntityCaption = 'Commodity';
var EntityCaptionPlural = 'Commodities';
var ColPrefix = 'prcm';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'Name';

// ------> CREATE SCREENS
// Search screen
ObjectName = EntityName + 'SearchBox';

AddCustom_ScreenObjects(EntityName + 'SearchBox', 'SearchScreen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, NameField, LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'Alias', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'IPDFlag', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// Main entity new screen
ObjectName = EntityName + 'NewEntry';

AddCustom_ScreenObjects(EntityName + 'NewEntry', 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, NameField, LN_New, 1, 2, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'Alias', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'IPDFlag', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// ------> CREATE LISTS
// Main entity list
ObjectName = EntityName + 'Grid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', NameField, '', '', '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '2', ColPrefix + '_' + 'Alias', '', OR_Allow, '', '', '', '', '', '', '', 0);
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
// COMMUNICATION START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var EntityName = 'Communication';

ObjectName = 'CommunicationList';
AddCustom_Lists(ObjectName, '80', 'Comm_PRCategory', '', OR_Allow, '', 'CENTER', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '90', 'Comm_PRSubCategory', '', OR_Allow, '', 'CENTER', '', '', '', '', '', 0);

// make some manual changes to the native communication listing...
AddCustom_Data('Custom_Lists', 'grip', 'grip_GridPropsId', 'grip_GridName,grip_colname,grip_DeviceId,grip_Deleted','CommunicationList,comm_secterr, ISNULL,1', '1,2,3')
// and the territory filter item
AddCustom_Data('Custom_Screens', 'seap', 'seap_SearchEntryPropsId', 'seap_SearchBoxName,seap_colname,seap_DeviceId,seap_Deleted','CommunicationFilterBox,comm_secterr, ISNULL,1', '1,2,3')
// and the territory entry/summary screen item
AddCustom_Data('Custom_Screens', 'seap', 'seap_SearchEntryPropsId', 'seap_SearchBoxName,seap_colname,seap_DeviceId,seap_Deleted','CustomCommunicationDetailBox,comm_secterr, ISNULL,1', '1,2,3')

// changes have already been made to this native accpac screen during PRCo installation; 1) all seap_orders
// were multiplied by 20 to give us room to work; 2) comm_Note was given a rowspan value of 3 to account for 
// PRCategory and PRSubcategory being added here.
ObjectName = 'CustomCommunicationDetailBox';
AddCustom_Screens(ObjectName, 25, 'comm_PRCallAttemptCount', LN_Same, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 30, 'comm_PRCategory', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 36, 'comm_PRSubcategory', LN_Same, 1, 2, RQ_NotRequired, 0, '', '', '');


// RSH 10/11/06 - add Category & Subcategory to standard filter box
AddCustom_Screens(EntityName + 'FilterBox', 5, 'comm_PRCategory', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(EntityName + 'FilterBox', 6, 'comm_PRSubcategory', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');


////////////////////////////////////////////////////////////////////////
// *********************************************************************
// COMMUNICATIONS LINK
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var EntityName = 'Comm_Link';
var ColPrefix = 'cmli';

// ------> CREATE SCREENS
// Summary and add new screen
ObjectName = 'CommLinkSummary';
// set up the custom screen captions
AddCustom_Captions('Tags', 'ColNames', 'comm_Attn', 0, 'ATTN', '', '', '', '', '', '');
AddCustom_Captions('Tags', 'ColNames', 'comm_CompanyName', 0, 'Company', '', '', '', '', '', '');
AddCustom_Captions('Tags', 'ColNames', 'comm_AddressLine1', 0, 'Address', '', '', '', '', '', '');
AddCustom_Captions('Tags', 'ColNames', 'comm_CityStateZip', 0, 'City/State/ZIP', '', '', '', '', '', '');
AddCustom_Captions('Tags', 'ColNames', 'comm_EmailFax', 0, 'Email/Fax', '', '', '', '', '', '');

AddCustom_ScreenObjects(ObjectName, 'Screen', 'Comm_Link', 'N', 0, 'vPRCommunication', '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, 'cmli_comm_CompanyId', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, 'cmli_comm_PersonId', LN_Same, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 20, 'comm_Attn', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 21, 'comm_Action', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 30, 'comm_CompanyName', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 40, 'comm_AddressLine1', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 50, 'comm_CityStateZip', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 60, 'comm_EmailFax', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');


// ------> DEFINE CAPTIONS
pcg_UpdateCaption("Tags", "Button", "QuickNewTask", '"New Quick Interaction"');
pcg_UpdateCaption("Tags", "Button", "AddTask", '"Quick Interaction"');
pcg_UpdateCaption("Tags", "Button", "Task", "Interaction");
pcg_UpdateCaption("Tags", "Button", "NewTask", '"New Interaction"');
pcg_UpdateCaption("Tags", "Button", "DBCompletedTask", '"Record Completed Interaction"');
pcg_UpdateCaption("Tags", "Button", "DBScheduleTask", '"Schedule Interaction"');
pcg_UpdateCaption("Tags", "GenCaptions", "NewTask", '"New Interaction"');
pcg_UpdateCaption("Tags", "GenCaptions", "Communication", "Interaction");
pcg_UpdateCaption("Tags", "GenCaptions", "Communications", "Interactions");
pcg_UpdateCaption("Tags", "GenCaptions", '"Create Followup"', '"Create Followup Interaction"');
pcg_UpdateCaption("Tags", "GenCaptions", "CreateComm", '"Create Interaction"');
pcg_UpdateCaption("Tags", "ActionCreateTask", "WkAc_EmailBcc", '"Label for new interaction"');
pcg_UpdateCaption("Tags", "WkAc_Action", "comm", '"Create Interaction"');
pcg_UpdateCaption("Tags", "FindHead", "Communication", '"Find Interaction"');
pcg_UpdateCaption("Tags", "TabNames", "Communication", "Interaction");
pcg_UpdateCaption("Tags", "TabNames", "Communications", "Interactions");
pcg_UpdateCaption("Tags", "ColNames", "libr_communicationId", "Interaction");
pcg_UpdateCaption("tags", "email", "Seeattachedemail", '"Please see the attached E-mail interaction"');
pcg_UpdateCaption("Tags", "Ecommunicati", "Name", '"Interactions"');
pcg_UpdateCaption("Tags", "Ecommunicati", "RecordsFound", '"Interactions"');
pcg_UpdateCaption("Tags", "Ecommunicati", "NoRecordsFound", '"No Interactions"');

AddCustom_Captions('Choices', 'Comm_Action', 'Note', 0, "Internal Note", '', '', '', '', '', '');
pcg_UpdateCaption("Choices", "TabNames", "NewTask", '"Enter new interaction"');
pcg_UpdateCaption("Choices", "TabNames", "Communication", "Interaction");
pcg_UpdateCaption("Choices", "TabNames", "Task", "Interaction");
pcg_UpdateCaption("Choices", "TabNames", "Communications", "Interactions");
pcg_UpdateCaption("Choices", "TabNames", "NewCommunication", '"New Interaction"');
pcg_UpdateCaption("Choices", "TabNames", "ChangeComm", '"Edit Interaction"');
pcg_UpdateCaption("Choices", "TabNames", "NewComm", '"Enter new interaction"');
pcg_UpdateCaption("Choices", "TabNames", "NewRelated_communication", '"New related interaction"');

pcg_UpdateCaption("Choices", "GenCaptions", "ClickAddBtnForAddingTask", '"Quick Interaction"');
pcg_UpdateCaption("Choices", "Entities", "Communication", "Interaction");
pcg_UpdateCaption("Choices", "Libr_Entity", "communication", "Interaction");
pcg_UpdateCaption("Choices", "TablePrefixes", "Comm", "Interaction");
pcg_UpdateCaption("Choices", "Tables", "Communication", "Interaction");
pcg_UpdateCaption("Choices", "ColJump", "Communication", "Interaction");

pcg_UpdateCaption("Errors", "Errors", "ErrCommSecurity", '"You do not have security acces to view this Interaction"');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// CREDIT SHEET ITEM START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'CreditSheet';
var EntityCaption = 'C/S Item';
var EntityCaptionPlural = 'C/S Items';
var ColPrefix = 'prcs';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'Change';

// ------> CREATE SCREENS
// Search screen
ObjectName = EntityName + 'SearchBox';

AddCustom_ScreenObjects(ObjectName, 'SearchScreen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
// the following two fields are defined in TradeReport but are useful in creating a datae range for 
// searching/filtering so we'll reuse them here
AddCustom_Screens(ObjectName, 2, '_StartDate', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, '_EndDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');


// PRCompanyCSListing is the main listing result grid for the Credit Sheet Item from the company pages
ObjectName = 'PRCompanyCSListing';
AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, 'vPRCreditSheet', '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', 'prcs_CreatedDate', '', OR_Allow, '', '', 'Custom', '', '', 'PRCreditSheet/PRCreditSheet.asp', IdField, 0);
AddCustom_Lists(ObjectName, '2', 'prcs_PublishableDate', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '2', 'prcs_AuthorId', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '3', 'prcs_SourceType', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '10', 'prcs_Status', '', OR_Allow, '', '', '', '', '', '', '', 0);

// PRCompanyCSListing is the main listing result grid for the Credit Sheet Item from the CRM pages
ObjectName = 'PRCRMCSListing';
AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, 'vPRCreditSheet', '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', 'prcs_CreatedDate', '', OR_Allow, '', '', 'Custom', '', '', 'PRCreditSheet/PRCreditSheet.asp', IdField, 0);
AddCustom_Lists(ObjectName, '3', 'prcs_SourceType', '', OR_Allow, '', '', '', '', '', '', '', 0);
//AddCustom_Lists(ObjectName, '4', 'comp_CompanyId', '', OR_Allow, '', '', 'Custom', '', '', 'PRCompany/PRCompanySummary.asp', 'comp_companyid', 0);
AddCustom_Lists(ObjectName, '7', 'comp_Name', '', OR_Allow, '', '', 'Custom', '', '', 'PRCompany/PRCompanySummary.asp', 'comp_companyid', 0);
AddCustom_Lists(ObjectName, '8', 'prci_City', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '9', 'prst_State', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '13', 'comp_PRType', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '17', 'prcs_Status', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '20', 'comp_PRListingStatus', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '26', 'prci_ListingSpecialistId', '', OR_Allow, '', '', 'Custom', '', '', 'PRPerson/PRPerson.asp', 'prci_ListingSpecialistId', 0);
AddCustom_Lists(ObjectName, '30', 'prcs_ApproverId', '', OR_Allow, '', '', '', '', '', '', '', 0);



// Main entity new screen
ObjectName = 'PRCreditSheetHeader';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
ReadOnly = "ReadOnly = true;";
Hidden = "Hidden = true;";
// CompanyId is required; it is editable for New PersonEvent CS Items; we will add this manually
//AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'CompanyId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', Hidden);
// Source is a ReadOnly Field that will be populated manually as a hyperlink to the source
//AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'TransactionId', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'Status', LN_New, 1, 1, RQ_NotRequired, 0, '', '', ReadOnly);
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'PublishableDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', ReadOnly);
AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'AuthorId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', ReadOnly);
AddCustom_Screens(ObjectName, 6, ColPrefix + '_' + 'ApproverId', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', ReadOnly);
AddCustom_Screens(ObjectName, 7, ColPrefix + '_' + 'KeyFlag', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 8, ColPrefix + '_' + 'AuthorNotes', LN_New, 1, 3, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 9, ColPrefix + '_' + 'ListingSpecialistNotes', LN_New, 1, 3, RQ_NotRequired, 0, '', '', '');

// Classic screen
ObjectName = EntityName + 'Classic';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'Tradestyle', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'CityID', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'Numeral', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'Parenthetical', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'Change', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 6, ColPrefix + '_' + 'RatingChangeVerbiage', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 7, ColPrefix + '_' + 'RatingValue', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 8, ColPrefix + '_' + 'PreviousRatingValue', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 9, ColPrefix + '_' + 'Notes', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');

// Status screen 
ObjectName = EntityName + 'PublishingStatus'; 

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', ''); 
CreateScript = "ReadOnly = true;"; 
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'ExpressUpdatePubDate', LN_New, 1, 1, RQ_NotRequired, 0, '', '', ReadOnly);
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'WeeklyCSPubDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', ReadOnly);
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'EBBUpdatePubDate', LN_New, 1, 1, RQ_NotRequired, 0, '', '', ReadOnly);
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'AUSDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', ReadOnly); 


// ------> CREATE TABS
// Create the tab group
AddCustom_ScreenObjects(EntityName, 'TabGroup', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

// Create the tabs
AddCustom_Tabs('0', '0', '10', EntityName, 'Summary', 'customfile', EntityName + '/' + EntityName + 'Summary.asp', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// DEAL START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'Deal';
var EntityCaption = 'Deal';
var EntityCaptionPlural = 'Deals';
var ColPrefix = 'prde';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'StartDate';

// ------> CREATE SCREENS
// Search screen
ObjectName = EntityName + 'SearchBox';

AddCustom_ScreenObjects(ObjectName, 'SearchScreen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'StartDate', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'EndDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// Main entity new screen
ObjectName = EntityName + 'NewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'StartDate', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'EndDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// ------> CREATE LISTS
// Main entity list
ObjectName = EntityName + 'Grid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', ColPrefix + '_' + 'StartDate', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '2', ColPrefix + '_' + 'EndDate', '', OR_Allow, '', '', '', '', '', '', '', 0);

// ------> CREATE TABS
// Create the tab group
AddCustom_ScreenObjects(EntityName, 'TabGroup', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

// Create the tabs
AddCustom_Tabs('0', '0', '10', EntityName, 'Summary', 'customfile', EntityName + '/' + EntityName + 'Summary.asp', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// DEAL COMMODITY START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'DealCommodity';
var EntityCaption = 'Deal Commodity';
var EntityCaptionPlural = 'Deals Commodities';
var ColPrefix = 'prdc';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'CommodityNumber';

// ------> CREATE SCREENS
// Main entity new screen
ObjectName = EntityName + 'NewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
CreateScript = "ReadOnly = true;";
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'DealId', LN_New, 1, 1, RQ_Required, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'CommodityNumber', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// ------> CREATE LISTS
// Main entity list
ObjectName = EntityName + 'Grid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', ColPrefix + '_' + 'CommodityNumber', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// DEAL TERRITORY START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'DealTerritory';
var EntityCaption = 'Deal Territory';
var EntityCaptionPlural = 'Deals Territories';
var ColPrefix = 'prdt';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'SalesTerritory';

// ------> CREATE SCREENS
// Main entity new screen
ObjectName = EntityName + 'NewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
CreateScript = "ReadOnly = true;";
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'DealId', LN_New, 1, 1, RQ_Required, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'SalesTerritory', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// ------> CREATE LISTS
// Main entity list
ObjectName = EntityName + 'Grid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', ColPrefix + '_' + 'SalesTerritory', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// DESCRIPTIVE LINE START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'DescriptiveLine';
var EntityCaption = 'Descriptive Line';
var EntityCaptionPlural = 'Descriptive Lines';
var ColPrefix = 'prdl';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'LineContent';

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// DOMESTIC REGION START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'DomesticRegion';
var EntityCaption = 'Domestic Region';
var EntityCaptionPlural = 'Domestic Region';
var ColPrefix = 'prd2';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'Name';

// ------> CREATE SCREENS
// Search screen
ObjectName = EntityName + 'SearchBox';

AddCustom_ScreenObjects(ObjectName, 'SearchScreen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'Name', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'Level', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'ParentId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

// Main entity new screen
ObjectName = EntityName + 'NewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'Name', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'Level', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'ParentId', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// ------> CREATE LISTS
// Main entity list
ObjectName = EntityName + 'Grid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', ColPrefix + '_' + 'Name', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '2', ColPrefix + '_' + 'Level', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '3', ColPrefix + '_' + 'ParentId', '', OR_Allow, '', '', '', '', '', '', '', 0);

// ------> CREATE TABS
// Create the tab group
AddCustom_ScreenObjects(EntityName, 'TabGroup', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

// Create the tabs
AddCustom_Tabs('0', '0', '10', EntityName, 'Summary', 'customfile', EntityName + '/' + EntityName + 'Summary.asp', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// DRC LICENSE START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'DRCLicense';
var EntityCaption = 'DRC License';
var EntityCaptionPlural = 'DRC Licenses';
var ColPrefix = 'prdr';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'LicenseNumber';

// ------> CREATE SCREENS
// Search screen
ObjectName = EntityName + 'NewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

CreateScript = 'ReadOnly = true;';
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'CompanyId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'LicenseNumber', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'MemberName', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 6, ColPrefix + '_' + 'Publish', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 10, ColPrefix + '_' + 'Salutation', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 12, ColPrefix + '_' + 'ContactFirstAndMiddleName', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 14, ColPrefix + '_' + 'ContactLastName', LN_Same, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 20, ColPrefix + '_' + 'ContactJobTitle', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 24, ColPrefix + '_' + 'BusinessType', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 30, ColPrefix + '_' + 'Address', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 40, ColPrefix + '_' + 'City', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 42, ColPrefix + '_' + 'State', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 44, ColPrefix + '_' + 'PostalCode', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 46, ColPrefix + '_' + 'Country', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 50, ColPrefix + '_' + 'Address2', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 60, ColPrefix + '_' + 'City2', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 62, ColPrefix + '_' + 'State2', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 64, ColPrefix + '_' + 'PostalCode2', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 66, ColPrefix + '_' + 'Country2', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 70, ColPrefix + '_' + 'Phone', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 72, ColPrefix + '_' + 'Fax', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 80, ColPrefix + '_' + 'CoverageDate', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 82, ColPrefix + '_' + 'PaidToDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 84, ColPrefix + '_' + 'LicenseStatus', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// ------> CREATE TABS
// Create the tab group
AddCustom_ScreenObjects(EntityName, 'TabGroup', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

// Create the tabs
AddCustom_Tabs('0', '0', '10', EntityName, 'Summary', 'customfile', EntityName + '/' + EntityName + 'Summary.asp', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

AddCustom_Tabs('0', '0', '180', 'Find', 'DRC License Import Validation', 'customfile', 'PRDRCLicense/PRDRCLicenseImportValidation.aspx', '', 'PRDRCLicenseImportValidation.gif', 0);  

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// EMAIL START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var EntityName = 'Email';
var ColPrefix = 'emai';

// ------> CREATE SCREENS
// new screen
ObjectName = 'EmailNewEntry';
//AddCustom_Captions('Tags', 'ColNames', 'emai_PRDefault', 0, 'Default', '', '', '', '', '', '');

AddCustom_ScreenObjects(ObjectName, 'Screen', 'Email', 'N', 0, 'Email', '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, 'emai_Type', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, 'emai_EmailAddress', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, 'emai_PRWebAddress', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 20, 'emai_PRDefault', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 21, 'emai_PRPublish', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 30, 'emai_PRDescription', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
CreateScript = 'ReadOnly = true;';
AddCustom_Screens(ObjectName, 31, 'emai_PRSlot', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 32, 'emai_PRSequence', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);

// ------> CREATE LISTS
// Email list
ObjectName = 'PREmailGrid';

AddCustom_ScreenObjects(ObjectName, 'List', 'Email', 'N', 0, 'Email', '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', 'emai_Type', '', OR_Allow, '', '', 'Custom', '', '', 'PRGeneral/PREmail.asp', 'emai_EmailId', 0);
AddCustom_Lists(ObjectName, '2', 'emai_EmailAddress', '', OR_Allow, '', '', 'Custom', '', '', 'PRGeneral/PREmail.asp', 'emai_EmailId', 0);
AddCustom_Lists(ObjectName, '3', 'emai_PRWebAddress', '', OR_Allow, '', '', 'Custom', '', '', 'PRGeneral/PREmail.asp', 'emai_EmailId', 0);
AddCustom_Lists(ObjectName, '4', 'emai_PRDescription', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '5', 'emai_PRDefault', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '6', 'emai_PRPublish', '', OR_Allow, '', '', '', '', '', '', '', 0);

// ------> DEFINE CAPTIONS
// Main entity search results
AddCustom_Captions('Tags', 'Email', 'NoRecordsFound', 0, 'No Email', '', '', '', '', '', '');
AddCustom_Captions('Tags', 'Email', 'RecordsFound', 0, 'Email', '', '', '', '', '', '');
AddCustom_Captions('Tags', 'Email', 'RecordFound', 0, 'Email', '', '', '', '', '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// EXCEPTION QUEUE START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'ExceptionQueue';
var EntityCaption = 'Exception';
var EntityCaptionPlural = 'Exceptions';
var ColPrefix = 'preq';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = 'preq_Date';

CreateScript = 'ReadOnly = true;';
ObjectName = 'PRExceptionQueueSummary';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, 'PRExceptionQueue', '', '', '', '', '', '');
//AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'ExceptionQueueId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'CompanyId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 21, ColPrefix + '_' + 'Status', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 22, ColPrefix + '_' + 'AssignedUserId', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 23, ColPrefix + '_' + 'Type', LN_New, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 24, ColPrefix + '_' + 'Date', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 25, ColPrefix + '_' + 'DateClosed', LN_New, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 26, ColPrefix + '_' + 'ClosedById', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 27, ColPrefix + '_' + 'RatingLine', LN_New, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 28, ColPrefix + '_' + 'BluebookScoreDisplay', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
//AddCustom_Screens(ObjectName, 29, ColPrefix + '_' + 'TradeReportId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 41, ColPrefix + '_' + 'NumTradeReports3Months', LN_New, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 42, ColPrefix + '_' + 'NumTradeReports6Months', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 43, ColPrefix + '_' + 'NumTradeReports12Months', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 44, ColPrefix + '_' + 'ThreeMonthIntegrityRating', LN_New, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 45, ColPrefix + '_' + 'ThreeMonthPayRating', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);


// ------> CREATE SCREENS
// new screen
ObjectName = 'PRExceptionQueueCompany';

CreateScript = 'ReadOnly = true;';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'CompanyId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'Rating', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'BBScore', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// screen
ObjectName = 'PRExceptionQueueException';

CreateScript = 'ReadOnly = true;';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 21, ColPrefix + '_' + 'Type', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 22, ColPrefix + '_' + 'Date', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 23, ColPrefix + '_' + 'Status', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 24, ColPrefix + '_' + 'TradeReportId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 25, ColPrefix + '_' + 'ARAgingId', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 26, ColPrefix + '_' + 'AssignedUserId', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 27, ColPrefix + '_' + 'DateClosed', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 28, ColPrefix + '_' + 'ClosedById', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// screen
ObjectName = 'PRExceptionQueueTrade';

CreateScript = 'ReadOnly = true;';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 41, ColPrefix + '_' + 'ThreeMonthIntegrityRating', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 42, ColPrefix + '_' + 'ThreeMonthPayRating', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 43, ColPrefix + '_' + 'NumTradeReports3Months', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 44, ColPrefix + '_' + 'NumTradeReports6Months', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 45, ColPrefix + '_' + 'NumTradeReports12Months', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// ------> CREATE LISTS
// My CRM list
ObjectName = EntityName + 'UserGrid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', ColPrefix + '_' + 'Date', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '2', ColPrefix + '_' + 'CompanyId', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '3', ColPrefix + '_' + 'City', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '4', ColPrefix + '_' + 'State', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '5', ColPrefix + '_' + 'HQ', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '6', ColPrefix + '_' + 'Rating', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '7', ColPrefix + '_' + 'BBScore', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '8', ColPrefix + '_' + 'Type', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '9', ColPrefix + '_' + 'Status', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);


// set up the custom column headers
AddCustom_Captions('Tags', 'ColNames', 'preq_TypeName', 0, 'Type', '', '', '', '', '', '');
AddCustom_Captions('Tags', 'ColNames', 'preq_AssignedUser', 0, 'Assigned User', '', '', '', '', '', '');
AddCustom_Captions('Tags', 'ColNames', 'preq_BBScoreDisplay', 0, 'BB<br>Score', '', '', '', '', '', '');

// Team CRM list
ObjectName = EntityName + 'Grid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, 'vExceptionQueue', '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', ColPrefix + '_' + 'Date', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + '.asp', IdField, 0);
AddCustom_Lists(ObjectName, '2', ColPrefix + '_' + 'CompanyId', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + '.asp', IdField, 0);
AddCustom_Lists(ObjectName, '3', 'prci_City', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '6', ColPrefix + '_' + 'RatingLine', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '7', 'preq_BBScoreDisplay', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '8', 'preq_TypeName', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '9', ColPrefix + '_' + 'Status', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '10', 'preq_AssignedUser', '', OR_Allow, '', '', '', '', '', '', '', 0);

// Create a filter for use on the Exception Queue screens
// The EntityName value will not matter; we just use this screen to capture the 
// criteria then we pass the values to the database call
ObjectName = 'ExceptionQueueFilterBox';
AddCustom_ScreenObjects(ObjectName, 'SearchScreen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, 'preq_CompanyId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, 'preq_AssignedUserId', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, '_StartDate', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, '_EndDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, 'preq_Type', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 6, 'preq_Status', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');


// ------> CREATE TABS
// Create the tab group
AddCustom_ScreenObjects(EntityName, 'TabGroup', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

// Create the tabs
AddCustom_Tabs('0', '0', '10', EntityName, 'Summary', 'customfile', EntityName + '/' + EntityName + 'Summary.asp', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// FILE START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'File';
var EntityCaption = 'SS File';
var EntityCaptionPlural = 'SS Files';
var ColPrefix = 'prfi';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'FileId';


// ------> CREATE SCREENS
// Search screen
ObjectName = 'PRFileSearchBox';
AddCustom_ScreenObjects(ObjectName, 'SearchScreen', 'vPRFileWorkflowListing', 'N', 0, 'vPRFileWorkflowListing', '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, 'wkin_CurrentRecordId', LN_New, 1, 3, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 11, '_StartDate', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 12, '_EndDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 16, 'prfi_AssignedUserId', LN_Same, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 20, 'prfi_Status', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 22, 'prfi_Stage', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 24, 'prfi_Type', LN_Same, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 34, 'prfi_Company1Id', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 35, 'prfi_Company2Id', LN_Same, 1, 2, RQ_NotRequired, 0, '', '', '');


ObjectName = 'PRFileWorkflowGrid';
AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, 'vPRFileWorkflowListing', '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', 'prfi_FileId', '', OR_Allow, '', '', 'Custom', '', '', 'PRFile/PRFile.asp', 'wkin_InstanceID', 0);
AddCustom_Lists(ObjectName, '3', 'prfi_CreatedDate', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '5', 'prfi_Status', '', OR_Allow, '', 'CENTER', 'Custom', 'Y', '', 'PRFile/PRFile.asp', 'wkin_InstanceID', 0);
AddCustom_Lists(ObjectName, '10', 'prfi_Company1Id', '', OR_Allow, '', '', 'Custom', '', '', 'PRCompany/PRCompanySummary.asp', 'prfi_company1id', 0);
AddCustom_Lists(ObjectName, '15', 'prfi_Company2Id', '', OR_Allow, '', '', 'Custom', '', '', 'PRCompany/PRCompanySummary.asp', 'prfi_company2id', 0);
AddCustom_Lists(ObjectName, '30', 'prfi_Type', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '50', 'prfi_Stage', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '60', 'prfi_AssignedUserId', '', OR_Allow, '', '', '', '', '', '', '', 0);




// Main entity new screen
ObjectName = 'PRFileHeader';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, 'prfi_FileId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, 'prfi_Type', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 6, 'prfi_Status', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 10, 'prfi_IssueDescription', LN_New, 1, 3, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 21, 'prfi_Topic', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 26, 'prfi_InquirySource', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 28, 'prfi_InitialCallDuration', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 30, 'prfi_AssignedUserId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 50, 'prfi_ClosingDate', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 55, 'prfi_ClosingReason', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

ObjectName = 'PRFilePartySummary';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'Company1Id', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'Company1Contact1Id', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 10, ColPrefix + '_' + 'Company2Id', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 15, ColPrefix + '_' + 'Company2Contact1Id', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 20, ColPrefix + '_' + 'Company3Id', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 25, ColPrefix + '_' + 'Company3Contact1Id', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');


// screen
ObjectName = 'PRFileCreditorInfo';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'Company1Id', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 10, ColPrefix + '_' + 'Company1Contact1Id', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 12, ColPrefix + '_' + 'Company1Contact2Id', LN_Same, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 20, ColPrefix + '_' + 'Company1Contact1Address', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 24, ColPrefix + '_' + 'Company1Contact2Address', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 26, ColPrefix + '_' + 'Company1Contact1CityStateZip', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 27, ColPrefix + '_' + 'Company1Contact2CityStateZip', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 30, ColPrefix + '_' + 'Company1Contact1Telephone', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 34, ColPrefix + '_' + 'Company1Contact2Telephone', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 52, ColPrefix + '_' + 'Company1Contact1Email', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 56, ColPrefix + '_' + 'Company1Contact2Email', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 101, ColPrefix + '_' + 'RepresentingCompany1Id', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 102, ColPrefix + '_' + 'RepresentingCompany1Name', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 113, ColPrefix + '_' + 'RepresentingCompany1Address', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 115, ColPrefix + '_' + 'RepresentingCompany1Telephone', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 124, ColPrefix + '_' + 'RepresentingCompany1CityStateZip', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 127, ColPrefix + '_' + 'RepresentingCompany1Email', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 138, ColPrefix + '_' + 'RepresentingCompany1PersonId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 140, ColPrefix + '_' + 'RepresentingCompany1PersonSigned', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 141, ColPrefix + '_' + 'RepresentingCompany1PersonSigDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 150, ColPrefix + '_' + 'RepresentingCompany1Info', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');

// User Filter screen
ObjectName = 'PRFileDebtorInfo';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'Company2Id', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 10, ColPrefix + '_' + 'Company2Contact1Id', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 12, ColPrefix + '_' + 'Company2Contact2Id', LN_Same, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 20, ColPrefix + '_' + 'Company2Contact1Address', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 24, ColPrefix + '_' + 'Company2Contact2Address', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 26, ColPrefix + '_' + 'Company2Contact1CityStateZip', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 27, ColPrefix + '_' + 'Company2Contact2CityStateZip', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 30, ColPrefix + '_' + 'Company2Contact1Telephone', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 34, ColPrefix + '_' + 'Company2Contact2Telephone', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 52, ColPrefix + '_' + 'Company2Contact1Email', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 56, ColPrefix + '_' + 'Company2Contact2Email', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 101, ColPrefix + '_' + 'RepresentingCompany2Id', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 102, ColPrefix + '_' + 'RepresentingCompany2Name', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 113, ColPrefix + '_' + 'RepresentingCompany2Address', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 115, ColPrefix + '_' + 'RepresentingCompany2Telephone', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 124, ColPrefix + '_' + 'RepresentingCompany2CityStateZip', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 127, ColPrefix + '_' + 'RepresentingCompany2Email', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 138, ColPrefix + '_' + 'RepresentingCompany2PersonId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 140, ColPrefix + '_' + 'RepresentingCompany2PersonSigned', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 141, ColPrefix + '_' + 'RepresentingCompany2PersonSigDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 150, ColPrefix + '_' + 'RepresentingCompany2Info', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');

ObjectName = 'PRFileThirdPartyInfo';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'Company3Id', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 10, ColPrefix + '_' + 'Company3Contact1Id', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 12, ColPrefix + '_' + 'Company3Contact2Id', LN_Same, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 20, ColPrefix + '_' + 'Company3Contact1Address', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 24, ColPrefix + '_' + 'Company3Contact2Address', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 26, ColPrefix + '_' + 'Company3Contact1CityStateZip', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 27, ColPrefix + '_' + 'Company3Contact2CityStateZip', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 30, ColPrefix + '_' + 'Company3Contact1Telephone', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 34, ColPrefix + '_' + 'Company3Contact2Telephone', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 52, ColPrefix + '_' + 'Company3Contact1Email', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 56, ColPrefix + '_' + 'Company3Contact2Email', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 101, ColPrefix + '_' + 'RepresentingCompany3Id', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 102, ColPrefix + '_' + 'RepresentingCompany3Name', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 113, ColPrefix + '_' + 'RepresentingCompany3Address', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 115, ColPrefix + '_' + 'RepresentingCompany3Telephone', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 124, ColPrefix + '_' + 'RepresentingCompany3CityStateZip', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 127, ColPrefix + '_' + 'RepresentingCompany3Email', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 138, ColPrefix + '_' + 'RepresentingCompany3PersonId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 140, ColPrefix + '_' + 'RepresentingCompany3PersonSigned', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 141, ColPrefix + '_' + 'RepresentingCompany3PersonSigDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 150, ColPrefix + '_' + 'RepresentingCompany3Info', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');

// Initial File Info Block
ObjectName = 'PRFileCollectionInitialInfo';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 0, 'prfi_InitialAmountOwed', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, 'prfi_InvoiceNumber', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 10, 'prfi_AmountCreditorReceived', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 14, 'prfi_OldestInvoiceDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 20, 'prfi_AmountStillOwing', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 24, 'prfi_Terms', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
//AddCustom_Screens(ObjectName, 51, 'prfi_TotalNumberInvoices', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 30, 'prfi_CreditorCollectedReason', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 34, 'prfi_DueDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 40, 'prfi_DateA1LetterSent', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 42, 'prfi_PACADeadline', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 60, 'prfi_TrustProtection', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 70, 'prfi_AmountPRCoInvoiced', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');

ObjectName = 'PRFileOpinionInfo';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 0, 'prfi_OpinionFeeLetterSentDate', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, 'prfi_OpinionFeeAuthorizedDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 6, 'prfi_OpinionLetterSentDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

ObjectName = 'PRFileDisputeInfo';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 0, 'prfi_SettlementAmount', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, 'prfi_DisputeFeeLetterSentDate', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, 'prfi_DisputeFeeAuthorizedDate', LN_Same, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 10, 'prfi_DisputeRequestLetterDate', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 14, 'prfi_DisputeRequestDueDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 16, 'prfi_DisputeRequestResponseDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 20, 'prfi_DisputeRequestLetterDate2', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 24, 'prfi_DisputeRequestDueDate2', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 26, 'prfi_DisputeRequestResponseDate2', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
// Adding 56/57 Letter Info divider here
AddCustom_Screens(ObjectName, 35, 'prfi_5657LetterType', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 42, 'prfi_5657WarningSentDate', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 43, 'prfi_5657WarningDueDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 44, 'prfi_5657WarningResponseDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 52, 'prfi_5657ReportSentDate', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 53, 'prfi_5657ReportDueDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 54, 'prfi_5657ReportResponseDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// Formal Collection Stage
ObjectName = 'PRFileCollectionFormal';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, 'prfi_CollectionSubCategory', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, 'prfi_5657LetterType', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 10, 'prfi_PRCoFormallyCollectingAmount', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 11, 'prfi_5657WarningSentDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 20, 'prfi_PRCoCollectedAmount', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 21, 'prfi_5657WarningDueDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 30, 'prfi_PRCoStillCollectingAmount', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 31, 'prfi_5657WarningResponseDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 40, 'prfi_DateAcceptanceLetterSent', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 41, 'prfi_5657ReportSentDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 50, 'prfi_DateAcceptanceLetterRcvd', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 51, 'prfi_5657ReportDueDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 60, 'prfi_DateConfirmedPaymentRcvd', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 61, 'prfi_5657ReportResponseDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// PLAN Info
ObjectName = 'PRFilePLANInfo';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, 'prfi_PLANDateAcceptanceLetterSent', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 10, 'prfi_PLANDateAcceptanceLetterRcvd', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 20, 'prfi_PLANDateFileMailed', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 30, 'prfi_PLANPartnerUsed', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 40, 'prfi_PLANFileNumber', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');


// User Filter screen
ObjectName = 'PRFileUserFilterBox';

AddCustom_ScreenObjects(ObjectName, 'SearchScreen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'FileId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'CompanyId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'BBId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'DRCNumber', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'StartDate', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 6, ColPrefix + '_' + 'EndDate', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 7, ColPrefix + '_' + 'Status', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 8, ColPrefix + '_' + 'Type', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

// Channel Filter screen
ObjectName = 'PRFileChannelFilterBox';

AddCustom_ScreenObjects(ObjectName, 'SearchScreen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'FileId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'CompanyId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'BBId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'DRCNumber', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'StartDate', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 6, ColPrefix + '_' + 'EndDate', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 7, ColPrefix + '_' + 'Status', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 8, ColPrefix + '_' + 'Type', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 8, ColPrefix + '_' + 'AssignedUserId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

// Company Filter screen
ObjectName = 'PRFileCompanyFilterBox';

AddCustom_ScreenObjects(ObjectName, 'SearchScreen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'FileId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 7, ColPrefix + '_' + 'Status', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 8, ColPrefix + '_' + 'Type', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 8, ColPrefix + '_' + 'ClaimantCreditor', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 8, ColPrefix + '_' + 'RespondentDebtor', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

// ------> CREATE LISTS
// Main entity list
ObjectName = EntityName + 'Grid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, 'vPRFileWorkflowListing', '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', ColPrefix + '_' + 'FileId', '', OR_Allow, '', '', 'Custom', '', '', 'PRFile/PRFile.asp', 'wkin_InstanceID', 0);
AddCustom_Lists(ObjectName, '2', ColPrefix + '_' + 'Type', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '4', ColPrefix + '_' + 'IssueDescription', '', OR_Allow, '', '', 'Custom', '', '', 'PRFile/PRFile.asp', IdField, 0);
AddCustom_Lists(ObjectName, '5', ColPrefix + '_' + 'Company1Id', '', OR_Allow, '', '', 'Company', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '6', ColPrefix + '_' + 'Company2Id', '', OR_Allow, '', '', 'Company', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '7', ColPrefix + '_' + 'AssignedUserId', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '8', 'wkst_Name', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '9', ColPrefix + '_' + 'Status', '', OR_Allow, '', '', '', '', '', '', '', 0);

// My CRM list
ObjectName = EntityName + 'UserGrid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', ColPrefix + '_' + 'FileId', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '2', ColPrefix + '_' + 'Type', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '3', ColPrefix + '_' + 'NODDate', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '4', ColPrefix + '_' + 'IssueDescription', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '5', ColPrefix + '_' + 'Company1Id', '', OR_Allow, '', '', 'Company', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '6', ColPrefix + '_' + 'Company2Id', '', OR_Allow, '', '', 'Company', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '7', ColPrefix + '_' + 'Stage', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '8', ColPrefix + '_' + 'Status', '', OR_Allow, '', '', '', '', '', '', '', 0);

// Team CRM list
ObjectName = EntityName + 'ChannelGrid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', ColPrefix + '_' + 'FileId', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '2', ColPrefix + '_' + 'Type', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '3', ColPrefix + '_' + 'NODDate', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '4', ColPrefix + '_' + 'IssueDescription', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '5', ColPrefix + '_' + 'Company1Id', '', OR_Allow, '', '', 'Company', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '6', ColPrefix + '_' + 'Company2Id', '', OR_Allow, '', '', 'Company', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '7', ColPrefix + '_' + 'AssignedUserId', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '8', ColPrefix + '_' + 'Stage', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '9', ColPrefix + '_' + 'Status', '', OR_Allow, '', '', '', '', '', '', '', 0);

// Company list
ObjectName = 'PRCompanyFileGrid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, 'vPRFileWorkflowListing', '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', ColPrefix + '_' + 'FileId', '', OR_Allow, '', '', 'Custom', '', '', 'PRFile/PRFile.asp', 'wkin_InstanceID', 0);
AddCustom_Lists(ObjectName, '2', ColPrefix + '_' + 'Type', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '4', ColPrefix + '_' + 'IssueDescription', '', OR_Allow, '', '', 'Custom', '', '', 'PRFile/PRFile.asp', IdField, 0);
AddCustom_Lists(ObjectName, '5', ColPrefix + '_' + 'Company1Id', '', OR_Allow, '', '', 'Company', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '6', ColPrefix + '_' + 'Company2Id', '', OR_Allow, '', '', 'Company', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '7', ColPrefix + '_' + 'AssignedUserId', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '8', 'wkst_Name', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '9', ColPrefix + '_' + 'Status', '', OR_Allow, '', '', '', '', '', '', '', 0);

// ------> CREATE TABS
// Create the tab group
AddCustom_ScreenObjects(EntityName, 'TabGroup', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

// Create the tabs
AddCustom_Tabs('0', '0', '10', EntityName, 'Summary', 'customfile', 'PRFile/PRFile.asp', '', '', 0);
AddCustom_Tabs('0', '0', '50', EntityName, 'Interactions', 'customfile', EntityName + '/' + EntityName + 'Interaction.asp', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// FILE PAYMENT START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'FilePayment';
var EntityCaption = 'Payment';
var EntityCaptionPlural = 'Payments';
var ColPrefix = 'prfp';

var EntityName = 'PRFilePayment';
var IdField = 'prfp_FilePaymentId';
var NameField = 'prfp_DueDate';

// ------> CREATE SCREENS
// Main entity new screen
ObjectName = 'PRFilePaymentNewEntry';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
//AddCustom_Screens(ObjectName, 1, 'prfp_FileId', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, 'prfp_DueDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, 'prfp_PaymentAmount', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 8, 'prfp_ReceivedDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// ------> CREATE LISTS
// Main entity list
ObjectName = 'PRFilePaymentGrid';
AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', 'prfp_DueDate', '', OR_Allow, '', '', 'Custom', '', '', 'PRFile/PRFilePayment.asp', IdField, 0);
AddCustom_Lists(ObjectName, '2', 'prfp_PaymentAmount', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '3', 'prfp_ReceivedDate', '', OR_Allow, '', '', '', '', '', '', '', 0);

// ------> CREATE TABS
// Create the tab group
//AddCustom_ScreenObjects(EntityName, 'TabGroup', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

// Create the tabs
//AddCustom_Tabs('0', '0', '10', EntityName, 'Summary', 'customfile', EntityName + '/' + EntityName + 'Summary.asp', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// FINANCIAL STATEMENT START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'Financial';
var EntityCaption = 'Financials';
var EntityCaptionPlural = 'Financials';
var ColPrefix = 'prfs';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'StatementDate';

// ------> CREATE SCREENS
// Header
ObjectName = EntityName + 'Header';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

CreateScript = 'ReadOnly = true;';
AddCustom_Screens(ObjectName, 10, ColPrefix + '_' + 'CompanyId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 12, ColPrefix + '_' + 'StatementDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 14, ColPrefix + '_' + 'Currency', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 16, ColPrefix + '_' + 'Type', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 20, ColPrefix + '_' + 'Analysis', LN_New, 2, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 22, ColPrefix + '_' + 'EntryStatus', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 26, ColPrefix + '_' + 'Publish', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 30, ColPrefix + '_' + 'InterimMonth', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 40, ColPrefix + '_' + 'PreparationMethod', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 42, ColPrefix + '_' + 'CreatedDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 44, ColPrefix + '_' + 'UpdatedDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 50, ColPrefix + '_' + 'Reviewed', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 52, ColPrefix + '_' + 'ReviewDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', 'ReadOnly = true;');

// Assets
ObjectName = EntityName + 'CurrentAssets';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'CashEquivalents', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'ARTrade', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'DueFromRelatedParties', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'LoansNotesReceivable', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'MarketableSecurities', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 6, ColPrefix + '_' + 'Inventory', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 7, ColPrefix + '_' + 'OtherCurrentAssets', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 8, ColPrefix + '_' + 'TotalCurrentAssets', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

// Liabilities
ObjectName = EntityName + 'CurrentLiabilities';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'AccountsPayable', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'CurrentMaturity', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'CreditLine', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'CurrentLoanPayableShldr', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'OtherCurrentLiabilities', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 6, ColPrefix + '_' + 'TotalCurrentLiabilities', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

// Fixed Assets
ObjectName = EntityName + 'FixedAssets';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'Property', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'LeaseholdImprovements', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'OtherFixedAssets', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'AccumulatedDepreciation', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'NetFixedAssets', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

// Long Term Liabilities
ObjectName = EntityName + 'LTLiabilities';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'LongTermDebt', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'LoansNotesPayableShldr', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'OtherLongLiabilities', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'TotalLongLiabilities', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

// Other Assets
ObjectName = EntityName + 'OtherAssets';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'OtherLoansNotesReceivable', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'Goodwill', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'OtherMiscAssets', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'TotalOtherAssets', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

// Other Liabilities
ObjectName = EntityName + 'OtherLiabilities';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'OtherMiscLiabilities', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');


// Other Equity
ObjectName = EntityName + 'OtherEquity';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'OtherEquity', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');


// Totals
ObjectName = EntityName + 'Totals';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'RetainedEarnings', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'TotalEquity', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'TotalAssets', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'WorkingCapital', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

// The following fields all pertain to the Left side of the Income Statment
ObjectName = EntityName + 'IncomeStatementLeft';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'Sales', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'CostGoodsSold', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'GrossProfitMargin', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'OperatingExpenses', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'OperatingIncome', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 6, ColPrefix + '_' + 'InterestIncome', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 7, ColPrefix + '_' + 'OtherIncome', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 8, ColPrefix + '_' + 'ExtraordinaryGainLoss', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 9, ColPrefix + '_' + 'InterestExpense', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 10, ColPrefix + '_' + 'OtherExpenses', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 11, ColPrefix + '_' + 'TaxProvision', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 12, ColPrefix + '_' + 'NetIncome', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

// Sales
ObjectName = EntityName + 'Sales';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'Sales', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'CostGoodsSold', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'GrossProfitMargin', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

// Expenses
ObjectName = EntityName + 'Expenses';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'OperatingExpenses', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'OperatingIncome', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

// Misc
ObjectName = EntityName + 'Misc';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'InterestIncome', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'OtherIncome', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'ExtraordinaryGainLoss', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'InterestExpense', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'OtherExpenses', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 6, ColPrefix + '_' + 'TaxProvision', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

// Net
ObjectName = EntityName + 'Net';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'NetIncome', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

// Depreciation
ObjectName = EntityName + 'Depreciation';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'Depreciation', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'Amortization', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

// Ratio
ObjectName = EntityName + 'Ratio';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'CurrentRatio', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'QuickRatio', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'ARTurnover', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'DaysPayableOutstanding', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'DebtToEquity', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 6, ColPrefix + '_' + 'FixedAssetsToNetWorth', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 7, ColPrefix + '_' + 'DebtServiceAbility', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 8, ColPrefix + '_' + 'OperatingRatio', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 8, ColPrefix + '_' + 'ZScore', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

// ------> CREATE LISTS
// Main entity list
ObjectName = EntityName + 'Grid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', ColPrefix + '_' + 'StatementDate', '', OR_Allow, '', '', 'Custom', '', '', 'PRFinancial/PRFinancialSummary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '2', ColPrefix + '_' + 'Currency', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '3', ColPrefix + '_' + 'Type', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '4', ColPrefix + '_' + 'Publish', '', OR_Allow, '', '', '', '', '', '', '', 0);

// ------> CREATE TABS
// Create the tab group
AddCustom_ScreenObjects(EntityName, 'TabGroup', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

// Create the tabs
AddCustom_Tabs('0', '0', '10', EntityName, 'Summary', 'customfile', EntityName + '/' + EntityName + 'Summary.asp', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// FINANCIAL STATEMENT DETAIL START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'FinancialDetail';
var EntityCaption = 'Detail';
var EntityCaptionPlural = 'Details';
var ColPrefix = 'prfd';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'FieldName';

// ------> CREATE SCREENS
// Search screen
ObjectName = 'PRFinancialDetailHeader';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

CreateScript = 'ReadOnly = true;';
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'FinancialId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'FieldName', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// Search screen
ObjectName = 'PRFinancialDetailLine';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'Description', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'Amount', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// GENERAL INFORMATION START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'GeneralInformation';
var EntityCaption = 'General Information';
var EntityCaptionPlural = 'General Information';
var ColPrefix = 'prgi';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'Content';

// ------> CREATE SCREENS
// Main entity new screen
ObjectName = EntityName + 'NewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'Content', LN_New, 1, 3, RQ_Required, 0, '', '', '');

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// LIBRARY START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var EntityName = 'Library';
var ColPrefix = 'libr';

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// NOTE START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
var EntityCaption = 'Note';
var EntityCaptionPlural = 'Notes';

// ------> CREATE SCREENS
ObjectName = 'PRNoteBox';
AddCustom_ScreenObjects(ObjectName, 'Screen', 'Notes', 'N', 0, 'Notes', '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, 'note_Note', LN_New, 1, 1, RQ_Required, 0, '', '', '');

// ------> CREATE LISTS
ObjectName = 'PRFileNoteList';

AddCustom_ScreenObjects(ObjectName, 'List', 'Notes', 'N', 0, 'Notes', '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', 'note_CreatedDate', '', OR_Allow, '', '', 'Custom', '', '', 'PRFile/PRFileNoteSummary.asp', 'note_NoteId', 0);
AddCustom_Lists(ObjectName, '2', 'note_CreatedBy', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '3', 'note_Note', '', OR_Allow, '', '', '', '', '', '', '', 0);

ObjectName = 'PRInvestigationNoteList';

AddCustom_ScreenObjects(ObjectName, 'List', 'Notes', 'N', 0, 'Notes', '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', 'note_CreatedDate', '', OR_Allow, '', '', 'Custom', '', '', 'PRInvestigation/PRInvestigationNoteSummary.asp', 'note_NoteId', 0);
AddCustom_Lists(ObjectName, '2', 'note_CreatedBy', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '3', 'note_Note', '', OR_Allow, '', '', '', '', '', '', '', 0);

// ------> DEFINE CAPTIONS
// Main entity search results
AddCustom_Captions('Tags', 'Notes', 'NoRecordsFound', 0, 'No ' + EntityCaptionPlural, '', '', '', '', '', '');
AddCustom_Captions('Tags', 'Notes', 'RecordsFound', 0, EntityCaptionPlural, '', '', '', '', '', '');
AddCustom_Captions('Tags', 'Notes', 'RecordFound', 0, EntityCaption, '', '', '', '', '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// BBSCORE ( formerly OPEN DATA) START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'BBScore';
var EntityCaption = 'BB Score Record';
var EntityCaptionPlural = 'BB Score Records';
var ColPrefix = 'prbs';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'BBScore';

// ------> CREATE SCREENS
// Search screen
ObjectName = EntityName + 'NewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

CreateScript = 'ReadOnly = true;';
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'CompanyId', LN_New, 1, 1, RQ_Required, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'Date', LN_Same, 1, 1, RQ_Required, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 3, ColPrefix + '_' + 'RunDate', LN_Same, 1, 1, RQ_Required, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 4, ColPrefix + '_' + 'Current', LN_Same, 1, 1, RQ_Required, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 5, ColPrefix + '_' + 'P80Surveys', LN_New, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 6, ColPrefix + '_' + 'P90Surveys', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 7, ColPrefix + '_' + 'P95Surveys', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 8, ColPrefix + '_' + 'P975Surveys', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 9, ColPrefix + '_' + 'BBScore', LN_New, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 10, ColPrefix + '_' + 'NewBBScore', LN_New, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 11, ColPrefix + '_' + 'ConfidenceScore', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 12, ColPrefix + '_' + 'Recency', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 13, ColPrefix + '_' + 'Deviation', LN_New, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 14, ColPrefix + '_' + 'SmoothedScoreDeviation', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 15, ColPrefix + '_' + 'ObservationPeriodTES', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 16, ColPrefix + '_' + 'RecentTES', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 17, ColPrefix + '_' + 'Model', LN_New, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);

// ------> CREATE LISTS
// Main entity list
ObjectName = EntityName + 'Grid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', ColPrefix + '_' + 'Date', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '2', ColPrefix + '_' + 'BBScore', '', OR_Allow, '', '', 'Custom', '', '', 'PRCompany/' + EntityName + '.asp', IdField, 0);
AddCustom_Lists(ObjectName, '3', ColPrefix + '_' + 'NewBBScore', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '4', ColPrefix + '_' + 'Deviation', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '5', ColPrefix + '_' + 'ConfidenceScore', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '6', ColPrefix + '_' + 'Recency', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '7', ColPrefix + '_' + 'ObservationPeriodTES', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '8', ColPrefix + '_' + 'RecentTES', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '9', ColPrefix + '_' + 'P975Surveys', '', OR_Allow, '', '', '', '', '', '', '', 0);

// ------> CREATE TABS
// Create the tab group
//AddCustom_ScreenObjects(EntityName, 'TabGroup', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

// Create the tabs
//AddCustom_Tabs('0', '0', '10', EntityName, 'Summary', 'customfile', EntityName + '/' + EntityName + '.asp', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// OPPORTUNITY START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var EntityName = 'Opportunity';
var ColPrefix = 'oppo';

var ShortEntityName = 'Opportunity';
//var EntityCaption = 'Opportunity';
//var EntityCaptionPlural = 'Bus Events';
var ColPrefix = 'oppo';

var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'Description';

// Search screen
ObjectName = 'PROpportunitySearchBox';
AddCustom_ScreenObjects(ObjectName, 'SearchScreen', 'vOpportunityWorkflowListing', 'N', 0, 'vOpportunityWorkflowListing', '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, '_StartDate', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, '_EndDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 6, 'oppo_AssignedUserId', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 20, 'oppo_Status', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 22, 'oppo_Stage', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 25, 'oppo_Priority', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 30, 'oppo_Type', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 34, 'oppo_PrimaryCompanyId', LN_Same, 1, 2, RQ_NotRequired, 0, '', '', '');

// ------> CREATE SCREENS
ObjectName = EntityName + 'ContactInfo';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 11, 'oppo_PrimaryCompanyId', LN_New, 1, 2, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 20, 'oppo_PrimaryPersonId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 21, 'oppo_PRPrimaryPersonRole', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 30, 'oppo_PRSecondaryPersonId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 31, 'oppo_PRSecondaryPersonRole', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

ObjectName = EntityName + 'BPDetails';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 10, 'oppo_PRAdSize', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 11, 'oppo_PRAdRun', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 20, 'oppo_PRTargetIssue', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 21, 'oppo_PRTargetYear', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 30, 'oppo_PRAdvertisingAgency', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');

ObjectName = EntityName + 'Overview';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 10, 'oppo_Note', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 11, 'oppo_Source', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');

ObjectName = 'OpportunityForecasts';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 10, 'oppo_Forecast', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 20, 'oppo_Certainty', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 30, 'oppo_UpdatedBy', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 40, 'oppo_AssignedUserId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 50, 'oppo_Priority', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 60, 'oppo_PRTeam', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 70, 'oppo_WaveItemId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

ObjectName = EntityName + 'Status';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 10, 'oppo_Opened', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 11, 'oppo_Stage', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 20, 'oppo_Closed', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 21, 'oppo_Status', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 30, 'oppo_PRLostReason', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

ObjectName = 'OpportunityWorkflowGrid';
AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, 'vPROpportunityWorkflowListing', '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', 'oppo_Opened', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '5', 'oppo_Status', '', OR_Allow, '', 'CENTER', 'Custom', 'Y', '', 'PROpportunity/PROpportunityRedirect.asp', 'wkin_InstanceID', 0);
AddCustom_Lists(ObjectName, '10', 'oppo_PrimaryCompanyId', '', OR_Allow, '', '', 'Custom', '', '', 'PRCompany/PRCompanySummary.asp', 'comp_companyid', 0);
AddCustom_Lists(ObjectName, '15', 'oppo_PrimaryPersonId', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '30', 'oppo_Type', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '40', 'oppo_PRType', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '50', 'oppo_Stage', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '60', 'oppo_AssignedUserId', '', OR_Allow, '', '', '', '', '', '', '', 0);

// Blueprints Opportunity Screen
ObjectName = 'PRBlueprintsOpportunitySummary';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

// Screen will show Status divider here
AddCustom_Screens(ObjectName, 80, 'oppo_Opened', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 82, 'oppo_Closed', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 86, 'oppo_Status', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 90, 'oppo_PRLostReason', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 100, 'oppo_SignedAuthReceivedDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
// Screen will show Contact Info divider here
AddCustom_Screens(ObjectName, 111, 'oppo_PrimaryCompanyId', LN_New, 1, 2, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 115, 'oppo_Type', LN_Same, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 120, 'oppo_PrimaryPersonId', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 121, 'oppo_PRSecondaryPersonId', LN_Same, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 130, 'oppo_PRPrimaryPersonRole', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 131, 'oppo_PRSecondaryPersonRole', LN_Same, 1, 2, RQ_NotRequired, 0, '', '', '');
// Screen will show Overview divider here
AddCustom_Screens(ObjectName, 240, 'oppo_Note', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 254, 'oppo_Source', LN_New, 1, 4, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 260, 'oppo_PRReferredByCompanyId', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 262, 'oppo_PRReferredByUserId', LN_Same, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 270, 'oppo_PRReferredByPersonId', LN_New, 1, 4, RQ_NotRequired, 0, '', '', '');
// Screen will show Forecasts/Assignments divider here
AddCustom_Screens(ObjectName, 300, 'oppo_Forecast', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 305, 'oppo_AssignedUserId', LN_Same, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 320, 'oppo_Certainty', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 325, 'oppo_PRTeam', LN_Same, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 350, 'oppo_Priority', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 350, 'oppo_TargetClose', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 355, 'oppo_WaveItemId', LN_Same, 1, 2, RQ_NotRequired, 0, '', '', '');
// Screen will show Blueprints Details divider here
AddCustom_Screens(ObjectName, 400, 'oppo_PRType', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 411, 'oppo_PRAdRun', LN_Same, 1, 3, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 420, 'oppo_PRTargetIssue', LN_New, 1, 4, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 430, 'oppo_PRAdvertisingAgency', LN_New, 1, 4, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 440, 'oppo_PRAdvertiseIn', LN_New, 1, 4, RQ_NotRequired, 0, '', '', '');

// Membership Opportunity Additions
ObjectName = 'PROpportunityMembershipSummary';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

// Screen will show Status divider here
AddCustom_Screens(ObjectName, 80, 'oppo_Opened', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 82, 'oppo_Closed', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 86, 'oppo_Status', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 90, 'oppo_PRLostReason', LN_New, 1, 4, RQ_NotRequired, 0, '', '', '');
// Screen will show Contact Info divider here
AddCustom_Screens(ObjectName, 111, 'oppo_PrimaryCompanyId', LN_New, 1, 2, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 115, 'oppo_Type', LN_Same, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 120, 'oppo_PrimaryPersonId', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 121, 'oppo_PRSecondaryPersonId', LN_Same, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 130, 'oppo_PRPrimaryPersonRole', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 131, 'oppo_PRSecondaryPersonRole', LN_Same, 1, 2, RQ_NotRequired, 0, '', '', '');
// Screen will show Overview divider here
AddCustom_Screens(ObjectName, 240, 'oppo_Note', LN_New, 2, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 250, 'oppo_PRType', LN_Same, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 254, 'oppo_Source', LN_New, 1, 4, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 260, 'oppo_PRReferredByCompanyId', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 262, 'oppo_PRReferredByUserId', LN_Same, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 270, 'oppo_PRReferredByPersonId', LN_New, 1, 4, RQ_NotRequired, 0, '', '', '');
// Screen will show Forecasts/Assignments divider here
AddCustom_Screens(ObjectName, 300, 'oppo_Forecast', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 305, 'oppo_AssignedUserId', LN_Same, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 320, 'oppo_Certainty', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 325, 'oppo_PRTeam', LN_Same, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 350, 'oppo_Priority', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 350, 'oppo_TargetClose', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 355, 'oppo_WaveItemId', LN_Same, 1, 2, RQ_NotRequired, 0, '', '', '');

// *********************************************************************
// OWNERSHIP START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'Ownership';
var EntityCaption = 'Ownership Info';
var EntityCaptionPlural = 'Ownership Info';
var ColPrefix = 'prow';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'CompanyId';

// ------> CREATE SCREENS
// Company
ObjectName = EntityName + 'Company';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'Company1Ownership', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

// Person
ObjectName = EntityName + 'Person';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'Individual1Ownership', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'Individual2Ownership', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

// Undisclosed
ObjectName = EntityName + 'Undisclosed';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'UnattributedOwnerDesc', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'UnattributedOwnerPct', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// Total
ObjectName = EntityName + 'Total';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'Total', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// PHONE START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var EntityName = 'Phone';
var ColPrefix = 'phon';

// ------> CREATE SCREENS
// new screen
ObjectName = 'PhoneNewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', 'vPRPhone', 'N', 0, 'Phone', '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 1, 'Phon_Type', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 2, 'Phon_Default', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 3, 'Phon_PRPublish', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 20, 'Phon_CountryCode', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 21, 'Phon_AreaCode', LN_Same, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 22, 'Phon_Number', LN_Same, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 23, 'Phon_PRExtension', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 30, 'Phon_PRDescription', LN_New, 1, 4, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 31, 'Phon_PRDisconnected', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
CreateScript = 'ReadOnly = true;';
AddCustom_Screens(ObjectName, 32, 'Phon_PRSlot', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 33, 'Phon_PRSequence', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);

// ------> CREATE LISTS
// Company Phone list
ObjectName = 'CompanyPhoneGrid';
AddCustom_Captions('Tags', 'ColNames', 'Phon_TypeDisplay', 0, 'Type', '', '', '', '', '', '');

AddCustom_ScreenObjects(ObjectName, 'List', 'Phone', 'N', 0, 'vPRPhone', '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', 'Phon_TypeDisplay', '', OR_Allow, '', '', 'Custom', '', '', 'PRCompany/PRCompanyPhone.asp', 'Phon_PhoneId', 0);
AddCustom_Lists(ObjectName, '2', 'Phon_FullNumber', '', OR_Allow, '', '', 'Custom', '', '', 'PRCompany/PRCompanyPhone.asp', 'Phon_PhoneId', 0);
AddCustom_Lists(ObjectName, '3', 'Phon_PRDescription', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '4', 'Phon_Default', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '5', 'Phon_PRPublish', '', OR_Allow, '', '', '', '', '', '', '', 0);

// Person Phone list
ObjectName = 'PersonPhoneGrid';

AddCustom_ScreenObjects(ObjectName, 'List', 'Phone', 'N', 0, 'vPRPhone', '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', 'Phon_TypeDisplay', '', OR_Allow, '', '', 'Custom', '', '', 'PRPerson/PRPersonPhone.asp', 'Phon_PhoneId', 0);
AddCustom_Lists(ObjectName, '2', 'Phon_FullNumber', '', OR_Allow, '', '', 'Custom', '', '', 'PRPerson/PRPersonPhone.asp', 'Phon_PhoneId', 0);
AddCustom_Lists(ObjectName, '3', 'Phon_PRDescription', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '4', 'Phon_Default', '', OR_Allow, '', '', '', '', '', '', '', 0);
//AddCustom_Lists(ObjectName, '5', 'Phon_PRPublish', '', OR_Allow, '', '', '', '', '', '', '', 0);


// ------> DEFINE CAPTIONS
// Main entity search results
AddCustom_Captions('Tags', 'Phone', 'NoRecordsFound', 0, 'No Phones', '', '', '', '', '', '');
AddCustom_Captions('Tags', 'Phone', 'RecordsFound', 0, 'Phones', '', '', '', '', '', '');
AddCustom_Captions('Tags', 'Phone', 'RecordFound', 0, 'Phone', '', '', '', '', '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// SERVICE START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'Service';
var EntityCaption = 'Service';
var EntityCaptionPlural = 'Services';
var ColPrefix = 'prse';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'ServiceCode';

// ------> CREATE SCREENS
// Main entity new screen
ObjectName = 'PRServiceNewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

CreateScript = 'ReadOnly = true;';
//AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'CompanyId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 20, ColPrefix + '_' + 'ServiceCode', LN_New, 1, 1, RQ_Required, 0, '', '', '');
AddCustom_Screens(ObjectName, 21, ColPrefix + '_' + 'ServiceSubCode', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 22, ColPrefix + '_' + 'Primary', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 23, ColPrefix + '_' + 'CodeStartDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 40, ColPrefix + '_' + 'NextAnniversaryDate', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 42, ColPrefix + '_' + 'CodeEndDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 43, ColPrefix + '_' + 'StopServiceDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 50, ColPrefix + '_' + 'CancelCode', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 51, ColPrefix + '_' + 'ServiceSinceDate', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 52, ColPrefix + '_' + 'InitiatedBy', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 62, ColPrefix + '_' + 'BillToCompanyId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 63, ColPrefix + '_' + 'Terms', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 70, ColPrefix + '_' + 'HoldShipmentId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 71, ColPrefix + '_' + 'HoldMailId', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 72, ColPrefix + '_' + 'EBBSerialNumber', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 73, ColPrefix + '_' + 'ContractStatus', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 80, ColPrefix + '_' + 'DeliveryMethod', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 81, ColPrefix + '_' + 'ReferenceNumber', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 90, ColPrefix + '_' + 'ShipmentDate', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 91, ColPrefix + '_' + 'ShipmentDescription', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');


// ------> CREATE LISTS
// Company list
ObjectName = 'PRServiceGrid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
//AddCustom_Lists(ObjectName, '1', ColPrefix + '_' + 'ServiceId', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '2', ColPrefix + '_' + 'ServiceCode', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '3', ColPrefix + '_' + 'ServiceSubCode', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '3', ColPrefix + '_' + 'Primary', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '4', ColPrefix + '_' + 'CodeStartDate', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '5', ColPrefix + '_' + 'NextAnniversaryDate', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '6', ColPrefix + '_' + 'StopServiceDate', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '7', ColPrefix + '_' + 'CancelCode', '', OR_Allow, '', '', 'Custom', '', '', EntityName + '/' + EntityName + 'Summary.asp', IdField, 0);

// ------> CREATE TABS
// Create the tab group
AddCustom_ScreenObjects(EntityName, 'TabGroup', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

// Create the tabs
AddCustom_Tabs('0', '0', '10', EntityName, 'Summary', 'customfile', EntityName + '/' + EntityName + 'Summary.asp', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// SERVICE PAYMENT START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'ServicePayment';
var EntityCaption = 'Payment';
var EntityCaptionPlural = 'Payments';
var ColPrefix = 'prsp';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'InvoiceDate';

// ------> CREATE LISTS
// Company list
ObjectName = 'PRServicePaymentGrid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', ColPrefix + '_' + 'MasterInvoiceNumber', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '2', ColPrefix + '_' + 'InvoiceDate', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '3', ColPrefix + '_' + 'BilledAmount', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '4', ColPrefix + '_' + 'ReceivedAmount', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '4', ColPrefix + '_' + 'TransactionDate', '', OR_Allow, '', '', '', '', '', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// SERVICE UNIT START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'ServiceUnit';
var EntityCaption = 'Units';
var EntityCaptionPlural = 'Units';
var ColPrefix = 'prun';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'Units';

// ------> CREATE SCREENS
// Main entity new screen
ObjectName = 'PRServiceUnitNewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

CreateScript = 'ReadOnly = true;';
//AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'CompanyId', LN_New, 1, 1, RQ_Required, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'Units', LN_Same, 1, 2, RQ_Required, 0, '', '', '');

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// SERVICE UNIT USAGE 
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'ServiceUnitUsage';
var EntityCaption = 'Purchase';
var EntityCaptionPlural = 'Purchases';
var ColPrefix = 'prsuu';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'RegardingObjectId';

// create a summary listing of the combined ServiceUnit and BusinessReportRequest fields
var ObjectName = 'PRServiceUnitUsageSummary';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, 'vPRServiceUnitUsage', '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 10, 'prsuu_CompanyId', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 11, 'prsuu_PersonId', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 12, 'prsuu_Units', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 20, 'prsuu_CreatedDate', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 21, 'prsuu_SourceCode', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 22, 'prsuu_TransactionTypeCode', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 23, 'prsuu_UsageTypeCode', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 30, 'prsuu_SearchCriteria', LN_New, 1, 4, RQ_NotRequired, 0, '', '', '');
// we will place a divider here in code
AddCustom_Screens(ObjectName, 40, 'prbr_RequestorInfo', LN_New, 1, 4, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 50, 'prbr_AddressLine1', LN_New, 1, 4, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 60, 'prbr_AddressLine1', LN_New, 1, 4, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 70, 'prbr_CityStateZip', LN_New, 1, 2, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 71, 'prbr_Country', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 80, 'prbr_Fax', LN_New, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 81, 'prbr_EmailAddress', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');
AddCustom_Screens(ObjectName, 90, 'prbr_DoNotChargeUnits', LN_New, 1, 4, RQ_NotRequired, 0, '', '', '');

// Create a screen specifically for the reversals
var ObjectName = 'PRServiceUnitUsageReversal';
AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, 'PRServiceUnitUsage', '', '', '', '', '', '');
AddCustom_Screens(ObjectName, 30, 'prsuu_ReversalReasonCode', LN_New, 1, 4, RQ_NotRequired, 0, '', '', '');


// Create a listing screen
// set up some custom field captions
AddCustom_Captions('Tags', 'ColNames', 'prsuu_RequestedBBID', 0, 'BBID', '', '', '', '', '', '');
AddCustom_Captions('Tags', 'ColNames', 'prsuu_IsReversal', 0, 'Reversal', '', '', '', '', '', '');

var ObjectName = 'PRServiceUnitUsageGrid';
AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, 'vPRServiceUnitUsage', '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', 'prsuu_PersonId', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '2', 'prsuu_CreatedDate', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '3', 'prsuu_UsageTypeCode', '', OR_Allow, '', '', 'Custom', '', '', 'PRCompany/PRCompanyServiceUnitUsage.asp', IdField, 0);
AddCustom_Lists(ObjectName, '4', 'prsuu_RequestedBBID', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '5', 'prbr_RequestedCompanyId', '', OR_Allow, '', '', 'Custom', '', '', 'PRCompany/PRCompanySummary.asp', 'comp_companyId', 0);
AddCustom_Lists(ObjectName, '6', 'prsuu_IsReversal', '', OR_Allow, '', '', '', '', '', '', '', 0);
AddCustom_Lists(ObjectName, '7', 'prsuu_Units', '', OR_Allow, '', '', '', '', '', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

////////////////////////////////////////////////////////////////////////
// *********************************************************************
// WATCHDOG START
// *********************************************************************
////////////////////////////////////////////////////////////////////////
// ------> SET ENTITY ATTRIBUTES
var ShortEntityName = 'Watchdog';
var EntityCaption = 'Watch Company';
var EntityCaptionPlural = 'Watch Companies';
var ColPrefix = 'prwa';

var EntityName = ClientId + ShortEntityName;
var IdField = ColPrefix + '_' + ShortEntityName + 'Id';
var NameField = ColPrefix + '_' + 'CompanyId';

// ------> CREATE SCREENS
// Main entity new screen
ObjectName = EntityName + 'NewEntry';

AddCustom_ScreenObjects(ObjectName, 'Screen', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
CreateScript = "ReadOnly = true;";
AddCustom_Screens(ObjectName, 1, ColPrefix + '_' + 'CompanyId', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', CreateScript);
AddCustom_Screens(ObjectName, 2, ColPrefix + '_' + 'WatchCompanyId', LN_Same, 1, 1, RQ_NotRequired, 0, '', '', '');

// ------> CREATE LIST
// Main entity list
ObjectName = EntityName + 'Grid';

AddCustom_ScreenObjects(ObjectName, 'List', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');
AddCustom_Lists(ObjectName, '1', ColPrefix + '_' + 'CompanyId', '', OR_Allow, '', '', 'Custom', '', '', 'PRCompany/CompanySummary.asp', IdField, 0);
AddCustom_Lists(ObjectName, '2', ColPrefix + '_' + 'WatchCompanyId', '', OR_Allow, '', '', 'Custom', '', '', 'PRCompany/CompanySummary.asp', IdField, 0);

// ------> CREATE TABS
// Create the tab group
AddCustom_ScreenObjects(EntityName, 'TabGroup', EntityName, 'N', 0, EntityName, '', '', '', '', '', '');

// Create the tabs
AddCustom_Tabs('0', '0', '10', EntityName, 'Summary', 'customfile', EntityName + '/' + EntityName + 'Summary.asp', '', '', 0);

// ------> DEFINE CAPTIONS
DefineCaptions(EntityName, EntityCaption, EntityCaptionPlural, NameField, IdField, '', '');

// Add BB Score Import to Find dropdown
AddCustom_Tabs('0', '0', '160', 'Find', 'Import BB Scores', 'customfile', 'PRTES/PRBBScoreImportRedirect.asp', '', 'PRBBScoreImport.gif', 0);

// Add TES Form Batch / Export to Find dropdown
AddCustom_Tabs('0', '0', '170', 'Find', 'TES Form Batch / Export', 'customfile', 'PRTES/PRTESFormBatchView.aspx', '', 'PRTESFormBatchView.gif', 0);
// Add Credit Sheet Export to Find dropdwon  
AddCustom_Tabs('0', '0', '180', 'Find', 'Credit Sheet Export', 'customfile', 'PRCreditSheet/PRCreditSheetExportRedirect.asp', '', 'PRCreditSheetExport.gif', 0);  