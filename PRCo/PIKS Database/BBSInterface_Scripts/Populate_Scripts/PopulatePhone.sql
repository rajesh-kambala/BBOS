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
If Exists (Select name from sysobjects where name = 'usp_PopulatePhone' and type='P') Drop Procedure dbo.usp_PopulatePhone
Go

/**
Populates the Phone table from PIKS
**/
CREATE PROCEDURE dbo.usp_PopulatePhone
as 

PRINT 'Deleting From Phone Table'
DELETE FROM Phones;

PRINT 'Populating Phone Data'
INSERT INTO Phones (
       BBID,
       SEQ,
       PHONETYPE,
       PHONE,
       LIST,
       LISTSEQ,
       DEFFAX,
       DEFPHONE,
       AREACODE,
       COUNTRYCODE)
SELECT phon_CompanyID,
       phon_PRSlot,
       CASE phon_Type 
			WHEN 'F' THEN 'FAX' 
			WHEN 'P' THEN 'PHONE' 
			WHEN 'PA' THEN 'PAGER'
			WHEN 'PF' THEN 'PHONEFAX' 
			WHEN 'S'  THEN 'SLS' 
			WHEN 'SF' THEN 'SLSFAX'
			WHEN 'TF' THEN 'TOLLFREE'
            WHEN 'TP' THEN 'TRUCKER'
	   END,
       CRM.dbo.ufn_FormatPhone(RTRIM(Phon_CountryCode), 
                               RTRIM(Phon_AreaCode), 
                               RTRIM(Phon_Number), 
                               RTRIM(phon_PRExtension)),
       ISNULL(phon_PRPublish, 'N'),
       CRM.dbo.ufn_GetListingPhoneSeq(phon_Type, phon_PRSequence),
       CASE WHEN phon_PRIsFax = 'Y' AND phon_PRPreferredInternal='Y' THEN 'X' ELSE NULL END,
	   CASE WHEN phon_PRIsPhone = 'Y' AND phon_PRPreferredInternal='Y' THEN 'X' ELSE NULL END,
       RTRIM(Phon_AreaCode),
       RTRIM(Phon_CountryCode)
  FROM CRM.dbo.Phone INNER JOIN 
       CRM.dbo.Company ON phon_CompanyID = comp_CompanyID
 WHERE phon_Deleted IS NULL
   AND comp_Deleted IS NULL
   AND phon_PersonID IS NULL
   AND comp_CompanyID IN (SELECT BBID FROM CompanyFilter);
Go
