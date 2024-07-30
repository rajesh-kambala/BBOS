USE [msdb]
GO

/****** Object:  Job [Refresh Lumber WD List]    Script Date: 5/24/2022 6:12:27 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [BBSI]    Script Date: 5/24/2022 6:12:27 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'BBSI' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'BBSI'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Refresh Lumber WD List', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'BBSI', 
		@owner_login_name=N'BBSAgentJobs', 
		@notify_email_operator_name=N'SQL Support Notifications', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Update Webuser List]    Script Date: 5/24/2022 6:12:27 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Update Webuser List', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @StartDate datetime = GETDATE()
DECLARE @CompanyID int = 279121
DECLARE @WebUserListID int = 0

SELECT @WebUserListID = prwucl_WebUserListID
  FROM PRWebUserList
 WHERE prwucl_CompanyID = @CompanyID
   AND prwucl_Name = ''Lumber Members''

IF (@WebUserListID = 0) BEGIN
	INSERT INTO PRWebUserList (prwucl_WebUserID, prwucl_CompanyID, prwucl_HQID, prwucl_TypeCode, prwucl_Name, prwucl_Description, prwucl_IsPrivate, prwucl_CreatedBy, prwucl_CreatedDate, prwucl_UpdatedBy, prwucl_UpdatedDate, prwucl_Timestamp)
                       VALUES (58849, @CompanyID, @CompanyID, ''CL'', ''Lumber Members'', ''Lumber companies that are BBSI members.'', NULL, 58849, @StartDate, 58849, @StartDate, @StartDate);

	SET @WebUserListID = SCOPE_IDENTITY()
END

	DELETE FROM PRWebUserListDetail WHERE prwuld_WebUserListID = @WebUserListID

	INSERT INTO PRWebUserListDetail (prwuld_WebUserListID, prwuld_AssociatedID, prwuld_AssociatedType, prwuld_CreatedBy, prwuld_CreatedDate, prwuld_UpdatedBy, prwuld_UpdatedDate, prwuld_Timestamp)
     SELECT @WebUserListID,  comp_CompanyID, ''C'', -1, @StartDate, -1, @StartDate, @StartDate
       FROM Company
	        INNER JOIN PRService ON comp_CompanyID = prse_CompanyID AND prse_Primary = ''Y''
      WHERE comp_PRIndustryType = ''L''


	UPDATE PRWebUserList
	   SET prwucl_UpdatedDate = @StartDate,
	       prwucl_Description = ''Lumber companies that are BBS members.  Last updated '' + Format(GetDate(), ''MM/dd/yyyy'') + ''.''
	WHERE prwucl_WebUserListID = @WebUserListID
', 
		@database_name=N'CRM', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Update Lumber WD List', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20170913, 
		@active_end_date=99991231, 
		@active_start_time=233000, 
		@active_end_time=235959, 
		@schedule_uid=N'3b7c8987-9ce5-4c5f-9bf7-b4a713de1f5b'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

