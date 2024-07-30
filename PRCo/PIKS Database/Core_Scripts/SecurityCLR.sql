--
--  This code is duplicated in SecurityEBB.sql
--  This needs to execute prior to regisering any
--  CLR Assemblies.
SET NOCOUNT ON
GO

USE MASTER
grant unsafe assembly to accpac
--grant unsafe assembly to BBSBuild
Go

ALTER DATABASE CRM SET TRUSTWORTHY ON;
GO




USE CRM
GO

ALTER AUTHORIZATION ON DATABASE::CRM TO sa
Go

-- make sure clr is enabled
sp_configure 'clr enabled', 1 
GO

RECONFIGURE 
GO


