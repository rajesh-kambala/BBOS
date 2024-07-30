/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2024

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Produce Report Company  is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Produce Report Company .
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 
   
***********************************************************************
***********************************************************************/

--
--  This is a SAGE CRM provided stored procedure.  To help combat the
--  deadlocks/blocking issues, we've modified it a little.
--
ALTER PROCEDURE [dbo].[eware_get_identity_id]
       @table_name NVARCHAR(80) 
AS      
BEGIN    

	DECLARE @table_id INT

	DECLARE @errmsg NVARCHAR(250)      
	SELECT  @errmsg =''      

	DECLARE @timeout INTeger
	DECLARE @start_lock datetime

	DECLARE @id_inc INT
	DECLARE @sql NVARCHAR(200)
	
	DECLARE @r_start INT
	DECLARE @r_end INT
	DECLARE @r_nextstart INT
    DECLARE @r_nextend INT

	DECLARE @r_nextcontrol INT

	DECLARE @range_limit INT

	DECLARE @new_id INT
	SELECT  @new_id = 0

	DECLARE @no_lock INT

 	SELECT @range_limit = 10000

	SELECT @timeout = 5 -- try for 5 seconds to get the lock

	SET NOCOUNT ON

-- Added By PRCO to combat Deadlocking/Blocking
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
	
	-- Get the Table Id from the table name
	SELECT @table_id = Bord_TableId FROM Custom_Tables NOLOCK WHERE Bord_Name = @table_name
	IF (@@ERROR <> 0) OR @table_id = 0 BEGIN
		RAISERROR('crm_new_id: No Table Found %s',16,-1,@table_name) WITH LOG
		RETURN 0
	END

       
BEGIN TRANSACTION T1  
	-- keep trying until we get the lock
	-- must put a timeout here and RETURN ERROR IF cannot get lock
	SELECT @start_lock = getdate();
	SELECT @no_lock = 0
	WHILE (@no_lock = 0) AND (Getdate() < DateAdd(second,@timeout,@start_lock) ) BEGIN
	        INSERT INTO Locks (Lock_SessionId, Lock_TableId,Lock_RecordId,Lock_CreatedBy,Lock_CreatedDate)
        	VALUES(0,@table_id,-99,0,getDate())

	 	IF (@@ERROR = 0) BEGIN
           		SELECT @no_lock = 1
		END
	END
	IF @no_lock = 0 BEGIN
		ROLLBACK TRANSACTION T1
                RAISERROR('crm_new_id: Timeout trying to get lock (%s)',16,-1,@table_name) WITH LOG
		RETURN 0
	END
	ELSE BEGIN
        	COMMIT TRANSACTION T1
	END


BEGIN TRANSACTION T2
        -- check out the range values for this table 
	SELECT @r_start = Range_RangeStart, @r_end = Range_RangeEnd,
               @r_nextstart = Range_NextRangeStart, @r_nextend = Range_NextRangeEnd,
               @r_nextcontrol = Range_Control_NextRange FROM Rep_Ranges NOLOCK WHERE Range_TableId = @table_id

	-- get the next id for this table
	EXEC @new_id = crm_next_id @table_id = @table_id	

	-- is the id within the range?
	IF (@new_id < @r_start OR @new_id > @r_end) AND (@new_id <> 0) BEGIN

		-- have used up all the range so create a new range
		UPDATE Rep_Ranges SET 
   		Range_RangeStart = @r_nextstart,
		Range_RangeEnd = @r_nextend,
		Range_NextRangeStart = @r_nextcontrol,
		Range_NextRangeEnd = @r_nextcontrol + @range_limit - 1,
 		Range_Control_NextRange = @r_nextcontrol + @range_limit
		WHERE Range_TableId = @table_id
		
		IF @@ERROR <> 0 BEGIN
			SELECT @new_id = 0
			SELECT @errmsg = 'crm_new_id: Update New Range Failed (%s)'
			GOTO END_TRANS
		END

		-- result is first id FROM new range		
		SELECT @new_id = @r_nextstart

		-- apply the new range so eware_get_next_id will RETURN next id FROM within new range
		UPDATE Sql_Identity SET Id_NextId = @r_nextstart+1 WHERE Id_TableId = @table_id                  
		IF @@ERROR <> 0 BEGIN
			SELECT @new_id = 0
			SELECT @errmsg = 'crm_new_id: Apply New Range Failed (%s)'
			GOTO END_TRANS
		END

 	END 

END_TRANS: -- commit or rollback the transaction

	IF @new_id = 0 BEGIN		
		ROLLBACK TRANSACTION T2
		IF @errmsg = '' 
			SELECT @errmsg = 'crm_new_id: Get Next Id Failed (%s)'
                
	END
	ELSE BEGIN
		COMMIT TRANSACTION T2
	END

	
	--Finished so remove the lock 	
	BEGIN TRANSACTION T3
	SELECT @start_lock = getdate();
	SELECT @no_lock = 0
	WHILE (@no_lock = 0) AND (Getdate() < DateAdd(second,@timeout,@start_lock) ) BEGIN

	        DELETE FROM Locks WHERE Lock_TableId=@table_id and Lock_RecordId = -99		
	 	IF (@@ERROR = 0) BEGIN
           		SELECT @no_lock = 1
		END
	END
	IF @no_lock = 0 BEGIN
		ROLLBACK TRANSACTION T3
                RAISERROR('crm_new_id: Error Deleting Lock (%s)',16,-1,@table_name) WITH LOG
		RETURN 0
	END
	ELSE BEGIN
		COMMIT TRANSACTION T3
	END      

	-- Make sure RaisError is the last call, so that @@ERROR is set correctly
	IF (@errmsg <> '') BEGIN
 		RAISERROR(@errmsg,16,-1,@table_name) WITH LOG
		RETURN 0
	END
      
	SET NOCOUNT OFF
        RETURN @new_id
END
Go

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

/******************************************************************************
 *   This used to override the Sage proc, but no longer.  The code below
 *   was taken from v6.0.
 *
 *****************************************************************************/
IF OBJECT_ID (N'crm_next_id',N'P') IS NOT NULL
    DROP PROCEDURE crm_next_id;
GO
CREATE PROCEDURE crm_next_id 
       @table_id int 
AS      
BEGIN      
	declare @id_next int      
	declare @id_table int
	select  @id_next = 0

	declare @errmsg nvarchar(250)      
	select  @errmsg =''      

	declare @id_inc int
	declare @sql nvarchar(200)
       
BEGIN TRANSACTION T1  
	exec('DECLARE my_cursor CURSOR FOR SELECT Id_TableId, Id_NextId FROM ' +      
        	'SQL_Identity WITH (UPDLOCK) WHERE Id_TableId ='+@table_id)      
      
	--open cursor and fetch max back      
	open my_cursor      
	fetch next from my_cursor into @id_table, @id_next
	if (@@fetch_status=0) begin             
 		select @id_inc = @id_next+1
		select @sql = 'update SQL_Identity set Id_NextId='+STR(@id_inc)+' where Id_TableId='+STR(@id_table)
        	exec(@sql)      
        end 
        else begin
           select @errmsg = 'NOROW';
        end
                        
        close my_cursor      
        deallocate my_cursor      
COMMIT TRANSACTION T1
      
       -- now check got back decent result      
       if (@errmsg<>'') begin      
          raiserror(@errmsg,16,-1)      
          return 0      
       end      
      
       return @id_next
END
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_getNextId]'))
drop Procedure [dbo].[usp_getNextId]
GO
CREATE Procedure dbo.usp_getNextId
    @TableName nvarchar(200) = NULL,
    @Return int output 
AS
BEGIN
	Declare @returnvalue int
	SET @returnvalue = 0
	exec @returnvalue = eware_get_identity_id @TableName
	SET @Return = @returnvalue
	return @returnvalue
END
GO


IF EXISTS (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_InsertEmail]') 
            and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_InsertEmail]
GO

CREATE PROCEDURE dbo.usp_InsertEmail
    @RecordID int,
    @EntityID int,
	@Type varchar(40),
	@EmailAddress varchar(255),
	@WebAddress varchar(255),
	@Description varchar(50),
	@Publish char(1),
	@PreferredInternal char(1),
	@PreferredPublish char(1),
	@Sequence int = 0,
	@SourceID int = NULL,
    @UserId int = -1,
	@CompanyID int = NULL
AS
BEGIN

	DECLARE @EmailID int, @LinkID int
	DECLARE @Now datetime = GETDATE()

	IF (@Type IS NULL) BEGIN
		IF (@EmailAddress IS NOT NULL) BEGIN
			SET @Type = 'E'
			SET @Description = 'E-Mail'
		END ELSE BEGIN
			SET @Type = 'W'
			SET @Description = 'Web Site'
		END
	END

	EXEC usp_GetNextId 'Email', @EmailID output
	INSERT INTO Email 
		(emai_EmailId, emai_CreatedBy, emai_createdDate, emai_UpdatedBy, emai_UpdatedDate, emai_TimeStamp,
		 emai_EmailAddress, emai_PRWebAddress, emai_PRDescription, emai_PRPublish, emai_PRSequence,
		 emai_PRReplicatedFromId, emai_PRPreferredInternal, emai_PRPreferredPublished, emai_CompanyID)  
	VALUES (@EmailID, @UserId, @Now, @UserId, @Now, @Now,  
	        @EmailAddress, @WebAddress, @Description, @Publish, @Sequence,
			@SourceID, @PreferredInternal, @PreferredPublish, @CompanyID);

	EXEC usp_GetNextId 'EmailLink', @LinkID output
	INSERT INTO EmailLink 
		(ELink_LinkID, ELink_CreatedBy, ELink_createdDate, ELink_UpdatedBy, ELink_UpdatedDate, ELink_TimeStamp,
		 ELink_EntityID, ELink_RecordID, ELink_Type, ELink_EmailId)  
	VALUES (@LinkID, @UserId, @Now, @UserId, @Now, @Now,  
	        @EntityID, @RecordID, @Type, @EmailID);
END
Go


IF EXISTS (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_InsertPhone]') 
            and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_InsertPhone]
GO

CREATE PROCEDURE dbo.usp_InsertPhone
    @RecordID int,
    @EntityID int,
	@Type varchar(40),
	@CountryCode varchar(5),
	@AreaCode varchar(20),
	@Number varchar(34),
	@Description varchar(34),
	@Extension varchar(34),
	@International varchar(1),
	@CityCode varchar(5),
	@Disconnected char(1),
	@Publish char(1),
	@PreferredInternal char(1),
	@PreferredPublish char(1),
	@Sequence int = 0,
	@SourceID int = NULL,
    @UserId int = -1,
	@CompanyID int = NULL
AS
BEGIN

	DECLARE @PhoneID int, @LinkID int
	DECLARE @Now datetime = GETDATE()

	EXEC usp_GetNextId 'Phone', @PhoneID output
	INSERT INTO Phone 
		(phon_phoneid, phon_CreatedBy, phon_createdDate, phon_UpdatedBy, phon_UpdatedDate, phon_TimeStamp,
		 phon_CountryCode, phon_AreaCode, phon_Number, phon_PRDescription, phon_PRExtension,
		 phon_PRInternational, phon_PRCityCode, phon_PRDisconnected, phon_PRSequence, phon_PRReplicatedFromId,
		 phon_PRPublish, phon_PRPreferredInternal, phon_PRPreferredPublished, phon_CompanyID)  
	VALUES (@PhoneID, @UserId, @Now, @UserId, @Now, @Now,  
	        @CountryCode, @AreaCode, @Number, @Description, @Extension,
			@International, @CityCode, @Disconnected, @Sequence, @SourceID,
			@Publish, @PreferredInternal, @PreferredPublish, @CompanyID);

	EXEC usp_GetNextId 'PhoneLink', @LinkID output
	INSERT INTO PhoneLink 
		(PLink_LinkID, PLink_CreatedBy, PLink_createdDate, PLink_UpdatedBy, PLink_UpdatedDate, PLink_TimeStamp,
		 PLink_EntityID, PLink_RecordID, PLink_Type, PLink_PhoneId)  
	VALUES (@LinkID, @UserId, @Now, @UserId, @Now, @Now,  
	        @EntityID, @RecordID, @Type, @PhoneID);
END
Go





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
    
    IF (@prtx_EffectiveDate is null)
		SET @prtx_EffectiveDate = getDate()

    -- the user id is required
    IF ( @UserId IS NULL) 
    BEGIN
        SET @Msg = 'Update Failed.  An valid User Id must be provided.'
        ROLLBACK
        RAISERROR (@Msg, 16, 1)
        Return
    END
	
    exec usp_GetNextId 'PRTransaction', @NextId output

    SET @Now = getDate();
    INSERT INTO PRTransaction
      VALUES(@NextId, @prtx_Deleted, @prtx_WorkflowId, @prtx_Secterr, 
             @UserId, @Now, @UserId, @Now, @Now, 
             @prtx_CompanyId, @prtx_PersonId, @prtx_BusinessEventId, @prtx_PersonEventId,
             @prtx_EffectiveDate, @prtx_AuthorizedById, @prtx_AuthorizedInfo,
             @prtx_NotificationType, @prtx_NotificationStimulus, 
             @prtx_CreditSheetId, @prtx_Explanation, @prtx_RedbookDate, @prtx_Status, null, null, null)

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
    if ((@OldValue = @NewValue) OR
        (@OldValue IS NULL AND @NewValue IS NULL))
    BEGIN
        return
    END
	
	Declare @Caption varchar(500)
	SET @Caption = dbo.ufn_GetFieldCaption(@Field);
    IF (@Caption is NULL) SET @Caption = @Field

	INSERT INTO PRTransactionDetail (prtd_TransactionId, prtd_EntityName, prtd_Action, prtd_ColumnName, prtd_OldValue, prtd_NewValue, prtd_UpdatedBy)
	VALUES(@prtx_TransactionId, @Entity, @Action, @Caption, @OldValue, @NewValue, @UserId);

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
 *                the update is recorded in that trx. Otherwise, trx records are 
 *                created to record the change, then closed again.
 *
 *****************************************************************************/
CREATE OR ALTER PROCEDURE dbo.usp_AutoRemoveRatingNumerals
    @UserId int
as
BEGIN
    SET NOCOUNT ON
	DECLARE @Msg varchar(2000)
    DECLARE @comp_companyid int
    DECLARE @TrxId int
    DECLARE @CompanyCount int
    DECLARE @ndx int
    DECLARE @OldRatingId int, @NewRatingId int
	DECLARE @NOW datetime
	SET @NOW = getDate()

	-- Create a table of only autoremove numerals
	DECLARE @tblAutoRemove table (prrn_RatingNUmeralId int)
	INSERT INTO @tblAutoRemove 
		select prrn_RatingNumeralId from PRRatingNumeral where prrn_AutoRemove = 'Y'

    -- Create a local table for the companies with rating numerals to be removed
    DECLARE @tblCompanies TABLE (ndx int identity, comp_companyid int)

	-- get a list of all the companies that have rating numerals to remove
	INSERT INTO @tblCompanies
        SELECT DISTINCT comp_companyid
        FROM vPRCompaniesWithAutoRemoveNums 
        WHERE comp_PRListingStatus = 'L'
        ORDER BY comp_companyid
	SET @CompanyCount = @@ROWCOUNT
	SET @ndx = 1

    -- Start making our updates
	BEGIN TRY	
		WHILE (@ndx <= @CompanyCount)
		BEGIN
			SET @comp_companyid = null
			SET @NewRatingId = NULL
			SET @TrxId = NULL

			-- get the company we are operating on
			SELECT @comp_companyid = comp_companyid 
				FROM @tblCompanies where ndx = @ndx

			-- get the id of the current rating record
			SELECT @OldRatingId = prra_RatingId From PRRating where prra_Current = 'Y' and prra_CompanyId = @comp_companyid

			BEGIN TRANSACTION

			-- Open a transaction if one is not open
			IF (Not Exists (SELECT 1 FROM PRTransaction 
						  WHERE prtx_Status = 'O' and prtx_companyid = @comp_companyid))
			BEGIN
			  exec @TrxId = usp_CreateTransaction 
							 @UserId = @UserId,
							 @prtx_CompanyId = @comp_companyid,
							 @prtx_Explanation = 'Transaction created by Auto Remove Rating Numeral process.'
			END

			EXEC usp_GetNextId 'PRRating', @NewRatingId output

			--DELETE FROM PRRatingNumeralAssigned where pran_RatingNumeralAssignedId = @pran_RNAssignedId
			-- We no longer jsut delete rating numerals; we create a copy of the current rating
			-- and reassign each of the valid rating numerals to the new rating; note that we
			-- remove any credit worth ids of 4 CWE = 79). Also note the PRRating insert trigger
			-- assigns the prra_RatingId and sets the previous current rating to non-Current.
			INSERT INTO PRRating
			(prra_RatingId, prra_Deleted, prra_WorkflowId, prra_Secterr, prra_CreatedBy,
				prra_CreatedDate, prra_UpdatedBy, prra_UpdatedDate, prra_TimeStamp,
				prra_CompanyId, prra_Date, prra_Current, prra_CreditWorthId, prra_IntegrityId,
				prra_PayRatingId, prra_InternalAnalysis, prra_PublishedAnalysis)
			Select @NewRatingId, null, prra_WorkflowId, prra_Secterr, @UserId, 
				@NOW, @UserId, @NOW, @NOW, 
				@comp_companyid, @NOW, 'Y', case when prra_CreditWorthId = 4 then NULL else prra_CreditWorthId end, prra_IntegrityId,
				prra_PayRatingId, prra_InternalAnalysis, prra_PublishedAnalysis
			  from PRRating 
			 where prra_Current = 'Y' and prra_CompanyId = @comp_companyid
			-- get the new rating id that was just created

			--SELECT @NewRatingId = prra_RatingId FROM PRRating where prra_Current = 'Y' and prra_CompanyId = @comp_companyid
			-- Now add back any valid Rating Numerals

			INSERT INTO PRRatingNumeralAssigned
				(pran_RatingNumeralAssignedId, pran_Deleted, pran_WorkflowId, pran_Secterr,
						 pran_CreatedBy, pran_CreatedDate, pran_UpdatedBy, pran_UpdatedDate, pran_TimeStamp,
						 pran_RatingId, pran_RatingNumeralId)
				SELECT NULL, NULL, pran_WorkflowId, pran_Secterr,  
						 @UserId, @NOW, @UserId, @NOW, @NOW,
						 @NewRatingId, pran_RatingNumeralId
				  FROM PRRatingNumeralAssigned
				 WHERE pran_RatingId = @OldRatingId 
				   AND pran_RatingNumeralId not in (select prrn_RatingNumeralId from @tblAutoRemove )
	

			UPDATE PRRating SET prra_Current = null WHERE prra_RatingID = @OldRatingID;

 		    IF (@TrxId IS NOT NULL)
				UPDATE PRTransaction SET prtx_Status = 'C' WHERE prtx_TransactionId = @TrxId
			
		    -- if we made it here, commit our work
			COMMIT
			SET @ndx = @ndx+1
		END


		UPDATE Custom_Captions
		   SET capt_us = user_logon
		  FROM Users
		 WHERE user_userid = @UserId
		   AND capt_family = 'AutoRemoveRatingNumerals'
		   AND capt_code = 'User'


		UPDATE Custom_Captions
		   SET capt_us = CAST(GETDATE() as varchar(25))
		 WHERE capt_family = 'AutoRemoveRatingNumerals'
		   AND capt_code = 'Date';

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
		EXEC usp_RethrowError;
	END CATCH;

    return @CompanyCount
    SET NOCOUNT OFF
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
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[usp_AssignCompanyInvestigationMethodGroup]') AND Type IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[usp_AssignCompanyInvestigationMethodGroup]
GO

CREATE PROCEDURE dbo.usp_AssignCompanyInvestigationMethodGroup
AS
BEGIN

    DECLARE @tblCompanyMirror TABLE (
		tblid int identity, 
		comp_companyid int, 
		comp_PRInvestigationMethodGroup varchar(1), 
		newGroup varchar(1))

    SET NOCOUNT ON

    -- avoid calling updates on records that have not changed because the instead of trigger on company has to 
    -- do much more processing then we'll have to here
    INSERT INTO @tblCompanyMirror
    SELECT comp_companyId, comp_PRInvestigationMethodGroup, newGroup 
	  FROM vCompanyInvestigationMethod

    DECLARE @comp_companyid int, @newGroup char(1), @comp_PRInvestigationMethodGroup char(1)
    DECLARE @ctr int = 1

    WHILE (@ctr > 0)
    BEGIN 
        SET @comp_companyId = null
        SET @comp_PRInvestigationMethodGroup= null 
        SET @newGroup = null        

        SELECT @comp_companyid = comp_companyid,
               @comp_PRInvestigationMethodGroup = comp_PRInvestigationMethodGroup, 
               @newGroup = newGroup 
          FROM @tblCompanyMirror 
         WHERE tblid = @ctr

        IF (@comp_companyid is null)
        BEGIN
            SET @ctr = 0
        END
        
        IF (@ctr != 0)
        BEGIN

          -- only attempt an update if the value has changed
		  IF (ISNULL(@newGroup, 'x') != ISNULL(@comp_PRInvestigationMethodGroup, 'x')) BEGIN

            -- notice that changing this value does not require a transaction
            -- this is intentional; this is an internally-managed field
			--ALTER TABLE Company DISABLE TRIGGER ALL
            UPDATE Company 
			   SET comp_PRInvestigationMethodGroup = @newGroup 
             WHERE comp_CompanyId = @comp_companyid
            --ALTER TABLE Company ENABLE TRIGGER ALL
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
			Comp_Name, Comp_PRCorrTradestyle, Comp_PRBookTradestyle, 
			comp_prlistingcityid, comp_PRDataQualityTier, comp_PRAccountTier,
			comp_prSubordinationAgrProvided, comp_PRSubordinationAgrDate,
			comp_PRExcludeFSRequest, comp_PRSpecialInstruction,
			comp_PRBusinessStatus, 			
			comp_PRLegalName, comp_PROriginalName, comp_PROldName1, comp_PROldName1Date,
			comp_PROldName2, comp_PROldName2Date, comp_PROldName3, comp_PROldName3Date,
			comp_PRPublishUnloadHours, comp_PRMoralResponsibility, comp_PRSpecialhandlingInstruction,
			comp_PRHandlesInvoicing, comp_PRReceiveLRL, comp_PRTMFMAward,
			comp_PRTMFMAwardDate, comp_PRTMFMCandidate, comp_PRTMFMCandidateDate,
			comp_PRTMFMComments, comp_PRAdministrativeUsage, comp_PRInvestigationMethodGroup,
			comp_PRReceiveTES, comp_PRTESNonresponder, comp_PRCreditWorthCap,
			comp_PRCreditWorthCapReason, comp_PRConfidentialFS, comp_PRJeopardyDate,
			comp_PRLogo, comp_PRConnectionListDate, comp_PRFinancialStatementDate,
			comp_PRBusinessReport, comp_PRPrincipalsBackgroundText, comp_PRMethodSourceReceived,
			comp_PRindustryType, comp_PRCommunicationLanguage, comp_PRTradestyleFlag,
			comp_PRPublishDL, comp_DLBillFlag, comp_PRWebActivated,
			comp_PRWebActivatedDate, comp_PRServicesThroughCompanyId,
			Comp_CreatedBy, Comp_UpdatedBy, Comp_CreatedDate, Comp_UpdatedDate, Comp_Timestamp
		)
		Select 	@NewCompanyId, 'B',	@OrigHQId, Comp_PRListingStatus, 
			Comp_PRTradestyle1,	Comp_PRTradestyle2, Comp_PRTradestyle3, Comp_PRTradestyle4,
			Comp_Name, Comp_PRCorrTradestyle, Comp_PRBookTradestyle, 
			comp_prlistingcityid, comp_PRDataQualityTier, comp_PRAccountTier,
			comp_prSubordinationAgrProvided, comp_PRSubordinationAgrDate,
			comp_PRExcludeFSRequest, comp_PRSpecialInstruction,
			comp_PRBusinessStatus, 
			comp_PRLegalName, comp_PROriginalName, comp_PROldName1, comp_PROldName1Date,
			comp_PROldName2, comp_PROldName2Date, comp_PROldName3, comp_PROldName3Date,
			comp_PRPublishUnloadHours, comp_PRMoralResponsibility, comp_PRSpecialhandlingInstruction,
			comp_PRHandlesInvoicing, comp_PRReceiveLRL, comp_PRTMFMAward,
			comp_PRTMFMAwardDate, comp_PRTMFMCandidate, comp_PRTMFMCandidateDate,
			comp_PRTMFMComments, comp_PRAdministrativeUsage, comp_PRInvestigationMethodGroup,
			comp_PRReceiveTES, comp_PRTESNonresponder, comp_PRCreditWorthCap,
			comp_PRCreditWorthCapReason, comp_PRConfidentialFS, comp_PRJeopardyDate,
			comp_PRLogo, comp_PRConnectionListDate, comp_PRFinancialStatementDate,
			comp_PRBusinessReport, comp_PRPrincipalsBackgroundText, comp_PRMethodSourceReceived,
			comp_PRindustryType, comp_PRCommunicationLanguage, comp_PRTradestyleFlag,
			comp_PRPublishDL, comp_DLBillFlag, comp_PRWebActivated,
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
		UPDATE PhoneLink 
		SET PLink_RecordID = @NewCompanyId,
			PLink_UpdatedBy=@UserId, PLink_UpdatedDate=@Now
		WHERE PLink_RecordID = @OrigHQId 
		 AND PLink_EntityId = 5;

		UPDATE Phone 
		SET phon_CompanyID = @NewCompanyId,
			phon_UpdatedBy=@UserId, phon_UpdatedDate=@Now
		WHERE phon_CompanyID = @OrigHQId
		  AND phon_CompanyID IS NOT NULL;


		-- Move any email/web information to the new company
		UPDATE EmailLink 
		SET ELink_RecordID = @NewCompanyId,
			ELink_UpdatedBy=@UserId, ELink_UpdatedDate=@Now
		WHERE ELink_RecordID = @OrigHQId 
		AND ELink_EntityId = 5;

		UPDATE Email 
		SET emai_CompanyID = @NewCompanyId,
			emai_UpdatedBy=@UserId, emai_UpdatedDate=@Now
		WHERE emai_CompanyID = @OrigHQId
		  AND emai_CompanyID IS NOT NULL;


		-- Move any classification information to the new company
		UPDATE PRCompanyClassification 
		SET prc2_companyid = @NewCompanyId,
			prc2_UpdatedBy=@UserId, prc2_UpdatedDate=@Now
		WHERE prc2_companyid = @OrigHQId 

		-- Move any commodity information to the new company
		UPDATE PRCompanyCommodityAttribute 
		SET prcca_companyid = @NewCompanyId,
			prcca_UpdatedBy=@UserId, prcca_UpdatedDate=@Now
		WHERE prcca_companyid = @OrigHQId 

		-- Move any descriptine line information to the new company
		UPDATE PRDescriptiveLine 
		SET prdl_companyid = @NewCompanyId,
			prdl_UpdatedBy=@UserId, prdl_UpdatedDate=@Now
		WHERE prdl_companyid = @OrigHQId 


		-- Move any unload hours information to the new company
		UPDATE PRUnloadHours 
		SET pruh_companyid = @NewCompanyId,
			pruh_UpdatedBy=@UserId, pruh_UpdatedDate=@Now
		WHERE pruh_companyid = @OrigHQId 

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
			comp_prlistingcityid=c.comp_prlistingcityid, 
			comp_PRDataQualityTier=c.comp_PRDataQualityTier, 
			comp_PRAccountTier=c.comp_PRAccountTier,
			comp_prSubordinationAgrProvided=c.comp_prSubordinationAgrProvided, 
			comp_PRSubordinationAgrDate=c.comp_PRSubordinationAgrDate,
			comp_PRExcludeFSRequest=c.comp_PRExcludeFSRequest, 
			comp_PRSpecialInstruction=c.comp_PRSpecialInstruction,
			comp_PRBusinessStatus=c.comp_PRBusinessStatus, 
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
		UPDATE PhoneLink 
		SET PLink_RecordID = @OrigHQId,
			PLink_UpdatedBy=@UserId, PLink_UpdatedDate=@Now
		WHERE PLink_RecordID = @BranchId 
		 AND PLink_EntityId = 5;
		
		UPDATE Phone
		SET phon_CompanyID = @OrigHQId,
			phon_UpdatedBy=@UserId, phon_UpdatedDate=@Now
		WHERE phon_CompanyID = @BranchId
		  AND phon_CompanyID IS NOT NULL;

		-- Move any email/web information to the HQ rec
		UPDATE EmailLink 
		SET ELink_RecordID = @OrigHQId,
			ELink_UpdatedBy=@UserId, ELink_UpdatedDate=@Now
		WHERE ELink_RecordID = @BranchId 
		AND ELink_EntityId = 5;

		UPDATE Email 
		SET emai_CompanyID = @OrigHQId,
			emai_UpdatedBy=@UserId, emai_UpdatedDate=@Now
		WHERE emai_CompanyID = @BranchId
		  AND emai_CompanyID IS NOT NULL;

		-- Move any classification information to the HQ rec
		UPDATE PRCompanyClassification 
		SET prc2_companyid = @OrigHQId,
			prc2_UpdatedBy=@UserId, prc2_UpdatedDate=@Now
		WHERE prc2_companyid = @BranchId 

		-- Move any commodity information to the HQ rec
		UPDATE PRCompanyCommodityAttribute 
		SET prcca_companyid = @OrigHQId,
			prcca_UpdatedBy=@UserId, prcca_UpdatedDate=@Now
		WHERE prcca_companyid = @BranchId 

		-- Move any descriptine line information to the HQ rec
		UPDATE PRDescriptiveLine 
		SET prdl_companyid = @OrigHQId,
			prdl_UpdatedBy=@UserId, prdl_UpdatedDate=@Now
		WHERE prdl_companyid = @BranchId 

		-- Move any descriptine line information to the HQ rec
		UPDATE PRUnloadHours 
		SET pruh_companyid = @OrigHQId,
			pruh_UpdatedBy=@UserId, pruh_UpdatedDate=@Now
		WHERE pruh_companyid = @BranchId 

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


	DECLARE @DateTime datetime = GETDATE()
	DECLARE @AssignedToUserID int

    SET @Return = 0
    
    IF (@comp_PRTMFMAwarded = 'N' or @comp_PRTMFMAwarded is NULL)
    BEGIN
        -- get the original values
        SELECT @orig_PRTMFMAwarded = comp_PRTMFMAward, 
		       @orig_PRType = comp_PRType
          FROM Company WITH (NOLOCK)
         WHERE comp_CompanyId = @comp_CompanyId;

        IF (@orig_PRTMFMAwarded = 'Y' AND @orig_PRType = 'H')
        BEGIN
			DECLARE @BranchCount int, @Index int, @BranchID int, @TrxId int
			DECLARE @Branches table (
				Ndx int identity(1,1) Primary Key,
				BranchID int
			)

			INSERT INTO @Branches (BranchID)
			SELECT comp_CompanyID 
			  FROM Company WITH (NOLOCK)
			 WHERE comp_PRHQID = @comp_CompanyId
               AND comp_PRType = 'B'
               AND comp_PRTMFMAward = 'Y'
			   AND comp_Deleted IS NULL;

			SET @BranchCount = @@ROWCOUNT
			SET @Index = 0

			WHILE (@Index < @BranchCount) BEGIN
				SET @Return = 1
				SET @Index = @Index + 1

				SELECT @BranchID = BranchID
				  FROM @Branches
				 WHERE Ndx = @Index;

				-- Open a transaction
				EXEC @TrxId = usp_CreateTransaction 
					  		  @UserId = @UserId,
							  @prtx_CompanyId = @BranchID,
							  @prtx_Explanation = 'TM/FM status removed because of HQ removal.'

				-- Remove the branch's TMFM Award.				
				UPDATE Company
				   SET comp_PRTMFMAward     = NULL,
                       comp_PRTMFMAwardDate = NULL,
					   comp_UpdatedBy       = @UserID,
					   comp_UpdatedDate     = @DateTime,
					   comp_Timestamp       = @DateTime
				 WHERE comp_CompanyID = @BranchID;

				SET @AssignedToUserID = dbo.ufn_GetPRCoSpecialistUserId(@BranchID, 4)  --CSR
				SET @DateTime = GETDATE()

				EXEC usp_CreateTask @StartDateTime = @DateTime, 
									@DueDateTime = @DateTime, 
									@CreatorUserId = @UserID, 
									@AssignedToUserId = @AssignedToUserID, 
									@TaskNotes = 'TM Status has been removed from the HQ.  Please review this record and cancel any outstanding services in MAS.',	
									@RelatedCompanyId = @BranchID,	
									@Status = 'Pending',
									@Action = 'Note',
									@PRCategory = 'CS',
									@PRSubcategory = 'CAN',
									@Subject = 'TM status removed from HQ. Analyst to review record.';

				-- close the opened transaction
				UPDATE PRTransaction SET prtx_Status = 'C' WHERE prtx_TransactionId = @TrxId
			END
        END
    END    

    UPDATE Company 
       SET comp_PRTMFMAward = @comp_PRTMFMAwarded, 
	       comp_PRTMFMAwardDate = @comp_PRTMFMAwardedDate,
           comp_PRTMFMCandidate = @comp_PRTMFMCandidate, 
		   comp_PRTMFMCandidateDate = @comp_PRTMFMCandidateDate,
           comp_PRTMFMComments = @comp_PRTMFMComments
     WHERE comp_companyid = @comp_CompanyId;

    return @Return    
END
GO
/******************************************************************************
 *   Procedure: usp_SetCompanyPersonsStatus
 *
 *   Return: Int value number of Person_link reocrds updated.
 *
 *   Decription:  This procedure (called from trg_Company_upd) 
 *                sets the peli_PRStatus field to the indicated value
 *                for any person associated with the passed company id
 *                All updates must be wrapped in a transaction. 
 *
 *****************************************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_SetCompanyPersonsStatus]') 
            and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_SetCompanyPersonsStatus]
GO

CREATE PROCEDURE dbo.usp_SetCompanyPersonsStatus
  @comp_CompanyId int,
  @StatusValue varchar(40),
  @UserId int = -1
AS
BEGIN
    -- all person link records associated with this company
	-- need to have their status set to inactive.  We must do 
	-- them one at a time because each update will require a 
	-- corresponding transaction record to be created.

	DECLARE @Count int, @Index int, @PeliId int, @PersonId int, @PeliPRStatus int, @TrxId int
	DECLARE @PersonLink table (
		Ndx int identity(1,1) Primary Key,
		peli_PersonLinkId int,
		peli_PersonId int,
		peli_PRStatus nvarchar(40)
	)

	INSERT INTO @PersonLink (peli_PersonLinkId, peli_PersonId, peli_PRStatus)
	SELECT peli_PersonLInkId, peli_PersonId, peli_PRStatus 
	  FROM Person_Link WITH (NOLOCK)
	 WHERE peli_CompanyId = @comp_CompanyId;
	 
	SET @Count = @@ROWCOUNT
	SET @Index = 1

	WHILE (@Index <= @Count) BEGIN
		SELECT @PeliId = peli_PersonLinkId, @PersonId = peli_PersonId, @PeliPRStatus = peli_PRStatus
		  FROM @PersonLink
		 WHERE Ndx = @Index;

		-- Don't bother if the person already has a status of '3'
		IF @PeliPRStatus <> '3' BEGIN
			-- Open a transaction
			EXEC @TrxId = usp_CreateTransaction 
							@UserId = @UserId,
							@prtx_PersonId = @PersonId,
							@prtx_Explanation = 'Person status change due to company delisting.'

			-- Set the Person Link status.				
			UPDATE Person_Link
			   SET peli_PRStatus = @StatusValue,
				   peli_PREndDate = case when @StatusValue = 1 then null else DATEPART(Year, getdate()) end,
				   peli_UpdatedBy       = @UserID,
				   peli_UpdatedDate     = GETDATE(),
				   peli_Timestamp       = GETDATE()
			 WHERE peli_PersonLinkId = @PeliId;

			-- close the opened transaction
			UPDATE PRTransaction SET prtx_Status = 'C' WHERE prtx_TransactionId = @TrxId;
		End

		SET @Index = @Index + 1
	END
	
	-- return the number of recs updated.
    RETURN @Count
END
GO

/******************************************************************************
 *   Procedure: usp_ReplicateCompany
 *
 *   Return: Int value indicating success or failure.
 *
 *   Decription:  This procedure performs a Save-As of an existing company including
 *                a new BBID, with all other data on the record they started the transaction on, copied over to the new record.
 *				  Including: all contact information, classifications, commodities, DL, parenthetical, profile data (if a HQ record).
 *				  It would not copy over the people - the user would need to handle people records separately.
 *				  Also includes Specie, Service, and Product
 *
 *   For Defect 4329
 *****************************************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_ReplicateCompany]') 
            and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].usp_ReplicateCompany
GO

CREATE PROCEDURE dbo.usp_ReplicateCompany
  @comp_CompanyId int = null,
  @comp_PRHQId int = null, --HQ if null, branch if populated
  @UserId int = -1
AS
BEGIN
    DECLARE @Return int
    DECLARE @Msg varchar(2000)

    SET @Return = 0

	SET NOCOUNT ON
	SET ANSI_WARNINGS OFF
    
    IF (@comp_CompanyId IS NULL)
    BEGIN
        SET @Msg = 'Replicate Failed.  The Company Id could not be determined.'
        RAISERROR (@Msg, 16, 1)
        Return 1
    End

	DECLARE @new_comp_prtype varchar(10) = NULL

	IF @comp_PRHQId IS NULL BEGIN 
		SET @new_comp_prtype = 'H'
	END
	ELSE
	BEGIN
		SET @new_comp_prtype = 'B'
	END
    
	BEGIN TRY
		BEGIN TRANSACTION
			--------------------------------------
			-- Company
			--------------------------------------
			DECLARE @NextID int
			DECLARE @new_Comp_CompanyId int
			EXEC usp_GetNextId 'Company', @new_Comp_CompanyId output

			INSERT INTO Company 
			(
					Comp_CompanyId,
					comp_PRHQId,
					comp_PRType,
					comp_PRListingStatus,
					Comp_PrimaryPersonId,Comp_PrimaryAddressId,Comp_PrimaryUserId,Comp_Name,Comp_Status,Comp_Source,Comp_Territory,Comp_Revenue,Comp_Employees,Comp_Sector,Comp_IndCode,Comp_WebSite,Comp_MailRestriction,Comp_CreatedBy,Comp_CreatedDate,Comp_UpdatedBy,Comp_UpdatedDate,Comp_TimeStamp,Comp_Deleted,Comp_LibraryDir,Comp_SegmentID,Comp_ChannelID,Comp_SecTerr,Comp_WorkflowId,Comp_UploadDate,comp_SLAId,comp_PRCorrTradestyle,comp_PRBookTradestyle,comp_PRSubordinationAgrProvided,comp_PRSubordinationAgrDate,comp_PRRequestFinancials,comp_PRSpecialInstruction,comp_PRDataQualityTier,comp_PRListingCityId,comp_PRAccountTier,comp_PRBusinessStatus,comp_PRTradestyle1,comp_PRTradestyle2,comp_PRTradestyle3,comp_PRTradestyle4,comp_PRLegalName,comp_PROriginalName,comp_PROldName1,comp_PROldName1Date,comp_PROldName2,comp_PROldName2Date,comp_PROldName3,comp_PROldName3Date,comp_Type,comp_PRUnloadHours,comp_PRPublishUnloadHours,comp_PRMoralResponsibility,comp_PRSpecialHandlingInstruction,comp_PRHandlesInvoicing,comp_PRReceiveLRL,comp_PRTMFMAward,comp_PRTMFMAwardDate,comp_PRTMFMCandidate,comp_PRTMFMCandidateDate,comp_PRTMFMComments,comp_PRAdministrativeUsage,comp_PRInvestigationMethodGroup,comp_PRReceiveTES,comp_PRTESNonresponder,comp_PRCreditWorthCap,comp_PRCreditWorthCapReason,comp_PRConfidentialFS,comp_PRJeopardyDate,comp_PRLogo,comp_PRUnattributedOwnerPct,comp_PRUnattributedOwnerDesc,comp_PRConnectionListDate,comp_PRFinancialStatementDate,comp_PRBusinessReport,comp_PRPrincipalsBackgroundText,comp_PRMethodSourceReceived,comp_PRIndustryType,comp_PRCommunicationLanguage,comp_PRTradestyleFlag,comp_PRPublishDL,comp_DLBillFlag,comp_PRWebActivated,comp_PRWebActivatedDate,comp_PRReceivesBBScoreReport,comp_PRReceiveCSSurvey,comp_PRReceivePromoFaxes,comp_PRReceivePromoEmails,comp_PRServicesThroughCompanyId,comp_PRLastVisitDate,comp_PRLastVisitedBy,comp_PRListedDate,comp_PRDelistedDate,comp_PREBBTermsAcceptedDate,comp_PRLastPublishedCSDate,comp_PREBBTermsAcceptedBy,comp_PRExcludeFSRequest,comp_PRUnconfirmed,comp_PRSessionTrackerIDCheckDisabled,comp_PRIsEligibleForEquifaxData,comp_PRTradeAssociationLogo,comp_PRNAWLAID,comp_PRLastLRLLetterDate,comp_PRReceiveTESCode,comp_PRPublishPayIndicator,Comp_PrimaryAccountId,comp_intforeignid,comp_intid,comp_intlastsyncdate,comp_promote,comp_PRDLCountWhenListed,comp_PRPublishLogo,comp_PRLogoChangedDate,comp_PRLogoChangedBy,comp_PRHideLinkedInWidget,comp_PRServiceStartDate,comp_PRServiceEndDate,comp_PROriginalServiceStartDate,comp_PRExcludeAsEquifaxSubject,comp_PROnlineOnly,Comp_OptOut,comp_PRLocalSource,comp_PRARReportAccess,comp_PRHasCustomPersonSort,comp_PRExcludeFromLocalSource,comp_PRRetailerOnlineOnly,comp_PRImporter,comp_PRIsIntlTradeAssociation,comp_PRExcludeFromIntlTA,comp_PROnlineOnlyReasonCode,comp_PRHasITAAccess,Comp_IntegratedSystems,comp_PRPublishBBScore,comp_PRIgnoreTES
			) 
			SELECT	@new_Comp_CompanyId, 
					@comp_PRHQId,
					@new_comp_prtype,
					'N2', --Not Listed - Listing Membership Prospect
					Comp_PrimaryPersonId,Comp_PrimaryAddressId,Comp_PrimaryUserId,Comp_Name,Comp_Status,Comp_Source,Comp_Territory,Comp_Revenue,Comp_Employees,Comp_Sector,Comp_IndCode,Comp_WebSite,Comp_MailRestriction,Comp_CreatedBy,Comp_CreatedDate,Comp_UpdatedBy,Comp_UpdatedDate,Comp_TimeStamp,Comp_Deleted,Comp_LibraryDir,Comp_SegmentID,Comp_ChannelID,Comp_SecTerr,Comp_WorkflowId,Comp_UploadDate,comp_SLAId,comp_PRCorrTradestyle,comp_PRBookTradestyle,comp_PRSubordinationAgrProvided,comp_PRSubordinationAgrDate,comp_PRRequestFinancials,comp_PRSpecialInstruction,comp_PRDataQualityTier,comp_PRListingCityId,comp_PRAccountTier,comp_PRBusinessStatus,comp_PRTradestyle1,comp_PRTradestyle2,comp_PRTradestyle3,comp_PRTradestyle4,comp_PRLegalName,comp_PROriginalName,comp_PROldName1,comp_PROldName1Date,comp_PROldName2,comp_PROldName2Date,comp_PROldName3,comp_PROldName3Date,comp_Type,comp_PRUnloadHours,comp_PRPublishUnloadHours,comp_PRMoralResponsibility,comp_PRSpecialHandlingInstruction,comp_PRHandlesInvoicing,comp_PRReceiveLRL,comp_PRTMFMAward,comp_PRTMFMAwardDate,comp_PRTMFMCandidate,comp_PRTMFMCandidateDate,comp_PRTMFMComments,comp_PRAdministrativeUsage,comp_PRInvestigationMethodGroup,comp_PRReceiveTES,comp_PRTESNonresponder,comp_PRCreditWorthCap,comp_PRCreditWorthCapReason,comp_PRConfidentialFS,comp_PRJeopardyDate,comp_PRLogo,comp_PRUnattributedOwnerPct,comp_PRUnattributedOwnerDesc,comp_PRConnectionListDate,comp_PRFinancialStatementDate,comp_PRBusinessReport,comp_PRPrincipalsBackgroundText,comp_PRMethodSourceReceived,comp_PRIndustryType,comp_PRCommunicationLanguage,comp_PRTradestyleFlag,comp_PRPublishDL,comp_DLBillFlag,comp_PRWebActivated,comp_PRWebActivatedDate,comp_PRReceivesBBScoreReport,comp_PRReceiveCSSurvey,comp_PRReceivePromoFaxes,comp_PRReceivePromoEmails,comp_PRServicesThroughCompanyId,comp_PRLastVisitDate,comp_PRLastVisitedBy,comp_PRListedDate,comp_PRDelistedDate,comp_PREBBTermsAcceptedDate,comp_PRLastPublishedCSDate,comp_PREBBTermsAcceptedBy,comp_PRExcludeFSRequest,comp_PRUnconfirmed,comp_PRSessionTrackerIDCheckDisabled,comp_PRIsEligibleForEquifaxData,comp_PRTradeAssociationLogo,comp_PRNAWLAID,comp_PRLastLRLLetterDate,comp_PRReceiveTESCode,comp_PRPublishPayIndicator,Comp_PrimaryAccountId,comp_intforeignid,comp_intid,comp_intlastsyncdate,comp_promote,comp_PRDLCountWhenListed,comp_PRPublishLogo,comp_PRLogoChangedDate,comp_PRLogoChangedBy,comp_PRHideLinkedInWidget,comp_PRServiceStartDate,comp_PRServiceEndDate,comp_PROriginalServiceStartDate,comp_PRExcludeAsEquifaxSubject,comp_PROnlineOnly,Comp_OptOut,comp_PRLocalSource,comp_PRARReportAccess,comp_PRHasCustomPersonSort,comp_PRExcludeFromLocalSource,comp_PRRetailerOnlineOnly,comp_PRImporter,comp_PRIsIntlTradeAssociation,comp_PRExcludeFromIntlTA,comp_PROnlineOnlyReasonCode,comp_PRHasITAAccess,Comp_IntegratedSystems,comp_PRPublishBBScore,comp_PRIgnoreTES
			FROM Company WITH (NOLOCK) WHERE Comp_CompanyId = @comp_CompanyId

			DECLARE @IndustryType varchar(10)
			SELECT @IndustryType = comp_PRIndustryType FROM Company WITH (NOLOCK) WHERE comp_CompanyId = @comp_CompanyId

			--Triggers may have interfered with PRHQID so set it explicitly
			EXEC('DISABLE TRIGGER dbo.trg_Company_ioupd ON dbo.Company'); 
			IF @new_comp_prtype='B' BEGIN
				UPDATE Company SET comp_PRHQId = @comp_PRHQId, Comp_CreatedDate=GETDATE(), Comp_UpdatedDate=GETDATE() WHERE comp_CompanyId=@new_Comp_CompanyId
			END
			ELSE BEGIN
				UPDATE Company SET comp_PRHQId = @new_Comp_CompanyId, Comp_CreatedDate=GETDATE(), Comp_UpdatedDate=GETDATE() WHERE comp_CompanyId=@new_Comp_CompanyId
			END
			EXEC('ENABLE TRIGGER dbo.trg_Company_ioupd ON dbo.Company'); 
			--------------------------------------
			-- PRCompanyAlias
			--------------------------------------
			DECLARE @Count int
			DECLARE @Index int

			DECLARE @Temp_Alias TABLE
			(
				inx int identity,
				pral_CompanyId int,
				pral_Alias varchar(104),
				pral_NameAlphaOnly varchar(104),
				pral_AliasMatch varchar(104)
			)
			INSERT INTO @Temp_Alias
			SELECT pral_CompanyId,
				pral_Alias,
				pral_NameAlphaOnly,
				pral_AliasMatch
			FROM PRCompanyAlias WHERE pral_CompanyId=@comp_CompanyId

			
			SET @Count = @@ROWCOUNT
			SET @Index=0
			WHILE (@Index < @Count) BEGIN
				SET @Index = @Index + 1

				EXEC('DISABLE TRIGGER dbo.trg_PRCompanyAlias_insdel ON dbo.PRCompanyAlias'); 

				EXEC usp_GetNextId 'PRCompanyAlias', @NextID output
				DECLARE @pral_Alias varchar(104)
				DECLARE @pral_NameAlphaOnly varchar(104)
				DECLARE @pral_AliasMatch varchar(104)
				SELECT	@pral_Alias=pral_alias,
						@pral_NameAlphaOnly=pral_NameAlphaOnly,
						@pral_AliasMatch=pral_AliasMatch
				FROM @Temp_Alias WHERE inx=@Index

				INSERT INTO PRCompanyAlias (pral_CompanyAliasId, pral_CompanyId, pral_Alias, pral_NameAlphaOnly, pral_AliasMatch)
					VALUES (@NextId, @new_Comp_CompanyId, @pral_Alias, @pral_NameAlphaOnly, @pral_AliasMatch)
			END
			EXEC('ENABLE TRIGGER dbo.trg_PRCompanyAlias_insdel ON dbo.PRCompanyAlias'); 

			--------------------------------------
			-- PRCompanyProfile
			--------------------------------------
			IF @new_comp_prtype = 'H' BEGIN
				EXEC('DISABLE TRIGGER dbo.trg_PRCompanyProfile_ioupd ON dbo.PRCompanyProfile'); 

				EXEC usp_GetNextId 'PRCompanyProfile', @NextID output
				INSERT INTO PRCompanyProfile(prcp_CompanyProfileId, prcp_Deleted,prcp_WorkflowId,prcp_Secterr,prcp_CreatedBy,prcp_CreatedDate,prcp_UpdatedBy,prcp_UpdatedDate,prcp_TimeStamp,prcp_CompanyId,prcp_MigratedProfileDescription,prcp_CorporateStructure,prcp_Volume,prcp_FTEmployees,prcp_PTEmployees,prcp_SrcBuyBrokersPct,prcp_SrcBuyWholesalePct,prcp_SrcBuyShippersPct,prcp_SrcBuyExportersPct,prcp_SellBrokersPct,prcp_SellWholesalePct,prcp_SellDomesticBuyersPct,prcp_SellExportersPct,prcp_SellBuyOthers,prcp_SellDomesticAccountTypes,prcp_BkrTakeTitlePct,prcp_BkrTakePossessionPct,prcp_BkrCollectPct,prcp_BkrTakeFrieght,prcp_BkrConfirmation,prcp_BkrReceive,prcp_BkrGroundInspections,prcp_TrkrDirectHaulsPct,prcp_TrkrTPHaulsPct,prcp_TrkrProducePct,prcp_TrkrOtherColdPct,prcp_TrkrOtherWarmPct,prcp_TrkrTeams,prcp_TrkrTrucksOwned,prcp_TrkrTrucksLeased,prcp_TrkrTrailersOwned,prcp_TrkrTrailersLeased,prcp_TrkrPowerUnits,prcp_TrkrReefer,prcp_TrkrDryVan,prcp_TrkrFlatbed,prcp_TrkrPiggyback,prcp_TrkrTanker,prcp_TrkrContainer,prcp_TrkrOther,prcp_TrkrLiabilityAmount,prcp_TrkrLiabilityCarrier,prcp_TrkrCargoAmount,prcp_TrkrCargoCarrier,prcp_StorageWarehouses,prcp_StorageSF,prcp_StorageCF,prcp_StorageBushel,prcp_StorageCarlots,prcp_ColdStorage,prcp_RipeningStorage,prcp_HumidityStorage,prcp_AtmosphereStorage,prcp_ColdStorageLeased,prcp_HAACP,prcp_HAACPCertifiedBy,prcp_QTV,prcp_QTVCertifiedBy,prcp_Organic,prcp_OrganicCertifiedBy,prcp_OtherCertification,prcp_SellFoodWholesaler,prcp_SellRetailGrocery,prcp_SellInstitutions,prcp_SellRestaurants,prcp_SellMilitary,prcp_SellDistributors,prcp_BkrCollectRemitForShipper,prcp_SrcTakePhysicalPossessionPct,prcp_SellShippingSeason,prcp_TrkBkrCollectsFreightPct,prcp_TrkBkrPaymentFreightPct,prcp_TrkBkrCollectsFrom,prcp_TrkBkrResponsibleForPaymentOfClaims,prcp_TrnBkrArrangesTransportation,prcp_TrnBkrAdvPaymentsToCarrier,prcp_TrnBkrCollectsFrom,prcp_TrnLogAdvPaymentsToCarrier,prcp_TrnLogCollectsFrom,prcp_TrnLogResponsibleForPaymentOfClaims,prcp_FrtLiableForPaymentToCarrier,prcp_SellCoOpPct,prcp_SellRetailYardPct,prcp_SellOtherPct,prcp_SellHomeCenterPct,prcp_SellOfficeWholesalePct,prcp_SellProDealerPct,prcp_SellSecManPct,prcp_SellStockingWholesalePct,prcp_SrcBuyMillsPct,prcp_SrcBuyOfficeWholesalePct,prcp_SrcBuyOtherPct,prcp_SrcBuySecManPct,prcp_SrcBuyStockingWholesalePct,prcp_VolumeBoardFeetPerYear,prcp_VolumeTruckLoadsPerYear,prcp_VolumeCarLoadsPerYear,prcp_StorageCoveredSF,prcp_StorageUncoveredSF,prcp_RailServiceProvider1,prcp_RailServiceProvider2,prcp_SalvageDistressedProduce,prcp_StorageOwnLease,prcp_SellBuyOthersPct,prcp_GrowsOwnProducePct,prcp_FoodSafetyCertified)
					SELECT @NextID, prcp_Deleted,prcp_WorkflowId,prcp_Secterr,prcp_CreatedBy,prcp_CreatedDate,prcp_UpdatedBy,prcp_UpdatedDate,prcp_TimeStamp,@new_Comp_CompanyId,prcp_MigratedProfileDescription,prcp_CorporateStructure,prcp_Volume,prcp_FTEmployees,prcp_PTEmployees,prcp_SrcBuyBrokersPct,prcp_SrcBuyWholesalePct,prcp_SrcBuyShippersPct,prcp_SrcBuyExportersPct,prcp_SellBrokersPct,prcp_SellWholesalePct,prcp_SellDomesticBuyersPct,prcp_SellExportersPct,prcp_SellBuyOthers,prcp_SellDomesticAccountTypes,prcp_BkrTakeTitlePct,prcp_BkrTakePossessionPct,prcp_BkrCollectPct,prcp_BkrTakeFrieght,prcp_BkrConfirmation,prcp_BkrReceive,prcp_BkrGroundInspections,prcp_TrkrDirectHaulsPct,prcp_TrkrTPHaulsPct,prcp_TrkrProducePct,prcp_TrkrOtherColdPct,prcp_TrkrOtherWarmPct,prcp_TrkrTeams,prcp_TrkrTrucksOwned,prcp_TrkrTrucksLeased,prcp_TrkrTrailersOwned,prcp_TrkrTrailersLeased,prcp_TrkrPowerUnits,prcp_TrkrReefer,prcp_TrkrDryVan,prcp_TrkrFlatbed,prcp_TrkrPiggyback,prcp_TrkrTanker,prcp_TrkrContainer,prcp_TrkrOther,prcp_TrkrLiabilityAmount,prcp_TrkrLiabilityCarrier,prcp_TrkrCargoAmount,prcp_TrkrCargoCarrier,prcp_StorageWarehouses,prcp_StorageSF,prcp_StorageCF,prcp_StorageBushel,prcp_StorageCarlots,prcp_ColdStorage,prcp_RipeningStorage,prcp_HumidityStorage,prcp_AtmosphereStorage,prcp_ColdStorageLeased,prcp_HAACP,prcp_HAACPCertifiedBy,prcp_QTV,prcp_QTVCertifiedBy,prcp_Organic,prcp_OrganicCertifiedBy,prcp_OtherCertification,prcp_SellFoodWholesaler,prcp_SellRetailGrocery,prcp_SellInstitutions,prcp_SellRestaurants,prcp_SellMilitary,prcp_SellDistributors,prcp_BkrCollectRemitForShipper,prcp_SrcTakePhysicalPossessionPct,prcp_SellShippingSeason,prcp_TrkBkrCollectsFreightPct,prcp_TrkBkrPaymentFreightPct,prcp_TrkBkrCollectsFrom,prcp_TrkBkrResponsibleForPaymentOfClaims,prcp_TrnBkrArrangesTransportation,prcp_TrnBkrAdvPaymentsToCarrier,prcp_TrnBkrCollectsFrom,prcp_TrnLogAdvPaymentsToCarrier,prcp_TrnLogCollectsFrom,prcp_TrnLogResponsibleForPaymentOfClaims,prcp_FrtLiableForPaymentToCarrier,prcp_SellCoOpPct,prcp_SellRetailYardPct,prcp_SellOtherPct,prcp_SellHomeCenterPct,prcp_SellOfficeWholesalePct,prcp_SellProDealerPct,prcp_SellSecManPct,prcp_SellStockingWholesalePct,prcp_SrcBuyMillsPct,prcp_SrcBuyOfficeWholesalePct,prcp_SrcBuyOtherPct,prcp_SrcBuySecManPct,prcp_SrcBuyStockingWholesalePct,prcp_VolumeBoardFeetPerYear,prcp_VolumeTruckLoadsPerYear,prcp_VolumeCarLoadsPerYear,prcp_StorageCoveredSF,prcp_StorageUncoveredSF,prcp_RailServiceProvider1,prcp_RailServiceProvider2,prcp_SalvageDistressedProduce,prcp_StorageOwnLease,prcp_SellBuyOthersPct,prcp_GrowsOwnProducePct,prcp_FoodSafetyCertified
				FROM PRCompanyProfile WHERE prcp_CompanyId = @comp_CompanyId
			END
			EXEC('ENABLE TRIGGER dbo.trg_PRCompanyProfile_ioupd ON dbo.PRCompanyProfile'); 

			--------------------------------------
			-- CompanyAddress
			--------------------------------------
			DECLARE @Temp_Address TABLE
			(
				inx int identity,
				Addr_AddressId int
			)
			INSERT INTO @Temp_Address (Addr_AddressId)
				SELECT Addr_AddressId FROM Address 
				INNER JOIN Address_Link on Addr_AddressId = AdLi_AddressId
				WHERE adli_companyid = @comp_CompanyId

			SET @Count = @@ROWCOUNT
			SET @Index=0

			WHILE (@Index < @Count) BEGIN
				SET @Index = @Index + 1
				DECLARE @Addr_AddressId int
				SELECT @Addr_AddressId = Addr_AddressId FROM @Temp_Address WHERE inx=@Index
				EXEC dbo.usp_ReplicateCompanyAddress @comp_companyid, @Addr_AddressId , @new_Comp_CompanyId, @UserId
			END

			--------------------------------------
			-- CompanyPhone
			--------------------------------------
			DECLARE @Temp_Phone TABLE
			(
				inx int identity,
				Phon_PhoneId int
			)
			INSERT INTO @Temp_Phone (Phon_PhoneId)
				SELECT Phon_PhoneId FROM Phone
					INNER JOIN PhoneLink on phon_phoneid = PLink_PhoneId
				WHERE plink_RecordID = @comp_CompanyId

			SET @Count = @@ROWCOUNT
			SET @Index=0

			WHILE (@Index < @Count) BEGIN
				SET @Index = @Index + 1
				DECLARE @Phon_PhoneId int
				SELECT @Phon_PhoneId = Phon_PhoneId FROM @Temp_Phone WHERE inx=@Index
				EXEC dbo.usp_ReplicateCompanyPhone @comp_companyid, @Phon_PhoneId, @new_Comp_CompanyId, @UserId
			END

			--------------------------------------
			-- Other
			--------------------------------------
			EXEC dbo.usp_ReplicateCompanyEmailWeb @comp_companyid, null, @new_Comp_CompanyId, @UserId
			EXEC dbo.usp_ReplicateCompanyBrand @comp_companyid, null, @new_Comp_CompanyId, @UserId
			EXEC dbo.usp_ReplicateCompanyClassification @comp_companyid, null, @new_Comp_CompanyId, @UserId
			
			IF @IndustryType = 'L' BEGIN
				EXEC dbo.usp_ReplicateCompanySpecie @comp_companyid, null, @new_Comp_CompanyId, @UserId
				EXEC dbo.usp_ReplicateCompanyServiceProvided @comp_companyid, null, @new_Comp_CompanyId, @UserId
				EXEC dbo.usp_ReplicateCompanyProductProvided @comp_companyid, null, @new_Comp_CompanyId, @UserId				
			END

			IF @IndustryType = 'P' BEGIN
				EXEC dbo.usp_ReplicateCompanyCommodity @comp_companyid, null, @new_Comp_CompanyId, @UserId
			END

			EXEC dbo.usp_ReplicateCompanyNote @comp_companyid, @new_Comp_CompanyId

			-- if we made it here, commit our work
			SET @Return = @new_Comp_CompanyId
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

	RETURN @Return
	--SELECT @Return NewBBID
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

	DECLARE @Type varchar(40),
			@EmailAddress varchar(255),
			@WebAddress varchar(255),
			@Description varchar(50),
			@Publish char(1),
			@PreferredInternal char(1),
			@PreferredPublish char(1),
			@Sequence int = 0

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

		  INSERT INTO @tblEmail
		  SELECT Emai_EmailId
		    FROM vCompanyEmail WITH (NOLOCK)
		   WHERE ELink_RecordID = @comp_CompanyId
	    ORDER BY emai_PRSequence;
			
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
				EXEC @TrxId = usp_CreateTransaction 
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
						SET @LinkedEmailId = NULL
						SELECT @LinkedEmailId = emai_emailid 
						  FROM vCompanyEmail WITH (NOLOCK)
						 WHERE ELink_RecordID = @RepCompanyId 
						   AND emai_PRReplicatedFromId = @SourceId
			            
						IF (@LinkedEmailId IS NOT NULL)
						BEGIN
							-- Update
							PRINT 'Updating id ' + convert(varchar,@LinkedEmailId)
							UPDATE Email SET
								emai_UpdatedBy = @UserId,
								emai_UpdatedDate = @Now,
								emai_EmailAddress = a_EmailAddress,
								emai_PRWebAddress = a_PRWebAddress,
								emai_PRDescription = a_PRDescription,
								emai_PRPublish = a_PRPublish,
								emai_PRSequence = a_PRSequence
							FROM (
								SELECT 
									a_EmailAddress = emai_EmailAddress,
									a_PRWebAddress = emai_PRWebAddress,
									a_PRDescription = emai_PRDescription,
									a_PRPublish = emai_PRPublish,
									a_PRSequence = emai_PRSequence
								FROM Email WITH (NOLOCK)
								WHERE emai_EmailId = @SourceId
							) ATable
							WHERE emai_emailid = @LinkedEmailId

							UPDATE EmailLink SET
								elink_UpdatedBy = @UserId,
								elink_UpdatedDate = @Now,
								elink_Type = a_Type
							FROM (
								SELECT 
									a_Type = elink_Type
								FROM EmailLink WITH (NOLOCK)
								WHERE ELink_EmailId = @SourceId
							) ATable
							WHERE ELink_EmailId = @LinkedEmailId


						END
						ELSE
						BEGIN

							SELECT @EmailAddress = emai_EmailAddress,
							       @WebAddress = emai_PRWebAddress,
							       @Description = emai_PRDescription, 
								   @Publish =emai_PRPublish, 
								   @Sequence = emai_PRSequence,
								   @PreferredInternal = emai_PRPreferredInternal, 
								   @PreferredPublish = emai_PRPreferredPublished
							  FROM Email
							 WHERE emai_EmailId = @SourceId      

                            SELECT @Type = elink_Type
							  FROM EmailLink
							 WHERE ELink_EmailId = @SourceId

							EXEC usp_InsertEmail @RepCompanyId, 5, @Type,
												 @EmailAddress, @WebAddress, @Description,
												 @Publish, @PreferredInternal, @PreferredPublish,
												 @Sequence, @SourceId, @UserId

							-- Insert
							/*
							EXEC usp_GetNextId 'Email', @NextId output

							PRINT 'Inserting id ' + convert(varchar,@NextId )
							INSERT INTO Email 
							 ( emai_EmailId,emai_CompanyId,
							   emai_CreatedBy,emai_createdDate,emai_UpdatedBy,emai_UpdatedDate,emai_TimeStamp,
							   emai_Type,emai_EmailAddress,emai_PRWebAddress,
							   emai_PRDescription,emai_PRPublish,emai_PRSequence,
							   emai_PRReplicatedFromId, emai_PRPreferredInternal, emai_PRPreferredPublished
							 )  
							SELECT 
								@NextId,@RepCompanyId,
								@UserId,@Now,@UserId,@Now,@Now,  
								emai_Type,emai_EmailAddress,emai_PRWebAddress,
								emai_PRDescription,emai_PRPublish,emai_PRSequence,
								@SourceId, emai_PRPreferredInternal, emai_PRPreferredPublished
							FROM Email
							WHERE emai_EmailId = @SourceId       
							*/
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

	DECLARE @Type varchar(40),
			@CountryCode varchar(5),
			@AreaCode varchar(20),
			@Number varchar(34),
			@Description varchar(34),
			@Extension varchar(34),
			@International varchar(1),
			@CityCode varchar(5),
			@Disconnected char(1),
			@Publish char(1),
			@PreferredInternal char(1),
			@PreferredPublish char(1),
			@Sequence int = 0


    DECLARE @NextId int

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
			SELECT @token = token FROM @tblReplicateTo WHERE idx = @Loopidx;

			IF (@token is not null)
			BEGIN
				-- convert the token to a company id int value
				SET @RepCompanyId = convert(int, @token)
				-- Open a transaction
				EXEC @TrxId = usp_CreateTransaction 
								@UserId = @UserId,
								@prtx_CompanyId = @RepCompanyId,
								@prtx_Explanation = 'Transaction created by Phone Replication.'

				SET @LinkedPhoneId = NULL
				SELECT @LinkedPhoneId = phon_phoneid 
				  FROM vPRCompanyPhone WITH (NOLOCK)
				 WHERE plink_REcordID = @RepCompanyId
				   AND phon_PRReplicatedFromId = @SourceId;
	            
				SET @Now = getDate()
	            
				IF (@LinkedPhoneId IS NOT NULL)
				BEGIN
					-- Update
					Update Phone SET
						phon_UpdatedBy = @UserId,
						phon_UpdatedDate = @Now,
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
						FROM PHONE WITH (NOLOCK)
						WHERE phon_PhoneId = @SourceId
					) ATable
					WHERE phon_phoneid = @LinkedPhoneId;

					UPDATE PhoneLink SET
						plink_UpdatedBy = @UserId,
						plink_UpdatedDate = @Now,
						plink_Type = a_Type
					FROM (
						SELECT 
							a_Type = plink_Type
						FROM PhoneLink WITH (NOLOCK)
						WHERE PLink_PhoneId = @SourceId
					) ATable
					WHERE PLink_PhoneId = @LinkedPhoneId


				END
				ELSE
				BEGIN

					SELECT @CountryCode = Phon_CountryCode,
							@AreaCode = Phon_AreaCode,
							@Number = Phon_Number, 
							@Description =phon_PRDescription, 
							@Extension = phon_PRExtension,
							@International = phon_PRInternational,
							@CityCode = phon_PRCityCode,
							@Disconnected = phon_PRDisconnected,
							@Publish = phon_PRPublish,
							@PreferredInternal = phon_PRPreferredInternal, 
							@PreferredPublish = phon_PRPreferredPublished, 
							@Sequence = phon_PRSequence
						FROM Phone
						WHERE phon_phoneid = @SourceId;       

                    SELECT @Type = PLink_Type
						FROM PhoneLink
						WHERE PLink_PhoneId = @SourceId

					EXEC usp_InsertPhone @RepCompanyId, 5, @Type,
										@CountryCode, @AreaCode, @Number, @Description, @Extension,
										@International, @CityCode, @Disconnected,
										@Publish, @PreferredInternal, @PreferredPublish,
										@Sequence, @SourceId, @UserId

/*
					-- Insert
				    exec usp_GetNextId 'Phone', @NextId output

					INSERT INTO Phone 
					 ( phon_PhoneId,phon_CompanyId,
					   phon_CreatedBy,phon_createdDate,phon_UpdatedBy,phon_UpdatedDate,phon_TimeStamp,
					   phon_Type,phon_CountryCode,phon_AreaCode,phon_Number,
					   phon_PRDescription,phon_PRExtension,phon_PRInternational,
					   phon_PRCityCode,phon_PRPublish, phon_PRDisconnected,phon_PRSequence,
					   phon_PRReplicatedFromId, phon_PRPreferredInternal, phon_PRPreferredPublished
					 )  
					SELECT 
						@NextId,@RepCompanyId,
						@UserId,@Now,@UserId,@Now,@Now,  
						phon_Type,phon_CountryCode,phon_AreaCode,phon_Number,
						phon_PRDescription,phon_PRExtension,phon_PRInternational,
						phon_PRCityCode,phon_PRPublish,phon_PRDisconnected,phon_PRSequence,
						@SourceId, phon_PRPreferredInternal, phon_PRPreferredPublished
					FROM Phone WITH (NOLOCK)
					WHERE phon_phoneid = @SourceId;       
*/	        
				END

				UPDATE PRTransaction SET prtx_Status = 'C' WHERE prtx_TransactionId = @TrxId;
	            
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
    
    -- Address field value that will be copied
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
				EXEC @TrxId = usp_CreateTransaction 
								@UserId = @UserId,
								@prtx_CompanyId = @RepCompanyId,
								@prtx_Explanation = 'Transaction created by Address Replication.'

				SET @LinkedAddrId = NULL
				SELECT @LinkedAddrId = addr_addressid 
				  FROM Address WITH (NOLOCK)
				       INNER JOIN Address_Link WITH (NOLOCK) ON adli_AddressId = addr_AddressId 
				                                             AND adli_CompanyId = @RepCompanyId
				 WHERE addr_PRReplicatedFromId = @SourceId;
	            
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
					FROM Address WITH (NOLOCK)
					     INNER JOIN Address_Link WITH (NOLOCK) ON adli_addressId = addr_AddressId
					WHERE addr_AddressId = @SourceId;

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
					WHERE addr_addressid = @LinkedAddrId;
					
					UPDATE Address_Link SET
						adli_UpdatedBy = @UserId,
						adli_UpdatedDate = @Now,
						adli_Type	= @adli_Type
					WHERE adli_addressid = @LinkedAddrId;
				END
				ELSE
				BEGIN



					-- Insert
				    exec usp_GetNextId 'Address', @NextAddrId output
				    exec usp_GetNextId 'Address_Link', @NextAdliId output

					INSERT INTO Address
					 ( addr_AddressId,
					   addr_CreatedBy,addr_createdDate,addr_UpdatedBy,addr_UpdatedDate,addr_TimeStamp,
						addr_Address1,addr_Address2,addr_Address3,addr_Address4,addr_Address5,
						addr_City,addr_State,addr_Country,addr_PostCode,addr_uszipplusfour,
						addr_PRCityId,addr_PRCounty,addr_PRZone,addr_PRPublish,addr_PRDescription,
						addr_PRReplicatedFromId, addr_PRLatitude, addr_PRLongitude
					 )  
					SELECT 
						@NextAddrId,
						@UserId,@Now,@UserId,@Now,@Now,  
						addr_Address1,addr_Address2,addr_Address3,addr_Address4,addr_Address5,
						addr_City,addr_State,addr_Country,addr_PostCode,addr_uszipplusfour,
						addr_PRCityId,addr_PRCounty,addr_PRZone,addr_PRPublish,addr_PRDescription,
						@SourceId, addr_PRLatitude, addr_PRLongitude
					FROM Address WITH (NOLOCK)
					WHERE addr_addressid = @SourceId;       

					INSERT INTO Address_Link 
					 ( adli_AddressLinkId,adli_CompanyId,adli_AddressId,
					   adli_CreatedBy,adli_createdDate,adli_UpdatedBy,adli_UpdatedDate,adli_TimeStamp,
						adli_Type,
						adli_PRDefaultMailing,
						adli_PRDefaultTax
					 )  
					SELECT 
						@NextAdliId,@RepCompanyId,@NextAddrId,
						@UserId,@Now,@UserId,@Now,@Now,  
						adli_Type,
	                    dbo.ufn_GetAddressReplicationTargetDefault(adli_PRDefaultMailing, @RepCompanyId, 0),
						dbo.ufn_GetAddressReplicationTargetDefault(adli_PRDefaultTax, @RepCompanyId, 2)
					FROM Address_Link WITH (NOLOCK)
					WHERE adli_addressid = @SourceId;       
				END
	        
				UPDATE PRTransaction SET prtx_Status = 'C' WHERE prtx_TransactionId = @TrxId;
	            
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

CREATE PROCEDURE [dbo].[usp_ReplicateCompanyCommodity]
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
    DECLARE @tblCAs TABLE(
		ndx smallint identity, 
        ca_CommodityId int, 
		ca_GrowingMethodId int, 
		ca_AttributeId int, 
        ca_Publish nchar(1), 
		ca_PublishWithGM nchar(1), 
		ca_PublishedDisplay varchar(200), 
		ca_Sequence int)    

    INSERT INTO @tblCAs 
    SELECT prcca_CommodityId, prcca_GrowingMethodId, prcca_AttributeId, prcca_Publish,
           prcca_PublishWithGM, prcca_PublishedDisplay, prcca_Sequence
      FROM PRCompanyCommodityAttribute 
     WHERE prcca_CompanyId = @SourceId


    DECLARE @ndxCA smallint
    DECLARE @ca_CommodityId int, @ca_GrowingMethodId int, @ca_AttributeId int, @ca_Sequence int,
            @ca_Publish nchar(1), @ca_PublishWithGM nchar(1), @ca_PublishedDisplay varchar(200)

    DECLARE @RepCompanyId int
    DECLARE @NextPRCCAId int
    DECLARE @NextSequence int
            
    SET @Now = GETDATE()

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
				-- convert the token to a company id int value and get the sequence number
				SET @RepCompanyId = convert(int, @token)
				SET @NextSequence = null;
				SELECT @NextSequence = MAX(prcca_Sequence) + 1 
				  FROM PRCompanyCommodityAttribute 
				 WHERE prcca_CompanyId = @RepCompanyID

				SET @NextSequence = Coalesce(@NextSequence, 1);

				-- Open a transaction
				EXEC @TrxId = usp_CreateTransaction 
								@UserId = @UserId,
								@prtx_CompanyId = @RepCompanyId,
								@prtx_Explanation = 'Transaction created by Commodity Replication.'

				-- Get the first CommodityAttribute in the list
				SET @ndxCA = 1
				While (@ndxCA > 0)
				BEGIN
					SET @ca_CommodityId = null;
					SELECT @ca_CommodityId = ca_CommodityId, 
					       @ca_GrowingMethodId = ca_GrowingMethodId,
						   @ca_AttributeId = ca_AttributeId, 
						   @ca_Publish = ca_Publish, 
						   @ca_PublishWithGM = ca_PublishWithGM, 
						   @ca_PublishedDisplay = ca_PublishedDisplay,
						   @ca_Sequence = ca_Sequence
					  FROM @tblCAs 
					 WHERE ndx = @ndxCA
					
					IF (@ca_CommodityId is null)
						SET @ndxCA = -1
					ELSE
					BEGIN
						-- Determine if the rep company already handles this commoidty/attribute
						IF EXISTS(SELECT 'x' 
						           FROM PRCompanyCommodityAttribute 
								  WHERE prcca_companyid = @RepCompanyId 
								    AND prcca_CommodityId = @ca_CommodityId
									AND ISNULL(prcca_GrowingMethodId, 0) = ISNULL(@ca_GrowingMethodId, 0)
									AND ISNULL(prcca_AttributeId, 0) = ISNULL(@ca_AttributeId, 0))
						BEGIN
							UPDATE PRCompanyCommodityAttribute SET 
								   prcca_UpdatedBy = @UserId,
								   prcca_UpdatedDate = @Now,
								   prcca_TimeStamp = @Now,
								   prcca_Publish = @ca_Publish,
								   prcca_PublishWithGM = @ca_PublishWithGM,
								   prcca_Sequence = @ca_Sequence
							 WHERE prcca_companyid = @RepCompanyId
							   AND prcca_CommodityId = @ca_CommodityId
							   AND ISNULL(prcca_GrowingMethodId, 0) = ISNULL(@ca_GrowingMethodId, 0)
							   AND ISNULL(prcca_AttributeId, 0) = ISNULL(@ca_AttributeId, 0);

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
							EXEC usp_GetNextId 'PRCompanyCommodityAttribute', @NextPRCCAId output
							INSERT INTO PRCompanyCommodityAttribute
							( prcca_CompanyCommodityAttributeId,
								prcca_CreatedBy,prcca_createdDate,prcca_UpdatedBy,prcca_UpdatedDate,prcca_TimeStamp,
								prcca_CompanyId, prcca_CommodityId, prcca_GrowingMethodId, prcca_AttributeId,								
								prcca_Publish, prcca_PublishWithGM, prcca_PublishedDisplay, prcca_Sequence
							)  
							VALUES ( 
								@NextPRCCAId,
								@UserId, @Now, @UserId, @Now, @Now,  
								@RepCompanyId, @ca_CommodityId, @ca_GrowingMethodId, @ca_AttributeId,
								@ca_Publish, @ca_PublishWithGM, @ca_PublishedDisplay, @ca_Sequence
							)       

							IF @@ERROR <> 0
							BEGIN
    							ROLLBACK
								SET @Msg = 'Insert Failed.  Error creating the PRCompanyCommodityAttribute record.' 
								RAISERROR(@Msg,16,1)
    							RETURN -3
							END

							SET @NextSequence = @NextSequence + 1;
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
	DECLARE @RepType varchar(40)

    DECLARE @NextPRC2Id int
            
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

				SELECT @RepType = comp_PRType FROM Company WITH (NOLOCK) WHERE comp_CompanyID=@RepCompanyId;

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
								prc2_NumberOfStores = CASE @RepType WHEN 'B' THEN NULL ELSE @prc2_NumberOfStores END,
								prc2_ComboStores = CASE @RepType WHEN 'B' THEN NULL ELSE @prc2_ComboStores END,
								prc2_NumberOfComboStores = CASE @RepType WHEN 'B' THEN NULL ELSE @prc2_NumberOfComboStores END,
								prc2_ConvenienceStores	= CASE @RepType WHEN 'B' THEN NULL ELSE @prc2_ConvenienceStores END,
								prc2_NumberOfConvenienceStores = CASE @RepType WHEN 'B' THEN NULL ELSE @prc2_NumberOfConvenienceStores END,
								prc2_GourmetStores = CASE @RepType WHEN 'B' THEN NULL ELSE @prc2_GourmetStores END,
								prc2_NumberOfGourmetStores = CASE @RepType WHEN 'B' THEN NULL ELSE @prc2_NumberOfGourmetStores END,
								prc2_HealthFoodStores = CASE @RepType WHEN 'B' THEN NULL ELSE @prc2_HealthFoodStores END,
								prc2_NumberOfHealthFoodStores = CASE @RepType WHEN 'B' THEN NULL ELSE @prc2_NumberOfHealthFoodStores END,
								prc2_ProduceOnlyStores = CASE @RepType WHEN 'B' THEN NULL ELSE @prc2_ProduceOnlyStores END,
								prc2_NumberOfProduceOnlyStores = CASE @RepType WHEN 'B' THEN NULL ELSE @prc2_NumberOfProduceOnlyStores END,
								prc2_SupermarketStores =CASE @RepType WHEN 'B' THEN NULL ELSE @prc2_SupermarketStores END,
								prc2_NumberOfSupermarketStores = CASE @RepType WHEN 'B' THEN NULL ELSE @prc2_NumberOfSupermarketStores END,
								prc2_SuperStores = CASE @RepType WHEN 'B' THEN NULL ELSE @prc2_SuperStores END,
								prc2_NumberOfSuperStores = CASE @RepType WHEN 'B' THEN NULL ELSE @prc2_NumberOfSuperStores END,
								prc2_WarehouseStores = CASE @RepType WHEN 'B' THEN NULL ELSE @prc2_WarehouseStores END,
								prc2_NumberOfWarehouseStores = CASE @RepType WHEN 'B' THEN NULL ELSE @prc2_NumberOfWarehouseStores END,
								prc2_AirFreight = @prc2_AirFreight,
								prc2_OceanFreight = @prc2_OceanFreight,
								prc2_GroundFreight = @prc2_GroundFreight,
								prc2_RailFreight = @prc2_RailFreight
							WHERE prc2_CompanyId = @RepCompanyId AND prc2_ClassificationId = @prc2_ClassificationId
						END
						ELSE
						BEGIN
							-- Insert
						    exec usp_GetNextId 'PRCompanyClassification', @NextPRC2Id output

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
								prc2_Percentage, prc2_PercentageSource, CASE @RepType WHEN 'B' THEN NULL ELSE prc2_NumberOfStores END,
								CASE @RepType WHEN 'B' THEN NULL ELSE prc2_ComboStores END, CASE @RepType WHEN 'B' THEN NULL ELSE prc2_NumberOfComboStores END, 
								CASE @RepType WHEN 'B' THEN NULL ELSE prc2_ConvenienceStores END, CASE @RepType WHEN 'B' THEN NULL ELSE prc2_NumberOfConvenienceStores END, 
								CASE @RepType WHEN 'B' THEN NULL ELSE prc2_GourmetStores END, CASE @RepType WHEN 'B' THEN NULL ELSE prc2_NumberOfGourmetStores END,
								CASE @RepType WHEN 'B' THEN NULL ELSE prc2_HealthFoodStores END, CASE @RepType WHEN 'B' THEN NULL ELSE prc2_NumberOfHealthFoodStores END,
								CASE @RepType WHEN 'B' THEN NULL ELSE prc2_ProduceOnlyStores END, CASE @RepType WHEN 'B' THEN NULL ELSE prc2_NumberOfProduceOnlyStores END,
								CASE @RepType WHEN 'B' THEN NULL ELSE prc2_SupermarketStores END, CASE @RepType WHEN 'B' THEN NULL ELSE prc2_NumberOfSupermarketStores END,
								CASE @RepType WHEN 'B' THEN NULL ELSE prc2_SuperStores END, CASE @RepType WHEN 'B' THEN NULL ELSE prc2_NumberOfSuperStores END,
								CASE @RepType WHEN 'B' THEN NULL ELSE prc2_WarehouseStores END, CASE @RepType WHEN 'B' THEN NULL ELSE prc2_NumberOfWarehouseStores END,
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

/******************************************************************************
 *   Procedure: usp_ReplicateCompanyNote
 *
 *   Return: Int value indicating success or failure.
 *
 *   Decription:  This procedure applies the note id (@SourceId) to the list of    
 *                notes passed in the @ReplicateToIds parm.  If the record
 *                has been previously replicated, it is updated. Otherwise, it is
 *                created as a new company address with link record.  All updates 
 *                must be wrapped in a transaction. If a trx cannot be opened, all fail.
 *
 *****************************************************************************/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_ReplicateCompanyNote]') 
            and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_ReplicateCompanyNote]
GO

CREATE PROCEDURE dbo.usp_ReplicateCompanyNote
  @SourceCompanyId int = null,
  @TargetCompanyId int = null
AS
BEGIN
	DECLARE @Return int
    DECLARE @Msg varchar(2000)

    SET @Return = 0
    
    IF (@SourceCompanyId IS NULL)
    BEGIN
        SET @Msg = 'Updates Failed.  The SourceCompanyId could not be determined.'
        RAISERROR (@Msg, 16, 1)
        Return 1
    END
    
    IF (@TargetCompanyId IS NULL)
    BEGIN
        -- should never be here but return 0 because nothing went wrong
        Return 0
    END
    
	BEGIN TRY
		BEGIN TRANSACTION
			DECLARE @RowCount int
			DECLARE @Ndx int
			DECLARE @CompanyId int
			DECLARE @NoteType varchar(50)
			DECLARE @NoteNote varchar(max)

			DECLARE @PRCompanyNotes TABLE
			(
				ID int identity(1,1) PRIMARY KEY,
				prcomnot_CompanyId int,
				prcomnot_CompanyNoteType varchar(50),
				prcomnot_CompanyNoteNote varchar(max)
			)
			INSERT INTO @PRCompanyNotes (prcomnot_CompanyId, prcomnot_CompanyNoteType, prcomnot_CompanyNoteNote )
				SELECT prcomnot_CompanyId, prcomnot_CompanyNoteType, prcomnot_CompanyNoteNote FROM PRCompanyNote WHERE prcomnot_companyid = @SourceCompanyId

			SET @RowCount = @@ROWCOUNT
			SET @Ndx = 0
			WHILE (@Ndx < @RowCount) BEGIN
				SET @Ndx = @Ndx + 1
				-- Go get the next Note
				SELECT	@CompanyID = prcomnot_CompanyId,
						@NoteType=prcomnot_CompanyNoteType,
						@NoteNote=prcomnot_CompanyNoteNote
				FROM @PRCompanyNotes
 				WHERE ID = @Ndx;

				DECLARE @NextID int
				EXEC usp_GetNextId 'PRCompanyNote', @NextID output
				INSERT INTO PRCompanyNote (prcomnot_CompanyNoteId, prcomnot_CreatedBy, prcomnot_CreatedDate, prcomnot_UpdatedBy, prcomnot_UpdatedDate, prcomnot_CompanyId, prcomnot_CompanyNoteType, prcomnot_CompanyNoteNote)
					VALUES (@NextID, -1, GETDATE(), -1, GETDATE(), @TargetCompanyId, @NoteType, @NoteNote)
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

    return @Return    
END
GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_ReplicateCompanyBrand]') 
            and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_ReplicateCompanyBrand]
GO

CREATE PROCEDURE dbo.usp_ReplicateCompanyBrand
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
    
    -- Brand field values that will be copied
	DECLARE @prc3_CompanyBrandId int
    DECLARE @prc3_Brand	int
    DECLARE @prc3_Description varchar(max)
    DECLARE @prc3_ViewableImageLocation	varchar(100)
    DECLARE @prc3_PrintableImageLocation varchar(100)
    DECLARE @prc3_OwningCompany	varchar(100)
    DECLARE @prc3_Publish nchar(1)
    DECLARE @prc3_Sequence	int

    -- Create a local table for the Brands to be unioned
    DECLARE @tblBrand TABLE(ndx smallint identity, Brand varchar(34), Sequence int)   
    DECLARE @ndxBrand smallint
    DECLARE @Brand varchar(34)
	DECLARE @Sequence int

    INSERT INTO @tblBrand 
		SELECT prc3_Brand, prc3_Sequence
		FROM PRCompanyBrand 
		WHERE prc3_CompanyId = @SourceId 
		ORDER BY prc3_Sequence

    DECLARE @RepCompanyId int

    DECLARE @NextPRC2Id int
            
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
				EXEC @TrxId = usp_CreateTransaction 
								@UserId = @UserId,
								@prtx_CompanyId = @RepCompanyId,
								@prtx_Explanation = 'Transaction created by Brand Replication.'
				-- Process the Brands
				SET @ndxBrand = 1
				While (@ndxBrand > 0)
				BEGIN
					SET @Brand = null
					SET @Sequence = null

					SELECT	@Brand=Brand, 
							@Sequence=Sequence
					  FROM @tblBrand 
					 WHERE ndx=@ndxBrand

					IF (@Brand IS NULL)
						SET @ndxBrand = -1
					ELSE 
					BEGIN
						IF (Exists( SELECT 1 FROM PRCompanyBrand
									WHERE prc3_CompanyId = @RepCompanyId 
									AND prc3_Brand = @Brand 
									AND prc3_Sequence = @Sequence))
						BEGIN
							SELECT 
								@prc3_Description = prc3_Description,
								@prc3_ViewableImageLocation = prc3_ViewableImageLocation,
								@prc3_PrintableImageLocation = prc3_PrintableImageLocation,
								@prc3_OwningCompany = prc3_OwningCompany,
								@prc3_Publish = prc3_Publish,
								@prc3_Sequence= prc3_Sequence
							FROM PRCompanyBrand
							WHERE prc3_CompanyId = @SourceId 
							  AND prc3_Brand = @Brand
							  AND prc3_Sequence = @Sequence

							-- Update
							Update PRCompanyBrand SET
								prc3_UpdatedBy = @UserId,
								prc3_UpdatedDate = @Now,
								prc3_Description = @prc3_Description,
								prc3_ViewableImageLocation = @prc3_ViewableImageLocation,
								prc3_PrintableImageLocation = @prc3_PrintableImageLocation,
								prc3_OwningCompany = @prc3_OwningCompany,
								prc3_Publish = @prc3_Publish,
								prc3_Sequence	= @prc3_Sequence
							WHERE prc3_CompanyId = @RepCompanyId 
							  AND prc3_Brand = @Brand
							  AND prc3_Sequence = @Sequence
						END
						ELSE
						BEGIN
							-- Insert
						    exec usp_GetNextId 'PRCompanyBrand', @NextPRC2Id output

							INSERT INTO PRCompanyBrand
							( prc3_CompanyBrandId, prc3_CompanyId, prc3_Brand,
							   prc3_CreatedBy,prc3_createdDate,prc3_UpdatedBy,prc3_UpdatedDate,prc3_TimeStamp,
								prc3_Description, prc3_ViewableImageLocation, prc3_PrintableImageLocation,
								prc3_OwningCompany, prc3_Publish, prc3_Sequence,
								prc3_PRReplicatedFromId
							)  
							SELECT 
								@NextPRC2Id, @RepCompanyId, @Brand,
								@UserId,@Now,@UserId,@Now,@Now,
								prc3_Description, prc3_ViewableImageLocation, prc3_PrintableImageLocation,
								prc3_OwningCompany, prc3_Publish, @Sequence,
								prc3_CompanyBrandId
							FROM PRCompanyBrand
							WHERE prc3_CompanyId = @SourceId AND prc3_Brand = @Brand AND prc3_Sequence = @Sequence
						END

						SET @ndxBrand = @ndxBrand + 1
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
	INSERT INTO @ImportTable 
		SELECT min(pril_ImportPACALicenseId), pril_LicenseNumber 
		FROM PRImportPACALicense
		GROUP BY pril_LicenseNumber 
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
		-- *** Warning: if the prpa_Current = 'Y' is removed from the statement below (and this has
		--              been discussed), usp_CreatePACAFromImport must also be modified to 
		--              appropiately determine the comp-companyid and prpa_PACALicenseId values
		SELECT @ExistingPACALicenseId=prpa_PACALicenseId, @ExistingPACACompany=prpa_CompanyId 
		  FROM PRPACALicense 
		 WHERE prpa_LicenseNumber = @pril_LicenseNumber and prpa_Current = 'Y'


		IF (@ExistingPACALicenseId IS NOT NULL)
		BEGIN
			-- There is an existing paca record with this number so we are going to "mark the current as deleted"
			-- for history and create this new import record directly into the PRPACALicense table
			exec @NewLicenseId = usp_CreatePACAFromImport 
											@pril_ImportPACALicenseId = @pril_LicenseId ,
											@prpa_PACALicenseId = @ExistingPACALicenseId,
											@UserId = @UserId,
											@DeleteImport = 1,
											@SendNotifications = 1,
											@Type = 2
			IF( @NewLicenseId is not NULL)
			BEGIN
				SET @AutoConvertedCount = @AutoConvertedCount + 1

				-- Update PRPACAComplaint record to point to the new LicenseID that is now Current='Y'
				UPDATE PRPACAComplaint SET prpac_PACALicenseID = @NewLicenseId
				WHERE prpac_PACALicenseID = @ExistingPACALicenseID

			END
		END
		SET @ndx = @ndx + 1
	END		

    SET NOCOUNT OFF

	return @AutoConvertedCount
END
GO
/******************************************************************************
 *   Procedure: usp_PACAProcessImports2
 *
 *   Return: int - the number of import record processed into PACA License table
 *
 *   Decription:  This slight modification of usp_PACAProcessImports
 *                allows us to specify a Run date to process and 
 *				  send in a flag to indicate whether we should send 
 *				  notifications.  These to functions should be merged.
 *
 *   Note: This routine is being released in a 2.3 hotfix to catch up on PACA processing
 *****************************************************************************/
if exists (select * from dbo.sysobjects 
			where id = object_id(N'[dbo].[usp_PACAProcessImports2]') 
				and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_PACAProcessImports2]
GO

CREATE PROCEDURE dbo.usp_PACAProcessImports2
	@PACARunDate datetime = null,
	@SendNotifications bit = 0,
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
	IF (@PACARunDate is null)
		INSERT INTO @ImportTable 
			SELECT min(pril_ImportPACALicenseId), pril_LicenseNumber 
			FROM PRImportPACALicense
			GROUP BY pril_LicenseNumber 
	ELSE
		INSERT INTO @ImportTable 
			SELECT min(pril_ImportPACALicenseId), pril_LicenseNumber 
			FROM PRImportPACALicense
			WHERE pril_PACARunDate = @PACARunDate
			GROUP BY pril_LicenseNumber 

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
		-- *** Warning: if the prpa_Current = 'Y' is removed from the statement below (and this has
		--              been discussed), usp_CreatePACAFromImport must also be modified to 
		--              appropiately determine the comp-companyid and prpa_PACALicenseId values
		SELECT @ExistingPACALicenseId=prpa_PACALicenseId, @ExistingPACACompany=prpa_CompanyId 
		  FROM PRPACALicense 
		 WHERE prpa_LicenseNumber = @pril_LicenseNumber and prpa_Current = 'Y'


		IF (@ExistingPACALicenseId IS NOT NULL)
		BEGIN
			-- Determine how many records are in import because we may remove more than one during processing
			DECLARE @ProcessedCount int
			SELECT @ProcessedCount = count(1) from PRImportPACALicense where pril_LicenseNumber = @pril_LicenseNumber
			-- for history and create this new import record directly into the PRPACALicense table
			exec @NewLicenseId = usp_CreatePACAFromImport 
											@pril_ImportPACALicenseId = @pril_LicenseId ,
											@prpa_PACALicenseId = @ExistingPACALicenseId,
											@UserId = @UserId,
											@DeleteImport = 1,
											@SendNotifications = @SendNotifications,
											@Type = 2
			IF( @NewLicenseId is not NULL)
				SET @AutoConvertedCount = @AutoConvertedCount + isnull(@ProcessedCount, 1)
		END
		SET @ndx = @ndx + 1
	END		

    SET NOCOUNT OFF

	return @AutoConvertedCount
END
GO


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
CREATE PROCEDURE dbo.usp_CreateImportPACALicense
	@pril_FileName		nvarchar(50)	= null,
	@pril_ImportDate	datetime		= null,
	@pril_LicenseNumber	nvarchar(50)	= null,
	@pril_ExpirationDate datetime		= null,
	@pril_PrimaryTradeName	nvarchar(80)	= null,
	@pril_CompanyName	nvarchar(80)	= null,
	@pril_CustomerFirstName	nvarchar(80)	= null,
	@pril_CustomerMiddleInitial	nvarchar(1)	= null,
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
	@pril_Telephone		nvarchar(20)	= null,
	@pril_Email			nvarchar(255)	= null,
	@pril_WebAddress	nvarchar(255)	= null,
	@pril_Fax			nvarchar(20)	= null,
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
	declare @ExistingImportPACALicenseId	int

	-- if this license id has already been inserted from this input file,
	-- then there is most likely a termination issue to deal with.  If this is the terminate record
	-- (and it should be) delete the previously inserted License record.
	-- If this is not the terminate record just ignore it; we do not want to override the terminate rec.
	select @ExistingImportPACALicenseId = pril_ImportPACALicenseId 
	  from PRImportPACALicense WITH (NOLOCK)
	 where pril_LicenseNumber = @pril_LicenseNumber and pril_PACARunDate = @pril_PACARunDate

	if (@ExistingImportPACALicenseId is not null)
	begin
		IF (@pril_TerminateCode <> '1')
			Delete FROM PRImportPACALicense where pril_ImportPACALicenseId = @ExistingImportPACALicenseId
		else
			return 0
	end
	
	-- get a new ID for the entity
	-- exec usp_getNextId 'PRImportPACALicense', @pril_ImportPACALicenseId output
	BEGIN TRY
		BEGIN TRANSACTION;

		-- create the new Import PACA record
		INSERT INTO PRImportPACALicense
		(
			pril_CreatedBy, pril_CreatedDate, pril_UpdatedBy, pril_UpdatedDate,	pril_TimeStamp, pril_Deleted,
			pril_FileName, pril_ImportDate, pril_LicenseNumber,
			pril_ExpirationDate, pril_CompanyName, pril_Address1, pril_Address2, pril_City,
			pril_State,	pril_Country, pril_PostCode, pril_MailAddress1,	pril_MailAddress2,
			pril_MailCity, pril_MailState, pril_MailCountry, pril_MailPostCode,	pril_IncState,
			pril_IncDate, pril_OwnCode,	pril_Telephone,	pril_TerminateDate,	pril_TerminateCode,
			pril_TypeFruitVeg, pril_ProfCode, pril_PACARunDate,
			pril_PrimaryTradeName, pril_CustomerFirstName, pril_CustomerMiddleInitial,
			pril_Email, pril_WebAddress, pril_Fax
			
		) Values (
			@UserId, @Now,	@UserId, @Now,	@Now, null,
			@pril_FileName, @pril_ImportDate, @pril_LicenseNumber,
			@pril_ExpirationDate, @pril_CompanyName, @pril_Address1, @pril_Address2, @pril_City,
			@pril_State, @pril_Country, @pril_PostCode,	@pril_MailAddress1,	@pril_MailAddress2,
			@pril_MailCity,	@pril_MailState, @pril_MailCountry,	@pril_MailPostCode,	@pril_IncState,
			@pril_IncDate, @pril_OwnCode, @pril_Telephone, @pril_TerminateDate,	@pril_TerminateCode,
			@pril_TypeFruitVeg,	@pril_ProfCode,	@pril_PACARunDate,
			@pril_PrimaryTradeName, @pril_CustomerFirstName, @pril_CustomerMiddleInitial,
			@pril_Email, @pril_WebAddress, @pril_Fax
		);
		--SELECT @pril_ImportPACALicenseId = SCOPE_IDENTITY();

		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION;

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		PRINT 'ERROR'

		exec usp_RethrowError;
	END CATCH;

    SET NOCOUNT OFF

	return 0
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
CREATE PROCEDURE dbo.usp_CreateImportPACAPrincipal
	@prip_FileName		nvarchar(50)	= null,
	@prip_ImportDate	datetime		= null,
	@prip_Sequence  	int     		= null,
	@prip_LicenseNumber	nvarchar(50)	= null,
	@prip_LastName  	nvarchar(50)	= null,
	@prip_FirstName		nvarchar(20)	= null,
	@prip_MiddleInitial	nvarchar(1) 	= null,
	@prip_Title       	nvarchar(500)	= null,
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
	
	-- Do not insert duplicates from the import same file
	if Exists(
		SELECT 1 FROM PRImportPACAPrincipal WITH (NOLOCK)
		WHERE prip_FileName = @prip_FileName 
			AND prip_LicenseNumber = @prip_LicenseNumber AND prip_LastName = @prip_LastName 
			AND prip_FirstName = @prip_FirstName AND prip_Title = @prip_Title 
			AND prip_City = @prip_City AND prip_State = @prip_State AND prip_PACARunDate = @prip_PACARunDate
	)
		return 0

	-- Look up the PACA License ID
	Declare @pril_ImportPACALicenseId int
	SELECT @pril_ImportPACALicenseId = pril_ImportPACALicenseId 
	  FROM PRImportPACALicense WITH (NOLOCK)
	 WHERE pril_LicenseNumber = @prip_LicenseNumber and pril_PACARunDate = @prip_PACARunDate
	
	-- get a new ID for the entity
	--exec usp_getNextId 'PRImportPACAPrincipal', @prip_ImportPACAPrincipalId output

	-- create the new record
	INSERT INTO PRImportPACAPrincipal
	(   
		prip_CreatedBy, prip_CreatedDate, prip_UpdatedBy, prip_UpdatedDate,	prip_TimeStamp, prip_Deleted, 
		prip_FileName, prip_ImportDate, prip_ImportPACALicenseId,
        prip_Sequence, prip_LicenseNumber, prip_LastName, prip_FirstName, prip_MiddleInitial,
		prip_Title,	prip_City, prip_State, prip_PACARunDate
	) Values (
		@UserId, @Now,	@UserId, @Now,	@Now, null,
		@prip_FileName,	@prip_ImportDate, @pril_ImportPACALicenseId,
		@prip_Sequence,	@prip_LicenseNumber, @prip_LastName, @prip_FirstName, @prip_MiddleInitial,
		@prip_Title, @prip_City, @prip_State, @prip_PACARunDate
	);	
	--SELECT @prip_ImportPACAPrincipalId = SCOPE_IDENTITY();

    SET NOCOUNT OFF

	return 0
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

	-- Do not insert duplicates from the import same file
	if Exists(
		SELECT 1 FROM PRImportPACATrade WITH (NOLOCK)
		WHERE prit_FileName = @prit_FileName AND prit_LicenseNumber = @prit_LicenseNumber  
			AND prit_AdditionalTradeName = @prit_AdditionalTradeName AND prit_City = @prit_City 
			AND prit_State = @prit_State AND prit_PACARunDate = @prit_PACARunDate
	)
		return 0

	declare @prit_ImportPACATradeId	int

	-- Look up the PACA License ID
	Declare @pril_ImportPACALicenseId int
	SELECT @pril_ImportPACALicenseId = pril_ImportPACALicenseId 
	  FROM PRImportPACALicense WITH (NOLOCK)
	 WHERE pril_LicenseNumber = @prit_LicenseNumber and pril_PACARunDate = @prit_PACARunDate
	
	-- get a new ID for the entity
	--exec usp_getNextId 'PRImportPACATrade', @prit_ImportPACATradeId output

	-- create the new record
	INSERT INTO PRImportPACATrade
	(   
		prit_ImportPACALicenseId,
		prit_CreatedBy,	prit_CreatedDate, prit_UpdatedBy, prit_UpdatedDate,	prit_TimeStamp,	prit_Deleted,
		prit_FileName, prit_ImportDate,	prit_LicenseNumber,	prit_AdditionalTradeName, prit_City,
		prit_State,	prit_PACARunDate
	) Values (
		@pril_ImportPACALicenseId, 
		@UserId, @Now, @UserId, @Now, @Now, null,
		@prit_FileName,	@prit_ImportDate, @prit_LicenseNumber, @prit_AdditionalTradeName, @prit_City,
		@prit_State, @prit_PACARunDate
	);	
	--SELECT @prit_ImportPACATradeId = SCOPE_IDENTITY();
    
	SET NOCOUNT OFF

	return 0
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
CREATE OR ALTER PROCEDURE dbo.usp_CreatePACAFromImport
    @pril_ImportPACALicenseId int = NULL,
    @comp_CompanyId int = NULL,
    @prpa_PACALicenseId int = null,
    @UserId int = -1,
    @DeleteImport smallint = 0,
    @SendNotifications bit = 1,
    @Type int
as
BEGIN
    DECLARE @DEBUG bit; SET @DEBUG = 0;
	-- @Type = 0: Assign to Existing Company
    -- @Type = 1: Assign to a newly created Company
    -- @Type = 2: Assign to Existing PACA License Id
	DECLARE @Now datetime
	DECLARE @Msg varchar(2000)
    DECLARE @in_pril_LicenseNumber int
    DECLARE @TableId int
    DECLARE @NewPACALicenseId int, @NextId int;
	DECLARE @ProfCode varchar(10)
	DECLARE @Changes varchar(800), @ListingChanges varchar(800)

	SET @Now = getDate()

    IF ( @pril_ImportPACALicenseId IS NULL) 
    BEGIN
        SET @Msg = 'Update Failed.  An Import PACA License Id must be provided.'
        RAISERROR (@Msg, 16, 1)
        Return
    END

	SELECT @in_pril_LicenseNumber = pril_LicenseNumber,
	       @ProfCode = pril_ProfCode
	  FROM PRImportPACALicense 
     WHERE pril_ImportPACALicenseId = @pril_ImportPACALicenseId
	
	-- Based upon the received license number, determine if there are additional 
	-- PRImportPACALicense records with the same license number.  We will then 
	-- iterate through and process each one individually.
	DECLARE @ImportRecs table (ndx int identity, pril_ImportPACALicenseId int)
	INSERT into @ImportRecs
		select pril_ImportPACALicenseId 
          from PRImportPACALicense 
         where pril_LicenseNumber = @in_pril_LicenseNumber

/*
	IF (@in_pril_LicenseNumber IS NOT NULL)
	BEGIN
		SELECT @comp_CompanyId = prpa_CompanyId, @prpa_PACALicenseId = prpa_PACALicenseId 
		  From PRPACALicense 
		 where prpa_LicenseNumber = @in_pril_LicenseNumber	
			   AND prpa_Current = 'Y'
	END
*/
	-- if using an existing PACA License, get the associated company
	IF (@Type = 2 )
    BEGIN 
      SELECT @comp_CompanyId = prpa_CompanyId From PRPACALicense where prpa_PACALicenseId = @prpa_PACALicenseId
    END
    -- if the type is still 0, verify we have a valid company id
    IF ( @comp_companyId IS NULL ) 
    BEGIN
        SET @Msg = 'Update Failed.  Company Id for PACA LicenseId ('+ isnull(convert(varchar(12), @prpa_PACALicenseId),'NULL') + ') could not be determined. Processing record failed.'
        RAISERROR (@Msg, 16, 1)
        Return
    END
    
    -- Determine what should happen with Notifications
	DECLARE @ListingStatus varchar(40), @ListingUserId int, @RatingUserId int, @InsideSalesUserId int
	SELECT @ListingStatus = comp_PRListingStatus, 
	       @ListingUserId = prci_ListingSpecialistId,
           @RatingUserId = 1010, -- NLG
		   @InsideSalesUserId = prci_InsideSalesRepId 
	  FROM Company WITH (NOLOCK)
	       INNER JOIN vPRLocation WITH (NOLOCK) on comp_PRListingCityId = prci_CityId
	 WHERE comp_CompanyId = @comp_CompanyId


	-- DEFECT 3623 - Always send the notifiation regardless
	-- of the listing status
	-- If the company is not listed, override the SendNotification flag
	--IF (@ListingStatus != 'L') 		 
		--SET @SendNotifications = 0;
		
	-- set variables to hold messages to the recipients
	Declare @NotifyRatingUserMsg varchar(1000)
	Declare @NotifyListingUserMsg varchar(1000)
	Declare @NotifyInsideSalesUserMsg varchar(1000)
    
	-- Create temp tables to "stage" the updates to minimize the transaction size
	DECLARE @tempPRPACALicense TABLE (
		ndx int identity, prpa_PACALicenseId int ,
		prpa_CreatedBy int,	prpa_UpdatedBy int,	prpa_CompanyId int,
		prpa_LicenseNumber nvarchar(8),	prpa_Current nchar(1), prpa_Publish nchar(1), prpa_CompanyName nvarchar(80),
		prpa_PrimaryTradeName nvarchar(80), prpa_CustomerFirstName nvarchar(80), prpa_CustomerMiddleInitial nvarchar(1),
		prpa_Address1 nvarchar(64),	prpa_Address2 nvarchar(64), prpa_City nvarchar(25), prpa_State nvarchar(2),
		prpa_PostCode nvarchar(10), prpa_MailAddress1 nvarchar(64), prpa_MailAddress2 nvarchar(64),
		prpa_MailCity nvarchar(25), prpa_MailState nvarchar(2), prpa_MailPostCode nvarchar(10),
		prpa_IncState nvarchar(2), prpa_IncDate datetime, prpa_OwnCode nvarchar(40),
		prpa_Telephone nvarchar(20), prpa_TerminateDate datetime, prpa_TerminateCode nvarchar(40),
		prpa_TypeFruitVeg nvarchar(40), prpa_ProfCode nvarchar(40), 
		prpa_EffectiveDate datetime, prpa_ExpirationDate datetime,
		prpa_Email nvarchar(255), prpa_WebAddress nvarchar(255), prpa_Fax nvarchar(20)
	)	
	DECLARE @tempPRPACAPrincipal TABLE (
		ndx int identity, prpp_PACAPrincipalId int,
		prpp_CreatedBy int, prpp_UpdatedBy int, prpp_PACALicenseId int,
		prpp_LastName nvarchar(52), prpp_FirstName nvarchar(20), prpp_MiddleInitial nvarchar(1),
		prpp_Title nvarchar(500), prpp_City nvarchar(25), prpp_State nvarchar(2)
	)
	DECLARE @tempPRPACATrade TABLE (
		ndx int identity, ptrd_PACATradeId int,
		ptrd_CreatedBy int, ptrd_UpdatedBy int, ptrd_PACALicenseId int,
		ptrd_AdditionalTradeName nvarchar(80), ptrd_City nvarchar(25), ptrd_State nvarchar(2)
	)

    DECLARE @PrincipalMsg varchar (100), @TradeMsg varchar (100)
	Declare @SendToUserId int, @FinalMsg varchar(2000)

	Declare @ImportNdx int; SET @ImportNdx = 1
	Declare @ImportCount int, @LicenseCount int, @PrincipalCount int, @TradeCount int
	Declare @prpp_ndx int, @ptrd_ndx int
	SELECT @prpp_ndx = 1, @ptrd_ndx  = 1
	SELECT @ImportCount = Count(1) FROM @ImportRecs

	-- notice that this look inserts in the temp staging tables 
	WHILE (@ImportNdx <= @ImportCount)
	BEGIN
		-- reset the local variables
		DELETE FROM @tempPRPACALicense
		DELETE FROM @tempPRPACAPrincipal
		DELETE FROM @tempPRPACATrade

		SET @prpa_PACALicenseId = null
		SET @PrincipalMsg  = null
		SET @TradeMsg  = null
		SET @FinalMsg  = null
		SET @SendToUserId  = null
		
		-- get the current Import record
		SELECT @pril_ImportPACALicenseId = pril_ImportPACALicenseId 
		  FROM @ImportRecs 
		 WHERE ndx = @ImportNdx
		 
		-- get the PACALicenseId for the current record
		SELECT @prpa_PACALicenseId = prpa_PACALicenseId 
		  FROM PRPACALicense 
		 WHERE prpa_CompanyId = @comp_CompanyId AND prpa_Current = 'Y'

		-- get a new ID for the entity
		EXEC usp_getNextId 'PRPACALicense', @NewPACALicenseId output

		-- create the new PACA License record
		-- RAO: modifing to set the Publish flag when the License is imported.
		INSERT INTO @tempPRPACALicense
			(
				prpa_PACALicenseId,	prpa_CreatedBy,	prpa_UpdatedBy,	prpa_CompanyId,
				prpa_LicenseNumber,
				prpa_Current, prpa_Publish,
				prpa_CompanyName,
				prpa_PrimaryTradeName, prpa_CustomerFirstName, prpa_CustomerMiddleInitial,
				prpa_Address1, prpa_Address2, prpa_City, prpa_State, prpa_PostCode,
				prpa_MailAddress1, prpa_MailAddress2, prpa_MailCity, prpa_MailState, prpa_MailPostCode,
				prpa_IncState, prpa_IncDate, prpa_OwnCode, prpa_Telephone, prpa_TerminateDate, prpa_TerminateCode,
				prpa_TypeFruitVeg, prpa_ProfCode, 
                prpa_EffectiveDate, prpa_ExpirationDate,
                prpa_Email, prpa_WebAddress, prpa_Fax
			)
			SELECT 	@NewPACALicenseId, @UserId, @UserId, @comp_CompanyId,
				pril_LicenseNumber,
				'Y', case when pril_TerminateCode IN ('1', '4') then 'Y' else null end,
				pril_CompanyName,
				pril_PrimaryTradeName, pril_CustomerFirstName, pril_CustomerMiddleInitial,
				pril_Address1, pril_Address2, pril_City, pril_State, pril_PostCode,
				pril_MailAddress1, pril_MailAddress2, pril_MailCity, pril_MailState, pril_MailPostCode,
				pril_IncState, pril_IncDate, pril_OwnCode, pril_Telephone, pril_TerminateDate, pril_TerminateCode,
				pril_TypeFruitVeg, pril_ProfCode,
                pril_PACARunDate, pril_ExpirationDate,
                pril_Email, pril_WebAddress, pril_Fax
			FROM PRImportPACALicense 
			WHERE pril_ImportPACALicenseId = @pril_ImportPACALicenseId;
			
		SET @LicenseCount = @@ROWCOUNT

		-- Get the associated PRImportPACAPrincipal recs
		INSERT INTO @tempPRPACAPrincipal
		(
			prpp_PACAPrincipalId, prpp_CreatedBy, prpp_UpdatedBy, prpp_PACALicenseId,
			prpp_LastName, prpp_FirstName, prpp_MiddleInitial,
			prpp_Title, prpp_City, prpp_State
		) SELECT 
				NULL, @UserId, @UserId, @NewPACALicenseId,
				prip_LastName, prip_FirstName, prip_MiddleInitial,
				prip_Title, prip_City, prip_State
			FROM PRImportPACAPrincipal
		   WHERE prip_ImportPACALicenseId = @pril_ImportPACALicenseId
		SET @PrincipalCount = @@ROWCOUNT + @prpp_ndx

		-- start easy... if the counts don't match, have the Rating analyst review
		SELECT @PrincipalMsg = case when count(1) != (@PrincipalCount - @prpp_ndx) then 'Principals' else null end 
		  FROM PRPACAPrincipal 
		 WHERE prpp_PACALicenseId = @prpa_PACALicenseId
		
		-- create a primary key for when the rec is inserted for real, again, outside of the trx
		While (@prpp_ndx < @PrincipalCount)
		BEGIN
			--PRINT @prpp_ndx
			exec usp_getNextId 'PRPACAPrincipal', @NextId output
			Update @tempPRPACAPrincipal SET prpp_PACAPrincipalId = @NextId WHERE ndx = @prpp_ndx
			-- As soon as a changed rec is identified, we can stop checking
			IF ( @PrincipalMsg IS NULL)
			BEGIN
				-- Check the existing, current PACA Principal records to verify this value
				-- combo exists; if it doesn't trigger this as a change
				IF NOT EXISTS (select 1
					  FROM PRPACAPrincipal a, @tempPRPACAPrincipal b
					 WHERE ndx = @prpp_ndx
					   AND a.prpp_PACALicenseId = @prpa_PACALicenseId
					   AND (
							(ISNULL(a.prpp_lastname,'') = ISNULL(b.prpp_lastname,'')) AND
							(ISNULL(a.prpp_firstname,'') = ISNULL(b.prpp_firstname,'')) AND
							(ISNULL(a.prpp_title,'') = ISNULL(b.prpp_title,'')) 
							)
				)
					SET @PrincipalMsg = 'Principals'
			END
			SET @prpp_ndx = @prpp_ndx + 1
		END

		-- Get the associated PRImportPACATrade recs
		INSERT INTO @tempPRPACATrade
		(
			ptrd_PACATradeId, ptrd_CreatedBy, ptrd_UpdatedBy, ptrd_PACALicenseId,
			ptrd_AdditionalTradeName, ptrd_City, ptrd_State
		) SELECT 
			NULL, @UserId, @UserId, @NewPACALicenseId,
			prit_AdditionalTradeName, prit_City, prit_State
		  FROM PRImportPACATrade
		  WHERE prit_ImportPACALicenseId = @pril_ImportPACALicenseId 
		SET @TradeCount = @@ROWCOUNT + @ptrd_ndx

		-- start easy... if the counts don't match, have the Rating analyst review
		SELECT @TradeMsg = case when count(1) != (@TradeCount - @ptrd_ndx) then 'Alternate Tradename' else null end 
		  FROM PRPACATrade 
		 WHERE ptrd_PACALicenseId = @prpa_PACALicenseId

		-- create a primary key for when the rec is inserted for real, again, outside of the trx
		While (@ptrd_ndx < @TradeCount)
		BEGIN
			EXEC usp_getNextId 'PRPACATrade', @NextId output
			Update @tempPRPACATrade SET ptrd_PACATradeId = @NextId WHERE ndx = @ptrd_ndx
			-- As soon as a changed rec is identified, we can stop checking
			IF ( @PrincipalMsg IS NULL)
			BEGIN
				-- Check the existing, current PACA Principal records to verify this value
				-- combo exists; if it doesn't trigger this as a change
				IF NOT EXISTS (select 1
					  FROM PRPACATrade a, @tempPRPACATrade b
					 WHERE ndx = @ptrd_ndx
					   AND a.ptrd_PACALicenseId = @prpa_PACALicenseId
					   AND (
							(ISNULL(a.ptrd_AdditionalTradeName,'') = ISNULL(b.ptrd_AdditionalTradeName,'')) AND
							(ISNULL(a.ptrd_City,'') = ISNULL(b.ptrd_City,'')) AND
							(ISNULL(a.ptrd_State,'') = ISNULL(b.ptrd_State,'')) 
							)
				)
					SET @TradeMsg = 'Alternate Tradename'
			END
			SET @ptrd_ndx = @ptrd_ndx + 1
		END

		-- This notificiation does not adhere to the SendNotifications flag
		If (@Type IN (0, 1)) BEGIN
			
			-- if the PACA Insert record does not have a type of Frozen, set a inside sales task
			DECLARE @TypeFruitVeg varchar(40)
			SELECT @TypeFruitVeg = pril_TypeFruitVeg 
			  FROM PRImportPACALicense 
			 WHERE pril_ImportPACALicenseId = @pril_ImportPACALicenseId
				
			IF (@Type = 0) BEGIN 
				DECLARE @Notify bit = 0
				IF NOT EXISTS (SELECT 'x' FROM PRService WHERE prse_CompanyID=@comp_CompanyId AND prse_Primary = 'Y') BEGIN
					IF NOT EXISTS (SELECT 'x' FROM PRPACALicense WHERE prpa_CompanyId=@comp_CompanyId AND prpa_Publish = 'Y') BEGIN
						SET @Notify = 1
					END
				END

				IF (@Notify = 1) BEGIN
				SET @NotifyInsideSalesUserMsg = 'BB ID '+ convert(varchar,@comp_CompanyId) + 
					' assigned a new PACA license. Contact to qualify for listing and/or membership.'
				END
			END

			IF (@Type = 1) BEGIN 
				SET @NotifyInsideSalesUserMsg = 'BB ID '+ convert(varchar,@comp_CompanyId) + 
					' originated from a new PACA license. Contact to qualify for listing and/or membership.'
			END
		END
 
		-- Our records are now all ready to insert; Now determine what notifications are required
		-- If the caller asked us to send notifications (and all internal rules are met) determine 
		-- if any are necessary
		IF (@SendNotifications = 1)
		BEGIN
			-- determine the company changes
			Declare @pril_CompanyName varchar(80), @prpa_CompanyName varchar(80)
			Declare @pril_OwnCode varchar(40), @prpa_OwnCode varchar(40)
			Declare @pril_TerminateCode varchar(40), @prpa_TerminateCode varchar(40)
			Declare @pril_Telephone varchar(20), @prpa_Telephone varchar(20)
			Declare @pril_LicenseNumber varchar(8), @prpa_LicenseNumber varchar(8) 

			-- get the import record values
			SELECT @pril_CompanyName = pril_CompanyName, @pril_OwnCode = pril_OwnCode, 
				   @pril_Telephone = pril_Telephone, @pril_TerminateCode = pril_TerminateCode,
				   @pril_LicenseNumber = @pril_LicenseNumber
			  FROM PRImportPACALicense 
			  WHERE pril_ImportPACALicenseId = @pril_ImportPACALicenseId

			-- get the existing PACA License values
			SELECT @prpa_CompanyName = prpa_CompanyName, @prpa_OwnCode = prpa_OwnCode,
				   @prpa_Telephone = prpa_Telephone, @prpa_TerminateCode = prpa_TerminateCode,
				   @prpa_LicenseNumber = @prpa_LicenseNumber
			  FROM PRPACALicense, PRImportPACALicense 
			  WHERE pril_ImportPACALicenseId = @pril_ImportPACALicenseId
				    AND prpa_PACALicenseId = @prpa_PACALicenseId

			Declare @AddressChange varchar(10)
			SELECT @AddressChange = 'Address' 
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


			if (ISNULL(@prpa_LicenseNumber,'') != ISNULL(@pril_LicenseNumber,'') )
			begin
				if (@Changes != '' )
					SET @Changes = @Changes + ', '
				SET @Changes = @Changes + 'License Number'
			end
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
				-- Only notify the Listing Specialists if the company is listed.
				-- Defect #4090
				IF (@ListingStatus IN ('L', 'H', 'N1')) BEGIN
					if (@ListingChanges != '' )
						SET @ListingChanges = @ListingChanges + ', '
					SET @ListingChanges = @ListingChanges + 'Phone Number'

				END ELSE BEGIN
					if (@Changes != '' )
						SET @Changes = @Changes + ', '
					SET @Changes = @Changes + 'Phone Number'
				END
			end
			
			IF (ISNULL(@pril_TerminateCode,'') != ISNULL(@prpa_TerminateCode,''))
			begin
				if (@Changes != '' )
					SET @Changes = @Changes + ', '

				SET @Changes = @Changes + 'Terminate Code changed from ' + dbo.ufn_GetCustomCaptionValue('prpa_TerminateCode', @prpa_TerminateCode, 'en-us')  + ' to ' + dbo.ufn_GetCustomCaptionValue('prpa_TerminateCode', @pril_TerminateCode, 'en-us')
			end

			if (@AddressChange is not null)
			begin
				-- Only notify the Listing Specialists if the company is listed.
				-- Defect #4090
				IF (@ListingStatus IN ('L', 'H', 'N1')) BEGIN
					if (@ListingChanges != '' )
						SET @ListingChanges = @ListingChanges + ', '
					SET @ListingChanges = @ListingChanges + 'Address'
				END ELSE BEGIN
					if (@Changes != '' )
						SET @Changes = @Changes + ', '
					SET @Changes = @Changes + 'Address'
				END
			end
		
		END

		IF (@DEBUG = 1)
		BEGIN
			PRINT ''
			PRINT 'PACA Import License ID:' + convert(varchar(12), @pril_ImportPACALicenseId)
			PRINT 'PACA License ID:' + convert(varchar(12), @prpa_PACALicenseId)
			SELECT * FROM @tempPRPacaLicense
			SELECT * FROM @tempPRPacaPrincipal
			SELECT * FROM @tempPRPacaTrade
			PRINT '@NotifyInsideSalesUserMsg: ' + isnull(@NotifyInsideSalesUserMsg, 'NULL')
			PRINT '@Changes: ' + isnull(@Changes, 'NULL')
			PRINT '@ListingChanges: ' + isnull(@ListingChanges, 'NULL')
			if (@Changes != '' or @PrincipalMsg is not null or @TradeMsg is not null )begin
				SET @SendToUserId = @RatingUserId
				IF (@ListingChanges != '')
					SET @Changes = @Changes + ', '
				SET @Changes = @Changes + @ListingChanges
			end else if (@ListingChanges  != '') begin
				SET @SendToUserId = @ListingUserId
				SET @Changes = @ListingChanges 
			end			
			IF (@PrincipalMsg is not null) Begin
				IF (@Changes != '')
					SET @Changes = @Changes + ', ' 
				SET @Changes = @Changes + @PrincipalMsg 
			End
			IF (@TradeMsg is not null) Begin
				IF (@Changes != '')
					SET @Changes = @Changes + ', ' 
				SET @Changes = @Changes + @TradeMsg
			End
			PRINT '@Changes: ' + @Changes
			--=return -1
		END
		ELSE BEGIN
			-- Perform the insert/updates
			BEGIN TRY
				BEGIN TRANSACTION
					-- Start by updating the current record for this company
					UPDATE PRPACALicense 
					   SET prpa_Current = NULL, prpa_Publish = null 
						   ,prpa_Timestamp=getdate(), prpa_UpdatedDate=getDate(), prpa_UpdatedBy=@UserId 
					 WHERE prpa_CompanyId = @comp_CompanyId AND prpa_Current = 'Y'

					-- insert the PRPACALicense record
					INSERT INTO PRPACALicense
						(   prpa_PACALicenseId,	prpa_CreatedBy,	prpa_UpdatedBy,	prpa_CompanyId,
							prpa_LicenseNumber,
							prpa_Current, prpa_Publish,
							prpa_CompanyName,
							prpa_PrimaryTradeName, prpa_CustomerFirstName, prpa_CustomerMiddleInitial,
							prpa_Address1, prpa_Address2, prpa_City, prpa_State, prpa_PostCode,
							prpa_MailAddress1, prpa_MailAddress2, prpa_MailCity, prpa_MailState, prpa_MailPostCode,
							prpa_IncState, prpa_IncDate, prpa_OwnCode, prpa_Telephone, prpa_TerminateDate, prpa_TerminateCode,
							prpa_TypeFruitVeg, prpa_ProfCode, 
							prpa_EffectiveDate, prpa_ExpirationDate,
                            prpa_Email, prpa_WebAddress, prpa_Fax
						) SELECT    
							prpa_PACALicenseId,	prpa_CreatedBy,	prpa_UpdatedBy,	prpa_CompanyId,
							prpa_LicenseNumber,
							prpa_Current, prpa_Publish,
							prpa_CompanyName,
							prpa_PrimaryTradeName, prpa_CustomerFirstName, prpa_CustomerMiddleInitial,
							prpa_Address1, prpa_Address2, prpa_City, prpa_State, prpa_PostCode,
							prpa_MailAddress1, prpa_MailAddress2, prpa_MailCity, prpa_MailState, prpa_MailPostCode,
							prpa_IncState, prpa_IncDate, prpa_OwnCode, prpa_Telephone, prpa_TerminateDate, prpa_TerminateCode,
							prpa_TypeFruitVeg, prpa_ProfCode, 
							prpa_EffectiveDate, prpa_ExpirationDate,
                            prpa_Email, prpa_WebAddress, prpa_Fax
						  FROM @tempPRPACALicense
						  WHERE ndx = @ImportNdx

					-- insert the PRPACATrade record(s)
					INSERT INTO PRPACAPrincipal
						(   prpp_PACAPrincipalId, prpp_CreatedBy, prpp_UpdatedBy, prpp_PACALicenseId,
							prpp_LastName, prpp_FirstName, prpp_MiddleInitial,
							prpp_Title, prpp_City, prpp_State
						) SELECT 
							prpp_PACAPrincipalId, prpp_CreatedBy, prpp_UpdatedBy, prpp_PACALicenseId,
							prpp_LastName, prpp_FirstName, prpp_MiddleInitial,
							prpp_Title, prpp_City, prpp_State
						  FROM @tempPRPACAPrincipal

					-- insert the PRPACATrade record(s)
					INSERT INTO PRPACATrade
						( ptrd_PACATradeId, ptrd_CreatedBy, ptrd_UpdatedBy, ptrd_PACALicenseId,
							ptrd_AdditionalTradeName, ptrd_City, ptrd_State
						) SELECT 
							ptrd_PACATradeId, ptrd_CreatedBy, ptrd_UpdatedBy, ptrd_PACALicenseId,
							ptrd_AdditionalTradeName, ptrd_City, ptrd_State
						  FROM @tempPRPACATrade

					-- Detect if a PRImportPACAComplaint record exists for this license ID and if so, insert it into the PRPACAComplaint table.
					-- The other code uses temp tables.  We dont need to here.
					-- Just use the source ImportPACALicenseID value so select the record.  Use @prpa_PACALicenseId for the license ID when inserting the record.
					IF(EXISTS(SELECT * FROM PRImportPACAComplaint WHERE pripc_ImportPACALicenseID = @pril_ImportPACALicenseId))
					BEGIN
						DECLARE @prpac_PACAComplaintID int
						exec usp_getNextId 'PRPACAComplaint', @prpac_PACAComplaintID output

						INSERT INTO PRPACAComplaint(prpac_PACAComplaintID, prpac_PACALicenseID, prpac_InfRepComplaintCount, prpac_DisInfRepComplaintCount, prpac_ForRepComplaintCount, prpac_DisForRepCompaintCount, prpac_TotalFormalClaimAmt, prpac_TotalFormalClaimAmt_CID)
							SELECT @prpac_PACAComplaintID, @NewPACALicenseId, pripc_InfRepComplaintCount, pripc_DisInfRepComplaintCount, pripc_ForRepComplaintCount, pripc_DisForRepCompaintCount, pripc_TotalFormalClaimAmt, 1 
							FROM PRImportPACAComplaint 
							WHERE pripc_ImportPACALicenseID = @pril_ImportPACALicenseId
					END

					-- we send the inside sales message regardless of @SendNotification status
					IF (@NotifyInsideSalesUserMsg IS NOT NULL AND @InsideSalesUserId is not null)
					BEGIN

						DECLARE @OppoId int
						EXEC usp_getNextId 'Opportunity', @OppoId OUTPUT
						
						INSERT INTO Opportunity (oppo_OpportunityId, oppo_PrimaryCompanyID, oppo_AssignedUserID, Oppo_Note, oppo_Type, 
									             oppo_Status, oppo_Stage, oppo_PRPipeline, oppo_Opened,
									             oppo_Source, oppo_PRTrigger,
												 oppo_CreatedBy, oppo_CreatedDate, oppo_UpdatedBy, oppo_UpdatedDate, oppo_Timestamp)
			            VALUES (@OppoId, @comp_CompanyId, @InsideSalesUserId, @NotifyInsideSalesUserMsg, 'NEWM',
			                    'Open', 'Lead', 'M:PACA', GETDATE(),
			                    'IB', 'Other',
					            @UserId, GETDATE(), @UserId, GETDATE(), GETDATE());
					            
					END
				
					-- if notifcations have to be sent, send them here
					IF (@SendNotifications = 1)
					BEGIN
						-- Create the notification message, start with Rating values
						if (@Changes != '' or @PrincipalMsg is not null or @TradeMsg is not null )begin
							SET @SendToUserId = @RatingUserId
							IF (@ListingChanges != '')
								SET @Changes = @Changes + ', '
							SET @Changes = @Changes + @ListingChanges
						end else if (@ListingChanges  != '') begin
							SET @SendToUserId = @ListingUserId
							SET @Changes = @ListingChanges 
						end			

						IF (@PrincipalMsg is not null) Begin
							IF (@Changes != '')
								SET @Changes = @Changes + ', ' 
							SET @Changes = @Changes + @PrincipalMsg 
						End

						IF (@TradeMsg is not null) Begin
							IF (@Changes != '')
								SET @Changes = @Changes + ', ' 
							SET @Changes = @Changes + @TradeMsg
						End

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
								@Status = 'Pending',
								@Subject = 'PACA Reporting Changes'
						END
						
					END

					-- remove the existing Imported PACA record
					IF (@DeleteImport = 1)
					BEGIN
						 -- delete any Principal records
						DELETE 
							FROM PRImportPACAPrincipal 
							WHERE prip_ImportPACALicenseId = @pril_ImportPACALicenseId

						-- delete any Trade records
						DELETE 
							FROM PRImportPACATrade 
							WHERE prit_ImportPACALicenseId = @pril_ImportPACALicenseId

						--Deletes the data from the PRImportPACAComplaint table for this license ID.
						DELETE
							FROM PRImportPACAComplaint
							WHERE pripc_ImportPACALicenseID = @pril_ImportPACALicenseId

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
				exec usp_RethrowError;
			END CATCH;
		END
		-- Next record
		SET @ImportNdx = @ImportNdx + 1
	END

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
    
    -- if the caller was nice, they gave us a company id; if not, we can try to get it ourselves
    IF (@preq_CompanyId IS NULL)
    BEGIN
        IF (@preq_Type = 'TES')
        BEGIN
            -- Determine the CompanyId from the TradeReport
            select @preq_CompanyId = prtr_SubjectId from PRTradeReport WITH (NOLOCK) where prtr_TradeReportId = @preq_Id

        END
        ELSE IF (@preq_Type = 'AR')
        BEGIN
            -- Determine the CompanyId from the PRARAgingDetail record
            select @preq_CompanyId = SubjectCompanyId from vPRARAgingDetail where praad_ARAgingDetailId = @preq_Id

        END
        ELSE IF (@preq_Type = 'BBScore')
        BEGIN
            -- Determine the CompanyId from the BlueBook Score
            select @preq_CompanyId = prbs_CompanyId from PRBBScore WITH (NOLOCK) where prbs_BBScoreId = @preq_Id

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

	SELECT @comp_PRType = comp_PRType, @comp_HQId = comp_PRHQId 
	  FROM company WITH (NOLOCK) 
	 WHERE comp_CompanyId = @preq_CompanyId;
	 
	-- if this is a branch, we compare against the branches HQ
	if (@comp_PRType = 'B')
		SET @LookupCompanyId = @comp_HQId
    
    SELECT @comp_PRListingCityId = comp_PRListingCityId FROM Company WITH (NOLOCK) Where comp_CompanyId = @LookupCompanyId
    SET @preq_AssignedUserId = @preq_UserId
    IF (@comp_PRListingCityId is not null)
    BEGIN
        SELECT @preq_AssignedUserId = prci_RatingUserId from PRCity WITH (NOLOCK) where prci_CityId = @comp_PRListingCityId
    END
    IF (@preq_AssignedUserId is not null)
    BEGIN
        SELECT @preq_ChannelId = user_PrimaryChannelId from Users WITH (NOLOCK) where user_UserId = @preq_AssignedUserId
    END
    
    -- Get the current Rating LIne
    SELECT @preq_RatingLine = prra_RatingLine 
      FROM vPRCurrentRating 
     WHERE prra_CompanyId = @preq_CompanyId ;

    -- Get the Trade Report info
    DECLARE @tblTradeReports table (prtr_TradeReportId int, prtr_Date datetime )
    
    INSERT INTO @tblTradeReports 
    SELECT prtr_TradeReportId, prtr_Date
      FROM PRTradeReport WITH (NOLOCK) 
     WHERE prtr_SubjectId = @preq_CompanyId
       AND prtr_Date >= DateAdd(Month, -12, @NOW);
       
    SELECT @preq_NumTradeReports3 = COUNT(1) from @tblTradeReports WHERE prtr_Date >= DateAdd(Month, -3, @NOW);     
    SELECT @preq_NumTradeReports6 = COUNT(1) from @tblTradeReports WHERE prtr_Date >= DateAdd(Month, -6, @NOW);     
    SELECT @preq_NumTradeReports12 = COUNT(1) from @tblTradeReports WHERE prtr_Date >= DateAdd(Month, -12, @NOW);     

    -- Get the current Bluebook score
    SELECT @preq_BlueBookScore = prbs_BBScore 
      FROM PRBBScore  WITH (NOLOCK)
     WHERE prbs_CompanyId = @preq_CompanyId 
       AND prbs_Current = 'Y';

	BEGIN TRY
		BEGIN TRANSACTION
	    
		-- Insert the exception 
		INSERT INTO PRExceptionQueue 
			( preq_CreatedBy, preq_CreatedDate, preq_UpdatedBy, preq_UpdatedDate, preq_TimeStamp,
			  preq_TradeReportId, preq_ARAgingId, preq_CompanyId, 
			  preq_Date, preq_Type, preq_Status, 
			  preq_ThreeMonthIntegrityRating, preq_ThreeMonthPayRating,
			  preq_RatingLine, preq_NumTradeReports3Months,
			  preq_NumTradeReports6Months, preq_NumTradeReports12Months,
			  preq_BlueBookScore, preq_AssignedUserId, preq_ChannelId
			)
			VALUES
			( @preq_UserId, @NOW, @preq_UserId, @NOW, @NOW,
			  @preq_Id, null, @preq_CompanyId, 
			  @preq_Date, @preq_Type, 'O', 
			  @IntegrityAvg3, @PayRatingAvg3,
			  @preq_RatingLine, @preq_NumTradeReports3,
			  @preq_NumTradeReports6, @preq_NumTradeReports12,
			  @preq_BlueBookScore, @preq_AssignedUserId, @preq_ChannelId
			)
		SELECT @NewExceptionId = SCOPE_IDENTITY();

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
	@Assigned_IntegrityID int = NULL,
	@Assigned_PayRatingID int = NULL,
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
	DECLARE @prra_Rated nchar(1)
    
    Declare @cntRatingNumeral smallint
    Declare @cntOutOfBusiness smallint
    
    SET @NOW = GetDate()

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
    
    SELECT @prra_RatingId = prra_RatingId, 
           @prra_IntegrityId = prra_IntegrityId, 
           @prra_PayRatingId = prra_PayRatingId,
           @prra_IntegrityWeight = prin_Weight,
           @prra_PayRatingWeight = prpy_Weight,
		   @prra_Rated = prra_Rated
      FROM vPRCompanyRating
     WHERE prra_CompanyId = @RatingCompanyId
       AND prra_Current = 'Y'
      

	    
	DECLARE @CreateException bit
	SET @CreateException = 0

	If (@prra_RatingId is not null) begin

		SELECT @cntRatingNumeral = COUNT(1) 
		  FROM PRRatingNumeralAssigned WITH (NOLOCK)
		 WHERE pran_RatingId = @prra_RatingId
		   AND pran_RatingNumeralId in (86, 76, 27, 85, 74, 124, 132, 88, 113, 114)
	      
		-- if any of these rating numerals are reported, an exception can not occur
		if (@cntRatingNumeral = 0) begin
			if (@Assigned_IntegrityID in (1,2) and (@prra_IntegrityID not in (1,2,3)) ) begin 
				-- Create the exception
				SET @CreateException = 1
			END else if (@Assigned_PayRatingID in (2,3,4)) begin
				if (@prra_PayRatingWeight > @Assigned_PayRatingWeight + 1) begin
					-- create the exception
					SET @CreateException = 1
				end
			end
		end	
		  
		if ((@CreateException = 0) AND (@Assigned_OutOfBusiness = 'Y')) begin
			SELECT @cntOutOfBusiness = count(1) 
			  FROM PRRatingNumeralAssigned WITH (NOLOCK)
             WHERE pran_RatingId = @prra_RatingId
			   AND pran_RatingNumeralId in (88, 113, 114);
				 
			if (@cntOutOfBusiness = 0) begin
				-- Create the exception
				SET @CreateException = 1
			end
		end

		--Checks the specified PayRating.  
		-- If E or F, then check the PRRatingNumeralAssigned table for 81, 83, or 149.   
		-- If any are found invoke usp_CreateException.
		if ((@CreateException = 0) AND (@Assigned_PayRatingID in (2,3))) begin
					
			SELECT @cntRatingNumeral = count(1) 
			  FROM PRRatingNumeralAssigned WITH (NOLOCK)
             WHERE pran_RatingId = @prra_RatingId
			   AND pran_RatingNumeralId in (81, 83, 149)

			if (@cntRatingNumeral != 0) begin
				-- Create the exception
				SET @CreateException = 1
			end
		end

	end -- Done with the rating checks
 
	--Checks the specified Pay Rating for D, E, or F 
	-- and the specified Integrity Rating for X or XX.  If any of the five are found, 
	-- and the company is not rating (either no current PRRating record found or the 
	-- current PRRating has prra_Rated = NULL), then invoke usp_CreateException 
	IF (@CreateException = 0) AND 
	   (@Assigned_PayRatingID IN (2,3,4) OR @Assigned_IntegrityID IN (1, 2)) AND
	   (@prra_RatingId IS NULL OR @prra_Rated IS NULL) BEGIN
		SET @CreateException = 1
	END


/*
	IF (@CreateException = 0) BEGIN

		DECLARE @TMFMAward varchar(1)
		SELECT @TMFMAward = comp_PRTMFMAward
		  FROM Company WITH (NOLOCK)
		 WHERE comp_CompanyID = @RatingCompanyId

		IF (@TMFMAward = 'Y') AND 
	       (@Assigned_PayRatingID IN (2,3,4,5) OR @Assigned_IntegrityID IN (1, 2)) BEGIN
			SET @CreateException = 1
		END	
	END
*/
	IF (@CreateException = 1) BEGIN

		BEGIN TRY
			BEGIN TRANSACTION

			EXEC usp_CreateException @SourceType, @SourceId, @UserId

			IF @@TRANCOUNT > 0
				COMMIT TRANSACTION;
		END TRY
		BEGIN CATCH

			IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION;

			EXEC usp_RethrowError;
		END CATCH;
	END
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
      from vPRCurrentRating
      where prra_CompanyId = @comp_CompanyId;
      
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

-- =============================================
-- Author:		Tad M. Eness
-- Create date: 8/6/2007
-- Description:	Insert or Update a Company Relationship
-- Parameters:
--     LeftCompanyId
--			Subject Company
--     RightCompanyId
--			Related Company
--     RelationshipType
--			Comma delimted list of Types.
--			Intended to allow the deactivation of multiple types, but will work to add as well
--     Action
--			0 = Add/Update
--			1 = Strict Update. No record will be added
--			2 = Disable relationship. Will disable the relationship
--			3 = Decrement times reported and delete the relationship record if it reaches zero
--			4 = Hard delete the relationship record
--     CRMUserID
--			Needed for table insert. Will be looked up if not supplied
--     LastReportedDate
--			Optional reported date defaults to the current date
--     TransactionVolume
--		    Optional reported transaction volume for this relationship
--     TransactionFrequency
--          Optional reported transaction frequency for this relationship
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[usp_UpdateCompanyRelationship] 
	@LeftCompanyId int, 
	@RightCompanyId int,
	@RelationshipTypes nvarchar(4000),  -- comma delimited list of types
	@Action int = 0,
	@CRMUserID int = 0,
	@LastReportedDate datetime = null,
    @TransactionVolume nvarchar(40) = null,
    @TransactionFrequency nvarchar(40) = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Paranoia checks, make sure you've got some data to insert
	IF LEN(COALESCE(@RelationshipTypes, N'')) < 1
		RETURN;

	IF COALESCE(@LeftCompanyId, -1) < 0 OR COALESCE(@RightCompanyId, -1) < 0
		RETURN;

	-- Do nothing if attempting to relate a company to itself
	IF @LeftCompanyId = @RightCompanyId
		RETURN;

	-- If a company has a branch relationship, then ignore this request.
	IF EXISTS(SELECT 'x' FROM Company WITH (NOLOCK) WHERE ((Comp_CompanyID = @LeftCompanyId AND comp_PRHQId = @RightCompanyId) OR (Comp_CompanyID = @RightCompanyId AND comp_PRHQid = @LeftCompanyId)))
		RETURN;



	DECLARE @CurrentTime DATETIME;
	SET @CurrentTime = GETDATE();

	-- If we don't have a CRM User, go get the
	-- default website user
	IF @CRMUserID = 0 BEGIN
		SET @CRMUserID = dbo.ufn_GetSystemUserId(1)
	END

	IF @LastReportedDate Is Null BEGIN
		Set @LastReportedDate = @CurrentTime;
	END

	-- Change the list of Types from a string to a list.
	DECLARE @Types TABLE(idx int, [Type] varchar(10));
	INSERT INTO @Types(idx, [Type]) SELECT idx, [value] FROM dbo.Tokenize(@RelationshipTypes, ',');

	DECLARE @GenerateTES bit
	SET @GenerateTES = 0

	-- Iterate over each of the types received
	DECLARE @idx int;
	DECLARE @max_idx int;
	DECLARE @Type nvarchar(50);
	SELECT @max_idx = MAX(idx) FROM @Types;
	SELECT @idx = MIN(idx) FROM @Types;

	-- These should never be null, but might be if no parameter was passed.
	IF @idx is null OR @max_idx is null
		RETURN;

	WHILE @idx <= @max_idx
	BEGIN
		SELECT @Type = [Type] FROM @Types WHERE idx = @idx;
		IF LEN(COALESCE(@Type, '')) < 1 BEGIN
			SET @idx = @idx + 1
			CONTINUE
		END

		-- If a company is an affilate of another, then ignore this request.
		-- 27 = Wholy owned
		-- 28 = Partially owned
		-- 39 = Companies are peers
		IF EXISTS(SELECT 'x' FROM PRCompanyRelationship WITH (NOLOCK) WHERE prcr_Type in (N'27', N'28', N'29') AND ((prcr_LeftCompanyId = @LeftCompanyId AND prcr_RightCompanyId = @RightCompanyId) OR (prcr_LeftCompanyId = @RightCompanyId AND prcr_RightCompanyId = @LeftCompanyId))) BEGIN
			IF (@Type IN ('09', '10', '11', '12', '13', '14', '15')) BEGIN
				SET @idx = @idx + 1
				CONTINUE
			END
		END

		IF EXISTS(SELECT 'x' FROM PRCompanyRelationship WITH (NOLOCK) WHERE prcr_LeftCompanyId = @LeftCompanyId AND prcr_RightCompanyId = @RightCompanyId AND prcr_Type = @Type)
		BEGIN
			-- Hard delete
			IF @Action = 4
			BEGIN
				-- Hard delete, remove the record
				DELETE
				  FROM PRCompanyRelationship
				 WHERE prcr_LeftCompanyId = @LeftCompanyId
				   AND prcr_RightCompanyId = @RightCompanyId
				   AND prcr_Type = @Type;
			END ELSE BEGIN
				IF @TransactionVolume IS NOT NULL OR @TransactionFrequency IS NOT NULL
				BEGIN
					-- Update, Increment count, etc 
					UPDATE PRCompanyRelationship
					   SET prcr_TimesReported = prcr_TimesReported + CASE @Action WHEN 3 THEN -1 ELSE 1 END,
						   prcr_Active = CASE @Action WHEN 2 THEN null ELSE 'Y' END,
						   prcr_LastReportedDate = @LastReportedDate,
						   prcr_UpdatedBy = @CRMUserID,
						   prcr_UpdatedDate = @CurrentTime,
						   prcr_TimeStamp = @CurrentTime,
						   prcr_TransactionVolume = @TransactionVolume,
						   prcr_TransactionFrequency = @TransactionFrequency
					 WHERE prcr_Type = @Type
						   AND prcr_LeftCompanyId = @LeftCompanyId
						   AND prcr_RightCompanyId = @RightCompanyId;
				END ELSE BEGIN
					-- Update, Increment count, etc 
					UPDATE PRCompanyRelationship
					   SET prcr_TimesReported = prcr_TimesReported + 1,
                           prcr_Active = CASE @Action WHEN 2 THEN null ELSE 'Y' END,
                           prcr_LastReportedDate = @LastReportedDate,
                           prcr_UpdatedBy = @CRMUserID,
                           prcr_UpdatedDate = @CurrentTime,
                           prcr_TimeStamp = @CurrentTime
                     WHERE prcr_Type = @Type
					   AND prcr_LeftCompanyId = @LeftCompanyId
					   AND prcr_RightCompanyId = @RightCompanyId;
				END

				-- Delete the record when decrementing the count and it hits zero
				IF @Action = 3
				BEGIN
					DELETE
					  FROM PRCompanyRelationship
					 WHERE prcr_Type = @Type
						   AND prcr_LeftCompanyId = @LeftCompanyId
						   AND prcr_RightCompanyId = @RightCompanyId
						   AND prcr_TimesReported < 1;
				END
			END
		END ELSE BEGIN
			-- Only Insert for Update/Add action zero. All other actions are "strict"
			IF @Action = 0
			BEGIN
				-- Create a new records for those that do not exist
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
					prcr_Active,
					prcr_TransactionVolume,
					prcr_TransactionFrequency)
				VALUES (@CompRelID,
					@CRMUserID,
					@CurrentTime,
					@CRMUserID,
					@CurrentTime,
					@CurrentTime,
					@LeftCompanyId,
					@RightCompanyId,
					@Type,
					@CurrentTime,
					@LastReportedDate,
					1,
					'Y',
					@TransactionVolume,
					@TransactionFrequency);

				IF (@Type IN ('09', '10', '11', '12', '13', '14', '15', '16', '32')) BEGIN
					SET @GenerateTES = 1
				END
			END
		END

		-- Remove any TES exclusions between the relationship owner and related company
		-- if the relationship owner (responder) previously said they don't do business.
		-- If they are reporting these types, they now do business.
		IF (@Action IN (0, 1) AND
		    @Type IN ('09', '10', '11', '12', '13', '14', '15')) BEGIN
			DELETE FROM PRTESRequestExclusion WHERE prtesre_CompanyID=@LeftCompanyId AND prtesre_SubjectCompanyID=@RightCompanyID;
		END

		SET @idx = @idx + 1;
	END

	IF (@GenerateTES = 1) BEGIN

		DECLARE @IsEligible char(1) 
		SET @IsEligible = dbo.ufn_IsEligibleForTES(@RightCompanyId, @LeftCompanyId);

		IF (@IsEligible = 'Y') BEGIN
			EXEC usp_CreateTES @RightCompanyId, @LeftCompanyId, NULL, 'NC', @CRMUserID;
		END
	END
END
GO

CREATE OR ALTER PROCEDURE [dbo].[usp_CreateTESRequestExclusion] 
	@CompanyId int, 
	@SubjectCompanyId int,
	@UserID int = 1
AS
BEGIN

	IF EXISTS (SELECT 'x' FROM PRTESRequestExclusion WHERE prtesre_CompanyID=@CompanyId AND prtesre_SubjectCompanyID=@SubjectCompanyId) BEGIN
		UPDATE PRTESRequestExclusion SET prtesre_UpdatedBy = @UserID, prtesre_UpdatedDate = GETDATE() WHERE prtesre_CompanyID=@CompanyId AND prtesre_SubjectCompanyID=@SubjectCompanyId
	END ELSE BEGIN
		INSERT INTO PRTESRequestExclusion (prtesre_CompanyID, prtesre_SubjectCompanyID, prtesre_CreatedBy, prtesre_CreatedDate)
		VALUES (@CompanyId, @SubjectCompanyId, @UserID, GETDATE());
	END

END
Go


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
    @ProductID int,
	@PricingListID int,
    @RegardingCompanyID int = 0,
    @SearchCriteria nvarchar(2000) = NULL,
    @RequestorInfo nvarchar(50) = NULL,
    @AddressLine1 nvarchar(50) = NULL,
	@AddressLine2 nvarchar(50) = NULL,
	@CityStateZip nvarchar(50) = NULL,
    @Fax nvarchar(50) = NULL,
    @NoCharge bit = 0,
    @CRMUserID int = 0,
    @EmailAddress nvarchar(50) = null,
    @Country nvarchar(50) = null,
    @HQID int = null,
    @RegardingObjectID int = null,
    @RequestID int = null
AS 

SET NOCOUNT ON

-- If we don't have a CRM User, go get the
-- default website user
IF @CRMUserID = 0 BEGIN
	SET @CRMUserID = dbo.ufn_GetSystemUserId(1)
END

IF (@HQID IS NULL) BEGIN
	SELECT @HQID = comp_PRHQID
      FROM Company WITH (NOLOCK)
     WHERE comp_CompanyID = @CompanyID;
END

IF @NoCharge = 0 BEGIN
	-- Check to see if we have the units.
	IF dbo.ufn_HasAvailableUnits(@HQID, @ProductID, @PricingListID) = 0 BEGIN
		RAISERROR ('Not enough service units available.', 16, 1)
		RETURN -1
	END
END


-- Determine if we need to log a Business Report Request
DECLARE @CreateBRRequest bit
SET @CreateBRRequest = 0

IF (@UsageType IN  ('VBR', 'FBR', 'MBR', 'EBR','OBR')) BEGIN
	SET @CreateBRRequest = 1
END

BEGIN TRANSACTION;
BEGIN TRY

IF (@CreateBRRequest = 1) BEGIN
	-- Create a PRBusinessReportRequest record
	DECLARE @BRRequestID int
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
		prbr_ProductID,
        prbr_RequestorInfo,
        prbr_AddressLine1,
        prbr_AddressLine2,
		prbr_CityStateZip,
		prbr_Country,
		prbr_EmailAddress,
        prbr_Fax,
        prbr_DoNotChargeUnits,
        prbr_RequestID)
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
			@ProductID,
		    @RequestorInfo,
		    @AddressLine1,
			@AddressLine2, 
			@CityStateZip,
			@Country,
			@EmailAddress,
			@Fax,
			CASE @NoCharge WHEN 1 THEN 'Y' ELSE NULL END,
            @RequestID);

	SET @RegardingObjectID = @BRRequestID
    -- update the PRCompanyRelationship record.

	DECLARE @RegardingHQID int
	SELECT @RegardingHQID = comp_PRHQID
		FROM Company WITH (NOLOCK)
		WHERE comp_CompanyID = @RegardingCompanyID;


	EXEC usp_UpdateCompanyRelationship @CompanyID, @RegardingHQID, N'25', 0, @CRMUserID
END

DECLARE @Price numeric(24,6)
IF @NoCharge = 1 BEGIN
	SET @Price = 0
END ELSE BEGIN
	SET @Price = dbo.ufn_GetProductPrice(@ProductID, @PricingListID)			
END

-- Go Get our UniqueID.
DECLARE @ServiceUnitUsageID int
--EXEC usp_getNextId 'PRServiceUnitUsage', @ServiceUnitUsageID Output


-- Insert our ServiceUnitUsage record
INSERT INTO PRServiceUnitUsage (
    --prsuu_ServiceUnitUsageID,
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
    prsuu_SearchCriteria,
    prsuu_HQID)
VALUES (--@ServiceUnitUsageID,
		@CRMUserID,
        GETDATE(),
		@CRMUserID,
        GETDATE(),
        GETDATE(),
		@CompanyID,
		@PersonID,
		CAST(@Price As INT),
		@SourceType,
		'U',
		@UsageType,
		@RegardingObjectID,
		@SearchCriteria,
        @HQID);
SELECT @ServiceUnitUsageID = SCOPE_IDENTITY();

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
   AND prun_HQID = @HQID
   AND prun_UnitsRemaining > 0
 ORDER BY prun_ExpirationDate, prun_CreatedDate;

SET @Count = @@ROWCOUNT
SET @ndx = 1	
SET @CurrentRemaining = CAST(@Price AS INT)

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
	--DECLARE @ServiceUnitAllocationUsageID int
	--EXEC usp_getNextId 'PRServiceUnitAllocationUsage', @ServiceUnitAllocationUsageID Output

	-- Insert our PRServiceUnitAllocationUsage record
	INSERT INTO PRServiceUnitAllocationUsage (
		--prsua_ServiceUnitUsageAllocationID,
		prsua_CreatedBy,
		prsua_CreatedDate,
		prsua_UpdatedBy,
		prsua_UpdatedDate,
		prsua_TimeStamp,
		prsua_ServiceUnitAllocationID,
		prsua_ServiceUnitUsageID)
	VALUES (--@ServiceUnitAllocationUsageID,
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

	EXEC usp_RethrowError;
END CATCH;

SET NOCOUNT ON
GO

If Exists (Select name from sysobjects where name = 'usp_ConsumeBackgroundCheckUnits' and type='P') Drop Procedure dbo.usp_ConsumeBackgroundCheckUnits
Go

/**
Creates the appropriate records to consume background check service units
**/
CREATE PROCEDURE dbo.usp_ConsumeBackgroundCheckUnits
	@CompanyID int,
    @CRMUserID int,
    @HQID int = null
AS 

SET NOCOUNT ON

-- If we don't have a CRM User, go get the
-- default website user
IF @CRMUserID = 0 BEGIN
	SET @CRMUserID = dbo.ufn_GetSystemUserId(1)
END

IF (@HQID IS NULL) BEGIN
	SELECT @HQID = comp_PRHQID
      FROM Company WITH (NOLOCK)
     WHERE comp_CompanyID = @CompanyID;
END

BEGIN TRANSACTION;
BEGIN TRY

-- Now we need to figure out which allocations
-- to associate this usage with.  Those allocations need
--
DECLARE @Count int, @Ndx int, 
	@BackgroundCheckAllocationID int,
	@BackgroundCheckAllocationUnitsRemaining int, 
	@CurrentRemaining int

DECLARE @BackgroundCheckAllocations table (
	ndx smallint identity, 
	BackgroundCheckAllocationID int,
    UnitsRemaining int)

INSERT INTO @BackgroundCheckAllocations (BackgroundCheckAllocationID, UnitsRemaining)
SELECT prbca_BackgroundCheckAllocationID, prbca_Remaining
  FROM PRBackgroundCheckAllocation
 WHERE GETDATE() BETWEEN prbca_StartDate AND prbca_ExpirationDate
   AND prbca_HQID = @HQID
   AND prbca_Remaining > 0
 ORDER BY prbca_ExpirationDate, prbca_CreatedDate;

SET @Count = @@ROWCOUNT
SET @ndx = 1	
SET @CurrentRemaining = 1

WHILE (@Ndx <= @Count) BEGIN
	SELECT @BackgroundCheckAllocationID = BackgroundCheckAllocationID,
	       @BackgroundCheckAllocationUnitsRemaining = UnitsRemaining
      FROM @BackgroundCheckAllocations WHERE ndx = @Ndx;

	SET @Ndx = @Ndx + 1

	IF (@CurrentRemaining <= @BackgroundCheckAllocationUnitsRemaining) BEGIN
		UPDATE PRBackgroundCheckAllocation
           SET prbca_Remaining = prbca_Remaining - @CurrentRemaining,
			   prbca_UpdatedBy = @CRMUserID,
		       prbca_UpdatedDate = GETDATE(),
			   prbca_TimeStamp = GETDATE()
         WHERE prbca_BackgroundCheckAllocationID = @BackgroundCheckAllocationID;

		-- We're done so make sure we don't loop 
		-- any further.
		SET @Ndx = @Count + 1
	
	END ELSE BEGIN
		-- Decrement by how many this allocation has remaining, then zero out the allocation.
		SET @CurrentRemaining = @CurrentRemaining - @BackgroundCheckAllocationUnitsRemaining	

		UPDATE PRBackgroundCheckAllocation
           SET prbca_Remaining = 0,
			   prbca_UpdatedBy = @CRMUserID,
		       prbca_UpdatedDate = GETDATE(),
			   prbca_TimeStamp = GETDATE()
         WHERE prbca_BackgroundCheckAllocationID = @BackgroundCheckAllocationID;
	END
END

IF @@TRANCOUNT > 0
    COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

	EXEC usp_RethrowError;
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
	@ServiceUnitAllocationID int,
	@CancelUnitQty int = -1 OUTPUT
AS 
BEGIN 

	SET NOCOUNT ON

	DECLARE @CRMUserID int
	SET @CRMUserID = dbo.ufn_GetSystemUserId(1)

	DECLARE @HQID int
	SELECT @HQID = comp_PRHQID
	  FROM Company WITH (NOLOCK)
	 WHERE comp_CompanyID = @CompanyID;


	-- Determine how many units remain for the
	-- specified allocaton.
	DECLARE @UnitsRemaining int = 0
	SELECT @UnitsRemaining = ISNULL(prun_UnitsRemaining, 0),
	       @CancelUnitQty = ISNULL(prun_UnitsAllocated, 0) - ISNULL(prun_UnitsRemaining, 0)
	  FROM PRServiceUnitAllocation 
	 WHERE prun_ServiceUnitAllocationID = @ServiceUnitAllocationID;

	IF @UnitsRemaining > 0 BEGIN

		-- Create a single Usage record for
		-- the remaining units.

		-- Go Get our UniqueID.
		DECLARE @ServiceUnitUsageID int

		-- Insert our ServiceUnitUsage record
		INSERT INTO PRServiceUnitUsage (
			prsuu_CreatedBy,
			prsuu_CreatedDate,
			prsuu_UpdatedBy,
			prsuu_UpdatedDate,
			prsuu_TimeStamp,
			prsuu_CompanyID,
			prsuu_HQID,
			prsuu_Units,
			prsuu_SourceCode,
			prsuu_TransactionTypeCode,
			prsuu_UsageTypeCode)
		VALUES (@CRMUserID,
				GETDATE(),
				@CRMUserID,
				GETDATE(),
				GETDATE(),
				@CompanyID,
				@HQID,
				@UnitsRemaining,
				'C', -- CSR
				'C', -- Cancelleation
				'C');  -- Cancelleation
		SELECT @ServiceUnitUsageID = SCOPE_IDENTITY();


		-- Zero out the remaining units for
		-- our allocation records.
		UPDATE PRServiceUnitAllocation
		   SET prun_UnitsRemaining = 0,
			   prun_UpdatedBy = @CRMUserID,
			   prun_UpdatedDate = GETDATE(),
			   prun_TimeStamp = GETDATE()
		  FROM PRServiceUnitAllocation 
         WHERE prun_ServiceUnitAllocationID = @ServiceUnitAllocationID;

		--
		-- Create our bridge entry
		--

		-- Insert our PRServiceUnitAllocationUsage record
		INSERT INTO PRServiceUnitAllocationUsage (
			prsua_CreatedBy,
			prsua_CreatedDate,
			prsua_UpdatedBy,
			prsua_UpdatedDate,
			prsua_TimeStamp,
			prsua_ServiceUnitAllocationID,
			prsua_ServiceUnitUsageID)
		VALUES (
			@CRMUserID,
			GETDATE(),
			@CRMUserID,
			GETDATE(),
			GETDATE(),
			@ServiceUnitAllocationID,
			@ServiceUnitUsageID);
		END
	SET NOCOUNT OFF
END	
GO

If Exists (Select name from sysobjects where name = 'usp_CancelAllServiceUnits' and type='P') Drop Procedure dbo.usp_CancelAllServiceUnits
Go

CREATE PROCEDURE dbo.usp_CancelAllServiceUnits
	@CompanyID int,
	@CancelEnterprise bit = 0
AS 
BEGIN 


	DECLARE @MyTable table (
	    ndx int identity(1,1),
		CompanyID int,
		ServiceUnitAllocationID int)

	IF (@CancelEnterprise = 1) BEGIN
		DECLARE @HQID int
		SELECT @HQID = comp_PRHQID
		  FROM Company WITH (NOLOCK)
		 WHERE comp_CompanyID = @CompanyID;

		INSERT INTO @MyTable (CompanyID, ServiceUnitAllocationID)
		SELECT prun_CompanyID, prun_ServiceUnitAllocationID
		  FROM PRServiceUnitAllocation 
		 WHERE prun_HQID = @HQID
		   AND prun_UnitsRemaining > 0
		   AND GETDATE() BETWEEN prun_StartDate AND prun_ExpirationDate
	
	END ELSE BEGIN

		INSERT INTO @MyTable (CompanyID, ServiceUnitAllocationID)
		SELECT prun_CompanyID, prun_ServiceUnitAllocationID
		  FROM PRServiceUnitAllocation 
		 WHERE prun_CompanyID = @CompanyID
		   AND prun_UnitsRemaining > 0
		   AND GETDATE() BETWEEN prun_StartDate AND prun_ExpirationDate
	END

	DECLARE @Index int, @Count int, @CurrentCompanyID int, @ServiceUnitAllocationID int

	SELECT @Count = COUNT(1) FROM @MyTable;
	SET @Index = 0

	WHILE (@Index < @Count) BEGIN
		SET @Index = @Index + 1

		SELECT @CurrentCompanyID = CompanyID,
		       @ServiceUnitAllocationID = ServiceUnitAllocationID
		  FROM @MyTable
		 WHERE ndx = @Index;

	
		EXEC usp_CancelServiceUnits @CurrentCompanyID, @ServiceUnitAllocationID

	END

END
Go

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

	-- Determine our Price
	DECLARE @UsageTypePrice int
	SELECT @UsageTypePrice = prsuu_Units 
      FROM PRServiceUnitUsage WITH (NOLOCK)
     WHERE prsuu_ServiceUnitUsageId = @OriginalServiceUnitUsageID;

	BEGIN TRANSACTION;
	BEGIN TRY

	-- Go Get our UniqueID
	DECLARE @ServiceUnitUsageID int
	--EXEC usp_getNextId 'PRServiceUnitUsage', @ServiceUnitUsageID Output

	-- Insert our ServiceUnitUsage record
	INSERT 
		INTO PRServiceUnitUsage (--prsuu_ServiceUnitUsageID,
			prsuu_CreatedBy, prsuu_CreatedDate,	prsuu_UpdatedBy, prsuu_UpdatedDate,	prsuu_TimeStamp,
			prsuu_CompanyID, prsuu_PersonID, prsuu_TransactionTypeCode, prsuu_UsageTypeCode,
			prsuu_RegardingObjectID, prsuu_SearchCriteria, prsuu_HQID,
			prsuu_SourceCode, prsuu_ReversalServiceUnitUsageId, prsuu_Units, prsuu_ReversalReasonCode )
		SELECT --@ServiceUnitUsageID,	
				@CRMUserID, @Now, @CRMUserID, @Now, @Now,
				prsuu_CompanyID, prsuu_PersonID, 'R', prsuu_UsageTypeCode,
				prsuu_RegardingObjectID, prsuu_SearchCriteria, prsuu_HQID,
				@SourceCode, @OriginalServiceUnitUsageID, @UsageTypePrice * -1, @ReversalReason
		  FROM PRServiceUnitUsage 
		 WHERE prsuu_ServiceUnitUsageId = @OriginalServiceUnitUsageID
	SELECT @ServiceUnitUsageID = SCOPE_IDENTITY();

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
		(SELECT prsua_ServiceUnitAllocationId 
           FROM PRServiceUnitAllocationUsage
		  WHERE prsua_ServiceUnitUsageId = @OriginalServiceUnitUsageID)
	 ORDER BY prun_ExpirationDate DESC, prun_CreatedDate DESC;

	SET @Count = @@ROWCOUNT
	SET @Ndx = 1	
	SET @UnitsReallocated = 0

	WHILE (@UnitsReallocated < @UsageTypePrice) BEGIN

		SELECT @ServiceUnitAllocationID = ServiceUnitAllocationID,
			   @AllocationUnitsDelta = AvailableToReallocate
		  FROM @ServiceUnitAllocations WHERE ndx = @Ndx;

		IF (@AllocationUnitsDelta = 0) BEGIN
			RAISERROR ('Unable to reverse this unit usage record.  The associated allocation record is already at capacity.', 
				       16,
				       -1);
		END 

		SET @Ndx = @Ndx + 1

		IF (@AllocationUnitsDelta >= @UsageTypePrice - @UnitsReallocated)
			SET @UnitAllocation = @UsageTypePrice - @UnitsReallocated
		ELSE
			SET @UnitAllocation = @AllocationUnitsDelta

		-- Restore as many AllocationUnits as possible
		UPDATE PRServiceUnitAllocation
		   SET prun_UnitsRemaining = prun_UnitsRemaining + @UnitAllocation,
			   prun_UpdatedDate = @Now, prun_Timestamp = @Now, prun_UpdatedBy = @CRMUserID
		 WHERE prun_ServiceUnitAllocationID = @ServiceUnitAllocationID;

		SET @UnitsReallocated = @UnitsReallocated + @UnitAllocation
		
		--
		-- Create the bridge entry
		--

		-- Insert our PRServiceUnitAllocationUsage record
		INSERT INTO PRServiceUnitAllocationUsage (
			prsua_CreatedBy, prsua_CreatedDate, prsua_UpdatedBy, prsua_UpdatedDate,	prsua_TimeStamp,
			prsua_ServiceUnitAllocationID, prsua_ServiceUnitUsageID)
		VALUES (
			@CRMUserID, @Now, @CRMUserID, @Now, @Now,
			@ServiceUnitAllocationID, @ServiceUnitUsageID);
	END

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

**/
CREATE PROCEDURE dbo.usp_AllocateServiceUnits
	@CompanyID int,
    @PersonID int,
	@Units int,
	@SourceType nvarchar(40),
	@AllocationType nvarchar(40),
	@StartDate datetime = null,
    @CRMUserID int = 0,
    @HQID int = null  -- Added by CHW for EBB v3.0
AS
BEGIN
	SET NOCOUNT ON

	-- If we don't have a CRM User, go get the
	-- default website user
	IF @CRMUserID = 0 BEGIN
		SET @CRMUserID = dbo.ufn_GetSystemUserId(1)
	END

	IF (@StartDate IS NULL) BEGIN
		SET @StartDate = CONVERT(DateTime, convert(varchar, GetDate(),101))
	END

	IF (@HQID IS NULL) BEGIN
		SELECT @HQID = comp_PRHQID
		  FROM Company WITH (NOLOCK)
		 WHERE comp_CompanyID = @CompanyID;
	END

	-- Compute our End Date
	-- For a membership allocation, it is the first day of the same month of the next year. (Note: will always be 1/1)
	-- For an additional unit pack allocation, it is the first day of the next month of the next year.
	DECLARE @EndDate datetime, @TempDate datetime
	IF @AllocationType = 'A' BEGIN
		SET @TempDate = DATEADD(Month, 1, @StartDate)
		SET @EndDate = CONVERT(DateTime, CONVERT(varchar(4), YEAR(@TempDate)+1) + '-' +  CONVERT(varchar(4), Month(@TempDate)) + '-1')
	END ELSE BEGIN
		SET @EndDate = CONVERT(DateTime, CONVERT(varchar(4), YEAR(@StartDate)+1) + '-01-01')
	END
	
	--
	--  If we're allocating units for a membership, look to see if any
	--  other active allocation records exist.  If so, they need to be cancelled
	--  and the previous amount used deducted from this total.
	--
	IF @AllocationType = 'M' BEGIN

		 DECLARE @CancelServiceUnitAllocationID int
		
		 SELECT @CancelServiceUnitAllocationID = prun_ServiceUnitAllocationID
		   FROM PRServiceUnitAllocation
		  WHERE prun_HQID = @HQID
		    AND prun_AllocationTypeCode = 'M'
			AND prun_UnitsRemaining > 0
		    AND GETDATE() BETWEEN prun_StartDate AND prun_ExpirationDate;
	
		IF (@CancelServiceUnitAllocationID IS NOT NULL) BEGIN
			
			DECLARE @CancelUnitQty int
			EXEC dbo.usp_CancelServiceUnits @CompanyID, @CancelServiceUnitAllocationID, @CancelUnitQty OUTPUT
			
			SET @Units = @Units - @CancelUnitQty;
			IF (@Units < 0) BEGIN
				SET @Units = 0
			END
		END ELSE BEGIN

			-- If we didn't find any current membership allocations to cancel
			-- Let's look to see if there are any previous membership allocations
			-- for this year that have been fully consumed.  If we find one, we
			-- need to adjust this membership allocation.
			DECLARE @PreviousUnitsAllocated int

			 SELECT @PreviousUnitsAllocated = SUM(prun_UnitsAllocated)
			   FROM PRServiceUnitAllocation
			  WHERE prun_HQID = @HQID
				AND prun_AllocationTypeCode = 'M'
				AND prun_UnitsRemaining = 0
				AND GETDATE() BETWEEN prun_StartDate AND prun_ExpirationDate;

			IF (@PreviousUnitsAllocated IS NOT NULL) BEGIN
				SET @Units = @Units - @PreviousUnitsAllocated;
				IF (@Units < 0) BEGIN
					SET @Units = 0
				END				
			END
		END
	END
	

	DECLARE @ServiceUnitAllocationID int
	EXEC usp_getNextId 'PRServiceUnitAllocation', @ServiceUnitAllocationID Output
		
	INSERT INTO PRServiceUnitAllocation (
			prun_ServiceUnitAllocationID,
			prun_CreatedBy,
			prun_CreatedDate,
			prun_UpdatedBy,
			prun_UpdatedDate,
			prun_TimeStamp,
			prun_HQID,
			prun_CompanyID,
			prun_PersonID,
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
			@HQID,
			@CompanyID,
			@PersonID,
			@SourceType,
			@AllocationType,
			@StartDate,
			@EndDate,
			@Units,
			@Units);

	SELECT @ServiceUnitAllocationID;

	SET NOCOUNT OFF
END
GO







/*
	-- Create a task for the assigned user

	@AssignedToUserType is used if the @AssignedToUser is not populated.  This will be used to look
		up a PRCo Specialist based upon the following user type (these match ufn_GetPRCoSpecialistUserId):
		0: prci_RatingUserId
		1: prci_InsideSalesRepId
		2: prci_FieldSalesRepId
		3: prci_ListingSpecialistId
		4: prci_CustomerServiceId
	@ChannelIdOverride - Provides the caller a way to override the channelid as opposed
		to using Priamry ChannelId of assigned user
*/
CREATE OR ALTER Procedure dbo.usp_CreateTask
    @StartDateTime datetime = null,
    @DueDateTime datetime = null,
    @CreatorUserId int = null,
    @AssignedToUserId int = null,
    @TaskNotes varchar(max) = null,
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
    @PRCreditSheetId int = null,
    @PRFileId int = null,
    @PRCategory varchar(40) = null,
	@AssignedToUserType tinyint = 0,
	@AssociatedColumnName varchar(40) = null,
    @PRSubcategory varchar(40) = null,
    @ChannelIdOverride int = 0,
    @HasAttachments char(1) = null,
    @WaveItemID int = null,
	@Subject varchar(255) = null
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
	-- once we have an assigned user, determine the channel id; if @ChannelIdOverride is specified, use it
	if (@ChannelIdOverride = 0)
	Begin
		SELECT @ChannelIdOverride = user_PrimaryChannelId from USers
		 WHERE user_userid = @AssignedToUserId
	End

	IF (@Subject IS NULL) BEGIN

		DECLARE @TruncateLimit int = 50
		DECLARE @Pos int
		SET @Pos = CHARINDEX('.', @TaskNotes)

		IF (@Pos > 0) BEGIN
			IF (@Pos <= @TruncateLimit) BEGIN
				SET @Subject = SUBSTRING(@TaskNotes, 1, @Pos)
			END ELSE BEGIN
				SET @Pos = CHARINDEX(' ', @TaskNotes, @TruncateLimit)	
				SET @Subject = SUBSTRING(@TaskNotes, 1, @Pos) + '...'			
			END
		END ELSE BEGIN
			-- If our task note does not contain a period, 
			-- just take the first # characters of the note
			IF LEN(@TaskNotes) <= @TruncateLimit BEGIN
				SET @Subject = @TaskNotes
			END ELSE BEGIN
				SET @Pos = CHARINDEX(' ', @TaskNotes, @TruncateLimit)	
				SET @Subject = SUBSTRING(@TaskNotes, 1, @Pos) + '...'			
			END
		END
	END


	INSERT INTO Communication
		(Comm_CommunicationId, Comm_CreatedBy, Comm_UpdatedBy, Comm_CreatedDate, Comm_UpdatedDate, Comm_TimeStamp
		   ,Comm_Type, Comm_Action, Comm_Status, Comm_Priority, Comm_DateTime, Comm_ToDateTime
           ,Comm_Note, Comm_NotifyTime, Comm_TaskReminder, Comm_SMSNotification
           ,comm_PRBusinessEventId ,comm_PRPersonEventId
           ,comm_PRCreditSheetId, comm_PRFileId ,comm_PRCategory, comm_PRAssociatedColumnName
           ,comm_PRSubcategory, comm_ChannelId, Comm_HasAttachments, comm_WaveItemID
		   , Comm_Subject)
     VALUES
           (@nextCommId, @CreatorUserId, @CreatorUserId, @Now, @Now, @Now,
				@Type, @Action, @Status, @Priority, @StartDateTime, @DueDateTime, 
				@TaskNotes, @ReminderDateTime, @ReminderFlag, @SMSNotification, 
	            @PRBusinessEventId, @PRPersonEventId,
		        @PRCreditSheetId, @PRFileId, @PRCategory, @AssociatedColumnName,
                @PRSubcategory, @ChannelIdOverride, @HasAttachments, @WaveItemID,
				@Subject);
		        
	INSERT INTO Comm_Link
           (CmLi_CommLinkId, CmLi_CreatedBy, CmLi_UpdatedBy, CmLi_CreatedDate, CmLi_UpdatedDate,CmLi_TimeStamp
           ,CmLi_Comm_UserId,CmLi_Comm_CommunicationId,CmLi_Comm_PersonId,CmLi_Comm_CompanyId,CmLi_Comm_NotifyTime)
     VALUES
           (@nextCommLinkId, @CreatorUserId, @CreatorUserId, @Now, @Now, @Now
           ,@AssignedToUserId, @nextCommId, @RelatedPersonId, @RelatedCompanyId, @ReminderDateTime);

	RETURN @nextCommId
END
GO


CREATE OR ALTER Procedure dbo.usp_CreateEmail
    @CreatorUserId int = null,
    @To varchar(max) = null,
    @From varchar(max) = null,
    @Subject varchar(max) = null,
    @Content varchar(max) = null,
    @Priority varchar(40) = 'Normal',
    @CC varchar(max) = null,
    @BCC varchar(max) = null,
    @AttachmentDir varchar(255) = null,
    @AttachmentFileName varchar(max) = null,
    @Content_Format varchar(20) = 'TEXT',
    @RelatedCompanyId int = NULL,
    @RelatedPersonId int = NULL,
    @Action varchar(40) = 'EmailOut',
    @DoNotRecordCommunication bit = 0,
    @DoNotSend bit = 0,
    @AttachmentIsLibraryDoc bit = 0,
    @RightFaxEmbeddedCodes varchar(500) = NULL,
    @PRCategory varchar(40) = NULL,
    @PRSubcategory varchar(40) = NULL,
    @PRRequestID int = NULL,
    @Who varchar(50) = NULL,
    @Source varchar(100) = NULL,
	@ProfileName varchar(100) = 'Blue Book Services'
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
             Comm_PRCategory, Comm_PRSubcategory, comm_RequestID, Comm_Subject
			)
		 VALUES
			(@nextCommId, @CreatorUserId, @CreatorUserId, @Now, @Now, @Now,
			 @Type, @Action, @Status, @Priority, @Now, 
			 @Subject, @Content, @From, @To, @CC, @BCC, @AttachmentDir, SUBSTRING(@AttachmentFileName, 1, 255), @HasAttachments,
             @PRCategory, @PRSubcategory, @PRRequestID, @Subject) 
	    

		INSERT INTO Comm_Link
			   (CmLi_CommLinkId, CmLi_CreatedBy, CmLi_UpdatedBy, CmLi_CreatedDate, CmLi_UpdatedDate,CmLi_TimeStamp
			   ,CmLi_Comm_UserId,CmLi_Comm_CommunicationId,CmLi_Comm_PersonId,CmLi_Comm_CompanyId)
		 VALUES
			   (@nextCommLinkId, @CreatorUserId, @CreatorUserId, @Now, @Now, @Now
			   ,@CreatorUserId, @nextCommId, @RelatedPersonId, @RelatedCompanyId)
	END


	DECLARE @CommunicationLogID int
	INSERT INTO PRCommunicationLog
		(prcoml_CompanyID, prcoml_PersonID, prcoml_AttachmentName, prcoml_Source, prcoml_Subject, prcoml_MethodCode, prcoml_Destination, prcoml_CreatedDate, prcoml_CreatedBy, prcoml_UpdatedDate, prcoml_UpdatedBy, prcoml_Timestamp)
	VALUES (@RelatedCompanyId, @RelatedPersonId, @AttachmentFileName, @Source, @Subject, @Action, @To, GETDATE(), @CreatorUserId, GETDATE(), @CreatorUserId, GETDATE())
	SET @CommunicationLogID = SCOPE_IDENTITY()
	

	-- Give the Caller a chance to not actually send the email
	IF (@DoNotSend = 0)
	BEGIN
		
	    -- if this is a fax, then write it
		-- to the faxqueue for processing by
		-- the windows service
		IF (@Action = 'FaxOut') BEGIN

			DECLARE @IsInternational bit
            DECLARE @WorkArea varchar(100)
            DECLARE @Override varchar(100)
			SET @IsInternational = 0

			-- check for our override
			SET @Override = dbo.ufn_GetCustomCaptionValueDefault('FaxOverride', 'Fax', @To)
			IF (@Override is not null)
				SET @To = @Override

			SET @WorkArea = @To

			-- it is possible for numbers to come in with a format of "1 (999) 999-9999"
			-- try to reformat these to "999 999-9999"
			SET @WorkArea = REPLACE(@WorkArea,'1 (', '')
			SET @WorkArea = REPLACE(@WorkArea,')', '')

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
				IF (SUBSTRING(@WorkArea, 1, 3) != '011')
				BEGIN				
					SET @To = '011 ' + @WorkArea
				END
			END

			DECLARE @PersonName varchar(100)

			-- Who is sending the fax?
			IF (@Who IS NULL) BEGIN
				SELECT @Who = RTRIM(user_Logon)
				  FROM Users
				 WHERE user_userID = @CreatorUserId;
			END

			-- Whom are we sending it to?
			SELECT @PersonName = dbo.ufn_FormatPerson(Pers_FirstName, Pers_LastName, Pers_MiddleName, Pers_PRNickname1, Pers_Suffix)
              FROM Person
             WHERE pers_PersonID = @RelatedPersonId;

			INSERT INTO PRFaxQueue (Who, Attachment, FaxNumber, PersonName, Priority, IsLibraryDocument, RightFaxEmbeddedCodes, CommunicationLogID)
			    VALUES (@Who, @AttachmentFileName, @To, @PersonName, @Priority, @AttachmentIsLibraryDoc, @RightFaxEmbeddedCodes, @CommunicationLogID);
		END
    

		IF (@Action = 'EmailOut') BEGIN

			SET @To = dbo.ufn_GetCustomCaptionValueDefault('EmailOverride', 'Email', @To)

			BEGIN TRY
				EXECUTE AS User = 'DBMailUser'; 
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
				-- now rethrow
				exec usp_RethrowError				

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
    @WebUserListId int = NULL,
    @WebUserListDetailId int = NULL,
    @MonitoredCompanyId int = null,
    @UserId int = -1
AS
BEGIN
    DECLARE @Msg varchar(2000)
    DECLARE @NewAUSId int
	DECLARE @bNew bit
	DECLARE @Cnt int;
	DECLARE @CompanyId int;
	DECLARE @TypeCode varchar(40);
	DECLARE @AssociatedType varchar(40);
	DECLARE @AccessLevel varchar(40);
	
	-- If we have a WebUserDetailID, then we can fill in the company and WebUser id's
	-- Note that if we have a WebUserListID, it will be replaced here.
    IF @WebUserListDetailID IS NOT NULL BEGIN

	    SELECT @WebUserListID = prwucl_WebUserListID,
               @CompanyID = PeLi_CompanyID,
               @TypeCode = prwucl_TypeCode,
               @AssociatedType = prwuld_AssociatedType,
               @AccessLevel = prwu_AccessLevel
          FROM Person_Link WITH (NOLOCK)
               INNER JOIN PRWebUser WITH (NOLOCK) On (prwu_PersonLinkID = PeLi_PersonLinkID)
               INNER JOIN PRWebUserList WITH (NOLOCK) On (prwucl_WebUserID = prwu_WebUserID)
               INNER JOIN PRWebUserListDetail WITH (NOLOCK) On (prwuld_WebUserListID = prwucl_WebUserListID)
         WHERE prwuld_WebUserListDetailID = @WebUserListDetailID;

    END ELSE IF @WebUserListID IS NOT NULL BEGIN

        SELECT @CompanyID = PeLi_CompanyID,
               @TypeCode = prwucl_TypeCode,
               @AccessLevel = prwu_AccessLevel
          FROM Person_Link WITH (NOLOCK)
               INNER JOIN PRWebUser WITH (NOLOCK) On (prwu_PersonLinkID = PeLi_PersonLinkID)
               INNER JOIN PRWebUserList WITH (NOLOCK) On (prwucl_WebUserID = prwu_WebUserID)
         WHERE prwucl_WebUserListID = @WebUserListID;
	END

	-- Error Checks
	SET @Msg = '';
	IF (@WebUserListID Is Null)
		SET @Msg = @Msg + 'WebUserListID is missing. ';
	
	IF (ISNULL(@TypeCode, '') <> 'AUS')
		SET @Msg = @Msg + 'Invalid User List of ''' + Coalesce(@TypeCode, '') + '''. ';

	--IF (Coalesce(Case IsNumeric(@AccessLevel) When 1 Then Cast(@AccessLevel As decimal) Else -1 End, -1) < 200)
	--	SET @Msg = @Msg + 'User does not have a high enough access level for and Alerts list. ';

	IF (@WebUserListDetailID IS NOT NULL)
		IF (ISNULL(@AssociatedType, '') <> 'C')
            SET @Msg = @Msg + 'Update Failed. Invalid Detail User List of ''' + Coalesce(@AssociatedType, '') + '''.';

    IF (@MonitoredCompanyID Is Null)
        SET @Msg = @Msg + 'Monitored Company is missing. ';

    IF (@CompanyID Is Null)
        SET @Msg = @Msg + 'Company is missing from Person Link. ';

	-- Duplicate Check (This should already have been filtered out on the screen, but included here in case the screen is bypassed.)
	IF @WebUserListDetailID Is Not Null And @MonitoredCompanyID Is Not Null
	Begin
		SELECT @Cnt = Count(1) 
		  FROM PRWebUserListDetail WITH (NOLOCK) 
		 WHERE prwuld_WebUserListID = @WebUserListId 
		   AND prwuld_AssociatedID = @MonitoredCompanyId 
		   AND prwuld_AssociatedType = 'C';

		IF (@Cnt > 0)
			SET @Msg = @Msg + 'Monitored Company Already Exists in this Alerts list. ';
	End

    IF (LEN(@Msg) > 0)
    BEGIN
        RAISERROR (@Msg, 16, 1)
        Return
    END
    
	-- Passed error checking, now add the record
	SET @bNew = 0
	IF (@WebUserListDetailId is null)
	BEGIN
		SET @bNew = 1
	END
    
	Declare @dtNow datetime
	SET @dtNow = getdate()

    BEGIN TRY
		-- Start making our updates
		BEGIN TRANSACTION

		-- Save the PRAUS record
		If (@bNew = 1)
		Begin
			INSERT INTO PRWebUserListDetail
			    (prwuld_CreatedBy, prwuld_CreatedDate, prwuld_UpdatedBy, prwuld_UpdatedDate, prwuld_TimeStamp,
			     prwuld_WebUserListID, prwuld_AssociatedID, prwuld_AssociatedType)
			VALUES
				(@UserId, @dtNow, @UserId, @dtNow, @dtNow,
				@WebUserListId, @MonitoredCompanyId, 'C')

		End
		Else
		Begin
			UPDATE PRWebUserListDetail 
			   SET prwuld_UpdatedBy = @UserId,
				   prwuld_UpdatedDate = @dtNow,
				   prwuld_TimeStamp = @dtNow,
				   prwuld_AssociatedID = @MonitoredCompanyId
			 WHERE prwuld_WebUserListDetailID = @WebUserListDetailID
		End

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
Updates the Alerts Settings for the specified person and company.  I included the
peli_personlinkid as a security measure. 
**/
If Exists (Select name from sysobjects where name = 'usp_AUSSettingsUpdate' and type='P')
    Drop Procedure dbo.usp_AUSSettingsUpdate
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
Updates the Email Settings for the specified person and company.
**/
If Exists (Select name from sysobjects where name = 'usp_EmailCampaignOptInSettingsUpdate' and type='P')
    Drop Procedure dbo.usp_EmailCampaignOptInSettingsUpdate
Go

CREATE PROCEDURE dbo.usp_EmailCampaignOptInSettingsUpdate (
	@PersonLinkID int,
	@ReceivesTrainingEmail bit = 0,
	@ReceivesPromoEmail bit = 0,
	@ReceivesBRSurveyEMail bit = 0,
    @CRMUserID int = 0,
	@PRAlertEmail varchar(255)
	)
AS 

-- If we don't have a CRM User, go get the
-- default website user
IF @CRMUserID = 0 BEGIN
	SET @CRMUserID = dbo.ufn_GetSystemUserId(1)
END

UPDATE Person_Link
   SET peli_PRReceivesTrainingEmail = Case @ReceivesTrainingEmail When 1 Then 'Y' Else Null End,
	   peli_PRReceivesPromoEmail = Case @ReceivesPromoEmail When 1 Then 'Y' Else Null End,
	   peli_PRReceiveBRSurvey = Case @ReceivesBRSurveyEMail When 1 Then 'Y' Else Null End,
	   peli_UpdatedBy = @CRMUserID,
       peli_UpdatedDate = GETDATE(),
       peli_TimeStamp = GETDATE(),
	   peli_PRAlertEmail = @PRAlertEmail
 WHERE peli_PersonLinkID = @PersonLinkID
Go


/**
    Creates the PRTESRequest record
	@CompanyId: The subject of the the trade experience requests
	@RequestCount: The total number of TES forms to be requested; will not be greater than 60

	Called from PRBBScore insert trigger
**/
If Exists (Select name from sysobjects where name = 'usp_CreateAutoTES' and type='P') 
	Drop Procedure dbo.usp_CreateAutoTES
Go

CREATE PROCEDURE dbo.usp_CreateAutoTES
	@CompanyId int,
	@RequestCount smallint = 60,
	@UserId int = -300,
    @Source varchar(40) = 'MI'
AS 
BEGIN
    DECLARE @NOW datetime
    SET @NOW = getDate()
    
    Declare @tblTESable table (ndx smallint identity, RelatedCompanyId int)

    -- Now get a list of "TES-able" companies ordered by the tier (1,2,3) value 
    -- and store it in the temporary table
    if (@RequestCount is not null and @RequestCount > 0)
    BEGIN TRY
       
		-- We will never request more than 60 reports; NEWID() randomizes the results
        insert into @tblTESable
          select RelatedCompanyId 
            from (
			        select top (@RequestCount) RelatedCompanyId from 
			        ( 
				       select RelatedCompanyId, prcr_Tier, UID=NEWID()
                         from dbo.ufn_GetEligibleTESResponders(@CompanyId)
                    ) ATable order by prcr_Tier, UID, RelatedCompanyId
		         )BTABLE
		   order by RelatedCompanyId;


        -- Walk through each result and create the appropriate PRTES and PRTesDetail recs
		DECLARE @TableNdx int, @TableCnt int
		DECLARE @RelatedCompanyId int, @PRTESNextId int, @PRTESDetailNextId int
		SELECT @TableCnt = Count(1) from @tblTESable
		SET @TableNdx = 1

		WHILE (@TableNdx <= @TableCnt)
		BEGIN
			Select @RelatedCompanyId = RelatedCompanyId from @tblTESable where ndx = @TableNdx
			
			EXEC usp_CreateTES 
				@RelatedCompanyId,
			    @CompanyId,
                NULL,
                @Source,
                @UserId

			SET @TableNdx = @TableNdx + 1
		END
    END TRY
    BEGIN CATCH
        SET ROWCOUNT 0
        exec usp_RethrowError
    END CATCH
END
GO


If Exists (Select name from sysobjects where name = 'usp_CreateTES' and type='P') 
	Drop Procedure dbo.usp_CreateTES
Go

CREATE PROCEDURE dbo.usp_CreateTES
	@ResponderCompanyID int,
	@SubjectCompanyID int,
    @SentMethod varchar(40) = null,
    @Source varchar(40) = 'MI',
    @UserId int = -300,
	@CreatedDate datetime = null,
    @OverrideAddress varchar(50) = null,
	@OverridePersonID int = null,
	@OverrideCustomAttention varchar(100) = null,
    @VerbalInvestigationID int = null,
	@IsSecondRequest varchar(1) = null
AS 
BEGIN

	IF (@CreatedDate IS NULL) 
		BEGIN
			SET @CreatedDate = GETDATE()
		END

	IF (@SentMethod IS NULL AND @Source = 'MI')
		BEGIN
			SELECT @SentMethod = CASE WHEN prattn_BBOSOnly IS NOT NULL THEN 'B'
			                          WHEN prattn_EMailID IS NOT NULL THEN 'E' 
									  WHEN prattn_PhoneID IS NOT NULL THEN 'F' 
									  ELSE NULL 
								 END
			  FROM PRAttentionLine 
			WHERE prattn_CompanyID = @ResponderCompanyID
			  AND prattn_ItemCode = 'TES-E' 
			  AND prattn_Disabled IS NULL
		END


	-- Insert the records
	INSERT INTO PRTESRequest( 
		prtesr_ResponderCompanyID, prtesr_SubjectCompanyID, prtesr_Source, prtesr_SentMethod, 
        prtesr_OverrideAddress, prtesr_CreatedBy, prtesr_CreatedDate, prtesr_UpdatedBy, prtesr_UpdatedDate, 
        prtesr_TimeStamp, prtesr_OverridePersonID, prtesr_OverrideCustomAttention, prtesr_VerbalInvestigationID,
		prtesr_SecondRequest)
	VALUES (
		@ResponderCompanyID, @SubjectCompanyID, @Source, @SentMethod, 
        @OverrideAddress, @UserId, GETDATE(), @UserId, GETDATE(), 
        GETDATE(), @OverridePersonID, @OverrideCustomAttention, @VerbalInvestigationID,
		@IsSecondRequest);


END
Go


/**
Creates the TESFormBatch and TESForm records in preparation for
creating a data extract.
**/
If Exists (Select name from sysobjects where name = 'usp_GenerateTESFormBatch' and type='P') Drop Procedure dbo.usp_GenerateTESFormBatch
Go

CREATE PROCEDURE dbo.usp_GenerateTESFormBatch 
	@SentMethod varchar(40),
    @Source varchar(40) = null,
    @ResponderLimit int = 999999
AS 
BEGIN


	--
	--  Before we do anything, make
	--  sure our TES data is cleanded.
	--
	EXEC usp_CleanupTESRequests

	DECLARE @PRTESBatchID int, 
			@PRTESFormID int,
			@BatchSubjectCount int

	DECLARE @FormType varchar(40), 
			@Language nvarchar(40),
			@Country nvarchar(40)

	DECLARE @RemainingCount int, 
			@ResponderRowCount int, 
			@ResponderNdx int, 
			@ResponderCompanyID int, 
			@CRMUserID int,
			@FormCount int,
			@PersonID int,
			@RowCount int

	DECLARE @Now datetime
	SET @Now = GETDATE()
	SET @BatchSubjectCount = 7
	
	IF (@Source IS NULL) BEGIN
		SELECT @Source = COALESCE(@Source + ',', '') + prtesr_Source
          FROM (SELECT DISTINCT prtesr_Source
		          FROM PRTESRequest WITH (NOLOCK)
		         WHERE prtesr_SentDateTime IS NULL) T1;
	END

	DECLARE @TESResponders table (
		ID int identity(1,1) PRIMARY KEY,
		ResponderCompanyID int,
		SubjectCount int
	)

	INSERT INTO @TESResponders (
		ResponderCompanyID,
		SubjectCount)
	SELECT TOP(@ResponderLimit) prtesr_ResponderCompanyID, 
		   COUNT(1)
	  FROM PRTESRequest
	 WHERE prtesr_TESFormID IS NULL
	   AND prtesr_SentMethod = @SentMethod
	   AND prtesr_SentDateTime IS NULL
       AND prtesr_Source IN (SELECT value FROM Tokenize(@Source, ','))
	GROUP BY prtesr_ResponderCompanyID
	ORDER BY prtesr_ResponderCompanyID;

	SET @ResponderRowCount = @@ROWCOUNT

	-- Create our batch record for mailed
    -- TES forms.
	IF ((@SentMethod = 'M') AND
        (@ResponderRowCount > 0)) BEGIN
		INSERT INTO PRTESFormBatch (
			prtfb_CreatedBy,
			prtfb_CreatedDate,
			prtfb_UpdatedBy,
			prtfb_UpdatedDate,
			prtfb_TimeStamp)
		VALUES (
			@CRMUserID,
			@Now,
			@CRMUserID,
			@Now,
			@Now);

		SELECT @PRTESBatchID = SCOPE_IDENTITY();
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
 		  FROM PRTESRequest
		 WHERE prtesr_ResponderCompanyID = @ResponderCompanyID
		   AND prtesr_SentMethod = @SentMethod
		   AND prtesr_TESFormID IS NULL
		   AND prtesr_Source IN (SELECT value FROM Tokenize(@Source, ','))
		   AND prtesr_Received IS NULL;

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
			INSERT INTO PRTESForm (
				prtf_CreatedBy,
				prtf_CreatedDate,
				prtf_UpdatedBy,
				prtf_UpdatedDate,
				prtf_TimeStamp,
				prtf_TESFormBatchID,
				prtf_CompanyID,
				prtf_SerialNumber,
				prtf_FormType,
                prtf_SentMethod)
			VALUES (
				@CRMUserID,
				@Now,
				@CRMUserID,
				@Now,
				@Now,
				@PRTESBatchID,
				@ResponderCompanyID,
				@PRTESFormID,
				@FormType,
                @SentMethod);

			SELECT @PRTESFormID = SCOPE_IDENTITY();

            UPDATE PRTESRequest
			   SET prtesr_TESFormID = @PRTESFormID,
			       prtesr_UpdatedDate = @Now,
			       prtesr_TimeStamp = @Now
			 WHERE prtesr_TESRequestID IN 
				(SELECT TOP(@BatchSubjectCount) prtesr_TESRequestID
					FROM PRTESRequest
				 WHERE prtesr_ResponderCompanyID = @ResponderCompanyID
					AND prtesr_TESFormID IS NULL
                    AND prtesr_SentMethod = @SentMethod
                    AND prtesr_Source IN (SELECT value FROM Tokenize(@Source, ','))
		            AND prtesr_Received IS NULL
		       ORDER BY prtesr_SubjectCompanyID);


			-- Compute a new count
			SET @RowCount = @@ROWCOUNT
			IF (@RowCount = 0) BEGIN
				SET @RemainingCount = 0
			END ELSE BEGIN
				SET @RemainingCount = @RemainingCount - @RowCount
			END
		END
	END

	SELECT @FormCount = COUNT(1)
	  FROM PRTESForm
	 WHERE prtf_TESFormBatchID = @PRTESBatchID;

	SELECT @PRTESBatchID, @FormCount;
END
Go


/**
 Processes the Teleform TES Response creating the PRTradeReport record as well as updating
 the various TES records.
**/

If Exists (Select name from sysobjects where name = 'usp_ProcessTESResponse' and type='P')
    Drop Procedure dbo.usp_ProcessTESResponse
Go

CREATE PROCEDURE dbo.usp_ProcessTESResponse
	@Serial_No Numeric(8,0),
	@Form_ID Numeric(10,0) ,
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
	@DealtSeasonal numeric(1,0) = null,
	@DeliveredPrice numeric(1,0) = null,
	@PAS numeric(1,0) = null
AS
BEGIN
	DECLARE @Flag bit
	DECLARE @Count int, @TESRequestID int, @TESFormID int, @TradeReportID int, @CRMUserID int, @CRMTaskUserID int
	DECLARE @FormType varchar(40)

	SET @CRMUserID = 1;

	-- Do some quick data validation
	SELECT @TESRequestID = prtesr_TESRequestID,
		   @TESFormID = prtf_TESFormID,
		   @FormType = prtf_FormType
	  FROM PRTESForm WITH (NOLOCK)
		   INNER JOIN PRTESRequest WITH (NOLOCK) ON prtf_TESFormID = prtesr_TESFormID
	WHERE prtf_SerialNumber = @Serial_No
	  AND prtesr_ResponderCompanyID = @Dest_ID
	  AND prtesr_SubjectCompanyID = @Subject_BBID;

	-- If the TESID is null, then something ain't right. 
	-- Now go figure out what it is and handle it.
	IF @TESRequestID IS NULL BEGIN  
	
		DECLARE @ErrorMsg varchar(1000)
		SET @ErrorMsg = ''
	    
		-- Does this Serial # exist?
		SET @Flag = 0

		SELECT @Flag = 1
          FROM PRTESForm WITH (NOLOCK)
         WHERE prtf_SerialNumber = @Serial_No;

		IF @Flag = 0 BEGIN
			SET @ErrorMsg = 'Serial Number ' + Cast(@Serial_No As Varchar(30)) + 'Not Found.  '	
		END

		-- Validate the Subject ID
		SET @Flag = 0
		SELECT @Flag = 1
		  FROM PRTESForm WITH (NOLOCK)
               INNER JOIN PRTESRequest WITH (NOLOCK) ON prtf_TESFormID = prtesr_TESFormID
		 WHERE prtf_SerialNumber = @Serial_No
		   AND prtesr_SubjectCompanyID = @Subject_BBID;

		IF @Flag = 0 BEGIN
			SET @ErrorMsg = @ErrorMsg + 'Subject BBID ' + Cast(ISNULL(@Subject_BBID, '<NULL>') As Varchar(30)) + ' Not Found for Serial Number ' + Cast(@Serial_No As Varchar(30)) + '.  '
		END

		-- Validate the Responder ID
		SET @Flag = 0
		SELECT @Flag = 1
		  FROM PRTESForm WITH (NOLOCK)
               INNER JOIN PRTESRequest WITH (NOLOCK) ON prtf_TESFormID = prtesr_TESFormID
		 WHERE prtf_SerialNumber = @Serial_No
		   AND prtesr_ResponderCompanyID = @Dest_ID;

		IF @Flag = 0 BEGIN
			SET @ErrorMsg = @ErrorMsg + 'Responder BBID ' + Cast(ISNULL(@Dest_ID, '<NULL>') As Varchar(30)) + ' Not Found for Serial Number ' + Cast(@Serial_No As Varchar(30)) + '.  '
		END

		IF @CSID IS NOT NULL BEGIN
			SET @ErrorMsg = @ErrorMsg + 'Fax File Name = ' + @CSID + '.'
		END

		SET @CRMTaskUserID = 1;
		SELECT @CRMTaskUserID = cast(capt_US as varchar) -- cannot cast directly to int
          FROM custom_captions
		 WHERE capt_family = 'AssignmentUserID'
		   AND capt_code = 'DataProcessor';

		DECLARE @TaskDate datetime
		SET @TaskDate = GETDATE()
		EXEC usp_CreateTask @TaskDate, @TaskDate, @CRMUserID, @CRMTaskUserID, @ErrorMsg, NULL, NULL, 'Pending';

	END ELSE BEGIN

		DECLARE @ComputedTerms varchar(40)
		IF (@Cash_Only = 1) BEGIN
			SET @ComputedTerms = ',1'
		END

		IF (@Firm_Price = 1) BEGIN
			SET @ComputedTerms = COALESCE(@ComputedTerms,'') + ',2'
		END

		IF (@On_Consignment = 1) BEGIN
			SET @ComputedTerms = COALESCE(@ComputedTerms,'') + ',3'
		END

		IF (@Other_Terms = 1) BEGIN
			SET @ComputedTerms = COALESCE(@ComputedTerms,'') + ',4'
		END

		IF (@DeliveredPrice = 1) BEGIN
			SET @ComputedTerms = COALESCE(@ComputedTerms,'') + ',5'
		END

		IF (@PAS = 1) BEGIN
			SET @ComputedTerms = COALESCE(@ComputedTerms,'') + ',6'
		END


		IF (LEN(@ComputedTerms) > 0) BEGIN
			SET @ComputedTerms = @ComputedTerms + ','
		END

		DECLARE @RelationshipLength varchar(40)
		
		IF (@Dealt1To6 = 1) BEGIN
			SET @RelationshipLength = 'A'
		END ELSE BEGIN

			IF (@Dealt7To12 = 1) BEGIN
				SET @RelationshipLength = 'B'
			END 

			ELSE BEGIN
				
				IF (@DealtOver1Year = 1) 
				BEGIN
					SET @RelationshipLength = 'C'
				END
			END
		END

		-- Having FS1 in the CSID field indicates
		-- this is a fax
		DECLARE @HowReceived varchar(40)
		IF (CHARINDEX('FS1', @CSID) = 0) BEGIN
				SET @HowReceived = 'M'
		END ELSE BEGIN
			SET @HowReceived = 'FD'
		END

		DECLARE @PayRating varchar(40)

		IF (@Form_ID IN (56300,56299,11837,11838,45267,45266,24528,24527)) BEGIN
			SET @PayRating = CASE @Pay
								WHEN 'F'  THEN '2'
								WHEN 'E'  THEN '3'
								WHEN 'D'  THEN '4'
								WHEN 'C'  THEN '5'
								WHEN 'B'  THEN '6'
								WHEN 'AB' THEN '8'
								WHEN 'A'  THEN '9'
								WHEN 'AA' THEN '9'
							ELSE NULL END
		END ELSE BEGIN
			SET @PayRating = CASE @Pay
								WHEN 'F'  THEN '2'
								WHEN 'E'  THEN '3'
								WHEN 'D'  THEN '4'
								WHEN 'C'  THEN '5'
								WHEN 'B'  THEN '6'
								WHEN 'A'  THEN '8'
								WHEN 'AA' THEN '9'
							ELSE NULL END	
		END	
			
		-- Make sure at least one field was responded to before we create the entry.  It's possible a user
		-- did not respond about all subjects on a multi-form, so we want to avoid created essentially empty
		-- records
		IF (@Integrity_Ability IS NOT NULL 
			OR @Pay IS NOT NULL 
			OR @Deal_Regularly IS NOT NULL 
			OR @How_Does_Subject_Firm_Act IS NOT NULL 
			OR @Cash_Only IS NOT NULL 
			OR @Firm_Price IS NOT NULL 
			OR @On_Consignment IS NOT NULL 
			OR @Other_Terms IS NOT NULL 
			OR @Invoice_On_Ship_Day IS NOT NULL 
			OR @Payment_Trend IS NOT NULL 
			OR @How_Long_Dealt IS NOT NULL 
			OR @How_Recently_Dealt IS NOT NULL 
			OR @Product_Kickers IS NOT NULL 
			OR @Pack IS NOT NULL 
			OR @Encourage_Sales IS NOT NULL 
			OR @Collect_Remit IS NOT NULL 
			OR @Credit_Terms IS NOT NULL 
			OR @High_Credit IS NOT NULL 
			OR @Amount_Past_Due IS NOT NULL 
			OR @Good_Equipment IS NOT NULL 
			OR @Claims_Handled_Properly IS NOT NULL 
			OR @Loads_Per_Year IS NOT NULL 
			OR @Pays_Freight IS NOT NULL 
			OR @Reliable_Carriers IS NOT NULL 
			OR @OutOfBusiness IS NOT NULL 
			OR @Pay_Dispute IS NOT NULL 
			OR @Dealt1To6 IS NOT NULL 
			OR @Dealt7To12 IS NOT NULL 
			OR @DealtOver1Year IS NOT NULL 
			OR @DealtSeasonal IS NOT NULL) 
			BEGIN
				EXEC usp_getNextId 'PRTradeReport', @TradeReportID Output

				INSERT INTO PRTradeReport 
				(
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
					prtr_TESRequestID,
					prtr_ResponseSource
				)
				VALUES 
				(
					@TradeReportID,
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
					@PayRating,
					@High_Credit,
					@Credit_Terms,
					@Amount_Past_Due,
					CASE @Invoice_On_Ship_Day WHEN 'Y' THEN 'Y' ELSE NULL END,
					CASE @Pay_Dispute WHEN 'Y' THEN 'Y' ELSE NULL END,
					@Payment_Trend,
					@Loads_Per_Year,
					@TESRequestID,
					'T'
					);
			END


		UPDATE PRTESForm
		   SET prtf_UpdatedBy = @CRMUserID,
			   prtf_UpdatedDate = GETDATE(),
			   prtf_Timestamp =  GETDATE(),
			   prtf_ReceivedDateTime = CAST(@Time_Stamp AS datetime),
			   prtf_ReceivedMethod = @HowReceived,
			   prtf_FaxFileName = @CSID,
			   prtf_TeleformId = @Form_ID
		 WHERE prtf_TESFormID = @TESFormID;

		UPDATE PRTESRequest
		   SET prtesr_UpdatedBy = @CRMUserID,
  			   prtesr_UpdatedDate = GETDATE(),
			   prtesr_Timestamp =  GETDATE(),
			   prtesr_Received = 'Y',
			   prtesr_ReceivedDateTime = GETDATE(),
			   prtesr_ReceivedMethod = @HowReceived
		 WHERE prtesr_TESFormID = @TESFormID
		   AND prtesr_SubjectCompanyID = @Subject_BBID;
	END
END	
Go


/**
**/
If Exists (Select name from sysobjects where name = 'usp_AddOnlineTradeReport' and type='P') 
	Drop Procedure dbo.usp_AddOnlineTradeReport
Go

/**
Adds a PRTradeReport record from the PRCo web site
**/
CREATE PROCEDURE [dbo].[usp_AddOnlineTradeReport]
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
	 @Terms varchar(40) = null,
	 @Loads char(1) = null,
	 @Kicks char(1) = null,
	 @CollectRemit char(1) = null,
	 @Doubtful char(1) = null, -- Encourage Sales
	 @Prompt char(1) = null,
	 @PayFreight char(1) = null,
	 @Secures char(1) = null, -- Good Equipment
	 @Timely char(1) = null,
	 @Pack char(1) = null,
	 @Summary varchar(max) = null,
	 @ResponseSource varchar(40) = 'W',
	 @SerialNumber varchar(10) = null,  -- Added by CHW for EBB v3.0
	 @PRWebUserID int = null,  -- Added by CHW for EBB v3.0
	 @OutOfBusiness char(1) = null,  -- Added by CHW for EBB v3.0
	 @PRTESRequestID int = null -- Added by MM
AS 
	DECLARE @TradeReportID int, @CRMUserID int, @AssignedToUserID int
	DECLARE @TESRequestID int, @TESFormID int

	-- If we don't have a TES Request ID, then this may be an unsolicted
	-- submission, or perhaps the user was sent a form via mail/fax, and 
	-- is repsonding via online.	
	IF @PRTESRequestID IS NULL BEGIN
	
		IF @SerialNumber IS NULL BEGIN
			-- Implement fuzzy logic to handle matching online submissions
			-- with previously sent TES forms.
			SELECT @TESRequestID = prtesr_TESRequestID,
				   @TESFormID = prtf_TESFormID
			  FROM PRTESForm WITH (NOLOCK)
				   INNER JOIN PRTESRequest WITH (NOLOCK) ON prtf_TESFormID = prtesr_TESFormID
			 WHERE prtesr_ResponderCompanyID = @Responder_BBID
			   AND prtesr_SubjectCompanyID = @Subject_BBID
			   AND prtesr_Received IS NULL
			   AND DATEDIFF(day, GETDATE(), prtf_SentDateTime) <= 30;

		END ELSE BEGIN
			-- Otherwise use the specified Serial Number
			SELECT @TESRequestID = prtesr_TESRequestID,
				   @TESFormID = prtf_TESFormID
			  FROM PRTESForm WITH (NOLOCK)
				   INNER JOIN PRTESRequest WITH (NOLOCK) ON prtf_TESFormID = prtesr_TESFormID
			 WHERE prtesr_ResponderCompanyID = @Responder_BBID
			   AND prtesr_SubjectCompanyID = @Subject_BBID
			   AND prtesr_Received IS NULL
			   AND prtf_SerialNumber = @SerialNumber;
		END

	END ELSE BEGIN
		-- We are doing this so that we do not have to modify much of the code below.
		SET @TESRequestID = @PRTESRequestID
		
		-- Otherwise use the specified Serial Number
		SELECT @TESFormID = prtesr_TESFormID
		  FROM PRTESRequest WITH (NOLOCK)
		 WHERE prtesr_TESRequestID = @PRTESRequestID;
	END



	IF @PRWebUserID IS NULL BEGIN
		SET @CRMUserID = dbo.ufn_GetSystemUserId(1);
	END ELSE BEGIN
		SET @CRMUserID = @PRWebUserID;
	END


	SET @AssignedToUserID = dbo.ufn_GetPRCoSpecialistUserId(@Subject_BBID, 0);

	
	-- Only process the data if any data was specified
	--
	IF(@HowLong IS NOT NULL OR @HowRecently IS NOT NULL OR @Seasonal IS NOT NULL OR
		@DealRegularly IS NOT NULL OR @Integrity IS NOT NULL OR @Pay IS NOT NULL OR
		@HighCredit IS NOT NULL OR @CreditTerms IS NOT NULL OR @PastDue IS NOT NULL OR
		@InvoiceOnSameDay IS NOT NULL OR @BeyondTerms IS NOT NULL OR @OverallPay IS NOT NULL OR
		@SubjectActs IS NOT NULL OR @Terms IS NOT NULL OR @Loads IS NOT NULL OR
		@Kicks IS NOT NULL OR @CollectRemit IS NOT NULL OR @Doubtful IS NOT NULL OR @Prompt IS NOT NULL OR
		@PayFreight IS NOT NULL OR @Secures IS NOT NULL OR @Timely IS NOT NULL OR @Pack IS NOT NULL OR @OutOfBusiness IS NOT NULL)
		BEGIN

			IF (@Summary = '') BEGIN
				SET @Summary = NULL
			END

			EXEC usp_getNextId 'PRTradeReport', @TradeReportID Output
			INSERT INTO PRTradeReport 
			(
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
				prtr_CommentsFlag,
				prtr_ResponseSource,
				prtr_OutOfBusiness,
				prtr_TESRequestID
			)
			VALUES 
			(
				@TradeReportID,
				@CRMUserID,
				GetDate(),
				@CRMUserID,
				GetDate(),
				GetDate(),
				@Responder_BBID, 
				@Subject_BBID,
				GetDate(),
				CASE @DoNotDeal WHEN 'Y' THEN 'Y' ELSE NULL END, 
				@HowRecently,
				@HowLong,
				CASE @DealRegularly WHEN 'Y' THEN 'Y' ELSE NULL END, 
				CASE @Seasonal WHEN 'Y' THEN 'Y' ELSE NULL END, 
				@SubjectActs,
				@Terms,
				CASE @Kicks WHEN 'Y' THEN 'Y' ELSE NULL END,
				CASE @CollectRemit WHEN 'Y' THEN 'Y' ELSE NULL END,
				CASE @Prompt WHEN 'Y' THEN 'Y' ELSE NULL END,
				CASE @Secures WHEN 'Y' THEN 'Y' ELSE NULL END,
				@Pack,
				CASE @Doubtful WHEN 'Y' THEN 'Y' ELSE NULL END,
				CASE @PayFreight WHEN 'Y' THEN 'Y' ELSE NULL END,
				CASE @Timely WHEN 'Y' THEN 'Y' ELSE NULL END,
				@Integrity,
				@Pay,
				@HighCredit,
				@CreditTerms,
				@PastDue,
				CASE @InvoiceOnSameDay WHEN 'Y' THEN 'Y' ELSE NULL END,
				CASE @BeyondTerms WHEN 'Y' THEN 'Y' ELSE NULL END,
				@OverallPay,
				@Loads,
				@Summary,
				CASE WHEN @Summary IS NOT NULL THEN 'Y' ELSE NULL END,
				@ResponseSource,
				@OutOfBusiness,
				@TESRequestID
			);
		END	
						
		IF (@TESRequestID IS NOT NULL) BEGIN
			UPDATE PRTESRequest
			   SET prtesr_UpdatedBy = @CRMUserID,
				   prtesr_UpdatedDate = GETDATE(),
				   prtesr_Timestamp =  GETDATE(),
				   prtesr_Received = 'Y',
				   prtesr_ReceivedDateTime = GETDATE(),
				   prtesr_ReceivedMethod = 'OL',
				   prtesr_SentDateTime = ISNULL(prtesr_SentDateTime, prtesr_CreatedDate)
			 WHERE prtesr_TESRequestID = @TESRequestID;
		END

		IF (@TESFormID IS NOT NULL) BEGIN
			UPDATE PRTESForm
			   SET prtf_UpdatedBy = @CRMUserID,
				   prtf_UpdatedDate = GETDATE(),
				   prtf_Timestamp =  GETDATE(),
				   prtf_ReceivedDateTime = GETDATE(),
				   prtf_ReceivedMethod = 'OL'
			 WHERE prtf_TESFormID = @TESFormID;
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
If Exists (Select name from sysobjects where name = 'usp_SetRequiredTESRequestCount2' and type='P') Drop Procedure   usp_SetRequiredTESRequestCount2
Go

CREATE PROCEDURE [dbo].[usp_SetRequiredTESRequestCount2]
  @comp_CompanyId int,
  @prbs_BBScoreId int,
  @prbs_UpdatedBy int,
  @prbs_p975Surveys int,
  @prbs_Date datetime,
  @UpdateBBScoreRecord bit = 0
AS
BEGIN

    DECLARE @MinPerQuarter int
    DECLARE @RequiredReportCount int

    SET @MinPerQuarter = CASE
          WHEN CAST (@prbs_p975Surveys AS INT)%4 = 0 THEN @prbs_p975Surveys / 4
          ELSE ROUND(@prbs_p975Surveys / 4+.5, 0)
         END

    -- use the helper function to get the required number of tes requests to send
    Exec @RequiredReportCount = ufn_GetRequiredTESRequestCount 
                                    @comp_CompanyId,
                                    @prbs_Date,
                                    @prbs_p975Surveys,
                                    @MinPerQuarter

	IF (@UpdateBBScoreRecord = 1) BEGIN
		UPDATE PRBBScore 
		   SET prbs_RequiredReportCount = @RequiredReportCount
		 WHERE prbs_BBScoreId = @prbs_BBScoreId;
	END
    
    RETURN @RequiredReportCount
    
END
GO



/**
Sets required report count in a specified company's current BB Score record
**/
If Exists (Select name from sysobjects where name = 'usp_SetRequiredTESRequestCount' and type='P') Drop Procedure   usp_SetRequiredTESRequestCount
Go

CREATE PROCEDURE [dbo].[usp_SetRequiredTESRequestCount]
  @comp_CompanyId int,
  @UpdateBBScoreRecord bit = 0
AS
BEGIN

    DECLARE @MinPerQuarter int
    DECLARE @RequiredReportCount int
	DECLARE @prbs_BBScoreId int
	DECLARE @prbs_UpdatedBy int
    DECLARE @prbs_MinimumTradeReportCount int
    DECLARE @prbs_Date datetime

    SELECT @prbs_BBScoreId = prbs_BBScoreId,
	       @prbs_Date = prbs_Date,
	       @prbs_MinimumTradeReportCount = prbs_MinimumTradeReportCount,
           @MinPerQuarter = CASE
                 WHEN CAST (prbs_MinimumTradeReportCount AS INT)%4 = 0 THEN prbs_MinimumTradeReportCount / 4
                 ELSE ROUND(prbs_MinimumTradeReportCount / 4+.5, 0)
           END
      FROM PRBBScore
     WHERE prbs_CompanyId = @comp_CompanyId AND prbs_Current = 'Y'


    RETURN EXEC usp_SetRequiredTESRequestCount2 @comp_CompanyId,
			 							   @prbs_BBScoreId,
										   @prbs_UpdatedBy,
										   @prbs_MinimumTradeReportCount,
										   @prbs_Date,
										   @UpdateBBScoreRecord
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
  @prbs_BBScoreId int,
  @prbs_CurrentBBScore float,
  @prbs_CurrentRecency varchar(20),
  @prbs_OldBBScore float = NULL,
  @prbs_UpdatedBy int = NULL
AS
BEGIN

	DECLARE @prra_RatingId int
	DECLARE @prra_AssignedRatingNumerals varchar(100)
	DECLARE @prra_IntegrityID int
	DECLARE @prra_PayRatingID int
    DECLARE @prra_Rated char(1)
    DECLARE @prbs_Recency varchar(20)

	-- get the integrity rating, pay rating and the rating numerals
	SELECT @prra_RatingId = prra_RatingId,
		 @prra_AssignedRatingNumerals = prra_AssignedRatingNumerals,
		 @prra_IntegrityID = prra_IntegrityID,
		 @prra_PayRatingID = prra_PayRatingID,
         @prra_Rated = prra_Rated
	FROM vPRCurrentRating
	WHERE prra_CompanyId = @comp_CompanyId;


	IF (@prra_Rated IS NOT NULL) BEGIN

		IF ((ISNULL(@prbs_OldBBScore, 0) >= 600) AND
            (@prbs_CurrentBBScore < 600) AND
            (@prra_IntegrityID IN (4,5,6))) BEGIN

			EXEC usp_CreateException 'BBScore', @prbs_BBScoreId, @prbs_UpdatedBy
		END ELSE BEGIN
	     
		IF ((@prbs_CurrentBBScore < 600) AND
            (@prra_IntegrityID IN (4,5,6)) AND
			(CAST(@prbs_CurrentRecency AS INT) >= 3)) BEGIN
				EXEC usp_CreateException 'BBScore', @prbs_BBScoreId, @prbs_UpdatedBy
			END
		END

	END
END

GO



/**
Returns the PersonIDs and Companiesthat have Alerts changes for the specified
time frame.
**/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetAUSReportItems]
  @StartDate datetime,
  @EndDate datetime,
  @ReceiveMethod varchar(50)
AS
BEGIN
	DECLARE @BBSSuppressAUSandReport bit = 0
	IF dbo.ufn_GetCustomCaptionValue('BBSSuppressAUSandReport','BBSSuppressAUSandReport', 'en-us') IS NOT NULL BEGIN
		SELECT @BBSSuppressAUSandReport = dbo.ufn_GetCustomCaptionValue('BBSSuppressAUSandReport','BBSSuppressAUSandReport', 'en-us') 
	END

	DECLARE @MyTable table (
		peli_PersonID int,
		peli_CompanyID int,
        prwu_Culture varchar(50),
		[Count] int
	)
	DECLARE @ListType varchar(10) = 'AUS'
	DECLARE @KeyOnlyChanges varchar(10) = '1'
	DECLARE @AllChanges varchar(10) = '2'

	INSERT INTO @MyTable
	SELECT peli_PersonID, peli_CompanyID, prwu_Culture, COUNT(1) AS [Count]
        FROM PRWebUserList WITH (NOLOCK)
            INNER JOIN PRWebUserListDetail WITH (NOLOCK) on prwucl_WebUserListID = prwuld_WebUserListID
            INNER JOIN PRWebUser WITH (NOLOCK) on prwucl_WebUserID = prwu_WebUserID
            INNER JOIN PRCreditSheet WITH (NOLOCK) on prwuld_AssociatedID = prcs_CompanyID
            INNER JOIN Person_Link WITH (NOLOCK) on prwu_PersonLinkID = peli_PersonLinkID
            LEFT OUTER JOIN PRCompanyIndicators WITH (NOLOCK) ON prci2_CompanyID = peli_CompanyID
        WHERE prwucl_TypeCode = @ListType
			AND prwu_Disabled IS NULL
			AND prwu_ServiceCode IS NOT NULL
			AND prcs_PublishableDate BETWEEN @StartDate AND @EndDate
			AND peli_PRAUSReceiveMethod=@ReceiveMethod
			AND prcs_Status = 'P' -- Publishable
			AND prcs_NewListing IS NULL
			AND peli_PRStatus = '1'
			AND ISNULL(prcs_KeyFlag, 'N') = CASE WHEN peli_PRAUSChangePreference = @KeyOnlyChanges THEN 'Y' ELSE ISNULL(prcs_KeyFlag, 'N')  END
			AND prci2_Suspended IS NULL
		GROUP BY peli_PersonID, peli_CompanyID, prwu_Culture
	INSERT INTO @MyTable
    SELECT peli_PersonID, peli_CompanyID, prwu_Culture, COUNT(1) AS [Count]
        FROM PRWebUserList WITH (NOLOCK)
			INNER JOIN PRWebUser WITH (NOLOCK) on prwucl_WebUserID = prwu_WebUserID
		    INNER JOIN Person_Link WITH (NOLOCK) on prwu_PersonLinkID = peli_PersonLinkID
            INNER JOIN PRBusinessReportRequest WITH (NOLOCK) ON peli_PersonID = prbr_RequestingPersonID and peli_CompanyID = prbr_RequestingCompanyID
            INNER JOIN PRCreditSheet WITH (NOLOCK) on prbr_RequestedCompanyID = prcs_CompanyID
            LEFT OUTER JOIN PRCompanyIndicators WITH (NOLOCK) ON prci2_CompanyID = peli_CompanyID
        WHERE prwucl_TypeCode = @ListType
			AND prwu_Disabled IS NULL
			AND prwu_ServiceCode IS NOT NULL
			AND prcs_PublishableDate BETWEEN @StartDate AND @EndDate
			AND peli_PRAUSReceiveMethod=@ReceiveMethod
			AND prcs_Status = 'P' -- Publishable
			AND prcs_NewListing IS NULL
			AND peli_PRStatus = '1'
			AND ISNULL(prcs_KeyFlag, 'N') = CASE WHEN peli_PRAUSChangePreference = @KeyOnlyChanges THEN 'Y' ELSE ISNULL(prcs_KeyFlag, 'N')  END
			AND prbr_CreatedDate > DATEADD(month, -6, GETDATE())
			AND prci2_Suspended IS NULL
		GROUP BY peli_PersonID, peli_CompanyID, prwu_Culture
	INSERT INTO @MyTable
      SELECT peli_PersonID, peli_CompanyID, prwu_Culture, COUNT(1) AS [Count]--, 'News'
          FROM PRWebUserList WITH (NOLOCK)
                INNER JOIN PRWebUserListDetail WITH (NOLOCK) on prwucl_WebUserListID = prwuld_WebUserListID
                INNER JOIN PRWebUser WITH (NOLOCK) on prwucl_WebUserID = prwu_WebUserID
			    INNER JOIN (
				    SELECT wppmac.*, ca.*, post_date FROM WordPressProduce.dbo.wp_posts WITH (NOLOCK)
					    LEFT OUTER JOIN WordPressProduce.dbo.wp_PostMeta wppmac WITH (NOLOCK) ON wp_posts.ID = wppmac.post_id AND meta_key = 'associated-companies'
					    LEFT OUTER JOIN (SELECT post_ID FROM WordPressProduce.dbo.wp_PostMeta WHERE meta_key='blueprintEdition') bpe ON bpe.post_ID = wp_posts.ID
					    CROSS APPLY CRM.dbo.Tokenize(meta_value, ',') ca
				    WHERE
					    post_type = 'post'
					    AND post_status in('publish')
					    AND post_date BETWEEN @StartDate AND @EndDate
					    AND meta_value IS NOT NULL
						AND (bpe.post_ID IS NULL OR dbo.ufn_GetWordPressBluePrintsEdition(ID) = '')
			    ) wp ON wp.value = prwuld_AssociatedID
                INNER JOIN Person_Link WITH (NOLOCK) on prwu_PersonLinkID = peli_PersonLinkID
                LEFT OUTER JOIN PRCompanyIndicators WITH (NOLOCK) ON prci2_CompanyID = peli_CompanyID
         WHERE prwucl_TypeCode = @ListType
			AND prwu_Disabled IS NULL
			AND prwu_ServiceCode IS NOT NULL
			AND wp.post_date BETWEEN @StartDate AND @EndDate
			AND peli_PRAUSReceiveMethod=@ReceiveMethod
			AND peli_PRStatus = '1'
			AND peli_PRAUSChangePreference = @AllChanges
			AND prci2_Suspended IS NULL
	  GROUP BY peli_PersonID, peli_CompanyID, prwu_Culture
	INSERT INTO @MyTable
      SELECT peli_PersonID, peli_CompanyID, prwu_Culture, COUNT(1) AS [Count]--, 'Special Services'
          FROM PRWebUserList WITH (NOLOCK)
               INNER JOIN PRWebUserListDetail WITH (NOLOCK) on prwucl_WebUserListID = prwuld_WebUserListID
               INNER JOIN PRWebUser WITH (NOLOCK) on prwucl_WebUserID = prwu_WebUserID
               INNER JOIN PRSSFile WITH (NOLOCK) on prwuld_AssociatedID = prss_RespondentCompanyId
               INNER JOIN Person_Link WITH (NOLOCK) on prwu_PersonLinkID = peli_PersonLinkID
               LEFT OUTER JOIN PRCompanyIndicators WITH (NOLOCK) ON prci2_CompanyID = peli_CompanyID
         WHERE prwucl_TypeCode = @ListType
		   AND prwu_Disabled IS NULL
		   AND prwu_ServiceCode IS NOT NULL
           AND prss_OpenedDate BETWEEN @StartDate AND @EndDate
		   AND peli_PRAUSReceiveMethod=@ReceiveMethod
           AND prss_Publish = 'Y'
           AND peli_PRStatus = '1'
           AND peli_PRAUSChangePreference = @AllChanges
           AND prci2_Suspended IS NULL
	  GROUP BY peli_PersonID, peli_CompanyID, prwu_Culture
	INSERT INTO @MyTable
      SELECT peli_PersonID, peli_CompanyID, prwu_Culture, COUNT(1) AS [Count]
          FROM PRWebUserList WITH (NOLOCK)
               INNER JOIN PRWebUserListDetail WITH (NOLOCK) on prwucl_WebUserListID = prwuld_WebUserListID
               INNER JOIN PRWebUser WITH (NOLOCK) on prwucl_WebUserID = prwu_WebUserID
               INNER JOIN PRCourtCases WITH (NOLOCK) on prwuld_AssociatedID = prcc_CompanyID
               INNER JOIN Person_Link WITH (NOLOCK) on prwu_PersonLinkID = peli_PersonLinkID
               LEFT OUTER JOIN PRCompanyIndicators WITH (NOLOCK) ON prci2_CompanyID = peli_CompanyID
         WHERE prwucl_TypeCode = @ListType
		   AND prwu_Disabled IS NULL
		   AND prwu_ServiceCode IS NOT NULL
           AND prcc_CreatedDate BETWEEN @StartDate AND @EndDate
		   AND peli_PRAUSReceiveMethod=@ReceiveMethod
		   --AND peli_PRAUSReceiveMethod IN (1,2,4)
		   AND prcc_FiledDate > DATEADD(day, -45, GETDATE())
           AND peli_PRStatus = '1'
           AND peli_PRAUSChangePreference = @AllChanges
           AND prci2_Suspended IS NULL
	  GROUP BY peli_PersonID, peli_CompanyID, prwu_Culture
	INSERT INTO @MyTable
      SELECT peli_PersonID, peli_CompanyID, prwu_Culture, COUNT(1) AS [Count]
          FROM PRWebUserList WITH (NOLOCK)
               INNER JOIN PRWebUserListDetail WITH (NOLOCK) on prwucl_WebUserListID = prwuld_WebUserListID
               INNER JOIN PRWebUser WITH (NOLOCK) on prwucl_WebUserID = prwu_WebUserID
			   INNER JOIN vPRBBScoreChange ON prwuld_AssociatedID = prbs_CompanyID
               INNER JOIN Person_Link WITH (NOLOCK) on prwu_PersonLinkID = peli_PersonLinkID
			   INNER JOIN Company WITH (NOLOCK) ON Comp_CompanyId = PeLi_CompanyID
               LEFT OUTER JOIN PRCompanyIndicators WITH (NOLOCK) ON prci2_CompanyID = peli_CompanyID
         WHERE prwucl_TypeCode = @ListType
		   AND CAST(prwu_AccessLevel as int) >= 300
		   AND prwu_Disabled IS NULL
		   AND prwu_ServiceCode IS NOT NULL
           AND prbs_CreatedDate BETWEEN @StartDate AND @EndDate
		   AND peli_PRAUSReceiveMethod=@ReceiveMethod
		   AND PreviousScore IS NULL
           AND peli_PRAUSChangePreference = @AllChanges
           AND prci2_Suspended IS NULL
		   AND 1 =	CASE
						WHEN @BBSSuppressAUSandReport=0 THEN 1
						WHEN @BBSSuppressAUSandReport=1 AND comp_PRIndustryType IN ('P','S','T') THEN 0
						WHEN @BBSSuppressAUSandReport=1 AND comp_PRIndustryType NOT IN ('P','S','T') THEN 1
					END
	  GROUP BY peli_PersonID, peli_CompanyID, prwu_Culture
	INSERT INTO @MyTable
      SELECT peli_PersonID, peli_CompanyID, prwu_Culture, COUNT(1) AS [Count]
          FROM PRWebUserList WITH (NOLOCK)
               INNER JOIN PRWebUserListDetail WITH (NOLOCK) on prwucl_WebUserListID = prwuld_WebUserListID
               INNER JOIN PRWebUser WITH (NOLOCK) on prwucl_WebUserID = prwu_WebUserID
			   INNER JOIN vPRBBScoreChange ON prwuld_AssociatedID = prbs_CompanyID
               INNER JOIN Person_Link WITH (NOLOCK) on prwu_PersonLinkID = peli_PersonLinkID
			   INNER JOIN Company WITH (NOLOCK) ON Comp_CompanyId = PeLi_CompanyID
               LEFT OUTER JOIN PRCompanyIndicators WITH (NOLOCK) ON prci2_CompanyID = peli_CompanyID
         WHERE prwucl_TypeCode = @ListType
		   AND CAST(prwu_AccessLevel as int) >= 300
		   AND prwu_Disabled IS NULL
		   AND prwu_ServiceCode IS NOT NULL
           AND prbs_CreatedDate BETWEEN @StartDate AND @EndDate
		   AND peli_PRAUSReceiveMethod=@ReceiveMethod
		   AND PreviousScore IS NOT NULL
		   AND ABS(prbs_BBScore - PreviousScore) >= 25
           AND peli_PRAUSChangePreference = @AllChanges
           AND prci2_Suspended IS NULL
			AND 1 =	CASE
						WHEN @BBSSuppressAUSandReport=0 THEN 1
						WHEN @BBSSuppressAUSandReport=1 AND comp_PRIndustryType IN ('P','S','T') THEN 0
						WHEN @BBSSuppressAUSandReport=1 AND comp_PRIndustryType NOT IN ('P','S','T') THEN 1
					END
	  GROUP BY peli_PersonID, peli_CompanyID, prwu_Culture

	SELECT peli_PersonID, peli_CompanyID, prwu_Culture, SUM([Count]) AS [Count]
	  FROM @MyTable
	 WHERE dbo.ufn_GetPrimaryService(peli_CompanyID) IS NOT NULL
  GROUP BY peli_PersonID, peli_CompanyID, prwu_Culture
  ORDER BY peli_PersonID, peli_CompanyID, prwu_Culture;
END 
GO

/**
Returns the PersonIDs that have Alerts changes for the specified
time frame and specified monitored companyh
**/
If Exists (Select name from sysobjects where name = 'usp_GetAUSReportItemsForMonitoredCompany' and type='P') Drop Procedure usp_GetAUSReportItemsForMonitoredCompany
Go

CREATE PROCEDURE [dbo].[usp_GetAUSReportItemsForMonitoredCompany]
@StartDate datetime,
@EndDate datetime,
@MonitoredCompanyID int,
@ReceiveMethod varchar(50)
AS

DECLARE @MinAccessLevel int = 50

SELECT peli_PersonID, peli_CompanyID, prwu_Culture, SUM([Count]) AS [Count]
  FROM (SELECT peli_PersonID, peli_CompanyID, prwu_Culture, COUNT(1) AS [Count]
          FROM PRWebUserList WITH (NOLOCK)
               INNER JOIN PRWebUserListDetail WITH (NOLOCK) on prwucl_WebUserListID = prwuld_WebUserListID
               INNER JOIN PRWebUser WITH (NOLOCK) on prwucl_WebUserID = prwu_WebUserID
               INNER JOIN PRCreditSheet WITH (NOLOCK) on prwuld_AssociatedID = prcs_CompanyID
               INNER JOIN Person_Link WITH (NOLOCK) on prwu_PersonLinkID = peli_PersonLinkID
               LEFT OUTER JOIN PRCompanyIndicators WITH (NOLOCK) ON prci2_CompanyID = peli_CompanyID
         WHERE prwucl_TypeCode = 'AUS'
        AND (CAST(ISNULL(prwu_AccessLevel, 0) as Integer) >= @MinAccessLevel
		     OR CAST(ISNULL(prwu_AccessLevel, 0) as Integer) = 7)
           AND prwuld_AssociatedID = @MonitoredCompanyID
           AND prcs_PublishableDate BETWEEN @StartDate AND @EndDate
           AND prcs_Status = 'P' -- Publishable
           AND peli_PRStatus = '1'
		   AND peli_PRAUSReceiveMethod=@ReceiveMethod
           --AND peli_PRAUSReceiveMethod IN (1,2)
           AND ISNULL(prcs_KeyFlag, 'N') = CASE WHEN peli_PRAUSChangePreference = '1' THEN 'Y' ELSE ISNULL(prcs_KeyFlag, 'N')  END
           AND prci2_Suspended IS NULL
      GROUP BY peli_PersonID, peli_CompanyID, prwu_Culture
		UNION
        SELECT peli_PersonID, peli_CompanyID, prwu_Culture, COUNT(1) AS [Count]
          FROM PRWebUserList WITH (NOLOCK)
			   INNER JOIN PRWebUser WITH (NOLOCK) on prwucl_WebUserID = prwu_WebUserID
		       INNER JOIN Person_Link WITH (NOLOCK) on prwu_PersonLinkID = peli_PersonLinkID
               INNER JOIN PRBusinessReportRequest WITH (NOLOCK) ON peli_PersonID = prbr_RequestingPersonID and peli_CompanyID = prbr_RequestingCompanyID
               INNER JOIN PRCreditSheet WITH (NOLOCK) on prbr_RequestedCompanyID = prcs_CompanyID
               LEFT OUTER JOIN PRCompanyIndicators WITH (NOLOCK) ON prci2_CompanyID = peli_CompanyID
         WHERE prwucl_TypeCode = 'AUS'
        AND (CAST(ISNULL(prwu_AccessLevel, 0) as Integer) >= @MinAccessLevel
		     OR CAST(ISNULL(prwu_AccessLevel, 0) as Integer) = 7)
           AND prbr_RequestedCompanyId = @MonitoredCompanyID
           AND prcs_PublishableDate BETWEEN @StartDate AND @EndDate
           AND prcs_Status = 'P' -- Publishable
           AND peli_PRStatus = '1'
		   AND peli_PRAUSReceiveMethod=@ReceiveMethod
           --AND peli_PRAUSReceiveMethod IN (1,2)
           AND prbr_CreatedDate > DATEADD(month, -6, GETDATE())
           AND ISNULL(prcs_KeyFlag, 'N') = CASE WHEN peli_PRAUSChangePreference = '1' THEN 'Y' ELSE ISNULL(prcs_KeyFlag, 'N')  END
           AND prci2_Suspended IS NULL
      GROUP BY peli_PersonID, peli_CompanyID, prwu_Culture
		UNION      
        SELECT peli_PersonID, peli_CompanyID, prwu_Culture, COUNT(1) AS [Count]
          FROM PRWebUserList WITH (NOLOCK)
               INNER JOIN PRWebUserListDetail WITH (NOLOCK) on prwucl_WebUserListID = prwuld_WebUserListID
               INNER JOIN PRWebUser WITH (NOLOCK) on prwucl_WebUserID = prwu_WebUserID
               INNER JOIN (
				                SELECT wppmac.*, ca.*, post_date FROM WordPressProduce.dbo.wp_posts WITH (NOLOCK)
						            LEFT OUTER JOIN WordPressProduce.dbo.wp_PostMeta wppmac WITH (NOLOCK) ON wp_posts.ID = wppmac.post_id AND meta_key = 'associated-companies'
						            LEFT OUTER JOIN (SELECT post_ID FROM WordPressProduce.dbo.wp_PostMeta WHERE meta_key='blueprintEdition') bpe ON bpe.post_ID = wp_posts.ID
						            CROSS APPLY CRM.dbo.Tokenize(meta_value, ',') ca
					            WHERE
						            post_type = 'post'
						            AND post_status in('publish')
						            AND post_date BETWEEN @StartDate AND @EndDate
						            AND meta_value IS NOT NULL
									AND (bpe.post_ID IS NULL OR dbo.ufn_GetWordPressBluePrintsEdition(ID) = '')
				) wp ON wp.value = prwuld_AssociatedID
               INNER JOIN Person_Link WITH (NOLOCK) on prwu_PersonLinkID = peli_PersonLinkID
               LEFT OUTER JOIN PRCompanyIndicators WITH (NOLOCK) ON prci2_CompanyID = peli_CompanyID
         WHERE prwucl_TypeCode = 'AUS'
        AND (CAST(ISNULL(prwu_AccessLevel, 0) as Integer) >= @MinAccessLevel
		     OR CAST(ISNULL(prwu_AccessLevel, 0) as Integer) = 7)
           AND value = @MonitoredCompanyID
           AND wp.post_date BETWEEN @StartDate AND @EndDate
           AND peli_PRStatus = '1'
           AND peli_PRAUSChangePreference = '2'
		   AND peli_PRAUSReceiveMethod=@ReceiveMethod
           --AND peli_PRAUSReceiveMethod IN (1,2)
           AND prci2_Suspended IS NULL
      GROUP BY peli_PersonID, peli_CompanyID, prwu_Culture
 ) T1
 INNER JOIN PRService ON T1.peli_CompanyID = prse_CompanyID
 WHERE prse_Primary = 'Y'
GROUP BY peli_PersonID, peli_CompanyID, prwu_Culture
ORDER BY peli_PersonID, peli_CompanyID, prwu_Culture;
Go

/**
Returns the header information for the Alerts Report
**/
If Exists (Select name from sysobjects where name = 'usp_GetAUSReportHeader' and type='P') Drop Procedure usp_GetAUSReportHeader
Go

CREATE PROCEDURE [dbo].[usp_GetAUSReportHeader]
  @PersonID int,
  @CompanyID int
AS
	SELECT dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_MiddleName, pers_PRNickName1, pers_Suffix) As FullName, 
       comp_PRCorrTradestyle, peli_PRAUSChangePreference, a.capt_us AS ReceiveMethod, b.capt_us AS ChangePreference, 
       peli_PRAUSReceiveMethod, 
       CASE 
			WHEN peli_PRAUSReceiveMethod  = '1' THEN dbo.ufn_FormatPhone(phon_CountryCode, phon_AreaCode, phon_Number, phon_PRExtension) 
			WHEN peli_PRAUSReceiveMethod  ='2' OR peli_PRAUSReceiveMethod='4' THEN RTRIM(ISNULL(peli_PRAlertEmail, prwu_Email)) 
			ELSE NULL
       END AS Destination
  FROM Person_Link WITH (NOLOCK)
       INNER JOIN Person WITH (NOLOCK) ON peli_PersonID = pers_PersonID
       INNER JOIN Company WITH (NOLOCK) ON peli_CompanyID = comp_CompanyID
       LEFT OUTER JOIN PRWebUser WITH (NOLOCK) ON peli_PersonLinkID = prwu_PersonLinkID
       LEFT OUTER JOIN vPRPersonPhone WITH (NOLOCK) ON peli_PersonID = plink_RecordID AND peli_CompanyID = phon_CompanyID AND phon_PRIsFax = 'Y' AND phon_PRPreferredInternal = 'Y'
       LEFT OUTER JOIN custom_captions a WITH (NOLOCK) ON peli_PRAUSReceiveMethod = a.capt_code and a.capt_family = 'peli_PRAUSReceiveMethod'
       LEFT OUTER JOIN custom_captions b WITH (NOLOCK) ON peli_PRAUSChangePreference = b.capt_code and b.capt_family = 'peli_PRAUSChangePreference'
 WHERE peli_PersonID = @PersonID
   AND peli_CompanyID = @CompanyID
   AND peli_PRStatus In ('1', '2');
Go

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
   AND prfs_FinancialID NOT IN (SELECT TOP 4 prfs_FinancialID 
		  FROM PRFinancial 
		  WHERE prfs_CompanyID=@CompanyID
		   AND prfs_Publish='Y'
		  ORDER BY prfs_StatementDate desc);

END
Go


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

	DECLARE @CompanyCount int, @Index int, @CurrentCompanyID int, @LeftCompanyId int, @RightCompanyId int
	DECLARE @HasType36 varchar(1)

	DECLARE @SharedOwnership table (
		ndx int identity(1,1) Primary Key,
		peli_CompanyID int
	)

	INSERT INTO @SharedOwnership (peli_CompanyID)
	SELECT distinct peli_CompanyID
	  FROM Person_Link
	 WHERE peli_PersonID=@PersonID
	   AND peli_CompanyID <> @CompanyID
	   AND peli_PROwnershipRole != 'RCR'
       AND peli_PRStatus IN (1, 2);


	SET @CompanyCount = @@ROWCOUNT
	SET @Index = 0

	WHILE @Index < @CompanyCount BEGIN
		SET @Index = @Index + 1

		SELECT @CurrentCompanyID = peli_CompanyID
		  FROM @SharedOwnership
		 WHERE Ndx = @Index;

		SET @HasType36 = NULL
		SELECT @HasType36 = 'Y'
		  FROM PRCompanyRelationship
		  WHERE prcr_Type = '36'
		    AND prcr_Active = 'Y'
		    AND ((prcr_LeftCompanyID = @CompanyID AND prcr_RightCompanyID = @CurrentCompanyID)
			     OR (prcr_LeftCompanyID = @CurrentCompanyID AND prcr_RightCompanyID = @CompanyID));

		-- Only create the Type 29 if the two companies do not
		-- have a Type 36 already established.
		IF (@HasType36 IS NULL) BEGIN
			-- NULL these or the old values will be reused if no results are found
			SELECT @LeftCompanyId = NULL, @RightCompanyId = NULL
		
			-- Now determine if we need to create or 
			-- update the PRCompanyRelationship record.
			-- find the related company id's (in the right order)
			SELECT @LeftCompanyId = prcr_LeftCompanyId
				   , @RightCompanyId = prcr_RightCompanyId
			  FROM PRCompanyRelationship 
			 WHERE prcr_Type = '29'
			   AND ((prcr_LeftCompanyID = @CompanyID AND prcr_RightCompanyID = @CurrentCompanyID)
				   OR (prcr_LeftCompanyID = @CurrentCompanyID AND prcr_RightCompanyID = @CompanyID));

	

			-- Update the relationship
			Set @LeftCompanyId = COALESCE(@LeftCompanyId, @CompanyId);
			Set @RightCompanyId = COALESCE(@RightCompanyId, @CurrentCompanyId);
			EXEC usp_UpdateCompanyRelationship @LeftCompanyId, @RightCompanyId, N'29', 0, @CRMUserID
		END
	END
END
GO


/**
Used by all of the Jeopardy Letters for the address block
**/
CREATE OR ALTER Procedure dbo.usp_GetJeopardyLetterHeader(@CompanyID int)
AS  
BEGIN 

	DECLARE @DeadlineDate datetime,
	 	    @nth tinyint = 1,     -- Which of them - 1st, 2nd, etc.
            @dow tinyint  = 6,     -- Day of week we want
			@LastFinancialStatementDate datetime

	SELECT @DeadlineDate = comp_PRJeopardyDate,
	       @LastFinancialStatementDate = comp_PRFinancialStatementDate
      FROM Company WITH (NOLOCK)
	 WHERE comp_CompanyID = @CompanyID

	-- Temp change due to COVID-19
	IF (@DeadlineDate = '2020-07-01')
		SET @DeadlineDate = DATEADD(month, 1, @DeadlineDate)

	-- Temp change due to COVID-19 but only affects
	-- yeae-end statements
	IF (@LastFinancialStatementDate = '2019-12-31') BEGIN
		IF EXISTS (SELECT 'x' FROM PRFinancial WHERE prfs_CompanyID=@CompanyID AND prfs_Type='Y' AND prfs_StatementDate=@LastFinancialStatementDate) BEGIN
			SET @DeadlineDate = DATEADD(month, 1, @DeadlineDate)
		END
	END


	SET @DeadlineDate = @DeadlineDate + 7*(@nth-1)
	SET @DeadlineDate = @DeadlineDate + (7 + @dow - datepart(weekday, @DeadlineDate))%7

	
	-- Return the data needed for the letter
	SELECT comp_CompanyID
           , RTRIM(comp_PRCorrTradestyle) comp_PRCorrTradestyle
		   , RTRIM(
				CASE WHEN prattn_PersonID IS NOT NULL THEN
				dbo.ufn_FormatPerson(Pers_FirstName, Pers_LastName, Pers_MiddleName, pers_PRNickname1, Pers_Suffix)
				ELSE prattn_CustomLine
				END) pers_FullName
		   , RTRIM(Addr_Address1) Addr_Address1
		   , RTRIM(Addr_Address2) Addr_Address2
		   , RTRIM(Addr_Address3) Addr_Address3
		   , RTRIM(Addr_Address4) Addr_Address4
		   , RTRIM(Addr_Address5) Addr_Address5
		   , RTRIM(prci_City) prci_City
		   , RTRIM(prst_Abbreviation) prst_Abbreviation
		   , RTRIM(prcn_Country) prcn_Country
		   , RTRIM(Addr_PostCode) Addr_PostCode
		   , comp_PRTMFMAward
		   , BlueBookUpdateDate = @DeadlineDate
		   , NotProvidedByDate = DATEADD(DAY, -1, @DeadlineDate)
	  FROM Company WITH (NOLOCK)
		   LEFT OUTER JOIN PRAttentionLine WITH (NOLOCK) ON comp_CompanyID = prattn_CompanyID
				AND prattn_ItemCode = 'JEP-M'
				AND prattn_Disabled IS NULL
		   LEFT OUTER JOIN Address WITH (NOLOCK) ON prattn_AddressID = Addr_AddressID
		   LEFT OUTER JOIN vPRLocation ON addr_PRCityId = prci_CityID
		   LEFT OUTER JOIN Person WITH (NOLOCK) ON prattn_PersonID = pers_PersonID
           LEFT OUTER JOIN Person_Link WITH (NOLOCK) ON pers_PersonID = PeLi_PersonId AND comp_CompanyID = peli_CompanyId
				       AND peli_PRStatus IN (1,2)
		WHERE comp_CompanyID = @CompanyID;
END
GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_GetCompaniesForJeopardyLetter]'))
	drop Procedure [dbo].[usp_GetCompaniesForJeopardyLetter]
GO

CREATE Procedure dbo.usp_GetCompaniesForJeopardyLetter
	@LetterDate datetime = NULL
AS
BEGIN

	IF (@LetterDate IS NULL) SET @LetterDate = GETDATE()
	

	DECLARE @MyTable table (
		CompanyID int,
		CompanyName varchar(200),
		StatementDate date,
		JeopardyDate date,
		TMStatus varchar(1),
		LetterType varchar(3),
		CommType varchar(40),
		Addressee varchar(100),
		PersonID int,
		EmailID int,
		PhoneID int,
		AddressID int
	)

	INSERT @MyTable (CompanyID, CompanyName, StatementDate, JeopardyDate, TMStatus, LetterType)
	Select comp_CompanyID,
		   comp_PRCorrTradestyle,
		   comp_PRFinancialStatementDate,
		   comp_PRJeopardyDate,
		   ISNULL(comp_PRTMFMAward,'N'),
		   CASE WHEN DATEDIFF(m,@LetterDate,comp_PRJeopardyDate) = 4 AND comp_PRTMFMAward = 'Y' THEN 'T1'
				WHEN DATEDIFF(m,@LetterDate,comp_PRJeopardyDate) = 2 AND comp_PRTMFMAward = 'Y' THEN 'T2'
				WHEN DATEDIFF(m,@LetterDate,comp_PRJeopardyDate) = 1 AND comp_PRTMFMAward = 'Y' THEN 'T3'
				WHEN DATEDIFF(m,@LetterDate,comp_PRJeopardyDate) = 4 AND comp_PRTMFMAward IS NULL THEN 'N1'
				WHEN DATEDIFF(m,@LetterDate,comp_PRJeopardyDate) = 2 AND comp_PRTMFMAward IS NULL THEN 'N2'
				WHEN DATEDIFF(m,@LetterDate,comp_PRJeopardyDate) = 1 AND comp_PRTMFMAward IS NULL THEN 'N3'
				ELSE '' end
	 FROM Company with (nolock)
		  INNER JOIN vPRCompanyRating with (nolock) on prra_CompanyID = comp_CompanyID AND prra_Current = 'Y'
	WHERE Comp_CompanyID not in (100587, 108785, 111945)
	  AND comp_PRIndustryType <> 'L'
	  AND comp_PRListingStatus not in ('D', 'N3', 'N5', 'N6')
	  AND prra_CreditWorthID is not null
	  AND prra_CreditWorthID not in (4, 7, 8, 9, 10)
	  AND DATEDIFF(m, @LetterDate, Comp_PRJeopardyDate) in (4, 2, 1)
	  AND Comp_CompanyID IN (SELECT DISTINCT prattn_CompanyID FROM vPRCompanyAttentionLine WHERE prattn_ItemCode IN ('JEP-M', 'JEP-E') AND prattn_Disabled IS NULL)

	UPDATE @MyTable
	   SET PersonID = prattn_PersonID,
		   EmailID = CASE WHEN prattn_EmailID IS NOT NULL THEN prattn_EmailID ELSE NULL END,
		   PhoneID = CASE WHEN prattn_PhoneID IS NOT NULL THEN prattn_PhoneID ELSE NULL END,
		   --CommType = CASE WHEN prattn_EmailID IS NOT NULL THEN 'EmailOut' ELSE 'FaxOut' END,
		   CommType = CASE WHEN prattn_EmailID IS NOT NULL THEN 'EmailOut' ELSE CASE WHEN prattn_PhoneID IS NOT NULL THEN 'FaxOut' ELSE NULL END END,
		   Addressee = vPRCompanyAttentionLine.Addressee
	  FROM vPRCompanyAttentionLine
	 WHERE CompanyID = prattn_CompanyID
	   AND LetterType NOT IN ('T3', 'N3')
	   AND prattn_ItemCode = 'JEP-E' 
	   AND prattn_Disabled IS NULL




	-- 116171
	UPDATE @MyTable
	   SET PersonID = peli_PersonID,
		   EmailID = CASE WHEN emai_EmailID IS NOT NULL THEN emai_EmailID ELSE NULL END,
		   PhoneID = CASE WHEN emai_EmailID IS NULL THEN phon_PhoneID ELSE NULL END,
		   CommType = CASE WHEN emai_EmailID IS NOT NULL THEN 'EmailOut' ELSE CASE WHEN phon_PhoneID IS NOT NULL THEN 'FaxOut' ELSE NULL END END
	  FROM (
			SELECT peli_CompanyID, 
				   peli_PersonID, 
				   emai_EmailID,
				   phon_PhoneID,
				   CommType,
				   ROW_NUMBER() OVER (PARTITION BY peli_CompanyID ORDER BY CASE WHEN peli_PRTitle = 'CFO' THEN 1 
																				WHEN peli_PRTitle = 'CTRL' THEN 2 
																				WHEN peli_PRRole LIKE '%,HE,%' THEN 3
																				WHEN peli_PRTitle = 'SEC' THEN 4 
																				WHEN peli_PRTitle = 'TRE' THEN 5  
																				ELSE 99 END) as RowNum
			  FROM @MyTable
				   INNER JOIN Person_Link WITH (NOLOCK) ON CompanyID = peli_CompanyID
				   LEFT OUTER JOIN vPRPersonEmail WITH (NOLOCK) ON peli_PersonID = elink_RecordID AND peli_CompanyID = emai_CompanyID AND ELink_Type = 'E'
				   LEFT OUTER JOIN vPRPersonPhone WITH (NOLOCK) ON peli_PersonID = plink_RecordID AND peli_CompanyID = phon_CompanyID AND phon_PRIsFax = 'Y'
			 WHERE CommType IS NULL
			   AND LetterType NOT IN ('T3', 'N3')
			   AND peli_PRStatus = 1
			   AND (peli_PRRole LIKE '%,HE,%' OR peli_PRTitle IN ('CFO', 'CTRL', 'SEC', 'TRE'))
			   AND (ISNULL(emai_EmailID,0) + ISNULL(phon_PhoneID, 0) > 0)  -- Has either an Email or Fax
						) T1
	  WHERE RowNum = 1
		AND CompanyID = peli_CompanyID 


	UPDATE @MyTable
	   SET EmailID = CASE WHEN emai_EmailID IS NOT NULL THEN emai_EmailID ELSE NULL END,
		   PhoneID = CASE WHEN emai_EmailID IS NULL THEN phon_PhoneID ELSE NULL END,
		   CommType = CASE WHEN emai_EmailID IS NOT NULL THEN 'EmailOut' ELSE CASE WHEN emai_EmailID IS NOT NULL THEN 'FaxOut' ELSE NULL END END
		FROM @MyTable 
			LEFT OUTER JOIN vCompanyEmail WITH (NOLOCK) ON CompanyID = elink_RecordID AND ELink_Type = 'E' AND emai_PRPreferredInternal = 'Y'
			LEFT OUTER JOIN vPRCompanyPhone WITH (NOLOCK) ON CompanyID = plink_RecordID AND phon_PRIsFax = 'Y' AND phon_PRPreferredInternal = 'Y'
	   WHERE CommType IS NULL
		 AND LetterType NOT IN ('T3', 'N3')
		 AND (ISNULL(emai_EmailID,0) + ISNULL(phon_PhoneID, 0) > 0)  -- Has either an Email or Fax

	UPDATE @MyTable
	   SET PersonID = prattn_PersonID,
		   AddressID = prattn_AddressID,
		   CommType = 'LetterOut',
		   Addressee = vPRCompanyAttentionLine.Addressee
	  FROM vPRCompanyAttentionLine
	 WHERE CompanyID = prattn_CompanyID
	   AND (LetterType IN ('T3', 'N3') OR CommType IS NULL)
	   AND prattn_ItemCode = 'JEP-M' 
	   AND prattn_Disabled IS NULL

	SELECT mt.* ,
	       RTRIM(emai_EmailAddress) Email,
		   dbo.ufn_FormatPhone(phon_CountryCode, phon_AreaCode, phon_Number, phon_PRExtension) as Fax
	  FROM @MyTable mt
	       LEFT OUTER JOIN Email ON EmailID = emai_EmailID
		   LEFT OUTER JOIN Phone ON PhoneID = phon_PhoneID
  ORDER BY CompanyID

END
GO



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
	DECLARE @FinancialId Int, @Type varchar(40)
	DECLARE @MonthIncrement int	
	DECLARE @TM char(1)

	SELECT top 1 @StatementDate = prfs_StatementDate, @Type = prfs_type, @FinancialId = prfs_FinancialId 
	  FROM PRFinancial
	 WHERE prfs_CompanyID = @CompanyID
	 ORDER BY prfs_StatementDate desc, prfs_FinancialId desc

	SELECT @TM = comp_PRTMFMAward 
	  FROM Company
	 WHERE comp_companyId = @CompanyID 

	-- determine how many months to increment based upon Trading Member status and FS Type
	SET @MonthIncrement = case
		WHEN @TM = 'Y' AND @Type = 'Y' THEN 18
		WHEN @TM = 'Y' AND @Type = 'I' THEN 12
		WHEN @TM IS NULL AND @Type = 'Y' THEN 18
		WHEN @TM IS NULL AND @Type = 'I' THEN 12
		ELSE 12
	END
		
	-- calcualte the date to be the FS Date + the month increment
	SET @JeopardyDate = DATEADD(month, @MonthIncrement, @StatementDate) 	

	-- Finally, calculate the true date to be the first Wednesday of the next month 
	DECLARE @Month int, @Year int
	SET @Year = DatePart(year, @JeopardyDate) 
	SET @Month = DatePart(month, @JeopardyDate)+1
	If @Month > 12 begin
		SET @Month = 1
		SET @Year = @Year + 1
	end
	SET @JeopardyDate = convert(DateTime, cast( @Month as varchar ) + '/01/' + cast(@Year As varchar ))

	UPDATE Company
	   SET comp_PRJeopardyDate = @JeopardyDate,
           comp_UpdatedDate = GETDATE(),
           comp_UpdatedBy = @CRMUserID,
           comp_Timestamp = GETDATE()
	 WHERE comp_CompanyID = @CompanyID;

END
Go

/**
  Returns a table containing all customer service encounters made during the calender week prior to the specified date.
**/
IF  EXISTS (SELECT 'x' FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ufn_GetCSSurveyEncounters]'))
	DROP FUNCTION dbo.ufn_GetCSSurveyEncounters
GO


CREATE FUNCTION [dbo].[ufn_GetCSSurveyEncounters](@SurveyDate date)  
RETURNS @CSSurveyEncounters table (
    ndx smallint identity,
    CompanyId int,
    UserId int,
    CallType char(1))
AS  
BEGIN 

	-- determine start and end of last week
	DECLARE @TodayMidnight datetime
	DECLARE @FromDate datetime
	DECLARE @ThroughDate datetime

	SET @TodayMidnight = @SurveyDate
	SET @FromDate = DATEADD(DAY,-(6 + DATEPART(weekday,@TodayMidnight)), @TodayMidnight)
	SET @ThroughDate = DATEADD(WEEK,1,@FromDate)

	-- query pool of company ID's from customer care cases,
	-- verbal BR requests, phone interactions, phone transactions
	INSERT INTO @CSSurveyEncounters (CompanyId, UserId, CallType)
	SELECT DISTINCT case_PrimaryCompanyId as CompanyId, case_ClosedBy as UserId, 'H' as CallType
	  FROM Cases WITH (NOLOCK)
	 WHERE case_Closed BETWEEN @FromDate AND @ThroughDate
	   AND case_ProductArea <> 'AR'
	UNION
	SELECT DISTINCT prbr_RequestingCompanyId as CompanyId, prbr_CreatedBy as UserId, 'V' as CallType
	  FROM PRBusinessReportRequest WITH (NOLOCK)
	 WHERE prbr_CreatedDate BETWEEN @FromDate AND @ThroughDate
	   AND prbr_MethodSent = 'VBR'
	UNION
	SELECT DISTINCT cmli_comm_CompanyId as CompanyId, comm_CreatedBy as UserId, 'I' as CallType
	  FROM Communication WITH (NOLOCK)
	       INNER JOIN Comm_Link WITH (NOLOCK) on comm_communicationid = cmli_comm_communicationid
	 WHERE comm_DateTime BETWEEN @FromDate AND @ThroughDate
	   AND Comm_Action = 'PhoneIn'
	   AND cmli_comm_CompanyId IS NOT NULL
	UNION
	SELECT DISTINCT prtx_Companyid as CompanyId, prtx_CreatedBy as UserId, 'T' as CallType
	  FROM PRTransaction WITH (NOLOCK)
	 WHERE prtx_CreatedDate BETWEEN @FromDate AND @ThroughDate
	   AND prtx_NotificationType = 'P'
	   AND prtx_CompanyId IS NOT NULL

	RETURN
END
GO

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
		DECLARE @IndustryType varchar(40)
		SELECT @IndustryType = comp_PRIndustryType FROM Company WITH (NOLOCK) WHERE comp_CompanyID=@SubjectCompany;

		IF ((@RelationshipType = '29') AND (@IndustryType = 'L')) BEGIN
			-- Skip lumber companies with type 29 relationships
			DECLARE @Dummy char(1)
		END ELSE BEGIN
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
									@PRSubcategory = null,
									@Subject = 'Review Company Record due to New Relationship Type'
			END										
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

			SET @ListingSpecalistID = dbo.ufn_GetPRCoSpecialistUserId(@CurrentCompanyID, 0)

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
								@PRSubcategory = 'RR',
								@Subject = 'Review Company''s Rating due to New Business Event.'


		END
	END
END
Go



--
--  Looks for TES Non Repsonders to create tasks for verbal trade reports
--
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].usp_CreateTESNonResponderTasks'))
     DROP PROCEDURE dbo.usp_CreateTESNonResponderTasks
GO

CREATE Procedure [dbo].[usp_CreateTESNonResponderTasks]
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
	SELECT prtesr_ResponderCompanyID, ResponderName, prtesr_SubjectCompanyID, SubjectName 
	  FROM (
		SELECT prtesr_ResponderCompanyID, a.comp_Name as ResponderName, prtesr_SubjectCompanyID, b.comp_Name as SubjectName, MIN(prtesr_CreatedDate) as prtesr_CreatedDate, Count(1) as TESCount
		  FROM PRTESRequest
			   --INNER JOIN PRTESDetail ON prte_TESID = prt2_TESID
			   INNER JOIN Company a ON prtesr_ResponderCompanyID = a.comp_CompanyID
			   INNER JOIN Company b ON prtesr_SubjectCompanyID = b.comp_CompanyID
		 WHERE prtesr_CreatedDate >= DATEADD(day, -62, GETDATE())
		   AND prtesr_Received IS NULL
		GROUP BY prtesr_ResponderCompanyID, a.comp_Name, prtesr_SubjectCompanyID, b.comp_Name
		HAVING COUNT(1) > 1) T1
	WHERE prtesr_CreatedDate = DATEADD(day, -62, GETDATE());
	SET @ResponderCount = @@ROWCOUNT
	SET @ResponderIndex = 0
	SET @DataProcessorUserID = dbo.ufn_GetCustomCaptionValueDefault('AssignmentUserID', 'DataProcessor', -5)
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
							@PRSubcategory = 'VI',
							@Subject = 'Process TES Non Responder'
	END
	SELECT @ResponderCount as TaskCount;
END
GO

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
							@PRSubcategory = 'O',
							@Subject = 'Review Services due to cancellation'


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

/**
For every type 'M' allocation that has a start date of 1/1 of last year 
and is tied to a non-cancelled service, create a new allocation for this year.
Will be invoked by BBS monitor at midnight on 1/1 each year.
**/

CREATE OR ALTER PROCEDURE [dbo].[usp_RenewServiceUnitAllocations]
AS

	DECLARE @Start datetime
	SET @Start = GETDATE()

	PRINT 'Renewing All M Type Unit Allocations'

	DECLARE @TempTable table (
		temp_id int IDENTITY(1,1),
		prun_ServiceUnitAllocationId int,
		prun_CreatedBy int,
		prun_CreatedDate datetime,
		prun_UpdatedBy int,
		prun_UpdatedDate datetime,
		prun_TimeStamp datetime,
		prun_CompanyID int,
		prun_SourceCode varchar(40),	
		prun_AllocationTypeCode varchar(40),
		prun_StartDate datetime,
		prun_ExpirationDate datetime,
		prun_UnitsAllocated	int,
		prun_UnitsRemaining int,
		prun_HQID int
	)

	INSERT INTO @TempTable
	SELECT NULL, -1, @Start, -1, @Start, @Start,
	       prse_CompanyID, 'C', 'M','1/1/' + LTRIM(STR(DATEPART(year, @Start))),  
	       '1/1/' + LTRIM(STR(DATEPART(year, DATEADD(Year, 1, @Start)))),
	       prod_PRServiceUnits, prod_PRServiceUnits, comp_PRHQID
	  FROM PRService
		   INNER JOIN NewProduct WITH (NOLOCK) on prse_ServiceCode = prod_Code
		   INNER JOIN Company WITH (NOLOCK) on comp_CompanyID = prse_CompanyID
	 WHERE Prod_ProductFamilyID = 5

	INSERT INTO @TempTable
	SELECT NULL, -1, @Start, -1, @Start, @Start,
           prse_CompanyID, 'C', 'R', '1/1/' + LTRIM(STR(DATEPART(year, @Start))),  
           '1/1/' + LTRIM(STR(DATEPART(year, DATEADD(Year, 1, @Start)))),
           QuantityOrdered, QuantityOrdered, comp_PRHQID
      FROM PRService
           INNER JOIN Company WITH (NOLOCK) on comp_CompanyID = prse_CompanyID
     WHERE prse_ServiceCode = 'UNITS-RENEWAL'


	DECLARE @Count int, @ndx int, @ServiceUnitAllocationID int
	SELECT @Count = COUNT(1) FROM @TempTable
	SET @ndx = 1	

	WHILE (@Ndx <= @Count) BEGIN

		EXEC usp_getNextId 'PRServiceUnitAllocation', @ServiceUnitAllocationID Output

		UPDATE @TempTable
		   SET prun_ServiceUnitAllocationID = @ServiceUnitAllocationID
		 WHERE temp_id = @Ndx

		SET @Ndx = @Ndx + 1
	END

	INSERT INTO PRServiceUnitAllocation  (prun_ServiceUnitAllocationId, prun_CreatedBy, prun_CreatedDate, prun_UpdatedBy, prun_UpdatedDate, prun_TimeStamp,
	                                      prun_CompanyID, prun_SourceCode, prun_AllocationTypeCode, prun_StartDate, prun_ExpirationDate,
	                                      prun_UnitsAllocated, prun_UnitsRemaining, prun_HQID)
    SELECT	prun_ServiceUnitAllocationId, prun_CreatedBy,prun_CreatedDate, prun_UpdatedBy, prun_UpdatedDate, prun_TimeStamp,
	        prun_CompanyID, prun_SourceCode, prun_AllocationTypeCode, prun_StartDate, prun_ExpirationDate,
	        prun_UnitsAllocated, prun_UnitsRemaining, prun_HQID
       FROM @TempTable

	SELECT COUNT(*) FROM PRServiceUnitAllocation WHERE prun_CreatedDate = @Start

	PRINT 'usp_RenewServiceUnitAllocations Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))
Go


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].usp_TESFormResponseReport'))
     DROP PROCEDURE dbo.usp_TESFormResponseReport
GO

CREATE PROCEDURE [dbo].[usp_TESFormResponseReport]
	@StartDate datetime,
    @EndDate datetime,
    @CountryID int = 0
AS BEGIN
	DECLARE @ComputedEndDate datetime
	SET @ComputedEndDate = DATEADD(d, 1, @EndDate)
	DECLARE @Details table (
		prtf_FormType varchar(40),
		prtf_SentMethod varchar(40),
		prtf_ReceivedMethod varchar(40),
		Total int
	)
	DECLARE @Results table (
		prtf_FormType varchar(40),
		prtf_SentMethod varchar(40),
		Label varchar(100),
		TotalSent int,
		ReturnedByMail int,
		ReturnedByFax int,
		ReturnedByWeb int,
		SortOrder tinyint
	)
	-- We're going to use a in-memory table to limit our
	-- result set to the appropriate country.
	DECLARE @Country table (
		CountryID int
	)
	IF @CountryID = -99 BEGIN
		INSERT INTO @Country 
		SELECT prcn_CountryID 
		  FROM PRCountry 
		 WHERE prcn_CountryID > 3;
	END ELSE IF @CountryID = 0 BEGIN
		INSERT INTO @Country 
		SELECT prcn_CountryID 
		  FROM PRCountry;
	END ELSE BEGIN
		INSERT INTO @Country VALUES (@CountryID);
	END
	INSERT INTO @Details
	SELECT prtf_FormType, prtf_SentMethod, prtf_ReceivedMethod,  COUNT(DISTINCT prtf_TESFormID)
	  FROM PRTESRequest WITH (NOLOCK)
		   --INNER JOIN PRTESDetail WITH (NOLOCK)  ON prte_TESID = prt2_TESID
		   INNER JOIN PRTESForm WITH (NOLOCK)    ON prtesr_TESFormID = prtf_TESFormID
		   INNER JOIN PRAttentionLine WITH (NOLOCK) ON prtf_CompanyId = prattn_CompanyID
		   INNER JOIN Address WITH (NOLOCK)      ON prattn_AddressId = Addr_AddressId 
		   INNER JOIN vPRLocation  ON Address.addr_PRCityId = prci_CityId
	 WHERE prtf_SentDateTime BETWEEN @StartDate AND @EndDate
	   AND prcn_CountryID IN (SELECT CountryID FROM @Country)
	   AND prattn_ItemCode = 'TES'
       AND prattn_Disabled IS NULL
	GROUP BY prtf_FormType, prtf_SentMethod, prtf_ReceivedMethod
	ORDER BY prtf_FormType, prtf_SentMethod, prtf_ReceivedMethod;
	INSERT INTO @Results 
	SELECT DISTINCT a.capt_code, b.capt_code, RTRIM(cast(a.capt_us as varchar)) + ' by ' + RTRIM(cast(b.capt_us as varchar)), 0, 0, 0, 0,  CASE a.capt_code WHEN 'SE' THEN 1 WHEN 'SS' THEN 2 WHEN 'ME' THEN 3 ELSE 4 END
	  FROM custom_captions a 
		   CROSS JOIN custom_captions b 
	WHERE a.capt_Family = 'prtf_FormType'
	  AND b.capt_Family = 'prtf_SentMethod';
	-- Compute the total
	UPDATE @Results
	   SET TotalSent = Total
	 FROM (SELECT prtf_FormType, prtf_SentMethod, SUM(Total) as Total
			 FROM @Details 
		 GROUP BY prtf_FormType, prtf_SentMethod) T1,
		   @Results T2
	 WHERE T2.prtf_FormType = T1.prtf_FormType
	   AND T2.prtf_SentMethod = T1.prtf_SentMethod;
	-- Compute the Returned By Mail
	UPDATE @Results
	   SET ReturnedByMail = Total
	 FROM (SELECT prtf_FormType, prtf_SentMethod, SUM(Total) as Total
			 FROM @Details 
			WHERE prtf_ReceivedMethod = 'M'
		 GROUP BY prtf_FormType, prtf_SentMethod) T1,
		   @Results T2
	 WHERE T2.prtf_FormType = T1.prtf_FormType
	   AND T2.prtf_SentMethod = T1.prtf_SentMethod;
	-- Compute the Returned By Fax
	UPDATE @Results
	   SET ReturnedByFax = Total
	 FROM (SELECT prtf_FormType, prtf_SentMethod, SUM(Total) as Total
			 FROM @Details 
			WHERE prtf_ReceivedMethod IN ('FD', 'FR')
		 GROUP BY prtf_FormType, prtf_SentMethod) T1,
		   @Results T2
	 WHERE T2.prtf_FormType = T1.prtf_FormType
	   AND T2.prtf_SentMethod = T1.prtf_SentMethod;
	-- Compute the Returned By Web
	UPDATE @Results
	   SET ReturnedByWeb = Total
	 FROM (SELECT prtf_FormType, prtf_SentMethod, SUM(Total) as Total
			 FROM @Details 
			WHERE prtf_ReceivedMethod = 'OL'
		 GROUP BY prtf_FormType, prtf_SentMethod) T1,
		   @Results T2
	 WHERE T2.prtf_FormType = T1.prtf_FormType
	   AND T2.prtf_SentMethod = T1.prtf_SentMethod;
	--
	-- The International designation is only for outbound forms and has no bearing
	-- on PIKS.  So combine the Internationl numbers with the English numbers and
	-- then remove the International records.
	UPDATE @Results 
	   SET T2.TotalSent = ISNULL(T2.TotalSent, 0) + ISNULL(T1.TotalSent, 0),
		   T2.ReturnedByMail = ISNULL(T2.ReturnedByMail, 0) + ISNULL(T1.ReturnedByMail, 0),
		   T2.ReturnedByFax = ISNULL(T2.ReturnedByFax, 0) + ISNULL(T1.ReturnedByFax, 0),
		   T2.ReturnedByWeb = ISNULL(T2.ReturnedByWeb, 0) + ISNULL(T1.ReturnedByWeb, 0)
	   FROM ( SELECT prtf_SentMethod, TotalSent, ReturnedByMail, ReturnedByFax, ReturnedByWeb
				FROM @Results
			   WHERE prtf_FormType = 'MI') T1,
		   @Results T2
	 WHERE T2.prtf_FormType = 'ME'
	   AND T2.prtf_SentMethod = T1.prtf_SentMethod;
	UPDATE @Results 
	   SET T2.TotalSent = ISNULL(T2.TotalSent, 0) + ISNULL(T1.TotalSent, 0),
		   T2.ReturnedByMail = ISNULL(T2.ReturnedByMail, 0) + ISNULL(T1.ReturnedByMail, 0),
		   T2.ReturnedByFax = ISNULL(T2.ReturnedByFax, 0) + ISNULL(T1.ReturnedByFax, 0),
		   T2.ReturnedByWeb = ISNULL(T2.ReturnedByWeb, 0) + ISNULL(T1.ReturnedByWeb, 0)
	   FROM ( SELECT prtf_SentMethod, TotalSent, ReturnedByMail, ReturnedByFax, ReturnedByWeb
				FROM @Results
			   WHERE prtf_FormType = 'SI') T1,
		   @Results T2
	 WHERE T2.prtf_FormType = 'SE'
	   AND T2.prtf_SentMethod = T1.prtf_SentMethod;
	DELETE FROM @Results WHERE prtf_FormType IN ('SI', 'MI');
	SELECT * FROM @Results ORDER BY SortOrder;
END

GO


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_ModifyCommodity]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[usp_ModifyCommodity]
GO
CREATE PROCEDURE usp_ModifyCommodity
	-- *******************************************************
	-- Available Actions:
	--		0 : Combine CommodityId1 with CommodityID2 and remove commodityId1
	--					- CommodityId 1 is the commodity to remove; 
	--					- CommodityId 2 is the commodity to move the 
	--					  assigned Commodity 1 values to
	--		1 : Update the commodity abbreviation for CommodityId1
	--					- CommodityId 1 is the id of the commodity for the abbr to change; 
	--					  Can be null if all commodities using OriginalAbbr should be changed; 
	--					- OriginalAbbr is the current commodity abbr value
	--					- CorrectedAbbr is the corrected commodity abbr value
	-- *******************************************************
	@ActionId int,
	@CommodityId1 int = null,
	@CommodityId2 int = null,
	@OriginalAbbr varchar(100) = null,
	@CorrectedAbbr varchar(100) = null,
	@UpdatedBy int = -1
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRANSACTION
	BEGIN TRY
		
		PRINT ''
		PRINT '*****************************************************************************************'
		
		DECLARE @UpdateUserId int; SET @UpdateUserId = @UpdatedBy

		Declare @Msg varchar(max), @Sql varchar(max)

		Declare @Now datetime
		Set @Now = getDate();

		Declare @sCommodityId1 varchar(20), @sCommodityId2 varchar(20)
		SET @sCommodityId1 = cast(@CommodityId1 as varchar)
		SET @sCommodityId2 = cast(@CommodityId2 as varchar)

		IF (@ActionId  = 0)
		BEGIN
			IF (@CommodityId1 is null)
			BEGIN
				SET @Msg = 'A CommodityId1 value is required when performing a Commodity Combine/Remove action (ActionId = 0)'
				--PRINT @Msg
				SET @Msg = 'usp_ModifyCommodity Error.  ' + @Msg
				RAISERROR (@Msg, 16, 1)
			END

			PRINT ''
			PRINT 'Verify the commodity has no children'
			IF Exists(Select 1 From PRCommodity Where prcm_ParentID = @CommodityId1)
			BEGIN
				SET @Msg = 'Aborting update... The specified commodity has children and cannot be removed'
				--PRINT @Msg
				SET @Msg = 'usp_ModifyCommodity Error.  ' + @Msg
				RAISERROR (@Msg, 16, 1)
			END
			PRINT '  -- Commodity has no children'

			-- the first thing to identify is if any PRCompanyCommodityAttribute records will need to be modified
			-- if so, these will be moved over to the @CommodityId2 value
			PRINT ''
			PRINT 'Count of currently assigned companies using Commodity Id ' + @sCommodityId1 
			Select distinct rec_count = count(1), prcca_CommodityId, prcca_AttributeId, prcca_GrowingMethodId, prcca_PublishedDisplay 
			  From PRCompanyCommodityAttribute
			 Where prcca_CommodityID = @CommodityId1 
			Group By prcca_CommodityId, prcca_AttributeId, prcca_GrowingMethodId, prcca_PublishedDisplay

			IF (@@ROWCOUNT > 0 and @CommodityId2 IS NULL)
			BEGIN
				SET @Msg = 'usp_ModifyCommodity Error.  A CommodityId2 value is required when PRCompanyCommodityAttribute records exist for the CommodityId1 value.'
				RAISERROR (@Msg, 16, 1)
			END

			PRINT ''
			PRINT 'Count exsiting assigned companies using CommodityId2 ' + @sCommodityId2
			Select distinct rec_count = count(1), prcca_CommodityId, prcca_AttributeId, prcca_GrowingMethodId, prcca_PublishedDisplay 
			  From PRCompanyCommodityAttribute
			 Where prcca_CommodityID = @CommodityId2
			Group By prcca_CommodityId, prcca_AttributeId, prcca_GrowingMethodId, prcca_PublishedDisplay

			PRINT ''
			PRINT 'Modify the Commodity Id ' + @sCommodityId1 + ' records to Commodity Id ' + @sCommodityId2 
			PRINT '  -- Disable the Triggers for PRCompanyCommodityAttribute'
			ALTER TABLE PRCompanyCommodityAttribute DISABLE TRIGGER ALL
		
			PRINT '  -- Perform the update'
			Update PRCompanyCommodityAttribute
			   Set prcca_CommodityId = @CommodityId2
					,[prcca_UpdatedBy] = -1
					,[prcca_UpdatedDate] = @Now
					,[prcca_TimeStamp] = @Now
			 Where prcca_CommodityId = @CommodityId1 
			PRINT '     # of records updated: ' + cast(@@ROWCOUNT as varchar)

			PRINT '  -- Enable the Triggers for PRCompanyCommodityAttribute'
			ALTER TABLE PRCompanyCommodityAttribute ENABLE TRIGGER ALL
		
			PRINT ''
			PRINT 'Re-count exsiting records for CommodityId1 ' + @sCommodityId1
			Select distinct rec_count = count(1), prcca_CommodityId, prcca_AttributeId, prcca_GrowingMethodId, prcca_PublishedDisplay 
			  From PRCompanyCommodityAttribute
			 Where prcca_CommodityID = @CommodityId1
			Group By prcca_CommodityId, prcca_AttributeId, prcca_GrowingMethodId, prcca_PublishedDisplay

			PRINT ''
			PRINT 'Re-count exsiting records for CommodityId2 ' + @sCommodityId2
			Select distinct rec_count = count(1), prcca_CommodityId, prcca_AttributeId, prcca_GrowingMethodId, prcca_PublishedDisplay 
			  From PRCompanyCommodityAttribute
			 Where prcca_CommodityID = @CommodityId2
			Group By prcca_CommodityId, prcca_AttributeId, prcca_GrowingMethodId, prcca_PublishedDisplay

			PRINT 'Remove Commodity Id '+ @sCommodityId1
			PRINT '-----------------------------------------------------'

			PRINT 'The record to delete'
			Select * 
			  From PRCommodity
			 Where prcm_CommodityID = @CommodityId1
		
			PRINT ''
			PRINT 'Delete the record'
			Delete
			  From PRCommodity
			 Where prcm_CommodityID = @CommodityId1
			PRINT '  # of records deleted: ' + cast(@@ROWCOUNT as varchar)

			PRINT ''
			PRINT 'Verify the record was deleted'
			Select * 
			  From PRCommodity
			 Where prcm_CommodityID = @CommodityId1

		END ELSE IF (@ActionId = 1) BEGIN

			IF (@OriginalAbbr is null OR @CorrectedAbbr is null )
			BEGIN
				SET @Msg = 'OriginalAbbr and CorrectedAbbr are required when performing an Abbreviation Update action (ActionId = 1)'
				--PRINT @Msg
				SET @Msg = 'usp_ModifyCommodity Error.  ' + @Msg
				RAISERROR (@Msg, 16, 1)
			END
			-- when modifiying a commodity abbreviation, we'll need to update both the 
			-- PRCompanyCompmodityAttribute and PRCommodity tables
			DECLARE @SelectSQL varchar(2000), @Abbr1Where varchar(1000), @Abbr2Where varchar(1000)
			SET @SelectSQL = 'Select prcca_CompanyCommodityAttributeId, prcca_CompanyId, ' 
							+ 'prcca_CommodityId, prcca_PublishedDisplay '
							+ 'From PRCompanyCommodityAttribute ' 
			SET @Abbr1Where = ' WHERE prcca_PublishedDisplay like ''%' + @OriginalAbbr + '%'' '
							+ ISNULL(' AND prcca_CommodityId = ' + @sCommodityId1, '')
			SET @Abbr2Where = ' WHERE prcca_PublishedDisplay like ''%' + @CorrectedAbbr + '%'' '
							+ ISNULL(' AND prcca_CommodityId = ' + @sCommodityId1, '')
			PRINT 'Modify the Commodity Abbreviation from ' + 
					ISNULL(@OriginalAbbr, 'NULL') + ' to ' + ISNULL(@CorrectedAbbr, 'NULL') +
					ISNULL('For CommodityId ' + @sCommodityId1, '') 
			PRINT '-------------------------------------------------------------------------------------------------'
			PRINT 'Correct those PRCompanyCommodityAttribute records'
			PRINT 'Original PRCompanyCommodityAttribute List'
			EXEC (@SelectSQL + @Abbr1Where)
			PRINT '  # of records retrieved: ' + cast(@@ROWCOUNT as varchar)

			PRINT ''
			PRINT 'Disable the Triggers for PRCompanyCommodityAttribute'
			ALTER TABLE PRCompanyCommodityAttribute DISABLE TRIGGER ALL
			
			PRINT ''
			PRINT 'Change the published display to reflect the new abbreviation'
			SET @Sql = 'Update PRCompanyCommodityAttribute SET '
						+ '[prcca_PublishedDisplay] = REPLACE(prcca_PublishedDisplay, ''' 
									+ @OriginalAbbr + ''', ''' + @CorrectedAbbr + ''')'
						+ ',[prcca_UpdatedBy] = ' + cast(@UpdateUserId as varchar)
						+ ',[prcca_UpdatedDate] = ''' + cast(@Now as varchar) + ''''
						+ ',[prcca_TimeStamp] = ''' + cast(@Now as varchar) + ''''
			EXEC (@Sql + @Abbr1Where)
			PRINT '  # of records updated: ' + cast(@@ROWCOUNT as varchar)

			PRINT ''
			PRINT 'Enable the Triggers for PRCompanyCommodityAttribute'
			ALTER TABLE PRCompanyCommodityAttribute ENABLE TRIGGER ALL
				
			PRINT ''
			PRINT 'Verify PRCompanyCommodityAttribute no longer uses the original abbreviation'
			EXEC (@SelectSQL + @Abbr1Where)
			PRINT '  # of records retrieved: ' + cast(@@ROWCOUNT as varchar)

			PRINT ''
			PRINT 'Verify PRCompanyCommodityAttribute uses the corrected abbreviation'
			EXEC (@SelectSQL + @Abbr2Where)
			PRINT '  # of records retrieved: ' + cast(@@ROWCOUNT as varchar)

			PRINT ''
			PRINT ''
			PRINT 'Correct the PRCommodity Commodity Code and Path Code '
			PRINT '-----------------------------------------------------'
			SET @SelectSQL = 'SELECT [prcm_CommodityId],[prcm_Name],[prcm_CommodityCode],'
								+ '[prcm_PathNames],[prcm_PathCodes] '
								+ ' FROM PRCommodity ' 
			SET @Abbr1Where = ' WHERE prcm_CommodityCode like ''%' + @OriginalAbbr + '%'' '
							+ ISNULL(' AND prcm_CommodityId = ' + @sCommodityId1, '')
			SET @Abbr2Where = ' WHERE prcm_CommodityCode like ''%' + @CorrectedAbbr + '%'' '
							+ ISNULL(' AND prcm_CommodityId = ' + @sCommodityId1, '')

			PRINT 'The record(s) to update'
			EXEC (@SelectSQL + @Abbr1Where)
			PRINT '  # of records retrieved: ' + cast(@@ROWCOUNT as varchar)

			PRINT ''
			PRINT 'Update the PRCommodity record'
			SET @Sql = 'Update PRCommodity SET '
						+ '[prcm_CommodityCode] = REPLACE(prcm_CommodityCode, ''' 
									+ @OriginalAbbr + ''', ''' + @CorrectedAbbr + ''')'
						+ ',[prcm_PathCodes] = REPLACE(prcm_PathCodes, ''' 
									+ @OriginalAbbr + ''', ''' + @CorrectedAbbr + ''')'
						+ ',[prcm_UpdatedBy] = ' + cast(@UpdateUserId as varchar)
						+ ',[prcm_UpdatedDate] = ''' + cast(@Now as varchar) + ''''
						+ ',[prcm_TimeStamp] = ''' + cast(@Now as varchar) + ''''
			EXEC (@Sql + @Abbr1Where)
			PRINT '  # of records updated: ' + cast(@@ROWCOUNT as varchar)

			PRINT ''
			PRINT 'Verify PRCommodity no longer uses the original abbreviation'
			EXEC (@SelectSQL + @Abbr1Where)
			PRINT '  # of records retrieved: ' + cast(@@ROWCOUNT as varchar)

			PRINT ''
			PRINT 'Verify PRCommodity uses the corrected abbreviation'
			EXEC (@SelectSQL + @Abbr2Where)
			PRINT '  # of records retrieved: ' + cast(@@ROWCOUNT as varchar)

		END ELSE  BEGIN
			PRINT 'ActionId ''' + cast(@ActionId as varchar) + ''' does not correspond to an available action.' 
		END
		COMMIT

	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		EXEC usp_RethrowError;
	END CATCH;
	PRINT ''
	PRINT '*****************************************************************************************'
	PRINT '*****************************************************************************************'
	PRINT ''

	SET NOCOUNT OFF
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_InsertCommodity]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[usp_InsertCommodity]
GO
CREATE PROCEDURE [dbo].[usp_InsertCommodity]
	@Name nvarchar(50),
	@CommodityCode nvarchar(34) ,
	@Level int ,
	@ParentId int = NULL,
	@DisplayOrder int = NULL,
	@CreatedBy int = NULL,
	@Alias nvarchar(200) = NULL,
	@SpanishName nvarchar(50) = NULL,
	@IPDFlag nchar(1) = NULL,
	@PathNames nvarchar(300) = NULL,
	@PathCodes nvarchar(300) = NULL
AS
BEGIN
	DECLARE @CommodityId int
	SET NOCOUNT ON
	BEGIN TRANSACTION
	BEGIN TRY

		Declare @Msg varchar(max)
		DECLARE @Now Datetime; SET @Now = getDate()
		
		IF (@Name is null OR @CommodityCode IS NULL OR @Level is null)
		BEGIN
			SET @Msg = 'A Name, CommodityCode, and Level value is required to add a commodity.'
			--PRINT @Msg
			SET @Msg = 'usp_InsertCommodity Error.  ' + @Msg
			RAISERROR (@Msg, 16, 1)
		END

		SET @CreatedBy = ISNULL(@CreatedBy, -1)

		-- get a commodity id value
		exec usp_getNextId 'PRCommodity', @CommodityId output

		-- if they are not passed, get the PathName and PathCode
		IF (@PathNames is null or @PathCodes is null)
		BEGIN
			Declare @Separator varchar(5); SET @Separator = ''

			Declare @ParentPathNames nvarchar (300), @ParentPathCodes nvarchar (300), @ParentLevel int

			Select @ParentPathNames = prcm_PathNames, 
					@ParentPathCodes = prcm_PathCodes, 
					@ParentLevel = prcm_Level
			  from PRCommodity 
			 where prcm_CommodityId = @ParentId

			WHILE (@ParentLevel < @Level) BEGIN
				SET @Separator = @Separator + ','
				SET @ParentLevel = @ParentLevel + 1 
			END
			
			IF (@PathNames is NULL) BEGIN
				SET @PathNames = COALESCE(@ParentPathNames + @Separator, '') + @Name
			END
			IF (@PathCodes is NULL) BEGIN
				SET @PathCodes = COALESCE(@ParentPathCodes + @Separator, '') + @CommodityCode
			END
		END

		INSERT INTO PRCommodity
				   (prcm_CommodityId
				   ,prcm_CreatedBy,prcm_CreatedDate,prcm_UpdatedBy,prcm_UpdatedDate,prcm_TimeStamp
				   ,prcm_ParentId,prcm_Level,prcm_Name,prcm_CommodityCode,prcm_Alias
				   ,prcm_Name_ES,prcm_IPDFlag,prcm_PathNames,prcm_PathCodes,prcm_DisplayOrder)
			 VALUES
				   (@CommodityId
				   ,@CreatedBy,@Now,@CreatedBy,@Now,@Now 
				   ,@ParentId,@Level,@Name,@CommodityCode,@Alias
				   ,@SpanishName,@IPDFlag,@PathNames,@PathCodes,@DisplayOrder)

		PRINT 'PRCommodity Added - ID: ' + cast(@CommodityId as varchar) + ', Name:' +@Name + ', Abbr:' + @CommodityCode + ', ParentId:' + cast(@ParentId as varchar) 
		COMMIT

	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		EXEC usp_RethrowError;
	END CATCH;
	SET NOCOUNT OFF
	return @CommodityId
END
GO


If Exists (Select name from sysobjects where name = 'usp_PopulatePRCommodityTranslation' and type='P') 
	Drop Procedure dbo.usp_PopulatePRCommodityTranslation
Go

/**
This procedure was ported from the BBSInterface and as little as possible
changed.  This is why there are some legacy names such as CMDVAL.

It populates the PRCommondityTranslation with every possible combination of 
commodity, attribute, and growing method.  PRCommodityTranslation records that
already exist are updated to preserver the Spanish translations.
**/
CREATE PROCEDURE [dbo].[usp_PopulatePRCommodityTranslation]
as 

	-- As a result of reorganizing the commodities, PIKS has some scenarios 
	-- where the computed name can exceed the length allowed by BBS.  Per
	-- PRCo, we should just truncate the name in these circumstances.
	DECLARE @Commodity table (
			prcm_CommodityID int,	
			prcm_CommodityCode nvarchar(36),
			prcm_PathCode nvarchar(300),
			prcm_Name nvarchar(43),
			prcm_Key char(1)
	)

	--Get all commodities that are level 1-3.  This is type 1 in the Mapping 
	--commodity homwork.
	INSERT INTO @Commodity
	SELECT 
		prcm_CommodityID,
		rtrim(prcm_CommodityCode),
		rtrim(prcm_PathCodes),
		rtrim(prcm_Name),
		'Y'
	from PRCommodity
	where prcm_level < 4



	--Get all level 4 commodities.  This is type 3 in the Mapping commodity homework.
	INSERT INTO @Commodity
	SELECT 
		a.prcm_CommodityID, 	
		(rtrim(a.prcm_CommodityCode)+ rtrim(lower(b.prcm_CommodityCode))),
		rtrim(a.prcm_PathCodes),	
		(rtrim(a.prcm_Name)+' '+rtrim(lower(b.prcm_Name))),
		NULL
	from PRCommodity a 
		inner join PRCommodity b on a.prcm_ParentID=b.prcm_CommodityID
	where 
		a.prcm_level = 4
		and a.prcm_Name != b.prcm_Name



	--Get all level 5 commodities where parent is a level 3.  Thi is type 2
	-- in the mapping commodity homework.
	INSERT INTO @Commodity
	SELECT 
		a.prcm_CommodityID, 	
		(rtrim(a.prcm_CommodityCode)+ rtrim(lower(b.prcm_CommodityCode))),
		rtrim(a.prcm_PathCodes),
		(rtrim(a.prcm_Name)+' '+rtrim(lower(b.prcm_Name))),
		NULL
	from PRCommodity a 
		inner join PRCommodity b on a.prcm_ParentID=b.prcm_CommodityID
	where 
		a.prcm_level = 5
		and b.prcm_Level=3
		and a.prcm_Name != b.prcm_Name


	--Get all level 5 commodities where parent is a level 4.  This is type 4 in
	--the commodity
	INSERT INTO @Commodity
	SELECT 
		a.prcm_CommodityID, 	
		(rtrim(a.prcm_CommodityCode)+ rtrim(lower(b.prcm_CommodityCode)) + rtrim(lower(c.prcm_CommodityCode))),
		rtrim(a.prcm_PathCodes),
		(rtrim(a.prcm_Name) + ' ' + rtrim(lower(b.prcm_Name)) + ' ' + rtrim(lower(c.prcm_Name))),
		NULL
	from PRCommodity a 
		inner join PRCommodity b on a.prcm_ParentID=b.prcm_CommodityID
		inner join PRCommodity c on b.prcm_ParentID=c.prcm_CommodityID
	where 
		a.prcm_level = 5
		and b.prcm_Level=4
		and c.prcm_Name != a.prcm_Name
		and c.prcm_Name != b.prcm_Name
		and a.prcm_name != b.prcm_Name


	--Get all level 6 commodities where parent is a level 5.  This is type 5 in
	--the commodity
	INSERT INTO @Commodity
	SELECT 
		a.prcm_CommodityID, 	
		(rtrim(a.prcm_CommodityCode)+ rtrim(lower(b.prcm_CommodityCode)) + rtrim(lower(c.prcm_CommodityCode))),
		rtrim(a.prcm_PathCodes),
		(rtrim(a.prcm_Name) + ' ' + rtrim(lower(b.prcm_Name)) + ' ' + rtrim(lower(c.prcm_Name))),
		NULL
	from PRCommodity a 
		inner join PRCommodity b on a.prcm_ParentID=b.prcm_CommodityID
		inner join PRCommodity c on b.prcm_ParentID=c.prcm_CommodityID
	where 
		a.prcm_level = 6
		and b.prcm_Level=5
		and c.prcm_Name != a.prcm_Name
		and c.prcm_Name != b.prcm_Name
		and a.prcm_name != b.prcm_Name;

	-- Create Combinations of Commodities and attributes
	DECLARE @CmdVal TABLE (
		  [COMMOD] [varchar](45) NULL,
		  [DESC] [varchar](40) NULL,
		  [DESC_SPANISH] [varchar](45) NULL,
		  [KEY] [varchar](1) NULL
	) 

	--Get all commodities without attributes
	INSERT INTO @CmdVal (COMMOD, [DESC], [KEY])
	SELECT prcm_CommodityCode, prcm_Name, prcm_key
	  FROM @Commodity;

	--Get combinations of all commodities and growing methods
	INSERT INTO @CmdVal (COMMOD, [DESC])
	SELECT RTRIM(prat_Abbreviation) + RTRIM(LOWER(prcm_CommodityCode)), 
		SUBSTRING(RTRIM(prat_Name) + ' ' + RTRIM(Lower(prcm_Name)),1 ,40)
	  FROM PRAttribute CROSS JOIN
		   @Commodity
	 WHERE prat_Type = 'GM';

	--Get all combinations of all commodities and all non-growing method attributes
	--where the attribute is placed BEFORE the commodity.
	INSERT INTO @CmdVal (COMMOD, [DESC])
	SELECT RTRIM(prat_Abbreviation) + RTRIM(LOWER(prcm_CommodityCode)), 
		SUBSTRING(RTRIM(prat_Name) + ' ' + RTRIM(lower(prcm_Name)),1 ,40)
	  FROM PRAttribute CROSS JOIN
		   @Commodity
	 WHERE prat_Type != 'GM'
		and prat_PlacementAfter is null;


	--Get all combinations of all commodities and all non-growing method attributes
	--where the attribute is placed AFTER the commodity.
	INSERT INTO @CmdVal (COMMOD, [DESC])
	SELECT RTRIM(prcm_CommodityCode) + RTRIM(lower(prat_Abbreviation)) , 
		SUBSTRING(RTRIM(prcm_Name)+ ' ' + Rtrim(lower(prat_Name)) ,1 ,40)
	  FROM PRAttribute CROSS JOIN
		   @Commodity
	 WHERE prat_Type != 'GM'
		and prat_PlacementAfter is not null;

	--This is hard-coded to fit commodity exercise from Kathi's spreadsheet on 9/23/2019
	--Per discussion between CHW and JMT
	INSERT INTO @CmdVal (COMMOD, [DESC])
	VALUES('Pricklycactusprpuree', 'Prickly Pear Cactus Puree')

	--Get all combinations of all commodities and all growing methods and all attributes
	--where the attribute is placed BEFORE the commodity.
	INSERT INTO @CmdVal (COMMOD, [DESC])
	SELECT RTRIM(gm.prat_Abbreviation) + RTRIM(lower(a.prat_Abbreviation)) + RTRIM(LOWER(prcm_CommodityCode)), 
		SUBSTRING(RTRIM(gm.prat_Name) + ' ' + RTRIM(lower(a.prat_Name)) + ' ' + RTRIM(lower(prcm_Name)),1 ,40)
	  FROM PRAttribute a CROSS JOIN
			PRAttribute gm cross join
		   @Commodity 
	 WHERE a.prat_Type != 'GM'
		and a.prat_PlacementAfter is null
		and gm.prat_Type = 'GM';


	--Get all combinations of all commodities and all growing methods and all attributes
	--where the attribute is placed AFTER the commodity.
	INSERT INTO @CmdVal (COMMOD, [DESC])
	SELECT RTRIM(gm.prat_Abbreviation)  + RTRIM(LOWER(prcm_CommodityCode))+ RTRIM(Lower(a.prat_Abbreviation)), 
		SUBSTRING(RTRIM(gm.prat_Name)  + ' ' + RTRIM(Lower(prcm_Name))+ ' ' + RTRIM(Lower(a.prat_Name)),1 ,40)
	  FROM PRAttribute a CROSS JOIN
			PRAttribute gm cross join
		   @Commodity 
	 WHERE a.prat_Type != 'GM'
		and a.prat_PlacementAfter='Y'
		and gm.prat_Type = 'GM'

	-- This is a hack to take care of an new situation.  We have a commodity Breadn and a separate
	-- commodity Breadnseeds.  However, when we build this commodity attribute matrix, we combine Breadn + seeds
	-- to end up with two Breadnseeds.  This causes duplicate records to dispaly in other areas of the 
	-- system.  Just delete the second record for now.  CHW 3/22/2018
	DELETE FROM @CmdVal WHERE COMMOD = 'Breadnseeds' AND [Key] IS NULL

	-- Let's add any new records to our lookup table.
	DECLARE @Count int, @Index int, @ID int
	DECLARE @Commod varchar(40), @Description varchar(50), @Key varchar(1)
	DECLARE @NewCommods table (
		ndx int identity(1,1) primary key,
		commod varchar(50),
		description varchar(40),
		keyflag varchar(1)
	)

	DECLARE @OldCommods table (
		ndx int identity(1,1) primary key,
		commod varchar(50),
		description varchar(40),
		keyflag varchar(1)
	)


	INSERT INTO @NewCommods (commod, description, keyflag)
	SELECT DISTINCT COMMOD, [DESC], [key]
	  FROM @CmdVal
	 WHERE COMMOD NOT IN (SELECT prcx_Abbreviation
							FROM PRCommodityTranslation);

	INSERT INTO @OldCommods (commod, description, keyflag)
	SELECT DISTINCT COMMOD, [DESC], [key]
	  FROM @CmdVal
	 WHERE COMMOD IN (SELECT prcx_Abbreviation
						FROM PRCommodityTranslation);

	SELECT @Count = COUNT(1)
	  FROM @NewCommods;
	SET @Index = 0

	WHILE @Index < @Count BEGIN
		SET @Index = @Index + 1

		SELECT @Commod = Commod,
			   @Description = description,
			   @Key = keyflag
		  FROM @NewCommods
		 WHERE ndx = @Index;
		
		EXEC usp_GetNextID 'PRCommodityTranslation', @ID OUTPUT

		INSERT INTO PRCommodityTranslation
			(prcx_CommodityTranslationId, prcx_CreatedBy, prcx_CreatedDate, prcx_UpdatedBy, prcx_UpdatedDate, prcx_TimeStamp, prcx_Abbreviation, prcx_Description, prcx_Key)
			VALUES (@ID, -1, GETDATE(), -1, GETDATE(), GETDATE(), @Commod, @Description, @Key);

	END

	-- Now update the existing abbreviations
	UPDATE PRCommodityTranslation
	   SET prcx_Description = Description,
		   prcx_Key = keyflag
	  FROM @OldCommods 
	 WHERE commod = prcx_Abbreviation;
GO



If Exists (Select name from sysobjects where name = 'usp_MovePACALicense' and type='P') 
	Drop Procedure dbo.usp_MovePACALicense
Go

/**
	Moves the specified license from the source company to the
	target company.  Displays informational messages so this is
	intended to be manually executed.
**/
CREATE PROCEDURE [dbo].[usp_MovePACALicense]
	@SourceCompanyID int, 
    @TargetCompanyID int, 
    @LicenseNumber varchar(10), 
    @CRMUserID int
AS
BEGIN 

	DECLARE @Count int

	SELECT @Count = COUNT(1)
	  FROM PRPACALicense 
	 WHERE prpa_CompanyID = @SourceCompanyID
	   AND prpa_LicenseNumber = @LicenseNumber;

	IF @Count = 0 BEGIN
		DECLARE @Msg varchar(500)
		SET @Msg = 'License Number ' + @LicenseNumber + ' is not associated with Company ID ' + Convert(varchar(10), @SourceCompanyID)  + '.  Please review.'
		RAISERROR(@Msg,16,1)
		RETURN
	END

	UPDATE PRPACALicense
	   SET prpa_CompanyID = @TargetCompanyID,
		   prpa_UpdatedDate = GETDATE(),
		   prpa_UpdatedBy = @CRMUserID,
		   prpa_Timestamp = GETDATE()
	 WHERE prpa_LicenseNumber = @LicenseNumber
	   AND prpa_CompanyID = @SourceCompanyID;


	Print 'License Number ' + @LicenseNumber + ' has been moved from Company ID ' + Convert(varchar(10), @SourceCompanyID)  + ' to Company ID ' + Convert(varchar(10), @TargetCompanyID)  + '.'

	SELECT @Count = COUNT(1)
	  FROM PRPACALicense 
	 WHERE prpa_CompanyID = @TargetCompanyID
	   AND prpa_LicenseNumber <> @LicenseNumber;

	IF @Count > 0 BEGIN
		Print 'Target company ' + Convert(varchar(10), @TargetCompanyID)  + ' now has more than one license number associated with it.  Please verify the current/publish flags.'
	END


	SELECT @Count = COUNT(1)
	  FROM PRCompanyLicense  
	 WHERE prli_CompanyID = @TargetCompanyID
	   AND prli_Type = 'PACA';

	IF @Count > 0 BEGIN
		Print 'Please verify the unconfirmed license information for target Company ID' + Convert(varchar(10), @TargetCompanyID) + '.'
	END
END
Go

If Exists (Select name from sysobjects where name = 'usp_UpdateSQLIdentity' and type='P') 
	Drop Procedure dbo.usp_UpdateSQLIdentity
Go

/**
	Updates the SQL_Identity and Rep_Ranges table
	to reflect the primary key ID values in the
	specified table.
**/
CREATE PROCEDURE [dbo].[usp_UpdateSQLIdentity]
	@TableName varchar(50), 
	@PrimaryKeyName varchar(50)
AS
BEGIN 

	DECLARE @SQL varchar(8000)
	SET @SQL = 'Declare @IDMax int' +
	' Declare @TableId int' +
	' Declare @RepRangeStart int' +
	' select @TableId = Bord_TableId from custom_tables where Bord_Caption = ' + '''' + @TableName + '''' +
	' select @IDMax = Max(' + @PrimaryKeyName + ') from ' + @TableName +
	' select @RepRangeStart = ((@IDMax / 500)*500)'  +
	' If (@IDMax is not null)' +
	' BEGIN' +
	'    update SQL_Identity set ID_NextId = @IDMax + 1 ' +
	'       where ID_TableId = @TableId;' +
	'    update Rep_Ranges ' +
	'      set Range_RangeStart = @RepRangeStart,' +
	'            Range_RangeEnd = @RepRangeStart + 499,' +
	'            Range_NextRangeStart = @RepRangeStart + 500,' +
	'            Range_NextRangeEnd = @RepRangeStart + 999,' +
	'            Range_Control_NextRange = @RepRangeStart + 1000' +
	'       where Range_TableId = @TableId;' +
	' END'
	Exec(@SQL)
END
Go



If Exists (Select name from sysobjects where name = 'usp_ConvertAllFieldsToVarchar' and type='P') 
	Drop Procedure dbo.usp_ConvertAllFieldsToVarchar
Go

/**
	Converts all NChar/Char columns with a length greater
	than 2 into a Varchar.  Columns that are part of an
	index are skipped.
**/
CREATE PROCEDURE [dbo].[usp_ConvertAllFieldsToVarchar]
AS
BEGIN 

	IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Person]') AND name = N'IDX_Pers_FullName') 
		DROP INDEX [IDX_Pers_FullName] ON [dbo].[Person] WITH ( ONLINE = OFF ) 

	IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Person]') AND name = N'ndx_pers_NameId') 
		DROP INDEX [ndx_pers_NameId] ON [dbo].[Person] WITH ( ONLINE = OFF ) 


	DECLARE @TableColumns table (
		ndx int identity(1,1) primary key,
		TableName varchar(100),
		ColumnName varchar(100),
		ColumnSize int
	)

	INSERT INTO @TableColumns (TableName, ColumnName, ColumnSize)
	SELECT table_name, column_name, character_maximum_length 
	  FROM INFORMATION_SCHEMA.COLUMNS
	 WHERE data_type IN ('nchar', 'char')
	   AND character_maximum_length > 2
	   AND table_name not like 'v%'
	   AND table_name not like '%.*';

	DECLARE @Count int, @Index int, @IndexCount int
	DECLARE @TableName varchar(100), @ColumnName varchar(100), @ColumnSize varchar(10)
	DECLARE @SQL varchar(5000)

	SELECT @Count = COUNT(1) From @TableColumns;
	SET @Index = 1
	SET @IndexCount = 0

	WHILE (@Index < @Count) BEGIN
		SELECT @TableName = TableName,
			   @ColumnName = ColumnName,
			   @ColumnSize = Convert(varchar(10), ColumnSize)
		  FROM @TableColumns
		 WHERE ndx = @Index;


		SELECT @IndexCount = COUNT(1)
		  FROM sys.sysindexkeys sik
			   INNER JOIN sys.columns c ON sik.colID = column_id
			   INNER JOIN sys.tables t ON c.object_id = t.object_id and sik.id = t.object_id
			   INNER JOIN sysindexes si ON t.object_id = si.id AND sik.indid = si.indid
		 WHERE t.name = @TableName
		   AND c.name = @ColumnName

		IF (@IndexCount = 0) BEGIN
			SET @SQL = 'ALTER TABLE ' + @TableName + ' ' + +  'ALTER COLUMN ' + @ColumnName + ' varchar(' +@ColumnSize + ')'
			Print @SQL
			EXEC(@SQL)
		END

		SET @Index = @Index + 1
		SET @SQL = NULL
		SET @IndexCount = 0
	END


	ALTER TABLE Person DISABLE TRIGGER ALL
	UPDATE Person SET
		pers_FirstName = RTRIM(pers_FirstName),
		pers_LastName = RTRIM(pers_LastName),
		Pers_MiddleName = RTRIM(Pers_MiddleName),
		Pers_Suffix = RTRIM(Pers_Suffix);
	ALTER TABLE Person ENABLE TRIGGER ALL


	ALTER TABLE Address DISABLE TRIGGER ALL
	UPDATE Address SET
		Addr_Address1 = RTRIM(Addr_Address1),
		Addr_Address2 = RTRIM(Addr_Address2),
		Addr_Address3 = RTRIM(Addr_Address3),
		Addr_Address4 = RTRIM(Addr_Address4);
	ALTER TABLE Address ENABLE TRIGGER ALL


	CREATE CLUSTERED INDEX [IDX_Pers_FullName] ON [dbo].[Person] 
	( [Pers_LastName] ASC,[Pers_FirstName] ASC) 
	WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY] 

	CREATE NONCLUSTERED INDEX [ndx_pers_NameId] ON [dbo].[Person] 
	( [Pers_LastName] ASC,[Pers_FirstName] ASC,[Pers_PersonId] ASC) 
	WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY] 


END
Go


If Exists (Select name from sysobjects where name = 'usp_VerifySQLIdentityValues' and type='P') Drop Procedure dbo.usp_VerifySQLIdentityValues
Go

/**
**/
CREATE PROCEDURE dbo.usp_VerifySQLIdentityValues
	@Verbose bit = 0
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @Count int, @Index int, @TableID int, @NextID int, @StartRange int, @EndRange int, @CurrentMaxID int
	DECLARE @RowCount int
	DECLARE @TableName varchar(100), @TableKeyField varchar(100), @SQL varchar(1000), @Msg varchar(5000)
	DECLARE @Error bit, @TableError bit
	SET @Error = 0

	DECLARE @Tables table (
		ndx int identity(1,1) primary key,
		TableID int,
		TableName varchar(100),
		TableKeyField varchar(100)
	)

	CREATE TABLE #CurrentMaxID (
		CurrentMaxID int
	)


	INSERT INTO @Tables (TableID, TableName, TableKeyField)
	SELECT bord_tableid, bord_name, bord_IdField
	  FROM custom_tables
	 WHERE bord_name NOT LIKE 'v%'
	ORDER BY bord_name;
	 


	SELECT @Count = COUNT(1) FROM @Tables;
	SET @Index = 0

	WHILE (@Index < @Count) BEGIN
		SET @Index = @Index + 1

		SELECT @TableID = TableID,
			   @TableName = RTRIM(TableName),
			   @TableKeyField = RTRIM(TableKeyField)
		  FROM @Tables
		 WHERE ndx = @Index;

		IF EXISTS (select 1 from sysobjects where name = @TableName) BEGIN

			SELECT @NextID = id_NextID
			  FROM SQL_Identity
			 WHERE id_tableID = @TableID;

			SELECT @StartRange = Range_RangeStart,
				   @EndRange = Range_RangeEnd
			  FROM Rep_Ranges 
			 WHERE range_tableID = @TableID;
		 
			SET @SQL = 'INSERT INTO #CurrentMaxID SELECT ISNULL(MAX(' + @TableKeyField + '),0) FROM ' + @TableName
			--PRINT @SQL
			EXECUTE(@SQL)

			SELECT @CurrentMaxID = MAX(CurrentMaxID) FROM #CurrentMaxID;
			SET @TableError = 0
			IF (@CurrentMaxID > 0) BEGIN
				IF (@CurrentMaxID >= @NextID) BEGIN
					SET @Error = 1
					SET @TableError = 1	
					PRINT @TableName + ':' +  ' Current Max Value of ' + @TableKeyField + ' (' + CONVERT(varchar(10), @CurrentMaxID ) + ') is greater than or equal to SQL_Identity.id_NextID value (' + CONVERT(varchar(10), @NextID ) + ')';
				END

				IF (@CurrentMaxID < @StartRange) OR
				   (@CurrentMaxID > @EndRange) BEGIN
					SET @Error = 1
					SET @TableError = 1	
					PRINT @TableName + ':' +  ' Current Max Value of ' + @TableKeyField + ' (' + CONVERT(varchar(10), @CurrentMaxID ) + ') is not within the current range of IDs (' + CONVERT(varchar(10), @StartRange) + ' and ' + CONVERT(varchar(10), @EndRange ) + ')';
				END
			END
			
			IF (@Verbose = 1) AND (@TableError = 0) BEGIN
				PRINT @TableName + ': No Errors Found'
			END 

			DELETE FROM #CurrentMaxID;
		END
	END

	DROP TABLE #CurrentMaxID;

	IF (@Error = 0) BEGIN
		PRINT 'No SQL_Identity Errors Found'
	END

	SET NOCOUNT OFF
END
GO

IF EXISTS (
	SELECT Name FROM sysobjects WHERE Name = 'usp_BBScoreReport' and type='P') 
	DROP Procedure dbo.usp_BBScoreReport
Go

CREATE Procedure [dbo].[usp_BBScoreReport]
    @CompanyID int,
    @ReportDate datetime = NULL
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
		PACALicenseNumber varchar(100),
		RecentClaimCount int,
		PayIndicator varchar(200)
	)
	INSERT INTO @ReportTable (BBID, CompanyName, Location, CurrentRating, RatingDate, PreviousRating, ReceiverBBID, PACALicenseNumber, RecentClaimCount, PayIndicator)
	SELECT comp_CompanyID, comp_PRCorrTradestyle, CityStateCountryShort, prra_RatingLine, prra_Date, dbo.ufn_GetPreviousRating(comp_CompanyID), 
	       @CompanyID, prpa_LicenseNumber, 0, prcpi_PayIndicator
	  FROM Company WITH (NOLOCK)
		   INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
		   LEFT OUTER JOIN vPRCompanyRating on comp_CompanyID = prra_CompanyID AND prra_Current='Y'
		   LEFT OUTER JOIN PRCompanyPayIndicator WITH (NOLOCK) ON comp_CompanyID = prcpi_CompanyID AND prcpi_Current = 'Y'
		   LEFT OUTER JOIN PRPACALicense WITH (NOLOCK) on prpa_CompanyID = comp_CompanyID
				                                      AND prpa_Current = 'Y' 
													  AND prpa_Publish = 'Y'
	 WHERE comp_PRListingStatus IN ('L', 'H', 'LUV')
	   AND comp_CompanyID IN (SELECT DISTINCT comp_PRHQID 
								FROM PRCompanyRelationship WITH (NOLOCK)
								     INNER JOIN Company WITH (NOLOCK) ON prcr_RightCompanyID = comp_CompanyID
							   WHERE prcr_Deleted IS NULL 
                                 AND prcr_Active = 'Y'
								 AND prcr_Type in ('04','09','10','11','12','13','14','15','16')
								 AND prcr_LeftCompanyID = @CompanyID);

	-- Get our Receiver's BBScore
	UPDATE @ReportTable
       SET ReceiverBBScore = prbs_BBScore
      FROM PRBBScore WITH (NOLOCK)
     WHERE prbs_Current = 'Y'
       AND prbs_PRPublish = 'Y'
       AND prbs_CompanyID = @CompanyID;

	-- Get our current month score
	SET @Start1 =  DATEADD(mm, DATEDIFF(mm, 0, @ReportDate), 0)
	SET @End1 = DATEADD(s, -1, DATEADD(month, 1, @Start1))

	UPDATE @ReportTable
	   SET CurrentMonthBBSScore = prbs_BBScore,
		   Change = prbs_Deviation,
		   CurrentMonth = Month(@Start1)
	  FROM PRBBScore WITH (NOLOCK)
	       INNER JOIN @ReportTable ON prbs_CompanyID = BBID
	 WHERE prbs_Date BETWEEN @Start1 AND @End1
	   AND prbs_PRPublish = 'Y';

	-- Get our Month - 1 Score
	SET @End2 =  DATEADD(s, -1, @Start1)
	SET @Start2 = DATEADD(month, -1, @Start1)

	UPDATE @ReportTable
	   SET MonthMinus1BBSScore = prbs_BBScore,
		   MonthMinus1 = Month(@Start2)
	  FROM PRBBScore WITH (NOLOCK)
	       INNER JOIN @ReportTable ON prbs_CompanyID = BBID
	 WHERE prbs_Date BETWEEN @Start2 AND @End2
	   AND prbs_PRPublish = 'Y';

	-- Get our Month - 2 Score
	SET @End3 =  DATEADD(s, -1, @Start2)
	SET @Start3 = DATEADD(month, -1, @Start2)

	UPDATE @ReportTable
	   SET MonthMinus2BBSScore = prbs_BBScore,
		   MonthMinus2 = Month(@Start3)
	  FROM PRBBScore WITH (NOLOCK)
		   INNER JOIN @ReportTable ON prbs_CompanyID = BBID
	 WHERE prbs_Date BETWEEN @Start3 AND @End3
	   AND prbs_PRPublish = 'Y';

	--GET Recent Number of BBS Claims filed in past 90 days. -- populate this column with total number of BBS claims (where subject company is Respondent) with a Date Filed date within the past 90 days.
	UPDATE @ReportTable
		SET RecentClaimCount = (SELECT COUNT(*) FROM vPRBBSiClaims 
								WHERE 
									prss_RespondentCompanyId = BBID
									AND ISNULL(prss_ClosedDate, GETDATE()) >= DATEADD(day, -90, GETDATE())
									AND prss_Status IN ('O', 'C')
									AND prss_Publish = 'Y'
								)

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
		   PACALicenseNumber,
		   RecentClaimCount,
		   PayIndicator
      FROM @ReportTable 
  ORDER BY CurrentMonthBBSScore DESC,
           CompanyName;

END
GO

IF EXISTS (
	SELECT Name FROM sysobjects WHERE Name = 'usp_BBScoreReport_Lumber' and type='P') 
	DROP Procedure dbo.usp_BBScoreReport_Lumber
Go

CREATE Procedure [dbo].[usp_BBScoreReport_Lumber]
    @CompanyID int,
	@WebUserID int,
    @ReportDate datetime = NULL
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
		PACALicenseNumber varchar(100),
		RecentClaimCount int,
		PayIndicator varchar(200)
	)
	INSERT INTO @ReportTable (BBID, CompanyName, Location, CurrentRating, RatingDate, PreviousRating, ReceiverBBID, PACALicenseNumber, RecentClaimCount, PayIndicator)
		SELECT comp_CompanyID, comp_PRCorrTradestyle, CityStateCountryShort, prra_RatingLine, prra_Date, dbo.ufn_GetPreviousRating(comp_CompanyID), 
			@CompanyID, prpa_LicenseNumber, 0, prcpi_PayIndicator
		FROM Company WITH (NOLOCK)
			INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
			LEFT OUTER JOIN vPRCompanyRating on comp_CompanyID = prra_CompanyID AND prra_Current='Y'
			LEFT OUTER JOIN PRCompanyPayIndicator WITH (NOLOCK) ON comp_CompanyID = prcpi_CompanyID AND prcpi_Current = 'Y'
			LEFT OUTER JOIN PRPACALicense WITH (NOLOCK) on prpa_CompanyID = comp_CompanyID
				                                      AND prpa_Current = 'Y' 
													  AND prpa_Publish = 'Y'
		WHERE comp_PRListingStatus IN ('L', 'H', 'LUV')
			AND comp_CompanyID IN	(
										SELECT prwuld_AssociatedID
										FROM PRWebUserList WITH (NOLOCK)
											INNER JOIN PRWebUserListDetail WITH (NOLOCK) ON prwucl_WebUserListID = prwuld_WebUserListID
										WHERE prwucl_TypeCode='AUS' AND prwucl_WebUserID = @WebUserID
									)
 
 -- Get our Receiver's BBScore
		UPDATE @ReportTable
			SET ReceiverBBScore = prbs_BBScore
		FROM PRBBScore WITH (NOLOCK)
		WHERE prbs_Current = 'Y'
			AND prbs_PRPublish = 'Y'
			AND prbs_CompanyID = @CompanyID;

		-- Get our current month score
		SET @Start1 =  DATEADD(mm, DATEDIFF(mm, 0, @ReportDate), 0)
		SET @End1 = DATEADD(s, -1, DATEADD(month, 1, @Start1))

		UPDATE @ReportTable
		SET CurrentMonthBBSScore = prbs_BBScore,
			Change = prbs_Deviation,
			CurrentMonth = Month(@Start1)
		FROM PRBBScore WITH (NOLOCK)
			INNER JOIN @ReportTable ON prbs_CompanyID = BBID
		WHERE prbs_Date BETWEEN @Start1 AND @End1
			AND prbs_PRPublish = 'Y';

		-- Get our Month - 1 Score
		SET @End2 =  DATEADD(s, -1, @Start1)
		SET @Start2 = DATEADD(month, -1, @Start1)

		UPDATE @ReportTable
			SET MonthMinus1BBSScore = prbs_BBScore,
				MonthMinus1 = Month(@Start2)
			FROM PRBBScore WITH (NOLOCK)
				INNER JOIN @ReportTable ON prbs_CompanyID = BBID
			WHERE prbs_Date BETWEEN @Start2 AND @End2
				AND prbs_PRPublish = 'Y';

		-- Get our Month - 2 Score
		SET @End3 =  DATEADD(s, -1, @Start2)
		SET @Start3 = DATEADD(month, -1, @Start2)

		UPDATE @ReportTable
		SET MonthMinus2BBSScore = prbs_BBScore,
			MonthMinus2 = Month(@Start3)
		FROM PRBBScore WITH (NOLOCK)
			INNER JOIN @ReportTable ON prbs_CompanyID = BBID
		WHERE prbs_Date BETWEEN @Start3 AND @End3
			AND prbs_PRPublish = 'Y';

		--GET Recent Number of BBS Claims filed in past 90 days. -- populate this column with total number of BBS claims (where subject company is Respondent) with a Date Filed date within the past 90 days.
		UPDATE @ReportTable
			SET RecentClaimCount = (
										SELECT COUNT(*) FROM vPRBBSiClaims 
										WHERE prss_RespondentCompanyId = BBID
											AND ISNULL(prss_ClosedDate, GETDATE()) >= DATEADD(day, -90, GETDATE())
											AND prss_Status IN ('O', 'C')
											AND prss_Publish = 'Y'
									)

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
			   PACALicenseNumber,
			   RecentClaimCount,
			   PayIndicator
		FROM @ReportTable 
		ORDER BY CurrentMonthBBSScore DESC,
			   CompanyName;

END
GO


IF EXISTS (
	SELECT Name FROM sysobjects WHERE Name = 'usp_BBOSBBScoreReport' and type='P') 
	DROP Procedure dbo.usp_BBOSBBScoreReport
Go

/**
	Pulls the BBScoreReport data for the selected company ids.
    This procedure is used by the BBOSBBScore report.
**/
CREATE Procedure [dbo].[usp_BBOSBBScoreReport]
    @CompanyID int, 
    @CompanyIDList varchar(4000),
    @ReportDate datetime = NULL
AS
BEGIN
	IF (@ReportDate IS NULL) BEGIN
		SELECT @ReportDate = MAX(prbs_Date)
          FROM PRBBScore 
         WHERE prbs_Current = 'Y';
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
		RecentClaimCount int,
		PayIndicator varchar(200)
	)
	
	INSERT INTO @ReportTable (BBID, CompanyName, Location, CurrentRating, RatingDate, PreviousRating, ReceiverBBID, RecentClaimCount, PayIndicator)
	SELECT comp_CompanyID, comp_PRCorrTradestyle, CityStateCountryShort, prra_RatingLine, prra_Date, dbo.ufn_GetPreviousRating(comp_CompanyID), 
	@CompanyID, 0, prcpi_PayIndicator
	  FROM Company WITH (NOLOCK)
		   INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
		   LEFT OUTER JOIN vPRCompanyRating on comp_CompanyID = prra_CompanyID AND prra_Current='Y'
		   LEFT OUTER JOIN PRCompanyPayIndicator WITH (NOLOCK) ON comp_CompanyID = prcpi_CompanyID AND prcpi_Current = 'Y'
	 WHERE comp_CompanyID IN (SELECT CAST(value AS INT) FROM dbo.Tokenize(@CompanyIDList, ','));

	-- Get our Receiver's BBScore
	UPDATE @ReportTable
       SET ReceiverBBScore =prbs_BBScore
      FROM PRBBScore WITH (NOLOCK)
     WHERE prbs_Current = 'Y'
       AND prbs_PRPublish = 'Y' 
       AND prbs_CompanyID = @CompanyID;


	-- Get our current month score
	SET @Start1 =  DATEADD(mm, DATEDIFF(mm, 0, @ReportDate), 0)
	SET @End1 = DATEADD(s, -1, DATEADD(month, 1, @Start1))	
	
	UPDATE @ReportTable
	   SET CurrentMonthBBSScore = prbs_BBScore,
		   Change = prbs_Deviation,
		   CurrentMonth = Month(@Start1)
	  FROM PRBBScore WITH (NOLOCK)
		   INNER JOIN @ReportTable ON prbs_CompanyID = BBID
	 WHERE prbs_Date BETWEEN @Start1 AND @End1
	   AND prbs_PRPublish = 'Y';

	-- Get our Month - 1 Score
	SET @End2 =  DATEADD(s, -1, @Start1)
	SET @Start2 = DATEADD(month, -1, @Start1)
	
	UPDATE @ReportTable
	   SET MonthMinus1BBSScore = prbs_BBScore,
		   MonthMinus1 = Month(@Start2)
	  FROM PRBBScore WITH (NOLOCK)
		   INNER JOIN @ReportTable ON prbs_CompanyID = BBID
	 WHERE prbs_Date BETWEEN @Start2 AND @End2
	   AND prbs_PRPublish = 'Y';

	-- Get our Month - 2 Score
	SET @End3 =  DATEADD(s, -1, @Start2)
	SET @Start3 = DATEADD(month, -1, @Start2)
	
	UPDATE @ReportTable
	   SET MonthMinus2BBSScore = prbs_BBScore,
		   MonthMinus2 = Month(@Start3)
	  FROM PRBBScore WITH (NOLOCK)
		   INNER JOIN @ReportTable ON prbs_CompanyID = BBID
	 WHERE prbs_Date BETWEEN @Start3 AND @End3
	   AND prbs_PRPublish = 'Y';

	--GET Recent Number of BBS Claims filed in past 90 days. -- populate this column with total number of BBS claims (where subject company is Respondent) 
	--with a Date Filed date within the past 90 days.
	UPDATE @ReportTable
		SET RecentClaimCount = (SELECT COUNT(*) FROM vPRBBSiClaims 
								WHERE 
									prss_RespondentCompanyId = BBID
									AND ISNULL(prss_ClosedDate, GETDATE()) >= DATEADD(day, -90, GETDATE())
									AND prss_Status IN ('O', 'C')
									AND prss_Publish = 'Y'
								)

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
		   RecentClaimCount,
		   PayIndicator
      FROM @ReportTable 
  ORDER BY CurrentMonthBBSScore DESC,
           CompanyName;
END
GO


If Exists (Select name from sysobjects where name = 'usp_ResetBBOSUserListConnectionList' and type='P') Drop Procedure dbo.usp_ResetBBOSUserListConnectionList
Go

/**
	Resets the PRWebUserListDetail for the specified
	HQ's connection list.
**/
CREATE PROCEDURE dbo.usp_ResetBBOSUserListConnectionList
	@HQID int,
    @WebUserID int = null
AS
	DECLARE @UserListID int
	DECLARE @Count int, @Index int
	DECLARE @NewCompanyID int

	SELECT @UserListID = prwucl_WebUserListID
	  FROM PRWebUserList
	 WHERE prwucl_HQID = @HQID
	   AND prwucl_TypeCode = 'CL';


	IF @UserListID IS NULL BEGIN
			RAISERROR ('No PRWebUserList w/type = Connection List found.', 16, 1);
			RETURN 1
	END


	IF @WebUserID IS NULL BEGIN
		SET @WebUserID = -1
	END

	DECLARE @CLCompanies table (
		CompanyID int
	)

	DECLARE @UserListCompanies table (
		CompanyID int
	)

	DECLARE @NewCompanies table (
		Ndx int identity(1,1) primary key,
		CompanyID int
	)

	-- Go get all of our Connection List companies
	INSERT INTO @CLCompanies
		 SELECT DISTINCT prcr_RightCompanyID
		   FROM PRCompanyRelationship
		  WHERE prcr_Type IN ('09', '10', '11', '12', '13', '14', '15', '16')
			AND prcr_Active = 'Y'
			AND prcr_LeftCompanyID = @HQID;

	-- Go get all of our WebUserList Detail companies for 
	-- the connection list
	INSERT INTO @UserListCompanies
		 SELECT prwuld_AssociatedID
		   FROM PRWebUserListDetail
		  WHERE prwuld_WebUserListID = @UserListID;

	-- Remove all companies from the user list
	-- that are not in our connection list
	DELETE FROM PRWebUserListDetail
		  WHERE prwuld_WebUserListID = @UserListID 
			AND prwuld_AssociatedID NOT IN (SELECT CompanyID
											  FROM @CLCompanies);

	-- Determine what companies are in the Connection list but
	-- not in the WebUserlist
	INSERT INTO @NewCompanies (CompanyID)
		 SELECT CompanyID
		   FROM @CLCompanies
		  WHERE CompanyID NOT IN (SELECT CompanyID
									FROM @UserListCompanies);



	-- Add add all companies that are in our connection
	-- list but not in our user list
	SELECT @Count = COUNT(1) FROM @NewCompanies;
	SET @Index = 0

	WHILE @Index < @Count BEGIN
		SET @Index = @Index + 1

		SELECT @NewCompanyID = CompanyID
		  FROM @NewCompanies
		 WHERE Ndx = @Index;

		--Declare @DetailID int
		--exec usp_getNextId 'PRWebUserListDetail', @DetailID output

		INSERT INTO PRWebUserListDetail 
			(prwuld_CreatedBy,
			 prwuld_CreatedDate,
			 prwuld_UpdatedBy,
			 prwuld_UpdatedDate,
			 prwuld_TimeStamp,
			 prwuld_WebUserListID,
			 prwuld_AssociatedID,
			 prwuld_AssociatedType)
		VALUES (@WebUserID, 
				GETDATE(), 
				@WebUserID, 
				GETDATE(), 
				GETDATE(),
				@UserListID,
				@NewCompanyID,
				'C');
	END
GO

/**
Ensures the new membership user has the default records
setup
**/
CREATE OR ALTER PROCEDURE dbo.usp_ProcessNewMembeshipUser
	@WebUserID int
AS

	DECLARE @HQID int, @CompanyID int, @ID int, @PersonLinkID int, @AccessLevel int
	DECLARE @Culture varchar(40), @Name varchar(50), @Description varchar(50), @IndustryType varchar(40)
	DECLARE @DoesAUSExist bit, @DoesCLExist bit, @DoesSavedSearchesExist bit

	-- Go get our user's information
	SELECT @CompanyID = prwu_BBID,
		   @HQID  = prwu_HQID,
		   @Culture = prwu_Culture,
		   @PersonLinkID = prwu_PersonLinkID,
		   @AccessLevel = prwu_AccessLevel
	  FROM PRWebUser WITH (NOLOCK)
	 WHERE prwu_WebUserID = @WebUserID;

	IF @CompanyID IS NULL BEGIN
		RAISERROR('Unable to find PRWebUser record.',16,-1)      
		RETURN
	END

	SELECT @IndustryType = comp_PRIndustryType
      FROM Company WITH (NOLOCK)
     WHERE comp_CompanyID = @HQID; 

	-- Supply companies do not have 
	-- Connection Lists available 
	IF @IndustryType = 'S' BEGIN
		SET @DoesCLExist = 1
	END ELSE BEGIN
		-- Does a Connection List exist for this HQ?
		SELECT @DoesCLExist = 1
		  FROM PRWebUserList
		 WHERE prwucl_HQID = @HQID
		   AND prwucl_TypeCode = 'CL'
		   AND prwucl_IsPrivate IS NULL;
	END

	-- If not, then create one
	IF @DoesCLExist IS NULL BEGIN
		--EXEC usp_GetNextID 'PRWebUserList', @ID OUTPUT

		INSERT INTO PRWebUserList (
			prwucl_CreatedBy,
			prwucl_CreatedDate,
			prwucl_UpdatedBy,
			prwucl_UpdatedDate,
			prwucl_TimeStamp,
			prwucl_WebUserID,
			prwucl_CompanyID,
			prwucl_HQID,
			prwucl_TypeCode,
			prwucl_Name,
			prwucl_Description,
			prwucl_IsPrivate)
		VALUES (
			@WebUserID,
			GETDATE(),
			@WebUserID,
			GETDATE(),
			GETDATE(),
			@WebUserID,
			@CompanyID,
			@HQID,
			'CL',
			dbo.ufn_GetCustomCaptionValue('PRWebUserListName', 'Name_CL', @Culture),
			dbo.ufn_GetCustomCaptionValue('PRWebUserListName', 'Description_CL', @Culture),
			NULL
		);

		EXEC usp_ResetBBOSUserListConnectionList @HQID, @WebUserID;
	END


	-- Does an Alerts List exist for this User?
	SELECT @DoesAUSExist = 1
	  FROM PRWebUserList
	 WHERE prwucl_WebUserID = @WebUserID
	   AND prwucl_TypeCode = 'AUS'
	   AND prwucl_IsPrivate = 'Y';

	-- If not, then create one
	IF @DoesAUSExist IS NULL BEGIN

		INSERT INTO PRWebUserList (
			prwucl_CreatedBy,
			prwucl_CreatedDate,
			prwucl_UpdatedBy,
			prwucl_UpdatedDate,
			prwucl_TimeStamp,
			prwucl_WebUserID,
			prwucl_CompanyID,
			prwucl_HQID,
			prwucl_TypeCode,
			prwucl_Name,
			prwucl_Description,
			prwucl_IsPrivate)
		VALUES (
			@WebUserID,
			GETDATE(),
			@WebUserID,
			GETDATE(),
			GETDATE(),
			@WebUserID,
			@CompanyID,
			@HQID,
			'AUS',
			dbo.ufn_GetCustomCaptionValue('PRWebUserListName', 'Name_AUS', @Culture),
			dbo.ufn_GetCustomCaptionValue('PRWebUserListName', 'Description_AUS', @Culture),
			'Y'
		);

		UPDATE Person_Link
		   SET peli_PRAUSReceiveMethod = '2',  -- Email
			   peli_PRAUSChangePreference = '2',  -- All Changes
			   peli_UpdatedBy = @WebUserID,
			   peli_UpdatedDate = GETDATE(),
			   peli_TimeStamp = GETDATE()
		 WHERE peli_PersonLinkID = @PersonLinkID
	END


	UPDATE Person_Link
		SET peli_PRCSReceiveMethod = '2',  -- Email
		    peli_PRCSSortOption = 'L',
			peli_UpdatedBy = @WebUserID,
			peli_UpdatedDate = GETDATE(),
			peli_TimeStamp = GETDATE()
	  WHERE peli_PersonLinkID = @PersonLinkID;

	-- Ensure we have the correct email address 
	-- for this user.
	UPDATE PRWebUser
	   SET prwu_IsNewUser = null,
	       prwu_Email = Emai_EmailAddress 
	  FROM vPRPersonEmail 
	       INNER JOIN Person_Link ON ELink_RecordID = PeLi_PersonId AND emai_CompanyID= PeLi_CompanyID
	 WHERE prwu_WebUserID = @WebUserID
	   AND prwu_PersonLinkID = PeLi_PersonLinkId

    --Defect 4407 - widget defaults for new users
    DELETE FROM PRWebUserWidget WHERE prwuw_WebUserID = @WebUserID AND prwuw_WidgetCode IN ('CompaniesRecentlyViewed','ListingsRecentlyPublished','IndustryMetricsSnapshot','AlertCompaniesRecentKeyChanges')
    INSERT INTO PRWebUserWidget (prwuw_CreatedDate, prwuw_UpdatedBy, prwuw_UpdatedDate, prwuw_WebUserID, prwuw_WidgetCode, prwuw_Sequence)
	    VALUES (GETDATE(), @WebUserID, GETDATE(), @WebUserID, 'CompaniesRecentlyViewed', 1)
    INSERT INTO PRWebUserWidget (prwuw_CreatedDate, prwuw_UpdatedBy, prwuw_UpdatedDate, prwuw_WebUserID, prwuw_WidgetCode, prwuw_Sequence)
	    VALUES (GETDATE(), @WebUserID, GETDATE(), @WebUserID, 'ListingsRecentlyPublished', 2)
    INSERT INTO PRWebUserWidget (prwuw_CreatedDate, prwuw_UpdatedBy, prwuw_UpdatedDate, prwuw_WebUserID, prwuw_WidgetCode, prwuw_Sequence)
	    VALUES (GETDATE(), @WebUserID, GETDATE(), @WebUserID, 'IndustryMetricsSnapshot', 3)
    INSERT INTO PRWebUserWidget (prwuw_CreatedDate, prwuw_UpdatedBy, prwuw_UpdatedDate, prwuw_WebUserID, prwuw_WidgetCode, prwuw_Sequence)
	    VALUES (GETDATE(), @WebUserID, GETDATE(), @WebUserID, 'AlertCompaniesRecentKeyChanges', 4)
GO

If Exists (Select name from sysobjects where name = 'usp_ResetEBBConversion' and type='P') Drop Procedure dbo.usp_ResetEBBConversion
Go

/**
	Resets the EBB conversion by deleting all records created
	as a result of the conversion.
**/
CREATE PROCEDURE dbo.usp_ResetEBBConversion
	@WebUserID int
AS

	-- Delete the PRWebNote records that were created as
	-- from the user's uploaded EBB Paradox database.
	DELETE FROM PRWebUserNote
	 WHERE prwun_CreatedBy = @WebUserID
	   AND prwun_WebUserNoteID IN (SELECT prebbcd_AssociatedID 
									 FROM PREBBConversionDetail
									WHERE prebbcd_CreatedBy = @WebUserID
									  AND prebbcd_AssociatedType = 'N');


	-- Delete the PRWebUserListDetail records that were created as
	-- from the user's uploaded EBB Paradox database.
	DELETE FROM PRWebUserListDetail
	 WHERE prwuld_WebUserListID IN  (SELECT prebbcd_AssociatedID 
									 FROM PREBBConversionDetail
									WHERE prebbcd_CreatedBy = @WebUserID
									  AND prebbcd_AssociatedType = 'UL');

	-- Delete the PRWebUserList records that were created as
	-- from the user's uploaded EBB Paradox database.
	DELETE FROM PRWebUserList
	 WHERE prwucl_CreatedBy = @WebUserID
	   AND prwucl_WebUserListID IN  (SELECT prebbcd_AssociatedID 
									 FROM PREBBConversionDetail
									WHERE prebbcd_CreatedBy = @WebUserID
									  AND prebbcd_AssociatedType = 'UL');

	-- Delete the PREBBConversionDetail records that were created as
	-- from the user's uploaded EBB Paradox database.
	DELETE PREBBConversionDetail
	 WHERE prebbcd_CreatedBy = @WebUserID;

	-- Delete the PREBBConversion records that were created as
	-- from the user's uploaded EBB Paradox database.
	DELETE PREBBConversion
	 WHERE prebbc_CreatedBy = @WebUserID;
GO



/* 
 *  NEW STORED PROC
 */
If Exists (Select name from sysobjects where name = 'usp_UpdateBBOSOwnership' and type='P') 
	Drop Procedure dbo.usp_UpdateBBOSOwnership
Go

/**
	Changes "Ownership" from one user to another
**/
CREATE PROCEDURE dbo.usp_UpdateBBOSOwnership
	@OldWebUserID int,
    @NewWebUserID int
AS

	DECLARE @HQID1 int, @HQID2 int
	DECLARE @OldCompanyID int, @NewCompanyID int
	
	SELECT @HQID1 = prwu_HQID,
           @OldCompanyID = prwu_BBID
      FROM PRWebUser
     WHERE prwu_WebUserID = @OldWebUserID;

	SELECT @HQID2 = prwu_HQID,
           @NewCompanyID = prwu_BBID
      FROM PRWebUser
     WHERE prwu_WebUserID = @NewWebUserID;

	IF @HQID1 <> @HQID2 BEGIN
		RAISERROR('The old user and new user are not part of the same headquarters.',16,-1)      
		RETURN
	END
	

	UPDATE PRWebUserContact
       SET prwuc_WebUserID = @NewWebUserID,
           prwuc_CompanyID = @NewCompanyID,
		   prwuc_UpdatedBy = @NewWebUserID,
		   prwuc_UpdatedDate = GETDATE(),
	       prwuc_Timestamp = GETDATE()
     WHERE prwuc_WebUserID = @OldWebUserID;

	UPDATE PRWebUserCustomData
       SET prwucd_WebUserID = @NewWebUserID,
           prwucd_CompanyID = @NewCompanyID,
		   prwucd_UpdatedBy = @NewWebUserID,
		   prwucd_UpdatedDate = GETDATE(),
	       prwucd_Timestamp = GETDATE()
     WHERE prwucd_WebUserID = @OldWebUserID;

	UPDATE PRWebUserList
       SET prwucl_WebUserID = @NewWebUserID,
           prwucl_CompanyID = @NewCompanyID,
		   prwucl_UpdatedBy = @NewWebUserID,
		   prwucl_UpdatedDate = GETDATE(),
	       prwucl_Timestamp = GETDATE()
     WHERE prwucl_WebUserID = @OldWebUserID;

	UPDATE PRWebUserNote
       SET prwun_WebUserID = @NewWebUserID,
           prwun_CompanyID = @NewCompanyID,
		   prwun_UpdatedBy = @NewWebUserID,
		   prwun_UpdatedDate = GETDATE(),
	       prwun_Timestamp = GETDATE()
     WHERE prwun_WebUserID = @OldWebUserID;

	UPDATE PRWebUserSearchCriteria
       SET prsc_WebUserID = @NewWebUserID,
           prsc_CompanyID = @NewCompanyID,
		   prsc_UpdatedBy = @NewWebUserID,
		   prsc_UpdatedDate = GETDATE(),
	       prsc_Timestamp = GETDATE()
     WHERE prsc_WebUserID = @OldWebUserID;
GO



/* 
 *  NEW STORED PROC
 */
If Exists (Select name from sysobjects where name = 'usp_GeneratePassword' and type='P') 
	Drop Procedure dbo.usp_GeneratePassword
Go

/**
	Uses the PRPasswordGenerator table to generate a random
	password
**/
CREATE PROCEDURE [dbo].[usp_GeneratePassword]
	@Password varchar(100) OUTPUT,
	@UseSpecialChars bit = 0
AS
BEGIN 

	DECLARE @MaxIndex int, @Index int
	DECLARE @Part1 varchar(50), @Part2 varchar(50)

	-- Determine how many words we have
	SELECT @MaxIndex = MAX(NDX) FROM PRPasswordGenerator WHERE Word IS NOT NULL;

	-- Randonly select the first word
	SELECT @Index =  CONVERT(int, (@MaxIndex+1)*RAND());
	IF @Index = 0 SET @Index = 1
	SELECT @Part1 = Word FROM PRPasswordGenerator WHERE Ndx = @Index

	-- Randonly select the last word
	SELECT @Index =  CONVERT(int, (@MaxIndex+1)*RAND());
	IF @Index = 0 SET @Index = 1
	SELECT @Part2 = Word FROM PRPasswordGenerator WHERE Ndx = @Index

	-- If we're using special character
	IF (@UseSpecialChars = 1) BEGIN

		DECLARE @CharIndex int, @MaxIterations int, @Found int, @Count int
		DECLARE @TranslateFrom varchar(5), @TranslateTo varchar(5)

		SET @CharIndex = 0
		SET @MaxIterations = 20
		SET @Found = 0
		SET @Count = 0

		-- Determine how many replacements we can choose from.
		SELECT @MaxIndex = MAX(NDX) FROM PRPasswordGenerator WHERE TranslateFrom IS NOT NULL;

		-- Iterate through until we either find a replacement in
		-- our first randomly chosen word or until we reach our
		-- max count.
		WHILE (@Found = 0) AND (@Count < @MaxIterations) BEGIN
			SELECT @Index =  CONVERT(int, (@MaxIndex+1)*RAND());
			IF @Index = 0 SET @Index = 1

			-- Go get the From and To
			SELECT @TranslateFrom = TranslateFrom,
				   @TranslateTo = TranslateTo
			  FROM PRPasswordGenerator
			 WHERE Ndx = @Index;

			-- If the first word has the From chararacter, 
			-- go the replacement
			IF (CHARINDEX(@TranslateFrom, @Part1) > 0) BEGIN
				SET @Part1 = REPLACE(@Part1, @TranslateFrom, @TranslateTo)
				SET @Found = 1
			END

			SET @Count = @Count + 1
		END
	END

	-- Inject a number between the words.
	SET @Password = @Part1 + CONVERT(varchar(5), CONVERT(int, (99+1)*RAND())) + @Part2
END
Go


If Exists (Select name from sysobjects where name = 'usp_ConvertPersonToBBOS' and type='P') Drop Procedure dbo.usp_ConvertPersonToBBOS
Go

/**
Ensures the new membership user has the default records
setup
**/
CREATE PROCEDURE dbo.usp_ConvertPersonToBBOS
	@PersonID int,
    @CompanyID int
AS
BEGIN

	DECLARE @Email varchar(100), @FirstName varchar(100), @LastName varchar(100)
	DECLARE @Password varchar(100), @EncryptedPassword varchar(100)
	DECLARE @HQID int, @PersonLinkID int, @WebUserID int, @AccessLevel int

	SELECT @Email = RTRIM(emai_EmailAddress),
		   @Password = peli_WebPassword,
		   @FirstName = RTrim(pers_FirstName), 
		   @LastName = RTRIM(pers_LastName),
		   @HQID = comp_PRHQID,
		   @PersonLinkID = peli_PersonLinkID
	  FROM Person_Link
		   INNER JOIN Person ON peli_PersonID = pers_PersonID
		   INNER JOIN Company ON peli_CompanyID = comp_CompanyID
		   LEFT OUTER JOIN vPRPersonEmail ON peli_PersonID = ELink_RecordID AND peli_CompanyID = emai_CompanyID AND ELink_Type='E'
	 WHERE peli_CompanyID = @CompanyID
	   AND peli_PersonID = @PersonID;


	IF (@FirstName IS NULL) BEGIN
		PRINT 'NULL FirstName: ' + CONVERT(varchar(100), @PersonID) + ' ' + CONVERT(varchar(100), @CompanyID)
	END

	SELECT @AccessLevel = MAX(prod_PRWebAccessLevel)
      FROM PRService
           INNER JOIN NewProduct WITH (NOLOCK) ON prse_ServiceCode = prod_Code
	WHERE prse_Primary = 'Y'
      AND prse_HQID = @HQID;

	IF @Email IS NULL BEGIN
		Print 'No Email Address Found'
	END

	IF @Password IS NULL BEGIN
		Print 'Generating Password'
		EXEC usp_GeneratePassword @Password OUTPUT
	END

	SET @EncryptedPassword = dbo.ufnclr_EncryptText(@Password)


	EXEC usp_GetNextID 'PRWebUser', @WebUserID OUTPUT
	INSERT INTO PRWebUser
	(prwu_WebUserID,prwu_Email,prwu_Password,prwu_FirstName,prwu_LastName,prwu_PersonLinkID,prwu_BBID,prwu_HQID,prwu_Culture,prwu_UICulture,prwu_AccessLevel,prwu_Timezone,prwu_CreatedBy,prwu_CreatedDate,prwu_UpdatedBy,prwu_UpdatedDate,prwu_TimeStamp)
	VALUES (@WebUserID,@Email,@EncryptedPassword,@FirstName,@LastName,@PersonLinkID,@CompanyID,@HQID,'en-us','en-us',@AccessLevel,'Eastern Standard Time',-103,GETDATE(),-103,GETDATE(),GETDATE());

	Print 'Processing New Membership'
	EXEC usp_ProcessNewMembeshipUser @WebUserID
END
Go



If Exists (Select name from sysobjects where name = 'usp_ConvertAUS' and type='P') Drop Procedure dbo.usp_ConvertAUS
Go

CREATE PROCEDURE [dbo].[usp_ConvertAUS]
	@CreatedByID int = -125
AS
BEGIN 

	Declare @Start datetime
	SET @Start = GETDATE()
	PRINT 'usp_ConvertAUS: Start Time: ' +  CONVERT(varchar(25), @Start)

	DECLARE @WebUsers table (
		ndx int identity(1,1) primary key,
		WebUserID int, 
		PersonID int,
		CompanyID int
	)

	CREATE TABLE #AUSCompanies(
		ndx int identity(1,1) primary key,
		CompanyID int
	)

	DECLARE @Results table (
		CompanyID int,
		PersonID int,
		WebUserID int,
		AUSCount int
	)

	DECLARE @Count int, @Index int, @WatchdogListID int
	DECLARE @WebUserID int, @PersonID int, @CompanyID int
	DECLARE @AUSCount int, @AUSIndex int, @MonitoredCompanyID int, @DetailID int

	-- Go get those PRWebUser records that also have
	-- Alerts records
	INSERT INTO @WebUsers (WebUserID, PersonID, CompanyID)
	SELECT DISTINCT prwu_WebUserID, peli_PersonID, peli_CompanyID
	  FROM PRWebUser  
		   INNER JOIN Person_Link ON prwu_PersonLinkID = peli_PersonLinkID
		   INNER JOIN PRAUS ON peli_PersonID = prau_PersonID AND peli_CompanyID = prau_CompanyID;
	  
	 

	SELECT @Count = COUNT(1) FROM @WebUsers;
	SET @Index = 0

	WHILE (@Index < @Count) BEGIN
		SET @Index = @Index + 1

		-- Get the PIKS Keys
		SELECT @WebUserID = WebUserID,
			   @PersonID = PersonID,
			   @CompanyID = CompanyID
		  FROM @WebUsers
		 WHERE ndx = @Index;

		-- Get the Alerts Watchdoglist ID
		SELECT @WatchdogListID = prwucl_WebUserListID
		  FROM PRWebUserList
		 WHERE prwucl_TypeCode = 'AUS'
		   AND prwucl_WebUserID = @WebUserID;
		
		-- Put the current Alerts companies
		-- in a temp table.
		INSERT INTO #AUSCompanies
		SELECT prau_MonitoredCompanyID
		  FROM PRAUS
		  WHERE prau_PersonID = @PersonID
			AND prau_CompanyID = @CompanyID;

		-- Remove any existing entries
		DELETE FROM PRWebUserListDetail WHERE prwuld_WebUserListID = @WatchdogListID;

		SELECT @AUSCount = COUNT(1) FROM #AUSCompanies;
		SET @AUSIndex = 0
		WHILE (@AUSIndex < @AUSCount) BEGIN
			SET @AUSIndex = @AUSIndex + 1

			SELECT @MonitoredCompanyID = CompanyID
			  FROM #AUSCompanies
			 WHERE ndx = @AUSIndex;

	   
			--EXEC usp_GetNextId 'PRWebUserListDetail', @DetailID output

			INSERT INTO PRWebUserListDetail(prwuld_CreatedBy,
											prwuld_CreatedDate,
											prwuld_UpdatedBy,
											prwuld_UpdatedDate,
											prwuld_TimeStamp,
											prwuld_WebUserListID,
											prwuld_AssociatedID,
											prwuld_AssociatedType)
			VALUES (@CreatedByID,
					GETDATE(),
					@CreatedByID,
					GETDATE(),
					GETDATE(),
					@WatchdogListID,
					@MonitoredCompanyID,
					'C');
		END

		-- Save off what we just did
		INSERT INTO @Results VALUES (@CompanyID, @PersonID, @WebUserID, @AUSCount);

		-- Reset our Alerts temp table
		DELETE FROM #AUSCompanies;
		DBCC CHECKIDENT ('#AUSCompanies', RESEED, 0)
	END

	DROP TABLE #AUSCompanies

	-- Dump a record of what we did here today...
	SELECT CompanyID, comp_Name, PersonID, dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_MiddleName, NULL, pers_Suffix) As PersonName, WebUserID, AUSCount
	  FROM @Results
		   INNER JOIN Company on CompanyID = comp_CompanyID
		   INNER JOIN Person on PersonID = pers_PersonID
  ORDER BY CompanyID;

	PRINT 'usp_ConvertAUS: End Time: ' +  CONVERT(varchar(25), GETDATE())
	PRINT 'usp_ConvertAUS Execution time (seconds): ' +  CONVERT(varchar(10), DATEDIFF(second, @Start, GETDATE()))

END
Go


If Exists (Select name from sysobjects where name = 'usp_SndBBOSPassword' and type='P') Drop Procedure dbo.usp_SndBBOSPassword
Go

CREATE PROCEDURE [dbo].[usp_SndBBOSPassword]
	@WebUserID int,
	@CreateCommunication bit = 0
AS
BEGIN 

	-- Override the 'Create Communication' parameter
	EXEC usp_SendBBOSPassword @WebUserID, -125, 0
END
Go

If Exists (Select name from sysobjects where name = 'usp_SendBBOSPassword' and type='P') Drop Procedure dbo.usp_SendBBOSPassword
Go

CREATE PROCEDURE [dbo].[usp_SendBBOSPassword]
	@WebUserID int,
	@CreatedByID int = -125,
	@CreateCommunication bit = 0
AS
BEGIN 

	DECLARE @CompanyID int, @PersonID int
	DECLARE @Email varchar(255), @Password varchar(50), @Msg varchar(max), @AccessLevel varchar(40), @PreviousAccessLevel varchar(40)
    DECLARE @Subject varchar(500), @CaptFamily varchar(50), @TrialExpDate datetime, @ServiceCode varchar(40)
	DECLARE @Culture varchar(40)

	SELECT @Email = prwu_Email,
		   @CompanyID = prwu_BBID,
		   @PersonID = peli_PersonID,
		   @Password = prwu_Password,
           @TrialExpDate = prwu_TrialExpirationDate,
           @AccessLevel = prwu_AccessLevel,
           @PreviousAccessLevel = prwu_PreviousAccessLevel,
		   @ServiceCode = prwu_ServiceCode,
		   @Culture = prwu_Culture
	  FROM PRWebUser WITH (NOLOCK)
		   LEFT OUTER JOIN Person_Link WITH (NOLOCK) ON prwu_PersonLinkID = peli_PersonLinkID
	 WHERE prwu_WebUserID = @WebUserID;

	IF (@Email IS NOT NULL) BEGIN

		SET @CaptFamily = 'BBOSWelcomeEmail'
		IF ((@TrialExpDate IS NOT NULL) AND 
            (@TrialExpDate > GETDATE())) BEGIN

			SET @CaptFamily = 'BBOSWelcomeEmailTrialMember'
			IF (@PreviousAccessLevel = '10') OR (@PreviousAccessLevel = '5') BEGIN
				SET @CaptFamily = 'BBOSWelcomeEmailTrialNonMember'
			END
		END

		IF (@ServiceCode = 'ITALIC') BEGIN
			SET @CaptFamily = 'BBOSWelcomeEmailITA'
		END

		SET @Msg = dbo.ufn_GetCustomCaptionValue(@CaptFamily, 'Body', @Culture)
		SET @Msg = REPLACE(@Msg,'{0}', dbo.ufn_GetCustomCaptionValue('BBOS', 'URL', 'en-us'))
		SET @Msg = REPLACE(@Msg,'{1}', @Email)
		SET @Msg = REPLACE(@Msg,'{2}', dbo.ufnclr_DecryptText(@Password))
		SET @Msg = REPLACE(@Msg,'{3}', dbo.ufn_ConcatURL(dbo.ufn_GetCustomCaptionValue('BBOS', 'URL', 'en-us'), dbo.ufn_GetCustomCaptionValue('ReferenceURL', 'Training', 'en-us')))
        SET @Msg = REPLACE(@Msg,'{4}', dbo.ufn_ConcatURL(dbo.ufn_GetCustomCaptionValue('BBOS', 'URL', 'en-us'), dbo.ufn_GetCustomCaptionValue('ReferenceURL', 'MembershipComparison', 'en-us')))

		SET @Subject = dbo.ufn_GetCustomCaptionValue(@CaptFamily, 'Subject', @Culture)
		SET @Msg = dbo.ufn_GetFormattedEmail2(@CompanyID, @PersonID, @WebUserID, @Subject, @Msg, NULL, @Culture)

		EXEC usp_CreateEmail
				@CreatorUserID = @CreatedByID,
				@To = @Email,
				@Subject = @Subject,
				@Content = @Msg,
				@Action = 'EmailOut',
				@DoNotRecordCommunication = 1,
				@Content_Format = 'HTML',
                @RelatedCompanyID = @CompanyID,
                @RelatedPersonID = @PersonID,
                @Source='Send BBOS Password'
				

		-- If this is a registered user, don't create the
        -- communication records
		IF (Cast(@AccessLevel As Int) <= 10) BEGIN
			SET @CreateCommunication = 0
		END

		-- By default we do not create a communication record;
		-- If the caller requests it, we will.
		IF (@CreateCommunication = 1)
		BEGIN
			SET @Msg = dbo.ufn_GetCustomCaptionValue(@CaptFamily, 'Communication', 'en-us')
			SET @Msg = REPLACE(@Msg,'{0}', @Email)
			exec dbo.usp_CreateTask
				@CreatorUserId = @CreatedByID,
				@TaskNotes = @Msg,
				@RelatedCompanyId = @CompanyId,
				@RelatedPersonId = @PersonId,
				@Status = 'Pending'
		END
	END

END
Go

If Exists (Select name from sysobjects where name = 'usp_SendBBOSPasswordChangeLink' and type='P') Drop Procedure dbo.usp_SendBBOSPasswordChangeLink
Go

CREATE PROCEDURE [dbo].[usp_SendBBOSPasswordChangeLink]
	@WebUserID int,
	@CreatedByID int = -126,
	@CreateCommunication bit = 0,
	@ExpirationHours int = 24
AS
BEGIN 
	DECLARE @CompanyID int, @PersonID int
	DECLARE @Email varchar(255), @Msg varchar(max), @AccessLevel varchar(40) 
    DECLARE @Subject varchar(500), @CaptFamily varchar(50)
	DECLARE @Culture varchar(40)
	DECLARE @Guid varchar(16) = SUBSTRING(CONVERT(varchar(255), NEWID()), 0, 8) + SUBSTRING(CONVERT(varchar(255), NEWID()), 0, 8)
	DECLARE @szPasswordChangeEmailSubject varchar(1000)
	DECLARE @szPasswordChangeEmailBody  varchar(1000)

	SELECT @Email = prwu_Email,
		   @CompanyID = prwu_BBID,
		   @PersonID = peli_PersonID,
           @AccessLevel = prwu_AccessLevel,
		   @Culture = prwu_Culture
	  FROM PRWebUser WITH (NOLOCK)
		   LEFT OUTER JOIN Person_Link WITH (NOLOCK) ON prwu_PersonLinkID = peli_PersonLinkID
	 WHERE prwu_WebUserID = @WebUserID;

	IF @Culture = 'es-mx' BEGIN
		SET @szPasswordChangeEmailSubject = 'Solicitud de cambio de contraseña'
		SET @szPasswordChangeEmailBody = '<br/><br/>Para cambiar su contraseña a Blue Book Online Services (BBOS), haga clic <a href=''{0}''>aquí</a>. Este es un enlace de uso único que caducará en 24 horas.<br/> <br/>
Si necesita asistencia adicional, comuníquese con nuestro Grupo de Atención al Cliente al 630-668-3500 o <a href=''mailto:customerservice@bluebookservices.com''>customerservice@bluebookservices.com</a>. <br/>
<br/><br/>

Atentamente, <br/>
Blue Book Services, Inc. <br/>
Ph: 630-668-3500 <br/>
845 E. Geneva Rd., Carol Stream, IL 60188<br/>'
	END
	ELSE
	BEGIN
		SET @szPasswordChangeEmailSubject = 'Password Change Request'
		SET @szPasswordChangeEmailBody = '<br/><br/>To change your password to Blue Book Online Services (BBOS), please click <a href=''{0}''>here</a>.  This is a one-time use link that will expire in {1} hours. <br/><br/>
If you need additional assistance, please contact our Customer Service Group at 630-668-3500 or <a href=''mailto:customerservice@bluebookservices.com''>customerservice@bluebookservices.com</a>. <br/><br/>

Sincerely, <br/>
Blue Book Services, Inc. <br/>
Ph: 630-668-3500 <br/>
845 E. Geneva Rd., Carol Stream, IL 60188 <br/>'
	END

	IF (@Email IS NOT NULL) BEGIN
		SET @Msg = @szPasswordChangeEmailBody
		SET @Msg = REPLACE(@Msg,'{0}', dbo.ufn_GetCustomCaptionValue('BBOS', 'URL', 'en-us') + 'PasswordChange.aspx?qk=' + @Guid)
		SET @Msg = REPLACE(@Msg,'{1}', @ExpirationHours)
		SET @Subject = @szPasswordChangeEmailSubject
		SET @Msg = dbo.ufn_GetFormattedEmail2(@CompanyID, @PersonID, @WebUserID, @Subject, @Msg, NULL, @Culture)

		UPDATE PRWebUser SET prwu_passwordchangeguid = @GUID, 
			prwu_PasswordChangeGuidExpirationDate = DATEADD(HOUR, @ExpirationHours, getdate())
		WHERE prwu_WebUserID = @WebUserID
			   
		EXEC usp_CreateEmail
				@CreatorUserID = @CreatedByID,
				@To = @Email,
				@Subject = @Subject,
				@Content = @Msg,
				@Action = 'EmailOut',
				@DoNotRecordCommunication = 1,
				@Content_Format = 'HTML',
                @RelatedCompanyID = @CompanyID,
                @RelatedPersonID = @PersonID,
                @Source='Send BBOS Password Change Link'

		-- If this is a registered user, don't create the
        -- communication records
		IF (Cast(@AccessLevel As Int) <= 10) BEGIN
			SET @CreateCommunication = 0
		END

		-- By default we do not create a communication record;
		-- If the caller requests it, we will.
		IF (@CreateCommunication = 1)
		BEGIN
			SET @Msg = dbo.ufn_GetCustomCaptionValue(@CaptFamily, 'Communication', 'en-us')
			SET @Msg = REPLACE(@Msg,'{0}', @Email)
			exec dbo.usp_CreateTask
				@CreatorUserId = @CreatedByID,
				@TaskNotes = @Msg,
				@RelatedCompanyId = @CompanyId,
				@RelatedPersonId = @PersonId,
				@Status = 'Pending'
		END
	END
END
Go


If Exists (Select name from sysobjects where name = 'usp_CreateWebUserFromPersonLink' and type='P') 
	Drop Procedure dbo.usp_CreateWebUserFromPersonLink
Go

CREATE PROCEDURE dbo.usp_CreateWebUserFromPersonLink
	@PersonLinkID int,
	@CreatedUserID int = -1,
	@ServiceCode varchar(40),
	@MaxAccessLevel int = 0
AS
BEGIN 
	DECLARE @WebUserID int
	DECLARE @CompanyID int
	DECLARE @Email varchar(255), @Subject varchar(255), @Body varchar(255)
	DECLARE @Password varchar(100), @EncryptedPassword varchar(100)
	DECLARE @FirstName varchar(100), @LastName varchar(100), @IndustryType varchar(40), @Culture varchar(40), @Timezone varchar(100)
	DECLARE @HQID int

	DECLARE @OldAccessLevel varchar(40), @TrialExpiration datetime

	SELECT @HQID = dbo.ufn_BRGetHQID(@CompanyId)

	EXEC usp_GetNextId 'PRWebUser', @WebUserID output

	SELECT @Email = RTRIM(emai_EmailAddress),
		   @Password = peli_WebPassword,
		   @FirstName = RTrim(pers_FirstName), 
		   @LastName = RTRIM(pers_LastName),
		   @CompanyID = peli_CompanyID,	
		   @HQID = dbo.ufn_BRGetHQID(peli_CompanyID),
           @IndustryType = comp_PRIndustryType
	  FROM Person_Link WITH (NOLOCK)
		   INNER JOIN Person WITH (NOLOCK) on peli_PersonID = pers_PersonID
           INNER JOIN Company WITH (NOLOCK) ON peli_CompanyID = comp_CompanyID
		   LEFT OUTER JOIN vPersonEmail ON peli_PersonID = ELink_RecordID AND peli_CompanyID = emai_CompanyID AND ELink_Type='E'
	 WHERE peli_PersonLinkID = @PersonLinkID;

	-- IF we're creating this for a trial license, then set the exipriation date
    -- and make sure the user reverts to a Registered User level
	IF EXISTS (SELECT 'Y' As IsTrial FROM NewProduct WITH (NOLOCK) WHERE prod_productfamilyid=14 AND prod_Code = @ServiceCode) BEGIN

		IF (@IndustryType = 'L') BEGIN
			SET @OldAccessLevel = '5'
        END ELSE BEGIN
			SET @OldAccessLevel = '10'
        END
			
		SET @TrialExpiration = CAST(FLOOR( CAST( DATEADD(day, 31, GETDATE()) AS FLOAT ))AS DATETIME)
	END

	IF @Email IS NULL BEGIN
		Print 'No Email Address Found'
	END

	IF @Password IS NULL BEGIN
		Print 'Generating Password'
		EXEC usp_GeneratePassword @Password OUTPUT
	END

	SET @EncryptedPassword = dbo.ufnclr_EncryptText(@Password)

	IF (@ServiceCode IN ('None', 'None2')) BEGIN
		SET @ServiceCode = NULL
	END

	SET @Culture = 'en-us'
	SET @Timezone = 'Eastern Standard Time'
	IF (@ServiceCode = 'ITALIC') BEGIN
		SET @Culture = 'es-mx'
		SET @Timezone = 'Central Standard Time (Mexico)'
	END

	INSERT INTO PRWebUser
	(prwu_WebUserID, prwu_ServiceCode, prwu_Email,prwu_Password,prwu_FirstName,prwu_LastName,prwu_PersonLinkID,prwu_BBID,prwu_HQID,prwu_Culture,prwu_UICulture,prwu_AccessLevel,prwu_PreviousAccessLevel, prwu_TrialExpirationDate,prwu_Timezone,prwu_CreatedBy,prwu_CreatedDate,prwu_UpdatedBy,prwu_UpdatedDate,prwu_TimeStamp)
	VALUES (@WebUserID,@ServiceCode, @Email,@EncryptedPassword,@FirstName,@LastName,@PersonLinkID,@CompanyID,@HQID,@Culture,@Culture,@MaxAccessLevel,@OldAccessLevel,@TrialExpiration,@Timezone,@CreatedUserID,GETDATE(),@CreatedUserID,GETDATE(),GETDATE());

	

	IF (@ServiceCode <> 'ITALIC') BEGIN
		UPDATE Person_Link
		   SET peli_PRReceivesCreditSheetReport = 'Y'
		 WHERE peli_PersonLinkID = @PersonLinkID;
	END 

	Print 'Processing New Membership'
	EXEC usp_ProcessNewMembeshipUser @WebUserID

	IF (@MaxAccessLevel <> 7) BEGIN  -- Exclude the new "Restricted Plus" from getting an email
		EXEC usp_SendBBOSPassword @WebUserID
	END

	RETURN @WebUserID
END
GO

/******************************************************************************
 *   Procedure: usp_MergeWebUserToCRM
 *
 *   Return: None.
 *
 *   Decription:  This procedure merges a BBOS Web User to a Sage CRM User
 *                There are 2 main considerations when doing this: 
 *					1) Is the person being associated to an existing rec or created new, 
 *					2) Is the company being associated to an existing rec  or created new
 *				  The absence of @AssociatedCompanyId or @AssociatedPersonId on the input 
 *                parameters indicates that the @WebUserId should be used to 
 *                gather info for the person/company and create a new record.
 *
 ****************************************************************************/


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_MergeWebUserToCRM]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_MergeWebUserToCRM]
GO

CREATE PROCEDURE dbo.usp_MergeWebUserToCRM
	@WebUserId int,
	@UserId int,
	@AssociatedPersonId int = null,
	@AssociatedCompanyId int = null
AS
BEGIN
    RETURN

	SET NOCOUNT ON

    DECLARE @NewPersonId int , @PersonTrxId int
    DECLARE @NewCompanyId int, @CompanyTrxId int
	-- Fields from PRWebUser
    DECLARE @prwu_Email varchar(255)
    DECLARE @prwu_FirstName varchar(30)
    DECLARE @prwu_LastName varchar(30)
    DECLARE @prwu_CompanyName varchar(104)
    DECLARE @prwu_TitleCode varchar(40)
    DECLARE @prwu_Address1 varchar(40)
    DECLARE @prwu_Address2 varchar(40)
    DECLARE @prwu_City varchar(34)
    DECLARE @prwu_PostalCode varchar(10)
    DECLARE @prwu_PhoneAreaCode varchar(20)
    DECLARE @prwu_PhoneNumber varchar(30)
    DECLARE @prwu_FaxAreaCode varchar(20)
    DECLARE @prwu_FaxNumber varchar(30)
    DECLARE @prwu_WebSite varchar(255)
    DECLARE @prwu_Gender varchar(6)
    DECLARE @prwu_IndustryClassification varchar(15)
    DECLARE @prwu_CompanySize varchar(40)


    DECLARE @Now datetime
    SET @Now = getDate()

	-- Get necessary information from the PRWebUser record
	IF (@AssociatedPersonId is null or @AssociatedCompanyId is null)
	BEGIN
		SELECT 
			@prwu_Email = prwu_Email
			,@prwu_FirstName = prwu_FirstName
			,@prwu_LastName = prwu_LastName
			,@prwu_CompanyName = prwu_CompanyName
			,@prwu_TitleCode = prwu_TitleCode
			,@prwu_Address1 = prwu_Address1
			,@prwu_Address2 = prwu_Address2
			,@prwu_City = prwu_City
			,@prwu_PostalCode = prwu_PostalCode
			,@prwu_PhoneAreaCode = prwu_PhoneAreaCode
			,@prwu_PhoneNumber =  prwu_PhoneNumber
			,@prwu_FaxAreaCode = prwu_FaxAreaCode
			,@prwu_FaxNumber = prwu_FaxNumber
			,@prwu_WebSite = prwu_WebSite
			,@prwu_Gender = prwu_Gender
			,@prwu_IndustryClassification = prwu_IndustryClassification
			,@prwu_CompanySize = prwu_CompanySize
		  FROM PRWebUser
		 WHERE prwu_WebUserId = @WebUserId
		-- Get IDs for the company and person outside of the trx;
		-- if we fail later, we'll concede use of these ids
		IF (@AssociatedPersonId is null )
			exec usp_getNextId 'Person', @NewPersonId output
		IF (@AssociatedCompanyId is null )
			exec usp_getNextId 'Company', @NewCompanyId output
	END

	BEGIN TRY
	    Begin TRANSACTION
		
		-- if we need a person create the record now; we need a PRCO trx, of course
		IF (@AssociatedPersonId is null)
		BEGIN
			exec @PersonTrxId = usp_CreateTransaction 
					@UserId = @UserId,
					@prtx_PersonId = @NewPersonId,
					@prtx_Explanation = 'Transaction created by the Web User to CRM process.'
			-- Create the person record
			Insert into Person (pers_personid, pers_LastName, pers_FirstName, pers_gender,
				pers_CreatedBy, pers_UpdatedBy)
			 Values (@NewPersonId, @prwu_LastName, @prwu_FirstName, @prwu_gender, @UserID, @UserId)
			-- 						
		END

		-- if we need a company create the record now; we need a PRCO trx, of course
		IF (@AssociatedCompanyId is null)
		BEGIN
			exec @CompanyTrxId = usp_CreateTransaction 
					@UserId = @UserId,
					@prtx_CompanyId = @NewCompanyId,
					@prtx_Explanation = 'Transaction created by the Web User to CRM process.'
			-- Create the Company record
			Insert into Company (comp_companyid, comp_Name, comp_PRType, comp_PRIndustryType,
				comp_CreatedBy, comp_UpdatedBy)
			 Values (@NewCompanyId, @prwu_CompanyName, 'H', @prwu_IndustryClassification, @UserID, @UserId)
						
		END
		
    	
		-- update the PRWebUser record with the passed/new Company and Person IDs
		UPDATE PRWebUser
		   SET prwu_updatedDate = @Now, prwu_Timestamp=@Now, prwu_UpdatedBy = @UserID,
			   prwu_PersonLinkID = @AssociatedPersonId, prwu_BBID = @AssociatedCompanyId
		 WHERE prwu_WebUserId = @WebUserId

		-- Be sure to close any open PRCo transactions
        IF (@PersonTrxId IS NOT NULL )
			UPDATE PRTransaction SET prtx_Status = 'C' WHERE prtx_TransactionId = @PersonTrxId
        IF (@CompanyTrxId IS NOT NULL )
			UPDATE PRTransaction SET prtx_Status = 'C' WHERE prtx_TransactionId = @CompanyTrxId

		COMMIT;

	END TRY
	BEGIN CATCH
		IF (xact_state() <> 0 )
			ROLLBACK
		exec usp_RethrowError

	END CATCH;


    SET NOCOUNT OFF

END
GO



If Exists (Select name from sysobjects where name = 'usp_CreateWebServiceLicenseKey' and type='P') 
	Drop Procedure dbo.usp_CreateWebServiceLicenseKey
GO

/**
Creates web service license keys based on the specified type.  These
types correspond to service codes.
**/
CREATE PROCEDURE dbo.usp_CreateWebServiceLicenseKey
	@KeyType varchar(40),
    @HQID int,
	@ExpirationDate datetime = null,
    @Key varchar(50) = null,
    @Password varchar(20) = null,
    @CreatedUserID int = null
AS
BEGIN

	IF @Key IS NULL BEGIN
		SET @Key = NEWID()
	END

	IF @Password IS NULL BEGIN
		EXEC usp_GeneratePassword @Password OUTPUT
	END

	IF @ExpirationDate IS NULL BEGIN
		SET @ExpirationDate = DATEADD(m, 12, GETDATE())
		SET @ExpirationDate = DATEADD(d, 1, @ExpirationDate)
	END


	DECLARE @UserAuthReq char(1), @UserAssocWithCompany char(1), @IsTest char(1)
    DECLARE @AccessLevel int, @MaxRequestsPerMethod int, @WebServiceKeyID int
	
	IF (@KeyType = 'WebSvc') BEGIN
		SET @UserAuthReq = 'Y'
		SET @UserAssocWithCompany = 'Y'
        SET @MaxRequestsPerMethod = -1
        SET @AccessLevel = 3
	END

	IF (@KeyType = 'RegDv1') BEGIN
		SET @UserAuthReq = 'Y'
		SET @UserAssocWithCompany = 'N'
        SET @MaxRequestsPerMethod = dbo.ufn_GetCustomCaptionValue('PRWebServiceLicenseKey', 'MaxRequestsForRegDv1', 'en-us')
        SET @AccessLevel = 1
	END

	IF (@KeyType = 'RegDv2') BEGIN
		SET @UserAuthReq = 'Y'
		SET @UserAssocWithCompany = 'N'
        SET @MaxRequestsPerMethod = dbo.ufn_GetCustomCaptionValue('PRWebServiceLicenseKey', 'MaxRequestsForRegDv2', 'en-us')
        SET @AccessLevel = 2
	END

	IF (@KeyType = 'WSEval') BEGIN
		SET @IsTest = 'Y'
		SET @UserAuthReq = 'Y'
		SET @UserAssocWithCompany = 'N'
        SET @MaxRequestsPerMethod = -1
        SET @AccessLevel = 0
	END
	
				
	INSERT INTO PRWebServiceLicenseKey
			(prwslk_LicenseKey,
			 prwslk_Password,
             prwslk_AccessLevel,
             prwslk_HQID,
             prwslk_UserAuthRequired,
             prwslk_UserAssociatedWithCompanyRequired,
             prwslk_MaxRequestsPerMethod,
             prwslk_ExpirationDate, 
             prwslk_IsTestOnly,
             prwslk_CreatedBy,
             prwslk_CreatedDate,
             prwslk_UpdatedBy,
             prwslk_UpdatedDate,
             prwslk_TimeStamp)
	VALUES (@Key, 
            dbo.ufnclr_EncryptText(@Password), 
            @AccessLevel, 
            @HQID, 
            @UserAuthReq, 
            @UserAssocWithCompany, 
            @MaxRequestsPerMethod,  
            @ExpirationDate, 
            @IsTest,
            @CreatedUserID, 
            GETDATE(), 
            @CreatedUserID, 
            GETDATE(), 
            GETDATE());
	
	SELECT @WebServiceKeyID = SCOPE_IDENTITY();
			
	-- Now add our web methods to the key
	INSERT INTO PRWebServiceLicenseKeyWM (
				prwslkwm_WebServiceLicenseID,
				prwslkwm_WebMethodName,
				prwslkwm_CreatedBy,
				prwslkwm_CreatedDate,
				prwslkwm_UpdatedBy,
				prwslkwm_UpdatedDate,
				prwslkwm_TimeStamp)
    SELECT @WebServiceKeyID, capt_US, @CreatedUserID, GETDATE(), @CreatedUserID, GETDATE(), GETDATE()
      FROM Custom_Captions 
     WHERE Capt_Family = 'PRWebServiceLicenseKeyWM' 
       AND Capt_Code = @KeyType;



	SELECT prwslk_HQID, comp_Name, prwslk_LicenseKey, dbo.ufnclr_DecryptText(prwslk_Password) As Password, prwslk_AccessLevel, prwslk_UserAuthRequired, prwslk_UserAssociatedWithCompanyRequired, prwslk_MaxRequestsPerMethod, prwslk_ExpirationDate, prwslk_IsTestOnly
      FROM PRWebServiceLicenseKey
           INNER JOIN Company on prwslk_HQID = comp_CompanyID
     WHERE prwslk_WebServiceLicenseID = @WebServiceKeyID;

	SELECT prwslkwm_WebMethodName
      FROM PRWebServiceLicenseKeyWM
     WHERE prwslkwm_WebServiceLicenseID = @WebServiceKeyID;

END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_SaveDL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE dbo.usp_SaveDL
GO

CREATE PROCEDURE dbo.usp_SaveDL
    @CompanyId int,
    @Content nvarchar(max),
	@LineBreak nvarchar(20),
    @UserId int = -1
AS
BEGIN
	DECLARE  @dtNow datetime = GETDATE()

    BEGIN TRY
		-- Start making our updates
		BEGIN TRANSACTION

		DELETE FROM PRDescriptiveLine WHERE prdl_CompanyId = @CompanyID

		If ((@Content IS NOT NULL) AND LEN(LTRIM(RTRIM(@Content))) > 0) BEGIN
			INSERT INTO PRDescriptiveLine
				(prdl_CompanyId, prdl_LineContent,
				 prdl_CreatedBy, prdl_CreatedDate, prdl_UpdatedBy, prdl_UpdatedDate, prdl_TimeStamp)
			SELECT @CompanyId, [value],
 				   @UserId, @dtNow, @UserId, @dtNow, @dtNow
			FROM dbo.Tokenize(@Content, @LineBreak)
			WHERE Len(LTrim([value])) > 0
			ORDER BY idx
		END

		INSERT INTO PRChangeDetection (prchngd_CompanyID, prchngd_ChangeType, prchngd_AssociatedType, prchngd_CreatedBy, prchngd_UpdatedBy)
		VALUES (@CompanyID, 'DL Quantity', 'PRDescriptiveLine', @UserId, @UserId);	

		-- if we made it here, commit our work
		COMMIT
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
		EXEC usp_RethrowError;
	END CATCH;
END
GO


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_SaveUnloadHours]') AND type in (N'P', N'PC'))
	DROP PROCEDURE dbo.usp_SaveUnloadHours
GO

CREATE PROCEDURE dbo.usp_SaveUnloadHours
    @CompanyId int,
    @Content nvarchar(max),
	@LineBreak nvarchar(20),
    @UserId int = -1
AS
BEGIN
	DECLARE  @dtNow datetime = GETDATE()

    BEGIN TRY
		-- Start making our updates
		BEGIN TRANSACTION

		DELETE FROM PRUnloadHours WHERE pruh_CompanyID = @CompanyID

		If ((@Content IS NOT NULL) AND LEN(LTRIM(RTRIM(@Content))) > 0) BEGIN
			INSERT INTO PRUnloadHours
				(pruh_CompanyId, pruh_LineContent,
				 pruh_CreatedBy, pruh_CreatedDate, pruh_UpdatedBy, pruh_UpdatedDate, pruh_TimeStamp)
			SELECT @CompanyId, [value],
 				   @UserId, @dtNow, @UserId, @dtNow, @dtNow
			FROM dbo.Tokenize(@Content, @LineBreak)
			WHERE Len(LTrim([value])) > 0
			ORDER BY idx
		END

		INSERT INTO PRChangeDetection (prchngd_CompanyID, prchngd_ChangeType, prchngd_AssociatedType, prchngd_CreatedBy, prchngd_UpdatedBy)
		VALUES (@CompanyID, 'DL Quantity', 'PRUnloadHours', @UserId, @UserId);	

		-- if we made it here, commit our work
		COMMIT
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
		EXEC usp_RethrowError;
	END CATCH;
END
GO


IF EXISTS (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_BRPopulateEquifaxData]'))
    drop procedure [dbo].[usp_BRPopulateEquifaxData]
GO




IF EXISTS (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_SendBusinessReportSurvey]'))
    drop procedure [dbo].[usp_SendBusinessReportSurvey]
GO

CREATE PROCEDURE dbo.usp_SendBusinessReportSurvey
    @PersonLinkID int = Null,
    @PersonID int = Null,
    @CompanyID int = Null,
    @RequestID int = Null,
    @PRCategory nvarchar(max) = 'BusinessReportSurvey',
    @PRSubcategory nvarchar(max) = 'Survey',
    @Culture nvarchar(max) = 'en-us'
AS
BEGIN
    -- Send a survey when no one in the enterprise has received a survey within the last 30 days
    -- AND when the person requesting the BR has a person level email associated with the enterprise.  
	-- (PRBusinessReportRequest, specifically prbr_SurveyIncluded, prbr_RequestingPersonID, and prbr_RequestingCompanyID, 
	--  should be helpful in this.) 
    Declare @BusinessReportSurvey nvarchar(max);
    Set @BusinessReportSurvey = 'BusinessReportSurvey'

    -- Paranoia check
    If @Culture Is Null Begin
        Set @Culture = 'en-us';
    End

    -- Check to see if this is active
    Declare @Enabled int;
    Set @Enabled = dbo.ufn_GetCustomCaptionValueDefault(@BusinessReportSurvey, 'Enabled', 0);
    If @Enabled = 0 Begin
        Return;
    End

	DECLARE @PRReceiveBRSurvey char(1);

    -- Check the person link id, if there is one use it (BBOS), else use the Person & Company Id's (PIKS)
    If (@PersonLinkID Is Not Null) Begin
        SELECT @PersonID = PeLi_PersonID, 
               @CompanyID = PeLi_CompanyID,
			   @PRReceiveBRSurvey = peli_PRReceiveBRSurvey
          FROM Person_Link WITH (NOLOCK)
         WHERE PeLi_PersonLinkId = @PersonLinkID
    End

	IF (ISNULL(@PRReceiveBRSurvey, 'N') = 'N') BEGIN
		RETURN
	END

    -- Bail out if we don't have Company and Person ID's
    IF @PersonID Is Null And @CompanyID Is Null Begin
        Return;
    End

    -- Get the Headquarter
    DECLARE @HQID int;
	DECLARE @IndustryType varchar(40)
    SELECT @HQID = Comp_PRHQId,
           @IndustryType = comp_PRIndustryType
      FROM Company WITH (NOLOCK)
     WHERE Comp_CompanyID = @CompanyID;

    -- Get the # of days to check
    Declare @DayInterval int;
    Declare @StartDate datetime;
    Set @DayInterval = dbo.ufn_GetCustomCaptionValueDefault(@BusinessReportSurvey, 'DayInterval', 30);
    Set @StartDate = DateAdd(Day, 0, DateDiff(Day, 0, CURRENT_TIMESTAMP)) - @DayInterval;

    -- Check how many surveys were sent to this enterprise in the time period specified
    Declare @PreviousSurveyCount int;
    Declare @EmailAddress varchar(255);

    Set @PreviousSurveyCount = 0
    SELECT @PreviousSurveyCount = Count(1)
      FROM Communication WITH (NOLOCK)
           INNER JOIN Comm_Link WITH (NOLOCK) on Comm_CommunicationID = CmLi_Comm_CommunicationId
     WHERE Comm_PRCategory = @PRCategory
       AND CmLi_Comm_CompanyID In (SELECT Comp_CompanyID FROM Company WITH (NOLOCK) Where Comp_PRHQId = @HQID)
       AND Comm_CreatedDate > @StartDate


	IF @PreviousSurveyCount = 0 BEGIN

		SET @EmailAddress = Null;
		SELECT @EmailAddress = Emai_EmailAddress
		  FROM vPRPersonEmail WITH (NOLOCK)
		 WHERE ELink_RecordID = @PersonID
		   AND Emai_CompanyID = @CompanyID;

		IF @EmailAddress Is Not Null BEGIN

			-- Get the text of the email
			Declare @SurveySubject nvarchar(max);
			Set @SurveySubject = dbo.ufn_GetCustomCaptionValueDefault(@BusinessReportSurvey, 'SurveySubjectLine', 'Blue Book Services Would Like Your Feedback');

			Declare @SurveyText nvarchar(max);
			Select @SurveyText = dbo.ufn_GetCustomCaptionValue('BusinessReportSurvey', 'SurveyText', @Culture);

			Declare @SurveyURL nvarchar(max);
			IF (@IndustryType = 'L') BEGIN
				SELECT @SurveyURL = dbo.ufn_GetCustomCaptionValue('BusinessReportSurvey', 'SurveyURL_Lumber', @Culture);
			END ELSE BEGIN
				SELECT @SurveyURL = dbo.ufn_GetCustomCaptionValue('BusinessReportSurvey', 'SurveyURL', @Culture);
			END

			SET @SurveyText = REPLACE(@SurveyText, '{0}', @SurveyURL)
		

			SET @SurveyText = dbo.ufn_GetFormattedEmail(@CompanyID, @PersonID, 0, @SurveySubject, @SurveyText, NULL)

			Exec usp_CreateEmail
						@TO = @EmailAddress,
						@Subject = @SurveySubject,
						@Content = @SurveyText,
						@Content_Format = 'HTML',
						@RelatedCompanyID = @CompanyID,
						@RelatedPersonID = @PersonID,
						@Action = 'EmailOut',
						@PRCategory = @PRCategory,
						@PRSubCategory = @PRSubcategory,
						@PRRequestID = @RequestID,
						@Source = 'Send BR Survey'
		END
	END		
END
Go

--
-- Deprecated.  Use ufn_GetTableCounts instead.  Would rather have something that is dynamic,
-- but the user function is faster and easier to use.
--
IF OBJECT_ID (N'usp_GetTableCountsOLD',N'P') IS NOT NULL
    DROP PROCEDURE usp_GetTableCountsOLD;
GO

CREATE PROCEDURE usp_GetTableCountsOLD
    @CompanyID int,
    @IncludeAssociatedIDs bit = 1
AS
BEGIN

	DECLARE @Count int, @Index int
	DECLARE @TableName varchar(255), @ColumnName varchar(255), @Prefix varchar(255)
	DECLARE @PIKSTables table (
		ndx int identity(1,1) primary key,
		tablename varchar(255),
		columnname varchar(255),
        colprefix varchar(10)
	)

	-- Determine which tables have columns ending
	-- with companyid or hqid
	INSERT INTO @PIKSTables (tablename, columnname, colprefix)
	SELECT c.table_name, column_name, RTRIM(Bord_Prefix) 
	  FROM information_schema.columns c
		   inner join information_schema.tables t ON c.table_name = t.table_name
           inner join custom_tables ON t.table_name = bord_name
	 WHERE (column_name like '%companyid'
			OR column_name like '%hqid'
			OR column_name like '%bbid'
            OR column_name like '%AssociatedID')
       AND c.table_name NOT IN ('OrderQuote')
	   AND table_type = 'BASE TABLE'
	   AND data_type = 'int'
	ORDER BY table_name, column_name;

	IF (@IncludeAssociatedIDs = 0) BEGIN
		DELETE FROM @PIKSTables
         WHERE columnname like '%AssociatedID';
	END

	-- Uncomment this to see a list of the
	-- tables/columns being checked
	--select * from @PIKSTables

	CREATE TABLE #PIKSTables (
		tablename varchar(255),
		recordcount int,
	    lastupdate datetime
	)

	DECLARE @SQL varchar(500)
	SELECT @Count = COUNT(1) FROM @PIKSTables;
	SET @Index = 0

	-- Now get the record count for each table 
	-- that references our company ID
	WHILE (@Index < @Count) BEGIN
		SET @Index = @Index + 1

		SELECT @TableName = tablename,
			   @ColumnName = columnname,
               @Prefix = colprefix
		  FROM @PIKSTables
		 WHERE ndx = @Index;
		
		IF (@ColumnName LIKE '%AssociatedID') BEGIN
			SET @SQL = 'INSERT INTO #PIKSTables (tablename, recordcount, lastupdate) SELECT ''' + @TableName + ''', COUNT(1), MAX(' + @Prefix + '_UpdatedDate) FROM ' + @TableName + ' WHERE ' + @ColumnName + '=' + CONVERT(varchar(10), @CompanyID) + ' AND ' + @Prefix + '_AssociatedType=''C'''
		END ELSE BEGIN
			SET @SQL = 'INSERT INTO #PIKSTables (tablename, recordcount, lastupdate) SELECT ''' + @TableName + ''', COUNT(1), MAX(' + @Prefix + '_UpdatedDate) FROM ' + @TableName + ' WHERE ' + @ColumnName + '=' + CONVERT(varchar(10), @CompanyID)
		END
		
		--print @SQL
		EXEC(@SQL)
	END


	SELECT TableName, SUM(recordcount) As RecordCount, MAX(lastupdate) As LastUpdated
	  FROM #PIKSTables
	 WHERE recordcount > 0
	GROUP BY tablename;

	Drop Table #PIKSTables
END
Go

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].usp_IsEligibeForDelete'))
DROP PROCEDURE dbo.usp_IsEligibeForDelete
GO

CREATE PROCEDURE dbo.usp_IsEligibeForDelete
	@CompanyID int, 
	@IncludeAssociatedIDs bit
AS
BEGIN

	DECLARE @TableCounts table (
		tablename varchar(255),
		recordcount int,
		lastupdate datetime
	)

	--INSERT INTO @TableCounts(tablename, recordcount, lastupdate)
	--EXEC usp_GetTableCounts @CompanyID, @IncludeAssociatedIDs

	INSERT INTO @TableCounts(tablename, recordcount, lastupdate)
	SELECT * FROM dbo.ufn_GetTableCounts(@CompanyID, @IncludeAssociatedIDs)

	DECLARE @Count int

	SELECT @Count = COUNT(1)
	  FROM @TableCounts
	 WHERE tablename IN (
			'PRBusinessReportRequest',
			'PREBBConversionDetail',
			'PRFile',
			'PRService',
			'PRServiceUnitAllocation',
			'PRServiceUnitUsage',
			'PRAdCampaign',
			'PRWebServiceLicenseKey',
			'PRBBOSUserAudit',
			'PRExternalLinkAuditTrail',
			'PRRequest',
			'PRRequestDetail',
			'PRSearchAuditTrail',
			'PRSearchWizardAuditTrail',
			'PRSelfServiceAuditTrail',
			'PRWebAuditTrail',
			'PRWebUser',
			'PRWebUserContact',
			'PRWebUserCustomData',
			'PRWebUserList',
			'PRWebUserNote',
			'PRWebUserSearchCriteria');

	IF @Count > 0 BEGIN
		SELECT 'N' As Result
	END ELSE BEGIN
		SELECT 'Y' As Result
	END
END
Go


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].usp_DeleteCompany'))
     DROP PROCEDURE dbo.usp_DeleteCompany
GO

CREATE PROCEDURE [dbo].[usp_DeleteCompany] 
	@CompanyID int
AS
BEGIN
	DECLARE @IsListed varchar(1), @CanDelete varchar(1)
	SELECT @IsListed = 'Y'
	   FROM Company
	  WHERE comp_CompanyID = @CompanyID
	    AND comp_PRListingStatus IN ('L', 'H', 'LUV');
	IF (@IsListed = 'Y') BEGIN
		RAISERROR ('Unable to Delete Company: It is listed.', 16, 1)
		RETURN
	END
	SELECT @CanDelete = dbo.ufn_IsEligibeForDelete(@CompanyID, 1, 0);
	IF (@CanDelete = 'N') BEGIN
		RAISERROR ('Unable to Delete Company. Found company data that cannot be deleted.', 16, 1)
		RETURN
	END
	UPDATE Cases SET Case_PrimaryCompanyId = NULL WHERE Case_PrimaryCompanyId = @CompanyID;
	UPDATE Opportunity SET oppo_PRReferredByCompanyId = NULL WHERE oppo_PRReferredByCompanyId = @CompanyID;
	DELETE FROM PRPublicationArticleCompany WHERE prpbarc_CompanyID = @CompanyID;
	UPDATE PRWebUser Set prwu_CDSWBBID = null where prwu_CDSWBBID = @CompanyID;


	DECLARE @Tmp table (
		ID int
	)

	INSERT INTO @Tmp SELECT elink_EmailID FROM EmailLink WHERE elink_RecordID = @CompanyID AND ELink_EntityId = 5 

	ALTER TABLE Email DISABLE TRIGGER ALL;
	ALTER TABLE EmailLink DISABLE TRIGGER ALL;
	UPDATE Email SET emai_CompanyID = NULL FROM EmailLink WHERE emai_EmailID = elink_EmailID AND ELink_EntityId = 13 AND emai_CompanyID = @CompanyID;
	DELETE FROM EmailLink WHERE elink_RecordID = @CompanyID AND ELink_EntityId = 5 
	DELETE FROM Email WHERE emai_EmailID IN (SELECT ID FROM @Tmp)	
	ALTER TABLE Email ENABLE TRIGGER ALL;
	ALTER TABLE EmailLink ENABLE TRIGGER ALL;

	DELETE FROM @Tmp;
	INSERT INTO @Tmp SELECT plink_PhoneID FROM PhoneLink WHERE plink_RecordID = @CompanyID AND pLink_EntityId = 5 

	ALTER TABLE Phone DISABLE TRIGGER ALL;
	ALTER TABLE PhoneLink DISABLE TRIGGER ALL;
	UPDATE Phone SET phon_CompanyID = NULL FROM PhoneLink WHERE phon_PhoneID = plink_PhoneID AND pLink_EntityId = 13 AND phon_CompanyID = @CompanyID;
	DELETE FROM PhoneLink WHERE plink_RecordID = @CompanyID AND pLink_EntityId = 5 
	DELETE FROM Phone WHERE phon_PhoneID IN (SELECT ID FROM @Tmp)	
	ALTER TABLE Phone ENABLE TRIGGER ALL;
	ALTER TABLE PhoneLink ENABLE TRIGGER ALL;


	 ALTER TABLE Address DISABLE TRIGGER ALL;
	 DELETE FROM Address WHERE addr_AddressID IN (SELECT adli_AddressID FROM Address_Link WHERE adli_CompanyID = @CompanyID);
	 ALTER TABLE Address ENABLE TRIGGER ALL;
	 ALTER TABLE Address_Link DISABLE TRIGGER ALL;
	 DELETE FROM Address_Link WHERE adli_CompanyID = @CompanyID;
	 ALTER TABLE Address_Link ENABLE TRIGGER ALL;
	 ALTER TABLE Person DISABLE TRIGGER ALL;
	 DELETE FROM Person WHERE pers_PersonID IN (SELECT peli_PersonID FROM Person_Link WHERE peli_CompanyID = @CompanyID);
	 ALTER TABLE Person ENABLE TRIGGER ALL;
	 ALTER TABLE Person_Link DISABLE TRIGGER ALL;
	 DELETE FROM Person_Link WHERE peli_CompanyID = @CompanyID;
	 ALTER TABLE Person_Link ENABLE TRIGGER ALL;
	 ALTER TABLE PRBusinessEvent DISABLE TRIGGER ALL;
	 DELETE FROM PRBusinessEvent WHERE prbe_CompanyId = @CompanyID;
	 ALTER TABLE PRBusinessEvent ENABLE TRIGGER ALL;
	 ALTER TABLE PRCompanyAlias DISABLE TRIGGER ALL;
	 DELETE FROM PRCompanyAlias WHERE pral_CompanyId = @CompanyID;
	 ALTER TABLE PRCompanyAlias ENABLE TRIGGER ALL;
	 ALTER TABLE PRCompanyBank DISABLE TRIGGER ALL;
	 DELETE FROM PRCompanyBank WHERE prcb_CompanyId = @CompanyID;
	 ALTER TABLE PRCompanyBank ENABLE TRIGGER ALL;
	 ALTER TABLE PRCompanyBrand DISABLE TRIGGER ALL;
	 DELETE FROM PRCompanyBrand WHERE prc3_CompanyId = @CompanyID;
	 ALTER TABLE PRCompanyBrand ENABLE TRIGGER ALL;
	 ALTER TABLE PRCompanyClassification DISABLE TRIGGER ALL;
	 DELETE FROM PRCompanyClassification WHERE prc2_CompanyId = @CompanyID;
	 ALTER TABLE PRCompanyClassification ENABLE TRIGGER ALL;
	 ALTER TABLE PRCompanyCommodityAttribute DISABLE TRIGGER ALL;
	 DELETE FROM PRCompanyCommodityAttribute WHERE prcca_CompanyId = @CompanyID;
	 ALTER TABLE PRCompanyCommodityAttribute ENABLE TRIGGER ALL;
	 ALTER TABLE PRCompanyExternalNews DISABLE TRIGGER ALL;
	 DELETE FROM PRCompanyExternalNews WHERE prcen_CompanyID = @CompanyID;
	 ALTER TABLE PRCompanyExternalNews ENABLE TRIGGER ALL;
	 ALTER TABLE PRCompanyIndicators DISABLE TRIGGER ALL;
	 DELETE FROM PRCompanyIndicators WHERE prci2_CompanyID = @CompanyID;
	 ALTER TABLE PRCompanyIndicators ENABLE TRIGGER ALL;
	 ALTER TABLE PRCompanyLicense DISABLE TRIGGER ALL;
	 DELETE FROM PRCompanyLicense WHERE prli_CompanyId = @CompanyID;
	 ALTER TABLE PRCompanyLicense ENABLE TRIGGER ALL;
	 ALTER TABLE PRCompanyProductProvided DISABLE TRIGGER ALL;
	 DELETE FROM PRCompanyProductProvided WHERE prcprpr_CompanyID = @CompanyID;
	 ALTER TABLE PRCompanyProductProvided ENABLE TRIGGER ALL;
	 ALTER TABLE PRCompanyProfile DISABLE TRIGGER ALL;
	 DELETE FROM PRCompanyProfile WHERE prcp_CompanyId = @CompanyID;
	 ALTER TABLE PRCompanyProfile ENABLE TRIGGER ALL;
	 ALTER TABLE PRCompanyRegion DISABLE TRIGGER ALL;
	 DELETE FROM PRCompanyRegion WHERE prcd_CompanyId = @CompanyID;
	 ALTER TABLE PRCompanyRegion ENABLE TRIGGER ALL;
	 ALTER TABLE PRCompanySearch DISABLE TRIGGER ALL;
	 DELETE FROM PRCompanySearch WHERE prcse_CompanyId = @CompanyID;
	 ALTER TABLE PRCompanySearch ENABLE TRIGGER ALL;
	 ALTER TABLE PRCompanyServiceProvided DISABLE TRIGGER ALL;
	 DELETE FROM PRCompanyServiceProvided WHERE prcserpr_CompanyID = @CompanyID;
	 ALTER TABLE PRCompanyServiceProvided ENABLE TRIGGER ALL;
	 ALTER TABLE PRCompanySpecie DISABLE TRIGGER ALL;
	 DELETE FROM PRCompanySpecie WHERE prcspc_CompanyID = @CompanyID;
	 ALTER TABLE PRCompanySpecie ENABLE TRIGGER ALL;
	 ALTER TABLE PRCompanyStockExchange DISABLE TRIGGER ALL;
	 DELETE FROM PRCompanyStockExchange WHERE prc4_CompanyId = @CompanyID;
	 ALTER TABLE PRCompanyStockExchange ENABLE TRIGGER ALL;
	 ALTER TABLE PRCompanyTerminalMarket DISABLE TRIGGER ALL;
	 DELETE FROM PRCompanyTerminalMarket WHERE prct_CompanyId = @CompanyID;
	 ALTER TABLE PRCompanyTerminalMarket ENABLE TRIGGER ALL;
	 ALTER TABLE PRDescriptiveLine DISABLE TRIGGER ALL;
	 DELETE FROM PRDescriptiveLine WHERE prdl_CompanyId = @CompanyID;
	 ALTER TABLE PRDescriptiveLine ENABLE TRIGGER ALL;
	 ALTER TABLE PRUnloadHours DISABLE TRIGGER ALL;
	 DELETE FROM PRUnloadHours WHERE pruh_CompanyID = @CompanyID;
	 ALTER TABLE PRUnloadHours ENABLE TRIGGER ALL;
	 ALTER TABLE PRDescriptiveLineUsage DISABLE TRIGGER ALL;
	 DELETE FROM PRDescriptiveLineUsage WHERE prd3_CompanyId = @CompanyID;
	 ALTER TABLE PRDescriptiveLineUsage ENABLE TRIGGER ALL;
	 ALTER TABLE PRDRCLicense DISABLE TRIGGER ALL;
	 DELETE FROM PRDRCLicense WHERE prdr_CompanyId = @CompanyID;
	 ALTER TABLE PRDRCLicense ENABLE TRIGGER ALL;
--	 ALTER TABLE PROwnership DISABLE TRIGGER ALL;
--	 DELETE FROM PROwnership WHERE prow_CompanyId = @CompanyID;
--	 ALTER TABLE PROwnership ENABLE TRIGGER ALL;
	 ALTER TABLE PRPACALicense DISABLE TRIGGER ALL;
	 DELETE FROM PRPACALicense WHERE prpa_CompanyId = @CompanyID;
	 ALTER TABLE PRPACALicense ENABLE TRIGGER ALL;
	 ALTER TABLE PRRating DISABLE TRIGGER ALL;
	 DELETE FROM PRRating WHERE prra_CompanyId = @CompanyID;
	 ALTER TABLE PRRating ENABLE TRIGGER ALL;
	 DELETE FROM Communication WHERE Comm_CommunicationId IN (SELECT cmli_Comm_CommunicationId FROM Comm_Link WHERE CmLi_Comm_CompanyId = @CompanyID);
	 DELETE FROM Comm_Link WHERE CmLi_Comm_CompanyId = @CompanyID;
	 DELETE FROM Lead WHERE Lead_PrimaryCompanyID = @CompanyID;
	 DELETE FROM Library WHERE Libr_CompanyId = @CompanyID;
	 DELETE FROM Marketing WHERE Mrkt_CompanyId = @CompanyID;
	 DELETE FROM Opportunity WHERE Oppo_PrimaryCompanyId = @CompanyID;
	 DELETE FROM OpportunityHistory WHERE Oppo_PrimaryCompanyID = @CompanyID;
	 DELETE FROM PRAdCampaign WHERE pradc_CompanyID = @CompanyID;
	 DELETE FROM PRAdCampaignAuditTrail WHERE pradcat_CompanyID = @CompanyID;
	 DELETE FROM PRARAging WHERE praa_CompanyId = @CompanyID;
	 DELETE FROM PRARAgingDetail WHERE praad_ManualCompanyId = @CompanyID;
--	 DELETE FROM PRBBOSUserAudit WHERE prbbosua_CompanyID = @CompanyID;
	 DELETE FROM PRBBScore WHERE prbs_CompanyId = @CompanyID;
	 DELETE FROM PRCompanyInfoProfile WHERE prc5_CompanyId = @CompanyID;
	 DELETE FROM PRCompanyRelationship WHERE prcr_LeftCompanyId = @CompanyID;
	 DELETE FROM PRCompanyRelationship WHERE prcr_RightCompanyId = @CompanyID;
	 DELETE FROM PRCreditSheet WHERE prcs_CompanyId = @CompanyID;
	 DELETE FROM PRExceptionQueue WHERE preq_CompanyId = @CompanyID;
	 DELETE FROM PRFinancial WHERE prfs_CompanyId = @CompanyID;
	 DELETE FROM PRRequest WHERE prreq_CompanyID = @CompanyID;
	 DELETE FROM PRRequestDetail WHERE prrc_RequestID IN (SELECT prreq_RequestID FROM PRRequest WHERE prreq_CompanyID = @CompanyID);
	 DELETE FROM PRRequestDetail WHERE prrc_AssociatedID = @CompanyID AND prrc_AssociatedType = 'C'
	 DELETE FROM PRSelfServiceAuditTrailDetail WHERE prssatd_SelfServiceAuditTrailID IN (SELECT prssat_SelfServiceAuditTrailID FROM PRSelfServiceAuditTrail WHERE prssat_CompanyID = @CompanyID);
	 DELETE FROM PRSelfServiceAuditTrail WHERE prssat_CompanyID = @CompanyID;
	 DELETE FROM PRServiceUnitAllocation WHERE prun_CompanyId = @CompanyID;
	 DELETE FROM PRServiceUnitUsage WHERE prsuu_CompanyId = @CompanyID;
	 DELETE FROM PRSSContact WHERE prssc_CompanyId = @CompanyID;
	 DELETE FROM PRTESRequest WHERE prtesr_SubjectCompanyID = @CompanyID;
	 DELETE FROM PRTESRequest WHERE prtesr_ResponderCompanyID = @CompanyID;
	 DELETE FROM PRTESForm WHERE prtf_CompanyId = @CompanyID;
	 DELETE FROM PRTransactionDetail WHERE prtd_TransactionId IN (SELECT prtx_TransactionID FROM PRTransaction WHERE prtx_CompanyId = @CompanyID);
	 DELETE FROM PRTransaction WHERE prtx_CompanyId = @CompanyID;

	 DELETE FROM PRLocalSource WHERE prls_CompanyId = @CompanyID;
	 DELETE FROM PRListing WHERE prlst_CompanyId = @CompanyID;
	 DELETE FROM PRCompanyPayIndicator WHERE prcpi_CompanyID = @CompanyID;
	 DELETE FROM PRAttentionLine WHERE prattn_CompanyID = @CompanyID;
	 DELETE FROM PRDLMetrics WHERE prdlm_CompanyID = @CompanyID;
	 DELETE FROM PRCommunicationLog WHERE prcoml_CompanyID = @CompanyID;
	 
	 ALTER TABLE Company DISABLE TRIGGER ALL;
	 DELETE FROM Company WHERE comp_CompanyID = @CompanyID;
	 ALTER TABLE Company ENABLE TRIGGER ALL;
	 ALTER TABLE Company DISABLE TRIGGER ALL;
	 UPDATE Company SET comp_PRServicesThroughCompanyId = NULL WHERE comp_PRServicesThroughCompanyId = @CompanyID;
	 ALTER TABLE Company ENABLE TRIGGER ALL;
END
Go



IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].usp_GetCreditSheetCount'))
DROP PROCEDURE dbo.usp_GetCreditSheetCount
GO

CREATE PROCEDURE dbo.usp_GetCreditSheetCount 
	@IndustryTypeList varchar(50), 
    @ReportDate datetime
AS
BEGIN


	SELECT COUNT(1)
      FROM PRCreditSheet
           INNER JOIN Company on prcs_CompanyID = comp_CompanyID
     WHERE prcs_WeeklyCSPubDate = @ReportDate
       AND comp_PRIndustryType IN (SELECT value FROM dbo.tokenize(@IndustryTypeList, ','));
END
Go


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].usp_MergeCompanies'))
     DROP PROCEDURE dbo.usp_MergeCompanies
GO

CREATE PROCEDURE [dbo].[usp_MergeCompanies] 
	@SourceCompanyID int,	
	@TargetCompanyID int 
AS
BEGIN
	DECLARE @IsListed varchar(1), @CanDelete varchar(1)
	SELECT @IsListed = 'Y'
      FROM Company
     WHERE comp_CompanyID = @SourceCompanyID
       AND comp_PRListingStatus IN ('L', 'H', 'LUV');
	IF (@IsListed = 'Y') BEGIN
		RAISERROR ('Unable to Merge Companies: The source company is listed.', 16, 1)
		RETURN
	END
	SELECT @CanDelete = dbo.ufn_IsEligibeForDelete(@SourceCompanyID, 1, 1);
	IF (@CanDelete = 'N') BEGIN
		RAISERROR ('Unable to Merge Company. Found source company data that cannot be deleted.', 16, 1)
		RETURN
	END
	UPDATE Opportunity SET oppo_PRReferredByCompanyId = @TargetCompanyID  WHERE oppo_PRReferredByCompanyId = @SourceCompanyID;
	UPDATE PRARAging SET praa_CompanyId = @TargetCompanyID  WHERE praa_CompanyId = @SourceCompanyID;
	UPDATE PRARAgingDetail SET praad_ManualCompanyId = @TargetCompanyID  WHERE praad_ManualCompanyId = @SourceCompanyID;
	UPDATE PRBusinessReportRequest SET prbr_RequestedCompanyId = @TargetCompanyID  WHERE prbr_RequestedCompanyId = @SourceCompanyID;
	UPDATE PRCompanyExternalNews SET prcen_CompanyID = @TargetCompanyID WHERE prcen_CompanyID = @SourceCompanyID;
	UPDATE PRCompanyRelationship SET prcr_LeftCompanyId = @TargetCompanyID  WHERE prcr_LeftCompanyId = @SourceCompanyID;
	UPDATE PRCompanyRelationship SET prcr_RightCompanyId = @TargetCompanyID  WHERE prcr_RightCompanyId = @SourceCompanyID;
	UPDATE PRExternalLinkAuditTrail SET prelat_AssociatedID = @TargetCompanyID  WHERE prelat_AssociatedID = @SourceCompanyID AND prelat_AssociatedType = 'C';
	UPDATE PRExternalNews SET pren_SubjectCompanyID = @TargetCompanyID WHERE pren_SubjectCompanyID = @SourceCompanyID;
	UPDATE PRLinkedInAuditTrail SET prliat_SubjectCompanyID = @TargetCompanyID WHERE prliat_SubjectCompanyID = @SourceCompanyID;
	UPDATE PRPublicationArticleCompany SET prpbarc_CompanyID = @TargetCompanyID WHERE prpbarc_CompanyID = @SourceCompanyID;
	UPDATE PRRequestDetail SET prrc_AssociatedID = @TargetCompanyID  WHERE prrc_AssociatedID = @SourceCompanyID AND prrc_AssociatedType = 'C';
	UPDATE PRSocialMedia SET prsm_CompanyID = @TargetCompanyID WHERE prsm_CompanyID = @SourceCompanyID;
	UPDATE PRTESRequest SET prtesr_ResponderCompanyID = @TargetCompanyID  WHERE prtesr_ResponderCompanyID = @SourceCompanyID;
	UPDATE PRTESRequest SET prtesr_SubjectCompanyID = @TargetCompanyID  WHERE prtesr_SubjectCompanyID = @SourceCompanyID;
	UPDATE PRTESForm SET prtf_CompanyId = @TargetCompanyID  WHERE prtf_CompanyId = @SourceCompanyID;
	UPDATE PRWebAuditTrail SET prwsat_AssociatedID = @TargetCompanyID WHERE prwsat_AssociatedID = @SourceCompanyID AND prwsat_AssociatedType = 'C';
	UPDATE PRWebUserContact SET prwuc_AssociatedCompanyID = @TargetCompanyID  WHERE prwuc_AssociatedCompanyID = @SourceCompanyID;
	UPDATE PRWebUserCustomData SET prwucd_AssociatedID = @TargetCompanyID  WHERE prwucd_AssociatedID = @SourceCompanyID AND prwucd_AssociatedType = 'C';
	UPDATE PRWebUserListDetail SET prwuld_AssociatedID = @TargetCompanyID  WHERE prwuld_AssociatedID = @SourceCompanyID AND prwuld_AssociatedType = 'C';
	UPDATE PRWebUserNote SET prwun_AssociatedID = @TargetCompanyID  WHERE prwun_AssociatedID = @SourceCompanyID AND prwun_AssociatedType = 'C';
	UPDATE PRPACALicense SET prpa_CompanyId = @TargetCompanyID  WHERE prpa_CompanyId = @SourceCompanyID;


	DELETE FROM PRListing WHERE prlst_CompanyID = @SourceCompanyID;
END

Go


If Exists (Select name from sysobjects where name = 'usp_SaveLumberSettings' and type='P')
    Drop Procedure dbo.usp_SaveLumberSettings
Go

CREATE PROCEDURE dbo.usp_SaveLumberSettings (
    @PersonLinkID int,
    @WillSubmitARAging char(1) = null,
    @ReceivesCreditSheetReport char(1) = null,
    @CRMUserID int = 0)
AS 

-- If we don't have a CRM User, go get the
-- default website user
IF @CRMUserID = 0 BEGIN
	SET @CRMUserID = dbo.ufn_GetSystemUserId(1)
END

UPDATE Person_Link
   SET peli_PRWillSubmitARAging  = @WillSubmitARAging,
	   peli_PRReceivesCreditSheetReport  = @ReceivesCreditSheetReport,
	   peli_UpdatedBy = @CRMUserID,
       peli_UpdatedDate = GETDATE(),
       peli_TimeStamp = GETDATE()
 WHERE peli_PersonLinkID = @PersonLinkID;
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_ReplicateCompanySpecie]') 
            and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_ReplicateCompanySpecie]
GO

CREATE PROCEDURE dbo.usp_ReplicateCompanySpecie
  @comp_CompanyId int = null,
  @SourceId int = null,
  @ReplicateToIds varchar(max) = null,
  @UserId int = -1
AS
BEGIN

    DECLARE @Return int
    DECLARE @Msg varchar(2000)
    SET @Return = 0
    IF (@SourceId IS NULL)
        SET @SourceId = @comp_CompanyId;

    IF (@SourceId IS NULL)
    BEGIN
        SET @Msg = 'Updates Failed.  The Company Id could not be determined.'
        RAISERROR (@Msg, 16, 1)
        Return 1
    End


    -- Create a local table for the Company Ids to be replicated to
    DECLARE @tblReplicateTo TABLE(idx smallint, token varchar(30))    
    DECLARE @CompanyCnt smallint, @LoopIdx smallint
    DECLARE @token varchar(30)
    DECLARE @TrxId int
    DECLARE @Now DateTime
    SET @Now = getDate()
    DECLARE @RepCompanyId int


    INSERT INTO @tblReplicateTo SELECT * FROM dbo.Tokenize(@ReplicateToIds, ',');
    SELECT @CompanyCnt = COUNT(1) FROM @tblReplicateTo;


    -- Create a local table for the IDs that are to be replicated
    DECLARE @tblReplicateID TABLE(ndx smallint identity, ID int, Name varchar(500), DisplayOrder int)    
    DECLARE @IdNdx smallint, @IDCount int
    DECLARE @ReplicateID int, @Name varchar(500), @NextID int
	DECLARE @NewValues varchar(max);
    DECLARE @OldValues varchar(max);
	SET @NewValues = '';

    INSERT INTO @tblReplicateID (ID, Name, DisplayOrder)
         SELECT DISTINCT prcspc_SpecieID, prspc_Name, prspc_DisplayOrder
           FROM PRCompanySpecie 
                INNER JOIN PRSpecie ON prcspc_SpecieID = prspc_SpecieID
          WHERE prcspc_CompanyID = @SourceId
       ORDER BY prspc_DisplayOrder;
	SELECT @IDCount = COUNT(1) FROM @tblReplicateID;


	BEGIN TRY
		BEGIN TRANSACTION

		  SET @LoopIdx = 0
		  WHILE (@LoopIdx < @CompanyCnt) BEGIN

			SET @token = null
			SELECT @token = token FROM @tblReplicateTo WHERE idx = @Loopidx


			IF (@token is not null)
			BEGIN
				-- convert the token to a company id int value
				SET @RepCompanyId = convert(int, @token)

				-- Build an "Old Value" lis
				SELECT @OldValues = COALESCE(@OldValues+',' ,'') + prspc_Name
                  FROM PRCompanySpecie 
                       INNER JOIN PRSpecie ON prcspc_SpecieID = prspc_SpecieID
                 WHERE prcspc_CompanyID = @RepCompanyId;

				-- Process the IDs
				SET @IdNdx = 1
				WHILE (@IdNdx <= @IDCount) BEGIN
					SELECT @ReplicateID = ID,
                           @Name = Name
                      FROM @tblReplicateID 
					 WHERE ndx=@IdNdx;

					IF (NOT Exists(SELECT 1 
                                     FROM PRCompanySpecie
									WHERE prcspc_CompanyID = @RepCompanyId 
									  AND prcspc_SpecieID = @ReplicateID)) BEGIN


						EXEC usp_GetNextId 'PRCompanySpecie', @NextID output
						INSERT INTO PRCompanySpecie 
							(prcspc_CompanySpecieID,prcspc_CompanyID,prcspc_SpecieID,prcspc_CreatedBy,prcspc_CreatedDate,prcspc_UpdatedBy,prcspc_UpdatedDate,prcspc_TimeStamp)
                        VALUES (@NextID, @RepCompanyId, @ReplicateID, @UserId, @Now, @UserId, @Now, @Now);

						IF (LEN(@NewValues) > 0) BEGIN
							SET @NewValues = @NewValues + ', ';
						END
						SET @NewValues = @NewValues + @Name;
					END

					SET @IdNdx = @IdNdx + 1
				END
			END
			

			-- Transactions are handled differently in this case.
			IF (LEN(@NewValues) > 0) BEGIN
				EXEC @TrxId = usp_CreateTransaction 
								@UserId = @UserId,
								@prtx_CompanyId = @RepCompanyId,
								@prtx_Explanation = 'Transaction created by Specie Replication.'

				EXEC usp_CreateTransactionDetail @TrxId, 'Specie', 'Update', 'prspc_Name', @OldValues, @NewValues;
	
				UPDATE PRTransaction SET prtx_Status = 'C' WHERE prtx_TransactionId = @TrxId
			END

			SET @LoopIdx = @LoopIdx + 1

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

	RETURN @Return
END
Go



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_ReplicateCompanyServiceProvided]') 
            and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_ReplicateCompanyServiceProvided]
GO

CREATE PROCEDURE dbo.usp_ReplicateCompanyServiceProvided
  @comp_CompanyId int = null,
  @SourceId int = null,
  @ReplicateToIds varchar(max) = null,
  @UserId int = -1
AS
BEGIN

    DECLARE @Return int
    DECLARE @Msg varchar(2000)
    SET @Return = 0
    IF (@SourceId IS NULL)
        SET @SourceId = @comp_CompanyId;

    IF (@SourceId IS NULL)
    BEGIN
        SET @Msg = 'Updates Failed.  The Company Id could not be determined.'
        RAISERROR (@Msg, 16, 1)
        Return 1
    End


    -- Create a local table for the Company Ids to be replicated to
    DECLARE @tblReplicateTo TABLE(idx smallint, token varchar(30))    
    DECLARE @CompanyCnt smallint, @LoopIdx smallint
    DECLARE @token varchar(30)
    DECLARE @TrxId int
    DECLARE @Now DateTime
    SET @Now = getDate()
    DECLARE @RepCompanyId int


    INSERT INTO @tblReplicateTo SELECT * FROM dbo.Tokenize(@ReplicateToIds, ',');
    SELECT @CompanyCnt = COUNT(1) FROM @tblReplicateTo;


    -- Create a local table for the IDs that are to be replicated
    DECLARE @tblReplicateID TABLE(ndx smallint identity, ID int, Name varchar(500), DisplayOrder int)    
    DECLARE @IdNdx smallint, @IDCount int
    DECLARE @ReplicateID int, @Name varchar(500), @NextID int
	DECLARE @NewValues varchar(max);
    DECLARE @OldValues varchar(max);
	SET @NewValues = '';

    INSERT INTO @tblReplicateID (ID, Name, DisplayOrder)
         SELECT DISTINCT prcserpr_ServiceProvidedID, prserpr_Name, prserpr_DisplayOrder
           FROM PRCompanyServiceProvided 
                INNER JOIN PRServiceProvided ON prcserpr_ServiceProvidedID = prserpr_ServiceProvidedID
          WHERE prcserpr_CompanyID = @SourceId
       ORDER BY prserpr_DisplayOrder;
	SELECT @IDCount = COUNT(1) FROM @tblReplicateID;

	BEGIN TRY
		BEGIN TRANSACTION

		  SET @LoopIdx = 0
		  WHILE (@LoopIdx < @CompanyCnt) BEGIN

			SET @token = null
			SELECT @token = token FROM @tblReplicateTo WHERE idx = @Loopidx


			IF (@token is not null)
			BEGIN
				-- convert the token to a company id int value
				SET @RepCompanyId = convert(int, @token)

				-- Build an "Old Value" lis
				SELECT @OldValues = COALESCE(@OldValues+',' ,'') + prserpr_Name
                  FROM PRCompanyServiceProvided 
                       INNER JOIN PRServiceProvided ON prcserpr_ServiceProvidedID = prserpr_ServiceProvidedID
                 WHERE prcserpr_CompanyID = @RepCompanyId;

				-- Process the IDs
				SET @IdNdx = 1
				WHILE (@IdNdx <= @IDCount) BEGIN
					SELECT @ReplicateID = ID,
                           @Name = Name
                      FROM @tblReplicateID 
					 WHERE ndx=@IdNdx;

					IF (NOT Exists(SELECT 1 
                                     FROM PRCompanyServiceProvided
									WHERE prcserpr_CompanyID = @RepCompanyId 
									  AND prcserpr_ServiceProvidedID = @ReplicateID)) BEGIN


						EXEC usp_GetNextId 'PRCompanyServiceProvided', @NextID output
						INSERT INTO PRCompanyServiceProvided 
							(prcserpr_CompanyServiceProvidedID,prcserpr_CompanyID,prcserpr_ServiceProvidedID,prcserpr_CreatedBy,prcserpr_CreatedDate,prcserpr_UpdatedBy,prcserpr_UpdatedDate,prcserpr_TimeStamp)
                        VALUES (@NextID, @RepCompanyId, @ReplicateID, @UserId, @Now, @UserId, @Now, @Now);

						IF (LEN(@NewValues) > 0) BEGIN
							SET @NewValues = @NewValues + ', ';
						END
						SET @NewValues = @NewValues + @Name;
					END

					SET @IdNdx = @IdNdx + 1
				END
			END
			

			-- Transactions are handled differently in this case.
			IF (LEN(@NewValues) > 0) BEGIN
				EXEC @TrxId = usp_CreateTransaction 
								@UserId = @UserId,
								@prtx_CompanyId = @RepCompanyId,
								@prtx_Explanation = 'Transaction created by Service Provided Replication.'

				EXEC usp_CreateTransactionDetail @TrxId, 'Services Provided', 'Update', 'prserpr_Name', @OldValues, @NewValues;
	
				UPDATE PRTransaction SET prtx_Status = 'C' WHERE prtx_TransactionId = @TrxId
			END

			SET @LoopIdx = @LoopIdx + 1

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

	RETURN @Return
END
Go


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_ReplicateCompanyProductProvided]') 
            and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_ReplicateCompanyProductProvided]
GO

CREATE PROCEDURE dbo.usp_ReplicateCompanyProductProvided
  @comp_CompanyId int = null,
  @SourceId int = null,
  @ReplicateToIds varchar(max) = null,
  @UserId int = -1
AS
BEGIN

    DECLARE @Return int
    DECLARE @Msg varchar(2000)
    SET @Return = 0
    IF (@SourceId IS NULL)
        SET @SourceId = @comp_CompanyId;

    IF (@SourceId IS NULL)
    BEGIN
        SET @Msg = 'Updates Failed.  The Company Id could not be determined.'
        RAISERROR (@Msg, 16, 1)
        Return 1
    End


    -- Create a local table for the Company Ids to be replicated to
    DECLARE @tblReplicateTo TABLE(idx smallint, token varchar(30))    
    DECLARE @CompanyCnt smallint, @LoopIdx smallint
    DECLARE @token varchar(30)
    DECLARE @TrxId int
    DECLARE @Now DateTime
    SET @Now = getDate()
    DECLARE @RepCompanyId int


    INSERT INTO @tblReplicateTo SELECT * FROM dbo.Tokenize(@ReplicateToIds, ',');
    SELECT @CompanyCnt = COUNT(1) FROM @tblReplicateTo;


    -- Create a local table for the IDs that are to be replicated
    DECLARE @tblReplicateID TABLE(ndx smallint identity, ID int, Name varchar(500), DisplayOrder int)    
    DECLARE @IdNdx smallint, @IDCount int
    DECLARE @ReplicateID int, @Name varchar(500), @NextID int
	DECLARE @NewValues varchar(max);
    DECLARE @OldValues varchar(max);

    INSERT INTO @tblReplicateID (ID, Name, DisplayOrder)
         SELECT DISTINCT prcprpr_ProductProvidedID, prprpr_Name, prprpr_DisplayOrder
           FROM PRCompanyProductProvided 
                INNER JOIN PRProductProvided ON prcprpr_ProductProvidedID = prprpr_ProductProvidedID
          WHERE prcprpr_CompanyID = @SourceId
       ORDER BY prprpr_DisplayOrder;
	SELECT @IDCount = COUNT(1) FROM @tblReplicateID;

	BEGIN TRY
		BEGIN TRANSACTION

		  SET @LoopIdx = 0
		  WHILE (@LoopIdx < @CompanyCnt) BEGIN
			SET @NewValues = '';
			SET @token = null
			SELECT @token = token FROM @tblReplicateTo WHERE idx = @Loopidx


			IF (@token is not null)
			BEGIN
				-- convert the token to a company id int value
				SET @RepCompanyId = convert(int, @token)

				-- Build an "Old Value" lis
				SELECT @OldValues = COALESCE(@OldValues+',' ,'') + prprpr_Name
                  FROM PRCompanyProductProvided 
                       INNER JOIN PRProductProvided ON prcprpr_ProductProvidedID = prprpr_ProductProvidedID
                 WHERE prcprpr_CompanyID = @RepCompanyId;

				-- Process the IDs
				SET @IdNdx = 1
				WHILE (@IdNdx <= @IDCount) BEGIN
					SELECT @ReplicateID = ID,
                           @Name = Name
                      FROM @tblReplicateID 
					 WHERE ndx=@IdNdx;

					IF (NOT Exists(SELECT 1 
                                     FROM PRCompanyProductProvided
									WHERE prcprpr_CompanyID = @RepCompanyId 
									  AND prcprpr_ProductProvidedID = @ReplicateID)) BEGIN


						EXEC usp_GetNextId 'PRCompanyProductProvided', @NextID output
						INSERT INTO PRCompanyProductProvided 
							(prcprpr_CompanyProductProvidedID,prcprpr_CompanyID,prcprpr_ProductProvidedID,prcprpr_CreatedBy,prcprpr_CreatedDate,prcprpr_UpdatedBy,prcprpr_UpdatedDate,prcprpr_TimeStamp)
                        VALUES (@NextID, @RepCompanyId, @ReplicateID, @UserId, @Now, @UserId, @Now, @Now);

						IF (LEN(@NewValues) > 0) BEGIN
							SET @NewValues = @NewValues + ', ';
						END
						SET @NewValues = @NewValues + @Name;
					END

					SET @IdNdx = @IdNdx + 1
				END
			END
			

			-- Transactions are handled differently in this case.
			IF (LEN(@NewValues) > 0) BEGIN
				EXEC @TrxId = usp_CreateTransaction 
								@UserId = @UserId,
								@prtx_CompanyId = @RepCompanyId,
								@prtx_Explanation = 'Transaction created by Product Provided Replication.'

				EXEC usp_CreateTransactionDetail @TrxId, 'Products Provided', 'Update', 'prprpr_Name', @OldValues, @NewValues;
	
				UPDATE PRTransaction SET prtx_Status = 'C' WHERE prtx_TransactionId = @TrxId
			END

			SET @LoopIdx = @LoopIdx + 1

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

	RETURN @Return
END
Go


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].usp_ConvertToBranch'))
DROP PROCEDURE dbo.usp_ConvertToBranch
GO

CREATE PROCEDURE dbo.usp_ConvertToBranch 
	@SourceCompanyID int,	
	@TargetHQCompanyID int 
AS
BEGIN

	DECLARE @Type varchar(1)
	DECLARE @Count int

	SELECT @Type = comp_PRType
      FROM Company
     WHERE comp_CompanyID = @SourceCompanyID;

	IF (@Type = 'B') BEGIN
		RAISERROR ('Unable to Convert To Branch: The source company is a branch.', 16, 1)
		RETURN
	END

	SELECT @Type = comp_PRType
      FROM Company
     WHERE comp_CompanyID = @TargetHQCompanyID;

	IF (@Type = 'B') BEGIN
		RAISERROR ('Unable to Convert To Branch: The target company is a branch.', 16, 1)
		RETURN
	END

	SELECT @Count = COUNT(1)
      FROM Company
     WHERE comp_PRHQID = @SourceCompanyID
       AND comp_PRType = 'B';

	IF (@Count > 0) BEGIN
		RAISERROR ('Unable to Convert To Branch: The source company has branches.', 16, 1)
		RETURN
	END

	ALTER TABLE Company DISABLE TRIGGER ALL;

	UPDATE Company
	   SET Comp_PRTYPE = 'B', 
           comp_PRHQID = @TargetHQCompanyID
	 WHERE comp_CompanyID = @SourceCompanyID;

	ALTER TABLE Company ENABLE TRIGGER ALL;


	UPDATE PRCompanySearch
	   SET prcse_FullName = dbo.ufn_getCompanyFullName(prcse_CompanyId)
	 WHERE prcse_CompanyID = @SourceCompanyID;

END
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_GenerateARTranslation]'))
drop Procedure [dbo].[usp_GenerateARTranslation]
GO

CREATE Procedure dbo.usp_GenerateARTranslation
    @ARAgingID int,
    @UserID int = -2000,
    @CreateRecords bit = 1 
AS
BEGIN

	DECLARE @Count int, @Index int

	DECLARE @CompanyID int, @ARTranslationID int, @IndustryType varchar(40)
	DECLARE @CompanyName varchar(200), @City varchar(200), @State varchar(10), @Phone varchar(50), @ARCustomerID varchar(15)
	DECLARE @CRMCompanyName varchar(200), @CRMCity varchar(200), @CRMPhone varchar(50), @Explanation varchar(500), @NewValue varchar(500)
	DECLARE @FoundHQID int, @CityID int, @PhoneID int, @TrxID int

	--
	-- Get some basic info on who the ARAging
	-- was submitted by
	SELECT @CompanyID = praa_CompanyID,
		   @IndustryType = comp_PRIndustryType
	  FROM PRARAging 
		   INNER JOIN Company WITH (NOLOCK) ON praa_CompanyID = comp_CompanyID
	 WHERE praa_ARAgingID = @ARAgingID;


	DECLARE @tblUnmatchedCompanies table (
		ndx int identity(1,1) primary key,
		ARCustomerID varchar(15),
		CompanyName varchar(200),
		City varchar(100),
		StateAbbr varchar(10),
		ZipCode varchar(10),
		Phone varchar(50),
		CRMCompanyID int,
		CRMCompanyName varchar(200),
		CRMCity varchar(100),	
		CRMPhone varchar(50)
	)

	--
	-- Get a set of those ARAging Details that do not
	-- have a corresponding ARTranslation record
	INSERT INTO @tblUnmatchedCompanies 
	SELECT DISTINCT praad_ARCustomerId, praad_FileCompanyName, praad_FileCityName, praad_FileStateName, praad_FileZipCode, praad_PhoneNumber, null, null, null, null
	  FROM PRARAgingDetail
		   INNER JOIN PRARAging ON praad_ARAgingID = praa_ARAgingID
		   LEFT OUTER JOIN PRARTranslation ON praa_CompanyId = prar_CompanyId AND praad_ARCustomerId = prar_CustomerNumber
	 WHERE praad_ARAgingID = @ARAgingID
	   AND prar_CustomerNumber IS NULL;


	SELECT @Count = COUNT(1) FROM @tblUnmatchedCompanies;
	SET @Index = 1

	WHILE (@Index <= @Count) BEGIN


		SELECT @ARCustomerID = ARCustomerID,
			   @CompanyName = CompanyName,
			   @City = City,
			   @State = StateAbbr,
			   @Phone = Phone
		  FROM @tblUnmatchedCompanies
		 WHERE ndx = @Index;

		SET @FoundHQID = NULL;

		--
		-- First try to match on name and city
		SELECT @FoundHQID = comp_PRHQID,
			   @CRMCompanyName = comp_Name,
			   @CRMCity = prci_City
		  FROM PRCompanySearch WITH (NOLOCK)
			   INNER JOIN Company WITH (NOLOCK) ON prcse_CompanyID = comp_CompanyID
			   INNER JOIN vPRAddress on prcse_CompanyID = adli_CompanyID
		 WHERE prcse_NameAlphaOnly = dbo.ufn_GetLowerAlpha(@CompanyName)
		   AND dbo.ufn_GetLowerAlpha(prci_City) = dbo.ufn_GetLowerAlpha (@City);

		IF (@FoundHQID IS NOT NULL) BEGIN

			UPDATE @tblUnmatchedCompanies
			   SET CRMCompanyID = @FoundHQID,
				   CRMCompanyName = @CRMCompanyName,
				   CRMCity = @CRMCity
			 WHERE ndx = @Index;

		END ELSE BEGIN

			-- 
			-- Then try to match on phone number
			SELECT @FoundHQID = comp_PRHQID,
				   @CRMCompanyName = comp_Name,
				   @CRMPhone = dbo.ufn_GetLowerAlpha (phon_AreaCode + phon_Number)
			  FROM Company WITH (NOLOCK)
				   INNER JOIN vPRCompanyPhone WITH (NOLOCK) ON comp_CompanyID = plink_RecordID
			 WHERE phon_PhoneMatch = dbo.ufn_GetLowerAlpha(@Phone);

			IF (@FoundHQID IS NOT NULL) BEGIN

				UPDATE @tblUnmatchedCompanies
				   SET CRMCompanyID = @FoundHQID,
					   CRMCompanyName = @CRMCompanyName,
					   CRMPhone = @CRMPhone
				 WHERE ndx = @Index;
			END
		
		END

		IF (@CreateRecords = 1) BEGIN

			--
			-- If we didn't find a company, then create 
			-- one ourself
			IF (@FoundHQID IS NULL) BEGIN
			
				--
				-- Figure out the listing city.  If we can't,
				-- then use Unknown (-1)	
				SET @CityID = NULL
				SELECT @CityID = prci_CityID
				  FROM vPRLocation
				 WHERE dbo.ufn_GetLowerAlpha(prci_City) = dbo.ufn_GetLowerAlpha (@City)
				   AND dbo.ufn_GetLowerAlpha(prst_Abbreviation) = dbo.ufn_GetLowerAlpha (@State);

				IF (@CityID IS NULL) BEGIN
					SET @CityID = -1
				END

				EXEC usp_GetNextId 'Company', @FoundHQID output
				INSERT INTO Company (comp_CompanyId, comp_PRHQID, comp_Name, comp_PRCorrTradestyle, comp_PRBookTradestyle, comp_PRTradestyle1, comp_PRIndustryType, comp_PRListingCityID, comp_PRType, comp_PRListingStatus, comp_Source, comp_CreatedBy, comp_CreatedDate, comp_UpdatedBy, comp_UpdatedDate, comp_TimeStamp)
				VALUES (@FoundHQID, @FoundHQID, @CompanyName, @CompanyName, @CompanyName, @CompanyName, @IndustryType, @CityID, 'H', 'N2', 'P', @UserID, GETDATE(), @UserID, GETDATE(), GETDATE());

				SET @Explanation = 'Originated from AR Aging submission from BBID ' + CAST(@CompanyID as VARCHAR(10))
				SET @NewValue = @CompanyName + ' Created'

				EXECUTE @TrxID = usp_CreateTransaction 
								 @UserId = @UserId,
								 @prtx_CompanyId = @FoundHQID,
								 @prtx_Explanation = @Explanation;
				
				EXECUTE usp_CreateTransactionDetail 
							@prtx_TransactionId = @TrxID,
							@Entity = 'Company',
							@Action = 'Insert', 
							@NewValue = @NewValue, 
							@UserId =  @UserID;
				-- 
				-- If we have a phone number and it's parseable
				-- create a phone record
				IF (@Phone IS NOT NULL) BEGIN
				   IF (LEN(@Phone) = 10) BEGIN
						
						DECLARE @AreaCode varchar(5) = SUBSTRING(@Phone, 1, 3)
						DECLARE @Number varchar(5) = SUBSTRING(@Phone, 4, 7)
						EXEC usp_InsertPhone @FoundHQID, 5, 'P', '1', @AreaCode, @Number, 'Phone', NULL, NULL, NULL, NULL, NULL, 'Y', NULL, NULL, @UserID

						/*
						EXEC usp_GetNextId 'Phone', @PhoneID output
						INSERT INTO PHONE (Phon_PhoneId, Phon_CompanyID, Phon_Type, Phon_CountryCode, Phon_AreaCode, Phon_Number, phon_PRPreferredInternal, phon_PRDescription, phon_PRSequence, phon_CreatedBy, phon_CreatedDate, phon_UpdatedBy, phon_UpdatedDate, phon_TimeStamp)
						VALUES(@PhoneID, @FoundHQID, 'P', '1', SUBSTRING(@Phone, 1, 3), SUBSTRING(@Phone, 4, 7), 'Y', 'Phone', 1, @UserID, GETDATE(), @UserID, GETDATE(), GETDATE());
						*/
					END
				END 

				UPDATE PRTransaction 
				   SET prtx_Status = 'C' 
				 WHERE prtx_TransactionId = @TrxID;
			END

			--	
			-- Finnally, add a PRARTranslation record
			EXEC usp_GetNextId 'PRARTranslation', @ARTranslationID output
			INSERT INTO PRARTranslation (prar_ARTranslationId, prar_CompanyId, prar_CustomerNumber, prar_PRCoCompanyId, prar_CreatedBy, prar_CreatedDate, prar_UpdatedBy, prar_UpdatedDate, prar_TimeStamp)
			VALUES (@ARTranslationID, @CompanyID, @ARCustomerID, @FoundHQID, @UserID, GETDATE(), @UserID, GETDATE(), GETDATE());

		END

		SET @Index = @Index + 1

	END

	SELECT COUNT(1) As Total,
		   COUNT(CRMCity) As Name_City_Matches, 
		   COUNT(CRMPhone) As Phone_Matches,
		   COUNT(1) - COUNT(CRMCity) - COUNT(CRMPhone) As Unmatched
	  FROM @tblUnmatchedCompanies;

	SELECT * FROM @tblUnmatchedCompanies;
END
Go




IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].usp_SetCreditSheetMarketingMessage'))
     DROP PROCEDURE dbo.usp_SetCreditSheetMarketingMessage
GO

CREATE PROCEDURE dbo.usp_SetCreditSheetMarketingMessage
	@Industry varchar(40) = 'P',	
	@Date datetime = null  -- This parameter allows us to override "Today"
AS
BEGIN

	IF @Date IS NULL BEGIN
		SET @Date = GETDATE()
	END

	DECLARE @Header varchar(100)
	DECLARE @Msg  varchar(500)

	-- Drop the time portion off of the specified date
	DECLARE @Today date = @Date

	IF (@Industry = 'P') BEGIN
		SET @Msg =
		  CASE @Today

			WHEN '12/18/2013' 
				THEN 'CREDIT SHEET CHANGE: Starting Friday, December 27, the Credit Sheet will be delivered to you each Friday, rather than Wednesday. This change enables us to deliver all of the current week''s updates to you, without delay. Thank you for using Blue Book Services to make safe and profitable business decisions.'
			WHEN '12/27/2013' 
				THEN 'CREDIT SHEET CHANGE: The Credit Sheet is now delivered to you every Friday, rather than Wednesday. This change enables us to deliver all of the current week''s updates to you, without delay. Thank you for using Blue Book Services to make safe and profitable business decisions.'
			WHEN '1/3/2014' 
				THEN 'CREDIT SHEET CHANGE: The Credit Sheet is now delivered to you every Friday, rather than Wednesday. This change enables us to deliver all of the current week''s updates to you, without delay. Thank you for using Blue Book Services to make safe and profitable business decisions.'
			WHEN '1/10/2014' 
				THEN 'CREDIT SHEET CHANGE: The Credit Sheet is now delivered to you every Friday, rather than Wednesday. This change enables us to deliver all of the current week''s updates to you, without delay. Thank you for using Blue Book Services to make safe and profitable business decisions.'
			WHEN '1/17/2014' 
				THEN 'Please Act Now For The Upcoming Deadline!  The next edition of the hardbound print Blue Book closes in 2 weeks. Ensure up-to-date listing information by contacting a Listing Specialist today at listing@bluebookservices.com with your changes.'
			WHEN '2/7/2014' 
				THEN 'All changes reported after this issue were received after the publication deadline, therefore will not be included in the upcoming print Blue Book.'

			WHEN '3/5/2014' 
				THEN 'The Blue Book has instituted the new Rating Key Numeral (159) which means, "Reported posted a USDA surety bond."  The numeral will reflect situations in which PACA requires a bond be posted by a licensee where the firm or one of its principals has been involved in bankruptcy, or when a PACA licensee employs an individual who is under PACA employment restrictions. The numeral will be reported on an interim basis for a period up to, but no longer than 6 months.'

			WHEN '3/7/2014' 
				THEN 'The Blue Book has instituted the new Rating Key Numeral (159) which means, "Reported posted a USDA surety bond."  The numeral will reflect situations in which PACA requires a bond be posted by a licensee where the firm or one of its principals has been involved in bankruptcy, or when a PACA licensee employs an individual who is under PACA employment restrictions. The numeral will be reported on an interim basis for a period up to, but no longer than 6 months.'

			WHEN '7/18/2014' 
				THEN 'Please Act Now For The Upcoming Deadline!  The next edition of the hardbound print Blue Book closes in 2 weeks. Ensure up-to-date listing information by contacting a Listing Specialist today at listing@bluebookservices.com with your changes.'
			WHEN '8/8/2014' 
				THEN 'All changes reported after this issue were received after the publication deadline, therefore will not be included in the upcoming print Blue Book.'

			WHEN '1/16/2015' 
				THEN 'Please Act Now For The Upcoming Deadline!  The next edition of the hardbound print Blue Book closes in 2 weeks. Ensure up-to-date listing information by contacting a Listing Specialist today at listing@bluebookservices.com with your changes.'

			WHEN '2/6/2015' 
				THEN 'All changes reported after this issue were received after the publication deadline, therefore will not be included in the upcoming print Blue Book.'

			WHEN '7/17/2015' 
				THEN 'Please Act Now For The Upcoming Deadline!  The next edition of the hardbound print Blue Book closes in 2 weeks. Ensure up-to-date listing information by contacting a Listing Specialist today at listing@bluebookservices.com with your changes.'

			WHEN '8/7/2015' 
				THEN 'All changes reported after this issue were received after the publication deadline, therefore will not be included in the upcoming print Blue Book.'


			ELSE 
				NULL
		END
	END

	IF (@Industry = 'L') BEGIN
		SET @Header =
		  CASE @Today
			WHEN '1/3/2014' 
				THEN 'Announcement: 2014 Membership Pricing'
			ELSE 
				NULL
		END

		SET @Msg =
		  CASE @Today
			WHEN '1/3/2014' 
				THEN 'For 2014, Blue Book Memberships will have a modest price increase; less than 2 cents a day per user. Please visit the News Center on BBOS or call for full details. Thank you for using Blue Book Services to make safe and profitable business decisions.'
			ELSE 
				NULL
		END
	END

	UPDATE Custom_Captions
	   SET capt_us = @Msg
	 WHERE capt_family = 'CreditSheetMarketing'
	   AND capt_code = @Industry + 'Msg';

	UPDATE Custom_Captions
	   SET capt_us = @Header
	 WHERE capt_family = 'CreditSheetMarketing'
	   AND capt_code = @Industry + 'Header';
END
Go

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].usp_ProcessExpiredTrialLicenses'))
     DROP PROCEDURE dbo.usp_ProcessExpiredTrialLicenses
GO

CREATE PROCEDURE dbo.usp_ProcessExpiredTrialLicenses
AS
BEGIN


	UPDATE PRWebUser
	   SET prwu_TrialExpirationDate = NULL,
		   prwu_AccessLevel = prwu_PreviousAccessLevel,
		   prwu_ServiceCode = prwu_PreviousServiceCode,
		   prwu_PreviousAccessLevel = NULL,
		   prwu_PreviousServiceCode = NULL,
		   prwu_Disabled = CASE WHEN prwu_PreviousServiceCode IS NULL THEN 'Y' ELSE NULL END
	 WHERE prwu_TrialExpirationDate < GETDATE();

END
Go


/**
 Processes all mass investigations.
**/
CREATE OR ALTER PROCEDURE dbo.usp_ProcessMassInvestigations
AS 
BEGIN

	DECLARE @LastBBScoreRunDate DateTime
	DECLARE @LastMassInvestigationRunDate DateTime
	DECLARE @RecordCount int
    DECLARE @ndx int

	--SET @LastBBScoreRunDate = dbo.ufn_GetCustomCaptionValue('LastBBScoreRunDate', 'LastBBScoreRunDate', DEFAULT)
	SELECT @LastBBScoreRunDate = capt_code FROM Custom_Captions WHERE capt_Family = 'LastBBScoreRunDate'
	SET @LastMassInvestigationRunDate = dbo.ufn_GetCustomCaptionValue('LastMassInvestigationRunDate', 'LastMassInvestigationRunDate', DEFAULT)
 
	IF @LastBBScoreRunDate < @LastMassInvestigationRunDate 
	BEGIN
		RETURN
	END

	DECLARE @MyTable table (
		ndx int identity(1,1) primary key,
        CompanyID int,
        RequiredTradeReportCount int
      )

    -- Get all current PRBBScore records and insert them in a temp table variable.
    INSERT INTO @MyTable (CompanyID, RequiredTradeReportCount)
	SELECT comp_CompanyID, CASE prbs_RequiredReportCount WHEN 0 THEN 5 ELSE ISNULL(prbs_RequiredReportCount, 5) END prbs_RequiredReportCount
		FROM Company WITH (NOLOCK)
		    LEFT OUTER JOIN PRBBScore WITH (NOLOCK) ON prbs_CompanyId = comp_CompanyID AND prbs_current = 'Y' AND prbs_RequiredReportCount > 0
	WHERE comp_PRListingStatus IN ('L','H')
		AND comp_PRIndustryType IN ('P', 'T')
		AND comp_PRType='H'
		AND comp_PRLocalSource IS NULL
    ORDER BY comp_CompanyID

    SET @RecordCount = @@ROWCOUNT
    SET @ndx = 1

    DECLARE @CompanyID int, @RequiredTradeReportCount int

    -- Loop through all temp records and execute usp_CreateAutoTES for each one.
    WHILE (@ndx <= @RecordCount)
	BEGIN
		SET @CompanyID = null
		SET @RequiredTradeReportCount = NULL

        SELECT 
			@CompanyID = CompanyID,
			@RequiredTradeReportCount = RequiredTradeReportCount
		FROM @MyTable
		WHERE ndx = @ndx;

        EXEC usp_CreateAutoTES @CompanyID, @RequiredTradeReportCount, 1, 'BBScore'          

		SET @ndx = @ndx + 1
	END

	DECLARE @LastDate varchar(50)
	SET @LastDate = GETDATE()

    -- Update the LastMassInvestigationRunDate custom caption to the current datetime
	UPDATE Custom_Captions
	   SET capt_us = @LastDate
	 WHERE capt_family = 'LastMassInvestigationRunDate'
	   AND capt_code = 'LastMassInvestigationRunDate'

END
Go


/**
 usp_SendMassInvestigations
**/
If Exists (Select name from sysobjects where name = 'usp_SendMassInvestigations' and type='P') 
	Drop Procedure dbo.usp_SendMassInvestigations
Go

CREATE PROCEDURE dbo.usp_SendMassInvestigations
AS 
BEGIN
	--
	--  Before we do anything, make
	--  sure our TES data is cleanded.
	--
	EXEC usp_CleanupTESRequests

	-- Set the SentCode appropriately
	UPDATE PRTESRequest
	   SET prtesr_SentMethod = 'B',
	       prtesr_SentDateTime = prtesr_CreatedDate
	  FROM PRAttentionLine 
	 WHERE prtesr_ResponderCompanyID = prattn_CompanyID 
	   AND prtesr_SentMethod IS NULL
	   AND prattn_ItemCode = 'TES-E' 
	   AND prattn_BBOSOnly = 'Y'
	   AND prattn_Disabled IS NULL;

	UPDATE PRTESRequest
	   SET prtesr_SentMethod = 'E'
	  FROM PRAttentionLine 
	 WHERE prtesr_ResponderCompanyID = prattn_CompanyID 
	   AND prtesr_SentMethod IS NULL
	   AND prattn_ItemCode = 'TES-E' 
	   AND prattn_EMailID IS NOT NULL
	   AND prattn_BBOSOnly IS NULL
	   AND prattn_Disabled IS NULL;

END
Go




/**
 usp_SendTESEmail
**/
DROP PROCEDURE IF EXISTS dbo.usp_SendTESEmail
Go

CREATE PROCEDURE [dbo].[usp_SendTESEmail]
AS
BEGIN
	/*
		Almost all of this logic is duplicated in usp_SendVITESEmail
	*/
	DECLARE @ResponderNdx int,
			@ResponderCompanyID int,
			@ResponderPersonID int,
			@Addressee varchar(100),
			@DeliveryAddress varchar(100),
			@ResponderRowCount int,
			@CommunicationLanguage varchar(10)
	SET @ResponderNdx = 0
	DECLARE @TempResponders table (
            ID int identity(1,1) PRIMARY KEY,
            ResponderCompanyID int,
			ResponderPersonID int,
            Addressee varchar(100),
            DeliveryAddress varchar(100),
			HasSecondRequest varchar(1),
			CommunicationLanguage varchar(1),
			IndustryType varchar(50)
			)
	INSERT INTO @TempResponders (
        ResponderCompanyID,
		ResponderPersonID,
        Addressee,
        DeliveryAddress,
		CommunicationLanguage,
		IndustryType)
	SELECT DISTINCT
	   prtesr_ResponderCompanyID,
	   ISNULL(prtesr_OverridePersonID, prattn_PersonID),
	   ISNULL(ISNULL(prtesr_OverrideCustomAttention, dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_MiddleName, pers_PRNickName1, pers_Suffix)), Addressee) As Addressee,
	   ISNULL(prtesr_OverrideAddress, DeliveryAddress) As DeliveryAddress,
	   comp_PRCommunicationLanguage,
	   comp_PRIndustryType
	FROM PRTESRequest WITH (NOLOCK)
	    INNER JOIN Company WITH (NOLOCK) ON prtesr_ResponderCompanyID = comp_CompanyID
		INNER JOIN vPRCompanyAttentionLine ON prtesr_ResponderCompanyID = prattn_CompanyID
		LEFT OUTER JOIN Person WITH (NOLOCK) ON prtesr_OverridePersonID = pers_PersonID
	WHERE prattn_ItemCode = 'TES-E'
		AND prtesr_SentMethod = 'E'
		AND prtesr_SentDateTime IS NULL
		AND prtesr_TESFormID IS NULL
		AND ISNULL(prtesr_OverrideAddress, DeliveryAddress) IS NOT NULL
		AND ISNULL(prtesr_OverrideAddress, DeliveryAddress) <> '';
	SET @ResponderRowCount = @@ROWCOUNT

	--
	--  Now that we have a unqiue list of responders,
	--  see if any of the TES requests are second requests.
	UPDATE @TempResponders
	   SET HasSecondRequest = 'Y'
	FROM PRTESRequest WITH (NOLOCK)
		INNER JOIN vPRCompanyAttentionLine ON prtesr_ResponderCompanyID = prattn_CompanyID
		LEFT OUTER JOIN Person WITH (NOLOCK) ON prtesr_OverridePersonID = pers_PersonID
	WHERE prattn_ItemCode = 'TES-E'
		AND ISNULL(prtesr_OverrideAddress, vPRCompanyAttentionLine.DeliveryAddress) IS NOT NULL
		AND ISNULL(prtesr_OverrideAddress, vPRCompanyAttentionLine.DeliveryAddress) <> ''
		AND prtesr_SentMethod = 'E'
		AND prtesr_SentDateTime IS NULL
		AND prtesr_TESFormID IS NULL
		AND ResponderCompanyID = prtesr_ResponderCompanyID
		AND prtesr_SecondRequest = 'Y';
    DECLARE @Subject varchar(100)
    DECLARE @Body varchar(max)
    DECLARE @ResponseURL varchar(500)
	DECLARE @HasSecondRequest varchar(1)
    DECLARE @Culture varchar(100)
	DECLARE @IndustryType varchar(50)
	DECLARE @SubjectEnglish varchar(100)
    DECLARE @BodyEnglish varchar(max)
	--SET @SubjectEnglish = dbo.ufn_GetCustomCaptionValue('TESEmail', 'Subject', 'en-us')
    SET @BodyEnglish = dbo.ufn_GetCustomCaptionValue('TESEmail', 'Body', 'en-us')
	DECLARE @SubjectSpanish varchar(100)
    DECLARE @BodySpanish varchar(max)
	--SET @SubjectSpanish = dbo.ufn_GetCustomCaptionValue('TESEmail', 'Subject', 'es-mx')
    SET @BodySpanish = dbo.ufn_GetCustomCaptionValue('TESEmail', 'Body', 'es-mx')
	SET @ResponseURL = dbo.ufn_ConcatURL(dbo.ufn_GetCustomCaptionValue('BBOS', 'URL', 'en-us'),
                                         dbo.ufn_GetCustomCaptionValue('TESEmail', 'ResponseURL', 'en-us'))
    DECLARE @Msg varchar(max)

    WHILE (@ResponderNdx < @ResponderRowCount) BEGIN
    	DECLARE @SubjectCompanyCount int
		SET @ResponderNdx = @ResponderNdx + 1
        -- Go get the next responder
        SELECT
                @ResponderCompanyID = ResponderCompanyID,
				@ResponderPersonID = ResponderPersonID,
                @Addressee = CASE WHEN Addressee IS NULL THEN '' ELSE Addressee END,
                @DeliveryAddress = DeliveryAddress,
				@CommunicationLanguage = CommunicationLanguage,
				@HasSecondRequest = HasSecondRequest,
				@IndustryType = IndustryType
        FROM @TempResponders
        WHERE ID = @ResponderNdx;
        DECLARE @Guid varchar(50)
        SET @Guid= REPLACE(NEWID(), '-', '')
        DECLARE @TESFormId int
        DECLARE @SentDateTime datetime
        SET @SentDateTime = getDate() 

        INSERT INTO PRTESForm
        (
			prtf_CompanyId,
            prtf_Key,
            prtf_ExpirationDateTime,
            prtf_SentDateTime,
            prtf_SentMethod,
			prtf_CreatedBy,
			prtf_CreatedDate,
			prtf_UpdatedBy,
			prtf_UpdatedDate,
			prtf_Timestamp
        )
        VALUES
        (
            @ResponderCompanyID,
            @Guid,
            DATEADD(day, 45, getDate()),
            @SentDateTime,
            'E',
			-1,
			@SentDateTime,
			-1,
			@SentDateTime,
			@SentDateTime
		)
        SET @TESFormId = SCOPE_IDENTITY()
  		UPDATE PRTESRequest
        SET prtesr_TESFormID = @TESFormId,
            prtesr_SentDateTime = @SentDateTime
        WHERE prtesr_ResponderCompanyID = @ResponderCompanyID
        AND prtesr_SentMethod = 'E'
		AND prtesr_SentDateTime IS NULL
        AND prtesr_TESFormID IS NULL;
------------Defect 5730 START
		SET @SubjectCompanyCount=@@ROWCOUNT
		DECLARE @FirstCompanyName nvarchar(104)
		DECLARE @CompanyListMsg varchar(MAX)
		SET @CompanyListMsg = '<ul>'
		DECLARE @TESNdx int,
				@TESCompanyID int,
				@TESPRBookTradestyle varchar(500),
				@TESRatingLine varchar(100),
				@TESRowCount int
		DECLARE @TempTESRequests table (
			ID int,
			comp_CompanyID int,
			comp_PRBookTradestyle varchar(500),
			prra_RatingLine varchar(100)
		)
		
		DELETE FROM @TempTESRequests --IMPORTANT as TABLE doesn't reset on each loop item
		
		INSERT INTO @TempTESRequests (
				ID,
				comp_CompanyID,
				comp_PRBookTradestyle,
				prra_RatingLine)
		SELECT  
			ROW_NUMBER() OVER (order by cl.comp_PRBookTradestyle),
			cl.comp_CompanyID, cl.comp_PRBookTradestyle, prra_RatingLine
				FROM PRTESRequest tr WITH (NOLOCK)  
					INNER JOIN Company c WITH (NOLOCK)  ON c.Comp_CompanyId = tr.prtesr_SubjectCompanyID 
					LEFT OUTER JOIN vPRCurrentRating WITH (NOLOCK) ON prra_CompanyId = comp_CompanyID
					INNER JOIN vPRBBOSCompanyList cl ON tr.prtesr_SubjectCompanyID = cl.comp_CompanyID 
					INNER JOIN PRTESForm f WITH (NOLOCK)  ON f.prtf_TESFormId = tr.prtesr_TESFormID 
					WHERE f.prtf_Key = @Guid
						AND tr.prtesr_Received IS NULL
					ORDER BY cl.comp_PRBookTradestyle
		SET @TESRowCount = @@ROWCOUNT
		SELECT @FirstCompanyName = comp_PRBookTradestyle FROM @TempTESRequests WHERE ID=1
		SET @TESNdx = 0
		WHILE (@TESNdx < @TESRowCount) BEGIN
			SET @TESNdx = @TESNdx + 1
			-- Go get the next TES Company
			SELECT	@TESCompanyID = comp_CompanyID,
					@TESPRBookTradestyle=comp_PRBookTradestyle,
					@TESRatingLine=prra_RatingLine
			FROM @TempTESRequests 
			WHERE ID = @TESNdx;

		SET @CompanyListMsg = @CompanyListMsg + '<li>' + ISNULL(@TESPRBookTradestyle,'')
		IF(@CompanyListMsg IS NOT NULL) BEGIN
			SET @CompanyListMsg = @CompanyListMsg + '  -  ' + ISNULL(@TESRatingLine,'')
		END
		SET @CompanyListMsg = @CompanyListMsg + '</li>'
		END
		IF @CompanyListMsg IS NULL BEGIN
			SET @CompanyListMsg = '<ul><li>' + @FirstCompanyName + '</li></ul>'
		END ELSE BEGIN
			SET @CompanyListMsg = @CompanyListMsg + '</ul>'
		END
		IF (@SubjectCompanyCount > 1) BEGIN
			IF (@CommunicationLanguage = 'E') BEGIN
				SET @SubjectEnglish = dbo.ufn_GetCustomCaptionValue('TESEmail', 'Subject_Long', 'en-us') -- 'Rate {0} and {1} other {2}.  Response needed.'
				SET @SubjectEnglish = REPLACE(@SubjectEnglish, '{0}', @FirstCompanyName )
				SET @SubjectEnglish = REPLACE(@SubjectEnglish, '{1}', @SubjectCompanyCount-1)
				IF (@SubjectCompanyCount=2) BEGIN 
					SET @SubjectEnglish = REPLACE(@SubjectEnglish, '{2}', 'company')
				END ELSE BEGIN
					SET @SubjectEnglish = REPLACE(@SubjectEnglish, '{2}', 'companies')
				END
			END ELSE BEGIN
				SET @SubjectSpanish = dbo.ufn_GetCustomCaptionValue('TESEmail', 'Subject_Long', 'es-mx') -- 'Rate {0} and {1} other {2}.  Response needed.'
				SET @SubjectSpanish = REPLACE(@SubjectSpanish, '{0}', @FirstCompanyName )
				SET @SubjectSpanish = REPLACE(@SubjectSpanish, '{1}', @SubjectCompanyCount-1)
				IF (@SubjectCompanyCount=2) BEGIN 
					SET @SubjectSpanish = REPLACE(@SubjectSpanish, '{2}', 'compañía')
				END ELSE BEGIN
					SET @SubjectSpanish = REPLACE(@SubjectSpanish, '{2}', 'compañías')
				END
			END
		END 
		ELSE BEGIN
			--Trim off trailing period (if it's there)
			IF(RIGHT(@FirstCompanyName,1)='.') BEGIN
				SELECT @FirstCompanyName = LEFT(@FirstCompanyName, LEN(@FirstCompanyName)-1)
			END
			IF (@CommunicationLanguage = 'E') BEGIN
				SET @SubjectEnglish = dbo.ufn_GetCustomCaptionValue('TESEmail', 'Subject_Short', 'en-us')  -- 'Rate {0}.  Response needed.'
				SET @SubjectEnglish = REPLACE(@SubjectEnglish, '{0}', @FirstCompanyName )
			END ELSE BEGIN
				SET @SubjectSpanish = dbo.ufn_GetCustomCaptionValue('TESEmail', 'Subject_Short', 'es-mx') -- 'Rate {0}.  Response needed.'
				SET @SubjectSpanish = REPLACE(@SubjectSpanish, '{0}', @FirstCompanyName )
			END
		END
------------Defect 5730 END
		IF (@CommunicationLanguage = 'E') BEGIN
	        SET @Msg = @BodyEnglish
			SET @Subject = @SubjectEnglish
			SET @Culture = 'en-us'
		END ELSE BEGIN
			SET @Msg = @BodySpanish
			SET @Subject = @SubjectSpanish
			SET @Culture = 'es-mx'
		END

		--Defect 4113 email images
		DECLARE @TopImage varchar(5000)
		DECLARE @BottomImage varchar(5000)
		SET @TopImage = dbo.ufn_GetEmailImageHTML('3','T',@IndustryType)
		SET @BottomImage = dbo.ufn_GetEmailImageHTML('3','B',@IndustryType)
		SET @Msg = @TopImage + @Msg + @BottomImage --Defect 4113 include optional email header and footer images

        SET @Msg = REPLACE(@Msg,'{0}', @Addressee)
        SET @Msg = REPLACE(@Msg,'{1}', REPLACE(@ResponseURL,'{0}', @Guid))
		IF (@HasSecondRequest = 'Y') BEGIN
			IF(@CommunicationLanguage = 'E') BEGIN
				SET @Msg = REPLACE(@Msg,'{2}', '<p style="color:red;text-align:center;">There are second trade survey requests pending!</p>' + @CompanyListMsg)
			END ELSE BEGIN
				SET @Msg = REPLACE(@Msg,'{2}', '<p style="color:red;text-align:center;">Hay segundas solicitudes de encuestas comerciales pendientes!</p>' + @CompanyListMsg)
			END
		END ELSE BEGIN
			SET @Msg = REPLACE(@Msg,'{2}', @CompanyListMsg)
		END
		IF (@CommunicationLanguage = 'E') BEGIN
			IF (@SubjectCompanyCount=1) BEGIN 
				SET @Msg = REPLACE(@Msg,'{3}', 'Rate Company')
			END ELSE BEGIN
				SET @Msg = REPLACE(@Msg,'{3}', 'Rate Companies')
			END
		END ELSE BEGIN
			IF (@SubjectCompanyCount=1) BEGIN 
				SET @Msg = REPLACE(@Msg,'{3}', 'Calificar Empresa')
			END ELSE BEGIN
				SET @Msg = REPLACE(@Msg,'{3}', 'Calificar Empresas')
			END
		END
		--Possibly show a 2nd Rate Companies button if there are more than 5 companies in the list
		IF(@SubjectCompanyCount>5) BEGIN 
			SET @Msg = REPLACE(@Msg,'{4}', '')
		END ELSE BEGIN
			SET @Msg = REPLACE(@Msg,'{4}', 'none')
		END
		SET @Msg = dbo.ufn_GetFormattedEmail2(@ResponderCompanyID, 0, 0, @Subject, @Msg, @Addressee, @Culture)

        EXEC usp_CreateEmail
            @CreatorUserID = -1,
            @To = @DeliveryAddress,
			@RelatedCompanyId = @ResponderCompanyID,
			@RelatedPersonId = @ResponderPersonID,
            @Subject = @Subject,
            @Content = @Msg,
            @Action = 'EmailOut',
            @DoNotRecordCommunication = 1,
            @Content_Format = 'HTML',
            @Source = 'Send TES Email'
      END
END
GO


If Exists (Select name from sysobjects where name = 'usp_SendVITESEmail' and type='P') 
	Drop Procedure dbo.usp_SendVITESEmail
Go

CREATE PROCEDURE [dbo].[usp_SendVITESEmail]
	@TESIDList varchar(5000)
AS
BEGIN

	/*
		This is a duplicate of usp_SendTESEmail, but allows
		us to target speciic TES records.  A bit of a hack.
	*/
	DECLARE @ResponderNdx int,
			@ResponderCompanyID int,
			@ResponderPersonID int,
			@Addressee varchar(100),
			@DeliveryAddress varchar(100),
			@ResponderRowCount int
	SET @ResponderNdx = 0
	DECLARE @TempResponders table (
            ID int identity(1,1) PRIMARY KEY,
            ResponderCompanyID int,
			ResponderPersonID int,
            Addressee varchar(100),
            DeliveryAddress varchar(100),
			HasSecondRequest varchar(1),
			CommunicationLanguage varchar(1),
			IndustryType varchar(50)
			)
	INSERT INTO @TempResponders (
        ResponderCompanyID,
		ResponderPersonID,
        Addressee,
        DeliveryAddress,
		CommunicationLanguage,
		IndustryType)
	SELECT DISTINCT
	   prtesr_ResponderCompanyID,
	   ISNULL(prtesr_OverridePersonID, prattn_PersonID),
	   ISNULL(ISNULL(prtesr_OverrideCustomAttention, dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_MiddleName, pers_PRNickName1, pers_Suffix)), Addressee) As Addressee,
	   ISNULL(prtesr_OverrideAddress, DeliveryAddress) As DeliveryAddress,
	   comp_PRCommunicationLanguage,
	   comp_PRIndustryType
	FROM PRTESRequest WITH (NOLOCK)
		INNER JOIN Company WITH (NOLOCK) ON prtesr_ResponderCompanyID = comp_CompanyID
		INNER JOIN vPRCompanyAttentionLine ON prtesr_ResponderCompanyID = prattn_CompanyID
		LEFT OUTER JOIN Person WITH (NOLOCK) ON prtesr_OverridePersonID = pers_PersonID
	WHERE prattn_ItemCode = 'TES-E'
		AND prtesr_SentMethod = 'E'
		AND prtesr_SentDateTime IS NULL
		AND prtesr_TESFormID IS NULL
		AND ISNULL(prtesr_OverrideAddress, DeliveryAddress) IS NOT NULL
		AND ISNULL(prtesr_OverrideAddress, DeliveryAddress) <> ''
		AND prtesr_TESRequestID IN (SELECT value FROM dbo.Tokenize(@TESIDList, ',') WHERE value <> '');
	SET @ResponderRowCount = @@ROWCOUNT
	--
	--  Now that we have a unqiue list of responders,
	--  see if any of the TES requests are second requests.
	UPDATE @TempResponders
	   SET HasSecondRequest = 'Y'
	FROM PRTESRequest WITH (NOLOCK)
		INNER JOIN vPRCompanyAttentionLine ON prtesr_ResponderCompanyID = prattn_CompanyID
		LEFT OUTER JOIN Person WITH (NOLOCK) ON prtesr_OverridePersonID = pers_PersonID
	WHERE prattn_ItemCode = 'TES-E'
		AND ISNULL(prtesr_OverrideAddress, vPRCompanyAttentionLine.DeliveryAddress) IS NOT NULL
		AND ISNULL(prtesr_OverrideAddress, vPRCompanyAttentionLine.DeliveryAddress) <> ''
		AND prtesr_SentMethod = 'E'
		AND prtesr_SentDateTime IS NULL
		AND prtesr_TESFormID IS NULL
		AND ResponderCompanyID = prtesr_ResponderCompanyID
		AND prtesr_SecondRequest = 'Y';
    DECLARE @Subject varchar(100)
    DECLARE @Body varchar(max)
    DECLARE @ResponseURL varchar(500)
	DECLARE @HasSecondRequest varchar(1)

    DECLARE @Culture varchar(10) = 'en-us'
	DECLARE @comp_PRCommunicationLanguage varchar(5)
	SELECT @comp_PRCommunicationLanguage=comp_PRCommunicationLanguage FROM Company WHERE comp_CompanyId = @ResponderCompanyID
	IF @comp_PRCommunicationLanguage='S' BEGIN SET @Culture = 'es-mx' END

    SET @Subject = dbo.ufn_GetCustomCaptionValue('TESEmail', 'Subject', @Culture)
    SET @Body = dbo.ufn_GetCustomCaptionValue('TESEmail', 'Body', @Culture)
    SET @ResponseURL = dbo.ufn_ConcatURL(dbo.ufn_GetCustomCaptionValue('BBOS', 'URL', @Culture),
                                         dbo.ufn_GetCustomCaptionValue('TESEmail', 'ResponseURL', @Culture))
	DECLARE @IndustryType varchar(50)
    DECLARE @Msg varchar(max)
    WHILE (@ResponderNdx < @ResponderRowCount) 
		BEGIN
			SET @ResponderNdx = @ResponderNdx + 1
            -- Go get the next responder
            SELECT
                  @ResponderCompanyID = ResponderCompanyID,
				  @ResponderPersonID = ResponderPersonID,
                  @Addressee = CASE WHEN Addressee IS NULL THEN '' ELSE Addressee END,
                  @DeliveryAddress = DeliveryAddress,
				  @HasSecondRequest = HasSecondRequest,
				  @IndustryType = IndustryType
            FROM @TempResponders
            WHERE ID = @ResponderNdx;
            DECLARE @Guid varchar(50)
            SET @Guid= REPLACE(NEWID(), '-', '')
            DECLARE @TESFormId int
            DECLARE @SentDateTime datetime
            SET @SentDateTime = getDate()            
            INSERT INTO PRTESForm
            (
				prtf_CompanyId,
                prtf_Key,
                prtf_ExpirationDateTime,
                prtf_SentDateTime,
                prtf_SentMethod,
				prtf_CreatedBy,
				prtf_CreatedDate,
				prtf_UpdatedBy,
				prtf_UpdatedDate,
				prtf_Timestamp
            )
            VALUES
            (
                @ResponderCompanyID,
                @Guid,
                DATEADD(day, 45, getDate()),
                @SentDateTime,
                'E',
				-1,
				@SentDateTime,
				-1,
				@SentDateTime,
				@SentDateTime
			)
            SET @TESFormId = SCOPE_IDENTITY()
            UPDATE PRTESRequest
            SET prtesr_TESFormID = @TESFormId,
                prtesr_SentDateTime = @SentDateTime
            WHERE prtesr_ResponderCompanyID = @ResponderCompanyID
            AND prtesr_SentMethod = 'E'
			AND prtesr_SentDateTime IS NULL
            AND prtesr_TESFormID IS NULL;
            SET @Msg = @Body

			--Defect 4113 email images
			DECLARE @TopImage varchar(5000)
			DECLARE @BottomImage varchar(5000)
			SET @TopImage = dbo.ufn_GetEmailImageHTML('3','T',@IndustryType)
			SET @BottomImage = dbo.ufn_GetEmailImageHTML('3','B',@IndustryType)
			SET @Msg = @TopImage + @Msg + @BottomImage --Defect 4113 include optional email header and footer images


            SET @Msg = REPLACE(@Msg,'{0}', @Addressee)
            SET @Msg = REPLACE(@Msg,'{1}', REPLACE(@ResponseURL,'{0}', @Guid))
			IF (@HasSecondRequest = 'Y') BEGIN
				SET @Msg = REPLACE(@Msg,'{2}', '<p style="color:red;text-align:center;">There are second trade survey requests pending!</p>')
			END ELSE BEGIN
				SET @Msg = REPLACE(@Msg,'{2}', '')
			END
			SET @Msg = dbo.ufn_GetFormattedEmail(@ResponderCompanyID, 0, 0, @Subject, @Msg, @Addressee)
            EXEC usp_CreateEmail
                @CreatorUserID = -1,
                @To = @DeliveryAddress,
				@RelatedCompanyId = @ResponderCompanyID,
				@RelatedPersonId = @ResponderPersonID,
                @Subject = @Subject,
                @Content = @Msg,
                @Action = 'EmailOut',
                @DoNotRecordCommunication = 1,
                @Content_Format = 'HTML',
                @Source = 'Send TES Email'
      END
END
Go


/**
 usp_ProcessVerbalInvestigations
**/
If Exists (Select name from sysobjects where name = 'usp_ProcessVerbalInvestigations' and type='P')
    Drop Procedure dbo.usp_ProcessVerbalInvestigations
Go

CREATE PROCEDURE dbo.usp_ProcessVerbalInvestigations
	@TradeReportID int
AS
BEGIN
	DECLARE @VerbalInvestigationIndex int
	DECLARE @VerbalInvestigationCount int
	DECLARE @VerbalInvestigationID int
	DECLARE @UserEmailAddress nchar(255)
	DECLARE @CompanyName nvarchar(500)
	DECLARE @InvestigationName varchar(100)
	DECLARE @TargetNumberOfPayReports int
	DECLARE @TargetNumberOfIntegrityReports int
	DECLARE @IntegrityResponseCount int
	DECLARE @PayRatingResponseCount int
	DECLARE @Subject varchar(100)
	DECLARE @Body varchar(max)
	DECLARE @Msg varchar(max)


	SELECT 
		@VerbalInvestigationID = prvi.prvi_VerbalInvestigationID,
		@InvestigationName = prvi.prvi_InvestigationName,
		@TargetNumberOfPayReports  = ISNULL(prvi.prvi_TargetNumberOfPayReports, 0),
		@TargetNumberOfIntegrityReports = ISNULL(prvi.prvi_TargetNumberOfIntegrityReports, 0),
		@UserEmailAddress = u.User_EmailAddress,
		@CompanyName = c.prcse_FullName
	FROM PRTradeReport tr WITH (NOLOCK)
		INNER JOIN PRTESRequest tes WITH (NOLOCK) ON tes.prtesr_TESRequestID = tr.prtr_TESRequestID
		INNER JOIN PRVerbalInvestigation prvi WITH (NOLOCK) ON prvi.prvi_VerbalInvestigationID = tes.prtesr_VerbalInvestigationID
		INNER JOIN Users u WITH (NOLOCK) ON u.User_UserId = prvi.prvi_CreatedBy
		INNER JOIN PRCompanySearch c WITH (NOLOCK) ON c.prcse_CompanyId = prvi.prvi_CompanyID 
	WHERE tr.prtr_TradeReportId = @TradeReportID
	  AND prvi_Status = 'O';

	IF (@VerbalInvestigationID IS NOT NULL) BEGIN
	
		SELECT @IntegrityResponseCount = COUNT(prtr_IntegrityId) 
		FROM PRTradeReport WITH (NOLOCK)
			INNER JOIN PRTESRequest WITH (NOLOCK) ON prtr_TESRequestID = prtesr_TESRequestID
		WHERE prtesr_VerbalInvestigationID = @VerbalInvestigationID 
			AND ISNULL(prtr_IntegrityId, 0) > 0; 
		   
		SELECT @PayRatingResponseCount = COUNT(prtr_PayRatingId)
		FROM PRTradeReport WITH (NOLOCK)
			INNER JOIN PRTESRequest WITH (NOLOCK) ON prtr_TESRequestID = prtesr_TESRequestID
		WHERE prtesr_VerbalInvestigationID = @VerbalInvestigationID
			AND ISNULL(prtr_PayRatingId, 0) > 0;
		
		If ((@PayRatingResponseCount >= @TargetNumberOfPayReports)
			AND (@IntegrityResponseCount >= @TargetNumberOfIntegrityReports))
		BEGIN
			
			UPDATE PRVerbalInvestigation
			SET prvi_Status = 'C'
			WHERE prvi_VerbalInvestigationID = @VerbalInvestigationID

			SET @Subject = dbo.ufn_GetCustomCaptionValue('TargetReachedVIEmail', 'Subject', 'en-us')
			SET @Body = dbo.ufn_GetCustomCaptionValue('TargetReachedVIEmail', 'Body', 'en-us')

			SET @Msg = @Body
			SET @Msg = REPLACE(@Msg,'{0}', @CompanyName)
			SET @Msg = REPLACE(@Msg,'{1}', @InvestigationName)

			EXEC usp_CreateEmail
				@CreatorUserID = -1,
				@To = @UserEmailAddress,
				@Subject = @Subject,
				@Content = @Msg,
				@Content_Format = 'HTML',
				@Action = 'EmailOut',
				@DoNotRecordCommunication = 1
		
		END
	END
END
Go


If Exists (Select name from sysobjects where name = 'usp_ProcessVICallAttempts ' and type='P') 
	Drop Procedure dbo.usp_ProcessVICallAttempts 
Go

CREATE PROCEDURE dbo.usp_ProcessVICallAttempts 
	@ResponderCompanyID int = null	
AS
BEGIN

	UPDATE PRTESRequest
	   SET prtesr_Received = 'Y',
		   prtesr_ReceivedDateTime = GETDATE(),
           prtesr_ProcessedByUserID = NULL
	 WHERE prtesr_TESRequestID IN (
			SELECT prtesr_TESRequestID FROM (
				SELECT prtesr_TESRequestID, prvi_MaxNumberOfAttempts, COUNT(1) As CallAttemptCount
				  FROM PRVerbalInvestigation
					   INNER JOIN PRVerbalInvestigationCAVI ON prvictvi_VerbalInvestigationID = prvi_VerbalInvestigationID
					   INNER JOIN PRTESRequest ON prtesr_TESRequestID = prvictvi_TESRequestID
				 WHERE prvi_Status = 'O'
				   AND prtesr_ResponderCompanyID = @ResponderCompanyID
				GROUP BY prtesr_TESRequestID, prvi_MaxNumberOfAttempts
				HAVING COUNT(1) >= prvi_MaxNumberOfAttempts
			) T1
		);

END
Go

/**
 usp_CloseVerbalInvestigations
**/
If Exists (Select name from sysobjects where name = 'usp_CloseVerbalInvestigations' and type='P')
    Drop Procedure dbo.usp_CloseVerbalInvestigations
Go

CREATE PROCEDURE dbo.usp_CloseVerbalInvestigations
AS
BEGIN
	DECLARE @VerbalInvestigationIndex int
	DECLARE @VerbalInvestigationCount int
	DECLARE @VerbalInvestigationID int
	DECLARE @UserEmailAddress nchar(255)
	DECLARE @CompanyName nvarchar(500)
	DECLARE @InvestigationName varchar(100)
	DECLARE @TargetCloseDate datetime
	DECLARE @Closed bit
	DECLARE @Count int
	
	DECLARE @Subject varchar(100)
	DECLARE @Body varchar(max)
	DECLARE @Msg varchar(max)	
	--Query for Open PRVerbalInvestigationRecords and get the creator's email address.
	DECLARE @VerbalInvestigation table (
		ID int identity(1,1) PRIMARY KEY,
		VerbalInvestigationID int,
		InvestigationName varchar(100),
		UserEmailAddress nchar(255) null,
		CompanyName nvarchar(500),
		TargetCloseDate datetime
	)

	INSERT INTO @VerbalInvestigation 
		(
			VerbalInvestigationID, 
			InvestigationName,
			UserEmailAddress,
			CompanyName,
			TargetCloseDate
		)
		SELECT 
			prvi_VerbalInvestigationID,
			prvi_InvestigationName,
			User_EmailAddress,
			prcse_FullName,
			prvi_TargetCompletionDate
		FROM PRVerbalInvestigation WITH (NOLOCK)
			 INNER JOIN Users WITH (NOLOCK) ON User_UserId = prvi_CreatedBy
			 INNER JOIN PRCompanySearch WITH (NOLOCK) ON prcse_CompanyId = prvi_CompanyID
		WHERE prvi_Status = 'O';

	SET @VerbalInvestigationCount = @@ROWCOUNT
	SET @VerbalInvestigationIndex = 0
		
	WHILE (@VerbalInvestigationIndex < @VerbalInvestigationCount) BEGIN
	
		SET @Closed = 0;
		SET @VerbalInvestigationIndex = @VerbalInvestigationIndex + 1
	
		SELECT 
			@VerbalInvestigationID = VerbalInvestigationID,
			@InvestigationName = InvestigationName,
			@UserEmailAddress = UserEmailAddress,
			@CompanyName = CompanyName,
			@TargetCloseDate = TargetCloseDate
		FROM @VerbalInvestigation 
		WHERE ID = @VerbalInvestigationIndex;


		-- Check to see if this VI has expired.
		IF (@TargetCloseDate < GETDATE()) BEGIN

			UPDATE PRVerbalInvestigation
			   SET prvi_Status = 'C'
			 WHERE prvi_VerbalInvestigationID = @VerbalInvestigationID
			SET @Closed = 1;
			
			SET @Subject = dbo.ufn_GetCustomCaptionValue('ExpiredVIEmail', 'Subject', 'en-us')
			SET @Body = dbo.ufn_GetCustomCaptionValue('ExpiredVIEmail', 'Body', 'en-us')

			SET @Msg = @Body
			SET @Msg = REPLACE(@Msg,'{0}', @CompanyName)
			SET @Msg = REPLACE(@Msg,'{1}', @InvestigationName)

			EXEC usp_CreateEmail
				@CreatorUserID = -1,
				@To = @UserEmailAddress,
				@Subject = @Subject,
				@Content = @Msg,
				@Content_Format = 'HTML',
				@Action = 'EmailOut',
				@DoNotRecordCommunication = 1;
		END

		-- Let's see if the VI has any remaining pending TES Requests
		IF (@Closed = 0) BEGIN
		
			SELECT @Count = COUNT(1)
			  FROM PRTESRequest WITH (NOLOCK)
			 WHERE prtesr_VerbalInvestigationID = @VerbalInvestigationID
			   AND prtesr_Received IS NULL;
		
			IF (@Count = 0) BEGIN
			
				UPDATE PRVerbalInvestigation
				   SET prvi_Status = 'C'
				 WHERE prvi_VerbalInvestigationID = @VerbalInvestigationID
				SET @Closed = 1;
				
				SET @Subject = dbo.ufn_GetCustomCaptionValue('ClosedVIEmail', 'Subject', 'en-us')
				SET @Body = dbo.ufn_GetCustomCaptionValue('ClosedVIEmail', 'Body', 'en-us')

				SET @Msg = @Body
				SET @Msg = REPLACE(@Msg,'{0}', @CompanyName)
				SET @Msg = REPLACE(@Msg,'{1}', @InvestigationName)

				EXEC usp_CreateEmail
					@CreatorUserID = -1,
					@To = @UserEmailAddress,
					@Subject = @Subject,
					@Content = @Msg,
					@Content_Format = 'HTML',
					@Action = 'EmailOut',
					@DoNotRecordCommunication = 1;			
			
			END
		
		END


	END
END	
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_CreateOpportunities]') 
            and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_CreateOpportunities]
GO

CREATE PROCEDURE dbo.usp_CreateOpportunities
    @CompanyID int,
    @PersonID int,
    @AssignedTo int,
    @MarketingWave int,
    @Type varchar(40),
    @Pipeline varchar(40),
    @Trigger varchar(40),
    @Source varchar(40),
    @Details varchar(max),
	@TargetMonth int = null,
	@TargetYear int = null,    
    @UserID int = -1,
    @Status varchar(40) = 'Open',
    @Stage varchar(40) = 'Lead'
as
BEGIN

	DECLARE @OppoId int
	EXEC usp_getNextId 'Opportunity', @OppoId OUTPUT
					
	INSERT INTO Opportunity (oppo_OpportunityId, oppo_PrimaryCompanyID, oppo_AssignedUserID, Oppo_Note, oppo_Type, 
							 oppo_Status, oppo_Stage, oppo_PRPipeline, oppo_Opened, Oppo_PrimaryPersonId,
							 oppo_Source, oppo_PRTrigger, Oppo_WaveItemId, oppo_PRTargetStartYear, oppo_PRTargetStartMonth,
							 oppo_CreatedBy, oppo_CreatedDate, oppo_UpdatedBy, oppo_UpdatedDate, oppo_Timestamp)
	VALUES (@OppoId, @CompanyID, @AssignedTo, @Details, @Type,
			@Status, @Stage, @Pipeline, GETDATE(), @PersonID,
			@Source, @Trigger, @MarketingWave, @TargetYear, @TargetMonth,
			@UserId, GETDATE(), @UserId, GETDATE(), GETDATE());
		            
END				            
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_FlushExternalNewsArticleCacheByCompany]') 
            and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_FlushExternalNewsArticleCacheByCompany]
GO

CREATE PROCEDURE dbo.usp_FlushExternalNewsArticleCacheByCompany
	@CompanyID int, @PrimarySourceCode varchar(40), @MonthOffset int
As
BEGIN
	DECLARE @Articles table (
		ArticleID int
	)	

	-- Save our most recent 10 articles.  These should
	-- not be deleted
	INSERT INTO @Articles
	SELECT TOP 10 pren_ExternalNewsID
	  FROM PRExternalNews
	 WHERE pren_SubjectCompanyID = @CompanyID
	ORDER BY pren_PublishDateTime DESC

	DELETE
	  FROM PRExternalNews
	 WHERE pren_SubjectCompanyID = @CompanyID
	   AND pren_PublishDateTime < DATEADD(month, 0-@MonthOffset, GETDATE())
	   AND pren_PrimarySourceCode = @PrimarySourceCode
	   AND pren_ExternalNewsID NOT IN (SELECT ArticleID FROM @Articles);
	   
	RETURN @@ROWCOUNT	   
END
Go   



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_FlushExternalNewsArticleCache]') 
            and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_FlushExternalNewsArticleCache]
GO

CREATE PROCEDURE dbo.usp_FlushExternalNewsArticleCache
As
BEGIN
	SET NOCOUNT ON

	DECLARE @TotalDeleteCount int, @CompanyDeleteCount int, @Result int
	DECLARE @Company table (
		ndx int identity (1,1) primary key,
		CompanyID int
	)

	-- Look for those companies that have more than 10 articles with
	-- the oldest being over 24 months old. 
	INSERT INTO @Company
	SELECT pren_SubjectCompanyID
	  FROM (
			SELECT pren_SubjectCompanyID, COUNT(1) ArticleCount, MIN(pren_PublishDateTime) As OldestPublishDate
			  FROM PRExternalNews
			GROUP BY pren_SubjectCompanyID  
			 HAVING COUNT(1) > 10
			) T1
	 WHERE OldestPublishDate < DATEADD(month, -24, GETDATE());

	DECLARE @Count int, @Index int, @CompanyID int
	
	SELECT @Count = COUNT(1) FROM @Company;
	SET @Index = 0
	SET @TotalDeleteCount = 0
	
	WHILE (@Index < @Count) BEGIN
		
		SET @Index = @Index + 1
		SET @CompanyDeleteCount = 0
		
		SELECT @CompanyID = CompanyID
		  FROM @Company
		 WHERE ndx = @Index;
			
		EXEC @Result = usp_FlushExternalNewsArticleCacheByCompany @CompanyID, 'DowJones', 24
		SET @CompanyDeleteCount = @CompanyDeleteCount + @Result

		EXEC @Result = usp_FlushExternalNewsArticleCacheByCompany @CompanyID, 'MMW', 48
		SET @CompanyDeleteCount = @CompanyDeleteCount + @Result

		EXEC @Result = usp_FlushExternalNewsArticleCacheByCompany @CompanyID, 'PN', 48
		SET @CompanyDeleteCount = @CompanyDeleteCount + @Result
		

		IF (@CompanyDeleteCount > 0) BEGIN	
			PRINT CAST(@CompanyID AS VARCHAR(10)) + ': Deleted ' + CAST(@CompanyDeleteCount as Varchar(10)) + ' external news article records.'
		END
	
		SET @TotalDeleteCount = @TotalDeleteCount + @CompanyDeleteCount
	END
	
	PRINT 'Deleted a total of ' + CAST(@TotalDeleteCount as Varchar(10)) + ' external news article records.'	
END
Go	

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_UpdateARAgingTotals]') 
            and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_UpdateARAgingTotals]
GO

CREATE PROCEDURE dbo.usp_UpdateARAgingTotals
    @ARAgingID int
As
BEGIN

UPDATE PRARAging
   SET praa_Count = praa_ARAgingDetailCount,
       praa_Total = praad_TotalAmountCurrent  + praad_TotalAmount1to30 + praad_TotalAmount31to60 + praad_TotalAmount61to90 + praad_TotalAmount91Plus +  praad_TotalAmount0to29 + praad_TotalAmount30to44 + praad_TotalAmount45to60 + praad_TotalAmount61Plus,
       praa_TotalCurrent = praad_TotalAmountCurrent,
       praa_Total1to30 = praad_TotalAmount1to30,
       praa_Total31to60 = praad_TotalAmount31to60,
       praa_Total61to90 = praad_TotalAmount61to90,
       praa_Total91Plus = praad_TotalAmount91Plus,
       praa_Total0to29 = praad_TotalAmount0to29,
       praa_Total30to44 = praad_TotalAmount30to44,
       praa_Total45to60 = praad_TotalAmount45to60,
       praa_Total61Plus = praad_TotalAmount61Plus       
  FROM  (
		SELECT praad_ARAgingId, 
			   praa_ARAgingDetailCount = COUNT(1), 
			   praad_TotalAmountCurrent = ISNULL(SUM(praad_AmountCurrent), 0),
			   praad_TotalAmount1to30 = ISNULL(SUM(praad_Amount1to30),  0),
			   praad_TotalAmount31to60 = ISNULL(SUM(praad_Amount31to60), 0),
			   praad_TotalAmount61to90 = ISNULL(SUM(praad_Amount61to90), 0),
			   praad_TotalAmount91Plus = ISNULL(SUM(praad_Amount91Plus), 0),
			   praad_TotalAmount0to29 = ISNULL(SUM(praad_Amount0to29),  0),
			   praad_TotalAmount30to44 = ISNULL(SUM(praad_Amount30to44), 0),
			   praad_TotalAmount45to60 = ISNULL(SUM(praad_Amount45to60), 0),
			   praad_TotalAmount61Plus = ISNULL(SUM(praad_Amount61Plus), 0)
		  FROM PRARAgingDetail WITH (NOLOCK) 
		 WHERE praad_ARAgingID = @ARAgingID
	  GROUP BY praad_ARAgingId) T1
	 WHERE praa_ARAgingId = T1.praad_ARAgingId;
END
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_UpdateListing]') 
            and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_UpdateListing]
GO

CREATE PROCEDURE dbo.usp_UpdateListing
    @CompanyID int
As
BEGIN

	DECLARE @ListingID int
	
	SELECT @ListingID = prlst_ListingID
	  FROM PRListing WITH (NOLOCK)
	 WHERE prlst_CompanyID = @CompanyID;
	 
	 IF (@ListingID IS NOT NULL) BEGIN
		UPDATE PRListing
		   SET prlst_Listing = dbo.ufn_GetListingFromCompany(@CompanyID, 0, 0),
		       prlst_UpdatedDate = GETDATE(),
		       prlst_Timestamp = GETDATE()
		 WHERE prlst_CompanyID = @CompanyID;
	 END ELSE BEGIN
		INSERT INTO PRListing (prlst_CompanyID, prlst_Listing) 
		   VALUES (@CompanyID, dbo.ufn_GetListingFromCompany(@CompanyID, 0, 0));
	 END
END
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_UpdateBranchListings]') 
            and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_UpdateBranchListings]
GO

CREATE PROCEDURE dbo.usp_UpdateBranchListings
    @HQID int
As
BEGIN

	DECLARE @ndx int, @BranchID int, @Count int
	DECLARE @tblBranches table (
	    ndx int primary key identity (0,1),
		BranchID int
	)
	
	INSERT INTO @tblBranches
	SELECT comp_CompanyID
	  FROM Company WITH (NOLOCK)
	 WHERE comp_PRHQID = @HQID
	   AND comp_PRType = 'B';

	SELECT @Count = COUNT(1) FROM @tblBranches;
	SET @ndx = 0
	WHILE (@ndx < @Count) BEGIN
		SELECT @BranchID = BranchID
		  FROM @tblBranches
		 WHERE ndx = @ndx;
	
		EXEC usp_UpdateListing @BranchID
		
		SET @ndx = @ndx + 1
	END
End
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_SetMessageCenterMsgs]') 
            and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_SetMessageCenterMsgs]
GO

CREATE PROCEDURE dbo.usp_SetMessageCenterMsgs
    @Type varchar(40),
    @Msg varchar(max),
    @MaxLoginCount int
As
BEGIN

	DECLARE @Family varchar(40)
	SET @Family = 'MessageCenterMsg'
	IF @Type = 'Member' BEGIN
		SET @Family = 'MemberMessageCenterMsg'
	END		
	IF @Type = 'NonMember' BEGIN
		SET @Family = 'NonMemberMessageCenterMsg'
	END		

	UPDATE Custom_Captions
	   SET capt_US = @msg
	 WHERE capt_Family = @Family
	   AND capt_Code = 'Message';

	UPDATE Custom_Captions
	   SET capt_US = CONVERT(varchar(40), @MaxLoginCount)
	 WHERE capt_Family = @Family
	   AND capt_Code = 'MaxLoginCount';	
	
	SELECT capt_Family, RTRIM(capt_Code) As cap_Code, capt_US
	  FROM custom_captions
	 WHERE capt_Family = @Family;
End
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_UpdateCSItemText]') 
            and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_UpdateCSItemText]
GO

CREATE PROCEDURE dbo.usp_UpdateCSItemText
    @CreditSheetID int
As
BEGIN

	UPDATE PRCreditSheet
	   SET prcs_ItemText = dbo.ufn_GetItem(@CreditSheetID, 0, 1, 34)
	 WHERE prcs_CreditSheetId = @CreditSheetID;

END
Go


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_DataIntegrityCheck]') 
            and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_DataIntegrityCheck]
GO

CREATE PROCEDURE dbo.usp_DataIntegrityCheck
As
BEGIN

	DECLARE @MsgTable table (
		ndx int primary key identity(1,1),
		Msg varchar(1000)
	)

	INSERT INTO @MsgTable
	SELECT ' - Company ID ' + CAST(comp_CompanyID As varchar(10)) + ' has an invalid comp_PRListingCityID value: ' + ISNULL(CAST(comp_PRListingCityID AS varchar(10)), '<null>') + '.  This company was last changed by ' + CASE WHEN comp_UpdatedBy < 0 THEN 'SYSTEM' ELSE RTRIM(User_FirstName) + ' ' + RTRIM(User_LastName) END + ' on ' + convert(varchar, Comp_UpdatedDate,22)
	  FROM Company WITH (NOLOCK)
		   LEFT OUTER JOIN Users WITH (NOLOCK) ON comp_UpdatedBy = User_UserId
	 WHERE comp_PRListingCityId IS NULL
		OR comp_PRListingCityId = 0;
	    
	DECLARE @MsgCount int = 0
	SELECT @MsgCount = COUNT(1) FROM @MsgTable;

	IF (@MsgCount > 0) BEGIN

		DECLARE @NewLineChar AS CHAR(2) = CHAR(13) + CHAR(10)
		DECLARE @Body varchar(max)
		
		SET @Body = 'The following data anomalies have been found:' + @NewLineChar
		
		SELECT @Body = Coalesce(@Body + @NewLineChar, '') + Msg
		  FROM @MsgTable;
		

		EXEC usp_CreateEmail 
			@To = 'noc@bluebookservices.com',
			@Subject = 'Data Anomalies Found',
			@Content = @Body,
			@DoNotRecordCommunication = 1
			
	END
END
Go


IF EXISTS (SELECT 'x' FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[usp_AttentionLineSetDefault]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[usp_AttentionLineSetDefault]
GO

CREATE PROCEDURE dbo.usp_AttentionLineSetDefault 
    @CompanyID int, 
    @ItemCode varchar(40), 
    @ItemCount int
As
BEGIN

	DECLARE @Index int = 0, @Count int = 0
	DECLARE @AddressID int = 0, @EmailID int = 0, @PhoneID int = 0;
	
	SELECT @Count = COUNT(1)
	  FROM PRAttentionLine
	 WHERE prattn_CompanyID = @CompanyID
	   AND prattn_ItemCode = @ItemCode;
	   
	WHILE (@Count < @ItemCount) BEGIN

		IF ((@ItemCode LIKE 'BOOK-%') OR
		    (@ItemCode = 'BPRINT') OR
		    (@ItemCode = 'KYCG') OR
		    (@ItemCode = 'BBSICC')) BEGIN

		    SET @AddressID = null;
			SELECT @AddressID = adli_AddressID 
			  FROM Address_Link 
			 WHERE adli_CompanyID = @CompanyID 
			   AND adli_PRDefaultMailing = 'Y';
			   
			 INSERT INTO PRAttentionLine (prattn_CompanyID, prattn_ItemCode, prattn_AddressID, prattn_CreatedBy, prattn_CreatedDate, prattn_UpdatedBy, prattn_UpdatedDate, prattn_Timestamp)
			 VALUES (@CompanyID, @ItemCode, @AddressID, -1, GETDATE(), -1, GETDATE(), GETDATE())
		END 
		
		SET @Count = @Count + 1
	END
END
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_UpdateTaxCode]') 
            and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].usp_UpdateTaxCode
GO

CREATE PROCEDURE dbo.usp_UpdateTaxCode 
    @CompanyID int, 
    @AddressID int, 
    @UserID int
As
BEGIN

	DECLARE @TaxCode varchar(40) = dbo.ufn_GetTaxCode(@AddressID)
	

	DECLARE @CompanyIndicatorID int
	SELECT @CompanyIndicatorID = prci2_CompanyIndicatorID
	  FROM PRCompanyIndicators
	 WHERE prci2_CompanyID = @CompanyID;
	 
	IF (@CompanyIndicatorID IS NULL) BEGIN
	
		EXEC usp_GetNextId 'PRCompanyIndicators', @CompanyIndicatorID output
		INSERT INTO PRCompanyIndicators (prci2_CompanyIndicatorID, prci2_CompanyID, prci2_TaxCode, prci2_CreatedBy, prci2_CreatedDate, prci2_UpdatedBy, prci2_UpdatedDate, prci2_Timestamp)
		VALUES (@CompanyIndicatorID, @CompanyID, @TaxCode, @UserID, GETDATE(), @UserID, GETDATE(), GETDATE());
	
	END ELSE BEGIN
		
		UPDATE PRCompanyIndicators
		   SET prci2_TaxCode = CASE WHEN prci2_TaxExempt IS NULL THEN @TaxCode ELSE 'NT' END,
		       prci2_UpdatedBy = @UserID,
		       prci2_UpdatedDate = GETDATE(),
		       prci2_Timestamp = GETDATE()
		 WHERE prci2_CompanyIndicatorID = @CompanyIndicatorID;

	END

END
Go


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_UpdateAllTaxCodes]') 
            and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].usp_UpdateAllTaxCodes
GO

CREATE PROCEDURE dbo.usp_UpdateAllTaxCodes 
As
BEGIN

	--
	--  Try to only update the records that have changes to the
	--  tax codes because changes to tax codes trigger data imports
	--  into MAS.
	--
	UPDATE PRCompanyIndicators
	   SET prci2_TaxCode =  TaxCode,
		   prci2_UpdatedBy = -1,
		   prci2_UpdatedDate = GETDATE(),
		   prci2_Timestamp = GETDATE()
	  FROM PRCompanyIndicators
		   INNER JOIN (SELECT adli_CompanyID, dbo.ufn_GetTaxCode(addr_AddressID) As TaxCode
						FROM vPRAddress 
						     INNER JOIN PRCompanyIndicators ON adli_CompanyId = prci2_CompanyID
					   WHERE adli_PRDefaultTax = 'Y') T1 ON prci2_CompanyID = adli_CompanyID
	 WHERE ISNULL(prci2_TaxCode, 'z') <> TaxCode
	   AND prci2_TaxExempt IS NULL;

	UPDATE PRCompanyIndicators
	   SET prci2_TaxCode =  'NT',
		   prci2_UpdatedBy = -1,
		   prci2_UpdatedDate = GETDATE(),
		   prci2_Timestamp = GETDATE()
	  FROM PRCompanyIndicators
	 WHERE prci2_TaxCode <> 'NT'
	   AND prci2_TaxExempt = 'Y';

END
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_UpdateStripeCustomerId]') 
            and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].usp_UpdateStripeCustomerId
GO

CREATE PROCEDURE dbo.usp_UpdateStripeCustomerId 
    @CompanyID int, 
    @StripeCustomerId varchar(50), 
    @UserID int
As
BEGIN
	DECLARE @CompanyIndicatorID int
	SELECT @CompanyIndicatorID = prci2_CompanyIndicatorID
	  FROM PRCompanyIndicators
	 WHERE prci2_CompanyID = @CompanyID;
	 
	IF (@CompanyIndicatorID IS NULL) BEGIN
	
		EXEC usp_GetNextId 'PRCompanyIndicators', @CompanyIndicatorID output
		INSERT INTO PRCompanyIndicators (prci2_CompanyIndicatorID, prci2_CompanyID, prci2_StripeCustomerId, prci2_CreatedBy, prci2_CreatedDate, prci2_UpdatedBy, prci2_UpdatedDate, prci2_Timestamp)
		VALUES (@CompanyIndicatorID, @CompanyID, @StripeCustomerId, @UserID, GETDATE(), @UserID, GETDATE(), GETDATE());
	
	END ELSE BEGIN
		
		UPDATE PRCompanyIndicators
		   SET prci2_StripeCustomerId = @StripeCustomerId,
		       prci2_UpdatedBy = @UserID,
		       prci2_UpdatedDate = GETDATE(),
		       prci2_Timestamp = GETDATE()
		 WHERE prci2_CompanyIndicatorID = @CompanyIndicatorID;

	END
END
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_CheckDLCount]') 
            and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].usp_CheckDLCount
GO

CREATE PROCEDURE dbo.usp_CheckDLCount 
As
BEGIN

	DECLARE @MyTable table (
		HQID int,
		CRMDLCount int)

	INSERT INTO @MyTable
	SELECT comp_PRHQID, SUM(CompanyDLCount) as HQDLCount
	 FROM (
		SELECT comp_PRHQId, comp_CompanyID, comp_Name, dbo.ufn_GetListingDLLineCount(comp_CompanyID) as CompanyDLCount
		  FROM Company
		 WHERE dbo.ufn_GetListingDLLineCount(comp_CompanyID) > 0
	) T1
	GROUP BY comp_PRHQID

	INSERT INTO PRChangeDetection (prchngd_CompanyID, prchngd_ChangeType)
	SELECT CAST(ISNULL(soh.BillToCustomerNo, soh.CustomerNo) As Int), 'DL Quantity'
	  FROM @MyTable
		   INNER JOIN MAS_PRC.dbo.SO_SalesOrderHeader soh ON HQID = CAST(ISNULL(soh.BillToCustomerNo, soh.CustomerNo) As Int)
		   INNER JOIN MAS_PRC.dbo.SO_SalesOrderDetail sod  ON soh.SalesOrderNo = sod.SalesOrderNo
	 WHERE ItemCode = 'DL'
	   AND CRMDLCount <> ISNULL(sod.QuantityOrdered, 0)

END
Go


CREATE OR ALTER PROCEDURE dbo.usp_GetDLOrders 
    @Start datetime,
    @End datetime
As
BEGIN

	DECLARE @Order table (
		SalesOrderNo varchar(50),
		ARDivisionNo varchar(50),
		CustomerNo varchar(50),
		OrderType varchar(50),
		ShipExpireDate varchar(50),
		CustomerNo2 varchar(50),
		OrderStatus varchar(50),		
		BillToName varchar(100),
		BillToAddress1 varchar(50),
		BillToAddress2 varchar(50),
		BillToAddress3 varchar(50),
		BillToZipCode varchar(50),
		BillToCity varchar(50),
		BillToState varchar(50),
		BillToCountryCode varchar(50),
		ShipToName varchar(100),
		ShipToAddress1 varchar(50),
		ShipToAddress2 varchar(50),
		ShipToAddress3 varchar(50),
		ShipToZipCode varchar(50),
		ShipToCity varchar(50),
		ShipToState varchar(50),
		ShipToCountryCode varchar(50),
		TermsCode varchar(50),
		TaxSchedule varchar(50),
		TaxExemptNo varchar(50),
		CycleCode varchar(50),
		BillToDivisionNo varchar(50),
		BillToCustomerNo varchar(50),
		ItemCode varchar(50),
		ItemType varchar(50),
		ItemCodeDesc varchar(50),
		Discount varchar(50),
		SubjectToExemption varchar(50),
		PriceLevel varchar(50), 
		UnitOfMeasure varchar(50),
		CostOfGoodsSoldAcctKey varchar(50),
		SalesAcctKey varchar(50),
		ExplodedKitItem varchar(50),
		TaxClass varchar(50),
		QuantityOrdered int,
		UnitPrice  decimal(9,4),
		ExtensionAmt decimal(9,4),
		SkipPrintCompLine varchar(1)	
	)

	INSERT INTO @Order
	SELECT DISTINCT 
		SO_SalesOrderHeader.SalesOrderNo, 
		'00',
		'0' + CAST(ship.comp_CompanyID as varchar(10)),
		'R',
		'ShipExpireDate' = '12/31/5999',
        '0' + CAST(ship.comp_CompanyID as varchar(10))
		, 'OrderStatus' = 'N'
		, 'BillToName' = CASE WHEN bill.comp_CompanyID = ship.comp_CompanyID THEN '' ELSE SUBSTRING(bill.comp_PRCorrTradestyle, 1, 30) END
		, 'BillToAddress1' = CASE WHEN bill.comp_CompanyID = ship.comp_CompanyID THEN '' ELSE RTRIM(bl.Addr_Address1) END
		, 'BillToAddress2' = CASE WHEN bill.comp_CompanyID = ship.comp_CompanyID THEN '' ELSE ISNULL(RTRIM(bl.Addr_Address2), '') END
		, 'BillToAddress3' = CASE WHEN bill.comp_CompanyID = ship.comp_CompanyID THEN '' ELSE ISNULL(RTRIM(bl.Addr_Address3), '') END
		, 'BillToZipCode' = CASE WHEN bill.comp_CompanyID = ship.comp_CompanyID THEN '' ELSE ISNULL(bl.addr_uszipfive,'') END
		, 'BillToCity' = CASE WHEN bill.comp_CompanyID = ship.comp_CompanyID THEN '' ELSE bl.prci_City END
		, 'BillToState' = CASE WHEN bill.comp_CompanyID = ship.comp_CompanyID THEN '' ELSE ISNULL(bl.prst_Abbreviation,'') END
		, 'BillToCountryCode' = CASE WHEN bill.comp_CompanyID = ship.comp_CompanyID THEN '' ELSE RIGHT('00'+ CONVERT(VARCHAR, bl.prcn_CountryId), 3) END
		, 'ShipToName' = ship.comp_PRCorrTradestyle
		, 'ShipToAddress1' = RTRIM(tx.Addr_Address1)
		, 'ShipToAddress2' = ISNULL(RTRIM(tx.Addr_Address2), '')
		, 'ShipToAddress3' = ISNULL(RTRIM(tx.Addr_Address3), '')
		, 'ShipToZipCode' = ISNULL(tx.addr_uszipfive,'')
		, 'ShipToCity' = tx.prci_City
		, 'ShipToState' = ISNULL(tx.prst_Abbreviation,'')
		, 'ShipToCountryCode' = RIGHT('00'+ CONVERT(VARCHAR, tx.prcn_CountryId),3)
		, 'TermsCode' = '01'
		, 'TaxSchedule' = dbo.ufn_GetTaxCode(bl.addr_AddressID)
		, 'TaxExemptNo' = ''
		,  ISNULL(CycleCode, '02')
		, 'BillToDivisionNo' = CASE WHEN bill.comp_CompanyID = ship.comp_CompanyID THEN '' ELSE '00' END
		, 'BillToCustomerNo' = CASE WHEN bill.comp_CompanyID = ship.comp_CompanyID THEN '' ELSE '0' + CAST(bill.comp_CompanyID as varchar(6)) END
		,ItemCode,
		ItemType,
		ItemCodeDesc,
		'' As Discount,
		'Y' As SubjectToExemption,
		'' As PriceLevel,
		CI_Item.StandardUnitOfMeasure,
		IM_ProductLine.CostOfGoodsSoldAcctKey,
		IM_ProductLine.SalesIncomeAcctKey,
		'N' As ExplodedKitItem,
		CI_Item.TaxClass,
		dbo.ufn_GetListingDLLineCount(ship.comp_CompanyID) AS QuantityOrdered,
		StandardUnitPrice,
		(dbo.ufn_GetListingDLLineCount(ship.comp_CompanyID) * StandardUnitPrice) As ExtensionAmt,
		'N' As SkipPrintCompLine
   FROM PRChangeDetection WITH (NOLOCK)
	    INNER JOIN Company ship WITH (NOLOCK) ON prchngd_CompanyID = comp_CompanyID
		INNER JOIN MAS_PRC.dbo.CI_Item ON ItemCode = 'DL'
		INNER JOIN MAS_PRC.dbo.IM_ProductLine ON CI_Item.ProductLine = IM_ProductLine.ProductLine
	    INNER JOIN Company bill WITH (NOLOCK) ON bill.comp_CompanyID = ship.comp_PRHQID
		INNER JOIN vPRAddress tx WITH (NOLOCK) ON tx.adli_CompanyId = ship.Comp_CompanyId AND tx.adli_PRDefaultTax = 'Y'
		LEFT OUTER JOIN PRAttentionLine WITH (NOLOCK) ON prattn_CompanyID = ship.comp_PRHQID AND prattn_ItemCode = 'Bill'
		LEFT OUTER JOIN vPRAddress bl WITH (NOLOCK) ON prattn_AddressID = bl.Addr_AddressId
	    LEFT OUTER JOIN MAS_PRC.dbo.SO_SalesOrderHeader ON CAST(CustomerNo as INT) = ship.comp_CompanyID AND OrderType = 'R' AND CycleCode <> '99'  
  WHERE prchngd_ChangeType IN ('DL ORDER')  
    AND prchngd_CreatedDate BETWEEN @Start AND @End
	AND prchngd_CompanyID NOT IN (SELECT prse_CompanyID FROM PRService WHERE prse_Primary='Y')

		
	UPDATE @Order
	   SET TaxSchedule = 'NT'
	 WHERE TaxSchedule = ''
		OR TaxSchedule IS NULL;

	SELECT *
	  FROM @Order 
	 WHERE SalesOrderNo IS NULL;
	 
	 
	SELECT SalesOrderNo,
		ItemCode,
		ItemType,
		ItemCodeDesc,
		Discount,
		SubjectToExemption,
		PriceLevel, 
		UnitOfMeasure,
		CostOfGoodsSoldAcctKey,
		SalesAcctKey,
		ExplodedKitItem,
		TaxClass,
		QuantityOrdered,
		UnitPrice,
		ExtensionAmt,
		SkipPrintCompLine
	  FROM @Order 
	 WHERE SalesOrderNo IS NOT NULL; 
	 
END
GO	 


IF EXISTS (SELECT 'x' FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[usp_RemoveServiceItems]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[usp_RemoveServiceItems]
GO

CREATE PROCEDURE dbo.usp_RemoveServiceItems 
    @CompanyID int, 
    @IndustryType varchar(40),
    @UserID int,
    @CompanyOnly bit = 1
As
BEGIN

	IF (@CompanyOnly = 1) BEGIN
		UPDATE PRWebUser
		   SET prwu_AccessLevel = 0,
		       prwu_ServiceCode = null,
			   prwu_Disabled = 'Y',
			   prwu_UpdatedBy = @UserID,
			   prwu_UpdatedDate = GETDATE(),
			   prwu_TimeStamp = GETDATE()
		 WHERE prwu_BBID = @CompanyID;
		 
		 DELETE
		   FROM PRAttentionLine
		  WHERE prattn_CompanyID = @CompanyID
			AND (prattn_ItemCode IN ('BPRINT', 'KYCG')
				 OR prattn_ItemCode LIKE 'BOOK-%');

		--Defect 4642
		DELETE PRWebUserLocalSource
			FROM PRWebUserLocalSource
			INNER JOIN PRWebUser ON prwuls_WebUserID = prwu_WebUserID
		WHERE 
			prwu_BBID = @CompanyID
			AND prwuls_ServiceCode IN ('LSS','LSSLIC');

		EXEC usp_CancelAllServiceUnits @CompanyID, 0

	END ELSE BEGIN
	
		DECLARE @HQID int
		SET @HQID = dbo.ufn_BRGetHQID(@CompanyID);
		
		UPDATE PRWebUser
		   SET prwu_AccessLevel = 0,
		       prwu_ServiceCode = null,
			   prwu_Disabled = 'Y',
			   prwu_UpdatedBy = @UserID,
			   prwu_UpdatedDate = GETDATE(),
			   prwu_TimeStamp = GETDATE()
		 WHERE prwu_HQID = @HQID;
	
		 DELETE PRAttentionLine
		   FROM PRAttentionLine
		        INNER JOIN Company ON prattn_CompanyID = comp_CompanyID
		  WHERE comp_PRHQId = @HQID
			AND (prattn_ItemCode IN ('BPRINT', 'KYCG')
				 OR prattn_ItemCode LIKE 'BOOK-%');

		--Defect 4642
		DELETE PRWebUserLocalSource
			FROM PRWebUserLocalSource
			INNER JOIN PRWebUser ON prwuls_WebUserID = prwu_WebUserID
			INNER JOIN Company ON prwu_BBID = comp_CompanyID
		WHERE 
			comp_PRHQId = @HQID
			AND prwuls_ServiceCode IN ('LSS','LSSLIC');

		EXEC usp_CancelAllServiceUnits @CompanyID, 1		
	END
END
Go

CREATE OR ALTER PROCEDURE dbo.usp_RestoreAttentionLineFromService 
    @CompanyID int = null
As
BEGIN


	DECLARE @MyTable table (
		ndx int identity(1,1),
		CompanyID int,
		ItemCode varchar(40),
		QuantityOrdered int,
		AttnLineCount int)


	INSERT INTO @MyTable (CompanyID, ItemCode, QuantityOrdered, AttnLineCount)
	SELECT CustomerNo, ItemCode, QuantityOrdered, AttnLineCount
	  FROM (
			SELECT CAST(CustomerNo As Int) CustomerNo,
				   i.ItemCode,
				   QuantityOrdered
			  FROM MAS_PRC.dbo.SO_SalesOrderDetail	i
				   INNER JOIN MAS_PRC.dbo.SO_SalesOrderHeader ON i.SalesOrderNo = SO_SalesOrderHeader.SalesOrderNo
			 WHERE OrderType = 'R'
			   AND CycleCode <> '99'
			   AND (i.ItemCode  IN ('BPRINT', 'KYCG')
					OR i.ItemCode LIKE 'BOOK-%')) T1
			LEFT OUTER JOIN (	        
			 SELECT prattn_CompanyID, prattn_ItemCode, COUNT(1) As AttnLineCount
			   FROM CRM.dbo.PRAttentionLine
			  WHERE (prattn_ItemCode IN ('BPRINT', 'KYCG')
					OR prattn_ItemCode LIKE 'BOOK-%')
			  GROUP BY prattn_CompanyID, prattn_ItemCode) T2 ON CustomerNo = prattn_CompanyID AND ItemCode = prattn_ItemCode
	WHERE (AttnLineCount IS NULL
		   OR QuantityOrdered > AttnLineCount)
	  AND CustomerNo = ISNULL(@CompanyID, CustomerNo)
	ORDER BY CustomerNo;


	DECLARE @Count int, @Index int
	DECLARE @SubjectCompanyID int, @ItemCode varchar(40), @ItemCount int

	SELECT @Count = COUNT(1) FROM @MyTable;
	SET @Index = 0

	WHILE (@Index < @Count) BEGIN
		SET @Index = @Index + 1

		SELECT @SubjectCompanyID = CompanyID,
			   @ItemCode = ItemCode,
			   @ItemCount = QuantityOrdered
		  FROM @MyTable
		 WHERE ndx = @Index;

		EXEC CRM.dbo.usp_AttentionLineSetDefault @SubjectCompanyID, @ItemCode, @ItemCount
	END
END	   
Go	

		  
			  
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_ClosePendingCases]') 
            and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_ClosePendingCases]
GO

CREATE PROCEDURE dbo.usp_ClosePendingCases 
As
BEGIN

	DECLARE @ClosedCOunt int = 0

	;WITH PendingCasesCollected AS
	(
	   SELECT case_CaseId, case_Status, tph.TransactionType, Case_ClosedBy, Case_Closed, Case_UpdatedBy, Case_UpdatedDate, Case_TimeStamp,
			 ROW_NUMBER() OVER (PARTITION BY UDF_MASTER_INVOICE ORDER BY TransactionType DESC) AS rn
		FROM CRM.dbo.Cases WITH (NOLOCK)
			 INNER JOIN MAS_PRC.dbo.AR_InvoiceHistoryHeader ihh WITH (NOLOCK) ON case_PRMasterInvoiceNumber = UDF_MASTER_INVOICE
			 INNER JOIN MAS_PRC.dbo.AR_OpenInvoice oi WITH (NOLOCK) ON oi.InvoiceNo = ihh.InvoiceNo
			 INNER JOIN MAS_PRC.dbo.AR_TransactionPaymentHistory tph WITH (NOLOCK) ON tph.InvoiceNo = ihh.InvoiceNo
	   WHERE tph.TransactionType IN ('P', 'C')
		 AND UDF_MASTER_INVOICE <> ''
		 AND Case_Status IN ('Pending', 'Open')
		 AND Balance = 0
	)
	UPDATE PendingCasesCollected
	   SET Case_Status = 'Collected',
           Case_ClosedBy = -1,
           Case_Closed = GETDATE(),
           Case_UpdatedBy = -1,
           Case_UpdatedDate = GETDATE(),
           Case_TimeStamp = GETDATE()
	 WHERE rn = 1
	   AND TransactionType = 'P';


	SET @ClosedCOunt = @ClosedCOunt + @@ROWCOUNT

--
--  If the invoice now has a zero balance due to a credit, 
--  and the company has a new open invoice created in the past 24 hours,
--  then assume this is a membership change.
	;WITH PendingCasesNotCollected AS
	(
	   SELECT case_CaseId, case_Status, tph.TransactionType, Case_ClosedBy, Case_Closed, Case_UpdatedBy, Case_UpdatedDate, Case_TimeStamp,
			  ROW_NUMBER() OVER (PARTITION BY UDF_MASTER_INVOICE ORDER BY TransactionType DESC) AS rn
		FROM CRM.dbo.Cases WITH (NOLOCK)
			 INNER JOIN MAS_PRC.dbo.AR_InvoiceHistoryHeader ihh WITH (NOLOCK) ON case_PRMasterInvoiceNumber = UDF_MASTER_INVOICE
			 INNER JOIN MAS_PRC.dbo.AR_OpenInvoice oi WITH (NOLOCK) ON oi.InvoiceNo = ihh.InvoiceNo
			 INNER JOIN MAS_PRC.dbo.AR_TransactionPaymentHistory tph WITH (NOLOCK) ON tph.InvoiceNo = ihh.InvoiceNo
	   WHERE tph.TransactionType IN ('P', 'C')
		 AND UDF_MASTER_INVOICE <> ''
		 AND Case_Status IN ('Pending', 'Open')
		 AND Balance = 0
		 AND case_PrimaryCompanyID IN (SELECT DISTINCT CAST(CASE WHEN ihh.BillToCustomerNo = '' THEN ihh.CustomerNo ELSE ihh.BillToCustomerNo END As INT) As CompanyID 
                                         FROM MAS_PRC.dbo.AR_OpenInvoice oi
                                              INNER JOIN MAS_PRC.dbo.AR_InvoiceHistoryHeader ihh ON oi.InvoiceNo = ihh.InvoiceNo
                                        WHERE Balance > 0
                                          AND ihh.InvoiceDate < DATEADD(day, -1, GETDATE()))
	)
	UPDATE PendingCasesNotCollected
	   SET Case_Status = 'MembershipChanges',
           Case_ClosedBy = -1,
           Case_Closed = GETDATE(),
           Case_UpdatedBy = -1,
           Case_UpdatedDate = GETDATE(),
           Case_TimeStamp = GETDATE()
	 WHERE rn = 1
	   AND TransactionType = 'C';


	;WITH PendingCasesNotCollected AS
	(
	   SELECT case_CaseId, case_Status, tph.TransactionType, Case_ClosedBy, Case_Closed, Case_UpdatedBy, Case_UpdatedDate, Case_TimeStamp,
			  ROW_NUMBER() OVER (PARTITION BY UDF_MASTER_INVOICE ORDER BY TransactionType DESC) AS rn
		FROM CRM.dbo.Cases WITH (NOLOCK)
			 INNER JOIN MAS_PRC.dbo.AR_InvoiceHistoryHeader ihh WITH (NOLOCK) ON case_PRMasterInvoiceNumber = UDF_MASTER_INVOICE
			 INNER JOIN MAS_PRC.dbo.AR_OpenInvoice oi WITH (NOLOCK) ON oi.InvoiceNo = ihh.InvoiceNo
			 INNER JOIN MAS_PRC.dbo.AR_TransactionPaymentHistory tph WITH (NOLOCK) ON tph.InvoiceNo = ihh.InvoiceNo
	   WHERE tph.TransactionType IN ('P', 'C')
		 AND UDF_MASTER_INVOICE <> ''
		 AND Case_Status IN ('Pending', 'Open')
		 AND Balance = 0
	)
	UPDATE PendingCasesNotCollected
	   SET Case_Status = 'NotCollected',
           Case_ClosedBy = -1,
           Case_Closed = GETDATE(),
           Case_UpdatedBy = -1,
           Case_UpdatedDate = GETDATE(),
           Case_TimeStamp = GETDATE()
	 WHERE rn = 1
	   AND TransactionType = 'C';

	SET @ClosedCOunt = @ClosedCOunt + @@ROWCOUNT
	
	SELECT @ClosedCOunt;
END
Go			  




IF EXISTS (SELECT Name FROM sys.procedures WHERE Name = N'usp_GenerateClearingHouseTESRequests')
	DROP PROCEDURE usp_GenerateClearingHouseTESRequests
GO

CREATE PROCEDURE dbo.usp_GenerateClearingHouseTESRequests
	@SubjectCompanyList varchar(max),
	@Commit int = 0
As
BEGIN

	IF (@Commit = 0) begin
		PRINT '*************************************************************'
		PRINT 'NOTE: COMMIT CHANGES IS TURNED OFF. NO CHANGES WILL BE SAVED!'
		PRINT '*************************************************************'
		PRINT ''
	END

	BEGIN TRANSACTION
	BEGIN TRY

		DECLARE @Start datetime = GETDATE()
		
		DECLARE @Email table (
			CompanyID int,
			PersonID int,
			EmailAddress varchar(255));

		--
		-- Look for Person emails first.  If more than one person if found with
		-- an email address, sort by role targetting the executives first.
		---
		INSERT INTO @Email
		SELECT comp_CompanyID, peli_PersonID, Emai_EmailAddress FROM (
				SELECT comp_CompanyID, peli_PersonID, peli_PRRole, ep.Emai_EmailAddress, 
					   ROW_NUMBER() over (partition by comp_CompanyID ORDER BY CASE WHEN peli_PRRole LIKE '%,HE,%' THEN 1 WHEN peli_PRRole LIKE '%,H?,%' THEN 2 WHEN peli_PRRole LIKE '%,E,%' THEN 3 WHEN peli_PRRole LIKE '%,F,%' THEN 4 WHEN peli_PRRole LIKE '%,F,%' THEN 5   ELSE 9999 END) as PersonRank
				  FROM Company WITH (NOLOCK)
					   INNER JOIN PRCompanyClassification WITH (NOLOCK) ON comp_CompanyID = prc2_CompanyID
					   INNER JOIN Person_Link WITH (NOLOCK) ON comp_CompanyID = peli_CompanyID AND peli_PRStatus = '1'
					   INNER JOIN vPersonEmail ep WITH (NOLOCK) ON peli_PersonID = ep.elink_RecordID AND ep.emai_CompanyID = comp_CompanyID AND ep.elink_Type = 'E'
					   LEFT OUTER JOIN PRCompanyInfoProfile WITH (NOLOCK) ON comp_CompanyID = prc5_CompanyID
				 WHERE comp_PRIndustryType = 'L'
				   AND comp_PRType = 'H'
				   AND comp_PRListingStatus IN ('L', 'H', 'LUV')
				   AND prc2_ClassificationId IN (2182, 2185, 2189)  --Mill and/or Office Wholesaler and/or Stocking Wholesalers
				   AND prc5_ARSubmitter IS NULL -- Exclude AR Submitters
				   AND comp_PRReceiveTESCode IS NULL -- All the codes mean something bad, so select companies w/o a code.
		) T1 WHERE PersonRank = 1
		ORDER BY comp_CompanyID		   



		--
		--  For the remaining companies, grab the company level 
		--  email.
		--
		INSERT INTO @Email
		SELECT comp_CompanyID, NULL, Emai_EmailAddress FROM (
				SELECT comp_CompanyID, ep.Emai_EmailAddress, 
					   ROW_NUMBER() over (partition by comp_CompanyID ORDER BY emai_CreatedDate ) as EmailRank
				  FROM Company WITH (NOLOCK)
					   INNER JOIN PRCompanyClassification WITH (NOLOCK) ON comp_CompanyID = prc2_CompanyID
					   INNER JOIN vCompanyEmail ep WITH (NOLOCK) ON comp_CompanyID = ep.elink_RecordID AND ep.elink_Type = 'E'
					   LEFT OUTER JOIN PRCompanyInfoProfile WITH (NOLOCK) ON comp_CompanyID = prc5_CompanyID
				 WHERE comp_PRIndustryType = 'L'
				   AND comp_PRListingStatus IN ('L', 'H', 'LUV')
				   AND comp_PRType = 'H'
				   AND prc2_ClassificationId IN (2182, 2185, 2189)  --Mill and/or Office Wholesaler and/or Stocking Wholesalers
				   AND prc5_ARSubmitter IS NULL -- Exclude AR Submitters
				   AND comp_PRReceiveTESCode IS NULL -- All the codes mean something bad, so select companies w/o a code.
		) T1 
		WHERE EmailRank = 1
		  AND comp_CompanyID NOT IN (SELECT CompanyID FROM @Email)
		ORDER BY comp_CompanyID		   



		INSERT INTO PRTESRequest (prtesr_ResponderCompanyID, prtesr_SubjectCompanyID, prtesr_Source, prtesr_SentMethod, prtesr_OverridePersonID, prtesr_OverrideAddress)
		SELECT DISTINCT CompanyID, CAST(value as Int) as SubjectCompanyID, 'LCH', 'E', PersonID, EmailAddress
		  FROM @Email
			   CROSS APPLY dbo.Tokenize(@SubjectCompanyList, ',')
		 WHERE dbo.ufn_IsEligibleForManualTES(CompanyID, CAST(value as Int)) = 1
		   ORDER BY CompanyID, CAST(value as Int);


		SELECT COUNT(1) As TESRequests, 
		       COUNT(DISTINCT prtesr_ResponderCompanyID) As DistinctResponders,
			   COUNT(DISTINCT prtesr_SubjectCompanyID) As DistinctSubjects
		  FROM PRTESRequest
		 WHERE prtesr_Source = 'LCH'
		   AND prtesr_CreatedDate BETWEEN @Start AND GETDATE()


		IF (@Commit = 1) BEGIN
			COMMIT TRANSACTION;
		END ELSE BEGIN
			ROLLBACK TRANSACTION;
		END

	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		EXEC usp_RethrowError;
	END CATCH
END
Go

IF EXISTS (SELECT Name FROM sys.procedures WHERE Name = N'usp_GetBluePrintsEditionArchive')
	DROP PROCEDURE usp_GetBluePrintsEditionArchive
GO

CREATE PROCEDURE dbo.usp_GetBluePrintsEditionArchive
As
BEGIN

	DECLARE @MyTable table (
		ndx int primary key identity(1,1),
		prpbed_PublicationEditionID int,
		prpbed_Name varchar(1000),
		prpbed_CoverArtFileName varchar(1000), 
		prpbed_PublishDate datetime,
		prpbed_CoverArtThumbFileName varchar(1000)
	)


	DECLARE @StartDate datetime, @EndDate datetime
	DECLARE @Year int = YEAR(GETDATE())
	DECLARE @EndYear int = 2002
	DECLARE @RowCount int = -1

	WHILE (@Year >= @EndYear) BEGIN

		SET @StartDate = CAST(@Year as varchar(4)) + '-01-01'
		SET @EndDate = CAST(@Year as varchar(4)) + '-12-31'

		INSERT INTO @MyTable
		SELECT prpbed_PublicationEditionID, prpbed_Name, prpbed_CoverArtFileName, prpbed_PublishDate, ISNULL(prpbed_CoverArtThumbFileName, prpbed_CoverArtFileName) 
		  FROM PRPublicationEdition WITH (NOLOCK) 
		 WHERE prpbed_PublishDate BETWEEN @StartDate AND @EndDate
		   AND prpbed_PublishDate <= GETDATE()
	  ORDER BY prpbed_PublishDate

	  SET @RowCount = @@ROWCOUNT

	  SET @Year = @Year - 1
	END


	SELECT * FROM @MyTable ORDER BY ndx;
END
Go

IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[usp_DSIRSummary]') AND Type IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[usp_DSIRSummary]
GO

CREATE PROCEDURE [dbo].[usp_DSIRSummary]
	@StartDate DATETIME, 
	@EndDate DATETIME, 
	@Industry varchar(100)
AS 
BEGIN


--Declare @Startdate datetime = '3/12/2013';
--Declare @Enddate datetime = getdate();
--Calculate Reporting Period Dates
	--Daily
	DECLARE @ComputedEndDate DATETIME = DATEADD(SECOND, -1, DATEADD(DAY, 1, @EndDate))
	--Weekly
	DECLARE @WeekStartDate DATETIME = CONVERT(VARCHAR(100), 
		(SELECT DATEADD(dd,-(DATEPART(dw,@ComputedEndDate) - 1), @ComputedEndDate)),101) 
	--Monthly
	DECLARE @MonthStartDate DATETIME = CONVERT(VARCHAR(10), 
		MONTH(@ComputedEndDate)) + '/1/' + CONVERT(VARCHAR(10), YEAR(@ComputedEndDate))
	--Yearly
	DECLARE @YearStartDate DATETIME = '1/1/' + CONVERT(VARCHAR(10), YEAR(@ComputedEndDate)) 

	-- Create mapping of product line to report groupings 
	DECLARE @Grp TABLE (ProdLine VARCHAR(100), Grp VARCHAR(100), Descr VARCHAR(MAX), Ord INT, ServiceType VARCHAR(100))

	INSERT INTO @Grp (ProdLine, Descr, Ord, Grp, ServiceType)
	VALUES ('MSE', 'Member' + CHAR(10) + '(New Ms, Ups & Downs)', 1, 'Member', 'Subscription');

	INSERT INTO @Grp (ProdLine, Descr, Ord, Grp, ServiceType)
	VALUES ('MSP', 'Member' + CHAR(10) + '(New Ms, Ups & Downs)', 1, 'Member', 'Subscription');

	INSERT INTO @Grp (ProdLine, Descr, Ord, Grp, ServiceType)
	VALUES ('ASE', 'Ancillary' + CHAR(10) + '(Book Copies, Licenses)', 2, 'Ancillary', 'Subscription');

	INSERT INTO @Grp (ProdLine, Descr, Ord, Grp, ServiceType)
	VALUES ('ASP', 'Ancillary' + CHAR(10) + '(Book Copies, Licenses)', 2, 'Ancillary', 'Subscription');

	INSERT INTO @Grp (ProdLine, Descr, Ord, Grp, ServiceType)
	VALUES ('LCP', 'Ancillary' + CHAR(10) + '(Book Copies, Licenses)', 2, 'Ancillary', 'Subscription');

	INSERT INTO @Grp (ProdLine, Descr, Ord, Grp, ServiceType)
	VALUES ('SPR', 'Ancillary' + CHAR(10) + '(Book Copies, Licenses)', 2, 'Ancillary', 'Subscription');

	INSERT INTO @Grp (ProdLine, Descr, Ord, Grp, ServiceType)
	VALUES ('ADE', 'Ads' + CHAR(10) + '(BP & BBOS)', 3, 'Ad', 'Non-Subscription');

	INSERT INTO @Grp (ProdLine, Descr, Ord, Grp, ServiceType)
	VALUES ('ADP', 'Ads' + CHAR(10) + '(BP & BBOS)', 3, 'Ad', 'Non-Subscription');

	INSERT INTO @Grp (ProdLine, Descr, Ord, Grp, ServiceType)
	VALUES ('SEM', 'Special' + CHAR(10) + '(Collections & Units)', 4, 'Special', 'Non-Subscription');

	INSERT INTO @Grp (ProdLine, Descr, Ord, Grp, ServiceType)
	VALUES ('SPN', 'Special' + CHAR(10) + '(Collections & Units)', 4, 'Special', 'Non-Subscription');

	INSERT INTO @Grp (ProdLine, Descr, Ord, Grp, ServiceType)
	VALUES ('SS','Special' + CHAR(10) + '(Collections & Units)', 4, 'Special', 'Non-Subscription');

	INSERT INTO @Grp (ProdLine, Descr, Ord, Grp, ServiceType)
	VALUES ('UNP', 'Special' + CHAR(10) + '(Collections & Units)', 4, 'Special', 'Non-Subscription');

	INSERT INTO @Grp (ProdLine, Descr, Ord, Grp, ServiceType)
	VALUES ('LCL', 'Lumber', 5, 'Lumber', 'Subscription');

	INSERT INTO @Grp (ProdLine, Descr, Ord, Grp, ServiceType)
	VALUES ('MSL', 'Lumber', 5, 'Lumber', 'Subscription');

	INSERT INTO @Grp (ProdLine, Descr, Ord, Grp, ServiceType)
	VALUES ('UNL', 'Lumber', 5, 'Lumber', 'Non-Subscription');

	INSERT INTO @Grp (ProdLine, Descr, Ord, Grp)
	VALUES ('DL', 'DL', 6, 'DL');
	
	
	DECLARE @Activity TABLE
		(ActionCode VARCHAR(10)
		, CreatedDate DATETIME
		, ItemCode VARCHAR(100)
		, AmtChange FLOAT
		, QtyChange INT)
	
	--Get Subscription Activity
	INSERT INTO @Activity (ActionCode, CreatedDate, ItemCode,AmtChange, QtyChange)
	SELECT prsoat_ActionCode,
		   prsoat_CreatedDate,
		   prsoat_ItemCode,
		   prsoat_ExtensionAmtChange,
		   prsoat_QuantityChange
	  FROM CRM.dbo.PRSalesOrderAuditTrail WITH (NOLOCK)		
	 WHERE prsoat_CreatedDate BETWEEN @YearStartDate AND @ComputedEndDate;
	
	--Get Special Charge Activity
	INSERT INTO @Activity (CreatedDate, ItemCode, AmtChange)
	SELECT hdr.DateCreated,
		   det.ItemCode,
		   det.LastExtensionAmt
	  FROM MAS_PRC.dbo.SO_SalesOrderHistoryHeader hdr WITH (NOLOCK)
	       INNER JOIN MAS_PRC.dbo.SO_SalesOrderHistoryDetail det WITH (NOLOCK) ON hdr.SalesOrderNo = det.SalesOrderNo
	       INNER JOIN MAS_PRC.dbo.CI_Item it WITH (NOLOCK) ON det.ItemCode = it.ItemCode 
	       INNER JOIN @Grp ON ProdLine = ProductLine
	 WHERE Grp IN ('Special', 'Ad')
	   AND hdr.OrderStatus IN ('A', 'C') 
	   AND det.SalesAcctKey <> '' 

	SELECT Grp,
	       Descr,
	       ServiceType,
	       'Action' = CASE 
				WHEN Grp = 'Ad' THEN 'Advertising'
				WHEN Grp = 'Special' THEN 'Special Charge'
				WHEN ActionCode = 'I' THEN '1'
				WHEN ActionCode IS NULL THEN '1'
				WHEN ActionCode = 'C' THEN '3'		
				--WHEN ActionCode = 'U' AND Grp = 'Member' THEN 2
				ELSE 
					CASE WHEN QtyChange > 0 AND AmtChange > 0 THEN '1'
					ELSE '3'
					END
				END,
	       'Time Period' = CASE 
				WHEN CreatedDate >= @Startdate THEN 1 
				WHEN CreatedDate >= @WeekStartDate THEN 2 
				WHEN CreatedDate >= @MonthStartDate THEN 3 
				ELSE 4 END,
	       'Amt' = AmtChange,
	       Ord
      FROM @Activity a
           INNER JOIN MAS_PRC.dbo.CI_Item it WITH (NOLOCK) ON a.ItemCode = it.ItemCode 
           INNER JOIN @Grp ON ProdLine = ProductLine
     WHERE CreatedDate BETWEEN @YearStartDate AND @ComputedEndDate 
	   AND Grp != 'DL'
	   AND Grp != CASE WHEN @Industry = 'P' THEN 'Lumber' ELSE '' END
	   AND Grp = CASE WHEN @Industry = 'L' THEN 'Lumber' ELSE Grp END

END
Go


IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[usp_UpdateAUSListFromARAging]') AND Type IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[usp_UpdateAUSListFromARAging]
GO

CREATE PROCEDURE [dbo].[usp_UpdateAUSListFromARAging]
	@CompanyID int, 
	@WebUserID int, 
    @UserID int = -1,
	@ARAgingID int = NULL
AS 
BEGIN

	DECLARE @AUSListID int

	SELECT @AUSListID = prwucl_WebUserListID
      FROM PRWebUserList
	 WHERE prwucl_WebUserID = @WebUserID
	   AND prwucl_TypeCode = 'AUS'

	IF @AUSListID IS NULL BEGIN
		RAISERROR('Unable to find Alerts list.',16,-1)      
		RETURN
	END

	-- Most of our triggers assume a one record at a time insert.
	DECLARE @MyTable table (
		ndx int identity(1,1) primary key,
		SubjectCompanyID int
	)


/*
		INSERT INTO @MyTable (SubjectCompanyID)
		 SELECT DISTINCT prar_PRCoCompanyId
		  FROM PRARTranslation WITH (NOLOCK)
			   INNER JOIN PRARAgingDetail WITH (NOLOCK) ON praad_SubjectCompanyID = prar_PRCoCompanyId
			   INNER JOIN Company WITH (NOLOCK) ON comp_CompanyId = prar_PRCoCompanyId
		 WHERE comp_PRListingStatus IN ('L', 'H', 'LUV')
		   AND prar_CompanyId = @CompanyID
		   AND praad_ARAgingID = ISNULL(@ARAgingID, praad_ARAgingID)
		   AND prar_PRCoCompanyId NOT IN (SELECT prwuld_AssociatedID
											 FROM PRWebUserListDetail WITH (NOLOCK)
										    WHERE prwuld_WebUserListID = @AUSListID);
*/

		INSERT INTO @MyTable (SubjectCompanyID)
		 SELECT DISTINCT praad_SubjectCompanyID
		  FROM PRARAgingDetail WITH (NOLOCK)
		       INNER JOIN PRARAging WITH (NOLOCK) ON praad_ARAgingID = praa_ARAgingID
			   INNER JOIN Company WITH (NOLOCK) ON comp_CompanyId = praad_SubjectCompanyID
		 WHERE comp_PRListingStatus IN ('L', 'H', 'LUV')
		   AND praa_CompanyId = @CompanyID
		   AND praad_ARAgingID = ISNULL(@ARAgingID, praad_ARAgingID)
		   AND praad_SubjectCompanyID NOT IN (SELECT prwuld_AssociatedID
											     FROM PRWebUserListDetail WITH (NOLOCK)
											    WHERE prwuld_WebUserListID = @AUSListID);



	DECLARE @Count int, @Index int, @SubjectCompanyID int

	SELECT @Count = COUNT(1) FROM @MyTable;
	SET @Index = 0

	WHILE (@Index < @Count) BEGIN

		SET @Index = @Index + 1

		SELECT @SubjectCompanyID = SubjectCompanyID
		  FROM @MyTable
		 WHERE ndx = @Index;

		INSERT INTO PRWebUserListDetail (prwuld_WebUserListID, prwuld_AssociatedID, prwuld_AssociatedType, prwuld_CreatedBy, prwuld_UpdatedBy)
		VALUES (@AUSListID, @SubjectCompanyID, 'C', @UserID, @UserID);
	END

END
Go


IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[usp_CalculateIndustryAverageRatings]') AND Type IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[usp_CalculateIndustryAverageRatings]
GO

CREATE PROCEDURE [dbo].[usp_CalculateIndustryAverageRatings]
        @IndustryType varchar(40),
		@CurrentPeriodMonths int,
        @PreviousPeriodMonths int
        
AS 
BEGIN

	DECLARE @CustomCaptionFamily varchar(30) = 'IndustryAverageRatings_' + @IndustryType;
	DECLARE @CaptCode varchar(40)

	DECLARE @IntegrityCount int, @IntegrityAverage decimal(12,3)
	DECLARE @PayCount int, @PayMedian varchar(30), @PayMedianNumeric decimal(12,3)
	DECLARE @Start datetime, @End datetime

	SET @End = GETDATE()
	SET @Start = DATEADD(month, 0-@CurrentPeriodMonths, @End)

	SELECT @IntegrityCount = prtr_INT_Count, 
	       @IntegrityAverage = prtr_INT_Avg, 
		   @PayCount = prtr_Pay_Count, 
		   @PayMedian = prtr_Pay_Median, 
		   @PayMedianNumeric = prtr_Pay_MedianNumeric
      FROM dbo.ufn_GetTradeReportAnalysis(NULL, @Start, @End, NULL, 'N', NULL, NULL, NULL, @IndustryType, NULL)


	SET @CaptCode = 'IntegrityAverage_Current'
	IF EXISTS (SELECT 'X' FROM Custom_Captions WHERE capt_family = @CustomCaptionFamily AND capt_code = @CaptCode) BEGIN
		UPDATE Custom_Captions
		   SET capt_us = CAST(@IntegrityAverage as varchar(25))
		 WHERE capt_family = @CustomCaptionFamily 
		   AND capt_code = @CaptCode
	END ELSE BEGIN
		EXEC usp_TravantCRM_CreateDropdownValue @CustomCaptionFamily, @CaptCode, 0, @IntegrityAverage
	END

	SET @CaptCode = 'PayMedian_Current'
	IF EXISTS (SELECT 'X' FROM Custom_Captions WHERE capt_family = @CustomCaptionFamily AND capt_code = @CaptCode) BEGIN
		UPDATE Custom_Captions
		   SET capt_us = @PayMedian
		 WHERE capt_family = @CustomCaptionFamily 
		   AND capt_code = @CaptCode
	END ELSE BEGIN
		EXEC usp_TravantCRM_CreateDropdownValue @CustomCaptionFamily, @CaptCode, 0, @PayMedian
	END



	SET @End = @Start
	SET @Start = DATEADD(month, 0-@PreviousPeriodMonths, @End)

	SELECT @IntegrityCount = prtr_INT_Count, 
	       @IntegrityAverage = prtr_INT_Avg, 
		   @PayCount = prtr_Pay_Count, 
		   @PayMedian = prtr_Pay_Median, 
		   @PayMedianNumeric = prtr_Pay_MedianNumeric
      FROM dbo.ufn_GetTradeReportAnalysis(NULL, @Start, @End, NULL, 'N', NULL, NULL, NULL, @IndustryType, NULL)

	SET @CaptCode = 'IntegrityAverage_Previous'
	IF EXISTS (SELECT 'X' FROM Custom_Captions WHERE capt_family = @CustomCaptionFamily AND capt_code = @CaptCode) BEGIN
		UPDATE Custom_Captions
		   SET capt_us = CAST(@IntegrityAverage as varchar(25))
		 WHERE capt_family = @CustomCaptionFamily 
		   AND capt_code = @CaptCode
	END ELSE BEGIN
		EXEC usp_TravantCRM_CreateDropdownValue @CustomCaptionFamily, @CaptCode, 0, @IntegrityAverage
	END

	SET @CaptCode = 'PayMedian_Previous'
	IF EXISTS (SELECT 'X' FROM Custom_Captions WHERE capt_family = @CustomCaptionFamily AND capt_code = @CaptCode) BEGIN
		UPDATE Custom_Captions
		   SET capt_us = @PayMedian
		 WHERE capt_family = @CustomCaptionFamily 
		   AND capt_code = @CaptCode
	END ELSE BEGIN
		EXEC usp_TravantCRM_CreateDropdownValue @CustomCaptionFamily, @CaptCode, 0, @PayMedian
	END

	SELECT capt_family, capt_code, capt_us
	  FROM Custom_Captions 
	 WHERE capt_family = @CustomCaptionFamily;
END
Go

CREATE OR ALTER PROCEDURE [dbo].[usp_UpdateServiceStartEndDates]
AS 
BEGIN

	--
	--  If this company has a primary service and no service
	--  start date, let's set it.
	UPDATE Company
	   SET comp_PRServiceStartDate = DATEADD(dd, 0, DATEDIFF(dd, 0, prse_CreatedDate)),
		   comp_PRServiceEndDate = NULL
	  FROM PRService
	 WHERE comp_CompanyID = prse_CompanyID
	   AND prse_Primary = 'Y'
	   AND comp_CompanyID NOT IN (  -- Exclude any upgrade/downgrades
		   SELECT prsoat_SoldToCompany
			 FROM PRSalesOrderAuditTrail WITH (NOLOCK) 
			WHERE prsoat_CreatedDate < DATEADD(hour, -18, GETDATE()) 
			  AND prsoat_CancelReasonCode IN ('C24', 'C30', 'D40', 'D41', 'D42'))


	UPDATE Company
	   SET comp_PROriginalServiceStartDate = DATEADD(dd, 0, DATEDIFF(dd, 0, prse_CreatedDate))
	  FROM PRService
	 WHERE comp_CompanyID = prse_CompanyID
	   AND prse_Primary = 'Y'
	   AND comp_PROriginalServiceStartDate IS NULL
	   AND comp_CompanyID NOT IN (  -- Exclude any upgrade/downgrades
		   SELECT prsoat_SoldToCompany
			 FROM PRSalesOrderAuditTrail WITH (NOLOCK) 
			WHERE prsoat_CreatedDate < DATEADD(hour, -18, GETDATE()) 
			  AND prsoat_CancelReasonCode IN ('C24', 'C30', 'D40', 'D41', 'D42'))

	--
	--  If this company has a primary service and 
	--  a service end date, clear it out.  The member
	--  probably cancelled their service for a period 
	--  and has now re-established it.
	UPDATE Company
	   SET comp_PRServiceEndDate = NULL
	  FROM PRService
	 WHERE comp_CompanyID = prse_CompanyID
	   AND prse_Primary = 'Y'
	   AND comp_PRServiceEndDate IS NOT NULL;


	--
	--  If this company does not have a primary service
	--  has a service start date with no service end
	--  date, then set the service end date.  They probably
	--  cancelled.
	UPDATE Company
	   SET comp_PRServiceEndDate = DATEADD(dd, 0, DATEDIFF(dd, 0, GETDATE()))
	  FROM Company
	       LEFT OUTER JOIN PRService ON comp_CompanyID = prse_CompanyID AND prse_Primary = 'Y'
	 WHERE comp_PRServiceStartDate IS NOT NULL
	   AND comp_PRServiceEndDate IS NULL
	   AND prse_CompanyID IS NULL;

END      
Go


IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[usp_ProcessDuplicateUser]') AND Type IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[usp_ProcessDuplicateUser]
GO


CREATE PROCEDURE [dbo].[usp_ProcessDuplicateUser]
	@Email varchar(255),
	@Commit bit = 0
As
BEGIN

	IF (@Commit = 0) begin
		PRINT '*************************************************************'
		PRINT 'NOTE: COMMIT CHANGES IS TURNED OFF. NO CHANGES WILL BE SAVED!'
		PRINT '*************************************************************'
		PRINT ''
	END

	BEGIN TRANSACTION
	BEGIN TRY

		-- First make sure we have a duplicate
		DECLARE @Count int
		SELECT @Count = COUNT(1) 
		  FROM PRWebUser WITH (NOLOCK) 
		 WHERE prwu_Email = @Email

		IF (@Count < 2) BEGIN
			RAISERROR ('Unable to find a duplicate records.', 16, 1)
			RETURN
		END

		IF (@Count > 2) BEGIN
			RAISERROR ('Found more than two (2) records. Please contact system support.', 16, 1)
			RETURN
		END

		SELECT prwu_WebUserID, prwu_AccessLevel, prwu_ServiceCode, prwu_Email, prwu_FirstName, prwu_LastName, prwu_HQID, prwu_BBID, prwu_Disabled
		  FROM PRWebUser WITH (NOLOCK)
		 WHERE prwu_Email = @Email
		ORDER BY CAST(prwu_AccessLevel as Int);

		DECLARE @WebUserID int = null
		SELECT @WebUserID = prwu_WebUserID
		  FROM PRWebUser WITH (NOLOCK)
		 WHERE prwu_Email = @Email
		   AND CAST(prwu_AccessLevel as Int) < 100
	  ORDER BY prwu_HQID DESC;

		IF (@WebUserID IS NULL) BEGIN

			SELECT @Count = COUNT(1) 
			  FROM PRWebUser WITH (NOLOCK)
			 WHERE prwu_Email = @Email
			   AND prwu_Disabled = 'Y';

			IF (@Count = 1) BEGIN
				SELECT @WebUserID = prwu_WebUserID
				  FROM PRWebUser WITH (NOLOCK)
				 WHERE prwu_Email = @Email
				   AND prwu_Disabled = 'Y';
			END

		END



		IF (@WebUserID IS NULL) BEGIN
			RAISERROR ('Unable to find a registered or disabled user record to remove. Please contact system support.', 16, 1)
			RETURN
		END

		UPDATE PRWebuser
		   SET prwu_Email = NULL,
		       prwu_UpdatedDate = GETDATE(),
			   prwu_UpdatedBy = -1,
			   prwu_TimeStamp = GETDATE()
		 WHERE prwu_WebuserID = @WebUserID

		SELECT prwu_WebUserID, prwu_AccessLevel, prwu_ServiceCode, prwu_Email, prwu_FirstName, prwu_LastName, prwu_HQID, prwu_BBID, prwu_Disabled
		  FROM PRWebUser WITH (NOLOCK)
		 WHERE prwu_Email = @Email
		ORDER BY CAST(prwu_AccessLevel as Int);

		IF (@Commit = 1) BEGIN
			COMMIT TRANSACTION;
		END ELSE BEGIN
			ROLLBACK TRANSACTION;
		END
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
		EXEC usp_RethrowError;
	END CATCH
END
Go


If Exists (Select name from sysobjects where name = 'usp_CleanupTESRequests' and type='P') Drop Procedure dbo.usp_CleanupTESRequests
Go

CREATE PROCEDURE dbo.usp_CleanupTESRequests
AS 
BEGIN

/*
	SELECT prtesr_TESRequestID,
		   prtesr_ResponderCompanyID,
		   prtesr_SubjectCompanyID
	 FROM (
		  SELECT prtesr_TESRequestID,
				 prtesr_ResponderCompanyID,
				 prtesr_SubjectCompanyID,
				 ROW_NUMBER() OVER(PARTITION BY prtesr_ResponderCompanyID, prtesr_SubjectCompanyID ORDER BY prtesr_TESRequestID) AS rn
		   FROM PRTESRequest
		  WHERE prtesr_SentDateTime IS NULL
			AND prtesr_Received IS NULL
		 ) AS T
	where rn > 1;
*/

	--
	-- Delete duplicate unsent requests
	WITH DuplicateData AS (
		SELECT ROW_NUMBER() OVER(PARTITION BY prtesr_ResponderCompanyID, prtesr_SubjectCompanyID ORDER BY prtesr_TESRequestID) AS row_num 
		  FROM PRTESRequest
		 WHERE prtesr_SentDateTime IS NULL
		   AND prtesr_Received IS NULL
		   AND prtesr_Source <> 'VI'
	)
	DELETE FROM DuplicateData WHERE row_num > 1;

/*
	SELECT COUNT(1)
	  FROM PRTESRequest
	 WHERE prtesr_SubjectCompanyID=-1;
*/

	--
	--  Delete requests with invalid subjects.
	--
	DELETE
	  FROM PRTESRequest
	 WHERE prtesr_SubjectCompanyID=-1



/*
	SELECT COUNT(1)
	  FROM PRTESRequest
	 WHERE prtesr_ResponderCompanyID=-1;
*/

	--
	--  Delete requests with invalid responders.
	--
	DELETE
	  FROM PRTESRequest
	 WHERE prtesr_ResponderCompanyID=-1

END
Go

If Exists (Select name from sysobjects where name = 'usp_DeactivateCompanyRelationships' and type='P') Drop Procedure dbo.usp_DeactivateCompanyRelationships
Go

CREATE PROCEDURE dbo.usp_DeactivateCompanyRelationships
	@LeftCompanyID int,
	@RightCompanyID int,
	@UserID int = -1
AS 
BEGIN

	--
	--  If we have some non-type 15 CLs relationship types,
	--  then deactivate the type 15.
	--
	UPDATE PRCompanyRelationship
	   SET prcr_Active = NULL,
	       prcr_UpdatedBy = @UserID,
		   prcr_UpdatedDate = GetDate()
	 WHERE prcr_CompanyRelationshipId IN (
			SELECT prcr_CompanyRelationshipId
			  FROM PRCompanyRelationship
				   INNER JOIN (SELECT DISTINCT prcr_LeftCompanyId, prcr_RightCompanyID
								 FROM PRCompanyRelationship
								WHERE prcr_Active = 'Y'
								  AND prcr_Type IN ('09', '10', '11', '12', '13')
				  			      AND prcr_LeftCompanyId = @LeftCompanyID
			                      AND prcr_RightCompanyId = @RightCompanyID
							  ) as CLTypes ON PRCompanyRelationship.prcr_LeftCompanyID = CLTypes.prcr_LeftCompanyID
										  AND PRCompanyRelationship.prcr_RightCompanyID = CLTypes.prcr_RightCompanyID
			 WHERE prcr_Active = 'Y'
			   AND prcr_Type = '15'
			   AND PRCompanyRelationship.prcr_LeftCompanyId = @LeftCompanyID
			   AND PRCompanyRelationship.prcr_RightCompanyId = @RightCompanyID
	        )
	   AND prcr_Active = 'Y';
END
Go


If Exists (Select name from sysobjects where name = 'usp_ResetConnectionListDate' and type='P') Drop Procedure dbo.usp_ResetConnectionListDate
Go

CREATE PROCEDURE dbo.usp_ResetConnectionListDate
	@UserID int = -1
AS 
BEGIN

	UPDATE Company
	   SET comp_PRConnectionListDate = NULL,
		   comp_UpdatedBy = @UserID,
		   comp_UpdatedDate = GETDATE()
	 WHERE comp_CompanyID IN (	   
			 SELECT comp_CompanyID
			  FROM Company WITH (NOLOCK)
				   LEFT OUTER JOIN PRCompanyRelationship WITH (NOLOCK) ON comp_CompanyID = prcr_LeftCompanyID
	   																  AND prcr_Active = 'Y'
																	  AND prcr_Type IN ('09', '10', '11', '12', '13', '14', '15', '16')
			 WHERE comp_PRConnectionListDate IS NOT NULL
			   AND comp_PRListingStatus NOT IN ('D', 'N1') 
			GROUP BY comp_CompanyID
			HAVING COUNT(prcr_RightCompanyID) = 0)

END
Go


IF EXISTS (SELECT 'x' FROM sysobjects WHERE name = 'usp_UpdateWordPressNews' and type='P') 
	DROP PROCEDURE dbo.usp_UpdateWordPressNews
Go

CREATE PROCEDURE dbo.usp_UpdateWordPressNews
	@ArticleID int,
	@IndustryType varchar(10)
AS 
BEGIN

	DECLARE @PostID int
	IF (@IndustryType = 'P') BEGIN
		SELECT @PostID = post_id
		  FROM WordPressProduce.dbo.wp_PostMeta
		 WHERE meta_key = 'prpbar_PublicationArticleID'
		   AND meta_value = @ArticleID
		IF (@PostID IS NOT NULL) BEGIN
			UPDATE [WordPressProduce].[dbo].wp_posts
			   SET post_date = prpbar_PublishDate, 
				   post_date_gmt = DATEADD(hour, 6, prpbar_PublishDate), 
				   post_content = REPLACE(prpbar_Body, 'ExternalLink.aspx', CRM.dbo.ufn_GetCustomCaptionValue('BBOS', 'URL', 'en-us')  + 'ExternalLink.aspx'),  
				   post_title = prpbar_Name, 
				   post_status = CASE WHEN prpbar_PublishDate > GETDATE() THEN 'future' ELSE 'publish' END,
				   post_excerpt = ISNULL(prpbar_Abstract, ''), 
				   post_name = CRM.dbo.ufn_PreparePostName(prpbar_Name),
				   post_modified = prpbar_CreatedDate,
				   post_modified_gmt =  DATEADD(hour, 6, prpbar_CreatedDate)
			  FROM CRM.dbo.PRPublicationArticle 
			 WHERE id = @PostID
			   AND prpbar_PublicationArticleID = @ArticleID
		END ELSE BEGIN
			INSERT INTO [WordPressProduce].[dbo].wp_posts (post_author, post_date, post_date_gmt,  post_content, post_title, post_excerpt, post_status, comment_status, ping_status, 
													post_password, post_name, post_modified, post_modified_gmt, post_content_filtered, post_parent,
													menu_order, post_type, post_mime_type, comment_count, to_ping, pinged)
			SELECT post_author = [WordPress].[dbo].wp_users.ID, 
				   post_date = prpbar_PublishDate, 
				   post_date_gmt = DATEADD(hour, 6, prpbar_PublishDate), 
				   post_content = REPLACE(prpbar_Body, 'ExternalLink.aspx', CRM.dbo.ufn_GetCustomCaptionValue('BBOS', 'URL', 'en-us')  + 'ExternalLink.aspx'), 
				   post_title = prpbar_Name, 
				   post_excerpt = ISNULL(prpbar_Abstract, ''), 
				   post_status = CASE WHEN prpbar_PublishDate > GETDATE() THEN 'future' ELSE 'publish' END,
				   comment_status = 'open',
				   ping_status = 'open',
				   post_password = '',
				   post_name = CRM.dbo.ufn_PreparePostName(prpbar_Name),
				   post_modified = prpbar_CreatedDate,
				   post_modified_gmt =  DATEADD(hour, 6, prpbar_CreatedDate),
				   post_content_filtered = '',
				   post_parent = 0,
				   menu_order = 0,
				   post_type = 'post',
				   post_mime_type = '', 
				   comment_count = 0,
				   to_ping = '',
				   pinged = ''
			  FROM CRM.dbo.PRPublicationArticle 
				   INNER JOIN CRM.dbo.users ON prpbar_CreatedBy = user_userid
				   INNER JOIN [WordPress].[dbo].wp_users ON user_logon = user_login
			 WHERE prpbar_PublicationArticleID = @ArticleID;

			INSERT INTO WordPressProduce.dbo.wp_PostMeta (post_id, meta_key, meta_value)
			SELECT ID, 'bbsi_crm', 'true'
			  FROM CRM.dbo.PRPublicationArticle 
				   INNER JOIN WordPressProduce.dbo.wp_posts ON prpbar_Name = post_title AND prpbar_PublishDate = post_date
			 WHERE prpbar_PublicationArticleID = @ArticleID;

			INSERT INTO WordPressProduce.dbo.wp_PostMeta (post_id, meta_key, meta_value)
			SELECT ID, 'prpbar_PublicationArticleID', prpbar_PublicationArticleID
			  FROM CRM.dbo.PRPublicationArticle 
				   INNER JOIN WordPressProduce.dbo.wp_posts ON prpbar_Name = post_title AND prpbar_PublishDate = post_date
			 WHERE prpbar_PublicationArticleID = @ArticleID;

			INSERT INTO WordPressProduce.dbo.wp_term_relationships
			SELECT ID, 3, 0
			  FROM CRM.dbo.PRPublicationArticle 
				   INNER JOIN WordPressProduce.dbo.wp_posts ON prpbar_Name = post_title AND prpbar_PublishDate = post_date
			WHERE prpbar_PublicationArticleID = @ArticleID;

			UPDATE [WordPressProduce].[dbo].wp_posts
			   SET guid = 'http://www.producebluebook.com/?p=' + CAST(id as varchar(10))
			  FROM CRM.dbo.PRPublicationArticle 
				   INNER JOIN WordPressProduce.dbo.wp_posts ON prpbar_Name = post_title AND prpbar_PublishDate = post_date
			 WHERE prpbar_PublicationArticleID = @ArticleID
		END
	END
	IF (@IndustryType = 'L') BEGIN
		SELECT @PostID = post_id
		  FROM WordPressLumber.dbo.wp_postmeta
		 WHERE meta_key = 'prpbar_PublicationArticleID'
		   AND meta_value = @ArticleID
		IF (@PostID IS NOT NULL) BEGIN
			UPDATE [WordPressLumber].[dbo].wp_posts
			   SET post_date = prpbar_PublishDate, 
				   post_date_gmt = DATEADD(hour, 6, prpbar_PublishDate), 
				   post_content = REPLACE(prpbar_Body, 'ExternalLink.aspx', CRM.dbo.ufn_GetCustomCaptionValue('BBOS', 'URL', 'en-us')  + 'ExternalLink.aspx'),  
				   post_title = prpbar_Name, 
				   post_status = CASE WHEN prpbar_PublishDate > GETDATE() THEN 'future' ELSE 'publish' END,
				   post_excerpt = ISNULL(prpbar_Abstract, ''), 
				   post_name = CRM.dbo.ufn_PreparePostName(prpbar_Name),
				   post_modified = prpbar_CreatedDate,
				   post_modified_gmt =  DATEADD(hour, 6, prpbar_CreatedDate)
			  FROM CRM.dbo.PRPublicationArticle 
			 WHERE id = @PostID
			   AND prpbar_PublicationArticleID = @ArticleID
		END ELSE BEGIN
			INSERT INTO [WordPressLumber].[dbo].wp_posts (post_author, post_date, post_date_gmt,  post_content, post_title, post_excerpt, post_status, comment_status, ping_status, 
													post_password, post_name, post_modified, post_modified_gmt, post_content_filtered, post_parent,
													menu_order, post_type, post_mime_type, comment_count, to_ping, pinged)
			SELECT post_author = [WordPress].[dbo].wp_users.ID, 
				   post_date = prpbar_PublishDate, 
				   post_date_gmt = DATEADD(hour, 6, prpbar_PublishDate), 
				   post_content = REPLACE(prpbar_Body, 'ExternalLink.aspx', CRM.dbo.ufn_GetCustomCaptionValue('BBOS', 'URL', 'en-us')  + 'ExternalLink.aspx'), 
				   post_title = prpbar_Name, 
				   post_excerpt = ISNULL(prpbar_Abstract, ''), 
				   post_status = CASE WHEN prpbar_PublishDate > GETDATE() THEN 'future' ELSE 'publish' END,
				   comment_status = 'open',
				   ping_status = 'open',
				   post_password = '',
				   post_name = CRM.dbo.ufn_PreparePostName(prpbar_Name),
				   post_modified = prpbar_CreatedDate,
				   post_modified_gmt =  DATEADD(hour, 6, prpbar_CreatedDate),
				   post_content_filtered = '',
				   post_parent = 0,
				   menu_order = 0,
				   post_type = 'post',
				   post_mime_type = '', 
				   comment_count = 0,
				   to_ping = '',
				   pinged = ''
			  FROM CRM.dbo.PRPublicationArticle 
				   INNER JOIN CRM.dbo.users ON prpbar_CreatedBy = user_userid
				   INNER JOIN [WordPress].[dbo].wp_users ON user_logon = user_login
			 WHERE prpbar_PublicationArticleID = @ArticleID;

			INSERT INTO WordPressLumber.dbo.wp_postmeta (post_id, meta_key, meta_value)
			SELECT ID, 'bbsi_crm', 'true'
			  FROM CRM.dbo.PRPublicationArticle 
				   INNER JOIN WordPressLumber.dbo.wp_posts ON prpbar_Name = post_title AND prpbar_PublishDate = post_date
			 WHERE prpbar_PublicationArticleID = @ArticleID;

			INSERT INTO WordPressLumber.dbo.wp_postmeta (post_id, meta_key, meta_value)
			SELECT ID, 'prpbar_PublicationArticleID', prpbar_PublicationArticleID
			  FROM CRM.dbo.PRPublicationArticle 
				   INNER JOIN WordPressLumber.dbo.wp_posts ON prpbar_Name = post_title AND prpbar_PublishDate = post_date
			 WHERE prpbar_PublicationArticleID = @ArticleID;

			INSERT INTO WordPressLumber.dbo.wp_term_relationships
			SELECT ID, 1, 0
			  FROM CRM.dbo.PRPublicationArticle 
				   INNER JOIN WordPressLumber.dbo.wp_posts ON prpbar_Name = post_title AND prpbar_PublishDate = post_date
			WHERE prpbar_PublicationArticleID = @ArticleID;

			UPDATE [WordPressLumber].[dbo].wp_posts
			   SET guid = 'http://www.lumberbluebook.com/?p=' + CAST(id as varchar(10))
			  FROM CRM.dbo.PRPublicationArticle 
				   INNER JOIN WordPressLumber.dbo.wp_posts ON prpbar_Name = post_title AND prpbar_PublishDate = post_date
			 WHERE prpbar_PublicationArticleID = @ArticleID
		END
	END

END
Go



IF EXISTS (SELECT 'x' FROM sysobjects WHERE name = 'usp_DeleteWordPressNews' and type='P') 
	DROP PROCEDURE dbo.usp_DeleteWordPressNews
Go

CREATE PROCEDURE dbo.usp_DeleteWordPressNews
	@ArticleID int,
	@IndustryType varchar(10)
AS 
BEGIN


	DECLARE @PostID int


	IF (@IndustryType = 'P') BEGIN

		SELECT @PostID = post_id
			FROM WordPressProduce.dbo.wp_postmeta
			WHERE meta_key = 'prpbar_PublicationArticleID'
			AND meta_value = CAST(@ArticleID as varchar(25));

		DELETE FROM WordPressProduce.dbo.wp_posts
 		 WHERE ID = @PostID;

		DELETE FROM WordPressProduce.dbo.wp_postmeta
 		 WHERE post_id = @PostID;

		DELETE FROM WordPressProduce.dbo.wp_term_relationships
		 WHERE object_id = @PostID;
	END


	IF (@IndustryType = 'L') BEGIN

		SELECT @PostID = post_id
			FROM WordPressLumber.dbo.wp_postmeta
			WHERE meta_key = 'prpbar_PublicationArticleID'
			AND meta_value = CAST(@ArticleID as varchar(25));

		DELETE FROM WordPressLumber.dbo.wp_posts
 		 WHERE ID = @PostID;

		DELETE FROM WordPressLumber.dbo.wp_postmeta
 		 WHERE post_id = @PostID;

		DELETE FROM WordPressLumber.dbo.wp_term_relationships
		 WHERE object_id = @PostID;
	END
END
Go

IF EXISTS (SELECT 'x' FROM sysobjects WHERE name = 'usp_SetCustomData' and type='P') 
	DROP PROCEDURE dbo.usp_SetCustomData
Go

CREATE PROCEDURE dbo.usp_SetCustomData
	@CompanyID int,
    @HQID int,
	@UserID int,
    @CustomFieldID int,
    @CompanyIDList varchar(max),
    @Value varchar(500)
AS 
BEGIN

	DECLARE @FieldTypeCode varchar(40)

	IF ((@Value IS NULL) OR
		(@Value = '')) BEGIN

		DELETE 
		  FROM PRWebUserCustomData
		 WHERE prwucd_WebUserCustomFieldID=@CustomFieldID 
		   AND prwucd_AssociatedID IN (SELECT value FROM dbo.Tokenize(@CompanyIDList, ','));

	END ELSE BEGIN

		SELECT @FieldTypeCode = prwucf_FieldTypeCode
		  FROM PRWebUserCustomField
		 WHERE prwucf_WebUserCustomFieldID = @CustomFieldID 

		IF (@FieldTypeCode = 'Text') BEGIN 

			UPDATE PRWebUserCustomData
			   SET prwucd_Value = @Value,
				   prwucd_UpdatedBy = @UserID,
				   prwucd_UpdatedDate = GETDATE(),
				   prwucd_TimeStamp = GETDATE()
			 WHERE prwucd_WebUserCustomFieldID=@CustomFieldID 
			   AND prwucd_AssociatedID IN (SELECT value FROM dbo.Tokenize(@CompanyIDList, ','));

			INSERT INTO [PRWebUserCustomData] ([prwucd_CompanyID],[prwucd_WebUserCustomFieldID],[prwucd_HQID],[prwucd_AssociatedID],[prwucd_AssociatedType],[prwucd_WebUserID],[prwucd_Value],[prwucd_CreatedBy],[prwucd_CreatedDate],[prwucd_UpdatedBy],[prwucd_UpdatedDate],[prwucd_TimeStamp]) 
			SELECT @CompanyID, @CustomFieldID, @HQID, value, 'C',  @UserID, @Value, @UserID, GETDATE(), @UserID, GETDATE(), GETDATE()
			  FROM dbo.Tokenize(@CompanyIDList, ',')
			 WHERE value NOT IN (SELECT prwucd_AssociatedID FROM PRWebUserCustomData WHERE prwucd_WebUserCustomFieldID=@CustomFieldID);

		END

		IF (@FieldTypeCode = 'DDL') BEGIN 

			UPDATE PRWebUserCustomData
			   SET prwucd_WebUserCustomFieldLookupID = @Value,
				   prwucd_UpdatedBy = @UserID,
				   prwucd_UpdatedDate = GETDATE(),
				   prwucd_TimeStamp = GETDATE()
			 WHERE prwucd_WebUserCustomFieldID=@CustomFieldID 
			   AND prwucd_AssociatedID IN (SELECT value FROM dbo.Tokenize(@CompanyIDList, ','));

			INSERT INTO [PRWebUserCustomData] ([prwucd_CompanyID],[prwucd_WebUserCustomFieldID],[prwucd_HQID],[prwucd_AssociatedID],[prwucd_AssociatedType],[prwucd_WebUserID],[prwucd_WebUserCustomFieldLookupID],[prwucd_CreatedBy],[prwucd_CreatedDate],[prwucd_UpdatedBy],[prwucd_UpdatedDate],[prwucd_TimeStamp]) 
			SELECT @CompanyID, @CustomFieldID, @HQID, value, 'C',  @UserID, @Value, @UserID, GETDATE(), @UserID, GETDATE(), GETDATE()
			  FROM dbo.Tokenize(@CompanyIDList, ',')
			 WHERE value NOT IN (SELECT prwucd_AssociatedID FROM PRWebUserCustomData WHERE prwucd_WebUserCustomFieldID=@CustomFieldID);

		END

	END
END
Go



IF EXISTS (SELECT 'x' FROM sysobjects WHERE name = 'usp_GenerateUpdateReport' and type='P') 
	DROP PROCEDURE dbo.usp_GenerateUpdateReport
Go

CREATE PROCEDURE dbo.usp_GenerateUpdateReport
	 @ReportType varchar(40) = 'CSUPD',
     @ReportDate varchar(40) = null, 
	 @IndustryType varchar(40) = '''P'',''T'',''S''',
	 @SortType varchar(40) = null
AS 
BEGIN

	DECLARE @SQL varchar(max)
	DECLARE @DateClause varchar(500)
	DECLARE @OrderClause varchar(1000)

	SET @SQL =
	'SELECT prcs_CompanyId,
	prcs_Tradestyle,
	dbo.ufn_PrepareCreditSheetText(prcs_Parenthetical) AS prcs_Parenthetical,
	dbo.ufn_PrepareCreditSheetText(prcs_Change) AS prcs_Change,
	prcs_RatingChangeVerbiage,
	prcs_RatingValue,
	CASE WHEN prcs_PreviousRatingValue IS NULL THEN NULL ELSE ''Previous '' + prcs_PreviousRatingValue END as prcs_PreviousRatingValue,
	prcs_Notes,
	REPLACE(prcs_Numeral, ''<B>'', '''') AS prcs_Numeral,
	prcs_PublishableDate, 

	prci_City, 
	prst_State, 
	prst_Abbreviation, 
	prcn_CountryID, 
	prcn_Country, 

	--'''' as prci_City, 
	--'''' as prst_State, 
	--'''' as prst_Abbreviation, 
	--prcn_CountryID, 
	--'''' as prcn_Country, 

	dbo.ufn_GetCustomCaptionValue(''comp_PRIndustryType'', comp_PRIndustryType, ''en-us'') As comp_PRIndustryType,
	--'''' As comp_PRIndustryType,
	ISNULL(prcs_KeyFlag, ''Z'') as prcs_KeyFlag, 
	dbo.ufn_GetCreditSheetExportSection(comp_PRIndustryType, prcs_KeyFlag, 0) As Section,
	CASE WHEN prcs_Numeral IS NULL THEN prcs_Tradestyle ELSE dbo.ufn_ApplyListingLineBreaks2(prcs_Tradestyle + ''..'' + REPLACE(prcs_Numeral, ''<B>'', ''''), char(10), 38) END As TradeStyleLine,
	prcs_RatingChangeVerbiage + ''...'' +  REPLACE(ISNULL(prcs_RatingValue, ''''), ''<B>'', '''')  As RatingLine,
	dbo.ufn_GetIndustryTypeForOrderBy(comp_PRIndustryType) as IndustrySort
	 FROM PRCreditSheet 
			   INNER JOIN Company ON prcs_CompanyID = comp_CompanyID 
			   INNER JOIN vPRLocation ON ISNULL(prcs_CityID, comp_PRListingCityID) = prci_CityID
	 WHERE prcs_Status = ''P'' AND comp_PRIndustryType IN (' + @IndustryType + ') AND '

	IF (@ReportType = 'EXUPD') BEGIN
		SET @DateClause = 'prcs_ExpressUpdatePubDate '
		SET @OrderClause = ' ORDER BY dbo.ufn_GetIndustryTypeForOrderBy(comp_PRIndustryType), ISNULL(prcs_KeyFlag, ''Z''),  prcn_BookOrder, prst_BookOrder , prci_City, dbo.ufn_GetCompanyNameForOrderBy(comp_PRBookTradestyle), prcs_PublishableDate'
	END ELSE BEGIN 
		SET @DateClause = 'prcs_WeeklyCSPubDate '


		SET @OrderClause = ' ORDER BY dbo.ufn_GetIndustryTypeForOrderBy(comp_PRIndustryType),  prcn_BookOrder, prst_BookOrder , prci_City, dbo.ufn_GetCompanyNameForOrderBy(comp_PRBookTradestyle), prcs_PublishableDate'
		--SET @OrderClause = ' ORDER BY prcn_BookOrder, prst_BookOrder , prci_City, dbo.ufn_GetCompanyNameForOrderBy(comp_PRBookTradestyle), prcs_PublishableDate'
		--SET @OrderClause = ' ORDER BY dbo.ufn_GetCompanyNameForOrderBy(comp_PRBookTradestyle), prcs_PublishableDate'
	END



	IF (@ReportDate IS NULL) BEGIN
		SET @DateClause = @DateClause + ' IS NULL '
	END ELSE BEGIN 
		SET @DateClause = @DateClause + ' BETWEEN DATEADD(minute, -5, CAST(''' + @ReportDate + ''' AS datetime)) AND DATEADD(minute, 5, CAST(''' + @ReportDate + ''' AS datetime))'
	END



	IF (@IndustryType ='''L''') BEGIN
		 SET @OrderClause = ' ORDER BY prcn_Country, prst_State, prci_City,  dbo.ufn_GetCompanyNameForOrderBy(comp_PRBookTradestyle)'
	END

	SET @SQL = @SQL + @DateClause + @OrderClause

	--SELECT @SQL 

	EXEC(@SQL)
 END
 Go


IF EXISTS (SELECT 'x' FROM sysobjects WHERE name = 'usp_GetLRLCompanies' and type='P') 
	DROP PROCEDURE dbo.usp_GetLRLCompanies
Go

CREATE PROCEDURE dbo.usp_GetLRLCompanies
	@CycleStartDate date,
	@TotalCycles int,
	@IndustryType varchar(40),
	@ServiceType varchar(40)
AS 
BEGIN

/*
DECLARE @CycleStartDate date = '2015-01-19'
DECLARE @TotalCycles int = 1
DECLARE @IndustryType varchar(40) = 'L'
DECLARE @ServiceType varchar(40) = 'M' -- B=Both, M=Members Only, N=Non-Members Only
*/

	DECLARE @CycleCount int = 0

	DECLARE @tblIndustryType table (
		IndustryType varchar(40)
	)

	IF (@IndustryType = 'P') BEGIN
		INSERT INTO @tblIndustryType VALUES ('P');
		INSERT INTO @tblIndustryType VALUES ('T');
		INSERT INTO @tblIndustryType VALUES ('S');
	END ELSE BEGIN
		INSERT INTO @tblIndustryType VALUES ('L');
	END


	SELECT @CycleCount = COUNT(DISTINCT(ISNULL(comp_PRLastLRLLetterDate, '2006-12-04')))
	  FROM Company WITH (NOLOCK)
	       LEFT OUTER JOIN vPRPrimaryMembers WITH (NOLOCK) ON comp_CompanyID = CompanyID
	 WHERE comp_PRIndustryType IN (SELECT IndustryType FROM @tblIndustryType)
	   AND comp_PRLastLRLLetterDate > @CycleStartDate
	   AND comp_PRLocalSource IS NULL
  	   AND CASE WHEN ServiceType IS NOT NULL THEN 'M' ELSE 'N' END = CASE @ServiceType WHEN 'B' THEN CASE WHEN ServiceType IS NOT NULL THEN 'M' ELSE 'N' END ELSE @ServiceType END
   
	DECLARE @NTile int = @TotalCycles - @CycleCount
	IF (@NTile < 1) SET @NTile = 1 

	SELECT *
	  FROM (
		SELECT *,
				Grp = NTILE(@NTile) OVER(PARTITION BY prci_ListingSpecialistId ORDER BY CASE WHEN ServiceType IS NULL THEN 1 ELSE 2 END, ISNULL(comp_PRLastLRLLetterDate, '2006-12-04') ASC)
				   FROM (
				 SELECT DISTINCT comp_CompanyID,
						comp_name,
						ISNULL(comp_PRLastLRLLetterDate, '2006-12-04') as comp_PRLastLRLLetterDate,
						prci_ListingSpecialistId,
						ServiceType
 				   FROM Company a WITH (NOLOCK)
						INNER JOIN vPRLocation WITH (NOLOCK) ON prci_CityID = comp_PRListingCityID
						INNER JOIN PRAttentionLine WITH (NOLOCK) ON comp_CompanyID = prattn_CompanyID AND prattn_ItemCode = 'LRL'
						LEFT OUTER JOIN vPRPrimaryMembers WITH (NOLOCK) ON comp_CompanyID = CompanyID
				  WHERE comp_PRListingStatus IN ('L','H')
					AND comp_PRType = 'H'
					AND comp_PRLocalSource IS NULL
					AND comp_PRIndustryType IN (SELECT IndustryType FROM @tblIndustryType)
					AND prattn_Disabled IS NULL
					AND (prattn_AddressID IS NOT NULL OR prattn_EmailID IS NOT NULL)
					--AND (comp_PRLastLRLLetterDate < @CycleStartDate OR comp_PRLastLRLLetterDate IS NULL)
					AND (ISNULL(comp_PRLastLRLLetterDate, DATEADD(day, 30, comp_PRListedDate)) < @CycleStartDate)
					AND CASE WHEN ServiceType IS NOT NULL THEN 'M' ELSE 'N' END = CASE @ServiceType WHEN 'B' THEN CASE WHEN ServiceType IS NOT NULL THEN 'M' ELSE 'N' END ELSE @ServiceType END
				) T1
		) T2
	WHERE Grp=1
	ORDER BY prci_ListingSpecialistId, comp_CompanyID;

END
Go


IF EXISTS (SELECT 'x' FROM sysobjects WHERE name = 'usp_GetLRLCounts' and type='P') 
	DROP PROCEDURE dbo.usp_GetLRLCounts
Go

CREATE PROCEDURE dbo.usp_GetLRLCounts
	@CycleStartDate date,
	@IndustryType varchar(40),
	@ServiceType varchar(40)
AS 
BEGIN

	DECLARE @tblIndustryType table (
		IndustryType varchar(40)
	)

	IF (@IndustryType = 'P') BEGIN
		INSERT INTO @tblIndustryType VALUES ('P');
		INSERT INTO @tblIndustryType VALUES ('T');
		INSERT INTO @tblIndustryType VALUES ('S');
	END ELSE BEGIN
		INSERT INTO @tblIndustryType VALUES ('L');
	END

	DECLARE @SentCount int, @RemainingCount int

	SELECT @SentCount = COUNT(1)
	  FROM Company WITH (NOLOCK)
	       INNER JOIN PRAttentionLine ON comp_CompanyID = prattn_CompanyID AND prattn_ItemCode = 'LRL'
	       LEFT OUTER JOIN vPRPrimaryMembers WITH (NOLOCK) ON comp_CompanyID = CompanyID
     WHERE comp_PRListingStatus IN ('L','H')
	   AND comp_PRType = 'H'
	   AND comp_PRLocalSource IS NULL
	   AND comp_PRIndustryType IN (SELECT IndustryType FROM @tblIndustryType)
	   AND comp_PRLastLRLLetterDate >= @CycleStartDate
	   AND comp_PRLastLRLLetterDate IS NOT NULL
       AND CASE WHEN ServiceType IS NOT NULL THEN 'M' ELSE 'N' END = CASE @ServiceType WHEN 'B' THEN CASE WHEN ServiceType IS NOT NULL THEN 'M' ELSE 'N' END ELSE @ServiceType END

	SELECT @RemainingCount = COUNT(1)
	  FROM Company WITH (NOLOCK)
	       INNER JOIN PRAttentionLine ON comp_CompanyID = prattn_CompanyID AND prattn_ItemCode = 'LRL'
	       LEFT OUTER JOIN vPRPrimaryMembers WITH (NOLOCK) ON comp_CompanyID = CompanyID
     WHERE comp_PRListingStatus IN ('L','H')
	   AND comp_PRType = 'H'
	   AND comp_PRLocalSource IS NULL
	   AND comp_PRIndustryType IN (SELECT IndustryType FROM @tblIndustryType)
  	   AND prattn_Disabled IS NULL
	   AND (prattn_AddressID IS NOT NULL OR prattn_EmailID IS NOT NULL)
	   --AND (comp_PRLastLRLLetterDate < @CycleStartDate OR comp_PRLastLRLLetterDate IS NULL)
	   AND (ISNULL(comp_PRLastLRLLetterDate, DATEADD(day, 30, comp_PRListedDate)) < @CycleStartDate)
       AND CASE WHEN ServiceType IS NOT NULL THEN 'M' ELSE 'N' END = CASE @ServiceType WHEN 'B' THEN CASE WHEN ServiceType IS NOT NULL THEN 'M' ELSE 'N' END ELSE @ServiceType END


	SELECT @SentCount as TotalSentCount, 
	       @RemainingCount as RemainingCount
END
Go


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_UpdateCompanyRating]') 
            and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_UpdateCompanyRating]
GO

CREATE PROCEDURE dbo.usp_UpdateCompanyRating
    @CompanyID int
As
BEGIN

	DECLARE @CompanyRatingID int
	
	SELECT @CompanyRatingID = prcra_CompanyRatingID
	  FROM PRCompanyRating WITH (NOLOCK)
	 WHERE prcra_CompanyID = @CompanyID;
	 
	 IF (@CompanyRatingID IS NOT NULL) BEGIN

		UPDATE PRCompanyRating
		   SET prcra_RatingLine = CASE WHEN comp_PRType = 'B' THEN CASE WHEN compRating.prra_RatingID IS NOT NULL THEN compRating.prra_RatingLine ELSE hqRating.prra_RatingLine END ELSE hqRating.prra_RatingLine END,
		       prcra_RatingID = CASE WHEN comp_PRType = 'B' THEN CASE WHEN compRating.prra_RatingID IS NOT NULL THEN compRating.prra_RatingID ELSE hqRating.prra_RatingID END ELSE hqRating.prra_RatingID END,
			   prcra_IsHQRating = CASE WHEN comp_PRType = 'B' THEN CASE WHEN compRating.prra_RatingID IS NOT NULL THEN 'N' ELSE 'Y' END ELSE 'N' END,
		       prcra_UpdatedDate = GETDATE(),
		       prcra_Timestamp = GETDATE()
		  FROM Company
			   LEFT OUTER JOIN vPRCurrentRating compRating ON comp_CompanyID = compRating.prra_CompanyID 
			   LEFT OUTER JOIN vPRCurrentRating hqRating ON comp_PRHQID = hqRating.prra_CompanyID 
		 WHERE compRating.prra_RatingID IS NOT NULL
		   AND hqRating.prra_RatingID IS NOT NULL
		   AND prcra_CompanyID = comp_CompanyID
		   AND prcra_CompanyID = @CompanyID;

		IF (@@ROWCOUNT = 0) BEGIN
			DELETE FROM PRCompanyRating WHERE prcra_CompanyID = @CompanyID;
		END

	 END ELSE BEGIN

		INSERT INTO PRCompanyRating (prcra_CompanyID, prcra_RatingLine, prcra_RatingID, prcra_IsHQRating, prcra_CreatedBy, prcra_CreatedDate, prcra_UpdatedBy, prcra_UpdatedDate, prcra_TimeStamp)
		SELECT comp_CompanyID,
			   CASE WHEN comp_PRType = 'B' THEN CASE WHEN compRating.prra_RatingID IS NOT NULL THEN compRating.prra_RatingLine ELSE hqRating.prra_RatingLine END ELSE hqRating.prra_RatingLine END AS prra_RatingLine,
			   CASE WHEN comp_PRType = 'B' THEN CASE WHEN compRating.prra_RatingID IS NOT NULL THEN compRating.prra_RatingID ELSE hqRating.prra_RatingID END ELSE hqRating.prra_RatingID END AS prra_RatingID,
			   CASE WHEN comp_PRType = 'B' THEN CASE WHEN compRating.prra_RatingID IS NOT NULL THEN 'N' ELSE 'Y' END ELSE 'N' END AS IsHQRating,
			   1, GETDATE(), 1, GETDATE(), GETDATE()
		  FROM Company
			   LEFT OUTER JOIN vPRCurrentRating compRating ON comp_CompanyID = compRating.prra_CompanyID 
			   LEFT OUTER JOIN vPRCurrentRating hqRating ON comp_PRHQID = hqRating.prra_CompanyID 
		 WHERE compRating.prra_RatingID IS NOT NULL
		   AND hqRating.prra_RatingID IS NOT NULL
		   AND comp_CompanyID = @CompanyID;

	 END
END
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_UpdateBranchCompanyRatings]') 
            and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_UpdateBranchCompanyRatings]
GO

CREATE PROCEDURE dbo.usp_UpdateBranchCompanyRatings
    @HQID int
As
BEGIN

	DECLARE @ndx int, @BranchID int, @Count int
	DECLARE @tblBranches table (
	    ndx int primary key identity (0,1),
		BranchID int
	)
	
	INSERT INTO @tblBranches
	SELECT comp_CompanyID
	  FROM Company WITH (NOLOCK)
	 WHERE comp_PRHQID = @HQID
	   AND comp_PRType = 'B';

	SELECT @Count = COUNT(1) FROM @tblBranches;
	SET @ndx = 0
	WHILE (@ndx < @Count) BEGIN
		SELECT @BranchID = BranchID
		  FROM @tblBranches
		 WHERE ndx = @ndx;
	
		EXEC usp_UpdateCompanyRating @BranchID
		
		SET @ndx = @ndx + 1
	END
End
Go


IF EXISTS (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_BluePrintsDirectory]') 
            and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_BluePrintsDirectory]
GO

CREATE PROCEDURE [dbo].[usp_BluePrintsDirectory]
	@CommodityID int
AS 
BEGIN
SET NOCOUNT ON

	DECLARE @BPCount INT
	DECLARE @BPDirectory TABLE
		(ndx INT IDENTITY,
		COUNTRY NVARCHAR(30), 
		StateAbbr NVARCHAR(10), 
		City NVARCHAR(34), 
		TradeStyle NVARCHAR(104), 
		STATE NVARCHAR(34),
		CompanyID INT, 
		Logo INT, 
		TradeStyle1 NVARCHAR(104),	
		TradeStyle2 NVARCHAR(104), 
		TradeStyle3 NVARCHAR(104),
		CityState NVARCHAR(78), 
		Phone NVARCHAR(34), 
		Fax NVARCHAR(34), 
		Email NVARCHAR(50), 
		Web NVARCHAR(50), 
		Phrase NVARCHAR(25),
		TMYear INT, 
		Classifications NVARCHAR(100), 
		Commodities NVARCHAR(100))

	INSERT INTO @BPDirectory
	SELECT
		prcn_Country,
		prst_Abbreviation,
		v.prci_City,
		comp_PRBookTradestyle,
		prst_State,
		comp_CompanyID,
		LEFT(comp_PRLogo, 6) AS Logo,
		Trade1 = NULL,
		Trade2 = NULL,
		Trade3 = NULL,
		v.prci_City,
		MainPhone,
		Obsolete = NULL,
		Email = RTRIM(EmailAddr),
		Website = NULL,
		TMSince = CASE comp_PRTMFMAward WHEN 'Y' THEN 'Trading Member Since' ELSE NULL END,
		TMYear = CASE comp_PRTMFMAward WHEN 'Y' THEN YEAR(comp_PRTMFMAwardDate) ELSE NULL END,
		Classifications = NULL,
		Commodities = NULL
	FROM
		Company WITH (NOLOCK)
		INNER JOIN vPRLocation v ON comp_PRListingCityID = prci_CityID
		INNER JOIN PRRating on prra_CompanyID = comp_CompanyID
						   AND prra_Current = 'Y'
						   AND prra_IntegrityID in (5,6)
		LEFT OUTER JOIN 
			(SELECT plink_RecordID
			  , PhoneRank = RANK() OVER (PARTITION BY plink_RecordID Order BY phon_PRPreferredPublished, Phon_PhoneId DESC)
			  , MainPhone = dbo.ufn_FormatPhone(Phon_CountryCode, Phon_AreaCode, Phon_Number, phon_PRExtension)
			FROM vPRCompanyPhone WITH (NOLOCK) 
			WHERE  phon_PRPublish = 'Y'
				AND phon_PRPreferredPublished = 'Y'
				AND phon_PRIsPhone = 'Y') PhoneTable ON comp_CompanyID = plink_RecordID AND phoneRank = 1
		LEFT OUTER JOIN  
			(SELECT eCompID = elink_RecordID
			  , EmailRank = RANK() OVER (PARTITION BY elink_RecordID Order BY emai_PRPreferredPublished, Emai_EmailId DESC)
			  , EmailAddr = Emai_EmailAddress 
			FROM vCompanyEmail WITH (NOLOCK) 
			WHERE emai_PRPublish = 'Y' 
				  AND elink_Type = 'E'
				AND emai_PRPreferredPublished = 'Y') EmailTable ON ECompID = comp_CompanyID AND EmailRank = 1
	WHERE
		comp_PRListingStatus IN ('L', 'H')
		AND comp_PRType = 'H'
		AND comp_PRIndustryType != 'L'
		and Comp_CompanyID in (Select prc2_CompanyID from PRCompanyClassification with (nolock) 
			where prc2_ClassificationID in (180,360,390))  -- G, S, Dstr
		AND comp_CompanyID IN 
			(SELECT prcca_CompanyId 
			FROM PRCompanyCommodityAttribute WITH (NOLOCK) 
			WHERE prcca_CommodityId IN (@CommodityID))
	Order BY prcn_CountryId, prst_State, v.prci_City,comp_PRBookTradestyle

	Select @BPCount = count(1) from @BPDirectory

	DECLARE @ndx INT; SET @ndx = 1
	DECLARE @CompID INT;
	DECLARE @Class VARCHAR(100)
	DECLARE @Commod VARCHAR(100)
	DECLARE @comp_PRBookTradestyle VARCHAR(420)
	DECLARE @NamePart1 NVARCHAR(34)
	DECLARE @NamePart2 NVARCHAR (34)
	DECLARE @NamePart3 NVARCHAR (34)
	DECLARE @LineBreakChar VARCHAR(50); SET @LineBreakChar = CHAR(10)
	DECLARE @LineSize INT; SET @LineSize = 34
	DECLARE @NameParts TABLE (idx SMALLINT, NameLines VARCHAR(400))




	WHILE (@ndx <= @BPCount) BEGIN
		SELECT @Class = ''
		SELECT @Commod = ''
		SELECT @Comp_PRBookTradeStyle = ''
		SELECT @NamePart1 = ''
		SELECT @NamePart2 = ''
		SELECT @NamePart3 = ''
		SELECT @CompID = CompanyID FROM @BPDirectory WHERE ndx = @ndx
		SELECT @Comp_PRBookTradestyle = (SELECT TradeStyle FROM @BPDirectory WHERE ndx = @ndx)

		--Get Classifications
			SELECT @Class = @Class + prcl_Abbreviation 
			FROM PRCompanyClassification 
			INNER JOIN PRClassification ON prcl_ClassificationId = prc2_ClassificationId
			WHERE prc2_CompanyId = @CompID
			Order BY prc2_Percentage DESC, prc2_CompanyClassificationId ASC

		--Get Commodities
			SELECT @Commod = @Commod + prcca_PublishedDisplay
			FROM PRCompanyCommodityAttribute 
			WHERE prcca_CompanyId = @CompID
			AND prcca_CommodityId IN (@CommodityID)

		--Divide the Company name into quark size fields.  If logo is present limit to 22.  No logo = 34
		IF EXISTS (SELECT 1 FROM Company WHERE comp_PRLogo IS NOT NULL AND comp_CompanyID = @CompID) BEGIN
			IF (CHARINDEX('.', @comp_PRBookTradestyle, LEN(@comp_PRBookTradestyle)) = 0) BEGIN
				SET @comp_PRBookTradestyle = @comp_PRBookTradestyle + '.'
			END
			IF (LEN(@comp_PRBookTradestyle) <= 22)
			BEGIN		
				SELECT @comp_PRBookTradestyle = 
						dbo.ufn_ApplyListingLineBreaks(@comp_PRBookTradestyle,@LineBreakChar)
			END 
			ELSE BEGIN
				DECLARE @PartA VARCHAR(400), @PartB VARCHAR(400), @PartALineBreak INT
				-- first get the line 1 content at 22 characters
				SET @comp_PRBookTradestyle = dbo.ufn_ApplyListingLineBreaks2(@comp_PRBookTradestyle,@LineBreakChar, 22)
				-- Now find the first line break
				SET @PartALineBreak = CHARINDEX(@LineBreakChar, @comp_PRBookTradestyle)
				-- PartA is the first line; everything before the line break
				SET @PartA = SUBSTRING(@comp_PRBookTradestyle, 1, @PartALineBreak-1)
				-- PartB is everything that is left; this formats to a max of 20 characters/line
				SET @PartB = SUBSTRING(@comp_PRBookTradestyle, @PartALineBreak+LEN(@LineBreakChar), (LEN(@comp_PRBookTradestyle)-@PartALineBreak+LEN(@LineBreakChar))+1)
				-- remove the line break chars because they have to be set to 20 not 22
				SET @PartB = REPLACE(@PartB, @LineBreakChar, ' ')
				SELECT @comp_PRBookTradestyle = @PartA+@LineBreakChar+
						dbo.ufn_ApplyListingLineBreaksForLogo(@PartB, @LineBreakChar, 20, @LineSize, 3)
			END
		END ELSE BEGIN
			IF (CHARINDEX('.', @comp_PRBookTradestyle, LEN(@comp_PRBookTradestyle)) = 0) BEGIN
				SET @comp_PRBookTradestyle = @comp_PRBookTradestyle + '.'
			END
			SELECT @comp_PRBookTradestyle = dbo.ufn_ApplyListingLineBreaks(@comp_PRBookTradestyle, @LineBreakChar)

		END

		INSERT INTO @NameParts SELECT * FROM dbo.Tokenize(@Comp_PRBookTradeStyle, CHAR(10))
	
		SET @NamePart1 = (SELECT Namelines FROM @NameParts WHERE idx = 0)
		SET @NamePart2 = (SELECT Namelines FROM @NameParts WHERE idx = 1)
		SET @NamePart3 = (SELECT Namelines FROM @NameParts WHERE idx = 2)

		UPDATE @BPDirectory
		SET Classifications = @Class,
		Commodities = @Commod,
		TradeStyle1 = @NamePart1,
		TradeStyle2 = @NamePart2,
		TradeStyle3 = @NamePart3
		WHERE ndx = @ndx

		DELETE FROM @NameParts
		SET @ndx = @ndx + 1
	END

	SELECT [Country], 
		   ISNULL([State], '') [State], 
		   City, 
		   TradeStyle, 
		   StateAbbr, 
		   '' as CompanyID,
		   ISNULL(CAST(Logo as varchar), '') as Logo,
		   TradeStyle1,
		   ISNULL(TradeStyle2, '') as TradeStyle2,
		   ISNULL(TradeStyle3, '') as TradeStyle3,
		   CityState,
		   Phone,
		   ISNULL(Fax, '') as Fax,
		   ISNULL(Email, '') as Email,
		   ISNULL(Web, '') as Web,
		   ISNULL(Phrase, '') as Phrase,
		   ISNULL(CAST(TMYear as varchar), '') as TMYear,
		   Classifications,
		   Commodities
	  FROM @BPDirectory
	ORDER BY Country, STATE, City, TradeStyle

END
Go


IF EXISTS (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_CreateInteractions]') 
            and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_CreateInteractions]
GO

CREATE PROCEDURE [dbo].[usp_CreateInteractions]
	@CompanyIDList varchar(max),
	@Note varchar(max),
	@Date datetime,
	@Action varchar(40),
	@Category varchar(40) = null,
	@SubCategory varchar(40) = null,
	@Status varchar(40) = null,
	@Priority varchar(40) = 'Normal',
	@Type varchar(40) = 'Note',
	@Subject varchar(255) = null,
	@CreatedByUser int = -1,
	@Commit bit = 0
As
BEGIN
	SET NOCOUNT ON
	DECLARE @nextCommId int
    DECLARE @nextCommLinkId int
	DECLARE @Now datetime = GETDATE()
	IF (@Commit = 0) begin
		PRINT '*************************************************************'
		PRINT 'NOTE: COMMIT CHANGES IS TURNED OFF. NO CHANGES WILL BE SAVED!'
		PRINT '*************************************************************'
		PRINT ''
	END
	BEGIN TRANSACTION
	BEGIN TRY
		DECLARE @Start datetime = GETDATE()
		DECLARE @CompanyIDs table (
			ndx int,
			CompanyID int);
		DECLARE @CompanyID int, @Count int, @Index int
		INSERT INTO @CompanyIDs SELECT * FROM dbo.Tokenize(@CompanyIDList, ',') WHERE value <> ''
		SELECT @Count = COUNT(1) FROM @CompanyIDs;
		--SELECT * FROM @CompanyIDs;

		SET @Index = 0
		WHILE (@Index < @Count) BEGIN
			SELECT @CompanyID = CompanyID FROM @CompanyIDs WHERE ndx = @Index;
			Print 'Processing ' + CAST(@Index as varchar) + ': ' + CAST(@CompanyID as varchar)
			EXEC usp_GetNextId 'Communication', @nextCommId out
			EXEC usp_GetNextId 'Comm_Link', @nextCommLinkId out 
			INSERT INTO Communication (comm_CommunicationId, comm_Action, comm_Status, comm_Priority, 
									   comm_DateTime, comm_PRCategory, comm_PRSubcategory, comm_Note, comm_Type,comm_Subject,
									   comm_CreatedBy, comm_UpdatedBy, comm_CreatedDate, Comm_UpdatedDate, Comm_TimeStamp)
							   VALUES (@nextCommId, @Action, @Status, @Priority, 
									   @Date, @Category, @SubCategory, @Note, @Type,@Subject,
									   @CreatedByUser, @CreatedByUser, @Now, @Now, @Now);
			INSERT INTO Comm_Link (CmLi_CommLinkId, CmLi_CreatedBy, CmLi_UpdatedBy, CmLi_CreatedDate, CmLi_UpdatedDate,CmLi_TimeStamp,
								   CmLi_Comm_CommunicationId, CmLi_Comm_CompanyId, cmli_comm_userID)
						   VALUES (@nextCommLinkId, @CreatedByUser, @CreatedByUser, @Now, @Now, @Now,
								   @nextCommId, @CompanyID, @CreatedByUser);
			SET @Index = @Index + 1
		END
		SELECT comm_CommunicationId, CmLi_Comm_CompanyId,
		       comm_Action, comm_Status, comm_Priority, 
			   comm_DateTime, comm_PRCategory, comm_PRSubcategory, comm_Note, comm_Type,
			   comm_CreatedBy, comm_UpdatedBy, comm_CreatedDate, Comm_UpdatedDate
		  FROM comm_link  WITH (NOLOCK)  
               INNER JOIN communication WITH (NOLOCK) on cmli_comm_CommunicationId = comm_CommunicationId
         WHERE comm_CreatedDate BETWEEN @Now AND GETDATE()
	  ORDER BY comm_CommunicationId;
		IF (@Commit = 1) BEGIN
			COMMIT TRANSACTION;
		END ELSE BEGIN
			ROLLBACK TRANSACTION;
		END
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
		EXEC usp_RethrowError;
	END CATCH
END
Go



IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].usp_QueueCompanyForDeletion'))
     DROP PROCEDURE dbo.usp_QueueCompanyForDeletion
GO

CREATE PROCEDURE [dbo].[usp_QueueCompanyForDeletion] 
	@CompanyID int,
	@UserID int = 1
AS
BEGIN
	DECLARE @IsListed varchar(1), @CanDelete varchar(1)
	SELECT @IsListed = 'Y'
	   FROM Company
	  WHERE comp_CompanyID = @CompanyID
	    AND comp_PRListingStatus IN ('L', 'H', 'LUV');
	IF (@IsListed = 'Y') BEGIN
		RAISERROR ('Unable to Delete Company: It is listed.', 16, 1)
		RETURN
	END
	SELECT @CanDelete = dbo.ufn_IsEligibeForDelete(@CompanyID, 1, 0);
	IF (@CanDelete = 'N') BEGIN
		RAISERROR ('Unable to Delete Company. Found company data that cannot be deleted.', 16, 1)
		RETURN
	END

	--
	--  By setting the Listing City ID to NULL, this effectively hides
	--  the company from the online systems.
	ALTER TABLE Company DISABLE TRIGGER ALL
	UPDATE Company 
	   SET comp_PRListingCityID = NULL,
	       comp_PRListingStatus = 'QD'  -- Queued for Deletion.  Does not exist in Custom_Captions.
	 WHERE comp_CompanyID = @CompanyID
	ALTER TABLE Company ENABLE TRIGGER ALL

	 INSERT INTO PRDeleteQueue (prdq_CompanyID, prdq_CreatedBy, prdq_CreatedDate)
	                    VALUES (@CompanyID, @UserID, GETDATE());

END
Go

--
--  Email specified number of customer service surveys using ufn_GetCSSurveyEncounters and usp_CreateEmail.
--
CREATE OR ALTER PROCEDURE [dbo].[usp_SendCSSurveys]
	@SurveyDate datetime = null,
	@TargetCount int = 100
as 
BEGIN
SET NOCOUNT ON

	IF (@SurveyDate is null) BEGIN
		set @SurveyDate = getdate()
	END

	DECLARE @ChosenCount int, 
		@RecordCount int, 
		@Random int,
		@ndx int, 
		@Chosen bit,
		@CompanyId int, 
		@EmailAddress varchar(255),
		@IndustryType varchar(50)
 
	DECLARE @CompanyIdPool table (
		ndx int identity,
		CompanyId int,
		EmailAddress varchar(255),
		Chosen bit,
		IndustryType varchar(50)
		)

	-- query for companies eligible for survey
	INSERT INTO @CompanyIdPool (CompanyId, EmailAddress, Chosen, IndustryType)
	SELECT DISTINCT CompanyId, Emai_EmailAddress, 0, comp_PRIndustryType
	  FROM dbo.ufn_GetCSSurveyEncounters(@SurveyDate)
		   INNER JOIN Company WITH (NOLOCK) on comp_CompanyId = CompanyId
		   INNER JOIN vCompanyEmail WITH (NOLOCK) ON comp_CompanyId = elink_RecordID AND elink_Type = 'E'
		   INNER JOIN vPRLocation on comp_PRListingCityId = prci_CityId
	 WHERE comp_PRReceiveCSSurvey = 'Y'
	   AND prcn_CountryID in (1, 2)
	   AND comp_PRIndustryType <> 'L'
	   AND emai_PRPreferredInternal = 'Y'
	   AND comp_CompanyId NOT IN
		(
				SELECT DISTINCT cmli_comm_CompanyId 
				FROM Comm_Link WITH (NOLOCK)
					INNER JOIN Communication WITH (NOLOCK) on comm_CommunicationId = cmli_Comm_CommunicationId
				WHERE 
					comm_PRCategory='CS'
					AND comm_PRSubcategory = 'CSS'
					AND comm_DateTime >= DATEADD(month, -3, GETDATE())
		);
	SET @RecordCount = @@ROWCOUNT

	-- choose up to the desired number of surveys
	IF (@RecordCount <= @TargetCount) BEGIN

		-- if not enough to choose from, take 'em all
		SET @ChosenCount = @RecordCount
		UPDATE @CompanyIdPool set Chosen = 1

	END ELSE BEGIN

		-- choose desired number at random
		SET @ChosenCount = 0
		WHILE (@ChosenCount < @TargetCount) BEGIN

			SET @Random = round(rand() * @RecordCount, 0, 1) + 1	
			SELECT @Chosen = Chosen 
			  FROM @CompanyIdPool	
			 WHERE ndx = @Random

			IF @Chosen = 0 BEGIN
				UPDATE @CompanyIdPool SET Chosen = 1 WHERE ndx = @Random
				SET @ChosenCount = @ChosenCount + 1
			END
		END
	END

	-- now loop thru the table, sending a survey to each selected company
	SET @ndx = 1

	WHILE (@ndx <= @RecordCount) BEGIN

		SELECT @CompanyId = CompanyId, 
			   @EmailAddress = EmailAddress,
			   @Chosen = Chosen		,
			   @IndustryType = IndustryType
		  FROM @CompanyIdPool 
		 WHERE ndx = @ndx;

		IF (@Chosen = 1) BEGIN

			-- Get the text of the email
			DECLARE @SurveySubject nvarchar(max);
			SET @SurveySubject = dbo.ufn_GetCustomCaptionValueDefault('CustomerServiceSurvey', 'SurveySubjectLine', 'Blue Book Services Would Like Your Feedback');

			DECLARE @SurveyText nvarchar(max);
			SET @SurveyText = dbo.ufn_GetCustomCaptionValue('CustomerServiceSurvey', 'SurveyText', 'en-us');

			DECLARE @SurveyURL nvarchar(max);
			SET @SurveyURL = dbo.ufn_GetCustomCaptionValue('CustomerServiceSurvey', 'SurveyURL', 'en-us');

			SET @SurveyText = REPLACE(@SurveyText, '{0}', @SurveyURL)

			--Defect 4113 email images
			DECLARE @TopImage varchar(5000)
			DECLARE @BottomImage varchar(5000)
			SET @TopImage = dbo.ufn_GetEmailImageHTML('4','T',@IndustryType)
			SET @BottomImage = dbo.ufn_GetEmailImageHTML('4','B',@IndustryType)
			SET @SurveyText = @TopImage + @SurveyText + @BottomImage --Defect 4113 include optional email header and footer images
			--SELECT @SurveyText

			SET @SurveyText = dbo.ufn_GetFormattedEmail(@CompanyID, null, 0, @SurveySubject, @SurveyText, NULL)
			
			EXEC dbo.usp_CreateEmail
				@To = @EmailAddress, 
				@Subject = @SurveySubject,
				@Content = @SurveyText,
				@Content_Format = 'HTML',
				@RelatedCompanyId = @CompanyId, 
				@Action = 'EmailOut',
				@PRCategory ='CS', 
				@PRSubcategory = 'CSS',
				@Source = 'Send CS Survey'
		END

		SET @ndx = @ndx + 1

	END
	SELECT ISNULL(@ChosenCount, 0)
END	
GO

--
--  Email specified number of special service surveys 
--
CREATE OR ALTER PROCEDURE [dbo].[usp_SendSSSurveys]
	@SurveyDate datetime = null,
	@TargetCount int = 100
as 
BEGIN
	SET NOCOUNT ON

	IF (@SurveyDate is null) BEGIN
		set @SurveyDate = getdate()
	END

	-- determine start and end of last week from @SurveyDate
	declare @TodayMidnight datetime
	declare @FromDate datetime
	declare @ThroughDate datetime
	set @TodayMidnight = cast(convert(varchar,@SurveyDate,101) + ' 12:00:00 AM' as datetime)
	set @FromDate = DateAdd(day,-(6 + datepart(weekday,@TodayMidnight)), @TodayMidnight)
	set @ThroughDate = DateAdd(week,1,@FromDate)

	DECLARE @ChosenCount int, 
		@RecordCount int, 
		@Random int,
		@ndx int, 
		@Chosen bit,
		@CompanyId int,
		@PersonId int, 
		@EmailAddress varchar(255),
		@IndustryType varchar(50)
 
	DECLARE @PersonIdPool table (
		ndx int identity,
		CompanyId int,
		PersonId int,
		EmailAddress varchar(255),
		Chosen bit,
		IndustryType varchar(50))

	-- query for companies eligible for survey
	INSERT INTO @PersonIdPool (CompanyId, PersonId, EmailAddress, Chosen, IndustryType)
		SELECT DISTINCT prssc_CompanyId, prssc_PersonId, prssc_Email, 0, comp_PRIndustryType
		FROM PRSSFile f WITH(NOLOCK)
			INNER JOIN PRSSContact c WITH (NOLOCK) ON f.prss_SSFileID = c.prssc_SSFileID
			INNER JOIN Company co WITH (NOLOCK) ON co.Comp_CompanyId = prssc_CompanyId
		WHERE 
			prss_ClosedDate BETWEEN @FromDate AND @ThroughDate
			AND prss_Status = 'C'
			AND prss_Type='C' --limit to claims only
			AND prss_ClaimantCompanyId IS NOT NULL
			and prssc_Email IS NOT NULL
			and prss_ClaimantCompanyId = prssc_CompanyId
			AND prssc_PersonId IS NOT NULL
			AND prssc_PersonId NOT IN
			(
				SELECT DISTINCT cmli_comm_Personid
				FROM Comm_Link WITH (NOLOCK)
					INNER JOIN Communication WITH (NOLOCK) on comm_CommunicationId = cmli_Comm_CommunicationId
				WHERE 
					comm_action='EmailOut' 
					AND comm_PRCategory='SS' 
					AND comm_PRSubcategory = 'CSS' 
					AND comm_DateTime >= DATEADD(month, -3, GETDATE())
			);

	SET @RecordCount = @@ROWCOUNT

	-- choose up to the desired number of surveys
	IF (@RecordCount <= @TargetCount) BEGIN
		-- if not enough to choose from, take 'em all
		SET @ChosenCount = @RecordCount
		UPDATE @PersonIdPool set Chosen = 1
	END ELSE BEGIN
		-- choose desired number at random
		SET @ChosenCount = 0
		WHILE (@ChosenCount < @TargetCount) BEGIN
			SET @Random = round(rand() * @RecordCount, 0, 1) + 1	
			SELECT @Chosen = Chosen 
			  FROM @PersonIdPool	
			 WHERE ndx = @Random

			IF @Chosen = 0 BEGIN
				UPDATE @PersonIdPool SET Chosen = 1 WHERE ndx = @Random
				SET @ChosenCount = @ChosenCount + 1
			END
		END
	END

	-- now loop thru the table, sending a survey to each selected company
	SET @ndx = 1

	WHILE (@ndx <= @RecordCount) BEGIN
		SELECT @CompanyId = CompanyId,
			   @PersonId = PersonId, 
			   @EmailAddress = EmailAddress,
			   @Chosen = Chosen,
			   @IndustryType = IndustryType
		FROM @PersonIdPool 
		WHERE ndx = @ndx;

		IF (@Chosen = 1) BEGIN
			-- Get the text of the email
			DECLARE @SurveySubject nvarchar(max);
			SET @SurveySubject = dbo.ufn_GetCustomCaptionValueDefault('SpecialServiceSurvey', 'SurveySubjectLine', 'We Need Your Feedback on Special Services');

			DECLARE @SurveyText nvarchar(max);
			SET @SurveyText = dbo.ufn_GetCustomCaptionValue('SpecialServiceSurvey', 'SurveyText', 'en-us');

			DECLARE @SurveyURL nvarchar(max);
			SET @SurveyURL = dbo.ufn_GetCustomCaptionValue('SpecialServiceSurvey', 'SurveyURL', 'en-us');

			SET @SurveyText = REPLACE(@SurveyText, '{0}', @SurveyURL)

			--Defect 4113 email images
			DECLARE @TopImage varchar(5000)
			DECLARE @BottomImage varchar(5000)
			SET @TopImage = dbo.ufn_GetEmailImageHTML('4','T',@IndustryType)
			SET @BottomImage = dbo.ufn_GetEmailImageHTML('4','B',@IndustryType)
			SET @SurveyText = @TopImage + @SurveyText + @BottomImage --Defect 4113 include optional email header and footer images
			--SELECT @SurveyText

			SET @SurveyText = dbo.ufn_GetFormattedEmail(@CompanyId, @PersonId, 0, @SurveySubject, @SurveyText, NULL)

			EXEC dbo.usp_CreateEmail
				@To = @EmailAddress, 
				@Subject = @SurveySubject,
				@Content = @SurveyText,
				@Content_Format = 'HTML',
				@RelatedCompanyId = @CompanyId, 
				@RelatedPersonId = @PersonId, 
				@Action = 'EmailOut',
				@PRCategory ='SS', --Special Services
				@PRSubcategory = 'CSS',
				@Source = 'Send SS Survey'
		END

		SET @ndx = @ndx + 1

	END
	SELECT ISNULL(@ChosenCount, 0)
END
GO



IF EXISTS (SELECT 'x' FROM dbo.sysobjects where id = object_id(N'[dbo].[usp_GetBBOSARDetails]'))
	DROP PROCEDURE [dbo].[usp_GetBBOSARDetails]
GO

CREATE PROCEDURE [dbo].[usp_GetBBOSARDetails]
    @SubjectCompanyID int,
	@IndustryType varchar(40) = 'P',
	@Threshold int
as 
BEGIN

	SET NOCOUNT ON

	DECLARE @tmpDate Date =  DATEADD(month, 0-@Threshold, DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0))

	-- We want only one AR Detail record per submitter per month.  
	DECLARE @MyDetailTable table (
		ARAgingDetailID int
	)

	INSERT INTO @MyDetailTable
	SELECT praad_ARAgingDetailID 
	  FROM (
			SELECT praad_ARAgingDetailID,
				   ROW_NUMBER() OVER(PARTITION BY praa_CompanyId, YEAR(praa_Date), Month(praa_Date), praad_ARCustomerID,  praad_SubjectCompanyID ORDER BY praa_Date DESC) As RowNum
			  FROM PRARAging
				   INNER JOIN PRARAgingDetail ON praa_ARAgingID = praad_ARAgingId
			 WHERE praa_Date >= @tmpDate
			   AND praad_SubjectCompanyID = @SubjectCompanyID
			) T1
	WHERE RowNum = 1

	SELECT YEAR(praa_Date) [Year], 
	       Month(praa_Date) [Month],  
		   LEFT(DATENAME(MONTH,praa_Date),3) + ' ' + CAST(YEAR(praa_Date) as varchar(4)) DateDisplay, 
		   COUNT(DISTINCT praad_ReportingCompanyID) as [Submitter Count],
		   COUNT(DISTINCT praa_ARAgingID) as [FileCount],
		   SUM(praad_TotalAmount) praad_TotalAmount, 
		   SUM(praad_Amount0to29) praad_Amount0to29,
		   SUM(praad_Amount30to44) praad_Amount30to44, 
			SUM(praad_Amount45to60) praad_Amount45to60, 
			SUM(praad_Amount61Plus) praad_Amount61Plus, 
			praad_Amount0to29Percent = 100 * dbo.ufn_Divide(SUM(praad_Amount0to29), SUM(praad_TotalAmount)),
			praad_Amount30to44Percent = 100 * dbo.ufn_Divide(SUM(praad_Amount30to44), SUM(praad_TotalAmount)),
			praad_Amount45to60Percent = 100 * dbo.ufn_Divide(SUM(praad_Amount45to60), SUM(praad_TotalAmount)),
			praad_Amount61PlusPercent = 100 * dbo.ufn_Divide(SUM(praad_Amount61Plus), SUM(praad_TotalAmount))
	  FROM vPRARAgingDetailOnProduce 
     WHERE praad_SubjectCompanyID = @SubjectCompanyID
       AND praad_ARAgingDetailId IN (SELECT ARAgingDetailID FROM @MyDetailTable)
	   AND praa_Date >= @tmpDate
	GROUP BY YEAR(praa_Date), Month(praa_Date), LEFT(DATENAME(MONTH,praa_Date),3) + ' ' + CAST(YEAR(praa_Date) as varchar(4))
	ORDER BY YEAR(praa_Date) DESC, Month(praa_Date) DESC
END
Go

IF EXISTS (SELECT 'x' FROM dbo.sysobjects where id = object_id(N'[dbo].[usp_GetBBOSARDetailsForChartProduce]'))
	DROP PROCEDURE [dbo].[usp_GetBBOSARDetailsForChartProduce]
GO

CREATE PROCEDURE [dbo].[usp_GetBBOSARDetailsForChartProduce]
    @SubjectCompanyID int,
	@Threshold int
as 
BEGIN

	SET NOCOUNT ON

	DECLARE @tmpDate Date =  DATEADD(month, 0-6, DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0))

	-- We want only one AR Detail record per submitter per month.  
	DECLARE @MyDetailTable table (
		ARAgingDetailID int
	)

	INSERT INTO @MyDetailTable
	SELECT praad_ARAgingDetailID 
	  FROM (
			SELECT praad_ARAgingDetailID,
				   ROW_NUMBER() OVER(PARTITION BY praa_CompanyId, YEAR(praa_Date), Month(praa_Date), praad_ARCustomerID,  praad_SubjectCompanyID ORDER BY praa_Date DESC) As RowNum
			  FROM PRARAging
				   INNER JOIN PRARAgingDetail ON praa_ARAgingID = praad_ARAgingId
			 WHERE praa_Date >= @tmpDate
			   AND praad_SubjectCompanyID = @SubjectCompanyID
			) T1
	WHERE RowNum = 1


	SELECT YEAR(praa_Date) [Year], 
			Month(praa_Date) [Month],  
			LEFT(DATENAME(MONTH,praa_Date),3) + ' ' + CAST(YEAR(praa_Date) as varchar(4)) DateDisplay, 
			COUNT(DISTINCT praad_ReportingCompanyID) as [Submitter Count],
			COUNT(DISTINCT praa_ARAgingID) as [FileCount],
			SUM(praad_TotalAmount) praad_TotalAmount, 
			SUM(praad_Amount0to29) praad_Amount0to29,
			SUM(praad_Amount30to44) praad_Amount30to44, 
			SUM(praad_Amount45to60) praad_Amount45to60, 
			SUM(praad_Amount61Plus) praad_Amount61Plus, 
			praad_Amount0to29Percent = 100 * dbo.ufn_Divide(SUM(praad_Amount0to29), SUM(praad_TotalAmount)),
			praad_Amount30to44Percent = 100 * dbo.ufn_Divide(SUM(praad_Amount30to44), SUM(praad_TotalAmount)),
			praad_Amount45to60Percent = 100 * dbo.ufn_Divide(SUM(praad_Amount45to60), SUM(praad_TotalAmount)),
			praad_Amount61PlusPercent = 100 * dbo.ufn_Divide(SUM(praad_Amount61Plus), SUM(praad_TotalAmount))
		FROM vPRARAgingDetailOnProduce 
		WHERE praad_SubjectCompanyID = @SubjectCompanyID
        AND praad_ARAgingDetailId IN (SELECT ARAgingDetailID FROM @MyDetailTable)
		AND praa_Date >= @tmpDate
	GROUP BY YEAR(praa_Date), Month(praa_Date), LEFT(DATENAME(MONTH,praa_Date),3) + ' ' + CAST(YEAR(praa_Date) as varchar(4))
	ORDER BY YEAR(praa_Date), Month(praa_Date)
END
Go




IF EXISTS (SELECT 'x' FROM dbo.sysobjects where id = object_id(N'[dbo].[usp_GetBBOSARDetailsForChartLumber]'))
	DROP PROCEDURE [dbo].[usp_GetBBOSARDetailsForChartLumber]
GO

CREATE PROCEDURE [dbo].[usp_GetBBOSARDetailsForChartLumber]
    @SubjectCompanyID int,
	@Threshold int
as 
BEGIN

	SET NOCOUNT ON

	DECLARE @tmpDate Date =  DATEADD(month, 0-6, DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0))

	-- We want only one AR Detail record per submitter per month.  
	DECLARE @MyDetailTable table (
		ARAgingDetailID int
	)

	INSERT INTO @MyDetailTable
	SELECT praad_ARAgingDetailID 
	  FROM (
			SELECT praad_ARAgingDetailID,
				   ROW_NUMBER() OVER(PARTITION BY praa_CompanyId, YEAR(praa_Date), Month(praa_Date), praad_ARCustomerID,  praad_SubjectCompanyID ORDER BY praa_Date DESC) As RowNum
			  FROM PRARAging
				   INNER JOIN PRARAgingDetail ON praa_ARAgingID = praad_ARAgingId
			 WHERE praa_Date >= @tmpDate
			   AND praad_SubjectCompanyID = @SubjectCompanyID
			) T1
	WHERE RowNum = 1

	SELECT YEAR(praa_Date) [Year], 
			Month(praa_Date) [Month],  
			LEFT(DATENAME(MONTH,praa_Date),3) + ' ' + CAST(YEAR(praa_Date) as varchar(4)) DateDisplay, 
			COUNT(DISTINCT praad_ReportingCompanyID) as [Submitter Count],
			COUNT(DISTINCT praa_ARAgingID) as [FileCount],
			SUM(praad_AmountCurrent) praad_AmountCurrent, 
			SUM(praad_Amount1to30) praad_Amount1to30,
			SUM(praad_Amount31to60) praad_Amount31to60, 
			SUM(praad_Amount61to90) praad_Amount61to90, 
			SUM(praad_Amount91Plus) praad_Amount91Plus, 
			praad_AmountCurrentPercent =  100 * dbo.ufn_Divide(SUM(CASE WHEN praad_AmountCurrent  < 0 THEN 0 ELSE praad_AmountCurrent END ), SUM(CASE WHEN praad_AmountCurrent  < 0 THEN 0 ELSE praad_AmountCurrent END + CASE WHEN praad_Amount1to30 < 0 THEN 0 ELSE praad_Amount1to30 END + CASE WHEN praad_Amount31to60 < 0 THEN 0 ELSE praad_Amount31to60 END + CASE WHEN praad_Amount61to90 < 0 THEN 0 ELSE praad_Amount61to90 END + CASE WHEN praad_Amount91Plus < 0 THEN 0 ELSE praad_Amount91Plus END)),
			praad_Amount1to30Percent =  100 * dbo.ufn_Divide(SUM(CASE WHEN praad_Amount1to30  < 0 THEN 0 ELSE praad_Amount1to30 END ), SUM(CASE WHEN praad_AmountCurrent  < 0 THEN 0 ELSE praad_AmountCurrent END + CASE WHEN praad_Amount1to30 < 0 THEN 0 ELSE praad_Amount1to30 END + CASE WHEN praad_Amount31to60 < 0 THEN 0 ELSE praad_Amount31to60 END + CASE WHEN praad_Amount61to90 < 0 THEN 0 ELSE praad_Amount61to90 END + CASE WHEN praad_Amount91Plus < 0 THEN 0 ELSE praad_Amount91Plus END)),
			praad_Amount31to60Percent = 100 * dbo.ufn_Divide(SUM(CASE WHEN praad_Amount31to60 < 0 THEN 0 ELSE praad_Amount31to60 END ), SUM(CASE WHEN praad_AmountCurrent  < 0 THEN 0 ELSE praad_AmountCurrent END + CASE WHEN praad_Amount1to30 < 0 THEN 0 ELSE praad_Amount1to30 END + CASE WHEN praad_Amount31to60 < 0 THEN 0 ELSE praad_Amount31to60 END + CASE WHEN praad_Amount61to90 < 0 THEN 0 ELSE praad_Amount61to90 END + CASE WHEN praad_Amount91Plus < 0 THEN 0 ELSE praad_Amount91Plus END)),
			praad_Amount61to90Percent = 100 * dbo.ufn_Divide(SUM(CASE WHEN praad_Amount61to90 < 0 THEN 0 ELSE praad_Amount61to90 END ), SUM(CASE WHEN praad_AmountCurrent  < 0 THEN 0 ELSE praad_AmountCurrent END + CASE WHEN praad_Amount1to30 < 0 THEN 0 ELSE praad_Amount1to30 END + CASE WHEN praad_Amount31to60 < 0 THEN 0 ELSE praad_Amount31to60 END + CASE WHEN praad_Amount61to90 < 0 THEN 0 ELSE praad_Amount61to90 END + CASE WHEN praad_Amount91Plus < 0 THEN 0 ELSE praad_Amount91Plus END)),
			praad_Amount91PlusPercent = 100 * dbo.ufn_Divide(SUM(CASE WHEN praad_Amount91Plus < 0 THEN 0 ELSE praad_Amount91Plus END), SUM(CASE WHEN praad_AmountCurrent  < 0 THEN 0 ELSE praad_AmountCurrent END + CASE WHEN praad_Amount1to30 < 0 THEN 0 ELSE praad_Amount1to30 END + CASE WHEN praad_Amount31to60 < 0 THEN 0 ELSE praad_Amount31to60 END + CASE WHEN praad_Amount61to90 < 0 THEN 0 ELSE praad_Amount61to90 END + CASE WHEN praad_Amount91Plus < 0 THEN 0 ELSE praad_Amount91Plus END))
		FROM vPRARAgingDetailOnLumber 
		WHERE praad_SubjectCompanyID = @SubjectCompanyID
        AND praad_ARAgingDetailId IN (SELECT ARAgingDetailID FROM @MyDetailTable)
		AND praa_Date >= @tmpDate
	GROUP BY YEAR(praa_Date), Month(praa_Date), LEFT(DATENAME(MONTH,praa_Date),3) + ' ' + CAST(YEAR(praa_Date) as varchar(4))
	ORDER BY YEAR(praa_Date), Month(praa_Date)

END
Go


IF EXISTS (SELECT 'x' FROM dbo.sysobjects where id = object_id(N'[dbo].[usp_GetBBOSARSummary]'))
	DROP PROCEDURE [dbo].[usp_GetBBOSARSummary]
GO

CREATE PROCEDURE [dbo].[usp_GetBBOSARSummary]
    @SubjectCompanyID int,
	@IndustryType varchar(40) = 'P',
	@Threshold int
as 
BEGIN


	DECLARE @tmpDate Date =  DATEADD(month, 0-@Threshold, DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0))
	DECLARE @ReportingCompanies int

	-- We want only one AR Detail record per submitter per month.  
	DECLARE @MyDetailTable table (
		ARAgingDetailID int
	)

	INSERT INTO @MyDetailTable
	SELECT praad_ARAgingDetailID 
	  FROM (
			SELECT praad_ARAgingDetailID,
				   ROW_NUMBER() OVER(PARTITION BY praa_CompanyId, YEAR(praa_Date), Month(praa_Date), praad_ARCustomerID,  praad_SubjectCompanyID ORDER BY praa_Date DESC) As RowNum
			  FROM PRARAging WITH (NOLOCK)
				   INNER JOIN PRARAgingDetail WITH (NOLOCK) ON praa_ARAgingID = praad_ARAgingId
			 WHERE praa_Date >= @tmpDate
			   AND praad_SubjectCompanyID = @SubjectCompanyID
			) T1
	WHERE RowNum = 1

	IF (@IndustryType = 'L') BEGIN

		SELECT @ReportingCompanies = COUNT(DISTINCT praad_ReportingCompanyID)
		  FROM vPRARAgingDetailOnLumber
		 WHERE praad_SubjectCompanyID = @SubjectCompanyID
		   AND praa_Date >= @tmpDate
		   AND praa_Date < DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0) -- Current Month


		SELECT @ReportingCompanies as ReportingCompanies,
			   MAX(praad_TotalAmount) as MaxMonthlyBalance,
			   AVG(praad_TotalAmount) as AvgMonthlyBalance
		  FROM (SELECT Year(praa_Date) as [Year],
					   Month(praa_Date) as [Month],
					   SUM(CASE WHEN praad_TotalAmount < 0 THEN 0 ELSE praad_TotalAmount END) praad_TotalAmount 
				  FROM vPRARAgingDetailOnLumber
				 WHERE praad_SubjectCompanyID = @SubjectCompanyID
				   AND praad_ARAgingDetailId IN (SELECT ARAgingDetailID FROM @MyDetailTable)
				   AND praa_Date >= @tmpDate
				   AND praa_Date < DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0) -- Current Month
			  GROUP BY Year(praa_Date), Month(praa_Date)) T1

	END ELSE BEGIN

		SELECT @ReportingCompanies = COUNT(DISTINCT praad_ReportingCompanyID)
		  FROM vPRARAgingDetailOnProduce
		 WHERE praad_SubjectCompanyID = @SubjectCompanyID
		   AND praa_Date >= @tmpDate


		SELECT @ReportingCompanies as ReportingCompanies,
			   MAX(praad_TotalAmount) as MaxMonthlyBalance,
			   AVG(praad_TotalAmount) as AvgMonthlyBalance
		  FROM (SELECT Year(praa_Date) as [Year],
					   Month(praa_Date) as [Month],
					   SUM(CASE WHEN praad_TotalAmount < 0 THEN 0 ELSE praad_TotalAmount END) praad_TotalAmount 
				  FROM vPRARAgingDetailOnProduce
				 WHERE praad_SubjectCompanyID = @SubjectCompanyID
				   AND praad_ARAgingDetailId IN (SELECT ARAgingDetailID FROM @MyDetailTable)
				   AND praa_Date >= @tmpDate
			  GROUP BY Year(praa_Date), Month(praa_Date)) T1
	END
END
Go


IF EXISTS (SELECT 'x' FROM dbo.sysobjects where id = object_id(N'[dbo].[usp_GetBBOSARCharts]'))
	DROP PROCEDURE [dbo].[usp_GetBBOSARCharts]
GO

CREATE PROCEDURE [dbo].[usp_GetBBOSARCharts]
    @SubjectCompanyID int,
	@IndustryType varchar(40) = 'P',
	@Threshold int
as 
BEGIN

	SET NOCOUNT ON

	DECLARE @MyTable table (
		[Year] int,
		[Month] int,
		[DateDisplay] varchar(25)
	)

	DECLARE @tmpDate Date =  DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0)
	DECLARE @Index int = 0

	IF (@IndustryType = 'L') BEGIN
		SET @tmpDate = DATEADD(month, -1, @tmpDate)
	END

	WHILE (@Index < @Threshold) BEGIN
		INSERT INTO @MyTable VALUES (YEAR(@tmpDate), Month(@tmpDate),  LEFT(DATENAME(MONTH,@tmpDate),3) + ' ' + CAST(YEAR(@tmpDate) as varchar(4)))

		SET @Index = @Index + 1
		SET @tmpDate = DATEADD(month, -1, @tmpDate)

	END

	-- We want only one AR Detail record per submitter per month.  
	DECLARE @MyDetailTable table (
		ARAgingDetailID int
	)

	INSERT INTO @MyDetailTable
	SELECT praad_ARAgingDetailID 
	  FROM (
			SELECT praad_ARAgingDetailID,
				   ROW_NUMBER() OVER(PARTITION BY praa_CompanyId, YEAR(praa_Date), Month(praa_Date), praad_ARCustomerID,  praad_SubjectCompanyID ORDER BY praa_Date DESC) As RowNum
			  FROM PRARAging
				   INNER JOIN PRARAgingDetail ON praa_ARAgingID = praad_ARAgingId
			 WHERE praa_Date >= @tmpDate
			   AND praad_SubjectCompanyID = @SubjectCompanyID
			) T1
	WHERE RowNum = 1

	IF (@IndustryType = 'L') BEGIN

		SELECT [Year], 
			   [Month],
			   DateDisplay,
			   COUNT(DISTINCT praad_ReportingCompanyID) as [Submitter Count],
			   COUNT(DISTINCT praa_ARAgingID) as [FileCount],
				praad_AmountCurrentPercent =  100 * dbo.ufn_Divide(SUM(CASE WHEN praad_AmountCurrent  < 0 THEN 0 ELSE praad_AmountCurrent END ), SUM(CASE WHEN praad_AmountCurrent  < 0 THEN 0 ELSE praad_AmountCurrent END + CASE WHEN praad_Amount1to30 < 0 THEN 0 ELSE praad_Amount1to30 END + CASE WHEN praad_Amount31to60 < 0 THEN 0 ELSE praad_Amount31to60 END + CASE WHEN praad_Amount61to90 < 0 THEN 0 ELSE praad_Amount61to90 END + CASE WHEN praad_Amount91Plus < 0 THEN 0 ELSE praad_Amount91Plus END)),
				praad_Amount1to30Percent =  100 * dbo.ufn_Divide(SUM(CASE WHEN praad_Amount1to30  < 0 THEN 0 ELSE praad_Amount1to30 END ), SUM(CASE WHEN praad_AmountCurrent  < 0 THEN 0 ELSE praad_AmountCurrent END + CASE WHEN praad_Amount1to30 < 0 THEN 0 ELSE praad_Amount1to30 END + CASE WHEN praad_Amount31to60 < 0 THEN 0 ELSE praad_Amount31to60 END + CASE WHEN praad_Amount61to90 < 0 THEN 0 ELSE praad_Amount61to90 END + CASE WHEN praad_Amount91Plus < 0 THEN 0 ELSE praad_Amount91Plus END)),
				praad_Amount31to60Percent = 100 * dbo.ufn_Divide(SUM(CASE WHEN praad_Amount31to60 < 0 THEN 0 ELSE praad_Amount31to60 END ), SUM(CASE WHEN praad_AmountCurrent  < 0 THEN 0 ELSE praad_AmountCurrent END + CASE WHEN praad_Amount1to30 < 0 THEN 0 ELSE praad_Amount1to30 END + CASE WHEN praad_Amount31to60 < 0 THEN 0 ELSE praad_Amount31to60 END + CASE WHEN praad_Amount61to90 < 0 THEN 0 ELSE praad_Amount61to90 END + CASE WHEN praad_Amount91Plus < 0 THEN 0 ELSE praad_Amount91Plus END)),
				praad_Amount61to90Percent = 100 * dbo.ufn_Divide(SUM(CASE WHEN praad_Amount61to90 < 0 THEN 0 ELSE praad_Amount61to90 END ), SUM(CASE WHEN praad_AmountCurrent  < 0 THEN 0 ELSE praad_AmountCurrent END + CASE WHEN praad_Amount1to30 < 0 THEN 0 ELSE praad_Amount1to30 END + CASE WHEN praad_Amount31to60 < 0 THEN 0 ELSE praad_Amount31to60 END + CASE WHEN praad_Amount61to90 < 0 THEN 0 ELSE praad_Amount61to90 END + CASE WHEN praad_Amount91Plus < 0 THEN 0 ELSE praad_Amount91Plus END)),
				praad_Amount91PlusPercent = 100 * dbo.ufn_Divide(SUM(CASE WHEN praad_Amount91Plus < 0 THEN 0 ELSE praad_Amount91Plus END), SUM(CASE WHEN praad_AmountCurrent  < 0 THEN 0 ELSE praad_AmountCurrent END + CASE WHEN praad_Amount1to30 < 0 THEN 0 ELSE praad_Amount1to30 END + CASE WHEN praad_Amount31to60 < 0 THEN 0 ELSE praad_Amount31to60 END + CASE WHEN praad_Amount61to90 < 0 THEN 0 ELSE praad_Amount61to90 END + CASE WHEN praad_Amount91Plus < 0 THEN 0 ELSE praad_Amount91Plus END))
		  FROM @MyTable
			   LEFT OUTER JOIN vPRARAgingDetailOnLumber ON Year(praa_Date) = [Year]
														 AND Month(praa_Date) = [Month]
														 AND praad_SubjectCompanyID = @SubjectCompanyID
														 AND praad_ARAgingDetailId IN (SELECT ARAgingDetailID FROM @MyDetailTable)
		GROUP BY [Year], [Month], [DateDisplay]
		ORDER BY [Year], [Month]

	END ELSE BEGIN

		SELECT [Year], 
			   [Month],
			   DateDisplay,
			   COUNT(DISTINCT praad_ReportingCompanyID) as [Submitter Count],
			   COUNT(DISTINCT praa_ARAgingID) as [FileCount],
				--praad_Amount0to29Percent = 100 * dbo.ufn_Divide(SUM(praad_Amount0to29), SUM(praad_TotalAmount)),
				--praad_Amount30to44Percent = 100 * dbo.ufn_Divide(SUM(praad_Amount30to44), SUM(praad_TotalAmount)),
				--praad_Amount45to60Percent = 100 * dbo.ufn_Divide(SUM(praad_Amount45to60), SUM(praad_TotalAmount)),
				--praad_Amount61PlusPercent = 100 * dbo.ufn_Divide(SUM(praad_Amount61Plus), SUM(praad_TotalAmount))
				praad_Amount0to29Percent = 100 * dbo.ufn_Divide(SUM(CASE WHEN praad_Amount0to29 < 0 THEN 0 ELSE praad_Amount0to29 END ), SUM(CASE WHEN praad_Amount0to29 < 0 THEN 0 ELSE praad_Amount0to29 END + CASE WHEN praad_Amount30to44 < 0 THEN 0 ELSE praad_Amount30to44 END + CASE WHEN praad_Amount45to60 < 0 THEN 0 ELSE praad_Amount45to60 END + CASE WHEN praad_Amount61Plus < 0 THEN 0 ELSE praad_Amount61Plus END)),
				praad_Amount30to44Percent = 100 * dbo.ufn_Divide(SUM(CASE WHEN praad_Amount30to44 < 0 THEN 0 ELSE praad_Amount30to44 END ), SUM(CASE WHEN praad_Amount0to29 < 0 THEN 0 ELSE praad_Amount0to29 END + CASE WHEN praad_Amount30to44 < 0 THEN 0 ELSE praad_Amount30to44 END + CASE WHEN praad_Amount45to60 < 0 THEN 0 ELSE praad_Amount45to60 END + CASE WHEN praad_Amount61Plus < 0 THEN 0 ELSE praad_Amount61Plus END)),
				praad_Amount45to60Percent = 100 * dbo.ufn_Divide(SUM(CASE WHEN praad_Amount45to60 < 0 THEN 0 ELSE praad_Amount45to60 END ), SUM(CASE WHEN praad_Amount0to29 < 0 THEN 0 ELSE praad_Amount0to29 END + CASE WHEN praad_Amount30to44 < 0 THEN 0 ELSE praad_Amount30to44 END + CASE WHEN praad_Amount45to60 < 0 THEN 0 ELSE praad_Amount45to60 END + CASE WHEN praad_Amount61Plus < 0 THEN 0 ELSE praad_Amount61Plus END)),
				praad_Amount61PlusPercent = 100 * dbo.ufn_Divide(SUM(CASE WHEN praad_Amount61Plus < 0 THEN 0 ELSE praad_Amount61Plus END), SUM(CASE WHEN praad_Amount0to29 < 0 THEN 0 ELSE praad_Amount0to29 END + CASE WHEN praad_Amount30to44 < 0 THEN 0 ELSE praad_Amount30to44 END + CASE WHEN praad_Amount45to60 < 0 THEN 0 ELSE praad_Amount45to60 END + CASE WHEN praad_Amount61Plus < 0 THEN 0 ELSE praad_Amount61Plus END))

		  FROM @MyTable
			   LEFT OUTER JOIN vPRARAgingDetailOnProduce ON Year(praa_Date) = [Year]
														 AND Month(praa_Date) = [Month]
														 AND praad_SubjectCompanyID = @SubjectCompanyID
														 AND praad_ARAgingDetailId IN (SELECT ARAgingDetailID FROM @MyDetailTable)
		GROUP BY [Year], [Month], [DateDisplay]
		ORDER BY [Year], [Month]
	END
END
Go



IF EXISTS (SELECT Name FROM sys.procedures WHERE Name = N'usp_GenerateRLITESRequests')
	DROP PROCEDURE usp_GenerateRLITESRequests
GO

--
--  Generate Reference List Investigation
--  TES Requests
--
CREATE PROCEDURE dbo.usp_GenerateRLITESRequests
	@ResponderCompanyList varchar(max),
	@Commit int = 0
As
BEGIN

	IF (@Commit = 0) begin
		PRINT '*************************************************************'
		PRINT 'NOTE: COMMIT CHANGES IS TURNED OFF. NO CHANGES WILL BE SAVED!'
		PRINT '*************************************************************'
		PRINT ''
	END

	BEGIN TRANSACTION
	BEGIN TRY

		DECLARE @Start datetime = GETDATE()
	
		DECLARE @MyTable table (
		    ResponderCompanyID int,
			SubjectCompanyID int
		)

		INSERT INTO @MyTable
		SELECT DISTINCT CAST(value as Int) as ResponderCompanyID, comp_CompanyID
		  FROM PRCompanyRelationship WITH (NOLOCK)
			   INNER JOIN Company WITH (NOLOCK) ON prcr_RightCompanyID = comp_CompanyID
			   CROSS APPLY dbo.Tokenize(@ResponderCompanyList, ',')
		 WHERE prcr_Type IN ('09','10','11','12','13','14','15','16')
		  AND prcr_LeftCompanyId = CAST(value as Int)
		  AND prcr_Active = 'Y'
		  AND comp_PRListingStatus IN ('L', 'H', 'LUV')
		  UNION
		SELECT DISTINCT CAST(value as Int) as ResponderCompanyID, praad_SubjectCompanyID
		 FROM PRARAging WITH (NOLOCK)
			  INNER JOIN PRARAgingDetail ON praa_ARAgingID = praad_ARAgingID
			  INNER JOIN Company WITH (NOLOCK) ON praad_SubjectCompanyID = comp_CompanyID
			  CROSS APPLY dbo.Tokenize(@ResponderCompanyList, ',')
		WHERE praa_CompanyID = CAST(value as Int)
		  AND comp_PRListingStatus IN ('L', 'H', 'LUV')



		--SELECT * FROM @MyTable ORDER BY SubjectCompanyID

		INSERT INTO PRTESRequest (prtesr_ResponderCompanyID, prtesr_SubjectCompanyID, prtesr_Source, prtesr_SentMethod)
		SELECT DISTINCT ResponderCompanyID, SubjectCompanyID, 'RLI', 'E'
		  FROM @MyTable
	   ORDER BY ResponderCompanyID, SubjectCompanyID


		SELECT COUNT(1) As TESRequests, 
		       COUNT(DISTINCT prtesr_ResponderCompanyID) As DistinctResponders,
			   COUNT(DISTINCT prtesr_SubjectCompanyID) As DistinctSubjects
		  FROM PRTESRequest
		 WHERE prtesr_Source = 'RLI'
		   AND prtesr_CreatedDate BETWEEN @Start AND GETDATE()


		--EXEC usp_SendTESEmail

		--SELECT * FROM PRTESForm WHERE prtf_CreatedDate BETWEEN @Start AND GETDATE() AND prtf_CompanyID=@CompanyID
		--SELECT * FROM PRTESRequest WHERE prtesr_CreatedDate BETWEEN @Start AND GETDATE() AND prtesr_ResponderCompanyID=@CompanyID

		IF (@Commit = 1) BEGIN
			COMMIT TRANSACTION;
		END ELSE BEGIN
			ROLLBACK TRANSACTION;
		END

	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		EXEC usp_RethrowError;
	END CATCH
END
Go


IF EXISTS (SELECT 'x' FROM dbo.sysobjects where id = object_id(N'[dbo].[usp_UpdateProfileFromClassifications]'))
	DROP PROCEDURE [dbo].[usp_UpdateProfileFromClassifications]
GO

CREATE PROCEDURE [dbo].[usp_UpdateProfileFromClassifications]
    @CompanyID int,
	@UseriD int 
as 
BEGIN


	DECLARE @Now datetime = GETDATE()

	DECLARE @Sourcing bit = 0
	DECLARE @Selling bit = 0
	DECLARE @Trucking bit = 0
	DECLARE @TranBrokering bit = 0

	IF EXISTS (SELECT 'x' 
	             FROM PRCompanyClassification WITH (NOLOCK) 
	                  INNER JOIN PRClassification WITH (NOLOCK) on prc2_ClassificationId = prcl_ClassificationId  
			    WHERE LEFT(prcl_Path, charindex(',',prcl_Path)-1) = '1'
			      AND prc2_CompanyId = @CompanyID) BEGIN
		SET @Sourcing = 1
	END 

	IF EXISTS (SELECT 'x' 
	             FROM PRCompanyClassification WITH (NOLOCK) 
	                  INNER JOIN PRClassification WITH (NOLOCK) on prc2_ClassificationId = prcl_ClassificationId  
			    WHERE LEFT(prcl_Path, charindex(',',prcl_Path)-1) = '2'
			      AND prc2_CompanyId = @CompanyID) BEGIN
		SET @Selling = 1
	END 

	IF EXISTS (SELECT 'x' FROM PRCompanyClassification WITH (NOLOCK) WHERE prc2_ClassificationId = 610 AND prc2_CompanyId = @CompanyID) BEGIN
		SET @Trucking = 1
	END

	IF (@Selling = 0) BEGIN
		IF EXISTS (SELECT 'x' FROM PRCompanyClassification WITH (NOLOCK) WHERE prc2_ClassificationId = 180 AND prc2_CompanyId = @CompanyID) BEGIN
			SET @Selling = 1
		END
	END

	IF EXISTS (SELECT 'x' FROM PRCompanyClassification WITH (NOLOCK) WHERE prc2_ClassificationId IN (570, 580, 590, 520, 500, 530, 540, 550, 560) AND prc2_CompanyId = @CompanyID) BEGIN
		SET @TranBrokering = 1
	END


	IF (@Sourcing = 0) BEGIN

		UPDATE PRCompanyProfile
		   SET prcp_SrcBuyBrokersPct = NULL,
			   prcp_SrcBuyWholesalePct = NULL,
			   prcp_SrcBuyShippersPct = NULL,
			   prcp_SrcBuyExportersPct = NULL,
			   prcp_SrcTakePhysicalPossessionPct = NULL,
			   prcp_SalvageDistressedProduce = NULL,
			   prcp_UpdatedBy = @UserID,
			   prcp_UpdatedDate = @Now,
			   prcp_TimeStamp = @Now
		 WHERE prcp_CompanyID=@CompanyID

	END

	IF (@Selling = 0) BEGIN

		UPDATE PRCompanyProfile
		   SET prcp_SellBrokersPct = NULL,
			   prcp_SellWholesalePct = NULL,
			   prcp_SellDomesticBuyersPct = NULL,
			   prcp_SellExportersPct = NULL,
			   prcp_SellBuyOthersPct = NULL,
			   prcp_GrowsOwnProducePct = NULL,
			   prcp_SellDomesticAccountTypes = NULL,
			   prcp_SellShippingSeason = NULL,
			   prcp_UpdatedBy = @UserID,
			   prcp_UpdatedDate = @Now,
			   prcp_TimeStamp = @Now
		 WHERE prcp_CompanyID=@CompanyID

	END

	IF (@Trucking = 0) BEGIN

 		UPDATE PRCompanyProfile
		   SET prcp_TrkrDirectHaulsPct = NULL,
			   prcp_TrkrTPHaulsPct = NULL,
			   prcp_TrkrProducePct = NULL,
			   prcp_TrkrOtherColdPct = NULL,
			   prcp_TrkrOtherWarmPct = NULL,
			   prcp_TrkrTeams = NULL,
			   prcp_TrkrTrucksOwned = NULL,
			   prcp_TrkrTrucksLeased = NULL,
			   prcp_TrkrTrailersOwned = NULL,
			   prcp_TrkrTrailersLeased = NULL,
			   prcp_TrkrPowerUnits = NULL,
			   prcp_TrkrReefer = NULL,
			   prcp_TrkrDryVan = NULL,
			   prcp_TrkrFlatbed = NULL,
			   prcp_TrkrPiggyback = NULL,
			   prcp_TrkrTanker = NULL,
			   prcp_TrkrContainer = NULL,
			   prcp_TrkrOther = NULL,
			   prcp_TrkrLiabilityAmount = NULL,
			   prcp_TrkrLiabilityCarrier = NULL,
			   prcp_TrkrCargoAmount = NULL,
			   prcp_TrkrCargoCarrier = NULL,
			   prcp_UpdatedBy = @UserID,
			   prcp_UpdatedDate = @Now,
			   prcp_TimeStamp = @Now
		 WHERE prcp_CompanyID=@CompanyID
	END
END
Go

IF EXISTS (SELECT 'x' FROM dbo.sysobjects where id = object_id(N'[dbo].[usp_UpdateBBScoreStatistics]'))
	DROP PROCEDURE [dbo].[usp_UpdateBBScoreStatistics]
GO

CREATE PROCEDURE dbo.usp_UpdateBBScoreStatistics
    @RunDate datetime
AS
BEGIN

	UPDATE PRBBScore
	   SET prbs_IndustryAve = AvgScore
	  FROM Company,
		   (SELECT prbs_RunDate, AVG(prbs_BBScore) as AvgScore
		 	  FROM PRBBScore WITH (NOLOCK)
				   INNER JOIN Company  WITH (NOLOCK) ON prbs_CompanyID = comp_CompanyID
		     WHERE comp_PRIndustryType = 'L'
			   AND prbs_RunDate = @RunDate
		  GROUP BY prbs_RunDate) T1 
	WHERE comp_PRIndustryType = 'L'
	  AND prbs_CompanyID = comp_CompanyID
	  AND PRBBScore.prbs_RunDate = T1.prbs_RunDate

	UPDATE PRBBScore
	   SET prbs_IndustryPercentile = percentile
	  FROM Company,
	       (SELECT *, NTILE(100) OVER (ORDER BY prbs_BBScore) AS percentile
			  FROM (SELECT DISTINCT prbs_BBScore
					 FROM PRBBScore WITH (NOLOCK)
						  INNER JOIN Company  WITH (NOLOCK) ON prbs_CompanyID = comp_CompanyID
					WHERE comp_PRIndustryType = 'L'
					  AND prbs_RunDate = @RunDate) INNER1) T1 
	WHERE comp_PRIndustryType = 'L'
	  AND prbs_CompanyID = comp_CompanyID
	  AND PRBBScore.prbs_BBScore = T1.prbs_BBScore
      AND PRBBScore.prbs_RunDate = @RunDate

END
Go

IF EXISTS (SELECT 'x' FROM dbo.sysobjects where id = object_id(N'[dbo].[usp_DeleteDuplicateLSSPersons]'))
	DROP PROCEDURE [dbo].[usp_DeleteDuplicateLSSPersons]
GO

CREATE PROCEDURE dbo.usp_DeleteDuplicateLSSPersons
	
AS
BEGIN

	SET NOCOUNT OFF
	
	DECLARE @WorkTable table (
		ndx int identity(1,1) primary key,
		CompanyID int,
		LastName varchar(100),
		FirstName varchar(100))


	INSERT INTO @WorkTable
	SELECT peli_CompanyID, Pers_LastName, Pers_FirstName
	 FROM Person WITH(NOLOCK)
		  INNER JOIN Person_Link WITH(NOLOCK) ON pers_PersonID = peli_PersonID
		  LEFT OUTER JOIN vPRPersonEmail WITH(NOLOCK) ON pers_PersonID = elink_RecordID and peli_CompanyID = emai_CompanyID
	WHERE pers_PRLocalSource = 'Y'
	GROUP BY peli_CompanyID, Pers_LastName, Pers_FirstName
	HAVING COUNT(1) > 1
	ORDER BY Pers_LastName, Pers_FirstName

	DECLARE @Count int, @Index int
	DECLARE @CompanyID int, @LastName varchar(100), @FirstName varchar(100)

	DECLARE @tblPerson table (PersonID int)
	DECLARE @Tmp table (ID int)

	SELECT @Count = COUNT(1) FROM @WorkTable;
	SET @Index = 0

	SELECT 'DELETING ' + CAST(@Count as varchar) + ' PERSON RECORDS'

	WHILE (@Index < @Count) BEGIN
		SET @Index = @Index + 1

		SELECT @CompanyID = CompanyID,
			   @FirstName = FirstName,
			   @LastName = LastName
		  FROM @WorkTable
		 WHERE ndx = @Index

		 DELETE FROM @tblPerson

		-- Cannot just delete NLC because some dupes are only NLC and we
		-- want to keep one of them
		 INSERT INTO @tblPerson
		  SELECT pers_PersonID
			FROM (
			SELECT pers_PersonID, ROW_NUMBER() OVER(ORDER BY Pers_CreatedDate DESC) as RowNum
			 FROM Person WITH(NOLOCK)
				  INNER JOIN Person_Link WITH(NOLOCK) ON pers_PersonID = peli_PersonID
			WHERE pers_PRLocalSource = 'Y'
			  AND peli_CompanyID = @CompanyID
			  AND pers_LastName = @LastName
			  AND Pers_FirstName = @FirstName
				  ) T1
				WHERE RowNum > 1

		ALTER TABLE Email DISABLE TRIGGER ALL;
		ALTER TABLE EmailLink DISABLE TRIGGER ALL;
		DELETE FROM @Tmp		
		INSERT INTO @Tmp SELECT elink_EmailID FROM EmailLink WITH(NOLOCK) WHERE elink_RecordID IN (SELECT PersonID FROM @tblPerson) AND ELink_EntityId = 13 
		DELETE FROM EmailLink WHERE elink_RecordID IN (SELECT PersonID FROM @tblPerson) AND ELink_EntityId = 13 
		DELETE FROM Email WHERE emai_EmailID IN (SELECT ID FROM @Tmp)	
		ALTER TABLE Email ENABLE TRIGGER ALL;
		ALTER TABLE EmailLink ENABLE TRIGGER ALL;

		ALTER TABLE Phone DISABLE TRIGGER ALL;
		ALTER TABLE PhoneLink DISABLE TRIGGER ALL;
		DELETE FROM @Tmp;
		INSERT INTO @Tmp SELECT plink_PhoneID FROM PhoneLink WITH(NOLOCK) WHERE plink_RecordID IN (SELECT PersonID FROM @tblPerson) AND pLink_EntityId = 13 
		DELETE FROM PhoneLink WHERE plink_RecordID IN (SELECT PersonID FROM @tblPerson) AND pLink_EntityId = 13 
		DELETE FROM Phone WHERE phon_PhoneID IN (SELECT ID FROM @Tmp)	
		ALTER TABLE Phone ENABLE TRIGGER ALL;
		ALTER TABLE PhoneLink ENABLE TRIGGER ALL;

		ALTER TABLE Person_Link DISABLE TRIGGER ALL
		DELETE FROM Person_Link WHERE peli_PersonID IN (SELECT PersonID FROM @tblPerson)
		ALTER TABLE Person_Link ENABLE TRIGGER ALL

		ALTER TABLE Person DISABLE TRIGGER ALL
		DELETE FROM Person WHERE pers_PersonID IN (SELECT PersonID FROM @tblPerson)
		ALTER TABLE Person ENABLE TRIGGER ALL

		DELETE FROM PRTransactionDetail WHERE prtd_TransactionID IN (SELECT prtx_TransactionID FROM PRTransaction WITH(NOLOCK) WHERE prtx_PersonID IN (SELECT PersonID FROM @tblPerson))
		DELETE FROM PRTransaction WHERE prtx_PersonID IN (SELECT PersonID FROM @tblPerson)
	END
END
GO


CREATE OR ALTER PROCEDURE [dbo].[usp_GetBPGratisSubscriptions]
	@CountryFilterCode varchar(10) = 'A'
As
BEGIN

	DECLARE @ExcludeCompanies table (
		CompanyID int
	)

	INSERT INTO @ExcludeCompanies VALUES (136497);
	INSERT INTO @ExcludeCompanies VALUES (105327);
	INSERT INTO @ExcludeCompanies VALUES (121681);
	INSERT INTO @ExcludeCompanies VALUES (124584);
	INSERT INTO @ExcludeCompanies VALUES (140168);
	INSERT INTO @ExcludeCompanies VALUES (141382);
	INSERT INTO @ExcludeCompanies VALUES (147784);
	INSERT INTO @ExcludeCompanies VALUES (148174);
	INSERT INTO @ExcludeCompanies VALUES (150603);
	INSERT INTO @ExcludeCompanies VALUES (168960);
	INSERT INTO @ExcludeCompanies VALUES (168965);
	INSERT INTO @ExcludeCompanies VALUES (170855);
	INSERT INTO @ExcludeCompanies VALUES (205303);
	INSERT INTO @ExcludeCompanies VALUES (105437);
	INSERT INTO @ExcludeCompanies VALUES (167041);
	INSERT INTO @ExcludeCompanies VALUES (104696);
	INSERT INTO @ExcludeCompanies VALUES (142622);
	INSERT INTO @ExcludeCompanies VALUES (115453);
	INSERT INTO @ExcludeCompanies VALUES (282285);
	INSERT INTO @ExcludeCompanies VALUES (299518);
	INSERT INTO @ExcludeCompanies VALUES (164071);
	INSERT INTO @ExcludeCompanies VALUES (150831);
	INSERT INTO @ExcludeCompanies VALUES (260003);
	INSERT INTO @ExcludeCompanies VALUES (368674);
	INSERT INTO @ExcludeCompanies VALUES (119422);
	INSERT INTO @ExcludeCompanies VALUES (200854);
	INSERT INTO @ExcludeCompanies VALUES (201281);
	INSERT INTO @ExcludeCompanies VALUES (201660);
	INSERT INTO @ExcludeCompanies VALUES (275505);
	INSERT INTO @ExcludeCompanies VALUES (257509);
	INSERT INTO @ExcludeCompanies VALUES (283729);
	INSERT INTO @ExcludeCompanies VALUES (290923);
	INSERT INTO @ExcludeCompanies VALUES (293725);
	INSERT INTO @ExcludeCompanies VALUES (302197);
	INSERT INTO @ExcludeCompanies VALUES (297327);
	INSERT INTO @ExcludeCompanies VALUES (158819);

	DECLARE @ExcludePersons table (
		PersonID int
	)

	INSERT INTO @ExcludePersons VALUES (155056);
	INSERT INTO @ExcludePersons VALUES (18570);
	INSERT INTO @ExcludePersons VALUES (10106);
	INSERT INTO @ExcludePersons VALUES (12352);
	INSERT INTO @ExcludePersons VALUES (15725);
	INSERT INTO @ExcludePersons VALUES (54947);
	INSERT INTO @ExcludePersons VALUES (60401);
	INSERT INTO @ExcludePersons VALUES (73987);
	INSERT INTO @ExcludePersons VALUES (76679);
	INSERT INTO @ExcludePersons VALUES (79204);
	INSERT INTO @ExcludePersons VALUES (89659);
	INSERT INTO @ExcludePersons VALUES (91780);
	INSERT INTO @ExcludePersons VALUES (94476);
	INSERT INTO @ExcludePersons VALUES (94477);
	INSERT INTO @ExcludePersons VALUES (94479);
	INSERT INTO @ExcludePersons VALUES (94480);
	INSERT INTO @ExcludePersons VALUES (94481);
	INSERT INTO @ExcludePersons VALUES (94483);
	INSERT INTO @ExcludePersons VALUES (94484);
	INSERT INTO @ExcludePersons VALUES (94499);
	INSERT INTO @ExcludePersons VALUES (94529);
	INSERT INTO @ExcludePersons VALUES (94530);
	INSERT INTO @ExcludePersons VALUES (94614);
	INSERT INTO @ExcludePersons VALUES (132106);
	INSERT INTO @ExcludePersons VALUES (132107);
	INSERT INTO @ExcludePersons VALUES (132109);
	INSERT INTO @ExcludePersons VALUES (132112);
	INSERT INTO @ExcludePersons VALUES (132114);
	INSERT INTO @ExcludePersons VALUES (132116);
	INSERT INTO @ExcludePersons VALUES (132117);
	INSERT INTO @ExcludePersons VALUES (132143);
	INSERT INTO @ExcludePersons VALUES (132144);
	INSERT INTO @ExcludePersons VALUES (132152);
	INSERT INTO @ExcludePersons VALUES (137814);
	INSERT INTO @ExcludePersons VALUES (137816);
	INSERT INTO @ExcludePersons VALUES (142438);
	INSERT INTO @ExcludePersons VALUES (155386);
	INSERT INTO @ExcludePersons VALUES (94497);
	INSERT INTO @ExcludePersons VALUES (94495);
	INSERT INTO @ExcludePersons VALUES (64927);
	INSERT INTO @ExcludePersons VALUES (166040);
	INSERT INTO @ExcludePersons VALUES (70779);
	INSERT INTO @ExcludePersons VALUES (64926);
	INSERT INTO @ExcludePersons VALUES (78037);
	INSERT INTO @ExcludePersons VALUES (94494);
	INSERT INTO @ExcludePersons VALUES (94496);
	INSERT INTO @ExcludePersons VALUES (145706);
	INSERT INTO @ExcludePersons VALUES (90056);
	INSERT INTO @ExcludePersons VALUES (76543);
	INSERT INTO @ExcludePersons VALUES (20212);
	INSERT INTO @ExcludePersons VALUES (140263);
	INSERT INTO @ExcludePersons VALUES (47923);
	INSERT INTO @ExcludePersons VALUES (127231);
	INSERT INTO @ExcludePersons VALUES (40551);
	INSERT INTO @ExcludePersons VALUES (82457);
	INSERT INTO @ExcludePersons VALUES (126984);
	INSERT INTO @ExcludePersons VALUES (12929);
	INSERT INTO @ExcludePersons VALUES (24740);
	INSERT INTO @ExcludePersons VALUES (7460);
	INSERT INTO @ExcludePersons VALUES (176282);
	INSERT INTO @ExcludePersons VALUES (41726);
	INSERT INTO @ExcludePersons VALUES (53877);
	INSERT INTO @ExcludePersons VALUES (57013);
	INSERT INTO @ExcludePersons VALUES (80180);
	INSERT INTO @ExcludePersons VALUES (74753);
	INSERT INTO @ExcludePersons VALUES (73941);
	INSERT INTO @ExcludePersons VALUES (70608);
	INSERT INTO @ExcludePersons VALUES (65296);
	INSERT INTO @ExcludePersons VALUES (68513);
	INSERT INTO @ExcludePersons VALUES (91266);
	INSERT INTO @ExcludePersons VALUES (91264);
	INSERT INTO @ExcludePersons VALUES (74665);
	INSERT INTO @ExcludePersons VALUES (115877);
	INSERT INTO @ExcludePersons VALUES (8723);
	INSERT INTO @ExcludePersons VALUES (136513);
	INSERT INTO @ExcludePersons VALUES (69035);
	INSERT INTO @ExcludePersons VALUES (256011);
	INSERT INTO @ExcludePersons VALUES (131489);
	INSERT INTO @ExcludePersons VALUES (88694);
	INSERT INTO @ExcludePersons VALUES (285211);
	INSERT INTO @ExcludePersons VALUES (172691);
	INSERT INTO @ExcludePersons VALUES (88694);
	INSERT INTO @ExcludePersons VALUES (76542);
	INSERT INTO @ExcludePersons VALUES (254493);
	INSERT INTO @ExcludePersons VALUES (296268);
	INSERT INTO @ExcludePersons VALUES (301728);
	INSERT INTO @ExcludePersons VALUES (149758);
	INSERT INTO @ExcludePersons VALUES (163963);
	INSERT INTO @ExcludePersons VALUES (139642);
	INSERT INTO @ExcludePersons VALUES (115121);
	INSERT INTO @ExcludePersons VALUES (136508);
	INSERT INTO @ExcludePersons VALUES (153292);
	INSERT INTO @ExcludePersons VALUES (319337);
	INSERT INTO @ExcludePersons VALUES (176285);
	INSERT INTO @ExcludePersons VALUES (247460);
	INSERT INTO @ExcludePersons VALUES (227533);

	DELETE PRGratisService
	  FROM PRGratisService
		   LEFT OUTER JOIN (SELECT peli_CompanyID, peli_PersonID
								  FROM Person_Link
								 WHERE peli_PRStatus = '1'
									  AND (peli_PRRole = 'B' 
										   OR peli_PRTitleCode = 'BUYR'
										   OR (peli_PRTitle LIKE '%buyer%' OR
											   peli_PRTitle LIKE '%Chain%' OR 
												peli_PRTitle LIKE '%Category%' OR
												peli_PRTitle LIKE '%Merchandising%' OR
												peli_PRTitle LIKE '%Distribution%' OR
												peli_PRTitle LIKE '%Retail%' OR
												peli_PRTitle LIKE '%Buyer%' OR
												peli_PRTitle LIKE '%Buying%' OR
												peli_PRTitle LIKE '%Merchandiser%' OR
												peli_PRTitle LIKE '%Procurement%' OR
												peli_PRTitle LIKE '%Produce%' OR
												peli_PRTitle LIKE '%Perishables%' OR 
												peli_PRTitle LIKE '%Logistics%' OR
												peli_PRTitle LIKE '%Transportation%' OR
												peli_PRTitle LIKE '%Traffic%')
												)
									)T1 ON prgs_CompanyID = peli_CompanyID
									   AND prgs_PersonID = peli_PersonID
	WHERE prgs_ItemCode = 'BPRINT'
	   AND prgs_CustomLine IS NULL
	   AND peli_CompanyID IS NULL
	   AND peli_PersonID IS NULL


	--
	--  Remove any existing companies that are no longer listed retailers
	--
	DELETE 
	  FROM PRGratisService
	 WHERE prgs_ItemCode = 'BPRINT'
	   AND prgs_CompanyID NOT IN (SELECT comp_CompanyID
									FROM Company
										 INNER JOIN PRCompanyClassification ON comp_CompanyID = prc2_CompanyId 
										 LEFT OUTER JOIN PRCompanyProfile ON comp_CompanyID = prcp_CompanyID
  								   WHERE comp_PRIndustryType = 'P'
									 AND comp_PRListingStatus IN ('L', 'H')
			 						 AND (prc2_ClassificationId = 330
											OR (dbo.ufn_GetListingClassificationBlock(comp_CompanyID, comp_PRIndustryType, '') LIKE 'Wg%'
												AND CAST(ISNULL(prcp_Volume, 0) as Int) >= 12)
											)
									);

	--
	-- Remove any generic addressees for those companies that have specific persons
	--
	DELETE 
	  FROM PRGratisService
	 WHERE prgs_ItemCode = 'BPRINT'
	   AND prgs_PersonID IS NULL
	   AND prgs_CompanyID IN (SELECT prgs_CompanyID  FROM PRGratisService WHERE prgs_PersonID IS NOT NULL);


	--
	--  Add anyone who is not already in the table.
	--
	INSERT INTO PRGratisService (prgs_CompanyID, prgs_PersonID, prgs_AddressID, prgs_ItemCode, prgs_CustomLine)
	SELECT DISTINCT
		   comp_CompanyID,
		   peli_PersonID,
		   adli_AddressID,
		   'BPRINT',
		   CASE WHEN peli_PersonID IS NULL THEN 'Director of Produce/Perishables' ELSE NULL END
	  FROM Company WITH (NOLOCK)
		   INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID	 
		   INNER JOIN PRCompanyClassification WITH (NOLOCK) ON comp_CompanyID = prc2_CompanyId
		   INNER JOIN Address_Link WITH (NOLOCK) ON comp_CompanyID = adli_CompanyID
	     						  AND adli_PRDefaultMailing = 'Y'
		   LEFT OUTER JOIN PRCompanyProfile ON comp_CompanyID = prcp_CompanyID
		   LEFT OUTER JOIN Person_Link WITH (NOLOCK) ON comp_CompanyID = peli_CompanyID 
									  AND peli_PRStatus = '1'
									  AND (peli_PRRole = 'B' 
										   OR peli_PRTitleCode = 'BUYR'
										   OR (peli_PRTitle LIKE '%buyer%' OR
											   peli_PRTitle LIKE '%Chain%' OR 
												peli_PRTitle LIKE '%Category%' OR
												peli_PRTitle LIKE '%Merchandising%' OR
												peli_PRTitle LIKE '%Distribution%' OR
												peli_PRTitle LIKE '%Retail%' OR
												peli_PRTitle LIKE '%Buyer%' OR
												peli_PRTitle LIKE '%Buying%' OR
												peli_PRTitle LIKE '%Merchandiser%' OR
												peli_PRTitle LIKE '%Procurement%' OR
												peli_PRTitle LIKE '%Produce%' OR
												peli_PRTitle LIKE '%Perishables%' OR 
												peli_PRTitle LIKE '%Logistics%' OR
												peli_PRTitle LIKE '%Transportation%' OR
												peli_PRTitle LIKE '%Traffic%')
												)
		   LEFT OUTER JOIN (SELECT prgs_CompanyID, prgs_PersonID
							  FROM PRGratisService
							 WHERE prgs_ItemCode = 'BPRINT') T1 ON comp_CompanyID = prgs_CompanyID
															   AND ISNULL(peli_PersonID, -1) = ISNULL(prgs_PersonID, -1)
	 WHERE comp_PRIndustryType = 'P'
	   AND comp_PRListingStatus IN ('L', 'H')
	   AND (prc2_ClassificationId = 330
			OR (dbo.ufn_GetListingClassificationBlock(comp_CompanyID, comp_PRIndustryType, '') LIKE 'Wg%'
				AND CAST(ISNULL(prcp_Volume, 0) as Int) >= 12)
			)
	   AND T1.prgs_CompanyID IS NULL
	   AND T1.prgs_PersonID IS NULL
	ORDER BY comp_CompanyID



	-- Remove any persons that already receive 
	-- Blueprints
	DELETE PRGratisService
	  FROM PRGratisService
		   INNER JOIN PRAttentionLine WITH (NOLOCK) ON prgs_CompanyID = prattn_CompanyID
									 AND prgs_PersonID = prattn_PersonID
	 WHERE prgs_ItemCode = 'BPRINT'
	   AND prgs_PersonID IS NOT NULL
	   AND prattn_PersonID IS NOT NULL
	   AND prattn_ItemCode = 'BPRINT';


	DELETE FROM PRGratisService WHERE prgs_PersonID IN (SELECT PersonID FROM @ExcludePersons);
	DELETE FROM PRGratisService WHERE prgs_CompanyID IN (SELECT CompanyID FROM @ExcludeCompanies);

	--  This process has been in place for years, but this has so far only
	--  occurred once.  It it occurs multiple times, then we'll come up with
	--  a better solution.
	DELETE FROM PRGratisService WHERE prgs_CompanyID = 290049 AND prgs_PersonID = 89256 
	DELETE FROM PRGratisService WHERE prgs_CompanyID = 297327 AND prgs_PersonID = 91265  -- Twice now

	IF NOT EXISTS (SELECT 'x' FROM PRGratisService WHERE prgs_PersonID=253857) BEGIN
		INSERT INTO PRGratisService (prgs_CompanyID, prgs_PersonID, prgs_AddressID, prgs_ItemCode, prgs_CustomLine)
		VALUES (327176, 253857, 206358, 'BPRINT', NULL);
	END
	-- SELECT * FROM PRGratisService WHERE prgs_CompanyID = 297327 
	-- DELETE FROM PRGratisService WHERE prgs_GratisServiceID=24017
	--
	--  This result set is used to verify the data
	--

	DECLARE @Exceptions table (
		GratisExceptionID int,
		CompanyID int,
		PersonID int,
		Address1 char(200),
		Address2 varchar(200),
		City varchar(200),
		State varchar(50),
		Country varchar(50),
		Postal varchar(10)
	)
	INSERT INTO @Exceptions VALUES (3, 100073, 76607, '5631 Merrimac Ave', NULL, 'Dallas', 'TX', 'USA', '75206');
	INSERT INTO @Exceptions VALUES (4, 279251, 17269, '338 Via Vera Cruz Ste. 180', NULL, 'San Marcos', 'CA', 'USA', '92078');
	INSERT INTO @Exceptions VALUES (5, 279251, 133242, '338 Via Vera Cruz Ste. 180', NULL, 'San Marcos', 'CA', 'USA', '92078');
	INSERT INTO @Exceptions VALUES (6, 279251, 90275, '338 Via Vera Cruz Ste. 180', NULL, 'San Marcos', 'CA', 'USA', '92078');
	INSERT INTO @Exceptions VALUES (7, 279251, 69316, '338 Via Vera Cruz Ste. 180', NULL, 'San Marcos', 'CA', 'USA', '92078');
	INSERT INTO @Exceptions VALUES (8, 279251, 145410, '5445 West Missouri Ave', NULL, 'Glendale', 'AZ', 'USA', '85301');
	INSERT INTO @Exceptions VALUES (9, 116279, 14258, '1020  64 Avenue NE', NULL, 'Calgary', 'AB', 'Canada', 'T2E 7V8');
	INSERT INTO @Exceptions VALUES (10, 116279, 127668, '1020  64 Avenue NE', NULL, 'Calgary', 'AB', 'Canada', 'T2E 7V8');
	INSERT INTO @Exceptions VALUES (11, 116279, 151923, '1020  64 Avenue NE', NULL, 'Calgary', 'AB', 'Canada', 'T2E 7V8');
	INSERT INTO @Exceptions VALUES (12, 116279, 151924, '1020  64 Avenue NE', NULL, 'Calgary', 'AB', 'Canada', 'T2E 7V8');
	INSERT INTO @Exceptions VALUES (13, 168563, 16970, '3605 Saint Croix Ave', NULL, 'McKinney', 'TX', 'USA', '75071');
	INSERT INTO @Exceptions VALUES (14, 285480, 311601, '6270 Kenway Drive', NULL, 'Mississauga', 'ON', 'Canada', 'L5T 2N3');
	INSERT INTO @Exceptions VALUES (15, 285480, 311664, '6270 Kenway Drive', NULL, 'Mississauga', 'ON', 'Canada', 'L5T 2N3');
	INSERT INTO @Exceptions VALUES (16, 327176, 253857, '175 N Main St', NULL, 'Kouts', 'IN', 'USA', '46347');
	INSERT INTO @Exceptions VALUES (17, 137315, 300390, '500 North St', NULL, 'Windsor Locks', 'CT', 'USA', '06096');
	

	--  SELECT * FROM vPRPersonnelListing WHERE peli_CompanyID=155863    ORDER BY pers_LastName

	DECLARE @tblCountryFilter table (
		CountryID int
	)

	IF (@CountryFilterCode = 'A' ) BEGIN
		INSERT INTO @tblCountryFilter SELECT prcn_CountryID FROM PRCountry WITH (NOLOCK);
	END
	IF (@CountryFilterCode = 'US' ) BEGIN
		INSERT INTO @tblCountryFilter VALUES (1);
	END
	IF (@CountryFilterCode = 'CA' ) BEGIN
		INSERT INTO @tblCountryFilter VALUES (2);
	END

	IF (@CountryFilterCode = 'USCA' ) BEGIN
		INSERT INTO @tblCountryFilter VALUES (1);
		INSERT INTO @tblCountryFilter VALUES (2);
	END

	IF (@CountryFilterCode = 'O' ) BEGIN
		INSERT INTO @tblCountryFilter SELECT prcn_CountryID FROM PRCountry WITH (NOLOCK) WHERE prcn_CountryID >= 3;
	END



	SELECT pers_PersonID, prgs_CompanyID,
		   CASE WHEN prgs_PersonID IS NULL THEN prgs_CustomLine ELSE dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_MiddleName, NULL, pers_Suffix) END  as [Contact],
		   comp_Name as [Company],
			CASE WHEN GratisExceptionID IS NOT NULL THEN RTRIM(Address1) ELSE RTRIM(addr_Address1) END as Address1,
			CASE WHEN GratisExceptionID IS NOT NULL THEN RTRIM(ISNULL(Address2, '')) ELSE RTRIM(ISNULL(addr_Address2, '')) END as Address2,
			CASE WHEN GratisExceptionID IS NOT NULL THEN RTRIM(City) ELSE prci_City END as [City],
			CASE WHEN GratisExceptionID IS NOT NULL THEN RTRIM(State) ELSE ISNULL(prst_Abbreviation, prst_State) END as [State/Province],
			CASE WHEN GratisExceptionID IS NOT NULL THEN RTRIM(Country) ELSE ISNULL(prcn_Country,'') END  as [Country],
			CASE WHEN GratisExceptionID IS NOT NULL THEN RTRIM(Postal) ELSE ISNULL(RTRIM(Addr_PostCode),'') END as [Zip/Postal Code], 
			prgs_GratisServiceID as [Reference]
		FROM PRGratisService
			INNER JOIN Company WITH (NOLOCK) ON prgs_CompanyID = comp_CompanyID
			INNER JOIN vPRAddress ON prgs_AddressID = addr_AddressID
			LEFT OUTER JOIN Person WITH (NOLOCK) ON prgs_PersonID = pers_PersonID 
			LEFT OUTER JOIN @Exceptions ON prgs_PersonID = PersonID AND prgs_CompanyID = CompanyID
	WHERE prgs_ItemCode = 'BPRINT'
	  AND prcn_CountryID IN (SELECT CountryID FROM @tblCountryFilter)
	ORDER BY comp_Name
END
GO


CREATE OR ALTER PROCEDURE [dbo].[usp_GetBPGratisMarketingDirectorListSubscription]
As
BEGIN
	DECLARE @tblRetailGratis table (
		CompanyID int,
		Email varchar(255))

	-- ="INSERT INTO @tblRetailGratis VALUES (" & A5 & ", '" & H5 & "');
	INSERT INTO @tblRetailGratis VALUES (194101, 'fionam@delfrescopure.com');
	INSERT INTO @tblRetailGratis VALUES (165851, 'emurracas@muccifarms.com');
	INSERT INTO @tblRetailGratis VALUES (164326, 'dave@smartybrand.com');
	INSERT INTO @tblRetailGratis VALUES (115453, 'ashleys@sunsetgrown.com');
	INSERT INTO @tblRetailGratis VALUES (158819, 'robertn@lakesideproduce.com');
	INSERT INTO @tblRetailGratis VALUES (162214, 'dinod@westmorelandsales.com');
	INSERT INTO @tblRetailGratis VALUES (170379, 'chris@pure-flavor.com');
	INSERT INTO @tblRetailGratis VALUES (171100, 'lneill@redsunfarms.com');
	INSERT INTO @tblRetailGratis VALUES (122923, 'srobb@northbayproduce.com');
	INSERT INTO @tblRetailGratis VALUES (137502, 'kari@riveridgeproduce.com');
	INSERT INTO @tblRetailGratis VALUES (167970, 'bdixon@topbrassproduce.com');
	INSERT INTO @tblRetailGratis VALUES (189566, 'timd@daykahackett.com');
	INSERT INTO @tblRetailGratis VALUES (172413, 'jescobar@sun-world.com');
	INSERT INTO @tblRetailGratis VALUES (111742, 'dmcclean@oceanmist.com');
	INSERT INTO @tblRetailGratis VALUES (115075, 'ashleypipkin@taproduce.com');
	INSERT INTO @tblRetailGratis VALUES (116141, 'dan@wellpict.com');
	INSERT INTO @tblRetailGratis VALUES (126866, 'jdixon@thegiant.com');
	INSERT INTO @tblRetailGratis VALUES (169332, 'jpadilla@naturipefarms.com');
	INSERT INTO @tblRetailGratis VALUES (155561, 'marliese@lakesideorganic.com ');
	INSERT INTO @tblRetailGratis VALUES (134183, 'georgeh@cmiorchards.com');
	INSERT INTO @tblRetailGratis VALUES (113721, 'mpreacher@superfreshgrowers.com');
	INSERT INTO @tblRetailGratis VALUES (127169, 'cindy.sherman@friedas.com');
	INSERT INTO @tblRetailGratis VALUES (111187, 'fdiaz@freshdelmonte.com');
	INSERT INTO @tblRetailGratis VALUES (167233, 'wvazquezjr@freedomfresh.com');
	INSERT INTO @tblRetailGratis VALUES (113359, 'mtabard@fyffes-na.com');
	INSERT INTO @tblRetailGratis VALUES (149375, 'jl.friedman@carbamericas.com');
	INSERT INTO @tblRetailGratis VALUES (110459, 'shannon@capcofarms.com');
	INSERT INTO @tblRetailGratis VALUES (123123, 'john.scandrett@perofamilyfarms.com');
	INSERT INTO @tblRetailGratis VALUES (142198, 'ceagle@southspec.com');
	INSERT INTO @tblRetailGratis VALUES (111635, 'bheller@sunripecertified.com');
	INSERT INTO @tblRetailGratis VALUES (112095, 'jmay@torsales.com');
	INSERT INTO @tblRetailGratis VALUES (114930, 'nichole.towell@duda.com');
	INSERT INTO @tblRetailGratis VALUES (153066, 'dkling@villagefarms.com');
	INSERT INTO @tblRetailGratis VALUES (112316, 'faye.westfall@dimarefresh.com');
	INSERT INTO @tblRetailGratis VALUES (148899, 'rickm@4earthfarms.com');
	INSERT INTO @tblRetailGratis VALUES (135754, 'patty@agrojalfarms.com');
	INSERT INTO @tblRetailGratis VALUES (192473, 'tbetter@agromodproduce.com');
	INSERT INTO @tblRetailGratis VALUES (165648, 'jcain@alwaysfresh.com');
	INSERT INTO @tblRetailGratis VALUES (172493, 'mandy@mc-solutions.com');
	INSERT INTO @tblRetailGratis VALUES (109825, 'toddgosule@watercress.com');
	INSERT INTO @tblRetailGratis VALUES (116324, 'cpollock@bctree.com');
	INSERT INTO @tblRetailGratis VALUES (124467, 'ande@babefarms.com');
	INSERT INTO @tblRetailGratis VALUES (123034, 'lhickey@baloianfarms.com');
	INSERT INTO @tblRetailGratis VALUES (170241, 'lbartlett@beachsideproduce.com');
	INSERT INTO @tblRetailGratis VALUES (293150, 'mparedes@bellflowerproduce.com');
	INSERT INTO @tblRetailGratis VALUES (114792, 'joek@bengardranch.com');
	INSERT INTO @tblRetailGratis VALUES (121726, 'leah.brakke@blackgoldfarms.com');
	INSERT INTO @tblRetailGratis VALUES (111358, 'kpedersen@bolthouse.com');
	INSERT INTO @tblRetailGratis VALUES (289197, 'dedmeier@bonanzafresh.com');
	INSERT INTO @tblRetailGratis VALUES (296227, 'dori@bovafresh.com');
	INSERT INTO @tblRetailGratis VALUES (149314, 'allensales@ewbrandt.com');
	INSERT INTO @tblRetailGratis VALUES (110555, 'peter@brookstropicals.com');
	INSERT INTO @tblRetailGratis VALUES (182467, 'fata@ce-farms.com');
	INSERT INTO @tblRetailGratis VALUES (113203, 'lindsaym@calavo.com');
	INSERT INTO @tblRetailGratis VALUES (268157, 'jake@californiaspecialtyfarms.com');
	INSERT INTO @tblRetailGratis VALUES (115638, 'lila@cataniaworldwide.com');
	INSERT INTO @tblRetailGratis VALUES (113987, 'jan@cdsdist.com');
	INSERT INTO @tblRetailGratis VALUES (161800, 'kori@churchbrothers.com');
	INSERT INTO @tblRetailGratis VALUES (293933, 'kelly@classicharvest.com');
	INSERT INTO @tblRetailGratis VALUES (165371, 'dchase@classicsalads.com');
	INSERT INTO @tblRetailGratis VALUES (113248, 'mmarchena@coastproduce.com');
	INSERT INTO @tblRetailGratis VALUES (141488, 'tamig@coastlinefamilyfarms.com');
	INSERT INTO @tblRetailGratis VALUES (343319, 'rick.johnston@ac-foods.com');
	INSERT INTO @tblRetailGratis VALUES (101237, 'milaneseb@freshideas.com');
	INSERT INTO @tblRetailGratis VALUES (355081, 'bbesix@cfmushroom.com');
	INSERT INTO @tblRetailGratis VALUES (165317, 'iris@covilli.com');
	INSERT INTO @tblRetailGratis VALUES (160757, 'katiana@crystalvalleyfoods.com');
	INSERT INTO @tblRetailGratis VALUES (134515, 'jtaylor@dnoproduce.com');
	INSERT INTO @tblRetailGratis VALUES (114843, 'cvillalobos@darrigo.com');
	INSERT INTO @tblRetailGratis VALUES (144215, 'leslie@mydaves.com');
	INSERT INTO @tblRetailGratis VALUES (194101, 'fionam@delfrescopure.com');
	INSERT INTO @tblRetailGratis VALUES (283332, 'duncan@detwilermarket.com');
	INSERT INTO @tblRetailGratis VALUES (130681, 'david@diazteca.com');
	INSERT INTO @tblRetailGratis VALUES (156737, 'mikejr@directproduce.com');
	INSERT INTO @tblRetailGratis VALUES (195232, 'chuck@directsourcemktg.com');
	INSERT INTO @tblRetailGratis VALUES (171255, 'ebaltierra@msn.com');
	INSERT INTO @tblRetailGratis VALUES (338509, 'pierre.pepin@eaglexport.ca');
	INSERT INTO @tblRetailGratis VALUES (155612, 'susans@earlsorganic.com');
	INSERT INTO @tblRetailGratis VALUES (154319, 'jessica.harris@danone.com');
	INSERT INTO @tblRetailGratis VALUES (295519, 'enoble@ecofarmsusa.com');
	INSERT INTO @tblRetailGratis VALUES (259300, 'joev@ffm-wa.com');
	INSERT INTO @tblRetailGratis VALUES (123376, 'dvandyke@fivecrowns.com');
	INSERT INTO @tblRetailGratis VALUES (189092, 'amfigueroa@fivediamondcs.com');
	INSERT INTO @tblRetailGratis VALUES (166167, 'tray@fpproduce.com');
	INSERT INTO @tblRetailGratis VALUES (129812, 'dan.purdy@usfoods.com');
	INSERT INTO @tblRetailGratis VALUES (149334, 'misty.ysasi@fronteraproduce.com');
	INSERT INTO @tblRetailGratis VALUES (171287, 'sjohnson@gofresh-precut.com');
	INSERT INTO @tblRetailGratis VALUES (114714, 'lluka@generalproduce.com');
	INSERT INTO @tblRetailGratis VALUES (113366, 'hbrick@giumarra.com');
	INSERT INTO @tblRetailGratis VALUES (168067, 'kveenstra@gloriannfarms.com');
	INSERT INTO @tblRetailGratis VALUES (133777, 'billm@goldcoastpack.com');
	INSERT INTO @tblRetailGratis VALUES (152629, 'tony@grfresh.us');
	INSERT INTO @tblRetailGratis VALUES (170906, 'jesse@grandeproduce.com');
	INSERT INTO @tblRetailGratis VALUES (210849, 'msabovich@grapery.biz');
	INSERT INTO @tblRetailGratis VALUES (297448, 'dan@greenfruitavocados.com');
	INSERT INTO @tblRetailGratis VALUES (165474, 'omar@greenpointdist.com');
	INSERT INTO @tblRetailGratis VALUES (112956, 'kstailey@grimmway.com');
	INSERT INTO @tblRetailGratis VALUES (158533, 'cassie@gumzfarmswi.com');
	INSERT INTO @tblRetailGratis VALUES (324336, 'cristobal@heritagefarmsproduce.com');
	INSERT INTO @tblRetailGratis VALUES (115280, 'steven@hillsidegardens.ca');
	INSERT INTO @tblRetailGratis VALUES (129161, 'stevek@hmcfarms.com');
	INSERT INTO @tblRetailGratis VALUES (161459, 'cherie.france@hgofarms.com');
	INSERT INTO @tblRetailGratis VALUES (177525, 'david.bell@houwelings.com');
	INSERT INTO @tblRetailGratis VALUES (157270, 'deedee@internaturalmarketing.com');
	INSERT INTO @tblRetailGratis VALUES (168911, 'alicia.blanco@qvproduce.com');
	INSERT INTO @tblRetailGratis VALUES (151587, 'noah@irvingspuds.com');
	INSERT INTO @tblRetailGratis VALUES (194494, 'gabriel@isabelleinc.ca');
	INSERT INTO @tblRetailGratis VALUES (158898, 'kyla.oberman@delcabo.com');
	INSERT INTO @tblRetailGratis VALUES (105716, 'wdwerner@benekeith.com');
	INSERT INTO @tblRetailGratis VALUES (193937, 'cfkingfarms@yahoo.com');
	INSERT INTO @tblRetailGratis VALUES (135708, 'callred@kingsburgorchards.com');
	INSERT INTO @tblRetailGratis VALUES (102822, 'mprather@flavorpic.com');
	INSERT INTO @tblRetailGratis VALUES (131571, 'wills@lancasterfoods.com');
	INSERT INTO @tblRetailGratis VALUES (114313, 'jordan@legerandson.com');
	INSERT INTO @tblRetailGratis VALUES (168478, 'jchamberlain@limoneira.com');
	INSERT INTO @tblRetailGratis VALUES (151855, 'jessica.press@lipmanfamilyfarms.com');
	INSERT INTO @tblRetailGratis VALUES (101797, 'james@loffredo.com');
	INSERT INTO @tblRetailGratis VALUES (105318, 'cindy@londonfruit.com');
	INSERT INTO @tblRetailGratis VALUES (205246, 'tjf@lonestarcitrus.com');
	INSERT INTO @tblRetailGratis VALUES (280447, 'natasha@lovebeets.com');
	INSERT INTO @tblRetailGratis VALUES (114946, 'kim.stgeorge@mannpacking.com');
	INSERT INTO @tblRetailGratis VALUES (135562, 'jenny@jmarchinifarms.com');
	INSERT INTO @tblRetailGratis VALUES (159941, 'knewcomb@marketfreshproduce.net');
	INSERT INTO @tblRetailGratis VALUES (123315, 'jenns@markon.com');
	INSERT INTO @tblRetailGratis VALUES (116525, 'kevin.hachey@mccain.ca');
	INSERT INTO @tblRetailGratis VALUES (116075, 'mobrien@montmush.com');
	INSERT INTO @tblRetailGratis VALUES (151931, 'rbrett@mvfruit.com');
	INSERT INTO @tblRetailGratis VALUES (284369, 'paulm@muzzifamilyfarms.com');
	INSERT INTO @tblRetailGratis VALUES (191466, 'tamilong@nashproduce.com');
	INSERT INTO @tblRetailGratis VALUES (166519, 'vincent@nationalproduce.com');
	INSERT INTO @tblRetailGratis VALUES (103146, 'miker@nokotapackers.com');
	INSERT INTO @tblRetailGratis VALUES (151130, 'chris@northshore.farm');
	INSERT INTO @tblRetailGratis VALUES (166959, 'victor.gonzalez@northgatemarkets.com');
	INSERT INTO @tblRetailGratis VALUES (114986, 'mcrossgrove@foxyproduce.com');
	INSERT INTO @tblRetailGratis VALUES (276788, 'haleye@oagglobal.com');
	INSERT INTO @tblRetailGratis VALUES (294660, 'radams@onebananas.com');
	INSERT INTO @tblRetailGratis VALUES (113637, 'scottm@starranch.com');
	INSERT INTO @tblRetailGratis VALUES (104705, 'falon@onions52.com');
	INSERT INTO @tblRetailGratis VALUES (166322, 'laura@orangelinefarms.com');
	INSERT INTO @tblRetailGratis VALUES (149476, 'info@organicgrown.com');
	INSERT INTO @tblRetailGratis VALUES (192696, 'info@owyheeproduce.com');
	INSERT INTO @tblRetailGratis VALUES (164166, 'trhode@pacifictrellisfruit.com');
	INSERT INTO @tblRetailGratis VALUES (111977, 'reade@pandol.com');
	INSERT INTO @tblRetailGratis VALUES (100956, 'helen.pappas@petepappasinc.com');
	INSERT INTO @tblRetailGratis VALUES (132995, 'sean@parkerfarms.net');
	INSERT INTO @tblRetailGratis VALUES (135602, 'rpearson@pearsonfoods.com');
	INSERT INTO @tblRetailGratis VALUES (169149, 'jimmy@premiercitrus.com');
	INSERT INTO @tblRetailGratis VALUES (123417, 'rchapman@pridepak.com');
	INSERT INTO @tblRetailGratis VALUES (172001, 'kflores@pcnbrand.com');
	INSERT INTO @tblRetailGratis VALUES (141746, 'bdenton@proactusa.com');
	INSERT INTO @tblRetailGratis VALUES (157377, 'schwab.ppi@gmail.com');
	INSERT INTO @tblRetailGratis VALUES (113613, 'oscar@progressiveproduce.com');
	INSERT INTO @tblRetailGratis VALUES (302165, 'davidpprosel@gmail.com');
	INSERT INTO @tblRetailGratis VALUES (270729, 'nhogan@prosourceproduce.com');
	INSERT INTO @tblRetailGratis VALUES (107452, 'ashley.rawl@rawl.net');
	INSERT INTO @tblRetailGratis VALUES (108297, 'jarrod@richterproduce.com');
	INSERT INTO @tblRetailGratis VALUES (113035, 'joan@rivermaid.com');
	INSERT INTO @tblRetailGratis VALUES (114235, 'bob.cummings@cutnclean.com');
	INSERT INTO @tblRetailGratis VALUES (298796, 'smcdulin@schmieding.com');
	INSERT INTO @tblRetailGratis VALUES (122214, 'jeff@scottfarms.com');
	INSERT INTO @tblRetailGratis VALUES (140124, 'jen@freshveggie.com');
	INSERT INTO @tblRetailGratis VALUES (108533, 'brooke@southern-produce.com');
	INSERT INTO @tblRetailGratis VALUES (155214, 'gbonisteel@stdavidshydroponics.com');
	INSERT INTO @tblRetailGratis VALUES (126736, 'mseeley@steinbeckproduce.com');
	INSERT INTO @tblRetailGratis VALUES (122874, 'kreeb@sunpacific.com');
	INSERT INTO @tblRetailGratis VALUES (301686, 'brettb@suntreat.com');
	INSERT INTO @tblRetailGratis VALUES (133194, 'sboyajian@sunviewmarketing.com');
	INSERT INTO @tblRetailGratis VALUES (205654, 'agarza@tripleh.com.mx');
	INSERT INTO @tblRetailGratis VALUES (113754, 'mvb@valleyproduce.com');
	INSERT INTO @tblRetailGratis VALUES (160183, 'lprevost@vegpro.com');
	INSERT INTO @tblRetailGratis VALUES (130688, 'monique@vegfresh.com');
	INSERT INTO @tblRetailGratis VALUES (104221, 'ekohlhas@johnvenaproduce.com');
	INSERT INTO @tblRetailGratis VALUES (153066, 'dkling@villagefarms.com');
	INSERT INTO @tblRetailGratis VALUES (122205, 'paul@vivatierra.com');
	INSERT INTO @tblRetailGratis VALUES (189555, 'ericb@wadafarms.com');
	INSERT INTO @tblRetailGratis VALUES (112858, 'bobh@portioncontrolfresh.com');
	INSERT INTO @tblRetailGratis VALUES (154118, 'steven@wcapples.com');
	INSERT INTO @tblRetailGratis VALUES (117036, 'george.henderson@westpakavocado.com');
	INSERT INTO @tblRetailGratis VALUES (112973, 'derek@wilcoxfresh.com');
	INSERT INTO @tblRetailGratis VALUES (206396, 'earana@wilsonproduce.com');
	INSERT INTO @tblRetailGratis VALUES (262073, 'suzawa@windset.com');


	SELECT pers_PersonID, 
	       comp_CompanyID,
		   dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_MiddleName, NULL, pers_Suffix)  as [Contact],
		   comp_Name as [Company],
			RTRIM(addr_Address1) as Address1,
			RTRIM(ISNULL(addr_Address2, '')) as Address2,
			RTRIM(ISNULL(prci_City, '')) as [City],
			ISNULL(prst_Abbreviation, prst_State) as [State/Province],
			ISNULL(prcn_Country,'') as [Country],
			ISNULL(RTRIM(Addr_PostCode),'') as [Zip/Postal Code]
		FROM @tblRetailGratis
			INNER JOIN Company WITH (NOLOCK) ON CompanyID = comp_CompanyID
			INNER JOIN vPRPersonEmail ON CompanyID = emai_CompanyID AND Emai_EmailAddress=RTRIM(Email)
			INNER JOIN Person WITH (NOLOCK) ON ELink_RecordID = pers_PersonID 
			INNER JOIN vPRAddress ON comp_CompanyID = adli_CompanyID
	     						  AND adli_PRDefaultMailing = 'Y'
	ORDER BY comp_Name

END
GO





IF EXISTS  (SELECT * FROM dbo.sysobjects  WHERE id = object_id(N'[dbo].[usp_BRBusinessProfileLicense]')) 
	DROP PROCEDURE [dbo].usp_BRBusinessProfileLicense
GO

/**
Returns the License information
**/
CREATE PROCEDURE [dbo].[usp_BRBusinessProfileLicense]
	@CompanyID INT
AS  
BEGIN
    DECLARE @HQID INT
    SET @HQID = dbo.ufn_BRGetHQID(@CompanyID)
    -- Go get our company and it's branches
    DECLARE @CompanyIDs TABLE (
	    CompanyID INT
    )
    INSERT INTO @CompanyIDs
    SELECT comp_CompanyID
      FROM Company WITH (NOLOCK)
     WHERE (comp_PRHQId = @HQID OR comp_CompanyID = @HQID)
       AND comp_PRListingStatus IN ('L', 'N3', 'N5', 'N6', 'H', 'LUV')
       AND Comp_Deleted IS NULL;
    SELECT prli_Type AS Type, prli_Number AS Number
      FROM PRCompanyLicense WITH (NOLOCK)
     WHERE prli_CompanyId IN (SELECT CompanyID FROM @CompanyIDs)
       AND prli_Publish = 'Y'
       AND prli_Deleted IS NULL
    UNION
    SELECT DISTINCT 'DRC License', 'x' AS prdr_LicenseNumber
      FROM PRDRCLicense WITH (NOLOCK)
     WHERE prdr_CompanyId IN (SELECT CompanyID FROM @CompanyIDs)
       AND prdr_Publish = 'Y'
       AND prdr_Deleted IS NULL
    UNION
    SELECT 'PACA License', prpa_LicenseNumber
      FROM PRPACALicense WITH (NOLOCK)
     WHERE prpa_CompanyId = @HQID
       AND prpa_Current = 'Y'
       AND prpa_Publish = 'Y'
       AND prpa_Deleted IS NULL;
END

GO


IF EXISTS  (SELECT * FROM dbo.sysobjects  WHERE id = object_id(N'[dbo].[usp_IndustryPayTrendAR]')) 
	DROP PROCEDURE [dbo].usp_IndustryPayTrendAR
GO

/**
Returns the AR industry pay trend data for widget on BBOS (non lumber version)
**/
CREATE PROCEDURE [dbo].usp_IndustryPayTrendAR
	@NumMonths int
AS  
BEGIN
    DECLARE @EndDate date = EOMONTH(GETDATE())
    DECLARE @BeginningOfMonth date = DATEADD(mm,datediff(mm,0,@EndDate),0)
    DECLARE @StartDate date = DATEADD(mm, -(@NumMonths-1), @BeginningOfMonth)

    SELECT YEAR(praa_Date) as [Year],
        MONTH(praa_Date) as [Month],
        FORMAT(praa_Date, 'MMM') + '-' + RIGHT(CAST(YEAR(praa_Date) as varchar(4)), 2) DisplayText,
        COUNT(1) as ReportCount,
        COUNT(DISTINCT praa_CompanyID) as SubmitterCount,
        SUM(ISNULL(praad_Amount0to29, 0)) Amount0to29,
              SUM(ISNULL(praad_Amount30to44, 0)) Amount30to44,
              SUM(ISNULL(praad_Amount45to60, 0)) Amount45to60,
              SUM(ISNULL(praad_Amount61Plus, 0)) Amount61Plus,
              SUM(ISNULL(praad_Amount0to29, 0)) + SUM(ISNULL(praad_Amount30to44, 0)) + SUM(ISNULL(praad_Amount45to60, 0)) + SUM(ISNULL(praad_Amount61Plus, 0)) as Total,
        dbo.ufn_Divide(SUM(ISNULL(praad_Amount0to29, 0)), (SUM(ISNULL(praad_Amount0to29, 0)) + SUM(ISNULL(praad_Amount30to44, 0)) + SUM(ISNULL(praad_Amount45to60, 0)) + SUM(ISNULL(praad_Amount61Plus, 0)))) Amount0to29Pct, 
        dbo.ufn_Divide(SUM(ISNULL(praad_Amount30to44, 0)), (SUM(ISNULL(praad_Amount0to29, 0)) + SUM(ISNULL(praad_Amount30to44, 0)) + SUM(ISNULL(praad_Amount45to60, 0)) + SUM(ISNULL(praad_Amount61Plus, 0)))) Amount30to44Pct, 
        dbo.ufn_Divide(SUM(ISNULL(praad_Amount45to60, 0)), (SUM(ISNULL(praad_Amount0to29, 0)) + SUM(ISNULL(praad_Amount30to44, 0)) + SUM(ISNULL(praad_Amount45to60, 0)) + SUM(ISNULL(praad_Amount61Plus, 0)))) Amount45to60Pct, 
        dbo.ufn_Divide(SUM(ISNULL(praad_Amount61Plus, 0)), (SUM(ISNULL(praad_Amount0to29, 0)) + SUM(ISNULL(praad_Amount30to44, 0)) + SUM(ISNULL(praad_Amount45to60, 0)) + SUM(ISNULL(praad_Amount61Plus, 0)))) Amount61PlusPct 
    FROM PRARAging WITH (NOLOCK)
        INNER JOIN PRARAgingDetail WITH (NOLOCK) ON praa_ARAgingId = praad_ARAgingId
        INNER JOIN Company ON praad_SubjectCompanyID = Company.Comp_CompanyId
    WHERE praa_Date BETWEEN @StartDate AND @EndDate
        AND praad_SubjectCompanyID IS NOT NULL
        AND comp_PRIndustryType IN ('P','S','T')
    GROUP BY YEAR(praa_Date),
        MONTH(praa_Date),
        FORMAT(praa_Date, 'MMM') + '-' + RIGHT(CAST(YEAR(praa_Date) as varchar(4)), 2)
    ORDER BY [Year] ASC,
        [Month] ASC
END

GO

IF EXISTS  (SELECT * FROM dbo.sysobjects  WHERE id = object_id(N'[dbo].[usp_IndustryPayTrendAR_Lumber]')) 
	DROP PROCEDURE [dbo].usp_IndustryPayTrendAR_Lumber
GO

/**
Returns the AR industry pay trend data for widget on BBOS (lumber version)
**/
CREATE PROCEDURE [dbo].usp_IndustryPayTrendAR_Lumber
	@NumMonths int
AS  
BEGIN
    DECLARE @EndDate date = EOMONTH(GETDATE())
    DECLARE @BeginningOfMonth date = DATEADD(mm,datediff(mm,0,@EndDate),0)
    DECLARE @StartDate date = DATEADD(mm, -(@NumMonths-1), @BeginningOfMonth)
    SELECT YEAR(praa_Date) as [Year],
        MONTH(praa_Date) as [Month],
        FORMAT(praa_Date, 'MMM') + '-' + RIGHT(CAST(YEAR(praa_Date) as varchar(4)), 2) DisplayText,
        COUNT(1) as ReportCount,
        COUNT(DISTINCT praa_CompanyID) as SubmitterCount,
        SUM(ISNULL(praad_AmountCurrent, 0)) AmountCurrent,
              SUM(ISNULL(praad_Amount1to30, 0)) Amount1to30,
              SUM(ISNULL(praad_Amount31to60, 0)) Amount31to60,
              SUM(ISNULL(praad_Amount61to90, 0)) Amount61to90,
			  SUM(ISNULL(praad_Amount91Plus, 0)) Amount91Plus,
              SUM(ISNULL(praad_AmountCurrent, 0)) + SUM(ISNULL(praad_Amount1to30, 0)) + SUM(ISNULL(praad_Amount31to60, 0)) + SUM(ISNULL(praad_Amount61to90, 0)) + SUM(ISNULL(praad_Amount91Plus, 0)) as Total,
        dbo.ufn_Divide(SUM(ISNULL(praad_AmountCurrent, 0)), (SUM(ISNULL(praad_AmountCurrent, 0)) + SUM(ISNULL(praad_Amount1to30, 0)) + SUM(ISNULL(praad_Amount31to60, 0)) + SUM(ISNULL(praad_Amount61to90, 0)) + SUM(ISNULL(praad_Amount91Plus, 0)))) AmountCurrentPct, 
				dbo.ufn_Divide(SUM(ISNULL(praad_Amount1to30, 0)), (SUM(ISNULL(praad_AmountCurrent, 0)) + SUM(ISNULL(praad_Amount1to30, 0)) + SUM(ISNULL(praad_Amount31to60, 0)) + SUM(ISNULL(praad_Amount61to90, 0)) + SUM(ISNULL(praad_Amount91Plus, 0)))) Amount1to30Pct, 
				dbo.ufn_Divide(SUM(ISNULL(praad_Amount31to60, 0)), (SUM(ISNULL(praad_AmountCurrent, 0)) + SUM(ISNULL(praad_Amount1to30, 0)) + SUM(ISNULL(praad_Amount31to60, 0)) + SUM(ISNULL(praad_Amount61to90, 0)) + SUM(ISNULL(praad_Amount91Plus, 0)))) Amount31to60Pct, 
				dbo.ufn_Divide(SUM(ISNULL(praad_Amount61to90, 0)), (SUM(ISNULL(praad_AmountCurrent, 0)) + SUM(ISNULL(praad_Amount1to30, 0)) + SUM(ISNULL(praad_Amount31to60, 0)) + SUM(ISNULL(praad_Amount61to90, 0)) + SUM(ISNULL(praad_Amount91Plus, 0)))) Amount61to90Pct, 
				dbo.ufn_Divide(SUM(ISNULL(praad_Amount91Plus, 0)), (SUM(ISNULL(praad_AmountCurrent, 0)) + SUM(ISNULL(praad_Amount1to30, 0)) + SUM(ISNULL(praad_Amount31to60, 0)) + SUM(ISNULL(praad_Amount61to90, 0)) + SUM(ISNULL(praad_Amount91Plus, 0)))) Amount91PlusPct 
    FROM PRARAging WITH (NOLOCK)
        INNER JOIN PRARAgingDetail WITH (NOLOCK) ON praa_ARAgingId = praad_ARAgingId
		INNER JOIN Company ON praad_SubjectCompanyID = Company.Comp_CompanyId
    WHERE praa_Date BETWEEN @StartDate AND @EndDate
        AND praad_SubjectCompanyID IS NOT NULL
		AND comp_PRIndustryType IN ('L')
    GROUP BY YEAR(praa_Date),
        MONTH(praa_Date),
        FORMAT(praa_Date, 'MMM') + '-' + RIGHT(CAST(YEAR(praa_Date) as varchar(4)), 2)
    ORDER BY [Year] ASC,
        [Month] ASC
END

GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].usp_DeleteAdCampaign'))
     DROP PROCEDURE dbo.usp_DeleteAdCampaign
GO

CREATE PROCEDURE [dbo].[usp_DeleteAdCampaign]
	@AdCampaignID int,
	@Commit bit = 0
As
BEGIN
	SET NOCOUNT ON
	if (@Commit = 0) begin
		PRINT '*************************************************************'
		PRINT 'NOTE: COMMIT CHANGES IS TURNED OFF. NO CHANGES WILL BE SAVED!'
		PRINT '*************************************************************'
		PRINT ''
	end
	BEGIN TRANSACTION
	BEGIN TRY
		PRINT '1. Select the bad data to be deleted'
		PRINT '-----------------------------------------------------'
		SELECT COUNT(1) As PRAdCampaignCount FROM PRAdCampaign WITH (NOLOCK) WHERE pradc_AdCampaignID = @AdCampaignID;
		SELECT COUNT(1) As PRAdCampaignFileCount FROM PRAdCampaignFile WITH (NOLOCK) WHERE pracf_AdCampaignID = @AdCampaignID;
		SELECT COUNT(1) As PRAdCampaignTermsCount FROM PRAdCampaignTerms WITH (NOLOCK) WHERE pract_AdCampaignID = @AdCampaignID
		PRINT '';PRINT ''
		PRINT '2. Delete the bad data.'
		PRINT '-----------------------------------------------------'
		DELETE FROM PRAdCampaign WHERE pradc_AdCampaignID = @AdCampaignID;
		DELETE FROM PRAdCampaignFile WHERE pracf_AdCampaignID = @AdCampaignID;
		DELETE FROM PRAdCampaignTerms WHERE pract_AdCampaignID = @AdCampaignID;
		PRINT '';PRINT ''
		PRINT '3. Select the bad data to make sure it no longer exists'
		PRINT '-----------------------------------------------------'
		SELECT COUNT(1) As PRAdCampaignCount FROM PRAdCampaign WITH (NOLOCK) WHERE pradc_AdCampaignID = @AdCampaignID;
		SELECT COUNT(1) As PRAdCampaignFileCount FROM PRAdCampaignFile WITH (NOLOCK) WHERE pracf_AdCampaignID = @AdCampaignID;
		SELECT COUNT(1) As PRAdCampaignTermsCount FROM PRAdCampaignTerms WITH (NOLOCK) WHERE pract_AdCampaignID = @AdCampaignID
		PRINT '';PRINT ''
		if (@Commit = 1) begin
		PRINT 'COMMITTING CHANGES'
			COMMIT
		end else begin
			PRINT 'ROLLING BACK ALL CHANGES'
			ROLLBACK TRANSACTION
		end
		END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
		EXEC usp_RethrowError;
	END CATCH;
END

GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].usp_DeleteAdCampaignHeader'))
     DROP PROCEDURE dbo.usp_DeleteAdCampaignHeader
GO

CREATE PROCEDURE [dbo].[usp_DeleteAdCampaignHeader]
	@AdCampaignHeaderID int,
	@Commit bit = 0
As
BEGIN
	SET NOCOUNT ON
	if (@Commit = 0) begin
		PRINT '*************************************************************'
		PRINT 'NOTE: COMMIT CHANGES IS TURNED OFF. NO CHANGES WILL BE SAVED!'
		PRINT '*************************************************************'
		PRINT ''
	end
	BEGIN TRANSACTION
	BEGIN TRY
		PRINT '1. Select the bad data to be deleted'
		PRINT '-----------------------------------------------------'
		SELECT COUNT(1) As PRAdCampaignHeaderCount FROM PRAdCampaignHeader WITH (NOLOCK) WHERE pradch_AdCampaignHeaderID = @AdCampaignHeaderID;
		SELECT COUNT(1) As PRAdCampaignAdCount FROM PRAdCampaign WITH (NOLOCK) WHERE pradc_AdCampaignHeaderID = @AdCampaignHeaderID;
		SELECT COUNT(1) As PRAdCampaignFileCount FROM PRAdCampaignFile WITH (NOLOCK) WHERE pracf_AdCampaignID IN (SELECT pradc_AdCampaignID FROM PRAdCampaign WHERE pradc_AdCampaignHeaderID = @AdCampaignHeaderID)
		SELECT COUNT(1) As PRAdCampaignTermsCount FROM PRAdCampaignTerms WITH (NOLOCK) WHERE pract_AdCampaignID IN (SELECT pradc_AdCampaignID FROM PRAdCampaign WHERE pradc_AdCampaignHeaderID = @AdCampaignHeaderID)

		PRINT '';PRINT ''
		PRINT '2. Delete the bad data.'
		PRINT '-----------------------------------------------------'
		DELETE FROM PRAdCampaignHeader WHERE pradch_AdCampaignHeaderID = @AdCampaignHeaderID;
		DELETE FROM PRAdCampaignFile WHERE pracf_AdCampaignID IN (SELECT pradc_AdCampaignID FROM PRAdCampaign WHERE pradc_AdCampaignHeaderID = @AdCampaignHeaderID)
		DELETE FROM PRAdCampaignTerms WHERE pract_AdCampaignID IN (SELECT pradc_AdCampaignID FROM PRAdCampaign WHERE pradc_AdCampaignHeaderID = @AdCampaignHeaderID)
		DELETE FROM PRAdCampaign WHERE pradc_AdCampaignHeaderID = @AdCampaignHeaderID;
		
		PRINT '';PRINT ''
		PRINT '3. Select the bad data to make sure it no longer exists'
		PRINT '-----------------------------------------------------'
		SELECT COUNT(1) As PRAdCampaignHeaderCount FROM PRAdCampaignHeader WITH (NOLOCK) WHERE pradch_AdCampaignHeaderID = @AdCampaignHeaderID;
		SELECT COUNT(1) As PRAdCampaignAdCount FROM PRAdCampaign WITH (NOLOCK) WHERE pradc_AdCampaignHeaderID = @AdCampaignHeaderID;
		SELECT COUNT(1) As PRAdCampaignFileCount FROM PRAdCampaignFile WITH (NOLOCK) WHERE pracf_AdCampaignID IN (SELECT pradc_AdCampaignID FROM PRAdCampaign WHERE pradc_AdCampaignHeaderID = @AdCampaignHeaderID)
		SELECT COUNT(1) As PRAdCampaignTermsCount FROM PRAdCampaignTerms WITH (NOLOCK) WHERE pract_AdCampaignID IN (SELECT pradc_AdCampaignID FROM PRAdCampaign WHERE pradc_AdCampaignHeaderID = @AdCampaignHeaderID)
		PRINT '';PRINT ''
		if (@Commit = 1) begin
		PRINT 'COMMITTING CHANGES'
			COMMIT
		end else begin
			PRINT 'ROLLING BACK ALL CHANGES'
			ROLLBACK TRANSACTION
		end
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

GO



/**
Returns the AR ad data for billing
**/
IF EXISTS  (SELECT * FROM dbo.sysobjects  WHERE id = object_id(N'[dbo].[usp_PRAd_AR_Data]')) 
	DROP PROCEDURE [dbo].usp_PRAd_AR_Data
GO

CREATE PROCEDURE [dbo].usp_PRAd_AR_Data
	@AdCampaignID int,
	@AdCampaignType varchar(100),
	@AdCampaignPremium varchar(1) = 'N',
	@AdCampaignSubType varchar(100) = NULL
AS  
BEGIN
	DECLARE @Today date = CAST(GETDATE() AS DATE)
	DECLARE @ItemCode varchar(100)
	DECLARE @IndustryType varchar(40)

	SELECT @IndustryType = comp_PRIndustryType
	  FROM PRAdCampaign WITH (NOLOCK)
	       INNER JOIN Company WITH (NOLOCK) ON pradc_CompanyID = comp_CompanyID 
	 WHERE pradc_AdCampaignID = @AdCampaignID

	IF @IndustryType = 'L' BEGIN
		SET @ItemCode = 'LMBAD'
	END
	ELSE IF @AdCampaignType = 'D' BEGIN
		SET @ItemCode = dbo.ufn_AccountingCodeLookup(@AdCampaignSubType, @AdCampaignPremium) 
	END
	ELSE IF @AdCampaignType = 'TT' BEGIN 
		SET @ItemCode = 'TTAD'
	END
	ELSE IF @AdCampaignType = 'KYC' BEGIN 
		SET @ItemCode = dbo.ufn_AccountingCodeLookup('KYC', @AdCampaignPremium)
	END
	ELSE IF @AdCampaignType = 'BP' BEGIN 
		SET @ItemCode = 'BPAD'
	END

	SELECT DISTINCT 
			pradc_AdCampaignID AdCampaignID,
			'0' + CAST(ship.comp_CompanyID as varchar(10)) CompanyID, 
			'BillToName' = CASE WHEN bill.comp_CompanyID = ship.comp_CompanyID THEN '' ELSE SUBSTRING(bill.comp_PRCorrTradestyle, 1, 30) END,
			'BillToAddress1' = CASE WHEN bill.comp_CompanyID = ship.comp_CompanyID THEN '' ELSE RTRIM(bl.Addr_Address1) END,
			'BillToAddress2' = CASE WHEN bill.comp_CompanyID = ship.comp_CompanyID THEN '' ELSE ISNULL(RTRIM(bl.Addr_Address2), '') END,
			'BillToAddress3' = CASE WHEN bill.comp_CompanyID = ship.comp_CompanyID THEN '' ELSE ISNULL(RTRIM(bl.Addr_Address3), '') END,
			'BillToZipCode' = CASE WHEN bill.comp_CompanyID = ship.comp_CompanyID THEN '' ELSE ISNULL(bl.addr_uszipfive,'') END,
			'BillToCity' = CASE WHEN bill.comp_CompanyID = ship.comp_CompanyID THEN '' ELSE bl.prci_City END,
			'BillToState' = CASE WHEN bill.comp_CompanyID = ship.comp_CompanyID THEN '' ELSE ISNULL(bl.prst_Abbreviation,'') END,
			'BillToCountryCode' = CASE WHEN bill.comp_CompanyID = ship.comp_CompanyID THEN '' ELSE RIGHT('00'+ CONVERT(VARCHAR, bl.prcn_CountryId), 3) END,
			'ShipToName' = CASE WHEN (prattn_PersonID IS NULL AND prattn_CustomLine IS NULL) THEN ship.comp_PRCorrTradestyle ELSE 'Attn: ' + ISNULL(prattn_CustomLine, dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_MiddleName, null, pers_Suffix)) END,
			'ShipToAddress1' = RTRIM(tx.Addr_Address1), 
			'ShipToAddress2' = ISNULL(RTRIM(tx.Addr_Address2), ''), 
			'ShipToAddress3' = ISNULL(RTRIM(tx.Addr_Address3), ''), 
			'ShipToZipCode' = ISNULL(tx.addr_uszipfive,''), 
			'ShipToCity' = tx.prci_City, 
			'ShipToState' = ISNULL(tx.prst_Abbreviation,''), 
			'ShipToCountryCode' = RIGHT('00'+ CONVERT(VARCHAR, tx.prcn_CountryId),3), 
			'TaxSchedule' = dbo.ufn_GetTaxCode(bl.addr_AddressID), 
			'BillToDivisionNo' = CASE WHEN bill.comp_CompanyID = ship.comp_CompanyID THEN '' ELSE '00' END,
			'BillToCustomerNo' = CASE WHEN bill.comp_CompanyID = ship.comp_CompanyID THEN '' ELSE '0' + CAST(bill.comp_CompanyID as varchar(6)) END,
			ItemCode,
			ItemType,
			ItemCodeDesc, --override this (Jan 2019 blueprints edition, or kyc: postname)
			CI_Item.StandardUnitOfMeasure, 
			IM_ProductLine.CostOfGoodsSoldAcctKey, 
			IM_ProductLine.SalesIncomeAcctKey, 
			CI_Item.TaxClass, 
			1 AS QuantityOrdered
			--StandardUnitPrice, --Terms record qty*price
			--(dbo.ufn_GetListingDLLineCount(ship.comp_CompanyID) * StandardUnitPrice) As ExtensionAmt --Terms record qty*price
	FROM PRAdCampaignTerms WITH (NOLOCK) 
		INNER JOIN PRAdCampaign WITH (NOLOCK) ON pract_AdCampaignID = pradc_AdCampaignID 
		INNER JOIN Company ship WITH (NOLOCK) ON pradc_CompanyID = comp_CompanyID 
		INNER JOIN MAS_PRC.dbo.CI_Item ON ItemCode = @ItemCode
		INNER JOIN MAS_PRC.dbo.IM_ProductLine ON CI_Item.ProductLine = IM_ProductLine.ProductLine 
		INNER JOIN Company bill WITH (NOLOCK) ON bill.comp_CompanyID = ship.comp_PRHQID 
		INNER JOIN vPRAddress tx WITH (NOLOCK) ON tx.adli_CompanyId = ship.Comp_CompanyId AND tx.adli_PRDefaultTax = 'Y' 
		LEFT OUTER JOIN PRAttentionLine WITH (NOLOCK) ON prattn_CompanyID = ship.comp_PRHQID AND prattn_ItemCode = 'ADVBILL' 
		LEFT OUTER JOIN vPRAddress bl WITH (NOLOCK) ON prattn_AddressID = bl.Addr_AddressId
		LEFT OUTER JOIN vPerson pers WITH (NOLOCK) ON pers.Pers_PersonId = prattn_PersonID
	WHERE 
		pradc_AdCampaignID = @AdCampaignID AND
		pract_BillingDate IS NOT NULL AND 
		pract_BillingDate <= @Today AND 
		ISNULL(pract_Processed,'N') = 'N'
	ORDER BY '0' + CAST(ship.comp_CompanyID as varchar(10))
END

GO


/******************************************************************************
 *   Procedure: usp_CreateImportPACAComplaint
 *
 *   Return: int - the id of the new record
 *
 *   Decription:  This procedure creates a new ImportPACAComplaint record
 *                supporting the import from file method 
 *
 *
 *****************************************************************************/
if exists (select * from dbo.sysobjects 
			where id = object_id(N'[dbo].[usp_CreateImportPACAComplaint]') 
				and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].usp_CreateImportPACAComplaint
GO
CREATE PROCEDURE dbo.usp_CreateImportPACAComplaint
	@pripc_FileName nvarchar(50)	= null,
	@pripc_ImportDate	datetime = null,
	@pripc_LicenseNumber	nvarchar(8) = null,
	@pripc_BusinessName nvarchar(125)	= null,
	@pripc_InfRepComplaintCount int = null,
	@pripc_DisInfRepComplaintCount int = null,
	@pripc_ForRepComplaintCount int = null, 
	@pripc_DisForRepCompaintCount int = null,
	@pripc_TotalFormalClaimAmt numeric(24,6) = null,
	@UserId int = -1
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @Now DateTime
    SET @Now = getDate()
		DECLARE @TableId int
		--Delete because new record superceded any existing records
		DELETE FROM PRImportPACAComplaint WHERE pripc_LicenseNumber = @pripc_LicenseNumber
	
		DECLARE @pripc_ImportPACAComplaintID int
		
		-- Look up the PACA License ID
		DECLARE @pripc_ImportPACALicenseID int
		SELECT @pripc_ImportPACALicenseID = pril_ImportPACALicenseId 
			FROM PRImportPACALicense WITH (NOLOCK) 
			WHERE pril_LicenseNumber = @pripc_LicenseNumber

		-- get a new ID for the entity
		exec usp_getNextId 'PRImportPACAComplaint', @pripc_ImportPACAComplaintID output

		-- create the new record
		INSERT INTO PRImportPACAComplaint
		(
			pripc_ImportPACAComplaintID, 
			pripc_ImportPACALicenseID,
			pripc_CreatedBy,	pripc_CreatedDate, pripc_UpdatedBy, pripc_UpdatedDate,	pripc_TimeStamp,	pripc_Deleted,
			pripc_FileName, pripc_ImportDate,	pripc_LicenseNumber,	pripc_BusinessName, pripc_InfRepComplaintCount,
			pripc_DisInfRepComplaintCount,	pripc_ForRepComplaintCount, pripc_DisForRepCompaintCount, pripc_TotalFormalClaimAmt
		) Values (
			@pripc_ImportPACAComplaintID,
			@pripc_ImportPACALicenseID, 
			@UserId, @Now, @UserId, @Now, @Now, null,
			@pripc_FileName, @pripc_ImportDate,	@pripc_LicenseNumber,	@pripc_BusinessName, @pripc_InfRepComplaintCount,
			@pripc_DisInfRepComplaintCount,	@pripc_ForRepComplaintCount, @pripc_DisForRepCompaintCount, @pripc_TotalFormalClaimAmt
		);	
		--SELECT @prit_ImportPACATradeId = SCOPE_IDENTITY();
		SET NOCOUNT OFF
		
		return @pripc_ImportPACAComplaintID
END
GO

/******************************************************************************
 *   Procedure: usp_CreatePACAComplaintDetail
 *
 *   Return: int - the id of the new record
 *
 *   Decription:  This procedure creates a new PACAComplaintDetail record
 *
 *****************************************************************************/
if exists (select * from dbo.sysobjects 
			where id = object_id(N'[dbo].[usp_CreatePACAComplaintDetail]') 
				and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].usp_CreatePACAComplaintDetail
GO
CREATE PROCEDURE dbo.usp_CreatePACAComplaintDetail
	@prpacd_LicenseNumber	varchar(8) = null,
	@prpacd_ChangeDate datetime = null,
	@prpacd_InfRepComplaintCount int = null,
	@prpacd_ForRepComplaintCount int = null,
	@UserId int = -1
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @Now DateTime
    SET @Now = getDate()
		DECLARE @prpacd_PRPACAComplaintDetailID int
		
		-- Look up the PACA License ID
		DECLARE @prpacd_PACALicenseID int
		SELECT @prpacd_PACALicenseID = prpa_PACALicenseID FROM PRPACALicense WITH(NOLOCK) WHERE prpa_LicenseNumber=@prpacd_LicenseNumber AND prpa_Current='Y'
		IF @prpacd_PACALicenseID IS NULL BEGIN
			SELECT @prpacd_PACALicenseID = MAX(prpa_PACALicenseID) FROM PRPACALicense WITH(NOLOCK) WHERE prpa_LicenseNumber=@prpacd_LicenseNumber
		END

		-- get a new ID for the entity
		--exec usp_getNextId 'PRPACAComplaintDetail', @prpacd_PRPACAComplaintDetailID output

		-- create the new record
		INSERT INTO PRPACAComplaintDetail
		(
			prpacd_CreatedBy, prpacd_CreatedDate, prpacd_UpdatedBy, prpacd_UpdatedDate, prpacd_TimeStamp, prpacd_Deleted,
			prpacd_PACALicenseID, prpacd_LicenseNumber, prpacd_ChangeDate, prpacd_InfRepComplaintCount, prpacd_ForRepComplaintCount
		) Values (
			@UserId, @Now, @UserId, @Now, @Now, null,
			@prpacd_PACALicenseID, @prpacd_LicenseNumber, @prpacd_ChangeDate,	@prpacd_InfRepComplaintCount,	@prpacd_ForRepComplaintCount
		);	
		SET NOCOUNT OFF
		
		return @prpacd_PRPACAComplaintDetailID
END
GO


/******************************************************************************
 *   Procedure: usp_PACAProcessComplaints
 *
 *   Return: int - the number of complaint records processed
 *
 *   Decription:  This procedure itereates through the ImportPACA... tables and
 *                determines if a matching License Number can be found in the 
 *				  real paca tables.  If so, the record is processed.
 *
 *
 *****************************************************************************/
if exists (select * from dbo.sysobjects 
			where id = object_id(N'[dbo].[usp_PACAProcessComplaints]') 
				and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].usp_PACAProcessComplaints
GO

CREATE PROCEDURE dbo.usp_PACAProcessComplaints
	@UserId int = -1
AS
BEGIN
  SET NOCOUNT ON
  DECLARE @Now DateTime
  SET @Now = GETDATE()

	DECLARE @ComplaintTable Table 
	(	
		ndx int identity, pripc_ImportPACAComplaintID int, pripc_PACALicenseID int
	)

	-- select all the Complaints into the temp table
	Declare @RecordCount int
	INSERT INTO @ComplaintTable 
	SELECT pripc_ImportPACAComplaintID, prpa_PACALicenseID
		FROM PRImportPACAComplaint
		INNER JOIN PRPACALicense ON prpa_LicenseNumber = pripc_LicenseNumber AND prpa_Current='Y'

	SET @RecordCount = @@ROWCOUNT
	DECLARE @ndx int
	DECLARE @prpa_PACALicenseID int, @pripc_ImportPACAComplaintID int,
					@pripc_LicenseNumber varchar(20), @pripc_BusinessName varchar(125),
					@pripc_InfRepComplaintCount int, @pripc_DisInfRepComplaintCount int, @pripc_ForRepComplaintCount int,
					@pripc_DisForRepCompaintCount int, @pripc_TotalFormalClaimAmt numeric(24,6),
					@pripc_CreatedDate datetime 

	SET @ndx=1

	WHILE (@ndx <= @RecordCount)
	BEGIN
		SELECT 
			@prpa_PACALicenseID=pripc_PACALicenseID, @pripc_ImportPACAComplaintID=IC.pripc_ImportPACAComplaintID,
			@pripc_LicenseNumber=pripc_LicenseNumber, @pripc_BusinessName=pripc_BusinessName,
			@pripc_InfRepComplaintCount=pripc_InfRepComplaintCount, @pripc_DisInfRepComplaintCount=pripc_DisInfRepComplaintCount,
			@pripc_ForRepComplaintCount=pripc_ForRepComplaintCount, @pripc_DisForRepCompaintCount=pripc_DisForRepCompaintCount,
			@pripc_TotalFormalClaimAmt=pripc_TotalFormalClaimAmt, @pripc_CreatedDate=pripc_CreatedDate
		FROM @ComplaintTable C
		INNER JOIN PRImportPACAComplaint IC ON C.pripc_ImportPACAComplaintID = IC.pripc_ImportPACAComplaintID
		WHERE ndx = @ndx

		DECLARE @Subject varchar(100)
		DECLARE @Body varchar(max)
		DECLARE @Msg varchar(max)
		DECLARE @UserEmailAddress nchar(255)

		-- If a record does not have a license number and was added since the last import 
		-- (in the past 24 hours), then send an email to ratings@bluebookservices.com.
		-- "PACA Complaint data without a License found."  Include the name of the business and the five data fields.
		IF(@prpa_PACALicenseID IS NULL AND @pripc_CreatedDate > DATEADD(day,-1,GETDATE())) 
		BEGIN
			SET @UserEmailAddress = 'ratings@bluebookservices.com'
			SET @Subject = 'PACA Complaint data without a License found'
			
			SET @Body = @Subject + '.<br/><br/>'
			SET @Body = @Body + '<b>Business Name:</b> ' + ISNULL(@pripc_BusinessName,'') + '<br/><br/>'
			SET @Body = @Body + '<b>Disputed Informal Reparation Complaints:</b> ' + CAST(@pripc_DisInfRepComplaintCount as varchar(10))  + '<br/>'
			SET @Body = @Body + '<b>Informal Reparation Complaints:</b> ' + CAST(@pripc_InfRepComplaintCount as varchar(10)) + '<br/>'
			SET @Body = @Body + '<b>Disputed Formal Reparation Complaints:</b> ' + CAST(@pripc_DisForRepCompaintCount  as varchar(10)) + '<br/>'
			SET @Body = @Body + '<b>Formal Repration Complaints:</b> ' + CAST(@pripc_ForRepComplaintCount  as varchar(10)) + '<br/><br/>'
			SET @Body = @Body + '<b>Total Formal Claim Amount:</b> ' + FORMAT(@pripc_TotalFormalClaimAmt, 'c', 'en-us') + '<br/>'

			SELECT @UserEmailAddress, @Subject, @Body
			
			EXEC usp_CreateEmail
				@CreatorUserID = -1,
				@To = @UserEmailAddress,
				@Subject = @Subject,
				@Content = @Body,
				@Content_Format = 'HTML',
				@Action = 'EmailOut',
				@DoNotRecordCommunication = 1
		END

		DECLARE @prpa_CompanyId int
		DECLARE @RatingUserId int

		-- If a record does not exist for the license number in the PRPACAComplaint table, insert it into that table, 
		-- delete it from the import table. Create an interaction for the associated company assigning it to the companys 
		-- rating analyst (ufn_GetPRCoSpecialistUserID()).  
		-- "This company has new PACA complaint data."
		IF(@prpa_PACALicenseID IS NOT NULL AND NOT EXISTS(SELECT * FROM PRPACAComplaint WHERE prpac_PACALicenseID=@prpa_PACALicenseID))
		BEGIN
			DECLARE @prpac_PACAComplaintID int
			exec usp_getNextId 'PRPACAComplaint', @prpac_PACAComplaintID output
			
			INSERT INTO PRPACAComplaint(prpac_PACAComplaintID, prpac_PACALicenseID, prpac_InfRepComplaintCount, prpac_DisInfRepComplaintCount, prpac_ForRepComplaintCount, prpac_DisForRepCompaintCount, prpac_TotalFormalClaimAmt, prpac_TotalFormalClaimAmt_CID)
				VALUES (@prpac_PACAComplaintID, @prpa_PACALicenseID, @pripc_InfRepComplaintCount, @pripc_DisInfRepComplaintCount, @pripc_ForRepComplaintCount, @pripc_DisForRepCompaintCount, @pripc_TotalFormalClaimAmt, 1)

			DELETE FROM PRImportPACAComplaint WHERE pripc_ImportPACAComplaintID=@pripc_ImportPACAComplaintID

			SELECT @prpa_CompanyId = prpa_CompanyID FROM PRPACALicense WHERE prpa_PACALicenseId = @prpa_PACALicenseID
			SELECT @RatingUserId = dbo.ufn_GetPRCoSpecialistUserId(@prpa_CompanyId, 0)

			SELECT @msg = 'This company has new PACA complaint data.  Please Review.'
			
			EXEC usp_CreateTask     
				@StartDateTime = @Now,
				@CreatorUserId = -1,
				@AssignedToUserId = @RatingUserId,
				@TaskNotes = @msg,
				@RelatedCompanyId = @prpa_CompanyId,
				@Status = 'Pending',
				@Subject = @msg
		END

		IF(EXISTS(SELECT * FROM PRPACAComplaint WHERE prpac_PACALicenseID = @prpa_PACALicenseID))
		BEGIN
			--Record does exist for the license number in the PRPACAComplaint table
			SELECT @prpa_CompanyId = prpa_CompanyID FROM PRPACALicense WHERE prpa_PACALicenseId = @prpa_PACALicenseID
			SELECT @RatingUserId = dbo.ufn_GetPRCoSpecialistUserId(@prpa_CompanyId, 0)

			--Update the data in PRPACAComplaint
			UPDATE PRPACAComplaint
			SET prpac_InfRepComplaintCount=@pripc_InfRepComplaintCount,
					prpac_DisInfRepComplaintCount=@pripc_DisInfRepComplaintCount, 
					prpac_ForRepComplaintCount=@pripc_ForRepComplaintCount, 
					prpac_DisForRepCompaintCount=@pripc_DisForRepCompaintCount,
					prpac_TotalFormalClaimAmt=@pripc_TotalFormalClaimAmt,
					prpac_UpdatedDate=GETDATE()
			WHERE
				prpac_PACALicenseID = @prpa_PACALicenseID

			--Delete it from the import table
			DELETE FROM PRImportPACAComplaint WHERE pripc_ImportPACAComplaintID=@pripc_ImportPACAComplaintID

			-- Look at the five business data columns.
			-- If all are empty/zero, Create an interaction for the associated company assigning it to the companys rating analyst (ufn_GetPRCoSpecialistUserID()).
			-- "This company no longer has any PACA complaint data."

			IF(ISNULL(@pripc_InfRepComplaintCount,0) = 0
			  AND ISNULL(@pripc_DisInfRepComplaintCount,0) = 0
			  AND ISNULL(@pripc_ForRepComplaintCount,0) = 0
			  AND ISNULL(@pripc_DisForRepCompaintCount,0) = 0
			  AND ISNULL(@pripc_TotalFormalClaimAmt,0) = 0)
			BEGIN
				DELETE FROM PRPACAComplaint WHERE prpac_PACALicenseID = @prpa_PACALicenseID

				SELECT @msg = 'This company no longer has any PACA complaint data.  Please Review.'

				EXEC usp_CreateTask     
					@StartDateTime = @Now,
					@CreatorUserId = -1,
					@AssignedToUserId = @RatingUserId,
					@TaskNotes = @msg,
					@RelatedCompanyId = @prpa_CompanyId,
					@Status = 'Pending',
					@Subject = @msg
			END
			ELSE
			BEGIN
				-- Compare the five business data columns.
				-- If any have changed, Create an interaction for the associated company assigning it to the companys rating analyst (ufn_GetPRCoSpecialistUserID()).  
				-- "This company has updated PACA complaint data."

				DECLARE @prpac_InfRepComplaintCount int, @prpac_DisInfRepComplaintCount int, @prpac_ForRepComplaintCount int, @prpac_DisForRepCompaintCount int, @prpac_TotalFormalClaimAmt numeric(24,6)
				SELECT @prpac_InfRepComplaintCount=prpac_InfRepComplaintCount,
					@prpac_DisInfRepComplaintCount=prpac_DisInfRepComplaintCount,
					@prpac_ForRepComplaintCount=prpac_ForRepComplaintCount,
					@prpac_DisForRepCompaintCount=prpac_DisForRepCompaintCount,
					@prpac_TotalFormalClaimAmt=prpac_TotalFormalClaimAmt
				FROM PRPACAComplaint WHERE prpac_PACALicenseID = @prpa_PACALicenseID

				IF(ISNULL(@pripc_InfRepComplaintCount,0) <> ISNULL(@prpac_InfRepComplaintCount,0)
					OR ISNULL(@pripc_DisInfRepComplaintCount,0) <> ISNULL(@prpac_DisInfRepComplaintCount,0)
					OR ISNULL(@pripc_ForRepComplaintCount,0) <> ISNULL(@prpac_ForRepComplaintCount,0)
					OR ISNULL(@pripc_DisForRepCompaintCount,0) <> ISNULL(@prpac_DisForRepCompaintCount,0)
					OR ISNULL(@pripc_TotalFormalClaimAmt,0) <> ISNULL(@prpac_TotalFormalClaimAmt,0))
				BEGIN
					SELECT @msg = 'This company has updated PACA complaint data.  Please Review.'

					EXEC usp_CreateTask     
						@StartDateTime = @Now,
						@CreatorUserId = -1,
						@AssignedToUserId = @RatingUserId,
						@TaskNotes = @msg,
						@RelatedCompanyId = @prpa_CompanyId,
						@Status = 'Pending',
						@Subject = @msg
				END
			END
		END

		SET @ndx = @ndx + 1
	END
END
GO


CREATE OR ALTER PROCEDURE [dbo].[usp_PopulatePRCommodity2]
as 
	SET NOCOUNT ON

	-- As a result of reorganizing the commodities, PIKS has some scenarios 
	-- where the computed name can exceed the length allowed by BBS.  Per
	-- PRCo, we should just truncate the name in these circumstances.
	DECLARE @Commodity table (
			prcm_CommodityID int,	
			prcm_CommodityCode nvarchar(36),
			prcm_PathCode nvarchar(300),
			prcm_Name nvarchar(50),
			prcm_Name_ES nvarchar(50),
			prcm_Key char(1)
	)

	--Get all commodities that are level 1-3.  This is type 1 in the Mapping 
	--commodity homwork.
	INSERT INTO @Commodity
	SELECT 
		prcm_CommodityID,
		rtrim(prcm_CommodityCode),
		rtrim(prcm_PathCodes),
		rtrim(prcm_Name),
		rtrim(prcm_Name_ES),
		'Y'
	from PRCommodity
	where prcm_level < 4



	--Get all level 4 commodities.  This is type 3 in the Mapping commodity homework.
	INSERT INTO @Commodity
	SELECT 
		a.prcm_CommodityID, 	
		(rtrim(a.prcm_CommodityCode)+ rtrim(lower(b.prcm_CommodityCode))),
		rtrim(a.prcm_PathCodes),	
		(rtrim(a.prcm_Name)+' '+rtrim(lower(b.prcm_Name))),
		(rtrim(a.prcm_Name_ES)+' '+rtrim(lower(b.prcm_Name_ES))),
		NULL
	from PRCommodity a 
		inner join PRCommodity b on a.prcm_ParentID=b.prcm_CommodityID
	where 
		a.prcm_level = 4
		and a.prcm_Name != b.prcm_Name



	--Get all level 5 commodities where parent is a level 3.  Thi is type 2
	-- in the mapping commodity homework.
	INSERT INTO @Commodity
	SELECT 
		a.prcm_CommodityID, 	
		(rtrim(a.prcm_CommodityCode)+ rtrim(lower(b.prcm_CommodityCode))),
		rtrim(a.prcm_PathCodes),
		(rtrim(a.prcm_Name)+' '+rtrim(lower(b.prcm_Name))),
		(rtrim(a.prcm_Name_ES)+' '+rtrim(lower(b.prcm_Name_ES))),
		NULL
	from PRCommodity a 
		inner join PRCommodity b on a.prcm_ParentID=b.prcm_CommodityID
	where 
		a.prcm_level = 5
		and b.prcm_Level=3
		and a.prcm_Name != b.prcm_Name


	--Get all level 5 commodities where parent is a level 4.  This is type 4 in
	--the commodity
	INSERT INTO @Commodity
	SELECT 
		a.prcm_CommodityID, 	
		(rtrim(a.prcm_CommodityCode)+ rtrim(lower(b.prcm_CommodityCode)) + rtrim(lower(c.prcm_CommodityCode))),
		rtrim(a.prcm_PathCodes),
		(rtrim(a.prcm_Name) + ' ' + rtrim(lower(b.prcm_Name)) + ' ' + rtrim(lower(c.prcm_Name))),
        (rtrim(a.prcm_Name_ES) + ' ' + rtrim(lower(b.prcm_Name_ES)) + ' ' + rtrim(lower(c.prcm_Name_ES))),
		NULL
	from PRCommodity a 
		inner join PRCommodity b on a.prcm_ParentID=b.prcm_CommodityID
		inner join PRCommodity c on b.prcm_ParentID=c.prcm_CommodityID
	where 
		a.prcm_level = 5
		and b.prcm_Level=4
		and c.prcm_Name != a.prcm_Name
		and c.prcm_Name != b.prcm_Name
		and a.prcm_name != b.prcm_Name


	--Get all level 6 commodities where parent is a level 5.  This is type 5 in
	--the commodity
	INSERT INTO @Commodity
	SELECT 
		a.prcm_CommodityID, 	
		(rtrim(a.prcm_CommodityCode)+ rtrim(lower(b.prcm_CommodityCode)) + rtrim(lower(c.prcm_CommodityCode))),
		rtrim(a.prcm_PathCodes),
		(rtrim(a.prcm_Name) + ' ' + rtrim(lower(b.prcm_Name)) + ' ' + rtrim(lower(c.prcm_Name))),
		(rtrim(a.prcm_Name_ES) + ' ' + rtrim(lower(b.prcm_Name_ES)) + ' ' + rtrim(lower(c.prcm_Name_ES))),
		NULL
	from PRCommodity a 
		inner join PRCommodity b on a.prcm_ParentID=b.prcm_CommodityID
		inner join PRCommodity c on b.prcm_ParentID=c.prcm_CommodityID
	where 
		a.prcm_level = 6
		and b.prcm_Level=5
		and c.prcm_Name != a.prcm_Name
		and c.prcm_Name != b.prcm_Name
		and a.prcm_name != b.prcm_Name;

	-- Create Combinations of Commodities and attributes
	CREATE TABLE #CmdVal (
	      CommodityID int,
		  AttributeID int,
		  GrowingMethodID int,
		  [COMMOD] [varchar](45) NULL,
		  [DESC] [varchar](200) NULL,
		  [DESC_SPANISH] [varchar](200) NULL,
		  [KEY] [varchar](1) NULL
	) 

	--Get all commodities without attributes
	INSERT INTO #CmdVal (CommodityID, COMMOD, [DESC], [DESC_SPANISH], [KEY])
	SELECT prcm_CommodityID, prcm_CommodityCode, prcm_Name, prcm_Name_ES, prcm_key
	  FROM @Commodity;

	--Get combinations of all commodities and growing methods
	INSERT INTO #CmdVal (CommodityID, GrowingMethodID, COMMOD, [DESC], [DESC_SPANISH])
	SELECT prcm_CommodityID, prat_AttributeId, RTRIM(prat_Abbreviation) + RTRIM(LOWER(prcm_CommodityCode)), 
		   RTRIM(prat_Name) + ' ' + RTRIM(Lower(prcm_Name)),
		   RTRIM(prat_Name_ES) + ' ' + RTRIM(Lower(prcm_Name_ES))
	  FROM PRAttribute CROSS JOIN
		   @Commodity
	 WHERE prat_Type = 'GM';

	--Get all combinations of all commodities and all non-growing method attributes
	--where the attribute is placed BEFORE the commodity.
	INSERT INTO #CmdVal (CommodityID, AttributeID, COMMOD, [DESC], [DESC_SPANISH])
	SELECT prcm_CommodityID, prat_AttributeId, RTRIM(prat_Abbreviation) + RTRIM(LOWER(prcm_CommodityCode)), 
		   RTRIM(prat_Name) + ' ' + RTRIM(Lower(prcm_Name)),
		   RTRIM(prat_Name_ES) + ' ' + RTRIM(Lower(prcm_Name_ES))
	  FROM PRAttribute CROSS JOIN
		   @Commodity
	 WHERE prat_Type != 'GM'
		and prat_PlacementAfter is null;


	--Get all combinations of all commodities and all non-growing method attributes
	--where the attribute is placed AFTER the commodity.
	INSERT INTO #CmdVal (CommodityID, AttributeID, COMMOD, [DESC], [DESC_SPANISH])
	SELECT prcm_CommodityID, prat_AttributeId, RTRIM(prcm_CommodityCode) + RTRIM(lower(prat_Abbreviation)) , 
		   RTRIM(prcm_Name)+ ' ' + Rtrim(lower(prat_Name)),
		   RTRIM(prcm_Name_ES) + ' ' + RTRIM(Lower(prat_Name_ES))
	  FROM PRAttribute CROSS JOIN
		   @Commodity
	 WHERE prat_Type != 'GM'
		and prat_PlacementAfter is not null;

	--This is hard-coded to fit commodity exercise from Kathi's spreadsheet on 9/23/2019
	--Per discussion between CHW and JMT
	--INSERT INTO #CmdVal (COMMOD, [DESC])
	--VALUES('Pricklycactusprpuree', 'Prickly Pear Cactus Puree')

	--Get all combinations of all commodities and all growing methods and all attributes
	--where the attribute is placed BEFORE the commodity.
	INSERT INTO #CmdVal (CommodityID, GrowingMethodID, AttributeID, COMMOD, [DESC], [DESC_SPANISH])
	SELECT prcm_CommodityID, gm.prat_AttributeId, a.prat_AttributeId, RTRIM(gm.prat_Abbreviation) + RTRIM(lower(a.prat_Abbreviation)) + RTRIM(LOWER(prcm_CommodityCode)), 
		   RTRIM(gm.prat_Name) + ' ' + RTRIM(lower(a.prat_Name)) + ' ' + RTRIM(lower(prcm_Name)),
		   RTRIM(gm.prat_Name_ES) + ' ' + RTRIM(lower(a.prat_Name_ES)) + ' ' + RTRIM(lower(prcm_Name_ES))
	  FROM PRAttribute a CROSS JOIN
			PRAttribute gm cross join
		   @Commodity 
	 WHERE a.prat_Type != 'GM'
		and a.prat_PlacementAfter is null
		and gm.prat_Type = 'GM';


	--Get all combinations of all commodities and all growing methods and all attributes
	--where the attribute is placed AFTER the commodity.
	INSERT INTO #CmdVal (CommodityID, GrowingMethodID, AttributeID, COMMOD, [DESC], [DESC_SPANISH])
	SELECT prcm_CommodityID, gm.prat_AttributeId, a.prat_AttributeId, RTRIM(gm.prat_Abbreviation)  + RTRIM(LOWER(prcm_CommodityCode))+ RTRIM(Lower(a.prat_Abbreviation)), 
		   RTRIM(gm.prat_Name)  + ' ' + RTRIM(Lower(prcm_Name))+ ' ' + RTRIM(Lower(a.prat_Name)),
		   RTRIM(gm.prat_Name_ES) + ' ' + RTRIM(lower(prcm_Name_ES)) + ' ' + RTRIM(lower(a.prat_Name_ES))
	  FROM PRAttribute a CROSS JOIN
			PRAttribute gm cross join
		   @Commodity 
	 WHERE a.prat_Type != 'GM'
		and a.prat_PlacementAfter='Y'
		and gm.prat_Type = 'GM'

	-- This is a hack to take care of an new situation.  We have a commodity Breadn and a separate
	-- commodity Breadnseeds.  However, when we build this commodity attribute matrix, we combine Breadn + seeds
	-- to end up with two Breadnseeds.  This causes duplicate records to dispaly in other areas of the 
	-- system.  Just delete the second record for now.  CHW 3/22/2018
	DELETE FROM #CmdVal WHERE COMMOD = 'Breadnseeds' AND [Key] IS NULL

	-- Let's add any new records to our lookup table.
	DECLARE @Count int, @Index int, @ID int
	DECLARE @Commod varchar(40), @Description varchar(200), @Description_ES varchar(200), @Key varchar(1)
	DECLARE @NewCommods table (
		ndx int identity(1,1) primary key,
		CommodityID int,
		AttributeID int,
		GrowingMethodID int,
		commod varchar(50),
		description varchar(100),
		description_ES varchar(100),
		keyflag varchar(1)
	)

	DECLARE @OldCommods table (
		ndx int identity(1,1) primary key,
		CommodityID int,
        AttributeID int,
		GrowingMethodID int,
		commod varchar(50),
		description varchar(200),
		description_ES varchar(200),
		keyflag varchar(1)
	)

	INSERT INTO @NewCommods (CommodityID, AttributeID, GrowingMethodID, commod, description, description_ES, keyflag)
	SELECT DISTINCT CommodityID, AttributeID, GrowingMethodID, COMMOD, [DESC], DESC_SPANISH, [key]
	  FROM #CmdVal
	 WHERE NOT EXISTS 
	 (
		SELECT prcm_Commodity2ID FROM PRCommodity2 
		WHERE prcm_CommodityID=CommodityID
			AND ISNULL(prcm_AttributeID,-1)=ISNULL(AttributeID ,-1)
			AND ISNULL(prcm_GrowingMethodID,-1)=ISNULL(GrowingMethodID,-1)
	 );

	INSERT INTO @OldCommods (CommodityID, AttributeID, GrowingMethodID, commod, description, description_ES, keyflag)
	SELECT DISTINCT CommodityID, AttributeID, GrowingMethodID, COMMOD, [DESC], DESC_SPANISH, [key]
	  FROM #CmdVal
	 WHERE EXISTS 
	 (
		SELECT prcm_Commodity2ID FROM PRCommodity2 
		WHERE prcm_CommodityID=CommodityID
			AND ISNULL(prcm_AttributeID,-1)=ISNULL(AttributeID ,-1)
			AND ISNULL(prcm_GrowingMethodID,-1)=ISNULL(GrowingMethodID,-1)
	 );

	SELECT @Count = COUNT(1)
	  FROM @NewCommods;
	SET @Index = 0

	DECLARE @RecordID int, @CommodityID int, @AttributeID int, @GrowingMethodID int

	WHILE @Index < @Count BEGIN
		SET @Index = @Index + 1

		SELECT @CommodityID = CommodityID,
			   @AttributeID = AttributeID,
			   @GrowingMethodID = GrowingMethodID,
		       @Commod = Commod,
			   @Description = description,
			   @Description_ES = description_ES,
			   @Key = keyflag
		  FROM @NewCommods
		 WHERE ndx = @Index;
		
		EXEC usp_GetNextID 'PRCommodity2', @ID OUTPUT

		INSERT INTO PRCommodity2
			(prcm_Commodity2ID, prcm_CommodityID, prcm_AttributeID, prcm_GrowingMethodID, prcm_Abbreviation, prcm_Description, prcm_Description_ES, prcm_DescriptionMatch, prcm_CreatedBy, prcm_CreatedDate, prcm_UpdatedBy, prcm_UpdatedDate, prcm_TimeStamp)
			VALUES (@ID, @CommodityID, @AttributeID, @GrowingMethodID, @Commod, @Description, @Description_ES, dbo.GetLowerAlpha(@Description), -1, GETDATE(), -1, GETDATE(), GETDATE());

	END

	-- Now update the existing abbreviations
	UPDATE PRCommodity2
	   SET prcm_Description = [Description],
	       prcm_description_ES = description_ES,
		   prcm_DescriptionMatch = dbo.GetLowerAlpha([Description])
	  FROM @OldCommods 
	 WHERE prcm_CommodityID = CommodityID 
	   AND prcm_Abbreviation = commod;

	UPDATE PRCommodity2
	   SET prcm_Alias = old.prcm_Alias,
		   prcm_AliasMatch = dbo.GetLowerAlpha(old.prcm_Alias)
	  FROM PRCommodity old
	 WHERE PRCommodity2.prcm_CommodityID = old.prcm_CommodityId
	   AND PRCommodity2.prcm_AttributeID IS NULL
	   AND PRCommodity2.prcm_GrowingMethodID IS NULL
	   AND old.prcm_Alias IS NOT NULL;

	DROP TABLE #CmdVal
GO

/******************************************************************************
 *   Procedure: usp_Alerts_GetMonitoredCompanies
 *
 *
 *   Decription:  Originally dsMonitoredCompany in the Alerts report.
 *                Pulled here for reuse.
 *
 *****************************************************************************/
if exists (select * from dbo.sysobjects 
			where id = object_id(N'[dbo].[usp_Alerts_GetMonitoredCompanies]') 
				and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].usp_Alerts_GetMonitoredCompanies
GO

CREATE PROCEDURE dbo.usp_Alerts_GetMonitoredCompanies
	@PersonID int,
	@CompanyID int,
	@StartDate datetime,
	@EndDate datetime
AS
BEGIN
	DECLARE @ChangePreference varchar(40)
	SELECT @ChangePreference = ISNULL(peli_PRAUSChangePreference,1)
	  FROM Person_Link WITH (NOLOCK)
	 WHERE peli_PersonID = @PersonID
	   AND peli_CompanyID = @CompanyID
	   AND peli_PRStatus In ('1', '2');

	SELECT DISTINCT MonitoredCompanyID, comp_PRCorrTradestyle, CityStateCountryShort
	  FROM (

		SELECT DISTINCT prwuld_AssociatedID As MonitoredCompanyID
		  FROM PRWebUserListDetail WITH (NOLOCK)
		       INNER JOIN PRWebUserList WITH (NOLOCK) on prwuld_WebUserListID = prwucl_WebUserListID
			   INNER JOIN PRWebUser WITH (NOLOCK) on prwucl_WebUserID = prwu_WebUserID
		       INNER JOIN Person_Link WITH (NOLOCK) on prwu_PersonLinkID = peli_PersonLinkID
			   INNER JOIN PRCreditSheet WITH (NOLOCK) on prwuld_AssociatedID = prcs_CompanyID
			   LEFT OUTER JOIN PRCompanyIndicators WITH (NOLOCK) ON prci2_CompanyID = peli_CompanyID
		 WHERE peli_PersonID = @PersonID
           AND peli_CompanyID = @CompanyID
           AND peli_PRStatus In ('1', '2')
           AND prwucl_TypeCode = 'AUS' 
		   AND prwu_Disabled IS NULL
		   AND prwu_ServiceCode IS NOT NULL
           AND prcs_PublishableDate BETWEEN @StartDate AND @EndDate
           AND prcs_Status = 'P' 
           AND prcs_NewListing IS NULL
           AND ISNULL(prcs_KeyFlag, 'N') = CASE WHEN @ChangePreference ='1' THEN 'Y' ELSE ISNULL(prcs_KeyFlag, 'N')  END
		   AND prci2_Suspended IS NULL
		UNION
		SELECT DISTINCT prbr_RequestedCompanyID As MonitoredCompanyID
			   FROM PRWebUserList WITH (NOLOCK)
			   INNER JOIN PRWebUser WITH (NOLOCK) on prwucl_WebUserID = prwu_WebUserID
		       INNER JOIN Person_Link WITH (NOLOCK) on prwu_PersonLinkID = peli_PersonLinkID
 			   INNER JOIN PRBusinessReportRequest WITH (NOLOCK) ON peli_PersonID = prbr_RequestingPersonID and peli_CompanyID = prbr_RequestingCompanyID 
			   INNER JOIN PRCreditSheet WITH (NOLOCK) on prbr_RequestedCompanyID = prcs_CompanyID			   
			   LEFT OUTER JOIN PRCompanyIndicators WITH (NOLOCK) ON prci2_CompanyID = peli_CompanyID
		 WHERE peli_PersonID = @PersonID
           AND peli_CompanyID = @CompanyID
           AND peli_PRStatus In ('1', '2')
           AND prwucl_TypeCode = 'AUS' 
		   AND prwu_Disabled IS NULL
		   AND prwu_ServiceCode IS NOT NULL
		   AND prcs_PublishableDate BETWEEN @StartDate AND @EndDate
		   AND prcs_Status = 'P' 
		   AND prcs_NewListing IS NULL
		   AND ISNULL(prcs_KeyFlag, 'N') = CASE WHEN @ChangePreference ='1' THEN 'Y' ELSE ISNULL(prcs_KeyFlag, 'N')  END
		   AND prbr_CreatedDate > DATEADD(month, -6, GETDATE())
		   AND prci2_Suspended IS NULL
		UNION      
		SELECT DISTINCT prwuld_AssociatedID As MonitoredCompanyID
	  	  FROM PRWebUserListDetail WITH (NOLOCK)
		       INNER JOIN PRWebUserList WITH (NOLOCK) on prwuld_WebUserListID = prwucl_WebUserListID
			   INNER JOIN PRWebUser WITH (NOLOCK) on prwucl_WebUserID = prwu_WebUserID
		       INNER JOIN Person_Link WITH (NOLOCK) on prwu_PersonLinkID = peli_PersonLinkID
		       INNER JOIN (
				    SELECT wppmac.*, ca.*, post_date 
					  FROM WordPressProduce.dbo.wp_posts WITH (NOLOCK)
					       LEFT OUTER JOIN WordPressProduce.dbo.wp_PostMeta wppmac WITH (NOLOCK) ON wp_posts.ID = wppmac.post_id AND meta_key = 'associated-companies'
					       LEFT OUTER JOIN (SELECT post_ID FROM WordPressProduce.dbo.wp_PostMeta WHERE meta_key='blueprintEdition') bpe ON bpe.post_ID = wp_posts.ID
					       CROSS APPLY CRM.dbo.Tokenize(meta_value, ',') ca
				     WHERE post_type = 'post'
					   AND post_status in('publish')
					   AND post_date BETWEEN @StartDate AND @EndDate
					   AND meta_value IS NOT NULL
					AND (bpe.post_ID IS NULL OR dbo.ufn_GetWordPressBluePrintsEdition(ID) = '')
			    ) wp ON wp.value = prwuld_AssociatedID
                LEFT OUTER JOIN PRCompanyIndicators WITH (NOLOCK) ON prci2_CompanyID = peli_CompanyID
		 WHERE peli_PersonID = @PersonID
           AND peli_CompanyID = @CompanyID
           AND peli_PRStatus In ('1', '2')
           AND peli_PRAUSChangePreference = '2'
		   AND prwucl_TypeCode = 'AUS' 
		   AND prwu_Disabled IS NULL
		   AND prwu_ServiceCode IS NOT NULL
           AND wp.post_date BETWEEN @StartDate AND @EndDate
		   AND prci2_Suspended IS NULL
	   UNION
		SELECT DISTINCT prss_RespondentCompanyId As MonitoredCompanyID
   	      FROM PRWebUserListDetail WITH (NOLOCK)
		       INNER JOIN PRWebUserList WITH (NOLOCK) on prwuld_WebUserListID = prwucl_WebUserListID
			   INNER JOIN PRWebUser WITH (NOLOCK) on prwucl_WebUserID = prwu_WebUserID
		       INNER JOIN Person_Link WITH (NOLOCK) on prwu_PersonLinkID = peli_PersonLinkID
			   INNER JOIN PRSSFile WITH (NOLOCK) on prwuld_AssociatedID = prss_RespondentCompanyId
			   LEFT OUTER JOIN PRCompanyIndicators WITH (NOLOCK) ON prci2_CompanyID = peli_CompanyID
		 WHERE peli_PersonID = @PersonID
           AND peli_CompanyID = @CompanyID
           AND peli_PRStatus In ('1', '2')
           AND peli_PRAUSChangePreference = '2'
		   AND prwucl_TypeCode = 'AUS' 
		   AND prwu_Disabled IS NULL
		   AND prwu_ServiceCode IS NOT NULL
		   AND prss_OpenedDate BETWEEN @StartDate AND @EndDate
		   AND prss_Publish = 'Y'
		   AND prci2_Suspended IS NULL
		UNION
		SELECT DISTINCT prcc_CompanyID As MonitoredCompanyID
   	      FROM PRWebUserListDetail WITH (NOLOCK)
		       INNER JOIN PRWebUserList WITH (NOLOCK) on prwuld_WebUserListID = prwucl_WebUserListID
			   INNER JOIN PRWebUser WITH (NOLOCK) on prwucl_WebUserID = prwu_WebUserID
		       INNER JOIN Person_Link WITH (NOLOCK) on prwu_PersonLinkID = peli_PersonLinkID
			   INNER JOIN PRCourtCases WITH (NOLOCK) on prwuld_AssociatedID = prcc_CompanyID
			   LEFT OUTER JOIN PRCompanyIndicators WITH (NOLOCK) ON prci2_CompanyID = peli_CompanyID
		 WHERE peli_PersonID = @PersonID
           AND peli_CompanyID = @CompanyID
           AND peli_PRStatus In ('1', '2')
           AND peli_PRAUSChangePreference = '2'
		   AND prwucl_TypeCode = 'AUS' 
		   AND prwu_Disabled IS NULL
		   AND prwu_ServiceCode IS NOT NULL
		   AND prcc_CreatedDate BETWEEN @StartDate AND @EndDate
		   AND prcc_FiledDate > DATEADD(day, -45, GETDATE())
		   AND prci2_Suspended IS NULL
		UNION
		SELECT DISTINCT prbs_CompanyID As MonitoredCompanyID
   	      FROM PRWebUserListDetail WITH (NOLOCK)
		       INNER JOIN PRWebUserList WITH (NOLOCK) on prwuld_WebUserListID = prwucl_WebUserListID
			   INNER JOIN PRWebUser WITH (NOLOCK) on prwucl_WebUserID = prwu_WebUserID
		       INNER JOIN Person_Link WITH (NOLOCK) on prwu_PersonLinkID = peli_PersonLinkID
			   INNER JOIN vPRBBScoreChange ON prwuld_AssociatedID = prbs_CompanyID
			   LEFT OUTER JOIN PRCompanyIndicators WITH (NOLOCK) ON prci2_CompanyID = peli_CompanyID
		 WHERE peli_PersonID = @PersonID
           AND peli_CompanyID = @CompanyID
           AND peli_PRStatus In ('1', '2')
           AND peli_PRAUSChangePreference = '2'
		   AND prwucl_TypeCode = 'AUS' 
		   AND prwu_Disabled IS NULL
		   AND prwu_ServiceCode IS NOT NULL
		   AND CAST(prwu_AccessLevel as int) >= 300
		   AND prbs_CreatedDate BETWEEN @StartDate AND @EndDate
		   AND PreviousScore IS NULL
		   AND prci2_Suspended IS NULL
		UNION
		  SELECT DISTINCT prbs_CompanyID As MonitoredCompanyID
   	      FROM PRWebUserListDetail WITH (NOLOCK)
		       INNER JOIN PRWebUserList WITH (NOLOCK) on prwuld_WebUserListID = prwucl_WebUserListID
			   INNER JOIN PRWebUser WITH (NOLOCK) on prwucl_WebUserID = prwu_WebUserID
		       INNER JOIN Person_Link WITH (NOLOCK) on prwu_PersonLinkID = peli_PersonLinkID
			   INNER JOIN vPRBBScoreChange ON prwuld_AssociatedID = prbs_CompanyID
			   LEFT OUTER JOIN PRCompanyIndicators WITH (NOLOCK) ON prci2_CompanyID = peli_CompanyID
		 WHERE peli_PersonID = @PersonID
           AND peli_CompanyID = @CompanyID
           AND peli_PRStatus In ('1', '2')
           AND peli_PRAUSChangePreference = '2'
		   AND prwucl_TypeCode = 'AUS' 
		   AND prwu_Disabled IS NULL
		   AND prwu_ServiceCode IS NOT NULL
		   AND CAST(prwu_AccessLevel as int) >= 300
		   AND prbs_CreatedDate BETWEEN @StartDate AND @EndDate
		   AND PreviousScore IS NOT NULL
		   AND ABS(prbs_BBScore - PreviousScore) >= 25
		   AND prci2_Suspended IS NULL
		) T1
		INNER JOIN Company WITH (NOLOCK) ON MonitoredCompanyID = comp_CompanyID
		INNER JOIN vPRLocation on comp_PRListingCityID = prci_CityID
	ORDER BY MonitoredCompanyID;
END
GO

/******************************************************************************
 *   Procedure: usp_Alerts_GetRatingNumerals
 *
 *
 *   Decription:  Originally dsRatingNumerals in the Alerts report.
 *                Pulled here for reuse.
 *
 *****************************************************************************/
if exists (select * from dbo.sysobjects 
			where id = object_id(N'[dbo].[usp_Alerts_GetRatingNumerals]') 
				and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].usp_Alerts_GetRatingNumerals
GO

CREATE PROCEDURE dbo.usp_Alerts_GetRatingNumerals
	@PersonID int,
	@CompanyID int,
	@StartDate datetime,
	@EndDate datetime,
	@MonitoredCompanyID int= null,
	@AccessLevelThreshold int=0
AS
BEGIN
	DECLARE @ChangePreference varchar(40)

	SELECT @ChangePreference = ISNULL(peli_PRAUSChangePreference,1)
	FROM Person_Link WITH (NOLOCK)
	WHERE peli_PersonID = @PersonID
		AND peli_CompanyID = @CompanyID
		AND peli_PRStatus In ('1', '2');

	DECLARE @CreditSheetIDs table (
		prcs_CreditSheetId int
	)

	INSERT INTO @CreditSheetIDs
	SELECT DISTINCT prcs_CreditSheetId
	  FROM (SELECT DISTINCT prcs_CreditSheetId
			FROM PRWebUserListDetail WITH (NOLOCK)
			INNER JOIN PRCreditSheet WITH (NOLOCK) on prwuld_AssociatedID = prcs_CompanyID
			INNER JOIN PRWebUserList WITH (NOLOCK) on prwuld_WebUserListID = prwucl_WebUserListID
			INNER JOIN PRWebUser WITH (NOLOCK) on prwucl_WebUserID = prwu_WebUserID
			INNER JOIN Person_Link WITH (NOLOCK) on prwu_PersonLinkID = peli_PersonLinkID
			 WHERE prcs_PublishableDate BETWEEN @StartDate AND @EndDate
			   AND ISNULL(prcs_KeyFlag, 'N') = CASE WHEN @ChangePreference ='1' THEN 'Y' ELSE ISNULL(prcs_KeyFlag, 'N')  END
			   AND prcs_Status = 'P' -- Publishable
			   AND peli_PersonID = @PersonID
			   AND peli_CompanyID = @CompanyID
			   AND peli_PRStatus In ('1', '2')
			   AND prwu_AccessLevel >= @AccessLevelThreshold
			   AND prwucl_TypeCode = 'AUS' 
			   AND prwuld_AssociatedType = 'C'
			   AND prwuld_AssociatedID = CASE WHEN @MonitoredCompanyID IS  NULL THEN prwuld_AssociatedID ELSE @MonitoredCompanyID END
			 UNION
			SELECT DISTINCT prcs_CreditSheetId
			FROM PRWebUserList WITH (NOLOCK)
					   INNER JOIN PRWebUser WITH (NOLOCK) on prwucl_WebUserID = prwu_WebUserID    
					   INNER JOIN Person_Link WITH (NOLOCK) on prwu_PersonLinkID = peli_PersonLinkID 
					   INNER JOIN PRBusinessReportRequest WITH (NOLOCK) ON peli_PersonID = prbr_RequestingPersonID and prwucl_CompanyID = prbr_RequestingCompanyID 
					   INNER JOIN PRCreditSheet WITH (NOLOCK) on prbr_RequestedCompanyID = prcs_CompanyID			   
			 WHERE prcs_PublishableDate BETWEEN @StartDate AND @EndDate
			   AND prcs_Status = 'P' -- Publishable
			   AND ISNULL(prcs_KeyFlag, 'N') = CASE WHEN @ChangePreference ='1' THEN 'Y' ELSE ISNULL(prcs_KeyFlag, 'N')  END
			   AND prbr_CreatedDate > DATEADD(month, -6, GETDATE())
			   AND peli_PersonID = @PersonID
			   AND peli_CompanyID = @CompanyID
			   AND peli_PRStatus In ('1', '2')
			   AND prwucl_TypeCode = 'AUS'
			   AND prbr_RequestedCompanyID = CASE WHEN @MonitoredCompanyID IS  NULL THEN prbr_RequestedCompanyID ELSE @MonitoredCompanyID END
	) T1;

	DECLARE @tblWork table (
		NumeralString varchar(500)
	)

	INSERT INTO @tblWork
	SELECT REPLACE(dbo.ufn_ExtractRatingNumerals(prcs_Numeral) +
				   dbo.ufn_ExtractRatingNumerals(prcs_Change) +
				   dbo.ufn_ExtractRatingNumerals(prcs_RatingValue) +
				   dbo.ufn_ExtractRatingNumerals(prcs_PreviousRatingValue), ',,', ',') as RatingNumerals
	 FROM PRCreditSheet
	WHERE prcs_CreditSheetId IN (SELECT prcs_CreditSheetId FROM @CreditSheetIDs);

	DECLARE @tblWork2 table (
		Numeral varchar(5),
		NumeralInt int
	)

	INSERT INTO @tblWork2
	SELECT value, REPLACE(REPLACE(value, '(', ''), ')', '')
	  FROM @tblWork
		   CROSS APPLY dbo.Tokenize(NumeralString, ',')
		WHERE value <> ''
		  AND value IS NOT NULL
		  AND LEN(value) <= 5;

	SELECT Numeral, Description
	 FROM (
	SELECT DISTINCT Numeral, NumeralInt, CAST(ISNULL(rn.capt_us, ISNULL(cn.capt_us, ISNULL(pn.capt_us, csn.capt_us))) as varchar(1000)) as Description
	 FROM @tblWork2
		  LEFT OUTER JOIN Custom_Captions rn ON Numeral = rn.capt_code AND rn.capt_family = 'prrn_Name'
		  LEFT OUTER JOIN Custom_Captions cn ON Numeral = cn.capt_code AND cn.capt_family = 'prcw_Name'
		  LEFT OUTER JOIN Custom_Captions pn ON Numeral = pn.capt_code AND pn.capt_family = 'prpy_Name'
		  LEFT OUTER JOIN Custom_Captions csn ON Numeral = csn.capt_code AND csn.capt_family = 'CreditSheetNumerals'
	) T1
	WHERE Description IS NOT NULL
	ORDER BY NumeralInt
END
GO

/******************************************************************************
 *   Procedure: usp_Alerts_GetCreditItems
 *
 *
 *   Decription:  Originally dsCreditItem in the AUSCreditsheetSubReport.
 *                Pulled here for reuse.
 *
 *****************************************************************************/
if exists (select * from dbo.sysobjects 
			where id = object_id(N'[dbo].[usp_Alerts_GetCreditItems]') 
				and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].usp_Alerts_GetCreditItems
GO

CREATE PROCEDURE dbo.usp_Alerts_GetCreditItems
	@CompanyID int,
	@StartDate datetime,
	@EndDate datetime,
	@ChangePreference varchar(50)='2'
AS
BEGIN
	SELECT prcs_CreditSheetID, dbo.ufn_GetItem(prcs_CreditSheetID, 2, 0, 60) as ItemText
	FROM PRCreditSheet WITH (NOLOCK)
	WHERE prcs_CompanyID = @CompanyID
		AND prcs_PublishableDate BETWEEN @StartDate AND @EndDate
		AND prcs_Status = 'P' -- Publishable
		AND prcs_NewListing IS NULL
		AND ISNULL(prcs_KeyFlag, 'N') = CASE WHEN @ChangePreference ='1' THEN 'Y' ELSE ISNULL(prcs_KeyFlag, 'N')  END;
END
GO

/******************************************************************************
 *   Procedure: usp_Alerts_GetNews
 *
 *
 *   Decription:  Originally dsNews in the AUSNewsArticleSubReport.
 *                Pulled here for reuse.
 *
 *****************************************************************************/
if exists (select * from dbo.sysobjects 
			where id = object_id(N'[dbo].[usp_Alerts_GetNews]') 
				and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].usp_Alerts_GetNews
GO

CREATE PROCEDURE dbo.usp_Alerts_GetNews
	@CompanyID int,
	@StartDate datetime,
	@EndDate datetime
AS
BEGIN
	SELECT 
		CAST(ID as int) AS prpbar_PublicationArticleID, 
		post_title as prpbar_Name,
		dbo.ufn_ConcatURL(dbo.ufn_GetCustomCaptionValue('ProduceWebSite', 'URL', 'en-us'), '?p=') As URL,
		post_date
	FROM WordPressProduce.dbo.wp_posts WITH (NOLOCK)
		LEFT OUTER JOIN WordPressProduce.dbo.wp_PostMeta WITH (NOLOCK) ON wp_Posts.ID = wp_postmeta.post_id AND meta_key = 'associated-companies'
		LEFT OUTER JOIN (SELECT post_ID FROM WordPressProduce.dbo.wp_PostMeta WHERE meta_key='blueprintEdition') bpe ON bpe.post_ID = wp_Posts.ID
	WHERE post_type = 'post'
		AND post_status in('publish')
		AND (bpe.post_ID IS NULL OR dbo.ufn_GetWordPressBluePrintsEdition(ID) = '')
		AND wp_PostMeta.meta_value LIKE '%' + CAST(@CompanyID AS varchar(20)) + '%'
		AND wp_posts.post_date BETWEEN @StartDate AND @EndDate
END
GO

/******************************************************************************
 *   Procedure: usp_Alerts_GetCourtCases
 *
 *
 *   Decription:  Originally dsResults in the AUSCourtCaseSubReport.
 *                Pulled here for reuse.
 *
 *****************************************************************************/
if exists (select * from dbo.sysobjects 
			where id = object_id(N'[dbo].[usp_Alerts_GetCourtCases]') 
				and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].usp_Alerts_GetCourtCases
GO

CREATE PROCEDURE dbo.usp_Alerts_GetCourtCases
	@CompanyID int,
	@StartDate datetime,
	@EndDate datetime
AS
BEGIN
	SELECT prcc_CompanyID,
		prcc_FiledDate,
		prcc_CaseNumber,
		dbo.ufn_ConcatURL(dbo.ufn_GetCustomCaptionValue('BBOS', 'URL', 'en-us'), 'CompanyClaimsActivity.aspx?CompanyID=') As URL
	FROM PRCourtCases WITH (NOLOCK)
	WHERE prcc_CompanyID = @CompanyID
		AND prcc_CreatedDate BETWEEN @StartDate AND @EndDate
		AND prcc_FiledDate > DATEADD(day, -45, GETDATE())
END
GO

/******************************************************************************
 *   Procedure: usp_Alerts_GetClaims
 *
 *
 *   Decription:  Originally dsResults in the AUSBBSiClaimSubReport.
 *                Pulled here for reuse.
 *
 *****************************************************************************/
if exists (select * from dbo.sysobjects 
			where id = object_id(N'[dbo].[usp_Alerts_GetClaims]') 
				and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].usp_Alerts_GetClaims
GO

CREATE PROCEDURE dbo.usp_Alerts_GetClaims
	@CompanyID int,
	@StartDate datetime,
	@EndDate datetime
AS
BEGIN
	SELECT	prss_RespondentCompanyId,
			prss_OpenedDate,
			prss_SSFileID,
			dbo.ufn_ConcatURL(dbo.ufn_GetCustomCaptionValue('BBOS', 'URL', 'en-us'), 'CompanyClaimsActivity.aspx?CompanyID=') As URL
	FROM PRSSFile WITH (NOLOCK)
	WHERE prss_RespondentCompanyId = @CompanyID
		AND prss_OpenedDate BETWEEN @StartDate AND @EndDate
END
GO

/******************************************************************************
 *   Procedure: usp_Alerts_GetNewPublishableScore
 *
 *
 *   Decription:  Originally dsNewPublishableScore in the AUSBBScoreSubReport
 *                Pulled here for reuse.
 *
 *****************************************************************************/
if exists (select * from dbo.sysobjects 
			where id = object_id(N'[dbo].[usp_Alerts_GetNewPublishableScore]') 
				and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].usp_Alerts_GetNewPublishableScore
GO

CREATE PROCEDURE dbo.usp_Alerts_GetNewPublishableScore
	@CompanyID int,
	@StartDate datetime,
	@EndDate datetime
AS
BEGIN
	SELECT  *
	FROM vPRBBScoreChange
    WHERE prbs_CompanyID = @CompanyID
		AND prbs_CreatedDate BETWEEN @StartDate AND @EndDate
		AND PreviousScore IS NULL
		OPTION (maxdop 1)
END
GO

/******************************************************************************
 *   Procedure: usp_Alerts_GetScoreChange
 *
 *
 *   Decription:  Originally dsScoreChange in the AUSBBScoreSubReport
 *                Pulled here for reuse.
 *
 *****************************************************************************/
if exists (select * from dbo.sysobjects 
			where id = object_id(N'[dbo].[usp_Alerts_GetScoreChange]') 
				and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].usp_Alerts_GetScoreChange
GO

CREATE PROCEDURE dbo.usp_Alerts_GetScoreChange
	@CompanyID int,
	@StartDate datetime,
	@EndDate datetime
AS
BEGIN
	SELECT *
	FROM vPRBBScoreChange
	WHERE prbs_CompanyID = @CompanyID
		AND prbs_CreatedDate BETWEEN @StartDate AND @EndDate
		AND PreviousScore IS NOT NULL
		AND ABS(prbs_BBScore - PreviousScore) >= 25
	OPTION (maxdop 1)
END
GO


/******************************************************************************
 *   Procedure: usp_GetCompanyContactDataExportCSV
 *
 *
 *   Decription:  For defect 5696.  Generate CSV for export instead of calling SSRS with dynamic columns.
 *
 *****************************************************************************/
IF EXISTS (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_GetCompanyContactDataExportCSV]') 
            and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].usp_GetCompanyContactDataExportCSV
GO

CREATE Procedure [dbo].usp_GetCompanyContactDataExportCSV
(
	@CompanyIDs varchar(max),
	@UserCompanyID int,
	@WebUserID int
)
AS  
BEGIN 

-- Build a list of our custom field column names
DECLARE @DynamicColumns AS VARCHAR(max)
SELECT @DynamicColumns = COALESCE(@DynamicColumns + ', ', '') + Quotename(prwucf_Label)
  FROM (SELECT DISTINCT prwucf_Label
          FROM PRWebUserCustomField WITH (NOLOCK)
         WHERE prwucf_CompanyID = @UserCompanyID
           AND prwucf_Hide IS NULL
      ) AS FieldList
ORDER BY prwucf_Label


--Build the Dynamic Pivot Table Query  
DECLARE @Query AS NVARCHAR(max)
SET @Query = 
'DECLARE @CompanyIDs varchar(MAX) = ''' + @CompanyIDs + '''
DECLARE @UserCompanyID int = ' + CAST(@UserCompanyID as varchar(10)) + '
DECLARE @WebUserID int = ' + CAST(@WebUserID as varchar(10)) + '
SELECT *
	, dbo.ufn_GetWatchdogGroupsForList(@WebUserID, BBID) WatchDogGroups
  FROM vPRGetCompanyContactDataExportCSV
       LEFT OUTER JOIN (SELECT *
                                          FROM ( 
                                                     SELECT prwucd_AssociatedID,
                                                               prwucf_Label, 
                                                               prwucd_Value
                                                       FROM PRWebUserCustomField WITH (NOLOCK)
                                                               INNER JOIN PRWebUserCustomData WITH (NOLOCK) ON prwucf_WebUserCustomFieldID = prwucd_WebUserCustomFieldID
                                                     WHERE prwucf_CompanyID = @UserCompanyID
                                                        AND prwucf_Hide IS NULL
                                                        AND prwucd_Value IS NOT NULL
                                                        ) t'

IF(@DynamicColumns IS NOT NULL) BEGIN
	SET @Query = @Query + '                            PIVOT (MAX(prwucd_Value) for prwucf_Label in (' + @DynamicColumns + ')) p'
END

SET @Query = @Query + 
'                                        ) UDF ON [BBID] = prwucd_AssociatedID
WHERE BBID IN (SELECT CAST(value AS INT) FROM dbo.Tokenize(@CompanyIDs, '',''))'
EXECUTE (@Query)

END
GO

/******************************************************************************
 *   Procedure: usp_GetCompanyDataExportReportCSV
 *
 *
 *   Decription:  For defect 5696.  Generate CSV for export instead of calling SSRS with dynamic columns.
 *
 *****************************************************************************/
IF EXISTS (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_GetCompanyDataExportReportCSV]') 
            and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].usp_GetCompanyDataExportReportCSV
GO

CREATE Procedure [dbo].usp_GetCompanyDataExportReportCSV
(
	@CompanyIDs varchar(max),
	@UserCompanyID int,
	@WebUserID int,
	@Culture varchar(50)
)
AS  
BEGIN 

-- Build a list of our custom field column names
DECLARE @DynamicColumns AS VARCHAR(max)
SELECT @DynamicColumns = COALESCE(@DynamicColumns + ', ', '') + Quotename(prwucf_Label)
  FROM (SELECT DISTINCT prwucf_Label
          FROM PRWebUserCustomField WITH (NOLOCK)
         WHERE prwucf_CompanyID = @UserCompanyID
           AND prwucf_Hide IS NULL
      ) AS FieldList
ORDER BY prwucf_Label


--Build the Dynamic Pivot Table Query  
DECLARE @Query AS NVARCHAR(max)
SET @Query = 
'DECLARE @CompanyIDs varchar(MAX) = ''' + @CompanyIDs + '''
DECLARE @UserCompanyID int = ' + CAST(@UserCompanyID as varchar(10)) + '
DECLARE @WebUserID int = ' + CAST(@WebUserID as varchar(10)) + '
DECLARE @Culture varchar(50) = ''' + @Culture + '''

SELECT *,
    dbo.ufn_GetCustomCaptionValue(''prcp_Volume'', prcp_Volume, @Culture) AS [AnnualVolumeFigure],
    dbo.ufn_GetCustomCaptionValue(''comp_PRIndustryType'', comp_PRIndustryType, @Culture) AS [Industry],
	dbo.ufn_GetCustomCaptionValue(''comp_PRType'', comp_PRType, @Culture) AS [Type],
	dbo.ufn_GetCustomCaptionValue(''prc2_StoreCount'', prc2_NumberOfStores, @Culture) AS [NumberOfStores],
	dbo.ufn_GetWatchdogGroupsForList(@WebUserID, BBID) WatchDogGroups
  FROM vPRGetCompanyDataExportReportCSV
       LEFT OUTER JOIN (SELECT *
                                          FROM ( 
                                                     SELECT prwucd_AssociatedID,
                                                               prwucf_Label, 
                                                               prwucd_Value
                                                       FROM PRWebUserCustomField WITH (NOLOCK)
                                                               INNER JOIN PRWebUserCustomData WITH (NOLOCK) ON prwucf_WebUserCustomFieldID = prwucd_WebUserCustomFieldID
                                                     WHERE prwucf_CompanyID = @UserCompanyID
                                                        AND prwucf_Hide IS NULL
                                                        AND prwucd_Value IS NOT NULL
                                                        ) t'
IF(@DynamicColumns IS NOT NULL) BEGIN
	SET @Query = @Query + '                                PIVOT (MAX(prwucd_Value) for prwucf_Label in (' + @DynamicColumns + ') ) p'
END

SET @Query = @Query + '                       ) UDF ON [BBID] = prwucd_AssociatedID
WHERE BBID IN (SELECT CAST(value AS INT) FROM dbo.Tokenize(@CompanyIDs, '',''))'
EXECUTE (@Query)

END
GO

/******************************************************************************
 *   Procedure: usp_GetCompanyDataExportReportLumberCSV
 *
 *
 *   Decription:  For defect 5696.  Generate CSV for export instead of calling SSRS with dynamic columns.
 *
 *****************************************************************************/
IF EXISTS (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_GetCompanyDataExportReportLumberCSV]') 
            and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].usp_GetCompanyDataExportReportLumberCSV
GO

CREATE Procedure [dbo].usp_GetCompanyDataExportReportLumberCSV
(
	@CompanyIDs varchar(max),
	@UserCompanyID int,
	@WebUserID int,
	@Culture varchar(50)
)
AS  
BEGIN 

-- Build a list of our custom field column names
DECLARE @DynamicColumns AS VARCHAR(max)
SELECT @DynamicColumns = COALESCE(@DynamicColumns + ', ', '') + Quotename(prwucf_Label)
  FROM (SELECT DISTINCT prwucf_Label
          FROM PRWebUserCustomField WITH (NOLOCK)
         WHERE prwucf_CompanyID = @UserCompanyID
           AND prwucf_Hide IS NULL
      ) AS FieldList
ORDER BY prwucf_Label


--Build the Dynamic Pivot Table Query  
DECLARE @Query AS NVARCHAR(max)
SET @Query = 
'DECLARE @CompanyIDs varchar(MAX) = ''' + @CompanyIDs + '''
DECLARE @UserCompanyID int = ' + CAST(@UserCompanyID as varchar(10)) + '
DECLARE @WebUserID int = ' + CAST(@WebUserID as varchar(10)) + '
DECLARE @Culture varchar(50) = ''' + @Culture  + '''
SELECT *,
	dbo.ufn_GetCustomCaptionValue(''comp_PRIndustryType'', comp_PRIndustryType, @Culture) AS [Industry],
	dbo.ufn_GetCustomCaptionValue(''comp_PRType'', comp_PRType, @Culture) AS [Type],
	dbo.ufn_GetWatchdogGroupsForList(@WebUserID, BBID) WatchDogGroups
  FROM vPRGetCompanyDataExportReportLumberCSV
       LEFT OUTER JOIN (SELECT *
                                          FROM ( 
                                                     SELECT prwucd_AssociatedID,
                                                               prwucf_Label, 
                                                               prwucd_Value
                                                       FROM PRWebUserCustomField WITH (NOLOCK)
                                                               INNER JOIN PRWebUserCustomData WITH (NOLOCK) ON prwucf_WebUserCustomFieldID = prwucd_WebUserCustomFieldID
                                                     WHERE prwucf_CompanyID = @UserCompanyID
                                                        AND prwucf_Hide IS NULL
                                                        AND prwucd_Value IS NOT NULL
                                                        ) t'
IF(@DynamicColumns IS NOT NULL) BEGIN
	SET @Query = @Query +
	'                                                    PIVOT (MAX(prwucd_Value) for prwucf_Label in (' + @DynamicColumns + ') ) p'
END

SET @Query = @Query +
'                                        ) UDF ON [BBID] = prwucd_AssociatedID
WHERE BBID IN (SELECT CAST(value AS INT) FROM dbo.Tokenize(@CompanyIDs, '',''))'
EXECUTE (@Query)

END
GO

/******************************************************************************
 *   Procedure: [usp_ARAgingAdjustToCurrent]
 *
 *
 *   Decription:  For defect 7023 to reset an ARAgingDetail record to current
 *
 *****************************************************************************/
if exists (select * from dbo.sysobjects 
			where id = object_id(N'[dbo].[usp_ARAgingAdjustToCurrent]') 
				and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].usp_ARAgingAdjustToCurrent
GO

CREATE PROCEDURE [dbo].[usp_ARAgingAdjustToCurrent]
    @ARAgingDetailId int
As
BEGIN
	DECLARE @ARAgingId int
	DECLARE @CompanyId int
	DECLARE @Industry varchar(5)

	SELECT @ARAgingId = praad_ARAgingId FROM PRARAgingDetail WHERE praad_ARAgingDetailId = @ARAgingDetailId
	SELECT @CompanyId = praa_CompanyId FROM PRARAging WHERE praa_ARAgingId = @ARAgingId
	SELECT @Industry = comp_PRIndustryType FROM Company WHERE comp_CompanyId = @CompanyId

	IF @Industry = 'L' BEGIN
		--LUMBER
		DECLARE @Amount1to30 numeric(24,6)
		DECLARE @Amount31to60 numeric(24,6)
		DECLARE @Amount61to90 numeric(24,6)
		DECLARE @Amount91Plus numeric(24,6)
		SELECT	@Amount1to30 = ISNULL(praad_Amount1to30,0),
				@Amount31to60 = ISNULL(praad_Amount31to60,0),
				@Amount61to90 = ISNULL(praad_Amount61to90,0),
				@Amount91Plus = ISNULL(praad_Amount91Plus,0)
		FROM PRARAgingDetail WHERE praad_ARAgingDetailId = @ARAgingDetailId

		UPDATE PRARAgingDetail SET praad_AmountCurrent = ISNULL(praad_AmountCurrent,0) + @Amount1to30 + @Amount31to60 + @Amount61to90 + @Amount91Plus,
			praad_Amount1to30=0, 
			praad_Amount31to60=0, 
			praad_Amount61to90=0, 
			praad_Amount91Plus=0
		WHERE praad_ARAgingDetailId = @ARAgingDetailId

		UPDATE PRARAging SET praa_TotalCurrent = ISNULL(praa_TotalCurrent,0) + @Amount1to30 + @Amount31to60 + @Amount61to90 + @Amount91Plus,
			praa_Total1to30 = ISNULL(praa_Total1to30,0) - @Amount1to30,
			praa_Total31to60 = ISNULL(praa_Total31to60,0) - @Amount31to60,
			praa_Total61to90 = ISNULL(praa_Total61to90,0) - @Amount61to90,
			praa_Total91Plus = ISNULL(praa_Total91Plus,0) - @Amount91Plus
		WHERE praa_ARAgingId=@ARAgingId
	END

	--SELECT @ARAgingId ARAgingId, @CompanyId CompanyId, @Industry Industry
END
GO


CREATE OR ALTER PROCEDURE [dbo].[usp_GetLRLRefenceList]
    @CompanyID int
As
BEGIN

	DECLARE @IndustryType varchar(10)
	DECLARE @TypeList varchar(100)

	SELECT @IndustryType = comp_PRIndustryType FROM Company WHERE comp_CompanyID=@CompanyID

	SET @TypeList = CASE @IndustryType
		WHEN 'P' THEN  '09,10,12,13,15'
		WHEN 'T' THEN '10,11,15'
		WHEN 'L' THEN '10,11,15'
	END

	SELECT DISTINCT prcse_FullName, 
            comp_PRBookTradestyle,
			prcr_LastReportedDate,
			dbo.ufn_GetRelationshipTypeList(prcr_LeftCompanyID, comp_CompanyID) As RelationshipTypeList
	FROM PRCompanyRelationship WITH (NOLOCK) 
			INNER JOIN Company WITH (NOLOCK) ON prcr_RightCompanyID = comp_CompanyID 
			INNER JOIN PRCompanySearch WITH (NOLOCK) ON prcr_RightCompanyId = prcse_CompanyId
	WHERE prcr_LeftCompanyID = @CompanyID
		AND prcr_Active = 'Y' 
		AND prcr_Deleted IS NULL
		AND prcr_Type IN (SELECT value FROM dbo.Tokenize(@TypeList, ','))
   ORDER BY comp_PRBookTradestyle
END
Go

CREATE OR ALTER PROCEDURE usp_GetDSIRCalendarTotals
	@StartDate datetime,
    @EndDate datetime
As
BEGIN 

	SET @EndDate = DATEADD(minute, 1439, @EndDate)
	DECLARE @tblProductLine table (
		ProductLine varchar(10)
	)
	INSERT INTO @tblProductLine SELECT DISTINCT ProductLine FROM MAS_PRC.dbo.CI_Item WHERE ProductLine NOT IN ('ADP', 'ADE')
	DECLARE @tblSS TABLE
	(
		[inx] int identity,
		[BBID] int,
		[Company Name] varchar(MAX),
		[Service] varchar(MAX),
		[ItemCode] varchar(MAX),
		[Action] varchar(MAX),
		[ActionCancel] varchar(MAX),
		[prsoat_ActionCode] varchar(MAX),
		[Order] varchar(MAX),
		[Order Date] datetime,
		[Std Order] varchar(MAX),
		[UpDown] varchar(MAX),
		[comp_PRIndustryType] varchar(50),
		[IsMembershipCode] bit
	)
	INSERT INTO @tblSS 
	SELECT DISTINCT
		'BBID' = comp_CompanyID
		, 'Company Name' = comp_name
		, 'Service' = ItemCodeDesc
		, ItemCode
		, 'Action' = CASE prsoat_ActionCode
			WHEN 'C' THEN prsoat_CancelReasonCode
			WHEN 'I' THEN 'New'
			WHEN 'U' THEN 'Change'
			ELSE prsoat_ActionCode
			END
		, 'ActionCancel' = prsoat_CancelReasonCode + ' ' + cc2.Capt_US		
		, ISNULL(prsoat_ActionCode,'') prsoat_ActionCode
		, 'Order' = prsoat_SalesOrderNo
		, 'Order Date' = prsoat_CreatedDate
		, 'Std Order' = CASE WHEN Std.SalesOrderNo IS NOT NULL THEN 'Y' ELSE '' END 
		, ISNULL(prsoat_Up_Down, '') UpDown
		, comp_PRIndustryType
		, CASE WHEN cc3.Capt_Code IS NOT NULL THEN 1 ELSE 0 END
	FROM CRM.dbo.PRSalesOrderAuditTrail rpt WITH (NOLOCK) 
		INNER JOIN CRM.dbo.Company WITH (NOLOCK) ON prsoat_SoldToCompany = comp_CompanyID 
		INNER JOIN MAS_PRC.dbo.CI_Item WITH (NOLOCK) ON prsoat_ItemCode = ItemCode 
		INNER JOIN Custom_Captions cc1 ON Capt_Family='comp_PRIndustryType' AND Capt_Code=comp_PRIndustryType
		LEFT OUTER JOIN Custom_Captions cc2 ON cc2.Capt_Family='MembershipCancelCode' AND cc2.Capt_Code=prsoat_CancelReasonCode
		LEFT OUTER JOIN Custom_Captions cc3 ON cc3.Capt_Family='prse_ServiceCode' AND cc3.Capt_Code=prsoat_ItemCode
		LEFT OUTER JOIN MAS_PRC.dbo.SO_SalesOrderHistoryHeader std WITH (NOLOCK) ON std.MasterRepeatingOrderNo = rpt.prsoat_SalesOrderNo AND std.DateCreated BETWEEN @StartDate AND @EndDate
	WHERE prsoat_CreatedDate BETWEEN @StartDate AND @EndDate 
	  AND CI_Item.ItemCode != 'DL'
	  AND prsoat_Pipeline NOT IN ('TRANSFER')
	  AND ProductLine IN (SELECT ProductLine FROM @tblProductLine)
	  AND (prsoat_CreatedDate NOT BETWEEN '2024-03-01' AND '2024-03-31 11:59 PM'
		    OR prsoat_ItemCode NOT IN (SELECT ItemCode FROM MAS_PRC.dbo.CI_Item WHERE Category2='PRIMARY'))
	UNION
	SELECT
		BBID = hdr.CustomerNo
		, 'Company Name' = hdr.BillToName
		,'Service' = det.ItemCodeDesc
		, det.ItemCode
		,'Action' = 'Charge'
		, NULL
		, NULL
		,'Order' = ''
		,'Order Date' = hdr.DateCreated
		,'Std Order' = ''
		,NULL AS UpDown
		,comp_PRIndustryType
		,CASE WHEN cc3.Capt_Code IS NOT NULL THEN 1 ELSE 0 END
	FROM MAS_PRC.dbo.SO_SalesOrderHistoryHeader hdr 
		INNER JOIN CRM.dbo.Company WITH (NOLOCK) ON hdr.CustomerNo = comp_CompanyID 
		INNER JOIN MAS_PRC.dbo.SO_SalesOrderHistoryDetail AS det ON hdr.SalesOrderNo = det.SalesOrderNo 
		INNER JOIN MAS_PRC.dbo.CI_Item AS Item ON item.ItemCode = det.ItemCode 
		LEFT OUTER JOIN Custom_Captions cc3 ON cc3.Capt_Family='prse_ServiceCode' AND cc3.Capt_Code=det.ItemCode
	WHERE        
		hdr.OrderStatus IN ('A', 'C') 
		AND (det.SalesAcctKey <> '') 
		AND (hdr.SalesOrderNo NOT IN
			(SELECT SalesOrderNo
			   FROM MAS_PRC.dbo.SO_SalesOrderHeader WITH (NOLOCK)
			  WHERE OrderType = 'R'
			    AND CycleCode <> '99'))
		AND (hdr.DateCreated BETWEEN @StartDate AND @EndDate)
		AND hdr.MasterRepeatingOrderNo = '' 
		AND ProductLine IN (SELECT ProductLine FROM @tblProductLine)
	Order BY [Company Name], [Order DATE], UpDown DESC


	INSERT INTO @tblSS
    SELECT prmr_CompanyID, comp_name, ItemCodeDesc, prmr_ItemCode, 'New', NULL, 'I', NULL, prmr_InvoiceDate, '', 'NEW', comp_PRIndustryType, 1
		 FROM PRMembershipReportTable
		    INNER JOIN CRM.dbo.Company WITH (NOLOCK) ON prmr_CompanyID = comp_CompanyID 
			INNER JOIN MAS_PRC.dbo.CI_Item WITH (NOLOCK) ON prmr_ItemCode = ItemCode 
		WHERE prmr_InvoiceDate BETWEEN @StartDate AND @EndDate 

	--SELECT * FROM @tblSS
	DECLARE @tblSS2 TABLE
	(
		inx int,
		[Prev Matches] bit,
		[Prev BBID] int,
		[Prev Service] varchar(MAX),
		[Prev Order Date] datetime,
		[Prev Order Date Seconds] int,
		[Next Matches] bit,
		[Next ActionCode] varchar(MAX),
		[IsSale] bit,
		[IsCancel] bit,
		[IsUpgrade] bit,
		[IsDowngrade] bit
	)
	INSERT INTO @tblSS2
	SELECT inx, 
		[Prev Matches]=CASE WHEN
				Lag([BBID], 1) OVER(ORDER BY inx)=[BBID]
				AND DATEDIFF(SECOND, [Order Date], Lag([Order Date], 1) OVER(order by inx)) BETWEEN -180 AND -1
			THEN 1 ELSE 0 END,
		[Prev BBID] = Lag([BBID], 1) OVER(ORDER BY inx),
		[Prev Service] = Lag([Service], 1) OVER(ORDER BY inx),
		[Prev Order Date] = Lag([Order Date], 1) OVER(order by inx),
		[Prev Order Date Seconds] = DATEDIFF(SECOND, [Order Date], Lag([Order Date], 1) OVER(order by inx)),
		[Next Matches] = CASE WHEN
				Lead([BBID], 1) OVER(ORDER BY inx)=[BBID]
				AND DATEDIFF(SECOND, [Order Date], Lead([Order Date], 1) OVER(order by inx)) < 180
		THEN 1 ELSE 0 END,
		[Next ActionCode] = Lead([prsoat_ActionCode], 1) OVER(ORDER BY inx),
		NULL, NULL, NULL, NULL
	FROM @tblSS
	ORDER BY inx
	--IsSale
	UPDATE T2
	   SET IsSale = 1 
	  FROM @tblSS T1
		   INNER JOIN @tblSS2 T2 ON T1.inx = T2.inx
	 WHERE prsoat_ActionCode='I' 
	   AND [Prev Matches]=0 
	   AND IsMembershipCode=1
	   AND UpDown IN ('New', '', 'OTHER')
	--IsCancel
	UPDATE T2
	   SET IsCancel = 1 
	  FROM @tblSS T1
		   INNER JOIN @tblSS2 T2 ON T1.inx = T2.inx
	 WHERE prsoat_ActionCode='C' 
	   AND IsMembershipCode=1
	   AND Action NOT IN ('C24','C30', 'D40', 'D41', 'D42', 'C11')
	--IsUpgrade
	UPDATE T2
	   SET IsUpgrade = 1 
	  FROM @tblSS T1
		   INNER JOIN @tblSS2 T2 ON T1.inx = T2.inx
	 WHERE IsMembershipCode=1
	   AND Action='C24'
	--IsDowngrade
	UPDATE T2
	   SET IsDowngrade = 1 
	  FROM @tblSS T1
   		   INNER JOIN @tblSS2 T2 ON T1.inx = T2.inx
	 WHERE IsMembershipCode=1
	   AND Action IN ('C30', 'D40', 'D41', 'D42')
	DECLARE @tblMetric table (
		ndx int,
		Metric varchar(100),
		IndustryCode varchar(10),
		MetricCount int
	)
	INSERT INTO @tblMetric
	SELECT ndx, Metric, IndustryCode, MetricCount
	  FROM (
		SELECT 1 ndx, 'New Memberships' Metric,  CASE WHEN comp_PRIndustryType = 'L' THEN 'L' ELSE 'P/T/S' END IndustryCode, COUNT([IsSale]) MetricCount
		FROM @tblSS T1
			INNER JOIN @tblSS2 T2 ON T1.inx = T2.inx
		GROUP BY  CASE WHEN comp_PRIndustryType = 'L' THEN 'L' ELSE 'P/T/S' END
		UNION
		SELECT 2, 'Cancelled Memberships',  CASE WHEN comp_PRIndustryType = 'L' THEN 'L' ELSE 'P/T/S' END, COUNT([IsCancel]) MetricCount
		FROM @tblSS T1
			INNER JOIN @tblSS2 T2 ON T1.inx = T2.inx
		GROUP BY  CASE WHEN comp_PRIndustryType = 'L' THEN 'L' ELSE 'P/T/S' END
		UNION
		SELECT 3, 'Upgraded Memberships',  CASE WHEN comp_PRIndustryType = 'L' THEN 'L' ELSE 'P/T/S' END, COUNT([IsUpgrade]) MetricCount
		FROM @tblSS T1
			INNER JOIN @tblSS2 T2 ON T1.inx = T2.inx
		GROUP BY  CASE WHEN comp_PRIndustryType = 'L' THEN 'L' ELSE 'P/T/S' END
		UNION
		SELECT 4, 'Downgraded Memberships',  CASE WHEN comp_PRIndustryType = 'L' THEN 'L' ELSE 'P/T/S' END, COUNT([IsDowngrade]) MetricCount
		FROM @tblSS T1
			INNER JOIN @tblSS2 T2 ON T1.inx = T2.inx
		GROUP BY  CASE WHEN comp_PRIndustryType = 'L' THEN 'L' ELSE 'P/T/S' END) T1
	ORDER BY ndx, CASE WHEN IndustryCode = 'L' THEN 'L' ELSE 'P/T/S' END DESC
	IF NOT EXISTS (SELECT 'x' FROM @tblMetric WHERE Metric='New Memberships' AND IndustryCode='P/T/S') BEGIN
		INSERT INTO @tblMetric VALUES (1, 'New Memberships', 'P/T/S', 0)
	END
	IF NOT EXISTS (SELECT 'x' FROM @tblMetric WHERE Metric='Cancelled Memberships' AND IndustryCode='P/T/S') BEGIN
		INSERT INTO @tblMetric VALUES (2, 'Cancelled Memberships', 'P/T/S', 0)
	END
	IF NOT EXISTS (SELECT 'x' FROM @tblMetric WHERE Metric='Upgraded Memberships' AND IndustryCode='P/T/S') BEGIN
		INSERT INTO @tblMetric VALUES (3, 'Upgraded Memberships', 'P/T/S', 0)
	END
	IF NOT EXISTS (SELECT 'x' FROM @tblMetric WHERE Metric='Downgraded Memberships' AND IndustryCode='P/T/S') BEGIN
		INSERT INTO @tblMetric VALUES (4, 'Downgraded Memberships', 'P/T/S', 0)
	END
	IF NOT EXISTS (SELECT 'x' FROM @tblMetric WHERE Metric='New Memberships' AND IndustryCode='L') BEGIN
		INSERT INTO @tblMetric VALUES (1, 'New Memberships', 'L', 0)
	END
	IF NOT EXISTS (SELECT 'x' FROM @tblMetric WHERE Metric='Cancelled Memberships' AND IndustryCode='L') BEGIN
		INSERT INTO @tblMetric VALUES (2, 'Cancelled Memberships', 'L', 0)
	END
	IF NOT EXISTS (SELECT 'x' FROM @tblMetric WHERE Metric='Upgraded Memberships' AND IndustryCode='L') BEGIN
		INSERT INTO @tblMetric VALUES (3, 'Upgraded Memberships', 'L', 0)
	END
	IF NOT EXISTS (SELECT 'x' FROM @tblMetric WHERE Metric='Downgraded Memberships' AND IndustryCode='L') BEGIN
		INSERT INTO @tblMetric VALUES (4, 'Downgraded Memberships', 'L', 0)
	END
	SELECT Metric, IndustryCode, MetricCount FROM @tblMetric ORDER BY ndx, CASE WHEN IndustryCode = 'L' THEN 'L' ELSE 'P/T/S' END DESC

END
GO

CREATE OR ALTER PROCEDURE [dbo].[usp_SalesImpactCore](
	@IncludeAds int,
	@StartDate datetime,
	@EndDate datetime,
	@Industry varchar(50),
	@Order varchar(50), --'Calendar' OR 'Subscription',
	@ReportDate datetime=NULL
)
AS
BEGIN
	--When @ReportDate is not null, then calculate @Start and @End dates for Weekly Sales Impact purposes
	IF(@ReportDate IS NOT NULL) BEGIN
		IF(@EndDate IS NULL) BEGIN
			SET @EndDate = case when datepart(weekday, @ReportDate) > 5 then
				DATEADD(DAY, +4, DATEADD(WEEK, DATEDIFF(WEEK, 0, @ReportDate), 0)) 
			else
				DATEADD(DAY, -3, DATEADD(WEEK, DATEDIFF(WEEK, 0, @ReportDate), 0)) END
		END

		IF(@StartDate IS NULL) BEGIN
			SET @StartDate = DATEADD(month, DATEDIFF(month, 0, @EndDate), 0)
		END
	END
	
	DECLARE @ComputedEndDate DATETIME = DATEADD(SECOND, -1, DATEADD(DAY, 1, @EndDate))

	DECLARE @MonthName varchar(50) = FORMAT(@EndDate, 'MMMM')

	DECLARE @tblProductLine table (
		ProductLine varchar(10)
	)

	DECLARE @tblSS TABLE
	(
		[inx] int identity,
		[prsoat_SalesOrderAuditTrailID] int,
		[Description] varchar(MAX),
		[User] varchar(MAX),
		[SoldBy] varchar(10),
		[BBID] int,
		[Company Name] varchar(MAX),
		[City] varchar(MAX),
		[State] varchar(MAX),
		[Country] varchar(MAX),
		[Terr] varchar(MAX),
		[Service] varchar(MAX),
		[ItemCode] varchar(MAX),
		[Action] varchar(MAX),
		[ActionCancel] varchar(MAX),
		[prsoat_ActionCode] varchar(MAX),
		[Order] varchar(MAX),
		[Amt] decimal(12,2),
		[Anni Month] varchar(MAX),
		[Order Date] datetime,
		[Qty] varchar(MAX),
		[Std Order] varchar(MAX),
		[Category] varchar(MAX),
		[Pipeline] varchar(MAX),
		[UpDown] varchar(MAX),
		[comp_PRIndustryType] varchar(50),
		[IsMembershipCode] bit
	)

	IF (@IncludeAds = 1) BEGIN
		INSERT INTO @tblProductLine SELECT DISTINCT ProductLine FROM MAS_PRC.dbo.CI_Item
	END ELSE BEGIN 
		INSERT INTO @tblProductLine SELECT DISTINCT ProductLine FROM MAS_PRC.dbo.CI_Item WHERE ProductLine NOT IN ('ADP', 'ADE')
	END

	INSERT INTO @tblSS 
	SELECT DISTINCT
		rpt.prsoat_SalesOrderAuditTrailID
		,'Description' = cc1.Capt_US + ' ' + 
			CASE 
				WHEN ItemCode LIKE 'LOGO%' THEN 'Logo '
				WHEN ItemCode='LSS' THEN 'Local Source '
				WHEN ItemCode='BBSINTL' THEN 'International (INTL) '
			ELSE '' END +

			CASE 
				WHEN prsoat_Pipeline='PACA' THEN 'PACA '
				WHEN prsoat_Pipeline='ONLINE' THEN 'Online Member '
				WHEN prsoat_Pipeline='INBOUND' THEN 'Inbound '
				WHEN prsoat_Pipeline='OUTBOUND' THEN 'Outbound '
				WHEN prsoat_Pipeline='REINSTATEMENT' THEN 'Reinstate '
				WHEN prsoat_Pipeline LIKE 'INTERNAL%' THEN 'Internal Referral '
				WHEN prsoat_Pipeline LIKE 'BBOS%' THEN 'BBOS Inquiry '
				WHEN prsoat_Pipeline LIKE 'BBOS%' THEN 'BBOS Inquiry '
				WHEN prsoat_Pipeline LIKE '%TRADESHOW%' OR prsoat_Pipeline LIKE '%TRADE SHOW%' OR prsoat_Pipeline LIKE '% SHOW' THEN 'Tradeshow Referral '
			ELSE '' END +

			CASE WHEN prsoat_ActionCode='C' THEN 'Cancel ' ELSE 
				CASE 
					WHEN ISNULL(prsoat_Up_Down, '')='UPGRADE' THEN 'Upgrade '
					WHEN ISNULL(prsoat_Up_Down, '')='DOWNGRADE' THEN 'Downgrade '
					ELSE 'Membership '
				END 
			END

		, 'User' = RTRIM(UserCode)
		, 'SoldBy' = RTRIM(prsoat_SoldBy)
		, 'BBID' = comp_CompanyID
		, 'Company Name' = comp_name
		, 'City' = prci_City
		, 'State' = prst_Abbreviation
		, 'Country' = prcn_Country
		, 'Terr' = left(prci_SalesTerritory,2)
		, 'Service' = ItemCodeDesc
		, ItemCode
		, 'Action' = CASE prsoat_ActionCode
			WHEN 'C' THEN prsoat_CancelReasonCode
			WHEN 'I' THEN 'New'
			WHEN 'U' THEN 'Change'
			ELSE prsoat_ActionCode
			END
		, 'ActionCancel' = prsoat_CancelReasonCode + ' ' + cc2.Capt_US		
		, ISNULL(prsoat_ActionCode,'') prsoat_ActionCode
		, 'Order' = prsoat_SalesOrderNo
		, 'Amt' =prsoat_ExtensionAmtChange
		, 'Anni Month' = prsoat_CycleCode
		, 'Order Date' = prsoat_CreatedDate
		, 'Qty' = prsoat_QuantityChange
		, 'Std Order' = CASE WHEN Std.SalesOrderNo IS NOT NULL THEN 'Y' ELSE '' END 
		, 'Category' = ''
		, ISNULL(prsoat_Pipeline, '') Pipeline
		, ISNULL(prsoat_Up_Down, '') UpDown
		, comp_PRIndustryType
		, CASE WHEN cc3.Capt_Code IS NOT NULL THEN 1 ELSE 0 END
	FROM CRM.dbo.PRSalesOrderAuditTrail rpt WITH (NOLOCK) 
		INNER JOIN CRM.dbo.Company WITH (NOLOCK) ON prsoat_SoldToCompany = comp_CompanyID 
		INNER JOIN CRM.dbo.vPRLocation ON comp_PRListingCityID = prci_CityID 
		INNER JOIN MAS_PRC.dbo.CI_Item WITH (NOLOCK) ON prsoat_ItemCode = ItemCode 
		INNER JOIN MAS_SYSTEM.dbo.SY_User u WITH (NOLOCK) ON prsoat_CreatedBy = u.UserKey
		INNER JOIN Custom_Captions cc1 ON Capt_Family='comp_PRIndustryType' AND Capt_Code=comp_PRIndustryType
		LEFT OUTER JOIN Custom_Captions cc2 ON cc2.Capt_Family='MembershipCancelCode' AND cc2.Capt_Code=prsoat_CancelReasonCode
		LEFT OUTER JOIN Custom_Captions cc3 ON cc3.Capt_Family='prse_ServiceCode' AND cc3.Capt_Code=prsoat_ItemCode
		LEFT OUTER JOIN MAS_PRC.dbo.SO_SalesOrderHistoryHeader std WITH (NOLOCK) ON std.MasterRepeatingOrderNo = rpt.prsoat_SalesOrderNo AND std.DateCreated BETWEEN @StartDate AND @ComputedEndDate
	WHERE
		prsoat_Deleted IS NULL
		AND prsoat_CreatedDate BETWEEN @StartDate AND @ComputedEndDate 
		AND CI_Item.ItemCode != 'DL'
		AND comp_PRIndustryType =
			CASE 
				WHEN @Industry IN ('All') THEN comp_PRIndustryType
				WHEN @Industry IN ('L') THEN 'L'
				ELSE comp_PRIndustryType
				END
		AND comp_PRIndustryType != 
			CASE WHEN @Industry = 'P' THEN 'L'
			ELSE ''
			END
		AND ProductLine IN (SELECT ProductLine FROM @tblProductLine)

	UNION

	SELECT
		null
		, 'Description'=''
		, 'User' = RTRIM(UserCode)
		, 'SoldBy' = RTRIM(SalespersonNo)
		, BBID = hdr.CustomerNo
		, 'Company Name' = hdr.BillToName
		, 'City' = prci_City
		, 'State' = prst_Abbreviation
		, 'Country' = prcn_Country
		, 'Terr' = left(prci_SalesTerritory,2)
		,'Service' = det.ItemCodeDesc
		, det.ItemCode
		,'Action' = 'Charge'
		, NULL
		, NULL
		,'Order' = ''
		,'Amt' = hdr.TaxableAmt + hdr.NonTaxableAmt + hdr.SalesTaxAmt - hdr.DiscountAmt
		,'Anni Month' = ''
		,'Order Date' = hdr.DateCreated
		,'Qty' = det.QuantityOrderedRevised 
		,'Std Order' = ''
		,'Category' = item.Category4
		,NULL AS Pipeline
		,NULL AS UpDown
		,comp_PRIndustryType
		,CASE WHEN cc3.Capt_Code IS NOT NULL THEN 1 ELSE 0 END
	
	FROM MAS_PRC.dbo.SO_SalesOrderHistoryHeader hdr 
		INNER JOIN CRM.dbo.Company WITH (NOLOCK) ON hdr.CustomerNo = comp_CompanyID 
		INNER JOIN CRM.dbo.vPRLocation ON comp_PRListingCityID = prci_CityID 
		INNER JOIN MAS_PRC.dbo.SO_SalesOrderHistoryDetail AS det ON hdr.SalesOrderNo = det.SalesOrderNo 
		INNER JOIN MAS_PRC.dbo.CI_Item AS Item ON item.ItemCode = det.ItemCode 
		INNER JOIN MAS_SYSTEM.dbo.SY_User usr ON usr.UserKey = hdr.UserUpdatedKey 
		INNER JOIN CRM.dbo.Users ON User_Logon = usr.UserCode --AND Users.User_PrimaryChannelId != 15 AND Users.User_Logon != 'MMR'
		LEFT OUTER JOIN Custom_Captions cc3 ON cc3.Capt_Family='prse_ServiceCode' AND cc3.Capt_Code=det.ItemCode
	WHERE        
		hdr.OrderStatus IN ('A', 'C') 
		AND (det.SalesAcctKey <> '') 
		AND (hdr.SalesOrderNo NOT IN
			(SELECT SalesOrderNo
			   FROM MAS_PRC.dbo.SO_SalesOrderHeader WITH (NOLOCK)
			  WHERE OrderType = 'R'
			    AND CycleCode <> '99'))
		AND (hdr.DateCreated BETWEEN @StartDate AND @ComputedEndDate)
		AND hdr.MasterRepeatingOrderNo = '' 
		AND comp_PRIndustryType =
			CASE 
				WHEN @Industry IN ('All') THEN comp_PRIndustryType
				WHEN @Industry IN ('L') THEN 'L'
				ELSE comp_PRIndustryType
				END
		AND comp_PRIndustryType != 
			CASE WHEN @Industry = 'P' THEN 'L'
			ELSE ''
			END
		AND ProductLine IN (SELECT ProductLine FROM @tblProductLine)
	ORDER BY [Company Name], [Order DATE], UpDown DESC

	DECLARE @tblSS2 TABLE
	(
		inx int,
		[Prev Matches] bit,
		[Prev BBID] int,
		[Prev Service] varchar(MAX),
		[Prev Order Date] datetime,
		[Prev Order Date Seconds] int,
		[Prev Qty] numeric(24,6),
		[Prev ActionCode] varchar(MAX),
		[Prev IsMembershipCode] bit,
		[Next Matches] bit,
		[Next ActionCode] varchar(MAX),
	
		[IsSale] bit,
		[IsPrevSale] bit,
		[IsCancel] bit,
		[IsLogo] bit,
		[IsUpgrade] bit,
		[IsDowngrade] bit,
		[IsLocalSource] bit,
		[IsPipeline] bit,
		[SameDay_C30_Downgrade] bit,
		[SameDay_C24_Upgrade] bit
	)

	DECLARE @LagSeconds int = 300;

	INSERT INTO @tblSS2
	SELECT inx, 
		[Prev Matches]=CASE WHEN
				Lag([BBID], 1) OVER(ORDER BY inx)=[BBID]
				AND DATEDIFF(SECOND, [Order Date], Lag([Order Date], 1) OVER(order by inx)) > (-1*@LagSeconds)
			THEN 1 ELSE 0 END,

		[Prev BBID] = Lag([BBID], 1) OVER(ORDER BY inx),
		[Prev Service] = Lag([Service], 1) OVER(ORDER BY inx),
		[Prev Order Date] = Lag([Order Date], 1) OVER(order by inx),
		[Prev Order Date Seconds] = DATEDIFF(SECOND, [Order Date], Lag([Order Date], 1) OVER(order by inx)),
		[Prev Qty] = Lag([Qty], 1) OVER(order by inx),
		[Prev ActionCode] = Lag([prsoat_ActionCode], 1) OVER(order by inx),
		[Prev IsMembershipCode] = Lag([IsMembershipCode], 1) OVER(order by inx),

		[Next Matches] = CASE WHEN
				Lead([BBID], 1) OVER(ORDER BY inx)=[BBID]
				AND DATEDIFF(SECOND, [Order Date], Lead([Order Date], 1) OVER(order by inx)) < @LagSeconds
		THEN 1 ELSE 0 END,
		[Next ActionCode] = Lead([prsoat_ActionCode], 1) OVER(ORDER BY inx),
	
		NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
	FROM @tblSS
	ORDER BY inx

	--IsPrevSale
	UPDATE T2
		SET IsPrevSale = 1 
	FROM @tblSS T1
		INNER JOIN @tblSS2 T2 ON T1.inx = T2.inx
	WHERE
		(prsoat_ActionCode='U' AND [Prev Matches]=1 AND IsMembershipCode=1)

	--IsSale
	UPDATE T2
		SET IsSale = 1 
	FROM @tblSS T1
		INNER JOIN @tblSS2 T2 ON T1.inx = T2.inx
	WHERE
		--(prsoat_ActionCode='I' AND [Prev Matches]=0 AND IsMembershipCode=1)
		(
			prsoat_ActionCode='I' 
			AND IsMembershipCode=1 
			AND Pipeline <> 'TRANSFER'
			AND (
					[Prev Matches]=0 
					OR ([Prev Matches]=1 AND ISNULL([Prev ActionCode],'')='C' AND ISNULL([Prev IsMembershipCode],0) = 0)
				)
		)
	   
	--IsCancel
	UPDATE T2
		SET IsCancel = 1 
	FROM @tblSS T1
		INNER JOIN @tblSS2 T2 ON T1.inx = T2.inx
	WHERE
		(prsoat_ActionCode='C' AND IsMembershipCode=1)
		AND Action NOT IN ('C24','C30','C11','C31', 'D40', 'D41', 'D42')

	--IsLogo
	UPDATE T2
		SET IsLogo = 1 
	FROM @tblSS T1
		INNER JOIN @tblSS2 T2 ON T1.inx = T2.inx
	WHERE
		prsoat_ActionCode <> 'C' 
		AND ItemCode <> 'LOGO-ADD'
		AND LEFT(ISNULL(ItemCode,'') ,4) = 'LOGO'

	--IsUpgrade
	UPDATE T2
		SET IsUpgrade = 1 
	FROM @tblSS T1
		INNER JOIN @tblSS2 T2 ON T1.inx = T2.inx
	WHERE
		IsMembershipCode=1
		AND
		( 
			Action='C24'
		)

	--IsDowngrade
	UPDATE T2
		SET IsDowngrade = 1 
	FROM @tblSS T1
		INNER JOIN @tblSS2 T2 ON T1.inx = T2.inx
	WHERE
		IsMembershipCode=1
		AND
		Action IN ('C30','D40', 'D41', 'D42')

	--IsLocalSource
	UPDATE T2
		SET IsLocalSource = 1 
	FROM @tblSS T1
		INNER JOIN @tblSS2 T2 ON T1.inx = T2.inx
	WHERE
		LEFT(ItemCode, 3)='LSS' AND prsoat_ActionCode<>'C'

	--IsPipeline
	UPDATE T2
		SET IsPipeline = 1 
	FROM @tblSS T1
		INNER JOIN @tblSS2 T2 ON T1.inx = T2.inx
	WHERE
		ISNULL(Pipeline, '') <> '' AND prsoat_ActionCode<>'C'

	--SameDay flags
	UPDATE T2
		SET T2.SameDay_C30_Downgrade = CASE WHEN cnt>0 THEN 1 ELSE NULL END
	FROM @tblSS T1
		INNER JOIN @tblSS2 T2 ON T1.inx = T2.inx
		LEFT OUTER JOIN (SELECT CAST([Order Date] AS Date) [Order Date], [BBID], COUNT(*) cnt FROM @tblSS WHERE [Action] IN ('C30','D40', 'D41', 'D42') GROUP BY CAST([Order Date] as Date), [BBID]) T3 ON T3.BBID = T1.BBID AND T3.[Order Date] = CAST(T1.[Order Date] as date)

	UPDATE T2
		SET T2.SameDay_C24_Upgrade = CASE WHEN cnt>0 THEN 1 ELSE NULL END
	FROM @tblSS T1
		INNER JOIN @tblSS2 T2 ON T1.inx = T2.inx
		LEFT OUTER JOIN (SELECT CAST([Order Date] AS Date) [Order Date], [BBID], COUNT(*) cnt FROM @tblSS WHERE [Action]='C24' GROUP BY CAST([Order Date] as Date), [BBID]) T3 ON T3.BBID = T1.BBID AND T3.[Order Date] = CAST(T1.[Order Date] as date)
	WHERE
		T1.BBID = T3.BBID

	--Fix out of order downgrade that incorrectly matches as a sale because of cancel on more than previous record
	UPDATE T2 SET IsSale=NULL
	FROM @tblSS T1
		INNER JOIN @tblSS2 T2 ON T1.inx = T2.inx
	WHERE
		T2.SameDay_C30_Downgrade=1 AND T2.IsSale=1 AND [UpDown] = 'DOWNGRADE'

	UPDATE T2 SET IsSale=NULL
	FROM @tblSS T1
		INNER JOIN @tblSS2 T2 ON T1.inx = T2.inx
	WHERE
		T2.SameDay_C24_Upgrade=1 AND T2.IsSale=1 AND [UpDown] = 'UPGRADE'


	SELECT T1.inx, [prsoat_SalesOrderAuditTrailID], [Description], [User], [BBID], [Company Name], [City], [State], [Country], [Terr], [Service], [ItemCode], [Action], [ActionCancel], [prsoat_ActionCode], [Order], CAST(Amt AS DECIMAL(12,2)) [Amt], [Anni Month], [Order Date], [Qty], [Std Order], [Category], [Pipeline], [UpDown], [comp_prIndustryType], [IsMembershipCode],
		[Prev Matches], [Prev BBID], [Prev Service], [Prev Order Date], [Prev Order Date Seconds], [Prev Qty], [Prev ActionCode], [Prev IsMembershipCode], [Next Matches], [Next ActionCode], [IsSale], [IsPrevSale], [IsCancel], [IsLogo], [IsUpgrade], [IsDowngrade], [IsLocalSource], [IsPipeline], [SoldBy],
		[SameDay_C30_Downgrade], [SameDay_C24_Upgrade], @MonthName [MonthName], @StartDate [StartDate], @ComputedEndDate [EndDate]
	FROM @tblSS T1
		INNER JOIN @tblSS2 T2 ON T1.inx = T2.inx
	ORDER BY 
		CASE WHEN @Order='Subscription' THEN [Company Name] END,
		CASE WHEN @Order='Subscription' THEN [Order Date] END, 
		CASE WHEN @Order='Calendar' THEN [Order Date] END,
		CASE WHEN @Order='Calendar' THEN [Company Name] END
END
GO

--Stripe Invoice Integration
CREATE OR ALTER PROCEDURE dbo.usp_InsertPRInvoice
	@CompanyID int,
	@InvoiceNbr varchar(8),
	@SentMethodCode varchar(10),
	@SentDateTime datetime,
	@StripePaymentURL varchar(200),
	@StripeInvoiceId varchar(30),
	@PaymentURLKey varchar(15),
    @UserID int
As
BEGIN
	DECLARE @FirstReminderDate datetime, @SecondReminderDate datetime

	SELECT TOP(1) @FirstReminderDate = prinv_FirstReminderDate,
	              @SecondReminderDate = prinv_SecondReminderDate
	 FROM PRInvoice WITH (NOLOCK)
	 WHERE prinv_InvoiceNbr = @InvoiceNbr
    ORDER BY prinv_InvoiceID DESC

	DECLARE @PRInvoiceID int
	EXEC usp_GetNextId 'PRInvoice', @PRInvoiceID output
	INSERT INTO PRInvoice (prinv_InvoiceID, prinv_CompanyID, prinv_InvoiceNbr, prinv_SentMethodCode, prinv_SentDateTime, prinv_StripePaymentURL, prinv_StripeInvoiceId, prinv_PaymentURLKey, prinv_FirstReminderDate, prinv_SecondReminderDate, prinv_CreatedBy, prinv_CreatedDate, prinv_UpdatedBy, prinv_UpdatedDate, prinv_TimeStamp)
		VALUES (@PRInvoiceID, @CompanyID, @InvoiceNbr, @SentMethodCode, @SentDateTime, @StripePaymentURL, @StripeInvoiceId, @PaymentURLKey, @FirstReminderDate, @SecondReminderDate, @UserID, GETDATE(), @UserID, GETDATE(), GETDATE());
END
Go

CREATE OR ALTER PROCEDURE dbo.usp_AllocateBackgroundChecks
	@CompanyID int,
	@Units int,
	@AllocationType nvarchar(40),
	@StartDate datetime = null,
    @CRMUserID int = 0,
    @HQID int = null 
AS
BEGIN
	SET NOCOUNT ON

	-- If we don't have a CRM User, go get the
	-- default website user
	IF @CRMUserID = 0 BEGIN
		SET @CRMUserID = dbo.ufn_GetSystemUserId(1)
	END

	IF (@StartDate IS NULL) BEGIN
		SET @StartDate = CONVERT(DateTime, convert(varchar, GetDate(),101))
	END

	IF (@HQID IS NULL) BEGIN
		SELECT @HQID = comp_PRHQID
		  FROM Company WITH (NOLOCK)
		 WHERE comp_CompanyID = @CompanyID;
	END

	-- Compute our End Date
	-- For a membership allocation, it is the first day of the same month of the next year. (Note: will always be 1/1)
	-- For an additional unit pack allocation, it is the first day of the next month of the next year.
	DECLARE @EndDate datetime, @TempDate datetime
	IF @AllocationType = 'A' BEGIN
		SET @TempDate = DATEADD(Month, 1, @StartDate)
		SET @EndDate = CONVERT(DateTime, CONVERT(varchar(4), YEAR(@TempDate)+1) + '-' +  CONVERT(varchar(4), Month(@TempDate)) + '-1')
	END ELSE BEGIN
		SET @EndDate = CONVERT(DateTime, CONVERT(varchar(4), YEAR(@StartDate)+1) + '-01-01')
	END
	
	--
	--  If we're allocating units for a membership, look to see if any
	--  other active allocation records exist.  If so, they need to be cancelled
	--
	IF @AllocationType = 'M' BEGIN

		UPDATE PRBackgroundCheckAllocation
		   SET prbca_Remaining = 0,
		       prbca_UpdatedBy = @CRMUserID,
			   prbca_UpdatedDate = GETDATE()
   	     WHERE prbca_HQID = @HQID
		   AND prbca_AllocationTypeCode = 'M'
		   AND prbca_Remaining > 0;
	END
	
		
	INSERT INTO PRBackgroundCheckAllocation (prbca_HQID, prbca_CompanyID, prbca_AllocationTypeCode, prbca_Allocation, prbca_Remaining, prbca_StartDate, prbca_ExpirationDate, prbca_CreatedBy, prbca_CreatedDate)
	VALUES (@HQID,
			@CompanyID,
			@Units,
			@Units,
			@AllocationType,
			@StartDate,
			@EndDate,
			@CRMUserID,
			GETDATE());

	SET NOCOUNT OFF
END
GO

CREATE OR ALTER PROCEDURE usp_RenewBackgroundCheckAllocations
AS
BEGIN
	DECLARE @Start datetime
	SET @Start = GETDATE()
	PRINT 'Renewing All M Type Background Check Allocations'

	UPDATE PRBackgroundCheckAllocation
		SET prbca_Remaining = 0,
		    prbca_UpdatedBy = 1,
			prbca_UpdatedDate = @Start
   	  WHERE prbca_AllocationTypeCode = 'M'
		AND prbca_Remaining > 0;

	DECLARE @StartDate datetime = '1/1/' + LTRIM(STR(DATEPART(year, @Start)))  
    DECLARE @EndDate datetime = '1/1/' + LTRIM(STR(DATEPART(year, DATEADD(Year, 1, @Start))))

	INSERT INTO PRBackgroundCheckAllocation (prbca_HQID, prbca_CompanyID, prbca_AllocationTypeCode, prbca_Allocation, prbca_Remaining, prbca_StartDate, prbca_ExpirationDate, prbca_CreatedBy, prbca_CreatedDate)
	SELECT prse_HQID, prse_CompanyID, 'M', prod_PRBackgroundChecks, prod_PRBackgroundChecks, @StartDate, @EndDate, 1, @Start
	  FROM PRService
           INNER JOIN NewProduct ON prse_ServiceCode = prod_code
     WHERE prse_Primary='Y'
       AND prod_productfamilyid = 5
END
Go

CREATE OR ALTER PROCEDURE usp_MemberCancellations
	@StartDate datetime,
	@EndDate datetime,
    @OutputType varchar(25) = 'Summary',
	@IndustryType varchar(10) = 'P'
AS
BEGIN
	SET NOCOUNT ON

	--DECLARE @StartDate datetime = '2024-01-01'
	--DECLARE @EndDate datetime = '2024-03-31'

	DECLARE @ComputedEndDate datetime
	SET @ComputedEndDate = DATEADD(day, 1, @EndDate)

	CREATE TABLE #tblCompanies  (
		CompanyID int
	)

	INSERT INTO #tblCompanies
	SELECT DISTINCT prsoat_SoldToCompany
	  FROM PRSalesOrderAuditTrail WITH (NOLOCK)
	       INNER JOIN Company WITH (NOLOCK) ON prsoat_SoldToCompany = comp_CompanyID
	 WHERE prsoat_CreatedDate BETWEEN @StartDate AND @ComputedEndDate
	   AND prsoat_ActionCode = 'C'
	   AND prsoat_CancelReasonCode IN ('C01', 'C02', 'C03', 'C04', 'C05', 'C06', 'C07', 'C08', 'C09', 'C10', 'C12', 'C23', 'C27', 'C33', 'C34')
	   AND comp_PRIndustryType IN (SELECT Value FROM dbo.Tokenize(@IndustryType, ','))


	CREATE TABLE #tblLastLogin (
		CompanyID int,
		LastUsageDate date
	)

	INSERT INTO #tblLastLogin
	SELECT prwsat_CompanyID, MAX(prwsat_CreatedDate) LastUsageDate 
		FROM (SELECT prwsat_CompanyID, prwsat_CreatedDate FROM CRM.dbo.PRWebAuditTrail WITH (NOLOCK) WHERE prwsat_CompanyID IN (SELECT CompanyID FROM #tblCompanies)
			  UNION
			  SELECT prwsat_CompanyID, prwsat_CreatedDate FROM CRMArchive.dbo.PRWebAuditTrail WITH (NOLOCK) WHERE prwsat_CompanyID IN (SELECT CompanyID FROM #tblCompanies)) INNERT1
	GROUP BY prwsat_CompanyID


	/*
	SELECT COUNT(1) TotalCancellationsCount,
		   COUNT(DISTINCT prsoat_SoldToCompany) CompaniesCancelledCount
	  FROM PRSalesOrderAuditTrail WITH (NOLOCK)
	 WHERE prsoat_CreatedDate BETWEEN @StartDate AND @ComputedEndDate
	   AND prsoat_ActionCode = 'C'
	   AND prsoat_CancelReasonCode NOT IN ('C24', 'C30')
	*/

	CREATE TABLE #CancelledMembership (
		BBID int,
		CompanyName varchar(200),
		CancelDate date,
		CancelReasonCode varchar(40),
		CancelReason varchar(200),
		CancelledService varchar(40),
		Industry varchar(50),
		ListingStatus varchar(100),
		Rated varchar(5),
		UsedBBOS varchar(5),
		LastBBOSUsage date,
	)

	INSERT INTO #CancelledMembership
	SELECT prsoat_SoldToCompany [BBID], 
		   Company.comp_Name [Company Name],
		   prsoat_CreatedDate [Cancel Date], 
		   prsoat_CancelReasonCode,
		   cancelcode.capt_us [Cancel Reason],
		   prsoat_ItemCode [Cancelled Membership],
		   industry.capt_us [Industry],
		   listing.capt_us [Listing Status],
		   CASE WHEN prra_RatingID IS NOT NULL THEN 'Yes' ELSE 'No' END [Rated]
		   ,CASE WHEN LastUsageDate IS NOT NULL THEN 'Yes' ELSE 'No' END [Used BBOS],
		   LastUsageDate [Last BBOS Usage]
	  FROM PRSalesOrderAuditTrail WITH (NOLOCK) 
		   INNER JOIN Company WITH (NOLOCK) ON prsoat_SoldToCompany = comp_CompanyID
		   INNER JOIN Custom_Captions industry WITH (NOLOCK)  ON comp_PRIndustryType = industry.Capt_Code AND industry.Capt_Family = 'comp_PRIndustryType'
		   INNER JOIN Custom_Captions listing WITH (NOLOCK)  ON comp_PRListingStatus = listing.Capt_Code AND listing.Capt_Family = 'comp_PRListingStatus'
		   INNER JOIN Custom_Captions cancelcode WITH (NOLOCK)  ON prsoat_CancelReasonCode = cancelcode.Capt_Code AND cancelcode.Capt_Family = 'MembershipCancelCode'
		   LEFT OUTER JOIN vPRCompanyRating ON comp_CompanyID = prra_CompanyID AND prra_Current = 'Y'
		   LEFT OUTER JOIN #tblLastLogin ON prsoat_SoldToCompany = CompanyID
	 WHERE prsoat_CreatedDate BETWEEN @StartDate AND @ComputedEndDate
	   AND prsoat_ActionCode = 'C'
	   AND prsoat_CancelReasonCode IN ('C01', 'C02', 'C03', 'C04', 'C05', 'C06', 'C07', 'C08', 'C09', 'C10', 'C12', 'C23', 'C27', 'C33', 'C34')
	   AND prsoat_ItemCode IN (SELECT ItemCode FROM MAS_PRC.dbo.CI_Item WHERE Category2='PRIMARY')
	   AND comp_PRIndustryType IN (SELECT Value FROM dbo.Tokenize(@IndustryType, ','))


	 IF (@OutputType = 'Details') BEGIN
		SELECT * FROM #CancelledMembership ORDER BY CancelDate
	 END

	 IF (@OutputType = 'Monthly') BEGIN
		SELECT 'CancelReason' Metric, YEAR(CancelDate) [Year], MONTH(CancelDate) [Month], FORMAT(CancelDate, 'MMM yyyy') DisplayText, CancelReason Label, COUNT(1) Cnt
		  FROM #CancelledMembership
		GROUP BY CancelReason, YEAR(CancelDate), MONTH(CancelDate), FORMAT(CancelDate, 'MMM yyyy')
		UNION
		SELECT 'Industry' Metric, YEAR(CancelDate) [Year], MONTH(CancelDate) [Month], FORMAT(CancelDate, 'MMM yyyy') DisplayText, Industry, COUNT(1) 
		  FROM #CancelledMembership
		GROUP BY Industry, YEAR(CancelDate), MONTH(CancelDate), FORMAT(CancelDate, 'MMM yyyy')
		UNION
		SELECT 'ListingStatus' Metric, YEAR(CancelDate) [Year], MONTH(CancelDate) [Month], FORMAT(CancelDate, 'MMM yyyy') DisplayText, ListingStatus, COUNT(1) 
		  FROM #CancelledMembership
		GROUP BY ListingStatus, YEAR(CancelDate), MONTH(CancelDate), FORMAT(CancelDate, 'MMM yyyy')
		UNION
		SELECT 'Rated' Metric, YEAR(CancelDate) [Year], MONTH(CancelDate) [Month], FORMAT(CancelDate, 'MMM yyyy') DisplayText, Rated, COUNT(1) 
		  FROM #CancelledMembership
		GROUP BY Rated, YEAR(CancelDate), MONTH(CancelDate), FORMAT(CancelDate, 'MMM yyyy')
		UNION
		SELECT 'UsedBBOS' Metric, YEAR(CancelDate) [Year], MONTH(CancelDate) [Month], FORMAT(CancelDate, 'MMM yyyy') DisplayText, UsedBBOS, COUNT(1) 
		  FROM #CancelledMembership
		GROUP BY UsedBBOS, YEAR(CancelDate), MONTH(CancelDate), FORMAT(CancelDate, 'MMM yyyy')
	END

	 IF (@OutputType = 'Annually') BEGIN
		SELECT 'CancelReason' Metric, YEAR(CancelDate) [Year], FORMAT(CancelDate, 'yyyy') DisplayText, CancelReason Label, COUNT(1) Cnt
		  FROM #CancelledMembership
		GROUP BY CancelReason, YEAR(CancelDate), FORMAT(CancelDate, 'yyyy')
		UNION
		SELECT 'Industry' Metric, YEAR(CancelDate) [Year], FORMAT(CancelDate, 'yyyy') DisplayText, Industry, COUNT(1) 
		  FROM #CancelledMembership
		GROUP BY Industry, YEAR(CancelDate), FORMAT(CancelDate, 'yyyy')
		UNION
		SELECT 'ListingStatus' Metric, YEAR(CancelDate) [Year], FORMAT(CancelDate, 'yyyy') DisplayText, ListingStatus, COUNT(1) 
		  FROM #CancelledMembership
		GROUP BY ListingStatus, YEAR(CancelDate), FORMAT(CancelDate, 'yyyy')
		UNION
		SELECT 'Rated' Metric, YEAR(CancelDate) [Year], FORMAT(CancelDate, 'yyyy') DisplayText, Rated, COUNT(1) 
		  FROM #CancelledMembership
		GROUP BY Rated, YEAR(CancelDate), FORMAT(CancelDate, 'yyyy')
		UNION
		SELECT 'UsedBBOS' Metric, YEAR(CancelDate) [Year], FORMAT(CancelDate, 'yyyy') DisplayText, UsedBBOS, COUNT(1) 
		  FROM #CancelledMembership
		GROUP BY UsedBBOS, YEAR(CancelDate), FORMAT(CancelDate, 'yyyy')
	END

	DROP TABLE #CancelledMembership
	DROP TABLE #tblLastLogin
	DROP TABLE #tblCompanies
END
GO


CREATE OR ALTER PROCEDURE usp_MembershipsSoldByUser
	@StartDate datetime,
	@EndDate datetime,
    @OutputType varchar(25) = 'Summary'
AS
BEGIN
	SET NOCOUNT ON


	DECLARE @ComputedEndDate datetime = DATEADD(day, 1, @EndDate)

	CREATE TABLE #tblWork (
		DateSold date,
		SoldBy varchar(10),
		Pipeline varchar(50),
		ItemCode varchar(15),
		Revenue money
	)

	INSERT INTO #tblWork
	SELECT prsoat_CreatedDate, UPPER(CASE WHEN prsoat_SoldBy IS NULL THEN prsoat_UserLogon WHEN prsoat_SoldBy = '0000' THEN prsoat_UserLogon ELSE prsoat_SoldBy END), prsoat_Pipeline, prsoat_ItemCode, prsoat_ExtensionAmt
	  FROM PRSalesOrderAuditTrail
	 WHERE prsoat_CreatedDate BETWEEN @StartDate AND @ComputedEndDate
	   AND prsoat_CreatedDate NOT BETWEEN '2024-03-01' AND '2024-03-31 11:59 PM'
	   AND prsoat_ActionCode = 'I'
	   AND prsoat_ItemCode IN (SELECT DISTINCT ItemCode  FROM MAS_PRC.dbo.CI_Item WHERE  Category2 = 'PRIMARY')
	   AND prsoat_Pipeline NOT IN ('TRANSFER')
	   AND prsoat_Up_Down NOT IN ('DOWNGRADE', 'UPGRADE')
	   AND prsoat_SalesOrderAuditTrailID NOT IN (  -- Exclude those changes that are a result of an upgrade or downgrade
 					SELECT prsoat_SalesOrderAuditTrailID
					  FROM PRSalesOrderAuditTrail soat
						   INNER JOIN (
									SELECT prsoat_SalesOrderAuditTrailID SalesOrderAuditTrailID, prsoat_SalesOrderNo SalesOrderNo
									  FROM PRSalesOrderAuditTrail
									 WHERE prsoat_CancelReasonCode IN ('C24', 'C30', 'D40', 'D41', 'D42')
									   AND prsoat_CreatedDate BETWEEN @StartDate AND @ComputedEndDate
									   AND prsoat_ItemCode IN (SELECT ItemCode FROM MAS_PRC.dbo.CI_Item WHERE Category2='PRIMARY')
									 ) CanceledServices ON (CanceledServices.SalesOrderAuditTrailID+1) = soat.prsoat_SalesOrderAuditTrailID  -- For upgrades/downgrades, most often the very next record is the new service
													   AND CanceledServices.SalesOrderNo = prsoat_SalesOrderNo
					 WHERE prsoat_ItemCode IN (SELECT ItemCode FROM MAS_PRC.dbo.CI_Item WHERE Category2='PRIMARY'))
	UNION
	SELECT prmr_Invoicedate, prmr_SoldBy, prmr_Pipeline, prmr_ItemCode, prmr_Amount
		 FROM PRMembershipReportTable
		WHERE prmr_InvoiceDate BETWEEN @StartDate AND @ComputedEndDate 


	DECLARE @tblWeeklyGoal TABLE (
		SoldBy varchar(3),
		Goal decimal(5,2)
	)

	INSERT INTO @tblWeeklyGoal VALUES ('JBL', 2.5)
	INSERT INTO @tblWeeklyGoal VALUES ('LEL', 7)
	INSERT INTO @tblWeeklyGoal VALUES ('TJR', 7)

	DECLARE @WeekCount decimal(5,2) = DATEDIFF(WW, @startdate, @enddate)
	--SELECT @WeekCount

	DECLARE @tblTotals TABLE (
		SoldBy varchar(3),
		Goal decimal(5,2),
		YTD int
	)

	INSERT INTO @tblTotals
	SELECT UPPER(a.SoldBy), (Goal*@WeekCount), COUNT(1)
	  FROM #tblWork a
	       LEFT OUTER JOIN @tblWeeklyGoal b ON a.SoldBy = b.SoldBy
  GROUP BY a.SoldBy, Goal
  --  SELECT * FROM @tblTotals

	IF (@OutputType = 'SUMMARY') BEGIN
		SELECT COUNT(1) SoldCount,
			   SUM(Revenue) TotalRevenue
		  FROM #tblWork
	END

	IF (@OutputType = 'MONTHLY') BEGIN
		SELECT SoldBy, CASE RowNum WHEN 1 THEN Goal ELSE 0 END Goal, CASE RowNum WHEN 1 THEN YTD ELSE 0 END YTD, YTDPct, Sort, Display, SoldCount, GoalPct, RowNum
		FROM (
			SELECT a.SoldBy, ISNULL(b.Goal, 0) Goal, YTD, (YTD / ISNULL(b.Goal, 1)) YTDPct, FORMAT(DateSold, 'yyyyMM') as Sort, FORMAT(DateSold, 'MMM yy') as Display, COUNT(1) SoldCount, (COUNT(1) / (c.Goal * 4)) GoalPct, ROW_NUMBER() OVER(Partition By a.SoldBy ORDER BY FORMAT(DateSold, 'yyyyMM')) RowNum
			  FROM #tblWork a
				   LEFT OUTER JOIN @tblTotals b ON a.SoldBy = b.SoldBy
				   LEFT OUTER JOIN @tblWeeklyGoal  c ON a.SoldBy = c.SoldBy
			 GROUP BY a.SoldBy, b.Goal, c.Goal, YTD, FORMAT(DateSold, 'yyyyMM'), FORMAT(DateSold, 'MMM yy')
			 ) T1
		ORDER BY SoldBy, Sort
	END

	IF (@OutputType = 'WEEKLY') BEGIN
		SET DATEFIRST 1 --Monday

		SELECT SoldBy, CASE RowNum WHEN 1 THEN Goal ELSE 0 END Goal, CASE RowNum WHEN 1 THEN YTD ELSE 0 END YTD, YTDPct, Sort, Display, SoldCount, GoalPct, RowNum
		FROM (
			SELECT a.SoldBy, ISNULL(b.Goal, 0) Goal, YTD, (YTD / ISNULL(b.Goal, 1)) YTDPct, DATEPART(wk, DateSold) as Sort, FORMAT(DATEADD(DD, 1 - DATEPART(DW, DateSold), DateSold), 'M/d') as Display, COUNT(1) SoldCount, (COUNT(1) / (c.Goal)) GoalPct, ROW_NUMBER() OVER(Partition By a.SoldBy ORDER BY DATEPART(wk, DateSold)) RowNum
			  FROM #tblWork a
				   LEFT OUTER JOIN @tblTotals b ON a.SoldBy = b.SoldBy
				   LEFT OUTER JOIN @tblWeeklyGoal  c ON a.SoldBy = c.SoldBy
			 GROUP BY a.SoldBy, b.Goal, c.Goal, YTD, DATEPART(wk, DateSold), FORMAT(DATEADD(DD, 1 - DATEPART(DW, DateSold), DateSold), 'M/d')
		 ) T1
		ORDER BY SoldBy, Sort
	END

	IF (@OutputType = 'QUARTERLY') BEGIN
		SET DATEFIRST 1 --Monday

		SELECT SoldBy, CASE RowNum WHEN 1 THEN Goal ELSE 0 END Goal, CASE RowNum WHEN 1 THEN YTD ELSE 0 END YTD, YTDPct, Sort, Display, SoldCount, GoalPct, RowNum
		FROM (
			SELECT a.SoldBy, ISNULL(b.Goal, 0) Goal, YTD, (YTD / ISNULL(b.Goal, 1)) YTDPct, DATEPART(quarter, DateSold) as Sort,  'Quarter ' + CAST(DATEPART(quarter, DateSold) as varchar(2)) + ' ' + FORMAT(DateSold, 'yyyy') as Display, COUNT(1) SoldCount, (COUNT(1) / (c.Goal * 13)) GoalPct, ROW_NUMBER() OVER(Partition By a.SoldBy ORDER BY DATEPART(quarter, DateSold)) RowNum
			  FROM #tblWork a
				   LEFT OUTER JOIN @tblTotals b ON a.SoldBy = b.SoldBy
				   LEFT OUTER JOIN @tblWeeklyGoal  c ON a.SoldBy = c.SoldBy
			 GROUP BY a.SoldBy, b.Goal, c.Goal, YTD, DATEPART(quarter, DateSold), 'Quarter ' + CAST(DATEPART(quarter, DateSold) as varchar(2)) + ' ' + FORMAT(DateSold, 'yyyy')
		 ) T1
		ORDER BY SoldBy, Sort
	END	

	IF (@OutputType = 'MEMBERSHIPS') BEGIN
		SELECT ItemCode, COUNT(1) SoldCount
		  FROM #tblWork
		GROUP BY ItemCode
	END

	IF (@OutputType = 'PIPELINEMONTHLY') BEGIN
		SELECT Pipeline, Sort, Display, SoldCount
		FROM (
			SELECT Pipeline, FORMAT(DateSold, 'yyyyMM') as Sort, FORMAT(DateSold, 'MMM yy') as Display, COUNT(1) SoldCount
			  FROM #tblWork a
			 GROUP BY Pipeline, FORMAT(DateSold, 'yyyyMM'), FORMAT(DateSold, 'MMM yy')
			 ) T1
		ORDER BY Pipeline, Sort
	END

	IF (@OutputType = 'PIPELINEWEEKLY') BEGIN
		SET DATEFIRST 1 --Monday

		SELECT Pipeline, Sort, Display, SoldCount
		FROM (
			SELECT Pipeline, DATEPART(wk, DateSold) as Sort, FORMAT(DATEADD(DD, 1 - DATEPART(DW, DateSold), DateSold), 'M/d') as Display, COUNT(1) SoldCount
			  FROM #tblWork a
			 GROUP BY Pipeline, DATEPART(wk, DateSold), FORMAT(DATEADD(DD, 1 - DATEPART(DW, DateSold), DateSold), 'M/d')
		 ) T1
		ORDER BY Pipeline, Sort
	END

	DROP TABLE #tblWork

END
Go

CREATE OR ALTER   PROCEDURE [dbo].[usp_MemberCancellationsExecutive]
	@StartDate datetime,
	@EndDate datetime,
    @OutputType varchar(25) = 'Summary',
	@IndustryType varchar(10) = 'P'
AS
BEGIN
	SET NOCOUNT ON

	--DECLARE @StartDate datetime = '2023-01-01'
	--DECLARE @EndDate datetime = '2024-04-30'

	DECLARE @ComputedEndDate datetime
	SET @ComputedEndDate = DATEADD(day, 1, @EndDate)

	CREATE TABLE #tblCompanies  (
		CompanyID int
	)

	INSERT INTO #tblCompanies
	SELECT DISTINCT prsoat_SoldToCompany
	  FROM PRSalesOrderAuditTrail WITH (NOLOCK)
	       INNER JOIN Company WITH (NOLOCK) ON prsoat_SoldToCompany = comp_CompanyID
	 WHERE prsoat_CreatedDate BETWEEN @StartDate AND @ComputedEndDate
	   AND prsoat_ActionCode = 'C'
	   AND prsoat_CancelReasonCode IN ('C01', 'C02', 'C03', 'C04', 'C05', 'C06', 'C07', 'C08', 'C09', 'C10', 'C12', 'C23', 'C27', 'C33', 'C34')
	   AND comp_PRIndustryType IN (SELECT Value FROM dbo.Tokenize(@IndustryType, ','))


	CREATE TABLE #CancelledMembership (
		BBID int,
		CompanyName varchar(200),
		CancelDate date,
		CancelReasonCode varchar(40),
		CancelReason varchar(200),
		CancelledService varchar(40),
		Industry varchar(50),
		ListingStatus varchar(100),
		DaysOfService int
	)

	INSERT INTO #CancelledMembership
	SELECT prsoat_SoldToCompany [BBID], 
		   Company.comp_Name [Company Name],
		   prsoat_CreatedDate [Cancel Date], 
		   prsoat_CancelReasonCode,
		   cancelcode.capt_us [Cancel Reason],
		   prsoat_ItemCode [Cancelled Membership],
		   industry.capt_us [Industry],
		   listing.capt_us [Listing Status],
		   DATEDIFF(day, comp_PRServiceStartDate, comp_PRServiceEndDate) DaysOfService
	  FROM PRSalesOrderAuditTrail WITH (NOLOCK) 
		   INNER JOIN Company WITH (NOLOCK) ON prsoat_SoldToCompany = comp_CompanyID
		   INNER JOIN Custom_Captions industry WITH (NOLOCK)  ON comp_PRIndustryType = industry.Capt_Code AND industry.Capt_Family = 'comp_PRIndustryType'
		   INNER JOIN Custom_Captions listing WITH (NOLOCK)  ON comp_PRListingStatus = listing.Capt_Code AND listing.Capt_Family = 'comp_PRListingStatus'
		   INNER JOIN Custom_Captions cancelcode WITH (NOLOCK)  ON prsoat_CancelReasonCode = cancelcode.Capt_Code AND cancelcode.Capt_Family = 'MembershipCancelCode'
	 WHERE prsoat_CreatedDate BETWEEN @StartDate AND @ComputedEndDate
	   AND prsoat_ActionCode = 'C'
	   AND prsoat_CancelReasonCode IN ('C01', 'C02', 'C03', 'C04', 'C05', 'C06', 'C07', 'C08', 'C09', 'C10', 'C12', 'C23', 'C27', 'C33', 'C34')
	   AND prsoat_ItemCode IN (SELECT ItemCode FROM MAS_PRC.dbo.CI_Item WHERE Category2='PRIMARY')
	   AND comp_PRIndustryType IN (SELECT Value FROM dbo.Tokenize(@IndustryType, ','))

--SELECT * FROM #CancelledMembership WHERE CancelDate BETWEEN '2024-01-01' AND '2024-02-01'

	 IF (@OutputType = 'Monthly') BEGIN
		SELECT 'TotalCancellations' Metric, YEAR(CancelDate) [Year], MONTH(CancelDate) [Month], FORMAT(CancelDate, 'MMM yyyy') DisplayText, '' SubType, COUNT(1) Cnt
		  FROM #CancelledMembership
		GROUP BY YEAR(CancelDate), MONTH(CancelDate), FORMAT(CancelDate, 'MMM yyyy')
	  UNION
   	   SELECT 'NonPayment' Metric, YEAR(CancelDate) [Year], MONTH(CancelDate) [Month], FORMAT(CancelDate, 'MMM yyyy') DisplayText, '' SubType, COUNT(1) Cnt
		  FROM #CancelledMembership
	    WHERE CancelReasonCode = 'C23'
		GROUP BY YEAR(CancelDate), MONTH(CancelDate), FORMAT(CancelDate, 'MMM yyyy')
	  UNION
   	   SELECT 'ServiceOnly' Metric, YEAR(CancelDate) [Year], MONTH(CancelDate) [Month], FORMAT(CancelDate, 'MMM yyyy') DisplayText, '' SubType, COUNT(1) Cnt
		  FROM #CancelledMembership
	    WHERE ListingStatus = 'Not Listed - Service Only'
		GROUP BY YEAR(CancelDate), MONTH(CancelDate), FORMAT(CancelDate, 'MMM yyyy')
	  UNION
   	   SELECT 'ServiceDuration' Metric, YEAR(CancelDate) [Year], MONTH(CancelDate) [Month], FORMAT(CancelDate, 'MMM yyyy') DisplayText, CASE WHEN DaysOfService < 365 THEN '< 1 Year' 
	                                                                                                                                         WHEN DaysOfService < (365 * 2) THEN '< 2 Years'
																																			 WHEN DaysOfService < (365 * 3) THEN '< 3 Yeasr'
																																			 ELSE '3+ Years' END as Duration,  
				COUNT(1) Cnt
		  FROM #CancelledMembership
		GROUP BY YEAR(CancelDate), MONTH(CancelDate), FORMAT(CancelDate, 'MMM yyyy'), CASE WHEN DaysOfService < 365 THEN '< 1 Year' 
	                                                                                        WHEN DaysOfService < (365 * 2) THEN '< 2 Years'
																							WHEN DaysOfService < (365 * 3) THEN '< 3 Yeasr'
																							ELSE '3+ Years' END 

	END


	 IF (@OutputType = 'Annually') BEGIN
		SELECT 'TotalCancellations' Metric, YEAR(CancelDate) [Year], FORMAT(CancelDate, 'yyyy') DisplayText, CancelReason Label, '' SubType, COUNT(1) Cnt
		  FROM #CancelledMembership
		GROUP BY YEAR(CancelDate), FORMAT(CancelDate, 'yyyy')
	  UNION
   	   SELECT 'NonPayment' Metric, YEAR(CancelDate) [Year], FORMAT(CancelDate, 'yyyy') DisplayText, '' SubType, COUNT(1) Cnt
		  FROM #CancelledMembership
	    WHERE CancelReasonCode = 'C23'
		GROUP BY YEAR(CancelDate), FORMAT(CancelDate, 'yyyy')
	  UNION
   	   SELECT 'ServiceOnly' Metric, YEAR(CancelDate) [Year], FORMAT(CancelDate, 'yyyy') DisplayText, '' SubType, COUNT(1) Cnt
		  FROM #CancelledMembership
	    WHERE ListingStatus = 'Not Listed - Service Only'
		GROUP BY YEAR(CancelDate), FORMAT(CancelDate, 'yyyy')
	   UNION
   	   SELECT 'ServiceDuration' Metric, YEAR(CancelDate) [Year], FORMAT(CancelDate, 'yyyy') DisplayText, CASE WHEN DaysOfService < 365 THEN '< 1 Year' 
	                                                                                                                                         WHEN DaysOfService < (365 * 2) THEN '< 2 Years'
																																			 WHEN DaysOfService < (365 * 3) THEN '< 3 Yeasr'
																																			 ELSE '3+ Years' END as Duration,  
				COUNT(1) Cnt
		  FROM #CancelledMembership
		GROUP BY YEAR(CancelDate), FORMAT(CancelDate, 'yyyy'), CASE WHEN DaysOfService < 365 THEN '< 1 Year' 
	                                                                                        WHEN DaysOfService < (365 * 2) THEN '< 2 Years'
																							WHEN DaysOfService < (365 * 3) THEN '< 3 Yeasr'
																							ELSE '3+ Years' END 

	END

	DROP TABLE #CancelledMembership
	DROP TABLE #tblCompanies
END
GO