/* ************************************************************
 * Name:   dbo.trg_PRARAgingDetail_ins
 * 
 * Table:  PRARAgingDetail
 * Action: FOR INSERT
 * 
 * Description: INSERT trigger that 
 *              1) checks to see if a relationship 
 *                 record (04) exists for the praad_ManualCompanyId
 *                 and the praa_CompanyId (PRARAging)
 *              2) checks for conditions that would cause this 
 *                 detail record to generate a PRExceptionQueue item 
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRARAgingDetail_ins]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRARAgingDetail_ins]
GO

CREATE TRIGGER dbo.trg_PRARAgingDetail_ins
ON PRARAgingDetail
FOR INSERT AS
BEGIN
    SET NOCOUNT ON
    Declare @Err int
    SET @Err = 0

    Declare @NextRelationshipId int
    Declare @PRRelationshipTableId int
    Declare @Msg varchar(255)
    Declare @Now datetime

    Declare @praa_CompanyId int
    Declare @praa_Date datetime
    Declare @SubjectId int 

    Declare @praad_ManualCompanyId int
    Declare @praad_ARAgingDetailId int
    Declare @praad_ARAgingId int
    Declare @praad_Amount30to44 numeric, @praad_Amount45to60 numeric, @praad_Amount61Plus numeric
    Declare @praad_ARCustomerId nvarchar(15)
    Declare @praad_CreatedBy int

    Declare @prra_RatingId int
    Declare @prra_AssignedRatingNumerals varchar(100) 
    Declare @prra_IntegrityName varchar(10)
    Declare @prra_PayRatingName varchar(10)
            
    Declare @prcr_CompanyRelationshipId int

    -- get the Accpac ID value for this entity so we can get the next available Id
    select @PRRelationshipTableId = Bord_TableId from custom_tables where Bord_Caption = 'PRCompanyRelationship'

    -- get the required fields from the inserted record
    SELECT @praa_CompanyId = praa_CompanyId,
           @praa_Date = praa_Date,
           @praad_ARAgingDetailId = praad_ARAgingDetailId,
           @praad_ARCustomerId = praad_ARCustomerId,
           @praad_ManualCompanyId = praad_ManualCompanyId,
           @praad_ARAgingId = praad_ARAgingId,
           @praad_Amount30to44 = praad_Amount30to44, 
           @praad_Amount45to60 = praad_Amount45to60, 
           @praad_Amount61Plus = praad_Amount61Plus,
           @praad_CreatedBy = praad_CreatedBy 
      from inserted
      JOIN PRARAging ON praad_ARAgingId = praa_ARAgingId
    
    IF (@praad_ManualCompanyId IS NOT NULL)
    BEGIN
        SET @SubjectId = @praad_ManualCompanyId
        -- check if a relationship record already exists
        SET @prcr_CompanyRelationshipId = NULL
        Select @prcr_CompanyRelationshipId = prcr_CompanyRelationshipId
          from PRCompanyRelationship
          where prcr_LeftCompanyId = @praa_CompanyId 
            AND prcr_RightCompanyId = @praad_ManualCompanyId
            AND prcr_Type = '04'
        If (@prcr_CompanyRelationshipId is null)
        begin
            SET @Now = getDate();
            EXEC @NextRelationshipId = crm_next_id @PRRelationshipTableId

            INSERT into PRCompanyRelationship
            ( prcr_CompanyRelationshipId,
              prcr_CreatedBy,prcr_createdDate,prcr_UpdatedBy,prcr_UpdatedDate,prcr_TimeStamp,
              prcr_LeftCompanyId, prcr_RightCompanyId, prcr_type, prcr_EnteredDate, 
              prcr_LastReportedDate, prcr_TimesReported
            )  
            VALUES ( 
                @NextRelationshipId,
                @praad_CreatedBy,@Now,@praad_CreatedBy,@Now,@Now,  
                @praa_CompanyId, @praad_ManualCompanyId, '04', @Now, 
                @praa_Date, 1
            )
        end
        else
        begin
            -- update the company relationsihp statistics
            UPDATE PRCompanyRelationship
               SET prcr_LastReportedDate = @praa_Date, 
                   prcr_TimesReported = prcr_TimesReported + 1
             WHERE prcr_CompanyRelationshipId = @prcr_CompanyRelationshipId 
        end
    
    END
    ELSE
    BEGIN
       -- determine the Subject Company from the ARTranslation table
       SELECT @SubjectId = prar_CompanyId
       FROM PRARTranslation 
       WHERE prar_CustomerNumber = @praad_ARCustomerId
         AND prar_PRCoCompanyId = @praa_CompanyId
   
    END    

    IF (@SubjectId IS NOT NULL)
    BEGIN
		DECLARE @RatingCompanyId int
		DECLARE @comp_HQId int
		DECLARE @comp_PRType varchar(40)
		SET @RatingCompanyId = @SubjectId
		select @comp_PRType = comp_PRType, @comp_HQId = comp_PRHQId 
		  from company where comp_CompanyId = @SubjectId
		-- if this is a branch, we compare against the branches HQ
		if (@comp_PRType = 'B')
			SET @RatingCompanyId = @comp_HQId
        
        
        
        -- determine if this record should be reviewed by a specialist
        IF (@praad_Amount30to44 > 5000 OR
            @praad_Amount45to60 > 1000 
        )
        BEGIN
            exec usp_CreateException 'AR', @praad_ARAgingDetailId, @praad_CreatedBy, @SubjectId
        END
        ELSE IF (@praad_Amount61Plus > 1000 )
        BEGIN
            -- get the integrity rating, pay rating and the rating numerals
            SELECT @prra_RatingId = prra_RatingId,
                @prra_AssignedRatingNumerals = prra_AssignedRatingNumerals, 
                @prra_IntegrityName = prin_Name,
                @prra_PayRatingName = prpy_Name 
            from vPRCompanyRating 
            where prra_CompanyId = @RatingCompanyId AND prra_Current = 'Y'
            
            IF (@prra_RatingId IS NULL)
            BEGIN
                exec usp_CreateException 'AR', @praad_ARAgingDetailId, @praad_CreatedBy, @SubjectId
            END
            ELSE IF (
                        ( (@prra_IntegrityName not in ('XXX147','XX','X') ) AND  
                          (@prra_PayRatingName not in ('D', 'E', 'F') ) AND  
                          (CHARINDEX('(86)', @prra_AssignedRatingNumerals) = 0) 
                        )
                        OR 
                        ( CHARINDEX('(76)', @prra_AssignedRatingNumerals) > 0 OR
                          CHARINDEX('(27)', @prra_AssignedRatingNumerals) > 0 OR
                          CHARINDEX('(85)', @prra_AssignedRatingNumerals) > 0 OR
                          CHARINDEX('(74)', @prra_AssignedRatingNumerals) > 0 OR
                          CHARINDEX('(124)', @prra_AssignedRatingNumerals) > 0 OR
                          CHARINDEX('(132)', @prra_AssignedRatingNumerals) > 0 
                        )
                    )    
            BEGIN
                exec usp_CreateException 'AR', @praad_ARAgingDetailId, @praad_CreatedBy, @SubjectId
            END
        END
    END

    SET NOCOUNT OFF
END
GO
/* ************************************************************
 * Name:   dbo.trg_PRARTranslation_ins
 * 
 * Table:  PRARTranslation
 * Action: FOR INSERT
 * 
 * Description: INSERT trigger that checks to see if a relationship 
 *              record (04) exists for the prar_PRCoCompanyId
 *              and the prar_CompanyId 
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRARTranslation_ins]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRARTranslation_ins]
GO

CREATE TRIGGER dbo.trg_PRARTranslation_ins
ON PRARTranslation
FOR INSERT AS
BEGIN
    SET NOCOUNT ON
    Declare @Err int
    SET @Err = 0
    Declare @NextRelationshipId int
    Declare @PRRelationshipTableId int
    Declare @UserId int
    Declare @Now datetime

    Declare @prar_CompanyId int
    Declare @prar_PRCoCompanyId int
    Declare @prar_CustomerNumber varchar(15)
    Declare @praad_ARAgingId int
    Declare @cnt int

    Declare @prcr_CompanyRelationshipId int
    Declare @praa_ARAgingId int
    Declare @praa_Date datetime
    
    -- get the Accpac ID value for this entity so we can get the next available Id
    select @PRRelationshipTableId = Bord_TableId from custom_tables where Bord_Caption = 'PRCompanyRelationship'

    -- get the required fields from the inserted record
    SELECT @prar_PRCoCompanyId = prar_PRCoCompanyId,
           @prar_CompanyId = prar_CompanyId,
           @prar_CustomerNumber = prar_CustomerNumber,
           @UserId = prar_CreatedBy 
      from inserted
      
    IF (@prar_PRCoCompanyId IS NOT NULL)
    BEGIN
        -- make sure that the company is actually used on an AR Aging Detail record
        SET @praa_ARAgingId = NULL
        select @praa_ARAgingId = praa_ARAgingId, @praa_Date = praa_Date 
          from PRARAgingDetail 
          Join PRARAging ON praad_ARAgingId = praa_ARAgingId
          Where praa_CompanyId = @prar_CompanyId
            AND praad_ARCustomerId = @prar_CustomerNumber
        
        if (@praa_ARAgingId is not null)
        begin
            -- check if a relationship record already exists
            SET @prcr_CompanyRelationshipId = NULL
            Select @prcr_CompanyRelationshipId = prcr_CompanyRelationshipId
              from PRCompanyRelationship
              where prcr_LeftCompanyId = @prar_CompanyId 
                AND prcr_RightCompanyId = @prar_PRCoCompanyId
                AND prcr_Type = '04'
            If (@prcr_CompanyRelationshipId is NULL)
            begin
                SET @Now = getDate();
                EXEC @NextRelationshipId = crm_next_id @PRRelationshipTableId

                INSERT into PRCompanyRelationship
                ( prcr_CompanyRelationshipId,
                prcr_CreatedBy,prcr_createdDate,prcr_UpdatedBy,prcr_UpdatedDate,prcr_TimeStamp,
                prcr_LeftCompanyId, prcr_RightCompanyId, prcr_type, prcr_EnteredDate,
                prcr_LastReportedDate, prcr_TimesReported
                )  
                VALUES ( 
                    @NextRelationshipId,
                    @UserId,@Now,@UserId,@Now,@Now,  
                    @prar_CompanyId, @prar_PRCoCompanyId, '04', @Now,
                    @praa_Date, 1
                )
            end
            else
            begin
                -- update the company relationsihp statistics
                UPDATE PRCompanyRelationship
                SET prcr_LastReportedDate = @praa_Date, 
                    prcr_TimesReported = prcr_TimesReported + 1
                WHERE prcr_CompanyRelationshipId = @prcr_CompanyRelationshipId 
            end
        end    
    END
    
    SET NOCOUNT OFF
END
GO

/* ************************************************************
 * Name:   dbo.trg_PRTradeReport_ins
 * 
 * Table:  PRTradeReport
 * Action: FOR INSERT
 * 
 * Description: INSERT trigger that checks 
 *              1) to see if a relationship record (01) exists 
 *                 for the prtr_ResponderId and the prtr_SubjectId 
 *              2) to see if the trade report being entered  
 *                 creates any type of exception for the 
 *                 exception queue
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRTradeReport_ins]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRTradeReport_ins]
GO

CREATE TRIGGER dbo.trg_PRTradeReport_ins
ON PRTradeReport
FOR INSERT AS
BEGIN
    SET NOCOUNT ON
    Declare @Err int
    SET @Err = 0
    Declare @NextRelationshipId int
    Declare @PRRelationshipTableId int
    Declare @prcr_CompanyRelationshipId int
    Declare @UserId int
    Declare @Now datetime

    Declare @prtr_TradeReportId int
    Declare @prtr_ResponderId int
    Declare @prtr_SubjectId int
    
    Declare @prtr_IntegrityId int
    Declare @prtr_PayRatingId int
    Declare @prtr_IntegrityWeight int
    Declare @prtr_PayRatingWeight int
    Declare @prtr_IntegrityName varchar (10)
    Declare @prtr_PayRatingName varchar (10)
    Declare @prtr_OutOfBusiness char(1)
    Declare @prtr_Date datetime

    Declare @prra_IntegrityId int
    Declare @prra_PayRatingId int
    Declare @prra_IntegrityName varchar (10)
    Declare @prra_IntegrityWeight int
    Declare @prra_PayRatingWeight int
    Declare @prra_RatingId int

    Declare @cntRatingNumeral smallint
    Declare @cntOutOfBusiness smallint
    
    SET @Now = getDate();

    -- get the required fields from the inserted record
    SELECT @prtr_TradeReportId = prtr_TradeReportId,
           @prtr_ResponderId = prtr_ResponderId,
           @prtr_SubjectId = prtr_SubjectId,
           @prtr_IntegrityId = prtr_IntegrityId,
           @prtr_IntegrityWeight = prin_Weight,
           @prtr_IntegrityName = prin_Name,
           @prtr_PayRatingId = prtr_PayRatingId,
           @prtr_PayRatingWeight = prpy_Weight,
           @prtr_PayRatingName = prpy_Name,
           @prtr_OutOfBusiness = prtr_OutOfBusiness,
           @prtr_Date = prtr_Date,
           @UserId = prtr_CreatedBy 
      from inserted
      LEFT OUTER JOIN PRIntegrityRating ON prtr_IntegrityId = prin_IntegrityRatingId
      LEFT OUTER JOIN PRPayRating ON prtr_PayRatingId = prpy_PayRatingId

    -- check if a relationship record already exists
    SET @prcr_CompanyRelationshipId = NULL
    Select @prcr_CompanyRelationshipId =prcr_CompanyRelationshipId
      from PRCompanyRelationship
      where prcr_LeftCompanyId = @prtr_ResponderId 
        AND prcr_RightCompanyId = @prtr_SubjectId
        AND prcr_Type = '01'
    If (@prcr_CompanyRelationshipId is null)
    begin
        -- get next available Id
        EXEC usp_GetNextId 'PRCompanyRelationship', @NextRelationshipId output

        INSERT into PRCompanyRelationship
        ( prcr_CompanyRelationshipId,
          prcr_CreatedBy,prcr_createdDate,prcr_UpdatedBy,prcr_UpdatedDate,prcr_TimeStamp,
          prcr_LeftCompanyId, prcr_RightCompanyId, prcr_type, prcr_EnteredDate, 
          prcr_LastReportedDate, prcr_TimesReported
          
        )  
        VALUES ( 
            @NextRelationshipId,
            @UserId,@Now,@UserId,@Now,@Now,  
            @prtr_ResponderId, @prtr_SubjectId, '01', @Now, 
            @prtr_Date, 1
        )
    end
    else
    begin
        -- we need to update the company relationsihp statistics
        UPDATE PRCompanyRelationship
        SET prcr_LastReportedDate = @prtr_Date, 
            prcr_TimesReported = prcr_TimesReported + 1
        WHERE prcr_CompanyRelationshipId = @prcr_CompanyRelationshipId 
        
    end

    -- get the current company integrity and pay ratings
	exec usp_CheckCompanyTESException
			@prtr_SubjectId,
			@UserId,
			@prtr_TradeReportId,
			@prtr_IntegrityName,
			@prtr_PayRatingName,
			@prtr_PayRatingWeight,
			@prtr_OutOfBusiness
    
	/*
	 * Business Rule: if two BBID's report a "one X" TES report on each other 
	 * within a six month period, create a task for Rating Analyst to review.
	*/
	-- if a "X" is reported, perform our check.
	IF (@prtr_IntegrityId = 1)
	BEGIN
		declare @Exists bit
		SET @Exists = 0 
		-- look up any trade reports for the subject by the target company
		-- within the last 6 months that have a "X" rating
		select TOP 1 @Exists = 1 from PRTradeReport
		 where prtr_IntegrityId = 1 
           and prtr_ResponderId = @prtr_SubjectId
           and DATEDIFF(month, prtr_Date, @prtr_Date) <= 6
		IF (@Exists = 1)
		Begin
			/* Create a task for the rating analyst for the subject company to review this
			   (rating analyst is the default type for the task creation when no specific 
			   AssignedToUserId is passed; it will be looked up from PRCity
			*/
			Declare @SubjectName varchar(500), @ResponderName varchar(500)
			DECLARE @MsgText varchar(2000)
			SELECT @SubjectName = comp_Name from Company where comp_companyid = @prtr_SubjectId
			SELECT @ResponderName = comp_Name from Company where comp_companyid = @prtr_ResponderId
			SET @MsgText = @SubjectName + '(' +  convert(varchar,@prtr_SubjectId) + ') and ' +
							@ResponderName + '(' +  convert(varchar,@prtr_ResponderId) + ') have ' +
							'reported an Integity Rating of "X" on the other company within the past '+
							'six months.  This should be reviewed.'
			exec usp_CreateTask 
					@StartDateTime = @Now,
					@CreatorUserId = @UserId,
					@TaskNotes = @MsgText,
					@RelatedCompanyId = @prtr_SubjectId,
					@Status = 'Pending'

		End
	END

	-- Look for any previous trade report records within the past 45 days
    -- for the same subject and responder and mark them as duplicates.
	UPDATE PRTradeReport
       SET prtr_Duplicate	= 'Y',
           prtr_UpdatedBy	= @UserId,
           prtr_UpdatedDate = @Now,
           prtr_TimeStamp	= @Now
     WHERE prtr_ResponderID = @prtr_ResponderId
       AND prtr_SubjectID	= @prtr_SubjectId
       AND prtr_Duplicate IS NULL
       AND prtr_Deleted IS NULL
       AND DATEDIFF(day, @prtr_Date, prtr_Date) <= 45
       AND prtr_TradeReportId <> @prtr_TradeReportId;

    SET NOCOUNT OFF
