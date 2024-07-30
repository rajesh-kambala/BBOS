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

-- 1 = PIKS-to-BBS
-- 2 = BBS-to-PIKS


/**

**/
If Exists (Select name from sysobjects where name = 'usp_StartInterface' and type='P') Drop Procedure dbo.usp_StartInterface
Go

CREATE PROCEDURE dbo.usp_StartInterface 
	@InterfaceID int,
    @Notes varchar(5000) = NULL
AS

	INSERT INTO InterfaceStatus (
		[InterfaceID],
		[IsExecuting],
		[StartDateTime],
		[UserID],
        [Notes])
	VALUES (@InterfaceID,
			1,
			GETDATE(),
			SUSER_NAME(),
            @Notes);
Go


/**

**/
If Exists (Select name from sysobjects where name = 'usp_FinishInterface' and type='P') Drop Procedure dbo.usp_FinishInterface
Go

CREATE PROCEDURE dbo.usp_FinishInterface 
	@InterfaceID int
AS
	DECLARE @ID int

	-- Make sure we update the most recent
	-- executing record.  There may be multiple
	-- due to errors.
	SELECT @ID = MAX(ID)
	  FROM InterfaceStatus
     WHERE InterfaceID = @InterfaceID
       AND IsExecuting = 1;


	UPDATE InterfaceStatus
	   SET IsExecuting = 0,
           EndDateTime = GETDATE()
     WHERE ID = @ID;
Go