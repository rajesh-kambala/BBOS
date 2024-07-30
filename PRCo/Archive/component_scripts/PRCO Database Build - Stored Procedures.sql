-- ********************* CREATE CUSTOM STORED PROCEDURES **********************

/* usp_RethrowError is used to generate an error using 
 * RAISERROR, typically from within a BEGIN CATCH block. 
 * The original error information is used to
 * construct the msg_str for RAISERROR.
 * This procedure is taken directly from SQLServer Help.
 */
IF OBJECT_ID (N'usp_RethrowError',N'P') IS NOT NULL
    DROP PROCEDURE usp_RethrowError;
GO
CREATE PROCEDURE usp_RethrowError AS
    -- Return if there is no error information to retrieve.
    IF ERROR_NUMBER() IS NULL
        RETURN;

    DECLARE 
        @ErrorMessage    NVARCHAR(4000),
        @ErrorNumber     INT,
        @ErrorSeverity   INT,
        @ErrorState      INT,
        @ErrorLine       INT,
        @ErrorProcedure  NVARCHAR(200);

    -- Assign variables to error-handling functions that 
    -- capture information for RAISERROR.
    SELECT 
        @ErrorNumber = ERROR_NUMBER(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE(),
        @ErrorLine = ERROR_LINE(),
        @ErrorProcedure = ISNULL(ERROR_PROCEDURE(), '-');

    -- Building the message string that will contain original
    -- error information.
    SELECT @ErrorMessage = 
        N'Error %d, Level %d, State %d, Procedure %s, Line %d, ' + 
            'Message: '+ ERROR_MESSAGE();

    -- Raise an error: msg_str parameter of RAISERROR will contain
    -- the original error information.
    RAISERROR 
        (
        @ErrorMessage, 
        @ErrorSeverity, 
        1,               
        @ErrorNumber,    -- parameter: original error number.
        @ErrorSeverity,  -- parameter: original error severity.
        @ErrorState,     -- parameter: original error state.
        @ErrorProcedure, -- parameter: original error procedure name.
        @ErrorLine       -- parameter: original error line number.
        );
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_getNextId]'))
drop Procedure [dbo].[usp_getNextId]
GO
CREATE Procedure dbo.usp_getNextId
    @TableName nvarchar(200) = NULL,
    @Return int output 
AS
BEGIN
    Declare @TableId int, @returnvalue int
    select @TableId = Bord_TableId 
        from custom_tables 
        where bord_Name = @TableName
    exec @Return = crm_next_id @TableId
END
GO


/******************************************************************************
 *   Procedure: usp_CreateTransaction
 *
 *   Return: None
 *
 *   Decription:  This procedure simplifies creation of a PRTransaction 
 *                record
 *
 *
 *****************************************************************************/
if exists (select * from dbo.sysobjects 
		where id = object_id(N'[dbo].[usp_CreateTransaction]') 
				and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_CreateTransaction]
GO

CREATE PROCEDURE dbo.usp_CreateTransaction
    @UserId int = -1,
    @prtx_CompanyId int = null,
    @prtx_PersonId int = null,
    @prtx_BusinessEventId int = null,
    @prtx_PersonEventId int = null,
    @prtx_EffectiveDate datetime = null,
    @prtx_AuthorizedById int = null,
    @prtx_AuthorizedInfo nvarchar(50) = null,
    @prtx_NotificationType nvarchar(40) = 'P',
    @prtx_NotificationStimulus nvarchar(40) = null,
    @prtx_CreditSheetId int = null,
    @prtx_Explanation text = null,
    @prtx_RedbookDate datetime = null,
    @prtx_Status nvarchar(40) = 'O',
    @prtx_Deleted int = null,
    @prtx_WorkflowId int = null,
    @prtx_Secterr int = null
AS
BEGIN
    SET NOCOUNT ON

    Declare @Msg varchar(2000)
    Declare @Now datetime
    Declare @Caption varchar(200)
    Declare @NextId int
    Declare @TableId_Transaction int
    
    -- the user id is required
    IF ( @UserId IS NULL) 
    BEGIN
        SET @Msg = 'Update Failed.  An valid User Id must be provided.'
        ROLLBACK
        RAISERROR (@Msg, 16, 1)
        Return
    END

    select @TableId_Transaction = bord_tableId from custom_tables where bord_name = 'PRTransaction'
    exec @NextId = crm_next_id @TableId_Transaction 

    SET @Now = getDate();
    INSERT INTO PRTransaction
      VALUES(@NextId, @prtx_Deleted, @prtx_WorkflowId, @prtx_Secterr, 
             @UserId, @Now, @UserId, @Now, @Now, 
             @prtx_CompanyId, @prtx_PersonId, @prtx_BusinessEventId, @prtx_PersonEventId,
             @prtx_EffectiveDate, @prtx_AuthorizedById, @prtx_AuthorizedInfo,
             @prtx_NotificationType, @prtx_NotificationStimulus, 
             @prtx_CreditSheetId, @prtx_Explanation, @prtx_RedbookDate, @prtx_Status,null)

    SET NOCOUNT OFF

    RETURN @NextId
END
GO


/******************************************************************************
 *   Procedure: usp_CreateTransactionDetail
 *
 *   Return: None
 *
 *   Decription:  This procedure simplifies creation of a PRTransactionDetail 
 *                record
 *
 *
 *****************************************************************************/
if exists (select * from dbo.sysobjects 
		where id = object_id(N'[dbo].[usp_CreateTransactionDetail]') 
				and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_CreateTransactionDetail]
GO

CREATE PROCEDURE dbo.usp_CreateTransactionDetail
    @prtx_TransactionId int = null,
    @Entity varchar(100),
    @Action varchar(10) = 'Update',
    @Field varchar(200) = null,
    @OldValue varchar(2000) = null, 
    @NewValue varchar(2000) = null,
    @UserId int = -1,
    @TransactionDetailTypeId int = null,
    @OldTextValue Text = null, 
    @NewTextValue Text = null
AS
BEGIN
    SET NOCOUNT ON

    -- determine if there was really a value change
    if ( (@OldValue = @NewValue AND @OldValue != 'Text Change') OR
         (@OldValue IS NULL AND @NewValue IS NULL)
       )
    BEGIN
        return
    END
        
    Declare @Caption varchar(200)
    Declare @NextId int
    
    -- most of the time this should be passed in; if it isn't, look it up
    IF (@TransactionDetailTypeId IS null)
    BEGIN
         -- get the Accpac ID value for this entity so we can get the next available Id
         select @TransactionDetailTypeId = Bord_TableId from custom_tables where Bord_Caption = 'PRTransactionDetail'
    END
    -- get a next ID 
    exec @NextId = crm_next_id @TransactionDetailTypeId 

    DECLARE @FieldTable TABLE(idx smallint, token varchar(8000))    
    DECLARE @FieldCnt smallint, @LoopIdx smallint
    DECLARE @token varchar(8000)
    DECLARE @TempCaption nvarchar(100)
    INSERT INTO @FieldTable SELECT * FROM dbo.Tokenize(@Field, ',')
    SELECT @FieldCnt = COUNT(1) FROM @FieldTable
    IF (@FieldCnt > 1)
    BEGIN
      --  Get the value for each caption
      SET @LoopIdx = 0
      WHILE (@LoopIdx >= 0)
      BEGIN
        SET @token = null
        SELECT @token = token FROM @FieldTable WHERE idx = @Loopidx
        IF (@token is not null)
        Begin
    	    SELECT @TempCaption = Capt_US from Custom_Captions where Capt_code = @Token
            SET @Caption = COALESCE(@Caption + ', ' + @TempCaption, @TempCaption, @Caption + ', ' + @Token, @Token)
            SET @LoopIdx = @LoopIdx + 1
        End
        ELSE
        Begin
            SET @LoopIdx = -1
        End  
      END
    END
    ELSE
    BEGIN
    	SELECT @Caption = Capt_US from Custom_Captions where Capt_code = @Field
    END
    
    IF (@Caption is NULL) SET @Caption = @Field
    if (@NewValue = 'Text Change' )
    BEGIN
      INSERT INTO PRTransactionDetail
            (prtd_TransactionDetailId, prtd_TransactionId, prtd_EntityName, prtd_Action, prtd_ColumnName, prtd_OldValue, prtd_NewValue, prtd_UpdatedBy, prtd_OldText, prtd_NewText )
         SELECT @NextId, @prtx_TransactionId, @Entity, @Action, @Caption, @OldValue, @NewValue, @UserId, delText, insText FROM #TextTable
    END
    ELSE
    BEGIN
      INSERT INTO PRTransactionDetail
            (prtd_TransactionDetailId, prtd_TransactionId, prtd_EntityName, prtd_Action, prtd_ColumnName, prtd_OldValue, prtd_NewValue, prtd_UpdatedBy, prtd_OldText, prtd_NewText )
      VALUES(@NextId, @prtx_TransactionId, @Entity, @Action, @Caption, @OldValue, @NewValue, @UserId, NULL, NULL)
    END
    SET NOCOUNT OFF
END
GO




-- ** PRRating STORED PROCEDURES

/******************************************************************************
 *   Procedure: usp_AutoRemoveRatingNumerals
 *
 *   Return: None.
 *
 *   Decription:  This procedure removes all rating numerals that   
 *                have their autoremove attribute set to 'Y'; if trx's are open
 *                the company is skipped (unless the calling user owns the trx)
 *                Otherwise, trx records are created on the fly
 *
 *****************************************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AutoRemoveRatingNumerals]'))
    drop procedure [dbo].[usp_AutoRemoveRatingNumerals]
GO

CREATE PROCEDURE dbo.usp_AutoRemoveRatingNumerals
    @UserId int = NULL
as
BEGIN
    DECLARE @Msg varchar(2000)
    DECLARE @pran_RNAssignedId int, @comp_companyid int
    DECLARE @TableId_Transaction int
    DECLARE @TrxId int
    DECLARE @TrxCompanyId int
    DECLARE @ctr int

    -- the user id is required
    IF ( @UserId IS NULL) 
    BEGIN
        SET @Msg = 'Update Failed.  An valid User Id must be provided.'
        RAISERROR (@Msg, 16, 1)
        Return
    END

    select @TableId_Transaction = bord_tableId from custom_tables where bord_name = 'PRTransaction'
    SET @ctr = 1
    -- Create a local table for the rating numeral ids to be removed
    DECLARE @tblRNs TABLE (idctr int identity, pran_RatingNumeralAssignedId int, comp_companyid int)

    -- get the values to remove using the same where clause from the user interface
    INSERT INTO @tblRNs 
        SELECT DISTINCT pran_RatingNumeralAssignedId, comp_companyid
        FROM vPRRatingNumeralsToAutoRemove 
        WHERE (comp_companyid Not IN (SELECT prtx_companyid FROM PRtransaction WHERE prtx_Status = 'O' and prtx_CreatedBy != @UserId))
        ORDER BY comp_companyid
    -- Start making our updates
    BEGIN TRANSACTION
	BEGIN TRY	
		SET @TrxCompanyId = NULL
		WHILE (@ctr > 0)
		BEGIN 
			SET @pran_RNAssignedId = null
			SET @comp_companyid = null
			SELECT @pran_RNAssignedId = pran_RatingNumeralAssignedId, @comp_companyid = comp_companyid 
		FROM @tblRNs where idctr = @ctr

			IF (@pran_RNAssignedId is null)
			BEGIN
				SET @ctr = 0
			END

			IF (@TrxCompanyId IS NOT NULL AND 
				(@TrxCompanyId != @comp_companyid OR @comp_companyid IS NULL) AND 
				@TrxId IS NOT NULL)
			BEGIN
			  UPDATE PRTransaction SET prtx_Status = 'C' WHERE prtx_TransactionId = @TrxId
			  SET @TrxId = NULL
			  SET @TrxCompanyId = null
			END


			IF (@ctr != 0)
			BEGIN
			  IF (@TrxCompanyId IS NULL)
			  BEGIN
				  SET @TrxCompanyId = @comp_companyid
				  IF (Not Exists (SELECT 1 FROM PRTransaction 
								  WHERE prtx_Status = 'O' and prtx_companyid = @comp_companyid))
				  BEGIN
					  -- Open a transaction if one is not open
					  exec @TrxId = usp_CreateTransaction 
									 @UserId = @UserId,
									 @prtx_CompanyId = @comp_companyid,
									 @prtx_Explanation = 'Transaction created by Auto Remove Rating Numeral process.'
				  END
			  END
			  DELETE FROM PRRatingNumeralAssigned where pran_RatingNumeralAssignedId = @pran_RNAssignedId

			  SET @ctr = @ctr+1
			END
		END

		-- if we made it here, commit our work
		COMMIT
	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		SELECT	@ErrorMessage = ERROR_MESSAGE(),
				@ErrorSeverity = ERROR_SEVERITY(),
				@ErrorState = ERROR_STATE();

		RAISERROR (@ErrorMessage, 16, @ErrorState);
	END CATCH;


    return SELECT count(1) from @tblRNs

END
GO

-- ********************* CREATE COMPANY-CENTRIC STORED PROCEDURES **********************

/******************************************************************************
 *   Procedure: usp_AssignCompanyInvestigationMethodGroup
 *
 *   Return: N/A
 *
 *   Decription:  This procedure assigns the comp_PRInvestigationMethodGroup
 *                value to each company. 
 *
 *
 *****************************************************************************/
if exists (select * from dbo.sysobjects 
			where id = object_id(N'[dbo].[usp_AssignCompanyInvestigationMethodGroup]') 
				and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_AssignCompanyInvestigationMethodGroup]
GO
CREATE PROCEDURE dbo.usp_AssignCompanyInvestigationMethodGroup
AS
BEGIN
    DECLARE @tblCompanyMirror TABLE (tblid int identity, comp_companyid int, comp_PRInvestigationMethodGroup varchar(1), newGroup varchar(1))
    SET NOCOUNT ON
    -- avoid calling updates on records that have not changed because the instead of trigger on company has to 
    -- do much more processing then we'll have to here
    insert into @tblCompanyMirror
      select * from vCompanyInvestigationMethod

    DECLARE @comp_companyid int, @newGroup char(1), @comp_PRInvestigationMethodGroup char(1)
    DECLARE @ctr int
    SET @ctr = 1
    WHILE (@ctr > 0)
    BEGIN 
        SET @comp_companyId = null
        SET @comp_PRInvestigationMethodGroup= null 
        SET @newGroup = null        
        SELECT @comp_companyid = comp_companyid,
               @comp_PRInvestigationMethodGroup = comp_PRInvestigationMethodGroup, 
               @newGroup = newGroup 
        FROM @tblCompanyMirror 
        where tblid = @ctr

        IF (@comp_companyid is null)
        BEGIN
            SET @ctr = 0
        END
        
        IF (@ctr != 0)
        BEGIN
          -- only attempt an update if the value has changed
          IF ((@newGroup != @comp_PRInvestigationMethodGroup)
              OR (@newGroup is null and @comp_PRInvestigationMethodGroup is not null)
              OR (@newGroup is not null and @comp_PRInvestigationMethodGroup is null))
          BEGIN
            -- notice that changing this value does not require a transaction
            -- this is intentional; this is an internally-managed field
            Update Company SET comp_PRInvestigationMethodGroup = @newGroup 
                where comp_CompanyId = @comp_companyid
          END
          SET @ctr = @ctr+1
        END
    END
    SET NOCOUNT OFF
END
GO

/******************************************************************************
 *   Procedure: usp_ElevateBranch
 *
 *   Return: None.
 *
 *   Decription:  This procedure elevates a branch to become a HQ moving all
 *                informaion related to the branch to the newly created HQ rec
 *
 *****************************************************************************/


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_ElevateBranch]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_ElevateBranch]
GO

CREATE PROCEDURE dbo.usp_ElevateBranch
  @BranchId int = null,
  @UserId int = -1
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @TransactionDetailTypeId int
    -- get the Accpac ID value for this entity so we can get the next available Id
    select @TransactionDetailTypeId = Bord_TableId from custom_tables where Bord_Caption = 'PRTransactionDetail'

    DECLARE @OrigHQId int
    DECLARE @NewCompanyId int
    DECLARE @Now datetime
    
    SET @Now = getDate()

    IF @BranchId is NULL
    BEGIN
      RAISERROR('usp_ElevateBranch: BranchId parameter cannot be NULL',16,1)
      RETURN -1
    END

	-- find the orignal headquarter company Id
	SELECT @OrigHQId = comp_PRHQId from Company WHERE comp_companyid = @BranchId
	

	BEGIN TRY
	    Begin TRANSACTION
    
	
		-- ***********************************************************************************
		-- THIS Section creates the new branch based upon the original HQ

		-- get a new ID for the company 
		exec usp_getNextId 'Company', @NewCompanyId output

		-- create the company record
		INSERT INTO Company
		(
			Comp_CompanyId, Comp_PRType, Comp_PRHQId, Comp_PRListingStatus,
			Comp_PRTradestyle1, Comp_PRTradestyle2, Comp_PRTradestyle3, Comp_PRTradestyle4,
			Comp_Name, Comp_PRCorrTradestyle, Comp_PRBookTradestyle, Comp_PRUnloadHours,
			comp_prlistingcityid, comp_PRDataQualityTier, comp_PRAccountTier,
			comp_prSubordinationAgrProvided, comp_PRSubordinationAgrDate,
			comp_PRRequestFinancials, comp_PRSpecialInstruction,
			comp_PRBusinessStatus, comp_PRDaysPastDue, comp_PRSuspendedService,			
			comp_PRLegalName, comp_PROriginalName, comp_PROldName1, comp_PROldName1Date,
			comp_PROldName2, comp_PROldName2Date, comp_PROldName3, comp_PROldName3Date,
			comp_PRPublishUnloadHours, comp_PRMoralResponsibility, comp_PRSpecialhandlingInstruction,
			comp_PRHandlesInvoicing, comp_PRReceiveLRL, comp_PRTMFMAward,
			comp_PRTMFMAwardDate, comp_PRTMFMCandidate, comp_PRTMFMCandidateDate,
			comp_PRTMFMComments, comp_PRAdministrativeUsage, comp_PRInvestigationMethodGroup,
			comp_PRReceiveTES, comp_PRTESNonresponder, comp_PRCreditWorthCap,
			comp_PRCreditWorthCapReason, comp_PRConfidentialFS, comp_PRJeopardyDate,
			comp_PRSpotlight, comp_PRLogo, comp_PRConnectionListDate, comp_PRFinancialStatementDate,
			comp_PRBusinessReport, comp_PRPrincipalsBackgroundText, comp_PRMethodSourceReceived,
			comp_PRindustryType, comp_PRCommunicationLanguage, comp_PRTradestyleFlag,
			comp_PRPublishDL, comp_DLBillFlag, comp_PRDLDaysPastDue, comp_PRWebActivated,
			comp_PRWebActivatedDate, comp_PRServicesThroughCompanyId,
			Comp_CreatedBy, Comp_UpdatedBy, Comp_CreatedDate, Comp_UpdatedDate, Comp_Timestamp
		)
		Select 	@NewCompanyId, 'B',	@OrigHQId, Comp_PRListingStatus, 
			Comp_PRTradestyle1,	Comp_PRTradestyle2, Comp_PRTradestyle3, Comp_PRTradestyle4,
			Comp_Name, Comp_PRCorrTradestyle, Comp_PRBookTradestyle, Comp_PRUnloadHours,
			comp_prlistingcityid, comp_PRDataQualityTier, comp_PRAccountTier,
			comp_prSubordinationAgrProvided, comp_PRSubordinationAgrDate,
			comp_PRRequestFinancials, comp_PRSpecialInstruction,
			comp_PRBusinessStatus, comp_PRDaysPastDue, comp_PRSuspendedService,			
			comp_PRLegalName, comp_PROriginalName, comp_PROldName1, comp_PROldName1Date,
			comp_PROldName2, comp_PROldName2Date, comp_PROldName3, comp_PROldName3Date,
			comp_PRPublishUnloadHours, comp_PRMoralResponsibility, comp_PRSpecialhandlingInstruction,
			comp_PRHandlesInvoicing, comp_PRReceiveLRL, comp_PRTMFMAward,
			comp_PRTMFMAwardDate, comp_PRTMFMCandidate, comp_PRTMFMCandidateDate,
			comp_PRTMFMComments, comp_PRAdministrativeUsage, comp_PRInvestigationMethodGroup,
			comp_PRReceiveTES, comp_PRTESNonresponder, comp_PRCreditWorthCap,
			comp_PRCreditWorthCapReason, comp_PRConfidentialFS, comp_PRJeopardyDate,
			comp_PRSpotlight, comp_PRLogo, comp_PRConnectionListDate, comp_PRFinancialStatementDate,
			comp_PRBusinessReport, comp_PRPrincipalsBackgroundText, comp_PRMethodSourceReceived,
			comp_PRindustryType, comp_PRCommunicationLanguage, comp_PRTradestyleFlag,
			comp_PRPublishDL, comp_DLBillFlag, comp_PRDLDaysPastDue, comp_PRWebActivated,
			comp_PRWebActivatedDate, comp_PRServicesThroughCompanyId,
			@UserId, @UserId, @Now, @Now, @Now
		FROM Company 
		WHERE comp_companyid = @OrigHQId

		
		-- Move all existing transaction records to the new company
		UPDATE PRTransaction 
		SET prtx_companyid=@NewCompanyId, 
			prtx_UpdatedBy=@UserId, prtx_UpdatedDate=@Now
		WHERE prtx_companyid = @OrigHQId 

		-- the transfer above moves all transactions for the Orig HQ, but a trx may not be open
		-- have had on open, but we have to make sure
		DECLARE @NewBranchTrxId int, @bCreatedNewBranchTrx bit
		SET @bCreatedNewBranchTrx = 0
		SELECT @NewBranchTrxId = prtx_TransactionId FROM PRTransaction 
					  WHERE prtx_Status = 'O' and prtx_companyid = @NewCompanyId
		IF (@NewBranchTrxId is null)
		BEGIN
			-- Open a transaction for the original branch
			Set @bCreatedNewBranchTrx = 1
			exec @NewBranchTrxId = usp_CreateTransaction 
							@UserId = @UserId,
							@prtx_CompanyId = @NewCompanyId,
							@prtx_Explanation = 'Transaction created by the Branch Promotion process.'
		END
		
		-- Make a trx detail entry indicating the start of the promotion
        exec usp_CreateTransactionDetail @NewBranchTrxId, 'Company', 'Promotion', NULL, '', 'This branch was created during demotion of a headquarter.', @UserId, @TransactionDetailTypeId
		
		-- Move any address information to the new company
		UPDATE Address_Link 
		SET adli_companyid=@NewCompanyId, 
			adli_UpdatedBy=@UserId, adli_UpdatedDate=@Now
		WHERE adli_companyid = @OrigHQId 

		-- Move any person information where not in BR to the new company
		UPDATE Person_Link 
		SET peli_companyid = @NewCompanyId,
			peli_UpdatedBy=@UserId, peli_UpdatedDate=@Now
		WHERE peli_companyid = @OrigHQId
			AND peli_PRBRPublish <> ''

		-- Move any telephone information to the new company
		UPDATE Phone 
		SET phon_companyid = @NewCompanyId,
			phon_UpdatedBy=@UserId, phon_UpdatedDate=@Now
		WHERE phon_companyid = @OrigHQId 

		-- Move any email/web information to the new company
		UPDATE Email 
		SET emai_companyid = @NewCompanyId,
			emai_UpdatedBy=@UserId, emai_UpdatedDate=@Now
		WHERE emai_companyid = @OrigHQId 

		-- Move any classification information to the new company
		UPDATE PRCompanyClassification 
		SET prc2_companyid = @NewCompanyId,
			prc2_UpdatedBy=@UserId, prc2_UpdatedDate=@Now
		WHERE prc2_companyid = @OrigHQId 

		-- Move any commodity information to the new company
		UPDATE PRCompanyCommodity 
		SET prcc_companyid = @NewCompanyId,
			prcc_UpdatedBy=@UserId, prcc_UpdatedDate=@Now
		WHERE prcc_companyid = @OrigHQId 

		-- Move any descriptine line information to the new company
		UPDATE PRDescriptiveLine 
		SET prdl_companyid = @NewCompanyId,
			prdl_UpdatedBy=@UserId, prdl_UpdatedDate=@Now
		WHERE prdl_companyid = @OrigHQId 

		IF ( @bCreatedNewBranchTrx = 1)
		BEGIN
			-- close the transaction created for recording Branch promotion to the HQ Comp ID
		    UPDATE PRTransaction SET prtx_Status = 'C' WHERE prtx_TransactionId = @NewBranchTrxId
		END

		-- ***********************************************************************************
		-- This section moves all the elevated branch information to the orig HQ rec

		-- First move all the transactions from the branch id to the old HQ Id; 
		UPDATE PRTransaction 
		SET prtx_companyid=@OrigHQId, 
			prtx_UpdatedBy=@UserId, prtx_UpdatedDate=@Now
		WHERE prtx_companyid = @BranchId 
		
		-- the transfer above should have a trx open for the new HQ because the BranchId rec should
		-- have had on open, but we have to make sure
		DECLARE @HQTrxId int, @bCreatedHQTrx bit
		SET @bCreatedHQTrx = 0
		SELECT @HQTrxId = prtx_TransactionId FROM PRTransaction 
					  WHERE prtx_Status = 'O' and prtx_companyid = @OrigHQId
		IF (@HQTrxId is null)
		BEGIN
			-- Open a transaction for the original branch
			Set @bCreatedHQTrx = 1
			exec @HQTrxId = usp_CreateTransaction 
							@UserId = @UserId,
							@prtx_CompanyId = @OrigHQId,
							@prtx_Explanation = 'Transaction created by the Branch Promotion process.'
		END
		
		-- Make a trx detail entry indicating the start of the promotion
        exec usp_CreateTransactionDetail @HQTrxId, 'Company', 'Promotion', 'Comp_Name', '', 'Promotion Started', @UserId, @TransactionDetailTypeId
		
		-- Move any company information to the HQ rec
		UPDATE Company 
		SET comp_name=c.comp_name,
			comp_PRTradestyle1=c.comp_PRTradestyle1, 
			comp_PRTradestyle2=c.comp_PRTradestyle2, 
			comp_PRTradestyle3=c.comp_PRTradestyle3, 
			comp_PRTradestyle4=c.comp_PRTradestyle4,
			comp_PRBookTradestyle=c.comp_PRBookTradestyle,
			comp_PRCorrTradestyle=c.comp_PRCorrTradestyle,
			comp_PRUnloadHours=c.comp_PRUnloadHours,
			comp_prlistingcityid=c.comp_prlistingcityid, 
			comp_PRDataQualityTier=c.comp_PRDataQualityTier, 
			comp_PRAccountTier=c.comp_PRAccountTier,
			comp_prSubordinationAgrProvided=c.comp_prSubordinationAgrProvided, 
			comp_PRSubordinationAgrDate=c.comp_PRSubordinationAgrDate,
			comp_PRRequestFinancials=c.comp_PRRequestFinancials, 
			comp_PRSpecialInstruction=c.comp_PRSpecialInstruction,
			comp_PRBusinessStatus=c.comp_PRBusinessStatus, 
			comp_PRDaysPastDue=c.comp_PRDaysPastDue, 
			comp_PRSuspendedService=c.comp_PRSuspendedService,			
			comp_PRLegalName=c.comp_PRLegalName, 
			comp_PROriginalName=c.comp_PROriginalName, 
			comp_PROldName1=c.comp_PROldName1, 
			comp_PROldName1Date=c.comp_PROldName1Date,
			comp_PROldName2=c.comp_PROldName2, 
			comp_PROldName2Date=c.comp_PROldName2Date, 
			comp_PROldName3=c.comp_PROldName3, 
			comp_PROldName3Date=c.comp_PROldName3Date,
			comp_PRPublishUnloadHours=c.comp_PRPublishUnloadHours, 
			comp_PRMoralResponsibility=c.comp_PRMoralResponsibility, 
			comp_PRSpecialhandlingInstruction=c.comp_PRSpecialhandlingInstruction,
			comp_PRHandlesInvoicing=c.comp_PRHandlesInvoicing, 
			comp_PRReceiveLRL=c.comp_PRReceiveLRL, 
			comp_PRTMFMAward=c.comp_PRTMFMAward,
			comp_PRTMFMAwardDate=c.comp_PRTMFMAwardDate, 
			comp_PRTMFMCandidate=c.comp_PRTMFMCandidate, 
			comp_PRTMFMCandidateDate=c.comp_PRTMFMCandidateDate,
			comp_PRTMFMComments=c.comp_PRTMFMComments, 
			comp_PRAdministrativeUsage=c.comp_PRAdministrativeUsage, 
			comp_PRInvestigationMethodGroup=c.comp_PRInvestigationMethodGroup,
			comp_PRReceiveTES=c.comp_PRReceiveTES, 
			comp_PRTESNonresponder=c.comp_PRTESNonresponder, 
			comp_PRCreditWorthCap=c.comp_PRCreditWorthCap,
			comp_PRCreditWorthCapReason=c.comp_PRCreditWorthCapReason, 
			comp_PRConfidentialFS=c.comp_PRConfidentialFS, 
			comp_PRJeopardyDate=c.comp_PRJeopardyDate,
			comp_PRSpotlight=c.comp_PRSpotlight, 
			comp_PRLogo=c.comp_PRLogo, 
			comp_PRConnectionListDate=c.comp_PRConnectionListDate, 
			comp_PRFinancialStatementDate=c.comp_PRFinancialStatementDate,
			comp_PRBusinessReport=c.comp_PRBusinessReport, 
			comp_PRPrincipalsBackgroundText=c.comp_PRPrincipalsBackgroundText, 
			comp_PRMethodSourceReceived=c.comp_PRMethodSourceReceived,
			comp_PRindustryType=c.comp_PRindustryType,
			comp_PRCommunicationLanguage=c.comp_PRCommunicationLanguage, 
			comp_PRTradestyleFlag=c.comp_PRTradestyleFlag,
			comp_PRPublishDL=c.comp_PRPublishDL, 
			comp_DLBillFlag=c.comp_DLBillFlag, 
			comp_PRDLDaysPastDue=c.comp_PRDLDaysPastDue, 
			comp_PRWebActivated=c.comp_PRWebActivated,
			comp_PRWebActivatedDate=c.comp_PRWebActivatedDate, 
			comp_PRServicesThroughCompanyId=c.comp_PRServicesThroughCompanyId,
			comp_UpdatedBy=@UserId,
			comp_UpdatedDate=@Now
		FROM 
			(SELECT * FROM Company Where comp_companyid = @BranchId) As c
		WHERE Company.comp_companyid = @OrigHQId

		-- Move any address information to the HQ rec
		UPDATE Address_Link 
		SET adli_companyid=@OrigHQId , 
			adli_UpdatedBy=@UserId, adli_UpdatedDate=@Now
		WHERE adli_companyid = @BranchId 

		-- Move any person information where not in BR to the HQ rec
		UPDATE Person_Link 
		SET peli_companyid = @OrigHQId,
			peli_UpdatedBy=@UserId, peli_UpdatedDate=@Now
		WHERE peli_companyid = @BranchId
			AND peli_PRBRPublish <> ''

		-- Move any telephone information to the HQ rec
		UPDATE Phone 
		SET phon_companyid = @OrigHQId,
			phon_UpdatedBy=@UserId, phon_UpdatedDate=@Now
		WHERE phon_companyid = @BranchId 

		-- Move any email/web information to the HQ rec
		UPDATE Email 
		SET emai_companyid = @OrigHQId,
			emai_UpdatedBy=@UserId, emai_UpdatedDate=@Now
		WHERE emai_companyid = @BranchId 

		-- Move any classification information to the HQ rec
		UPDATE PRCompanyClassification 
		SET prc2_companyid = @OrigHQId,
			prc2_UpdatedBy=@UserId, prc2_UpdatedDate=@Now
		WHERE prc2_companyid = @BranchId 

		-- Move any commodity information to the HQ rec
		UPDATE PRCompanyCommodity 
		SET prcc_companyid = @OrigHQId,
			prcc_UpdatedBy=@UserId, prcc_UpdatedDate=@Now
		WHERE prcc_companyid = @BranchId 

		-- Move any descriptine line information to the HQ rec
		UPDATE PRDescriptiveLine 
		SET prdl_companyid = @OrigHQId,
			prdl_UpdatedBy=@UserId, prdl_UpdatedDate=@Now
		WHERE prdl_companyid = @BranchId 

		-- Make a trx detail entry indicating the start of the promotion
        exec usp_CreateTransactionDetail @HQTrxId, 'Company', 'Promotion', 'Comp_Name', '', 'Promotion Complete', @UserId, @TransactionDetailTypeId
		
		IF ( @bCreatedHQTrx = 1)
		BEGIN
			-- close the transaction created for recording Branch promotion to the HQ Comp ID
		    UPDATE PRTransaction SET prtx_Status = 'C' WHERE prtx_TransactionId = @HQTrxId
		END

		-- ***********************************************************************************
		-- Finally, obsolete the original branch company id record

		-- again, we need a transaction open to make these changes; this should always be true
		-- because a transaction would have been necessary on the interface to get here.
		DECLARE @BranchTrxId int
		SELECT @BranchTrxId = prtx_TransactionId FROM PRTransaction 
					  WHERE prtx_Status = 'O' and prtx_companyid = @BranchId
		IF (@BranchTrxId is null)
		BEGIN
			-- Open a transaction for the original branch
			exec @BranchTrxId = usp_CreateTransaction 
							@UserId = @UserId,
							@prtx_CompanyId = @BranchId,
							@prtx_Explanation = 'Transaction created by the Branch Promotion process.'
			-- Make a trx detail entry indicating the start of the promotion
			exec usp_CreateTransactionDetail @BranchTrxId, 'Company', 'Promotion', 'Comp_Name', '', 'Company record was cleared during Branch Promotion process.', @UserId, @TransactionDetailTypeId
		
		END
		--clear the information of the orignal Branch
		UPDATE Company 
		SET comp_name=NULL,
			comp_PRTradestyle1='', 
			comp_PRTradestyle2=NULL, 
			comp_PRTradestyle3=NULL, 
			comp_PRTradestyle4=NULL,
			comp_PRBookTradestyle=NULL,
			comp_PRCorrTradestyle=NULL,
			comp_PRUnloadHours=NULL,
			comp_UpdatedBy=@UserId,
			comp_UpdatedDate=@Now,
			comp_PRListingStatus='N1'
		WHERE Company.comp_companyid = @BranchId

        -- close this transaction because this company record is obsolete
        UPDATE PRTransaction SET prtx_Status = 'C' WHERE prtx_TransactionId = @BranchTrxId

		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION;

	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity BIGINT;
		DECLARE @ErrorState BIGINT;

		SELECT	@ErrorMessage = ERROR_MESSAGE(),
				@ErrorSeverity = ERROR_SEVERITY(),
				@ErrorState = ERROR_STATE();

		RAISERROR (@ErrorMessage,16, @ErrorState);
	END CATCH;


    SET NOCOUNT OFF

    -- Select * from Company Where comp_companyid in (@NewCompanyId, @OrigHQId, @BranchId);

END
GO


/******************************************************************************
 *   Procedure: usp_DeleteCompanyCommodity
 *
 *   Return: None.
 *
 *   Decription:  This procedure deletes a PRCompanyCommodity record and
 *                any existing attribute records
 *
 *****************************************************************************/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_DeleteCompanyCommodity]') 
            and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_DeleteCompanyCommodity]
GO

CREATE PROCEDURE dbo.usp_DeleteCompanyCommodity
  @prcc_CompanyId int = null,
  @prcc_CommodityId int = null,
  @UserId int = -1
