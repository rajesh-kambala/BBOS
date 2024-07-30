
IF Exists (SELECT name FROM sysobjects WHERE name = 'ufn_GetCustomCaptionCode') 
    DROP FUNCTION dbo.ufn_GetCustomCaptionCode
GO

--
-- Returns the appropriate caption value for the specified family,
-- code, and culture
--
CREATE FUNCTION ufn_GetCustomCaptionCode(@CaptFamily varchar(30), 
                                         @CaptUS varchar(100)) 
RETURNS varchar(40)
BEGIN
    DECLARE @Value varchar(40)

    SELECT @Value =  capt_code
      FROM Custom_Captions WITH (NOLOCK)
     WHERE capt_Family = @CaptFamily
       AND CAST(capt_us as varchar(max)) = @CaptUS;

    RETURN @Value
END
GO

IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[ufn_GetTransactionDetailOldValue]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    DROP FUNCTION [dbo].ufn_GetTransactionDetailOldValue
GO

CREATE Function ufn_GetTransactionDetailOldValue(@CompanyID int, @CreatedBy int, @Explanation varchar(100), @EntityName varchar(100), @ColumnName varchar(100))
RETURNS varchar(2000)
AS
BEGIN
    
    DECLARE @Return varchar(2000)

	SELECT @Return = prtd_OldValue
	 FROM PRTransaction 
	      INNER JOIN PRTransactionDetail ON prtx_TransactionID = prtd_TransactionID
	WHERE prtx_CompanyID=@CompanyID
	  AND prtx_CreatedBy = @CreatedBy
	  AND prtx_Explanation LIKE @Explanation
	  AND prtd_EntityName = @EntityName
	  AND prtd_ColumnName = @ColumnName
	  AND prtd_Action <> 'Insert'


    RETURN @Return
END
Go



DECLARE @CompanyID int = 303064  --  186281 152520   192397	101948 186281
DECLARE @Commit bit = 0
DECLARE @UserID int = 3
DECLARE @TransExplanation varchar(200) = 'Reversing Local Source Match.'



SET NOCOUNT OFF

if (@Commit = 0) begin
	PRINT '*************************************************************'
	PRINT 'NOTE: COMMIT CHANGES IS TURNED OFF. NO CHANGES WILL BE SAVED!'
	PRINT '*************************************************************'
	PRINT ''
end

DECLARE @Start DateTime
SET @Start = GETDATE()
PRINT 'Execution Start: ' + CONVERT(VARCHAR(20), @Start, 100) + ' on server ' + @@SERVERNAME
PRINT ''

