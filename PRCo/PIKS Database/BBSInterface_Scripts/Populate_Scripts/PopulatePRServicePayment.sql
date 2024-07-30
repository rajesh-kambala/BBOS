/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co. 2006

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

If Exists (Select name from sysobjects where name = 'usp_PopulatePRServicePayment' and type='P') Drop Procedure dbo.usp_PopulatePRServicePayment
Go

/**
Updates the usp_PopulatePRServicePayment Table
**/
CREATE PROCEDURE dbo.usp_PopulatePRServicePayment
AS

DECLARE @Start datetime
SET @Start = GETDATE()

PRINT 'Deleting From PRServicePayment Table'
DELETE FROM CRM.dbo.PRServicePayment;

PRINT 'Populating PRServicePayment Data'

INSERT INTO CRM.dbo.PRServicePayment (
	prsp_ServicePaymentID,
	prsp_ServiceId,
	prsp_InvoiceDate,
	prsp_MasterInvoiceNumber,
	prsp_SubInvoiceNumber,
	prsp_BilledAmount,
	prsp_ReceivedAmount,
	prsp_BillingPeriodStart,
	prsp_BillingPeriodEnd,
	prsp_Tax,
	prsp_CheckNumber,
	prsp_TransactionDate,
	prsp_Activity,
	prsp_Effect,
	prsp_ServiceCode
)
SELECT KEYFIELD,SVCID,INVOICEDATE,MASTINVNO,SUBINVNO,AMOUNT,PAYAMOUNT,BILLPERSTART,BILLPEREND,TAX,CHECKNO,TRANSDATE,ACTIVITY,EFFECT,SVCCODE
  FROM OPENROWSET(BULK 'D:\Applications\BBSInterface\ServicePayment.txt', FORMATFILE='D:\Applications\BBSInterface\Format\ServicePayment.fmt') As AR


-- Calculate our Invoice balances
DECLARE @CursorStart datetime
SET @CursorStart = GETDATE()

DECLARE @ServicePaymentID int
DECLARE @MasterInvoiceNumber varchar(20), @SaveMasterInvoiceNumber varchar(20)
DECLARE @MasterInvoiceBalance numeric(24,6), @Effect numeric(24,6)

DECLARE balance_cur CURSOR LOCAL FAST_FORWARD FOR
SELECT prsp_ServicePaymentId, prsp_MasterInvoiceNumber, prsp_Effect
  FROM CRM.dbo.PRServicePayment
ORDER BY prsp_ServiceId, prsp_MasterInvoiceNumber, prsp_TransactionDate
FOR READ ONLY;

OPEN balance_cur
FETCH NEXT FROM balance_cur INTO @ServicePaymentID, @MasterInvoiceNumber, @Effect

SET @MasterInvoiceBalance = 0
SET @SaveMasterInvoiceNumber = ''

WHILE @@Fetch_Status=0
BEGIN

	IF @MasterInvoiceNumber <> @SaveMasterInvoiceNumber BEGIN
		SET @SaveMasterInvoiceNumber = @MasterInvoiceNumber 
		SET @MasterInvoiceBalance = 0
	END

	SET @MasterInvoiceBalance = @MasterInvoiceBalance + @Effect
	UPDATE CRM.dbo.PRServicePayment 
      SET prsp_Balance = @MasterInvoiceBalance,
          prsp_UpdatedDate = GETDATE(),
          prsp_UpdatedBy = CRM.dbo.ufn_GetSystemUserId(0),
          prsp_TimeStamp = GETDATE()
    WHERE prsp_ServicePaymentID=@ServicePaymentID;

	FETCH NEXT FROM balance_cur INTO @ServicePaymentID, @MasterInvoiceNumber, @Effect
END

CLOSE balance_cur
DEALLOCATE balance_cur
PRINT 'usp_PopulatePRServicePayment Balance Calculation Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @CursorStart, GETDATE()))

PRINT 'usp_PopulatePRServicePayment Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))
Go