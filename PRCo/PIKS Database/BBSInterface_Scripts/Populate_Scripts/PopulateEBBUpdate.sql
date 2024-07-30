/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co. 2006

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co. is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 Notes:	

***********************************************************************
***********************************************************************/
If Exists (Select name from sysobjects where name = 'usp_PopulateEBBUpdate' and type='P') Drop Procedure dbo.usp_PopulateEBBUpdate
Go

/**
Populates the EBBUpdate table from PIKS
**/
CREATE PROCEDURE [dbo].[usp_PopulateEBBUpdate]
	@StartDate datetime, 
	@EndDate datetime
as 

	Declare @Start datetime
	SET @Start = GETDATE()

	-- Update the EBBUpdate fields for those records in our
	-- timeframe that don't already have a date.
	UPDATE CRM.dbo.PRCreditSheet
	   SET prcs_EBBUpdatePubDate = GETDATE(),
           prcs_UpdatedDate = GETDATE(),
           prcs_UpdatedBy = CRM.dbo.ufn_GetSystemUserId(0),
           prcs_TimeStamp = GETDATE()
	 WHERE prcs_PublishableDate BETWEEN @StartDate AND @EndDate
	   AND prcs_Status = 'P' -- Publishable
	   AND prcs_EBBUpdatePubDate IS NULL;

	PRINT 'Deleting From EBBUpdate Table'
	DELETE FROM EBBUpdate;

	PRINT 'Populating EBBUpdate Data'
	INSERT INTO EBBUpdate
	SELECT prcs_PublishableDate,
		   prcs_CompanyId,
		   prcs_Tradestyle,
		   prci_City,
   		   CASE prst_CountryID WHEN 1 THEN RTRIM(prst_Abbreviation) WHEN 2 THEN RTRIM(prst_Abbreviation) ELSE NULL END,
		   prcn_Country,
		   prcs_EBBUpdatePubDate,
		   prcs_KeyFlag,
           CRM.dbo.ufn_GetItem(prcs_CreditSheetID, 1, 1, 34)
	  FROM CRM.dbo.PRCreditSheet
		   LEFT OUTER JOIN CRM.dbo.vPRLocation ON prcs_CityID = prci_CityID
	 WHERE prcs_PublishableDate BETWEEN @StartDate AND @EndDate
	   AND prcs_Status = 'P' -- Publishable
	ORDER BY prcs_CompanyId, prcs_EBBUpdatePubDate

	PRINT 'usp_PopulateEBBUpdate Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))

Go