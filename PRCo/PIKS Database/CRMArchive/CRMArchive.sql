USE CRM

/*
DELETE FROM CRM.dbo.custom_captions WHERE capt_family = 'ArchiveDataThreshold'
exec CRM.dbo.usp_AccpacCreateDropdownValue 'ArchiveDataThreshold', 'Communication', 0, '36'
exec CRM.dbo.usp_AccpacCreateDropdownValue 'ArchiveDataThreshold', 'PRAdCampaignAuditTrail', 0, '12'
exec CRM.dbo.usp_AccpacCreateDropdownValue 'ArchiveDataThreshold', 'PRARAging', 0, '24'
exec CRM.dbo.usp_AccpacCreateDropdownValue 'ArchiveDataThreshold', 'PREquifaxAuditLog', 0, '13'
exec CRM.dbo.usp_AccpacCreateDropdownValue 'ArchiveDataThreshold', 'PRExternalLinkAuditTrail', 0, '13'
exec CRM.dbo.usp_AccpacCreateDropdownValue 'ArchiveDataThreshold', 'PRRequest', 0, '13'
exec CRM.dbo.usp_AccpacCreateDropdownValue 'ArchiveDataThreshold', 'PRSearchAuditTrail', 0, '13'
exec CRM.dbo.usp_AccpacCreateDropdownValue 'ArchiveDataThreshold', 'PRSearchWizardAuditTrail', 0, '132'
exec CRM.dbo.usp_AccpacCreateDropdownValue 'ArchiveDataThreshold', 'PRTESRequest', 0, '24'
exec CRM.dbo.usp_AccpacCreateDropdownValue 'ArchiveDataThreshold', 'PRTransaction', 0, '36'
exec CRM.dbo.usp_AccpacCreateDropdownValue 'ArchiveDataThreshold', 'PRWebAuditTrail', 0, '13'
exec CRM.dbo.usp_AccpacCreateDropdownValue 'ArchiveDataThreshold', 'PRWebServiceAuditTrail', 0, '13'
exec CRM.dbo.usp_AccpacCreateDropdownValue 'ArchiveDataThreshold', 'PRCommunicationLog', 0, '13'
*/
select * from CRM.dbo.custom_captions where capt_family = 'ArchiveDataThreshold'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_ArchivePRTES]'))
    drop procedure [dbo].[usp_ArchivePRTES]
GO




IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ufn_GetArchiveDate]'))
DROP FUNCTION dbo.ufn_GetArchiveDate
GO

CREATE FUNCTION dbo.ufn_GetArchiveDate(@TableName varchar(40))
RETURNS datetime
AS
BEGIN
	DECLARE @ArchiveThresholdDate DATETIME

/*
	SET @ArchiveThresholdDate = DATEADD(day, 0-CAST(CRM.dbo.ufn_GetCustomCaptionValue('ArchiveDataThreshold', @TableName, 'en-us') As Int), GETDATE())
	SET @ArchiveThresholdDate = CONVERT(varchar(10), @ArchiveThresholdDate, 101)
*/

	DECLARE @Month int, @Year int

	SET @ArchiveThresholdDate = DATEADD(month, 0-CAST(CRM.dbo.ufn_GetCustomCaptionValue('ArchiveDataThreshold', @TableName, 'en-us') As Int), GETDATE())
	SET @Month = MONTH(@ArchiveThresholdDate)
	SET @Year = YEAR(@ArchiveThresholdDate)
	SET @ArchiveThresholdDate = CAST(@Year As Varchar(4)) + '-' + CAST(@Month As Varchar(4)) + '-01'


	RETURN @ArchiveThresholdDate
END
Go



IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ufn_GetArchiveTimestamp]'))
	DROP FUNCTION dbo.ufn_GetArchiveTimestamp
GO

CREATE FUNCTION dbo.ufn_GetArchiveTimestamp(@CreateNew bit)
RETURNS varchar(50)
AS
BEGIN

	DECLARE @Timestamp varchar(50)

	IF (@CreateNew = 0) BEGIN

		SET @Timestamp = REPLACE(REPLACE(REPLACE(CONVERT(CHAR(16), CURRENT_TIMESTAMP, 120), '-', ''), ' ', '_'), ':', '')
		
		IF EXISTS (SELECT 'x' FROM CRM.dbo.Custom_Caption WHERE capt_family = 'ArchiveTimestamp' AND capt_code = 'ArchiveTimestamp') BEGIN
		
			UPDATE CRM.dbo.CustomCaptions 
			   SET capt_us = @Timestamp,
			       capt_UpdatedDate = GETDATE(),
				   capt_Timestamp = GETDATE()
			 WHERE capt_family = 'ArchiveTimestamp' 
			   AND capt_code = 'ArchiveTimestamp'
		
		END ELSE BEGIN

			DECLARE @CustomCaptionID int
			EXEC CRM.dbo.usp_GetNextId 'CustomCaptions', @CustomCaptionID output
			
			INSERT INTO CRM.dbo.CustomCaptions (capt_CaptionID, capt_FamilyType, capt_Family, capt_Code, capt_US, capt_CreatedDate)
			VALUES (@CustomCaptionID, 'Choices', 'ArchiveTimestamp', 'ArchiveTimestamp', @Timestamp, GETDATE());
		END
		
	END ELSE BEGIN
		SET @Timestamp = CRM.dbo.ufn_GetCustomCaptionValue('ArchiveTimestamp', 'ArchiveTimestamp', 'en-us')
	END

	RETURN @Timestamp
END
Go



	DECLARE @ArchiveThresholdDate DATETIME

/*
	SET @ArchiveThresholdDate = DATEADD(day, 0-CAST(CRM.dbo.ufn_GetCustomCaptionValue('ArchiveDataThreshold', @TableName, 'en-us') As Int), GETDATE())
	SET @ArchiveThresholdDate = CONVERT(varchar(10), @ArchiveThresholdDate, 101)
*/

	DECLARE @Month int, @Year int

	SET @ArchiveThresholdDate = DATEADD(month, 0-CAST(CRM.dbo.ufn_GetCustomCaptionValue('ArchiveDataThreshold', @TableName, 'en-us') As Int), GETDATE())
	SET @Month = MONTH(@ArchiveThresholdDate)
	SET @Year = YEAR(@ArchiveThresholdDate)
	SET @ArchiveThresholdDate = CAST(@Year As Varchar(4)) + '-' + CAST(@Month As Varchar(4)) + '-01'


	RETURN @ArchiveThresholdDate
END
Go



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_ArchivePRWebAuditTrail]'))
    drop procedure [dbo].[usp_ArchivePRWebAuditTrail]
GO

CREATE PROCEDURE dbo.usp_ArchivePRWebAuditTrail 
	@CommitToArchive bit = 0
As
BEGIN
	SET NOCOUNT ON

	IF (@CommitToArchive = 0) BEGIN
		PRINT '*************************************************************'
		PRINT 'NOTE: COMMIT CHANGES IS TURNED OFF. NO CHANGES WILL BE SAVED!'
		PRINT '*************************************************************'
		PRINT ''
	END

	DECLARE @ArchiveThresholdDate datetime
	DECLARE @BeforeCount int, @AfterCount int, @ArchiveCount int
	DECLARE @ArchiveRowCount int, @DoubleCheckCount int
	DECLARE @ArchiveLogID int
	
	SET @ArchiveThresholdDate = CRM.dbo.ufn_GetArchiveDate('PRWebAuditTrail');

	INSERT INTO CRMArchive.dbo.ArchiveLog (SourceTable, TargetTable, DateField, ArchiveThresholdDate, Status, StartDateTime)
	VALUES ('CRM.dbo.PRWebAuditTrail', 'CRMArchive.dbo.PRWebAuditTrail', 'prwsat_UpdatedDate', @ArchiveThresholdDate, 'In Progress', GETDATE());
	SELECT @ArchiveLogID = SCOPE_IDENTITY();

	BEGIN TRANSACTION
	BEGIN TRY

		-- How many records already exist in the Archive table?
		SELECT @BeforeCount = COUNT(1)
		  FROM CRMArchive.dbo.PRWebAuditTrail;

		-- How many records will we be archiving?
		SELECT @ArchiveCount = COUNT(1)
		  FROM CRM.dbo.PRWebAuditTrail
		 WHERE prwsat_UpdatedDate <= @ArchiveThresholdDate;

		-- Archive the records
		INSERT INTO CRMArchive.dbo.PRWebAuditTrail
		SELECT * FROM CRM.dbo.PRWebAuditTrail
 		 WHERE prwsat_UpdatedDate <= @ArchiveThresholdDate;
		SET @ArchiveRowCount = @@ROWCOUNT;

		-- Confirm the archive count
		IF (@ArchiveCount != @ArchiveRowCount) BEGIN
			Print 'ArchiveCount != ArchiveRowCount'
			RAISERROR ('ArchiveCount != ArchiveRowCount', 16, 1)		
		END

		-- Confirm the physical count matches the archive count
		SELECT @AfterCount = COUNT(1)
		  FROM CRMArchive.dbo.PRWebAuditTrail;
		IF (@ArchiveCount != (@AfterCount - @BeforeCount)) BEGIN
			Print 'ArchiveCount != (AfterCount - BeforeCount)'
			RAISERROR ('ArchiveCount != (AfterCount - BeforeCount)', 16, 1)
		END

		-- One final check.  Make sure all records we're about
		-- to delete exist in the archive table.
		SELECT @DoubleCheckCount = COUNT(1)
		  FROM CRM.dbo.PRWebAuditTrail
		 WHERE prwsat_UpdatedDate <= @ArchiveThresholdDate
			AND prwsat_WebSiteAuditTrailID NOT IN (
				SELECT prwsat_WebSiteAuditTrailID
				  FROM CRMArchive.dbo.PRWebAuditTrail);
	            
		IF (@DoubleCheckCount != 0) BEGIN
			Print 'DoubleCheckCount > 0'
			RAISERROR ('DoubleCheckCount > 0', 16, 1)
		END

		-- Remove the archived records
		DELETE FROM CRM.dbo.PRWebAuditTrail
 		 WHERE prwsat_UpdatedDate <= @ArchiveThresholdDate;

 		-- Update our archive log
		UPDATE CRMArchive.dbo.ArchiveLog
		   SET EndDateTime = GetDate(),
			   Status = 'Completed',
			   BeforeCount = @BeforeCount,
			   AfterCount = @AfterCount,
			   ArchiveCount = @ArchiveCount
		 WHERE ArchiveLogID = @ArchiveLogID;


		IF (@CommitToArchive = 1) BEGIN
			PRINT 'COMMITTING ARCHIVE UPDATE'
			COMMIT
		END ELSE BEGIN
			PRINT 'ROLLING BACK ARCHIVE UPDATE'
			SELECT * FROM CRMArchive.dbo.ArchiveLog WHERE ArchiveLogID = @ArchiveLogID;
			ROLLBACK TRANSACTION
			DELETE FROM CRMArchive.dbo.ArchiveLog WHERE ArchiveLogID = @ArchiveLogID;
		END

	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		UPDATE CRMArchive.dbo.ArchiveLog
		   SET EndDateTime = GetDate(),
			   Status = 'Error',
			   StatusMsg =  ERROR_MESSAGE(),
			   BeforeCount = @BeforeCount,
			   AfterCount = @AfterCount,
			   ArchiveCount = @ArchiveCount
		 WHERE ArchiveLogID = @ArchiveLogID;

		EXEC CRM.dbo.usp_RethrowError

	END CATCH;

	SET NOCOUNT OFF
END
Go


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_ArchiveCommunication]'))
    drop procedure [dbo].[usp_ArchiveCommunication]
GO

CREATE PROCEDURE dbo.usp_ArchiveCommunication
	@CommitToArchive bit = 0