AS
BEGIN
    SET NOCOUNT ON
    -- first delete the attributes
    DELETE FROM PRCompanyCommodityAttribute 
    WHERE prcca_CompanyId = @prcc_CompanyId and prcca_CommodityId = @prcc_CommodityId

    DELETE FROM PRCompanyCommodity 
    WHERE prcc_CompanyId = @prcc_CompanyId and prcc_CommodityId = @prcc_CommodityId
END
GO

/******************************************************************************
 *   Procedure: usp_UpdateCompanyCommodity
 *
 *   Return: None.
 *
 *   Decription:  This procedure determines if the values of a PRCompanyCommodity
 *                record need to have their values updated
 *
 *****************************************************************************/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_UpdateCompanyCommodity]') 
            and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_UpdateCompanyCommodity]
GO

CREATE PROCEDURE dbo.usp_UpdateCompanyCommodity
  @prcc_CompanyId int = null,
  @prcc_CommodityId int = null,
  @prcc_Sequence int = 0,
  @prcc_Publish nchar(1) = null,
  @UserId int = -1
AS
BEGIN
    DECLARE @orig_Sequence int;
    DECLARE @orig_Publish nchar(1);
    
    SET NOCOUNT ON
    -- get the original values
    SELECT @orig_Sequence = prcc_Sequence, @orig_Publish = prcc_Publish
    FROM PRCompanyCommodity 
    WHERE prcc_CompanyId = @prcc_CompanyId and prcc_CommodityId = @prcc_CommodityId
    -- determine if values changed
    IF (  ( (@orig_Sequence != @prcc_Sequence ) OR
            (@orig_Sequence is null and @prcc_Sequence is not null ) OR
            (@orig_Sequence is not null and @prcc_Sequence is null )
          ) OR
          ( (@orig_Publish != @prcc_Publish  ) OR
            (@orig_Publish is null and @prcc_Publish is not null ) OR
            (@orig_Publish is not null and @prcc_Publish is null )
          ) 
       )
    BEGIN
        -- if the userid is null determine who is making this change based on t eopen transaction
        IF (@UserId = NULL)
        BEGIN
            SELECT @UserId = prtx_CreatedBy FROM PRTransaction 
            WHERE prtx_CompanyId = @prcc_CompanyId and prtx_Status='O'
        END
        -- update the record
        UPDATE PRCompanyCommodity 
        SET prcc_Sequence = @prcc_Sequence, prcc_Publish = @prcc_Publish,
            prcc_UpdatedBy=@UserId, prcc_UpdatedDate = getdate()
        WHERE prcc_CompanyId = @prcc_CompanyId and prcc_CommodityId = @prcc_CommodityId
    
    END           
    
END
GO

/******************************************************************************
 *   Procedure: usp_UpdateTMFMStatus
 *
 *   Return: None.
 *
 *   Decription:  This procedure reviews the values send in by the caller and  
 *                implements the associated business rules before updating the
 *                TM/FM fields of the company table.
 *
 *****************************************************************************/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_UpdateTMFMStatus]') 
            and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_UpdateTMFMStatus]
GO

CREATE PROCEDURE dbo.usp_UpdateTMFMStatus
  @comp_CompanyId int = null,
  @comp_PRTMFMAwarded nchar(1) = null,
  @comp_PRTMFMAwardedDate DateTime = null,
  @comp_PRTMFMCandidate nchar(1) = null,
  @comp_PRTMFMCandidateDate DateTime = null,
  @comp_PRTMFMComments text = null,
  @UserId int = -1
AS
BEGIN
    DECLARE @orig_PRTMFMAwarded nchar(1)
    DECLARE @orig_PRType nvarchar(20)
    DECLARE @Return int

    SET @Return = 0
    
    IF (@comp_PRTMFMAwarded = 'N' or @comp_PRTMFMAwarded is NULL)
    BEGIN
        -- get the original values
        SELECT @orig_PRTMFMAwarded = comp_PRTMFMAward, @orig_PRType = comp_PRType
        FROM Company
        WHERE comp_CompanyId = @comp_CompanyId 

        IF (@orig_PRTMFMAwarded = 'Y' AND @orig_PRType = 'H')
        BEGIN
            UPDATE Company 
            SET comp_PRTMFMAward = null, comp_PRTMFMAwardDate = null
            WHERE comp_PRHQId = @comp_CompanyId
            IF @@ROWCOUNT > 0 
            BEGIN
                SET @Return = 1
            END
        END
    END
    
    UPDATE Company 
    SET comp_PRTMFMAward = @comp_PRTMFMAwarded, comp_PRTMFMAwardDate = @comp_PRTMFMAwardedDate,
        comp_PRTMFMCandidate = @comp_PRTMFMCandidate, comp_PRTMFMCandidateDate = @comp_PRTMFMCandidateDate,
        comp_PRTMFMComments = @comp_PRTMFMComments
    WHERE comp_companyid = @comp_CompanyId

    return @Return    
END
GO

/******************************************************************************
 *   Procedure: usp_ReplicateCompanyEmailWeb
 *
 *   Return: Int value indicating success or failure.
 *
 *   Decription:  This procedure copies email table recs to a related company. 
 *                the passed @SourceId will not be used in this routine; the SourceId(s)     
 *                will be determined by the company id. The target companies 
 *				  are passed in the @ReplicateToIds parm.  
 *                This routine unconditionally replaces the existing values.
 *                All updates must be wrapped in a transaction. 
 *                If a trx cannot be opened, all fail.
 *
 *****************************************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_ReplicateCompanyEmailWeb]') 
            and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_ReplicateCompanyEmailWeb]
GO

CREATE PROCEDURE dbo.usp_ReplicateCompanyEmailWeb
  @comp_CompanyId int = null,
  @SourceId int = null,
  @ReplicateToIds varchar(3000) = null,
  @UserId int = -1
AS
BEGIN
    DECLARE @Return int
    DECLARE @Msg varchar(2000)

    SET @Return = 0
    
    IF (@comp_CompanyId IS NULL)
    BEGIN
        SET @Msg = 'Updates Failed.  The Company Id could not be determined.'
        RAISERROR (@Msg, 16, 1)
        Return 1
    End
    
    IF (@ReplicateToIds IS NULL or Len(@ReplicateToIds) = 0)
    BEGIN
        -- should never be here but return 0 because nothing went wrong
        Return 0
    End
    
    -- Create a local table for the Company Ids to be replicated to
    DECLARE @tblReplicateTo TABLE(idx smallint, token varchar(30))    
    DECLARE @CompanyCnt smallint, @LoopIdx smallint, @EmailNdx int
    DECLARE @token varchar(30)
	DECLARE @LinkedEmailId int
	
    DECLARE @TrxId int
    DECLARE @Now DateTime
    DECLARE @NextId int
    
    DECLARE @RepCompanyId int

    DECLARE @tblEmail TABLE(idx smallint identity, email_EmailId int)    

    INSERT INTO @tblReplicateTo SELECT * FROM dbo.Tokenize(@ReplicateToIds, ',')
    SELECT @CompanyCnt = COUNT(1) FROM @tblReplicateTo
    IF (@CompanyCnt >= 1)
    BEGIN
      SET @Now = getDate()
  
      BEGIN TRY
		  BEGIN TRANSACTION
		  -- clear and reset the temp Email table
		  DELETE FROM @tblEmail
		  INSERT INTO @tblEmail SELECT Emai_EmailId from Email Where emai_CompanyId = @comp_CompanyId
			
		  --  Get the value for each caption
		  SET @LoopIdx = 0
		  WHILE (@LoopIdx >= 0)
		  BEGIN
			
			SET @token = null
			SELECT @token = token FROM @tblReplicateTo WHERE idx = @Loopidx
			IF (@token is not null)
			BEGIN
				-- convert the token to a company id int value
				SET @RepCompanyId = convert(int, @token)
				PRINT 'Replicating to company id ' + convert(varchar,@RepCompanyId)
				-- Open a transaction
				exec @TrxId = usp_CreateTransaction 
								@UserId = @UserId,
								@prtx_CompanyId = @RepCompanyId,
								@prtx_Explanation = 'Transaction created by Email Replication.'

				-- go through each record in the tempEmail table and process it
				-- unlike tables populated from Tokenize, tables with an identity field
				-- will start at the value 1
				SET @EmailNdx = 1
				WHILE (@EmailNdx >= 1)
				BEGIN
					SET @SourceId = null
					Select @SourceId = email_EmailId from @tblEmail WHERE idx = @EmailNdx
					IF (@SourceId Is Not Null)
					BEGIN
						-- determine if this record was a previously replicated record
						SELECT @LinkedEmailId = emai_emailid 
						FROM Email
						WHERE emai_CompanyId = @RepCompanyId AND emai_PRReplicatedFromId = @SourceId
			            
						IF (@LinkedEmailId IS NOT NULL)
						BEGIN
							-- Update
							PRINT 'Updating id ' + convert(varchar,@LinkedEmailId)
							Update Email SET
								emai_UpdatedBy = @UserId,
								emai_UpdatedDate = @Now,
								emai_Type = a_Type,
								emai_EmailAddress = a_EmailAddress,
								emai_PRWebAddress = a_PRWebAddress,
								emai_PRDescription = a_PRDescription,
								emai_PRPublish = a_PRPublish,
								emai_PRSequence = a_PRSequence
							FROM (
								SELECT 
									a_Type = emai_Type,
									a_EmailAddress = emai_EmailAddress,
									a_PRWebAddress = emai_PRWebAddress,
									a_PRDescription = emai_PRDescription,
									a_PRPublish = emai_PRPublish,
									a_PRSequence = emai_PRSequence
								FROM Email
								WHERE emai_EmailId = @SourceId
							) ATable
							WHERE emai_emailid = @LinkedEmailId
						END
						ELSE
						BEGIN
							-- Insert
							EXEC usp_GetNextId 'Email', @NextId output

							PRINT 'Inserting id ' + convert(varchar,@NextId )
							INSERT INTO Email 
							 ( emai_EmailId,emai_CompanyId,
							   emai_CreatedBy,emai_createdDate,emai_UpdatedBy,emai_UpdatedDate,emai_TimeStamp,
							   emai_Type,emai_EmailAddress,emai_PRWebAddress,
							   emai_PRDescription,emai_PRPublish,emai_PRSequence,
							   emai_PRReplicatedFromId
							 )  
							SELECT 
								@NextId,@RepCompanyId,
								@UserId,@Now,@UserId,@Now,@Now,  
								emai_Type,emai_EmailAddress,emai_PRWebAddress,
								emai_PRDescription,emai_PRPublish,emai_PRSequence,
								@SourceId
							FROM Email
							WHERE emai_EmailId = @SourceId       
						END
						SET @EmailNdx = @EmailNdx + 1
					END
					ELSE
					BEGIN
						SET @EmailNdx = -1
					END
				END					
				-- close the opened transaction
				UPDATE PRTransaction SET prtx_Status = 'C' WHERE prtx_TransactionId = @TrxId
	            
				SET @LoopIdx = @LoopIdx + 1
			End
			ELSE
			Begin
				SET @LoopIdx = -1
			End  

		  END
		  -- if we made it here, commit our work
		  IF @@TRANCOUNT > 0
			COMMIT TRANSACTION;

		END TRY
		BEGIN CATCH

			IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION;

			DECLARE @ErrorMessage NVARCHAR(4000);
			DECLARE @ErrorSeverity INT;
			DECLARE @ErrorState INT;

			SELECT	@ErrorMessage = ERROR_MESSAGE(),
					@ErrorSeverity = ERROR_SEVERITY(),
					@ErrorState = ERROR_STATE();

			RAISERROR (@ErrorMessage, 
					   @ErrorSeverity,
					   @ErrorState);
		END CATCH;

    END

    return @Return    
END
GO

/******************************************************************************
 *   Procedure: usp_ReplicateCompanyPhone
 *
 *   Return: Int value indicating success or failure.
 *
 *   Decription:  This procedure applies the phone id (@SourceId) to the list of    
 *                companies passed in the @ReplicateToIds parm.  If the record
 *                has been previously replicated, it is updated. Otherwise, it is
 *                created as a new company phone.  All updates must be wrapped in a 
 *                transaction. If a trx cannot be opened, all fail.
 *
 *****************************************************************************/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_ReplicateCompanyPhone]') 
            and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_ReplicateCompanyPhone]
GO

CREATE PROCEDURE dbo.usp_ReplicateCompanyPhone
  @comp_CompanyId int = null,
  @SourceId int = null,
  @ReplicateToIds varchar(3000) = null,
  @UserId int = -1
AS
BEGIN
    DECLARE @Return int
    DECLARE @Msg varchar(2000)

    SET @Return = 0
    
    IF (@SourceId IS NULL)
    BEGIN
        SET @Msg = 'Updates Failed.  The Phone Id could not be determined.'
        RAISERROR (@Msg, 16, 1)
        Return 1
    End
    
    IF (@ReplicateToIds IS NULL or Len(@ReplicateToIds) = 0)
    BEGIN
        -- should never be here but return 0 because nothing went wrong
        Return 0
    End
    
    -- Create a local table for the Company Ids to be replicated to
    DECLARE @tblReplicateTo TABLE(idx smallint, token varchar(30))    
    DECLARE @CompanyCnt smallint, @LoopIdx smallint
    DECLARE @token varchar(30)

    DECLARE @LinkedPhoneId int
    DECLARE @TrxId int
    DECLARE @Now DateTime
        
    DECLARE @RepCompanyId int
    DECLARE @NextId int
    DECLARE @PhoneTableId int
    select @PhoneTableId = bord_tableId from custom_tables where bord_name = 'Phone'
    

    INSERT INTO @tblReplicateTo SELECT * FROM dbo.Tokenize(@ReplicateToIds, ',')
    SELECT @CompanyCnt = COUNT(1) FROM @tblReplicateTo

    BEGIN TRY
		IF (@CompanyCnt >= 1)
		BEGIN
		  --  Get the value for each caption
		  SET @LoopIdx = 0
		  WHILE (@LoopIdx >= 0)
		  BEGIN
			SET @token = null
			SELECT @token = token FROM @tblReplicateTo WHERE idx = @Loopidx
			IF (@token is not null)
			BEGIN
				-- convert the token to a company id int value
				SET @RepCompanyId = convert(int, @token)
				-- Open a transaction
				exec @TrxId = usp_CreateTransaction 
								@UserId = @UserId,
								@prtx_CompanyId = @RepCompanyId,
								@prtx_Explanation = 'Transaction created by Phone Replication.'


				SELECT @LinkedPhoneId = phon_phoneid 
				FROM Phone
				WHERE phon_CompanyId = @RepCompanyId AND phon_PRReplicatedFromId = @SourceId
	            
				SET @Now = getDate()
	            
				IF (@LinkedPhoneId IS NOT NULL)
				BEGIN
					-- Update
					Update Phone SET
						phon_UpdatedBy = @UserId,
						phon_UpdatedDate = @Now,
						phon_Type = a_Type,
						phon_CountryCode = a_CountryCode,
						phon_AreaCode = a_AreaCode,
						phon_Number = a_Number,
						phon_PRDescription = a_PRDescription,
						phon_PRExtension = a_PRExtension,
						phon_PRInternational = a_PRInternational,
						phon_PRCityCode = a_PRCityCode,
						phon_PRPublish = a_PRPublish,
						phon_PRDisconnected = a_PRDisconnected,
						phon_PRSequence = a_PRSequence
					FROM (
						SELECT 
							a_PhoneId = phon_phoneid, 
							a_Type = phon_Type,
							a_CountryCode = phon_CountryCode,
							a_AreaCode = phon_AreaCode,
							a_Number = phon_Number,
							a_PRDescription = phon_PRDescription,
							a_PRExtension = phon_PRExtension,
							a_PRInternational = phon_PRInternational,
							a_PRCityCode = phon_PRCityCode,
							a_PRPublish = phon_PRPublish,
							a_PRDisconnected = phon_PRDisconnected,
							a_PRSequence = phon_PRSequence
						FROM PHONE
						WHERE phon_PhoneId = @SourceId
					) ATable
					WHERE phon_phoneid = @LinkedPhoneId
				END
				ELSE
				BEGIN
					-- Insert
					EXEC @NextId = crm_next_id @PhoneTableId

					INSERT INTO Phone 
					 ( phon_PhoneId,phon_CompanyId,
					   phon_CreatedBy,phon_createdDate,phon_UpdatedBy,phon_UpdatedDate,phon_TimeStamp,
					   phon_Type,phon_CountryCode,phon_AreaCode,phon_Number,
					   phon_PRDescription,phon_PRExtension,phon_PRInternational,
					   phon_PRCityCode,phon_PRPublish,phon_PRDisconnected,phon_PRSequence,
					   phon_PRReplicatedFromId
					 )  
					SELECT 
						@NextId,@RepCompanyId,
						@UserId,@Now,@UserId,@Now,@Now,  
						phon_Type,phon_CountryCode,phon_AreaCode,phon_Number,
						phon_PRDescription,phon_PRExtension,phon_PRInternational,
						phon_PRCityCode,phon_PRPublish,phon_PRDisconnected,phon_PRSequence,
						@SourceId
					FROM Phone
					WHERE phon_phoneid = @SourceId       
				END
	        
				UPDATE PRTransaction SET prtx_Status = 'C' WHERE prtx_TransactionId = @TrxId
	            
				SET @LoopIdx = @LoopIdx + 1
			End
			ELSE
			Begin
				SET @LoopIdx = -1
			End  

		  END
		  COMMIT
	    END
	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity BIGINT;
		DECLARE @ErrorState BIGINT;

		SELECT	@ErrorMessage = ERROR_MESSAGE(),
				@ErrorSeverity = ERROR_SEVERITY(),
				@ErrorState = ERROR_STATE();

		RAISERROR (@ErrorMessage,16, @ErrorState);
	END CATCH;

    return @Return    
END
GO

/******************************************************************************
 *   Procedure: usp_ReplicateCompanyAddress
 *
 *   Return: Int value indicating success or failure.
 *
 *   Decription:  This procedure applies the address id (@SourceId) to the list of    
 *                companies passed in the @ReplicateToIds parm.  If the record
 *                has been previously replicated, it is updated. Otherwise, it is
 *                created as a new company address with link record.  All updates 
 *                must be wrapped in a transaction. If a trx cannot be opened, all fail.
 *
 *****************************************************************************/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_ReplicateCompanyAddress]') 
            and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_ReplicateCompanyAddress]
GO

CREATE PROCEDURE dbo.usp_ReplicateCompanyAddress
  @comp_CompanyId int = null,
  @SourceId int = null,
  @ReplicateToIds varchar(3000) = null,
  @UserId int = -1
AS
BEGIN
    DECLARE @Return int
    DECLARE @Msg varchar(2000)

    SET @Return = 0
    
    IF (@SourceId IS NULL)
    BEGIN
        SET @Msg = 'Updates Failed.  The Address Id could not be determined.'
        RAISERROR (@Msg, 16, 1)
        Return 1
    End
    
    IF (@ReplicateToIds IS NULL or Len(@ReplicateToIds) = 0)
    BEGIN
        -- should never be here but return 0 because nothing went wrong
        Return 0
    End
    
    -- Create a local table for the Company Ids to be replicated to
    DECLARE @tblReplicateTo TABLE(idx smallint, token varchar(30))    
    DECLARE @CompanyCnt smallint, @LoopIdx smallint
    DECLARE @token varchar(30)

    DECLARE @LinkedAddrId int
    DECLARE @TrxId int
    DECLARE @Now DateTime
    
    -- Phone field value that will be copied
    DECLARE @addr_AddressId	int	
    DECLARE @addr_Address1	nvarchar(40)
    DECLARE @addr_Address2	nvarchar(40)
    DECLARE @addr_Address3	nvarchar(40)
    DECLARE @addr_Address4	nvarchar(40)
    DECLARE @addr_Address5	nvarchar(40)
    DECLARE @addr_City	nvarchar(30)
    DECLARE @addr_State	nvarchar(30)
    DECLARE @addr_Country	nvarchar(30)
    DECLARE @addr_PostCode	nvarchar(10)
    DECLARE @addr_uszipplusfour	nvarchar(4)
    DECLARE @addr_PRCityId	int	
    DECLARE @addr_PRCounty	nvarchar(30)
    DECLARE @addr_PRZone	nvarchar(40)
    DECLARE @addr_PRPublish	nchar(1)
    DECLARE @addr_PRDescription	nvarchar(100)

    DECLARE @adli_Type	nvarchar(40)

    DECLARE @RepCompanyId int
    DECLARE @NextAddrId int, @NextAdliId int
    DECLARE @AddrTableId int, @AdliTableId int
    select @AddrTableId = bord_tableId from custom_tables where bord_name = 'Address'
    select @AdliTableId = bord_tableId from custom_tables where bord_name = 'Address_Link'
    

    INSERT INTO @tblReplicateTo SELECT * FROM dbo.Tokenize(@ReplicateToIds, ',')
    SELECT @CompanyCnt = COUNT(1) FROM @tblReplicateTo
	BEGIN TRY
		BEGIN TRANSACTION
		IF (@CompanyCnt >= 1)
		BEGIN
		  --  Get the value for each caption
		  SET @LoopIdx = 0
		  WHILE (@LoopIdx >= 0)
		  BEGIN
			SET @token = null
			SELECT @token = token FROM @tblReplicateTo WHERE idx = @Loopidx
			IF (@token is not null)
			BEGIN
				-- convert the token to a company id int value
				SET @RepCompanyId = convert(int, @token)
				-- Open a transaction
				exec @TrxId = usp_CreateTransaction 
								@UserId = @UserId,
								@prtx_CompanyId = @RepCompanyId,
								@prtx_Explanation = 'Transaction created by Address Replication.'


				SELECT @LinkedAddrId = addr_addressid 
				FROM Address
				JOIN Address_Link ON adli_AddressId = addr_AddressId and 
									adli_CompanyId = @RepCompanyId
				WHERE addr_PRReplicatedFromId = @SourceId
	            
				SET @Now = getDate()
	            
				IF (@LinkedAddrId IS NOT NULL)
				BEGIN
					SELECT 
						@addr_AddressId	=	addr_AddressId,
						@addr_Address1	=	addr_Address1,
						@addr_Address2	=	addr_Address2,
						@addr_Address3	=	addr_Address3,
						@addr_Address4	=	addr_Address4,
						@addr_Address5	=	addr_Address5,
						@addr_City	=	addr_City,
						@addr_State	=	addr_State,
						@addr_Country	=	addr_Country,
						@addr_PostCode	=	addr_PostCode,
						@addr_uszipplusfour	=	addr_uszipplusfour,
						@addr_PRCityId	=	addr_PRCityId,
						@addr_PRCounty	=	addr_PRCounty,
						@addr_PRZone	=	addr_PRZone,
						@addr_PRPublish	=	addr_PRPublish,
						@addr_PRDescription	=	addr_PRDescription,
						@adli_Type = adli_Type
					FROM Address
					JOIN Address_Link ON adli_addressId = addr_AddressId
					WHERE addr_AddressId = @SourceId

					-- Update
					Update Address SET
						addr_UpdatedBy = @UserId,
						addr_UpdatedDate = @Now,
						addr_Address1	= @addr_Address1,
						addr_Address2	= @addr_Address2,
						addr_Address3	= @addr_Address3,
						addr_Address4	= @addr_Address4,
						addr_Address5	= @addr_Address5,
						addr_City	= @addr_City,
						addr_State	= @addr_State,
						addr_Country	= @addr_Country,
						addr_PostCode	= @addr_PostCode,
						addr_uszipplusfour	= @addr_uszipplusfour,
						addr_PRCityId	= @addr_PRCityId,
						addr_PRCounty	= @addr_PRCounty,
						addr_PRZone	= @addr_PRZone,
						addr_PRPublish	= @addr_PRPublish,
						addr_PRDescription	= @addr_PRDescription,
						addr_PRReplicatedFromId = @SourceId
					WHERE addr_addressid = @LinkedAddrId
					Update Address_Link SET
						adli_UpdatedBy = @UserId,
						adli_UpdatedDate = @Now,
						adli_Type	= @adli_Type
					WHERE adli_addressid = @LinkedAddrId
				END
				ELSE
				BEGIN
					-- Insert
					EXEC @NextAddrId = crm_next_id @AddrTableId
					EXEC @NextAdliId = crm_next_id @AdliTableId

					INSERT INTO Address
					 ( addr_AddressId,
					   addr_CreatedBy,addr_createdDate,addr_UpdatedBy,addr_UpdatedDate,addr_TimeStamp,
						addr_Address1,addr_Address2,addr_Address3,addr_Address4,addr_Address5,
						addr_City,addr_State,addr_Country,addr_PostCode,addr_uszipplusfour,
						addr_PRCityId,addr_PRCounty,addr_PRZone,addr_PRPublish,addr_PRDescription,
						addr_PRReplicatedFromId
					 )  
					SELECT 
						@NextAddrId,
						@UserId,@Now,@UserId,@Now,@Now,  
						addr_Address1,addr_Address2,addr_Address3,addr_Address4,addr_Address5,
						addr_City,addr_State,addr_Country,addr_PostCode,addr_uszipplusfour,
						addr_PRCityId,addr_PRCounty,addr_PRZone,addr_PRPublish,addr_PRDescription,
						@SourceId
					FROM Address
					WHERE addr_addressid = @SourceId       

					INSERT INTO Address_Link 
					 ( adli_AddressLinkId,adli_CompanyId,adli_AddressId,
					   adli_CreatedBy,adli_createdDate,adli_UpdatedBy,adli_UpdatedDate,adli_TimeStamp,
						adli_Type
					 )  
					SELECT 
						@NextAddrId,@RepCompanyId,@NextAddrId,
						@UserId,@Now,@UserId,@Now,@Now,  
						adli_Type
					FROM Address_Link
					WHERE adli_addressid = @SourceId       
				END
	        
				UPDATE PRTransaction SET prtx_Status = 'C' WHERE prtx_TransactionId = @TrxId
	            
				SET @LoopIdx = @LoopIdx + 1
			End
			ELSE
			Begin
				SET @LoopIdx = -1
			End  

		  END
		  -- if we made it here, commit our work
		  COMMIT
		END
	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity BIGINT;
		DECLARE @ErrorState BIGINT;

		SELECT	@ErrorMessage = ERROR_MESSAGE(),
				@ErrorSeverity = ERROR_SEVERITY(),
				@ErrorState = ERROR_STATE();

		RAISERROR (@ErrorMessage,16, @ErrorState);
	END CATCH;


    return @Return    
END
GO

/******************************************************************************
 *   Procedure: usp_ReplicateCompanyCommodity
 *
 *   Return: Int value indicating success or failure.
 *
 *   Decription:  This procedure applies the commodity and attributes of the
 *                selected company (@comp_CompanyId will = @SourceId in this 
 *                routine; either can be used) to the list of companies passed in 
 *                the @ReplicateToIds parm.  A union of the existing PRCompanyCommodity
 *                values will be performed.  Then a union of PRCompanyCommodityAttribute
 *                will be performed. No existing Commodity or Attributes on the target
 *                company will be removed.  All updates must be wrapped in a transaction.
 *                If a trx cannot be opened, all fail.
 *
 *****************************************************************************/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_ReplicateCompanyCommodity]') 
            and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_ReplicateCompanyCommodity]
GO

CREATE PROCEDURE dbo.usp_ReplicateCompanyCommodity
  @comp_CompanyId int = null,
  @SourceId int = null,
  @ReplicateToIds varchar(3000) = null,
  @UserId int = -1
AS
BEGIN
    DECLARE @Return int
    DECLARE @Msg varchar(2000)

    SET @Return = 0
    IF (@comp_CompanyId IS NULL)
        SET @comp_CompanyId = @SourceId
    IF (@comp_CompanyId IS NULL)
    BEGIN
        SET @Msg = 'Updates Failed.  The Company Id could not be determined.'
        RAISERROR (@Msg, 16, 1)
        Return 1
    End
    SET @SourceId = @comp_CompanyId
    
    IF (@ReplicateToIds IS NULL or Len(@ReplicateToIds) = 0)
    BEGIN
        -- should never be here but return 0 because nothing went wrong
        Return 0
    End
    
    -- Create a local table for the Company Ids to be replicated to
    DECLARE @tblReplicateTo TABLE(idx smallint, token varchar(30))    
    DECLARE @CompanyCnt smallint, @LoopIdx smallint
    DECLARE @token varchar(30)

    DECLARE @TrxId int
    DECLARE @Now DateTime
    
    -- Commodity field values that will be copied
    DECLARE @prcc_CommodityId	int
    DECLARE @prcc_Publish nchar(1)

    -- CommodityAttribute field values that will be copied
    DECLARE @prcca_CommodityId	int
    DECLARE @prcca_AttributeId	int
    DECLARE @prcca_Publish nchar(1)

    -- Create a local table for the CommoditiesAttributes to be unioned
    DECLARE @tblCAs TABLE(ndx smallint identity, 
                    ca_CommodityId int, ca_GrowingMethodId int, ca_AttributeId int, 
                    ca_Publish nchar(1), ca_PublishWithGM nchar(1), ca_PublishedDisplay varchar(200))    
    INSERT INTO @tblCAs 
            SELECT prcca_CommodityId, prcca_GrowingMethodId, prcca_AttributeId, prcca_Publish,
                   prcca_PublishWithGM, prcca_PublishedDisplay
            FROM PRCompanyCommodityAttribute 
            WHERE prcca_CompanyId = @SourceId
    DECLARE @ndxCA smallint
    DECLARE @ca_CommodityId int, @ca_GrowingMethodId int, @ca_AttributeId int, 
            @ca_Publish nchar(1), @ca_PublishWithGM nchar(1), @ca_PublishedDisplay varchar(200)

    DECLARE @RepCompanyId int
    DECLARE @NextPRCCAId int
    DECLARE @PRCCATableId int
    select @PRCCATableId = bord_tableId from custom_tables where bord_name = 'PRCompanyCommodityAttribute'
            
    SET @Now = getDate()

    INSERT INTO @tblReplicateTo SELECT * FROM dbo.Tokenize(@ReplicateToIds, ',')
    SELECT @CompanyCnt = COUNT(1) FROM @tblReplicateTo
    IF (@CompanyCnt >= 1)
    BEGIN
		BEGIN TRY
		  BEGIN TRANSACTION
		  SET @LoopIdx = 0
		  WHILE (@LoopIdx >= 0)
		  BEGIN
			SET @token = null
			SELECT @token = token FROM @tblReplicateTo WHERE idx = @Loopidx
			IF (@token is not null)
			BEGIN
				-- convert the token to a company id int value
				SET @RepCompanyId = convert(int, @token)
				-- Open a transaction
				exec @TrxId = usp_CreateTransaction 
								@UserId = @UserId,
								@prtx_CompanyId = @RepCompanyId,
								@prtx_Explanation = 'Transaction created by Commodity Replication.'
				-- Get the first CommodityAttribute in the list
				SET @ndxCA = 1
				While (@ndxCA > 0)
				BEGIN
					SET @ca_CommodityId = null;
					SELECT @ca_CommodityId = ca_CommodityId, @ca_GrowingMethodId = ca_GrowingMethodId,
							@ca_AttributeId = ca_AttributeId, @ca_Publish = ca_Publish, 
							@ca_PublishWithGM = ca_PublishWithGM, @ca_PublishedDisplay = ca_PublishedDisplay
					FROM @tblCAs WHERE ndx = @ndxCA
					IF (@ca_CommodityId is null)
						SET @ndxCA = -1
					ELSE
					BEGIN
						-- Determine if the rep company already handles this commoidty/attribute
						if ( exists(select 1 from PRCompanyCommodityAttribute 
									where prcca_companyid = @RepCompanyId and 
										  prcca_PublishedDisplay = @ca_PublishedDisplay))
						begin
							UPDATE PRCompanyCommodityAttribute SET 
								prcca_UpdatedBy = @UserId,
								prcca_UpdatedDate = @Now,
								prcca_TimeStamp = @Now,
								prcca_Publish = @ca_Publish,
								prcca_PublishWithGM = @ca_PublishWithGM
							WHERE prcca_companyid = @RepCompanyId and 
								  prcca_PublishedDisplay = @ca_PublishedDisplay
							IF @@ERROR <> 0
							BEGIN
    							ROLLBACK
								SET @Msg = 'Update Failed.  Error creating the PRCompanyCommodityAttribute record.' 
								RAISERROR(@Msg,16,1)
    							RETURN -2
							END
						end
						else
						begin
							EXEC @NextPRCCAId = crm_next_id @PRCCATableId
							INSERT INTO PRCompanyCommodityAttribute
							( prcca_CompanyCommodityAttributeId,
								prcca_CreatedBy,prcca_createdDate,prcca_UpdatedBy,prcca_UpdatedDate,prcca_TimeStamp,
								prcca_CompanyId, prcca_CommodityId, prcca_GrowingMethodId, prcca_AttributeId, 
								prcca_Publish, prcca_PublishWithGM, prcca_PublishedDisplay
							)  
							VALUES ( 
								@NextPRCCAId,
								@UserId,@Now,@UserId,@Now,@Now,  
								@RepCompanyId, @ca_CommodityId, @ca_AttributeId, @ca_GrowingMethodId, 
								@ca_Publish, @ca_PublishWithGM, @ca_PublishedDisplay
							)       
							IF @@ERROR <> 0
							BEGIN
    							ROLLBACK
								SET @Msg = 'Insert Failed.  Error creating the PRCompanyCommodityAttribute record.' 
								RAISERROR(@Msg,16,1)
    							RETURN -3
							END
						end
						SET @ndxCA = @ndxCA + 1
					END
				END
				UPDATE PRTransaction SET prtx_Status = 'C' WHERE prtx_TransactionId = @TrxId
	            
				SET @LoopIdx = @LoopIdx + 1
			End
			ELSE
			Begin
				SET @LoopIdx = -1
			End  

		  END
		  -- if we made it here, commit our work
		  COMMIT
		END TRY
		BEGIN CATCH

			IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION;

			DECLARE @ErrorMessage NVARCHAR(4000);
			DECLARE @ErrorSeverity BIGINT;
			DECLARE @ErrorState BIGINT;

			SELECT	@ErrorMessage = ERROR_MESSAGE(),
					@ErrorSeverity = ERROR_SEVERITY(),
					@ErrorState = ERROR_STATE();

			RAISERROR (@ErrorMessage,16, @ErrorState);
		END CATCH;


    END

    return @Return    
END
GO

/******************************************************************************
 *   Procedure: usp_ReplicateCompanyClassification
 *
 *   Return: Int value indicating success or failure.
 *
 *   Decription:  This procedure applies the classifications of the
 *                selected company (@comp_CompanyId will = @SourceId in this 
 *                routine; either can be used) to the list of companies passed in 
 *                the @ReplicateToIds parm.  A union of the existing 
 *                PRCompanyClassification values will be performed. No existing  
 *                Commodity or Attributes on the target company will be removed.   
 *                All updates must be wrapped in a transaction. If a trx cannot 
 *                be opened, all fail.
 *
 *****************************************************************************/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_ReplicateCompanyClassification]') 
            and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_ReplicateCompanyClassification]
GO

CREATE PROCEDURE dbo.usp_ReplicateCompanyClassification
  @comp_CompanyId int = null,
  @SourceId int = null,
  @ReplicateToIds varchar(3000) = null,
  @UserId int = -1
