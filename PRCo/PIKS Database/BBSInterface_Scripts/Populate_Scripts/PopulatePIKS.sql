/***********************************************************************
***********************************************************************
 Copyright Produce Report Co. 2006-2010

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

If Exists (Select name from sysobjects where name = 'usp_PopulatePIKS' and type='P') Drop Procedure dbo.usp_PopulatePIKS
Go

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO

/**
Updates the PIKS database from the BBSInterface tables
**/
CREATE PROCEDURE [dbo].[usp_PopulatePIKS]
	@SuppressTaskCreation bit = 0
AS

EXEC usp_StartInterface 2


DECLARE @Start datetime
SET @Start = GETDATE()

EXEC usp_PopulatePRService @SuppressTaskCreation;

-- Note: usp_PopulatePRServicePayment requires that 
-- usp_PopulatePRService is executed first.
EXEC usp_PopulatePRServicePayment; 

EXEC usp_PopulateCompany;
EXEC usp_PopulatePRServiceAlaCarte @SuppressTaskCreation;

EXEC usp_FinishInterface 2

PRINT 'usp_PopulatePIKS Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))

Go