as
BEGIN
	SET NOCOUNT ON

	IF (@CommitToArchive = 0) BEGIN
		PRINT '*************************************************************'
		PRINT 'NOTE: COMMIT CHANGES IS TURNED OFF. NO CHANGES WILL BE SAVED!'
		PRINT '*************************************************************'
		PRINT ''
	END


	DECLARE @ArchiveThresholdDate datetime
	DECLARE @BeforeCount int, @AfterCount int, @ArchiveCount int
	DECLARE @ArchiveRowCount int, @DoubleCheckCount int

	DECLARE @CommLink_ArchiveLogID int, @Comm_ArchiveLogID int
	DECLARE @TableCount int
	
	SET @ArchiveThresholdDate = CRM.dbo.ufn_GetArchiveDate('Communication');
 
	INSERT INTO CRMArchive.dbo.ArchiveLog (SourceTable, TargetTable, DateField, ArchiveThresholdDate, Status, StartDateTime)
	VALUES ('CRM.dbo.Comm_Link', 'CRMArchive.dbo.Comm_Link', 'comm_UpdatedDate', @ArchiveThresholdDate, 'In Progress', GETDATE());
	SELECT @CommLink_ArchiveLogID = SCOPE_IDENTITY();

	INSERT INTO CRMArchive.dbo.ArchiveLog (SourceTable, TargetTable, DateField, ArchiveThresholdDate, Status, StartDateTime)
	VALUES ('CRM.dbo.Communication', 'CRMArchive.dbo.Communication', 'comm_UpdatedDate', @ArchiveThresholdDate, 'In Progress', GETDATE());
	SELECT @Comm_ArchiveLogID = SCOPE_IDENTITY();

	DECLARE @ArchiveIDs table (
		RecordID int
	)	

	INSERT INTO @ArchiveIDs 
	SELECT Comm_CommunicationId
      FROM CRM.dbo.vCommunication
     WHERE comm_UpdatedDate <= @ArchiveThresholdDate
	   AND Comm_CommunicationId > 0
	   AND cmli_CommLinkID > 0;

	BEGIN TRANSACTION
	BEGIN TRY


		/* 
		* First process the Detail table
		*/
        SET @TableCount = 1;

		-- How many records already exist in the Archive table?
		SELECT @BeforeCount = COUNT(1)
		  FROM CRMArchive.dbo.Comm_Link;

		-- How many records will we be archiving?
		SELECT @ArchiveCount = COUNT(1)
		  FROM CRM.dbo.Comm_Link
		 WHERE CmLi_Comm_CommunicationId IN 
				(SELECT RecordID FROM @ArchiveIDs);

		-- Archive the records
		INSERT INTO CRMArchive.dbo.Comm_Link
		SELECT * FROM CRM.dbo.Comm_Link
		 WHERE CmLi_Comm_CommunicationId IN 
				(SELECT RecordID FROM @ArchiveIDs);
		SET @ArchiveRowCount = @@ROWCOUNT;

		-- Confirm the archive count
		IF (@ArchiveCount != @ArchiveRowCount) BEGIN
			Print 'Comm_Link: ArchiveCount != ArchiveRowCount'
			RAISERROR ('Comm_Link: ArchiveCount != ArchiveRowCount', 16, 1)		
			RETURN
		END

		-- Confirm the physical count matches the archive count
		SELECT @AfterCount = COUNT(1)
		  FROM CRMArchive.dbo.Comm_Link;
		IF (@ArchiveCount != (@AfterCount - @BeforeCount)) BEGIN
			Print 'Comm_Link: ArchiveCount != (AfterCount - BeforeCount)'
			RAISERROR ('Comm_Link: ArchiveCount != (AfterCount - BeforeCount)', 16, 1)
		END

		-- One final check.  Make sure all records we're about
		-- to delete exist in the archive table.
		SELECT @DoubleCheckCount = COUNT(1)
		  FROM CRM.dbo.Comm_Link
		 WHERE CmLi_Comm_CommunicationId IN 
				(SELECT RecordID FROM @ArchiveIDs)
		   AND CmLi_CommLinkId NOT IN 
                (SELECT CmLi_CommLinkId FROM CRMArchive.dbo.Comm_Link);
	            
		IF (@DoubleCheckCount != 0) BEGIN
			Print 'Comm_Link: DoubleCheckCount > 0'
			RAISERROR ('Comm_Link: DoubleCheckCount > 0', 16, 1)
		END

		-- Remove the archived records
		DELETE FROM CRM.dbo.Comm_Link
		 WHERE CmLi_Comm_CommunicationId IN 
				(SELECT RecordID FROM @ArchiveIDs);

 		-- Update our archive log
		UPDATE CRMArchive.dbo.ArchiveLog
		   SET EndDateTime = GetDate(),
			   Status = 'Completed',
			   BeforeCount = @BeforeCount,
			   AfterCount = @AfterCount,
			   ArchiveCount = @ArchiveCount
		 WHERE ArchiveLogID = @CommLink_ArchiveLogID;


		/* 
		* Now process the Master table
		*/
        SET @TableCount = 2;

		-- How many records already exist in the Archive table?
		SELECT @BeforeCount = COUNT(1)
		  FROM CRMArchive.dbo.Communication;

		-- How many records will we be archiving?
		SELECT @ArchiveCount = COUNT(1)
		  FROM CRM.dbo.Communication
		 WHERE Comm_CommunicationId IN 
				(SELECT RecordID FROM @ArchiveIDs);

		-- Archive the records
		INSERT INTO CRMArchive.dbo.Communication
		SELECT * FROM CRM.dbo.Communication
		 WHERE Comm_CommunicationId IN 
				(SELECT RecordID FROM @ArchiveIDs);
		SET @ArchiveRowCount = @@ROWCOUNT;

		-- Confirm the archive count
		IF (@ArchiveCount != @ArchiveRowCount) BEGIN
			Print 'Communication: ArchiveCount != ArchiveRowCount'
			RAISERROR ('Communication: ArchiveCount != ArchiveRowCount', 16, 1)		
		END

		-- Confirm the physical count matches the archive count
		SELECT @AfterCount = COUNT(1)
		  FROM CRMArchive.dbo.Communication;
		IF (@ArchiveCount != (@AfterCount - @BeforeCount)) BEGIN
			Print 'Communication: ArchiveCount != (AfterCount - BeforeCount)'
			RAISERROR ('Communication: ArchiveCount != (AfterCount - BeforeCount)', 16, 1)
		END

		-- One final check.  Make sure all records we're about
		-- to delete exist in the archive table.
		SELECT @DoubleCheckCount = COUNT(1)
		  FROM CRM.dbo.Communication
		 WHERE Comm_CommunicationId IN 
				(SELECT RecordID FROM @ArchiveIDs)
		   AND Comm_CommunicationId NOT IN 
                (SELECT Comm_CommunicationId FROM CRMArchive.dbo.Communication);
	            
		IF (@DoubleCheckCount != 0) BEGIN
			Print 'Communication: DoubleCheckCount > 0'
			RAISERROR ('Communication: DoubleCheckCount > 0', 16, 1)
		END

		-- Remove the archived records
		DELETE FROM CRM.dbo.Communication
		 WHERE Comm_CommunicationId IN 
				(SELECT RecordID FROM @ArchiveIDs);

 		-- Update our archive log
		UPDATE CRMArchive.dbo.ArchiveLog
		   SET EndDateTime = GetDate(),
			   Status = 'Completed',
			   BeforeCount = @BeforeCount,
			   AfterCount = @AfterCount,
			   ArchiveCount = @ArchiveCount
		 WHERE ArchiveLogID = @Comm_ArchiveLogID;


		IF (@CommitToArchive = 1) BEGIN
			PRINT 'COMMITTING ARCHIVE UPDATE'
			COMMIT
		END ELSE BEGIN
			PRINT 'ROLLING BACK ARCHIVE UPDATE'
			SELECT * FROM CRMArchive.dbo.ArchiveLog WHERE ArchiveLogID IN (@CommLink_ArchiveLogID, @Comm_ArchiveLogID);
			ROLLBACK TRANSACTION
			DELETE FROM CRMArchive.dbo.ArchiveLog WHERE ArchiveLogID IN (@CommLink_ArchiveLogID, @Comm_ArchiveLogID);
		END

		
	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		IF (@TableCount = 1) BEGIN

			UPDATE CRMArchive.dbo.ArchiveLog
			   SET EndDateTime = GetDate(),
				   Status = 'Error',
				   StatusMsg =  ERROR_MESSAGE(),
				   BeforeCount = @BeforeCount,
				   AfterCount = @AfterCount,
				   ArchiveCount = @ArchiveCount
			 WHERE ArchiveLogID = @CommLink_ArchiveLogID;


			UPDATE CRMArchive.dbo.ArchiveLog
			   SET EndDateTime = GetDate(),
				   Status = 'Error',
				   StatusMsg =  'Error archiving Comm_Link'
			 WHERE ArchiveLogID = @Comm_ArchiveLogID;

		END ELSE BEGIN

			UPDATE CRMArchive.dbo.ArchiveLog
			   SET EndDateTime = GetDate(),
				   Status = 'Error',
				   StatusMsg =  ERROR_MESSAGE(),
				   BeforeCount = @BeforeCount,
				   AfterCount = @AfterCount,
				   ArchiveCount = @ArchiveCount
			 WHERE ArchiveLogID = @Comm_ArchiveLogID;


			UPDATE CRMArchive.dbo.ArchiveLog
			   SET EndDateTime = GetDate(),
				   Status = 'Error',
				   StatusMsg =  'Error archiving Communication'
			 WHERE ArchiveLogID = @CommLink_ArchiveLogID;
		END

		EXEC CRM.dbo.usp_RethrowError

	END CATCH;
END
Go


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_ArchivePRAdCampaignAuditTrail]'))
    drop procedure [dbo].[usp_ArchivePRAdCampaignAuditTrail]
GO

CREATE PROCEDURE dbo.usp_ArchivePRAdCampaignAuditTrail
	@CommitToArchive bit = 0
As
BEGIN
	SET NOCOUNT ON

	IF (@CommitToArchive = 0) BEGIN
		PRINT '*************************************************************'
		PRINT 'NOTE: COMMIT CHANGES IS TURNED OFF. NO CHANGES WILL BE SAVED!'
		PRINT '*************************************************************'
		PRINT ''
	END

	DECLARE @ArchiveThresholdDate datetime
	DECLARE @BeforeCount int, @AfterCount int, @ArchiveCount int
	DECLARE @ArchiveRowCount int, @DoubleCheckCount int
	DECLARE @ArchiveLogID int
	
	SET @ArchiveThresholdDate = CRM.dbo.ufn_GetArchiveDate('PRAdCampaignAuditTrailSummary');
 
	INSERT INTO CRMArchive.dbo.ArchiveLog (SourceTable, TargetTable, DateField, ArchiveThresholdDate, Status, StartDateTime)
	VALUES ('CRM.dbo.PRAdCampaignAuditTrailSummary', 'CRMArchive.dbo.PRAdCampaignAuditTrailSummary', 'pradcat_UpdatedDate', @ArchiveThresholdDate, 'In Progress', GETDATE());
	SELECT @ArchiveLogID = SCOPE_IDENTITY();

	BEGIN TRANSACTION
	BEGIN TRY

		-- How many records already exist in the Archive table?
		SELECT @BeforeCount = COUNT(1)
		  FROM CRMArchive.dbo.PRAdCampaignAuditTrailSummary;

		-- How many records will we be archiving?
		SELECT @ArchiveCount = COUNT(1)
		  FROM CRM.dbo.PRAdCampaignAuditTrailSummary
		 WHERE pradcats_UpdatedDate <= @ArchiveThresholdDate;

		-- Archive the records
		INSERT INTO CRMArchive.dbo.PRAdCampaignAuditTrailSummary
		SELECT * FROM CRM.dbo.PRAdCampaignAuditTrailSummary
 		 WHERE pradcats_UpdatedDate <= @ArchiveThresholdDate;
		SET @ArchiveRowCount = @@ROWCOUNT;

		-- Confirm the archive count
		IF (@ArchiveCount != @ArchiveRowCount) BEGIN
			Print 'ArchiveCount != ArchiveRowCount'
			RAISERROR ('ArchiveCount != ArchiveRowCount', 16, 1)		
		END

		-- Confirm the physical count matches the archive count
		SELECT @AfterCount = COUNT(1)
		  FROM CRMArchive.dbo.PRAdCampaignAuditTrailSummary;
		IF (@ArchiveCount != (@AfterCount - @BeforeCount)) BEGIN
			Print 'ArchiveCount != (AfterCount - BeforeCount)'
			RAISERROR ('ArchiveCount != (AfterCount - BeforeCount)', 16, 1)
		END

		-- One final check.  Make sure all records we're about
		-- to delete exist in the archive table.
		SELECT @DoubleCheckCount = COUNT(1)
		  FROM CRM.dbo.PRAdCampaignAuditTrailSummary
		 WHERE pradcats_UpdatedDate <= @ArchiveThresholdDate
			AND pradcats_AdCampaignAuditTrailSummaryID NOT IN (
				SELECT pradcats_AdCampaignAuditTrailSummaryID
				  FROM CRMArchive.dbo.PRAdCampaignAuditTrailSummary);
	            
		IF (@DoubleCheckCount != 0) BEGIN
			Print 'DoubleCheckCount > 0'
			RAISERROR ('DoubleCheckCount > 0', 16, 1)
		END

		-- Remove the archived records
		DELETE FROM CRM.dbo.PRAdCampaignAuditTrailSummary
 		 WHERE pradcats_UpdatedDate <= @ArchiveThresholdDate;

 		-- Update our archive log
		UPDATE CRMArchive.dbo.ArchiveLog
		   SET EndDateTime = GetDate(),
			   Status = 'Completed',
			   BeforeCount = @BeforeCount,
			   AfterCount = @AfterCount,
			   ArchiveCount = @ArchiveCount
		 WHERE ArchiveLogID = @ArchiveLogID;


		IF (@CommitToArchive = 1) BEGIN
			PRINT 'COMMITTING ARCHIVE UPDATE'
			COMMIT
		END ELSE BEGIN
			PRINT 'ROLLING BACK ARCHIVE UPDATE'
			SELECT * FROM CRMArchive.dbo.ArchiveLog WHERE ArchiveLogID = @ArchiveLogID;
			ROLLBACK TRANSACTION
			DELETE FROM CRMArchive.dbo.ArchiveLog WHERE ArchiveLogID = @ArchiveLogID;
		END

	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		UPDATE CRMArchive.dbo.ArchiveLog
		   SET EndDateTime = GetDate(),
			   Status = 'Error',
			   StatusMsg =  ERROR_MESSAGE(),
			   BeforeCount = @BeforeCount,
			   AfterCount = @AfterCount,
			   ArchiveCount = @ArchiveCount
		 WHERE ArchiveLogID = @ArchiveLogID;

		EXEC CRM.dbo.usp_RethrowError

	END CATCH;
END
Go




if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_ArchivePREquifaxAuditLog]'))
    drop procedure [dbo].[usp_ArchivePREquifaxAuditLog]
GO

CREATE PROCEDURE dbo.usp_ArchivePREquifaxAuditLog
	@CommitToArchive bit = 0
