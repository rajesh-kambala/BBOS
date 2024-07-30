USE CRM

--8.3 Release

--***************    BEGIN    AD REFACTORING DATA CONVERSION  *****************************
BEGIN TRANSACTION

DECLARE @Start datetime = GETDATE()

DECLARE @MyTable table (
    ndx int identity(1,1),
	AdCampaignID int,
	AdCampaignType varchar(40)
)

INSERT INTO @MyTable
SELECT pradc_AdCampaignID, pradc_AdCampaignType
  FROM PRAdCampaign
 --WHERE pradc_AdCampaignType IN ('BBOSSlider', 'IA_180x570', 'IA_960x100', 'LPA', 'SA', 'CSG', 'IA', 'PMSHPSQ')

DECLARE @AdCampaignID int, @AdCampaignHeaderID int, @HeaderTypeCode varchar(40), @AdCampaignTypeCode varchar(40)
DECLARE @Count int, @Index int

SELECT @Count = COUNT(1) FROM @MyTable
SET @Index = 0

SET NOCOUNT ON
WHILE (@Index < @Count) BEGIN

	SET @Index = @Index + 1
	SELECT @AdCampaignID = AdCampaignID,
	       @AdCampaignTypeCode = AdCampaignType
	  FROM @MyTable
	 WHERE ndx = @Index

	 EXEC usp_GetNextId 'PRAdCampaignHeader', @AdCampaignHeaderID output

	 SET @HeaderTypeCode = CASE 
							WHEN @AdCampaignTypeCode IN ('BBOSSlider', 'IA_180x570', 'IA_960x100', 'LPA', 'SA', 'CSG', 'IA', 'PMSHPB', 'PMSHPSQ', 'BPBDA') THEN 'D'
							WHEN @AdCampaignTypeCode IN ('BP') THEN 'BP'
							WHEN @AdCampaignTypeCode IN ('KYCD', 'PUB') THEN 'KYC'
						  END

	UPDATE PRAdCampaign
		SET pradc_AdCampaignHeaderID = @AdCampaignHeaderID
	WHERE pradc_AdCampaignID = @AdCampaignID

	DECLARE @cost_sum numeric(24,6) = (SELECT SUM(ISNULL(pradc_Cost,0)) FROM PRAdCampaign WHERE pradc_AdCampaignHeaderID=@AdCampaignHeaderID)
	DECLARE @discount_sum numeric(24,6) = (SELECT SUM(ISNULL(pradc_Discount,0)) FROM PRAdCampaign WHERE pradc_AdCampaignHeaderID=@AdCampaignHeaderID)
	INSERT INTO PRAdCampaignHeader (pradch_AdCampaignHeaderID,pradch_HQID,pradch_CompanyID,pradch_Name,pradch_AltTradeName,pradch_TypeCode,pradch_ApprovedByPersonID,pradch_SoldBy,pradch_SoldDate,pradch_Cost,pradch_Discount,pradch_Renewal,pradch_Terms,pradch_TermsDescription,pradch_CreatedBy,pradch_CreatedDate,pradch_UpdatedBy,pradch_UpdatedDate,pradch_TimeStamp)
			SELECT @AdCampaignHeaderID, pradc_HQID,pradc_CompanyID,pradc_Name,pradc_AltTradeName,@HeaderTypeCode,pradc_ApprovedByPersonID,pradc_SoldBy,pradc_SoldDate,@cost_sum,@discount_sum,pradc_Renewal,pradc_Terms,pradc_TermsDescription, 1, @Start, 1, @Start, @Start
			 FROM PRAdCampaign
			WHERE pradc_AdCampaignID = @AdCampaignID

END

--
--  Set the KYC Guide Edition
--