AS
BEGIN
    DECLARE @Return int
    DECLARE @Msg varchar(2000)

    SET @Return = 0
    
    IF (@SourceId IS NULL)
        SET @SourceId = @comp_CompanyId
    IF (@SourceId IS NULL)
    BEGIN
        SET @Msg = 'Updates Failed.  The Company Id could not be determined.'
        RAISERROR (@Msg, 16, 1)
        Return 1
    End
    
    IF (@ReplicateToIds IS NULL or Len(@ReplicateToIds) = 0)
    BEGIN
        -- should never be here but return 0 because nothing went wrong
        Return 0
    End
    
    -- Create a local table for the Company Ids to be replicated to
    DECLARE @tblReplicateTo TABLE(idx smallint, token varchar(30))    
    DECLARE @CompanyCnt smallint, @LoopIdx smallint
    DECLARE @token varchar(30)

    DECLARE @TrxId int
    DECLARE @Now DateTime
    
    -- Classification field values that will be copied
    DECLARE @prc2_ClassificationId	int
    DECLARE @prc2_Percentage numeric(13)
    DECLARE @prc2_PercentageSource	nchar(1)
    DECLARE @prc2_NumberOfStores varchar(40)
    DECLARE @prc2_ComboStores	nchar(1)
    DECLARE @prc2_NumberOfComboStores varchar(40)
    DECLARE @prc2_ConvenienceStores	nchar(1)
    DECLARE @prc2_NumberOfConvenienceStores varchar(40)
    DECLARE @prc2_GourmetStores	nchar(1)
    DECLARE @prc2_NumberOfGourmetStores varchar(40)
    DECLARE @prc2_HealthFoodStores	nchar(1)
    DECLARE @prc2_NumberOfHealthFoodStores varchar(40)
    DECLARE @prc2_ProduceOnlyStores	nchar(1)
    DECLARE @prc2_NumberOfProduceOnlyStores varchar(40)
    DECLARE @prc2_SupermarketStores	nchar(1)
    DECLARE @prc2_NumberOfSupermarketStores varchar(40)
    DECLARE @prc2_SuperStores	nchar(1)
    DECLARE @prc2_NumberOfSuperStores varchar(40)
    DECLARE @prc2_WarehouseStores	nchar(1)
    DECLARE @prc2_NumberOfWarehouseStores varchar(40)
    DECLARE @prc2_AirFreight	nchar(1)
    DECLARE @prc2_OceanFreight	nchar(1)
    DECLARE @prc2_GroundFreight	nchar(1)
    DECLARE @prc2_RailFreight	nchar(1)
    
    -- Create a local table for the Commodities to be unioned
    DECLARE @tblClassifications TABLE(ndx smallint identity, cl_ClassificationId int)    
    DECLARE @ndxClassification smallint
    DECLARE @cl_ClassificationId int
    INSERT INTO @tblClassifications SELECT prc2_ClassificationId
                                FROM PRCompanyClassification 
                                WHERE prc2_CompanyId = @SourceId

    DECLARE @RepCompanyId int
    DECLARE @NextPRC2Id int
    DECLARE @PRC2TableId int
    select @PRC2TableId = bord_tableId from custom_tables where bord_name = 'PRCompanyClassification'
            
    SET @Now = getDate()

    INSERT INTO @tblReplicateTo SELECT * FROM dbo.Tokenize(@ReplicateToIds, ',')
    SELECT @CompanyCnt = COUNT(1) FROM @tblReplicateTo
    IF (@CompanyCnt >= 1)
    BEGIN
      BEGIN TRY
		  BEGIN TRANSACTION
		  SET @LoopIdx = 0
		  WHILE (@LoopIdx >= 0)
		  BEGIN
			SET @token = null
			SELECT @token = token FROM @tblReplicateTo WHERE idx = @Loopidx
			IF (@token is not null)
			BEGIN
				-- convert the token to a company id int value
				SET @RepCompanyId = convert(int, @token)
				-- Open a transaction
				exec @TrxId = usp_CreateTransaction 
								@UserId = @UserId,
								@prtx_CompanyId = @RepCompanyId,
								@prtx_Explanation = 'Transaction created by Classification Replication.'
				-- Process the Classifications
				SET @ndxClassification = 1
				While (@ndxClassification > 0)
				BEGIN
					SET @prc2_ClassificationId = null
					SELECT @prc2_ClassificationId = cl_ClassificationId 
					FROM @tblClassifications 
					WHERE ndx=@ndxClassification
					IF (@prc2_ClassificationId IS NULL)
						SET @ndxClassification = -1
					ELSE 
					BEGIN
						IF (Exists( SELECT 1 FROM PRCompanyClassification
									WHERE prc2_CompanyId = @RepCompanyId 
									AND prc2_ClassificationId = @prc2_ClassificationId))
						BEGIN
							SELECT 
								@prc2_Percentage = prc2_Percentage,
								@prc2_PercentageSource = prc2_PercentageSource,
								@prc2_NumberOfStores = prc2_NumberOfStores,
								@prc2_ComboStores = prc2_ComboStores,
								@prc2_NumberOfComboStores = prc2_NumberOfComboStores,
								@prc2_ConvenienceStores	= prc2_ConvenienceStores,
								@prc2_NumberOfConvenienceStores = prc2_NumberOfConvenienceStores,
								@prc2_GourmetStores = prc2_GourmetStores,
								@prc2_NumberOfGourmetStores = prc2_NumberOfGourmetStores,
								@prc2_HealthFoodStores = prc2_HealthFoodStores,
								@prc2_NumberOfHealthFoodStores = prc2_NumberOfHealthFoodStores,
								@prc2_ProduceOnlyStores = prc2_ProduceOnlyStores,
								@prc2_NumberOfProduceOnlyStores = prc2_NumberOfProduceOnlyStores,
								@prc2_SupermarketStores = prc2_SupermarketStores,
								@prc2_NumberOfSupermarketStores = prc2_NumberOfSupermarketStores,
								@prc2_SuperStores = prc2_SuperStores,
								@prc2_NumberOfSuperStores = prc2_NumberOfSuperStores,
								@prc2_WarehouseStores = prc2_WarehouseStores,
								@prc2_NumberOfWarehouseStores = prc2_NumberOfWarehouseStores,
								@prc2_AirFreight = prc2_AirFreight,
								@prc2_OceanFreight = prc2_OceanFreight,
								@prc2_GroundFreight = prc2_GroundFreight,
								@prc2_RailFreight = prc2_RailFreight
							FROM PRCompanyClassification
							WHERE prc2_CompanyId = @SourceId AND prc2_ClassificationId = @prc2_ClassificationId

							-- Update
							Update PRCompanyClassification SET
								prc2_UpdatedBy = @UserId,
								prc2_UpdatedDate = @Now,
								prc2_Percentage = @prc2_Percentage,
								prc2_PercentageSource = @prc2_PercentageSource,
								prc2_NumberOfStores = @prc2_NumberOfStores,
								prc2_ComboStores = @prc2_ComboStores,
								prc2_NumberOfComboStores = @prc2_NumberOfComboStores,
								prc2_ConvenienceStores	= @prc2_ConvenienceStores,
								prc2_NumberOfConvenienceStores = @prc2_NumberOfConvenienceStores,
								prc2_GourmetStores = @prc2_GourmetStores,
								prc2_NumberOfGourmetStores = @prc2_NumberOfGourmetStores,
								prc2_HealthFoodStores = @prc2_HealthFoodStores,
								prc2_NumberOfHealthFoodStores = @prc2_NumberOfHealthFoodStores,
								prc2_ProduceOnlyStores = @prc2_ProduceOnlyStores,
								prc2_NumberOfProduceOnlyStores = @prc2_NumberOfProduceOnlyStores,
								prc2_SupermarketStores = @prc2_SupermarketStores,
								prc2_NumberOfSupermarketStores = @prc2_NumberOfSupermarketStores,
								prc2_SuperStores = @prc2_SuperStores,
								prc2_NumberOfSuperStores = @prc2_NumberOfSuperStores,
								prc2_WarehouseStores = @prc2_WarehouseStores,
								prc2_NumberOfWarehouseStores = @prc2_NumberOfWarehouseStores,
								prc2_AirFreight = @prc2_AirFreight,
								prc2_OceanFreight = @prc2_OceanFreight,
								prc2_GroundFreight = @prc2_GroundFreight,
								prc2_RailFreight = @prc2_RailFreight
							WHERE prc2_CompanyId = @RepCompanyId AND prc2_ClassificationId = @prc2_ClassificationId
						END
						ELSE
						BEGIN
							-- Insert
							EXEC @NextPRC2Id = crm_next_id @PRC2TableId

							INSERT INTO PRCompanyClassification
							( prc2_CompanyClassificationId, prc2_CompanyId, prc2_ClassificationId,
							prc2_CreatedBy,prc2_createdDate,prc2_UpdatedBy,prc2_UpdatedDate,prc2_TimeStamp,
								prc2_Percentage, prc2_PercentageSource, prc2_NumberOfStores,
								prc2_ComboStores, prc2_NumberOfComboStores, 
								prc2_ConvenienceStores, prc2_NumberOfConvenienceStores, 
								prc2_GourmetStores, prc2_NumberOfGourmetStores,
								prc2_HealthFoodStores, prc2_NumberOfHealthFoodStores,
								prc2_ProduceOnlyStores, prc2_NumberOfProduceOnlyStores,
								prc2_SupermarketStores, prc2_NumberOfSupermarketStores,
								prc2_SuperStores, prc2_NumberOfSuperStores,
								prc2_WarehouseStores, prc2_NumberOfWarehouseStores,
								prc2_AirFreight, prc2_OceanFreight, prc2_GroundFreight, prc2_RailFreight
	                            
							)  
							SELECT 
								@NextPRC2Id, @RepCompanyId, @prc2_ClassificationId,
								@UserId,@Now,@UserId,@Now,@Now,
								prc2_Percentage, prc2_PercentageSource, prc2_NumberOfStores,
								prc2_ComboStores, prc2_NumberOfComboStores, 
								prc2_ConvenienceStores, prc2_NumberOfConvenienceStores, 
								prc2_GourmetStores, prc2_NumberOfGourmetStores,
								prc2_HealthFoodStores, prc2_NumberOfHealthFoodStores,
								prc2_ProduceOnlyStores, prc2_NumberOfProduceOnlyStores,
								prc2_SupermarketStores, prc2_NumberOfSupermarketStores,
								prc2_SuperStores, prc2_NumberOfSuperStores,
								prc2_WarehouseStores, prc2_NumberOfWarehouseStores,
								prc2_AirFreight, prc2_OceanFreight, prc2_GroundFreight, prc2_RailFreight
							FROM PRCompanyClassification
							WHERE prc2_CompanyId = @SourceId AND prc2_ClassificationId = @prc2_ClassificationId
						END

						SET @ndxClassification = @ndxClassification + 1
					END
				END
				UPDATE PRTransaction SET prtx_Status = 'C' WHERE prtx_TransactionId = @TrxId
	            
				SET @LoopIdx = @LoopIdx + 1
			End
			ELSE
			Begin
				SET @LoopIdx = -1
			End  

		  END
		  -- if we made it here, commit our work
		  COMMIT
		END TRY
		BEGIN CATCH

			IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION;

			DECLARE @ErrorMessage NVARCHAR(4000);
			DECLARE @ErrorSeverity BIGINT;
			DECLARE @ErrorState BIGINT;

			SELECT	@ErrorMessage = ERROR_MESSAGE(),
					@ErrorSeverity = ERROR_SEVERITY(),
					@ErrorState = ERROR_STATE();

			RAISERROR (@ErrorMessage,16, @ErrorState);
		END CATCH;

    END

    return @Return    
END
GO

-- ********************* END COMPANY_CENTRIC STORED PROCEDURE CREATION *****************

-- ********************* CREATE PACA-CENTRIC STORED PROCEDURES **********************

/******************************************************************************
 *   Procedure: usp_CreateImportPACALicense
 *
 *   Return: int - the id of the new record
 *
 *   Decription:  This procedure creates a new PRImportPACALicense record
 *                supporting the import from file method 
 *
 *
 *****************************************************************************/
if exists (select * from dbo.sysobjects 
			where id = object_id(N'[dbo].[usp_CreateImportPACALicense]') 
				and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_CreateImportPACALicense]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE dbo.usp_CreateImportPACALicense
	@pril_FileName		nvarchar(50)	= null,
	@pril_ImportDate	datetime		= null,
	@pril_LicenseNumber	nvarchar(50)	= null,
	@pril_ExpirationDate datetime		= null,
	@pril_CompanyName	nvarchar(80)	= null,
	@pril_Address1		nvarchar(64)	= null,
	@pril_Address2		nvarchar(64)	= null,
	@pril_City			nvarchar(24)	= null,
	@pril_State			nvarchar(2)	    = null,
	@pril_Country		nvarchar(20)	= null,
	@pril_PostCode		nvarchar(10)	= null,
	@pril_MailAddress1	nvarchar(64)	= null,
	@pril_MailAddress2	nvarchar(64)	= null,
	@pril_MailCity		nvarchar(24)	= null,
	@pril_MailState		nvarchar(2)	    = null,
	@pril_MailCountry	nvarchar(50)	= null,
	@pril_MailPostCode	nvarchar(50)	= null,
	@pril_IncState		nvarchar(50)	= null,
	@pril_IncDate		datetime		= null,
	@pril_OwnCode		nvarchar(10)	= null,
	@pril_Telephone		nvarchar(10)	= null,
	@pril_TerminateDate	datetime		= null,
	@pril_TerminateCode	nvarchar(10)	= null,
	@pril_PACARunDate	datetime		= null,
	@pril_TypeFruitVeg  nvarchar(40)    = null,
	@pril_ProfCode      nvarchar(40)    = null,
	@UserId int = -1
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @Now DateTime
    SET @Now = getDate()

	Declare @Msg varchar(1000)
	declare @TableId int

	declare @pril_ImportPACALicenseId	int

	BEGIN TRY
		BEGIN TRANSACTION;
		-- get a new ID for the entity
		exec usp_getNextId 'PRImportPACALicense', @pril_ImportPACALicenseId output
		-- create the new Import PACA record
		INSERT INTO PRImportPACALicense
		(
			pril_ImportPACALicenseId, 
			pril_CreatedBy, pril_CreatedDate, pril_UpdatedBy, pril_UpdatedDate,	pril_TimeStamp, pril_Deleted,
			pril_FileName, pril_ImportDate, pril_LicenseNumber,
			pril_ExpirationDate, pril_CompanyName, pril_Address1, pril_Address2, pril_City,
			pril_State,	pril_Country, pril_PostCode, pril_MailAddress1,	pril_MailAddress2,
			pril_MailCity, pril_MailState, pril_MailCountry, pril_MailPostCode,	pril_IncState,
			pril_IncDate, pril_OwnCode,	pril_Telephone,	pril_TerminateDate,	pril_TerminateCode,
			pril_TypeFruitVeg, pril_ProfCode, pril_PACARunDate
		) Values (
			@pril_ImportPACALicenseId,
			@UserId, @Now,	@UserId, @Now,	@Now, null,
			@pril_FileName, @pril_ImportDate, @pril_LicenseNumber,
			@pril_ExpirationDate, @pril_CompanyName, @pril_Address1, @pril_Address2, @pril_City,
			@pril_State, @pril_Country, @pril_PostCode,	@pril_MailAddress1,	@pril_MailAddress2,
			@pril_MailCity,	@pril_MailState, @pril_MailCountry,	@pril_MailPostCode,	@pril_IncState,
			@pril_IncDate, @pril_OwnCode, @pril_Telephone, @pril_TerminateDate,	@pril_TerminateCode,
			@pril_TypeFruitVeg,	@pril_ProfCode,	@pril_PACARunDate
		)	
		
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION;

	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		SELECT	@ErrorMessage = ERROR_MESSAGE(),
				@ErrorSeverity = ERROR_SEVERITY(),
				@ErrorState = ERROR_STATE();

		RAISERROR (@ErrorMessage, 
				   @ErrorSeverity,
				   @ErrorState);
	END CATCH;

    SET NOCOUNT OFF

	return @pril_ImportPACALicenseId
END
GO

/******************************************************************************
 *   Procedure: usp_PACAProcessImports
 *
 *   Return: int - the number of import record processed into PACA License table
 *
 *   Decription:  This procedure itereates through the ImportPACA... tables and
 *                determines if a matching License Number can be found in the 
 *				  real paca tables.  If so, the record is processed.
 *
 *
 *****************************************************************************/
if exists (select * from dbo.sysobjects 
			where id = object_id(N'[dbo].[usp_PACAProcessImports]') 
				and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_PACAProcessImports]
GO

CREATE PROCEDURE dbo.usp_PACAProcessImports
	@UserId int = -1
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @Now DateTime
    SET @Now = getDate()

	DECLARE @ImportTable Table (ndx int identity, LicenseId int, LicenseNumber varchar(20))
	Declare @Msg varchar(1000)
	declare @TableId int

	declare @pril_ImportPACALicenseId	int

	-- select all the License numbers into the temp table
	Declare @RecordCount int
	INSERT INTO @ImportTable SELECT pril_ImportPACALicenseId, pril_LicenseNumber FROM PRImportPACALicense
	SET @RecordCount = @@ROWCOUNT
	Declare @ndx int
	Declare @pril_LicenseId int, @pril_LicenseNumber varchar(20)
	set @ndx=1

	Declare @ExistingPACACompany int, @ExistingPACALicenseId int, @NewLicenseId int
	Declare @AutoConvertedCount int
	SET @AutoConvertedCount = 0
	
	WHILE (@ndx <= @RecordCount)
	BEGIN
		SET @ExistingPACALicenseId = NULL
		SELECT @pril_LicenseId=LicenseId, @pril_LicenseNumber=LicenseNumber
		  FROM @ImportTable WHERE ndx = @ndx
	
		-- determine if this license number is already in use
		SELECT @ExistingPACALicenseId=prpa_PACALicenseId, @ExistingPACACompany=prpa_CompanyId 
		  FROM PRPACALicense 
		 WHERE prpa_LicenseNumber = @pril_LicenseNumber and prpa_Current = 'Y'


		IF (@ExistingPACALicenseId IS NOT NULL)
		BEGIN
			-- There is an existing paca record with this number so we are going to "mark the current as deleted"
			-- for history and create this new import record directly into the PRPACALicense table
			exec @NewLicenseId = usp_CreatePACAFromImport 
											@pril_ImportPACALicenseId = @pril_LicenseId ,
											@UserId = @UserId,
											@DeleteImport = 1,
											@SendNotifications = 1,
											@Type = 2
			IF( @NewLicenseId is not NULL)
				SET @AutoConvertedCount = @AutoConvertedCount + 1
		END
		SET @ndx = @ndx + 1
	END		

    SET NOCOUNT OFF

	return @AutoConvertedCount
END
GO



/******************************************************************************
 *   Procedure: usp_CreateImportPACAPrincipal
 *
 *   Return: int - the id of the new record
 *
 *   Decription:  This procedure creates a new PRImportPACAPrincipal record
 *                supporting the import from file method 
 *
 *
 *****************************************************************************/
if exists (select * from dbo.sysobjects 
			where id = object_id(N'[dbo].[usp_CreateImportPACAPrincipal]') 
				and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_CreateImportPACAPrincipal]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE dbo.usp_CreateImportPACAPrincipal
	@prip_FileName		nvarchar(50)	= null,
	@prip_ImportDate	datetime		= null,
	@prip_Sequence  	int     		= null,
	@prip_LicenseNumber	nvarchar(50)	= null,
	@prip_LastName  	nvarchar(50)	= null,
	@prip_FirstName		nvarchar(20)	= null,
	@prip_MiddleInitial	nvarchar(1) 	= null,
	@prip_Title       	nvarchar(10)	= null,
	@prip_City			nvarchar(24)	= null,
	@prip_State			nvarchar(2) 	= null,
	@prip_PACARunDate	datetime		= null,
	@UserId int = -1
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @Now DateTime
    SET @Now = getDate()

	declare @TableId int

	declare @prip_ImportPACAPrincipalId	int
	-- get a new ID for the entity
	select @TableId = bord_tableId from custom_tables where bord_name = 'PRImportPACAPrincipal'
	exec @prip_ImportPACAPrincipalId = crm_next_id @TableId 
	-- create the new record
	INSERT INTO PRImportPACAPrincipal
	(
		prip_ImportPACAPrincipalId, 
		prip_CreatedBy, prip_CreatedDate, prip_UpdatedBy, prip_UpdatedDate,	prip_TimeStamp, prip_Deleted, 
		prip_FileName, prip_ImportDate,
        prip_Sequence, prip_LicenseNumber, prip_LastName, prip_FirstName, prip_MiddleInitial,
		prip_Title,	prip_City, prip_State, prip_PACARunDate
	) Values (
		@prip_ImportPACAPrincipalId,
		@UserId, @Now,	@UserId, @Now,	@Now, null,
		@prip_FileName,	@prip_ImportDate,
		@prip_Sequence,	@prip_LicenseNumber, @prip_LastName, @prip_FirstName, @prip_MiddleInitial,
		@prip_Title, @prip_City, @prip_State, @prip_PACARunDate
	)	

    SET NOCOUNT OFF

	return @prip_ImportPACAPrincipalId
END
GO

/******************************************************************************
 *   Procedure: usp_CreateImportPACATrade
 *
 *   Return: int - the id of the new record
 *
 *   Decription:  This procedure creates a new PRImportPACATrade record
 *                supporting the import from file method 
 *
 *
 *****************************************************************************/
if exists (select * from dbo.sysobjects 
			where id = object_id(N'[dbo].[usp_CreateImportPACATrade]') 
				and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_CreateImportPACATrade]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE dbo.usp_CreateImportPACATrade
	@prit_FileName		nvarchar(50)	= null,
	@prit_ImportDate	datetime		= null,
	@prit_LicenseNumber	nvarchar(8)	    = null,
	@prit_AdditionalTradeName nvarchar(80)	= null,
	@prit_City			nvarchar(24)	= null,
	@prit_State			nvarchar(2) 	= null,
	@prit_PACARunDate	datetime		= null,
	@UserId             int             = -1
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @Now DateTime
    SET @Now = getDate()

	declare @TableId int

	declare @prit_ImportPACATradeId	int
	-- get a new ID for the entity
	select @TableId = bord_tableId from custom_tables where bord_name = 'PRImportPACATrade'
	exec @prit_ImportPACATradeId = crm_next_id @TableId 
	-- create the new record
	INSERT INTO PRImportPACATrade
	(
		prit_ImportPACATradeId,
		prit_CreatedBy,	prit_CreatedDate, prit_UpdatedBy, prit_UpdatedDate,	prit_TimeStamp,	prit_Deleted,
		prit_FileName, prit_ImportDate,	prit_LicenseNumber,	prit_AdditionalTradeName, prit_City,
		prit_State,	prit_PACARunDate
	) Values (
		@prit_ImportPACATradeId,
		@UserId, @Now, @UserId, @Now, @Now, null,
		@prit_FileName,	@prit_ImportDate, @prit_LicenseNumber, @prit_AdditionalTradeName, @prit_City,
		@prit_State, @prit_PACARunDate
	)	
    SET NOCOUNT OFF

	return @prit_ImportPACATradeId
END
GO

/******************************************************************************
 *   Procedure: usp_CreatePACAFromImport
 *
 *   Return: int - the id of the new record
 *
 *   Decription:  This procedure creates a new PRPACALicense record
 *                from an imported paca record.  All supporting PACA
 *                Principal and Trade records are also copied.  If this
 *                record is replacing an existing PACA record, the old record
 *                has the Current flag set to NULL 
 *
 *
 *****************************************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_CreatePACAFromImport]') 
            and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_CreatePACAFromImport]
GO

CREATE PROCEDURE dbo.usp_CreatePACAFromImport
    @pril_ImportPACALicenseId int = NULL,
    @comp_CompanyId int = NULL,
    @prpa_PACALicenseId int = null,
    @comp_PRTradestyle1 nvarchar(104) = NULL,
    @comp_PRTradestyle2 nvarchar(104) = NULL,
    @comp_PRTradestyle3 nvarchar(104) = NULL,
    @comp_PRTradestyle4 nvarchar(104) = NULL,
    @comp_Name nvarchar(420) = NULL,
    @comp_PRCorrTradestyle nvarchar(420) = NULL,
    @comp_PRBookTradestyle nvarchar(420) = NULL,
    @UserId int = -1,
    @DeleteImport smallint = 0,
    @SendNotifications bit = 1,
    @Type int
as
BEGIN
    DECLARE @Now datetime
	DECLARE @Msg varchar(2000)
    DECLARE @pril_LicenseNumber int
    DECLARE @TableId int
    DECLARE @NewPACALicenseId int

	DECLARE @Changes varchar(800), @ListingChanges varchar(800)

	SET @Now = getDate()

    -- if the type is still 0, verify we have a valid company id
    IF ( @pril_ImportPACALicenseId IS NULL) 
    BEGIN
        SET @Msg = 'Update Failed.  An Import PACA License Id must be provided.'
        RAISERROR (@Msg, 16, 1)
        Return
    END

	SELECT @pril_LicenseNumber = pril_LicenseNumber FROM PRImportPACALicense 
              WHERE pril_ImportPACALicenseId = @pril_ImportPACALicenseId
	
	IF (@pril_LicenseNumber IS NOT NULL)
	BEGIN
		SELECT @comp_CompanyId = prpa_CompanyId, @prpa_PACALicenseId = prpa_PACALicenseId 
		  From PRPACALicense 
		 where prpa_LicenseNumber = @pril_LicenseNumber	
			   AND prpa_Current = 'Y'
	END
/*
    -- Determine if this is an assignment to an existing BBId
    --   if a new company is being created, or this is being
    --   assigned to an existing PACA record 
    Declare @Type int
    -- Assume "Assign to BBId"
    SET @Type = 0
*/
	IF (@Type = 2 )
    BEGIN 
--      SET @Type = 2 -- assign to PACA
      SELECT @comp_CompanyId = prpa_CompanyId From PRPACALicense where prpa_PACALicenseId = @prpa_PACALicenseId
    END
    -- if the type is still 0, verify we have a valid company id
    IF ( (@Type = 0) AND (@comp_companyId IS NULL) )
    BEGIN
        SET @Msg = 'Update Failed.  Not enough information has been provided to process this record.'
        RAISERROR (@Msg, 16, 1)
        Return
    END
    
    -- Determine what should happen with Notifications
	DECLARE @ListingStatus varchar(40), @ListingUserId int, @RatingUserId int, @CustomerServiceUserId int
	SELECT @ListingStatus = comp_PRListingStatus, @ListingUserId = prci_ListingSpecialistId,
			@RatingUserId = prci_RatingUserId,  @CustomerServiceUserId = prci_CustomerServiceId
	  FROM company 
	 INNER JOIN PRCity on comp_PRListingCityId = prci_CityId
	 WHERE comp_CompanyId = @comp_CompanyId

	-- If the company is not listed, override the SendNotification flag
	IF (@ListingStatus != 'L') 		 
		SET @SendNotifications = 0;
	-- set variables to hold messages to the recipients
	Declare @NotifyRatingUserMsg varchar(1000)
	Declare @NotifyListingUserMsg varchar(1000)
	Declare @NotifyCustomerServiceUserMsg varchar(1000)
    
	-- get a new ID for the entity
	exec usp_getNextId 'PRPACALicense', @NewPACALicenseId output

    -- Start making our updates
	BEGIN TRY
		BEGIN TRANSACTION
		IF ( @Type = 0)
		BEGIN
			-- If this is an existing PRPACALicense that is getting replaced, archive it
		  UPDATE PRPACALicense SET prpa_Current = NULL, prpa_UpdatedDate=getDate(), prpa_UpdatedBy=@UserId 
				WHERE prpa_CompanyId = @comp_CompanyId AND prpa_Current = 'Y'
	                            
		END ELSE IF ( @Type = 1) 
		BEGIN
/*  We no longer insert companies in this stored proc
			-- IF this is type 1 (new company) create the company record
			INSERT INTO Company (comp_companyid, comp_CreatedBy, comp_UpdatedBy, 
								 comp_PRTradestyle1, comp_PRTradestyle2, comp_PRTradestyle3, comp_PRTradestyle4,
								 comp_Name, comp_PRCorrTradestyle, comp_PRBookTradestyle)
				   VALUES (@comp_CompanyId, @UserId, @UserId, 
							@comp_PRTradestyle1, @comp_PRTradestyle2, @comp_PRTradestyle3, @comp_PRTradestyle4,
							@comp_Name, @comp_PRCorrTradestyle, @comp_PRBookTradestyle)
			-- if the PACA Insert record does not have a type of Frozen, set a CSR task
*/
			declare @TypeFruitVeg varchar(40)
			select @TypeFruitVeg = pril_TypeFruitVeg FROM PRImportPACALicense 
			WHERE pril_ImportPACALicenseId = @pril_ImportPACALicenseId
			if (@TypeFruitVeg != '2') begin
				SET @NotifyCustomerServiceUserMsg = 'BB ID '+ convert(varchar,@comp_CompanyId) + 
					' originated from a new PACA license. Contact to qualify for listing and/or membership.'
			end
		END ELSE IF ( @Type = 2)
		BEGIN
			-- If this is an existing PRPACALicense that is getting replaced, archive it
		  UPDATE PRPACALicense SET prpa_Current = NULL, prpa_UpdatedDate=getDate(), prpa_UpdatedBy=@UserId 
				WHERE prpa_PACALicenseId = @prpa_PACALicenseId AND prpa_Current = 'Y'
	                            
		END

		-- create the new PACA License record
		INSERT INTO PRPACALicense
			(
				prpa_PACALicenseId,	prpa_CreatedBy,	prpa_UpdatedBy,	prpa_CompanyId,
				prpa_LicenseNumber,
				prpa_Current,
				prpa_CompanyName,
				prpa_Address1, prpa_Address2, prpa_City, prpa_State, prpa_PostCode,
				prpa_MailAddress1, prpa_MailAddress2, prpa_MailCity, prpa_MailState, prpa_MailPostCode,
				prpa_IncState, prpa_IncDate, prpa_OwnCode, prpa_Telephone, prpa_TerminateDate, prpa_TerminateCode,
				prpa_TypeFruitVeg, prpa_ProfCode, 
                prpa_EffectiveDate, prpa_ExpirationDate
			)
			Select 	@NewPACALicenseId, @UserId, @UserId, @comp_CompanyId,
				pril_LicenseNumber,
				'Y',
				pril_CompanyName,
				pril_Address1, pril_Address2, pril_City, pril_State, pril_PostCode,
				pril_MailAddress1, pril_MailAddress2, pril_MailCity, pril_MailState, pril_MailPostCode,
				pril_IncState, pril_IncDate, pril_OwnCode, pril_Telephone, pril_TerminateDate, pril_TerminateCode,
				pril_TypeFruitVeg, pril_ProfCode,
                pril_PACARunDate, pril_ExpirationDate
			FROM PRImportPACALicense 
			WHERE pril_ImportPACALicenseId = @pril_ImportPACALicenseId

		-- If the caller asked us to send notifications (and all internal rules are met) detemine if any are necessary
		IF (@SendNotifications = 1)
		BEGIN
			Declare @pril_CompanyName varchar(80), @prpa_CompanyName varchar(80)
			Declare @pril_OwnCode varchar(40), @prpa_OwnCode varchar(40)
			Declare @pril_TerminateDate datetime
			Declare @pril_Telephone varchar(20), @prpa_Telephone varchar(20)
			
			select @pril_CompanyName = pril_CompanyName, @pril_OwnCode = pril_OwnCode, 
				   @pril_Telephone = pril_Telephone, @pril_TerminateDate = pril_TerminateDate
			  FROM PRImportPACALicense 
			  WHERE pril_ImportPACALicenseId = @pril_ImportPACALicenseId
			
			select @prpa_CompanyName = prpa_CompanyName, @prpa_OwnCode = prpa_OwnCode,
				   @prpa_Telephone = prpa_Telephone
			  FROM PRPACALicense, PRImportPACALicense 
			  WHERE pril_ImportPACALicenseId = @pril_ImportPACALicenseId
				    AND prpa_PACALicenseId = @prpa_PACALicenseId

			Declare @AddressChange varchar(10)
			select @AddressChange = 'Address' 
			  FROM PRPACALicense, PRImportPACALicense 
			  WHERE pril_ImportPACALicenseId = @pril_ImportPACALicenseId
				    AND prpa_PACALicenseId = @prpa_PACALicenseId
				    AND (
					(ISNULL(prpa_Address1,'') != ISNULL(pril_Address1,'')) OR
					(ISNULL(prpa_Address2,'') != ISNULL(pril_Address2,'')) OR
					(ISNULL(prpa_City,'') != ISNULL(pril_City,'')) OR
					(ISNULL(prpa_State,'') != ISNULL(pril_State,'')) OR
					(ISNULL(prpa_PostCode,'') != ISNULL(pril_PostCode,'')) OR
					(ISNULL(prpa_MailAddress1,'') != ISNULL(pril_MailAddress1,'')) OR
					(ISNULL(prpa_MailAddress2,'') != ISNULL(pril_MailAddress2,'')) OR
					(ISNULL(prpa_MailCity,'') != ISNULL(pril_MailCity,'')) OR
					(ISNULL(prpa_MailState,'') != ISNULL(pril_MailState,'')) OR
					(ISNULL(prpa_MailPostCode,'') != ISNULL(pril_MailPostCode,'')) 
				)

			SET @Changes = ''
			SET @ListingChanges = ''
			if (ISNULL(@prpa_OwnCode,'') != ISNULL(@pril_OwnCode,'') )
			begin
				if (@Changes != '' )
					SET @Changes = @Changes + ', '
				SET @Changes = @Changes + 'Ownership'
			end
			if (ISNULL(@prpa_CompanyName,'') != ISNULL(@pril_CompanyName,'') )
			begin
				if (@Changes != '' )
					SET @Changes = @Changes + ', '
				SET @Changes = @Changes + 'Company Name'
			end
			
			if (ISNULL(@prpa_Telephone,'') != ISNULL(@pril_Telephone,'') )
			begin
				if (@ListingChanges != '' )
					SET @ListingChanges = @ListingChanges + ', '
				SET @ListingChanges = @ListingChanges + 'Phone Number'
			end
			
			if(@pril_TerminateDate is not null )
			begin
				if (@Changes != '' )
					SET @Changes = @Changes + ', '
				SET @Changes = @Changes + 'License Terminated'
			end

			if (@AddressChange is not null)
			begin
				if (@ListingChanges != '' )
					SET @ListingChanges = @ListingChanges + ', '
				SET @ListingChanges = @ListingChanges + 'Address'
			end
		
		END


		-- Add any imported Principal Names the new PACA License record
		DECLARE @ctr int, @RecordCount int, @NextId int, @id_value int
	    DECLARE @PrincipalMsg varchar (100)
	    DECLARE @TradeMsg varchar (100)
		DECLARE @tbl TABLE (idctr int identity, id_value int)
		DECLARE @ExistingPrincipals TABLE (lastname varchar(52), firstname varchar(20), title varchar(10))
		DECLARE @lastname varchar(52), @firstname varchar(20), @title varchar(10)

		-- get a count of how many current principal records we have
		Declare @ExistingPrincipalCount int
		INSERT INTO @ExistingPrincipals 
			SELECT prpp_Lastname, prpp_FirstName, prpp_Title
			  FROM PRPACAPrincipal
			 WHERE prpp_PACALicenseId = @prpa_PACALicenseId
		SET @ExistingPrincipalCount = @@ROWCOUNT

		SET @ctr = 1


		INSERT INTO @tbl SELECT prip_ImportPACAPrincipalId FROM PRImportPACAPrincipal
		  WHERE prip_LicenseNumber = @pril_LicenseNumber 
		SET @RecordCount = @@ROWCOUNT
		-- start easy... if the counts don't match have the Rating analyst review
		IF (@ExistingPrincipalCount != @RecordCount)
		    SET @PrincipalMsg = 'Principals'

		-- now process the records
		WHILE (@ctr <= @RecordCount)
		BEGIN 
			SET @id_value = null
			SELECT @id_value = id_value from @tbl where idctr = @ctr
			if (@id_value is not null)
			begin
				exec usp_getNextId 'PRPACAPrincipal', @NextId output
				INSERT INTO PRPACAPrincipal
				(
					prpp_PACAPrincipalId, prpp_CreatedBy, prpp_UpdatedBy, prpp_PACALicenseId,
					prpp_LastName, prpp_FirstName, prpp_MiddleInitial,
					prpp_Title, prpp_City, prpp_State
				) SELECT 
					@NextId, @UserId, @UserId, @NewPACALicenseId,
					prip_LastName, prip_FirstName, prip_MiddleInitial,
					prip_Title, prip_City, prip_State
				FROM PRImportPACAPrincipal
				WHERE prip_ImportPACAPrincipalId = @id_value 
				
				-- As soon as a changed rec is identified, we can stop checking
				IF ( @PrincipalMsg IS NULL)
				BEGIN
					-- Check the existing records to see if this already exists
					SELECT @lastname = prip_LastName, @firstname = prip_FirstName, @title = prip_Title
					  FROM PRImportPACAPrincipal					
                     WHERE prip_ImportPACAPrincipalId = @id_value

					SELECT 1
					  FROM @ExistingPrincipals
                     WHERE (
							(ISNULL(lastName,'') = ISNULL(@lastname,'') ) 
						AND (ISNULL(firstName,'') = ISNULL(@firstname,'') )
						AND (ISNULL(title,'') = ISNULL(@title,'') )
							)
					IF (@@ROWCOUNT > 0)
						SET @PrincipalMsg = 'Principals'
				END
				-- go to the next record.
				SET @ctr = @ctr+1
			end
		END

		-- Add any imported Trade Names the new PACA License record
		DECLARE @ExistingTrades TABLE (AdditionalTradeName varchar(80), City varchar(25), State varchar(2))
		DECLARE @AdditionalTradeName varchar(80), @City varchar(25), @State varchar(2)

		-- get a count of how many current trade records we have
		Declare @ExistingTradeCount int
		INSERT INTO @ExistingTrades 
			SELECT ptrd_AdditionalTradeName, ptrd_City, ptrd_State
			  FROM PRPACATrade
			 WHERE ptrd_PACALicenseId = @prpa_PACALicenseId
		SET @ExistingTradeCount = @@ROWCOUNT

		DECLARE @tblTrade TABLE (idctr int identity, id_value int)
		SET @ctr = 1

		INSERT INTO @tblTrade SELECT prit_ImportPACATradeId FROM PRImportPACATrade
		  WHERE prit_LicenseNumber = @pril_LicenseNumber 
		SET @RecordCount = @@ROWCOUNT
		-- start easy... if the counts don't match have the Rating analyst review
		IF (@ExistingTradeCount != @RecordCount)
		    SET @TradeMsg = 'Alternate Tradename'

		WHILE (@ctr <= @RecordCount)
		BEGIN 
			SET @id_value = null
			SELECT @id_value = id_value from @tblTrade where idctr = @ctr
			if (@id_value is not null)
			begin
				exec usp_getNextId 'PRPACATrade', @NextId output
				INSERT INTO PRPACATrade
				(
					ptrd_PACATradeId, ptrd_CreatedBy, ptrd_UpdatedBy, ptrd_PACALicenseId,
					ptrd_AdditionalTradeName, ptrd_City, ptrd_State
				) SELECT 
					@NextId, @UserId, @UserId, @NewPACALicenseId,
					prit_AdditionalTradeName, prit_City, prit_State
				  FROM PRImportPACATrade
				  WHERE prit_ImportPACATradeId = @id_value 
				SET @ctr = @ctr+1
			end
			-- As soon as a changed rec is identified, we can stop checking
			IF ( @TradeMsg IS NULL)
			BEGIN
				-- Check the existing records to see if this already exists
				SELECT @AdditionalTradeName = prit_AdditionalTradeName, @City = prit_City, @State = prit_State
				  FROM PRImportPACATrade					
                 WHERE prit_ImportPACATradeId = @id_value

				SELECT 1
				  FROM @ExistingTrades
                 WHERE (
						(ISNULL(AdditionalTradeName,'') = ISNULL(@AdditionalTradeName,'') ) 
					AND (ISNULL(City,'') = ISNULL(@City,'') )
					AND (ISNULL(State,'') = ISNULL(@State,'') )
						)
				IF (@@ROWCOUNT > 0)
					SET @TradeMsg = 'Alternate Tradename'
			END
		END

		-- we send the CSR message regardless of @SendNotification status
		IF (@NotifyCustomerServiceUserMsg IS NOT NULL AND @CustomerServiceUserId is not null)
		BEGIN
			-- SEnd notification
			exec usp_CreateTask     
				@StartDateTime = @Now,
				@CreatorUserId = @UserId,
				@AssignedToUserId = @CustomerServiceUserId,
				@TaskNotes = @NotifyCustomerServiceUserMsg,
				@RelatedCompanyId = @comp_CompanyId,
				@Status = 'Pending'
		END
		
		-- if notifcations have to be sent, send them here
		IF (@SendNotifications = 1)
		BEGIN
			Declare @SendToUserId int, @FinalMsg varchar(2000)
			-- Create the notification message, start with Rating values
			if (@Changes != '')begin
				SET @SendToUserId = @RatingUserId
				IF (@ListingChanges != '')
					SET @Changes = @Changes + ', '
				SET @Changes = @Changes + @ListingChanges
			end else if (@ListingChanges  != '') begin
				SET @SendToUserId = @ListingUserId
				SET @Changes = @ListingChanges 
			end			
			SET @Changes = @Changes + COALESCE(', ' + @PrincipalMsg,'') + COALESCE(', ' + @TradeMsg, '')

			IF ( (@Changes IS NOT NULL and @Changes != '') AND @SendToUserId is not null)
			BEGIN
				SET @FinalMsg = 'PACA reports changes to the following values for BB ID ' + convert(varchar(20),@comp_companyid) 
					+ ': ' + @Changes
				-- SEnd notification
				exec usp_CreateTask     
					@StartDateTime = @Now,
					@CreatorUserId = @UserId,
					@AssignedToUserId = @SendToUserId,
					@TaskNotes = @FinalMsg,
					@RelatedCompanyId = @comp_CompanyId,
					@Status = 'Pending'
			END
			
		END

		-- remove the existing Imported PACA record
		IF (@DeleteImport = 1)
		BEGIN
			 -- delete any Principal records
			DELETE 
				FROM PRImportPACAPrincipal 
				WHERE prip_LicenseNumber = @pril_LicenseNumber

			 -- delete any Trade records
			DELETE 
				FROM PRImportPACATrade 
				WHERE prit_LicenseNumber = @pril_LicenseNumber
			-- Finally remove the imported license record
			DELETE 
				FROM PRImportPACALicense 
				WHERE pril_ImportPACALicenseId = @pril_ImportPACALicenseId
		END

		-- if we made it here, commit our work
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION;

	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		SELECT	@ErrorMessage = ERROR_MESSAGE(),
				@ErrorSeverity = ERROR_SEVERITY(),
				@ErrorState = ERROR_STATE();

		RAISERROR (@ErrorMessage, 
				   @ErrorSeverity,
				   @ErrorState);
	END CATCH;


    return @NewPACALicenseId 


