/* 
    This function formats a full person name for a listing line.
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_FormatPerson]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_FormatPerson]
GO
CREATE FUNCTION dbo.ufn_FormatPerson(@pers_FirstName varchar(30),
                                    @pers_LastName varchar(40), 
                                    @pers_MiddleName varchar(30),
                                    @pers_Nickname1 varchar(20),
                                    @pers_Suffix varchar(20)
)
RETURNS varchar(150) AS  
BEGIN
	--DECLARE @Person varchar(150)
	Return  dbo.ufn_FormatPerson2(@pers_FirstName, @pers_LastName, @pers_MiddleName, @pers_Nickname1, @pers_Suffix, 0)
	--Return @Person
END
Go


/* 
    This function formats a full person name for a listing line.
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_FormatPerson2]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_FormatPerson2]
GO
CREATE FUNCTION dbo.ufn_FormatPerson2(@pers_FirstName varchar(30),
                                    @pers_LastName varchar(40), 
                                    @pers_MiddleName varchar(30),
                                    @pers_Nickname1 varchar(20),
                                    @pers_Suffix varchar(20),
                                    @LastNameFirst tinyint = 0
)
RETURNS varchar(150) AS  
BEGIN 
	DECLARE @Person as varchar(150)

	IF (@LastNameFirst = 0) BEGIN
		SELECT @Person = 
			RTRIM(@pers_FirstName) + ' ' +
			COALESCE('(' + RTRIM(@pers_Nickname1) + ') ', '') + 
			COALESCE(RTRIM(@pers_MiddleName) + ' ', '') + 
			RTRIM(@pers_LastName) + 
			COALESCE(RTRIM(' ' + @pers_Suffix), '')
	END ELSE BEGIN
		SELECT @Person = 
		    RTRIM(@pers_LastName) + ', ' +
			RTRIM(@pers_FirstName) + ' ' +
			COALESCE('(' + RTRIM(@pers_Nickname1) + ') ', '') + 
			COALESCE(RTRIM(@pers_MiddleName) + ' ', '') + 
			COALESCE(RTRIM(' ' + @pers_Suffix), '')
	END

	-- Somtimes the suffix starts with a comma, sometimes it
    -- does not.  Remove any space before the comma.
	SET @Person = REPLACE(@Person, ' ,', ',')

	RETURN @Person
END
GO

/* 
    This function formats a phone number for a listing line.
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_FormatPhone]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_FormatPhone]
GO
CREATE FUNCTION dbo.ufn_FormatPhone(@Phon_CountryCode varchar(5),
                                    @Phon_AreaCode varchar(20), 
                                    @Phon_Number varchar(34),
                                    @phon_PRExtension varchar(5))  
RETURNS varchar(100) AS  
BEGIN 
	DECLARE @Phone as varchar(100)
	SET @Phone = 
	    CASE 
	        WHEN @Phon_CountryCode <> '1' THEN RTRIM(@Phon_CountryCode) + ' ' 
	        ELSE '' 
        END + 
        CASE WHEN @Phon_AreaCode IS NULL THEN '' ELSE RTRIM(@Phon_AreaCode) + ' ' END +
        RTRIM(@Phon_Number) + 
	CASE
			WHEN ASCII(RTRIM(@phon_PRExtension)) BETWEEN ASCII(0) AND ASCII(9) THEN ' Ext. ' + RTRIM(@phon_PRExtension) 
			WHEN @phon_PRExtension IS NOT NULL THEN ' ' + RTRIM(@phon_PRExtension) 
			ELSE ''
	END
	RETURN @Phone
END
GO

/* 
    This function applies line breaks in the passed string based upon a 34 character line.  Breaks
    will occur at the first space preceeding the word containing the 34th character.
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_ApplyListingLineBreaks2]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_ApplyListingLineBreaks2]
GO
CREATE FUNCTION dbo.ufn_ApplyListingLineBreaks2 ( 
    @OriginalString varchar(3000),
    @LineBreakChar varchar(50),
    @LineSize int
)
RETURNS varchar(6000)
AS

BEGIN
    DECLARE @FinalString varchar(1000)
    DECLARE @RemainingString varchar(1000)
    DECLARE @Position tinyint
    DECLARE @PosSpace tinyint
    DECLARE @LastSpaceOnLine tinyint

    SET @Position = 1
    SET @FinalString = ''

    IF (@OriginalString is null or (LEN(@OriginalString) <= @LineSize))
        RETURN @OriginalString
    ELSE
    BEGIN
        SET @RemainingString = @OriginalString
        WHILE (@Position < LEN(@RemainingString))
        BEGIN
            IF (LEN(@RemainingString) <= @LineSize)
            BEGIN
                SET @FinalString = @FinalString + @RemainingString
                BREAK
            END
            ELSE
            BEGIN
                -- find the last space prior to our line size        
                SET @PosSpace = CHARINDEX(' ', @RemainingString, @Position)
                WHILE (@PosSpace > 0 AND (@PosSpace <= @LineSize+1)) --look at the linesize + 1 to determine if the next char is a space
                BEGIN
                    SET @LastSpaceOnLine = @PosSpace
                    SET @PosSpace = CHARINDEX(' ', @RemainingString, @PosSpace+1)
                END
                SET @FinalString = @FinalString + SUBSTRING(@RemainingString, @Position, @LastSpaceOnLine - @Position) + @LineBreakChar
                SET @RemainingString = SUBSTRING(@RemainingString, @LastSpaceOnLine + 1, LEN(@RemainingString) - @LastSpaceOnLine )
                SET @Position = 1
            END
        END
        RETURN @FinalString
    END
    RETURN NULL
END
GO


/* 
    This function applies line breaks in the passed string based upon a 34 character line.  Breaks
    will occur at the first space preceeding the word containing the 34th character.
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_ApplyListingLineBreaks]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_ApplyListingLineBreaks]
GO
CREATE FUNCTION dbo.ufn_ApplyListingLineBreaks ( 
    @OriginalString varchar(3000),
    @LineBreakChar varchar(50)
)
RETURNS varchar(6000)
AS
BEGIN
	DECLARE @Return varchar(6000)
	SET @Return = dbo.ufn_ApplyListingLineBreaks2(@OriginalString, @LineBreakChar, 34)
	RETURN @Return
END
Go





/* 
    This function applies line breaks in the passed string based upon a the specified line
    length.  Also respects and handles any embedded line break characters.  Note: The line
    break characters are Char(10) & Char(10)Char(13); this is not the specified line break to 
    use to wrap the text.
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_ApplyListingLineBreaks3]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_ApplyListingLineBreaks3]
GO
CREATE FUNCTION dbo.ufn_ApplyListingLineBreaks3 ( 
    @OriginalString varchar(8000),
    @LineBreakChar varchar(50),
    @LineSize int
)
RETURNS varchar(8000)
AS
BEGIN

    IF (@OriginalString is null) BEGIN
        RETURN @OriginalString
	END

	DECLARE @LineCount int, @LineIndex int
	DECLARE @CurrentLine varchar(8000), @FinalString varchar(8000)

	DECLARE @tblLines table (
		ndx int primary key,
		Line varchar(8000)
	)

	-- The data migrated from the Paradox BBS system uses different line breaks
	-- than what the web browser uses for new PIKS data.  This makes them all
	-- the same for easier processing.
	SET @OriginalString = REPLACE(@OriginalString, CHAR(13), '')

	-- Split our text based on embedded line breaks
	INSERT INTO @tblLines (ndx, Line)
	SELECT idx, value 
      FROM dbo.Tokenize(@OriginalString, CHAR(10));

	SET @LineCount = @@ROWCOUNT;

	IF @LineCount = 1  BEGIN
		-- If we only have one (1) line, we're done
		SET @FinalString = dbo.ufn_ApplyListingLineBreaks2(@OriginalString, @LineBreakChar, @LineSize)
	END ELSE BEGIN
		
		-- Iterate through each of our lines
		SET @LineIndex = 0
        SET @FinalString = ''

		WHILE (@LineIndex < @LineCount) BEGIN
			SELECT @CurrentLine = Line
              FROM @tblLines
             WHERE ndx = @LineIndex;

			-- If our current buffer already has data, add
			-- a line break
			IF (LEN(@FinalString) > 0) BEGIN
				SET @FinalString = @FinalString + @LineBreakChar
			END

			SET @FinalString = @FinalString + dbo.ufn_ApplyListingLineBreaks2(@CurrentLine, @LineBreakChar, @LineSize)
			SET @LineIndex = @LineIndex + 1
		END

	END

	RETURN @FinalString
END
Go





/* 
    This function returns the sorting sequence for the specified phone type for a listing line.
*/
If Exists (Select name from sysobjects where name = 'ufn_GetListingPhoneSeq' and type in (N'FN', N'IF', N'TF')) Drop Function dbo.ufn_GetListingPhoneSeq
Go

CREATE FUNCTION [dbo].[ufn_GetListingPhoneSeq](@Type varchar(50), @Sequence Int) 
RETURNS int AS 
BEGIN 
DECLARE @Seq int
SET @Seq = COALESCE(@Sequence,0) 
DECLARE @SortCode int
SELECT @SortCode = CASE @Type
    WHEN 'P' THEN 1000 + @Seq
    WHEN 'TF' THEN 2000 + @Seq 
    WHEN 'S' THEN 3000 + @Seq
    WHEN 'TP' THEN 4000 + @Seq
    WHEN 'F' THEN 5000 + @Seq
    WHEN 'PF' THEN 6000 + @Seq
    WHEN 'SF' THEN 7000 + @Seq
    WHEN 'C' THEN 8000 + @Seq
    WHEN 'PA' THEN 9000 + @Seq
    ELSE @Seq
END;

RETURN @SortCode
END
Go


/* 
    This function replaces the last occurrence of the @FindVal with the @ReplaceVal
*/
If Exists (Select name from sysobjects where name = 'ufn_ReplaceLastOccurence' and type in (N'FN', N'IF', N'TF')) Drop Function dbo.ufn_ReplaceLastOccurence
Go

CREATE FUNCTION dbo.ufn_ReplaceLastOccurence(@CurrentVal varchar(1500), @FindVal varchar(50), @ReplaceVal varchar(50))  
RETURNS varchar(2000) AS  
BEGIN 
	DECLARE @ReturnVal varchar(2000)
	DECLARE @Pos int

	SET @ReturnVal = @CurrentVal

	-- Find the last occurrence
	SET @Pos = CHARINDEX(@FindVal, REVERSE(@ReturnVal))

	-- If we find an occurence, replace it.
	IF (@Pos > 0) BEGIN
		SET @Pos = LEN(@ReturnVal) + 1 - @Pos
		SET @ReturnVal = STUFF(@ReturnVal, @Pos, LEN(@FindVal), @ReplaceVal)
	END

	RETURN @ReturnVal
END
GO

