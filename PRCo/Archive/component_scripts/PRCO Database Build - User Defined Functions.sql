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
            FROM PRCommodity 
            WHERE prcm_ParentId = 0
            order by prcm_Name

    end
    else
    begin
        
        INSERT INTO @tblCommodities 
            select prcm_CommodityId, prcm_ParentId, prcm_Level, prcm_Name, 
                prcm_Alias, prcm_CommodityCode, prcm_PathNames, prcm_PathCodes 
            from PRCommodity 
            where prcm_CommodityId = @prcm_CommodityId
    
        Insert into @tblInternal
            SELECT prcm_CommodityId, prcm_ParentId, prcm_Level, prcm_Name, 
                prcm_Alias, prcm_CommodityCode, prcm_PathNames, prcm_PathCodes 
            FROM PRCommodity 
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
  SELECT  @RetValue = Coalesce(@RetValue + ', ', '') + Convert(nvarchar(1024),prat_name)
    FROM PRCompanyCommodityAttribute
    JOIN PRAttribute ON prat_AttributeId = prcca_AttributeId
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
    -- Load all the classifications
    INSERT INTO @tblClassifications
        SELECT prcl_ClassificationId, prcl_ParentId, 
               prcl_Level, prcl_Name, prcl_Abbreviation, prcl_BookSection, prcl_Path 
        FROM PRClassification
    -- if company is not passed, return everything
    if (@CompanyId is null)
        RETURN
    -- if the company is sent but it has no selected classifications, just return
    DECLARE @prc2_ClassId int
    SELECT TOP 1 @prc2_ClassId = prc2_ClassificationId from PRCompanyClassification Where prc2_CompanyId=@CompanyId
    if (@prc2_ClassId is null)
        RETURN
            
    -- selectively remove certain classification from our return set
    
    -- remove any items not in the same Book Section
    DELETE FROM @tblClassifications
    WHERE prcl_BookSection != 
          ( Select prcl_BookSection from PRClassification WHERE prcl_ClassificationId = @prc2_ClassId)
          
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
        FROM PRCompanyClassification 
       INNER JOIN PRClassification ON prc2_ClassificationId = prcl_ClassificationId 
       WHERE prc2_ClassificationId in 
			( select prcl_ClassificationId from PRClassification 
               where prcl_Abbreviation in ('Dstr', 'Exp', 'J', 'R', 'Ret', 'Rg', 'Wg', 'TruckBkr')
			)
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
  SELECT  @RetValue = Coalesce(@RetValue + ', ', '') + Convert(nvarchar(1024),capt_us)
    FROM Address_Link
    JOIN Custom_Captions ON capt_code = adli_Type AND 
            capt_familytype = 'Choices' AND capt_family = @capt_family 
    WHERE adli_AddressId = @addressid
  SET @RetValue = rtrim(Convert(nvarchar(1024),COALESCE(@RetValue,'')))
  RETURN @RetValue
END
GO

-- The tokenize function takes a comma delimited string and returns a 
-- table of the string's values
/***********************************************************************
***********************************************************************
 Copyright Elliott Affiliates, Ltd. 2004

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Elliott Affiliates, Ltd. is 
 strictly prohibited.

 Confidential, Unpublished Property of Elliott Affiliates, Ltd.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This function was included by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 Notes:	

***********************************************************************
***********************************************************************/
If Exists (Select name from sysobjects where name = 'Tokenize' and type='TF') 
    Drop Function dbo.Tokenize
Go

CREATE FUNCTION dbo.Tokenize(@sText varchar(8000), @sDelim varchar(20) = ' ')
RETURNS @retArray TABLE (idx smallint Primary Key, value varchar(8000))
AS
BEGIN
    DECLARE @idx smallint,
	    @value varchar(8000),
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
    --If you can’t find the delimiter in the text, @sText is the last value in
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
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetTradeReportAnalysis]') 
            and OBJECTPROPERTY(id, N'IsTableFunction') = 1)
drop Function [dbo].[ufn_GetTradeReportAnalysis]
GO

CREATE FUNCTION dbo.ufn_GetTradeReportAnalysis
(
    @prtr_SubjectId int = NULL,
    @prtr_StartDate datetime = NULL,
    @prtr_EndDate datetime = NULL,
    @prtr_Exception char(1) = NULL,
    @prtr_DisputeInvolved char(1) = NULL,
    @prtr_ClassificationList varchar(50) = NULL
)
RETURNS @tblTradeReportAnalysis TABLE (
    prtr_SubjectId int,
    prtr_ReportCount int,
    prtr_Int_Count int,
    prtr_Int_Avg decimal(6,3) default 0,
    prtr_Int_XCount int default 0, prtr_Int_XPct decimal(6,3) default 0,
    prtr_Int_XXCount int default 0, prtr_Int_XXPct decimal(6,3) default 0,
    prtr_Int_XXXCount int default 0, prtr_Int_XXXPct decimal(6,3) default 0,
    prtr_Int_XXXXCount int default 0, prtr_Int_XXXXPct decimal(6,3) default 0,
    prtr_Credit_Count int,
    prtr_Credit_5MCount int default 0, prtr_Credit_5MPct decimal(6,3) default 0,
    prtr_Credit_10MCount int default 0, prtr_Credit_10MPct decimal(6,3) default 0,
    prtr_Credit_50MCount int default 0, prtr_Credit_50MPct decimal(6,3) default 0,
    prtr_Credit_75MCount int default 0, prtr_Credit_75MPct decimal(6,3) default 0,
    prtr_Credit_100MCount int default 0, prtr_Credit_100MPct decimal(6,3) default 0,
    prtr_Credit_250MCount int default 0, prtr_Credit_250MPct decimal(6,3) default 0,
    prtr_Pay_Count int, prtr_Pay_Median varchar(40),prtr_Pay_MedianNumeric decimal(6,3) default 0,
    prtr_Pay_Low varchar(40), prtr_Pay_High varchar(40),
    prtr_Pay_AACount int default 0, prtr_Pay_AAPct decimal(6,3) default 0,
    prtr_Pay_ACount int default 0, prtr_Pay_APct decimal(6,3) default 0,
    prtr_Pay_ABCount int default 0, prtr_Pay_ABPct decimal(6,3) default 0,
    prtr_Pay_BCount int default 0, prtr_Pay_BPct decimal(6,3) default 0,
    prtr_Pay_CCount int default 0, prtr_Pay_CPct decimal(6,3) default 0,
    prtr_Pay_DCount int default 0, prtr_Pay_DPct decimal(6,3) default 0,
    prtr_Pay_ECount int default 0, prtr_Pay_EPct decimal(6,3) default 0,
    prtr_Pay_FCount int default 0, prtr_Pay_FPct decimal(6,3) default 0
)
as
BEGIN
    DECLARE @Msg varchar(2000)

    DECLARE @prtr_ReportCount int, @prtr_Int_Count int, @prtr_Crt_Count int, @prtr_Pay_Count int

    -- the user id is required
