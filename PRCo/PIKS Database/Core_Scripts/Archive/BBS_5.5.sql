EXEC usp_AccpacDropField 'Cases', 'case_PRCompanyITRep'
EXEC usp_AccpacDropField 'Cases', 'case_PRCallDuration'
EXEC usp_AccpacDropField 'Cases', 'case_PRServiceOffering'
EXEC usp_AccpacDropField 'Cases', 'case_PROperatingSystem'
EXEC usp_AccpacDropField 'Cases', 'case_PREBBNetworkStatus'
EXEC usp_AccpacDropField 'Cases', 'case_PRResearchingReason'
EXEC usp_AccpacDropField 'Cases', 'case_PRClosedReason'

EXEC usp_DeleteCustom_Caption null, 'case_PRServiceOffering'
EXEC usp_DeleteCustom_Caption null, 'case_PROperatingSystem'
EXEC usp_DeleteCustom_Caption null, 'case_PREBBNetworkStatus'
EXEC usp_DeleteCustom_Caption null, 'case_PRResearchingReason'
EXEC usp_DeleteCustom_Caption null, 'case_PRClosedReason'
EXEC usp_DeleteCustom_Caption null, 'case_PRPriority'
EXEC usp_DeleteCustom_Caption null, 'case_ProductArea'
EXEC usp_DeleteCustom_Caption null, 'case_ProblemType'
EXEC usp_DeleteCustom_Caption null, 'case_PRStage'


EXEC usp_AccpacCreateTextField 'Cases', 'case_PRAltContactName', 'Alternate Contact Name', 100, 100
EXEC usp_AccpacCreateTextField 'Cases', 'case_PRMasterInvoiceNumber', 'Master Invoice Number', 20, 20


UPDATE Custom_Tabs
   SET Tabs_CustomFileName = 'PRCase/PRCaseSummary.asp'
 WHERE Tabs_CustomFileName like '%PRCustomerCare.asp%';

--select * from custom_captions where capt_family = 'Case_Status'
--select * from custom_captions where capt_family = 'Case_Priority'
SELECT * FROM Channel

DECLARE @ChannelID int, @ID int

EXEC usp_GetNextId 'Channel', @ChannelID output
INSERT INTO Channel VALUES (@ChannelID, 'Collections', null, null, -1, GETDATE(), -1, GETDATE(), GETDATE(), NULL);


EXEC usp_GetNextId 'Channel_Link', @ID output
INSERT INTO Channel_Link VALUES (@ID, @ChannelID, 1019, null, -1, GETDATE(), -1, GETDATE(), GETDATE(), NULL);

EXEC usp_GetNextId 'Channel_Link', @ID output
INSERT INTO Channel_Link VALUES (@ID, @ChannelID, 43, null, -1, GETDATE(), -1, GETDATE(), GETDATE(), NULL);

EXEC usp_GetNextId 'Channel_Link', @ID output
INSERT INTO Channel_Link VALUES (@ID, @ChannelID, 1027, null, -1, GETDATE(), -1, GETDATE(), GETDATE(), NULL);

SELECT @ChannelID As [Collections Channel ID]

EXEC usp_DeleteCustom_ScreenObject 'PRCasesGrid'
EXEC usp_AddCustom_ScreenObjects 'PRCasesGrid', 'List', 'Cases', 'N', 0, 'vPRCaseListing'
EXEC usp_AddCustom_Lists 'PRCasesGrid', 10, 'comp_Name', null, 'Y', null, null, 'custom', null, null, 'PRCompany/PRCompanySummary.asp', 'comp_CompanyID'
EXEC usp_AddCustom_Lists 'PRCasesGrid', 20, 'prci_City', null, 'Y'
EXEC usp_AddCustom_Lists 'PRCasesGrid', 30, 'prst_Abbreviation', null, 'Y'
EXEC usp_AddCustom_Lists 'PRCasesGrid', 40, 'prsp_InvoiceDate', null, 'Y'
EXEC usp_AddCustom_Lists 'PRCasesGrid', 50, 'TotalDue', null, 'Y', null, 'right', 'custom', null, null, 'PRCase/PRCaseSummary.asp', 'case_caseID'
EXEC usp_AddCustom_Lists 'PRCasesGrid', 60, 'case_Priority', null, 'Y'
EXEC usp_AddCustom_Lists 'PRCasesGrid', 70, 'LastContactDate', null, 'Y', null, 'center'
EXEC usp_AddCustom_Lists 'PRCasesGrid', 80, 'case_Status', null, 'Y'
EXEC usp_AddCustom_Lists 'PRCasesGrid', 90, 'prra_RatingLine'