END
GO
-- ********************* END PACA-CENTRIC STORED PROCEDURE CREATION *****************

/******************************************************************************
 *   Procedure: usp_CreateException
 *
 *   Return: 
 *
 *   Decription:  This procedure creates the rating exceptions for records
 *                inserted into the system. If a companyId is not passed, we'll
 *                try to retrieve it.  This method is primarily invoked from 
 *                insert triggers on the BBScore, TradeReport, and ARAgingDetail
 *                tables. There is also a monthly process that invokes the LEM
 *                process for assessing exceptions
 *                Note: @IntegrityAvg3 & @PayRatingAvg3 apply 
 *                      to LegalEntityMonthly (LEM) only
 *
 *
 *****************************************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_CreateException]') 
            and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_CreateException]
GO
CREATE PROCEDURE dbo.usp_CreateException
    @preq_Type varchar(40) = NULL,
    @preq_Id int = NULL,
    @preq_UserId int = NULL,
    @preq_CompanyId int = NULL,
    @IntegrityAvg3 numeric(6,3) = NULL,
    @PayRatingAvg3 numeric(6,3) = NULL
AS
BEGIN
    DECLARE @Msg varchar(2000)
    DECLARE @NOW datetime

    IF ( @preq_Type IS NULL OR @preq_Id IS NULL OR @preq_UserId IS NULL) 
    BEGIN
        SET @Msg = 'Exception Queue generation failed.  preq_Type, preq_Id, and preq_UserId are required.'
        RAISERROR (@Msg, 16, 1)
        Return
    END

    DECLARE @comp_PRListingCityId int

    -- apply to all exceptions
    DECLARE @preq_Date datetime
    DECLARE @preq_Status varchar(40)
    DECLARE @preq_AssignedUserId int
    DECLARE @preq_ChannelId int

    DECLARE @preq_RatingLine varchar(50)
    DECLARE @preq_NumTradeReports3 smallint
    DECLARE @preq_NumTradeReports6 smallint
    DECLARE @preq_NumTradeReports12 smallint
    DECLARE @preq_BlueBookScore numeric
    
    DECLARE @TableId int
    DECLARE @NewExceptionId int

    SET @NOW = getdate()

    SET @preq_Date = @NOW
    SET @preq_Status = 'O'
    
	-- get a new ID for the entity
	select @TableId = bord_tableId from custom_tables where bord_name = 'PRExceptionQueue'
	exec @NewExceptionId = crm_next_id @TableId 

    -- if the caller was nice, they gave us a company id; if not, we can try to get it ourselves
    IF (@preq_CompanyId IS NULL)
    BEGIN
        IF (@preq_Type = 'TES')
        BEGIN
            -- Determine the CompanyId from the TradeReport
            select @preq_CompanyId = prtr_SubjectId from PRTradeReport where prtr_TradeReportId = @preq_Id

        END
        ELSE IF (@preq_Type = 'AR')
        BEGIN
            -- Determine the CompanyId from the PRARAgingDetail record
            select @preq_CompanyId = SubjectCompanyId from vPRARAgingDetail where praad_ARAgingDetailId = @preq_Id

        END
        ELSE IF (@preq_Type = 'BBScore')
        BEGIN
            -- Determine the CompanyId from the BlueBook Score
            select @preq_CompanyId = prbs_CompanyId from PRBBScore where prbs_BBScoreId = @preq_Id

        END
        ELSE IF (@preq_Type = 'LEM')
        BEGIN
            -- Determine the CompanyId from the BlueBook Score
            SET @preq_CompanyId = NULL
        END
    END
    -- determine if we have a valid Company
    IF ( @preq_CompanyId IS NULL) 
    BEGIN
        SET @Msg = 'Exception Queue generation failed.  Company could not be identified.'
        RAISERROR (@Msg, 16, 1)
        Return
    END

    -- Determine the assigned user id
    -- use the company's listing city to find a PRCity record; then determine the AssignedUser
    -- if this company is a branch, the assigned user is based on the HQ
	DECLARE @LookupCompanyId int
	DECLARE @comp_HQId int
	DECLARE @comp_PRType varchar(40)
	SET @LookupCompanyId = @preq_CompanyId
	select @comp_PRType = comp_PRType, @comp_HQId = comp_PRHQId 
	  from company where comp_CompanyId = @preq_CompanyId
	-- if this is a branch, we compare against the branches HQ
	if (@comp_PRType = 'B')
		SET @LookupCompanyId = @comp_HQId
    
    Select @comp_PRListingCityId = comp_PRListingCityId FROM Company Where comp_CompanyId = @LookupCompanyId
    SET @preq_AssignedUserId = @preq_UserId
    IF (@comp_PRListingCityId is not null)
    BEGIN
        SELECT @preq_AssignedUserId = prci_RatingUserId from PRCity where prci_CityId = @comp_PRListingCityId
    END
    IF (@preq_AssignedUserId is not null)
    BEGIN
        SELECT @preq_ChannelId = user_PrimaryChannelId from Users where user_UserId = @preq_AssignedUserId
    END
    
    -- Get the current Rating LIne
    SELECT @preq_RatingLine = prra_RatingLine FROM vPRCompanyRating 
        WHERE prra_CompanyId = @preq_CompanyId and prra_Current = 'Y'

    -- Get the Trade Report info
    DECLARE @tblTradeReports table (prtr_TradeReportId int, prtr_Date datetime )
    INSERT INTO @tblTradeReports 
        SELECT prtr_TradeReportId, prtr_Date
        FROM PRTradeReport 
        WHERE prtr_SubjectId = @preq_CompanyId
          AND prtr_Date >= DateAdd(Month, -12, @NOW)
    SELECT @preq_NumTradeReports3 = COUNT(1) from @tblTradeReports WHERE prtr_Date >= DateAdd(Month, -3, @NOW)     
    SELECT @preq_NumTradeReports6 = COUNT(1) from @tblTradeReports WHERE prtr_Date >= DateAdd(Month, -6, @NOW)     
    SELECT @preq_NumTradeReports12 = COUNT(1) from @tblTradeReports WHERE prtr_Date >= DateAdd(Month, -12, @NOW)     

    -- Get the current Bluebook score
    SELECT @preq_BlueBookScore = prbs_BBScore FROM PRBBScore 
        WHERE prbs_CompanyId = @preq_CompanyId and prbs_Current = 'Y'

	BEGIN TRY
		-- Begin a transaction
		BEGIN TRANSACTION
	    
		-- Insert the exception 
		INSERT INTO PRExceptionQueue 
			( preq_ExceptionQueueId, 
			  preq_CreatedBy, preq_CreatedDate, preq_UpdatedBy, preq_UpdatedDate, preq_TimeStamp,
			  preq_TradeReportId, preq_ARAgingId, preq_CompanyId, 
			  preq_Date, preq_Type, preq_Status, 
			  preq_ThreeMonthIntegrityRating, preq_ThreeMonthPayRating,
			  preq_RatingLine, preq_NumTradeReports3Months,
			  preq_NumTradeReports6Months, preq_NumTradeReports12Months,
			  preq_BlueBookScore, preq_AssignedUserId, preq_ChannelId
			)
			VALUES
			( @NewExceptionId, 
			  @preq_UserId, @NOW, @preq_UserId, @NOW, @NOW,
			  @preq_Id, null, @preq_CompanyId, 
			  @preq_Date, @preq_Type, 'O', 
			  @IntegrityAvg3, @PayRatingAvg3,
			  @preq_RatingLine, @preq_NumTradeReports3,
			  @preq_NumTradeReports6, @preq_NumTradeReports12,
			  @preq_BlueBookScore, @preq_AssignedUserId, @preq_ChannelId
			)

		-- Certain types require the Exception flag to be set
		IF (@preq_Type = 'TES')
		BEGIN
			Update PRTradeReport set prtr_Exception = 'Y' where prtr_TradeReportId = @preq_Id
		END
		ELSE IF (@preq_Type = 'AR')
		BEGIN
			Update PRARAgingDetail set praad_Exception = 'Y' where praad_ARAgingDetailId = @preq_Id
		END
	    ELSE IF (@preq_Type = 'BBScore')
	    BEGIN
	        Update PRBBScore set prbs_Exception = 'Y' where prbs_BBScoreId = @preq_Id
	    END

		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION;

	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity BIGINT;
		DECLARE @ErrorState BIGINT;

		SELECT	@ErrorMessage = ERROR_MESSAGE(),
				@ErrorSeverity = ERROR_SEVERITY(),
				@ErrorState = ERROR_STATE();

		RAISERROR (@ErrorMessage, 16, @ErrorState);
	END CATCH;


    return @NewExceptionId

END
GO

/******************************************************************************
 *   Procedure: usp_CheckCompanyTESException
 *
 *   Return: 
 *
 *   Decription:  This procedure checks for exceptions that occur based upon
 *                the rating rules.  If an exception is identified, the 
 *                PRExceptionQueue record is created.
 *
 *****************************************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_CheckCompanyTESException]'))
    drop procedure [dbo].[usp_CheckCompanyTESException]
GO

CREATE PROCEDURE dbo.usp_CheckCompanyTESException
    @comp_CompanyId int,
    @UserId int,
    @SourceId int = NULL,
    @Assigned_IntegrityName varchar (10) = NULL,
    @Assigned_PayRatingName varchar (10) = NULL,
    @Assigned_PayRatingWeight int = NULL,
    @Assigned_OutOfBusiness char(1)= NULL

AS
BEGIN
    SET NOCOUNT OFF
    DECLARE @Msg varchar(2000)
    DECLARE @NOW datetime

    DECLARE @SourceType varchar (10)
    SET @SourceType = 'TES'
    
    DECLARE @RatingCompanyId int
    DECLARE @comp_HQId int
    DECLARE @comp_PRType varchar(40)

    Declare @prra_IntegrityId int
    Declare @prra_PayRatingId int
    Declare @prra_IntegrityName varchar (10)
    Declare @prra_IntegrityWeight int
    Declare @prra_PayRatingWeight int
    Declare @prra_RatingId int
    
    Declare @cntRatingNumeral smallint
    Declare @cntOutOfBusiness smallint
    
    SET @NOW = getDate()

    IF ( @comp_CompanyId IS NULL ) 
    BEGIN
        SET @Msg = 'usp_CheckCompanyTESException failed.  @comp_CompanyId is required.'
        RAISERROR (@Msg, 16, 1)
        Return
    END

    SET @RatingCompanyId = @comp_CompanyId
   
    select @comp_PRType = comp_PRType, @comp_HQId = comp_PRHQId 
      from company where comp_CompanyId = @comp_CompanyId
    -- if this is a branch, we compare against the branches HQ
    if (@comp_PRType = 'B')
		SET @RatingCompanyId = @comp_HQId
    
    select @prra_RatingId = prra_RatingId, 
           @prra_IntegrityId = prra_IntegrityId, 
           @prra_PayRatingId = prra_PayRatingId,
           @prra_IntegrityName = prin_Name,
           @prra_IntegrityWeight = prin_Weight,
           @prra_PayRatingWeight = prpy_Weight 
      from vPRCompanyRating
      where prra_CompanyId = @RatingCompanyId
            AND prra_Current = 'Y'
      

	BEGIN TRY
		-- Begin a transaction
		BEGIN TRANSACTION
	    
		Declare @CreateException bit
		set @CreateException = 0

		If (@prra_RatingId is not null)
		begin
		  select @cntRatingNumeral = count(1) 
			from PRRatingNumeralAssigned
			JOIN PRRatingNumeral on pran_RatingNumeralId = prrn_RatingNumeralId
			where pran_RatingId = @prra_RatingId
			  and prrn_Name in ('(86)', '(76)', '(27)', '(85)', '(74)', '(124)', '(132)', '(88)', '(113)', '(114)')
	      
		  -- if any of these rating numerals are reported, an exception can not occur
		  if (@cntRatingNumeral = 0)
		  begin
			if (@Assigned_IntegrityName in ('X', 'XX') and (@prra_IntegrityName not in ('X', 'XX', 'XX147')) )
			begin 
			  -- Create the exception
			  EXEC usp_CreateException @SourceType, @SourceId, @UserId
			end
			else if (@Assigned_PayRatingName in ('D', 'E', 'F') )
			begin
			  if (@prra_PayRatingWeight > @Assigned_PayRatingWeight + 1)
			  begin
				-- create the exception
				EXEC usp_CreateException @SourceType, @SourceId, @UserId
			  end
			end
			else if (@Assigned_OutOfBusiness = 'Y')
			begin
			  select @cntOutOfBusiness = count(1) 
				  from PRRatingNumeralAssigned
				  JOIN PRRatingNumeral on pran_RatingNumeralId = prrn_RatingNumeralId
				  where pran_RatingId = @prra_RatingId
				  and prrn_Name in ('(88)', '(113)', '(114)')
			  if (@cntOutOfBusiness = 0)
			  begin
				-- Create the exception
				EXEC usp_CreateException @SourceType, @SourceId, @UserId
			  end
	        
			end
	        
		  end
		end


		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION;

	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity BIGINT;
		DECLARE @ErrorState BIGINT;

		SELECT	@ErrorMessage = ERROR_MESSAGE(),
				@ErrorSeverity = ERROR_SEVERITY(),
				@ErrorState = ERROR_STATE();

		RAISERROR (@ErrorMessage, 16, @ErrorState);
	END CATCH;

END
GO

/******************************************************************************
 *   Procedure: usp_CheckCompanyLEMException
 *
 *   Return: 
 *
 *   Decription:  This procedure checks for exceptions that occur based upon
 *                the Legal Entity rules.  This process is defined to be
 *                run once a month. If an exception is identified, the 
 *                PRExceptionQueue record is created.
 *
 *****************************************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_CheckCompanyLEMException]'))
    drop procedure [dbo].[usp_CheckCompanyLEMException]
GO

CREATE PROCEDURE dbo.usp_CheckCompanyLEMException
    @comp_CompanyId int = NULL
AS
BEGIN
    SET NOCOUNT OFF

    DECLARE @Msg varchar(2000)
    DECLARE @NOW datetime
    SET @NOW = getDate()

    IF ( @comp_CompanyId IS NULL ) 
    BEGIN
        SET @Msg = 'usp_CheckCompanyLEMException failed.  @comp_CompanyId is required.'
        RAISERROR (@Msg, 16, 1)
        Return
    END

    DECLARE @comp_PRType varchar(40)
    
    DECLARE @NumTradeReports3 smallint
    DECLARE @NumTradeReports6 smallint
    
    DECLARE @IntegrityAvg3 numeric(6,3)
    DECLARE @PayRatingAvg3 numeric(6,3)
    
    DECLARE @HQRatingId int
    DECLARE @HQCreditWorthId int
    DECLARE @HQIntegrityName varchar(10)
    DECLARE @HQPayRatingName varchar(10)
    
    -- notice that the weight fields are defined as numeric instead of int to allow
    -- SQL to do the appropriate averaging.
    DECLARE @tblTradeReports table (ndx smallint identity,
                comp_CompanyId int, prtr_TradeReportId int,
                prin_Weight numeric(6,3), prin_Name varchar(10), 
                prpy_Weight numeric(6,3), prpy_Name varchar(10), 
                prtr_Date datetime)
                
    DECLARE @tblCompanies table (ndx smallint identity, comp_CompanyId int)
    
    -- It is best to call this procedure with a HQ company but we can work with a branch also
    select @comp_PRType = comp_PRType
      from company 
      where comp_CompanyId = @comp_CompanyId
    if (@comp_PRType = 'H')
    begin
        INSERT INTO @tblCompanies
            select distinct comp_Companyid from company 
                where comp_companyid = @comp_CompanyId or comp_PRHQId = @comp_CompanyId
    end
    else
    BEGIN
        SET @Msg = 'usp_CheckCompanyLEMException failed.  Company Id must be for a headquarter company.'
        RAISERROR (@Msg, 16, 1)
        Return
    END
    
    select @HQRatingId = prra_RatingId, 
           @HQIntegrityName = prin_Name, 
           @HQPayRatingName = prpy_Name,
           @HQCreditWorthId = prra_CreditWorthId
      from vPRCompanyRating
      where prra_CompanyId = @comp_CompanyId
            AND prra_Current = 'Y'
      
    -- Populate a table of all the trade report information for the hq and all its branches
    -- we only need data fro mthe last 6 months
    INSERT INTO @tblTradeReports
        select prtr_subjectId, prtr_TradeReportId, prin_Weight, prin_Name, prpy_Weight, prpy_Name, 
            prtr_Date
        from PRTradeReport prtr
        LEFT OUTER JOIN PRIntegrityRating ON prtr_IntegrityId = prin_IntegrityRatingId 
        LEFT OUTER JOIN PRPayRating ON prtr_PayRatingId = prpy_PayRatingId 
        WHERE prtr_date >= DateAdd(Month, -6, @NOW) 
        AND prtr_subjectId in (select comp_Companyid from @tblCompanies)
        
    select @NumTradeReports3 = Count(1) from @tblTradeReports 
        WHERE prtr_date >= DateAdd(Month, -3, @NOW)
    select @NumTradeReports6 = Count(1) from @tblTradeReports
    
    SELECT  @IntegrityAvg3 = AVG(prin_Weight) from @tblTradeReports 
        WHERE prtr_date >= DateAdd(Month, -3, @NOW)
    SELECT  @PayRatingAvg3 = AVG(prpy_Weight) from @tblTradeReports 
        WHERE prtr_date >= DateAdd(Month, -3, @NOW)

    Declare @CreateException bit
    set @CreateException = 0
    -- These are the rules for exception generation
    IF (@HQRatingId is null AND ( @PayRatingAvg3 >= 3 AND @NumTradeReports3 >= 3) )
        SET @CreateException = 1
    ELSE IF (@HQIntegrityName = 'XXXX' AND (@IntegrityAvg3 < 3.2 or @NumTradeReports6 <= 2) )
        SET @CreateException = 1
    ELSE IF ((@HQIntegrityName = 'XXX') AND 
             (@IntegrityAvg3 < 2.9 
              or @NumTradeReports6 <= 2 
              or (@IntegrityAvg3 > 3.5 and @HQCreditWorthId is not null 
                                       and @HQPayRatingName not in ('C','D','E','F','(81)')) 
             )
            )
        SET @CreateException = 1
    ELSE IF (@HQIntegrityName = 'XXX148' AND 
            (@IntegrityAvg3 < 2.75 or @IntegrityAvg3 > 3.2 or @NumTradeReports6 <= 2  ) )
        SET @CreateException = 1
    ELSE IF (@HQIntegrityName = 'XX147' AND (@IntegrityAvg3 < 2.4 or @IntegrityAvg3 > 3) )
        SET @CreateException = 1
    ELSE IF (@HQIntegrityName in ('XX','X') AND (@IntegrityAvg3 > 2.8) )
        SET @CreateException = 1
    ELSE IF (@HQPayRatingName in ('AA','A') AND (@PayRatingAvg3 < 6) )
        SET @CreateException = 1
    ELSE IF (@HQPayRatingName = 'AB' AND (@PayRatingAvg3 < 5 or @PayRatingAvg3 > 7) )
        SET @CreateException = 1
    ELSE IF (@HQPayRatingName = 'B' AND (@PayRatingAvg3 < 4.5 or @PayRatingAvg3 > 6.5) )
        SET @CreateException = 1
    ELSE IF (@HQPayRatingName = 'C' AND (@PayRatingAvg3 > 5.5) )
        SET @CreateException = 1
    ELSE IF (@HQPayRatingName in ('D','E','F') AND (@PayRatingAvg3 > 4.5) )
        SET @CreateException = 1
    ELSE IF (@HQPayRatingName = '(81)' AND (@PayRatingAvg3 < 3 or @PayRatingAvg3 > 5) )
        SET @CreateException = 1
    
    IF (@CreateException = 1)
    Begin
        EXEC usp_CreateException 'LEM', null, -1, @comp_CompanyId, @IntegrityAvg3, @PayRatingAvg3 
    End

    -- debugging block
    /*
    select @CreateException, @HQRatingId, @HQIntegrityName, @HQPayRatingName, 
    @NumTradeReports3, @NumTradeReports6, @IntegritySum, @PayRatingSum, 
    @IntegrityAvg3, @PayRatingAvg3, * 
    from @tblTradeReports
    */
    SET NOCOUNT OFF

END
GO



If Exists (Select name from sysobjects where name = 'usp_ConsumeServiceUnits' and type='P') Drop Procedure dbo.usp_ConsumeServiceUnits
Go

/**
Creates the appropriate records to consume service units for the
specified usage and source.
**/
CREATE PROCEDURE dbo.usp_ConsumeServiceUnits
	@CompanyID int,
    @PersonID int,
	@UsageType nvarchar(40),
    @SourceType nvarchar(40),
    @RegardingCompanyID int,
    @SearchCriteria nvarchar(2000) = NULL,
    @RequestorInfo nvarchar(50) = NULL,
    @AddressLine1 nvarchar(50) = NULL,
	@AddressLine2 nvarchar(50) = NULL,
	@CityStateZip nvarchar(50) = NULL,
    @Fax nvarchar(50) = NULL,
    @NoCharge bit = 0,
    @CRMUserID int = 0,
    @EmailAddress nvarchar(50) = null,
    @Country nvarchar(50) = null
AS 

SET NOCOUNT ON

IF @NoCharge = 0 BEGIN
	-- Check to see if we have the units.
	IF dbo.ufn_HasAvailableUnits(@CompanyID, @UsageType) = 0 BEGIN
		RAISERROR ('Not enough service units available.', 16, 1)
		RETURN -1
	END
END

-- If we don't have a CRM User, go get the
-- default website user
IF @CRMUserID = 0 BEGIN
	SET @CRMUserID = dbo.ufn_GetSystemUserId(1)
END


-- Determine if we need to log a Business Report Request
DECLARE @BRRequestID int
DECLARE @CreateBRRequest bit
SET @CreateBRRequest = 0

IF (@UsageType = 'VBR') SET @CreateBRRequest = 1
IF (@UsageType = 'FBR') SET @CreateBRRequest = 1
IF (@UsageType = 'MBR') SET @CreateBRRequest = 1
IF (@UsageType = 'EBR') SET @CreateBRRequest = 1
IF (@UsageType = 'OBR') SET @CreateBRRequest = 1

BEGIN TRANSACTION;
BEGIN TRY

IF (@CreateBRRequest = 1) BEGIN
	-- Create a PRBusinessReportRequest record
	EXEC usp_getNextId 'PRBusinessReportRequest', @BRRequestID Output
	INSERT INTO PRBusinessReportRequest (
		prbr_BusinessReportRequestID,
		prbr_CreatedBy,
        prbr_CreatedDate,
		prbr_UpdatedBy,
		prbr_UpdatedDate,
		prbr_TimeStamp,
		prbr_RequestingCompanyID,
		prbr_RequestingPersonID,
		prbr_RequestedCompanyID,
		prbr_MethodSent,
        prbr_RequestorInfo,
        prbr_AddressLine1,
        prbr_AddressLine2,
		prbr_CityStateZip,
		prbr_Country,
		prbr_EmailAddress,
        prbr_Fax,
        prbr_DoNotChargeUnits)
	VALUES (@BRRequestID,
			@CRMUserID,
            GETDATE(),
			@CRMUserID,
            GETDATE(),
            GETDATE(),
			@CompanyID,
			@PersonID,
			@RegardingCompanyID,
            @UsageType,
		    @RequestorInfo,
		    @AddressLine1,
			@AddressLine2, 
			@CityStateZip,
			@Country,
			@EmailAddress,
			@Fax,
			@NoCharge);

	-- Now determine if we need to create or 
    -- update the PRCompanyRelationship record.
	SELECT 'x' 
      FROM PRCompanyRelationship
     WHERE prcr_Type = '25'
       AND prcr_LeftCompanyID = @CompanyID
       AND prcr_RightCompanyID = @RegardingCompanyID;

	IF @@ROWCOUNT = 0 BEGIN

		-- Create a new record
		DECLARE @CompRelID int
		EXEC usp_getNextId 'PRCompanyRelationship', @CompRelID Output

		INSERT INTO PRCompanyRelationship (
			prcr_CompanyRelationshipID,
			prcr_CreatedBy,
			prcr_CreatedDate,
			prcr_UpdatedBy,
			prcr_UpdatedDate,
			prcr_TimeStamp,
			prcr_LeftCompanyID,
			prcr_RightCompanyID,
			prcr_Type,
			prcr_EnteredDate,
			prcr_LastReportedDate,
			prcr_TimesReported,
			prcr_Active)
		VALUES (@CompRelID,
			@CRMUserID,
            GETDATE(),
			@CRMUserID,
            GETDATE(),
            GETDATE(),
			@CompanyID,
			@RegardingCompanyID,
			'25',
			GETDATE(),
			GETDATE(),
			1,
			'Y');
	END ELSE BEGIN
		-- Update the existing record
		UPDATE PRCompanyRelationship
           SET prcr_TimesReported = prcr_TimesReported + 1,
               prcr_LastReportedDate = GETDATE(),
			   prcr_UpdatedBy = @CRMUserID,
		       prcr_UpdatedDate = GETDATE(),
			   prcr_TimeStamp = GETDATE()
         WHERE prcr_Type = '25'
           AND prcr_LeftCompanyID = @CompanyID
           AND prcr_RightCompanyID = @RegardingCompanyID;
	END
END

-- Determine our Price
DECLARE @UsageTypePrice int
IF @NoCharge = 0 BEGIN
	SET @UsageTypePrice = dbo.ufn_GetUsageTypePrice(@UsageType) 
END ELSE BEGIN
	SET @UsageTypePrice = 0
END


-- Go Get our UniqueID.
DECLARE @ServiceUnitUsageID int
EXEC usp_getNextId 'PRServiceUnitUsage', @ServiceUnitUsageID Output


-- Insert our ServiceUnitUsage record
INSERT INTO PRServiceUnitUsage (
    prsuu_ServiceUnitUsageID,
	prsuu_CreatedBy,
    prsuu_CreatedDate,
	prsuu_UpdatedBy,
	prsuu_UpdatedDate,
	prsuu_TimeStamp,
	prsuu_CompanyID,
    prsuu_PersonID,
	prsuu_Units,
    prsuu_SourceCode,
    prsuu_TransactionTypeCode,
    prsuu_UsageTypeCode,
    prsuu_RegardingObjectID,
    prsuu_SearchCriteria)
VALUES (@ServiceUnitUsageID,
		@CRMUserID,
        GETDATE(),
		@CRMUserID,
        GETDATE(),
        GETDATE(),
		@CompanyID,
		@PersonID,
		@UsageTypePrice,
		@SourceType,
		'U',
		@UsageType,
		@BRRequestID,
		@SearchCriteria);


--
-- Now we need to figure out which allocations
-- to associate this usage with.  Those allocations need
-- to be decremented and the appropriate bridge
-- entries created.
--
DECLARE @Count int, @Ndx int, @ServiceUnitAllocationID int
DECLARE @ServiceUnitAllocationUnitsRemaining int, @CurrentRemaining int

DECLARE @ServiceUnitAllocations table (
	ndx smallint identity, 
	ServiceUnitAllocationID int,
    UnitsRemaining int)

INSERT INTO @ServiceUnitAllocations (ServiceUnitAllocationID, UnitsRemaining)
SELECT prun_ServiceUnitAllocationID, prun_UnitsRemaining
  FROM PRServiceUnitAllocation
 WHERE GETDATE() BETWEEN prun_StartDate AND prun_ExpirationDate
   AND prun_CompanyID = @CompanyID
   AND prun_UnitsRemaining > 0
 ORDER BY prun_ExpirationDate, prun_CreatedDate;

SET @Count = @@ROWCOUNT
SET @ndx = 1	
SET @CurrentRemaining = @UsageTypePrice

