SET NOCOUNT ON
GO

ALTER DATABASE CRM SET TRUSTWORTHY ON;
GO

USE CRM
GO
--ALTER AUTHORIZATION ON DATABASE::CRM TO sa
--Go
sp_configure 'clr enabled', 1 
GO
RECONFIGURE 
GO




/**
	Create the Login and Users for accpac in both the 
    CRM and BBSInterface databases. 
**/

-- Create a Login
If NOT Exists (SELECT name FROM master.sys.server_principals WHERE name = 'accpac') BEGIN
	CREATE LOGIN accpac WITH PASSWORD = '2006PIKS1204';
END
Go

If NOT Exists (SELECT name FROM master.sys.server_principals WHERE name = 'AZ-NC-SQL-Q1\DBMailUser') BEGIN
	CREATE LOGIN [AZ-NC-SQL-Q1\DBMailUser] FROM WINDOWS WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english]
END
Go



Use CRM
If NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'accpac') BEGIN
	CREATE USER accpac FOR LOGIN accpac;
	EXEC sp_addrolemember 'db_owner', 'accpac'
END ELSE BEGIN
	ALTER USER accpac WITH LOGIN=accpac 
END
Go

If NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'WPUser') BEGIN
	CREATE USER WPUser FOR LOGIN WPUser;
	EXEC sp_addrolemember 'db_datareader', 'WPUser'
END ELSE BEGIN
	ALTER USER WPUser WITH LOGIN=WPUser 
END
Go

If NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'AZ-NC-SQL-Q1\DBMailUser') BEGIN
	CREATE USER [AZ-NC-SQL-Q1\DBMailUser] FOR LOGIN [AZ-NC-SQL-Q1\DBMailUser] WITH DEFAULT_SCHEMA=[dbo]
END ELSE BEGIN
	ALTER USER [AZ-NC-SQL-Q1\DBMailUser] WITH LOGIN=[AZ-NC-SQL-Q1\DBMailUser]  
END
Go


Use MSDB
If NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'accpac') BEGIN
	CREATE USER accpac FOR LOGIN accpac;
	GRANT Authenticate TO accpac
END ELSE BEGIN
	ALTER USER accpac WITH LOGIN=accpac 
END
Go

Use MSDB
If NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'BBOS') BEGIN
	CREATE USER BBOS FOR LOGIN BBOS;
	GRANT Authenticate TO BBOS
END ELSE BEGIN
	ALTER USER BBOS WITH LOGIN=BBOS 
END
Go


USE CRMArchive
If NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'accpac') BEGIN
	CREATE USER accpac FOR LOGIN accpac;
	EXEC sp_addrolemember 'db_owner', 'accpac'
END ELSE BEGIN
	ALTER USER accpac WITH LOGIN=accpac 
END
GO


USE MAS_PRC
If NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'accpac') BEGIN
	CREATE USER accpac FOR LOGIN accpac;
	EXEC sp_addrolemember 'db_datareader', 'accpac'
END ELSE BEGIN
	ALTER USER accpac WITH LOGIN=accpac 
END

If NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'BBOS') BEGIN
	CREATE USER BBOS FOR LOGIN BBOS;
	EXEC sp_addrolemember 'db_datareader', 'BBOS'
END ELSE BEGIN
	ALTER USER BBOS WITH LOGIN=BBOS 
END

If NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'MAS_User') BEGIN
	CREATE USER MAS_User FOR LOGIN MAS_User;
	EXEC sp_addrolemember 'db_owner', 'MAS_User'
END ELSE BEGIN
	ALTER USER MAS_User WITH LOGIN=MAS_User 
END

If NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'MAS_Reports') BEGIN
	CREATE USER MAS_Reports FOR LOGIN MAS_Reports;
	EXEC sp_addrolemember 'db_datareader', 'MAS_Reports'
END ELSE BEGIN
	ALTER USER MAS_Reports WITH LOGIN=MAS_Reports 
END

USE MAS_SYSTEM
If NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'accpac') BEGIN
	CREATE USER accpac FOR LOGIN accpac;
	EXEC sp_addrolemember 'db_owner', 'accpac'
END ELSE BEGIN
	ALTER USER accpac WITH LOGIN=accpac 
END 
 
If NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'BBOS') BEGIN
	CREATE USER BBOS FOR LOGIN BBOS;
	EXEC sp_addrolemember 'db_datareader', 'BBOS'
END ELSE BEGIN
	ALTER USER BBOS WITH LOGIN=BBOS 
END 
 
If NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'MAS_User') BEGIN
	CREATE USER MAS_User FOR LOGIN MAS_User;
	EXEC sp_addrolemember 'db_owner', 'MAS_User'
END ELSE BEGIN
	ALTER USER MAS_User WITH LOGIN=MAS_User 
END

If NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'MAS_Reports') BEGIN
	CREATE USER MAS_Reports FOR LOGIN MAS_Reports;
	EXEC sp_addrolemember 'db_datareader', 'MAS_Reports'
END ELSE BEGIN
	ALTER USER MAS_Reports WITH LOGIN=MAS_Reports 
END

-- grant the accpac user access to administer CLR Assemblies
Use Master
If NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'accpac') BEGIN
	CREATE USER accpac FOR LOGIN accpac;
END ELSE BEGIN
	ALTER USER accpac WITH LOGIN=accpac 
END
Go

