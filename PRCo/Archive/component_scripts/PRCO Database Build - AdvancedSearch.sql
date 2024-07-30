
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
        @StateID int = NULL
)
RETURNS @tblResults TABLE (
	pers_PersonID int PRIMARY KEY,
	pers_FullName varchar(500),
    pers_PRMaidenName varchar(20),
	pers_PRNotes varchar(8000),
    CompanyList varchar(8000)
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

	IF ((@FirstName IS NOT NULL) OR (@LastName IS NOT NULL) OR (@MaidenName IS NOT NULL))  BEGIN

		IF (@FirstName IS NOT NULL) BEGIN
			SET @FirstName = @FirstName + '%'
		END

		IF (@LastName IS NOT NULL) BEGIN
			SET @LastName = @LastName + '%'
		END

		IF (@MaidenName IS NOT NULL) BEGIN
			SET @MaidenName = @MaidenName + '%'
		END

		INSERT INTO @SearchResults 
		SELECT pers_PersonID
		  FROM Person
		 WHERE pers_FirstName LIKE CASE WHEN @FirstName IS NULL THEN pers_FirstName ELSE @FirstName END
		   AND pers_LastName LIKE CASE WHEN @LastName IS NULL THEN pers_LastName ELSE @LastName END
		   AND ISNULL(pers_PRMaidenName, '') LIKE CASE WHEN @MaidenName IS NULL THEN ISNULL(pers_PRMaidenName, '') ELSE @MaidenName END
		   AND Pers_Deleted IS NULL;

		SET @IsFirstQuery = 0;

		--PRINT 'Person Name Search Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))
		SET @Start = GETDATE()
	END



	IF ((@PhoneAreaCode IS NOT NULL) OR (@PhoneNumber IS NOT NULL)) BEGIN

		-- If we already have a set of CompanyIDs, then
		-- we must now remove what doesn't match this next
		-- criteria
		IF (@IsFirstQuery = 0) BEGIN
			DELETE FROM @SearchResults
			 WHERE PersonID NOT IN (
				SELECT DISTINCT phon_PersonID
				  FROM Phone
				 WHERE phon_AreaCode = CASE WHEN @PhoneAreaCode IS NULL THEN phon_AreaCode ELSE @PhoneAreaCode END
				   AND phon_Number = CASE WHEN @PhoneNumber IS NULL THEN phon_Number ELSE @PhoneNumber END
				   AND phon_Deleted IS NULL
				   AND phon_PersonID IS NOT NULL);

		END ELSE BEGIN

			INSERT INTO @SearchResults
			SELECT DISTINCT phon_PersonID
			  FROM Phone
			 WHERE phon_AreaCode = CASE WHEN @PhoneAreaCode IS NULL THEN phon_AreaCode ELSE @PhoneAreaCode END
			   AND phon_Number = CASE WHEN @PhoneNumber IS NULL THEN phon_Number ELSE @PhoneNumber END
			   AND phon_Deleted IS NULL
			   AND phon_PersonID IS NOT NULL;

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
				SELECT adli_PersonID
				  FROM Address_Link
					   INNER JOIN Address on adli_AddressID = addr_AddressID
					   INNER JOIN PRCity on addr_PRCityID = prci_CityID
				 WHERE prci_CityID = CASE WHEN @CityID IS NULL THEN prci_CityID ELSE @CityID END
				   AND prci_StateID = CASE WHEN @StateID IS NULL THEN prci_StateID ELSE @StateID END
				   AND adli_PersonID IS NOT NULL);

		END ELSE BEGIN

			INSERT INTO @SearchResults
			SELECT adli_PersonID
			  FROM Address_Link
				   INNER JOIN Address on adli_AddressID = addr_AddressID
				   INNER JOIN PRCity on addr_PRCityID = prci_CityID
			 WHERE prci_CityID = CASE WHEN @CityID IS NULL THEN prci_CityID ELSE @CityID END
			   AND prci_StateID = CASE WHEN @StateID IS NULL THEN prci_StateID ELSE @StateID END
			   AND adli_PersonID IS NOT NULL;

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
	INSERT INTO @tblResults (pers_PersonID, pers_FullName, pers_PRMaidenName, pers_PRNotes)
	SELECT pers_PersonID, 
		   dbo.ufn_FormatPerson2(Pers_FirstName, Pers_LastName, Pers_MiddleName, Pers_PRNickname1, Pers_Suffix, 1)  AS Pers_FullName, 
		   pers_PRMaidenName, 
		   CAST(pers_PRNotes AS varchar(8000))
	  FROM Person
		   INNER JOIN @SearchResults on pers_PersonID = PersonID;


	--
	--  Now build a list of associated companies
	--
	DECLARE @PersonCount int, @PersonIndex int, @CurrentPersonID int
	DECLARE @CompanyList varchar(8000)

	DECLARE @Companies table (
		PersonID int,
		CompanyName varchar(104))

	-- Build distinct lists of companies and person IDs
	INSERT INTO @Companies (PersonID, CompanyName) 
	SELECT DISTINCT PersonID, comp_Name
	  FROM @SearchResults
		   INNER JOIN Person_Link on PersonID = peli_PersonID
		   INNER JOIN Company on peli_CompanyID = comp_CompanyID
	 WHERE peli_PRStatus IN (1,2);

	-- Yes, we need another person ID table because we need the ndx
    -- to be unique and sequential.
	DECLARE @PersonIDs table (
		ndx int identity(1,1) PRIMARY KEY,
		PersonID int)

	INSERT INTO @PersonIDs (PersonID) SELECT DISTINCT PersonID FROM @SearchResults;
	SET @PersonCount = @@ROWCOUNT

	-- For each company, build a list of locations
	SET @PersonIndex = 1
	WHILE (@PersonIndex <= @PersonCount) BEGIN
		
		SET @CompanyList = NULL;

		-- Get our current Person ID
		SELECT @CurrentPersonID = PersonID
		  FROM @PersonIDs
		 WHERE ndx = @PersonIndex;
		
		-- Build the company name list
		SELECT @CompanyList = COALESCE(@CompanyList + ', ', '') + CompanyName
		  FROM @Companies
		 WHERE PersonID = @CurrentPersonID
		ORDER BY CompanyName;
		
		-- Add it to the search results
		UPDATE @tblResults
		   SET CompanyList = @CompanyList
		 WHERE pers_PersonID = @CurrentPersonID;

		SET @PersonIndex = @PersonIndex + 1
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
        @ServiceID int = NULL,
        @Brand varchar(34) = NULL
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
	comp_StatusDisplay varchar(1),
	comp_TypeDisplay varchar(40)
) AS 
BEGIN

	DECLARE @IsFirstQuery bit
	DECLARE @Start datetime

	DECLARE @SearchResults table (
		CompanyID int PRIMARY KEY
	)

	SET @IsFirstQuery = 1;
	SET @Start = GETDATE()

	IF (@CompanyName IS NOT NULL) BEGIN
		SET @CompanyName = @CompanyName + '%'


		INSERT INTO @SearchResults 
		SELECT comp_CompanyID
		  FROM Company
		 WHERE comp_Name LIKE @CompanyName
			OR comp_PRCorrTradestyle LIKE @CompanyName
			OR comp_PRBookTradestyle LIKE @CompanyName
			OR comp_PRTradestyle1 LIKE @CompanyName
			OR comp_PRTradestyle2 LIKE @CompanyName
			OR comp_PRTradestyle3 LIKE @CompanyName
			OR comp_PRTradestyle4 LIKE @CompanyName
			OR comp_PRLegalName LIKE @CompanyName
			OR comp_PROriginalName LIKE @CompanyName
			OR comp_PROldName1 LIKE @CompanyName
			OR comp_PROldName2 LIKE @CompanyName
			OR comp_PROldName3 LIKE @CompanyName;

		INSERT INTO @SearchResults
		SELECT DISTINCT pral_CompanyID
		  FROM PRCompanyAlias
		 WHERE pral_Alias LIKE @CompanyName
		   AND pral_CompanyID NOT IN (SELECT CompanyID FROM @SearchResults);

		INSERT INTO @SearchResults
		SELECT DISTINCT prpa_CompanyID
		  FROM PRPACALicense
		 WHERE prpa_CompanyName LIKE @CompanyName
		   AND prpa_CompanyID NOT IN (SELECT CompanyID FROM @SearchResults);

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
					   FROM Company
					  WHERE comp_PRType = CASE WHEN @CompanyType IS NULL THEN comp_PRType ELSE @CompanyType END
						AND comp_PRListingStatus = CASE WHEN @CompanyListingStatus IS NULL THEN comp_PRListingStatus ELSE @CompanyListingStatus END);

		END ELSE BEGIN
			INSERT INTO @SearchResults
			SELECT comp_CompanyID
			  FROM Company
			 WHERE comp_PRType = CASE WHEN @CompanyType IS NULL THEN comp_PRType ELSE @CompanyType END
			   AND comp_PRListingStatus = CASE WHEN @CompanyListingStatus IS NULL THEN comp_PRListingStatus ELSE @CompanyListingStatus END;

			SET @IsFirstQuery = 0;
		END

		--PRINT 'Type/LisitingStatus Search Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))
		SET @Start = GETDATE()
	END



	IF ((@PhoneAreaCode IS NOT NULL) OR (@PhoneNumber IS NOT NULL)) BEGIN

		-- If we already have a set of CompanyIDs, then
		-- we must now remove what doesn't match this next
		-- criteria
		IF (@IsFirstQuery = 0) BEGIN
			DELETE FROM @SearchResults
			 WHERE CompanyID NOT IN (
				SELECT DISTINCT phon_CompanyID
				  FROM Phone
				 WHERE phon_AreaCode = CASE WHEN @PhoneAreaCode IS NULL THEN phon_AreaCode ELSE @PhoneAreaCode END
				   AND phon_Number = CASE WHEN @PhoneNumber IS NULL THEN phon_Number ELSE @PhoneNumber END
				   AND phon_Deleted IS NULL
				   AND phon_CompanyID IS NOT NULL);

		END ELSE BEGIN

			INSERT INTO @SearchResults
			SELECT DISTINCT phon_CompanyID
			  FROM Phone
			 WHERE phon_AreaCode = CASE WHEN @PhoneAreaCode IS NULL THEN phon_AreaCode ELSE @PhoneAreaCode END
			   AND phon_Number = CASE WHEN @PhoneNumber IS NULL THEN phon_Number ELSE @PhoneNumber END
			   AND phon_Deleted IS NULL
			   AND phon_CompanyID IS NOT NULL;

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
			 WHERE CompanyID NOT IN (
				SELECT comp_CompanyID
				  FROM Company
					   INNER JOIN PRCity on comp_PRListingCityID = prci_CityID
				 WHERE prci_CityID = CASE WHEN @CityID IS NULL THEN prci_CityID ELSE @CityID END
				   AND prci_StateID = CASE WHEN @StateID IS NULL THEN prci_StateID ELSE @StateID END);

		END ELSE BEGIN

			INSERT INTO @SearchResults
			SELECT comp_CompanyID
			  FROM Company
				   INNER JOIN PRCity on comp_PRListingCityID = prci_CityID
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
				SELECT DISTINCT emai_CompanyID
				  FROM Email
				 WHERE emai_EmailAddress LIKE @Email
				   AND emai_Type = 'E'
				   AND emai_Deleted IS NULL);

		END ELSE BEGIN

			INSERT INTO @SearchResults
			SELECT DISTINCT emai_CompanyID
			  FROM Email
			 WHERE emai_EmailAddress LIKE @Email
			   AND emai_Type = 'E'
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
			  FROM PRDRCLicense
			 WHERE prdr_LicenseNumber LIKE @DRCLicenseNumber
			   AND prdr_Deleted IS NULL);

		END ELSE BEGIN

			INSERT INTO @SearchResults
			SELECT DISTINCT prdr_CompanyID
			  FROM PRDRCLicense
			 WHERE prdr_LicenseNumber LIKE @DRCLicenseNumber
			   AND prdr_Deleted IS NULL;

			SET @IsFirstQuery = 0;
		END

		--PRINT 'DRC License Search Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))
		SET @Start = GETDATE()

	END


	IF (@ServiceID > 0) BEGIN
		-- If we already have a set of CompanyIDs, then
		-- we must now remove what doesn't match this next
		-- criteria
		IF (@IsFirstQuery = 0) BEGIN
			DELETE FROM @SearchResults
			 WHERE CompanyID NOT IN (
				SELECT DISTINCT prse_CompanyID
			  FROM PRService
			 WHERE prse_ServiceID = @ServiceID);

		END ELSE BEGIN

			INSERT INTO @SearchResults
			SELECT DISTINCT prse_CompanyID
			  FROM PRService
			 WHERE prse_ServiceID = @ServiceID;

			SET @IsFirstQuery = 0;
		END

		--PRINT 'Service Search Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))
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
			  FROM PRCompanyBrand
			 WHERE prc3_Brand LIKE @Brand
			   AND prc3_Deleted IS NULL);

		END ELSE BEGIN

			INSERT INTO @SearchResults
			SELECT DISTINCT prc3_CompanyID
			  FROM PRCompanyBrand
			 WHERE prc3_Brand LIKE @Brand
			   AND prc3_Deleted IS NULL;

			SET @IsFirstQuery = 0;
		END

		--PRINT 'Brand Search Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))
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
			   comp_TypeDisplay 
		  FROM vSearchListCompany;
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
			   comp_TypeDisplay 
		  FROM @SearchResults
			   INNER JOIN vSearchListCompany on CompanyID = comp_CompanyID
	END

	RETURN

END
GO
