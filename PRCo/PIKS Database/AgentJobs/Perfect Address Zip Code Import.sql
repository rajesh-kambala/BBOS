USE [msdb]
GO

/****** Object:  Job [Perfect Address Zip Code Import]    Script Date: 5/24/2022 6:11:10 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [BBSI]    Script Date: 5/24/2022 6:11:11 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'BBSI' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'BBSI'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Perfect Address Zip Code Import', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Imports Perfect Address data into the CRM database.', 
		@category_name=N'BBSI', 
		@owner_login_name=N'BBSAgentJobs', 
		@notify_email_operator_name=N'SQL Support Notifications', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Perfect Address Zip Code Import]    Script Date: 5/24/2022 6:11:11 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Perfect Address Zip Code Import', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/DTS "\"\MSDB\Perfect Address Zip Code Import\"" /SERVER "\"AZ-NC-SQL-P2\"" /CHECKPOINTING OFF /REPORTING E', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Update Time Zones]    Script Date: 5/24/2022 6:11:11 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Update Time Zones', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
DECLARE @PerfectAddress table (
	CityID int,
    TimeZone varchar(10),
    DST varchar(1),
    TimeZoneOffset int
)

INSERT INTO @PerfectAddress
SELECT prci_CityID, REPLACE(TimeZone, ''"'','''') TimeZone, REPLACE(DST, ''"'','''') DST,
  CASE REPLACE(TimeZone, ''"'','''') 
      WHEN ''EST'' THEN -5
      WHEN ''CST'' THEN -6
      WHEN ''MST'' THEN -7
      WHEN ''PST'' THEN -8
      WHEN ''PST-1'' THEN -9
      WHEN ''PST-2'' THEN -10
      WHEN ''PST-3'' THEN -11
      WHEN ''PST-4'' THEN -12
	END as TimezoneOffset
  FROM vPRLocation
       INNER JOIN (
			SELECT DISTINCT REPLACE(City, ''"'','''') As City, REPLACE(State, ''"'','''')  As State, TimeZone, DST
			FROM OPENROWSET(BULK ''D:\Perfect Address Data Files\Zip Code Data\z5ll.txt'', 
							FORMATFILE=''D:\Perfect Address Data Files\Zip Code Data\z5ll.fmt'', 
							FIRSTROW=3) A) As Z5LL ON prci_City = REPLACE(City, ''"'','''') AND prst_Abbreviation = REPLACE(State, ''"'','''')
ORDER BY prst_State, prci_City;

UPDATE PRCity
   SET prci_Timezone = TimeZone,
       prci_DST = DST,
       prci_TimeZoneOffset = TimeZoneOffset
  FROM @PerfectAddress
 WHERE prci_CityID = CityID;
', 
		@database_name=N'CRM', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'End of Month Recurring.', 
		@enabled=1, 
		@freq_type=16, 
		@freq_interval=25, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20091020, 
		@active_end_date=99991231, 
		@active_start_time=20000, 
		@active_end_time=235959, 
		@schedule_uid=N'32578398-3e78-4ff3-862c-8ccf97b172fe'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Run Once on Demand', 
		@enabled=0, 
		@freq_type=1, 
		@freq_interval=0, 
		@freq_subday_type=0, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180728, 
		@active_end_date=99991231, 
		@active_start_time=20000, 
		@active_end_time=235959, 
		@schedule_uid=N'50e4be7f-3a9a-4dcd-a907-bf36da7ff05c'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

