/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co. 2006-2011

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
If Exists (Select name from sysobjects where name = 'usp_PopulateListing' and type='P') Drop Procedure dbo.usp_PopulateListing
Go

/**
Populates the Listing table from PIKS
**/
CREATE PROCEDURE [dbo].[usp_PopulateListing]
as 
BEGIN 

SET NOCOUNT ON

DECLARE @Start datetime
SET @Start = GETDATE()

PRINT 'Deleting From Listing Table'
DELETE FROM Listing;

PRINT 'Populating Listing Data'
	INSERT INTO Listing (
		   BBID,
		   BOOKSECTION,
		   COUNTRY,
		   STATE,
		   CITY,
		   ORDERTRDSTYL,
		   BOOKTRDSTYL,
		   STATEABBREV,
		   MBRDATE,
		   STATUS,
		   HOLD,
		   CORRTRDSTYL,
		   HQBBID,
		   HQBR,
		   BILLATTN,
		   LISTATTN,
		   PAIDLINES		
			)
	SELECT Comp_CompanyId, 
		   CASE comp_PRIndustryType WHEN 'P' THEN '0' WHEN 'S' THEN '2' WHEN 'T' THEN '1' WHEN 'L' THEN '3' END,
		   dbo.ufn_GetCountry(prcn_CountryID, prcn_Country),
		   CASE WHEN prcn_CountryID in (1,2,3) THEN RTRIM(prst_State) ELSE NULL END,
		   RTRIM(prci_City), 
		   REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(Comp_Name, '.', ''), ',', ''), '''', ''), ':', ''), ';', ''),
		   RTRIM(Comp_PRBookTradestyle),
		   CASE WHEN prcn_CountryID IN (1,2) THEN RTRIM(prst_Abbreviation) ELSE NULL END,
		   CASE WHEN comp_PRTMFMAward = 'Y' THEN DATEPART(YEAR, comp_PRTMFMAwardDate) ELSE NULL END,
		   CASE comp_PRIndustryType 
			WHEN 'L' THEN 'LM'
			ELSE CASE Comp_PRListingStatus
					WHEN 'L' THEN 'L' 
					WHEN 'H' THEN 'L' 
					WHEN 'N1' THEN 'SV' 
					WHEN 'N2' THEN 'U' 
					WHEN 'N3' THEN 'DL' 
					WHEN 'N4' THEN 'DL' 
					WHEN 'D' THEN 'DL' 
				 END
			END AS Status,
		   CASE Comp_PRListingStatus WHEN 'H' THEN 'Y' ELSE NULL END AS Hold,
		   Comp_PRCorrTradestyle,
		   CASE WHEN Comp_PRType <> 'H' THEN Comp_PRHQID ELSE NULL END,
		   Comp_PRType,
		   CRM.dbo.ufn_GetAttentionLine(comp_CompanyId,'BILL'),
		   CRM.dbo.ufn_GetAttentionLine(comp_CompanyId,'LRL'),
		   CRM.dbo.ufn_GetListingDLLineCount(comp_CompanyID)
	  FROM CRM.dbo.Company WITH (NOLOCK)
	       INNER JOIN CRM.dbo.vPRLocation ON prci_CityId = comp_PRListingCityId 
	       LEFT OUTER JOIN CRM.dbo.PRCompanyProfile WITH (NOLOCK) ON prcp_CompanyId = Comp_CompanyId
	 WHERE comp_CompanyID IN (SELECT BBID FROM CompanyFilter);
	 
	SET NOCOUNT OFF
	PRINT 'usp_PopulateListing Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))   
END
Go	 

GO

If Exists (Select name from sysobjects where name = 'ufn_CountString' and type='FN') Drop Function dbo.ufn_CountString
Go

CREATE FUNCTION [dbo].[ufn_CountString]
( @pInput VARCHAR(8000), @pSearchString VARCHAR(100) )
RETURNS INT
BEGIN

	IF @pInput IS NULL RETURN 0

    RETURN (LEN(@pInput) - LEN(REPLACE(@pInput, @pSearchString, ''))) /
            LEN(@pSearchString)

END
GO
