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
If Exists (Select name from sysobjects where name = 'usp_PopulatePerson' and type='P') Drop Procedure dbo.usp_PopulatePerson
Go

/**
Populates the Person table from PIKS
**/
CREATE PROCEDURE dbo.usp_PopulatePerson
AS 

DECLARE @Start datetime
SET @Start = GETDATE()

PRINT 'Deleting From Person Table'
DELETE FROM Person;

-- We truncate many of the name fields because the PIKS definitions are larger
-- than the BBS definitions.  The decision was made to leave both systems as is
-- and handle it in the interface.  No data at creation time exceeds the BBS
-- field sizes.
PRINT 'Populating Person Data'
INSERT INTO Person (
       PERSONID,
       FIRSTNAME,
       NICKNAME,
       MIDDLENAME,
       LASTNAME,
       AFTERNAME,
       FULLNAME,
       FULLNICKNAME,
       GENDER)
SELECT Pers_PersonID,  -- PERSONID 
	   SUBSTRING(RTRIM(Pers_FirstName),1 ,20),  -- FIRSTNAME
	   RTRIM(Pers_PRNickname1), -- NICKNAME
	   SUBSTRING(RTRIM(Pers_MiddleName),1 , 20), -- MIDDLENAME
	   SUBSTRING(RTRIM(Pers_LastName),1 , 35),  -- LASTNAME
	   SUBSTRING(RTRIM(Pers_Suffix),1 , 8), -- AFTERNAME
	   dbo.ufn_GetFullName(Pers_FirstName, Pers_PRNickname1, Pers_MiddleName, Pers_LastName, Pers_Suffix),
	   REPLACE(ISNULL(RTRIM(Pers_PRNickname1), SUBSTRING(RTRIM(Pers_FirstName),1 ,20))
		  + ' ' + SUBSTRING(RTRIM(Pers_LastName),1 , 35) -- FULLNICKNAME
		  + CASE WHEN Pers_Suffix IS NOT NULL THEN ' ' + SUBSTRING(RTRIM(Pers_Suffix),1 , 8) ELSE '' END, ' ,', ','),
	   SUBSTRING(Pers_Gender, 1, 1) -- GENDER
  FROM CRM.dbo.Person INNER JOIN
       CRM.dbo.Person_Link ON pers_PersonID = peli_PersonID
 WHERE pers_Deleted IS NULL
   AND peli_Deleted IS NULL
   AND peli_CompanyID IN (SELECT BBID FROM CompanyFilter);

PRINT 'usp_PopulatePerson Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))
Go