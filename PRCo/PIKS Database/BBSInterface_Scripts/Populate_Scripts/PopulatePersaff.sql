/***********************************************************************
***********************************************************************
 Copyright Produce Report Co. 2006-2009

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
If Exists (Select name from sysobjects where name = 'usp_PopulatePersAff' and type='P') Drop Procedure dbo.usp_PopulatePersAff
Go

/**
Populates the persaff table from PIKS
**/
CREATE PROCEDURE [dbo].[usp_PopulatePersAff]
as 
Declare @Start datetime
SET @Start = GETDATE()
PRINT 'Deleting From Persaff Table'
DELETE FROM persaff;
PRINT 'Populating Persaff Data'
INSERT INTO persaff (
       BBID,
       PERSONID,
       STATUS,
       TITLE,
       SHARE,
       PRESIDENT,
       TREASURER,
       SALES,
       MARKETING,
       OPERATIONS,
       INFORMATION,
       CREDIT,
       BUYER,
       DISPATCHER,
       WEBPASSWORD,
       WEBSTATUS,
       LISTSEQ,
       LISTYN)
SELECT peli_CompanyID, -- BBID
       peli_PersonID, -- PERSONID
       CASE RTRIM(peli_PRStatus) WHEN 1 THEN 'A' WHEN 2 THEN 'I' WHEN 3 THEN 'N' END, -- STATUS
       PeLi_PRTitle, -- TITLE
       REPLACE(RTRIM(REPLACE(REPLACE(LTRIM(RTRIM(REPLACE(CONVERT(varchar(25), PeLi_PRPctOwned),'0',' '))),' ','0'),'.',' ')),' ','.'), -- SHARE
       CASE WHEN CHARINDEX(',HE,', peli_PRRole) > 0 THEN 'X' ELSE NULL END AS President, -- PRESIDENT
       CASE WHEN CHARINDEX(',HF,', peli_PRRole) > 0 THEN 'X' ELSE NULL END AS Treasurer, -- TREASURER
       CASE WHEN CHARINDEX(',HS,', peli_PRRole) > 0 THEN 'X' ELSE NULL END AS Sales, -- SALES
       CASE WHEN CHARINDEX(',HM,', peli_PRRole) > 0 THEN 'X' ELSE NULL END AS Marketing, -- MARKETING
       CASE WHEN CHARINDEX(',HO,', peli_PRRole) > 0 THEN 'X' ELSE NULL END AS Operations, -- OPERATIONS
	   CASE WHEN CHARINDEX(',HI,', peli_PRRole) > 0 THEN 'X' ELSE NULL END AS Information, -- INFORMATION
       CASE WHEN CHARINDEX(',HC,', peli_PRRole) > 0 THEN 'X' ELSE NULL END AS Credit, -- CREDIT
       CASE WHEN CHARINDEX(',HB,', peli_PRRole) > 0 THEN 'X' ELSE NULL END AS Buyer, -- BUYER
       CASE WHEN CHARINDEX(',HT,', peli_PRRole) > 0 THEN 'X' ELSE NULL END AS Dispatcher, -- DISPATCHER
       peli_WebPassword, -- WEBPASSWORD
       peli_WebStatus, -- WEBSTATUS
       capt_order, -- LISTSEQ
       ISNULL(peli_PREBBPublish, 'N') -- LISTYN
  FROM CRM.dbo.Person_Link
       INNER JOIN CRM.dbo.Person on pers_PersonId = peli_PersonId
       INNER JOIN CRM.dbo.Custom_Captions ON peli_PRTitleCode = capt_code AND capt_Family = 'pers_TitleCode'
 WHERE peli_Deleted IS NULL
   AND peli_CompanyID IN (SELECT BBID FROM CompanyFilter)
   AND peli_PRStatus in (1,2)
ORDER BY peli_CompanyId, capt_order, Pers_LastName;

PRINT 'usp_PopulatePersAff Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))
Go