As
BEGIN
	SET NOCOUNT ON

	IF (@CommitToArchive = 0) BEGIN
		PRINT '*************************************************************'
		PRINT 'NOTE: COMMIT CHANGES IS TURNED OFF. NO CHANGES WILL BE SAVED!'
		PRINT '*************************************************************'
		PRINT ''
	END

	DECLARE @ArchiveThresholdDate datetime
	DECLARE @BeforeCount int, @AfterCount int, @ArchiveCount int
	DECLARE @ArchiveRowCount int, @DoubleCheckCount int

	DECLARE @Detail_ArchiveLogID int, @Master_ArchiveLogID int
	DECLARE @TableCount int
	
	SET @ArchiveThresholdDate = CRM.dbo.ufn_GetArchiveDate('PREquifaxAuditLog');

	INSERT INTO CRMArchive.dbo.ArchiveLog (SourceTable, TargetTable, DateField, ArchiveThresholdDate, Status, StartDateTime)
	VALUES ('CRM.dbo.PREquifaxAuditLog', 'CRMArchive.dbo.PREquifaxAuditLog', 'preqfal_UpdatedDate', @ArchiveThresholdDate, 'In Progress', GETDATE());
	SELECT @Master_ArchiveLogID = SCOPE_IDENTITY();
 
	INSERT INTO CRMArchive.dbo.ArchiveLog (SourceTable, TargetTable, DateField, ArchiveThresholdDate, Status, StartDateTime)
	VALUES ('CRM.dbo.PREquifaxAuditLogDetail', 'CRMArchive.dbo.PREquifaxAuditLogDetail', 'preqfal_UpdatedDate', @ArchiveThresholdDate, 'In Progress', GETDATE());
	SELECT @Detail_ArchiveLogID = SCOPE_IDENTITY();


	DECLARE @ArchiveIDs table (
		RecordID int
	)	

	INSERT INTO @ArchiveIDs 
	SELECT preqfal_EquifaxAuditLogID
      FROM CRM.dbo.PREquifaxAuditLog
     WHERE preqfal_UpdatedDate <= @ArchiveThresholdDate;

	BEGIN TRANSACTION
	BEGIN TRY


		/* 
		* First process the detail table
		*/
        SET @TableCount = 1;

		-- How many records already exist in the Archive table?
		SELECT @BeforeCount = COUNT(1)
		  FROM CRMArchive.dbo.PREquifaxAuditLogDetail;

		-- How many records will we be archiving?
		SELECT @ArchiveCount = COUNT(1)
		  FROM CRM.dbo.PREquifaxAuditLogDetail
		 WHERE preqfald_EquifaxAuditLogID IN 
				(SELECT RecordID FROM @ArchiveIDs);

		-- Archive the records
		INSERT INTO CRMArchive.dbo.PREquifaxAuditLogDetail
		SELECT * FROM CRM.dbo.PREquifaxAuditLogDetail
		 WHERE preqfald_EquifaxAuditLogID IN 
				(SELECT RecordID FROM @ArchiveIDs);
		SET @ArchiveRowCount = @@ROWCOUNT;

		-- Confirm the archive count
		IF (@ArchiveCount != @ArchiveRowCount) BEGIN
			Print 'PREquifaxAuditLogDetail: ArchiveCount != ArchiveRowCount'
			RAISERROR ('PREquifaxAuditLogDetail: ArchiveCount != ArchiveRowCount', 16, 1)		
		END

		-- Confirm the physical count matches the archive count
		SELECT @AfterCount = COUNT(1)
		  FROM CRMArchive.dbo.PREquifaxAuditLogDetail;
		IF (@ArchiveCount != (@AfterCount - @BeforeCount)) BEGIN
			Print 'PREquifaxAuditLogDetail: ArchiveCount != (AfterCount - BeforeCount)'
			RAISERROR ('PREquifaxAuditLogDetail: ArchiveCount != (AfterCount - BeforeCount)', 16, 1)
		END

		-- One final check.  Make sure all records we're about
		-- to delete exist in the archive table.
		SELECT @DoubleCheckCount = COUNT(1)
		  FROM CRM.dbo.PREquifaxAuditLogDetail
		 WHERE preqfald_EquifaxAuditLogID IN 
				(SELECT RecordID FROM @ArchiveIDs)
		   AND preqfald_EquifaxAuditLogDetailID NOT IN 
                (SELECT preqfald_EquifaxAuditLogDetailID FROM CRMArchive.dbo.PREquifaxAuditLogDetail);
	            
		IF (@DoubleCheckCount != 0) BEGIN
			Print 'PREquifaxAuditLogDetail: DoubleCheckCount > 0'
			RAISERROR ('PREquifaxAuditLogDetail: DoubleCheckCount > 0', 16, 1)
		END

		-- Remove the archived records
		DELETE FROM CRM.dbo.PREquifaxAuditLogDetail
		 WHERE preqfald_EquifaxAuditLogID IN 
				(SELECT RecordID FROM @ArchiveIDs);

 		-- Update our archive log
		UPDATE CRMArchive.dbo.ArchiveLog
		   SET EndDateTime = GetDate(),
			   Status = 'Completed',
			   BeforeCount = @BeforeCount,
			   AfterCount = @AfterCount,
			   ArchiveCount = @ArchiveCount
		 WHERE ArchiveLogID = @Detail_ArchiveLogID;


		/* 
		* Now process the Master table
		*/
        SET @TableCount = 2;

		-- How many records already exist in the Archive table?
		SELECT @BeforeCount = COUNT(1)
		  FROM CRMArchive.dbo.PREquifaxAuditLog;

		-- How many records will we be archiving?
		SELECT @ArchiveCount = COUNT(1)
		  FROM CRM.dbo.PREquifaxAuditLog
		 WHERE preqfal_EquifaxAuditLogID IN 
				(SELECT RecordID FROM @ArchiveIDs);

		-- Archive the records
		INSERT INTO CRMArchive.dbo.PREquifaxAuditLog
		SELECT * FROM CRM.dbo.PREquifaxAuditLog
		 WHERE preqfal_EquifaxAuditLogID IN 
				(SELECT RecordID FROM @ArchiveIDs);
		SET @ArchiveRowCount = @@ROWCOUNT;

		-- Confirm the archive count
		IF (@ArchiveCount != @ArchiveRowCount) BEGIN
			Print 'PREquifaxAuditLog: ArchiveCount != ArchiveRowCount'
			RAISERROR ('PREquifaxAuditLog: ArchiveCount != ArchiveRowCount', 16, 1)		
		END

		-- Confirm the physical count matches the archive count
		SELECT @AfterCount = COUNT(1)
		  FROM CRMArchive.dbo.PREquifaxAuditLog;
		IF (@ArchiveCount != (@AfterCount - @BeforeCount)) BEGIN
			Print 'PREquifaxAuditLog: ArchiveCount != (AfterCount - BeforeCount)'
			RAISERROR ('PREquifaxAuditLog: ArchiveCount != (AfterCount - BeforeCount)', 16, 1)
		END

		-- One final check.  Make sure all records we're about
		-- to delete exist in the archive table.
		SELECT @DoubleCheckCount = COUNT(1)
		  FROM CRM.dbo.PREquifaxAuditLog
		 WHERE preqfal_EquifaxAuditLogID IN 
				(SELECT RecordID FROM @ArchiveIDs)
		   AND preqfal_EquifaxAuditLogID NOT IN 
                (SELECT preqfal_EquifaxAuditLogID FROM CRMArchive.dbo.PREquifaxAuditLog);
	            
		IF (@DoubleCheckCount != 0) BEGIN
			Print 'PREquifaxAuditLog: DoubleCheckCount > 0'
			RAISERROR ('PREquifaxAuditLog: DoubleCheckCount > 0', 16, 1)
		END

		-- Remove the archived records
		DELETE FROM CRM.dbo.PREquifaxAuditLog
		 WHERE preqfal_EquifaxAuditLogID IN 
				(SELECT RecordID FROM @ArchiveIDs);

 		-- Update our archive log
		UPDATE CRMArchive.dbo.ArchiveLog
		   SET EndDateTime = GetDate(),
			   Status = 'Completed',
			   BeforeCount = @BeforeCount,
			   AfterCount = @AfterCount,
			   ArchiveCount = @ArchiveCount
		 WHERE ArchiveLogID = @Master_ArchiveLogID;


		IF (@CommitToArchive = 1) BEGIN
			PRINT 'COMMITTING ARCHIVE UPDATE'
			COMMIT
		END ELSE BEGIN
			PRINT 'ROLLING BACK ARCHIVE UPDATE'
			SELECT * FROM CRMArchive.dbo.ArchiveLog WHERE ArchiveLogID IN (@Master_ArchiveLogID, @Detail_ArchiveLogID);
			ROLLBACK TRANSACTION
			DELETE FROM CRMArchive.dbo.ArchiveLog WHERE ArchiveLogID IN (@Master_ArchiveLogID, @Detail_ArchiveLogID);
		END


	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		IF (@TableCount = 1) BEGIN

			UPDATE CRMArchive.dbo.ArchiveLog
			   SET EndDateTime = GetDate(),
				   Status = 'Error',
				   StatusMsg =  ERROR_MESSAGE(),
				   BeforeCount = @BeforeCount,
				   AfterCount = @AfterCount,
				   ArchiveCount = @ArchiveCount
			 WHERE ArchiveLogID = @Detail_ArchiveLogID;


			UPDATE CRMArchive.dbo.ArchiveLog
			   SET EndDateTime = GetDate(),
				   Status = 'Error',
				   StatusMsg =  'Error archiving PREquifaxAuditLogDetail'
			 WHERE ArchiveLogID = @Master_ArchiveLogID;

		END ELSE BEGIN

			UPDATE CRMArchive.dbo.ArchiveLog
			   SET EndDateTime = GetDate(),
				   Status = 'Error',
				   StatusMsg =  ERROR_MESSAGE(),
				   BeforeCount = @BeforeCount,
				   AfterCount = @AfterCount,
				   ArchiveCount = @ArchiveCount
			 WHERE ArchiveLogID = @Master_ArchiveLogID;


			UPDATE CRMArchive.dbo.ArchiveLog
			   SET EndDateTime = GetDate(),
				   Status = 'Error',
				   StatusMsg =  'Error archiving PREquifaxAuditLog'
			 WHERE ArchiveLogID = @Detail_ArchiveLogID;
		END

		EXEC CRM.dbo.usp_RethrowError

	END CATCH;
END
Go



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_ArchivePRExternalLinkAuditTrail]'))
    drop procedure [dbo].[usp_ArchivePRExternalLinkAuditTrail]
GO

CREATE PROCEDURE dbo.usp_ArchivePRExternalLinkAuditTrail
	@CommitToArchive bit = 0
As
BEGIN
	SET NOCOUNT ON

	IF (@CommitToArchive = 0) BEGIN
		PRINT '*************************************************************'
		PRINT 'NOTE: COMMIT CHANGES IS TURNED OFF. NO CHANGES WILL BE SAVED!'
		PRINT '*************************************************************'
		PRINT ''
	END

	DECLARE @ArchiveThresholdDate datetime
	DECLARE @BeforeCount int, @AfterCount int, @ArchiveCount int
	DECLARE @ArchiveRowCount int, @DoubleCheckCount int
	DECLARE @ArchiveLogID int
	
	SET @ArchiveThresholdDate = CRM.dbo.ufn_GetArchiveDate('PRExternalLinkAuditTrail');

	INSERT INTO CRMArchive.dbo.ArchiveLog (SourceTable, TargetTable, DateField, ArchiveThresholdDate, Status, StartDateTime)
	VALUES ('CRM.dbo.PRExternalLinkAuditTrail', 'CRMArchive.dbo.PRExternalLinkAuditTrail', 'prelat_UpdatedDate', @ArchiveThresholdDate, 'In Progress', GETDATE());
	SELECT @ArchiveLogID = SCOPE_IDENTITY();

	BEGIN TRANSACTION
	BEGIN TRY

		-- How many records already exist in the Archive table?
		SELECT @BeforeCount = COUNT(1)
		  FROM CRMArchive.dbo.PRExternalLinkAuditTrail;

		-- How many records will we be archiving?
		SELECT @ArchiveCount = COUNT(1)
		  FROM CRM.dbo.PRExternalLinkAuditTrail
		 WHERE prelat_UpdatedDate <= @ArchiveThresholdDate;

		-- Archive the records
		INSERT INTO CRMArchive.dbo.PRExternalLinkAuditTrail
		SELECT * FROM CRM.dbo.PRExternalLinkAuditTrail
 		 WHERE prelat_UpdatedDate <= @ArchiveThresholdDate;
		SET @ArchiveRowCount = @@ROWCOUNT;

		-- Confirm the archive count
		IF (@ArchiveCount != @ArchiveRowCount) BEGIN
			Print 'ArchiveCount != ArchiveRowCount'
			RAISERROR ('ArchiveCount != ArchiveRowCount', 16, 1)		
		END

		-- Confirm the physical count matches the archive count
		SELECT @AfterCount = COUNT(1)
		  FROM CRMArchive.dbo.PRExternalLinkAuditTrail;
		IF (@ArchiveCount != (@AfterCount - @BeforeCount)) BEGIN
			Print 'ArchiveCount != (AfterCount - BeforeCount)'
			RAISERROR ('ArchiveCount != (AfterCount - BeforeCount)', 16, 1)
		END

		-- One final check.  Make sure all records we're about
		-- to delete exist in the archive table.
		SELECT @DoubleCheckCount = COUNT(1)
		  FROM CRM.dbo.PRExternalLinkAuditTrail
		 WHERE prelat_UpdatedDate <= @ArchiveThresholdDate
			AND prelat_ExternalLinkAuditTrailID NOT IN (
				SELECT prelat_ExternalLinkAuditTrailID
				  FROM CRMArchive.dbo.PRExternalLinkAuditTrail);
	            
		IF (@DoubleCheckCount != 0) BEGIN
			Print 'DoubleCheckCount > 0'
			RAISERROR ('DoubleCheckCount > 0', 16, 1)
		END

		-- Remove the archived records
		DELETE FROM CRM.dbo.PRExternalLinkAuditTrail
 		 WHERE prelat_UpdatedDate <= @ArchiveThresholdDate;

 		-- Update our archive log
		UPDATE CRMArchive.dbo.ArchiveLog
		   SET EndDateTime = GetDate(),
			   Status = 'Completed',
			   BeforeCount = @BeforeCount,
			   AfterCount = @AfterCount,
			   ArchiveCount = @ArchiveCount
		 WHERE ArchiveLogID = @ArchiveLogID;


		IF (@CommitToArchive = 1) BEGIN
			PRINT 'COMMITTING ARCHIVE UPDATE'
			COMMIT
		END ELSE BEGIN
			PRINT 'ROLLING BACK ARCHIVE UPDATE'
			SELECT * FROM CRMArchive.dbo.ArchiveLog WHERE ArchiveLogID = @ArchiveLogID;
			ROLLBACK TRANSACTION
			DELETE FROM CRMArchive.dbo.ArchiveLog WHERE ArchiveLogID = @ArchiveLogID;
		END


	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		UPDATE CRMArchive.dbo.ArchiveLog
		   SET EndDateTime = GetDate(),
			   Status = 'Error',
			   StatusMsg =  ERROR_MESSAGE(),
			   BeforeCount = @BeforeCount,
			   AfterCount = @AfterCount,
			   ArchiveCount = @ArchiveCount
		 WHERE ArchiveLogID = @ArchiveLogID;

		EXEC CRM.dbo.usp_RethrowError

	END CATCH;
END
Go



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_ArchivePRSearchAuditTrail]'))
    drop procedure [dbo].[usp_ArchivePRSearchAuditTrail]
GO

CREATE PROCEDURE dbo.usp_ArchivePRSearchAuditTrail
	@CommitToArchive bit = 0
