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
If Exists (Select name from sysobjects where name = 'usp_PopulateClassVal' and type='P') Drop Procedure dbo.usp_PopulateClassVal
Go

/**
Populates the ClassVal table from PIKS
**/
CREATE PROCEDURE dbo.usp_PopulateClassVal
as 

PRINT 'Deleting From ClassVal Table'
DELETE FROM ClassVal;

PRINT 'Populating ClassVal Data'
INSERT INTO ClassVal (
       CLASSIF,
       [DESC],
       DESC_SPANISH)
SELECT RTRIM(prcl_Abbreviation), 
       RTRIM(prcl_Name),
       RTRIM(prcl_Name_ES)
  FROM CRM.dbo.PRClassification 
 WHERE prcl_Level in (2, 3)
   AND prcl_Deleted IS NULL
   AND prcl_BookSection <> 2;
Go