/*    IF ( @UserId IS NULL) 
    BEGIN
        SET @Msg = 'Update Failed.  An valid User Id must be provided.'
        ROLLBACK
        RAISERROR (@Msg, 16, 1)
        Return
    END
*/
    -- Create a local table for the trade reports that meet our search
    -- 2/24/2006 changing the insert below to populate the ...number fields with the weight
    --           values from the Pay and Integrity Rating lookups
    DECLARE @tblTRs TABLE (prtr_integrityid int, prin_weight decimal(6,3),
                           prtr_payratingid int, prpy_weight decimal(6,3),
                           prtr_highcredit varchar(4)
                          )

    -- get the TradeReports
    INSERT INTO @tblTRs 
        SELECT prtr_integrityid, convert(decimal(6,3),prin_weight),
               prtr_PayRatingId, convert(decimal(6,3),prpy_weight),
               prtr_HighCredit
        FROM PRTradeReport
        LEFT OUTER JOIN PRPayRating ON prtr_PayRatingId = prpy_PayRatingId
        LEFT OUTER JOIN PRIntegrityRating ON prtr_IntegrityId = prin_IntegrityRatingId
        WHERE prtr_SubjectId = @prtr_SubjectId
        AND (@prtr_StartDate is null OR @prtr_StartDate <= prtr_Date)
        AND (@prtr_EndDate is null OR @prtr_EndDate >= prtr_Date)
        AND ( ( @prtr_Exception is null) or 
              ( Upper(@prtr_Exception) = 'N' and prtr_Exception is null) or
              ( Upper(@prtr_Exception) = Upper(prtr_Exception) )
            )
        AND ( ( @prtr_DisputeInvolved is null) or 
              ( Upper(@prtr_DisputeInvolved) = 'N' and prtr_DisputeInvolved is null) or
              ( Upper(@prtr_DisputeInvolved) = Upper(prtr_DisputeInvolved) )
            )
        AND (@prtr_ClassificationList is null OR @prtr_ClassificationList = '' OR
             prtr_ResponderId in 
             (select distinct prtr_ResponderId from 
                 (select prtr_ResponderId, prc2_ClassificationId, prcl_Name, highest_level = Left(prcl_Path, charindex(',',prcl_Path)-1) 
                  from PRTradeReport 
              LEFT OUTER JOIN PRCompanyClassification ON prc2_CompanyId = prtr_ResponderId
              LEFT OUTER JOIN PRClassification ON prc2_ClassificationId = prcl_classificationId
                  where prtr_SubjectId = @prtr_SubjectId) ATable
              WHERE highest_level in (select value FROM dbo.Tokenize(@prtr_ClassificationList, ','))
             )
            ) 


    -- check if we have a record
    SELECT @prtr_ReportCount = COUNT(1) FROM @tblTRs 

    if (@prtr_ReportCount > 0)
    BEGIN

        -- Retrieve all the values
        INSERT INTO @tblTradeReportAnalysis (prtr_SubjectId,prtr_ReportCount) VALUES (@prtr_SubjectId,@prtr_ReportCount)
        
        -- Integrity
        SELECT @prtr_Int_Count = COUNT(1) FROM @tblTRs WHERE prtr_integrityid is not null
        UPDATE @tblTradeReportAnalysis SET prtr_Int_Count = @prtr_Int_Count

        IF (@prtr_Int_Count > 0)
        BEGIN
            UPDATE @tblTradeReportAnalysis SET prtr_Int_Avg = trs.intAvg 
            FROM (SELECT intAvg = AVG(prin_weight) FROM @tblTRs WHERE prin_weight is not null) as trs
            UPDATE @tblTradeReportAnalysis SET prtr_Int_XCount = trs.intXCount, prtr_Int_XPct = trs.intXPct 
            FROM (SELECT intXCount = COUNT(1), intXPct = Cast(COUNT(1)AS decimal(6,3))/CAST(@prtr_Int_Count AS decimal(6,3)) FROM @tblTRs WHERE prin_weight = 1) as trs
            UPDATE @tblTradeReportAnalysis SET prtr_Int_XXCount = trs.intXXCount, prtr_Int_XXPct = trs.intXXPct 
            FROM (SELECT intXXCount = COUNT(1), intXXPct = Cast(COUNT(1)AS decimal(6,3))/CAST(@prtr_Int_Count AS decimal(6,3)) FROM @tblTRs WHERE prin_weight = 2) as trs
            UPDATE @tblTradeReportAnalysis SET prtr_Int_XXXCount = trs.intXXXCount, prtr_Int_XXXPct = trs.intXXXPct 
            FROM (SELECT intXXXCount = COUNT(1), intXXXPct = Cast(COUNT(1)AS decimal(6,3))/CAST(@prtr_Int_Count AS decimal(6,3)) FROM @tblTRs WHERE prin_weight = 3) as trs
            UPDATE @tblTradeReportAnalysis SET prtr_Int_XXXXCount = trs.intXXXXCount, prtr_Int_XXXXPct = trs.intXXXXPct 
            FROM (SELECT intXXXXCount = COUNT(1), intXXXXPct = Cast(COUNT(1)AS decimal(6,3))/CAST(@prtr_Int_Count AS decimal(6,3)) FROM @tblTRs WHERE prin_weight = 4) as trs
        END
        -- Credit
        SELECT @prtr_Crt_Count = COUNT(1) FROM @tblTRs WHERE prtr_HighCredit is not null
        UPDATE @tblTradeReportAnalysis SET prtr_Credit_Count = @prtr_Crt_Count

        IF (@prtr_Crt_Count > 0)
        BEGIN
            UPDATE @tblTradeReportAnalysis SET prtr_Credit_5MCount = trs.crt5MCount, prtr_Credit_5MPct = trs.crt5MPct 
            FROM (SELECT crt5MCount = COUNT(1), crt5MPct = Cast(COUNT(1)AS decimal(6,3))/CAST(@prtr_Crt_Count AS decimal(6,3)) FROM @tblTRs WHERE prtr_HighCredit = 'A') as trs
            UPDATE @tblTradeReportAnalysis SET prtr_Credit_10MCount = trs.crt10MCount, prtr_Credit_10MPct = trs.crt10MPct 
            FROM (SELECT crt10MCount = COUNT(1), crt10MPct = Cast(COUNT(1)AS decimal(6,3))/CAST(@prtr_Crt_Count AS decimal(6,3)) FROM @tblTRs WHERE prtr_HighCredit = 'B') as trs
            UPDATE @tblTradeReportAnalysis SET prtr_Credit_50MCount = trs.crt50MCount, prtr_Credit_50MPct = trs.crt50MPct 
            FROM (SELECT crt50MCount = COUNT(1), crt50MPct = Cast(COUNT(1)AS decimal(6,3))/CAST(@prtr_Crt_Count AS decimal(6,3)) FROM @tblTRs WHERE prtr_HighCredit = 'C') as trs
            UPDATE @tblTradeReportAnalysis SET prtr_Credit_75MCount = trs.crt75MCount, prtr_Credit_75MPct = trs.crt75MPct 
            FROM (SELECT crt75MCount = COUNT(1), crt75MPct = Cast(COUNT(1)AS decimal(6,3))/CAST(@prtr_Crt_Count AS decimal(6,3)) FROM @tblTRs WHERE prtr_HighCredit = 'D') as trs
            UPDATE @tblTradeReportAnalysis SET prtr_Credit_100MCount = trs.crt100MCount, prtr_Credit_100MPct = trs.crt100MPct 
            FROM (SELECT crt100MCount = COUNT(1), crt100MPct = Cast(COUNT(1)AS decimal(6,3))/CAST(@prtr_Crt_Count AS decimal(6,3)) FROM @tblTRs WHERE prtr_HighCredit = 'E') as trs
            UPDATE @tblTradeReportAnalysis SET prtr_Credit_250MCount = trs.crt250MCount, prtr_Credit_250MPct = trs.crt250MPct 
            FROM (SELECT crt250MCount = COUNT(1), crt250MPct = Cast(COUNT(1)AS decimal(6,3))/CAST(@prtr_Crt_Count AS decimal(6,3)) FROM @tblTRs WHERE prtr_HighCredit = 'F') as trs
        END

        -- PAY 
        SELECT @prtr_Pay_Count = COUNT(1) FROM @tblTRs WHERE prtr_payratingid is not null
        UPDATE @tblTradeReportAnalysis SET prtr_Pay_Count = @prtr_Pay_Count

        IF (@prtr_Pay_Count > 0)
        BEGIN
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
            DECLARE @MedianNumeric decimal(6,3)
            IF (@prtr_Pay_Count = 1)
            BEGIN
                SELECT @MedianNumeric = convert(decimal(6,3),prpy_weight) FROM @tblTRs where prtr_payratingid is not null 
            END
            ELSE
            BEGIN
                DECLARE @tblMedian TABLE (cnt int identity(0,1), prtr_payratingid int, prpy_weight decimal(6,3))
                INSERT INTO @tblMedian 
                    SELECT prtr_payratingid, prpy_weight 
                    from @tblTRs 
                    where prtr_payratingid is not null 
                    ORDER BY prpy_weight
                
                DECLARE @CountHalf int
                Select @CountHalf = (Count(1) + (Count(1)%2) ) /2 from @tblMedian
                DECLARE @MedianMax decimal(6,3)
                DECLARE @MedianMin decimal(6,3)
                SELECT @MedianMax = Max(convert(decimal(6,3),prpy_weight)) 
                    FROM @tblMedian
                    WHERE cnt < @CountHalf
                
                SELECT @MedianMin = Min(convert(decimal(6,3),prpy_weight)) 
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
                                    when ROUND(@MedianNumeric,0) = 6 THEN 'AB'
                                    when ROUND(@MedianNumeric,0) = 7 THEN 'A'
                                    when ROUND(@MedianNumeric,0) = 8 THEN 'AA'
                                    else ''
                                end
         
            -- now back to count and % fields
            UPDATE @tblTradeReportAnalysis SET prtr_Pay_AACount = trs.payAACount, prtr_Pay_AAPct = trs.payAAPct 
            FROM (SELECT payAACount = COUNT(1), payAAPct = Cast(COUNT(1)AS decimal(6,3))/CAST(@prtr_Pay_Count AS decimal(6,3)) FROM @tblTRs WHERE prpy_weight = 8) as trs
            UPDATE @tblTradeReportAnalysis SET prtr_Pay_ACount = trs.payACount, prtr_Pay_APct = trs.payAPct 
            FROM (SELECT payACount = COUNT(1), payAPct = Cast(COUNT(1)AS decimal(6,3))/CAST(@prtr_Pay_Count AS decimal(6,3)) FROM @tblTRs WHERE prpy_weight = 7) as trs
            UPDATE @tblTradeReportAnalysis SET prtr_Pay_ABCount = trs.payABCount, prtr_Pay_ABPct = trs.payABPct 
            FROM (SELECT payABCount = COUNT(1), payABPct = Cast(COUNT(1)AS decimal(6,3))/CAST(@prtr_Pay_Count AS decimal(6,3)) FROM @tblTRs WHERE prpy_weight = 6) as trs
            UPDATE @tblTradeReportAnalysis SET prtr_Pay_BCount = trs.payBCount, prtr_Pay_BPct = trs.payBPct 
            FROM (SELECT payBCount = COUNT(1), payBPct = Cast(COUNT(1)AS decimal(6,3))/CAST(@prtr_Pay_Count AS decimal(6,3)) FROM @tblTRs WHERE prpy_weight = 5) as trs
            UPDATE @tblTradeReportAnalysis SET prtr_Pay_CCount = trs.payCCount, prtr_Pay_CPct = trs.payCPct 
            FROM (SELECT payCCount = COUNT(1), payCPct = Cast(COUNT(1)AS decimal(6,3))/CAST(@prtr_Pay_Count AS decimal(6,3)) FROM @tblTRs WHERE prpy_weight = 4) as trs
            UPDATE @tblTradeReportAnalysis SET prtr_Pay_DCount = trs.payDCount, prtr_Pay_DPct = trs.payDPct 
            FROM (SELECT payDCount = COUNT(1), payDPct = Cast(COUNT(1)AS decimal(6,3))/CAST(@prtr_Pay_Count AS decimal(6,3)) FROM @tblTRs WHERE prpy_weight = 3) as trs
            UPDATE @tblTradeReportAnalysis SET prtr_Pay_ECount = trs.payECount, prtr_Pay_EPct = trs.payEPct 
            FROM (SELECT payECount = COUNT(1), payEPct = Cast(COUNT(1)AS decimal(6,3))/CAST(@prtr_Pay_Count AS decimal(6,3)) FROM @tblTRs WHERE prpy_weight = 2) as trs
            UPDATE @tblTradeReportAnalysis SET prtr_Pay_FCount = trs.payFCount, prtr_Pay_FPct = trs.payFPct 
            FROM (SELECT payFCount = COUNT(1), payFPct = Cast(COUNT(1)AS decimal(6,3))/CAST(@prtr_Pay_Count AS decimal(6,3)) FROM @tblTRs WHERE prpy_weight = 1) as trs
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
                  FROM PRCompanyClassification 
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
                               FROM PRCompanyClassification 
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
                               FROM PRCompanyClassification 
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
    select @comp_PRHQId = comp_PRHQID
    from Company
    Where comp_companyId = @comp_CompanyId 
    IF (@comp_PRHQId is null OR @comp_PRHQId = -1)
        SET @comp_PRHQId = NULL
    ELSE
        SET @complete_list = convert(varchar,@comp_PRHQId)
    -- add branches of the headquarter
    select @complete_list = coalesce(@complete_list+',','')+ coalesce(convert(varchar,comp_companyid),'')
    from Company
    Where comp_PRHQId = @comp_PRHQId
      and comp_companyid != @comp_CompanyId 
    -- add branches
    select @complete_list = coalesce(@complete_list+',','')+ coalesce(convert(varchar,comp_companyid),'')
    from Company
    Where comp_PRHQId = @comp_CompanyId 
    -- add left side relationships
    select @complete_list = coalesce(@complete_list+',','')+ coalesce(convert(varchar,prcr_RightCompanyId),'')
    from PRCompanyRelationship
    Where prcr_LeftCompanyId = @comp_CompanyId 
      AND prcr_Type in ('27','28','29')
          
    -- add left side relationships
    select @complete_list = coalesce(@complete_list+',','')+ coalesce(convert(varchar,prcr_LeftCompanyId),'')
    from PRCompanyRelationship
    Where prcr_RightCompanyId = @comp_CompanyId 
      AND prcr_Type in ('27','28','29')

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
        SELECT  praa_CompanyId, praa_ARAgingId, praa_ImportedDate, praa_ImportedByUserId, praa_RunDate 
           FROM PRARAging 
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
               count(1), 0,
               sum(praad_Amount0to29),
               sum(praad_Amount30to44),
               sum(praad_Amount45to60), 
               sum(praad_Amount61Plus)
          FROM PRARAgingDetail 
          JOIN @tblARAging  ON praa_ARAgingId = praad_ARAgingId 
          GROUP BY praad_ARAgingId
    -- we don't want any NULLS in our table or calculations will fail
    UPDATE @tblDetail SET
    	praad_count = COALESCE(praad_count,0),
    	praad_Amount0to29 = COALESCE(praad_Amount0to29,0),
    	praad_Amount30to44 = COALESCE(praad_Amount30to44,0),
    	praad_Amount45to60 = COALESCE(praad_Amount45to60,0),
    	praad_Amount61Plus = COALESCE(praad_Amount61Plus,0)
    
    UPDATE @tblDetail SET praad_Amount = (praad_Amount0to29+praad_Amount30to44+praad_Amount45to60+praad_Amount61Plus)

    -- save these values out to the result table for each row
    UPDATE @tblARAging SET 
           praa_ARAgingDetailCount = praad_count,
           praa_Amount = praad_Amount,
           praa_Amount0to29 = praad_Amount0to29,
           praa_Amount30to44 = praad_Amount30to44,
           praa_Amount45to60 = praad_Amount45to60,
           praa_Amount61Plus = praad_Amount61Plus
    FROM @tblDetail where praa_ARAgingId = praad_ARAgingId  

    -- Now calculate the Totals owed for each bucket; these are for the page summary totals
    DECLARE @praa_TotalAmount numeric(20,2)
    DECLARE @praa_TotalAmount0to29 numeric(20,2) 
    DECLARE @praa_TotalAmount30to44 numeric(20,2) 
    DECLARE @praa_TotalAmount45to60 numeric(20,2)  
    DECLARE @praa_TotalAmount61Plus numeric(20,2) 
    
    SELECT
           @praa_TotalAmount = SUM(praad_Amount),
           @praa_TotalAmount0to29 = SUM(praad_Amount0to29), 
           @praa_TotalAmount30to44 = SUM(praad_Amount30to44), 
           @praa_TotalAmount45to60 = SUM(praad_Amount45to60), 
           @praa_TotalAmount61Plus = SUM(praad_Amount61Plus)
    FROM @tblDetail  

    UPDATE @tblARAging SET 
           praa_TotalAmount = @praa_TotalAmount,
           praa_TotalAmount0to29 = @praa_TotalAmount0to29,
           praa_TotalAmount30to44 = @praa_TotalAmount30to44,
           praa_TotalAmount45to60 = @praa_TotalAmount45to60,
           praa_TotalAmount61Plus = @praa_TotalAmount61Plus
    FROM @tblDetail  

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
        FROM @tblDetail  
        UPDATE @tblARAging SET 
           praa_AmountPct = (praa_Amount0to29Pct+praa_Amount30to44Pct+praa_Amount45to60Pct+praa_Amount61PlusPct)
        FROM @tblDetail  
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
  SELECT  @RetValue = Coalesce(@RetValue + ',', '') + prrn_name
    FROM PRRatingNumeralAssigned
    JOIN PRRatingNumeral ON pran_RatingNumeralId = prrn_RatingNumeralId
    WHERE pran_ratingid = @ratingid
    ORDER BY prrn_Order
  SET @RetValue = rtrim(COALESCE(@RetValue,''))
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
        select @types = Coalesce(@types+',', '') + prcr_Type
        from 
             (select distinct prcr_Type
              from PRCompanyRelationship
              where (prcr_LeftCompanyId = @CompanyId1 and prcr_RightCompanyId = @CompanyId2)
                 OR (prcr_LeftCompanyId = @CompanyId2 and prcr_RightCompanyId = @CompanyId1)
             ) ATable

    RETURN @types
