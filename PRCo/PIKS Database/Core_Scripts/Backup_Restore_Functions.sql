/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2007

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Produce Report Company  is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Produce Report Company .
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 

***********************************************************************
***********************************************************************/


--
-- Copies the specified table to the target database.  If the
-- table exists in the target database, it is deleted.
--
IF EXISTS(SELECT 1 FROM sysobjects WHERE id = object_id('[dbo].[usp_BackupTable]'))
	DROP PROCEDURE usp_BackupTable
GO

CREATE PROCEDURE usp_BackupTable
	@BackupDatabasename varchar(100),
	@Tablename varchar(100),
    @UsesIdentity bit = 0
AS
BEGIN
	DECLARE @SQL varchar(5000)
	DECLARE @BackupTableName varchar(200)
	SET @BackupTableName = @BackupDatabasename + '.dbo.BAK_' + @Tablename

	Print 'Backing up ' + @Tablename + ' to ' + @BackupTableName + '.'

	IF (SELECT OBJECT_ID(@BackupTableName)) IS NOT NULL BEGIN
		SET @SQL = 'DROP TABLE ' + @BackupTableName
		EXEC(@SQL)
	END

	SET @SQL = 'SELECT * INTO ' + @BackupTableName + ' FROM ' + @Tablename
	EXEC(@SQL)
END
Go

--
-- Copies the specified table columns to the target database.
-- If the table exists in the target database, it is deleted.
--
IF EXISTS(SELECT 1 FROM sysobjects WHERE id = object_id('[dbo].[usp_BackupTableColumns]'))
	DROP PROCEDURE usp_BackupTableColumns
GO

CREATE PROCEDURE usp_BackupTableColumns
	@BackupDatabasename varchar(100),
	@Tablename varchar(100),
    @Columns varchar(5000)
AS
BEGIN
	DECLARE @SQL varchar(5000)
	DECLARE @BackupTableName varchar(200)
	SET @BackupTableName = @BackupDatabasename + '.dbo.BAK_' + @Tablename

	Print 'Backing up ' + @Tablename + ' columns to ' + @BackupTableName + '.'

	IF (SELECT OBJECT_ID(@BackupTableName)) IS NOT NULL BEGIN
		SET @SQL = 'DROP TABLE ' + @BackupTableName
		EXEC(@SQL)
	END

	SET @SQL = 'SELECT ' + @Columns + ' INTO ' + @BackupTableName + ' FROM ' + @Tablename
	EXEC(@SQL)
END
Go

--
-- Restores the specified table from the backup database.  Only
-- those columns that exist in the table in the backup database
-- are restored.  Existing data in the current database is deleted.
--
IF EXISTS(SELECT 1 FROM sysobjects WHERE id = object_id('[dbo].[usp_RestoreTable]'))
	DROP PROCEDURE usp_RestoreTable
GO

CREATE PROCEDURE usp_RestoreTable
	@BackupDatabasename varchar(100),
	@Tablename varchar(100),
    @UsesIdentity bit = 0
