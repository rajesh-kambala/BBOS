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
	Return  dbo.ufn_FormatPerson2(@pers_FirstName, @pers_LastName, @pers_MiddleName, @pers_Nickname1, @pers_Suffix, 0)
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
                                    @phon_PRExtension varchar(15))  
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


-- *************************************************************************
-- This function is similar to the other LineBreak functions but 
-- specifically focuses on breaks for listings with logos. These
-- listings require special handling of breaks for the parenthetical,
-- address, and phone blocks,

-- LineLimit is the number of lines that should use the LogoLineSize value
-- If the number of LineLimit lines reaches 0, LineSize should be used 
-- for all remaining lines

-- As Of Build 2.2.164, this function becomes the helper function for most
-- Line break functions to centralize common code
-- *************************************************************************
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_ApplyListingLineBreaksForLogo]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_ApplyListingLineBreaksForLogo]
GO
CREATE FUNCTION dbo.ufn_ApplyListingLineBreaksForLogo ( 
    @OriginalString varchar(8000),
    @LineBreakChar varchar(50),
    @LogoLineSize int,
	@LineSize int,
	@LineLimit int
)
RETURNS varchar(8000)
AS

BEGIN
    DECLARE @FinalString varchar(8000)
    DECLARE @RemainingString varchar(8000)
    DECLARE @Position int
    DECLARE @PosSpace int
    DECLARE @LastSpaceOnLine int

	DECLARE @Offset int = 0
    SET @Position = 1
    SET @FinalString = ''

	IF @LineLimit <= 0
		SET @LogoLineSize = @LineSize 

    IF (@OriginalString is null or (LEN(@OriginalString) <= @LogoLineSize))
        RETURN @OriginalString
    ELSE
    BEGIN
        SET @RemainingString = @OriginalString
        WHILE (@Position <= LEN(@RemainingString))
        BEGIN
            IF (LEN(@RemainingString) <= @LogoLineSize)
            BEGIN
                SET @FinalString = @FinalString + @RemainingString
                BREAK
            END
            ELSE
            BEGIN
                -- find the last space prior to our line size        
                SET @PosSpace = CHARINDEX(' ', @RemainingString, @Position)
				SET @Offset = 0
				SET @LastSpaceOnLine = NULL

                WHILE (@PosSpace > 0 AND (@PosSpace <= @LogoLineSize+1)) --look at the linesize + 1 to determine if the next char is a space
                BEGIN
                    SET @LastSpaceOnLine = @PosSpace
                    SET @PosSpace = CHARINDEX(' ', @RemainingString, @PosSpace+1)
                END

				-- If we didn't find a space, look for a dash.
				IF (@LastSpaceOnLine is null) BEGIN

					-- Now look for the first dash.
					SET @PosSpace = CHARINDEX('-', @RemainingString, @Position)
					IF (@PosSpace > 0 AND (@PosSpace <= @LogoLineSize+1))
					BEGIN
						SET @LastSpaceOnLine = @PosSpace
						SET @PosSpace = CHARINDEX('-', @RemainingString, @PosSpace+1)
						SET @Offset = 1
					END

					-- IF there is not a space on the line, set LastSpaceOnLine to the len of the string
					IF (@LastSpaceOnLine is null) BEGIN
						SET @LastSpaceOnLine = len(@RemainingString)
					END
				END

				
                SET @FinalString = @FinalString + SUBSTRING(@RemainingString, @Position, @LastSpaceOnLine - @Position + @Offset) + @LineBreakChar
                SET @LineLimit = @LineLimit -1
				IF (@LineLimit <= 0)
					SET @LogoLineSize = @LineSize 
				
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
    This function applies line breaks in the passed string based upon a @LineSize character line.  Breaks
    will occur at the first space preceeding the word containing the @LineSize-th character.
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_ApplyListingLineBreaks2]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_ApplyListingLineBreaks2]
GO
CREATE FUNCTION dbo.ufn_ApplyListingLineBreaks2 ( 
    @OriginalString varchar(8000),
    @LineBreakChar varchar(50),
    @LineSize int
)
RETURNS varchar(8000)
AS
BEGIN
	DECLARE @Return varchar(8000)
	SET @Return = dbo.ufn_ApplyListingLineBreaksForLogo(@OriginalString, @LineBreakChar, @LineSize, @LineSize, 0)
	RETURN @Return
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
    @OriginalString varchar(8000),
    @LineBreakChar varchar(50)
)
RETURNS varchar(8000)
AS
BEGIN
	DECLARE @Return varchar(8000)
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
      FROM dbo.Tokenize(@OriginalString, CHAR(10))
     WHERE value IS NOT NULL;

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

If Exists (Select name from sysobjects where name = 'ufn_AppendListingStringForLogo' and type in (N'FN', N'IF', N'TF')) 
	Drop Function dbo.ufn_AppendListingStringForLogo
Go

CREATE FUNCTION dbo.ufn_AppendListingStringForLogo(@Current varchar(4000),
                                            @Append varchar(1000), 
                                            @LineBreakChar varchar(50),
											@LogoLineSize int = 22,  
											@LineSize int = 34,  
											@LineLimit int = 0)  
RETURNS varchar(5000) AS  
BEGIN

	-- Do we have a value to append?
	IF (@Append IS NOT NULL) BEGIN

		-- Do we have a value to append to?
		IF (@Current IS NULL) BEGIN
			SET @Current = dbo.ufn_ApplyListingLineBreaksForLogo(@Append, @LineBreakChar, @LogoLineSize, @LineSize, @LineLimit)
		END ELSE BEGIN
		    SET @Current = @Current + @LineBreakChar + dbo.ufn_ApplyListingLineBreaksForLogo(@Append, @LineBreakChar, @LogoLineSize, @LineSize, @LineLimit)
		END
	END

	RETURN @Current
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetListingPhoneBlock2]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_GetListingPhoneBlock2]
GO
CREATE FUNCTION dbo.ufn_GetListingPhoneBlock2(  
    @CompanyId int,
    @LineBreakChar nvarchar(50),
	@LogoLineSize int = 22,
	@LineSize int = 34,
	@LineLimit int = 0
)
RETURNS varchar(5000) 
AS  
BEGIN

/*  DEBUGGIN BLOCK

    DECLARE @CompanyId int; SET @CompanyId = 161873
    DECLARE @LineBreakChar nvarchar(50); SET @LineBreakChar = CHAR(13)
	DECLARE @LogoLineSize int; SET @LogoLineSize= 22
	DECLARE @LineSize int; SET @LineSize= 34
	DECLARE @LineLimit int; SET @LineLimit= 0
*/
    DECLARE @RetVal varchar(5000)
	DECLARE @Line varchar(5000)

    IF (@LineBreakChar IS NULL)
        SET @LineBreakChar = '<br/>'

	IF (@LineLimit <= 0 )
		SET @LogoLineSize = @LineSize

	Declare @PhonesCount int
	DECLARE @Phones TABLE (
		phon_ndx int identity,
		phon_type varchar(100), 
		phon_Description varchar(100), 
		phon_Phone varchar(100),
		SequenceGroup int

	)

	DECLARE @Ndx int, @Type varchar(100), @Description varchar(100), @Phone varchar(100)

	INSERT INTO @Phones
		SELECT Capt_US AS Type, 
		       RTRIM(phon_PRDescription) AS phon_PRDescription, 
			   dbo.ufn_FormatPhone(RTRIM(Phon_CountryCode), RTRIM(Phon_AreaCode), RTRIM(Phon_Number), RTRIM(phon_PRExtension)) AS Phone,
			   0
		  FROM vPRCompanyPhone WITH (NOLOCK) 
		       INNER JOIN Custom_Captions WITH (NOLOCK) on plink_Type = capt_Code and capt_Family='phon_TypeCompany'
		 WHERE plink_RecordID = @CompanyId
		   AND phon_PRPublish = 'Y' 
		   AND phon_Deleted IS NULL 
		ORDER BY dbo.ufn_GetListingPhoneSeq(plink_Type, phon_PRSequence)
	SELECT @PhonesCount = count (1) from @Phones

	SET @Ndx = 1
	DECLARE @SaveDescription varchar(100) = '', @SaveType varchar(40) = ''
	DECLARE @SequenceGroup int = 0

	-- 
	--  We need to group by consecutive type & description in the.  Since phones of the same type can
	--  have different descriptions, in different orders, having to be consecutive is an issue.  This
	--  loop solves that by grouping the consecutive phone type / descriptions 
	-- 
	WHILE (@Ndx <= @PhonesCount) BEGIN
		SELECT @Type = phon_type, @Description = phon_Description
		  FROM @Phones
		 WHERE phon_ndx = @Ndx


		IF (@Type <> @SaveType) OR
		   (@Description <> @SaveDescription) BEGIN

		   SET @SequenceGroup = @SequenceGroup + 1
		   SET @SaveDescription = @Description 
		   SET @SaveType = @Type

		END 

		UPDATE @Phones
		   SET SequenceGroup = @SequenceGroup
		 WHERE phon_ndx = @Ndx

		 SET @Ndx = @Ndx + 1
	END



	SET @Ndx = 1
	SET @Line = NULL

	DECLARE @Conjunction varchar(5); SET @Conjunction = '';
	DECLARE @ValueToAppend varchar(100); SET @ValueToAppend = '';
	-- GroupTotal is the number of phones in the same type and desc
	-- GroupCountis our counter to tell which rec of the group we are processing
	DECLARE @GroupCount int, @GroupTotal int 
	SET @GroupCount = 1;
	SET @GroupTotal = -1;

	WHILE (@Ndx <= @PhonesCount) BEGIN
		-- Get the current record from our temp table
		SELECT @Type = phon_type, 
		       @Description = phon_Description, 
			   @Phone = phon_Phone,
			   @SequenceGroup = SequenceGroup
		  FROM @Phones
		 WHERE phon_ndx = @Ndx

		SET @Conjunction = ''
		
		-- Determine if we need a new group
		IF (@GroupCount > @GroupTotal) BEGIN
			SELECT @GroupTotal = count (1) 
			  FROM @Phones 
			 WHERE SequenceGroup = @SequenceGroup

			SET @GroupCount = 1 
			SET @Line = NULL
		END

		-- if this is the second to last line, use "or"
		-- if this is the last line of a group, use nothing
		-- otherwise, use a comma
		IF (@GroupCount = @GroupTotal -1 )
			SET @Conjunction = ' or '
		ELSE IF (@GroupCount != @GroupTotal)  
			SET @Conjunction = ', '
		
		SET @ValueToAppend = ''
		IF (@GroupCount = 1) BEGIN
			IF (LEN(@Description) + LEN(@Phone) + 1 + LEN(RTRIM(@Conjunction)) > @LogoLineSize) BEGIN
				-- we need to break at the Description
				SET @RetVal = COALESCE(@RetVal + @LineBreakChar, '') + @Description
				SET @LineLimit = @LineLimit - 1
				IF (@LineLimit <= 0)
					SET @LogoLineSize = @LineSize 
			END ELSE BEGIN
				SET @ValueToAppend = @Description + ' ' 
			END
		END
		SET @ValueToAppend = @ValueToAppend + @Phone + @Conjunction

		-- now get the line
		if (LEN(@Line) + LEN(@ValueToAppend)+1 > @LogoLineSize ) BEGIN
			SET @RetVal = COALESCE(@RetVal + @LineBreakChar, '') + RTRIM(@Line)
			SET @LineLimit = @LineLimit - 1
			IF (@LineLimit <= 0)
				SET @LogoLineSize = @LineSize 
			SET @Line = @ValueToAppend 
		END ELSE BEGIN
			SET @Line = COALESCE(@Line , '') + @ValueToAppend
		END

		SET @GroupCount = @GroupCount +1 
		IF (@GroupCount > @GroupTotal) BEGIN
			SET @RetVal = COALESCE(@RetVal + @LineBreakChar, '') + @Line 
			SET @LineLimit = @LineLimit - 1
			IF (@LineLimit <= 0)
				SET @LogoLineSize = @LineSize 
		END
		SET @Ndx = @Ndx + 1
	End
--	SELECT @RetVal

    RETURN @RetVal
END
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetListingPhoneBlock]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_GetListingPhoneBlock]
GO
CREATE FUNCTION [dbo].[ufn_GetListingPhoneBlock](  
    @CompanyId int,
    @LineBreakChar nvarchar(50)
)
RETURNS varchar(5000) 
AS  
BEGIN
	DECLARE @Return varchar(5000)
	SET @Return = dbo.ufn_GetListingPhoneBlock2(@CompanyID, @LineBreakChar, DEFAULT, DEFAULT, DEFAULT)  
	RETURN @Return
END
Go


