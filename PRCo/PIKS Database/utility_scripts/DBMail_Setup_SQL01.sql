/*
USE MSDB
EXEC sp_grantdbaccess 'accpac'
GRANT Authenticate TO accpac
*/

USE CRM
ALTER DATABASE CRM SET TRUSTWORTHY ON


--CREATE LOGIN [SQL01\rsuser] FROM WINDOWS
--GO

--EXEC msdb.dbo.sp_addrolemember @rolename = 'DatabaseMailUserRole', 
--   @membername = 'SQL01\rsuser' 
--GO

USE CRM
--EXEC sp_grantdbaccess 'SQL01\rsuser', 'DBFileAccess'
EXEC sp_grantdbaccess 'NT AUTHORITY\SYSTEM', 'DBFileAccess'


