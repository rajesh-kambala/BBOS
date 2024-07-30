--9.1 Release
--Defect 7119 - ad kyc page elements AdCampaignAdKYC.asp
EXEC usp_TravantCRM_DeleteCustom_ScreenObject 'AdCampaignAdKYCDigital'
EXEC usp_TravantCRM_AddCustom_ScreenObjects 'AdCampaignAdKYCDigital', 'Screen', 'PRAdCampaign', 'N', 0, 'PRAdCampaign'
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdKYCDigital', 11, 'pradc_StartDate', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdKYCDigital', 12, 'pradc_EndDate', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdKYCDigital', 13, 'pradc_KYCMobileHomeDisplay', 0, 1, 2, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdKYCDigital', 21, 'pradc_CreativeStatus', 1, 1, 2, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdKYCDigital', 31, 'pradc_TargetURL', 1, 1, 2, 0

--Defect 7149
IF NOT EXISTS(SELECT 'x' FROM Custom_Screens WHERE SeaP_SearchBoxName='CustomCommunicationDetailBox' AND SeaP_ColName='comm_updatedby') BEGIN
	EXEC usp_TravantCRM_AddCustom_Screens 'CustomCommunicationDetailBox', 160, 'comm_updatedby', 1, 1, 1, 0
END
IF NOT EXISTS(SELECT 'x' FROM Custom_Screens WHERE SeaP_SearchBoxName='CustomCommunicationDetailBox' AND SeaP_ColName='comm_updateddate') BEGIN
	EXEC usp_TravantCRM_AddCustom_Screens 'CustomCommunicationDetailBox', 170, 'comm_updateddate', 0, 1, 1, 0
END

--Defect 7489 - Ads on Search Results page
EXEC usp_TravantCRM_DeleteCustom_ScreenObject 'AdCampaignAdDigital'
EXEC usp_TravantCRM_AddCustom_ScreenObjects 'AdCampaignAdDigital', 'Screen', 'PRAdCampaign', 'N', 0, 'PRAdCampaign'
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdDigital', 1, 'pradc_CompanyID', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdDigital', 3, 'pradc_AdCampaignHeaderID', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdDigital', 5, 'pradc_AdCampaignType', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdDigital', 10, 'pradc_Name', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdDigital', 20, 'pradc_StartDate', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdDigital', 30, 'pradc_AdCampaignTypeDigital', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdDigital', 40, 'pradc_EndDate', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdDigital', 50, 'pradc_CreativeStatus', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdDigital', 60, 'pradc_AdCampaignTypeDigitalAMEdition', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdDigital', 70, 'pradc_TargetURL', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdDigital', 80, 'pradc_AdCampaignTypeDigitalPMEdition', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdDigital', 90, 'pradc_Sequence', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdDigital', 100, 'pradc_Cost', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdDigital', 110, 'pradc_Discount', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdDigital', 120, 'pradc_IndustryType', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdDigital', 130, 'pradc_Language', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdDigital', 140, 'pradc_Notes', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdDigital', 150, 'pradc_CommodityId', 1, 1, 1, 0
Go


EXEC usp_TravantCRM_CreateDateField 'PRInvoice', 'prinv_FirstReminderDate', 'First Reminder Date Time', 'Y', 'N'
EXEC usp_TravantCRM_CreateDateField 'PRInvoice', 'prinv_SecondReminderDate', 'Second Reminder Date Time', 'Y', 'N'
Go


-- These records are created by BBOS so we use a SQL Identity
-- field for the ID.
--EXEC usp_TravantCRM_DropTable               'PRChangeQueue'
EXEC usp_TravantCRM_CreateTable             'PRChangeQueue', 'prchrq', 'prchrq_ChangeQueueID', NULL, NULL, NULL, NULL, 'Y'
EXEC usp_TravantCRM_CreateKeyField          'PRChangeQueue', 'prchrq_ChangeQueueID', 'Change Queue ID'
EXEC usp_TravantCRM_CreateSearchSelectField 'PRChangeQueue', 'prchrq_CompanyID', 'Company', 'Company', 100 
EXEC usp_TravantCRM_CreateSearchSelectField 'PRChangeQueue', 'prchrq_PersonID', 'Person', 'Person', 100 
EXEC usp_TravantCRM_CreateSearchSelectField 'PRChangeQueue', 'prchrq_WebUserID', 'PRWebUser', 'BBOS User', 100 
EXEC usp_TravantCRM_CreateIntegerField		'PRChangeQueue', 'prchrq_EntityID', 'Entity' -- Custom_Tables
EXEC usp_TravantCRM_CreateIntegerField		'PRChangeQueue', 'prchrq_RecordID', 'Entity Record ID'
EXEC usp_TravantCRM_CreateSelectField       'PRChangeQueue', 'prchrq_ActionCode', 'Action', 'prchrq_ActionCode'
EXEC usp_TravantCRM_CreateMultilineField    'PRChangeQueue', 'prchrq_Notes', 'Notes'
Go


