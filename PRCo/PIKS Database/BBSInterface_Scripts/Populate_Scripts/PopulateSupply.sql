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
If Exists (Select name from sysobjects where name = 'usp_PopulateSupply' and type='P') Drop Procedure dbo.usp_PopulateSupply
Go

/**
Populates the Supply table from PIKS
**/
CREATE PROCEDURE dbo.usp_PopulateSupply
as 

DECLARE @Start datetime
SET @Start = GETDATE()

PRINT 'Deleting From Supply Table'
DELETE FROM Supply;

PRINT 'Populating Supply Data'
INSERT INTO Supply (
       BBID, 
       SUPPLY)
SELECT prc2_CompanyID, 
       RTRIM(prcl_Name)
  FROM CRM.dbo.PRClassification, CRM.dbo.PRCompanyClassification
 WHERE prcl_ClassificationId = prc2_ClassificationId
   AND dbo.ufn_GetRootClassificationIndustryType(prcl_Path) IN (2)
   AND prc2_Deleted IS NULL
   AND prc2_CompanyID IN (SELECT BBID FROM CompanyFilter)
ORDER BY prc2_CompanyID, prc2_Percentage DESC, prc2_CompanyClassificationID;

-- Set our sequence numbers
UPDATE SUPPLY 
   SET LISTSEQ = (SELECT Count(1)+1 
                    FROM SUPPLY 
                   WHERE BBID = T.BBID 
                     AND ID < T.ID)
  FROM SUPPLY T;

PRINT 'usp_PopulateSupply Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))
Go



If Exists (Select name from sysobjects where name = 'ufn_GetRootClassificationIndustryType' and type='FN') Drop Function dbo.ufn_GetRootClassificationIndustryType
Go

/* 
    This function returns the IndustryType for the Level1 classification.
*/
CREATE FUNCTION dbo.ufn_GetRootClassificationIndustryType(@Path varchar(100))  
RETURNS int AS  
BEGIN 
	
	DECLARE @IndustryType int
    SELECT @IndustryType = prcl_BookSection 
      FROM CRM.dbo.PRClassification 
     WHERE prcl_ClassificationId = CRM.dbo.ufn_GetCommodityPathElement(@Path, 1)

	RETURN @IndustryType
END
GO
