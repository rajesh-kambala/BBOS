if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[service]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[service]
GO

CREATE TABLE [dbo].[service](
	[SVCID] [float] NULL,
	[BBID] [float] NULL,
	[SVCTYPE] [varchar](15) NULL,
	[BILLBBID] [float] NULL,
	[INITDATE] [datetime] NULL,
	[STARTDATE] [datetime] NULL,
	[BILLDATE] [datetime] NULL,
	[EXPDATE] [datetime] NULL,
	--[BILLTODATE] [datetime] NULL,
	--[CANCELFROMDATE] [datetime] NULL,
	--[TAXAUTHORITY] [varchar](4) NULL,
	--[HOUSEORFIELD] [varchar](1) NULL,
	[STATUS] [varchar](3) NULL,
	[HOLDSHIP] [varchar](5) NULL,
	[HOLDMAIL] [varchar](5) NULL,
	--[HOLDBILL] [varchar](5) NULL,
	--[CHANGETIME] [datetime] NULL,
	--[CHANGEDBY] [varchar](5) NULL,
	[SUBCODE] [varchar](15) NULL,
	[EBBSERIAL] [varchar](9) NULL,
	--[COMBO] [varchar](9) NULL,
	[PRIMARY] [varchar](1) NULL,
	[CODEENDDATE] [datetime] NULL,
	[CONTRACTSTATUS] [varchar](1) NULL,
	[TERMS] [varchar](2) NULL,
	[INQWHO] [varchar](8) NULL
	--[INQTYPE] [varchar](8) NULL,
	--[INQINIT] [varchar](8) NULL,
	--[INQREASON] [varchar](8) NULL,
	--[INQDETAIL] [varchar](8) NULL,
	--[INVOICELETTER] [varchar](1) NULL,
	--[PONUMBER] [varchar](15) NULL,
	--[OLDSVCID] [float] NULL,
	--[OLDSVCCODE] [varchar](2) NULL,
	--[NEWDATE] [datetime] NULL,
	--[NEWTYPE] [varchar](1) NULL,
	--[CANDATE] [datetime] NULL,
	--[CANTYPE] [varchar](1) NULL,
	--[CANACCTTIER] [varchar](1) NULL,
	--[INIT_ALLOC_ID] [int] NULL,
	--[INIT_ALLOC_YEAR] [smallint] NULL,
	--[MAIL_CS] [varchar](1) NULL,
	--[CANCEL_PENDING] [varchar](1) NULL,
	--[BBSS_STATUS] [varchar](1) NULL,
	--[BBSS_ATTN] [varchar](44) NULL,
	--[BBSS_EMAIL] [varchar](80) NULL
)
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[svctyval]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[svctyval]
GO

CREATE TABLE [dbo].[svctyval](
	[SVCTYPE] [varchar](15) NULL,
	[DESC] [varchar](50) NULL,
	--[SORTORDER] [smallint] NULL,
	--[CHLABEL] [varchar](1) NULL,
	[AMOUNT] [float] NULL,
	[WEBUNITS] [smallint] NULL
	--[PRIMARY] [varchar](1) NULL,
	--[GROUP] [varchar](1) NULL,
	--[GROUPORDER] [smallint] NULL,
	--[TAXEXEMPT] [varchar](1) NULL,
	--[CHARGETYPE] [varchar](1) NULL,
	--[UPSFIELD] [smallint] NULL,
	--[FEDEXKEY] [varchar](8) NULL,
	--[CHANGETO] [varchar](2) NULL,
	--[M90DESC] [varchar](30) NULL,
	--[CSASGROUP] [smallint] NULL,
	--[HOMEPAGE] [varchar](1) NULL,
	--[LOGO] [varchar](1) NULL,
	--[FUTURES] [varchar](1) NULL,
	--[SERIES] [varchar](5)
)
GO

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
If Exists (Select name from sysobjects where name = 'usp_PopulatePRService' and type='P') 
	Drop Procedure dbo.usp_PopulatePRService
GO

/**
Updates the PRService Table
**/
CREATE PROCEDURE dbo.usp_PopulatePRService
	@SuppressTaskCreation bit = 0