END
Go

/* ************************************************************
 * Name:   dbo.trg_PRBBScore_ins
 * 
 * Table:  PRBBScore
 * Action: FOR INSERT
 * 
 * Description: INSERT trigger for the table performs the  
 *              following tasks:
 *              -  
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRBBScore_ins]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRBBScore_ins]
GO

CREATE TRIGGER [dbo].[trg_PRBBScore_ins]
ON [dbo].[PRBBScore]
FOR INSERT AS
BEGIN
    SET NOCOUNT ON
    
    DECLARE @prbs_BBScoreId int
    DECLARE @prbs_CompanyId int
    DECLARE @UserId int

    DECLARE @prbs_NewBBScore numeric(24,6)
    DECLARE @prbs_OldBBScore numeric(24,6)

    SELECT @prbs_BBScoreId = prbs_BBScoreId,
           @prbs_CompanyId = prbs_CompanyId,
		   @prbs_NewBBScore = prbs_BBScore,
		   @UserId = prbs_UpdatedBy
    FROM inserted 

	-- Update our deviation values.
    SELECT @prbs_OldBBScore = prbs_BBScore
     FROM PRBBScore
    WHERE prbs_BBScoreId != @prbs_BBScoreId 
      AND prbs_CompanyId = @prbs_CompanyId 
      AND prbs_Current = 'Y'

    UPDATE PRBBScore
       SET prbs_Deviation = @prbs_NewBBScore - @prbs_OldBBScore
     WHERE prbs_BBScoreID = @prbs_BBScoreId;

    -- when a new BBScore is entered, the current BBSCore must be set to non-Current
    UPDATE PRBBScore 
    SET prbs_Current = NULL
    WHERE prbs_BBScoreId != @prbs_BBScoreId 
      AND prbs_CompanyId = @prbs_CompanyId 
      AND prbs_Current = 'Y'
	-- Now set the inserted record to current
    UPDATE PRBBScore
       SET prbs_Current = 'Y'
     WHERE prbs_BBScoreID = @prbs_BBScoreId;
	

	-- set request count on current record
	DECLARE @ReqCount smallint
	EXEC @ReqCount = usp_SetRequiredTESRequestCount @prbs_CompanyId

	-- Create the TES and TESDetail records
	if (@ReqCount > 0)
		EXEC usp_CreateTES @prbs_CompanyId, @ReqCount, @UserId
	
    -- now determine an if the current score is an exception
    -- RAO: The values for this function must be passed in because 
    -- from the perspective of a select in the usp, the record will not yet exist
	EXEC usp_DetermineBBScoreException @prbs_CompanyId, 
				@prbs_BBScoreId, @prbs_NewBBScore, @UserId

  
    SET NOCOUNT OFF
END
GO

/* ************************************************************
 * Name:   dbo.trg_PRExceptionQueue_upd
 * 
 * Table:  PRExceptionQueue
 * Action: FOR UPDATE
 * 
 * Description: UPDATE trigger that 
 *              1) checks checks if the preq_status has changed
 *                 and updates the preq_ClosedById and preq_DateClosed
 *                 values
 *              2) 
 *                 
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRExceptionQueue_upd]'))
drop trigger [dbo].[trg_PRExceptionQueue_upd]
GO

CREATE TRIGGER dbo.trg_PRExceptionQueue_upd
ON PRExceptionQueue
FOR UPDATE AS
BEGIN
    SET NOCOUNT ON
    Declare @Err int
    SET @Err = 0
    Declare @Now datetime
    SET @Now = getDate()
    
    Declare @preq_Status varchar(40)
    Declare @preq_ExceptionQueueId int
    Declare @preq_UpdatedBy int

    IF ( Update(preq_Status) )
    Begin
        select  @preq_ExceptionQueueId = preq_ExceptionQueueId , 
                @preq_Status = preq_Status, 
                @preq_UpdatedBy = preq_UpdatedBy 
            from inserted    
        if (@preq_Status = 'C')
        begin
            update PRExceptionQueue 
              set preq_ClosedById = @preq_UpdatedBy,
                  preq_DateClosed = @Now
              where preq_ExceptionQueueId = @preq_ExceptionQueueId    
        end
        else
        begin
            update PRExceptionQueue 
              set preq_ClosedById = NULL,
                  preq_DateClosed = NULL
              where preq_ExceptionQueueId = @preq_ExceptionQueueId    
        end
    End
    
END
Go


/**
	Processes the "Single English" Teleform trade report survey
    response creating a PRTradeReport record.  The insert comes
    from Teleform so the trigger assumes a single record in the
	inserted table.
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRTESResponseSE_insert]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRTESResponseSE_insert]
GO

CREATE TRIGGER [trg_PRTESResponseSE_insert] 
ON [PRTESResponseSE.*]
INSTEAD OF INSERT AS
BEGIN

	DECLARE @Serial_No Numeric(8,0)
	DECLARE @Form_ID Numeric(10,0)	
	DECLARE @Time_Stamp varchar(30)
	DECLARE @Subject_BBID Numeric(6,0)
	DECLARE @Dest_ID Numeric(6,0)
	DECLARE @Integrity_Ability Char(1)
	DECLARE @Pay char(2)
	DECLARE @Deal_Regularly Char(1)
	DECLARE @How_Does_Subject_Firm_Act char(2)
	DECLARE @Cash_Only Numeric(1,0)
	DECLARE @Firm_Price Numeric(1,0)
	DECLARE @On_Consignment Numeric(1,0)
	DECLARE @Other_Terms Numeric(1,0)
	DECLARE @Invoice_On_Ship_Day char(1)
	DECLARE @Payment_Trend char(1)
	DECLARE @How_Long_Dealt char(1)
	DECLARE @How_Recently_Dealt char(1)
	DECLARE @Product_Kickers char(1)
	DECLARE @Pack char(1)
	DECLARE @Encourage_Sales char(1)
	DECLARE @Collect_Remit char(1)
	DECLARE @Credit_Terms char(1)
	DECLARE @High_Credit char(1)
	DECLARE @Amount_Past_Due char(1)
	DECLARE @CSID varchar(30)
	DECLARE @Good_Equipment char(1)
	DECLARE @Claims_Handled_Properly char(1)
	DECLARE @Loads_Per_Year char(1)
	DECLARE @Pays_Freight char(1)
	DECLARE @Reliable_Carriers char(1)
	DECLARE @DontDeal char(1)
	DECLARE @OutOfBusiness char(1)
	DECLARE @Pay_Dispute char(1)
	DECLARE @Dealt1To6 numeric(1,0)
	DECLARE @Dealt7To12 numeric(1,0)
	DECLARE @DealtOver1Year numeric(1,0)
	DECLARE @DealtSeasonal numeric(1,0)

	SELECT @Serial_No				= Serial_No,
			@Form_ID				= Form_ID,
			@Time_Stamp				= Time_Stamp,
			@Subject_BBID			= Subject_BBID,
			@Dest_ID				= Dest_ID,
			@Integrity_Ability		= Integrity_Ability,
			@Pay					= Pay,
			@Deal_Regularly			= Deal_Regularly,
			@How_Does_Subject_Firm_Act = How_Does_Subject_Firm_Act,
			@Cash_Only				= Cash_Only,
			@Firm_Price				= Firm_Price,
			@On_Consignment			= On_Consignment,
			@Other_Terms			= Other_Terms,
			@Invoice_On_Ship_Day	= Invoice_On_Ship_Day,
			@Payment_Trend			= Payment_Trend,
			@How_Recently_Dealt		= How_Recently_Dealt,
			@How_Long_Dealt			= How_Long_Dealt,
			@Product_Kickers		= Product_Kickers,
			@Pack					= Pack,
			@Encourage_Sales		= Encourage_Sales,
			@Collect_Remit			= Collect_Remit,
			@Credit_Terms			= Credit_Terms,
			@High_Credit			= High_Credit,
			@Amount_Past_Due		= Amount_Past_Due,
			@CSID					= CSID,
			@Good_Equipment			= Good_Equipment,
			@Claims_Handled_Properly = Claims_Handled_Properly,
			@Loads_Per_Year			= Loads_Per_Year,
			@Pays_Freight			= Pays_Freight,
			@Reliable_Carriers		= Reliable_Carriers,
			@DontDeal				= DontDeal,
			@OutOfBusiness			= OutOfBusiness,
			@Pay_Dispute			= Pay_Dispute,
			@Dealt1To6				= Dealt1To6,
			@Dealt7To12				= Dealt7To12,
			@DealtOver1Year			= DealtOver1Year,
			@DealtSeasonal			= DealtSeasonal
		FROM inserted;

	EXEC usp_ProcessTESResponse 
		@Serial_No,
		@Form_ID,
		@Time_Stamp,
		@Subject_BBID,
		@Dest_ID,
		@Integrity_Ability,
		@Pay ,
		@Deal_Regularly,
		@How_Does_Subject_Firm_Act,
		@Cash_Only,
		@Firm_Price,
		@On_Consignment,
		@Other_Terms,
		@Invoice_On_Ship_Day,
		@Payment_Trend,
		@How_Long_Dealt,
		@How_Recently_Dealt,
		@Product_Kickers,
		@Pack,
		@Encourage_Sales,
		@Collect_Remit,
		@Credit_Terms,
		@High_Credit,
		@Amount_Past_Due,
		@CSID,
		@Good_Equipment,
		@Claims_Handled_Properly,
		@Loads_Per_Year,
		@Pays_Freight,
		@Reliable_Carriers,
		@DontDeal,
		@OutOfBusiness,
		@Pay_Dispute,
		@Dealt1To6,
		@Dealt7To12,
		@DealtOver1Year,
		@DealtSeasonal;
END
Go



/**
	Processes the "Multiple English" Teleform trade report survey
    response creating a PRTradeReport record.  The insert comes
    from Teleform so the trigger assumes a single record in the
	inserted table.
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRTESResponseME_insert]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRTESResponseME_insert]
GO

CREATE TRIGGER [trg_PRTESResponseME_insert] 
ON [PRTESResponseME.*]
INSTEAD OF INSERT AS
BEGIN

	DECLARE @Serial_No Numeric(8,0)
	DECLARE @Form_ID Numeric(10,0)	
	DECLARE @Time_Stamp varchar(30)
	DECLARE @Dest_ID Numeric(6,0)
	DECLARE @CSID varchar(30)

	DECLARE @BBID_1 numeric(6,0)
	DECLARE @Integrity_1 numeric(1,0)
	DECLARE @Pay_1 char(2)
	DECLARE @DontDeal_1 char(1)
	DECLARE @OutOfBusiness_1 char(1)
	DECLARE @High_Credit_1 char(1)

	DECLARE @BBID_2 numeric(6,0)
	DECLARE @Integrity_2 numeric(1,0)
	DECLARE @Pay_2 char(2)
	DECLARE @DontDeal_2 char(1)
	DECLARE @OutOfBusiness_2 char(1)
	DECLARE @High_Credit_2 char(1)

	DECLARE @BBID_3 numeric(6,0)
	DECLARE @Integrity_3 numeric(1,0)
	DECLARE @Pay_3 char(2)
	DECLARE @DontDeal_3 char(1)
	DECLARE @OutOfBusiness_3 char(1)
	DECLARE @High_Credit_3 char(1)

	DECLARE @BBID_4 numeric(6,0)
	DECLARE @Integrity_4 numeric(1,0)
	DECLARE @Pay_4 char(2)
	DECLARE @DontDeal_4 char(1)
	DECLARE @OutOfBusiness_4 char(1)
	DECLARE @High_Credit_4 char(1)

	DECLARE @BBID_5 numeric(6,0)
	DECLARE @Integrity_5 numeric(1,0)
	DECLARE @Pay_5 char(2)
	DECLARE @DontDeal_5 char(1)
	DECLARE @OutOfBusiness_5 char(1)
	DECLARE @High_Credit_5 char(1)

	DECLARE @BBID_6 numeric(6,0)
	DECLARE @Integrity_6 numeric(1,0)
	DECLARE @Pay_6 char(2)
	DECLARE @DontDeal_6 char(1)
	DECLARE @OutOfBusiness_6 char(1)
	DECLARE @High_Credit_6 char(1)

	DECLARE @BBID_7 numeric(6,0)
	DECLARE @Integrity_7 numeric(1,0)
	DECLARE @Pay_7 char(2)
	DECLARE @DontDeal_7 char(1)
	DECLARE @OutOfBusiness_7 char(1)
	DECLARE @High_Credit_7 char(1)

	DECLARE @BBID_8 numeric(6,0)
	DECLARE @Integrity_8 numeric(1,0)
	DECLARE @Pay_8 char(2)
	DECLARE @DontDeal_8 char(1)
	DECLARE @OutOfBusiness_8 char(1)
	DECLARE @High_Credit_8 char(1)

	SELECT @Serial_No				= Serial_No,
			@Form_ID				= Form_ID,
			@Time_Stamp				= Time_Stamp,
			@Dest_ID				= Dest_ID,
			@CSID					= CSID,
			@BBID_1					= BBID_1,
			@Integrity_1			= INTEG_1,
			@Pay_1					= PAY_1,
			@DontDeal_1				= DONTDEAL_1,
			@OutOfBusiness_1		= OUTOFBUSINESS_1,
			@High_Credit_1			= HIGH_CREDIT_1,
			@BBID_2					= BBID_2,
			@Integrity_2			= INTEG_2,
			@Pay_2					= PAY_2,
			@DontDeal_2				= DONTDEAL_2,
			@OutOfBusiness_2		= OUTOFBUSINESS_2,
			@High_Credit_2			= HIGH_CREDIT_2,
			@BBID_3					= BBID_3,
			@Integrity_3			= INTEG_3,
			@Pay_3					= PAY_3,
			@DontDeal_3				= DONTDEAL_3,
			@OutOfBusiness_3		= OUTOFBUSINESS_3,
			@High_Credit_3			= HIGH_CREDIT_3,
			@BBID_4					= BBID_4,
			@Integrity_4			= INTEG_4,
			@Pay_4					= PAY_4,
			@DontDeal_4				= DONTDEAL_4,
			@OutOfBusiness_4		= OUTOFBUSINESS_4,
			@High_Credit_4			= HIGH_CREDIT_4,
			@BBID_5					= BBID_5,
			@Integrity_5			= INTEG_5,
			@Pay_5					= PAY_5,
			@DontDeal_5				= DONTDEAL_5,
			@OutOfBusiness_5		= OUTOFBUSINESS_5,
			@High_Credit_5			= HIGH_CREDIT_5,
			@BBID_6					= BBID_6,
			@Integrity_6			= INTEG_6,
			@Pay_6					= PAY_6,
			@DontDeal_6				= DONTDEAL_6,
			@OutOfBusiness_6		= OUTOFBUSINESS_6,
			@High_Credit_6			= HIGH_CREDIT_6,
			@BBID_7					= BBID_7,
			@Integrity_7			= INTEG_7,
			@Pay_7					= PAY_7,
			@DontDeal_7				= DONTDEAL_7,
			@OutOfBusiness_7		= OUTOFBUSINESS_7,
			@High_Credit_7			= HIGH_CREDIT_7,
			@BBID_8					= BBID_8,
			@Integrity_8			= INTEG_8,
			@Pay_8					= PAY_8,
			@DontDeal_8				= DONTDEAL_8,
			@OutOfBusiness_8		= OUTOFBUSINESS_8,
			@High_Credit_8			= HIGH_CREDIT_8
		FROM inserted;

	EXEC usp_ProcessTESResponse 
		@Serial_No				= @Serial_No,
		@Form_ID			= @Form_ID,
		@Time_Stamp			= @Time_Stamp,
		@Dest_ID			= @Dest_ID,
		@CSID				= @CSID,
		@Subject_BBID		= @BBID_1,
		@Integrity_Ability	= @Integrity_1,
		@Pay				= @Pay_1,
		@High_Credit		= @High_Credit_1,
		@DontDeal			= @DontDeal_1,
		@OutOfBusiness		= @OutOfBusiness_1;

	IF @BBID_2 IS NOT NULL BEGIN
		EXEC usp_ProcessTESResponse 
			@Serial_No				= @Serial_No,
			@Form_ID			= @Form_ID,
			@Time_Stamp			= @Time_Stamp,
			@Dest_ID			= @Dest_ID,
			@CSID				= @CSID,
			@Subject_BBID		= @BBID_2,
			@Integrity_Ability	= @Integrity_2,
			@Pay				= @Pay_2,
			@High_Credit		= @High_Credit_2,
			@DontDeal			= @DontDeal_2,
			@OutOfBusiness		= @OutOfBusiness_2;
	END

	IF @BBID_3 IS NOT NULL BEGIN
		EXEC usp_ProcessTESResponse 
			@Serial_No				= @Serial_No,
			@Form_ID			= @Form_ID,
			@Time_Stamp			= @Time_Stamp,
			@Dest_ID			= @Dest_ID,
			@CSID				= @CSID,
			@Subject_BBID		= @BBID_3,
			@Integrity_Ability	= @Integrity_3,
			@Pay				= @Pay_3,
			@High_Credit		= @High_Credit_3,
			@DontDeal			= @DontDeal_3,
			@OutOfBusiness		= @OutOfBusiness_3;
	END


	IF @BBID_4 IS NOT NULL BEGIN
		EXEC usp_ProcessTESResponse 
			@Serial_No				= @Serial_No,
			@Form_ID			= @Form_ID,
			@Time_Stamp			= @Time_Stamp,
			@Dest_ID			= @Dest_ID,
			@CSID				= @CSID,
			@Subject_BBID		= @BBID_4,
			@Integrity_Ability	= @Integrity_4,
			@Pay				= @Pay_4,
			@High_Credit		= @High_Credit_4,
			@DontDeal			= @DontDeal_4,
			@OutOfBusiness		= @OutOfBusiness_4;
	END


	IF @BBID_5 IS NOT NULL BEGIN
		EXEC usp_ProcessTESResponse 
			@Serial_No				= @Serial_No,
			@Form_ID			= @Form_ID,
			@Time_Stamp			= @Time_Stamp,
			@Dest_ID			= @Dest_ID,
			@CSID				= @CSID,
			@Subject_BBID		= @BBID_5,
			@Integrity_Ability	= @Integrity_5,
			@Pay				= @Pay_5,
			@High_Credit		= @High_Credit_5,
			@DontDeal			= @DontDeal_5,
			@OutOfBusiness		= @OutOfBusiness_5;
	END


	IF @BBID_6 IS NOT NULL BEGIN
		EXEC usp_ProcessTESResponse 
			@Serial_No				= @Serial_No,
			@Form_ID			= @Form_ID,
			@Time_Stamp			= @Time_Stamp,
			@Dest_ID			= @Dest_ID,
			@CSID				= @CSID,
			@Subject_BBID		= @BBID_6,
			@Integrity_Ability	= @Integrity_6,
			@Pay				= @Pay_6,
			@High_Credit		= @High_Credit_6,
			@DontDeal			= @DontDeal_6,
			@OutOfBusiness		= @OutOfBusiness_6;
	END


	IF @BBID_7 IS NOT NULL BEGIN
		EXEC usp_ProcessTESResponse 
			@Serial_No				= @Serial_No,
			@Form_ID			= @Form_ID,
			@Time_Stamp			= @Time_Stamp,
			@Dest_ID			= @Dest_ID,
			@CSID				= @CSID,
			@Subject_BBID		= @BBID_7,
			@Integrity_Ability	= @Integrity_7,
			@Pay				= @Pay_7,
			@High_Credit		= @High_Credit_7,
			@DontDeal			= @DontDeal_7,
			@OutOfBusiness		= @OutOfBusiness_7;
	END


	IF @BBID_8 IS NOT NULL BEGIN
		EXEC usp_ProcessTESResponse 
			@Serial_No				= @Serial_No,
			@Form_ID			= @Form_ID,
			@Time_Stamp			= @Time_Stamp,
			@Dest_ID			= @Dest_ID,
			@CSID				= @CSID,
			@Subject_BBID		= @BBID_8,
			@Integrity_Ability	= @Integrity_8,
			@Pay				= @Pay_8,
			@High_Credit		= @High_Credit_8,
			@DontDeal			= @DontDeal_8,
			@OutOfBusiness		= @OutOfBusiness_8;
	END


END
Go


/**
	Processes the "Single Spanish" Teleform trade report survey
    response creating a PRTradeReport record.  The insert comes
    from Teleform so the trigger assumes a single record in the
	inserted table.
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRTESResponseSS_insert]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRTESResponseSS_insert]
GO

CREATE TRIGGER [trg_PRTESResponseSS_insert] 
ON [PRTESResponseSS.*]
INSTEAD OF INSERT AS
BEGIN

	DECLARE @Serial_No numeric(8,0)
	DECLARE @Form_ID numeric(10,0)	
	DECLARE @Time_Stamp varchar(30)
	DECLARE @Subject_BBID numeric(6,0)
	DECLARE @Dest_ID numeric(6,0)
	DECLARE @Integrity_Ability char(1)
	DECLARE @Pay char(2)
	DECLARE @Deal_Regularly char(1)
	DECLARE @Payment_Trend char(1)
	DECLARE @How_Long_Dealt char(1)
	DECLARE @How_Recently_Dealt char(1)
	DECLARE @Credit_Terms char(1)
	DECLARE @High_Credit char(1)
	DECLARE @Amount_Past_Due char(1)
	DECLARE @CSID varchar(30)

	SELECT @Serial_No				= Serial_No,
			@Form_ID				= Form_ID,
			@Time_Stamp				= Time_Stamp,
			@Subject_BBID			= Subject_BBID,
			@Dest_ID				= Dest_ID,
			@Integrity_Ability		= Integrity_Ability,
			@Pay					= Pay,
			@Deal_Regularly			= Deal_Regularly,
			@Payment_Trend			= Payment_Trend,
			@How_Recently_Dealt		= How_Recently_Dealt,
			@How_Long_Dealt			= How_Long_Dealt,
			@High_Credit			= High_Credit,
			@Amount_Past_Due		= Amount_Past_Due,
			@CSID					= CSID
		FROM inserted;

	EXEC usp_ProcessTESResponse 
		@Serial_No			= @Serial_No,
		@Form_ID			= @Form_ID,
		@Time_Stamp			= @Time_Stamp,
		@Subject_BBID		= @Subject_BBID,
		@Dest_ID			= @Dest_ID,
		@Integrity_Ability	= @Integrity_Ability,
		@Pay				= @Pay,
		@Deal_Regularly		= @Deal_Regularly,
		@How_Long_Dealt		= @How_Long_Dealt,
		@How_Recently_Dealt = @How_Recently_Dealt,
		@High_Credit		= @High_Credit,
		@Amount_Past_Due	= @Amount_Past_Due,
		@CSID				= @CSID;
END
Go



/**
	Processes the "Multiple Spanish" Teleform trade report survey
    response creating a PRTradeReport record.  The insert comes
    from Teleform so the trigger assumes a single record in the
	inserted table.
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRTESResponseMS_insert]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRTESResponseMS_insert]
GO

CREATE TRIGGER [trg_PRTESResponseMS_insert] 
ON [PRTESResponseMS.*]
INSTEAD OF INSERT AS
BEGIN

	DECLARE @Serial_No Numeric(8,0)
	DECLARE @Form_ID Numeric(10,0)	
	DECLARE @Time_Stamp varchar(30)
	DECLARE @Dest_ID Numeric(6,0)
	DECLARE @CSID varchar(30)

	DECLARE @BBID_1 numeric(6,0)
	DECLARE @Integrity_1 numeric(1,0)
	DECLARE @Pay_1 char(2)
	DECLARE @DontDeal_1 char(1)
	DECLARE @OutOfBusiness_1 char(1)
	DECLARE @High_Credit_1 char(1)

	DECLARE @BBID_2 numeric(6,0)
	DECLARE @Integrity_2 numeric(1,0)
	DECLARE @Pay_2 char(2)
	DECLARE @DontDeal_2 char(1)
	DECLARE @OutOfBusiness_2 char(1)
	DECLARE @High_Credit_2 char(1)

	DECLARE @BBID_3 numeric(6,0)
	DECLARE @Integrity_3 numeric(1,0)
	DECLARE @Pay_3 char(2)
	DECLARE @DontDeal_3 char(1)
	DECLARE @OutOfBusiness_3 char(1)
	DECLARE @High_Credit_3 char(1)

	DECLARE @BBID_4 numeric(6,0)
	DECLARE @Integrity_4 numeric(1,0)
	DECLARE @Pay_4 char(2)
	DECLARE @DontDeal_4 char(1)
	DECLARE @OutOfBusiness_4 char(1)
	DECLARE @High_Credit_4 char(1)

	DECLARE @BBID_5 numeric(6,0)
	DECLARE @Integrity_5 numeric(1,0)
	DECLARE @Pay_5 char(2)
	DECLARE @DontDeal_5 char(1)
	DECLARE @OutOfBusiness_5 char(1)
	DECLARE @High_Credit_5 char(1)

	DECLARE @BBID_6 numeric(6,0)
	DECLARE @Integrity_6 numeric(1,0)
	DECLARE @Pay_6 char(2)
	DECLARE @DontDeal_6 char(1)
	DECLARE @OutOfBusiness_6 char(1)
	DECLARE @High_Credit_6 char(1)

	DECLARE @BBID_7 numeric(6,0)
	DECLARE @Integrity_7 numeric(1,0)
	DECLARE @Pay_7 char(2)
	DECLARE @DontDeal_7 char(1)
	DECLARE @OutOfBusiness_7 char(1)
	DECLARE @High_Credit_7 char(1)

	DECLARE @BBID_8 numeric(6,0)
	DECLARE @Integrity_8 numeric(1,0)
	DECLARE @Pay_8 char(2)
	DECLARE @DontDeal_8 char(1)
	DECLARE @OutOfBusiness_8 char(1)
	DECLARE @High_Credit_8 char(1)

	SELECT @Serial_No				= Serial_No,
			@Form_ID				= Form_ID,
			@Time_Stamp				= Time_Stamp,
			@Dest_ID				= Dest_ID,
			@CSID					= CSID,
			@BBID_1					= BBID_1,
			@Integrity_1			= INTEG_1,
			@Pay_1					= PAY_1,
			@DontDeal_1				= DONTDEAL_1,
			@OutOfBusiness_1		= OUTOFBUSINESS_1,
			@High_Credit_1			= HIGH_CREDIT_1,
			@BBID_2					= BBID_2,
			@Integrity_2			= INTEG_2,
			@Pay_2					= PAY_2,
			@DontDeal_2				= DONTDEAL_2,
			@OutOfBusiness_2		= OUTOFBUSINESS_2,
			@High_Credit_2			= HIGH_CREDIT_2,
			@BBID_3					= BBID_3,
			@Integrity_3			= INTEG_3,
			@Pay_3					= PAY_3,
			@DontDeal_3				= DONTDEAL_3,
			@OutOfBusiness_3		= OUTOFBUSINESS_3,
			@High_Credit_3			= HIGH_CREDIT_3,
			@BBID_4					= BBID_4,
			@Integrity_4			= INTEG_4,
			@Pay_4					= PAY_4,
			@DontDeal_4				= DONTDEAL_4,
			@OutOfBusiness_4		= OUTOFBUSINESS_4,
			@High_Credit_4			= HIGH_CREDIT_4,
			@BBID_5					= BBID_5,
			@Integrity_5			= INTEG_5,
			@Pay_5					= PAY_5,
			@DontDeal_5				= DONTDEAL_5,
			@OutOfBusiness_5		= OUTOFBUSINESS_5,
			@High_Credit_5			= HIGH_CREDIT_5,
			@BBID_6					= BBID_6,
			@Integrity_6			= INTEG_6,
			@Pay_6					= PAY_6,
			@DontDeal_6				= DONTDEAL_6,
			@OutOfBusiness_6		= OUTOFBUSINESS_6,
			@High_Credit_6			= HIGH_CREDIT_6,
			@BBID_7					= BBID_7,
			@Integrity_7			= INTEG_7,
			@Pay_7					= PAY_7,
			@DontDeal_7				= DONTDEAL_7,
			@OutOfBusiness_7		= OUTOFBUSINESS_7,
			@High_Credit_7			= HIGH_CREDIT_7,
			@BBID_8					= BBID_8,
			@Integrity_8			= INTEG_8,
			@Pay_8					= PAY_8,
			@DontDeal_8				= DONTDEAL_8,
			@OutOfBusiness_8		= OUTOFBUSINESS_8,
			@High_Credit_8			= HIGH_CREDIT_8
		FROM inserted;

	EXEC usp_ProcessTESResponse 
		@Serial_No			= @Serial_No,
		@Form_ID			= @Form_ID,
		@Time_Stamp			= @Time_Stamp,
		@Dest_ID			= @Dest_ID,
		@CSID				= @CSID,
		@Subject_BBID		= @BBID_1,
		@Integrity_Ability	= @Integrity_1,
		@Pay				= @Pay_1,
		@High_Credit		= @High_Credit_1,
		@DontDeal			= @DontDeal_1,
		@OutOfBusiness		= @OutOfBusiness_1;

	IF @BBID_2 IS NOT NULL BEGIN
		EXEC usp_ProcessTESResponse 
			@Serial_No			= @Serial_No,
			@Form_ID			= @Form_ID,
			@Time_Stamp			= @Time_Stamp,
			@Dest_ID			= @Dest_ID,
			@CSID				= @CSID,
			@Subject_BBID		= @BBID_2,
			@Integrity_Ability	= @Integrity_2,
			@Pay				= @Pay_2,
			@High_Credit		= @High_Credit_2,
			@DontDeal			= @DontDeal_2,
			@OutOfBusiness		= @OutOfBusiness_2;
	END

	IF @BBID_3 IS NOT NULL BEGIN
		EXEC usp_ProcessTESResponse 
			@Serial_No			= @Serial_No,
			@Form_ID			= @Form_ID,
			@Time_Stamp			= @Time_Stamp,
			@Dest_ID			= @Dest_ID,
			@CSID				= @CSID,
			@Subject_BBID		= @BBID_3,
			@Integrity_Ability	= @Integrity_3,
			@Pay				= @Pay_3,
			@High_Credit		= @High_Credit_3,
			@DontDeal			= @DontDeal_3,
			@OutOfBusiness		= @OutOfBusiness_3;
	END


	IF @BBID_4 IS NOT NULL BEGIN
		EXEC usp_ProcessTESResponse 
			@Serial_No			= @Serial_No,
			@Form_ID			= @Form_ID,
			@Time_Stamp			= @Time_Stamp,
			@Dest_ID			= @Dest_ID,
			@CSID				= @CSID,
			@Subject_BBID		= @BBID_4,
			@Integrity_Ability	= @Integrity_4,
			@Pay				= @Pay_4,
			@High_Credit		= @High_Credit_4,
			@DontDeal			= @DontDeal_4,
			@OutOfBusiness		= @OutOfBusiness_4;
	END


	IF @BBID_5 IS NOT NULL BEGIN
		EXEC usp_ProcessTESResponse 
			@Serial_No			= @Serial_No,
			@Form_ID			= @Form_ID,
			@Time_Stamp			= @Time_Stamp,
			@Dest_ID			= @Dest_ID,
			@CSID				= @CSID,
			@Subject_BBID		= @BBID_5,
			@Integrity_Ability	= @Integrity_5,
			@Pay				= @Pay_5,
			@High_Credit		= @High_Credit_5,
			@DontDeal			= @DontDeal_5,
			@OutOfBusiness		= @OutOfBusiness_5;
	END


	IF @BBID_6 IS NOT NULL BEGIN
		EXEC usp_ProcessTESResponse 
			@Serial_No			= @Serial_No,
			@Form_ID			= @Form_ID,
			@Time_Stamp			= @Time_Stamp,
			@Dest_ID			= @Dest_ID,
			@CSID				= @CSID,
			@Subject_BBID		= @BBID_6,
			@Integrity_Ability	= @Integrity_6,
			@Pay				= @Pay_6,
			@High_Credit		= @High_Credit_6,
			@DontDeal			= @DontDeal_6,
			@OutOfBusiness		= @OutOfBusiness_6;
	END


	IF @BBID_7 IS NOT NULL BEGIN
		EXEC usp_ProcessTESResponse 
			@Serial_No			= @Serial_No,
			@Form_ID			= @Form_ID,
			@Time_Stamp			= @Time_Stamp,
			@Dest_ID			= @Dest_ID,
			@CSID				= @CSID,
			@Subject_BBID		= @BBID_7,
			@Integrity_Ability	= @Integrity_7,
			@Pay				= @Pay_7,
			@High_Credit		= @High_Credit_7,
			@DontDeal			= @DontDeal_7,
			@OutOfBusiness		= @OutOfBusiness_7;
	END


	IF @BBID_8 IS NOT NULL BEGIN
		EXEC usp_ProcessTESResponse 
			@Serial_No			= @Serial_No,
			@Form_ID			= @Form_ID,
			@Time_Stamp			= @Time_Stamp,
			@Dest_ID			= @Dest_ID,
			@CSID				= @CSID,
			@Subject_BBID		= @BBID_8,
			@Integrity_Ability	= @Integrity_8,
			@Pay				= @Pay_8,
			@High_Credit		= @High_Credit_8,
			@DontDeal			= @DontDeal_8,
			@OutOfBusiness		= @OutOfBusiness_8;
	END
END
Go



/* ************************************************************
 * Name:   dbo.[trg_Address_Link_BBSInterface_delete]
 * 
 * Table:  Address_Link
 * Action: FOR DELETE
 * 
 * Description: Adds an entry to the BBSInterface 
 *              DeleteDetection table for each record deleted.
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_Address_Link_BBSInterface_delete]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_Address_Link_BBSInterface_delete]
GO

CREATE TRIGGER dbo.[trg_Address_Link_BBSInterface_delete] 
	ON Address_Link FOR DELETE AS
BEGIN
	SET NOCOUNT ON;

	-- Write a record 
	INSERT INTO BBSInterface.dbo.DeleteDetection (BBID,DeleteDateTime)
	SELECT adli_CompanyID, GetDate() FROM deleted;
END
Go


/* ************************************************************
 * Name:   dbo.[trg_PRCompanyClassification_BBSInterface_delete]
 * 
 * Table:  PRCompanyClassification
 * Action: FOR DELETE
 * 
 * Description: Adds an entry to the BBSInterface 
 *              DeleteDetection table for each record deleted.
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRCompanyClassification_BBSInterface_delete]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRCompanyClassification_BBSInterface_delete]
GO

CREATE TRIGGER dbo.[trg_PRCompanyClassification_BBSInterface_delete] 
	ON PRCompanyClassification FOR DELETE AS
BEGIN
	SET NOCOUNT ON;

	-- Write a record 
	INSERT INTO BBSInterface.dbo.DeleteDetection (BBID,DeleteDateTime)
	SELECT prc2_CompanyID, GetDate() FROM deleted;
END
Go

/* ************************************************************
 * Name:   dbo.[trg_PRCompanyCommodityAttribute_BBSInterface_delete]
 * 
 * Table:  PRCompanyCommodityAttribute
 * Action: FOR DELETE
 * 
 * Description: Adds an entry to the BBSInterface 
 *              DeleteDetection table for each record deleted.
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRCompanyCommodityAttribute_BBSInterface_delete]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRCompanyCommodityAttribute_BBSInterface_delete]
GO

CREATE TRIGGER dbo.[trg_PRCompanyCommodityAttribute_BBSInterface_delete] 
	ON PRCompanyCommodityAttribute FOR DELETE AS
BEGIN
	SET NOCOUNT ON;

	-- Write a record 
	INSERT INTO BBSInterface.dbo.DeleteDetection (BBID,DeleteDateTime)
	SELECT prcca_CompanyID, GetDate() FROM deleted;
END
GO



/* ************************************************************
 * Name:   dbo.[trg_Company_BBSInterface_insert]
 * 
 * Table:  Company
 * Action: FOR INSERT
 * 
 * Description: Adds an entry to the BBSInterface 
 *              MAS90ChangeDetection table for each record inserted.
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_Company_BBSInterface_insert]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_Company_BBSInterface_insert]
GO

CREATE TRIGGER dbo.[trg_Company_BBSInterface_insert] 
	ON Company FOR INSERT AS
BEGIN
	SET NOCOUNT ON;

	-- Write a record 
	INSERT INTO BBSInterface.dbo.MAS90ChangeDetection (BBID,ChangeDateTime)
	SELECT comp_CompanyID, GetDate() FROM inserted;

	SET NOCOUNT OFF  
END
Go


/* ************************************************************
 * Name:   dbo.[trg_Company_BBSInterface_update]
 * 
 * Table:  Company
 * Action: FOR INSERT
 * 
 * Description: Adds an entry to the BBSInterface 
 *              MAS90ChangeDetection table for each record inserted.
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_Company_BBSInterface_update]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_Company_BBSInterface_update]
GO

CREATE TRIGGER dbo.[trg_Company_BBSInterface_update] 
	ON Company FOR UPDATE AS
BEGIN
Set NoCount On

DECLARE @iChangeCount as int;
DECLARE @iBBID as int;
DECLARE @iCreateRecord as int;
DECLARE @szOldValue as varchar(500);
DECLARE @szNewValue as varchar(500);

-- This trigger gets fired for every updated statement
-- regardless if any rows are actually updated.
SELECT @iChangeCount = count(1) from inserted;
If @iChangeCount > 0
BEGIN

	SET @iCreateRecord = 0
	SELECT @iBBID = comp_CompanyID from inserted;

	SELECT @szOldValue = Cast(comp_PRBookTradestyle as varchar(500)) from deleted;
	SELECT @szNewValue = Cast(comp_PRBookTradestyle as varchar(500)) from inserted;
	IF (dbo.ufn_AreValuesEqual(@szOldValue, @szNewValue) = 0) BEGIN
		SET @iCreateRecord = 1
	END


	SELECT @szOldValue = Cast(comp_PRCorrTradestyle as varchar(500)) from deleted;
	SELECT @szNewValue = Cast(comp_PRCorrTradestyle as varchar(500)) from inserted;
	IF (dbo.ufn_AreValuesEqual(@szOldValue, @szNewValue) = 0) BEGIN
		SET @iCreateRecord = 1
	END

	SELECT @szOldValue = Cast(comp_PRListingCityId as varchar(500)) from deleted;
	SELECT @szNewValue = Cast(comp_PRListingCityId as varchar(500)) from inserted;
	IF (dbo.ufn_AreValuesEqual(@szOldValue, @szNewValue) = 0) BEGIN
		SET @iCreateRecord = 1
	END

	IF (@iCreateRecord = 1) BEGIN
		INSERT INTO BBSInterface.dbo.MAS90ChangeDetection (BBID,ChangeDateTime)
		VALUES (@iBBID, GetDate());
	END

END

SET NOCOUNT OFF 
END
Go



/* ************************************************************
 * Name:   dbo.[trg_Address_BBSInterface_update]
 * 
 * Table:  Company
 * Action: FOR INSERT
 * 
 * Description: Adds an entry to the BBSInterface 
 *              MAS90ChangeDetection table for each record inserted.
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_Address_BBSInterface_update]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_Address_BBSInterface_update]
GO

CREATE TRIGGER dbo.[trg_Address_BBSInterface_update] 
	ON Address FOR UPDATE AS
BEGIN
Set NoCount On

DECLARE @iChangeCount as int;
DECLARE @iBBID as int;
DECLARE @iAddressID as int;
DECLARE @iCreateRecord as int;
DECLARE @szOldValue as varchar(500);
DECLARE @szNewValue as varchar(500);

-- This trigger gets fired for every updated statement
-- regardless if any rows are actually updated.
SELECT @iChangeCount = count(1) from inserted;
If @iChangeCount > 0
BEGIN

	SELECT @iAddressID = addr_AddressID from inserted;

	-- See if this is a billing address
	SELECT @iBBID = adli_CompanyID
      FROM Address_Link
     WHERE adli_AddressID = @iAddressID
       AND adli_PRDefaultBilling = 'Y';
	

	IF @iBBID IS NOT NULL BEGIN
		SET @iCreateRecord = 0


		SELECT @szOldValue = Cast(Addr_Address1 as varchar(500)) from deleted;
		SELECT @szNewValue = Cast(Addr_Address1 as varchar(500)) from inserted;
		IF (dbo.ufn_AreValuesEqual(@szOldValue, @szNewValue) = 0) BEGIN
			SET @iCreateRecord = 1
		END

		SELECT @szOldValue = Cast(Addr_Address2 as varchar(500)) from deleted;
		SELECT @szNewValue = Cast(Addr_Address2 as varchar(500)) from inserted;
		IF (dbo.ufn_AreValuesEqual(@szOldValue, @szNewValue) = 0) BEGIN
			SET @iCreateRecord = 1
		END

		SELECT @szOldValue = Cast(Addr_Address3 as varchar(500)) from deleted;
		SELECT @szNewValue = Cast(Addr_Address3 as varchar(500)) from inserted;
		IF (dbo.ufn_AreValuesEqual(@szOldValue, @szNewValue) = 0) BEGIN
			SET @iCreateRecord = 1
		END

		SELECT @szOldValue = Cast(Addr_Address4 as varchar(500)) from deleted;
		SELECT @szNewValue = Cast(Addr_Address5 as varchar(500)) from inserted;
		IF (dbo.ufn_AreValuesEqual(@szOldValue, @szNewValue) = 0) BEGIN
			SET @iCreateRecord = 1
		END


		SELECT @szOldValue = Cast(Addr_Address5 as varchar(500)) from deleted;
		SELECT @szNewValue = Cast(Addr_Address5 as varchar(500)) from inserted;
		IF (dbo.ufn_AreValuesEqual(@szOldValue, @szNewValue) = 0) BEGIN
			SET @iCreateRecord = 1
		END


		SELECT @szOldValue = Cast(Addr_City as varchar(500)) from deleted;
		SELECT @szNewValue = Cast(Addr_City as varchar(500)) from inserted;
		IF (dbo.ufn_AreValuesEqual(@szOldValue, @szNewValue) = 0) BEGIN
			SET @iCreateRecord = 1
		END

		SELECT @szOldValue = Cast(Addr_State as varchar(500)) from deleted;
		SELECT @szNewValue = Cast(Addr_State as varchar(500)) from inserted;
		IF (dbo.ufn_AreValuesEqual(@szOldValue, @szNewValue) = 0) BEGIN
			SET @iCreateRecord = 1
		END

		SELECT @szOldValue = Cast(Addr_PostCode as varchar(500)) from deleted;
		SELECT @szNewValue = Cast(Addr_PostCode as varchar(500)) from inserted;
		IF (dbo.ufn_AreValuesEqual(@szOldValue, @szNewValue) = 0) BEGIN
			SET @iCreateRecord = 1
		END

		SELECT @szOldValue = Cast(Addr_Country as varchar(500)) from deleted;
		SELECT @szNewValue = Cast(Addr_Country as varchar(500)) from inserted;
		IF (dbo.ufn_AreValuesEqual(@szOldValue, @szNewValue) = 0) BEGIN
			SET @iCreateRecord = 1
		END

		SELECT @szOldValue = Cast(addr_PRAttentionLineCustom as varchar(500)) from deleted;
		SELECT @szNewValue = Cast(addr_PRAttentionLineCustom as varchar(500)) from inserted;
		IF (dbo.ufn_AreValuesEqual(@szOldValue, @szNewValue) = 0) BEGIN
			SET @iCreateRecord = 1
		END

		SELECT @szOldValue = Cast(addr_PRAttentionLinePersonId as varchar(500)) from deleted;
		SELECT @szNewValue = Cast(addr_PRAttentionLinePersonId as varchar(500)) from inserted;
		IF (dbo.ufn_AreValuesEqual(@szOldValue, @szNewValue) = 0) BEGIN
			SET @iCreateRecord = 1
		END

		IF (@iCreateRecord = 1) BEGIN
			INSERT INTO BBSInterface.dbo.MAS90ChangeDetection (BBID,ChangeDateTime)
			VALUES (@iBBID, GetDate());
		END
	END -- Is this a billind address?
END

SET NOCOUNT OFF 
END
Go


/*
	Ensures only the maximum amount of financial statements are marked
    as published.
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRFinancial_ins]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRFinancial_ins]
GO

CREATE TRIGGER dbo.trg_PRFinancial_ins
ON PRFinancial
FOR INSERT AS
BEGIN

    DECLARE @prfs_FinancialID int
    DECLARE @prfs_CompanyID int
	DECLARE @prfs_UserID int
	DECLARE @prfs_Publish nchar(1)

    SELECT @prfs_FinancialID = prfs_FinancialID,
           @prfs_CompanyID = prfs_CompanyID,
           @prfs_UserID = prfs_CreatedBy,
           @prfs_Publish = prfs_Publish
      FROM inserted;

	IF (@prfs_Publish = 'Y') BEGIN
		EXEC usp_ResetFinancialPublishFlag @prfs_FinancialID, @prfs_CompanyID, @prfs_UserID
	END

	-- Make sure our JeopardyDate gets set
	EXEC usp_SetJeopardyDate @prfs_CompanyID, @prfs_UserID

    SET NOCOUNT OFF
END
GO



/*
	Ensures only the maximum amount of financial statements are marked
    as published.
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRFinancial_upd]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRFinancial_upd]
GO

CREATE TRIGGER dbo.trg_PRFinancial_upd
ON PRFinancial
FOR UPDATE AS
BEGIN

    DECLARE @prfs_FinancialID int
    DECLARE @prfs_CompanyID int
	DECLARE @prfs_UserID int
	DECLARE @prfs_Publish nchar(1)
	DECLARE @prfs_PublishOld nchar(1)

    SELECT @prfs_FinancialID = prfs_FinancialID,
           @prfs_CompanyID = prfs_CompanyID,
           @prfs_UserID = prfs_UpdatedBy,
           @prfs_Publish = prfs_Publish
      FROM inserted;

    SELECT @prfs_PublishOld = prfs_Publish
      FROM deleted;

	IF ((@prfs_Publish = 'Y') AND ((@prfs_PublishOld IS NULL) OR (@prfs_PublishOld = 'N'))) BEGIN
		EXEC usp_ResetFinancialPublishFlag @prfs_FinancialID, @prfs_CompanyID, @prfs_UserID
	END

	-- Make sure our JeopardyDate gets set
	EXEC usp_SetJeopardyDate @prfs_CompanyID, @prfs_UserID

    SET NOCOUNT OFF
END
GO


/*
	Updates the corresponding company's connection list date if this new
	relationship record is from the connection list.
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRCompanyRelationship_ins]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRCompanyRelationship_ins]
GO

CREATE TRIGGER dbo.trg_PRCompanyRelationship_ins
ON PRCompanyRelationship
FOR INSERT AS
BEGIN

    DECLARE @prcr_Source varchar(40), @prcr_Type varchar(40)
    DECLARE @prcr_LeftCompanyID int, @prcr_RightCompanyID int
	DECLARE @Date datetime
	DECLARE @UserID int

    SELECT @prcr_LeftCompanyID = prcr_LeftCompanyID,
           @prcr_RightCompanyID = prcr_RightCompanyID,
           @prcr_Source = prcr_Source,
           @prcr_Type = prcr_Type,
           @Date = prcr_CreatedDate,
		   @UserID = prcr_CreatedBy
      FROM inserted;

	IF (@prcr_Source = 'C') BEGIN
		UPDATE Company
           SET comp_PRConnectionListDate = @Date, 
               comp_UpdatedBy = @UserID,
               comp_UpdatedDate = @Date,
               comp_Timestamp = @Date
         WHERE comp_CompanyID = @prcr_LeftCompanyID
	END

	-- Note: Not required when updating a relationship as only the active flag should be modified.
	EXEC usp_CreateRelationshipTasks @prcr_LeftCompanyID, @prcr_RightCompanyID, @prcr_Type, @UserID

    SET NOCOUNT OFF
END
GO


/*
	Updates the corresponding company's connection list date if this new
	relationship record is from the connection list.

	Handles marking other relationships inactive depending upon the type.
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRCompanyRelationship_upd]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRCompanyRelationship_upd]
GO

CREATE TRIGGER dbo.trg_PRCompanyRelationship_upd
ON PRCompanyRelationship
FOR UPDATE AS
BEGIN

    DECLARE @prcr_Source varchar(40), @prcr_OldSource varchar(40)
    DECLARE @prcr_LeftCompanyID int, @prcr_RightCompanyID int
	DECLARE @Date datetime
	DECLARE @UserID int
    DECLARE @prcr_Active char(1), @prcr_OldActive char(1)
	DECLARE @prcr_Type varchar(40)
    DECLARE @prcr_CompanyRelationshipID int

    SELECT @prcr_CompanyRelationshipID = prcr_CompanyRelationshipID,
		   @prcr_LeftCompanyID = prcr_LeftCompanyID,
           @prcr_RightCompanyID = prcr_RightCompanyID,
           @prcr_Source = prcr_Source,
           @prcr_Active = prcr_Active,
		   @prcr_Type = prcr_Type,
           @Date = prcr_UpdatedDate,
		   @UserID = prcr_UpdatedBy
      FROM inserted;

    SELECT @prcr_OldSource = prcr_Source,
           @prcr_OldActive = prcr_Active
      FROM deleted;


	--
	-- Handle the connection list updates
	--
	IF ((@prcr_OldSource <> 'C') AND (@prcr_Source = 'C')) BEGIN
		UPDATE Company
           SET comp_PRConnectionListDate = @Date, 
               comp_UpdatedBy = @UserID,
               comp_UpdatedDate = @Date,
               comp_Timestamp = @Date
         WHERE comp_CompanyID = @prcr_LeftCompanyID
	END

	--
	-- Handle marking a set of relation types inactive
	--
	IF ((@prcr_Active <> 'Y' OR @prcr_Active IS NULL) AND (@prcr_OldActive = 'Y')) BEGIN	
		IF (@prcr_Type IN ('01', '04', '09', '10', '11', '12', '13', '14', '15', '16')) BEGIN
			
			UPDATE PRCompanyRelationship
			   SET prcr_Active = NULL, 
				   prcr_UpdatedBy = @UserID,
				   prcr_UpdatedDate = @Date,
				   prcr_Timestamp = @Date
			 WHERE prcr_LeftCompanyID = @prcr_LeftCompanyID
               AND prcr_RightCompanyID = @prcr_RightCompanyID
               AND prcr_Type IN ('01', '04', '09', '10', '11', '12', '13', '14', '15', '16')
               AND prcr_CompanyRelationshipID <> @prcr_CompanyRelationshipID
               AND prcr_Active = 'Y'

			UPDATE PRCompanyRelationship
			   SET prcr_Active = NULL, 
				   prcr_UpdatedBy = @UserID,
				   prcr_UpdatedDate = @Date,
				   prcr_Timestamp = @Date
			 WHERE prcr_LeftCompanyID = @prcr_RightCompanyID
               AND prcr_RightCompanyID = @prcr_LeftCompanyID
               AND prcr_Type IN ('01', '04', '09', '10', '11', '12', '13', '14', '15', '16')
               AND prcr_CompanyRelationshipID <> @prcr_CompanyRelationshipID
               AND prcr_Active = 'Y';

		END
	END

    SET NOCOUNT OFF
END
GO

/*

	Assigns slot and sequence numbers for a newly inserted Phone record
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_Phone_ins]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_Phone_ins]
GO

CREATE TRIGGER [dbo].[trg_Phone_ins]
ON [dbo].[Phone]
FOR INSERT AS
BEGIN

DECLARE @CompanyID int, @RecordID int, @SlotNumber int, @SequenceNumber int
 
-- Get our key fields from the inserted record
SELECT @RecordID = phon_PhoneId,
       @CompanyID = phon_CompanyId
  FROM inserted
 
-- Get our current max slot value excluding the current record.  
SELECT @SlotNumber = ISNULL(MAX([phon_PRSlot]), -1) 
  FROM Phone
 WHERE phon_CompanyId = @CompanyID
 
-- Increment it
SET @SlotNumber = @SlotNumber + 1

-- Get our current max sequence value excluding the current record.  
SELECT @SequenceNumber = ISNULL(MAX([phon_PRSequence]), -1) 
  FROM Phone
 WHERE phon_CompanyId = @CompanyID
 
-- Increment it
SET @SequenceNumber = @SequenceNumber + 1
 
-- Reset our value.
UPDATE Phone
   SET phon_PRSlot = @SlotNumber,
    phon_PRSequence = @SequenceNumber
 WHERE phon_PhoneId = @RecordID

END
GO

/*
	Assigns slot and sequence numbers for a newly inserted Email record
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_Email_ins]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_Email_ins]
GO

CREATE TRIGGER [dbo].[trg_Email_ins]
ON [dbo].[Email]
FOR INSERT AS
BEGIN

DECLARE @CompanyID int, @RecordID int, @SlotNumber int, @SequenceNumber int
 
-- Get our key fields from the inserted record
SELECT @RecordID = emai_EmailId,
       @CompanyID = emai_CompanyId
  FROM inserted
 
-- Get our current max slot value excluding the current record.  
SELECT @SlotNumber = ISNULL(MAX([emai_PRSlot]), -1) 
  FROM Email
 WHERE emai_CompanyId = @CompanyID
 
-- Increment it
SET @SlotNumber = @SlotNumber + 1

-- Get our current max sequence value excluding the current record.  
SELECT @SequenceNumber = ISNULL(MAX([emai_PRSequence]), -1) 
  FROM Email
 WHERE emai_CompanyId = @CompanyID
 
-- Increment it
SET @SequenceNumber = @SequenceNumber + 1
 
-- Reset our value.
UPDATE Email
   SET emai_PRSlot = @SlotNumber,
    emai_PRSequence = @SequenceNumber
 WHERE emai_EmailId = @RecordID

END
GO

/*

      Assigns slot number for a newly inserted Address_Link record

*/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_Address_Link_ins]') 

    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_Address_Link_ins]