AS
BEGIN
	DECLARE @SQL varchar(5000), @ColumnList varchar(5000)
	DECLARE @BackupTableName varchar(200), @FullBackupTableName varchar(200)
	SET @FullBackupTableName = @BackupDatabasename + '.dbo.BAK_' + @Tablename
	SET @BackupTableName = 'BAK_' + @Tablename

	Print 'Restoring up ' + @BackupTableName + ' to ' + @Tablename + '.'

	CREATE TABLE #ColNames (
		ColName varchar(100) 
	)

	SET @SQL ='INSERT INTO #ColNames SELECT column_name FROM ' + @BackupDatabasename + '.INFORMATION_SCHEMA.Columns WHERE table_name = ''' + @BackupTableName + ''';'
	EXEC (@SQL)


	SELECT @ColumnList = COALESCE(@ColumnList + ', ', '') + ColName 
	  FROM #ColNames;

	DROP TABLE #ColNames

	SET @SQL = 'DELETE FROM ' + @Tablename
	EXEC(@SQL)


	SET @SQL = 'INSERT INTO '  + @Tablename + '(' + @ColumnList + ') SELECT ' + @ColumnList + ' FROM ' + @FullBackupTableName + ';'

	IF @UsesIdentity = 1 BEGIN
		SET @SQL = 'SET IDENTITY_INSERT ' + @Tablename + ' ON; ' + @SQL + 'SET IDENTITY_INSERT ' + @Tablename + ' OFF;'
	END

	EXEC(@SQL)
END
Go


--
-- Restores the specified table columns from the backup database.  Only
-- rows that exist in the backup are updated in the current database.
--
IF EXISTS(SELECT 1 FROM sysobjects WHERE id = object_id('[dbo].[usp_RestoreTableColumns]'))
	DROP PROCEDURE usp_RestoreTableColumns
GO

CREATE PROCEDURE usp_RestoreTableColumns
	@BackupDatabasename varchar(100),
	@Tablename varchar(100),
	@Columns varchar(5000)
AS
BEGIN

	DECLARE @Count int, @Index int
	DECLARE @ColName varchar(100), @KeyColName varchar(100)

	DECLARE @SQL varchar(5000), @ColumnList varchar(5000)
	DECLARE @BackupTableName varchar(200)
	SET @BackupTableName = @BackupDatabasename + '.dbo.BAK_' + @Tablename

	Print 'Restoring up ' + @BackupTableName + ' columns to ' + @Tablename + '.'

	DECLARE @tblColumns table (
		ndx int,
		ColName varchar(100)
	)

	INSERT INTO @tblColumns SELECT * FROM dbo.Tokenize(@Columns, ',');
	SELECT @Count = COUNT(1) FROM @tblColumns;

	SET @SQL = ''
	SET @Index = 1
	WHILE @Index < @Count BEGIN
		SELECT @ColName = ColName
          FROM @tblColumns
         WHERE ndx = @Index;

		IF LEN(@SQL) > 0 BEGIN
			SET @SQL = @SQL + ', '
		END

		SET @SQL = @SQL + 'a.' + @ColName  + ' = b.' + @ColName
		SET @Index = @Index + 1
	END
	
	SELECT @KeyColName = kcu.COLUMN_NAME
      FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS as tc
           INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE as kcu 
			ON kcu.CONSTRAINT_SCHEMA = tc.CONSTRAINT_SCHEMA
		   AND kcu.CONSTRAINT_NAME = tc.CONSTRAINT_NAME
		   AND kcu.TABLE_SCHEMA = tc.TABLE_SCHEMA
		   AND kcu.TABLE_NAME = tc.TABLE_NAME
     WHERE tc.CONSTRAINT_TYPE in ( 'PRIMARY KEY', 'UNIQUE' )
       AND tc.TABLE_NAME = @Tablename;

	SET @SQL = 'UPDATE a SET '  + @SQL + ' FROM ' + @Tablename + ' a INNER JOIN ' + @BackupTableName + ' b ON a.' + @KeyColName + '=b.' + @KeyColName
	EXEC(@SQL)
END
Go


--
-- Backups up the BBOS user tables that should be preserved between builds
-- for system testing.
--
IF EXISTS(SELECT 1 FROM sysobjects WHERE id = object_id('[dbo].[usp_BackupBBOSUserTables]'))
	DROP PROCEDURE usp_BackupBBOSUserTables
GO

CREATE PROCEDURE usp_BackupBBOSUserTables
AS
BEGIN
	EXEC usp_BackupTable 'BBOS_BAK', 'PREBBConversion'
	EXEC usp_BackupTable 'BBOS_BAK', 'PREBBConversionDetail'
	EXEC usp_BackupTable 'BBOS_BAK', 'PRExternalLinkAuditTrail'
	EXEC usp_BackupTable 'BBOS_BAK', 'PRPayment'
	EXEC usp_BackupTable 'BBOS_BAK', 'PRPaymentProduct'
	EXEC usp_BackupTable 'BBOS_BAK', 'PRRequest'
	EXEC usp_BackupTable 'BBOS_BAK', 'PRRequestDetail'
	EXEC usp_BackupTable 'BBOS_BAK', 'PRSearchAuditTrail'
	EXEC usp_BackupTable 'BBOS_BAK', 'PRSearchAuditTrailCriteria'
	EXEC usp_BackupTable 'BBOS_BAK', 'PRSearchWizardAuditTrail'
	EXEC usp_BackupTable 'BBOS_BAK', 'PRSearchWizardAuditTrailDetail'
	EXEC usp_BackupTable 'BBOS_BAK', 'PRSelfServiceAuditTrail'
	EXEC usp_BackupTable 'BBOS_BAK', 'PRSelfServiceAuditTrailDetail'
	EXEC usp_BackupTable 'BBOS_BAK', 'PRWebAuditTrail'
	EXEC usp_BackupTable 'BBOS_BAK', 'PRWebUserContact'
	EXEC usp_BackupTable 'BBOS_BAK', 'PRWebUserCustomData'
	EXEC usp_BackupTable 'BBOS_BAK', 'PRWebUserList'
	EXEC usp_BackupTable 'BBOS_BAK', 'PRWebUserListDetail'
	EXEC usp_BackupTable 'BBOS_BAK', 'PRWebUserNote'
	EXEC usp_BackupTable 'BBOS_BAK', 'PRWebUserSearchCriteria'
	EXEC usp_BackupTable 'BBOS_BAK', 'PRFeedback'
	EXEC usp_BackupTable 'BBOS_BAK', 'PRMembershipPurchase'
	EXEC usp_BackupTable 'BBOS_BAK', 'PRWebServiceAuditTrail'
	EXEC usp_BackupTable 'BBOS_BAK', 'PRWebServiceLicenseKey'
	EXEC usp_BackupTable 'BBOS_BAK', 'PRWebServiceLicenseKeyWM'

	EXEC usp_BackupTable 'BBOS_BAK', 'PRWebUser'
	--EXEC usp_BackupTableColumns 'BBOS_BAK', 'PRWebUser', 'prwu_WebUserID, prwu_LastLoginDateTime,prwu_LoginCount,prwu_FailedAttemptCount,prwu_LastPasswordChange,prwu_LastCompanySearchID,prwu_LastPersonSearchID,prwu_LastCreditSheetSearchID,prwu_CompanyData,prwu_CDSWBBID'
END
Go

--
-- Restores up the BBOS user tables that should be preserved between builds
-- for system testing.
--
IF EXISTS(SELECT 1 FROM sysobjects WHERE id = object_id('[dbo].[usp_RestoreBBOSUserTables]'))
	DROP PROCEDURE usp_RestoreBBOSUserTables
GO

CREATE PROCEDURE usp_RestoreBBOSUserTables
AS
BEGIN
	EXEC usp_RestoreTable 'BBOS_BAK', 'PREBBConversion', 1
	EXEC usp_RestoreTable 'BBOS_BAK', 'PREBBConversionDetail', 1
	EXEC usp_RestoreTable 'BBOS_BAK', 'PRExternalLinkAuditTrail', 1
	EXEC usp_RestoreTable 'BBOS_BAK', 'PRPayment'
	EXEC usp_RestoreTable 'BBOS_BAK', 'PRPaymentProduct', 1
	EXEC usp_RestoreTable 'BBOS_BAK', 'PRRequest', 1
	EXEC usp_RestoreTable 'BBOS_BAK', 'PRRequestDetail', 1
	EXEC usp_RestoreTable 'BBOS_BAK', 'PRSearchAuditTrail', 1
	EXEC usp_RestoreTable 'BBOS_BAK', 'PRSearchAuditTrailCriteria', 1
	EXEC usp_RestoreTable 'BBOS_BAK', 'PRSearchWizardAuditTrail', 1
	EXEC usp_RestoreTable 'BBOS_BAK', 'PRSearchWizardAuditTrailDetail', 1
	EXEC usp_RestoreTable 'BBOS_BAK', 'PRSelfServiceAuditTrail', 1
	EXEC usp_RestoreTable 'BBOS_BAK', 'PRSelfServiceAuditTrailDetail', 1
	EXEC usp_RestoreTable 'BBOS_BAK', 'PRWebAuditTrail', 1
	EXEC usp_RestoreTable 'BBOS_BAK', 'PRWebUserContact', 1
	EXEC usp_RestoreTable 'BBOS_BAK', 'PRWebUserCustomData', 1
	EXEC usp_RestoreTable 'BBOS_BAK', 'PRWebUserList', 1
	EXEC usp_RestoreTable 'BBOS_BAK', 'PRWebUserListDetail', 1
	EXEC usp_RestoreTable 'BBOS_BAK', 'PRWebUserNote', 1
	EXEC usp_RestoreTable 'BBOS_BAK', 'PRWebUserSearchCriteria', 1
	EXEC usp_RestoreTable 'BBOS_BAK', 'PRFeedback', 1
	EXEC usp_RestoreTable 'BBOS_BAK', 'PRMembershipPurchase', 1
	EXEC usp_RestoreTable 'BBOS_BAK', 'PRWebServiceAuditTrail', 1
	EXEC usp_RestoreTable 'BBOS_BAK', 'PRWebServiceLicenseKey', 1
	EXEC usp_RestoreTable 'BBOS_BAK', 'PRWebServiceLicenseKeyWM', 1

	EXEC usp_RestoreTable 'BBOS_BAK', 'PRWebUser'
	--EXEC usp_RestoreTableColumns 'BBOS_BAK', 'PRWebUser', 'prwu_LastLoginDateTime,prwu_LoginCount,prwu_FailedAttemptCount,prwu_LastPasswordChange,prwu_LastCompanySearchID,prwu_LastPersonSearchID,prwu_LastCreditSheetSearchID,prwu_CompanyData,prwu_CDSWBBID'

	EXEC usp_UpdateSQLIdentity 'PRPayment', 'prpay_PaymentID'
END
Go