END
GO

/**************************************************************************
    ufn_GetCustomTESOption5:
    
    This function is a single SQL statement that returns a table result set
    listing all the companies ( and associated data) that meet the criteria
    passed in.  This is used to load the fifth option of the Custom TES 
    Request screen.  This started as a much simpler select and then grew
    quite a bit.

**************************************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetCustomTESOption5]') 
            and OBJECTPROPERTY(id, N'IsTableFunction') = 1)
drop Function [dbo].[ufn_GetCustomTESOption5]
GO

CREATE FUNCTION dbo.ufn_GetCustomTESOption5
(
    @SubjectCompanyId int = NULL,
    @StartDate datetime = NULL,
    @EndDate datetime = NULL,
    @RelationshipType varchar(40) = NULL,
    @ListingStatus varchar(40) = NULL
)
RETURNS @tblResults TABLE (
    prte_ResponderCompanyId int,
    comp_Name varchar (500),
    comp_PRListingStatus varchar(40),
    prcr_Types varchar(200),
    prci_City varchar (34),
    prst_Abbreviation varchar(10), 
    prte_DateMAX datetime, 
    prcr_LastUpdatedMAX datetime 
)
AS 
BEGIN
    -- this is a single statement right now; 
    -- if it gets much more complicated, it can be broken out into seperate calls
    INSERT INTO @tblResults 
    SELECT ATable.prte_ResponderCompanyId, 
        comp_Name, custom_captions.capt_us AS comp_PRListingStatus, 
        prcr_Types,
        prci_City, prst_Abbreviation, prte_DateMAX, prcr_LastUpdatedMAX 
    from 
    ( 
      SELECT * FROM 
      (
        SELECT prte_ResponderCompanyId,
          prcr_Types = dbo.ufn_GetCompanyRelationshipsList(@SubjectCompanyId, prte_ResponderCompanyId)
        FROM 
        (
          SELECT distinct prte_ResponderCompanyId = 
            case 
            when prcr_LeftCompanyId = @SubjectCompanyId then prcr_RightCompanyId 
            else prcr_LeftCompanyId 
            end
          FROM PRCompanyRelationship 
          WHERE prcr_LeftCompanyId = @SubjectCompanyId OR prcr_RightCompanyId = @SubjectCompanyId
          AND convert(smallint, prcr_Type) NOT IN (27, 28, 29, 30, 31, 32) 
        ) AllRelationships
      ) FilterRelationships
      WHERE (@RelationshipType IS NULL OR CHARINDEX(@RelationshipType, prcr_Types) > 0) 
    ) ATable 
    INNER JOIN Company ON prte_ResponderCompanyId = comp_CompanyId 
                AND (comp_PRReceiveTES = 'Y')
	            AND comp_PRListingStatus in ('L','H','N1','N2') 
                AND (@ListingStatus IS NULL OR comp_PRListingStatus = @ListingStatus)
    INNER JOIN PRCity ON comp_PRListingCityId = prci_CityId
    INNER JOIN PRState ON prci_StateId = prst_StateId
    INNER JOIN custom_captions ON comp_PRListingStatus = capt_code AND capt_family = 'comp_PRListingStatus'
    INNER JOIN 
    (
        Select prte_ResponderCompanyId, prte_DateMAX = MAX(prte_Date) 
        from PRTES 
        INNER JOIN PRTESDetail ON prte_TESId = prt2_TESId
                        AND prt2_SubjectCompanyId = @SubjectCompanyId
        Group By prte_ResponderCompanyId
    )LastTESDate ON ATable.prte_ResponderCompanyId = LastTESDate.prte_ResponderCompanyId
    INNER JOIN 
    ( 
      SELECT * FROM 
      (
        SELECT RelatedCompanyId, prcr_LastUpdatedMAX = MAX(prcr_LastReportedDate)
            FROM (
            SELECT RelatedCompanyId = prcr_RightCompanyId, prcr_LastReportedDate 	
                FROM PRCompanyrelationship 
                WHERE (prcr_LeftCompanyId = @SubjectCompanyId)
            UNION
            SELECT RelatedCompanyId = prcr_LeftCompanyId, prcr_LastReportedDate
                FROM PRCompanyrelationship 
                WHERE (prcr_RightCompanyId = @SubjectCompanyId)
            ) UniqueRelated 
        GROUP BY RelatedCompanyId    
      ) UniqueLastUpdated
      WHERE (@StartDate IS NULL OR @StartDate <= prcr_LastUpdatedMAX )
        AND (@EndDate IS NULL OR @EndDate >= prcr_LastUpdatedMAX )
    ) LASTUPDATED ON ATAble.prte_ResponderCompanyId = RelatedCompanyId
    

    RETURN
END
GO

/**************************************************************************
    ufn_GetTESEligibleCompanies:
    
    This function retrieves all companies that are eligible to be Responders
    (prte_ResponderCompanyId) for TES forms.  The returned table will be
    ordered by "Tier" allowing for Select TOP calls to extract the necessary 
    companies without further ordering.
    
RAO:  I DO NOT BELIEVE THIS FUNCTION IS USED; I BELIEVE IT BECAME [ufn_GetCustomTESOption5]
**************************************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetTESEligibleCompanies]') 
            and OBJECTPROPERTY(id, N'IsTableFunction') = 1)
drop Function [dbo].[ufn_GetTESEligibleCompanies]
GO

CREATE FUNCTION dbo.ufn_GetTESEligibleCompanies
(
    @SubjectCompanyId int = NULL,
    @StartDate datetime = NULL,
    @EndDate datetime = NULL,
    @RelationshipType varchar(40) = NULL,
    @ListingStatus varchar(40) = NULL
)
RETURNS @tblResults TABLE (
    prte_ResponderCompanyId int,
    comp_Name varchar (500),
    comp_PRListingStatus varchar(40),
    prcr_Types varchar(200),
    prci_City varchar (34),
    prst_Abbreviation varchar(10), 
    prte_DateMAX datetime, 
    prcr_LastUpdatedMAX datetime 
)
AS 
BEGIN
    -- this is a single statement right now; 
    -- if it gets much more complicated, it can be broken out into seperate calls
    INSERT INTO @tblResults 
    SELECT ATable.prte_ResponderCompanyId, 
        comp_Name, comp_PRListingStatus, 
        prcr_Types,
        prci_City, prst_Abbreviation, prte_DateMAX, prcr_LastUpdatedMAX 
    from 
    ( 
      SELECT * FROM 
      (
        SELECT prte_ResponderCompanyId,
          prcr_Types = dbo.ufn_GetCompanyRelationshipsList(@SubjectCompanyId, prte_ResponderCompanyId)
        FROM 
        (
          SELECT distinct prte_ResponderCompanyId = 
            case 
            when prcr_LeftCompanyId = @SubjectCompanyId then prcr_RightCompanyId 
            else prcr_LeftCompanyId 
            end
          FROM PRCompanyRelationship 
          WHERE prcr_LeftCompanyId = @SubjectCompanyId OR prcr_RightCompanyId = @SubjectCompanyId
          AND convert(smallint, prcr_Type) NOT IN (27, 28, 29, 30, 31, 32) 
        ) AllRelationships
      ) FilterRelationships
      WHERE (@RelationshipType IS NULL OR CHARINDEX(@RelationshipType, prcr_Types) > 0) 
    ) ATable 
    JOIN Company ON prte_ResponderCompanyId = comp_CompanyId 
                AND (comp_PRReceiveTES = 'Y')
                AND (@ListingStatus IS NULL OR comp_PRListingStatus = @ListingStatus)
    Left OUTER JOIN PRCity ON comp_PRListingCityId = prci_CityId
    Left OUTER JOIN PRState ON prci_StateId = prst_StateId
    JOIN 
    (
        Select prte_ResponderCompanyId, prte_DateMAX = MAX(prte_Date) 
        from PRTES 
        JOIN PRTESDetail ON prte_TESId = prt2_TESId
                        AND prt2_SubjectCompanyId = @SubjectCompanyId
        Group By prte_ResponderCompanyId
    )LastTESDate ON ATable.prte_ResponderCompanyId = LastTESDate.prte_ResponderCompanyId
    JOIN 
    ( 
      SELECT * FROM 
      (
        SELECT RelatedCompanyId, prcr_LastUpdatedMAX = MAX(prcr_LastReportedDate)
            FROM (
            SELECT RelatedCompanyId = prcr_RightCompanyId, prcr_LastReportedDate 	
                FROM PRCompanyrelationship 
                WHERE (prcr_LeftCompanyId = @SubjectCompanyId)
            UNION
            SELECT RelatedCompanyId = prcr_LeftCompanyId, prcr_LastReportedDate
                FROM PRCompanyrelationship 
                WHERE (prcr_RightCompanyId = @SubjectCompanyId)
            ) UniqueRelated 
        GROUP BY RelatedCompanyId    
      ) UniqueLastUpdated
      WHERE (@StartDate IS NULL OR @StartDate <= prcr_LastUpdatedMAX )
        AND (@EndDate IS NULL OR @EndDate >= prcr_LastUpdatedMAX )
    ) LASTUPDATED ON ATAble.prte_ResponderCompanyId = RelatedCompanyId
    

    RETURN
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
    DECLARE @comp_InvestigationMethodGroup varchar(1) 
    DECLARE @cnt_PayReports_3Months int
    DECLARE @cnt_PayReports_12Months int
    DECLARE @cnt_IntegrityReports int
    DECLARE @RequiredReportCount int
    
    SELECT @comp_InvestigationMethodGroup = comp_PRInvestigationMethodGroup
    FROM  company 
    WHERE comp_Companyid = @prbs_CompanyId

    SET @RequiredReportCount = null
    IF (@comp_InvestigationMethodGroup = 'A')
    BEGIN
        select @cnt_PayReports_3Months = count(1) 
        from PRTradeReport  
        where prtr_PayRatingId is not null 
          AND prtr_Date > DateAdd(Month, -3, @prbs_Date) 
          AND prtr_SubjectId = @prbs_CompanyId 

        select @cnt_PayReports_12Months = count(1) 
        from PRTradeReport  
        where prtr_PayRatingId is not null 
          AND prtr_Date > DateAdd(Month, -12, @prbs_Date) 
          AND prtr_SubjectId = @prbs_CompanyId 
        
        SET @RequiredReportCount = 0
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
        select @cnt_IntegrityReports = count(1) 
        from PRTradeReport  
        where prtr_IntegrityId is not null 
          AND prtr_Date > DateAdd(Month, -3, @prbs_Date)
          AND prtr_SubjectId = @prbs_CompanyId 
        
        SET @RequiredReportCount = 0
        IF (@cnt_IntegrityReports < 6)
            SET @RequiredReportCount = 6 - @cnt_IntegrityReports
    END

    -- do not set required to more than 20
    -- TODO Pull this M value (20 from a the PRGeneral Table as a configurable value
    IF (@RequiredReportCount > 20)
        SET @RequiredReportCount = 20

    -- multiple times 3 due to attrition
    SET @RequiredReportCount = @RequiredReportCount * 3

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
    Insert Into @tblReturn
        SELECT 
            prcca_CompanyCommodityAttributeId, prcca_CommodityId, prcca_GrowingMethodId, prcca_AttributeId,
            prcca_Publish, prcca_PublishWithGM, 
            case 
              when prcca_Sequence is not null then prcca_Sequence
              else 99999
            end, 
            prcca_PublishedDisplay
        FROM PRCompanyCommodityAttribute
        WHERE prcca_CompanyId = @CompanyId

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
	SELECT @Price = CONVERT(int, capt_us)
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

CREATE FUNCTION dbo.ufn_HasAvailableUnits(@CompanyID int, @UsageType varchar(40))
RETURNS int  AS  
BEGIN 
		
	DECLARE @HasUnits int
	DECLARE @Price int

	SET @Price = dbo.ufn_GetUsageTypePrice(@UsageType);

	IF @Price = 0 BEGIN
		SET @HasUnits = 1
	END ELSE BEGIN

		SELECT @HasUnits = 1
		  FROM PRServiceUnitAllocation
		 WHERE GETDATE() BETWEEN prun_StartDate AND prun_ExpirationDate
		   AND prun_CompanyID = @CompanyID
		HAVING SUM(prun_UnitsRemaining) >= @Price;

		IF @HasUnits IS NULL SET @HASUnits=0
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
	DECLARE @RemainingUnits int
		
	SELECT @RemainingUnits = SUM(prun_UnitsRemaining) 
      FROM PRServiceUnitAllocation
     WHERE GETDATE() BETWEEN prun_StartDate AND prun_ExpirationDate
       AND prun_CompanyID = @CompanyID;

	IF @RemainingUnits IS NULL SET @RemainingUnits=0

	RETURN @RemainingUnits
END
GO


/**
Returns the number of units the specified company has available
for the specified service.
**/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetConsumedUnitsForService]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_GetConsumedUnitsForService]
GO