GO

CREATE TRIGGER [dbo].[trg_Address_Link_ins]
ON [dbo].[Address_Link]
FOR INSERT AS
BEGIN

DECLARE @CompanyID int, @RecordID int, @SlotNumber int

-- Get our key fields from the inserted record
SELECT @RecordID = adli_AddressLinkId,
       @CompanyID = adli_CompanyId
  FROM inserted
-- Get our current max slot value excluding the current record.  
SELECT @SlotNumber = ISNULL(MAX([adli_PRSlot]), -1) 

  FROM Address_Link

 WHERE adli_CompanyId = @CompanyID

-- Increment it
SET @SlotNumber = @SlotNumber + 1

-- Reset our value.
UPDATE Address_Link
   SET adli_PRSlot = @SlotNumber
 WHERE adli_AddressLinkId = @RecordID

END
GO

/* ************************************************************
	This section contains triggers specific to actions of workflows
 * ************************************************************/

/* ************************************************************
 * Name:   dbo.trg_PRFile_upd
 * 
 * Table:  PRFile
 * Action: FOR UPDATE
 * 
 * Description: 
 *		
 *		
 *		                 
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRFile_upd]'))
drop trigger [dbo].[trg_PRFile_upd]
GO

CREATE TRIGGER dbo.trg_PRFile_upd
ON PRFile
FOR UPDATE AS
BEGIN
    DECLARE @Msg varchar (2000)
    
    Declare @prfi_UpdatedBy int, @UserId int, @prfi_FileId int
    Declare @prfi_Company1Id int
    Declare @CreditorName varchar(500), @DebtorName varchar(500)
    Declare @comm_CommunicationId int
    Declare @comm_DueDate datetime

	-- for Dispute Typed Files, if the Due Dates change, we will create tasks to the assigned to
	-- user.  if received dates change, we will attempt to remove the Due Date review tasks.
	DECLARE @prfi_DisputeRequestDueDate datetime, @prfi_DisputeRequestResponseDate datetime
	DECLARE @prfi_DisputeRequestDueDate2 datetime, @prfi_DisputeRequestResponseDate2 datetime
	DECLARE @prfi_5657WarningDueDate datetime, @prfi_5657WarningResponseDate datetime
	DECLARE @prfi_5657ReportDueDate datetime, @prfi_5657ReportResponseDate datetime
	DECLARE @prfi_AssignedUserId int
	
    select  @prfi_FileId = ins.prfi_FileId, 
			@prfi_Company1Id = ins.prfi_Company1Id,
            @CreditorName = comp_name,
            @prfi_DisputeRequestDueDate = ins.prfi_DisputeRequestDueDate, 
            @prfi_DisputeRequestResponseDate = ins.prfi_DisputeRequestResponseDate, 
            @prfi_DisputeRequestDueDate2 = ins.prfi_DisputeRequestDueDate2, 
            @prfi_DisputeRequestResponseDate2 = ins.prfi_DisputeRequestResponseDate2, 
            @prfi_5657WarningDueDate = ins.prfi_5657WarningDueDate, 
            @prfi_5657WarningResponseDate = ins.prfi_5657WarningResponseDate, 
            @prfi_5657ReportDueDate = ins.prfi_5657ReportDueDate, 
            @prfi_5657ReportResponseDate  = ins.prfi_5657ReportResponseDate , 
            @prfi_DisputeRequestDueDate = ins.prfi_DisputeRequestDueDate, 
            @prfi_AssignedUserId = ins.prfi_AssignedUserId , 
            @prfi_UpdatedBy = ins.prfi_UpdatedBy
      from inserted ins
     inner join deleted del ON ins.prfi_FileId = del.prfi_FileId
     inner join Company ON  ins.prfi_Company1Id = comp_CompanyId

	-- determine the creditor's phone number
	DECLARE @CreditorNumber varchar(255)
	SELECT @CreditorNumber = dbo.ufn_GetCompanyPhone (@prfi_Company1Id, 'Y', null, 'P')
     
    -- start checking Due Date changes
	if (Update(prfi_DisputeRequestDueDate) 
		AND dbo.ufn_GetAccpacDate(@prfi_DisputeRequestDueDate) IS NOT NULL 
		AND dbo.ufn_GetAccpacDate(@prfi_DisputeRequestResponseDate) IS NULL)
	begin
		-- create the task 	
		SET @Msg = 'Dispute Request Due Date is past due. Review the File (' +
				convert(varchar, @prfi_FileId) + ') regarding ' + @CreditorName + '(' + convert(varchar, @prfi_Company1Id) + ', ' + @CreditorNumber + ') .'
		exec usp_WA_File_CreateDueDateExpiredTask @prfi_FileId, 'prfi_DisputeRequestResponseDate',
					 @prfi_Company1Id, @prfi_AssignedUserId, @Msg, 1, @prfi_UpdatedBy
	end else if (Update(prfi_DisputeRequestResponseDate) AND dbo.ufn_GetAccpacDate(@prfi_DisputeRequestResponseDate) IS NOT NULL) begin
		-- check if the communication record (i.e. the task) needs to be canceled
		SET @comm_CommunicationId = null
		select @comm_CommunicationId = comm_communicationId, @comm_DueDate = Comm_DateTime 
		  from Communication 
		 where comm_PRFileId = @prfi_FileId and comm_PRAssociatedColumnName = 'prfi_DisputeRequestResponseDate'
		if (@comm_CommunicationId is not null and dbo.ufn_GetAccpacDate(@prfi_DisputeRequestResponseDate) < @comm_DueDate)
		begin
			DELETE FROM Communication where comm_CommunicationId = @comm_CommunicationId
			DELETE FROM Comm_Link where cmli_comm_CommunicationId = @comm_CommunicationId					
		end
	end
	-- prfi_DisputeRequestDueDate2
	if (Update(prfi_DisputeRequestDueDate2) 
		AND dbo.ufn_GetAccpacDate(@prfi_DisputeRequestDueDate2) IS NOT NULL 
		AND dbo.ufn_GetAccpacDate(@prfi_DisputeRequestResponseDate2) IS NULL)
	begin
		-- create the task 	
		SET @Msg = 'Dispute Request Due Date is past due. Review the File (' +
				convert(varchar, @prfi_FileId) + ') regarding ' + @CreditorName + '(' + convert(varchar, @prfi_Company1Id) + ', ' + @CreditorNumber + ') .'
		exec usp_WA_File_CreateDueDateExpiredTask @prfi_FileId, 'prfi_DisputeRequestResponseDate2',
					 @prfi_Company1Id, @prfi_AssignedUserId, @Msg, 1, @prfi_UpdatedBy
	end else if (Update(prfi_DisputeRequestResponseDate2) AND dbo.ufn_GetAccpacDate(@prfi_DisputeRequestResponseDate2) IS NOT NULL) begin
		-- check if the communication record (i.e. the task) needs to be canceled
		SET @comm_CommunicationId = null
		select @comm_CommunicationId = comm_communicationId, @comm_DueDate = Comm_DateTime 
		  from Communication 
		 where comm_PRFileId = @prfi_FileId and comm_PRAssociatedColumnName = 'prfi_DisputeRequestResponseDate2'
		if (@comm_CommunicationId is not null and dbo.ufn_GetAccpacDate(@prfi_DisputeRequestResponseDate2) < @comm_DueDate)
		begin
			DELETE FROM Communication where comm_CommunicationId = @comm_CommunicationId
			DELETE FROM Comm_Link where cmli_comm_CommunicationId = @comm_CommunicationId					
		end
	end
	-- prfi_5657WarningDueDate
	if (Update(prfi_5657WarningDueDate) 
		AND dbo.ufn_GetAccpacDate(@prfi_5657WarningDueDate) IS NOT NULL 
		AND dbo.ufn_GetAccpacDate(@prfi_5657WarningResponseDate) IS NULL)
	begin
		-- create the task 	
		SET @Msg = 'Dispute Request Due Date is past due. Review the File (' +
				convert(varchar, @prfi_FileId) + ') regarding ' + @CreditorName + '(' + convert(varchar, @prfi_Company1Id) + ', ' + @CreditorNumber + ') .'
		exec usp_WA_File_CreateDueDateExpiredTask @prfi_FileId, 'prfi_5657WarningResponseDate',
					 @prfi_Company1Id, @prfi_AssignedUserId, @Msg, 1, @prfi_UpdatedBy
	end else if (Update(prfi_5657WarningResponseDate) AND dbo.ufn_GetAccpacDate(@prfi_5657WarningResponseDate) IS NOT NULL) begin
		-- check if the communication record (i.e. the task) needs to be canceled
		SET @comm_CommunicationId = null
		select @comm_CommunicationId = comm_communicationId, @comm_DueDate = Comm_DateTime 
		  from Communication 
		 where comm_PRFileId = @prfi_FileId and comm_PRAssociatedColumnName = 'prfi_5657WarningResponseDate'
		if (@comm_CommunicationId is not null and dbo.ufn_GetAccpacDate(@prfi_5657WarningResponseDate) < @comm_DueDate)
		begin
			DELETE FROM Communication where comm_CommunicationId = @comm_CommunicationId
			DELETE FROM Comm_Link where cmli_comm_CommunicationId = @comm_CommunicationId					
		end
	end
	-- prfi_5657ReportDueDate
	if (Update(prfi_5657ReportDueDate) 
		AND dbo.ufn_GetAccpacDate(@prfi_5657ReportDueDate) IS NOT NULL 
		AND dbo.ufn_GetAccpacDate(@prfi_5657ReportResponseDate) IS NULL)
	begin
		-- create the task 	
		SET @Msg = 'Dispute Request Due Date is past due. Review the File (' +
				convert(varchar, @prfi_FileId) + ') regarding ' + @CreditorName + '(' + convert(varchar, @prfi_Company1Id) + ', ' + @CreditorNumber + ') .'
		exec usp_WA_File_CreateDueDateExpiredTask @prfi_FileId, 'prfi_5657ReportResponseDate',
					 @prfi_Company1Id, @prfi_AssignedUserId, @Msg, 1, @prfi_UpdatedBy
	end else if (Update(prfi_5657ReportResponseDate) AND dbo.ufn_GetAccpacDate(@prfi_5657ReportResponseDate) IS NOT NULL) begin
		-- check if the communication record (i.e. the task) needs to be canceled
		SET @comm_CommunicationId = null
		select @comm_CommunicationId = comm_communicationId, @comm_DueDate = Comm_DateTime 
		  from Communication 
		 where comm_PRFileId = @prfi_FileId and comm_PRAssociatedColumnName = 'prfi_5657ReportResponseDate'
		if (@comm_CommunicationId is not null and dbo.ufn_GetAccpacDate(@prfi_5657ReportResponseDate) < @comm_DueDate)
		begin
			DELETE FROM Communication where comm_CommunicationId = @comm_CommunicationId
			DELETE FROM Comm_Link where cmli_comm_CommunicationId = @comm_CommunicationId					
		end
	end
END
GO

/* ************************************************************
 * Name:   dbo.trg_WorkflowInstance_upd
 * 
 * Table:  WorkflowInstance
 * Action: FOR UPDATE
 * 
 * Description: This UPDATE trigger monitors all changes to workflow state
 *		Depending upon the workflow type and transition from/to states
 *		automation actions may be required.  The current automation tasks include:
 *		
 *		PRFile Workflows
 *          1) State change from Qualified to FileOpen, invoke usp_WA_File_OpenFile
 *          2) State change to Opinion, invoke usp_WA_File_WriteOpinion
 *          2) State change to Assitance Requested, invoke usp_WA_File_DisputeAssistanceRequested
 *                 
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_WorkflowInstance_upd]'))
drop trigger [dbo].[trg_WorkflowInstance_upd]
GO

CREATE TRIGGER dbo.trg_WorkflowInstance_upd
ON WorkflowInstance
FOR UPDATE AS
BEGIN
    
    SET NOCOUNT ON
    Declare @Err int
    SET @Err = 0
    Declare @Now datetime
    SET @Now = getDate()
    DECLARE @Msg varchar (2000)
    
    Declare @wkin_ins_StateName varchar(40), @wkin_del_StateName varchar(40)
    Declare @wkin_InstanceId int, @wkin_WorkflowId int
    Declare @wkin_UpdatedBy int
    Declare @wkin_CurrentEntityId int, @wkin_CurrentRecordId int
    Declare @wkin_ins_CurrentStateId int, @wkin_del_CurrentStateId int
    
    Declare @SSFileWorkflowId int
    select @SSFileWorkflowId = work_WorkflowId from Workflow where work_Description = 'Collections Workflow'
    
--    Declare @CreditorName varchar(500), @DebtorName varchar(500)

    -- Determine the type of Workflow being updated
    select  @wkin_InstanceId = ins.wkin_InstanceId , 
            @wkin_WorkflowId = ins.wkin_WorkflowId, 
            @wkin_CurrentEntityId = ins.wkin_CurrentEntityId, 
            @wkin_CurrentRecordId = ins.wkin_CurrentRecordId, 
            @wkin_ins_CurrentStateId = ins.wkin_CurrentStateId, 
            @wkin_del_CurrentStateId = del.wkin_CurrentStateId, 
            @wkin_UpdatedBy = ins.wkin_UpdatedBy 
      from inserted ins
     inner join deleted del ON ins.wkin_InstanceId = del.wkin_InstanceId
     
	-- actions related to the SSFile (Collections/Dispute/Opinion) workflows
	IF (@SSFileWorkflowId = @wkin_WorkflowId)
	BEGIN
		-- Now check the actions
		DECLARE @OpenFileStateId int, @QualifiedStateId int, @OpinionStateId int, @DisputeAssistanceRequestedStateId int
		SELECT @QualifiedStateId = wkst_StateId  from WorkflowState where wkst_Name = 'Qualified' and wkst_WorkflowId = @wkin_WorkflowId
		SELECT @OpenFileStateId = wkst_StateId  from WorkflowState where wkst_Name = 'File Open' and wkst_WorkflowId = @wkin_WorkflowId
		SELECT @OpinionStateId = wkst_StateId  from WorkflowState where wkst_Name = 'Opinion' and wkst_WorkflowId = @wkin_WorkflowId
		SELECT @DisputeAssistanceRequestedStateId = wkst_StateId  from WorkflowState where wkst_Name = 'Dispute Assistance Requested' and wkst_WorkflowId = @wkin_WorkflowId

		if (@wkin_del_CurrentStateId = @QualifiedStateId and @wkin_ins_CurrentStateId = @OpenFileStateId) begin
			-- if we are going from Qualified to Open File
			exec usp_WA_File_OpenFile @wkin_CurrentRecordId
		end else if (@wkin_ins_CurrentStateId = @OpinionStateId) begin
			-- if we are going to Opinion
			exec usp_WA_File_WriteOpinion @wkin_CurrentRecordId
		end else if (@wkin_ins_CurrentStateId = @DisputeAssistanceRequestedStateId) begin
			-- if we are going to Opinion
			exec usp_WA_File_RequestDisputeAssistance @wkin_CurrentRecordId
		end
	END
END
Go

/* ************************************************************
	This ends the workflow triggers section
 * ************************************************************/


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRRating_del]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRRating_del]
GO