/* 
    This function returns the listing block for the parenthetical information for the passed 
    HQ or branch company
*/
CREATE OR ALTER FUNCTION dbo.ufn_GetListingParentheticalBlock2( 
    @CompanyId int,
    @LineBreakChar nvarchar(50),
	@LogoLineSize int = 22,
	@LineSize int = 34,
	@LineLimit int = 0
)
RETURNS nvarchar(1000)
AS
BEGIN
    DECLARE @Paren1 nvarchar(1000)
	DECLARE @Paren2 nvarchar(1000)
	DECLARE @Paren3 nvarchar(1000)
    DECLARE @RetValue nvarchar(1000)
    DECLARE @prcp_CorporateStructure nvarchar(40)
    DECLARE @CorporateStructureDesc nvarchar(100)
    DECLARE @comp_PRLegalName nvarchar(104)
    DECLARE @comp_Name nvarchar(500)
    DECLARE @comp_PRListingCityId int
    DECLARE @comp_CountryId int
    DECLARE @comp_PRIndustryType nvarchar(40)
    DECLARE @comp_PRType nvarchar(40)
    DECLARE @comp_PRHQId int
	DECLARE @comp_CreditWorth nvarchar(10)

	DECLARE @LineCount int; SET @LineCount = 0
	IF (@LineLimit <= 0)
		SET @LogoLineSize = @LineSize

    -- fields pertaining to a related company record
    DECLARE @RelatedCompanyId int
    DECLARE @RelComp_Name nvarchar(500)
    DECLARE @RelComp_PRLegalName nvarchar(104)
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
        SET @LineBreakChar = '<br/>'

    -- get the relative company fields; we'll only get countryid if we need it.
    SELECT  @comp_PRLegalName = comp_PRLegalName, 
            @comp_Name = comp_Name,
            @comp_PRIndustryType = comp_PRIndustryType,
            @comp_PRListingCityId = comp_PRListingCityId,
            @comp_PRType = comp_PRType,
            @comp_PRHQId = comp_PRHQId
       FROM Company WITH (NOLOCK) 
      WHERE comp_companyid = @CompanyId;
    
    -- first parenthetical is the d/b/a
    --SET @comp_PRLegalName = 'THIS IS 60 CHARACTER LEGAL NAME FOR LINEBRK TESTING PURPOSES'
    if (@comp_PRLegalName is not null)
        SET @Paren1 = '(A d/b/a of ' + @comp_PRLegalName + ')'

    SELECT @Paren1 = dbo.ufn_ApplyListingLineBreaksForLogo(@Paren1, @LineBreakChar, @LogoLineSize, @LineSize, @LineLimit)
	IF (@Paren1 is not null AND @Paren1 != '')
		SET @LineLimit = @LineLimit - (dbo.ufn_CountOccurrences(@lineBreakChar, @Paren1) + 1);

    -- Parenthtical 2 is the entity type
    if (@comp_PRType = 'H')
    begin
        -- determine the entity type from the company profile record
        SELECT @prcp_CorporateStructure = prcp_CorporateStructure,
               @CorporateStructureDesc = dbo.ufn_GetCustomCaptionValue('prcp_CorporateStructure', prcp_CorporateStructure, 'en-us')
          FROM PRCompanyProfile WITH (NOLOCK) 
         WHERE prcp_companyid = @CompanyId;

        Set @Paren2 = '(A ' + @CorporateStructureDesc + ')'
    
        --  Based upon the corporate structure, determine which rule to follow
        if (@prcp_CorporateStructure is null)
            SET @Paren2 = NULL
        else if (@prcp_CorporateStructure = 'PROP')
        -- this encapsulates rules (a)
        begin
            declare @person_name nvarchar(125)
            SELECT @person_name = dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_MiddleName, NULL, pers_Suffix)
            from person_link WITH (NOLOCK)
            join person WITH (NOLOCK) on peli_PersonId = pers_Personid
            where peli_PROwnershipRole = 'RCO' and peli_PRStatus = 1
              AND peli_CompanyId = @CompanyId
    
            SET @Paren2 = '(' + @person_name + ', Prop.)'
    
        end
        else if (@prcp_CorporateStructure in ('CORP', 'CCORP', 'SCORP'))
        -- this encapsulates rules (b) and (f) from the homework document
        begin
            if (@comp_Name like '%Inc.' or @comp_Name like '%Incorporated' or 
                @comp_Name like '%Corp.' or @comp_Name like '%Co.' or 
                @comp_Name like '%Company' or @comp_Name like '%Corporation' or 
                @comp_Name like '%Company, The' or
                @comp_PRLegalName like '%Inc.' or @comp_PRLegalName like '%Incorporated' or 
                @comp_PRLegalName like '%Corp.' or @comp_PRLegalName like '%Co.' or 
                @comp_PRLegalName like '%Company' or @comp_PRLegalName like '%Corporation' or
                @comp_PRLegalName like '%Company, The'
               )
                SET @Paren2 = ''
        end
        else if (@prcp_CorporateStructure = 'LLC')
        -- this encapsulates rules (e)
        begin
            if (@comp_Name like '%LLC'
                or @comp_Name like '%LLC.'
                or @comp_Name like '%L.L.C.'
                or @comp_Name like '%Limited Liability Company'
                or @comp_Name like '%Limited Liability Co.'
                or @comp_PRLegalName like '%LLC'
                or @comp_PRLegalName like '%LLC.'
                or @comp_PRLegalName like '%L.L.C.'
                or @comp_PRLegalName like '%Limited Liability Company'
                or @comp_PRLegalName like '%Limited Liability Co.' 
               )
                SET @Paren2 = ''
        end
		SELECT @Paren2 = dbo.ufn_ApplyListingLineBreaksForLogo(@Paren2, @LineBreakChar, @LogoLineSize, @LineSize, @LineLimit)
		IF (@Paren2 is not null AND @Paren2 != '')
			SET @LineLimit = @LineLimit - (dbo.ufn_CountOccurrences(@lineBreakChar, @Paren2) + 1);
        
        -- Determine if relevant Company Relationships exist for the third parenthetical
        select @RelatedCompanyId = prcr_LeftCompanyId from PRCompanyRelationship WITH (NOLOCK)
        where prcr_RightCompanyId = @CompanyId AND prcr_Type = '27'
        if (@RelatedCompanyId is not null)
        begin
            SET @Paren3 = '(A wholly-owned subsidiary of ' 
        end
        else
        begin
            select @RelatedCompanyId = prcr_LeftCompanyId from PRCompanyRelationship WITH (NOLOCK) 
            where prcr_RightCompanyId = @CompanyId AND prcr_Type = '28' AND prcr_OwnershipPct > 50
            if (@RelatedCompanyId is not null)
            begin
                SET @Paren3 = '(A subsidiary of ' 
            end
        end
        if (@RelatedCompanyId is not null)
        -- this encapsulates rule (c) from the homework document
        begin
            --get the relevant info for the related company
            SELECT  @RelComp_PRLegalName = comp_PRLegalName, 
                    @RelComp_Name = comp_Name,
                    @RelComp_PRIndustryType = comp_PRIndustryType,
                    @RelComp_PRIndustryTypeDesc = capt_US,
                    @RelComp_PRListingStatus = comp_PRListingStatus,
                    @RelComp_PRListingCityId = comp_PRListingCityId,
                    @RelComp_CountryId = prcn_CountryId,
                    @RelComp_City = prci_City,
                    @RelComp_State = ISNULL(prst_Abbreviation, prst_State),
                    @RelComp_Country = prcn_Country,
                    @RelComp_CreditWorth = prcw_Name
               FROM company WITH (NOLOCK) 
					JOIN Custom_Captions WITH (NOLOCK) On comp_PRIndustryType = capt_Code and capt_Family = 'comp_PRIndustryType'
					JOIN vPRLocation WITH (NOLOCK) ON comp_PRListingCityId = prci_CityId 
					LEFT OUTER JOIN PRRating WITH (NOLOCK) on comp_companyid = prra_CompanyId and prra_Current = 'Y'
					LEFT OUTER JOIN PRCreditWorthRating WITH (NOLOCK) on prra_CreditWorthId = prcw_CreditWorthRatingId
              WHERE comp_companyid = @RelatedCompanyId;
    
            -- Add the company name
            SET @Paren3 = @Paren3 + ISNULL(@RelComp_PRLegalName, @RelComp_Name) + ', '

            -- get the country id
            select  @comp_CountryId = prst_CountryId
            from company WITH (NOLOCK) 
            JOIN PRCity WITH (NOLOCK) ON comp_PRListingCityId = prci_CityId 
            JOIN PRState WITH (NOLOCK) ON prci_StateId = prst_StateId 
            where comp_companyid = @CompanyId
    
			SET @Address = @RelComp_City
			SET @UnderscoredAddress = REPLACE(@RelComp_City, ' ', '_')

			IF (@RelComp_State IS NOT NULL AND @RelComp_State != '') BEGIN
				SET @UnderscoredAddress = @UnderscoredAddress + ', ' + REPLACE(@RelComp_State, ' ', '_')
				SET @Address = @Address + ', ' + @RelComp_State
			END

			if (@comp_CountryId != @RelComp_CountryId)
			BEGIN
				SET @Address = @Address + ', ' + @RelComp_Country 
				SET @UnderscoredAddress = @UnderscoredAddress + ', ' + REPLACE(@RelComp_Country, ' ', '_') 
			END
			
            -- set spaces to underscores so the field cannot break lines
            SET @Paren3 = @Paren3 + @UnderscoredAddress
    
            if (@RelComp_PRListingStatus = 'L') begin
                SET @Paren3 = @Paren3 + ', BBID #' + convert(varchar(15), @RelatedCompanyId)
				if (@RelComp_PRIndustryType != @Comp_PRIndustryType) begin
					SET @Paren3 = @Paren3 + ' in the ' + @RelComp_PRIndustryTypeDesc + ' section';
				end
            end else begin
                if (@RelComp_CreditWorth is not null) begin
                    -- Check the CreditWorth name on the subject company. Use the parent if set to 150.
                    Set @Comp_CreditWorth = 'N/A';
                    Select @Comp_CreditWorth = Coalesce(prcw_Name, '')
                      From PRRating WITH (NOLOCK)
		                   Left Outer Join PRCreditWorthRating WITH (NOLOCK) On (prcw_CreditWorthRatingId = prra_CreditWorthId)
                     Where prra_Current = 'Y' And prra_CompanyId = @CompanyId;

                    if (@Comp_CreditWorth = '(150)')
                        Set @Paren3 = @Paren3 + ', ' + @RelComp_CreditWorth
                end
            end
            SET @Paren3 = @Paren3 + ')'
        end
    end
    -- this should be a branch but make sure
    else if (@comp_PRType = 'B')
    begin
        -- get relevent information for the related company; in this case the HQ
        SELECT  @RelComp_PRLegalName = comp_PRLegalName, 
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
           FROM company WITH (NOLOCK) 
                JOIN vPRLocation WITH (NOLOCK) ON comp_PRListingCityId = prci_CityId 
                LEFT OUTER JOIN PRRating WITH (NOLOCK) on comp_companyid = prra_CompanyId and prra_Current = 'Y'
                LEFT OUTER JOIN PRCreditWorthRating WITH (NOLOCK) on prra_CreditWorthId = prcw_CreditWorthRatingId
                JOIN Custom_Captions WITH (NOLOCK) On comp_PRIndustryType = capt_Code and capt_Family = 'comp_PRIndustryType'
          WHERE comp_companyid = @comp_PRHQId;
    
        -- get the country id
        SELECT @comp_CountryId = prst_CountryId
          FROM company WITH (NOLOCK) 
               JOIN vPRLocation WITH (NOLOCK) ON comp_PRListingCityId = prci_CityId 
         WHERE comp_companyid = @CompanyId;

		SET @Address = @RelComp_City
		SET @UnderscoredAddress = REPLACE(@RelComp_City, ' ', '_')
		IF (@RelComp_State IS NOT NULL AND @RelComp_State != '') BEGIN
			SET @UnderscoredAddress = @UnderscoredAddress + ', ' + REPLACE(@RelComp_State, ' ', '_')
			SET @Address = @Address + ', ' + @RelComp_State
		END

        if (@comp_CountryId != @RelComp_CountryId)
        BEGIN
            SET @Address = @Address + ', ' + @RelComp_Country 
            SET @UnderscoredAddress = @UnderscoredAddress + ', ' + REPLACE(@RelComp_Country, ' ', '_') 
        END
		
        if (@comp_PRListingCityId = @RelComp_PRListingCityId)
        begin
            SET @Paren3 = '(See ' + @RelComp_Name
            if (@RelComp_Name = @comp_Name)
                SET @Paren3 = @Paren3 + ', BB# ' + convert(varchar(20), @comp_PRHQId) 
			SET @Paren3 = @Paren3 + ', ' + @UnderscoredAddress             
            if (@RelComp_PRIndustryType is not null and @comp_PRIndustryType != @RelComp_PRIndustryType)
                SET @Paren3 = @Paren3 + ' in ' + @RelComp_PRIndustryTypeDesc + ' section'
            SET @Paren3 = @Paren3 + ')'
        end
        else 
        begin
            if (@RelComp_Name != @comp_Name)
                SET @Paren3 = '(See ' + @RelComp_Name + ', '
            else
                SET @Paren3 = '(See '

            SET @Paren3 = @Paren3 + @UnderscoredAddress
    
            if (@RelComp_PRIndustryType is not null and @comp_PRIndustryType != @RelComp_PRIndustryType)
                SET @Paren3 = @Paren3 + ' in ' + @RelComp_PRIndustryTypeDesc + ' section'

            SET @Paren3 = @Paren3 + ')'
        end
    end
	SELECT @Paren3 = dbo.ufn_ApplyListingLineBreaksForLogo(@Paren3, @LineBreakChar, @LogoLineSize, @LineSize, @LineLimit)
	IF (@Paren3 is not null AND @Paren3 != '')
		SET @LineLimit = @LineLimit - (dbo.ufn_CountOccurrences(@lineBreakChar, @Paren3) + 1);

	-- Replace the underscored city, state, and country with the "spaced" equivalents
    IF (@UnderscoredAddress IS NOT NULL) BEGIN
 	    -- This doesn't work if the address spans multipe lines.  Checked w/MRR
		-- and it was agreed to blindly replace all underscores for now.
		-- SET @RetValue = REPLACE(@RetValue, @UnderscoredAddress, @Address)
		-- SET @RetValue = REPLACE(@RetValue, '_', ' ')
		SET @Paren3 = REPLACE(@Paren3, '_', ' ')
	END

	-- Build the return value
	Set @RetValue = '';
	If (Len(Coalesce(@Paren1, '')) > 0)
		Set @RetValue = @Paren1;
	
	If (Len(Coalesce(@Paren2, '')) > 0)
		Set @RetValue = @RetValue + Case When Len(@RetValue) > 0 Then @LineBreakChar Else '' End + @Paren2;

	If (Len(Coalesce(@Paren3, '')) > 0)
		Set @RetValue = @RetValue + Case When Len(@RetValue) > 0 Then @LineBreakChar Else '' End + @Paren3;
		
	-- Above in the code this value is reset to an empty
	-- string.  It cannot be set to NULL as then any subsequent concatentations
    -- will result in NULL.  However, at this point, if we don't have any data
    -- we want to return NULL instead of an empty string to avoid adding empty
	-- lines to the listing.    
	IF @RetValue = '' SET @RetValue = NULL
    
	RETURN @RetValue
END
GO

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
	DECLARE @Return varchar(8000)
	SET @Return = dbo.ufn_GetListingParentheticalBlock2(@CompanyID,@LineBreakChar, DEFAULT, DEFAULT, DEFAULT)  
	RETURN @Return
