DECLARE @BackupPath varchar(500)
DECLARE @DatabaseName varchar(100)
DECLARE @FileName varchar(100)
DECLARE @Timestamp varchar(50)
DECLARE @BackupName varchar(100)

SET @BackupPath = 'C:\Temp\Hourly\'
SET @Timestamp = REPLACE(REPLACE(CONVERT(varchar(25), GETDATE(), 120), '-', ''), ':', '')
--SELECT @Timestamp

--
-- CRM
--
SET @DatabaseName = 'CRM'
SET @FileName = @BackupPath + @DatabaseName + ' ' + @Timestamp + '.trn'
SET @BackupName = @DatabaseName + ' Transaction Log Backup ' + @Timestamp
BACKUP LOG @DatabaseName TO  DISK = @FileName WITH NOFORMAT, NOINIT,  NAME = @BackupName, SKIP, REWIND, NOUNLOAD, COMPRESSION,  STATS = 10

--
-- MAS_PRC
--
SET @DatabaseName = 'MAS_PRC'
SET @FileName = @BackupPath + @DatabaseName + ' ' + @Timestamp + '.trn'
SET @BackupName = @DatabaseName + ' Transaction Log Backup ' + @Timestamp
BACKUP LOG @DatabaseName TO  DISK = @FileName WITH NOFORMAT, NOINIT,  NAME = @BackupName, SKIP, REWIND, NOUNLOAD, COMPRESSION,  STATS = 10

--
-- MAS_SYSTEM
--
SET @DatabaseName = 'MAS_SYSTEM'
SET @FileName = @BackupPath + @DatabaseName + ' ' + @Timestamp + '.trn'
SET @BackupName = @DatabaseName + ' Transaction Log Backup ' + @Timestamp
BACKUP LOG @DatabaseName TO  DISK = @FileName WITH NOFORMAT, NOINIT,  NAME = @BackupName, SKIP, REWIND, NOUNLOAD, COMPRESSION,  STATS = 10

DECLARE @ThresholdDate DATETIME = DATEADD(DAY, -2, GETDATE());
EXECUTE master.dbo.xp_delete_file 0, @BackupPath, N'trn', Master


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

USE Master