BEGIN TRANSACTION
BEGIN TRY

	DECLARE @ListingStatus varchar(40), @IsLocalSource char(1), @Source varchar(40)

	SELECT @ListingStatus = comp_PRListingStatus,
	       @IsLocalSource = comp_PRLocalSource,
		   @Source = comp_Source
	  FROM Company 
	 WHERE comp_CompanyID = @CompanyID


	IF (ISNULL(@IsLocalSource, 'N') <> 'Y') BEGIN
	    RAISERROR('The specified company ID is not flagged "Local Source".',16,1)
		--RETURN -1
	END

	IF (ISNULL(@Source, 'Z') = 'MMW') BEGIN
	    RAISERROR('The specified company ID has a source of "MMW" so there is nothing to restore.',16,1)
		--RETURN -1
	END

	DECLARE @TrxID int
	EXEC @TrxID = usp_CreateTransaction 
	  		      @UserId = @UserID,
				  @prtx_CompanyId = @CompanyID,
				  @prtx_Explanation = @TransExplanation

	DECLARE @RecordID int, @LinkRecordID int, @CityID int, @CityStateCountry varchar(200)
	DECLARE @Count int = 0
	DECLARE @EntityName varchar(100)
	DECLARE @CreatedBy int = 1
	DECLARE @Explanation varchar(100) = 'Company updated from Local Source import.%'


	--
	--  Restore Company Record
	--
	SET @EntityName = 'Company'

	DECLARE @comp_PRListingStatus varchar(40), @comp_Name varchar(200), @comp_PRCorrTradestyle varchar(200), @comp_PRBookTradestyle varchar(200),
	        @comp_PRTradestyle1 varchar(200), @comp_PROnlineOnly nchar(1)

	SET @comp_PRListingStatus = dbo.ufn_GetTransactionDetailOldValue(@CompanyID, @CreatedBy, @Explanation, @EntityName, 'Listing Status')
	SET @comp_PRListingStatus = dbo.ufn_GetCustomCaptionCode('comp_PRListingStatus', @comp_PRListingStatus)
	
	SET @comp_Name = dbo.ufn_GetTransactionDetailOldValue(@CompanyID, @CreatedBy, @Explanation, @EntityName, 'Company Name')
	SET @comp_PRBookTradestyle = dbo.ufn_GetTransactionDetailOldValue(@CompanyID, @CreatedBy, @Explanation, @EntityName, 'Book Tradestyle')
	SET @comp_PRCorrTradestyle = dbo.ufn_GetTransactionDetailOldValue(@CompanyID, @CreatedBy, @Explanation, @EntityName, 'Correspondence Tradestyle')
	SET @comp_PRTradestyle1 = dbo.ufn_GetTransactionDetailOldValue(@CompanyID, @CreatedBy, @Explanation, @EntityName, 'Tradestyle 1')
	SET @comp_PROnlineOnly = dbo.ufn_GetTransactionDetailOldValue(@CompanyID, @CreatedBy, @Explanation, @EntityName, 'Online Only')
	SET @CityStateCountry = dbo.ufn_GetTransactionDetailOldValue(@CompanyID, @CreatedBy, @Explanation, @EntityName, 'Listing City')
	SELECT @CityID = prci_CityID FROM vPRLocation WHERE CityStateCountryShort = @CityStateCountry

	SELECT comp_CompanyID, comp_Name, comp_PRListingCityID, comp_PRListingStatus, comp_PRBookTradestyle, comp_PRCorrTradestyle, comp_PRTradestyle1, comp_PROnlineOnly,
	       comp_PRLocalSource, comp_UpdatedBy, comp_UpdatedDate
	  FROM Company WITH (NOLOCK)
	WHERE comp_CompanyID = @CompanyID

	UPDATE Company
	   SET comp_PRListingStatus = ISNULL(@comp_PRListingStatus, 'N3'),
	       comp_Name = ISNULL(@comp_Name, comp_Name),
		   comp_PRBookTradestyle = ISNULL(@comp_PRBookTradestyle, ISNULL(@comp_Name, comp_Name)),
		   comp_PRCorrTradestyle = ISNULL(@comp_PRCorrTradestyle, ISNULL(@comp_Name, comp_Name)),
		   comp_PRTradestyle1 = ISNULL(@comp_PRTradestyle1, ISNULL(@comp_Name, comp_Name)),
		   comp_PRListingCityID = @CityID,
		   comp_PROnlineOnly = @comp_PROnlineOnly,
		   comp_PRLocalSource = NULL,
		   comp_UpdatedBy = @UserID,
		   comp_UpdatedDate = @Start
     WHERE comp_CompanyID = @CompanyID

	DELETE FROM PRLocalSource WHERE prls_CompanyID = @CompanyID

	SELECT comp_CompanyID, comp_Name, comp_PRListingCityID, comp_PRListingStatus, comp_PRBookTradestyle, comp_PRCorrTradestyle, comp_PRTradestyle1, comp_PROnlineOnly,
	       comp_PRLocalSource, comp_UpdatedBy, comp_UpdatedDate
	  FROM Company  WITH (NOLOCK)
	WHERE comp_CompanyID = @CompanyID

	
	--
	--  Address
	--
	SET @EntityName = 'Address'

	SELECT *
      FROM vPRAddress
	 WHERE adli_CompanyID = @CompanyID

	SELECT @Count = COUNT(1)
	  FROM PRTransaction 
	       INNER JOIN PRTransactionDetail ON prtx_TransactionID = prtd_TransactionID
	WHERE prtx_CompanyID=@CompanyID
	  AND prtx_CreatedBy = @CreatedBy
	  AND prtx_Explanation LIKE @Explanation
	  AND prtd_EntityName = @EntityName
	  AND prtd_ColumnName = 'Type'
	  AND prtd_Action = 'Delete'

	IF (@Count = 1) BEGIN

		
		DECLARE @adli_Type varchar(40), @addr_Address1 varchar(200), @addr_Address2 varchar(200), @addr_Address3 varchar(200),
	        @Zip varchar(200), @County varchar(200), @Publish nchar(1)

		SET @adli_Type = dbo.ufn_GetTransactionDetailOldValue(@CompanyID, @CreatedBy, @Explanation, @EntityName, 'Type')
		SET @adli_Type = dbo.ufn_GetCustomCaptionCode('adli_TypeCompany', @adli_Type)
	
		SET @addr_Address1 = dbo.ufn_GetTransactionDetailOldValue(@CompanyID, @CreatedBy, @Explanation, @EntityName, 'Address Line 1')
		SET @addr_Address2 = dbo.ufn_GetTransactionDetailOldValue(@CompanyID, @CreatedBy, @Explanation, @EntityName, 'Address Line 2')
		SET @addr_Address3 = dbo.ufn_GetTransactionDetailOldValue(@CompanyID, @CreatedBy, @Explanation, @EntityName, 'Address Line 31')
		SET @CityStateCountry = dbo.ufn_GetTransactionDetailOldValue(@CompanyID, @CreatedBy, @Explanation, @EntityName, 'City/State/Country')
		SET @Zip = dbo.ufn_GetTransactionDetailOldValue(@CompanyID, @CreatedBy, @Explanation, @EntityName, 'Zip Code')
		SET @County = dbo.ufn_GetTransactionDetailOldValue(@CompanyID, @CreatedBy, @Explanation, @EntityName, 'County')
		
		SELECT @CityID = prci_CityID FROM vPRLocation WHERE CityStateCountryShort = @CityStateCountry

		EXEC usp_GetNextId 'Address', @RecordID output
		INSERT INTO Address (Addr_AddressId, Addr_Address1, Addr_Address2, Addr_Address3, Addr_PostCode, addr_PRCityId, addr_PRCounty, addr_PRPublish, Addr_CreatedBy, Addr_CreatedDate, Addr_UpdatedBy, Addr_UpdatedDate, Addr_TimeStamp) 
                     VALUES (@RecordID, @addr_Address1, @addr_Address2, @addr_Address3, @Zip, @CityID, @County, @Publish, @UserID, @Start, @UserID, @Start, @Start)

		EXEC usp_GetNextId 'Address_Link', @LinkRecordID output
		INSERT INTO Address_Link (AdLi_AddressLinkId, AdLi_AddressId, AdLi_CompanyID, AdLi_Type, adli_PRDefaultTax, adli_PRDefaultMailing, adLi_CreatedBy, AdLi_CreatedDate, AdLi_UpdatedBy, AdLi_UpdatedDate, AdLi_TimeStamp) 
                          VALUES (@LinkRecordID, @RecordID, @CompanyID, @adli_Type, 'Y', 'Y', @UserID, @Start, @UserID, @Start, @Start)

		
	END


	DELETE FROM Address WHERE addr_AddressId IN (SELECT adli_AddressID FROM Address_Link WHERE adli_CompanyID=@CompanyID) AND addr_CreatedDate < @Start
	DELETE FROM Address_Link WHERE adli_CompanyID=@CompanyID AND adli_CreatedDate < @Start;

	SELECT *
   	  FROM vPRAddress
	 WHERE adli_CompanyID = @CompanyID


	--
	-- Phone
	--
	SET @EntityName = 'Phone'

	SELECT *
      FROM vPRCompanyPhone
	 WHERE plink_RecordID = @CompanyID

	DECLARE @Index int, @PhoneValue varchar(200)
	DECLARE @tblWork table (
		ndx int identity(1, 1),
		PhoneValue varchar(200)
	)

	INSERT INTO @tblWork (PhoneValue)
	SELECT prtd_OldValue
	  FROM PRTransaction 
	       INNER JOIN PRTransactionDetail ON prtx_TransactionID = prtd_TransactionID
	WHERE prtx_CompanyID=@CompanyID
	  AND prtx_CreatedBy = @CreatedBy
	  AND prtx_Explanation LIKE @Explanation
	  AND prtd_EntityName = @EntityName
	  AND prtd_Action = 'Delete'

	SELECT @Count = COUNT(1) FROM @tblWork
	SET @Index = 0

	WHILE (@Index < @Count) BEGIN

		SET @Index = @Index + 1

		SELECT @PhoneValue = PhoneValue
		  FROM @tblWork
		 WHERE ndx = @Index

		DECLARE @tblWorkValues table (
			ndx int,
			Value varchar(200)
		)

		INSERT INTO @tblWorkValues SELECT * FROM dbo.Tokenize(@PhoneValue, ',');

		DECLARE @plink_Type varchar(40), @phon_CountryCode varchar(40), @phon_AreaCode varchar(40), @phon_Number varchar(40),
	        @phon_Extension varchar(40), @phon_Description varchar(200), @phon_PRPreferredInternal nchar(1), @phon_Publish nchar(1), @phon_PRPreferredPublish nchar(1)

		SELECT @plink_Type = value FROM @tblWorkValues WHERE ndx = 0;
		SELECT @phon_CountryCode = value FROM @tblWorkValues WHERE ndx = 1;
		SELECT @phon_AreaCode = value FROM @tblWorkValues WHERE ndx = 2;
		SELECT @phon_Number = value FROM @tblWorkValues WHERE ndx = 3;
		SELECT @phon_Extension = value FROM @tblWorkValues WHERE ndx = 4;
		SELECT @phon_Description = value FROM @tblWorkValues WHERE ndx = 5;
		SELECT @phon_PRPreferredInternal = value FROM @tblWorkValues WHERE ndx = 6;
		SELECT @phon_Publish = value FROM @tblWorkValues WHERE ndx = 7;
		SELECT @phon_PRPreferredPublish = value FROM @tblWorkValues WHERE ndx = 8;

		SET @plink_Type = dbo.ufn_GetCustomCaptionCode('Phon_TypeCompany', @plink_Type)
	
		EXEC usp_GetNextId 'Phone', @RecordID output
		INSERT INTO Phone (phon_PhoneID, phon_PRDescription, Phon_AreaCode, Phon_Number, Phon_CountryCode, phon_PRPublish, phon_PRPreferredPublished, phon_PRPreferredInternal, Phon_CreatedBy, Phon_CreatedDate, Phon_UpdatedBy, Phon_UpdatedDate, Phon_Timestamp) 
			VALUES (@RecordID, @phon_Description, @phon_AreaCode, @phon_Number, @phon_CountryCode, @phon_Publish, @phon_PRPreferredPublish, @phon_PRPreferredInternal, @UserID, @Start, @UserID, @Start, @Start)
		
		EXEC usp_GetNextId 'PhoneLink', @LinkRecordID output
        INSERT INTO PhoneLink (plink_LinkID, plink_EntityID, plink_RecordID, plink_Type, plink_PhoneID, plink_CreatedBy, plink_CreatedDate, plink_UpdatedBy, plink_UpdatedDate, plink_Timestamp)
          VALUES (@LinkRecordID, 5, @CompanyID, @plink_Type, @RecordID, @UserID, @Start, @UserID, @Start, @Start)

		
	END

	DECLARE @Tmp table (ID int);
    INSERT INTO @Tmp SELECT plink_PhoneID FROM PhoneLink WHERE plink_RecordID = @CompanyID AND pLink_EntityId = 5 AND plink_CreatedDate < @Start;
    DELETE FROM PhoneLink WHERE plink_phoneID IN (SELECT ID FROM @Tmp);
    DELETE FROM Phone WHERE phon_PhoneID IN (SELECT ID FROM @Tmp);


	SELECT *
      FROM vPRCompanyPhone
	 WHERE plink_RecordID = @CompanyID




	--
	-- Classification
	--
	SET @EntityName = 'Company Classification'

	SELECT *
      FROM PRCompanyClassification
	 WHERE prc2_CompanyId = @CompanyID

	DECLARE @ClassificationID int
	DECLARE @Classification varchar(200)
	DECLARE @tblClassification table (
		ndx int identity(1, 1),
		Classification varchar(200)
	)

	INSERT INTO @tblClassification (Classification)
	SELECT prtd_OldValue
	  FROM PRTransaction 
	       INNER JOIN PRTransactionDetail ON prtx_TransactionID = prtd_TransactionID
	WHERE prtx_CompanyID=@CompanyID
	  AND prtx_CreatedBy = @CreatedBy
	  AND prtx_Explanation LIKE @Explanation
	  AND prtd_EntityName = @EntityName
	  AND prtd_Action = 'Delete'

	SELECT @Count = COUNT(1) FROM @tblClassification
	SET @Index = 0

	WHILE (@Index < @Count) BEGIN

		SET @Index = @Index + 1

		SELECT @Classification = Classification
		  FROM @tblClassification
		 WHERE ndx = @Index

		 SELECT @ClassificationID = prcl_ClassificationID FROM PRClassification WHERE prcl_Name = @Classification;

		 EXEC usp_GetNextId 'PRCompanyClassification', @RecordID output
		 INSERT INTO PRCompanyClassification (prc2_CompanyClassificationId, prc2_CompanyId, prc2_ClassificationId, prc2_CreatedBy, prc2_CreatedDate, prc2_UpdatedBy, prc2_UpdatedDate, prc2_Timestamp) 
            VALUES (@RecordID, @CompanyId, @ClassificationId, @UserID, @Start, @UserID, @Start, @Start)
	END

	DELETE FROM PRCompanyClassification WHERE prc2_CompanyId = @CompanyId AND prc2_CreatedDate < @Start;

	SELECT *
      FROM PRCompanyClassification
	 WHERE prc2_CompanyId = @CompanyID



	--
	-- Brand
	--
	SET @EntityName = 'Company Brand'

	SELECT *
      FROM PRCompanyBrand
	 WHERE prc3_CompanyId = @CompanyID

	DECLARE @Brand varchar(200)
	DECLARE @tblBrand table (
		ndx int identity(1, 1),
		Brand varchar(200)
	)

	INSERT INTO @tblBrand (Brand)
	SELECT prtd_OldValue
	  FROM PRTransaction 
	       INNER JOIN PRTransactionDetail ON prtx_TransactionID = prtd_TransactionID
	WHERE prtx_CompanyID=@CompanyID
	  AND prtx_CreatedBy = @CreatedBy
	  AND prtx_Explanation LIKE @Explanation
	  AND prtd_EntityName = @EntityName
	  AND prtd_Action = 'Delete'

	SELECT @Count = COUNT(1) FROM @tblBrand
	SET @Index = 0

	WHILE (@Index < @Count) BEGIN

		SET @Index = @Index + 1

		SELECT @Brand = Brand
		  FROM @tblBrand
		 WHERE ndx = @Index


		 EXEC usp_GetNextId 'PRCompanyBrand', @RecordID output
		 INSERT INTO PRCompanyBrand (prc3_CompanyBrandId, prc3_CompanyId, prc3_Brand, prc3_CreatedBy, prc3_CreatedDate, prc3_UpdatedBy, prc3_UpdatedDate, prc3_Timestamp) 
            VALUES (@RecordID, @CompanyId, @Brand, @UserID, @Start, @UserID, @Start, @Start)
	END

	SELECT *
      FROM PRCompanyBrand
	 WHERE prc3_CompanyId = @CompanyID


	--
	-- Rating
	--
	SET @EntityName = 'Rating'
	DECLARE @HadRating char(1)
	SET @HadRating = dbo.ufn_GetTransactionDetailOldValue(@CompanyID, @CreatedBy, @Explanation, @EntityName, 'Current')
	IF (@HadRating = 'Y') BEGIN

		SELECT TOP 1 * FROM vPRCompanyRating WHERE prra_CompanyID = @CompanyID ORDER BY prra_RatingID DESC;

		DECLARE @RatingID int
		SELECT @RatingID = MAX(prra_RatingID) FROM PRRating WHERE prra_CompanyID = @CompanyID
		UPDATE PRRating 
		   SET prra_Current = 'Y',
		       prra_UpdatedBy = @UserID,
			   prra_UpdatedDate = @Start
		 WHERE prra_RatingID = @RatingID

		SELECT TOP 1 * FROM vPRCompanyRating WHERE prra_CompanyID = @CompanyID ORDER BY prra_RatingID DESC;
	END


	UPDATE PRTransaction SET prtx_Status = 'C' WHERE prtx_Status = 'O' AND prtx_CompanyID = @CompanyID -- prtx_TransactionId = @TrxID


	--
	-- Person History
	--
	SET @EntityName = 'History'

	SELECT * FROM vPRPersonnelListing WHERE peli_CompanyID=@CompanyID AND peli_PRStatus = '1'

	DECLARE @PersonTrxID int
	DECLARE @PersonTrxExplanation varchar(100) = 'Reversing Local Source Match.'
	DECLARE @Person_LinkID int
	DECLARE @PersonID int, @Status varchar(40)
	DECLARE @tblPerson table (
		ndx int identity(1, 1),
		PersonID int,
		NewStatus varchar(40)
	)

	INSERT INTO @tblPerson (PersonID, NewStatus)
    SELECT prtx_PersonID, '1'
 	 FROM PRTransaction 
 	      INNER JOIN PRTransactionDetail ON prtx_TransactionID = prtd_TransactionID
 	WHERE prtx_Explanation LIKE 'Person marked NLC because not found in Local Source import.%'
	  AND prtd_EntityName = @EntityName
	  AND prtd_Action = 'Update'
	  AND prtd_NewValue = 'No Longer Connected'
      AND prtd_ColumnName LIKE 'BB #' + CAST(@CompanyID as varchar(10)) + '%'

	INSERT INTO @tblPerson (PersonID, NewStatus)
    SELECT peli_PersonID, '3' FROM vPRPersonnelListing WHERE peli_CompanyID=@CompanyID AND peli_PRStatus = '1'

	SELECT @Count = COUNT(1) FROM @tblPerson
	SET @Index = 0
	WHILE (@Index < @Count) BEGIN

		SET @Index = @Index + 1

		SELECT @PersonID = PersonID,
		       @Status = NewStatus
		  FROM @tblPerson
		 WHERE ndx = @Index


		SELECT @Person_LinkID = MAX(peli_PersonLinkID) FROM Person_Link WHERE peli_PersonID = @PersonID AND peli_CompanyID = @CompanyID;

		EXEC @PersonTrxID = usp_CreateTransaction 
	  		      @UserId = @UserID,
				  @prtx_PersonID = @PersonID,
				  @prtx_Explanation = @TransExplanation
		 
		UPDATE Person_Link 
           SET peli_PRStatus = @Status, 
               peli_UpdatedBy=@UserID, 
               peli_UpdatedDate=@Start, 
               peli_Timestamp=@Start   
         WHERE peli_PersonLinkID = @Person_LinkID

		UPDATE PRTransaction SET prtx_Status = 'C' WHERE prtx_Status = 'O' AND prtx_PersonID = @PersonID
	END

	--SELECT * FROM vPRPersonnelListing WHERE peli_CompanyID=@CompanyID AND peli_PRStatus = '1'
	


	SELECT prtx_TransactionID,
	       prtx_CompanyID,
		   prtx_CreatedDate,
		   prtd_EntityName,
		   prtd_ColumnName,
		   prtd_Action,
		   prtd_OldValue,
		   prtd_NewValue
	 FROM PRTransaction 
	      INNER JOIN PRTransactionDetail ON prtx_TransactionID = prtd_TransactionID
	WHERE prtx_CompanyID=@CompanyID
	 AND prtx_CreatedBy = 1
	 AND prtx_Explanation LIKE 'Company updated from Local Source import.%'


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

PRINT ''
PRINT 'Execution End: ' + CONVERT(VARCHAR(20), GETDATE(), 100)
PRINT 'Execution Time: ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE())) + ' ms'