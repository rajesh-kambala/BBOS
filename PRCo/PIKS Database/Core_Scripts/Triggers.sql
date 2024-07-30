/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2024

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Produce Report Company  is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Produce Report Company.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
   
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 

***********************************************************************
***********************************************************************/


/* ************************************************************
 * Name:   dbo.trg_PRARAgingDetail_ins
 * 
 * Table:  PRARAgingDetail
 * Action: FOR INSERT
 * 
 * Description: INSERT trigger that 
 *              1) checks to see if a relationship 
 *                 record (04) exists for the praad_ManualCompanyId
 *                 and the praa_CompanyId (PRARA ging)
 *              2) checks for conditions that would cause this 
 *                 detail record to generate a PRExceptionQueue item 
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id =  object_id(N'[dbo].[trg_PRARAgingDetail_ins]')
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
	Declare @praa_CompanyId int
	Declare @praa_Date datetime
	Declare @SubjectId int
	Declare @praad_ManualCompanyId int, @praad_SubjectCompanyID int
	Declare @praad_ARAgingDetailId int
	Declare @praad_ARAgingId int
	Declare @praad_Amount0to29 numeric, @praad_Amount30to44 numeric, @praad_Amount45to60 numeric, @praad_Amount61Plus numeric
	Declare @AmountTotal numeric
	Declare @praad_ARCustomerId nvarchar(15)
	Declare @praad_CreatedBy int
	DECLARE @comp_PRIndustryType varchar(40), @comp_PRListingStatus varchar(40)
	Declare @prra_RatingId int
	Declare @prra_AssignedRatingNumerals varchar(100)
	Declare @prra_IntegrityID int
	Declare @prra_PayRatingID int

	-- get the required fields from the inserted record
	SELECT @praa_CompanyId = praa_CompanyId,
		   @praa_Date = praa_Date,
		   @praad_ARAgingDetailId = praad_ARAgingDetailId,
		   @praad_ARCustomerId = praad_ARCustomerId,
		   @praad_ManualCompanyId = praad_ManualCompanyId,
		   @praad_SubjectCompanyID = praad_SubjectCompanyID,
		   @praad_ARAgingId = praad_ARAgingId,
		   @praad_Amount0to29 = ISNULL(praad_Amount0to29, 0),
		   @praad_Amount30to44 = ISNULL(praad_Amount30to44, 0),
		   @praad_Amount45to60 = ISNULL(praad_Amount45to60, 0),
		   @praad_Amount61Plus = ISNULL(praad_Amount61Plus, 0),
		   @praad_CreatedBy = praad_CreatedBy
	  from inserted
	       INNER JOIN PRARAging ON praad_ARAgingId = praa_ARAgingId

	IF (ISNULL(@praad_ManualCompanyId, @praad_SubjectCompanyID) IS NOT NULL) BEGIN
		SET @SubjectId = ISNULL(@praad_ManualCompanyId, @praad_SubjectCompanyID)
		EXEC usp_UpdateCompanyRelationship @praa_CompanyId, @SubjectId, '04', 0, @praad_CreatedBy
	END	ELSE BEGIN
	   -- determine the Subject Company from the ARTranslation table
	   SELECT @SubjectId = prar_PRCoCompanyId
	     FROM PRARTranslation WITH (NOLOCK)
	    WHERE prar_CustomerNumber = @praad_ARCustomerId
		  AND prar_CompanyId = @praa_CompanyId 
	END   

	IF (@SubjectId IS NOT NULL) BEGIN

        SELECT @comp_PRIndustryType = comp_PRIndustryType,
		       @comp_PRListingStatus = comp_PRListingStatus
 		  FROM Company WITH (NOLOCK)
		 WHERE comp_CompanyID = @SubjectId;

		--
		--  Make sure our SubjectCompanyID value is set.
		--  This is an internal field used to optimize queries.
		--
		UPDATE PRARAgingDetail
			SET praad_SubjectCompanyID = @SubjectId,
				praad_UpdatedBy = @praad_CreatedBy,
				praad_UpdatedDate = GETDATE()
			FROM PRARAgingDetail a WITH (NOLOCK)
				INNER JOIN inserted i ON a.praad_ARAgingDetailId = i.praad_ARAgingDetailId
			WHERE a.praad_SubjectCompanyID IS NULL;

		DECLARE @RatingCompanyId int
		SET @RatingCompanyId = @SubjectId



		IF (@comp_PRIndustryType IN ('P', 'S', 'T')) BEGIN

			SET @AmountTotal = @praad_Amount0to29 + @praad_Amount30to44 + @praad_Amount45to60 + @praad_Amount61Plus

			IF @AmountTotal > 1000 BEGIN

				-- get the integrity rating, pay rating and the rating numerals
				SELECT @prra_RatingId = prra_RatingId,
			  			@prra_AssignedRatingNumerals = prra_AssignedRatingNumerals,
						@prra_IntegrityID = prra_IntegrityID,
						@prra_PayRatingID = prra_PayRatingID
					FROM vPRCurrentRating
					WHERE prra_CompanyId = @RatingCompanyId;
			
				-- If we have a rating record
				IF (@prra_RatingId IS NOT NULL) BEGIN
				
					-- If Integritity Rating is 'XXXX', 'XXX' 'XXX148' OR NULL
					-- AND The amount 45 days + is > 35% of the total
					IF ((ISNULL(@prra_IntegrityID, -1) IN (-1, 4,5,6)) AND
						(((@praad_Amount45to60 + @praad_Amount61Plus) / @AmountTotal) >= .40)) BEGIN
							EXEC usp_CreateException 'AR', @praad_ARAgingDetailId, @praad_CreatedBy, @SubjectId
					END
				END					
			END
		END
	END
	SET NOCOUNT OFF
END
GO


if exists (select * from dbo.sysobjects where id =  object_id(N'[dbo].[trg_PRARAgingDetail_upd]')
	and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRARAgingDetail_upd]
GO

CREATE TRIGGER dbo.trg_PRARAgingDetail_upd
ON PRARAgingDetail
FOR UPDATE AS

BEGIN
	SET NOCOUNT ON
	Declare @Err int
	SET @Err = 0

	Declare @praa_CompanyId int
	Declare @praa_Date datetime
	Declare @SubjectId int
	Declare @praad_ManualCompanyId int
	Declare @praad_ARAgingDetailId int
	Declare @praad_ARAgingId int
	Declare @praad_Amount0to29 numeric, @praad_Amount30to44 numeric, @praad_Amount45to60 numeric, @praad_Amount61Plus numeric
	Declare @AmountTotal numeric
	Declare @praad_ARCustomerId nvarchar(15)
	Declare @praad_UpdatedBy int
	DECLARE @comp_PRIndustryType varchar(40), @comp_PRListingStatus varchar(40)
	Declare @prra_RatingId int
	Declare @prra_AssignedRatingNumerals varchar(100)
	Declare @prra_IntegrityID int
	Declare @prra_PayRatingID int, @praad_CreatedBy int
    DECLARE @praad_Exception char(1)

	-- get the required fields from the updated record
	SELECT @praa_CompanyId = praa_CompanyId,
		   @praa_Date = praa_Date,
		   @praad_ARAgingDetailId = praad_ARAgingDetailId,
		   @praad_ARCustomerId = praad_ARCustomerId,
		   @praad_ManualCompanyId = praad_ManualCompanyId,
		   @SubjectId = praad_SubjectCompanyId,
		   @praad_ARAgingId = praad_ARAgingId,
		   @praad_Amount0to29 = ISNULL(praad_Amount0to29, 0),
		   @praad_Amount30to44 = ISNULL(praad_Amount30to44, 0),
		   @praad_Amount45to60 = ISNULL(praad_Amount45to60, 0),
		   @praad_Amount61Plus = ISNULL(praad_Amount61Plus, 0),			   
		   @praad_UpdatedBy = praad_UpdatedBy,
           @praad_Exception = ISNULL(praad_Exception, 'N'),
		   @praad_CreatedBy = praad_CreatedBy
	  from inserted
	       INNER JOIN PRARAging WITH (NOLOCK) ON praad_ARAgingId = praa_ARAgingId

	IF (@SubjectId IS NULL) BEGIN
	   -- determine the Subject Company from the ARTranslation table
	   SELECT @SubjectId = prar_PRCoCompanyId
	     FROM PRARTranslation WITH (NOLOCK)
	    WHERE prar_CustomerNumber = @praad_ARCustomerId
		  AND prar_CompanyId = @praa_CompanyId;

	END   

	DECLARE @CreatedException char(1)
	SET @CreatedException = 'N'
	
	IF (@SubjectId IS NOT NULL) BEGIN

        SELECT @comp_PRIndustryType = comp_PRIndustryType,
		       @comp_PRListingStatus = comp_PRListingStatus
 		  FROM Company WITH (NOLOCK)
		 WHERE comp_CompanyID = @SubjectId;

			--
			--  Make sure our SubjectCompanyID value is set.
			--  This is an internal field used to optimize queries.
			--
			UPDATE PRARAgingDetail
			   SET praad_SubjectCompanyID = @SubjectId,
				   praad_UpdatedBy = @praad_UpdatedBy,
				   praad_UpdatedDate = GETDATE()
			  FROM PRARAgingDetail a WITH (NOLOCK)
				   INNER JOIN inserted i ON a.praad_ARAgingDetailId = i.praad_ARAgingDetailId;

			DECLARE @RatingCompanyId int
			SET @RatingCompanyId = @SubjectId

			SELECT @comp_PRIndustryType = comp_PRIndustryType
			  FROM Company WITH (NOLOCK)
			 WHERE comp_CompanyID = @SubjectId;

			IF (@comp_PRIndustryType IN ('P', 'S', 'T')) BEGIN

				SET @AmountTotal = @praad_Amount0to29 + @praad_Amount30to44 + @praad_Amount45to60 + @praad_Amount61Plus

				IF @AmountTotal > 1000 BEGIN
			
					-- get the integrity rating, pay rating and the rating numerals
				  SELECT @prra_RatingId = prra_RatingId,
						 @prra_AssignedRatingNumerals = prra_AssignedRatingNumerals,
						 @prra_IntegrityID = prra_IntegrityID,
						 @prra_PayRatingID = prra_PayRatingID
					FROM vPRCurrentRating
				   WHERE prra_CompanyId = @RatingCompanyId;
		
					-- If we have a rating record
					IF (@prra_RatingId IS NOT NULL) BEGIN
			
						-- If Integritity Rating is 'XXXX', 'XXX' 'XXX148' OR NULL
						-- AND The amount 45 days + is > 35% of the total
						IF ((ISNULL(@prra_IntegrityID, -1) IN (-1, 4,5,6)) AND
		  					(((@praad_Amount45to60 + @praad_Amount61Plus) / @AmountTotal) >= .35)) BEGIN
					   
							-- If we didn't create an exception last time,
							-- then go ahead and create it now.
							IF (@praad_Exception = 'N') BEGIN
								EXEC usp_CreateException 'AR', @praad_ARAgingDetailId, @praad_UpdatedBy, @SubjectId
							END
							SET @CreatedException = 'Y'
						END
					END						
				END	
			END
		
	END

	-- If we created an Exception when we first inserted this record,
    -- but now based on the data we did not create an exception, then
	-- we must go delete that original exception.
	IF ((@praad_Exception = 'Y') AND (@CreatedException = 'N')) BEGIN
		DELETE FROM PRExceptionQueue WHERE preq_TradeReportId = @praad_ARAgingDetailId AND preq_Type = 'AR';
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
    Declare @UserId int

    Declare @prar_CompanyId int
    Declare @prar_PRCoCompanyId int
    Declare @prar_CustomerNumber varchar(15)

    Declare @praa_ARAgingId int
    Declare @praa_Date datetime
    
    -- get the required fields from the inserted record
    SELECT @prar_PRCoCompanyId = prar_PRCoCompanyId,
           @prar_CompanyId = prar_CompanyId,
           @prar_CustomerNumber = prar_CustomerNumber,
           @UserId = prar_CreatedBy 
      FROM inserted
      
    IF (@prar_PRCoCompanyId IS NOT NULL)
    BEGIN
        -- make sure that the company is actually used on an AR Aging Detail record
        SET @praa_ARAgingId = NULL
        SELECT @praa_ARAgingId = praa_ARAgingId, @praa_Date = praa_Date 
          FROM PRARAgingDetail WITH (NOLOCK)
               INNER JOIN PRARAging WITH (NOLOCK) ON praad_ARAgingId = praa_ARAgingId
         WHERE praa_CompanyId = @prar_CompanyId
           AND praad_ARCustomerId = @prar_CustomerNumber;
        
        IF (@praa_ARAgingId is not null)
        BEGIN
			EXEC usp_UpdateCompanyRelationship @prar_CompanyId, @prar_PRCoCompanyId, '04', 0, @UserId

			--
			--  Make sure our SubjectCompanyID value is set.
			--  This is an internal field used to optimize queries.
			--
			UPDATE PRARAgingDetail
			   SET praad_SubjectCompanyID = @prar_PRCoCompanyId,
		           praad_UpdatedBy = @UserId,
			       praad_UpdatedDate = GETDATE()
			  FROM PRARAgingDetail WITH (NOLOCK)
				   INNER JOIN PRARAging WITH (NOLOCK) ON praad_ARAgingId = praa_ARAgingId
			 WHERE praa_CompanyId = @prar_CompanyId
			   AND praad_ARCustomerId = @prar_CustomerNumber;

        END  
    END
    
    SET NOCOUNT OFF
END
GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRARTranslation_upd]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRARTranslation_upd]
GO

CREATE TRIGGER dbo.trg_PRARTranslation_upd
ON PRARTranslation
FOR UPDATE AS
BEGIN

	DECLARE @OldSubjectCompanyID int, @NewSubjectCompanyID int
    DECLARE @prar_CompanyId int, @UserId int
    DECLARE @prar_CustomerNumber varchar(15)

    -- get the required fields from the inserted record
    SELECT @NewSubjectCompanyID = prar_PRCoCompanyId,
	       @prar_CompanyId = prar_CompanyID,
		   @prar_CustomerNumber = prar_CustomerNumber,
		   @UserId = prar_UpdatedBy 
      FROM inserted
      
    SELECT @OldSubjectCompanyID = prar_PRCoCompanyId
      FROM deleted

	IF (ISNULL(@NewSubjectCompanyID, 0) <> ISNULL(@OldSubjectCompanyID, 0)) BEGIN

		EXEC usp_UpdateCompanyRelationship @prar_CompanyId, @NewSubjectCompanyID, '04', 0, @UserId

		UPDATE PRARAgingDetail
			SET praad_SubjectCompanyID = @NewSubjectCompanyID,
		        praad_UpdatedBy = @UserId,
			    praad_UpdatedDate = GETDATE()
			FROM PRARAgingDetail WITH (NOLOCK)
				INNER JOIN PRARAging WITH (NOLOCK) ON praad_ARAgingId = praa_ARAgingId
			WHERE praa_CompanyId = @prar_CompanyId
			AND praad_ARCustomerId = @prar_CustomerNumber;
		
	END

END 
Go



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRARTranslation_del]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRARTranslation_del]
GO

CREATE TRIGGER dbo.trg_PRARTranslation_del
ON PRARTranslation
FOR DELETE AS
BEGIN

    DECLARE @prar_CompanyId int
    DECLARE @prar_CustomerNumber varchar(15)

    SELECT @prar_CompanyId = prar_CompanyID,
		   @prar_CustomerNumber = prar_CustomerNumber
      FROM deleted
      
	UPDATE PRARAgingDetail
		SET praad_SubjectCompanyID = NULL,
		    praad_UpdatedBy = -1,
			praad_UpdatedDate = GETDATE()
	   FROM PRARAgingDetail WITH (NOLOCK)
			INNER JOIN PRARAging WITH (NOLOCK) ON praad_ARAgingId = praa_ARAgingId
	  WHERE praa_CompanyId = @prar_CompanyId
		AND praad_ARCustomerId = @prar_CustomerNumber;
	

END 
Go



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
CREATE OR ALTER TRIGGER dbo.trg_PRTradeReport_ins
ON PRTradeReport
FOR INSERT AS
BEGIN
    SET NOCOUNT ON
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
    Declare @prtr_LastdealtDate varchar (40)
    Declare @prtr_NoTrade char(1)
    Declare @prtr_Date datetime
	Declare @prtr_TESRequestID int

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
		   @prtr_LastDealtDate = prtr_LastDealtDate,
		   @prtr_NoTrade = prtr_NoTrade,
           @UserId = prtr_CreatedBy,
		   @prtr_TESRequestID = prtr_TESRequestID
      FROM inserted
           LEFT OUTER JOIN PRIntegrityRating ON prtr_IntegrityId = prin_IntegrityRatingId
           LEFT OUTER JOIN PRPayRating ON prtr_PayRatingId = prpy_PayRatingId;
	
	EXEC usp_UpdateCompanyRelationship @prtr_ResponderId, @prtr_SubjectId, '01', 0, @UserId, @prtr_Date

	IF ((@prtr_LastDealtDate IS NOT NULL AND @prtr_LastDealtDate = 'D')  OR-- Never
	    (@prtr_LastDealtDate IS NOT NULL AND @prtr_LastDealtDate = 'C') OR -- Over 1 Year
		(@prtr_NoTrade IS NOT NULL AND @prtr_NoTrade = 'Y') OR
        (@prtr_OutOfBusiness IS NOT NULL AND @prtr_OutOfBusiness = 'Y'))
	BEGIN
		-- Deactivate these records.
		EXEC usp_UpdateCompanyRelationship @prtr_ResponderId, @prtr_SubjectId, '01,04,09,10,11,12,13,14,15,16', 2, @UserId
		
		-- Exclude this subject from this responder for future TES Requests
		EXEC usp_CreateTESRequestExclusion @prtr_ResponderId, @prtr_SubjectId, @UserId

		-- Exclude this Trade Report record from being included in future analysis.
		UPDATE PRTradeReport SET prtr_ExcludeFromAnalysis = 'Y' WHERE prtr_TradeReportId = @prtr_TradeReportId;

	END ELSE BEGIN
		-- If we get a trade report from a responder on a subject, remove any TES Exclusion
		DELETE FROM PRTESRequestExclusion WHERE prtesre_CompanyID=@prtr_ResponderId AND prtesre_SubjectCompanyID=@prtr_SubjectId;
	END

    -- get the current company integrity and pay ratings
	EXEC usp_CheckCompanyTESException
				@prtr_SubjectId,
				@UserId,
				@prtr_TradeReportId,
				@prtr_IntegrityId,
				@prtr_PayRatingId,
				@prtr_PayRatingWeight,
				@prtr_OutOfBusiness

    
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
       AND DATEDIFF(day, prtr_Date, @prtr_Date) <= 45
       AND prtr_TradeReportId <> @prtr_TradeReportId;

	IF (@prtr_TESRequestID is not null)
		BEGIN
			EXEC usp_ProcessVerbalInvestigations @prtr_TradeReportId	
		END

    SET NOCOUNT OFF
END
Go


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRTradeReport_upd]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRTradeReport_upd]
GO

CREATE TRIGGER dbo.trg_PRTradeReport_upd
ON PRTradeReport
FOR UPDATE AS
BEGIN
    SET NOCOUNT ON

    Declare @prtr_TradeReportId int
	Declare @prtr_TESRequestID int, @prtr_OLDTESRequestID int

    SELECT @prtr_TradeReportId = prtr_TradeReportId,
		   @prtr_TESRequestID = prtr_TESRequestID
      FROM inserted;

    SELECT @prtr_OLDTESRequestID = prtr_TESRequestID
      FROM deleted;

	-- If we updated this TradeReport record with a TESRequest ID,
    -- then process the verbal investigations.
	IF ((@prtr_TESRequestID IS NOT NULL) AND
        (@prtr_OLDTESRequestID IS NULL))
		BEGIN
			EXEC usp_ProcessVerbalInvestigations @prtr_TradeReportId	
		END

    SET NOCOUNT OFF
END
Go


/* ************************************************************
 * Name:   dbo.trg_PRTradeReport_del
 * 
 * Table:  PRTradeReport
 * Action: FOR DELETE
 * 
 * Description: Delete trigger that 
 *              1) decrement the count or deletes the relationship record (01) 
 *                 for the prtr_ResponderId and the prtr_SubjectId 
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRTradeReport_del]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRTradeReport_del]
GO

CREATE TRIGGER dbo.trg_PRTradeReport_del
ON PRTradeReport
FOR DELETE AS
BEGIN
    SET NOCOUNT ON

    Declare @UserId int

    Declare @prtr_TradeReportId int
    Declare @prtr_ResponderId int
    Declare @prtr_SubjectId int

    Declare @prtr_Date datetime
    
    -- get the required fields from the deleted record
    SELECT @prtr_TradeReportId = prtr_TradeReportId,
           @prtr_ResponderId = prtr_ResponderId,
           @prtr_SubjectId = prtr_SubjectId,
           @UserId = prtr_CreatedBy 
      from deleted

    -- If there are no more reports, then delete the relationship.
    -- otherwise we will decrement the Times Reported by 1 and update the LastReportedDate to the
    -- date of the next most recent prtr record between the two companies
    Set @prtr_Date = NULL;
    select @prtr_Date = max(prtr_Date) from PRTradeReport 
    where prtr_TradeReportId != @prtr_TradeReportId and 
	       prtr_ResponderId = @prtr_ResponderId and
	       prtr_SubjectId = @prtr_SubjectId;

    Declare @Action int;
    Set @Action = Case When @prtr_Date is null Then 4 Else 3 End;
    EXEC usp_UpdateCompanyRelationship @prtr_ResponderId, @prtr_SubjectId, '01', @Action, @UserId, @prtr_Date


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
CREATE OR ALTER TRIGGER [dbo].[trg_PRBBScore_ins]
ON [dbo].[PRBBScore]
FOR INSERT AS
BEGIN
    SET NOCOUNT ON

	BEGIN TRY
		BEGIN TRANSACTION
	    
		DECLARE @prbs_BBScoreId int, @prbs_OldBBScoreID int
		DECLARE @prbs_CompanyId int, @prbs_MinimumTradeReportCount int
		DECLARE @UserId int
		DECLARE @prbs_Date datetime, @ListedDate datetime
		DECLARE @prbs_NewBBScore numeric(24,6)
		DECLARE @prbs_OldBBScore numeric(24,6)
        DECLARE @prbs_Recency varchar(20)
		DECLARE @ConfidenceScore numeric(24,6), @Type varchar(40), @InvestigationGroup varchar(40)
		DECLARE @PublishScore varchar(1), @OldPublishScore varchar(1)
		DECLARE @IndustryType varchar(40)
		
		SET @PublishScore = NULL;
		
		
		-- Get our current record's values
		SELECT @prbs_BBScoreId = prbs_BBScoreId,
			   @prbs_CompanyId = prbs_CompanyId,
			   @prbs_NewBBScore = prbs_BBScore,
			   @prbs_MinimumTradeReportCount = prbs_MinimumTradeReportCount,
			   @prbs_Date = prbs_Date,
               @prbs_Recency = prbs_Recency,
			   @UserId = prbs_UpdatedBy,
			   @ConfidenceScore = prbs_ConfidenceScore,
               @Type = comp_PRType,
               @InvestigationGroup = comp_PRInvestigationMethodGroup,
			   @IndustryType = comp_PRIndustryType,
			   @ListedDate = CASE WHEN comp_PRListedDate IS NULL AND comp_PRListingStatus IN ('L', 'H', 'LUV') THEN '2007-12-01' ELSE comp_PRListedDate END
		FROM inserted
             INNER JOIN Company WITH (NOLOCK) On comp_CompanyID = prbs_CompanyId
		
		-- Get our previous record's values
		SELECT @prbs_OldBBScoreID = prbs_BBScoreId,
			   @prbs_OldBBScore = prbs_BBScore,
			   @OldPublishScore = prbs_PRPublish
		  FROM PRBBScore WITH (NOLOCK)
		 WHERE prbs_BBScoreId != @prbs_BBScoreId 
		   AND prbs_CompanyId = @prbs_CompanyId 
		   AND prbs_Current = 'Y';

		-- Update the old current record
		UPDATE PRBBScore 
		   SET prbs_Current = NULL
		 WHERE prbs_BBScoreId = @prbs_OldBBScoreID;


		DECLARE @ListedAgeRule bit = 0
		IF (DATEDIFF(day, @ListedDate, GETDATE()) >= 150) BEGIN
			SET @ListedAgeRule = 1
		END ELSE BEGIN
			-- If they aren't in the window, see if they arleady
			-- have a published score.  If so, they are grandathered in
			IF ((@prbs_OldBBScoreID IS NOT NULL) AND (@OldPublishScore IS NOT NULL)) BEGIN
				SET @ListedAgeRule = 1
			END
		END


		IF (@prbs_NewBBScore > 0
		    AND @ConfidenceScore >= 6
            AND @Type = 'H'
            AND @InvestigationGroup = 'A'
            AND (CONVERT(int, @prbs_Recency) < 12)
			AND @ListedAgeRule = 1) BEGIN 
            SET @PublishScore = 'Y'
        END
       
		-- This overrides the other Produce rules about the 
		-- Investigation Group, Recency, etc.
		IF (@IndustryType IN ('L')
		    AND @ListedAgeRule = 1) BEGIN
			SET @PublishScore = 'Y'
		END

		-- Compute the required TES request count
		DECLARE @ReqCount smallint = 0
		
		IF (@IndustryType IN ('P', 'T', 'S')) BEGIN
			EXEC @ReqCount = usp_SetRequiredTESRequestCount2 @prbs_CompanyId,
															 @prbs_BBScoreId,
															 @UserId,
															 @prbs_MinimumTradeReportCount,
															 @prbs_Date,
															 0
		END

		-- Update the new record
		UPDATE PRBBScore
		   SET prbs_Deviation = @prbs_NewBBScore - @prbs_OldBBScore,
			   prbs_Current = 'Y',
			   prbs_RequiredReportCount = @ReqCount,
			   prbs_PRPublish = @PublishScore
		 WHERE prbs_BBScoreID = @prbs_BBScoreId;


		IF ((@IndustryType IN ('P', 'T', 'S')) AND
		    (@PublishScore = 'Y')) BEGIN

			-- now determine an if the current score is an exception
			-- RAO: The values for this function must be passed in because 
			-- from the perspective of a select in the usp, the record will not yet exist
			EXEC usp_DetermineBBScoreException @prbs_CompanyId, 
											   @prbs_BBScoreId, 
											   @prbs_NewBBScore, 
											   @prbs_Recency,
											   @prbs_OldBBScore,
											   @UserId
		END

		COMMIT TRANSACTION

	END TRY
	BEGIN CATCH
		IF (xact_state() <> 0)
			Rollback
		EXEC usp_RethrowError
	END CATCH
  
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
	DECLARE @DeliveredPrice numeric(1,0)
	DECLARE @PAS numeric(1,0)

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
			@DeliveredPrice			= Delivered_Price,
			@PAS					= PAS,
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
		@DealtSeasonal,
		@DeliveredPrice,
		@PAS;
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
	Declare @prfs_StatementDate DateTime
	DECLARE @prfs_Reviewed nchar(1)
	DECLARE @prfs_ReviewedOld nchar(1)
	Declare @prfs_PublishedDate DateTime

    SELECT @prfs_FinancialID = prfs_FinancialID,
           @prfs_CompanyID = prfs_CompanyID,
           @prfs_UserID = prfs_CreatedBy,
           @prfs_StatementDate = prfs_StatementDate,
           @prfs_Publish = prfs_Publish,
           @prfs_Reviewed = prfs_Reviewed
      FROM inserted;

    SELECT @prfs_ReviewedOld = prfs_Reviewed
      FROM deleted;

	IF (@prfs_Publish = 'Y') BEGIN
		EXEC usp_ResetFinancialPublishFlag @prfs_FinancialID, @prfs_CompanyID, @prfs_UserID
		
		UPDATE PRFinancial 
		   SET prfs_PublishedDate = GETDATE()	
		 WHERE prfs_FinancialId = @prfs_FinancialID;
	END

	-- if this record is changing to reviewed, set some additional fields	
	IF ((@prfs_Reviewed = 'Y') AND ((@prfs_ReviewedOld IS NULL) OR (@prfs_ReviewedOld = 'N'))) BEGIN
		UPDATE PRFinancial 
		   SET prfs_ReviewedBy = @prfs_UserID, prfs_ReviewDate = getDate()
		 WHERE prfs_FinancialId = @prfs_FinancialID
	END

	-- Upon each Financial Statement insert, update the Company field comp_PRFinancialStatementDate
	Declare @Max datetime
	SELECT @Max = max(prfs_StatementDate) from PRFinancial WHERE prfs_CompanyId = @prfs_CompanyId
	UPDATE Company 
	   SET comp_PRFinancialStatementDate = @Max,
		   comp_UpdatedDate = getDate(), comp_Timestamp = getDate(), comp_UpdatedBy = @prfs_UserID 
	 WHERE comp_CompanyId = @prfs_CompanyId


	-- Make sure our JeopardyDate gets set
	EXEC usp_SetJeopardyDate @prfs_CompanyID, @prfs_UserID

    SET NOCOUNT OFF
END
GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRFinancial_del]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRFinancial_del]
GO
CREATE TRIGGER dbo.trg_PRFinancial_del
ON PRFinancial
FOR DELETE AS
BEGIN
    DECLARE @prfs_CompanyID int
	DECLARE @prfs_UserID int

    SELECT @prfs_CompanyID = prfs_CompanyID,
           @prfs_UserID = prfs_CreatedBy
      FROM deleted;

	-- Upon each Financial Statement insert, update the Company field comp_PRFinancialStatementDate
	Declare @Max datetime
	SELECT @Max = max(prfs_StatementDate) from PRFinancial WHERE prfs_CompanyId = @prfs_CompanyId
	UPDATE Company 
	   SET comp_PRFinancialStatementDate = @Max,
		   comp_UpdatedDate = getDate(), comp_Timestamp = getDate(), comp_UpdatedBy = @prfs_UserID 
	 WHERE comp_CompanyId = @prfs_CompanyId

            exec usp_SetJeopardyDate @prfs_CompanyID, @prfs_UserID

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
	DECLARE @prfs_Reviewed nchar(1)
	DECLARE @prfs_ReviewedOld nchar(1)

    SELECT @prfs_FinancialID = prfs_FinancialID,
           @prfs_CompanyID = prfs_CompanyID,
           @prfs_UserID = prfs_UpdatedBy,
           @prfs_Publish = prfs_Publish,
           @prfs_Reviewed = prfs_Reviewed
      FROM inserted;

    SELECT @prfs_PublishOld = prfs_Publish, @prfs_ReviewedOld = prfs_Reviewed
      FROM deleted;

	IF ((@prfs_Publish = 'Y') AND ((@prfs_PublishOld IS NULL) OR (@prfs_PublishOld = 'N'))) BEGIN
		EXEC usp_ResetFinancialPublishFlag @prfs_FinancialID, @prfs_CompanyID, @prfs_UserID
		
		UPDATE PRFinancial 
		   SET prfs_PublishedDate = GETDATE()	
		 WHERE prfs_FinancialId = @prfs_FinancialID;		
	END

	-- if this record is changing to reviewed, set some additional fields	
	IF ((@prfs_Reviewed = 'Y') AND ((@prfs_ReviewedOld IS NULL) OR (@prfs_ReviewedOld = 'N'))) BEGIN
		UPDATE PRFinancial 
		   SET prfs_ReviewedBy = @prfs_UserID, prfs_ReviewDate = getDate()
		 WHERE prfs_FinancialId = @prfs_FinancialID
	END

	-- Upon each Financial Statement insert, update the Company field comp_PRFinancialStatementDate
	Declare @Max datetime
	SELECT @Max = max(prfs_StatementDate) from PRFinancial WHERE prfs_CompanyId = @prfs_CompanyId
	UPDATE Company 
	   SET comp_PRFinancialStatementDate = @Max,
		   comp_UpdatedDate = getDate(), comp_Timestamp = getDate(), comp_UpdatedBy = @prfs_UserID 
	 WHERE comp_CompanyId = @prfs_CompanyId

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

	-- Note: Not required when updating a relationship as only the active flag should be modified.
	EXEC usp_CreateRelationshipTasks @prcr_LeftCompanyID, @prcr_RightCompanyID, @prcr_Type, @UserID

	EXEC usp_DeactivateCompanyRelationships @prcr_LeftCompanyID, @prcr_RightCompanyID, @UserID

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
	-- Handle marking a set of relation types inactive
	--
	IF ((ISNULL(@prcr_Active, 'N') <> 'Y') AND (ISNULL(@prcr_OldActive, 'N') = 'Y')) BEGIN	
		IF (@prcr_Type IN ('09', '10', '11', '12', '13', '14', '15', '16')) BEGIN
			 
			--
			-- Delete inactive relationships from
			-- any CL watchdog lists
			DELETE FROM PRWebUserListDetail
 				  WHERE prwuld_WebUserListDetailID IN 
						(
						SELECT DISTINCT prwuld_WebUserListDetailID
						  FROM PRWebUserList
							   INNER JOIN PRWebUserListDetail ON prwucl_WebUserListID = prwuld_WebUserListID
						 WHERE prwucl_TypeCode = 'CL'
						   AND prwuld_AssociatedID = @prcr_RightCompanyID 
						   AND prwuld_AssociatedType = 'C' 
						   AND prwucl_HQID = @prcr_LeftCompanyID
						);
		END
	END

    SET NOCOUNT OFF
END
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_Phone_ins]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_Phone_ins]
GO

CREATE TRIGGER [dbo].[trg_Phone_ins]
ON [dbo].[Phone]
FOR INSERT AS
BEGIN

	DECLARE @RecordID int
	DECLARE @AreaCode varchar(20), @Number varchar(34)
	 
	-- Get our key fields from the inserted record
	SELECT @RecordID = phon_PhoneId,
		   @AreaCode = phon_AreaCode,
		   @Number = phon_Number
	  FROM inserted
	 
	UPDATE Phone
	   SET phon_PhoneMatch = dbo.ufn_GetLowerAlpha (@AreaCode + @Number)
	 WHERE phon_PhoneId = @RecordID;
END
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PhoneLink_ins]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PhoneLink_ins]
GO

CREATE TRIGGER [dbo].[trg_PhoneLink_ins]
ON [dbo].[PhoneLink]
FOR INSERT AS
BEGIN

	DECLARE @CompanyID int, @RecordID int, @PersonID int, @EntityID int, @SequenceNumber int = 0
	DECLARE @Type varchar(40), @IsFax char(1), @IsPhone char(1)
	 
	-- Get our key fields from the inserted record
	SELECT @RecordID = plink_PhoneId,
	       @EntityID = plink_EntityId,
		   @CompanyID = plink_RecordId,
		   @PersonID = plink_RecordId,
		   @Type = plink_Type
	  FROM inserted

	IF @Type IN ('F', 'PF', 'SF', 'EFAX') BEGIN
		SET @IsFax = 'Y'
	END
	IF @Type NOT IN ('F', 'SF', 'EFAX') BEGIN
		SET @IsPhone = 'Y'
	END

	-- Company Phone Records
	IF (@EntityID = 5) BEGIN
		-- Get our current max sequence value excluding the current record.  
		SELECT @SequenceNumber = ISNULL(MAX([phon_PRSequence]), -1) 
		  FROM inserted
			   INNER JOIN Phone ON plink_PhoneID = phon_PhoneID
		 WHERE plink_RecordId = @CompanyID
		-- Increment it
		SET @SequenceNumber = @SequenceNumber + 1

		IF (@IsPhone='Y') BEGIN
			DECLARE @Count int  = 0
			SELECT @Count = COUNT(1)
			  FROM vPRCompanyPhone
		     WHERE plink_RecordId = @CompanyID
			   AND phon_PRIsPhone='Y'

			-- If this if our first phone,
			-- go set the appropriate attention lines
			IF (@Count = 0) BEGIN
				UPDATE PRAttentionline
				   SET prattn_PhoneID = @RecordID
				 WHERE prattn_PhoneID IS NULL
				   AND prattn_ItemCode = 'TES-V'
				   AND prattn_CompanyID = @CompanyID;
			END
		END
	END

	UPDATE Phone
	   SET phon_PRIsFax = @IsFax,
		   phon_PRIsPhone = @IsPhone,
		   phon_PRSequence = @SequenceNumber
	 WHERE phon_PhoneId = @RecordID;

END
GO



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_Phone_upd]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_Phone_upd]
GO

CREATE TRIGGER [dbo].[trg_Phone_upd]
ON [dbo].[Phone]
FOR UPDATE AS
BEGIN

	DECLARE @RecordID int, @UserID int, @CompanyID int
	DECLARE @AreaCode varchar(20), @Number varchar(34)
	DECLARE @OldAreaCode varchar(20), @OldNumber varchar(34)
	
	 
	-- Get our key fields from the inserted record
	SELECT @RecordID = phon_PhoneId,
		   @AreaCode = phon_AreaCode,
		   @Number = phon_Number,
		   @UserID = Phon_UpdatedBy
	  FROM inserted;

	SELECT @OldAreaCode = phon_AreaCode,
		   @OldNumber = phon_Number
	  FROM deleted;


	IF ((@OldAreaCode != @AreaCode) OR (@OldNumber != @Number)) BEGIN
		UPDATE Phone
		   SET phon_PhoneMatch = dbo.ufn_GetLowerAlpha (@AreaCode + @Number)
		 WHERE phon_PhoneId = @RecordID;
	END

	SELECT @CompanyID = prattn_CompanyID
	  FROM inserted
	       INNER JOIN PRAttentionLine ON Phon_PhoneId = prattn_PhoneID AND prattn_ItemCode = 'BILL';

	IF (@CompanyID IS NOT NULL) BEGIN
		INSERT INTO PRChangeDetection (prchngd_CompanyID, prchngd_ChangeType, prchngd_AssociatedID, prchngd_AssociatedType, prchngd_CreatedBy, prchngd_UpdatedBy)
		VALUES (@CompanyID, 'Update', @RecordID, 'Phone', @UserID, @UserID);	
	END	
	
END
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PhoneLink_upd]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PhoneLink_upd]
GO

CREATE TRIGGER [dbo].[trg_PhoneLink_upd]
ON PhoneLink
FOR UPDATE AS
BEGIN

	DECLARE @RecordID int
	DECLARE @Type varchar(40), @OldType varchar(40), @IsPhone char(1), @IsFax char(1)
	
	 
	-- Get our key fields from the inserted record
	SELECT @RecordID = plink_PhoneId,
		   @Type = plink_Type
	  FROM inserted;

	SELECT @OldType = plink_Type
	  FROM deleted;


	
	IF (@OldType != @Type) BEGIN
		IF @Type IN ('F', 'PF', 'SF', 'EFAX') BEGIN
			SET @IsFax = 'Y'
		END

		IF @Type NOT IN ('F', 'SF', 'EFAX') BEGIN
			SET @IsPhone = 'Y'
		END
	 
		UPDATE Phone
		   SET phon_PRIsFax = @IsFax,
			   phon_PRIsPhone = @IsPhone
		 WHERE phon_PhoneId = @RecordID;	
	END
END
GO




/*
	Assigns slot and sequence numbers for a newly inserted Email record
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_EmailLink_ins]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
	drop trigger [dbo].[trg_EmailLink_ins]
GO

CREATE TRIGGER [dbo].[trg_EmailLink_ins] ON [dbo].[EmailLink]
FOR INSERT AS
BEGIN

	DECLARE @CompanyID int, @RecordID int, @PersonID int, @EntityID int, @SequenceNumber int
	 
	-- Get our key fields from the inserted record
	SELECT @RecordID = elink_emailId,
	       @EntityID = elink_EntityId,
		   @CompanyID = elink_RecordId,
		   @PersonID = elink_RecordId
	  FROM inserted
	 
	-- Company Phone Records
	IF (@EntityID = 5) BEGIN
		-- Get our current max sequence value excluding the current record.  
		SELECT @SequenceNumber = ISNULL(MAX([emai_PRSequence]), -1) 
		  FROM inserted
			   INNER JOIN Email ON elink_EmailID = emai_EmailID
		 WHERE elink_RecordId = @CompanyID

		-- Increment it
		SET @SequenceNumber = @SequenceNumber + 1

		UPDATE Email
		   SET emai_PRSequence = @SequenceNumber
		 WHERE emai_EmailId = @RecordID;		
	END
END
GO

/*

      Assigns slot number for a newly inserted Address_Link record

*/
CREATE OR ALTER TRIGGER [dbo].[trg_Address_Link_ins]
ON [dbo].[Address_Link]
FOR INSERT AS
BEGIN

	DECLARE @CompanyID int, @RecordID int, @AddressCount int, @AddressID int
	DECLARE @DefaultTax char(1), @UserID int, @CountryID int

	-- Get our key fields from the inserted record
	SELECT @RecordID = adli_AddressLinkId,
           @AddressID = adli_AddressID,
		   @CompanyID = adli_CompanyId,
		   @CountryID = prcn_CountryID,
		   @DefaultTax = adli_PRDefaultTax,
		   @UserID = AdLi_CreatedBy
	  FROM inserted
	       LEFT OUTER JOIN Address WITH (NOLOCK) ON adli_AddressID = addr_AddressID
		   LEFT OUTER JOIN vPRLocation ON addr_PRCityID = prci_CityID;

	SELECT @AddressCount = COUNT(1) 
	  FROM Address_Link
	 WHERE adli_CompanyId = @CompanyID

	-- If this if our first address,
    -- go set the appropriate attention lines
	IF (@AddressCount = 1) BEGIN

		UPDATE PRAttentionline
           SET prattn_AddressID = @AddressID
         WHERE prattn_AddressID IS NULL
           AND prattn_EmailID IS NULL
           AND prattn_PhoneID IS NULL
           AND prattn_ItemCode IN ('BILL', 'ADVBILL', 'JEP-M', 'LRL', 'TES-M')
           AND prattn_CompanyID = @CompanyID;

        -- If Not USA or Canada, set the wire transfer flag
		IF (ISNULL(@CountryID, 0) >= 3) BEGIN
			UPDATE PRAttentionline
			   SET prattn_IncludeWireTransferInstructions = 'Y'
			 WHERE prattn_AddressID = @AddressID
			   AND prattn_ItemCode IN ('BILL', 'ADVBILL')
			   AND prattn_CompanyID = @CompanyID;
		END
	END

	IF (@DefaultTax = 'Y') BEGIN
		EXEC usp_UpdateTaxCode @CompanyID, @AddressID, @UserID
	END