As
BEGIN
	SET NOCOUNT ON

	IF (@CommitToArchive = 0) BEGIN
		PRINT '*************************************************************'
		PRINT 'NOTE: COMMIT CHANGES IS TURNED OFF. NO CHANGES WILL BE SAVED!'
		PRINT '*************************************************************'
		PRINT ''
	END

	DECLARE @ArchiveThresholdDate datetime
	DECLARE @BeforeCount int, @AfterCount int, @ArchiveCount int
	DECLARE @ArchiveRowCount int, @DoubleCheckCount int

	DECLARE @Detail_ArchiveLogID int, @Master_ArchiveLogID int
	DECLARE @TableCount int
	
	SET @ArchiveThresholdDate = CRM.dbo.ufn_GetArchiveDate('PRSearchAuditTrail');
 
	INSERT INTO CRMArchive.dbo.ArchiveLog (SourceTable, TargetTable, DateField, ArchiveThresholdDate, Status, StartDateTime)
	VALUES ('CRM.dbo.PRSearchAuditTrail', 'CRMArchive.dbo.PRSearchAuditTrail', 'prsat_UpdatedBy', @ArchiveThresholdDate, 'In Progress', GETDATE());
	SELECT @Master_ArchiveLogID = SCOPE_IDENTITY();

	INSERT INTO CRMArchive.dbo.ArchiveLog (SourceTable, TargetTable, DateField, ArchiveThresholdDate, Status, StartDateTime)
	VALUES ('CRM.dbo.PRSearchAuditTrailCriteria', 'CRMArchive.dbo.PRSearchAuditTrailCriteria', 'prsat_UpdatedBy', @ArchiveThresholdDate, 'In Progress', GETDATE());
	SELECT @Detail_ArchiveLogID = SCOPE_IDENTITY();

	DECLARE @ArchiveIDs table (
		RecordID int
	)	

	INSERT INTO @ArchiveIDs 
	SELECT prsat_SearchAuditTrailID
      FROM CRM.dbo.PRSearchAuditTrail
     WHERE prsat_UpdatedDate <= @ArchiveThresholdDate;

	BEGIN TRANSACTION
	BEGIN TRY


		/* 
		* First process the detail table
		*/
        SET @TableCount = 1;

		-- How many records already exist in the Archive table?
		SELECT @BeforeCount = COUNT(1)
		  FROM CRMArchive.dbo.PRSearchAuditTrailCriteria;

		-- How many records will we be archiving?
		SELECT @ArchiveCount = COUNT(1)
		  FROM CRM.dbo.PRSearchAuditTrailCriteria
		 WHERE prsatc_SearchAuditTrailID IN 
				(SELECT RecordID FROM @ArchiveIDs);

		-- Archive the records
		INSERT INTO CRMArchive.dbo.PRSearchAuditTrailCriteria
		SELECT * FROM CRM.dbo.PRSearchAuditTrailCriteria
		 WHERE prsatc_SearchAuditTrailID IN 
				(SELECT RecordID FROM @ArchiveIDs);
		SET @ArchiveRowCount = @@ROWCOUNT;

		-- Confirm the archive count
		IF (@ArchiveCount != @ArchiveRowCount) BEGIN
			Print 'PRSearchAuditTrailCriteria: ArchiveCount != ArchiveRowCount'
			RAISERROR ('PRSearchAuditTrailCriteria: ArchiveCount != ArchiveRowCount', 16, 1)		
		END

		-- Confirm the physical count matches the archive count
		SELECT @AfterCount = COUNT(1)
		  FROM CRMArchive.dbo.PRSearchAuditTrailCriteria;
		IF (@ArchiveCount != (@AfterCount - @BeforeCount)) BEGIN
			Print 'PRSearchAuditTrailCriteria: ArchiveCount != (AfterCount - BeforeCount)'
			RAISERROR ('PRSearchAuditTrailCriteria: ArchiveCount != (AfterCount - BeforeCount)', 16, 1)
		END

		-- One final check.  Make sure all records we're about
		-- to delete exist in the archive table.
		SELECT @DoubleCheckCount = COUNT(1)
		  FROM CRM.dbo.PRSearchAuditTrailCriteria
		 WHERE prsatc_SearchAuditTrailID IN 
				(SELECT RecordID FROM @ArchiveIDs)
		   AND prsatc_SearchAuditTrailCriteriaID NOT IN 
                (SELECT prsatc_SearchAuditTrailCriteriaID FROM CRMArchive.dbo.PRSearchAuditTrailCriteria);
	            
		IF (@DoubleCheckCount != 0) BEGIN
			Print 'PRSearchAuditTrailCriteria: DoubleCheckCount > 0'
			RAISERROR ('PRSearchAuditTrailCriteria: DoubleCheckCount > 0', 16, 1)
		END

		-- Remove the archived records
		DELETE FROM CRM.dbo.PRSearchAuditTrailCriteria
		 WHERE prsatc_SearchAuditTrailID IN 
				(SELECT RecordID FROM @ArchiveIDs);

 		-- Update our archive log
		UPDATE CRMArchive.dbo.ArchiveLog
		   SET EndDateTime = GetDate(),
			   Status = 'Completed',
			   BeforeCount = @BeforeCount,
			   AfterCount = @AfterCount,
			   ArchiveCount = @ArchiveCount
		 WHERE ArchiveLogID = @Detail_ArchiveLogID;


		/* 
		* Now process the Master table
		*/
        SET @TableCount = 2;

		-- How many records already exist in the Archive table?
		SELECT @BeforeCount = COUNT(1)
		  FROM CRMArchive.dbo.PRSearchAuditTrail;

		-- How many records will we be archiving?
		SELECT @ArchiveCount = COUNT(1)
		  FROM CRM.dbo.PRSearchAuditTrail
		 WHERE prsat_SearchAuditTrailID IN 
				(SELECT RecordID FROM @ArchiveIDs);

		-- Archive the records
		INSERT INTO CRMArchive.dbo.PRSearchAuditTrail
		SELECT * FROM CRM.dbo.PRSearchAuditTrail
		 WHERE prsat_SearchAuditTrailID IN 
				(SELECT RecordID FROM @ArchiveIDs);
		SET @ArchiveRowCount = @@ROWCOUNT;

		-- Confirm the archive count
		IF (@ArchiveCount != @ArchiveRowCount) BEGIN
			Print 'PRSearchAuditTrail: ArchiveCount != ArchiveRowCount'
			RAISERROR ('PRSearchAuditTrail: ArchiveCount != ArchiveRowCount', 16, 1)		
		END

		-- Confirm the physical count matches the archive count
		SELECT @AfterCount = COUNT(1)
		  FROM CRMArchive.dbo.PRSearchAuditTrail;
		IF (@ArchiveCount != (@AfterCount - @BeforeCount)) BEGIN
			Print 'PRSearchAuditTrail: ArchiveCount != (AfterCount - BeforeCount)'
			RAISERROR ('PRSearchAuditTrail: ArchiveCount != (AfterCount - BeforeCount)', 16, 1)
		END

		-- One final check.  Make sure all records we're about
		-- to delete exist in the archive table.
		SELECT @DoubleCheckCount = COUNT(1)
		  FROM CRM.dbo.PRSearchAuditTrail
		 WHERE prsat_SearchAuditTrailID IN 
				(SELECT RecordID FROM @ArchiveIDs)
		   AND prsat_SearchAuditTrailID NOT IN 
                (SELECT prsat_SearchAuditTrailID FROM CRMArchive.dbo.PRSearchAuditTrail);
	            
		IF (@DoubleCheckCount != 0) BEGIN
			Print 'PRSearchAuditTrail: DoubleCheckCount > 0'
			RAISERROR ('PRSearchAuditTrail: DoubleCheckCount > 0', 16, 1)
		END

		-- Remove the archived records
		DELETE FROM CRM.dbo.PRSearchAuditTrail
		 WHERE prsat_SearchAuditTrailID IN 
				(SELECT RecordID FROM @ArchiveIDs);

 		-- Update our archive log
		UPDATE CRMArchive.dbo.ArchiveLog
		   SET EndDateTime = GetDate(),
			   Status = 'Completed',
			   BeforeCount = @BeforeCount,
			   AfterCount = @AfterCount,
			   ArchiveCount = @ArchiveCount
		 WHERE ArchiveLogID = @Master_ArchiveLogID;


		IF (@CommitToArchive = 1) BEGIN
			PRINT 'COMMITTING ARCHIVE UPDATE'
			COMMIT
		END ELSE BEGIN
			PRINT 'ROLLING BACK ARCHIVE UPDATE'
			SELECT * FROM CRMArchive.dbo.ArchiveLog WHERE ArchiveLogID IN (@Master_ArchiveLogID, @Detail_ArchiveLogID);
			ROLLBACK TRANSACTION
			DELETE FROM CRMArchive.dbo.ArchiveLog WHERE ArchiveLogID IN (@Master_ArchiveLogID, @Detail_ArchiveLogID);
		END


	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		IF (@TableCount = 1) BEGIN

			UPDATE CRMArchive.dbo.ArchiveLog
			   SET EndDateTime = GetDate(),
				   Status = 'Error',
				   StatusMsg =  ERROR_MESSAGE(),
				   BeforeCount = @BeforeCount,
				   AfterCount = @AfterCount,
				   ArchiveCount = @ArchiveCount
			 WHERE ArchiveLogID = @Detail_ArchiveLogID;


			UPDATE CRMArchive.dbo.ArchiveLog
			   SET EndDateTime = GetDate(),
				   Status = 'Error',
				   StatusMsg =  'Error archiving PRSearchAuditTrailCriteria'
			 WHERE ArchiveLogID = @Master_ArchiveLogID;

		END ELSE BEGIN

			UPDATE CRMArchive.dbo.ArchiveLog
			   SET EndDateTime = GetDate(),
				   Status = 'Error',
				   StatusMsg =  ERROR_MESSAGE(),
				   BeforeCount = @BeforeCount,
				   AfterCount = @AfterCount,
				   ArchiveCount = @ArchiveCount
			 WHERE ArchiveLogID = @Master_ArchiveLogID;


			UPDATE CRMArchive.dbo.ArchiveLog
			   SET EndDateTime = GetDate(),
				   Status = 'Error',
				   StatusMsg =  'Error archiving PRSearchAuditTrail'
			 WHERE ArchiveLogID = @Detail_ArchiveLogID;
		END

		EXEC CRM.dbo.usp_RethrowError

	END CATCH;
END
Go




if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_ArchivePRSearchWizardAuditTrail]'))
    drop procedure [dbo].[usp_ArchivePRSearchWizardAuditTrail]
GO

CREATE PROCEDURE dbo.usp_ArchivePRSearchWizardAuditTrail
	@CommitToArchive bit = 0
As
BEGIN
	SET NOCOUNT ON

	IF (@CommitToArchive = 0) BEGIN
		PRINT '*************************************************************'
		PRINT 'NOTE: COMMIT CHANGES IS TURNED OFF. NO CHANGES WILL BE SAVED!'
		PRINT '*************************************************************'
		PRINT ''
	END

	DECLARE @ArchiveThresholdDate datetime
	DECLARE @BeforeCount int, @AfterCount int, @ArchiveCount int
	DECLARE @ArchiveRowCount int, @DoubleCheckCount int

	DECLARE @Detail_ArchiveLogID int, @Master_ArchiveLogID int
	DECLARE @TableCount int
	
	SET @ArchiveThresholdDate = CRM.dbo.ufn_GetArchiveDate('PRSearchWizardAuditTrail');
 
	INSERT INTO CRMArchive.dbo.ArchiveLog (SourceTable, TargetTable, DateField, ArchiveThresholdDate, Status, StartDateTime)
	VALUES ('CRM.dbo.PRSearchWizardAuditTrail', 'CRMArchive.dbo.PRSearchWizardAuditTrail', 'prswau_UpdatedDate', @ArchiveThresholdDate, 'In Progress', GETDATE());
	SELECT @Master_ArchiveLogID = SCOPE_IDENTITY();

	INSERT INTO CRMArchive.dbo.ArchiveLog (SourceTable, TargetTable, DateField, ArchiveThresholdDate, Status, StartDateTime)
	VALUES ('CRM.dbo.PRSearchWizardAuditTrailDetail', 'CRMArchive.dbo.PRSearchWizardAuditTrailDetail', 'prswau_UpdatedDate', @ArchiveThresholdDate, 'In Progress', GETDATE());
	SELECT @Detail_ArchiveLogID = SCOPE_IDENTITY();

	DECLARE @ArchiveIDs table (
		RecordID int
	)	

	INSERT INTO @ArchiveIDs 
	SELECT prswau_SearchWizardAuditTrailID
      FROM CRM.dbo.PRSearchWizardAuditTrail
     WHERE prswau_UpdatedDate <= @ArchiveThresholdDate;

	BEGIN TRANSACTION
	BEGIN TRY


		/* 
		* First process the detail table
		*/
        SET @TableCount = 1;

		-- How many records already exist in the Archive table?
		SELECT @BeforeCount = COUNT(1)
		  FROM CRMArchive.dbo.PRSearchWizardAuditTrailDetail;

		-- How many records will we be archiving?
		SELECT @ArchiveCount = COUNT(1)
		  FROM CRM.dbo.PRSearchWizardAuditTrailDetail
		 WHERE prswaud_SearchWizardAuditTrailID IN 
				(SELECT RecordID FROM @ArchiveIDs);

		-- Archive the records
		INSERT INTO CRMArchive.dbo.PRSearchWizardAuditTrailDetail
		SELECT * FROM CRM.dbo.PRSearchWizardAuditTrailDetail
		 WHERE prswaud_SearchWizardAuditTrailID IN 
				(SELECT RecordID FROM @ArchiveIDs);
		SET @ArchiveRowCount = @@ROWCOUNT;

		-- Confirm the archive count
		IF (@ArchiveCount != @ArchiveRowCount) BEGIN
			Print 'PRSearchWizardAuditTrailDetail: ArchiveCount != ArchiveRowCount'
			RAISERROR ('PRSearchWizardAuditTrailDetail: ArchiveCount != ArchiveRowCount', 16, 1)		
		END

		-- Confirm the physical count matches the archive count
		SELECT @AfterCount = COUNT(1)
		  FROM CRMArchive.dbo.PRSearchWizardAuditTrailDetail;
		IF (@ArchiveCount != (@AfterCount - @BeforeCount)) BEGIN
			Print 'PRSearchWizardAuditTrailDetail: ArchiveCount != (AfterCount - BeforeCount)'
			RAISERROR ('PRSearchWizardAuditTrailDetail: ArchiveCount != (AfterCount - BeforeCount)', 16, 1)
		END

		-- One final check.  Make sure all records we're about
		-- to delete exist in the archive table.
		SELECT @DoubleCheckCount = COUNT(1)
		  FROM CRM.dbo.PRSearchWizardAuditTrailDetail
		 WHERE prswaud_SearchWizardAuditTrailID IN 
				(SELECT RecordID FROM @ArchiveIDs)
		   AND prswaud_SearchWizardAuditTrailDetailID NOT IN 
                (SELECT prswaud_SearchWizardAuditTrailDetailID FROM CRMArchive.dbo.PRSearchWizardAuditTrailDetail);
	            
		IF (@DoubleCheckCount != 0) BEGIN
			Print 'PRSearchWizardAuditTrailDetail: DoubleCheckCount > 0'
			RAISERROR ('PRSearchWizardAuditTrailDetail: DoubleCheckCount > 0', 16, 1)
		END

		-- Remove the archived records
		DELETE FROM CRM.dbo.PRSearchWizardAuditTrailDetail
		 WHERE prswaud_SearchWizardAuditTrailID IN 
				(SELECT RecordID FROM @ArchiveIDs);

 		-- Update our archive log
		UPDATE CRMArchive.dbo.ArchiveLog
		   SET EndDateTime = GetDate(),
			   Status = 'Completed',
			   BeforeCount = @BeforeCount,
			   AfterCount = @AfterCount,
			   ArchiveCount = @ArchiveCount
		 WHERE ArchiveLogID = @Detail_ArchiveLogID;


		/* 
		* Now process the Master table
		*/
        SET @TableCount = 2;

		-- How many records already exist in the Archive table?
		SELECT @BeforeCount = COUNT(1)
		  FROM CRMArchive.dbo.PRSearchWizardAuditTrail;

		-- How many records will we be archiving?
		SELECT @ArchiveCount = COUNT(1)
		  FROM CRM.dbo.PRSearchWizardAuditTrail
		 WHERE prswau_SearchWizardAuditTrailID IN 
				(SELECT RecordID FROM @ArchiveIDs);

		-- Archive the records
		INSERT INTO CRMArchive.dbo.PRSearchWizardAuditTrail
		SELECT * FROM CRM.dbo.PRSearchWizardAuditTrail
		 WHERE prswau_SearchWizardAuditTrailID IN 
				(SELECT RecordID FROM @ArchiveIDs);
		SET @ArchiveRowCount = @@ROWCOUNT;

		-- Confirm the archive count
		IF (@ArchiveCount != @ArchiveRowCount) BEGIN
			Print 'PRSearchWizardAuditTrail: ArchiveCount != ArchiveRowCount'
			RAISERROR ('PRSearchWizardAuditTrail: ArchiveCount != ArchiveRowCount', 16, 1)		
		END

		-- Confirm the physical count matches the archive count
		SELECT @AfterCount = COUNT(1)
		  FROM CRMArchive.dbo.PRSearchWizardAuditTrail;
		IF (@ArchiveCount != (@AfterCount - @BeforeCount)) BEGIN
			Print 'PRSearchWizardAuditTrail: ArchiveCount != (AfterCount - BeforeCount)'
			RAISERROR ('PRSearchWizardAuditTrail: ArchiveCount != (AfterCount - BeforeCount)', 16, 1)
		END

		-- One final check.  Make sure all records we're about
		-- to delete exist in the archive table.
		SELECT @DoubleCheckCount = COUNT(1)
		  FROM CRM.dbo.PRSearchWizardAuditTrail
		 WHERE prswau_SearchWizardAuditTrailID IN 
				(SELECT RecordID FROM @ArchiveIDs)
		   AND prswau_SearchWizardAuditTrailID NOT IN 
                (SELECT prswau_SearchWizardAuditTrailID FROM CRMArchive.dbo.PRSearchWizardAuditTrail);
	            
		IF (@DoubleCheckCount != 0) BEGIN
			Print 'PRSearchWizardAuditTrail: DoubleCheckCount > 0'
			RAISERROR ('PRSearchWizardAuditTrail: DoubleCheckCount > 0', 16, 1)
		END

		-- Remove the archived records
		DELETE FROM CRM.dbo.PRSearchWizardAuditTrail
		 WHERE prswau_SearchWizardAuditTrailID IN 
				(SELECT RecordID FROM @ArchiveIDs);

 		-- Update our archive log
		UPDATE CRMArchive.dbo.ArchiveLog
		   SET EndDateTime = GetDate(),
			   Status = 'Completed',
			   BeforeCount = @BeforeCount,
			   AfterCount = @AfterCount,
			   ArchiveCount = @ArchiveCount
		 WHERE ArchiveLogID = @Master_ArchiveLogID;


		IF (@CommitToArchive = 1) BEGIN
			PRINT 'COMMITTING ARCHIVE UPDATE'
			COMMIT
		END ELSE BEGIN
			PRINT 'ROLLING BACK ARCHIVE UPDATE'
			SELECT * FROM CRMArchive.dbo.ArchiveLog WHERE ArchiveLogID IN (@Master_ArchiveLogID, @Detail_ArchiveLogID);
			ROLLBACK TRANSACTION
			DELETE FROM CRMArchive.dbo.ArchiveLog WHERE ArchiveLogID IN (@Master_ArchiveLogID, @Detail_ArchiveLogID);
		END

	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		IF (@TableCount = 1) BEGIN

			UPDATE CRMArchive.dbo.ArchiveLog
			   SET EndDateTime = GetDate(),
				   Status = 'Error',
				   StatusMsg =  ERROR_MESSAGE(),
				   BeforeCount = @BeforeCount,
				   AfterCount = @AfterCount,
				   ArchiveCount = @ArchiveCount
			 WHERE ArchiveLogID = @Detail_ArchiveLogID;


			UPDATE CRMArchive.dbo.ArchiveLog
			   SET EndDateTime = GetDate(),
				   Status = 'Error',
				   StatusMsg =  'Error archiving PRSearchWizardAuditTrailDetail'
			 WHERE ArchiveLogID = @Master_ArchiveLogID;

		END ELSE BEGIN

			UPDATE CRMArchive.dbo.ArchiveLog
			   SET EndDateTime = GetDate(),
				   Status = 'Error',
				   StatusMsg =  ERROR_MESSAGE(),
				   BeforeCount = @BeforeCount,
				   AfterCount = @AfterCount,
				   ArchiveCount = @ArchiveCount
			 WHERE ArchiveLogID = @Master_ArchiveLogID;


			UPDATE CRMArchive.dbo.ArchiveLog
			   SET EndDateTime = GetDate(),
				   Status = 'Error',
				   StatusMsg =  'Error archiving PRSearchWizardAuditTrail'
			 WHERE ArchiveLogID = @Detail_ArchiveLogID;
		END

		EXEC CRM.dbo.usp_RethrowError

	END CATCH;
