/***********************************************************************
***********************************************************************
 Copyright Produce Report Co. 2006-2022

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Report Co. is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Report Co.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 Notes:	

***********************************************************************
***********************************************************************/

IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'ufn_BRIsAwardMember' AND Type='FN') DROP FUNCTION dbo.ufn_BRIsAwardMember
GO
 /**
 
**/
CREATE FUNCTION dbo.ufn_BRIsAwardMember(@AwardWinner CHAR(1), @AwardDate DATETIME, @IndustryType VARCHAR(40))  
RETURNS VARCHAR(100) AS  
BEGIN 
    IF (@AwardWinner IS NULL) BEGIN
	    RETURN NULL
    END

	DECLARE @Return VARCHAR(100) = ''
	SET @Return = 
		CASE @IndustryType
			WHEN 'P' THEN 'Trading'
			WHEN 'T' THEN 'Transportation'
		END
		
	SET @Return = @Return + ' Member since ' + CAST(YEAR(@AwardDate) AS VARCHAR(4))

	RETURN	@Return	
END
GO


IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'usp_BRAffiliates' AND Type='P') DROP PROCEDURE dbo.usp_BRAffiliates
GO

/**
Returns the affiliation data for the specified company
**/
CREATE PROCEDURE dbo.usp_BRAffiliates
	@CompanyID INT,
	@ColumnCount INT = 3
AS 
BEGIN 
     
    DECLARE @CompanyIDs TABLE (
        CompanyID INT
    )

    DECLARE @ReportTable TABLE (
        ndx INT IDENTITY(1,1),
        RowID INT,
        ColID INT,
        CompanyID INT,
        Name VARCHAR(500),
        ListingLocation VARCHAR(500),
        COUNTRY VARCHAR(50),
        RatingLine VARCHAR(100),
        TMFMAward VARCHAR(100),
        Classifications VARCHAR(1000)
    )

    DECLARE @HQID INT
    SET @HQID = dbo.ufn_BRGetHQID(@CompanyID);

    -- Go get other companies that have a direct
    -- relationship
    INSERT INTO @CompanyIDs (CompanyID)
    SELECT prcr_LeftCompanyID
      FROM PRCompanyRelationship WITH (NOLOCK)
     WHERE prcr_RightCompanyID = @HQID
       AND prcr_Type IN (27, 28, 29)
       AND prcr_Active = 'Y';

    -- Go get other companies that have a direct
    -- relationship
    INSERT INTO @CompanyIDs (CompanyID)
    SELECT prcr_RightCompanyID
      FROM PRCompanyRelationship WITH (NOLOCK)
     WHERE prcr_LeftCompanyID = @HQID
       AND prcr_Type IN (27, 28, 29)
       AND prcr_Active = 'Y';


    -- This should remove any duplicates found as a result of using
    -- two (2) separate queries to build our initial list.
    INSERT INTO @ReportTable (CompanyID, Name, ListingLocation, RatingLine, TMFMAward, Classifications)
    SELECT comp_CompanyID, comp_PRCorrTradestyle, CityStateCountryShort, prra_RatingLine, dbo.ufn_BRIsAwardMember(comp_PRTMFMAward, comp_PRTMFMAwardDate, comp_PRIndustryType) AS TMFMAward, dbo.ufn_GetLevel1Classifications(comp_CompanyID, 2)
      FROM Company WITH (NOLOCK) 
           INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
           LEFT OUTER JOIN vPRCurrentRating ON comp_CompanyID = prra_CompanyId
     WHERE comp_CompanyID IN (SELECT DISTINCT CompanyID FROM @CompanyIDs) 
       AND comp_PRListingStatus IN ('L', 'H', 'LUV')
  Order BY comp_PRCorrTradestyle, CityStateCountryShort;
       
    -- Now build the Row/Col values needed to display
    -- this data in a Matrix control.  The control needs
    -- something to break on.
    DECLARE @RowCount INT, @ColCount INT, @CurCompanyID INT
	DECLARE @Index INT, @CompanyCount INT

	SELECT @CompanyCount = COUNT(1) FROM @ReportTable
	SET @Index = 1
    SET @RowCount = 0
    SET @ColCount = 0

	WHILE (@Index <= @CompanyCount) BEGIN
	
		SELECT @CurCompanyID = CompanyID 
          FROM @ReportTable 
         WHERE ndx = @Index
		
	    IF @ColCount =  @ColumnCount BEGIN
		    SET @RowCount = @RowCount + 1
		    SET @ColCount = 0
	    END

	    UPDATE @ReportTable SET RowID = @RowCount, ColID = @ColCount WHERE CompanyID = @CurCompanyID;
	    SET @ColCount = @ColCount + 1
		SET @Index = @Index + 1
	END

    SELECT * FROM @ReportTable Order BY RowID, ColID;
END
GO

IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'usp_BRBalanceSheet' AND Type='P') DROP PROCEDURE dbo.usp_BRBalanceSheet
GO

/**
Returns the balance sheet information for the
specified company.
**/
CREATE PROCEDURE dbo.usp_BRBalanceSheet
	@CompanyID INT,
	@ThresholdMonthsOld INT = 24
AS  
BEGIN

    DECLARE @HQID INT
    SET @HQID = dbo.ufn_BRGetHQID(@CompanyID)

    DECLARE @FinancialCompanyID INT
    SET @FinancialCompanyID = dbo.ufn_BRGetFinancialCompanyID(@HQID)

    -- Look for any statement within the threshold
    -- period
    DECLARE @MostRecentStatementDate DATETIME

    SELECT @MostRecentStatementDate = MAX(prfs_StatementDate) 
      FROM PRFinancial WITH (NOLOCK)
     WHERE prfs_CompanyId = @FinancialCompanyID 
       AND prfs_StatementDate > DATEADD(mm, 0 - @ThresholdMonthsOld, GETDATE());

	    SELECT PRFinancial.*
	      FROM PRFinancial  WITH (NOLOCK)
               INNER JOIN Company WITH (NOLOCK) ON prfs_CompanyId = comp_CompanyID 
	     WHERE prfs_CompanyId = @FinancialCompanyID
  	    AND prfs_Publish = 'Y'
	    AND prfs_StatementDate = @MostRecentStatementDate
	    AND prfs_Deleted IS NULL
	    AND prfs_EntryStatus = 'F' -- Full
	    AND comp_PRConfidentialFS IS NULL
	    AND Comp_Deleted IS NULL; 
END
GO




IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'usp_BRBasicCompanyInfo' AND Type='P') DROP PROCEDURE dbo.usp_BRBasicCompanyInfo
GO

/**
Returns the basic company data.  If a "branch" company is specified,
the HQ company will be returned instead.
**/
CREATE PROCEDURE dbo.usp_BRBasicCompanyInfo 
	@CompanyID INT
AS 

SELECT comp_CompanyID, comp_Name, comp_PRCorrTradestyle, CityStateCountryShort AS ListingLocation,
	   comp_PRLegalName, 
	   REPLACE(dbo.ufn_GetCustomCaptionValue('PIKSUtils', 'LogoURL', 'en-us'), 'https://', 'http://') + comp_PRLogo + '&Width=125&Height=125' AS comp_PRLogo, 
	   comp_PRListingStatus, comp_PRInvestigationMethodGroup, comp_PRIndustryType,
	   comp_PRPublishLogo,
	  CASE comp_PRPublishLogo 
			WHEN 'Y' THEN dbo.ufnclr_GetLogoWidth( REPLACE(dbo.ufn_GetCustomCaptionValue('PIKSUtils', 'LogoURL', 'en-us'), 'https://', 'http://') + comp_PRLogo + '&Width=125&Height=125')
			ELSE 0 
		    END AS LogoWidth
  FROM Company WITH (NOLOCK)
       INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
 WHERE comp_CompanyID = dbo.ufn_BRGetHQID(@CompanyID);

/*
SELECT comp_CompanyID, comp_Name, comp_PRCorrTradestyle, CityStateCountryShort AS ListingLocation,
	   comp_PRLegalName, 
	   REPLACE(dbo.ufn_GetCustomCaptionValue('PIKSUtils', 'LogoURL', 'en-us'), 'https://', 'http://') + comp_PRLogo + '&Width=125&Height=125' AS comp_PRLogo, 
	   comp_PRListingStatus, comp_PRInvestigationMethodGroup, comp_PRIndustryType,
	   comp_PRPublishLogo,
	  CASE comp_PRPublishLogo 
			WHEN 'Y' THEN dbo.ufnclr_GetLogoWidth( REPLACE(dbo.ufn_GetCustomCaptionValue('PIKSUtils', 'LogoURL', 'en-us'), 'https://', 'http://') + comp_PRLogo + '&Width=125&Height=125')
			ELSE 0 
		    END AS LogoWidth
  FROM Company WITH (NOLOCK)
       INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
 WHERE comp_CompanyID = dbo.ufn_BRGetHQID(@CompanyID);
 */
GO




/**
Returns the internet addresses.  If a "branch" company is specified,
the HQ company will be returned instead.
**/
IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'usp_BRBasicCompanyInfoInternet' AND Type='P') DROP PROCEDURE dbo.usp_BRBasicCompanyInfoInternet
GO


CREATE PROCEDURE dbo.usp_BRBasicCompanyInfoInternet 
	@CompanyID INT
AS 


	DECLARE @MyTable table (
		Emai_EmailAddress varchar(255),
		emai_PRWebAddress varchar(255)
	)

	INSERT INTO @MyTable (Emai_EmailAddress)
	SELECT RTRIM(Emai_EmailAddress)
      FROM vCompanyEmail WITH (NOLOCK)
     WHERE elink_RecordID = dbo.ufn_BRGetHQID(@CompanyID)
	   AND elink_Type = 'E'
       AND emai_PRPreferredPublished = 'Y';


	DECLARE @Count int = @@ROWCOUNT

	DECLARE @Website varchar(255)
	SELECT @Website = RTRIM(emai_PRWebAddress)
      FROM vCompanyEmail WITH (NOLOCK)
	 WHERE elink_RecordID = dbo.ufn_BRGetHQID(@CompanyID)
	   AND elink_Type = 'W'
	   AND emai_PRPreferredPublished = 'Y';

	IF @Count = 0 BEGIN
		INSERT INTO @MyTable (emai_PRWebAddress) VALUES (@Website);
	END ELSE BEGIN

		UPDATE @MyTable
		   SET emai_PRWebAddress = @Website
	END


	SELECT * FROM @MyTable;

GO


/**
Returns the addresses for the specified company
**/
IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'usp_BRBasicCompanyInfoAddresses' AND Type='P') DROP PROCEDURE dbo.usp_BRBasicCompanyInfoAddresses
GO

CREATE PROCEDURE dbo.usp_BRBasicCompanyInfoAddresses 
	@CompanyID INT
AS 
SELECT Addr_Address1, Addr_Address2, Addr_Address3, Addr_Address4, Addr_Address5, Addr_PostCode, prci_City, prst_State, prcn_Country
  FROM Address WITH (NOLOCK)
       INNER JOIN Address_Link WITH (NOLOCK) ON Addr_AddressId = AdLi_AddressId 
       INNER JOIN vPRLocation ON prci_CityID = addr_PRCityId
 WHERE AdLi_CompanyID = dbo.ufn_BRGetHQID(@CompanyID) 
   AND addr_PRPublish = 'Y'
   AND AdLi_Type IN ('M', 'PH')
   AND AdLi_PersonID IS NULL
   AND Addr_Deleted IS NULL
 Order BY dbo.ufn_GetAddressListSeq(AdLi_Type), AdLi_CreatedDate
GO


/**
Returns the phone numbers for the specified company
**/
IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'usp_BRBasicCompanyInfoPhone' AND Type='P') DROP PROCEDURE dbo.usp_BRBasicCompanyInfoPhone
GO

CREATE PROCEDURE dbo.usp_BRBasicCompanyInfoPhone 
	@CompanyID INT
AS 

SELECT phon_PRDescription, 
       dbo.ufn_FormatPhone(Phon_CountryCode, 
						   Phon_AreaCode, 
	                       Phon_Number, 
	                       phon_PRExtension) AS Phone
  FROM vPRCompanyPhone WITH (NOLOCK)
 WHERE plink_RecordID = dbo.ufn_BRGetHQID(@CompanyID)
   AND phon_PRPublish = 'Y'
   AND phon_PRPreferredPublished = 'Y'
Order BY dbo.ufn_GetListingPhoneSeq(plink_Type, phon_PRSequence)
GO



/**
Returns the aliases for the specified company
**/
IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'usp_BRBasicCompanyInfoAlias' AND Type='P') DROP PROCEDURE dbo.usp_BRBasicCompanyInfoAlias
GO

CREATE PROCEDURE dbo.usp_BRBasicCompanyInfoAlias 
	@CompanyID INT
AS 

SELECT pral_Alias
  FROM PRCompanyAlias WITH (NOLOCK) 
 WHERE pral_CompanyId = dbo.ufn_BRGetHQID(@CompanyID)  
   AND pral_Deleted IS NULL
Order BY pral_Alias;
GO





/**
Returns the ownership for the specified company
**/
IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'usp_BRBasicCompanyInfoOwnership' AND Type='P') DROP PROCEDURE dbo.usp_BRBasicCompanyInfoOwnership
GO

CREATE PROCEDURE dbo.usp_BRBasicCompanyInfoOwnership 
	@CompanyID INT
AS 
BEGIN
    DECLARE @ReportTable TABLE (
        CompanyID INT,
        PersonID INT,
        Display VARCHAR(500),
        Title VARCHAR(50),
        Percentage DECIMAL(6,2),
        Relationship VARCHAR(100),
        Rating VARCHAR(50),
        SortField VARCHAR(500),
        ListingLocation VARCHAR(100)
    )

    DECLARE @HQID int, @ListingStatus varchar(40)
    SET @HQID = dbo.ufn_BRGetHQID(@CompanyID);

	SELECT @ListingStatus = comp_PRListingStatus
	  FROM Company WITH (NOLOCK)
	 WHERE comp_CompanyID = @CompanyID;

	INSERT INTO @ReportTable (Percentage, Display)
	SELECT -1, prex_Name + ': ' + prc4_Symbol1
	  FROM PRCompanyStockExchange
	       INNER JOIN PRStockExchange ON prc4_StockExchangeId = prex_StockExchangeID
	 WHERE prc4_CompanyId = @HQID;


    -- 100% by Company
    INSERT INTO @ReportTable (CompanyID, Percentage, Title)
    SELECT prcr_LeftCompanyID, prcr_OwnershipPct, Capt_US AS OwnershipDescription
    FROM PRCompanyRelationship WITH (NOLOCK)
         LEFT OUTER JOIN Custom_Captions WITH (NOLOCK) ON prcr_OwnershipDescription = Capt_Code AND Capt_Family = 'prcr_OwnershipDescription'
    WHERE prcr_RightCompanyID = @HQID
    AND prcr_Type = 27
    AND prcr_Active = 'Y'
    AND prcr_Deleted IS NULL;

    -- 1% to 99% by Companies
    INSERT INTO @ReportTable (CompanyID, Percentage, Title)
    SELECT prcr_LeftCompanyID, prcr_OwnershipPct, Capt_US AS OwnershipDescription
    FROM PRCompanyRelationship WITH (NOLOCK)
         LEFT OUTER JOIN Custom_Captions WITH (NOLOCK) ON prcr_OwnershipDescription = Capt_Code AND Capt_Family = 'prcr_OwnershipDescription'
    WHERE prcr_RightCompanyID = @HQID
    AND prcr_Type = 28
    AND prcr_Active = 'Y'
    AND prcr_Deleted IS NULL;

	IF (@ListingStatus IN ('L', 'H', 'LUV')) BEGIN
		-- Persons
		INSERT INTO @ReportTable (PersonID, Display, Percentage, Title, SortField)
		SELECT pers_PersonID, 
			dbo.ufn_FormatPerson(Pers_FirstName, Pers_LastName, Pers_MiddleName, pers_PRNickname1, Pers_Suffix) AS Name,
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

	END ELSE BEGIN

		INSERT INTO @ReportTable (PersonID, Display, Percentage, Title, SortField)
		SELECT proh_PersonID, 
		       dbo.ufn_FormatPerson(Pers_FirstName, Pers_LastName, Pers_MiddleName, pers_PRNickname1, Pers_Suffix) AS Name,
		       proh_Percentage, 
			   proh_Title, 
			   proh_SortField
		  FROM PROwnershipHistory WITH (NOLOCK)
		  	   INNER JOIN Person  WITH (NOLOCK) ON proh_PersonID = pers_PersonID
		 WHERE proh_CompanyID = @HQID;
	END


    -- Unattributed Ownership
    INSERT INTO @ReportTable(Display, Percentage, SortField)
    SELECT CONVERT(VARCHAR(500), comp_PRUnattributedOwnerDesc), comp_PRUnattributedOwnerPct, CONVERT(VARCHAR(500), comp_PRUnattributedOwnerDesc)
      FROM Company WITH (NOLOCK)
     WHERE comp_CompanyID = @HQID
       AND comp_PRUnattributedOwnerPct IS NOT NULL;

    UPDATE @ReportTable
    SET Display = CASE WHEN comp_PRListingStatus IN ('L', 'LUV') 
	                       THEN 'BB #' + CONVERT(VARCHAR(150), T1.Comp_CompanyId) + ', '
						   ELSE '' END
						    + T1.Comp_Name,
        Rating = T1.prra_RatingLine,
        ListingLocation = T1.CityStateCountryShort
    FROM (SELECT comp_CompanyID, ISNULL(Company.comp_PRLegalName, Company.Comp_Name) Comp_Name, prra_RatingLine, CityStateCountryShort, comp_PRListingStatus
            FROM Company WITH (NOLOCK)
                 INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
                 LEFT OUTER JOIN vPRCurrentRating  ON comp_CompanyID = prra_CompanyId
          WHERE Company.Comp_Deleted IS NULL 
            AND comp_PRListingStatus IN ('L', 'LUV', 'N1', 'N2', 'N3', 'N4', 'N5', 'N6')) T1,
        @ReportTable rt
    WHERE T1.Comp_CompanyId = rt.CompanyID;

    -- Get rid of any company records we initially found.
    -- The names will be null if they aren't to be listed
    DELETE FROM @ReportTable WHERE Display IS NULL;

    -- Due to formatting constraints in SRS, replace the
    -- NULL values with a magic number so they can be formatted
    -- correctly.
    UPDATE @ReportTable SET Percentage = 0 WHERE Percentage IS NULL;
	UPDATE @ReportTable SET Percentage = NULL WHERE Percentage = -1;

	
    -- Only add the 'Undisclosed' line item if we
    -- don't have any other ownership
    DECLARE @Count INT
    SELECT @Count = COUNT(1) FROM @ReportTable;

    IF @Count = 0 BEGIN
	    INSERT INTO @ReportTable(Display, Percentage, SortField) VALUES ('Undisclosed', 100, 'Undisclosed');
    END

    SELECT * FROM @ReportTable Order BY ISNULL(Percentage, 100) DESC, SortField;