WHILE (@Ndx <= @Count) BEGIN
	SELECT @ServiceUnitAllocationID = ServiceUnitAllocationID,
	       @ServiceUnitAllocationUnitsRemaining = UnitsRemaining
      FROM @ServiceUnitAllocations WHERE ndx = @Ndx;

	SET @Ndx = @Ndx + 1

	IF (@CurrentRemaining <= @ServiceUnitAllocationUnitsRemaining) BEGIN
		UPDATE PRServiceUnitAllocation
           SET prun_UnitsRemaining = prun_UnitsRemaining - @CurrentRemaining,
			   prun_UpdatedBy = @CRMUserID,
		       prun_UpdatedDate = GETDATE(),
			   prun_TimeStamp = GETDATE()
         WHERE prun_ServiceUnitAllocationID = @ServiceUnitAllocationID;

		-- We're done so make sure we don't loop 
		-- any further.
		SET @Ndx = @Count + 1
	
	END ELSE BEGIN
		
		-- Decrement by how many this allocation has remaining, then
		-- zero out the allocation.
		SET @CurrentRemaining = @CurrentRemaining - @ServiceUnitAllocationUnitsRemaining	

		UPDATE PRServiceUnitAllocation
           SET prun_UnitsRemaining = 0,
			   prun_UpdatedBy = @CRMUserID,
		       prun_UpdatedDate = GETDATE(),
			   prun_TimeStamp = GETDATE()
         WHERE prun_ServiceUnitAllocationID = @ServiceUnitAllocationID;
	END
	

	--
	-- Create our bridge entry
	--
	DECLARE @ServiceUnitAllocationUsageID int
	EXEC usp_getNextId 'PRServiceUnitAllocationUsage', @ServiceUnitAllocationUsageID Output

	-- Insert our PRServiceUnitAllocationUsage record
	INSERT INTO PRServiceUnitAllocationUsage (
		prsua_ServiceUnitUsageAllocationID,
		prsua_CreatedBy,
		prsua_CreatedDate,
		prsua_UpdatedBy,
		prsua_UpdatedDate,
		prsua_TimeStamp,
		prsua_ServiceUnitAllocationID,
		prsua_ServiceUnitUsageID)
	VALUES (@ServiceUnitAllocationUsageID,
		@CRMUserID,
        GETDATE(),
		@CRMUserID,
        GETDATE(),
        GETDATE(),
		@ServiceUnitAllocationID,
		@ServiceUnitUsageID);
END

IF @@TRANCOUNT > 0
    COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

	DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT	@ErrorMessage = ERROR_MESSAGE(),
			@ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE();

    RAISERROR (@ErrorMessage, 
               @ErrorSeverity,
               @ErrorState);
END CATCH;

SET NOCOUNT ON
GO



/**
 DATA CONVERSION ONLY
 Updates the database for consuming units for the data conversion.  Doesn't 
 create the BR Request record.
**/
If Exists (Select name from sysobjects where name = 'usp_ConsumeServiceUnitsForConversion' and type='P') Drop Procedure dbo.usp_ConsumeServiceUnitsForConversion
Go

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_ConsumeServiceUnitsForConversion]
	@CompanyID int,
    @PersonID int,
	@UsageType nvarchar(40),
    @SourceType nvarchar(40),
    @BRRequestID int,
    @CRMUserID int,
	@NoCharge bit = 0
AS 

SET NOCOUNT ON

-- Check to see if we have the units.
IF dbo.ufn_HasAvailableUnits(@CompanyID, @UsageType) = 0 BEGIN
--	RAISERROR (N'CompanyId %d: Not enough service units available.', 16, 1, @CompanyID)
	RETURN -1
END

BEGIN TRANSACTION;
BEGIN TRY

DECLARE @UsageTypePrice int
IF (@NoCharge = 1) BEGIN
	SET @UsageTypePrice = 0
END ELSE BEGIN 
	SET @UsageTypePrice = dbo.ufn_GetUsageTypePrice(@UsageType) 
END


-- Go Get our UniqueID.
DECLARE @ServiceUnitUsageID int
EXEC usp_getNextId 'PRServiceUnitUsage', @ServiceUnitUsageID Output


-- Insert our ServiceUnitUsage record
INSERT INTO PRServiceUnitUsage (
    prsuu_ServiceUnitUsageID,
	prsuu_CreatedBy,
    prsuu_CreatedDate,
	prsuu_UpdatedBy,
	prsuu_UpdatedDate,
	prsuu_TimeStamp,
	prsuu_CompanyID,
    prsuu_PersonID,
	prsuu_Units,
    prsuu_SourceCode,
    prsuu_TransactionTypeCode,
    prsuu_UsageTypeCode,
    prsuu_RegardingObjectID)
VALUES (@ServiceUnitUsageID,
		@CRMUserID,
        GETDATE(),
		@CRMUserID,
        GETDATE(),
        GETDATE(),
		@CompanyID,
		@PersonID,
		@UsageTypePrice,
		@SourceType,
		'U',
		@UsageType,
		@BRRequestID);


--
-- Now we need to figure out which allocations
-- to associate this usage with.  Those allocations need
-- to be decremented and the appropriate bridge
-- entries created.
--
DECLARE @Count int, @Ndx int, @ServiceUnitAllocationID int
DECLARE @ServiceUnitAllocationUnitsRemaining int, @CurrentRemaining int

DECLARE @ServiceUnitAllocations table (
	ndx smallint identity, 
	ServiceUnitAllocationID int,
    UnitsRemaining int)

INSERT INTO @ServiceUnitAllocations (ServiceUnitAllocationID, UnitsRemaining)
SELECT prun_ServiceUnitAllocationID, prun_UnitsRemaining
  FROM PRServiceUnitAllocation
 WHERE GETDATE() BETWEEN prun_StartDate AND prun_ExpirationDate
   AND prun_CompanyID = @CompanyID
   AND prun_UnitsRemaining > 0
 ORDER BY prun_ExpirationDate, prun_CreatedDate;

SET @Count = @@ROWCOUNT
SET @ndx = 1	
SET @CurrentRemaining = @UsageTypePrice

WHILE (@Ndx <= @Count) BEGIN
	SELECT @ServiceUnitAllocationID = ServiceUnitAllocationID,
	       @ServiceUnitAllocationUnitsRemaining = UnitsRemaining
      FROM @ServiceUnitAllocations WHERE ndx = @Ndx;

	SET @Ndx = @Ndx + 1

	IF (@CurrentRemaining <= @ServiceUnitAllocationUnitsRemaining) BEGIN
		UPDATE PRServiceUnitAllocation
           SET prun_UnitsRemaining = prun_UnitsRemaining - @CurrentRemaining,
			   prun_UpdatedBy = @CRMUserID,
		       prun_UpdatedDate = GETDATE(),
			   prun_TimeStamp = GETDATE()
         WHERE prun_ServiceUnitAllocationID = @ServiceUnitAllocationID;

		-- We're done so make sure we don't loop 
		-- any further.
		SET @Ndx = @Count + 1
	
	END ELSE BEGIN
		
		-- Decrement by how many this allocation has remaining, then
		-- zero out the allocation.
		SET @CurrentRemaining = @CurrentRemaining - @ServiceUnitAllocationUnitsRemaining	

		UPDATE PRServiceUnitAllocation
           SET prun_UnitsRemaining = 0,
			   prun_UpdatedBy = @CRMUserID,
		       prun_UpdatedDate = GETDATE(),
			   prun_TimeStamp = GETDATE()
         WHERE prun_ServiceUnitAllocationID = @ServiceUnitAllocationID;
	END
	

	--
	-- Create our bridge entry
	--
	DECLARE @ServiceUnitAllocationUsageID int
	EXEC usp_getNextId 'PRServiceUnitAllocationUsage', @ServiceUnitAllocationUsageID Output

	-- Insert our PRServiceUnitAllocationUsage record
	INSERT INTO PRServiceUnitAllocationUsage (
		prsua_ServiceUnitUsageAllocationID,
		prsua_CreatedBy,
		prsua_CreatedDate,
		prsua_UpdatedBy,
		prsua_UpdatedDate,
		prsua_TimeStamp,
		prsua_ServiceUnitAllocationID,
		prsua_ServiceUnitUsageID)
	VALUES (@ServiceUnitAllocationUsageID,
		@CRMUserID,
        GETDATE(),
		@CRMUserID,
        GETDATE(),
        GETDATE(),
		@ServiceUnitAllocationID,
		@ServiceUnitUsageID);
END

IF @@TRANCOUNT > 0
    COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

	DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT	@ErrorMessage = ERROR_MESSAGE(),
			@ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE();

    RAISERROR (@ErrorMessage, 
               @ErrorSeverity,
               @ErrorState);
END CATCH;

SET NOCOUNT ON

GO

/**
Cancels the remainging service units for the 
specified service code.
**/
If Exists (Select name from sysobjects where name = 'usp_CancelServiceUnits' and type='P') Drop Procedure dbo.usp_CancelServiceUnits
Go

CREATE PROCEDURE dbo.usp_CancelServiceUnits
	@CompanyID int,
	@ServiceID int
AS 

SET NOCOUNT ON

DECLARE @CRMUserID int
SET @CRMUserID = dbo.ufn_GetSystemUserId(1)


DECLARE @ConsumedUnits int
SET @ConsumedUnits = dbo.ufn_GetConsumedUnitsForService(@CompanyID, @ServiceID)

-- Build a table of the Allocation records
-- we need to operate on.
DECLARE @UnitAllocationIDs table (
	ndx smallint identity, 
	ServiceUnitAllocationID int 
)

INSERT INTO @UnitAllocationIDs (ServiceUnitAllocationID)
SELECT prun_ServiceUnitAllocationID
  FROM PRServiceUnitAllocation
 WHERE GETDATE() BETWEEN prun_StartDate AND prun_ExpirationDate
   AND prun_CompanyID = @CompanyID
   AND prun_ServiceID = @ServiceID;



-- Determine how many units remain for the
-- specified service id.
DECLARE @RemainingUnits int
SELECT @RemainingUnits = SUM(prun_UnitsRemaining) 
  FROM PRServiceUnitAllocation 
       INNER JOIN @UnitAllocationIDs on prun_ServiceUnitAllocationID = ServiceUnitAllocationID
 
IF @RemainingUnits IS NULL SET @RemainingUnits=0


IF @RemainingUnits > 0 BEGIN

	-- Create a single Usage record for
	-- the remaining units.

	-- Go Get our UniqueID.
	DECLARE @ServiceUnitUsageID int
	EXEC usp_getNextId 'PRServiceUnitUsage', @ServiceUnitUsageID Output

	-- Insert our ServiceUnitUsage record
	INSERT INTO PRServiceUnitUsage (
		prsuu_ServiceUnitUsageID,
		prsuu_CreatedBy,
		prsuu_CreatedDate,
		prsuu_UpdatedBy,
		prsuu_UpdatedDate,
		prsuu_TimeStamp,
		prsuu_CompanyID,
		prsuu_Units,
		prsuu_SourceCode,
		prsuu_TransactionTypeCode,
		prsuu_UsageTypeCode)
	VALUES (@ServiceUnitUsageID,
			@CRMUserID,
			GETDATE(),
			@CRMUserID,
			GETDATE(),
			GETDATE(),
			@CompanyID,
			@RemainingUnits,
			'C', -- CSR
			'C', -- Cancelleation
			'C');  -- Cancelleation

	-- Zero out the remaining units for
	-- our allocation records.
	UPDATE PRServiceUnitAllocation
	   SET prun_UnitsRemaining = 0,
		   prun_UpdatedBy = @CRMUserID,
		   prun_UpdatedDate = GETDATE(),
		   prun_TimeStamp = GETDATE()
	  FROM PRServiceUnitAllocation 
		   INNER JOIN @UnitAllocationIDs on prun_ServiceUnitAllocationID = ServiceUnitAllocationID

	-- Now spin through the allocation records creating a bridge
	-- entry for each one pointing to our newly created usage record
	DECLARE @Count int, @Ndx int, @ServiceUnitAllocationID int

	SELECT @Count = COUNT(1) FROM @UnitAllocationIDs;
	SET @ndx = 1	

	WHILE (@Ndx <= @Count) BEGIN
		SELECT @ServiceUnitAllocationID = ServiceUnitAllocationID
		  FROM @UnitAllocationIDs WHERE ndx = @Ndx;

		SET @Ndx = @Ndx + 1

		--
		-- Create our bridge entry
		--
		DECLARE @ServiceUnitAllocationUsageID int
		EXEC usp_getNextId 'PRServiceUnitAllocationUsage', @ServiceUnitAllocationUsageID Output

		-- Insert our PRServiceUnitAllocationUsage record
		INSERT INTO PRServiceUnitAllocationUsage (
			prsua_ServiceUnitUsageAllocationID,
			prsua_CreatedBy,
			prsua_CreatedDate,
			prsua_UpdatedBy,
			prsua_UpdatedDate,
			prsua_TimeStamp,
			prsua_ServiceUnitAllocationID,
			prsua_ServiceUnitUsageID)
		VALUES (@ServiceUnitAllocationUsageID,
			@CRMUserID,
			GETDATE(),
			@CRMUserID,
			GETDATE(),
			GETDATE(),
			@ServiceUnitAllocationID,
			@ServiceUnitUsageID);
	END
END

SELECT @ConsumedUnits as CancelledUnits

SET NOCOUNT OFF
GO



/**
Reverses a service unit consumption by making a negative entry in the PRServiceUnitUsage table and modifying the allocation
**/
If Exists (Select name from sysobjects where name = 'usp_ReverseServiceUnitUsage' and type='P') Drop Procedure dbo.usp_ReverseServiceUnitUsage
Go

CREATE PROCEDURE dbo.usp_ReverseServiceUnitUsage
	@OriginalServiceUnitUsageID int,
	@SourceCode nvarchar(40), 
	@ReversalReason nvarchar(40), 
	@CRMUserId int = null
AS 
BEGIN
	SET NOCOUNT ON

	-- If we don't have a CRM User, go get the
	-- default website user
	IF @CRMUserID = 0 BEGIN
		SET @CRMUserID = dbo.ufn_GetSystemUserId(1)
	END

	DECLARE @Now datetime
	SET @Now = getDate()

	BEGIN TRANSACTION;
	BEGIN TRY

	-- Determine our Price
	DECLARE @UsageTypePrice int
	Select @UsageTypePrice from PRServiceUnitUsage where prsuu_ServiceUnitUsageId = @OriginalServiceUnitUsageID

	-- Go Get our UniqueID.
	DECLARE @ServiceUnitUsageID int
	EXEC usp_getNextId 'PRServiceUnitUsage', @ServiceUnitUsageID Output

	-- Insert our ServiceUnitUsage record
	INSERT 
		INTO PRServiceUnitUsage (prsuu_ServiceUnitUsageID,
			prsuu_CreatedBy, prsuu_CreatedDate,	prsuu_UpdatedBy, prsuu_UpdatedDate,	prsuu_TimeStamp,
			prsuu_CompanyID, prsuu_PersonID, prsuu_TransactionTypeCode, prsuu_UsageTypeCode,
			prsuu_RegardingObjectID, prsuu_SearchCriteria,
			prsuu_SourceCode, prsuu_ReversalServiceUnitUsageId, prsuu_Units, prsuu_ReversalReasonCode )
		SELECT @ServiceUnitUsageID,	
				@CRMUserID, @Now, @CRMUserID, @Now, @Now,
				prsuu_CompanyID, prsuu_PersonID, 'R', prsuu_UsageTypeCode,
				prsuu_RegardingObjectID, prsuu_SearchCriteria, 
				@SourceCode, @OriginalServiceUnitUsageID, @UsageTypePrice * -1, @ReversalReason
		  FROM PRServiceUnitUsage 
		 WHERE prsuu_ServiceUnitUsageId = @OriginalServiceUnitUsageID


	--
	-- Now we need to figure out which allocations
	-- this usage was associated with.  Those allocations need
	-- to be re-incremented and the appropriate bridge
	-- entries created.
	--
	DECLARE @Count int, @Ndx int, @ServiceUnitAllocationID int
	DECLARE @UnitsReallocated int -- Total Count of Units that have been reallocated
	DECLARE @UnitAllocation int -- The number of Units to reallocate to each PRServiceAllocationUnit record
	DECLARE @AllocationUnitsDelta int -- differnce between prun_AllocatedUnits and prun_RemainingUnits 
	DECLARE @CurrentRemaining int

	DECLARE @ServiceUnitAllocations table (
		ndx smallint identity, 
		ServiceUnitAllocationID int,
		AvailableToReallocate int)

	INSERT INTO @ServiceUnitAllocations (ServiceUnitAllocationID, AvailableToReallocate)
	SELECT prun_ServiceUnitAllocationID, prun_UnitsAllocated - prun_UnitsRemaining
	  FROM PRServiceUnitAllocation
	 WHERE prun_ServiceUnitAllocationId in 
		(Select prsua_ServiceUnitAllocationId from PRServiceUnitAllocationUsage
		  where prsua_ServiceUnitUsageId = @OriginalServiceUnitUsageID
		)
	 ORDER BY prun_ExpirationDate DESC, prun_CreatedDate DESC;

	SET @Count = @@ROWCOUNT
	SET @Ndx = 1	
	SET @UnitsReallocated = 0

	WHILE (@UnitsReallocated < @UsageTypePrice) BEGIN
		SELECT @ServiceUnitAllocationID = ServiceUnitAllocationID,
			   @AllocationUnitsDelta = AvailableToReallocate
		  FROM @ServiceUnitAllocations WHERE ndx = @Ndx;

		SET @Ndx = @Ndx + 1

		IF (@AllocationUnitsDelta >= @UsageTypePrice - @UnitsReallocated)
			SET @UnitAllocation = @UsageTypePrice - @UnitsReallocated
		ELSE
			SET @UnitAllocation = @AllocationUnitsDelta
			
		-- REstore as many AllocationUnits as possible
		UPDATE PRServiceUnitAllocation
		   SET prun_UnitsRemaining = prun_UnitsRemaining + @UnitAllocation,
			   prun_UpdatedDate = @Now, prun_Timestamp = @Now, prun_UpdatedBy = @CRMUserID
		 WHERE prun_ServiceUnitAllocationID = @ServiceUnitAllocationID;

		SET @UnitsReallocated = @UnitsReallocated + @UnitAllocation
		
		--
		-- Create the bridge entry
		--
		DECLARE @ServiceUnitAllocationUsageID int
		EXEC usp_getNextId 'PRServiceUnitAllocationUsage', @ServiceUnitAllocationUsageID Output

		-- Insert our PRServiceUnitAllocationUsage record
		INSERT INTO PRServiceUnitAllocationUsage (
			prsua_ServiceUnitUsageAllocationID,
			prsua_CreatedBy, prsua_CreatedDate, prsua_UpdatedBy, prsua_UpdatedDate,	prsua_TimeStamp,
			prsua_ServiceUnitAllocationID, prsua_ServiceUnitUsageID)
		VALUES (@ServiceUnitAllocationUsageID,
			@CRMUserID, @Now, @CRMUserID, @Now, @Now,
			@ServiceUnitAllocationID, @ServiceUnitUsageID);
	END

	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION;

	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		SELECT	@ErrorMessage = ERROR_MESSAGE(),
				@ErrorSeverity = ERROR_SEVERITY(),
				@ErrorState = ERROR_STATE();

		RAISERROR (@ErrorMessage, 
				   @ErrorSeverity,
				   @ErrorState);
	END CATCH;

	SET NOCOUNT ON
END
GO



If Exists (Select name from sysobjects where name = 'usp_AllocateServiceUnits' and type='P') Drop Procedure dbo.usp_AllocateServiceUnits
Go

/**
Determines if the specified company has enough available
units for the specified usage type.
**/
CREATE PROCEDURE dbo.usp_AllocateServiceUnits
	@CompanyID int,
    @PersonID int,
	@Units int,
	@SourceType nvarchar(40),
	@ServiceID int,
	@AllocationType nvarchar(40),
	@StartDate datetime = null,
    @CRMUserID int = 0
AS

SET NOCOUNT ON

-- If we don't have a CRM User, go get the
-- default website user
IF @CRMUserID = 0 BEGIN
	SET @CRMUserID = dbo.ufn_GetSystemUserId(1)
END

IF (@StartDate IS NULL) SET @StartDate = CONVERT(DateTime, convert(varchar, GetDate(),101))

-- Compute our End Date
-- For a membership allocation, it is the first day of the same month of the next year. (Note: will always be 1/1)
-- For an additional unit pack allocation, it is the first day of the next month of the next year.
DECLARE @EndDate datetime, @TempDate datetime
IF @AllocationType = 'A' BEGIN
	SET @TempDate = DATEADD(Month, 1, @StartDate)
END ELSE BEGIN
	SET @TempDate = @StartDate
END
SET @EndDate = CONVERT(DateTime, CONVERT(varchar(4), YEAR(@TempDate)+1) + '-' +  CONVERT(varchar(4), Month(@TempDate)) + '-1')

DECLARE @ServiceUnitAllocationID int
EXEC usp_getNextId 'PRServiceUnitAllocation', @ServiceUnitAllocationID Output
	
INSERT INTO PRServiceUnitAllocation (
		prun_ServiceUnitAllocationID,
		prun_CreatedBy,
		prun_CreatedDate,
		prun_UpdatedBy,
		prun_UpdatedDate,
		prun_TimeStamp,
		prun_CompanyID,
		prun_PersonID,
		prun_ServiceID,
		prun_SourceCode,
		prun_AllocationTypeCode,
		prun_StartDate,
		prun_ExpirationDate,
		prun_UnitsAllocated,
		prun_UnitsRemaining)
VALUES (@ServiceUnitAllocationID,
		@CRMUserID,
        GETDATE(),
		@CRMUserID,
        GETDATE(),
        GETDATE(),
		@CompanyID,
		@PersonID,
		@ServiceID,
		@SourceType,
		@AllocationType,
		@StartDate,
		@EndDate,
		@Units,
		@Units);

SELECT @ServiceUnitAllocationID;

SET NOCOUNT OFF
GO

/**
Updates the pending PRServiceUnitAllocation record for the
specified company and ServiceUnitAllocation.  If successful
a '0' is returned, otherwise a descriptive message is returned.
**/
If Exists (Select name from sysobjects where name = 'usp_ReconcileOnlineAllocation' and type='P') Drop Procedure dbo.usp_ReconcileOnlineAllocation
Go

CREATE PROCEDURE dbo.usp_ReconcileOnlineAllocation
	@CompanyID int,
	@PRServiceUnitAllocationID int,
	@ServiceID int
AS

DECLARE @Return varchar(100)

SET @Return = dbo.ufn_IsOnlineAllocationReconciliationValid(@CompanyID, @PRServiceUnitAllocationID)
IF @Return = '0' BEGIN
	
	UPDATE PRServiceUnitAllocation
       SET prun_ServiceID = @ServiceID
     WHERE prun_ServiceUnitAllocationID = @PRServiceUnitAllocationID
       AND prun_CompanyID = @CompanyID
       AND prun_SourceCode = 'O';  -- Online

END

SELECT @Return
Go



/*
	-- Create a task for the assigned user

	@AssignedToUserType is used if the @AssignedToUser is not populated.  This will be used to look
		up a PRCo Specialist based upon the following user type (these match ufn_GetPRCoSpecialistUserId):
		0: prci_RatingUserId
		1: prci_InsideSalesRepId
		2: prci_FieldSalesRepId
		3: prci_ListingSpecialistId
		4: prci_CustomerServiceId
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_CreateTask]'))
	drop Procedure [dbo].[usp_CreateTask]
GO
CREATE Procedure dbo.usp_CreateTask
    @StartDateTime datetime = null,
    @DueDateTime datetime = null,
    @CreatorUserId int = null,
    @AssignedToUserId int = null,
    @TaskNotes text = null,
    @RelatedCompanyId int = NULL,
    @RelatedPersonId int = NULL,
    @Status varchar(40) = 'Complete',
    @Action varchar(40) = 'ToDo',
    @Type varchar(40) = 'Task',
    @Priority varchar(40) = 'Normal',
    @ReminderDateTime datetime = null,
    @SMSNotification char(1) = null,
    @PRBusinessEventId int = null,
    @PRPersonEventId int = null,
    @PRTESId int = null,
    @PRCreditSheetId int = null,
    @PRFileId int = null,
    @PRCategory varchar(40) = null,
	@AssignedToUserType tinyint = 0,
	@AssociatedColumnName varchar(40) = null,
    @PRSubcategory varchar(40) = null
AS
BEGIN
	Declare @Now datetime
	SET @Now = GetDate()
	if (@StartDateTime is null)
		SET @StartDateTime = @Now
    --TODO:  Add some checks to make sure we have enough info to create a task.

	Declare @nextCommId int
    Declare @nextCommLinkId int
    exec usp_GetNextId 'Communication', @nextCommId out
    exec usp_GetNextId 'Comm_Link', @nextCommLinkId out 
    
	Declare @ReminderFlag char(1)
	if (@ReminderDateTime IS NOT NULL)
		SET @ReminderFlag = 'Y'

	-- determine the Assigned To user (if one is not passed) based upon the CompanyId and AssignedToUser Type
	IF (@AssignedToUserId is null)
	BEGIN
		If (@RelatedCompanyId is not null)
		Begin
			-- default is the Rating Analyst
			SELECT @AssignedToUserId = dbo.ufn_GetPRCoSpecialistUserId (@RelatedCompanyId, @AssignedToUserType)
		End
	END

	INSERT INTO Communication
		(Comm_CommunicationId, Comm_CreatedBy, Comm_UpdatedBy, Comm_CreatedDate, Comm_UpdatedDate, Comm_TimeStamp
		   ,Comm_Type, Comm_Action, Comm_Status, Comm_Priority, Comm_DateTime, Comm_ToDateTime
           ,Comm_Note, Comm_NotifyTime, Comm_TaskReminder, Comm_SMSNotification
           ,comm_PRBusinessEventId ,comm_PRPersonEventId, comm_PRTESId
           ,comm_PRCreditSheetId, comm_PRFileId ,comm_PRCategory, comm_PRAssociatedColumnName
           ,comm_PRSubcategory)
     VALUES
           (@nextCommId, @CreatorUserId, @CreatorUserId, @Now, @Now, @Now,
				@Type, @Action, @Status, @Priority, @StartDateTime, @DueDateTime, 
				@TaskNotes, @ReminderDateTime, @ReminderFlag, @SMSNotification, 
	            @PRBusinessEventId, @PRPersonEventId, @PRTESId,
		        @PRCreditSheetId, @PRFileId, @PRCategory, @AssociatedColumnName,
                @PRSubcategory)
		        
	INSERT INTO Comm_Link
           (CmLi_CommLinkId, CmLi_CreatedBy, CmLi_UpdatedBy, CmLi_CreatedDate, CmLi_UpdatedDate,CmLi_TimeStamp
           ,CmLi_Comm_UserId,CmLi_Comm_CommunicationId,CmLi_Comm_PersonId,CmLi_Comm_CompanyId,CmLi_Comm_NotifyTime)
     VALUES
           (@nextCommLinkId, @CreatorUserId, @CreatorUserId, @Now, @Now, @Now
           ,@AssignedToUserId, @nextCommId, @RelatedPersonId, @RelatedCompanyId, @ReminderDateTime)


END
GO



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_CreateEmail]'))
drop Procedure [dbo].[usp_CreateEmail]
GO
CREATE Procedure dbo.usp_CreateEmail
    @CreatorUserId int = null,
    @To text = null,
    @From text = null,
    @Subject text = null,
    @Content text = null,
    @Priority varchar(40) = 'Normal',
    @CC text = null,
    @BCC text = null,
    @AttachmentDir varchar(255) = null,
    @AttachmentFileName varchar(255) = null,
    @Content_Format varchar(20) = 'TEXT',
    @RelatedCompanyId int = NULL,
    @RelatedPersonId int = NULL,
    @Action varchar(40) = 'EmailOut',
    @DoNotRecordCommunication bit = 0,
    @DoNotSend bit = 0,
    @AttachmentIsLibraryDoc bit = 0,
    @PRCategory varchar(40) = NULL,
    @PRSubcategory varchar(40) = NULL
AS
BEGIN
	Declare @ret_value int
	set @ret_value = -1
	
    Declare @Status varchar(40) 
    SET @Status = 'Complete'
    Declare @Type varchar(40) 

	IF @Action = 'EmailOut' BEGIN
		SET @Type = 'Email'
	END ELSE BEGIN
		SET @Type = 'Fax'
	END

	Declare @Now datetime
	SET @Now = GetDate()
	
	Declare @ToName varchar(500)
	If (@RelatedCompanyId is not null)
		SELECT @ToName = comp_Name from Company Where comp_CompanyId = @RelatedCompanyId;
	-- override with the person	
	If (@RelatedPersonId is not null)
		SELECT @ToName = dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_MiddleName, NULL, pers_Suffix)
            from Person Where pers_PersonId = @RelatedPersonId;
	
	Declare @HasAttachments char(1)
	if (@AttachmentFileName is not null)
		SET @HasAttachments = 'Y'
    
	-- Give the caller a chance to not save a communication record
	IF (@DoNotRecordCommunication = 0)
    BEGIN
		Declare @nextCommId int
		Declare @nextCommLinkId int
		exec usp_GetNextId 'Communication', @nextCommId out
		exec usp_GetNextId 'Comm_Link',  @nextCommLinkId out
	    
		INSERT INTO Communication
			(Comm_CommunicationId, Comm_CreatedBy, Comm_UpdatedBy, Comm_CreatedDate, Comm_UpdatedDate, Comm_TimeStamp,
			 Comm_Type, Comm_Action, Comm_Status, Comm_Priority, Comm_DateTime, 
			 Comm_Note, Comm_Email, Comm_From, Comm_TO, Comm_CC, Comm_BCC, Comm_DocDir, Comm_DocName, Comm_HasAttachments,
             Comm_PRCategory, Comm_PRSubcategory
			)
		 VALUES
			(@nextCommId, @CreatorUserId, @CreatorUserId, @Now, @Now, @Now,
			 @Type, @Action, @Status, @Priority, @Now, 
			 @Subject, @Content, @From, @To, @CC, @BCC, @AttachmentDir, @AttachmentFileName, @HasAttachments,
             @PRCategory, @PRSubcategory) 
	    

		INSERT INTO Comm_Link
			   (CmLi_CommLinkId, CmLi_CreatedBy, CmLi_UpdatedBy, CmLi_CreatedDate, CmLi_UpdatedDate,CmLi_TimeStamp
			   ,CmLi_Comm_UserId,CmLi_Comm_CommunicationId,CmLi_Comm_PersonId,CmLi_Comm_CompanyId)
		 VALUES
			   (@nextCommLinkId, @CreatorUserId, @CreatorUserId, @Now, @Now, @Now
			   ,@CreatorUserId, @nextCommId, @RelatedPersonId, @RelatedCompanyId)
	END

	-- Give the Caller a chance to not actually send the email
	IF (@DoNotSend = 0)
	BEGIN
		
		DECLARE @ProfileName varchar(100)
		SET @ProfileName = 'Blue Book Services'

	    -- if this is a fax, then write it
		-- to the faxqueue for processing by
		-- the windows service
		IF (@Action = 'FaxOut') BEGIN

			DECLARE @IsInternational bit
            DECLARE @WorkArea varchar(100)
			SET @IsInternational = 0
			SET @WorkArea = @To

			-- Domestic # are always < 12, unless we have 
			-- vanity #s which will fail regardless.
			IF (LEN(@WorkArea) > 12) BEGIN
				SET @IsInternational = 1
			END ELSE BEGIN
				
				-- Domestic numbers will not have a space
                -- in the third position
				IF (SUBSTRING(@WorkArea, 3, 1) = ' ') BEGIN 
					SET @IsInternational = 1
				END ELSE BEGIN

					-- Domestic numbers will have a dash in 8th position
					IF (LEN(@WorkArea) > 8) AND (SUBSTRING(@WorkArea, 8, 1) <> '-') BEGIN 
						SET @IsInternational = 1
					END 
				END
			END

			IF (@IsInternational = 1) BEGIN
				SET @To = '011 ' + @WorkArea
			END

			SET @To = dbo.ufn_GetCustomCaptionValue('FaxOverride', 'Fax', @To)

			DECLARE @Who varchar(50), @PersonName varchar(100)

			-- Who is sending the fax?
			SELECT @Who = RTRIM(user_Logon)
              FROM Users
             WHERE user_userID = @CreatorUserId;

			-- Whom are we sending it to?
			SELECT @PersonName = dbo.ufn_FormatPerson(Pers_FirstName, Pers_LastName, Pers_MiddleName, Pers_PRNickname1, Pers_Suffix)
              FROM Person
             WHERE pers_PersonID = @RelatedPersonId;

			INSERT INTO PRFaxQueue (Who, Attachment, FaxNumber, PersonName, Priority, IsLibraryDocument)
			    VALUES (@Who, @AttachmentFileName, @To, @PersonName, @Priority, @AttachmentIsLibraryDoc);
		END
    

		IF (@Action = 'EmailOut') BEGIN

			SET @To = dbo.ufn_GetCustomCaptionValue('EmailOverride', 'Email', @To)

			BEGIN TRY
				EXECUTE AS User = 'DBFileAccess'; 
				Execute @ret_value = msdb.dbo.sp_send_dbmail     
					@profile_name = @ProfileName,     
					@recipients = @To, 
					@copy_recipients = @CC,
					@blind_copy_recipients = @BCC,    
					@body = @Content,    
					@subject = @Subject,
					@importance = @Priority,
					@body_format = @Content_Format,
					@file_attachments=@AttachmentFileName ;
				-- always revert the user context back
				REVERT
			END TRY
			BEGIN CATCH
				-- always revert the user context back
				REVERT
				DECLARE @ErrorMessage NVARCHAR(4000);
				DECLARE @ErrorState INT;

				SELECT	@ErrorMessage = ERROR_MESSAGE(),
						@ErrorState = ERROR_STATE();

				RAISERROR (@ErrorMessage,16, @ErrorState);
			END CATCH;
		END
	END
	
	RETURN @ret_value
END
GO



IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_SaveAUS]') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.usp_SaveAUS
GO

CREATE PROCEDURE dbo.usp_SaveAUS
    @prau_AUSId int = NULL,
    @prau_CompanyId int = NULL,
    @prau_PersonId int = NULL,
    @prau_MonitoredCompanyId int = null,
    @UserId int = -1
as
BEGIN
    DECLARE @Msg varchar(2000)
    DECLARE @NewAUSId int
	DECLARE @bNew bit
	
	SET @bNew = 0
	IF (@prau_AUSId is null)
	BEGIN
		SET @bNew = 1
		EXEC usp_GetNextId 'PRAUS', @prau_AUSId output
	END
    
    -- if the AUSId is null we have a problem
    IF ( @prau_AUSId IS NULL or @prau_PersonId IS NULL or @prau_CompanyId IS NULL or @prau_MonitoredCompanyId IS NULL) 
    BEGIN
        SET @Msg = 'Update Failed.  A require field is missing.'
        RAISERROR (@Msg, 16, 1)
        Return
    END
    
	Declare @dtNow datetime
	SET @dtNow = getdate()

    BEGIN TRY
		-- Start making our updates
		BEGIN TRANSACTION

		-- Save the PRAUS record
		if (@bNew = 1)
		Begin
			INSERT INTO PRAUS 
				(prau_AUSId, prau_CreatedBy, prau_CreatedDate, prau_UpdatedBy, prau_UpdatedDate, prau_TimeStamp,
					prau_PersonId, prau_CompanyId, prau_MonitoredCompanyId)
			VALUES
				(@prau_AUSId, @UserId, @dtNow, @UserId, @dtNow, @dtNow,
					@prau_PersonId, @prau_CompanyId, @prau_MonitoredCompanyId)

		End
		Else
		Begin
			UPDATE PRAUS SET
				prau_UpdatedBy = @UserId,
				prau_UpdatedDate = @dtNow,
				prau_TimeStamp = @dtNow,
				prau_CompanyId = @prau_CompanyId,
				prau_MonitoredCompanyId = @prau_MonitoredCompanyId
			WHERE prau_AUSId = @prau_AUSId
		End

		-- Create/update a company relationship record for this AUS
		DECLARE @prcr_CompanyRelationshipId int
		SELECT @prcr_CompanyRelationshipId 
			from PRCompanyRelationship 
			WHERE prcr_LeftCompanyId = @prau_CompanyId
			  AND prcr_RightCompanyId = @prau_MonitoredCompanyId
			  AND prcr_Type = 23
		-- IF @prcr_CompanyRelationshipId is null, create a record
		IF (@prcr_CompanyRelationshipId is null)
		BEGIN
			EXEC usp_GetNextId 'PRCompanyRelationship', @prcr_CompanyRelationshipId output
			INSERT INTO PRCompanyRelationship
				([prcr_CompanyRelationshipId],[prcr_CreatedBy],[prcr_CreatedDate]
				   ,[prcr_UpdatedBy],[prcr_UpdatedDate],[prcr_TimeStamp]
				   ,[prcr_LeftCompanyId],[prcr_RightCompanyId],[prcr_Type]
				   ,[prcr_EnteredDate],[prcr_LastReportedDate]
				   ,[prcr_TimesReported],[prcr_Active])
			 VALUES
				   (@prcr_CompanyRelationshipId, @UserId, @dtNow, @UserId, @dtNow, @dtNow,
						@prau_CompanyId, @prau_MonitoredCompanyId, '23', 
						@dtNow, @dtNow, 1, 'Y')
		END
		ELSE
		BEGIN
			UPDATE PRCompanyRelationship
			   SET [prcr_UpdatedBy] = @UserId
				  ,[prcr_UpdatedDate] = @dtNow
				  ,[prcr_TimeStamp] = @dtNow
				  ,[prcr_LastReportedDate] = @dtNow
				  ,[prcr_TimesReported] = prcr_TimesReported + 1
			 WHERE prcr_CompanyRelationshipId = @prcr_CompanyRelationshipId    
		END
		-- if we made it here, commit our work
		COMMIT
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK

		-- Raise an error with the details of the exception
		DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int
		SELECT @ErrMsg = ERROR_MESSAGE(),
				@ErrSeverity = ERROR_SEVERITY()

		RAISERROR(@ErrMsg, 16, 1)
	END CATCH
END
GO



/**
Adds an entry to the PRAUS table for the specified parameters.  Inserts or
Updates the appropriate PRCompanyRelationship record as well.  Skips any 
duplicate entries.
**/