-- These records are created by BBOS so we use a SQL Identity
-- field for the ID.
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'PRChangeQueueDetail')
BEGIN
	--EXEC usp_TravantCRM_DropTable               'PRChangeQueueDetail'
	EXEC usp_TravantCRM_CreateTable             'PRChangeQueueDetail', 'prchrqd', 'prchrqd_ChangeQueueDetailID', NULL, NULL, NULL, NULL, 'Y'
	EXEC usp_TravantCRM_CreateKeyField          'PRChangeQueueDetail', 'prchrqd_ChangeQueueDetailID', 'Change Queue Detail ID'
	EXEC usp_TravantCRM_CreateIntegerField		'PRChangeQueueDetail', 'prchrqd_ChangeQueueID', 'Change Queue ID'
	EXEC usp_TravantCRM_CreateIntegerField		'PRChangeQueueDetail', 'prchrqd_EntityID', 'Entity'-- Custom_Tables
	EXEC usp_TravantCRM_CreateIntegerField		'PRChangeQueueDetail', 'prchrqd_RecordID', 'Entity Record ID' 
	EXEC usp_TravantCRM_CreateTextField		    'PRChangeQueueDetail', 'prchrqd_FieldName', 'Entity Field Name', 50, 50
	EXEC usp_TravantCRM_CreateIntegerField		'PRChangeQueueDetail', 'prchrqd_FieldID', 'Entity Field ID'  -- Custom_Edits
	EXEC usp_TravantCRM_CreateTextField	   	    'PRChangeQueueDetail', 'prchrqd_OldValue', 'Old Value', 100, 500
	EXEC usp_TravantCRM_CreateTextField	   	    'PRChangeQueueDetail', 'prchrqd_NewValue', 'New Value', 100, 500
	EXEC usp_TravantCRM_CreateTextField	   	    'PRChangeQueueDetail', 'prchrqd_Type', 'Type', 40, 40
	EXEC usp_TravantCRM_CreateTextField	   	    'PRChangeQueueDetail', 'prchrqd_GroupCode', 'Group Code', 40, 40    
END
Go

EXEC usp_TravantCRM_DeleteCustom_List 'PRChangeQueueList'
EXEC usp_TravantCRM_AddCustom_ScreenObjects 'PRChangeQueueList', 'List', 'PRChangeQueue', 'N', 0, 'vPRChangeQueue'
EXEC usp_TravantCRM_AddCustom_Lists 'PRChangeQueueList', 10, 'prchrq_CreatedDate', null, 'Y', @Jump='customdotnetdll', @CustomAction='TravantCRM.dll', @CustomFunction='RunChangeQueueDetail', @CustomIdField='prchrq_ChangeQueueID'
EXEC usp_TravantCRM_AddCustom_Lists 'PRChangeQueueList', 20, 'prchrq_CompanyID', null, 'Y', @Jump='company'
EXEC usp_TravantCRM_AddCustom_Lists 'PRChangeQueueList', 30, 'prchrq_PersonID', null, 'Y', @Jump='person'
EXEC usp_TravantCRM_AddCustom_Lists 'PRChangeQueueList', 40, 'BBOSUserFullName', null, 'Y', @Jump='customdotnetdll', @CustomAction='TravantCRM.dll', @CustomFunction='RunRegisteredUserDetails', @CustomIdField='prchrq_WebUserID'
EXEC usp_TravantCRM_AddCustom_Lists 'PRChangeQueueList', 50, 'prchrq_ActionCode', null, 'Y'
Go

EXEC usp_TravantCRM_DeleteCustom_ScreenObject 'PRChangeSummary'
EXEC usp_TravantCRM_AddCustom_ScreenObjects  'PRChangeSummary', 'Screen', 'PRChangeQueue', 'N', 0, 'vPRChangeQueue'
EXEC usp_TravantCRM_AddCustom_Screens 'PRChangeSummary', 10, 'prchrq_CreatedDate',  1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRChangeSummary', 20, 'prchrq_CompanyID',    0, 1, 2, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRChangeSummary', 30, 'prchrq_PersonID',     1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRChangeSummary', 40, 'BBOSUserFullName', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRChangeSummary', 50, 'prchrq_ActionCode',   0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRChangeSummary', 60, 'prchrq_Notes',        1, 1, 3, 0
Go