END
GO




IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'usp_BRBranches' AND Type='P') DROP PROCEDURE dbo.usp_BRBranches
GO

/**
Returns the branch data for the specified company
**/
CREATE PROCEDURE dbo.usp_BRBranches
	@CompanyID INT,
	@ColumnCount INT = 3
AS 
BEGIN
    DECLARE @ReportTable TABLE (
        ndx INT IDENTITY(1,1),
        RowID INT,
        ColID INT,
        CompanyID INT,
        Name VARCHAR(500),
        ListingLocation VARCHAR(500),
        RatingLine VARCHAR(100),
        TMFMAward VARCHAR(100),
        Classifications VARCHAR(1000)
    )

    INSERT INTO @ReportTable
    SELECT 0, 0, comp_CompanyID, comp_PRCorrTradestyle, CityStateCountryShort, prra_RatingLine, dbo.ufn_BRIsAwardMember(comp_PRTMFMAward, comp_PRTMFMAwardDate, comp_PRIndustryType) AS TMFMAward, dbo.ufn_GetLevel1Classifications(Company.Comp_CompanyId, 2)
      FROM Company WITH (NOLOCK)
           INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
           LEFT OUTER JOIN vPRCurrentRating ON comp_CompanyID = prra_CompanyId
     WHERE comp_PRHQId = dbo.ufn_BRGetHQID(@CompanyID)
       AND comp_PRType = 'B'
       AND comp_PRListingStatus IN ('L', 'H', 'LUV')
       AND Comp_Deleted IS NULL
  Order BY comp_PRCorrTradestyle, prst_State, prci_City;


    -- Now build the Row/Col values needed to display
    -- this data in a Matrix control.  The control needs
    -- something to break on.
    DECLARE @RowCount INT, @ColCount INT, @CurCompanyID INT
	DECLARE @Index INT, @CompanyCount INT

	SELECT @CompanyCount = COUNT(1) FROM @ReportTable
	SET @Index = 1
    SET @RowCount = 0
    SET @ColCount = 0

	WHILE (@Index <= @CompanyCount) BEGIN
	
		SELECT @CurCompanyID = CompanyID 
          FROM @ReportTable 
         WHERE ndx = @Index
		
	    IF @ColCount =  @ColumnCount BEGIN
		    SET @RowCount = @RowCount + 1
		    SET @ColCount = 0
	    END

	    UPDATE @ReportTable SET RowID = @RowCount, ColID = @ColCount WHERE CompanyID = @CurCompanyID;

	    SET @ColCount = @ColCount + 1
		SET @Index = @Index + 1
	END


    SELECT * FROM @ReportTable Order BY RowID, ColID;
END 
GO


IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'usp_BRBusinessEvents' AND Type='P') 
	DROP PROCEDURE dbo.usp_BRBusinessEvents
GO

/**
Returns the business event data for the specified company.
The heavy lifting is actually done by the BBS Data Formatter
class who builds the verbiage based on the business event IDs
and types.
**/
CREATE PROCEDURE dbo.usp_BRBusinessEvents
	@CompanyID INT,
	@DaysOldStart INT = 0,
	@DaysOldEnd INT = 999999,
	@ReportType INT = 1 -- IF 2, limit to bankruptcy events
AS 
BEGIN
    DECLARE @ReportTable TABLE (
        BusinessEventID INT,
        BusinessEventTypeID INT,
        EventDate DATETIME,
        EventDisplayDate VARCHAR(50),
        Verbiage VARCHAR(5000)
    )

    DECLARE @HQID INT
    SET @HQID = dbo.ufn_BRGetHQID(@CompanyID)

    -- Business Events
    INSERT INTO @ReportTable (BusinessEventID, BusinessEventTypeID, EventDate, EventDisplayDate, Verbiage)
    SELECT prbe_BusinessEventId, prbe_BusinessEventTypeId, prbe_EffectiveDate, prbe_DisplayedEffectiveDate, dbo.ufn_GetBusinessEventText(prbe_BusinessEventId, @ReportType) AS Verbiage
      FROM PRBusinessEvent WITH (NOLOCK)
     WHERE prbe_CompanyId = @HQID
       AND prbe_PublishUntilDate > GETDATE()
       AND DATEDIFF(DAY, prbe_EffectiveDate, GETDATE()) BETWEEN @DaysOldStart AND @DaysOldEnd
       AND prbe_Deleted IS NULL;

    -- Even if we do not have data, we must return something
    -- for ReportType 1 to ensure the sub-report is displayed.
    IF @ReportType = 1 BEGIN
	    DECLARE @Count INT
	    SELECT @Count = COUNT(1) FROM @ReportTable;
    	
	    --IF @Count = 0 BEGIN
	    --INSERT INTO @ReportTable VALUES (NULL, NULL, NULL, NULL, NULL);
	    --END
    END

    IF @ReportType = 2 BEGIN
	    SELECT * FROM @ReportTable WHERE BusinessEventTypeID IN (3,5) Order BY EventDate DESC;
    END ELSE BEGIN
	    SELECT * FROM @ReportTable Order BY EventDate DESC;	
    END
END
GO 


IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'usp_BRBusinessEventsNameChange' AND Type='P') DROP PROCEDURE dbo.usp_BRBusinessEventsNameChange
GO

/**
Returns the name change information for the specified
company.
**/
CREATE PROCEDURE dbo.usp_BRBusinessEventsNameChange
	@CompanyID INT,
	@ReportType INT = 1 -- IF 2, limit to bankruptcy events	
AS 
BEGIN
    DECLARE @ReportTable TABLE (
	    ChangeDate DATETIME,
	    OldName VARCHAR(100),
	    OriginalName VARCHAR(100)
    )

    IF (@ReportType = 1) BEGIN
    INSERT INTO @ReportTable 
    SELECT comp_PROldName1Date,
	    comp_PROldName1,
	    comp_PROriginalName
    FROM Company WITH (NOLOCK)
    WHERE comp_CompanyID = dbo.ufn_BRGetHQID(@CompanyID) 
    AND comp_PROldName1Date IS NOT NULL;
       
    INSERT INTO @ReportTable
    SELECT comp_PROldName2Date,
        comp_PROldName2,
	    comp_PROriginalName
    FROM Company WITH (NOLOCK)
    WHERE comp_CompanyID = dbo.ufn_BRGetHQID(@CompanyID) 
    AND comp_PROldName2Date IS NOT NULL;
       
    INSERT INTO @ReportTable
    SELECT comp_PROldName3Date,
	    comp_PROldName3,
	    comp_PROriginalName
    FROM Company WITH (NOLOCK)
    WHERE comp_CompanyID = dbo.ufn_BRGetHQID(@CompanyID) 
    AND comp_PROldName3Date IS NOT NULL;      
    END

    SELECT * FROM @ReportTable Order BY ChangeDate;
END
GO

IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'usp_BRBusinessEventsDisplayToggle' AND Type='P') DROP PROCEDURE dbo.usp_BRBusinessEventsDisplayToggle
GO
/**
Trick used to ensure the sub-report is displayed for
some types and not others if no data is present.
**/
CREATE PROCEDURE dbo.usp_BRBusinessEventsDisplayToggle
	@ReportType INT
AS 
BEGIN
    DECLARE @ReportTable TABLE (
	    Display INT
    )

    IF @ReportType = 1 BEGIN
	    INSERT INTO @ReportTable VALUES (1);
    END

    SELECT * FROM @ReportTable;
END
GO   

IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'usp_BRBusinessProfileLicense' AND Type='P') DROP PROCEDURE dbo.usp_BRBusinessProfileLicense
GO

/**
Returns the License information
**/
CREATE PROCEDURE dbo.usp_BRBusinessProfileLicense
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
    SELECT 'DRC License', prdr_LicenseNumber
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



IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'usp_BRBusinessProfileOperations' AND Type='P') DROP PROCEDURE dbo.usp_BRBusinessProfileOperations
GO

/**
Returns the Method of Operations
**/
CREATE PROCEDURE dbo.usp_BRBusinessProfileOperations
	@CompanyID INT
AS  
BEGIN
    DECLARE @HQID INT
    SET @HQID = dbo.ufn_BRGetHQID(@CompanyID)


    DECLARE @ReportTable TABLE (
	    ClassificationName VARCHAR(100),
	    Percentage NUMERIC(24,6),
	    CITY VARCHAR(50),
	    STATE VARCHAR(50),
	    ListingLocation VARCHAR(100),
	    COUNTRY VARCHAR(50),
	    ClassificationList VARCHAR(MAX),
	    prc2_PercentageSource CHAR(1)
    )

    INSERT INTO @ReportTable (ClassificationName, Percentage, prc2_PercentageSource)
    SELECT prcl_Name, ISNULL(prc2_Percentage, 0), prc2_PercentageSource
      FROM PRClassification WITH (NOLOCK) 
           INNER JOIN PRCompanyClassification WITH (NOLOCK) ON  prcl_ClassificationId = prc2_ClassificationId
     WHERE prc2_CompanyId = @HQID
       AND prc2_Deleted IS NULL
  Order BY prc2_Percentage DESC;

    -- Build a comma-delimited list for easy display
    DECLARE @List VARCHAR(MAX)
    SELECT @List = COALESCE(@List + ', ', '') + ClassificationName
    FROM @ReportTable;


    UPDATE @ReportTable 
    SET CITY = prci_City,
        STATE = prst_State,
        COUNTRY = prcn_Country,
        ListingLocation = CityStateCountryShort,
        ClassificationList = @List
    FROM (      
	    SELECT prci_City, prst_State, prcn_Country, CityStateCountryShort
	      FROM Company WITH (NOLOCK)
               INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
 	     WHERE Company.Comp_CompanyId = @HQID) T1;

    SELECT * FROM @ReportTable Order BY Percentage DESC;
END
GO



IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'usp_BRBusinessProfileOperationsRetail' AND Type='P') DROP PROCEDURE dbo.usp_BRBusinessProfileOperationsRetail
GO

/**
Returns store count for retail operations
**/
CREATE PROCEDURE dbo.usp_BRBusinessProfileOperationsRetail
	@CompanyID INT
AS  
BEGIN
    SELECT prcl_Name,
        TotalStores.Capt_US       AS NumberOfTotalStores, 
	    prc2_ComboStores,
        ComboStores.Capt_US       AS NumberOfComboStores, 
        prc2_ConvenienceStores,
        ConvStores.Capt_US        AS NumberOfConvenienceStores, 
	    prc2_GourmetStores,
        GourmetStores.Capt_US     AS NumberOfGourmetStores, 
        prc2_HealthFoodStores,
        HealthStores.Capt_US      AS NumberOfHealthStores, 
        prc2_ProduceOnlyStores,
        ProduceStores.Capt_US     AS NumberOfProduceStores, 
        prc2_SupermarketStores,
        SupermarketStores.Capt_US AS NumberOfSupermarketStores, 
        prc2_SuperStores,
        SuperStores.Capt_US       AS NumberOfSuperStores, 
        prc2_WarehouseStores,
        WarehouseStores.Capt_US   AS NumberOfWarehouseStores
    FROM PRCompanyClassification WITH (NOLOCK) INNER JOIN
        PRClassification WITH (NOLOCK) ON prc2_ClassificationId = prcl_ClassificationId LEFT OUTER JOIN
        Custom_Captions TotalStores WITH (NOLOCK)       ON prc2_NumberOfStores            = TotalStores.Capt_Code AND TotalStores.capt_family = 'prc2_StoreCount' LEFT OUTER JOIN
        Custom_Captions ComboStores WITH (NOLOCK)       ON prc2_NumberOfComboStores       = ComboStores.Capt_Code AND ComboStores.capt_family = 'prc2_StoreCount' LEFT OUTER JOIN
        Custom_Captions ConvStores WITH (NOLOCK)        ON prc2_NumberOfConvenienceStores = ConvStores.Capt_Code AND ConvStores.capt_family = 'prc2_StoreCount' LEFT OUTER JOIN
        Custom_Captions GourmetStores WITH (NOLOCK)     ON prc2_NumberOfGourmetStores     = GourmetStores.Capt_Code AND GourmetStores.capt_family = 'prc2_StoreCount' LEFT OUTER JOIN
        Custom_Captions HealthStores WITH (NOLOCK)      ON prc2_NumberOfHealthFoodStores  = HealthStores.Capt_Code AND HealthStores.capt_family = 'prc2_StoreCount' LEFT OUTER JOIN
        Custom_Captions ProduceStores WITH (NOLOCK)     ON prc2_NumberOfProduceOnlyStores = ProduceStores.Capt_Code AND ProduceStores.capt_family = 'prc2_StoreCount' LEFT OUTER JOIN
        Custom_Captions SupermarketStores WITH (NOLOCK) ON prc2_NumberOfSupermarketStores = SupermarketStores.Capt_Code AND SupermarketStores.capt_family = 'prc2_StoreCount' LEFT OUTER JOIN
        Custom_Captions SuperStores WITH (NOLOCK)       ON prc2_NumberOfSuperStores       = SuperStores.Capt_Code AND SuperStores.capt_family = 'prc2_StoreCount' LEFT OUTER JOIN
        Custom_Captions WarehouseStores WITH (NOLOCK)   ON prc2_NumberOfWarehouseStores   = WarehouseStores.Capt_Code AND WarehouseStores.capt_family = 'prc2_StoreCount'
    WHERE prc2_CompanyId = dbo.ufn_BRGetHQID(@CompanyID)
    AND (prc2_ClassificationId = 330 OR prc2_ClassificationId = 320) -- Retail or Restaruant
    AND prc2_Deleted IS NULL
END
GO



IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'ufn_BRGetRegions' AND Type='FN') DROP FUNCTION dbo.ufn_BRGetRegions
GO

/**
Returns the a delimited list of the domestic regions for the
specified company and type
**/
CREATE FUNCTION dbo.ufn_BRGetRegions(@CompanyID INT, @Type VARCHAR(5))  
RETURNS VARCHAR(2000) AS  
BEGIN 

    -- Build a comma-delimited list of the sourcing regions
    DECLARE @List VARCHAR(2000)
    SELECT @List = COALESCE(@List + ', ', '') +  CAST(prd2_Description AS VARCHAR(1000))
      FROM PRRegion WITH (NOLOCK)
           INNER JOIN PRCompanyRegion WITH (NOLOCK) ON prd2_RegionId = prcd_RegionId
     WHERE prcd_CompanyId = @CompanyID
       AND prcd_Type = @Type; 
       
    RETURN @List
END 
GO


IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'usp_BRBusinessProfileGrids' AND Type='P') DROP PROCEDURE dbo.usp_BRBusinessProfileGrids
GO

/**
Returns the attributes for the various operation types
**/
CREATE PROCEDURE dbo.usp_BRBusinessProfileGrids	
	@CompanyID INT
AS  
BEGIN
    DECLARE @HQID INT
    SET @HQID = dbo.ufn_BRGetHQID(@CompanyID)

    SELECT PRCompanyProfile. *, a.Capt_US AS BkrReceive, 
	          dbo.ufn_BRGetRegions(@HQID, 'SrcD') AS SourcingRegions
		    , dbo.ufn_BRGetRegions(@HQID, 'SellD') AS SellingRegions
		    , dbo.ufn_BRGetRegions(@HQID, 'TrkD') AS TruckingRegions
			, dbo.ufn_BRGetRegions(@HQID, 'TrkI') AS IntlTruckingRegions
		    , dbo.ufn_BRGetRegions(@HQID, 'SrcI') AS IntlImportRegions
		    , dbo.ufn_BRGetRegions(@HQID, 'SellI') AS IntlExportRegions
			, dbo.ufn_GetCustomCaptionValueList('prcp_ArrangesTransportWith', prcp_TrnBkrArrangesTransportation) as ArrangesTransporation
		    , b.Capt_US AS TrkrPowerUnits, c.Capt_US AS TrkrReefer, d.Capt_US AS TrkrDryVan
		    , e.Capt_US AS TrkrFlatbed, f.Capt_US AS TrkrPiggyback, g.Capt_US AS TrkrTanker
		    , h.Capt_US AS TrkrContainer, i.Capt_US AS TrkrOther, j.Capt_US AS StorageSF
		    , k.Capt_US AS StorageCF, l.Capt_US AS StorageCarlots, m.Capt_US AS StorageBushel
		    , n.capt_US AS Volume, o.capt_US AS FTEmployees, p.capt_US AS PTEmployees
		    , q.Capt_US AS TrucksOwned, r.Capt_US AS TrucksLeased
		    , s.Capt_US AS TrailersOwned, t.Capt_US AS TrailersLeased
            , u.Capt_US AS StorageCoveredSF, v.Capt_US AS StorageUncoverdSF
            , x.Capt_US AS OrganicCertifiedBy, y.Capt_US AS LumberVolume
    FROM PRCompanyProfile WITH (NOLOCK) 
        LEFT OUTER JOIN Custom_Captions a WITH (NOLOCK) ON prcp_BkrReceive     = a.Capt_Code AND a.Capt_Family = 'prcp_bkrreceive' 
        LEFT OUTER JOIN Custom_Captions b WITH (NOLOCK) ON prcp_TrkrPowerUnits = b.Capt_Code AND b.Capt_Family = 'TruckEquip' 
        LEFT OUTER JOIN Custom_Captions c WITH (NOLOCK) ON prcp_TrkrReefer     = c.Capt_Code AND c.Capt_Family = 'TruckEquip' 
        LEFT OUTER JOIN Custom_Captions d WITH (NOLOCK) ON prcp_TrkrDryVan     = d.Capt_Code AND d.Capt_Family = 'TruckEquip' 
        LEFT OUTER JOIN Custom_Captions e WITH (NOLOCK) ON prcp_TrkrFlatbed    = e.Capt_Code AND e.Capt_Family = 'TruckEquip' 
        LEFT OUTER JOIN Custom_Captions f WITH (NOLOCK) ON prcp_TrkrPiggyback  = f.Capt_Code AND f.Capt_Family = 'TruckEquip' 
        LEFT OUTER JOIN Custom_Captions g WITH (NOLOCK) ON prcp_TrkrTanker     = g.Capt_Code AND g.Capt_Family = 'TruckEquip' 
        LEFT OUTER JOIN Custom_Captions h WITH (NOLOCK) ON prcp_TrkrContainer  = h.Capt_Code AND h.Capt_Family = 'TruckEquip' 
        LEFT OUTER JOIN Custom_Captions i WITH (NOLOCK) ON prcp_TrkrOther      = i.Capt_Code AND i.Capt_Family = 'TruckEquip' 
        LEFT OUTER JOIN Custom_Captions j WITH (NOLOCK) ON prcp_StorageSF      = j.Capt_Code AND j.Capt_Family = 'prcp_StorageSF' 
        LEFT OUTER JOIN Custom_Captions k WITH (NOLOCK) ON prcp_StorageCF      = k.Capt_Code AND k.Capt_Family = 'prcp_StorageCF' 
        LEFT OUTER JOIN Custom_Captions l WITH (NOLOCK) ON prcp_StorageCarlots = l.Capt_Code AND l.Capt_Family = 'prcp_StorageCarlots' 
        LEFT OUTER JOIN Custom_Captions m WITH (NOLOCK) ON prcp_StorageBushel  = m.Capt_Code AND m.Capt_Family = 'prcp_StorageBushel' 
        LEFT OUTER JOIN Custom_Captions n WITH (NOLOCK) ON prcp_Volume         = n.Capt_Code AND n.Capt_Family = 'prcp_Volume' 
        LEFT OUTER JOIN Custom_Captions o WITH (NOLOCK) ON prcp_FTEmployees    = o.Capt_Code AND o.Capt_Family = 'NumEmployees' 
        LEFT OUTER JOIN Custom_Captions p WITH (NOLOCK) ON prcp_PTEmployees    = p.Capt_Code AND p.Capt_Family = 'NumEmployees'
        LEFT OUTER JOIN Custom_Captions q WITH (NOLOCK) ON prcp_TrkrTrucksOwned= q.Capt_Code AND q.Capt_Family = 'TruckEquip' 
        LEFT OUTER JOIN Custom_Captions r WITH (NOLOCK) ON prcp_TrkrTrucksLeased= r.Capt_Code AND r.Capt_Family = 'TruckEquip' 
        LEFT OUTER JOIN Custom_Captions s WITH (NOLOCK) ON prcp_TrkrTrailersOwned= s.Capt_Code AND s.Capt_Family = 'TruckEquip' 
        LEFT OUTER JOIN Custom_Captions t WITH (NOLOCK) ON prcp_TrkrTrailersLeased= t.Capt_Code AND t.Capt_Family = 'TruckEquip' 
		LEFT OUTER JOIN Custom_Captions u WITH (NOLOCK) ON prcp_StorageCoveredSF= u.Capt_Code AND u.Capt_Family = 'prcp_StorageSF' 
		LEFT OUTER JOIN Custom_Captions v WITH (NOLOCK) ON prcp_StorageUncoveredSF= v.Capt_Code AND v.Capt_Family = 'prcp_StorageSF' 
		LEFT OUTER JOIN Custom_Captions x WITH (NOLOCK) ON prcp_OrganicCertifiedBy= x.Capt_Code AND x.Capt_Family = 'prcp_OrganicCertifiedBy' 
		LEFT OUTER JOIN Custom_Captions y WITH (NOLOCK) ON prcp_Volume         = y.Capt_Code AND y.Capt_Family = 'prcp_VolumeL' 
    WHERE prcp_CompanyId = @HQID
      AND prcp_Deleted IS NULL;