END
GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_Address_Link_upd]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_Address_Link_upd]
GO

CREATE TRIGGER [dbo].[trg_Address_Link_upd]
ON [dbo].[Address_Link]
FOR UPDATE AS
BEGIN

	DECLARE @CompanyID int, @AddressID int
	DECLARE @DefaultTax char(1), @UserID int
	DECLARE @OldDefaultTax char(1)

	-- Get our key fields from the updated record
	SELECT @AddressID = adli_AddressID,
		   @CompanyID = adli_CompanyId,
		   @DefaultTax = ISNULL(adli_PRDefaultTax, 'N'),
		   @UserID = AdLi_CreatedBy
	  FROM inserted;

	SELECT @OldDefaultTax = ISNULL(adli_PRDefaultTax, 'N')
	  FROM deleted;

	IF (@DefaultTax = 'Y') AND (@OldDefaultTax = 'N') BEGIN
		EXEC usp_UpdateTaxCode @CompanyID, @AddressID, @UserID
	END
END
GO


CREATE OR ALTER TRIGGER dbo.trg_Company_upd
ON Company
FOR UPDATE AS
BEGIN

	-- *********************************************************************************
	-- Perform changes for the CompanyListing requirements

	DECLARE @ListingStatus varchar(40), @OldListingStatus varchar(40),@Type varchar(40), @OldType varchar(40)
    DECLARE @IndustryType varchar(40), @TradeStyle varchar(104), @Name varchar(104), @OldName varchar(104)
    DECLARE @LegalName varchar(104), @OldLegalName varchar(104), @CorrTradestyle varchar(104), @OldCorrTradestyle varchar(104)
	DECLARE @TMFMAward char(1), @OldTMFMAward char(1), @PublishLogo char(1), @OldPublishLogo char(1)
	DECLARE @PublishUnloadHours char(1), @OldPublishUnloadHours char(1)
	DECLARE @PROnlineOnly char(1), @OldPROnlineOnly char(1), @LocalSource char(1), @OldLocalSource char(1)
	DECLARE @IntlTradeAssoc char(1), @OldIntlTradeAssoc char(1)
	DECLARE @OriginalName varchar(104), @OldOriginalName varchar(104)
	DECLARE @OldName1 varchar(104), @OldOldName1 varchar(104)
	DECLARE @OldName2 varchar(104), @OldOldName2 varchar(104)
	DECLARE @OldName3 varchar(104), @OldOldName3 varchar(104)
	DECLARE @Logo varchar(255), @OldLogo varchar(255)

	DECLARE @BranchCount int, @Index int, @BranchID int, @HQID int
	DECLARE @TrxId int, @UserID int, @AssignedToUserID int, @ListingCityID int
	DECLARE @DLCount int, @OldListingCityID int
	DECLARE @ServiceCnt int;
				
	DECLARE @DateTime datetime

	DECLARE @Branches table (
		Ndx int identity(1,1) Primary Key,
		BranchID int
	)

	SELECT @HQID = comp_CompanyID,
	       @Name = comp_Name,
	       @LegalName = comp_PRLegalName,
	       @CorrTradestyle = comp_PRCorrTradestyle,
           @ListingStatus = comp_PRListingStatus,
		   @Type = comp_PRType,
           @IndustryType = comp_PRIndustryType,
           @ListingCityID = comp_PRListingCityID,
           @TradeStyle = comp_PRBookTradestyle,
           @TMFMAward = comp_PRTMFMAward,
           @PublishLogo = comp_PRPublishLogo,
           @PublishUnloadHours = comp_PRPublishUnloadHours,
		   @OriginalName = comp_PROriginalName,
		   @OldName1 = comp_PROldName1,
		   @OldName2 = comp_PROldName2,
		   @OldName3 = comp_PROldName3,
		   @UserID = comp_UpdatedBy,
		   @PROnlineOnly = comp_PROnlineOnly,
		   @LocalSource = comp_PRLocalSource,
		   @IntlTradeAssoc = comp_PRIsIntlTradeAssociation,
		   @Logo = comp_PRLogo
	  FROM inserted;

	SELECT @OldName = comp_Name,
	       @OldLegalName = comp_PRLegalName,
	       @OldCorrTradestyle = comp_PRCorrTradestyle,
	       @OldListingStatus = comp_PRListingStatus,
		   @OldType = comp_PRType,
	       @OldListingCityID = comp_PRListingCityID,
           @OldTMFMAward = comp_PRTMFMAward,
           @OldPublishLogo = comp_PRPublishLogo,
           @OldPublishUnloadHours = comp_PRPublishUnloadHours,
		   @OldOriginalName = comp_PROriginalName,
		   @OldOldName1 = comp_PROldName1,
		   @OldOldName2 = comp_PROldName2,
		   @OldOldName3 = comp_PROldName3,
		   @OldPROnlineOnly = comp_PROnlineOnly,
		   @OldLocalSource = comp_PRLocalSource,
		   @OldIntlTradeAssoc = comp_PRIsIntlTradeAssociation,
		   @OldLogo = comp_PRLogo
	  FROM deleted;

	IF ((@CorrTradestyle <> @OldCorrTradestyle) OR
	    (ISNULL(@PublishUnloadHours, 'N') <> ISNULL(@OldPublishUnloadHours, 'N')))
	 BEGIN
	
		INSERT INTO PRChangeDetection (prchngd_CompanyID, prchngd_ChangeType, prchngd_AssociatedID, prchngd_AssociatedType, prchngd_CreatedBy, prchngd_UpdatedBy)
		VALUES (@HQID, 'Update', @HQID, 'Company', @UserID, @UserID);	
	END



	-- Note that we do not do NULL checks because ListingStatus should always be set to a value
	-- it is required, but is not a "database required" field
	-- Is the company being listed
	IF (@OldListingStatus not in ('L', 'H', 'LUV') AND 
		@ListingStatus in ('L', 'H', 'LUV') ) BEGIN
		
		SELECT @DLCount = COUNT(1) FROM PRDescriptiveLine WHERE prdl_CompanyId = @HQID;
		
		UPDATE Company 
		   SET comp_PRListedDate = GETDATE(), 
		       comp_PRDelistedDate = NULL ,
		       comp_PRDLCountWhenListed = @DLCount
		 WHERE comp_companyid = @HQID;
	END


	IF (@OldListingStatus not in ('L', 'H', 'LUV') AND 
		@ListingStatus in ('L', 'LUV') ) BEGIN

		IF (@IndustryType = 'L') BEGIN
			DECLARE @Status varchar(10)
			SET @Status = 'P'
		 
			-- If this is a newly listed company than we need to
			-- create a credit sheet item
			DECLARE @NextId int
			EXEC usp_getNextId 'PRCreditSheet', @NextId OUTPUT

			INSERT INTO PRCreditSheet (prcs_CreditSheetId, prcs_CompanyId, prcs_Tradestyle, prcs_CityID, prcs_Status, prcs_AuthorId, prcs_Change, prcs_PublishableDate, prcs_KeyFlag, prcs_NewListing)
			VALUES (@NextId, @HQID, @TradeStyle, @ListingCityID, @Status, @UserID, dbo.ufn_GetListingFromCompany2(@HQID, 2, 0, 0), GETDATE(), 'Y', 'Y');

			UPDATE Company 
				SET comp_PRLastPublishedCSDate = GETDATE()
				WHERE comp_CompanyID = @HQID;
		END

	END
	
	IF (@OldListingStatus <> @ListingStatus) BEGIN
	
		-- Look to see if this company has the standard attention lines
		-- If not, then create them.
		DECLARE @HasAttn char(1)
		SELECT @HasAttn = 'Y' 
		  FROM PRAttentionLine 
		 WHERE prattn_CompanyID=@HQID
		   AND prattn_ItemCode = 'LRL';

		IF (@HasAttn IS NULL) BEGIN

			INSERT INTO PRAttentionLine (prattn_CompanyID, prattn_ItemCode, prattn_CreatedBy, prattn_UpdatedBy)
			VALUES (@HQID, 'LRL', @UserID, @UserID);

			INSERT INTO PRAttentionLine (prattn_CompanyID, prattn_ItemCode, prattn_CreatedBy, prattn_UpdatedBy)
			VALUES (@HQID, 'JEP-M', @UserID, @UserID);

			INSERT INTO PRAttentionLine (prattn_CompanyID, prattn_ItemCode, prattn_CreatedBy, prattn_UpdatedBy)
			VALUES (@HQID, 'JEP-E', @UserID, @UserID);

			INSERT INTO PRAttentionLine (prattn_CompanyID, prattn_ItemCode, prattn_CreatedBy, prattn_UpdatedBy)
			VALUES (@HQID, 'TES-E', @UserID, @UserID);

			IF (@IndustryType <> 'L') BEGIN
				INSERT INTO PRAttentionLine (prattn_CompanyID, prattn_ItemCode, prattn_CreatedBy, prattn_UpdatedBy)
				VALUES (@HQID, 'TES-M', @UserID, @UserID);
			END
			
			INSERT INTO PRAttentionLine (prattn_CompanyID, prattn_ItemCode, prattn_CreatedBy, prattn_UpdatedBy)
			VALUES (@HQID, 'TES-V', @UserID, @UserID);

			INSERT INTO PRAttentionLine (prattn_CompanyID, prattn_ItemCode, prattn_CreatedBy, prattn_UpdatedBy)
			VALUES (@HQID, 'BILL', @UserID, @UserID);
    
			INSERT INTO PRAttentionLine (prattn_CompanyID, prattn_ItemCode, prattn_CreatedBy, prattn_UpdatedBy)
			VALUES (@HQID, 'ADVBILL', @UserID, @UserID);

			INSERT INTO PRAttentionLine (prattn_CompanyID, prattn_ItemCode, prattn_CreatedBy, prattn_UpdatedBy)
			VALUES (@HQID, 'ARD', @UserID, @UserID);
		END    
	END

    -- Delisted, but has active services (Defect 2327)
    If @OldListingStatus IN ('L', 'H') AND @ListingStatus Not In ('L', 'H', 'N1')
    Begin
        -- Add a task for sales reps if the new listing is not 'service only' and there are active service codes
        SELECT @ServiceCnt = Count(1) 
          FROM PRService WITH (NOLOCK) 
         WHERE prse_CompanyID = @HQID 
           AND prse_ServiceCode <> 'DL';

        SET @AssignedToUserID = dbo.ufn_GetPRCoSpecialistUserId(@HQID, 4); --Customer Service

        If @ServiceCnt > 0 Begin
            Set @DateTime = GetDate();

            EXEC usp_CreateTask @StartDateTime = @DateTime,
                                @DueDateTime = @DateTime,
                                @CreatorUserId = @UserID,
                                @AssignedToUserId = @AssignedToUserID,
                                @TaskNotes = 'Company has been delisted, but is not service only and has active service code(s).',
                                @RelatedCompanyId = @HQID,
                                @Status = 'Pending',
                                @PRCategory = 'L',
								@Subject = 'Company was delisted but has active services.';
        End
    End

    -- Delisted
	IF (@OldListingStatus in ('L', 'H', 'LUV') AND 
		@ListingStatus not in ('L', 'H', 'LUV') ) BEGIN

		-- if the delisting occurs, set the comp_PRDelistedDate
		UPDATE Company SET comp_PRDelistedDate = GETDATE() WHERE comp_companyid = @HQID

		INSERT INTO PROwnershipHistory (proh_CompanyID, proh_PersonID, proh_Percentage, proh_Title, proh_SortField)
		SELECT PeLi_CompanyID,
		       pers_PersonID, 
			   peli_PRPctOwned, 
			   peli_PRTitle, 
			   tcc.capt_Order AS Sort
		  FROM Person_Link WITH (NOLOCK)
			   INNER JOIN Person  WITH (NOLOCK) ON PeLi_PersonId = pers_PersonID
			   INNER JOIN custom_captions tcc WITH (NOLOCK) ON tcc.capt_family = 'pers_TitleCode' and tcc.capt_code = peli_PRTitleCode 
		 WHERE peli_PROwnershipRole = 'RCO'
		   AND peli_PRStatus IN ('1', '2')
		   AND peli_PRBRPublish = 'Y'
		   AND PeLi_CompanyID = @HQID
		   AND PeLi_Deleted IS NULL;


		-- if the delisting occurs, associated people to this company are marked NLC
		EXEC usp_SetCompanyPersonsStatus @HQID, '3', @UserID

		-- Branch updates only occur if a HQ is being delisted
		IF (@Type = 'H') BEGIN
		
			INSERT INTO @Branches (BranchID)
			SELECT comp_CompanyID 
			  FROM company WITH (NOLOCK)
			 WHERE comp_PRHQID = @HQID
			   AND comp_PRType = 'B'
			   AND comp_PRListingStatus in('L', 'H', 'LUV', 'N1', 'N2')
			   AND comp_Deleted IS NULL;

			SET @BranchCount = @@ROWCOUNT
			SET @Index = 1

			WHILE (@Index <= @BranchCount) BEGIN

				SELECT @BranchID = BranchID
				  FROM @Branches
				 WHERE Ndx = @Index;

				-- Open a transaction
				EXEC @TrxId = usp_CreateTransaction 
								@UserId = @UserId,
								@prtx_CompanyId = @BranchID,
								@prtx_Explanation = 'Delisted as a result of HQ being delisted.'

				-- Because the "Recursive Triggers Enabled" option is off in our DB, we need
				-- to manually execute the "Delisting" logic for all associated branckes

				-- Set the Delisted Date				
				UPDATE Company
				   SET comp_PRListingStatus = @ListingStatus,
				       comp_PRDelistedDate = GETDATE(),
					   comp_UpdatedBy = @UserID,
					   comp_UpdatedDate = GETDATE(),
					   comp_Timestamp = GETDATE()
				 WHERE comp_CompanyID = @BranchID;

				-- Mark associated persons as "NLC"
				EXEC usp_SetCompanyPersonsStatus @BranchID, '3', @UserID

				-- If our HQ is out of business, then
				-- mark all of the relationships for 
				-- the associated branch as inactive.
				IF (@OldListingStatus NOT IN ('N3', 'N5', 'N6') AND 
					@ListingStatus IN ('N3', 'N5', 'N6')) BEGIN

					UPDATE PRCompanyRelationship
					   SET prcr_Active = NULL,
						   prcr_UpdatedDate = GETDATE(),
						   prcr_UpdatedBy = @UserID,
						   prcr_TimeStamp = GETDATE() 
					 WHERE prcr_Active = 'Y'
					   AND (prcr_RightCompanyID = @BranchID OR prcr_LeftCompanyID = @BranchID)
					   AND prcr_Type NOT IN ('27','28','29');
				END

				SET @ServiceCnt = 0
				SELECT @ServiceCnt = Count(1) 
				  FROM PRService WITH (NOLOCK) 
				 WHERE prse_CompanyID = @BranchID 
				   AND prse_NextAnniversaryDate Is Not Null;

				IF @ServiceCnt > 0 BEGIN
					SET @AssignedToUserID = dbo.ufn_GetPRCoSpecialistUserId(@BranchID, 4);
					SET @DateTime = GetDate();

					EXEC usp_CreateTask @StartDateTime = @DateTime,
										@DueDateTime = @DateTime,
										@CreatorUserId = @UserID,
										@AssignedToUserId = @AssignedToUserID,
										@TaskNotes = 'Company has been delisted as a result of HQ being delisted, but is not service only and has active service code(s).',
										@RelatedCompanyId = @BranchID,
										@Status = 'Pending',
										@PRCategory = 'L',
										@Subject = 'Branch was delisted due to HQ delisting, but has active services.';
				END


				-- close the opened transaction
				UPDATE PRTransaction SET prtx_Status = 'C' WHERE prtx_TransactionId = @TrxId

				SET @Index = @Index + 1
			END
		END
	END

	-- If we go from "Service Only" to closed
	--  mark all connected persons NLC
	IF (@OldListingStatus in ('N1') AND 
		@ListingStatus not in ('N1', 'L', 'H', 'LUV') ) BEGIN

		EXEC usp_SetCompanyPersonsStatus @HQID, '3', @UserID
	END



	--
    -- If our company is out of business, then
    -- mark all of the relationships inactive.
	IF (@OldListingStatus NOT IN ('N3', 'N5', 'N6') AND 
		@ListingStatus IN ('N3', 'N5', 'N6')) BEGIN

		UPDATE PRCompanyRelationship
           SET prcr_Active = NULL,
               prcr_UpdatedDate = GETDATE(),
               prcr_UpdatedBy = @UserID,
               prcr_TimeStamp = GETDATE() 
         WHERE prcr_Active = 'Y'
           AND (prcr_RightCompanyID = @HQID OR prcr_LeftCompanyID = @HQID)
           AND prcr_Type NOT IN ('27','28','29');

	END

	-- If the company is newly listed, create a task
	IF ((@OldListingStatus NOT IN ('L')) AND 
		(@ListingStatus = 'L') AND
		(@LocalSource IS NULL) AND
		(@IntlTradeAssoc IS NULL)) BEGIN

		SET @AssignedToUserID = dbo.ufn_GetPRCoSpecialistUserId(@HQID, 3)
		SET @DateTime = GETDATE()

		EXEC usp_CreateTask @StartDateTime = @DateTime, 
							@DueDateTime = @DateTime, 
							@CreatorUserId = @UserID, 
							@AssignedToUserId = @AssignedToUserID, 
							@TaskNotes = 'Company has been marked Listed.  Please review the listing for accuracy',	
							@RelatedCompanyId = @HQID,	
							@Status = 'Pending',
                            @PRCategory = 'L',
							@Subject = 'Newly Listed - Review for Accuracy';
	END

	--
    --  If this company no longer has the award, check to see if any
    --  branches have it too
    --
	IF ((@OldTMFMAward = 'Y') AND
        (@TMFMAward IS NULL)) BEGIN

		DECLARE @Count int

		SELECT @Count = COUNT(1) 
          FROM Company WITH (NOLOCK) 
         WHERE comp_PRHQID = @HQID 
           AND comp_PRType ='B' 
           AND comp_PRTMFMAward = 'Y';

	
		IF (@Count > 0) BEGIN
			SET @AssignedToUserID = dbo.ufn_GetPRCoSpecialistUserId(@HQID, 3)
			SET @DateTime = GETDATE()

			EXEC usp_CreateTask @StartDateTime = @DateTime, 
								@DueDateTime = @DateTime, 
								@CreatorUserId = @UserID, 
								@AssignedToUserId = @AssignedToUserID, 
								@TaskNotes = 'TMFM Award was removed this company but found branches that have the award flag set.',	
								@RelatedCompanyId = @HQID,	
								@Status = 'Pending',
								@PRCategory = 'L',
								@Subject = 'TM status removed from HQ. Analyst to review Branch records with award flag set.';
		END
	END


	-- End CompanyListing requirements
	-- *********************************************************************************
	
	-- *********************************************************************************
	-- Begin Updates of Company Search and full name values
	IF ((@Name <> @OldName) OR
	    (@ListingCityID <> @OldListingCityID)OR
	    (@Type <> @OldType)) BEGIN
	
		-- if the comp_name field changed refresh both the full name and the duplicate search value
		UPDATE PRCompanySearch
		   SET prcse_FullName = dbo.ufn_getCompanyFullName(comp_companyid),
			   prcse_NameAlphaOnly = dbo.ufn_getLowerAlpha(comp_Name),
			   prcse_NameMatch = dbo.GetLowerAlpha(dbo.ufn_PrepareCompanyName(comp_Name)),
			   prce_WordPressSlug =  CASE comp_PRIndustryType WHEN 'L' THEN '/services/find-companies/profile/' ELSE '/find-produce-companies/profile/' END  + dbo.ufn_PrepareSlugValue(prcn_Country) +  dbo.ufn_PrepareSlugValue(ISNULL(prst_Abbreviation, prst_State)) + dbo.ufn_PrepareSlugValue(prci_City) + dbo.ufn_PrepareSlugValue(comp_Name) + CAST(comp_CompanyID as varchar(10)) + '/',
               prcse_UpdatedBy = comp_UpdatedBy,
			   prcse_UpdatedDate = comp_UpdatedDate,
			   prcse_Timestamp = comp_Timestamp
		  FROM inserted i 
		       INNER JOIN vPRLocation ON i.comp_PRListingCityID = prci_CityID
		 WHERE prcse_CompanyId = comp_companyid;
	END		 

		 
	If (ISNULL(@LegalName, 'x') <> ISNULL(@OldLegalName, 'x')) BEGIN
		UPDATE PRCompanySearch
		   SET prcse_LegalNameMatch = CASE WHEN comp_PRLegalName IS NOT NULL THEN dbo.GetLowerAlpha(dbo.ufn_PrepareCompanyName(comp_PRLegalName)) ELSE NULL END,
		 	   prcse_UpdatedBy = comp_UpdatedBy,
			   prcse_UpdatedDate = comp_UpdatedDate,
			   prcse_Timestamp = comp_Timestamp
		  FROM inserted i 
		 WHERE prcse_CompanyId = comp_companyid	;
	END

	If (ISNULL(@OriginalName, 'x') <> ISNULL(@OldOriginalName, 'x')) BEGIN
		UPDATE PRCompanySearch
		   SET prcse_OriginalNameMatch = CASE WHEN comp_PROriginalName IS NOT NULL THEN dbo.GetLowerAlpha(dbo.ufn_PrepareCompanyName(comp_PROriginalName)) ELSE NULL END,
		 	   prcse_UpdatedBy = comp_UpdatedBy,
			   prcse_UpdatedDate = comp_UpdatedDate,
			   prcse_Timestamp = comp_Timestamp
		  FROM inserted i 
		 WHERE prcse_CompanyId = comp_companyid	;
	END

	If (ISNULL(@OldName1, 'x') <> ISNULL(@OldOldName1, 'x')) BEGIN
		UPDATE PRCompanySearch
		   SET prcse_OldName1Match = CASE WHEN comp_PROldName1 IS NOT NULL THEN dbo.GetLowerAlpha(dbo.ufn_PrepareCompanyName(comp_PROldName1)) ELSE NULL END,
		 	   prcse_UpdatedBy = comp_UpdatedBy,
			   prcse_UpdatedDate = comp_UpdatedDate,
			   prcse_Timestamp = comp_Timestamp
		  FROM inserted i 
		 WHERE prcse_CompanyId = comp_companyid	;
	END

	If (ISNULL(@OldName2, 'x') <> ISNULL(@OldOldName2, 'x')) BEGIN
		UPDATE PRCompanySearch
		   SET prcse_OldName2Match = CASE WHEN comp_PROldName2 IS NOT NULL THEN dbo.GetLowerAlpha(dbo.ufn_PrepareCompanyName(comp_PROldName2)) ELSE NULL END,
		 	   prcse_UpdatedBy = comp_UpdatedBy,
			   prcse_UpdatedDate = comp_UpdatedDate,
			   prcse_Timestamp = comp_Timestamp
		  FROM inserted i 
		 WHERE prcse_CompanyId = comp_companyid	;
	END

	If (ISNULL(@OldName3, 'x') <> ISNULL(@OldOldName3, 'x')) BEGIN
		UPDATE PRCompanySearch
		   SET prcse_OldName3Match = CASE WHEN comp_PROldName3 IS NOT NULL THEN dbo.GetLowerAlpha(dbo.ufn_PrepareCompanyName(comp_PROldName3)) ELSE NULL END,
		 	   prcse_UpdatedBy = comp_UpdatedBy,
			   prcse_UpdatedDate = comp_UpdatedDate,
			   prcse_Timestamp = comp_Timestamp
		  FROM inserted i 
		 WHERE prcse_CompanyId = comp_companyid	;
	END



	If (@CorrTradestyle <> @OldCorrTradestyle) BEGIN
		UPDATE PRCompanySearch
		   SET prcse_CorrTradestyleMatch = dbo.GetLowerAlpha(dbo.ufn_PrepareCompanyName(comp_PRCorrTradestyle)),
		 	   prcse_UpdatedBy = comp_UpdatedBy,
			   prcse_UpdatedDate = comp_UpdatedDate,
			   prcse_Timestamp = comp_Timestamp
		  FROM inserted i 
		 WHERE prcse_CompanyId = comp_companyid;
	END
	
		 
	-- End Updates of Company Search and full name values
	-- *********************************************************************************

	-- Update the record's HQID to match the CompanyID if it's an hq.
	UPDATE Company
       SET comp_PRHQId = i.comp_CompanyID
      FROM Inserted i 
           INNER JOIN Company c On (c.comp_CompanyID = i.comp_CompanyID)
     WHERE i.comp_PRType = 'H';


	IF (@Type = 'B' AND @OldType = 'H') BEGIN

		-- Move the SS Files to the new HQ.
		UPDATE PRSSFile
		   SET prss_ClaimantCompanyId = i.comp_PRHQID
	      FROM inserted i
		 WHERE prss_ClaimantCompanyId = i.comp_CompanyID;

		UPDATE PRSSFile
		   SET prss_RespondentCompanyId = i.comp_PRHQID
	      FROM inserted i
		 WHERE prss_RespondentCompanyId = i.comp_CompanyID;
		
		UPDATE PRSSFile
		   SET prss_3rdPartyCompanyId = i.comp_PRHQID
	      FROM inserted i
		 WHERE prss_3rdPartyCompanyId = i.comp_CompanyID;
	END

	IF (@Type = 'H' AND @OldType = 'B') BEGIN
		UPDATE Company
		  SET comp_PRInvestigationMethodGroup = 'A'
		WHERE comp_CompanyID = @HQID

		UPDATE PRBBScore
		   SET prbs_PRPublish = 'Y'
		 WHERE prbs_CompanyID = @HQID
		   AND prbs_NewBBScore > 0
		   AND prbs_ConfidenceScore >= 6
		   AND (CONVERT(int, prbs_Recency) < 12)

		-- Fake out our date to force a new BBScore guage
		-- image to be created.
		UPDATE PRBBScore
		   SET prbs_CreatedDate = GETDATE()
		 WHERE prbs_CompanyID = @HQID
		   AND prbs_PRPublish = 'Y'
		   AND prbs_Current = 'Y'

	END

	IF (@Type <> @OldType) BEGIN
		UPDATE PRWebUser
		   SET prwu_HQID = i.comp_PRHQID
		  FROM inserted i
		 WHERE prwu_BBID = i.comp_CompanyID;
	END

	--
	--  In the scenario with the condition below, the Online Only flag is read-only
	--  on the CRM screen.  But it seems that CRM is not sending it to us when in
	--  read-only mode, so we have this hack here.
	--
	DECLARE @RowCount int

	UPDATE Company
	   SET comp_PROnlineOnly = 'Y'
	  FROM vPRLocation 
	 WHERE comp_CompanyID = @HQID
	   AND comp_PRListingCityID = prci_CityID
	   AND comp_PROnlineOnly IS NULL
	   AND (prcn_CountryID NOT IN (1, 2, 3)
	        OR comp_PRIndustryType = 'L');

	-- If we updated the Online Only flag due to the conditions above,
	-- then remove any transaction data so we don't confuse the users.
	SET @RowCount = @@ROWCOUNT
	IF (@RowCount > 0) BEGIN
		DELETE PRTransactionDetail
		  FROM PRTransaction
			   INNER JOIN PRTransactionDetail ON prtx_TransactionID = prtd_TransactionID
		 WHERE prtx_CompanyID = @HQID
		   AND prtd_EntityName = 'Company'
		   AND prtd_ColumnName = 'Online Only'
		   AND prtd_CreatedDate > DATEADD(minute, -2, GETDATE())
	END

	-- If this is an HQ
	-- and the Online Only flag just got turned on,
	-- set any branch location's Online Only
	-- flag on.
	IF ((@Type = 'H') AND
	    (@PROnlineOnly = 'Y') AND
		(@OldPROnlineOnly IS NULL)) BEGIN


		DECLARE @Branches2 table (
			Ndx int identity(1,1) Primary Key,
			BranchID int
		)

		INSERT INTO @Branches2 (BranchID)
		SELECT comp_CompanyID 
			FROM company WITH (NOLOCK)
			WHERE comp_PRType = 'B'
			AND comp_PROnlineOnly IS NULL
			AND comp_PRHQID = @HQID

		SET @BranchCount = @@ROWCOUNT
		SET @Index = 1

		WHILE (@Index <= @BranchCount) BEGIN

			SELECT @BranchID = BranchID
			  FROM @Branches2
			 WHERE Ndx = @Index;

			-- Open a transaction
			EXEC @TrxId = usp_CreateTransaction 
							@UserId = @UserId,
							@prtx_CompanyId = @BranchID,
							@prtx_Explanation = 'This branch was auto-marked as an online-only listing, when the HQ listing was marked online-only.'

			UPDATE Company
			   SET comp_PROnlineOnly = 'Y',
				   comp_PRDelistedDate = GETDATE(),
				   comp_UpdatedBy = @UserID,
				   comp_UpdatedDate = GETDATE(),
				   comp_Timestamp = GETDATE()
			 WHERE comp_CompanyID = @BranchID;

			-- close the opened transaction
			UPDATE PRTransaction SET prtx_Status = 'C' WHERE prtx_TransactionId = @TrxId

			SET @Index = @Index + 1
		END
	 END

	 IF ((@OldLocalSource = 'Y') AND
	     (@LocalSource IS NULL)) BEGIN

		 UPDATE Person 
		    SET pers_PRLocalSource = NULL,
				pers_UpdatedBy = @UserID,
				pers_UpdatedDate = GETDATE(),
				pers_Timestamp = GETDATE()
		   FROM Person_Link
		  WHERE pers_PersonID = peli_PersonID
		    AND pers_PRLocalSource = 'Y'
			AND peli_CompanyID = @HQID

	 END

	 IF (ISNULL(@OldLogo, '') <> ISNULL(@Logo, '') ) BEGIN
		SET @PublishLogo = NULL

		DECLARE @HasService CHAR(1) = NULL
		SELECT @HasService = 'Y' FROM PRService WHERE prse_HQID = @HQID AND prse_ServiceCode IN ('STANDARD', 'PREMIUM','ENTERPRISE', 'LOGO', 'LMBLOGO', 'LOGO-ADD', 'LMBLOGO-ADD')

		IF (@Logo IS NOT NULL) AND (@HasService IS NOT NULL) BEGIN
			SET @PublishLogo = 'Y'
		END

		UPDATE Company
		   SET comp_PRLogo = @Logo,
		       comp_PRPublishLogo = @PublishLogo
		 WHERE comp_PRHQID = @HQID;

	 END

	IF ISNULL(@PublishLogo, '') <> ISNULL(@OldPublishLogo, '')  BEGIN
		EXEC usp_UpdateListing @HQID
	END