-- This is a computed field so define the various meta-data entries
-- so that CRM is aware of it, but don't actually create it.
EXEC usp_TravantCRM_CreateField @EntityName = 'PRWebUser', 
                                @FieldName = 'BBOSUserFullName', 
                                @Caption = 'BBOS User',
                                @AccpacEntryType = 10,
                                @AccpacEntrySize = 50,
                                @DBFieldType = 'varchar',
                                @DBFieldSize = 50,
                                @AllowNull = 'Y',
                                @SkipColumnCreation='Y'
Go


--Temporarily Commented out 6/26 intentionally per SCRUM meeting -- so that this doesn't go out in 7/12/2024 production release
--EXEC usp_TravantCRM_AddCustom_Tabs 180, 'find', 'BBOS Change Queue', 'customdotnetdll', 'TravantCRM', null, 'dataupload.gif'
--UPDATE Custom_Tabs SET Tabs_CustomFunction='RunChangeQueueListing' WHERE Tabs_Entity='find' AND Tabs_Caption='BBOS Change Queue' AND Tabs_Action='customdotnetdll'
-- EXEC usp_TravantCRM_DeleteCustom_Tab 'find', 'BBOS Change Queue'
--GO

EXEC usp_TravantCRM_CreateCheckboxField 'Person_Link', 'peli_PRCanViewBusinessValuations', 'Can View Business Valuations'
EXEC usp_TravantCRM_AddCustom_Screens	'PRPersonLinkMembershipSettings', 95, 'peli_PRCanViewBusinessValuations', 0, 1, 1
GO

EXEC usp_TravantCRM_CreateTextField		'PRWebServiceLicenseKey', 'prwslk_IndustryTypeCodes', 'Industry Type Codes', 40, 40
Go

--DEFECT 7337 - Business Valuation
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'PRBusinessValuation')
BEGIN
	--EXEC usp_TravantCRM_DropTable 'PRBusinessValuation'
	EXEC usp_TravantCRM_CreateTable @EntityName='PRBusinessValuation', @ColPrefix='prbv', @IDField='prbv_BusinessValuationID', @UseIdentityForKey='Y'
	EXEC usp_TravantCRM_CreateKeyField          'PRBusinessValuation', 'prbv_BusinessValuationID',  'Business Valuation ID'
	EXEC usp_TravantCRM_CreateSearchSelectField 'PRBusinessValuation', 'prbv_CompanyID', 'Company', 'Company', 100 
	EXEC usp_TravantCRM_CreateSearchSelectField 'PRBusinessValuation', 'prbv_PersonID', 'Person', 'Person', 100 
	EXEC usp_TravantCRM_CreateTextField			'PRBusinessValuation', 'prbv_FileName', 'Business Valuation Filename', 255, 255, @AllowNull_In='Y'
	EXEC usp_TravantCRM_CreateTextField			'PRBusinessValuation', 'prbv_DiskFileName', 'Disk Filename', 255, 255, @AllowNull_In='Y'
	EXEC usp_TravantCRM_CreateSelectField	    'PRBusinessValuation', 'prbv_StatusCode', 'Status', 'prbv_StatusCode'
	EXEC usp_TravantCRM_CreateDateTimeField		'PRBusinessValuation', 'prbv_SentDateTime', 'Sent Date Time', 'Y', 'N'
	EXEC usp_TravantCRM_CreateUserSelectField   'PRBusinessValuation', 'prbv_ProcessedBy', 'Processed By'
	EXEC usp_TravantCRM_CreateTextField			'PRBusinessValuation', 'prbv_Guid', 'Download Guid', 255, 255
END
GO

/*
	EXEC usp_TravantCRM_DeleteCustom_ScreenObject 'PRBusinessValuationSearchBox'
	EXEC usp_TravantCRM_DeleteCustom_ScreenObject 'PRBusinessValuationGrid'
	EXEC usp_TravantCRM_DeleteCustom_ScreenObject 'PRBusinessValuation'

	--EXEC usp_TravantCRM_DropView 'vPRBusinessValuation'
*/
EXEC usp_TravantCRM_DeleteCustom_ScreenObject 'PRBusinessValuationSearchBox'
EXEC usp_TravantCRM_AddCustom_ScreenObjects 'PRBusinessValuationSearchBox', 'SearchScreen', 'PRBusinessValuation', 'N', 0, 'PRBusinessValuation'
EXEC usp_TravantCRM_AddCustom_Screens 'PRBusinessValuationSearchBox', 10, 'prbv_CreatedDate', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRBusinessValuationSearchBox', 20, 'prbv_CompanyID', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRBusinessValuationSearchBox', 25, 'prbv_PersonID', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRBusinessValuationSearchBox', 30, 'prbv_StatusCode', 1, 1, 1, 0
Go

