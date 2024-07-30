USE master
alter database [LumberLeads] set offline with rollback immediate
alter database [LumberLeads] set online
Go



RESTORE DATABASE [LumberLeads] FROM  DISK = N'D:\Restore_Point\LumberLeads.bak' 
WITH  FILE = 1,  
	  NOUNLOAD,  
	  REPLACE,  
	  STATS = 10,
	  MOVE 'LumberLeads' TO 'D:\Applications\SQLServer_Data\LumberLeads.mdf', 
	  MOVE 'LumberLeads_Log'  TO 'D:\Applications\SQLServer_Data\LumberLeads_1.ldf';
Go	  
	  

USE [LumberLeads] 
		
If NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'accpac') BEGIN
	CREATE USER accpac FOR LOGIN accpac;
	EXEC sp_addrolemember 'db_owner', 'accpac'
END ELSE BEGIN
	ALTER USER accpac WITH LOGIN=accpac 
END  
Go

ALTER TABLE LEAD ADD CustomerNumber varchar(15)

CREATE FUNCTION [dbo].[ufn_GetCustomerNumber] ( 
    @BatchID int
)
RETURNS varchar(50)
AS
BEGIN

	DECLARE @CustomerNumber varchar(50)

	SELECT @CustomerNumber = CustomerNumber
	  FROM Lead
	       INNER JOIN Match ON Lead.LeadID = Match.LeadID 
	 WHERE BatchID = @BatchID
	   AND CustomerNumber IS NOT NULL
  ORDER BY Lead.LeadID DESC;

	RETURN @CustomerNumber
END
--select * from lead where customerNumber is not null