END
GO



IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'usp_BRBusinessProfileType30' AND Type='P') DROP PROCEDURE dbo.usp_BRBusinessProfileType30
GO
/**
Returns the companies that have a type 30 relationship
**/
CREATE PROCEDURE dbo.usp_BRBusinessProfileType30
	@CompanyID INT
AS  
BEGIN
    DECLARE @HQID INT
    SET @HQID = dbo.ufn_BRGetHQID(@CompanyID)

    SELECT 'R' AS Type, comp_CompanyID, comp_PRCorrTradestyle, prci_City, prst_State, prcn_Country, CityStateCountryShort AS ListingLocation
      FROM Company WITH (NOLOCK)
           INNER JOIN PRCompanyRelationship WITH (NOLOCK) ON comp_CompanyID = prcr_LeftCompanyID  
           INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
     WHERE prcr_RightCompanyID = @HQID
       AND PRCompanyRelationship.prcr_Type = '30'
       AND Comp_Deleted IS NULL
       AND prcr_Active = 'Y'
    UNION
    SELECT 'L' AS Type, comp_CompanyID, comp_PRCorrTradestyle, prci_City, prst_State, prcn_Country, CityStateCountryShort AS ListingLocation
      FROM Company WITH (NOLOCK)
           INNER JOIN PRCompanyRelationship WITH (NOLOCK) ON comp_CompanyID = prcr_RightCompanyID  
           INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
     WHERE prcr_LeftCompanyID = @HQID
       AND PRCompanyRelationship.prcr_Type = '30'
       AND Comp_Deleted IS NULL
       AND prcr_Active = 'Y';
END
GO


IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'usp_BRBusinessProfileBrands' AND Type='P') DROP PROCEDURE dbo.usp_BRBusinessProfileBrands
GO

/**
Returns a list of unique brands for the company and branches
ordered by sequence
**/
CREATE PROCEDURE dbo.usp_BRBusinessProfileBrands
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


    -- Build a comma-delimited list of the sourcing regions
    DECLARE @List VARCHAR(5000)
    SELECT @List = COALESCE(@List + ', ', '') + prc3_Brand
      FROM (
		SELECT prc3_Brand, MIN(prc3_Sequence) AS Sequence
          FROM PRCompanyBrand WITH (NOLOCK)
         WHERE prc3_CompanyId IN (SELECT CompanyID FROM @CompanyIDs)
           AND prc3_Publish = 'Y'
           AND prc3_Deleted IS NULL
      GROUP BY prc3_Brand) TABLE1
  Order BY Sequence;

    SELECT @List AS Brands
END
GO

IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'usp_BRBusinessProfileStockExchange' AND Type='P') DROP PROCEDURE dbo.usp_BRBusinessProfileStockExchange
GO
/**
Returns a list of unique brands for the company and branches
ordered by sequence
**/
CREATE PROCEDURE dbo.usp_BRBusinessProfileStockExchange
	@CompanyID INT
AS  
BEGIN
    SELECT prex_Name, prc4_Symbol1, prc4_Symbol2, prc4_Symbol3
      FROM PRStockExchange WITH (NOLOCK)
           INNER JOIN PRCompanyStockExchange WITH (NOLOCK) ON prex_StockExchangeId = prc4_StockExchangeId
     WHERE prc4_CompanyId = dbo.ufn_BRGetHQID(@CompanyID)
       AND prex_Publish = 'Y'
       AND prc4_Deleted IS NULL
       AND prex_Deleted IS NULL
  Order BY prex_Order;
END
GO


IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'usp_BRBusinessProfileLocationCount' AND Type='P') DROP PROCEDURE dbo.usp_BRBusinessProfileLocationCount
GO
/**
Returns a count of listed locations
**/
CREATE PROCEDURE dbo.usp_BRBusinessProfileLocationCount
	@CompanyID INT
AS  
BEGIN
    DECLARE @HQID INT
    SET @HQID = dbo.ufn_BRGetHQID(@CompanyID)

    SELECT COUNT(1) AS COUNT
      FROM Company WITH (NOLOCK)
     WHERE (comp_PRHQId = @HQID OR comp_CompanyID=@HQID)
       AND comp_PRListingStatus IN ('L', 'H', 'LUV')
       AND Comp_Deleted IS NULL;
END
GO   



IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'usp_BRBusinessProfileBank' AND Type='P') DROP PROCEDURE dbo.usp_BRBusinessProfileBank
GO
/**
Returns a list of banks for the specified company
**/
CREATE PROCEDURE dbo.usp_BRBusinessProfileBank
	@CompanyID INT
AS  
BEGIN
    SELECT prcb_CompanyBankId, prcb_Name, prcb_Telephone, '<a href="http://' + prcb_Website + '">' + prcb_Website + '</a>' as prcb_Website
      FROM PRCompanyBank WITH (NOLOCK)
     WHERE prcb_CompanyId = dbo.ufn_BRGetHQID(@CompanyID)
       AND prcb_Publish = 'Y'
       AND prcb_Deleted IS NULL;
END
GO   


IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'usp_BRBusinessProfileCommodities' AND Type='P') DROP PROCEDURE dbo.usp_BRBusinessProfileCommodities
GO
/**
Returns a list of the commodities and commodidity attributes
**/
CREATE PROCEDURE dbo.usp_BRBusinessProfileCommodities
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
     WHERE comp_PRHQId = @HQID
       AND comp_PRListingStatus IN ('L', 'N3', 'N5', 'N6', 'H', 'LUV')
       AND Comp_Deleted IS NULL;


    DECLARE @ReportTable TABLE (
        Commodities VARCHAR(1500),
        GrowingAttributes VARCHAR(1500),
        SizeAttributes VARCHAR(1500),
        StorageAttributes VARCHAR(1500),
        StyleAttributes VARCHAR(1500)
    )

    DECLARE @Commodity TABLE (
        CommodityId INT,
        Name VARCHAR(50),
        IsHQ INT,
        Sequence INT
    )

    -- Get the HQ commodities
    INSERT INTO @Commodity
    SELECT DISTINCT prcm_CommodityId, dbo.ufn_GetCommodityPublishableName (prcm_CommodityId) AS prcm_Name, 1, MIN(prcca_Sequence)
      FROM PRCommodity WITH (NOLOCK)
           INNER JOIN PRCompanyCommodityAttribute WITH (NOLOCK) ON  prcca_CommodityId = prcm_CommodityId
     WHERE prcca_CompanyId = @HQID
       AND (prcca_Publish = 'Y' OR prcca_PublishWithGM = 'Y')
       AND prcca_Deleted IS NULL
       AND prcm_Deleted IS NULL
  GROUP BY prcm_CommodityId, prcm_Name
  Order BY MIN(prcca_Sequence);


    -- Now get the branch commodities excluding the HQ ones
    INSERT INTO @Commodity
    SELECT DISTINCT prcm_CommodityId, dbo.ufn_GetCommodityPublishableName (prcm_CommodityId) AS prcm_Name, 0, prcca_Sequence
      FROM PRCommodity WITH (NOLOCK)
           INNER JOIN PRCompanyCommodityAttribute WITH (NOLOCK) ON  prcca_CommodityId = prcm_CommodityId
     WHERE prcca_CompanyId IN (SELECT CompanyID FROM @CompanyIDs)
       AND prcca_CommodityId NOT IN (SELECT CommodityId FROM @Commodity)
       AND (prcca_Publish = 'Y' OR prcca_PublishWithGM = 'Y')
       AND prcca_Deleted IS NULL
       AND prcm_Deleted IS NULL;

    -- Build a comma-delimited list of the commodities
    DECLARE @List VARCHAR(1500)
    SELECT @List = COALESCE(@List + ', ', '') + Name
    FROM @Commodity
    Order BY IsHQ DESC;

    INSERT INTO @ReportTable (Commodities) VALUES (@List);

    -- Size
    SET @List = NULL
    SELECT @List = CASE WHEN CHARINDEX(prat_Name, ISNULL(@List, '') ) = 0 
					    THEN ISNULL(@List + ', ', '') + prat_Name 
					    ELSE @List 
			    END
    FROM PRCompanyCommodityAttribute WITH (NOLOCK), 
         PRAttribute WITH (NOLOCK),
         @Commodity
    WHERE prat_AttributeId = prcca_AttributeID
    AND prat_Type = 'SG'  -- Size
    AND (prcca_CompanyId IN (SELECT CompanyID FROM @CompanyIDs) OR prcca_CompanyId = @HQID)
    AND prcca_CommodityId = CommodityId
    AND (prcca_Publish = 'Y' OR prcca_PublishWithGM = 'Y')
    AND prcca_Deleted IS NULL;

    UPDATE @ReportTable SET SizeAttributes = @List;

    -- Style
    SET @List = NULL
    SELECT @List = CASE WHEN CHARINDEX(prat_Name, ISNULL(@List, '') ) = 0 
					    THEN ISNULL(@List + ', ', '') + prat_Name 
					    ELSE @List 
			    END
    FROM PRCompanyCommodityAttribute WITH (NOLOCK), 
        PRAttribute WITH (NOLOCK),
        @Commodity
    WHERE prat_AttributeId = prcca_AttributeID
    AND prat_Type = 'ST'  -- Style
    AND (prcca_CompanyId IN (SELECT CompanyID FROM @CompanyIDs) OR prcca_CompanyId = @HQID)
    AND prcca_CommodityId = CommodityId
    AND (prcca_Publish = 'Y' OR prcca_PublishWithGM = 'Y')
    AND prcca_Deleted IS NULL;

    UPDATE @ReportTable SET StyleAttributes = @List;

    -- Treatment
    SET @List = NULL
    SELECT @List = CASE WHEN CHARINDEX(prat_Name, ISNULL(@List, '') ) = 0 
					    THEN ISNULL(@List + ', ', '') + prat_Name 
					    ELSE @List 
			    END
    FROM PRCompanyCommodityAttribute WITH (NOLOCK), 
        PRAttribute WITH (NOLOCK),
        @Commodity
    WHERE prat_AttributeId = prcca_AttributeID
    AND prat_Type = 'TR'  -- Treament
    AND (prcca_CompanyId IN (SELECT CompanyID FROM @CompanyIDs) OR prcca_CompanyId = @HQID)
    AND prcca_CommodityId = CommodityId
    AND (prcca_Publish = 'Y' OR prcca_PublishWithGM = 'Y')
    AND prcca_Deleted IS NULL;

    UPDATE @ReportTable SET StorageAttributes = @List;


    -- Growing Method
    SET @List = NULL
    SELECT @List = CASE WHEN CHARINDEX(prat_Name, ISNULL(@List, '') ) = 0 
					    THEN ISNULL(@List + ', ', '') + prat_Name 
					    ELSE @List 
			    END
    FROM PRCompanyCommodityAttribute WITH (NOLOCK), 
        PRAttribute WITH (NOLOCK),
        @Commodity
    WHERE prat_AttributeId = prcca_GrowingMethodID
    --   AND prat_Type = 'GM'  -- Growing Method
    AND (prcca_CompanyId IN (SELECT CompanyID FROM @CompanyIDs) OR prcca_CompanyId = @HQID)
    AND prcca_CommodityId = CommodityId
    AND (prcca_Publish = 'Y' OR prcca_PublishWithGM = 'Y')
    AND prcca_Deleted IS NULL;

    UPDATE @ReportTable SET GrowingAttributes = @List;

    SELECT * FROM @ReportTable
END
GO   


IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'usp_BRBusinessProfileAccountTypes' AND Type='P') DROP PROCEDURE dbo.usp_BRBusinessProfileAccountTypes
GO
/**
Returns a list of account types
**/
CREATE PROCEDURE dbo.usp_BRBusinessProfileAccountTypes
	@CompanyID INT
AS  
BEGIN
    DECLARE @AccountTypes VARCHAR(255)
    DECLARE @List VARCHAR(2000)

    SELECT @AccountTypes = prcp_SellDomesticAccountTypes 
      FROM PRCompanyProfile WITH (NOLOCK) 
     WHERE prcp_CompanyId=dbo.ufn_BRGetHQID(@CompanyID);


    SELECT @List = COALESCE(@List + ', ', '') + CAST(Capt_US AS VARCHAR(50)) 
      FROM Custom_Captions WITH (NOLOCK)
     WHERE Capt_Family = 'prcp_SellDomesticAccountTypes'
       AND Capt_Code IN (SELECT value FROM dbo.Tokenize(@AccountTypes, ',')); 

    SELECT @List AS AccountTypes
END
GO

/**
Returns the financial information for the specified 
company.
**/
CREATE OR ALTER PROCEDURE dbo.usp_BRFinancialInformation
	@CompanyID INT,
	@ThresholdMonthsOld INT = 24,
	@ExcludeMonthsOld INT = 48,
	@ReportLevel INT = 3