/* 
    This function returns the listing block for the Phone information for the passed company
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetListingPhoneBlock]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_GetListingPhoneBlock]
GO
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ufn_GetListingPhoneBlock](  
    @CompanyId int,
    @LineBreakChar nvarchar(50)
)
RETURNS varchar(5000) 
AS  
BEGIN 

    DECLARE @RetVal varchar(5000)
	DECLARE @WorkArea varchar(5000)
	DECLARE @Line varchar(50)
    DECLARE @bBreak int
	DECLARE @Pos int

    IF (@LineBreakChar IS NULL)
        SET @LineBreakChar = '<br>'

	DECLARE @Type varchar(100), @Phone varchar(100), @SaveType varchar(100), @Description varchar(100), @SaveDescription varchar(100)

	DECLARE Phone_cur CURSOR LOCAL FAST_FORWARD FOR
	SELECT RTRIM(Capt_US) AS Type, RTRIM(phon_PRDescription) AS phon_PRDescription, dbo.ufn_FormatPhone(RTRIM(Phon_CountryCode), RTRIM(Phon_AreaCode), RTRIM(Phon_Number), RTRIM(phon_PRExtension)) AS Phone
	  FROM phone inner join Custom_Captions on phon_Type = capt_Code and capt_Family='phon_TypeCompany'
	 WHERE phon_CompanyID = @CompanyId
	   AND phon_PRPublish = 'Y' 
	   AND phon_Deleted IS NULL 
	ORDER BY dbo.ufn_GetListingPhoneSeq(phon_Type, phon_PRSequence)
	FOR READ ONLY;

	OPEN Phone_cur
	FETCH NEXT FROM Phone_cur INTO @Type, @Description, @Phone

	SET @SaveType = ''
	SET @SaveDescription = ''	

	WHILE @@Fetch_Status=0
	BEGIN

		SET @bBreak = 1

		IF @SaveType = @Type BEGIN
			IF @SaveDescription = @Description BEGIN
				SET @bBreak = 0
				IF (LEN(@Line) + 4 > 34) BEGIN -- Though we're only appending a ', ', assume 4 for ' or '
					SET @WorkArea = dbo.ufn_AppendListingString(@WorkArea, @Line + ',', @LineBreakChar)
					SET @Line = ''
				END ELSE BEGIN
					SET @Line = @Line + ','
				END
			END ELSE BEGIN
				SET @WorkArea = dbo.ufn_AppendListingString(@WorkArea, @Line, @LineBreakChar)
			END
		END ELSE BEGIN
			SET @WorkArea = dbo.ufn_AppendListingString(@WorkArea, @Line, @LineBreakChar)	
		END

	
		IF @bBreak = 1 BEGIN
			-- If we have a "last" comma, replace it 
            -- with an 'OR'
			SET @WorkArea = dbo.ufn_ReplaceLastOccurence(@WorkArea, ',', ' or')
			
			IF (@RetVal IS NULL) BEGIN
				SET @RetVal = @WorkArea
			END ELSE BEGIN
				SET @RetVal = @RetVal + @LineBreakChar + @WorkArea
			END

			SET @SaveType = @Type
			SET @SaveDescription = @Description
			SET @Line = @Description
            SET @WorkArea = NULL
		END
		
		IF (LEN(@Line) + LEN(@Phone) + 1 > 34) BEGIN
			SET @WorkArea = dbo.ufn_AppendListingString(@WorkArea, @Line, @LineBreakChar)
			SET @Line = @Phone
		END ELSE BEGIN
			SET @Line = @Line + ' ' + @Phone
		END

		FETCH NEXT FROM Phone_cur INTO @Type, @Description, @Phone
	End

	CLOSE Phone_cur
	DEALLOCATE Phone_cur

	-- Process our last entry...
	IF (@WorkArea IS NULL) BEGIN
		SET @WorkArea = @Line
	END ELSE BEGIN
		SET @WorkArea = @WorkArea + @LineBreakChar + @Line
	END

	-- If we have a "last" comma, replace it 
    -- with an 'OR'
	SET @WorkArea = dbo.ufn_ReplaceLastOccurence(@WorkArea, ',', ' or')

	IF (@RetVal IS NULL) BEGIN
		SET @RetVal = @WorkArea
	END ELSE BEGIN
		SET @RetVal = @RetVal + @LineBreakChar + @WorkArea
	END

    RETURN @RetVal
END
GO


/* 
    This function returns the listing block for the parenthetical information for the passed 
    HQ or branch company
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetListingParentheticalBlock]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_GetListingParentheticalBlock]
GO
CREATE FUNCTION dbo.ufn_GetListingParentheticalBlock ( 
    @CompanyId int,
    @LineBreakChar nvarchar(50)
)
RETURNS nvarchar(1000)
AS
BEGIN
    DECLARE @Paren1 nvarchar(1000)
    DECLARE @RetValue nvarchar(1000)
    DECLARE @prcp_CorporateStructure nvarchar(40)
    DECLARE @CorporateStructureDesc nvarchar(100)
    DECLARE @comp_PRLegalName nvarchar(60)
    DECLARE @comp_Name nvarchar(500)
    DECLARE @comp_PRListingCityId int
    DECLARE @comp_CountryId int
    DECLARE @comp_PRIndustryType nvarchar(40)
    DECLARE @comp_PRType nvarchar(40)
    DECLARE @comp_PRHQId int

    -- fields pertaining to a related company record
    DECLARE @RelatedCompanyId int
    DECLARE @RelComp_Name nvarchar(500)
    DECLARE @RelComp_PRLegalName nvarchar(60)
    DECLARE @RelComp_PRListingCityId int
    DECLARE @RelComp_CountryId int
    DECLARE @RelComp_City nvarchar(34)
    DECLARE @RelComp_State nvarchar(50)
    DECLARE @RelComp_Country nvarchar(30)
    DECLARE @RelComp_CreditWorth nvarchar(10)
    DECLARE @RelComp_PRIndustryType nvarchar(40)
    DECLARE @RelComp_PRListingStatus nvarchar(40)
    DECLARE @RelComp_PRIndustryTypeDesc nvarchar(100)

	DECLARE @Address varchar(200)
    DECLARE @UnderscoredAddress varchar(200)

    if (@LineBreakChar is null)
        SET @LineBreakChar = '<br>'

    -- get the relative company fields; we'll only get countryid if we need it.
    select  @comp_PRLegalName = comp_PRLegalName, 
            @comp_Name = comp_Name,
            @comp_PRIndustryType = comp_PRIndustryType,
            @comp_PRListingCityId = comp_PRListingCityId,
            @comp_PRType = comp_PRType,
            @comp_PRHQId = comp_PRHQId
    from company where comp_companyid = @CompanyId
    
    -- first parenthetical is the d/b/a
    select @comp_PRLegalName = comp_PRLegalName from company where comp_companyid = @CompanyId
    --SET @comp_PRLegalName = 'THIS IS 60 CHARACTER LEGAL NAME FOR LINEBRK TESTING PURPOSES'
    if (@comp_PRLegalName is not null)
        SET @Paren1 = '(A d/b/a of ' + @comp_PRLegalName + ')'

    SELECT @Paren1 = dbo.ufn_ApplyListingLineBreaks(@Paren1, @LineBreakChar)


    -- Parenthtical 2 is the entity type
    if (@comp_PRType = 'H')
    begin
        -- determine the entity type from the company profile record
        select @prcp_CorporateStructure = prcp_CorporateStructure from PRCompanyProfile where prcp_companyid = @CompanyId
        select @CorporateStructureDesc = capt_US from Custom_Captions 
            where capt_code = @prcp_CorporateStructure and capt_family = 'prcp_CorporateStructure'
    
        SET @RetValue = '(A ' + @CorporateStructureDesc + ')'
    
        --  Based upon the corporate structure, determine which rule to follow
        if (@prcp_CorporateStructure is null)
            SET @RetValue = NULL
        else if (@prcp_CorporateStructure = 'PROP')
        -- this encapsulates rules (a)
        begin
            declare @person_name nvarchar(125)
            SELECT @person_name = dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_MiddleName, NULL, pers_Suffix)
            from person_link
            join person on peli_PersonId = pers_Personid
            where peli_PROwnershipRole = 'RCO' and peli_PRStatus = 1
              AND peli_CompanyId = @CompanyId
    
            SET @RetValue = '(' + @person_name + ', Prop.)'
    
        end
        else if (@prcp_CorporateStructure in ('CORP', 'CCORP', 'SCORP'))
        -- this encapsulates rules (b) and (f) from the homework document
        begin
            if (@comp_Name like '%Inc.' or @comp_Name like '%Incorporated' or 
                @comp_Name like '%Corp.' or @comp_Name like '%Co.' or 
                @comp_Name like '%Company' or @comp_Name like '%Corporation' or 
                @comp_PRLegalName like '%Inc.' or @comp_PRLegalName like '%Incorporated' or 
                @comp_PRLegalName like '%Corp.' or @comp_PRLegalName like '%Co.' or 
                @comp_PRLegalName like '%Company' or @comp_PRLegalName like '%Corporation' 
               )
                SET @RetValue = ''
        end
        else if (@prcp_CorporateStructure = 'LLC')
        -- this encapsulates rules (e)
        begin
            if (@comp_Name like '%LLC' or @comp_Name like '%Limited Liability Company' or 
                @comp_Name like '%Limited Liability Co.' or
                @comp_PRLegalName like '%LLC' or @comp_PRLegalName like '%Limited Liability Company' or 
                @comp_PRLegalName like '%Limited Liability Co.' 
               )
                SET @RetValue = ''
        end
        
        -- Determine if relevant Company Relationships exist    
        select @RelatedCompanyId = prcr_LeftCompanyId from PRCompanyRelationship 
        where prcr_RightCompanyId = @CompanyId AND prcr_Type = '27'
        if (@RelatedCompanyId is not null)
        begin
            SET @RetValue = '(A Wholly Owned Subsidiary of ' 
        end
        else
        begin
            select @RelatedCompanyId = prcr_LeftCompanyId from PRCompanyRelationship 
            where prcr_RightCompanyId = @CompanyId AND prcr_Type = '28' AND prcr_OwnershipPct > 50
            if (@RelatedCompanyId is not null)
            begin
                SET @RetValue = '(A Subsidiary of ' 
            end
        end
        if (@RelatedCompanyId is not null)
        -- this encapsulates rule (c) from the homework document
        begin
            --get the relevant info for the related company
            select  @RelComp_PRLegalName = comp_PRLegalName, 
                    @RelComp_Name = comp_Name,
                    @RelComp_PRIndustryType = comp_PRIndustryType,
                    @RelComp_PRListingStatus = comp_PRListingStatus,
                    @RelComp_PRListingCityId = comp_PRListingCityId,
                    @RelComp_CountryId = prcn_CountryId,
                    @RelComp_City = prci_City,
                    @RelComp_State = prst_State,
                    @RelComp_Country = prcn_Country,
                    @RelComp_CreditWorth = prcw_Name
            from company 
            JOIN PRCity ON comp_PRListingCityId = prci_CityId 
            JOIN PRState ON prci_StateId = prst_StateId 
            JOIN PRCountry ON prst_CountryId = prcn_CountryId 
            LEFT OUTER JOIN PRRating on comp_companyid = prra_CompanyId and prra_Current = 'Y'
            LEFT OUTER JOIN PRCreditWorthRating on prra_CreditWorthId = prcw_CreditWorthRatingId
            where comp_companyid = @RelatedCompanyId
    
            -- Add the company name
            SET @RetValue = @RetValue + @RelComp_Name + ', '

            -- get the country id
            select  @comp_CountryId = prst_CountryId
            from company 
            JOIN PRCity ON comp_PRListingCityId = prci_CityId 
            JOIN PRState ON prci_StateId = prst_StateId 
            where comp_companyid = @CompanyId
    
			SET @Address = @RelComp_City + ', ' + @RelComp_State
			SET @UnderscoredAddress = REPLACE(@RelComp_City, ' ', '_') + ', ' + REPLACE(@RelComp_State, ' ', '_')

			if (@comp_CountryId != @RelComp_CountryId)
			BEGIN
				SET @Address = @Address + ', ' + @RelComp_Country 
				SET @UnderscoredAddress = @UnderscoredAddress + ', ' + REPLACE(@RelComp_Country, ' ', '_') 
			END
			
            -- set spaces to underscores so the field cannot break lines
            SET @RetValue = @RetValue + @UnderscoredAddress
    
            if (@RelComp_PRListingStatus = 'L')
                SET @RetValue = @RetValue + ', BBID #' + convert(varchar(15), @RelatedCompanyId)
            else
            begin
                if (@RelComp_CreditWorth is not null)
                    SET @RetValue = @RetValue + ' ' + @RelComp_CreditWorth
            end
            SET @RetValue = @RetValue + ')'
        end
    end
    -- this should be a branch but make sure
    else if (@comp_PRType = 'B')
    begin
        -- get relevent information for the related company; in this case the HQ
        select  @RelComp_PRLegalName = comp_PRLegalName, 
                @RelComp_Name = comp_Name,
                @RelComp_PRIndustryType = comp_PRIndustryType,
                @RelComp_PRIndustryTypeDesc = capt_US,
                @RelComp_PRListingStatus = comp_PRListingStatus,
                @RelComp_PRListingCityId = comp_PRListingCityId,
                @RelComp_CountryId = prcn_CountryId,
                @RelComp_City = prci_City,
                @RelComp_State = prst_Abbreviation, --prst_State,
                @RelComp_Country = prcn_Country,
                @RelComp_CreditWorth = prcw_Name
        from company 
        JOIN PRCity ON comp_PRListingCityId = prci_CityId 
        JOIN PRState ON prci_StateId = prst_StateId 
        JOIN PRCountry ON prst_CountryId = prcn_CountryId 
        LEFT OUTER JOIN PRRating on comp_companyid = prra_CompanyId and prra_Current = 'Y'
        LEFT OUTER JOIN PRCreditWorthRating on prra_CreditWorthId = prcw_CreditWorthRatingId
        JOIN Custom_Captions On comp_PRIndustryType = capt_Code and capt_Family = 'comp_PRIndustryType'
        where comp_companyid = @comp_PRHQId
    
        -- get the country id
        select  @comp_CountryId = prst_CountryId
        from company 
        JOIN PRCity ON comp_PRListingCityId = prci_CityId 
        JOIN PRState ON prci_StateId = prst_StateId 
        where comp_companyid = @CompanyId

		SET @Address = @RelComp_City + ', ' + @RelComp_State
		SET @UnderscoredAddress = REPLACE(@RelComp_City, ' ', '_') + ', ' + REPLACE(@RelComp_State, ' ', '_')

        if (@comp_CountryId != @RelComp_CountryId)
        BEGIN
            SET @Address = @Address + ', ' + @RelComp_Country 
            SET @UnderscoredAddress = @UnderscoredAddress + ', ' + REPLACE(@RelComp_Country, ' ', '_') 
        END
		
        if (@comp_PRListingCityId = @RelComp_PRListingCityId)
        begin
            SET @RetValue = '(See ' + @RelComp_Name + 
                            ', BB# ' + convert(varchar(20), @comp_PRHQId) +
                            ', ' + @UnderscoredAddress 
            if (@RelComp_PRIndustryType is not null and @comp_PRIndustryType != @RelComp_PRIndustryType)
                SET @RetValue = @RetValue + ' in ' + @RelComp_PRIndustryTypeDesc + ' section'
            SET @RetValue = @RetValue + ')'
        end
        else 
        begin

            if (@RelComp_Name != @comp_Name)
                SET @RetValue = '(See ' + @RelComp_Name + ', '
            else
                SET @RetValue = '(See '

            SET @RetValue = @RetValue + @UnderscoredAddress
    
            if (@RelComp_PRIndustryType is not null and @comp_PRIndustryType != @RelComp_PRIndustryType)
                SET @RetValue = @RetValue + ' in ' + @RelComp_PRIndustryTypeDesc + ' section'

            SET @RetValue = @RetValue + ')'

        end
    end

    SELECT @RetValue = dbo.ufn_ApplyListingLineBreaks(@RetValue, @LineBreakChar)
    
	-- Replace the underscored city, state, and country with the "spaced" equivalents
    IF (@UnderscoredAddress IS NOT NULL) BEGIN
 	    -- This doesn't work if the address spans multipe lines.  Checked w/MRR
		-- and it was agreed to blindly replace all underscores for now.
		-- SET @RetValue = REPLACE(@RetValue, @UnderscoredAddress, @Address)
		SET @RetValue = REPLACE(@RetValue, '_', ' ')
	END
    if (@Paren1 is not null and @Paren1 != '')
        if (@RetValue is not null and @RetValue != '')
            SET @RetValue = @Paren1 + @LineBreakChar + @RetValue
        else 
            SET @RetValue = @Paren1
    
    RETURN @RetValue
END
GO


/* 
    This function returns the listing block for the email and website addresses 
    for the passed company id.
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetListingInternetBlock]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_GetListingInternetBlock]
GO
CREATE FUNCTION [dbo].[ufn_GetListingInternetBlock] ( 
    @CompanyId int,
    @LineBreakChar nvarchar(50)
)
RETURNS nvarchar(1000)
AS
BEGIN

    DECLARE @RetVal varchar(5000)
	DECLARE @WorkArea varchar(5000)
	DECLARE @Line varchar(50)
    DECLARE @bBreak int
	DECLARE @Pos int

    IF (@LineBreakChar IS NULL)
        SET @LineBreakChar = '<br>'

	DECLARE @Type varchar(100), @TypeCode varchar(40), @Address varchar(100),
     @Description varchar(100), @WebAddress varchar(100), @SaveType varchar(100), @SaveDescription varchar(100)
    DECLARE @DelimiterIndex int, @PartA varchar(500), @PartB varchar(500)

	DECLARE Internet_cur CURSOR LOCAL FAST_FORWARD FOR
	SELECT RTRIM(Capt_US) AS Type, RTRIM(emai_Type) AS TypeCode, 
     RTRIM(ISNULL(Emai_EmailAddress,'')) AS Address, RTRIM(ISNULL(Emai_PRWebAddress,'')) as WebAddress,
     COALESCE(emai_PRDescription + ':','')
	  FROM email inner join Custom_Captions on emai_Type = capt_Code and capt_Family='emai_Type'
	 WHERE emai_CompanyID = @CompanyId
	   AND emai_PRPublish = 'Y' 
	   AND emai_Deleted IS NULL 
	ORDER BY emai_Type, emai_PRSequence
	FOR READ ONLY;

	OPEN Internet_cur
	FETCH NEXT FROM Internet_cur INTO @Type, @TypeCode, @Address, @WebAddress, @Description

	SET @SaveType = ''
    SET @SaveDescription = ''

	WHILE @@Fetch_Status=0
	BEGIN

		IF @TypeCode = 'W' BEGIN
			SET @Address = @WebAddress
		END

		SET @bBreak = 1
		
		IF @SaveType = @Type BEGIN
			IF @SaveDescription = @Description BEGIN
				SET @bBreak = 0
				IF (LEN(@Line) + 4 > 34) BEGIN -- Though we're only appending a ', ', assume 4 for ' or '
					SET @WorkArea = dbo.ufn_AppendListingString(@WorkArea, @Line + ',', @LineBreakChar)
					SET @Line = ''
				END ELSE BEGIN
					SET @Line = @Line + ','
				END
			END ELSE BEGIN
				SET @WorkArea = dbo.ufn_AppendListingString(@WorkArea, @Line, @LineBreakChar)
			END
		END ELSE BEGIN
			SET @WorkArea = dbo.ufn_AppendListingString(@WorkArea, @Line, @LineBreakChar)	
		END

		IF @bBreak = 1 BEGIN

			-- If we have a "last" comma, replace it 
            -- with an 'OR'
			SET @WorkArea = dbo.ufn_ReplaceLastOccurence(@WorkArea, ',', ' or')

			IF (@RetVal IS NULL) BEGIN
				SET @RetVal = @WorkArea
			END ELSE BEGIN
				SET @RetVal = @RetVal + @LineBreakChar + @WorkArea
			END

			SET @SaveType = @Type
			SET @SaveDescription = @Description
			SET @Line = @Description
            SET @WorkArea = NULL
		END

		-- Can we add our address to the current line
		-- Without blowing the margin?
		IF (LEN(@Line) + LEN(@Address) + 1 > 34) BEGIN

			-- Setup our delimiter based on the type
			IF (@TypeCode = 'E') BEGIN
				SET @DelimiterIndex = CHARINDEX('@', @Address)
			END ELSE BEGIN
				SET @DelimiterIndex = CHARINDEX('.', @Address)
			END 

			-- Break the account into two portions
			-- to see what we can fit on the line.
			SET @PartA = SUBSTRING(@Address, 1, @DelimiterIndex-1)
            SET @PartB = SUBSTRING(@Address, @DelimiterIndex, LEN(@Address)-@DelimiterIndex+1)

			-- If the first portion fits, add it.
			IF (LEN(@Line) + LEN(@PartA) + 1 <= 34) BEGIN
				SET @Line = @Line + ' ' + @PartA
				SET @WorkArea = dbo.ufn_AppendListingString(@WorkArea, @Line, @LineBreakChar)

				-- Now deal with the second part
				IF (LEN(@PartB) > 34) BEGIN
					WHILE (LEN(@PartB) > 34) BEGIN
						SET @Line = SUBSTRING(@PartB, 1, 34)
						SET @WorkArea = dbo.ufn_AppendListingString(@WorkArea, @Line, @LineBreakChar)
                        SET @PartB = SUBSTRING(@PartB, 35, LEN(@PartB) - 34)
					END
					SET @Line = @PartB
				END ELSE BEGIN
					SET @Line = @PartB	
				END		

			-- The first portion doesn't fit so try putting the entire
			-- address on the next line.
			END ELSE BEGIN
				SET @WorkArea = dbo.ufn_AppendListingString(@WorkArea, @Line, @LineBreakChar)
					
				IF (LEN(@Address) > 34) BEGIN
					WHILE (LEN(@Address) > 34) BEGIN
						SET @WorkArea = SUBSTRING(@Address, 1, 34)
						SET @WorkArea = dbo.ufn_AppendListingString(@WorkArea, @Line, @LineBreakChar)
                        SET @Address = SUBSTRING(@Address, 35, LEN(@Address) - 34)
					END
					
					SET @Line = @Address
				END ELSE BEGIN
					SET @Line = @Address	
				END		

			END
		END ELSE BEGIN
			SET @Line = @Line + ' ' + @Address
		END

		FETCH NEXT FROM Internet_cur INTO @Type, @TypeCode, @Address, @WebAddress, @Description
		
	END

	CLOSE Internet_cur
	DEALLOCATE Internet_cur

	-- Process our last entry...
	IF (@WorkArea IS NULL) BEGIN
		SET @WorkArea = @Line
	END ELSE BEGIN
		SET @WorkArea = @WorkArea + @LineBreakChar + @Line
	END

	-- If we have a "last" comma, replace it 
    -- with an 'OR'
	SET @WorkArea = dbo.ufn_ReplaceLastOccurence(@WorkArea, ',', ' or')

	IF (@RetVal IS NULL) BEGIN
		SET @RetVal = @WorkArea
	END ELSE BEGIN
		SET @RetVal = @RetVal + @LineBreakChar + @WorkArea
	END

    RETURN @RetVal
END
GO



/* 
    This function appends the Append text to the Current text, applying 
    line breaks as necessary.
*/
If Exists (Select name from sysobjects where name = 'ufn_AppendListingString' and type in (N'FN', N'IF', N'TF')) Drop Function dbo.ufn_AppendListingString
Go