CREATE FUNCTION dbo.ufn_GetConsumedUnitsForService(@CompanyID int, @ServiceID int)
RETURNS int  AS  
BEGIN 
	DECLARE @RemainingUnits int
	DECLARE @TotalUnits int
		
	SELECT @TotalUnits = SUM(prun_UnitsAllocated),
		   @RemainingUnits = SUM(prun_UnitsRemaining) 
      FROM PRServiceUnitAllocation
     WHERE GETDATE() BETWEEN prun_StartDate AND prun_ExpirationDate
       AND prun_CompanyID = @CompanyID
       AND prun_ServiceID = @ServiceID

	IF @RemainingUnits IS NULL SET @RemainingUnits=0

	RETURN @TotalUnits - @RemainingUnits
END
GO


/**
Determines if the specified Company and ServiceUnitAllocation exists
and has not yet been reconcilled.  A value of zero '0' means valid.
Otherwise a descriptive message is returned.  Designed for use with
the BBS real-time interface.
**/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_IsOnlineAllocationReconciliationValid]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_IsOnlineAllocationReconciliationValid]
GO

CREATE FUNCTION dbo.ufn_IsOnlineAllocationReconciliationValid(@CompanyID int, @PRServiceUnitAllocationID int)
RETURNS varchar(100)  AS  
BEGIN 
	DECLARE @Return varchar(100)

	DECLARE @Exists varchar(1)
	DECLARE @ServiceID int

	SELECT @Exists = 'x',
           @ServiceID = prun_ServiceID
      FROM PRServiceUnitAllocation
     WHERE prun_ServiceUnitAllocationID = @PRServiceUnitAllocationID
       AND prun_CompanyID = @CompanyID
       AND prun_SourceCode = 'O';

	IF @Exists IS NULL BEGIN
		SET @Return = 'Service Unit Allocation Not Found.'
	END ELSE BEGIN
		IF @ServiceID IS NOT NULL BEGIN
			SET @Return = 'Service Unit Allocation Already Reconcilled.'
		END ELSE BEGIN
			SET @Return = '0'
		END 
	END

	RETURN @Return