AS
BEGIN
	DECLARE @Start datetime
	SET @Start = GETDATE()

	-- Pull the data from BBS and put it in
	-- the local DB for easier reference
	DELETE FROM BBSInterface.dbo.service;
	DELETE FROM BBSInterface.dbo.svctyval;
	DELETE FROM BBSInterface.dbo.bkcodevl;
	DELETE FROM BBSInterface.dbo.outbooks;

	INSERT INTO BBSInterface.dbo.Service SELECT * FROM OPENQUERY("LINK2SBBS\SQLEXPRESS", 'SELECT * FROM OPENQUERY(SBBS, ''SELECT SVCID,BBID,SVCTYPE,BILLBBID,INITDATE,STARTDATE,BILLDATE,EXPDATE,STATUS,HOLDSHIP,HOLDMAIL,SUBCODE,EBBSERIAL,PRIMARY,CODEENDDATE,CONTRACTSTATUS,TERMS,INQWHO FROM SERVICE'')')
	INSERT INTO BBSInterface.dbo.svctyval SELECT * FROM OPENQUERY("LINK2SBBS\SQLEXPRESS", 'SELECT * FROM OPENQUERY(SBBS, ''SELECT SVCTYPE,DESC,AMOUNT,WEBUNITS FROM svctyval'')')
	INSERT INTO BBSInterface.dbo.bkcodevl SELECT * FROM OPENQUERY("LINK2SBBS\SQLEXPRESS", 'SELECT * FROM OPENQUERY(SBBS, ''SELECT BOOKCODE,DESC FROM bkcodevl'')')
	INSERT INTO BBSInterface.dbo.outbooks SELECT * FROM OPENQUERY("LINK2SBBS\SQLEXPRESS", 'SELECT * FROM OPENQUERY(SBBS, ''SELECT BOOKID,BBID,SVCID,PUBNUM,HOW,LABELDATE,TRACKINGNO FROM outbooks'')')

	DECLARE @CompanyIDs table (
		CompanyID int
	)

	DECLARE @CompanyID int, @StartDate datetime, @CreatedUserID int, @AssignedToUserID int

	SET @CreatedUserID = CRM.dbo.ufn_GetSystemUserId(0)
	SET @StartDate = GetDate()

	IF (@SuppressTaskCreation = 0) BEGIN

		-- Prospect for Service Update
		Print 'Prospect for Service Update'

		INSERT INTO @CompanyIDs
		select distinct BBID from BBSInterface.dbo.Service
		where SVCTYPE in ('100UN','250UN','500UN','1000UN','3000UN') 
		and (BBID not in
			(select prse_CompanyID from CRM.dbo.PRService where 
			prse_ServiceCode IN ('100UN','250UN','500UN','1000UN','3000UN')))
		and BBID in
			(select prse_CompanyID from CRM.dbo.PRService where 
			prse_ServiceCode IN ('BBS100','BBS150'))

		DECLARE Task_cur CURSOR LOCAL FAST_FORWARD FOR SELECT CompanyID FROM @CompanyIDs FOR READ ONLY;
		OPEN Task_cur
		FETCH NEXT FROM Task_cur INTO @CompanyID

		WHILE @@Fetch_Status=0 BEGIN
			SET @AssignedToUserID = CRM.dbo.ufn_GetPRCoSpecialistUserId(@CompanyID, 1)

			EXEC CRM.dbo.usp_CreateTask @StartDateTime = @StartDate, 
										@DueDateTime = @StartDate, 
										@CreatorUserId = @CreatedUserID, 
										@AssignedToUserId = @AssignedToUserID, 
										@TaskNotes = 'Online unit usage suggests this is a membership upgrade prospect.',	
										@RelatedCompanyId = @CompanyID,	
										@Status = 'Pending';
			FETCH NEXT FROM Task_cur INTO @CompanyID
		END

		CLOSE Task_cur
		DEALLOCATE Task_cur

		-- Prospect for Service Update
		Print 'Prospect for Service Update 2'

		DELETE FROM @CompanyIDs;

		-- checks to see if this company currently has a BBS200 service but no additional units, and now additional units are being added.
		INSERT INTO @CompanyIDs
		SELECT prse_CompanyID
		  FROM CRM.dbo.PRService
		 WHERE prse_ServiceCode = 'BBS200'
		   AND prse_CompanyID NOT IN 
				(Select ps2.prse_CompanyId from CRM.dbo.PRService ps2 where ps2.prse_ServiceCode  in ('250UN','500UN','1000UN','3000UN'))
		   AND prse_CompanyID IN 
				(SELECT BBID FROM BBSInterface.dbo.Service WHERE SVCTYPE IN ('250UN','500UN','1000UN','3000UN'))


		DECLARE Task_cur CURSOR LOCAL FAST_FORWARD FOR SELECT CompanyID FROM @CompanyIDs FOR READ ONLY;
		OPEN Task_cur
		FETCH NEXT FROM Task_cur INTO @CompanyID

		WHILE @@Fetch_Status=0
		BEGIN
			SET @AssignedToUserID = CRM.dbo.ufn_GetPRCoSpecialistUserId(@CompanyID, 1)

			EXEC CRM.dbo.usp_CreateTask @StartDateTime = @StartDate, 
										@DueDateTime = @StartDate, 
										@CreatorUserId = @CreatedUserID, 
										@AssignedToUserId = @AssignedToUserID, 
										@TaskNotes = 'Additional Units Ordered.  Prospect for Upgrade.',	
										@RelatedCompanyId = @CompanyID,	
										@Status = 'Pending';

			FETCH NEXT FROM Task_cur INTO @CompanyID
		END

		CLOSE Task_cur
		DEALLOCATE Task_cur

		-- Prospect for New Member Update
		Print 'Prospect for New Member Update'

		DELETE FROM @CompanyIDs;

		INSERT INTO @CompanyIDs
		SELECT distinct BBID
		FROM BBSInterface.dbo.Service 
		WHERE SVCTYPE IN ('BBS100','BBS150','BBS200','BBS300') 
		  AND STATUS is NULL
		  AND BBID NOT IN
				(SELECT DISTINCT prse_CompanyId 
				   FROM CRM.dbo.PRService
				  WHERE prse_ServiceCode IN ('BBS100','BBS150','BBS200','BBS300') 
					AND prse_CancelCode IS NULL
				)

		DECLARE Task_cur CURSOR LOCAL FAST_FORWARD FOR SELECT CompanyID FROM @CompanyIDs FOR READ ONLY;
		OPEN Task_cur
		FETCH NEXT FROM Task_cur INTO @CompanyID

		DECLARE @StartDate1 datetime, @StartDate2 datetime
		SET @StartDate1 = DateAdd(day, 45, GetDate()) 
		SET @StartDate2 = DateAdd(day, 10, GetDate()) 

		WHILE @@Fetch_Status=0
		BEGIN

			SET @AssignedToUserID = CRM.dbo.ufn_GetPRCoSpecialistUserId(@CompanyID, 4)
			EXEC CRM.dbo.usp_CreateTask @StartDateTime = @StartDate1, 
										@DueDateTime = @StartDate1, 
										@CreatorUserId = @CreatedUserID, 
										@AssignedToUserId = @AssignedToUserID, 
										@TaskNotes = 'Call for New Member Follow-up.',	
										@RelatedCompanyId = @CompanyID,	
										@Status = 'Pending';

			SET @AssignedToUserID = CRM.dbo.ufn_GetSurveyPersonID()
			EXEC CRM.dbo.usp_CreateTask @StartDateTime = @StartDate2, 
										@DueDateTime = @StartDate2, 
										@CreatorUserId = @CreatedUserID, 
										@AssignedToUserId = @AssignedToUserID, 
										@TaskNotes = 'Conduct New Member Survey.',	
										@RelatedCompanyId = @CompanyID,	
										@Status = 'Pending';

			FETCH NEXT FROM Task_cur INTO @CompanyID
		END

		CLOSE Task_cur
		DEALLOCATE Task_cur

		-- Cancelled Service
		Print 'Cancelled Service'

		DELETE FROM @CompanyIDs;

		INSERT INTO @CompanyIDs
		SELECT DISTINCT BBID FROM BBSInterface.dbo.Service
		WHERE SVCTYPE IN ('BBS100','BBS150','BBS200','BBS300')
		  AND STATUS IS NOT NULL
		  AND BBID NOT IN
				(SELECT DISTINCT prse_CompanyID
				   FROM CRM.dbo.PRService
				  WHERE prse_ServiceCode IN ('BBS100','BBS150','BBS200','BBS300')
					AND prse_CancelCode IS NOT NULL
				)

		DECLARE @Email varchar(255), @Subject varchar(255), @Body varchar(255)

		DECLARE Task_cur CURSOR LOCAL FAST_FORWARD FOR SELECT CompanyID FROM @CompanyIDs FOR READ ONLY;
		OPEN Task_cur
		FETCH NEXT FROM Task_cur INTO @CompanyID

		WHILE @@Fetch_Status=0
		BEGIN

			-- This procedure will check if any other companies are receiving services through
			-- this company and create a task for the inside sales rep to review.
			EXEC CRM.dbo.usp_CreateServiceCancellationTasks @CompanyID, @CreatedUserID
			

			SET @AssignedToUserID = CRM.dbo.ufn_GetPRCoSpecialistUserId(@CompanyID, 0)
			DECLARE @Notes varchar(1000)

			EXEC CRM.dbo.usp_CreateTask @StartDateTime = @StartDate, 
										@DueDateTime = @StartDate, 
										@CreatorUserId = @CreatedUserID, 
										@AssignedToUserId = @AssignedToUserID, 
										@TaskNotes = 'FYI: Cancelled their primary membership.',	
										@RelatedCompanyId = @CompanyID,	
										@Status = 'Pending',
										@PRCategory = 'R';

			FETCH NEXT FROM Task_cur INTO @CompanyID
		END

		CLOSE Task_cur
		DEALLOCATE Task_cur

	END

	PRINT 'Deleting From PRService Table'
	DELETE FROM CRM.dbo.PRService;

	PRINT 'Populating PRService Data'
	INSERT INTO CRM.dbo.PRService (
		prse_ServiceId,
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
		prse_CancelCode,
		prse_ServiceSinceDate,
		prse_InitiatedBy,
		prse_BillToCompanyId,
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
	SELECT
		SERVICE.SVCID,
		CRM.dbo.ufn_GetSystemUserId(0),
		GetDate(),
		CRM.dbo.ufn_GetSystemUserId(0),
		GetDate(),
		GetDate(),
		SERVICE.BBID,
		SERVICE.SVCTYPE,
		SUBCODE,
		CASE SERVICE.[PRIMARY] WHEN 'X' THEN 'Y' ELSE NULL END,
		STARTDATE,
		BILLDATE,
		CODEENDDATE,
		EXPDATE,
		STATUS,
		INITDATE,
		INQWHO,
		BILLBBID,
		TERMS,
		HOLDSHIP,
		HOLDMAIL,
		SERVICE.EBBSERIAL,
		CONTRACTSTATUS,
		HOW,
		TRACKINGNO,
		LABELDATE,
		BKCODEVL.[DESC],
		SVCTYVAL.[DESC],
		AMOUNT,
		WEBUNITS
	FROM BBSInterface.dbo.svctyval RIGHT OUTER JOIN
		 BBSInterface.dbo.service ON BBSInterface.dbo.svctyval.SVCTYPE = BBSInterface.dbo.service.SVCTYPE LEFT OUTER JOIN
		 BBSInterface.dbo.bkcodevl INNER JOIN
		 BBSInterface.dbo.outbooks ON BBSInterface.dbo.bkcodevl.BOOKCODE = SUBSTRING(BBSInterface.dbo.outbooks.PUBNUM, 1, 1) ON 
		 BBSInterface.dbo.service.BBID = BBSInterface.dbo.outbooks.BBID AND BBSInterface.dbo.service.SVCID = BBSInterface.dbo.outbooks.SVCID

	PRINT 'usp_PopulatePRService Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))
END
GO
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
SELECT @CurrentMaxPurchaseDate = MAX(CAST(PurchaseDate as datetime)) FROM OPENQUERY("LINK2SBBS\SQLEXPRESS", 'SELECT * FROM OPENQUERY(SBBS, ''SELECT * FROM Report3 '')');

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
		State,
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
	 FROM OPENQUERY("LINK2SBBS\SQLEXPRESS", 'SELECT * FROM OPENQUERY(SBBS, ''SELECT * FROM Report3'')') 
  WHERE CAST(PurchaseDate as datetime) BETWEEN @LastMaxPurchaseDate AND @CurrentMaxPurchaseDate;

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
