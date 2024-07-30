EXEC usp_AccpacDropView 'vPRPersonDefaultInfo'
EXEC usp_AccpacDropView 'vPRContactInfo'


EXEC usp_DeleteCustom_ScreenObject 'PRFileHeader'
EXEC usp_DeleteCustom_ScreenObject 'PRFilePartySummary'
EXEC usp_DeleteCustom_ScreenObject 'PRFileCollectionInitialInfo'
EXEC usp_DeleteCustom_ScreenObject 'PRFileCollectionFormal'
EXEC usp_DeleteCustom_ScreenObject 'PRFilePLANInfo'
EXEC usp_DeleteCustom_ScreenObject 'PRFilePaymentGrid'
EXEC usp_DeleteCustom_ScreenObject 'PRFileSearchBox'
EXEC usp_DeleteCustom_ScreenObject 'PRFileGrid'
EXEC usp_DeleteCustom_ScreenObject 'PRFileWorkflowGrid'
EXEC usp_DeleteCustom_ScreenObject 'PRFileCreditorInfo'
EXEC usp_DeleteCustom_ScreenObject 'PRFileDebtorInfo'
EXEC usp_DeleteCustom_ScreenObject 'PRFileThirdPartyInfo'
EXEC usp_DeleteCustom_ScreenObject 'PRFilePaymentNewEntry'
Go



EXEC usp_AccpacCreateCheckboxField 'Email', 'emai_PRPreferredPublished', 'Preferred for Published Use'
EXEC usp_AccpacCreateCheckboxField 'Email', 'emai_PRPreferredInternal', 'Preferred for Internal Use'

EXEC usp_AccpacCreateCheckboxField 'Phone', 'phon_PRPreferredPublished', 'Preferred for Published Use'
EXEC usp_AccpacCreateCheckboxField 'Phone', 'phon_PRPreferredInternal', 'Preferred for Internal Use'
EXEC usp_AccpacCreateCheckboxField 'Phone', 'phon_PRIsPhone', 'Is a Phone Number'
EXEC usp_AccpacCreateCheckboxField 'Phone', 'phon_PRIsFax', 'Is a Fax Number'



EXEC usp_AddCustom_Lists 'PREmailGrid', 60, 'emai_PRPreferredInternal', null, 'Y', null, 'center'
EXEC usp_AddCustom_Lists 'PREmailGrid', 80, 'emai_PRPreferredPublished', null, 'Y', null, 'center'
EXEC usp_DeleteCustom_List 'PREmailGrid', 'emai_PRDefault'

EXEC usp_AddCustom_Screens 'EmailNewEntry', 10, 'emai_Type', 1, 1, 1
EXEC usp_AddCustom_Screens 'EmailNewEntry', 20, 'emai_EmailAddress', 0, 1, 1
EXEC usp_AddCustom_Screens 'EmailNewEntry', 30, 'emai_PRWebAddress', 0, 1, 1
EXEC usp_AddCustom_Screens 'EmailNewEntry', 40, 'emai_CompanyID', 0, 1, 1
EXEC usp_AddCustom_Screens 'EmailNewEntry', 50, 'emai_PRDescription', 1, 1, 3
EXEC usp_AddCustom_Screens 'EmailNewEntry', 60, 'emai_PRPublish', 1, 1, 1
EXEC usp_AddCustom_Screens 'EmailNewEntry', 70, 'emai_PRPreferredPublished', 0, 1, 1
EXEC usp_AddCustom_Screens 'EmailNewEntry', 80, 'emai_PRPreferredInternal', 0, 1, 1
EXEC usp_AddCustom_Screens 'EmailNewEntry', 90, 'emai_PRSlot', 1, 1, 1, null, null, null, null, 'ReadOnly = true;'
EXEC usp_AddCustom_Screens 'EmailNewEntry', 100, 'emai_PRSequence', 0, 1, 1, null, null, null, null, 'ReadOnly = true;' 
EXEC usp_DeleteCustom_Screen 'EmailNewEntry', 'emai_PRDefault'
Go

EXEC usp_AddCustom_Lists 'CompanyPhoneGrid', 4, 'phon_PRPreferredInternal', null, 'Y', null, 'center'
EXEC usp_AddCustom_Lists 'CompanyPhoneGrid', 6, 'phon_PRPreferredPublished', null, 'Y', null, 'center'
EXEC usp_DeleteCustom_List 'CompanyPhoneGrid', 'phon_Default'

EXEC usp_AddCustom_Lists 'PersonPhoneGrid', 50, 'phon_PRPreferredInternal', null, 'Y', null, 'center'
EXEC usp_AddCustom_Lists 'PersonPhoneGrid', 70, 'phon_PRPreferredPublished', null, 'Y', null, 'center'
EXEC usp_DeleteCustom_List 'PersonPhoneGrid', 'phon_Default'

