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
If Exists (Select name from sysobjects where name = 'usp_PopulateSuppval' and type='P') Drop Procedure dbo.usp_PopulateSuppval
Go

/**
Populates the SuppVal table from PIKS
**/
CREATE PROCEDURE dbo.usp_PopulateSuppval
as 

Declare @Start datetime
SET @Start = GETDATE()

PRINT 'Deleting From SuppVal Table'
DELETE FROM SUPPVAL;

PRINT 'Populating SuppVal Data'
INSERT INTO SUPPVAL (
       SUPPLY,
       SUPPKEY,
       SUPPLY_SPANISH, 
       LINE1, 
       LINE2, 
       LINE3, 
       LINE4)
SELECT RTRIM(prcl_Name), 
       RTRIM(prcl_Abbreviation), 
       prcl_Name_ES, 
       prcl_Line1, 
       prcl_Line2, 
       prcl_Line3, 
       prcl_Line4
  FROM CRM.dbo.PRClassification
 WHERE dbo.ufn_GetRootClassificationIndustryType(prcl_Path) IN (2)
   AND prcl_Deleted IS NULL
   AND prcl_Level <> 1;
Go