END
Go

CREATE OR ALTER TRIGGER dbo.trg_Company_ins
ON Company
FOR INSERT AS
BEGIN
	-- ** Notice that this insert trigger ony handles single inserts into the company table
	--    not multi-insert statements

	-- *********************************************************************************
	-- Begin Insert of Company Search and full name values
	INSERT INTO PRCompanySearch
			([prcse_CreatedBy],[prcse_CreatedDate],[prcse_UpdatedBy],[prcse_UpdatedDate],[prcse_TimeStamp]
			,[prcse_CompanyId],[prcse_FullName],[prcse_NameAlphaOnly]
			,prcse_NameMatch, prcse_LegalNameMatch, prcse_CorrTradestyleMatch,
			prcse_OriginalNameMatch, prcse_OldName1Match, prcse_OldName2Match, prcse_OldName3Match, 
			prce_WordPressSlug)
      SELECT top 1 
			 comp_CreatedBy, comp_CreatedDate, comp_CreatedBy, comp_CreatedDate, comp_CreatedDate
			, comp_companyid
			, dbo.ufn_getCompanyFullName(comp_companyid)
			, dbo.ufn_getLowerAlpha(comp_Name)
            , prcse_NameMatch = dbo.GetLowerAlpha(dbo.ufn_PrepareCompanyName(comp_Name))
            , prcse_LegalNameMatch = CASE WHEN comp_PRLegalName IS NOT NULL THEN dbo.GetLowerAlpha(dbo.ufn_PrepareCompanyName(comp_PRLegalName)) ELSE NULL END
            , prcse_CorrTradestyleMatch = dbo.GetLowerAlpha(dbo.ufn_PrepareCompanyName(comp_PRCorrTradestyle))			
			, prcse_OriginalNameMatch = CASE WHEN comp_PROriginalName IS NOT NULL THEN dbo.GetLowerAlpha(dbo.ufn_PrepareCompanyName(comp_PROriginalName)) ELSE NULL END
            , prcse_OldName1Match = CASE WHEN comp_PROldName1 IS NOT NULL THEN dbo.GetLowerAlpha(dbo.ufn_PrepareCompanyName(comp_PROldName1)) ELSE NULL END
	        , prcse_OldName2Match = CASE WHEN comp_PROldName2 IS NOT NULL THEN dbo.GetLowerAlpha(dbo.ufn_PrepareCompanyName(comp_PROldName2)) ELSE NULL END
	        , prcse_OldName3Match = CASE WHEN comp_PROldName3 IS NOT NULL THEN dbo.GetLowerAlpha(dbo.ufn_PrepareCompanyName(comp_PROldName3)) ELSE NULL END
			, prce_WordPressSlug =  CASE comp_PRIndustryType WHEN 'L' THEN '/services/find-companies/profile/' ELSE '/find-produce-companies/profile/' END  + dbo.ufn_PrepareSlugValue(prcn_Country) +  dbo.ufn_PrepareSlugValue(ISNULL(prst_Abbreviation, prst_State)) + dbo.ufn_PrepareSlugValue(prci_City) + dbo.ufn_PrepareSlugValue(comp_Name) + CAST(comp_CompanyID as varchar(10)) + '/'
		FROM inserted
		     LEFT OUTER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID;
		
	-- End Updates of Company Search and full name values
	-- *********************************************************************************

	-- Update the newly inserted record's HQID if it's already an hq.
    -- If this is a Lumber company, ensure the Confidential Financial Statement flag is Yes.
	UPDATE Company
       SET comp_PRHQId = CASE c.comp_PRType WHEN 'H' THEN c.comp_CompanyID ELSE c.comp_PRHQID END,
           comp_PRConfidentialFS = CASE c.comp_PRIndustryType WHEN 'L' THEN '2' ELSE '1' END,
           comp_PRIsEligibleForEquifaxData = 'Y',
           comp_PRPublishPayIndicator = CASE c.comp_PRIndustryType WHEN 'L' THEN 'Y' ELSE NULL END,
           comp_PRListingCityID = CASE WHEN c.comp_PRListingCityID IS NULL THEN -1 WHEN c.comp_PRListingCityID = 0 THEN -1 ELSE c.comp_PRListingCityID END,
           comp_PRReceiveTES = 'Y',
		   comp_PRIgnoreTES = NULL,
		   comp_PRPublishDL = 'Y',
		   comp_PRPublishBBScore = 'Y',
		   comp_PRReceiveCSSurvey = 'Y', -- CASE WHEN prcn_CountryID = 2 THEN NULL ELSE 'Y' END,
		   comp_PRReceivePromoFaxes = 'Y', -- CASE WHEN prcn_CountryID = 2 THEN NULL ELSE 'Y' END,
		   comp_PRReceivePromoEmails = 'Y', -- CASE WHEN prcn_CountryID = 2 THEN NULL ELSE 'Y' END,
		   comp_PROnlineOnly = CASE WHEN c.comp_PRLocalSource = 'Y' THEN 'Y' WHEN c.comp_PRRetailerOnlineOnly = 'Y' THEN 'Y' WHEN c.comp_PRIsIntlTradeAssociation = 'Y' THEN 'Y' WHEN prcn_CountryID NOT IN (1, 2, 3) THEN 'Y' ELSE NULL END,
		   comp_PRReceivesBBScoreReport = 'Y'
      FROM Inserted i 
           INNER JOIN Company c ON c.comp_CompanyID = i.comp_CompanyID
		   LEFT OUTER JOIN vPRLocation ON c.comp_PRListingCityID = prci_CityID;

	--When inserting Branch, Copy HQ logo fields if HQ has published logo
	DECLARE @PRType nvarchar(40)
	SELECT @PRType = i.comp_PRType FROM Inserted i
	IF(@PRType = 'B') BEGIN
		UPDATE Company
			SET comp_PRLogo        = hq.comp_PRLogo,
				comp_PRPublishLogo = hq.comp_PRPublishLogo
		FROM Inserted i 
			INNER JOIN Company ON Company.comp_CompanyID = i.comp_CompanyID
			INNER JOIN Company hq ON hq.comp_CompanyID = i.comp_PRHQID
		WHERE hq.comp_PRPublishLogo = 'Y';
	END
	
	DECLARE @UserID int, @CompanyID int
	DECLARE @IndustryType varchar(40)
    DECLARE @Comp_Source nvarchar(40)
	
	SELECT @CompanyID = comp_CompanyID,
           @UserID = comp_CreatedBy,
           @IndustryType = comp_PRIndustryType,
           @Comp_Source = Comp_Source
      FROM inserted;

	INSERT INTO PRAttentionLine (prattn_CompanyID, prattn_ItemCode, prattn_CreatedBy, prattn_UpdatedBy)
    VALUES (@CompanyID, 'LRL', @UserID, @UserID);

	INSERT INTO PRAttentionLine (prattn_CompanyID, prattn_ItemCode, prattn_CreatedBy, prattn_UpdatedBy)
    VALUES (@CompanyID, 'JEP-M', @UserID, @UserID);

	INSERT INTO PRAttentionLine (prattn_CompanyID, prattn_ItemCode, prattn_CreatedBy, prattn_UpdatedBy)
    VALUES (@CompanyID, 'JEP-E', @UserID, @UserID);

	INSERT INTO PRAttentionLine (prattn_CompanyID, prattn_ItemCode, prattn_CreatedBy, prattn_UpdatedBy)
    VALUES (@CompanyID, 'TES-E', @UserID, @UserID);

	IF (@IndustryType <> 'L') BEGIN
		INSERT INTO PRAttentionLine (prattn_CompanyID, prattn_ItemCode, prattn_CreatedBy, prattn_UpdatedBy)
		VALUES (@CompanyID, 'TES-M', @UserID, @UserID);
	END
	
	INSERT INTO PRAttentionLine (prattn_CompanyID, prattn_ItemCode, prattn_CreatedBy, prattn_UpdatedBy)
    VALUES (@CompanyID, 'TES-V', @UserID, @UserID);

	INSERT INTO PRAttentionLine (prattn_CompanyID, prattn_ItemCode, prattn_CreatedBy, prattn_UpdatedBy)
    VALUES (@CompanyID, 'BILL', @UserID, @UserID);

	INSERT INTO PRAttentionLine (prattn_CompanyID, prattn_ItemCode, prattn_CreatedBy, prattn_UpdatedBy)
    VALUES (@CompanyID, 'ADVBILL', @UserID, @UserID);

	INSERT INTO PRAttentionLine (prattn_CompanyID, prattn_ItemCode, prattn_CreatedBy, prattn_UpdatedBy)
    VALUES (@CompanyID, 'ARD', @UserID, @UserID);
	    
	DECLARE @NextId int
	EXEC usp_getNextId 'PRCompanyIndicators', @NextId OUTPUT

	INSERT INTO PRCompanyIndicators (prci2_CompanyIndicatorID, prci2_CompanyID, prci2_CreatedBy, prci2_UpdatedBy)
	VALUES (@NextId, @CompanyID, @UserID, @UserID);

    --Defect 4564
	IF(@Comp_Source = 'CL') BEGIN
		DECLARE @InsideSalesUserId int
		SELECT  @InsideSalesUserId = prci_InsideSalesRepId 
			 FROM Company WITH (NOLOCK)
					INNER JOIN vPRLocation WITH (NOLOCK) on comp_PRListingCityId = prci_CityId
			 WHERE comp_CompanyId = @CompanyID

		DECLARE @OppoId int
		EXEC usp_getNextId 'Opportunity', @OppoId OUTPUT

		INSERT INTO Opportunity (oppo_OpportunityId, oppo_PrimaryCompanyID, oppo_AssignedUserID, Oppo_Note, oppo_Type, 
														 oppo_Status, oppo_Stage, oppo_PRPipeline, oppo_Opened,
														oppo_Source, oppo_PRTrigger,
														oppo_CreatedBy, oppo_CreatedDate, oppo_UpdatedBy, oppo_UpdatedDate, oppo_Timestamp)
		VALUES (@OppoId, @CompanyID, @InsideSalesUserId, 'New company created from reference list.', 'NEWM',
																'Open', 'Lead', 'M:TR', GETDATE(),
																'IB', 'Other',
																@UserId, GETDATE(), @UserId, GETDATE(), GETDATE());
	END