EXEC usp_DefineCaptions 'Cases', 'Case', 'Cases', NULL, NULL, NULL, NULL

EXEC usp_AddCustom_ScreenObjects 'PRCasesFilter', 'SearchScreen', 'Cases', 'N', 0, 'vPRCaseListing'
EXEC usp_AddCustom_Screens 'PRCasesFilter', 10, 'prsp_InvoiceDate', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCasesFilter', 20, 'LastContactDate', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCasesFilter', 30, 'XXXorBetterRated', 0, 2, 1, 0
EXEC usp_AddCustom_Screens 'PRCasesFilter', 40, 'case_Status', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCasesFilter', 50, 'case_Priority', 0, 1, 1, 0



EXEC usp_AccpacCreateField @EntityName = 'Cases', 
                           @FieldName = 'XXXorBetterRated', 
                           @Caption = 'Rated XXX or Better',
                           @AccpacEntryType = 45,
                           @AccpacEntrySize = 0,
                           @IsRequired = 'N', 
                           @SkipColumnCreation = 'Y';


EXEC usp_AccpacCreateField @EntityName = 'Cases', 
                           @FieldName = 'LastContactDate', 
                           @Caption = 'Last Contact Date',
                           @AccpacEntryType = 42,
                           @AccpacEntrySize = 0,
                           @IsRequired = 'N', 
                           @SkipColumnCreation = 'Y';
                           
                           



EXEC usp_AddCustom_ScreenObjects 'PRCaseCompanyInfo', 'Screen', 'Cases', 'N', 0, 'vPRCaseCompanyInfo'
--EXEC usp_AddCustom_Screens 'PRCaseCompanyInfo', 10, 'Case_PrimaryCompanyId', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCaseCompanyInfo', 20, 'Case_PrimaryPersonId', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCaseCompanyInfo', 30, 'case_PRAltContactName', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCaseCompanyInfo', 40, 'prra_RatingLine', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCaseCompanyInfo', 50, 'Case_AssignedUserId', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCaseCompanyInfo', 60, 'Case_Status', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCaseCompanyInfo', 70, 'Case_Priority', 0, 1, 1, 0



EXEC usp_AddCustom_ScreenObjects 'PRCaseInvoiceInfo', 'Screen', 'Cases', 'N', 0, 'vPRCaseInvoiceInfo'
EXEC usp_AddCustom_Screens 'PRCaseInvoiceInfo', 10, 'case_PRMasterInvoiceNumber', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCaseInvoiceInfo', 20, 'BBOSUserCount', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCaseInvoiceInfo', 30, 'TotalDue', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCaseInvoiceInfo', 40, 'LastBBOSUse', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCaseInvoiceInfo', 50, 'prsp_InvoiceDate', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCaseInvoiceInfo', 60, 'LastContactDate', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCaseInvoiceInfo', 70, 'DaysSinceInvoice', 0, 1, 1, 0
      
      
EXEC usp_AddCustom_Captions 'Tags', 'ColNames', 'BBOSUserCount', 0, 'BBOS User Count'
EXEC usp_AddCustom_Captions 'Tags', 'ColNames', 'TotalDue', 0, 'Total Due'
EXEC usp_AddCustom_Captions 'Tags', 'ColNames', 'LastBBOSUse', 0, 'Last BBOS Use'
EXEC usp_AddCustom_Captions 'Tags', 'ColNames', 'DaysSinceInvoice', 0, 'Days Since Invoice'
      
      
EXEC usp_AddCustom_ScreenObjects 'PRCaseServicesGrid', 'List', 'vPRCaseServiceInfo', 'N', 0, 'vPRCaseServiceInfo'
EXEC usp_AddCustom_Lists 'PRCaseServicesGrid', 10, 'prse_ServiceID', null, 'Y'
EXEC usp_AddCustom_Lists 'PRCaseServicesGrid', 20, 'prse_ServiceCode', null, 'Y'
EXEC usp_AddCustom_Lists 'PRCaseServicesGrid', 30, 'prsp_BilledAmount', null, 'Y'
EXEC usp_AddCustom_Lists 'PRCaseServicesGrid', 40, 'BalanceDue', null, 'Y'