END
GO




/**
Returns a dataset for the AUS listing on the website.  This allows the
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
INSERT INTO @AUSListing (
	prau_AUSID,
	DisplayOnHomePage,
	BBID,
	TRADENAME,
	comp_PRIndustryType,
	CITY,
	STATE,
	COUNTRY,
	HQBR)
SELECT prau_AUSID,
	prau_ShowOnHomePage,
	prau_MonitoredCompanyID,
    comp_PRCorrTradestyle,
	comp_PRIndustryType,
    prci_City,
	prst_Abbreviation,
    prcn_Country,
	CASE WHEN comp_PRHQId > 0 THEN 'B' ELSE 'H' END
  FROM PRAUS 
	   INNER JOIN Company on prau_MonitoredCompanyID = comp_CompanyID
       INNER JOIN PRCity on comp_PRListingCityID = prci_CityID
       INNER JOIN PRState on prci_StateID = prst_StateID
       INNER JOIN PRCountry on prst_CountryID = prcn_CountryID
 WHERE prau_Deleted IS NULL
   AND comp_Deleted IS NULL
   AND (comp_PRListingStatus = 'L' OR comp_PRListingStatus = 'N3')
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


-- Go get our last financial date
UPDATE @AUSListing
   SET LastFinancialDate = prfs_StatementDate
  FROM @AUSListing T1 
       INNER JOIN PRFinancial on BBID = prfs_CompanyId
       INNER JOIN Company on BBID = comp_CompanyID      
 WHERE prfs_Deleted IS NULL
  AND  prfs_Publish = 'Y'
  AND  comp_PRConfidentialFS IS NULL;

RETURN
END
Go


/**
Returns the default email address of the specified  person.
**/
If Exists (Select name from sysobjects where name = 'ufn_GetPersonDefaultEmail' and type in (N'FN', N'IF', N'TF')) Drop Function dbo.ufn_GetPersonDefaultEmail
Go

