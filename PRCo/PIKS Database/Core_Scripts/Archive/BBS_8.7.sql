--8.7 Release
USE CRM

--
--  These stored procedures have been renamed using the
--  usp_TravantCRM_ prefix.
--
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacGetInstallComponentName]') and OBJECTPROPERTY(id, N'IsProcedure') = 1) 
	drop procedure [dbo].[usp_AccpacGetInstallComponentName]

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_DeleteCustom_Caption]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[usp_DeleteCustom_Caption]

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_DeleteCustom_Tab]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[usp_DeleteCustom_Tab]

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_DeleteCustom_List]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[usp_DeleteCustom_List]

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_DeleteCustom_Screen]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[usp_DeleteCustom_Screen]

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_DeleteCustom_ScreenObject]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[usp_DeleteCustom_ScreenObject]

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AddCustom_ScreenObjects]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[usp_AddCustom_ScreenObjects]

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AddCustom_Screens]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[usp_AddCustom_Screens]

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AddCustom_Lists]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[usp_AddCustom_Lists]

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AddCustom_Captions]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[usp_AddCustom_Captions]

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AddCustom_Tabs]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[usp_AddCustom_Tabs]

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_DefineCaptions]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[usp_DefineCaptions]

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacCreateTable]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[usp_AccpacCreateTable]

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacCreateField]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[usp_AccpacCreateField]

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacCreateSelectField]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[usp_AccpacCreateSelectField]

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacCreateTextField]')  and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[usp_AccpacCreateTextField]

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacCreateKeyField]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[usp_AccpacCreateKeyField]

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacCreateIntegerField]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[usp_AccpacCreateIntegerField]

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacCreateNumericField]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[usp_AccpacCreateNumericField]

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacCreateSearchSelectField]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[usp_AccpacCreateSearchSelectField]

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacCreateMultiselectField]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[usp_AccpacCreateMultiselectField]

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacCreateUserSelectField]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[usp_AccpacCreateUserSelectField]

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacCreateAdvSearchSelectField]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[usp_AccpacCreateAdvSearchSelectField]

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacCreateCheckboxField]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[usp_AccpacCreateCheckboxField]

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacCreateDateTimeField]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[usp_AccpacCreateDateTimeField]

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacCreateDateField]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[usp_AccpacCreateDateField]

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacCreateEmailField]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[usp_AccpacCreateEmailField]

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacCreateURLField]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[usp_AccpacCreateURLField]

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacCreateMultilineField]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[usp_AccpacCreateMultilineField]

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacCreateTeamField]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[usp_AccpacCreateTeamField]

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacCreateTerritoryField]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[usp_AccpacCreateTerritoryField]

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacCreateView]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[usp_AccpacCreateView]

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacCreateDropdownValue]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[usp_AccpacCreateDropdownValue]

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacCreateCurrencyField]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[usp_AccpacCreateCurrencyField]

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacCreateKeyIdentityField]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[usp_AccpacCreateKeyIdentityField]

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacDropField]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[usp_AccpacDropField]

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacDropTable]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[usp_AccpacDropTable]

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacDropView]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[usp_AccpacDropView]

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacGetBlockInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[usp_AccpacGetBlockInfo]

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacRegisterViewAsTable]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[usp_AccpacRegisterViewAsTable]

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacRenameField]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[usp_AccpacRenameField]

GO

--New PRCommodityCategory table
EXEC usp_TravantCRM_DropTable 'PRCommodityCategory'
EXEC usp_TravantCRM_CreateTable 'PRCommodityCategory', 'prcomcat', 'prcomcat_CommodityCategoryId'
EXEC usp_TravantCRM_CreateKeyField 'PRCommodityCategory', 'prcomcat_CommodityCategoryId', 'Commodity Category Id' 
EXEC usp_TravantCRM_CreateIntegerField 'PRCommodityCategory', 'prcomcat_ParentId', 'Parent Id', 10
EXEC usp_TravantCRM_CreateIntegerField 'PRCommodityCategory', 'prcomcat_CommodityId', 'Commodity Id', 10
GO

