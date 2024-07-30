
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_PersonAdvancedSearch]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop Function [dbo].[ufn_PersonAdvancedSearch]
GO

CREATE FUNCTION [dbo].[ufn_PersonAdvancedSearch]( 
	    @FirstName varchar(30) = NULL, 
        @LastName varchar(40) = NULL,
        @MaidenName varchar(20) = NULL,
        @PhoneAreaCode varchar(20) = NULL, 
        @PhoneNumber varchar(34) = NULL,
        @CityID int = NULL,
        @StateID int = NULL,
		@Unconfirmed nchar(1) = NULL,
        @EmailAddress varchar(255) = NULL,
		@IndustryType varchar(10) = NULL,
		@Nickname varchar(40) = NULL,
		@Deceased nchar(1) = NULL,
		@LocalSource nchar(1) = NULL,
		@MiddleName varchar(30) = NULL
)
RETURNS @tblResults TABLE (
	pers_PersonID int,
	pers_FullName varchar(500),
	pers_LastName varchar(100),
	pers_FirstName varchar(100),
	pers_MiddleName varchar(100),
	pers_EmailAddress varchar(255),
	comp_CompanyID int,
	comp_Name varchar(500),
	CityStateCountryShort varchar(500),
    comp_PRIndustryType varchar(40),
	pers_PRNotes varchar(max),
	peli_PRStatus varchar(40)
) AS 
BEGIN
	DECLARE @IsFirstQuery bit
	DECLARE @ResultCount int
	DECLARE @Start datetime

	DECLARE @SearchResults table (
		PersonID int PRIMARY KEY
	)

	SET @IsFirstQuery = 1;
	SET @Start = GETDATE()

	IF ((@FirstName IS NOT NULL) OR (@LastName IS NOT NULL) OR (@MiddleName IS NOT NULL) OR (@MaidenName IS NOT NULL) OR (@Nickname IS NOT NULL) 
	    OR (@LocalSource IS NOT NULL)
		OR (@Unconfirmed IS NOT NULL))  BEGIN

		IF (@FirstName IS NOT NULL) BEGIN
			SET @FirstName = dbo.ufn_GetLowerAlpha(@FirstName) + '%'
		END

		IF (@LastName IS NOT NULL) BEGIN
			SET @LastName = dbo.ufn_GetLowerAlpha(@LastName) + '%'
		END
		
		IF (@MiddleName IS NOT NULL) BEGIN
			SET @MiddleName = dbo.ufn_GetLowerAlpha(@MiddleName) + '%'
		END

		IF (@MaidenName IS NOT NULL) BEGIN
			SET @MaidenName = @MaidenName + '%'
		END

		IF (@Nickname IS NOT NULL) BEGIN
			SET @Nickname = @Nickname + '%'
		END

		INSERT INTO @SearchResults 
		SELECT DISTINCT pers_PersonID
		  FROM Person WITH (NOLOCK)
		 WHERE pers_FirstNameAlphaOnly LIKE CASE WHEN @FirstName IS NULL THEN pers_FirstNameAlphaOnly ELSE @FirstName END
		   AND pers_LastNameAlphaOnly LIKE CASE WHEN @LastName IS NULL THEN pers_LastNameAlphaOnly ELSE @LastName END
		   AND ISNULL(pers_MiddleName, '') LIKE CASE WHEN @MiddleName IS NULL THEN ISNULL(pers_MiddleName, '') ELSE @MiddleName END
		   AND ISNULL(pers_PRMaidenName, '') LIKE CASE WHEN @MaidenName IS NULL THEN ISNULL(pers_PRMaidenName, '') ELSE @MaidenName END
		   AND ISNULL(pers_PRNickname1, '') LIKE CASE WHEN @Nickname IS NULL THEN ISNULL(pers_PRNickname1, '') ELSE @Nickname END
		   AND ISNULL(pers_PRLocalSource, 'N') = ISNULL(@LocalSource, ISNULL(pers_PRLocalSource, 'N'))
		   AND ISNULL(pers_PRUnconfirmed, 'N') = ISNULL(@Unconfirmed, ISNULL(pers_PRUnconfirmed, 'N'))
		   AND Pers_Deleted IS NULL;

		SET @IsFirstQuery = 0;

		--PRINT 'Person Name Search Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))
		SET @Start = GETDATE()
	END

	IF (@Deceased IS NOT NULL) BEGIN
		IF (@IsFirstQuery = 0) BEGIN
			--
			-- Use IN clauses for this because not all persons
			-- have a person_link record
			IF (@Deceased = 'Y' ) BEGIN
				DELETE FROM @SearchResults WHERE PersonID NOT IN (SELECT DISTINCT pers_PersonID
					                                            FROM Person_Link WITH (NOLOCK) 
																     INNER JOIN Person WITH (NOLOCK) ON peli_PersonID = pers_PersonID
															   WHERE (ISNULL(peli_PRExitReason, '') = 'D' 
																  	 OR ISNULL(pers_PRDeathDate, '') <> ''));
			END ELSE BEGIN
				DELETE FROM @SearchResults WHERE PersonID IN (SELECT DISTINCT pers_PersonID
					                                            FROM Person_Link WITH (NOLOCK) 
																     INNER JOIN Person WITH (NOLOCK) ON peli_PersonID = pers_PersonID
															   WHERE (ISNULL(peli_PRExitReason, '') = 'D' 
																  	 OR ISNULL(pers_PRDeathDate, '') <> ''));
			END
		END ELSE BEGIN
			IF (@Deceased = 'Y' ) BEGIN
				INSERT INTO @SearchResults	
				SELECT DISTINCT pers_PersonID
					  FROM Person_Link WITH (NOLOCK) 
						   INNER JOIN Person WITH (NOLOCK) ON peli_PersonID = pers_PersonID
					 WHERE (ISNULL(peli_PRExitReason, '') = 'D' 
							OR ISNULL(pers_PRDeathDate, '') <> '')

			END ELSE BEGIN
				INSERT INTO @SearchResults	
				SELECT DISTINCT pers_PersonID
					  FROM Person_Link WITH (NOLOCK) 
						   INNER JOIN Person WITH (NOLOCK) ON peli_PersonID = pers_PersonID
					 WHERE (ISNULL(peli_PRExitReason, '') <> 'D' 
							AND ISNULL(pers_PRDeathDate, '') = '')

			END
			SET @IsFirstQuery = 0;
		END

		--PRINT 'Deceased Search Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))
		SET @Start = GETDATE()
	END

	IF ((@PhoneAreaCode IS NOT NULL) OR (@PhoneNumber IS NOT NULL)) BEGIN
		-- If we already have a set of CompanyIDs, then
		-- we must now remove what doesn't match this next
		-- criteria
		IF (@IsFirstQuery = 0) BEGIN
			DELETE FROM @SearchResults
			 WHERE PersonID NOT IN (
				SELECT DISTINCT plink_RecordID
				  FROM vPRPersonPhone WITH (NOLOCK)
				 WHERE 
					(@PhoneAreaCode IS NULL OR (@PhoneAreaCode IS NOT NULL AND Phon_AreaCode = @PhoneAreaCode))
				   AND (@PhoneNumber IS NULL OR (@PhoneNumber IS NOT NULL AND phon_Number = @PhoneNumber))
				   AND phon_Deleted IS NULL);

		END ELSE BEGIN

			INSERT INTO @SearchResults
			SELECT DISTINCT plink_RecordID
			  FROM vPRPersonPhone WITH (NOLOCK)
			 WHERE 
			 	(@PhoneAreaCode IS NULL OR (@PhoneAreaCode IS NOT NULL AND Phon_AreaCode = @PhoneAreaCode))
				AND (@PhoneNumber IS NULL OR (@PhoneNumber IS NOT NULL AND phon_Number = @PhoneNumber))
			   AND phon_Deleted IS NULL;

			SET @IsFirstQuery = 0;
		END

		--PRINT 'Phone Search Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))
		SET @Start = GETDATE()
	END

	IF (@EmailAddress IS NOT NULL) BEGIN
		SET @EmailAddress = @EmailAddress + '%'

		-- If we already have a set of CompanyIDs, then
		-- we must now remove what doesn't match this next
		-- criteria
		IF (@IsFirstQuery = 0) BEGIN
			DELETE FROM @SearchResults
			 WHERE PersonID NOT IN (
				SELECT DISTINCT elink_RecordID
				  FROM vPersonEmail WITH (NOLOCK)
				 WHERE Emai_EmailAddress LIKE @EmailAddress
				   AND elink_Type = 'E'
				   AND Emai_Deleted IS NULL);

		END ELSE BEGIN

			INSERT INTO @SearchResults
			SELECT DISTINCT elink_RecordID
				  FROM vPersonEmail WITH (NOLOCK)
				 WHERE Emai_EmailAddress LIKE @EmailAddress
				   AND elink_Type = 'E'
				   AND Emai_Deleted IS NULL;

			SET @IsFirstQuery = 0;
		END

		--PRINT 'Phone Search Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))
		SET @Start = GETDATE()
	END

	IF ((@CityID > 0) OR (@StateID > 0)) BEGIN

		-- If we already have a set of CompanyIDs, then
		-- we must now remove what doesn't match this next
		-- criteria
		IF (@IsFirstQuery = 0) BEGIN
			DELETE FROM @SearchResults
			 WHERE PersonID NOT IN (

			    SELECT DISTINCT(peli_PersonID) FROM
				(
                    SELECT DISTINCT peli_PersonID, comp_CompanyID, prci_City
                    FROM Company WITH (NOLOCK)
                        INNER JOIN PRCity WITH (NOLOCK) on comp_PRListingCityID = prci_CityID
                        INNER JOIN Person_Link WITH (NOLOCK) ON comp_CompanyID = peli_CompanyID
                    WHERE prci_CityID = CASE WHEN @CityID IS NULL THEN prci_CityID ELSE @CityID END
                        AND prci_StateID = CASE WHEN @StateID IS NULL THEN prci_StateID ELSE @StateID END
                        AND peli_PRStatus = 1
				) P1
        )
    	END ELSE BEGIN
			INSERT INTO @SearchResults

			    SELECT DISTINCT(peli_PersonID) FROM
				(
                    SELECT DISTINCT peli_PersonID, comp_CompanyID, prci_City
                    FROM Company WITH (NOLOCK)
                        INNER JOIN PRCity WITH (NOLOCK) on comp_PRListingCityID = prci_CityID
                        INNER JOIN Person_Link WITH (NOLOCK) ON comp_CompanyID = peli_CompanyID
                    WHERE prci_CityID = CASE WHEN @CityID IS NULL THEN prci_CityID ELSE @CityID END
                        AND prci_StateID = CASE WHEN @StateID IS NULL THEN prci_StateID ELSE @StateID END
                        AND peli_PRStatus = 1
				) P1

			SET @IsFirstQuery = 0;
		END

		--PRINT 'City/State Search Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))
		SET @Start = GETDATE()
	END

	IF (@IsFirstQuery = 1) BEGIN
		INSERT INTO @SearchResults
		SELECT pers_PersonID 
		  FROM Person;
	END	  

	-- Build our intial resultset
	INSERT INTO @tblResults
	SELECT DISTINCT pers_PersonID, 
		   dbo.ufn_FormatPerson2(Pers_FirstName, Pers_LastName, Pers_MiddleName, Pers_PRNickname1, Pers_Suffix, 1)  AS Pers_FullName, 
		   pers_LastName,
		   pers_FirstName,
		   pers_MiddleName,
		   emai_EmailAddress,
		   comp_CompanyID,
		   comp_Name,
		   CityStateCountryShort,
		   comp_PRIndustryType,
		   CAST(pers_PRNotes AS varchar(max)),
		   peli_PRStatus
	  FROM Person WITH (NOLOCK)
	       INNER JOIN @SearchResults on pers_PersonID = PersonID
		   LEFT OUTER JOIN Person_Link WITH (NOLOCK) ON pers_PersonID = peli_PersonID
           --LEFT OUTER JOIN Custom_Captions ON peli_PRStatus = capt_code AND capt_family = 'peli_PRStatus'
		   LEFT OUTER JOIN Company WITH (NOLOCK) ON peli_CompanyID = comp_CompanyID
		                                        AND comp_PRIndustryType = ISNULL(@IndustryType, comp_PRIndustryType)
		   LEFT OUTER JOIN vPRLocation ON comp_PRLIstingCityID = prci_CityID
		   LEFT OUTER JOIN vPersonEmail ON  pers_PersonID = elink_RecordID
		                                         AND peli_CompanyID = emai_CompanyID
												 AND elink_Type = 'E'
												 AND emai_PRPreferredInternal = 'Y';
	   
	IF (@IndustryType IS NOT NULL) BEGIN
		DELETE FROM @tblResults WHERE comp_PRIndustryType IS NULL OR comp_PRIndustryType <> @IndustryType
	END
	
	RETURN