CREATE TRIGGER [dbo].[trg_PRRating_del]
ON [dbo].[PRRating]
FOR DELETE AS
BEGIN

DECLARE @PreviousRatingID int, @prra_CompanyID int
DECLARE @prra_Current char(1)


SELECT @prra_Current = prra_Current,
       @prra_CompanyID = prra_CompanyID
  FROM deleted;

-- If we're deleting a rating that is marked
-- as current
IF (@prra_Current = 'Y') BEGIN
	-- Go figure out what our previous rating is
	SELECT @PreviousRatingID = MAX(prra_RatingID)
	  FROM PRRating
	 WHERE prra_CompanyId = @prra_CompanyID
	   AND prra_Deleted IS NULL
	   AND prra_Current IS NULL;

	IF (@PreviousRatingID IS NOT NULL) BEGIN
		UPDATE PRRating
           SET prra_Current = 'Y',
               prra_UpdatedDate = GETDATE(),
			   prra_TimeStamp = GETDATE()
         WHERE prra_RatingID = @PreviousRatingID;
	END
END

END
GO



--
--  If a HQ company is delisted, this trigger delists
--  any branches.
--
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_CompanyBranchDelisting_upd]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_CompanyBranchDelisting_upd]
GO

CREATE TRIGGER dbo.trg_CompanyBranchDelisting_upd
ON Company
FOR UPDATE AS
BEGIN

	DECLARE @BranchCount int, @Index int, @BranchID int, @HQID int
	DECLARE @ListingStatus varchar(40), @OldListingStatus varchar(40),@Type varchar(40)
	DECLARE @TrxId int, @UserID int

	DECLARE @Branches table (
		Ndx int identity(1,1) Primary Key,
		BranchID int
	)

	SELECT @HQID = comp_CompanyID,
           @ListingStatus = comp_PRListingStatus,
		   @Type = comp_PRType,
		   @UserID = comp_UpdatedBy
	  FROM inserted;

	SELECT @OldListingStatus = comp_PRListingStatus
	  FROM deleted;

	-- We only care if the an HQ is being delisted
	IF ((@Type = 'H') AND
		(@OldListingStatus = 'L') AND 
		(@ListingStatus <> 'L') ) BEGIN

		INSERT INTO @Branches (BranchID)
		SELECT comp_CompanyID 
		  FROM company
		 WHERE comp_PRHQID = @HQID
		   AND comp_PRListingStatus = 'L'
           AND comp_Deleted IS NULL;

		SET @BranchCount = @@ROWCOUNT
		SET @Index = 0

		WHILE (@Index < @BranchCount) BEGIN
			SET @Index = @Index + 1

			SELECT @BranchID = BranchID
			  FROM @Branches
			 WHERE Ndx = @Index;

			-- Open a transaction
			exec @TrxId = usp_CreateTransaction 
							@UserId = @UserId,
							@prtx_CompanyId = @BranchID,
							@prtx_Explanation = 'Delisted as a result of HQ being delisted.'
			
			UPDATE Company
			   SET comp_PRListingStatus = @ListingStatus,
				   comp_UpdatedBy = @UserID,
				   comp_UpdatedDate = GETDATE(),
				   comp_Timestamp = GETDATE()
			 WHERE comp_CompanyID = @BranchID;

			-- close the opened transaction
			UPDATE PRTransaction SET prtx_Status = 'C' WHERE prtx_TransactionId = @TrxId
		END
	END