--
--  Ultimately this will replace the PRCommodity table.
--
EXEC usp_TravantCRM_DropTable 'PRCommodity2'
EXEC usp_TravantCRM_CreateTable 'PRCommodity2', 'prcm', 'prcm_Commodity2ID'
EXEC usp_TravantCRM_CreateKeyField          'PRCommodity2', 'prcm_Commodity2ID', 'Primnary Key ID'
EXEC usp_TravantCRM_CreateIntegerField      'PRCommodity2', 'prcm_CommodityID', 'Commodity ID'
EXEC usp_TravantCRM_CreateIntegerField      'PRCommodity2', 'prcm_AttributeID', 'Attribute ID'
EXEC usp_TravantCRM_CreateIntegerField      'PRCommodity2', 'prcm_GrowingMethodID', 'Growing Method ID'
EXEC usp_TravantCRM_CreateTextField         'PRCommodity2', 'prcm_Abbreviation', 'Abbreviation', 25, 50
EXEC usp_TravantCRM_CreateTextField         'PRCommodity2', 'prcm_Description', 'Description', 50, 200
EXEC usp_TravantCRM_CreateTextField         'PRCommodity2', 'prcm_Description_ES', 'Description', 50, 200
EXEC usp_TravantCRM_CreateTextField         'PRCommodity2', 'prcm_ShortDescription', 'Short Description', 50, 200
EXEC usp_TravantCRM_CreateTextField         'PRCommodity2', 'prcm_ShortDescription_ES', 'Short Description', 50, 200
EXEC usp_TravantCRM_CreateTextField         'PRCommodity2', 'prcm_Alias', 'Aliases', 50, 200
EXEC usp_TravantCRM_CreateTextField         'PRCommodity2', 'prcm_DescriptionMatch', 'DescriptionMatch', 50, 200
EXEC usp_TravantCRM_CreateTextField         'PRCommodity2', 'prcm_AliasMatch', 'AliasMatch', 50, 200
GO

--Defect 6793 - prevent TES flag
EXEC usp_TravantCRM_CreateCheckboxField 'Company', 'comp_PRIgnoreTES', 'Ignore TES','Y','N','Y','N','''Y'''
EXEC usp_TravantCRM_AddCustom_Screens 'PRCompanyInfo', 187, 'comp_PRIgnoreTES', 0, 1, 1, 0
Go

--
-- New CRM filter for the Interactions page.
EXEC usp_TravantCRM_DeleteCustom_ScreenObject 'PRCommunicationListFilter'
EXEC usp_TravantCRM_AddCustom_ScreenObjects 'PRCommunicationListFilter', 'SearchScreen', 'Communication', 'N', 0, 'vListCommunication2'
EXEC usp_TravantCRM_AddCustom_Screens 'PRCommunicationListFilter', 10, 'comm_datetime', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRCommunicationListFilter', 20, 'cmli_comm_userid', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRCommunicationListFilter', 30, 'comm_subject', 0, 1, 1, 0

-- This makes the User ID control in the filter box appear as a dropdown.
UPDATE Custom_Edits
   SET ColP_EntrySize = '4'
WHERE ColP_ColName = 'cmli_comm_userid'

UPDATE Custom_Tabs SET tabs_action = 'customdotnetdll', Tabs_CustomFileName='TravantCRM', Tabs_CustomFunction='RunCompanyInteractionListing' WHERE Tabs_TabId=329
UPDATE Custom_Tabs SET tabs_action = 'customdotnetdll', Tabs_CustomFileName='TravantCRM', Tabs_CustomFunction='RunMyCRMInteractionListing' WHERE Tabs_TabId=10876
Go


--Defect 6793 - add Ignore TES flag to grid
EXEC usp_TravantCRM_AddCustom_Lists 'PRTradeReportOnGrid', 115, 'comp_PRIgnoreTES', null, 'Y', null, 'CENTER'
GO

--Defect 4282 - AUS changes
EXEC usp_TravantCRM_CreateTextField 'Person_Link', 'PeLi_PRAlertEmail', 'Alert Email', 255

--6.1.2 PREmailImages table [NEW]
EXEC usp_TravantCRM_DropTable 'PREmailImages'
EXEC usp_TravantCRM_CreateTable @EntityName='PREmailImages', @ColPrefix='prei', @IDField='prei_EmailImageID' --, @UseIdentityForKey='Y'
EXEC usp_TravantCRM_CreateKeyField          'PREmailImages', 'prei_EmailImageID', 'Email Image ID'
EXEC usp_TravantCRM_CreateSelectField		'PREmailImages', 'prei_EmailTypeCode', 'Email Type Code', 'prei_EmailTypeCode'
EXEC usp_TravantCRM_CreateDateField			'PREmailImages', 'prei_StartDate', 'Start Date', @AllowNull_In='N'
EXEC usp_TravantCRM_CreateDateField			'PREmailImages', 'prei_EndDate', 'End Date', @AllowNull_In='N'
EXEC usp_TravantCRM_CreateTextField         'PREmailImages', 'prei_EmailImgFileName', 'Email Image FileName', 200, 200, @AllowNull_In='N'
EXEC usp_TravantCRM_CreateTextField         'PREmailImages', 'prei_EmailImgDiskFileName', 'Email Image Disk FileName', 200, 200, @AllowNull_In='N'
EXEC usp_TravantCRM_CreateSelectField		'PREmailImages', 'prei_LocationCode', 'Location Code', 'prei_LocationCode'
GO

--2.2 new Sage CRM SDK screens
EXEC usp_TravantCRM_AddCustom_Tabs 580, 'find', 'Email Images', 'customdotnetdll', 'TravantCRM', null, 'dataupload.gif'
UPDATE Custom_Tabs SET Tabs_CustomFunction='RunEmailImageListing' WHERE Tabs_Entity='find' AND Tabs_Caption='Email Images' AND Tabs_Action='customdotnetdll'
Go

