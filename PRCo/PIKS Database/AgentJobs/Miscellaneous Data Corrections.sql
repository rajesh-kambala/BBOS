USE [msdb]
GO

/****** Object:  Job [Miscellaneous Data Corrections]    Script Date: 5/24/2022 6:10:57 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [BBSI]    Script Date: 5/24/2022 6:10:57 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'BBSI' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'BBSI'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Miscellaneous Data Corrections', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Contains:
--  Welcome Call Task Creation
-- PACA Task Moves for Ratings
-- Setting attention line service IDs to 0', 
		@category_name=N'BBSI', 
		@owner_login_name=N'BBSAgentJobs', 
		@notify_email_operator_name=N'SQL Support Notifications', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Welcome Call Tasks]    Script Date: 5/24/2022 6:10:58 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Welcome Call Tasks', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE CRM;

DECLARE @Now DATETIME = GETDATE();

DECLARE @CompanyCount INT;
DECLARE @ndx INT;
DECLARE @comp_CompanyId INT;
DECLARE @Due DATETIME;
DECLARE @AssignedTo INT;

DECLARE @WelcomeCalls TABLE (ndx INT IDENTITY, CompID INT, Due DATETIME, AssignTo INT)

INSERT INTO @WelcomeCalls (CompID, AssignTo, Due)
SELECT 
	prse_CompanyId
	, CASE WHEN comp_PRIndustryType = ''L'' THEN prci_LumberCustomerServiceId ELSE prci_CustomerServiceId END
	, DATEADD(d, 28,max(prsoat_CreatedDate))
FROM PRService o WITH (NOLOCK)
INNER JOIN Company WITH (NOLOCK) ON comp_CompanyID = prse_CompanyId
INNER JOIN vPRLocation WITH (NOLOCK) ON prci_CityID = comp_PRListingCityID
inner join PRSalesOrderAuditTrail s with (nolock) on prsoat_ItemCode = prse_ServiceCode
	and o.SalesOrderNo = s.prsoat_SalesOrderNo
WHERE 
	prse_CreatedDate > ''1/1/2013'' 
	AND prse_Primary = ''Y''
	AND prse_CompanyId NOT IN 
		(SELECT prse_CompanyId 
		FROM PRService_Backup WITH (NOLOCK)
		WHERE prse_ServiceCode LIKE ''BBS%''
		AND prse_CompanyId IS NOT NULL)
	AND prse_CompanyId NOT IN
		(SELECT prsoat_SoldToCompany
		FROM PRSalesOrderAuditTrail a WITH (NOLOCK)
		INNER JOIN MAS_PRC.dbo.CI_Item i WITH (NOLOCK) ON i.ItemCode = prsoat_ItemCode
			AND i.Category2 = ''Primary''
		WHERE a.prsoat_CreatedDate <= DATEADD(d,-30,GETDATE()))
	AND prse_CompanyId NOT IN
		(SELECT CmLi_Comm_CompanyID
		FROM vCommunication WITH (NOLOCK)
		WHERE comm_PRSubcategory = ''Welcome''
		AND (Comm_Status = ''Pending'' OR Comm_CreatedDate >= DATEADD(d,-60,GETDATE())) AND CmLi_Comm_CompanyID IS NOT NULL)
AND prse_CompanyID NOT IN (195986)
AND comp_PRIndustryType <> ''L''
	GROUP BY prse_CompanyID, CASE WHEN comp_PRIndustryType = ''L'' THEN prci_LumberCustomerServiceId ELSE prci_CustomerServiceId END


SELECT @CompanyCount =  COUNT(1) FROM @WelcomeCalls;
SET @ndx = 0;

WHILE (@ndx < @CompanyCount)
	BEGIN
		SET @ndx = @ndx + 1
		SELECT @comp_companyid = NULL, @AssignedTo = NULL, @Due = NULL;

		-- get the company we are operating on
			 SELECT @comp_companyid = CompID, @Due = Due, @AssignedTo = AssignTo
			 FROM @WelcomeCalls WHERE ndx = @ndx
			
			EXEC usp_CreateTask
				@Startdatetime = @Due
				, @DueDateTime = @Due
				, @CreatorUserID = 1
				, @AssignedToUserID = @AssignedTo
				, @TaskNotes = ''Call for new member follow up.''
				, @RelatedCompanyID = @comp_CompanyId
				, @Status = ''Pending''
				, @Action = ''PhoneOut''
				, @PRCategory = ''CS''
				, @PRSubCategory = ''Welcome'';

END
', 
		@database_name=N'CRM', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Move PACA Tasks]    Script Date: 5/24/2022 6:10:58 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Move PACA Tasks', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'-- CHW 3014-08-23  Disabled for now per KWS

/*
UPDATE Comm_Link
SET CmLi_Comm_UserID = 1044
FROM Comm_Link
INNER JOIN Communication on Comm_CommunicationId = CmLi_Comm_CommunicationId
INNER JOIN Users ON User_UserId = CmLi_Comm_UserID
	AND User_PrimaryChannelId IN (1,2)
WHERE Comm_Note LIKE ''%PACA reports changes%''
AND Comm_Status = ''Pending''
and CmLi_Comm_UserId != 1044;
*/', 
		@database_name=N'CRM', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Miscellaneous Data Corrections', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=4, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20130227, 
		@active_end_date=99991231, 
		@active_start_time=60000, 
		@active_end_time=180000, 
		@schedule_uid=N'2213e33d-2a8a-4d52-a2fb-bd5cb067db44'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