CREATE FUNCTION dbo.ufn_AppendListingString(@Current varchar(4000),
                                            @Append varchar(1000), 
                                            @LineBreakChar varchar(50))  
RETURNS varchar(5000) AS  
BEGIN

	-- Do we have a value to append?
	IF (@Append IS NOT NULL) BEGIN

		-- Do we have a value to append to?
		IF (@Current IS NULL) BEGIN
			SET @Current = dbo.ufn_ApplyListingLineBreaks(@Append, @LineBreakChar)
		END ELSE BEGIN
		    SET @Current = @Current + @LineBreakChar + dbo.ufn_ApplyListingLineBreaks(@Append, @LineBreakChar)
		END
	END

	RETURN @Current
END
Go



/* 
    This function formats the address for a listing line.
*/
If Exists (Select name from sysobjects where name = 'ufn_FormatAddress' and type in (N'FN', N'IF', N'TF')) Drop Function dbo.ufn_FormatAddress
Go

CREATE FUNCTION dbo.ufn_FormatAddress(@LineBreakChar varchar(50),
                                      @Description varchar(50),
									  @Address1 varchar(50),
									  @Address2 varchar(50),
									  @Address3 varchar(50),
									  @Address4 varchar(50),
									  @Address5 varchar(50),
									  @City varchar(50),
									  @State varchar(50),
									  @Country varchar(50),
									  @Postal varchar(50),
                                      @ListingCityID int,
                                      @Type varchar(40))  
