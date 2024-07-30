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


/* 
   Determines if the specified Service ID exists
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_IsPubAddrExists]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_IsPubAddrExists]
GO
CREATE FUNCTION dbo.ufn_IsPubAddrExists(@SvcID int,
                                        @PubType varchar(5),
                                        @StartMMDD varchar(4))
RETURNS bit  AS  
BEGIN 
	DECLARE @Exists bit
	SET @Exists = 0

	SELECT @Exists = 1 
      FROM CRM.dbo.PRPubAddr 
     WHERE puba_SVCID     = @SvcID
       AND puba_PubType   = @PubType
       AND puba_StartMMDD = @StartMMDD;

	RETURN @Exists
END
GO



If Exists (Select name from sysobjects where name = 'usp_PopulatePRPubAddrRT' and type='P') Drop Procedure dbo.usp_PopulatePRPubAddrRT
Go

/**
Updates the Service Table with the specified values
**/
CREATE PROCEDURE dbo.usp_PopulatePRPubAddrRT
	@ActionCode int, -- 0:Add, 1:Update, 2:Delete
	@SvcID int,
	@PubType varchar(5),
    @StartMMDD varchar(4),
    @How varchar(1),
	@Include varchar(1),
	@Attn varchar(44),
	@AddrID smallint,
	@Exc varchar(1)
AS

DECLARE @Start datetime
SET @Start = GETDATE()

-- Determine if our record already exists
DECLARE @Exists bit
SET @Exists = dbo.ufn_IsPubAddrExists(@SvcID, @PubType, @StartMMDD);

-- Add
IF @ActionCode = 0 BEGIN
	Print 'Add Record'

	IF @Exists = 1 BEGIN
	    RAISERROR ('Cannot add record.  Specified SvcID, PutType, and StartMMDD already exists.', 1, 1)
		RETURN -1
	END	


	INSERT INTO CRM.dbo.PRPubAddr 
	   (puba_SvcID, 
        puba_PubType, 
		puba_StartMMDD,
		puba_How,
		puba_Include,
		puba_Attn,
		puba_AddrID,
		puba_Exc)
	VALUES 
	   (@SvcID,
		@PubType,
		@StartMMDD,
		@How,
		@Include,
		@Attn,
		@AddrID,
		@Exc);

-- Update
END ELSE IF @ActionCode = 1 BEGIN
	Print 'Update Record'

	IF @Exists = 0 BEGIN
	    RAISERROR ('Cannot update record.  Specified SvcID, PutType, and StartMMDD does not exist.', 1, 1)
		RETURN -1
	END	

	UPDATE CRM.dbo.PRPubAddr SET 
		puba_How       = @How,
		puba_Include   = @Include,
		puba_Attn      = @Attn,
		puba_AddrID    = @AddrID, 
		puba_Exc       = @Exc
     WHERE puba_SVCID     = @SvcID
       AND puba_PubType   = @PubType
       AND puba_StartMMDD = @StartMMDD;


-- Delete
END ELSE IF @ActionCode = 2 BEGIN
	Print 'Delete Record'

	IF @Exists = 0 BEGIN
	    RAISERROR ('Cannot delete record.  Specified SvcID, PutType, and StartMMDD does not exist.', 1, 1)
		RETURN -1
	END	

	DELETE FROM CRM.dbo.PRPubAddr
     WHERE puba_SVCID     = @SvcID
       AND puba_PubType   = @PubType
       AND puba_StartMMDD = @StartMMDD;


-- Invalid
END ELSE BEGIN
	Print 'Invalid Action Code'

    RAISERROR ('Invalid action code specified.', 1, 1)
	RETURN -1
END


PRINT 'usp_PopulatePRPubAddrRT Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))
Go



