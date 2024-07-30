-- Examples for queries that exercise different SQL objects implemented by this assembly

-----------------------------------------------------------------------------------------
-- Stored procedure
-----------------------------------------------------------------------------------------
-- exec StoredProcedureName


-----------------------------------------------------------------------------------------
-- User defined function
-----------------------------------------------------------------------------------------
-- select dbo.FunctionName()


-----------------------------------------------------------------------------------------
-- User defined type
-----------------------------------------------------------------------------------------
-- CREATE TABLE test_table (col1 UserType)
-- go
--
-- INSERT INTO test_table VALUES (convert(uri, 'Instantiation String 1'))
-- INSERT INTO test_table VALUES (convert(uri, 'Instantiation String 2'))
-- INSERT INTO test_table VALUES (convert(uri, 'Instantiation String 3'))
--
-- select col1::method1() from test_table



-----------------------------------------------------------------------------------------
-- User defined type
-----------------------------------------------------------------------------------------
-- select dbo.AggregateName(Column1) from Table1
/*
DECLARE @Dir varchar(max)
DECLARE @FileDate char(8)
SELECT @Dir = 'C:\RichardOtruba\Clients\Travant\PIKS\Import Data\PACA Input\'
SELECT @FileDate = '20060731'
select * from PACALicenseFile(@Dir, @FileDate)
select * from PACAPrincipalFile(@Dir, @FileDate)
select * from PACATradeFile(@Dir, @FileDate)


DECLARE @Dir varchar(max)
DECLARE @FileDate char(8)
SELECT @Dir = '\\fs1\vol1\pacaupdt\'
--SELECT @Dir = 'C:\RichardOtruba\Clients\Travant\PIKS\Import Data\PACA Input\'
SELECT @FileDate = '20061201'
select count(*) from PACALicenseFile(@Dir, @FileDate)
select count(*) from PACAPrincipalFile(@Dir, @FileDate)
select count(*) from PACATradeFile(@Dir, @FileDate)
*/
Exec uspclr_PopulateEquifaxData