END
Go



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_ArchivePRWebServiceAuditTrail]'))
    drop procedure [dbo].[usp_ArchivePRWebServiceAuditTrail]
GO

CREATE PROCEDURE dbo.usp_ArchivePRWebServiceAuditTrail
	@CommitToArchive bit = 0
As
BEGIN
	SET NOCOUNT ON

	IF (@CommitToArchive = 0) BEGIN
		PRINT '*************************************************************'
		PRINT 'NOTE: COMMIT CHANGES IS TURNED OFF. NO CHANGES WILL BE SAVED!'
		PRINT '*************************************************************'
		PRINT ''
	END

	DECLARE @ArchiveThresholdDate datetime
	DECLARE @BeforeCount int, @AfterCount int, @ArchiveCount int
	DECLARE @ArchiveRowCount int, @DoubleCheckCount int
	DECLARE @ArchiveLogID int
	
	SET @ArchiveThresholdDate = CRM.dbo.ufn_GetArchiveDate('PRWebServiceAuditTrail');

	INSERT INTO CRMArchive.dbo.ArchiveLog (SourceTable, TargetTable, DateField, ArchiveThresholdDate, Status, StartDateTime)
	VALUES ('CRM.dbo.PRWebServiceAuditTrail', 'CRMArchive.dbo.PRWebServiceAuditTrail', 'prwsat2_UpdatedDate', @ArchiveThresholdDate, 'In Progress', GETDATE());
	SELECT @ArchiveLogID = SCOPE_IDENTITY();

	BEGIN TRANSACTION
	BEGIN TRY

		-- How many records already exist in the Archive table?
		SELECT @BeforeCount = COUNT(1)
		  FROM CRMArchive.dbo.PRWebServiceAuditTrail;

		-- How many records will we be archiving?
		SELECT @ArchiveCount = COUNT(1)
		  FROM CRM.dbo.PRWebServiceAuditTrail
		 WHERE prwsat2_UpdatedDate <= @ArchiveThresholdDate;

		-- Archive the records
		INSERT INTO CRMArchive.dbo.PRWebServiceAuditTrail
		SELECT * FROM CRM.dbo.PRWebServiceAuditTrail
 		 WHERE prwsat2_UpdatedDate <= @ArchiveThresholdDate;
		SET @ArchiveRowCount = @@ROWCOUNT;

		-- Confirm the archive count
		IF (@ArchiveCount != @ArchiveRowCount) BEGIN
			Print 'ArchiveCount != ArchiveRowCount'
			RAISERROR ('ArchiveCount != ArchiveRowCount', 16, 1)		
		END

		-- Confirm the physical count matches the archive count
		SELECT @AfterCount = COUNT(1)
		  FROM CRMArchive.dbo.PRWebServiceAuditTrail;
		IF (@ArchiveCount != (@AfterCount - @BeforeCount)) BEGIN
			Print 'ArchiveCount != (AfterCount - BeforeCount)'
			RAISERROR ('ArchiveCount != (AfterCount - BeforeCount)', 16, 1)
		END

		-- One final check.  Make sure all records we're about
		-- to delete exist in the archive table.
		SELECT @DoubleCheckCount = COUNT(1)
		  FROM CRM.dbo.PRWebServiceAuditTrail
		 WHERE prwsat2_UpdatedDate <= @ArchiveThresholdDate
		   AND prwsat2_WebServiceAuditTrailID NOT IN (
				SELECT prwsat2_WebServiceAuditTrailID
				  FROM CRMArchive.dbo.PRWebServiceAuditTrail);
	            
		IF (@DoubleCheckCount != 0) BEGIN
			Print 'DoubleCheckCount > 0'
			RAISERROR ('DoubleCheckCount > 0', 16, 1)
		END

		-- Remove the archived records
		DELETE FROM CRM.dbo.PRWebServiceAuditTrail
 		 WHERE prwsat2_UpdatedDate <= @ArchiveThresholdDate;

 		-- Update our archive log
		UPDATE CRMArchive.dbo.ArchiveLog
		   SET EndDateTime = GetDate(),
			   Status = 'Completed',
			   BeforeCount = @BeforeCount,
			   AfterCount = @AfterCount,
			   ArchiveCount = @ArchiveCount
		 WHERE ArchiveLogID = @ArchiveLogID;


		IF (@CommitToArchive = 1) BEGIN
			PRINT 'COMMITTING ARCHIVE UPDATE'
			COMMIT
		END ELSE BEGIN
			PRINT 'ROLLING BACK ARCHIVE UPDATE'
			SELECT * FROM CRMArchive.dbo.ArchiveLog WHERE ArchiveLogID = @ArchiveLogID;
			ROLLBACK TRANSACTION
			DELETE FROM CRMArchive.dbo.ArchiveLog WHERE ArchiveLogID = @ArchiveLogID;
		END

	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		UPDATE CRMArchive.dbo.ArchiveLog
		   SET EndDateTime = GetDate(),
			   Status = 'Error',
			   StatusMsg =  ERROR_MESSAGE(),
			   BeforeCount = @BeforeCount,
			   AfterCount = @AfterCount,
			   ArchiveCount = @ArchiveCount
		 WHERE ArchiveLogID = @ArchiveLogID;

		EXEC CRM.dbo.usp_RethrowError

	END CATCH;
END
Go


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_ArchivePRTESRequest]'))
    drop procedure [dbo].[usp_ArchivePRTESRequest]
GO

CREATE PROCEDURE dbo.usp_ArchivePRTESRequest
	@CommitToArchive bit = 0
As
BEGIN
	SET NOCOUNT ON

	IF (@CommitToArchive = 0) BEGIN
		PRINT '*************************************************************'
		PRINT 'NOTE: COMMIT CHANGES IS TURNED OFF. NO CHANGES WILL BE SAVED!'
		PRINT '*************************************************************'
		PRINT ''
	END

	DECLARE @ArchiveThresholdDate datetime
	DECLARE @BeforeCount int, @AfterCount int, @ArchiveCount int
	DECLARE @ArchiveRowCount int, @DoubleCheckCount int

	DECLARE @Detail_ArchiveLogID int, @Master_ArchiveLogID int
	DECLARE @TableCount int
	
	SET @ArchiveThresholdDate = CRM.dbo.ufn_GetArchiveDate('PRTESRequest');
 
	INSERT INTO CRMArchive.dbo.ArchiveLog (SourceTable, TargetTable, DateField, ArchiveThresholdDate, Status, StartDateTime)
	VALUES ('CRM.dbo.PRTESRequest', 'CRMArchive.dbo.PRTESRequest', 'prtesr_UpdatedDate', @ArchiveThresholdDate, 'In Progress', GETDATE());
	SELECT @Master_ArchiveLogID = SCOPE_IDENTITY();

	INSERT INTO CRMArchive.dbo.ArchiveLog (SourceTable, TargetTable, DateField, ArchiveThresholdDate, Status, StartDateTime)
	VALUES ('CRM.dbo.PRTESForm', 'CRMArchive.dbo.PRTESForm', 'prtesr_UpdatedDate', @ArchiveThresholdDate, 'In Progress', GETDATE());
	SELECT @Detail_ArchiveLogID = SCOPE_IDENTITY();

	DECLARE @ArchiveIDs table (
		RecordID int
	)	

	INSERT INTO @ArchiveIDs 
	SELECT prtesr_TESRequestID
      FROM CRM.dbo.PRTESRequest
     WHERE prtesr_UpdatedDate <= @ArchiveThresholdDate;

	BEGIN TRANSACTION
	BEGIN TRY


		/* 
		* First process the PRTESRequest table
		*/
        SET @TableCount = 1;

		-- How many records already exist in the Archive table?
		SELECT @BeforeCount = COUNT(1)
		  FROM CRMArchive.dbo.PRTESRequest;

		-- How many records will we be archiving?
		SELECT @ArchiveCount = COUNT(1)
		  FROM CRM.dbo.PRTESRequest
		 WHERE prtesr_TESRequestID IN 
				(SELECT RecordID FROM @ArchiveIDs);

		-- Archive the records
		INSERT INTO CRMArchive.dbo.PRTESRequest
		SELECT * FROM CRM.dbo.PRTESRequest
		 WHERE prtesr_TESRequestID IN 
				(SELECT RecordID FROM @ArchiveIDs);
		SET @ArchiveRowCount = @@ROWCOUNT;

		-- Confirm the archive count
		IF (@ArchiveCount != @ArchiveRowCount) BEGIN
			Print 'PRTESRequest: ArchiveCount != ArchiveRowCount'
			RAISERROR ('PRTESRequest: ArchiveCount != ArchiveRowCount', 16, 1)		
			RETURN
		END

		-- Confirm the physical count matches the archive count
		SELECT @AfterCount = COUNT(1)
		  FROM CRMArchive.dbo.PRTESRequest;
		IF (@ArchiveCount != (@AfterCount - @BeforeCount)) BEGIN
			Print 'PRTESRequest: ArchiveCount != (AfterCount - BeforeCount)'
			RAISERROR ('PRTESRequest: ArchiveCount != (AfterCount - BeforeCount)', 16, 1)
		END

		-- One final check.  Make sure all records we're about
		-- to delete exist in the archive table.
		SELECT @DoubleCheckCount = COUNT(1)
		  FROM CRM.dbo.PRTESRequest
		 WHERE prtesr_TESRequestID IN 
				(SELECT RecordID FROM @ArchiveIDs)
		   AND prtesr_TESRequestID NOT IN 
               (SELECT prtesr_TESRequestID FROM CRMArchive.dbo.PRTESRequest);
	            
		IF (@DoubleCheckCount != 0) BEGIN
			Print 'PRTESRequest: DoubleCheckCount > 0'
			RAISERROR ('PRTESRequest: DoubleCheckCount > 0', 16, 1)
		END

		-- Remove the archived records
		DELETE FROM CRM.dbo.PRTESRequest
		 WHERE prtesr_TESRequestID IN 
				(SELECT RecordID FROM @ArchiveIDs);

 		-- Update our archive log
		UPDATE CRMArchive.dbo.ArchiveLog
		   SET EndDateTime = GetDate(),
			   Status = 'Completed',
			   BeforeCount = @BeforeCount,
			   AfterCount = @AfterCount,
			   ArchiveCount = @ArchiveCount
		 WHERE ArchiveLogID = @Master_ArchiveLogID;


		/* 
		* Now process the PRTESForm table
		*/
        SET @TableCount = 2;

		-- How many records already exist in the Archive table?
		SELECT @BeforeCount = COUNT(1)
		  FROM CRMArchive.dbo.PRTESForm;

		-- How many records will we be archiving?
		SELECT @ArchiveCount = COUNT(1)
		  FROM CRM.dbo.PRTESForm
		 WHERE prtf_TESFormId IN 
                (SELECT prtesr_TESFormID 
                   FROM CRMArchive.dbo.PRTESRequest
                  WHERE prtesr_TESRequestID IN (SELECT RecordID FROM @ArchiveIDs));

		-- Archive the records
		INSERT INTO CRMArchive.dbo.PRTESForm
		SELECT * FROM CRM.dbo.PRTESForm
		 WHERE prtf_TESFormId IN 
                (SELECT prtesr_TESFormID 
                   FROM CRMArchive.dbo.PRTESRequest
                  WHERE prtesr_TESRequestID IN (SELECT RecordID FROM @ArchiveIDs));
		SET @ArchiveRowCount = @@ROWCOUNT;

		-- Confirm the archive count
		IF (@ArchiveCount != @ArchiveRowCount) BEGIN
			Print 'PRTESForm: ArchiveCount != ArchiveRowCount'
			RAISERROR ('PRTESForm: ArchiveCount != ArchiveRowCount', 16, 1)		
		END

		-- Confirm the physical count matches the archive count
		SELECT @AfterCount = COUNT(1)
		  FROM CRMArchive.dbo.PRTESForm;
		IF (@ArchiveCount != (@AfterCount - @BeforeCount)) BEGIN
			Print 'PRTESForm: ArchiveCount != (AfterCount - BeforeCount)'
			RAISERROR ('PRTESForm: ArchiveCount != (AfterCount - BeforeCount)', 16, 1)
			RETURN
		END

		-- One final check.  Make sure all records we're about
		-- to delete exist in the archive table.
		SELECT @DoubleCheckCount = COUNT(1)
		  FROM CRM.dbo.PRTESForm
		 WHERE prtf_TESFormId IN 
                (SELECT prtesr_TESFormID 
                   FROM CRMArchive.dbo.PRTESRequest
                  WHERE prtesr_TESRequestID IN (SELECT RecordID FROM @ArchiveIDs))
		   AND prtf_TESFormId NOT IN 
                (SELECT prtf_TESFormId FROM CRMArchive.dbo.PRTESForm);
	            
		IF (@DoubleCheckCount != 0) BEGIN
			Print 'PRTESForm: DoubleCheckCount > 0'
			RAISERROR ('PRTESForm: DoubleCheckCount > 0', 16, 1)
		END

		-- Remove the archived records
		DELETE FROM CRM.dbo.PRTESForm
		 WHERE prtf_TESFormId IN 
                (SELECT prtesr_TESFormID 
                   FROM CRMArchive.dbo.PRTESRequest
                  WHERE prtesr_TESRequestID IN (SELECT RecordID FROM @ArchiveIDs));

 		-- Update our archive log
		UPDATE CRMArchive.dbo.ArchiveLog
		   SET EndDateTime = GetDate(),
			   Status = 'Completed',
			   BeforeCount = @BeforeCount,
			   AfterCount = @AfterCount,
			   ArchiveCount = @ArchiveCount
		 WHERE ArchiveLogID = @Detail_ArchiveLogID;


		IF (@CommitToArchive = 1) BEGIN
			PRINT 'COMMITTING ARCHIVE UPDATE'
			COMMIT
		END ELSE BEGIN
			PRINT 'ROLLING BACK ARCHIVE UPDATE'
			SELECT * FROM CRMArchive.dbo.ArchiveLog WHERE ArchiveLogID IN (@Detail_ArchiveLogID, @Master_ArchiveLogID);
			ROLLBACK TRANSACTION
			DELETE FROM CRMArchive.dbo.ArchiveLog WHERE ArchiveLogID IN (@Detail_ArchiveLogID, @Master_ArchiveLogID);
		END


	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		IF (@TableCount = 1) BEGIN

			UPDATE CRMArchive.dbo.ArchiveLog
			   SET EndDateTime = GetDate(),
				   Status = 'Error',
				   StatusMsg =  ERROR_MESSAGE(),
				   BeforeCount = @BeforeCount,
				   AfterCount = @AfterCount,
				   ArchiveCount = @ArchiveCount
			 WHERE ArchiveLogID = @Master_ArchiveLogID;


			UPDATE CRMArchive.dbo.ArchiveLog
			   SET EndDateTime = GetDate(),
				   Status = 'Error',
				   StatusMsg =  'Error archiving PRTESRequest'
			 WHERE ArchiveLogID = @Detail_ArchiveLogID;

		END ELSE BEGIN

			UPDATE CRMArchive.dbo.ArchiveLog
			   SET EndDateTime = GetDate(),
				   Status = 'Error',
				   StatusMsg =  ERROR_MESSAGE(),
				   BeforeCount = @BeforeCount,
				   AfterCount = @AfterCount,
				   ArchiveCount = @ArchiveCount
			 WHERE ArchiveLogID = @Detail_ArchiveLogID;


			UPDATE CRMArchive.dbo.ArchiveLog
			   SET EndDateTime = GetDate(),
				   Status = 'Error',
				   StatusMsg =  'Error archiving PRTESForm'
			 WHERE ArchiveLogID = @Master_ArchiveLogID;
		END

		EXEC CRM.dbo.usp_RethrowError

	END CATCH;
END
Go


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_ArchivePRARAging]'))
    drop procedure [dbo].[usp_ArchivePRARAging]
