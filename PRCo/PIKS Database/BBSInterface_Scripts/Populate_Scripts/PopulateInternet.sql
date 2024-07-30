/***********************************************************************
***********************************************************************
 Copyright Produce Report Co. 2006-2011

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
If Exists (Select name from sysobjects where name = 'usp_PopulateInternet' and type='P') Drop Procedure dbo.usp_PopulateInternet
Go

/**
Populates the Internet table from PIKS
**/
CREATE PROCEDURE dbo.usp_PopulateInternet
as 

Declare @Start datetime
SET @Start = GETDATE()

PRINT 'Deleting From Internet Table'
DELETE FROM Internet;

PRINT 'Populating Internet Data'

INSERT INTO Internet (
       BBID,
       SEQ,
       HEADER,
       INTTYPE,
       INTLOC,
       LISTSEQ,
       LIST,
       DEFEMAIL)
SELECT emai_CompanyID, -- BBID
       emai_PRSlot, -- SEQ
	   emai_PRDescription, -- HEADER
       CASE Emai_Type WHEN 'E' THEN 'EMAIL' WHEN 'W' THEN 'WEB' END, -- INTTYPE
	CASE Emai_Type WHEN 'E' THEN RTRIM(emai_EmailAddress) WHEN 'W' THEN RTRIM(emai_PRWebAddress) END, -- INITLOC
       CASE emai_Type WHEN 'W' THEN 1000 + emai_PRSequence ELSE emai_PRSequence END, -- LISTSEQ
       ISNULL(emai_PRPublish, 'N'), -- LIST
       CASE emai_PRPreferredInternal WHEN 'Y' THEN 'X' ELSE NULL END -- DEFEMAIL
  FROM CRM.dbo.Email 
 WHERE emai_CompanyID IN (SELECT BBID FROM CompanyFilter)
   AND emai_PersonID IS NULL
   AND emai_Deleted IS NULL
   AND emai_Type = 'E';

PRINT 'usp_PopulateInternet Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))
Go