AS  
BEGIN
    DECLARE @HQID INT
    SET @HQID = dbo.ufn_BRGetHQID(@CompanyID)

    DECLARE @FinancialCompanyID INT
    SET @FinancialCompanyID = dbo.ufn_BRGetFinancialCompanyID(@HQID)

	DECLARE @PRConfidentialFS char(40)
	SELECT @PRConfidentialFS=comp_PRConfidentialFS
	  FROM Company WITH (NOLOCK)
	 WHERE comp_CompanyId = @FinancialCompanyID

    DECLARE @Financials TABLE (
        StatementDate DATETIME,
        Type VARCHAR(40),
        InterimMonth VARCHAR(40),
        PreparationMethod VARCHAR(40),
        TotalCurrentAssets NUMERIC(24,6), 
        NetFixedAssets NUMERIC(24,6), 
        TotalOtherAssets NUMERIC(24,6), 
        TotalAssets NUMERIC(24,6),
        TotalCurrentLiabilities NUMERIC(24,6),
        TotalLongLiabilities NUMERIC(24,6),
        OtherMiscLiabilities NUMERIC(24,6),
        TotalEquity NUMERIC(24,6),
        WorkingCapital NUMERIC(24,6),
        CurrentRatio NUMERIC(24,6),
        QuickRatio NUMERIC(24,6),
        ARTurnover NUMERIC(24,6),
        DaysPayableOutstanding NUMERIC(24,6),
        DebtToEquity NUMERIC(24,6),
        FixedAssetsToNetWorth NUMERIC(24,6),
        DebtServiceAbility NUMERIC(24,6),
        OperatingRatio NUMERIC(24,6),
        NetProfitLoss VARCHAR(10)
    )

    -- Look for any statement within the threshold
    -- period
    DECLARE @MostRecentStatementDate DATETIME, @FilterDate DATETIME
    SELECT @MostRecentStatementDate = MAX(prfs_StatementDate) 
      FROM PRFinancial  WITH (NOLOCK) 
     WHERE prfs_CompanyId = @FinancialCompanyID 
       AND prfs_StatementDate > DATEADD(mm, 0 - @ThresholdMonthsOld, GETDATE());

    IF (@MostRecentStatementDate IS NOT NULL) BEGIN

	    IF (@ReportLevel >= 3) BEGIN
		    SET @FilterDate = DATEADD(mm, 0 - @ExcludeMonthsOld, @MostRecentStatementDate) 
	    END ELSE BEGIN
		    SET @FilterDate = @MostRecentStatementDate
	    END


	    INSERT INTO @Financials 
	    SELECT TOP 4 prfs_StatementDate, a.Capt_US AS Type, b.Capt_US AS InterimMonth, c.Capt_US AS PreparationMethod, prfs_TotalCurrentAssets, prfs_NetFixedAssets, prfs_TotalOtherAssets, 
		    prfs_TotalAssets, prfs_TotalCurrentLiabilities, prfs_TotalLongLiabilities, prfs_OtherMiscLiabilities, 
		    prfs_TotalEquity, prfs_WorkingCapital, prfs_CurrentRatio, prfs_QuickRatio, 
		    prfs_ARTurnover, prfs_DaysPayableOutstanding, prfs_DebtToEquity, prfs_FixedAssetsToNetWorth, 
		    prfs_DebtServiceAbility, prfs_OperatingRatio, prfs_NetProfitLoss
	    FROM  PRFinancial WITH (NOLOCK)  INNER JOIN
		    Company WITH (NOLOCK)  ON prfs_CompanyId = comp_CompanyID INNER JOIN
		    Custom_Captions a WITH (NOLOCK)  ON prfs_Type = a.Capt_Code AND a.Capt_Family = 'prfs_Type' INNER JOIN
		    Custom_Captions c WITH (NOLOCK)  ON prfs_PreparationMethod = c.Capt_Code AND c.Capt_Family = 'prfs_PreparationMethod' LEFT OUTER JOIN
		    Custom_Captions b WITH (NOLOCK)  ON prfs_InterimMonth = b.Capt_Code AND b.Capt_Family = 'prfs_InterimMonth'
	    WHERE  prfs_CompanyId = @FinancialCompanyID
	    AND  prfs_Publish = 'Y'
	    AND  prfs_StatementDate >= @FilterDate
	    AND  prfs_Deleted IS NULL
	    AND  prfs_EntryStatus = 'F' -- Full
	    AND  comp_PRConfidentialFS <> '2'
	    AND  Comp_Deleted IS NULL;
    END

    SELECT * FROM (
    SELECT StatementDate, Type, InterimMonth, PreparationMethod, 'C' AS 'DataType', 'Current Assets' AS 'Property', CONVERT(SQL_VARIANT, TotalCurrentAssets) AS 'Value' FROM @Financials
    UNION ALL
    SELECT StatementDate, Type, InterimMonth, PreparationMethod, 'C', 'Net Fixed Assets', CONVERT(SQL_VARIANT, NetFixedAssets) FROM @Financials
    UNION ALL
    SELECT StatementDate, Type, InterimMonth, PreparationMethod, 'C', 'Other Assets', CONVERT(SQL_VARIANT, TotalOtherAssets) FROM @Financials
    UNION ALL
    SELECT StatementDate, Type, InterimMonth, PreparationMethod, 'C', 'Total Assets', CONVERT(SQL_VARIANT, TotalAssets) FROM @Financials
    UNION ALL
    SELECT StatementDate, Type, InterimMonth, PreparationMethod, 'F', '   ', NULL FROM @Financials
    UNION ALL
    SELECT StatementDate, Type, InterimMonth, PreparationMethod, 'C', 'Current Liabilities', CONVERT(SQL_VARIANT, TotalCurrentLiabilities) FROM @Financials
    UNION ALL
    SELECT StatementDate, Type, InterimMonth, PreparationMethod, 'C', 'Long-Term Liabilities',  CONVERT(SQL_VARIANT, TotalLongLiabilities) FROM @Financials
    UNION ALL
    SELECT StatementDate, Type, InterimMonth, PreparationMethod, 'C', 'Other Liabilities', CONVERT(SQL_VARIANT, OtherMiscLiabilities) FROM @Financials
    UNION ALL
    SELECT StatementDate, Type, InterimMonth, PreparationMethod, 'C', 'Equity', CONVERT(SQL_VARIANT, TotalEquity) FROM @Financials
    UNION ALL
    SELECT StatementDate, Type, InterimMonth, PreparationMethod, 'F', '         ', NULL FROM @Financials
    UNION ALL
    SELECT StatementDate, Type, InterimMonth, PreparationMethod, 'C', 'Working Capital', CONVERT(SQL_VARIANT, WorkingCapital) FROM @Financials
    UNION ALL
    SELECT StatementDate, Type, InterimMonth, PreparationMethod, 'R', 'Current Ratio', CONVERT(SQL_VARIANT, CurrentRatio) FROM @Financials
    UNION ALL
    SELECT StatementDate, Type, InterimMonth, PreparationMethod, 'R', 'Quick Ratio', CONVERT(SQL_VARIANT, QuickRatio) FROM @Financials
    UNION ALL
    SELECT StatementDate, Type, InterimMonth, PreparationMethod, 'R', 'Account Receivable Turnover', CONVERT(SQL_VARIANT, ARTurnover) FROM @Financials
    UNION ALL
    SELECT StatementDate, Type, InterimMonth, PreparationMethod, 'R', 'Days Payable Outstanding', CONVERT(SQL_VARIANT, DaysPayableOutstanding) FROM @Financials
    UNION ALL
    SELECT StatementDate, Type, InterimMonth, PreparationMethod, 'R', 'Debt To Equity', CONVERT(SQL_VARIANT, DebtToEquity) FROM @Financials
    UNION ALL
    SELECT StatementDate, Type, InterimMonth, PreparationMethod, 'R', 'Fixed Assets to Equity', CONVERT(SQL_VARIANT, FixedAssetsToNetWorth) FROM @Financials
    UNION ALL
    SELECT StatementDate, Type, InterimMonth, PreparationMethod, 'R', 'Debt Service Ability', CONVERT(SQL_VARIANT, DebtServiceAbility) FROM @Financials
    UNION ALL
    SELECT StatementDate, Type, InterimMonth, PreparationMethod, 'R', 'Operating Ratio', CONVERT(SQL_VARIANT, OperatingRatio) FROM @Financials
    UNION ALL
    SELECT StatementDate, Type, InterimMonth, PreparationMethod, 'S', 'Net Profit/Loss', CONVERT(SQL_VARIANT, NetProfitLoss) FROM @Financials
    ) T1
	WHERE DataType = CASE @PRConfidentialFS WHEN '1' THEN 'R' WHEN '2' THEN 'X' WHEN '3' THEN DataType END
	   OR DataType = CASE @PRConfidentialFS WHEN '1' THEN 'S' WHEN '2' THEN 'X' WHEN '3' THEN DataType END
    Order BY StatementDate DESC
END
GO

/**
Returns the trade report summary data for the specified 
company and branches
**/
CREATE OR ALTER PROCEDURE dbo.usp_BRFinancialInformationFlags
	@CompanyID int,
	@ThresholdMonthsOld int = 24,
	@ExcludeMonthsOld int = 48
AS  
BEGIN

    DECLARE @ReportTable table (
	    RecordCount int,
	    IsMostRecentOlderThreshold char(1) DEFAULT 'N',
	    IsMostRecentOlderExclusionThreshold char(1) DEFAULT 'N',
	    IsConfidential char(1) DEFAULT '2',
	    IsCreditWorth150 char(1) DEFAULT 'N',
	    MostRecentDate datetime,
	    [Type] varchar(40),
	    HowPrepared varchar(40),
	    InterimMonth varchar(40),
	    Analysis varchar(max),
		IsForParentCompany char(1) DEFAULT 'N'
    )
    	
    DECLARE @HQID int = dbo.ufn_BRGetHQID(@CompanyID)	
    DECLARE @FinancialCompanyID int = dbo.ufn_BRGetFinancialCompanyID(@HQID)

    INSERT INTO @ReportTable (IsConfidential)
    SELECT comp_PRConfidentialFS
      FROM Company WITH (NOLOCK) 
     WHERE comp_CompanyID = @FinancialCompanyID 
       AND Comp_Deleted IS NULL  
       
    UPDATE @ReportTable 
    SET RecordCount = T1.Count, 
        MostRecentDate = T1.prfs_StatementDate 
    FROM(SELECT COUNT(1) AS COUNT, MAX(prfs_StatementDate) AS prfs_StatementDate
           FROM PRFinancial WITH (NOLOCK) 
          WHERE prfs_CompanyId = @FinancialCompanyID
            AND prfs_Deleted IS NULL
            AND prfs_Publish = 'Y'
        HAVING COUNT(1) > 0) T1

    DECLARE @MostRecentDate DATETIME
    SELECT @MostRecentDate = MostRecentDate FROM @ReportTable;

	IF (@MostRecentDate IS NULL)
		UPDATE @ReportTable SET IsConfidential = '2'

    IF (@MostRecentDate < DATEADD(mm, 0-@ExcludeMonthsOld, GETDATE())) BEGIN
	    UPDATE @ReportTable SET RecordCount = 0, IsMostRecentOlderExclusionThreshold = 'Y'
    END ELSE BEGIN
	    IF (@MostRecentDate < DATEADD(mm, 0-@ThresholdMonthsOld, GETDATE())) BEGIN
		    UPDATE @ReportTable SET IsMostRecentOlderThreshold = 'Y'
	    END
    END
    -- Modifying this function to use @HQId instead of @FinancialCompanyID.  The credit worth flag must be set
    -- for the company actually being viewed
    UPDATE @ReportTable SET IsCreditWorth150 = T1.CreditRating
    FROM (
    SELECT CASE WHEN COUNT(1) > 0 THEN 'Y' ELSE 'N' END AS 'CreditRating'
      FROM PRRating WITH (NOLOCK) 
     WHERE prra_CompanyId = @HQID
       AND prra_CreditWorthId = 9 -- (150)
       AND prra_Current = 'Y'
       AND prra_Deleted IS NULL) T1;
       
    UPDATE @ReportTable 
    SET Analysis = T1.prfs_Analysis,
        Type = T1.Type,
        HowPrepared = T1.PreparationMethod,
        InterimMonth = T1.InterimMonth
    --       RecordCount = 0
    FROM (SELECT prfs_Analysis, a.Capt_US AS Type, b.Capt_US AS InterimMonth, c.Capt_US AS PreparationMethod
		    FROM PRFinancial WITH (NOLOCK)  INNER JOIN
			     Company WITH (NOLOCK)  ON prfs_CompanyId = comp_CompanyID INNER JOIN
			     Custom_Captions a WITH (NOLOCK)  ON prfs_Type = a.Capt_Code AND a.Capt_Family = 'prfs_Type' INNER JOIN
			     Custom_Captions c WITH (NOLOCK)  ON prfs_PreparationMethod = c.Capt_Code AND c.Capt_Family = 'prfs_PreparationMethod' LEFT OUTER JOIN
			     Custom_Captions b WITH (NOLOCK)  ON prfs_InterimMonth = b.Capt_Code AND b.Capt_Family = 'prfs_InterimMonth'
           WHERE prfs_CompanyId = @FinancialCompanyID
             AND prfs_Deleted IS NULL
             AND comp_CompanyID = prfs_CompanyId 
             AND comp_Deleted IS NULL
             AND prfs_StatementDate = @MostRecentDate) T1;


	IF (@HQID <> @FinancialCompanyID) BEGIN
		UPDATE @ReportTable 
		   SET IsForParentCompany = 'Y'
	END

    DECLARE @Count INT
    SELECT @Count = COUNT(1) FROM @ReportTable;

    -- If we don't have any records from
    -- create a dummy record
    IF (@Count = 0) BEGIN
	    INSERT INTO @ReportTable (RecordCount) VALUES (0);
    END

    SELECT * FROM @ReportTable;
END
GO

IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'ufn_BRGetFinancialCompanyID' AND Type='FN') DROP FUNCTION dbo.ufn_BRGetFinancialCompanyID
GO

CREATE FUNCTION dbo.ufn_BRGetFinancialCompanyID(@HQID INT)  
RETURNS INT AS  
BEGIN 
    DECLARE @Count INT

    -- First check is for a credit
    -- worth rating of 150
    SELECT @Count = COUNT(1)
    FROM PRRating
    WHERE prra_CompanyId = @HQID
    AND prra_CreditWorthId = 9 -- (150)
    AND prra_Current = 'Y'
    AND prra_Deleted IS NULL;

    IF (@Count > 0) BEGIN

        -- Second check is for a parent company
        -- with > 50 ownership
        DECLARE @LeftCompanyID INT

        SELECT @LeftCompanyID = ISNULL(prcr_LeftCompanyID, 0)
          FROM PRCompanyRelationship WITH (NOLOCK) 
         WHERE prcr_RightCompanyID = @HQID
           AND (prcr_Type = '27' OR (prcr_Type = '28' AND ISNULL(prcr_OwnershipPct, 0) > 50) ) 
           AND prcr_Active = 'Y';

        -- If we found someone, go get thier
        -- finanial info...
        IF @LeftCompanyID IS NOT NULL BEGIN
		    RETURN @LeftCompanyID
	    END
    END

    RETURN @HQID

    END 
GO 

IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'ufn_BRGetCompanyRootClassifications') DROP FUNCTION dbo.ufn_BRGetCompanyRootClassifications
GO
/**
 Returns the root classification ID for the specified company.
**/
CREATE FUNCTION dbo.ufn_BRGetCompanyRootClassifications(@CompanyID INT)  
RETURNS @RootClassifications TABLE 
(
	ClassificationID INT,
	Name VARCHAR(100)
)
AS 
BEGIN 
    -- Go find our RootIDs.  This query is making a HUGE
    -- assumption in that our Root ID will always be < 10.
    INSERT INTO @RootClassifications (ClassificationID)
    SELECT DISTINCT SUBSTRING(prcl_Path, 1, 1)
      FROM PRClassification a WITH (NOLOCK) , 
           PRCompanyClassification b WITH (NOLOCK) 
     WHERE a.prcl_ClassificationId = b. prc2_ClassificationId
       AND b.prc2_CompanyId = @CompanyID; 

    -- Now that we have our root IDs, go get the names.
    UPDATE @RootClassifications
    SET Name = prcl_Name
    FROM PRClassification WITH (NOLOCK) 
    WHERE ClassificationID = prcl_ClassificationId;

    RETURN
END 
GO

IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'ufn_BRGetHQID' AND Type='FN') DROP FUNCTION dbo.ufn_BRGetHQID
GO

/**
Returns the ID of the headquarters company.  The same value is returned
if the company ID specified is for the headquarters.
**/
CREATE FUNCTION dbo.ufn_BRGetHQID(@CompanyID INT)  
RETURNS INT AS  
BEGIN 
    DECLARE @HQID INT;

    -- Do we have a headquarters?
    SELECT @HQID = comp_PRHQId 
      FROM Company WITH (NOLOCK)
     WHERE comp_CompanyID=@CompanyID 
       AND Comp_Deleted IS NULL;
       
    RETURN ISNULL(@HQID, @CompanyID)
END 
GO


IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'usp_BRPeople' AND Type='P') DROP PROCEDURE dbo.usp_BRPeople
GO
/**
Returns the people associated with the current company.
**/
CREATE PROCEDURE dbo.usp_BRPeople
	@CompanyID INT
AS 
BEGIN
    DECLARE @HQID INT
    SET @HQID = dbo.ufn_BRGetHQID(@CompanyID);

    SELECT pers_PersonID, dbo.ufn_FormatPerson(Pers_FirstName, Pers_LastName, Pers_MiddleName, pers_PRNickname1, Pers_Suffix) AS PersonName, peli_PRTitle, peli_PRTitleCode, Capt_Order AS Sort, pers_PRYearBorn, pers_PRIndustryStartDate
      FROM Person_Link  WITH (NOLOCK) 
           INNER JOIN Person WITH (NOLOCK)  ON PeLi_PersonId = pers_PersonID
           INNER JOIN Custom_Captions WITH (NOLOCK)  ON peli_PRTitleCode = Capt_Code AND Capt_Family = 'pers_TitleCode'
     WHERE PeLi_PersonId IN (SELECT * FROM dbo.ufn_BRGetPeopleIDs(@HQID))
       AND peli_PRStatus IN (1,2)
       AND PeLi_CompanyID = @HQID
  Order BY sort, Pers_LastName, Pers_FirstName;
END
GO


IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'usp_BRPeopleCount' AND Type='P') DROP PROCEDURE dbo.usp_BRPeopleCount
GO

/**
Returns the count of people associated with the current company.
**/
CREATE PROCEDURE dbo.usp_BRPeopleCount
	@CompanyID INT
AS 
BEGIN
    DECLARE @HQID INT
    SET @HQID = dbo.ufn_BRGetHQID(@CompanyID);

    SELECT COUNT(1) AS COUNT
      FROM Person_Link WITH (NOLOCK) 
     WHERE PeLi_PersonId IN (SELECT * FROM dbo.ufn_BRGetPeopleIDs(@HQID))
       AND PeLi_CompanyID = @HQID
       AND peli_PRBRPublish = 'Y'
       AND PeLi_Deleted IS NULL;
END
GO




IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'usp_BRPeopleBackground' AND Type='P') DROP PROCEDURE dbo.usp_BRPeopleBackground
GO

/**
Returns the background information for the specified person.
**/
CREATE PROCEDURE dbo.usp_BRPeopleBackground
	@PersonID INT
AS 
BEGIN
    SELECT * FROM (
    SELECT DISTINCT PeLi_PersonId AS PersonID, peli_PRStartDate AS StartDate, peli_PREndDate AS EndDate, 
	       peli_PRTitle AS Title, peli_PRResponsibilities AS Responsibilities, comp_PRCorrTradestyle AS CompanyName, 
	       prci_City AS CITY, prst_State AS STATE, prcn_Country AS COUNTRY, peli_PRStatus,
	       dbo.ufn_BRGetPersonBackgroundDate(peli_PRStartDate, peli_PREndDate, peli_PRStatus)  AS BackgroundDates,
	       CityStateCountryShort AS ListingLocation
      FROM Person_Link WITH (NOLOCK) 
           INNER JOIN Company WITH (NOLOCK)  ON PeLi_CompanyID = comp_CompanyID 
           INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID 
     WHERE PeLi_PersonId = @PersonId
       AND PeLi_Deleted IS NULL
       AND PeLi_CompanyID NOT IN (SELECT prc2_CompanyId FROM PRCompanyClassification WHERE prc2_ClassificationId = 1930)
    UNION
    SELECT prba_PersonId, prba_StartDate, prba_EndDate, prba_Title, NULL, prba_Company, NULL, NULL, NULL, '3',
	       dbo.ufn_BRGetPersonBackgroundDate(prba_StartDate, prba_EndDate, '3')  AS BackgroundDates,
	       NULL
      FROM PRPersonBackground WITH (NOLOCK) 
     WHERE prba_PersonId = @PersonID
       AND prba_Deleted IS NULL
    ) T1
    Order BY ISNULL(EndDate, 'Current') DESC, StartDate DESC, CompanyName
END
GO


IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'usp_BRPeopleBackgroundCount' AND Type='P') DROP PROCEDURE dbo.usp_BRPeopleBackgroundCount
GO

/**
Returns the background information for the specified person.
**/
CREATE PROCEDURE dbo.usp_BRPeopleBackgroundCount
	@PersonID INT
AS 
BEGIN
    SELECT COUNT(1) AS COUNT FROM (
    SELECT PeLi_PersonId
      FROM Person_Link WITH (NOLOCK) 
     WHERE PeLi_PersonId = @PersonId
       AND PeLi_Deleted IS NULL
       AND PeLi_CompanyID NOT IN (SELECT prc2_CompanyId FROM PRCompanyClassification WHERE prc2_ClassificationId = 1930)
    UNION
    SELECT prba_PersonId
      FROM PRPersonBackground WITH (NOLOCK) 
     WHERE prba_PersonId = @PersonID
       AND prba_Deleted IS NULL
    ) T1
END
GO

IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'usp_BRPeopleEvents' AND Type='P') DROP PROCEDURE dbo.usp_BRPeopleEvents
GO
/**
Returns the person event data for the specified person.
and types.
**/
CREATE PROCEDURE dbo.usp_BRPeopleEvents
	@PersonID INT,
	@DaysOldStart INT = 0,
	@DaysOldEnd INT = 999999
AS 
BEGIN

    SELECT prpe_PersonEventId, prpe_PersonEventTypeId, prpe_DisplayedEffectiveDate, dbo.ufn_GetPersonEventText(prpe_PersonEventId) AS EventText
      FROM PRPersonEvent WITH (NOLOCK) 
     WHERE prpe_PersonId = @PersonID
       AND prpe_PublishUntilDate > GETDATE()
       AND DATEDIFF(DAY, prpe_Date, GETDATE()) BETWEEN @DaysOldStart AND @DaysOldEnd
       AND prpe_Deleted IS NULL
  Order BY prpe_Date DESC;

