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
If Exists (Select name from sysobjects where name = 'usp_PopulateAffil' and type='P') Drop Procedure dbo.usp_PopulateAffil
Go

/**
Populates the Affil table from PIKS
**/
CREATE PROCEDURE dbo.usp_PopulateAffil
as 

DECLARE @Start datetime
SET @Start = GETDATE()

PRINT 'Deleting From Affil Table'
DELETE FROM Affil;

PRINT 'Populating Affil Data'
INSERT INTO Affil (
       BBID1,
       BBID2)
SELECT DISTINCT prcr_LeftCompanyID, -- BBID1
       prcr_RightCompanyID -- BBID2
  FROM CRM.dbo.PRCompanyRelationship
 WHERE PRCR_Type IN (27, 28, 29)
   AND PRCR_Deleted IS NULL
   AND (prcr_LeftCompanyID IN (SELECT BBID FROM CompanyFilter)
        OR prcr_RightCompanyID IN (SELECT BBID FROM CompanyFilter)) 
UNION
SELECT DISTINCT prcr_RightCompanyID, -- BBID1
       prcr_LeftCompanyID -- BBID2
  FROM CRM.dbo.PRCompanyRelationship
 WHERE PRCR_Type IN (27, 28, 29)
   AND PRCR_Deleted IS NULL
   AND (prcr_LeftCompanyID IN (SELECT BBID FROM CompanyFilter)
        OR prcr_RightCompanyID IN (SELECT BBID FROM CompanyFilter)) ;

PRINT 'usp_PopulateAffil Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))

Go