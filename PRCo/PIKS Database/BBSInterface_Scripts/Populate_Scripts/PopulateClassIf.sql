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
If Exists (Select name from sysobjects where name = 'usp_PopulateClassIf' and type='P') Drop Procedure dbo.usp_PopulateClassIf
Go

/**
Populates the Address table from PIKS
**/
CREATE PROCEDURE dbo.usp_PopulateClassIf
as 

Declare @Start datetime
SET @Start = GETDATE()

PRINT 'Deleting From ClassIf Table'
DELETE FROM ClassIf;

-- This table has an ID column that is BBSInterface specific.  It
-- is an Identity column subsequently used to populate the ListSeq
-- column.

PRINT 'Populating ClassIf Data'
INSERT INTO ClassIf (
       BBID, 
       CLASSIF)
SELECT prc2_CompanyID,
       RTRIM(prcl_Abbreviation)
  FROM CRM.dbo.PRCompanyClassification INNER JOIN
       CRM.dbo.PRClassification ON prc2_ClassificationID = prcl_ClassificationId
 WHERE prc2_Deleted IS NULL
   AND prcl_Deleted IS NULL
   AND prc2_CompanyID IN (SELECT BBID FROM CompanyFilter)
ORDER BY prc2_Percentage DESC, prc2_CompanyClassificationId;

-- This updates the ListSeq column so that it is unique on a 
-- per BBID basis, always starting at 1.
UPDATE ClassIf 
   SET LISTSEQ = (SELECT Count(1) 
                    FROM ClassIf 
                   WHERE BBID = T.BBID 
                     AND ID < T.ID)
  FROM ClassIf T;

PRINT 'usp_PopulateClassIf Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))
GO