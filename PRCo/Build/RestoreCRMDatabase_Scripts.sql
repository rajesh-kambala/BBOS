-- Installs all CRM restore functions to Master

/***********************************************************************
***********************************************************************
 Copyright Travant Solutions, Inc. 2006-2016

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Travant Solutions is 
 strictly prohibited.

 Confidential, Unpublished Property of Travant Solutions, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com.  

 Notes:	Adapted from code by mak mak_999@yahoo.com
        http://www.databasejournal.com/features/mssql/article.php/2174031

***********************************************************************
***********************************************************************/

USE [master]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_ResetCRMDatabaseToBaseline]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[usp_ResetCRMDatabaseToBaseline]
GO

CREATE PROCEDURE [dbo].[usp_ResetCRMDatabaseToBaseline]
	@SourceDataFile varchar(1000),
    @TargetDataFile varchar(1000),  -- No extention
    @TargetDBName varchar(100)

AS
BEGIN
	DECLARE @query varchar(2000)
	DECLARE @DataFile varchar(2000)
	DECLARE @LogFile varchar(2000)
	DECLARE @DOSCommand varchar(150)
    DECLARE @Data varchar(500)
    DECLARE @Log varchar(500)
	DECLARE @FullTextIndex varchar(500)
	DECLARE @FullTextIndexFile varchar(2000)

    DECLARE @File int

    -- Delete the target if it already exists
    IF EXISTS(SELECT * FROM sysdatabases WHERE name = @TargetDBName)
    BEGIN
        SET @query = 'DROP DATABASE ' + @TargetDBName
        EXEC (@query)
    END

    -- Restore the structure
    RESTORE HEADERONLY FROM DISK = @SourceDataFile

    SET @query = 'RESTORE FILELISTONLY FROM DISK = ' + QUOTENAME(@SourceDataFile , '''')

    DECLARE @Restore table (
		 LogicalName nvarchar(128),
		 PhysicalName nvarchar(260),
		 type char(1),
		 FilegroupName nvarchar(128),
		 size numeric(20,0),
		 maxsize numeric(20,0),
		 FileID bigint,
		 CreateLSN numeric(25,0),
		 DropLSN numeric(25,0),
		 UniqueID uniqueidentifier,     
		 ReadOnlyLSN numeric(25,0),
		 ReadWriteLSN numeric(25,0),
		 BackupSizeInBytes bigint,
		 SourceBlockSize int,
		 FileGroupID int,
		 LogGroupGUID uniqueidentifier,
		 DifferentialBaseLSN numeric(25,0),
		 DifferentialBaseGUID uniqueidentifier,
		 IsReadOnly bit,
		 IsPresent bit,
		 TDEThumprint varbinary(32),
		 SnapshotUrl nvarchar(360)
    )
    INSERT @Restore EXEC (@query)

    SELECT @File = COUNT(1) from @Restore 
    SELECT @Data = LogicalName FROM @Restore WHERE type = 'D' AND FilegroupName='PRIMARY'
    SELECT @Log = LogicalName FROM @Restore WHERE type = 'L'
	SELECT @FullTextIndex = LogicalName FROM @Restore WHERE type = 'D' AND FilegroupName LIKE '%LearningCenter%'

    SET @DataFile = @TargetDataFile + '.mdf'
    SET @LogFile = @TargetDataFile + '.ldf'
	SET @FullTextIndexFile = @TargetDataFile + '.ndf'

    -- Restore the data from the backup file to the new MDF and LDF files.
    IF @File > 0
    BEGIN
        SET @query = 'RESTORE DATABASE ' + @TargetDBName + ' FROM DISK = ' + QUOTENAME(@SourceDataFile, '''') + 
            ' WITH MOVE ' + QUOTENAME(@Data, '''') + ' TO ' + QUOTENAME(@DataFile, '''') + 
			', MOVE ' + QUOTENAME(@Log, '''') + ' TO ' + QUOTENAME(@LogFile, '''') 

		IF (@FullTextIndex IS NOT NULL) BEGIN
			SET @query = @query + ', MOVE ' + QUOTENAME(@FullTextIndex, '''') + ' TO ' + QUOTENAME(@FullTextIndexFile, '''') 
		END

        EXEC (@query)
    END

    
    -- Now alter our db to reset the logical file 
    -- names so they are different from the source
    DECLARE @NewName varchar(50)
    SET @NewName = @TargetDBName + '_Data'
	IF (@Data <> @NewName)
	BEGIN
		SET @query = 'ALTER DATABASE ' + @TargetDBName + ' MODIFY FILE (NAME = ' + @Data + ' , NEWNAME = ' + QUOTENAME(@NewName, '''') + ')'
		EXEC (@query)
	END

    SET @NewName = @TargetDBName + '_Log'
	IF (@LOG <> @NewName)
	BEGIN
		SET @query = 'ALTER DATABASE ' + @TargetDBName + ' MODIFY FILE (NAME = ' + @Log + ' , NEWNAME = ' + QUOTENAME(@NewName, '''') + ')'
		EXEC (@query)
	END
END
GO





If Exists (Select name from sysobjects where name = 'usp_KillDBProcesses' and type='P') Drop Procedure dbo.usp_KillDBProcesses
Go

CREATE PROCEDURE usp_KillDBProcesses
    @dbname varchar(128) 
AS
BEGIN
	SET nocount on
	SET quoted_identifier off

	DECLARE @kill_id int
	DECLARE @query varchar(320)

	DECLARE killprocess_cursor CURSOR FOR 
	SELECT a.spid 
	  FROM sysprocesses a JOIN
		   sysdatabases b ON a.dbid=b.dbid 
	 WHERE b.name=@dbname

	OPEN killprocess_cursor
	FETCH NEXT FROM killprocess_cursor INTO @kill_id
	WHILE (@@fetch_status =0) BEGIN
		SET @query = 'kill ' + convert(varchar,@kill_id)
		EXEC (@query)

		FETCH NEXT FROM killprocess_cursor INTO @kill_id
	END

	CLOSE killprocess_cursor
	DEALLOCATE killprocess_cursor
END
Go

If Exists (Select name from sysobjects where name = 'usp_CopyDatabase' and type='P') Drop Procedure dbo.usp_CopyDatabase
Go

/**
 Copies a database to a new database on the same server by backing up the files
 and restoring them to a new database.  All apsects are copied including stored
 procedures, user-defined functions, tables, and views.
**/
CREATE PROCEDURE dbo.usp_CopyDatabase
    @SourceDBName varchar(200),
    @TargetDBName varchar(200),
    @BackupFileName varchar(2000),
    @RestoreFileName varchar(2000),
    @Perform_Backup bit = 1,
    @Perform_Restore bit = 1,
    @Perform_DeleteBackupFile bit = 1
as 
BEGIN	
	DECLARE @query varchar(2000)
	DECLARE @DataFile varchar(2000)
	DECLARE @LogFile varchar(2000)
	DECLARE @DOSCommand varchar(150)


	-- Create our backup file of the source DB.  This is will restored
	-- to the target databse.
	IF (@Perform_Backup = 1)
	BEGIN
		IF EXISTS(SELECT * FROM sysdatabases WHERE name = @SourceDBName)
		BEGIN
			SET @query = 'BACKUP DATABASE ' + @SourceDBName + ' TO DISK = ' + QUOTENAME(@BackupFileName, '''')
			EXEC (@query)
		END
	END

	IF (@Perform_Restore = 1)
	BEGIN
		-- Delete the target if it already exists
		IF EXISTS(SELECT * FROM sysdatabases WHERE name = @TargetDBName)
		BEGIN
			SET @query = 'DROP DATABASE ' + @TargetDBName
			EXEC (@query)
		END

		-- Restore the structure
		RESTORE HEADERONLY FROM DISK = @BackupFileName
		DECLARE @File int
	--    SET @File = @@ROWCOUNT

		DECLARE @Data varchar(500)
		DECLARE @Log varchar(500)

		SET @query = 'RESTORE FILELISTONLY FROM DISK = ' + QUOTENAME(@BackupFileName , '''')

		CREATE TABLE #restoretemp (
		 LogicalName nvarchar(128),
		 PhysicalName nvarchar(260),
		 type char(1),
		 FilegroupName nvarchar(128),
		 size numeric(20,0),
		 maxsize numeric(20,0),
		 FileID bigint,
		 CreateLSN numeric(25,0),
		 DropLSN numeric(25,0),
		 UniqueID uniqueidentifier,     
		 ReadOnlyLSN numeric(25,0),
		 ReadWriteLSN numeric(25,0),
		 BackupSizeInBytes bigint,
		 SourceBlockSize int,
		 FileGroupID int,
		 LogGroupGUID uniqueidentifier,
		 DifferentialBaseLSN numeric(25,0),
		 DifferentialBaseGUID uniqueidentifier,
		 IsReadOnly bit,
		 IsPresent bit,
		 TDEThumprint varbinary(32)
		)
		INSERT #restoretemp EXEC (@query)

		SELECT @File = COUNT(1) from #restoretemp 
		SELECT @Data = LogicalName FROM #restoretemp WHERE type = 'D' AND FilegroupName='PRIMARY'
		SELECT @Log = LogicalName FROM #restoretemp WHERE type = 'L'

		TRUNCATE TABLE #restoretemp
		DROP TABLE #restoretemp

		SET @DataFile = @RestoreFileName + '.mdf'
		SET @LogFile = @RestoreFileName + '.ldf'

		-- Restore the data from the backup file to the new MDF and LDF files.
		IF @File > 0
		BEGIN
			SET @query = 'RESTORE DATABASE ' + @TargetDBName + ' FROM DISK = ' + QUOTENAME(@BackupFileName, '''') + 
				' WITH MOVE ' + QUOTENAME(@Data, '''') + ' TO ' + QUOTENAME(@DataFile, '''') + ', MOVE ' +
				QUOTENAME(@Log, '''') + ' TO ' + QUOTENAME(@LogFile, '''') 
	--+ ', FILE = ' + CONVERT(varchar, @File)
			EXEC (@query)
		END

	    
		-- Now alter our db to reset the logical file 
		-- names so they are different from the source
		DECLARE @NewName varchar(50)
		SET @NewName = @TargetDBName + '_Data'
		IF (@Data <> @NewName)
		BEGIN
			SET @query = 'ALTER DATABASE ' + @TargetDBName + ' MODIFY FILE (NAME = ' + @Data + ' , NEWNAME = ' + QUOTENAME(@NewName, '''') + ')'
			EXEC (@query)
		END

		SET @NewName = @TargetDBName + '_Log'
		IF (@LOG <> @NewName)
		BEGIN
			SET @query = 'ALTER DATABASE ' + @TargetDBName + ' MODIFY FILE (NAME = ' + @Log + ' , NEWNAME = ' + QUOTENAME(@NewName, '''') + ')'
			EXEC (@query)
		END
	END

	IF (@Perform_DeleteBackupFile = 1)
	BEGIN
		-- Delete our intermediate backup file
		SET @DOSCommand = 'del ' + '"' + @BackupFileName + '"'
		EXEC xp_cmdshell @DOSCommand
	END
END
GO

/*
*   THIS FUNCTION IS OBSOLETE
*
*/
If Exists (Select name from sysobjects where name = 'usp_ResetCRMDatabase' and type='P') Drop Procedure dbo.usp_ResetCRMDatabase
Go

/**
 Copies the current CRM database to a new database named CRM + current timestamp.
 The copies the CRM_Empty database to the CRM database effectively overwriting the
 current CRM database.
**/
/*
*   THIS FUNCTION IS OBSOLETE
*/

--CREATE PROCEDURE dbo.usp_ResetCRMDatabase as
--BEGIN
--	DECLARE @RootDataPath varchar(1000)
--	DECLARE @TargetDB varchar(200)
--	DECLARE @TargetDBFile varchar(200)
--	DECLARE @BackupFile varchar(200)
--
--	DECLARE @Year varchar(4), @Month varchar(2), @Day varchar(2), @Hour varchar(2), @Minute varchar(2)
--	DECLARE @Timestamp varchar(12)
--
--	-- The data path on the server.  Both the data files and intermediate 
--	-- backup file will be created here.
--	SET @RootDataPath = 'D:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Data\'
--
--	SET @Year =  Cast(DatePart(yyyy, GetDate()) as varchar(4))
--	SET @Month =  Cast(DatePart(mm, GetDate()) as varchar(2))
--	SET @Day =  Cast(DatePart(dd, GetDate()) as varchar(2))
--	SET @Hour =  Cast(DatePart(hh, GetDate()) as varchar(2))
--	SET @Minute =  Cast(DatePart(mi, GetDate()) as varchar(2))
--
--	IF (LEN(@Month) = 1) BEGIN SET @Month = '0' + @Month END
--	IF (LEN(@Day) = 1) BEGIN SET @Day = '0' + @Day END
--	IF (LEN(@Hour) = 1) BEGIN SET @Hour = '0' + @Hour END
--	IF (LEN(@Minute) = 1) BEGIN  SET @Minute = '0' + @Minute END
--
--	SET @Timestamp = @Year  + @Month + @Day + @Hour + @Minute
--
--	-- Backup the current CRM database, but don't restore it anywhere
--	-- Just save the backup DAT file to disk.
--	SET @TargetDB = 'CRM' + @Timestamp
--	SET @TargetDBFile = @RootDataPath + 'CRM_BAK' + @Timestamp
--	SET @BackupFile = @RootDataPath + 'CRM_BAK ' + @Timestamp + '.dat'
--	EXEC usp_CopyDatabase 'CRM', @TargetDB, @BackupFile, @TargetDBFile, 1, 0, 0
--
--	-- Recreate the CRM database from a fresh ACCPAC source
--	SET @TargetDB = 'CRM'
--	SET @TargetDBFile = @RootDataPath + 'CRM'
--	SET @BackupFile = @RootDataPath + 'CRMDatabaseCopy.dat'
--	EXEC usp_CopyDatabase 'CRM_Empty', @TargetDB, @BackupFile, @TargetDBFile, 1, 1, 1
--END

