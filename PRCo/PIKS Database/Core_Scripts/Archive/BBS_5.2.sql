EXEC usp_AddCustom_Lists 'PRAdCampaignGrid', 50, 'BlueprintsEdition', null, null
EXEC usp_AddCustom_Captions 'Tags', 'ColNames', 'BlueprintsEdition', 0, 'Blueprint Edition', 'Blueprint Edition', 'Blueprint Edition', 'Blueprint Edition', 'Blueprint Edition', 'Blueprint Edition', 'Blueprint Edition'
EXEC usp_AddCustom_Captions 'Tags', 'ColNames', 'StartDate', 0, 'Start Date', 'Start Date', 'Start Date', 'Start Date', 'Start Date', 'Start Date', 'Start Date'
EXEC usp_AddCustom_Captions 'Tags', 'ColNames', 'EndDate', 0, 'End Date', 'End Date', 'End Date', 'End Date', 'End Date', 'End Date', 'End Date'


EXEC usp_AddCustom_Screens 'PRAdCampaignPub', 45, 'pradc_AdSize', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRAdCampaignPub', 50, 'pradc_AdImageName', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRAdCampaignPub', 55, 'pradc_Notes', 1, 1, 2, 0
Go

EXEC usp_AccpacCreateIntegerField 'PRClassification', 'prcl_DisplayOrder', 'Sequence' 
Go

