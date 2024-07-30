/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co. 2006-2010

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
USE BBSInterface

If Exists (Select name from sysobjects where name = 'usp_PopulatePRService' and type = 'P') 
    Drop Procedure dbo.usp_PopulatePRService
GO

/**
Updates the PRService Table
**/
CREATE PROCEDURE dbo.usp_PopulatePRService
    @SuppressTaskCreation bit = 0,
    @SuppressMembershipProcessing bit = 0,
    @SuppressAdvertisingProcessing bit = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Start datetime
    SET @Start = GETDATE()

    -- Pull the data from BBS and put it in
    -- the local DB for easier reference

PRINT 'Start: ' + CONVERT(VARCHAR(12), GETDATE(), 114)


    DELETE FROM BBSInterface.dbo.service;
    DELETE FROM BBSInterface.dbo.svctyval;
    DELETE FROM BBSInterface.dbo.bkcodevl;
    DELETE FROM BBSInterface.dbo.outbooks;

    BULK INSERT BBSInterface.dbo.Service  FROM N'D:\Applications\BBSInterface\Service.txt'  WITH (FormatFile=N'D:\Applications\BBSInterface\Format\Service.fmt')
    BULK INSERT BBSInterface.dbo.Svctyval FROM N'D:\Applications\BBSInterface\Svctyval.txt' WITH (FormatFile=N'D:\Applications\BBSInterface\Format\Svctyval.fmt')
    BULK INSERT BBSInterface.dbo.Bkcodevl FROM N'D:\Applications\BBSInterface\Bkcodevl.txt' WITH (FormatFile=N'D:\Applications\BBSInterface\Format\Bkcodevl.fmt')
    BULK INSERT BBSInterface.dbo.Outbooks FROM N'D:\Applications\BBSInterface\Outbooks.txt' WITH (FormatFile=N'D:\Applications\BBSInterface\Format\Outbooks.fmt')

	-- Remove services that have not yet been approved
	DELETE FROM BBSInterface.dbo.Service WHERE SVCTYPE = '**' AND ApprovalDate IS NULL;

	-- For approved orders that haven't been processed, replace the ** service code
    -- with the values stored int the ComboCode field.  This allows us to process the codes
    -- now without any code changes in the logic below.
	UPDATE Service
	   SET SVCTYPE = SUBSTRING(ComboCode, 1, CHARINDEX(' ', ComboCode)),
           SUBCODE = SUBSTRING(ComboCode, CHARINDEX(' ', ComboCode) + 1, LEN(ComboCode) - CHARINDEX(' ', ComboCode))
	 WHERE SVCTYPE = '**';
	

    DECLARE @CompanyIDs table (
        ndx int not null identity(1,1),
        CompanyID int
    );
	DECLARE @StartIndex int, @EndIndex int, @Index int
	

    -- Added to eliminate duplicate task entries during cancellations
    Declare @TaskList Table (
        TaskID int not null identity(1,1),
        RelatedCompanyID int,
        AssignedToUserID int,
        TaskNotes nvarchar(max)
    );
    DECLARE @TaskNotes nvarchar(max);
    DECLARE @TLIndex int, @TLMax int;  -- TaskListIndex

    DECLARE @CompanyID int, @StartDate datetime, @CreatedUserID int, @AssignedToUserID int
    DECLARE @Email varchar(255), @Subject varchar(255), @Body varchar(255)
    DECLARE @Password varchar(100), @EncryptedPassword varchar(100)
    DECLARE @FirstName varchar(100), @LastName varchar(100)
    DECLARE @ServiceID int

    DECLARE @NMIndexMax int, @NMIndex int; -- New Member Index
    DECLARE @WebMethodName varchar(100), @WebMethodKeyID int

    SET @CreatedUserID = CRM.dbo.ufn_GetSystemUserId(0)
    SET @StartDate = GetDate()

    IF (@SuppressTaskCreation = 0) BEGIN

		--
        -- Prospect for Service Update
		--
        Print 'Prospect for Service Update: '  + CONVERT(VARCHAR(12), GETDATE(), 114)

        INSERT INTO @CompanyIDs (CompanyID)
        SELECT DISTINCT BBID from BBSInterface.dbo.Service
         WHERE SVCTYPE IN (SELECT prod_code FROM CRM.dbo.NewProduct WITH (NOLOCK) WHERE prod_productfamilyID = 8) --  NEW ADDITIONAL UNITS
           AND BBID NOT IN (SELECT prse_CompanyID FROM CRM.dbo.PRService WITH (NOLOCK) INNER JOIN CRM.dbo.NewProduct WITH (NOLOCK) ON prse_ServiceCode = prod_code AND prod_productfamilyID = 8) -- PREVIOUS ADDITIONAL UNITS
           AND BBID IN (SELECT prse_CompanyID FROM CRM.dbo.PRService WITH (NOLOCK) WHERE prse_ServiceCode IN ('BBS100','BBS150')); -- Existing Membership

		SELECT @StartIndex = MIN(ndx),
               @EndIndex = MAX(ndx)
          FROM @CompanyIDs;
		SET @Index = @StartIndex	


		WHILE @Index <= @EndIndex Begin

            SET @CompanyID = null;
            SET @AssignedToUserID = null;

            SELECT @CompanyID = CompanyID
              FROM @CompanyIDs 
             WHERE ndx = @Index;

            SET @AssignedToUserID = CRM.dbo.ufn_GetPRCoSpecialistUserId(@CompanyID, 1)

            EXEC CRM.dbo.usp_CreateTask @StartDateTime = @StartDate, 
                                        @DueDateTime = @StartDate, 
                                        @CreatorUserId = @CreatedUserID, 
                                        @AssignedToUserId = @AssignedToUserID, 
                                        @TaskNotes = 'Online unit usage suggests this is a membership upgrade prospect.',    
                                        @RelatedCompanyId = @CompanyID,    
                                        @Status = 'Pending';
			
			SET @Index = @Index + 1
		END


		--
        -- Prospect for Service Update
		--
        Print 'Prospect for Service Update 2: '  + CONVERT(VARCHAR(12), GETDATE(), 114)

        DELETE FROM @CompanyIDs;

        -- checks to see if this company currently has a BBS200 service but no additional units, and now additional units are being added.
        INSERT INTO @CompanyIDs (CompanyID)
        SELECT prse_CompanyID
          FROM CRM.dbo.PRService WITH (NOLOCK)
         WHERE prse_ServiceCode = 'BBS200'  -- Existing BBS200 service
           AND prse_CompanyID NOT IN (SELECT prse_CompanyID FROM CRM.dbo.PRService WITH (NOLOCK) INNER JOIN CRM.dbo.NewProduct WITH (NOLOCK) ON prse_ServiceCode = prod_code AND prod_productfamilyID = 8) -- No Existing Addtional Units
           AND prse_CompanyID IN (SELECT BBID FROM BBSInterface.dbo.Service WHERE SVCTYPE IN (SELECT prod_code FROM CRM.dbo.NewProduct WHERE prod_productfamilyID = 8)) -- Requesting Addtional Units


		SELECT @StartIndex = MIN(ndx),
               @EndIndex = MAX(ndx)
          FROM @CompanyIDs;
		SET @Index = @StartIndex	


		WHILE @Index <= @EndIndex Begin

            SET @CompanyID = null;
            SET @AssignedToUserID = null;

            SELECT @CompanyID = CompanyID
              FROM @CompanyIDs 
             WHERE ndx = @Index;

            SET @AssignedToUserID = CRM.dbo.ufn_GetPRCoSpecialistUserId(@CompanyID, 1)

            EXEC CRM.dbo.usp_CreateTask @StartDateTime = @StartDate, 
                                        @DueDateTime = @StartDate, 
                                        @CreatorUserId = @CreatedUserID, 
                                        @AssignedToUserId = @AssignedToUserID, 
                                        @TaskNotes = 'Additional Units Ordered.  Prospect for Upgrade.',    
                                        @RelatedCompanyId = @CompanyID,    
                                        @Status = 'Pending';

			SET @Index = @Index + 1
		END


		--
        -- Prospect for New Member Update
		--
        Print 'Prospect for New Member Update: '  + CONVERT(VARCHAR(12), GETDATE(), 114)

        DELETE FROM @CompanyIDs;

        INSERT INTO @CompanyIDs (CompanyID)
        SELECT distinct BBID
        FROM BBSInterface.dbo.Service 
        WHERE SVCTYPE IN (SELECT prod_code FROM CRM.dbo.NewProduct WITH (NOLOCK) WHERE prod_productfamilyID = 5)  -- Membership Products
          AND STATUS is NULL -- Not Cancelled
          AND BBID NOT IN -- No Current Membership
                (SELECT DISTINCT prse_CompanyId 
                   FROM CRM.dbo.PRService WITH (NOLOCK)
                  WHERE prse_ServiceCode IN (SELECT prod_code FROM CRM.dbo.NewProduct WITH (NOLOCK) WHERE prod_productfamilyID = 5) 
                    AND prse_CancelCode IS NULL
                );


		SELECT @StartIndex = MIN(ndx),
               @EndIndex = MAX(ndx)
          FROM @CompanyIDs;
		SET @Index = @StartIndex	

        DECLARE @NewMemberFollowUpDate datetime 
        SET @NewMemberFollowUpDate = DateAdd(day, 45, GetDate()) 

		WHILE @Index <= @EndIndex Begin

            SET @CompanyID = null;
            SET @AssignedToUserID = null;

            SELECT @CompanyID = CompanyID
              FROM @CompanyIDs 
             WHERE ndx = @Index;

            SET @AssignedToUserID = CRM.dbo.ufn_GetPRCoSpecialistUserId(@CompanyID, 4)
            EXEC CRM.dbo.usp_CreateTask @StartDateTime = @NewMemberFollowUpDate, 
                                        @DueDateTime = @NewMemberFollowUpDate, 
                                        @CreatorUserId = @CreatedUserID, 
                                        @AssignedToUserId = @AssignedToUserID, 
                                        @TaskNotes = 'Call for New Member Follow-up.',    
                                        @RelatedCompanyId = @CompanyID,    
                                        @Status = 'Pending';

			SET @Index = @Index + 1
		END




        -- Cancelled Service associated with TM/FM
        Print 'Cancelled Service associated with TM/FM: '  + CONVERT(VARCHAR(12), GETDATE(), 114)

        DELETE FROM @CompanyIDs;

        INSERT INTO @CompanyIDs (CompanyID)
        SELECT DISTINCT BBID 
          FROM BBSInterface.dbo.Service WITH (NOLOCK) 
               INNER JOIN CRM.dbo.Company WITH (NOLOCK) ON comp_CompanyId = Cast(BBID As Int)
         WHERE 
          SVCTYPE IN (SELECT prod_code FROM CRM.dbo.NewProduct WITH (NOLOCK) WHERE prod_productfamilyID = 5 UNION SELECT 'TMPUB') -- Membership
          AND STATUS IS NOT NULL -- Cancelled
          AND STATUS <> 'CP'  -- This means Cancel Pending which indicates this may be an upgrade instead of a cancellation.
          AND comp_PRTMFMAward IS NOT NULL -- TM/FM Award
          AND SVCID NOT IN -- Make sure that specific service hasn't already been cancelled
				(SELECT DISTINCT prse_ServiceID
                   FROM CRM.dbo.PRService WITH (NOLOCK)
                  WHERE prse_ServiceCode IN (SELECT prod_code FROM CRM.dbo.NewProduct WITH (NOLOCK) WHERE prod_productfamilyID = 5 UNION SELECT 'TMPUB')
                    AND prse_CancelCode IS NOT NULL)
		  AND BBID NOT IN --  Make sure there isn't another valid membership service, i.e. upgrade
                (SELECT BBID 
                   FROM BBSInterface.dbo.Service WITH (NOLOCK) 
                  WHERE SVCTYPE IN (SELECT prod_code FROM CRM.dbo.NewProduct WITH (NOLOCK) WHERE prod_productfamilyID = 5 UNION SELECT 'TMPUB') -- Membership
                     AND STATUS IS NULL);


		SELECT @StartIndex = MIN(ndx),
               @EndIndex = MAX(ndx)
          FROM @CompanyIDs;
		SET @Index = @StartIndex	

        SET @TaskNotes = 'FYI: TM/FM Cancelled service.';

		WHILE @Index <= @EndIndex Begin

            SET @CompanyID = null;
            SET @AssignedToUserID = null;

            SELECT @CompanyID = CompanyID
              FROM @CompanyIDs 
             WHERE ndx = @Index;

            SET @AssignedToUserID = CRM.dbo.ufn_GetPRCoSpecialistUserId(@CompanyID, 0)

            IF NOT EXISTS(SELECT 'x' FROM @TaskList WHERE RelatedCompanyID = @CompanyID AND AssignedToUserID = @AssignedToUserID) BEGIN
                INSERT INTO @TaskList (RelatedCompanyID, AssignedToUserID, TaskNotes) VALUES (@CompanyID, @AssignedToUserID, @TaskNotes);
            END ELSE BEGIN
                UPDATE @TaskList SET TaskNotes = @TaskNotes WHERE RelatedCompanyID = @CompanyID AND AssignedToUserID = @AssignedToUserID;
            END


			SET @Index = @Index + 1
		END



        -- Unrated Transportation Company Cancelled service.
        Print 'Unrated Transportation Company Cancelled service: '  + CONVERT(VARCHAR(12), GETDATE(), 114)

        DELETE FROM @CompanyIDs;

        INSERT INTO @CompanyIDs (CompanyID)
        SELECT DISTINCT BBID FROM BBSInterface.dbo.Service WITH (NOLOCK) INNER JOIN CRM.dbo.Company WITH (NOLOCK) On (comp_CompanyId = Cast(BBID As Int))
        WHERE 
          SVCTYPE IN (SELECT prod_code FROM CRM.dbo.NewProduct WITH (NOLOCK) WHERE prod_productfamilyID = 5)
          AND STATUS IS NOT NULL
          AND STATUS <> 'CP'  -- This means Cancel Pending which indicates this may be an upgrade instead of a cancellation.
          AND comp_PRIndustryType = 'T'
          AND comp_PRListingStatus IN ('L', 'H')
          AND comp_PRType = 'H'
          AND comp_CompanyID NOT IN (SELECT prra_CompanyID FROM CRM.dbo.vPRCompanyRating WHERE prra_Current = 'Y' AND prra_Rated='Y')
          AND SVCID NOT IN -- Make sure that specific service hasn't already been cancelled
				(SELECT DISTINCT prse_ServiceID
                   FROM CRM.dbo.PRService WITH (NOLOCK)
                  WHERE prse_ServiceCode IN (SELECT prod_code FROM CRM.dbo.NewProduct WITH (NOLOCK) WHERE prod_productfamilyID = 5 UNION SELECT 'TMPUB')
                    AND prse_CancelCode IS NOT NULL)
		  AND BBID NOT IN --  Make sure there isn't another valid membership service, i.e. upgrade
                (SELECT BBID 
                   FROM BBSInterface.dbo.Service WITH (NOLOCK) 
                  WHERE SVCTYPE IN (SELECT prod_code FROM CRM.dbo.NewProduct WITH (NOLOCK) WHERE prod_productfamilyID = 5 UNION SELECT 'TMPUB') -- Membership
                     AND STATUS IS NULL);



		SELECT @StartIndex = MIN(ndx),
               @EndIndex = MAX(ndx)
          FROM @CompanyIDs;
		SET @Index = @StartIndex	

        Set @TaskNotes = 'FYI: Unrated Transportation Company Cancelled service.';

		WHILE @Index <= @EndIndex Begin

            SET @CompanyID = null;
            SET @AssignedToUserID = null;

            SELECT @CompanyID = CompanyID
              FROM @CompanyIDs 
             WHERE ndx = @Index;

            SET @AssignedToUserID = CRM.dbo.ufn_GetPRCoSpecialistUserId(@CompanyID, 0)

            IF NOT EXISTS(SELECT 'x' FROM @TaskList WHERE RelatedCompanyID = @CompanyID AND AssignedToUserID = @AssignedToUserID) BEGIN
                INSERT INTO @TaskList (RelatedCompanyID, AssignedToUserID, TaskNotes) VALUES (@CompanyID, @AssignedToUserID, @TaskNotes);
            END ELSE BEGIN
                UPDATE @TaskList SET TaskNotes = @TaskNotes WHERE RelatedCompanyID = @CompanyID AND AssignedToUserID = @AssignedToUserID;
            END


			SET @Index = @Index + 1
		END


        -- Add those tasks that are pending.
        Select @TLIndex = Min(TaskID), @TLMax = Max(TaskID) From @TaskList;
        While @TLIndex <= @TLMax Begin
            Set @CompanyID = null;
            Set @AssignedToUserID = null;
            Set @TaskNotes = null;

            Select @CompanyID = RelatedCompanyID, @AssignedToUserID = AssignedToUserID, @TaskNotes = TaskNotes From @TaskList Where TaskID = @TLIndex;
            EXEC CRM.dbo.usp_CreateTask @StartDateTime = @StartDate,
                                        @DueDateTime = @StartDate,
                                        @CreatorUserId = @CreatedUserID,
                                        @AssignedToUserId = @AssignedToUserID,
                                        @TaskNotes = @TaskNotes,
                                        @RelatedCompanyId = @CompanyID,
                                        @Status = 'Pending',
                                        @PRCategory = 'R'
            Set @TLIndex = @TLIndex + 1;
        End
    END

    --
    --  BEGIN Advertising PROCESSING
    --
    IF (@SuppressAdvertisingProcessing = 0) BEGIN

        -- New Advertising Services
        Print 'Advertising Services: '  + CONVERT(VARCHAR(12), GETDATE(), 114)
        DECLARE @AdServiceIDs table (
            CompanyID int,
            ServiceID int
        )


        -- Find all unassigned listing publicity service codes and assign
        -- then.
        INSERT INTO @AdServiceIDs 
        SELECT DISTINCT BBID, SVCID FROM BBSInterface.dbo.Service
        WHERE SVCTYPE IN (SELECT prod_code FROM CRM.dbo.NewProduct WHERE prod_productfamilyID = 12)
          AND STATUS IS NULL
          AND SVCID NOT IN -- exclude existing services
                (SELECT DISTINCT prse_ServiceID
                   FROM CRM.dbo.PRService WITH (NOLOCK)
                  WHERE prse_ServiceCode = 'LP'
                    AND prse_CancelCode IS NULL
                )
          AND SVCID NOT IN 
                (SELECT DISTINCT pradc_ServiceID 
                   FROM CRM.dbo.PRAdCampaign WITH (NOLOCK)
                  WHERE pradc_ServiceID IS NOT NULL);

        UPDATE CRM.dbo.PRAdCampaign
           SET pradc_ServiceID = ServiceID
          FROM @AdServiceIDs
         WHERE pradc_CompanyID = CompanyID
           AND pradc_AdCampaignType = 'LPA'
           AND pradc_ServiceID IS NULL;



        DELETE FROM @AdServiceIDs;

		--
		--  Now handle terminated campaigns
		--
        INSERT INTO @AdServiceIDs
        SELECT DISTINCT BBID, SVCID FROM BBSInterface.dbo.Service
        WHERE SVCTYPE IN ('LP')
          AND STATUS IS NOT NULL
          AND SVCID NOT IN   -- Select those service records that have already been cancelled
                (SELECT DISTINCT prse_ServiceID  
                   FROM CRM.dbo.PRService WITH (NOLOCK)
                  WHERE prse_ServiceCode = 'LP'
                    AND prse_CancelCode IS NOT NULL
                )


		UPDATE CRM.dbo.PRAdCampaign
           SET pradc_EndDate = GETDATE(),
               pradc_UpdatedBy = @CreatedUserID,
               pradc_UpdatedDate = GETDATE(),
               pradc_Timestamp = GETDATE()
          FROM @AdServiceIDs
         WHERE pradc_ServiceID = ServiceID;

    END
    --
    --  END Advertising PROCESSING
    --

    --
    --  BEGIN Membership PROCESSING
    --
    IF (@SuppressMembershipProcessing = 0) BEGIN

		Print 'Membership Processsing: '  + CONVERT(VARCHAR(12), GETDATE(), 114)

        -- Constants for Service Type
        Declare @ST_Primary int, @ST_Additional int, @ST_NotConnected int;
        Set @ST_Primary = 0;
        Set @ST_Additional = 1;
        Set @ST_NotConnected = 2;

        DECLARE @CancelledServices table (
            ServiceID int,
			ServiceType int	-- 0: Primary; 1: Additional License
        )

		Declare @ExistingWebUsers Table (
			WebUserID int,
			HQID int,
			LastName nvarchar(max),
			FirstName nvarchar(max),
			ExistingEmail bit,
			LicenseAssigned bit,
			ServiceType int	-- 0: Primary; 1: Additional License; 2 - Existing Users not currently connected
		)

        -- Cancelled Primary Memberships
        INSERT INTO @CancelledServices (ServiceID, ServiceType)
        SELECT DISTINCT a.SVCID, @ST_Primary
          FROM BBSInterface.dbo.Service a
         WHERE a.SVCTYPE IN (SELECT prod_code FROM CRM.dbo.NewProduct WHERE prod_productfamilyID = 5)
           AND a.[STATUS] IS NOT NULL
           AND a.SVCID NOT IN
                (SELECT b.prse_ServiceID
                   FROM CRM.dbo.PRService b WITH (NOLOCK)
                  WHERE b.prse_ServiceCode IN (SELECT prod_code FROM CRM.dbo.NewProduct WHERE prod_productfamilyID = 5)
                    AND b.prse_CancelCode IS NOT NULL
                );

		-- Save off a list of current web user's prior to clearing them
		-- Servicetype of 0 = Primary Licenses.
		Insert Into
			@ExistingWebUsers (WebUserID, HQID, LastName, FirstName, ExistingEmail, LicenseAssigned, ServiceType)
		Select
			prwu_WebUserID, comp_PRHQID, prwu_LastName, prwu_FirstName, Case When Len(Coalesce(prwu_Email, '')) > 0 Then 1 Else 0 End, Case When Coalesce(prwu_AccessLevel, 0) > 10 Then 1 Else 0 End, @ST_Primary
		From
			CRM.dbo.PRWebUser WITH (NOLOCK)
			Inner Join CRM.dbo.Person_Link WITH (NOLOCK) On (peli_PersonLinkID = prwu_PersonLinkID)
			Inner Join CRM.dbo.Company WITH (NOLOCK) On (comp_CompanyID = peli_CompanyID)
		Where
		    prwu_ServiceID In (
				Select ServiceID From @CancelledServices Where ServiceType = @ST_Primary   -- Overkill to check for service type (it's always primary here); It's there for consistency
		    )
		    And peli_PRStatus In (1, 2);

-- Print ' - Updating PRWebUser Records due to cancelled primary membership'
        UPDATE CRM.dbo.PRWebUser
           SET prwu_AccessLevel = CASE comp_PRIndustryType WHEN 'L' THEN 5 ELSE 10 END,
               prwu_ServiceID = NULL,
               prwu_UpdatedBy = @CreatedUserID,
               prwu_UpdatedDate = GETDATE(),
               prwu_Timestamp = GETDATE()
          FROM CRM.dbo.PRWebUser
               INNER JOIN crm.dbo.Company ON prwu_BBID = comp_CompanyID
         WHERE prwu_ServiceID IN (SELECT ServiceID FROM @CancelledServices Where ServiceType = @ST_Primary);

        -- Cancelled Additional Licenses (Still need the Primary service ID's)
        INSERT INTO @CancelledServices (ServiceID, ServiceType)
        SELECT a.SVCID, @ST_Additional FROM BBSInterface.dbo.Service a
        WHERE a.SVCTYPE IN (SELECT prod_code FROM CRM.dbo.NewProduct WHERE prod_productfamilyID = 6)
          AND a.[STATUS] IS NOT NULL
          AND a.SVCID NOT IN
                (SELECT b.prse_ServiceID
                   FROM CRM.dbo.PRService b WITH (NOLOCK)
                  WHERE b.prse_ServiceCode IN (SELECT prod_code FROM CRM.dbo.NewProduct WITH (NOLOCK) WHERE prod_productfamilyID = 6)
                    AND b.prse_CancelCode IS NOT NULL
                );

		-- Save off a list of current web user's prior to clearing them
		-- Servicetype of 1 = Additional Licenses.
		Insert Into
			@ExistingWebUsers (WebUserID, HQID, LastName, FirstName, ExistingEmail, LicenseAssigned, ServiceType)
		Select
			prwu_WebUserID, comp_PRHQId, prwu_LastName, prwu_FirstName, Case When Len(Coalesce(prwu_Email, '')) > 0 Then 1 Else 0 End, Case When Coalesce(prwu_AccessLevel, 0) > 10 Then 1 Else 0 End, @ST_Additional
		From
			CRM.dbo.PRWebUser WITH (NOLOCK)
			Inner Join CRM.dbo.Person_Link WITH (NOLOCK) On (peli_PersonLinkID = prwu_PersonLinkID)
			Inner Join CRM.dbo.Company WITH (NOLOCK) On (comp_CompanyID = peli_CompanyID)
		Where
		    prwu_ServiceID In (
				Select ServiceID From @CancelledServices Where ServiceType = @ST_Additional
		    )
		    And peli_PRStatus In (1, 2);

-- Print ' - Updating PRWebUser Records due to cancelled additional licenses'
        UPDATE CRM.dbo.PRWebUser
           SET prwu_AccessLevel = CASE comp_PRIndustryType WHEN 'L' THEN 5 ELSE 10 END,
               prwu_ServiceID = NULL,
               prwu_UpdatedBy = @CreatedUserID,
               prwu_UpdatedDate = GETDATE(),
               prwu_Timestamp = GETDATE()
          FROM CRM.dbo.PRWebUser WITH (NOLOCK)
               INNER JOIN crm.dbo.Company WITH (NOLOCK) ON prwu_BBID = comp_CompanyID
         WHERE prwu_ServiceID IN (SELECT ServiceID FROM @CancelledServices Where ServiceType = @ST_Additional);

        -- New Primary Memberships
        Declare @MembershipHQIDs As Table (
            ndx int identity(1,1) primary key,
            HQID int,
            ServiceID int,
            ServiceCode varchar(50)
        )

        DECLARE @WebUserCount int, @PersonLinkCount int, @RemainingCount int
        DECLARE @HQID int, @MaxWebUsers int, @MaxAccessLevel int
        DECLARE @ServiceCode varchar(50)

        --
        -- New Memberships
        --
        INSERT INTO @MembershipHQIDs (HQID, ServiceID, ServiceCode)
        SELECT DISTINCT CRM.dbo.ufn_BRGetHQID(BBID), SVCID, SVCTYPE FROM BBSInterface.dbo.Service
        WHERE SVCTYPE IN (SELECT prod_code FROM CRM.dbo.NewProduct WHERE prod_productfamilyID = 5)
          AND [STATUS] IS NULL
          AND SVCID NOT IN
                (SELECT DISTINCT prse_ServiceID
                   FROM CRM.dbo.PRService WITH (NOLOCK)
                  WHERE prse_ServiceCode IN (SELECT prod_code FROM CRM.dbo.NewProduct WITH (NOLOCK) WHERE prod_productfamilyID = 5)
					AND prse_ServiceID Not In (Select ServiceID From @CancelledServices)
                    AND prse_CancelCode IS NULL);

        -- Add any web users to the existing table (if not already there)
        Insert Into
            @ExistingWebUsers(WebUserID, HQID, LastName, FirstName, ExistingEmail, LicenseAssigned, ServiceType)
        Select
            prwu_WebUserID,
            comp_PRHQId,
            prwu_LastName,
            prwu_FirstName,
            Case When Len(Coalesce(prwu_Email, '')) > 0 Then 1 Else 0 End,
            Case When Coalesce(prwu_AccessLevel, 0) > 10 Then 1 Else 0 End,
            @ST_NotConnected
        From
            CRM.dbo.PRWebUser
            Inner Join CRM.dbo.Person_Link On (peli_PersonLinkID = prwu_PersonLinkID)
            Inner Join CRM.dbo.Company On (comp_CompanyID = peli_CompanyID)
        Where
            comp_PRHQID In (Select HQID From @MembershipHQIDs)
            And prwu_Email Is Not Null
            And prwu_ServiceID Is Null
            And prwu_WebUserId Not In (Select WebUserID From @ExistingWebUsers)
            And peli_PRStatus In (1, 2)
        ;
        
        -- Remove from the Existing User List any user that does not have currently have both an email and existing license
        Delete
        From    @ExistingWebUsers
        Where   ExistingEmail = 0 And LicenseAssigned = 0;

        Select @NMIndex = Coalesce(Min(ndx), 0), @NMIndexMax = Coalesce(Max(ndx), -1) From @MembershipHQIDs;
        WHILE (@NMIndex <= @NMIndexMax) BEGIN
            SELECT @HQID = HQID,
                   @ServiceID = ServiceID,
                   @ServiceCode = ServiceCode,
                   @MaxWebUsers = prod_PRWebUsers,
                   @MaxAccessLevel = prod_PRWebAccessLevel
              FROM @MembershipHQIDs
                   INNER JOIN CRM.dbo.NewProduct WITH (NOLOCK) ON ServiceCode = prod_code
             WHERE ndx = @NMIndex;

            SET @RemainingCount = @MaxWebUsers;
            Select @WebUserCount = Count(*)
            From   @ExistingWebUsers
            Where  HQID = @HQID And ServiceType In (@ST_Primary, @ST_Additional);

			-- Enable Web users that used to have access.
			-- However, if we don't have enough licenses for these (downgrade), create a task
			Declare @UserTask nvarchar(max);
			Set @UserTask = '';

			IF (@WebUserCount > @MaxWebUsers) BEGIN
			    -- Create a list of user names 
			    Select @UserTask = 'BBOS Access needs to be reassigned. The following users previously had a BBOS Access License: '
			                       + Stuff((Select ', ' + FirstName + ' ' + LastName From @ExistingWebUsers Where HQID = @HQID Order By LastName, FirstName For XML Path('')), 1, 2, '')
			                       + '.';
			END ELSE BEGIN
-- PRINT ' - Updating existing PRWebUser Records due to membership upgrade';
				
			    UPDATE CRM.dbo.PRWebUser
			       SET prwu_AccessLevel = @MaxAccessLevel,
				       prwu_ServiceID = @ServiceID,
				       prwu_UpdatedBy = @CreatedUserID,
				       prwu_UpdatedDate = GETDATE(),
				       prwu_Timestamp = GETDATE()
			     WHERE prwu_WebUserID In (
			                Select WebUserID
			                From   @ExistingWebUsers
			                Where  HQID = @HQID
			                       And ServiceType In (@ST_Primary, @ST_Additional)
			           );

			    Set @RemainingCount = @RemainingCount - @@RowCount;

			    -- Add any additional Webusers who were not already connected into the mix...
                Select @WebUserCount = Count(*)
                From   @ExistingWebUsers
                Where  HQID = @HQID And ServiceType = @ST_NotConnected

                -- Check for too many users
			    IF (@WebUserCount > @RemainingCount) BEGIN
			        Select @UserTask = 'The following web users had no licenses assigned, but cannot be assigned due to more users than available licenses: '
			                           + Stuff((Select ', ' + FirstName + ' ' + LastName From @ExistingWebUsers Where HQID = @HQID And ServiceType = @ST_NotConnected Order By LastName, FirstName For XML Path('')), 1, 2, '')
			                           + '.';
                END ELSE BEGIN
-- Print ' - Updating existing unconnected PRWebUser Records due to new primary membership'
                    
                    UPDATE CRM.dbo.PRWebUser
                       SET prwu_AccessLevel = @MaxAccessLevel,
                           prwu_ServiceID = @ServiceID,
                           prwu_UpdatedBy = @CreatedUserID,
                           prwu_UpdatedDate = GETDATE(),
                           prwu_Timestamp = GETDATE()
                     WHERE prwu_WebUserID In (
                        Select WebUserID From @ExistingWebUsers Where HQID = @HQID And ServiceType = @ST_NotConnected
                     )

                    SET @RemainingCount = @RemainingCount - @@RowCount;

                    -- If we have any licenses left, go look
                    -- for PersonLink records
                    IF (@RemainingCount > 0) BEGIN

                        DECLARE @PersonLinkIDs table (
                            ndx int identity(1,1),
                            PersonLinkID int
                        )
                        DECLARE @PLIndex int, @MaxPLIndex int, @PersonLinkID int, @WebUserID int

                        Delete From @PersonLinkIDs;

                        With PersonLinks (PersonLinkID, HQID, PersonStatus, EmailAddress, PersonOrder)
                        As
                        (
                            Select peli_PersonLinkID, comp_PRHQId, peli_PRStatus, emai_EmailAddress, Row_Number() Over (Partition By comp_PRHQId, peli_PersonID Order By peli_PRStatus, Capt_Order)
                            FROM CRM.dbo.Person_Link WITH (NOLOCK)
                               INNER JOIN CRM.dbo.Company WITH (NOLOCK) ON peli_CompanyID = comp_CompanyID
                               INNER JOIN CRM.dbo.Custom_Captions WITH (NOLOCK) On (comp_PRType = Capt_Code And Capt_Family = 'comp_PRType')
                               LEFT OUTER JOIN CRM.dbo.Email WITH (NOLOCK) ON peli_PersonID = emai_PersonID AND emai_CompanyID = peli_CompanyID AND emai_Type = 'E'
                        )
                        INSERT INTO @PersonLinkIDs (PersonLinkID)
                        SELECT DISTINCT PersonLinkID
                          FROM PersonLinks
                         WHERE HQID = @HQID
                               AND PersonStatus IN (1,2,4)
                               AND EmailAddress Is Not Null
                               AND PersonOrder = 1
                               AND PersonLinkID NOT IN (SELECT prwu_PersonLinkID 
                                                          FROM CRM.dbo.PRWebUser WITH (NOLOCK) 
                                                         WHERE prwu_HQID = @HQID 
                                                               AND prwu_ServiceID IS NOT NULL);

                        SELECT @PersonLinkCount = COUNT(*) FROM @PersonLinkIDs;
                        -- If the number of person link records is less than
                        -- the remaining count, then go ahead and create
                        -- PRWebUser records.
                        IF ((@PersonLinkCount > 0) And (@PersonLinkCount <= @RemainingCount)) BEGIN
-- Print ' - Creating PRWebUser Records due to new primary membership'

                            Select @PLIndex = Coalesce(Min(ndx), 0), @MaxPLIndex = Coalesce(Max(ndx), -1) From @PersonLinkIDs
                            WHILE (@PLIndex <= @MaxPLIndex) BEGIN

                                SELECT @PersonLinkID = PersonLinkID
                                  FROM @PersonLinkIDs
                                 WHERE ndx = @PLIndex;

                                SELECT @Email = RTRIM(emai_EmailAddress),
                                       @Password = peli_WebPassword,
                                       @FirstName = RTrim(pers_FirstName), 
                                       @LastName = RTRIM(pers_LastName),
                                       @CompanyID = peli_CompanyID
                                  FROM CRM.dbo.Person_Link WITH (NOLOCK)
                                       INNER JOIN CRM.dbo.Person WITH (NOLOCK) on peli_PersonID = pers_PersonID
                                       LEFT OUTER JOIN CRM.dbo.Email WITH (NOLOCK) ON peli_PersonID = emai_PersonID AND emai_Type = 'E'
                                 WHERE peli_PersonLinkID = @PersonLinkID;

								DECLARE @IsEmailExist int
								SET @IsEmailExist = 0

                                IF @Email IS NOT NULL BEGIN
									SELECT @IsEmailExist = 1
									  FROM crm.dbo.PRWebUser
									 WHERE prwu_Email = @Email;
								END

								IF @IsEmailExist = 0 BEGIN
									IF @Password IS NULL BEGIN
-- Print ' - Generating Password'
										EXEC CRM.dbo.usp_GeneratePassword @Password OUTPUT
									END

									SET @EncryptedPassword = CRM.dbo.ufnclr_EncryptText(@Password)

									EXEC CRM.dbo.usp_GetNextId 'PRWebUser', @WebUserID output

									INSERT INTO CRM.dbo.PRWebUser
									(prwu_WebUserID,prwu_Email,prwu_Password,prwu_FirstName,prwu_LastName,prwu_PersonLinkID,prwu_BBID,prwu_HQID,prwu_ServiceID,prwu_Culture,prwu_UICulture,prwu_AccessLevel,prwu_CreatedBy,prwu_CreatedDate,prwu_UpdatedBy,prwu_UpdatedDate,prwu_TimeStamp)
									VALUES (@WebUserID,@Email,@EncryptedPassword,@FirstName,@LastName,@PersonLinkID,@CompanyID,@HQID,@ServiceID,'en-us','en-us',@MaxAccessLevel,@CreatedUserID,GETDATE(),@CreatedUserID,GETDATE(),GETDATE());

--Print ' - Processing New Membership'
									EXEC CRM.dbo.usp_ProcessNewMembeshipUser @WebUserID

									EXEC CRM.dbo.usp_SendBBOSPassword @WebUserID
								END

                                SET @PLIndex = @PLIndex + 1;
                            END

                            SET @RemainingCount = @RemainingCount - @PersonLinkCount;
                        END
                    END
                END 
			END

            IF (@RemainingCount > 0) And (@SuppressTaskCreation = 0) BEGIN

                Declare @TaskNotesParam nvarchar(max);
                Set @TaskNotesParam = 'This enterprise has unassigned licenses.' + Coalesce(@UserTask, '');
                
--Print ' - Creating task due to extra licenses: ' + Convert(varchar(10), @RemainingCount)
                SET @AssignedToUserID = CRM.dbo.ufn_GetPRCoSpecialistUserId(@HQID, 4)
                EXEC CRM.dbo.usp_CreateTask @StartDateTime = @StartDate, 
                                            @DueDateTime = @StartDate, 
                                            @CreatorUserId = @CreatedUserID, 
                                            @AssignedToUserId = @AssignedToUserID, 
                                            @TaskNotes = @TaskNotesParam,
                                            @RelatedCompanyId = @HQID,    
                                            @Status = 'Pending';

            END

            SET @NMIndex = @NMIndex + 1
        END

		--
		-- Now Process Attention Lines
		--
		-- First up, new memberships and bundled services
		--

PRINT 'Starting Attention Line Processing: '  + CONVERT(VARCHAR(12), GETDATE(), 114)

		DECLARE @NewService table (
			CompanyID int,
			ServiceID int,
			ServiceCode varchar(50)
		)

        INSERT INTO @NewService (CompanyID, ServiceID, ServiceCode)
        SELECT DISTINCT BBID, SVCID, SVCTYPE FROM BBSInterface.dbo.Service
        WHERE SVCTYPE IN (SELECT prod_code FROM CRM.dbo.NewProduct WHERE prod_productfamilyID = 5)
          AND [STATUS] IS NULL
          AND SVCID NOT IN
                (SELECT DISTINCT prse_ServiceID
                   FROM CRM.dbo.PRService WITH (NOLOCK)
                  WHERE prse_ServiceCode IN (SELECT prod_code FROM CRM.dbo.NewProduct WITH (NOLOCK) WHERE prod_productfamilyID = 5)
					AND prse_ServiceID Not In (Select ServiceID From @CancelledServices)
                    AND prse_CancelCode IS NULL);


--PRINT '  - Processing New Memberships'
		INSERT INTO CRM.dbo.PRAttentionLine (prattn_CompanyID, prattn_ItemCode, prattn_ServiceID, prattn_AddressID, prattn_CreatedBy, prattn_UpdatedBy)
		SELECT CompanyID, 'BOOK', ServiceID, adli_AddressID, @CreatedUserID, @CreatedUserID
          FROM @NewService
               LEFT OUTER JOIN CRM.dbo.Address_Link WITH (NOLOCK) ON CompanyID = adli_CompanyID AND adli_PRDefaultMailing = 'Y'
         WHERE ServiceCode = 'BBS100';

		INSERT INTO CRM.dbo.PRAttentionLine (prattn_CompanyID, prattn_ItemCode, prattn_ServiceID, prattn_AddressID, prattn_CreatedBy, prattn_UpdatedBy)
		SELECT CompanyID, 'BPRINT', ServiceID, adli_AddressID, @CreatedUserID, @CreatedUserID
          FROM @NewService
			   LEFT OUTER JOIN CRM.dbo.Address_Link WITH (NOLOCK) ON CompanyID = adli_CompanyID AND adli_PRDefaultMailing = 'Y'
         WHERE ServiceCode IN ('BBS100', 'BBS150', 'BBS200', 'BBS300', 'BBS350');

		INSERT INTO CRM.dbo.PRAttentionLine (prattn_CompanyID, prattn_ItemCode, prattn_ServiceID, prattn_CreatedBy, prattn_UpdatedBy)
		SELECT CompanyID, 'CSUPD', ServiceID, @CreatedUserID, @CreatedUserID
          FROM @NewService
         WHERE ServiceCode IN ('BBS100', 'BBS150', 'BBS200', 'BBS300', 'BBS350');

--PRINT '  - Processing Cancelled Services'
		--
		-- Build a table of newly cancelled services
		-- Include all services, primary and additional.
		DELETE FROM @CancelledServices;
         
		INSERT INTO @CancelledServices (ServiceID)
		SELECT DISTINCT a.SVCID
		  FROM BBSInterface.dbo.Service a
         WHERE --a.SVCTYPE IN ('CSUPD', 'EXUPD', 'BOOK', 'BPRINT') AND 
		   a.[STATUS] IS NOT NULL
           AND a.SVCID NOT IN
			 (SELECT b.prse_ServiceID
				FROM CRM.dbo.PRService b WITH (NOLOCK)
			   WHERE --b.prse_ServiceCode IN ('CSUPD', 'EXUPD', 'BOOK', 'BPRINT') AND 
					b.prse_CancelCode IS NOT NULL)


		DELETE FROM CRM.dbo.PRAttentionLine
		 WHERE prattn_ServiceID IN 
			(SELECT ServiceID 
			   FROM @CancelledServices);


--PRINT '  - Processing New Additional Services'
		--
		--  Now handle new additional services
		--
		DELETE FROM @NewService;

		INSERT INTO @NewService (CompanyID, ServiceID, ServiceCode)
		SELECT BBID, SVCID, SVCTYPE 
          FROM BBSInterface.dbo.Service
		 WHERE SVCTYPE IN ('CSUPD', 'EXUPD' , 'BOOK', 'BPRINT')
		   AND STATUS IS NULL
		   AND SVCID NOT IN
			 (SELECT DISTINCT prse_ServiceID
				FROM CRM.dbo.PRService WITH (NOLOCK)
					 INNER JOIN CRM.dbo.NewProduct WITH (NOLOCK) ON prse_ServiceCode = prod_code 
			   WHERE prse_ServiceID Not In (SELECT ServiceID FROM @CancelledServices)
                 AND prse_ServiceCode IN ('CSUPD', 'EXUPD', 'BOOK', 'BPRINT')
				 AND prse_CancelCode IS NULL);


		INSERT INTO CRM.dbo.PRAttentionLine (prattn_CompanyID, prattn_ItemCode, prattn_ServiceID, prattn_AddressID, prattn_CreatedBy, prattn_UpdatedBy)
		SELECT CompanyID, ServiceCode, ServiceID, adli_AddressID, @CreatedUserID, @CreatedUserID
          FROM @NewService
               LEFT OUTER JOIN CRM.dbo.Address_Link WITH (NOLOCK) ON CompanyID = adli_CompanyID AND adli_PRDefaultMailing = 'Y'
         WHERE ServiceCode IN ('BOOK', 'BPRINT');

		INSERT INTO CRM.dbo.PRAttentionLine (prattn_CompanyID, prattn_ItemCode, prattn_EmailID, prattn_PhoneID, prattn_ServiceID, prattn_CreatedBy, prattn_UpdatedBy)
		SELECT CompanyID, ServiceCode, ServiceID, emai_EmailID, CASE WHEN emai_EmailID IS NULL THEN phon_PhoneID ELSE NULL END, @CreatedUserID, @CreatedUserID
          FROM @NewService
               LEFT OUTER JOIN CRM.dbo.Email WITH (NOLOCK) ON CompanyID = emai_CompanyID AND emai_PersonID IS NULL AND emai_Type = 'E' AND emai_PRPreferredInternal = 'Y'
               LEFT OUTER JOIN CRM.dbo.Phone WITH (NOLOCK) ON CompanyID = phon_CompanyID AND phon_PersonID IS NULL AND phon_PRIsFax = 'Y' AND phon_PRPreferredInternal = 'Y'
         WHERE ServiceCode IN ('CSUPD', 'EXUPD');
    END
    --
    --  END PRWebUser PROCESSING
    --
    


	PRINT 'Deleting From PRService Table: '  + CONVERT(VARCHAR(12), GETDATE(), 114)
    DELETE FROM CRM.dbo.PRService;

    PRINT 'Populating PRService Data: '  + CONVERT(VARCHAR(12), GETDATE(), 114)
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
        prse_UnitsPackaged,
        prse_HQID,
        prse_DiscountPCT)
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
        [STATUS],
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
        WEBUNITS,
        CRM.dbo.ufn_BRGetHQID(SERVICE.BBID),
        DISCOUNTPCT
    FROM BBSInterface.dbo.svctyval 
         RIGHT OUTER JOIN BBSInterface.dbo.service ON BBSInterface.dbo.svctyval.SVCTYPE = BBSInterface.dbo.service.SVCTYPE 
		 LEFT OUTER JOIN BBSInterface.dbo.bkcodevl 
         INNER JOIN BBSInterface.dbo.outbooks ON BBSInterface.dbo.bkcodevl.BOOKCODE = SUBSTRING(BBSInterface.dbo.outbooks.PUBNUM, 1, 1) ON  BBSInterface.dbo.service.BBID = BBSInterface.dbo.outbooks.BBID AND BBSInterface.dbo.service.SVCID = BBSInterface.dbo.outbooks.SVCID

Print 'Updating Suspended Flag: '  + CONVERT(VARCHAR(12), GETDATE(), 114)

	UPDATE CRM.dbo.PRService
	   SET prse_Suspended = 'Y'
	  FROM OPENROWSET(BULK 'D:\Applications\BBSInterface\Servsusp.txt', FORMATFILE='D:\Applications\BBSInterface\Format\Servsusp.fmt') As Servsusp
	 WHERE prse_ServiceID = SVCID;

Print 'Done: '  + CONVERT(VARCHAR(12), GETDATE(), 114)


    PRINT 'usp_PopulatePRService Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))
END
GO