END
Go


CREATE OR ALTER TRIGGER dbo.trg_Person_Link_ins
ON Person_Link
FOR INSERT AS
BEGIN

	DECLARE @PersonID int, @CompanyID int, @UserID int, @PersonLinkID int, @Sequence int
	DECLARE @PRStatus varchar(40), @PROwnershipRole varchar(40), @PRTitleCode varchar(40)

	SELECT @PersonLinkID = PeLi_PersonLinkId,
	       @PersonID  = peli_PersonID,
           @CompanyID = peli_CompanyID,
		   @PRStatus  = peli_PRStatus,
           @PROwnershipRole = peli_PROwnershipRole,
		   @PRTitleCode = peli_prtitlecode,
           @UserID    = peli_CreatedBy
      FROM inserted;

	IF ((@PRStatus IN (1,2)) AND (@PROwnershipRole <> 'RCR')) BEGIN
		EXEC usp_CreateCompanyType29Relationship @PersonID, @CompanyID, @UserID
	END

	DECLARE @Count int
    SELECT @Count = COUNT(1) 
      FROM Person_Link 
     WHERE peli_CompanyID = @CompanyID 
       AND peli_PersonID <> @PersonID;

    IF (@Count = 0) BEGIN
		UPDATE PRAttentionline
           SET prattn_PersonID = @PersonID
         WHERE prattn_PersonID IS NULL
           AND prattn_CustomLine IS NULL
           AND prattn_ItemCode IN ('BILL', 'ADVBILL', 'JEP-M', 'JEP-E', 'LRL', 'TES-M', 'TES-E', 'TES-V', 'ARD')
           AND prattn_CompanyID = @CompanyID;
	END


	DECLARE @CompanyHasCustomPersonSort char(1)
	SELECT @CompanyHasCustomPersonSort = ISNULL(comp_PRHasCustomPersonSort, 'N') FROM Company WITH (NOLOCK) WHERE comp_CompanyID=@CompanyID;

	IF (@CompanyHasCustomPersonSort = 'N') BEGIN
		SELECT @Sequence = capt_order FROM Custom_Captions WHERE capt_family = 'pers_TitleCode' AND capt_code = @PRTitleCode
	END

	IF (@Sequence IS NULL) BEGIN
		SET @Sequence = 9999
	END

	UPDATE Person_Link SET 
		peli_PRSequence = @Sequence,
		peli_PRReceivesBBScoreReport='Y'
	WHERE PeLi_PersonLinkId=@PersonLinkID
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
	DECLARE @peli_PersonLinkId int, @peli_PersonId int, @peli_CompanyId int, @peli_UserId int, @peli_OldCompanyId int
	DECLARE @peli_PRSubmitTES char(1)
	DECLARE @peli_PRStatus varchar(40), @Old_peli_PRStatus varchar(40), 
			@peli_PROwnershipRole varchar(40), @Old_peli_PROwnershipRole varchar(40),
			@PRTitleCode varchar(40), @Old_PRTitleCode varchar(40)

	SELECT @peli_PersonLinkId = peli_PersonLinkId,
		   @peli_PersonId  = peli_PersonID,
           @peli_CompanyId = peli_CompanyID,
		   @peli_PRStatus  = peli_PRStatus,
           @peli_PROwnershipRole = peli_PROwnershipRole,
		   @peli_PRSubmitTES = peli_PRSubmitTES,
		   @PRTitleCode = peli_prtitlecode,
           @peli_UserId    = peli_UpdatedBy
      FROM inserted;

	SELECT @Old_peli_PROwnershipRole  = peli_PROwnershipRole,
		   @Old_peli_PRStatus = peli_PRStatus,
		   @Old_PRTitleCode = peli_prtitlecode,
		   @peli_OldCompanyId = peli_CompanyID
      FROM deleted;
	
	-- Business Rules

	-- If the status is changed from Active or Inactive to any other status, 
	-- set the PRWebUser.prwu_AccessLevel = 0 and the PRWebUser.prwu_ServiceId = null
	IF (@Old_peli_PRStatus IN (1,2) AND @peli_PRStatus not in (1, 2))
	BEGIN
		UPDATE PRWebUser 
           SET prwu_AccessLevel = 0, 
               prwu_ServiceCode = NULL,
			   prwu_Disabled = 'Y',
               prwu_UpdatedDate = GETDATE(),
               prwu_UpdatedBy = @peli_UserId,
               prwu_Timestamp = GETDATE()
		 WHERE prwu_PersonLinkId = @peli_PersonLinkId;

		 UPDATE PRAttentionLine
		    SET prattn_PersonID = NULL
		  WHERE prattn_PersonID = @peli_PersonId
		    AND prattn_CompanyID = @peli_CompanyId;

		 UPDATE PRAttentionLine
		    SET prattn_EmailID = NULL
		   FROM vPersonEmail
		  WHERE elink_RecordID = @peli_PersonId
			AND emai_CompanyID = @peli_CompanyId
		    AND prattn_EmailID = Emai_EmailId;

		 UPDATE PRAttentionLine
		    SET prattn_PhoneID = NULL
		   FROM vPRPersonPhone
		  WHERE plink_RecordID = @peli_PersonId
			AND phon_CompanyID = @peli_CompanyId
		    AND prattn_PhoneID = phon_PhoneID;
			
		 DECLARE @WebUserID_Lic int
		 SELECT @WebUserID_Lic = prwu_WebUserID FROM PRWebUser WHERE prwu_PersonLinkID=@peli_PersonLinkId
		 DELETE FROM PRWebUserLocalSource WHERE prwuls_WebUserID = @WebUserID_Lic

	END

	-- If our ownership was nothing, but now is something, go greate a type
	-- 29 relationship
	IF ((@peli_PROwnershipRole <> 'RCR') AND 
        ((@Old_peli_PROwnershipRole = 'RCR')) AND 
        (@peli_PRStatus IN (1,2))) BEGIN
		exec usp_CreateCompanyType29Relationship @peli_PersonId, @peli_CompanyId, @peli_UserId
	END


	IF (@Old_PRTitleCode <> @PRTitleCode) BEGIN

		DECLARE @CompanyHasCustomPersonSort char(1), @Sequence int
		SELECT @CompanyHasCustomPersonSort = ISNULL(comp_PRHasCustomPersonSort, 'N') FROM Company WITH (NOLOCK) WHERE comp_CompanyID=@peli_CompanyId;

		IF (@CompanyHasCustomPersonSort = 'N') BEGIN
			SELECT @Sequence = capt_order FROM Custom_Captions WHERE capt_family = 'pers_TitleCode' AND capt_code = @PRTitleCode
			IF (@Sequence IS NULL) BEGIN
				SET @Sequence = 9999
			END

			UPDATE Person_Link SET peli_PRSequence = @Sequence WHERE PeLi_PersonLinkId=@peli_PersonLinkId
		END
	END

	IF (@peli_CompanyId <> @peli_OldCompanyId) BEGIN

		DECLARE @HQID int, @OldHQID int, @WebUserID int

		SELECT @WebUserID = prwu_WebUserID FROM PRWebUser WHERE prwu_PersonLinkID=@peli_PersonLinkId

		IF (@WebUserID IS NOT NULL) BEGIN
			SELECT 	@HQID = comp_PRHQID FROM Company WITH (NOLOCK) WHERE comp_CompanyID=@peli_CompanyId	
			SELECT 	@OldHQID = comp_PRHQID FROM Company WITH (NOLOCK) WHERE comp_CompanyID=@peli_OldCompanyId	

			IF (@HQID <> @OldHQID) BEGIN
				UPDATE PRWebUser 
				   SET prwu_ServiceCode = NULL, prwu_AccessLevel=0, prwu_PersonLinkID=NULL, prwu_Email=NULL, prwu_Disabled = 'Y' 
				 WHERE prwu_PersonLinkID=@peli_PersonLinkId

			END
		END

	END

END
Go

--  When the Credit Sheet records are insserted or updated, check the status field for P or K
--  When P, set the comp_PRLastPublishedCSDate to the prcs_PublishableDate value; when K, set the 
--  comp_PRLastPublishedCSDate value to the most recent prcs_PublishableDate for this company 
--  where the prcs_Status = P
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRCreditSheet_insupd]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRCreditSheet_insupd]
GO

CREATE TRIGGER dbo.trg_PRCreditSheet_insupd
ON PRCreditSheet
FOR INSERT, UPDATE AS
BEGIN

	DECLARE @NewListing char(1)
	DECLARE @NewStatus varchar(40), @OldStatus varchar(40)
	DECLARE @CreditSheetID int, @UserID int, @LockedUserID int, @LockedDate datetime
	DECLARE @Locked char(1), @OldLocked char(1)
	DECLARE @Key char(1), @OldKey char(1)
	DECLARE @prcs_Parenthetical varchar(max)

	SELECT @NewListing = prcs_NewListing,
           @NewStatus = prcs_Status,
           @CreditSheetID = prcs_CreditSheetID,
		   @Locked = prcs_Locked,
		   @Key = prcs_KeyFlag,
		   @UserID = prcs_UpdatedBy,
		   @prcs_Parenthetical = prcs_Parenthetical
      FROM inserted;

	SELECT @OldStatus = prcs_Status,
	       @OldLocked = prcs_Locked,
		   @LockedUserID = prcs_LockedByUser,
		   @LockedDate = prcs_LockedDate,
		   @OldKey = prcs_KeyFlag
      FROM deleted;

	DECLARE @Count int
	SELECT @Count = COUNT(1) 
      from deleted;


	-- Bug Fix
	-- When editing the notes on a published CS item, we disable the key
	-- flag.  When its saved, we are losing the value.  We don't lose the value
	-- of the New flag, though.  Can't figure out what accpac is doing, so we're
	-- just going to handle it here.
	IF ((@OldStatus = 'P' AND @NewStatus = 'P') AND
	    ((ISNULL(@Key, 'x') <> ISNULL(@OldKey, 'x')))) BEGIN
		UPDATE PRCreditSheet 
           SET prcs_KeyFlag = @OldKey
          WHERE prcs_CreditSheetID = @CreditSheetID;
	END

	IF (@OldStatus <> 'A' AND @NewStatus = 'A') BEGIN
		UPDATE PRCreditSheet 
           SET prcs_ApprovalDate = GETDATE()
          WHERE prcs_CreditSheetID = @CreditSheetID;
	END

	IF ((@NewStatus = 'A') AND
	    (ISNULL(@Locked, 'N') NOT IN ('Y', 'Z'))) BEGIN

		UPDATE PRCreditSheet 
           SET prcs_Locked = 'Y',
		       prcs_LockedDate = GETDATE(),
		       prcs_LockedByUser = @UserID
          WHERE prcs_CreditSheetID = @CreditSheetID;
	END

	---- If the user edits a locked CS item, we want to hold
	---- the lock.
	--IF ((@OldStatus = 'A' AND @NewStatus = 'A') AND
	--    (ISNULL(@Locked, 'N') <> 'Y')) BEGIN
	--	UPDATE PRCreditSheet 
 --          SET prcs_Locked = 'Y',
	--	       prcs_LockedDate = @LockedDate,
	--	       prcs_LockedByUser = @LockedUserID
 --        WHERE prcs_CreditSheetID = @CreditSheetID;
	--END



	IF (@OldStatus <> 'D' AND @NewStatus = 'D') BEGIN
		UPDATE PRCreditSheet 
           SET prcs_Locked = 'Y',
		       prcs_LockedDate = GETDATE(),
		       prcs_LockedByUser = @UserID
          WHERE prcs_CreditSheetID = @CreditSheetID;
	END

	IF (@NewStatus = 'K' AND @OldStatus <> 'K') BEGIN
		UPDATE PRCreditSheet 
           SET prcs_KilledDate = GETDATE(),
		       prcs_KilledByUser = @UserID
          WHERE prcs_CreditSheetID = @CreditSheetID;
	END

	IF (@Locked = 'Y' AND @OldLocked IS NULL) BEGIN
		UPDATE PRCreditSheet 
           SET prcs_LockedDate = GETDATE(),
		       prcs_LockedByUser = @UserID
          WHERE prcs_CreditSheetID = @CreditSheetID;
	END

	IF (@Locked = 'Z' AND @OldLocked = 'Y') BEGIN
		UPDATE PRCreditSheet 
           SET prcs_Locked = NULL,
		       prcs_LockedDate = NULL,
		       prcs_LockedByUser = NULL
          WHERE prcs_CreditSheetID = @CreditSheetID;
	END


	IF ((@NewListing = 'Y') AND @Count = 0) BEGIN
		-- This is an insert from a Company trigger
        -- for a lumber company.  In this case, we cannot
        -- update the Company table because that throws
        -- us into recursive triggers with SQL Server 
        -- does not like.
        SET @Count = 0
	END ELSE BEGIN

		-- First Handle the Published items.
		UPDATE c 
		   SET c.comp_PRLastPublishedCSDate = prcs_PublishableDate,
  	  		   c.comp_UpdatedDate = GETDATE(), 
			   c.comp_Timestamp = GETDATE(), 
			   c.comp_UpdatedBy = prcs_CreatedBy
		  FROM Company c
			   INNER JOIN inserted ON comp_CompanyID = prcs_CompanyID
		 WHERE prcs_Status = 'P';

		-- Now handle the Killed items.
		DECLARE @KilledTable table (
			CompanyID int,
			LastUpdate datetime
		)

		INSERT INTO @KilledTable
		SELECT prcs_CompanyID,
			   MAX(prcs_PublishableDate)
		  FROM PRCreditSheet
		 WHERE prcs_Status = 'P'
		   AND prcs_CompanyID IN (SELECT DISTINCT prcs_CompanyID FROM inserted WHERE prcs_Status = 'K')
	  GROUP BY prcs_CompanyID;

		UPDATE c 
		   SET c.comp_PRLastPublishedCSDate = LastUpdate
		  FROM Company c
			   INNER JOIN @KilledTable ON comp_CompanyID = CompanyID;
	END

	--
	--  When copy/paste in the web browser, sometimes an ending line
	--	break comes along for the ride.  We need to remove it.
	IF (@prcs_Parenthetical LIKE '%' + CHAR(13) + CHAR(10)) BEGIN
		UPDATE PRCreditSheet 
           SET prcs_Parenthetical = SUBSTRING(@prcs_Parenthetical, 1, LEN(@prcs_Parenthetical) - 2)
         WHERE prcs_CreditSheetID = @CreditSheetID;

	END

	EXEC usp_UpdateCSItemText @CreditSheetID;
	
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

	DECLARE @RatingID int, @RatingNumeralID int, @CompanyID int

	SELECT @RatingID = pran_RatingID,
	       @RatingNumeralID = pran_RatingNumeralId
      FROM inserted;
	
	UPDATE PRRating
	   SET prra_Rated = 'Y'
	 WHERE prra_RatingID = @RatingID
	   AND prra_Rated IS NULL;
	   

	IF (@RatingNumeralID = 133) BEGIN

		SELECT @CompanyID = prra_CompanyID
		  FROM PRRating
		 WHERE prra_RatingID = @RatingID;

		EXEC usp_UpdateTMFMStatus @CompanyID,
			                      NULL,
			                      NULL

		/*									
		UPDATE Company
		   SET comp_PRTMFMAward = NULL,
		       comp_PRTMFMAwardDate = NULL
		  FROM PRRating
         WHERE prra_CompanyID = comp_CompanyID
		   AND prra_RatingID = @RatingID
		*/
	END

END
Go


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRRating_ioins]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRRating_ioins]
GO
--	This trigger perrforms some checks on the inserted record prior to giving it to the table.
--	The trigger handles multiple inserts, removes the previous current rating if the new record
--	is marked to be current, and retrieves a RatingId value if none is passed.
--	This is used for insert operations like those in usp_AutoRemoveRatingNumerals
CREATE TRIGGER [dbo].[trg_PRRating_ioins]
ON [dbo].[PRRating]
INSTEAD OF INSERT AS
BEGIN
	-- handle multiple inserts
	DECLARE @Inserts table (
		ndx int identity, 
		prra_RatingId int ,
		prra_Deleted int ,
		prra_WorkflowId int,
		prra_Secterr int ,
		prra_CreatedBy int,
		prra_CreatedDate datetime,
		prra_UpdatedBy int,
		prra_UpdatedDate datetime,
		prra_TimeStamp datetime,
		prra_CompanyId int,
		prra_Date datetime,
		prra_Current nchar(1),
		prra_CreditWorthId int,
		prra_IntegrityId int,
		prra_PayRatingId int,
		prra_UpgradeDowngrade varchar(40),
		prra_InternalAnalysis ntext,
		prra_PublishedAnalysis ntext
	)
	DECLARE @ndx int, @InsertedCount int
	INSERT INTO @Inserts 
		SELECT prra_RatingId, prra_Deleted, prra_WorkflowId, prra_Secterr, prra_CreatedBy,
			prra_CreatedDate, prra_UpdatedBy, prra_UpdatedDate, prra_TimeStamp,
			prra_CompanyId, prra_Date, prra_Current, prra_CreditWorthId, prra_IntegrityId,
			prra_PayRatingId, prra_UpgradeDowngrade, prra_InternalAnalysis, prra_PublishedAnalysis
		  FROM inserted;
		  
	SET @InsertedCount = @@ROWCOUNT
	SET @ndx = 1

	WHILE (@ndx <= @InsertedCount)
	BEGIN
		DECLARE @prra_CompanyID int, @prra_RatingId int, @prra_Current char(1)
		DECLARE @prra_CreditWorthId int, @prra_IntegrityId int, @prra_PayRatingId int
		DECLARE @prra_Rated char(1)
		SELECT @prra_RatingId = prra_RatingId, 
				@prra_CompanyID = prra_CompanyID, @prra_Current = prra_Current,
				@prra_CreditWorthId = prra_CreditWorthId, @prra_IntegrityId = prra_IntegrityId,
				@prra_PayRatingId = prra_PayRatingId
		  FROM @Inserts 
		 WHERE ndx = @ndx

		-- When inserting a new current Rating, the old current rating flag must be removed
		IF (@prra_Current = 'Y')
			UPDATE PRRating 
			   SET prra_Current = null 
			 WHERE prra_Current = 'Y' and prra_CompanyId = @prra_CompanyID;
			 
		IF (@prra_RatingId IS NULL)
			EXEC usp_getNextId 'PRRating', @prra_RatingId output
		
		-- set the Rated flag to true by default
		SET @prra_Rated = 'Y'
		IF (@prra_CreditWorthId IS NULL AND @prra_IntegrityId IS NULL AND @prra_PayRatingId IS NULL)
			SET @prra_Rated = NULL

		INSERT INTO PRRating
			(prra_RatingId, prra_Deleted, prra_WorkflowId, prra_Secterr, prra_CreatedBy,
				prra_CreatedDate, prra_UpdatedBy, prra_UpdatedDate, prra_TimeStamp,
				prra_CompanyId, prra_Date, prra_Current, prra_CreditWorthId, prra_IntegrityId,
				prra_PayRatingId, prra_InternalAnalysis, prra_PublishedAnalysis, prra_UpgradeDowngrade,
				prra_Rated)
			SELECT @prra_RatingId, prra_Deleted, prra_WorkflowId, prra_Secterr, prra_CreatedBy,
				prra_CreatedDate, prra_UpdatedBy, prra_UpdatedDate, prra_TimeStamp,
				prra_CompanyId, prra_Date, prra_Current, prra_CreditWorthId, prra_IntegrityId,
				prra_PayRatingId, prra_InternalAnalysis, prra_PublishedAnalysis, prra_UpgradeDowngrade,
				@prra_Rated
			  FROM @Inserts
			  WHERE ndx = @ndx
			  
		DECLARE @comp_PRExcludeFSRequest char(1)
		IF (@prra_CreditWorthId = 9) --(150)
			SET @comp_PRExcludeFSRequest = 'Y'
			
		UPDATE company 
		   SET comp_PRExcludeFSRequest = @comp_PRExcludeFSRequest
		 WHERE comp_companyid = @prra_CompanyID
		

		SET @ndx = @ndx +1
	END
END
GO
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
         
        DECLARE @CWRID int
        SELECT @CWRID = prra_CreditWorthId FROM PRRating WITH (NOLOCK) where prra_RatingId = @PreviousRatingID;

		DECLARE @comp_PRExcludeFSRequest char(1)
		IF (@CWRID  = 9) --(150)
			SET @comp_PRExcludeFSRequest = 'Y'
			
		UPDATE company 
		   SET comp_PRExcludeFSRequest = @comp_PRExcludeFSRequest
		 WHERE comp_companyid = @prra_CompanyID
	END
	
END

END
GO

--	This trigger perrforms some checks on the inserted record prior to giving it to the table.
--	The trigger handles multiple inserts and retrieves an Id value if none is passed.
--	This is used for insert operations like those in usp_AutoRemoveRatingNumerals
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRRatingNumeralAssigned_ioins]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRRatingNumeralAssigned_ioins]
GO
CREATE TRIGGER [dbo].[trg_PRRatingNumeralAssigned_ioins]
ON [dbo].[PRRatingNumeralAssigned]
INSTEAD OF INSERT AS
BEGIN
	-- handle multiple inserts
	DECLARE @Inserts table (
		ndx int identity, 
		pran_RatingNumeralAssignedId int ,
		pran_Deleted int ,
		pran_WorkflowId int,
		pran_Secterr int ,
		pran_CreatedBy int,
		pran_CreatedDate datetime,
		pran_UpdatedBy int,
		pran_UpdatedDate datetime,
		pran_TimeStamp datetime,
		pran_RatingId int,
		pran_RatingNumeralId int
	)

	DECLARE @ndx int, @InsertedCount int
	INSERT INTO @Inserts 
		SELECT 	pran_RatingNumeralAssignedId, pran_Deleted, pran_WorkflowId, pran_Secterr,
				pran_CreatedBy, pran_CreatedDate, pran_UpdatedBy, pran_UpdatedDate, pran_TimeStamp,
				pran_RatingId, pran_RatingNumeralId
		  FROM inserted
	SET @InsertedCount = @@ROWCOUNT

	SET @ndx = 1
	WHILE (@ndx <= @InsertedCount)
	BEGIN
		DECLARE @pran_RatingNumeralAssignedId int, @prra_RatingId int
		SELECT @pran_RatingNumeralAssignedId = pran_RatingNumeralAssignedId
		  FROM @Inserts 
		 WHERE ndx = @ndx

		IF (@pran_RatingNumeralAssignedId is null)
			exec usp_getNextId 'PRRatingNumeralAssigned', @pran_RatingNumeralAssignedId output

		INSERT INTO PRRatingNumeralAssigned
			(pran_RatingNumeralAssignedId, pran_Deleted, pran_WorkflowId, pran_Secterr,
				pran_CreatedBy, pran_CreatedDate, pran_UpdatedBy, pran_UpdatedDate, pran_TimeStamp,
				pran_RatingId, pran_RatingNumeralId)
			SELECT @pran_RatingNumeralAssignedId, pran_Deleted, pran_WorkflowId, pran_Secterr,
				pran_CreatedBy, pran_CreatedDate, pran_UpdatedBy, pran_UpdatedDate, pran_TimeStamp,
				pran_RatingId, pran_RatingNumeralId
			  FROM @Inserts
			 WHERE ndx = @ndx

		SET @ndx = @ndx +1
		
	END