END
Go


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
RETURNS varchar(5000)
AS
BEGIN
/*  DEBUGGING BLOCK
    DECLARE @CompanyId int; SET @CompanyId = 
    DECLARE @LineBreakChar nvarchar(50); SET @LineBreakChar = CHAR(10)
	DECLARE @LogoLineSize int; SET @LogoLineSize= 22
	DECLARE @LineLimit int; SET @LineLimit= 0
*/
	DECLARE @LineSize int; SET @LineSize= 34
    DECLARE @RetVal varchar(5000)
	DECLARE @Line varchar(5000)
    DECLARE @Delimiter varchar(4), @DelimiterIndex int
    IF (@LineBreakChar IS NULL)
        SET @LineBreakChar = '<br/>'
	Declare @EmailCount int
	DECLARE @Emails TABLE (emai_ndx int identity,
			emai_type varchar(100), emai_typecode varchar(40), 
			emai_Description varchar(100), emai_Address varchar(255)
	)
	DECLARE @Ndx int, @Type varchar(100), @TypeCode varchar(40), 
			@Description varchar(100), @Address varchar(255)
	INSERT INTO @Emails
		SELECT Capt_US, RTRIM(elink_Type) AS TypeCode, 
				COALESCE(emai_PRDescription + ': ',''),
				CASE WHEN RTRIM(elink_Type) = 'W' THEN RTRIM(emai_PRWebAddress) ELSE RTRIM(emai_EmailAddress) END
		  FROM vCompanyEmail WITH (NOLOCK) 
		       INNER JOIN Custom_Captions WITH (NOLOCK) on elink_Type = capt_Code and capt_Family='emai_Type'
		 WHERE elink_RecordID = @CompanyId
		   AND emai_PRPublish = 'Y' 
		   AND emai_Deleted IS NULL 
		ORDER BY elink_Type, emai_PRSequence;

	SELECT @EmailCount = count (1) from @Emails
	SET @Ndx = 1
	SET @Line = ''
	DECLARE @Conjunction varchar(5); SET @Conjunction = '';
	DECLARE @ValueToAppend varchar(255); SET @ValueToAppend = '';
	-- GroupTotal is the number of emails in the same type and desc
	-- GroupCount is our counter to tell which rec of the group we are processing
	-- These are most likely going to be 1 but we will leave as is for future flexability
	DECLARE @GroupCount int, @GroupTotal int 
	SET @GroupCount = 1;
	SET @GroupTotal = -1;
	WHILE (@Ndx <= @EmailCount) BEGIN
		-- Get the current record from our temp table
		SELECT @Type = emai_type, @TypeCode = emai_typecode, 
				@Description = emai_Description, @Address = emai_Address
		  FROM @Emails
		 WHERE emai_ndx = @Ndx
		SET @Conjunction = ''
		-- Determine if we need a new group
		IF (@GroupCount > @GroupTotal) BEGIN
			SELECT @GroupTotal = count (1) 
			  FROM @Emails 
			 WHERE emai_Type = @Type AND emai_Description = @Description
			SET @GroupCount = 1 
			SET @Line = ''
		END
		-- if this is the second to last line, use "or"
		-- if this is the last line of a group, use nothing
		-- otherwise, use a comma
		IF (@GroupCount = @GroupTotal -1 )
			SET @Conjunction = ' or '
		ELSE IF (@GroupCount != @GroupTotal)  
			SET @Conjunction = ', '
		SET @ValueToAppend = ''
		IF (@GroupCount != 1) BEGIN
			SET @Description = ''
		END
			IF (LEN(@Description) + LEN(@Address) + 1 + LEN(RTRIM(@Conjunction)) > @LineSize - LEN(@Line) ) BEGIN
				-- for web addresses, we allow the www. to try to exist on the same line
				IF (@Line != '' and @TypeCode = 'E') BEGIN
					SET @RetVal = COALESCE(@RetVal + @LineBreakChar, '') + @Line
					SET @Line = ''
				END
				-- we need to break the line
				-- set our delimiter 
				IF (@TypeCode = 'E') BEGIN 
					SET @Delimiter = '@'
					SET @DelimiterIndex = CHARINDEX('@', @Address)
				END ELSE BEGIN
					SET @Delimiter = 'www.'
					SET @DelimiterIndex = 1
				END
				-- we need to see if the address exceeds our line size
				IF (LEN(@Address) + LEN(RTRIM(@Conjunction)) <= @LineSize) BEGIN				
					IF (@Line != '' and @TypeCode = 'W') BEGIN
						SET @RetVal = COALESCE(@RetVal + @LineBreakChar, '') + @Line
						SET @Line = ''
					END

					IF (@Description != '') BEGIN
						SET @RetVal = COALESCE(@RetVal + @LineBreakChar, '') + dbo.ufn_ApplyListingLineBreaks(@Description, @LineBreakChar)
					END

				END ELSE BEGIN
					DECLARE @Value varchar(255)
					DECLARE @PostDelimiter varchar(500)
					IF (@TypeCode = 'E') BEGIN 
						-- determine what exists before the delimiter
						SET @Value = SUBSTRING(@Address, 1, @DelimiterIndex + LEN(@Delimiter) -1)
						SET @PostDelimiter = SUBSTRING(@Address, @DelimiterIndex+1, LEN(@Address) -1)
						IF (LEN(@Description) + Len(@Value) > @LineSize)
						BEGIN
							-- description goes to it's own line and gets cleared
							IF (@Description != '')
								SET @RetVal = COALESCE(@RetVal + @LineBreakChar, '') + @Description
							SET @Description = ''
							IF (Len(@PostDelimiter) > @LineSize) BEGIN
								SET @Value = @Value + @PostDelimiter
								SET @PostDelimiter = ''
							END 
						-- description and delimiter go on one line
						END ELSE BEGIN

							SET @RetVal = COALESCE(@RetVal + @LineBreakChar, '') + @Description + @Value
							SET @Value = @PostDelimiter
							SET @PostDelimiter = ''
/*
							-- if the @PostDelimiter alone is > linesize, just wrap everything at linesize
							IF (Len(@PostDelimiter) > @LineSize) BEGIN
								SET @Value = @Value + @PostDelimiter
							END ELSE BEGIN
								SET @RetVal = COALESCE(@RetVal + @LineBreakChar, '') + @Description + @Value
								SET @Value = @PostDelimiter
							END
							SET @PostDelimiter = ''
*/
						END
						WHILE (Len(@Value) > @LineSize)
						BEGIN
							SET @RetVal = COALESCE(@RetVal + @LineBreakChar, '') + SUBSTRING(@Value, 1, @LineSize)
							SET @Value = SUBSTRING(@Value, @LineSize+1, LEN(@Value)-1)								
						END
						IF (Len(@Value) + Len(@PostDelimiter) > @LineSize) BEGIN
							SET @RetVal = COALESCE(@RetVal + @LineBreakChar, '') + @Value
							SET @Address = @PostDelimiter
						END ELSE BEGIN
							SET @Address = @Value + @PostDelimiter
						END
					END ELSE BEGIN
						-- if there is anything left on line, set it as the descrition
						IF (@Line != '') BEGIN
							SET @Description = @Line + @Description
							SET @Line = ''
						END						
						-- determine what exists after the delimiter
						--SET @Value = SUBSTRING(@Address, @DelimiterIndex+LEN(@Delimiter), LEN(@Address) -1)
						IF (@Address LIKE 'www.%') BEGIN				
							-- determine what exists after the delimiter
							SET @Value = SUBSTRING(@Address, @DelimiterIndex+LEN(@Delimiter), LEN(@Address) -1)
						END ELSE BEGIN
							SET @Value = @Address
						END

						IF (LEN(@Description) + Len(@Address) > @LineSize)
						BEGIN
							-- if just the address after the www. is > linesize, don't split the delimiter out
							IF (Len(@Value) > @LineSize) BEGIN
								SET @Value = @Description + @Address
								SET @Description = ''								
							END ELSE BEGIN
								-- Otherwise, add the description and delimiter
								SET @Description = @Description + @Delimiter
							END
							-- description goes to it's own line and gets cleared
							IF (@Description != '') BEGIN
								SET @RetVal = COALESCE(@RetVal + @LineBreakChar, '') + @Description
								SET @Description = ''
							END
							WHILE (Len(@Value) > 34)
							BEGIN
								SET @RetVal = COALESCE(@RetVal + @LineBreakChar, '') + SUBSTRING(@Value, 1, 34)
								SET @Value = SUBSTRING(@Value, 35, LEN(@Value)-1)								
							END	
							SET @Address = @Value
						END
					END
				END
			END ELSE BEGIN
				SET @Address = @Description + @Address
			END
		IF ( LEN(@Address) + LEN(RTRIM(@Conjunction)) <= 34 )
			SET @Line = @Address + @Conjunction
		ELSE BEGIN
			SET @RetVal = COALESCE(@RetVal + @LineBreakChar, '') + @Address
			SET @Line = LTRIM(@Conjunction)
		END	

		SET @GroupCount = @GroupCount +1 
		IF (@GroupCount > @GroupTotal) BEGIN
			SET @RetVal = COALESCE(@RetVal + @LineBreakChar, '') + @Line 
		END
		SET @Ndx = @Ndx + 1
	End
--	SELECT @RetVal
    RETURN @RetVal
END
GO


/* 
    This function formats the address for a listing line.
*/
If Exists (Select name from sysobjects where name = 'ufn_FormatAddress' and type in (N'FN', N'IF', N'TF')) 
	Drop Function dbo.ufn_FormatAddress
Go

CREATE FUNCTION dbo.ufn_FormatAddress(@LineBreakChar varchar(50),
                                      @Description varchar(50),
									  @Address1 varchar(50),
									  @Address2 varchar(50),
									  @Address3 varchar(50),
									  @Address4 varchar(50),
									  @Address5 varchar(50),
									  @CityID int,
									  @City varchar(50),
									  @StateID int,
									  @State varchar(50),
									  @CountryID int,
									  @Country varchar(50),
									  @Postal varchar(50),
                                      @ListingCityID int,
                                      @Type varchar(40),
									  @LogoLineSize int = 22,
									  @LineSize int = 34,
									  @LineLimit int = 0)  
RETURNS varchar(5000) AS
BEGIN
	-- Declare a placeholder for the space character when we don't want to break a line on it.
	-- Used for the City, State, Country and Postal codes.
	DECLARE @SpacePlaceHolder CHAR(1)
	SET @SpacePlaceHolder = CHAR(7)    -- Hopefully, no one is actually storing a bell character in the address.

	IF (@LineBreakChar is null)
		SET @LineBreakChar = '<br/>'
	DECLARE @RetVal varchar(1000)
	DECLARE @LastLine varchar(1000)
	-- these values will tell us the number of lines taken up by each address line displayed
	DECLARE @CurrentLimit int	
	DECLARE @AddressLineCount int
	DECLARE @LastLineCount int
	SET @CurrentLimit = @LineLimit
	SET @AddressLineCount = 0
	SET @LastLineCount = 0
	DECLARE @DisplayedCity bit, @DisplayedPostal bit, @DisplayedState bit, @DisplayedCountry bit
	SET @DisplayedCity = 0
	SET @DisplayedPostal = 0
	SET @DisplayedState = 0
	SET @DisplayedCountry = 0
	-- for the logo, if we are still less than 5 lines deep, keep the line restricted to 22 chars
	IF (@LineLimit <= 0) 
		SET @LogoLineSize = @LineSize
	IF (@Address1 IS NOT NULL) BEGIN
		IF (@Address2 IS NULL) BEGIN
			SET @LastLine = ISNULL(@Description + ' ', '') + @Address1
		END ELSE BEGIN
			SET @RetVal = dbo.ufn_AppendListingStringForLogo(@RetVal, ISNULL(@Description + ' ', '') + @Address1, @LineBreakChar, @LogoLineSize, @LineSize, @CurrentLimit)
			-- decrement the line limit by the number of lines used
			SET @AddressLineCount = dbo.ufn_CountOccurrences(@LineBreakChar, @RetVal) + 1
			SET @CurrentLimit = @LineLimit - @AddressLineCount
			IF (@Address3 IS NULL) BEGIN
				SET @LastLine = @Address2
			END ELSE BEGIN
				SET @RetVal = dbo.ufn_AppendListingStringForLogo(@RetVal, @Address2, @LineBreakChar, @LogoLineSize, @LineSize, @CurrentLimit)
				-- decrement the line limit by the number of lines used
				SET @AddressLineCount = dbo.ufn_CountOccurrences(@LineBreakChar, @RetVal)+ 1 
				SET @CurrentLimit = @LineLimit - @AddressLineCount
				IF (@Address4 IS NULL) BEGIN
					SET @LastLine = @Address3
				END ELSE BEGIN
					SET @RetVal = dbo.ufn_AppendListingStringForLogo(@RetVal, @Address3, @LineBreakChar, @LogoLineSize, @LineSize, @CurrentLimit)
					-- decrement the line limit by the number of lines used
					SET @AddressLineCount = dbo.ufn_CountOccurrences(@LineBreakChar, @RetVal)+ 1 
					SET @CurrentLimit = @LineLimit - @AddressLineCount
					IF (@Address5 IS NULL) BEGIN
						SET @LastLine = @Address4
					END ELSE BEGIN
						SET @RetVal = dbo.ufn_AppendListingStringForLogo(@RetVal, @Address4, @LineBreakChar, @LogoLineSize, @LineSize, @CurrentLimit)
						-- decrement the line limit by the number of lines used
						SET @AddressLineCount = dbo.ufn_CountOccurrences(@LineBreakChar, @RetVal)+ 1 
						SET @CurrentLimit = @LineLimit - @AddressLineCount
						SET @LastLine = @Address5
					END
				END
			END
		END
	END
	-- if we have used all the avialble Logo Lines left, change the size of a 
	-- logo line to that of a regular line
	if (@CurrentLimit <= 0 )
		SET @LogoLineSize = @LineSize
	-- from here on out we will assume we are using @LogoLineSize for line size and change this
	-- value when necessary
	-- If our last line is > @LogoLineSize, we need to break it
    -- before we process the city, state, & country
	IF (LEN(@LastLine) > @LogoLineSize) BEGIN
			DECLARE @Pos int
			DECLARE @Pos2 int
			SET @LastLine = dbo.ufn_ApplyListingLineBreaksForLogo(@LastLine, @LineBreakChar, @LogoLineSize, @LineSize, @CurrentLimit)
			SET @Pos = CHARINDEX(@LineBreakChar, @LastLine)
			SET @RetVal = dbo.ufn_AppendListingStringForLogo(@RetVal, 
				SUBSTRING(@LastLine, 1, @Pos-1), @LineBreakChar, @LogoLineSize, @LineSize, @CurrentLimit)
			if (@CurrentLimit > 0 ) Begin
				-- recheck our limits
				SET @AddressLineCount = dbo.ufn_CountOccurrences(@LineBreakChar, @RetVal)+ 1 
				SET @CurrentLimit = @LineLimit - @AddressLineCount
				if (@CurrentLimit <= 0 )
					SET @LogoLineSize = @LineSize
			End
			SET @Pos2 = @Pos + LEN(@LineBreakChar)
			SET @LastLine = SUBSTRING(@LastLine, @Pos2, LEN(@LastLine) - @Pos2 + 1)
	END
	DECLARE @ListingStateID int, 
	        @ListingCountryID int
	        
	        
	SELECT @ListingStateID = prst_StateID,
           @ListingCountryID = prcn_CountryID
      FROM vPRLocation
     WHERE prci_CityID = @ListingCityID;


    IF (@ListingCityID <> @CityID) BEGIN
		IF (SUBSTRING(REVERSE(@LastLine), 1, 1) != ',') BEGIN
			SET @LastLine = @LastLine + ','
			-- After adding any character we have to recheck our line length
			IF (LEN(@LastLine)  > @LogoLineSize) BEGIN
				SET @LastLine = dbo.ufn_ApplyListingLineBreaksForLogo(@LastLine, @LineBreakChar, @LogoLineSize, @LineSize, @CurrentLimit)
				SET @Pos = CHARINDEX(@LineBreakChar, @LastLine)
				SET @RetVal = dbo.ufn_AppendListingStringForLogo(@RetVal, 
					SUBSTRING(@LastLine, 1, @Pos-1), @LineBreakChar, @LogoLineSize, @LineSize, @CurrentLimit)
				if (@CurrentLimit > 0 ) Begin
					-- recheck our limits
					SET @AddressLineCount = dbo.ufn_CountOccurrences(@LineBreakChar, @RetVal)+ 1 
					SET @CurrentLimit = @LineLimit - @AddressLineCount
					if (@CurrentLimit <= 0 )
						SET @LogoLineSize = @LineSize
				End
				SET @Pos2 = @Pos + LEN(@LineBreakChar)
				SET @LastLine = SUBSTRING(@LastLine, @Pos2, LEN(@LastLine) - @Pos2 + 1)
			END 
		END
		IF (LEN(@LastLine) + LEN(@City) + 1) > @LogoLineSize BEGIN
			SET @RetVal = dbo.ufn_AppendListingStringForLogo(@RetVal, @LastLine, @LineBreakChar, 
													@LogoLineSize, @LineSize, @CurrentLimit)
			if (@CurrentLimit > 0 ) Begin
				SET @AddressLineCount = dbo.ufn_CountOccurrences(@LineBreakChar, @RetVal)+ 1 
				SET @CurrentLimit = @LineLimit - @AddressLineCount
				if (@CurrentLimit <= 0 )
					SET @LogoLineSize = @LineSize
			End
			SET @LastLine = REPLACE(@City, ' ', @SpacePlaceHolder)
		END ELSE BEGIN
			SET @LastLine = @LastLine + ' ' + REPLACE(@City, ' ', @SpacePlaceHolder)
		END
	END

    IF (@ListingStateID <> @StateID) AND (LEN(@State) > 0) BEGIN
		SET @DisplayedState = 1
		IF (SUBSTRING(REVERSE(@LastLine), 1, 1) != ',') BEGIN
			SET @LastLine = @LastLine + ','
			-- After adding any character we have to recheck our line length
			IF (LEN(@LastLine)  > @LogoLineSize) BEGIN
				SET @LastLine = dbo.ufn_ApplyListingLineBreaksForLogo(@LastLine, @LineBreakChar, @LogoLineSize, @LineSize, @CurrentLimit)
				SET @Pos = CHARINDEX(@LineBreakChar, @LastLine)
				SET @RetVal = dbo.ufn_AppendListingStringForLogo(@RetVal, 
					SUBSTRING(@LastLine, 1, @Pos-1), @LineBreakChar, @LogoLineSize, @LineSize, @CurrentLimit)
				if (@CurrentLimit > 0 ) Begin
					-- recheck our limits
					SET @AddressLineCount = dbo.ufn_CountOccurrences(@LineBreakChar, @RetVal)+ 1 
					SET @CurrentLimit = @LineLimit - @AddressLineCount
					if (@CurrentLimit <= 0 )
						SET @LogoLineSize = @LineSize
				End
				SET @Pos2 = @Pos + LEN(@LineBreakChar)
				SET @LastLine = SUBSTRING(@LastLine, @Pos2, LEN(@LastLine) - @Pos2 + 1)
			END 
		END
		IF (LEN(@LastLine) + LEN(@State) + 1) > @LogoLineSize BEGIN
			SET @RetVal = dbo.ufn_AppendListingStringForLogo(@RetVal, @LastLine, @LineBreakChar, 
													@LogoLineSize, @LineSize, @CurrentLimit)
			if (@CurrentLimit > 0 ) Begin

				SET @AddressLineCount = dbo.ufn_CountOccurrences(@LineBreakChar, @RetVal)+ 1 
				SET @CurrentLimit = @LineLimit - @AddressLineCount
				if (@CurrentLimit <= 0 )
					SET @LogoLineSize = @LineSize
			End
			SET @LastLine = REPLACE(@State, ' ', @SpacePlaceHolder)
		END ELSE BEGIN
			SET @LastLine = @LastLine + ' ' + REPLACE(@State, ' ', @SpacePlaceHolder)
		END
	END

    IF (@ListingCountryID <> @CountryID) BEGIN
		SET @DisplayedCountry = 1
		IF (SUBSTRING(REVERSE(@LastLine), 1, 1) != ',') BEGIN
			SET @LastLine = @LastLine + ','
			-- After adding any character we have to recheck our line length
			IF (LEN(@LastLine)  > @LogoLineSize) BEGIN
				SET @LastLine = dbo.ufn_ApplyListingLineBreaksForLogo(@LastLine, @LineBreakChar, @LogoLineSize, @LineSize, @CurrentLimit)
				SET @Pos = CHARINDEX(@LineBreakChar, @LastLine)
				SET @RetVal = dbo.ufn_AppendListingStringForLogo(@RetVal, 
					SUBSTRING(@LastLine, 1, @Pos-1), @LineBreakChar, @LogoLineSize, @LineSize, @CurrentLimit)
				if (@CurrentLimit > 0 ) Begin
					-- recheck our limits
					SET @AddressLineCount = dbo.ufn_CountOccurrences(@LineBreakChar, @RetVal)+ 1 
					SET @CurrentLimit = @LineLimit - @AddressLineCount
					if (@CurrentLimit <= 0 )
						SET @LogoLineSize = @LineSize
				End
				SET @Pos2 = @Pos + LEN(@LineBreakChar)
				SET @LastLine = SUBSTRING(@LastLine, @Pos2, LEN(@LastLine) - @Pos2 + 1)
			END 
		END
		IF (LEN(@LastLine) + LEN(@Country) + 1) > @LogoLineSize BEGIN
			SET @RetVal = dbo.ufn_AppendListingStringForLogo(@RetVal, @LastLine, @LineBreakChar, 
													@LogoLineSize, @LineSize, @CurrentLimit)
			if (@CurrentLimit > 0 ) Begin
				SET @AddressLineCount = dbo.ufn_CountOccurrences(@LineBreakChar, @RetVal)+ 1 
				SET @CurrentLimit = @LineLimit - @AddressLineCount
				if (@CurrentLimit <= 0 )
					SET @LogoLineSize = @LineSize
			End
			SET @LastLine = REPLACE(@Country, ' ', @SpacePlaceHolder)
		END ELSE BEGIN
			SET @LastLine = @LastLine + ' ' + REPLACE(@Country, ' ', @SpacePlaceHolder)
		END

	END

	IF (SUBSTRING(@LastLine, LEN(@LastLine), 1) <> '.') BEGIN
		SET @LastLine = @LastLine + '.'
		IF (LEN(@LastLine) > @LogoLineSize) BEGIN
			SET @LastLine = dbo.ufn_ApplyListingLineBreaksForLogo(@LastLine, @LineBreakChar, @LogoLineSize, @LineSize, @CurrentLimit)
			SET @Pos = CHARINDEX(@LineBreakChar, @LastLine)
			SET @RetVal = dbo.ufn_AppendListingStringForLogo(@RetVal, 
				SUBSTRING(@LastLine, 1, @Pos-1), @LineBreakChar, @LogoLineSize, @LineSize, @CurrentLimit)
			if (@CurrentLimit > 0 ) Begin
				-- recheck our limits
				SET @AddressLineCount = dbo.ufn_CountOccurrences(@LineBreakChar, @RetVal)+ 1 
				SET @CurrentLimit = @LineLimit - @AddressLineCount
				if (@CurrentLimit <= 0 )
					SET @LogoLineSize = @LineSize
			End
			SET @Pos2 = @Pos + LEN(@LineBreakChar)
			SET @LastLine = SUBSTRING(@LastLine, @Pos2, LEN(@LastLine) - @Pos2 + 1)
		END
	END

	IF ((@Postal IS NOT NULL) AND (@Type <> 'PH')) BEGIN
		IF (LEN(@LastLine) + LEN(@Postal) + 3) > @LogoLineSize BEGIN
			SET @RetVal = dbo.ufn_AppendListingStringForLogo(@RetVal, @LastLine, @LineBreakChar, 
													@LogoLineSize, @LineSize, @CurrentLimit)
			if (@CurrentLimit > 0 ) Begin
				SET @AddressLineCount = dbo.ufn_CountOccurrences(@LineBreakChar, @RetVal) + 1 

				SET @CurrentLimit = @LineLimit - @AddressLineCount
				if (@CurrentLimit <= 0 )
					SET @LogoLineSize = @LineSize
			End
			SET @LastLine = '(' + REPLACE(@Postal, ' ', @SpacePlaceHolder) + ')'
		END ELSE BEGIN
			SET @LastLine = @LastLine + ' (' + REPLACE(@Postal, ' ', @SpacePlaceHolder) + ')'
		END
	END 

	SET @RetVal = dbo.ufn_AppendListingStringForLogo(@RetVal, @LastLine, @LineBreakChar,
												@LogoLineSize, @LineSize, @CurrentLimit)

	-- We are done with the space placeholder, put the space back in and return the string.
	RETURN REPLACE(@RetVal, @SpacePlaceHolder, ' ')
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
If Exists (Select name from sysobjects where name = 'ufn_GetListingAddressBlock2' and type in (N'FN', N'IF', N'TF')) Drop Function dbo.ufn_GetListingAddressBlock2
Go