END
GO



IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'ufn_BRGetTitleSortCode' AND Type='FN') DROP FUNCTION dbo.ufn_BRGetTitleSortCode
GO


IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'ufn_BRGetPeopleIDs' AND Type='TF') DROP FUNCTION dbo.ufn_BRGetPeopleIDs
GO

 /**
  Function used to determine which People should be included in 
  the various Business Report People queries.
**/
CREATE FUNCTION dbo.ufn_BRGetPeopleIDs(@CompanyID INT)  
RETURNS @PersonTable TABLE (PersonID INT) AS  
BEGIN 

	INSERT INTO @PersonTable 
	SELECT PeLi_PersonId
	  FROM Person_Link WITH (NOLOCK) 
	 WHERE peli_PRStatus IN ('1', '2')
	   AND peli_PRBRPublish = 'Y'
	   AND PeLi_CompanyID = @CompanyID
	   AND PeLi_Deleted IS NULL

	RETURN
END
GO 



IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'usp_BRPeopleText' AND Type='P') DROP PROCEDURE dbo.usp_BRPeopleText
GO

/**
Returns the business report event text that replaces
the other person information.
**/
CREATE PROCEDURE dbo.usp_BRPeopleText
	@CompanyID INT
AS 
BEGIN
    SELECT comp_PRBusinessReport, comp_PRPrincipalsBackgroundText
      FROM Company WITH (NOLOCK) 
     WHERE comp_CompanyID = dbo.ufn_BRGetHQID(@CompanyID);
END
GO




IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'usp_BRRatings' AND Type='P') DROP PROCEDURE dbo.usp_BRRatings
GO

/**
Returns the rating data for the specified company
**/
CREATE PROCEDURE dbo.usp_BRRatings
	@CompanyID INT
AS 
BEGIN
    DECLARE @ReportTable TABLE (
        RatingID INT,
        RatingDate DATETIME,
        [CURRENT] CHAR(1),
        RatingLine VARCHAR(50),
        RatingAnalysis text,
        TMFMAward VARCHAR(50)
    )

    DECLARE @HQID INT
    SET @HQID = dbo.ufn_BRGetHQID(@CompanyID);

    DECLARE @PreviousRatingID INT
    SELECT @PreviousRatingID = ISNULL(MAX(prra_RatingId), 0)
      FROM PRRating WITH (NOLOCK) 
     WHERE prra_CompanyId = @HQID
       AND prra_Deleted IS NULL
       AND prra_Current IS NULL;


    -- Go get our various rating records
    INSERT INTO @ReportTable
    SELECT prra_RatingId, prra_Date, prra_Current, prra_RatingLine, prra_PublishedAnalysis, dbo.ufn_BRIsAwardMember(comp_PRTMFMAward, comp_PRTMFMAwardDate, comp_PRIndustryType) AS TMFMAward
      FROM Company WITH (NOLOCK)
           INNER JOIN vPRCompanyRating ON comp_CompanyID = prra_CompanyId
     WHERE comp_CompanyID = @HQID
       AND prra_Deleted IS NULL
       AND ((DATEDIFF(YEAR, prra_Date, GETDATE()) <= 10) 
            OR (prra_Current = 'Y') 
            OR prra_RatingId=@PreviousRatingID);

    SELECT * FROM @ReportTable Order BY [CURRENT] DESC, RatingDate DESC;
END
GO 


IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'usp_BRRatingsDefinitions' AND Type='P') DROP PROCEDURE dbo.usp_BRRatingsDefinitions
GO

/**
Returns the rating data definitions for the specified company
**/
CREATE PROCEDURE dbo.usp_BRRatingsDefinitions
	@CompanyID INT
AS 
BEGIN

    DECLARE @ReportTable TABLE (
        Name VARCHAR(10),
        Description VARCHAR(500)
    )

    DECLARE @HQID INT
    SET @HQID = dbo.ufn_BRGetHQID(@CompanyID);

    -- Credit Worth Rating
    INSERT INTO @ReportTable
    SELECT DISTINCT prcw_Name AS Credit, CAST(cc.capt_US AS VARCHAR(500))
      FROM PRRating WITH (NOLOCK)
           INNER JOIN PRCreditWorthRating WITH (NOLOCK) ON prra_CreditWorthId = prcw_CreditWorthRatingId
           INNER JOIN Custom_Captions cc WITH (NOLOCK) ON Capt_FamilyType = 'Choices' AND Capt_Family = 'prcw_Name' AND Capt_Code = prcw_Name
     WHERE prra_CompanyId = @HQID
       AND prra_Current = 'Y'
       AND prra_Deleted IS NULL;

    -- Integrity Rating
    INSERT INTO @ReportTable
    SELECT DISTINCT prin_Name AS Integrity, CAST(Capt_US AS VARCHAR(500))
      FROM PRRating WITH (NOLOCK)
           INNER JOIN PRIntegrityRating  WITH (NOLOCK) ON prra_IntegrityId = prin_IntegrityRatingId
           INNER JOIN Custom_Captions cc  WITH (NOLOCK) ON Capt_FamilyType = 'Choices' AND Capt_Family = 'prin_Name' AND Capt_Code = prin_Name
     WHERE prra_CompanyId = @HQID
       AND prra_Current = 'Y'
       AND prra_Deleted IS NULL;

    -- Rating Numerals
    INSERT INTO @ReportTable
    SELECT DISTINCT prrn_Name, CAST(Capt_US AS VARCHAR(500))
      FROM PRRatingNumeralAssigned WITH (NOLOCK)
           INNER JOIN PRRatingNumeral WITH (NOLOCK) ON pran_RatingNumeralId = prrn_RatingNumeralId 
           INNER JOIN PRRating WITH (NOLOCK) ON pran_RatingId = prra_RatingId 
           INNER JOIN Custom_Captions cc WITH (NOLOCK) ON Capt_FamilyType = 'Choices' AND Capt_Family = 'prrn_Name' AND Capt_Code = prrn_Name
     WHERE prra_CompanyId = @HQID
       AND prra_Current = 'Y'
       AND prra_Deleted IS NULL;

    -- Pay Rating
    INSERT INTO @ReportTable
    SELECT DISTINCT prpy_Name AS PayRating, CAST(Capt_US AS VARCHAR(500))
      FROM PRRating  WITH (NOLOCK)
           INNER JOIN PRPayRating WITH (NOLOCK) ON prra_PayRatingId = prpy_PayRatingId
           INNER JOIN Custom_Captions cc WITH (NOLOCK) ON Capt_FamilyType = 'Choices' AND Capt_Family = 'prpy_Name' AND Capt_Code = prpy_Name
     WHERE prra_CompanyId = @HQID
       AND prra_Current = 'Y'
       AND prra_Deleted IS NULL;

    SELECT * FROM @ReportTable;
END
GO


IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'usp_BRRatingCount' AND Type='P') DROP PROCEDURE dbo.usp_BRRatingCount
GO

/**
Returns count of the rating data for the specified company
**/
CREATE PROCEDURE dbo.usp_BRRatingCount
	@CompanyID INT
AS 
BEGIN
    DECLARE @PreviousRatingID INT
    SELECT @PreviousRatingID = ISNULL(MAX(prra_RatingId), 0)
      FROM PRRating WITH (NOLOCK)
     WHERE prra_CompanyId = dbo.ufn_BRGetHQID(@CompanyID)
       AND prra_Deleted IS NULL
       AND prra_Current IS NULL;


    SELECT COUNT(1) AS COUNT
      FROM vPRCompanyRating
     WHERE prra_CompanyId = dbo.ufn_BRGetHQID(@CompanyID)
       AND prra_Deleted IS NULL
       AND ((DATEDIFF(YEAR, prra_Date, GETDATE()) <= 10) OR (prra_Current = 'Y') OR prra_RatingId = @PreviousRatingID)
END
GO

IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'usp_BRRatingCountAll' AND Type='P') DROP PROCEDURE dbo.usp_BRRatingCountAll
GO

/**
Returns count of the rating data for the specified company
**/
CREATE PROCEDURE dbo.usp_BRRatingCountAll
	@CompanyID INT
AS 
BEGIN
    SELECT COUNT(1) AS COUNT
      FROM vPRCompanyRating
     WHERE prra_CompanyId = dbo.ufn_BRGetHQID(@CompanyID)
       AND prra_Deleted IS NULL;
END
GO

IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'usp_BRTradeReportDetails' AND Type='P') DROP PROCEDURE dbo.usp_BRTradeReportDetails
GO

/**
Returns the trade report detail data for the specified 
company and branches.
**/
CREATE PROCEDURE dbo.usp_BRTradeReportDetails
	@CompanyID INT,
	@MonthsOld INT = 18
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
    FROM Company
    WHERE (comp_PRHQId = @HQID OR comp_CompanyID = @HQID)
    AND Comp_Deleted IS NULL;
    DECLARE @ReportTable TABLE (
        TradeReportID INT,
        CompanyID INT,
        ReportDate DATETIME,
        LastDealtDate VARCHAR(255),
        IntegrityRating VARCHAR(255),
        PayRating VARCHAR(255),
        HighCredit VARCHAR(255),
        CreditTerms VARCHAR(255),
		ResponderIndustryType CHAR(1),
        Footnote varchar(5),
		Footnote2 varchar(5),
		ResponderID INT
    )
    INSERT INTO @ReportTable (TradeReportID, CompanyID, ReportDate, LastDealtDate, IntegrityRating, PayRating, HighCredit, CreditTerms, ResponderIndustryType, Footnote, Footnote2, ResponderID)
    SELECT TOP 100 prtr_TradeReportId, prtr_SubjectId, prtr_Date, CC3.Capt_US AS LastDealtDate, prin_TradeReportDescription, prpy_TradeReportDescription, CC1.Capt_US AS HighCredit, CC2.Capt_US AS CreditTerms
		    ,comp_PRIndustryType, NULL, NULL, prtr_ResponderId 
      FROM PRTradeReport WITH (NOLOCK) INNER JOIN
  	    Company WITH (NOLOCK) ON comp_CompanyID = prtr_ResponderId AND comp_PRIgnoreTES IS NULL LEFT OUTER JOIN
        Custom_Captions CC1 WITH (NOLOCK) ON PRTradeReport.prtr_HighCredit = CC1.Capt_Code AND CC1.Capt_Family = 'prtr_HighCredit' LEFT OUTER JOIN
        Custom_Captions CC2 WITH (NOLOCK) ON PRTradeReport.prtr_CreditTerms = CC2.Capt_Code AND CC2.Capt_Family = 'prtr_CreditTerms' LEFT OUTER JOIN
        Custom_Captions CC3 WITH (NOLOCK) ON PRTradeReport.prtr_LastDealtDate = CC3.Capt_Code AND CC3.Capt_Family = 'prtr_LastDealtDate' LEFT OUTER JOIN
        PRPayRating WITH (NOLOCK) ON PRTradeReport.prtr_PayRatingId = PRPayRating.prpy_PayRatingId LEFT OUTER JOIN
        PRIntegrityRating WITH (NOLOCK) ON PRTradeReport.prtr_IntegrityId = PRIntegrityRating.prin_IntegrityRatingId
    WHERE PRTradeReport.prtr_SubjectId IN (SELECT CompanyID FROM @CompanyIDs)
      AND prtr_Date >= DATEADD(mm, 0 - @MonthsOld, GETDATE()) 
    --AND prtr_DisputeInvolved IS NULL
      AND prtr_Duplicate IS NULL
      AND prtr_Deleted IS NULL
	  AND prtr_ExcludeFromAnalysis IS NULL
    Order BY prtr_Date DESC;
    -- Go get our company and it's branches
    DECLARE @Footnotes TABLE (
	    CompanyID INT,
	    Footnote INT IDENTITY(1,1)
    )
    INSERT INTO @Footnotes
    SELECT DISTINCT CompanyID
      FROM @ReportTable
     WHERE CompanyID <> @HQID
  Order BY CompanyID;
		
		--Footnotes 1
    UPDATE @ReportTable
       SET Footnote = a.Footnote
      FROM @Footnotes a, @ReportTable b
     WHERE a.CompanyID = b.CompanyID;

	-- Footnotes 2 - Check for multiple TES responses
	DECLARE @Footnotes2 TABLE (
		ResponderID INT,
		ResponseCount INT,
		Footnote INT IDENTITY(1,1) 
    )
    INSERT INTO @Footnotes2
    SELECT ResponderID,COUNT(*)
      FROM @ReportTable
		 GROUP BY ResponderID
		 HAVING COUNT(*) > 1

		 UPDATE @ReportTable
			SET Footnote2 = a.Footnote
			FROM @Footnotes2 a, @ReportTable b
			WHERE a.ResponderID = b.ResponderID

    SELECT * FROM @ReportTable Order BY ReportDate DESC;
END
GO

IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'usp_BRTradeReportDetailsFootNotes' AND Type='P') DROP PROCEDURE dbo.usp_BRTradeReportDetailsFootNotes
GO
/**
Returns the trade report detail data for the specified 
company and branches.
**/
CREATE PROCEDURE dbo.usp_BRTradeReportDetailsFootNotes
	@CompanyID INT,
	@MonthsOld INT = 18
AS  
BEGIN
DECLARE @ReportTable TABLE (
        TradeReportID INT,
        CompanyID INT,
        ReportDate DATETIME,
        LastDealtDate VARCHAR(255),
        IntegrityRating VARCHAR(255),
        PayRating VARCHAR(255),
        HighCredit VARCHAR(255),
        CreditTerms VARCHAR(255),
		ResponderIndustryType CHAR(1),
        Footnote varchar(5),
		Footnote2 varchar(5),
		ResponderID INT)

INSERT INTO @ReportTable
EXEC usp_BRTradeReportDetails @CompanyID

SELECT DISTINCT a.Footnote, a.Footnote2Char [Footnote2], a.ResponderID, a.CompanyID, vprl.CityStateCountryShort [ListingLocation]
FROM (
SELECT *, CHAR(Footnote2+96) [Footnote2Char] FROM @ReportTable WHERE Footnote IS NOT NULL OR Footnote2 IS NOT NULL) a
	INNER JOIN Company c ON c.comp_companyid	= a.CompanyID
	INNER JOIN vPRLocation vprl ON vprl.prci_CityID = c.comp_PRListingCityID
	
END
GO




IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'usp_BRTradeReportSummary' AND Type='P') 
	DROP PROCEDURE dbo.usp_BRTradeReportSummary
GO

/**
Returns the trade report summary data for the specified 
company and branches
**/
CREATE PROCEDURE dbo.usp_BRTradeReportSummary
	@CompanyID INT,
	@YearsOld INT = 3
AS  
BEGIN
	DECLARE @HQID INT = dbo.ufn_BRGetHQID(@CompanyID)

	DECLARE @YearCount int = 0
	DECLARE @Years TABLE (Yr int);
	
	WHILE (@YearCount < @YearsOld) BEGIN
		INSERT INTO @Years SELECT YEAR(DATEADD(yy, 0-@YearCount, GETDATE()));
		SET @YearCount = @YearCount +1
	END

	DECLARE @ReportTable TABLE (
		GraphType int,
		ReportYear int,
		RatingDescription varchar(50),
		RatingSubdescription varchar(50),
		SortOrder int,
		Cnt int,
		Type1Count int,
		Type2Count int,
		YearRatingTotal int
	)

	--Integrity Data
	INSERT INTO @ReportTable (GraphType, ReportYear, RatingDescription, RatingSubdescription, SortOrder, Cnt)
	SELECT 1,
		   Yr,
		   prin_TradeReportDescription,
		   CASE prin_TradeReportDescription 
		        WHEN N'XXXX' THEN N' (excellent)'
				WHEN N'XXX' THEN N' (good)'
				WHEN N'XX' THEN N' (fair)'
				WHEN N'X' THEN N' (poor)' END,
		   prin_Order,
		   COUNT(prtr_TradeReportId)
	  FROM
			--Get all possible combinations of PRIN and Year 
			(SELECT Yr, prin_IntegrityRatingId, prin_Order, prin_Weight
				, prin_TradeReportDescription, prin_IsNumeral, prin_Deleted
			FROM @Years
			CROSS JOIN PRIntegrityRating WITH (NOLOCK)
			) TableA
	LEFT OUTER JOIN Company WITH (NOLOCK) ON comp_PRHQId = @HQID
	LEFT OUTER JOIN PRTradeReport WITH (NOLOCK)ON prin_IntegrityRatingId = prtr_IntegrityId
		AND	YEAR(prtr_Date) = Yr
		AND prtr_SubjectId = comp_CompanyID
		AND prtr_Duplicate IS NULL
		AND prtr_ExcludeFromAnalysis IS NULL
	LEFT OUTER JOIN (SELECT comp_CompanyId, comp_PRIgnoreTES FROM Company WITH (NOLOCK)) T1 ON T1.comp_CompanyID = prtr_ResponderId 
	WHERE 
		prin_IsNumeral IS NULL
		AND prin_Deleted IS NULL
		AND T1.comp_PRIgnoreTES IS NULL
	GROUP BY Yr,  
	         prin_TradeReportDescription,
			CASE prin_TradeReportDescription 
				WHEN 'XXXX' THEN '(excellent)'
				WHEN 'XXX' THEN '(good)'
				WHEN 'XX' THEN '(fair)'
				WHEN 'X' THEN '(poor)' END,
		   prin_Order
	ORDER BY prin_Order, yr DESC;

	-- Pay Data
	INSERT INTO @ReportTable (GraphType, ReportYear, RatingDescription, SortOrder, Cnt)
	SELECT 
		2
		, Yr
		, prpy_TradeReportDescription
		, prpy_Order
		, COUNT(prtr_TradeReportId)
	FROM 
		--Go get all combos of Year and Pay Ratings
		(SELECT Yr, prpy_PayRatingId, prpy_Order, prpy_IsNumeral
			, prpy_TradeReportDescription , prpy_Deleted  
		FROM @Years
		CROSS JOIN PRPayRating WITH (NOLOCK)
		) TableA
	LEFT OUTER JOIN Company WITH (NOLOCK) ON comp_PRHQId = @HQID
	LEFT OUTER JOIN PRTradeReport WITH (NOLOCK)ON prpy_PayRatingId = prtr_PayRatingId
		AND	YEAR(prtr_Date) = Yr
		AND prtr_SubjectId = comp_CompanyID
		AND prtr_Duplicate IS NULL
		AND prtr_ExcludeFromAnalysis IS NULL
	LEFT OUTER JOIN (SELECT comp_CompanyId, comp_PRIgnoreTES FROM Company WITH (NOLOCK)) T1 ON T1.comp_CompanyID = prtr_ResponderId 
	WHERE 
		prpy_IsNumeral IS NULL 
		AND prpy_Deleted IS NULL
		AND T1.comp_PRIgnoreTES IS NULL
	GROUP BY Yr, prpy_TradeReportDescription, prpy_Order
	Order BY prpy_Order, yr DESC

	UPDATE @ReportTable
	SET Type1Count = (SELECT COUNT(1) FROM @ReportTable WHERE GraphType = 1 AND Cnt > 0)

	UPDATE @ReportTable
	SET Type2Count = (SELECT COUNT(1) FROM @ReportTable WHERE GraphType = 2 AND Cnt > 0)

	UPDATE @ReportTable
	   SET YearRatingTotal = Total
	  FROM @ReportTable rt
	       LEFT OUTER JOIN (SELECT GraphType, ReportYear, SUM(Cnt) as Total
	                          FROM @ReportTable
		                   GROUP BY GraphType, ReportYear) T1 ON T1.ReportYear = rt.ReportYear
						                                     AND T1.GraphType = rt.GraphType
	 
	SELECT * FROM @ReportTable