END
Go

--
--  
--
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_Person_Link_ins]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_Person_Link_ins]
GO

CREATE TRIGGER dbo.trg_Person_Link_ins
ON Person_Link
FOR INSERT AS
BEGIN

	DECLARE @PersonID int, @CompanyID int, @UserID int
	DECLARE @PRStatus varchar(40), @PROwnershipRole varchar(40)

	SELECT @PersonID  = peli_PersonID,
           @CompanyID = peli_PRCompanyID,
		   @PRStatus  = peli_PRStatus,
           @PROwnershipRole = peli_PROwnershipRole,
           @UserID    = peli_CreatedBy
      FROM inserted;

	IF ((@PRStatus IN (1,2)) AND (@PROwnershipRole <> 'RCR')) BEGIN
		exec usp_CreateCompanyType29Relationship @PersonID, @CompanyID, @UserID
	END
END
Go

--
--  
--
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_Person_Link_upd]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_Person_Link_upd]
GO

CREATE TRIGGER dbo.trg_Person_Link_upd
ON Person_Link
FOR update AS
BEGIN

	DECLARE @PersonID int, @CompanyID int, @UserID int
	DECLARE @PRStatus varchar(40), @PROwnershipRole varchar(40), @PROldOwnershipRole varchar(40)

	SELECT @PersonID  = peli_PersonID,
           @CompanyID = peli_PRCompanyID,
		   @PRStatus  = peli_PRStatus,
           @PROwnershipRole = peli_PROwnershipRole,
           @UserID    = peli_UpdatedBy
      FROM inserted;

	SELECT @PROldOwnershipRole  = peli_PROwnershipRole
      FROM deleted;

	-- If our ownership was nothing, but now is something, go greate a type
	-- 29 relationship
	IF ((@PROwnershipRole <> 'RCR') AND 
        ((@PROldOwnershipRole = 'RCR')) AND 
        (@PRStatus IN (1,2))) BEGIN
		exec usp_CreateCompanyType29Relationship @PersonID, @CompanyID, @UserID
	END