GO

CREATE PROCEDURE dbo.usp_ArchivePRARAging
	@CommitToArchive bit = 0
as
BEGIN
	SET NOCOUNT ON

	IF (@CommitToArchive = 0) BEGIN
		PRINT '*************************************************************'
		PRINT 'NOTE: COMMIT CHANGES IS TURNED OFF. NO CHANGES WILL BE SAVED!'
		PRINT '*************************************************************'
		PRINT ''
	END


	DECLARE @ArchiveThresholdDate datetime
	DECLARE @BeforeCount int, @AfterCount int, @ArchiveCount int
	DECLARE @ArchiveRowCount int, @DoubleCheckCount int

	DECLARE @Detail_ArchiveLogID int, @Master_ArchiveLogID int
	DECLARE @TableCount int
	
	SET @ArchiveThresholdDate = CRM.dbo.ufn_GetArchiveDate('PRARAging');
 
	INSERT INTO CRMArchive.dbo.ArchiveLog (SourceTable, TargetTable, DateField, ArchiveThresholdDate, Status, StartDateTime)
	VALUES ('CRM.dbo.PRARAging', 'CRMArchive.dbo.PRARAging', 'praa_UpdatedDate', @ArchiveThresholdDate, 'In Progress', GETDATE());
	SELECT @Master_ArchiveLogID = SCOPE_IDENTITY();

	INSERT INTO CRMArchive.dbo.ArchiveLog (SourceTable, TargetTable, DateField, ArchiveThresholdDate, Status, StartDateTime)
	VALUES ('CRM.dbo.PRARAgingDetail', 'CRMArchive.dbo.PRARAgingDetail', 'praa_UpdatedDate', @ArchiveThresholdDate, 'In Progress', GETDATE());
	SELECT @Detail_ArchiveLogID = SCOPE_IDENTITY();

	DECLARE @ArchiveIDs table (
		RecordID int
	)	

	INSERT INTO @ArchiveIDs 
	SELECT praa_ARAgingId
      FROM CRM.dbo.PRARAging
     WHERE praa_UpdatedDate <= @ArchiveThresholdDate;

	BEGIN TRANSACTION
	BEGIN TRY


		/* 
		* First process the Detail table
		*/
        SET @TableCount = 1;

		-- How many records already exist in the Archive table?
		SELECT @BeforeCount = COUNT(1)
		  FROM CRMArchive.dbo.PRARAgingDetail;

		-- How many records will we be archiving?
		SELECT @ArchiveCount = COUNT(1)
		  FROM CRM.dbo.PRARAgingDetail
		 WHERE praad_ARAgingId IN 
				(SELECT RecordID FROM @ArchiveIDs);

		-- Archive the records
		INSERT INTO CRMArchive.dbo.PRARAgingDetail
		SELECT * FROM CRM.dbo.PRARAgingDetail
		 WHERE praad_ARAgingId IN 
				(SELECT RecordID FROM @ArchiveIDs);
		SET @ArchiveRowCount = @@ROWCOUNT;

		-- Confirm the archive count
		IF (@ArchiveCount != @ArchiveRowCount) BEGIN
			Print 'PRARAgingDetail: ArchiveCount != ArchiveRowCount'
			RAISERROR ('PRARAgingDetail: ArchiveCount != ArchiveRowCount', 16, 1)		
			RETURN
		END

		-- Confirm the physical count matches the archive count
		SELECT @AfterCount = COUNT(1)
		  FROM CRMArchive.dbo.PRARAgingDetail;
		IF (@ArchiveCount != (@AfterCount - @BeforeCount)) BEGIN
			Print 'PRARAgingDetail: ArchiveCount != (AfterCount - BeforeCount)'
			RAISERROR ('PRARAgingDetail: ArchiveCount != (AfterCount - BeforeCount)', 16, 1)
		END

		-- One final check.  Make sure all records we're about
		-- to delete exist in the archive table.
		SELECT @DoubleCheckCount = COUNT(1)
		  FROM CRM.dbo.PRARAgingDetail
		 WHERE praad_ARAgingId IN 
				(SELECT RecordID FROM @ArchiveIDs)
		   AND praad_ARAgingId NOT IN 
                (SELECT praad_ARAgingId FROM CRMArchive.dbo.PRARAgingDetail);
	            
		IF (@DoubleCheckCount != 0) BEGIN
			Print 'PRARAgingDetail: DoubleCheckCount > 0'
			RAISERROR ('PRARAgingDetail: DoubleCheckCount > 0', 16, 1)
		END

		-- Remove the archived records
		DELETE FROM CRM.dbo.PRARAgingDetail
		 WHERE praad_ARAgingId IN 
				(SELECT RecordID FROM @ArchiveIDs);

 		-- Update our archive log
		UPDATE CRMArchive.dbo.ArchiveLog
		   SET EndDateTime = GetDate(),
			   Status = 'Completed',
			   BeforeCount = @BeforeCount,
			   AfterCount = @AfterCount,
			   ArchiveCount = @ArchiveCount
		 WHERE ArchiveLogID = @Detail_ArchiveLogID;


		/* 
		* Now process the Master table
		*/
        SET @TableCount = 2;

		-- How many records already exist in the Archive table?
		SELECT @BeforeCount = COUNT(1)
		  FROM CRMArchive.dbo.PRARAging;

		-- How many records will we be archiving?
		SELECT @ArchiveCount = COUNT(1)
		  FROM CRM.dbo.PRARAging
		 WHERE praa_ARAgingId IN 
				(SELECT RecordID FROM @ArchiveIDs);

		-- Archive the records
		INSERT INTO CRMArchive.dbo.PRARAging
		SELECT * FROM CRM.dbo.PRARAging
		 WHERE praa_ARAgingId IN 
				(SELECT RecordID FROM @ArchiveIDs);
		SET @ArchiveRowCount = @@ROWCOUNT;

		-- Confirm the archive count
		IF (@ArchiveCount != @ArchiveRowCount) BEGIN
			Print 'PRARAging: ArchiveCount != ArchiveRowCount'
			RAISERROR ('PRARAging: ArchiveCount != ArchiveRowCount', 16, 1)		
		END

		-- Confirm the physical count matches the archive count
		SELECT @AfterCount = COUNT(1)
		  FROM CRMArchive.dbo.PRARAging;
		IF (@ArchiveCount != (@AfterCount - @BeforeCount)) BEGIN
			Print 'PRARAging: ArchiveCount != (AfterCount - BeforeCount)'
			RAISERROR ('PRARAging: ArchiveCount != (AfterCount - BeforeCount)', 16, 1)
		END

		-- One final check.  Make sure all records we're about
		-- to delete exist in the archive table.
		SELECT @DoubleCheckCount = COUNT(1)
		  FROM CRM.dbo.PRARAging
		 WHERE praa_ARAgingId IN 
				(SELECT RecordID FROM @ArchiveIDs)
		   AND praa_ARAgingId NOT IN 
                (SELECT praa_ARAgingId FROM CRMArchive.dbo.PRARAging);
	            
		IF (@DoubleCheckCount != 0) BEGIN
			Print 'PRARAging: DoubleCheckCount > 0'
			RAISERROR ('PRARAging: DoubleCheckCount > 0', 16, 1)
		END

		-- Remove the archived records
		DELETE FROM CRM.dbo.PRARAging
		 WHERE praa_ARAgingId IN 
				(SELECT RecordID FROM @ArchiveIDs);

 		-- Update our archive log
		UPDATE CRMArchive.dbo.ArchiveLog
		   SET EndDateTime = GetDate(),
			   Status = 'Completed',
			   BeforeCount = @BeforeCount,
			   AfterCount = @AfterCount,
			   ArchiveCount = @ArchiveCount
		 WHERE ArchiveLogID = @Master_ArchiveLogID;


		IF (@CommitToArchive = 1) BEGIN
			PRINT 'COMMITTING ARCHIVE UPDATE'
			COMMIT
		END ELSE BEGIN
			PRINT 'ROLLING BACK ARCHIVE UPDATE'
			SELECT * FROM CRMArchive.dbo.ArchiveLog WHERE ArchiveLogID IN (@Master_ArchiveLogID, @Detail_ArchiveLogID);
			ROLLBACK TRANSACTION
			DELETE FROM CRMArchive.dbo.ArchiveLog WHERE ArchiveLogID IN (@Master_ArchiveLogID, @Detail_ArchiveLogID);
		END

		
	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		IF (@TableCount = 1) BEGIN

			UPDATE CRMArchive.dbo.ArchiveLog
			   SET EndDateTime = GetDate(),
				   Status = 'Error',
				   StatusMsg =  ERROR_MESSAGE(),
				   BeforeCount = @BeforeCount,
				   AfterCount = @AfterCount,
				   ArchiveCount = @ArchiveCount
			 WHERE ArchiveLogID = @Detail_ArchiveLogID;


			UPDATE CRMArchive.dbo.ArchiveLog
			   SET EndDateTime = GetDate(),
				   Status = 'Error',
				   StatusMsg =  'Error archiving PRARAgingDetail'
			 WHERE ArchiveLogID = @Master_ArchiveLogID;

		END ELSE BEGIN

			UPDATE CRMArchive.dbo.ArchiveLog
			   SET EndDateTime = GetDate(),
				   Status = 'Error',
				   StatusMsg =  ERROR_MESSAGE(),
				   BeforeCount = @BeforeCount,
				   AfterCount = @AfterCount,
				   ArchiveCount = @ArchiveCount
			 WHERE ArchiveLogID = @Master_ArchiveLogID;


			UPDATE CRMArchive.dbo.ArchiveLog
			   SET EndDateTime = GetDate(),
				   Status = 'Error',
				   StatusMsg =  'Error archiving PRARAging'
			 WHERE ArchiveLogID = @Detail_ArchiveLogID;
		END

		EXEC CRM.dbo.usp_RethrowError

	END CATCH;
END
Go


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_ArchivePRRequest]'))
    drop procedure [dbo].[usp_ArchivePRRequest]
GO

CREATE PROCEDURE dbo.usp_ArchivePRRequest
	@CommitToArchive bit = 0
as
BEGIN
	SET NOCOUNT ON

	IF (@CommitToArchive = 0) BEGIN
		PRINT '*************************************************************'
		PRINT 'NOTE: COMMIT CHANGES IS TURNED OFF. NO CHANGES WILL BE SAVED!'
		PRINT '*************************************************************'
		PRINT ''
	END


	DECLARE @ArchiveThresholdDate datetime
	DECLARE @BeforeCount int, @AfterCount int, @ArchiveCount int
	DECLARE @ArchiveRowCount int, @DoubleCheckCount int

	DECLARE @Detail_ArchiveLogID int, @Master_ArchiveLogID int
	DECLARE @TableCount int
	
	SET @ArchiveThresholdDate = CRM.dbo.ufn_GetArchiveDate('PRRequest');
 
	INSERT INTO CRMArchive.dbo.ArchiveLog (SourceTable, TargetTable, DateField, ArchiveThresholdDate, Status, StartDateTime)
	VALUES ('CRM.dbo.PRRequest', 'CRMArchive.dbo.PRRequest', 'prreq_UpdatedDate', @ArchiveThresholdDate, 'In Progress', GETDATE());
	SELECT @Master_ArchiveLogID = SCOPE_IDENTITY();

	INSERT INTO CRMArchive.dbo.ArchiveLog (SourceTable, TargetTable, DateField, ArchiveThresholdDate, Status, StartDateTime)
	VALUES ('CRM.dbo.PRRequestDetail', 'CRMArchive.dbo.PRRequestDetail', 'prreq_UpdatedDate', @ArchiveThresholdDate, 'In Progress', GETDATE());
	SELECT @Detail_ArchiveLogID = SCOPE_IDENTITY();

	DECLARE @ArchiveIDs table (
		RecordID int
	)	

	INSERT INTO @ArchiveIDs 
	SELECT prreq_RequestID
      FROM CRM.dbo.PRRequest
     WHERE prreq_UpdatedDate <= @ArchiveThresholdDate;

	BEGIN TRANSACTION
	BEGIN TRY


		/* 
		* First process the Detail table
		*/
        SET @TableCount = 1;

		-- How many records already exist in the Archive table?
		SELECT @BeforeCount = COUNT(1)
		  FROM CRMArchive.dbo.PRRequestDetail;

		-- How many records will we be archiving?
		SELECT @ArchiveCount = COUNT(1)
		  FROM CRM.dbo.PRRequestDetail
		 WHERE prrc_RequestID IN 
				(SELECT RecordID FROM @ArchiveIDs);

		-- Archive the records
		INSERT INTO CRMArchive.dbo.PRRequestDetail
		SELECT * FROM CRM.dbo.PRRequestDetail
		 WHERE prrc_RequestID IN 
				(SELECT RecordID FROM @ArchiveIDs);
		SET @ArchiveRowCount = @@ROWCOUNT;

		-- Confirm the archive count
		IF (@ArchiveCount != @ArchiveRowCount) BEGIN
			Print 'PRRequestDetail: ArchiveCount != ArchiveRowCount'
			RAISERROR ('PRRequestDetail: ArchiveCount != ArchiveRowCount', 16, 1)		
			RETURN
		END

		-- Confirm the physical count matches the archive count
		SELECT @AfterCount = COUNT(1)
		  FROM CRMArchive.dbo.PRRequestDetail;
		IF (@ArchiveCount != (@AfterCount - @BeforeCount)) BEGIN
			Print 'PRRequestDetail: ArchiveCount != (AfterCount - BeforeCount)'
			RAISERROR ('PRRequestDetail: ArchiveCount != (AfterCount - BeforeCount)', 16, 1)
		END

		-- One final check.  Make sure all records we're about
		-- to delete exist in the archive table.
		SELECT @DoubleCheckCount = COUNT(1)
		  FROM CRM.dbo.PRRequestDetail
		 WHERE prrc_RequestID IN 
				(SELECT RecordID FROM @ArchiveIDs)
		   AND prrc_RequestID NOT IN 
                (SELECT prrc_RequestID FROM CRMArchive.dbo.PRRequestDetail);
	            
		IF (@DoubleCheckCount != 0) BEGIN
			Print 'PRRequestDetail: DoubleCheckCount > 0'
			RAISERROR ('PRRequestDetail: DoubleCheckCount > 0', 16, 1)
		END

		-- Remove the archived records
		DELETE FROM CRM.dbo.PRRequestDetail
		 WHERE prrc_RequestID IN 
				(SELECT RecordID FROM @ArchiveIDs);

 		-- Update our archive log
		UPDATE CRMArchive.dbo.ArchiveLog
		   SET EndDateTime = GetDate(),
			   Status = 'Completed',
			   BeforeCount = @BeforeCount,
			   AfterCount = @AfterCount,
			   ArchiveCount = @ArchiveCount
		 WHERE ArchiveLogID = @Detail_ArchiveLogID;


		/* 
		* Now process the Master table
		*/
        SET @TableCount = 2;

		-- How many records already exist in the Archive table?
		SELECT @BeforeCount = COUNT(1)
		  FROM CRMArchive.dbo.PRRequest;

		-- How many records will we be archiving?
		SELECT @ArchiveCount = COUNT(1)
		  FROM CRM.dbo.PRRequest
		 WHERE prreq_RequestID IN 
				(SELECT RecordID FROM @ArchiveIDs);

		-- Archive the records
		INSERT INTO CRMArchive.dbo.PRRequest
		SELECT * FROM CRM.dbo.PRRequest
		 WHERE prreq_RequestID IN 
				(SELECT RecordID FROM @ArchiveIDs);
		SET @ArchiveRowCount = @@ROWCOUNT;

		-- Confirm the archive count
		IF (@ArchiveCount != @ArchiveRowCount) BEGIN
			Print 'PRRequest: ArchiveCount != ArchiveRowCount'
			RAISERROR ('PRRequest: ArchiveCount != ArchiveRowCount', 16, 1)		
		END

		-- Confirm the physical count matches the archive count
		SELECT @AfterCount = COUNT(1)
		  FROM CRMArchive.dbo.PRRequest;
		IF (@ArchiveCount != (@AfterCount - @BeforeCount)) BEGIN
			Print 'PRRequest: ArchiveCount != (AfterCount - BeforeCount)'
			RAISERROR ('PRRequest: ArchiveCount != (AfterCount - BeforeCount)', 16, 1)
		END

		-- One final check.  Make sure all records we're about
		-- to delete exist in the archive table.
		SELECT @DoubleCheckCount = COUNT(1)
		  FROM CRM.dbo.PRRequest
		 WHERE prreq_RequestID IN 
				(SELECT RecordID FROM @ArchiveIDs)
		   AND prreq_RequestID NOT IN 
                (SELECT prreq_RequestID FROM CRMArchive.dbo.PRRequest);
	            
		IF (@DoubleCheckCount != 0) BEGIN
			Print 'PRRequest: DoubleCheckCount > 0'
			RAISERROR ('PRRequest: DoubleCheckCount > 0', 16, 1)
		END

		-- Remove the archived records
		DELETE FROM CRM.dbo.PRRequest
		 WHERE prreq_RequestID IN 
				(SELECT RecordID FROM @ArchiveIDs);

 		-- Update our archive log
		UPDATE CRMArchive.dbo.ArchiveLog
		   SET EndDateTime = GetDate(),
			   Status = 'Completed',
			   BeforeCount = @BeforeCount,
			   AfterCount = @AfterCount,
			   ArchiveCount = @ArchiveCount
		 WHERE ArchiveLogID = @Master_ArchiveLogID;


		IF (@CommitToArchive = 1) BEGIN
			PRINT 'COMMITTING ARCHIVE UPDATE'
			COMMIT
		END ELSE BEGIN
			PRINT 'ROLLING BACK ARCHIVE UPDATE'
			SELECT * FROM CRMArchive.dbo.ArchiveLog WHERE ArchiveLogID IN (@Master_ArchiveLogID, @Detail_ArchiveLogID);
			ROLLBACK TRANSACTION
			DELETE FROM CRMArchive.dbo.ArchiveLog WHERE ArchiveLogID IN (@Master_ArchiveLogID, @Detail_ArchiveLogID);
		END

		
	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		IF (@TableCount = 1) BEGIN

			UPDATE CRMArchive.dbo.ArchiveLog
			   SET EndDateTime = GetDate(),
				   Status = 'Error',
				   StatusMsg =  ERROR_MESSAGE(),
				   BeforeCount = @BeforeCount,
				   AfterCount = @AfterCount,
				   ArchiveCount = @ArchiveCount
			 WHERE ArchiveLogID = @Detail_ArchiveLogID;


			UPDATE CRMArchive.dbo.ArchiveLog
			   SET EndDateTime = GetDate(),
				   Status = 'Error',
				   StatusMsg =  'Error archiving PRRequestDetail'
			 WHERE ArchiveLogID = @Master_ArchiveLogID;

		END ELSE BEGIN

			UPDATE CRMArchive.dbo.ArchiveLog
			   SET EndDateTime = GetDate(),
				   Status = 'Error',
				   StatusMsg =  ERROR_MESSAGE(),
				   BeforeCount = @BeforeCount,
				   AfterCount = @AfterCount,
				   ArchiveCount = @ArchiveCount
			 WHERE ArchiveLogID = @Master_ArchiveLogID;


			UPDATE CRMArchive.dbo.ArchiveLog
			   SET EndDateTime = GetDate(),
				   Status = 'Error',
				   StatusMsg =  'Error archiving PRRequest'
			 WHERE ArchiveLogID = @Detail_ArchiveLogID;
		END

		EXEC CRM.dbo.usp_RethrowError

	END CATCH;