If Exists (Select name from sysobjects where name = 'usp_AUSEntryAdd' and type='P') Drop Procedure dbo.usp_AUSEntryAdd
Go

CREATE PROCEDURE dbo.usp_AUSEntryAdd (
	@PersonID int,
	@CompanyID int,
	@MonitoredCompanyIDList varchar(2000),
    @CRMUserID int = 0)
AS 

DECLARE @Index int, @CompanyCount int, @MonitorCompanyID int, @ExistCount int

DECLARE @AUSCompanyIDs table (
    idx smallint,
	CompanyID int
)

INSERT INTO @AUSCompanyIDs SELECT idx, CONVERT(int, value) from dbo.Tokenize(@MonitoredCompanyIDList, ',');
SET @CompanyCount = @@ROWCOUNT
SET @Index = 0

-- If we don't have a CRM User, go get the
-- default website user
IF @CRMUserID = 0 BEGIN
	SET @CRMUserID = dbo.ufn_GetSystemUserId(1)
END


WHILE (@Index < @CompanyCount) BEGIN
	SELECT @MonitorCompanyID = CompanyID 
      FROM @AUSCompanyIDs 
     WHERE idx =  @Index;

	SELECT @ExistCount = COUNT(1)
      FROM PRAUS
     WHERE prau_PersonID = @PersonID
       AND prau_CompanyID = @CompanyID
       AND prau_MonitoredCompanyID = @MonitorCompanyID;

	-- Only add the company if we don't already
    -- have it in our list.
	IF (@ExistCount = 0) BEGIN

		DECLARE @AUSID int
		EXEC usp_getNextId 'PRAUS', @AUSID Output

		INSERT INTO PRAUS (
			prau_AUSId,
			prau_CreatedBy,
			prau_CreatedDate,
			prau_UpdatedBy,
			prau_UpdatedDate,
            prau_TimeStamp,
			prau_PersonID,
			prau_CompanyID,
			prau_MonitoredCompanyID)
		VALUES (
			@AUSID,
			@CRMUserID,
			GetDate(),
			@CRMUserID,
			GetDate(),
			GetDate(),
			@PersonID,
			@CompanyID,
			@MonitorCompanyID);


		-- Now determine if we need to create or 
		-- update the PRCompanyRelationship record.
		SELECT 'x' 
		  FROM PRCompanyRelationship
		 WHERE prcr_Type = '23'
		   AND prcr_LeftCompanyID = @CompanyID
		   AND prcr_RightCompanyID = @MonitorCompanyID;

		IF @@ROWCOUNT = 0 BEGIN

			-- Create a new record
			DECLARE @CompRelID int
			EXEC usp_getNextId 'PRCompanyRelationship', @CompRelID Output

			INSERT INTO PRCompanyRelationship (
				prcr_CompanyRelationshipID,
				prcr_CreatedBy,
				prcr_CreatedDate,
				prcr_UpdatedBy,
				prcr_UpdatedDate,
				prcr_TimeStamp,
				prcr_LeftCompanyID,
				prcr_RightCompanyID,
				prcr_Type,
				prcr_EnteredDate,
				prcr_LastReportedDate,
				prcr_TimesReported,
				prcr_Active)
			VALUES (@CompRelID,
				@CRMUserID,
				GETDATE(),
				@CRMUserID,
				GETDATE(),
				GETDATE(),
				@CompanyID,
				@MonitorCompanyID,
				'23',
				GETDATE(),
				GETDATE(),
				1,
				'Y');
		END ELSE BEGIN
			-- Update the existing record
			UPDATE PRCompanyRelationship
	           SET prcr_TimesReported = prcr_TimesReported + 1,
                   prcr_Active = 'Y',
	               prcr_LastReportedDate = GETDATE(),
				   prcr_UpdatedBy = @CRMUserID,
		           prcr_UpdatedDate = GETDATE(),
			       prcr_TimeStamp = GETDATE()
	         WHERE prcr_Type = '23'
	           AND prcr_LeftCompanyID = @CompanyID
	           AND prcr_RightCompanyID = @MonitorCompanyID;
		END
	END

	SET @Index = @Index + 1
END
GO


/**
Deletes the specified AUS entry and updates the PRRelationship
record accordingly.
**/
If Exists (Select name from sysobjects where name = 'usp_AUSEntryDelete' and type='P') Drop Procedure dbo.usp_AUSEntryDelete
Go

CREATE PROCEDURE dbo.usp_AUSEntryDelete (
	@PersonID int,
	@CompanyID int,
	@AUSID int,
    @CRMUserID int = 0)
AS 
	DECLARE @MontioredCompanyID int

	-- If we don't have a CRM User, go get the
	-- default website user
	IF @CRMUserID = 0 BEGIN
		SET @CRMUserID = dbo.ufn_GetSystemUserId(1)
	END

	SELECT @MontioredCompanyID = prau_MonitoredCompanyID
	  FROM PRAUS
	 WHERE prau_PersonID = @PersonID
	   AND prau_CompanyID = @CompanyID
	   AND prau_AUSID = @AUSID;

	IF (@MontioredCompanyID IS NOT NULL) BEGIN
		DELETE 
		  FROM PRAUS
		 WHERE prau_PersonID = @PersonID
		   AND prau_CompanyID = @CompanyID
		   AND prau_AUSID = @AUSID;

		-- Update the existing record
		UPDATE PRCompanyRelationship
		   SET prcr_TimesReported = prcr_TimesReported + 1,
			   prcr_Active = NULL,
			   prcr_LastReportedDate = GETDATE(),
			   prcr_UpdatedBy = @CRMUserID,
		       prcr_UpdatedDate = GETDATE(),
			   prcr_TimeStamp = GETDATE()
		 WHERE prcr_Type = '23'
		   AND prcr_LeftCompanyID = @CompanyID
		   AND prcr_RightCompanyID = @MontioredCompanyID;
	END
Go




/**
Sets the ShowOnHomePage column for the specified AUS entry.
**/
If Exists (Select name from sysobjects where name = 'usp_AUSEntryShowOnHomePage' and type='P') Drop Procedure dbo.usp_AUSEntryShowOnHomePage
Go

CREATE PROCEDURE dbo.usp_AUSEntryShowOnHomePage (
	@PersonID int,
	@CompanyID int,
	@AUSID int,
	@ShowOnHomePage nchar(1) = NULL,
    @CRMUserID int = 0)
AS 

-- If we don't have a CRM User, go get the
-- default website user
IF @CRMUserID = 0 BEGIN
	SET @CRMUserID = dbo.ufn_GetSystemUserId(1)
END

UPDATE PRAUS
   SET prau_ShowOnHomePage = @ShowOnHomePage,
	   prau_UpdatedBy = @CRMUserID,
       prau_UpdatedDate = GETDATE(),
	   prau_TimeStamp = GETDATE()
 WHERE prau_PersonID = @PersonID
   AND prau_CompanyID = @CompanyID
   AND prau_AUSID = @AUSID;
Go


/**
Updates the AUS Settings for the specified person and company.  I included the
peli_personlinkid as a security measure. 
**/
If Exists (Select name from sysobjects where name = 'usp_AUSSettingsUpdate' and type='P') Drop Procedure dbo.usp_AUSSettingsUpdate
Go

CREATE PROCEDURE dbo.usp_AUSSettingsUpdate (
	@PersonID int,
	@CompanyID int,
	@peli_PersonID int,
	@ReceiveMethod varchar(40),
	@ChangePreference varchar(40),
    @CRMUserID int = 0)
AS 

-- If we don't have a CRM User, go get the
-- default website user
IF @CRMUserID = 0 BEGIN
	SET @CRMUserID = dbo.ufn_GetSystemUserId(1)
END

UPDATE Person_Link
   SET peli_PRAUSReceiveMethod = @ReceiveMethod,
	   peli_PRAUSChangePreference = @ChangePreference,
	   peli_UpdatedBy = @CRMUserID,
       peli_UpdatedDate = GETDATE(),
       peli_TimeStamp = GETDATE()
 WHERE peli_PersonID = @PersonID
   AND peli_CompanyID = @CompanyID
   AND peli_PersonLinkID = @peli_PersonID
   AND peli_PRStatus = '1'; -- Active
Go


/**
Creates the PRTES and PRTESDetail records 
	@CompanyId: The subject of the the trade experience requests
	@RequestCount: The total number of TES forms to be requested; will not be greater than 60

	Called from PRBBScore insert trigger
**/
If Exists (Select name from sysobjects where name = 'usp_CreateTES' and type='P') 
	Drop Procedure dbo.usp_CreateTES
Go

CREATE PROCEDURE dbo.usp_CreateTES
	@CompanyId int,
	@RequestCount smallint = 60,
	@UserId int = -300
AS 
BEGIN
    DECLARE @NOW datetime
    SET @NOW = getDate()
    
    Declare @tblTESable table (ndx smallint identity, RelatedCompanyId int)

    -- Now get a list of "TES-able" companies ordered by the tier (1,2,3) value 
    -- and store it in the temporary table
    if (@RequestCount is not null and @RequestCount > 0)
    BEGIN TRY
        SET ROWCOUNT @RequestCount
        -- We will never request more than 60 reports; NEWID() randomizes the results
        insert into @tblTESable
          select RelatedCompanyId 
            from (
			        select distinct top 60 RelatedCompanyId from 
			        ( 
				       select RelatedCompanyId, prcr_Tier, UID=NEWID()
                         from vTESEligibleCompany
                        where SubjectCompanyId = @CompanyId
                    ) ATable group by prcr_Tier, UID,RelatedCompanyId
		         )BTABLE
		   order by RelatedCompanyId
        SET ROWCOUNT 0
        -- Walk through each result and create the appropriate PRTES and PRTesDetail recs
		DECLARE @TableNdx int, @TableCnt int
		DECLARE @RelatedCompanyId int, @PRTESNextId int, @PRTESDetailNextId int
		SELECT @TableCnt = Count(1) from @tblTESable
		SET @TableNdx = 1
		WHILE (@TableNdx <= @TableCnt)
		BEGIN
			Select @RelatedCompanyId = RelatedCompanyId from @tblTESable where ndx = @TableNdx
			
			-- Get next Ids
			EXEC usp_getNextId 'PRTES', @PRTESNextId Output
			EXEC usp_getNextId 'PRTESDetail', @PRTESDetailNextId Output
			
			-- Insert the records
			INSERT INTO PRTES( 
				prte_TESId, prte_ResponderCompanyId, prte_Date,
				prte_CreatedBy, prte_CreatedDate, prte_UpdatedBy, prte_UpdatedDate, prte_TimeStamp, prte_HowSent)
			VALUES (
				@PRTESNextId, @RelatedCompanyId, @Now,
				@UserId, @NOW, @UserId, @NOW, @NOW, 'M');

			INSERT INTO PRTESDetail( 
				prt2_TESDetailId, prt2_TESId, prt2_SubjectCompanyId,
				prt2_CreatedBy, prt2_CreatedDate, prt2_UpdatedBy, prt2_UpdatedDate, prt2_TimeStamp)
			VALUES (
				@PRTESDetailNextId, @PRTESNextId, @CompanyId,
				@UserId, @NOW, @UserId, @NOW, @NOW);
			
			SET @TableNdx = @TableNdx + 1
		END
    END TRY
    BEGIN CATCH
        SET ROWCOUNT 0
    END CATCH
END
GO

/**
Creates the TESFormBatch and TESForm records in preparation for
creating a data extract.
**/
If Exists (Select name from sysobjects where name = 'usp_GenerateTESFormBatch' and type='P') Drop Procedure dbo.usp_GenerateTESFormBatch
Go

CREATE PROCEDURE dbo.usp_GenerateTESFormBatch 
AS 


DECLARE @PRTESBatchID int, 
		@PRTESFormID int

DECLARE @FormType varchar(40), 
		@Language nvarchar(40),
        @Country nvarchar(40)

DECLARE @RemainingCount int, 
		@ResponderRowCount int, 
		@ResponderNdx int, 
		@ResponderCompanyID int, 
		@CRMUserID int,
		@prt2_TESDetailID int,
        @FormCount int,
        @PersonID int

DECLARE @Now datetime
SET @Now = GETDATE()

DECLARE @TESResponders table (
	ID int identity(1,1) PRIMARY KEY,
	ResponderCompanyID int,
	SubjectCount int
)

INSERT INTO @TESResponders (
	ResponderCompanyID,
	SubjectCount)
SELECT prte_ResponderCompanyID, 
	   COUNT(1)
  FROM PRTES 
	   INNER JOIN PRTESDetail on prte_TESID = prt2_TESID
 WHERE prt2_TESFormID IS NULL
   AND prte_HowSent = 'M' -- Mail Only
GROUP BY prte_ResponderCompanyID
ORDER BY prte_ResponderCompanyID;

SET @ResponderRowCount = @@ROWCOUNT

-- Create our batch record
IF @ResponderRowCount > 0 BEGIN
	EXEC usp_getNextId 'PRTESFormBatch', @PRTESBatchID Output

	INSERT INTO PRTESFormBatch (
		prtfb_TESFormBatchID,
		prtfb_CreatedBy,
		prtfb_CreatedDate,
		prtfb_UpdatedBy,
		prtfb_UpdatedDate,
        prtfb_TimeStamp)
	VALUES (
		@PRTESBatchID,
		@CRMUserID,
		@Now,
		@CRMUserID,
		@Now,
		@Now);
END

SET @ResponderNdx = 0

IF (@CRMUserID IS NULL) BEGIN
	SET @CRMUserID = -50
END

WHILE (@ResponderNdx < @ResponderRowCount) BEGIN
	SET @ResponderNdx = @ResponderNdx + 1

	-- Go get the next responder
	SELECT @ResponderCompanyID = ResponderCompanyID
      FROM @TESResponders 
     WHERE ID = @ResponderNdx;

	-- What language do they speak?
	SELECT @Language = comp_PRCommunicationLanguage,
           @Country = prcn_IATACode
      FROM Company 
           INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
     WHERE comp_CompanyID = @ResponderCompanyID;

	-- Set our initial count	
	SELECT @RemainingCount = COUNT(1)
 	  FROM PRTES 
	       INNER JOIN PRTESDetail on prte_TESID = prt2_TESID
	 WHERE prte_ResponderCompanyID = @ResponderCompanyID
       AND prte_HowSent = 'M' -- Mail Only
       AND prt2_TESFormID IS NULL;

	-- This loop will update up to 8 detail
	-- records at a time.
	WHILE (@RemainingCount > 0) BEGIN

		-- With the remaining subject count and language,
		-- determine what form this form is.
		IF (@RemainingCount = 1) BEGIN
			IF (@Language = 'E') BEGIN
				IF (@Country = 'US') BEGIN
					SET @FormType = 'SE'
				END ELSE BEGIN
					SET @FormType = 'SI'
				END 
			END ELSE BEGIN
				SET @FormType = 'SS'
			END
		END ELSE BEGIN
			IF (@Language = 'E') BEGIN
				IF (@Country = 'US') BEGIN
					SET @FormType = 'ME'
				END ELSE BEGIN
					SET @FormType = 'MI'
				END 
			END ELSE BEGIN
				SET @FormType = 'MS'
			END
		END


		-- Create our TESForm record
		EXEC usp_getNextId 'PRTESForm', @PRTESFormID Output
		INSERT INTO PRTESForm (
			prtf_TESFormID,
			prtf_CreatedBy,
			prtf_CreatedDate,
			prtf_UpdatedBy,
			prtf_UpdatedDate,
			prtf_TimeStamp,
			prtf_TESFormBatchID,
			prtf_CompanyID,
			prtf_SerialNumber,
			prtf_FormType)
		VALUES (
			@PRTESFormID,
			@CRMUserID,
			@Now,
			@CRMUserID,
			@Now,
			@Now,
			@PRTESBatchID,
			@ResponderCompanyID,
			@PRTESFormID,
			@FormType);

		-- Update up to 8 Detail Records
		UPDATE PRTESDetail
		   SET prt2_TESFormID = @PRTESFormID,
               prt2_UpdatedDate = @Now,
			   prt2_TimeStamp = @Now
         WHERE prt2_TESDetailID IN 
			(SELECT TOP 8 prt2_TESDetailID
			   FROM PRTES 
		            INNER JOIN PRTESDetail on prte_TESID = prt2_TESID
		      WHERE prte_ResponderCompanyID = @ResponderCompanyID
                AND prt2_TESFormID IS NULL
             ORDER BY prt2_SubjectCompanyID);

		-- Compute a new count
		SET @RemainingCount = @RemainingCount - @@ROWCOUNT
	END

/*
	-- Left in the code incase we want to enable this.  
	SELECT @PersonID = peli_PersonID
      FROM Person_Link
     WHERE peli_CompanyID = @ResponderCompanyID
       AND peli_PRRecipientRole LIKE '%,RCVTES,%'
       AND peli_PRStatus IN (1,2) 

	-- Now create the corresponding communication/interaction/task record
	EXEC usp_CreateTask     
		@StartDateTime = @Now,
		@CreatorUserId = @CRMUserID,
		@AssignedToUserType = 0,
		@TaskNotes = 'TES Sent',
		@RelatedCompanyId = @ResponderCompanyID,
        @RelatedPersonId= @PersonID,
        @Status = 'Complete',
		@Action = 'LetterOut',
        @PRCategory = 'R',
        @PRSubCategory = 'CI'
*/
END



SELECT @FormCount = COUNT(1)
  FROM PRTESForm
 WHERE prtf_TESFormBatchID = @PRTESBatchID;

SELECT @PRTESBatchID, @FormCount;
Go



/**
Processes the TES Response creating the PRTradeReport record as well as updating
the various TES records.
**/
If Exists (Select name from sysobjects where name = 'usp_ProcessTESResponse' and type='P') Drop Procedure dbo.usp_ProcessTESResponse
Go

CREATE PROCEDURE dbo.usp_ProcessTESResponse 
 @Serial_No Numeric(8,0),
 @Form_ID Numeric(10,0)	,
 @Time_Stamp varchar(30),
 @Subject_BBID numeric(6,0),
 @Dest_ID numeric(6,0),
 @Integrity_Ability char(1) = null,
 @Pay char(2) = null,
 @Deal_Regularly char(1) = null,
 @How_Does_Subject_Firm_Act char(2) = null,
 @Cash_Only numeric(1,0) = null,
 @Firm_Price numeric(1,0) = null,
 @On_Consignment numeric(1,0) = null,
 @Other_Terms numeric(1,0) = null,
 @Invoice_On_Ship_Day char(1) = null,
 @Payment_Trend char(1) = null,
 @How_Long_Dealt char(1) = null,
 @How_Recently_Dealt char(1) = null,
 @Product_Kickers char(1) = null,
 @Pack char(1) = null,
 @Encourage_Sales char(1) = null,
 @Collect_Remit char(1) = null,
 @Credit_Terms char(1) = null,
 @High_Credit char(1) = null,
 @Amount_Past_Due char(1) = null,
 @CSID varchar(30) = null,
 @Good_Equipment char(1) = null,
 @Claims_Handled_Properly char(1) = null,
 @Loads_Per_Year char(1) = null,
 @Pays_Freight char(1) = null,
 @Reliable_Carriers char(1) = null,
 @DontDeal char(1) = null,
 @OutOfBusiness char(1) = null,
 @Pay_Dispute char(1) = null,
 @Dealt1To6 numeric(1,0) = null,
 @Dealt7To12 numeric(1,0) = null,
 @DealtOver1Year numeric(1,0) = null,
 @DealtSeasonal numeric(1,0) = null
AS 


DECLARE @Flag bit
DECLARE @Count int, @TESID int, @TESFormID int, @TradeReportID int, @CRMUserID int, @CRMTaskUserID int
DECLARE @FormType varchar(40)

SET @CRMUserID = 1;

-- Do some quick data validation
SELECT @TESID = prte_TESID,
       @TESFormID = prtf_TESFormID,
       @FormType = prtf_FormType
  FROM PRTESForm
       INNER JOIN PRTESDetail ON prtf_TESFormID = prt2_TESFormID
       INNER JOIN PRTES on prt2_TESID = prte_TESID
 WHERE prtf_SerialNumber = @Serial_No
   AND prte_ResponderCompanyID = @Dest_ID
   AND prt2_SubjectCompanyID = @Subject_BBID;


-- If the TESID is null, then something ain't right.  
-- Now go figure out what it is and handle it.
IF @TESID IS NULL BEGIN
	
	DECLARE @ErrorMsg varchar(100)

	-- Does this Serial # exist?
	SET @Flag = 0

	SELECT @Flag = 1
	  FROM PRTESForm
	 WHERE prtf_SerialNumber = @Serial_No;

	IF @Flag = 0 BEGIN
		SET @ErrorMsg = 'Serial Number Not Found.'
	END


	-- Validate the Subject ID
	SET @Flag = 0

	SELECT @Flag = 1
	  FROM PRTESForm
		   INNER JOIN PRTESDetail ON prtf_TESFormID = prt2_TESFormID
     WHERE prtf_SerialNumber = @Serial_No
	   AND prt2_SubjectCompanyID = @Subject_BBID;

	IF @Flag = 0 BEGIN
		SET @ErrorMsg = 'Subject BBID Not Found for Serial Number.'
	END


	-- Validate the Responder ID
	SET @Flag = 0

	SELECT @Flag = 1
	  FROM PRTESForm
		   INNER JOIN PRTESDetail ON prtf_TESFormID = prt2_TESFormID
		   INNER JOIN PRTES on prt2_TESID = prte_TESID
     WHERE prtf_SerialNumber = @Serial_No
	   AND prte_ResponderCompanyID = @Dest_ID;

	IF @Flag = 0 BEGIN
		SET @ErrorMsg = 'Responder BBID Not Found for Serial Number.'
	END

	IF @CSID IS NOT NULL BEGIN
		SET @ErrorMsg = @ErrorMsg + '  Fax File Name = ' + @CSID + '.'
	END

	SET @CRMTaskUserID = 1;
	SELECT @CRMTaskUserID = capt_US
	  FROM CRM.dbo.custom_captions
	 WHERE capt_family = 'AssignmentUserID' 
	   AND capt_code = 'DataProcessor';

	DECLARE @TaskDate datetime
	SET @TaskDate = GETDATE()
	EXEC dbo.usp_CreateTask @TaskDate, 
						    @TaskDate, 
						    @CRMUserID, 
						    @CRMTaskUserID,
						    @ErrorMsg,
						    NULL,
						    NULL,
						    'Pending';


END ELSE BEGIN

	DECLARE @ComputedTerms varchar(40)
	IF (@Cash_Only = 1) BEGIN
		SET @ComputedTerms = ',1'
	END
	IF (@Firm_Price = 1) BEGIN
		SET @ComputedTerms = @ComputedTerms + ',2'
	END
	IF (@On_Consignment = 1) BEGIN
		SET @ComputedTerms = @ComputedTerms + ',3'
	END
	IF (@Other_Terms = 1) BEGIN
		SET @ComputedTerms = @ComputedTerms + ',4'
	END
	IF (LEN(@ComputedTerms) > 0) BEGIN
		SET @ComputedTerms = @ComputedTerms + ','
	END

	DECLARE @RelationshipLength varchar(40)
	IF (@Dealt1To6 = 1) BEGIN
		SET @RelationshipLength = 'B'
	END ELSE BEGIN
		IF (@Dealt7To12 = 1) BEGIN
			SET @RelationshipLength = 'C'
		END ELSE BEGIN
			IF (@DealtOver1Year = 1) BEGIN
				SET @RelationshipLength = 'D'
			END
		END
	END

	DECLARE @HowReceived varchar(40)
	IF (CHARINDEX('~', @CSID) = 1) BEGIN
		SET @HowReceived = 'FR'
	END ELSE BEGIN
		IF (CHARINDEX('B00', @CSID) = 1) BEGIN
			SET @HowReceived = 'FD'
		END ELSE BEGIN
			SET @HowReceived = 'M'
		END
	END

	EXEC usp_getNextId 'PRTradeReport', @TradeReportID Output

	INSERT INTO PRTradeReport (
		prtr_TradeReportID,
		prtr_CreatedBy,
		prtr_CreatedDate,
		prtr_UpdatedBy,
		prtr_UpdatedDate,
		prtr_TimeStamp,
		prtr_ResponderID,
		prtr_SubjectID,
		prtr_Date,
		prtr_NoTrade,
		prtr_OutOfBusiness,
		prtr_LastDealtDate,
		prtr_RelationshipLength,
		prtr_Regularity,
		prtr_Seasonal,
		prtr_RelationshipType,
		prtr_Terms,
		prtr_ProductKickers,
		prtr_CollectRemit,
		prtr_PromptHandling,
		prtr_ProperEquipment,
		prtr_Pack,
		prtr_DoubtfulAccounts,
		prtr_PayFreight,
		prtr_TimelyArrivals,
		prtr_IntegrityID,
		prtr_PayRatingID,
		prtr_HighCredit,
		prtr_CreditTerms,
		prtr_AmountPastDue,
		prtr_InvoiceOnDayShipped,
		prtr_DisputeInvolved,
		prtr_PaymentTrend,
		prtr_LoadsPerYear,
		prtr_TESFormID)
	VALUES (@TradeReportID,
			@CRMUserID,
			GetDate(),
			@CRMUserID,
			GetDate(),
			GetDate(),
			@Dest_ID, 
			@Subject_BBID,
			CAST(@Time_Stamp AS datetime),
			CASE @DontDeal WHEN 'X' THEN 'Y' ELSE NULL END,
			CASE @OutOfBusiness WHEN 'X' THEN 'Y' ELSE NULL END,
			@RelationshipLength,
			@How_Long_Dealt,
			@Deal_Regularly,
			CASE @DealtSeasonal WHEN 1 THEN 'Y' ELSE NULL END, 
			@How_Does_Subject_Firm_Act,
			@ComputedTerms,
			CASE @Product_Kickers WHEN 'Y' THEN 'Y' ELSE NULL END,
			CASE @Collect_Remit WHEN 'Y' THEN 'Y' ELSE NULL END,
			CASE @Claims_Handled_Properly WHEN 'Y' THEN 'Y' ELSE NULL END,
			CASE @Good_Equipment WHEN 'Y' THEN 'Y' ELSE NULL END,
			@Pack,
			CASE @Encourage_Sales WHEN 'Y' THEN 'Y' ELSE NULL END,
			CASE @Pays_Freight WHEN 'Y' THEN 'Y' ELSE NULL END,
			CASE @Reliable_Carriers WHEN 'Y' THEN 'Y' ELSE NULL END,
			CASE @Integrity_Ability 
				WHEN '1' THEN '1'
				WHEN '2' THEN '2'
				WHEN '3' THEN '5'
				WHEN '4' THEN '6'
				ELSE NULL END,
			CASE @Pay 
				WHEN 'F' THEN '2'
				WHEN 'E' THEN '3'
				WHEN 'D' THEN '4'
				WHEN 'C' THEN '5'
				WHEN 'B' THEN '6'
				WHEN 'AB' THEN '7'
				WHEN 'A' THEN '8'
				WHEN 'AA' THEN '9'
				ELSE NULL END,
			@High_Credit,
			@Credit_Terms,
			@Amount_Past_Due,
			CASE @Invoice_On_Ship_Day WHEN 'Y' THEN 'Y' ELSE NULL END,
			CASE @Pay_Dispute WHEN 'Y' THEN 'Y' ELSE NULL END,
			@Payment_Trend,
			@Loads_Per_Year,
			@TESFormID);

	UPDATE PRTESForm
       SET prtf_UpdatedBy = @CRMUserID,
           prtf_UpdatedDate = GETDATE(),
           prtf_Timestamp =  GETDATE(),
		   prtf_ReceivedDateTime = CAST(@Time_Stamp AS datetime),
           prtf_ReceivedMethod = @HowReceived,
           prtf_FaxFileName = @CSID,
           prtf_TeleformId = @Form_ID
     WHERE prtf_TESFormID = @TESFormID;

	UPDATE PRTESDetail
       SET prt2_UpdatedBy = @CRMUserID,
           prt2_UpdatedDate = GETDATE(),
           prt2_Timestamp =  GETDATE(),
		   prt2_Received = 'Y'
     WHERE prt2_TESFormID = @TESFormID
       and prt2_SubjectCompanyID = @Subject_BBID;
END
Go



/**
Adds a PRTradeReport record from the PRCo web site
**/
If Exists (Select name from sysobjects where name = 'usp_AddOnlineTradeReport' and type='P') Drop Procedure dbo.usp_AddOnlineTradeReport
Go

CREATE PROCEDURE dbo.usp_AddOnlineTradeReport
 @Responder_BBID numeric(6,0),
 @Subject_BBID numeric(6,0),
 @HowLong char(1) = null,
 @HowRecently char(1) = null,
 @Seasonal char(1) = null,
 @DealRegularly char(1) = null,
 @DoNotDeal char(1) = null,
 @Integrity char(1) = null,
 @Pay char(2) = null,
 @HighCredit char(1) = null, 
 @CreditTerms char(1) = null,
 @PastDue char(1) = null,
 @InvoiceOnSameDay char(1) = null,
 @BeyondTerms char(1) = null,  -- Dispute
 @OverallPay char(1) = null,  -- Trend
 @SubjectActs char(2) = null,
 @TermsCOD char(1) = null,
 @TermsFirm char(1) = null,
 @TermsCon char(1) = null,
 @TermsFOB char(1) = null,
 @Loads char(1) = null,
 @Kicks char(1) = null,
 @CollectRemit char(1) = null,
 @Doubtful char(1) = null, -- Encourage Sales
 @Prompt char(1) = null,
 @PayFreight char(1) = null,
 @Secures char(1) = null, -- Good Equipment
 @Timely char(1) = null,
 @Pack char(1) = null,
 @Summary varchar(250) = null