GRANT EXTERNAL ACCESS ASSEMBLY TO accpac
GRANT CREATE ASSEMBLY TO accpac
GRANT UNSAFE ASSEMBLY to accpac
EXEC sp_addsrvrolemember 'accpac', 'bulkadmin' 
--GRANT UNSAFE ASSEMBLY to BBSBuild
Go



USE CRM
If NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'MAS_User') BEGIN
	CREATE USER MAS_User FOR LOGIN MAS_User;
	EXEC sp_addrolemember 'db_owner', 'MAS_User'
END ELSE BEGIN
	ALTER USER MAS_User WITH LOGIN=MAS_User 
END
Go


/**
	Create the Login and User for the Blue Book Online Services,
	Then grant specific access.  This ID is used by the external
	web site to interact w/CRM.
**/
If NOT Exists (SELECT name   
                 FROM master.sys.server_principals 
                WHERE name = 'BBOS') BEGIN
	CREATE LOGIN BBOS WITH PASSWORD = 'BBOS_1995';
END
Go

If NOT Exists (SELECT Name FROM sysusers WHERE Name = 'BBOS') BEGIN
	CREATE USER BBOS FOR LOGIN BBOS;
    EXEC sp_addrolemember 'db_datareader', 'BBOS'
	GRANT IMPERSONATE ON USER::DBFileAccess TO BBOS    
END ELSE BEGIN
	ALTER USER BBOS WITH LOGIN=BBOS 
END
GO

USE CRM
IF DATABASE_PRINCIPAL_ID('db_Reporting') IS NULL BEGIN

	CREATE ROLE [db_Reporting] AUTHORIZATION [dbo]
	EXEC sp_addrolemember 'db_datareader', 'db_Reporting'
	GRANT EXECUTE TO [db_Reporting]
END
Go

If NOT Exists (SELECT name FROM master.sys.server_principals WHERE name = 'ReportUser') BEGIN
	CREATE LOGIN ReportUser WITH PASSWORD = 'GoBears!';
END
Go

Use CRM
If NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'ReportUser') BEGIN
	CREATE USER ReportUser FOR LOGIN ReportUser;
	EXEC sp_addrolemember 'db_Reporting', 'ReportUser'
END ELSE BEGIN
	ALTER USER ReportUser WITH LOGIN=ReportUser 
END 
Go


Use MAS_PRC
If NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'ReportUser') BEGIN
	CREATE USER ReportUser FOR LOGIN ReportUser;
	EXEC sp_addrolemember 'db_datareader', 'ReportUser'
END ELSE BEGIN
	ALTER USER ReportUser WITH LOGIN=ReportUser 
END 
Go

Use MAS_SYSTEM
If NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'ReportUser') BEGIN
	CREATE USER ReportUser FOR LOGIN ReportUser;
	EXEC sp_addrolemember 'db_datareader', 'ReportUser'
END ELSE BEGIN
	ALTER USER ReportUser WITH LOGIN=ReportUser 
END 
Go

Use CRMArchive
IF DATABASE_PRINCIPAL_ID('db_Reporting') IS NULL BEGIN
	CREATE ROLE [db_Reporting] AUTHORIZATION [dbo]
	EXEC sp_addrolemember 'db_datareader', 'db_Reporting'
	GRANT EXECUTE TO [db_Reporting]
END
Go


If NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'ReportUser') BEGIN
	CREATE USER ReportUser FOR LOGIN ReportUser;
	EXEC sp_addrolemember 'db_Reporting', 'ReportUser'
END
Go

USE WordPressProduce
If NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'BBOS') BEGIN
	CREATE USER BBOS FOR LOGIN BBOS;
	EXEC sp_addrolemember 'db_datareader', 'BBOS'
END ELSE BEGIN
	ALTER USER BBOS WITH LOGIN=BBOS 
END
Go

USE WordPressLumber
If NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'BBOS') BEGIN
	CREATE USER BBOS FOR LOGIN BBOS;
	EXEC sp_addrolemember 'db_datareader', 'BBOS'
END ELSE BEGIN
	ALTER USER BBOS WITH LOGIN=BBOS 
END
Go

USE CRM
If NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'WPUser') BEGIN
	CREATE USER WPUser FOR LOGIN WPUser;
	EXEC sp_addrolemember 'db_datareader', 'WPUser'
END ELSE BEGIN
	ALTER USER WPUser WITH LOGIN=WPUser 
END
Go

/*
USE CRM

-- Remove the prod user from the DB
If EXISTS (SELECT name FROM sys.database_principals WHERE name = 'AZ-NC-SQL-Q1\DBMailUser') BEGIN
	REVOKE IMPERSONATE ON USER:: [AZ-NC-SQL-P2\DBMailUser] TO accpac;  
	REVOKE IMPERSONATE ON USER:: [AZ-NC-SQL-P2\DBMailUser] TO bbos;  
	DROP USER [AZ-NC-SQL-P2\DBMailUser]
END

If NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'DBMailUser') BEGIN
	CREATE USER DBMailUser FOR LOGIN [AZ-NC-SQL-Q1\DBMailUser];
END ELSE BEGIN
	ALTER USER DBMailUser WITH LOGIN=[AZ-NC-SQL-Q1\DBMailUser]; 
END
*/

GRANT IMPERSONATE ON USER:: [DBMailUser] TO accpac;  
GRANT IMPERSONATE ON USER:: [DBMailUser] TO bbos;  