END
Go

--
--  
--
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRBusinessEvent_ins]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRBusinessEvent_ins]
GO

CREATE TRIGGER dbo.trg_PRBusinessEvent_ins
ON PRBusinessEvent
FOR INSERT AS
BEGIN

	DECLARE @CompanyID int, @BusinessEventTypeID int, @UserID int

	SELECT @CompanyID           = prbe_CompanyID,
           @BusinessEventTypeID = prbe_BusinessEventTypeID,
           @UserID              = prbe_CreatedBy
      FROM inserted;

	EXEC usp_CreateBusinessEventTasks @CompanyID, @BusinessEventTypeID, @UserID
END
Go


--
--  
--
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRRatingNumeralAssigned_ins]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRRatingNumeralAssigned_ins]
GO

CREATE TRIGGER dbo.trg_PRRatingNumeralAssigned_ins
ON PRRatingNumeralAssigned
FOR INSERT AS
BEGIN

	DECLARE @CompanyID int, @RatingNumeralID int, @UserID int

	SELECT @CompanyID           = prra_CompanyID,
           @RatingNumeralID     = pran_RatingNumeralID,
           @UserID              = pran_CreatedBy
      FROM inserted
           INNER JOIN PRRating on pran_RatingID = prra_RatingID;

	EXEC usp_CreateRatingNumeralTasks @CompanyID, @RatingNumeralID, @UserID
END
Go