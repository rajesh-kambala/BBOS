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
If Exists (Select name from sysobjects where name = 'usp_PopulateChangeDetection' and type='P') Drop Procedure dbo.usp_PopulateChangeDetection
Go

/**
Populates the ChangeDetection table from PIKS
**/
CREATE PROCEDURE dbo.usp_PopulateChangeDetection
as 

DECLARE @Start datetime
SET @Start = GETDATE()

PRINT 'Deleting From ChangeDetection Table'
DELETE FROM ChangeDetection;

PRINT 'Populating ChangeDetection Data'
INSERT INTO ChangeDetection (
       BBID,
       LastUpdatedDateTime)
SELECT BBID, 
       MAX(LastUpdatedDateTime)
  FROM (
SELECT adli_CompanyID As BBID, addr_UpdatedDate as LastUpdatedDateTime
  FROM CRM.dbo.Address 
       INNER JOIN CRM.dbo.Address_Link ON addr_AddressID = adli_AddressID
 WHERE adli_CompanyID in (SELECT BBID FROM CompanyFilter)
UNION
SELECT adli_CompanyID, adli_UpdatedDate
  FROM CRM.dbo.Address_Link
 WHERE adli_CompanyID in (SELECT BBID FROM CompanyFilter)
UNION
SELECT PRCR_LeftCompanyID, prcr_UpdatedDate
  FROM CRM.dbo.PRCompanyRelationship
 WHERE PRCR_Type IN (27, 28, 29)
   AND PRCR_RightCompanyID in (SELECT BBID FROM CompanyFilter)
UNION
SELECT PRCR_RightCompanyID, prcr_UpdatedDate
  FROM CRM.dbo.PRCompanyRelationship
 WHERE PRCR_Type IN (27, 28, 29)
   AND PRCR_LeftCompanyID in (SELECT BBID FROM CompanyFilter)
UNION
SELECT prc3_CompanyID, prc3_UpdatedDate
  FROM CRM.dbo.PRCompanyBrand
 WHERE prc3_CompanyID in (SELECT BBID FROM CompanyFilter)
UNION
SELECT prc2_CompanyID, prc2_UpdatedDate
  FROM CRM.dbo.PRCompanyClassification 
 WHERE prc2_CompanyID in (SELECT BBID FROM CompanyFilter)
UNION
SELECT prcca_CompanyID, prcca_UpdatedDate
  FROM CRM.dbo.PRCompanyCommodityAttribute
 WHERE prcca_CompanyID in (SELECT BBID FROM CompanyFilter)
UNION
SELECT comp_CompanyID, comp_UpdatedDate
  FROM CRM.dbo.Company
 WHERE comp_CompanyID in (SELECT BBID FROM CompanyFilter)
UNION
SELECT prpa_CompanyID, prpa_UpdatedDate
  FROM CRM.dbo.PRPACALicense
 WHERE prpa_CompanyID in (SELECT BBID FROM CompanyFilter)
UNION
SELECT prdr_CompanyID, prdr_UpdatedDate
  FROM CRM.dbo.PRDRCLicense
 WHERE prdr_CompanyID in (SELECT BBID FROM CompanyFilter)
UNION
SELECT prli_CompanyID, prli_UpdatedDate
  FROM CRM.dbo.PRCompanyLicense
 WHERE prli_CompanyID in (SELECT BBID FROM CompanyFilter)
UNION
SELECT prcp_CompanyID, prcp_UpdatedDate
  FROM CRM.dbo.PRCompanyProfile 
 WHERE prcp_CompanyID in (SELECT BBID FROM CompanyFilter)
UNION
SELECT prfs_CompanyID, prfs_UpdatedDate
  FROM CRM.dbo.PRFinancial
 WHERE prfs_CompanyID in (SELECT BBID FROM CompanyFilter)
UNION
SELECT peli_CompanyID, peli_UpdatedDate
  FROM CRM.dbo.Person_Link
 WHERE peli_CompanyID in (SELECT BBID FROM CompanyFilter)
UNION
SELECT peli_CompanyID, pers_UpdatedDate
  FROM CRM.dbo.Person_Link INNER JOIN
       CRM.dbo.Person on peli_PersonID = pers_PersonID
 WHERE peli_CompanyID in (SELECT BBID FROM CompanyFilter)
UNION
SELECT phon_CompanyID, phon_UpdatedDate
  FROM CRM.dbo.Phone
 WHERE phon_CompanyID in (SELECT BBID FROM CompanyFilter)
UNION
SELECT prra_CompanyID, prra_UpdatedDate
  FROM CRM.dbo.PRRating
 WHERE prra_CompanyID in (SELECT BBID FROM CompanyFilter)
UNION
SELECT prra_CompanyID, pran_UpdatedDate
  FROM CRM.dbo.PRRating INNER JOIN
       CRM.dbo.PRRatingNumeralAssigned ON prra_RatingID = pran_RatingID
 WHERE prra_CompanyID in (SELECT BBID FROM CompanyFilter)
) Table1
GROUP BY BBID;

-- Now look at the DeleteDection table and update our
-- ChangeDetection appropriately.  The DeleteDetection is populated
-- via delete triggers on specific PIKS tables.
UPDATE ChangeDetection
   SET LastUpdatedDateTime = T1.DeleteDateTime
  FROM (SELECT BBID, MAX(DeleteDateTime) AS DeleteDateTime
          FROM DeleteDetection
      GROUP BY BBID) AS T1
 WHERE ChangeDetection.BBID = T1.BBID
   AND LastUpdatedDateTime < T1.DeleteDateTime;

PRINT 'usp_PopulateChangeDetection Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))
Go