END
GO


IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'usp_BRTradeReportSummaryRules' AND Type='P') DROP PROCEDURE dbo.usp_BRTradeReportSummaryRules
GO

/**
Returns the trade report rule indicator data for the specified 
company.
**/
CREATE PROCEDURE dbo.usp_BRTradeReportSummaryRules
	@CompanyID INT,
	@MonthsOld INT = 36
AS  
BEGIN
    DECLARE @ReportTable TABLE (
	    ConnectionListDate DATETIME,
	    TradeReportCount INT DEFAULT 0
    )

    DECLARE @HQID INT
    SET @HQID = dbo.ufn_BRGetHQID(@CompanyID)

    INSERT INTO @ReportTable VALUES (NULL, 0);

    UPDATE @ReportTable SET ConnectionListDate = comp_PRConnectionListDate
      FROM Company WITH (NOLOCK) 
     WHERE Company.Comp_Deleted IS NULL
       AND comp_CompanyID = @HQID;
     
    UPDATE @ReportTable SET TradeReportCount = 
    (SELECT COUNT(1)
       FROM Company WITH (NOLOCK) 
            INNER JOIN PRTradeReport WITH (NOLOCK) ON Company.Comp_CompanyId = PRTradeReport.prtr_SubjectId
      WHERE Company.Comp_Deleted IS NULL
        AND comp_PRHQId = @HQID OR comp_CompanyID = @HQID
        AND PRTradeReport.prtr_DisputeInvolved IS NULL
        AND PRTradeReport.prtr_Deleted IS NULL
        AND prtr_Date >= DATEADD(mm, 0-@MonthsOld, GETDATE())
		AND prtr_ExcludeFromAnalysis IS NULL);

	SELECT * FROM @ReportTable;  
END
GO

IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'usp_BRBBScoreHistory' AND Type='P') 
	DROP PROCEDURE dbo.usp_BRBBScoreHistory
GO
/**
Returns the BBScore history data for the specified 
company.
**/
CREATE PROCEDURE dbo.usp_BRBBScoreHistory
	@CompanyID int,
	@IndustryType varchar(40),
	@HistoryThresholdMonths int = 12,
    @ConfidenceThreshold decimal(24,6) = 5
AS  
BEGIN
	DECLARE @tblResults TABLE (RunDate DATETIME, BBScore INT, OldBBScore INT)

	-- Current is defined as the latest file date uploaded so history starts at the file prior to that
	DECLARE @CurrentRunDate DATETIME
	SELECT @CurrentRunDate = MAX(prbs_RunDate) 
	  FROM PRBBScore
	       INNER JOIN Company  WITH (NOLOCK) ON prbs_CompanyID = comp_CompanyID
	 WHERE comp_PRIndustryType = CASE @IndustryType WHEN 'L' THEN 'L' ELSE 'P' END

	-- Create an outline for the @HistoryThresholdMonths previous months
	DECLARE @BeginMonthScoreDate  DATETIME
	SELECT @BeginMonthScoreDate = DATEADD(MONTH, DATEDIFF(MONTH, 0, @CurrentRunDate), 0) -- Set to the first of the month
                                  
	INSERT INTO @tblResults
	SELECT DISTINCT prbs_RunDate, NULL, NULL
	  FROM PRBBScore WITH (NOLOCK) 
	       INNER JOIN Company  WITH (NOLOCK) ON prbs_CompanyID = comp_CompanyID
	 WHERE prbs_RunDate > DATEADD(MONTH, -(@HistoryThresholdMonths),  @BeginMonthScoreDate)
	   AND comp_PRIndustryType = CASE @IndustryType WHEN 'L' THEN 'L' ELSE 'P' END
	ORDER BY prbs_RunDate DESC

	UPDATE @tblResults SET BBScore = prbs_BBScore, OldBBScore = prbs_OldBBScore
		 FROM PRBBScore WITH (NOLOCK) 
		 WHERE prbs_CompanyId = @CompanyId 
		   AND RunDate = prbs_RunDate
		   AND prbs_PRPublish = 'Y'

	SELECT * FROM @tblResults
END
GO	

IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'usp_BRBBScoreHistoryRank' AND Type='P') 
	DROP PROCEDURE dbo.usp_BRBBScoreHistoryRank
GO
/**
Returns the BBScore history data for the specified 
company.
**/
CREATE PROCEDURE dbo.usp_BRBBScoreHistoryRank
	@CompanyID int,
	@IndustryType varchar(40),
	@Culture varchar(40) = 'en-us',
	@BBScoreChartCount int = 4,
	@HistoryThresholdMonths int = 12
	
AS  
BEGIN
	IF(@Culture = 'es-mx') BEGIN
		SET LANGUAGE SPANISH
	END
	
	DECLARE @tblResults TABLE (RunDate DATETIME, BBScore INT, OldBBScore INT)

	-- Current is defined as the latest file date uploaded so history starts at the file prior to that
	DECLARE @CurrentRunDate DATETIME
	SELECT @CurrentRunDate = MAX(prbs_RunDate) 
	  FROM PRBBScore
	       INNER JOIN Company  WITH (NOLOCK) ON prbs_CompanyID = comp_CompanyID
	 WHERE comp_PRIndustryType = CASE @IndustryType WHEN 'L' THEN 'L' ELSE 'P' END

	-- Create an outline for the @HistoryThresholdMonths previous months
	DECLARE @BeginMonthScoreDate  DATETIME
	SELECT @BeginMonthScoreDate = DATEADD(MONTH, DATEDIFF(MONTH, 0, @CurrentRunDate), 0) -- Set to the first of the month
                                  
	INSERT INTO @tblResults
	SELECT DISTINCT prbs_RunDate, NULL, NULL
	  FROM PRBBScore WITH (NOLOCK) 
	       INNER JOIN Company  WITH (NOLOCK) ON prbs_CompanyID = comp_CompanyID
	 WHERE prbs_RunDate > DATEADD(MONTH, -(@HistoryThresholdMonths),  @BeginMonthScoreDate)
	   AND comp_PRIndustryType = CASE @IndustryType WHEN 'L' THEN 'L' ELSE 'P' END
	ORDER BY prbs_RunDate DESC

	UPDATE @tblResults SET BBScore = prbs_BBScore, OldBBScore = prbs_OldBBScore
		 FROM PRBBScore WITH (NOLOCK) 
		 WHERE prbs_CompanyId = @CompanyId 
		   AND RunDate = prbs_RunDate
		   AND prbs_PRPublish = 'Y'

	SELECT * FROM 
	(
		SELECT TOP (@BBScoreChartCount) 
			RunDate, 
			DATENAME(m, RunDate) + ' ' + CAST(Year(RunDate) as varchar(4)) as RunDateDescription,
			BBScore,
			OldBBScore,
			RN
		 FROM (
			SELECT *, RANK() OVER (ORDER BY RunDate DESC) AS RN 
		FROM @tblResults) T1
		WHERE 
			BBScore IS NOT NULL
		ORDER BY RunDate DESC
	) T2
	ORDER BY RunDate ASC
	
	SET LANGUAGE ENGLISH
END
GO	



IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'usp_BRBusinessProfileSpecies' AND Type='P') DROP PROCEDURE dbo.usp_BRBusinessProfileSpecies
GO
/**
Returns a list of the species
**/
CREATE PROCEDURE dbo.usp_BRBusinessProfileSpecies
	@CompanyID INT
AS  
BEGIN
    DECLARE @HQID INT
    SET @HQID = dbo.ufn_BRGetHQID(@CompanyID)

	DECLARE @Result VARCHAR(MAX)

	SELECT @Result = COALESCE(@Result + ', ', '') + prspc_Name
      FROM PRCompanySpecie WITH (NOLOCK)
           INNER JOIN PRSpecie WITH (NOLOCK) ON prcspc_SpecieID = prspc_SpecieID
     WHERE prcspc_CompanyID = @HQID
  Order BY prspc_DisplayOrder;

	SELECT @Result AS Species

END
GO

IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'usp_BRBusinessProfileProducts' AND Type='P') DROP PROCEDURE dbo.usp_BRBusinessProfileProducts
GO
/**
Returns a list of the products provided
**/
CREATE PROCEDURE dbo.usp_BRBusinessProfileProducts
	@CompanyID INT
AS  
BEGIN
    DECLARE @HQID INT
    SET @HQID = dbo.ufn_BRGetHQID(@CompanyID)

	DECLARE @Result VARCHAR(MAX)

	SELECT @Result = COALESCE(@Result + ', ', '') + prprpr_Name
      FROM PRCompanyProductProvided WITH (NOLOCK)
           INNER JOIN PRProductProvided WITH (NOLOCK) ON prcprpr_ProductProvidedID = prprpr_ProductProvidedID
     WHERE prcprpr_CompanyID = @HQID
  Order BY prprpr_DisplayOrder;

	SELECT @Result AS Products
END
GO

IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'usp_BRBusinessProfileServices' AND Type='P') DROP PROCEDURE dbo.usp_BRBusinessProfileServices
GO
/**
Returns a list of the services provided
**/
CREATE PROCEDURE dbo.usp_BRBusinessProfileServices
	@CompanyID INT
AS  
BEGIN
    DECLARE @HQID INT
    SET @HQID = dbo.ufn_BRGetHQID(@CompanyID)

	DECLARE @Result VARCHAR(MAX)

	SELECT @Result = COALESCE(@Result + ', ', '') + prserpr_Name
      FROM PRServiceProvided WITH (NOLOCK)
           INNER JOIN PRCompanyServiceProvided WITH (NOLOCK) ON prcserpr_ServiceProvidedID = prserpr_ServiceProvidedID
     WHERE prcserpr_CompanyID = @HQID
  Order BY prserpr_DisplayOrder;

	SELECT @Result AS Services
END
GO

IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'usp_BRBusinessProfileOperationsLumber' AND Type='P') DROP PROCEDURE dbo.usp_BRBusinessProfileOperationsLumber
GO

/**
Returns store count for lumber operations
**/
CREATE PROCEDURE dbo.usp_BRBusinessProfileOperationsLumber
	@CompanyID INT
AS  
BEGIN
    SELECT prcl_Name,
           dbo.ufn_GetCustomCaptionValue('prc2_StoreCount', prc2_NumberOfStores, 'en-us') AS NumberOfStores
      FROM PRCompanyClassification WITH (NOLOCK) 
           INNER JOIN PRClassification WITH (NOLOCK) ON prc2_ClassificationId = prcl_ClassificationId 
     WHERE prc2_CompanyId = dbo.ufn_BRGetHQID(@CompanyID)
       AND prc2_ClassificationId IN (2190, 2191, 2192)
       AND prc2_Deleted IS NULL;
END
GO


IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'ufn_BRGetPersonBackgroundDate') 
	DROP FUNCTION dbo.ufn_BRGetPersonBackgroundDate
GO


CREATE FUNCTION dbo.ufn_BRGetPersonBackgroundDate(@Start VARCHAR(50), @End VARCHAR(50), @PeliStatus VARCHAR(40))  
RETURNS VARCHAR(100)
BEGIN 

	DECLARE @Return VARCHAR(100)
	
	IF ((@Start IS NULL) OR (@Start = '') AND
        (@End IS NULL) OR (@End = '')) BEGIN
        
        SET @Return = 'Not Avail.'
        
    END ELSE BEGIN
    
		IF (@Start IS NULL) OR (@Start = '') BEGIN
			SET @Return = 'Not Avail.'
		END ELSE BEGIN
			SET @Return = @Start
		END
    
		SET @Return = @Return + ' - '
		
		IF (@End IS NULL) OR (@End = '') BEGIN
			
			IF (@PeliStatus = '3') BEGIN
				SET @Return = @Return + 'Not Avail.'
			END ELSE BEGIN
				SET @Return = @Return + 'Current'
			END
			
		END ELSE BEGIN
			SET @Return = @Return + @End
		END		
    
    END
        
        
	RETURN @Return
END
GO 



create or ALTER     proc  [dbo].[usp_PopulateExperianData] @request_id int, @company_id int,  @audit_record_id int OUTPUT, @debug int = 0
as
begin

-- declare @audit_id int = 0 exec usp_PopulateExperianData 1001 , 1, @audit_id OUTPUT, @debug = 1 select @audit_id as my_audit_record

--exec [usp_BRPopulateExperianData] 1001,1
 --declare @request_id int = 1000, @company_id int = 1

begin try

declare @Experian_exit_code char(1) = 'N' -- this goes into a PRExperianData record

declare @bin varchar(50) -- using a string so it's easier to work with when crafting requests

select @bin = prcex_BIN, @Experian_exit_code = 'R' from PRCompanyExperian where prcex_CompanyID = @company_id

---if @debug = 1  --select @bin as bin, @Experian_exit_code as exit_code   --- this breaks SSRS field population

declare @web_endpoint_auth varchar(1024) = (select Capt_US from custom_captions where capt_family = 'ExperianIntegration' and capt_code = 'web_endpoint_auth')

declare @web_endpoint_bankruptcies varchar(1024) = (select Capt_US from custom_captions where capt_family = 'ExperianIntegration' and capt_code = 'web_endpoint_bankruptcies')
declare @web_endpoint_business_facts varchar(1024) = (select Capt_US from custom_captions where capt_family = 'ExperianIntegration' and capt_code = 'web_endpoint_business_facts')
declare @web_endpoint_judgements varchar(1024) = (select Capt_US from custom_captions where capt_family = 'ExperianIntegration' and capt_code = 'web_endpoint_judgements')
declare @web_endpoint_liens varchar(1024) = (select Capt_US from custom_captions where capt_family = 'ExperianIntegration' and capt_code = 'web_endpoint_liens')
declare @web_endpoint_trades varchar(1024) = (select Capt_US from custom_captions where capt_family = 'ExperianIntegration' and capt_code = 'web_endpoint_trades')
declare @web_endpoint_collections varchar(1024) = (select Capt_US from custom_captions where capt_family = 'ExperianIntegration' and capt_code = 'web_endpoint_collections')

declare @Client_id varchar(1024) = (select Capt_US from custom_captions where capt_family = 'ExperianIntegration' and capt_code = 'Client_id')
declare @Client_secret varchar(1024) = (select Capt_US from custom_captions where capt_family = 'ExperianIntegration' and capt_code = 'Client_secret')
declare @username varchar(1024) = (select Capt_US from custom_captions where capt_family = 'ExperianIntegration' and capt_code = 'username')
declare @password varchar(1024) = (select Capt_US from custom_captions where capt_family = 'ExperianIntegration' and capt_code = 'password')
declare @subcode varchar(1024) = (select Capt_US from custom_captions where capt_family = 'ExperianIntegration' and capt_code = 'subcode')

if(@debug = 1) select @username, @password

declare @HasPaymentFilingsSummary nchar(1) = 'N',
@HasTaxLienDetails  nchar(1) = 'N',
@HasJudgementDetails nchar(1) = 'N',
@HasTradeContinuous nchar(1) = 'N',
@HasTradeNew nchar(1) = 'N',
@HasTradeAdditional nchar(1) = 'N',
@HasTradeDetails nchar(1) = 'N',
@HasBusinessFacts nchar(1) = 'N'



declare @auth_web_request_body varchar(2000)= '{ "username": "' + @username + '", "password": "' + @password + '"}'
declare @auth_web_request_headers varchar(2000)  = 'Client_id='+ @Client_id + ';Client_secret=' + @Client_secret

--get an authorization token

declare @auth_response varchar(8000)
select @auth_response = dbo.HTTPS_POST_JSON_UTF8(@web_endpoint_auth,@auth_web_request_body,@auth_web_request_headers)

if(isjson(@auth_response)<>1) throw  60000,'JSON PROBLEM WITH AUTH_REPSONSE',1

if @debug = 1
select @auth_response as auth_resp

declare @access_token varchar(1024) = json_value(@auth_response,'$.access_token')

if @debug = 1
select @access_token as access_token

declare @auth_token_header varchar(1024)  = 'Authorization= Bearer ' + @access_token


--pull Business Facts

declare @web_endpoint_business_facts_success int = 1

begin try
	select dbo.HTTPS_POST_JSON_UTF8(
	@web_endpoint_business_facts,
	'{"bin":"' + @bin + '",  "subcode":"' + @subcode + '"}',
	@auth_token_header
	) as json1
	into #business_facts_results

end try
begin catch
	set @web_endpoint_business_facts_success = 0
end catch




if @debug = 1 
select * from #business_facts_results 

select @HasBusinessFacts = 'Y', @Experian_exit_code = 'R'  from #business_facts_results




--pull Judgements

declare @web_endpoint_judgements_success int = 1

begin try
	select dbo.HTTPS_POST_JSON_UTF8(
	@web_endpoint_judgements,
	'{"bin":"' + @bin + '",  "subcode":"' + @subcode + '" ,  "judgmentSummary":true,  "judgmentDetail":true}',
	@auth_token_header
	) as json1
	into #judgements_results

end try
begin catch
	set @web_endpoint_judgements_success = 0
end catch

select @Experian_exit_code = 'R' from #judgements_results 

if @debug = 1
select * from #judgements_results 




--pull Liens

declare @web_endpoint_liens_success int = 1

begin try
	select dbo.HTTPS_POST_JSON_UTF8(
	@web_endpoint_liens,
	'{"bin":"' + @bin + '",  "subcode":"' + @subcode + '" ,    "lienSummary":true,    "lienDetail":true}',
	@auth_token_header
	) as json1
	into #liens_results

end try
begin catch
	set @web_endpoint_liens_success = 0
end catch

if @debug = 1
select * from #liens_results 

select @HasTaxLienDetails = 'Y' , @Experian_exit_code = 'R'  from #liens_results




--pull Trades

declare @web_endpoint_trades_success int = 1

begin try
	select dbo.HTTPS_POST_JSON_UTF8(
	@web_endpoint_trades,
	'{"bin":"' + @bin + '",  "subcode":"' + @subcode + '" ,     "tradePaymentSummary":true,  "tradePaymentTotals":true,  "tradePaymentExperiences":true,  "tradePaymentTrends":true}',
	@auth_token_header
	) as json1
	into #trades_results

end try
begin catch
	set @web_endpoint_trades_success = 0
end catch

