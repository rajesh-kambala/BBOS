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

If Exists (Select name from sysobjects where name = 'usp_PopulatePRServiceAlaCarte' and type='P') Drop Procedure dbo.usp_PopulatePRServiceAlaCarte
Go

/**
Updates the PRServiceAlaCarte Table
**/
CREATE PROCEDURE [dbo].[usp_PopulatePRServiceAlaCarte]
	@SuppressTaskCreation bit = 0
AS

DECLARE @Start datetime
SET @Start = GETDATE()

DECLARE @LastMaxPurchaseDate datetime, @CurrentMaxPurchaseDate datetime, @PRServiceAlaCarteID int
DECLARE @CurrentDate DateTime, @CreatedUserID int, @AssignedToUserID int
DECLARE @LineBreak varchar(10)
DECLARE @City varchar (100), @State varchar(100)

SET @LineBreak = '<BR>'
SET @CreatedUserID = CRM.dbo.ufn_GetSystemUserId(0)
SET @CurrentDate = GETDATE()
SET @CurrentMaxPurchaseDate = GETDATE()

-- Determine what our last maximum purchase date processed was
SELECT @LastMaxPurchaseDate = ISNULL(MAX([prsac_PurchaseDate]), '1900-01-01')
  FROM CRM.dbo.PRServiceAlaCarte;

-- Determine what the current maximum purchase date is
SELECT @CurrentMaxPurchaseDate = MAX(CAST(PurchaseDate as datetime)) FROM OPENROWSET(BULK 'D:\Applications\BBSInterface\Report3.txt', FORMATFILE='D:\Applications\BBSInterface\Format\Report3.fmt') As Report3;