RETURNS varchar(5000) AS  
BEGIN

	IF (@LineBreakChar is null)
		SET @LineBreakChar = '<br>'

	DECLARE @RetVal varchar(1000)
	DECLARE @LastLine varchar(1000)

	DECLARE @DisplayedCity bit, @DisplayedPostal bit, @DisplayedState bit, @DisplayedCountry bit

	SET @DisplayedCity = 0
	SET @DisplayedPostal = 0
	SET @DisplayedState = 0
	SET @DisplayedCountry = 0

	IF (@Address1 IS NOT NULL) BEGIN
		IF (@Address2 IS NULL) BEGIN
			SET @LastLine = ISNULL(@Description + ' ', '') + @Address1
		END ELSE BEGIN
			SET @RetVal = dbo.ufn_AppendListingString(@RetVal, ISNULL(@Description + ' ', '') + @Address1, @LineBreakChar)

			IF (@Address3 IS NULL) BEGIN
				SET @LastLine = @Address2
			END ELSE BEGIN
				SET @RetVal = dbo.ufn_AppendListingString(@RetVal, @Address2, @LineBreakChar)

				IF (@Address4 IS NULL) BEGIN
					SET @LastLine = @Address3
				END ELSE BEGIN
					SET @RetVal = dbo.ufn_AppendListingString(@RetVal, @Address3, @LineBreakChar)

					IF (@Address5 IS NULL) BEGIN
						SET @LastLine = @Address4
					END ELSE BEGIN
						SET @RetVal = dbo.ufn_AppendListingString(@RetVal, @Address4, @LineBreakChar)
						SET @LastLine = @Address5
					END
				END
			END
		END
	END

	--SET @LastLine = @LastLine + ','

	-- If our last line is > 34, we need to break it
    -- before we process the city, state, & country
	IF (LEN(@LastLine) > 34) BEGIN
			DECLARE @Pos int
			DECLARE @Pos2 int

			SET @LastLine = dbo.ufn_ApplyListingLineBreaks(@LastLine, @LineBreakChar)
			SET @Pos = CHARINDEX(@LineBreakChar, @LastLine)
			SET @RetVal = dbo.ufn_AppendListingString(@RetVal, SUBSTRING(@LastLine, 1, @Pos-1), @LineBreakChar)

			SET @Pos2 = @Pos + LEN(@LineBreakChar)
			SET @LastLine = SUBSTRING(@LastLine, @Pos2, LEN(@LastLine) - @Pos2 + 1)
	END

	DECLARE @ListingCity varchar(50), @ListingState varchar(50), @ListingCountry varchar(50)
	SELECT @ListingCity = prci_City,
           @ListingState = ISNULL(prst_Abbreviation, prst_State),
           @ListingCountry = prcn_Country
      FROM PRState LEFT OUTER JOIN
           PRCountry ON PRState.prst_CountryId = PRCountry.prcn_CountryId RIGHT OUTER JOIN
           PRCity ON PRState.prst_StateId = PRCity.prci_StateId 
     WHERE prci_CityID = @ListingCityID;

    IF (@ListingCity <> @City) BEGIN
		SET @DisplayedCity = 1
		IF (LEN(@LastLine) + LEN(@City) + 1) > 34 BEGIN
			SET @RetVal = dbo.ufn_AppendListingString(@RetVal, @LastLine, @LineBreakChar)
			SET @LastLine = @City
		END ELSE BEGIN
			SET @LastLine = @LastLine + ' ' + @City
		END
	END

    IF (@ListingState <> @State) BEGIN
		SET @DisplayedState = 1
		IF (LEN(@LastLine) + LEN(@State) + 3) > 34 BEGIN
			SET @RetVal = dbo.ufn_AppendListingString(@RetVal, @LastLine, @LineBreakChar)
			SET @LastLine = @State
		END ELSE BEGIN
			SET @LastLine = @LastLine + ', ' + @State
		END
	END

	IF ((@Postal IS NOT NULL) AND (@Type = 'M')) BEGIN
		SET @DisplayedPostal = 1

		IF (SUBSTRING(@LastLine, LEN(@LastLine), 1) <> '.') BEGIN
			SET @LastLine = @LastLine + '.'
		END

		IF (LEN(@LastLine) + LEN(@Postal) + 3) > 34 BEGIN
			SET @RetVal = dbo.ufn_AppendListingString(@RetVal, @LastLine, @LineBreakChar)
			SET @LastLine = '(' + @Postal + ')'
		END ELSE BEGIN
			SET @LastLine = @LastLine + ' (' + @Postal + ')'
		END
	END 

    IF (@ListingCountry <> @Country) BEGIN
		SET @DisplayedCountry = 1
		IF (LEN(@LastLine) + LEN(@Country) + 3) > 34 BEGIN
			SET @RetVal = dbo.ufn_AppendListingString(@RetVal, @LastLine, @LineBreakChar)
			SET @LastLine = @Country
		END ELSE BEGIN
			SET @LastLine = @LastLine + ', ' + @Country
		END

		IF (SUBSTRING(@LastLine, LEN(@LastLine), 1) <> '.') BEGIN
			SET @LastLine = @LastLine + '.'
		END
	END



	SET @RetVal = dbo.ufn_AppendListingString(@RetVal, @LastLine, @LineBreakChar)
	
	RETURN @RetVal
END
Go



If Exists (Select name from sysobjects where name = 'ufn_GetAddressListSeq' and type='FN') Drop Function dbo.ufn_GetAddressListSeq
Go

CREATE FUNCTION dbo.ufn_GetAddressListSeq(@AdLi_Type varchar(40))  
RETURNS int AS  
BEGIN 

	DECLARE @SortCode int
	SELECT @SortCode = CASE @AdLi_Type
 		WHEN 'M' THEN 1
		WHEN 'PH' THEN 2	
		WHEN 'I' THEN 3
		WHEN 'W' THEN 4
		ELSE 99
	END;

	RETURN @SortCode
END
Go





/* 
    This function returns the listing block for the Address information for the passed company
*/
If Exists (Select name from sysobjects where name = 'ufn_GetListingAddressBlock' and type in (N'FN', N'IF', N'TF')) Drop Function dbo.ufn_GetListingAddressBlock
Go

CREATE FUNCTION dbo.ufn_GetListingAddressBlock(@CompanyID int,
                                               @LineBreakChar varchar(50))  
RETURNS varchar(1000) AS  
BEGIN 

	IF (@LineBreakChar is null)
		SET @LineBreakChar = '<br>'

	DECLARE @RetVal varchar(5000)

	SELECT @RetVal = COALESCE(@RetVal + @LineBreakChar, '') + Address
      FROM(SELECT TOP 2 dbo. ufn_FormatAddress(@LineBreakChar,
                   RTRIM(Addr_PRDescription),
				   RTRIM(Addr_Address1), 
				   RTRIM(Addr_Address2), 
				   RTRIM(Addr_Address3), 
				   RTRIM(Addr_Address4), 
				   RTRIM(Addr_Address5), 
				   RTRIM(prci_City), 
				   ISNULL(RTRIM(prst_Abbreviation), RTRIM(prst_State)), 
				   RTRIM(prcn_Country), 
				   RTRIM(Addr_PostCode),
                   comp_PRListingCityId,
                   adli_Type) as Address
              FROM Company INNER JOIN
                   Address INNER JOIN
                   Address_Link ON Addr_AddressId = AdLi_AddressId ON 
                   Comp_CompanyId = AdLi_CompanyID LEFT OUTER JOIN
                   PRState LEFT OUTER JOIN
                   PRCountry ON prst_CountryId = prcn_CountryId RIGHT OUTER JOIN
                   PRCity ON prst_StateId = prci_StateId ON addr_PRCityId = prci_CityId
			 WHERE adli_CompanyID=@CompanyID
			   AND addr_PRPublish = 'Y'
			   AND Addr_Deleted IS NULL
			ORDER BY dbo.ufn_GetAddressListSeq(adli_Type)) T1;

	RETURN @RetVal
END
Go


