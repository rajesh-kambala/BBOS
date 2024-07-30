/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co. 2007

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co. is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 Notes:	

***********************************************************************
***********************************************************************/
If Exists (Select name from sysobjects where name = 'usp_PopulateCmdVal' and type='P') Drop Procedure dbo.usp_PopulateCmdVal
Go

/**
Populates the CMDVAL table from PIKS
**/
CREATE PROCEDURE [dbo].[usp_PopulateCmdVal]
as 
Declare @Start datetime
SET @Start = GETDATE()

PRINT 'Deleting From CMDVAL Table'
DELETE FROM CMDVAL;

-- Make sure our table of all possible commodity
-- combinations is up to date
--
-- This proc is new for v2.5 as code in BBS CRM needs
-- the descriptions and translated descriptions
EXEC CRM.dbo.usp_PopulatePRCommodityTranslation

-- Now only populate our CMDVAL table with
-- those commodities that are actually in
-- use by listed companies.
INSERT INTO CMDVAL (
       COMMOD, 
       [DESC],
	   DESC_SPANISH,
	   [KEY])
SELECT DISTINCT prcx_Abbreviation,prcx_Description, prcx_Description_ES, prcx_Key
  FROM CRM.dbo.PRCommodityTranslation
	   INNER JOIN COMMOD ON prcx_Abbreviation = COMMOD.COMMOD
       INNER JOIN LISTING ON COMMOD.BBID = LISTING.BBID 
 WHERE LISTING.STATUS = 'L'
PRINT 'usp_PopulateCmdVal Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))


Go