/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2024

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Produce Report Company  is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Produce Report Company .
  Use and distribution limited soFlely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 

***********************************************************************
***********************************************************************/

	-- this function counts the number of occurrences of one string in another
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_CountOccurrences]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    drop function [dbo].[ufn_CountOccurrences]
GO
CREATE FUNCTION [dbo].[ufn_CountOccurrences] ( 
    @SearchValue varchar(100),
    @Content varchar (max)
)
RETURNS int
AS
BEGIN
    IF @Content IS NULL RETURN 0

    RETURN (LEN(@Content) - LEN(REPLACE(@Content, @SearchValue, ''))) /
            LEN(@SearchValue)
END
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_getCurrentRatingLine]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    drop function [dbo].[ufn_getCurrentRatingLine]
GO
CREATE FUNCTION [dbo].[ufn_getCurrentRatingLine] ( 
    @CompanyId int
)
RETURNS varchar(50)
AS
BEGIN
    DECLARE @RatingLine varchar(50)
    SELECT @RatingLine = COALESCE(prcw_Name+' ','')
                        +COALESCE(prin_Name,'')
                        +COALESCE(prra_AssignedRatingNumerals,'')
                        +COALESCE(' '+prpy_Name,'') 
    FROM ( 
        SELECT prcw_Name, prin_Name, prpy_Name, 
                prra_AssignedRatingNumerals = dbo.ufn_GetAssignedRatingNumeralList(prra_RatingId, 0) 
        FROM PRRating prra WITH (NOLOCK)
        LEFT OUTER JOIN PRCreditWorthRating ON prra_CreditWorthId = prcw_CreditWorthRatingId 
        LEFT OUTER JOIN PRIntegrityRating ON prra_IntegrityId = prin_IntegrityRatingId 
        LEFT OUTER JOIN PRPayRating ON prra_PayRatingId = prpy_PayRatingId 
        WHERE prra_Current = 'Y' and prra_CompanyId = @CompanyId
    ) ATable            
    RETURN @RatingLine
END
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_getPreviousRatingLine]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    drop function [dbo].[ufn_getPreviousRatingLine]
GO
CREATE FUNCTION [dbo].[ufn_getPreviousRatingLine] ( 
    @CompanyId int
)
RETURNS varchar(50)
AS
BEGIN
    DECLARE @RatingLine varchar(50)
    SELECT @RatingLine = COALESCE(prcw_Name+' ','')
                        +COALESCE(prin_Name,'')
                        +COALESCE(prra_AssignedRatingNumerals,'')
                        +COALESCE(' '+prpy_Name,'') 
    FROM ( 
        SELECT TOP 1 prcw_Name, prin_Name, prpy_Name, 
                prra_AssignedRatingNumerals = dbo.ufn_GetAssignedRatingNumeralList(prra_RatingId, 0) 
        FROM PRRating prra WITH (NOLOCK)
        LEFT OUTER JOIN PRCreditWorthRating ON prra_CreditWorthId = prcw_CreditWorthRatingId 
        LEFT OUTER JOIN PRIntegrityRating ON prra_IntegrityId = prin_IntegrityRatingId 
        LEFT OUTER JOIN PRPayRating ON prra_PayRatingId = prpy_PayRatingId 
        WHERE prra_Current IS NULL AND prra_Rated='Y' and prra_CompanyId = @CompanyId
		ORDER BY prra_Date DESC
    ) ATable            
    RETURN @RatingLine
END
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_getCurrentBBScore]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    drop function [dbo].[ufn_getCurrentBBScore]
GO
CREATE FUNCTION [dbo].[ufn_getCurrentBBScore] ( 
    @CompanyId int
)
RETURNS varchar(50)
AS
BEGIN
    DECLARE @Result varchar(50)
    select @Result = prbs_BBScore
    FROM PRBBScore WITH (NOLOCK)
    WHERE prbs_Current = 'Y' 
		and prbs_PRPublish = 'Y'
		and prbs_CompanyId = @CompanyId
        
    RETURN @Result
END
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetCommodityPublishableName]') 
                    and xtype in (N'FN', N'IF', N'TF')) 
    drop function [dbo].[ufn_GetCommodityPublishableName]
GO
CREATE FUNCTION dbo.ufn_GetCommodityPublishableName ( 
    @commodityid int
)
RETURNS NVARCHAR(1024)
AS
BEGIN
    DECLARE @RetValue nvarchar(1024)
    DECLARE @CommLevel int, @ParentId int, @ParentLevel int, @Name varchar(100) 
    Declare @Level1ParentId int, @Level1ParentLevel int, @Level1ParentName varchar(100)
    Declare @Level2ParentId int, @Level2ParentLevel int, @Level2ParentName varchar(100)
    -- Parent Levels are going to be as follows (when present)
    --     __ Level 2 Parent 
    --       |
    --       |__ Level 1 Parent
    --         |
    --         |__ Commodity
    SELECT @CommLevel = prcm_Level, @ParentId = prcm_ParentId, @Name = rtrim(prcm_Name)
      FROM PRCommodity WITH (NOLOCK) 
     WHERE prcm_CommodityId = @commodityid

    IF (@CommLevel < 4)
        SET @RetValue = @Name
    ELSE BEGIN
        -- determine info about the parent
        SELECT @Level1ParentId = @ParentId, @Level1ParentLevel = prcm_Level, 
                @Level1ParentName = rtrim(prcm_Name), @Level2ParentId = prcm_ParentId
          FROM PRCommodity WITH (NOLOCK) 
         WHERE prcm_CommodityId = @ParentId;
        IF (@Level1ParentLevel > 3) Begin
            SELECT @Level2ParentLevel = prcm_Level, @Level2ParentName = rtrim(prcm_Name) 
              FROM PRCommodity WITH (NOLOCK) 
             WHERE prcm_CommodityId = @Level2ParentId;
        End
        -- are we dealing with 2 levels of parents
        IF (@Level2ParentName IS NOT NULL) BEGIN
            IF (@Level2ParentName != @Level1ParentName AND @Level1ParentName != @Name AND @Level2ParentName != @Name)
                SET @RetValue = @Name + ' ' + @Level1ParentName + ' ' + @Level2ParentName
            ELSE IF (@Level2ParentName != @Level1ParentName AND @Level1ParentName != @Name )-- Level 2 and Name are the name
                SET @RetValue = @Level1ParentName + ' ' + @Level2ParentName
            ELSE IF (@Level2ParentName != @Level1ParentName AND @Level2ParentName != @Name) -- Level 1 and Name are the same
                SET @RetValue = @Name + ' ' + @Level2ParentName
            ELSE IF (@Level1ParentName != @Name AND @Level2ParentName != @Name) -- Level 1 and Level 2 are the same
                SET @RetValue = @Name + ' ' + @Level2ParentName
        END ELSE BEGIN
            IF (@Level1ParentName != @Name )
                SET @RetValue = @Name + ' ' + @Level1ParentName 
            ELSE 
                SET @RetValue = @Name
        END
    END
    RETURN @RetValue
END
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetCommodityTreeBranch]') 
            and OBJECTPROPERTY(id, N'IsTableFunction') = 1)
drop Function [dbo].[ufn_GetCommodityTreeBranch]
GO

CREATE FUNCTION dbo.ufn_GetCommodityTreeBranch
(
    @prcm_CommodityId int
)
RETURNS @tblCommodities TABLE (
    prcm_CommodityId int,
    prcm_ParentId int,
    prcm_Level int,
    prcm_Name varchar(100),
    prcm_Alias varchar(100),
    prcm_CommodityCode varchar(100),
    prcm_PathNames varchar(300),
    prcm_PathCodes varchar(300)
)
as
BEGIN

    Declare @tblInternal Table (
        cntr smallint identity,
        prcm_CommodityId int,
        prcm_ParentId int,
        prcm_Level int,
        prcm_Name varchar(100),
        prcm_Alias varchar(100),
        prcm_CommodityCode varchar(100),
        prcm_PathNames varchar(300),
        prcm_PathCodes varchar(300)
    )
    Declare @CommodityId int
    Declare @cntr int, @recs smallint
    Declare @ParentId int
    SET @CommodityId = 1;

    if (@prcm_CommodityId is null)
    begin
        Insert into @tblInternal
            SELECT prcm_CommodityId, prcm_ParentId, prcm_Level, prcm_Name,
                prcm_CommodityCode, prcm_Alias, prcm_PathNames, prcm_PathCodes 
            FROM PRCommodity WITH (NOLOCK) 
            WHERE prcm_ParentId = 0
            order by prcm_Name

    end
    else
    begin
        
        INSERT INTO @tblCommodities 
            select prcm_CommodityId, prcm_ParentId, prcm_Level, prcm_Name, 
                prcm_Alias, prcm_CommodityCode, prcm_PathNames, prcm_PathCodes 
            from PRCommodity WITH (NOLOCK) 
            where prcm_CommodityId = @prcm_CommodityId
    
        Insert into @tblInternal
            SELECT prcm_CommodityId, prcm_ParentId, prcm_Level, prcm_Name, 
                prcm_Alias, prcm_CommodityCode, prcm_PathNames, prcm_PathCodes 
            FROM PRCommodity WITH (NOLOCK) 
            WHERE prcm_ParentId =  @prcm_CommodityId
            order by prcm_Name
        
    End

    SELECT @recs = count(1) from @tblInternal
    if (@recs > 0)
    begin 
        SET @cntr = 1
        SET @CommodityId = null
        SELECT @CommodityId = prcm_CommodityId, @ParentId = prcm_ParentId 
            FROM @tblInternal 
            where cntr = @cntr
        while (@CommodityId is not null)
        Begin
            INSERT INTO @tblCommodities select * from dbo.ufn_GetCommodityTreeBranch(@CommodityId)

            SET @cntr = @cntr + 1
            SET @CommodityId = null
            SELECT @CommodityId = prcm_CommodityId, @ParentId = prcm_ParentId 
                FROM @tblInternal 
                where cntr = @cntr
        End    
    end
    RETURN 

END
GO

-- This function returns a specific commodity name for an element of the commodity path structure
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetCommodityPathElement]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    drop function [dbo].[ufn_GetCommodityPathElement]
GO
CREATE FUNCTION dbo.ufn_GetCommodityPathElement ( 
    @path varchar(200), 
    @level int = 1
)
RETURNS varchar(1000)
AS
BEGIN
    DECLARE @RetValue varchar(1000)
    DECLARE @prcm_Name varchar(1000)
    DECLARE @PathLen int, @ndxStart int, @ndxNext int, @ndxEnd int, @CurrLevel int
    DECLARE @Level1Id int, @Level2Id int, @Level3Id int, @Level4Id int, @Level5Id int
    SET @RetValue = NULL      
    SET @PathLen = Len(@path)      
    
    SET @ndxStart = 0
    SET @CurrLevel = 1
    
    WHILE (@ndxStart < @PathLen)
    BEGIN
        if (@ndxStart = 0)
            SET @ndxStart = 1
        else
            SET @ndxStart = @ndxEnd + 1
        
        IF (@ndxStart > @PathLen)
            RETURN NULL
        
        SET @ndxEnd = CHARINDEX(',', @path, @ndxStart)
        if (@ndxEnd = 0)
            SET @ndxEnd = @PathLen +1

        IF (@CurrLevel = @level)
        begin
            SET @RetValue  = SUBSTRING(@path, @ndxStart, @ndxEnd-@ndxStart)
            IF (@RetValue = '')
                SET @RetValue = NULL
            break
        end
        SET @CurrLevel = @CurrLevel+1
    END
    
    RETURN @RetValue
END
GO

-- This function returns the comma delimited attribute list for the given commodity and company
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetCommodityAttributeList]') 
                    and xtype in (N'FN', N'IF', N'TF')) 
    drop function [dbo].[ufn_GetCommodityAttributeList]
GO
CREATE FUNCTION dbo.ufn_GetCommodityAttributeList ( 
    @companyid int, 
    @commodityid int
)
RETURNS NVARCHAR(1024)
AS
BEGIN
  DECLARE @RetValue nvarchar(1024)
	SELECT @RetValue = Coalesce(@RetValue + ', ', '') + Convert(nvarchar(1024),prat_name)
      FROM PRCompanyCommodityAttribute WITH (NOLOCK)
           INNER JOIN PRAttribute WITH (NOLOCK) ON prat_AttributeId = prcca_AttributeId
     WHERE prcca_companyid = @companyid
       AND prcca_commodityid = @commodityid

  SET @RetValue = rtrim(convert(nvarchar(1024), COALESCE(@RetValue,'')))
  RETURN @RetValue
END
GO

-- This function returns a list of the available classifications values bsed upon 
-- the passed CompanyId
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetSelectableClassifications]') 
            and OBJECTPROPERTY(id, N'IsTableFunction') = 1)
drop Function [dbo].[ufn_GetSelectableClassifications]
GO

CREATE FUNCTION dbo.ufn_GetSelectableClassifications
(
    @CompanyId int
)
RETURNS @tblClassifications TABLE (
    prcl_ClassificationId int,
    prcl_ParentId int,
    prcl_Level int,
    prcl_Name varchar(100),
    prcl_Abbreviation varchar(400),
    prcl_BookSection int,
    prcl_Path varchar(100)
)
as
BEGIN

	DECLARE @BookSection int
	SELECT @BookSection = CASE comp_PRIndustryType 
			WHEN 'P' THEN 0 
			WHEN 'T' THEN 1
			WHEN 'S' THEN 2 
			WHEN 'L' THEN 3 
			END
       FROM Company WITH (NOLOCK)
      WHERE comp_CompanyID = @CompanyId;


    -- Load all the classifications
    INSERT INTO @tblClassifications
        SELECT prcl_ClassificationId, prcl_ParentId, 
               prcl_Level, prcl_Name, prcl_Abbreviation, prcl_BookSection, prcl_Path 
          FROM PRClassification WITH (NOLOCK)
         WHERE prcl_BookSection = @BookSection;

    -- if company is not passed, return everything
    if (@CompanyId is null)
        RETURN
        
    -- remove any previously selected classification
    DELETE FROM @tblClassifications
    WHERE prcl_ClassificationId in 
          ( Select prc2_ClassificationId from PRCompanyClassification WHERE prc2_CompanyId = @CompanyId)
    
    -- remove any items that are a child of a selected classification
    DELETE FROM @tblClassifications
    WHERE prcl_ParentId in 
          ( Select prc2_ClassificationId from PRCompanyClassification WHERE prc2_CompanyId = @CompanyId)

    RETURN 

END
GO

-- This function returns a table of the classifications id within investigation methodology
-- Group A values based upon the passed CompanyId (querying PRCompanyClassification
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetAssignedGroupAClassifications]') 
            and OBJECTPROPERTY(id, N'IsTableFunction') = 1)
drop Function [dbo].[ufn_GetAssignedGroupAClassifications]
GO

CREATE FUNCTION dbo.ufn_GetAssignedGroupAClassifications
(
    @CompanyId int
)
RETURNS @tblClassifications TABLE (
    prcl_ClassificationId int,
    prcl_ParentId int,
    prcl_Level int,
    prcl_Name varchar(100),
    prcl_Abbreviation varchar(400),
    prcl_BookSection int,
    prcl_Path varchar(100)
)
as
BEGIN
    -- if company is not passed, return everything
    if (@CompanyId is null)
        RETURN

    -- Load all the classifications
    INSERT INTO @tblClassifications
      SELECT prcl_ClassificationId, prcl_ParentId, 
             prcl_Level, prcl_Name, prcl_Abbreviation, prcl_BookSection, prcl_Path 
        FROM PRCompanyClassification WITH (NOLOCK) 
             INNER JOIN PRClassification WITH (NOLOCK) ON prc2_ClassificationId = prcl_ClassificationId 
       WHERE prc2_ClassificationId in 
            (SELECT prcl_ClassificationId 
               FROM PRClassification WITH (NOLOCK) 
              WHERE prcl_Abbreviation in ('Dstr', 'Exp', 'J', 'R', 'Ret', 'Rg', 'Wg', 'TruckBkr'))
        AND prc2_CompanyId = @CompanyId

    RETURN 

END
GO



-- This function returns a comma separated list of the address types for the passed address
-- The capt_family attribute allows the function to differentiate between company and person types.
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetAddressTypeList]') and xtype in (N'FN', N'IF', N'TF')) 
    drop function [dbo].[ufn_GetAddressTypeList]
GO
CREATE FUNCTION dbo.ufn_GetAddressTypeList ( 
    @addressid int,
    @capt_family varchar(40)
)
RETURNS NVARCHAR(1024)
AS
BEGIN
  DECLARE @RetValue nvarchar(1024)
   SELECT @RetValue = Coalesce(@RetValue + ', ', '') + Convert(nvarchar(1024),capt_us)
     FROM Address_Link WITH (NOLOCK)
          INNER JOIN Custom_Captions WITH (NOLOCK) ON capt_code = adli_Type 
                   AND capt_familytype = 'Choices' AND capt_family = @capt_family 
    WHERE adli_AddressId = @addressid

  SET @RetValue = rtrim(Convert(nvarchar(1024),COALESCE(@RetValue,'')))
  RETURN @RetValue
END
GO

-- The tokenize function takes a comma delimited string and returns a 
-- table of the string's values
If Exists (Select name from sysobjects where name = 'Tokenize' and type='TF') 
    Drop Function dbo.Tokenize
Go

CREATE FUNCTION dbo.Tokenize(@sText varchar(max), @sDelim varchar(20) = ' ')
RETURNS @retArray TABLE (idx smallint Primary Key, value varchar(100))
AS
BEGIN
    DECLARE @idx smallint,
        @value varchar(100),
        @bcontinue bit,
        @iStrike smallint,
        @iDelimlength tinyint

    IF @sDelim = 'Space'
        BEGIN
        SET @sDelim = ' '
        END

    SET @idx = 0
    SET @sText = LTrim(RTrim(@sText))
    SET @iDelimlength = DATALENGTH(@sDelim)
    SET @bcontinue = 1

    IF NOT ((@iDelimlength = 0) or (@sDelim = 'Empty'))
        BEGIN
        WHILE @bcontinue = 1
            BEGIN

            --If you can find the delimiter in the text, retrieve the first element and
            --insert it with its index into the return table.
     
            IF CHARINDEX(@sDelim, @sText)>0
                BEGIN
                SET @value = SUBSTRING(@sText,1, CHARINDEX(@sDelim,@sText)-1)
                    BEGIN
                    INSERT @retArray (idx, value)
                    VALUES (@idx, @value)
                    END
                
                --Trim the element and its delimiter from the front of the string.
                --Increment the index and loop.
                SET @iStrike = DATALENGTH(@value) + @iDelimlength
                SET @idx = @idx + 1
                SET @sText = LTrim(Right(@sText,DATALENGTH(@sText) - @iStrike))
            
                END
            ELSE
                BEGIN
                    --If you cant find the delimiter in the text, @sText is the last value in
                    --@retArray.
                    SET @value = @sText
                    BEGIN
                        INSERT @retArray (idx, value)
                        VALUES (@idx, @value)
                    END
                    --Exit the WHILE loop.
                    SET @bcontinue = 0
                END
            END
        END
    ELSE
        BEGIN
        WHILE @bcontinue=1
            BEGIN
            --If the delimiter is an empty string, check for remaining text
            --instead of a delimiter. Insert the first character into the
            --retArray table. Trim the character from the front of the string.
            --Increment the index and loop.
            IF DATALENGTH(@sText)>1
                BEGIN
                SET @value = SUBSTRING(@sText,1,1)
                    BEGIN
                    INSERT @retArray (idx, value)
                    VALUES (@idx, @value)
                    END
                SET @idx = @idx+1
                SET @sText = SUBSTRING(@sText,2,DATALENGTH(@sText)-1)
                
                END
            ELSE
                BEGIN
                --One character remains.
                --Insert the character, and exit the WHILE loop.
                INSERT @retArray (idx, value)
                VALUES (@idx, @sText)
                SET @bcontinue = 0    
                END
        END
    END

    RETURN
END
GO

-- This function retrieves all the calculated values from for the display of the trade report 
-- analysis screen.
CREATE OR ALTER   FUNCTION [dbo].[ufn_GetTradeReportAnalysis]
(
    @prtr_SubjectId int = NULL,
    @prtr_StartDate datetime = NULL,
    @prtr_EndDate datetime = NULL,
    @prtr_Exception char(1) = NULL,
    @prtr_DisputeInvolved char(1) = NULL,
    @prtr_Duplicate char(1) = NULL,
    @prtr_ClassificationList varchar(50) = NULL,
    @MostRecentByResponderOnly char(1) = NULL,
	@IndustryType varchar(40) = NULL,
	@HQID int = NULL
)
RETURNS @tblTradeReportAnalysis TABLE (
    prtr_SubjectId int,
    prtr_ReportCount int,
    prtr_UniqueResponderCount int,
    prtr_Int_Count int,
    prtr_Int_Avg decimal(12,3) default 0,
    prtr_Int_XCount int default 0, prtr_Int_XPct decimal(12,3) default 0,
    prtr_Int_XXCount int default 0, prtr_Int_XXPct decimal(12,3) default 0,
    prtr_Int_XXXCount int default 0, prtr_Int_XXXPct decimal(12,3) default 0,
    prtr_Int_XXXXCount int default 0, prtr_Int_XXXXPct decimal(12,3) default 0,
    prtr_Credit_Count int,
    prtr_Credit_5MCount int default 0, prtr_Credit_5MPct decimal(12,3) default 0,
    prtr_Credit_10MCount int default 0, prtr_Credit_10MPct decimal(12,3) default 0,
    prtr_Credit_50MCount int default 0, prtr_Credit_50MPct decimal(12,3) default 0,
    prtr_Credit_75MCount int default 0, prtr_Credit_75MPct decimal(12,3) default 0,
    prtr_Credit_100MCount int default 0, prtr_Credit_100MPct decimal(12,3) default 0,
    prtr_Credit_250MCountOver int default 0, prtr_Credit_250MPctOver decimal(12,3) default 0,
	prtr_Credit_250MCount int default 0, prtr_Credit_250MPct decimal(12,3) default 0,
	prtr_Credit_500MCount int default 0, prtr_Credit_500MPct decimal(12,3) default 0,
	prtr_Credit_1000MCountOver int default 0, prtr_Credit_1000MPctOver decimal(12,3) default 0,
    prtr_Pay_Count int, prtr_Pay_Median varchar(40),prtr_Pay_MedianNumeric decimal(12,3) default 0,
	prtr_Pay_Avg decimal(12,3) default 0,
    prtr_Pay_Low varchar(40), prtr_Pay_High varchar(40),
    prtr_Pay_AACount int default 0, prtr_Pay_AAPct decimal(12,3) default 0,
    prtr_Pay_ACount int default 0, prtr_Pay_APct decimal(12,3) default 0,
    prtr_Pay_BCount int default 0, prtr_Pay_BPct decimal(12,3) default 0,
    prtr_Pay_CCount int default 0, prtr_Pay_CPct decimal(12,3) default 0,
    prtr_Pay_DCount int default 0, prtr_Pay_DPct decimal(12,3) default 0,
    prtr_Pay_ECount int default 0, prtr_Pay_EPct decimal(12,3) default 0,
    prtr_Pay_FCount int default 0, prtr_Pay_FPct decimal(12,3) default 0
)
as
BEGIN
    DECLARE @Msg varchar(2000)
    DECLARE @prtr_ReportCount int, @prtr_Int_Count int, @prtr_Crt_Count int, @prtr_Pay_Count int
    -- Create a local table for the trade reports that meet our search
    -- 2/24/2006 changing the insert below to populate the ...number fields with the weight
    --           values from the Pay and Integrity Rating lookups
    DECLARE @tblTRs TABLE (prtr_ResponderId int, prtr_TradeReportID int,
                           prtr_integrityid int, prin_weight decimal(12,3),
                           prtr_payratingid int, prpy_weight decimal(12,3),
                           prtr_highcredit varchar(4)
						   ,ptrr_Date datetime, prtr_ExcludeFromAnalysis char(1)
                          )
    -- get the TradeReports
    INSERT INTO @tblTRs 
        SELECT prtr_ResponderId, prtr_TradeReportID,
               prtr_integrityid, convert(decimal(12,3),prin_weight),
               prtr_PayRatingId, convert(decimal(12,3),prpy_weight),
               prtr_HighCredit
			   ,prtr_Date, prtr_ExcludeFromAnalysis
        FROM PRTradeReport WITH (NOLOCK)
		     INNER JOIN Company s WITH (NOLOCK) ON prtr_SubjectID = s.comp_CompanyID
			 INNER JOIN Company r WITH (NOLOCK) ON prtr_ResponderID = r.comp_CompanyID
             LEFT OUTER JOIN PRPayRating WITH (NOLOCK) ON prtr_PayRatingId = prpy_PayRatingId
             LEFT OUTER JOIN PRIntegrityRating WITH (NOLOCK) ON prtr_IntegrityId = prin_IntegrityRatingId
       WHERE prtr_SubjectId = ISNULL(@prtr_SubjectId, prtr_SubjectId)
	     AND s.comp_PRHQID = ISNULL(@HQID, s.comp_PRHQID)
	     AND r.comp_PRIndustryType = ISNULL(@IndustryType, r.comp_PRIndustryType)
		 AND r.comp_prIgnoreTES IS NULL
         AND prtr_Date BETWEEN ISNULL(@prtr_StartDate, '1900-01-01') AND ISNULL(@prtr_EndDate, GETDATE())
         AND ISNULL(prtr_Exception, 'N') = ISNULL(@prtr_Exception, ISNULL(prtr_Exception, 'N'))
		 AND ISNULL(prtr_DisputeInvolved, 'N') = ISNULL(@prtr_DisputeInvolved, ISNULL(prtr_DisputeInvolved, 'N'))
		 AND ISNULL(prtr_Duplicate, 'N') = ISNULL(@prtr_Duplicate, ISNULL(prtr_Duplicate, 'N'))
         AND (@prtr_ClassificationList is null OR @prtr_ClassificationList = '' OR
             prtr_ResponderId in 
             (SELECT distinct prtr_ResponderId 
                FROM (SELECT prtr_ResponderId, prc2_ClassificationId, prcl_Name, highest_level = Left(prcl_Path, charindex(',',prcl_Path)-1) 
                        FROM PRTradeReport WITH (NOLOCK) 
						     INNER JOIN Company WITH (NOLOCK) ON prtr_SubjectID = comp_CompanyID
                             LEFT OUTER JOIN PRCompanyClassification WITH (NOLOCK) ON prc2_CompanyId = prtr_ResponderId
                             LEFT OUTER JOIN PRClassification ON prc2_ClassificationId = prcl_classificationId
                       WHERE prtr_SubjectId = ISNULL(@prtr_SubjectId, prtr_SubjectId)
	                     AND comp_PRHQID = ISNULL(@HQID, comp_PRHQID)) ATable
               WHERE highest_level IN (SELECT value FROM dbo.Tokenize(@prtr_ClassificationList, ','))
             )
            ) 
	IF (@MostRecentByResponderOnly = 'Y') BEGIN
		DELETE
		  FROM @tblTRs
		 WHERE prtr_TradeReportID NOT IN (
                 SELECT TradeReportID FROM (
                    SELECT prtr_ResponderID, max(prtr_TradeReportID) As TradeReportID 
                      FROM @tblTRs
                  GROUP BY prtr_ResponderID) T1);
	END


	DELETE FROM @tblTRs WHERE prtr_ExcludeFromAnalysis = 'Y'


    -- check if we have a record
    SELECT @prtr_ReportCount = COUNT(1) FROM @tblTRs 
    IF (@prtr_ReportCount > 0)
    BEGIN
		DECLARE @UniqueResponderCount int
		SELECT @UniqueResponderCount = COUNT(DISTINCT prtr_ResponderId) FROM @tblTRs;
        -- Retrieve all the values
        INSERT INTO @tblTradeReportAnalysis (prtr_SubjectId, prtr_ReportCount, prtr_UniqueResponderCount) 
         VALUES (@prtr_SubjectId, @prtr_ReportCount, @UniqueResponderCount)
        -- Integrity
        SELECT @prtr_Int_Count = COUNT(1) FROM @tblTRs WHERE prtr_integrityid is not null AND prtr_integrityid > 0;
        UPDATE @tblTradeReportAnalysis SET prtr_Int_Count = @prtr_Int_Count
        IF (@prtr_Int_Count > 0)
        BEGIN
            UPDATE @tblTradeReportAnalysis SET prtr_Int_Avg = trs.intAvg 
            FROM (SELECT intAvg = AVG(prin_weight) FROM @tblTRs WHERE prin_weight is not null) as trs
            UPDATE @tblTradeReportAnalysis SET prtr_Int_XCount = trs.intXCount, prtr_Int_XPct = trs.intXPct 
            FROM (SELECT intXCount = COUNT(1), intXPct = Cast(COUNT(1)AS decimal(12,3))/CAST(@prtr_Int_Count AS decimal(12,3)) FROM @tblTRs WHERE prin_weight = 1) as trs
            UPDATE @tblTradeReportAnalysis SET prtr_Int_XXCount = trs.intXXCount, prtr_Int_XXPct = trs.intXXPct 
            FROM (SELECT intXXCount = COUNT(1), intXXPct = Cast(COUNT(1)AS decimal(12,3))/CAST(@prtr_Int_Count AS decimal(12,3)) FROM @tblTRs WHERE prin_weight = 2) as trs
            UPDATE @tblTradeReportAnalysis SET prtr_Int_XXXCount = trs.intXXXCount, prtr_Int_XXXPct = trs.intXXXPct 
            FROM (SELECT intXXXCount = COUNT(1), intXXXPct = Cast(COUNT(1)AS decimal(12,3))/CAST(@prtr_Int_Count AS decimal(12,3)) FROM @tblTRs WHERE prin_weight = 3) as trs
            UPDATE @tblTradeReportAnalysis SET prtr_Int_XXXXCount = trs.intXXXXCount, prtr_Int_XXXXPct = trs.intXXXXPct 
            FROM (SELECT intXXXXCount = COUNT(1), intXXXXPct = Cast(COUNT(1)AS decimal(12,3))/CAST(@prtr_Int_Count AS decimal(12,3)) FROM @tblTRs WHERE prin_weight = 4) as trs
        END
        -- Credit
        SELECT @prtr_Crt_Count = COUNT(1) FROM @tblTRs WHERE prtr_HighCredit is not null AND prtr_HighCredit <> ''
        UPDATE @tblTradeReportAnalysis SET prtr_Credit_Count = @prtr_Crt_Count
        IF (@prtr_Crt_Count > 0)
        BEGIN
            UPDATE @tblTradeReportAnalysis SET prtr_Credit_5MCount = trs.crt5MCount, prtr_Credit_5MPct = trs.crt5MPct 
            FROM (SELECT crt5MCount = COUNT(1), crt5MPct = Cast(COUNT(1)AS decimal(12,3))/CAST(@prtr_Crt_Count AS decimal(12,3)) FROM @tblTRs WHERE prtr_HighCredit = 'A') as trs
            UPDATE @tblTradeReportAnalysis SET prtr_Credit_10MCount = trs.crt10MCount, prtr_Credit_10MPct = trs.crt10MPct 
            FROM (SELECT crt10MCount = COUNT(1), crt10MPct = Cast(COUNT(1)AS decimal(12,3))/CAST(@prtr_Crt_Count AS decimal(12,3)) FROM @tblTRs WHERE prtr_HighCredit = 'B') as trs
            UPDATE @tblTradeReportAnalysis SET prtr_Credit_50MCount = trs.crt50MCount, prtr_Credit_50MPct = trs.crt50MPct 
            FROM (SELECT crt50MCount = COUNT(1), crt50MPct = Cast(COUNT(1)AS decimal(12,3))/CAST(@prtr_Crt_Count AS decimal(12,3)) FROM @tblTRs WHERE prtr_HighCredit = 'C') as trs
            UPDATE @tblTradeReportAnalysis SET prtr_Credit_75MCount = trs.crt75MCount, prtr_Credit_75MPct = trs.crt75MPct 
            FROM (SELECT crt75MCount = COUNT(1), crt75MPct = Cast(COUNT(1)AS decimal(12,3))/CAST(@prtr_Crt_Count AS decimal(12,3)) FROM @tblTRs WHERE prtr_HighCredit = 'D') as trs
            UPDATE @tblTradeReportAnalysis SET prtr_Credit_100MCount = trs.crt100MCount, prtr_Credit_100MPct = trs.crt100MPct 
            FROM (SELECT crt100MCount = COUNT(1), crt100MPct = Cast(COUNT(1)AS decimal(12,3))/CAST(@prtr_Crt_Count AS decimal(12,3)) FROM @tblTRs WHERE prtr_HighCredit = 'E') as trs
            UPDATE @tblTradeReportAnalysis SET prtr_Credit_250MCountOver = trs.crt250MCountOver, prtr_Credit_250MPctOver = trs.crt250MPctOver
            FROM (SELECT crt250MCountOver = COUNT(1), crt250MPctOver = Cast(COUNT(1)AS decimal(12,3))/CAST(@prtr_Crt_Count AS decimal(12,3)) FROM @tblTRs WHERE prtr_HighCredit = 'F') as trs
			UPDATE @tblTradeReportAnalysis SET prtr_Credit_250MCount = trs.crt250MCount, prtr_Credit_250MPct = trs.crt250MPct
            FROM (SELECT crt250MCount = COUNT(1), crt250MPct = Cast(COUNT(1)AS decimal(12,3))/CAST(@prtr_Crt_Count AS decimal(12,3)) FROM @tblTRs WHERE prtr_HighCredit = 'G') as trs
			UPDATE @tblTradeReportAnalysis SET prtr_Credit_500MCount = trs.crt500MCount, prtr_Credit_500MPct = trs.crt500MPct
            FROM (SELECT crt500MCount = COUNT(1), crt500MPct = Cast(COUNT(1)AS decimal(12,3))/CAST(@prtr_Crt_Count AS decimal(12,3)) FROM @tblTRs WHERE prtr_HighCredit = 'H') as trs
			UPDATE @tblTradeReportAnalysis SET prtr_Credit_1000MCountOver = trs.crt1000MCountOver, prtr_Credit_1000MPctOver = trs.crt1000MPctOver
            FROM (SELECT crt1000MCountOver = COUNT(1), crt1000MPctOver = Cast(COUNT(1)AS decimal(12,3))/CAST(@prtr_Crt_Count AS decimal(12,3)) FROM @tblTRs WHERE prtr_HighCredit = 'I') as trs
        END
        -- PAY 
        SELECT @prtr_Pay_Count = COUNT(1) FROM @tblTRs WHERE prtr_payratingid is not null AND prtr_payratingid > 0;
        UPDATE @tblTradeReportAnalysis SET prtr_Pay_Count = @prtr_Pay_Count
        IF (@prtr_Pay_Count > 0)
        BEGIN
            UPDATE @tblTradeReportAnalysis SET prtr_Pay_Avg = trs.payAvg 
            FROM (SELECT payAvg = AVG(prpy_weight) FROM @tblTRs WHERE prpy_weight is not null) as trs
            UPDATE @tblTradeReportAnalysis SET prtr_Pay_Low = trs.prpy_Name
            FROM (SELECT prpy_Name 
                    FROM PRPayRating pay
                    WHERE pay.prpy_Weight = ( Select Min(prpy_weight) FROM @tblTRs )
                  ) trs
            UPDATE @tblTradeReportAnalysis SET prtr_Pay_High = trs.prpy_Name 
            FROM (SELECT prpy_Name 
                    FROM PRPayRating pay
                    WHERE pay.prpy_Weight = (Select MAX(prpy_weight) FROM @tblTRs)
                 ) trs
            -- Pay Median requires a bit more work
            DECLARE @MedianNumeric decimal(12,3)
            IF (@prtr_Pay_Count = 1)
            BEGIN
                SELECT @MedianNumeric = convert(decimal(12,3),prpy_weight) FROM @tblTRs where prtr_payratingid is not null  AND prtr_payratingid > 0;
            END
            ELSE
            BEGIN
                DECLARE @tblMedian TABLE (cnt int identity(0,1), prtr_payratingid int, prpy_weight decimal(12,3))
                INSERT INTO @tblMedian 
                    SELECT prtr_payratingid, prpy_weight 
                      FROM @tblTRs 
                     WHERE prtr_payratingid is not null  
                       AND prtr_payratingid > 0
                  ORDER BY prpy_weight
                DECLARE @CountHalf int
                Select @CountHalf = (Count(1) + (Count(1)%2) ) /2 from @tblMedian
                DECLARE @MedianMax decimal(12,3)
                DECLARE @MedianMin decimal(12,3)
                SELECT @MedianMax = Max(convert(decimal(12,3),prpy_weight)) 
                    FROM @tblMedian
                    WHERE cnt < @CountHalf
                SELECT @MedianMin = Min(convert(decimal(12,3),prpy_weight)) 
                    FROM @tblMedian
                    WHERE cnt > @CountHalf
                SET @MedianNumeric = (@MedianMax + @MedianMin)/2
            END
            UPDATE @tblTradeReportAnalysis SET prtr_Pay_MedianNumeric = @MedianNumeric,
                prtr_Pay_Median = case 
                                    when ROUND(@MedianNumeric,0) = 1 THEN 'F'
                                    when ROUND(@MedianNumeric,0) = 2 THEN 'E'
                                    when ROUND(@MedianNumeric,0) = 3 THEN 'D'
                                    when ROUND(@MedianNumeric,0) = 4 THEN 'C'
                                    when ROUND(@MedianNumeric,0) = 5 THEN 'B'
                                    when ROUND(@MedianNumeric,0) = 6 THEN 'A'
                                    when ROUND(@MedianNumeric,0) = 7 THEN 'AA'
                                    else ''
                                end
            -- now back to count and % fields
            UPDATE @tblTradeReportAnalysis 
			   SET prtr_Pay_AACount = trs.payAACount, 
			       prtr_Pay_AAPct = trs.payAAPct 
              FROM (SELECT payAACount = COUNT(1), 
			               payAAPct = Cast(COUNT(1)AS decimal(12,3))/CAST(@prtr_Pay_Count AS decimal(12,3)) 
					  FROM @tblTRs WHERE prpy_weight = 7) as trs
            UPDATE @tblTradeReportAnalysis 
			   SET prtr_Pay_ACount = trs.payACount, 
			       prtr_Pay_APct = trs.payAPct 
              FROM (SELECT payACount = COUNT(1), 
			               payAPct = Cast(COUNT(1)AS decimal(12,3))/CAST(@prtr_Pay_Count AS decimal(12,3)) 
				      FROM @tblTRs WHERE prpy_weight = 6) as trs
            UPDATE @tblTradeReportAnalysis SET prtr_Pay_BCount = trs.payBCount, prtr_Pay_BPct = trs.payBPct 
            FROM (SELECT payBCount = COUNT(1), payBPct = Cast(COUNT(1)AS decimal(12,3))/CAST(@prtr_Pay_Count AS decimal(12,3)) FROM @tblTRs WHERE prpy_weight = 5) as trs
            UPDATE @tblTradeReportAnalysis SET prtr_Pay_CCount = trs.payCCount, prtr_Pay_CPct = trs.payCPct 
            FROM (SELECT payCCount = COUNT(1), payCPct = Cast(COUNT(1)AS decimal(12,3))/CAST(@prtr_Pay_Count AS decimal(12,3)) FROM @tblTRs WHERE prpy_weight = 4) as trs
            UPDATE @tblTradeReportAnalysis SET prtr_Pay_DCount = trs.payDCount, prtr_Pay_DPct = trs.payDPct 
            FROM (SELECT payDCount = COUNT(1), payDPct = Cast(COUNT(1)AS decimal(12,3))/CAST(@prtr_Pay_Count AS decimal(12,3)) FROM @tblTRs WHERE prpy_weight = 3) as trs
            UPDATE @tblTradeReportAnalysis SET prtr_Pay_ECount = trs.payECount, prtr_Pay_EPct = trs.payEPct 
            FROM (SELECT payECount = COUNT(1), payEPct = Cast(COUNT(1)AS decimal(12,3))/CAST(@prtr_Pay_Count AS decimal(12,3)) FROM @tblTRs WHERE prpy_weight = 2) as trs
            UPDATE @tblTradeReportAnalysis SET prtr_Pay_FCount = trs.payFCount, prtr_Pay_FPct = trs.payFPct 
            FROM (SELECT payFCount = COUNT(1), payFPct = Cast(COUNT(1)AS decimal(12,3))/CAST(@prtr_Pay_Count AS decimal(12,3)) FROM @tblTRs WHERE prpy_weight = 1) as trs
        END
    END
    RETURN 
END
GO




-- This function retrieves a comma delimited list of Level 1 Classification for the specified company
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetLevel1Classifications]'))
drop Function [dbo].[ufn_GetLevel1Classifications]
GO

CREATE FUNCTION dbo.ufn_GetLevel1Classifications
(
    @comp_CompanyId int = NULL,
    @return_type int = 0 -- 0 = ID, 1=Abbreviation, 2=Name
)
RETURNS varchar(200) 
AS 
BEGIN
    Declare @business_type varchar(1000)
    
    -- Are we returning the root ID?
    IF (@return_type = 0) 
    BEGIN
        SELECT @business_type = COALESCE(@business_type + ',', '') + highest_level 
          FROM (SELECT DISTINCT prc2_CompanyID, highest_level = CASE WHEN CHARINDEX(',', prcl_Path)  = 0 THEN prcl_Path ELSE LEFT(prcl_Path, CHARINDEX(',', prcl_Path)-1) END  
                  FROM PRCompanyClassification WITH (NOLOCK) 
                       LEFT OUTER JOIN PRClassification ON prc2_ClassificationId = prcl_classificationId 
                  WHERE prc2_CompanyId = @comp_CompanyId ) ATable 
         WHERE highest_level IS NOT NULL 
    END

    -- Are we returning an abbreviation?
    ELSE IF (@return_type = 1) 
    BEGIN
        SELECT @business_type = COALESCE(@business_type + ',', '') + highest_level 
          FROM (SELECT DISTINCT prc2_CompanyID, highest_level = prcl_abbreviation 
                  FROM PRClassification
                       JOIN (SELECT DISTINCT prc2_CompanyID, highest_level = CASE WHEN CHARINDEX(',', prcl_Path)  = 0 THEN prcl_Path ELSE LEFT(prcl_Path, CHARINDEX(',', prcl_Path)-1) END  
                               FROM PRCompanyClassification WITH (NOLOCK) 
                                    LEFT OUTER JOIN PRClassification ON prc2_ClassificationId = prcl_classificationId 
                              WHERE prc2_CompanyId = @comp_CompanyId) ATable 
                         ON highest_level = prcl_ClassificationId) BTable 
        WHERE highest_level IS NOT NULL 
    END

    -- Are we returning a name?
    ELSE IF (@return_type = 2)
    BEGIN
        SELECT @business_type = COALESCE(@business_type + ', ', '') + highest_level 
          FROM (SELECT DISTINCT prc2_CompanyID, highest_level = prcl_name 
                  FROM PRClassification
                       JOIN (SELECT DISTINCT prc2_CompanyID, highest_level = CASE WHEN CHARINDEX(',', prcl_Path)  = 0 THEN prcl_Path ELSE LEFT(prcl_Path, CHARINDEX(',', prcl_Path)-1) END  
                               FROM PRCompanyClassification WITH (NOLOCK) 
                                    LEFT OUTER JOIN PRClassification ON prc2_ClassificationId = prcl_classificationId 
                              WHERE prc2_CompanyId = @comp_CompanyId) ATable 
                         ON highest_level = prcl_ClassificationId) BTable 
        WHERE highest_level IS NOT NULL 
    END

    RETURN @business_type
END
GO

-- This function retrieves a comma delimited list of CompanyIds related to the passed in company as 
-- either a Headquarter, branch, or relationship type 27, 28, or 29 (affiliated)
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetRelatedCompaniesList]'))
	drop Function [dbo].[ufn_GetRelatedCompaniesList]
GO

CREATE FUNCTION dbo.ufn_GetRelatedCompaniesList
(
    @comp_CompanyId int = NULL
)
RETURNS varchar(2000) 
AS 
BEGIN
    Declare @complete_list varchar(2000)
    Declare @comp_PRHQId int

    -- get the headquarter
    SELECT @comp_PRHQId = comp_PRHQID
      FROM Company WITH (NOLOCK)
     WHERE comp_companyId = @comp_CompanyId;

    SET @complete_list = ''

    -- Add all companies in the enterprise
    SELECT @complete_list = coalesce(@complete_list+',','') +  Convert(varchar,comp_companyid)
      FROM Company WITH (NOLOCK)
     WHERE comp_PRHQId = @comp_PRHQId
       AND comp_companyid != @comp_CompanyId;

    -- Add left side relationships
    SELECT @complete_list = coalesce(@complete_list+',','') + convert(varchar,prcr_RightCompanyId)
      FROM PRCompanyRelationship WITH (NOLOCK)
     WHERE prcr_LeftCompanyId = @comp_CompanyId 
       AND prcr_Type in ('27','28','29');
          
    -- Add right side relationships
    SELECT @complete_list = coalesce(@complete_list+',','') + convert(varchar,prcr_LeftCompanyId)
      FROM PRCompanyRelationship WITH (NOLOCK)
     WHERE prcr_RightCompanyId = @comp_CompanyId 
       AND prcr_Type in ('27','28','29');

    RETURN @complete_list
END
GO	

-- This function retrieves all the calculated values from for the display of the  
-- AR Aging By Summary screen.
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetARAgingListingValues]') 
            and OBJECTPROPERTY(id, N'IsTableFunction') = 1)
drop Function [dbo].[ufn_GetARAgingListingValues]
GO
CREATE FUNCTION dbo.ufn_GetARAgingListingValues
(
    @praa_CompanyId int = NULL,
    @praa_StartDate datetime = NULL,
    @praa_EndDate datetime = NULL
)
RETURNS @tblARAging TABLE (
    praa_CompanyId int,
    praa_ARAgingId int,
    praa_RunDate datetime,
    praa_ImportedDate datetime,
    praa_ImportedByUserId int,
    praa_ARAgingDetailCount int,
    praa_Amount numeric(20,2) default 0, 
    praa_Amount0to29 numeric(20,2) default 0, 
    praa_Amount30to44 numeric(20,2) default 0, 
    praa_Amount45to60 numeric(20,2) default 0, 
    praa_Amount61Plus numeric(20,2) default 0, 
    praa_AmountPct numeric(6,3) default 0, 
    praa_Amount0to29Pct numeric(6,3) default 0,
    praa_Amount30to44Pct numeric(6,3) default 0,
    praa_Amount45to60Pct numeric(6,3) default 0,
    praa_Amount61PlusPct numeric(6,3) default 0,
    praa_TotalAmount numeric(20,2) default 0,
    praa_TotalAmount0to29 numeric(20,2) default 0, 
    praa_TotalAmount30to44 numeric(20,2) default 0, 
    praa_TotalAmount45to60 numeric(20,2) default 0, 
    praa_TotalAmount61Plus numeric(20,2) default 0, 
    praa_TotalAmount0to29Pct numeric(6,3) default 0, 
    praa_TotalAmount30to44Pct numeric(6,3) default 0, 
    praa_TotalAmount45to60Pct numeric(6,3) default 0, 
    praa_TotalAmount61PlusPct numeric(6,3) default 0,
    ERR_MSG varchar (2000) default NULL
)
as
BEGIN
    DECLARE @Msg varchar(2000)

    -- the user id is required
    IF ( @praa_CompanyId IS NULL) 
    BEGIN
        INSERT INTO @tblARAging (ERR_MSG) 
        VALUES ('Retrieval Failed.  An valid Company Id must be provided.')
        RETURN
    END

    -- populate our return table with a row row each of the PRARAging records meeting our search criteria
    INSERT INTO @tblARAging (praa_CompanyId, praa_ARAgingId, 
                             praa_ImportedDate, praa_ImportedByUserId, praa_RunDate) 
        SELECT praa_CompanyId, praa_ARAgingId, praa_ImportedDate, praa_ImportedByUserId, praa_RunDate 
          FROM PRARAging WITH (NOLOCK)
         WHERE praa_CompanyId = @praa_CompanyId
           AND (@praa_StartDate is null OR @praa_StartDate <= praa_RunDate)
           AND (@praa_EndDate is null OR @praa_EndDate >= praa_RunDate)
          
    -- Create a local table for the ARAgingDetail records that meet our search
    DECLARE @tblDetail TABLE (praad_ARAgingId int, praad_count int, 
                           praad_Amount numeric(20,2) default 0,
                           praad_Amount0to29 numeric(20,2) default 0,
                           praad_Amount30to44 numeric(20,2) default 0,
                           praad_Amount45to60 numeric(20,2) default 0,
                           praad_Amount61Plus numeric(20,2) default 0
                          )

    -- get the summed Details for each company in our result table
    INSERT INTO @tblDetail 
          SELECT praad_ARAgingId,  
                 COUNT(1), 0,
                 SUM(praad_Amount0to29),
                 SUM(praad_Amount30to44),
                 SUM(praad_Amount45to60), 
                 SUM(praad_Amount61Plus)
            FROM PRARAgingDetail 
                 INNER JOIN @tblARAging  ON praa_ARAgingId = praad_ARAgingId 
        GROUP BY praad_ARAgingId;

    -- we don't want any NULLS in our table or calculations will fail
    UPDATE @tblDetail SET
        praad_count = ISNULL(praad_count, 0),
        praad_Amount0to29 = ISNULL(praad_Amount0to29, 0),
        praad_Amount30to44 = ISNULL(praad_Amount30to44, 0),
        praad_Amount45to60 = ISNULL(praad_Amount45to60, 0),
        praad_Amount61Plus = ISNULL(praad_Amount61Plus, 0);
    
    UPDATE @tblDetail SET praad_Amount = (praad_Amount0to29+praad_Amount30to44+praad_Amount45to60+praad_Amount61Plus);

    -- save these values out to the result table for each row
    UPDATE @tblARAging SET 
           praa_ARAgingDetailCount = praad_count,
           praa_Amount = praad_Amount,
           praa_Amount0to29 = praad_Amount0to29,
           praa_Amount30to44 = praad_Amount30to44,
           praa_Amount45to60 = praad_Amount45to60,
           praa_Amount61Plus = praad_Amount61Plus
      FROM @tblDetail 
     WHERE praa_ARAgingId = praad_ARAgingId;

    -- Now calculate the Totals owed for each bucket; these are for the page summary totals
    DECLARE @praa_TotalAmount numeric(20,2)
    DECLARE @praa_TotalAmount0to29 numeric(20,2) 
    DECLARE @praa_TotalAmount30to44 numeric(20,2) 
    DECLARE @praa_TotalAmount45to60 numeric(20,2)  
    DECLARE @praa_TotalAmount61Plus numeric(20,2) 
    
    SELECT @praa_TotalAmount = SUM(praad_Amount),
           @praa_TotalAmount0to29 = SUM(praad_Amount0to29), 
           @praa_TotalAmount30to44 = SUM(praad_Amount30to44), 
           @praa_TotalAmount45to60 = SUM(praad_Amount45to60), 
           @praa_TotalAmount61Plus = SUM(praad_Amount61Plus)
      FROM @tblDetail;

    UPDATE @tblARAging SET 
           praa_TotalAmount = @praa_TotalAmount,
           praa_TotalAmount0to29 = @praa_TotalAmount0to29,
           praa_TotalAmount30to44 = @praa_TotalAmount30to44,
           praa_TotalAmount45to60 = @praa_TotalAmount45to60,
           praa_TotalAmount61Plus = @praa_TotalAmount61Plus
      FROM @tblDetail;

    -- Finally calculate the percentages
    IF (@praa_TotalAmount > 0)
    BEGIN
        UPDATE @tblARAging SET 
           praa_Amount0to29Pct = 100*(praa_Amount0to29/@praa_TotalAmount),
           praa_Amount30to44Pct = 100*(praa_Amount30to44/@praa_TotalAmount),
           praa_Amount45to60Pct = 100*(praa_Amount45to60/@praa_TotalAmount),
           praa_Amount61PlusPct = 100*(praa_Amount61Plus/@praa_TotalAmount),
           praa_TotalAmount0to29Pct = 100*(praa_TotalAmount0to29/@praa_TotalAmount),
           praa_TotalAmount30to44Pct = 100*(praa_TotalAmount30to44/@praa_TotalAmount),
           praa_TotalAmount45to60Pct = 100*(praa_TotalAmount45to60/@praa_TotalAmount),
           praa_TotalAmount61PlusPct = 100*(praa_TotalAmount61Plus/@praa_TotalAmount)
        FROM @tblDetail;

        UPDATE @tblARAging 
           SET praa_AmountPct = (praa_Amount0to29Pct+praa_Amount30to44Pct+praa_Amount45to60Pct+praa_Amount61PlusPct)
          FROM @tblDetail;
    END

    RETURN 
END
GO

/**************************************************************************
    ufn_GetAssignedRatingNumeralList:
    
    This function retrieves a comma delimited list of assigned rating 
    numerals.

**************************************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetAssignedRatingNumeralList]') 
    and xtype in (N'FN', N'IF', N'TF')) drop function [dbo].[ufn_GetAssignedRatingNumeralList]
GO
CREATE FUNCTION dbo.ufn_GetAssignedRatingNumeralList ( 
    @ratingid int,
    @CommaSeparate int = 1 
)
RETURNS VARCHAR(1024)
AS
BEGIN
  DECLARE @RetValue varchar(1024)
  
   SELECT @RetValue = Coalesce(@RetValue + ',', '') + prrn_name
     FROM PRRatingNumeralAssigned WITH (NOLOCK)
          INNER JOIN PRRatingNumeral ON pran_RatingNumeralId = prrn_RatingNumeralId
    WHERE pran_ratingid = @ratingid
 ORDER BY prrn_Order

  SET @RetValue = RTRIM(ISNULL(@RetValue,''))
  IF (@CommaSeparate = 0)
      SET @RetValue = REPLACE(@RetValue, ',', '')

  RETURN @RetValue
END
GO

/**************************************************************************
    ufn_GetCompanyRelationshipsList:
    
    This function retrieves a comma delimited list of relationship types
    between the two specified company.

**************************************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetCompanyRelationshipsList]'))
	drop Function [dbo].[ufn_GetCompanyRelationshipsList]
GO

CREATE FUNCTION dbo.ufn_GetCompanyRelationshipsList
(
    @CompanyId1 int = NULL,
    @CompanyId2 int = NULL
)
RETURNS varchar(200) 
AS 
BEGIN
    Declare @types varchar(40)

    SELECT @types = Coalesce(@types+',', '') + prcr_Type
      FROM
         (SELECT DISTINCT prcr_Type
            FROM PRCompanyRelationship WITH (NOLOCK)
           WHERE prcr_Active = 'Y'
		     AND prcr_LeftCompanyId = @CompanyId1 
			 AND prcr_RightCompanyId = @CompanyId2
         ) ATable

    RETURN @types
END
GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetCompanySharedRelationshipsList]'))
	drop Function [dbo].[ufn_GetCompanySharedRelationshipsList]
GO

CREATE FUNCTION dbo.ufn_GetCompanySharedRelationshipsList
(
    @CompanyId1 int = NULL,
    @CompanyId2 int = NULL
)
RETURNS varchar(200) 
AS 
BEGIN
    Declare @types varchar(40)

    SELECT @types = Coalesce(@types+',', '') + prcr_Type
      FROM
         (SELECT DISTINCT prcr_Type
            FROM PRCompanyRelationship WITH (NOLOCK)
           WHERE prcr_Active = 'Y'
		     AND (prcr_LeftCompanyId IN (@CompanyId1, @CompanyId2)
                  OR prcr_RightCompanyId IN (@CompanyId1, @CompanyId2))
         ) ATable
   ORDER BY prcr_Type
    RETURN @types
END
GO



/******************************************************************************
 *   Procedure: ufn_GetRequiredTESRequestCount
 *
 *   Return: int - the number of required TES requests for the company specified 
 *
 *   Decription:  This procedure creates 
 *
 *
 *****************************************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetRequiredTESRequestCount]') )
    drop function [dbo].[ufn_GetRequiredTESRequestCount]
GO

CREATE FUNCTION dbo.ufn_GetRequiredTESRequestCount
(
    @prbs_CompanyId int = NULL,
    @prbs_Date datetime = NULL,
    @prbs_p975Surveys int = NULL,
    @MinPerQuarter int = 0
)
RETURNS int
as
BEGIN
    DECLARE @comp_InvestigationMethodGroup varchar(1), @comp_PRIndustryType varchar(40), @ListingStatus varchar(40)
    DECLARE @cnt_PayReports_3Months int
    DECLARE @cnt_PayReports_12Months int
    DECLARE @cnt_IntegrityReports int
    DECLARE @RequiredReportCount int
    
    SELECT @comp_InvestigationMethodGroup = comp_PRInvestigationMethodGroup,
           @comp_PRIndustryType = comp_PRIndustryType,
		   @ListingStatus = comp_PRListingStatus
      FROM company WITH (NOLOCK)
     WHERE comp_Companyid = @prbs_CompanyId;

    SET @RequiredReportCount = 0;

	IF (@ListingStatus NOT IN ('N3', 'N5', 'N6')) BEGIN

		IF (@comp_InvestigationMethodGroup = 'A')
		BEGIN
			SELECT @cnt_PayReports_3Months = count(1) 
			 FROM PRTradeReport WITH (NOLOCK) 
                  INNER JOIN Company WITH (NOLOCK) ON comp_CompanyID = prtr_ResponderID 
			WHERE ISNULL(prtr_PayRatingId, 0) > 0
			  AND prtr_Date > DateAdd(Month, -3, @prbs_Date) 
			  AND prtr_SubjectId = @prbs_CompanyId 
              AND comp_PRListingStatus NOT IN ('N3', 'N5', 'N6');

			SELECT @cnt_PayReports_12Months = count(1) 
			 FROM PRTradeReport WITH (NOLOCK)  
                  INNER JOIN Company WITH (NOLOCK) ON comp_CompanyID = prtr_ResponderID 
			WHERE ISNULL(prtr_PayRatingId, 0) > 0
			  AND prtr_Date > DateAdd(Month, -12, @prbs_Date) 
			  AND prtr_SubjectId = @prbs_CompanyId 
              AND comp_PRListingStatus NOT IN ('N3', 'N5', 'N6');
	        
			-- using names (W, X) from homework document
			DECLARE @W int, @X int
			SET @W = @MinPerQuarter - @cnt_PayReports_3Months 
			SET @X = @prbs_p975Surveys - @cnt_PayReports_12Months 
			IF ( (@W > 0) OR (@X > 0)) 
			BEGIN
				IF (@W > @X)
					SET @RequiredReportCount = @W
				ELSE
					SET @RequiredReportCount = @X
			END
		END
		ELSE IF (@comp_InvestigationMethodGroup = 'B')
		BEGIN
			
			IF (@comp_PRIndustryType IN ('P', 'T')) BEGIN

			   SELECT @cnt_IntegrityReports = COUNT(1) 
				 FROM PRTradeReport WITH (NOLOCK)
                      INNER JOIN Company WITH (NOLOCK) ON comp_CompanyID = prtr_ResponderID 
				WHERE prtr_IntegrityId is not null 
				  AND prtr_Date > DateAdd(Month, -3, @prbs_Date)
				  AND prtr_SubjectId = @prbs_CompanyId
                  AND comp_PRListingStatus NOT IN ('N3', 'N5', 'N6');
	        
				IF (@cnt_IntegrityReports < 6)
					SET @RequiredReportCount = 6 - @cnt_IntegrityReports
			END
		END

		-- do not set required to more than 20
		-- TODO Pull this M value (20 from a the PRGeneral Table as a configurable value
		IF (@RequiredReportCount > 20)
			SET @RequiredReportCount = 20

		-- multiple times 3 due to attrition
		SET @RequiredReportCount = @RequiredReportCount * 3
	END

    RETURN @RequiredReportCount
END
GO
	
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetAllCompanyCommodities]') 
            and OBJECTPROPERTY(id, N'IsTableFunction') = 1)
drop Function [dbo].[ufn_GetAllCompanyCommodities]
GO

CREATE FUNCTION dbo.ufn_GetAllCompanyCommodities
(
    @CompanyId int = NULL
)
RETURNS @tblCommodities TABLE (
    CompanyCommodityAttributeId int,
    CommodityId int,
    GrowingMethodId int,
    AttributeId int,
    SequenceNumber int,
    PublishWithGM char(1),
    PublishedDisplay varchar(50)
)
as
BEGIN

    Declare @tblReturn Table (
        CompanyCommodityAttributeId int,
        CommodityId int,
        GrowingMethodId int,
        AttributeId int,
        Publish char(1),
        PublishWithGM char(1),
        SequenceNumber int,
        PublishedDisplay varchar(50)
    )

    INSERT INTO @tblReturn
	SELECT prcca_CompanyCommodityAttributeId, prcca_CommodityId, prcca_GrowingMethodId, prcca_AttributeId,
           prcca_Publish, prcca_PublishWithGM, 
           ISNULL(prcca_Sequence, 99999),
           prcca_PublishedDisplay
      FROM PRCompanyCommodityAttribute WITH (NOLOCK)
     WHERE prcca_CompanyId = @CompanyId;

    INSERT INTO @tblCommodities
    SELECT CompanyCommodityAttributeId, CommodityId, GrowingMethodId, AttributeId, 
      case 
        when SequenceNumber = 99999 then NULL
        else SequenceNumber
      end, 
      PublishWithGM, PublishedDisplay
    FROM @tblReturn
    ORDER BY SequenceNumber

    RETURN 

END
GO



/**
Returns the unit price for the specified usage type.
**/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetUsageTypePrice]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    drop function [dbo].[ufn_GetUsageTypePrice]
GO
CREATE FUNCTION dbo.ufn_GetUsageTypePrice(@UsageType varchar(40))
RETURNS int  AS  
BEGIN 
    
    DECLARE @Price int
    SELECT @Price = CONVERT(int, cast(capt_us as varchar))
      FROM Custom_Captions
     WHERE capt_family = 'prsuu_Units'
       AND capt_code = @UsageType;

    IF @Price IS NULL SET @Price = 0

    RETURN @Price
END
GO



/**
Determines if the specified company has enough available
units for the specified usage type.
**/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_HasAvailableUnits]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    drop function [dbo].[ufn_HasAvailableUnits]
GO

CREATE FUNCTION dbo.ufn_HasAvailableUnits(@HQID int, @ProductID int, @PricingListID int)
RETURNS int  AS  
BEGIN 
        
    DECLARE @HasUnits int
    DECLARE @Price numeric(24,6)

    SET @Price = dbo.ufn_GetProductPrice(@ProductID, @PricingListID);

    IF @Price = NULL BEGIN
        SET @HasUnits = 0
    END ELSE IF @Price = 0 BEGIN
        SET @HasUnits = 1
    END ELSE BEGIN

        SELECT @HasUnits = 1
          FROM PRServiceUnitAllocation
         WHERE GETDATE() BETWEEN prun_StartDate AND prun_ExpirationDate
           AND prun_HQID = @HQID
        HAVING SUM(prun_UnitsRemaining) >= @Price;

        IF @HasUnits IS NULL SET @HasUnits=0
    END

    RETURN @HasUnits
END
GO



/**
Returns the number of units the specified company has available.
**/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetAvailableUnits]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    drop function [dbo].[ufn_GetAvailableUnits]
GO

CREATE FUNCTION dbo.ufn_GetAvailableUnits(@CompanyID int)
RETURNS int  AS  
BEGIN 
    
    DECLARE @HQID int
    SELECT @HQID = comp_PRHQID
      FROM Company WITH (NOLOCK)
     WHERE comp_CompanyID = @CompanyID;

    DECLARE @RemainingUnits int
        
    SELECT @RemainingUnits = SUM(prun_UnitsRemaining) 
      FROM PRServiceUnitAllocation WITH (NOLOCK)
     WHERE GETDATE() BETWEEN prun_StartDate AND prun_ExpirationDate
       AND prun_HQID = @HQID;

    IF @RemainingUnits IS NULL SET @RemainingUnits=0

    RETURN @RemainingUnits
END
GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetRemainingBRCount]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    drop function [dbo].[ufn_GetRemainingBRCount]
GO




/**
Returns the number of units the specified company has available.
**/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetAllocatedUnits]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    drop function [dbo].[ufn_GetAllocatedUnits]
GO

CREATE FUNCTION dbo.ufn_GetAllocatedUnits(@CompanyID int)
RETURNS int  AS  
BEGIN 
    DECLARE @HQID int
    SELECT @HQID = comp_PRHQID
      FROM Company WITH (NOLOCK)
     WHERE comp_CompanyID = @CompanyID;

    DECLARE @AllocatedUnits int
        
    SELECT @AllocatedUnits = SUM(prun_UnitsAllocated) 
      FROM PRServiceUnitAllocation WITH (NOLOCK)
     WHERE GETDATE() BETWEEN prun_StartDate AND prun_ExpirationDate
       AND prun_HQID = @HQID;

    IF @AllocatedUnits IS NULL SET @AllocatedUnits=0

    RETURN @AllocatedUnits
END
GO






/**
Returns a dataset for the Alerts listing on the website.  This allows the
website to apply custom sorting.
**/
If Exists (Select name from sysobjects where name = 'ufn_GetAUSListing' and type in (N'FN', N'IF', N'TF')) Drop Function dbo.ufn_GetAUSListing
Go

CREATE FUNCTION dbo.ufn_GetAUSListing(@PersonID int, @CompanyID int)  
RETURNS @AUSListing table (
    prau_AUSID int,
    DisplayOnHomePage nchar(1),
    BBID int, 
    TRADENAME varchar(500), 
    comp_PRIndustryType varchar(40),
    CITY varchar(100), 
    STATE varchar(100), 
    COUNTRY varchar(100), 
    CurrentRating varchar(100), 
    PreviousRating varchar(100),
    LastModified datetime, 
    HQBR char(1), 
    LastFinancialDate datetime) AS  
BEGIN 

-- Build our initial list
-- FinancialStatementDate is now being pulled from the company field which should always be up-to-date
INSERT INTO @AUSListing (
    prau_AUSID,
    DisplayOnHomePage,
    BBID,
    TRADENAME,
    comp_PRIndustryType,
    CITY,
    STATE,
    COUNTRY,
    HQBR,
    LastFinancialDate)
SELECT prau_AUSID,
    prau_ShowOnHomePage,
    prau_MonitoredCompanyID,
    comp_PRCorrTradestyle,
    comp_PRIndustryType,
    prci_City,
    prst_Abbreviation,
    prcn_Country,
    CASE WHEN comp_PRHQId > 0 THEN 'B' ELSE 'H' END,
    comp_PRFinancialStatementDate
  FROM PRAUS 
       INNER JOIN Company on prau_MonitoredCompanyID = comp_CompanyID
       INNER JOIN PRCity on comp_PRListingCityID = prci_CityID
       INNER JOIN PRState on prci_StateID = prst_StateID
       INNER JOIN PRCountry on prst_CountryID = prcn_CountryID
 WHERE prau_Deleted IS NULL
   AND comp_Deleted IS NULL
   AND comp_PRListingStatus IN ('L', 'N3', 'N5', 'N6')
   AND prau_CompanyID = @CompanyID
   AND prau_PersonID = @PersonID;
   
-- Go get our current rating
UPDATE @AUSListing
   SET CurrentRating = prra_RatingLine,
       LastModified = prra_Date
  FROM @AUSListing T1 
       INNER JOIN vPRCompanyRating on BBID = prra_CompanyId
 WHERE prra_Current = 'Y'

-- Go get our previous rating
UPDATE @AUSListing
   SET PreviousRating = prra_RatingLine
  FROM @AUSListing T1, 
       vPRCompanyRating
 WHERE BBID = prra_CompanyID
   AND prra_RatingID = (SELECT MAX(prra_RatingId) FROM vPRCompanyRating WHERE prra_Date < T1.LastModified AND prra_CompanyID=T1.BBID)

RETURN
END
Go

/**
Returns the current AUS settings for the specifed person and company
**/
If Exists (Select name from sysobjects where name = 'ufn_GetAUSSettings' and type in (N'FN', N'IF', N'TF')) Drop Function dbo.ufn_GetAUSSettings
Go

CREATE FUNCTION dbo.ufn_GetAUSSettings(@PersonID int, @CompanyID int)  
RETURNS @AUSSettings table (
    peli_PersonLinkID int,
    peli_PRAUSReceiveMethod nvarchar(40),
    peli_PRAUSChangePreference nvarchar(40)) AS  
BEGIN 

    INSERT INTO @AUSSettings
    SELECT peli_PersonLinkID,
           peli_PRAUSReceiveMethod,
           peli_PRAUSChangePreference
      FROM Person_Link WITH (NOLOCK)
     WHERE peli_PersonID = @PersonID
       AND peli_CompanyID = @CompanyID
       AND peli_PRStatus = '1'; -- Active;

    RETURN;
END
Go

/**
Determines if the specified company is eligible to receive a business
report survey.
Defect #2343.
This function enables/disables the survey section on the business report.
We'll be emailing surveys now, and will not include them in the business report.
See version 139, 1/7/09 for the original code.
**/
If Exists (Select name from sysobjects where name = 'ufn_IsEligibleForBRSurvey' and type in (N'FN', N'IF', N'TF')) Drop Function dbo.ufn_IsEligibleForBRSurvey
Go

CREATE FUNCTION dbo.ufn_IsEligibleForBRSurvey(@CompanyID int)  
RETURNS int AS  
BEGIN 
    RETURN 0
END
Go


/**
Determines if the specified company has an active, primary service record.
**/

If Exists (Select name from sysobjects where name = 'ufn_IsActiveMember' and type in (N'FN', N'IF', N'TF')) Drop Function dbo.ufn_IsActiveMember
Go

CREATE FUNCTION [dbo].[ufn_IsActiveMember](@CompanyId int)  
RETURNS int AS  
BEGIN 

    DECLARE @Count int

    SELECT @Count = COUNT(1)
      FROM PRService
     WHERE prse_CompanyID = @CompanyId
       AND prse_Primary = 'Y';
    
    IF @Count = 0 BEGIN
        RETURN 0
    END 
    
    RETURN 1
END
Go


/*    
   ufn_GetPRCoSpecialistUserId:
   
   Returns the specialist user id for the specified company.
   Specialist Id Types are:
    0: prci_RatingUserId
    1: prci_InsideSalesRepId
    2: prci_FieldSalesRepId
    3: prci_ListingSpecialistId
    4: prci_CustomerServiceId
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetPRCoSpecialistUserId]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    drop function [dbo].[ufn_GetPRCoSpecialistUserId]
GO
CREATE FUNCTION dbo.ufn_GetPRCoSpecialistUserId(@CompanyID int, @TypeId tinyint)
RETURNS int  AS  
BEGIN 

    DECLARE @UserID int

	SELECT @UserID = case
        WHEN @TypeId = 0 THEN CASE comp_PRIndustryType WHEN 'L' THEN prci_LumberRatingUserId ELSE prci_RatingUserId END
        WHEN @TypeId = 1 THEN CASE comp_PRIndustryType WHEN 'L' THEN prci_LumberInsideSalesRepId ELSE prci_InsideSalesRepId END
        WHEN @TypeId = 2 THEN CASE comp_PRIndustryType WHEN 'L' THEN prci_LumberFieldSalesRepId ELSE prci_FieldSalesRepId END
        WHEN @TypeId = 3 THEN CASE comp_PRIndustryType WHEN 'L' THEN prci_LumberListingSpecialistId ELSE prci_ListingSpecialistId END
        WHEN @TypeId = 4 THEN CASE comp_PRIndustryType WHEN 'L' THEN prci_LumberCustomerServiceId ELSE prci_CustomerServiceId END
        ELSE NULL
      END
      FROM Company  WITH (NOLOCK)
           INNER JOIN PRCity WITH (NOLOCK) ON PRCi_CityID = Comp_PRListingCityID
     WHERE comp_CompanyID=@CompanyID;

    RETURN @UserID
END
Go

/*
    Gets the user id for a specific workflow action
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetWorkflowUserId]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    drop function [dbo].[ufn_GetWorkflowUserId]
GO
CREATE FUNCTION dbo.ufn_GetWorkflowUserId(@Type varchar(255))
RETURNS int  AS  
BEGIN 

    DECLARE @UserId int
    IF (@Type = 'File_OpenFile')
    begin
        -- KLZ per item 7 of Updates to Collection File Workflow Doc (4/12/06)
        SELECT @UserId = user_userid from users where user_logon = 'klz'
    end
    ELSE IF (@Type = 'File_OpinionMonitor')
    begin
        SELECT @UserId = user_userid from users where user_logon = 'reg'
    end 
    ELSE IF (@Type = 'File_RDAMonitor')
    begin
        -- Request Dispute Assistance monitor userid
        SELECT @UserId = user_userid from users where user_logon = 'reg'
    end
    return @UserId
END
GO



/**
Builds the item text for Credit Sheet Item text
**/
If Exists (Select name from sysobjects where name = 'ufn_GetItem2' and type in (N'FN', N'IF', N'TF')) Drop Function dbo.ufn_GetItem2
Go

CREATE FUNCTION [dbo].[ufn_GetItem2] (
    @prcs_CreditSheetId int, 
    @FormattingStyle tinyint = 0, -- 0: <br/> 1: CHR(10) 2: CHR(10 & 13),
    @IncludeBBHeader bit,
    @LineSize int,
    @IncludeTags bit = 0
)
RETURNS varchar(max)
AS
BEGIN
    DECLARE @RetValue varchar(max)

    DECLARE @prcs_CompanyId int
    DECLARE @prcs_Tradestyle varchar(420)
    DECLARE @prcs_Parenthetical varchar(1000)
    DECLARE @prcs_Numeral varchar(75)   
    DECLARE @prcs_Change varchar(4000)
    DECLARE @prcs_RatingChangeVerbiage varchar(1000)
    DECLARE @RatingBlock varchar(1100)
    DECLARE @prcs_RatingValue varchar(75)
    DECLARE @prcs_PreviousRatingValue varchar(75)
    DECLARE @prcs_Notes varchar(1000)
    
    DECLARE @LineBreakChar varchar(50)
    DECLARE @Space varchar(10) 
    DECLARE @Indent1 varchar(40), @Indent2 varchar(40), @Indent3 varchar(40), @PaidIndent2 varchar(40)  
    
    SET @RetValue = ''
    SET @Space = ' '
    SET @LineBreakChar = CHAR(10)

    SET @Indent1 = @Space
    SET @Indent2 = @Space + @Space
    SET @Indent3 = @Space + @Space + @Space 

    SELECT @prcs_CompanyId = prcs_CompanyId,
           @prcs_Tradestyle = prcs_Tradestyle,
           @prcs_Parenthetical = prcs_Parenthetical,
           @prcs_Numeral = prcs_Numeral,
           @prcs_Change = prcs_Change,
           @prcs_RatingChangeVerbiage = prcs_RatingChangeVerbiage,
           @prcs_RatingValue = prcs_RatingValue,
           @prcs_PreviousRatingValue = prcs_PreviousRatingValue,
           @prcs_Notes = prcs_Notes
      FROM PRCreditSheet WITH (NOLOCK)
     WHERE prcs_CreditSheetId = @prcs_CreditSheetId;

    IF (@IncludeBBHeader = 1) BEGIN
        SET @RetValue =  @Indent2 + 'BB #' + Convert(varchar(15), @prcs_CompanyId)

        IF (CHARINDEX('.', @prcs_Tradestyle, LEN(@prcs_Tradestyle)) = 0) BEGIN
            SET @prcs_Tradestyle = @prcs_Tradestyle + '.'
        END

        SET @RetValue = @RetValue + @LineBreakChar + dbo.ufn_indentListingBlock(
                dbo.ufn_ApplyListingLineBreaks3(@prcs_Tradestyle + Coalesce(@prcs_Numeral,''),
                @LineBreakChar, @LineSize), @LineBreakChar, @Indent3, 1)
    END ELSE BEGIN
        IF @prcs_Numeral IS NOT NULL
        BEGIN
            SET @RetValue = dbo.ufn_indentListingBlock(
                dbo.ufn_ApplyListingLineBreaks2(@prcs_Numeral,@LineBreakChar, @LineSize),
                @LineBreakChar, @Indent3, 1)

        END
    END 

    IF LEN(@prcs_Parenthetical) > 0
    BEGIN

		-- If our data already ends with a line break char, then strip it off.
		IF CHARINDEX(@LineBreakChar, @prcs_Parenthetical) = LEN(@prcs_Parenthetical) BEGIN
			SET @prcs_Parenthetical = SUBSTRING(@prcs_Parenthetical, 1, LEN(@prcs_Parenthetical) - 1)
		END

        IF (LEN(@RetValue) > 0) BEGIN
            SET @RetValue = @RetValue + @LineBreakChar
        END
        SET @RetValue = @RetValue + 
         COALESCE(dbo.ufn_indentListingBlock(
         dbo.ufn_ApplyListingLineBreaks3(@prcs_Parenthetical,@LineBreakChar, @LineSize),
         @LineBreakChar, @Indent2, 0), '') 
    END

    IF LEN(@prcs_Change) > 0  
    BEGIN
    
		SET @prcs_Change = dbo.ufn_PrepareCreditSheetText(@prcs_Change)
        
        IF (LEN(@RetValue) > 0) BEGIN
            SET @RetValue = @RetValue + @LineBreakChar
        END

		-- If our data already ends with a line break char, then strip it off.
		IF CHARINDEX(@LineBreakChar, @prcs_Change) = LEN(@prcs_Change) BEGIN
			SET @prcs_Change = SUBSTRING(@prcs_Change, 1, LEN(@prcs_Change) - 1)
		END


        SET @RetValue = @RetValue + 
         COALESCE(dbo.ufn_indentListingBlock(
         dbo.ufn_ApplyListingLineBreaks3(@prcs_Change,@LineBreakChar, @LineSize),
         @LineBreakChar, @Indent2, 0), '') 
    END

    SET @RatingBlock = COALESCE(@prcs_RatingChangeVerbiage,'')
    IF @prcs_RatingValue IS NOT NULL BEGIN
    SET @RatingBlock = @RatingBlock + ' ... ' + @prcs_RatingValue
    END
    IF @RatingBlock <> '' BEGIN
       IF (LEN(@RetValue) > 0) BEGIN
          SET @RetValue = @RetValue + @LineBreakChar
    END
    SET @RetValue = @RetValue + 
         dbo.ufn_indentListingBlock(
         dbo.ufn_ApplyListingLineBreaks3(@RatingBlock, @LineBreakChar, @LineSize),
              @LineBreakChar, @Indent1, 0) 
    END

    IF @prcs_PreviousRatingValue IS NOT NULL
    BEGIN
        IF (LEN(@RetValue) > 0) BEGIN
            SET @RetValue = @RetValue + @LineBreakChar
        END

        SET @RetValue = @RetValue + 
            dbo.ufn_indentListingBlock('Previous ' 
            + @prcs_PreviousRatingValue, @LineBreakChar, @Indent1, 0)
    END

    IF @prcs_Notes IS NOT NULL
    BEGIN
        IF (LEN(@RetValue) > 0) BEGIN
            SET @RetValue = @RetValue + @LineBreakChar
        END

        SET @RetValue = @RetValue + COALESCE(dbo.ufn_indentListingBlock(
        dbo.ufn_ApplyListingLineBreaks3(@prcs_Notes, @LineBreakChar, @LineSize),
        @LineBreakChar, @Indent3, 0), '')
    END


    -- add a final line break
    IF @RetValue IS NOT NULL
    BEGIN
        SET @RetValue = @RetValue + @LineBreakChar
    END 
    
	-- Tags are no longer needed, but exist in the 
    -- old data, so always strip them.
    SET @RetValue = REPLACE(@RetValue, '<B>', '')

/*
    IF @IncludeTags = 0 BEGIN
        SET @RetValue = REPLACE(@RetValue, '<B>', '')
    END ELSE BEGIN
        IF (@FormattingStyle = 0) BEGIN
            SET @RetValue = REPLACE(@RetValue, '<B>', '&lt;b&gt;')
        END 
    END
*/

    -- change line breaks and spaces as appropriate for formatting style
    IF (@FormattingStyle = 0) BEGIN
        SET @RetValue = REPLACE(@RetValue, @LineBreakChar, '<br/>')
        SET @RetValue = REPLACE(@RetValue, @Space, '&nbsp;')
    END ELSE IF (@FormattingStyle = 2) BEGIN
        SET @RetValue = REPLACE(@RetValue, @LineBreakChar, CHAR(13)+CHAR(10))
        END

    RETURN @RetValue
END
Go


/**
Builds the item text for Credit Sheet Items EBB Update
**/
If Exists (Select name from sysobjects where name = 'ufn_GetItem' and type in (N'FN', N'IF', N'TF')) Drop Function dbo.ufn_GetItem
Go

CREATE FUNCTION [dbo].[ufn_GetItem] (
    @prcs_CreditSheetId int, 
    @FormattingStyle tinyint = 0, -- 0: <br/> 1: CHR(10) 2: CHR(10 & 13),
    @IncludeBBHeader bit,
    @LineSize int
)
RETURNS varchar(6000)
AS
BEGIN
    RETURN dbo.ufn_GetItem2(@prcs_CreditSheetId, @FormattingStyle, @IncludeBBHeader, @LineSize, 0)
END
Go

/**
Returns the data for the specified company and business event type.
**/
If Exists (Select name from sysobjects where name = 'ufn_GetBusinessEventDate' and type in (N'FN', N'IF', N'TF')) Drop Function dbo.ufn_GetBusinessEventDate
Go

CREATE FUNCTION [dbo].[ufn_GetBusinessEventDate] (
    @CompanyID int, 
    @BusinessEventTypeID int,
    @ReturnMin bit = 0, -- 0: MIN 1: MAX
    @ReturnIfNotFound tinyint = 0,  -- 0: NULL, 1: MIN Event Date for Company, 2: MAX Event Date for Company, 3: SpecifiedValue
    @DefaultValue datetime = NULL
)
RETURNS datetime
AS
BEGIN

DECLARE @EventDate datetime

IF @ReturnMin = 0 BEGIN
    SELECT @EventDate = MIN(prbe_EffectiveDate)
      FROM PRBusinessEvent WITH (NOLOCK)
     WHERE prbe_BusinessEventTypeID = @BusinessEventTypeID
       AND prbe_CompanyID = @CompanyID;
END ELSE BEGIN
    SELECT @EventDate = MAX(prbe_EffectiveDate)
      FROM PRBusinessEvent WITH (NOLOCK)
     WHERE prbe_BusinessEventTypeID = @BusinessEventTypeID
       AND prbe_CompanyID = @CompanyID;
END


IF @EventDate IS NULL BEGIN
    IF @ReturnIfNotFound = 1 BEGIN
        SELECT @EventDate = MIN(prbe_EffectiveDate)
          FROM PRBusinessEvent WITH (NOLOCK)
         WHERE prbe_CompanyID = @CompanyID;
    END

    IF @ReturnIfNotFound = 2 BEGIN
        SELECT @EventDate = MAX(prbe_EffectiveDate)
          FROM PRBusinessEvent WITH (NOLOCK)
         WHERE prbe_CompanyID = @CompanyID;
    END

    IF @ReturnIfNotFound = 3 BEGIN
        SET @EventDate = @DefaultValue
    END
END

RETURN @EventDate
END
GO


/**
Returns the data for the specified company and business event type.
**/
If Exists (Select name from sysobjects where name = 'ufn_GetBusinessEventDateDisplayed' and type in (N'FN', N'IF', N'TF')) Drop Function dbo.ufn_GetBusinessEventDateDisplayed
Go

CREATE FUNCTION [dbo].[ufn_GetBusinessEventDateDisplayed] (
    @CompanyID int, 
    @BusinessEventTypeID int,
    @ReturnMin bit = 0, -- 0: MIN 1: MAX
    @ReturnIfNotFound tinyint = 0,  -- 0: NULL, 1: MIN Event Date for Company, 2: MAX Event Date for Company, 3: SpecifiedValue
    @DefaultValue varchar(500) = NULL
)
RETURNS varchar(500)
AS
BEGIN

DECLARE @EventDate varchar(500)

IF @ReturnMin = 0 BEGIN
    SELECT @EventDate = MIN(prbe_DisplayedEffectiveDate)
      FROM PRBusinessEvent WITH (NOLOCK)
     WHERE prbe_BusinessEventTypeID = @BusinessEventTypeID
       AND prbe_CompanyID = @CompanyID;
END ELSE BEGIN
    SELECT @EventDate = MAX(prbe_DisplayedEffectiveDate)
      FROM PRBusinessEvent WITH (NOLOCK)
     WHERE prbe_BusinessEventTypeID = @BusinessEventTypeID
       AND prbe_CompanyID = @CompanyID;
END


IF @EventDate IS NULL BEGIN
    IF @ReturnIfNotFound = 1 BEGIN
        SELECT @EventDate = MIN(prbe_DisplayedEffectiveDate)
          FROM PRBusinessEvent WITH (NOLOCK)
         WHERE prbe_CompanyID = @CompanyID;
    END

    IF @ReturnIfNotFound = 2 BEGIN
        SELECT @EventDate = MAX(prbe_DisplayedEffectiveDate)
          FROM PRBusinessEvent WITH (NOLOCK)
         WHERE prbe_CompanyID = @CompanyID;
    END

    IF @ReturnIfNotFound = 3 BEGIN
        SET @EventDate = @DefaultValue
    END
END

RETURN @EventDate
END
GO


/**
    This function is used by the prco transaction (auditing) triggers to determine if an
    Accpac date field is considered updated.  Accpac stores null dates as '12/30/1899' so 
    the standard Updated() statement does not work for determining if the value changed
**/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_IsAccpacDateUpdated]') 
    and xtype in (N'FN', N'IF', N'TF')) drop function [dbo].[ufn_IsAccpacDateUpdated]
GO
CREATE FUNCTION [dbo].[ufn_IsAccpacDateUpdated] ( 
    @dtInitial datetime,
    @dtCurrent datetime 
)
RETURNS bit
AS
BEGIN
    Declare @sInitial varchar(20)
    Declare @sCurrent varchar(20)
    SET @sInitial = convert(varchar, @dtInitial, 101)
    SET @sCurrent = convert(varchar, @dtCurrent, 101)
    
    -- check null options; accpac null is 12/30/1899
    IF (@dtInitial is null and @dtCurrent is null)
        RETURN 0
    IF (@dtInitial is null and @sCurrent = '12/30/1899')
        RETURN 0
    IF (@sInitial = '12/30/1899' and @dtCurrent is null)
        RETURN 0

    IF (@dtInitial = @dtCurrent)
        RETURN 0

    RETURN 1
END
GO



/**
    This function is used by the prco transaction (auditing) triggers.  Accpac stores 
    null dates as '12/30/1899', which we don't like.  This function returns NULL if
    '12/30/1899' is found.
**/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetAccpacDate]') 
    and xtype in (N'FN', N'IF', N'TF')) drop function [dbo].[ufn_GetAccpacDate]
GO
CREATE FUNCTION [dbo].[ufn_GetAccpacDate] ( 
    @dtCurrent datetime 
)
RETURNS datetime
AS
BEGIN
    
    DECLARE @ReturnDate datetime
    SET @ReturnDate = @dtCurrent

    IF (@dtCurrent IS NOT NULL) BEGIN

        DECLARE @sCurrent varchar(20)
        SET @sCurrent = convert(varchar, @dtCurrent, 101)
    
        IF (@sCurrent = '12/30/1899') BEGIN
            SET @ReturnDate = NULL
        END
    END

    RETURN @ReturnDate
END
GO


/*    
   Determines if the specified values are equal
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_AreValuesEqual]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    drop function [dbo].[ufn_AreValuesEqual]
GO

CREATE FUNCTION dbo.ufn_AreValuesEqual(@Value1 varchar(1000), 
                                       @Value2 varchar(1000))
RETURNS bit  AS  
BEGIN 
    
    DECLARE @bAreEqual bit
    SET @bAreEqual = 1

    IF (@Value1 IS NULL AND @Value2 IS NOT NULL) BEGIN
        SET @bAreEqual = 0
    END

    IF (@Value2 IS NULL AND @Value1 IS NOT NULL) BEGIN
        SET @bAreEqual = 0
    END


    IF (@Value1 != @Value2) BEGIN
        SET @bAreEqual = 0
    END

    RETURN @bAreEqual
END
Go


/*    
   Returns the date of the current ownership for the
   specified company
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetDateOfCurrentOwnership]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    drop function [dbo].[ufn_GetDateOfCurrentOwnership]
GO

CREATE FUNCTION dbo.ufn_GetDateOfCurrentOwnership(@CompanyID int)
RETURNS datetime  AS  
BEGIN 
    
    DECLARE @CurrentOwnership DateTime

    DECLARE @IndOwnershipSale DateTime
    DECLARE @Divesture DateTime
    DECLARE @OwnershipChange DateTime

    DECLARE @DefaultDate DateTime
    SET @DefaultDate = '1800-01-01'

    SET @IndOwnershipSale = dbo.ufn_GetBusinessEventDate(@CompanyID, 10, 1, 3, @DefaultDate);
    SET @Divesture = dbo.ufn_GetBusinessEventDate(@CompanyID, 11    , 1, 3, @DefaultDate);
    SET @OwnershipChange = dbo.ufn_GetBusinessEventDate(@CompanyID, 38, 1, 3, @DefaultDate);

    -- We want to use the most recent of our 
    -- three dates.
    SET @CurrentOwnership = @IndOwnershipSale;

    IF @Divesture > @CurrentOwnership BEGIN
        SET @CurrentOwnership = @Divesture
    END

    IF @OwnershipChange > @CurrentOwnership BEGIN
        SET @CurrentOwnership = @OwnershipChange
    END

    IF @CurrentOwnership = @DefaultDate BEGIN
        SET @CurrentOwnership = dbo.ufn_GetBusinessEventDate(@CompanyID, 9, 0, 0, NULL);
    END

    RETURN @CurrentOwnership
END
Go


/*    
   Returns the CompanyIDs for those that are considered to be in
   the specified sales territory.
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetCompaniesInSalesTerritory]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    drop function [dbo].[ufn_GetCompaniesInSalesTerritory]
GO

CREATE FUNCTION dbo.ufn_GetCompaniesInSalesTerritory(@SalesTerritory varchar(40))
RETURNS @SelectedCompanyIDs table (CompanyID int) 
AS  BEGIN 

    -- Go get those companies that have a phsycial
    -- published address in our territory.
    INSERT INTO @SelectedCompanyIDs (CompanyID)
    SELECT DISTINCT adli_CompanyID
      FROM Address WITH (NOLOCK)
           INNER JOIN Address_Link WITH (NOLOCK) on addr_AddressID = adli_AddressID
           INNER JOIN PRCity WITH (NOLOCK) ON addr_PRCityID = prci_CityID
     WHERE prci_SalesTerritory = @SalesTerritory
       AND addr_PRPublish = 'Y'
       AND adli_Type = 'PH';


    -- Go get those Companies that do not have a known address,
    -- but whose listing city is in our territory.
    INSERT INTO @SelectedCompanyIDs (CompanyID)
    SELECT comp_CompanyID
      FROM Company WITH (NOLOCK)
           INNER JOIN PRCity WITH (NOLOCK) ON comp_PRListingCityID = prci_CityID
     WHERE prci_SalesTerritory = @SalesTerritory
       AND comp_CompanyID NOT IN (SELECT DISTINCT adli_CompanyID
                                    FROM Address_Link);

    -- Go get those companies that have addresses in our territory,
    -- that we don't already have, and that don't a published physical
    -- address in another territory.
    INSERT INTO @SelectedCompanyIDs (CompanyID)
    SELECT DISTINCT adli_CompanyID
      FROM Address WITH (NOLOCK)
           INNER JOIN Address_Link WITH (NOLOCK) on addr_AddressID = adli_AddressID
           INNER JOIN PRCity WITH (NOLOCK) ON addr_PRCityID = prci_CityID
     WHERE prci_SalesTerritory = @SalesTerritory
       AND adli_CompanyID NOT IN (SELECT CompanyID from @SelectedCompanyIDs) -- Exclude those we already have
       AND adli_CompanyID NOT IN (SELECT adli_CompanyID
                                    FROM Address
                                         INNER JOIN Address_Link on addr_AddressID = adli_AddressID
                                         INNER JOIN PRCity ON addr_PRCityID = prci_CityID
                                   WHERE prci_SalesTerritory <> @SalesTerritory
                                     AND addr_PRPublish = 'Y'
                                     AND adli_Type = 'PH'); -- Companies that have other published physical addresses in other territories


    RETURN
END
Go

/**
Determines sales territory for a company
**/
If Exists (Select name from sysobjects where name = 'ufn_GetCompanySalesTerritory' and type in (N'FN', N'IF', N'TF')) 
    Drop Function dbo.ufn_GetCompanySalesTerritory
Go
CREATE FUNCTION [dbo].[ufn_GetCompanySalesTerritory](@CompanyId int)  
RETURNS nvarchar(40) AS  
BEGIN 

DECLARE @SalesTerritory nvarchar(40)

-- get territory from first listed physical address city
SELECT TOP 1 @SalesTerritory = prci_SalesTerritory
  FROM Address WITH (NOLOCK)
       INNER JOIN Address_Link WITH (NOLOCK) on addr_AddressID = adli_AddressID
       INNER JOIN PRCity WITH (NOLOCK) ON addr_PRCityID = prci_CityID
  WHERE addr_PRPublish = 'Y'
  AND adli_Type = 'PH' AND adli_CompanyId = @CompanyId

IF @SalesTerritory IS NULL BEGIN
    -- If no addresses, get territory from listing city 
    IF @CompanyId NOT IN (SELECT DISTINCT adli_CompanyID FROM Address_Link) BEGIN
        SELECT @SalesTerritory = prci_SalesTerritory
          FROM Company WITH (NOLOCK)
           INNER JOIN PRCity WITH (NOLOCK) ON comp_PRListingCityID = prci_CityID
          WHERE comp_CompanyId = @CompanyId
    END ELSE BEGIN
    -- otherwise, get territory from first address city
        SELECT TOP 1 @SalesTerritory = prci_SalesTerritory
        FROM Address
            INNER JOIN Address_Link WITH (NOLOCK) on addr_AddressID = adli_AddressID
                INNER JOIN PRCity WITH (NOLOCK) ON addr_PRCityID = prci_CityID
        WHERE adli_CompanyId = @CompanyId
    END
END

RETURN @SalesTerritory

END

Go

/* 
    Returns the previous rating for the specified company
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetPreviousRating]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    drop function [dbo].[ufn_GetPreviousRating]
GO

CREATE FUNCTION dbo.ufn_GetPreviousRating(@CompanyID int)
RETURNS varchar(150) AS  
BEGIN 
    DECLARE @PreviousRating as varchar(150)
    
    SELECT @PreviousRating = PreviousRating
      FROM (
    SELECT TOP 1 prra_RatingLine AS PreviousRating
      FROM vPRCompanyRating
     WHERE prra_Current IS NULL
       AND prra_CompanyID = @CompanyID
    ORDER BY prra_Date desc) T1;

    RETURN @PreviousRating
END
GO



/*    
   ufn_GetSystemUserId:
   
   Returns the mock id for an internal user.
   Specialist Id Types are:
    0: BBS Interface
    1: Web Site
    2: Reports
    3: Workflow Generator/Creator
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetSystemUserId]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    drop function [dbo].[ufn_GetSystemUserId]
GO
CREATE FUNCTION dbo.ufn_GetSystemUserId(@TypeId tinyint)
RETURNS int  AS  
BEGIN 

    DECLARE @UserID int

    SET    @UserID = CASE @TypeId
        WHEN 0 THEN -100
        WHEN 1 THEN -200
        WHEN 2 THEN -300
        WHEN 3 THEN -400
        ELSE NULL
    END


    RETURN @UserID
END
Go



/* 
   Returns the UserID of the Survey Person
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetSurveyPersonID]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    drop function [dbo].[ufn_GetSurveyPersonID]
GO
CREATE FUNCTION dbo.ufn_GetSurveyPersonID()
RETURNS int  AS  
BEGIN 
    DECLARE @SurveyPersonID int

    SELECT @SurveyPersonID = cast(capt_US as varchar) -- cannot convert directly to int
      FROM CRM.dbo.custom_captions
     WHERE capt_family = 'AssignmentUserID' 
       AND capt_code = 'Survey';

    RETURN @SurveyPersonID
END
Go


/* 
   Returns the Email address of the rating analyst
   for the specified company.
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetRatingAnalystEmail]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    drop function [dbo].[ufn_GetRatingAnalystEmail]
GO
CREATE FUNCTION dbo.ufn_GetRatingAnalystEmail(@CompanyID int)
RETURNS varchar(255)  AS  
BEGIN 

    DECLARE @Email varchar(255)

    SELECT @Email = user_EmailAddress
       FROM CRM.dbo.Company WITH (NOLOCK) 
           INNER JOIN CRM.dbo.PRCity WITH (NOLOCK) ON PRCi_CityID = Comp_PRListingCityID
           INNER JOIN CRM.dbo.Users WITH (NOLOCK) ON PRCi_RatingUserID = user_UserID
     WHERE comp_CompanyID = @CompanyID;

    RETURN @Email
END
Go


If Exists (Select name from sysobjects where name = 'GetLowerAlpha' and type='FN') Drop Function dbo.GetLowerAlpha
Go

/**
This is used for duplicate name checks making them case
insensitive and ignoring puncuation.
**/
CREATE FUNCTION dbo.GetLowerAlpha(@sText varchar(8000))
RETURNS varchar(8000)
AS
BEGIN

DECLARE @AlphaOnly varchar(8000), @CurrentChar varchar(1)
DECLARE @idx smallint,
          @bcontinue bit,
        @Ascii int

SET @idx = 0
SET @sText = LTrim(RTrim(@sText))
SET @sText = Lower(@sText)
SET @bcontinue = 1
SET @AlphaOnly = '';

While (@idx <= DataLength(@sText))
Begin        
    Set @CurrentChar = SubString(@sText, @idx, 1)
    Set @Ascii = ASCII(@CurrentChar)

    if (@Ascii >= ASCII('a')) Begin
        if (@Ascii <= ASCII('z')) Begin
            SET @AlphaOnly = @AlphaOnly + @CurrentChar
        end 
    end

    if (@Ascii >= ASCII('0')) Begin
        if (@Ascii <= ASCII('9')) Begin
            SET @AlphaOnly = @AlphaOnly + @CurrentChar
        end 
    end

    SET @idx = @idx + 1
End

Return(@AlphaOnly)
End 
Go




/* 
   Returns the inside sales rep for the specified address
   information.
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetInsideSalesRepForAddress]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    drop function [dbo].[ufn_GetInsideSalesRepForAddress]
GO
CREATE FUNCTION dbo.ufn_GetInsideSalesRepForAddress(@City varchar(100), @State varchar(100))
RETURNS int  AS  
BEGIN 

    DECLARE @InsideSalesRepIT int
    
    SELECT @InsideSalesRepIT = prci_InsideSalesRepID
      FROM CRM.dbo.PRCity 
           INNER JOIN CRM.dbo.PRState on prci_StateID = prst_StateID
     WHERE dbo.GetLowerAlpha(prci_City) = dbo.GetLowerAlpha(@City)
       AND dbo.GetLowerAlpha(prst_State) = dbo.GetLowerAlpha(@State);
 
    IF (@InsideSalesRepIT IS NULL) BEGIN
        SELECT @InsideSalesRepIT = cast(capt_US as varchar) -- cannot convert ntext directly to int
          FROM CRM.dbo.custom_captions
         WHERE capt_family = 'AssignmentUserID' 
           AND capt_code = 'UnknownAlaCarteOrder';
    END
    
    RETURN @InsideSalesRepIT
END
Go








if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_FormatUserName]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    drop Function [dbo].[ufn_FormatUserName]
GO

CREATE FUNCTION [dbo].[ufn_FormatUserName](@UserId Int)  
RETURNS varchar(100) AS
BEGIN
    DECLARE @fullname varchar(100)  
    SELECT @fullname = COALESCE(RTrim(User_FirstName) + ' ','') + RTrim(User_LastName) 
     FROM Users WHERE user_userid = @UserId
    RETURN @fullname
END
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetCapt_US]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    drop Function [dbo].[ufn_GetCapt_US]
GO

CREATE FUNCTION [dbo].[ufn_GetCapt_US](@FamilyType nchar(12), @Family nchar(30),
 @Code nchar(30))  
RETURNS nvarchar(255) AS
BEGIN
    DECLARE @capt_US nvarchar(255)  
    select @capt_US = capt_US from custom_captions 
     where capt_FamilyType = @FamilyType
     and capt_Family = @Family
     and capt_Code = @Code
    RETURN @capt_US
END
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_FormatPersonById]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    drop Function [dbo].[ufn_FormatPersonById]
GO

CREATE FUNCTION [dbo].[ufn_FormatPersonById](@personid int)
RETURNS varchar(150) AS  
BEGIN
    DECLARE @Person varchar(150)

    SELECT @Person = dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_MiddleName, pers_PRNickname1, pers_Suffix)
      FROM Person WITH (NOLOCK)
     WHERE pers_PersonId = @personid;

    Return @Person
END
GO


/*
    Returns how much of the specified company is owned (or at least known to be).
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetOwnershipPercentage]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    drop Function [dbo].[ufn_GetOwnershipPercentage]
GO

CREATE FUNCTION [dbo].[ufn_GetOwnershipPercentage](@CompanyID int)
RETURNS Float AS  
BEGIN

    DECLARE @Return Float
    SET @Return = 0

    -- Companies
    SELECT @Return = @Return + ISNULL(SUM(prcr_OwnershipPct), 0)
      FROM PRCompanyRelationship
     WHERE prcr_RightCompanyId = @CompanyID
       AND prcr_Type IN (27, 28)
       AND prcr_Active = 'Y'
       AND prcr_Deleted IS NULL;

    -- Persons
    SELECT @Return = @Return + ISNULL(SUM(peli_PRPctOwned), 0)
      FROM Person_Link
     WHERE peli_PRStatus IN ('1', '2')
       AND PeLi_CompanyID = @CompanyID
       AND PeLi_Deleted IS NULL;

    -- Unattributed Ownership
    SELECT @Return = @Return + ISNULL(comp_PRUnattributedOwnerPct, 0)
      FROM Company
     WHERE Comp_CompanyId = @CompanyID;

    RETURN @Return
END
GO



/**
Returns the next ID for the specified table
**/
If Exists (Select name from sysobjects where name = 'ufn_GetNextTableId' and type in (N'FN', N'IF', N'TF')) 
    Drop Function dbo.ufn_GetNextTableId
Go
CREATE FUNCTION [dbo].[ufn_GetNextTableId](@Table nchar(40))
RETURNS int 
AS  
BEGIN 
    declare @TableId int
    declare @NextId int

    select @TableId = Bord_TableId from custom_tables where Bord_Caption = @Table
    select @nextId = ID_nextID from sql_identity where ID_TableId = @TableId

    RETURN @NextId
END
Go



/**
Returns the specfied custom caption value or the default
value if NULL
**/
If Exists (Select name from sysobjects where name = 'ufn_GetCustomCaptionValueDefault' and type in (N'FN', N'IF', N'TF')) 
    Drop Function dbo.ufn_GetCustomCaptionValueDefault
Go
CREATE FUNCTION [dbo].[ufn_GetCustomCaptionValueDefault](@capt_family varchar(50), @capt_code varchar(50), @DefaultValue varchar(500))
RETURNS varchar(max) 
AS  
BEGIN 
    DECLARE @Return varchar(max)

    SELECT @Return = capt_us
      FROM Custom_Captions WITH (NOLOCK)
     WHERE capt_family = @capt_family
       AND capt_code = @capt_code;

    IF @Return IS NULL
        SET @Return = @DefaultValue

    RETURN @Return
END
Go


/**
  Returns a company formatted name of comp_name + comp_id + listing location
**/
If Exists (Select name from sysobjects where name = 'ufn_GetCompanyFullName' and type in (N'FN', N'IF', N'TF')) 
    Drop Function dbo.ufn_GetCompanyFullName
Go

CREATE FUNCTION [dbo].[ufn_GetCompanyFullName](@CompanyID int)
RETURNS varchar(500) 
AS  
BEGIN 
    DECLARE @Return varchar(500)

    SELECT @Return = comp_Name + ', ' + Cast(comp_Companyid as varchar(10))+ ' ('+ ISNULL(comp_PRType, '') + ')' + CASE WHEN CityStateCountryShort IS NULL THEN '' ELSE ', ' + CityStateCountryShort END
      FROM Company WITH (NOLOCK) 
           LEFT OUTER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID 
     WHERE comp_CompanyID =  @CompanyID;

    RETURN @Return
END
Go

/**
  Returns a table containing all customer service encounters made during the calender week prior to the specified date.
**/
If Exists (Select name from sysobjects where name = 'ufn_GetCSSurveyEncounters' and type in (N'FN', N'IF', N'TF')) 
    Drop Function dbo.ufn_GetCSSurveyEncounters
Go
CREATE FUNCTION [dbo].[ufn_GetCSSurveyEncounters](@SurveyDate datetime)  
RETURNS @CSSurveyEncounters table (
    ndx smallint identity,
    CompanyId int,
    UserId int,
    CallType char(1))
AS  
BEGIN 

-- determine start and end of last week
declare @TodayMidnight datetime
declare @FromDate datetime
declare @ThroughDate datetime
set @TodayMidnight = cast(convert(varchar,@SurveyDate,101) + ' 12:00:00 AM' as datetime)
set @FromDate = DateAdd(day,-(6 + datepart(weekday,@TodayMidnight)), @TodayMidnight)
set @ThroughDate = DateAdd(week,1,@FromDate)

-- query pool of company ID's from customer care cases,
-- verbal BR requests, phone interactions, phone transactions
insert into @CSSurveyEncounters (CompanyId, UserId, CallType)
select distinct case_PrimaryCompanyId as CompanyId, case_ClosedBy as UserId, 'H' as CallType
from Cases
where case_Closed >= @FromDate and case_Closed < @ThroughDate
and case_ProductArea <> 'AR'
union
select distinct prbr_RequestingCompanyId as CompanyId, prbr_CreatedBy as UserId, 'V' as CallType
from PRBusinessReportRequest 
where prbr_CreatedDate >= @FromDate and prbr_CreatedDate < @ThroughDate
and prbr_MethodSent = 'VBR'
union
select distinct cmli_comm_CompanyId as CompanyId, comm_CreatedBy as UserId, 'I' as CallType
from Communication
inner join Comm_Link on comm_communicationid = cmli_comm_communicationid
where comm_DateTime >=  @FromDate and comm_DateTime < @ThroughDate
and Comm_Action = 'PhoneIn'
and cmli_comm_CompanyId is not null
union
SELECT DISTINCT cmli_comm_CompanyId as CompanyId, comm_CreatedBy as UserId, 'I' as CallType
	FROM Communication WITH (NOLOCK)
	      INNER JOIN Comm_Link WITH (NOLOCK) on comm_communicationid = cmli_comm_communicationid
	WHERE comm_DateTime BETWEEN @FromDate AND @ThroughDate
	  AND Comm_Action = 'EmailIn'
	  AND cmli_comm_CompanyId IS NOT NULL
union
select distinct prtx_Companyid as CompanyId, prtx_CreatedBy as UserId, 'T' as CallType
from PRTransaction 
where prtx_CreatedDate >= @FromDate and prtx_CreatedDate < @ThroughDate
and prtx_NotificationType = 'P'
and prtx_CompanyId is not null
union
SELECT DISTINCT prtx_Companyid as CompanyId, prtx_CreatedBy as UserId, 'T' as CallType
	FROM PRTransaction WITH (NOLOCK)
	WHERE prtx_CreatedDate BETWEEN @FromDate AND @ThroughDate
	  AND prtx_NotificationType = 'E'
	  AND prtx_CompanyId IS NOT NULL

return
end
go




If Exists (Select name from sysobjects where name = 'ufn_GetAttentionLine' and type in (N'FN', N'IF', N'TF')) 
    Drop Function dbo.ufn_GetAttentionLine
Go

CREATE FUNCTION [dbo].[ufn_GetAttentionLine](@CompanyID int, @ItemCode varchar(40))
RETURNS varchar(500) 
AS  
BEGIN
    DECLARE @AttentionLine varchar(500)

    SELECT @AttentionLine = ISNULL('Attn: ' + dbo.ufn_FormatPerson(Pers_FirstName, Pers_LastName, Pers_MiddleName, Pers_PRNickname1, Pers_Suffix), prattn_CustomLine)
      FROM PRAttentionLine WITH (NOLOCK)
           LEFT OUTER JOIN Person WITH (NOLOCK) ON prattn_PersonID = pers_PersonID
     WHERE prattn_CompanyID = @CompanyID
       AND prattn_ItemCode = @ItemCode;

    RETURN @AttentionLine
END
Go

If Exists (Select name from sysobjects where name = 'ufn_GetAttentionLineByID' and type in (N'FN', N'IF', N'TF')) 
    Drop Function dbo.ufn_GetAttentionLineByID
Go

CREATE FUNCTION [dbo].[ufn_GetAttentionLineByID](@AttentionLineID int)
RETURNS varchar(500) 
AS  
BEGIN
    DECLARE @AttentionLine varchar(500)

    SELECT @AttentionLine = ISNULL('Attn: ' + dbo.ufn_FormatPerson(Pers_FirstName, Pers_LastName, Pers_MiddleName, Pers_PRNickname1, Pers_Suffix), prattn_CustomLine)
      FROM PRAttentionLine WITH (NOLOCK)
           LEFT OUTER JOIN Person WITH (NOLOCK) ON prattn_PersonID = pers_PersonID
     WHERE prattn_AttentionLineID = @AttentionLineID;

    RETURN @AttentionLine
END
Go


/**
Removes all whitespaces and punctuation from the specified
string.  Also converts it to lowercasing.  Used for duplicate
name checks and text sorting.
**/
If Exists (Select name from sysobjects where name = 'ufn_GetLowerAlpha' and type in (N'FN', N'IF', N'TF')) 
    Drop Function dbo.ufn_GetLowerAlpha
Go


CREATE FUNCTION [dbo].[ufn_GetLowerAlpha](@sText varchar(8000))
RETURNS varchar(8000)
AS
BEGIN

    DECLARE @AlphaOnly varchar(8000), @CurrentChar varchar(1)
    DECLARE @idx smallint,
              @bcontinue bit,
            @Ascii int

    SET @idx = 0
    SET @sText = LTrim(RTrim(@sText))
    SET @sText = Lower(@sText)
    SET @bcontinue = 1
    SET @AlphaOnly = '';

    WHILE (@idx <= DataLength(@sText)) BEGIN
    
        SET @CurrentChar = SubString(@sText, @idx, 1)
        SET @Ascii = ASCII(@CurrentChar)

        IF (@Ascii >= ASCII('a')) BEGIN
            IF (@Ascii <= ASCII('z')) BEGIN
                SET @AlphaOnly = @AlphaOnly + @CurrentChar
            END 
        END

        IF (@Ascii >= ASCII('0')) BEGIN
            IF (@Ascii <= ASCII('9')) BEGIN
                SET @AlphaOnly = @AlphaOnly + @CurrentChar
            END 
        END

        SET @idx = @idx + 1
    END

    RETURN @AlphaOnly
END 
Go

If Exists (Select name from sysobjects where name = 'ufn_GetLowerAlphaWC' and type='FN') Drop Function dbo.ufn_GetLowerAlphaWC
Go

/**
This is used for duplicate name checks making them case
insensitive and ignoring puncuation. This include SQL
wildcard character %
**/
CREATE FUNCTION dbo.ufn_GetLowerAlphaWC(@sText varchar(8000))
RETURNS varchar(8000)
AS
BEGIN

DECLARE @AlphaOnly varchar(8000), @CurrentChar varchar(1)
DECLARE @idx smallint,
          @bcontinue bit,
        @Ascii int

SET @idx = 0
SET @sText = LTrim(RTrim(@sText))
SET @sText = Lower(@sText)
SET @bcontinue = 1
SET @AlphaOnly = '';

While (@idx <= DataLength(@sText))
Begin        
    Set @CurrentChar = SubString(@sText, @idx, 1)
    Set @Ascii = ASCII(@CurrentChar)

    if (@Ascii >= ASCII('a')) Begin
        if (@Ascii <= ASCII('z')) Begin
            SET @AlphaOnly = @AlphaOnly + @CurrentChar
        end 
    end

    if (@Ascii >= ASCII('0')) Begin
        if (@Ascii <= ASCII('9')) Begin
            SET @AlphaOnly = @AlphaOnly + @CurrentChar
        end 
    end

	IF (@CurrentChar = '%') BEGIN
		SET @AlphaOnly = @AlphaOnly + @CurrentChar
	END

    SET @idx = @idx + 1
End

Return(@AlphaOnly)
End 
Go

/**
Determines the appropriate section for credit sheet export
**/
If Exists (Select name from sysobjects where name = 'ufn_GetCreditSheetExportSection' and type in (N'FN', N'IF', N'TF')) 
    Drop Function dbo.ufn_GetCreditSheetExportSection
Go


CREATE FUNCTION [dbo].[ufn_GetCreditSheetExportSection](@comp_PRIndustryType varchar(40), @prcs_KeyFlag nchar(1), @IsExpress bit)
RETURNS varchar(1)
AS
BEGIN

    DECLARE @Section varchar(1)

    IF (@comp_PRIndustryType = 'P') BEGIN
        IF (@IsExpress = 0) BEGIN
            SET @Section = 'A'
        END ELSE BEGIN
            IF (@prcs_KeyFlag = 'Y') BEGIN
                SET @Section = 'A'
            END ELSE BEGIN
                SET @Section = 'B'
            END
        END
    END

    IF (@comp_PRIndustryType = 'T') BEGIN
        IF (@IsExpress = 0) BEGIN
            SET @Section = 'B'
        END ELSE BEGIN
            IF (@prcs_KeyFlag = 'Y') BEGIN
                SET @Section = 'C'
            END ELSE BEGIN
                SET @Section = 'D'
            END
        END
    END

    IF (@comp_PRIndustryType = 'S') BEGIN
        IF (@IsExpress = 0) BEGIN
            SET @Section = 'C'
        END ELSE BEGIN
            SET @Section = 'E'
        END
    END

    RETURN @Section
END
Go


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetTieredRelationships]') 
            and OBJECTPROPERTY(id, N'IsTableFunction') = 1)
drop Function [dbo].[ufn_GetTieredRelationships]
GO

CREATE FUNCTION dbo.ufn_GetTieredRelationships (@SubjectCompanyID int)
RETURNS @Results2 TABLE (
    RelatedCompanyID int primary key,
    prcr_Tier int
)
BEGIN


	DECLARE @Results TABLE (
		RelatedCompanyID int,
		prcr_Tier int
	)

    INSERT INTO @Results (RelatedCompanyID, prcr_Tier)
    SELECT DISTINCT prcr_LeftCompanyId, 1  
      FROM PRCompanyRelationship WITH (NOLOCK)
     WHERE prcr_RightCompanyId = @SubjectCompanyID
       AND prcr_LastReportedDate > DateAdd(Month, -24, getDate()) 
       AND prcr_Type IN ('01', '02', '04', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22')
	   AND prcr_Active = 'Y';


    INSERT INTO @Results (RelatedCompanyID, prcr_Tier)
    SELECT DISTINCT prcr_RightCompanyId, 1  
      FROM PRCompanyRelationship WITH (NOLOCK)
     WHERE prcr_LeftCompanyId = @SubjectCompanyID
       AND prcr_LastReportedDate > DateAdd(Month, -24, getDate()) 
       AND prcr_Type IN ('01', '02', '04', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22') 
       AND prcr_Active = 'Y';


    INSERT INTO @Results (RelatedCompanyID, prcr_Tier)
    SELECT DISTINCT prcr_LeftCompanyId, 2  
     FROM  PRCompanyRelationship WITH (NOLOCK)
     WHERE prcr_RightCompanyId = @SubjectCompanyID
       AND prcr_LastReportedDate > DateAdd(Month, -60, getDate()) 
       AND prcr_Type IN ('01', '02', '04', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22') 
       AND prcr_Active = 'Y';


    INSERT INTO @Results (RelatedCompanyID, prcr_Tier)
    SELECT DISTINCT prcr_RightCompanyId, 2  
     FROM  PRCompanyRelationship WITH (NOLOCK)
     WHERE prcr_LeftCompanyId = @SubjectCompanyID
       AND prcr_LastReportedDate > DateAdd(Month, -60, getDate()) 
       AND prcr_Type IN ('01', '02', '04', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22') 
       AND prcr_Active = 'Y';


    INSERT INTO @Results (RelatedCompanyID, prcr_Tier)
    SELECT DISTINCT prcr_LeftCompanyId, 3  
      FROM PRCompanyRelationship WITH (NOLOCK)
     WHERE prcr_RightCompanyId = @SubjectCompanyID
       AND prcr_LastReportedDate < DateAdd(Month, -60, getDate()) 
       AND prcr_Type IN ('01', '02', '04', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22')
       AND prcr_Active = 'Y';


    INSERT INTO @Results (RelatedCompanyID, prcr_Tier)
    SELECT DISTINCT prcr_LeftCompanyId, 3  
      FROM PRCompanyRelationship WITH (NOLOCK)
     WHERE prcr_RightCompanyId = @SubjectCompanyID
       AND prcr_LastReportedDate > DateAdd(Month, -36, getDate())
       AND prcr_Type IN ('24', '25', '26')
       AND prcr_Active = 'Y';


    INSERT INTO @Results (RelatedCompanyID, prcr_Tier)
    SELECT DISTINCT prcr_RightCompanyId, 3  
      FROM PRCompanyRelationship WITH (NOLOCK)
     WHERE prcr_LeftCompanyId = @SubjectCompanyID
       AND prcr_LastReportedDate < DateAdd(Month, -60, getDate()) 
       AND prcr_Type IN ('1', '2', '4', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22')
       AND prcr_Active = 'Y';


    INSERT INTO @Results (RelatedCompanyID, prcr_Tier)
    SELECT DISTINCT prcr_RightCompanyId, 3  
      FROM PRCompanyRelationship WITH (NOLOCK)
     WHERE prcr_LeftCompanyId = @SubjectCompanyID
       AND prcr_LastReportedDate > DateAdd(Month, -36, getDate())
       AND prcr_Type IN ('24', '25', '26')
       AND prcr_Active = 'Y';


	INSERT INTO @Results2
	SELECT RelatedCompanyID, MIN(prcr_Tier)
	  FROM @Results
  GROUP BY RelatedCompanyID

	RETURN

END 
Go


If Exists (Select name from sysobjects where name = 'ufn_GetEligibleTESResponders' and type in (N'FN', N'IF', N'TF')) 
    Drop Function dbo.ufn_GetEligibleTESResponders
Go

CREATE FUNCTION [dbo].[ufn_GetEligibleTESResponders] (@SubjectCompanyID int)
RETURNS @Results TABLE (
    RelatedCompanyID int primary key,
    prcr_Tier int
)
BEGIN
    INSERT INTO @Results
    SELECT * FROM ufn_GetTieredRelationships(@SubjectCompanyID);

    -- Now remove any responders that have any type
    -- of ownership relationship with our subject
    DECLARE @Owners TABLE (
        OwnerID int primary key
    )
    INSERT INTO @Owners
    SELECT DISTINCT prcr_LeftCompanyId
      FROM @Results
           INNER JOIN PRCompanyRelationship WITH (NOLOCK) ON RelatedCompanyID = prcr_LeftCompanyId
     WHERE prcr_RightCompanyID = @SubjectCompanyID
       AND prcr_Type IN ('27', '28', '29');

    INSERT INTO @Owners
    SELECT DISTINCT prcr_RightCompanyID
      FROM @Results
           INNER JOIN PRCompanyRelationship WITH (NOLOCK) ON RelatedCompanyID = prcr_RightCompanyID
     WHERE prcr_LeftCompanyId = @SubjectCompanyID
       AND prcr_Type IN ('27', '28', '29')
       AND prcr_RightCompanyID NOT IN (SELECT OwnerID FROM @Owners);


/*
	-- At this point, the @Owners table has the subject company's
	-- affiliates.  We also need to exclude the branches of those
	-- affiliates.  This statement should add those branches to our
	-- @Owners table.
    INSERT INTO @Owners
	SELECT comp_CompanyID
	  FROM Company WITH (NOLOCK)
	 WHERE comp_PRType = 'B'
	   AND comp_PRHQId IN (
			SELECT DISTINCT prcr_LeftCompanyId
			  FROM PRCompanyRelationship WITH (NOLOCK)
			 WHERE prcr_RightCompanyID = @SubjectCompanyID
			   AND prcr_Type IN ('27', '28', '29')
					  )
					  
	INSERT INTO @Owners					  
	SELECT comp_CompanyID
	  FROM Company WITH (NOLOCK)
	 WHERE comp_PRType = 'B'
	   AND comp_PRHQId IN (
			SELECT DISTINCT prcr_RightCompanyID 
			  FROM PRCompanyRelationship WITH (NOLOCK)
			 WHERE prcr_LeftCompanyId = @SubjectCompanyID
			   AND prcr_Type IN ('27', '28', '29')
						  )	
*/
       
       
       
    DELETE FROM @Results
     WHERE RelatedCompanyID IN (SELECT OwnerID FROM @Owners);
    
    -- Remove those responders that are either branches of 
    -- our subject company, or are the subject company itself
    DELETE FROM @Results
     WHERE RelatedCompanyID IN (SELECT comp_CompanyID
                                  FROM @Results
                                       INNER JOIN Company WITH (NOLOCK) ON RelatedCompanyID = comp_CompanyID
                                 WHERE comp_PRHQID = @SubjectCompanyID);

    -- Remove those responders that don't receive a TES
    -- and are not listed.
    DELETE FROM @Results
     WHERE RelatedCompanyID NOT IN (SELECT comp_CompanyID
                                      FROM @Results
                                           INNER JOIN Company WITH (NOLOCK) ON RelatedCompanyID = comp_CompanyID
                                     WHERE comp_PRReceiveTES = 'Y' 
									   AND comp_PRType = 'H'
                                       AND comp_PRListingStatus NOT IN ('N3', 'D', 'N5', 'N6'));

    -- Remove those responders that have already
    -- had over 75 TES requests
    DELETE FROM @Results
     WHERE RelatedCompanyID IN (SELECT prtesr_ResponderCompanyID
                                  FROM @Results
                                       INNER JOIN PRTESRequest WITH (NOLOCK) ON RelatedCompanyID = prtesr_ResponderCompanyID
                                 WHERE prtesr_CreatedDate >= DATEADD(Day, -90, GETDATE())
                              GROUP BY prtesr_ResponderCompanyID
                                HAVING COUNT(1) >= 75);

    -- Remove those responders that have provided
    -- A/R Aging data in the past 90 days
    DELETE FROM @Results
     WHERE RelatedCompanyID IN (SELECT praa_CompanyId
                                  FROM @Results
                                       INNER JOIN PRARAging WITH (NOLOCK) ON RelatedCompanyID = praa_CompanyId
                                 WHERE  praa_Date >= DATEADD(Day, -90, GETDATE()))

    -- Remove those responders that have already 
    -- sent a TES request on our subject in the past
    -- 27 days
    DELETE FROM @Results
     WHERE RelatedCompanyID IN (SELECT prtesr_ResponderCompanyID
                                  FROM @Results
                                       INNER JOIN PRTESRequest ON RelatedCompanyID = prtesr_ResponderCompanyID
                                 WHERE prtesr_SubjectCompanyID = @SubjectCompanyID
                                   AND prtesr_CreatedDate >= DATEADD(Day, - 27, GETDATE()));

    -- Remove those responders that have provided trade
    -- report data on our subject in the past 45 days.
    DELETE FROM @Results
     WHERE RelatedCompanyID IN (SELECT prtr_ResponderId
                                  FROM @Results
                                       INNER JOIN PRTradeReport WITH (NOLOCK) ON RelatedCompanyID = prtr_ResponderId
                                 WHERE prtr_SubjectId = @SubjectCompanyID
                                   AND prtr_Date >= DATEADD(Day, -45, GETDATE()))

	-- Remove those responders not setup with a
    -- TES attention line
    DELETE FROM @Results
     WHERE RelatedCompanyID NOT IN (SELECT DISTINCT prattn_CompanyID
                                       FROM @Results
                                            INNER JOIN PRAttentionLine WITH (NOLOCK) ON RelatedCompanyID = prattn_CompanyID
                                      WHERE (prattn_ItemCode = 'TES-E' AND (prattn_PhoneID IS NOT NULL OR prattn_EmailID IS NOT NULL OR prattn_BBOSOnly IS NOT NULL) AND prattn_Disabled IS NULL)
                                         OR (prattn_ItemCode = 'TES-M' AND prattn_AddressID IS NOT NULL AND prattn_Disabled IS NULL));
							
	-- Remove those responders that already have a 
	-- pending TES request for the subject, regardless
	-- of how old the request is.
    DELETE FROM @Results
     WHERE RelatedCompanyID IN (
				SELECT DISTINCT prtesr_ResponderCompanyID
                  FROM @Results
                       INNER JOIN PRTESRequest ON RelatedCompanyID = prtesr_ResponderCompanyID
                 WHERE prtesr_SubjectCompanyID = @SubjectCompanyID
				   AND prtesr_SentDateTime IS NULL
				   AND prtesr_Received IS NULL);


	-- Remove those responders that have told use they 
	-- don't do business with the subject.
	DELETE FROM @Results
	  WHERE RelatedCompanyID IN (
				SELECT prtesre_CompanyID 
				  FROM PRTESRequestExclusion 
				 WHERE prtesre_SubjectCompanyID = @SubjectCompanyID)

    RETURN
END
Go



-- TME 8/2/07. CRM 2.5
-- Return the hierarchical List of Regions from PRRegion
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetRegions]') 
            and OBJECTPROPERTY(id, N'IsTableFunction') = 1)
drop Function [dbo].[ufn_GetRegions]
GO

CREATE FUNCTION [dbo].[ufn_GetRegions] 
(
    -- Domestic or International ('D' or 'I')
    @Type nvarchar(40) = N'D'
)
RETURNS 
@Results TABLE 
(
    prd2_RegionId int
    , prd2_Name nvarchar (200)
    , prd2_Level int
    , prd2_ParentId int,
	seq int identity(1,1)
)
AS
BEGIN
    -- Fill the table variable with the rows for your result set

    declare @ctl_table table (_ndx int identity, _level int, _parent int)
    declare @result_table table (_ndx int identity, prd2_RegionId int , 
            prd2_Name varchar (200), prd2_Level int , prd2_ParentId int)

    declare @Count int

    insert into @ctl_table
    SELECT DISTINCT prd2_Level, prd2_ParentId
      FROM PRRegion
     WHERE prd2_ParentId is not null
	   AND prd2_Type = @Type
  ORDER BY prd2_Level desc, prd2_ParentId desc

    SELECT @Count = COUNT(1) FROM @ctl_table
    Declare @ndx int; SET @ndx = 1
    DECLARE @ParentId int, @LevelId int
    While (@ndx < @Count)
    Begin
        SELECT @ParentId = null, @LevelId = null
        SELECT @ParentId = _parent, @LevelId = _level from @ctl_table where _ndx = @ndx

        Insert into @result_table
            SELECT prd2_RegionId, prd2_Name, prd2_Level, prd2_ParentId 
              from PRRegion 
             where prd2_ParentId = @ParentId 
			   AND prd2_Type = @Type 
			   AND prd2_RegionId NOT IN (SELECT prd2_RegionId FROM @result_table)
          order by prd2_Name desc

        Insert into @result_table
            SELECT prd2_RegionId, prd2_Name, prd2_Level, prd2_ParentId 
                from PRRegion 
                where prd2_RegionId = @ParentId 
				AND prd2_Type = @Type 
				AND prd2_RegionId NOT IN (SELECT prd2_RegionId FROM @result_table)

        SET @ndx = @ndx + 1
    End

    Insert into @result_table 
        SELECT prd2_RegionId, prd2_Name, prd2_Level, prd2_ParentId 
            from PRRegion 
            where prd2_ParentId is null and prd2_Type = @Type 

    insert into @Results select prd2_RegionId, prd2_Name, prd2_Level, prd2_ParentId from @result_table order by _ndx desc
    
    RETURN 
END
GO

-- Count how many times a given string exists within another string
-- Found at http://www.sql-server-helper.com
If Exists (Select name from sysobjects where name = 'ufn_CountString' and type='FN') Drop Function dbo.ufn_CountString
Go
CREATE FUNCTION [dbo].[ufn_CountString]
( @pInput VARCHAR(8000), @pSearchString VARCHAR(100) )
RETURNS INT
BEGIN

    RETURN (LEN(@pInput) - 
            LEN(REPLACE(@pInput, @pSearchString, ''))) /
            LEN(@pSearchString)

END
GO

-- Count exceptions for a company within a specified time period (for Defect #1377)
If Exists (Select name from sysobjects where name = 'ufn_CompanyExceptionCount' and type='FN') Drop Function dbo.ufn_CompanyExceptionCount
Go
-- the above function is obsolete!

If Exists (Select name from sysobjects where name = 'ufn_getCompanyExceptionCount' and type='FN') 
    Drop Function dbo.ufn_getCompanyExceptionCount
Go
--    Note that TypeCodes does not always = custom caption value.  'TESAR' can be passed equaling
--    TES & AR
CREATE FUNCTION [dbo].[ufn_getCompanyExceptionCount](
    @CompanyId int, 
    @NumberOfDays int,
    @TypeCode varchar(40),
    @Status varchar(40)
)
RETURNS INT
BEGIN
    If (@CompanyId is null )
        return -1

    If (@NumberOfDays is null or @NumberOfDays < 1)
        return -1
    
    DECLARE @Table TABLE (
		preq_Type varchar(40), 
		preq_Status varchar(40),
		_Count int)

    DECLARE @RetVal int
    
	DECLARE @Today datetime = DATEADD(minute, 1339, CAST(GETDATE() as Date))


    -- Get all the records that fit the companyid and date range
    -- group by the preq_Type and preq_Status
    INSERT INTO @Table
        SELECT preq_Type, preq_Status, count(1) 
          FROM PRExceptionQueue WITH (NOLOCK)
         WHERE preq_CompanyId = @CompanyId
           AND preq_Date >= DATEADD(day, 0-@NumberOfDays, @Today)
           AND preq_Date <= @Today    
		   AND preq_Status = ISNULL(@Status, preq_Status)
        GROUP BY preq_Type, preq_Status

    -- Remove any records that do not have the requested Status
--   IF (@Status is not null) BEGIN
--        DELETE FROM @Table
--        WHERE preq_Status != @Status
--   END


    -- Remove any records that do not have the requested type
    IF (@TypeCode is not null) BEGIN
        IF (@TypeCode = 'TESAR') 
            DELETE FROM @Table
            WHERE preq_Type != 'TES' and preq_Type != 'AR'
        ELSE    
            DELETE FROM @Table
            WHERE preq_Type != @TypeCode 
    END
    
    SELECT @RetVal = ISNULL(SUM(_Count), 0) from @Table
    RETURN @RetVal
END
GO



If Exists (Select name from sysobjects where name = 'ufn_getCompanyExceptionCounts') 
    Drop Function dbo.ufn_getCompanyExceptionCounts
Go

--    Note that TypeCodes does not always = custom caption value.  'TESAR' can be passed equaling
--    TES & AR
CREATE FUNCTION [dbo].[ufn_getCompanyExceptionCounts](
    @TypeCode varchar(40),
    @Status varchar(40)
)
RETURNS @MyTable table (
	CompanyID int,
	TotalExcpCount int default(0),
	BBS_Count int default(0),
	BBS_Days15Count int default(0),
	BBS_Days30Count int default(0),
	BBS_Days45Count int default(0),
	BBS_Days60Count int default(0),
	BBS_Days90Count int default(0),
	BBS_Days90PlusCount int default(0),
	AR_Count int default(0),
	AR_Days15Count int default(0),
	AR_Days30Count int default(0),
	AR_Days45Count int default(0),
	AR_Days60Count int default(0),
	AR_Days90Count int default(0),
	AR_Days90PlusCount int default(0),
	TES_Count int default(0),
	TES_Days15Count int default(0),
	TES_Days30Count int default(0),
	TES_Days45Count int default(0),
	TES_Days60Count int default(0),
	TES_Days90Count int default(0),
	TES_Days90PlusCount int default(0)
)

BEGIN


	IF (@TypeCode IS NULL) BEGIN
		SET @TypeCode = 'All'
	END


	DECLARE @Today datetime = DATEADD(minute, 1339, CAST(CAST(GETDATE() as Date) as DateTime)	)
	DECLARE @15Days datetime = DATEADD(day, -15, @Today)
	DECLARE @30Days datetime = DATEADD(day, -30, @Today)
	DECLARE @45Days datetime = DATEADD(day, -45, @Today)
	DECLARE @60Days datetime = DATEADD(day, -60, @Today)
	DECLARE @90Days datetime = DATEADD(day, -90, @Today)



	DECLARE @TypeCodeString varchar(100) = ''
	IF (@TypeCode IN ('AR', 'TESAR', 'All')) BEGIN
		IF (LEN(@TypeCodeString) > 0) SET @TypeCodeString = @TypeCodeString + ','
		SET @TypeCodeString = @TypeCodeString + 'AR'
	END

	IF (@TypeCode IN ('TES', 'TESAR', 'All')) BEGIN
		IF (LEN(@TypeCodeString) > 0) SET @TypeCodeString = @TypeCodeString + ','
		SET @TypeCodeString = @TypeCodeString + 'TES'
	END


	IF (@TypeCode IN ('BBScore', 'All')) BEGIN
		IF (LEN(@TypeCodeString) > 0) SET @TypeCodeString = @TypeCodeString + ','
		SET @TypeCodeString = @TypeCodeString + 'BBScore'
	END

	INSERT INTO @MyTable (CompanyID)
	SELECT DISTINCT preq_CompanyId
	  FROM PRExceptionQueue preq WITH (NOLOCK) 
	 WHERE preq_Status = ISNULL(@Status, preq_Status)
	   --AND preq_Date >= @90Days
	   AND preq_Type IN (SELECT value FROM dbo.Tokenize(@TypeCodeString, ','));

	IF (@TypeCode IN ('AR', 'TESAR', 'All')) BEGIN

		UPDATE @MyTable
		   SET AR_Count = TotalCount,
			   AR_Days15Count = Days15Count,
			   AR_Days30Count = Days30Count,
			   AR_Days45Count = Days45Count,
			   AR_Days60Count = Days60Count,
			   AR_Days90Count = Days90Count
		  FROM (
				SELECT preq_CompanyId,
					   preq_Type, 
					   count(1) as TotalCount,
					   SUM(CASE WHEN preq_Date BETWEEN @15Days AND @Today THEN 1 ELSE 0 END) as Days15Count,
					   SUM(CASE WHEN preq_Date BETWEEN @30Days AND @15Days THEN 1 ELSE 0 END) as Days30Count,
					   SUM(CASE WHEN preq_Date BETWEEN @45Days AND @30Days THEN 1 ELSE 0 END) as Days45Count,
					   SUM(CASE WHEN preq_Date BETWEEN @60Days AND @45Days THEN 1 ELSE 0 END) as Days60Count,
					   SUM(CASE WHEN preq_Date BETWEEN @90Days AND @60Days THEN 1 ELSE 0 END) as Days90Count
				  FROM PRExceptionQueue WITH (NOLOCK)
				 WHERE preq_Type = 'AR' 
				   --AND preq_Date >= @90Days
				   AND preq_Status = ISNULL(@Status, preq_Status)
				GROUP BY preq_CompanyId, preq_Type
				) T1
		WHERE CompanyID = preq_CompanyID
	END


	IF (@TypeCode IN ('TES', 'TESAR', 'All')) BEGIN

		UPDATE @MyTable
		   SET TES_Count = TotalCount,
			   TES_Days15Count = Days15Count,
			   TES_Days30Count = Days30Count,
			   TES_Days45Count = Days45Count,
			   TES_Days60Count = Days60Count,
			   TES_Days90Count = Days90Count
		  FROM (
				SELECT preq_CompanyId,
					   preq_Type, 
					   count(1) as TotalCount,
					   SUM(CASE WHEN preq_Date BETWEEN @15Days AND @Today THEN 1 ELSE 0 END) as Days15Count,
					   SUM(CASE WHEN preq_Date BETWEEN @30Days AND @15Days THEN 1 ELSE 0 END) as Days30Count,
					   SUM(CASE WHEN preq_Date BETWEEN @45Days AND @30Days THEN 1 ELSE 0 END) as Days45Count,
					   SUM(CASE WHEN preq_Date BETWEEN @60Days AND @45Days THEN 1 ELSE 0 END) as Days60Count,
					   SUM(CASE WHEN preq_Date BETWEEN @90Days AND @60Days THEN 1 ELSE 0 END) as Days90Count
				  FROM PRExceptionQueue WITH (NOLOCK)
				 WHERE preq_Type = 'TES' 
				   --AND preq_Date >= @90Days
				   AND preq_Status = ISNULL(@Status, preq_Status)
				GROUP BY preq_CompanyId, preq_Type
				) T1
		WHERE CompanyID = preq_CompanyID
	END

	IF (@TypeCode IN ('BBScore', 'All')) BEGIN

		UPDATE @MyTable
		   SET BBS_Count = TotalCount,
			   BBS_Days15Count = Days15Count,
			   BBS_Days30Count = Days30Count,
			   BBS_Days45Count = Days45Count,
			   BBS_Days60Count = Days60Count,
			   BBS_Days90Count = Days90Count
		  FROM (
				SELECT preq_CompanyId,
					   preq_Type, 
					   count(1) as TotalCount,
					   SUM(CASE WHEN preq_Date BETWEEN @15Days AND @Today THEN 1 ELSE 0 END) as Days15Count,
					   SUM(CASE WHEN preq_Date BETWEEN @30Days AND @15Days THEN 1 ELSE 0 END) as Days30Count,
					   SUM(CASE WHEN preq_Date BETWEEN @45Days AND @30Days THEN 1 ELSE 0 END) as Days45Count,
					   SUM(CASE WHEN preq_Date BETWEEN @60Days AND @45Days THEN 1 ELSE 0 END) as Days60Count,
					   SUM(CASE WHEN preq_Date BETWEEN @90Days AND @60Days THEN 1 ELSE 0 END) as Days90Count
				  FROM PRExceptionQueue WITH (NOLOCK)
				 WHERE preq_Type = 'BBScore' 
				   --AND preq_Date >= @90Days
				   AND preq_Status = ISNULL(@Status, preq_Status)
				GROUP BY preq_CompanyId, preq_Type
				) T1
		WHERE CompanyID = preq_CompanyID
	END

	UPDATE @MyTable
	   SET TotalExcpCount = ISNULL(BBS_Count, 0) + ISNULL(AR_Count, 0) + ISNULL(TES_Count, 0)

	--SELECT * FROM @MyTable
	RETURN
END
Go

-- Determine whether a string has any lowercase characters
If Exists (Select name from sysobjects where name = 'ufn_HasLowerAlpha' and type='FN') Drop Function dbo.ufn_HasLowerAlpha
Go
CREATE FUNCTION [dbo].[ufn_HasLowerAlpha](@sText varchar(8000))
RETURNS bit
AS
BEGIN
 
DECLARE @CurrentChar varchar(1)
DECLARE @idx smallint,
        @Ascii int,
        @HasLower bit
 
SET @idx = 0
SET @sText = LTrim(RTrim(@sText))
SET @HasLower = 0
 
While (@idx <= DataLength(@sText))
Begin        
    Set @CurrentChar = SubString(@sText, @idx, 1)
    Set @Ascii = ASCII(@CurrentChar)
 
    if (@Ascii >= ASCII('a')) Begin
        if (@Ascii <= ASCII('z')) Begin
            SET @HasLower = 1
   SET @idx = DataLength(@sText)
        end 
    end
 
    SET @idx = @idx + 1
End
 

Return @HasLower
End 

Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_getSSContactMailingLabel ]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    drop function [dbo].[ufn_getSSContactMailingLabel ]
GO
CREATE FUNCTION dbo.ufn_getSSContactMailingLabel ( 
    @prssc_SSContactId int,
    @LineBreakChar varchar(50)
)
RETURNS varchar(1000)
AS
BEGIN
    Declare @Result varchar(1000)
    SELECT @Result = ISNULL(prssc_ContactAttn + @LineBreakChar, '') + comp_Name + @LineBreakChar
        + IsNull(prssc_Address1, '') + @LineBreakChar 
        + IsNull(prssc_Address2 + @LineBreakChar, '') + IsNull(prssc_Address3 + @LineBreakChar, '') 
        + IsNull(prssc_CityStateZip + @LineBreakChar, '') 
        + IsNull('(P) ' + prssc_Telephone + @LineBreakChar, '') 
        + IsNull('(F) ' + prssc_Fax + @LineBreakChar, '') 
        + IsNull(prssc_Email + @LineBreakChar, '') 
        + IsNull('Notes: '+ prssc_ContactNotes + @LineBreakChar, '') 
     FROM PRSSContact
          INNER JOIN Company WITH (NOLOCK) on prssc_CompanyId = comp_CompanyId
    WHERE prssc_SSContactId = @prssc_SSContactId;

    return @Result
END
GO


/**
Returns the unit price for the specified product and UOM
**/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetProductPrice]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    drop function [dbo].[ufn_GetProductPrice]
GO
CREATE FUNCTION dbo.ufn_GetProductPrice(@ProductID int, @PricingListID int)
RETURNS numeric(24,6)  AS  
BEGIN 
    
    DECLARE @Price numeric(24,6)

    SELECT @Price = pric_price
      FROM Pricing
     WHERE pric_ProductID = @ProductID
       AND pric_PricingListID = @PricingListID;

    -- If we didn't fine a price, then
    -- go query for the default price.
    IF @Price IS NULL BEGIN
        SELECT @Price = pric_price
          FROM Pricing
         WHERE pric_ProductID = @ProductID
           AND pric_PricingListID = 16002;
    END

    RETURN @Price
END
GO

--
-- Returns the last top N company IDs viewed by the specified user
--
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetRecentCompanies]') 
            and OBJECTPROPERTY(id, N'IsTableFunction') = 1)
drop Function [dbo].[ufn_GetRecentCompanies]
GO

CREATE FUNCTION dbo.ufn_GetRecentCompanies
(
    @WebUserID int,
    @Top int
)
RETURNS @Recent table (
    ndx int identity(1,1) ,
    CompanyID int
)
AS BEGIN

	INSERT INTO @Recent (CompanyID)
	SELECT TOP(@Top) prwsat_AssociatedID
	  FROM PRWebAuditTrail         
	  WHERE (prwsat_PageName LIKE '%CompanyDetailsSummary.aspx'
			 OR prwsat_PageName LIKE '%Company.aspx'
			 OR prwsat_PageName LIKE '%CompanyView.aspx'
	         OR prwsat_PageName LIKE '%getcompany')
		AND prwsat_WebUserID = @WebUserID 
		AND prwsat_AssociatedType = 'C'  
	GROUP BY  prwsat_AssociatedID   
	ORDER BY MAX(prwsat_CreatedDate) DESC;

    RETURN
END
Go

--
-- Returns the last top N company IDs viewed by the specified Limitado user using LimitadoCompany.aspx
--
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetRecentCompanies_Limitado]') 
            and OBJECTPROPERTY(id, N'IsTableFunction') = 1)
drop Function [dbo].[ufn_GetRecentCompanies_Limitado]
GO

CREATE FUNCTION dbo.ufn_GetRecentCompanies_Limitado
(
    @WebUserID int,
    @Top int
)
RETURNS @Recent table (
    ndx int identity(1,1) ,
    CompanyID int
)
AS BEGIN

	INSERT INTO @Recent (CompanyID)
	SELECT TOP(@Top) prwsat_AssociatedID
	  FROM PRWebAuditTrail         
	  WHERE (prwsat_PageName LIKE '%LimitadoCompany.aspx')
		AND prwsat_WebUserID = @WebUserID 
		AND prwsat_AssociatedType = 'C'  
	GROUP BY  prwsat_AssociatedID   
	ORDER BY MAX(prwsat_CreatedDate) DESC;

    RETURN
END
Go

--
-- Returns the last top N person IDs viewed by the specified user
--
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetRecentPersons]') 
            and OBJECTPROPERTY(id, N'IsTableFunction') = 1)
drop Function [dbo].[ufn_GetRecentPersons]
GO

CREATE FUNCTION dbo.ufn_GetRecentPersons
(
    @WebUserID int,
    @Top int
)
RETURNS @Recent table (
    ndx int identity(1,1) ,
    PersonID int
)
AS BEGIN


	INSERT INTO @Recent (PersonID)
	SELECT TOP(@Top) prwsat_AssociatedID
	  FROM PRWebAuditTrail         
	  WHERE (prwsat_PageName LIKE '%PersonDetails.aspx'
	         OR prwsat_PageName LIKE '%getcontact')
		AND prwsat_WebUserID = @WebUserID 
		AND prwsat_AssociatedType = 'P'  
	GROUP BY  prwsat_AssociatedID   
	ORDER BY MAX(prwsat_CreatedDate) DESC;

	RETURN

END
Go

--
-- Returns a list of Brands for the given company
--
IF EXISTS 
(
    SELECT * FROM dbo.sysobjects 
    WHERE id = object_id(N'[dbo].[ufn_GetBrandsList]') 
    AND xtype in (N'FN', N'IF', N'TF')
) DROP FUNCTION [dbo].[ufn_GetBrandsList]
GO

CREATE FUNCTION [dbo].[ufn_GetBrandsList] ( 
    @CompanyId int
)
RETURNS varchar(2000)
AS
BEGIN
    -- Build a comma-delimited list of the Brands
    DECLARE @List varchar(2000)
    SELECT @List =  COALESCE(@List + ', ', '') + prc3_Brand
      FROM PRCompanyBrand
     WHERE prc3_CompanyID = @CompanyID
       AND prc3_Publish = 'Y'
       AND prc3_Deleted IS NULL
    ORDER BY prc3_Sequence;
    RETURN @List;
END
GO

--
-- Returns the rating definitions for the given rating id
--
IF EXISTS 
(
    SELECT * FROM dbo.sysobjects 
    WHERE id = object_id(N'[dbo].[ufn_GetRatingDefinitions]') 
    AND xtype in (N'FN', N'IF', N'TF')
) DROP FUNCTION [dbo].[ufn_GetRatingDefinitions]
GO

CREATE FUNCTION [dbo].[ufn_GetRatingDefinitions] (
    @prra_RatingId int, 
    @FormattingStyle tinyint = 0, -- 0: <br/> 1: CHR(10) 2: CHR(10 & 13)
    @LineSize int
)
RETURNS varchar(5000) 
AS
BEGIN
    DECLARE @RetValue varchar(5000)
    DECLARE @LineBreakChar varchar(50)

    DECLARE @CreditWorthDefinition varchar(1000)
    DECLARE @IntegrityRatingDefinition varchar (1000)
    DECLARE @PayRatingDefinition varchar(1000)
    DECLARE @RatingNumeralDefinition varchar(1000)

    SET @LineBreakChar = CHAR(10) 
    SET @RetValue = ''
    
    SELECT @CreditWorthDefinition = prcw_Name + '-' +dbo.ufn_GetCustomCaptionValue('prcw_Name', prcw_Name, 'en-us'),        
        @IntegrityRatingDefinition = prin_Name + '-' + dbo.ufn_GetCustomCaptionValue('prin_Name', prin_Name, 'en-us'),
        @PayRatingDefinition = prpy_Name + '-' + dbo.ufn_GetCustomCaptionValue('prpy_Name', prpy_Name, 'en-us')
    FROM vPRCompanyRating 
    WHERE prra_RatingID=@prra_RatingId

    IF (@CreditWorthDefinition IS NOT NULL)
    BEGIN
        IF (LEN(@RetValue) > 0) 
        BEGIN
            SET @RetValue = @RetValue + @LineBreakChar
        END            
        SET @RetValue = @RetValue + dbo.ufn_ApplyListingLineBreaks2(@CreditWorthDefinition,@LineBreakChar, @LineSize)
    END
    
    IF (@IntegrityRatingDefinition IS NOT NULL)
    BEGIN
        IF (LEN(@RetValue) > 0) 
        BEGIN
            SET @RetValue = @RetValue + @LineBreakChar
        END        
        SET @RetValue = @RetValue + dbo.ufn_ApplyListingLineBreaks2(@IntegrityRatingDefinition,@LineBreakChar, @LineSize)
    END

    IF (@PayRatingDefinition IS NOT NULL)
    BEGIN
        IF (LEN(@RetValue) > 0) 
        BEGIN
            SET @RetValue = @RetValue + @LineBreakChar
        END
        SET @RetValue = @RetValue + dbo.ufn_ApplyListingLineBreaks3(@PayRatingDefinition,@LineBreakChar, @LineSize)
    END


    DECLARE @Table table (
        ndx int identity(1,1),
        Definition varchar(500)
    )

    INSERT INTO @Table (Definition)
    SELECT  prrn_Name + '-' + dbo.ufn_GetCustomCaptionValue('prrn_Name', prrn_Name, 'en-us')
    FROM PRRating 
    INNER JOIN PRRatingNumeralAssigned ON prra_RatingID = pran_RatingID 
    INNER JOIN PRRatingNumeral ON pran_RatingNumeralID = prrn_RatingNumeralID
    WHERE prra_RatingID=@prra_RatingId
    ORDER BY prrn_Order;

    DECLARE @Count int, @Index int, @RatingDef varchar(500)
    SELECT @Count = COUNT(1) FROM @Table;

    SET @Index = 0
    WHILE (@Index < @Count) BEGIN
        SET @Index = @Index + 1
        
        SELECT @RatingDef = Definition
          FROM @Table
         WHERE ndx = @Index;

        IF (LEN(@RetValue) > 0) 
        BEGIN
            SET @RetValue = @RetValue + @LineBreakChar
        END
        SET @RetValue = @RetValue + dbo.ufn_ApplyListingLineBreaks2(@RatingDef,@LineBreakChar, @LineSize)

    END

    RETURN @RetValue

END
GO

--
-- Returns the formatted address for mailing labels.  Order of resolution M,PH,W,I,O
--
IF EXISTS 
(
    SELECT * FROM dbo.sysobjects 
    WHERE id = object_id(N'[dbo].[ufn_GetAddressForMailingLabel]') 
    AND xtype in (N'FN', N'IF', N'TF')
) DROP FUNCTION [dbo].[ufn_GetAddressForMailingLabel]
GO

CREATE FUNCTION [dbo].[ufn_GetAddressForMailingLabel] (
    @CompanyId int, 
    @IncludeCountry bit = 0
)
RETURNS varchar(1000) 
AS
BEGIN
    DECLARE @RetValue varchar(1000)
    DECLARE @LineBreakChar varchar(50)

    DECLARE @AddressLine1 varchar(40)
    DECLARE @AddressLine2 varchar(40)
    DECLARE @City varchar(30)
    DECLARE @State varchar(30)
    DECLARE @Country varchar(30)
    DECLARE @PostalCode varchar(10)


    SET @LineBreakChar = CHAR(10) 
    SET @RetValue = ''

	DECLARE @AddressID int = NULL
	
	SET @AddressID = dbo.ufn_GetAddressIDForList(@CompanyId, 'M')
	IF (@AddressID IS NULL) BEGIN
		SET @AddressID = dbo.ufn_GetAddressIDForList(@CompanyId, 'PH')	
	END
	IF (@AddressID IS NULL) BEGIN
		SET @AddressID = dbo.ufn_GetAddressIDForList(@CompanyId, 'W')	
	END
	IF (@AddressID IS NULL) BEGIN
		SET @AddressID = dbo.ufn_GetAddressIDForList(@CompanyId, 'W')	
	END
	IF (@AddressID IS NULL) BEGIN
		SET @AddressID = dbo.ufn_GetAddressIDForList(@CompanyId, 'O')	
	END

    SELECT @AddressLine1 = addr_Address1, 
           @AddressLine2 = addr_Address2,
           @City = prci_City, 
           @State = ISNULL(prst_Abbreviation, prst_State), 
           @Country = prcn_Country, 
           @PostalCode = addr_PostCode
      FROM vPRAddress      
     WHERE addr_AddressID = @AddressID;

    SET @RetValue = RTRIM(@AddressLine1)
    IF (LEN(@AddressLine2) > 0) 
    BEGIN
        SET @RetValue = @RetValue + @LineBreakChar + RTRIM(@AddressLine2)
    END        

    SET @RetValue = @RetValue + @LineBreakChar + @City + ', '
    
    IF (@State IS NOT NULL) 
    BEGIN
        SET @RetValue = @RetValue + @State
    END

    IF (@PostalCode IS NOT NULL) 
    BEGIN
        SET @RetValue = @RetValue + ' ' + RTRIM(@PostalCode)
    END

        
    IF (@IncludeCountry = 1) 
    BEGIN
        SET @RetValue = @RetValue + @LineBreakChar + RTRIM(@Country)
    END
    ELSE
    BEGIN
        IF(RTRIM(@Country) <> 'USA')
        BEGIN
            SET @RetValue = @RetValue + @LineBreakChar + RTRIM(@Country)
        END
    END

    RETURN @RetValue

END
GO

--
-- Returns the translated string value based on based on the Search Audit 
-- Trail value and the SubtypeCode
--
IF EXISTS 
(
    SELECT * FROM dbo.sysobjects 
    WHERE id = object_id(N'[dbo].[ufn_GetSearchAuditTrailCriteriaValue]') 
    AND xtype in (N'FN', N'IF', N'TF')
) DROP FUNCTION [dbo].[ufn_GetSearchAuditTrailCriteriaValue]
GO

CREATE FUNCTION [dbo].[ufn_GetSearchAuditTrailCriteriaValue] ( 
    @StringValue varchar(max), -- comma-delimited list of search values
    @IntValue int,
    @SubtypeCode varchar(40),
    @Culture varchar(10)
)
RETURNS varchar(max)
AS
BEGIN
    DECLARE @ReturnValue varchar(max)
    DECLARE @CaptionFamily varchar(50)

    IF(LEN(RTRIM(@StringValue)) > 0)
    BEGIN
        
        -- Separate the list of Search values
        DECLARE @SearchValues TABLE(idx int, [SearchValue] varchar(500));
        INSERT INTO @SearchValues(idx, [SearchValue]) SELECT idx, [value] FROM dbo.Tokenize(@StringValue, ',');    

        -- Iterate over each of the types received
        DECLARE @idx int;
        DECLARE @max_idx int;
        DECLARE @SValue nvarchar(500);
        DECLARE @Connector nvarchar(100);

        SELECT @max_idx = MAX(idx) FROM @SearchValues;
        SELECT @idx = MIN(idx) FROM @SearchValues;
        
        SET @ReturnValue = ''
        SET @Connector = ''

        WHILE @idx <= @max_idx
        BEGIN
            SELECT @SValue = [SearchValue] FROM @SearchValues WHERE idx = @idx;
            IF LEN(COALESCE(@SValue, '')) < 1 BEGIN
                SET @idx = @idx + 1
                CONTINUE
            END

            IF (LEN(RTRIM(@ReturnValue)) > 0) 
            BEGIN
                SET @Connector = ', '
            END
            ELSE
            BEGIN
                SET @Connector = ''
            END

            SET @ReturnValue = @ReturnValue + @Connector            

            -- BR - Brands - No translation required
            IF(@SubtypeCode = 'BR')
            BEGIN
                SET @ReturnValue = @ReturnValue + @SValue
            END
            -- CL - Classification
            IF(@SubtypeCode = 'CL')
            BEGIN
                SET @ReturnValue = @ReturnValue + (SELECT prcl_Name FROM PRClassification WITH (NOLOCK) WHERE prcl_ClassificationId = @SValue)
            END
            -- CM - Commodity
            IF(@SubtypeCode = 'CM')
            BEGIN
                SET @ReturnValue = @ReturnValue + (SELECT prcm_Name FROM PRCommodity WITH (NOLOCK) WHERE prcm_CommodityId = @SValue)
            END
            -- CMA - Commodity Attribute
            IF(@SubtypeCode = 'CMA')
            BEGIN
                SET @ReturnValue = @ReturnValue + (SELECT prat_Name FROM PRAttribute WITH (NOLOCK) WHERE prat_AttributeId = @SValue)
            END
            -- IT - Industry Type
            IF(@SubtypeCode = 'IT')
            BEGIN
                SET @ReturnValue = @ReturnValue + dbo.ufn_GetCustomCaptionValue('comp_PRIndustryType', @SValue, @Culture)    
            END
            -- LCI - Listing City - No translation required
            IF(@SubtypeCode = 'LCI')
            BEGIN
                SET @ReturnValue = @ReturnValue + @SValue
            END
            -- LCN - Listing Country 
            IF(@SubtypeCode = 'LCN')
            BEGIN
                SET @ReturnValue = @ReturnValue + (SELECT prcn_Country FROM PRCountry WITH (NOLOCK) WHERE prcn_CountryId = @SValue)
            END
            -- LS - Listing State
            IF(@SubtypeCode = 'LS')
            BEGIN
                SET @ReturnValue = @ReturnValue + (SELECT prst_State FROM PRState WITH (NOLOCK) WHERE prst_StateId = @SValue)
            END
            -- PC - Listing Postal Code - No translation required
            IF(@SubtypeCode = 'PC')
            BEGIN
                SET @ReturnValue = @ReturnValue + @SValue
            END
            -- RS - Radius Search - No translation required
            IF(@SubtypeCode = 'RS')
            BEGIN
                SET @ReturnValue = @ReturnValue + @SValue
            END
            -- TM - Terminal Market
            IF(@SubtypeCode = 'TM')
            BEGIN
                SET @ReturnValue = @ReturnValue + (SELECT prtm_FullMarketName FROM PRTerminalMarket WITH (NOLOCK) WHERE prtm_TerminalMarketId = @SValue)
            END
            -- VO - Volume
            IF(@SubtypeCode = 'VO')
            BEGIN
                SET @ReturnValue = @ReturnValue + dbo.ufn_GetCustomCaptionValue('prcp_Volume', @SValue, @Culture)                    
            END            


            IF(@SubtypeCode = 'PP')
            BEGIN
                SET @ReturnValue = @ReturnValue + (SELECT prprpr_Name FROM PRProductProvided WITH (NOLOCK) WHERE prprpr_ProductProvidedID = @SValue)
            END

            IF(@SubtypeCode = 'S')
            BEGIN
                SET @ReturnValue = @ReturnValue + (SELECT prspc_Name FROM PRSpecie WITH (NOLOCK) WHERE prspc_SpecieID = @SValue)
            END

            IF(@SubtypeCode = 'SP')
            BEGIN
                SET @ReturnValue = @ReturnValue + (SELECT prserpr_Name FROM PRServiceProvided WITH (NOLOCK) WHERE prserpr_ServiceProvidedID = @SValue)
            END


            SET @idx = @idx + 1;
        END
    END
    ELSE
    BEGIN
        SET @ReturnValue = @IntValue
    END
    RETURN @ReturnValue

END
GO

IF EXISTS 
(
    SELECT * FROM dbo.sysobjects 
    WHERE id = object_id(N'[dbo].[ufn_GetSearchCountForCriteriaType]') 
    AND xtype in (N'FN', N'IF', N'TF')
) DROP FUNCTION [dbo].[ufn_GetSearchCountForCriteriaType]
GO

CREATE FUNCTION [dbo].[ufn_GetSearchCountForCriteriaType] ( 
    @StartDate datetime,
    @EndDate datetime
)
RETURNS @tblCriterTypeCount TABLE (
    IndustryType varchar(40),
    TypeCode varchar(40),
    TypeCount int
)
AS
BEGIN


	DECLARE @tblExclude table (
		CompanyID int
	)

	INSERT INTO @tblExclude
	SELECT Cast(Capt_Code As INT) FROM Custom_Captions WHERE Capt_Family = 'InternalHQID';

	INSERT INTO @tblCriterTypeCount
	  SELECT comp_PRIndustryType, 'H' As TypeCode, Sum(Case prsat_IsHeader When 'Y' Then 1 Else 0 End) As TypeCount
		FROM PRSearchAuditTrail WITH (NOLOCK)
			 INNER JOIN PRWebUser WITH (NOLOCK) ON prsat_WebUserID = prwu_WebUserID
			 INNER JOIN Company WITH (NOLOCK) on prwu_BBID = comp_CompanyID
	   WHERE prsat_CreatedDate BETWEEN @StartDate AND @EndDate
		 AND prsat_SearchType = 'Company'
		 AND comp_CompanyID NOT IN (SELECT CompanyID FROM @tblExclude)
	 GROUP BY comp_PRIndustryType;

	INSERT INTO @tblCriterTypeCount
	 SELECT comp_PRIndustryType, 'L' As TypeCode, Sum(Case prsat_IsCompanyLocation When 'Y' Then 1 Else 0 End) As TypeCount
	   FROM PRSearchAuditTrail WITH (NOLOCK)
			 INNER JOIN PRWebUser WITH (NOLOCK) ON prsat_WebUserID = prwu_WebUserID
			 INNER JOIN Company WITH (NOLOCK) on prwu_BBID = comp_CompanyID
	  WHERE prsat_CreatedDate BETWEEN @StartDate AND @EndDate
		AND prsat_SearchType = 'Company'
		AND comp_CompanyID NOT IN (SELECT CompanyID FROM @tblExclude)
	 GROUP BY comp_PRIndustryType;

	INSERT INTO @tblCriterTypeCount
	SELECT comp_PRIndustryType, 'CL' As TypeCode, Sum(Case prsat_IsClassification When 'Y' Then 1 Else 0 End) As TypeCount
	  FROM PRSearchAuditTrail WITH (NOLOCK)
			 INNER JOIN PRWebUser WITH (NOLOCK) ON prsat_WebUserID = prwu_WebUserID
			 INNER JOIN Company WITH (NOLOCK) on prwu_BBID = comp_CompanyID
	 WHERE prsat_CreatedDate BETWEEN @StartDate AND @EndDate
	   AND prsat_SearchType = 'Company'
	   AND comp_CompanyID NOT IN (SELECT CompanyID FROM @tblExclude)
	 GROUP BY comp_PRIndustryType;

	INSERT INTO @tblCriterTypeCount
	SELECT comp_PRIndustryType, 'CM' As TypeCode, Sum(Case prsat_IsCommodity When 'Y' Then 1 Else 0 End) As TypeCount
	  FROM PRSearchAuditTrail WITH (NOLOCK)
			 INNER JOIN PRWebUser WITH (NOLOCK) ON prsat_WebUserID = prwu_WebUserID
			 INNER JOIN Company WITH (NOLOCK) on prwu_BBID = comp_CompanyID
	 WHERE prsat_CreatedDate BETWEEN @StartDate AND @EndDate
	   AND prsat_SearchType = 'Company'
	   AND comp_CompanyID NOT IN (SELECT CompanyID FROM @tblExclude)
	 GROUP BY comp_PRIndustryType;

	INSERT INTO @tblCriterTypeCount
	SELECT comp_PRIndustryType, 'P' As TypeCode, Sum(Case prsat_IsProfile When 'Y' Then 1 Else 0 End) As TypeCount
	  FROM PRSearchAuditTrail WITH (NOLOCK)
			 INNER JOIN PRWebUser WITH (NOLOCK) ON prsat_WebUserID = prwu_WebUserID
			 INNER JOIN Company WITH (NOLOCK) on prwu_BBID = comp_CompanyID
	 WHERE prsat_CreatedDate BETWEEN @StartDate AND @EndDate
	   AND prsat_SearchType = 'Company'
	   AND comp_CompanyID NOT IN (SELECT CompanyID FROM @tblExclude)
	 GROUP BY comp_PRIndustryType;

	RETURN

END
Go



IF Exists (SELECT name FROM sysobjects WHERE name = 'ufn_GetCustomCaptionValue') 
    DROP FUNCTION dbo.ufn_GetCustomCaptionValue
GO

--
-- Returns the appropriate caption value for the specified family,
-- code, and culture
--
CREATE FUNCTION ufn_GetCustomCaptionValue(@CaptFamily varchar(30), 
                                          @CaptCode varchar(40), 
                                          @Culture varchar(10) = 'en-us') 
RETURNS varchar(max)
BEGIN
    DECLARE @Value varchar(max)

    SELECT @Value =  CASE @Culture WHEN 'es-mx' THEN capt_es WHEN 'fr-ca' THEN capt_fr ELSE capt_us END
      FROM Custom_Captions WITH (NOLOCK)
     WHERE capt_Family = @CaptFamily
       AND capt_code = @CaptCode;

    RETURN @Value
END
GO


IF Exists (SELECT name FROM sysobjects WHERE name = 'ufn_CompanyList') 
    DROP FUNCTION dbo.ufn_CompanyList
Go

-- 
-- Returns a company list that is reused my much of the EBB application.
CREATE FUNCTION ufn_CompanyList(@CompanyIDList varchar(5000), 
                                @Culture varchar(10) = 'en-us') 
RETURNS @tblCompanyList table (
    comp_CompanyID int,
    CompanyName varchar(104),
    Location varchar(200),
    IndustryType varchar(255),
    CompanyType varchar(255), 
    ListedDate datetime, 
    LastPublishedCSDate datetime)
BEGIN

    INSERT INTO @tblCompanyList
    SELECT comp_CompanyID, 
           comp_PRBookTradestyle, 
           CityStateCountryShort, 
           dbo.ufn_GetCustomCaptionValue('comp_PRIndustryType', comp_PRIndustryType, @Culture),
           dbo.ufn_GetCustomCaptionValue('comp_PRType', comp_PRType, @Culture), 
           comp_PRListedDate, 
           comp_PRLastPublishedCSDate
      FROM Company WITH (NOLOCK)
           INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
     WHERE comp_CompanyID IN (SELECT value FROM dbo.Tokenize(@CompanyIDList, ','))
       AND comp_PRListingStatus IN ('L', 'LUV', 'H', 'N3', 'N5', 'N6');

    RETURN
END
Go



IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[ufn_GetRadius]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    DROP FUNCTION [dbo].[ufn_GetRadius]
GO

--
-- Returns the Max Lat/Long and Min Lat/Long
-- to use when calculating the radius using
-- the specified postal code as the center.
--
-- Algorithm found on the 'Net.
--
CREATE FUNCTION dbo.ufn_GetRadius(
    @PostalCode nvarchar(50),
    @Miles decimal(18, 9)
)
RETURNS
    @MaxLongLats TABLE
    (
        Latitude decimal(12,8),
        Longitude decimal(13,8),
        MaxLatitude decimal(12,8),
        MinLatitude decimal(12,8),
        MaxLongitude decimal(13,8),
        MinLongitude decimal(13,8)
    )
AS
BEGIN
    --Declare variables
    DECLARE @Latitude decimal(12,8), @Longitude decimal(13,8)
    DECLARE @MaxLatitude decimal(12, 8), @MinLatitude decimal(12, 8)
    DECLARE @MaxLongitude decimal(13, 8), @MinLongitude decimal(13, 8)

    --Get the Lat/Long of the Postalcode
    SELECT @Latitude = prpc_Latitude, @Longitude = prpc_Longitude
      FROM PRPostalCode
     WHERE prpc_PostalCode = @PostalCode;

    --Postalcode not found?
    IF @@ROWCOUNT = 0
        RETURN 

    --Determine the maxes (69.17 is the # of miles/degree)
    SET @MaxLatitude = @Latitude + @Miles / 69.17
    SET @MinLatitude = @Latitude - (@MaxLatitude - @Latitude)
    SET @MaxLongitude = @Longitude + @Miles / (COS(@MinLatitude * PI() / 180) * 69.17)
    SET @MinLongitude = @Longitude - (@MaxLongitude - @Longitude)

    --Insert data into return table
    INSERT INTO @MaxLongLats
        (Latitude, Longitude, MaxLatitude, MinLatitude, MaxLongitude, MinLongitude)
    SELECT @Latitude, @Longitude, @MaxLatitude, @MinLatitude, @MaxLongitude, @MinLongitude
    RETURN
END
Go



IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[ufn_GetDistance]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    DROP FUNCTION [dbo].[ufn_GetDistance]
GO

--
-- Returns the distance between the 
-- specified coordinates
--
-- Algorithm found on the 'Net.
--
CREATE FUNCTION dbo.ufn_GetDistance
(
    @Latitude1 decimal(11,6),
    @Longitude1 decimal(11,6),
    @Latitude2 decimal(11,6),
    @Longitude2 decimal(11,6)
)
RETURNS decimal(11, 6)    --returns distance in miles
AS
BEGIN
    --If the 2 locations are the same, return 0 miles
    IF @Latitude1 = @Latitude2 AND @Longitude1 = @Longitude2
        RETURN 0

    --Convert the points from degrees to radians
    SET @Latitude1 = @Latitude1 * PI() / 180
    SET @Longitude1 = @Longitude1 * PI() / 180
    SET @Latitude2 = @Latitude2 * PI() / 180
    SET @Longitude2 = @Longitude2* PI() / 180

    --Temp var
    DECLARE @Distance decimal(18,13)
    SET @Distance = 0.0

    --Compute the distance
    SET @Distance = SIN(@Latitude1) * SIN(@Latitude2) + COS(@Latitude1) *
            COS(@Latitude2) * COS(@Longitude2 - @Longitude1)

    --Are the latitude and longitude points the same? Return 0
    IF @distance = 1    
        RETURN 0

    --Convert to miles (3963 = earth's radius)
    RETURN 3963 * (-1 * ATAN(@Distance / SQRT(1 - @Distance * @Distance)) + PI() / 2)
END
Go



IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[ufn_GetRadiusAddressListSeq]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    DROP FUNCTION [dbo].[ufn_GetRadiusAddressListSeq]
GO

--
-- Returns the appropriate sort order for the address type
-- when used for address radius searching.
--
CREATE FUNCTION [dbo].[ufn_GetRadiusAddressListSeq](@AdLi_Type varchar(40))  
RETURNS int AS  
BEGIN 
    DECLARE @SortCode int
    SELECT @SortCode = CASE @AdLi_Type
        WHEN 'PH' THEN 1
         WHEN 'S' THEN 2
        WHEN 'M' THEN 3
        WHEN 'W' THEN 4    
        WHEN 'I' THEN 5
        WHEN 'O' THEN 6
    END;
    RETURN @SortCode
END
GO



IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[ufn_IsAddressValidForRadius]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    DROP FUNCTION [dbo].[ufn_IsAddressValidForRadius]
GO

--
-- Determines if the specified AddressID is the one that is eligible
-- for radius searching.  Only one of a company's addresses are eligible.
-- The order of resolution is defined in ufn_GetRadiusAddressListSeq
--
CREATE FUNCTION [dbo].[ufn_IsAddressValidForRadius](@CompanyID int, @AddressID int)  
RETURNS char(1) AS  
BEGIN 

    DECLARE @ElibileAddressID int
    DECLARE @Eligible char(1)
    
    SELECT TOP 1 @ElibileAddressID = adli_AddressID
      FROM Address_Link WITH (NOLOCK)
           INNER JOIN Address WITH (NOLOCK) ON adli_AddressID = addr_AddressID
           INNER JOIN vPRLocation ON addr_PRCityID = prci_CityID
     WHERE adli_CompanyID = @CompanyID
       AND addr_PRPublish = 'Y'
       AND prcn_CountryID IN (1,2)
   ORDER BY dbo.ufn_GetRadiusAddressListSeq(adli_type);

    IF @ElibileAddressID = @AddressID BEGIN
        SET @Eligible = 'Y'
    END

    RETURN @Eligible
END
GO



IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[ufn_GetCompaniesWithinRadius]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    DROP FUNCTION [dbo].[ufn_GetCompaniesWithinRadius]
GO

--
-- Returns a table of Company IDs that have addresses within the specified
-- radius of the specified postal code.  
--
CREATE FUNCTION dbo.ufn_GetCompaniesWithinRadius(@PostalCode nvarchar(50),
                                                 @Miles decimal(11,6))
RETURNS @Companies TABLE (CompanyID int)  AS
BEGIN

	-- If we go over 9000, then nothing is returned
	-- This is a very simple alorithim that does not
	-- have a huge level of precision.  9000 more than
    -- covers the US
	IF (@Miles > 9000) BEGIN
		SET @Miles = 9000
	END

    DECLARE @PostalTable table (
        PostalCode varchar(10) PRIMARY KEY,
        Distance decimal(11, 6)
    )

    -- First determine which postal codes are within
    -- the specified radius of our source postal code
    INSERT INTO @PostalTable
    SELECT Postal.prpc_PostalCode,
           dbo.ufn_GetDistance(Postal.prpc_Latitude, Postal.prpc_Longitude, RAD.Latitude, RAD.Longitude) As Distance
      FROM PRPostalCode Postal, ufn_GetRadius(@PostalCode, @Miles) RAD
     WHERE (Postal.prpc_Latitude BETWEEN RAD.MinLatitude AND RAD.MaxLatitude) 
       AND (Postal.prpc_Longitude BETWEEN RAD.MinLongitude AND RAD.MaxLongitude) 
       AND (dbo.ufn_GetDistance(Postal.prpc_Latitude,Postal.prpc_Longitude,RAD.Latitude,RAD.Longitude) <= @Miles)

IF CHARINDEX(' ', @PostalCode) > 0 BEGIN
		--Canadian zip
		INSERT INTO @Companies
			SELECT distinct adli_CompanyID
			FROM Address WITH (NOLOCK)
				INNER JOIN Address_Link WITH (NOLOCK) on addr_AddressID = adli_AddressID
				INNER JOIN vPRLocation ON addr_PRCityID = prci_CityID
				INNER JOIN @PostalTable ON LTRIM(RTRIM(Addr_PostCode))=PostalCode AND addr_PRPublish = 'Y'
			WHERE 
				adli_Type IN ('PH', 'S', 'M', 'W', 'I', 'O') and
				prcn_CountryID = 2
				AND dbo.ufn_IsAddressValidForRadius(adli_CompanyID, addr_AddressID) = 'Y';
	END
	ELSE
	BEGIN
		--US Zip
		INSERT INTO @Companies
			SELECT distinct adli_CompanyID
			FROM Address WITH (NOLOCK)
				INNER JOIN Address_Link WITH (NOLOCK) on addr_AddressID = adli_AddressID
				INNER JOIN vPRLocation ON addr_PRCityID = prci_CityID
				INNER JOIN @PostalTable ON addr_USZipFive = PostalCode AND addr_PRPublish = 'Y'
			WHERE adli_Type IN ('PH', 'S', 'M', 'W', 'I', 'O')
				AND prcn_CountryID = 1
				AND dbo.ufn_IsAddressValidForRadius(adli_CompanyID, addr_AddressID) = 'Y';
	END

    RETURN
END
GO

IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[ufn_HasNote]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    DROP FUNCTION [dbo].[ufn_HasNote]
GO

--
-- Determines if the specified record
-- has a note the user has access to.
--
CREATE FUNCTION dbo.ufn_HasNote(
    @WebUserID int, 
    @HQID int,
    @AssociatedID int, 
    @AssociatedType varchar(40)
)
RETURNS char(1)
AS
BEGIN
    DECLARE @Return char(1)

    SELECT @Return = 'Y'
      FROM PRWebUserNote WITH (NOLOCK)
     WHERE prwun_AssociatedID = @AssociatedID
       AND prwun_AssociatedType = @AssociatedType
       AND ((prwun_WebUserID = @WebUserID AND prwun_IsPrivate = 'Y')
           OR (prwun_HQID = @HQID AND prwun_IsPrivate IS NULL))

    RETURN @Return
END
GO

IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[ufn_HasCSG]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    DROP FUNCTION [dbo].[ufn_HasCSG]
GO

--
-- Determines if the specified record
-- has any CSG data to display.
--
CREATE FUNCTION [dbo].[ufn_HasCSG](
    @CompanyID int
)
RETURNS char(1)
AS
BEGIN
	DECLARE @Return char(1)
	SELECT @Return = 'Y'
		FROM PRCSG WITH (NOLOCK)
		WHERE prcsg_CompanyID = @CompanyID

	RETURN @Return
END
GO

IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[ufn_HasNewClaimActivity]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    DROP FUNCTION [dbo].[ufn_HasNewClaimActivity]
GO

CREATE FUNCTION dbo.ufn_HasNewClaimActivity(
    @CompanyID int, 
    @ThresholdDate date
)
RETURNS char(1)
AS
BEGIN
    DECLARE @Return char(1)

    SELECT @Return = 'Y'
      FROM vPRBBOSClaimActivitySearch WITH (NOLOCK)
     WHERE CompanyID = @CompanyID
       AND CASE ClaimType WHEN 'BBSI Claim' THEN BBSiClaimThresholdDate ELSE FederalCivilCaseThresholdDate END >= @ThresholdDate
	   AND Status = 'O'
    RETURN @Return
END
GO


IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[ufn_HasMeritoriousClaim]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    DROP FUNCTION [dbo].[ufn_HasMeritoriousClaim]
GO

CREATE FUNCTION dbo.ufn_HasMeritoriousClaim(
    @CompanyID int, 
    @ThresholdDate date
)
RETURNS char(1)
AS
BEGIN
    DECLARE @Return char(1)

    SELECT @Return = 'Y'
      FROM PRSSFile WITH (NOLOCK)
     WHERE prss_RespondentCompanyId = @CompanyID
       AND prss_Status IN ('O', 'C')
       AND prss_Publish = 'Y'
       AND prss_Meritorious = 'Y'
       AND prss_MeritoriousDate >= @ThresholdDate

    RETURN @Return
END
GO



IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[ufn_GetAddressIDForList]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    DROP FUNCTION [dbo].[ufn_GetAddressIDForList]
GO

--
-- Returns the appropriate AddressID to use for a marketing list for the specifed type.
--
CREATE Function ufn_GetAddressIDForList(@CompanyID int, @AddressType varchar(40))
RETURNS INT
AS
BEGIN
    DECLARE @AddressID int 

    SELECT @AddressID = MIN(addr_AddressID)
    FROM Address_Link WITH (NOLOCK)
         INNER JOIN Address WITH (NOLOCK) ON adli_AddressID = addr_AddressID
     WHERE adli_CompanyID = @CompanyID
       AND adli_Type = @AddressType
       AND addr_PRPublish = 'Y';

    RETURN @AddressID;
END
Go



IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[ufn_GetClassificationsForList]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    DROP FUNCTION [dbo].[ufn_GetClassificationsForList]
GO

--
-- Returns a list of Classifications for inclusion in a marketing list
--
CREATE Function ufn_GetClassificationsForList(@CompanyID int)
RETURNS varchar(2000)
AS
BEGIN
    
    DECLARE @List varchar(2000)

    SELECT @List = COALESCE(@List + ', ', '') + prcl_Name
      FROM PRCompanyClassification WITH (NOLOCK)
           INNER JOIN PRClassification ON prc2_ClassificationID = prcl_ClassificationID
     WHERE prc2_CompanyID = @CompanyID;

    RETURN @List
END
Go

IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[ufn_GetCertificationsForList]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    DROP FUNCTION [dbo].ufn_GetCertificationsForList
GO

--
-- Returns a list of Certifications
--
CREATE Function ufn_GetCertificationsForList(@CompanyID int)
RETURNS varchar(2000)
AS
BEGIN
    DECLARE @List varchar(2000)
	SET @List = 
	CASE
		WHEN dbo.ufn_HasCertification_Organic(@CompanyID)='Y' AND dbo.ufn_HasCertification_FoodSafety(@CompanyID)='Y' THEN 'Organic, Food Safety'
		WHEN dbo.ufn_HasCertification_Organic(@CompanyID)='Y' AND dbo.ufn_HasCertification_FoodSafety(@CompanyID) IS NULL THEN 'Organic'
		WHEN dbo.ufn_HasCertification_Organic(@CompanyID) IS NULL AND dbo.ufn_HasCertification_FoodSafety(@CompanyID)='Y' THEN 'Food Safety'
		ELSE ''
	END

    RETURN @List
END
Go

IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[ufn_GetCompanyTradeAssociationForList]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    DROP FUNCTION [dbo].ufn_GetCompanyTradeAssociationForList
GO

CREATE Function dbo.ufn_GetCompanyTradeAssociationForList(@CompanyID int)
RETURNS varchar(3000)
AS
BEGIN
   DECLARE @List varchar(2000)

    SELECT @List = COALESCE(@List + ', ', '') + CAST(Capt_US AS VarChar(50))
	FROM Company WITH (NOLOCK)
		INNER JOIN PRCompanyTradeAssociation ON prcta_CompanyID = comp_CompanyID
		INNER JOIN Custom_Captions ON Capt_Code = prcta_TradeAssociationCode AND Capt_Family = 'prcta_TradeAssociationCode'
	WHERE comp_CompanyID = @CompanyID

    RETURN @List
END
GO

IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[ufn_GetCommoditiesForList]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    DROP FUNCTION [dbo].[ufn_GetCommoditiesForList]
GO

--
-- Returns a list of Commodities for inclusion in a marketing list
--
CREATE Function ufn_GetCommoditiesForList(@CompanyID int)
RETURNS varchar(6000)
AS
BEGIN

    -- Build a comma-delimited list of the commodities
    DECLARE @List varchar(6000)

    SELECT @List =  COALESCE(@List + ', ', '') +  dbo.ufn_GetCommodityPublishableName(prcm_CommodityID)
      FROM PRCommodity, PRCompanyCommodityAttribute
     WHERE prcca_CommodityID = prcm_CommodityID
       AND prcca_CompanyID = @CompanyID
       AND (prcca_Publish = 'Y' OR prcca_PublishWithGM = 'Y')
       AND prcca_Deleted IS NULL
       AND prcm_Deleted IS NULL
    GROUP BY prcm_CommodityID, prcm_Name
    ORDER BY MIN(prcca_Sequence);

    RETURN @List;
END
Go




IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[ufn_GetVCardAddressListSeq]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    DROP FUNCTION [dbo].[ufn_GetVCardAddressListSeq]
GO

--
-- Returns the appropriate sort order for the address type
-- when used for creating a VCard
--
CREATE FUNCTION [dbo].[ufn_GetVCardAddressListSeq](@AdLi_Type varchar(40))  
RETURNS int AS  
BEGIN 
    DECLARE @SortCode int
    SELECT @SortCode = CASE @AdLi_Type
        WHEN 'M' THEN 1    
        WHEN 'PH' THEN 2
        WHEN 'W' THEN 3         
        WHEN 'I' THEN 4
        WHEN 'O' THEN 5
    END;
    RETURN @SortCode
END
GO



IF Exists (SELECT name FROM sysobjects WHERE name = 'ufn_GetWebUserLocation') 
    DROP FUNCTION dbo.ufn_GetWebUserLocation
GO

--
-- Returns the location of the specified user
--
CREATE FUNCTION ufn_GetWebUserLocation(@WebUserID int) 
RETURNS varchar(500)
BEGIN

    Declare @Location varchar(500)

    SELECT @Location = CityStateCountryShort
      FROM PRWebUser WITH (NOLOCK)
           INNER JOIN Company WITH (NOLOCK) on prwu_BBID = comp_CompanyID
           INNER JOIN vPRLocation on comp_PRListingCityID = prci_CityID
     WHERE prwu_WebUserID=@WebUserID;

    Return @Location
END
GO



If Exists (Select name from sysobjects where name = 'ufn_GetRatingNumerals' and type='TF') 
    Drop Function dbo.ufn_GetRatingNumerals
Go

CREATE FUNCTION dbo.ufn_GetRatingNumerals(@Culture varchar(10), @IndustryType varchar(40))
RETURNS @RatingNumreals TABLE (
    Name varchar(10),
    Description varchar(MAX),
    Numeral int)
AS
BEGIN
	DECLARE @Condition varchar(10)
	SET @Condition = '%,' + @IndustryType + ',%'

    INSERT INTO @RatingNumreals
    SELECT prrn_Name, dbo.ufn_GetCustomCaptionValue('prrn_Name', prrn_Name, @Culture) As NumeralDescription, CONVERT(int, SUBSTRING(prrn_Name, 2, LEN(prrn_Name)-2)) As Numeral 
      FROM PRRatingNumeral
     WHERE prrn_IndustryType LIKE @Condition
	   AND prrn_RatingNumeralID <> 149;
    
	INSERT INTO @RatingNumreals
    SELECT prcw_Name, dbo.ufn_GetCustomCaptionValue('prcw_Name', prcw_Name, @Culture) As NumeralDescription, CONVERT(int, SUBSTRING(prcw_Name, 2, LEN(prcw_Name)-2)) As Numeral
      FROM PRCreditWorthRating 
     WHERE prcw_IsNumeral = 'Y'
       AND prcw_IndustryType LIKE @Condition;
    
	IF (@IndustryType != 'L') BEGIN
		INSERT INTO @RatingNumreals
		SELECT prpy_Name, dbo.ufn_GetCustomCaptionValue('prpy_Name', prpy_Name, @Culture) As NumeralDescription, CONVERT(int, SUBSTRING(prpy_Name, 2, LEN(prpy_Name)-2)) As Numeral
		  FROM PRPayRating 
		 WHERE prpy_IsNumeral = 'Y';
	    
		INSERT INTO @RatingNumreals
		SELECT prin_Name, dbo.ufn_GetCustomCaptionValue('prin_Name', prin_Name, @Culture) As NumeralDescription, CONVERT(int, SUBSTRING(prin_Name, LEN(prin_Name)-2, LEN(prin_Name))) As Numeral
		  FROM PRIntegrityRating 
		 WHERE prin_IsNumeral = 'Y';
	    
		INSERT INTO @RatingNumreals
		SELECT RTRIM(capt_code), CAST(capt_US AS VARCHAR(MAX)) As NumeralDescription, CONVERT(int, SUBSTRING(RTRIM(capt_code), 2, LEN(RTRIM(capt_code))-2)) As Numeral
		  FROM custom_captions
		 WHERE capt_Family = 'CreditSheetNumerals';
	END  

    RETURN
END
Go

IF Exists (SELECT name FROM sysobjects WHERE name = 'ufn_GetAddressReplicationTargetDefault') 
    DROP FUNCTION dbo.ufn_GetAddressReplicationTargetDefault
GO

CREATE FUNCTION ufn_GetAddressReplicationTargetDefault(@SourceDefaultValue varchar(1), @TargetCompanyID int, @DefaultFlagType int) 
RETURNS varchar(1)
BEGIN
    DECLARE @Return varchar(1)
    
    IF (@SourceDefaultValue IS NOT NULL) BEGIN

        DECLARE @CurrentFlag varchar(1)
        DECLARE @DefaultTable table (
            DefaultType int,
            DefaultFlag varchar(1)
        )

        INSERT INTO @DefaultTable
        SELECT 0, adli_PRDefaultMailing FROM Address_Link WITH (NOLOCK) WHERE adli_CompanyID=@TargetCompanyID AND adli_PRDefaultMailing = 'Y'
        UNION
        SELECT 2, adli_PRDefaultTax FROM Address_Link WITH (NOLOCK) WHERE adli_CompanyID=@TargetCompanyID AND adli_PRDefaultTax = 'Y' 

        SELECT @CurrentFlag = DefaultFlag
          FROM @DefaultTable
         WHERE DefaultType = @DefaultFlagType;

        IF @CurrentFlag IS NULL BEGIN
            SET @Return = @SourceDefaultValue
        END 
    END

    RETURN @Return            

END
GO

IF Exists (SELECT name FROM sysobjects WHERE name = 'ufn_ConcatURL') 
    DROP FUNCTION dbo.ufn_ConcatURL
GO

-- =============================================
-- Author:        Tad M. Eness
-- Create date: 2008/06/02
-- Description:    Append a string to a URL, filling in the seperator if needed
-- =============================================
CREATE FUNCTION ufn_ConcatURL 
(
    -- Add the parameters for the function here
    @URL1 nvarchar(max),
    @URL2 nvarchar(max)
)
RETURNS nvarchar(max)
AS
Begin
    If Len(Coalesce(@URL1, '')) = 0
        Return @URL2;

    Return
        @URL1
        + Case Right(@URL1, 1) When '/' Then '' Else '/' End
        + Case Left(@URL2, 1) When '/' Then Substring(@URL2, 2, Len(@URL2)) Else @URL2 End
End
GO


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ufn_GetPrimaryService]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.ufn_GetPrimaryService
GO

CREATE FUNCTION dbo.ufn_GetPrimaryService(@CompanyID int)  
RETURNS nvarchar(100) AS  
BEGIN 

	DECLARE @ServiceCode nvarchar(100)

	SELECT @ServiceCode = prse_ServiceCode
	  FROM Company WITH (NOLOCK)
		   INNER JOIN PRService ON comp_PRHQID = prse_HQID
	 WHERE prse_Primary = 'Y'
	   AND comp_CompanyID=@CompanyID;

	RETURN @ServiceCode
END;
Go

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ufn_GetCompanyRelationships]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.ufn_GetCompanyRelationships
GO

CREATE FUNCTION dbo.ufn_GetCompanyRelationships(@CompanyID int)
RETURNS @CompanyRelationships TABLE (
    prcr_CompanyRelationshipId int,
    CompanyID int,
    prcr_RightCompanyID int, 
    prcr_LeftCompanyID int,
    LastReportedDate datetime,
    Active char(1),
	prcr_CategoryType varchar(10))
AS
BEGIN

	INSERT INTO @CompanyRelationships
	SELECT prcr_CompanyRelationshipId,
           CASE WHEN prcr_LeftCompanyID = @CompanyID THEN prcr_RightCompanyID ELSE prcr_LeftCompanyID END As CompanyID,
           prcr_RightCompanyID,
           prcr_LeftCompanyID,
		   prcr_LastReportedDate,
		   prcr_Active,
		   CASE WHEN (prcr_Type IN (1, 4, 5, 7)) THEN 1  
            WHEN (prcr_Type IN (9, 10, 11, 12, 13, 14, 15, 16)) THEN 2  
            WHEN (prcr_Type IN (23, 24)) THEN 3  
            WHEN (prcr_Type IN (27, 28, 29)) THEN 4  
            WHEN (prcr_Type IN (30, 31, 32)) THEN 5  
            WHEN (prcr_Type IN (33, 34)) THEN 6  
            ELSE NULL END AS prcr_CategoryType
	  FROM PRCompanyRelationship WITH (NOLOCK)
	 WHERE (prcr_LeftCompanyID = @CompanyID OR prcr_RightCompanyID = @CompanyID)
	   AND prcr_Type not in (27, 28, 29)
	   AND prcr_Active is not null;
	RETURN
END
GO


If Exists (Select name from sysobjects where name = 'ufn_GetTableCounts' and type in (N'FN', N'IF', N'TF')) 
    Drop Function dbo.ufn_GetTableCounts
Go

CREATE FUNCTION [dbo].[ufn_GetTableCounts](@CompanyID int, @IncludeAssociatedIDs bit = 1)
RETURNS @ReturnTableCount TABLE (
		TableName varchar(255),
		RecordCount int,
	    LastUpdate datetime)
AS
BEGIN
	DECLARE @TableCount TABLE (
		TableName varchar(255),
		RecordCount int,
	    LastUpdate datetime
	)
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'Address_Link', COUNT(1), MAX(AdLi_UpdatedDate) FROM Address_Link WHERE AdLi_CompanyID=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'Cases', COUNT(1), MAX(Case_UpdatedDate) FROM Cases WHERE Case_PrimaryCompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'Comm_Link', COUNT(1), MAX(CmLI_UpdatedDate) FROM Comm_Link WHERE CmLi_Comm_CompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'Company', COUNT(1), MAX(Comp_UpdatedDate) FROM Company WHERE Comp_CompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'Company', COUNT(1), MAX(Comp_UpdatedDate) FROM Company WHERE comp_PRHQId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'Company', COUNT(1), MAX(Comp_UpdatedDate) FROM Company WHERE comp_PRServicesThroughCompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'Email', COUNT(1), MAX(Emai_UpdatedDate) FROM vCompanyEmail WHERE ELink_RecordID=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'Email', COUNT(1), MAX(Emai_UpdatedDate) FROM vPersonEmail WHERE emai_CompanyID=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'Lead', COUNT(1), MAX(Lead_UpdatedDate) FROM Lead WHERE Lead_PrimaryCompanyID=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'Library', COUNT(1), MAX(Libr_UpdatedDate) FROM Library WHERE Libr_CompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'Marketing', COUNT(1), MAX(Mrkt_UpdatedDate) FROM Marketing WHERE Mrkt_CompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'Opportunity', COUNT(1), MAX(Oppo_UpdatedDate) FROM Opportunity WHERE Oppo_PrimaryCompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'Opportunity', COUNT(1), MAX(Oppo_UpdatedDate) FROM Opportunity WHERE oppo_PRReferredByCompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'OpportunityHistory', COUNT(1), MAX(Opph_UpdatedDate) FROM OpportunityHistory WHERE Oppo_PrimaryCompanyID=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'Person', COUNT(1), MAX(Pers_UpdatedDate) FROM Person WHERE Pers_CompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'Person_Link', COUNT(1), MAX(PeLi_UpdatedDate) FROM Person_Link WHERE PeLi_CompanyID=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'Person_Link', COUNT(1), MAX(PeLi_UpdatedDate) FROM Person_Link WHERE peli_PRCompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'Phone', COUNT(1), MAX(Phon_UpdatedDate) FROM vPRCompanyPhone WHERE plink_RecordID=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'Phone', COUNT(1), MAX(Phon_UpdatedDate) FROM vPRPersonPhone WHERE phon_CompanyID=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRAdCampaign', COUNT(1), MAX(pradc_UpdatedDate) FROM PRAdCampaign WHERE pradc_CompanyID=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRAdCampaignAuditTrail', COUNT(1), MAX(pradcat_UpdatedDate) FROM PRAdCampaignAuditTrail WHERE pradcat_CompanyID=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRARAging', COUNT(1), MAX(praa_UpdatedDate) FROM PRARAging WHERE praa_CompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRARAgingDetail', COUNT(1), MAX(praad_UpdatedDate) FROM PRARAgingDetail WHERE praad_ManualCompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRARTranslation', COUNT(1), MAX(prar_UpdatedDate) FROM PRARTranslation WHERE prar_CompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRARTranslation', COUNT(1), MAX(prar_UpdatedDate) FROM PRARTranslation WHERE prar_PRCoCompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRBBScore', COUNT(1), MAX(prbs_UpdatedDate) FROM PRBBScore WHERE prbs_CompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRBusinessEvent', COUNT(1), MAX(prbe_UpdatedDate) FROM PRBusinessEvent WHERE prbe_CompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRBusinessReportRequest', COUNT(1), MAX(prbr_UpdatedDate) FROM PRBusinessReportRequest WHERE prbr_RequestingCompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRCompanyAlias', COUNT(1), MAX(pral_UpdatedDate) FROM PRCompanyAlias WHERE pral_CompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRCompanyBank', COUNT(1), MAX(prcb_UpdatedDate) FROM PRCompanyBank WHERE prcb_CompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRCompanyBrand', COUNT(1), MAX(prc3_UpdatedDate) FROM PRCompanyBrand WHERE prc3_CompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRCompanyClassification', COUNT(1), MAX(prc2_UpdatedDate) FROM PRCompanyClassification WHERE prc2_CompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRCompanyCommodityAttribute', COUNT(1), MAX(prcca_UpdatedDate) FROM PRCompanyCommodityAttribute WHERE prcca_CompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRCompanyInfoProfile', COUNT(1), MAX(prc5_UpdatedDate) FROM PRCompanyInfoProfile WHERE prc5_CompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRCompanyLicense', COUNT(1), MAX(prli_UpdatedDate) FROM PRCompanyLicense WHERE prli_CompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRCompanyProductProvided', COUNT(1), MAX(prcprpr_UpdatedDate) FROM PRCompanyProductProvided WHERE prcprpr_CompanyID=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRCompanyProfile', COUNT(1), MAX(prcp_UpdatedDate) FROM PRCompanyProfile WHERE prcp_CompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRCompanyRegion', COUNT(1), MAX(prcd_UpdatedDate) FROM PRCompanyRegion WHERE prcd_CompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRCompanyRelationship', COUNT(1), MAX(prcr_UpdatedDate) FROM PRCompanyRelationship WHERE prcr_LeftCompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRCompanyRelationship', COUNT(1), MAX(prcr_UpdatedDate) FROM PRCompanyRelationship WHERE prcr_RightCompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRCompanySearch', COUNT(1), MAX(prcse_UpdatedDate) FROM PRCompanySearch WHERE prcse_CompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRCompanyServiceProvided', COUNT(1), MAX(prcserpr_UpdatedDate) FROM PRCompanyServiceProvided WHERE prcserpr_CompanyID=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRCompanySpecie', COUNT(1), MAX(prcspc_UpdatedDate) FROM PRCompanySpecie WHERE prcspc_CompanyID=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRCompanyStockExchange', COUNT(1), MAX(prc4_UpdatedDate) FROM PRCompanyStockExchange WHERE prc4_CompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRCompanyTerminalMarket', COUNT(1), MAX(prct_UpdatedDate) FROM PRCompanyTerminalMarket WHERE prct_CompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRCompanyProductProvided', COUNT(1), MAX(prcprpr_UpdatedDate) FROM PRCompanyProductProvided WHERE prcprpr_CompanyID = @CompanyID;
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRCompanyServiceProvided', COUNT(1), MAX(prcserpr_UpdatedDate) FROM PRCompanyServiceProvided WHERE prcserpr_CompanyID = @CompanyID;
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRCompanySpecie', COUNT(1), MAX(prcspc_UpdatedDate) FROM PRCompanySpecie WHERE prcspc_CompanyID = @CompanyID;
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRCreditSheet', COUNT(1), MAX(prcs_UpdatedDate) FROM PRCreditSheet WHERE prcs_CompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRDescriptiveLine', COUNT(1), MAX(prdl_UpdatedDate) FROM PRDescriptiveLine WHERE prdl_CompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRDescriptiveLineUsage', COUNT(1), MAX(prd3_UpdatedDate) FROM PRDescriptiveLineUsage WHERE prd3_CompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRDRCLicense', COUNT(1), MAX(prdr_UpdatedDate) FROM PRDRCLicense WHERE prdr_CompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRExceptionQueue', COUNT(1), MAX(preq_UpdatedDate) FROM PRExceptionQueue WHERE preq_CompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRExternalLinkAuditTrail', COUNT(1), MAX(prelat_UpdatedDate) FROM PRExternalLinkAuditTrail WHERE prelat_CompanyID=@CompanyID
--	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRFile', COUNT(1), MAX(prfi_UpdatedDate) FROM PRFile WHERE prfi_CompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRFinancial', COUNT(1), MAX(prfs_UpdatedDate) FROM PRFinancial WHERE prfs_CompanyId=@CompanyID
--	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PROwnership', COUNT(1), MAX(prow_UpdatedDate) FROM PROwnership WHERE prow_CompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRPACALicense', COUNT(1), MAX(prpa_UpdatedDate) FROM PRPACALicense WHERE prpa_CompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRRating', COUNT(1), MAX(prra_UpdatedDate) FROM PRRating WHERE prra_CompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRRequest', COUNT(1), MAX(prreq_UpdatedDate) FROM PRRequest WHERE prreq_CompanyID=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRRequest', COUNT(1), MAX(prreq_UpdatedDate) FROM PRRequest WHERE prreq_HQID=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRSearchAuditTrail', COUNT(1), MAX(prsat_UpdatedDate) FROM PRSearchAuditTrail WHERE prsat_CompanyID=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRSearchWizardAuditTrail', COUNT(1), MAX(prswau_UpdatedDate) FROM PRSearchWizardAuditTrail WHERE prswau_CompanyID=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRSelfServiceAuditTrail', COUNT(1), MAX(prssat_UpdatedDate) FROM PRSelfServiceAuditTrail WHERE prssat_CompanyID=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRSelfServiceAuditTrail', COUNT(1), MAX(prssat_UpdatedDate) FROM PRSelfServiceAuditTrail WHERE prssat_HQID=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRService', COUNT(1), MAX(prse_UpdatedDate) FROM PRService WHERE prse_BillToCompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRService', COUNT(1), MAX(prse_UpdatedDate) FROM PRService WHERE prse_CompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRService', COUNT(1), MAX(prse_UpdatedDate) FROM PRService WHERE prse_HQID=@CompanyID
--	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRServiceAlaCarte', COUNT(1), MAX(prsac_UpdatedDate) FROM PRServiceAlaCarte WHERE prsac_SubjectBBID=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRServiceUnitAllocation', COUNT(1), MAX(prun_UpdatedDate) FROM PRServiceUnitAllocation WHERE prun_CompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRServiceUnitAllocation', COUNT(1), MAX(prun_UpdatedDate) FROM PRServiceUnitAllocation WHERE prun_HQID=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRServiceUnitUsage', COUNT(1), MAX(prsuu_UpdatedDate) FROM PRServiceUnitUsage WHERE prsuu_CompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRServiceUnitUsage', COUNT(1), MAX(prsuu_UpdatedDate) FROM PRServiceUnitUsage WHERE prsuu_HQID=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRSSContact', COUNT(1), MAX(prssc_UpdatedDate) FROM PRSSContact WHERE prssc_CompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRSSFile', COUNT(1), MAX(prss_UpdatedDate) FROM PRSSFile WHERE prss_3rdPartyCompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRSSFile', COUNT(1), MAX(prss_UpdatedDate) FROM PRSSFile WHERE prss_ClaimantCompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRSSFile', COUNT(1), MAX(prss_UpdatedDate) FROM PRSSFile WHERE prss_RespondentCompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRTESRequest', COUNT(1), MAX(prtesr_UpdatedDate) FROM PRTESRequest WHERE prtesr_ResponderCompanyID=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRTESForm', COUNT(1), MAX(prtf_UpdatedDate) FROM PRTESForm WHERE prtf_CompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRTransaction', COUNT(1), MAX(prtx_UpdatedDate) FROM PRTransaction WHERE prtx_CompanyId=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRWebAuditTrail', COUNT(1), MAX(prwsat_UpdatedDate) FROM PRWebAuditTrail WHERE prwsat_CompanyID=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRWebServiceLicenseKey', COUNT(1), MAX(prwslk_UpdatedDate) FROM PRWebServiceLicenseKey WHERE prwslk_HQID=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRWebUser', COUNT(1), MAX(prwu_UpdatedDate) FROM PRWebUser WHERE prwu_BBID=@CompanyID
	--INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRWebUser', COUNT(1), MAX(prwu_UpdatedDate) FROM PRWebUser WHERE prwu_CDSWBBID=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRWebUser', COUNT(1), MAX(prwu_UpdatedDate) FROM PRWebUser WHERE prwu_HQID=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRWebUser', COUNT(1), MAX(prwu_UpdatedDate) FROM PRWebUser WHERE prwu_MergedCompanyID=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRWebUserContact', COUNT(1), MAX(prwuc_UpdatedDate) FROM PRWebUserContact WHERE prwuc_AssociatedCompanyID=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRWebUserContact', COUNT(1), MAX(prwuc_UpdatedDate) FROM PRWebUserContact WHERE prwuc_CompanyID=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRWebUserContact', COUNT(1), MAX(prwuc_UpdatedDate) FROM PRWebUserContact WHERE prwuc_HQID=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRWebUserCustomData', COUNT(1), MAX(prwucd_UpdatedDate) FROM PRWebUserCustomData WHERE prwucd_CompanyID=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRWebUserCustomData', COUNT(1), MAX(prwucd_UpdatedDate) FROM PRWebUserCustomData WHERE prwucd_HQID=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRWebUserList', COUNT(1), MAX(prwucl_UpdatedDate) FROM PRWebUserList WHERE prwucl_CompanyID=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRWebUserList', COUNT(1), MAX(prwucl_UpdatedDate) FROM PRWebUserList WHERE prwucl_HQID=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRWebUserNote', COUNT(1), MAX(prwun_UpdatedDate) FROM PRWebUserNote WHERE prwun_CompanyID=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRWebUserNote', COUNT(1), MAX(prwun_UpdatedDate) FROM PRWebUserNote WHERE prwun_HQID=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRWebUserSearchCriteria', COUNT(1), MAX(prsc_UpdatedDate) FROM PRWebUserSearchCriteria WHERE prsc_CompanyID=@CompanyID
	INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRWebUserSearchCriteria', COUNT(1), MAX(prsc_UpdatedDate) FROM PRWebUserSearchCriteria WHERE prsc_HQID=@CompanyID
	IF (@IncludeAssociatedIDs = 0) BEGIN
		INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRExternalLinkAuditTrail', COUNT(1), MAX(prelat_UpdatedDate) FROM PRExternalLinkAuditTrail WHERE prelat_AssociatedID=@CompanyID AND prelat_AssociatedType='C'
		--INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRRequestDetail', COUNT(1), MAX(prrc_UpdatedDate) FROM PRRequestDetail WHERE prrc_AssociatedID=@CompanyID AND prrc_AssociatedType='C'
		INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRWebAuditTrail', COUNT(1), MAX(prwsat_UpdatedDate) FROM PRWebAuditTrail WHERE prwsat_AssociatedID=@CompanyID AND prwsat_AssociatedType='C'
		INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRWebUserCustomData', COUNT(1), MAX(prwucd_UpdatedDate) FROM PRWebUserCustomData WHERE prwucd_AssociatedID=@CompanyID AND prwucd_AssociatedType='C'
		INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRWebUserListDetail', COUNT(1), MAX(prwuld_UpdatedDate) FROM PRWebUserListDetail WHERE prwuld_AssociatedID=@CompanyID AND prwuld_AssociatedType='C'
		INSERT INTO @TableCount (tablename, recordcount, lastupdate) SELECT 'PRWebUserNote', COUNT(1), MAX(prwun_UpdatedDate) FROM PRWebUserNote WHERE prwun_AssociatedID=@CompanyID AND prwun_AssociatedType='C'
	END
	INSERT INTO @ReturnTableCount
	SELECT TableName, SUM(recordcount) As RecordCount, MAX(lastupdate) As LastUpdated
	  FROM @TableCount
	 WHERE recordcount > 0
	GROUP BY tablename;
	RETURN
END
Go


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ufn_IsEligibeForDelete]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.ufn_IsEligibeForDelete
GO

CREATE FUNCTION dbo.ufn_IsEligibeForDelete(@CompanyID int, @IncludeAssociatedIDs bit = 1, @ForMerge bit = 0)
RETURNS char(1)
AS
BEGIN

	DECLARE @TableCounts table (
		tablename varchar(255),
		recordcount int,
		lastupdate datetime
	)

	INSERT INTO @TableCounts(tablename, recordcount, lastupdate)
	SELECT * FROM dbo.ufn_GetTableCounts(@CompanyID, @IncludeAssociatedIDs)

	DECLARE @Count int

	SELECT @Count = COUNT(1)
	  FROM @TableCounts
	 WHERE tablename IN (
			'PRAdCampaign',
			'PRBusinessReportRequest',
			'PRService',
			'PRServiceUnitAllocation',
			'PRServiceUnitUsage',
			'PRSSFile',
			'PRWebServiceLicenseKey',				
			'PRWebUser');

	--
	-- If we didn't find any records, but this
	-- is not for merging companies, check the
	-- records would have been updated if it were
	-- a merge.
	IF (@Count = 0 AND @ForMerge = 0) BEGIN
		SELECT @Count = COUNT(1)
		  FROM @TableCounts
		 WHERE tablename IN (
				'PRExternalLinkAuditTrail',
				'PRRequest',
				'PRRequestDetail',
		    	'PRSearchAuditTrail',
	    		'PRSearchWizardAuditTrail',
     			'PRSelfServiceAuditTrail',
				'PRWebAuditTrail',
			    'PRWebUserContact',
			    'PRWebUserCustomData',
			    'PRWebUserList',
			    'PRWebUserNote',
			    'PRWebUserSearchCriteria'
				);	
	END



	DECLARE @CanDelete char(1)

	IF @Count > 0 BEGIN
		SET @CanDelete = 'N'
	END ELSE BEGIN
		SET @CanDelete = 'Y'
	END

	RETURN @CanDelete
END
Go


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ufn_GetCompanyAffiliations]'))
DROP FUNCTION dbo.ufn_GetCompanyAffiliations
GO

CREATE FUNCTION dbo.ufn_GetCompanyAffiliations (@CompanyID int)
RETURNS @CompanyRelationships TABLE (
    prcr_CompanyRelationshipId int, 
    CompanyID int,
    CompanyName varchar(500), 
    prcr_OwnershipPct decimal(24,6),
    prcr_Type int,
    prcr_Active char(1))
AS
BEGIN

	INSERT INTO @CompanyRelationships
	SELECT prcr_CompanyRelationshipId, CompanyID, prcse_FullName, prcr_OwnershipPct, prcr_Type, prcr_Active
      FROM (
	SELECT prcr_CompanyRelationshipId, 
           CASE WHEN prcr_LeftCompanyID = @CompanyID THEN prcr_RightCompanyID ELSE prcr_LeftCompanyID END As CompanyID,
           prcr_OwnershipPct,
		   prcr_Type,
		   prcr_Active
	  FROM PRCompanyRelationship
	 WHERE (prcr_LeftCompanyID = @CompanyID OR prcr_RightCompanyID = @CompanyID)
	   AND prcr_Type = 29) T1
           INNER JOIN PRCompanySearch ON CompanyID = prcse_CompanyID;


	RETURN
END
Go

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ufn_Divide]'))
DROP FUNCTION dbo.ufn_Divide
GO

CREATE FUNCTION dbo.ufn_Divide(@Quotient numeric(24,6), @Divisor numeric(24,6))
RETURNS numeric(24,6)
AS
BEGIN
	DECLARE @Result numeric(24,6)

	IF (@Divisor = 0) BEGIN
		SET @Result = 0
	END ELSE BEGIN
		SET @Result = @Quotient / @Divisor
	END

	RETURN @Result
END
Go


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ufn_GetOtherRelatedCompanies]'))
DROP FUNCTION dbo.ufn_GetOtherRelatedCompanies
GO

CREATE FUNCTION dbo.ufn_GetOtherRelatedCompanies (@CompanyID int, @Type varchar(40))
RETURNS @CompanyRelationships TABLE (
    CompanyID int,
    CompanyName varchar(500), 
    CompanyFullName  varchar(500))
AS
BEGIN

	INSERT INTO @CompanyRelationships
    SELECT DISTINCT comp_CompanyID, comp_Name, prcse_FullName
      FROM Company
           INNER JOIN PRCompanySearch ON comp_CompanyID = prcse_CompanyID
     WHERE comp_CompanyID IN       
	    (
 		SELECT CASE WHEN prcr_LeftCompanyID = @CompanyID THEN prcr_RightCompanyID ELSE prcr_LeftCompanyID END As CompanyID
 		  FROM PRCompanyRelationship WITH (NOLOCK)
 		 WHERE (prcr_LeftCompanyID = @CompanyID OR prcr_RightCompanyID = @CompanyID)
		   AND prcr_Type = @Type
		   AND prcr_Active = 'Y'
		);

	RETURN
END
Go



IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ufn_GetReportURL]'))
DROP FUNCTION dbo.ufn_GetReportURL
GO

CREATE FUNCTION dbo.ufn_GetReportURL(@ReportCode varchar(40))
RETURNS varchar(500)
AS
BEGIN
	DECLARE @Result varchar(500)

	SET @Result = dbo.ufn_GetCustomCaptionValue('SSRS', 'URL', 'en-us')
	SET @Result = @Result + dbo.ufn_GetCustomCaptionValue('SSRS', @ReportCode, 'en-us')


	RETURN @Result
END
Go




IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ufn_GetFieldCaption]'))
	DROP FUNCTION dbo.ufn_GetFieldCaption
GO

CREATE FUNCTION dbo.ufn_GetFieldCaption(@Field varchar(500))
RETURNS varchar(500)
AS
BEGIN

    Declare @Caption varchar(500)

    DECLARE @FieldTable TABLE(idx smallint, token varchar(8000))    
    DECLARE @FieldCnt smallint, @LoopIdx smallint
    DECLARE @token varchar(8000)
    DECLARE @TempCaption nvarchar(100)

    INSERT INTO @FieldTable SELECT * FROM dbo.Tokenize(@Field, ',');
    SELECT @FieldCnt = COUNT(1) FROM @FieldTable;

	SET @Caption = ''
    IF (@FieldCnt > 1) BEGIN
      --  Get the value for each caption
      SET @LoopIdx = 0
      WHILE (@LoopIdx < @FieldCnt) BEGIN

        SET @token = null
        SELECT @token = token FROM @FieldTable WHERE idx = @Loopidx;

        IF (@token is null) BEGIN
			SET @LoopIdx = @FieldCnt -- Break out of our loop
		END ELSE BEGIN
    	    
			SET @TempCaption = NULL
			SELECT @TempCaption = Capt_US from Custom_Captions  WITH (NOLOCK) where Capt_code = @Token AND capt_family = 'ColNames';
			IF (LEN(@Caption) > 0) BEGIN
				SET @Caption = @Caption + ', '
			END

			SET @Caption = @Caption + ISNULL(@TempCaption, @token)
			SET @LoopIdx = @LoopIdx + 1
        End
      END
    END ELSE BEGIN
		SET @Caption = NULL
    	SELECT @Caption = ISNULL(Capt_US, @Field) from Custom_Captions WITH (NOLOCK) where Capt_code = @Field AND capt_family = 'ColNames';
    END

	RETURN ISNULL(@Caption, @Field)
END
GO


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ufn_GetPayReportCount]'))
	DROP FUNCTION dbo.ufn_GetPayReportCount
GO

CREATE FUNCTION dbo.ufn_GetPayReportCount(@CompanyID int)
RETURNS int
AS
BEGIN

	DECLARE @Count int = 0
	
	DECLARE @IndustryType varchar(40)
	SELECT @IndustryType = comp_PRIndustryType 
	  FROM Company WITH (NOLOCK)
	 WHERE comp_CompanyID = @CompanyID;
	 
	 IF (@IndustryType = 'L') BEGIN
		SELECT @Count = COUNT(DISTINCT praa_CompanyId)
		 FROM  Company WITH (NOLOCK)
			   INNER JOIN PRARAging WITH (NOLOCK) ON Comp_CompanyId = praa_CompanyId
			   INNER JOIN PRARAgingDetail WITH (NOLOCK) ON praa_ARAgingId = praad_ARAgingId 
		 WHERE comp_PRListingStatus IN ('L', 'H', 'LUV', 'N2')
		   AND comp_PRIndustryType = 'L'
		   AND praa_Date >= DATEADD(day, -91, GETDATE())
		   AND praad_SubjectCompanyId = @CompanyID;
	END
	
	RETURN @Count
END
Go

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ufn_GetCustomCaptionValueList]'))
	DROP FUNCTION dbo.ufn_GetCustomCaptionValueList
GO

CREATE FUNCTION dbo.ufn_GetCustomCaptionValueList(@CaptFamily varchar(30),
                                                  @CaptCodeList varchar(500))
RETURNS varchar(5000)
AS
BEGIN

	DECLARE @Meaning varchar(5000)

	SELECT @Meaning = COALESCE(@Meaning + ', ', '') + CAST(capt_US as varchar(100))
	  FROM Custom_Captions
	 WHERE capt_family = @CaptFamily
	   AND capt_code IN (SELECT value FROM dbo.Tokenize(@CaptCodeList, ',') WHERE value <> '')
	ORDER BY capt_order

	RETURN @Meaning
END
Go

CREATE OR ALTER FUNCTION dbo.ufn_IsEligibleForManualTES2(@ResponderCompanyID int, 
                                               @SubjectCompanyID int,
											   @WithTESExclusion bit=1)
RETURNS tinyint
AS
BEGIN
	IF (@SubjectCompanyID = @ResponderCompanyID) BEGIN
		RETURN 0
	END 

	IF (dbo.ufn_BRGetHQID(@SubjectCompanyID) = dbo.ufn_BRGetHQID(@ResponderCompanyID)) BEGIN
		RETURN 0
	END 

	IF EXISTS (SELECT 'x'
		  FROM Company WITH (NOLOCK)
		 WHERE (comp_PRType = 'B'
			    OR comp_PRListingStatus IN ('N3', 'D', 'N5', 'N6'))
		   AND comp_CompanyID = @ResponderCompanyID) BEGIN
		RETURN 0
	END

	-- Remove those responders that have told use they 
	-- don't do business with the subject.
	IF @WithTESExclusion=1 AND EXISTS (SELECT 'x'
  			     FROM PRTESRequestExclusion 
				WHERE prtesre_SubjectCompanyID = @SubjectCompanyID
				  AND prtesre_CompanyID = @ResponderCompanyID) BEGIN
		RETURN 0
	END

	IF EXISTS (SELECT 'x' 
	  FROM PRCompanyRelationship WITH (NOLOCK)
	 WHERE ((prcr_LeftCompanyID = @SubjectCompanyID AND prcr_RightCompanyID = @ResponderCompanyID)
			OR (prcr_LeftCompanyID = @ResponderCompanyID AND prcr_RightCompanyID = @SubjectCompanyID))
	   AND prcr_Type IN ('27', '28', '29')
	   AND prcr_Active = 'Y') BEGIN
		RETURN 0
	END

	RETURN 1
END
Go

CREATE OR ALTER FUNCTION dbo.ufn_IsEligibleForManualTES(@ResponderCompanyID int, 
                                               @SubjectCompanyID int)
RETURNS tinyint
AS
BEGIN
	RETURN dbo.ufn_IsEligibleForManualTES2(@ResponderCompanyID, @SubjectCompanyID, 1);
END
GO


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ufn_GetProductsProvidedForList]'))
	DROP FUNCTION dbo.ufn_GetProductsProvidedForList
GO

CREATE FUNCTION dbo.ufn_GetProductsProvidedForList(@CompanyID int)
RETURNS varchar(5000)
AS
BEGIN
	
    -- Build a comma-delimited list
    DECLARE @List varchar(5000)

    SELECT @List = COALESCE(@List + ', ', '') +  prprpr_Name
      FROM PRCompanyProductProvided WITH (NOLOCK)
           INNER JOIN PRProductProvided WITH (NOLOCK) ON prcprpr_ProductProvidedID = prprpr_ProductProvidedID
     WHERE prcprpr_CompanyID = @CompanyID
  ORDER BY prprpr_DisplayOrder;
  
   RETURN @List
END
Go


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ufn_GetServicesProvidedForList]'))
	DROP FUNCTION dbo.ufn_GetServicesProvidedForList
GO
CREATE FUNCTION dbo.ufn_GetServicesProvidedForList(@CompanyID int)
RETURNS varchar(5000)
AS
BEGIN
	
    -- Build a comma-delimited list
    DECLARE @List varchar(5000)

    SELECT @List = COALESCE(@List + ', ', '') +  prserpr_Name
      FROM PRCompanyServiceProvided WITH (NOLOCK)
           INNER JOIN PRServiceProvided WITH (NOLOCK) ON prcserpr_ServiceProvidedID = prserpr_ServiceProvidedID
     WHERE prcserpr_CompanyID = @CompanyID
  ORDER BY prserpr_DisplayOrder;
  
   RETURN @List
END
Go


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ufn_GetSpeciesForList]'))
	DROP FUNCTION dbo.ufn_GetSpeciesForList
GO
CREATE FUNCTION dbo.ufn_GetSpeciesForList(@CompanyID int)
RETURNS varchar(5000)
AS
BEGIN
	
    -- Build a comma-delimited list
    DECLARE @List varchar(5000)

    SELECT @List = COALESCE(@List + ', ', '') +  prspc_Name
      FROM PRCompanySpecie WITH (NOLOCK)
           INNER JOIN PRSpecie WITH (NOLOCK) ON prcspc_SpecieID = prspc_SpecieID
     WHERE prcspc_CompanyID = @CompanyID
  ORDER BY prspc_DisplayOrder;
  
   RETURN @List
END
Go

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ufn_GetRootSpecies]'))
	DROP FUNCTION dbo.ufn_GetRootSpecies
GO
CREATE FUNCTION dbo.ufn_GetRootSpecies(@SpeciesID int)
RETURNS int
AS
BEGIN
	DECLARE @CurrentSpeciesId int, @UltimateSpeciesId int
	SET @CurrentSpeciesId = @SpeciesId

	;WITH ParentSpecies (SpeciesId, ParentSpeciesId)
	AS
	(
		SELECT s.prspc_SpecieID, s.prspc_ParentID
		FROM PRSpecie s
		WHERE s.prspc_SpecieID = @CurrentSpeciesId
		UNION ALL
		-- Perform the recursive join
		SELECT s.prspc_SpecieID, s.prspc_ParentID
		FROM PRSpecie s
			INNER JOIN  ParentSpecies ps ON ps.ParentSpeciesId = s.prspc_SpecieID
	)

	SELECT @UltimateSpeciesId = SpeciesId
		FROM ParentSpecies
		WHERE ParentSpeciesId IS NULL
  
   RETURN @UltimateSpeciesId
END
Go


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ufn_FormatAddress2]'))
	DROP FUNCTION dbo.ufn_FormatAddress2
GO
CREATE FUNCTION [dbo].[ufn_FormatAddress2](@LineBreakChar varchar(50),
									  @Address1 varchar(50),
									  @Address2 varchar(50),
									  @Address3 varchar(50),
									  @Address4 varchar(50),
									  @Address5 varchar(50),
									  @City varchar(50),
									  @State varchar(50),
									  @Country varchar(50),
									  @Postal varchar(50)
)  
RETURNS varchar(5000) AS
BEGIN

	IF (@LineBreakChar is null)
		SET @LineBreakChar = '<br/>'

	DECLARE @RetVal varchar(1000)
    SET @RetVal = ''

	IF (@Address1 IS NOT NULL) BEGIN
		SET @RetVal	= @RetVal + RTRIM(@Address1)
	END

	IF (@Address2 IS NOT NULL) BEGIN
		SET @RetVal	= @RetVal + @LineBreakChar + RTRIM(@Address2)
	END

	IF (@Address3 IS NOT NULL) BEGIN
		SET @RetVal	= @RetVal +@LineBreakChar + RTRIM(@Address3)
	END

	IF (@Address4 IS NOT NULL) BEGIN
		SET @RetVal	= @RetVal +@LineBreakChar + RTRIM(@Address4)
	END

	IF (@Address5 IS NOT NULL) BEGIN
		SET @RetVal	= @RetVal +@LineBreakChar + RTRIM(@Address5)
	END

	IF (@City IS NOT NULL) BEGIN
		SET @RetVal	= @RetVal + @LineBreakChar + @City + ', '
	END

	IF (@State IS NOT NULL) BEGIN
		SET @RetVal	= @RetVal + @State + ' '
	END

	IF (@Postal IS NOT NULL) BEGIN
		SET @RetVal	= @RetVal + @Postal
	END

	IF (@Country IS NOT NULL) BEGIN
		IF (@Country <> 'USA') BEGIN
			SET @RetVal	= @RetVal + @LineBreakChar + @Country
        END
	END


	RETURN @RetVal
END
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetCreditSheetPublishInfo]') 
            and OBJECTPROPERTY(id, N'IsTableFunction') = 1)
drop Function [dbo].[ufn_GetCreditSheetPublishInfo]
GO

CREATE FUNCTION dbo.ufn_GetCreditSheetPublishInfo
(
    @PublicationCode varchar(40),
    @IndustryTypeCode varchar(40),
    @ReportDate datetime
)
RETURNS @tblPublicationInfo TABLE (
    Volume varchar(40),
    Number varchar(40),
    FromDate datetime
)
as
BEGIN

	-- The report uses single ticks due to how the dynamic SQL is
    -- constructed. Let's remove it for our puposes here.
	SET @IndustryTypeCode = REPLACE(@IndustryTypeCode, '''', '')


	DECLARE @PublicationDate datetime
	IF (@PublicationDate IS NULL) BEGIN
		SET @PublicationDate = GETDATE()
	END

	DECLARE @PubStartDate DateTime 
	DECLARE @NumRolloverDate DateTime
    DECLARE @NumSuffix varchar(1)
    DECLARE @Year int


    -- We may be having an issues with milliseconds being dropped off of
    -- dates, so to make sure the correct "From Date" is selected,
    -- We are going to subtract some time.  These reports are generated
    -- at most twice a week, so a few minutes should not matter.
	SET @ReportDate = DATEADD(minute, -10, ISNULL(@ReportDate, GETDATE()))


	DECLARE @FromDate datetime

	IF (@PublicationCode = 'CSUPD') BEGIN

		IF (@IndustryTypeCode = 'L') BEGIN
			SET @PubStartDate = '2009-06-08'
			SET @NumSuffix = ''

			SELECT @FromDate = MAX(prcs_WeeklyCSPubDate)
			  FROM PRCreditSheet WITH (NOLOCK)
                   INNER JOIN Company WITH (NOLOCK) ON prcs_CompanyID = comp_CompanyID
			 WHERE prcs_WeeklyCSPubDate < ISNULL(@ReportDate, GETDATE())
               AND comp_PRIndustryType = 'L';	

		END ELSE BEGIN
			SET @PubStartDate = '1903-02-11'
			SET @NumSuffix = ''

			SELECT @FromDate = MAX(prcs_WeeklyCSPubDate)
			  FROM PRCreditSheet WITH (NOLOCK)
                   INNER JOIN Company WITH (NOLOCK) ON prcs_CompanyID = comp_CompanyID
			 WHERE prcs_WeeklyCSPubDate < ISNULL(@ReportDate, GETDATE())
               AND comp_PRIndustryType <> 'L';	
		END
	END 

	IF (@PublicationCode = 'EXUPD') BEGIN
		SET @PubStartDate = '1986-02-05'

		SET @NumSuffix = CASE (DATEPART(WEEKDAY, GETDATE()))
							WHEN 2 THEN 'A'
							WHEN 3 THEN 'B'
							WHEN 4 THEN 'C'
							WHEN 5 THEN 'D'
							WHEN 6 THEN 'E'
							WHEN 7 THEN 'F'
							WHEN 1 THEN 'G'
						 END

		SELECT @FromDate = MAX(prcs_ExpressUpdatePubDate)
		  FROM PRCreditSheet WITH (NOLOCK)
               INNER JOIN Company WITH (NOLOCK) ON prcs_CompanyID = comp_CompanyID
		 WHERE prcs_ExpressUpdatePubDate < ISNULL(@ReportDate, GETDATE())
           AND comp_PRIndustryType <> 'L';	

	END 

	SET @Year = DATEDIFF(YEAR, @PubStartDate, @PublicationDate)
	SET @NumRolloverDate = CAST(YEAR(@PublicationDate) As varchar(4)) + '-' + CAST(MONTH(@PubStartDate) As varchar(2)) + '-' + CAST(DAY(@PubStartDate) As varchar(2))
	IF (@NumRolloverDate > @PublicationDate) BEGIN
		SET @NumRolloverDate = DATEADD(YEAR, -1, @NumRolloverDate)
	END ELSE BEGIN
		SET @Year = @Year + 1
	END

	INSERT INTO @tblPublicationInfo VALUES(@Year, CAST(DATEDIFF(WEEK, @NumRolloverDate, @PublicationDate) as varchar(4)) + @NumSuffix, @FromDate)

	RETURN
END
GO


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ufn_GetCompanyNameForOrderBy]'))
	DROP FUNCTION dbo.ufn_GetCompanyNameForOrderBy
GO
CREATE FUNCTION [dbo].[ufn_GetCompanyNameForOrderBy](@CompanyName varchar(104))  
RETURNS varchar(104) AS
BEGIN
	RETURN REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@CompanyName, '.', ''), ',', ''), '''', ''), ':', ''), ';', '')
END
Go

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ufn_GetIndustryTypeForOrderBy]'))
	DROP FUNCTION dbo.ufn_GetIndustryTypeForOrderBy
GO
CREATE FUNCTION [dbo].[ufn_GetIndustryTypeForOrderBy](@IndustryType varchar(40))  
RETURNS int AS
BEGIN
	
	RETURN CASE @IndustryType WHEN 'P' THEN 0 WHEN 'T' THEN 1 WHEN 'S' THEN 2 WHEN 'L' THEN 4 END

END
Go




If Exists (Select name from sysobjects where name = 'ufn_HasEquifaxAlertCode' and type in (N'FN', N'IF', N'TF')) 
    Drop Function dbo.ufn_HasEquifaxAlertCode
Go



If Exists (Select name from sysobjects where name = 'ufn_IsAddressPOBox' and type in (N'FN', N'IF', N'TF')) 
    Drop Function dbo.ufn_IsAddressPOBox
Go

CREATE FUNCTION dbo.ufn_IsAddressPOBox(@Address1 varchar(40), @Address2 varchar(40))  
RETURNS char(1) AS  
BEGIN 

	DECLARE @Return char(1)


	DECLARE @LowerAlpha1 varchar(40), @LowerAlpha2 varchar(40)
	SET @LowerAlpha1 =  dbo.getloweralpha(@Address1)
    SET @LowerAlpha2 =  dbo.getloweralpha(@Address2)
	
	IF ((@LowerAlpha1 LIKE 'po%') AND
        (@LowerAlpha1 NOT LIKE 'port%') AND
        (@LowerAlpha1 NOT LIKE 'pompano%')) BEGIN
		SET @Return = 'Y'
	END

	IF (@Return IS NULL) BEGIN
		IF ((@LowerAlpha2 LIKE 'po%') AND
			(@LowerAlpha2 NOT LIKE 'port%') AND
			(@LowerAlpha2 NOT LIKE 'pompano%')) BEGIN
			SET @Return = 'Y'
		END
	END

	RETURN @Return
END
Go


If Exists (Select name from sysobjects where name = 'ufn_GetCustomTESOption1' and type in (N'FN', N'IF', N'TF')) 
    Drop Function dbo.ufn_GetCustomTESOption1
Go

CREATE FUNCTION [dbo].[ufn_GetCustomTESOption1] (@SubjectCompanyID int)
RETURNS @Results TABLE (
    prtesr_ResponderCompanyID int primary key,
    prtesr_SubjectCompanyID int,
    company_name varchar(104),
    FaxNumber varchar(25)
) AS
BEGIN
    -- Our core query
    INSERT INTO @Results
    SELECT DISTINCT prtr_ResponderId, prtr_SubjectId, comp_Name, dbo.ufn_FormatPhone(fax.phon_CountryCode, fax.phon_AreaCode, fax.phon_Number, fax.phon_PRExtension)
      FROM PRTradeReport WITH (NOLOCK)
           INNER JOIN Company WITH (NOLOCK) ON prtr_ResponderId = comp_CompanyId
           LEFT OUTER JOIN vPRCompanyPhone fax WITH (NOLOCK) ON prtr_ResponderId = fax.plink_RecordID AND fax.phon_PRIsFax = 'Y' AND fax.phon_PRPreferredInternal = 'Y'
     WHERE comp_PRReceiveTES = 'Y' 
       AND comp_PRListingStatus in ('L','H','N1','N2')  
       AND prtr_PayRatingId in (2,3,4)  
       AND prtr_Duplicate IS NULL
       AND prtr_Date BETWEEN DATEADD(month, -12, GETDATE()) AND DATEADD(month, -3, GETDATE())
       AND prtr_SubjectId = @SubjectCompanyID
       AND prtr_SubjectId != prtr_ResponderId;


    -- First remove any responders that do have an active relationship to the subject company
    DELETE FROM @Results
     WHERE prtesr_ResponderCompanyID IN 
            (SELECT a.prtesr_ResponderCompanyID
               FROM @Results a
              INNER JOIN PRCompanyRelationship ON prtesr_ResponderCompanyID = prcr_RightCompanyID
                                              AND prcr_LeftCompanyId = @SubjectCompanyID
                                              AND prcr_Active is null)
    DELETE FROM @Results
     WHERE dbo.ufn_IsEligibleForManualTES(prtesr_ResponderCompanyID, @SubjectCompanyID) = 0;

    -- Remove those responders that have already
    -- had over 50 TES requests
    DELETE FROM @Results
     WHERE prtesr_ResponderCompanyID IN (SELECT a.prtesr_ResponderCompanyID
                                  FROM @Results a
                                       INNER JOIN PRTESRequest ON a.prtesr_ResponderCompanyID = PRTESRequest.prtesr_ResponderCompanyID
                                 WHERE prtesr_CreatedDate >= DATEADD(Day, -90, GETDATE())
                              GROUP BY a.prtesr_ResponderCompanyID
                                HAVING COUNT(1) >= 50);
    -- Remove those responders that have provided
    -- A/R Aging data in the past 90 days
    DELETE FROM @Results
     WHERE prtesr_ResponderCompanyID IN (SELECT praa_CompanyId
                                  FROM @Results
                                       INNER JOIN PRARAging ON prtesr_ResponderCompanyID = praa_CompanyId
                                 WHERE  praa_Date >= DATEADD(Day, -90, GETDATE()))
    -- Remove those responders that have already 
    -- sent a TES request on our subject in the past
    -- 27 days
    DELETE FROM @Results
     WHERE prtesr_ResponderCompanyID IN (SELECT a.prtesr_ResponderCompanyID
                                  FROM @Results a
                                       INNER JOIN PRTESRequest ON a.prtesr_ResponderCompanyID = PRTESRequest.prtesr_ResponderCompanyID
                                 WHERE PRTESRequest.prtesr_SubjectCompanyID = @SubjectCompanyID
                                   AND prtesr_CreatedDate >= DATEADD(Day, - 27, GETDATE()));
    -- Remove those responders that have provided trade
    -- report data on our subject in the past 45 days.
    DELETE FROM @Results
     WHERE prtesr_ResponderCompanyID IN (SELECT prtr_ResponderId
                                  FROM @Results
                                       INNER JOIN PRTradeReport ON prtesr_ResponderCompanyID = prtr_ResponderId
                                 WHERE prtr_SubjectId = @SubjectCompanyID
                                   AND prtr_Date >= DATEADD(Day, -45, GETDATE()))
    RETURN
END
Go



If Exists (Select name from sysobjects where name = 'ufn_IsEligibleForTES' and type in (N'FN', N'IF', N'TF')) 
    Drop Function dbo.ufn_IsEligibleForTES
Go

CREATE FUNCTION [dbo].[ufn_IsEligibleForTES] ( 
   @ResponderCompanyID int, 
   @SubjectCompanyID int
)
RETURNS char(1)
AS
BEGIN
	DECLARE @IsEligible char
	SET @IsEligible = 'N';

	SELECT @IsEligible = 'Y'
	  FROM Company
     WHERE comp_CompanyID = @ResponderCompanyID
       AND comp_PRReceiveTES = 'Y'
       AND comp_PRIndustryType != 'L'
	   AND comp_PRType = 'H'
       AND comp_PRListingStatus NOT IN ('N3', 'D', 'N5', 'N6');
	--
	-- If this responder has had 50 requests in the
    -- past 90 days, they are not eligible
	IF (@IsEligible = 'Y') BEGIN
		SELECT @IsEligible = 'N'     
          FROM PRTESRequest
         WHERE prtesr_CreatedDate >= DATEADD(Day, -90, GETDATE())
           AND prtesr_ResponderCompanyID = @ResponderCompanyID
        HAVING COUNT(1) >= 50;
	END
    -- Remove those responders that have provided
    -- A/R Aging data in the past 90 days
	IF (@IsEligible = 'Y') BEGIN
		SELECT @IsEligible = 'N'  
          FROM PRARAging 
         WHERE praa_CompanyId = @ResponderCompanyID
           AND praa_Date >= DATEADD(Day, -90, GETDATE());
	END
    -- Remove those responders that have already 
    -- sent a TES request on our subject in the past
    -- 27 days
    IF (@IsEligible = 'Y') BEGIN
		SELECT @IsEligible = 'N'  
	      FROM PRTESRequest
         WHERE prtesr_ResponderCompanyID = @ResponderCompanyID
           AND prtesr_SubjectCompanyID = @SubjectCompanyID
           AND prtesr_CreatedDate >= DATEADD(Day, - 27, GETDATE());
	END
    -- Remove those responders that have provided trade
    -- report data on our subject in the past 45 days.
    IF (@IsEligible = 'Y') BEGIN
		SELECT @IsEligible = 'N'  
          FROM PRTradeReport
         WHERE prtr_ResponderId = @ResponderCompanyID
           AND prtr_SubjectId = @SubjectCompanyID
           AND prtr_Date >= DATEADD(Day, -45, GETDATE());
	END
    IF (@IsEligible = 'Y') BEGIN
		SELECT @IsEligible = 'N'  
	      FROM PRTESRequest
         WHERE prtesr_SubjectCompanyID = @SubjectCompanyID
           AND prtesr_CreatedDate >= DATEADD(Day, -7, GETDATE())
         HAVING COUNT(1) > 25;
	END	
	RETURN @IsEligible
END
Go


If Exists (Select name from sysobjects where name = 'ufn_GetDaylightSavingsTimeStart' and type in (N'FN', N'IF', N'TF')) 
    Drop Function dbo.ufn_GetDaylightSavingsTimeStart
Go

CREATE function [dbo].[ufn_GetDaylightSavingsTimeStart]
                   (@Year varchar(4))
RETURNS smalldatetime
as
begin
	declare @DTSStartWeek smalldatetime, @DTSEndWeek smalldatetime
	set @DTSStartWeek = '03/01/' + convert(varchar,@Year)

	return case datepart(dw,@DTSStartWeek)
		when 1 then dateadd(hour,170,@DTSStartWeek)
		when 2 then dateadd(hour,314,@DTSStartWeek)
		when 3 then dateadd(hour,290,@DTSStartWeek)
		when 4 then dateadd(hour,266,@DTSStartWeek)
		when 5 then dateadd(hour,242,@DTSStartWeek)
		when 6 then dateadd(hour,218,@DTSStartWeek)
		when 7 then dateadd(hour,194,@DTSStartWeek)
	end
end
Go


If Exists (Select name from sysobjects where name = 'ufn_GetDaylightSavingsTimeEnd' and type in (N'FN', N'IF', N'TF')) 
    Drop Function dbo.ufn_GetDaylightSavingsTimeEnd
Go

CREATE function [dbo].[ufn_GetDaylightSavingsTimeEnd]
	(@Year varchar(4))
RETURNS smalldatetime
as
begin
	declare @DTSEndWeek smalldatetime
	set @DTSEndWeek = '11/01/' + convert(varchar,@Year)
	return case datepart(dw,dateadd(week,1,@DTSEndWeek))
		when 1 then	dateadd(hour,2,@DTSEndWeek)
		when 2 then	dateadd(hour,146,@DTSEndWeek)
		when 3 then	dateadd(hour,122,@DTSEndWeek)
		when 4 then	dateadd(hour,98,@DTSEndWeek)
		when 5 then	dateadd(hour,74,@DTSEndWeek)
		when 6 then	dateadd(hour,50,@DTSEndWeek)
		when 7 then	dateadd(hour,26,@DTSEndWeek)
	end
end
Go


If Exists (Select name from sysobjects where name = 'ufn_GetLocalTime' and type in (N'FN', N'IF', N'TF')) 
    Drop Function dbo.ufn_GetLocalTime
Go

CREATE function [dbo].[ufn_GetLocalTime]
	(@TargetTimeZoneOffset decimal(10,2),
       @TargetDST char(1))
RETURNS smalldatetime
as
begin

DECLARE @BBSiTimeZoneOffset decimal(10,2)
DECLARE @Modifier decimal(10,2)
DECLARE @TargetTimezoneTime datetime
SET @BBSiTimeZoneOffset = -6.0

SET @Modifier = 0 - (@BBSiTimeZoneOffset - @TargetTimeZoneOffset)

IF (GETDATE() BETWEEN dbo.ufn_GetDaylightSavingsTimeStart(Year(GETDATE())) AND  dbo.ufn_GetDaylightSavingsTimeEnd(Year(GETDATE()))) BEGIN

		IF ISNULL(@TargetDST, 'N') != 'Y' BEGIN
			SET @Modifier = @Modifier - 1
		END
END

SET @TargetTimezoneTime = DATEADD(minute, @Modifier*60, GETDATE());
RETURN @TargetTimezoneTime
End
Go

If Exists (Select name from sysobjects where name = 'ufn_GetClassificationAbbrForList ' and type in (N'FN', N'IF', N'TF')) 
    Drop Function dbo.ufn_GetClassificationAbbrForList 
Go

CREATE FUNCTION dbo.ufn_GetClassificationAbbrForList(@CompanyID int, @Count int)  
RETURNS varchar(500) AS  
BEGIN 

	DECLARE @Return varchar(500)

     SELECT TOP (@Count) @Return = COALESCE(@Return + ', ', '') +  prcl_Abbreviation
	  FROM PRClassification WITH (NOLOCK) 
	   INNER JOIN PRCompanyClassification WITH (NOLOCK) ON prcl_ClassificationId = prc2_ClassificationId
	 WHERE prc2_CompanyID = @CompanyID
	   AND prc2_Deleted IS NULL
	 ORDER BY prc2_Percentage DESC, prc2_CompanyClassificationID;

	RETURN @Return
END
Go


If Exists (Select name from sysobjects where name = 'ufn_GetRelationshipTypeList ' and type in (N'FN', N'IF', N'TF')) 
    Drop Function dbo.ufn_GetRelationshipTypeList 
Go

CREATE FUNCTION dbo.ufn_GetRelationshipTypeList(@LeftCompanyID int, @RightCompanyID int)  
RETURNS varchar(5000) AS  
BEGIN 
	DECLARE @Return varchar(5000)

	SELECT @Return = COALESCE(@Return + ', ', '') + RTRIM(COALESCE(convert(varchar(100), Capt_US),''))
	  FROM PRCompanyRelationship WITH (NOLOCK)
	  INNER JOIN custom_captions WITH (NOLOCK) ON prcr_Type = capt_code AND capt_family = 'BBOSLeftRelType'
	WHERE prcr_LeftCompanyID=@LeftCompanyID
	  AND prcr_RightCompanyID=@RightCompanyID
      AND prcr_Active = 'Y';

	RETURN @Return

END
Go

If Exists (Select name from sysobjects where name = 'ufn_GetRelationshipTypeList2' and type in (N'FN', N'IF', N'TF')) 
    Drop Function dbo.ufn_GetRelationshipTypeList2 
Go

CREATE FUNCTION dbo.ufn_GetRelationshipTypeList2(@LeftCompanyID int, @RightCompanyID int)  
RETURNS varchar(5000) AS  
BEGIN 
	DECLARE @Return varchar(5000)

	SELECT @Return = COALESCE(@Return + ', ', '') + RTRIM(COALESCE(convert(varchar(100), Capt_US),''))
	  FROM PRCompanyRelationship WITH (NOLOCK)
	  INNER JOIN custom_captions WITH (NOLOCK) ON prcr_Type = capt_code AND capt_family = 'prcr_TypeFilter'
	WHERE prcr_LeftCompanyID=@LeftCompanyID
	  AND prcr_RightCompanyID=@RightCompanyID
      AND prcr_Active = 'Y'

	RETURN @Return
END
Go

If Exists (Select name from sysobjects where name = 'ufn_GetRelationshipTypeList2_Types' and type in (N'FN', N'IF', N'TF')) 
    Drop Function dbo.ufn_GetRelationshipTypeList2_Types 
Go

CREATE FUNCTION dbo.ufn_GetRelationshipTypeList2_Types(@LeftCompanyID int, @RightCompanyID int)  
RETURNS varchar(5000) AS  
BEGIN 
	DECLARE @Return varchar(5000)

	SELECT @Return = COALESCE(@Return + ',', '') + RTRIM(COALESCE(convert(varchar(100), prcr_Type),''))
	  FROM PRCompanyRelationship WITH (NOLOCK)
	WHERE prcr_LeftCompanyID=@LeftCompanyID
	  AND prcr_RightCompanyID=@RightCompanyID
      AND prcr_Active = 'Y'

	RETURN @Return
END
Go



If Exists (Select name from sysobjects where name = 'ufn_GetRelationshipTypeCodeList ' and type in (N'FN', N'IF', N'TF')) 
    Drop Function dbo.ufn_GetRelationshipTypeCodeList 
Go

CREATE FUNCTION dbo.ufn_GetRelationshipTypeCodeList(@LeftCompanyID int, @RightCompanyID int)  
RETURNS varchar(5000) AS  
BEGIN 

	DECLARE @Return varchar(5000)

	SELECT @Return = COALESCE(@Return + ', ', '') + RTRIM(COALESCE(prcr_Type, ''))
	  FROM PRCompanyRelationship WITH (NOLOCK)
	        INNER JOIN custom_captions WITH (NOLOCK) ON prcr_Type = capt_code AND capt_family = 'BBOSLeftRelType'
	WHERE prcr_LeftCompanyID=@LeftCompanyID
	  AND prcr_RightCompanyID=@RightCompanyID
      AND prcr_Active = 'Y';

	RETURN @Return

END
Go


If Exists (Select name from sysobjects where name = 'ufn_GetRelationshipIDList ' and type in (N'FN', N'IF', N'TF')) 
    Drop Function dbo.ufn_GetRelationshipIDList 
Go

CREATE FUNCTION dbo.ufn_GetRelationshipIDList(@LeftCompanyID int, @RightCompanyID int)  
RETURNS varchar(5000) AS  
BEGIN 

	DECLARE @Return varchar(5000)

	SELECT @Return = COALESCE(@Return + ', ', '') + RTRIM(COALESCE(convert(varchar(100), prcr_CompanyRelationshipId),''))
	  FROM PRCompanyRelationship WITH (NOLOCK)
	       INNER JOIN custom_captions WITH (NOLOCK) ON prcr_Type = capt_code AND capt_family = 'BBOSLeftRelType'
	 WHERE prcr_LeftCompanyID=@LeftCompanyID
	   AND prcr_RightCompanyID=@RightCompanyID
       AND prcr_Active = 'Y';

	RETURN @Return

END
Go

If Exists (Select name from sysobjects where name = 'ufn_GetLastTradeReportDate' and type in (N'FN', N'IF', N'TF')) 
    Drop Function dbo.ufn_GetLastTradeReportDate
Go

CREATE FUNCTION dbo.ufn_GetLastTradeReportDate(@ResponderCompanyID int, @SubjectCompanyID int)  
RETURNS datetime AS  
BEGIN 

	DECLARE @Return datetime

	SELECT @Return = MAX(prtr_Date)
	  FROM PRTradeReport WITH (NOLOCK)
	 WHERE prtr_ResponderID=@ResponderCompanyID
	   AND prtr_SubjectID=@SubjectCompanyID;

	RETURN @Return

END
Go


If Exists (Select name from sysobjects where name = 'ufn_GetNumericAdSize' and type in (N'FN', N'IF', N'TF')) 
    Drop Function dbo.ufn_GetNumericAdSize
Go

CREATE FUNCTION dbo.ufn_GetNumericAdSize(@AdSize varchar(40))  
RETURNS decimal(5,4) AS  
BEGIN 

	DECLARE @Return decimal(5,4)

	SET @Return = CASE @AdSize
                    WHEN 'Full' THEN 1
                    WHEN 'Half' THEN .5
                    WHEN 'Third' THEN .3
                    WHEN 'Sixth' THEN .17
                    WHEN 'Ninth' THEN .11
                    WHEN 'HalfSpread' THEN 1
                    WHEN 'FullSpread' THEN 2 
                  END;

	RETURN @Return
END
Go

If Exists (Select name from sysobjects where name = 'ufn_GetTextAdSize' and type in (N'FN', N'IF', N'TF')) 
    Drop Function dbo.ufn_GetTextAdSize
Go

CREATE FUNCTION dbo.ufn_GetTextAdSize(@AdSize decimal(7,4))  
RETURNS varchar(40) AS  
BEGIN 

	DECLARE @Return varchar(40)
    DECLARE @Fraction varchar(40)
	DECLARE @IntValue int
	DECLARE @ModValue decimal(5,4)

	SET @IntValue = @AdSize / 1;
    SET @ModValue = @AdSize % 1;

	IF (@ModValue > .5) 
		SET @IntValue = @IntValue + 1
	ELSE IF (@ModValue > .3)
        SET @Fraction = '1/2'
	ELSE IF (@ModValue > .17)
        SET @Fraction = '1/3'
	ELSE IF (@ModValue > .11)
        SET @Fraction = '1/6'
	ELSE IF (@ModValue > .0)
        SET @Fraction = '1/9'

	SET @Return = ''
    IF (@IntValue > 0) BEGIN
	   SET @Return = CAST(@IntValue as varchar(10))
	END

	IF @Fraction IS NOT NULL BEGIN
       IF (LEN(@Return) > 0) BEGIN
            SET @Return = @Return + ' '
       END

       SET @Return = @Return + @Fraction
	END

	RETURN @Return
END
Go

If Exists (Select name from sysobjects where name = 'ufn_PrepareCompanyName' and type in (N'FN', N'IF', N'TF')) 
    Drop Function dbo.ufn_PrepareCompanyName
Go

CREATE FUNCTION dbo.ufn_PrepareCompanyName(@Name varchar(104))  
RETURNS varchar(104) AS  
BEGIN 

	DECLARE @Return varchar(104)
	
	IF (@Name LIKE '% Co., Inc.') BEGIN
		SET @RETURN = SUBSTRING(@Name, 1, LEN(@Name)-10)	

	END ELSE IF (@Name LIKE '% Co Inc') BEGIN
		SET @RETURN = SUBSTRING(@Name, 1, LEN(@Name)-7)	

	END ELSE IF (@Name LIKE '% Co Inc.') BEGIN
		SET @RETURN = SUBSTRING(@Name, 1, LEN(@Name)-8)	

	END ELSE IF (@Name LIKE '% Co, Inc') BEGIN
		SET @RETURN = SUBSTRING(@Name, 1, LEN(@Name)-8)	

	END ELSE IF (@Name LIKE '% Co, Inc.') BEGIN
		SET @RETURN = SUBSTRING(@Name, 1, LEN(@Name)-9)	

	END ELSE IF (@Name LIKE '% Co. Inc') BEGIN
		SET @RETURN = SUBSTRING(@Name, 1, LEN(@Name)-8)	

	END ELSE IF (@Name LIKE '% Co. Inc.') BEGIN
		SET @RETURN = SUBSTRING(@Name, 1, LEN(@Name)-9)	

	END ELSE IF (@Name LIKE '% Co., Inc') BEGIN
		SET @RETURN = SUBSTRING(@Name, 1, LEN(@Name)-9)	

	END ELSE IF (@Name LIKE '% Company') BEGIN
		SET @RETURN = SUBSTRING(@Name, 1, LEN(@Name)-8)

	END ELSE IF (@Name LIKE '% Company.') BEGIN
		SET @RETURN = SUBSTRING(@Name, 1, LEN(@Name)-9)

	END ELSE IF (@Name LIKE '% Incorporated') BEGIN
		SET @RETURN = SUBSTRING(@Name, 1, LEN(@Name)-13)

	END ELSE IF (@Name LIKE '% Incorporated.') BEGIN
		SET @RETURN = SUBSTRING(@Name, 1, LEN(@Name)-14)

	END ELSE IF (@Name LIKE '%, Incorporated') BEGIN
		SET @RETURN = SUBSTRING(@Name, 1, LEN(@Name)-14)

	END ELSE IF (@Name LIKE '%, Incorporated.') BEGIN
		SET @RETURN = SUBSTRING(@Name, 1, LEN(@Name)-15)

	END ELSE IF (@Name LIKE '%, Inc.') BEGIN
		SET @RETURN = SUBSTRING(@Name, 1, LEN(@Name)-6)
	
	END ELSE IF (@Name LIKE '% Inc.') BEGIN
		SET @RETURN = SUBSTRING(@Name, 1, LEN(@Name)-5)

	END ELSE IF (@Name LIKE '%, Inc') BEGIN
		SET @RETURN = SUBSTRING(@Name, 1, LEN(@Name)-5)

	END ELSE IF (@Name LIKE '% Inc') BEGIN
		SET @RETURN = SUBSTRING(@Name, 1, LEN(@Name)-4)

	END ELSE IF (@Name LIKE '%, LLC') BEGIN
		SET @RETURN = SUBSTRING(@Name, 1, LEN(@Name)-5)

	END ELSE IF (@Name LIKE '% LLC') BEGIN
		SET @RETURN = SUBSTRING(@Name, 1, LEN(@Name)-4)

	END ELSE IF (@Name LIKE '%, LLC.') BEGIN
		SET @RETURN = SUBSTRING(@Name, 1, LEN(@Name)-6)

	END ELSE IF (@Name LIKE '% LLC.') BEGIN
		SET @RETURN = SUBSTRING(@Name, 1, LEN(@Name)-5)

	END ELSE IF (@Name LIKE '% L.L.C.') BEGIN
		SET @RETURN = SUBSTRING(@Name, 1, LEN(@Name)-8)

	END ELSE IF (@Name LIKE '%, L.L.C.') BEGIN
		SET @RETURN = SUBSTRING(@Name, 1, LEN(@Name)-9)

	END ELSE IF (@Name LIKE '% Corp.') BEGIN
		SET @RETURN = SUBSTRING(@Name, 1, LEN(@Name)-6)	

	END ELSE IF (@Name LIKE '% Corp') BEGIN
		SET @RETURN = SUBSTRING(@Name, 1, LEN(@Name)-5)	

	END ELSE IF (@Name LIKE '% Corporation') BEGIN
		SET @RETURN = SUBSTRING(@Name, 1, LEN(@Name)-12)	

	END ELSE IF (@Name LIKE '% Corporation.') BEGIN
		SET @RETURN = SUBSTRING(@Name, 1, LEN(@Name)-13)	

	END ELSE IF (@Name LIKE '% Co') BEGIN
		SET @RETURN = SUBSTRING(@Name, 1, LEN(@Name)-3)	

	END ELSE IF (@Name LIKE '% Co.') BEGIN
		SET @RETURN = SUBSTRING(@Name, 1, LEN(@Name)-4)	

	END ELSE IF (@Name LIKE '% Ltd.') BEGIN
		SET @RETURN = SUBSTRING(@Name, 1, LEN(@Name)-5)	

	END ELSE IF (@Name LIKE '% Ltd') BEGIN
		SET @RETURN = SUBSTRING(@Name, 1, LEN(@Name)-4)	

	END ELSE IF (@Name LIKE '% Limited') BEGIN
		SET @RETURN = SUBSTRING(@Name, 1, LEN(@Name)-8)	

	END ELSE IF (@Name LIKE '% Limited.') BEGIN
		SET @RETURN = SUBSTRING(@Name, 1, LEN(@Name)-9)	
    END

	SET @RETURN = ISNULL(@RETURN, @Name)

	--
	--  Mexico Names
	-- Productos El Caporal, S.P.R. De R.S.
	IF (@RETURN LIKE '% de C.V.') BEGIN
		SET @RETURN = SUBSTRING(@RETURN, 1, LEN(@RETURN)-8)	
	END

	IF (@RETURN LIKE '% de CV') BEGIN
		SET @RETURN = SUBSTRING(@RETURN, 1, LEN(@RETURN)-6)	
	END

	IF (@RETURN LIKE '% de R.L.') BEGIN
		SET @RETURN = SUBSTRING(@RETURN, 1, LEN(@RETURN)-8)	
	END

	IF (@RETURN LIKE '% de RL') BEGIN
		SET @RETURN = SUBSTRING(@RETURN, 1, LEN(@RETURN)-6)	
	END

	IF (@RETURN LIKE '% de R.S.') BEGIN
		SET @RETURN = SUBSTRING(@RETURN, 1, LEN(@RETURN)-8)	
	END

	IF (@RETURN LIKE '% de RS') BEGIN
		SET @RETURN = SUBSTRING(@RETURN, 1, LEN(@RETURN)-6)	
	END
	
	IF (@RETURN LIKE '% S.A.') BEGIN
		SET @RETURN = SUBSTRING(@RETURN, 1, LEN(@RETURN)-5)	
	END
	
	IF (@RETURN LIKE '% SA') BEGIN
		SET @RETURN = SUBSTRING(@RETURN, 1, LEN(@RETURN)-3)	
	END

	IF (@RETURN LIKE '% S.P.R.') BEGIN
		SET @RETURN = SUBSTRING(@RETURN, 1, LEN(@RETURN)-7)	
	END

	IF (@RETURN LIKE '% SPR') BEGIN
		SET @RETURN = SUBSTRING(@RETURN, 1, LEN(@RETURN)-4)	
	END

	IF (@RETURN LIKE '% S.A.P.I.') BEGIN
		SET @RETURN = SUBSTRING(@RETURN, 1, LEN(@RETURN)-9)	
	END

	IF (@RETURN LIKE '% SAPI') BEGIN
		SET @RETURN = SUBSTRING(@RETURN, 1, LEN(@RETURN)-4)	
	END

	IF (@RETURN LIKE '% S.P.R.L.') BEGIN
		SET @RETURN = SUBSTRING(@RETURN, 1, LEN(@RETURN)-9)	
	END

	IF (@RETURN LIKE '% SPRL') BEGIN
		SET @RETURN = SUBSTRING(@RETURN, 1, LEN(@RETURN)-5)	
	END

	IF (@RETURN LIKE 'The %') BEGIN
		SET @RETURN = SUBSTRING(@RETURN, 5, LEN(@RETURN)-4)	
	END

	SET @RETURN = REPLACE(@RETURN, ' AND ', '')	

	RETURN ISNULL(@Return, @Name)
END
Go




If Exists (Select name from sysobjects where name = 'ufn_URLEncode' and type in (N'FN', N'IF', N'TF')) 
    Drop Function dbo.ufn_URLEncode
Go

--http://sqlblog.com/blogs/peter_debetta/archive/2007/03/09/t-sql-urlencode.aspx
CREATE FUNCTION dbo.ufn_URLEncode(@URL varchar(4000))  
RETURNS varchar(8000) AS  
BEGIN   

    DECLARE @Count int, @c char(1), @i int, @urlReturn varchar(8000)
    
    SET @count = Len(@url)
    SET @i = 1
    SET @urlReturn = ''    
    
    WHILE (@i <= @count) BEGIN
		SET @c = substring(@url, @i, 1)
        IF @c LIKE '[A-Za-z0-9()''*-._!]' BEGIN
            SET @urlReturn = @urlReturn + @c
        END ELSE BEGIN
            SET @urlReturn = 
                   @urlReturn +
                   '%' +
                   SUBSTRING(sys.fn_varbintohexstr(CAST(@c as varbinary(max))),3,2)
        END
        SET @i = @i +1
	END
	
    RETURN @urlReturn
END
Go    

IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[ufn_GetAddressIDForCAC]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    DROP FUNCTION [dbo].[ufn_GetAddressIDForCAC]
GO

--
-- Returns the appropriate AddressID to use for a marketing list for the specifed type.
--
CREATE Function ufn_GetAddressIDForCAC(@CompanyID int)
RETURNS INT
AS
BEGIN
    DECLARE @AddressID int 

    SELECT TOP 1 @AddressID = addr_AddressID
    FROM Address_Link
         INNER JOIN Address ON adli_AddressID = addr_AddressID
     WHERE adli_CompanyID = @CompanyID
       AND adli_Type IN ('M', 'PH')
  ORDER BY dbo.ufn_GetAddressListSeq(adli_Type), addr_AddressID;

    RETURN @AddressID;
END
Go

-- Returns comma delimited list of publication topics for an article

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ufn_GetPublicationTopics]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[ufn_GetPublicationTopics]
GO 

CREATE FUNCTION [dbo].[ufn_GetPublicationTopics](@PublicationArticleID int)
RETURNS varchar(5000)
AS
BEGIN
    -- Build a comma-delimited list
    DECLARE @List varchar(5000)
    SELECT @List = COALESCE(@List + ', ', '') +  prpbt_Name
	FROM PRPublicationArticleTopic with (nolock)
	left outer join PRPublicationTopic with (nolock) on prpbt_PublicationTopicID = prpbart_PublicationTopicID
     WHERE  prpbart_PublicationArticleID = @PublicationArticleID
  ORDER BY prpbt_Name;
   RETURN @List
END
Go


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ufn_PrepareCreditSheetText]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[ufn_PrepareCreditSheetText]
GO 

CREATE FUNCTION [dbo].[ufn_PrepareCreditSheetText](@Change varchar(max))
RETURNS varchar(max)
AS
BEGIN

	DECLARE @Return varchar(max)

	IF @Change IS NOT NULL AND
	   LEN(@Change) > 0 BEGIN
	
		SET @Return = REPLACE(@Change, '<B>', '');
		
		IF (@Return LIKE  '%' + CHAR(13) + CHAR(10)) BEGIN
			SET @Return = SUBSTRING(@Return, 1, LEN(@Return)-2)
		END
		
		IF (@Return LIKE  CHAR(13) + CHAR(10) + '%') BEGIN
			SET @Return = SUBSTRING(@Return, 3, LEN(@Return)-2)
		END
		
	END
	
	RETURN @Return
END
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetCSItemCache]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_GetCSItemCache]
GO
CREATE FUNCTION dbo.ufn_GetCSItemCache ( 
    @CreditSheetID int,
    @FormattingStyle tinyint = 0 -- 0: <br/> 1: CHR(10) 2: CHR(10 & 13)
)
RETURNS varchar(max)
AS
BEGIN

	DECLARE @ItemText varchar(max)

	SELECT @ItemText = prcs_ItemText
	  FROM PRCreditSheet
	 WHERE prcs_CreditSheetId = @CreditSheetID

	
	IF (@FormattingStyle <> 0) BEGIN
	
		DECLARE @LineBreakChar varchar(5)
		IF (@FormattingStyle = 1) BEGIN
			SET @LineBreakChar = CHAR(10)
		END ELSE IF (@FormattingStyle = 2) BEGIN
			SET @LineBreakChar = CHAR(13)+CHAR(10)
		END        
        
        SET @ItemText = REPLACE(@ItemText, '<br/>', @LineBreakChar)
        SET @ItemText = REPLACE(@ItemText, '&nbsp;', ' ')
	END
	
	
	IF (@ItemText IS NULL) BEGIN
		SET @ItemText = dbo.ufn_GetItem(@CreditSheetID, @FormattingStyle, 1, 34)
	END
	
	RETURN @ItemText;
	
END
GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetShipmentLogItemsForList]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_GetShipmentLogItemsForList]
GO
--
-- Returns a list of Shipment Item codes
--
CREATE Function dbo.ufn_GetShipmentLogItemsForList(@ShipmentLogID int)
RETURNS varchar(2000)
AS
BEGIN
    
    DECLARE @List varchar(2000)

    SELECT @List = COALESCE(@List + ', ', '') + CAST(capt_US as varchar(100))
      FROM PRShipmentLogDetail WITH (NOLOCK)
           INNER JOIN Custom_Captions WITH (NOLOCK) ON prshplgd_ItemCode = capt_code AND capt_family = 'prshplgd_ItemCode'
     WHERE prshplgd_ShipmentLogID = @ShipmentLogID;

    RETURN @List
END
Go

CREATE OR ALTER FUNCTION dbo.ufn_OrderAttentionLineCounts
(
    @CompanyID int
)
RETURNS @ItemTable table (
	Item varchar(40),
	OrderedCount int,
	AttnLineCount int
)
as
BEGIN

	INSERT INTO @ItemTable VALUES ('BOOK-APR', 0, 0);
	INSERT INTO @ItemTable VALUES ('BOOK-OCT', 0, 0);
	INSERT INTO @ItemTable VALUES ('BOOK-UNV', 0, 0);
	INSERT INTO @ItemTable VALUES ('BPRINT', 0, 0);
	INSERT INTO @ItemTable VALUES ('KYCG', 0, 0);
	INSERT INTO @ItemTable VALUES ('BOOK-F', 0, 0);

	UPDATE @ItemTable 
	   SET OrderedCount = ServiceCount
	  FROM (   
			SELECT prse_ServiceCode, SUM(QuantityOrdered) As ServiceCount
			  FROM PRService
			 WHERE prse_CompanyID = @CompanyID
			  AND prse_ServiceCode IN (SELECT Item FROM @ItemTable)
			GROUP BY prse_ServiceCode 
			) T1
	 WHERE 	Item = 	prse_ServiceCode;

	UPDATE @ItemTable 
	   SET AttnLineCount = AttentionLineCount
	  FROM (  
			SELECT prattn_ItemCode, COUNT(1) As AttentionLineCount 
			  FROM PRAttentionLine WITH (NOLOCK)
			 WHERE prattn_CompanyID = @CompanyID
			   AND prattn_ItemCode IN (SELECT Item FROM @ItemTable)
			GROUP BY prattn_ItemCode
			) T1
	 WHERE 	Item = 	prattn_ItemCode;

	RETURN
  
END  
Go

CREATE OR ALTER FUNCTION dbo.ufn_GetCompanyMessages
(
    @CompanyID int,
    @IndustryType varchar(40) = NULL
)
RETURNS @ItemTable table (
	Message varchar(200),
	MessageType varchar(40),
	AdditionalData varchar(1000)
)
as
BEGIN
	DECLARE @Count int = 0, @Count2 int = 0
	DECLARE @Date datetime = null
	DECLARE @List varchar(5000) = null
	DECLARE @Type varchar(40), @ListingStatus varchar(40)
	DECLARE @LocalSource char(1), @IntlTradeAssociation char(1), @HasITAAccess char(1)
	
	SELECT @IndustryType = comp_PRIndustryType,
	       @Type = comp_PRType,
		   @ListingStatus = comp_PRListingStatus,
		   @LocalSource = comp_PRLocalSource,
		   @IntlTradeAssociation = comp_PRIsIntlTradeAssociation,
           @HasITAAccess = comp_PRHasITAAccess
	  FROM Company WITH (NOLOCK) 
	 WHERE Comp_CompanyId = @CompanyID;
	
	--
	--  BEGIN Accounting Messages.  Only one of the following should get displayed.
	--
	IF EXISTS (SELECT 'X' FROM PRCompanyIndicators WITH (NOLOCK) WHERE prci2_CompanyID = @CompanyID AND prci2_Suspended = 'Y') BEGIN
		SET @Count = 1;
		
		INSERT INTO @ItemTable (Message, MessageType) VALUES ('This company''s Membership Service has been suspended due to non-payment.', 'Accounting');
	END

	IF (@Count = 0) BEGIN
	
		SELECT @Count = COUNT(1)
	      FROM MAS_PRC.dbo.AR_OpenInvoice WITH (NOLOCK) 
         WHERE Balance > 0
           AND InvoiceDueDate < GETDATE()
           AND CAST(CustomerNo AS INT) = @CompanyID
           
		IF (@Count > 0) BEGIN           
			INSERT INTO @ItemTable (Message, MessageType) VALUES ('This company is past due.', 'Accounting');
		END
	END

	IF (@Count = 0) BEGIN
	
		SELECT @Count = COUNT(1)
	      FROM MAS_PRC.dbo.AR_OpenInvoice WITH (NOLOCK) 
         WHERE Balance > 0
           AND CAST(CustomerNo AS INT) = @CompanyID

		IF (@Count > 0) BEGIN           
			INSERT INTO @ItemTable (Message, MessageType) VALUES ('This company has an amount owing.', 'Accounting');
		END
	END
	
	SELECT @Count = COUNT(1)
	  FROM MAS_PRC.dbo.SO_SalesOrderHeader WITH (NOLOCK)
     WHERE OrderType = 'S'
       AND CAST(CustomerNo AS INT) = @CompanyID;
       
	IF (@Count > 0) BEGIN
		INSERT INTO @ItemTable (Message, MessageType) VALUES ('This company has a pending order.', 'Accounting');
	END	
	--
	--  END Accounting Messages.
	--

	SELECT @Count = ISNULL(SUM(QuantityOrdered), 0) 
	  FROM PRService WITH (NOLOCK)
	 WHERE Category2 = 'License'
	   AND prse_HQID=@CompanyID;

	SELECT @Count2 = COUNT(1)
	  FROM PRWebUser WITH (NOLOCK)
	 WHERE prwu_ServiceCode IS NOT NULL
	   AND prwu_ServiceCode NOT IN('None', 'None2', 'ITALIC')
	   AND prwu_Disabled IS NULL
	   AND prwu_HQID = @CompanyID;

	IF (@Count2 > @Count) BEGIN
		INSERT INTO @ItemTable (Message, MessageType) VALUES ('This company has more BBOS users assigned than licenses.', 'BBOSLicenses');	
	END

	IF (@LocalSource = 'Y') BEGIN
		INSERT INTO @ItemTable (Message, MessageType) VALUES ('This is a Local Source company.', 'Delivery');	
	END 

	IF (@IntlTradeAssociation = 'Y') BEGIN
		INSERT INTO @ItemTable (Message, MessageType) VALUES ('This is an Intl Trade Association company.', 'Delivery');	
	END 

	IF (@HasITAAccess = 'Y') BEGIN
		INSERT INTO @ItemTable (Message, MessageType) VALUES ('This company has BBOS Limitado access.', 'Delivery');	
	END 

	IF EXISTS (SELECT 'X' FROM dbo.ufn_OrderAttentionLineCounts(@CompanyID) WHERE OrderedCount != AttnLineCount) BEGIN
		INSERT INTO @ItemTable (Message, MessageType) VALUES ('This company''s service count does not match the delivery attention lines.', 'Delivery');	
	END 

	IF (@IndustryType <> 'L') BEGIN
		SELECT @Count = dbo.ufn_CountOccurrences(CHAR(10), dbo.ufn_GetListingCache(@CompanyID, 1));
		IF (@Count > 174) BEGIN
			INSERT INTO @ItemTable (Message, MessageType) VALUES ('This company has a listing length exceeding 174 lines.', 'Listing');		
		END
	END
	
	IF (@IndustryType = 'L') BEGIN
		SELECT @Count =  dbo.ufn_GetPayReportCount(@CompanyID);
		
		IF (@Count > 0) BEGIN
			INSERT INTO @ItemTable (Message, MessageType) VALUES ('This company has ' + CAST(@Count as varchar(5)) + ' current Industry Pay Reports.', 'Rating');		
		END		
	END

	IF (@Type = 'H')  BEGIN

		IF EXISTS (SELECT 'X' FROM PRCompanyInfoProfile WITH (NOLOCK) WHERE prc5_CompanyID = @CompanyID AND prc5_ARSubmitter = 'Y') BEGIN
			INSERT INTO @ItemTable (Message, MessageType) VALUES ('This company is an AR submitter.', 'Rating');
		END

		IF EXISTS (SELECT 'X' FROM PRCompanyInfoProfile WITH (NOLOCK) WHERE prc5_CompanyID = @CompanyID AND prc5_CLSubmitter = 'Y') BEGIN
			INSERT INTO @ItemTable (Message, MessageType) VALUES ('This company is a CL submitter.', 'Rating');
		END
	END

    IF EXISTS (SELECT 'X' FROM PRCompanyInfoProfile WITH (NOLOCK) WHERE prc5_CompanyID = @CompanyID AND prc5_PRARYearRoundBPAdvertiser = 'Y') BEGIN
	    INSERT INTO @ItemTable (Message, MessageType) VALUES ('lightblue:This company is a year-round Blueprints advertiser.', 'Rating');
	END

	SELECT @Count = COUNT(1) 
      FROM PRSSFile WITH (NOLOCK)
     WHERE prss_RespondentCompanyId = @CompanyID
       AND prss_Status IN ('O', 'C')
       AND prss_Publish = 'Y'
       AND prss_Meritorious = 'Y'
       AND prss_MeritoriousDate >= DATEADD(day, -60, GETDATE());

	IF (@Count > 0) BEGIN
		INSERT INTO @ItemTable (Message, MessageType) VALUES ('This company has ' + CAST(@Count as varchar) + ' meritorious Special Services claim(s).', 'Rating');		
	END

	SELECT @Count = COUNT(1) 
      FROM PRSSFile WITH (NOLOCK)
     WHERE prss_RespondentCompanyId = @CompanyID
       AND prss_Status IN ('O', 'C')
       AND prss_Publish = 'Y'
       AND prss_OpenedDate >= DATEADD(day, -21, GETDATE());

	IF (@Count > 0) BEGIN
		INSERT INTO @ItemTable (Message, MessageType) VALUES ('This company has ' + CAST(@Count as varchar) + ' new Special Services claim(s).', 'Rating');		
	END

	SELECT @Count = COUNT(1) 
      FROM PRCourtCases WITH (NOLOCK)
     WHERE prcc_CreatedDate >= DATEADD(day, -21, GETDATE())
       AND prcc_CompanyID = @CompanyID;
	
	IF (@Count > 0) BEGIN
		INSERT INTO @ItemTable (Message, MessageType) VALUES ('This company has ' + CAST(@Count as varchar) + ' new Federal Civil Case(s).', 'Rating');		
	END

	IF (@Type = 'H') BEGIN		
		SELECT @Count = COUNT(1) 
		  FROM PRAttentionLine WITH (NOLOCK) 
		 WHERE prattn_CompanyID = @CompanyID 
		   AND prattn_ItemCode <> 'ARD'
		   AND ISNULL(prattn_AddressID, 0) = 0 
		   AND ISNULL(prattn_PhoneID, 0) = 0 
		   AND ISNULL(prattn_EmailID, 0) = 0
		   AND prattn_Disabled IS NULL

		IF (@Count > 0 AND @ListingStatus NOT IN ('N5','N6')) BEGIN
			INSERT INTO @ItemTable (Message, MessageType) VALUES ('This company has attention line(s) with missing delivery methods.  Attention lines MUST be assigned!', 'Delivery');		
		END		
	END

	SELECT @Date = MAX(prwu_LastLoginDateTime) 
	  FROM PRWebUser WITH (NOLOCK) 
	 WHERE prwu_BBID = @CompanyID OR prwu_HQID = @CompanyID;
	 
	IF ((@Date IS NOT NULL) AND
	    (DATEDIFF(day, @Date, GETDATE()) > 120)) BEGIN
		INSERT INTO @ItemTable (Message, MessageType) VALUES ('This company has not had any BBOS activity in the past 120 days.', 'BBOS');			    
	END

	SELECT @List = COALESCE(@List + ', ', '') + CAST(CompanyID as varchar(10)) 
	  FROM dbo.ufn_GetOtherRelatedCompanies(@CompanyID, '36');

	IF (@List IS NOT NULL) BEGIN
		INSERT INTO @ItemTable 
		   VALUES ('Company performs cross industry functions with: ', 'CompanyRelationships', @List);			    
	END

	IF (dbo.ufn_IsActiveMember(@CompanyID) = 0) BEGIN
		--Non-members
		SELECT @Count = COUNT(1) 
		  FROM Company WITH (NOLOCK)
			   LEFT OUTER JOIN PRService WITH (NOLOCK) ON prse_CompanyID = comp_CompanyID AND prse_ServiceCode = 'DL' AND prse_Primary IS NULL
		 WHERE comp_CompanyID=@CompanyID
		   --AND comp_PRPublishDL = 'Y'
		   AND dbo.ufn_GetListingDLLineCount(comp_CompanyID) > 0
		   AND prse_ServiceCode IS NULL;

		IF (@Count > 0) BEGIN
			INSERT INTO @ItemTable (Message, MessageType) VALUES ('This company is configured to publish DL, but does not have a DL service code.', 'Delivery');		
		END	
	END

	RETURN
END
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetBusinessEventTypeValue]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    drop function [dbo].[ufn_GetBusinessEventTypeValue]
GO

CREATE FUNCTION [dbo].[ufn_GetBusinessEventTypeValue] ( 
    @TypeFamily varchar(40),
    @TypeCode varchar(40), 
    @CodeOther varchar(40),
    @OtherDecription varchar(1000)
)
RETURNS varchar(1000)
AS
BEGIN

	DECLARE @EventValue varchar(1000)
	
	IF (@TypeCode = @CodeOther) BEGIN
		SET @EventValue = @OtherDecription
	END ELSE BEGIN
		SET @EventValue = dbo.ufn_GetCustomCaptionValue(@TypeFamily, @TypeCode, null);
	END
	
	RETURN @EventValue
END
Go


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetBusinessEventCompanyInfo]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    drop function [dbo].[ufn_GetBusinessEventCompanyInfo]
GO

CREATE FUNCTION [dbo].[ufn_GetBusinessEventCompanyInfo] ( 
    @TypeCode varchar(40), 
    @CompanyID int
)
RETURNS varchar(1000)
AS
BEGIN

	DECLARE @CompanyInfo varchar(1000)
	DECLARE @Name varchar(200), @Location varchar(200)
		
	SELECT @Name = Comp_PRCorrTradestyle, 
	       @Location = CityStateCountryShort
	  FROM Company WITH (NOLOCK)
	       INNER JOIN vPRLocation ON  prci_CityId = comp_PRListingCityId
	 WHERE Comp_CompanyId = @CompanyID
	
	
	IF ((@TypeCode = '32') OR            -- BUSINESS_EVENT_RECEIVERSHIP_APPLIED_FOR
	    (@TypeCode = '33'))  BEGIN        -- BUSINESS_EVENT_RECEIVERSHIP_APPOINTED
		SET @CompanyInfo = @Name
	END ELSE BEGIN
		SET @CompanyInfo = @Name + ', ' + @Location
	END
	
	RETURN @CompanyInfo
END
Go



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetBusinessEventUnderLawText]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    drop function [dbo].[ufn_GetBusinessEventUnderLawText]
GO

CREATE FUNCTION [dbo].[ufn_GetBusinessEventUnderLawText] ( 
    @DetailedType varchar(40), 
    @StateID int
)
RETURNS varchar(1000)
AS
BEGIN
	DECLARE @UnderLawText varchar(1000) = ''

	IF ((@DetailedType IS NOT NULL) AND
		(@StateID IS NOT NULL)) BEGIN
		
		--IF ((@DetailedType = '1') OR
		--	(@DetailedType = '2') OR
		--	(@DetailedType = '3') OR
		--	(@DetailedType = '4')) BEGIN
		    
			SELECT @UnderLawText = 'under ' + prst_State + ' law'
			  FROM PRState WITH (NOLOCK)
			 WHERE prst_StateId = @StateID;
		--END
	END	
 
	RETURN @UnderLawText
END
Go
 

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetBusinessEventText]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    drop function [dbo].[ufn_GetBusinessEventText]
GO

CREATE FUNCTION [dbo].[ufn_GetBusinessEventText] ( 
    @BusinessEventID int,
    @ReportType int = 1
)
RETURNS varchar(max)
AS
BEGIN

	DECLARE @work varchar(100) = null

	DECLARE @EventText varchar(max) = ''
	DECLARE @EventType varchar(40), @EffectiveDate datetime 
	DECLARE @DetailedType varchar(40), @OtherDecription varchar(1000), @RelatedCompany1ID int, @RelatedCompany2ID int, @PublishedAnalysis varchar(max)
	DECLARE @AgreementCategory varchar(40)
	DECLARE @AssigneeTrusteeName varchar(30), @AssigneeTrusteeAddress varchar(200), @AssigneeTrusteePhone varchar(30)
	DECLARE @StateId int
	DECLARE @IndividualSellerId int, @IndividualBuyerId int, @PercentSold decimal(24,2)
	DECLARE @Amount decimal(24,2)
	DECLARE @USBankruptcyVoluntary varchar(1), @USBankruptcyCourt varchar(40), @CourtDistrict varchar(50)
	DECLARE @CaseNumber varchar(15), @AttorneyName varchar(30), @AttorneyPhone varchar(20)
	DECLARE @AssetAmount numeric(24,2), @LiabilityAmount numeric(24,2)
	DECLARE @DisasterImpact varchar(40), @Names varchar(100)
	DECLARE @NumberSellers int, @NonPromptStart varchar(20), @NonPromptEnd varchar(20), @BusinessOperateUntil datetime, @IndividualOperateUntil datetime

	SELECT @EventType = prbe_BusinessEventTypeId,
	       @DetailedType = prbe_DetailedType,
	       @EffectiveDate = CONVERT(VARCHAR(10),prbe_EffectiveDate, 101),
	       @OtherDecription = prbe_OtherDescription,
	       @RelatedCompany1ID = prbe_RelatedCompany1Id,
	       @RelatedCompany2ID = prbe_RelatedCompany2Id,
	       @PublishedAnalysis = prbe_PublishedAnalysis,
	       @AgreementCategory = prbe_AgreementCategory,
	       @AssigneeTrusteeName = prbe_AssigneeTrusteeName,
	       @AssigneeTrusteeAddress = prbe_AssigneeTrusteeAddress,
	       @AssigneeTrusteePhone = prbe_AssigneeTrusteePhone,
	       @USBankruptcyVoluntary = prbe_USBankruptcyVoluntary,
	       @USBankruptcyCourt = prbe_USBankruptcyCourt,
	       @CourtDistrict = prbe_CourtDistrict,
	       @CaseNumber = prbe_CaseNumber,
	       @AttorneyName = prbe_AttorneyName,
	       @AttorneyPhone = prbe_AttorneyPhone,
	       @AssetAmount = prbe_AssetAmount,
	       @LiabilityAmount = prbe_LiabilityAmount,
	       @StateId = prbe_StateId,
	       @IndividualSellerId = prbe_IndividualSellerId,
	       @IndividualBuyerId = prbe_IndividualBuyerId,
	       @PercentSold = prbe_PercentSold,
	       @Amount = prbe_Amount,
	       @DisasterImpact = prbe_DisasterImpact,
	       @Names = prbe_Names, 
	       @NumberSellers = prbe_NumberSellers, 
	       @NonPromptStart = prbe_NonPromptStart, 
	       @NonPromptEnd = prbe_NonPromptEnd,
	       @BusinessOperateUntil = prbe_BusinessOperateUntil, 
	       @IndividualOperateUntil = prbe_IndividualOperateUntil
	  FROM PRBusinessEvent WITH (NOLOCK)
	 WHERE prbe_BusinessEventID = @BusinessEventID;


	IF @EventType = '1' BEGIN  -- BUSINESS_EVENT_ACQUISTION
		IF ((@DetailedType IS NOT NULL) AND
		    (@RelatedCompany1ID IS NOT NULL)) BEGIN
	
			SET @EventText = 'Subject company acquired {0} of {1}.'
			SET @EventText = REPLACE(@EventText, '{0}', dbo.ufn_GetBusinessEventTypeValue('prbe_AcquisitionType', @DetailedType, '6', @OtherDecription));
			SET @EventText = REPLACE(@EventText, '{1}', dbo.ufn_GetBusinessEventCompanyInfo(@EventType, @RelatedCompany1ID));
		END
	END
	
	IF @EventType = '2' BEGIN  -- BUSINESS_EVENT_AGREEMENT_IN_PRINCIPLE
		IF ((@DetailedType IS NOT NULL) AND
		    (@RelatedCompany1ID IS NOT NULL) AND
		    (@AgreementCategory IS NOT NULL)) BEGIN
	
			SET @EventText = 'An agreement in priciple was reach with {0} to {1} {2}.'
			SET @EventText = REPLACE(@EventText, '{0}', dbo.ufn_GetBusinessEventCompanyInfo(@EventType, @RelatedCompany1ID));
			SET @EventText = REPLACE(@EventText, '{1}', dbo.ufn_GetCustomCaptionValue('prbe_AgreementCategory', @AgreementCategory, null));
			SET @EventText = REPLACE(@EventText, '{2}', dbo.ufn_GetBusinessEventTypeValue('prbe_AcquisitionType', @DetailedType, '6', @OtherDecription));
		END
	END	
	
	IF @EventType = '3' BEGIN -- BUSINESS_EVENT_ASSIGNMENT_BENEFIT_CREDITORS
	
		IF ((@AssigneeTrusteeName IS NOT NULL) AND
		    (@AssigneeTrusteeAddress IS NOT NULL) AND
		    (@AssigneeTrusteePhone IS NOT NULL)) BEGIN
	
			SET @EventText = 'Subject company reported assignment of all/certain assets made for the benefit of creditors.'
			
			IF (@ReportType = 1) BEGIN
				SET @EventText = @EventText + '  Assignee named to this case is {1}, {2}, {3}.'
				SET @EventText = REPLACE(@EventText, '{0}', @AssigneeTrusteeName);
				SET @EventText = REPLACE(@EventText, '{1}', @AssigneeTrusteeAddress);
				SET @EventText = REPLACE(@EventText, '{2}', @AssigneeTrusteePhone);
				
			END ELSE BEGIN
				SET @EventText = @EventText + '  Additional details are documented in the Business Background section of this report.'
			END
		END
	END	
		
	IF (@EventType = '4') BEGIN -- BUSINESS_EVENT_BANKRUPTCY
		SET @EventText = ''
	END		
		
	IF (@EventType = '5') BEGIN -- BUSINESS_EVENT_US_BANKRUPTCY

		IF ((@DetailedType IS NOT NULL) AND
		    (@USBankruptcyCourt IS NOT NULL) AND
		    (@CourtDistrict IS NOT NULL) AND
		    (@CaseNumber IS NOT NULL) AND
		    (@AttorneyName IS NOT NULL) AND
		    (@AttorneyPhone IS NOT NULL) AND
		    (@AssigneeTrusteeAddress IS NOT NULL) AND
		    (@AssigneeTrusteePhone IS NOT NULL) AND
		    (@AssetAmount IS NOT NULL) AND
		    (@LiabilityAmount IS NOT NULL)) BEGIN
		
			SET @work = 'involuntary'
			IF (@USBankruptcyVoluntary = 'Y') BEGIN
				SET @work = 'voluntary'
			END
		
			SET @EventText = 'Subject company filed a {0} petition in bankruptcy under Chapter {1}.'
			SET @EventText = REPLACE(@EventText, '{0}', @work);
			SET @EventText = REPLACE(@EventText, '{1}', dbo.ufn_GetCustomCaptionValue('prbe_USBankruptcyType', @DetailedType, null));
			
			
			IF (@ReportType = 1) BEGIN
				SET @EventText = @EventText + '  The bankruptcy was filed as a {2} case with the {3} under the case number {4}.  Attorney for the debtor is {5}, {6}.  Trustee assigned to the case is {7}, {8}.  Assets were reported in the amount of ${9} and liabilities in the amount of ${10}.'
				SET @EventText = REPLACE(@EventText, '{2}', dbo.ufn_GetCustomCaptionValue('prbe_USBankruptcyCourt', @USBankruptcyCourt, null));			
				SET @EventText = REPLACE(@EventText, '{3}', @CourtDistrict);			
				SET @EventText = REPLACE(@EventText, '{4}', @CaseNumber);			
				SET @EventText = REPLACE(@EventText, '{5}', @AttorneyName);			
				SET @EventText = REPLACE(@EventText, '{6}', @AttorneyPhone);			
				SET @EventText = REPLACE(@EventText, '{7}', @AssigneeTrusteeName);			
				SET @EventText = REPLACE(@EventText, '{8}', @AssigneeTrusteePhone);			
				SET @EventText = REPLACE(@EventText, '{9}', @AssetAmount);			
				SET @EventText = REPLACE(@EventText, '{10}', @LiabilityAmount);			
				
			END ELSE BEGIN
				SET @EventText = @EventText + '  Additional details are documented in the Business Background section of this report.'
			END		
		
		END
	END			
	
	IF (@EventType = '6') BEGIN -- BUSINESS_EVENT_CANADIAN_BANKRUPTCY
		IF (@DetailedType IS NOT NULL) BEGIN
			SET @EventText = 'Subject company filed {0}.'
			SET @EventText = REPLACE(@EventText, '{0}', dbo.ufn_GetCustomCaptionValue('prbe_CanBankruptcyType', @DetailedType, null));
		END
	END		
	
	IF (@EventType = '7') BEGIN -- BUSINESS_EVENT_BUSINESS_CLOSED
		IF (@DetailedType IS NOT NULL) BEGIN
		
			IF (@DetailedType = '1') BEGIN
				SET @EventText = 'Subject company ceased operations with all obligations handled in full.'
			END ELSE IF (@DetailedType = '2') BEGIN
				SET @EventText = 'Subject company was reported liquidating.'
			END ELSE IF (@DetailedType = '3') BEGIN
				SET @EventText = 'Subject company suspended operations with obligations not fully liquidated.'
			END ELSE IF (@DetailedType = '4') BEGIN
				SET @EventText = 'Subject company inactivated operations.'
			END
		END
	END			
	
	IF (@EventType = '8') BEGIN -- BUSINESS_EVENT_BUSINESS_ENTITY_CHANGED
		IF (@DetailedType IS NOT NULL) BEGIN
			SET @EventText = 'Subject company converted to a {0} {1}.'
			SET @EventText = REPLACE(@EventText, '{0}', dbo.ufn_GetCustomCaptionValue('prbe_NewEntityType', @DetailedType, null));
			SET @EventText = REPLACE(@EventText, '{1}', dbo.ufn_GetBusinessEventUnderLawText(@DetailedType, @StateID));
		END
	END	
	
	IF (@EventType = '9') BEGIN -- BUSINESS_EVENT_BUSINESS_STARTED
		IF (@DetailedType IS NOT NULL) BEGIN
			SET @EventText = 'Subject company was established as a {0} {1}.'
			SET @EventText = REPLACE(@EventText, '{0}', dbo.ufn_GetCustomCaptionValue('prbe_NewEntityType', @DetailedType, null));
			SET @EventText = REPLACE(@EventText, '{1}', dbo.ufn_GetBusinessEventUnderLawText(@DetailedType, @StateID));
		END
	END	
	
	IF (@EventType = '10') BEGIN -- BUSINESS_EVENT_INDIVIDUAL_OWNERSHIP_CHANGE
		IF ((@DetailedType IS NOT NULL) AND
		    (@IndividualSellerId IS NOT NULL) AND
		    (@IndividualBuyerId IS NOT NULL) AND
		    (@PercentSold IS NOT NULL)) BEGIN
		    
		    SET @EventText = '{0} sold {1}% of the business {2} to {3}.'
			SET @EventText = REPLACE(@EventText, '{0}', dbo.ufn_FormatPersonById(@IndividualSellerId));
			SET @EventText = REPLACE(@EventText, '{1}', @PercentSold);
			SET @EventText = REPLACE(@EventText, '{2}', dbo.ufn_GetCustomCaptionValue('prbe_SaleType', @DetailedType, null));
			SET @EventText = REPLACE(@EventText, '{3}', dbo.ufn_FormatPersonById(@IndividualBuyerId));
		END		    
	END				
	
	IF (@EventType = '11') BEGIN -- BUSINESS_EVENT_DIVESTITURE
		IF ((@DetailedType IS NOT NULL) AND
		    (@RelatedCompany1ID IS NOT NULL)) BEGIN
	
			SET @EventText = 'Subject company sold {0} to {1}.'
			SET @EventText = REPLACE(@EventText, '{0}', dbo.ufn_GetBusinessEventTypeValue('prbe_AcquisitionType', @DetailedType, '6', @OtherDecription));
			SET @EventText = REPLACE(@EventText, '{1}', dbo.ufn_GetBusinessEventCompanyInfo(@EventType, @RelatedCompany1ID));
		END
	END
	
	IF (@EventType = '12') BEGIN -- BUSINESS_EVENT_DRC_ISSUE
		IF (@DetailedType IS NOT NULL) BEGIN
			IF (@DetailedType = '1') BEGIN
				SET @EventText = 'A fine or civil penalty was levied by the government or regulatory agency against subject company.'
			END ELSE IF (@DetailedType = '2') BEGIN
				SET @EventText = 'The Disupte Resolution Corporation (DRC) membership of subject company was suspended.'
			END ELSE IF (@DetailedType = '3') BEGIN
				SET @EventText = 'The Dispute Resolution Corporation (DRC) membership of subject company was revoked.'
			END ELSE IF (@DetailedType = '4') BEGIN
				SET @EventText = 'The Dispute Resolution Corporation (DRC) membership of subject company was reinstated.'
			END
		END
	END
	
	IF (@EventType = '13') BEGIN -- BUSINESS_EVENT_EXTENSION_COMPROMISE
		IF (@DetailedType IS NOT NULL) BEGIN
			IF (@DetailedType = '1') BEGIN
				SET @EventText = 'Subject company was reported asking general extension.'
			END ELSE IF (@DetailedType = '2') BEGIN
				SET @EventText = 'Subject company was reported granted general extension.'
			END ELSE IF (@DetailedType = '3') BEGIN
				SET @EventText = 'Subject company was reported asking one or more creditors for temporary extension.'
			END ELSE IF (@DetailedType = '4') BEGIN
				SET @EventText = 'Subject company was reported was granted temporary extension by one or more creditors.'
			END ELSE IF (@DetailedType = '5') BEGIN
				SET @EventText = 'Subject company was reported offering to compromise.'
			END ELSE IF (@DetailedType = '7') BEGIN
				SET @EventText = 'Subject company was reported compromised with creditors.'
			END
		END

	END
	
	IF (@EventType = '14') BEGIN -- BUSINESS_EVENT_FINANCIAL_EVENT
		SET @EventText = ''
	END				
	
	IF (@EventType = '15') BEGIN -- BUSINESS_EVENT_INDICTMENT
		SET @EventText = 'Subject company was reported indicted.'
	END		

	IF (@EventType = '16') BEGIN -- BUSINESS_EVENT_INDICTMENT_CLOSED
		SET @EventText = 'The indictment on subject company was reported closed.'
	END			

	IF (@EventType = '17') BEGIN -- BUSINESS_EVENT_INJUNCTIONS
		IF ((@CourtDistrict IS NOT NULL) AND
		    (@CaseNumber IS NOT NULL) AND
		    (@AttorneyName IS NOT NULL) AND
		    (@AttorneyPhone IS NOT NULL)) BEGIN

		    SET @EventText = 'An injunction was issued against subject company at {0}, under the case number {1}.  Attorney assigned to the case is {2}, {3}.'
			SET @EventText = REPLACE(@EventText, '{0}', @CourtDistrict);
			SET @EventText = REPLACE(@EventText, '{1}', @CaseNumber);
			SET @EventText = REPLACE(@EventText, '{2}', @AttorneyName);
			SET @EventText = REPLACE(@EventText, '{3}', @AttorneyPhone);
		END
	END			

	IF (@EventType = '18') BEGIN -- BUSINESS_EVENT_JUDGEMENT
		IF ((@Amount IS NOT NULL) AND
		    (@RelatedCompany1ID IS NOT NULL)) BEGIN
	
			SET @EventText = 'A judgement was reported on subject company in the amount of ${0}.  Creditor: {1}.'
			SET @EventText = REPLACE(@EventText, '{0}', @Amount);
			SET @EventText = REPLACE(@EventText, '{1}', dbo.ufn_GetBusinessEventCompanyInfo(@EventType, @RelatedCompany1ID));
		END
	END			

	IF (@EventType = '19') BEGIN -- BUSINESS_EVENT_LETTER_OF_INTENT
		IF ((@RelatedCompany1ID IS NOT NULL) AND
		    (@AgreementCategory IS NOT NULL) AND
		    (@DetailedType IS NOT NULL)) BEGIN
	
			SET @EventText = 'A letter of intent was signed between subject company and {0} to {1}, {2}.'
			SET @EventText = REPLACE(@EventText, '{0}', dbo.ufn_GetBusinessEventCompanyInfo(@EventType, @RelatedCompany1ID));
			SET @EventText = REPLACE(@EventText, '{1}', dbo.ufn_GetCustomCaptionValue('prbe_AgreementCategory', @AgreementCategory, null));
			SET @EventText = REPLACE(@EventText, '{2}', dbo.ufn_GetBusinessEventTypeValue('prbe_AcquisitionType', @DetailedType, '6', @OtherDecription));
			
		END
	END			

	IF (@EventType = '20') BEGIN -- BUSINESS_EVENT_LIEN
		IF ((@Amount IS NOT NULL) AND
		    (@RelatedCompany1ID IS NOT NULL)) BEGIN
	
			SET @EventText = 'A lien of public record was entered against subject company for ${0} in favor of {1}.'
			SET @EventText = REPLACE(@EventText, '{0}', @Amount);
			SET @EventText = REPLACE(@EventText, '{1}', dbo.ufn_GetBusinessEventCompanyInfo(@EventType, @RelatedCompany1ID));
		END
	END			

	IF (@EventType = '21') BEGIN -- BUSINESS_EVENT_LOCATION_CHANGE
		SET @EventText = ''
	END			

	IF (@EventType = '22') BEGIN -- BUSINESS_EVENT_MERGER
		SET @EventText = ''
	END			

	IF (@EventType = '23') BEGIN -- BUSINESS_EVENT_NATURAL_DISASTER
		IF ((@Amount IS NOT NULL) AND
		    (@DisasterImpact IS NOT NULL) AND
		    (@DetailedType IS NOT NULL)) BEGIN
	
			SET @EventText = 'Subject company suffered a {0} due to a {1}.  Damages were estimated at ${2}.'
			SET @EventText = REPLACE(@EventText, '{0}', dbo.ufn_GetCustomCaptionValue('prbe_DisasterImpact', @DisasterImpact, null));
			SET @EventText = REPLACE(@EventText, '{1}', dbo.ufn_GetBusinessEventTypeValue('prbe_DisasterType', @DetailedType, '7', @OtherDecription));
			SET @EventText = REPLACE(@EventText, '{2}', @Amount);
		END
	END			

	IF (@EventType = '24') BEGIN -- BUSINESS_EVENT_NOT_HANDLING_PRODUCE
		SET @EventText = 'Subject company reportedly discontinued handling fresh produce.'
	END			

	IF (@EventType = '25') BEGIN -- BUSINESS_EVENT_OTHER_LEGAL_ACTION
		SET @EventText = ''
	END			

	IF (@EventType = '26') BEGIN -- BUSINESS_EVENT_OTHER
		SET @EventText = ''
	END		

	IF (@EventType = '27') BEGIN -- BUSINESS_EVENT_OTHER_PACA
		SET @EventText = ''
	END			

	IF (@EventType = '28') BEGIN -- BUSINESS_EVENT_PACA_LICENSE_SUSPENDED

		IF (@DetailedType = '1') BEGIN
			IF ((@Amount IS NOT NULL) AND
				(@EffectiveDate IS NOT NULL) AND
				(@StateId IS NOT NULL) AND
				(@Names IS NOT NULL)) BEGIN
		
				SELECT @Work = prst_State
			      FROM PRState WITH (NOLOCK)
			     WHERE prst_StateId = @StateID;
		
		
				SET @EventText = 'An Agricultural Marketing Service (AMS) news release dated {0} reported that the USDA cited subject company for failure to pay a ${1} award in favor of a {2} seller under the Perishable Agricultural Commodities Act.  Subject company was barred from operating in the produce industry until the award was paid, and {3} could not be employed or affiliated with a PACA licensee without USDA approval.'
				SET @EventText = REPLACE(@EventText, '{0}', @EffectiveDate);
				SET @EventText = REPLACE(@EventText, '{1}', @Amount);
				SET @EventText = REPLACE(@EventText, '{2}', @Work);
				SET @EventText = REPLACE(@EventText, '{3}', @Names);
			END
		END
		
		IF (@DetailedType = '2') BEGIN
			IF ((@EffectiveDate IS NOT NULL) AND
				(@Amount IS NOT NULL) AND
				(@NumberSellers IS NOT NULL) AND
				(@NonPromptStart IS NOT NULL) AND
				(@NonPromptEnd IS NOT NULL) AND
				(@BusinessOperateUntil IS NOT NULL) AND
				(@Names IS NOT NULL) AND
				(@IndividualOperateUntil IS NOT NULL)) BEGIN
		
				SET @EventText = 'An Agricultural Marketing Service (AMS) news release dated {0} reported that the USDA cited subject company for "willful, repeated and flagrant violations of the Perishable Agricultural Commodities Act."  Subject company failed to pay promptly and in full ${1} for perishable agricultural commodities purchased, received and accepted from {2} sellers in the course of interstate commerce from {3} through {4}.  The firm could not operate in the produce industry until {5} and then only if it obtained a PACA license.  {6} could not be employed or affiliated with a PACA licensee until {7} and then only with the posting of a USDA-approved surety bond.'
				SET @EventText = REPLACE(@EventText, '{0}', @EffectiveDate);
				SET @EventText = REPLACE(@EventText, '{1}', @Amount);
				SET @EventText = REPLACE(@EventText, '{2}', @NumberSellers);
				SET @EventText = REPLACE(@EventText, '{3}', @NonPromptStart);
				SET @EventText = REPLACE(@EventText, '{4}', @NonPromptEnd);
				SET @EventText = REPLACE(@EventText, '{5}', @BusinessOperateUntil);
				SET @EventText = REPLACE(@EventText, '{6}', @Names);
				SET @EventText = REPLACE(@EventText, '{7}', @IndividualOperateUntil);
			END		
		END
	END				
		
	IF (@EventType = '29') BEGIN -- BUSINESS_EVENT_PACA_LICENSE_REINSTATED
		SET @EventText = 'The PACA license of subject company was reinstated.'
	END	
		
	IF (@EventType = '30') BEGIN -- BUSINESS_EVENT_PACA_TRUST_PROCEDURE
		IF ((@Amount IS NOT NULL) AND
		    (@RelatedCompany1ID IS NOT NULL)) BEGIN
	
			SET @EventText = '{0} filed an action to preserve its PACA trust rights in the amount of ${1} against subject company.'
			SET @EventText = REPLACE(@EventText, '{0}', dbo.ufn_GetBusinessEventCompanyInfo(@EventType, @RelatedCompany1ID));
			SET @EventText = REPLACE(@EventText, '{1}', @Amount);
		END
	END	
		
	IF (@EventType = '31') BEGIN -- BUSINESS_EVENT_PARTNERSHIP_DISOLUTION
		SET @EventText = ''
	END	
		
	IF (@EventType = '32') BEGIN -- BUSINESS_EVENT_RECEIVERSHIP_APPLIED_FOR
		IF ((@RelatedCompany1ID IS NOT NULL) AND
		    (@RelatedCompany2ID IS NOT NULL)) BEGIN
	
			SET @EventText = 'A receiver {0} was applied for by {1}.'
			SET @EventText = REPLACE(@EventText, '{0}', dbo.ufn_GetBusinessEventCompanyInfo(@EventType, @RelatedCompany1ID));
			SET @EventText = REPLACE(@EventText, '{1}', dbo.ufn_GetBusinessEventCompanyInfo(@EventType, @RelatedCompany2ID));
		END
	END	
		
	IF (@EventType = '33') BEGIN -- BUSINESS_EVENT_RECEIVERSHIP_APPOINTED
		IF ((@RelatedCompany1ID IS NOT NULL) AND
		    (@RelatedCompany2ID IS NOT NULL)) BEGIN
	
			SET @EventText = 'A receiver {0} was appointed by {1}.'
			SET @EventText = REPLACE(@EventText, '{0}', dbo.ufn_GetBusinessEventCompanyInfo(@EventType, @RelatedCompany1ID));
			SET @EventText = REPLACE(@EventText, '{1}', dbo.ufn_GetBusinessEventCompanyInfo(@EventType, @RelatedCompany2ID));
		END
	END	
		
	IF (@EventType = '34') BEGIN -- BUSINESS_EVENT_SEC_ACTIONS
		SET @EventText = ''
	END						
		
	IF (@EventType = '35') BEGIN -- BUSINESS_EVENT_PUBLIC_STOCK
		SET @EventText = ''
	END	
		
	IF (@EventType = '36') BEGIN -- BUSINESS_EVENT_TREASURY_STOCK
		SET @EventText = 'Subject company repurchased shares of its capital stock and retired it to treasury'
		
		IF (@Amount IS NOT NULL) BEGIN
			SET @EventText = @EventText + ' in a transaction valued at $'+ CAST(@Amount as varchar);
		END
		SET @EventText = @EventText + '.';
	END	
				
	IF (@EventType = '37') BEGIN -- BUSINESS_EVENT_TRO
		IF ((@CourtDistrict IS NOT NULL) AND
		    (@CaseNumber IS NOT NULL) AND
		    (@RelatedCompany1ID IS NOT NULL) AND
		    (@Amount IS NOT NULL)) BEGIN
	
			SET @EventText = 'A temporary restraining order was granted against the subject at {0}.  Case number is {1}.  Plaintiff, {2}, is seeking ${3}.'
			SET @EventText = REPLACE(@EventText, '{0}', @CourtDistrict);
			SET @EventText = REPLACE(@EventText, '{1}', @CaseNumber);
			SET @EventText = REPLACE(@EventText, '{2}', dbo.ufn_GetBusinessEventCompanyInfo(@EventType, @RelatedCompany1ID));
			SET @EventText = REPLACE(@EventText, '{3}', @Amount);
		END
	END	


	IF (@EventType = '42') BEGIN -- Commenced Operations
		SET @EventText = 'Subject company commenced operations.'
	END		
	
	IF @PublishedAnalysis IS NOT NULL BEGIN
		IF LEN(@EventText) > 0 BEGIN
			SET @EventText = @EventText + ' ';
		END
		
		SET @EventText = @EventText + @PublishedAnalysis;
	END
	
	RETURN @EventText

END
GO


 

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetPersonEventText]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    drop function [dbo].[ufn_GetPersonEventText]
GO

CREATE FUNCTION [dbo].[ufn_GetPersonEventText] ( 
    @PersonEventID int
)
RETURNS varchar(max)
AS
BEGIN

	DECLARE @work varchar(50)
	DECLARE @EventText varchar(max) = '', @PersonID int
	DECLARE @EventType varchar(40), @EffectiveDate varchar(50) 
	DECLARE @PublishedAnalysis varchar(max), @EducationInstitution varchar(75), @EducationDegree varchar(75)
	DECLARE @USBankruptcyVoluntary varchar(1), @USBankruptcyCourt varchar(40), @BankruptcyType varchar(40)
	DECLARE @CaseNumber varchar(15), @DischargeType varchar(40)




	SELECT @EventType = prpe_PersonEventTypeId,
	       @EffectiveDate = prpe_DisplayedEffectiveDate,
	       @PersonID = prpe_PersonId,
	       @PublishedAnalysis = prpe_PublishedAnalysis,
	       @BankruptcyType = prpe_BankruptcyType,
	       @USBankruptcyVoluntary = prpe_USBankruptcyVoluntary,
	       @USBankruptcyCourt = prpe_USBankruptcyCourt,
	       @CaseNumber = prpe_CaseNumber,
	       @EducationInstitution = prpe_EducationalInstitution,
	       @EducationDegree = prpe_EducationalDegree,
	       @DischargeType = prpe_DischargeType
	  FROM PRPersonEvent WITH (NOLOCK)
	 WHERE prpe_PersonEventId = @PersonEventID;


	IF @EventType = '1' BEGIN  -- PERSON_EVENT_DRC_VIOLATION
		SET @EventText = @PublishedAnalysis
	END
	
	IF @EventType = '2' BEGIN  -- PERSON_EVENT_PACA_VIOLATIONS
		SET @EventText = @PublishedAnalysis
	END	

	IF @EventType = '3' BEGIN  -- PERSON_EVENT_EDUCATION
		IF ((@EducationInstitution IS NOT NULL) AND
		    (@EducationDegree IS NOT NULL)) BEGIN
	
			SET @EventText = 'On {0}, {1} reportedly earned a {2} from {3}.'
			SET @EventText = REPLACE(@EventText, '{0}', @EffectiveDate);
			SET @EventText = REPLACE(@EventText, '{1}', dbo.ufn_FormatPersonById(@PersonID));
			SET @EventText = REPLACE(@EventText, '{2}', @EducationDegree);
			SET @EventText = REPLACE(@EventText, '{3}', @EducationInstitution);
		END
	END	

	IF @EventType = '4' BEGIN  -- PERSON_EVENT_BANKRUPTCY_FILED
		IF (@PublishedAnalysis IS NOT NULL) BEGIN
			SET @EventText = @PublishedAnalysis
		END ELSE BEGIN
	
			IF ((@BankruptcyType IS NOT NULL) AND
				(@USBankruptcyCourt IS NOT NULL) AND
				(@CaseNumber IS NOT NULL)) BEGIN
			    
				SET @work = 'involuntary'
				IF (@USBankruptcyVoluntary = 'Y') BEGIN
					SET @work = 'voluntary'
				END		    
		
				SET @EventText = 'On {0}, {1} filed a personal {2} {3} petition in bankruptcy.  The bankruptcy was filed with the {4} under the case number {5}.'
				SET @EventText = REPLACE(@EventText, '{0}', @EffectiveDate);
				SET @EventText = REPLACE(@EventText, '{1}', dbo.ufn_FormatPersonById(@PersonID));
				SET @EventText = REPLACE(@EventText, '{2}', @work);
				SET @EventText = REPLACE(@EventText, '{3}', dbo.ufn_GetCustomCaptionValue('prpe_BankruptcyType', @BankruptcyType, null));
				SET @EventText = REPLACE(@EventText, '{4}', @USBankruptcyCourt);
				SET @EventText = REPLACE(@EventText, '{5}', @CaseNumber);
			END
		END			
	END	

	IF @EventType = '5' BEGIN  -- PERSON_EVENT_BANKRUPTCY_DISMISSED
		IF ((@BankruptcyType IS NOT NULL) AND
		    (@DischargeType IS NOT NULL)) BEGIN
	
			SET @EventText = 'On {0}, the personal {1} bankruptcy petition filed by {2} was reported {3} by the court.'
			SET @EventText = REPLACE(@EventText, '{0}', @EffectiveDate);
			SET @EventText = REPLACE(@EventText, '{1}', dbo.ufn_GetCustomCaptionValue('prpe_BankruptcyType', @BankruptcyType, null));
			SET @EventText = REPLACE(@EventText, '{2}', dbo.ufn_FormatPersonById(@PersonID));
			SET @EventText = REPLACE(@EventText, '{3}', dbo.ufn_GetCustomCaptionValue('prpe_DischargeType', @DischargeType, null));
		END
	END	

	IF @EventType = '6' BEGIN  -- PERSON_EVENT_OTHER_LEGAL
		SET @EventText = @PublishedAnalysis
	END	

	IF @EventType = '7' BEGIN  -- PERSON_EVENT_OTHER
		SET @EventText = @PublishedAnalysis
	END	

	RETURN @EventText
END
Go	


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetTaxCode]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    drop function [dbo].[ufn_GetTaxCode]
GO
CREATE FUNCTION [dbo].[ufn_GetTaxCode] ( 
    @AddressID int
)
RETURNS varchar(40)
AS
BEGIN
	DECLARE @TaxCode varchar(40)
	DECLARE @State varchar(5)
	
	SELECT @State = prst_Abbreviation
	  FROM vPRAddress
     WHERE Addr_AddressId=@AddressID
	
	IF @State = 'IL' BEGIN
		SELECT @TaxCode = 'SYS000000'
	END ELSE BEGIN

		IF @State IN ('CA', 'CT', 'NY', 'PA', 'FL', 'MA', 'MN', 'ND') BEGIN

			SELECT @TaxCode = prtax_TaxCode
			  FROM vPRAddress
				   LEFT OUTER JOIN PRTaxRate WITH (NOLOCK) ON addr_uszipfive = prtax_PostalCode
												AND addr_PRCounty = prtax_County
												AND prci_City = prtax_City
				WHERE Addr_AddressId=@AddressID;
	
			IF @TaxCode IS NULL BEGIN
				SELECT @TaxCode = prtax_TaxCode
				  FROM vPRAddress
					   LEFT OUTER JOIN PRTaxRate WITH (NOLOCK) ON addr_uszipfive = prtax_PostalCode
													AND addr_PRCounty = prtax_County
					WHERE Addr_AddressId=@AddressID;

				IF @TaxCode IS NULL BEGIN
					SELECT @TaxCode = prtax_TaxCode
					  FROM vPRAddress
						   LEFT OUTER JOIN PRTaxRate WITH (NOLOCK) ON addr_uszipfive = prtax_PostalCode
														AND prst_Abbreviation = prtax_State
						WHERE Addr_AddressId=@AddressID;
				END
			END
		END
	END
	
	IF (@TaxCode IS NULL) BEGIN
		SET @TaxCode = 'NT'
	END
	
	RETURN @TaxCode
END
GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetWorkDayCount]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    drop function [dbo].[ufn_GetWorkDayCount]
GO
CREATE FUNCTION [dbo].[ufn_GetWorkDayCount] ( 
    @StartDate datetime,
    @EndDate datetime
)
RETURNS int
AS
BEGIN

    SELECT @StartDate = DATEADD(dd,DATEDIFF(dd,0,@StartDate),0), 
           @EndDate   = DATEADD(dd,DATEDIFF(dd,0,@EndDate)  ,0) 


	DECLARE @TotalDays int, @Holidays int 

	SET @TotalDays =
          --Start with total number of days including weekends 
            (DATEDIFF(dd,@StartDate,@EndDate)+1) 
 
          --Subtact 2 days for each full weekend 
           -(DATEDIFF(wk,@StartDate,@EndDate)*2) 
 
          --If StartDate is a Sunday, Subtract 1 
           -(CASE WHEN DATENAME(dw,@StartDate) = 'Sunday' 
                  THEN 1 
                  ELSE 0 
              END) 
 
          --If EndDate is a Saturday, Subtract 1 
           -(CASE WHEN DATENAME(dw,@EndDate) = 'Saturday' 
                  THEN 1 
                  ELSE 0 
              END) 


	SELECT @Holidays = COUNT(1) 
      FROM PRHoliday WITH (NOLOCK)
     WHERE prhldy_Date BETWEEN @StartDate AND @EndDate;
             
	RETURN @TotalDays - @Holidays;
END
Go


IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[ufn_GetPaymentHistory]') 
            AND OBJECTPROPERTY(id, N'IsTableFunction') = 1)
	DROP FUNCTION [dbo].[ufn_GetPaymentHistory]
GO

CREATE FUNCTION ufn_GetPaymentHistory
(
	@CompanyID int,
	@SalesOrderNo varchar(20) = NULL
)
RETURNS @tblReturn table (
    Sequence int identity (0,1),
	UDF_MASTER_INVOICE varchar(20),
	TransactionDate datetime,
	TransactionType varchar(1),
	TransactionTypeDesc varchar(255),
	TransactionAmt decimal(12,2),
	Balance decimal(12,2),
	DaysToPay varchar(10),
	CheckNo varchar(10))
as
BEGIN

	DECLARE @MyTable table (
		MASTER_INVOICE_NO varchar(20),
		TransactionDate datetime,
		TransactionType varchar(1),
		TransactionAmt decimal(12,2),
		Balance decimal(12,2),
		DaysToPay int,
		CheckNo varchar(10))
	
	INSERT INTO @MyTable (MASTER_INVOICE_NO, TransactionDate, TransactionType, TransactionAmt, CheckNo)
	SELECT UDF_MASTER_INVOICE,
		   tph.TransactionDate,
		   TransactionType,
		   SUM(CASE TransactionType 
				WHEN 'P' THEN 0 - TransactionAmt
				WHEN 'C' THEN 0 - TransactionAmt
				WHEN 'X' THEN 0 - TransactionAmt
				WHEN 'A' THEN 0 - TransactionAmt
				WHEN 'D' THEN 0 - TransactionAmt
				ElSE TransactionAmt END),
		   CheckNo
	  FROM MAS_PRC.dbo.AR_InvoiceHistoryHeader ihh 
		   LEFT OUTER JOIN MAS_PRC.dbo.AR_TransactionPaymentHistory tph ON tph.InvoiceNo = ihh.InvoiceNo 
		                                                                --AND tph.CustomerNo = ihh.CustomerNo
																		AND tph.CustomerNo = MAS_PRC.dbo.ufn_GetBillTo(ihh.BillToCustomerNo, ihh.CustomerNo)
		   LEFT OUTER JOIN MAS_PRC.dbo.SO_SalesOrderHistoryHeader soh ON ihh.SalesOrderNo = soh.SalesOrderNo
	 WHERE tph.CustomerNo = @CompanyID
	   --AND soh.SalesOrderNo = ISNULL(@SalesOrderNo, soh.SalesOrderNo) 
	GROUP BY tph.CustomerNo,
		   UDF_MASTER_INVOICE,
		   ihh.InvoiceDate,
		   tph.TransactionDate,
		   TransactionType,
		   CheckNo
	ORDER BY TransactionDate 


	IF (@SalesOrderNo IS NOT NULL) BEGIN
		DELETE 
		  FROM @MyTable
		 WHERE MASTER_INVOICE_NO NOT IN
				(SELECT DISTINCT UDF_MASTER_INVOICE
	               FROM MAS_PRC.dbo.AR_InvoiceHistoryHeader ihh 
		                INNER JOIN MAS_PRC.dbo.SO_SalesOrderHistoryHeader soh ON ihh.SalesOrderNo = soh.SalesOrderNo
	              WHERE soh.MasterRepeatingOrderNo = @SalesOrderNo);
	
	END


	DECLARE @RunningTotal decimal(12,2) 
	SET @RunningTotal = 0 

	DECLARE @LastInvoiceDate datetime

	 UPDATE @MyTable 
		SET @RunningTotal = Balance =  @RunningTotal + TransactionAmt
	   FROM @MyTable 

	UPDATE @MyTable
	   SET DaysToPay = tmp.DaysToPay
	  FROM @MyTable mt,
			(
			SELECT i.Master_Invoice_No, p.TransactionDate as PaymentDate, MIN(i.TransactionDate) As InvoiceDate,
				   DATEDIFF(day, MIN(i.TransactionDate), p.TransactionDate) As DaysToPay
			  FROM @MyTable i
				   INNER JOIN @MyTable p ON i.Master_Invoice_No = p.Master_Invoice_No
			 WHERE i.TransactionType = 'I'
			   AND p.TransactionType = 'P'       
			   AND i.Master_Invoice_No <> ''
			GROUP BY i.Master_Invoice_No, p.TransactionDate
			) tmp
	 WHERE mt.Master_Invoice_No = tmp.Master_Invoice_No
	   AND mt.TransactionType = 'P'
	   AND mt.TransactionDate = tmp.PaymentDate

	INSERT INTO @tblReturn
	 SELECT Master_Invoice_No, TransactionDate, TransactionType, capt_us, TransactionAmt, Balance, DaysToPay, CheckNo 
	   FROM @MyTable
	        LEFT OUTER JOIN Custom_Captions ON capt_family = 'TransactionType' AND capt_Code = TransactionType
   ORDER BY TransactionDate DESC, TransactionType DESC;

	RETURN
END	
Go



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetEnterpriseAvailableLicenseCount]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    drop function [dbo].[ufn_GetEnterpriseAvailableLicenseCount]
GO


CREATE FUNCTION [dbo].[ufn_GetEnterpriseAvailableLicenseCount](@HQID int)
RETURNS int
AS
BEGIN

	DECLARE @Count int

	SELECT @Count = SUM(QuantityOrdered)
	  FROM PRService 
	 WHERE prse_HQID=@HQID
	   AND Category2 = 'LICENSE'

	RETURN ISNULL(@Count, 0)
END
GO

       
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetAdPublicationViewCount]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    drop function [dbo].[ufn_GetAdPublicationViewCount]
GO


CREATE FUNCTION [dbo].[ufn_GetAdPublicationViewCount](@AdCampaignID int)
RETURNS int
AS
BEGIN

	DECLARE @ViewCount int
	
	SELECT @ViewCount = COUNT(prpar_PublicationArticleID)
      FROM PRAdCampaign WITH (NOLOCK)
           LEFT OUTER JOIN PRPublicationArticleRead WITH (NOLOCK) ON pradc_PublicationArticleID = prpar_PublicationArticleID
     WHERE pradc_AdCampaignID = @AdCampaignID
       AND prpar_CreatedDate BETWEEN pradc_StartDate AND ISNULL(pradc_EndDate, GETDATE())
       
	RETURN @ViewCount       
END
GO       

CREATE OR ALTER FUNCTION [dbo].[ufn_GetFormattedEmail3](@CompanyID int, @PersonID int, @WebUserID int, @Title varchar(500), @Body varchar(max), @AddresseeOverride varchar(100), @Culture varchar(40), @IndustryType varchar(40), @TopImage varchar(5000)=NULL, @BottomImage varchar(5000)=NULL)
RETURNS varchar(max)
AS
BEGIN

DECLARE @EmailTemplate varchar(max) =
'<!DOCTYPE HTML>
<html>
	<head>
		<title>{0}</title>
	</head>
	<body style="font-family: "abel", Arial, Helvetica, sans-serif;">

    <table style="width:800px;margin-left:auto;margin-right:auto;background-color:#E0E0E0;margin-left:auto;margin-right:auto;" align="center">
    <tr>
        <td style="padding:15px;">
        
            <table style="width:100%;border: thin solid #C0C0C0;background-color:White;" align="center">
            <tr>
                <td style="width:150px;text-align:center;">
                    <img src="http://apps.bluebookservices.com/BBOS/en-us/images/LogoEmail.png" />
                </td>            
                <td style="width:650px;color:#1025a2">
                    <div style="text-align:center;font-size:26pt;font-weight:bold;">{0}</div>
                </td>
				 <td style="width:150px;text-align:center;">
					&nbsp;
				 </td>
            </tr>   

            <tr>
                <td colspan="3" style="background-color:#1025a2;height:5px;"></td>
            </tr>

            <tr>
                <td valign="top" style="vertical-align:top;width:150px;padding-left:15px">

					<table width="100%" style="width:100%;border:1px solid #CCCCCC;margin-top:10px" cellpadding="0" cellspacing="0">
					<tr>
						<td style="height:45px;text-align:center;font-weight:bold;font-size:10pt;background-color:#EAEAEA;color:#1025a2;padding-left:5px;padding-right:5px;padding-top:5px;padding-bottom:5px;vertical-align:middle;">{10}</td>
					</tr>
					<tr>
						<td style="margin-top:15px;margin-bottom:15px;padding-left:5px;padding-right:5px;padding-top:5px;padding-bottom:5px;">
							<p style="font-style:italic;font-size:10pt;text-align:center;">Blue Book Services</p>

							<p style="font-size:8pt;">
							<a href="mailto:info@bluebookservices.com">info@bluebookservices.com</a><br />
							<a href="https://{1}">{1}</a>
							</p>
                
							<p style="font-size:8pt;">
							{14} 630-668-3500<br />
							fax 630-668-0303
							</p>                    
						</td>
					</tr>
					</table>

					<table width="100%" style="width:100%;border:1px solid #CCCCCC;margin-top:10px;{9}" cellpadding="0" cellspacing="0">
					<tr>
						<td style="height:45px;text-align:center;font-weight:bold;font-size:10pt;background-color:#EAEAEA;color:#1025a2;padding-left:5px;padding-right:5px;padding-top:5px;padding-bottom:5px;vertical-align:middle">{11}</td>
					</tr>	
					<tr>
						<td style="margin-top:15px;margin-bottom:15px;padding-left:5px;padding-right:5px;padding-top:5px;padding-bottom:5px;">
							<p style="font-size:9pt;">BBID: {2}<br/>
                			{3}<br/>
							{4}</p>

							{13}

							<p style="font-size:9pt;margin-top:7pt;margin-bottom:4pt;text-align:center;">
							<a href="{5}" style="color:blue;text-decoration:underline;">{16}</a>
							</p>
						</td>
					</tr>
					</table>

                </td>
            

                <td colspan="2" valign="top" style="padding-top:20px;padding-left:15px;padding-right:15px;font-size:12pt;">
                    {17}
					{7}

                    {8}

					<p>{12}</p>

					<p><em>Blue Book Services</em></p>
					{18}
                </td>
            </tr>
            
			<tr>
				<td colspan="3" style="font-size:10px;font-style:italic;">
					{15}
				</td>
            <tr>
                <td colspan="3" style="font-size:12px;text-align:center;font-style:italic;background-color:#1025a2;color:White;font-weight:bold;height:25px;">
                    {6}
                </td>
            </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td style="text-align:center;font-size:10px;font-weight:bold;">
            845 East Geneva Road &nbsp;&nbsp;&nbsp; Carol Stream, IL 60188 &nbsp;&nbsp;&nbsp; {14} 630-668-3500 &nbsp;&nbsp;&nbsp; fax 630-668-0303 &nbsp;&nbsp;&nbsp; <a href="mailto:info@bluebookservices.com">info@bluebookservices.com</a>
        </td>
    </tr>                     

    </table>
	</body>
</html>';


	DECLARE @Website varchar(100), @BBID varchar(10), @CompanyName varchar(200) = '', @Membership varchar(200) = '', @comp_PRIsIntlTradeAssociation nchar(1)
	DECLARE @MarketingMessage varchar(1000), @PersonName varchar(100) = '', @TempPersonID int, @TempIndustryType varchar(40)
	DECLARE @AccessLevel varchar(40), @BBOSURL varchar(100), @AccountSummaryStyle varchar(50) = ''
	DECLARE @AvailBRs int, @AvailableBRMsg varchar(400) = '', @YouHaveMsg_L varchar(300) = '', @YouHaveMsg_R varchar(300) = '' 

	IF (@CompanyID = 0) BEGIN
	
		SELECT @CompanyID = ISNULL(prwu_BBID, 0),
			   @TempPersonID = peli_PersonID,
			   @TempIndustryType = prwu_IndustryTypeCode,
			   @AccessLevel = prwu_AccessLevel
		  FROM PRWebUser WITH (NOLOCK)
		       LEFT OUTER JOIN Person_Link WITH (NOLOCK) ON prwu_PersonLinkID = peli_PersonLinkID
		 WHERE prwu_WebUserID = @WebUserID;

		 IF ((@TempIndustryType IS NOT NULL) AND (@IndustryType IS NULL)) BEGIN
			SET @IndustryType = @TempIndustryType
		 END

		 IF (@PersonID = 0) BEGIN
			SET @PersonID = @TempPersonID
		 END
	END 

	IF (@CompanyID > 0) BEGIN
		SELECT @IndustryType = comp_PRIndustryType, 
			   @Membership = ISNULL(ItemCodeDesc, ''),
			   @CompanyName = comp_PRBookTradestyle,
			   @AvailBRs = dbo.ufn_GetAvailableUnits(comp_CompanyID),
               @comp_PRIsIntlTradeAssociation = comp_PRIsIntlTradeAssociation
		  FROM Company WITH (NOLOCK)
			   LEFT OUTER JOIN vPRPrimaryService ON comp_PRHQID = EnteredCompanyID
		 WHERE comp_CompanyID=@CompanyID;

		IF (@AvailBRs > 0) BEGIN
        	SET @YouHaveMsg_L = dbo.ufn_GetCustomCaptionValue('EmailTemplate', 'YouHaveMsg_L', @Culture)
			SET @YouHaveMsg_R = dbo.ufn_GetCustomCaptionValue('EmailTemplate', 'YouHaveMsg_R', @Culture)
			--SET @AvailableBRMsg = '<p style="font-size:9pt;">You have ' + CAST(@AvailBRs as varchar(10))  + ' Business Reports to use this year.  Login now to get yours today!</p><p style="font-size:9pt;">Need more reports? Contact a customer service rep.</p>'
            SET @AvailableBRMsg = @YouHaveMsg_L + CAST(@AvailBRs as varchar(10)) +  @YouHaveMsg_R
		END
	END

	IF ((@AddresseeOverride IS NULL) OR (@AddresseeOverride = '')) BEGIN
		 IF ((@PersonID IS NOT NULL) AND (@PersonID > 0)) BEGIN
			--SET @PersonName = dbo.ufn_FormatPersonById(@PersonID);
			SELECT @PersonName = RTRIM(pers_FirstName)
			  FROM Person WITH (NOLOCK)
			 WHERE pers_PersonID = @PersonID;
		 END
	END	ELSE BEGIN
		SET @PersonName = @AddresseeOverride
	END

	IF (@PersonName NOT LIKE 'Attn:%') BEGIN
		IF (@Culture = 'es-mx') BEGIN
			IF (@PersonName <> '') BEGIN
				SET @PersonName = 'Estimado a ' + @PersonName + ','
			END
		END ELSE BEGIN
			IF (@PersonName <> '') BEGIN
				SET @PersonName = 'Dear ' + @PersonName + ','
			END
		END
	END
	 
	 IF (@IndustryType = 'L') BEGIN
		SET @Website = dbo.ufn_GetCustomCaptionValue('LumberWebSite', 'URL', 'en-us')
		SET @MarketingMessage = dbo.ufn_GetCustomCaptionValueDefault('EmailTemplate', 'MarketingMessageL', '')
	 END ELSE BEGIN
		SET @Website = dbo.ufn_GetCustomCaptionValue('ProduceWebSite', 'URL', 'en-us')
		SET @MarketingMessage = dbo.ufn_GetCustomCaptionValueDefault('EmailTemplate', 'MarketingMessageP', '')
	 END

	 SET @Website = REPLACE(@Website, 'http://', '')
	 SET @Website = REPLACE(@Website, 'https://', '')
	 SET @Website = REPLACE(@Website, '/', '')

	 SET @BBOSURL = dbo.ufn_GetCustomCaptionValue('BBOS', 'URL', 'en-us')

	 DECLARE @LeftBarHeader varchar(100) = dbo.ufn_GetCustomCaptionValue('EmailTemplate', 'LeftBarHeader', @Culture)
	 DECLARE @AccountSummary varchar(100) = dbo.ufn_GetCustomCaptionValue('EmailTemplate', 'AccountSummary', @Culture)
	 DECLARE @ThankYou varchar(100) = dbo.ufn_GetCustomCaptionValue('EmailTemplate', 'ThankYou', @Culture)
	 DECLARE @Phone varchar(100) = dbo.ufn_GetCustomCaptionValue('EmailTemplate', 'Phone', @Culture)
	 DECLARE @Disclaimer varchar(500) = dbo.ufn_GetCustomCaptionValue('EmailTemplate', 'Disclaimer', @Culture)
	 DECLARE @Login varchar(100) = dbo.ufn_GetCustomCaptionValue('EmailTemplate', 'Login', @Culture)
	 DECLARE @TopImageText varchar(5000) = ''
	 DECLARE @BottomImageText varchar(5000) = ''
	 
     IF(@comp_PRIsIntlTradeAssociation = 'Y')
	 BEGIN
		SET @Membership = 'Limitado'
	 END

	 IF (@Membership = '') BEGIN
		SET @AccountSummaryStyle = '';
		SET @AvailableBRMsg = '';
	 END

	IF(@TopImage IS NOT NULL) BEGIN
		SET @TopImageText = '<p>' + @TopImage + '</p>'
	END
	IF(@BottomImage IS NOT NULL) BEGIN
		SET @BottomImageText = '<p>' + @BottomImage + '</p>'
	END

	 DECLARE @Email varchar(max) = @EmailTemplate;
	 SET @Email = REPLACE(@Email, '{0}', @Title);
	 SET @Email = REPLACE(@Email, '{1}', @Website);
	 SET @Email = REPLACE(@Email, '{2}', CAST(@CompanyID as varchar));
	 SET @Email = REPLACE(@Email, '{3}', @CompanyName);
	 SET @Email = REPLACE(@Email, '{4}', @Membership);
	 SET @Email = REPLACE(@Email, '{5}', @BBOSURL);
	 SET @Email = REPLACE(@Email, '{6}', @MarketingMessage);
	 SET @Email = REPLACE(@Email, '{7}', @PersonName);
	 SET @Email = REPLACE(@Email, '{8}', @Body);
	 SET @Email = REPLACE(@Email, '{9}', @AccountSummaryStyle);
	 SET @Email = REPLACE(@Email, '{10}', @LeftBarHeader);
	 SET @Email = REPLACE(@Email, '{11}', @AccountSummary);
	 SET @Email = REPLACE(@Email, '{12}', @ThankYou);
	 SET @Email = REPLACE(@Email, '{13}', @AvailableBRMsg);
	 SET @Email = REPLACE(@Email, '{14}', @Phone);
	 SET @Email = REPLACE(@Email, '{15}', @Disclaimer);
	 SET @Email = REPLACE(@Email, '{16}', @Login);
	 SET @Email = REPLACE(@Email, '{17}', @TopImageText);
	 SET @Email = REPLACE(@Email, '{18}', @BottomImageText);

	 RETURN @Email
END
GO     

       
IF EXISTS (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetFormattedEmail2]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    DROP FUNCTION [dbo].[ufn_GetFormattedEmail2]
GO

CREATE FUNCTION [dbo].[ufn_GetFormattedEmail2](@CompanyID int, @PersonID int, @WebUserID int, @Title varchar(500), @Body varchar(max), @AddresseeOverride varchar(100), @Culture varchar(40))
RETURNS varchar(max)
AS
BEGIN

	RETURN dbo.ufn_GetFormattedEmail3(@CompanyID, @PersonID, @WebUserID, @Title, @Body, @AddresseeOverride, @Culture, null, null, null)

END
Go

IF EXISTS (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetFormattedEmail4]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    DROP FUNCTION [dbo].[ufn_GetFormattedEmail4]
GO

CREATE FUNCTION [dbo].[ufn_GetFormattedEmail4](@CompanyID int, @PersonID int, @WebUserID int, @Title varchar(500), @Body varchar(max), @AddresseeOverride varchar(100), @Culture varchar(40), @TopImage varchar(5000), @BottomImage varchar(5000))
RETURNS varchar(max)
AS
BEGIN

	RETURN dbo.ufn_GetFormattedEmail3(@CompanyID, @PersonID, @WebUserID, @Title, @Body, @AddresseeOverride, @Culture, null, @TopImage, @BottomImage)
END
Go


IF EXISTS (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetFormattedEmail]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    DROP FUNCTION [dbo].[ufn_GetFormattedEmail]
GO


CREATE FUNCTION [dbo].[ufn_GetFormattedEmail](@CompanyID int, @PersonID int, @WebUserID int, @Title varchar(500), @Body varchar(max), @AddresseeOverride varchar(100))
RETURNS varchar(max)
AS
BEGIN

	RETURN dbo.ufn_GetFormattedEmail2(@CompanyID, @PersonID, @WebUserID, @Title, @Body, @AddresseeOverride, 'en-us')

END
Go



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetUnitUsageHistorySummary]') 
            and OBJECTPROPERTY(id, N'IsTableFunction') = 1)
drop Function [dbo].[ufn_GetUnitUsageHistorySummary]
GO

CREATE FUNCTION dbo.ufn_GetUnitUsageHistorySummary
(
	@HQID int, 
	@YearCount int = 2
)
RETURNS @tblResults TABLE (
		[Year] int,
		OBR varchar(200),
		FBR varchar(200),
		VBR varchar(200),
		EBR varchar(200),
		TOTAL varchar(200))
as
BEGIN

	DECLARE @MyTable table (
		[Year] int,
		UsageTypeCode varchar(40),
		UsageTypeDesc varchar(500),
		UsageCount int,
		UsageUnits int
	)

	DECLARE @CurrentYear int = YEAR(GETDATE())
	DECLARE @Count int = 0

	WHILE @Count < @YearCount BEGIN

		INSERT INTO @MyTable
		SELECT @CurrentYear, capt_code, capt_us, 0, 0
		  FROM custom_captions
		 WHERE capt_family = 'prsuu_UsageTypeCode'
		   AND capt_code IN ('OBR', 'VBR', 'EBR', 'FBR')

		INSERT INTO @MyTable
		SELECT @CurrentYear, 'TOTAL', 'TOTAL', 0, 0

		SET @CurrentYear = @CurrentYear - 1
		SET @Count = @Count + 1
	END

	--
	--  There was a bug about counting reversals.  Since each usage is one unit, we will use the unit sum for
	--  both the unit usage and the count
	--
	UPDATE @MyTable
	  SET UsageCount = T1.UsageCount,
		  UsageUnits = T1.UsageUnits
	 FROM (
		SELECT Year(prsuu_CreatedDate) UsageYear, prsuu_UsageTypeCode, SUM(prsuu_Units) as UsageCount, SUM(prsuu_Units) as UsageUnits
		  FROM vPRServiceUnitUsageHistoryCRM
		 WHERE prsuu_HQID = @HQID    
		GROUP BY Year(prsuu_CreatedDate), prsuu_UsageTypeCode)  T1
	WHERE [Year] = UsageYear
	  AND UsageTypeCode = prsuu_UsageTypeCode

	UPDATE @MyTable
	  SET UsageCount = T1.UsageCount,
		  UsageUnits = T1.UsageUnits
	 FROM (
	    SELECT Year(prsuu_CreatedDate) UsageYear, SUM(CASE prsuu_TransactionTypeCode WHEN 'C' THEN 0 ELSE prsuu_Units END) as UsageCount, SUM(CASE prsuu_TransactionTypeCode WHEN 'C' THEN 0-prsuu_Units ELSE prsuu_Units END) as UsageUnits
		  FROM vPRServiceUnitUsageHistoryCRM
		 WHERE prsuu_HQID = @HQID    
		GROUP BY Year(prsuu_CreatedDate))  T1
	WHERE [Year] = UsageYear
	  AND UsageTypeCode = 'TOTAL';


	INSERT INTO @tblResults ([Year], OBR, FBR, VBR, EBR, TOTAL)
	SELECT pvt.[Year], pvt.OBR, pvt.FBR, pvt.VBR, pvt.EBR, pvt.TOTAL
	  FROM ( 
			SELECT [Year], 
			       [UsageTypeCode], 
				   CAST(UsageCount as varchar) + ' reports' as Cnt
			  FROM @MyTable
			) T1
	 PIVOT (MAX(Cnt)
			for [UsageTypeCode] IN (OBR, FBR, VBR, EBR, TOTAL)
		   ) pvt
	ORDER BY [Year] DESC


	DECLARE @TotalAllocatedUnits int = dbo.ufn_GetAllocatedUnits(@HQID)
	DECLARE @TotalAvailabileUnits int = dbo.ufn_GetAvailableUnits(@HQID)

	DECLARE @UsedUnits int = @TotalAllocatedUnits - @TotalAvailabileUnits
	DECLARE @AllocatedReports int = @TotalAllocatedUnits
	DECLARE @UsedReports int = @UsedUnits 

	UPDATE @tblResults
	   SET TOTAL = CAST(@UsedReports as varchar) + ' of ' + CAST(@AllocatedReports as varchar) + ' reports used'
     WHERE [Year] =	YEAR(GETDATE());


	RETURN
END
Go

IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[ufn_GetAncillarySerivcesList]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    DROP FUNCTION [dbo].[ufn_GetAncillarySerivcesList]
GO

CREATE Function ufn_GetAncillarySerivcesList(@CompanyID int)
RETURNS varchar(2000)
AS
BEGIN
    
    DECLARE @List varchar(2000)

    SELECT @List = COALESCE(@List + ', ', '') + prse_ServiceCode
      FROM PRService WITH (NOLOCK)
     WHERE prse_CompanyID = @CompanyID
	   AND SalesKitItem = 'N'
	   AND prse_Primary IS NULL;

    RETURN @List
END
Go



IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[ufn_GetRelationshipList]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    DROP FUNCTION [dbo].ufn_GetRelationshipList
GO

--
-- 
--
CREATE Function ufn_GetRelationshipList(@LeftCompanyID int, @RightCompanyID int)
RETURNS varchar(8000)
AS
BEGIN
    
    DECLARE @List varchar(8000)

    SELECT @List = COALESCE(@List + ', ', '') + CAST(capt_us as varchar(50))
      FROM PRCompanyRelationship WITH (NOLOCK)
           INNER JOIN Custom_Captions ON prcr_Type = capt_code AND capt_family = 'prcr_TypeFilter'
     WHERE prcr_LeftCompanyID = @LeftCompanyID
	   AND prcr_RightCompanyID = @RightCompanyID
	   AND prcr_Active = 'Y';

    RETURN @List
END
Go

IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[ufn_GetLastRLRelationshipType]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    DROP FUNCTION [dbo].ufn_GetLastRLRelationshipType
GO

--
-- 
--
CREATE Function ufn_GetLastRLRelationshipType(@LeftCompanyID int, @RightCompanyID int)
RETURNS varchar(100)
AS
BEGIN
    
    DECLARE @List varchar(100)

    SELECT TOP 1 @List =  CAST(capt_us as varchar(50))
      FROM PRCompanyRelationship WITH (NOLOCK)
           INNER JOIN Custom_Captions ON prcr_Type = capt_code AND capt_family = 'prcr_TypeFilter'
     WHERE prcr_LeftCompanyID = @LeftCompanyID
	   AND prcr_RightCompanyID = @RightCompanyID
	   AND prcr_Active = 'Y'
	   AND prcr_Type IN ('09','10','11','12','13','14','15','16') 
	   ORDER BY prcr_LastReportedDate DESC;

    RETURN @List
END
Go


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetCustomTESOption1]') 
            and OBJECTPROPERTY(id, N'IsTableFunction') = 1)
drop Function [dbo].[ufn_GetCustomTESOption1]
GO

CREATE FUNCTION [dbo].[ufn_GetCustomTESOption1] (@SubjectCompanyID int)
RETURNS @Results TABLE (
    prtesr_ResponderCompanyId int primary key,
    prtesr_SubjectCompanyId int,
    comp_Name varchar(104),
    DeliveryAddress varchar(500)
) AS
BEGIN

    -- Our core query
    INSERT INTO @Results
    SELECT DISTINCT prtr_ResponderId, prtr_SubjectId,  comp_Name, DeliveryAddress
      FROM PRTradeReport WITH (NOLOCK)
           INNER JOIN Company WITH (NOLOCK) ON prtr_ResponderId = comp_CompanyId
           INNER JOIN vPRCompanyAttentionLine ON prtr_ResponderID = prattn_CompanyID AND prattn_ItemCode = 'TES-E'
     WHERE comp_PRReceiveTES = 'Y' 
       AND comp_PRListingStatus in ('L','H','N1','N2')  
       AND prtr_PayRatingId in (2,3,4)  
       AND prtr_Duplicate IS NULL
       AND prtr_Date BETWEEN DATEADD(month, -12, GETDATE()) AND DATEADD(month, -3, GETDATE())
       AND prtr_SubjectId = @SubjectCompanyID
       AND prtr_SubjectId != prtr_ResponderId;


    -- First remove any responders that do have an active relationship to the subject company
    DELETE FROM @Results
     WHERE prtesr_ResponderCompanyId IN 
            (SELECT a.prtesr_ResponderCompanyId
               FROM @Results a
              INNER JOIN PRCompanyRelationship ON prtesr_ResponderCompanyId = prcr_RightCompanyID
                                              AND prcr_LeftCompanyId = @SubjectCompanyID
                                              AND prcr_Active is null)

    DELETE FROM @Results
     WHERE dbo.ufn_IsEligibleForManualTES(prtesr_ResponderCompanyId, @SubjectCompanyID) = 0;


    -- Remove those responders that have already
    -- had over 50 TES requests
    DELETE FROM @Results
     WHERE prtesr_ResponderCompanyId IN (SELECT a.prtesr_ResponderCompanyId
                                  FROM @Results a
                                       INNER JOIN PRTES ON a.prtesr_ResponderCompanyId = PRTES.prte_ResponderCompanyId
                                 WHERE prte_Date >= DATEADD(Day, -90, GETDATE())
                              GROUP BY a.prtesr_ResponderCompanyId
                                HAVING COUNT(1) >= 50);


    -- Remove those responders that have provided
    -- A/R Aging data in the past 90 days
    DELETE FROM @Results
     WHERE prtesr_ResponderCompanyId IN (SELECT praa_CompanyId
                                  FROM @Results
                                       INNER JOIN PRARAging ON prtesr_ResponderCompanyId = praa_CompanyId
                                 WHERE  praa_Date >= DATEADD(Day, -90, GETDATE()))


    -- Remove those responders that have already 
    -- sent a TES request on our subject in the past
    -- 27 days
    DELETE FROM @Results
     WHERE prtesr_ResponderCompanyId IN (SELECT a.prtesr_ResponderCompanyId
                                  FROM @Results a
                                       INNER JOIN PRTES ON a.prtesr_ResponderCompanyId = PRTES.prte_ResponderCompanyId
                                       INNER JOIN PRTESDetail ON prte_TESId = prt2_TESId
                                 WHERE PRTESDetail.prt2_SubjectCompanyId = @SubjectCompanyID
                                   AND prte_Date >= DATEADD(Day, - 27, GETDATE()));


    -- Remove those responders that have provided trade
    -- report data on our subject in the past 45 days.
    DELETE FROM @Results
     WHERE prtesr_ResponderCompanyId IN (SELECT prtr_ResponderId
                                  FROM @Results
                                       INNER JOIN PRTradeReport ON prtesr_ResponderCompanyId = prtr_ResponderId
                                 WHERE prtr_SubjectId = @SubjectCompanyID
                                   AND prtr_Date >= DATEADD(Day, -45, GETDATE()))
    RETURN
END
Go



If Exists (Select name from sysobjects where name = 'ufn_GetCustomTESOption2' and type in (N'FN', N'IF', N'TF')) 
    Drop Function dbo.ufn_GetCustomTESOption2
Go

CREATE FUNCTION [dbo].[ufn_GetCustomTESOption2] (@SubjectCompanyID int)
RETURNS @Results TABLE (
    prtesr_ResponderCompanyID int primary key,
    prtesr_SubjectCompanyID int,
    comp_Name varchar(104),
    DeliveryAddress varchar(500),
    prcr_Tier int
) AS
BEGIN
     -- Our core query
     INSERT INTO @Results 
     SELECT RelatedCompanyID, @SubjectCompanyID, comp_Name, DeliveryAddress, prcr_Tier
       FROM ufn_GetTieredRelationships(@SubjectCompanyID)
            INNER JOIN Company WITH (NOLOCK) ON RelatedCompanyID = comp_CompanyID
            INNER JOIN vPRCompanyAttentionLine ON RelatedCompanyID = prattn_CompanyID AND prattn_ItemCode = 'TES-E'
      WHERE comp_PRReceiveTES = 'Y' 
        AND comp_PRListingStatus in ('L','H','N1','N2')
        AND RelatedCompanyId != @SubjectCompanyId
    -- First remove any responders that do have an active relationship to the subject company
    DELETE FROM @Results
     WHERE prtesr_ResponderCompanyID IN 
            (SELECT a.prtesr_ResponderCompanyID
               FROM @Results a
              INNER JOIN PRCompanyRelationship ON prtesr_ResponderCompanyID = prcr_RightCompanyID
                                              AND prcr_LeftCompanyId = @SubjectCompanyID
                                              AND prcr_Active is null)
    DELETE FROM @Results
     WHERE dbo.ufn_IsEligibleForManualTES(prtesr_ResponderCompanyID, @SubjectCompanyID) = 0;

    -- Remove those responders that have already
    -- had over 50 TES requests
    DELETE FROM @Results
     WHERE prtesr_ResponderCompanyID IN (SELECT a.prtesr_ResponderCompanyID
                                  FROM @Results a
                                       INNER JOIN PRTESRequest ON a.prtesr_ResponderCompanyID = PRTESRequest.prtesr_ResponderCompanyID
                                 WHERE prtesr_CreatedDate >= DATEADD(Day, -90, GETDATE())
                              GROUP BY a.prtesr_ResponderCompanyID
                                HAVING COUNT(1) >= 50);
    -- Remove those responders that have provided
    -- A/R Aging data in the past 90 days
    DELETE FROM @Results
     WHERE prtesr_ResponderCompanyID IN (SELECT praa_CompanyId
                                  FROM @Results
                                       INNER JOIN PRARAging ON prtesr_ResponderCompanyID = praa_CompanyId
                                 WHERE  praa_Date >= DATEADD(Day, -90, GETDATE()))
    -- Remove those responders that have already 
    -- sent a TES request on our subject in the past
    -- 27 days
    DELETE FROM @Results
     WHERE prtesr_ResponderCompanyID IN (SELECT a.prtesr_ResponderCompanyID
                                  FROM @Results a
                                       INNER JOIN PRTESRequest ON a.prtesr_ResponderCompanyID = PRTESRequest.prtesr_ResponderCompanyID
                                 WHERE PRTESRequest.prtesr_SubjectCompanyID = @SubjectCompanyID
                                   AND prtesr_CreatedDate >= DATEADD(Day, - 27, GETDATE()));
    -- Remove those responders that have provided trade
    -- report data on our subject in the past 45 days.
    DELETE FROM @Results
     WHERE prtesr_ResponderCompanyID IN (SELECT prtr_ResponderId
                                  FROM @Results
                                       INNER JOIN PRTradeReport ON prtesr_ResponderCompanyID = prtr_ResponderId
                                 WHERE prtr_SubjectId = @SubjectCompanyID
                                   AND prtr_Date >= DATEADD(Day, -45, GETDATE()))
    RETURN
END
Go


If Exists (Select name from sysobjects where name = 'ufn_GetCustomTESOption3' and type in (N'FN', N'IF', N'TF')) 
    Drop Function dbo.ufn_GetCustomTESOption3
Go

CREATE FUNCTION [dbo].[ufn_GetCustomTESOption3] (@SubjectCompanyID int)
RETURNS @Results TABLE (
    prtesr_ResponderCompanyID int primary key,
    prtesr_SubjectCompanyID int,
    comp_Name varchar(104),
    DeliveryAddress varchar(500),
    prcr_Tier int
) AS
BEGIN
    -- Our core query
    INSERT INTO @Results
    SELECT DISTINCT prtr_ResponderId, prtr_SubjectId,  comp_Name, DeliveryAddress, 0
      FROM PRTradeReport WITH (NOLOCK)
           INNER JOIN Company WITH (NOLOCK) ON prtr_ResponderId = comp_CompanyId
           INNER JOIN vPRCompanyAttentionLine ON prtr_ResponderID = prattn_CompanyID AND prattn_ItemCode = 'TES-E'
     WHERE comp_PRReceiveTES = 'Y' 
       AND comp_PRListingStatus in ('L','H','N1','N2')  
       AND prtr_Date >= DATEADD(month, -24, GETDATE()) 
       AND prtr_SubjectId = @SubjectCompanyID
       AND prtr_SubjectId != prtr_ResponderId
     -- Our secondardy query.  The first query sets the tier to 
     -- zero (0) so those records should always be sorted first.
     INSERT INTO @Results
     SELECT RelatedCompanyID, @SubjectCompanyID, comp_Name, dbo.ufn_GetCompanyPhone(RelatedCompanyID, 'Y', NULL, 'F', null), prcr_Tier
       FROM ufn_GetTieredRelationships(@SubjectCompanyID)
            INNER JOIN Company ON RelatedCompanyID = comp_CompanyID
      WHERE comp_PRReceiveTES = 'Y' 
        AND comp_PRListingStatus in ('L','H','N1','N2')
        AND RelatedCompanyID NOT IN (SELECT prtesr_ResponderCompanyID 
                                      FROM @Results);
    -- First remove any responders that do have an active relationship to the subject company
    DELETE FROM @Results
     WHERE prtesr_ResponderCompanyID IN 
            (SELECT a.prtesr_ResponderCompanyID
               FROM @Results a
              INNER JOIN PRCompanyRelationship ON prtesr_ResponderCompanyID = prcr_RightCompanyID
                                              AND prcr_LeftCompanyId = @SubjectCompanyID
                                              AND prcr_Active is null)
    DELETE FROM @Results
     WHERE dbo.ufn_IsEligibleForManualTES(prtesr_ResponderCompanyID, @SubjectCompanyID) = 0;

    -- Remove those responders that have already
    -- had over 50 TES requests
    DELETE FROM @Results
     WHERE prtesr_ResponderCompanyID IN (SELECT a.prtesr_ResponderCompanyID
                                  FROM @Results a
                                       INNER JOIN PRTESRequest ON a.prtesr_ResponderCompanyID = PRTESRequest.prtesr_ResponderCompanyID
                                 WHERE prtesr_CreatedDate >= DATEADD(Day, -90, GETDATE())
                              GROUP BY a.prtesr_ResponderCompanyID
                                HAVING COUNT(1) >= 50);
    -- Remove those responders that have provided
    -- A/R Aging data in the past 90 days
    DELETE FROM @Results
     WHERE prtesr_ResponderCompanyID IN (SELECT praa_CompanyId
                                  FROM @Results
                                       INNER JOIN PRARAging ON prtesr_ResponderCompanyID = praa_CompanyId
                                 WHERE  praa_Date >= DATEADD(Day, -90, GETDATE()))
    -- Remove those responders that have already 
    -- sent a TES request on our subject in the past
    -- 27 days
    DELETE FROM @Results
     WHERE prtesr_ResponderCompanyID IN (SELECT a.prtesr_ResponderCompanyID
                                  FROM @Results a
                                       INNER JOIN PRTESRequest ON a.prtesr_ResponderCompanyID = PRTESRequest.prtesr_ResponderCompanyID
                                 WHERE PRTESRequest.prtesr_SubjectCompanyID = @SubjectCompanyID
                                   AND prtesr_CreatedDate >= DATEADD(Day, - 27, GETDATE()));
    -- Remove those responders that have provided trade
    -- report data on our subject in the past 45 days.
    DELETE FROM @Results
     WHERE prtesr_ResponderCompanyID IN (SELECT prtr_ResponderId
                                  FROM @Results
                                       INNER JOIN PRTradeReport ON prtesr_ResponderCompanyID = prtr_ResponderId
                                 WHERE prtr_SubjectId = @SubjectCompanyID
                                   AND prtr_Date >= DATEADD(Day, -45, GETDATE()))
    RETURN
END
Go

If Exists (Select name from sysobjects where name = 'ufn_GetCustomTESOption4' and type in (N'FN', N'IF', N'TF')) 
    Drop Function dbo.ufn_GetCustomTESOption4
Go

CREATE FUNCTION [dbo].[ufn_GetCustomTESOption4] (@SubjectCompanyID int)
RETURNS @Results TABLE (
    prtesr_ResponderCompanyID int primary key,
    prtesr_SubjectCompanyID int,
    comp_Name varchar(104),
    DeliveryAddress varchar(500)
) AS
BEGIN
    -- Go get companies that have the specified relationships
    -- within the past 12 months
    INSERT INTO @Results (prtesr_ResponderCompanyID, prtesr_SubjectCompanyID)
    SELECT DISTINCT 
      CASE 
        WHEN prcr_LeftCompanyId = @SubjectCompanyID THEN prcr_RightCompanyId 
        ELSE prcr_LeftCompanyId 
      END,
      @SubjectCompanyID
     FROM PRCompanyRelationship  WITH (NOLOCK)
    WHERE (prcr_LeftCompanyId = @SubjectCompanyID OR prcr_RightCompanyId = @SubjectCompanyID)
      AND prcr_Type IN ('04', '09', '10', '11', '12', '13', '14', '15', '23', '25') 
      AND prcr_LastReportedDate > DATEADD(Month, -12, GETDATE()) 
       AND prcr_LeftCompanyId != prcr_RightCompanyId 

    -- Go get the names, addresses for those that receive TES
    -- and are listed.
    UPDATE @Results
       SET r.comp_Name = Company.comp_Name,
           r.DeliveryAddress = vPRCompanyAttentionLine.DeliveryAddress
      FROM @Results r
           INNER JOIN Company WITH (NOLOCK) ON prtesr_ResponderCompanyID = comp_CompanyId
           INNER JOIN vPRCompanyAttentionLine ON comp_CompanyId = prattn_CompanyID AND prattn_ItemCode = 'TES-E'
     WHERE comp_PRReceiveTES = 'Y' 
       AND comp_PRListingStatus in ('L','H','N1','N2');
    -- Any record that does not have a name should
    -- be removed
    DELETE FROM @Results WHERE comp_Name IS NULL;
    -- First remove any responders that do have an active relationship to the subject company
    DELETE FROM @Results
     WHERE prtesr_ResponderCompanyID IN 
            (SELECT a.prtesr_ResponderCompanyID
               FROM @Results a
              INNER JOIN PRCompanyRelationship ON prtesr_ResponderCompanyID = prcr_RightCompanyID
                                              AND prcr_LeftCompanyId = @SubjectCompanyID
                                              AND prcr_Active is null)
    DELETE FROM @Results
     WHERE dbo.ufn_IsEligibleForManualTES(prtesr_ResponderCompanyID, @SubjectCompanyID) = 0;

    -- Remove those responders that have already
    -- had over 50 TES requests
    DELETE FROM @Results
     WHERE prtesr_ResponderCompanyID IN (SELECT a.prtesr_ResponderCompanyID
                                  FROM @Results a
                                       INNER JOIN PRTESRequest ON a.prtesr_ResponderCompanyID = PRTESRequest.prtesr_ResponderCompanyID
                                 WHERE prtesr_CreatedDate >= DATEADD(Day, -90, GETDATE())
                              GROUP BY a.prtesr_ResponderCompanyID
                                HAVING COUNT(1) >= 50);
    -- Remove those responders that have provided
    -- A/R Aging data in the past 90 days
    DELETE FROM @Results
     WHERE prtesr_ResponderCompanyID IN (SELECT praa_CompanyId
                                  FROM @Results
                                       INNER JOIN PRARAging ON prtesr_ResponderCompanyID = praa_CompanyId
                                 WHERE  praa_Date >= DATEADD(Day, -90, GETDATE()))
    /*** DIFFERENCE FROM OTHER OPTIONS ***/
    -- Remove those responders that have already 
    -- sent a TES request on our subject in the past
    -- 60 days
    DELETE FROM @Results
     WHERE prtesr_ResponderCompanyID IN (SELECT a.prtesr_ResponderCompanyID
                                  FROM @Results a
                                       INNER JOIN PRTESRequest ON a.prtesr_ResponderCompanyID = PRTESRequest.prtesr_ResponderCompanyID
                                 WHERE PRTESRequest.prtesr_SubjectCompanyID = @SubjectCompanyID
                                   AND prtesr_CreatedDate >= DATEADD(Day, - 60, GETDATE()));
    -- Remove those responders that have provided trade
    -- report data on our subject in the past 45 days.
    DELETE FROM @Results
     WHERE prtesr_ResponderCompanyID IN (SELECT prtr_ResponderId
                                  FROM @Results
                                       INNER JOIN PRTradeReport ON prtesr_ResponderCompanyID = prtr_ResponderId
                                 WHERE prtr_SubjectId = @SubjectCompanyID
                                   AND prtr_Date >= DATEADD(Day, -45, GETDATE()))
    RETURN
END
Go


If Exists (Select name from sysobjects where name = 'ufn_GetCustomTESOption5' and type in (N'FN', N'IF', N'TF')) 
    Drop Function dbo.ufn_GetCustomTESOption5
Go

CREATE FUNCTION [dbo].[ufn_GetCustomTESOption5]
(
    @SubjectCompanyId int = NULL,
    @StartDate datetime = NULL,
    @EndDate datetime = NULL,
    @RelationshipType varchar(40) = NULL,
    @ListingStatus varchar(40) = NULL
)
RETURNS @Results TABLE (
    prtesr_ResponderCompanyID int,
    comp_Name varchar (104),
    comp_PRListingStatus varchar(40),
    prcr_Types varchar(200),
    CityStateCountryShort varchar (100),
    prtesr_SentDateTimeMAX datetime, 
    prcr_LastUpdatedMAX datetime,
    DeliveryAddress varchar(500)
)
AS 
BEGIN
    -- this is a single statement right now; 
    -- if it gets much more complicated, it can be broken out into seperate calls
    INSERT INTO @Results 
    SELECT ATable.prtesr_ResponderCompanyID, 
        comp_Name, 
        custom_captions.capt_us AS comp_PRListingStatus, 
        prcr_Types,
        CityStateCountryShort, 
        prtesr_SentDateTimeMAX, 
        prcr_LastUpdatedMAX,
        DeliveryAddress
    FROM 
    ( 
      SELECT * FROM 
      (
        SELECT prtesr_ResponderCompanyID,
          prcr_Types = dbo.ufn_GetCompanyRelationshipsList(@SubjectCompanyId, prtesr_ResponderCompanyID)
        FROM 
        (
          SELECT DISTINCT prtesr_ResponderCompanyID = 
            CASE 
            WHEN prcr_LeftCompanyId = @SubjectCompanyId then prcr_RightCompanyId 
            ELSE prcr_LeftCompanyId 
            END
          FROM PRCompanyRelationship 
          WHERE (prcr_LeftCompanyId = @SubjectCompanyId OR prcr_RightCompanyId = @SubjectCompanyId)
             AND prcr_Type NOT IN ('27', '28', '29', '30', '31', '32') 
             AND prcr_LeftCompanyId != prcr_RightCompanyId
             AND prcr_Active = 'Y'
        ) AllRelationships
      ) FilterRelationships
      WHERE (@RelationshipType IS NULL OR CHARINDEX(@RelationshipType, prcr_Types) > 0) 
    ) ATable 
    INNER JOIN Company ON prtesr_ResponderCompanyID = comp_CompanyId 
                AND (comp_PRReceiveTES = 'Y')
                AND comp_PRListingStatus in ('L','H','N1','N2') 
                AND (@ListingStatus IS NULL OR comp_PRListingStatus = @ListingStatus)
                AND (comp_PRHQID IS NULL OR comp_PRHQID <> @SubjectCompanyID)
    INNER JOIN vPRLocation ON comp_PRListingCityId = prci_CityId
    INNER JOIN vPRCompanyAttentionLine ON prtesr_ResponderCompanyID = prattn_CompanyID AND prattn_ItemCode = 'TES-E'
    INNER JOIN custom_captions ON comp_PRListingStatus = capt_code AND capt_family = 'comp_PRListingStatus'
    INNER JOIN 
    ( 
      SELECT * FROM 
      (
        SELECT RelatedCompanyId, prcr_LastUpdatedMAX = MAX(prcr_LastReportedDate)
          FROM (
            SELECT RelatedCompanyId = prcr_RightCompanyId, prcr_LastReportedDate     
              FROM PRCompanyrelationship 
             WHERE prcr_LeftCompanyId = @SubjectCompanyId
			   AND prcr_Active = 'Y'
            UNION
            SELECT RelatedCompanyId = prcr_LeftCompanyId, prcr_LastReportedDate
              FROM PRCompanyrelationship 
             WHERE prcr_RightCompanyId = @SubjectCompanyId
			   AND prcr_Active = 'Y'
                ) UniqueRelated 
        GROUP BY RelatedCompanyId    
      ) UniqueLastUpdated
      WHERE (@StartDate IS NULL OR @StartDate <= prcr_LastUpdatedMAX )
        AND (@EndDate IS NULL OR @EndDate >= prcr_LastUpdatedMAX )
    ) LASTUPDATED ON ATAble.prtesr_ResponderCompanyID = RelatedCompanyId
    LEFT OUTER JOIN 
    (
        SELECT prtesr_ResponderCompanyID, prtesr_SentDateTimeMAX = MAX(prtesr_SentDateTime) 
          FROM PRTESRequest
      GROUP BY prtesr_ResponderCompanyID
    ) LastTESDate ON ATable.prtesr_ResponderCompanyID = LastTESDate.prtesr_ResponderCompanyID    
    -- First remove any responders that do have an active relationship to the subject company
    DELETE FROM @Results
     WHERE prtesr_ResponderCompanyID IN 
            (SELECT a.prtesr_ResponderCompanyID
               FROM @Results a
              INNER JOIN PRCompanyRelationship ON prtesr_ResponderCompanyID = prcr_RightCompanyID
                                              AND prcr_LeftCompanyId = @SubjectCompanyID
                                              AND prcr_Active is null)
    DELETE FROM @Results
     WHERE dbo.ufn_IsEligibleForManualTES(prtesr_ResponderCompanyID, @SubjectCompanyID) = 0;
    -- Remove those responders that have already
    -- had over 50 TES requests
    DELETE FROM @Results
     WHERE prtesr_ResponderCompanyID IN (SELECT a.prtesr_ResponderCompanyID
                                  FROM @Results a
                                       INNER JOIN PRTESRequest ON a.prtesr_ResponderCompanyID = PRTESRequest.prtesr_ResponderCompanyID
                                 WHERE prtesr_CreatedDate >= DATEADD(Day, -90, GETDATE())
                              GROUP BY a.prtesr_ResponderCompanyID
                                HAVING COUNT(1) >= 50);
    -- Remove those responders that have provided
    -- A/R Aging data in the past 90 days
    DELETE FROM @Results
     WHERE prtesr_ResponderCompanyID IN (SELECT praa_CompanyId
                                  FROM @Results
                                       INNER JOIN PRARAging ON prtesr_ResponderCompanyID = praa_CompanyId
                                 WHERE  praa_Date >= DATEADD(Day, -90, GETDATE()))
    -- Remove those responders that have already 
    -- sent a TES request on our subject in the past
    -- 27 days
    DELETE FROM @Results
     WHERE prtesr_ResponderCompanyID IN (SELECT a.prtesr_ResponderCompanyID
                                  FROM @Results a
                                       INNER JOIN PRTESRequest ON a.prtesr_ResponderCompanyID = PRTESRequest.prtesr_ResponderCompanyID
                                 WHERE PRTESRequest.prtesr_SubjectCompanyID = @SubjectCompanyID
                                   AND PRTESRequest.prtesr_CreatedDate >= DATEADD(Day, -27, GETDATE()));
    -- Remove those responders that have provided trade
    -- report data on our subject in the past 45 days.
    DELETE FROM @Results
     WHERE prtesr_ResponderCompanyID IN (SELECT prtr_ResponderId
                                  FROM @Results
                                       INNER JOIN PRTradeReport ON prtesr_ResponderCompanyID = prtr_ResponderId
                                 WHERE prtr_SubjectId = @SubjectCompanyID
                                   AND prtr_Date >= DATEADD(Day, -45, GETDATE()))
    RETURN
END
Go


If Exists (Select name from sysobjects where name = 'ufn_GetCustomTESOption6' and type in (N'FN', N'IF', N'TF')) 
    Drop Function dbo.ufn_GetCustomTESOption6
Go

CREATE FUNCTION [dbo].[ufn_GetCustomTESOption6]
(
    @SubjectCompanyId int = NULL,
    @StartDate datetime = NULL,
    @EndDate datetime = NULL,
    @RelationshipType varchar(40) = NULL,
    @ListingStatus varchar(40) = NULL,
	@ConnectionListOnly char(1) = NULL
)
RETURNS @Results TABLE (
    prtesr_ResponderCompanyID int,
    comp_Name varchar (104),
    comp_PRListingStatus varchar(40),
    prcr_Types varchar(200),
    CityStateCountryShort varchar (100),
    prcr_LastUpdatedMAX datetime,
    DeliveryAddress varchar(500),
	prtesr_SentDateTimeSubject datetime,
	TimesSent int
)
AS 
BEGIN

	INSERT INTO @Results 
    SELECT DISTINCT
	    PRTESRequest.prtesr_ResponderCompanyID, 
        comp_Name, 
        CAST(custom_captions.capt_us as varchar(100)) AS comp_PRListingStatus, 
        prcr_Types,
        CityStateCountryShort, 
        prcr_LastUpdatedMAX,
        DeliveryAddress,
		MAX(CAST(prtesr_SentDateTime as Date)) as prtesr_SentDateTimeSubject,
		COUNT(1) as TimesSent
    FROM PRTESRequest
    INNER JOIN Company ON prtesr_ResponderCompanyID = comp_CompanyId 
                AND (comp_PRReceiveTES = 'Y')
                AND comp_PRListingStatus in ('L','H','N1','N2') 
                AND (@ListingStatus IS NULL OR comp_PRListingStatus = @ListingStatus)
    INNER JOIN vPRLocation ON comp_PRListingCityId = prci_CityId
    INNER JOIN vPRCompanyAttentionLine eTES ON prtesr_ResponderCompanyID = eTES.prattn_CompanyID AND eTES.prattn_ItemCode = 'TES-E' AND eTES.prattn_Disabled IS NULL
	INNER JOIN PRAttentionLine mailTES ON prtesr_ResponderCompanyID = mailTES.prattn_CompanyID AND mailTES.prattn_ItemCode = 'TES-M' AND mailTES.prattn_Disabled = 'Y'
    INNER JOIN custom_captions ON comp_PRListingStatus = capt_code AND capt_family = 'comp_PRListingStatus'
    LEFT OUTER JOIN
		( 
		  SELECT * FROM 
		  (
			SELECT RelatedCompanyId2,
			  prcr_Types = dbo.ufn_GetCompanyRelationshipsList(@SubjectCompanyId, RelatedCompanyId2)
			FROM 
			(
			  SELECT DISTINCT RelatedCompanyId2 = 
				CASE 
				WHEN prcr_LeftCompanyId = @SubjectCompanyId then prcr_RightCompanyId 
				ELSE prcr_LeftCompanyId 
				END
			  FROM PRCompanyRelationship 
			  WHERE (prcr_LeftCompanyId = @SubjectCompanyId OR prcr_RightCompanyId = @SubjectCompanyId)
				 AND prcr_Type NOT IN ('27', '28', '29', '30', '31', '32') 
				 AND prcr_LeftCompanyId != prcr_RightCompanyId
				 AND prcr_Active = 'Y'
			) AllRelationships
		  ) FilterRelationships
		  WHERE (@RelationshipType IS NULL OR CHARINDEX(@RelationshipType, prcr_Types) > 0) 
	    ) ATable ON RelatedCompanyId2 = prtesr_ResponderCompanyID
	LEFT OUTER JOIN
		(
		SELECT DISTINCT prcr_RightCompanyID, IsOnCL = 'Y'
		  FROM PRCompanyRelationship
		 WHERE prcr_LeftCompanyID = @SubjectCompanyId
		   AND prcr_Active = 'Y'
		   AND prcr_Type IN ('09', '10', '11', '12', '15')
		 ) tblConnectionList ON prcr_RightCompanyID = prtesr_ResponderCompanyID
	INNER JOIN 
    ( 
      SELECT * FROM 
      (
        SELECT RelatedCompanyId, prcr_LastUpdatedMAX = MAX(prcr_LastReportedDate)
          FROM (
            SELECT RelatedCompanyId = prcr_RightCompanyId, prcr_LastReportedDate     
              FROM PRCompanyrelationship 
             WHERE prcr_LeftCompanyId = @SubjectCompanyId
			   AND prcr_Active = 'Y'
            UNION
            SELECT RelatedCompanyId = prcr_LeftCompanyId, prcr_LastReportedDate
              FROM PRCompanyrelationship 
             WHERE prcr_RightCompanyId = @SubjectCompanyId
			   AND prcr_Active = 'Y'
                ) UniqueRelated 
        GROUP BY RelatedCompanyId    
      ) UniqueLastUpdated
    ) LASTUPDATED ON prtesr_ResponderCompanyID = RelatedCompanyId
    INNER JOIN 
	(
		SELECT prtesr_ResponderCompanyID, prtesr_SubjectCompanyID as C2, MAX(prtesr_TESRequestID) as MostRecentTESRequestID
		  FROM PRTESRequest 
		 WHERE prtesr_SubjectCompanyID =@SubjectCompanyId    
		   AND (@StartDate IS NULL OR @StartDate <= prtesr_SentDateTime )
		   AND (@EndDate IS NULL OR @EndDate >= prtesr_SentDateTime )
		GROUP BY prtesr_ResponderCompanyID, prtesr_SubjectCompanyID
	) MostRecentTES ON MostRecentTESRequestID = PRTESRequest.prtesr_TESRequestID
 WHERE prtesr_SubjectCompanyID =@SubjectCompanyId    
   AND (@StartDate IS NULL OR @StartDate <= prtesr_SentDateTime )
   AND (@EndDate IS NULL OR @EndDate >= prtesr_SentDateTime )
   AND prtesr_Received IS NULL
   AND (@ConnectionListOnly IS NULL OR ISNULL(IsOnCL, 'N') = @ConnectionListOnly)
   AND PRTESRequest.prtesr_ResponderCompanyID NOT IN (SELECT DISTINCT prtesr_ResponderCompanyID FROM PRTESRequest WHERE prtesr_SubjectCompanyID = @SubjectCompanyID AND prtesr_CreatedDate >= ISNULL(@EndDate, GETDATE()))
GROUP BY PRTESRequest.prtesr_ResponderCompanyID, 
        comp_Name, 
        CAST(custom_captions.capt_us as varchar(100)),
        prcr_Types,
        CityStateCountryShort, 
        prcr_LastUpdatedMAX,
        DeliveryAddress
ORDER BY prtesr_SentDateTimeSubject DESC; -- comp_Name;

    RETURN
END
Go


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ufn_CalcTradeReportPayMedian]'))
	DROP FUNCTION dbo.ufn_CalcTradeReportPayMedian
GO
CREATE FUNCTION dbo.ufn_CalcTradeReportPayMedian(@SubjectCompanyID int,
                                                 @DaysOld int)
RETURNS varchar(40)
AS
BEGIN
	
	DECLARE @m1 int, @m2 int, @MedianID int
    DECLARE @Return varchar(40)

	SELECT TOP 50 PERCENT @m1 = prpy_PayRatingId
	  FROM PRTradeReport 
           INNER JOIN PRPayRating ON prtr_PayRatingId = prpy_PayRatingId
	 WHERE DATEDIFF(d, prtr_Date, GETDATE()) <= @DaysOld
       AND prtr_SubjectID = @SubjectCompanyID
       AND prpy_Weight IS NOT NULL
  ORDER BY prpy_PayRatingId ASC;
	
	SELECT TOP 50 PERCENT @m2 = prpy_PayRatingId
	  FROM PRTradeReport 
           INNER JOIN PRPayRating ON prtr_PayRatingId = prpy_PayRatingId
	 WHERE DATEDIFF(d, prtr_Date, GETDATE()) <= @DaysOld
       AND prtr_SubjectID = @SubjectCompanyID
       AND prpy_Weight IS NOT NULL
  ORDER BY prpy_PayRatingId DESC;

	 
	SET @MedianID = (@m1+@m2)/2.0
	SELECT @Return = prpy_Name FROM PRPayRating WHERE prpy_PayRatingId = @MedianID;

	RETURN @Return
	

END
Go


IF EXISTS (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_PreparePostName]') 
        AND xtype in (N'FN', N'IF', N'TF')) 
    DROP FUNCTION [dbo].[ufn_PreparePostName]
GO

CREATE FUNCTION [dbo].[ufn_PreparePostName] ( 
    @Temp varchar(5000)
)
RETURNS varchar(5000)
AS
BEGIN

    DECLARE @KeepValues as varchar(50) = '%[^a-z0-9 ]%'
    WHILE PATINDEX(@KeepValues, @Temp) > 0
        SET @Temp = STUFF(@Temp, PATINDEX(@KeepValues, @Temp), 1, '')

	SET @Temp = RTRIM(@Temp)
	SET @Temp = REPLACE(@Temp, '  ', ' ')
	SET @Temp = REPLACE(@Temp, ' ', '-')
	SET @Temp = LOWER(@Temp)
	SET @Temp = LEFT(@Temp, 175)
	
    RETURN @Temp
END
Go


IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[ufn_GetNoteReminderList]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    DROP FUNCTION [dbo].[ufn_GetNoteReminderList]
GO

CREATE Function ufn_GetNoteReminderList(@NoteID int, @WebUserID int, @LineBreak varchar(10))
	RETURNS varchar(2000)
AS
BEGIN

	DECLARE @List varchar(2000)
	SELECT @List = COALESCE(@List + @LineBreak, '') +CAST(capt_us as varchar(100)) + 
		   CASE prwunr_Type WHEN 'BBOS' THEN '' 
							WHEN 'Email' THEN ': ' + prwunr_Email
							WHEN 'Text' THEN ': ' + prwunr_Phone END
	  FROM PRWebUserNoteReminder WITH (NOLOCK)
		   INNER JOIN Custom_Captions ON prwunr_Type = capt_code AND capt_family = 'prwunr_Type'
	 WHERE prwunr_WebUserNoteID = @NoteID
	   AND prwunr_WebUserID = @WebUserID
	RETURN @List
END
Go


IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[ufn_GetRatingNumeralAssignedDate]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    DROP FUNCTION [dbo].[ufn_GetRatingNumeralAssignedDate]
GO

CREATE Function ufn_GetRatingNumeralAssignedDate(@CompanyID int, @RatingNumeral varchar(10))
	RETURNS date
AS
BEGIN

	DECLARE @RatingNumeralDate Date

	DECLARE @tblWork table (
		ndx int identity(1,1),
		RatingID int,
		RatingNumerals varchar(100),
		RatingDate date)

	INSERT INTO @tblWork
	SELECT prra_RatingID, prra_AssignedRatingNumerals, prra_Date
	  FROM vPRCompanyRating WITH (NOLOCK)
     WHERE prra_CompanyID = @CompanyID
  ORDER BY prra_Date DESC	  

  DECLARE @Count int, @Index int
  DECLARE @RatingNumerals varchar(100), @RatingDate date

  SELECT @Count = COUNT(1) FROM @tblWork
  SET @Index = 0

  WHILE (@Index < @Count) BEGIN

	SET @Index = @Index + 1

	SELECT @RatingDate = RatingDate,
	       @RatingNumerals = RatingNumerals
	  FROM @tblWork
	 WHERE ndx = @Index 

	 IF (@RatingNumerals LIKE '%' + @RatingNumeral + '%') BEGIN
		SET @RatingNumeralDate = @RatingDate
	 END ELSE BEGIN
		-- Break the loop
		SET @Index = @Count + 1
	 END
  END

  RETURN @RatingNumeralDate
END
Go


IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[ufn_ExtractRatingNumerals]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    DROP Function [dbo].[ufn_ExtractRatingNumerals]
GO

CREATE FUNCTION [dbo].[ufn_ExtractRatingNumerals](@Temp varchar(max))
RETURNS varchar(max)
AS
BEGIN

	DECLARE @Work varchar(max) = '', @Char varchar(1)
	DECLARE @Index int = 0
	DECLARE @FoundBegin bit = 0
	DECLARE @KeepValues as varchar(50) = '[0-9]'
	IF (@Temp LIKE '%(%)%') BEGIN

		WHILE(@Index < LEN(@Temp)) BEGIN

			 SET @Index = @Index + 1
			 SET @Char = SUBSTRING(@Temp, @Index, 1)
			 

			 IF ( @FoundBegin = 0) BEGIN

				 IF (@Char = '(') BEGIN
					SET @FoundBegin = 1

					IF (LEN(@Work) > 0) BEGIN
						SET @Work = @Work + ','
					END

					SET @Work = @Work + @Char
				 END
			
			END ELSE BEGIN

				IF (PATINDEX(@KeepValues, @Char) > 0)
					SET @Work = @Work + @Char

 				IF (@Char = ')') BEGIN
					SET @Work = @Work + @Char
					SET @FoundBegin = 0
				END
			END


		END

		SET @Work =  ',' + REPLACE(@Work, '()', ',') +  ',';
	END ELSE BEGIN

		SET @Work = '';
	END



    RETURN @Work
END
Go 

IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[ufn_GetEditionRange]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    DROP Function [dbo].[ufn_GetEditionRange]
GO

CREATE FUNCTION [dbo].[ufn_GetEditionRange]
(
   @EditionList varchar(500) 
)
RETURNS @Results table (
	StartDate date,
	EndDate date
)
as
BEGIN

	/*
	DECLARE @EditionList varchar(500) = ',201407,201410,201501,201504,'
	DECLARE @Results table (
		StartDate date,
		EndDate date)
	*/

	DECLARE @Work table (
		EditionDate date
	)



	INSERT INTO @Work 
	SELECT SUBSTRING(value, 1, 4) + '-' + SUBSTRING(value, 5, 2) + '-1'
	  FROM Tokenize(@EditionList, ',') 
	WHERE Value <> ''

	INSERT INTO @Results 
	SELECT MIN(EditionDate), MAX(EditionDate) FROM @Work

	RETURN
END
GO


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ufn_GetDuplicatePhoneList]'))
	DROP FUNCTION dbo.ufn_GetDuplicatePhoneList
GO
CREATE FUNCTION dbo.ufn_GetDuplicatePhoneList(@PhoneID int)
RETURNS varchar(max)
AS
BEGIN
    -- Build a comma-delimited list
    DECLARE @List varchar(max)

	SELECT @List = COALESCE(@List + ', ', '') + OtherEntity
	  FROM (SELECT prcse_FullName as OtherEntity
			  FROM vPRCompanyPhone a
				   INNER JOIN vPRCompanyPhone b ON a.phon_PhoneMatch = b.phon_PhoneMatch
				   INNER JOIN PRCompanySearch ON a.plink_RecordID = prcse_CompanyID
			 WHERE b.phon_PhoneID = @PhoneID
			   AND a.phon_PhoneID <> @PhoneID) T1
	ORDER BY OtherEntity       

	SELECT @List = COALESCE(@List + ', ', '') + OtherEntity
	  FROM (SELECT ISNULL(dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_MiddleName, NULL, pers_Suffix) + ' (' + CAST(pers_PersonID as varchar(25)) + ')', prcse_FullName) as OtherEntity
			  FROM vPRPersonPhone a
				   INNER JOIN vPRPersonPhone b ON a.phon_PhoneMatch = b.phon_PhoneMatch
				   INNER JOIN PRCompanySearch ON a.phon_CompanyID = prcse_CompanyID
				   INNER JOIN Person ON a.plink_RecordID = pers_PersonID
			 WHERE b.phon_PhoneID = @PhoneID
			   AND a.phon_PhoneID <> @PhoneID) T1
	ORDER BY OtherEntity  


	RETURN @List
END
Go


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_SearchByCompanyName]') 
            and OBJECTPROPERTY(id, N'IsTableFunction') = 1)
drop Function [dbo].[ufn_SearchByCompanyName]
GO

CREATE FUNCTION dbo.ufn_SearchByCompanyName(@CompanyName varchar(400))
RETURNS @tblResults TABLE (
    CompanyID int
)
as
BEGIN

	--DECLARE @CompanyName varchar(400) = 'Travant Solutions Inc.'
	--DECLARE @tblResults table (
	--	CompanyID int
	--)

	DECLARE @NameMatch varchar(400) = dbo.GetLowerAlpha(dbo.ufn_PrepareCompanyName(@CompanyName)) 

	DECLARE @Count int

	INSERT INTO @tblResults
	SELECT prcse_CompanyID
	  FROM PRCompanySearch WITH (NOLOCK)
	 WHERE (prcse_NameMatch =  @NameMatch
			OR ISNULL(prcse_LegalNameMatch, '') = @NameMatch
			OR ISNULL(prcse_CorrTradeStyleMatch, '') = @NameMatch)

	SET @Count = @@ROWCOUNT

	IF (@Count = 0) BEGIN
		INSERT INTO @tblResults
		SELECT pral_CompanyID
		  FROM PRCompanyAlias WITH (NOLOCK)
		 WHERE pral_AliasMatch = @NameMatch
		   --AND dbo.GetLowerAlpha(dbo.ufn_PrepareCompanyName(pral_Alias)) = @NameMatch

		SET @Count = @@ROWCOUNT
	END

	IF (@Count = 0) BEGIN
		INSERT INTO @tblResults
		SELECT prpa_CompanyID
		  FROM PRPACALicense WITH (NOLOCK)
		 WHERE prpa_Current = 'Y'
		   AND prpa_CompanyNameMatch = @NameMatch

		SET @Count = @@ROWCOUNT
	END

	--SELECT * FROM @tblResults
	RETURN
END
Go

IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[ufn_GetLocalSourceAccessList]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    DROP FUNCTION [dbo].[ufn_GetLocalSourceAccessList]
GO

CREATE Function ufn_GetLocalSourceAccessList(@WebUserID int, @ReturnType int)
RETURNS varchar(2000)
AS
BEGIN
    
    DECLARE @List varchar(2000)

	if (@ReturnType = 0) BEGIN
		 SELECT @List = COALESCE(@List + ', ', '') + prwuls_ServiceCode
		   FROM PRWebUserLocalSource WITH (NOLOCK)
		 WHERE prwuls_WebUserID= @WebUserID
	END ELSE BEGIN
		 SELECT @List = COALESCE(@List + ', ', '') + prod_name
		   FROM PRWebUserLocalSource WITH (NOLOCK) 
				INNER JOIN NewProduct WITH (NOLOCK) ON prod_code = prwuls_ServiceCode
		 WHERE prwuls_WebUserID= @WebUserID
	END

    RETURN @List
END
Go

IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[ufn_GetKYCPublicationList]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    DROP FUNCTION [dbo].[ufn_GetKYCPublicationList]
Go

CREATE Function ufn_GetKYCPublicationList(@CompanyID int, @KYCEdition varchar(100))
RETURNS varchar(2000)
AS
BEGIN
    
    DECLARE @List varchar(2000)

	SELECT @List = COALESCE(@List + ', ', '') + prkycc_PostName
	FROM PRAdCampaignHeader
		INNER JOIN PRAdCampaign WITH (NOLOCK) ON pradch_AdCampaignHeaderID = pradc_AdCampaignHeaderID
		LEFT OUTER JOIN PRKYCCommodity ON pradc_KYCCommodityID = prkycc_KYCCommodityID
	WHERE pradch_TypeCode = 'KYC'		
		AND pradc_AdCampaignType = 'PUB'
		AND pradc_CompanyID = @CompanyID
		AND pradc_KYCEdition = @KYCEdition
	ORDER BY prkycc_PostName

    RETURN @List
END
Go


IF EXISTS (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetRatingMetrics]') 
            and OBJECTPROPERTY(id, N'IsTableFunction') = 1)
	drop Function [dbo].[ufn_GetRatingMetrics]
GO

CREATE FUNCTION dbo.ufn_GetRatingMetrics
(
    @StartDate datetime,
	@EndDate datetime,
	@ReturnFormat varchar(10) = 'Report'
)
RETURNS @tblResults TABLE (
    [Year] int,
    ChangeType varchar(25),
    [Count] int
)
as
BEGIN



	Declare @Ratings Table
		(RatingID  int Primary Key,
		 BBID  int,
		[Date]  datetime,
		[Year]  int,
		[Month]  int,
		[Quarter]  int,
		[Name]  nvarchar(300),
		[CWE]  nvarchar(30),
		[Int]  nvarchar(30),
		[Pay]  nvarchar(30),
		[CWEWeight]  int,
		[IntWeight]  int,
		[PayWeight]  int,
		[RatingLine]  nvarchar(100),
	
		[Numerals] nvarchar(100),
		[Prev RatingID]  int,
		[Change Type] nvarchar(100),
		[Rule] int,
	
		[Num62]  nvarchar(5),
		[Num68]  nvarchar(5),
		[Num81]  nvarchar(5),
		[Num82]  nvarchar(5),
		[Num83]  nvarchar(5),
		[Num84]  nvarchar(5),
		[Num86]  nvarchar(5),
		[Num142]  nvarchar(5),
		[Num145]  nvarchar(5),
		[Num146]  nvarchar(5),
		[Num147]  nvarchar(5),
		[Num148]  nvarchar(5),
		[Num149]  nvarchar(5),
		[Num154]  nvarchar(5),

		[Analyst] nvarchar (10),
		[Region]  nvarchar (50)
		--,
		--[Pay Change] nvarchar(50),
		--[Int Change] nvarchar(50),
		--[CWE Change] nvarchar(50),
		--[Numeral Change] nvarchar(50)
		)

	--We're only interested in Ratings after our Start Date, so I identify the earliest rating set before or on our Start date.
	--Then, I use the earliest rating date per company to find all valid ratings.

	Declare @EarliestRatings table 	
		(CompanyID int
		, RatingDate datetime)

	INSERT INTO @EarliestRatings
		SELECT 
		prra_CompanyID
		, min(prra_Date)
	--	, case when @Startdate is null then min(prra_Date) else max(prra_Date) end
		FROM PRRating with (nolock)
	--	WHERE prra_Date <= (case when @Startdate is null then prra_Date else @StartDate end)
		GROUP BY prra_CompanyID



	--We're only interested in Rating assignments and removals, not interim or informational rating line changes.
	--We do a little song and dance here to find the eligible rating records, and rank them by company and date.
	--I use the rank column later to determine each rating record's previous rating.
	--This gets downright strange with the "OR" in the where clause of the subquery.  But, the first group of where conditions
	--pertains to rating removals.  The second group of where conditions return the rating assignment records we're interested in.

	Declare @ValidRatings Table 
		(RID int Primary Key, 
		CompID int, 
		RDate datetime, 
		Rnk int, 
		unique clustered (CompID, Rnk))

	Insert into @ValidRatings
	Select
		RID
		, prra_CompanyID
		, prra_Date
		, RANK() OVER (PARTITION BY prra_CompanyID ORDER BY prra_Date) --Yeah, I know this is weird.
	From
		(SELECT 
			max(prra_RatingID) as RID --This is weird too, but I only want one rating per day.
			, prra_CompanyID
			, prra_Date 
		FROM PRRating with (nolock)
		left outer join PRRatingNumeralAssigned on prra_RatingID = pran_RatingID
			and pran_RatingNumeralID in (82,83,	84, 86, 146,147,148,149)
		WHERE 
		--Company is Unrated
			((prra_CreditWorthID is null or prra_CreditWorthID = 9)
			and prra_PayRatingID is null
			and prra_IntegrityID is null
			and prra_RatingID not in
				(Select pran_RatingID
				from PRRatingNumeralAssigned 
				inner join PRRatingNumeral  on prrn_RatingNumeralID = pran_RatingNumeralID
					and prrn_Type != 'A')) --An unrated company cannot have any numerals, other than affiliations.
		OR
		--Company is Rated
			((prra_CreditWorthID is not null and prra_CreditWorthID not in (3, 4, 6, 7, 9))
				or prra_PayRatingID is not null
				or prra_IntegrityID is not null
				or pran_RatingNumeralID is not null)
		GROUP BY prra_CompanyID, prra_Date)TableA
	Inner Join @EarliestRatings on prra_CompanyID = CompanyID
		and prra_Date >= RatingDate

	--Select * from @ValidRatings
	--Inner Join @EarliestRatings on compID = CompanyID
	--order by compID,Rnk

	Insert into @Ratings
	SELECT 
		RatingID  =  prra_RatingID,
		BBID  =  prra_CompanyID,
		[Date]  =  prra_Date,
		[Year]  =  year(prra_Date),
		[Month]  =  month(prra_Date),
		[Quarter]  =  datepart(qq, prra_Date),
		[Name]  =  v.comp_Name ,
		[CWE]  =  isnull(prcw_Name,''),
		[Int]  =  isnull(prin_Name,''),
		[Pay]  =  isnull(prpy_Name,''),
		[CWEWeight]  =  CASE 
			when prcw_Name like '(%' then ''
			when prcw_Name is null then ''
			else dbo.getloweralpha(left(prcw_Name,len(prcw_Name)-1))
			end,
		[IntWeight]  =  isnull(prra_IntegrityID,''),
		[PayWeight]  =  isnull(prpy_Weight,''),
		[RatingLine]  =  prra_RatingLine,
		[Numerals] = '',
		[Prev RatingID] = p.RID,
		[Change Type] = '', 
		[Rule] = 0,
		--I haven't tried joining to the rating numeral assigned table to see if there's a performance
		--improvement vs. this case stuff.
		[Num62]  = CASE when prra_RatingLine like '%(62)%' then 'Y' else '' end, 
		[Num68]  = CASE when prra_RatingLine like '%(68)%' then 'Y' else '' end,
		[Num81]  = CASE when prra_RatingLine like '%(81)%' then 'Y' else '' end,
		[Num82]  = CASE when prra_RatingLine like '%(82)%' then 'Y' else '' end,
		[Num83]  = CASE when prra_RatingLine like '%(83)%' then 'Y' else '' end,
		[Num84]  = CASE when prra_RatingLine like '%(84)%' then 'Y' else '' end,
		[Num86]  = CASE when prra_RatingLine like '%(86)%' then 'Y' else '' end,
		[Num142]  = CASE when prra_RatingLine like '%(142)%' then 'Y' else '' end,
		[Num145]  = CASE when prra_RatingLine like '%(145)%' then 'Y' else '' end,
		[Num146]  = CASE when prra_RatingLine like '%(146)%' then 'Y' else '' end,
		[Num147]  = CASE when prra_RatingLine like '%(147)%' then 'Y' else '' end,
		[Num148]  = CASE when prra_RatingLine like '%(148)%' then 'Y' else '' end,
		[Num149]  = CASE when prra_RatingLine like '%(149)%' then 'Y' else '' end,
		[Num154]  = CASE when prra_RatingLine like '%(154)%' then 'Y' else '' end,
		[Analyst] = rtrim(user_logon),
		[Region] = null
	FROM vPRCompanyRating v with (nolock)
	inner join Company with (nolock) on comp_CompanyID = prra_CompanyID
		and comp_PRIndustryType != 'L'
		and comp_CompanyID != 100001

	Inner Join @ValidRatings c on c.RID = prra_RatingID --for current rating record.
	Left outer join @ValidRatings p on p.CompID = c.CompID --for previous rating record.
		and p.Rnk = (c.Rnk - 1)
	Left outer join Users with (nolock) on user_UserID = prra_CreatedBy
	ORDER BY BBID, [Date]

	Update @Ratings
	Set Numerals = 'Y'
	where 
	[Num62]  = 'Y' OR
	[Num68]  = 'Y' OR
	[Num142]  = 'Y' OR
	[Num145]  = 'Y' OR
	[Num154]  = 'Y' OR
	[Num82]  = 'Y' OR
	[Num83]  = 'Y' OR
	[Num84]  = 'Y' OR
	[Num86]  = 'Y' OR
	[Num146]  = 'Y' OR
	[Num147]  = 'Y' OR
	[Num148]  = 'Y' OR
	[Num149]  = 'Y' OR
	[Num81]  = 'Y'



	-- 1.  Flag first ratings: no prev rating

	Update @Ratings
	Set [Change Type] = 'Established'
		,[Rule] = 1
	where [Prev RatingID] is null


	-- Special Rule for (86) to (83)
	Update @Ratings 
	Set [Change Type] = 'Upgrade'
		,[Rule] = 2
	where 
		[Change Type] = ''
		AND RatingID in 
			(Select cur.RatingID
			From @Ratings cur
			inner join @Ratings prev on prev.RatingID = cur.[Prev RatingID]
			where 
				cur.Num83 = 'Y' and cur.Num86 = ''
				and prev.Num86 = 'Y')

	-- Special Rule for (149) to (81)
	Update @Ratings 
	Set [Change Type] = 'Upgrade'
		,[Rule] = 3
	where 
		[Change Type] = ''
		AND RatingID in 
			(Select cur.RatingID
			From @Ratings cur
			inner join @Ratings prev on prev.RatingID = cur.[Prev RatingID]
			where 
				cur.Num81 = 'Y' and cur.Num149 = ''
				and prev.Num149 = 'Y')

	--Special Rule for F to (149) or (81)
	Update @Ratings 
	Set [Change Type] = 'Upgrade'
		,[Rule] = 4
	where 
		[Change Type] = ''
		AND RatingID in 
			(Select cur.RatingID
			From @Ratings cur
			inner join @Ratings prev on prev.RatingID = cur.[Prev RatingID]
			where 
				prev.PayWeight = 1 and 
				(cur.Num149 = 'Y' or cur.Num81 = 'Y'))
			
	--Special Rule for (154) X F
	Update @Ratings 
	Set [Change Type] = 'Downgrade'
		,[Rule] = 5
	where 
		[Change Type] = ''
		AND Num154 = 'Y' 
		AND IntWeight = 1
		and PayWeight = 1

	--Flag Unchanged:  No change in CWE, Pay, Int, or Numeral status
	Update @Ratings 
	Set [Change Type] = 'Unchanged'
		,[Rule] = 6
	where 
		[Change Type] = ''
		AND RatingID in 
			(Select cur.RatingID
			From @Ratings cur
			inner join @Ratings prev on prev.RatingID = cur.[Prev RatingID]
			where 
				cur.Numerals = prev.Numerals 
				and cur.CWEWeight = prev.CWEWeight
				and cur.IntWeight = prev.IntWeight
				and cur.PayWeight = prev.PayWeight)


	-- Flag removed ratings: No CWE, Pay, Int, or Numerals

	Update @Ratings
	Set [Change Type] = 'Removed'
		,[Rule] = 7
	where 
		[Change Type] = ''
		and CWEWeight = 0
		and IntWeight = 0
		and PayWeight = 0
		and Numerals = ''

	--Re-established Rating:  CWE, Pay, or Int assigned without numerals, where prev rating was "removed".
	Update @Ratings
	Set [Change Type] = 'Established'
		,[Rule] = 8
	where 
		[Change Type] = ''
		and Numerals = '' 
		and [Prev RatingID] in (Select RatingID from @Ratings where [Change Type] = 'Removed')
		and(CWEWeight > 0
		or IntWeight > 0
		or PayWeight > 0)

	-- Numeral Downgrade:  Prev rating has no numerals, but numerals are now assigned

	Update @Ratings
	Set [Change Type] = 'Downgrade'	
		,[Rule] = 9
	where 
		[Change Type] = ''
		and Numerals = 'Y'
		and [Prev RatingID] in (Select RatingID from @Ratings where [Numerals] = '')


	-- Numeral Upgrade:  Prev Rating has numerals, current rating does not
	Update @Ratings
	Set [Change Type] = 'Upgrade'
		,[Rule] = 10
	where 
		[Change Type] = ''
		and Numerals = ''
		and [Prev RatingID] in (Select RatingID from @Ratings where [Numerals] = 'Y')


	-- Downgrade:  CWE, Int, or Pay drop
	Update @Ratings 
	Set [Change Type] = 'Downgrade'
		,[Rule] = 11
	where 
		[Change Type] = ''
		AND RatingID in 
			(Select cur.RatingID
			From @Ratings cur
			inner join @Ratings prev on prev.RatingID = cur.[Prev RatingID]
			where 
				cur.CWEWeight < prev.CWEWeight
				or cur.IntWeight < prev.IntWeight
				or cur.PayWeight < prev.PayWeight)


	-- Upgrade:  CWE, Int, or Pay Increase
	Update @Ratings 
	Set [Change Type] = 'Upgrade'
		,[Rule] = 12
	where 
		[Change Type] = ''
		AND RatingID in 
			(Select cur.RatingID
			From @Ratings cur
			inner join @Ratings prev on prev.RatingID = cur.[Prev RatingID]
			where 
				cur.CWEWeight > prev.CWEWeight
				or cur.IntWeight > prev.IntWeight
				or cur.PayWeight > prev.PayWeight)

	IF (@ReturnFormat = 'Report') BEGIN

		INSERT INTO @tblResults
		SELECT [Year], [Change Type], COUNT(1) as CNT
				  FROM @Ratings
				 WHERE date BETWEEN @Startdate AND DATEADD(minute, 1339, @EndDate)
				   AND [change type] != 'Unchanged'
				GROUP BY [Year], [Change Type]
	END ELSE BEGIN
	
		INSERT INTO @tblResults
		SELECT 0, [Change Type], COUNT(1) as CNT
				  FROM @Ratings
				 WHERE date BETWEEN @Startdate AND DATEADD(minute, 1339, @EndDate)
				   AND [change type] != 'Unchanged'
				GROUP BY [Change Type]
	END


	RETURN
END
Go


IF EXISTS (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetIndustryMetrics]') 
            and OBJECTPROPERTY(id, N'IsTableFunction') = 1)
	drop Function [dbo].[ufn_GetIndustryMetrics]
GO

CREATE FUNCTION dbo.ufn_GetIndustryMetrics
(
    @StartDate datetime,
	@EndDate datetime
)
RETURNS @tblResults TABLE (
    Metric varchar(25),
    [Count] int
)
as
BEGIN

	INSERT INTO @tblResults
	SELECT 'MeritoriousClaims', COUNT(1)
	  FROM PRSSFile m WITH (NOLOCK)
		   INNER JOIN Company WITH (NOLOCK) ON comp_CompanyID = prss_ClaimantCompanyId
	  WHERE comp_PRIndustryType <> 'L'
	   AND prss_MeritoriousDate BETWEEN @StartDate AND @EndDate
	   AND prss_Meritorious = 'Y'
	   AND prss_Type = 'C'
	   AND prss_Status = 'C'


	INSERT INTO @tblResults
	SELECT 'Bankruptcy' as Metric, 
	 COUNT(*) FROM 
                (
	                SELECT comp_CompanyID AS BBID
                    FROM Company WITH (NOLOCK)
                        INNER JOIN PRRating WITH (NOLOCK) ON comp_CompanyID = prra_CompanyID
                        INNER JOIN PRRatingNumeralAssigned WITH (NOLOCK) ON prra_RatingID = pran_RatingID
	                WHERE pran_RatingNumeralID IN (17, 18, 19, 84)
		                AND Comp_Deleted IS NULL
		                AND comp_PRIndustryType <> 'L'
		                AND prra_Date BETWEEN @StartDate AND @EndDate
		                GROUP BY comp_CompanyID
                ) T1

	INSERT INTO @tblResults
    SELECT ChangeType as Metric, [Count]
      FROM ufn_GetRatingMetrics(@StartDate, @EndDate, 'BBOS') WHERE [ChangeType] IN ('Upgrade', 'Downgrade')

	INSERT INTO @tblResults
	SELECT 'NewlyListed', COUNT(1)
	  FROM Company WITH (NOLOCK)
	 WHERE comp_PRIndustryType <> 'L'
	   AND comp_PRType = 'H' 
	   AND comp_PRListedDate BETWEEN @StartDate AND @EndDate
	   AND comp_PRListingStatus = 'L'
	   AND comp_PRLocalSource IS NULL

	RETURN

END 
Go

IF EXISTS (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetIndustryMetrics_Lumber]') 
            and OBJECTPROPERTY(id, N'IsTableFunction') = 1)
	drop Function [dbo].[ufn_GetIndustryMetrics_Lumber]
GO

CREATE FUNCTION dbo.ufn_GetIndustryMetrics_Lumber
(
    @StartDate datetime,
	@EndDate datetime
)
RETURNS @tblResults TABLE (
    Metric varchar(25),
    [Count] int
)
as
BEGIN
	INSERT INTO @tblResults
	SELECT 'Bankruptcy' as Metric, 
		   COUNT(*) FROM
                (
	                SELECT comp_CompanyID AS BBID
                    FROM Company WITH (NOLOCK)
                        INNER JOIN PRRating WITH (NOLOCK) ON comp_CompanyID = prra_CompanyID
                        INNER JOIN PRRatingNumeralAssigned WITH (NOLOCK) ON prra_RatingID = pran_RatingID
	                WHERE pran_RatingNumeralID IN (17, 18, 19, 84)
		                AND Comp_Deleted IS NULL
		                AND comp_PRIndustryType = 'L'
		                AND prra_Date BETWEEN @StartDate AND @EndDate
		                GROUP BY comp_CompanyID
                ) T1
	
	INSERT INTO @tblResults
	SELECT 'NewlyListed', COUNT(1)
	  FROM Company WITH (NOLOCK)
	 WHERE comp_PRIndustryType = 'L'
	   AND comp_PRType = 'H' 
	   AND comp_PRListedDate BETWEEN @StartDate AND @EndDate
	   AND comp_PRListingStatus = 'L'
	   AND comp_PRLocalSource IS NULL
	
	RETURN
END 
Go

--
-- 
--

IF EXISTS (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetCSGValueForList]') )
	drop Function [dbo].[ufn_GetCSGValueForList]
GO

CREATE Function ufn_GetCSGValueForList(@CompanyID int, @TypeCode varchar(10))
RETURNS varchar(max)
AS
BEGIN
    
    DECLARE @List varchar(max)

    SELECT @List = COALESCE(@List + ', ', '') + prcsgd_Value
      FROM PRCSGData WITH (NOLOCK) 
	       INNER JOIN PRCSG WITH (NOLOCK) ON prcsgd_CSGID = prcsg_CSGID
     WHERE prcsg_CompanyID = @CompanyID
       AND prcsgd_TypeCode = @TypeCode
    ORDER BY prcsgd_Value
 
    RETURN @List
END
Go


IF EXISTS (SELECT 'x' from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetWordPressPostDetails]') )
	DROP FUNCTION [dbo].[ufn_GetWordPressPostDetails]
GO

CREATE FUNCTION [dbo].[ufn_GetWordPressPostDetails]
(
    @PostID int
)
RETURNS @MyTable TABLE (
	PostID int,
	StandFirst varchar(5000),
	Author varchar(1000),
	AuthorAbout varchar(5000),
	BlueprintEdition varchar(1000),
	ThumbnailPostID int,
	ThumbnailImg varchar(5000),
	Abstract varchar(1000),
    CategoryCode varchar(1000))
AS
BEGIN
	DECLARE @Content varchar(1000)

	INSERT INTO @MyTable (PostID, StandFirst, Author, AuthorAbout, BlueprintEdition, ThumbnailPostID)
    SELECT @PostID, standfirst, author, [about-author], blueprintEdition, _thumbnail_id
	FROM
        (SELECT meta_key, meta_value FROM WordPress.dbo.wp_postmeta WITH (NOLOCK) WHERE post_id=@PostID) d
	PIVOT
	    (MAX (meta_value) FOR meta_key in (standfirst, author, [about-author], blueprintEdition, _thumbnail_id)) piv;

    UPDATE @MyTable
	SET ThumbnailImg = guid
	FROM WordPress.dbo.wp_posts WITH (NOLOCK)
	WHERE ISNULL(ThumbnailPostID, 0) = id

	SELECT @Content = post_content
	FROM WordPress.dbo.wp_posts WITH (NOLOCK)
	WHERE ID = @PostID

	DECLARE @Pos int = 0
	DECLARE @Pos2 int = 0
	DECLARE @Count int = 0
	WHILE (@Pos < 100) BEGIN
		SET @Pos = CHARINDEX('.', @Content, @Pos+1)
		IF (@Pos > 100) BEGIN
			SET @Pos2 = CHARINDEX('?', @Content, @Pos+1)
			IF (@Pos2 > 100 AND @Pos2 < @Pos) BEGIN
				SET @Pos = @Pos2
			END
		END
		SET @Count = @Count + 1
		IF (@Count >= 5) BEGIN
			SET @Pos = 100
		END
	END

	UPDATE @MyTable
	  SET Abstract = SUBSTRING(@Content, 1, @Pos + 1) + '</p>'

	UPDATE @MyTable
      SET CategoryCode = (SELECT meta_value FROM WordPress.dbo.wp_postmeta WITH (NOLOCK) WHERE post_id = @PostID AND meta_key = 'prpbar_CategoryCode')

	RETURN
END

GO

IF EXISTS (SELECT 'x' from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetWordPressPostDetails2]') )
	DROP FUNCTION [dbo].[ufn_GetWordPressPostDetails2]
GO

CREATE FUNCTION [dbo].[ufn_GetWordPressPostDetails2]
(
  @PostID int,
	@IndustryType varchar(5) = 'P'
)
RETURNS @MyTable TABLE (
	PostID int,
	StandFirst varchar(5000),
	Author varchar(1000),
	AuthorAbout varchar(5000),
	BlueprintEdition varchar(1000),
	ThumbnailPostID int,
	ThumbnailImg varchar(5000),
	Abstract varchar(1000),
  CategoryCode varchar(1000),
	[Date] varchar(1000))
AS
BEGIN
	DECLARE @Content varchar(1000)

	IF @IndustryType = 'L'
	BEGIN
		INSERT INTO @MyTable (PostID, StandFirst, Author, AuthorAbout, BlueprintEdition, ThumbnailPostID,[Date])
			SELECT @PostID, standfirst, author, [about-author], blueprintEdition, _thumbnail_id, [date]
				FROM
				(SELECT meta_key, meta_value FROM WordPressLumber.dbo.wp_postmeta WITH (NOLOCK) WHERE post_id=@PostID) d
			 PIVOT
				(MAX (meta_value) FOR meta_key in (standfirst, author, [about-author], blueprintEdition, _thumbnail_id, [date])) piv;

		UPDATE @MyTable
			SET ThumbnailImg = guid
			FROM WordPressLumber.dbo.wp_posts WITH (NOLOCK)
			WHERE ISNULL(ThumbnailPostID, 0) = id
		 
		 SELECT @Content = post_content
			FROM WordPressLumber.dbo.wp_posts WITH (NOLOCK)
		 WHERE ID = @PostID
	END
	ELSE
	BEGIN
		INSERT INTO @MyTable (PostID, StandFirst, Author, AuthorAbout, BlueprintEdition, ThumbnailPostID,[Date])
			SELECT @PostID, standfirst, author, [about-author], blueprintEdition, _thumbnail_id, [date]
				FROM
				(SELECT meta_key, meta_value FROM WordPressProduce.dbo.wp_postmeta WITH (NOLOCK) WHERE post_id=@PostID) d
			 PIVOT
				(MAX (meta_value) FOR meta_key in (standfirst, author, [about-author], blueprintEdition, _thumbnail_id, [date])) piv;

		UPDATE @MyTable
			SET ThumbnailImg = guid
			FROM WordPressProduce.dbo.wp_posts WITH (NOLOCK)
		 WHERE ISNULL(ThumbnailPostID, 0) = id

		 SELECT @Content = post_content
			FROM WordPressProduce.dbo.wp_posts WITH (NOLOCK)
		 WHERE ID = @PostID
	END

	 DECLARE @Pos int = 0
	 DECLARE @Pos2 int = 0
	 DECLARE @Count int = 0
	 WHILE (@Pos < 100) BEGIN
		SET @Pos = CHARINDEX('.', @Content, @Pos+1)
		IF (@Pos > 100) BEGIN
			SET @Pos2 = CHARINDEX('?', @Content, @Pos+1)
			IF (@Pos2 > 100 AND @Pos2 < @Pos) BEGIN
				SET @Pos = @Pos2
			END
		END
		SET @Count = @Count + 1
		IF (@Count >= 5) BEGIN
			SET @Pos = 100
		END
	END
	UPDATE @MyTable
	  SET Abstract = SUBSTRING(@Content, 1, @Pos + 1) + '</p>'

	IF @IndustryType = 'L'
	BEGIN
		UPDATE @MyTable
			SET CategoryCode = (SELECT meta_value FROM WordPressLumber.dbo.wp_postmeta WITH (NOLOCK) WHERE post_id = @PostID AND meta_key = 'prpbar_CategoryCode')
	END
	ELSE
	BEGIN
		UPDATE @MyTable
			SET CategoryCode = (SELECT meta_value FROM WordPressProduce.dbo.wp_postmeta WITH (NOLOCK) WHERE post_id = @PostID AND meta_key = 'prpbar_CategoryCode')
	END

	RETURN
END

GO

IF EXISTS (SELECT 'x' from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetWordPressPostDetails3]') )
	DROP FUNCTION [dbo].[ufn_GetWordPressPostDetails3]
GO

CREATE FUNCTION [dbo].[ufn_GetWordPressPostDetails3]
(
	@PostID int,
	@IndustryType varchar(5) = 'P'
)
RETURNS @MyTable TABLE (
	PostID int,
	StandFirst varchar(5000),
	Author varchar(1000),
	AuthorAbout varchar(5000),
	BlueprintEdition varchar(1000),
	ThumbnailPostID int,
	ThumbnailImg varchar(5000),
	Abstract varchar(1000),
  CategoryCode varchar(1000),
	[Date] varchar(1000),
	Category varchar(1000))
AS
BEGIN
	DECLARE @Content varchar(1000)
	DECLARE @Category varchar(1000)
 	IF @IndustryType = 'L'
	BEGIN
		INSERT INTO @MyTable (PostID, StandFirst, Author, AuthorAbout, BlueprintEdition, ThumbnailPostID, [Date])
			SELECT @PostID, standfirst, author, [about-author], blueprintEdition, _thumbnail_id, [date]
				FROM
				(SELECT meta_key, meta_value FROM WordPressLumber.dbo.wp_postmeta WITH (NOLOCK) WHERE post_id=@PostID) d
			 PIVOT
				(MAX (meta_value) FOR meta_key in (standfirst, author, [about-author], blueprintEdition, _thumbnail_id, [date])) piv;
		 UPDATE @MyTable
			SET ThumbnailImg = (
				SELECT TOP 1 meta2.meta_value
				FROM WordPressLumber.dbo.wp_postmeta meta1
					INNER JOIN WordPressLumber.dbo.wp_postmeta meta2 ON meta2.meta_key = '_wp_attached_file' AND meta2.post_id = meta1.meta_value
				WHERE meta1.meta_key = '_thumbnail_id' AND meta1.post_id = @PostID
				ORDER BY meta2.meta_id DESC
			)
 		 
		 SELECT @Content = post_content, 
                @Category = t.name
			FROM WordPressLumber.dbo.wp_posts p WITH (NOLOCK)
				LEFT JOIN WordPressLumber.dbo.wp_term_relationships rel ON rel.object_id = p.ID
				LEFT JOIN WordPressLumber.dbo.wp_term_taxonomy tax ON tax.term_taxonomy_id = rel.term_taxonomy_id
				LEFT JOIN WordPressLumber.dbo.wp_terms t ON t.term_id = tax.term_id
		 WHERE ID = @PostID
       AND tax.taxonomy = 'Category'
	END
	ELSE
	BEGIN
		INSERT INTO @MyTable (PostID, StandFirst, Author, AuthorAbout, BlueprintEdition, ThumbnailPostID, [Date])
			SELECT @PostID, standfirst, author, [about-author], blueprintEdition, _thumbnail_id, [date]
				FROM

				(SELECT meta_key, meta_value FROM WordPressProduce.dbo.wp_PostMeta WITH (NOLOCK) WHERE post_id=@PostID) d
				PIVOT
				(MAX (meta_value) FOR meta_key in (standfirst, author, [about-author], blueprintEdition, _thumbnail_id, [date])) piv;
 		
		 	UPDATE @MyTable
				SET ThumbnailImg = (
					SELECT TOP 1 meta2.meta_value
					FROM WordPressProduce.dbo.wp_PostMeta meta1
						INNER JOIN WordPressProduce.dbo.wp_PostMeta meta2 ON meta2.meta_key = '_wp_attached_file' AND meta2.post_id = meta1.meta_value
					WHERE meta1.meta_key = '_thumbnail_id' AND meta1.post_id = @PostID
					ORDER BY meta2.meta_id DESC
				)

 		 SELECT @Content = post_content, 
                @Category = t.name
			FROM WordPressProduce.dbo.wp_posts p WITH (NOLOCK)
				LEFT JOIN WordPressProduce.dbo.wp_term_relationships rel ON rel.object_id = p.ID
				LEFT JOIN WordPressProduce.dbo.wp_term_taxonomy tax ON tax.term_taxonomy_id = rel.term_taxonomy_id
				LEFT JOIN WordPressProduce.dbo.wp_terms t ON t.term_id = tax.term_id
		 WHERE ID = @PostID
         AND tax.taxonomy = 'Category'
	END
 	 DECLARE @Pos int = 0
	 DECLARE @Pos2 int = 0
	 DECLARE @Count int = 0
	 WHILE (@Pos < 100) BEGIN
		SET @Pos = CHARINDEX('.', @Content, @Pos+1)
		IF (@Pos > 100) BEGIN
			SET @Pos2 = CHARINDEX('?', @Content, @Pos+1)
			IF (@Pos2 > 100 AND @Pos2 < @Pos) BEGIN
				SET @Pos = @Pos2
			END
		END
		SET @Count = @Count + 1
		IF (@Count >= 5) BEGIN
			SET @Pos = 100
		END
	END
 	UPDATE @MyTable
	  SET Abstract = SUBSTRING(@Content, 1, @Pos + 1) + '</p>', 
		  Category = REPLACE(@Category, CHAR(63), '')

 	IF @IndustryType = 'L'
	BEGIN
		UPDATE @MyTable
			SET CategoryCode = (SELECT meta_value FROM WordPressLumber.dbo.wp_postmeta WITH (NOLOCK) WHERE post_id = @PostID AND meta_key = 'prpbar_CategoryCode')
	END
	ELSE
	BEGIN
		UPDATE @MyTable
			SET CategoryCode = (SELECT meta_value FROM WordPressProduce.dbo.wp_PostMeta WITH (NOLOCK) WHERE post_id = @PostID AND meta_key = 'prpbar_CategoryCode')
	END
 	RETURN
END
GO

IF EXISTS (SELECT 'x' from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetWordPressPostDetails4]') )
	DROP FUNCTION [dbo].[ufn_GetWordPressPostDetails4]
GO

CREATE FUNCTION [dbo].[ufn_GetWordPressPostDetails4]
(
	@PostID int,
	@IndustryType varchar(5) = 'P'
)
RETURNS @MyTable TABLE (
	PostID int,
	StandFirst varchar(5000),
	Author varchar(1000),
	AuthorAbout varchar(5000),
	BlueprintEdition varchar(1000),
	ThumbnailPostID int,
	ThumbnailImg varchar(5000),
	Abstract varchar(1000),
	CategoryCode varchar(1000),
	[Date] varchar(1000),
	Category varchar(1000),
	KYCThumbnailImage varchar(5000))
AS
BEGIN
	DECLARE @Content varchar(1000)
	DECLARE @Category varchar(1000)
 	IF @IndustryType = 'L'
	BEGIN
		INSERT INTO @MyTable (PostID, StandFirst, Author, AuthorAbout, BlueprintEdition, ThumbnailPostID, [Date])
			SELECT @PostID, standfirst, author, [about-author], blueprintEdition, _thumbnail_id, [date]
				FROM
				(SELECT meta_key, meta_value FROM WordPressLumber.dbo.wp_postmeta WITH (NOLOCK) WHERE post_id=@PostID) d
			 PIVOT
				(MAX (meta_value) FOR meta_key in (standfirst, author, [about-author], blueprintEdition, _thumbnail_id, [date])) piv;
		 UPDATE @MyTable
			SET ThumbnailImg = (
				SELECT TOP 1 meta2.meta_value
				FROM WordPressLumber.dbo.wp_postmeta meta1
					INNER JOIN WordPressLumber.dbo.wp_postmeta meta2 ON meta2.meta_key = '_wp_attached_file' AND meta2.post_id = meta1.meta_value
				WHERE meta1.meta_key = '_thumbnail_id' AND meta1.post_id = @PostID
				ORDER BY meta2.meta_id DESC
			)
 		 
		 SELECT @Content = post_content, 
                @Category = t.name
			FROM WordPressLumber.dbo.wp_posts p WITH (NOLOCK)
				LEFT JOIN WordPressLumber.dbo.wp_term_relationships rel ON rel.object_id = p.ID
				LEFT JOIN WordPressLumber.dbo.wp_term_taxonomy tax ON tax.term_taxonomy_id = rel.term_taxonomy_id
				LEFT JOIN WordPressLumber.dbo.wp_terms t ON t.term_id = tax.term_id
		 WHERE ID = @PostID
       AND tax.taxonomy = 'Category'
	END
	ELSE
	BEGIN
		INSERT INTO @MyTable (PostID, StandFirst, Author, AuthorAbout, BlueprintEdition, ThumbnailPostID, [Date], KYCThumbnailImage)
			SELECT @PostID, standfirst, author, [about-author], blueprintEdition, _thumbnail_id, [date], [kyc_thumbnail_image]
				FROM

				(SELECT meta_key, meta_value FROM WordPressProduce.dbo.wp_postmeta WITH (NOLOCK) WHERE post_id=@PostID) d
				PIVOT
				(MAX (meta_value) FOR meta_key in (standfirst, author, [about-author], blueprintEdition, _thumbnail_id, [date], [kyc_thumbnail_image])) piv;
 		
		 	UPDATE @MyTable
				SET ThumbnailImg = (
					SELECT TOP 1 meta2.meta_value
					FROM WordPressProduce.dbo.wp_postmeta meta1
						INNER JOIN WordPressProduce.dbo.wp_postmeta meta2 ON meta2.meta_key = '_wp_attached_file' AND meta2.post_id = meta1.meta_value
					WHERE meta1.meta_key = '_thumbnail_id' AND meta1.post_id = @PostID
					ORDER BY meta2.meta_id DESC
				)

 		 SELECT @Content = post_content, 
                @Category = t.name
			FROM WordPressProduce.dbo.wp_posts p WITH (NOLOCK)
				LEFT JOIN WordPressProduce.dbo.wp_term_relationships rel ON rel.object_id = p.ID
				LEFT JOIN WordPressProduce.dbo.wp_term_taxonomy tax ON tax.term_taxonomy_id = rel.term_taxonomy_id
				LEFT JOIN WordPressProduce.dbo.wp_terms t ON t.term_id = tax.term_id
		 WHERE ID = @PostID
         AND tax.taxonomy = 'Category'
	END
 	 DECLARE @Pos int = 0
	 DECLARE @Pos2 int = 0
	 DECLARE @Count int = 0
	 WHILE (@Pos < 100) BEGIN
		SET @Pos = CHARINDEX('.', @Content, @Pos+1)
		IF (@Pos > 100) BEGIN
			SET @Pos2 = CHARINDEX('?', @Content, @Pos+1)
			IF (@Pos2 > 100 AND @Pos2 < @Pos) BEGIN
				SET @Pos = @Pos2
			END
		END
		SET @Count = @Count + 1
		IF (@Count >= 5) BEGIN
			SET @Pos = 100
		END
	END
 	UPDATE @MyTable
	  SET Abstract = SUBSTRING(@Content, 1, @Pos + 1) + '</p>', 
		  Category = REPLACE(@Category, CHAR(63), '')

 	IF @IndustryType = 'L'
	BEGIN
		UPDATE @MyTable
			SET CategoryCode = (SELECT meta_value FROM WordPressLumber.dbo.wp_postmeta WITH (NOLOCK) WHERE post_id = @PostID AND meta_key = 'prpbar_CategoryCode')
	END
	ELSE
	BEGIN
		UPDATE @MyTable
			SET CategoryCode = (SELECT meta_value FROM WordPressProduce.dbo.wp_postmeta WITH (NOLOCK) WHERE post_id = @PostID AND meta_key = 'prpbar_CategoryCode')
	END
 	RETURN
END
GO

IF EXISTS (SELECT 'x' from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetWordPressBluePrintsEdition]') )
	DROP FUNCTION [dbo].[ufn_GetWordPressBluePrintsEdition]
GO

CREATE FUNCTION dbo.ufn_GetWordPressBluePrintsEdition
(
    @PostID int
)
RETURNS varchar(100)
BEGIN
	DECLARE @Work varchar(100) --'a:1:{i:0;a:1:{s:4:"date";s:12:"October 2013";}}'
	DECLARE @Index int

	SELECT @Work = meta_value FROM WordPressProduce.dbo.wp_PostMeta WHERE meta_key LIKE  N'blueprintEdition' AND post_id = @PostID

	SET @Work = REPLACE(@Work, 'a:1:{i:0;a:1:{s:4:"date";s:', '')
	SET @Index = CHARINDEX('"', @Work) + 1
	SET @Work = SUBSTRING(@Work, @Index, LEN(@Work) - @Index)
	SET @Index = CHARINDEX('"', @Work) - 1
	SET @Work = SUBSTRING(@Work, 1, @Index)

	--SELECT @Work    
	RETURN @Work
END
Go

IF EXISTS (SELECT 'x' from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetWordPressCategories]') )
	DROP FUNCTION [dbo].ufn_GetWordPressCategories
GO

CREATE FUNCTION dbo.ufn_GetWordPressCategories
(
	@PostID int,
	@IndustryType varchar(5) = 'P'
)
RETURNS varchar(1000)
BEGIN
	DECLARE @Categories varchar(5000)

	IF @IndustryType = 'L'
	BEGIN
		SELECT 
			@Categories = COALESCE(@Categories + ', ', '') + t.name
		FROM WordPressLumber.dbo.wp_posts p WITH (NOLOCK)
			LEFT JOIN WordPressLumber.dbo.wp_term_relationships rel ON rel.object_id = p.ID
			LEFT JOIN WordPressLumber.dbo.wp_term_taxonomy tax ON tax.term_taxonomy_id = rel.term_taxonomy_id
			LEFT JOIN WordPressLumber.dbo.wp_terms t ON t.term_id = tax.term_id
		WHERE ID = @PostID
			AND tax.taxonomy = 'Category'
	END
	ELSE
	BEGIN
		SELECT 
			@Categories = COALESCE(@Categories + ', ', '') + CASE WHEN (t.Name = 'Produce Blueprints' AND dbo.ufn_GetWordPressBluePrintsEdition(@PostID) IS NOT NULL AND dbo.ufn_GetWordPressBluePrintsEdition(@PostID) <> '') THEN 'Produce Blueprints ' + dbo.ufn_GetWordPressBluePrintsEdition(@PostID) + ' Edition' ELSE t.name END
		FROM WordPressProduce.dbo.wp_posts p WITH (NOLOCK)
			LEFT JOIN WordPressProduce.dbo.wp_term_relationships rel ON rel.object_id = p.ID
			LEFT JOIN WordPressProduce.dbo.wp_term_taxonomy tax ON tax.term_taxonomy_id = rel.term_taxonomy_id
			LEFT JOIN WordPressProduce.dbo.wp_terms t ON t.term_id = tax.term_id
		WHERE ID = @PostID
			AND tax.taxonomy = 'Category'
	END

	--SELECT @Categories
	RETURN @Categories
END
Go

IF EXISTS (SELECT 'x' from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetWordPressCategories2]') )
	DROP FUNCTION [dbo].ufn_GetWordPressCategories2
GO

CREATE FUNCTION dbo.ufn_GetWordPressCategories2
(
	@PostID int,
	@IndustryType varchar(5) = 'P'
)
RETURNS varchar(1000)
BEGIN
	DECLARE @Categories varchar(5000)

	IF @IndustryType = 'L'
	BEGIN
		SELECT 
			@Categories = COALESCE(@Categories + ', ', '') + t.name
		FROM WordPressLumber.dbo.wp_posts p WITH (NOLOCK)
			LEFT JOIN WordPressLumber.dbo.wp_term_relationships rel ON rel.object_id = p.ID
			LEFT JOIN WordPressLumber.dbo.wp_term_taxonomy tax ON tax.term_taxonomy_id = rel.term_taxonomy_id
			LEFT JOIN WordPressLumber.dbo.wp_terms t ON t.term_id = tax.term_id
		WHERE ID = @PostID
			AND tax.taxonomy = 'Category'
	END
	ELSE
	BEGIN
		SELECT 
			@Categories = COALESCE(@Categories + ', ', '') + CASE WHEN (t.Name = 'Produce Blueprints' AND dbo.ufn_GetWordPressBluePrintsEdition(@PostID) IS NOT NULL AND dbo.ufn_GetWordPressBluePrintsEdition(@PostID) <> '') THEN 'Produce Blueprints ' + dbo.ufn_GetWordPressBluePrintsEdition(@PostID) + ' Edition' ELSE t.name END
		FROM WordPressProduce.dbo.wp_posts p WITH (NOLOCK)
			LEFT JOIN WordPressProduce.dbo.wp_term_relationships rel ON rel.object_id = p.ID
			LEFT JOIN WordPressProduce.dbo.wp_term_taxonomy tax ON tax.term_taxonomy_id = rel.term_taxonomy_id
			LEFT JOIN WordPressProduce.dbo.wp_terms t ON t.term_id = tax.term_id
		WHERE ID = @PostID
			AND tax.taxonomy = 'Category'
	END

	--SELECT @Categories
	RETURN @Categories
END
Go


IF EXISTS (SELECT 'x' from dbo.sysobjects where id = object_id(N'[dbo].[ufn_HasCertification]') )
	DROP FUNCTION [dbo].[ufn_HasCertification]
GO

--
-- Determines if the specified record has a certification (either Organic or Food Safety)
--
CREATE FUNCTION [dbo].[ufn_HasCertification](
    @CompanyID int
)
RETURNS char(1)
AS
BEGIN
    DECLARE @Return char(1)
    SELECT @Return = 'Y'
			FROM PRCompanyProfile WITH (NOLOCK)
     WHERE prcp_CompanyID = @CompanyID
       AND ((prcp_Organic = 'Y') OR (prcp_FoodSafetyCertified = 'Y'))
    RETURN @Return
END
GO

IF EXISTS (SELECT 'x' from dbo.sysobjects where id = object_id(N'[dbo].[ufn_HasCertification_Organic]') )
	DROP FUNCTION [dbo].[ufn_HasCertification_Organic]
GO

--
-- Determines if the specified record has an organic certification
--
CREATE FUNCTION [dbo].[ufn_HasCertification_Organic](
    @CompanyID int
)
RETURNS char(1)
AS
BEGIN
    DECLARE @Return char(1)
    SELECT @Return = 'Y'
			FROM PRCompanyProfile WITH (NOLOCK)
     WHERE prcp_CompanyID = @CompanyID
       AND prcp_Organic = 'Y'
    RETURN @Return
END
GO

IF EXISTS (SELECT 'x' from dbo.sysobjects where id = object_id(N'[dbo].[ufn_HasCertification_FoodSafety]') )
	DROP FUNCTION [dbo].[ufn_HasCertification_FoodSafety]
GO

--
-- Determines if the specified record has a Food safety certification
--
CREATE FUNCTION [dbo].[ufn_HasCertification_FoodSafety](
    @CompanyID int
)
RETURNS char(1)
AS
BEGIN
    DECLARE @Return char(1)
    SELECT @Return = 'Y'
			FROM PRCompanyProfile WITH (NOLOCK)
     WHERE prcp_CompanyID = @CompanyID
       AND prcp_FoodSafetyCertified = 'Y'
    RETURN @Return
END
GO

IF EXISTS (SELECT 'x' from dbo.sysobjects where id = object_id(N'[dbo].[ufn_KYCPostTitleAdjust]') )
	DROP FUNCTION [dbo].[ufn_KYCPostTitleAdjust]
GO

--
-- Adjust KYCPostTitle for various exception (i.e. Greenhouse)
--
CREATE FUNCTION [dbo].[ufn_KYCPostTitleAdjust](
    @GrowingMethod varchar(100),
    @prcca_ListingCol1 varchar(100),
    @prcca_ListingCol2 varchar(100),
    @prcm_KYCPostTitle varchar(500)
)
RETURNS varchar(500)
AS
BEGIN
    DECLARE @Return varchar(500)
    IF (@GrowingMethod = 'Greenhouse' AND @prcca_ListingCol1 = 'Tomato')
    BEGIN
        SET @Return = @prcm_KYCPostTitle + ' (' + @GrowingMethod + ')' 
    END
    ELSE IF(@GrowingMethod = 'Greenhouse' AND @prcca_ListingCol1 = 'Pepper' AND @prcca_ListingCol2 NOT IN ('Jalapeno','Habanero','Chili'))
    BEGIN
        SET @Return = @prcm_KYCPostTitle + ' (' + @GrowingMethod + ')' 
    END
    ELSE
		BEGIN
        SET @Return = @prcm_KYCPostTitle
    END

    return @Return
END
GO


--
-- AccountingCodeLookup
--
CREATE OR ALTER FUNCTION [dbo].[ufn_AccountingCodeLookup](
    @BBOSCode varchar(100),
		@Premium varchar(1) = 'N'
)
RETURNS varchar(500)
AS
BEGIN
    DECLARE @Return varchar(500) = null

	IF @Premium = 'Y'
		BEGIN
			SET @Return = CASE @BBOSCode
					WHEN 'KYC' THEN 'RGADPREM'
				END
		END
		ELSE
		BEGIN
			SET @Return = CASE 
					WHEN @BBOSCode LIKE 'IA%' THEN 'IADVB'
					WHEN @BBOSCode = 'PRNBA_200x167' THEN 'PRDBAD'
					WHEN @BBOSCode = 'PRNBA_580x72' THEN 'PRLAD'
					WHEN @BBOSCode = 'PRNBA_SP' THEN 'PRLAD'
					WHEN @BBOSCode = 'CSEU' THEN 'PRLAD'
					WHEN @BBOSCode LIKE 'PMSHPB%' THEN 'LHPAD'		-- All homepage leaderboard ads map to the same code
					WHEN @BBOSCode LIKE 'PMSHPSQ%' THEN 'SQHPAD'	-- All homepage square ads map to the same code
					WHEN @BBOSCode = 'BBILA' THEN 'IADVI'
					WHEN @BBOSCode = 'KYC' THEN 'RGAD'
					WHEN @BBOSCode = 'SRLA' THEN 'PRLAD'			-- Search result leaderboard ad
				END
		END

    return @Return
END
GO

IF EXISTS (SELECT 'x' from dbo.sysobjects where id = object_id(N'[dbo].[ufn_HasAdvertisingItemCode]') )
	DROP FUNCTION [dbo].[ufn_HasAdvertisingItemCode]
GO

CREATE FUNCTION [dbo].[ufn_HasAdvertisingItemCode](
    @InvoiceNo varchar(100)
)
RETURNS int
AS
BEGIN
	DECLARE @RetVal int = 0
	DECLARE @ItemCodeCount int
	SELECT @ItemCodeCount = COUNT(*) 
	  FROM MAS_PRC.dbo.AR_InvoiceHistoryHeader ihh WITH (NOLOCK)
           INNER JOIN MAS_PRC.dbo.AR_InvoiceHistoryDetail ihd WITH (NOLOCK) ON ihh.InvoiceNo = ihd.InvoiceNo
	 WHERE (UDF_MASTER_INVOICE = @InvoiceNo) AND ItemCode IN ('LMBAD','TTAD','BPAD','RGADPREM','IADVB','PRDBAD','PRLAD','LHPAD','SQHPAD''IADVI','RGAD', 'IADBUT', 'IADVI', 'SQHPAD')
	
	IF @ItemCodeCount > 0 
	BEGIN
		SET @RetVal = 1
	END


    return @RetVal
END
GO

--AdCampaignTerms Default Invoice Description
IF EXISTS (SELECT 'x' from dbo.sysobjects where id = object_id(N'[dbo].[ufn_AdCampaignTermsInvoiceDescription]') )
	DROP FUNCTION [dbo].ufn_AdCampaignTermsInvoiceDescription
GO

CREATE FUNCTION [dbo].ufn_AdCampaignTermsInvoiceDescription(
    @AdCampaignID int
)
RETURNS varchar(50)
AS
BEGIN
			DECLARE @TypeCode varchar(10)
			DECLARE @Premium varchar(1)
			DECLARE @BluePrintsEdition varchar(100)
			DECLARE @BluePrintsEditionCapt varchar(100)
			DECLARE @KYCEdition varchar(100)
			DECLARE @KYCEditionCapt varchar(100)
			DECLARE @KYCCommodityID int
			DECLARE @KYCCommodityCapt varchar(100)
			DECLARE @AdCampaignTypeDigital varchar(100)
			DECLARE @AdCampaignTypeDigitalCapt varchar(100)
			DECLARE @TTEdition varchar(100)
			DECLARE @TTEditionCapt varchar(100)
			DECLARE @InvoiceDescription varchar(30) = ''

			SELECT
				@TypeCode = pradch_TypeCode,
				@Premium = pradc_Premium,
				@BluePrintsEdition = pradc_BluePrintsEdition,
				@BluePrintsEditionCapt = ccBPEdition.Capt_US,
				@KYCEdition = pradc_KYCEdition,
				@KYCEditionCapt = ccKYCEdition.Capt_US,
				@KYCCommodityID = pradc_KYCCommodityID,
				@KYCCommodityCapt = prkycc_PostName,
				@AdCampaignTypeDigital = pradc_AdCampaignTypeDigital,
				@AdCampaignTypeDigitalCapt = ccTypeDigital.Capt_US,
				@TTEdition = pradc_TTEdition
			FROM PRAdCampaignHeader
				INNER JOIN PRAdCampaign ON pradc_AdCampaignHeaderID = pradch_AdCampaignHeaderID
				LEFT OUTER JOIN Custom_Captions ccKYCEdition ON pradc_KYCEdition = ccKYCEdition.Capt_Code AND ccKYCEdition.capt_family='pradc_KYCEdition'
				LEFT OUTER JOIN Custom_Captions ccTypeDigital ON pradc_AdCampaignTypeDigital = ccTypeDigital.Capt_Code AND ccTypeDigital.capt_family='pradc_AdCampaignTypeDigital'
				LEFT OUTER JOIN Custom_Captions ccBPEdition ON pradc_BluePrintsEdition = ccBPEdition.Capt_Code AND ccBPEdition.capt_family='pradc_BluePrintsEdition'
				LEFT OUTER JOIN PRKYCCommodity ON prkycc_KYCCommodityID = pradc_KYCCommodityID
			WHERE pradc_AdCampaignID = @AdCampaignID

			
			IF @TypeCode = 'BP'
			BEGIN
				SET @InvoiceDescription = @BluePrintsEditionCapt + ' Blueprints Ad'
			END
			ELSE IF @TypeCode = 'KYC'
			BEGIN
				IF @Premium = 'Y'
				BEGIN
					IF @KYCCommodityCapt IS NULL
					BEGIN
						SET @InvoiceDescription = @KYCEditionCapt + ' Prem. Ad'
					END
					ELSE
					BEGIN
						SET @InvoiceDescription = @KYCEditionCapt + ' Prem. Ad:' + @KYCCommodityCapt
					END
				END
				ELSE
				BEGIN
					SET @InvoiceDescription = @KYCEditionCapt + ' Ad:' + @KYCCommodityCapt
				END
	
			END
			ELSE IF @TypeCode = 'D'
			BEGIN
				SELECT @InvoiceDescription = CASE 
					WHEN @AdCampaignTypeDigital = 'BBILA' THEN 'BB Insider Leaderboard Ad'
					WHEN @AdCampaignTypeDigital = 'BPBDA' THEN 'BP Briefing Digital Ad'
					WHEN @AdCampaignTypeDigital = 'LPA' THEN 'Listing Publicity Ad'
					WHEN @AdCampaignTypeDigital = 'PMSHPB' THEN 'Leaderboard 1 Home Page Ad'
					WHEN @AdCampaignTypeDigital = 'PMSHPB2' THEN 'Leaderboard 2 Home Page Ad'
					WHEN @AdCampaignTypeDigital = 'PMSHPB3' THEN 'Leaderboard 3 Home Page Ad'
					WHEN @AdCampaignTypeDigital = 'PRNBA_200x167' THEN 'Newsletter Banner Ad'
					WHEN @AdCampaignTypeDigital = 'PRNBA_580x72' THEN 'Newsletter Leaderboard Ad'
					ELSE @AdCampaignTypeDigitalCapt
				END
			END
			ELSE IF @TypeCode = 'TT'
			BEGIN
				SET @InvoiceDescription = @TTEdition + ' Trading/Transp. Guide Ad'
			END

			return @InvoiceDescription
END
GO

-- 8.4 get last x blueprint editions for company
IF EXISTS (SELECT 'x' from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetRecentBluePrintsEditions]') )
	DROP FUNCTION [dbo].[ufn_GetRecentBluePrintsEditions]
GO

CREATE FUNCTION dbo.ufn_GetRecentBluePrintsEditions
(
    @CompanyID int,
		@Count int = 6
)
RETURNS varchar(8000)
BEGIN
	DECLARE @T as TABLE (pradc_BluePrintsEdition varchar(8000))

	INSERT INTO @T
	SELECT TOP (@Count) * FROM
	(
		SELECT DISTINCT cc.Capt_US pradc_BluePrintsEdition FROM PRAdCampaignHeader
			INNER JOIN PRAdCampaign ON pradc_AdCampaignHeaderid = pradch_AdCampaignHeaderID
			INNER JOIN Custom_Captions cc ON pradc_BluePrintsEdition = cc.Capt_Code AND cc.Capt_Family='pradc_BlueprintsEdition'
		WHERE 
			pradch_TypeCode = 'BP'
			AND pradc_CompanyID = @CompanyId
	) x
	ORDER BY pradc_BluePrintsEdition DESC

	DECLARE @Editions varchar(8000)
	SELECT @Editions = COALESCE(@Editions + ', ', '') + pradc_BluePrintsEdition
	FROM @T

	RETURN @Editions
END
Go

--8.5
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetBBS200MembershipPrice]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    drop function [dbo].ufn_GetBBS200MembershipPrice
GO

CREATE FUNCTION [dbo].ufn_GetBBS200MembershipPrice(@CompanyID int)
RETURNS numeric(24,6)
AS
BEGIN
	DECLARE @prcta_TradeAssociationCode varchar(500)
	DECLARE @pric_price AS numeric(24,6)
	DECLARE @pric_price_default AS numeric(24,6)
	DECLARE @ReturnVal numeric(24,6)

	SELECT @pric_price_default = pric_price FROM Pricing WHERE pric_ProductID = 5 AND pric_Active='Y' AND pric_PriceCode IS NULL

	SELECT @prcta_TradeAssociationCode = prcta_TradeAssociationCode FROM PRCompanyTradeAssociation WHERE prcta_CompanyID = @CompanyID
	IF @prcta_TradeAssociationCode IS NULL
	BEGIN
			SET @ReturnVal = @pric_price_default
	END
	ELSE
	BEGIN
			SELECT @pric_price = pric_price FROM Pricing WHERE pric_ProductID = 5 AND pric_Active='Y' AND pric_PriceCode=@prcta_TradeAssociationCode
			IF @pric_price IS NULL
			BEGIN
				SET @ReturnVal = @pric_price_default
			END
			ELSE
			BEGIN
				SET @ReturnVal = @pric_price
			END
	END

	Return @ReturnVal
END
GO 

--8.9
--
-- Returns a list of Watchdog groups
--
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetWatchdogGroupsForList]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    drop function [dbo].ufn_GetWatchdogGroupsForList
GO

CREATE Function dbo.ufn_GetWatchdogGroupsForList(@WebUserID int, @CompanyID int)
RETURNS varchar(5000)
AS
BEGIN
    
    DECLARE @List varchar(5000)
	DECLARE @HQID int = (select prwu_hqid from prwebuser where prwu_webuserid=@WebUserID)

    SELECT @List = COALESCE(@List + ', ', '') + prwucl_Name
	FROM PRWebUserList WITH (NOLOCK)
		INNER JOIN PRWebUserListDetail WITH (NOLOCK) ON prwucl_WebUserListID = prwuld_WebUserListID
	WHERE ((prwucl_HQID = @HQID AND prwucl_IsPrivate IS NULL) OR (prwucl_WebUserID=@WebUserID AND prwucl_IsPrivate = 'Y')) 
		AND prwuld_AssociatedID = @CompanyID
	ORDER BY prwucl_Name

    RETURN @List
END

GO

--8.10
IF EXISTS (SELECT 'x' from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetEmailImageHTML]') )
	DROP FUNCTION [dbo].[ufn_GetEmailImageHTML]
GO

CREATE FUNCTION dbo.ufn_GetEmailImageHTML
(
    @prei_EmailTypeCode nvarchar(40),
	@prei_LocationCode nvarchar(40),
	@prei_Industry nvarchar(40)
)
RETURNS varchar(5000)
BEGIN
	DECLARE @EmailImageHTML varchar(5000)
	DECLARE @Hyperlink varchar(1000)
	DECLARE @FileName varchar(1000)
	DECLARE @EmailType varchar(10)
	DECLARE @BBOSURL varchar(1000)
	DECLARE @EmailImageID int
	
	SET @EmailImageHTML = '<div style="text-align:center"><a href="{0}"><img src="{1}" /></a><br></div>'
	SET @BBOSURL = dbo.ufn_GetCustomCaptionValue('BBOS', 'URL', 'en-us') 
	SELECT  @Hyperlink=prei_Hyperlink, 
			@FileName=prei_EmailImgDiskFileName ,
			@EmailType=capt_us,
			@EmailImageID=prei_EmailImageID
	FROM PREmailImages 
		INNER JOIN custom_captions ON capt_code=@prei_EmailTypeCode AND capt_family='prei_EmailTypeCode'
	WHERE
		prei_EmailTypeCode = @prei_EmailTypeCode
		AND prei_LocationCode = @prei_LocationCode
		AND (prei_Industry = 'B' OR prei_Industry LIKE '%' + @prei_Industry + '%')
		AND GETDATE() >= prei_StartDate
		AND GETDATE() <= prei_EndDate 
		AND prei_Deleted IS NULL	

	IF @Hyperlink IS NULL OR @FileName IS NULL 
	BEGIN
		SET @EmailImageHTML = ''
	END
	ELSE
	BEGIN
		SET @EmailImageHTML = REPLACE(@EmailImageHTML, '{0}', @Hyperlink)
		SET @EmailImageHTML = REPLACE(@EmailImageHTML , '{1}', @BBOSURL + 'Campaigns/' + @EmailType + '/' + CAST(@EmailImageID as varchar(10)) + '/' + @FileName)
	END

	RETURN @EmailImageHTML
END
GO


CREATE OR ALTER Function [dbo].ufn_PreparePhoneForMatch
(
    @Phone varchar(20)
)
RETURNS varchar(20)
as
BEGIN

	DECLARE @PreparedPhone varchar(20)

	IF (@Phone LIKE '1%') BEGIN
		SET @Phone = SUBSTRING(@Phone, 2, LEN(@Phone)-1)	
	END	

	IF (@Phone LIKE '+1%') BEGIN
		SET @Phone = SUBSTRING(@Phone, 3, LEN(@Phone)-2)	
	END

	IF (RTRIM(@Phone) = '')
		SET @Phone = NULL

	SET @PreparedPhone = dbo.ufn_GetLowerAlpha(ISNULL(@Phone, 'zzzzz'))

	RETURN @PreparedPhone

END
Go


CREATE OR ALTER Function [dbo].ufn_FindCompanyMatch
(
	@CompanyName varchar(200),
    @City varchar(100) = NULL,
    @State varchar(25) = NULL,
    @Phone1 varchar(20) = NULL,
    @Phone2 varchar(20) = NULL,
    @Phone3 varchar(20) = NULL,
	@Phone4 varchar(20) = NULL,
    @Email varchar(255) = NULL,
    @WebSite varchar(255) = NULL,
	@IndustryTypeFilter varchar(255) = NULL,
	@ListingStatusFilter varchar(255) = 'L,H',
	@ReturnHQsOnly bit = 1
)
RETURNS @tblHQs TABLE (
    CompanyID int,
    MatchType varchar(15),
	ListingStatus varchar(40))
as
BEGIN
	
	DECLARE @RowCount int = 0
	DECLARE @PreparedCompanyName varchar(200) = dbo.ufn_GetLowerAlpha(dbo.ufn_PrepareCompanyName(@CompanyName))

	DECLARE @tblResults table (
		CompanyID int,
		HQID int,
		ListingStatus varchar(40),
		MatchType varchar(15)
	)


	IF ((@Phone1 IS NOT NULL) OR
	    (@Phone2 IS NOT NULL) OR
		(@Phone3 IS NOT NULL) OR
		(@Phone4 IS NOT NULL)) BEGIN

		DECLARE @PreparedPhone1 varchar(20) = dbo.ufn_PreparePhoneForMatch(@Phone1)
		DECLARE @PreparedPhone2 varchar(20) = dbo.ufn_PreparePhoneForMatch(@Phone2)
		DECLARE @PreparedPhone3 varchar(20) = dbo.ufn_PreparePhoneForMatch(@Phone3)
		DECLARE @PreparedPhone4 varchar(20) = dbo.ufn_PreparePhoneForMatch(@Phone4)

		-- Step 1: Phone
		INSERT INTO @tblResults (CompanyID, MatchType)
		SELECT DISTINCT phon_CompanyID, 'Phone'
			FROM vPRPhone WITH (NOLOCK)
			WHERE phon_PhoneMatch IS NOT NULL
			AND phon_CompanyID IS NOT NULL
			AND (phon_PhoneMatch = @PreparedPhone1
				OR phon_PhoneMatch = @PreparedPhone2
				OR phon_PhoneMatch = @PreparedPhone3
				OR phon_PhoneMatch = @PreparedPhone4)

		--SET @RowCount = @@ROWCOUNT
	END

	-- Step 2: Web Site
	IF ((@WebSite IS NOT NULL) AND (@RowCount = 0)) BEGIN

		DECLARE @PreparedWebSite varchar(255) = @WebSite
		IF (@WebSite LIKE 'http://%') BEGIN
			SET @PreparedWebSite = SUBSTRING(@WebSite, 8, LEN(@WebSite)-7)	
		END	
		IF (@WebSite LIKE 'https://%') BEGIN
			SET @PreparedWebSite = SUBSTRING(@WebSite, 9, LEN(@WebSite)-8)	
		END	

		INSERT INTO @tblResults (CompanyID, MatchType)
		SELECT DISTINCT ELink_RecordID, 'Website'
			FROM vCompanyEmail WITH (NOLOCK)
			WHERE emai_PRWebAddress = RTRIM(@PreparedWebSite)

		--SET @RowCount = @@ROWCOUNT
	END

	-- Step 3: Email
	IF ((@Email IS NOT NULL) AND (@RowCount = 0)) BEGIN
		INSERT INTO @tblResults (CompanyID, MatchType)
		SELECT DISTINCT ELink_RecordID, 'Email'
			FROM vCompanyEmail WITH (NOLOCK)
			WHERE Emai_EmailAddress = RTRIM(@Email)

		--SET @RowCount = @@ROWCOUNT
	END

	-- Step 4: Company Names
	IF (@RowCount = 0) BEGIN

		INSERT INTO @tblResults (CompanyID, MatchType)
		SELECT DISTINCT prcse_CompanyId, 'Name'
			FROM PRCompanySearch WITH (NOLOCK)
				INNER JOIN vPRAddress ON adli_CompanyID = prcse_CompanyId
			WHERE (prst_Abbreviation = @State
		   		OR prst_State = @State)
			AND (prcse_NameMatch = @PreparedCompanyName
				OR prcse_LegalNameMatch = @PreparedCompanyName
				OR prcse_CorrTradestyleMatch = @PreparedCompanyName)

		--SET @RowCount = @@ROWCOUNT
	END

	-- Step 5: Aliases
	IF (@RowCount = 0) BEGIN

		INSERT INTO @tblResults (CompanyID, MatchType)
		SELECT DISTINCT pral_CompanyId, 'Alias'
		  FROM PRCompanyAlias WITH (NOLOCK)
			   INNER JOIN vPRAddress ON adli_CompanyID = pral_CompanyId
		WHERE (prst_Abbreviation = @State OR prst_State = @State)
		  AND pral_AliasMatch = @PreparedCompanyName

		--SET @RowCount = @@ROWCOUNT
	END

		UPDATE @tblResults
		   SET HQID = comp_PRHQID,
			   ListingStatus = comp_PRListingStatus
		  FROM Company WITH (NOLOCK)
		 WHERE CompanyID = comp_CompanyID

	IF (@IndustryTypeFilter IS NOT NULL) BEGIN
		DELETE r
		FROM @tblResults r
			INNER JOIN Company c ON c.comp_companyid=r.CompanyID
		WHERE comp_PRIndustryType NOT IN (SELECT value FROM STRING_SPLIT(@IndustryTypeFilter, ',')) 
	END

	IF (@ListingStatusFilter IS NOT NULL) BEGIN
		DELETE r
		FROM @tblResults r
			INNER JOIN Company c ON c.comp_companyid=r.CompanyID
		WHERE comp_PRListingStatus NOT IN (SELECT value FROM STRING_SPLIT(@ListingStatusFilter, ',')) 
	END

	IF (@ReturnHQsOnly = 1) BEGIN
		INSERT INTO @tblHQs
		SELECT DISTINCT HQID, '', ListingStatus --, MatchType
		  FROM @tblResults
	END ELSE BEGIN
		INSERT INTO @tblHQs
		SELECT DISTINCT CompanyID, '', ListingStatus --, MatchType
		  FROM @tblResults
	END

	RETURN
END
Go

CREATE OR ALTER Function [ufn_GetMostRecentDate]
(
    @D1 datetime,
	@D2 datetime
)
RETURNS datetime
AS
BEGIN
	RETURN CASE WHEN COALESCE(@D1, CAST('' AS DATETIME)) > COALESCE(@D2, CAST('' AS DATETIME)) THEN @D1 ELSE @D2 END
END
GO

CREATE OR ALTER Function [ufn_GetBusinessStartDate]
(
    @BBID int
)
RETURNS datetime
AS
BEGIN
	DECLARE @BusinessStartDate datetime
	DECLARE @T TABLE
	(
		prbe_CompanyID int,
		prbe_BusinessEventTypeId int,
		prbe_EffectiveDate datetime,
		[Priority] int
	)
	INSERT INTO @T
		SELECT  
			prbe_CompanyID, 
			prbe_BusinessEventTypeId, 
			MIN(prbe_EffectiveDate) prbe_EffectiveDate,
			[Priority]= CASE WHEN prbe_BusinessEventTypeId=9 THEN 1 
								WHEN prbe_BusinessEventTypeId=42 THEN 2 
								WHEN prbe_BusinessEventTypeId=8 THEN 3
						END
		FROM PRBusinessEvent WITH(NOLOCK)
		WHERE prbe_BusinessEventTypeId IN (9, 42, 8)
			AND prbe_CompanyId=@BBID
		GROUP BY prbe_CompanyID, prbe_BusinessEventTypeId, prbe_EffectiveDate, prbe_DisplayedEffectiveDate, prbe_DetailedType
		ORDER BY prbe_CompanyID, Priority ASC, prbe_EffectiveDate ASC

	SET @BusinessStartDate = (SELECT TOP 1 prbe_EffectiveDate FROM @T ORDER BY Priority ASC, prbe_effectiveDate ASC)
	return @BusinessStartDate;
END
GO

CREATE or ALTER FUNCTION CSV_Remove_Dups(
	@List VARCHAR(MAX),
	@Delim CHAR
)
RETURNS
VARCHAR(MAX)
AS
BEGIN
	DECLARE @ParsedList TABLE
	(
		Item VARCHAR(MAX)
	)
	
	DECLARE @list1 VARCHAR(MAX), @Pos INT, @rList VARCHAR(MAX)
	SET @list = LTRIM(RTRIM(@list)) + @Delim
	SET @pos = CHARINDEX(@delim, @list, 1)
	
	WHILE @pos > 0
	BEGIN
		SET @list1 = LTRIM(RTRIM(LEFT(@list, @pos - 1)))
		IF @list1 <> ''
			INSERT INTO @ParsedList VALUES (CAST(@list1 AS VARCHAR(MAX)))
		SET @list = SUBSTRING(@list, @pos+1, LEN(@list))
		SET @pos = CHARINDEX(@delim, @list, 1)
	END
	SELECT @rlist = COALESCE(@rlist+', ','') + item
	FROM (SELECT DISTINCT Item FROM @ParsedList) t
	RETURN @rlist
END
GO

CREATE OR ALTER FUNCTION [dbo].[ufn_PrepareSlugValue] (  
    @Content varchar(500) 
) 
RETURNS varchar(500) 
AS 
BEGIN 
 
	DECLARE @Slug varchar(500) = '' 
	DECLARE @CurrentChar varchar(1) 
	DECLARE @idx smallint = 0, @Ascii int 

	SET @Content = LTRIM(RTRIM(@Content)) 
	SET @Content = LOWER(@Content) 
	SET @Content = REPLACE(@Content, ' ', '-') 

	IF ISNULL(@Content, '') = '' 
		RETURN @Slug 

	While (@idx <= DATALENGTH(@Content)) 
	Begin         
		Set @CurrentChar = SUBSTRING(@Content, @idx, 1) 
		Set @Ascii = ASCII(@CurrentChar) 

		--Print @CurrentChar + '-' + CAST(@Ascii as varchar(5)) 

		if (@Ascii = ASCII('-')) Begin 
			SET @Slug = @Slug + @CurrentChar 
		end 

		if (@Ascii >= ASCII('a')) Begin 
			if (@Ascii <= ASCII('z')) Begin 
				SET @Slug = @Slug + @CurrentChar 
			end  
		end 

		if (@Ascii >= ASCII('0')) Begin 
			if (@Ascii <= ASCII('9')) Begin 
				SET @Slug = @Slug + @CurrentChar 
			end  
		end 

		SET @idx = @idx + 1 
	End 

	SET @Slug = @Slug + '/' 
	RETURN @Slug 
END 
GO 

CREATE OR ALTER FUNCTION dbo.ufn_GetPaymentMethodList ( 
    @Companyid varchar(20)
)
RETURNS VARCHAR(200)
AS
BEGIN
	DECLARE @RetValue varchar(200)

	SELECT @RetValue = Coalesce(@RetValue + ', ', '') + PaymentMethod
	  FROM (
			SELECT DISTINCT CustomerNo, CASE WHEN ISNUMERIC(CheckNo) = 1 THEN 'CHECK' ELSE CheckNo END As PaymentMethod
			  FROM MAS_PRC.dbo.AR_TransactionPaymentHistory WITH (NOLOCK)
			WHERE CheckNo <> ''
			  AND CustomerNo = @Companyid
		   ) T1

  SET @RetValue = rtrim(convert(nvarchar(1024), COALESCE(@RetValue,'')))
  RETURN @RetValue
END
GO



CREATE OR ALTER FUNCTION dbo.ufn_GetAvailableBackgroundChecks(@CompanyID int)
RETURNS int  AS  
BEGIN 
    
    DECLARE @HQID int
    SELECT @HQID = comp_PRHQID
      FROM Company WITH (NOLOCK)
     WHERE comp_CompanyID = @CompanyID;

    DECLARE @RemainingUnits int
        
    SELECT @RemainingUnits = SUM(prbca_Remaining) 
      FROM PRBackgroundCheckAllocation WITH (NOLOCK)
     WHERE GETDATE() BETWEEN prbca_StartDate AND prbca_ExpirationDate
       AND prbca_HQID = @HQID;

    IF @RemainingUnits IS NULL SET @RemainingUnits=0

    RETURN @RemainingUnits
END
GO

CREATE OR ALTER FUNCTION dbo.ufn_GetAllocatedBackgroundChecks(@CompanyID int)
RETURNS int  AS  
BEGIN 
    DECLARE @HQID int
    SELECT @HQID = comp_PRHQID
      FROM Company WITH (NOLOCK)
     WHERE comp_CompanyID = @CompanyID;

    DECLARE @AllocatedUnits int
        
    SELECT @AllocatedUnits = SUM(prbca_Allocation) 
      FROM PRBackgroundCheckAllocation WITH (NOLOCK)
     WHERE GETDATE() BETWEEN prbca_StartDate AND prbca_ExpirationDate
       AND prbca_HQID = @HQID;

    IF @AllocatedUnits IS NULL SET @AllocatedUnits=0

    RETURN @AllocatedUnits
END
GO