/* 
    This function returns the listing block for the Brand information for the passed company
*/
If Exists (Select name from sysobjects where name = 'ufn_GetListingBrandBlock' and type in (N'FN', N'IF', N'TF')) Drop Function dbo.ufn_GetListingBrandBlock
Go

CREATE FUNCTION dbo.ufn_GetListingBrandBlock(@CompanyID int,
                                              @LineBreakChar varchar(50))  
RETURNS varchar(1000) AS  
BEGIN 

	IF (@LineBreakChar is null)
		SET @LineBreakChar = '<br>'

	DECLARE @RetVal varchar(5000)

	SELECT @RetVal = COALESCE(@RetVal + ', ', '') + prc3_Brand
	FROM (SELECT prc3_Brand, MIN(prc3_Sequence) AS Sequence
            FROM PRCompanyBrand
           WHERE prc3_CompanyID = @CompanyID
             AND prc3_Publish = 'Y'
             AND prc3_Deleted IS NULL
        GROUP BY prc3_Brand) TABLE1
    ORDER BY Sequence;

	-- Now add our prefix
	IF (@RetVal IS NOT NULL) BEGIN
		DECLARE @Count int
		SELECT @Count = COUNT(DISTINCT prc3_Brand)
		  FROM PRCompanyBrand
		 WHERE prc3_CompanyID = @CompanyID
		   AND prc3_Publish = 'Y'
		   AND prc3_Deleted IS NULL

		IF (@Count > 1) BEGIN
			SET @RetVal = 'Brands: ' + @RetVal
		END ELSE BEGIN
			SET @RetVal = 'Brand: ' + @RetVal
		END
	END

	RETURN dbo.ufn_ApplyListingLineBreaks(@RetVal, @LineBreakChar)
END
Go



/* 
    This function returns the listing block for the Warehouse Unload Hours information for the passed company
*/
If Exists (Select name from sysobjects where name = 'ufn_GetListingUnloadHoursBlock' and type in (N'FN', N'IF', N'TF')) Drop Function dbo.ufn_GetListingUnloadHoursBlock
Go

CREATE FUNCTION dbo.ufn_GetListingUnloadHoursBlock(@CompanyID int,
                                                   @LineBreakChar varchar(50))  
RETURNS varchar(1000) AS  
BEGIN 

	IF (@LineBreakChar is null)
		SET @LineBreakChar = '<br>'

	DECLARE @RetVal varchar(5000), @PublishUnloadHours char(1)

    SELECT @RetVal = comp_PRUnloadHours,
           @PublishUnloadHours = comp_PRPublishUnloadHours
      FROM Company
     WHERE comp_CompanyID = @CompanyID
       AND comp_PRUnloadHours IS NOT NULL
       AND comp_Deleted IS NULL;

	IF (@PublishUnloadHours = 'Y') BEGIN

		-- The data has CHAR(10) embedded.  Ensure we return the string
		-- with whatever linebreak character is specified.
		SET @RetVal = REPLACE(@RetVal, CHAR(10), @LineBreakChar)
	END ELSE BEGIN
		SET @RetVal = NULL
	END

	RETURN @RetVal
END
Go



/* 
    This function returns the listing block for the Descriptive LIne information for the passed company
*/
If Exists (Select name from sysobjects where name = 'ufn_GetListingDLBlock' and type in (N'FN', N'IF', N'TF')) Drop Function dbo.ufn_GetListingDLBlock
Go

CREATE FUNCTION dbo.ufn_GetListingDLBlock(@CompanyID int,
                                          @LineBreakChar varchar(50))  
RETURNS varchar(4000) AS  
BEGIN 

	DECLARE @RetVal varchar(4000)
	DECLARE @PublishDL char(1)

	SELECT @PublishDL = comp_PRPublishDL
      FROM Company
     WHERE comp_CompanyID = @CompanyID;

	IF (@PublishDL = 'Y') BEGIN

		IF (@LineBreakChar is null)
			SET @LineBreakChar = '<br>'


		-- line content can be null for a blank line so coalesce it out, otherwise all content
		-- before the blank line will be erased
		SELECT @RetVal = COALESCE(@RetVal + @LineBreakChar, '') + COALESCE(prdl_LineContent, '')  
		  FROM PRDescriptiveLine
		 WHERE prdl_CompanyID = @CompanyID
		   AND prdl_Deleted IS NULL
		 order by prdl_DescriptiveLineId; -- TODO determine if this table should have a sequence field
	END

	RETURN @RetVal
END
Go



/* 
    This function returns the formatted stock exchange data for a listing line.
*/
If Exists (Select name from sysobjects where name = 'ufn_FormatStockSymbols' and type in (N'FN', N'IF', N'TF')) Drop Function dbo.ufn_FormatStockSymbols
Go

CREATE FUNCTION dbo.ufn_FormatStockSymbols(@LineBreakChar varchar(50),
									  @Name varchar(50),
									  @Symbol1 varchar(50),
									  @Symbol2 varchar(50),
									  @Symbol3 varchar(50))  
RETURNS varchar(5000) AS  
BEGIN

	IF (@LineBreakChar is null)
		SET @LineBreakChar = '<br>'

	DECLARE @RetVal varchar(1000)

	SET @RetVal = @Name + ': ' + @Symbol1
	
	IF (@Symbol2 IS NOT NULL) BEGIN
		SET @RetVal = @RetVal + ', ' + @Symbol2
	END

	IF (@Symbol3 IS NOT NULL) BEGIN
		SET @RetVal = @RetVal + ', ' + @Symbol3
	END

	RETURN dbo.ufn_ApplyListingLineBreaks(@RetVal, @LineBreakChar)
END
Go

/* 
    This function returns the listing block for the Bank information for the passed company
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetListingBankBlock]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_GetListingBankBlock]
GO
CREATE FUNCTION dbo.ufn_GetListingBankBlock ( 
    @CompanyId int,
    @LineBreakChar nvarchar(50)
)
RETURNS nvarchar(1000)
AS
BEGIN
    DECLARE @RetValue nvarchar(1000)

	IF (@LineBreakChar is null)
		SET @LineBreakChar = '<br>'

	DECLARE @RetVal varchar(5000)
    DECLARE @Count int 

	SELECT @RetVal = COALESCE(@RetVal + ', ', '') + prcb_Name
	FROM (SELECT prcb_Name
            FROM PRCompanyBank
           WHERE prcb_CompanyID =  @CompanyID
             AND prcb_Publish = 'Y'
             AND prcb_Deleted IS NULL
         ) TABLE1
    SET @Count = @@ROWCOUNT
	-- Now add our prefix
	IF (@Count > 1) 
    BEGIN
		SET @RetVal = 'Banks: ' + @RetVal
	END ELSE BEGIN
		SET @RetVal = 'Bank: ' + @RetVal
	END

	RETURN dbo.ufn_ApplyListingLineBreaks(@RetVal, @LineBreakChar)
END
GO

/* 
    This function returns the listing block for the Stock Exchange information for the passed company
*/
If Exists (Select name from sysobjects where name = 'ufn_GetListingStockExchangeBlock' and type in (N'FN', N'IF', N'TF')) Drop Function dbo.ufn_GetListingStockExchangeBlock
Go

CREATE FUNCTION dbo.ufn_GetListingStockExchangeBlock(@CompanyID int,
                                                     @LineBreakChar varchar(50))  
RETURNS varchar(1000) AS  
BEGIN 

	IF (@LineBreakChar is null)
		SET @LineBreakChar = '<br>'

	DECLARE @RetVal varchar(5000)

	SELECT @RetVal = COALESCE(@RetVal + @LineBreakChar, '') + StockSymbol
      FROM (
		SELECT TOP 1000 dbo.ufn_FormatStockSymbols(@LineBreakChar, prex_Name, prc4_Symbol1, prc4_Symbol2, prc4_Symbol3) as StockSymbol
		  FROM PRStockExchange,
               PRCompanyStockExchange
         WHERE prex_StockExchangeID = prc4_StockExchangeID
           AND prc4_CompanyId = @CompanyID
           AND prex_Publish = 'Y'
           AND prc4_Deleted IS NULL
           AND prex_Deleted IS NULL
      ORDER BY prex_Order) AS TABLE1

	RETURN @RetVal
END
Go



/* 
    This function returns the sorting sequence for the specified license type for a listing line.
*/
If Exists (Select name from sysobjects where name = 'ufn_GetListingLicenseSeq' and type in (N'FN', N'IF', N'TF')) Drop Function dbo.ufn_GetListingLicenseSeq
Go

CREATE FUNCTION dbo.ufn_GetListingLicenseSeq(@Type varchar(50))  
RETURNS int AS  
BEGIN 

	DECLARE @SortCode int
	SELECT @SortCode = CASE @Type
 		WHEN 'PACA' THEN 1
		WHEN 'DRC'  THEN 2	
		WHEN 'CFIA' THEN 3
		WHEN 'DOT'  THEN 4
		WHEN 'MC'   THEN 5
		WHEN 'FF'   THEN 6
		ELSE 99
	END;

	RETURN @SortCode
END
Go



/* 
    This function returns the listing block for the License information for the passed company
*/
If Exists (Select name from sysobjects where name = 'ufn_GetListingLicenseBlock' and type in (N'FN', N'IF', N'TF')) Drop Function dbo.ufn_GetListingLicenseBlock
Go

CREATE FUNCTION dbo.ufn_GetListingLicenseBlock(@CompanyID int,
                                                     @LineBreakChar varchar(50))  
RETURNS varchar(1000) AS  
BEGIN 

	IF (@LineBreakChar is null)
		SET @LineBreakChar = '<br>'

	DECLARE @RetVal varchar(1000)

	SELECT @RetVal = COALESCE(@RetVal + @LineBreakChar, '') + dbo.ufn_ApplyListingLineBreaks(Name + License, @LineBreakChar)
	 FROM (
		SELECT dbo.ufn_GetListingLicenseSeq('PACA') AS Seq, 'PACA License #' AS Name, prpa_LicenseNumber As License
		  FROM CRM.dbo.PRPACALicense
		 WHERE prpa_CompanyID = @CompanyID
		   AND prpa_Deleted IS NULL
		   AND prpa_Publish = 'Y'
		   AND prpa_Current = 'Y'
		UNION
		SELECT dbo.ufn_GetListingLicenseSeq('DRC'), 'DRC #', prdr_LicenseNumber
		  FROM CRM.dbo.PRDRCLicense
		 WHERE prdr_CompanyID = @CompanyID
		   AND prdr_Publish = 'Y'
		   AND prdr_Deleted IS NULL
		UNION
		SELECT dbo.ufn_GetListingLicenseSeq(prli_Type), CASE WHEN prli_Type = 'CFIA' THEN 'AGCAN' ELSE prli_Type END + ' #', prli_Number
		  FROM CRM.dbo.PRCompanyLicense
		 WHERE prli_CompanyID = @CompanyID
		   AND prli_Publish = 'Y'
		   AND prli_Deleted IS NULL
		) TABLE1 
	ORDER BY SEQ


	RETURN @RetVal
END
GO



