USE [msdb]
GO

/****** Object:  Job [Backup - Weekly]    Script Date: 5/24/2022 6:09:46 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [BBSI]    Script Date: 5/24/2022 6:09:46 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'BBSI' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'BBSI'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Backup - Weekly', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'BBSI', 
		@owner_login_name=N'BBSAgentJobs', 
		@notify_email_operator_name=N'SQL Support Notifications', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup - Weekly]    Script Date: 5/24/2022 6:09:47 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup - Weekly', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @BackupPath varchar(500)
DECLARE @DatabaseName varchar(100)
DECLARE @FileName varchar(100)
DECLARE @Timestamp varchar(50)
DECLARE @BackupName varchar(100)

SET @BackupPath = ''D:\Applications\SQLServer_Data\Backups\Nightly\''
SET @Timestamp = REPLACE(REPLACE(CONVERT(varchar(25), GETDATE(), 120), ''-'', ''''), '':'', '''')
--SELECT @Timestamp


--
-- InternationalLeads
--
SET @DatabaseName = ''InternationalLeads''
SET @FileName = @BackupPath + @DatabaseName + ''_Weekly.bak''
SET @BackupName = @DatabaseName + '' Backup '' + @Timestamp
BACKUP DATABASE @DatabaseName TO  DISK = @FileName WITH NOFORMAT, INIT,  NAME = @BackupName, SKIP, REWIND, NOUNLOAD, COMPRESSION,  STATS = 10

--
-- LocalSourcingLeads
--
SET @DatabaseName = ''LocalSourcingLeads''
SET @FileName = @BackupPath + @DatabaseName + ''_Weekly.bak''
SET @BackupName = @DatabaseName + '' Backup '' + @Timestamp
BACKUP DATABASE @DatabaseName TO  DISK = @FileName WITH NOFORMAT, INIT,  NAME = @BackupName, SKIP, REWIND, NOUNLOAD, COMPRESSION,  STATS = 10

--
-- LumberLeads
--
SET @DatabaseName = ''LumberLeads''
SET @FileName = @BackupPath + @DatabaseName + ''_Weekly.bak''
SET @BackupName = @DatabaseName + '' Backup '' + @Timestamp
BACKUP DATABASE @DatabaseName TO  DISK = @FileName WITH NOFORMAT, INIT,  NAME = @BackupName, SKIP, REWIND, NOUNLOAD, COMPRESSION,  STATS = 10

--
-- Reporting
--
SET @DatabaseName = ''Reporting''
SET @FileName = @BackupPath + @DatabaseName + ''_Weekly.bak''
SET @BackupName = @DatabaseName + '' Backup '' + @Timestamp
BACKUP DATABASE @DatabaseName TO  DISK = @FileName WITH NOFORMAT, INIT,  NAME = @BackupName, SKIP, REWIND, NOUNLOAD, COMPRESSION,  STATS = 10

--
-- ReportServer
--
SET @DatabaseName = ''ReportServer''
SET @FileName = @BackupPath + @DatabaseName + ''_Weekly.bak''
SET @BackupName = @DatabaseName + '' Backup '' + @Timestamp
BACKUP DATABASE @DatabaseName TO  DISK = @FileName WITH NOFORMAT, INIT,  NAME = @BackupName, SKIP, REWIND, NOUNLOAD, COMPRESSION,  STATS = 10

DECLARE @ThresholdDate DATETIME = DATEADD(DAY, -1, GETDATE());
EXECUTE master.dbo.xp_delete_file 0, @BackupPath, N''trn'', @ThresholdDate


USE InternationalLeads
GO
DBCC SHRINKFILE (InternationalLeads_log, 10)
GO

USE LocalSourcingLeads
GO
DBCC SHRINKFILE (LocalSourcingLeads_log, 10)
GO

USE LumberLeads
GO
DBCC SHRINKFILE (LumberLeads_log, 10)
GO

USE Master', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Weekly', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=64, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20180125, 
		@active_end_date=99991231, 
		@active_start_time=33000, 
		@active_end_time=235959, 
		@schedule_uid=N'227fe910-5008-4118-b4b9-9427be16762d'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

