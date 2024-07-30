-- Add your test scenario here --

Declare @MonthsFromToday int
SELECT @MonthsFromToday = -1

--Declare @StartDate datetime, @Now datetime
--SELECT @StartDate = DateAdd(Month, @MonthsFromToday , getDate()), @Now = getDate()

Declare @StartDate datetime, @Now datetime
SELECT @Now = convert(datetime, '08/30/2006')
SELECT @StartDate = DateAdd(Month, @MonthsFromToday , @Now)--, @Now = getDate()

Declare @FilesToProcess table (ndx int identity, FileDate varchar(8), LicenseCount int, PrincipalCount int, TradeCount int)
DECLARE @Dir varchar(max)
SELECT @Dir = 'C:\RichardOtruba\Clients\Travant\PIKS\Import Data\PACA Input\'

DECLARE @StartDateString varchar(8)
DECLARE @StartDateMonth varchar(2), @StartDateDay varchar(2), @StartDateYear varchar(4)
DECLARE @LicenseCount int, @PrincipalCount int, @TradeCount int

While (@StartDate < @Now)
Begin
	SELECT @LicenseCount = 0, @PrincipalCount = 0, @TradeCount = 0
	-- Get the date as a string
	SELECT @StartDateMonth = DatePart(month, @StartDate) 
	SELECT @StartDateDay = DatePart(Day, @StartDate) 
	SELECT @StartDateYear = DatePart(Year, @StartDate) 
	SELECT @StartDateMonth = case when @StartDateMonth < 10 then '0'+@StartDateMonth else @StartDateMonth end,
			@StartDateDay = case when @StartDateDay < 10 then '0'+@StartDateDay else @StartDateDay end
	SELECT @StartDateString = @StartDateYear + @StartDateMonth + @StartDateDay 
	PRINT @StartDateString

	SELECT @LicenseCount = count(1) from PACALicenseFile(@Dir, @StartDateString)
--	SELECT @PrincipalCount = count(1) from PACAPrincipalFile(@Dir, @StartDateString)
--	SELECT @TradeCount = count(1) from PACATradeFile(@Dir, @StartDateString)
	
	if (@LicenseCount > 0 OR @PrincipalCount > 0 OR @TradeCount > 0)
		Insert into @FilesToProcess VALUES (@StartDateString, @LicenseCount, @PrincipalCount, @TradeCount)
	
	-- increment the loop
	SELECT @StartDate = DATEADD(Day, 1, @StartDate)
End

SELECT * FROM @FilesToProcess 
/*
DECLARE @Dir varchar(max)
DECLARE @FileDate char(8)
SELECT @Dir = 'C:\RichardOtruba\Clients\Travant\PIKS\Import Data\PACA Input\'
SELECT @FileDate = '20060731'
select count(*) from PACALicenseFile(@Dir, @FileDate)
select count(*) from PACAPrincipalFile(@Dir, @FileDate)
select count(*) from PACATradeFile(@Dir, @FileDate)

SELECT @FileDate = '20060801'
select count(*) from PACALicenseFile(@Dir, @FileDate)
select count(*) from PACAPrincipalFile(@Dir, @FileDate)
select count(*) from PACATradeFile(@Dir, @FileDate)
SELECT @FileDate = '20060802'
select count(*) from PACALicenseFile(@Dir, @FileDate)
select count(*) from PACAPrincipalFile(@Dir, @FileDate)
select count(*) from PACATradeFile(@Dir, @FileDate)
SELECT @FileDate = '20060803'
select count(*) from PACALicenseFile(@Dir, @FileDate)
select count(*) from PACAPrincipalFile(@Dir, @FileDate)
SELECT @FileDate = '20060804'
select count(*) from PACALicenseFile(@Dir, @FileDate)
select count(*) from PACAPrincipalFile(@Dir, @FileDate)
select count(*) from PACATradeFile(@Dir, @FileDate)
select count(*) from PACATradeFile(@Dir, @FileDate)

*/