END
Go


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_ArchivePRTES]'))
    drop procedure [dbo].[usp_ArchivePRTES]
GO

CREATE PROCEDURE dbo.usp_ArchivePRTES
	@CommitToArchive bit = 0
as
BEGIN
	SET NOCOUNT ON

	IF (@CommitToArchive = 0) BEGIN
		PRINT '*************************************************************'
		PRINT 'NOTE: COMMIT CHANGES IS TURNED OFF. NO CHANGES WILL BE SAVED!'
		PRINT '*************************************************************'
		PRINT ''
	END


	DECLARE @ArchiveThresholdDate datetime
	DECLARE @BeforeCount int, @AfterCount int, @ArchiveCount int
	DECLARE @ArchiveRowCount int, @DoubleCheckCount int

	DECLARE @Detail_ArchiveLogID int, @Master_ArchiveLogID int
	DECLARE @TableCount int
	
	SET @ArchiveThresholdDate = CRM.dbo.ufn_GetArchiveDate('PRTES');
 
	INSERT INTO CRMArchive.dbo.ArchiveLog (SourceTable, TargetTable, DateField, ArchiveThresholdDate, Status, StartDateTime)
	VALUES ('CRM.dbo.PRTES', 'CRMArchive.dbo.PRTES', 'prte_UpdatedDate', @ArchiveThresholdDate, 'In Progress', GETDATE());
	SELECT @Master_ArchiveLogID = SCOPE_IDENTITY();

	INSERT INTO CRMArchive.dbo.ArchiveLog (SourceTable, TargetTable, DateField, ArchiveThresholdDate, Status, StartDateTime)
	VALUES ('CRM.dbo.PRTESDetail', 'CRMArchive.dbo.PRTESDetail', 'prte_UpdatedDate', @ArchiveThresholdDate, 'In Progress', GETDATE());
	SELECT @Detail_ArchiveLogID = SCOPE_IDENTITY();

	DECLARE @ArchiveIDs table (
		RecordID int
	)	

	INSERT INTO @ArchiveIDs 
	SELECT prte_TESId
      FROM CRM.dbo.PRTES
     WHERE prte_UpdatedDate <= @ArchiveThresholdDate;

	BEGIN TRANSACTION
	BEGIN TRY


		/* 
		* First process the Detail table
		*/
        SET @TableCount = 1;

		-- How many records already exist in the Archive table?
		SELECT @BeforeCount = COUNT(1)
		  FROM CRMArchive.dbo.PRTESDetail;

		-- How many records will we be archiving?
		SELECT @ArchiveCount = COUNT(1)
		  FROM CRM.dbo.PRTESDetail
		 WHERE prt2_TESId IN 
				(SELECT RecordID FROM @ArchiveIDs);

		-- Archive the records
		INSERT INTO CRMArchive.dbo.PRTESDetail
		SELECT * FROM CRM.dbo.PRTESDetail
		 WHERE prt2_TESId IN 
				(SELECT RecordID FROM @ArchiveIDs);
		SET @ArchiveRowCount = @@ROWCOUNT;

		-- Confirm the archive count
		IF (@ArchiveCount != @ArchiveRowCount) BEGIN
			Print 'PRTESDetail: ArchiveCount != ArchiveRowCount'
			RAISERROR ('PRTESDetail: ArchiveCount != ArchiveRowCount', 16, 1)		
			RETURN
		END

		-- Confirm the physical count matches the archive count
		SELECT @AfterCount = COUNT(1)
		  FROM CRMArchive.dbo.PRTESDetail;
		IF (@ArchiveCount != (@AfterCount - @BeforeCount)) BEGIN
			Print 'PRTESDetail: ArchiveCount != (AfterCount - BeforeCount)'
			RAISERROR ('PRTESDetail: ArchiveCount != (AfterCount - BeforeCount)', 16, 1)
		END

		-- One final check.  Make sure all records we're about
		-- to delete exist in the archive table.
		SELECT @DoubleCheckCount = COUNT(1)
		  FROM CRM.dbo.PRTESDetail
		 WHERE prt2_TESId IN 
				(SELECT RecordID FROM @ArchiveIDs)
		   AND prt2_TESId NOT IN 
                (SELECT prt2_TESId FROM CRMArchive.dbo.PRTESDetail);
	            
		IF (@DoubleCheckCount != 0) BEGIN
			Print 'PRTESDetail: DoubleCheckCount > 0'
			RAISERROR ('PRTESDetail: DoubleCheckCount > 0', 16, 1)
		END

		-- Remove the archived records
		DELETE FROM CRM.dbo.PRTESDetail
		 WHERE prt2_TESId IN 
				(SELECT RecordID FROM @ArchiveIDs);

 		-- Update our archive log
		UPDATE CRMArchive.dbo.ArchiveLog
		   SET EndDateTime = GetDate(),
			   Status = 'Completed',
			   BeforeCount = @BeforeCount,
			   AfterCount = @AfterCount,
			   ArchiveCount = @ArchiveCount
		 WHERE ArchiveLogID = @Detail_ArchiveLogID;


		/* 
		* Now process the Master table
		*/
        SET @TableCount = 2;

		-- How many records already exist in the Archive table?
		SELECT @BeforeCount = COUNT(1)
		  FROM CRMArchive.dbo.PRTES;

		-- How many records will we be archiving?
		SELECT @ArchiveCount = COUNT(1)
		  FROM CRM.dbo.PRTES
		 WHERE prte_TESId IN 
				(SELECT RecordID FROM @ArchiveIDs);

		-- Archive the records
		INSERT INTO CRMArchive.dbo.PRTES
		SELECT * FROM CRM.dbo.PRTES
		 WHERE prte_TESId IN 
				(SELECT RecordID FROM @ArchiveIDs);
		SET @ArchiveRowCount = @@ROWCOUNT;

		-- Confirm the archive count
		IF (@ArchiveCount != @ArchiveRowCount) BEGIN
			Print 'PRTES: ArchiveCount != ArchiveRowCount'
			RAISERROR ('PRTES: ArchiveCount != ArchiveRowCount', 16, 1)		
		END

		-- Confirm the physical count matches the archive count
		SELECT @AfterCount = COUNT(1)
		  FROM CRMArchive.dbo.PRTES;
		IF (@ArchiveCount != (@AfterCount - @BeforeCount)) BEGIN
			Print 'PRTES: ArchiveCount != (AfterCount - BeforeCount)'
			RAISERROR ('PRTES: ArchiveCount != (AfterCount - BeforeCount)', 16, 1)
		END

		-- One final check.  Make sure all records we're about
		-- to delete exist in the archive table.
		SELECT @DoubleCheckCount = COUNT(1)
		  FROM CRM.dbo.PRTES
		 WHERE prte_TESId IN 
				(SELECT RecordID FROM @ArchiveIDs)
		   AND prte_TESId NOT IN 
                (SELECT prte_TESId FROM CRMArchive.dbo.PRTES);
	            
		IF (@DoubleCheckCount != 0) BEGIN
			Print 'PRTES: DoubleCheckCount > 0'
			RAISERROR ('PRTES: DoubleCheckCount > 0', 16, 1)
		END

		-- Remove the archived records
		DELETE FROM CRM.dbo.PRTES
		 WHERE prte_TESId IN 
				(SELECT RecordID FROM @ArchiveIDs);

 		-- Update our archive log
		UPDATE CRMArchive.dbo.ArchiveLog
		   SET EndDateTime = GetDate(),
			   Status = 'Completed',
			   BeforeCount = @BeforeCount,
			   AfterCount = @AfterCount,
			   ArchiveCount = @ArchiveCount
		 WHERE ArchiveLogID = @Master_ArchiveLogID;


		IF (@CommitToArchive = 1) BEGIN
			PRINT 'COMMITTING ARCHIVE UPDATE'
			COMMIT
		END ELSE BEGIN
			PRINT 'ROLLING BACK ARCHIVE UPDATE'
			SELECT * FROM CRMArchive.dbo.ArchiveLog WHERE ArchiveLogID IN (@Master_ArchiveLogID, @Detail_ArchiveLogID);
			ROLLBACK TRANSACTION
			DELETE FROM CRMArchive.dbo.ArchiveLog WHERE ArchiveLogID IN (@Master_ArchiveLogID, @Detail_ArchiveLogID);
		END

		
	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		IF (@TableCount = 1) BEGIN

			UPDATE CRMArchive.dbo.ArchiveLog
			   SET EndDateTime = GetDate(),
				   Status = 'Error',
				   StatusMsg =  ERROR_MESSAGE(),
				   BeforeCount = @BeforeCount,
				   AfterCount = @AfterCount,
				   ArchiveCount = @ArchiveCount
			 WHERE ArchiveLogID = @Detail_ArchiveLogID;


			UPDATE CRMArchive.dbo.ArchiveLog
			   SET EndDateTime = GetDate(),
				   Status = 'Error',
				   StatusMsg =  'Error archiving PRTESDetail'
			 WHERE ArchiveLogID = @Master_ArchiveLogID;

		END ELSE BEGIN

			UPDATE CRMArchive.dbo.ArchiveLog
			   SET EndDateTime = GetDate(),
				   Status = 'Error',
				   StatusMsg =  ERROR_MESSAGE(),
				   BeforeCount = @BeforeCount,
				   AfterCount = @AfterCount,
				   ArchiveCount = @ArchiveCount
			 WHERE ArchiveLogID = @Master_ArchiveLogID;


			UPDATE CRMArchive.dbo.ArchiveLog
			   SET EndDateTime = GetDate(),
				   Status = 'Error',
				   StatusMsg =  'Error archiving PRTES'
			 WHERE ArchiveLogID = @Detail_ArchiveLogID;
		END

		EXEC CRM.dbo.usp_RethrowError

	END CATCH;
END
Go


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_ArchivePRTransaction]'))
    drop procedure [dbo].[usp_ArchivePRTransaction]
GO

CREATE PROCEDURE dbo.usp_ArchivePRTransaction
	@CommitToArchive bit = 0