/* 
    This function returns the listing block for the Classification information for the passed company
	Used for both the "Classification" block (Produce & Transport) and the "Supply" block (Supply)
*/
If Exists (Select name from sysobjects where name = 'ufn_GetListingClassificationBlock' and type in (N'FN', N'IF', N'TF')) Drop Function dbo.ufn_GetListingClassificationBlock
Go

CREATE FUNCTION dbo.ufn_GetListingClassificationBlock(@CompanyID int,
                                                      @LineBreakChar varchar(50))  
RETURNS varchar(1000) AS  
BEGIN 

	IF (@LineBreakChar is null)
		SET @LineBreakChar = '<br>'

    DECLARE @LineSize tinyint
    SET @LineSize = 34 -- LineSize will be changed to 32 as soon as a new row is started

	DECLARE @RetVal varchar(5000)
	DECLARE @Separator varchar(10)
	DECLARE @Spacing varchar(10)
	-- will contain the contents of the current row being built
    DECLARE @CurrRowVal varchar(5000)
    DECLARE @Value varchar(100)
    DECLARE @Count smallint, @ValueLength smallint
    DECLARE @ndx tinyint 

	SET @Separator = ''
	SET @Spacing = ''

	DECLARE @IndustryType varchar(40)
	SELECT @IndustryType = comp_PRIndustryType FROM Company WHERE comp_CompanyID=@CompanyID;

    DECLARE @Classifications table(ndx smallint identity, value nvarchar(100))

    INSERT INTO @Classifications (value)
	SELECT CASE @IndustryType WHEN 'S' THEN prcl_Name ELSE prcl_Abbreviation END
	  FROM PRClassification, 
           PRCompanyClassification
	 WHERE prcl_ClassificationId = prc2_ClassificationId
	   AND prc2_CompanyID = @CompanyID
	   AND prc2_Deleted IS NULL
  ORDER BY prc2_Percentage DESC, prc2_CompanyClassificationID;

   SET @Count = @@ROWCOUNT
    IF (@IndustryType = 'S') 
    BEGIN
		SET @Separator = ','
		SET @Spacing = ' '
	END 
		
	IF (@Count >= 1) 
	BEGIN
		SET @ndx = 1		
		WHILE (@ndx <= @Count)
		begin
			SELECT @Value = value from @Classifications where ndx = @ndx

			if (@ndx = @Count)
			BEGIN
			    SET @Separator = ''
			    SET @Spacing = ''
			END
			SET @ValueLength = Len(@Value) + Len(@Separator)
			-- if this classification will fit on the current line, append it
			if (Len(@CurrRowVal) + @ValueLength < @LineSize) 
				SET @CurrRowVal = @CurrRowVal + @Value + @Separator + @Spacing
			else if (Len(@CurrRowVal) + @ValueLength = @LineSize) 
				SET @CurrRowVal = @CurrRowVal + @Value + @Separator
			else
			begin
				-- start a new row
				SET @RetVal = COALESCE(@RetVal + @LineBreakChar, '') + @CurrRowVal
				SET @CurrRowVal = @Value + @Separator + @Spacing
				SET @LineSize = 32
			end    
			SET @ndx = @ndx + 1		
		end
		SET @RetVal = COALESCE(@RetVal + @LineBreakChar, '') + @CurrRowVal
	END
    RETURN @RetVal
End
Go


