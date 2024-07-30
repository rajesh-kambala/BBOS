USE [msdb]
GO

/****** Object:  Job [Update Head Executive Role]    Script Date: 5/24/2022 6:15:21 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [BBSI]    Script Date: 5/24/2022 6:15:21 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'BBSI' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'BBSI'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Update Head Executive Role', 
		@enabled=1, 
		@notify_level_eventlog=3, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'BBSI', 
		@owner_login_name=N'BBSAgentJobs', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Update Head Executive Role]    Script Date: 5/24/2022 6:15:22 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Update Head Executive Role', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @Start datetime = GETDATE()

    ALTER TABLE Person_Link DISABLE TRIGGER ALL
	UPDATE Person_Link
	   SET peli_PRRole = CASE WHEN peli_PRRole IS NULL THEN '',HE,'' ELSE peli_PRRole + ''HE,'' END,
	       PeLi_UpdatedDate = @Start,
		   PeLi_UpdatedBy = 1
	 WHERE PeLi_PersonLinkId IN (
				SELECT PeLi_PersonLinkId
				FROM (
				SELECT comp_CompanyID, comp_Name, PeLi_PersonLinkId, peli_PersonID, peli_PRTitleCode, peli_PRRole, ROW_NUMBER() OVER (PARTITION BY comp_CompanyID ORDER BY capt_order) as RowNumber
					FROM Company WITH (NOLOCK)
						INNER JOIN Person_Link WITH (NOLOCK) ON comp_CompanyID = peli_CompanyID
						INNER JOIN Custom_Captions ON  peli_PRTitleCode = capt_code and capt_family = ''pers_TitleCode''
					WHERE peli_PRStatus = ''1''
					AND comp_PRListingStatus IN (''L'')
					AND comp_PRType = ''H''
					AND comp_PRLocalSource IS NULL
				) T1
				INNER JOIN Person ON T1.peli_PersonID = pers_PersonID
				WHERE RowNumber = 1
				 AND comp_CompanyID NOT IN (SELECT comp_CompanyID
											  FROM Company WITH (NOLOCK)
												   INNER JOIN Person_Link WITH (NOLOCK) ON comp_CompanyID = peli_CompanyID
											 WHERE peli_PRStatus = ''1''
											   AND comp_PRListingStatus IN (''L'')
											   AND comp_PRType = ''H''
											   AND comp_PRLocalSource IS NULL
											   AND peli_PRRole LIKE ''%,HE,%''))
	ALTER TABLE Person_Link ENABLE TRIGGER ALL

', 
		@database_name=N'CRM', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Monthly', 
		@enabled=1, 
		@freq_type=16, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20171105, 
		@active_end_date=99991231, 
		@active_start_time=1500, 
		@active_end_time=235959, 
		@schedule_uid=N'5a84a4ce-c9e7-4261-a6c6-11f419be4445'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