END
GO
--	This trigger performs some checks on the inserted record prior to giving it to the table.
--	The trigger handles multiple inserts and retrieves an Id value if none is passed.
--	This functionality mirrors/replaces that of usp_CreateImportPACALicense but at the table level
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRImportPACALicense_ioins]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRImportPACALicense_ioins]
GO
CREATE TRIGGER [dbo].[trg_PRImportPACALicense_ioins]
ON [dbo].[PRImportPACALicense]
INSTEAD OF INSERT AS
BEGIN
	-- handle multiple inserts
	DECLARE @Inserts table (
		ndx int identity, 
	[pril_ImportPACALicenseId] [int],
	[pril_Deleted] [int],
	[pril_WorkflowId] [int],
	[pril_Secterr] [int],
	[pril_CreatedBy] [int],
	[pril_CreatedDate] [datetime] ,
	[pril_UpdatedBy] [int],
	[pril_UpdatedDate] [datetime] ,
	[pril_TimeStamp] [datetime] ,
	[pril_FileName] [nvarchar](50),
	[pril_ImportDate] [datetime],
	[pril_LicenseNumber] [nvarchar](8),
	[pril_ExpirationDate] [datetime],
	[pril_CompanyName] [nvarchar](80),
	[pril_Address1] [nvarchar](64),
	[pril_Address2] [nvarchar](64),
	[pril_City] [nvarchar](25),
	[pril_State] [nvarchar](2),
	[pril_Country] [nvarchar](20),
	[pril_PostCode] [nvarchar](10),
	[pril_MailAddress1] [nvarchar](64),
	[pril_MailAddress2] [nvarchar](64),
	[pril_MailCity] [nvarchar](25),
	[pril_MailState] [nvarchar](2),
	[pril_MailCountry] [nvarchar](20),
	[pril_MailPostCode] [nvarchar](10),
	[pril_IncState] [nvarchar](2),
	[pril_IncDate] [datetime],
	[pril_OwnCode] [nvarchar](40),
	[pril_Telephone] [nvarchar](20),
	[pril_Email] [nvarchar](255),
	[pril_WebAddress] [nvarchar](255),
	[pril_Fax] [nvarchar](20),
	[pril_TerminateDate] [datetime],
	[pril_TerminateCode] [nvarchar](2),
	[pril_PACARunDate] [datetime],
	[pril_TypeFruitVeg] [nvarchar](40),
	[pril_ProfCode] [nvarchar](40),
	[pril_PrimaryTradeName] [nvarchar](80),
	[pril_CustomerFirstName] [nvarchar](80),
	[pril_CustomerMiddleInitial] [nvarchar](80)
	)

	DECLARE @ndx int, @InsertedCount int
	INSERT INTO @Inserts 
		SELECT pril_ImportPACALicenseId
		 ,pril_Deleted ,pril_WorkflowId ,pril_Secterr ,pril_CreatedBy ,pril_CreatedDate ,pril_UpdatedBy ,pril_UpdatedDate
		 ,pril_TimeStamp ,pril_FileName ,pril_ImportDate ,pril_LicenseNumber ,pril_ExpirationDate ,pril_CompanyName 
		 ,pril_Address1 ,pril_Address2 ,pril_City ,pril_State ,pril_Country ,pril_PostCode ,pril_MailAddress1
		 ,pril_MailAddress2 ,pril_MailCity ,pril_MailState ,pril_MailCountry ,pril_MailPostCode ,pril_IncState
		 ,pril_IncDate ,pril_OwnCode ,pril_Telephone, pril_Email, pril_WebAddress, pril_Fax ,pril_TerminateDate ,pril_TerminateCode ,pril_PACARunDate
		 ,pril_TypeFruitVeg ,pril_ProfCode ,pril_PrimaryTradeName ,pril_CustomerFirstName ,pril_CustomerMiddleInitial
	    FROM inserted
	SET @InsertedCount = @@ROWCOUNT

	DECLARE @pril_ImportPACALicenseId int
	DECLARE @ExistingImportPACALicenseId int
	DECLARE @pril_PACARunDate datetime, @pril_TerminateDate datetime 
	DECLARE @pril_LicenseNumber nvarchar(8)
	DECLARE @PerformInsert bit
	SET @ndx = 1
	WHILE (@ndx <= @InsertedCount)
	BEGIN
		-- Reset defaults
		SELECT @ExistingImportPACALicenseId = null, 
				@pril_PACARunDate = null, @pril_TerminateDate = null,
				@pril_LicenseNumber = null, @PerformInsert = 1

		-- if this license id has already been inserted from this input file,
		-- then there is most likely a termination issue to deal with.  If this is the terminate record
		-- (and it should be) delete the previously inserted License record.
		-- If this is not the terminate record just ignore it; we do not want to override the terminate rec.
		SELECT @pril_PACARunDate = pril_PACARunDate, @pril_TerminateDate = pril_TerminateDate,
				@pril_LicenseNumber = pril_LicenseNumber
			  FROM @Inserts
			 WHERE ndx = @ndx

		select @ExistingImportPACALicenseId = pril_ImportPACALicenseId 
		  from PRImportPACALicense WITH (NOLOCK)
		 where pril_LicenseNumber = @pril_LicenseNumber and pril_PACARunDate = @pril_PACARunDate

		if (@ExistingImportPACALicenseId is not null)
		begin
			IF (@pril_TerminateDate is not null)
				Delete FROM PRImportPACALicense where pril_ImportPACALicenseId = @ExistingImportPACALicenseId
			else
				SET @PerformInsert = 0
		end
		
		IF (@PerformInsert = 1)
		BEGIN

			INSERT INTO PRImportPACALicense
				(pril_Deleted ,pril_WorkflowId ,pril_Secterr ,pril_CreatedBy ,pril_CreatedDate ,pril_UpdatedBy ,pril_UpdatedDate
					 ,pril_TimeStamp ,pril_FileName ,pril_ImportDate ,pril_LicenseNumber ,pril_ExpirationDate ,pril_CompanyName 
					 ,pril_Address1 ,pril_Address2 ,pril_City ,pril_State ,pril_Country ,pril_PostCode ,pril_MailAddress1
					 ,pril_MailAddress2 ,pril_MailCity ,pril_MailState ,pril_MailCountry ,pril_MailPostCode ,pril_IncState
					 ,pril_IncDate ,pril_OwnCode ,pril_Telephone ,pril_TerminateDate ,pril_TerminateCode ,pril_PACARunDate
					 ,pril_TypeFruitVeg ,pril_ProfCode ,pril_PrimaryTradeName ,pril_CustomerFirstName ,pril_CustomerMiddleInitial
					 ,pril_Email, pril_WebAddress, pril_Fax
				)
				SELECT pril_Deleted ,pril_WorkflowId ,pril_Secterr ,pril_CreatedBy ,pril_CreatedDate ,pril_UpdatedBy ,pril_UpdatedDate
					 ,pril_TimeStamp ,pril_FileName ,pril_ImportDate ,pril_LicenseNumber ,pril_ExpirationDate ,pril_CompanyName 
					 ,pril_Address1 ,pril_Address2 ,pril_City ,pril_State ,pril_Country ,pril_PostCode ,pril_MailAddress1
					 ,pril_MailAddress2 ,pril_MailCity ,pril_MailState ,pril_MailCountry ,pril_MailPostCode ,pril_IncState
					 ,pril_IncDate ,pril_OwnCode ,pril_Telephone ,pril_TerminateDate ,pril_TerminateCode ,pril_PACARunDate
					 ,pril_TypeFruitVeg ,pril_ProfCode ,pril_PrimaryTradeName ,pril_CustomerFirstName ,pril_CustomerMiddleInitial
					 ,pril_Email, pril_WebAddress, pril_Fax
				  FROM @Inserts
				 WHERE ndx = @ndx
		END
		SET @ndx = @ndx +1
	END

END
GO

--	This trigger performs some checks on the inserted record prior to giving it to the table.
--	The trigger handles multiple inserts and retrieves an Id value if none is passed.
--	This functionality mirrors/replaces that of usp_CreateImportPACAPrincipal but at the table level
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRImportPACAPrincipal_ioins]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRImportPACAPrincipal_ioins]
GO
CREATE TRIGGER [dbo].[trg_PRImportPACAPrincipal_ioins]
ON [dbo].[PRImportPACAPrincipal]
INSTEAD OF INSERT AS
BEGIN
	-- handle multiple inserts
	DECLARE @Inserts table (
		ndx int identity, 
		[prip_ImportPACAPrincipalId] [int],
		[prip_Deleted] [int],
		[prip_WorkflowId] [int],
		[prip_Secterr] [int],
		[prip_CreatedBy] [int],
		[prip_CreatedDate] [datetime] ,
		[prip_UpdatedBy] [int],
		[prip_UpdatedDate] [datetime] ,
		[prip_TimeStamp] [datetime] ,
		[prip_ImportPACALicenseId] [int],
		[prip_FileName] [nvarchar](50),
		[prip_ImportDate] [datetime],
		[prip_Sequence] [int],
		[prip_LastName] [nvarchar](52),
		[prip_FirstName] [nvarchar](20),
		[prip_MiddleInitial] [nvarchar](1),
		[prip_Title] [nvarchar](500),
		[prip_City] [nvarchar](25),
		[prip_State] [nvarchar](2),
		[prip_LicenseNumber] [nvarchar](8),
		[prip_PACARunDate] [datetime]
	)

	DECLARE @ndx int, @InsertedCount int
	INSERT INTO @Inserts 
		SELECT prip_ImportPACAPrincipalId, prip_Deleted, prip_WorkflowId, prip_Secterr
				,prip_CreatedBy, prip_CreatedDate, prip_UpdatedBy, prip_UpdatedDate, prip_TimeStamp
				,prip_ImportPACALicenseId, prip_FileName, prip_ImportDate, prip_Sequence
				,prip_LastName, prip_FirstName, prip_MiddleInitial, prip_Title
				,prip_City, prip_State, prip_LicenseNumber, prip_PACARunDate

	    FROM inserted
	SET @InsertedCount = @@ROWCOUNT

	DECLARE @prip_ImportPACAPrincipalId int
	DECLARE @pril_ImportPACALicenseId int
	DECLARE @PerformInsert bit
	DECLARE	@prip_FileName nvarchar(50),
			@prip_LicenseNumber nvarchar(8),
			@prip_LastName nvarchar(52),
			@prip_FirstName nvarchar(20),
			@prip_Title nvarchar(500),
			@prip_City nvarchar(25),
			@prip_State nvarchar(2),
			@prip_PACARunDate datetime,
			@prip_Sequence int

	SET @ndx = 1
	WHILE (@ndx <= @InsertedCount)
	BEGIN
		-- Reset defaults
		SELECT @prip_ImportPACAPrincipalId  = null, @pril_ImportPACALicenseId = null, @PerformInsert = 1 
		SELECT @prip_FileName = null, @prip_LicenseNumber = null, @prip_LastName = null,
				@prip_FirstName = null, @prip_Title = null, @prip_City = null,
				@prip_State = null, @prip_PACARunDate = null, @prip_Sequence = null

		SELECT @prip_ImportPACAPrincipalId = prip_ImportPACAPrincipalId,
				@prip_FileName = prip_FileName, @prip_LastName = prip_LastName,
				@prip_FirstName = prip_FirstName, @prip_Title = prip_Title, @prip_City = prip_City,
				@prip_State = prip_State, @prip_LicenseNumber = prip_LicenseNumber, @prip_PACARunDate = prip_PACARunDate,
				@prip_Sequence = prip_Sequence
		  FROM @Inserts
		 WHERE ndx = @ndx

		-- Principal has an index counter specific to the file upload
		-- which will correspond to the count of the inserts.  If records
		-- are inserted independently, this value must be set by the caller
		if (@prip_Sequence is null)
			SET @prip_Sequence = @ndx - 1

		-- Do not insert duplicates from the import same file
		if Exists(
			SELECT 1 FROM PRImportPACAPrincipal WITH (NOLOCK)
			WHERE prip_FileName = @prip_FileName 
				AND prip_LicenseNumber = @prip_LicenseNumber AND prip_LastName = @prip_LastName 
				AND prip_FirstName = @prip_FirstName AND prip_Title = @prip_Title 
				AND prip_City = @prip_City AND prip_State = @prip_State AND prip_PACARunDate = @prip_PACARunDate
		)
			set @PerformInsert = 0

		IF (@PerformInsert = 1)
		BEGIN
			-- Look up the PACA License ID
			SELECT @pril_ImportPACALicenseId = pril_ImportPACALicenseId 
			  FROM PRImportPACALicense WITH (NOLOCK)
			 WHERE pril_LicenseNumber = @prip_LicenseNumber and pril_PACARunDate = @prip_PACARunDate

			INSERT INTO PRImportPACAPrincipal
				(
					prip_CreatedBy, prip_CreatedDate, prip_UpdatedBy, prip_UpdatedDate,	prip_TimeStamp, prip_Deleted, 
					prip_FileName, prip_ImportDate, prip_ImportPACALicenseId,
					prip_Sequence, prip_LicenseNumber, prip_LastName, prip_FirstName, prip_MiddleInitial,
					prip_Title,	prip_City, prip_State, prip_PACARunDate
				)
				SELECT
					prip_CreatedBy, prip_CreatedDate, prip_UpdatedBy, prip_UpdatedDate,	prip_TimeStamp, prip_Deleted, 
					prip_FileName, prip_ImportDate, @pril_ImportPACALicenseId,
					@prip_Sequence, prip_LicenseNumber, prip_LastName, prip_FirstName, prip_MiddleInitial,
					prip_Title,	prip_City, prip_State, prip_PACARunDate
				  FROM @Inserts
				 WHERE ndx = @ndx
		END
		SET @ndx = @ndx +1
	END

END
GO


--	This trigger performs some checks on the inserted record prior to giving it to the table.
--	The trigger handles multiple inserts and retrieves an Id value if none is passed.
--	This functionality mirrors/replaces that of usp_CreateImportPACATrade but at the table level
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRImportPACATrade_ioins]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRImportPACATrade_ioins]
GO
CREATE TRIGGER [dbo].[trg_PRImportPACATrade_ioins]
ON [dbo].[PRImportPACATrade]
INSTEAD OF INSERT AS
BEGIN
	-- handle multiple inserts
	DECLARE @Inserts table (
		ndx int identity, 
		[prit_ImportPACATradeId] [int] ,
		[prit_Deleted] [int] ,
		[prit_WorkflowId] [int] ,
		[prit_Secterr] [int] ,
		[prit_CreatedBy] [int] ,
		[prit_CreatedDate] [datetime],
		[prit_UpdatedBy] [int] ,
		[prit_UpdatedDate] [datetime],
		[prit_TimeStamp] [datetime],
		[prit_ImportPACALicenseId] [int],
		[prit_FileName] [nvarchar](50) ,
		[prit_ImportDate] [datetime] ,
		[prit_LicenseNumber] [nvarchar](8) ,
		[prit_AdditionalTradeName] [nvarchar](80) ,
		[prit_City] [nvarchar](25) ,
		[prit_State] [nvarchar](2) ,
		[prit_PACARunDate] [datetime] 
	)

	DECLARE @ndx int, @InsertedCount int
	INSERT INTO @Inserts 
		SELECT prit_ImportPACATradeId, prit_Deleted, prit_WorkflowId, prit_Secterr
				,prit_CreatedBy, prit_CreatedDate, prit_UpdatedBy, prit_UpdatedDate, prit_TimeStamp
				,prit_ImportPACALicenseId, prit_FileName, prit_ImportDate, prit_LicenseNumber
				,prit_AdditionalTradeName, prit_City, prit_State, prit_PACARunDate
	    FROM inserted
	SET @InsertedCount = @@ROWCOUNT

	DECLARE @prit_ImportPACATradeId int
	DECLARE @pril_ImportPACALicenseId int
	DECLARE @PerformInsert bit
	DECLARE	@prit_FileName nvarchar(50),
			@prit_LicenseNumber nvarchar(8),
			@prit_AdditionalTradeName nvarchar(52),
			@prit_City nvarchar(25),
			@prit_State nvarchar(2),
			@prit_PACARunDate datetime


	SET @ndx = 1
	WHILE (@ndx <= @InsertedCount)
	BEGIN
		-- Reset defaults
		SELECT @prit_ImportPACATradeId  = null, @pril_ImportPACALicenseId = null, @PerformInsert = 1 
		SELECT @prit_FileName = null, @prit_LicenseNumber = null, @prit_AdditionalTradeName = null,
				@prit_City = null,	@prit_State = null, @prit_PACARunDate = null 

		SELECT @prit_ImportPACATradeId = prit_ImportPACATradeId,
				@prit_FileName = prit_FileName, @prit_AdditionalTradeName = prit_AdditionalTradeName,
				@prit_City = prit_City, @prit_State = prit_State, 
				@prit_LicenseNumber = prit_LicenseNumber, @prit_PACARunDate = prit_PACARunDate
		  FROM @Inserts
		 WHERE ndx = @ndx

		-- Do not insert duplicates from the import same file
		if Exists(
			SELECT 1 FROM PRImportPACATrade WITH (NOLOCK)
			WHERE prit_FileName = @prit_FileName AND prit_LicenseNumber = @prit_LicenseNumber 
				AND prit_AdditionalTradeName = @prit_AdditionalTradeName AND prit_City = @prit_City 
				AND prit_State = @prit_State AND prit_PACARunDate = @prit_PACARunDate
		)
			set @PerformInsert = 0

		IF (@PerformInsert = 1)
		BEGIN
			-- Look up the PACA License ID
			SELECT @pril_ImportPACALicenseId = pril_ImportPACALicenseId 
			  FROM PRImportPACALicense WITH (NOLOCK)
			 WHERE pril_LicenseNumber = @prit_LicenseNumber and pril_PACARunDate = @prit_PACARunDate

			INSERT INTO PRImportPACATrade
				(
					prit_CreatedBy, prit_CreatedDate, prit_UpdatedBy, prit_UpdatedDate,	prit_TimeStamp, prit_Deleted, 
					prit_FileName, prit_ImportDate, prit_ImportPACALicenseId,
					prit_LicenseNumber, prit_AdditionalTradeName,
					prit_City, prit_State, prit_PACARunDate
				)
				SELECT
					prit_CreatedBy, prit_CreatedDate, prit_UpdatedBy, prit_UpdatedDate,	prit_TimeStamp, prit_Deleted, 
					prit_FileName, prit_ImportDate, @pril_ImportPACALicenseId,
					prit_LicenseNumber, prit_AdditionalTradeName,
					prit_City, prit_State, prit_PACARunDate
				  FROM @Inserts
				 WHERE ndx = @ndx
		END
		SET @ndx = @ndx +1
	END

END
GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRSSFile_insupd]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRSSFile_insupd]
GO

CREATE TRIGGER [dbo].[trg_PRSSFile_insupd]
ON [dbo].[PRSSFile]
FOR INSERT, UPDATE AS
BEGIN
    SET NOCOUNT ON
    DECLARE @Now datetime; set @Now = getdate() 

    DECLARE @prss_SSFileId int, @prss_RespondentCompanyId int
    DECLARE @prss_Status varchar(40), @prss_Meritorious varchar(40), @prss_Type varchar(40)
		DECLARE @prss_ClosedDate datetime, @prss_OpenedDate datetime,  @prss_MeritoriousDate datetime, @prss_UpdatedDate datetime 
    DECLARE @UserId int

		DECLARE @prss_PublishedIssueDesc varchar(max), @prss_PublishedNotes varchar(max), @prss_StatusDescription varchar(max)
		DECLARE @prss_RecordOfActivity varchar(max), @Oldprss_RecordOfActivity varchar(max)

		DECLARE @Oldprss_PublishedIssueDesc varchar(max), @Oldprss_PublishedNotes varchar(max), @Oldprss_StatusDescription varchar(max)
		DECLARE @OldprssStatus varchar(40), @Oldprss_Meritorious varchar(40)
		DECLARE @prss_InitialAmountOwed numeric(24,6), @Oldprss_InitialAmountOwed numeric(24,6)


		-- Get our current record's values
    SELECT @prss_SSFileId  = prss_SSFileId,
		   @prss_RespondentCompanyId = prss_RespondentCompanyId,
       @prss_Status = prss_Status,
		   @prss_Type = prss_Type,
		   @prss_OpenedDate = prss_OpenedDate,
		   @prss_ClosedDate = prss_ClosedDate,
		   @prss_UpdatedDate = prss_UpdatedDate,
		   @prss_Meritorious = prss_Meritorious,
		   @prss_MeritoriousDate = prss_MeritoriousDate,
		   @UserId = prss_UpdatedBy,
		   @prss_PublishedIssueDesc = prss_PublishedIssueDesc,
		   @prss_PublishedNotes = prss_PublishedNotes,
		   @prss_StatusDescription = prss_StatusDescription,
		   @prss_InitialAmountOwed = prss_InitialAmountOwed,
		   @prss_RecordOfActivity = prss_RecordOfActivity
    FROM inserted 

    -- Get the original values for the fields
    SELECT @OldprssStatus = prss_Status,
		   @Oldprss_Meritorious = prss_Meritorious,
		   @Oldprss_PublishedIssueDesc = prss_PublishedIssueDesc,
		   @Oldprss_PublishedNotes = prss_PublishedNotes,
		   @Oldprss_StatusDescription = prss_StatusDescription,
		   @Oldprss_InitialAmountOwed = prss_InitialAmountOwed,
		   @Oldprss_RecordOfActivity = prss_RecordOfActivity
    FROM deleted 

	IF (@prss_Status = 'O' and @prss_OpenedDate is null)
	BEGIN
		UPDATE PRSSFile
		   SET prss_OpenedByUserId = @UserId, prss_OpenedDate = @prss_UpdatedDate
		 WHERE prss_SSFileId = @prss_SSFileId;

		IF (@prss_RespondentCompanyId IS NOT NULL) BEGIN

			DECLARE @CompanyFullName varchar(200), @UserEmailAddress varchar(255)

			SELECT @CompanyFullName = prcse_FullName
			  FROM PRCompanySearch WITH (NOLOCK)
				   INNER JOIN Company WITH (NOLOCK) ON prcse_CompanyID = comp_CompanyID
			 WHERE prcse_CompanyID = @prss_RespondentCompanyId;

			SELECT @UserEmailAddress = RTRIM(user_EmailAddress)
			  FROM Users WITH (NOLOCK)
			 WHERE user_userid = dbo.ufn_GetPRCoSpecialistUserId(@prss_RespondentCompanyId, 0);

			DECLARE @Subject varchar(50) = 'New Special Services Claim Created'
			DECLARE @Msg2 varchar(500) = 'A new special services claim has been entered for ' + @CompanyFullName

			EXEC usp_CreateEmail
				@CreatorUserID = -1,
				@To = @UserEmailAddress,
				@Subject = @Subject,
				@Content = @Msg2,
				@Content_Format = 'HTML',
				@Action = 'EmailOut',
				@DoNotRecordCommunication = 1

		END

	END
	ELSE IF (@prss_Status = 'C' and @prss_ClosedDate is null)
	BEGIN
		UPDATE PRSSFile
		   SET prss_ClosedByUserId = @UserId, prss_ClosedDate = @prss_UpdatedDate
		 WHERE prss_SSFileId = @prss_SSFileId  
	END

	IF (@prss_Status != 'C')
	BEGIN
		UPDATE PRSSFile
		   SET prss_ClosedByUserId = NULL, prss_ClosedDate = NULL, prss_ClosedReason = NULL
		 WHERE prss_SSFileId = @prss_SSFileId  
	END

	IF (@prss_Meritorious = 'Y' and @prss_MeritoriousDate is null)
	BEGIN
		UPDATE PRSSFile
		   SET prss_MeritoriousDate = @prss_UpdatedDate
		 WHERE prss_SSFileId = @prss_SSFileId;
	END

	-- Generate a task when the claim is Open
	IF (@OldprssStatus <> 'O'
			AND @prss_Status = 'O')
	BEGIN
		-- get some additional fields for the task		
		DECLARE @Claimant varchar(500), @Respondent varchar(500), 
				@prss_OldestInvoiceDate datetime,
				@RatingUserId int, @msg varchar (2000)
		
		SELECT @RatingUserId = dbo.ufn_GetPRCoSpecialistUserId(@prss_RespondentCompanyId, 0)

		SELECT @Claimant = prcse1.prcse_FullName,
			   @Respondent = prcse2.prcse_FullName,
			   @prss_InitialAmountOwed = prss_InitialAmountOwed,
			   @prss_OldestInvoiceDate = prss_OldestInvoiceDate
		FROM inserted 
		JOIN PRCompanySearch prcse1 ON prcse1.prcse_CompanyId = prss_ClaimantCompanyId 
		JOIN PRCompanySearch prcse2 ON prcse2.prcse_CompanyId = prss_RespondentCompanyId 

		SELECT @msg = 'New Claim Opened on ' + convert(varchar, @prss_UpdatedDate, 101) + 
					Char(10) + 'Claimant: ' + @Claimant + 
					Char(10) + 'Respondent: ' + @Respondent + 
					Char(10) + 'Init Amt Owed: ' + convert(varchar, ISNULL(@prss_InitialAmountOwed, '')) + 
					Char(10) + 'Oldest Invoice Date: ' + convert(varchar, ISNULL(@prss_OldestInvoiceDate, ''), 101)

		exec usp_CreateTask     
			@StartDateTime = @Now,
			@CreatorUserId = @UserId,
			@AssignedToUserId = @RatingUserId,
			@TaskNotes = @msg,
			@RelatedCompanyId = @prss_RespondentCompanyId,
			@Status = 'Pending',
			@PRFileId = @prss_SSFileId,
			@Subject = 'A New Claim has been opened by Special Services.  Please Review.'
	END

	IF (@prss_Type = 'C') BEGIN
		IF ((ISNULL(@OldprssStatus, 'x') <> ISNULL(@prss_Status, 'x')) OR
			(ISNULL(@Oldprss_Meritorious, 'x') <> ISNULL(@prss_Meritorious, 'x')) OR
			(ISNULL(@Oldprss_PublishedIssueDesc, 'x') <> ISNULL(@prss_PublishedIssueDesc, 'x')) OR
			(ISNULL(@Oldprss_PublishedNotes, 'x') <> ISNULL(@prss_PublishedNotes, 'x')) OR
			(ISNULL(@Oldprss_StatusDescription, 'x') <> ISNULL(@prss_StatusDescription, 'x')) OR
			(ISNULL(@Oldprss_InitialAmountOwed, 0) <> ISNULL(@prss_InitialAmountOwed, 0))) BEGIN

			UPDATE PRSSFile
			   SET prss_CATDataChanged = @prss_UpdatedDate
			 WHERE prss_SSFileId = @prss_SSFileId;

			INSERT INTO PRSSCATHistory
			(prcath_SSFileID, prcath_Meritorious, prcath_Status, prcath_InitialAmountOwed, prcath_StatusDescription, prcath_PublishedNotes, prcath_PublishedIssueDesc, prcath_CreatedBy, prcath_CreatedDate, prcath_UpdatedBy, prcath_UpdatedDate, prcath_TimeStamp)
			VALUES (@prss_SSFileId, @prss_Meritorious, @prss_Status, @prss_InitialAmountOwed, @prss_StatusDescription, @prss_PublishedNotes, @prss_PublishedIssueDesc, @UserID, @Now, @UserID, @Now, @Now);

		END ELSE BEGIN
		
			IF (ISNULL(@Oldprss_RecordOfActivity, 'x') <> ISNULL(@prss_RecordOfActivity, 'x')) BEGIN
				UPDATE PRSSFile
				   SET prss_CATDataChanged = @prss_UpdatedDate
				 WHERE prss_SSFileId = @prss_SSFileId;
			END
		END
	END

    SET NOCOUNT OFF