EXEC usp_AddCustom_Screens 'PhoneNewEntry', 10, 'phon_Type', 1, 1, 1
EXEC usp_AddCustom_Screens 'PhoneNewEntry', 20, 'phon_CompanyID', 0, 1, 1
EXEC usp_AddCustom_Screens 'PhoneNewEntry', 30, 'phon_CountryCode', 1, 1, 1
EXEC usp_AddCustom_Screens 'PhoneNewEntry', 40, 'phon_AreaCode', 0, 1, 1
EXEC usp_AddCustom_Screens 'PhoneNewEntry', 50, 'phon_Number', 0, 1, 1
EXEC usp_AddCustom_Screens 'PhoneNewEntry', 60, 'phon_PRExtension', 0, 1, 1
EXEC usp_AddCustom_Screens 'PhoneNewEntry', 70, 'phon_PRDescription', 1, 1, 1
EXEC usp_AddCustom_Screens 'PhoneNewEntry', 80, 'phon_PRPublish', 0, 1, 1
EXEC usp_AddCustom_Screens 'PhoneNewEntry', 90, 'phon_PRPreferredPublished', 0, 1, 1
EXEC usp_AddCustom_Screens 'PhoneNewEntry', 100, 'phon_PRPreferredInternal', 0, 1, 1
EXEC usp_AddCustom_Screens 'PhoneNewEntry', 110, 'phon_PRDisconnected', 1, 1, 1
EXEC usp_AddCustom_Screens 'PhoneNewEntry', 120, 'phon_PRSlot', 0, 1, 1, null, null, null, null, 'ReadOnly = true;'
EXEC usp_AddCustom_Screens 'PhoneNewEntry', 130, 'phon_PRSequence', 0, 1, 1, null, null, null, null, 'ReadOnly = true;' 
EXEC usp_DeleteCustom_Screen 'PhoneNewEntry', 'phon_Default'

Go



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetCompanyEmail]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    drop function [dbo].[ufn_GetCompanyEmail]
GO

If Exists (Select name from sysobjects where name = 'ufn_GetPersonDefaultEmail' and type in (N'FN', N'IF', N'TF')) 
	Drop Function dbo.ufn_GetPersonDefaultEmail
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetCompanyPhone]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    drop function [dbo].[ufn_GetCompanyPhone]
GO

If Exists (Select name from sysobjects where name = 'ufn_GetPersonDefaultFax' and type in (N'FN', N'IF', N'TF')) 
	Drop Function dbo.ufn_GetPersonDefaultFax
Go

If Exists (Select name from sysobjects where name = 'ufn_GetPersonDefaultPhone' and type in (N'FN', N'IF', N'TF')) 
    Drop Function dbo.ufn_GetPersonDefaultPhone
Go

If Exists (Select name from sysobjects where name = 'ufn_GetPersonPublishablePhone' and type in (N'FN', N'IF', N'TF')) 
    Drop Function dbo.ufn_GetPersonPublishablePhone
Go

If Exists (Select name from sysobjects where name = 'ufn_GetPersonPublishableFax' and type in (N'FN', N'IF', N'TF')) 
    Drop Function dbo.ufn_GetPersonPublishableFax
Go



IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Phone]') AND name = N'ndx_Phon_CompanyID')
	DROP INDEX ndx_Phon_CompanyID ON Phone;
Go

IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Phone]') AND name = N'ndx_Phon_PersonID')
	DROP INDEX ndx_Phon_PersonID ON Phone;
Go



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_WorkflowInstance_upd]'))
	drop trigger [dbo].[trg_WorkflowInstance_upd]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_WA_File_OpenFile]'))
	drop Procedure [dbo].[usp_WA_File_OpenFile]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_WA_File_CreateNextStepsTask]'))
	drop Procedure [dbo].[usp_WA_File_CreateNextStepsTask]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_WA_File_WriteOpinion]'))
	drop Procedure [dbo].[usp_WA_File_WriteOpinion]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_WA_File_RequestDisputeAssistance]'))
	drop Procedure [dbo].[usp_WA_File_RequestDisputeAssistance]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_CompanyListing_upd]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_CompanyListing_upd]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_CompanyBranchDelisting_upd]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_CompanyBranchDelisting_upd]
GO


--
-- Begin AB Pay Rating Changes
--
USE [CRMArchive]
GO

IF OBJECT_ID('dbo.PRPayRatingPreABConversion') IS NOT NULL
	DROP TABLE dbo.PRPayRatingPreABConversion