select @Experian_exit_code = 'R'  from #trades_results 

if @debug = 1
select * from #trades_results 


--pull Bankruptcies

declare @web_endpoint_bankruptcies_success int = 1

begin try
	select dbo.HTTPS_POST_JSON_UTF8(
	@web_endpoint_bankruptcies,
	'{"bin":"' + @bin + '",  "subcode":"' + @subcode + '" ,  "bankruptcySummary":true,  "bankruptcyDetail":true}',
	@auth_token_header
	) as json1
	into #bankruptcies_results

end try
begin catch
	set @web_endpoint_bankruptcies_success = 0
end catch

select @Experian_exit_code = 'R'  from #bankruptcies_results 

if @debug = 1
select * from #bankruptcies_results 


--pull Collections

declare @web_endpoint_collections_success int = 1

begin try
	select dbo.HTTPS_POST_JSON_UTF8(
	@web_endpoint_collections,
	'{"bin":"' + @bin + '",  "subcode":"' + @subcode + '" ,  "collectionsSummary":true,  "collectionsDetail":true}',
	@auth_token_header
	) as json1
	into #collections_results

end try
begin catch
	set @web_endpoint_collections_success = 0
end catch

select @Experian_exit_code = 'R'   from #collections_results 

if @debug = 1
select * from #collections_results 






--preclean to be able to rerun tests
delete from PRExperianBusinessCode where prexbc_CompanyID = @company_id and prexbc_RequestID = @request_id
delete from PRExperianData where prexd_CompanyID = @company_id and prexd_RequestID = @request_id
delete from PRExperianLegalFiling where prexlf_CompanyID = @company_id and prexlf_RequestID = @request_id
delete from PRExperianTradePaymentSummary where prextps_CompanyID = @company_id and prextps_RequestID = @request_id
delete from PRExperianTradePaymentDetail where prextpd_CompanyID = @company_id and prextpd_RequestID = @request_id


-- start parsing the JSON and loading it into the tables
declare @json1 varchar(max) = ''

select top 1 @json1 = json1 from #business_facts_results

if(isjson(@json1)<>1) throw 60000,'JSON PROBLEM WITH BUSINESS_FACTS_RESULTS',1

if @debug = 1
select @json1 as json_from_table


insert into dbo.PRExperianBusinessCode(prexbc_TimeStamp,prexbc_RequestID,prexbc_CompanyID,prexbc_TypeCode,prexbc_Code,prexbc_Description)
	select getdate(),@request_id,@company_id,'SIC',* from openjson(json_query(@json1,'$.results.sicCodes'))
	with (
	sicCode varchar(255)  '$.code',
	sicCodeDef varchar(255)  '$.definition'
	)

insert into dbo.PRExperianBusinessCode(prexbc_TimeStamp,prexbc_RequestID,prexbc_CompanyID,prexbc_TypeCode,prexbc_Code,prexbc_Description)
	select getdate(),@request_id,@company_id,'NAICS',* from openjson(json_query(@json1,'$.results.naicsCodes'))
	with (
	naicsCode varchar(255)  '$.code',
	naicsCodeDef varchar(255)  '$.definition'
	)

 set @json1 = ''
select top 1 @json1 = json1 from #liens_results
if(isjson(@json1)<>1) throw 60000,'JSON PROBLEM WITH LIENS_RESULTS',1 

if @debug = 1
select @json1 as json_from_table

insert into dbo.PRExperianLegalFiling(prexlf_TimeStamp,prexlf_RequestID, prexlf_CompanyID,prexlf_TypeCode, prexlf_Date,prexlf_LegalType,prexlf_LegalAction,prexlf_DocumentNumber,prexlf_FilingLocation,prexlf_Owner,prexlf_LiabilityAmount)
select getdate(), @request_id,@company_id,'TaxLien',* from openjson(json_query(@json1,'$.results.lienDetail'))
with (
dateFiled varchar(255)  '$.dateFiled',
legalType varchar(255)  '$.legalType',
legalAction varchar(255)  '$.legalAction',
documentNumber varchar(255)  '$.documentNumber',
filingLocation varchar(255)  '$.filingLocation',
owner varchar(255)  '$.owner',
liabilityAmount varchar(255)  '$.liabilityAmount'
)

select @HasTaxLienDetails = 'Y' from openjson(json_query(@json1,'$.results.lienDetail'))


set @json1 = ''
select top 1 @json1 = json1 from #judgements_results
if(isjson(@json1)<>1) throw 60000,'JSON PROBLEM WITH JUDGEMENTS_RESULTS',1

if @debug = 1
select @json1 as json_from_table

insert into dbo.PRExperianLegalFiling(prexlf_TimeStamp, prexlf_RequestID, prexlf_CompanyID,prexlf_TypeCode, prexlf_Date,prexlf_LegalType,prexlf_LegalAction,prexlf_DocumentNumber,prexlf_FilingLocation,prexlf_PlaintiffName,prexlf_LiabilityAmount)
select getdate(), @request_id, @company_id, 'Judgement',* from openjson(json_query(@json1,'$.results.judgmentDetail'))
with (
dateFiled varchar(255)  '$.dateFiled',
legalType varchar(255)  '$.legalType',
legalAction varchar(255)  '$.legalAction',
documentNumber varchar(255)  '$.documentNumber',
filingLocation varchar(255)  '$.filingLocation',
plaintiffName varchar(255)  '$.plaintiffName',
liabilityAmount varchar(255)  '$.liabilityAmount'
)

select @HasJudgementDetails = 'Y' from openjson(json_query(@json1,'$.results.judgmentDetail'))


--load trade payment summary records

set @json1 = ''
select top 1 @json1 = json1 from #trades_results
if(isjson(@json1)<>1) throw 60000,'JSON PROBLEM WITH TRADES_RESULTS',1 

if @debug = 1
select @json1 as json_from_table


insert into dbo.PRExperianTradePaymentSummary(prextps_TimeStamp,prextps_RequestID,prextps_CompanyID,
	prextps_TypeCode, prextps_TradeLineCount,prextps_CurrentDBT,prextps_TotalHighCreditAmount,prextps_TotalAccountBalance,prextps_CurrentPercentage,prextps_DBT30, prextps_DBT60,prextps_DBT90,prextps_DBT91Plus)

	select getdate(), @request_id, @company_id, 'Total',*  from openjson(json_query(@json1,'$.results.tradePaymentTotals.tradelines'))
	with (
	tradelineCount varchar(255)  '$.tradelineCount',
	currentDbt varchar(255)  '$.currentDbt',
	totalHighCreditAmount varchar(255)  '$.totalHighCreditAmount.amount',
	totalAccountBalance varchar(255)  '$.totalAccountBalance.amount',
	currentPercentage varchar(255)  '$.currentPercentage',
	dbt30 varchar(255)  '$.dbt30',
	dbt60 varchar(255)  '$.dbt60',
	dbt90 varchar(255)  '$.dbt90',
	dbt91Plus varchar(255)  '$.dbt91Plus'
	)

	insert into dbo.PRExperianTradePaymentSummary(prextps_TimeStamp,prextps_RequestID,prextps_CompanyID,
	prextps_TypeCode, prextps_TradeLineCount,prextps_CurrentDBT,prextps_TotalHighCreditAmount,prextps_TotalAccountBalance,prextps_CurrentPercentage,prextps_DBT30, prextps_DBT60,prextps_DBT90,prextps_DBT91Plus)

	select getdate(), @request_id, @company_id, 'Combined',*  from openjson(json_query(@json1,'$.results.tradePaymentTotals.combinedTradelines'))
	with (
	tradelineCount varchar(255)  '$.tradelineCount',
	currentDbt varchar(255)  '$.currentDbt',
	totalHighCreditAmount varchar(255)  '$.totalHighCreditAmount.amount',
	totalAccountBalance varchar(255)  '$.totalAccountBalance.amount',
	currentPercentage varchar(255)  '$.currentPercentage',
	dbt30 varchar(255)  '$.dbt30',
	dbt60 varchar(255)  '$.dbt60',
	dbt90 varchar(255)  '$.dbt90',
	dbt91Plus varchar(255)  '$.dbt91Plus'
	)





insert into dbo.PRExperianTradePaymentSummary(prextps_TimeStamp,prextps_RequestID,prextps_CompanyID,
	prextps_TypeCode, prextps_TradeLineCount,prextps_CurrentDBT,prextps_TotalHighCreditAmount,prextps_TotalAccountBalance,prextps_CurrentPercentage,prextps_DBT30, prextps_DBT60,prextps_DBT90,prextps_DBT91Plus)

	select getdate(), @request_id, @company_id, 'Continuous', *  from openjson(json_query(@json1,'$.results.tradePaymentTotals.continuouslyReportedTradelines'))
	with (
	tradelineCount varchar(255)  '$.tradelineCount',
	currentDbt varchar(255)  '$.currentDbt',
	totalHighCreditAmount varchar(255)  '$.totalHighCreditAmount.amount',
	totalAccountBalance varchar(255)  '$.totalAccountBalance.amount',
	currentPercentage varchar(255)  '$.currentPercentage',
	dbt30 varchar(255)  '$.dbt30',
	dbt60 varchar(255)  '$.dbt60',
	dbt90 varchar(255)  '$.dbt90',
	dbt91Plus varchar(255)  '$.dbt91Plus'
	)

	select @HasTradeContinuous = 'Y' from openjson(json_query(@json1,'$.results.tradePaymentTotals.continuouslyReportedTradelines1'))

	if @debug = 1
	select @HasTradeContinuous as '@HasTradeContinuous1'


insert into dbo.PRExperianTradePaymentSummary(prextps_TimeStamp,prextps_RequestID,prextps_CompanyID,
	prextps_TypeCode, prextps_TradeLineCount,prextps_CurrentDBT,prextps_TotalHighCreditAmount,prextps_TotalAccountBalance,prextps_CurrentPercentage,prextps_DBT30, prextps_DBT60,prextps_DBT90,prextps_DBT91Plus)

	select getdate(), @request_id, @company_id, 'New',*  from openjson(json_query(@json1,'$.results.tradePaymentTotals.newlyReportedTradelines'))
	with (
	tradelineCount varchar(255)  '$.tradelineCount',
	currentDbt varchar(255)  '$.currentDbt',
	totalHighCreditAmount varchar(255)  '$.totalHighCreditAmount.amount',
	totalAccountBalance varchar(255)  '$.totalAccountBalance.amount',
	currentPercentage varchar(255)  '$.currentPercentage',
	dbt30 varchar(255)  '$.dbt30',
	dbt60 varchar(255)  '$.dbt60',
	dbt90 varchar(255)  '$.dbt90',
	dbt91Plus varchar(255)  '$.dbt91Plus'
	)

	select @HasTradeNew = 'Y' from openjson(json_query(@json1,'$.results.tradePaymentTotals.newlyReportedTradelines'))


insert into dbo.PRExperianTradePaymentSummary(prextps_TimeStamp,prextps_RequestID,prextps_CompanyID,
	prextps_TypeCode, prextps_TradeLineCount,prextps_CurrentDBT,prextps_TotalHighCreditAmount,prextps_TotalAccountBalance,prextps_CurrentPercentage,prextps_DBT30, prextps_DBT60,prextps_DBT90,prextps_DBT91Plus)

	select getdate(), @request_id, @company_id, 'Additional',*  from openjson(json_query(@json1,'$.results.tradePaymentTotals.additionalTradelines'))
	with (
	tradelineCount varchar(255)  '$.tradelineCount',
	currentDbt varchar(255)  '$.currentDbt',
	totalHighCreditAmount varchar(255)  '$.totalHighCreditAmount.amount',
	totalAccountBalance varchar(255)  '$.totalAccountBalance.amount',
	currentPercentage varchar(255)  '$.currentPercentage',
	dbt30 varchar(255)  '$.dbt30',
	dbt60 varchar(255)  '$.dbt60',
	dbt90 varchar(255)  '$.dbt90',
	dbt91Plus varchar(255)  '$.dbt91Plus'
	)

	select @HasTradeAdditional = 'Y' from openjson(json_query(@json1,'$.results.tradePaymentTotals.additionalTradelines'))

	if 'y' in (@HasTradeContinuous,@HasTradeNew,@HasTradeAdditional) set @HasPaymentFilingsSummary = 'Y'


set @json1 = ''
--declare @json1 varchar(max), @request_id int = 1000, @company_id int = 1
select top 1 @json1 = json1 from #trades_results
if(isjson(@json1)<>1) throw 60000,'JSON PROBLEM WITH TRADES_RESULTS',1

if @debug = 1
select @json1 as json_from_table

insert into dbo.PRExperianTradePaymentDetail(prextpd_TimeStamp,prextpd_RequestID,prextpd_CompanyID,
	prextpd_BusinessCategory,prextpd_DateReported,prextpd_DateLastActivity,prextpd_Terms,prextpd_RecentHighCredit,prextpd_AccountBalance,prextpd_CurrentPercentage,prextpd_DBT30,prextpd_DBT60,prextpd_DBT90,prextpd_DBT91Plus,prextpd_NewlyReported,prextpd_TypeCode)

	select getdate(), @request_id, @company_id,
	
	businessCategory,
	dateReported,
	dateLastActivity,
	terms,
	recentHighCredit,
	accountBalance,
	currentPercentage,
	dbt30,
	dbt60,
	dbt90,
	dbt91Plus,
	case newlyReportedIndicator when 'true' then 'Y' else 'N' end as newlyReportedIndicator,
	'NewContinuous'
	
	 from openjson(json_query(@json1,'$.results.tradePaymentExperiences.tradeNewAndContinuous'))
	with (
	businessCategory varchar(255)  '$.businessCategory',
	dateReported varchar(255)  '$.dateReported',
	dateLastActivity varchar(255)  '$.dateLastActivity',
	terms varchar(255)  '$.terms',
	recentHighCredit varchar(255)  '$.recentHighCredit.amount',
	accountBalance varchar(255)  '$.accountBalance.amount',
	currentPercentage varchar(255)  '$.currentPercentage',
	dbt30 varchar(255)  '$.dbt30',
	dbt60 varchar(255)  '$.dbt60',
	dbt90 varchar(255)  '$.dbt90',
	dbt91Plus varchar(255)  '$.dbt91Plus',
	newlyReportedIndicator varchar(255)  '$.newlyReportedIndicator'--,customerDisputeIndicator varchar(255)  '$.customerDisputeIndicator',
	
	)

	select @HasTradeDetails = 'Y' from openjson(json_query(@json1,'$.results.tradePaymentExperiences.tradeNewAndContinuous'))

insert into dbo.PRExperianTradePaymentDetail(prextpd_TimeStamp,prextpd_RequestID,prextpd_CompanyID,
	prextpd_BusinessCategory,prextpd_DateReported,prextpd_DateLastActivity,prextpd_Terms,prextpd_RecentHighCredit,prextpd_AccountBalance,prextpd_CurrentPercentage,prextpd_DBT30,prextpd_DBT60,prextpd_DBT90,prextpd_DBT91Plus,prextpd_NewlyReported,prextpd_TypeCode)

	select getdate(), @request_id, @company_id,
	
	businessCategory,
	dateReported,
	dateLastActivity,
	terms,
	recentHighCredit,
	accountBalance,
	currentPercentage,
	dbt30,
	dbt60,
	dbt90,
	dbt91Plus,
	case newlyReportedIndicator when 'true' then 'Y' else 'N' end as newlyReportedIndicator,
	'Additional'
	
	 from openjson(json_query(@json1,'$.results.tradePaymentExperiences.tradeAdditional'))
	with (
	businessCategory varchar(255)  '$.businessCategory',
	dateReported varchar(255)  '$.dateReported',
	dateLastActivity varchar(255)  '$.dateLastActivity',
	terms varchar(255)  '$.terms',
	recentHighCredit varchar(255)  '$.recentHighCredit.amount',
	accountBalance varchar(255)  '$.accountBalance.amount',
	currentPercentage varchar(255)  '$.currentPercentage',
	dbt30 varchar(255)  '$.dbt30',
	dbt60 varchar(255)  '$.dbt60',
	dbt90 varchar(255)  '$.dbt90',
	dbt91Plus varchar(255)  '$.dbt91Plus',
	newlyReportedIndicator varchar(255)  '$.newlyReportedIndicator'--,customerDisputeIndicator varchar(255)  '$.customerDisputeIndicator',
	
	)

	select @HasTradeDetails = 'Y' from openjson(json_query(@json1,'$.results.tradePaymentExperiences.tradeNewAndContinuous'))

--declare @json1 varchar(max), @request_id int = 1000, @company_id int = 1
--now pull all the odd pieces together to load PRExperianData 
declare
@employeeSize varchar(512) = null, @salesRevenue varchar(512) = null,
@bankruptcyIndicator varchar(512) = null,
@judgmentCount varchar(512) = null, @judgmentBalance varchar(512) = null

--from Business Facts

set @json1 = ''
select top 1 @json1 = json1 from #business_facts_results
if(isjson(@json1)<>1) throw 60000,'JSON PROBLEM WITH BUSINESS_FACTS_RESULTS',1

if @debug = 1
select @json1 as json_from_table

select @employeeSize = employeeSize, @salesRevenue = salesRevenue from openjson(json_query(@json1,'$.results'))
with (
employeeSize varchar(255)  '$.employeeSize',
salesRevenue varchar(255)  '$.salesRevenue'
)

if @debug = 1
select @employeeSize '@employee_size', @salesRevenue '@sales_revenue'


--From Bankruptcy
set @json1 = ''
select top 1 @json1 = json1 from #bankruptcies_results
if(isjson(@json1)<>1) throw 60000,'JSON PROBLEM WITH BANKRUPTCIES_RESULTS',1

if @debug = 1
select @json1 as json_from_table

select @bankruptcyIndicator = bankruptcyIndicator from openjson(json_query(@json1,'$.results'))
with (
bankruptcyIndicator varchar(255)  '$.bankruptcyIndicator'
)

--From Judgements
set @json1 = ''
select top 1 @json1 = json1 from #judgements_results
if(isjson(@json1)<>1) throw 60000,'JSON PROBLEM WITH JUDGEMENTS_RESULTS',1

if @debug = 1
select @json1 as json_from_table

select @judgmentCount = judgmentCount, @judgmentBalance = judgmentBalance from openjson(json_query(@json1,'$.results.judgmentSummary'))
with (
judgmentCount varchar(255)  '$.judgmentCount',
judgmentBalance varchar(255)  '$.judgmentBalance' -- add this to lien balance
)

--From Trades

declare @currentDbt varchar(512) = null,
@monthlyAverageDbt varchar(512) = null,
@highestDbt6Months varchar(512) = null,
@highestDbt5Quarters varchar(512) = null,
@allTradelineCount varchar(512) = null,
@allTradelineBalance varchar(512) = null,
@continuous_tradelineCount varchar(512) = null,
@continuous_totalAccountBalance varchar(512) = null,
@singleHighCredit varchar(512) = null

set @json1 = ''
select top 1 @json1 = json1 from #trades_results
if(isjson(@json1)<>1) throw 60000,'JSON PROBLEM WITH TRADES_RESULTS',1

