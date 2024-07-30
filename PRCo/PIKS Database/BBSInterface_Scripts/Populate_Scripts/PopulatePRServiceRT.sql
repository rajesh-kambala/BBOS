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
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_IsServiceExists]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_IsServiceExists]
GO
CREATE FUNCTION dbo.ufn_IsServiceExists(@ServiceID int)
RETURNS bit  AS  
BEGIN 
	DECLARE @Exists bit
	SET @Exists = 0

	SELECT @Exists = 1 FROM CRM.dbo.PRService WHERE prse_ServiceID = @ServiceID;
	RETURN @Exists
END
GO



If Exists (Select name from sysobjects where name = 'usp_PopulatePRServiceRT' and type='P') Drop Procedure dbo.usp_PopulatePRServiceRT
Go

/**
Updates the Service Table
**/
CREATE PROCEDURE dbo.usp_PopulatePRServiceRT
	@ActionCode int, -- 0:Add, 1:Update, 2:Delete
	@ServiceID int,
	@BBID int,
    @ServiceType varchar(40),
    @BillToBBID int,
	@InitDate datetime,
	@StartDate datetime,
	@BillDate datetime,
	@ExpDate datetime
AS

DECLARE @Start datetime
SET @Start = GETDATE()

-- Determine if our ServiceID already exists
DECLARE @Exists bit
SET @Exists = dbo.ufn_IsServiceExists(@ServiceID);

-- Add
IF @ActionCode = 0 BEGIN
	Print 'Add Record'

	IF @Exists = 1 BEGIN
	    RAISERROR ('Cannot add record.  Specified PRCoServiceID already exists.', 1, 1)
		RETURN -1
	END	

	DECLARE @ID int
	EXEC CRM.dbo.usp_GetNextID 'PRService', @Return = @ID OUTPUT

	INSERT INTO CRM.dbo.PRService 
	   (prse_ServiceID, 
        prse_CreatedBy, 
		prse_CreatedDate,
		prse_UpdatedBy,
		prse_UpdatedDate,
		prse_TimeStamp,
		prse_CompanyId,
		prse_ServiceCode,
		prse_ServiceSubCode,
		prse_Primary,
		prse_CodeStartDate,
		prse_NextAnniversaryDate,
		prse_CodeEndDate,
		prse_StopServiceDate,
		prse_ServiceSinceDate,
		prse_InitiatedBy,
		prse_BillToCompanyId,
		prse_CancelCode,
		prse_Terms,
		prse_HoldShipmentId,
		prse_HoldMailId,
		prse_EBBSerialNumber,
		prse_ContractOnHand,
		prse_DeliveryMethod,
		prse_ReferenceNumber,
		prse_ShipmentDate,
		prse_ShipmentDescription,
		prse_Description,
		prse_ServicePrice,
		prse_UnitsPackaged)
	VALUES 
	   (@ID,
		CRM.dbo.ufn_GetSystemUserId(0),
		GetDate(),
		CRM.dbo.ufn_GetSystemUserId(0),
		GetDate(),
		GetDate(),
		@BBID,
		@ServiceType,
		null, 
		null,
		@StartDate,
		@BillDate,
		null, 
		@ExpDate,
		@InitDate,
		null, 
		@BillToBBID,
		null,    
		null,
		null, 
		null,
		null, 
		null,
		null, 
		null,
		null, 
		null,
		null, 
		null,
		null);

-- Update
END ELSE IF @ActionCode = 1 BEGIN
	Print 'Update Record'

	IF @Exists = 0 BEGIN
	    RAISERROR ('Cannot update record.  Specified PRCoServiceID does not exist.', 1, 1)
		RETURN -1
	END	

	UPDATE CRM.dbo.PRService SET 
		prse_UpdatedBy = CRM.dbo.ufn_GetSystemUserId(0),
		prse_UpdatedDate = GetDate(),
		prse_TimeStamp = GetDate(),
		prse_CompanyId = @BBID,
		prse_ServiceCode = @ServiceType,
		prse_ServiceSubCode = null, 
		prse_Primary = null,
		prse_CodeStartDate = @StartDate,
		prse_NextAnniversaryDate = @BillDate,
		prse_CodeEndDate = null, 
		prse_StopServiceDate = @ExpDate,
		prse_ServiceSinceDate = @InitDate,
		prse_InitiatedBy = null, 
		prse_BillToCompanyId = @BillToBBID,
		prse_CancelCode = null,    
		prse_Terms = null,
		prse_HoldShipmentId = null, 
		prse_HoldMailId = null,
		prse_EBBSerialNumber = null, 
		prse_ContractOnHand = null,
		prse_DeliveryMethod = null, 
		prse_ReferenceNumber = null,
		prse_ShipmentDate = null, 
		prse_ShipmentDescription = null,
		prse_Description = null, 
		prse_ServicePrice = null,
		prse_UnitsPackaged = null 
	WHERE prse_ServiceID = @ServiceID;

-- Delete
END ELSE IF @ActionCode = 2 BEGIN
	Print 'Delete Record'

	IF @Exists = 0 BEGIN
	    RAISERROR ('Cannot delete record.  Specified ServiceID does not exist.', 1, 1)
		RETURN -1
	END	

	DELETE FROM CRM.dbo.PRService
    WHERE prse_ServiceID = @ServiceID;

-- Invalid
END ELSE BEGIN
	Print 'Invalid Action Code'

    RAISERROR ('Invalid action code specified.', 1, 1)
	RETURN -1
END


PRINT 'usp_PopulatePRServiceRT Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))
Go