CREATE FUNCTION dbo.ufn_GetPersonDefaultEmail(@PersonID int)  
RETURNS varchar(255) AS  
BEGIN 
	DECLARE @Email varchar(255)

	SELECT @Email = emai_EmailAddress
      FROM Person INNER JOIN Email on pers_PersonID = emai_PersonID
	 WHERE pers_PersonID = @PersonID
       AND emai_PRDefault = 'Y';

	RETURN @Email
END
Go


/**
Returns the default fax of the specified  person.
**/
If Exists (Select name from sysobjects where name = 'ufn_GetPersonDefaultFax' and type in (N'FN', N'IF', N'TF')) Drop Function dbo.ufn_GetPersonDefaultFax
Go

CREATE FUNCTION dbo.ufn_GetPersonDefaultFax(@PersonID int)  
RETURNS varchar(255) AS  
BEGIN 
	DECLARE @Fax varchar(255)

	SELECT @Fax = dbo.ufn_FormatPhone(phon_CountryCode, phon_AreaCode, phon_Number, phon_PRExtension)
      FROM Phone
	 WHERE phon_Default='Y' 
       AND phon_Type='F' 
       AND phon_PersonID = @PersonID;

	RETURN @Fax
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
      FROM Person_Link
     WHERE peli_PersonID = @PersonID
       AND peli_CompanyID = @CompanyID
       AND peli_PRStatus = '1'; -- Active;

	RETURN;
END
Go

/**
Determines if the specified company is eligible to receive a business
report survey.
**/
If Exists (Select name from sysobjects where name = 'ufn_IsEligibleForBRSurvey' and type in (N'FN', N'IF', N'TF')) Drop Function dbo.ufn_IsEligibleForBRSurvey
Go

CREATE FUNCTION dbo.ufn_IsEligibleForBRSurvey(@CompanyID int)  
RETURNS bit AS  
BEGIN 

	DECLARE @Count int

	SELECT @Count = COUNT(1)
	  FROM PRBusinessReportRequest
	 WHERE prbr_RequestingCompanyID = 102030
	   AND MONTH(prbr_CreatedDate) = MONTH(GETDATE());
	
	IF @Count = 0 BEGIN
		RETURN 1
	END 
	
	RETURN 0
END
Go


/**
Determines if the specified company has an active, primary service record.
**/

If Exists (Select name from sysobjects where name = 'ufn_IsActiveMember' and type in (N'FN', N'IF', N'TF')) Drop Function dbo.ufn_IsActiveMember
Go

