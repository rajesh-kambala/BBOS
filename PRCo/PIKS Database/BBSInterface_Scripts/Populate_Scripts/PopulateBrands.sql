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
If Exists (Select name from sysobjects where name = 'usp_PopulateBrands' and type='P') Drop Procedure dbo.usp_PopulateBrands
Go

/**
Populates the Affil table from PIKS
**/
CREATE PROCEDURE dbo.usp_PopulateBrands
as 

PRINT 'Deleting From Brands Table'
DELETE FROM Brands;

PRINT 'Populating Brands Data'
INSERT INTO Brands (
       BBID,
       LISTSEQ,
       BRAND,
       LIST)
SELECT prc3_CompanyID, -- BBID
       prc3_Sequence,  -- LISTSEQ
       RTRIM(prc3_Brand), -- BRAND
	   ISNULL(prc3_Publish, 'N') -- LIST
  FROM CRM.dbo.PRCompanyBrand
 WHERE prc3_Deleted IS NULL
   AND prc3_CompanyID IN (SELECT BBID FROM CompanyFilter);

Go