--EmailImageGrid
EXEC usp_TravantCRM_DeleteCustom_ScreenObject 'EmailImageGrid'
EXEC usp_TravantCRM_AddCustom_ScreenObjects 'EmailImageGrid', 'List', 'PREmailImages', 'N', 0, 'PREmailImages'
EXEC usp_TravantCRM_AddCustom_Lists 'EmailImageGrid', 10, 'prei_StartDate', null, 'Y', @Jump='customdotnetdll', @CustomAction='TravantCRM.dll', @CustomFunction='RunEmailImage', @CustomIdField='prei_EmailImageID'
EXEC usp_TravantCRM_AddCustom_Lists 'EmailImageGrid', 20, 'prei_EndDate', null, 'Y', 'Y'
EXEC usp_TravantCRM_AddCustom_Lists 'EmailImageGrid', 30, 'prei_EmailTypeCode', null, 'Y'
EXEC usp_TravantCRM_AddCustom_Lists 'EmailImageGrid', 40, 'prei_EmailImgFileName', null, 'Y'
EXEC usp_TravantCRM_AddCustom_Lists 'EmailImageGrid', 50, 'prei_LocationCode', null, 'Y'

UPDATE custom_lists SET grip_DefaultOrderBy = 'Y', GriP_OrderByDesc='Y' WHERE grip_GridName = 'EmailImageGrid' AND grip_ColName='prei_StartDate';

-- New CRM filter for the Email Image page
EXEC usp_TravantCRM_DeleteCustom_ScreenObject 'PREmailImagesListFilter'
EXEC usp_TravantCRM_AddCustom_ScreenObjects 'PREmailImagesListFilter', 'SearchScreen', 'PREmailImages', 'N', 0, 'PREmailImages'
EXEC usp_TravantCRM_AddCustom_Screens 'PREmailImagesListFilter', 10, 'prei_StartDate', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PREmailImagesListFilter', 20, 'prei_EmailTypeCode', 1, 1, 1, 0

EXEC usp_TravantCRM_DeleteCustom_ScreenObject 'PREmailImage'
EXEC usp_TravantCRM_AddCustom_ScreenObjects 'PREmailImage', 'Screen', 'PREmailImages', 'N', 0, 'PREmailImages'
EXEC usp_TravantCRM_AddCustom_Screens 'PREmailImage', 10, 'prei_StartDate', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PREmailImage', 20, 'prei_EndDate', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PREmailImage', 30, 'prei_EmailTypeCode', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PREmailImage', 40, 'prei_EmailImgFileName', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PREmailImage', 50, 'prei_LocationCode', 1, 1, 1, 0

GO

--Defect 6810-Field Rep Interaction import tool
EXEC usp_TravantCRM_AddCustom_Tabs 345, 'find', 'Import Field Rep Interactions', 'customdotnetdll', 'TravantCRM', null, 'dataupload.gif'
UPDATE Custom_Tabs SET Tabs_CustomFunction='RunImportFieldRepInteractions' WHERE Tabs_Entity='find' AND Tabs_Caption='Import Field Rep Interactions' AND Tabs_Action='customdotnetdll'

GO

--change tab in person record from "AUS List" to "Alerts List"
UPDATE Custom_Tabs SET Tabs_Caption='Alerts List' WHERE tabs_Entity='person' AND Tabs_Caption='AUS List' 
EXEC usp_TravantCRM_DefineCaptions 'vPRWebUserAUSCompanyList', 'Alert Record', 'Alert Records', null, null, null, null

GO

--Cache Industry Metrics data in table
--EXEC usp_TravantCRM_DropTable 'PRIndustryMetrics'
EXEC usp_TravantCRM_CreateTable @EntityName='PRIndustryMetrics', @ColPrefix='prim', @IDField='prim_IndustryMetricsID', @UseIdentityForKey='Y'
EXEC usp_TravantCRM_CreateKeyField          'PRIndustryMetrics', 'prim_IndustryMetricsID', 'Industry Metrics ID'
EXEC usp_TravantCRM_CreateTextField			'PRIndustryMetrics', 'prim_Metric', 'Metric', 50, 50, @AllowNull_In='N'
EXEC usp_TravantCRM_CreateIntegerField      'PRIndustryMetrics', 'prim_Count', 'Metric Count'
EXEC usp_TravantCRM_CreateTextField			'PRIndustryMetrics', 'prim_IndustryType', 'Industry Type', 50, 50

GO

--AUSAlertEvent startdate seeding
DECLARE @AUSAlertSeedDate varchar(50) = CONVERT(varchar, GETDATE(), 120)
exec usp_TravantCRM_CreateDropdownValue 'prau_LastAlertDateTime', @AUSAlertSeedDate, 0, 'AUSAlert Last Run Date/Time' 
GO


