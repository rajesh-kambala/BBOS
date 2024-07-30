/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co. 2010

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
USE BBSInterface

If Exists (Select name from sysobjects where name = 'usp_PopulatePubAddr' and type = 'P') 
    Drop Procedure dbo.usp_PopulatePubAddr
GO

/**
Updates the PubAddr Table
**/
CREATE PROCEDURE dbo.usp_PopulatePubAddr
AS
BEGIN
	DECLARE @Start datetime
	SET @Start = GETDATE()

	PRINT 'Deleting From PubAddr Table'
	DELETE FROM PubAddr;

	PRINT 'Populating PubAddr Data'


	INSERT INTO PubAddr
		(SVCID, PUBTYPE, STARTMMDD, HOW, INCLUDE, ATTN, ADDRID, EXC)
	SELECT prattn_ServiceID As SvcID,
		   CASE 
				WHEN prattn_ItemCode = 'CSUPD' THEN 'CS'
				WHEN prattn_ItemCode = 'EXUPD' AND prattn_PhoneID IS NOT NULL THEN 'FAX'
				WHEN prattn_ItemCode = 'EXUPD' AND prattn_EmailID IS NOT NULL THEN 'XP'
				WHEN prattn_ItemCode = 'BOOK' THEN 'BB'
				WHEN prattn_ItemCode = 'BPRINT' THEN 'BP'
				ELSE '****' + prattn_ItemCode
			END As PubType,
			'0101' As StartMMDD,
			CASE 
				WHEN prattn_AddressID IS NOT NULL AND prattn_ItemCode = 'BOOK' THEN 'S'
				WHEN prattn_AddressID IS NOT NULL AND prattn_ItemCode <> 'BOOK' THEN 'M'
				WHEN prattn_EmailID IS NOT NULL THEN 'E'
				WHEN prattn_PhoneID IS NOT NULL THEN 'F'
			END As How,
			CASE prattn_Disabled WHEN 'Y' THEN 'N' ELSE 'Y' END As Include,
			Addressee As Attn,
			ISNULL(ISNULL(adli_PRSlot, phon_PRSlot), emai_PRSlot) As addrid,
			'Y' As Exception
	  FROM CRM.dbo.vPRCompanyAttentionLine
	  WHERE prattn_ServiceID IS NOT NULL
	ORDER BY prattn_ServiceID;


	PRINT 'usp_PopulatePubAddr Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))
END
GO
