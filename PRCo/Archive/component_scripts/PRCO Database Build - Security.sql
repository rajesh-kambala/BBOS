SET NOCOUNT ON
GO

/**
	Create the Login and Users for accpac in both the 
    CRM and BBSInterface databases. 
**/

-- Create a Login
If NOT EXISTS (SELECT SUSER_ID ('accpac')) BEGIN
	CREATE LOGIN accpac WITH PASSWORD = '2006PIKS1204';
END
Go

-- Create a User with the owner role in the CRM database
If NOT EXISTS (SELECT Name FROM sysusers WHERE Name = 'accpac') BEGIN
	CREATE USER accpac FOR LOGIN accpac;
	EXEC sp_addrolemember 'db_owner', 'accpac'

	USE MSDB
	EXEC sp_grantdbaccess 'accpac'
	GRANT Authenticate TO accpac

END
Go

If NOT EXISTS (SELECT Name FROM sysusers WHERE Name = 'DBFileAccess') BEGIN
	CREATE USER DBFileAccess FOR LOGIN [NT Authority\System];

	USE CRM
	ALTER DATABASE CRM SET TRUSTWORTHY ON

	EXEC msdb.dbo.sp_addrolemember @rolename = 'DatabaseMailUserRole', 
	   @membername = 'NT Authority\System' 

END
GO


/**
	Create the Login and User for the WebInterface ID,
	Then grant specific access.  This ID is used by the external
	web site to interact w/PIKS.
**/
If NOT Exists (SELECT SUSER_ID ('WebInterface')) BEGIN
	CREATE LOGIN WebInterface WITH PASSWORD = 'WebInterface_1901';
END
Go

If NOT Exists (SELECT Name FROM sysusers WHERE Name = 'WebInterface') BEGIN
	CREATE USER WebInterface FOR LOGIN WebInterface;
END
GO

--Set Object Specific Permissions
GRANT
	SELECT,UPDATE
	ON [dbo].[SQL_Identity]
	TO WebInterface
GRANT
	EXECUTE
	ON [dbo].[ufn_GetUsageTypePrice]
	TO WebInterface
GRANT
	EXECUTE
	ON [dbo].[ufn_HasAvailableUnits]
	TO WebInterface
GRANT
	EXECUTE
	ON [dbo].[ufn_IsEligibleForBRSurvey]
	TO WebInterface
GRANT
	EXECUTE
	ON [dbo].[usp_ConsumeServiceUnits]
	TO WebInterface
GRANT
	EXECUTE
	ON [dbo].[usp_AllocateServiceUnits]
	TO WebInterface
GRANT
	EXECUTE
	ON [dbo].[usp_AUSEntryAdd]
	TO WebInterface
GRANT
	EXECUTE
	ON [dbo].[usp_AUSEntryDelete]
	TO WebInterface
GRANT
	EXECUTE
	ON [dbo].[usp_AUSEntryShowOnHomePage]
	TO WebInterface
GRANT
	EXECUTE
	ON [dbo].[usp_AUSSettingsUpdate]
	TO WebInterface
GRANT
	SELECT
	ON [dbo].[vPRServiceUnitAllocHistory]
	TO WebInterface
GRANT
	SELECT
	ON [dbo].[vPRServiceUnitUsageHistory]
	TO WebInterface
GRANT
	SELECT
	ON [dbo].[vPRServiceUnitUsage]
	TO WebInterface
GRANT
	EXECUTE
	ON [dbo].[ufn_GetSystemUserId]
	TO WebInterface
GRANT
	EXECUTE
	ON [dbo].[ufn_GetAvailableUnits]
	TO WebInterface
GRANT
	SELECT	
	ON [dbo].[ufn_GetAUSListing]
	TO WebInterface
GRANT
	EXECUTE
	ON [dbo].[ufn_GetPersonDefaultEmail]
	TO WebInterface
GRANT
	EXECUTE
	ON [dbo].[ufn_GetPersonDefaultFax]
	TO WebInterface
GRANT
	SELECT
	ON [dbo].[ufn_GetAUSSettings]
	TO WebInterface
GRANT
	EXECUTE
	ON [dbo].[usp_AddOnlineTradeReport]
	TO WebInterface
GRANT
	EXECUTE
	ON [dbo].[ufn_GetPRCoSpecialistUserId]
	TO WebInterface
GO


-- Create a User with the owner role in the BBSInterface database
IF EXISTS(SELECT name FROM sys.databases WHERE name = 'BBSInterface') BEGIN

	-- NOTE: This same code is in the BBSInterfaceCreate.sql
	-- file.  If this is changed, most likely this other script will need
	-- to be changed.
	USE [BBSInterface]
	If NOT EXISTS (SELECT Name FROM sysusers WHERE Name = 'accpac') BEGIN
		CREATE USER accpac FOR LOGIN accpac;
		EXEC sp_addrolemember 'db_owner', 'accpac'
	END
END
GO