/* 
    This function returns the listing block for the Commodity information for the passed company
	This function must determine the spacing of the Classification and Volume values to accurately
	    create a line break fo rthe first line. The listing is presented as 
	    <Classifications> <Volume> <Commodities>; therefore, the length of the prior two must be determined
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetListingCommodityBlock]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_GetListingCommodityBlock]
GO
CREATE FUNCTION dbo.ufn_GetListingCommodityBlock ( 
    @CompanyId int,
    @LineBreakChar nvarchar(50)
)
RETURNS nvarchar(1000)
AS
BEGIN
    DECLARE @LineSize tinyint

    SET @LineSize = 34

	IF (@LineBreakChar is null)
		SET @LineBreakChar = '<br>'

	DECLARE @RetVal varchar(5000)
	-- will contain the contents of the current row being built
    DECLARE @CurrRowVal varchar(5000)
    DECLARE @Value varchar(100)
    DECLARE @Count smallint, @ValueLength smallint, @ClassVolumeLength smallint
    DECLARE @ndx tinyint 
    DECLARE @Classifications varchar(1000)
    DECLARE @Volume varchar(50)
    DECLARE @BBSBookSection tinyint
    
    SELECT @Volume = capt_US
    from PRCompanyProfile 
    JOIN Custom_Captions ON capt_code = prcp_Volume AND capt_family = 'prcp_Volume'
    where prcp_CompanyId = @CompanyId
    

    SELECT @BBSBookSection = CASE 
            when comp_PRIndustryType = 'P' then 0
            when comp_PRIndustryType = 'T' then 1
            when comp_PRIndustryType = 'S' then 2
            else null
        end            
    from company where comp_CompanyId = @CompanyId

    --SELECT @Classifications = dbo.ufn_GetListingClassificationBlock(@CompanyId, @BBSBookSection, @LineBreakChar)
	SELECT @Classifications = dbo.ufn_GetListingClassificationBlock(@CompanyId, @LineBreakChar)

    DECLARE @Commodities table(ndx smallint identity, value nvarchar(100)	)

    -- Because Classification and volume can affect the line breaks of commodities, we have to 
    -- determine how the first line will break when these values are there; they will be 
    -- removed before returning the result
    SET @CurrRowVal = ISNULL(Coalesce(@Classifications + ' ', '') + Coalesce(@Volume + ' ', ''), '') 


	SET @ClassVolumeLength = Len(@CurrRowVal)
	IF (@ClassVolumeLength > 0) BEGIN
		SET @ClassVolumeLength = @ClassVolumeLength + 1 -- add one for the last space; len won't count it
	END


    INSERT INTO @Commodities 
        SELECT prcca_PublishedDisplay 
          FROM PRCompanyCommodityAttribute
         WHERE (prcca_Publish = 'Y' OR prcca_PublishWithGM = 'Y')
           AND prcca_CompanyId = @CompanyId
      ORDER BY prcca_Sequence;

    SET @Count = @@ROWCOUNT
    IF (@Count >= 1) 
    BEGIN
        SET @ndx = 1		
        WHILE (@ndx <= @Count)
        begin
            SELECT @Value = value from @Commodities where ndx = @ndx

            SET @ValueLength = Len(@Value)
            -- if this commodity will fit on th ecurrent line, append it
            if (Len(@CurrRowVal) + @ValueLength <= @LineSize) 
                SET @CurrRowVal = @CurrRowVal + @Value
            else
            begin
                -- start a new row
                SET @RetVal = COALESCE(@RetVal + @LineBreakChar, '') + @CurrRowVal
                SET @CurrRowVal = @Value
                -- once there is a new row the linesize must be reduced to 33 for listing indentation
                SET @LineSize = 33
            end    
            SET @ndx = @ndx + 1		
        end
        SET @RetVal = COALESCE(@RetVal + @LineBreakChar, '') + @CurrRowVal
	END
    -- Now remove the characters representing the classifications and volume
    SET @RetVal = SUBSTRING(@RetVal, @ClassVolumeLength+1, Len(@RetVal))	
    RETURN @RetVal
END
GO


/*
    This function provides indentation for the usp_GetListing function
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_indentListingBlock]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_indentListingBlock]
GO
CREATE FUNCTION dbo.ufn_indentListingBlock ( 
    @TextBlock varchar(6000),
    @LineBreakChar varchar(50),
    @IndentString varchar(50),
    @IsHangingIndent bit
)
RETURNS varchar(6000)
AS
BEGIN
    IF (@TextBlock is null)
        RETURN NULL

    DECLARE @RetValue varchar(6000)
    SET @RetValue = ''
    IF (@IsHangingIndent = 0 )    
        SET @RetValue = @IndentString 
 
    SET @RetValue = @RetValue +
                    REPLACE(@TextBlock, @LineBreakChar, @LineBreakChar + @IndentString) 

    RETURN @RetValue
END
GO





/* 
    This function pulls together the entire company listing. 
    @FormattingStyle: indicates how to format the return string; 
                      currently 0 indicates html (" " is &nbsp; );
                      ideally, this can be expanded to facilitate other needs
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetListing]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_GetListing]
GO
CREATE FUNCTION dbo.ufn_GetListing ( 
    @CompanyId int,
    @FormattingStyle tinyint = 0, -- 0: <BR> 1: CHR(10) 2: CHR(10 & 13)
    @ShowPaidLines bit = 0,
    @comp_PRBookTradestyle varchar(420),
    @comp_PRListingStatus varchar(40),
    @comp_PRIndustryType varchar(40),
    @prcp_VolumeDesc varchar(50),
    @prra_RatingLine varchar(100),
    @ParentheticalBlock varchar(1000),
    @AddressBlock varchar(1000),
    @PhoneBlock varchar(1000),
    @InternetBlock varchar(1000),
    @DLBlock varchar(4000),
    @BrandBlock varchar(1000),
    @UnloadHoursBlock varchar(1000),
    @ClassificationBlock varchar(1000),
    @CommodityBlock varchar(1000),
    @StockExchangeBlock varchar(500),
    @RatingBlock varchar(100),
    @BankBlock varchar(500),
    @LicenseBlock varchar(500),
    @MemberSince varchar(10)
)
RETURNS varchar(6000)
AS
BEGIN
    DECLARE @RetValue varchar(6000)
    
    DECLARE @LineBreakChar varchar(50)
    DECLARE @Space varchar(10) 
    DECLARE @Indent2 varchar(40), @Indent3 varchar(40), @PaidIndent2 varchar(40)  
    
    IF (@FormattingStyle = 0) BEGIN
        SET @Space = '&nbsp;'
        SET @LineBreakChar = '<br>'
    END ELSE IF (@FormattingStyle = 1) BEGIN
        SET @Space = ' '
        SET @LineBreakChar = CHAR(10)
    END ELSE IF (@FormattingStyle = 2) BEGIN
        SET @Space = ' '
        SET @LineBreakChar = CHAR(13)+CHAR(10)
    END

    SET @Indent2 = @Space + @Space
    SET @Indent3 = @Space + @Space + @Space 

    IF (@ShowPaidLines = 1) BEGIN
		SET @PaidIndent2 = '-' + @Space
    END ELSE BEGIN
		SET @PaidIndent2 = @Indent2
    END
    
    SET @RetValue =  @Space + @Space + 'BB #' + Convert(varchar(15), @CompanyId)


	IF (CHARINDEX('.', @comp_PRBookTradestyle, LEN(@comp_PRBookTradestyle)) = 0) BEGIN
		SET @comp_PRBookTradestyle = @comp_PRBookTradestyle + '.'
	END

    -- The Company tradestyle name
    SELECT @comp_PRBookTradestyle = dbo.ufn_indentListingBlock(
            dbo.ufn_ApplyListingLineBreaks(@comp_PRBookTradestyle,@LineBreakChar),
            @LineBreakChar, @Indent3, 1)
    SET @RetValue = @RetValue + Coalesce(@LineBreakChar + @comp_PRBookTradestyle, '' ) 

    IF (@comp_PRListingStatus = 'D')
    begin
        SET @RetValue = @RetValue + @LineBreakChar + @Space + '(This Listing Deleted)'
        RETURN @RetValue
    end        

    SET @RetValue = @RetValue +  
        COALESCE(@LineBreakChar + dbo.ufn_indentListingBlock(@ParentheticalBlock, @LineBreakChar, @Indent2, 0), '')    

    SET @RetValue = @RetValue + 
        COALESCE(@LineBreakChar + dbo.ufn_indentListingBlock(@AddressBlock, @LineBreakChar, @Indent2, 0), '')

    SET @RetValue = @RetValue + 
        COALESCE(@LineBreakChar + dbo.ufn_indentListingBlock(@PhoneBlock, @LineBreakChar, @Indent2, 0), '')

    SET @RetValue = @RetValue + 
        COALESCE(@LineBreakChar + dbo.ufn_indentListingBlock(@InternetBlock, @LineBreakChar, @Indent2, 0), '')

    SET @RetValue = @RetValue + 
        COALESCE(@LineBreakChar + dbo.ufn_indentListingBlock(@DLBlock, @LineBreakChar, @PaidIndent2, 0), '') 

    IF (@comp_PRIndustryType in ('P', 'T'))
    begin    
        IF (@comp_PRIndustryType = 'P')
        begin    
            SET @RetValue = @RetValue + 
                COALESCE(@LineBreakChar + dbo.ufn_indentListingBlock(@BrandBlock, @LineBreakChar, @PaidIndent2, 0), '') 
            SET @RetValue = @RetValue + 
                COALESCE(@LineBreakChar + dbo.ufn_indentListingBlock(@UnloadHoursBlock, @LineBreakChar, @PaidIndent2, 0), '') 
        end

        SET @RetValue = @RetValue + 
            COALESCE(@LineBreakChar + dbo.ufn_indentListingBlock(@StockExchangeBlock, @LineBreakChar, @Indent2, 0), '') 
    
        IF (@comp_PRIndustryType = 'P')
        begin    
            SET @RetValue = @RetValue + 
                COALESCE(@LineBreakChar + dbo.ufn_indentListingBlock(@BankBlock, @LineBreakChar, @Indent2, 0), '') 
		    DECLARE @ChainStoresBlock varchar(100)
			SET @ChainStoresBlock = dbo.ufn_GetListingChainStoresBlock(@CompanyId, @LineBreakChar)
            SET @RetValue = @RetValue + 
                COALESCE(@LineBreakChar + dbo.ufn_indentListingBlock(@ChainStoresBlock, @LineBreakChar, @Indent2, 0), '') 
        end

        SET @RetValue = @RetValue + 
            COALESCE(@LineBreakChar + dbo.ufn_indentListingBlock(@LicenseBlock, @LineBreakChar, @Indent2, 0), '') 
    end

    IF (@MemberSince is not null)
    begin
        IF (@comp_PRIndustryType = 'P')
        begin    
            SET @RetValue = @RetValue +
                COALESCE(@LineBreakChar + dbo.ufn_indentListingBlock(@Space+ 'TRADING MEMBER since ' + @MemberSince, @LineBreakChar, @Indent2, 0), '') 
        end 
        ELSE IF (@comp_PRIndustryType = 'T')
        begin
            SET @RetValue = @RetValue + 
                COALESCE(@LineBreakChar + dbo.ufn_indentListingBlock(@Space+ 'TRANSPORTATION MEMBER-' + @MemberSince, @LineBreakChar, @Indent2, 0), '') 
        end
    end

    DECLARE @ClassVolCommBlock varchar(3000)

    IF (@comp_PRIndustryType in ('P', 'T'))
    begin    
        SET @ClassVolCommBlock = ''
        SET @ClassVolCommBlock = @ClassVolCommBlock + 
            COALESCE(dbo.ufn_indentListingBlock(@ClassificationBlock, @LineBreakChar, @Space, 0)+@Space, '') +
            COALESCE(@prcp_VolumeDesc + @Space, '')
        IF (@comp_PRIndustryType = 'P')
        begin
            SET @ClassVolCommBlock = @ClassVolCommBlock + 
                COALESCE(dbo.ufn_indentListingBlock(@CommodityBlock, @LineBreakChar, @Indent2, 1), '') 
        end

		-- If we don't have any values here, reset this
		-- to NULL so we don't end up with a blank line
		IF (@ClassVolCommBlock = '') BEGIN
			SET @ClassVolCommBlock = NULL
		END 

        SET @RetValue = @RetValue + COALESCE(@LineBreakChar + @ClassVolCommBlock, '')


        -- Get the rating line
        SET @RetValue = @RetValue + 
            COALESCE(@LineBreakChar + dbo.ufn_indentListingBlock(@RatingBlock, @LineBreakChar, @Indent2, 0), '') 

    end
    else IF (@comp_PRIndustryType = 'S')
    begin
        IF (@ClassificationBlock is not null)
        begin
            SET @RetValue = @RetValue + 
                COALESCE(@LineBreakChar + dbo.ufn_indentListingBlock('Products & Services:', @LineBreakChar, @Space, 0), '')
            SET @RetValue = @RetValue + 
                COALESCE(@LineBreakChar + dbo.ufn_indentListingBlock(@ClassificationBlock, @LineBreakChar, @Indent2, 0), '')
        end
    end

    RETURN @RetValue
END 
GO


/* 
    This function pulls together the entire company listing. 
    @FormattingStyle: indicates how to format the return string; 
                      currently 0 indicates html (" " is &nbsp; );
                      ideally, this can be expanded to facilitate other needs
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetListingFromCompany]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_GetListingFromCompany]
GO
CREATE FUNCTION dbo.ufn_GetListingFromCompany ( 
    @CompanyId int,
    @FormattingStyle tinyint = 0, -- 0: <BR> 1: CHR(10) 2: CHR(10 & 13)
    @ShowPaidLines bit = 0
)
RETURNS varchar(6000)
AS
BEGIN
    DECLARE @RetValue varchar(6000)
    
    DECLARE @comp_PRBookTradestyle varchar(420)
    DECLARE @comp_PRListingStatus varchar(40)
    DECLARE @comp_PRIndustryType varchar(40)
    DECLARE @prcp_VolumeDesc varchar(50)
    DECLARE @prra_RatingLine varchar(100)
    DECLARE @ParentheticalBlock varchar(1000)
    DECLARE @AddressBlock varchar(1000)
    DECLARE @PhoneBlock varchar(1000)
    DECLARE @InternetBlock varchar(1000)
    DECLARE @DLBlock varchar(4000)
    DECLARE @BrandBlock varchar(1000)
    DECLARE @UnloadHoursBlock varchar(1000)
    DECLARE @ClassificationBlock varchar(1000)
    DECLARE @CommodityBlock varchar(1000)
    DECLARE @StockExchangeBlock varchar(500)
    DECLARE @RatingBlock varchar(100)
    DECLARE @BankBlock varchar(500)
    DECLARE @LicenseBlock varchar(500)
    DECLARE @MemberSince varchar(10)

    DECLARE @LineBreakChar varchar(50)
    IF (@FormattingStyle = 0) BEGIN
        SET @LineBreakChar = '<br>'
    END ELSE IF (@FormattingStyle = 1) BEGIN
        SET @LineBreakChar = CHAR(10)
    END ELSE IF (@FormattingStyle = 2) BEGIN
        SET @LineBreakChar = CHAR(13)+CHAR(10)
    END


    SELECT @comp_PRBookTradestyle = comp_PRBookTradestyle,
           @comp_PRIndustryType = comp_PRIndustryType,
           @prcp_VolumeDesc = CaptVol.capt_US,
           @ParentheticalBlock = dbo.ufn_GetListingParentheticalBlock(@CompanyId, @LineBreakChar),
           @AddressBlock = dbo.ufn_GetListingAddressBlock(@CompanyId, @LineBreakChar),
           @PhoneBlock = dbo.ufn_GetListingPhoneBlock(@CompanyId, @LineBreakChar),
           @InternetBlock = dbo.ufn_GetListingInternetBlock(@CompanyId, @LineBreakChar),
           @DLBlock = dbo.ufn_GetListingDLBlock(@CompanyId, @LineBreakChar),
           @BankBlock = dbo.ufn_GetListingBankBlock(@CompanyId, @LineBreakChar),
           @BrandBlock = dbo.ufn_GetListingBrandBlock(@CompanyId, @LineBreakChar),
           @UnloadHoursBlock = dbo.ufn_GetListingUnloadHoursBlock(@CompanyId, @LineBreakChar),
           @StockExchangeBlock = dbo.ufn_GetListingStockExchangeBlock(@CompanyId, @LineBreakChar),
           @RatingBlock = dbo.ufn_GetListingRatingBlock(@CompanyId, 1),
           @LicenseBlock = dbo.ufn_GetListingLicenseBlock(@CompanyId, @LineBreakChar),
           @ClassificationBlock = dbo.ufn_GetListingClassificationBlock(@CompanyId, @LineBreakChar),
           @CommodityBlock = dbo.ufn_GetListingCommodityBlock(@CompanyId, @LineBreakChar),
           @MemberSince = case 
                when comp_PRTMFMAward = 'Y' then DATEPART(YEAR, comp_PRTMFMAwardDate)
                else NULL
           end
    FROM Company
    LEFT OUTER JOIN PRCompanyProfile ON comp_CompanyId = prcp_CompanyId
    LEFT OUTER JOIN Custom_Captions CaptVol ON capt_code = prcp_Volume AND capt_family = 'prcp_Volume'
    WHERE comp_companyid = @CompanyId

	SET @RetValue = dbo.ufn_GetListing(@CompanyId,
										@FormattingStyle,
                                        @ShowPaidLines,
                                        @comp_PRBookTradestyle,
                                        @comp_PRListingStatus,
                                        @comp_PRIndustryType,
                                        @prcp_VolumeDesc,
                                        @prra_RatingLine,
                                        @ParentheticalBlock,
                                        @AddressBlock,
                                        @PhoneBlock,
                                        @InternetBlock,
                                        @DLBlock,
                                        @BrandBlock,
                                        @UnloadHoursBlock,
                                        @ClassificationBlock,
                                        @CommodityBlock,
                                        @StockExchangeBlock,
                                        @RatingBlock,
                                        @BankBlock,
                                        @LicenseBlock,
                                        @MemberSince);

	RETURN @RetValue
END 
GO



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetListingChainStoresBlock]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_GetListingChainStoresBlock]
GO

CREATE FUNCTION dbo.ufn_GetListingChainStoresBlock(@CompanyID int,
                                                      @LineBreakChar varchar(50))  
RETURNS varchar(1000) AS  
BEGIN 

	IF (@LineBreakChar is null)
		SET @LineBreakChar = '<br>'

    DECLARE @LineSize tinyint
    SET @LineSize = 34

	DECLARE @RetVal varchar(1000)

	DECLARE @Retail varchar(40)
	DECLARE @Restaraunt varchar(40)

    SELECT @Retail = Capt_US
      FROM CRM.dbo.PRCompanyClassification INNER JOIN
           CRM.dbo.Custom_Captions ON prc2_NumberOfStores = capt_Code AND capt_Family = 'prc2_StoreCount'
     WHERE prc2_ClassificationId = 330
	   AND prc2_CompanyId = @CompanyId
       AND prc2_Deleted IS NULL;

    SELECT @Restaraunt = Capt_US
      FROM CRM.dbo.PRCompanyClassification INNER JOIN
           CRM.dbo.Custom_Captions ON prc2_NumberOfStores = capt_Code AND capt_Family = 'prc2_StoreCount'
     WHERE prc2_ClassificationId = 320
	   AND prc2_CompanyId = @CompanyId
       AND prc2_Deleted IS NULL;

	IF @Retail IS NULL BEGIN
		IF @Restaraunt IS NULL BEGIN
			RETURN NULL
		END
		
		SET @RetVal = 'Chain: ' + @Restaraunt  + ' Stores'
		
	END ELSE BEGIN
		SET @RetVal = 'Chain: ' + @Retail  + ' Stores'	
		IF @Restaraunt IS NOT NULL BEGIN
			SET @RetVal = @RetVal + ' & ' + @Restaraunt + ' Restaurants'
		END
	END

	RETURN dbo.ufn_ApplyListingLineBreaks(@RetVal, @LineBreakChar)
END
Go



/* 
	This function will return the rating description and rating line.  If the full
    leader is included, the two strings will be separated by "....." taking the 
    full width of the line.  If not, the two strings will be separated by a comma.
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetListingRatingBlockLeader]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_GetListingRatingBlockLeader]
GO

CREATE FUNCTION dbo.ufn_GetListingRatingBlockLeader (
	@RatingDescription varchar(100), 
	@RatingLine varchar(100)
)
RETURNS varchar(1000)
AS
BEGIN

	DECLARE @RetVal varchar(1000), @Count int, @DescLength int, @RatingLength int

	SET @DescLength = LEN(@RatingDescription)
	SET @RatingLength = ISNULL(LEN(@RatingLine), 0)

	SET @RetVal = @RatingDescription + ' '
		
	SET @Count = 0
	WHILE (@Count < 34 - (@DescLength + @RatingLength + 2)) BEGIN
		SET @RetVal = @RetVal + '.'
        SET @Count = @Count + 1
	END

	SET @RetVal = @RetVal + ' ' + ISNULL(@RatingLine, '')
	
	RETURN @RetVal		
END
Go

/* 
	This function will return the rating description and rating line.  If the full
    leader is included, the two strings will be separated by "....." taking the 
    full width of the line.  If not, the two strings will be separated by a comma.
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetListingRatingBlock]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_GetListingRatingBlock]
GO
CREATE FUNCTION dbo.ufn_GetListingRatingBlock ( 
    @CompanyId int,
    @bIncludeFullLeader bit = 1
)
RETURNS varchar(6000)
AS
BEGIN

	DECLARE @RetVal varchar(1000)

	DECLARE @RatingLine varchar(100), @RatingDescription varchar(100)
	DECLARE @HQID int, @IsHQ bit, @IsHQRating bit
	DECLARE @Count int, @DescLength int, @RatingLength int
	
	-- set the default values, otherwise they will be NULL not 0
	SET @IsHQ = 0;
	SET @IsHQRating = 0;
	
	-- Do we have a headquarters?
	SELECT @HQID = Comp_PRHQID 
      FROM Company 
     WHERE Comp_CompanyID=@CompanyID 
       AND Comp_Deleted IS NULL;

	-- Are we dealing with an HQ?
	IF @HQID IS NULL BEGIN
		SET @IsHQ = 1
	END

    SELECT @RatingLine = prra_RatingLine
 	  FROM CRM.dbo.vPRCompanyRating
	 WHERE prra_CompanyID = @CompanyID
	   AND prra_Current = 'Y'
	   AND prra_Deleted IS NULL;

	IF LEN(@RatingLine) > 0 BEGIN
		SET @IsHQRating = @IsHQ
	END ELSE BEGIN
		IF (@IsHQ = 0) BEGIN

		    SELECT @RatingLine = prra_RatingLine
 			  FROM CRM.dbo.vPRCompanyRating
			 WHERE prra_CompanyID = @HQID
			   AND prra_Current = 'Y'
			   AND prra_Deleted IS NULL;

			SET @IsHQRating = 1
		END
	END

	IF @IsHQ=1 BEGIN
		IF LEN(@RatingLine) > 0 BEGIN
			SET @RatingDescription = 'Rating'
		END ELSE BEGIN
			SET @RatingDescription = 'Not Rated'
		END
	END ELSE BEGIN
		IF @IsHQRating=1 BEGIN
			IF LEN(@RatingLine) > 0 BEGIN
				SET @RatingDescription = 'HQ Rating'
			END ELSE BEGIN
				SET @RatingDescription = 'HQ Not Rated'
			END
		END ELSE BEGIN
			IF LEN(@RatingLine) > 0 BEGIN
				SET @RatingDescription = 'Branch Rating'
			END ELSE BEGIN
				SET @RatingDescription = 'HQ Not Rated'
			END
		END
	END

	IF @bIncludeFullLeader = 1 BEGIN
		SET @RetVal = dbo.ufn_GetListingRatingBlockLeader(@RatingDescription, @RatingLine)
	END ELSE BEGIN
		SET @RetVal = @RatingDescription + ',' + ISNULL(@RatingLine, '')
	END
	
	RETURN @RetVal		
END
Go



/* 
   
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetListingDLLineCount]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_GetListingDLLineCount]
GO

CREATE FUNCTION dbo.ufn_GetListingDLLineCount(@CompanyID int)
RETURNS int AS  
BEGIN
	DECLARE @LineCount int
	DECLARE @LineBreakChar varchar(5)
	DECLARE @Block varchar(8000)

	SET @LineBreakChar = '<BR>'
	SET @LineCount = 0

	SET @Block = dbo.ufn_GetListingDLBlock(@CompanyID, '<BR>')
	IF (@Block IS NOT NULL) BEGIN
		SET @LineCount = @LineCount + ((LEN(@Block) - LEN(REPLACE(@Block, @LineBreakChar, ''))) / LEN(@LineBreakChar)) + 1
	END

	SET @Block = dbo.ufn_GetListingBrandBlock(@CompanyID, '<BR>')
	IF (@Block IS NOT NULL) BEGIN
		SET @LineCount = @LineCount + ((LEN(@Block) - LEN(REPLACE(@Block, @LineBreakChar, ''))) / LEN(@LineBreakChar)) + 1
	END

	SET @Block = dbo.ufn_GetListingUnloadHoursBlock(@CompanyID, '<BR>')
	IF (@Block IS NOT NULL) BEGIN
		SET @LineCount = @LineCount + ((LEN(@Block) - LEN(REPLACE(@Block, @LineBreakChar, ''))) / LEN(@LineBreakChar)) + 1
	END

	RETURN @LineCount

END
Go


/* 
   
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetListingBodyLineCount]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_GetListingBodyLineCount]
GO
CREATE FUNCTION dbo.ufn_GetListingBodyLineCount(@CompanyID int)
RETURNS int AS  
BEGIN
	DECLARE @LineCount int
	DECLARE @LineBreakChar varchar(5)
	DECLARE @Block varchar(8000)

	SET @LineBreakChar = '<BR>'
	SET @LineCount = 0

	SET @Block = dbo.ufn_GetListingParentheticalBlock(@CompanyID, '<BR>')
	IF (@Block IS NOT NULL) BEGIN
		SET @LineCount = @LineCount + ((LEN(@Block) - LEN(REPLACE(@Block, @LineBreakChar, ''))) / LEN(@LineBreakChar)) + 1
	END

	SET @Block = dbo.ufn_GetListingAddressBlock(@CompanyID, '<BR>')
	IF (@Block IS NOT NULL) BEGIN
		SET @LineCount = @LineCount + ((LEN(@Block) - LEN(REPLACE(@Block, @LineBreakChar, ''))) / LEN(@LineBreakChar)) + 1
	END

	SET @Block = dbo.ufn_GetListingPhoneBlock(@CompanyID, '<BR>')
	IF (@Block IS NOT NULL) BEGIN
		SET @LineCount = @LineCount + ((LEN(@Block) - LEN(REPLACE(@Block, @LineBreakChar, ''))) / LEN(@LineBreakChar)) + 1
	END

	SET @Block = dbo.ufn_GetListingInternetBlock(@CompanyID, '<BR>')
	IF (@Block IS NOT NULL) BEGIN
		SET @LineCount = @LineCount + ((LEN(@Block) - LEN(REPLACE(@Block, @LineBreakChar, ''))) / LEN(@LineBreakChar)) + 1
	END

	SET @Block = dbo.ufn_GetListingDLBlock(@CompanyID, '<BR>')
	IF (@Block IS NOT NULL) BEGIN
		SET @LineCount = @LineCount + ((LEN(@Block) - LEN(REPLACE(@Block, @LineBreakChar, ''))) / LEN(@LineBreakChar)) + 1
	END

	SET @Block = dbo.ufn_GetListingBrandBlock(@CompanyID, '<BR>')
	IF (@Block IS NOT NULL) BEGIN
		SET @LineCount = @LineCount + ((LEN(@Block) - LEN(REPLACE(@Block, @LineBreakChar, ''))) / LEN(@LineBreakChar)) + 1
	END

	SET @Block = dbo.ufn_GetListingUnloadHoursBlock(@CompanyID, '<BR>')
	IF (@Block IS NOT NULL) BEGIN
		SET @LineCount = @LineCount + ((LEN(@Block) - LEN(REPLACE(@Block, @LineBreakChar, ''))) / LEN(@LineBreakChar)) + 1
	END

	SET @Block = dbo.ufn_GetListingStockExchangeBlock(@CompanyID, '<BR>')
	IF (@Block IS NOT NULL) BEGIN
		SET @LineCount = @LineCount + ((LEN(@Block) - LEN(REPLACE(@Block, @LineBreakChar, ''))) / LEN(@LineBreakChar)) + 1
	END

	SET @Block = dbo.ufn_GetListingBankBlock(@CompanyID, '<BR>')
	IF (@Block IS NOT NULL) BEGIN
		SET @LineCount = @LineCount + ((LEN(@Block) - LEN(REPLACE(@Block, @LineBreakChar, ''))) / LEN(@LineBreakChar)) + 1
	END

	SET @Block = dbo.ufn_GetListingChainStoresBlock(@CompanyID, '<BR>')
	IF (@Block IS NOT NULL) BEGIN
		SET @LineCount = @LineCount + ((LEN(@Block) - LEN(REPLACE(@Block, @LineBreakChar, ''))) / LEN(@LineBreakChar)) + 1
	END

	RETURN @LineCount

END
Go