CREATE FUNCTION dbo.ufn_GetListingAddressBlock2(@CompanyID int,
                                                @LineBreakChar varchar(50),
												@LogoLineSize int = 22,
												@LineSize int = 34,
												@LineLimit int = 0)  
RETURNS varchar(5000) AS  
BEGIN 
	Declare @LineCount int

	IF (@LineBreakChar is null)
		SET @LineBreakChar = '<br/>'

	DECLARE @RetVal varchar(5000)
	DECLARE @Addresses table(ndx int identity, addressid int)

	INSERT INTO @Addresses 
	SELECT TOP 2 adli_AddressId 
	  FROM Address_Link WITH (NOLOCK)
	       INNER JOIN Address WITH (NOLOCK) ON Addr_AddressId = AdLi_AddressId 
	 WHERE adli_CompanyId=@CompanyID
       AND addr_PRPublish = 'Y'
	   AND Addr_Deleted IS NULL
  ORDER BY dbo.ufn_GetAddressListSeq(adli_Type);

	Declare @ID1 int, @ID2 int
	Declare @ADD1 varchar(2000), @ADD2 varchar(2000)
	SELECT @ID1 = addressid FROM @Addresses WHERE ndx = 1;
	SELECT @ID2 = addressid FROM @Addresses WHERE ndx = 2;

	IF (@ID1 IS NOT NULL) begin
		SELECT @ADD1 = Address
		  FROM(SELECT dbo.ufn_FormatAddress(@LineBreakChar,
					   RTRIM(Addr_PRDescription),RTRIM(Addr_Address1),RTRIM(Addr_Address2), 
					   RTRIM(Addr_Address3),RTRIM(Addr_Address4),RTRIM(Addr_Address5), 
					   prci_CityID, RTRIM(prci_City), prst_StateID, ISNULL(RTRIM(prst_Abbreviation), RTRIM(prst_State)), 
					   prcn_CountryID, RTRIM(prcn_Country),RTRIM(Addr_PostCode),comp_PRListingCityId,
					   adli_Type, @LogoLineSize, @LineSize, @LineLimit) as Address
				  FROM Company WITH (NOLOCK) 
                       INNER JOIN Address_Link WITH (NOLOCK) ON Comp_CompanyId = AdLi_CompanyID 
                       INNER JOIN Address WITH (NOLOCK) ON Addr_AddressId = AdLi_AddressId 
                       INNER JOIN vPRLocation ON addr_PRCityId = prci_CityId
				 WHERE addr_AddressId = @ID1) T1;
	end

	SELECT @LineCount = dbo.ufn_CountOccurrences(@LineBreakChar, @ADD1) + 1
	SET @LineLimit = @LineLimit - @LineCount

	IF (@ID2 IS NOT NULL) begin
		SELECT @ADD2 = Address
		  FROM(SELECT dbo.ufn_FormatAddress(@LineBreakChar,
					   RTRIM(Addr_PRDescription),RTRIM(Addr_Address1),RTRIM(Addr_Address2), 
					   RTRIM(Addr_Address3),RTRIM(Addr_Address4),RTRIM(Addr_Address5), 
					   prci_CityID, RTRIM(prci_City), prst_StateID, ISNULL(RTRIM(prst_Abbreviation), RTRIM(prst_State)), 
					   prcn_CountryID, RTRIM(prcn_Country),RTRIM(Addr_PostCode),comp_PRListingCityId,
					   adli_Type, @LogoLineSize, @LineSize, @LineLimit) as Address
				  FROM Company WITH (NOLOCK) 
                       INNER JOIN Address_Link WITH (NOLOCK) ON Comp_CompanyId = AdLi_CompanyID 
                       INNER JOIN Address WITH (NOLOCK) ON Addr_AddressId = AdLi_AddressId 
                       INNER JOIN vPRLocation ON addr_PRCityId = prci_CityId
				 WHERE addr_AddressId = @ID2) T1;
	end
	RETURN @ADD1 + COALESCE(@LineBreakChar + @ADD2 , '')
END
Go

If Exists (Select name from sysobjects where name = 'ufn_GetListingAddressBlock' and type in (N'FN', N'IF', N'TF')) 
	Drop Function dbo.ufn_GetListingAddressBlock
Go
CREATE FUNCTION dbo.ufn_GetListingAddressBlock(@CompanyID int,
                                               @LineBreakChar varchar(50))  
RETURNS varchar(1000) AS  
BEGIN 
	DECLARE @Return varchar(8000)
	SET @Return = dbo.ufn_GetListingAddressBlock2(@CompanyID,@LineBreakChar, DEFAULT, DEFAULT, DEFAULT)  
	RETURN @Return
END
GO


/* 
    This function returns the listing block for the Brand information for the passed company
*/
If Exists (Select name from sysobjects where name = 'ufn_GetListingBrandBlock' and type in (N'FN', N'IF', N'TF')) Drop Function dbo.ufn_GetListingBrandBlock
Go

CREATE FUNCTION dbo.ufn_GetListingBrandBlock(@CompanyID int,
                                              @LineBreakChar varchar(50))  
RETURNS varchar(5000) AS  
BEGIN 

	IF (@LineBreakChar is null)
		SET @LineBreakChar = '<br/>'

	DECLARE @RetVal varchar(5000)

	SELECT @RetVal = COALESCE(@RetVal + ', ', '') + prc3_Brand
	FROM (SELECT prc3_Brand, MIN(prc3_Sequence) AS Sequence
            FROM PRCompanyBrand WITH (NOLOCK)
           WHERE prc3_CompanyID = @CompanyID
             AND prc3_Publish = 'Y'
             AND prc3_Deleted IS NULL
			 AND prc3_Brand IS NOT NULL
        GROUP BY prc3_Brand) TABLE1
    ORDER BY Sequence;

	-- Now add our prefix
	IF (@RetVal IS NOT NULL) BEGIN
		DECLARE @Count int
		SELECT @Count = COUNT(DISTINCT prc3_Brand)
		  FROM PRCompanyBrand WITH (NOLOCK)
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
IF object_id(N'ufn_GetListingUnloadHoursBlock', N'FN') IS NOT NULL
	DROP FUNCTION dbo.ufn_GetListingUnloadHoursBlock
Go

CREATE FUNCTION dbo.ufn_GetListingUnloadHoursBlock(@CompanyID int,
                                                   @LineBreakChar varchar(50))  
RETURNS varchar(5000) AS  
BEGIN 

	DECLARE @RetVal varchar(5000), @PublishUnloadHours char(1)

	SELECT @PublishUnloadHours = comp_PRPublishUnloadHours
      FROM Company WITH (NOLOCK)
     WHERE comp_CompanyID = @CompanyID;

	IF (@PublishUnloadHours = 'Y') BEGIN

		IF (@LineBreakChar is null)
			SET @LineBreakChar = '<br/>'

		-- line content can be null for a blank line so coalesce it out, otherwise all content
		-- before the blank line will be erased
		SELECT @RetVal = COALESCE(@RetVal + @LineBreakChar, '') + pruh_LineContent
		  FROM PRUnloadHours WITH (NOLOCK)
		 WHERE pruh_CompanyID = @CompanyID
		   AND pruh_Deleted IS NULL
		   AND pruh_LineContent IS NOT NULL
	  ORDER BY pruh_UnloadHoursID; 
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
RETURNS varchar(max) AS  
BEGIN 

	DECLARE @RetVal varchar(max)
	DECLARE @PublishDL char(1)

	SELECT @PublishDL = comp_PRPublishDL
      FROM Company WITH (NOLOCK)
     WHERE comp_CompanyID = @CompanyID;

	IF (@PublishDL = 'Y') BEGIN

		IF (@LineBreakChar is null)
			SET @LineBreakChar = '<br/>'


		-- line content can be null for a blank line so coalesce it out, otherwise all content
		-- before the blank line will be erased
		SELECT @RetVal = COALESCE(@RetVal + @LineBreakChar, '') + prdl_LineContent
		  FROM PRDescriptiveLine WITH (NOLOCK)
		 WHERE prdl_CompanyID = @CompanyID
		   AND prdl_Deleted IS NULL
		   AND prdl_LineContent IS NOT NULL
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
		SET @LineBreakChar = '<br/>'

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
RETURNS varchar(5000)
AS
BEGIN
	RETURN dbo.ufn_GetListingBankBlock2(@CompanyId, @LineBreakChar, 0)