END

GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRSSContact_insupd]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRSSContact_insupd]
GO

CREATE TRIGGER [dbo].[trg_PRSSContact_insupd]
ON [dbo].[PRSSContact]
FOR INSERT, UPDATE AS
BEGIN
    SET NOCOUNT ON
    
    DECLARE @prssc_SSFileId int, @prssc_CompanyId int, @prssc_SSContactId int
    DECLARE @prssc_IsPrimary char(1)
	DECLARE @prssc_UpdatedDate Datetime
    DECLARE @UserId int

	-- Get our current record's values
    SELECT @prssc_SSContactId = prssc_SSContactId, 
		   @prssc_SSFileId  = prssc_SSFileId,
           @prssc_CompanyId = prssc_CompanyId,
		   @prssc_IsPrimary = prssc_IsPrimary,
		   @prssc_UpdatedDate = prssc_UpdatedDate,
		   @UserId = prssc_UpdatedBy
    FROM inserted 

	IF (@prssc_IsPrimary = 'Y')
	BEGIN
		UPDATE PRSSContact
		   SET prssc_IsPrimary = NULL
		 WHERE prssc_SSFileId = @prssc_SSFileId  
		   and prssc_CompanyId = @prssc_CompanyId 
		   and prssc_SSContactId != @prssc_SSContactId 
	END ELSE BEGIN
		-- Is there is not a primary
		IF NOT EXISTS (
			SELECT 1 
			FROM PRSSContact
			WHERE prssc_SSFileId = @prssc_SSFileId  
			   and prssc_CompanyId = @prssc_CompanyId 
			   and prssc_IsPrimary = 'Y'
		)
		UPDATE PRSSContact
		   SET prssc_IsPrimary = 'Y'
		 WHERE prssc_SSFileId = @prssc_SSFileId  
		   and prssc_CompanyId = @prssc_CompanyId 
		   and prssc_SSContactId = @prssc_SSContactId 
    END
	SET NOCOUNT OFF
END
GO

-- Update PRPublicationArticle when the Edition table changes.
-- =============================================
-- Author:		Tad M. Eness
-- Create date: 9/27/2007
-- Description:	Trigger to update Publication Articles
--   linked with an edition and synchronize the publish dates
-- =============================================
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PublicationEdition_upd]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PublicationEdition_upd]
GO

CREATE TRIGGER [dbo].[trg_PublicationEdition_upd]
   ON  [dbo].[PRPublicationEdition]
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Update all of the associated articles' expiration date with the publish date from this table
	Update PRPublicationArticle
	   Set prpbar_PublishDate = prpbed.prpbed_PublishDate
	  From Inserted prpbed
	       Inner Join PRPublicationArticle prpbar On (prpbar.prpbar_PublicationEditionID = prpbed.prpbed_PublicationEditionID)
	 Where prpbar.prpbar_PublicationCode = 'BP' And Coalesce(prpbar.prpbar_News, '') != 'Y';
END
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRPublicationArticle_ins]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRPublicationArticle_ins]
GO

CREATE TRIGGER [dbo].[trg_PRPublicationArticle_ins]
ON [dbo].[PRPublicationArticle]
FOR INSERT AS
BEGIN

	DECLARE @RecordID int, @SequenceNumber int, @EditionID int
	DECLARE @PublicationCode varchar(10)
	 
	-- Get our key fields from the inserted record
	SELECT @RecordID = prpbar_PublicationArticleID,
	       @EditionID = ISNULL(prpbar_PublicationEditionID, 0),
		   @PublicationCode = prpbar_PublicationCode,
		   @SequenceNumber = ISNULL(prpbar_Sequence, 0)
	  FROM inserted
	 
	 IF ((@EditionID > 0) AND 
	     (@PublicationCode IN ('BP', 'BPS')))
	    BEGIN


		 IF (@SequenceNumber <= 0) BEGIN
			-- Get our current max sequence value excluding the current record.  
			SELECT @SequenceNumber = ISNULL(MAX(prpbar_Sequence), 1) 
			  FROM PRPublicationArticle
			 WHERE prpbar_PublicationEditionID = @EditionID
			   AND prpbar_PublicationCode IN ('BP', 'BPS')
	 
			-- Increment it
			IF (@SequenceNumber < 0) SET @SequenceNumber = 0

			SET @SequenceNumber = @SequenceNumber + 1
	
			-- Reset our value.
			UPDATE PRPublicationArticle
			   SET prpbar_Sequence = @SequenceNumber
			 WHERE prpbar_PublicationArticleID = @RecordID;
		END
	END

END
GO



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PublicationArticle_insupd]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PublicationArticle_insupd]
GO

CREATE TRIGGER dbo.trg_PublicationArticle_insupd 
   ON  dbo.PRPublicationArticle 
   AFTER INSERT,UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Synchronize the Publication Date with the edition date
	UPDATE PRPublicationArticle
	   SET prpbar_PublishDate = prpbed.prpbed_PublishDate
      FROM PRPublicationArticle prpbar WITH (NOLOCK)
		   INNER JOIN Inserted i ON prpbar.prpbar_PublicationArticleID = i.prpbar_PublicationArticleID
		   INNER JOIN PRPublicationEdition prpbed WITH (NOLOCK) ON i.prpbar_PublicationEditionID = prpbed.prpbed_PublicationEditionID
     WHERE i.prpbar_PublicationCode IN ('BP', 'BPS');

	 DECLARE @PubCode varchar(40), @ArticleID int
	 DECLARE @Name varchar(500), @MembersOnly char(1), @Category varchar(40)
	 DECLARE @PublishDate datetime, @ExpirationDate datetime, @PublishProduce varchar(1), @PublishLumber varchar(1)
	 DECLARE @Abstract varchar(max), @Body varchar(max)
	 DECLARE @Action varchar(40)


	 SELECT @ArticleID = i.prpbar_PublicationArticleID,
	        @PubCode = i.prpbar_PublicationCode,
	        @Action = CASE WHEN d.prpbar_PublicationArticleID IS NULL THEN 'New' ELSE 'Updated' END,
	        @Name = i.prpbar_Name,
			@MembersOnly = i.prpbar_MembersOnly,
			@Category = dbo.ufn_GetCustomCaptionValue('prpbar_CategoryCode', i.prpbar_CategoryCode, 'en-us'),
			@PublishDate = i.prpbar_PublishDate,
			@ExpirationDate = i.prpbar_ExpirationDate,
			@PublishProduce = CASE WHEN i.prpbar_IndustryTypeCode LIKE '%,P,%' THEN 'Y' ELSE 'N' END,
			@PublishLumber = CASE WHEN i.prpbar_IndustryTypeCode = '%,L,%' THEN 'Y' ELSE 'N' END,
			@Abstract = i.prpbar_Abstract,
			@Body = i.prpbar_Body
	   FROM inserted i
	        LEFT OUTER JOIN deleted d ON i.prpbar_PublicationArticleID = d.prpbar_PublicationArticleID

	IF ((@PubCode = 'BBN') AND
	    (@Action = 'New')) BEGIN
		DECLARE @NewLine varchar(10) = '<br/>' --CHAR(13) + CHAR(10)
		DECLARE @Email varchar(max)

		DECLARE @ViewinBBOS varchar(255)
		SET @ViewinBBOS = '<a href="' + dbo.ufn_GetCustomCaptionValue('BBOS', 'URL', 'en-us') + 'NewsArticle.aspx?Preview=Y&ArticleID=' + CAST(@ArticleID as varchar(10))+ '">View Article in BBOS</a>'

		SET @Email = '<html><head></head><body>'
		SET @Email = @Email + '<strong>Name:</strong> ' + ISNULL(@Name, '') + @NewLine
		SET @Email = @Email + '<strong>Members Only:</strong> ' +  ISNULL(@MembersOnly, '') + @NewLine
		SET @Email = @Email + '<strong>Category:</strong> ' +  ISNULL(@Category, '') + @NewLine
		SET @Email = @Email + '<strong>Publish Date:</strong> ' +  ISNULL(convert(varchar, @PublishDate, 101), '') + @NewLine
		SET @Email = @Email + '<strong>Expiration Date:</strong> ' +  ISNULL(convert(varchar, @ExpirationDate, 101), '') + @NewLine
		SET @Email = @Email + '<strong>Publish for Produce:</strong> ' + ISNULL(@PublishProduce, '') + @NewLine
		SET @Email = @Email + '<strong>Publish for Lumber:</strong> ' +  ISNULL(@PublishLumber, '') + @NewLine
		SET @Email = @Email + @ViewinBBOS + @NewLine

		SET @Email = @Email + @NewLine + '<strong>Abstract:</strong> ' +  @NewLine + ISNULL(@Abstract, '') + @NewLine
		SET @Email = @Email + @NewLine + '<strong>Body:</strong> ' +  @NewLine + ISNULL(@Body, '') + @NewLine
		SET @Email = @Email + '</body></html>'

		DECLARE @Subject varchar(100) = @Action + ' BBOS News Article '

		EXEC usp_CreateEmail @To = 'korlowski@bluebookservices.com',
							 @Subject = @Subject,
							 @Content = @Email,
							 @Content_Format = 'HTML'

		EXEC usp_CreateEmail @To = 'gjohnson@bluebookservices.com',
							 @Subject = @Subject,
							 @Content = @Email,
							 @Content_Format = 'HTML'
	END
END
GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRWebUser_upd]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRWebUser_upd]
GO

CREATE TRIGGER dbo.trg_PRWebUser_upd
ON PRWebUser
FOR UPDATE AS
BEGIN
	SET NOCOUNT ON

	DECLARE @WebUserID2 int, @HQID int, @BBID int, @NewEmail varchar(255), @TrialExpirationDate datetime
	DECLARE @OldBBID int, @OldEmail varchar(255), @OldTrialExpirationDate datetime
	DECLARE @PersonLinkID int, @OldPersonLinkID int
	DECLARE @Timezone varchar(50), @OldTimezone varchar(50)

	SELECT @WebUserID2 = prwu_WebUserID,
	       @BBID = prwu_BBID,
		   @NewEmail = prwu_Email,
		   @PersonLinkID = ISNULL(prwu_PersonLinkID, 0),
		   @TrialExpirationDate = prwu_TrialExpirationDate,
		   @Timezone = prwu_TimeZone
      FROM inserted;

	SELECT @OldBBID = prwu_BBID,
		   @OldEmail = prwu_Email,
		   @OldPersonLinkID = ISNULL(prwu_PersonLinkID, 0),
		   @OldTrialExpirationDate = prwu_TrialExpirationDate,
		   @OldTimezone = prwu_TimeZone
      FROM deleted;


	-- Check for BBID modifications
	IF (@BBID <> @OldBBID) BEGIN

		SELECT @HQID = comp_PRHQId,
               @BBID = prwu_BBID
          FROM Company WITH (NOLOCK)
               INNER JOIN inserted ON comp_CompanyID = prwu_BBID;

		UPDATE PRWebUser
	       SET prwu_HQID = @HQID,
	           prwu_CDSWBBID = NULL,
	           prwu_MergedCompanyID = NULL,
	           prwu_CompanyData = NULL
	     WHERE prwu_WebUserID = @WebUserID2;

		UPDATE PRRequest
	       SET prreq_HQID = @HQID,
               prreq_CompanyID = @BBID
	     WHERE prreq_WebUserID = @WebUserID2;

		UPDATE PRWebUserContact
	       SET prwuc_CompanyID = @BBID,
               prwuc_HQID = @HQID
	     WHERE prwuc_WebUserID = @WebUserID2;

		UPDATE PRWebUserCustomData
	       SET prwucd_CompanyID = @BBID,
               prwucd_HQID = @HQID
	     WHERE prwucd_WebUserID = @WebUserID2;

		UPDATE PRWebUserList
	       SET prwucl_CompanyID = @BBID,
               prwucl_HQID = @HQID
	     WHERE prwucl_WebUserID = @WebUserID2;

		UPDATE PRWebUserNote
	       SET prwun_CompanyID = @BBID,
               prwun_HQID = @HQID
	     WHERE prwun_WebUserID = @WebUserID2;

		UPDATE PRWebUserSearchCriteria
	       SET prsc_CompanyID = @BBID,
               prsc_HQID = @HQID
	     WHERE prsc_WebUserID = @WebUserID2;
	     
	    UPDATE PRExternalLinkAuditTrail
	       SET prelat_CompanyID = @BBID
	     WHERE prelat_WebUserID = @WebUserID2;

		UPDATE PRSearchWizardAuditTrail
	       SET prswau_CompanyID = @BBID
	     WHERE prswau_WebUserID = @WebUserID2;

		UPDATE PRSearchAuditTrail
	       SET prsat_CompanyID = @BBID
	     WHERE prsat_WebUserID = @WebUserID2;
	     
	    UPDATE PRWebAuditTrail
	       SET prwsat_CompanyID = @BBID
	     WHERE prwsat_WebUserID = @WebUserID2;

	    UPDATE PRSelfServiceAuditTrail
	       SET prssat_CompanyID = @BBID
	     WHERE prssat_WebUserID = @WebUserID2;	     

	    UPDATE PRAdCampaignAuditTrail
	       SET pradcat_CompanyID = @BBID
	     WHERE pradcat_WebUserID = @WebUserID2;			
	END

	-- We only care if the email address changes.
	IF (@NewEmail <> @OldEmail) BEGIN

		Declare @ChangeTable table (
			Ndx int identity(1,1) primary key,
			WebUserID int,
			PersonLinkID int,
            CompanyID int,
			Email varchar(255)	
		)

		-- This trigger handles multiple row updates.  Only process
        -- those that are linked to a Person_Link record in BBS CRM
		INSERT INTO @ChangeTable (WebUserID, PersonLinkID, CompanyID, Email)
		SELECT prwu_WebUserID, prwu_PersonLinkID, prwu_BBID, prwu_Email
          FROM inserted
         WHERE prwu_PersonLinkID > 0;

		DECLARE @Count int, @Index int
		DECLARE @WebUserID int, @PersonID int, @EmailID int, @TrxId int, @CompanyID int
		DECLARE @Email varchar(255), @CurrentEmail varchar(255)
		SELECT @Count = COUNT(1) FROM @ChangeTable;
		SET @Index = 0

		-- Iterate through the changed rows
		WHILE @Index < @Count BEGIN
			SET @Index = @Index + 1
			SELECT @WebUserID = WebUserID,
				   @PersonLinkID = PersonLinkID,
                   @CompanyID = CompanyID,
				   @Email = Email
			  FROM @ChangeTable
			 WHERE Ndx = @Index;

			-- Since we're operating on a set of records,
            -- we only want to continue if our email addressed
	        -- changed.  The UPDATE() statement above returns true
			-- if *any* rows in the inserted table have changed.
			SELECT @EmailID = emai_EmailID, 
				   @PersonID = peli_PersonID,
                   @CurrentEmail = emai_EmailAddress
			  FROM Person_Link WITH (NOLOCK) 
				   LEFT OUTER JOIN vPersonEmail WITH (NOLOCK) ON elink_RecordID = peli_PersonID 
				                                             and emai_CompanyID = peli_CompanyID
			  WHERE peli_PersonLinkID = @PersonLinkID;

			IF @EmailID IS NULL BEGIN

				-- Open a transaction
				EXEC @TrxId = usp_CreateTransaction 
							@UserId = @WebUserID,
							@prtx_PersonID = @PersonID,
							@prtx_Explanation = 'Web user added email address via BBOS.'


				EXEC usp_InsertEmail @RecordID=@PersonID, 
				                     @CompanyID=@CompanyID,
				                     @EntityID = 13, 
									 @EmailAddress = @Email, 
									 @UserID = @WebUserID

				-- close the opened transaction
				UPDATE PRTransaction 
				   SET prtx_Status = 'C' 
				 WHERE prtx_TransactionId = @TrxId;

			END ELSE BEGIN
				IF @CurrentEmail <> @Email BEGIN
					-- Open a transaction
					EXEC @TrxId = usp_CreateTransaction 
								@UserId = @WebUserID,
								@prtx_PersonID = @PersonID,
								@prtx_Explanation = 'Web user changed email address via BBOS.'

					UPDATE Email
					   SET emai_EmailAddress = @Email,
						   emai_UpdatedBy = @WebUserID,
						   emai_UpdatedDate = GETDATE(),
						   emai_Timestamp = GETDATE()
					 WHERE emai_EmailID = @EmailID;

					-- close the opened transaction
					UPDATE PRTransaction 
					   SET prtx_Status = 'C' 
					 WHERE prtx_TransactionId = @TrxId;
				END
			END
		END
	END


	IF (ISNULL(@TrialExpirationDate, GETDATE()) <> ISNULL(@OldTrialExpirationDate, GETDATE())) BEGIN

        -- If the current expiration date is 12/30/1899, then
        -- this is the signal this expiration period is over.
		UPDATE PRWebUser
		   SET prwu_TrialExpirationDate = NULL,
		       prwu_PreviousServiceCode = NULL,
               prwu_PreviousAccessLevel = NULL
		 WHERE prwu_TrialExpirationDate = '1899-12-30'
           AND prwu_WebUserID = @WebUserID2;
	END

	IF (@Timezone <> @OldTimezone) BEGIN
		UPDATE PRWebUserNoteReminder
		   SET prwunr_Timezone = @Timezone
		  FROM PRWebUserNote
		 WHERE prwun_WebUserNoteID = prwunr_WebUserNoteID
		   AND prwun_WebUserID = @WebUserID2;
	END
	SET NOCOUNT OFF
END
Go

-- NEW TRIGGER
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRCompanyRelationship_BBOS_ins]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRCompanyRelationship_BBOS_ins]
GO

CREATE TRIGGER dbo.trg_PRCompanyRelationship_BBOS_ins
ON PRCompanyRelationship
FOR INSERT AS
BEGIN
    SET NOCOUNT ON

	DECLARE @CompanyID int, @HQID int, @RelatedCompanyID int
	DECLARE @UserListID int

	-- Look to see if the relationship is part
    -- of the connection list.
	SELECT @CompanyID = prcr_LeftCompanyID,
           @RelatedCompanyID = prcr_RightCompanyID,
           @HQID = comp_PRHQID
      FROM inserted
           INNER JOIN Company ON prcr_LeftCompanyID = comp_CompanyID
     WHERE prcr_Type IN ('09', '10', '11', '12', '13', '14', '15', '16')
       AND prcr_Active = 'Y'

	-- If so, see if we need to update the special
	-- WebUserList for the connection list.
	IF @CompanyID IS NOT NULL BEGIN

		-- Does the HQ have a UserList for
	    -- the connection list?
		SELECT @UserListID = prwucl_WebUserListID
          FROM PRWebUserList
         WHERE prwucl_HQID = @HQID
           AND prwucl_TypeCode = 'CL';

		-- If so, go add this company.
		IF @UserListID IS NOT NULL BEGIN

			-- Only add the company if it isn't 
			-- already there.  It could be there if the related
            -- company has a different relationship type.
			DECLARE @Count int
			SELECT @Count = COUNT(1)
			  FROM PRWebUserListDetail
			 WHERE prwuld_WebUserListID = @UserListID
			   AND prwuld_AssociatedID = @RelatedCompanyID;
			
			IF @Count = 0 BEGIN

				INSERT INTO PRWebUserListDetail 
					(prwuld_CreatedBy,
					 prwuld_CreatedDate,
					 prwuld_UpdatedBy,
					 prwuld_UpdatedDate,
					 prwuld_TimeStamp,
					 prwuld_WebUserListID,
					 prwuld_AssociatedID,
					 prwuld_AssociatedType)
				VALUES (-1, 
						GETDATE(), 
						-1, 
						GETDATE(), 
						GETDATE(),
						@UserListID,
						@RelatedCompanyID,
						'C');
                
                --Update UpdatedDate on parent PRWebUserList record
			    UPDATE PRWebUserList
					    SET prwucl_UpdatedDate = GETDATE() 
					    WHERE prwucl_WebUserListID = @UserListID
			END
		END
	END
END
Go
      
-- NEW TRIGGER 
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRCompanyRelationship_BBOS_del]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRCompanyRelationship_BBOS_del]
GO

CREATE TRIGGER dbo.trg_PRCompanyRelationship_BBOS_del
ON PRCompanyRelationship
FOR DELETE AS
BEGIN
    SET NOCOUNT ON

	DECLARE @CompanyID int, @HQID int, @RelatedCompanyID int
	DECLARE @UserListID int
	DECLARE @Type varchar(40)

	-- Look to see if the relationship is part
    -- of the connection list.
	SELECT @CompanyID = prcr_LeftCompanyID,
           @RelatedCompanyID = prcr_RightCompanyID,
           @HQID = comp_PRHQID,
	       @Type = prcr_Type
      FROM deleted
           INNER JOIN Company ON prcr_LeftCompanyID = comp_CompanyID
     WHERE prcr_Type IN ('09', '10', '11', '12', '13', '14', '15', '16')
       AND prcr_Active = 'Y';

	-- If so, see if we need to update the special
	-- WebUserList for the connection list.
	IF @CompanyID IS NOT NULL BEGIN

		-- Only remove this company from the PRWebUserList if 
		-- the company has not other Connection List relationship
		-- types.
		DECLARE @Count int

		SELECT @Count = Count(1)
          FROM PRCompanyRelationship
         WHERE prcr_Type IN ('09', '10', '11', '12', '13', '14', '15', '16')
           AND prcr_Active = 'Y'
           AND prcr_Type <> @Type
           AND prcr_RightCompanyID = @CompanyID
           AND prcr_LeftCompanyID = @RelatedCompanyID;

		IF @Count = 0 BEGIN
			-- Does the HQ have a UserList for
			-- the connection list?
			SELECT @UserListID = prwucl_WebUserListID
			  FROM PRWebUserList
			 WHERE prwucl_HQID = @HQID
			   AND prwucl_TypeCode = 'CL';

			-- If so, go delete this company.
			IF @UserListID IS NOT NULL
            BEGIN
				DELETE FROM PRWebUserListDetail
				 WHERE prwuld_WebUserListID = @UserListID
				   AND prwuld_AssociatedType = 'C'
				   AND prwuld_AssociatedID = @RelatedCompanyID;

                --Update UpdatedDate on parent PRWebUserList record
			    UPDATE PRWebUserList
				    SET prwucl_UpdatedDate = GETDATE() 
				    WHERE prwucl_WebUserListID = @UserListID
			END -- @UserListID
		END -- @Count = 0
	END  -- @CompanyID
END -- Trigger
GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_Address_iu]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_Address_iu]
GO

CREATE TRIGGER dbo.[trg_Address_iu] 
	ON Address FOR INSERT, UPDATE AS
BEGIN
Set NoCount On

	UPDATE a
	   SET addr_uszipfive = SUBSTRING(i.Addr_PostCode, 1, 5)
   	  FROM Address a
           INNER JOIN inserted i ON a.addr_AddressID = i.addr_AddressID;


	DECLARE @CompanyID int, @RecordID int, @UserID int
	
	SELECT @CompanyID = prattn_CompanyID,
	       @RecordID = addr_AddressID,
	       @UserID = addr_UpdatedBy
	  FROM inserted
	       LEFT OUTER JOIN PRAttentionLine ON addr_AddressID = prattn_AddressID AND prattn_ItemCode = 'BILL';

	-- If this address is associated with the billing
	-- attention line, then we need to capture the change
	IF ((EXISTS (SELECT 'x' FROM DELETED)) AND
	    (@CompanyID IS NOT NULL)) BEGIN

		INSERT INTO PRChangeDetection (prchngd_CompanyID, prchngd_ChangeType, prchngd_AssociatedID, prchngd_AssociatedType, prchngd_CreatedBy, prchngd_UpdatedBy)
		VALUES (@CompanyID, 'Update', @RecordID, 'Address', @UserID, @UserID);	
	END

	IF (EXISTS (SELECT 'x' FROM DELETED WHERE addr_PRLatitude IS NOT NULL)) BEGIN
		--  Reset our Geocode values if this address
		--  is updated and has a previous value.
		UPDATE Address
		   SET addr_PRLatitude = NULL,
		       addr_PRLongitude = NULL
		 WHERE addr_AddressID = @RecordID;

	END
SET NOCOUNT OFF 
END
Go




