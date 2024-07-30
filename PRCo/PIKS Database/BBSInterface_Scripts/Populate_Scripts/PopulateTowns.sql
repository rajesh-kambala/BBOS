/***********************************************************************
***********************************************************************
 Copyright Produce Report Co. 2006

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
If Exists (Select name from sysobjects where name = 'usp_PopulateTowns' and type='P') Drop Procedure dbo.usp_PopulateTowns
Go

/**
Populates the Towns table from PIKS
**/
CREATE PROCEDURE dbo.usp_PopulateTowns
as 

Declare @Start datetime
SET @Start = GETDATE()

PRINT 'Deleting From Towns Table'
DELETE FROM Towns;

-- prci_County (which is currently NULL for all recs) has been obsoleted; therefore the else condition 
-- of the County value will return NULL explicitly
PRINT 'Populating Towns Data'
INSERT INTO Towns (
       CITY,
       STATE,
       COUNTRY,
       STATEABBREV,
       COUNTY)
SELECT RTRIM(prci_City),  -- CITY
       CASE WHEN prcn_CountryID in (1,2,3) THEN RTRIM(prst_State) ELSE NULL END, -- STATE
		dbo.ufn_GetCountry(prcn_CountryID, prcn_Country), -- COUNTRY
  	   CASE prcn_CountryID 
            WHEN  1 THEN RTRIM(prst_Abbreviation) 
            WHEN 2 THEN RTRIM(prst_Abbreviation) END, --STATEABBREV
       CASE prcn_CountryID 
            WHEN 3 THEN RTRIM(prst_State) ELSE NULL END -- COUNTY
  FROM CRM.dbo.PRState INNER JOIN
       CRM.dbo.PRCity ON prst_StateId = prci_StateId INNER JOIN
       CRM.dbo.PRCountry ON prst_CountryId = prcn_CountryId;

PRINT 'usp_PopulateTowns Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))
GO