AS 

	DECLARE @TradeReportID int, @CRMUserID int, @AssignedToUserID int
	SET @CRMUserID = dbo.ufn_GetSystemUserId(1);
	SET @AssignedToUserID = dbo.ufn_GetPRCoSpecialistUserId(@Subject_BBID, 0);

	DECLARE @ComputedTerms varchar(40)
	IF (@TermsCOD = 1) BEGIN
		SET @ComputedTerms = ',1'
	END
	IF (@TermsFirm = 1) BEGIN
		SET @ComputedTerms = @ComputedTerms + ',2'
	END
	IF (@TermsCon = 1) BEGIN
		SET @ComputedTerms = @ComputedTerms + ',3'
	END
	IF (@TermsFOB = 1) BEGIN
		SET @ComputedTerms = @ComputedTerms + ',4'
	END
	IF (LEN(@ComputedTerms) > 0) BEGIN
		SET @ComputedTerms = @ComputedTerms + ','
	END

	EXEC usp_getNextId 'PRTradeReport', @TradeReportID Output

	INSERT INTO PRTradeReport (
		prtr_TradeReportID,
		prtr_CreatedBy,
		prtr_CreatedDate,
		prtr_UpdatedBy,
		prtr_UpdatedDate,
		prtr_TimeStamp,
		prtr_ResponderID,
		prtr_SubjectID,
		prtr_Date,
		prtr_NoTrade,
		prtr_LastDealtDate,
		prtr_RelationshipLength,
		prtr_Regularity,
		prtr_Seasonal,
		prtr_RelationshipType,
		prtr_Terms,
		prtr_ProductKickers,
		prtr_CollectRemit,
		prtr_PromptHandling,
		prtr_ProperEquipment,
		prtr_Pack,
		prtr_DoubtfulAccounts,
		prtr_PayFreight,
		prtr_TimelyArrivals,
		prtr_IntegrityID,
		prtr_PayRatingID,
		prtr_HighCredit,
		prtr_CreditTerms,
		prtr_AmountPastDue,
		prtr_InvoiceOnDayShipped,
		prtr_DisputeInvolved,
		prtr_PaymentTrend,
		prtr_LoadsPerYear,
        prtr_Comments,
        prtr_CommentsFlag)
	VALUES (@TradeReportID,
			@CRMUserID,
			GetDate(),
			@CRMUserID,
			GetDate(),
			GetDate(),
			@Responder_BBID, 
			@Subject_BBID,
			GetDate(),
			CASE @DoNotDeal WHEN '1' THEN 'Y' ELSE NULL END,
			@HowLong,
			@HowRecently,
			CASE @DealRegularly WHEN 'Y' THEN 'Y' ELSE NULL END, 
			CASE @Seasonal WHEN '1' THEN 'Y' ELSE NULL END, 
			@SubjectActs,
			@ComputedTerms,
			CASE @Kicks WHEN 'Y' THEN 'Y' ELSE NULL END,
			CASE @CollectRemit WHEN 'Y' THEN 'Y' ELSE NULL END,
			CASE @Prompt WHEN 'Y' THEN 'Y' ELSE NULL END,
			CASE @Secures WHEN 'Y' THEN 'Y' ELSE NULL END,
			@Pack,
			CASE @Doubtful WHEN 'Y' THEN 'Y' ELSE NULL END,
			CASE @PayFreight WHEN 'Y' THEN 'Y' ELSE NULL END,
			CASE @Timely WHEN 'Y' THEN 'Y' ELSE NULL END,
			CASE @Integrity 
				WHEN '1' THEN '1'
				WHEN '2' THEN '2'
				WHEN '3' THEN '5'
				WHEN '4' THEN '6'
				ELSE NULL END,
			CASE @Pay 
				WHEN 'F' THEN '2'
				WHEN 'E' THEN '3'
				WHEN 'D' THEN '4'
				WHEN 'C' THEN '5'
				WHEN 'B' THEN '6'
				WHEN 'AB' THEN '7'
				WHEN 'A' THEN '8'
				WHEN 'AA' THEN '9'
				ELSE NULL END,
			@HighCredit,
			@CreditTerms,
			@PastDue,
			CASE @InvoiceOnSameDay WHEN 'Y' THEN 'Y' ELSE NULL END,
			CASE @BeyondTerms WHEN 'Y' THEN 'Y' ELSE NULL END,
			@OverallPay,
			@Loads,
			@Summary,
		    CASE WHEN @Summary IS NOT NULL THEN 'Y' ELSE NULL END);

	IF @Summary IS NOT NULL BEGIN

		DECLARE @StartDate datetime
		SET @StartDate = GETDATE()

		DECLARE @TaskMsg varchar(5000), @Name varchar(1000), @ListingLocation varchar(1000)
		SET @TaskMsg = 'Online TES Comments'

		-- Go get info on our subject company
		SELECT @Name = comp_PRCorrTradeStyle,
               @ListingLocation = CityStateCountryShort
          FROM Company
               INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
         WHERE comp_CompanyID = @Subject_BBID;

		SET @TaskMsg = @TaskMsg + '<br>Subject Firm: BB# ' + CAST(@Subject_BBID AS varchar(10)) + ' ' + @Name + ', ' + @ListingLocation

		-- Go get info on our responder company
		SELECT @Name = comp_PRCorrTradeStyle,
               @ListingLocation = CityStateCountryShort
          FROM Company
               INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
         WHERE comp_CompanyID = @Responder_BBID;

		SET @TaskMsg = @TaskMsg + '<br>Responder: BB# ' + CAST(@Responder_BBID AS varchar(10)) + ' ' + @Name + ', ' + @ListingLocation

		SET @TaskMsg = @TaskMsg + '<br>' + @Summary
		EXEC CRM.dbo.usp_CreateTask @StartDate, 
							@StartDate, 
							@CRMUserID, 
							@AssignedToUserID,
							@TaskMsg,
							@Subject_BBID,
					 		NULL,
							'Pending';
	END

	-- Implement fuzzy logic to handle matching online submissions
	-- with previously sent TES forms.
	DECLARE @TESID int, @TESFormID int

	-- Do some quick data validation
	SELECT @TESID = prte_TESID,
		   @TESFormID = prtf_TESFormID
	  FROM PRTESForm
		   INNER JOIN PRTESDetail ON prtf_TESFormID = prt2_TESFormID
		   INNER JOIN PRTES on prt2_TESID = prte_TESID
	 WHERE prte_ResponderCompanyID = @Responder_BBID
	   AND prt2_SubjectCompanyID = @Subject_BBID
       AND prt2_Received IS NULL
       AND DATEDIFF(day, GETDATE(), prtf_SentDateTime) <= 30;

	IF (@TESID IS NOT NULL) BEGIN
		UPDATE PRTESForm
		   SET prtf_UpdatedBy = @CRMUserID,
			   prtf_UpdatedDate = GETDATE(),
			   prtf_Timestamp =  GETDATE(),
			   prtf_ReceivedDateTime = GETDATE(),
			   prtf_ReceivedMethod = 'OL'
		 WHERE prtf_TESFormID = @TESFormID;

		UPDATE PRTESDetail
		   SET prt2_UpdatedBy = @CRMUserID,
			   prt2_UpdatedDate = GETDATE(),
			   prt2_Timestamp =  GETDATE(),
			   prt2_Received = 'Y'
		 WHERE prt2_TESFormID = @TESFormID
		   and prt2_SubjectCompanyID = @Subject_BBID;

		UPDATE PRTradeReport
		   SET prtr_UpdatedBy = @CRMUserID,
			   prtr_UpdatedDate = GETDATE(),
			   prtr_Timestamp =  GETDATE(),
			   prtr_TESFormID = @TESFormID
		 WHERE prtr_TradeReportID = @TradeReportID;
	END
GO


/**
Sets required report count in all companies' current BB Score records
**/
If Exists (Select name from sysobjects where name = 'usp_SetAllRequiredTESCounts' and type='P') Drop Procedure     usp_SetAllRequiredTESCounts
Go

CREATE PROCEDURE [dbo].[usp_SetAllRequiredTESCounts]
AS

DECLARE temp_cur CURSOR LOCAL FAST_FORWARD FOR 
SELECT DISTINCT prbs_CompanyID
FROM PRBBScore
WHERE prbs_Current = 'Y'
FOR READ ONLY;

DECLARE @prbs_CompanyId int

OPEN temp_cur
FETCH NEXT FROM temp_cur INTO @prbs_CompanyId

WHILE @@Fetch_Status=0
BEGIN
	EXEC usp_SetRequiredTESRequestCount @prbs_CompanyId
	FETCH NEXT FROM temp_cur INTO @prbs_CompanyId
END

CLOSE temp_cur
DEALLOCATE temp_cur

GO


/**
Sets required report count in a specified company's current BB Score record
**/
If Exists (Select name from sysobjects where name = 'usp_SetRequiredTESRequestCount' and type='P') Drop Procedure   usp_SetRequiredTESRequestCount
Go

CREATE PROCEDURE [dbo].[usp_SetRequiredTESRequestCount]
  @comp_CompanyId int
AS
BEGIN

    DECLARE @MinPerQuarter int
    DECLARE @RequiredReportCount int
	DECLARE @prbs_BBScoreId int
	DECLARE @prbs_UpdatedBy int
    DECLARE @prbs_p975Surveys int
    DECLARE @prbs_Date datetime

    SELECT  @prbs_BBScoreId = prbs_BBScoreId,
	 @prbs_Date = prbs_Date,
	 @prbs_p975Surveys = prbs_p975Surveys,
         @MinPerQuarter = CASE
          WHEN CAST (prbs_p975Surveys AS INT)%4 = 0 THEN prbs_p975Surveys / 4
          ELSE ROUND(prbs_p975Surveys / 4+.5, 0)
         END
     FROM PRBBScore
     WHERE prbs_CompanyId = @comp_CompanyId AND prbs_Current = 'Y'

    -- use the helper function to get the required number of tes requests to send
    Exec @RequiredReportCount = ufn_GetRequiredTESRequestCount 
                                    @comp_CompanyId,
                                    @prbs_Date,
                                    @prbs_p975Surveys,
                                    @MinPerQuarter

    UPDATE PRBBScore 
    SET prbs_RequiredReportCount = @RequiredReportCount
    WHERE prbs_BBScoreId = @prbs_BBScoreId 
    
    RETURN @RequiredReportCount
    
END

GO

/**
Creates a BB Score exception if certain conditions are met in a specified company's current BB Score record
**/
If Exists (Select name from sysobjects where name = 'usp_DetermineBBScoreException' and type='P') 
	Drop Procedure usp_DetermineBBScoreException
Go

CREATE PROCEDURE [dbo].[usp_DetermineBBScoreException]
  @comp_CompanyId int,
  @prbs_BBScoreId int = NULL,
  @prbs_BBScore float = NULL,
  @prbs_UpdatedBy int = NULL
AS
BEGIN

	IF (@prbs_BBScoreId IS NULL)
	BEGIN
		SELECT @prbs_BBScoreId = prbs_BBScoreId, 
				@prbs_BBScore = prbs_BBScore,
				@prbs_UpdatedBy = prbs_UpdatedBy
		FROM PRBBScore
		WHERE prbs_CompanyId = @comp_CompanyId AND prbs_Current = 'Y'
	END
	
	DECLARE @prin_Name varchar(10)
	SELECT @prin_Name = prin_Name 
	FROM PRRating
	LEFT OUTER JOIN PRIntegrityRating ON prra_IntegrityId = prin_IntegrityRatingId
	WHERE prra_Current = 'Y' and prra_CompanyId = @comp_CompanyId

	IF (@prin_Name IS NOT NULL AND @prin_Name IN ('XXXX', 'XXX', 'XXX148') )
	BEGIN
		IF (@prbs_BBScore < 600)
			EXEC usp_CreateException 'BBScore', @prbs_BBScoreId, @prbs_UpdatedBy
	END

END

GO



/**
Returns the PersonIDs and Companiesthat have AUS changes for the specified
time frame.
**/
If Exists (Select name from sysobjects where name = 'usp_GetAUSReportItems' and type='P') Drop Procedure usp_GetAUSReportItems
Go

CREATE PROCEDURE [dbo].[usp_GetAUSReportItems]
  @StartDate datetime,
  @EndDate datetime
AS

SELECT prau_PersonID, prau_CompanyID, SUM([Count]) AS [Count]
  FROM (SELECT prau_PersonID, prau_CompanyID, COUNT(1) AS [Count]
          FROM PRAUS
               INNER JOIN PRCreditSheet on prau_MonitoredCompanyID = prcs_CompanyID
               INNER JOIN Person_Link on prau_PersonID = peli_PersonID AND prau_CompanyID = peli_CompanyID
         WHERE prcs_PublishableDate BETWEEN @StartDate AND @EndDate
           AND prcs_Status = 'P' -- Publishable
           AND ISNULL(prcs_KeyFlag, 'N') = CASE WHEN peli_PRAUSChangePreference = '1' THEN 'Y' ELSE ISNULL(prcs_KeyFlag, 'N')  END
      GROUP BY prau_PersonID, prau_CompanyID
		UNION
        SELECT prau_PersonID, prau_CompanyID, COUNT(1) AS [Count]
          FROM PRAUS
               INNER JOIN PRFinancial on prau_MonitoredCompanyID = prfs_CompanyID
         WHERE prfs_CreatedDate BETWEEN @StartDate AND @EndDate
      GROUP BY prau_PersonID, prau_CompanyID
		UNION
        SELECT prau_PersonID, prau_CompanyID, COUNT(1) AS [Count]
          FROM PRAUS
               INNER JOIN PRBusinessReportRequest ON prau_PersonID = prbr_RequestingPersonID and prau_CompanyID = prbr_RequestingCompanyID -- This means they have an AUS list
               INNER JOIN PRCreditSheet on prbr_RequestedCompanyID = prcs_CompanyID
		       INNER JOIN Person_Link on prau_PersonID = peli_PersonID AND prau_CompanyID = peli_CompanyID
         WHERE prcs_PublishableDate BETWEEN @StartDate AND @EndDate
           AND prcs_Status = 'P' -- Publishable
           AND prbr_CreatedDate > DATEADD(month, -6, GETDATE())
           AND ISNULL(prcs_KeyFlag, 'N') = CASE WHEN peli_PRAUSChangePreference = '1' THEN 'Y' ELSE ISNULL(prcs_KeyFlag, 'N')  END
      GROUP BY prau_PersonID, prau_CompanyID
		UNION
        SELECT prau_PersonID, prau_CompanyID, COUNT(1) AS [Count]
          FROM PRAUS
               INNER JOIN PRBusinessReportRequest ON prau_PersonID = prbr_RequestingPersonID and prau_CompanyID = prbr_RequestingCompanyID -- This means they have an AUS list
			   INNER JOIN PRFinancial on prbr_RequestedCompanyID = prfs_CompanyID               
         WHERE prfs_CreatedDate BETWEEN @StartDate AND @EndDate
           AND prbr_CreatedDate > DATEADD(month, -6, GETDATE())
      GROUP BY prau_PersonID, prau_CompanyID) T1
 INNER JOIN PRService ON T1.prau_CompanyID = prse_CompanyID
 WHERE prse_Primary = 'Y'
GROUP BY prau_PersonID, prau_CompanyID
ORDER BY prau_PersonID, prau_CompanyID;

Go



/**
Returns the PersonIDs and Companies that have AUS changes for the specified
time frame.
**/
If Exists (Select name from sysobjects where name = 'usp_GetAUSReportItems' and type='P') Drop Procedure usp_GetAUSReportItems
Go

CREATE PROCEDURE [dbo].[usp_GetAUSReportItems]
  @StartDate datetime,
  @EndDate datetime
AS

SELECT prau_PersonID, prau_CompanyID, SUM([Count]) AS [Count]
  FROM (SELECT prau_PersonID, prau_CompanyID, COUNT(1) AS [Count]
          FROM PRAUS
               INNER JOIN PRCreditSheet on prau_MonitoredCompanyID = prcs_CompanyID
               INNER JOIN Person_Link on prau_PersonID = peli_PersonID AND prau_CompanyID = peli_CompanyID AND peli_PRAUSChangePreference IN ('1','2')
         WHERE prcs_PublishableDate BETWEEN @StartDate AND @EndDate
           AND prcs_Status = 'P' -- Publishable
           AND ISNULL(prcs_KeyFlag, 'N') = CASE WHEN peli_PRAUSChangePreference = '1' THEN 'Y' ELSE ISNULL(prcs_KeyFlag, 'N')  END
      GROUP BY prau_PersonID, prau_CompanyID
		UNION
        SELECT prau_PersonID, prau_CompanyID, COUNT(1) AS [Count]
          FROM PRAUS
               INNER JOIN PRFinancial on prau_MonitoredCompanyID = prfs_CompanyID
               INNER JOIN Person_Link on prau_PersonID = peli_PersonID AND prau_CompanyID = peli_CompanyID AND peli_PRAUSChangePreference IN ('1','2')
         WHERE prfs_CreatedDate BETWEEN @StartDate AND @EndDate
      GROUP BY prau_PersonID, prau_CompanyID
		UNION
        SELECT prau_PersonID, prau_CompanyID, COUNT(1) AS [Count]
          FROM PRAUS
               INNER JOIN PRBusinessReportRequest ON prau_PersonID = prbr_RequestingPersonID and prau_CompanyID = prbr_RequestingCompanyID -- This means they have an AUS list
               INNER JOIN PRCreditSheet on prbr_RequestedCompanyID = prcs_CompanyID
		       INNER JOIN Person_Link on prau_PersonID = peli_PersonID AND prau_CompanyID = peli_CompanyID AND peli_PRAUSChangePreference IN ('1','2')
         WHERE prcs_PublishableDate BETWEEN @StartDate AND @EndDate
           AND prcs_Status = 'P' -- Publishable
           AND prbr_CreatedDate > DATEADD(month, -6, GETDATE())
           AND ISNULL(prcs_KeyFlag, 'N') = CASE WHEN peli_PRAUSChangePreference = '1' THEN 'Y' ELSE ISNULL(prcs_KeyFlag, 'N')  END
      GROUP BY prau_PersonID, prau_CompanyID
		UNION
        SELECT prau_PersonID, prau_CompanyID, COUNT(1) AS [Count]
          FROM PRAUS
               INNER JOIN PRBusinessReportRequest ON prau_PersonID = prbr_RequestingPersonID and prau_CompanyID = prbr_RequestingCompanyID -- This means they have an AUS list
			   INNER JOIN PRFinancial on prbr_RequestedCompanyID = prfs_CompanyID               
               INNER JOIN Person_Link on prau_PersonID = peli_PersonID AND prau_CompanyID = peli_CompanyID AND peli_PRAUSChangePreference IN ('1','2')
         WHERE prfs_CreatedDate BETWEEN @StartDate AND @EndDate
           AND prbr_CreatedDate > DATEADD(month, -6, GETDATE())
      GROUP BY prau_PersonID, prau_CompanyID) T1
 INNER JOIN PRService ON T1.prau_CompanyID = prse_CompanyID
 WHERE prse_Primary = 'Y'
GROUP BY prau_PersonID, prau_CompanyID
ORDER BY prau_PersonID, prau_CompanyID;

Go


/**
Returns the header information for the AUS Report
**/
If Exists (Select name from sysobjects where name = 'usp_GetAUSReportHeader' and type='P') Drop Procedure usp_GetAUSReportHeader
Go

CREATE PROCEDURE [dbo].[usp_GetAUSReportHeader]
  @PersonID int,
  @CompanyID int
AS

SELECT dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_MiddleName, pers_PRNickName1, pers_Suffix) As FullName, comp_PRCorrTradestyle, peli_PRAUSChangePreference, a.capt_us AS ReceiveMethod, b.capt_us AS ChangePreference, peli_PRAUSReceiveMethod, CASE peli_PRAUSReceiveMethod WHEN '1' THEN dbo.ufn_GetPersonDefaultFax(pers_PersonID) WHEN '2' THEN dbo.ufn_GetPersonDefaultEMail(pers_PersonID) ELSE NULL END AS Destination FROM Person_Link
       INNER JOIN Person ON peli_PersonID = pers_PersonID
       INNER JOIN Company ON peli_CompanyID = comp_CompanyID
       LEFT OUTER JOIN custom_captions a ON peli_PRAUSReceiveMethod = a.capt_code and a.capt_family = 'peli_PRAUSReceiveMethod'
       LEFT OUTER JOIN custom_captions b ON peli_PRAUSChangePreference = b.capt_code and b.capt_family = 'peli_PRAUSChangePreference'
 WHERE peli_PersonID = @PersonID
   AND peli_CompanyID = @CompanyID
   AND peli_PRStatus='1';

Go


/**
Returns the data for the BBScore Report
**/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_BBScoreReport]'))
drop Procedure [dbo].[usp_BBScoreReport]
GO

CREATE Procedure dbo.usp_BBScoreReport
    @CompanyID int,
    @ReportDate datetime = NULL,
    @ConfidenceThreshold decimal(24,6) = 5
AS
BEGIN

	IF (@ReportDate IS NULL) BEGIN
		SET @ReportDate = GETDATE()
	END

	DECLARE @Start1 datetime, @End1 datetime
	DECLARE @Start2 datetime, @End2 datetime
	DECLARE @Start3 datetime, @End3 datetime

	DECLARE @ReportTable table (
		BBID int,
		CompanyName varchar(104),
		Location varchar(150),
		MonthMinus2 int,
		MonthMinus1 int,
		CurrentMonth int,
		MonthMinus2BBSScore numeric(24,6),
		MonthMinus1BBSScore numeric(24,6),
		CurrentMonthBBSScore numeric(24,6),
		Change numeric(24, 6),
		CurrentRating varchar(200),
		RatingDate	 datetime,
		PreviousRating varchar(200),
		ReceiverBBID int,
		ReceiverBBScore numeric(24,6),
        comp_PRInvestigationMethodGroup varchar(40),
		ConfidenceScore numeric(24,6)
	)


	INSERT INTO @ReportTable (BBID, CompanyName, Location, CurrentRating, RatingDate, PreviousRating, comp_PRInvestigationMethodGroup, ReceiverBBID)
	SELECT comp_CompanyID, comp_PRCorrTradestyle, CityStateCountryShort, prra_RatingLine, prra_Date, dbo.ufn_GetPreviousRating(comp_CompanyID), comp_PRInvestigationMethodGroup, @CompanyID
	  FROM Company
		   INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
		   LEFT OUTER JOIN vPRCompanyRating on comp_CompanyID = prra_CompanyID AND prra_Current='Y'
	 WHERE comp_CompanyID IN (SELECT prcr_RightCompanyID 
								FROM PRCompanyRelationship 
							   WHERE prcr_Deleted IS NULL 
                                 AND prcr_Active = 'Y'
								 AND prcr_Type in ('09','10','11','12','13','14','15','16')
								 AND prcr_LeftCompanyID = @CompanyID );
	
	-- Get our Receiver's BBScore
	UPDATE @ReportTable
       SET ReceiverBBScore =prbs_BBScore
      FROM PRBBScore
     WHERE prbs_Current = 'Y'
       AND prbs_CompanyID = @CompanyID;

	-- Get our current month score
	SET @Start1 =  DATEADD(mm, DATEDIFF(mm,0, @ReportDate), 0)
	SET @End1 = DATEADD(month, 1, @Start1)

	UPDATE @ReportTable
	   SET CurrentMonthBBSScore = prbs_BBScore,
		   Change = prbs_Deviation,
           ConfidenceScore = prbs_ConfidenceScore,
		   CurrentMonth = Month(@Start1)
	  FROM PRBBScore
		   INNER JOIN @ReportTable ON prbs_CompanyID = BBID
	 WHERE prbs_Date BETWEEN @Start1 AND @End1;
	        

	-- Get our Month - 1 Score
	SET @End2 =  @Start1
	SET @Start2 = DATEADD(month, -1, @Start1)


	UPDATE @ReportTable
	   SET MonthMinus1BBSScore = prbs_BBScore,
		   MonthMinus1 = Month(@Start2)
	  FROM PRBBScore
		   INNER JOIN @ReportTable ON prbs_CompanyID = BBID
	 WHERE prbs_Date BETWEEN @Start2 AND @End2;

	-- Get our Month - 2 Score
	SET @End3 =  @Start2
	SET @Start3 = DATEADD(month, -1, @Start2)

	UPDATE @ReportTable
	   SET MonthMinus2BBSScore = prbs_BBScore,
		   MonthMinus2 = Month(@Start3)
	  FROM PRBBScore
		   INNER JOIN @ReportTable ON prbs_CompanyID = BBID
	 WHERE prbs_Date BETWEEN @Start3 AND @End3;

	-- NULL out our values if any of 
    -- the below conditions are true
	UPDATE @ReportTable
       SET CurrentMonthBBSScore = NULL,
           MonthMinus1BBSScore = NULL,
           MonthMinus2BBSScore = NULL,
           Change = NULL
     WHERE comp_PRInvestigationMethodGroup = 'B'
        OR CurrentMonthBBSScore IS NULL
        OR ConfidenceScore <= @ConfidenceThreshold;


	SELECT BBID,
		   CompanyName,
		   Location,
		   MonthMinus2,
		   MonthMinus1,
		   CurrentMonth,
		   MonthMinus2BBSScore,
		   MonthMinus1BBSScore,
		   CurrentMonthBBSScore,
		   Change,
		   CurrentRating,
		   RatingDate,
		   PreviousRating,
		   ReceiverBBID,
		   ReceiverBBScore,
		   ConfidenceScore
      FROM @ReportTable 
  ORDER BY CurrentMonthBBSScore DESC,
           CompanyName;

END
GO


/**
Ensures that only four (4) Financial statements are marked as published.  Keeps 
the most recent four by statement date.
**/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_ResetFinancialPublishFlag]'))
drop Procedure [dbo].[usp_ResetFinancialPublishFlag]
GO

CREATE Procedure dbo.usp_ResetFinancialPublishFlag(
    @prfs_FinancialID int,
	@CompanyID int, 
	@CurrentUserID int
)  
AS  
BEGIN 

UPDATE PRFinancial
   SET prfs_Publish = NULL,
       prfs_UpdatedDate = GETDATE(),
	   prfs_UpdatedBy = @CurrentUserID,
       prfs_Timestamp = GETDATE()
 WHERE prfs_Publish = 'Y' 
   AND prfs_CompanyID = @CompanyID
   AND prfs_FinancialID <> @prfs_FinancialID
   AND prfs_FinancialID NOT IN (SELECT TOP 3 prfs_FinancialID 
								  FROM PRFinancial 
								 WHERE prfs_CompanyID=@CompanyID
								   AND prfs_Publish='Y'
								ORDER BY prfs_StatementDate desc);

END
Go




/**
Generates the TESForm records for pending TES requests that need to 
be faxed out.
**/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_GenerateTESFormForFax]'))
drop Procedure [dbo].[usp_GenerateTESFormForFax]
GO

CREATE Procedure dbo.usp_GenerateTESFormForFax
AS  
BEGIN 

	DECLARE @FormType varchar(40), 
			@Language nvarchar(40),
			@Country nvarchar(40)

	DECLARE @ResponderNdx int, 
			@ResponderCount int,
			@CRMUserID int,
			@TESDetailID int,
			@ResponderCompanyID int,
			@PRTESFormID int

	DECLARE @TESResponders table (
		ID int identity(1,1) PRIMARY KEY,
		TESDetailID int,
		ResponderCompanyID int
	)

	-- There should be only one responder and
	-- subject for faxed TES forms.
	INSERT INTO @TESResponders (TESDetailID, ResponderCompanyID)
	SELECT prt2_TESDetailID, prte_ResponderCompanyID
	  FROM PRTES 
		   INNER JOIN PRTESDetail on prte_TESID = prt2_TESID
	 WHERE prt2_TESFormID IS NULL
	   AND prte_HowSent = 'F' -- Fax Only

	SET @ResponderCount = @@ROWCOUNT

	SET @ResponderNdx = 0
	SET @CRMUserID = -400

	WHILE (@ResponderNdx < @ResponderCount) BEGIN
		SET @ResponderNdx = @ResponderNdx + 1

		-- Go get the next responder
		SELECT @TESDetailID = TESDetailID,
			   @ResponderCompanyID = ResponderCompanyID
		  FROM @TESResponders 
		 WHERE ID = @ResponderNdx;

		-- What language do they speak?
		SELECT @Language = comp_PRCommunicationLanguage,
			   @Country = prcn_IATACode
		  FROM Company 
			   INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
		 WHERE comp_CompanyID = @ResponderCompanyID;

		-- We know it's a single subject form
		IF (@Language = 'E') BEGIN
			IF (@Country = 'US') BEGIN
				SET @FormType = 'SE'
			END ELSE BEGIN
				SET @FormType = 'SI'
			END 
		END ELSE BEGIN
			SET @FormType = 'SS'
		END

		-- Create our TESForm record
		EXEC usp_getNextId 'PRTESForm', @PRTESFormID Output
		INSERT INTO PRTESForm (
				prtf_TESFormID,
				prtf_CreatedBy,
				prtf_CreatedDate,
				prtf_UpdatedBy,
				prtf_UpdatedDate,
				prtf_TimeStamp,
				prtf_CompanyID,
				prtf_SerialNumber,
				prtf_FormType,
				prtf_SentMethod)
			VALUES (
				@PRTESFormID,
				@CRMUserID,
				GetDate(),
				@CRMUserID,
				GetDate(),
				GetDate(),
				@ResponderCompanyID,
				@PRTESFormID,
				@FormType,
				'F');

		-- Update up the Detail Record
		UPDATE PRTESDetail
		   SET prt2_TESFormID = @PRTESFormID,
			   prt2_UpdatedBy = @CRMUserID,
			   prt2_UpdatedDate = GETDATE(),
			   prt2_TimeStamp = GETDATE()
		 WHERE prt2_TESDetailID = @TESDetailID
	END
END
Go






/* ************************************************************
	This section contains procs specifically supporting workflows
 * ************************************************************/


/*
 * This procedure is called from the Workflow Update trigger when the status is changed from 
 * qualified to FileOpen.
 *
 */
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_WA_File_OpenFile]'))
	drop Procedure [dbo].[usp_WA_File_OpenFile]
GO

CREATE Procedure dbo.usp_WA_File_OpenFile
    @FileId int
AS  
BEGIN 
    SET NOCOUNT ON
    Declare @Err int
    SET @Err = 0
    Declare @Now datetime
    SET @Now = getDate()
    DECLARE @Msg varchar (2000)
    
    Declare @prfi_Type varchar(40)
    Declare @prfi_UpdatedBy int, @AssignedToUserId int
    Declare @prfi_Company1Id int, @prfi_Company2Id int
    Declare @CreditorName varchar(500), @DebtorName varchar(500)

    select  @prfi_Type = prfi_Type, 
            @prfi_Company1Id = prfi_Company1Id, 
            @prfi_Company2Id = prfi_Company2Id, 
            @prfi_UpdatedBy = prfi_UpdatedBy 
      from PRFile
     WHERE prfi_FileId = @FileId

	select @CreditorName = comp_name
	  from company
	 where comp_companyid = @prfi_Company1Id
	select @DebtorName = comp_name
	  from company
	 where comp_companyid = @prfi_Company2Id
	
	-- Fax A-1 letter to Debtor with Creditor cc'd
	
	-- Assign to the user specified for CollectionsFile_OpenFile
	SELECT @AssignedToUserId = dbo.ufn_GetWorkflowUserId('File_OpenFile')
	Update PRFile set prfi_AssignedUserId = @AssignedToUserId where prfi_FileId = @FileId 
	-- create a task for user to call Creditor in one week
	DECLARE @CreditorNumber varchar(255)
	SELECT @CreditorNumber = dbo.ufn_GetCompanyPhone (@prfi_Company1Id, 'Y', null, 'P')
	SET @Msg = 'Contact ' + @CreditorName + '(' + convert(varchar, @prfi_Company1Id) + ', ' + @CreditorNumber + ') regarding Open Collection File (' +
				convert(varchar, @FileId) + ') against '	+ @DebtorName + '(' + convert(varchar, @prfi_Company2Id) + ').'
	DECLARE @OneWeek Datetime
	SET @OneWeek = DateAdd(Week, 1, @Now)
	exec usp_CreateTask     
		@StartDateTime = @Now,
		@DueDateTime = @OneWeek,
		@CreatorUserId = @prfi_UpdatedBy,
		@AssignedToUserId = @AssignedToUserId,
		@TaskNotes = @Msg,
		@RelatedCompanyId = @prfi_Company1Id,
		@PRFileId = @FileId,
		@Status = 'Pending'
			
END
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_WA_File_CreateDueDateExpiredTask]'))
	drop Procedure [dbo].[usp_WA_File_CreateDueDateExpiredTask]
GO
CREATE Procedure dbo.usp_WA_File_CreateDueDateExpiredTask
    @prfi_FileId int,
    @AssociatedColumnName varchar(40),
    @prfi_Company1Id int,
    @AssignedUserId int,
    @TaskText varchar(200),
    @NumberOfDays int,
    @prfi_UpdatedBy int
AS  
BEGIN 
    SET NOCOUNT ON
    Declare @Err int
    SET @Err = 0
    Declare @Now datetime
    SET @Now = getDate()
	DECLARE @ReviewDate Datetime
	SET @ReviewDate = DateAdd(Day, @NumberOfDays, @Now)
	exec usp_CreateTask     
		@StartDateTime = @Now,
		@DueDateTime = @ReviewDate,
		@CreatorUserId = @prfi_UpdatedBy,
		@AssignedToUserId = @AssignedUserId,
		@TaskNotes = @TaskText,
		@RelatedCompanyId = @prfi_Company1Id,
		@PRFileId = @prfi_FileId,
		@Status = 'Pending',
		@AssociatedColumnName = @AssociatedColumnName
			
END
GO

/* 
	WA = Workflow Automation procedure 
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_WA_File_CreateNextStepsTask]'))
	drop Procedure [dbo].[usp_WA_File_CreateNextStepsTask]
GO
CREATE Procedure dbo.usp_WA_File_CreateNextStepsTask
    @FileId int,
    @AssignedUserRoleName varchar(100),
    @NextStepText varchar(200),
    @NumberOfDays int
AS  
BEGIN 
    SET NOCOUNT ON
    Declare @Err int
    SET @Err = 0
    Declare @Now datetime
    SET @Now = getDate()
    DECLARE @Msg varchar (2000)
    
    Declare @prfi_Type varchar(40)
    Declare @prfi_UpdatedBy int, @UserId int
    Declare @prfi_Company1Id int
    Declare @CreditorName varchar(500), @DebtorName varchar(500)

    select  @prfi_Type = prfi_Type, 
            @prfi_Company1Id = prfi_Company1Id, 
            @prfi_UpdatedBy = prfi_UpdatedBy 
      from PRFile
     WHERE prfi_FileId = @FileId

	select @CreditorName = comp_name
	  from company
	 where comp_companyid = @prfi_Company1Id
	-- determine the @AssignedUserRoleName UserId
	SELECT @UserId = dbo.ufn_GetWorkflowUserId(@AssignedUserRoleName)
	-- create a task for user to determine next steps in @NumberOfDays days
	DECLARE @CreditorNumber varchar(255)
	SELECT @CreditorNumber = dbo.ufn_GetCompanyPhone (@prfi_Company1Id, 'Y', null, 'P')
	SET @Msg = 'Determine next steps for ' + @NextStepText + ' requested by ' + @CreditorName + '(' + convert(varchar, @prfi_Company1Id) + ', ' + @CreditorNumber + ') regarding open File (' +
				convert(varchar, @FileId) + ').'
	DECLARE @ReviewDate Datetime
	SET @ReviewDate = DateAdd(Day, @NumberOfDays, @Now)
	exec usp_CreateTask     
		@StartDateTime = @Now,
		@DueDateTime = @ReviewDate,
		@CreatorUserId = @prfi_UpdatedBy,
		@AssignedToUserId = @UserId,
		@TaskNotes = @Msg,
		@RelatedCompanyId = @prfi_Company1Id,
		@PRFileId = @FileId,
		@Status = 'Pending'
			
END
GO

/*
 * This procedure is called from the Workflow Update trigger when the status is changed from 
 * Write Opinion.
 *
 * Actions:
 *		* Create a task to have the File_OpinionMonitor role to follow up in ten days
 */
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_WA_File_WriteOpinion]'))
	drop Procedure [dbo].[usp_WA_File_WriteOpinion]
GO
CREATE Procedure dbo.usp_WA_File_WriteOpinion
    @FileId int
AS  
BEGIN 
	exec usp_WA_File_CreateNextStepsTask @FileId, 'File_OpinionMonitor','Opinion Fee Letter', 14		
END
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_WA_File_RequestDisputeAssistance]'))
	drop Procedure [dbo].[usp_WA_File_RequestDisputeAssistance]
GO
CREATE Procedure dbo.usp_WA_File_RequestDisputeAssistance
    @FileId int
AS  
BEGIN 
	exec usp_WA_File_CreateNextStepsTask @FileId, 'File_RDAMonitor','Dispute Fee Letter', 14		
END
GO

/* ************************************************************
	This ends the workflow procs section
 * ************************************************************/


/* 
	Process any potential type 29 relationships.  Invoked from the 
	person_link insert trigger.
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_CreateCompanyType29Relationship]'))
	drop Procedure [dbo].[usp_CreateCompanyType29Relationship]
GO


CREATE Procedure dbo.usp_CreateCompanyType29Relationship
    @PersonID int,
    @CompanyID int,
    @CRMUserID int
AS  
BEGIN 

	DECLARE @CompanyCount int, @Index int, @CurrentCompanyID int, @Type29ID int 

	DECLARE @SharedOwnership table (
		ndx int identity(1,1) Primary Key,
		peli_CompanyID int
	)

	INSERT INTO @SharedOwnership (peli_CompanyID)
	SELECT peli_CompanyID
	  FROM vPROwnershipByPerson
	 WHERE pers_PersonID=@PersonID
	   AND peli_CompanyID <> @CompanyID;

	SET @CompanyCount = @@ROWCOUNT
	SET @Index = 0

	WHILE @Index < @CompanyCount BEGIN
		SET @Index = @Index + 1

		SELECT @CurrentCompanyID = peli_CompanyID
		  FROM @SharedOwnership
		 WHERE Ndx = @Index;

		-- Now determine if we need to create or 
		-- update the PRCompanyRelationship record.
		SELECT @Type29ID = prcr_CompanyRelationshipID 
		  FROM PRCompanyRelationship
		 WHERE prcr_Type = '29'
		   AND ((prcr_LeftCompanyID = @CompanyID AND prcr_RightCompanyID = @CurrentCompanyID)
			   OR (prcr_LeftCompanyID = @CurrentCompanyID AND prcr_RightCompanyID = @CompanyID));

		IF @Type29ID IS NULL BEGIN

			-- Create a new record
			DECLARE @CompRelID int
			EXEC usp_getNextId 'PRCompanyRelationship', @CompRelID Output

			INSERT INTO PRCompanyRelationship (
				prcr_CompanyRelationshipID,
				prcr_CreatedBy,
				prcr_CreatedDate,
				prcr_UpdatedBy,
				prcr_UpdatedDate,
				prcr_TimeStamp,
				prcr_LeftCompanyID,
				prcr_RightCompanyID,
				prcr_Type,
				prcr_EnteredDate,
				prcr_LastReportedDate,
				prcr_TimesReported,
				prcr_Active)
			VALUES (@CompRelID,
				@CRMUserID,
				GETDATE(),
				@CRMUserID,
				GETDATE(),
				GETDATE(),
				@CompanyID,
				@CurrentCompanyID,
				'29',
				GETDATE(),
				GETDATE(),
				1,
				'Y');
		END ELSE BEGIN
			-- Update the existing record
			UPDATE PRCompanyRelationship
			   SET prcr_TimesReported = prcr_TimesReported + 1,
				   prcr_LastReportedDate = GETDATE(),
				   prcr_UpdatedBy = @CRMUserID,
				   prcr_UpdatedDate = GETDATE(),
				   prcr_TimeStamp = GETDATE()
			 WHERE prcr_CompanyRelationshipID = @Type29ID;
		END
	END
END
GO

/**
Used by all of the Jeopardy Letters for the address block
**/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_GetJeopardyLetterHeader]'))
drop Procedure [dbo].[usp_GetJeopardyLetterHeader]
GO

