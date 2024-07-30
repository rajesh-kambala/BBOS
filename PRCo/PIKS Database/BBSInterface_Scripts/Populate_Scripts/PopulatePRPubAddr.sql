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


If Exists (Select name from sysobjects where name = 'usp_PopulatePRPubAddr' and type='P') Drop Procedure dbo.usp_PopulatePRPubAddr
Go

/**
Updates the PRPubAddr
**/
CREATE PROCEDURE dbo.usp_PopulatePRPubAddr
AS

DECLARE @Start datetime
SET @Start = GETDATE()

	PRINT 'Deleting From PRPubAddr Table'
	DELETE FROM CRM.dbo.PRPubAddr;

	PRINT 'Populating PRPubAddr Data'
	INSERT INTO CRM.dbo.PRPubAddr (
		puba_svcid,
		puba_pubtype,
		puba_startmmdd,
		puba_how,
		puba_include,
		puba_attn,
		puba_addrid,
		puba_exc)
	SELECT SVCID, PUBTYPE, STARTMMDD, HOW, [INCLUDE], ATTN, ADDRID, EXC
      FROM OPENROWSET(Bulk 'D:\Applications\BBSInterface\PubAddr.txt', FormatFile='D:\Applications\BBSInterface\Format\PubAddr.fmt') As PubAddr

PRINT 'usp_PopulatePRPubAddr Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))
Go