END
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetListingBankBlock2]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_GetListingBankBlock2]
GO
CREATE FUNCTION dbo.ufn_GetListingBankBlock2 ( 
    @CompanyId int,
    @LineBreakChar nvarchar(50),
	@IncludePrefix bit = 0
)
RETURNS varchar(5000)
AS
BEGIN
	IF (@LineBreakChar is null)
		SET @LineBreakChar = '<br/>'

	DECLARE @RetVal varchar(5000)
    DECLARE @Count int 

	SELECT @RetVal = COALESCE(@RetVal + ', ', '') + prcb_Name
	FROM (SELECT prcb_Name
            FROM PRCompanyBank WITH (NOLOCK)
           WHERE prcb_CompanyID =  @CompanyID
             AND prcb_Publish = 'Y'
             AND prcb_Deleted IS NULL
         ) TABLE1
    SET @Count = @@ROWCOUNT
	-- Now add our prefix
	IF(@IncludePrefix > 0)
	BEGIN
		IF (@Count > 1) 
		BEGIN
			SET @RetVal = 'Banks: ' + @RetVal
		END ELSE BEGIN
			SET @RetVal = 'Bank: ' + @RetVal
		END
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
RETURNS varchar(5000) AS  
BEGIN 

	IF (@LineBreakChar is null)
		SET @LineBreakChar = '<br/>'

	DECLARE @RetVal varchar(5000)

	SELECT @RetVal = COALESCE(@RetVal + @LineBreakChar, '') + StockSymbol
      FROM (
		SELECT TOP 1000 dbo.ufn_FormatStockSymbols(@LineBreakChar, prex_Name, prc4_Symbol1, prc4_Symbol2, prc4_Symbol3) as StockSymbol
		  FROM PRStockExchange WITH (NOLOCK)
               INNER JOIN PRCompanyStockExchange WITH (NOLOCK) ON prex_StockExchangeID = prc4_StockExchangeID
         WHERE prc4_CompanyId = @CompanyID
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
		SET @LineBreakChar = '<br/>'

	DECLARE @RetVal varchar(1000)

	SELECT @RetVal = COALESCE(@RetVal + @LineBreakChar, '') + dbo.ufn_ApplyListingLineBreaks(Name + License, @LineBreakChar)
	 FROM (
		SELECT dbo.ufn_GetListingLicenseSeq('PACA') AS Seq, 'PACA License #' AS Name, prpa_LicenseNumber As License
		  FROM PRPACALicense WITH (NOLOCK)
		 WHERE prpa_CompanyID = @CompanyID
		   AND prpa_Deleted IS NULL
		   AND prpa_Publish = 'Y'
		UNION
		SELECT dbo.ufn_GetListingLicenseSeq('DRC'), 'DRC Member', ''
		  FROM PRDRCLicense WITH (NOLOCK)
		 WHERE prdr_CompanyID = @CompanyID
		   AND prdr_Publish = 'Y'
		   AND prdr_Deleted IS NULL
		UNION
		SELECT dbo.ufn_GetListingLicenseSeq(prli_Type), 
			   COALESCE(cast(capt_us as varchar) + ' ', '') + '#', prli_Number
		  FROM PRCompanyLicense WITH (NOLOCK)
		       INNER JOIN custom_captions on capt_family = 'prli_Type' and capt_code = prli_Type
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
*/
If Exists (Select name from sysobjects where name = 'ufn_GetListingClassificationBlock' and type in (N'FN', N'IF', N'TF')) Drop Function dbo.ufn_GetListingClassificationBlock
Go

CREATE FUNCTION dbo.ufn_GetListingClassificationBlock(@CompanyID int,
                                                      @IndustryType varchar(40),
                                                      @LineBreakChar varchar(50))  
RETURNS varchar(5000) AS  
BEGIN 

	IF (@LineBreakChar is null)
		SET @LineBreakChar = '<br/>'

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

    DECLARE @Classifications table(ndx smallint identity, value nvarchar(100))

    IF (@IndustryType = 'S' ) BEGIN
		-- set this value here instead of in getListing so that we can wrap properly
		SET @CurrRowVal = 'Products & Services: '
		INSERT INTO @Classifications (value)
		SELECT prcl_Name 
		  FROM PRClassification WITH (NOLOCK) 
			   INNER JOIN PRCompanyClassification WITH (NOLOCK) ON prcl_ClassificationId = prc2_ClassificationId
		 WHERE prc2_CompanyID = @CompanyID
		   AND prc2_Deleted IS NULL
		 ORDER BY ISNULL(prc2_Sequence,0) ASC, prcl_Name ASC;
		
		SET @Count = @@ROWCOUNT
		SET @Separator = ','
		SET @Spacing = ' '

	END ELSE IF @IndustryType = 'L' BEGIN
		-- set this value here instead of in getListing so that we can wrap properly
		SET @CurrRowVal = 'Classifications: '
		INSERT INTO @Classifications (value)
		SELECT ISNULL(prcl_Abbreviation, prcl_Name)
		  FROM PRClassification WITH (NOLOCK) 
			   INNER JOIN PRCompanyClassification WITH (NOLOCK) ON prcl_ClassificationId = prc2_ClassificationId
		 WHERE prc2_CompanyID = @CompanyID
		   AND prc2_Deleted IS NULL
		 ORDER BY ISNULL(prc2_Sequence,0) ASC, ISNULL(prcl_Abbreviation, prcl_Name) ASC;
	
		SET @Count = @@ROWCOUNT
		SET @Separator = ','
		SET @Spacing = ' '

	END ELSE BEGIN
		INSERT INTO @Classifications (value)
		SELECT prcl_Abbreviation
		  FROM PRClassification WITH (NOLOCK) 
			   INNER JOIN PRCompanyClassification WITH (NOLOCK) ON prcl_ClassificationId = prc2_ClassificationId
		 WHERE prc2_CompanyID = @CompanyID
		   AND prc2_Deleted IS NULL
		 ORDER BY ISNULL(prc2_Sequence,0) ASC, ISNULL(prc2_Percentage,0) DESC, prc2_CompanyClassificationID;
		SET @Count = @@ROWCOUNT
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

			-- note: using replace is necessary because trailing spaces are not counted
			-- i.e select Len('gus ') = 3
			SET @ValueLength = Len(Replace(@Value,' ', '-')) + Len(@Separator)

			-- if this classification will fit on the current line, append it
			if (Len(Replace(@CurrRowVal,' ', '-')) + @ValueLength < @LineSize) 
				SET @CurrRowVal = @CurrRowVal + @Value + @Separator + @Spacing
			else if (Len(Replace(@CurrRowVal,' ', '-')) + @ValueLength = @LineSize) 
				SET @CurrRowVal = @CurrRowVal + @Value + @Separator
			else
			begin
				-- start a new row
				SET @RetVal = COALESCE(@RetVal + @LineBreakChar, '') + @CurrRowVal
				SET @CurrRowVal = @Value + @Separator + @Spacing

				-- These industry types can be trading members which means thier listing
				-- can be bold in the book.  To make room for the larger bolded characters
				-- lines > 1 have a smaller size.
				IF (@IndustryType IN ('P', 'T' )) BEGIN			
					SET @LineSize = 32
				END
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
						@IndustryType varchar(40),
						@LineBreakChar nvarchar(50)
)
RETURNS varchar(5000)
AS
BEGIN
    DECLARE @LineSize tinyint

    SET @LineSize = 34

	IF (@LineBreakChar is null)
		SET @LineBreakChar = '<br/>'

	DECLARE @RetVal varchar(5000)
	-- will contain the contents of the current row being built
    DECLARE @CurrRowVal varchar(5000)
    DECLARE @Value varchar(100)
    DECLARE @Count smallint, @ValueLength smallint, @ClassVolumeLength smallint
    DECLARE @ndx tinyint 
    DECLARE @Classifications varchar(5000)
    DECLARE @Volume varchar(50)
    
    SELECT @Volume = capt_US
      FROM PRCompanyProfile WITH (NOLOCK)  
           INNER JOIN Custom_Captions WITH (NOLOCK) ON capt_code = prcp_Volume AND capt_family = 'prcp_Volume'
     WHERE prcp_CompanyId = @CompanyId;
    
	SELECT @Classifications = dbo.ufn_GetListingClassificationBlock(ABS(@CompanyId), @IndustryType, @LineBreakChar)

    DECLARE @Commodities table(ndx smallint identity, value nvarchar(100)	)

    -- Because Classification and volume can affect the line breaks of commodities, we have to 
    -- determine how the first line will break when these values are there; they will be 
    -- removed before returning the result
    SET @CurrRowVal = ISNULL(Coalesce(@Classifications + ' ', '') + Coalesce(@Volume + ' ', ''), '') 

	DECLARE @LineBreakPos int
	SET @LineBreakPos = CHARINDEX(@LineBreakChar,@CurrRowVal)
	WHILE ( @LineBreakPos > 0) BEGIN
		SET @CurrRowVal =  SUBSTRING(@CurrRowVal, @LineBreakPos + Len(@LineBreakChar), (Len(@CurrRowVal)+1) - (@LineBreakPos + Len(@LineBreakChar)-1))
		SET @LineBreakPos = CHARINDEX(@LineBreakChar,@CurrRowVal)
	END

	SET @ClassVolumeLength = Len(@CurrRowVal)
	IF (@ClassVolumeLength > 0) BEGIN
		SET @ClassVolumeLength = @ClassVolumeLength + 1 -- add one for the last space; len won't count it
	END


    INSERT INTO @Commodities 
        SELECT prcca_PublishedDisplay 
          FROM PRCompanyCommodityAttribute WITH (NOLOCK)
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
    @TextBlock varchar(max),
    @LineBreakChar varchar(50),
    @IndentString varchar(50),
    @IsHangingIndent bit
)
RETURNS varchar(max)
AS
BEGIN
    IF (@TextBlock is null)
        RETURN NULL

    DECLARE @RetValue varchar(max)
    SET @RetValue = ''
    IF (@IsHangingIndent = 0 )    
        SET @RetValue = @IndentString 
 
    SET @RetValue = @RetValue +
                    REPLACE(@TextBlock, @LineBreakChar, @LineBreakChar + @IndentString) 

    RETURN @RetValue
END
GO

-- **********************************************************************************************
-- *  ufn_GetListingClassVolCommBlock determines the complete block of Classifciation, Volume, 
-- *  and Commodity concatentated together.  Currently this is only used from 
-- *  ufn_GetListingClassVolCommLineCoutn but it can (later) be placed in the getListing... 
-- *  functions to reduce the redundant code.
-- *  
-- **********************************************************************************************
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetListingClassVolCommBlock]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_GetListingClassVolCommBlock]
GO
Create FUNCTION [dbo].[ufn_GetListingClassVolCommBlock] ( 
    @CompanyId int,
    @FormattingStyle tinyint = 0 -- 0: <BR/> 1: CHR(10) 2: CHR(10 & 13)
)

RETURNS varchar(6000)
AS
BEGIN
    DECLARE @RetValue varchar(6000)
	SET @RetValue = ''
    DECLARE @LineBreakChar varchar(50)
    DECLARE @Space varchar(10) 
    DECLARE @Indent2 varchar(40), @Indent3 varchar(40)
    IF (@FormattingStyle = 0) BEGIN
        SET @Space = '&nbsp;'
        SET @LineBreakChar = '<br/>'
    END ELSE IF (@FormattingStyle = 1) BEGIN
        SET @Space = ' '
        SET @LineBreakChar = CHAR(10)
    END ELSE IF (@FormattingStyle = 2) BEGIN
        SET @Space = ' '
        SET @LineBreakChar = CHAR(13)+CHAR(10)
    END ELSE IF (@FormattingStyle = 3) BEGIN
        SET @Space = ' '
        SET @LineBreakChar = CHAR(9)
    END ELSE IF (@FormattingStyle = 4) BEGIN
        SET @Space = ' '
        SET @LineBreakChar = CHAR(9)
    END

	IF (@FormattingStyle = 3) BEGIN
		SET @Indent2 = ''
		SET @Indent3 = '' 
	END ELSE BEGIN
		SET @Indent2 = @Space + @Space
		SET @Indent3 = @Space + @Space + @Space 
	END

    DECLARE @comp_PRIndustryType varchar(40)
    DECLARE @prcp_VolumeDesc varchar(50)
    DECLARE @prcp_LumberVolumeDesc varchar(50)
    DECLARE @ClassificationBlock varchar(5000)
    DECLARE @CommodityBlock varchar(5000)

	SELECT @comp_PRIndustryType = comp_PRIndustryType,
		   @prcp_VolumeDesc = a.capt_US,
		   @prcp_LumberVolumeDesc = b.capt_US,
		   @ClassificationBlock = dbo.ufn_GetListingClassificationBlock(ABS(@CompanyId), comp_PRIndustryType, @LineBreakChar),
		   @CommodityBlock = dbo.ufn_GetListingCommodityBlock(@CompanyId, comp_PRIndustryType, @LineBreakChar)
	  FROM Company WITH (NOLOCK)
	       LEFT OUTER JOIN PRCompanyProfile WITH (NOLOCK) ON comp_CompanyId = ABS(prcp_CompanyId)
	       LEFT OUTER JOIN Custom_Captions a WITH (NOLOCK) ON a.capt_code = prcp_Volume AND a.capt_family = 'prcp_Volume'
	       LEFT OUTER JOIN Custom_Captions b WITH (NOLOCK) ON b.capt_code = prcp_Volume AND b.capt_family = 'prcp_VolumeL'
	 WHERE comp_companyid = ABS(@CompanyId);

    DECLARE @ClassVolCommBlock varchar(3000)
    IF (@comp_PRIndustryType in ('P', 'T'))
    begin    
        SET @ClassVolCommBlock = ''
        SET @ClassVolCommBlock = @ClassVolCommBlock + 
            ISNULL(@Space + dbo.ufn_indentListingBlock(@ClassificationBlock, @LineBreakChar, @Indent2, 1)+@Space, '') +
            ISNULL(@prcp_VolumeDesc + @Space, '')
        IF (@comp_PRIndustryType = 'P')
        begin
            SET @ClassVolCommBlock = @ClassVolCommBlock + 
                ISNULL(dbo.ufn_indentListingBlock(@CommodityBlock, @LineBreakChar, @Indent2, 1), '') 
        end
		-- If we don't have any values here, reset this
		-- to NULL so we don't end up with a blank line
		IF (@ClassVolCommBlock = '') BEGIN
			SET @ClassVolCommBlock = NULL
		END 
        SET @RetValue = @RetValue + ISNULL(@ClassVolCommBlock, '')
    end
    else IF (@comp_PRIndustryType IN ('S', 'L'))
    begin
		IF (@prcp_LumberVolumeDesc is not null) BEGIN
			SET @RetValue = @RetValue + dbo.ufn_indentListingBlock('Volume: ' + @prcp_LumberVolumeDesc, @LineBreakChar, @Space, 0);
		END
    
        IF (@ClassificationBlock is not null)
        begin
            -- 'Product & Services: ' label is now done in getListingClassificationBlock
			DECLARE @Line varchar(1000) 
			DECLARE @Line1Ndx int
			SET @Line1Ndx = charindex(@LineBreakChar, @ClassificationBlock)
			IF (@Line1Ndx > 0) BEGIN
				SET @Line = SUBSTRING(@ClassificationBlock, 1, @Line1Ndx-1)
				
				IF (LEN(@RetValue) > 0) BEGIN
					SET @RetValue = @RetValue + @LineBreakChar;
				END
				
				SET @RetValue = @RetValue + COALESCE(dbo.ufn_indentListingBlock(@Line, @LineBreakChar, @Space, 0), '')
				SET @ClassificationBlock = SUBSTRING(@ClassificationBlock, @Line1Ndx + Len(@LineBreakChar), Len(@ClassificationBlock)-1)
			END 

			IF (@ClassificationBlock IS NOT NULL) BEGIN
				IF (LEN(@RetValue) > 0) BEGIN
					SET @RetValue = @RetValue + @LineBreakChar;
				END

				SET @RetValue = @RetValue + dbo.ufn_indentListingBlock(@ClassificationBlock, @LineBreakChar, @Indent2, 0)
			END   
        end
    end

	IF (LEN(@RetValue) = 0) BEGIN
		SET @RetValue = NULL
	END
    RETURN @RetValue