--SELECT 'UPDATE PRAdCampaign SET pradc_KYCEdition=''' + CAST(YEAR(pradc_EndDate) as varchar(4)) + ''' WHERE pradc_KYCEdition IS NULL AND pradc_AdCampaignID=' + CAST(pradc_AdCampaignID as varchar(10))
--  FROM PRAdCampaign
-- WHERE pradc_AdCampaignType IN ('PUB')

UPDATE PRAdCampaign
   SET pradc_KYCEdition=CAST(YEAR(pradc_EndDate) as varchar(4))
  FROM PRAdCampaignHeader
	   INNER JOIN PRAdCampaign ON pradch_AdCampaignHeaderID = pradc_AdCampaignHeaderID
 WHERE pradch_TypeCode = 'KYC'
   AND pradc_EndDate IS NOT NULL
   AND pradc_KYCEdition IS NULL

SELECT 'UPDATE PRAdCampaign SET pradc_KYCEdition=''' + CAST(YEAR(pradc_EndDate) as varchar(4)) + ''' WHERE pradc_AdCampaignID=' + CAST(pradc_AdCampaignID as varchar(10))
  FROM PRAdCampaign
 WHERE pradc_AdCampaignType IN ('PUB')

--
--  Remove the start/end dates from the print KYC ads.
--
UPDATE PRAdCampaign
       SET pradc_StartDate=NULL,
	       pradc_EndDate=NULL
  FROM PRAdCampaignHeader
	   INNER JOIN PRAdCampaign ON pradch_AdCampaignHeaderID = pradc_AdCampaignHeaderID
 WHERE pradch_TypeCode = 'KYC' AND pradc_AdCampaignType='PUB'


SET NOCOUNT OFF

DECLARE @MyTable2 table (
  ndx int identity(1,1),
	AdCampaignID int,
	BluePrintsEdition varchar(200),
	idx int,
	BPEdition varchar(10),
	AdImageName varchar(200),
	RowNumber int
)

DECLARE @FileCopy table (
	command varchar(2000)
)
DECLARE @LibraryRoot varchar(100)
SELECT @LibraryRoot = parm_value FROM custom_sysparams WITH (NOLOCK) WHERE Parm_Name = 'DocStore'

INSERT INTO @MyTable2
SELECT pradc_AdCampaignID, pradc_BluePrintsEdition, idx, value, pradc_AdImageName, ROW_NUMBER() OVER (ORDER BY value)
  FROM PRAdCampaign
       CROSS APPLY dbo.Tokenize(pradc_BluePrintsEdition, ',')
 WHERE pradc_AdCampaignType = 'BP'
   AND LEN(pradc_BluePrintsEdition) > 8
   AND value <> ''

DECLARE @BPEdition varchar(10), @FirstBPEdition varchar(10), @idx int, @NewAdCampaignID int
DECLARE @AdImageName varchar(200), @NewAdImageName varchar(200), @RowNumber int

SELECT @Count = COUNT(1) FROM @MyTable2
SET @Index = 0

SET NOCOUNT ON
WHILE (@Index < @Count) BEGIN

	SET @Index = @Index + 1
	SELECT @AdCampaignID = AdCampaignID,
	       @idx = idx,
		     @BPEdition = BPEdition,
		     @AdImageName = AdImageName,
				 @RowNumber = RowNumber
	  FROM @MyTable2
	 WHERE ndx = @Index

	 DECLARE @FirstBPRowNumber int = (SELECT MIN(RowNumber) FROM @MyTable2 WHERE AdCampaignID = @AdCampaignID)

	 IF(@RowNumber = @FirstBPRowNumber) BEGIN
	    UPDATE PRAdCampaign
				SET pradc_BluePrintsEdition = SUBSTRING(@BPEdition, 1, 6)
			WHERE pradc_AdCampaignID = @AdCampaignID
	 END ELSE BEGIN

			EXEC usp_GetNextId 'PRAdCampaign', @NewAdCampaignID output

			SET @NewAdImageName = NULL
			IF (@AdImageName IS NOT NULL) BEGIN
				SET @NewAdImageName = SUBSTRING(@AdImageName, 1, LEN(@AdImageName)-4) + '_' + CAST(@idx as varchar(5)) + SUBSTRING(@AdImageName, LEN(@AdImageName)-3, 4)
				INSERT INTO @FileCopy VALUES ('COPY "' + @LibraryRoot + @AdImageName + '" "' + @LibraryRoot  + @NewAdImageName + '"')
			END

			--intentionally put 0 for the cost because these are for ad campaigns that have multiple ads -- the first has the full amount, supplement have $0, and this is not the first BP Edition for this adcampaign
			INSERT INTO PRAdCampaign (pradc_AdCampaignID, pradc_BluePrintsEdition, pradc_AdCampaignHeaderID, pradc_CompanyID, pradc_Name, pradc_AdCampaignType, pradc_AdImageName, pradc_AdSize, pradc_Placement, pradc_Section, pradc_SectionDetails, pradc_Orientation, pradc_Cost, pradc_Discount, pradc_Notes, pradc_CreativeStatus, pradc_PlannedSection, pradc_AdFileCreatedBy, pradc_AdFileUpdatedBy,pradc_CreatedBy,pradc_CreatedDate,pradc_UpdatedBy,pradc_UpdatedDate,pradc_TimeStamp)
			SELECT @NewAdCampaignID, SUBSTRING(@BPEdition, 1, 6), pradc_AdCampaignHeaderID, pradc_CompanyID, pradc_Name, pradc_AdCampaignType, @NewAdImageName, pradc_AdSize, pradc_Placement, pradc_Section, pradc_SectionDetails, pradc_Orientation, 0, pradc_Discount, pradc_Notes, pradc_CreativeStatus, pradc_PlannedSection, pradc_AdFileCreatedBy, pradc_AdFileUpdatedBy,pradc_CreatedBy,pradc_CreatedDate,pradc_UpdatedBy,pradc_UpdatedDate,pradc_TimeStamp
				FROM PRAdCampaign
						WHERE pradc_AdCampaignID = @AdCampaignID
		END
END
SET NOCOUNT OFF

UPDATE PRAdCampaign
   SET pradc_BluePrintsEdition = SUBSTRING(pradc_BluePrintsEdition, 2, 6)
 WHERE pradc_AdCampaignType = 'BP'
   AND LEN(pradc_BluePrintsEdition) = 8

DECLARE @MyTable3 table (
    ndx int identity(1,1),
	AdCampaignID int
)

INSERT INTO @MyTable3
SELECT pradc_AdCampaignID
  FROM PRAdCampaign
 WHERE pradc_AdImageName IS NOT NULL

DECLARE @AdCampaignType varchar(40), @FileTypeCode varchar(40)
DECLARE @AdFileName varchar(500)
DECLARE @NewAdCampaignFileID int

SELECT @Count = COUNT(1) FROM @MyTable3
SET @Index = 0
SET NOCOUNT ON
WHILE (@Index < @Count) BEGIN

	SET @Index = @Index + 1
	SELECT @AdCampaignID = AdCampaignID,
		   @AdCampaignType = pradc_AdCampaignType,
		   @AdFileName = pradc_AdImageName
	  FROM @MyTable3
	       INNER JOIN PRAdCampaign ON AdCampaignID = pradc_AdCampaignID
	 WHERE ndx = @Index

	 SET @FileTypeCode = CASE @AdCampaignType 
				WHEN 'BP' THEN 'PI' 
				WHEN 'PUB' THEN 'PI'
				ELSE 'DI' END
	
	--SELECT @NewAdCampaignFileID, @AdCampaignID, @FileTypeCode, @AdFileName

		EXEC usp_GetNextId 'PRAdCampaignFile', @NewAdCampaignFileID output
		INSERT INTO PRAdCampaignFile (pracf_AdCampaignFileID, pracf_AdCampaignID, pracf_FileTypeCode, pracf_FileName, pracf_Sequence, pracf_Language,pracf_CreatedBy,pracf_CreatedDate,pracf_UpdatedBy,pracf_UpdatedDate,pracf_TimeStamp)
		VALUES  (@NewAdCampaignFileID, @AdCampaignID, @FileTypeCode, @AdFileName, 1, 'E', 1, @Start, 1, @Start, @Start);

END
SET NOCOUNT OFF

/*
SELECT pradc_AdCampaignID, pradc_AdCampaignHeaderID, pradc_BluePrintsEdition, pradc_CompanyID, pradc_HQID, pradc_Name, pradc_AdCampaignType, pradc_AdImageName, pradc_AdSize, pradc_Placement, pradc_Section, pradc_SectionDetails, pradc_Orientation, pradc_Notes, pradc_CreativeStatus, pradc_PlannedSection, pradc_AdFileCreatedBy, pradc_AdFileUpdatedBy,pradc_CreatedBy,pradc_CreatedDate,pradc_UpdatedBy,pradc_UpdatedDate,pradc_TimeStamp
  FROM PRAdCampaign
 WHERE pradc_AdCampaignType = 'BP'
ORDER BY pradc_AdCampaignHeaderID, pradc_AdCampaignID

SELECT *
  FROM PRAdCampaignFile
ORDER BY pracf_AdCampaignID

SELECT *
 FROM @FileCopy
*/ 

--ROLLBACK
COMMIT

GO

--PRKYCCommodity


BEGIN TRANSACTION
	DELETE FROM PRKYCCommodity

	DECLARE @MyTable4 table (
		ndx int identity(1,1),
		ID int, 
		PostTitle varchar(1000),
		CommodityID int,
		Level int,
		HasAd nchar(1)
	)

	INSERT INTO @MyTable4
				SELECT 
					ID,
					prcm_KYCPostTitle,
					prcm_CommodityId,
					prcm_Level,
					NULL
				FROM PRCommodity
					INNER JOIN WordPress.dbo.wp_4_posts wp WITH (NOLOCK) ON prcm_KYCPostTitle = post_title AND post_type = 'KYC' and POST_STATUS = 'publish' AND post_date <= GETDATE()
				WHERE prcm_KYCPostTitle IS NOT NULL;

	--Update HasAd flag
	with toupdate as (
		SELECT mt.*, row_number() over (partition by ID ORDER BY Level ASC) AS seqnum
		FROM @MyTable4 mt
	)
	UPDATE toupdate
		SET HasAd = 'Y'
		FROM toupdate
		WHERE toupdate.seqnum=1;

	--SELECT * FROM @MyTable4 ORDER BY ndx ASC

	DECLARE @KYCCommodityID int
	DECLARE @ID int
	DECLARE @PostTitle varchar(1000)
	DECLARE @CommodityID int
	DECLARE @HasAd nchar(1)
	DECLARE @Count int, @Index int

	SELECT @Count = COUNT(1) FROM @MyTable4

	SET @Index = 0

	SET NOCOUNT ON
	WHILE (@Index < @Count) 
	BEGIN

		SET @Index = @Index + 1
		SELECT @ID = ID,
					 @PostTitle = PostTitle,
					 @CommodityID = CommodityID,
					 @HasAd = HasAd
			FROM @MyTable4
			WHERE ndx = @Index

		EXEC usp_GetNextId 'PRKYCCommodity', @KYCCommodityID output
			
		--SELECT @KYCCommodityID KYCCommodityID, @PublicationArticleID PublicationArticleID, @KYCPostTitle PostTitle, @CommodityID CommodityID
		INSERT INTO PRKYCCommodity(prkycc_KYCCommodityID, prkycc_ArticleID, prkycc_PostName, prkycc_CommodityID, prkycc_HasAd)
			SELECT 
				@KYCCommodityID,
				@ID, 
				@PostTitle,
				@CommodityID,
				@HasAd
	END
	SET NOCOUNT OFF

	SELECT * FROM PRKYCCommodity ORDER BY prkycc_PostName ASC
--ROLLBACK
COMMIT
GO

DECLARE @KYCCommodityID int
EXEC usp_GetNextId 'PRKYCCommodity', @KYCCommodityID output
INSERT INTO PRKYCCommodity (prkycc_KYCCommodityID, prkycc_ArticleID, prkycc_PostName, prkycc_CommodityID, prkycc_HasAd)
VALUES (@KYCCommodityID, 55, 'Sweet Corn', 484, 'Y')

EXEC usp_GetNextId 'PRKYCCommodity', @KYCCommodityID output
INSERT INTO PRKYCCommodity (prkycc_KYCCommodityID, prkycc_ArticleID, prkycc_PostName, prkycc_CommodityID, prkycc_HasAd, prkycc_GrowingMethodID)
VALUES (@KYCCommodityID, 171, 'Tomatoes (greenhouse)', 535, 'Y', 23)

EXEC usp_GetNextId 'PRKYCCommodity', @KYCCommodityID output
INSERT INTO PRKYCCommodity (prkycc_KYCCommodityID, prkycc_ArticleID, prkycc_PostName, prkycc_CommodityID, prkycc_HasAd, prkycc_GrowingMethodID)
VALUES (@KYCCommodityID, 131, 'Peppers (greenhouse)', 505, 'Y', 23)

EXEC usp_GetNextId 'PRKYCCommodity', @KYCCommodityID output
INSERT INTO PRKYCCommodity (prkycc_KYCCommodityID, prkycc_ArticleID, prkycc_PostName, prkycc_CommodityID, prkycc_HasAd, prkycc_GrowingMethodID)
VALUES (@KYCCommodityID, 15, 'Baby Vegetables', 291, 'Y', 17)

EXEC usp_GetNextId 'PRKYCCommodity', @KYCCommodityID output
INSERT INTO PRKYCCommodity (prkycc_KYCCommodityID, prkycc_ArticleID, prkycc_PostName, prkycc_CommodityID, prkycc_HasAd)
VALUES (@KYCCommodityID, 49, 'Christmas Trees', 8, 'Y')

EXEC usp_GetNextId 'PRKYCCommodity', @KYCCommodityID output
INSERT INTO PRKYCCommodity (prkycc_KYCCommodityID, prkycc_ArticleID, prkycc_PostName, prkycc_CommodityID, prkycc_HasAd)
VALUES (@KYCCommodityID, 55, 'Sweet Corn', 487, 'Y')
--DELETE this 2nd sweet corn because it became a dup as Corn was previously renamed -- but need to keep ids in place
DELETE FROM PRKYCCommodity WHERE prkycc_PostName='Sweet Corn' AND prkycc_KYCCommodityID = (SELECT MAX(prkycc_KYCCommodityID) FROM PRKYCCommodity WHERE prkycc_PostName='Sweet Corn')

EXEC usp_GetNextId 'PRKYCCommodity', @KYCCommodityID output
INSERT INTO PRKYCCommodity (prkycc_KYCCommodityID, prkycc_ArticleID, prkycc_PostName, prkycc_CommodityID, prkycc_HasAd)
VALUES (@KYCCommodityID, 4973, 'Rutabagas', 462, 'Y')

EXEC usp_GetNextId 'PRKYCCommodity', @KYCCommodityID output
INSERT INTO PRKYCCommodity (prkycc_KYCCommodityID, prkycc_ArticleID, prkycc_PostName, prkycc_CommodityID, prkycc_HasAd)
VALUES (@KYCCommodityID, 5426, 'Acai', null, 'Y')

EXEC usp_GetNextId 'PRKYCCommodity', @KYCCommodityID output
INSERT INTO PRKYCCommodity (prkycc_KYCCommodityID, prkycc_ArticleID, prkycc_PostName, prkycc_CommodityID, prkycc_HasAd)
VALUES (@KYCCommodityID, 73, 'Fresh Cut Produce', null, 'Y')

GO

--Add 2 more commodities that were previously missing, then process
--them the same as above.  Had to do them last so that the identity fields
--were not thrown off on all the manual spreadsheet mappings to KYCCommodity and WP posts
UPDATE PRCommodity SET prcm_KYCPostTitle='Lychee' WHERE prcm_CommodityCode = 'lychee'
UPDATE PRCommodity SET prcm_KYCPostTitle='Sprouts' WHERE prcm_CommodityCode = 'sprouts'

DECLARE @KYCCommodityID int
EXEC usp_GetNextId 'PRKYCCommodity', @KYCCommodityID output
INSERT INTO PRKYCCommodity (prkycc_KYCCommodityID, prkycc_ArticleID, prkycc_PostName, prkycc_CommodityID, prkycc_HasAd)
VALUES (@KYCCommodityID, 5387, 'Lychee', 44, 'Y')

EXEC usp_GetNextId 'PRKYCCommodity', @KYCCommodityID output
INSERT INTO PRKYCCommodity (prkycc_KYCCommodityID, prkycc_ArticleID, prkycc_PostName, prkycc_CommodityID, prkycc_HasAd)
VALUES (@KYCCommodityID, 5395, 'Sprouts', 44, 'Y')

--Add more with articleid=0 and change BBOS to not link to anything for these (i.e. just placeholders)
EXEC usp_GetNextId 'PRKYCCommodity', @KYCCommodityID output
INSERT INTO PRKYCCommodity (prkycc_KYCCommodityID, prkycc_ArticleID, prkycc_PostName, prkycc_CommodityID, prkycc_HasAd)
VALUES (@KYCCommodityID, 0, 'Broccoli Rabe', 0, 'Y')

EXEC usp_GetNextId 'PRKYCCommodity', @KYCCommodityID output
INSERT INTO PRKYCCommodity (prkycc_KYCCommodityID, prkycc_ArticleID, prkycc_PostName, prkycc_CommodityID, prkycc_HasAd)
VALUES (@KYCCommodityID, 0, 'Cassava', 0, 'Y')

EXEC usp_GetNextId 'PRKYCCommodity', @KYCCommodityID output
INSERT INTO PRKYCCommodity (prkycc_KYCCommodityID, prkycc_ArticleID, prkycc_PostName, prkycc_CommodityID, prkycc_HasAd)
VALUES (@KYCCommodityID, 0, 'Chayote', 0, 'Y')

EXEC usp_GetNextId 'PRKYCCommodity', @KYCCommodityID output
INSERT INTO PRKYCCommodity (prkycc_KYCCommodityID, prkycc_ArticleID, prkycc_PostName, prkycc_CommodityID, prkycc_HasAd)
VALUES (@KYCCommodityID, 0, 'Fennel', 0, 'Y')

EXEC usp_GetNextId 'PRKYCCommodity', @KYCCommodityID output
INSERT INTO PRKYCCommodity (prkycc_KYCCommodityID, prkycc_ArticleID, prkycc_PostName, prkycc_CommodityID, prkycc_HasAd)
VALUES (@KYCCommodityID, 0, 'Malanga', 0, 'Y')

EXEC usp_GetNextId 'PRKYCCommodity', @KYCCommodityID output
INSERT INTO PRKYCCommodity (prkycc_KYCCommodityID, prkycc_ArticleID, prkycc_PostName, prkycc_CommodityID, prkycc_HasAd)
VALUES (@KYCCommodityID, 0, 'Persimmons', 0, 'Y')

EXEC usp_GetNextId 'PRKYCCommodity', @KYCCommodityID output
INSERT INTO PRKYCCommodity (prkycc_KYCCommodityID, prkycc_ArticleID, prkycc_PostName, prkycc_CommodityID, prkycc_HasAd)
VALUES (@KYCCommodityID, 0, 'Prickly Pear', 0, 'Y')

EXEC usp_GetNextId 'PRKYCCommodity', @KYCCommodityID output
INSERT INTO PRKYCCommodity (prkycc_KYCCommodityID, prkycc_ArticleID, prkycc_PostName, prkycc_CommodityID, prkycc_HasAd)
VALUES (@KYCCommodityID, 0, 'Swiss Chard', 0, 'Y')

EXEC usp_GetNextId 'PRKYCCommodity', @KYCCommodityID output
INSERT INTO PRKYCCommodity (prkycc_KYCCommodityID, prkycc_ArticleID, prkycc_PostName, prkycc_CommodityID, prkycc_HasAd)
VALUES (@KYCCommodityID, 0, 'Raspberries & Blackberries', 0, 'Y')

EXEC usp_GetNextId 'PRKYCCommodity', @KYCCommodityID output
INSERT INTO PRKYCCommodity (prkycc_KYCCommodityID, prkycc_ArticleID, prkycc_PostName, prkycc_CommodityID, prkycc_HasAd)
VALUES (@KYCCommodityID, 0, 'Turnips & Rutabagas', 0, 'Y')

--Greenhouse beefsteak tomato to Tomatoes (greenhouse) defect 4534
EXEC usp_GetNextId 'PRKYCCommodity', @KYCCommodityID output
INSERT INTO PRKYCCommodity (prkycc_KYCCommodityID, prkycc_ArticleID, prkycc_PostName, prkycc_CommodityID, prkycc_HasAd, prkycc_GrowingMethodID)
VALUES (@KYCCommodityID, 171, 'Tomatoes (greenhouse)', 1503, NULL, 23)


GO

BEGIN TRANSACTION

	--SELECT * FROM PRAdCampaign WHERE pradc_KYCCommodityID IS NOT NULL

	UPDATE PRAdCampaign 
	SET pradc_KYCCommodityID = prkycc_KYCCommodityID
	FROM PRAdCampaign 
	INNER JOIN PRPublicationArticle ON pradc_PublicationArticleID = prpbar_PublicationArticleID
	INNER JOIN WordPress.dbo.wp_4_posts ON post_name = prpbar_Name AND post_status='publish'
	LEFT OUTER JOIN PRKYCCommodity ON prkycc_PostName = post_name
	WHERE prkycc_HasAd = 'Y'

	--SELECT * FROM PRAdCampaign WHERE pradc_KYCCommodityID IS NULL

--ROLLBACK
COMMIT

GO

--Manually set KYCCommodityID from spreadsheet
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6251 WHERE pradc_AdCampaignID=15368
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6025 WHERE pradc_AdCampaignID=15369
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6059 WHERE pradc_AdCampaignID=15370
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6166 WHERE pradc_AdCampaignID=15371
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6009 WHERE pradc_AdCampaignID=15372
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6142 WHERE pradc_AdCampaignID=15373
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6171 WHERE pradc_AdCampaignID=15374
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6153 WHERE pradc_AdCampaignID=15375
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6073 WHERE pradc_AdCampaignID=15376
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6045 WHERE pradc_AdCampaignID=15377
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6141 WHERE pradc_AdCampaignID=15378
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6141 WHERE pradc_AdCampaignID=15379
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6274 WHERE pradc_AdCampaignID=15380
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6201 WHERE pradc_AdCampaignID=15381
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6073 WHERE pradc_AdCampaignID=15382
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6232 WHERE pradc_AdCampaignID=15383
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6070 WHERE pradc_AdCampaignID=15384
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6257 WHERE pradc_AdCampaignID=15385
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6138 WHERE pradc_AdCampaignID=15386
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6234 WHERE pradc_AdCampaignID=15387
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6171 WHERE pradc_AdCampaignID=15388
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6138 WHERE pradc_AdCampaignID=15389
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6257 WHERE pradc_AdCampaignID=15390
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6201 WHERE pradc_AdCampaignID=15391
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6091 WHERE pradc_AdCampaignID=15392
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6014 WHERE pradc_AdCampaignID=15393
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6153 WHERE pradc_AdCampaignID=15396
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6055 WHERE pradc_AdCampaignID=15397
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6189 WHERE pradc_AdCampaignID=15398
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6055 WHERE pradc_AdCampaignID=15399
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6251 WHERE pradc_AdCampaignID=15400
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6059 WHERE pradc_AdCampaignID=15402
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6099 WHERE pradc_AdCampaignID=15403
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6181 WHERE pradc_AdCampaignID=15404
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6029 WHERE pradc_AdCampaignID=15405
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6234 WHERE pradc_AdCampaignID=15406
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6114 WHERE pradc_AdCampaignID=15407
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6072 WHERE pradc_AdCampaignID=15408
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6037 WHERE pradc_AdCampaignID=15409
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6271 WHERE pradc_AdCampaignID=15410
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6099 WHERE pradc_AdCampaignID=15411
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6222 WHERE pradc_AdCampaignID=15412
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6147 WHERE pradc_AdCampaignID=15413
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6249 WHERE pradc_AdCampaignID=15414
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6181 WHERE pradc_AdCampaignID=15415
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6045 WHERE pradc_AdCampaignID=15416
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6081 WHERE pradc_AdCampaignID=15417
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6142 WHERE pradc_AdCampaignID=15418
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6006 WHERE pradc_AdCampaignID=15419
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6164 WHERE pradc_AdCampaignID=15420
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6037 WHERE pradc_AdCampaignID=15421
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6164 WHERE pradc_AdCampaignID=15422
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6008 WHERE pradc_AdCampaignID=15423
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6125 WHERE pradc_AdCampaignID=15433
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6276 WHERE pradc_AdCampaignID=15435
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6264 WHERE pradc_AdCampaignID=15436
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6276 WHERE pradc_AdCampaignID=15438
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6173 WHERE pradc_AdCampaignID=15440
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6096 WHERE pradc_AdCampaignID=15441
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6025 WHERE pradc_AdCampaignID=15442
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6251 WHERE pradc_AdCampaignID=15443
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6153 WHERE pradc_AdCampaignID=15444
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6195 WHERE pradc_AdCampaignID=15445
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6059 WHERE pradc_AdCampaignID=15446
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6006 WHERE pradc_AdCampaignID=15448
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6029 WHERE pradc_AdCampaignID=15449
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6274 WHERE pradc_AdCampaignID=15451
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6038 WHERE pradc_AdCampaignID=15452
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6096 WHERE pradc_AdCampaignID=15454
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6166 WHERE pradc_AdCampaignID=15460
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6008 WHERE pradc_AdCampaignID=15461
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6141 WHERE pradc_AdCampaignID=15462
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6214 WHERE pradc_AdCampaignID=15463
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6159 WHERE pradc_AdCampaignID=15464
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6264 WHERE pradc_AdCampaignID=15466
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6153 WHERE pradc_AdCampaignID=15519
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6000 WHERE pradc_AdCampaignID=15533
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6189 WHERE pradc_AdCampaignID=15566
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6171 WHERE pradc_AdCampaignID=15578
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6070 WHERE pradc_AdCampaignID=15580
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6171 WHERE pradc_AdCampaignID=15590
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6055 WHERE pradc_AdCampaignID=15595
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6125 WHERE pradc_AdCampaignID=15610
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6201 WHERE pradc_AdCampaignID=15612
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6008 WHERE pradc_AdCampaignID=15618
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6257 WHERE pradc_AdCampaignID=15620
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6201 WHERE pradc_AdCampaignID=15622
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6020 WHERE pradc_AdCampaignID=15624
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6087 WHERE pradc_AdCampaignID=15631
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6091 WHERE pradc_AdCampaignID=15633
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6274 WHERE pradc_AdCampaignID=15635
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6138 WHERE pradc_AdCampaignID=15637
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6073 WHERE pradc_AdCampaignID=15639
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6234 WHERE pradc_AdCampaignID=15641
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6045 WHERE pradc_AdCampaignID=15643
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6251 WHERE pradc_AdCampaignID=15645
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6138 WHERE pradc_AdCampaignID=15651
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6073 WHERE pradc_AdCampaignID=15653
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6232 WHERE pradc_AdCampaignID=15655
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6234 WHERE pradc_AdCampaignID=15657
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6059 WHERE pradc_AdCampaignID=15662
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6276 WHERE pradc_AdCampaignID=15663
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6020 WHERE pradc_AdCampaignID=15669
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6252 WHERE pradc_AdCampaignID=15672
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6222 WHERE pradc_AdCampaignID=15802
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6142 WHERE pradc_AdCampaignID=15803
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6271 WHERE pradc_AdCampaignID=15873
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6037 WHERE pradc_AdCampaignID=15887
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6114 WHERE pradc_AdCampaignID=15899
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6251 WHERE pradc_AdCampaignID=15368

UPDATE PRAdCampaign SET pradc_KYCCommodityID=6277 WHERE pradc_AdCampaignID=15401
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6278 WHERE pradc_AdCampaignID=15432
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6279 WHERE pradc_AdCampaignID=15601
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6279 WHERE pradc_AdCampaignID=15450
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6279 WHERE pradc_AdCampaignID=15439
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6277 WHERE pradc_AdCampaignID=15661
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6278 WHERE pradc_AdCampaignID=15776

--2nd tab of spreadsheet
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6251 WHERE pradc_AdCampaignID=14821
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6096 WHERE pradc_AdCampaignID=11630
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6006 WHERE pradc_AdCampaignID=12411
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6008 WHERE pradc_AdCampaignID=14045
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6008 WHERE pradc_AdCampaignID=12981
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6008 WHERE pradc_AdCampaignID=13542
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6008 WHERE pradc_AdCampaignID=13030
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6008 WHERE pradc_AdCampaignID=13545
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6029 WHERE pradc_AdCampaignID=14546
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6251 WHERE pradc_AdCampaignID=13215
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6276 WHERE pradc_AdCampaignID=12655
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6006 WHERE pradc_AdCampaignID=11906
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6006 WHERE pradc_AdCampaignID=12403
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6008 WHERE pradc_AdCampaignID=14817
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6008 WHERE pradc_AdCampaignID=14638
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6008 WHERE pradc_AdCampaignID=15226
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6008 WHERE pradc_AdCampaignID=14106
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6008 WHERE pradc_AdCampaignID=15617
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6008 WHERE pradc_AdCampaignID=11136
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6008 WHERE pradc_AdCampaignID=11655
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6008 WHERE pradc_AdCampaignID=11155
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6008 WHERE pradc_AdCampaignID=11635
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6008 WHERE pradc_AdCampaignID=11229
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6008 WHERE pradc_AdCampaignID=11230
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6014 WHERE pradc_AdCampaignID=14814
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6014 WHERE pradc_AdCampaignID=11126
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6014 WHERE pradc_AdCampaignID=11663
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6014 WHERE pradc_AdCampaignID=11209
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6014 WHERE pradc_AdCampaignID=12462
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6014 WHERE pradc_AdCampaignID=13544
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6014 WHERE pradc_AdCampaignID=11147
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6024 WHERE pradc_AdCampaignID=14123
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6029 WHERE pradc_AdCampaignID=13517
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6029 WHERE pradc_AdCampaignID=15288
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6029 WHERE pradc_AdCampaignID=14053
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6029 WHERE pradc_AdCampaignID=12412
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6029 WHERE pradc_AdCampaignID=12188
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6029 WHERE pradc_AdCampaignID=12649
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6029 WHERE pradc_AdCampaignID=11176
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6029 WHERE pradc_AdCampaignID=11907
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6029 WHERE pradc_AdCampaignID=14980
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6031 WHERE pradc_AdCampaignID=12758
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6031 WHERE pradc_AdCampaignID=11893
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6031 WHERE pradc_AdCampaignID=12354
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6045 WHERE pradc_AdCampaignID=14107
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6045 WHERE pradc_AdCampaignID=14790
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6045 WHERE pradc_AdCampaignID=11159
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6045 WHERE pradc_AdCampaignID=15162
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6045 WHERE pradc_AdCampaignID=15642
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6045 WHERE pradc_AdCampaignID=11130
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6045 WHERE pradc_AdCampaignID=11132
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6072 WHERE pradc_AdCampaignID=15101
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6085 WHERE pradc_AdCampaignID=13463
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6085 WHERE pradc_AdCampaignID=14050
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6096 WHERE pradc_AdCampaignID=11654
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6096 WHERE pradc_AdCampaignID=11244
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6096 WHERE pradc_AdCampaignID=11245
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6096 WHERE pradc_AdCampaignID=11214
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6096 WHERE pradc_AdCampaignID=11145
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6096 WHERE pradc_AdCampaignID=11683
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6096 WHERE pradc_AdCampaignID=11188
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6099 WHERE pradc_AdCampaignID=14872
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6099 WHERE pradc_AdCampaignID=11150
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6099 WHERE pradc_AdCampaignID=11692
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6099 WHERE pradc_AdCampaignID=15133
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6099 WHERE pradc_AdCampaignID=11201
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6138 WHERE pradc_AdCampaignID=14805
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6138 WHERE pradc_AdCampaignID=14808
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6138 WHERE pradc_AdCampaignID=15650
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6138 WHERE pradc_AdCampaignID=15636
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6158 WHERE pradc_AdCampaignID=12157
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6159 WHERE pradc_AdCampaignID=15313
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6159 WHERE pradc_AdCampaignID=11226
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6166 WHERE pradc_AdCampaignID=12055
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6166 WHERE pradc_AdCampaignID=12611
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6173 WHERE pradc_AdCampaignID=11224
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6173 WHERE pradc_AdCampaignID=13386
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6173 WHERE pradc_AdCampaignID=13902
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6173 WHERE pradc_AdCampaignID=14535
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6173 WHERE pradc_AdCampaignID=13935
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6173 WHERE pradc_AdCampaignID=14828
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6173 WHERE pradc_AdCampaignID=11757
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6173 WHERE pradc_AdCampaignID=11750
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6173 WHERE pradc_AdCampaignID=12231
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6173 WHERE pradc_AdCampaignID=12054
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6173 WHERE pradc_AdCampaignID=11218
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6189 WHERE pradc_AdCampaignID=14819
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6189 WHERE pradc_AdCampaignID=15565
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6189 WHERE pradc_AdCampaignID=11753
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6189 WHERE pradc_AdCampaignID=13375
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6189 WHERE pradc_AdCampaignID=11234
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6189 WHERE pradc_AdCampaignID=13933
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6226 WHERE pradc_AdCampaignID=11219
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6232 WHERE pradc_AdCampaignID=14801
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6232 WHERE pradc_AdCampaignID=15654
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6232 WHERE pradc_AdCampaignID=11748
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6232 WHERE pradc_AdCampaignID=14239
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6251 WHERE pradc_AdCampaignID=11597
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6251 WHERE pradc_AdCampaignID=11181
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6251 WHERE pradc_AdCampaignID=11599
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6251 WHERE pradc_AdCampaignID=11598
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6251 WHERE pradc_AdCampaignID=13947
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6251 WHERE pradc_AdCampaignID=13725
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6251 WHERE pradc_AdCampaignID=14507
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6251 WHERE pradc_AdCampaignID=15142
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6251 WHERE pradc_AdCampaignID=13924
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6251 WHERE pradc_AdCampaignID=15644
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6251 WHERE pradc_AdCampaignID=12533
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6251 WHERE pradc_AdCampaignID=11900
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6257 WHERE pradc_AdCampaignID=12661
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6257 WHERE pradc_AdCampaignID=12134
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6257 WHERE pradc_AdCampaignID=12224
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6257 WHERE pradc_AdCampaignID=12830
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6257 WHERE pradc_AdCampaignID=12214
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6257 WHERE pradc_AdCampaignID=12762
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6264 WHERE pradc_AdCampaignID=14822
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6264 WHERE pradc_AdCampaignID=15465
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6274 WHERE pradc_AdCampaignID=11193
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6274 WHERE pradc_AdCampaignID=11908
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6274 WHERE pradc_AdCampaignID=12413
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6274 WHERE pradc_AdCampaignID=12452
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6006 WHERE pradc_AdCampaignID=12971
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6029 WHERE pradc_AdCampaignID=12475
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6029 WHERE pradc_AdCampaignID=11452
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6096 WHERE pradc_AdCampaignID=12615
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6125 WHERE pradc_AdCampaignID=12690
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6142 WHERE pradc_AdCampaignID=12613
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6158 WHERE pradc_AdCampaignID=12660
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6171 WHERE pradc_AdCampaignID=12621
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6173 WHERE pradc_AdCampaignID=12479
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6173 WHERE pradc_AdCampaignID=12477
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6173 WHERE pradc_AdCampaignID=12774
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6257 WHERE pradc_AdCampaignID=12654
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6274 WHERE pradc_AdCampaignID=12476
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6232 WHERE pradc_AdCampaignID=13789
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6232 WHERE pradc_AdCampaignID=13151
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6173 WHERE pradc_AdCampaignID=11165

UPDATE PRAdCampaign SET pradc_KYCCommodityID=6277 WHERE pradc_AdCampaignID=11811
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6278 WHERE pradc_AdCampaignID=12907
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6278 WHERE pradc_AdCampaignID=13543
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6279 WHERE pradc_AdCampaignID=14827
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6279 WHERE pradc_AdCampaignID=15289
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6279 WHERE pradc_AdCampaignID=14547
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6279 WHERE pradc_AdCampaignID=14044
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6278 WHERE pradc_AdCampaignID=14269
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6278 WHERE pradc_AdCampaignID=15775
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6278 WHERE pradc_AdCampaignID=14068
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6278 WHERE pradc_AdCampaignID=14399
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6278 WHERE pradc_AdCampaignID=13546
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6279 WHERE pradc_AdCampaignID=14054
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6279 WHERE pradc_AdCampaignID=12414
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6278 WHERE pradc_AdCampaignID=12384
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6279 WHERE pradc_AdCampaignID=15600
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6091 WHERE pradc_AdCampaignID=14250
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6091 WHERE pradc_AdCampaignID=14813
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6091 WHERE pradc_AdCampaignID=15632
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6091 WHERE pradc_AdCampaignID=11235
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6091 WHERE pradc_AdCampaignID=11537
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6277 WHERE pradc_AdCampaignID=14056
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6277 WHERE pradc_AdCampaignID=14080
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6277 WHERE pradc_AdCampaignID=14824
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6277 WHERE pradc_AdCampaignID=15658
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6277 WHERE pradc_AdCampaignID=11146
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6277 WHERE pradc_AdCampaignID=15661
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6279 WHERE pradc_AdCampaignID=15601
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6278 WHERE pradc_AdCampaignID=15776
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6277 WHERE pradc_AdCampaignID=15401
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6279 WHERE pradc_AdCampaignID=15439
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6279 WHERE pradc_AdCampaignID=15450
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6278 WHERE pradc_AdCampaignID=15432
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6277 WHERE pradc_AdCampaignID=13727
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6279 WHERE pradc_AdCampaignID=13519

UPDATE PRAdCampaign SET pradc_KYCCommodityID=6285 WHERE pradc_AdCampaignID=14129
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6285 WHERE pradc_AdCampaignID=14065
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6280 WHERE pradc_AdCampaignID=13464
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6280 WHERE pradc_AdCampaignID=14051
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6285 WHERE pradc_AdCampaignID=11531


UPDATE PRAdCampaign SET pradc_KYCCommodityID=6025 WHERE pradc_AdCampaignID=15962
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6251 WHERE pradc_AdCampaignID=15964
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6153 WHERE pradc_AdCampaignID=15984
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6164 WHERE pradc_AdCampaignID=15993
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6096 WHERE pradc_AdCampaignID=16003
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6006 WHERE pradc_AdCampaignID=16029
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6059 WHERE pradc_AdCampaignID=16030
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6081 WHERE pradc_AdCampaignID=16043
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6142 WHERE pradc_AdCampaignID=16044
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6195 WHERE pradc_AdCampaignID=16045
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6164 WHERE pradc_AdCampaignID=16047
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6249 WHERE pradc_AdCampaignID=16050

--5/3/2019 batch
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6264  WHERE pradc_AdCampaignID=15436
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6264  WHERE pradc_AdCampaignID=15466
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6037  WHERE pradc_AdCampaignID=15887
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6037  WHERE pradc_AdCampaignID=15409
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6000  WHERE pradc_AdCampaignID=15533
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6038  WHERE pradc_AdCampaignID=15452
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6142  WHERE pradc_AdCampaignID=15803
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6142  WHERE pradc_AdCampaignID=15373
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6234  WHERE pradc_AdCampaignID=15387
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6234  WHERE pradc_AdCampaignID=15657
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6008  WHERE pradc_AdCampaignID=15423
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6201  WHERE pradc_AdCampaignID=15381
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6201  WHERE pradc_AdCampaignID=15612
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6153  WHERE pradc_AdCampaignID=15984
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6153  WHERE pradc_AdCampaignID=15396
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6153  WHERE pradc_AdCampaignID=15444
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6059  WHERE pradc_AdCampaignID=15446
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6006  WHERE pradc_AdCampaignID=15419
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6059  WHERE pradc_AdCampaignID=15370
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6006  WHERE pradc_AdCampaignID=16029
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6059  WHERE pradc_AdCampaignID=16030
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6271  WHERE pradc_AdCampaignID=15410
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6271  WHERE pradc_AdCampaignID=15873
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6166  WHERE pradc_AdCampaignID=15460
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6166  WHERE pradc_AdCampaignID=15371
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6008  WHERE pradc_AdCampaignID=15461
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6008  WHERE pradc_AdCampaignID=15618
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6014  WHERE pradc_AdCampaignID=15393
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6276  WHERE pradc_AdCampaignID=15435
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6257  WHERE pradc_AdCampaignID=15390
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6257  WHERE pradc_AdCampaignID=15620
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6201  WHERE pradc_AdCampaignID=15622
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6201  WHERE pradc_AdCampaignID=15391
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6020  WHERE pradc_AdCampaignID=15624
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6081  WHERE pradc_AdCampaignID=16043
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6195  WHERE pradc_AdCampaignID=16045
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6195  WHERE pradc_AdCampaignID=15445
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6081  WHERE pradc_AdCampaignID=15417
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6142  WHERE pradc_AdCampaignID=15418
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6142  WHERE pradc_AdCampaignID=16044
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6277  WHERE pradc_AdCampaignID=15661
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6059  WHERE pradc_AdCampaignID=15662
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6276  WHERE pradc_AdCampaignID=15663
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6276  WHERE pradc_AdCampaignID=15438
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6277  WHERE pradc_AdCampaignID=15401
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6059  WHERE pradc_AdCampaignID=15402
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6099  WHERE pradc_AdCampaignID=15411
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6171  WHERE pradc_AdCampaignID=15388
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6171  WHERE pradc_AdCampaignID=15590
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6099  WHERE pradc_AdCampaignID=15403
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6164  WHERE pradc_AdCampaignID=15420
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6164  WHERE pradc_AdCampaignID=16047
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6006  WHERE pradc_AdCampaignID=15448
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6029  WHERE pradc_AdCampaignID=15449
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6279  WHERE pradc_AdCampaignID=15450
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6274  WHERE pradc_AdCampaignID=15451
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6147  WHERE pradc_AdCampaignID=15413
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6181  WHERE pradc_AdCampaignID=15415
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6091  WHERE pradc_AdCampaignID=15392
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6087  WHERE pradc_AdCampaignID=15631
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6091  WHERE pradc_AdCampaignID=15633
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6037  WHERE pradc_AdCampaignID=16071
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6037  WHERE pradc_AdCampaignID=15421
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6278  WHERE pradc_AdCampaignID=15432
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6234  WHERE pradc_AdCampaignID=15406
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6045  WHERE pradc_AdCampaignID=15377
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6234  WHERE pradc_AdCampaignID=15641
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6045  WHERE pradc_AdCampaignID=15643
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6073  WHERE pradc_AdCampaignID=15639
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6073  WHERE pradc_AdCampaignID=15376
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6096  WHERE pradc_AdCampaignID=15441
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6096  WHERE pradc_AdCampaignID=16003
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6072  WHERE pradc_AdCampaignID=15408
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6251  WHERE pradc_AdCampaignID=15400
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6251  WHERE pradc_AdCampaignID=15645
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6214  WHERE pradc_AdCampaignID=15463
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6141  WHERE pradc_AdCampaignID=15462
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6141  WHERE pradc_AdCampaignID=15378
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6125  WHERE pradc_AdCampaignID=15433
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6125  WHERE pradc_AdCampaignID=15610
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6153  WHERE pradc_AdCampaignID=15519
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6153  WHERE pradc_AdCampaignID=15375
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6159  WHERE pradc_AdCampaignID=15464
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6138  WHERE pradc_AdCampaignID=15651
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6138  WHERE pradc_AdCampaignID=15389
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6096  WHERE pradc_AdCampaignID=15454
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6171  WHERE pradc_AdCampaignID=15578
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6171  WHERE pradc_AdCampaignID=15374
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6055  WHERE pradc_AdCampaignID=15399
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6055  WHERE pradc_AdCampaignID=15397
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6055  WHERE pradc_AdCampaignID=15595
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6252  WHERE pradc_AdCampaignID=15672
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6274  WHERE pradc_AdCampaignID=15635
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6138  WHERE pradc_AdCampaignID=15637
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6274  WHERE pradc_AdCampaignID=15380
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6138  WHERE pradc_AdCampaignID=15386
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6070  WHERE pradc_AdCampaignID=15580
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6070  WHERE pradc_AdCampaignID=15384
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6164  WHERE pradc_AdCampaignID=15422
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6164  WHERE pradc_AdCampaignID=15993
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6073  WHERE pradc_AdCampaignID=15653
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6232  WHERE pradc_AdCampaignID=15655
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6073  WHERE pradc_AdCampaignID=15382
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6232  WHERE pradc_AdCampaignID=15383
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6009  WHERE pradc_AdCampaignID=15372
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6114  WHERE pradc_AdCampaignID=15407
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6114  WHERE pradc_AdCampaignID=15899
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6278  WHERE pradc_AdCampaignID=15776
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6173  WHERE pradc_AdCampaignID=15440
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6181  WHERE pradc_AdCampaignID=15404
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6029  WHERE pradc_AdCampaignID=15405
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6257  WHERE pradc_AdCampaignID=15385
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6279  WHERE pradc_AdCampaignID=15439
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6025  WHERE pradc_AdCampaignID=15442
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6251  WHERE pradc_AdCampaignID=15443
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6251  WHERE pradc_AdCampaignID=15368
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6025  WHERE pradc_AdCampaignID=15369
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6025  WHERE pradc_AdCampaignID=15962
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6251  WHERE pradc_AdCampaignID=15964
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6249  WHERE pradc_AdCampaignID=16050
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6249  WHERE pradc_AdCampaignID=15414
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6020  WHERE pradc_AdCampaignID=15669
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6222  WHERE pradc_AdCampaignID=15802
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6222  WHERE pradc_AdCampaignID=15412
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6189  WHERE pradc_AdCampaignID=15398
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6189  WHERE pradc_AdCampaignID=15566
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6045  WHERE pradc_AdCampaignID=15416
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6279  WHERE pradc_AdCampaignID=15601
UPDATE PRAdCampaign SET pradc_KYCCommodityID=6141  WHERE pradc_AdCampaignID=15379

GO

UPDATE PRAdCampaign SET pradc_Placement='KYCPage1' WHERE pradc_adcampaigntype = 'KYCD' AND pradc_Sequence=1
UPDATE PRAdCampaign SET pradc_Placement='KYCPage2' WHERE pradc_adcampaigntype = 'KYCD' AND pradc_Sequence=2

GO

--From spreadsheet on 5/3/2019 -- must do after above pradc_placement change because it overrides it
UPDATE PRAdCampaign SET pradc_Premium='Y', pradc_Placement='CSL3' WHERE pradc_AdCampaignID=15457
UPDATE PRAdCampaign SET pradc_Premium='Y', pradc_Placement='CSL2' WHERE pradc_AdCampaignID=15458
UPDATE PRAdCampaign SET pradc_Premium='Y', pradc_Placement='CSL2' WHERE pradc_AdCampaignID=15953
UPDATE PRAdCampaign SET pradc_Premium='Y', pradc_Placement='Page1' WHERE pradc_AdCampaignID=15453
UPDATE PRAdCampaign SET pradc_Premium='Y', pradc_Placement='CSL1' WHERE pradc_AdCampaignID=15552
UPDATE PRAdCampaign SET pradc_Premium='Y', pradc_Placement='CSL1' WHERE pradc_AdCampaignID=15455
UPDATE PRAdCampaign SET pradc_Premium='Y', pradc_Placement='CSL1' WHERE pradc_AdCampaignID=16008
UPDATE PRAdCampaign SET pradc_Premium='Y', pradc_Placement='IFC' WHERE pradc_AdCampaignID=15550
UPDATE PRAdCampaign SET pradc_Premium='Y', pradc_Placement='IFC' WHERE pradc_AdCampaignID=15434
UPDATE PRAdCampaign SET pradc_Premium='Y', pradc_Placement='IBC' WHERE pradc_AdCampaignID=15437
UPDATE PRAdCampaign SET pradc_Premium='Y', pradc_Placement='IF' WHERE pradc_AdCampaignID=15485
UPDATE PRAdCampaign SET pradc_Premium='Y', pradc_Placement='CSL3' WHERE pradc_AdCampaignID=15575
UPDATE PRAdCampaign SET pradc_Premium='Y', pradc_Placement='Page3' WHERE pradc_AdCampaignID=15447
UPDATE PRAdCampaign SET pradc_Premium='Y', pradc_Placement='Page3' WHERE pradc_AdCampaignID=16026
UPDATE PRAdCampaign SET pradc_Premium='Y', pradc_Placement='OBC' WHERE pradc_AdCampaignID=15456
UPDATE PRAdCampaign SET pradc_Premium='Y', pradc_Placement='CSL2' WHERE pradc_AdCampaignID=15459
UPDATE PRAdCampaign SET pradc_Premium='Y', pradc_Placement='IBC' WHERE pradc_AdCampaignID=15568
UPDATE PRAdCampaign SET pradc_Premium='Y', pradc_Placement='IB' WHERE pradc_AdCampaignID=15483


--SET pradc_AdCampaignTypeDigital for Digital campaigns
UPDATE PRAdCampaign SET pradc_AdCampaignTypeDigital = pradc_AdCampaignType
WHERE pradc_AdCampaignHeaderID IN (SELECT pradch_AdCampaignHeaderID FROM PRAdCampaignHeader WHERE pradch_TypeCode='D')

--Also noticed this: TPR Ads imported as “BPBDA” digital type. They should be PR Newsletter banner 200x167 
UPDATE PRAdCampaign SET pradc_AdCampaignTypeDigital = 'PRNBA_200x167' 
WHERE pradc_AdCampaignHeaderID IN (SELECT pradch_AdCampaignHeaderID FROM PRAdCampaignHeader WHERE pradch_TypeCode='D')
AND pradc_AdCampaignType = 'BPBDA'
GO

--SET pradc_KYCEdition - use year of EndDate instead of 10/31 logic (changed to this on 5/1/2019)
UPDATE PRAdCampaign SET pradc_KYCEdition = YEAR(pradc_EndDate) WHERE pradc_EndDate IS NOT NULL AND pradc_AdCampaignType IN('KYCD','PUB')

--UPDATE BP Premium flag
--All these should be imported in as Premium Ads (check the checkbox for Premium): 
--1st Page, 3rd Page, 5th Page, Left of Insert, Right of Insert, Insert Front, Insert Back, Inside Front Cover, Inside Back Cover, and Outside Back Cover
UPDATE PRAdCampaign SET pradc_Premium = 'Y' WHERE pradc_AdCampaignID IN (
		SELECT pradc_AdCampaignID FROM PRAdCampaignHeader INNER JOIN PRAdCampaign ON pradc_AdCampaignHeaderID = pradch_AdCampaignHeaderID
			AND pradch_TypeCode = 'BP'
			AND pradc_Placement IN ('Page1','Page3','5thP','LHS','RHS','HSL','HSR','IBC','IFC','OBC')
	)

UPDATE WordPress.dbo.wp_4_postmeta 
SET meta_value = '<script type="text/javascript">var ad1 = new BBSiGetKYCDAdsWidget("kycd1", null, ' + CONVERT(varchar(10), post_id) + ', "KYCPage1");</script>'
WHERE 
meta_key='KYCAD1'

UPDATE WordPress.dbo.wp_4_postmeta 
SET meta_value = '<script type="text/javascript">var ad1 = new BBSiGetKYCDAdsWidget("kycd2", null, ' + CONVERT(varchar(10), post_id) + ', "KYCPage2");</script>'
WHERE 
meta_key='KYCAD2'

--***************    END    AD REFACTORING DATA CONVERSION  *****************************

DECLARE @capt_NextId int
DELETE FROM CUSTOM_CAPTIONS WHERE Capt_Family='PRWebUserWidgetL' 

exec usp_getNextId 'custom_captions', @capt_NextId output
INSERT INTO CUSTOM_CAPTIONS (capt_CaptionId, capt_FamilyType, capt_Family, capt_Code, capt_US, capt_ES, capt_createdby, capt_createddate, capt_updatedby, capt_updateddate) 
	VALUES (@capt_NextId, 'Choices', 'PRWebUserWidgetL', 'CompaniesRecentlyViewed', 'Recently Viewed Companies', 'Compañías Vistas ', -1, getdate(), -1, getdate())
exec usp_getNextId 'custom_captions', @capt_NextId output
INSERT INTO CUSTOM_CAPTIONS (capt_CaptionId, capt_FamilyType, capt_Family, capt_Code, capt_US, capt_ES, capt_createdby, capt_createddate, capt_updatedby, capt_updateddate) 
	VALUES (@capt_NextId, 'Choices', 'PRWebUserWidgetL', 'ListingsRecentlyPublished', 'Recently Published New Listings', 'Nuevas Compañias Publicadas Reciente', -1, getdate(), -1, getdate())
exec usp_getNextId 'custom_captions', @capt_NextId output
INSERT INTO CUSTOM_CAPTIONS (capt_CaptionId, capt_FamilyType, capt_Family, capt_Code, capt_US, capt_ES, capt_createdby, capt_createddate, capt_updatedby, capt_updateddate) 
	VALUES (@capt_NextId, 'Choices', 'PRWebUserWidgetL', 'AUSCompaniesRecentKeyChanges', 'AUS Companies With Recent Key Changes', 'AUS Companies With Recent Key Changes', -1, getdate(), -1, getdate())
--exec usp_getNextId 'custom_captions', @capt_NextId output
--INSERT INTO CUSTOM_CAPTIONS (capt_CaptionId, capt_FamilyType, capt_Family, capt_Code, capt_US, capt_ES, capt_createdby, capt_createddate, capt_updatedby, capt_updateddate) 
	--VALUES (@capt_NextId, 'Choices', 'PRWebUserWidgetL', 'BlueBookScoreDistribution', 'Blue Book Score Distribution', 'Blue Book Score Distribution', -1, getdate(), -1, getdate())
exec usp_getNextId 'custom_captions', @capt_NextId output
INSERT INTO CUSTOM_CAPTIONS (capt_CaptionId, capt_FamilyType, capt_Family, capt_Code, capt_US, capt_ES, capt_createdby, capt_createddate, capt_updatedby, capt_updateddate) 
	VALUES (@capt_NextId, 'Choices', 'PRWebUserWidgetL', 'IndustryMetricsSnapshot', 'Industry Metrics Snapshot', 'Industry Metrics Snapshot', -1, getdate(), -1, getdate())
exec usp_getNextId 'custom_captions', @capt_NextId output
INSERT INTO CUSTOM_CAPTIONS (capt_CaptionId, capt_FamilyType, capt_Family, capt_Code, capt_US, capt_ES, capt_createdby, capt_createddate, capt_updatedby, capt_updateddate) 
	VALUES (@capt_NextId, 'Choices', 'PRWebUserWidgetL', 'IndustryPayTrends', 'Industry Pay Trends', 'Industry Pay Trends', -1, getdate(), -1, getdate())
Go

INSERT INTO PRChangeDetection (prchngd_CompanyID, prchngd_ChangeType)
SELECT DISTINCT ship.comp_CompanyID, 'DL ORDER'
   FROM Company ship WITH (NOLOCK) 
	    INNER JOIN Company bill WITH (NOLOCK) ON bill.comp_CompanyID = ship.comp_PRHQID
		INNER JOIN PRAttentionLine WITH (NOLOCK) ON prattn_CompanyID = ship.comp_PRHQID AND prattn_ItemCode = 'Bill'
		LEFT OUTER JOIN PRService ON ship.comp_CompanyID=prse_CompanyID AND prse_ServiceCode = 'DL'
  WHERE ship.comp_PRPublishDL='Y'
    --AND ship.comp_PRListingStatus = 'L'
	AND prattn_AddressID IS NULL
	AND (prattn_EmailID IS NOT NULL OR prattn_PhoneID IS NOT NULL)
	AND dbo.ufn_GetListingDLLinecount(bill.comp_CompanyID) <> ISNULL(QuantityOrdered, 0)
Go

DELETE FROM PRCompanyExperian WHERE prcex_CompanyID IN (342241, 297893, 296256, 285357, 355183, 355047, 355789, 355771, 348666, 341737, 355180, 348087, 170830, 347761, 347727, 334104, 342268, 342489, 333652, 341847, 355058, 348803, 355936)
Go