GO

CREATE TABLE [dbo].[PRPayRatingPreABConversion](
	[prpy_PayRatingId] [int] NOT NULL,
	[prpy_Deleted] [int] NULL,
	[prpy_WorkflowId] [int] NULL,
	[prpy_Secterr] [int] NULL,
	[prpy_CreatedBy] [int] NULL,
	[prpy_CreatedDate] [datetime] NULL,
	[prpy_UpdatedBy] [int] NULL,
	[prpy_UpdatedDate] [datetime] NULL,
	[prpy_TimeStamp] [datetime] NULL,
	[prpy_Name] [nvarchar](6) NULL,
	[prpy_TradeReportDescription] [nvarchar](15) NULL,
	[prpy_Order] [int] NULL,
	[prpy_Weight] [int] NULL,
	[prpy_IsNumeral] [nchar](1) NULL,
PRIMARY KEY CLUSTERED 
(
	[prpy_PayRatingId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO


IF OBJECT_ID('dbo.PRRatingPreABConversion') IS NOT NULL
	DROP TABLE dbo.PRRatingPreABConversion
GO

CREATE TABLE [dbo].[PRRatingPreABConversion](
	[prra_RatingId] [int] NOT NULL,
	[prra_Deleted] [int] NULL,
	[prra_WorkflowId] [int] NULL,
	[prra_Secterr] [int] NULL,
	[prra_CreatedBy] [int] NULL,
	[prra_CreatedDate] [datetime] NULL,
	[prra_UpdatedBy] [int] NULL,
	[prra_UpdatedDate] [datetime] NULL,
	[prra_TimeStamp] [datetime] NULL,
	[prra_CompanyId] [int] NOT NULL,
	[prra_Date] [datetime] NULL,
	[prra_Current] [nchar](1) NULL,
	[prra_CreditWorthId] [int] NULL,
	[prra_IntegrityId] [int] NULL,
	[prra_PayRatingId] [int] NULL,
	[prra_InternalAnalysis] [ntext] NULL,
	[prra_PublishedAnalysis] [ntext] NULL,
	[prra_Rated] [nchar](1) NULL,
PRIMARY KEY CLUSTERED 
(
	[prra_RatingId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO



IF OBJECT_ID('dbo.PRTradeReportPreABConversion') IS NOT NULL
	DROP TABLE dbo.PRTradeReportPreABConversion
GO


CREATE TABLE [dbo].[PRTradeReportPreABConversion](
	[prtr_TradeReportId] [int] NOT NULL,
	[prtr_Deleted] [int] NULL,
	[prtr_WorkflowId] [int] NULL,
	[prtr_Secterr] [int] NULL,
	[prtr_CreatedBy] [int] NULL,
	[prtr_CreatedDate] [datetime] NULL,
	[prtr_UpdatedBy] [int] NULL,
	[prtr_UpdatedDate] [datetime] NULL,
	[prtr_TimeStamp] [datetime] NULL,
	[prtr_ResponderId] [int] NOT NULL,
	[prtr_SubjectId] [int] NOT NULL,
	[prtr_Date] [datetime] NULL,
	[prtr_NoTrade] [nchar](1) NULL,
	[prtr_OutOfBusiness] [nchar](1) NULL,
	[prtr_LastDealtDate] [nvarchar](40) NULL,
	[prtr_RelationshipLength] [nvarchar](40) NULL,
	[prtr_Regularity] [nchar](1) NULL,
	[prtr_Seasonal] [nchar](1) NULL,
	[prtr_RelationshipType] [nvarchar](40) NULL,
	[prtr_Terms] [nvarchar](255) NULL,
	[prtr_ProductKickers] [nchar](1) NULL,
	[prtr_CollectRemit] [nchar](1) NULL,
	[prtr_PromptHandling] [nchar](1) NULL,
	[prtr_ProperEquipment] [nchar](1) NULL,
	[prtr_Pack] [nvarchar](40) NULL,
	[prtr_DoubtfulAccounts] [nchar](1) NULL,
	[prtr_PayFreight] [nchar](1) NULL,
	[prtr_TimelyArrivals] [nchar](1) NULL,
	[prtr_IntegrityId] [int] NULL,
	[prtr_PayRatingId] [int] NULL,
	[prtr_HighCredit] [nvarchar](40) NULL,
	[prtr_CreditTerms] [nvarchar](40) NULL,
	[prtr_AmountPastDue] [nvarchar](40) NULL,
	[prtr_InvoiceOnDayShipped] [nchar](1) NULL,
	[prtr_DisputeInvolved] [nchar](1) NULL,
	[prtr_PaymentTrend] [nvarchar](40) NULL,
	[prtr_LoadsPerYear] [nvarchar](40) NULL,
	[prtr_Comments] [ntext] NULL,
	[prtr_ResponseSource] [nvarchar](40) NULL,
	[prtr_Duplicate] [nchar](1) NULL,
	[prtr_Exception] [nchar](1) NULL,
	[prtr_CommentsFlag] [nchar](1) NULL,
	[prtr_TESRequestID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[prtr_TradeReportId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO



USE [CRM]
GO

EXEC usp_AccpacCreateTextField 'PRWebUser', 'prwu_LinkedInToken', 'Linked-In API Token', 50, 150
EXEC usp_AccpacCreateTextField 'PRWebUser', 'prwu_LinkedInTokenSecret', 'Linked-In API Token Secret', 50, 150
EXEC usp_AccpacCreateTextField 'Person', 'pers_PRLinkedInProfile', 'Linked-In Profile', 50, 150



EXEC usp_AccpacCreateTable @EntityName='PRLinkedInAuditTrail', @ColPrefix='prliat', @IDField='prliat_LinkedInAuditTrailID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyIdentityField 'PRLinkedInAuditTrail', 'prliat_LinkedInAuditTrailID', 'Linked-In Audit Trail ID';
EXEC usp_AccpacCreateSearchSelectField 'PRLinkedInAuditTrail', 'prliat_WebUserID', 'PRWebUser', 'PRWebUser', 50 
EXEC usp_AccpacCreateSearchSelectField 'PRLinkedInAuditTrail', 'prliat_SubjectCompanyID', 'Company', 'Company', 50 
EXEC usp_AccpacCreateTextField 'PRLinkedInAuditTrail', 'prliat_APIMethod', 'APIMethod', 50, 150
EXEC usp_AccpacCreateIntegerField 'PRLinkedInAuditTrail', 'prliat_SearchCount', 'Search Count';
EXEC usp_AccpacCreateIntegerField 'PRLinkedInAuditTrail', 'prliat_UserResultCount', 'User Result Count';
EXEC usp_AccpacCreateIntegerField 'PRLinkedInAuditTrail', 'prliat_TotalResultCount', 'Total Result Count';
EXEC usp_AccpacCreateIntegerField 'PRLinkedInAuditTrail', 'prliat_PrivateCount', 'Private Count';
EXEC usp_AccpacCreateCheckboxField 'PRLinkedInAuditTrail', 'prliat_ExceededThreshold', 'Exceeded Threshold'


EXEC usp_AccpacCreateTextField 'PRWebAuditTrail', 'prwsat_BrowserUserAgent', 'Browser User Agent', 50, 500

USE CRMArchive
if not exists (select column_name from INFORMATION_SCHEMA.columns where table_name = 'PRWebAuditTrail' and column_name = 'prwsat_BrowserUserAgent') begin
	ALTER TABLE CRMArchive.dbo.PRWebAuditTrail  ADD prwsat_BrowserUserAgent varchar(500) NULL 
END	
USE CRM


EXEC usp_AccpacCreateTextField 'PRTerminalMarket', 'prtm_ShortMarketName', 'Short Market Name', 50, 50
EXEC usp_AccpacCreateTextField 'PRClassification', 'prcl_ShortDescription', 'Short Description', 35, 35
EXEC usp_AccpacCreateTextField 'PRCommodity', 'prcm_ShortDescription', 'Short Description', 35, 35


EXEC usp_AddCustom_Screens 'PRTerminalMarketNewEntry', 15, 'prtm_ShortMarketName', 1, 1, 1
Go


EXEC usp_DeleteCustom_Screen 'PRCompanyProfile', 'prcp_VolumeBoardFeetPerYear'
EXEC usp_DeleteCustom_Screen 'PRCompanyProfile', 'prcp_VolumeTruckLoadsPerYear'
EXEC usp_DeleteCustom_Screen 'PRCompanyProfile', 'prcp_VolumeCarLoadsPerYear'
Go


EXEC usp_AccpacCreateCheckboxField 'Company', 'comp_PRPublishLogo', 'Publish Logo'
EXEC usp_AddCustom_Screens 'PRLogoSpotlight', 10, 'comp_PRPublishLogo', 0, 1, 1
UPDATE custom_edits
   SET colp_EntrySize = 25
 WHERE colp_ColName = 'comp_PRLogo';
Go

EXEC usp_AccpacCreateTextField 'PRCommodity', 'prcm_FullName', 'Full Name', 50, 100
Go


UPDATE custom_captions SET capt_us = 'Logo Image File (Entered as BBID\BBID.jpg)' WHERE capt_code = 'comp_PRLogo';
Go