CREATE FUNCTION [dbo].[ufn_IsActiveMember](@CompanyId int)  
RETURNS bit AS  
BEGIN 

	DECLARE @Count int

	SELECT @Count = COUNT(1)
	  FROM PRService
	 WHERE prse_CompanyID = @CompanyId
	   AND prse_Primary = 'Y'
           AND prse_CancelCode is NULL;
	
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

	SELECT 	@UserID = case
		when @TypeId = 0 then prci_RatingUserId
		when @TypeId = 1 then prci_InsideSalesRepId
		when @TypeId = 2 then prci_FieldSalesRepId
		when @TypeId = 3 then prci_ListingSpecialistId
		when @TypeId = 4 then prci_CustomerServiceId
		else NULL
	  end
	  FROM Company 
	  INNER JOIN PRCity ON PRCi_CityID = Comp_PRListingCityID
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

-- RSH 8/11/06
-- See if membership allocation already exists for the current year
-- for the specified ServiceID.
If Exists (Select name from sysobjects where name = 'ufn_CurrentAllocationId' and type in (N'FN', N'IF', N'TF')) Drop Function dbo.ufn_CurrentAllocationId
Go

CREATE FUNCTION [dbo].[ufn_CurrentAllocationId](@ServiceID int)
RETURNS int  AS  
BEGIN 
		
	DECLARE @AllocationId int

	SELECT @AllocationId = prun_ServiceUnitAllocationId from PRServiceUnitAllocation
	WHERE prun_ServiceId = @ServiceID
	AND prun_AllocationTypeCode = 'M'
	AND prun_StartDate = '1/1/' + LTRIM(STR(DATEPART(year, GETDATE())))

	IF @AllocationId IS NULL SET @AllocationId = -1

	RETURN @AllocationId
END
Go


/**
Builds the item text for Credit Sheet Items EBB Update
**/
If Exists (Select name from sysobjects where name = 'ufn_GetItem' and type in (N'FN', N'IF', N'TF')) Drop Function dbo.ufn_GetItem
Go

