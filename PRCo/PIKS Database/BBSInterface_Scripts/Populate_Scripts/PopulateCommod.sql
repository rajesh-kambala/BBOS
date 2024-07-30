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
If Exists (Select name from sysobjects where name = 'usp_PopulateCommod' and type='P') Drop Procedure dbo.usp_PopulateCommod
Go

/**
Populates the Commod table from PIKS
**/
CREATE PROCEDURE dbo.usp_PopulateCommod
as 

Declare @Start datetime
SET @Start = GETDATE()

PRINT 'Deleting From Commod Table'
DELETE FROM Commod;

-- This table has an ID column that is BBSInterface specific.  It
-- is an Identity column subsequently used to populate the ListSeq
-- column.

PRINT 'Populating Commod Data'
INSERT INTO commod (
       BBID, 
       COMMOD, 
       LISTSEQ)
SELECT prcca_CompanyID,
       RTRIM(prcca_PublishedDisplay), 
       prcca_Sequence
  FROM CRM.dbo.PRCompanyCommodityAttribute
 WHERE prcca_CompanyID IN (SELECT BBID FROM CompanyFilter)
ORDER BY prcca_CompanyID, prcca_Sequence;

-- This updates the ListSeq column so that it is unique on a 
-- per BBID basis, always starting at 1.
UPDATE commod 
   SET LISTSEQ = (SELECT Count(1) + 10000
                    FROM commod 
                   WHERE BBID = T.BBID 
                     AND ID < T.ID)
  FROM commod T
 WHERE LISTSEQ IS NULL; 


PRINT 'usp_PopulateCommod Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))

Go
