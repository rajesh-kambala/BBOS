USE CRM

PRINT 'DATA TABLE-CRM'
--DROP TABLE dbo.PRAdCampaignAuditTrailSummary
IF OBJECT_ID('dbo.PRAdCampaignAuditTrailSummary', 'U') IS NULL 
BEGIN
	EXEC usp_TravantCRM_DropTable 'PRAdCampaignAuditTrailSummary'
	EXEC usp_TravantCRM_CreateTable @EntityName='PRAdCampaignAuditTrailSummary', @ColPrefix='pradcats', @IDField='pradcats_AdCampaignAuditTrailSummaryID', @UseIdentityForKey='Y'
	EXEC usp_TravantCRM_CreateKeyField          'PRAdCampaignAuditTrailSummary', 'pradcats_AdCampaignAuditTrailSummaryID', 'Ad Campaign Audit Trail Summary ID'
	EXEC usp_TravantCRM_CreateIntegerField      'PRAdCampaignAuditTrailSummary', 'pradcats_AdCampaignID', 'AdCampaignID', @AllowNull_In='N'
	EXEC usp_TravantCRM_CreateDateField			'PRAdCampaignAuditTrailSummary', 'pradcats_DisplayDate', 'DisplayDate'
	EXEC usp_TravantCRM_CreateIntegerField      'PRAdCampaignAuditTrailSummary', 'pradcats_ImpressionCount', 'ImpressionCount', @AllowNull_In='N'
	EXEC usp_TravantCRM_CreateIntegerField      'PRAdCampaignAuditTrailSummary', 'pradcats_ClickCount', 'ClickCount', @AllowNull_In='N'

	CREATE INDEX ndx_PRAdCampaignAuditTrailSummary_01 ON CRM.dbo.PRAdCampaignAuditTrailSummary(pradcats_DisplayDate, pradcats_AdCampaignID);
	CREATE INDEX ndx_PRAdCampaignAuditTrailSummary_02 ON CRM.dbo.PRAdCampaignAuditTrailSummary(pradcats_AdCampaignID);
END
GRANT SELECT,INSERT,UPDATE ON CRM.[dbo].[PRAdCampaignAuditTrailSummary] TO BBOS
GO

PRINT 'DATA TABLE-CRMAArchive'
USE CRMArchive
--DROP TABLE dbo.PRAdCampaignAuditTrailSummary
IF OBJECT_ID('dbo.PRAdCampaignAuditTrailSummary', 'U') IS NULL 
BEGIN
	CREATE TABLE dbo.PRAdCampaignAuditTrailSummary(
	[pradcats_AdCampaignAuditTrailSummaryID] [int],
	[pradcats_Deleted] [int] NULL,
	[pradcats_WorkflowId] [int] NULL,
	[pradcats_Secterr] [int] NULL,
	[pradcats_CreatedBy] [int] NULL,
	[pradcats_CreatedDate] [datetime] NULL,
	[pradcats_UpdatedBy] [int] NULL,
	[pradcats_UpdatedDate] [datetime] NULL,
	[pradcats_TimeStamp] [datetime] NULL,
	[pradcats_AdCampaignID] [int] NOT NULL,
	[pradcats_DisplayDate] [datetime] NULL,
	[pradcats_ImpressionCount] [int] NOT NULL,
	[pradcats_ClickCount] [int] NOT NULL,
	PRIMARY KEY CLUSTERED 
	(
		[pradcats_AdCampaignAuditTrailSummaryID] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
	) ON [PRIMARY]

	CREATE INDEX IX_PRAdCampaignAuditTrailSummary_Index01 ON CRMArchive.dbo.PRAdCampaignAuditTrailSummary(pradcats_DisplayDate,pradcats_AdCampaignID);
	CREATE INDEX IX_PRAdCampaignAuditTrailSummary_Index02 ON CRMArchive.dbo.PRAdCampaignAuditTrailSummary(pradcats_AdCampaignID);
END
GO

/*
select * from CRM.dbo.PRAdCampaignAuditTrailSummary
select * from CRMArchive.dbo.PRAdCampaignAuditTrailSummary
*/
