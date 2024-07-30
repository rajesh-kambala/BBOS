SET NOCOUNT ON

--
--  Search and Replace the Year being moved into Cold Storage.  49 occurrences
--
--  FIND: CRMArchive_2019
--  REPLACE: CRMArchive_YYYY
--
--  Then update the @DateThreshold to the correct value
--

DECLARE @ForCommit bit


-- SET this variable to 1 to commit changes
SET @ForCommit = 0

if (@ForCommit = 0) begin
	PRINT '*************************************************************'
	PRINT 'NOTE: COMMIT CHANGES IS TURNED OFF. NO CHANGES WILL BE SAVED!'
	PRINT '*************************************************************'
	PRINT ''
end

DECLARE @Start DateTime
SET @Start = GETDATE()
PRINT 'Execution Start: ' + CONVERT(VARCHAR(20), @Start, 100) + ' on server ' + @@SERVERNAME
PRINT ''

BEGIN TRANSACTION
BEGIN TRY

	DECLARE @DateThreshold datetime = '2019-12-31 11:59 PM'
	DECLARE @ColdStorageID int = 0, @ColdStorageCount int = 0, @AfterCount int = 0

	--
	-- PRAdCampaignAuditTrail
	-- 

	/*
		THIS HAS BEEN REPLACED WITH THE PRAdCampaingAuditTrailSummary MECHANISM


	PRINT 'Moving PRAdCampaignAuditTrail to Cold Storage'
	INSERT INTO CRMArchive.dbo.ColdStorageLog (SourceTable, TargetDatabase, ThresholdDate, BeforeCount, ColdStorageCount, AfterCount, StartDateTime)
	SELECT 'PRAdCampaignAuditTrail', 'CRMArchive_2019', @DateThreshold, COUNT(1), 0, 0, GETDATE() FROM CRMArchive.dbo.PRAdCampaignAuditTrail;
	SET @ColdStorageID = SCOPE_IDENTITY()

	INSERT INTO CRMArchive_2019.dbo.PRAdCampaignAuditTrail
	 SELECT * FROM CRMArchive.dbo.PRAdCampaignAuditTrail
	 WHERE pradcat_CreatedDate <= @DateThreshold
 
	DELETE FROM CRMArchive.dbo.PRAdCampaignAuditTrail WHERE pradcat_AdCampaignAuditTrailID IN (SELECT pradcat_AdCampaignAuditTrailID FROM CRMArchive_2019.dbo.PRAdCampaignAuditTrail);

	SELECT @AfterCount = COUNT(1) FROM CRMArchive.dbo.PRAdCampaignAuditTrail
	SELECT @ColdStorageCount = COUNT(1) FROM CRMArchive_2019.dbo.PRAdCampaignAuditTrail
	UPDATE CRMArchive.dbo.ColdStorageLog 
	   SET ColdStorageCount = @ColdStorageCount,
	       AfterCount = @AfterCount,
		   EndDateTime = GETDATE()
	 WHERE ColdStorageLogID = @ColdStorageID
*/





	PRINT 'Moving PRAdCampaignAuditTrailSummary to Cold Storage'
	INSERT INTO CRMArchive.dbo.ColdStorageLog (SourceTable, TargetDatabase, ThresholdDate, BeforeCount, ColdStorageCount, AfterCount, StartDateTime)
	SELECT 'PRAdCampaignAuditTrailSummary', 'CRMArchive_2019', @DateThreshold, COUNT(1), 0, 0, GETDATE() FROM CRMArchive.dbo.PRAdCampaignAuditTrailSummary;
	SET @ColdStorageID = SCOPE_IDENTITY()

	INSERT INTO CRMArchive_2019.dbo.PRAdCampaignAuditTrailSummary
	 SELECT * FROM CRMArchive.dbo.PRAdCampaignAuditTrailSummary
	 WHERE pradcats_CreatedDate <= @DateThreshold
 
	DELETE FROM CRMArchive.dbo.PRAdCampaignAuditTrailSummary WHERE pradcats_AdCampaignAuditTrailSummaryID IN (SELECT pradcats_AdCampaignAuditTrailSummaryID FROM CRMArchive_2019.dbo.PRAdCampaignAuditTrailSummary);

	SELECT @AfterCount = COUNT(1) FROM CRMArchive.dbo.PRAdCampaignAuditTrailSummary
	SELECT @ColdStorageCount = COUNT(1) FROM CRMArchive_2019.dbo.PRAdCampaignAuditTrailSummary
	UPDATE CRMArchive.dbo.ColdStorageLog 
	   SET ColdStorageCount = @ColdStorageCount,
	       AfterCount = @AfterCount,
		   EndDateTime = GETDATE()
	 WHERE ColdStorageLogID = @ColdStorageID




	--
	-- PRCommunicationLog
	-- 
	PRINT 'Moving PRCommunicationLog to Cold Storage'
	INSERT INTO CRMArchive.dbo.ColdStorageLog (SourceTable, TargetDatabase, ThresholdDate, BeforeCount, ColdStorageCount, AfterCount, StartDateTime)
	SELECT 'PRCommunicationLog', 'CRMArchive_2019', @DateThreshold, COUNT(1), 0, 0, GETDATE() FROM CRMArchive.dbo.PRCommunicationLog;
	SET @ColdStorageID = SCOPE_IDENTITY()

	INSERT INTO CRMArchive_2019.dbo.PRCommunicationLog
	 SELECT * FROM CRMArchive.dbo.PRCommunicationLog
	 WHERE prcoml_CreatedDate <= @DateThreshold
 
	DELETE FROM CRMArchive.dbo.PRCommunicationLog WHERE prcoml_CommunicationLog IN (SELECT prcoml_CommunicationLog FROM CRMArchive_2019.dbo.PRCommunicationLog);

	SELECT @AfterCount = COUNT(1) FROM CRMArchive.dbo.PRCommunicationLog
	SELECT @ColdStorageCount = COUNT(1) FROM CRMArchive_2019.dbo.PRCommunicationLog
	UPDATE CRMArchive.dbo.ColdStorageLog 
	   SET ColdStorageCount = @ColdStorageCount,
	       AfterCount = @AfterCount,
		   EndDateTime = GETDATE()
	 WHERE ColdStorageLogID = @ColdStorageID


	--
	-- PREquifaxAuditLog
	-- 
