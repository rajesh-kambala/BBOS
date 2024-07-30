/***********************************************************************
***********************************************************************
 Copyright Travant Solutions, Inc. 2006

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Travant Solutions is 
 strictly prohibited.

 Confidential, Unpublished Property of Travant Solutions, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com.  

 Notes:	Adapted from code from on Michael Schwarz's web log on how
        to move databases. 
        http://weblogs.asp.net/mschwarz/archive/2004/08/26/220735.aspx

***********************************************************************
***********************************************************************/
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
	 IsPresent bit
    )
    INSERT #restoretemp EXEC (@query)

    SELECT @File = COUNT(1) from #restoretemp 
    SELECT @Data = LogicalName FROM #restoretemp WHERE type = 'D'
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