END
GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetListingClassVolCommLineCount]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_GetListingClassVolCommLineCount]
GO
CREATE FUNCTION [dbo].[ufn_GetListingClassVolCommLineCount](@CompanyID int)
RETURNS int AS  
BEGIN
	DECLARE @LineCount int
	DECLARE @LineBreakChar varchar(5)
	DECLARE @Block varchar(8000)
	SET @LineBreakChar = '<br/>'
	SET @LineCount = 0
	SET @Block = dbo.ufn_GetListingClassVolCommBlock(@CompanyID, 0)
	IF (@Block IS NOT NULL) BEGIN
		SET @LineCount = dbo.ufn_CountOccurrences(@LineBreakChar, @Block) + 1
	END
	RETURN @LineCount
END
GO



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetNumberOfStoresValue]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_GetNumberOfStoresValue]
GO

CREATE FUNCTION dbo.ufn_GetNumberOfStoresValue(@CompanyID int,
                                               @ClassificationID int)  
RETURNS varchar(40) AS  
BEGIN 

	DECLARE @Return varchar(40)

	SELECT @Return = Capt_US
	  FROM PRCompanyClassification  WITH (NOLOCK)
		   INNER JOIN Custom_Captions WITH (NOLOCK) ON prc2_NumberOfStores = capt_Code AND capt_Family = 'prc2_StoreCount'
	 WHERE prc2_ClassificationId = @ClassificationID
	   AND prc2_CompanyId = @CompanyId
	   AND prc2_Deleted IS NULL;

	RETURN @Return
END
Go


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetListingChainStoresBlock]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_GetListingChainStoresBlock]
GO

CREATE FUNCTION dbo.ufn_GetListingChainStoresBlock(@CompanyID int,
                                                   @IndustryType varchar(40),
                                                   @LineBreakChar varchar(50))  
RETURNS varchar(1000) AS  
BEGIN 

	IF (@LineBreakChar is null)
		SET @LineBreakChar = '<br/>'

    DECLARE @LineSize tinyint
    SET @LineSize = 34

	DECLARE @RetVal varchar(1000)

	IF (@IndustryType = 'L') BEGIN
		DECLARE @RetailLumberYard varchar(40)
		DECLARE @HomeCenter  varchar(40)
		DECLARE @ProDealer varchar(40)

		SET @RetailLumberYard = dbo.ufn_GetNumberOfStoresValue(@CompanyID, 2190)
		SET @HomeCenter = dbo.ufn_GetNumberOfStoresValue(@CompanyID, 2191)
		SET @ProDealer = dbo.ufn_GetNumberOfStoresValue(@CompanyID, 2192)

		IF (@RetailLumberYard IS NOT NULL) BEGIN
			SET @RetVal = @RetailLumberYard + ' Retail Lumber Yard'
		END

		IF (@HomeCenter IS NOT NULL) BEGIN
			IF (@RetVal IS NOT NULL) BEGIN
				SET @RetVal = @RetVal + ' & '
			END
			SET @RetVal = ISNULL(@RetVal, '') + @HomeCenter + ' Home Center'
		END

		IF (@ProDealer IS NOT NULL) BEGIN
			IF (@RetVal IS NOT NULL) BEGIN
				SET @RetVal = @RetVal + ' & '
			END
			SET @RetVal = ISNULL(@RetVal, '') + @ProDealer + ' Pro Dealer'
		END

		IF (@RetVal IS NOT NULL) BEGIN
			SET @RetVal = 'Chain: ' + @RetVal 
		END

	END ELSE IF (@IndustryType = 'P') BEGIN

		DECLARE @Retail varchar(40)
		DECLARE @Restaraunt varchar(40)

		SET @Retail = dbo.ufn_GetNumberOfStoresValue(@CompanyID, 330)
		SET @Restaraunt = dbo.ufn_GetNumberOfStoresValue(@CompanyID, 320)

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
    @IndustryType varchar(40),
    @FormatOptions int = 1,  -- 0: Comma Separated  1: Leader  2: Tab Delimited,
    @LineBreakChar varchar(10) = '<br/>'
)
RETURNS varchar(500)
AS
BEGIN

	DECLARE @RetVal varchar(500)

	DECLARE @RatingLine varchar(500), @RatingDescription varchar(100), @Type varchar(40)
	DECLARE @HQID int, @IsHQ bit, @IsHQRating bit
	DECLARE @Count int, @DescLength int, @RatingLength int
	
	-- set the default values, otherwise they will be NULL not 0
	SET @IsHQ = 0;
	SET @IsHQRating = 0;
	
	-- Do we have a headquarters?
	SELECT @HQID = comp_PRHQID,
           @Type = comp_PRType
      FROM Company WITH (NOLOCK)
     WHERE Comp_CompanyID=@CompanyID 
       AND Comp_Deleted IS NULL;

	-- Are we dealing with an HQ?
	IF @Type = 'H' BEGIN
		SET @IsHQ = 1
	END


	IF @IndustryType = 'L' BEGIN

		DECLARE @RatingID int
		DECLARE @CreditWorth varchar(50)
		DECLARE @RatingNumerals varchar(100)
        DECLARE @Prefix varchar(5)


		SET @Prefix  = '';
		IF (@IsHQ = 0) BEGIN
			SET @Prefix  = 'HQ ';	
		END


		SELECT @RatingID = prra_RatingID,
               @CreditWorth = prcw_Name
 		  FROM PRRating WITH (NOLOCK)
               LEFT OUTER JOIN PRCreditWorthRating WITH (NOLOCK) ON prra_CreditWorthID = prcw_CreditWorthRatingId
		 WHERE prra_CompanyID = @HQID
		   AND prra_Current = 'Y'
		   AND prra_Deleted IS NULL;

		IF (@RatingID IS NOT NULL) BEGIN
		
			SET @RatingLine = ''

			IF (@CreditWorth IS NOT NULL) BEGIN
				SET @RatingLine = @RatingLine + @LineBreakChar + @Prefix + 'Credit Worth Estimate:' + @CreditWorth
			END

			SET @RatingNumerals = dbo.ufn_GetAssignedRatingNumeralList(@RatingID, 1);
			IF (ISNULL(@RatingNumerals, '') <> '') BEGIN
				DECLARE @WorkArea varchar(1000)
				SET @WorkArea = dbo.ufn_AddItemsToLine(@Prefix + 'Rating Key Numerals:', @RatingNumerals, @LineBreakChar, ',', 32)
				SET @RatingLine = @RatingLine + @LineBreakChar + dbo.ufn_indentListingBlock(@WorkArea, @LineBreakChar, '  ', 1);
			END
		END

		DECLARE @PayIndicator varchar(40)
		SELECT @PayIndicator = prcpi_PayIndicator
          FROM PRCompanyPayIndicator WITH (NOLOCK)
               INNER JOIN Company WITH (NOLOCK) ON prcpi_CompanyID = comp_CompanyID
         WHERE prcpi_CompanyID = @HQID
           AND prcpi_Current = 'Y'
           AND comp_PRPublishPayIndicator = 'Y';		
		
		IF (@PayIndicator IS NOT NULL) BEGIN
			IF (@RatingLine IS NULL) BEGIN
				SET @RatingLine = ''
			END
		
			SET @RatingLine = @RatingLine + @LineBreakChar + 'Pay Indicator:' + @PayIndicator		
		END

		-- If we have any lumber rating information, then
		-- add our separator at the begining of the rating 
		-- line.
		IF (@RatingLine IS NOT NULL) BEGIN
			SET @RatingLine = @LineBreakChar + '---------------------------------' + @RatingLine
		END

		SET @RetVal = ISNULL(@RatingLine, '')

	END ELSE BEGIN

		SELECT @RatingLine = prra_RatingLine
 		  FROM vPRCurrentRating
		 WHERE prra_CompanyID = @CompanyID;

		IF LEN(@RatingLine) > 0 BEGIN
			SET @IsHQRating = @IsHQ
		END ELSE BEGIN
			IF (@IsHQ = 0) BEGIN

				SELECT @RatingLine = prra_RatingLine
 				  FROM vPRCurrentRating
				 WHERE prra_CompanyID = @HQID;

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

		IF @FormatOptions = 0 BEGIN
			SET @RetVal = @RatingDescription + ',' + ISNULL(@RatingLine, '')
		END ELSE IF @FormatOptions = 1 BEGIN
			SET @RetVal = dbo.ufn_GetListingRatingBlockLeader(@RatingDescription, @RatingLine)
		END ELSE IF @FormatOptions = 2 BEGIN
			SET @RetVal = @RatingDescription + char(9) + ISNULL(@RatingLine, '')
		END
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
	DECLARE @Block varchar(max)

	SET @LineBreakChar = '<br/>'
	SET @LineCount = 0

	SET @Block = dbo.ufn_GetListingDLBlock(@CompanyID, '<br/>')
	IF (@Block IS NOT NULL) BEGIN
		SET @LineCount = @LineCount + ((LEN(@Block) - LEN(REPLACE(@Block, @LineBreakChar, ''))) / LEN(@LineBreakChar)) + 1
	END

	SET @Block = dbo.ufn_GetListingBrandBlock(@CompanyID, '<br/>')
	IF (@Block IS NOT NULL) BEGIN
		SET @LineCount = @LineCount + ((LEN(@Block) - LEN(REPLACE(@Block, @LineBreakChar, ''))) / LEN(@LineBreakChar)) + 1
	END

	SET @Block = dbo.ufn_GetListingUnloadHoursBlock(@CompanyID, '<br/>')
	IF (@Block IS NOT NULL) BEGIN
		SET @LineCount = @LineCount + ((LEN(@Block) - LEN(REPLACE(@Block, @LineBreakChar, ''))) / LEN(@LineBreakChar)) + 1
	END

	RETURN @LineCount

END
Go


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetHQListingDLLineCount]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].ufn_GetHQListingDLLineCount
GO

CREATE FUNCTION dbo.ufn_GetHQListingDLLineCount(@HQID int)
RETURNS int AS  
BEGIN

	DECLARE @LineCount int = 0

	SELECT @LineCount = SUM(dbo.ufn_GetListingDLLineCount(comp_CompanyID))
	  FROM Company WITH (NOLOCK)
	 WHERE comp_PRHQID = @HQID
       AND comp_PRListingStatus IN ('L', 'H');      

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
	DECLARE @Block varchar(max)
	DECLARE @IndustryType varchar(40)
	DECLARE @PublishLogo char(1)

	SET @LineBreakChar = '<br/>'
	SET @LineCount = 0

	SELECT @IndustryType = comp_PRIndustryType,
	       @PublishLogo = comp_PRPublishLogo
      FROM Company WITH (NOLOCK)
     WHERE comp_CompanyID = @CompanyID;
	

	DECLARE @LineLimit int = 0
	IF (@PublishLogo = 'Y') BEGIN
		SET @LineLimit = 4
	END


	SET @Block = dbo.ufn_GetListingParentheticalBlock2(@CompanyID, @LineBreakChar, DEFAULT, DEFAULT, @LineLimit)
	IF (@Block IS NOT NULL) BEGIN
		IF (@LineLimit > 0) BEGIN
			SET @LineLimit = @LineLimit - ((LEN(@Block) - LEN(REPLACE(@Block, @LineBreakChar, ''))) / LEN(@LineBreakChar)) + 1
		END
		SET @LineCount = @LineCount + ((LEN(@Block) - LEN(REPLACE(@Block, @LineBreakChar, ''))) / LEN(@LineBreakChar)) + 1
	END

	SET @Block = dbo.ufn_GetListingAddressBlock2(@CompanyID, @LineBreakChar, DEFAULT, DEFAULT, @LineLimit)
	--SET @Block = dbo.ufn_GetListingAddressBlock2(@CompanyID, @LineBreakChar, @LogoLineSize, @LineSize, @LineLimit)
	IF (@Block IS NOT NULL) BEGIN
		IF (@LineLimit > 0) BEGIN
			SET @LineLimit = @LineLimit - ((LEN(@Block) - LEN(REPLACE(@Block, @LineBreakChar, ''))) / LEN(@LineBreakChar)) + 1
		END
		SET @LineCount = @LineCount + ((LEN(@Block) - LEN(REPLACE(@Block, @LineBreakChar, ''))) / LEN(@LineBreakChar)) + 1
	END

	SET @Block = dbo.ufn_GetListingPhoneBlock2(@CompanyID, @LineBreakChar, DEFAULT, DEFAULT, @LineLimit)
	IF (@Block IS NOT NULL) BEGIN
		SET @LineCount = @LineCount + ((LEN(@Block) - LEN(REPLACE(@Block, @LineBreakChar, ''))) / LEN(@LineBreakChar)) + 1
	END

	SET @Block = dbo.ufn_GetListingInternetBlock(@CompanyID, @LineBreakChar)
	IF (@Block IS NOT NULL) BEGIN
		SET @LineCount = @LineCount + ((LEN(@Block) - LEN(REPLACE(@Block, @LineBreakChar, ''))) / LEN(@LineBreakChar)) + 1
	END

	SET @Block = dbo.ufn_GetListingDLBlock(@CompanyID, @LineBreakChar)
	IF (@Block IS NOT NULL) BEGIN
		SET @LineCount = @LineCount + ((LEN(@Block) - LEN(REPLACE(@Block, @LineBreakChar, ''))) / LEN(@LineBreakChar)) + 1
	END

	SET @Block = dbo.ufn_GetListingBrandBlock(@CompanyID, @LineBreakChar)
	IF (@Block IS NOT NULL) BEGIN
		SET @LineCount = @LineCount + ((LEN(@Block) - LEN(REPLACE(@Block, @LineBreakChar, ''))) / LEN(@LineBreakChar)) + 1
	END

	SET @Block = dbo.ufn_GetListingUnloadHoursBlock(@CompanyID, @LineBreakChar)
	IF (@Block IS NOT NULL) BEGIN
		SET @LineCount = @LineCount + ((LEN(@Block) - LEN(REPLACE(@Block, @LineBreakChar, ''))) / LEN(@LineBreakChar)) + 1
	END

	SET @Block = dbo.ufn_GetListingStockExchangeBlock(@CompanyID, @LineBreakChar)
	IF (@Block IS NOT NULL) BEGIN
		SET @LineCount = @LineCount + ((LEN(@Block) - LEN(REPLACE(@Block, @LineBreakChar, ''))) / LEN(@LineBreakChar)) + 1
	END

	SET @Block = dbo.ufn_GetListingBankBlock2(@CompanyID, @LineBreakChar, 1)
	IF (@Block IS NOT NULL) BEGIN
		SET @LineCount = @LineCount + ((LEN(@Block) - LEN(REPLACE(@Block, @LineBreakChar, ''))) / LEN(@LineBreakChar)) + 1
	END

	SET @Block = dbo.ufn_GetListingChainStoresBlock(@CompanyID, @IndustryType, @LineBreakChar)
	IF (@Block IS NOT NULL) BEGIN
		SET @LineCount = @LineCount + ((LEN(@Block) - LEN(REPLACE(@Block, @LineBreakChar, ''))) / LEN(@LineBreakChar)) + 1
	END

	SET @Block = dbo.ufn_GetListingLicenseBlock(@CompanyID, @LineBreakChar)
	IF (@Block IS NOT NULL) BEGIN
		SET @LineCount = @LineCount + ((LEN(@Block) - LEN(REPLACE(@Block, @LineBreakChar, ''))) / LEN(@LineBreakChar)) + 1
	END

	RETURN @LineCount

