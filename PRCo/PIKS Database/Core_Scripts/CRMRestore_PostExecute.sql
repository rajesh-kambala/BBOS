/* CRMRestore_PostExecute.sql
	Fixes the user accounts and trustworthy status of a restored CRM database.	
*/
Use CRM
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


Go
Use MSDB
If NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'accpac') BEGIN
	CREATE USER accpac FOR LOGIN accpac;
	GRANT Authenticate TO accpac
END ELSE BEGIN
	ALTER USER accpac WITH LOGIN=accpac 
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
 

-- grant the accpac user access to administer CLR Assemblies
Use Master
If NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'accpac') BEGIN
	CREATE USER accpac FOR LOGIN accpac;
END ELSE BEGIN
	ALTER USER accpac WITH LOGIN=accpac 
END
Go

USE CRM
If NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'MAS_User') BEGIN
	CREATE USER MAS_User FOR LOGIN MAS_User;
	EXEC sp_addrolemember 'db_owner', 'MAS_User'
END
Go	

USE WordPress
If NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'accpac') BEGIN
	CREATE USER accpac FOR LOGIN accpac;
	EXEC sp_addrolemember 'db_owner', 'accpac'
END ELSE BEGIN
	ALTER USER accpac WITH LOGIN=accpac 
END

USE WordPress
If NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'BBOS') BEGIN
	CREATE USER BBOS FOR LOGIN BBOS;
	EXEC sp_addrolemember 'db_datareader', 'BBOS'
END ELSE BEGIN
	ALTER USER BBOS WITH LOGIN=BBOS 
END