CREATE FUNCTION [dbo].[ufn_GetItem] (
	@prcs_CreditSheetId int, 
    @FormattingStyle tinyint = 0, -- 0: <BR> 1: CHR(10) 2: CHR(10 & 13),
    @IncludeBBHeader bit,
    @LineSize int
)
RETURNS varchar(6000)
AS
BEGIN
    DECLARE @RetValue varchar(6000)

    DECLARE @prcs_CompanyId int
    DECLARE @prcs_Tradestyle varchar(420)
    DECLARE @prcs_Parenthetical varchar(1000)
    DECLARE @prcs_Numeral varchar(75)   
    DECLARE @prcs_Change varchar(4000)
    DECLARE @prcs_RatingChangeVerbiage varchar(1000)
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
      FROM PRCreditSheet
	 WHERE prcs_CreditSheetId = @prcs_CreditSheetId;

	IF (@IncludeBBHeader = 1) BEGIN
		SET @RetValue =  @Indent2 + 'BB #' + Convert(varchar(15), @prcs_CompanyId)

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

	-- This code makes some invalid assumptions.  It always adds a line break to the 
	-- @RetVal without checking to see if @RetVal has any data.  In other words, it 
	-- assumes it has values.  Modified it to check to see if it has data first.
    IF @prcs_Change IS NOT NULL
	BEGIN
		IF (LEN(@RetValue) > 0) BEGIN
			SET @RetValue = @RetValue + @LineBreakChar
		END
		SET @RetValue = @RetValue + 
         COALESCE(dbo.ufn_indentListingBlock(
		 dbo.ufn_ApplyListingLineBreaks3(@prcs_Change,@LineBreakChar, @LineSize),
         @LineBreakChar, @Indent2, 0), '') 
	END

    IF @prcs_RatingValue IS NOT NULL
	BEGIN
		IF (LEN(@RetValue) > 0) BEGIN
			SET @RetValue = @RetValue + @LineBreakChar
		END

		SET @RetValue = @RetValue + 
         dbo.ufn_indentListingBlock(
		 dbo.ufn_ApplyListingLineBreaks3(COALESCE(@prcs_RatingChangeVerbiage, '') 
	      + ' ... ' + @prcs_RatingValue, @LineBreakChar, @LineSize),
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
	
	IF (@FormattingStyle = 0) BEGIN
		SET @RetValue = REPLACE(@RetValue, '<B>', '&lg;b&gt;')
	END ELSE BEGIN -- remove Mac bold tags  
		SET @RetValue = REPLACE(@RetValue,'<B>','')
	END

	-- change line breaks and spaces as appropriate for formatting style
	IF (@FormattingStyle = 0) BEGIN
		SET @RetValue = REPLACE(@RetValue, @LineBreakChar, '<BR>')
		SET @RetValue = REPLACE(@RetValue, @Space, '&nbsp;')
	END ELSE IF (@FormattingStyle = 2) BEGIN
		SET @RetValue = REPLACE(@RetValue, @LineBreakChar, CHAR(13)+CHAR(10))
        END

    RETURN @RetValue
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
	  FROM PRBusinessEvent
	 WHERE prbe_BusinessEventTypeID = @BusinessEventTypeID
	   AND prbe_CompanyID = @CompanyID;
END ELSE BEGIN
	SELECT @EventDate = MAX(prbe_EffectiveDate)
	  FROM PRBusinessEvent
	 WHERE prbe_BusinessEventTypeID = @BusinessEventTypeID
	   AND prbe_CompanyID = @CompanyID;
END


IF @EventDate IS NULL BEGIN
	IF @ReturnIfNotFound = 1 BEGIN
		SELECT @EventDate = MIN(prbe_EffectiveDate)
		  FROM PRBusinessEvent
		 WHERE prbe_CompanyID = @CompanyID;
	END

	IF @ReturnIfNotFound = 2 BEGIN
		SELECT @EventDate = MAX(prbe_EffectiveDate)
		  FROM PRBusinessEvent
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
	SET @Divesture = dbo.ufn_GetBusinessEventDate(@CompanyID, 11	, 1, 3, @DefaultDate);
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
	  FROM Address
		   INNER JOIN Address_Link on addr_AddressID = adli_AddressID
		   INNER JOIN PRCity ON addr_PRCityID = prci_CityID
	 WHERE prci_SalesTerritory = @SalesTerritory
	   AND addr_PRPublish = 'Y'
	   AND adli_Type = 'PH';


	-- Go get those Companies that do not have a known address,
	-- but whose listing city is in our territory.
	INSERT INTO @SelectedCompanyIDs (CompanyID)
	SELECT comp_CompanyID
	  FROM Company
		   INNER JOIN PRCity ON comp_PRListingCityID = prci_CityID
	 WHERE prci_SalesTerritory = @SalesTerritory
	   AND comp_CompanyID NOT IN (SELECT DISTINCT adli_CompanyID
									FROM Address_Link);

	-- Go get those companies that have addresses in our territory,
    -- that we don't already have, and that don't a published physical
    -- address in another territory.
	INSERT INTO @SelectedCompanyIDs (CompanyID)
	SELECT DISTINCT adli_CompanyID
	  FROM Address
		   INNER JOIN Address_Link on addr_AddressID = adli_AddressID
		   INNER JOIN PRCity ON addr_PRCityID = prci_CityID
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
  FROM Address
	   INNER JOIN Address_Link on addr_AddressID = adli_AddressID
	   INNER JOIN PRCity ON addr_PRCityID = prci_CityID
  WHERE addr_PRPublish = 'Y'
  AND adli_Type = 'PH' AND adli_CompanyId = @CompanyId

IF @SalesTerritory IS NULL BEGIN
	-- If no addresses, get territory from listing city 
	IF @CompanyId NOT IN (SELECT DISTINCT adli_CompanyID FROM Address_Link) BEGIN
		SELECT @SalesTerritory = prci_SalesTerritory
		  FROM Company
		   INNER JOIN PRCity ON comp_PRListingCityID = prci_CityID
		  WHERE comp_CompanyId = @CompanyId
	END ELSE BEGIN
	-- otherwise, get territory from first address city
		SELECT TOP 1 @SalesTerritory = prci_SalesTerritory
		FROM Address
			INNER JOIN Address_Link on addr_AddressID = adli_AddressID
				INNER JOIN PRCity ON addr_PRCityID = prci_CityID
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

	SET	@UserID = CASE @TypeId
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

	SELECT @SurveyPersonID = capt_US
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
 	  FROM CRM.dbo.Company 
		   INNER JOIN CRM.dbo.PRCity ON PRCi_CityID = Comp_PRListingCityID
           INNER JOIN CRM.dbo.Users ON PRCi_RatingUserID = user_UserID
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
		SELECT @InsideSalesRepIT = capt_US
		  FROM CRM.dbo.custom_captions
		 WHERE capt_family = 'AssignmentUserID' 
		   AND capt_code = 'UnknownAlaCarteOrder';
	END
	
	RETURN @InsideSalesRepIT
END
Go

/* 
   Returns the attention line for the specified role at the specified company
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetAttentionLine]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_GetAttentionLine]
GO
CREATE FUNCTION [dbo].[ufn_GetAttentionLine](@CompanyId int, @Role varchar(40)) 
RETURNS varchar(44) AS
BEGIN 

DECLARE @AttentionLine as varchar(44)

SELECT @AttentionLine = CRM.dbo.ufn_FormatPerson(pers_FirstName, pers_LastName,
 pers_MiddleName, pers_PRNickname1, pers_Suffix) from Person_Link
INNER JOIN Company on comp_CompanyId = peli_CompanyId
INNER JOIN Person on pers_PersonId = peli_PersonId
WHERE comp_CompanyId = @CompanyId 
 AND (peli_PRRole LIKE '%,' + @Role + ',%'
  OR peli_PROwnershipRole LIKE '%,' + @Role + ',%'
  OR peli_PRRecipientRole LIKE '%,' + @Role + ',%')

if @AttentionLine is not NULL BEGIN
	SET @AttentionLine = 'Attn: ' + @AttentionLine
END

SET @AttentionLine = RTRIM(LEFT(@AttentionLine,44))

RETURN @AttentionLine
END
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetCompanyPhone]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_GetCompanyPhone]
GO
CREATE FUNCTION dbo.ufn_GetCompanyPhone(@CompanyID int,
                                        @DefaultOnly varchar(1) = 'Y',
									    @TypeList varchar(200) = null,
										@GeneralType char(1) = 'P' 
										)  
RETURNS varchar(25) AS  
BEGIN

	-- If we don't have a specific type list, include all of 'em
	IF @TypeList IS NULL 
	BEGIN
		IF (@GeneralType = 'F')
			SET @TypeList = 'F,SF,PF'
		else
		begin
			SELECT @TypeList = Coalesce(@TypeList + ',','') + RTRIM(capt_code) from custom_captions 
			where capt_family = 'phon_TypeCompany' and capt_code not in ('F', 'SF')
		end
	END
	DECLARE @Return varchar(25)

	SELECT @Return = dbo.ufn_FormatPhone(phon_CountryCode, phon_AreaCode, phon_Number, phon_PRExtension) 
	  FROM Phone 
	 WHERE phon_CompanyId = @CompanyId 
	   AND phon_Default = CASE @DefaultOnly WHEN 'Y' THEN 'Y' ELSE phon_Default END  -- Handles Default
	   AND phon_Type IN (SELECT value FROM dbo.Tokenize(@TypeList, ',')); -- Handles Many Types

	RETURN @Return
	
END
GO



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetCompanyEmail]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_GetCompanyEmail]
GO
CREATE FUNCTION dbo.ufn_GetCompanyEmail(@CompanyID int,
                                        @DefaultOnly varchar(1) = 'Y')
RETURNS varchar(255) AS  
BEGIN

	DECLARE @Return varchar(255)

	SELECT @Return = RTRIM(emai_EmailAddress)
      FROM Email
     WHERE emai_Type = 'E'
       AND emai_CompanyID = @CompanyID
       AND emai_PRDefault = CASE @DefaultOnly WHEN 'Y' THEN 'Y' ELSE emai_PRDefault END;  -- Handles Default

	RETURN @Return
	
END
GO


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
	FROM Person WHERE pers_PersonId = @personid
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
RETURNS decimal(5,2) AS  
BEGIN

	DECLARE @Return decimal(5,2)
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
Returns the default phone of the specified  person.
**/
If Exists (Select name from sysobjects where name = 'ufn_GetPersonDefaultPhone' and type in (N'FN', N'IF', N'TF')) 
	Drop Function dbo.ufn_GetPersonDefaultPhone
Go

CREATE FUNCTION dbo.ufn_GetPersonDefaultPhone(@PersonID int)  
RETURNS varchar(255) AS  
BEGIN 
	DECLARE @Fax varchar(255)

	SELECT @Fax = dbo.ufn_FormatPhone(phon_CountryCode, phon_AreaCode, phon_Number, phon_PRExtension)
      FROM Phone
	 WHERE phon_Default='Y' 
       AND phon_Type <> 'F'
       AND phon_PersonID = @PersonID;

	RETURN @Fax
END
Go

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
If Exists (Select name from sysobjects where name = 'ufn_GetCustomCaptionValue' and type in (N'FN', N'IF', N'TF')) 
	Drop Function dbo.ufn_GetCustomCaptionValue
Go
CREATE FUNCTION [dbo].[ufn_GetCustomCaptionValue](@capt_family varchar(50), @capt_code varchar(50), @DefaultValue varchar(50))
RETURNS varchar(50) 
AS  
BEGIN 
	DECLARE @Return varchar(50)

	SELECT @Return = capt_us
      FROM Custom_Captions 
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

	SELECT @Return = comp_name + ',  ' + cast(comp_companyid as varchar(10)) + ', ' + CityStateCountryShort
      FROM Company 
           INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID 
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
select distinct prtx_Companyid as CompanyId, prtx_CreatedBy as UserId, 'T' as CallType
from PRTransaction 
where prtx_CreatedDate >= @FromDate and prtx_CreatedDate < @ThroughDate
and prtx_NotificationType = 'P'
and prtx_CompanyId is not null

return
end
go


--
--  Returns a formatted attention line for the specified address looking at the linked person
--  or the default attention line.  Note: The text of most default attention lines contain the
--  text 'ATTN:', so we also added it to the formatted one for consistency.
--
If Exists (Select name from sysobjects where name = 'ufn_GetAddressAttentionLine' and type in (N'FN', N'IF', N'TF')) 
	Drop Function dbo.ufn_GetAddressAttentionLine
Go

CREATE FUNCTION [dbo].[ufn_GetAddressAttentionLine](@AddressID int)
RETURNS varchar(500) 
AS  
BEGIN
	DECLARE @AttentionLine varchar(500)

	SELECT @AttentionLine = ISNULL('Attn: ' + dbo.ufn_FormatPerson(Pers_FirstName, Pers_LastName, Pers_MiddleName, Pers_PRNickname1, Pers_Suffix), addr_PRAttentionLineCustom)
	  FROM Address
		   LEFT OUTER JOIN Person ON addr_PRAttentionLinePersonID = pers_PersonID
	 WHERE addr_AddressID = @AddressID

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