CREATE Procedure dbo.usp_GetJeopardyLetterHeader(@CompanyID int)
AS  
BEGIN 

	-- Calculate the first Wednesday of next month
	DECLARE @NextMonth datetime
	DECLARE @FirstWedOfNextMonth datetime

	SET @NextMonth = DATEADD(month, 1, GETDATE())
	SET @FirstWedOfNextMonth = CAST(DATEPART(year, @NextMonth) as varchar(4)) + '-' +CAST( DATEPART(month, @NextMonth) as varchar(2)) + '-01'

	WHILE (DATEPART(dw, @FirstWedOfNextMonth) <> 4) BEGIN
		SET @FirstWedOfNextMonth = DATEADD(day, 1, @FirstWedOfNextMonth)
	END

	-- Return the data needed for the letter
	SELECT comp_CompanyID,
           comp_PRCorrTradestyle,
		   dbo.ufn_FormatPerson(Pers_FirstName, Pers_LastName, Pers_MiddleName, Pers_PRNickname1, Pers_Suffix) AS Pers_FullName,
		   addr_Address1, addr_Address2, addr_Address3, addr_Address4, addr_Address5, prci_City, prst_Abbreviation, prcn_Country, addr_PostCode,
		   dbo.ufn_GetCompanyPhone(comp_CompanyID, 'Y', NULL, 'F') as FaxNumber,
           comp_PRTMFMAward,
		   @FirstWedOfNextMonth AS BlueBookUpdateDate,
		   DATEADD(day, -1, @FirstWedOfNextMonth) As NotProvidedByDate
	  FROM Company
		   INNER JOIN Address_Link ON comp_CompanyID = adli_CompanyID
		   INNER JOIN Address ON adli_AddressID = addr_AddressID
		   INNER JOIN vPRLocation on addr_PRCityID = prci_CityID
		   INNER JOIN Person_Link ON comp_CompanyID = peli_CompanyID
		   INNER JOIN Person ON peli_PersonID = pers_PersonID
	 WHERE adli_PRDefaultJeopardy = 'Y'
	   AND peli_PRRecipientRole LIKE '%,RCVJEP,%'
       AND peli_PRStatus IN (1,2)
       AND comp_CompanyID = @CompanyID;
       

END
Go



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_GetCompaniesForJeopardyLetter]'))
drop Procedure [dbo].[usp_GetCompaniesForJeopardyLetter]
GO

CREATE Procedure dbo.usp_GetCompaniesForJeopardyLetter
     @LetterType int,
     @DoNotCreateCommunciationRecord int,
	 @Action varchar(40) = NULL,
	 @CRMUserID int = -5,
     @PRCommunicationLanguage varchar(40) = 'E'
AS
BEGIN

	DECLARE @YearEndThreshold int, @IntrimThreshold int, @PreviousLetterThreshold int
	DECLARE @comm_PRSubCategory varchar(40)
	SET @PreviousLetterThreshold = -6

	SET @YearEndThreshold = CASE @LetterType
							WHEN 1 THEN 
								 14
							WHEN 2 THEN 
								 16
							END

	SET @IntrimThreshold = CASE @LetterType
							WHEN 1 THEN 
								 8
							WHEN 2 THEN 
								 10
							END

	-- The sub-category to use when both filter out
	-- previously notified companies and creating
	-- communication records for newly generate letters.
	SET @comm_PRSubCategory = CASE @LetterType
							WHEN 1 THEN 
								 'JL1'
							WHEN 2 THEN 
								 'JL2'
							WHEN 3 THEN 
								 'JL3'
							END

	-- This is an intermediate table
	DECLARE @JeopardyTable table (
		ndx int identity(1,1) PRIMARY KEY,
		CompanyID int,
        ListingCityID int,
		JeopardyDate datetime,
		StatementDate datetime,
        StatementType varchar(40),
		StatementTypeThreshold datetime,
		LastLetterDate datetime
	)

	-- Holds the final results
	DECLARE @Results table (
		ndx int identity(1,1) PRIMARY KEY,
		CompanyID int,
        CompanyName varchar(104),
        FaxNumber varchar(40),
        PersonID int,
        PRTMFMAward char(1),
		JeopardyDate datetime,
        StatementDate datetime,
        StatementType varchar(40)
	)

	IF (@LetterType IN (1,2)) BEGIN

		IF (@LetterType = 1) BEGIN

			Print 'Type 1'

			-- For Type1 letters, make sure we exclude any company that already
            -- received a type1 recently.
			INSERT INTO @JeopardyTable (CompanyID, JeopardyDate, StatementDate)
			SELECT prfs_CompanyID, comp_PRJeopardyDate, MAX(prfs_StatementDate)
			  FROM PRFinancial
				   INNER JOIN Company ON prfs_CompanyID = comp_CompanyID
			 WHERE comp_PRType = 'H'               -- HQ Company
			   AND comp_PRListingStatus = 'L'      -- Listed
			   AND comp_PRJeopardyDate > GETDATE() -- Jeopardy Date in the future
               AND comp_PRCommunicationLanguage = @PRCommunicationLanguage 
			   AND prfs_CompanyID NOT IN (SELECT DISTINCT cmli_Comm_CompanyID
											FROM comm_link
												 INNER JOIN Communication on cmli_Comm_CommunicationID = comm_CommunicationID
										   WHERE comm_PRCategory = 'R'
											 AND comm_PRSubcategory = 'JL1'
											 and comm_CreatedDate > DATEADD(month, @PreviousLetterThreshold, GETDATE()))
         GROUP BY prfs_CompanyID, comp_PRJeopardyDate;

		END ELSE BEGIN

			Print 'Type 2'

			-- For Type2 letters, make sure we include only those companies that have
            -- not received a type 2 yet.
			INSERT INTO @JeopardyTable (CompanyID, JeopardyDate, StatementDate)
			SELECT prfs_CompanyID, comp_PRJeopardyDate, MAX(prfs_StatementDate)
			  FROM PRFinancial
				   INNER JOIN Company ON prfs_CompanyID = comp_CompanyID
			 WHERE comp_PRType = 'H'               -- HQ Company
			   AND comp_PRListingStatus = 'L'      -- Listed
			   AND comp_PRJeopardyDate > GETDATE() -- Jeopardy Date in the future
               AND comp_PRCommunicationLanguage = @PRCommunicationLanguage 
			   AND prfs_CompanyID NOT IN (SELECT DISTINCT cmli_Comm_CompanyID
											FROM comm_link
												 INNER JOIN Communication on cmli_Comm_CommunicationID = comm_CommunicationID
										   WHERE comm_PRCategory = 'R'
											 AND comm_PRSubcategory = 'JL2'
											 and comm_CreatedDate > DATEADD(month, @PreviousLetterThreshold, GETDATE()))
			GROUP BY prfs_CompanyID, comp_PRJeopardyDate;

		END

	END ELSE BEGIN

		Print 'Type 3'

		-- Type3 letters have different date inclusion logic.  Instead of being based
		-- on the statement date, it's based on the Jeopardy date.  
		INSERT INTO @JeopardyTable (CompanyID, JeopardyDate, StatementDate)
		SELECT prfs_CompanyID, comp_PRJeopardyDate, MAX(prfs_StatementDate)
		  FROM PRFinancial
			   INNER JOIN Company ON prfs_CompanyID = comp_CompanyID
		 WHERE comp_PRType = 'H'               -- HQ Company
		   AND comp_PRListingStatus = 'L'      -- Listed
           AND DATEDIFF(day, GETDATE(), comp_PRJeopardyDate) BETWEEN 0 AND 25 -- JeopardyDate within 25 days
           AND comp_PRCommunicationLanguage = @PRCommunicationLanguage 
		   AND prfs_CompanyID NOT IN (SELECT DISTINCT cmli_Comm_CompanyID
										FROM comm_link
											 INNER JOIN Communication on cmli_Comm_CommunicationID = comm_CommunicationID
									   WHERE comm_PRCategory = 'R'
										 AND comm_PRSubcategory = 'JL3'
										 and comm_CreatedDate > DATEADD(month, @PreviousLetterThreshold, GETDATE()))
		GROUP BY prfs_CompanyID, comp_PRJeopardyDate;

	END

	-- Based on the last statement type, determine
	-- what the inclusion threshold is
	UPDATE @JeopardyTable
	   SET StatementType = prfs_Type,
           StatementTypeThreshold = CASE prfs_Type WHEN 'Y' THEN DATEADD(month, @YearEndThreshold, StatementDate) ELSE DATEADD(month, @IntrimThreshold, StatementDate) END
	  FROM PRFinancial
	 WHERE CompanyID = prfs_CompanyID
	   AND StatementDate = prfs_StatementDate;

	IF (@LetterType IN (1,2)) BEGIN
		-- Remove those companies that have a future
		-- threshold date
		DELETE 
		  FROM @JeopardyTable 
		 WHERE StatementTypeThreshold > GETDATE();
	END

	-- Now only deal with those companies that
    -- have someone designated to receive 
	-- Jeopardy letters.
	INSERT INTO @Results (CompanyID, CompanyName, FaxNumber, PRTMFMAward,  PersonID, JeopardyDate, StatementDate, StatementType)
	SELECT CompanyID, comp_Name, dbo.ufn_GetCompanyPhone(CompanyID, 'Y', NULL, 'F') as FaxNumber, comp_PRTMFMAward, peli_PersonID, JeopardyDate, StatementDate, StatementType
	  FROM @JeopardyTable
           INNER JOIN Person_Link ON CompanyID = peli_CompanyID 
           INNER JOIN Company ON CompanyID = comp_CompanyID
	 WHERE peli_PRRecipientRole LIKE '%,RCVJEP,%'
       AND peli_PRStatus IN (1,2);

	-- Only create the communication records if asked
	IF (@DoNotCreateCommunciationRecord = 0) BEGIN

		DECLARE @CompanyCount int, @Index int, @AssignedToUserID int
		DECLARE @CurrentCompanyID int, @PersonID int
        DECLARE @JeopardyDate datetime

		SELECT @CompanyCount = COUNT(1)
		  FROM @Results;

		BEGIN TRANSACTION
		BEGIN TRY	

			SET @Index = 0
			WHILE @Index < @CompanyCount BEGIN
			
				SET @Index = @Index + 1

				-- We need to know which person at the company 
				-- received the jeopardy letter
				SELECT @CurrentCompanyID = CompanyID,
		  			   @PersonID = PersonID,
					   @JeopardyDate = JeopardyDate
				  FROM @Results
				 WHERE ndx = @Index;

				EXEC usp_CreateTask 
							   @CreatorUserId    = @CRMUserID,
							   @TaskNotes        = 'Jeopardy Letter Sent',
							   @RelatedCompanyId = @CurrentCompanyID,
							   @RelatedPersonId  = @PersonID,
							   @Action           = @Action,
							   @Type             = 'Task',
							   @PRCategory       = 'R',
							   @PRSubcategory    = @comm_PRSubCategory;

				IF (@LetterType = 3) BEGIN

					SET @AssignedToUserID = dbo.ufn_GetPRCoSpecialistUserId(@CurrentCompanyID, 3)
					EXEC usp_CreateTask 
                                   @DueDateTime      = @JeopardyDate,
								   @CreatorUserId    = @CRMUserID,
                                   @AssignedToUserID = @AssignedToUserID,
								   @TaskNotes        = 'Determine if rating numeral (79) is required.',
								   @RelatedCompanyId = @CurrentCompanyID,
								   @RelatedPersonId  = @PersonID,
                                   @Status           = 'Pending',
								   @Action           = 'ToDo',
								   @Type             = 'Task',
								   @PRCategory       = 'R',
								   @PRSubcategory    = @comm_PRSubCategory;

				END

			END

			COMMIT
		END TRY
		BEGIN CATCH

			IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION;

			DECLARE @ErrorMessage NVARCHAR(4000);
			DECLARE @ErrorSeverity INT;
			DECLARE @ErrorState INT;

			SELECT	@ErrorMessage = ERROR_MESSAGE(),
					@ErrorSeverity = ERROR_SEVERITY(),
					@ErrorState = ERROR_STATE();

			RAISERROR (@ErrorMessage, 16, @ErrorState);
		END CATCH;
	END

	SELECT CompanyID, FaxNumber, CompanyName, PRTMFMAward, JeopardyDate, StatementDate, b.capt_us AS StatementType
	  FROM @Results 
		   INNER JOIN custom_captions b ON StatementType = b.capt_code and b.capt_family = 'prfs_Type'
  ORDER BY CompanyID;
END
Go



--
--  Set's the specified company's Jeopardy date based on the most recent
--  statement date and its type.
--
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_SetJeopardyDate]'))
drop Procedure [dbo].[usp_SetJeopardyDate]
GO

CREATE Procedure dbo.usp_SetJeopardyDate
     @CompanyID int,
	 @CRMUserID int = -5
AS
BEGIN

	DECLARE @StatementDate datetime, @JeopardyDate datetime

	SELECT @StatementDate = MAX(prfs_StatementDate)
	  FROM PRFinancial
     WHERE prfs_CompanyID = @CompanyID;

	-- Based on the last statement type, determine
    -- what our base expiration is
	SELECT @JeopardyDate = CASE prfs_Type WHEN 'Y' THEN DATEADD(month, 18, @StatementDate) ELSE DATEADD(month, 12, @StatementDate) END
	  FROM PRFinancial
	 WHERE prfs_CompanyID = @CompanyID
	   AND prfs_StatementDate = @StatementDate;

	UPDATE Company
	   SET comp_PRJeopardyDate = @JeopardyDate,
           comp_UpdatedDate = GETDATE(),
           comp_UpdatedBy = @CRMUserID,
           comp_Timestamp = GETDATE()
	 WHERE comp_CompanyID = @CompanyID;

END
Go

--
--  Fax specified number of customer service surveys using ufn_GetCSSurveyEncounters and usp_CreateEmail.
--
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_SendCSSurveys]'))
drop Procedure [dbo].[usp_SendCSSurveys]
go
CREATE PROCEDURE [dbo].[usp_SendCSSurveys]
	@SurveyDate datetime = null,
	@TargetCount int = 100
as 

set nocount on

if (@SurveyDate is null) begin
	set @SurveyDate = getdate()
end

declare @ChosenCount int, 
	@RecordCount int, 
	@Random int,
	@ndx int, 
	@Chosen bit,
	@CompanyId int, 
	@FaxNumber nvarchar(50)
 
declare @CompanyIdPool table (
	ndx int identity,
	CompanyId int,
	FaxNumber nvarchar(50),
	Chosen bit )

-- query for companies eligible for survey
insert into @CompanyIdPool (CompanyId, FaxNumber, Chosen)
select distinct CompanyId,
dbo.ufn_FormatPhone(phon_CountryCode,phon_AreaCode,phon_Number,NULL),
 0 from dbo.ufn_GetCSSurveyEncounters(@SurveyDate)
inner join Company on comp_CompanyId = CompanyId
inner join Phone on phon_CompanyId = CompanyId
inner join vPRLocation on comp_PRListingCityId = prci_CityId
where comp_PRReceiveCSSurvey = 'Y'
and prcn_Country in ('USA','Canada')
and phon_Type in ('F','PF','SF','TF') and phon_Default = 'Y'
and comp_CompanyId not in
	(select distinct cmli_comm_CompanyId from Comm_Link
	inner join Communication on comm_CommunicationId = cmli_Comm_CommunicationId
	where comm_PRSubcategory = 'CSS'
	and datepart(quarter, comm_DateTime) = datepart(quarter, @SurveyDate)
	and datepart(year, comm_DateTime) = datepart(year, @SurveyDate) )

set @RecordCount = @@ROWCOUNT

-- choose up to the desired number of surveys
if (@RecordCount <= @TargetCount) begin
	-- if not enough to choose from, take 'em all
	update @CompanyIdPool set Chosen = 1
end else begin
	-- choose desired number at random
	set @ChosenCount = 1
	while (@ChosenCount <= @TargetCount) begin
		set @Random = round(rand() * @RecordCount, 0, 1) + 1	
		select @Chosen = Chosen from @CompanyIdPool	where ndx = @Random
		if @Chosen = 0 begin
			update @CompanyIdPool set Chosen = 1 where ndx = @Random
			set @ChosenCount = @ChosenCount + 1
		end
	end
end

-- now loop thru the table, sending a survey to each selected company

set @ndx = 1

while (@ndx <= @RecordCount) begin

	select @CompanyId = CompanyId, 
		@FaxNumber = FaxNumber,
		@Chosen = Chosen		
	from @CompanyIdPool where ndx = @ndx

	if (@Chosen = 1) begin
		-- call proc to fax survey, create interaction record

		exec dbo.usp_CreateEmail
			null, --@CreatorUserId int = null,
			@FaxNumber, --@To text = null,
			null, --@From text = null,
			null, --@Subject text = null,
			null, --@Content text = null,
			'Normal', --@Priority varchar(40) = 'Normal',
			null, --@CC text = null,
			null, --@BCC text = null,
			null, --@AttachmentDir varchar(255) = null,
			'CSS1_R1', --@AttachmentFileName varchar(255) = null,
			null, --@Content_Format varchar(20) = 'TEXT',
			@CompanyId, --@RelatedCompanyId int = NULL,
			null, --@RelatedPersonId int = NULL,
			'FaxOut',
			0, --@DoNotRecordCommunication bit = 0,
			0, --@DoNotSend bit = 0,
			1, --@AttachmentIsLibraryDoc bit = 0
			'CS', --@PRCategory = NULL,
			'CSS' --@PRSubcategory = NULL
	
	end

	set @ndx = @ndx + 1

end
go


--
--  Determines if tasks need to be created based on the relationship type
--  and who created it.
--
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_CreateRelationshipTasks]'))
drop Procedure [dbo].[usp_CreateRelationshipTasks]
GO

CREATE Procedure dbo.usp_CreateRelationshipTasks
	@SubjectCompany int,
	@RelatedCompany int,
	@RelationshipType varchar(40),
	@UserID int
AS
BEGIN

	DECLARE @RatingAnalystID int
	DECLARE @Now datetime
	DECLARE @Notes varchar(1000)

	-- We're only interested in specific relationship types
	IF (@RelationshipType IN (5, 7, 27, 28, 29, 30, 31, 32, 33, 34, 35)) BEGIN

		--	 We only need to create the task if the user making the change
		-- is not the listing specialist
		SET @RatingAnalystID = dbo.ufn_GetPRCoSpecialistUserId(@SubjectCompany, 0)
		IF (@RatingAnalystID <> @UserID) BEGIN

			SET @Now = GETDATE()
			SET @Notes = 'Verify new relationship type ' + @RelationshipType + ' created with related company ID '+ CAST(@RelatedCompany as varchar(10)) + '.'

			exec usp_CreateTask @StartDateTime = @Now,
								@DueDateTime = @Now,
								@CreatorUserId = @UserID,
								@AssignedToUserId = @RatingAnalystID,
								@TaskNotes = @Notes,
								@RelatedCompanyId = @SubjectCompany,
								@Status = 'Pending',
								@Action = 'ToDo',
								@Type = 'Task',
								@Priority = 'Normal',
								@PRCategory = null,
								@PRSubcategory = null

		END
	END
END
Go


--
--  Determines if tasks need to be created based on the business event type
--
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_CreateBusinessEventTasks]'))
drop Procedure [dbo].[usp_CreateBusinessEventTasks]
GO

CREATE Procedure dbo.usp_CreateBusinessEventTasks
	@CompanyID int,
	@BusinessEventTypeID int,
	@UserID int
AS
BEGIN

	DECLARE @ListingSpecalistID int
	DECLARE @Now datetime, @DueDate datetime
	DECLARE @Notes varchar(1000), @BusinessEventTypeName varchar(100)

	DECLARE @CompanyCount int, @CompanyIndex int, @CurrentCompanyID int
	DECLARE @CompanyIDs table (
		ndx int identity(1,1) PRIMARY KEY,
		CompanyID int
	)

	-- If this a US Bankruptcy or Assignment for Creditors
	IF (@BusinessEventTypeID IN (5, 3)) BEGIN
		SET @Now = GETDATE()
		
	    SELECT @BusinessEventTypeName = prbt_Name
          FROM PRBusinessEventType
         WHERE prbt_BusinessEventTypeID = @BusinessEventTypeID;

		SET @Notes = 'Company ID ' + CAST(@CompanyID as varchar(10)) + ' reported a "' + @BusinessEventTypeName + '" business event and is affiliated with this company.  Please review this company''s rating.'

		INSERT INTO @CompanyIDs (CompanyID)
		SELECT DISTINCT prcr_LeftCompanyID
		  FROM PRCompanyRelationship
		 WHERE prcr_RightCompanyID = @CompanyID
		   AND prcr_Type IN (27, 28, 29)
           AND prcr_Active = 'Y'
		   AND prcr_Deleted IS NULL;

		-- Go get other companies that have a direct
		-- relationship
		INSERT INTO @CompanyIDs (CompanyID)
		SELECT DISTINCT prcr_RightCompanyID
		  FROM PRCompanyRelationship
		 WHERE prcr_LeftCompanyID = @CompanyID
		   AND prcr_Type IN (27, 28, 29)
           AND prcr_RightCompanyID NOT IN (SELECT CompanyID FROM @CompanyIDs)
           AND prcr_Active = 'Y'
		   AND prcr_Deleted IS NULL;

		SELECT @CompanyCount = COUNT(1) FROM @CompanyIDs;
		SET @CompanyIndex = 0

		WHILE @CompanyIndex < @CompanyCount BEGIN
			SET @CompanyIndex = @CompanyIndex + 1

			SELECT @CurrentCompanyID = CompanyID
              FROM @CompanyIDs
             WHERE ndx = @CompanyIndex;

			SET @ListingSpecalistID = dbo.ufn_GetPRCoSpecialistUserId(@CurrentCompanyID, 3)

			EXEC usp_CreateTask  @StartDateTime = @Now,
								@DueDateTime = @Now,
								@CreatorUserId = @UserID,
								@AssignedToUserId = @ListingSpecalistID,
								@TaskNotes = @Notes,
								@RelatedCompanyId = @CurrentCompanyID,
								@Status = 'Pending',
								@Action = 'ToDo',
								@Type = 'Task',
								@Priority = 'Normal',
								@PRCategory = 'R',
								@PRSubcategory = 'RR'


		END
	END
END
Go

--
--  Determines if tasks need to be created based on the rating numeral assigned
--
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_CreateRatingNumeralTasks]'))
drop Procedure [dbo].[usp_CreateRatingNumeralTasks]
GO

CREATE Procedure dbo.usp_CreateRatingNumeralTasks
	@Company int,
	@RatingNumeralID int,
	@UserID int
AS
BEGIN

	DECLARE @ListingSpecalistID int
	DECLARE @Now datetime, @DueDate datetime
	DECLARE @Notes varchar(1000)

	IF (@RatingNumeralID IN (83, 86, 60)) BEGIN

		SET @ListingSpecalistID = dbo.ufn_GetPRCoSpecialistUserId(@Company, 3)
		SET @Now = GETDATE()

		IF (@RatingNumeralID IN (83, 86)) BEGIN
			SET @Notes = 'Rating numeral (' + CAST(@RatingNumeralID as varchar(10))  + ') was assigned to this company.  Please review current rating and related publishable text.'
			SET @DueDate = DATEADD(month, 4, @Now)
		END

		IF (@RatingNumeralID = 60) BEGIN
			SET @Notes = 'Rating numeral (60) was assigned to this company.  Please review company to determine if an X rating can be assigned.'
			SET @DueDate = DATEADD(month, 9, @Now)
		END

		EXEC usp_CreateTask  @StartDateTime = @Now,
							@DueDateTime = @DueDate,
							@CreatorUserId = @UserID,
							@AssignedToUserId = @ListingSpecalistID,
							@TaskNotes = @Notes,
							@RelatedCompanyId = @Company,
							@Status = 'Pending',
							@Action = 'ToDo',
							@Type = 'Task',
							@Priority = 'Normal',
							@PRCategory = 'R',
							@PRSubcategory = 'RR'
	END
END
Go

--
--  Looks for TES Non Repsonders to create tasks for verbal trade reports
--
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_CreateTESNonResponderTasks]'))
drop Procedure [dbo].[usp_CreateTESNonResponderTasks]
GO

CREATE Procedure dbo.usp_CreateTESNonResponderTasks
AS
BEGIN
	DECLARE @ResponderCount int, @ResponderIndex int, @DataProcessorUserID int
	DECLARE @ResponderID int, @SubjectID int
	DECLARE @ResponderName varchar(104), @SubjectName varchar(104), @Notes varchar(1000)
	DECLARE @Now datetime

	SET @Now = GETDATE()

	DECLARE @NonResponders table (
		ndx int identity(1,1) primary key,
		ResponderID int,
		ResponderName varchar(104),
		SubjectID int,
		SubjectName varchar(104)
	)

	INSERT INTO @NonResponders (ResponderID, ResponderName, SubjectID, SubjectName)
	SELECT prte_ResponderCompanyID, ResponderName, prt2_SubjectCompanyID, SubjectName 
	  FROM (
		SELECT prte_ResponderCompanyID, a.comp_Name as ResponderName, prt2_SubjectCompanyID, b.comp_Name as SubjectName, MIN(prte_Date) as prte_Date, Count(1) as TESCount
		  FROM PRTES
			   INNER JOIN PRTESDetail ON prte_TESID = prt2_TESID
			   INNER JOIN Company a ON prte_ResponderCompanyID = a.comp_CompanyID
			   INNER JOIN Company b ON prt2_SubjectCompanyID = b.comp_CompanyID
		 WHERE prte_Date >= DATEADD(day, -62, GETDATE())
		   AND prt2_Received IS NULL
		GROUP BY prte_ResponderCompanyID, a.comp_Name, prt2_SubjectCompanyID, b.comp_Name
		HAVING COUNT(1) > 1) T1
	WHERE prte_Date = DATEADD(day, -62, GETDATE());

	SET @ResponderCount = @@ROWCOUNT
	SET @ResponderIndex = 0
	SET @DataProcessorUserID = dbo.ufn_GetCustomCaptionValue('AssignmentUserID', 'DataProcessor', -5)

	WHILE @ResponderIndex < @ResponderCount BEGIN
		SET @ResponderIndex = @ResponderIndex + 1

		SELECT @ResponderID   = ResponderID, 
			   @ResponderName = ResponderName,
			   @SubjectID     = SubjectID,
			   @SubjectName   = SubjectName 
		  FROM @NonResponders
		  WHERE ndx = @ResponderIndex;

		SET @Notes = 'Multiple TES requests have been sent to ' + @ResponderName + ', ' + CAST(@ResponderID as varchar(10)) + ' for subject '+ @SubjectName + ', ' + CAST(@ResponderID as varchar(10)) + '.  Please contact responder company for a verbal TES.';

		EXEC usp_CreateTask  @StartDateTime = @Now,
							@DueDateTime = @Now,
							@CreatorUserId = -100,
							@AssignedToUserId = @DataProcessorUserID,
							@TaskNotes = @Notes,
							@RelatedCompanyId = @ResponderID,
							@Status = 'Pending',
							@Action = 'ToDo',
							@Type = 'Task',
							@Priority = 'Normal',
							@PRCategory = 'R',
							@PRSubcategory = 'VI'
		

	END

	SELECT @ResponderCount as TaskCount;
END
Go

--
--  Determines if tasks need to be created for "service through" companies based on the the 
--  cancellation of a service
--
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_CreateServiceCancellationTasks]'))
drop Procedure [dbo].[usp_CreateServiceCancellationTasks]
GO

CREATE Procedure dbo.usp_CreateServiceCancellationTasks
	@CompanyID int,
	@UserID int
AS
BEGIN

	DECLARE @SalesRepID int
	DECLARE @Now datetime, @DueDate datetime
	DECLARE @Notes varchar(1000)
	
	DECLARE @CompanyCount int, @CompanyIndex int, @CurrentCompanyID int
	DECLARE @CompanyIDs table (
		ndx int identity(1,1) PRIMARY KEY,
		CompanyID int
	)

	SET @Now = GETDATE()
	
	INSERT INTO @CompanyIDs (CompanyID)
	SELECT DISTINCT comp_companyid
	  FROM Company
	 WHERE comp_PRServicesThroughCompanyId = @CompanyID
	   AND comp_Deleted IS NULL;

	SELECT @CompanyCount = COUNT(1) FROM @CompanyIDs;
	SET @CompanyIndex = 0

	WHILE @CompanyIndex < @CompanyCount BEGIN
		SET @CompanyIndex = @CompanyIndex + 1

		SELECT @CurrentCompanyID = CompanyID
          FROM @CompanyIDs
         WHERE ndx = @CompanyIndex;

		SET @SalesRepID = dbo.ufn_GetPRCoSpecialistUserId(@CurrentCompanyID, 1)
		SET @Notes = 'A Primary Service was canceled for Company ID ' + CAST(@CompanyID as varchar(10)) + 
				'. Company Id ' + CAST(@CurrentCompanyID as varchar(10)) + 
				' receives its services through this company.  Please review/update this company''s Services Through value.' 

		EXEC usp_CreateTask  @StartDateTime = @Now,
							@DueDateTime = @Now,
							@CreatorUserId = @UserID,
							@AssignedToUserId = @SalesRepID,
							@TaskNotes = @Notes,
							@RelatedCompanyId = @CurrentCompanyID,
							@Status = 'Pending',
							@Action = 'ToDo',
							@Type = 'Task',
							@Priority = 'Normal',
							@PRCategory = 'SM',
							@PRSubcategory = 'O'


	END
END
Go

/*
	This function is currently not in use as of build 2.0.126; could not be completed in time for 
	release 1
*/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_CheckPersonLinkWarnings]'))
	drop Procedure [dbo].[usp_CheckPersonLinkWarnings]
GO
CREATE Procedure dbo.usp_CheckPersonLinkWarnings
    @PersonId int, 
	@CompanyId int,
	@UserId int
AS
BEGIN
	-- Determine if the user is the rating analyst for this company
	-- if so just return
	Declare @RatingAnalystId int
	SET @RatingAnalystId = dbo.ufn_GetPRCoSpecialistUserId(@CompanyId, 0)
	IF (@RatingAnalystId = @UserId) 
		return
	
	Declare @bPersonIsOwner int
	Set @bPersonIsOwner = 0
	SELECT @bPersonIsOwner = 1 from Person_Link
	WHERE peli_PROwnershipRole = 'RCO'
	and peli_PersonId = @PersonId
	-- if the person is an owner, for some reason we do not check these.  Verify this rule
	if (@bPersonIsOwner	= 1)
		return

	Declare @PersonName varchar(100)
	select @PersonName = dbo.ufn_FormatPersonById(@PersonId)

	Declare @b113 bit, @bBankruptcy bit, @bPACAViolation bit, @bDRCViolation bit, 
			@bLegalAction bit, @bTerminated bit
	SET @b113 = 0
	SET @bBankruptcy = 0
	SET @bPACAViolation = 0
	SET @bDRCViolation =0
	SET @bLegalAction = 0
	SET @bTerminated = 0

	Declare @Now datetime
	SET @Now = GetDate()

	-- determine if this user was ever linked to a company
	-- that reported a (113)
	Select top 1 @b113 = 1 from PRRatingNumeralAssigned
	Inner Join PRRating on prra_RatingId = pran_RatingId 
	Inner Join Person_link on peli_CompanyId = prra_CompanyId
	where pran_RatingNumeralId = 113
	and peli_PersonId = @PersonId

	-- determine if this user was ever terminated
	Select top 1 @bTerminated = 1 from Person_link 
	where peli_PRExitReason = 'F'
	and peli_PersonId = @PersonId

	-- Check the variou s Person Events that can occur
	Select top 1 @bPACAViolation = 1 from PersonEventType
	Where prpe_PersonEventTypeId = 2
	and prpe_PersonId = @PersonId

	Select top 1 @bDRCViolation = 1 from PersonEventType
	Where prpe_PersonEventTypeId = 1
	and prpe_PersonId = @PersonId

	Select top 1 @bBankruptcy = 1 from PersonEventType
	Where prpe_PersonEventTypeId = 4
	and DATEDIFF(year, GETDATE(), prpe_CreatedDate) <= 5
	and prpe_PersonId = @PersonId

	Select top 1 @bLegalAction = 1 from PersonEventType
	Where prpe_PersonEventTypeId = 6
	and prpe_PersonId = @PersonId

	Declare @Msg varchar(1000)
	SET @Msg = ''	
	if (@b113 = 1) begin
		SET @Msg = @Msg + 'was previously employed or an owner of another company that was reported (113)'
	end	
	if (@bBankruptcy = 1) begin
		if (@Msg != '')
			SET @Msg = @Msg + ',\n'
		SET @Msg = @Msg + 'previously filed a personal bankrupcty'
	end	
	if (@bPACAViolation = 1) begin
		if (@Msg != '')
			SET @Msg = @Msg + ',\n'
		SET @Msg = @Msg + 'previously had a PACA violation'
	end	
	if (@bDRCViolation = 1) begin
		if (@Msg != '')
			SET @Msg = @Msg + ',\n'
		SET @Msg = @Msg + 'previously had a DRC violation'
	end	
	if (@bLegalAction = 1) begin
		if (@Msg != '')
			SET @Msg = @Msg + ',\n'
		SET @Msg = @Msg + 'previously had a legal violation'
	end	
	if (@bTerminated = 1) begin
		if (@Msg != '')
			SET @Msg = @Msg + ',\n'
		SET @Msg = @Msg + 'previously was "terminated" by another company'
	end	
	
	Declare @FinalMsg varchar(3000)
	if (@Msg != '')
	begin
		SET @FinalMsg = 'Check out BB ID ' + convert(varchar(12), @CompanyId) + '.  ' + @PersonName +
				' is now connected and has the following warnings: \n\n' + @FinalMsg
		-- send the email
		/*
		exec usp_CreateEmail
			@CreatorUserId = @UserId,
			@To text = null,
			@From text = null,
			@Subject text = null,
			@Content text = null,
			@Priority varchar(40) = 'Normal',
			@CC text = null,
			@BCC text = null,
			@AttachmentDir varchar(255) = null,
			@AttachmentFileName varchar(255) = null,
			@Content_Format varchar(20) = 'TEXT',
			@RelatedCompanyId int = NULL,
			@RelatedPersonId int = NULL,
			@Action varchar(40) = 'EmailOut',
			@DoNotRecordCommunication bit = 0,
			@DoNotSend bit = 0,
			@AttachmentIsLibraryDoc bit = 0,
			@PRCategory varchar(40) = NULL,
			@PRSubcategory varchar(40) = NULL
		*/
	end

END
GO
-- ********************* END CUSTOM STORED PROCEDURES **********************