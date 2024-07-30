USE [msdb]
GO

/****** Object:  Job [Backup - Daily]    Script Date: 5/23/2022 2:26:11 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [BBSI]    Script Date: 5/23/2022 2:26:11 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'BBSI' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'BBSI'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Backup - Daily', 
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
/****** Object:  Step [Backup Daily Databases]    Script Date: 5/23/2022 2:26:11 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup Daily Databases', 
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
-- CRM
--
SET @DatabaseName = ''CRM''
SET @FileName = @BackupPath + @DatabaseName + ''_Production.bak''
SET @BackupName = @DatabaseName + '' Backup '' + @Timestamp
BACKUP DATABASE @DatabaseName TO  DISK = @FileName WITH NOFORMAT, INIT,  NAME = @BackupName, SKIP, REWIND, NOUNLOAD, COMPRESSION,  STATS = 10

SET @FileName = @BackupPath + @DatabaseName + '' '' + @Timestamp + ''.trn''
SET @BackupName = @DatabaseName + '' Transaction Log Backup '' + @Timestamp
BACKUP LOG @DatabaseName TO  DISK = @FileName WITH NOFORMAT, NOINIT,  NAME = @BackupName, SKIP, REWIND, NOUNLOAD, COMPRESSION,  STATS = 10

--
-- MAS_PRC
--
SET @DatabaseName = ''MAS_PRC''
SET @FileName = @BackupPath + @DatabaseName + ''.bak''
SET @BackupName = @DatabaseName + '' Backup '' + @Timestamp
BACKUP DATABASE @DatabaseName TO  DISK = @FileName WITH NOFORMAT, INIT,  NAME = @BackupName, SKIP, REWIND, NOUNLOAD, COMPRESSION,  STATS = 10

SET @FileName = @BackupPath + @DatabaseName + '' '' + @Timestamp + ''.trn''
SET @BackupName = @DatabaseName + '' Transaction Log Backup '' + @Timestamp
BACKUP LOG @DatabaseName TO  DISK = @FileName WITH NOFORMAT, NOINIT,  NAME = @BackupName, SKIP, REWIND, NOUNLOAD, COMPRESSION,  STATS = 10

--
-- MAS_SYSTEM
--
SET @DatabaseName = ''MAS_SYSTEM''
SET @FileName = @BackupPath + @DatabaseName + ''.bak''
SET @BackupName = @DatabaseName + '' Backup '' + @Timestamp
BACKUP DATABASE @DatabaseName TO  DISK = @FileName WITH NOFORMAT, INIT,  NAME = @BackupName, SKIP, REWIND, NOUNLOAD, COMPRESSION,  STATS = 10

SET @FileName = @BackupPath + @DatabaseName + '' '' + @Timestamp + ''.trn''
SET @BackupName = @DatabaseName + '' Transaction Log Backup '' + @Timestamp
BACKUP LOG @DatabaseName TO  DISK = @FileName WITH NOFORMAT, NOINIT,  NAME = @BackupName, SKIP, REWIND, NOUNLOAD, COMPRESSION,  STATS = 10


--
-- WordPress
--
SET @DatabaseName = ''WordPress''
SET @FileName = @BackupPath + @DatabaseName + ''.bak''
SET @BackupName = @DatabaseName + '' Backup '' + @Timestamp
BACKUP DATABASE @DatabaseName TO  DISK = @FileName WITH NOFORMAT, INIT,  NAME = @BackupName, SKIP, REWIND, NOUNLOAD, COMPRESSION,  STATS = 10

--
-- BugTracker
--
SET @DatabaseName = ''BugTracker''
SET @FileName = @BackupPath + @DatabaseName + ''.bak''
SET @BackupName = @DatabaseName + '' Backup '' + @Timestamp
BACKUP DATABASE @DatabaseName TO  DISK = @FileName WITH NOFORMAT, INIT,  NAME = @BackupName, SKIP, REWIND, NOUNLOAD, COMPRESSION,  STATS = 10




DECLARE @ThresholdDate DATETIME = DATEADD(DAY, -1, GETDATE());
EXECUTE master.dbo.xp_delete_file 0, @BackupPath, N''trn'', @ThresholdDate


USE CRM
GO
DBCC SHRINKFILE (CRM_log, 1000)  -- 1GB
GO

USE MAS_PRC
GO
DBCC SHRINKFILE (MAS_PRC_log, 10)
GO

USE MAS_SYSTEM
GO
DBCC SHRINKFILE (MAS_SYSTEM_log, 1)
GO

USE WORDPRESS
GO
DBCC SHRINKFILE (WORDPRESS_log, 10)
GO

USE Master', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Backup - Daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20150526, 
		@active_end_date=99991231, 
		@active_start_time=30000, 
		@active_end_time=235959, 
		@schedule_uid=N'1d1788f3-90fa-42d9-9a04-26fc2894a5d1'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

