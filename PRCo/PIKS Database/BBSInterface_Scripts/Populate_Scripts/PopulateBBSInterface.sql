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
If Exists (Select name from sysobjects where name = 'usp_PopulateBBSInterface' and type='P') Drop Procedure dbo.usp_PopulateBBSInterface
Go

/**
Populates the BBSInterface database from PIKS
**/
CREATE PROCEDURE dbo.usp_PopulateBBSInterface
    @AllCompanies bit = 1,
	@IncludeListingFields bit = 1,
    @CompanyIDs varchar(3000) = ''
as 

DECLARE @Notes varchar(5000)
SET @Notes = 'Parameters: ' + CAST(@AllCompanies as varchar(1)) + ', ' + CAST(@IncludeListingFields as varchar(1)) + ', ''' + @CompanyIDs + ''''
EXEC usp_StartInterface 1, @Notes

-- Build a table of CompanyIDs to control what companies are
-- included in the data download.
DELETE FROM CompanyFilter;

IF @AllCompanies = 1 BEGIN
	INSERT INTO CompanyFilter SELECT comp_CompanyID from CRM.dbo.Company WHERE comp_PRListingStatus IN ('L','H','LUV','N1','N2');
END ELSE BEGIN

	IF @CompanyIDs IS NULL BEGIN
	    RAISERROR ('Invalid CompanyIDs Value.', 1, 1)
		RETURN -1
	END

	IF LEN(@CompanyIDs) = 0 BEGIN
	    RAISERROR ('Invalid CompanyIDs Value.', 1, 1)
		RETURN -1
	END

	INSERT INTO CompanyFilter SELECT Value FROM CRM.dbo.Tokenize(@CompanyIDs, ',');
END

EXEC usp_PopulateListing
EXEC usp_PopulateAddress;
EXEC usp_PopulatePhone;
EXEC usp_PopulateInternet;
EXEC usp_PopulatePubAddr;

-- These supporting tables are only needed
-- when pulling down data for the full listings
IF @IncludeListingFields = 1 BEGIN
	EXEC usp_PopulateAffil;
	--EXEC usp_PopulateBrands;
	--EXEC usp_PopulateClassIf;
	--EXEC usp_PopulateCommod;
	--EXEC usp_PopulateLicense;
	--EXEC usp_PopulatePersaff;
	--EXEC usp_PopulatePerson;
	--EXEC usp_PopulateRating;
	--EXEC usp_PopulateSupply;
END

-- Only worry about these if we're executing
-- a full synchronization
IF @AllCompanies = 1 BEGIN
	--EXEC usp_PopulateClassVal;
	--EXEC usp_PopulateCmdVal;
	--EXEC usp_PopulateSuppval;
    EXEC usp_PopulateTowns;

	EXEC usp_PopulateChangeDetection;
END



EXEC usp_FinishInterface 1
Go