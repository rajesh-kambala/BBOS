USE BBSInterface

IF EXISTS(SELECT name FROM BBSInterface..sysobjects WHERE name = N'Logo' AND xtype='U')
	DROP TABLE Logo

IF EXISTS(SELECT name FROM BBSInterface..sysobjects WHERE name = N'Logos' AND xtype='U')
	DROP TABLE Logos


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
		   comp_PRDLDaysPastDue = 0;

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

	ALTER TABLE CRM.dbo.Company ENABLE TRIGGER ALL
Print 'Done: '  + CONVERT(VARCHAR(12), GETDATE(), 114)
PRINT 'usp_PopulateCompany Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))
Go