END
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_CompanyAdvancedSearch]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop Function [dbo].[ufn_CompanyAdvancedSearch]
GO

CREATE FUNCTION [dbo].[ufn_CompanyAdvancedSearch]( 
	    @CompanyName varchar(104) = NULL, 
        @CompanyType varchar(40) = NULL,
        @CompanyListingStatus varchar(40) = NULL,
        @PhoneAreaCode varchar(20) = NULL, 
        @PhoneNumber varchar(34) = NULL,
        @CityID int = NULL,
        @StateID int = NULL,
        @Email varchar(255) = NULL,
        @DRCLicenseNumber varchar(5) = NULL,
        @Brand varchar(34) = NULL,
        @Unconfirmed nchar(1) = NULL,
        @IndustryType varchar(40) = NULL,
        @BBID int = null,
        @MasterInvoiceNo varchar(40) = null,
		@LegalNameOnly nchar(1) = NULL,
		@LocalSource nchar(1) = NULL,
		@Address1 nvarchar(40) = NULL
)
RETURNS @tblResults TABLE (
    comp_CompanyID int,
    comp_PRHQId int,
    comp_CompanyIDDisplay varchar(10),
    comp_name varchar(104),
    comp_PRIndustryType varchar(40),
    comp_PRServicesThroughCompanyID int,
    comp_PRType varchar(40),
    comp_PRListingStatus varchar(40),
    prci_CityID int,
    prst_StateID int,
	prcn_CountryId int,
	comp_PRListingCityID int,
	comp_ListingCityStateCountry varchar(97),
	comp_StatusDisplay varchar(100),
	comp_TypeDisplay varchar(40),
	prse_ServiceCode varchar(40)
) AS 
BEGIN

	DECLARE @IsFirstQuery bit
	DECLARE @Start datetime

	DECLARE @SearchResults table (
		CompanyID int PRIMARY KEY
	)

	SET @IsFirstQuery = 1;
	SET @Start = GETDATE()

	IF (@BBID IS NOT NULL) BEGIN
		INSERT INTO @SearchResults SELECT @BBID;
        SET @IsFirstQuery = 0;
	END

	IF (@CompanyName IS NOT NULL) BEGIN
		DECLARE @LowerAlpha  varchar(104)
		SET @LowerAlpha = dbo.ufn_GetLowerAlphaWC(@CompanyName) + '%'

		DECLARE @PreparedName varchar(104)
		SET @PreparedName = dbo.ufn_GetLowerAlphaWC(dbo.ufn_PrepareCompanyName(@CompanyName)) + '%'
		SET @CompanyName = @CompanyName + '%'

		IF (@LegalNameOnly = 'Y') BEGIN
			INSERT INTO @SearchResults
			SELECT DISTINCT prcse_CompanyId
			  FROM PRCompanySearch WITH (NOLOCK)
			 WHERE prcse_LegalNameMatch LIKE @PreparedName;
		END ELSE BEGIN

			/*
			-- Only 75 companies have a book tradestyle that is not the
			-- same as the company name
			INSERT INTO @SearchResults 
			SELECT comp_CompanyID
			  FROM Company
			 WHERE dbo.ufn_GetLowerAlpha(comp_PRBookTradestyle) LIKE @LowerAlpha
			 */

			INSERT INTO @SearchResults
			SELECT DISTINCT prcse_CompanyId
			  FROM PRCompanySearch WITH (NOLOCK)
			 WHERE (prcse_NameMatch LIKE @PreparedName
					OR prcse_LegalNameMatch LIKE @PreparedName
					OR prcse_CorrTradestyleMatch LIKE @PreparedName				
					OR prcse_OriginalNameMatch LIKE @PreparedName
				    OR prcse_OldName1Match LIKE @PreparedName
				    OR prcse_OldName2Match LIKE @PreparedName
				    OR prcse_OldName3Match LIKE @PreparedName)
			   AND prcse_CompanyId NOT IN (SELECT CompanyID FROM @SearchResults);

			INSERT INTO @SearchResults
			SELECT DISTINCT pral_CompanyID
			  FROM PRCompanyAlias WITH (NOLOCK)
			 WHERE pral_AliasMatch LIKE @PreparedName
			   AND pral_CompanyID NOT IN (SELECT CompanyID FROM @SearchResults);

			INSERT INTO @SearchResults
			SELECT DISTINCT prpa_CompanyID
			  FROM PRPACALicense WITH (NOLOCK)
			 WHERE prpa_CompanyNameMatch LIKE @PreparedName
			   AND prpa_CompanyID NOT IN (SELECT CompanyID FROM @SearchResults);
		END

		SET @IsFirstQuery = 0;

		--PRINT 'CompanyName Search Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))
		SET @Start = GETDATE()
	END

	IF ((@CompanyType IS NOT NULL) OR (@CompanyListingStatus IS NOT NULL)) BEGIN
		-- If we already have a set of CompanyIDs, then
		-- we must now remove what doesn't match this next
		-- criteria
		IF (@IsFirstQuery = 0) BEGIN
			DELETE FROM @SearchResults
			 WHERE CompanyID NOT IN 
					(SELECT comp_CompanyID
					   FROM Company WITH (NOLOCK)
					  WHERE comp_PRType = CASE WHEN @CompanyType IS NULL THEN comp_PRType ELSE @CompanyType END
						AND comp_PRListingStatus = CASE WHEN @CompanyListingStatus IS NULL THEN comp_PRListingStatus ELSE @CompanyListingStatus END);

		END ELSE BEGIN
			INSERT INTO @SearchResults
			SELECT comp_CompanyID
			  FROM Company WITH (NOLOCK)
			 WHERE comp_PRType = CASE WHEN @CompanyType IS NULL THEN comp_PRType ELSE @CompanyType END
			   AND comp_PRListingStatus = CASE WHEN @CompanyListingStatus IS NULL THEN comp_PRListingStatus ELSE @CompanyListingStatus END;

			SET @IsFirstQuery = 0;
		END

		--PRINT 'Type/LisitingStatus Search Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))
		SET @Start = GETDATE()
	END

	IF (@Unconfirmed IS NOT NULL) BEGIN
		IF (@IsFirstQuery = 0) BEGIN
			IF (@Unconfirmed = 'Y' ) 
				DELETE FROM @SearchResults WHERE CompanyID NOT IN (SELECT DISTINCT comp_CompanyID FROM Company WHERE comp_PRUnconfirmed = 'Y' AND comp_Deleted IS NULL);
			IF (@Unconfirmed = 'N' ) 
				DELETE FROM @SearchResults WHERE CompanyID NOT IN (SELECT DISTINCT comp_CompanyID FROM Company WHERE comp_PRUnconfirmed IS NULL AND comp_Deleted IS NULL);
		END ELSE BEGIN
			IF (@Unconfirmed = 'Y' ) 
				INSERT INTO @SearchResults	SELECT DISTINCT comp_CompanyID FROM Company WHERE comp_PRUnconfirmed = 'Y' and comp_Deleted IS NULL;
			IF (@Unconfirmed = 'N' ) 
				INSERT INTO @SearchResults	SELECT DISTINCT comp_CompanyID FROM Company WHERE comp_PRUnconfirmed IS NULL and comp_Deleted IS NULL;

			SET @IsFirstQuery = 0;
		END

		--PRINT 'Unconfirmed Search Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))
		SET @Start = GETDATE()
	END

	IF (@LocalSource IS NOT NULL) BEGIN
		IF (@IsFirstQuery = 0) BEGIN
			IF (@LocalSource = 'Y' ) 
				DELETE FROM @SearchResults WHERE CompanyID NOT IN (SELECT DISTINCT comp_CompanyID FROM Company WHERE comp_PRLocalSource = 'Y' AND comp_Deleted IS NULL);
			IF (@LocalSource = 'N' ) 
				DELETE FROM @SearchResults WHERE CompanyID NOT IN (SELECT DISTINCT comp_CompanyID FROM Company WHERE comp_PRLocalSource IS NULL AND comp_Deleted IS NULL);
		END ELSE BEGIN
			IF (@LocalSource = 'Y' ) 
				INSERT INTO @SearchResults	SELECT DISTINCT comp_CompanyID FROM Company WHERE comp_PRLocalSource = 'Y' and comp_Deleted IS NULL;
			IF (@LocalSource = 'N' ) 
				INSERT INTO @SearchResults	SELECT DISTINCT comp_CompanyID FROM Company WHERE comp_PRLocalSource IS NULL and comp_Deleted IS NULL;
			SET @IsFirstQuery = 0;
		END

		--PRINT 'Unconfirmed Search Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))
		SET @Start = GETDATE()
	END

	IF ((@PhoneAreaCode IS NOT NULL) OR (@PhoneNumber IS NOT NULL)) BEGIN
		-- If we already have a set of CompanyIDs, then
		-- we must now remove what doesn't match this next
		-- criteria
		IF (@IsFirstQuery = 0) BEGIN
			DELETE FROM @SearchResults
			 WHERE CompanyID NOT IN (
				SELECT DISTINCT plink_RecordID
				  FROM vPRCompanyPhone WITH (NOLOCK)
				 WHERE 
					(@PhoneAreaCode IS NULL OR (@PhoneAreaCode IS NOT NULL AND Phon_AreaCode = @PhoneAreaCode))
				   AND (@PhoneNumber IS NULL OR (@PhoneNumber IS NOT NULL AND phon_Number = @PhoneNumber))
				   AND phon_Deleted IS NULL);

		END ELSE BEGIN

			INSERT INTO @SearchResults
			SELECT DISTINCT plink_RecordID
			  FROM vPRCompanyPhone WITH (NOLOCK)
			 WHERE 
				(@PhoneAreaCode IS NULL OR (@PhoneAreaCode IS NOT NULL AND Phon_AreaCode = @PhoneAreaCode))
				AND (@PhoneNumber IS NULL OR (@PhoneNumber IS NOT NULL AND phon_Number = @PhoneNumber))
			   AND phon_Deleted IS NULL;

			SET @IsFirstQuery = 0;
		END

		--PRINT 'Phone Search Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))
		SET @Start = GETDATE()
	END

	IF (@Address1 IS NOT NULL) BEGIN
		IF (@IsFirstQuery = 0) BEGIN
			DELETE FROM @SearchResults WHERE CompanyID NOT IN 
			(
				SELECT DISTINCT Comp_CompanyId FROM Company
					INNER JOIN vPRAddress ON adli_Companyid=comp_companyid AND Addr_address1 LIKE '%' + @Address1 + '%' AND Addr_Deleted IS NULL
			);
		END ELSE BEGIN
			INSERT INTO @SearchResults	
			SELECT DISTINCT Comp_CompanyId FROM Company
				INNER JOIN vPRAddress ON adli_Companyid=comp_companyid AND Addr_address1 LIKE '%' + @Address1 + '%' AND Addr_Deleted IS NULL

			SET @IsFirstQuery = 0;
		END

		--PRINT 'Unconfirmed Search Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))
		SET @Start = GETDATE()
	END

	IF ((@CityID > 0) OR (@StateID > 0)) BEGIN

		-- If we already have a set of CompanyIDs, then
		-- we must now remove what doesn't match this next
		-- criteria
		IF (@IsFirstQuery = 0) BEGIN
			DELETE FROM @SearchResults
			 WHERE CompanyID NOT IN (
				SELECT comp_CompanyID
				  FROM Company WITH (NOLOCK)
					   INNER JOIN PRCity WITH (NOLOCK) on comp_PRListingCityID = prci_CityID
				 WHERE prci_CityID = CASE WHEN @CityID IS NULL THEN prci_CityID ELSE @CityID END
				   AND prci_StateID = CASE WHEN @StateID IS NULL THEN prci_StateID ELSE @StateID END);

		END ELSE BEGIN

			INSERT INTO @SearchResults
			SELECT comp_CompanyID
			  FROM Company WITH (NOLOCK)
				   INNER JOIN PRCity WITH (NOLOCK) on comp_PRListingCityID = prci_CityID
			 WHERE prci_CityID = CASE WHEN @CityID IS NULL THEN prci_CityID ELSE @CityID END
			   AND prci_StateID = CASE WHEN @StateID IS NULL THEN prci_StateID ELSE @StateID END;

			SET @IsFirstQuery = 0;
		END

		--PRINT 'City/State Search Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))
		SET @Start = GETDATE()
	END

	IF (@Email IS NOT NULL) BEGIN
		SET @Email = @Email + '%'
		
		-- If we already have a set of CompanyIDs, then
		-- we must now remove what doesn't match this next
		-- criteria
		IF (@IsFirstQuery = 0) BEGIN
			DELETE FROM @SearchResults
			 WHERE CompanyID NOT IN (
				SELECT DISTINCT elink_RecordID
				  FROM vCompanyEmail WITH (NOLOCK)
				 WHERE emai_EmailAddress LIKE @Email
				   AND elink_Type = 'E'
				   AND emai_Deleted IS NULL);

		END ELSE BEGIN

			INSERT INTO @SearchResults
			SELECT DISTINCT elink_RecordID
			  FROM vCompanyEmail WITH (NOLOCK)
			 WHERE emai_EmailAddress LIKE @Email
			   AND elink_Type = 'E'
			   AND emai_Deleted IS NULL;

			SET @IsFirstQuery = 0;
		END

		--PRINT 'Email Search Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))
		SET @Start = GETDATE()
	END

	IF (@DRCLicenseNumber IS NOT NULL) BEGIN
		-- If we already have a set of CompanyIDs, then
		-- we must now remove what doesn't match this next
		-- criteria
		IF (@IsFirstQuery = 0) BEGIN
			DELETE FROM @SearchResults
			 WHERE CompanyID NOT IN (
				SELECT DISTINCT prdr_CompanyID
			  FROM PRDRCLicense WITH (NOLOCK)
			 WHERE prdr_LicenseNumber LIKE @DRCLicenseNumber
			   AND prdr_Deleted IS NULL);

		END ELSE BEGIN

			INSERT INTO @SearchResults
			SELECT DISTINCT prdr_CompanyID
			  FROM PRDRCLicense WITH (NOLOCK)
			 WHERE prdr_LicenseNumber LIKE @DRCLicenseNumber
			   AND prdr_Deleted IS NULL;

			SET @IsFirstQuery = 0;
		END

		--PRINT 'DRC License Search Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))
		SET @Start = GETDATE()
	END

	IF (@Brand IS NOT NULL) BEGIN
		-- If we already have a set of CompanyIDs, then
		-- we must now remove what doesn't match this next
		-- criteria
		IF (@IsFirstQuery = 0) BEGIN
			DELETE FROM @SearchResults
			 WHERE CompanyID NOT IN (
				SELECT DISTINCT prc3_CompanyID
			  FROM PRCompanyBrand WITH (NOLOCK)
			 WHERE prc3_Brand LIKE @Brand
			   AND prc3_Deleted IS NULL);

		END ELSE BEGIN

			INSERT INTO @SearchResults
			SELECT DISTINCT prc3_CompanyID
			  FROM PRCompanyBrand WITH (NOLOCK)
			 WHERE prc3_Brand LIKE @Brand
			   AND prc3_Deleted IS NULL;

			SET @IsFirstQuery = 0;
		END

		--PRINT 'Brand Search Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))
		SET @Start = GETDATE()
	END
	
	IF (@IndustryType IS NOT NULL) BEGIN
		-- If we already have a set of CompanyIDs, then
		-- we must now remove what doesn't match this next
		-- criteria
		IF (@IsFirstQuery = 0) BEGIN
			DELETE FROM @SearchResults
			 WHERE CompanyID NOT IN 
					(SELECT comp_CompanyID
					   FROM Company WITH (NOLOCK)
					  WHERE comp_PRIndustryType = @IndustryType);

		END ELSE BEGIN
			INSERT INTO @SearchResults
			SELECT comp_CompanyID
			  FROM Company WITH (NOLOCK)
			 WHERE comp_PRIndustryType = @IndustryType;
			SET @IsFirstQuery = 0;
		END

		--PRINT 'Type/LisitingStatus Search Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))
		SET @Start = GETDATE()
	END	
	
	IF (@MasterInvoiceNo IS NOT NULL) BEGIN
	
		SET @MasterInvoiceNo = @MasterInvoiceNo + '%'
	
		-- If we already have a set of CompanyIDs, then
		-- we must now remove what doesn't match this next
		-- criteria
		IF (@IsFirstQuery = 0) BEGIN
			DELETE FROM @SearchResults
			 WHERE CompanyID NOT IN 
					(SELECT DISTINCT CAST(CustomerNo as Int)
                       FROM MAS_PRC.dbo.AR_InvoiceHistoryHeader WITH (NOLOCK)
                      WHERE UDF_MASTER_INVOICE LIKE @MasterInvoiceNo);

		END ELSE BEGIN
			INSERT INTO @SearchResults
			SELECT DISTINCT CAST(CustomerNo as Int)
              FROM MAS_PRC.dbo.AR_InvoiceHistoryHeader WITH (NOLOCK)
             WHERE UDF_MASTER_INVOICE LIKE @MasterInvoiceNo;
			SET @IsFirstQuery = 0;
		END

		--PRINT 'Type/LisitingStatus Search Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))
		SET @Start = GETDATE()	
	END

	-- If we haven't executed our first query, then
    -- all criteria is NULL, so return everything.
	if (@IsFirstQuery = 1) BEGIN
		INSERT INTO @tblResults
		SELECT comp_CompanyID ,
			   comp_PRHQId,
			   comp_CompanyIDDisplay,
			   comp_name,
			   comp_PRIndustryType,
			   comp_PRServicesThroughCompanyID,
			   comp_PRType,
			   comp_PRListingStatus,
			   prci_CityID,
			   prst_StateID,
			   prcn_CountryId,
			   comp_PRListingCityID,
			   comp_ListingCityStateCountry,
			   comp_StatusDisplay,
			   comp_TypeDisplay ,
			   prse_ServiceCode
		  FROM vSearchListCompany2;
	END ELSE BEGIN

		-- Return our results
		INSERT INTO @tblResults
		SELECT comp_CompanyID ,
			   comp_PRHQId,
			   comp_CompanyIDDisplay,
			   comp_name,
			   comp_PRIndustryType,
			   comp_PRServicesThroughCompanyID,
			   comp_PRType,
			   comp_PRListingStatus,
			   prci_CityID,
			   prst_StateID,
			   prcn_CountryId,
			   comp_PRListingCityID,
			   comp_ListingCityStateCountry,
			   comp_StatusDisplay,
			   comp_TypeDisplay,
			   prse_ServiceCode
		  FROM @SearchResults
			   INNER JOIN vSearchListCompany2 on CompanyID = comp_CompanyID
	END

	RETURN
END
GO