EXEC usp_DefineCaptions 'vPRCaseServiceInfo', 'Service', 'Services', NULL, NULL, NULL, NULL      
EXEC usp_AddCustom_Captions 'Tags', 'ColNames', 'BalanceDue', 0, 'Balance Due'                           

EXEC usp_AddCustom_ScreenObjects 'PRCaseSummary', 'Screen', 'Cases', 'N', 0, 'Cases'
EXEC usp_AddCustom_Screens 'PRCaseSummary', 10, 'Case_PrimaryCompanyId', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCaseSummary', 20, 'Case_PrimaryPersonId', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCaseSummary', 30, 'case_PRAltContactName', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCaseSummary', 40, 'case_PRMasterInvoiceNumber', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCaseSummary', 50, 'Case_AssignedUserId', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCaseSummary', 60, 'Case_Status', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCaseSummary', 70, 'Case_Priority', 0, 1, 1, 0

UPDATE Custom_ScreenObjects
   SET Cobj_CustomContent = '<script language=javascript src="../CustomPages/PRCoGeneral.js"></script><script language=javascript src="../CustomPages/PRCase/PRCaseSummary.js"></script><script language=javascript>document.write(new String( location.href ));RedirectCase();</script>'
 WHERE CObj_Name = 'CaseDetailBox';
Go


EXEC usp_AccpacCreateCheckboxField  'PRAdCampaign', 'pradc_AlwaysDisplay', 'Always Display'
EXEC usp_AccpacCreateIntegerField	'PRAdCampaign', 'pradc_TopSpotCount', 'Top Spot Count', 10

ALTER TABLE PRAdCampaignMirror ADD pradc_AlwaysDisplay int
ALTER TABLE PRAdCampaignMirror ADD pradc_TopSpotCount varchar(1)

EXEC usp_AddCustom_Screens 'PRAdCampaignNewEntry', 55, 'pradc_AlwaysDisplay', 0, 1, 1, 0
Go

EXEC usp_AccpacCreateTextField 'PRCompanyBank', 'prcb_Country', 'Country', 50, 50
UPDATE Custom_Screens
   SET seap_Order = (seap_Order * 10)
 WHERE seap_SearchBoxName = 'PRCompanyBankNewEntry'

EXEC usp_AddCustom_Screens 'PRCompanyBankNewEntry', 85, 'prcb_Country', 1, 1, 1, 0
Go

UPDATE Custom_Captions
   SET capt_us = '% sold to International Importers',
   capt_uk = '% sold to International Importers',
   capt_fr = '% sold to International Importers',
   capt_de = '% sold to International Importers',
   capt_es = '% sold to International Importers'
 WHERE Capt_Code = 'prcp_SellExportersPct'
 Go
 
 EXEC usp_AddCustom_Tabs 17, 'find', 'Import Third Party News', 'customfile', 'PRGeneral/ImportThirdPartyNewsRedirect.asp', null, 'Quote.gif'
 Go
 
 
 EXEC usp_AccpacCreateTextField 'PRCreditSheet', 'prcs_ItemText', 'Item Text', 500, 8000;
 Go
 
 
 EXEC usp_AccpacCreateCheckboxField  'Company', 'comp_PRHideLinkedInWidget', 'Don''t Display Linked-In Widget'
 Go
 
 EXEC usp_AccpacCreateSelectField @EntityName_In = 'PRTradeReport',	
								 @FieldName_In = 'prtr_HighCreditL',
								 @Caption_In = 'High Credit',
								 @LookupFamily_In = 'prtr_HighCreditL',
								 @SkipColumnCreation_In = 'Y';
UPDATE Custom_Lists SET GriP_Order = GriP_Order * 10  WHERE GriP_GridName = 'PRTradeReportOnGrid';
EXEC usp_AddCustom_Lists 'PRTradeReportOnGrid', 91, 'prtr_HighCreditL';
Go 

EXEC usp_AccpacCreateSearchSelectField 'Opportunity', 'oppo_PRWebUserID', 'BBOS User', 'PRWebUser', 50, 'N', 'Y' 
Go