if @debug = 1
select @json1 as json_from_table

select 
@currentDbt = currentDbt,
@monthlyAverageDbt = monthlyAverageDbt,
@highestDbt6Months = highestDbt6Months,
@highestDbt5Quarters = highestDbt5Quarters,
@allTradelineCount = allTradelineCount,
@allTradelineBalance = allTradelineBalance,
@continuous_tradelineCount = continuous_tradelineCount,
@continuous_totalAccountBalance = continuous_totalAccountBalance,
@singleHighCredit = singleHighCredit

from openjson(json_query(@json1,'$.results'))
with (
currentDbt varchar(255)  '$.tradePaymentSummary.currentDbt',
monthlyAverageDbt varchar(255)  '$.tradePaymentSummary.monthlyAverageDbt',
highestDbt6Months varchar(255)  '$.tradePaymentSummary.highestDbt6Months',
highestDbt5Quarters varchar(255)  '$.tradePaymentSummary.highestDbt5Quarters',
allTradelineCount varchar(255)  '$.tradePaymentSummary.allTradelineCount',  --this also gets added to total collections
allTradelineBalance varchar(255)  '$.tradePaymentSummary.allTradelineBalance', --this also gets added to total collections
continuous_tradelineCount varchar(255)  '$.tradePaymentTotals.continuouslyReportedTradelines.tradelineCount',  
continuous_totalAccountBalance varchar(255)  '$.tradePaymentTotals.continuouslyReportedTradelines.totalAccountBalance.amount', 
singleHighCredit varchar(255)  '$.tradePaymentSummary.singleHighCredit'
)


--From Liens
declare @lienCount varchar(512) = null,
@lienBalance varchar(512) = null

set @json1 = ''
select top 1 @json1 = json1 from #liens_results
if(isjson(@json1)<>1) throw 60000,'JSON PROBLEM WITH LIENS_RESULTS',1

if @debug = 1
select @json1 as json_from_table

select @lienCount = lienCount, @lienBalance = lienBalance from openjson(json_query(@json1,'$.results.lienSummary'))
with (
lienCount varchar(255)  '$.lienCount',
lienBalance varchar(255)  '$.lienBalance' -- add this to judgement balance
)

--From Collections
declare @collectionCount varchar(512) = null,
@collectionBalance varchar(512) = null

set @json1 = ''
select top 1 @json1 = json1 from #collections_results
if(isjson(@json1)<>1) throw 60000,'JSON PROBLEM WITH COLLECTIONS_RESULTS',1

if @debug = 1
select @json1 as json_from_table

select @collectionCount = collectionCount, @collectionBalance = collectionBalance from openjson(json_query(@json1,'$.results.collectionsSummary'))
with (
collectionCount varchar(255)  '$.collectionCount',
collectionBalance varchar(255)  '$.collectionBalance' -- add this to lien balance
)

end try
begin catch
set @Experian_exit_code = 'E'
end catch


--Here we go....one big composite record (2.1.1.6)
insert into dbo.PRExperianData(prexd_StatusCode,prexd_TimeStamp,prexd_RequestID,prexd_CompanyID,
prexd_CurrentDBT,
prexd_MonthlyAverageDBT,
prexd_HighestDBT6Months,
prexd_HighestDBT5Quarters,
prexd_TradeCollectionCount,
prexd_TradeCollectionAmount,

prexd_TradelinesCount,
prexd_TradelinesAmount,

prexd_CollectionsCount,
prexd_CollectionsAmount,

prexd_ContiniousTradelinesCount,
prexd_ContiniousTradelinesAmount,

prexd_SingleHighCredit,
prexd_BankruptcyIndicator,
prexd_LienCount,
prexd_LienBalance,
prexd_JudgementCount,
prexd_JudgementBalance,
prexd_EmployeeSize,
prexd_SalesRevenue)

select @Experian_exit_code,getdate(),@request_id,@company_id,

@currentDbt,
@monthlyAverageDbt,
@highestDbt6Months,
@highestDbt5Quarters,

cast(@allTradelineCount as int) + cast(@collectionCount as int),
cast(@allTradelineBalance as money) + cast(@collectionBalance as money),

cast(@allTradelineCount as int),
cast(@allTradelineBalance as money),

cast(@collectionCount as int),
cast(@collectionBalance as money),

cast(@continuous_tradelineCount as int),
cast(@continuous_totalAccountBalance as money),

@singleHighCredit,
case @bankruptcyIndicator when 'true' then 'Y' else 'N' end as bankruptcyIndicator,

cast(@lienCount as int),
cast(@lienBalance as money),
cast(@judgmentCount as int),
cast(@judgmentBalance as money),
cast(@employeeSize as int),
cast(@salesRevenue as money)






--make the mandatory PRExperianAuditLog record for each web request result (2.1.1.7)
insert into dbo.PRExperianAuditLog(prexal_TimeStamp,prexal_RequestID,prexal_SubjectCompanyID,
prexal_HasPaymentFilingsSummary,
prexal_HasTaxLienDetails,
prexal_HasJudgmentDetails,
prexal_HasTradeContinous,
prexal_HasTradeNew,
prexal_HasTradeAdditional,
prexal_HasTradeDetails,
prexal_HasBusinessFacts)

values(
getdate(), @request_id,@company_id,
@HasPaymentFilingsSummary,
@HasTaxLienDetails,
@HasJudgementDetails,
@HasTradeContinuous,
@HasTradeNew,
@HasTradeAdditional,
@HasTradeDetails,
@HasBusinessFacts
)


set @audit_record_id = @@IDENTITY


end


Go



IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'usp_BRPopulateExperianData' AND Type='P') DROP PROCEDURE dbo.usp_BRPopulateExperianData
GO

CREATE PROCEDURE dbo.usp_BRPopulateExperianData
    @RequestID int, 
    @SubjectCompanyID int
AS  
BEGIN

	DECLARE @CacheExpiration int, @GetData int, @DeleteData int, @ExperianDataID int
	DECLARE @DataCreatedDate datetime
	DECLARE @StatusCode varchar(40)
	SET @GetData = 0
	SET @DeleteData =0
	SET @CacheExpiration = dbo.ufn_GetCustomCaptionValue('ExperianIntegration', 'CacheExpiration', DEFAULT)
	SELECT @ExperianDataID = prexd_ExperianData,
           @DataCreatedDate = prexd_CreatedDate, 
           @StatusCode = prexd_StatusCode 
      FROM PRExperianData 
     WHERE prexd_RequestID = @RequestID
       AND prexd_CompanyID = @SubjectCompanyID;
	-- If we don't have a record, we need to 
    -- go get one.
	IF (@DataCreatedDate IS NULL) BEGIN
		--Print 'No Cache Record Found.'
		SET @GetData = 1
		
	END ELSE BEGIN
		--Print 'Cache Record Found.'
		IF (@DataCreatedDate <= DATEADD(hh, 0 - @CacheExpiration, GetDate())) BEGIN
			--Print 'Old Cache Record Found. Deleting It.'
			SET @DeleteData = 1
			SET @GetData = 1
		END ELSE BEGIN
			--Print 'Valid Cache Record Found.'
			-- If there was an error the first time, try again
			IF @StatusCode = 'E' BEGIN	
				--Print 'Cache Record has Status = "E".  Deleting It.'
				SET @DeleteData = 1
				SET @GetData = 1
			END
		END
	END
	IF (@DeleteData = 1) BEGIN

		delete from PRExperianBusinessCode where prexbc_CompanyID = @SubjectCompanyID and prexbc_RequestID = @RequestID
		delete from PRExperianData where prexd_CompanyID = @SubjectCompanyID and prexd_RequestID = @RequestID
		delete from PRExperianLegalFiling where prexlf_CompanyID = @SubjectCompanyID and prexlf_RequestID = @RequestID
		delete from PRExperianTradePaymentSummary where prextps_CompanyID = @SubjectCompanyID and prextps_RequestID = @RequestID
		delete from PRExperianTradePaymentDetail where prextpd_CompanyID = @SubjectCompanyID and prextpd_RequestID = @RequestID

	END
	IF (@GetData = 1) BEGIN
		EXEC dbo.usp_PopulateExperianData @RequestID, @SubjectCompanyID, null
	END
END
Go


IF EXISTS (SELECT Name FROM sysobjects WHERE Name = 'ufn_GetExperianStatusCode') 
	DROP FUNCTION dbo.ufn_GetExperianStatusCode
GO


CREATE FUNCTION [dbo].[ufn_GetExperianStatusCode]
(
    @RequestId int = NULL,
    @CompanyId int = NULL
)
RETURNS nchar(1)
AS 
BEGIN
	declare @status_code nchar(1) = '?'
	set @status_code = (select top 1 [prexd_StatusCode] from dbo.[PRExperianData] where [prexd_RequestID] = @RequestId and [prexd_CompanyID] = @CompanyId)
	return @status_code
END
GO



IF EXISTS  (SELECT * FROM dbo.sysobjects  WHERE id = object_id(N'[dbo].[usp_ExperianBINSearch]')) 
	DROP PROCEDURE [dbo].usp_ExperianBINSearch
GO

/**

**/
CREATE PROCEDURE [dbo].[usp_ExperianBINSearch]
	@CompanyID int,
	@UpdatedUserID int = 1,
	@UpdatedDate datetime = NULL,
	@Debug bit = 0
AS  
BEGIN

	IF (@UpdatedDate IS NULL)
		SET @UpdatedDate = GETDATE()


	declare @web_endpoint_auth varchar(1024) = (select Capt_US from custom_captions where capt_family = 'ExperianIntegration' and capt_code = 'web_endpoint_auth')
	declare @web_endpoint_business_search varchar(1024) = (select Capt_US from custom_captions where capt_family = 'ExperianIntegration' and capt_code = 'web_endpoint_search')
	--declare @web_endpoint_business_search varchar(1020) = 'https://us-api.experian.com//businessinformation/businesses/v1/search'
	--declare @web_endpoint_business_search varchar(1020) = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/search'
	declare @Client_id varchar(1024) = (select Capt_US from custom_captions where capt_family = 'ExperianIntegration' and capt_code = 'Client_id')
	declare @Client_secret varchar(1024) = (select Capt_US from custom_captions where capt_family = 'ExperianIntegration' and capt_code = 'Client_secret')
	declare @username varchar(1024) = (select Capt_US from custom_captions where capt_family = 'ExperianIntegration' and capt_code = 'username')
	declare @password varchar(1024) = (select Capt_US from custom_captions where capt_family = 'ExperianIntegration' and capt_code = 'password')
	declare @subcode varchar(1024) = (select Capt_US from custom_captions where capt_family = 'ExperianIntegration' and capt_code = 'subcode')

	--get an authorization token
	declare @auth_web_request_body varchar(2000)= '{ "username": "' + @username + '", "password": "' + @password + '"}'
	declare @auth_web_request_headers varchar(2000)  = 'Client_id='+ @Client_id + ';Client_secret=' + @Client_secret
	declare @auth_response varchar(8000)
	select @auth_response = dbo.HTTPS_POST_JSON_UTF8(@web_endpoint_auth, @auth_web_request_body, @auth_web_request_headers)

	declare @access_token varchar(1024) = json_value(@auth_response,'$.access_token')
	declare @auth_token_header varchar(1024)  = 'Authorization= Bearer ' + @access_token

	IF (@access_token IS NULL) BEGIN
		SELECT -1 as ReturnCode, 'ERROR:' + json_value(@auth_response,'$.errors[0].message') as Message
		RETURN
	END

	--SELECT @auth_web_request_headers, @auth_web_request_body, @access_token

	DECLARE @tblCompany table (
		ndx int identity(1,1),
		CompanyID int,
		CompanyName varchar(200),
		AddressType varchar(10),
		Address1 varchar(200),
		City varchar(200),
		StateAbbr varchar(5),
		Postal varchar(5),
		Phone varchar(20)
	)

	DECLARE @tblSearchResults table (
		CompanyID int,
		BIN varchar(25),
		ReliabilityCode decimal(6,3),
		BusinessName varchar(200),
		Street varchar(200),
		City varchar(200),
		State varchar(5),
		Phone varchar(200),
		NumberOfTradelines int
	)

	INSERT INTO @tblCompany 
	SELECT DISTINCT comp_CompanyID, comp_PRCorrTradestyle, adli_Type, Addr_Address1, prci_City, prst_Abbreviation, addr_uszipfive, null --, phon_PhoneMatch
	  FROM Company WITH (NOLOCK)
		   INNER JOIN vPRAddress ON comp_CompanyID = adli_CompanyID
		   --INNER JOIN vPRCompanyPhone ON comp_CompanyID = PLink_RecordID AND phon_PRIsPhone = 'Y'
		   LEFT OUTER JOIN PRCompanyExperian ON comp_CompanyID = prcex_CompanyID
	 WHERE adli_Type IN ('PH', 'M')
	   AND adli_CompanyId = @CompanyID
	 ORDER BY adli_Type DESC 

	IF (@Debug = 1) BEGIN
		SELECT * FROM @tblCompany
	END

	DECLARE @Count int, @Index int
	DECLARE @Name varchar(200), @Street varchar(200), @City varchar(200), @State varchar(2), @Postal varchar(5), @Phone varchar(20)

	SELECT @Count = COUNT(1) FROM @tblCompany
	SET @Index = 0
	DECLARE @json1 varchar(max)
	WHILE (@Index < @Count) BEGIN

		SET @Index = @Index + 1

		SELECT @Name = CompanyName,
			   @Street = ISNULL(Address1,''),
			   @City = City,
			   @State = StateAbbr,
			   @Postal = ISNULL(Postal, ''),
			   @Phone = ISNULL(Phone, '')
		  FROM @tblCompany
		 WHERE ndx =@index

		IF OBJECT_ID('tempdb..#search_results') IS NOT NULL 
		BEGIN 
			DROP TABLE #search_results 
		END

		select dbo.HTTPS_POST_JSON_UTF8(
		@web_endpoint_business_search,
		'{"name": "' + @Name + '","street":"' + @Street + '","city": "' + @City + '","state": "' + @State + '","subcode": "' + @subcode + '","zip": "' + @Postal + '","phone": "' + @Phone + '"}',
		@auth_token_header
		) as json1
		into #search_results

		SELECT TOP 1 @json1 = json1 FROM #search_results

		INSERT INTO @tblSearchResults
		SELECT @CompanyID, bin, reliabilityCode, businessName, street, city, state, phone, numberOfTradelines from openjson(JSON_QUERY(@json1,'$.results'))
		WITH (
			bin varchar(255)  '$.bin',
			reliabilityCode decimal(6,3)  '$.reliabilityCode',
			businessName varchar(255)  '$.businessName',
			phone varchar(255)  '$.phone',
			street varchar(255) '$.address.street',
			city varchar(255) '$.address.city',
			state varchar(2) '$.address.state',
			numberOfTradelines int '$.numberOfTradelines'
		)
		WHERE bin NOT IN (SELECT BIN FROM @tblSearchResults)
		  AND city = @City
		  AND state= @State
	
	END

	IF (@Debug = 1) BEGIN
		SELECT prcex_BIN as CurrentBin, bin as MatchedBin, ReliabilityCode, BusinessName, Street, City, State, Phone, NumberOfTradelines
		 FROM @tblSearchResults 
			  LEFT OUTER JOIN PRCompanyExperian ON CompanyID=prcex_CompanyID
		ORDER BY ReliabilityCode DESC, NumberOfTradelines DESC
	END

	DECLARE @CompanyExperianID int, @Bin varchar(25), @ReliabilityCode decimal(6,3), @NumberOfTradelines int

	SELECT TOP 1 
		@Bin = Bin,
		@ReliabilityCode = ReliabilityCode,
		@NumberOfTradelines = NumberOfTradelines
	 FROM @tblSearchResults
	 ORDER BY ReliabilityCode DESC, NumberOfTradelines DESC
	 --WHERE ReliabilityCode > 75 -- Low Confidence
	 
	DECLARE @DupCount int = 0
	DECLARE @ReturnCode int
	DECLARE @ExperianMatches int
	DECLARE @Message varchar(max)

	IF (@Bin IS NOT NULL) BEGIN

		SET @ReturnCode = 0 -- SUCCESSFUL MATCH
		SET @Message = 'Successfully matched to BIN ' + @Bin + '.'

		SELECT @ExperianMatches = COUNT(1) FROM @tblSearchResults
		IF (@ReliabilityCode <= 85) BEGIN
			SET @ReturnCode = 2 -- FOUND MATCHES, BUT NONE ABOVE THRESHOLD
			SET @Bin = NULL
			SET @Message = 'Found ' + CAST(@ExperianMatches as varchar(10)) + ' matches, but none with a Reliability Code > 85.'
		END ELSE BEGIN
		 
			 SELECT @DupCount = COUNT(1)
			   FROM @tblSearchResults
			  WHERE ReliabilityCode = @ReliabilityCode
				AND NumberOfTradelines = @NumberOfTradelines

			IF (@DupCount > 1) BEGIN
				SET @ReturnCode = 3 -- FOUND MATCHES, BUT MULTIPLE
				SET @Bin = NULL
				SET @Message = 'Found ' + CAST(@ExperianMatches as varchar(10)) + ' matches, but ' + CAST(@DupCount as varchar(10)) + ' have the same reliability code and number of tradelines.'
			END
		END

	END ELSE BEGIN
		SET @ReturnCode = 1  -- NOT FOUND
		SET @Message = 'No matching Experian company found.'
	END


	--IF ((@Bin IS NOT NULL) AND (@Debug = 0)) BEGIN
	IF (@Debug = 0) BEGIN
		SELECT @CompanyExperianID = prcex_CompanyExperianID FROM PRCompanyExperian WHERE prcex_CompanyID = @CompanyID
		IF (@CompanyExperianID IS NULL)
		BEGIN
			exec usp_getNextId 'PRCompanyExperian', @CompanyExperianID output
			INSERT INTO PRCompanyExperian (prcex_CompanyExperianID, prcex_CompanyID, prcex_BIN, prcex_LastLookupDateTime, prcex_MatchConfidence, prcex_LookupCount, prcex_CreatedBy, prcex_CreatedDate)
			VALUES (@CompanyExperianID, @CompanyID, @Bin, @UpdatedDate, @ReliabilityCode, 1, @UpdatedUserID, @UpdatedDate);
		END
		ELSE
		BEGIN
			UPDATE PRCompanyExperian
			   SET prcex_BIN = @Bin,
				   prcex_LastLookupDateTime = @UpdatedDate,
				   prcex_MatchConfidence = @ReliabilityCode,
				   prcex_LookupCount = ISNULL(prcex_LookupCount, 0) + 1,
           prcex_SearchResultCode = @ReturnCode,
           prcex_SearchResultMessage = @Message,
				   prcex_UpdatedBy = @UpdatedUserID,
				   prcex_UpdatedDate = @UpdatedDate
			 WHERE prcex_CompanyExperianID = @CompanyExperianID;
		END
	END
	
	SELECT @ReturnCode as ReturnCode, @Message as Message
END
Go