CREATE TABLE [dbo].[PRAdCampaignMirror](
	[pradc_AdCampaignMirrorID] [int] identity(1,1) NOT NULL,
	[pradc_AdCampaignID] [int] NOT NULL,
	[pradc_Deleted] [int] NULL,
	[pradc_WorkflowId] [int] NULL,
	[pradc_Secterr] [int] NULL,
	[pradc_CreatedBy] [int] NULL,
	[pradc_CreatedDate] [datetime] NULL,
	[pradc_UpdatedBy] [int] NULL,
	[pradc_UpdatedDate] [datetime] NULL,
	[pradc_TimeStamp] [datetime] NULL,
	[pradc_CompanyID] [int] NULL,
	[pradc_HQID] [int] NULL,
	[pradc_Name] [nvarchar](50) NOT NULL,
	[pradc_AdCampaignType] [nvarchar](40) NULL,
	[pradc_ImpressionCount] [int] NULL,
	[pradc_ClickCount] [int] NULL,
	[pradc_AdImageName] [nvarchar](500) NULL,
	[pradc_TargetURL] [nvarchar](500) NULL,
	[pradc_Listing1] [nvarchar](50) NULL,
	[pradc_Listing2] [nvarchar](50) NULL,
	[pradc_Listing3] [nvarchar](50) NULL,
	[pradc_Listing4] [nvarchar](50) NULL,
	[pradc_StartDate] [datetime] NULL,
	[pradc_EndDate] [datetime] NULL,
	[pradc_ServiceID] [int] NULL,
	[pradc_PeriodImpressionCount] [int] NULL,
	[pradc_PeriodClickCount] [int] NULL,
	[pradc_AdSize] [nvarchar](40) NULL,
	[pradc_AdColor] [nvarchar](40) NULL,
	[pradc_Placement] [nvarchar](40) NULL,
	[pradc_Section] [nvarchar](40) NULL,
	[pradc_SectionDetails] [varchar](100) NULL,
	[pradc_BluePrintsEdition] [nvarchar](255) NULL,
	[pradc_Orientation] [nvarchar](40) NULL,
	[pradc_Cost] [numeric](24, 6) NULL,
	[pradc_Discount] [numeric](24, 6) NULL,
	[pradc_PlacementInstructions] [varchar](max) NULL,
	[pradc_Notes] [varchar](max) NULL,
	[pradc_SoldBy] [int] NULL,
	[pradc_ApprovedByPersonID] [int] NULL,
	[pradc_CreativeStatus] [nvarchar](40) NULL,
	[pradc_FinalPlacement] [nvarchar](40) NULL,
	[pradc_FinalPageNumber] [int] NULL,
	[pradc_AltTradeName] [varchar](104) NULL,
	[pradc_FileID] [int] NULL,
	[pradc_PublicationArticleID] [int] NULL,
	[pradc_Terms] [nchar](1) NULL,
	[pradc_TermsDescription] [varchar](100) NULL,
	[pradc_WaitList] [nchar](1) NULL,
	[pradc_Premium] [nchar](1) NULL,
	[pradc_PlannedSection] [nvarchar](40) NULL,
	[pradc_Renewal] [nchar](1) NULL,
PRIMARY KEY CLUSTERED 
(
	[pradc_AdCampaignMirrorID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO


EXEC usp_AccpacCreateIntegerField 'PRCompanyExternalNews', 'prcen_LookupCount', 'Lookup Count' 
EXEC usp_AccpacCreateDateTimeField 'PRCompanyExternalNews', 'prcen_LastLookupDateTime', 'Last Lookup Date Time' 

EXEC usp_AddCustom_Tabs 50, 'find', 'Dow Jones Company Lookup', 'customfile', 'PRGeneral/DowJonesFCodeLookupRedirect.asp', null, 'Company.gif'
Go

EXEC usp_AddCustom_Screens 'ExceptionQueueFilterBox', 10, 'preq_AssignedUserId', 1
EXEC usp_AddCustom_Screens 'ExceptionQueueFilterBox', 20, 'preq_Date', 0
EXEC usp_AddCustom_Screens 'ExceptionQueueFilterBox', 30, 'preq_Type', 1
EXEC usp_AddCustom_Screens 'ExceptionQueueFilterBox', 40, 'preq_Status', 0
EXEC usp_AddCustom_Screens 'ExceptionQueueFilterBox', 50, 'comp_PRType', 1
EXEC usp_AddCustom_Screens 'ExceptionQueueFilterBox', 60, 'comp_PRIndustryType', 0

EXEC usp_DeleteCustom_Screen 'ExceptionQueueFilterBox', 'preq_EnteredDate'
Go


EXEC usp_AccpacCreateTable @EntityName='PRDLMetrics', @ColPrefix='prdlm', @IDField='prdlm_DLMetricsID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyIdentityField 'PRDLMetrics', 'prdlm_DLMetricsID', 'DL Metrics ID';
EXEC usp_AccpacCreateUserSelectField 'PRDLMetrics', 'prdlm_UserID', 'Count';
exec usp_AccpacCreateSearchSelectField 'PRDLMetrics', 'prdlm_CompanyID', 'Company', 'Company', 50 
EXEC usp_AccpacCreateIntegerField 'PRDLMetrics', 'prdlm_BeforeCount', 'Before Count';
EXEC usp_AccpacCreateIntegerField 'PRDLMetrics', 'prdlm_AfterCount', 'After Count';
EXEC usp_AccpacCreateIntegerField 'PRDLMetrics', 'prdlm_ChangeCount', 'Change Count';
Go

EXEC usp_AccpacCreateIntegerField 'Company', 'comp_PRDLCountWhenListed', 'DL Count When Listed';



EXEC usp_AccpacCreateTable @EntityName='PRSocialMedia', @ColPrefix='prsm', @IDField='prsm_SocialMediaID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyIdentityField 'PRSocialMedia', 'prsm_SocialMediaID', 'Social Media ID';
EXEC usp_AccpacCreateSearchSelectField 'PRSocialMedia', 'prsm_CompanyID', 'Company', 'Company', 50 
EXEC usp_AccpacCreateSelectField 'PRSocialMedia', 'prsm_SocialMediaTypeCode', 'Social Media Type', 'prsm_SocialMediaTypeCode' 
EXEC usp_AccpacCreateURLField 'PRSocialMedia', 'prsm_URL', 'URL', 'N', 'Y', 'Y', 'N', 100, 500
EXEC usp_AccpacCreateCheckboxField 'PRSocialMedia', 'prsm_Disabled', 'Disabled'

EXEC usp_DefineCaptions 'PRSocialMedia', 'Social Media URL', 'Social Media URLs', 'prsm_SocialMediaTypeCode', 'prsm_SocialMediaID', NULL, NULL
Go

EXEC usp_AddCustom_ScreenObjects 'PRSocialMediaGrid', 'List', 'PRSocialMedia', 'N', 0, 'PRSocialMedia'
EXEC usp_AddCustom_Lists 'PRSocialMediaGrid', 10, 'prsm_CompanyID', null, 'Y'
EXEC usp_AddCustom_Lists 'PRSocialMediaGrid', 20, 'prsm_SocialMediaTypeCode', null, 'Y'
EXEC usp_AddCustom_Lists 'PRSocialMediaGrid', 30, 'prsm_URL', null, 'Y'
EXEC usp_AddCustom_Lists 'PRSocialMediaGrid', 40, 'prsm_Disabled', null, 'Y'
Go

EXEC usp_AccpacCreateSelectField 'Company', 'comp_PRConfidentialFS', 'Financial Figures Confidentiality', 'comp_PRConfidentialFS' 
Go


EXEC usp_AccpacCreateSelectField 'Opportunity', 'oppo_PRTrigger', 'Trigger', 'oppo_PRTrigger', 'Y', 'N'
Go


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_Company_BBSInterface_insert]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
	drop trigger [dbo].[trg_Company_BBSInterface_insert]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_Company_BBSInterface_update]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
	drop trigger [dbo].[trg_Company_BBSInterface_update]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_Address_BBSInterface_update]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
	drop trigger [dbo].[trg_Address_BBSInterface_update]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_Address_Link_BBSInterface_delete]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
	drop trigger [dbo].[trg_Address_Link_BBSInterface_delete]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRCompanyClassification_BBSInterface_delete]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
	drop trigger [dbo].[trg_PRCompanyClassification_BBSInterface_delete]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRCompanyCommodityAttribute_BBSInterface_delete]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
	drop trigger [dbo].[trg_PRCompanyCommodityAttribute_BBSInterface_delete]
GO


EXEC usp_AccpacCreateTextField         'PRExternalNewsAuditTrail', 'prenat_SecondarySource', 'Secondary Source', 50, 150