END
Go


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetListingTradestyle]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_GetListingTradestyle]
GO

CREATE FUNCTION dbo.ufn_GetListingTradestyle(@comp_PRBookTradestyle varchar(104),
                                             @PublishLogo varchar(1),
											 @LineBreakChar varchar(10),
											 @LineSize int)

RETURNS varchar(150) AS  
BEGIN


	DECLARE @PartA varchar(400), @PartB varchar(400), @PartALineBreak int
	DECLARE @LineLimit int, @CharLimitA int, @CharLimitB int

	IF (CHARINDEX('.', @comp_PRBookTradestyle, LEN(@comp_PRBookTradestyle)) = 0) BEGIN
		SET @comp_PRBookTradestyle = @comp_PRBookTradestyle + '.'
	END

	IF (@LineSize IS NULL) BEGIN
		SET @LineSize = 34
	END

	-- first determine if this company has a logo to display
	IF (@PublishLogo IS NOT NULL) BEGIN
		SET @LineLimit = 4
		SET @CharLimitA = 22
		SET @CharLimitB = 20
	END ELSE BEGIN
        SET @LineLimit = 0
		SET @CharLimitA = 36
		SET @CharLimitB = 33
	END


	IF (LEN(@comp_PRBookTradestyle) <= @CharLimitA)
	BEGIN		
		IF (@PublishLogo IS NOT NULL) BEGIN
			SELECT @comp_PRBookTradestyle = dbo.ufn_ApplyListingLineBreaks(@comp_PRBookTradestyle,@LineBreakChar);
		END ELSE BEGIN
			SELECT @comp_PRBookTradestyle = dbo.ufn_ApplyListingLineBreaks2(@comp_PRBookTradestyle,@LineBreakChar, @CharLimitA)
		END

	END ELSE BEGIN
		-- first get the line 1 content at character limit
		SET @comp_PRBookTradestyle = dbo.ufn_ApplyListingLineBreaks2(@comp_PRBookTradestyle,@LineBreakChar, @CharLimitA)

		-- Now find the first line break
		SET @PartALineBreak = CHARINDEX(@LineBreakChar, @comp_PRBookTradestyle)

		-- PartA is the first line; everything before the line break
		SET @PartA = SUBSTRING(@comp_PRBookTradestyle, 1, @PartALineBreak-1)

		-- PartB is everything that is left; this formats to a max of 20 characters/line
		SET @PartB = SUBSTRING(@comp_PRBookTradestyle, @PartALineBreak+LEN(@LineBreakChar), (LEN(@comp_PRBookTradestyle)-@PartALineBreak+LEN(@LineBreakChar))+1)

		-- remove the line break chars because they have to be set to 20 not 22
		SET @PartB = REPLACE(@PartB, @LineBreakChar, ' ')
		SELECT @comp_PRBookTradestyle = @PartA+@LineBreakChar + dbo.ufn_ApplyListingLineBreaksForLogo(@PartB, @LineBreakChar, @CharLimitB, @LineSize, @LineLimit)
	END

	RETURN @comp_PRBookTradestyle
END
Go




if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetTradingMember]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_GetTradingMember]
GO

CREATE FUNCTION dbo.ufn_GetTradingMember(@MemberSince varchar(10),
                                         @comp_PRIndustryType varchar(40))

RETURNS varchar(50) AS  
BEGIN

	DECLARE @TradingMember varchar(50)

    IF (@MemberSince is not null) BEGIN
        IF (@comp_PRIndustryType = 'P') BEGIN    
            SET @TradingMember = 'TRADING MEMBER since ' + @MemberSince
        END ELSE IF (@comp_PRIndustryType = 'T') BEGIN
            SET @TradingMember = 'TRANSPORTATION MEMBER-' + @MemberSince
        END
    END

	RETURN @TradingMember
END
Go




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
CREATE FUNCTION [dbo].[ufn_GetListing] ( 
    @CompanyId int,
    @FormattingStyle tinyint = 0, -- 0: <br/> 1: CHR(10) 2: CHR(10 & 13) 3: Tab
    @ShowPaidLines bit = 0,
    @IncludeHeader bit = 1,
    @comp_PRBookTradestyle varchar(420),
    @comp_PRListingStatus varchar(40),
    @comp_PRIndustryType varchar(40),
    @prcp_VolumeDesc varchar(50),
    @prra_RatingLine varchar(100),
    @ParentheticalBlock varchar(1000),
    @AddressBlock varchar(1000),
    @PhoneBlock varchar(1000),
    @InternetBlock varchar(1000),
    @DLBlock varchar(max),
    @BrandBlock varchar(1000),
    @UnloadHoursBlock varchar(1000),
    @ClassificationBlock varchar(1000),
    @CommodityBlock varchar(1000),
    @StockExchangeBlock varchar(500),
    @RatingBlock varchar(500),
    @BankBlock varchar(500),
    @LicenseBlock varchar(500),
    @MemberSince varchar(10)
)
RETURNS varchar(max)
AS
BEGIN
    DECLARE @RetValue varchar(max)
    DECLARE @LineBreakChar varchar(50)
    DECLARE @Space varchar(10) 
    DECLARE @Indent2 varchar(40), @Indent3 varchar(40), @PaidIndent2 varchar(40)  
    IF (@FormattingStyle = 0) BEGIN
        SET @Space = '&nbsp;'
        SET @LineBreakChar = '<br/>'
    END ELSE IF (@FormattingStyle = 1) BEGIN
        SET @Space = ' '
        SET @LineBreakChar = CHAR(10)
    END ELSE IF (@FormattingStyle = 2) BEGIN
        SET @Space = ' '
        SET @LineBreakChar = CHAR(13)+CHAR(10)
    END ELSE IF (@FormattingStyle = 3) BEGIN
        SET @Space = ' ' 
        SET @LineBreakChar = CHAR(9)
	END ELSE IF (@FormattingStyle = 4) BEGIN
        SET @Space = ' ' 
        SET @LineBreakChar = CHAR(9)
    END
	--
	-- We are making an assumptiont that if we're 
    -- using TABS as the delimiter, then this is for
	-- the book images.
	IF (@FormattingStyle = 3) BEGIN
		SET @Indent2 = ''
		SET @Indent3 = ''
		SET @PaidIndent2 = ''
	END ELSE BEGIN
		SET @Indent2 = @Space + @Space
		SET @Indent3 = @Space + @Space + @Space 
		IF (@ShowPaidLines = 1) BEGIN
			SET @PaidIndent2 = '-' + @Space
		END ELSE BEGIN
			SET @PaidIndent2 = @Indent2
		END
	END
	SET @RetValue = ''
	IF (@IncludeHeader = 1) BEGIN
		SET @RetValue =  @Space + @Space + 'BB #' + Convert(varchar(15), @CompanyId)
		SET @RetValue = @RetValue +  
			COALESCE(@LineBreakChar + dbo.ufn_indentListingBlock(@comp_PRBookTradestyle, @LineBreakChar, @Indent3, 1), '')    
	END
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
	-- Brand Block
    SET @RetValue = @RetValue + 
        COALESCE(@LineBreakChar + dbo.ufn_indentListingBlock(@BrandBlock, @LineBreakChar, @PaidIndent2, 0), '') 
	-- Unload Hours Block
    IF (@comp_PRIndustryType = 'P')
    begin    
        SET @RetValue = @RetValue + 
            COALESCE(@LineBreakChar + dbo.ufn_indentListingBlock(@UnloadHoursBlock, @LineBreakChar, @PaidIndent2, 0), '') 
    end
	-- Stock Exchange Block
    IF (@comp_PRIndustryType in ('P', 'T', 'L'))
    begin    
        SET @RetValue = @RetValue + 
            COALESCE(@LineBreakChar + dbo.ufn_indentListingBlock(@StockExchangeBlock, @LineBreakChar, @Indent2, 0), '') 
	END
	-- Bank Block
    SET @RetValue = @RetValue + 
        COALESCE(@LineBreakChar + dbo.ufn_indentListingBlock(@BankBlock, @LineBreakChar, @Indent2, 0), '') 
	-- Chain Store Block
    IF (@comp_PRIndustryType = 'P')
    begin    
	    DECLARE @ChainStoresBlock varchar(100)
		SET @ChainStoresBlock = dbo.ufn_GetListingChainStoresBlock(@CompanyId, @comp_PRIndustryType, @LineBreakChar)
        SET @RetValue = @RetValue + 
            COALESCE(@LineBreakChar + dbo.ufn_indentListingBlock(@ChainStoresBlock, @LineBreakChar, @Indent2, 0), '') 
    end
    IF (@comp_PRIndustryType in ('P', 'T'))
    begin    
        SET @RetValue = @RetValue + 
            COALESCE(@LineBreakChar + dbo.ufn_indentListingBlock(@LicenseBlock, @LineBreakChar, @Indent2, 0), '') 
    end
    IF (@MemberSince is not null)
    begin
            SET @RetValue = @RetValue +
                COALESCE(@LineBreakChar + dbo.ufn_indentListingBlock(@Space+ dbo.ufn_GetTradingMember(@MemberSince, @comp_PRIndustryType), @LineBreakChar, @Indent2, 0), '') 
    end
	--
	-- We are making an assumption that if we're 
    -- using TABS as the delimiter, then this is for
	-- the book images.
	IF (@FormattingStyle <> 3) BEGIN
		DECLARE @ClassVolCommBlock varchar(3000)
		SET @ClassVolCommBlock = dbo.ufn_GetListingClassVolCommBlock(@CompanyId, @FormattingStyle)
		SET @RetValue = @RetValue + COALESCE(@LineBreakChar + @ClassVolCommBlock, '')
	END
    IF (@comp_PRIndustryType in ('P', 'T'))
    begin    
        -- Get the rating line
        SET @RetValue = @RetValue + 
            COALESCE(@LineBreakChar + dbo.ufn_indentListingBlock(@RatingBlock, @LineBreakChar, @Indent2, 0), '') 
    end
    IF (@comp_PRIndustryType in ('L'))
    begin    
        -- Get the rating line
        SET @RetValue = @RetValue + @RatingBlock
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
    @FormattingStyle tinyint = 0, -- 0: <br/> 1: CHR(10) 2: CHR(10 & 13)
    @ShowPaidLines bit = 0
)
RETURNS varchar(max)
AS
BEGIN
	RETURN dbo.ufn_GetListingFromCompany2(@CompanyId, @FormattingStyle, @ShowPaidLines, 1);