/*
	THIS IS NO LONGER NEEDED AS EXPIERAN IS NOW IN USE

	PRINT 'Moving PREquifaxAuditLog to Cold Storage'
	INSERT INTO CRMArchive.dbo.ColdStorageLog (SourceTable, TargetDatabase, ThresholdDate, BeforeCount, ColdStorageCount, AfterCount, StartDateTime)
	SELECT 'PREquifaxAuditLog', 'CRMArchive_2019', @DateThreshold, COUNT(1), 0, 0, GETDATE() FROM CRMArchive.dbo.PREquifaxAuditLog;
	SET @ColdStorageID = SCOPE_IDENTITY()

	INSERT INTO CRMArchive_2019.dbo.PREquifaxAuditLog
	 SELECT * FROM CRMArchive.dbo.PREquifaxAuditLog
	 WHERE preqfal_CreatedDate <= @DateThreshold
 
	DELETE FROM CRMArchive.dbo.PREquifaxAuditLog WHERE preqfal_EquifaxAuditLogID IN (SELECT preqfal_EquifaxAuditLogID FROM CRMArchive_2019.dbo.PREquifaxAuditLog);

	SELECT @AfterCount = COUNT(1) FROM CRMArchive.dbo.PREquifaxAuditLog
	SELECT @ColdStorageCount = COUNT(1) FROM CRMArchive_2019.dbo.PREquifaxAuditLog
	UPDATE CRMArchive.dbo.ColdStorageLog 
	   SET ColdStorageCount = @ColdStorageCount,
	       AfterCount = @AfterCount,
		   EndDateTime = GETDATE()
	 WHERE ColdStorageLogID = @ColdStorageID


	--
	-- PREquifaxAuditLogDetail
	-- 
	PRINT 'Moving PREquifaxAuditLogDetail to Cold Storage'
	INSERT INTO CRMArchive.dbo.ColdStorageLog (SourceTable, TargetDatabase, ThresholdDate, BeforeCount, ColdStorageCount, AfterCount, StartDateTime)
	SELECT 'PREquifaxAuditLogDetail', 'CRMArchive_2019', @DateThreshold, COUNT(1), 0, 0, GETDATE() FROM CRMArchive.dbo.PREquifaxAuditLogDetail;
	SET @ColdStorageID = SCOPE_IDENTITY()

	INSERT INTO CRMArchive_2019.dbo.PREquifaxAuditLogDetail
	 SELECT * FROM CRMArchive.dbo.PREquifaxAuditLogDetail
	 WHERE preqfald_CreatedDate <= @DateThreshold
 
	DELETE FROM CRMArchive.dbo.PREquifaxAuditLogDetail WHERE preqfald_EquifaxAuditLogDetailID IN (SELECT preqfald_EquifaxAuditLogDetailID FROM CRMArchive_2019.dbo.PREquifaxAuditLogDetail);

	SELECT @AfterCount = COUNT(1) FROM CRMArchive.dbo.PREquifaxAuditLogDetail
	SELECT @ColdStorageCount = COUNT(1) FROM CRMArchive_2019.dbo.PREquifaxAuditLogDetail
	UPDATE CRMArchive.dbo.ColdStorageLog 
	   SET ColdStorageCount = @ColdStorageCount,
	       AfterCount = @AfterCount,
		   EndDateTime = GETDATE()
	 WHERE ColdStorageLogID = @ColdStorageID
*/

	--
	-- PRExternalLinkAuditTrail
	-- 
	PRINT 'Moving PRExternalLinkAuditTrail to Cold Storage'
	INSERT INTO CRMArchive.dbo.ColdStorageLog (SourceTable, TargetDatabase, ThresholdDate, BeforeCount, ColdStorageCount, AfterCount, StartDateTime)
	SELECT 'PRExternalLinkAuditTrail', 'CRMArchive_2019', @DateThreshold, COUNT(1), 0, 0, GETDATE() FROM CRMArchive.dbo.PRExternalLinkAuditTrail;
	SET @ColdStorageID = SCOPE_IDENTITY()

	INSERT INTO CRMArchive_2019.dbo.PRExternalLinkAuditTrail
	 SELECT * FROM CRMArchive.dbo.PRExternalLinkAuditTrail
	 WHERE prelat_CreatedDate <= @DateThreshold
 
	DELETE FROM CRMArchive.dbo.PRExternalLinkAuditTrail WHERE prelat_ExternalLinkAuditTrailID IN (SELECT prelat_ExternalLinkAuditTrailID FROM CRMArchive_2019.dbo.PRExternalLinkAuditTrail);

	SELECT @AfterCount = COUNT(1) FROM CRMArchive.dbo.PRExternalLinkAuditTrail
	SELECT @ColdStorageCount = COUNT(1) FROM CRMArchive_2019.dbo.PRExternalLinkAuditTrail
	UPDATE CRMArchive.dbo.ColdStorageLog 
	   SET ColdStorageCount = @ColdStorageCount,
	       AfterCount = @AfterCount,
		   EndDateTime = GETDATE()
	 WHERE ColdStorageLogID = @ColdStorageID


	--
	-- PRRequest
	-- 
	PRINT 'Moving PRRequest to Cold Storage'
	INSERT INTO CRMArchive.dbo.ColdStorageLog (SourceTable, TargetDatabase, ThresholdDate, BeforeCount, ColdStorageCount, AfterCount, StartDateTime)
	SELECT 'PRRequest', 'CRMArchive_2019', @DateThreshold, COUNT(1), 0, 0, GETDATE() FROM CRMArchive.dbo.PRRequest;
	SET @ColdStorageID = SCOPE_IDENTITY()

	INSERT INTO CRMArchive_2019.dbo.PRRequest
	 SELECT * FROM CRMArchive.dbo.PRRequest
	 WHERE prreq_CreatedDate <= @DateThreshold
 
	DELETE FROM CRMArchive.dbo.PRRequest WHERE prreq_RequestID IN (SELECT prreq_RequestID FROM CRMArchive_2019.dbo.PRRequest);

	SELECT @AfterCount = COUNT(1) FROM CRMArchive.dbo.PRRequest
	SELECT @ColdStorageCount = COUNT(1) FROM CRMArchive_2019.dbo.PRRequest
	UPDATE CRMArchive.dbo.ColdStorageLog 
	   SET ColdStorageCount = @ColdStorageCount,
	       AfterCount = @AfterCount,
		   EndDateTime = GETDATE()
	 WHERE ColdStorageLogID = @ColdStorageID


	--
	-- PRRequestDetail
	-- 
	PRINT 'Moving PRRequestDetail to Cold Storage'
	INSERT INTO CRMArchive.dbo.ColdStorageLog (SourceTable, TargetDatabase, ThresholdDate, BeforeCount, ColdStorageCount, AfterCount, StartDateTime)
	SELECT 'PRRequestDetail', 'CRMArchive_2019', @DateThreshold, COUNT(1), 0, 0, GETDATE() FROM CRMArchive.dbo.PRRequestDetail;
	SET @ColdStorageID = SCOPE_IDENTITY()

	-- Archive the detail records for those master records that have already been archived
	INSERT INTO CRMArchive_2019.dbo.PRRequestDetail
	 SELECT * FROM CRMArchive.dbo.PRRequestDetail
	 WHERE prrc_RequestID IN (SELECT prreq_RequestID FROM CRMArchive_2019.dbo.PRRequest)
 
	DELETE FROM CRMArchive.dbo.PRRequestDetail WHERE prrc_RequestDetailID IN (SELECT prrc_RequestDetailID FROM CRMArchive_2019.dbo.PRRequestDetail);

	SELECT @AfterCount = COUNT(1) FROM CRMArchive.dbo.PRRequestDetail
	SELECT @ColdStorageCount = COUNT(1) FROM CRMArchive_2019.dbo.PRRequestDetail
	UPDATE CRMArchive.dbo.ColdStorageLog 
	   SET ColdStorageCount = @ColdStorageCount,
	       AfterCount = @AfterCount,
		   EndDateTime = GETDATE()
	 WHERE ColdStorageLogID = @ColdStorageID



	--
	-- PRSearchAuditTrail
	-- 
	PRINT 'Moving PRSearchAuditTrail to Cold Storage'
	INSERT INTO CRMArchive.dbo.ColdStorageLog (SourceTable, TargetDatabase, ThresholdDate, BeforeCount, ColdStorageCount, AfterCount, StartDateTime)
	SELECT 'PRSearchAuditTrail', 'CRMArchive_2019', @DateThreshold, COUNT(1), 0, 0, GETDATE() FROM CRMArchive.dbo.PRSearchAuditTrail;
	SET @ColdStorageID = SCOPE_IDENTITY()

	INSERT INTO CRMArchive_2019.dbo.PRSearchAuditTrail
	 SELECT * FROM CRMArchive.dbo.PRSearchAuditTrail
	 WHERE prsat_CreatedDate <= @DateThreshold
 
	DELETE FROM CRMArchive.dbo.PRSearchAuditTrail WHERE prsat_SearchAuditTrailID IN (SELECT prsat_SearchAuditTrailID FROM CRMArchive_2019.dbo.PRSearchAuditTrail);

	SELECT @AfterCount = COUNT(1) FROM CRMArchive.dbo.PRSearchAuditTrail
	SELECT @ColdStorageCount = COUNT(1) FROM CRMArchive_2019.dbo.PRSearchAuditTrail
	UPDATE CRMArchive.dbo.ColdStorageLog 
	   SET ColdStorageCount = @ColdStorageCount,
	       AfterCount = @AfterCount,
		   EndDateTime = GETDATE()
	 WHERE ColdStorageLogID = @ColdStorageID


	--
	-- PRSearchAuditTrailCriteria
	-- 
	PRINT 'Moving PRSearchAuditTrailCriteria to Cold Storage'
	INSERT INTO CRMArchive.dbo.ColdStorageLog (SourceTable, TargetDatabase, ThresholdDate, BeforeCount, ColdStorageCount, AfterCount, StartDateTime)
	SELECT 'PRSearchAuditTrailCriteria', 'CRMArchive_2019', @DateThreshold, COUNT(1), 0, 0, GETDATE() FROM CRMArchive.dbo.PRSearchAuditTrailCriteria;
	SET @ColdStorageID = SCOPE_IDENTITY()

	-- Archive the detail records for those master records that have already been archived
	INSERT INTO CRMArchive_2019.dbo.PRSearchAuditTrailCriteria
	 SELECT * FROM CRMArchive.dbo.PRSearchAuditTrailCriteria
	 WHERE prsatc_SearchAuditTrailID IN (SELECT prsat_SearchAuditTrailID FROM CRMArchive_2019.dbo.PRSearchAuditTrail)
 
	DELETE FROM CRMArchive.dbo.PRSearchAuditTrailCriteria WHERE prsatc_SearchAuditTrailCriteriaID IN (SELECT prsatc_SearchAuditTrailCriteriaID FROM CRMArchive_2019.dbo.PRSearchAuditTrailCriteria);

	SELECT @AfterCount = COUNT(1) FROM CRMArchive.dbo.PRSearchAuditTrailCriteria
	SELECT @ColdStorageCount = COUNT(1) FROM CRMArchive_2019.dbo.PRSearchAuditTrailCriteria
	UPDATE CRMArchive.dbo.ColdStorageLog 
	   SET ColdStorageCount = @ColdStorageCount,
	       AfterCount = @AfterCount,
		   EndDateTime = GETDATE()
	 WHERE ColdStorageLogID = @ColdStorageID

	--
	-- PRWebAuditTrail
	-- 
	PRINT 'Moving PRWebAuditTrail to Cold Storage'
	INSERT INTO CRMArchive.dbo.ColdStorageLog (SourceTable, TargetDatabase, ThresholdDate, BeforeCount, ColdStorageCount, AfterCount, StartDateTime)
	SELECT 'PRWebAuditTrail', 'CRMArchive_2019', @DateThreshold, COUNT(1), 0, 0, GETDATE() FROM CRMArchive.dbo.PRWebAuditTrail;
	SET @ColdStorageID = SCOPE_IDENTITY()

	INSERT INTO CRMArchive_2019.dbo.PRWebAuditTrail
	 SELECT * FROM CRMArchive.dbo.PRWebAuditTrail
	 WHERE prwsat_CreatedDate <= @DateThreshold
 
	DELETE FROM CRMArchive.dbo.PRWebAuditTrail WHERE prwsat_WebSiteAuditTrailID IN (SELECT prwsat_WebSiteAuditTrailID FROM CRMArchive_2019.dbo.PRWebAuditTrail);

	SELECT @AfterCount = COUNT(1) FROM CRMArchive.dbo.PRWebAuditTrail
	SELECT @ColdStorageCount = COUNT(1) FROM CRMArchive_2019.dbo.PRWebAuditTrail
	UPDATE CRMArchive.dbo.ColdStorageLog 
	   SET ColdStorageCount = @ColdStorageCount,
	       AfterCount = @AfterCount,
		   EndDateTime = GETDATE()
	 WHERE ColdStorageLogID = @ColdStorageID


	--
	-- PRWebServiceAuditTrail
	-- 
	PRINT 'Moving PRWebServiceAuditTrail to Cold Storage'
	INSERT INTO CRMArchive.dbo.ColdStorageLog (SourceTable, TargetDatabase, ThresholdDate, BeforeCount, ColdStorageCount, AfterCount, StartDateTime)
	SELECT 'PRWebServiceAuditTrail', 'CRMArchive_2019', @DateThreshold, COUNT(1), 0, 0, GETDATE() FROM CRMArchive.dbo.PRWebServiceAuditTrail;
	SET @ColdStorageID = SCOPE_IDENTITY()

	INSERT INTO CRMArchive_2019.dbo.PRWebServiceAuditTrail
	 SELECT * FROM CRMArchive.dbo.PRWebServiceAuditTrail
	 WHERE prwsat2_CreatedDate <= @DateThreshold
 
	DELETE FROM CRMArchive.dbo.PRWebServiceAuditTrail WHERE prwsat2_WebServiceAuditTrailID IN (SELECT prwsat2_WebServiceAuditTrailID FROM CRMArchive_2019.dbo.PRWebServiceAuditTrail);

	SELECT @AfterCount = COUNT(1) FROM CRMArchive.dbo.PRWebServiceAuditTrail
	SELECT @ColdStorageCount = COUNT(1) FROM CRMArchive_2019.dbo.PRWebServiceAuditTrail
	UPDATE CRMArchive.dbo.ColdStorageLog 
	   SET ColdStorageCount = @ColdStorageCount,
	       AfterCount = @AfterCount,
		   EndDateTime = GETDATE()
	 WHERE ColdStorageLogID = @ColdStorageID


	SELECT * FROM CRMArchive.dbo.ColdStorageLog WHERE TargetDatabase='CRMArchive_2019'

	if (@ForCommit = 1) begin
		PRINT 'COMMITTING CHANGES'
		COMMIT
	end else begin
		PRINT 'ROLLING BACK ALL CHANGES'
		ROLLBACK TRANSACTION
	end

	END TRY
BEGIN CATCH

	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;

	EXEC CRM.dbo.usp_RethrowError;
END CATCH;

PRINT ''
PRINT 'Execution End: ' + CONVERT(VARCHAR(20), GETDATE(), 100)
PRINT 'Execution Time: ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE())) + ' ms'