/*
	Keeps the PRWebUser table in sync with the Email table
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_EmailBBOS_upd]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_EmailBBOS_upd]
GO

CREATE TRIGGER [dbo].[trg_EmailBBOS_upd]
ON [dbo].[Email]
FOR UPDATE AS
BEGIN

	DECLARE @WebUserID int, @UserID int, @CompanyID int, @RecordID int
	DECLARE @Email varchar(500)
 
	-- Get our key fields from the updated record
	SELECT @RecordID = emai_EmailID,
	       @CompanyID = peli_CompanyID,
	       @WebUserID = prwu_WebUserID,
           @UserID = emai_UpdatedBy,
		   @Email = emai_EmailAddress
	  FROM inserted
	       INNER JOIN EmailLink ON emai_EmailID = elink_EmailID 
           INNER JOIN Person_Link WITH (NOLOCK) ON elink_RecordId = peli_PersonID AND elink_EntityID=13
		                                       AND emai_CompanyId = peli_CompanyID
           INNER JOIN PRWebUser WITH (NOLOCK) ON peli_PersonLinkID = prwu_PersonLinkID AND prwu_Disabled IS NULL;
 

	IF @WebUserID IS NOT NULL BEGIN
		UPDATE PRWebUser
           SET prwu_Email = @Email,
               prwu_UpdatedBy = @UserID,
               prwu_UpdatedDate = GETDATE(),
               prwu_Timestamp = GETDATE()
         WHERE prwu_WebUserID = @WebUserID;
	END
	
	
	SELECT @CompanyID = prattn_CompanyID
	  FROM inserted
	       INNER JOIN PRAttentionLine ON emai_EmailID = prattn_EmailID AND prattn_ItemCode = 'BILL';

	IF (@CompanyID IS NOT NULL) BEGIN
		INSERT INTO PRChangeDetection (prchngd_CompanyID, prchngd_ChangeType, prchngd_AssociatedID, prchngd_AssociatedType, prchngd_CreatedBy, prchngd_UpdatedBy)
		VALUES (@CompanyID, 'Update', @RecordID, 'Email', @UserID, @UserID);	
	END		
END
GO



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRTESForm_ins]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRTESForm_ins]
GO

CREATE TRIGGER dbo.trg_PRTESForm_ins
ON PRTESForm
FOR INSERT AS
BEGIN

	UPDATE TF 
       SET TF.prtf_SerialNumber = inserted.prtf_TESFormId
      FROM PRTESForm TF
           INNER JOIN inserted ON TF.prtf_TESFormId = inserted.prtf_TESFormId;

END
Go


/*
 * This trigger makes sure the prtx_Listing field is updated when a transaction is closed.
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRTransaction_insupd]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRTransaction_insupd]
GO

CREATE TRIGGER dbo.trg_PRTransaction_insupd
ON PRTransaction
FOR UPDATE, INSERT AS
BEGIN

	DECLARE @OldStatus varchar(40), @NewStatus varchar(40)
    DECLARE @TransactionID int, @CompanyID int, @PersonID int
	DECLARE @AuthorizedById int, @OldAuthorizedById int 

	SELECT @OldStatus = prtx_Status,
	       @OldAuthorizedById = prtx_AuthorizedById
	  FROM deleted;

	SELECT @NewStatus = prtx_Status,
           @TransactionID = prtx_TransactionID,
           @CompanyID = prtx_CompanyID,
           @PersonID = prtx_PersonID,
	       @AuthorizedById = prtx_AuthorizedById
      FROM inserted;

	IF (@NewStatus = 'C') AND (ISNULL(@OldStatus, 'X') <> 'C') BEGIN
	
		DECLARE @Count int, @Index int, @SubjectCompanyID int 
		DECLARE @tblCompanies table (
			ndx int primary key identity(0,1),
			CompanyID int
		)
	
	
		IF (@CompanyID IS NOT NULL) BEGIN
			UPDATE PRTransaction
			   SET prtx_Listing = dbo.ufn_GetListingFromCompany(@CompanyID, 2, 0)
			 WHERE prtx_TransactionID = @TransactionID;
	         
			 EXEC usp_UpdateListing @CompanyID;
			 EXEC usp_UpdateBranchListings @CompanyID;

			 EXEC usp_UpdateCompanyRating @CompanyID;
             EXEC usp_UpdateBranchCompanyRatings @CompanyID;

			--
			--  Now handle any companies that this
			--- company owns			 
			INSERT INTO @tblCompanies (CompanyID)
			SELECT DISTINCT prcr_RightCompanyId
			  FROM Company WITH (NOLOCK)
				   INNER JOIN PRCompanyRelationship WITH (NOLOCK) ON comp_CompanyID = prcr_RightCompanyId
			 WHERE comp_PRListingStatus IN ('L', 'H', 'LUV')
			   AND prcr_Type IN ('27', '28')
			   AND prcr_LeftCompanyID = @CompanyID;
		END			 
		
		--
		--  If this person is an owner of a company
		--  we may need to update the company listing
		IF (@PersonID IS NOT NULL) BEGIN

			INSERT INTO @tblCompanies (CompanyID)
			 SELECT DISTINCT prcp_companyid
			   FROM Company WITH (NOLOCK)
					INNER JOIN PRCompanyProfile WITH (NOLOCK) ON comp_CompanyID = prcp_companyid
					INNER JOIN Person_Link WITH (NOLOCK) on comp_CompanyID = peli_CompanyID
			  WHERE prcp_CorporateStructure = 'PROP'
				AND comp_PRListingStatus IN ('L', 'H', 'LUV')
				AND peli_PROwnershipRole = 'RCO' 
				AND peli_PRStatus = '1'
			    AND peli_PersonID = @PersonID;
		END
		
		SELECT @Count = COUNT(1) FROM @tblCompanies;
		SET @Index = 0
		WHILE @Index < @Count BEGIN

			SELECT @SubjectCompanyID = CompanyID  
			  FROM @tblCompanies
			 WHERE ndx = @Index;

			EXEC usp_UpdateListing @SubjectCompanyID;
			SET @Index = @Index + 1; 
		END 		
	END
	
END
Go


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRTransaction_ins]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRTransaction_ins]
GO

/*
CREATE TRIGGER dbo.trg_PRTransaction_ins
ON PRTransaction
FOR INSERT AS
BEGIN

    DECLARE @TransactionID int, @AuthorizedById int, @PersonID int

	SELECT @TransactionID = prtx_TransactionID,
           @PersonID = prtx_PersonID,
	       @AuthorizedById = prtx_AuthorizedById
      FROM inserted;

	IF (@AuthorizedById IS NULL AND @PersonID IS NOT NULL) BEGIN
		UPDATE PRTransaction
		   SET prtx_AuthorizedById = @PersonID
		 WHERE prtx_TransactionID = @TransactionID;
	END
END
*/
Go


CREATE OR ALTER TRIGGER dbo.trg_PRCompanyStockExchange_ins
ON PRCompanyStockExchange 
FOR INSERT AS
BEGIN

    DECLARE @CompanyID int

	SELECT @CompanyID = prc4_CompanyId
      FROM inserted;

	-- A company listed on a stock exchange
    -- cannot have confidential financials.
	UPDATE Company
       SET comp_PRConfidentialFS = '3'
     WHERE comp_CompanyID = @CompanyID;
END
Go



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRCompanyAlias_ins]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRCompanyAlias_ins]
GO

CREATE TRIGGER dbo.trg_PRCompanyAlias_ins
ON PRCompanyAlias 
FOR INSERT, UPDATE AS
BEGIN
UPDATE PRCompanyAlias SET pral_AliasMatch = dbo.GetLowerAlpha(dbo.ufn_PrepareCompanyName(pral_Alias)) 

    DECLARE @RecordID int
    DECLARE @LowerAlpha varchar(104), @Match varchar(104)

	SELECT @RecordID = pral_CompanyAliasId,
           @LowerAlpha = dbo.ufn_GetLowerAlpha(pral_Alias),
		   @Match = dbo.GetLowerAlpha(dbo.ufn_PrepareCompanyName(pral_Alias)) 

      FROM inserted;


	UPDATE PRCompanyAlias
       SET pral_NameAlphaOnly = @LowerAlpha,
	       pral_AliasMatch = @Match
     WHERE pral_CompanyAliasId = @RecordID;
END
Go




if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_Lock_ioins]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
	drop trigger [dbo].[trg_Lock_ioins]
GO


CREATE TRIGGER dbo.trg_Lock_ioins
ON Locks
INSTEAD OF INSERT AS
BEGIN

	DECLARE @SessionID varchar(30), @TableID int, @CreatedBy int, @DeviceID int, @ZeroCount int
    DECLARE @RecordID nchar(50), @CreatedDate datetime
    DECLARE @IsWapUser nchar(10)

	DECLARE @InsertRecord bit
	
	-- Setting this to 1 effectivey disables
	-- the trigger because a record will 
	-- always be created.
	SET @InsertRecord = 1

	SELECT @SessionID = lock_SessionID,
           @TableID = lock_TableID, 
           @RecordID = lock_RecordID,
           @CreatedBy = lock_CreatedBy,
           @CreatedDate = lock_CreatedDate,
           @IsWapUser = lock_IsWapUser,
           @DeviceID = lock_DeviceID
      FROM inserted; 


	-- When we have our lock issue it's generally due to a duplicate key issue where SessionID = 0. 
	-- I don't believe a Session ID of zero is valid.
	IF (@SessionID = '0')
    BEGIN
		SET @InsertRecord = 0
	END

	-- Exclude BBOS Users
	IF (@CreatedBy > 10000) BEGIN
		SET @InsertRecord = 0
	END	
	IF (@CreatedBy <= 0) BEGIN
		SET @InsertRecord = 0
	END

--	IF EXISTS (SELECT 'X' FROM Custom_Tables WHERE bord_TableID=@TableID AND bord_name IN ('PRTradeReport')) BEGIN
--		SET @InsertRecord = 0
--	END	

	IF (@InsertRecord = 1) BEGIN
		INSERT INTO Locks (Lock_SessionId, Lock_TableId, Lock_RecordId, Lock_CreatedBy, Lock_CreatedDate, Lock_IsWapUser, Lock_DeviceID)  
        VALUES(@SessionID,     @TableID,     @RecordID,     @CreatedBy,     @CreatedDate,     @IsWapUser,     @DeviceID);
	END

/*
	INSERT INTO LocksAuditLog (Lock_SessionId, Lock_TableId, Lock_RecordId, Lock_CreatedBy, Lock_CreatedDate, Lock_IsWapUser, Lock_DeviceID)  
                VALUES(@SessionID,     @TableID,     @RecordID,     @CreatedBy,     @CreatedDate,     @IsWapUser,     @DeviceID);
*/

END

Go

/* ************************************************************
 * Name:   dbo.trg_PRTESForm_upd
 * 
 * Table:  PRTESForm
 * Action: FOR UPDATE
 * 
 * Description: UPDATE trigger that 
 *              when the Sent Date/Time column is set on the PRTESForm table, 
 *              updates all associated PRTESRequests Sent Date/Time values.
 *                 
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRTESForm_upd]'))
drop trigger [dbo].[trg_PRTESForm_upd]
GO

CREATE TRIGGER [dbo].[trg_PRTESForm_upd]
ON [dbo].[PRTESForm]
FOR UPDATE AS
BEGIN
    SET NOCOUNT ON
    
	UPDATE PRTESRequest
       SET prtesr_SentDateTime = prtf_SentDateTime
      FROM PRTESRequest
           INNER JOIN inserted ON prtesr_TESFormID = prtf_TESFormID;

END
Go


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRAdCampaign_ins]'))
drop trigger [dbo].[trg_PRAdCampaign_ins]
GO

CREATE TRIGGER [dbo].[trg_PRAdCampaign_ins]
ON [dbo].[PRAdCampaign]
FOR INSERT AS
BEGIN

	DECLARE @AdCampaignType varchar(40), @AdCampaignName varchar(50), @Section varchar(100)
    DECLARE @Msg varchar(5000), @StatusDesc varchar(100)
    DECLARE @UserID int, @CompanyID int

	SELECT 
		@AdCampaignType = pradc_AdCampaignType,
		@Section = pradc_Section,
		@AdCampaignName = pradc_Name,
		@CompanyID = pradc_CompanyID
    FROM inserted;
	
	IF (@AdCampaignType = 'BP' AND @Section = 'NIB') 
	BEGIN

		SET @UserID = dbo.ufn_GetCustomCaptionValue('AssignmentUserID', 'Editor', 'en-us')
		SET @Msg = 'A new Ad Campaign, ' + @AdCampaignName + ' has been inserted with section NIB for BB ID ' + CAST(@CompanyID AS varchar(10)) + '.'
		EXEC usp_CreateTask @AssignedToUserID = @UserID, @TaskNotes = @Msg, @RelatedCompanyID = @CompanyID, @Subject = 'Blueprints New in Blue ad created'

	END
END
Go


IF EXISTS (SELECT 'x' FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[trg_PRAdCampaign_upd]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
	DROP TRIGGER [dbo].[trg_PRAdCampaign_upd]
GO

IF EXISTS (SELECT 'x' FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[trg_PRAdCampaign_del]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
	DROP TRIGGER [dbo].[trg_PRAdCampaign_del]
GO

/* ************************************************************
 * Name:   trg_PRCreditsheet_ins
 * 
 * Table:  PRCreditSheet
 * Action: FOR INSERT
 * 
 * Description: Insert trigger on the PRCreditSheet table to check for active ad campaigns.  
 *              If any are found, creates a task for the editor. 
 *                 
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRCreditsheet_ins]'))
	drop trigger [dbo].[trg_PRCreditsheet_ins]
GO

/*
CREATE TRIGGER [dbo].[trg_PRCreditsheet_ins]
ON [dbo].[PRCreditSheet]
FOR INSERT AS
BEGIN

    DECLARE @Msg varchar(5000)
    DECLARE @UserID int, @CompanyID int

	SELECT 
		@CompanyID = prcs_CompanyId
    FROM inserted;

	DECLARE @MyTable table (
		ndx int identity(1,1),
		CaptCode varchar(40)
	)

	INSERT INTO @MyTable (CaptCode)
	SELECT RTRIM(capt_code)
	FROM Custom_Captions 
	WHERE capt_family = 'pradc_BlueprintsEdition'
	 AND  SUBSTRING(capt_code, 1, 4) + '-' + SUBSTRING(capt_code, 5, 2)  + '-01' >= GETDATE()

	DECLARE @Count int, @Index int, @Edition varchar(40)
	DECLARE @AdCount int, @TempCount int
	SET @AdCount = 0

	SELECT @Count = COUNT(1) FROM @MyTable
	SET @Index = 1

	WHILE @Index <= @Count 
		BEGIN

			SELECT 
				@Edition = '%,' + CaptCode + ',%' 
			FROM @MyTable 
			WHERE ndx = @Index

			SELECT 
				@TempCount = COUNT(1) 
			FROM PRAdCampaign 
			WHERE pradc_CompanyID = @CompanyID 
			  AND pradc_AdCampaignType = 'BP'
			  AND pradc_BluePrintsEdition LIKE @Edition

			SET @AdCount = @AdCount + @TempCount
			
			SET @Index = @Index + 1
		END

	IF (@AdCount = 0)
		BEGIN
			SELECT 
				@AdCount = COUNT(1) 
			FROM PRAdCampaign 
			WHERE pradc_AdCampaignType = 'PUB'
			  AND pradc_CompanyID = @CompanyID 
			  AND GETDATE() <= pradc_EndDate;
		END

	IF (@AdCount > 0)
		BEGIN
			SET @UserID = dbo.ufn_GetCustomCaptionValue('AssignmentUserID', 'Editor', 'en-us')
			SET @Msg = 'There are ' + CAST(@AdCount As varchar(10)) + ' Ad Campaigns for BB ID ' + CAST(@CompanyID AS varchar(10)) + '.'
			EXEC usp_CreateTask @AssignedToUserID = @UserID, 
			                    @TaskNotes = @Msg, 
								@RelatedCompanyID = @CompanyID, 
								@Status = 'Pending',
								@Subject = 'Credit Sheet item created and Company had Advertising.'
		END
END
*/
Go




if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRCompanyPayIndicator_ins]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRCompanyPayIndicator_ins]
GO

CREATE TRIGGER [dbo].[trg_PRCompanyPayIndicator_ins]
ON [dbo].[PRCompanyPayIndicator]
FOR INSERT AS
BEGIN
	    
	DECLARE @prcpi_CompanyPayIndicatorID int, @prcpi_OldCompanyPayIndicatorID int
    DECLARE @prcpi_CompanyID int
    DECLARE @prcpi_Current varchar(1)

	-- Get our current record's values
	SELECT @prcpi_CompanyPayIndicatorID = prcpi_CompanyPayIndicatorID,
           @prcpi_CompanyID = prcpi_CompanyID,
           @prcpi_Current = prcpi_Current
	  FROM inserted;

	IF (@prcpi_Current = 'Y') BEGIN
		-- Get our previous record's values
		SELECT @prcpi_OldCompanyPayIndicatorID = prcpi_CompanyPayIndicatorID
		  FROM PRCompanyPayIndicator
		 WHERE prcpi_CompanyID = @prcpi_CompanyID
           AND prcpi_CompanyPayIndicatorID != @prcpi_CompanyPayIndicatorID
		   AND prcpi_Current = 'Y';

		IF (@prcpi_OldCompanyPayIndicatorID IS NOT NULL) BEGIN
			-- Update the old current record
			UPDATE PRCompanyPayIndicator 
			   SET prcpi_Current = NULL
			 WHERE prcpi_CompanyPayIndicatorID = @prcpi_OldCompanyPayIndicatorID;
		END
		
		EXEC usp_UpdateListing @prcpi_CompanyID;
	END

END
GO

if exists (select * from dbo.sysobjects where id =  object_id(N'[dbo].[trg_Opportunity_insupd]')
	and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_Opportunity_insupd]
GO

CREATE TRIGGER dbo.trg_Opportunity_insupd
ON Opportunity
FOR INSERT, UPDATE AS
BEGIN

	DECLARE @OpportunityID int 
	DECLARE @NewAssignedToUserID int, @OldAssignedToUserID int
	DECLARE @NewStage varchar(40), @OldStage varchar(40)
	DECLARE @NewStatus varchar(40), @OldStatus varchar(40)
	
	SELECT @OpportunityID = oppo_OpportunityID,
	       @NewStatus = oppo_Status,
	       @NewStage = oppo_Stage,
	       @NewAssignedToUserID = oppo_AssignedUserId
	  FROM inserted;

	SELECT @OldStatus = oppo_Status,
	       @OldStage = oppo_Stage,
	       @OldAssignedToUserID = oppo_AssignedUserId
	  FROM deleted;


	--
	--  When an opportunity is closed, we want to track
	--  the closed date/time.
	SET @OldStatus = ISNULL(@OldStatus, 'x')
	IF (@NewStatus <> 'Open') AND (@OldStatus = 'Open') BEGIN
		UPDATE Opportunity 
		   SET oppo_Closed = GETDATE() 
		 WHERE oppo_OpportunityID=@OpportunityID;
	END	
	
	--
	--  As the stage values change, we need to track
	--  the last date/time we were in each stage
	SET @OldStage = ISNULL(@OldStage, 'x')
	IF (@NewStage = 'Lead') AND (@OldStage <> 'Lead') BEGIN
		UPDATE Opportunity 
		   SET oppo_PRLeadDateTime = GETDATE() 
		 WHERE oppo_OpportunityID=@OpportunityID;
	END
	
	IF (@NewStage = 'Prospect') AND (@OldStage <> 'Prospect') BEGIN
		UPDATE Opportunity 
		   SET oppo_PRProspectDateTime = GETDATE() 
		 WHERE oppo_OpportunityID=@OpportunityID;
	END

	IF (@NewStage = 'Opportunity') AND (@OldStage <> 'Opportunity') BEGIN
		UPDATE Opportunity 
		   SET oppo_PROpportunityDateTime = GETDATE() 
		 WHERE oppo_OpportunityID=@OpportunityID;
	END
	
	--
	-- If we have an assigned user, then make
	-- sure we set the default channel
	SET @OldAssignedToUserID = ISNULL(@OldAssignedToUserID, 0)
	IF (@NewAssignedToUserID IS NOT NULL) AND
	   (@NewAssignedToUserID <> @OldAssignedToUserID) BEGIN
		DECLARE @ChannelID int
		
		SELECT @ChannelID = user_PrimaryChannelId
		  FROM Users
		 WHERE user_UserID=@NewAssignedToUserID;
	
		UPDATE Opportunity 
		   SET oppo_ChannelId = @ChannelID
		 WHERE oppo_OpportunityID=@OpportunityID;
	END
END
Go


if exists (select * from dbo.sysobjects where id =  object_id(N'[dbo].[trg_PRCompanyTradeAssociation_ioins]')
	and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRCompanyTradeAssociation_ioins]
GO

CREATE TRIGGER [dbo].[trg_PRCompanyTradeAssociation_ioins]
ON [dbo].[PRCompanyTradeAssociation]
INSTEAD OF INSERT AS
BEGIN

	-- First insert those records that have
	-- a record ID.
	INSERT INTO PRCompanyTradeAssociation
		(prcta_CompanyTradeAssociationID, prcta_CompanyID, prcta_TradeAssociationCode, prcta_MemberID, prcta_Disabled, prcta_IsIntlTradeAssociation,
		 prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp)
    SELECT prcta_CompanyTradeAssociationID, prcta_CompanyID, prcta_TradeAssociationCode, prcta_MemberID, prcta_Disabled, prcta_IsIntlTradeAssociation,
	       prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp
	  FROM inserted
	 WHERE prcta_CompanyTradeAssociationID IS NOT NULL;


	--
	-- Now handle those that don't have an ID
	-- 
	DECLARE @Inserts table (
		ndx int identity, 
		prcta_CompanyID int,
		prcta_TradeAssociationCode varchar(40),
		prcta_MemberID varchar(25),
		prcta_Disabled char(1),
		prcta_IsIntlTradeAssociation char(1),
		prcta_CreatedBy int,
		prcta_CreatedDate datetime,
		prcta_UpdatedBy int,
		prcta_UpdatedDate datetime,
		prcta_TimeStamp datetime
	)
	
	DECLARE @ndx int, @InsertedCount int, @RecordID int

	INSERT INTO @Inserts 
		(prcta_CompanyID, prcta_TradeAssociationCode, prcta_MemberID, prcta_Disabled, prcta_IsIntlTradeAssociation,
		 prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp)
    SELECT prcta_CompanyID, prcta_TradeAssociationCode, 	prcta_MemberID, prcta_Disabled, prcta_IsIntlTradeAssociation,
	       prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp
	  FROM inserted
	 WHERE prcta_CompanyTradeAssociationID IS NULL;


	SET @InsertedCount = @@ROWCOUNT
	SET @ndx = 1
	WHILE (@ndx <= @InsertedCount)
	BEGIN
	
		EXEC usp_getNextId 'PRCompanyTradeAssociation', @RecordID output
		
		INSERT INTO PRCompanyTradeAssociation
			(prcta_CompanyTradeAssociationID, prcta_CompanyID, prcta_TradeAssociationCode, 	prcta_MemberID, prcta_Disabled, prcta_IsIntlTradeAssociation,
			 prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp)
		SELECT @RecordID, prcta_CompanyID, prcta_TradeAssociationCode, 	prcta_MemberID, prcta_Disabled, prcta_IsIntlTradeAssociation,
			   prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp
		  FROM @Inserts
		 WHERE ndx = @ndx;		

		SET @ndx = @ndx +1
	END
END
Go



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRCompanyBrand_ins]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRCompanyBrand_ins]
GO

CREATE TRIGGER [dbo].[trg_PRCompanyBrand_ins]
ON [dbo].[PRCompanyBrand]
FOR INSERT AS
BEGIN

	DECLARE @RecordID int, @SequenceNumber int, @CompanyID int
	 
	-- Get our key fields from the inserted record
	SELECT @RecordID = prc3_CompanyBrandId,
	       @CompanyID = prc3_CompanyId,
		   @SequenceNumber = ISNULL(prc3_Sequence, -1)
	  FROM inserted
	 
	 IF (@SequenceNumber = -1) BEGIN
		-- Get our current max sequence value excluding the current record.  
		SELECT @SequenceNumber = ISNULL(MAX([prc3_Sequence]), -1) 
		  FROM PRCompanyBrand
		 WHERE prc3_CompanyId = @CompanyID
	 
		-- Increment it
		SET @SequenceNumber = @SequenceNumber + 1
	
		-- Reset our value.
		UPDATE PRCompanyBrand
		   SET prc3_Sequence = @SequenceNumber
		 WHERE prc3_CompanyBrandId = @RecordID;
	END
END
GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRCompanyBrand_insupddel]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRCompanyBrand_insupddel]
GO

CREATE TRIGGER [dbo].[trg_PRCompanyBrand_insupddel]
ON [dbo].[PRCompanyBrand]
FOR INSERT, UPDATE, DELETE AS
BEGIN

	DECLARE @CompanyID int, @RecordID int, @UserID int

	SELECT @CompanyID = prc3_CompanyId,
	       @RecordID = prc3_CompanyBrandId,
	       @UserID = prc3_UpdatedBy
	  FROM inserted;
	  
	IF (@CompanyID IS NULL) BEGIN
		SELECT @CompanyID = prc3_CompanyId,
			   @RecordID = prc3_CompanyBrandId,
			   @UserID = prc3_UpdatedBy
		  FROM deleted;	
	END

	IF (@CompanyID IS NOT NULL) BEGIN
		-- The action is 'Update' because logically the company
		-- is being updated.  
		INSERT INTO PRChangeDetection (prchngd_CompanyID, prchngd_ChangeType, prchngd_AssociatedID, prchngd_AssociatedType, prchngd_CreatedBy, prchngd_UpdatedBy)
		VALUES (@CompanyID, 'Update', @RecordID, 'PRCompanyBrand', @UserID, @UserID);	
	END
END
Go
	

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRAttentionLine_upd]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRAttentionLine_upd]
GO

CREATE TRIGGER [dbo].[trg_PRAttentionLine_upd]
ON [dbo].[PRAttentionLine]
FOR UPDATE AS
BEGIN

	DECLARE @CompanyID int, @RecordID int, @UserID int
	DECLARE @ItemCode varchar(40)

	SELECT @CompanyID = prattn_CompanyID,
	       @RecordID = prattn_AttentionLineID,
	       @UserID = prattn_UpdatedBy,
	       @ItemCode = prattn_ItemCode
	  FROM inserted;

	IF (@ItemCode = 'BILL') BEGIN
		INSERT INTO PRChangeDetection (prchngd_CompanyID, prchngd_ChangeType, prchngd_AssociatedID, prchngd_AssociatedType, prchngd_CreatedBy, prchngd_UpdatedBy)
		VALUES (@CompanyID, 'Update', @RecordID, 'PRAttentionLine', @UserID, @UserID);	
	END

END
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRAttentionLine_insupd]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRAttentionLine_insupd]
GO

