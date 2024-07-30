if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DebugLog]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[DebugLog]
GO

CREATE TABLE [dbo].[DebugLog](
	ID int identity(1,1) primary key,
    LogDate datetime DEFAULT (GETDATE()),
	Message varchar(max)
)
Go


If Exists (Select name from sysobjects where name = 'usp_PopulateCompany' and type='P') Drop Procedure dbo.usp_PopulateCompany
Go

/**
Updates the Company Table
**/
CREATE PROCEDURE dbo.usp_PopulateCompany
AS

DECLARE @DebugID int
SET @DebugID = 211092

DECLARE @Start datetime
SET @Start = GETDATE()

PRINT 'Updating Company Data'

-- Reset our company fields.  The subsequent updates statements
-- will only set the appropriate column for those BBS' that meet
-- the criteria
UPDATE CRM.dbo.Company
   SET comp_PRSuspendedService = NULL,
       comp_PRDaysPastDue = 0,
       comp_PRDLDaysPastDue = 0,
       comp_PRLogo = NULL;

UPDATE CRM.dbo.Company
   SET comp_PRSuspendedService = 'Y'
  FROM OPENROWSET(BULK 'D:\Applications\BBSInterface\Servsusp.txt', FORMATFILE='D:\Applications\BBSInterface\Format\Servsusp.fmt') As Servsusp
 WHERE comp_CompanyID = BBID;

UPDATE CRM.dbo.Company
   SET comp_PRDaysPastDue = Days
  FROM OPENROWSET(BULK 'D:\Applications\BBSInterface\Pastdue.txt', FORMATFILE='D:\Applications\BBSInterface\Format\Pastdue.fmt') As pastdue
 WHERE comp_CompanyID = BBID;

UPDATE CRM.dbo.Company
   SET comp_PRDLDaysPastDue = Days
  FROM OPENROWSET(BULK 'D:\Applications\BBSInterface\DPastdue.txt', FORMATFILE='D:\Applications\BBSInterface\Format\DPastdue.fmt') As DPastdue
 WHERE comp_CompanyID = BBID;


--
-- DEBUG
--
-- Look to see if our company has a logo entry
    
DECLARE @Found bit
SET @Found = 0

	SELECT @Found = 1
      FROM OPENROWSET(BULK 'D:\Applications\BBSInterface\Gfx.txt', FORMATFILE='D:\Applications\BBSInterface\Format\Gfx.fmt') As Gfx
           INNER JOIN OPENROWSET(BULK 'D:\Applications\BBSInterface\Service.txt', FORMATFILE='D:\Applications\BBSInterface\Format\Service.fmt') As [Service] On [Service].SVCID = Gfx.SVCID
     WHERE (EXPDATE is null or EXPDATE > GetDate()) AND STARTDATE <= DateAdd(Month, 3, GetDate())
       AND Gfx.BBID = @DebugID;

IF (@Found = 1) BEGIN
	INSERT INTO DebugLog (Message) VALUES ('Found Logo in SBBS data joining Gfx with Service');
END ELSE BEGIN
	INSERT INTO DebugLog (Message) VALUES ('Did NOT Find Logo in SBBS data joining Gfx with Service');

	SELECT @Found = 1
      FROM OPENROWSET(BULK 'D:\Applications\BBSInterface\Gfx.txt', FORMATFILE='D:\Applications\BBSInterface\Format\Gfx.fmt') As Gfx
     WHERE Gfx.BBID = @DebugID;

	IF (@Found = 1) BEGIN
		INSERT INTO DebugLog (Message) VALUES ('Found Logo in SBBS Gfx data');
	END ELSE BEGIN
		INSERT INTO DebugLog (Message) VALUES ('Did NOT Find Logo in SBBS Gfx data');
	END

	SET @Found = 0
	SELECT @Found = 1
	  FROM OPENROWSET(BULK 'D:\Applications\BBSInterface\Service.txt', FORMATFILE='D:\Applications\BBSInterface\Format\Service.fmt') As Svc
     WHERE BBID = @DebugID
       AND SvcType = 'LOGO'
       AND (EXPDATE is null or EXPDATE > GetDate()) AND STARTDATE <= DateAdd(Month, 3, GetDate());

	IF (@Found = 1) BEGIN
		INSERT INTO DebugLog (Message) VALUES ('Found Logo in SBBS Service data');
	END ELSE BEGIN
		INSERT INTO DebugLog (Message) VALUES ('Did NOT Find Logo in SBBS Service data');
	END

END




-- Logo File
UPDATE CRM.dbo.Company
   SET comp_PRlogo = CONVERT(varchar(20), LogoID) + '\' +  CONVERT(varchar(20), LogoID) + '.jpg'
FROM
(
    SELECT
        Gfx.BBID,
        Gfx.LogoID,
        [Service].StartDate,
        [Service].ExpDate
    FROM
        OPENROWSET(BULK 'D:\Applications\BBSInterface\Gfx.txt', FORMATFILE='D:\Applications\BBSInterface\Format\Gfx.fmt') As Gfx
        INNER JOIN OPENROWSET(BULK 'D:\Applications\BBSInterface\Service.txt', FORMATFILE='D:\Applications\BBSInterface\Format\Service.fmt') As [Service] On [Service].SVCID = Gfx.SVCID
    WHERE
        (EXPDATE is null or EXPDATE > GetDate()) AND STARTDATE <= DateAdd(Month, 3, GetDate())
) As Logo
WHERE comp_CompanyID = BBID;


SET @Found = 0;
SELECT @Found = 1
  FROM CRM.dbo.Company
 WHERE comp_CompanyID=@DebugID
   AND comp_PRlogo IS NOT NULL;


IF (@Found = 1) BEGIN
	INSERT INTO DebugLog (Message) VALUES ('Found Logo in CRM Company table');
END ELSE BEGIN
	INSERT INTO DebugLog (Message) VALUES ('Did NOT Find Logo in CRM Company table');
END

PRINT 'usp_PopulateCompany Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))
Go

