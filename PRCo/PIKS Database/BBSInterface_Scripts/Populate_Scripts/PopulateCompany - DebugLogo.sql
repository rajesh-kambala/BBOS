USE BBSInterface

IF EXISTS(SELECT name FROM BBSInterface..sysobjects WHERE name = N'Logos' AND xtype='U')
	DROP TABLE Logos

CREATE TABLE Logos (
    BBID int,
    LogoFile varchar(255),
    StartDate datetime,
    ExpDate datetime,
    LogoExists int
)

/***********************************************************************
***********************************************************************
 Copyright Produce Report Co. 2006-2010

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Report Co. is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Report Co.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 Notes:	

***********************************************************************
***********************************************************************/
USE BBSInterface

If Exists (Select name from sysobjects where name = 'usp_PopulateCompany' and type='P') Drop Procedure dbo.usp_PopulateCompany
Go

/**
Updates the Company Table
**/
CREATE PROCEDURE dbo.usp_PopulateCompany
AS

	DECLARE @Start datetime
	SET @Start = GETDATE()


	PRINT 'Resetting Company Data' + CONVERT(VARCHAR(12), GETDATE(), 114)

	ALTER TABLE CRM.dbo.Company DISABLE TRIGGER ALL

	-- Reset our company fields.  The subsequent updates statements
	-- will only set the appropriate column for those BBS' that meet
	-- the criteria
	UPDATE CRM.dbo.Company
	   SET comp_PRDaysPastDue = 0,
		   comp_PRDLDaysPastDue = 0,
		   comp_PRLogo = NULL;


	Print 'Setting comp_PRDaysPastDue: '  + CONVERT(VARCHAR(12), GETDATE(), 114)
	UPDATE CRM.dbo.Company
	   SET comp_PRDaysPastDue = Days
	  FROM OPENROWSET(BULK 'D:\Applications\BBSInterface\Pastdue.txt', FORMATFILE='D:\Applications\BBSInterface\Format\Pastdue.fmt') As pastdue
	 WHERE comp_CompanyID = BBID;

	Print 'Setting comp_PRDLDaysPastDue: '  + CONVERT(VARCHAR(12), GETDATE(), 114)
	UPDATE CRM.dbo.Company
	   SET comp_PRDLDaysPastDue = Days
	  FROM OPENROWSET(BULK 'D:\Applications\BBSInterface\DPastdue.txt', FORMATFILE='D:\Applications\BBSInterface\Format\DPastdue.fmt') As DPastdue
	 WHERE comp_CompanyID = BBID;

	-- Logo File
	Print 'Setting comp_PRlogo: '  + CONVERT(VARCHAR(12), GETDATE(), 114)
    DELETE FROM BBSInterface.dbo.service;
	DELETE FROM BBSInterface.dbo.Gfx;
	DELETE FROM BBSInterface.dbo.Logos;

	BULK INSERT BBSInterface.dbo.Gfx  FROM N'D:\Applications\BBSInterface\Gfx.txt'  WITH (FormatFile=N'D:\Applications\BBSInterface\Format\Gfx.fmt')
	BULK INSERT BBSInterface.dbo.Service  FROM N'D:\Applications\BBSInterface\Service.txt'  WITH (FormatFile=N'D:\Applications\BBSInterface\Format\Service.fmt')

	INSERT INTO BBSInterface.dbo.Logos
	SELECT Gfx.BBID,
		   CONVERT(varchar(20), Gfx.LogoID) + '\' +  CONVERT(varchar(20), Gfx.LogoID) + '.jpg' As LogoFile,
           StartDate, 
           ExpDate,
           dbo.ufnclr_DoesLogoExist(CONVERT(varchar(20), Gfx.LogoID) + '\' +  CONVERT(varchar(20), Gfx.LogoID) + '.jpg')
	  FROM gfx
		   INNER JOIN Service  On [Service].SVCID = Gfx.SVCID
	 WHERE (ExpDate is null 
			OR ExpDate > GetDate()) 
	   AND StartDate <= DateAdd(Month, 3, GetDate())

	UPDATE CRM.dbo.Company
	   SET comp_PRlogo = LogoFile
	  FROM Logos
     WHERE comp_CompanyID = BBID
	   AND LogoExists = 1;

	ALTER TABLE CRM.dbo.Company ENABLE TRIGGER ALL
Print 'Done: '  + CONVERT(VARCHAR(12), GETDATE(), 114)
PRINT 'usp_PopulateCompany Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))
Go