CREATE TRIGGER [dbo].[trg_PRAttentionLine_insupd]
ON [dbo].[PRAttentionLine]
FOR INSERT, UPDATE AS
BEGIN

	DECLARE @RecordID int, @AddressID int
	DECLARE @ItemCode varchar(40), @IncludeWTI char(1)

	SELECT @RecordID = prattn_AttentionLineID,
	       @ItemCode = prattn_ItemCode,
		   @AddressID = prattn_AddressID,
		   @IncludeWTI =prattn_IncludeWireTransferInstructions
	  FROM inserted;

	IF (@ItemCode = 'BILL') BEGIN
	
		IF ((@AddressID IS NOT NULL AND @AddressID > 0) AND
		    (ISNULL(@IncludeWTI, 'N') <> 'Y')) BEGIN

			DECLARE @CountryID int
			SELECT @CountryID = prcn_CountryID FROM vPRAddress WHERE addr_AddressID=@AddressID
			IF (@CountryID >= 3) BEGIN
				UPDATE PRAttentionLine
				   SET prattn_IncludeWireTransferInstructions = 'Y'
				 WHERE prattn_AttentionLineID = @RecordID

			END
		END
	END

END
Go


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_Person_upd]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_Person_upd]
GO

CREATE TRIGGER [dbo].[trg_Person_upd]
ON [dbo].[Person]
FOR UPDATE AS
BEGIN

	DECLARE @CompanyID int, @RecordID int, @UserID int

	SELECT @CompanyID = prattn_CompanyID,
	       @RecordID = pers_PersonID,
	       @UserID = pers_UpdatedBy
	  FROM inserted
	       LEFT OUTER JOIN PRAttentionLine ON pers_PersonID = prattn_PersonID AND prattn_ItemCode = 'BILL';

	IF (@CompanyID IS NOT NULL) BEGIN
		INSERT INTO PRChangeDetection (prchngd_CompanyID, prchngd_ChangeType, prchngd_AssociatedID, prchngd_AssociatedType, prchngd_CreatedBy, prchngd_UpdatedBy)
		VALUES (@CompanyID, 'Update', @RecordID, 'Person', @UserID, @UserID);	
	END

		-- if the comp_name field changed refresh both the full name and the duplicate search value
	UPDATE Person 
	   SET pers_FirstNameAlphaOnly = dbo.GetLowerAlpha(Pers_FirstName),
		   pers_LastNameAlphaOnly = dbo.GetLowerAlpha(Pers_LastName)
     WHERE pers_PersonID= @RecordID;
END
Go


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_Person_ins]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_Person_ins]
GO

CREATE TRIGGER [dbo].[trg_Person_ins]
ON [dbo].[Person]
FOR INSERT AS
BEGIN

	DECLARE @CompanyID int, @RecordID int, @UserID int

	SELECT @CompanyID = prattn_CompanyID,
	       @RecordID = pers_PersonID,
	       @UserID = pers_UpdatedBy
	  FROM inserted
	       LEFT OUTER JOIN PRAttentionLine ON pers_PersonID = prattn_PersonID AND prattn_ItemCode = 'BILL';

	IF (@CompanyID IS NOT NULL) BEGIN
		INSERT INTO PRChangeDetection (prchngd_CompanyID, prchngd_ChangeType, prchngd_AssociatedID, prchngd_AssociatedType, prchngd_CreatedBy, prchngd_UpdatedBy)
		VALUES (@CompanyID, 'Update', @RecordID, 'Person', @UserID, @UserID);	
	END

		-- if the comp_name field changed refresh both the full name and the duplicate search value
	UPDATE Person 
	   SET pers_FirstNameAlphaOnly = dbo.GetLowerAlpha(i.Pers_FirstName),
		   pers_LastNameAlphaOnly = dbo.GetLowerAlpha(i.Pers_LastName)
	  FROM inserted i
     WHERE i.pers_PersonID= Person.pers_PersonID;
END
Go



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRShippingLog_upd]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRShippingLog_upd]
GO

CREATE TRIGGER [dbo].[trg_PRShippingLog_upd]
ON [dbo].[PRShipmentLog]
FOR UPDATE AS
BEGIN

	DECLARE @RecordID int
	DECLARE @CarrierCode varchar(40), @OldCarrierCode varchar(40)
	DECLARE @TrackingNumber varchar(50), @OldTrackingNumber varchar(50)

	SELECT @RecordID = prshplg_ShipmentLogID,
	       @CarrierCode = prshplg_CarrierCode,
	       @TrackingNumber = prshplg_TrackingNumber
	  FROM inserted;

	SELECT @OldCarrierCode = prshplg_CarrierCode,
	       @OldTrackingNumber = prshplg_TrackingNumber
	  FROM deleted;

	IF (@OldCarrierCode IS NULL) AND
	   (@OldTrackingNumber IS NULL) AND
	   (@CarrierCode IS NULL) AND
	   (@TrackingNumber IS NOT NULL)
	BEGIN
	
		UPDATE PRShipmentLog
		   SET prshplg_CarrierCode = 'USPS'
		 WHERE prshplg_ShipmentLogID = @RecordID;
	END

END
Go


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRCompanyIndicator_upd]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRCompanyIndicator_upd]
GO

CREATE TRIGGER [dbo].[trg_PRCompanyIndicator_upd]
ON [dbo].[PRCompanyIndicators]
FOR INSERT, UPDATE AS
BEGIN


	--
	--  If our TaxExempt goes from Y to NULL, then
	--  set the tax code based on the default tax
	--  address
	--
	UPDATE PRCompanyIndicators
	   SET prci2_TaxCode = dbo.ufn_GetTaxCode(addr_AddressID)
	  FROM vPRAddress 
	       INNER JOIN inserted i ON adli_CompanyId = i.prci2_CompanyID
		   INNER JOIN deleted d ON i.prci2_CompanyIndicatorID = d.prci2_CompanyIndicatorID
		   INNER JOIN PRCompanyIndicators ci ON i.prci2_CompanyIndicatorID = ci.prci2_CompanyIndicatorID
     WHERE adli_PRDefaultTax = 'Y'
       AND i.prci2_TaxCode = d.prci2_TaxCode
	   AND i.prci2_TaxExempt IS NULL
	   AND d.prci2_TaxExempt = 'Y';


	UPDATE PRCompanyIndicators
	   SET prci2_TaxCode = 'NT'
	  FROM inserted i 
		   INNER JOIN deleted d ON i.prci2_CompanyIndicatorID = d.prci2_CompanyIndicatorID
		   INNER JOIN PRCompanyIndicators ci ON i.prci2_CompanyIndicatorID = ci.prci2_CompanyIndicatorID
     WHERE i.prci2_TaxCode = d.prci2_TaxCode
	   AND i.prci2_TaxExempt = 'Y'
	   AND d.prci2_TaxExempt IS NULL;


	--
	--  We need to handle many records being updated
	--  via a single update statement
	--
	INSERT INTO PRChangeDetection (prchngd_CompanyID, prchngd_ChangeType, prchngd_AssociatedID, prchngd_AssociatedType, prchngd_CreatedBy, prchngd_UpdatedBy)	
	SELECT prci2_CompanyID, 'Update', prci2_CompanyIndicatorID, 'PRCompanyIndicators', prci2_UpdatedBy, prci2_UpdatedBy
	  FROM inserted	
	 WHERE prci2_CompanyID IS NOT NULL;

END
Go



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRCountry_insupd]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRCountry_insupd]
GO

CREATE TRIGGER [dbo].[trg_PRCountry_insupd]
ON [dbo].[PRCountry]
FOR INSERT, UPDATE AS
BEGIN

	DECLARE @IsUpdate bit = 0
		
	IF EXISTS (SELECT 'x' FROM deleted) BEGIN
		SET @IsUpdate = 1
	END

	IF (@IsUpdate = 1) BEGIN
	
		UPDATE MAS_SYSTEM.dbo.SY_Country
		   SET CountryName = prcn_Country,
		       PhoneCode = prcn_CountryCode
		  FROM inserted
		 WHERE CountryCode = CAST(prcn_CountryId as varchar(10));
	
	END ELSE BEGIN

		INSERT INTO MAS_SYSTEM.dbo.SY_Country
		SELECT prcn_CountryId, prcn_Country, prcn_CountryCode, '', prcn_IATACode, 'N'
		  FROM inserted;

	END
END
Go


if exists (select * from dbo.sysobjects where id =  object_id(N'[dbo].[trg_PRWebUserListDetail_ins]')
	and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRWebUserListDetail_ins]
GO

CREATE TRIGGER dbo.trg_PRWebUserListDetail_ins
ON PRWebUserListDetail
FOR INSERT AS

BEGIN
	SET NOCOUNT ON

	DECLARE @WebUserListID int, @CompanyID int, @SubjectCompanyID int


	SELECT @WebUserListID = prwucl_WebUserListID,
	       @CompanyID = prwucl_CompanyID,
		   @SubjectCompanyID = prwuld_AssociatedID
	  FROM PRWebUserList 
	       INNER JOIN inserted ON prwucl_WebUserListID = prwuld_WebUserListID
     WHERE prwucl_TypeCode = 'AUS'

	 IF (@WebUserListID IS NOT NULL) BEGIN
		EXEC usp_UpdateCompanyRelationship @CompanyId, @SubjectCompanyID, '23', 0
	END
END
Go



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRConnectionList_ins]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
	DROP TRIGGER [dbo].[trg_PRConnectionList_ins]
GO

CREATE TRIGGER [dbo].[trg_PRConnectionList_ins]
ON [dbo].[PRConnectionList]
FOR INSERT, UPDATE AS
BEGIN
    SET NOCOUNT ON

	DECLARE @CompanyID int,  @CurrentConnectionListID int 
	DECLARE @ConnectionListDate date

	SELECT @CompanyID = prcl2_CompanyID
	  FROM inserted;

	--
	--  Set the most recent Connection List as Current.
	--
	SELECT TOP 1 @CurrentConnectionListID = prcl2_ConnectionListID,
	       @ConnectionListDate = prcl2_ConnectionListDate
	  FROM PRConnectionList
	 WHERE prcl2_CompanyID = @CompanyID
  ORDER BY prcl2_ConnectionListDate DESC;

	UPDATE PRConnectionList
	   SET prcl2_Current = NULL
	 WHERE prcl2_CompanyID = @CompanyID; 
	
	UPDATE PRConnectionList
	   SET prcl2_Current = 'Y'
	 WHERE prcl2_ConnectionListID = @CurrentConnectionListID; 

	 UPDATE Company 
	    SET comp_PRConnectionListDate = @ConnectionListDate
	  WHERE comp_CompanyID = @CompanyID
	    AND comp_PRConnectionListDate <> @ConnectionListDate

END
Go

IF EXISTS (SELECT 'x' FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[trg_PublicationArticle_WPNews]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
	DROP TRIGGER [dbo].[trg_PublicationArticle_WPNews]
GO

IF EXISTS (SELECT 'x' FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[trg_PublicationArticle_WPNews_Del]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
	DROP TRIGGER [dbo].[trg_PublicationArticle_WPNews_Del]
GO

if exists (select * from dbo.sysobjects where id =  object_id(N'[dbo].[trg_PRPACALicense_insupddel]')
	and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRPACALicense_insupddel]
GO

CREATE TRIGGER dbo.trg_PRPACALicense_insupddel
	ON PRPACALicense
FOR INSERT, UPDATE, DELETE AS

BEGIN
	
	DECLARE @CompanyID int

	SELECT @CompanyID = prpa_CompanyId
	  FROM inserted;

	IF (@CompanyID IS NULL) BEGIN
		SELECT @CompanyID = prpa_CompanyId
		  FROM deleted;
	END

	IF (@CompanyID IS NOT NULL) BEGIN
		EXEC usp_UpdateListing @CompanyID
	END
END
Go


if exists (select * from dbo.sysobjects where id =  object_id(N'[dbo].[trg_PRCommunicationLog_upd]')
	and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRCommunicationLog_upd]
GO

CREATE TRIGGER dbo.trg_PRCommunicationLog_upd
	ON PRCommunicationLog
FOR UPDATE AS

BEGIN
	SET NOCOUNT ON

	UPDATE PRCommunicationLog
	   SET prcoml_TranslatedFaxID = REPLACE(SUBSTRING(prcoml_FaxID, CHARINDEX('h', prcoml_FaxID)+1, LEN(prcoml_FaxID) - CHARINDEX('h', prcoml_FaxID)-1), 'r17j', '-')
	 WHERE prcoml_FaxID IS NOT NULL
	   AND prcoml_TranslatedFaxID IS NULL
	   AND prcoml_CommunicationLog IN (SELECT prcoml_CommunicationLog FROM inserted);
END
Go


if exists (select * from dbo.sysobjects where id =  object_id(N'[dbo].[trg_PRPACALicense_match]')
	and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRPACALicense_match]
GO

CREATE TRIGGER dbo.trg_PRPACALicense_match
	ON PRPACALicense
FOR INSERT, UPDATE AS
BEGIN

	UPDATE PRPACALicense 
	   SET prpa_CompanyNameMatch = dbo.GetLowerAlpha(dbo.ufn_PrepareCompanyName(PRPACALicense.prpa_CompanyName)) 
	  FROM inserted i
	 WHERE i.prpa_PACALicenseId = PRPACALicense.prpa_PACALicenseId
	
END
Go


if exists (select * from dbo.sysobjects where id =  object_id(N'[dbo].[trg_PRCourtCases_ins]')
	and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRCourtCases_ins]
GO

CREATE TRIGGER dbo.trg_PRCourtCases_ins
ON PRCourtCases
FOR INSERT AS

BEGIN
	SET NOCOUNT ON

	DECLARE @RatingUserId int, @msg varchar (2000)
	DECLARE @ClaimAmt numeric(24,6), @CompanyID int, @UserId int
	DECLARE @Now datetime = getdate() 

	SELECT @CompanyID = prcc_CompanyID,
	       @ClaimAmt = prcc_ClaimAmt,
		   @UserId = prcc_UpdatedBy
	  FROM inserted 

	SET @RatingUserId = dbo.ufn_GetPRCoSpecialistUserId(@CompanyID, 0)
	SET @msg = 'Lawsuit filed against company in the amount of $' + convert(varchar(20), ISNULL(CAST(@ClaimAmt as numeric(24,2)), '')) + '.'

	EXEC usp_CreateTask     
				@StartDateTime = @Now,
				@CreatorUserId = @UserId,
				@AssignedToUserId = @RatingUserId,
				@TaskNotes = @msg,
				@RelatedCompanyId = @CompanyID,
				@Status = 'Pending',
				@Subject = 'Lawsuit Filed'

	SET NOCOUNT OFF
END
GO




if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRCompanyInfoProfile_insupd]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRCompanyInfoProfile_insupd]
GO

CREATE TRIGGER [dbo].[trg_PRCompanyInfoProfile_insupd]
	ON [dbo].[PRCompanyInfoProfile]
FOR INSERT, UPDATE AS
BEGIN
    SET NOCOUNT ON
    
    DECLARE @CompanyId int
    DECLARE @prc5_ReceiveChristmasCard char(1), @Oldprc5_ReceiveChristmasCard char(1)

	-- Get our current record's values
    SELECT @CompanyId = prc5_CompanyId, 
		   @prc5_ReceiveChristmasCard  = prc5_ReceiveChristmasCard
    FROM inserted 

    SELECT @Oldprc5_ReceiveChristmasCard  = prc5_ReceiveChristmasCard
    FROM deleted 


	IF ((ISNULL(@prc5_ReceiveChristmasCard, 'N') = 'Y') AND
	    (ISNULL(@Oldprc5_ReceiveChristmasCard, 'N') = 'N'))
	BEGIN
		EXEC usp_AttentionLineSetDefault @CompanyId, 'BBSICC', 1
    END

	IF ((ISNULL(@prc5_ReceiveChristmasCard, 'N') = 'N') AND
	    (ISNULL(@Oldprc5_ReceiveChristmasCard, 'N') = 'Y'))
	BEGIN
		DELETE FROM PRAttentionLine WHERE prattn_CompanyID=@CompanyId AND prattn_ItemCode = 'BBSICC';
    END

	SET NOCOUNT OFF
END
GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRChangeDetection_upd]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRChangeDetection_upd]
GO

CREATE TRIGGER [dbo].[trg_PRChangeDetection_upd]
	ON [dbo].[PRChangeDetection]
FOR INSERT AS
BEGIN

	DELETE PRChangeDetection
	  FROM PRChangeDetection
	       INNER JOIN Company WITH (NOLOCK) ON prchngd_CompanyID = comp_CompanyID
     WHERE comp_PRLocalSource = 'Y'
	    OR comp_PRIsIntlTradeAssociation = 'Y';

END
Go

--Defect 4313
/*
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRSalesOrderAuditTrail_ins]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRSalesOrderAuditTrail_ins]
**GO

CREATE TRIGGER [dbo].[trg_PRSalesOrderAuditTrail_ins]
	ON [dbo].[PRSalesOrderAuditTrail]
FOR INSERT AS
BEGIN
	/*
		We may have multiple records since cancelling an order often comprises
		multiple line items.
	*/

	DECLARE @iItemCode varchar(30)
	DECLARE @CompanyID int
	DECLARE @DateUpdated datetime

	SELECT @iItemCode = prsoat_ItemCode, 
		   @CompanyID = CASE WHEN ISNULL(prsoat_BillToCompany,0) = 0 THEN prsoat_SoldToCompany ELSE prsoat_BillToCompany END,
		   @DateUpdated = prsoat_UpdatedDate
	  FROM inserted
	 WHERE prsoat_CancelReasonCode = 'C23'
	   AND prsoat_ItemCode IN (SELECT ItemCode FROM MAS_PRC.dbo.CI_Item WHERE Category2='PRIMARY')

	IF (@iItemCode IS NOT NULL)
	BEGIN
		DECLARE @Msg nvarchar(max) = 'Blue Book Membership cancelled for non-payment (' + CONVERT(VARCHAR(10), @DateUpdated, 1)  + ')'

		BEGIN TRY
			ALTER TABLE CRM.dbo.Company DISABLE TRIGGER ALL
            UPDATE CRM.dbo.Company 
				SET comp_PRSpecialInstruction =
				CASE 
					WHEN comp_PRSpecialInstruction IS NULL THEN ''
					ELSE CAST(comp_PRSpecialInstruction AS nvarchar(max)) + ' '
				END + @Msg 
				WHERE comp_CompanyID = @CompanyID
            ALTER TABLE CRM.dbo.Company ENABLE TRIGGER ALL
		END TRY
		BEGIN CATCH
			ALTER TABLE CRM.dbo.Company ENABLE TRIGGER ALL
		END CATCH
	END
END
**Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRSalesOrderAuditTrail_upd]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRSalesOrderAuditTrail_upd]
**GO

CREATE TRIGGER [dbo].trg_PRSalesOrderAuditTrail_upd
ON [dbo].[PRSalesOrderAuditTrail]
FOR UPDATE AS
BEGIN

	DECLARE @iItemCode varchar(30)
	DECLARE @CompanyID int
	DECLARE @DateUpdated datetime


	SELECT @iItemCode = i.prsoat_ItemCode, 
		   @CompanyID = CASE WHEN ISNULL(i.prsoat_BillToCompany,0) = 0 THEN i.prsoat_SoldToCompany ELSE i.prsoat_BillToCompany END,
		   @DateUpdated = i.prsoat_UpdatedDate
	  FROM inserted i
	       INNER JOIN deleted d on i.prsoat_SalesOrderAuditTrailID = d.prsoat_SalesOrderAuditTrailID
	 WHERE i.prsoat_CancelReasonCode = 'C23'
	   AND ISNULL(d.prsoat_CancelReasonCode, '') <> i.prsoat_CancelReasonCode
	   AND i.prsoat_ItemCode IN (SELECT ItemCode FROM MAS_PRC.dbo.CI_Item WHERE Category2='PRIMARY')

	IF (@iItemCode IS NOT NULL)
		BEGIN
			DECLARE @Msg nvarchar(max) = 'Blue Book Membership cancelled for non-payment (' + CONVERT(VARCHAR(10), @DateUpdated, 1)  + ')'

			BEGIN TRY
				ALTER TABLE CRM.dbo.Company DISABLE TRIGGER ALL
                UPDATE CRM.dbo.Company 
				   SET comp_PRSpecialInstruction =
					CASE 
						WHEN comp_PRSpecialInstruction IS NULL THEN ''
						ELSE CAST(comp_PRSpecialInstruction AS nvarchar(max)) + ' '
					END + @Msg 
				 WHERE comp_CompanyID = @CompanyID
                ALTER TABLE CRM.dbo.Company ENABLE TRIGGER ALL
			END TRY
			BEGIN CATCH
				ALTER TABLE CRM.dbo.Company ENABLE TRIGGER ALL
			END CATCH
		END
END
**Go
*/


USE WordPressProduce
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_wp_postmeta_insupd]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_wp_postmeta_insupd]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_wp_posts_insupd_produce]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_wp_posts_insupd_produce]
GO

CREATE TRIGGER [dbo].[trg_wp_posts_insupd_produce]
	ON [dbo].[wp_posts]
AFTER INSERT, UPDATE AS
BEGIN
	SET NOCOUNT ON
	DECLARE @Pattern varchar(10) = '%{{BB #:%'
	DECLARE @BBOSURL varchar(500) = (SELECT Capt_US FROM CRM.dbo.custom_captions  where capt_family='BBOS' and capt_code='URL')
	DECLARE @BBLink varchar(max) = 'CompanyDetailsSummary.aspx?RL=CM&CompanyID='
	DECLARE @Link varchar(100) = '<a href=''{0}'' target=''_blank''>BB #:{1}</a>'

	DECLARE @post_content varchar(max)
	SELECT @post_content = post_content FROM inserted;

	DECLARE @pos int = PATINDEX(@Pattern, @post_content)
	DECLARE @err bit = 0

	WHILE @pos > 0 BEGIN
		DECLARE @Instance varchar(100) = SUBSTRING(@post_content, @pos, 15)
		IF(RIGHT(@Instance,2) <> '}}') BEGIN
			--SET @err = 1
			BREAK;
		END
	
		DECLARE @BBID varchar(6) = SUBSTRING(@Instance, 8, 6)

		DECLARE @NewLink varchar(500) = REPLACE(@Link, '{0}', @BBOSURL + @BBLink + @BBID)
		SET @NewLink = REPLACE(@NewLink, '{1}', @BBID)

		SET @post_content = STUFF(@post_content, @pos, 15, @NewLink)
		SET @pos = PATINDEX(@Pattern, @post_content);
	END;

	IF(@err = 0) BEGIN
		UPDATE X
		SET post_content = @post_content
		FROM wp_posts X JOIN inserted i ON X.ID = i.ID;
	END
END
Go

USE WordPressLumber
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_wp_postmeta_insupd]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_wp_postmeta_insupd]
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_wp_posts_insupd_lumber]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_wp_posts_insupd_lumber]
GO

CREATE TRIGGER [dbo].[trg_wp_posts_insupd_lumber]
	ON [dbo].[wp_posts]
AFTER INSERT, UPDATE AS
BEGIN
	SET NOCOUNT ON
	DECLARE @Pattern varchar(10) = '%{{BB #:%'
	DECLARE @BBOSURL varchar(500) = (SELECT Capt_US FROM CRM.dbo.custom_captions  where capt_family='BBOS' and capt_code='URL')
	DECLARE @BBLink varchar(max) = 'CompanyDetailsSummary.aspx?RL=CML&CompanyID='
	DECLARE @Link varchar(100) = '<a href=''{0}'' target=''_blank''>BB #:{1}</a>'

	DECLARE @post_content varchar(max)
	SELECT @post_content = post_content FROM inserted;

	DECLARE @pos int = PATINDEX(@Pattern, @post_content)
	DECLARE @err bit = 0

	WHILE @pos > 0 BEGIN
		DECLARE @Instance varchar(100) = SUBSTRING(@post_content, @pos, 15)
		IF(RIGHT(@Instance,2) <> '}}') BEGIN
			--SET @err = 1
			BREAK;
		END
	
		DECLARE @BBID varchar(6) = SUBSTRING(@Instance, 8, 6)

		DECLARE @NewLink varchar(500) = REPLACE(@Link, '{0}', @BBOSURL + @BBLink + @BBID)
		SET @NewLink = REPLACE(@NewLink, '{1}', @BBID)

		SET @post_content = STUFF(@post_content, @pos, 15, @NewLink)
		SET @pos = PATINDEX(@Pattern, @post_content);
	END;

	IF(@err = 0) BEGIN
		UPDATE X
		SET post_content = @post_content
		FROM wp_posts X JOIN inserted i ON X.ID = i.ID;
	END
END
Go

Use CRM

if exists (select * from dbo.sysobjects where id =  object_id(N'[dbo].[trg_PRAdCampaignTerms_insupd]')
	and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].trg_PRAdCampaignTerms_insupd
GO

CREATE TRIGGER [dbo].[trg_PRAdCampaignTerms_insupd]
	ON PRAdCampaignTerms
 FOR INSERT, UPDATE AS
BEGIN

	UPDATE PRAdCampaignTerms
	   SET pract_Processed = 'Y'
	 WHERE pract_BillingDate < '2019-05-14'
	   AND pract_Processed IS NULL
	   AND pract_AdCampaignTermsID IN (SELECT pract_AdCampaignTermsID FROM Inserted)
END
Go

CREATE OR ALTER TRIGGER dbo.trg_PRTaxRate_ins
ON PRTaxRate
FOR INSERT AS

BEGIN

	DECLARE @PostalCode varchar(10), @City varchar(100)
	DECLARE @RecordID int = 0

	SELECT @RecordID = prtax_TaxRateID,
	       @PostalCode = prtax_PostalCode,
	       @City = prtax_City
	  FROM inserted

	IF ((@PostalCode = '60188') AND (@City <> 'CAROL STREAM')) BEGIN
		DELETE FROM PRTaxRate WHERE prtax_TaxRateID=@RecordID
	END

END
Go

--  Remove Word-pasted special chars from Communication Note field on insert/update
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_Communication_insupd]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_Communication_insupd]
GO

CREATE TRIGGER dbo.trg_Communication_insupd
ON Communication
FOR INSERT, UPDATE AS
BEGIN
	UPDATE Communication SET comm_Note = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(comm_Note, '“', '"'), '”', '"'),'’', ''''),'…','...'),'–','-')
	WHERE Comm_CommunicationId IN (SELECT Comm_CommunicationId FROM inserted)
END
Go