-- Do we have any new records?
IF @CurrentMaxPurchaseDate > @LastMaxPurchaseDate BEGIN

	-- Add one (1) second to our last purchase date so we can
	-- have an inclusive range.
	SET @LastMaxPurchaseDate = DATEADD(s, 1, @LastMaxPurchaseDate)

	DECLARE @PRServiceAlaCarte table(
			[ID] [int] identity(1,1),
			[prsac_ID] int,
			[prsac_NonmemberUsageID] [int],
			[prsac_PurchaseType] [nvarchar](40),
			[prsac_PurchaseDate] [datetime],
			[prsac_RefNum] [nvarchar](50),
			[prsac_Amount] [numeric](24, 6),
			[prsac_IPAddress] [nvarchar](15),
			[prsac_CreditCardNumber] [nvarchar](4),
			[prsac_CreditCardType] [nvarchar](40),
			[prsac_ExpirationDateMonth] [int],
			[prsac_ExpirationDateYear] [int],
			[prsac_BBID] [nvarchar](1),
			[prsac_FirstName] [nvarchar](17),
			[prsac_MI] [nvarchar](1),
			[prsac_LastName] [nvarchar](19),
			[prsac_CompanyName] [nvarchar](48),
			[prsac_Address1] [nvarchar](35),
			[prsac_Address2] [nvarchar](35),
			[prsac_City] [nvarchar](25),
			[prsac_County] [nvarchar](1),
			[prsac_State] [nvarchar](11),
			[prsac_Country] [nvarchar](36),
			[prsac_PostalCode] [nvarchar](10),
			[prsac_Phone] [nvarchar](19),
			[prsac_Fax] [nvarchar](19),
			[prsac_Email] [nvarchar](36),
			[prsac_WebSite] [nvarchar](29),
			[prsac_JobTitle] [nvarchar](42),
			[prsac_Classification] [nvarchar](14),
			[prsac_CompanySize] [nvarchar](10),
			[prsac_AutoEmail] [nvarchar](5),
			[prsac_UnitAllocationID] [nvarchar](1),
			[prsac_PurchaseTerms] [nvarchar](8),
			[prsac_LearnedText] [nvarchar](82),
			[prsac_UsageType] [nvarchar](1),
			[prsac_SubjectBBID] [int],
			[prsac_Field037] [nvarchar](255),
			[prsac_MLCount] [int],
			[prsac_UsageLevel] [nvarchar](1))

	DECLARE @RowCount int, @Index int, @TaskNotes varchar(5000)

	-- Go get our set of data.	
	INSERT INTO @PRServiceAlaCarte (
		prsac_ID,
		prsac_NonmemberUsageID,
		prsac_PurchaseType,
		prsac_PurchaseDate,
		prsac_RefNum,
		prsac_Amount,
		prsac_IPAddress,
		prsac_CreditCardNumber,
		prsac_CreditCardType,
		prsac_ExpirationDateMonth,
		prsac_ExpirationDateYear,
		prsac_BBID,
		prsac_FirstName,
		prsac_MI,
		prsac_LastName,
		prsac_CompanyName,
		prsac_Address1,
		prsac_Address2, 
		prsac_City,
		prsac_County,
		prsac_State,
		prsac_Country,
		prsac_PostalCode,
		prsac_Phone,
		prsac_Fax,
		prsac_Email,
		prsac_WebSite,
		prsac_JobTitle,
		prsac_Classification,
		prsac_CompanySize,
		prsac_AutoEmail,
		prsac_UnitAllocationID,
		prsac_PurchaseTerms,
		prsac_LearnedText,
		prsac_UsageType,
		prsac_SubjectBBID,
		prsac_Field037,
		prsac_MLCount,
		prsac_UsageLevel)
 SELECT ID,
		NonmemberUsageID,
		PurchaseType,
		PurchaseDate,
		RefNum,
		Amount,
		IP,
		CreditCardNumber,
		CreditCardType,
		ExpirationDateMonth,
		ExpirationDateYear,
		BBID,
		FirstName,
		MI,
		LastName,
		CompanyName,
		Address1,
		Address2, 
		City,
		County,
		[State],
		Country,
		PostalCode,
		Phone,
		Fax,
		Email,
		WebSite,
		JobTitle,
		Classification,
		CompanySize,
		AutoEmail,
		UnitAllocationID,
		PurchaseTerms,
		LearnedText,
		UsageType,
		SubjectBBID,
		Field037,
		MLCount,
		UsageLevel
     FROM OPENROWSET(BULK 'D:\Applications\BBSInterface\Report3.txt', FORMATFILE='D:\Applications\BBSInterface\Format\Report3.fmt') As Report3  WHERE CAST(PurchaseDate as datetime) BETWEEN @LastMaxPurchaseDate AND @CurrentMaxPurchaseDate;
	SET @RowCount = @@ROWCOUNT
	
	SET @Index = 1
	WHILE (@Index <= @RowCount) BEGIN

		EXEC CRM.dbo.usp_getNextId 'PRServiceAlaCarte', @PRServiceAlaCarteID Output

		-- Insert our record into the PIKS 
		-- Ala Carte order table
		INSERT INTO CRM.dbo.PRServiceAlaCarte 
		SELECT 	@PRServiceAlaCarteID,
				NULL,
				NULL,
				NULL,
				@CreatedUserID,
				@CurrentDate,
				@CreatedUserID,
				@CurrentDate,
				@CurrentDate,
			    prsac_ID,
				prsac_NonmemberUsageID,
				prsac_PurchaseType,
				prsac_PurchaseDate,
				prsac_RefNum,
				prsac_Amount,
				prsac_IPAddress,
				prsac_CreditCardNumber,
				prsac_CreditCardType,
				prsac_ExpirationDateMonth,
				prsac_ExpirationDateYear,
				prsac_BBID,
				prsac_FirstName,
				prsac_MI,
				prsac_LastName,
				prsac_CompanyName,
				prsac_Address1,
				prsac_Address2,
				prsac_City,
				prsac_County,
				prsac_State,
				prsac_Country,
				prsac_PostalCode,
				prsac_Phone,
				prsac_Fax,
				prsac_Email,
				prsac_WebSite,
				prsac_JobTitle,
				prsac_Classification,
				prsac_CompanySize,
				prsac_AutoEmail,
				prsac_UnitAllocationID,
				prsac_PurchaseTerms,
				prsac_LearnedText,
				prsac_UsageType,
				prsac_SubjectBBID,
				prsac_Field037,
				prsac_MLCount,
				prsac_UsageLevel
		  FROM @PRServiceAlaCarte WHERE [ID] = @Index;

	   IF (@SuppressTaskCreation = 0) BEGIN

		-- Now create a task for the user to follow
		-- up with this person making the request
		SELECT	@TaskNotes = 'Ala Carte Order placed by the following company:' + @LineBreak +
                            'Reference Number: ' + prsac_RefNum + @LineBreak +
							ISNULL(prsac_FirstName, '') + ' ' + ISNULL(prsac_LastName, '') + @LineBreak +
							ISNULL(prsac_CompanyName, '') + @LineBreak +
							ISNULL(prsac_Address1, '') + @LineBreak +
							ISNULL(prsac_Address2, '') + @LineBreak +
							ISNULL(prsac_City, '') + ' ' + ISNULL(prsac_State, '') + ', ' + ISNULL(prsac_PostalCode, '') + @LineBreak +
							ISNULL(prsac_Country, '') + @LineBreak +
							ISNULL(prsac_Phone, '') + @LineBreak +
							ISNULL(prsac_Email, '') + @LineBreak +
							ISNULL(prsac_WebSite, '') + @LineBreak +
							'Auto Email: ' + ISNULL(prsac_AutoEmail, '') + @LineBreak +
							'Usage Level: ' + ISNULL(prsac_UsageLevel, '')
		  FROM @PRServiceAlaCarte WHERE [ID] = @Index;
	
		SELECT @City = prsac_City, 
			   @State = prsac_State
		  FROM @PRServiceAlaCarte WHERE [ID] = @Index;
		SET @AssignedToUserID = CRM.dbo.ufn_GetInsideSalesRepForAddress(@City, @State)

		EXEC CRM.dbo.usp_CreateTask @CurrentDate, 
									@CurrentDate, 
									@CreatedUserID, 
									@AssignedToUserID,
									@TaskNotes,
									NULL,
									NULL,
									'Pending';
		END

		SET @Index = @Index + 1

	END
END

PRINT 'usp_PopulatePRServiceAlaCarte Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))

Go