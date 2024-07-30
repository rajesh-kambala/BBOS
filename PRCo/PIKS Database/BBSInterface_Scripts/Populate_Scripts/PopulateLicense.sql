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
If Exists (Select name from sysobjects where name = 'usp_PopulateLicense' and type='P') Drop Procedure dbo.usp_PopulateLicense
Go

/**
Populates the Address table from PIKS
**/
CREATE PROCEDURE dbo.usp_PopulateLicense
as 

PRINT 'Deleting From License Table'
DELETE FROM License;

PRINT 'Populating License Data'
INSERT INTO License (
       BBID,
       SEQ,
       TYPE,
       NUMBER,
       LIST)
SELECT prpa_CompanyID, -- BBID
       CRM.dbo.ufn_GetListingLicenseSeq('PACA'), -- SEQ
       'PACA', -- TYPE
       RTRIM(prpa_LicenseNumber), -- NUMBER
       ISNULL(prpa_Publish, 'N') -- LIST
  FROM CRM.dbo.PRPACALicense
 WHERE prpa_Deleted IS NULL
   AND prpa_Current = 'Y'
   AND prpa_CompanyID IN (SELECT BBID FROM CompanyFilter)
UNION
SELECT prdr_CompanyID,  -- BBID
       CRM.dbo.ufn_GetListingLicenseSeq('DRC'),  -- SEQ
       'DRC',  -- TYPE
       RTRIM(prdr_LicenseNumber),  -- NUMBER
       ISNULL(prdr_Publish, 'N') -- LIST
  FROM CRM.dbo.PRDRCLicense
 WHERE prdr_Deleted IS NULL
   AND prdr_CompanyID IN (SELECT BBID FROM CompanyFilter)
UNION
SELECT prli_CompanyID,  -- BBID
       CRM.dbo.ufn_GetListingLicenseSeq(prli_Type),  -- SEQ
       CASE WHEN prli_Type = 'CFIA' THEN 'AGCAN' ELSE prli_Type END,  -- TYPE
       RTRIM(prli_Number),  -- NUMBER
       ISNULL(prli_Publish, 'N') -- LIST
  FROM CRM.dbo.PRCompanyLicense
 WHERE prli_Deleted IS NULL
   AND prli_CompanyID IN (SELECT BBID FROM CompanyFilter)
GO