END
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetListingFromCompany2]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_GetListingFromCompany2]
GO
CREATE FUNCTION [dbo].[ufn_GetListingFromCompany2] ( 
    @CompanyId int,
    @FormattingStyle tinyint = 0, -- 0: <br/> 1: CHR(10) 2: CHR(10 & 13) 3: Tab
    @ShowPaidLines bit = 0,
    @IncludeHeader bit = 1
)
RETURNS varchar(max)
AS
BEGIN
    DECLARE @RetValue varchar(max)
	DECLARE @Logo varchar(50)
    DECLARE @comp_PRBookTradestyle varchar(420)
    DECLARE @comp_PRListingStatus varchar(40)
    DECLARE @comp_PRIndustryType varchar(40)
    DECLARE @prcp_VolumeDesc varchar(50)
    DECLARE @prra_RatingLine varchar(100)
    DECLARE @ParentheticalBlock varchar(1000)
    DECLARE @AddressBlock varchar(1000)
    DECLARE @PhoneBlock varchar(1000)
    DECLARE @InternetBlock varchar(1000)
    DECLARE @DLBlock varchar(max)
    DECLARE @BrandBlock varchar(1000)
    DECLARE @UnloadHoursBlock varchar(1000)
    DECLARE @ClassificationBlock varchar(5000)
    DECLARE @CommodityBlock varchar(5000)
    DECLARE @StockExchangeBlock varchar(500)
    DECLARE @RatingBlock varchar(500)
    DECLARE @BankBlock varchar(500)
    DECLARE @LicenseBlock varchar(500)
    DECLARE @MemberSince varchar(10)
    DECLARE @LineBreakChar varchar(50)
    IF (@FormattingStyle = 0) BEGIN
        SET @LineBreakChar = '<br/>'
    END ELSE IF (@FormattingStyle = 1) BEGIN
        SET @LineBreakChar = CHAR(10)
    END ELSE IF (@FormattingStyle = 2) BEGIN
        SET @LineBreakChar = CHAR(13)+CHAR(10)
    END ELSE IF (@FormattingStyle = 3) BEGIN
        SET @LineBreakChar = CHAR(9)
    END ELSE IF (@FormattingStyle = 4) BEGIN
        SET @LineBreakChar = CHAR(9)

    END
	-- LineLimit represents the number of lines taken up by a logo and therefore need special formatting
	Declare @LineLimit int, @LineCount int
	Declare @LogoLineSize int; SET @LogoLineSize = 22
	Declare @LineSize int; SET @LineSize = 34
	DECLARE @PartA varchar(400), @PartB varchar(400), @PartALineBreak int
	SELECT @comp_PRBookTradestyle = comp_PRBookTradestyle,
           @Logo = comp_PRPublishLogo
	  FROM Company WITH (NOLOCK)
	 WHERE comp_companyid = @CompanyId;
	-- first determine if this company has a logo to display
	IF (@Logo IS NOT NULL) BEGIN
		-- LineLimit starts at 5 when a logo is present; however line 1 is the BBId so start at 4
		set @LineLimit = 4
		SET @comp_PRBookTradestyle = dbo.ufn_GetListingTradestyle(@comp_PRBookTradestyle, @Logo, @LineBreakChar, @LineSize)
		SET @LineLimit = @LineLimit - (dbo.ufn_CountOccurrences(@LineBreakChar, @comp_PRBookTradestyle)+1)
		SELECT @ParentheticalBlock = dbo.ufn_GetListingParentheticalBlock2(@CompanyId, @LineBreakChar, 
												@LogoLineSize, @LineSize, @LineLimit)
		If (@ParentheticalBlock is not null and @ParentheticalBlock != '')
			SET @LineLimit = @LineLimit - (dbo.ufn_CountOccurrences(@LineBreakChar, @ParentheticalBlock)+1)
		SELECT @AddressBlock = dbo.ufn_GetListingAddressBlock2(@CompanyId, @LineBreakChar, @LogoLineSize, @LineSize, @LineLimit)
		If (@AddressBlock is not null and @AddressBlock != '')
			SET @LineLimit = @LineLimit - (dbo.ufn_CountOccurrences(@LineBreakChar, @AddressBlock)+1)
		SELECT @PhoneBlock = dbo.ufn_GetListingPhoneBlock2(@CompanyId, @LineBreakChar, @LogoLineSize, @LineSize, @LineLimit)
		If (@PhoneBlock is not null and @PhoneBlock != '')
			SET @LineLimit = @LineLimit - (dbo.ufn_CountOccurrences(@LineBreakChar, @PhoneBlock)+1)
		SELECT @comp_PRIndustryType = comp_PRIndustryType,
			   @prcp_VolumeDesc = CaptVol.capt_US,
			   @InternetBlock = dbo.ufn_GetListingInternetBlock(@CompanyId, @LineBreakChar),
			   @DLBlock = dbo.ufn_GetListingDLBlock(@CompanyId, @LineBreakChar),
			   @BankBlock = dbo.ufn_GetListingBankBlock2(@CompanyId, @LineBreakChar, 1),
			   @BrandBlock = dbo.ufn_GetListingBrandBlock(@CompanyId, @LineBreakChar),
			   @UnloadHoursBlock = dbo.ufn_GetListingUnloadHoursBlock(@CompanyId, @LineBreakChar),
			   @StockExchangeBlock = dbo.ufn_GetListingStockExchangeBlock(@CompanyId, @LineBreakChar),
			   @RatingBlock = dbo.ufn_GetListingRatingBlock(@CompanyId, comp_PRIndustryType, 1, @LineBreakChar),
			   @LicenseBlock = dbo.ufn_GetListingLicenseBlock(@CompanyId, @LineBreakChar),
			   @ClassificationBlock = dbo.ufn_GetListingClassificationBlock(ABS(@CompanyId), comp_PRIndustryType, @LineBreakChar),
			   @CommodityBlock = dbo.ufn_GetListingCommodityBlock(@CompanyId, comp_PRIndustryType, @LineBreakChar),
			   @MemberSince = case 
					when comp_PRTMFMAward = 'Y' then DATEPART(YEAR, comp_PRTMFMAwardDate)
					else NULL
			   end
		FROM Company WITH (NOLOCK)
		     LEFT OUTER JOIN PRCompanyProfile WITH (NOLOCK) ON comp_CompanyId = ABS(prcp_CompanyId)
		     LEFT OUTER JOIN Custom_Captions CaptVol WITH (NOLOCK) ON capt_code = prcp_Volume AND capt_family = 'prcp_Volume'
		WHERE comp_companyid = ABS(@CompanyId)
	END ELSE BEGIN
		SET @LineLimit = 0
		SET @comp_PRBookTradestyle = dbo.ufn_GetListingTradestyle(@comp_PRBookTradestyle, @Logo, @LineBreakChar, @LineSize)
		SELECT @comp_PRIndustryType = comp_PRIndustryType,
			   @prcp_VolumeDesc = CaptVol.capt_US,
			   @ParentheticalBlock = dbo.ufn_GetListingParentheticalBlock(@CompanyId, @LineBreakChar),
			   @AddressBlock = dbo.ufn_GetListingAddressBlock(@CompanyId, @LineBreakChar),
			   @PhoneBlock = dbo.ufn_GetListingPhoneBlock(@CompanyId, @LineBreakChar),
			   @InternetBlock = dbo.ufn_GetListingInternetBlock(@CompanyId, @LineBreakChar),
			   @DLBlock = dbo.ufn_GetListingDLBlock(@CompanyId, @LineBreakChar),
			   @BankBlock = dbo.ufn_GetListingBankBlock2(@CompanyId, @LineBreakChar,1),
			   @BrandBlock = dbo.ufn_GetListingBrandBlock(@CompanyId, @LineBreakChar),
			   @UnloadHoursBlock = dbo.ufn_GetListingUnloadHoursBlock(@CompanyId, @LineBreakChar),
			   @StockExchangeBlock = dbo.ufn_GetListingStockExchangeBlock(@CompanyId, @LineBreakChar),
			   @RatingBlock = dbo.ufn_GetListingRatingBlock(@CompanyId, comp_PRIndustryType, 1, @LineBreakChar),
			   @LicenseBlock = dbo.ufn_GetListingLicenseBlock(@CompanyId, @LineBreakChar),
			   @ClassificationBlock = dbo.ufn_GetListingClassificationBlock(ABS(@CompanyId), comp_PRIndustryType, @LineBreakChar),
			   @CommodityBlock = dbo.ufn_GetListingCommodityBlock(@CompanyId, comp_PRIndustryType, @LineBreakChar),
			   @MemberSince = case 
					when comp_PRTMFMAward = 'Y' then DATEPART(YEAR, comp_PRTMFMAwardDate)
					else NULL
			   end
		FROM Company WITH (NOLOCK)
		     LEFT OUTER JOIN PRCompanyProfile WITH (NOLOCK) ON comp_CompanyId = ABS(prcp_CompanyId)
		     LEFT OUTER JOIN Custom_Captions CaptVol WITH (NOLOCK) ON capt_code = prcp_Volume AND capt_family = 'prcp_Volume'
	   WHERE comp_companyid = ABS(@CompanyId)
	END
	SET @RetValue = dbo.ufn_GetListing(@CompanyId,
										@FormattingStyle,
                                        @ShowPaidLines,
                                        @IncludeHeader,
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




if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetBookImageListingBody]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_GetBookImageListingBody]
GO

CREATE FUNCTION dbo.ufn_GetBookImageListingBody ( 
    @CompanyID int
)
RETURNS varchar(8000)
AS
BEGIN

    DECLARE @RetValue varchar(8000)
    
	DECLARE @Logo varchar(50)
    DECLARE @comp_PRBookTradestyle varchar(120)
    DECLARE @comp_PRListingStatus varchar(40)
    DECLARE @comp_PRIndustryType varchar(40)
    DECLARE @ParentheticalBlock varchar(1000)
    DECLARE @AddressBlock varchar(1000)
    DECLARE @PhoneBlock varchar(1000)
    DECLARE @InternetBlock varchar(1000)
    DECLARE @DLBlock varchar(max)
    DECLARE @BrandBlock varchar(1000)
    DECLARE @UnloadHoursBlock varchar(1000)
    DECLARE @StockExchangeBlock varchar(500)
    DECLARE @BankBlock varchar(500)
    DECLARE @LicenseBlock varchar(500)

    DECLARE @LineBreakChar varchar(50)
    SET @LineBreakChar = CHAR(9)
	
	-- LineLimit represents the number of lines taken up by a logo and therefore need special formatting
	Declare @LineLimit int, @LineCount int
	Declare @LogoLineSize int; SET @LogoLineSize = 22
	Declare @LineSize int; SET @LineSize = 34

	DECLARE @PartA varchar(400), @PartB varchar(400), @PartALineBreak int

	SELECT @comp_PRBookTradestyle = comp_PRBookTradestyle,
           @Logo = comp_PRPublishLogo
	  FROM Company WITH (NOLOCK)
	 WHERE comp_companyid = @CompanyId;

	--SELECT 'Logo' + ISNULL(@Logo, '');

	-- first determine if this company has a logo to display
	IF (@Logo IS NOT NULL) BEGIN

		-- LineLimit starts at 5 when a logo is present; however line 1 is the BBId so start at 4
		SET @LineLimit = 4
		SET @comp_PRBookTradestyle = dbo.ufn_GetListingTradestyle(@comp_PRBookTradestyle, @Logo, @LineBreakChar, @LineSize)
		SET @LineLimit = @LineLimit - (dbo.ufn_CountOccurrences(@LineBreakChar, @comp_PRBookTradestyle)+1)

		SELECT @ParentheticalBlock = dbo.ufn_GetListingParentheticalBlock2(@CompanyId, @LineBreakChar, 
												@LogoLineSize, @LineSize, @LineLimit)
		If (@ParentheticalBlock is not null and @ParentheticalBlock != '')
			SET @LineLimit = @LineLimit - (dbo.ufn_CountOccurrences(@LineBreakChar, @ParentheticalBlock)+1)

		SELECT @AddressBlock = dbo.ufn_GetListingAddressBlock2(@CompanyId, @LineBreakChar, @LogoLineSize, @LineSize, @LineLimit)
		If (@AddressBlock is not null and @AddressBlock != '')
			SET @LineLimit = @LineLimit - (dbo.ufn_CountOccurrences(@LineBreakChar, @AddressBlock)+1)

		SELECT @PhoneBlock = dbo.ufn_GetListingPhoneBlock2(@CompanyId, @LineBreakChar, @LogoLineSize, @LineSize, @LineLimit)
		If (@PhoneBlock is not null and @PhoneBlock != '')
			SET @LineLimit = @LineLimit - (dbo.ufn_CountOccurrences(@LineBreakChar, @PhoneBlock)+1)

		SELECT @comp_PRIndustryType = comp_PRIndustryType,
			   @InternetBlock = dbo.ufn_GetListingInternetBlock(@CompanyId, @LineBreakChar),
			   @DLBlock = dbo.ufn_GetListingDLBlock(@CompanyId, @LineBreakChar),
			   @BankBlock = dbo.ufn_GetListingBankBlock2(@CompanyId, @LineBreakChar,1),
			   @BrandBlock = dbo.ufn_GetListingBrandBlock(@CompanyId, @LineBreakChar),
			   @UnloadHoursBlock = dbo.ufn_GetListingUnloadHoursBlock(@CompanyId, @LineBreakChar),
			   @StockExchangeBlock = dbo.ufn_GetListingStockExchangeBlock(@CompanyId, @LineBreakChar),
			   @LicenseBlock = dbo.ufn_GetListingLicenseBlock(@CompanyId, @LineBreakChar)
 		  FROM Company WITH (NOLOCK)
		 WHERE comp_companyid = @CompanyId


	END ELSE BEGIN
		SET @LineLimit = 0
		SET @comp_PRBookTradestyle = dbo.ufn_GetListingTradestyle(@comp_PRBookTradestyle, @Logo, @LineBreakChar, @LineSize)
		
		SELECT @comp_PRIndustryType = comp_PRIndustryType,
			   @ParentheticalBlock = dbo.ufn_GetListingParentheticalBlock(@CompanyId, @LineBreakChar),
			   @AddressBlock = dbo.ufn_GetListingAddressBlock(@CompanyId, @LineBreakChar),
			   @PhoneBlock = dbo.ufn_GetListingPhoneBlock(@CompanyId, @LineBreakChar),
			   @InternetBlock = dbo.ufn_GetListingInternetBlock(@CompanyId, @LineBreakChar),
			   @DLBlock = dbo.ufn_GetListingDLBlock(@CompanyId, @LineBreakChar),
			   @BankBlock = dbo.ufn_GetListingBankBlock2(@CompanyId, @LineBreakChar,1),
			   @BrandBlock = dbo.ufn_GetListingBrandBlock(@CompanyId, @LineBreakChar),
			   @UnloadHoursBlock = dbo.ufn_GetListingUnloadHoursBlock(@CompanyId, @LineBreakChar),
			   @StockExchangeBlock = dbo.ufn_GetListingStockExchangeBlock(@CompanyId, @LineBreakChar),
			   @LicenseBlock = dbo.ufn_GetListingLicenseBlock(@CompanyId, @LineBreakChar)
		FROM Company WITH (NOLOCK)
		WHERE comp_companyid = @CompanyId
	END

	SET @RetValue = dbo.ufn_GetListing(@CompanyId,
										3,
                                        0,
                                        0,
                                        @comp_PRBookTradestyle,
                                        @comp_PRListingStatus,
                                        @comp_PRIndustryType,
                                        null,
                                        null,
                                        @ParentheticalBlock,
                                        @AddressBlock,
                                        @PhoneBlock,
                                        @InternetBlock,
                                        @DLBlock,
                                        @BrandBlock,
                                        @UnloadHoursBlock,
                                        null,
                                        null,
                                        @StockExchangeBlock,
                                        null,
                                        @BankBlock,
                                        @LicenseBlock,
                                        null);

	RETURN @RetValue
END
Go


/*
 * Builds a block of text adding one item at a time to the
 * text checking lengths first.  This was the entire item
 * will be kept together either on the current line or the
 * next line.
 */
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_AddItemsToLine]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_AddItemsToLine]
GO
CREATE FUNCTION dbo.ufn_AddItemsToLine ( 
    @CurrentText varchar(8000),
    @Items varchar(8000),
    @LineBreakChar varchar(10),
    @DelimChar varchar(10),
	@LineSize int
)
RETURNS varchar(8000)
AS

BEGIN
	DECLARE @RetVal varchar(8000)
	DECLARE @TempBreak varchar(8000)	
	DECLARE @CurrentItem varchar(8000)
    DECLARE @CurrentLine varchar(8000)
    DECLARE @LineCount int, @LineIndex int

	DECLARE @tblItems table (
		ndx int primary key,
		ItemText varchar(8000)
	)

	INSERT INTO @tblItems (ndx, ItemText)
	SELECT idx, value 
      FROM dbo.Tokenize(@Items, @DelimChar)
     WHERE value IS NOT NULL;

	SET @LineCount = @@ROWCOUNT;
	SET @LineIndex = 0
	SET @CurrentLine = @CurrentText;
    SET @RetVal = ''

	WHILE (@LineIndex < @LineCount) BEGIN
		SELECT @CurrentItem = ItemText
          FROM @tblItems
         WHERE ndx = @LineIndex;

		SET @TempBreak = ''
		IF (LEN(@CurrentLine) + LEN(@CurrentItem)) > @LineSize BEGIN
			IF (LEN(@RetVal) > 0) BEGIN
				SET @RetVal = @RetVal + @LineBreakChar
			END
			SET @RetVal = @RetVal + @CurrentLine
			SET @CurrentLine = ''
		END

		SET @CurrentLine = @CurrentLine + @CurrentItem
		SET @LineIndex = @LineIndex + 1
	END
	
	IF (LEN(@RetVal) > 0) BEGIN
		SET @RetVal = @RetVal + @LineBreakChar
	END
	SET @RetVal = @RetVal + @CurrentLine


	RETURN @RetVal
END
Go


/* 
    This function reads the listing from the PRListing cache
    table.  
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetListingCache]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_GetListingCache]
GO
CREATE FUNCTION dbo.ufn_GetListingCache ( 
    @CompanyId int,
    @FormattingStyle tinyint = 0 -- 0: <br/> 1: CHR(10) 2: CHR(10 & 13)
)
RETURNS varchar(max)
AS
BEGIN

	DECLARE @Listing varchar(max)

	SELECT @Listing = prlst_Listing
	  FROM PRListing
	 WHERE prlst_CompanyID = @CompanyId

	
	IF (@FormattingStyle <> 0) BEGIN
	
		DECLARE @LineBreakChar varchar(5)
		IF (@FormattingStyle = 1) BEGIN
			SET @LineBreakChar = CHAR(10)
		END ELSE IF (@FormattingStyle = 2) BEGIN
			SET @LineBreakChar = CHAR(13)+CHAR(10)
		END ELSE IF (@FormattingStyle = 3) BEGIN
			SET @LineBreakChar = CHAR(9)
		END ELSE IF (@FormattingStyle = 4) BEGIN
			SET @LineBreakChar = CHAR(9)
		END        
        
        SET @Listing = REPLACE(@Listing, '<br/>', @LineBreakChar)
        SET @Listing = REPLACE(@Listing, '&nbsp;', ' ')
	END
	
	
	IF (@Listing IS NULL) BEGIN
		SET @Listing = dbo.ufn_GetListingFromCompany(@CompanyId, @FormattingStyle, 0);
	END
	
	RETURN @Listing;
	
END
GO