as
BEGIN
	SET NOCOUNT ON

	IF (@CommitToArchive = 0) BEGIN
		PRINT '*************************************************************'
		PRINT 'NOTE: COMMIT CHANGES IS TURNED OFF. NO CHANGES WILL BE SAVED!'
		PRINT '*************************************************************'
		PRINT ''
	END


	DECLARE @ArchiveThresholdDate datetime
	DECLARE @BeforeCount int, @AfterCount int, @ArchiveCount int
	DECLARE @ArchiveRowCount int, @DoubleCheckCount int

	DECLARE @Detail_ArchiveLogID int, @Master_ArchiveLogID int
	DECLARE @TableCount int
	
	SET @ArchiveThresholdDate = CRM.dbo.ufn_GetArchiveDate('PRTransaction');
 
	INSERT INTO CRMArchive.dbo.ArchiveLog (SourceTable, TargetTable, DateField, ArchiveThresholdDate, Status, StartDateTime)
	VALUES ('CRM.dbo.PRTransaction', 'CRMArchive.dbo.PRTransaction', 'prtx_UpdatedDate', @ArchiveThresholdDate, 'In Progress', GETDATE());
	SELECT @Master_ArchiveLogID = SCOPE_IDENTITY();

	INSERT INTO CRMArchive.dbo.ArchiveLog (SourceTable, TargetTable, DateField, ArchiveThresholdDate, Status, StartDateTime)
	VALUES ('CRM.dbo.PRTransactionDetail', 'CRMArchive.dbo.PRTransactionDetail', 'prtx_UpdatedDate', @ArchiveThresholdDate, 'In Progress', GETDATE());
	SELECT @Detail_ArchiveLogID = SCOPE_IDENTITY();

	DECLARE @ArchiveIDs table (
		RecordID int
	)	

	INSERT INTO @ArchiveIDs 
	SELECT prtx_TransactionId
      FROM CRM.dbo.PRTransaction
     WHERE prtx_UpdatedDate <= @ArchiveThresholdDate;

	BEGIN TRANSACTION
	BEGIN TRY


		/* 
		* First process the Detail table
		*/
        SET @TableCount = 1;

		-- How many records already exist in the Archive table?
		SELECT @BeforeCount = COUNT(1)
		  FROM CRMArchive.dbo.PRTransactionDetail;

		-- How many records will we be archiving?
		SELECT @ArchiveCount = COUNT(1)
		  FROM CRM.dbo.PRTransactionDetail
		 WHERE prtd_TransactionId IN 
				(SELECT RecordID FROM @ArchiveIDs);

		-- Archive the records
		INSERT INTO CRMArchive.dbo.PRTransactionDetail
		SELECT * FROM CRM.dbo.PRTransactionDetail
		 WHERE prtd_TransactionId IN 
				(SELECT RecordID FROM @ArchiveIDs);
		SET @ArchiveRowCount = @@ROWCOUNT;

		-- Confirm the archive count
		IF (@ArchiveCount != @ArchiveRowCount) BEGIN
			Print 'PRTransactionDetail: ArchiveCount != ArchiveRowCount'
			RAISERROR ('PRTransactionDetail: ArchiveCount != ArchiveRowCount', 16, 1)		
			RETURN
		END

		-- Confirm the physical count matches the archive count
		SELECT @AfterCount = COUNT(1)
		  FROM CRMArchive.dbo.PRTransactionDetail;
		IF (@ArchiveCount != (@AfterCount - @BeforeCount)) BEGIN
			Print 'PRTransactionDetail: ArchiveCount != (AfterCount - BeforeCount)'
			RAISERROR ('PRTransactionDetail: ArchiveCount != (AfterCount - BeforeCount)', 16, 1)
		END

		-- One final check.  Make sure all records we're about
		-- to delete exist in the archive table.
		SELECT @DoubleCheckCount = COUNT(1)
		  FROM CRM.dbo.PRTransactionDetail
		 WHERE prtd_TransactionId IN 
				(SELECT RecordID FROM @ArchiveIDs)
		   AND prtd_TransactionId NOT IN 
                (SELECT prtd_TransactionId FROM CRMArchive.dbo.PRTransactionDetail);
	            
		IF (@DoubleCheckCount != 0) BEGIN
			Print 'PRTransactionDetail: DoubleCheckCount > 0'
			RAISERROR ('PRTransactionDetail: DoubleCheckCount > 0', 16, 1)
		END

		-- Remove the archived records
		DELETE FROM CRM.dbo.PRTransactionDetail
		 WHERE prtd_TransactionId IN 
				(SELECT RecordID FROM @ArchiveIDs);

 		-- Update our archive log
		UPDATE CRMArchive.dbo.ArchiveLog
		   SET EndDateTime = GetDate(),
			   Status = 'Completed',
			   BeforeCount = @BeforeCount,
			   AfterCount = @AfterCount,
			   ArchiveCount = @ArchiveCount
		 WHERE ArchiveLogID = @Detail_ArchiveLogID;


		/* 
		* Now process the Master table
		*/
        SET @TableCount = 2;

		-- How many records already exist in the Archive table?
		SELECT @BeforeCount = COUNT(1)
		  FROM CRMArchive.dbo.PRTransaction;

		-- How many records will we be archiving?
		SELECT @ArchiveCount = COUNT(1)
		  FROM CRM.dbo.PRTransaction
		 WHERE prtx_TransactionId IN 
				(SELECT RecordID FROM @ArchiveIDs);

		-- Archive the records
		INSERT INTO CRMArchive.dbo.PRTransaction
		SELECT * FROM CRM.dbo.PRTransaction
		 WHERE prtx_TransactionId IN 
				(SELECT RecordID FROM @ArchiveIDs);
		SET @ArchiveRowCount = @@ROWCOUNT;

		-- Confirm the archive count
		IF (@ArchiveCount != @ArchiveRowCount) BEGIN
			Print 'PRTransaction: ArchiveCount != ArchiveRowCount'
			RAISERROR ('PRTransaction: ArchiveCount != ArchiveRowCount', 16, 1)		
		END

		-- Confirm the physical count matches the archive count
		SELECT @AfterCount = COUNT(1)
		  FROM CRMArchive.dbo.PRTransaction;
		IF (@ArchiveCount != (@AfterCount - @BeforeCount)) BEGIN
			Print 'PRTransaction: ArchiveCount != (AfterCount - BeforeCount)'
			RAISERROR ('PRTransaction: ArchiveCount != (AfterCount - BeforeCount)', 16, 1)
		END

		-- One final check.  Make sure all records we're about
		-- to delete exist in the archive table.
		SELECT @DoubleCheckCount = COUNT(1)
		  FROM CRM.dbo.PRTransaction
		 WHERE prtx_TransactionId IN 
				(SELECT RecordID FROM @ArchiveIDs)
		   AND prtx_TransactionId NOT IN 
                (SELECT prtx_TransactionId FROM CRMArchive.dbo.PRTransaction);
	            
		IF (@DoubleCheckCount != 0) BEGIN
			Print 'PRTransaction: DoubleCheckCount > 0'
			RAISERROR ('PRTransaction: DoubleCheckCount > 0', 16, 1)
		END

		-- Remove the archived records
		DELETE FROM CRM.dbo.PRTransaction
		 WHERE prtx_TransactionId IN 
				(SELECT RecordID FROM @ArchiveIDs);

 		-- Update our archive log
		UPDATE CRMArchive.dbo.ArchiveLog
		   SET EndDateTime = GetDate(),
			   Status = 'Completed',
			   BeforeCount = @BeforeCount,
			   AfterCount = @AfterCount,
			   ArchiveCount = @ArchiveCount
		 WHERE ArchiveLogID = @Master_ArchiveLogID;


		IF (@CommitToArchive = 1) BEGIN
			PRINT 'COMMITTING ARCHIVE UPDATE'
			COMMIT
		END ELSE BEGIN
			PRINT 'ROLLING BACK ARCHIVE UPDATE'
			SELECT * FROM CRMArchive.dbo.ArchiveLog WHERE ArchiveLogID IN (@Master_ArchiveLogID, @Detail_ArchiveLogID);
			ROLLBACK TRANSACTION
			DELETE FROM CRMArchive.dbo.ArchiveLog WHERE ArchiveLogID IN (@Master_ArchiveLogID, @Detail_ArchiveLogID);
		END

		
	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		IF (@TableCount = 1) BEGIN

			UPDATE CRMArchive.dbo.ArchiveLog
			   SET EndDateTime = GetDate(),
				   Status = 'Error',
				   StatusMsg =  ERROR_MESSAGE(),
				   BeforeCount = @BeforeCount,
				   AfterCount = @AfterCount,
				   ArchiveCount = @ArchiveCount
			 WHERE ArchiveLogID = @Detail_ArchiveLogID;


			UPDATE CRMArchive.dbo.ArchiveLog
			   SET EndDateTime = GetDate(),
				   Status = 'Error',
				   StatusMsg =  'Error archiving PRTransactionDetail'
			 WHERE ArchiveLogID = @Master_ArchiveLogID;

		END ELSE BEGIN

			UPDATE CRMArchive.dbo.ArchiveLog
			   SET EndDateTime = GetDate(),
				   Status = 'Error',
				   StatusMsg =  ERROR_MESSAGE(),
				   BeforeCount = @BeforeCount,
				   AfterCount = @AfterCount,
				   ArchiveCount = @ArchiveCount
			 WHERE ArchiveLogID = @Master_ArchiveLogID;


			UPDATE CRMArchive.dbo.ArchiveLog
			   SET EndDateTime = GetDate(),
				   Status = 'Error',
				   StatusMsg =  'Error archiving PRTransaction'
			 WHERE ArchiveLogID = @Detail_ArchiveLogID;
		END

		EXEC CRM.dbo.usp_RethrowError

	END CATCH;
END
Go




if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_ArchivePRCommunicationLog]'))
    drop procedure [dbo].[usp_ArchivePRCommunicationLog]
GO

CREATE PROCEDURE dbo.usp_ArchivePRCommunicationLog
	@CommitToArchive bit = 0
As
BEGIN
	SET NOCOUNT ON

	IF (@CommitToArchive = 0) BEGIN
		PRINT '*************************************************************'
		PRINT 'NOTE: COMMIT CHANGES IS TURNED OFF. NO CHANGES WILL BE SAVED!'
		PRINT '*************************************************************'
		PRINT ''
	END

	DECLARE @ArchiveThresholdDate datetime
	DECLARE @BeforeCount int, @AfterCount int, @ArchiveCount int
	DECLARE @ArchiveRowCount int, @DoubleCheckCount int
	DECLARE @ArchiveLogID int
	
	SET @ArchiveThresholdDate = CRM.dbo.ufn_GetArchiveDate('PRCommunicationLog');
 
	INSERT INTO CRMArchive.dbo.ArchiveLog (SourceTable, TargetTable, DateField, ArchiveThresholdDate, Status, StartDateTime)
	VALUES ('CRM.dbo.PRCommunicationLog', 'CRMArchive.dbo.PRCommunicationLog', 'prcoml_UpdatedDate', @ArchiveThresholdDate, 'In Progress', GETDATE());
	SELECT @ArchiveLogID = SCOPE_IDENTITY();

	BEGIN TRANSACTION
	BEGIN TRY

		-- How many records already exist in the Archive table?
		SELECT @BeforeCount = COUNT(1)
		  FROM CRMArchive.dbo.PRCommunicationLog;

		-- How many records will we be archiving?
		SELECT @ArchiveCount = COUNT(1)
		  FROM CRM.dbo.PRCommunicationLog
		 WHERE prcoml_UpdatedDate <= @ArchiveThresholdDate;

		-- Archive the records
		INSERT INTO CRMArchive.dbo.PRCommunicationLog
		SELECT * FROM CRM.dbo.PRCommunicationLog
 		 WHERE prcoml_UpdatedDate <= @ArchiveThresholdDate;
		SET @ArchiveRowCount = @@ROWCOUNT;

		-- Confirm the archive count
		IF (@ArchiveCount != @ArchiveRowCount) BEGIN
			Print 'ArchiveCount != ArchiveRowCount'
			RAISERROR ('ArchiveCount != ArchiveRowCount', 16, 1)		
		END

		-- Confirm the physical count matches the archive count
		SELECT @AfterCount = COUNT(1)
		  FROM CRMArchive.dbo.PRCommunicationLog;
		IF (@ArchiveCount != (@AfterCount - @BeforeCount)) BEGIN
			Print 'ArchiveCount != (AfterCount - BeforeCount)'
			RAISERROR ('ArchiveCount != (AfterCount - BeforeCount)', 16, 1)
		END

		-- One final check.  Make sure all records we're about
		-- to delete exist in the archive table.
		SELECT @DoubleCheckCount = COUNT(1)
		  FROM CRM.dbo.PRCommunicationLog
		 WHERE prcoml_UpdatedDate <= @ArchiveThresholdDate
			AND prcoml_CommunicationLog NOT IN (
				SELECT prcoml_CommunicationLog
				  FROM CRMArchive.dbo.PRCommunicationLog);
	            
		IF (@DoubleCheckCount != 0) BEGIN
			Print 'DoubleCheckCount > 0'
			RAISERROR ('DoubleCheckCount > 0', 16, 1)
		END

		-- Remove the archived records
		DELETE FROM CRM.dbo.PRCommunicationLog
 		 WHERE prcoml_UpdatedDate <= @ArchiveThresholdDate;

 		-- Update our archive log
		UPDATE CRMArchive.dbo.ArchiveLog
		   SET EndDateTime = GetDate(),
			   Status = 'Completed',
			   BeforeCount = @BeforeCount,
			   AfterCount = @AfterCount,
			   ArchiveCount = @ArchiveCount
		 WHERE ArchiveLogID = @ArchiveLogID;


		IF (@CommitToArchive = 1) BEGIN
			PRINT 'COMMITTING ARCHIVE UPDATE'
			COMMIT
		END ELSE BEGIN
			PRINT 'ROLLING BACK ARCHIVE UPDATE'
			SELECT * FROM CRMArchive.dbo.ArchiveLog WHERE ArchiveLogID = @ArchiveLogID;
			ROLLBACK TRANSACTION
			DELETE FROM CRMArchive.dbo.ArchiveLog WHERE ArchiveLogID = @ArchiveLogID;
		END

	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		UPDATE CRMArchive.dbo.ArchiveLog
		   SET EndDateTime = GetDate(),
			   Status = 'Error',
			   StatusMsg =  ERROR_MESSAGE(),
			   BeforeCount = @BeforeCount,
			   AfterCount = @AfterCount,
			   ArchiveCount = @ArchiveCount
		 WHERE ArchiveLogID = @ArchiveLogID;

		EXEC CRM.dbo.usp_RethrowError

	END CATCH;
END
Go




if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_ArchiveCRM]'))
    drop procedure [dbo].[usp_ArchiveCRM]
GO

CREATE PROCEDURE dbo.usp_ArchiveCRM
	@CommitToArchive bit = 0
As
BEGIN

	DECLARE @ArchiveRecordCount int, @ArchiveTableCount int, @ErrorCount int, @TableCount int
	DECLARE @ErrMsg varchar(2000)
	DECLARE @StartDateTime DateTime

	SET @StartDateTime = GETDATE()
	SET @TableCount = 21
	SET @ErrMsg = ''

    EXEC usp_ArchivePRARAging @CommitToArchive
	EXEC usp_ArchiveCommunication @CommitToArchive
	EXEC usp_ArchivePRAdCampaignAuditTrail @CommitToArchive
	EXEC usp_ArchivePREquifaxAuditLog @CommitToArchive
	EXEC usp_ArchivePRExternalLinkAuditTrail @CommitToArchive
    EXEC usp_ArchivePRRequest @CommitToArchive
	EXEC usp_ArchivePRSearchAuditTrail @CommitToArchive
	EXEC usp_ArchivePRSearchWizardAuditTrail @CommitToArchive
	EXEC usp_ArchivePRTransaction @CommitToArchive
	EXEC usp_ArchivePRWebAuditTrail @CommitToArchive
	EXEC usp_ArchivePRWebServiceAuditTrail @CommitToArchive
	EXEC usp_ArchivePRTESRequest @CommitToArchive
	EXEC usp_ArchivePRCommunicationLog @CommitToArchive

	--
	--  Only check for errors if we're committing, because
	--  if we are not committing, there are no archive log 
	--  records.
	--
	IF (@CommitToArchive = 1) BEGIN 
		SELECT @ArchiveTableCount = COUNT(1)
		  FROM CRMArchive.dbo.ArchiveLog
		 WHERE StartDateTime BETWEEN @StartDateTime AND GETDATE();

		IF (@ArchiveTableCount != @TableCount) BEGIN
			SET @ErrMsg = 'CRMArchive ArchiveLog Table Count Mismatch.  Expecting ' + CAST(@TableCount As varchar(4)) + ' tables, but found ' + CAST(@ArchiveTableCount as varchar(4)) + '.'
		END


		SELECT @ErrorCount = COUNT(1)
		  FROM CRMArchive.dbo.ArchiveLog
		 WHERE StartDateTime BETWEEN @StartDateTime AND GETDATE()
		   AND Status <> 'Completed';	
			

		IF (@ErrorCount > 0) BEGIN
			IF (LEN(@ErrMsg) > 0) BEGIN
				SET @ErrMsg = @ErrMsg + CHAR(10) + CHAR(13) + CHAR(10) + CHAR(13)
			END
			SET @ErrMsg = @ErrMsg + 'Errors found in the CRMArchive.ArchiveLog Table.'
		END
		
		IF (LEN(@ErrMsg) > 0) BEGIN

			EXEC usp_CreateEmail @To = 'it@bluebookservices.com', 
								 @Subject = 'CRMArchive Errors', 
								 @Content = @ErrMsg,
								 @DoNotRecordCommunication = 1,
								 @Priority = 'High'

		END	
	END
		
	SELECT @ArchiveRecordCount = ISNULL(SUM(ArchiveCount), 0)
      FROM CRMArchive.dbo.ArchiveLog
     WHERE StartDateTime BETWEEN @StartDateTime AND GETDATE();

	PRINT 'Execution time (minutes): ' +  CONVERT(varchar(10), DATEDIFF(minute, @StartDateTime, GETDATE()))
	PRINT 'Archived ' + CAST(@ArchiveRecordCount AS varchar(50)) + ' records.'
	PRINT ''

END
Go


