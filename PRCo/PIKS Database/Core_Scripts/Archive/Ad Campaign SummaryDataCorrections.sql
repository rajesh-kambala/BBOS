/*
	AFTER INSERTS, SHRINK LOG FILE
*/


USE CRMArchive
PRINT 'DATA CORRECTION-CRMArchive'
DECLARE @Start datetime = GETDATE()
INSERT INTO CRMArchive.dbo.PRAdCampaignAuditTrailSummary (pradcats_AdCampaignAuditTrailSummaryID, pradcats_AdCampaignID, pradcats_DisplayDate, pradcats_ImpressionCount, pradcats_ClickCount, pradcats_CreatedDate, pradcats_UpdatedDate, pradcats_TimeStamp)
	SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS RowNum, pradcat_AdCampaignID,
		CAST(pradcat_CreatedDate as Date) [DisplayDate],
		COUNT(1) ImpressionCount,
		COUNT(pradcat_Clicked) ClickCount,
		@Start, @Start, @Start
	FROM CRMArchive.dbo.PRAdCampaignAuditTrail WITH(NOLOCK)
	WHERE pradcat_CreatedDate < (CAST(GETDATE()-1 AS date))
	GROUP BY pradcat_AdCampaignID,
		CAST(pradcat_CreatedDate as Date)
	ORDER BY pradcat_AdCampaignID,
		CAST(pradcat_CreatedDate as Date)


DECLARE @CRMArchiveRecordCount int
SELECT @CRMArchiveRecordCount = COUNT(1) FROM CRMArchive.dbo.PRAdCampaignAuditTrailSummary


SELECT COUNT(*) [CRMArchive-SummaryCount], (CAST(MIN(pradcats_DisplayDate) as Date)) [Min], (CAST(MAX(pradcats_DisplayDate) as Date)) [Max]  FROM CRMArchive.dbo.PRAdCampaignAuditTrailSummary
SELECT @CRMArchiveRecordCount



PRINT 'DATA CORRECTION-CRM'
USE CRM

--
-- We need to reseed the CRM table to be the max ID from CRMArchive + 1.  This way
-- we avoid an ID collision when archiving.
DBCC CHECKIDENT ('PRAdCampaignAuditTrailSummary', RESEED, @CRMArchiveRecordCount) 


INSERT INTO CRM.dbo.PRAdCampaignAuditTrailSummary (pradcats_AdCampaignID, pradcats_DisplayDate, pradcats_ImpressionCount, pradcats_ClickCount, pradcats_UpdatedDate)
	SELECT pradcat_AdCampaignID,
		CAST(pradcat_CreatedDate as Date) [DisplayDate],
		COUNT(1) ImpressionCount,
		COUNT(pradcat_Clicked) ClickCount,
		CAST(pradcat_CreatedDate as Date)  -- Use the display date as the updated date so these get archived when appropriate
	FROM CRM.dbo.PRAdCampaignAuditTrail WITH(NOLOCK)
	WHERE pradcat_CreatedDate < (CAST(GETDATE()-1 AS date))
	GROUP BY pradcat_AdCampaignID,
		CAST(pradcat_CreatedDate as Date)
	ORDER BY pradcat_AdCampaignID,
		CAST(pradcat_CreatedDate as Date)

GO

/*
	AFTER INSERTS, SHRINK LOG FILE
*/


		
/*
SELECT COUNT(*) [CRM-SummaryCount], (CAST(MIN(pradcats_DisplayDate) as Date)) [Min], (CAST(MAX(pradcats_DisplayDate) as Date)) [Max]  FROM CRM.dbo.PRAdCampaignAuditTrailSummary
SELECT COUNT(*) [CRMArchive-SummaryCount], (CAST(MIN(pradcats_DisplayDate) as Date)) [Min], (CAST(MAX(pradcats_DisplayDate) as Date)) [Max]  FROM CRMArchive.dbo.PRAdCampaignAuditTrailSummary

select * from crm.dbo.PRAdCampaignAuditTrailSummary
select * from crmarchive.dbo.PRAdCampaignAuditTrailSummary

SELECT COUNT(1) CRMCount
  FROM [CRM].[dbo].[PRAdCampaignAuditTrailSummary]
SELECT COUNT(1) CRMArchiveCount
  FROM [CRMArchive].[dbo].[PRAdCampaignAuditTrailSummary]
*/