EXEC usp_TravantCRM_DeleteCustom_ScreenObject 'PRBusinessValuationGrid'
EXEC usp_TravantCRM_AddCustom_ScreenObjects 'PRBusinessValuationGrid', 'List', 'PRBusinessValuation', 'N', 0, 'PRBusinessValuation'
EXEC usp_TravantCRM_AddCustom_Lists 'PRBusinessValuationGrid', 5, 'prbv_CreatedDate', null, 'Y', @Jump='customdotnetdll', @CustomAction='TravantCRM.dll', @CustomFunction='RunBusinessValuationRequest', @CustomIdField='prbv_BusinessValuationID'
EXEC usp_TravantCRM_AddCustom_Lists 'PRBusinessValuationGrid', 10, 'prbv_CompanyID', null, 'Y', @Jump='Company'
EXEC usp_TravantCRM_AddCustom_Lists 'PRBusinessValuationGrid', 20, 'prbv_PersonID', null, 'Y', @Jump='Person'
EXEC usp_TravantCRM_AddCustom_Lists 'PRBusinessValuationGrid', 30, 'prbv_StatusCode', null, 'Y'
EXEC usp_TravantCRM_AddCustom_Lists 'PRBusinessValuationGrid', 40, 'prbv_SentDateTime', null, 'Y'
EXEC usp_TravantCRM_AddCustom_Lists 'PRBusinessValuationGrid', 50, 'prbv_ProcessedBy', null, 'Y'
GO

EXEC usp_TravantCRM_DeleteCustom_ScreenObject 'PRBusinessValuation'
EXEC usp_TravantCRM_AddCustom_ScreenObjects 'PRBusinessValuation', 'Screen', 'PRBusinessValuation', 'N', 0, 'PRBusinessValuation'
EXEC usp_TravantCRM_AddCustom_Screens 'PRBusinessValuation', 10, 'prbv_CompanyID', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRBusinessValuation', 20, 'prbv_PersonID', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRBusinessValuation', 30, 'prbv_StatusCode', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRBusinessValuation', 40, 'prbv_CreatedDate', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRBusinessValuation', 50, 'prbv_SentDateTime', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRBusinessValuation', 60, 'prbv_ProcessedBy', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRBusinessValuation', 70, 'prbv_FileName', 1, 1, 1, 0
Go

EXEC usp_TravantCRM_AddCustom_Tabs 175, 'find', 'Business Valuation Requests', 'customdotnetdll', 'TravantCRM', null, 'dataupload.gif'
UPDATE Custom_Tabs SET Tabs_CustomFunction='RunBusinessValuationRequestListing' WHERE Tabs_Entity='find' AND Tabs_Caption='Business Valuation Requests' AND Tabs_Action='customdotnetdll'
Go

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'PRMembershipReporting')
BEGIN
	--EXEC usp_TravantCRM_DropTable 'PRMembershipReportTable'
	EXEC usp_TravantCRM_CreateTable @EntityName='PRMembershipReportTable', @ColPrefix='prmr', @IDField='prmr_MembershipReportTable', @UseIdentityForKey='Y'
	EXEC usp_TravantCRM_CreateKeyField          'PRMembershipReportTable', 'prmr_MembershipReportTableID',  'Membership Report Table ID'
	EXEC usp_TravantCRM_CreateSelectField       'PRMembershipReportTable', 'prmr_TypeCode', 'Record Type', 'prmr_TypeCode'
	EXEC usp_TravantCRM_CreateSearchSelectField 'PRMembershipReportTable', 'prmr_CompanyID', 'Company', 'Company', 100 
	EXEC usp_TravantCRM_CreateTextField			'PRMembershipReportTable', 'prmr_SoldBy', 'Sold By', 10, 10
	EXEC usp_TravantCRM_CreateDateField			'PRMembershipReportTable', 'prmr_InvoiceDate', 'Invoice Date'
	EXEC usp_TravantCRM_CreateTextField			'PRMembershipReportTable', 'prmr_ItemCode', 'Item Code', 20, 20
	EXEC usp_TravantCRM_CreateIntegerField      'PRMembershipReportTable', 'prmr_Quantity', 'Quantity'
	EXEC usp_TravantCRM_CreateCurrencyField     'PRMembershipReportTable', 'prmr_Amount', 'Amount'
	EXEC usp_TravantCRM_CreateTextField			'PRMembershipReportTable', 'prmr_Pipeline', 'Pipeline', 50, 50
	EXEC usp_TravantCRM_CreateTextField			'PRMembershipReportTable', 'prmr_UpDown', 'Up/Down', 50, 50
END
GO


