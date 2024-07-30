/* CRMRestore_PostExecute.sql
	Fixes the user accounts and trustworthy status of a restored CRM database.	
*/
BEGIN
	-- Upon restoring a CRM database certain user records and values must be reestablished
	-- This file takes care of all CRM related issues when the CRM DB is restored

	-- we need to drop and readd the accpac user
	If EXISTS (SELECT Name FROM sysusers WHERE Name = 'accpac') Begin 
		Print 'Dropping user: accpac'
		DROP USER accpac
	End
	-- Now recreate
	CREATE USER accpac FOR LOGIN accpac;
	EXEC sp_addrolemember 'db_owner', 'accpac'
	Print 'Created user: accpac'

	Print ''
	-- we need to drop and readd DBFileAccess
	If EXISTS (SELECT Name FROM sysusers WHERE Name = 'DBFileAccess') Begin 
		Print 'Dropping user: DBFileAccess'
		DROP USER DBFileAccess
	End
	CREATE USER DBFileAccess FOR LOGIN [NT Authority\System];
	Print 'Created user: DBFileAccess'

	/**
		Create the Login and User for the WebInterface ID,
		Then grant specific access.  This ID is used by the external
		web site to interact w/PIKS.
	**/
	Print ''
	-- we need to drop and readd DBFileAccess, but first ensure we have a login
	DECLARE @nUserId int
	SELECT @nUserId = SUSER_ID ('WebInterface') 
	if (@nUserId is null) BEGIN
		CREATE LOGIN WebInterface WITH PASSWORD = 'WebInterface_1901'
		PRINT 'Created Principal: WebInterface'
	END
	
	If Exists (SELECT Name FROM sysusers WHERE Name = 'WebInterface') Begin 
		Print 'Dropping user: WebInterface '
		DROP USER WebInterface 
	End 
	CREATE USER WebInterface FOR LOGIN WebInterface;
	Print 'Created user: WebInterface'

	Print ''
	-- mark the new CRM as trustworthy for DBMail
	ALTER DATABASE CRM SET TRUSTWORTHY ON
	PRINT 'CRM Database has TRUSTWORTHY set to ON'
END	
GO
	