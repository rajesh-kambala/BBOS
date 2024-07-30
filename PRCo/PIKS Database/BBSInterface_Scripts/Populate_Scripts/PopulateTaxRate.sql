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

If Exists (Select name from sysobjects where name = 'usp_PopulateTaxRate' and type='P') 
	Drop Procedure dbo.usp_PopulateTaxRate
Go

/**
Updates the Company Table
**/
CREATE PROCEDURE dbo.usp_PopulateTaxRate
AS
BEGIN
	DECLARE @Start datetime
	SET @Start = GETDATE()

	PRINT 'Updating Tax Rate Data'
	-- delete all from the current table
	DELETE FROM CRM.dbo.PRTaxRate

	-- Now just insert based upon all the rows in BBS.DPCTax.db
	-- Note that the trigger on PRTaxRate will assign a key if one is not passed
    INSERT INTO CRM.dbo.PRTaxRate
	    (prtax_State, prtax_PostalCode, prtax_County, prtax_City, prtax_Indicator, prtax_TaxRate, 
	     prtax_Default, prtax_CntyDef, prtax_Def, 
	     prtax_CreatedBy, prtax_UpdatedBy, prtax_CreatedDate, prtax_UpdatedDate, prtax_Timestamp)
	    SELECT [State], Zip, County, City, Indicator, SalesTax,
	     [Default], CntyDef, Def, 
	     -700, -700, getDate(), getDate(), getDate() FROM OPENROWSET(BULK 'D:\Applications\BBSInterface\Dpctax.txt', FORMATFILE='D:\Applications\BBSInterface\Format\Dpctax.fmt') As Dpctax

	PRINT 'usp_PopulateTaxRate Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))
END
Go