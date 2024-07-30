SELECT comp_CompanyID, comp_PRListedDate, prbs_BBScoreId, prbs_CompanyID, prbs_BBScore, prbs_PRPublish, prbs_CreatedDate
 FROM PRBBScore,
       Company
 WHERE prbs_CompanyID = comp_CompanyID
   AND comp_PRListingStatus = 'L'
   AND comp_PRIndustryType IN ('P', 'T')
   AND prbs_PRPublish = 'Y'
   AND (DATEDIFF(day, comp_PRListedDate, GETDATE()) < 150)
ORDER BY comp_COmpanyID, prbs_CreatedDate

UPDATE PRBBScore 
   SET prbs_PRPublish = NULL,
       prbs_UpdatedBy = -1,
	   prbs_UpdatedDate = GETDATE()
  FROM Company
 WHERE prbs_CompanyID = comp_CompanyID
   AND comp_PRListingStatus = 'L'
   AND comp_PRIndustryType IN ('P', 'T')
   AND prbs_PRPublish = 'Y'
   AND (DATEDIFF(day, comp_PRListedDate, GETDATE()) < 150)
Go

SET NOCOUNT ON
DECLARE @ForCommit bit
-- SET this variable to 1 to commit changes

SET @ForCommit = 1;
DECLARE @CommitMsg varchar(500) = 'COMMITTING Changes'

if (@ForCommit = 0) begin
	PRINT '*************************************************************'
	PRINT 'NOTE: COMMIT CHANGES IS TURNED OFF. NO CHANGES WILL BE SAVED!'
	PRINT '*************************************************************'
	PRINT ''
	
	SET @CommitMsg = 'ROLLING BACK Changes'
end


DECLARE @Start DateTime
SET @Start = GETDATE()
PRINT 'Execution Start: ' + CONVERT(VARCHAR(20), @Start, 100) + ' on server ' + @@SERVERNAME
PRINT ''


BEGIN TRANSACTION
BEGIN TRY

	-- DELETE FROM PRWebUserCustomField WHERE prwucf_Label = 'Custom Contact'

	-- EXEC usp_AccpacCreateTextField 'PRWebUserCustomData', 'prwucd_Value', 'Value', 100, 200

	DECLARE @MyTable table (
		ndx int identity(1,1),
		CompanyID int,
		HQID int,
		ContactCount int,
		prwuc_WebUserID int,
		prwuc_AssociatedCompanyID int,
		prwuc_FirstName varchar(50),
		prwuc_LastName varchar(50), 
		prwuc_Title varchar(50),
		prwuc_Email varchar(100),
		prwuc_PhoneAreaCode varchar(50),
		prwuc_PhoneNumber varchar(50),
		prwuc_FaxAreaCode varchar(50),
		prwuc_FaxNumber varchar(50),
		prwuc_CellAreaCode varchar(50),
		prwuc_CellNumber varchar(50),
		prwuc_ResidenceAreaCode varchar(50),
		prwuc_ResidenceNumber varchar(50)
	)

	INSERT INTO @MyTable 
	SELECT prwu_BBID, prwu_HQID, null, prwuc_WebUserID,
		   prwuc_AssociatedCompanyID,prwuc_FirstName,prwuc_LastName, prwuc_Title,prwuc_Email,prwuc_PhoneAreaCode,prwuc_PhoneNumber,prwuc_FaxAreaCode,prwuc_FaxNumber,prwuc_CellAreaCode,prwuc_CellNumber,prwuc_ResidenceAreaCode,prwuc_ResidenceNumber
	  FROM PRWebUserContact
		   INNER JOIN PRWebUser ON prwuc_WebUserID = prwu_WebUserID
	 WHERE prwu_Disabled IS NULL       
	ORDER BY prwu_BBID, prwuc_WebUserContactID



	DECLARE @WebUserID int, @CompanyID int, @HQID int, @RecordID int, @AssociatedID int, @DataValue varchar(200)
	DECLARE @FieldCount int = 0, @FieldLabel varchar(50), @SaveCompanyID int = 0, @SaveAssociatedID int = 0
	DECLARE @Count int, @Index int

	SELECT @Count = COUNT(1) FROM @MyTable
	SET @Index = 0

	WHILE (@Index < @Count) BEGIN

		SET @Index = @Index + 1

		SELECT @HQID = HQID,
			   @CompanyID = CompanyID,
			   @WebUserID = prwuc_WebUserID,
			   @AssociatedID = prwuc_AssociatedCompanyID,
			   @DataValue = prwuc_FirstName + ' ' + prwuc_LastName + ' ' + prwuc_Title + ' ' + 
						   prwuc_Email + ' ' + 
						   CASE WHEN prwuc_PhoneNumber <> '' THEN 'Ph: ' + prwuc_PhoneAreaCode + ' ' + prwuc_PhoneNumber + ' ' ELSE '' END + 
						   CASE WHEN prwuc_CellNumber <> '' THEN 'Cell: ' + prwuc_CellAreaCode + ' ' + prwuc_CellNumber + ' ' ELSE '' END +
						   CASE WHEN prwuc_ResidenceNumber <> '' THEN 'Res: ' + prwuc_ResidenceAreaCode + ' ' + prwuc_ResidenceNumber + ' ' ELSE '' END +
						   CASE WHEN prwuc_FaxNumber <> '' THEN 'Fax: ' + prwuc_FaxNumber + ' ' + prwuc_FaxNumber + ' ' ELSE '' END
		  FROM @MyTable
		 WHERE ndx = @Index


		IF ((@SaveCompanyID <> @CompanyID) OR (@SaveAssociatedID <> @AssociatedID)) BEGIN
			SET @FieldCount = 0
			SET @SaveCompanyID = @CompanyID
			SET @SaveAssociatedID = @AssociatedID
		END
		SET @FieldCount = @FieldCount + 1

		IF (@FieldCount = 1) BEGIN
			SET @FieldLabel = 'Custom Contact'
		END ELSE BEGIN
			SET @FieldLabel = 'Custom Contact ' + CAST(@FieldCount as varchar(5))
		END

		SET @RecordID = NULL
		SELECT @RecordID = prwucf_WebUserCustomFieldID
		  FROM PRWebUserCustomField
		 WHERE prwucf_CompanyID = @CompanyID
		   AND prwucf_Label = @FieldLabel

		IF (@RecordID IS NULL) BEGIN
			INSERT INTO PRWebUserCustomField (prwucf_HQID, prwucf_CompanyID, prwucf_FieldTypeCode, prwucf_Label, prwucf_CreatedBy, prwucf_CreatedDate, prwucf_UpdatedBy, prwucf_UpdatedDate, prwucf_Timestamp)
			VALUES (@HQID, @CompanyID, 'Text', @FieldLabel, 1, @Start, 1, @Start, @Start);

			SET @RecordID = SCOPE_IDENTITY()
		END

		INSERT INTO PRWebUserCustomData (prwucd_WebUserID, prwucd_CompanyID, prwucd_HQID, prwucd_AssociatedID, prwucd_AssociatedType,
										 prwucd_WebUserCustomFieldID, prwucd_LabelCode, prwucd_Value, 
										 prwucd_CreatedBy, prwucd_CreatedDate, prwucd_UpdatedBy, prwucd_UpdatedDate, prwucd_Timestamp)
		VALUES (@WebUserID, @CompanyID, @HQID, @AssociatedID, 'C',
		        @RecordID, '1', @DataValue,
				1, @Start, 1, @Start, @Start);
	END


	--Populate new field in PRPublicationArticleRead
	UPDATE PRPublicationArticleRead 
	SET PRPublicationArticleRead.prpar_PublicationCode = PRPublicationArticle.prpbar_PublicationCode 
	FROM PRPublicationArticle 
	WHERE PRPublicationArticle.prpbar_PublicationArticleID = PRPublicationArticleRead.prpar_PublicationArticleID
	
	--28 articles have no PublicationCode so delete them
	DELETE FROM PRPublicationArticle WHERE prpbar_PublicationCode IS NULL OR prpbar_PublicationCode = ''
	--SELECT * FROM PRPublicationArticle WHERE prpbar_PublicationCode IS NULL OR prpbar_PublicationCode = ''

	--Now 32396 read records are orphaned for the articles that were removed above, which is ok
	DELETE FROM prPublicationArticleRead WHERE prpar_PublicationArticleID NOT IN (SELECT prpbar_PublicationArticleID from PRPublicationArticle)
	--SELECT * FROM prPublicationArticleRead WHERE prpar_PublicationArticleID NOT IN (SELECT prpbar_PublicationArticleID from PRPublicationArticle)	
  

  SELECT * FROM PRWebUserCustomField WHERE prwucf_CreatedDate = @Start
  SELECT * FROM PRWebUserCustomData WHERE prwucd_CreatedDate = @Start


	PRINT '';PRINT ''

	if (@ForCommit = 1) begin
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
Go




DECLARE @NextID int
SELECT @NextID = MAX(prserpr_ServiceProvidedID) + 1 FROM PRServiceProvided;

INSERT INTO PRServiceProvided
(prserpr_ServiceProvidedID,prserpr_DisplayOrder,prserpr_ParentID,prserpr_Level,prserpr_Name,prserpr_CreatedBy,prserpr_CreatedDate,prserpr_UpdatedBy,prserpr_UpdatedDate,prserpr_TimeStamp)
VALUES (@NextID, 45, 4, 2, 'Anti-Stain Treating', 1,GetDate(),1,GetDate(),GetDate());


UPDATE PRServiceProvided
   SET prserpr_Name = 'Heat Treating',
       prserpr_ParentID = 4,
	   prserpr_DisplayOrder = 55,
       prserpr_UpdatedDate = GETDATE()
 WHERE prserpr_ServiceProvidedID = 76; 

 
UPDATE PRServiceProvided
   SET prserpr_Name = 'Pressure Treating',
       prserpr_ParentID = 4,
	   prserpr_DisplayOrder = 115,
       prserpr_UpdatedDate = GETDATE()
 WHERE prserpr_ServiceProvidedID = 39; 

SET @NextID = @NextID + 1
INSERT INTO PRServiceProvided
(prserpr_ServiceProvidedID,prserpr_DisplayOrder,prserpr_ParentID,prserpr_Level,prserpr_Name,prserpr_CreatedBy,prserpr_CreatedDate,prserpr_UpdatedBy,prserpr_UpdatedDate,prserpr_TimeStamp)
VALUES (@NextID, 345, 14, 2, 'Peeler', 1,GetDate(),1,GetDate(),GetDate());

SET @NextID = @NextID + 1
INSERT INTO PRServiceProvided
(prserpr_ServiceProvidedID,prserpr_DisplayOrder,prserpr_ParentID,prserpr_Level,prserpr_Name,prserpr_CreatedBy,prserpr_CreatedDate,prserpr_UpdatedBy,prserpr_UpdatedDate,prserpr_TimeStamp)
VALUES (@NextID, 445, 14, 2, 'Stacker', 1,GetDate(),1,GetDate(),GetDate());

UPDATE PRServiceProvided
   SET prserpr_Name = 'Hewing Machine',
       prserpr_UpdatedDate = GETDATE()
 WHERE prserpr_ServiceProvidedID = 26; 

SET @NextID = @NextID + 1
INSERT INTO PRServiceProvided
(prserpr_ServiceProvidedID,prserpr_DisplayOrder,prserpr_ParentID,prserpr_Level,prserpr_Name,prserpr_CreatedBy,prserpr_CreatedDate,prserpr_UpdatedBy,prserpr_UpdatedDate,prserpr_TimeStamp)
VALUES (@NextID, 517, 48, 2, 'Panel Mill', 1,GetDate(),1,GetDate(),GetDate());

SET @NextID = @NextID + 1
INSERT INTO PRServiceProvided
(prserpr_ServiceProvidedID,prserpr_DisplayOrder,prserpr_ParentID,prserpr_Level,prserpr_Name,prserpr_CreatedBy,prserpr_CreatedDate,prserpr_UpdatedBy,prserpr_UpdatedDate,prserpr_TimeStamp)
VALUES (@NextID, 535, 48, 2, 'Pulp Mill', 1,GetDate(),1,GetDate(),GetDate());

SET @NextID = @NextID + 1
INSERT INTO PRServiceProvided
(prserpr_ServiceProvidedID,prserpr_DisplayOrder,prserpr_ParentID,prserpr_Level,prserpr_Name,prserpr_CreatedBy,prserpr_CreatedDate,prserpr_UpdatedBy,prserpr_UpdatedDate,prserpr_TimeStamp)
VALUES (@NextID, 545, 48, 2, 'Scragg Mill', 1,GetDate(),1,GetDate(),GetDate());

SET @NextID = @NextID + 1
INSERT INTO PRServiceProvided
(prserpr_ServiceProvidedID,prserpr_DisplayOrder,prserpr_ParentID,prserpr_Level,prserpr_Name,prserpr_CreatedBy,prserpr_CreatedDate,prserpr_UpdatedBy,prserpr_UpdatedDate,prserpr_TimeStamp)
VALUES (@NextID, 615, 56, 2, 'Gang Saw', 1,GetDate(),1,GetDate(),GetDate());

SET @NextID = @NextID + 1
INSERT INTO PRServiceProvided
(prserpr_ServiceProvidedID,prserpr_DisplayOrder,prserpr_ParentID,prserpr_Level,prserpr_Name,prserpr_CreatedBy,prserpr_CreatedDate,prserpr_UpdatedBy,prserpr_UpdatedDate,prserpr_TimeStamp)
VALUES (@NextID, 740, 71, 2, 'Container Loading', 1,GetDate(),1,GetDate(),GetDate());

ALTER TABLE PRCompanyServiceProvided DISABLE TRIGGER ALL
UPDATE PRCompanyServiceProvided
   SET prcserpr_ServiceProvidedID = 75
 WHERE prcserpr_ServiceProvidedID = 78
   AND prcserpr_CompanyID NOT IN (SELECT prcserpr_CompanyID FROM PRCompanyServiceProvided WHERE prcserpr_ServiceProvidedID = 75)
DELETE FROM PRCompanyServiceProvided WHERE prcserpr_ServiceProvidedID = 78
DELETE FROM PRServiceProvided WHERE prserpr_ServiceProvidedID = 78
ALTER TABLE PRCompanyServiceProvided ENABLE TRIGGER ALL
Go



DECLARE @NextID int
SELECT @NextID = MAX(prspc_SpecieID) + 1 FROM PRSpecie;

INSERT INTO PRSpecie
(prspc_SpecieID,prspc_DisplayOrder,prspc_ParentID,prspc_Level,prspc_Name,prspc_CreatedBy,prspc_CreatedDate,prspc_UpdatedBy,prspc_UpdatedDate,prspc_TimeStamp)
VALUES (@NextID, 50865, 75, 2, 'Locust', 1,GetDate(),1,GetDate(),GetDate());

UPDATE PRSpecie
   SET prspc_Name = 'Yellow Poplar/Tulipwood',
       prspc_UpdatedDate = GETDATE()
 WHERE prspc_SpecieID = 146; 

ALTER TABLE PRCompanySpecie DISABLE TRIGGER ALL
UPDATE PRCompanySpecie
   SET prcspc_SpecieID = 146
 WHERE prcspc_SpecieID = 219
   AND prcspc_CompanyID NOT IN (SELECT prcspc_CompanyID FROM PRCompanySpecie WHERE prcspc_SpecieID = 146)
DELETE FROM PRCompanySpecie WHERE prcspc_SpecieID = 219
DELETE FROM PRSpecie WHERE prspc_SpecieID = 219
ALTER TABLE PRCompanySpecie ENABLE TRIGGER ALL
Go

ALTER TABLE Person_Link DISABLE TRIGGER ALL
UPDATE Person_Link 
   SET peli_PRTitleCode = 'CTO' 
 WHERE peli_PRTitle IN ('CTO', 'Chief Technology Officer')
   AND peli_PRStatus = '1'
   AND peli_PRTitleCode <> 'CTO' 

UPDATE Person_Link 
   SET peli_PRRole = peli_PRRole + 'HI,' 
 WHERE peli_PRTitle IN ('CTO', 'Chief Technology Officer')
   AND peli_PRStatus = '1'
   AND peli_PRRole NOT LIKE '%,HI,%'


UPDATE Person_Link 
   SET peli_PRRole = peli_PRRole + 'HI,' 
 WHERE peli_PRTitle LIKE  '%/Chief Technology Officer'
   AND peli_PRStatus = '1'
   AND peli_PRRole NOT LIKE '%,HI,%'
ALTER TABLE Person_Link ENABLE TRIGGER ALL
Go


UPDATE NewProduct SET prod_PRDescription = 
'<div style="font-weight:bold">Blue Book Business Report including Experian Credit Information</div><p style="margin-top:0em">Creditors such as sellers, transporters and suppliers use this report type for performing a high-level account evaluation, where there is typically a specific interest in current and trend facts such as pay and trade experiences. Tabular and graphic presentation of the company''s rating information makes it quick & easy to make informed decisions.</p><p>The Business Report includes:  ownership, basic company contact information such as Blue Book ID#, company name, listing location, addresses, phones, faxes, e-mails, web URLs, and alternate trade names. Also included - if available/applicable - are current headquarter rating & rating definition, headquarter rating trend, Trading Member year, recent company developments, bankruptcy events, business background, people background, business profile, financial information, year-to-date trade report summary, previous two calendar years of trade reports, trade report details for the past 18 months, the current Blue Book Score, recent Blue Book Score history, affiliated businesses, and branch locations. Select credit information such as public record information, trade payment/legal filings, and business facts provided by <span style="font-weight:bold">Experian</span>, will be included with your Business Report, as available/applicable. When used in conjunction with Blue Book data, information provided by <span style="font-weight:bold">Experian</span> can help provide a comprehensive financial picture of a company as a whole, including financial activities outside of the produce industry.</p>'
WHERE Prod_ProductID = 47

UPDATE NewProduct SET prod_PRDescription = 
'<div style="font-weight:bold">Blue Book Business Report including Experian Credit Information</div><p style="margin-top:0em">Creditors such as sellers, transporters and suppliers use this report type for performing a high-level connection/prospect evaluation, where there is typically a specific interest in current and trend facts such as pay and trade experiences. Tabular and graphic presentation of the company''s rating information makes it quick & easy to reach informed decisions.</p><p>The Business Report includes: basic company contact information such as Blue Book ID#, company name, listing location, addresses, phones, faxes, e-mails, web URLs, ownership, and alternate trade names. Also included - if available/applicable - are current headquarter rating & rating definition, affiliated businesses, branch locations, headquarter rating trend, recent company developments, bankruptcy events, business background, people background, business profile, financial information, and year-to-date trade report summary. Select credit information such as public record information, trade payment/legal filings, and business facts provided by <span style="font-weight:bold">Experian</span>, will be included with your Business Report, as available/applicable. When used in conjunction with Blue Book data, information provided by <span style="font-weight:bold">Experian</span> can help provide a comprehensive financial picture of a company as a whole, including financial activities outside of the lumber industry.</p>'
WHERE Prod_ProductID = 80

Go




UPDATE NewProduct
   SET prod_IndustryTypeCode = ',P,T,S,'
 WHERE prod_ProductFamilyID=8 

DELETE FROM NewProduct WHERE prod_ProductID BETWEEN 88 AND 92
INSERT INTO NewProduct
	   (Prod_ProductID,prod_Active,prod_UOMCategory,prod_name,prod_PRServiceUnits,prod_code,prod_productfamilyid,prod_IndustryTypeCode,prod_PRSequence,Prod_CreatedBy,Prod_CreatedDate,Prod_UpdatedBy,Prod_UpdatedDate,Prod_TimeStamp)
VALUES (88,'Y',6000,'5 Additional Online Business Reports', 5,'100UN',8, ',L,', 10, -1,GETDATE(),-1,GETDATE(),GETDATE());
INSERT INTO NewProduct
	   (Prod_ProductID,prod_Active,prod_UOMCategory,prod_name,prod_PRServiceUnits,prod_code,prod_productfamilyid,prod_IndustryTypeCode,prod_PRSequence,Prod_CreatedBy,Prod_CreatedDate,Prod_UpdatedBy,Prod_UpdatedDate,Prod_TimeStamp)
VALUES (89,'Y',6000,'10 Additional Online Business Reports', 10,'250UN',8, ',L,', 20, -1,GETDATE(),-1,GETDATE(),GETDATE());
INSERT INTO NewProduct
	   (Prod_ProductID,prod_Active,prod_UOMCategory,prod_name,prod_PRServiceUnits,prod_code,prod_productfamilyid,prod_IndustryTypeCode,prod_PRSequence,Prod_CreatedBy,Prod_CreatedDate,Prod_UpdatedBy,Prod_UpdatedDate,Prod_TimeStamp)
VALUES (90,'Y',6000,'15 Additional Online Business Reports', 15,'500UN',8, ',L,', 30, -1,GETDATE(),-1,GETDATE(),GETDATE());
INSERT INTO NewProduct
	   (Prod_ProductID,prod_Active,prod_UOMCategory,prod_name,prod_PRServiceUnits,prod_code,prod_productfamilyid,prod_IndustryTypeCode,prod_PRSequence,Prod_CreatedBy,Prod_CreatedDate,Prod_UpdatedBy,Prod_UpdatedDate,Prod_TimeStamp)
VALUES (91,'Y',6000,'20 Additional Online Business Reports', 20,'1000UN',8, ',L,', 40, -1,GETDATE(),-1,GETDATE(),GETDATE());
INSERT INTO NewProduct
	   (Prod_ProductID,prod_Active,prod_UOMCategory,prod_name,prod_PRServiceUnits,prod_code,prod_productfamilyid,prod_IndustryTypeCode,prod_PRSequence,Prod_CreatedBy,Prod_CreatedDate,Prod_UpdatedBy,Prod_UpdatedDate,Prod_TimeStamp)
VALUES (92,'Y',6000,'40 Additional Online Business Reports', 40,'3000UN',8, ',L,', 50, -1,GETDATE(),-1,GETDATE(),GETDATE());


DELETE FROM Pricing WHERE pric_ProductID BETWEEN 88 AND 92
 INSERT INTO Pricing (pric_PricingID, pric_ProductID, pric_Price, pric_Price_CID, pric_PricingListID, pric_Active, pric_CreatedBy, pric_CreatedDate, pric_UpdatedBy, pric_UpdatedDate, pric_TimeStamp)
 VALUES (74, 88, 50, 16010, 16010, 'Y', -1, GETDATE(), -1, GETDATE(), GETDATE());
  INSERT INTO Pricing (pric_PricingID, pric_ProductID, pric_Price, pric_Price_CID, pric_PricingListID, pric_Active, pric_CreatedBy, pric_CreatedDate, pric_UpdatedBy, pric_UpdatedDate, pric_TimeStamp)
 VALUES (75, 89, 100, 16010, 16010, 'Y', -1, GETDATE(), -1, GETDATE(), GETDATE());
  INSERT INTO Pricing (pric_PricingID, pric_ProductID, pric_Price, pric_Price_CID, pric_PricingListID, pric_Active, pric_CreatedBy, pric_CreatedDate, pric_UpdatedBy, pric_UpdatedDate, pric_TimeStamp)
 VALUES (76, 90, 150, 16010, 16010, 'Y', -1, GETDATE(), -1, GETDATE(), GETDATE());
  INSERT INTO Pricing (pric_PricingID, pric_ProductID, pric_Price, pric_Price_CID, pric_PricingListID, pric_Active, pric_CreatedBy, pric_CreatedDate, pric_UpdatedBy, pric_UpdatedDate, pric_TimeStamp)
 VALUES (77, 91, 200, 16010, 16010, 'Y', -1, GETDATE(), -1, GETDATE(), GETDATE());
  INSERT INTO Pricing (pric_PricingID, pric_ProductID, pric_Price, pric_Price_CID, pric_PricingListID, pric_Active, pric_CreatedBy, pric_CreatedDate, pric_UpdatedBy, pric_UpdatedDate, pric_TimeStamp)
 VALUES (78, 92, 400, 16010, 16010, 'Y', -1, GETDATE(), -1, GETDATE(), GETDATE());
Go

UPDATE PRAdCampaign SET pradc_IndustryType = ',P,T,S,', pradc_Language=',en-us,' WHERE pradc_AdCampaignType NOT IN ('PUB', 'BP');

DECLARE @AdEligiblePageID int = 6046
DELETE FROM PRAdEligiblePage WHERE pradep_AdEligiblePageID = @AdEligiblePageID
INSERT INTO PRAdEligiblePage
(pradep_AdEligiblePageID,pradep_AdCampaignType,pradep_DisplayName,pradep_PageName,pradep_MaxAdCount,pradep_MinAdCount,pradep_MaxImageHeight,pradep_MaxImageWidth,pradep_CreatedBy,pradep_CreatedDate,pradep_UpdatedBy,pradep_UpdatedDate,pradep_TimeStamp)
VALUES (@AdEligiblePageID,'BBOSSlider','Home Page','Default',25,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());
EXEC usp_UpdateSQLIdentity 'PRAdEligiblePage', 'pradep_AdEligiblePageID'

DECLARE @AdCampaignID int
DECLARE @RecordID int

EXEC usp_GetNextId 'PRAdCampaign', @AdCampaignID output
INSERT INTO PRAdCampaign (pradc_AdCampaignID, pradc_CompanyID, pradc_HQID, pradc_Name, pradc_AdCampaignType, pradc_AdImageName, pradc_TargetURL, pradc_StartDate, pradc_EndDate, pradc_IndustryType, pradc_Language, pradc_CreatedBy, pradc_CreatedDate,pradc_UpdatedBy,pradc_UpdatedDate,pradc_TimeStamp)
VALUES (@AdCampaignID,100002,100002, 'Microslider 09', 'BBOSSlider', '100002\BBSL-microslider9.jpg', 'https://apps.bluebookservices.com/bbos/BlueBookReference.aspx', '2018-01-01', '2020-12-31', ',P,T,S,', ',en-us,', -100, GETDATE(), -100,GETDATE(), GETDATE());

EXEC usp_GetNextId 'PRAdCampaignPage', @RecordID output
INSERT INTO PRAdCampaignPage (pradcp_AdCampaignPageID,pradcp_AdCampaignID,pradcp_AdEligiblePageID,pradcp_CreatedBy,pradcp_CreatedDate,pradcp_UpdatedBy,pradcp_UpdatedDate,pradcp_TimeStamp)
VALUES (@RecordID, @AdCampaignID, @AdEligiblePageID, -100, GETDATE(), -100, GETDATE(), GETDATE());

EXEC usp_GetNextId 'PRAdCampaign', @AdCampaignID output
INSERT INTO PRAdCampaign (pradc_AdCampaignID, pradc_CompanyID, pradc_HQID, pradc_Name, pradc_AdCampaignType, pradc_AdImageName, pradc_TargetURL, pradc_StartDate, pradc_EndDate, pradc_IndustryType, pradc_Language, pradc_CreatedBy, pradc_CreatedDate,pradc_UpdatedBy,pradc_UpdatedDate,pradc_TimeStamp)
VALUES (@AdCampaignID,100002,100002, 'Microslider 10', 'BBOSSlider', '100002\BBSL-microslider10.jpg', 'https://apps.bluebookservices.com/bbos/GetPublicationFile.aspx?PublicationArticleID=9497', '2018-01-01', '2020-12-31', ',P,T,S,', ',en-us,', -100, GETDATE(), -100,GETDATE(), GETDATE());

EXEC usp_GetNextId 'PRAdCampaignPage', @RecordID output
INSERT INTO PRAdCampaignPage (pradcp_AdCampaignPageID,pradcp_AdCampaignID,pradcp_AdEligiblePageID,pradcp_CreatedBy,pradcp_CreatedDate,pradcp_UpdatedBy,pradcp_UpdatedDate,pradcp_TimeStamp)
VALUES (@RecordID, @AdCampaignID, @AdEligiblePageID, -100, GETDATE(), -100, GETDATE(), GETDATE());

EXEC usp_GetNextId 'PRAdCampaign', @AdCampaignID output
INSERT INTO PRAdCampaign (pradc_AdCampaignID, pradc_CompanyID, pradc_HQID, pradc_Name, pradc_AdCampaignType, pradc_AdImageName, pradc_TargetURL, pradc_StartDate, pradc_EndDate, pradc_IndustryType, pradc_Language, pradc_CreatedBy, pradc_CreatedDate,pradc_UpdatedBy,pradc_UpdatedDate,pradc_TimeStamp)
VALUES (@AdCampaignID,100002,100002, 'Microslider 11', 'BBOSSlider', '100002\BBSL-microslider11.jpg', 'https://apps.bluebookservices.com/bbos/CompanySearchClassification.aspx', '2018-01-01', '2020-12-31', ',P,T,S,', ',en-us,', -100, GETDATE(), -100,GETDATE(), GETDATE());

EXEC usp_GetNextId 'PRAdCampaignPage', @RecordID output
INSERT INTO PRAdCampaignPage (pradcp_AdCampaignPageID,pradcp_AdCampaignID,pradcp_AdEligiblePageID,pradcp_CreatedBy,pradcp_CreatedDate,pradcp_UpdatedBy,pradcp_UpdatedDate,pradcp_TimeStamp)
VALUES (@RecordID, @AdCampaignID, @AdEligiblePageID, -100, GETDATE(), -100, GETDATE(), GETDATE());

EXEC usp_GetNextId 'PRAdCampaign', @AdCampaignID output
INSERT INTO PRAdCampaign (pradc_AdCampaignID, pradc_CompanyID, pradc_HQID, pradc_Name, pradc_AdCampaignType, pradc_AdImageName, pradc_TargetURL, pradc_StartDate, pradc_EndDate, pradc_IndustryType, pradc_Language, pradc_CreatedBy, pradc_CreatedDate,pradc_UpdatedBy,pradc_UpdatedDate,pradc_TimeStamp)
VALUES (@AdCampaignID,100002,100002, 'Microslider 19', 'BBOSSlider', '100002\BBSL-microslider19.jpg', 'https://player.vimeo.com/video/182396519', '2018-01-01', '2020-12-31', ',P,T,S,', ',en-us,', -100, GETDATE(), -100,GETDATE(), GETDATE());

EXEC usp_GetNextId 'PRAdCampaignPage', @RecordID output
INSERT INTO PRAdCampaignPage (pradcp_AdCampaignPageID,pradcp_AdCampaignID,pradcp_AdEligiblePageID,pradcp_CreatedBy,pradcp_CreatedDate,pradcp_UpdatedBy,pradcp_UpdatedDate,pradcp_TimeStamp)
VALUES (@RecordID, @AdCampaignID, @AdEligiblePageID, -100, GETDATE(), -100, GETDATE(), GETDATE());
Go

UPDATE PRAdCampaign SET pradc_PublicationCode = 'KYCG' WHERE pradc_AdCampaignType = 'PUB' AND pradc_Name LIKE '%Guide%'
UPDATE PRAdCampaign SET pradc_PublicationCode = 'KYC' WHERE pradc_AdCampaignType = 'PUB' AND pradc_PublicationCode IS NULL
Go

UPDATE PRCompanySearch
   SET prcse_NameMatch = dbo.ufn_GetLowerAlpha(dbo.ufn_PrepareCompanyName(comp_Name)),
       prcse_LegalNameMatch = CASE WHEN comp_PRLegalName IS NOT NULL THEN dbo.GetLowerAlpha(dbo.ufn_PrepareCompanyName(comp_PRLegalName)) ELSE NULL END,
	   prcse_OriginalNameMatch = CASE WHEN comp_PROriginalName IS NOT NULL THEN dbo.GetLowerAlpha(dbo.ufn_PrepareCompanyName(comp_PROriginalName)) ELSE NULL END
  FROM Company
       INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
 WHERE comp_CompanyID= prcse_CompanyID
   AND prcn_CountryID=3
Go

ALTER TABLE Phone DISABLE TRIGGER ALL
UPDATE Phone SET Phon_CountryCode = '52'
FROM Company
      INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
	  INNER JOIN PhoneLink ON comp_CompanyID = plink_RecordID AND plink_EntityID=5
WHERE comp_PRListingStatus NOT IN ('L', 'D', 'N6')
  AND prcn_CountryID=3
  AND phon_PhoneID = plink_PhoneID
  AND Phon_CountryCode = '1'


UPDATE Phone SET phon_AreaCode = '442', Phon_Number='223-6730' WHERE phon_PhoneID=104315
UPDATE Phone SET phon_AreaCode = '116', Phon_Number='215-8699' WHERE phon_PhoneID=144541
UPDATE Phone SET phon_AreaCode = '665', Phon_Number='521-7355' WHERE phon_PhoneID=104329
UPDATE Phone SET phon_AreaCode = '354', Phon_Number='426-6265' WHERE phon_PhoneID=104340
UPDATE Phone SET phon_AreaCode = '333', Phon_Number='633-5481' WHERE phon_PhoneID=144540
UPDATE Phone SET phon_AreaCode = '331', Phon_Number='454-5800' WHERE phon_PhoneID=240279
UPDATE Phone SET phon_AreaCode = '637', Phon_Number='372-0906' WHERE phon_PhoneID=104337
UPDATE Phone SET phon_AreaCode = '354', Phon_Number='542-6603' WHERE phon_PhoneID=104339
UPDATE Phone SET phon_AreaCode = '415', Phon_Number='152-6970' WHERE phon_PhoneID=230556
UPDATE Phone SET phon_AreaCode = '461', Phon_Number='612-6844' WHERE phon_PhoneID=144537
UPDATE Phone SET phon_AreaCode = '351', Phon_Number='119-0635' WHERE phon_PhoneID=685868
UPDATE Phone SET phon_AreaCode = '811', Phon_Number='050-5054' WHERE phon_PhoneID=782803
UPDATE Phone SET phon_AreaCode = '637', Phon_Number='372-5178' WHERE phon_PhoneID=104338
UPDATE Phone SET phon_AreaCode = '415', Phon_Number='152-6971' WHERE phon_PhoneID=230557
UPDATE Phone SET phon_AreaCode = '555', Phon_Number='282-4016' WHERE phon_PhoneID=101448
UPDATE Phone SET phon_AreaCode = '442', Phon_Number='198-3335' WHERE phon_PhoneID=144539
UPDATE Phone SET phon_AreaCode = '555', Phon_Number='255-2298' WHERE phon_PhoneID=105954
UPDATE Phone SET phon_AreaCode = '172', Phon_Number='821-7599' WHERE phon_PhoneID=144543
UPDATE Phone SET phon_AreaCode = '238', Phon_Number='121-2678' WHERE phon_PhoneID=444250
UPDATE Phone SET phon_AreaCode = '555', Phon_Number='600-0191' WHERE phon_PhoneID=240181
UPDATE Phone SET phon_AreaCode = '354', Phon_Number='542-6866' WHERE phon_PhoneID=104341
UPDATE Phone SET phon_AreaCode = '667', Phon_Number='758-7000' WHERE phon_PhoneID=533567
ALTER TABLE Phone ENABLE TRIGGER ALL
Go

INSERT INTO NewProduct
	   (Prod_ProductID,prod_Active,prod_UOMCategory,prod_name,prod_code,prod_productfamilyid,prod_IndustryTypeCode,prod_PRSequence,Prod_CreatedBy,Prod_CreatedDate,Prod_UpdatedBy,Prod_UpdatedDate,Prod_TimeStamp)
VALUES (93,'Y',6000,'Intl Trade Association License', 'ITALIC',15, ',P,', 999, -1,GETDATE(),-1,GETDATE(),GETDATE());
Go

UPDATE Company 
   SET comp_PRImporter = 'Y' 
  FROM PRCompanyClassification
 WHERE prc2_CompanyId = comp_CompanyID
   AND prc2_ClassificationId = 220
   AND comp_PRImporter IS NULL
Go


UPDATE Pricing SET pric_Price = 225 WHERE pric_ProductID=17
UPDATE Pricing SET pric_Price = 205 WHERE pric_ProductID=21
Go


/*

SELECT ID, post_title, post_date, post_status, CRM.dbo.ufn_GetWordPressBluePrintsEdition(ID),
       prpbar_PublicationArticleID, prpbar_Name, prpbar_PublicationCode, prpbed_PublishDate, prpbed_Name
  FROM WordPress.dbo.wp_posts
       INNER JOIN CRM.dbo.PRPublicationArticle ON prpbar_Name LIKE '%' + post_title
	   INNER JOIN CRM.dbo.PRPublicationEdition ON prpbar_PublicationEditionID = prpbed_PublicationEditionID
 WHERE post_title <> '' 
   AND prpbar_Name <> ''
   AND post_status IN ('publish', 'future')
   AND prpbar_PublicationCode = 'BP'
   AND CRM.dbo.ufn_GetWordPressBluePrintsEdition(ID) = prpbed_Name
ORDER BY post_date, prpbed_Name
*/

USE CRM
IF EXISTS  (SELECT * FROM dbo.sysobjects  WHERE id = object_id(N'[dbo].[ufn_WPTemp]') AND xtype in (N'FN', N'IF', N'TF')) 
	DROP FUNCTION [dbo].[ufn_WPTemp]
GO

CREATE FUNCTION [dbo].[ufn_WPTemp] ( 
    @PublicationArticleID int
)
RETURNS varchar(2000)
AS
BEGIN
    -- Build a comma-delimited list of the Brands
    DECLARE @List varchar(2000)
    SELECT @List =  COALESCE(@List + ', ', '') + CAST(prpbarc_CompanyID as varchar(8))
      FROM PRPublicationArticleCompany
     WHERE prpbarc_PublicationArticleID = @PublicationArticleID
    ORDER BY prpbarc_CompanyID;

    RETURN @List;
END
GO


DELETE FROM WordPress.dbo.wp_postmeta WHERE meta_key = 'associated-companies'

INSERT INTO WordPress.dbo.wp_postmeta (post_id, meta_key, meta_value)
SELECT ID, 'associated-companies', CRM.dbo.ufn_WPTemp(prpbar_PublicationArticleID)
  FROM WordPress.dbo.wp_posts
       INNER JOIN CRM.dbo.PRPublicationArticle ON prpbar_Name LIKE '%' + post_title
	   INNER JOIN CRM.dbo.PRPublicationEdition ON prpbar_PublicationEditionID = prpbed_PublicationEditionID
 WHERE post_title <> '' 
   AND prpbar_Name <> ''
   AND post_status IN ('publish', 'future')
   AND prpbar_PublicationCode = 'BP'
   AND CRM.dbo.ufn_GetWordPressBluePrintsEdition(ID) = prpbed_Name
   AND prpbar_PublicationArticleID IN (SELECT DISTINCT prpbarc_PublicationArticleID FROM PRPublicationArticleCompany)
ORDER BY ID

--DELETE FROM CRM.dbo.PRWordPressPostCompany
INSERT INTO CRM.dbo.PRWordPressPostCompany (prwpc_PostID, prwpc_CompanyID)
SELECT ID, prpbarc_CompanyID
  FROM WordPress.dbo.wp_posts
       INNER JOIN CRM.dbo.PRPublicationArticle ON prpbar_Name LIKE '%' + post_title
	   INNER JOIN CRM.dbo.PRPublicationEdition ON prpbar_PublicationEditionID = prpbed_PublicationEditionID
	   INNER JOIN CRM.dbo.PRPublicationArticleCompany ON prpbar_PublicationArticleID = prpbarc_PublicationArticleID
 WHERE post_title <> '' 
   AND prpbar_Name <> ''
   AND post_status IN ('publish', 'future')
   AND prpbar_PublicationCode = 'BP'
   AND CRM.dbo.ufn_GetWordPressBluePrintsEdition(ID) = prpbed_Name
   AND prpbarc_CompanyID IS NOT NULL
ORDER BY post_date, prpbed_Name


IF EXISTS  (SELECT * FROM dbo.sysobjects  WHERE id = object_id(N'[dbo].[ufn_WPTemp]') AND xtype in (N'FN', N'IF', N'TF')) 
	DROP FUNCTION [dbo].[ufn_WPTemp]
GO

/*
UPDATE PRState SET prst_State='Ciudad de Mexico', prst_Abbreviation='CDMX', prst_BookOrder=65 WHERE prst_StateID=74
*/
GO

UPDATE PRClassification SET prcl_Description = NULL WHERE prcl_ClassificationID=1415 AND prcl_Name = 'Leasing'
GO

/* SPANISH TRANSLATION CHANGES */
/* EXCEL FORMULAS THAT CREATED THESE ARE ON JMT LOCAL MACHINE - T:\BBS Translation file 3-12-18_Final (002).xlsx */
EXEC usp_AccpacCreateTextField 'NewProduct', 'prod_Name_ES', 'Product Name', 50, 100 
EXEC usp_AccpacCreateTextField 'NewProduct', 'prod_PRDescription_ES', 'Product Description', 50, 2500
EXEC usp_AccpacCreateTextField 'PRAttribute', 'prat_Name_ES', 'Attribute Name', 50, 100
EXEC usp_AccpacCreateTextField 'PRCommodity', 'prcm_FullName_ES', 'Commodity Full Name', 50, 100
EXEC usp_AccpacCreateTextField 'PRCountry', 'prcn_Country_ES', 'Country Name', 50, 30
EXEC usp_AccpacCreateTextField 'PRState', 'prst_State_ES', 'State', 50, 30
Go

UPDATE NewProduct SET prod_name_ES='Informe Comercial', prod_PRDescription_ES='<div style="font-weight:bold">Informe comercial de Blue Book que incluye la Información de crédito de Experian</div><p style="margin-top:0em">Los acreedores como los vendedores, transportistas y proveedores utilizan este tipo de informe para realizar una evaluación de cuentas de alto nivel, en las que generalmente existe un interés específico en los datos actuales y de tendencia como experiencias de pago y comerciales. La presentación tabular y gráfica de la información de clasificación de la compañía hace que sea fácil y rápido tomar decisiones informadas.</p><p>El Informe comercial incluye:  información de propiedad, información básica de contacto de la compañía como # de ID de Blue Book, nombre de la compañía, ubicación del perfil de empresa, direcciones, teléfonos, faxes, correos electrónicos, URL del sitio Web y nombres comerciales alternos. También se incluye, si está disponible/aplica, la calificación actual de la sede y la definicion, con la tendencia de la calificación, año de Miembro Comercial, desarrollos recientes de la compañía, eventos de bancarrota, antecedentes comerciales, antecedentes personales, Perfil de operaciones, información financiera, resumen de informe comercial a la fecha, informes comerciales de los ultimos 2 años, detalles del informe comercial durante los últimos 18 meses, el actual Puntaje de crédito del Blue Book, el historial Puntaje de crédito del Blue Book, negocios afiliados y ubicaciones de las sucursales. Seleccione la información de crédito como información de registro público, presentaciones legales/pago comercial y datos comerciales proporcionados por <span style="font-weight:bold">Experian</span>, se incluirán con su Informe comercial, según esté disponible/aplique. Cuando se utiliza junto con los datos de Blue Book, la información proporcionada por <span style="font-weight:bold">Experian</span> puede ayudarle a obtener una imagen integral financiera de una compañía como un todo, incluso las actividades financieras fuera de la industria de producción.</p>' WHERE prod_ProductID=47
UPDATE NewProduct SET prod_name_ES='Servicio de Blue Book: 150', prod_PRDescription_ES='<ul class="Bullets"><li>3 licencias de usuarios en línea de Blue Book</li><li>10 informes comerciales</li></ul>' WHERE prod_ProductID=4
UPDATE NewProduct SET prod_name_ES='Servicio de Blue Book: 200', prod_PRDescription_ES='<ul class="Bullets"><li>5 licencias de usuarios en línea de Blue Book</li><li>20 informes comerciales</li></ul>' WHERE prod_ProductID=5
UPDATE NewProduct SET prod_name_ES='Servicio de Blue Book: 300', prod_PRDescription_ES='<ul class="Bullets"><li>10 licencias de usuarios en línea de Blue Book</li><li>85 informes comerciales</li></ul>' WHERE prod_ProductID=6
UPDATE NewProduct SET prod_name_ES='Servicio de Blue Book: 350', prod_PRDescription_ES='<ul class="Bullets"><li>20 licencias de usuario en línea de Blue Book</li><li>150 informes comerciales </li></ul>' WHERE prod_ProductID=7
UPDATE NewProduct SET prod_name_ES='Licencias Avanzadas de BBOS', prod_PRDescription_ES='Proporciona acceso avanzado a las funciones en línea y le permite buscar empresas recién incluidas y personal de la industria. Busca compañías por radio y central de mercados. Visualiza y busca actualizaciones de la compañía y guarda información importante de contacto en un formato vCard en Outlook.' WHERE prod_ProductID=10
UPDATE NewProduct SET prod_name_ES='Licencia Básica de BBOS', prod_PRDescription_ES='' WHERE prod_ProductID=69
UPDATE NewProduct SET prod_name_ES='Licencia Intermedia de BBOS', prod_PRDescription_ES='Proporciona acceso intermedio a las funciones en línea y le permite buscar compañías por teléfono, fax y correo electrónico, código postal, productos, clasificaciones y licencias (por ejemplo, PACA, DRC, CFIA). Visualiza las sucursales y afiliaciones de la compañía. Guarda sus criterios de búsqueda para una recuperación futura y exporta los resultados en Excel. Crea y guarda notas con funciones privadas sobre las compañías y las personas.' WHERE prod_ProductID=9
UPDATE NewProduct SET prod_name_ES='Licencia Limitada de BBOS', prod_PRDescription_ES='Proporciona acceso limitado a las funciones en línea y le permite buscar compañías por nombre, ciudad y estado. Accede a informes comerciales, información de referencia, artículos de planos actuales y archivados, crear listas de cuenta para imprimir, y leer artículos nuevos sobre compañías privadas y públicas.' WHERE prod_ProductID=8
UPDATE NewProduct SET prod_name_ES='Licencia Premium de BBOS', prod_PRDescription_ES='Proporciona acceso Premium para las funciones en línea y le permite ver el Puntaje de crédito del Blue Book. Tome decisiones de crédito calificadas comparando cuentas, utilizando herramientas de tasas analíticas. Buscar por el Puntaje de crédito del Blue Book.' WHERE prod_ProductID=11
UPDATE NewProduct SET prod_Name_ES='10 Informes Comerciales En Línea Adicionales', prod_PRDescription_ES=NULL WHERE prod_ProductID=13
UPDATE NewProduct SET prod_Name_ES='15 Informes Comerciales En Línea Adicionales', prod_PRDescription_ES=NULL WHERE prod_ProductID=14
UPDATE NewProduct SET prod_Name_ES='20 Informes Comerciales En Línea Adicionales', prod_PRDescription_ES=NULL WHERE prod_ProductID=15
UPDATE NewProduct SET prod_Name_ES='40 Informes Comerciales En Línea Adicionales', prod_PRDescription_ES=NULL WHERE prod_ProductID=16
UPDATE NewProduct SET prod_Name_ES='5 Informes Comerciales En Línea Adicionales', prod_PRDescription_ES=NULL WHERE prod_ProductID=12
UPDATE NewProduct SET prod_Name_ES='El Servicio Fuente de Datos de Productores Y Producto Local', prod_PRDescription_ES=NULL WHERE prod_ProductID=83
UPDATE NewProduct SET prod_Name_ES='Licencia del Servicio Fuente de Datos de Productores Y Producto Local', prod_PRDescription_ES=NULL WHERE prod_ProductID=84


UPDATE Custom_Captions SET capt_ES='Guía de Referencia' WHERE capt_family='BBOSLCSearchPublicationCode   ' AND capt_Code = 'BBR'
UPDATE Custom_Captions SET capt_ES='Guía de Membresía' WHERE capt_family='BBOSLCSearchPublicationCode   ' AND capt_Code = 'BBS'
UPDATE Custom_Captions SET capt_ES='Diario Trimestral Blueprints ' WHERE capt_family='BBOSLCSearchPublicationCode   ' AND capt_Code = 'BP'
UPDATE Custom_Captions SET capt_ES='Artículos Únicamente En Línea Blueprints ' WHERE capt_family='BBOSLCSearchPublicationCode   ' AND capt_Code = 'BPO'
UPDATE Custom_Captions SET capt_ES='Suplemento Del Diario Trimestral Blueprints' WHERE capt_family='BBOSLCSearchPublicationCode   ' AND capt_Code = 'BPS'
UPDATE Custom_Captions SET capt_ES='Conozca Sus Productos' WHERE capt_family='BBOSLCSearchPublicationCode   ' AND capt_Code = 'KYC'
UPDATE Custom_Captions SET capt_ES='Capacitación' WHERE capt_family='BBOSLCSearchPublicationCode   ' AND capt_Code = 'TRN'
UPDATE Custom_Captions SET capt_ES='Incluidos' WHERE capt_family='BBOSListingStatusSearch       ' AND capt_Code = 'L,H,LUV'
UPDATE Custom_Captions SET capt_ES='Incluidos y Recientemente Cerrados' WHERE capt_family='BBOSListingStatusSearch       ' AND capt_Code = 'L,H,LUV,N5'
UPDATE Custom_Captions SET capt_ES='Anteriormente Incluidos' WHERE capt_family='BBOSListingStatusSearch       ' AND capt_Code = 'N3,N5,N6'
UPDATE Custom_Captions SET capt_ES='Producto' WHERE capt_family='BBOSSearchIndustryType        ' AND capt_Code = 'P'
UPDATE Custom_Captions SET capt_ES='Suministro' WHERE capt_family='BBOSSearchIndustryType        ' AND capt_Code = 'S'
UPDATE Custom_Captions SET capt_ES='Transporte' WHERE capt_family='BBOSSearchIndustryType        ' AND capt_Code = 'T'
UPDATE Custom_Captions SET capt_ES='Excluir Fuente Local' WHERE capt_family='BBOSSearchLocalSoruce         ' AND capt_Code = 'ELS'
UPDATE Custom_Captions SET capt_ES='Incluir Fuente Local' WHERE capt_family='BBOSSearchLocalSoruce         ' AND capt_Code = 'ILS'
UPDATE Custom_Captions SET capt_ES='Limitar a Fuente Local' WHERE capt_family='BBOSSearchLocalSoruce         ' AND capt_Code = 'LSO'
UPDATE Custom_Captions SET capt_ES='10 por Página' WHERE capt_family='BBOSTESRequestGridPageSize    ' AND capt_Code = '10'
UPDATE Custom_Captions SET capt_ES='25 por Página' WHERE capt_family='BBOSTESRequestGridPageSize    ' AND capt_Code = '25'
UPDATE Custom_Captions SET capt_ES='5 por Página' WHERE capt_family='BBOSTESRequestGridPageSize    ' AND capt_Code = '5'
UPDATE Custom_Captions SET capt_ES='Todo' WHERE capt_family='BBOSTESRequestGridPageSize    ' AND capt_Code = '9999999'
UPDATE Custom_Captions SET capt_ES='Madera' WHERE capt_family='comp_PRIndustryType           ' AND capt_Code = 'L'
UPDATE Custom_Captions SET capt_ES='Producto' WHERE capt_family='comp_PRIndustryType           ' AND capt_Code = 'P'
UPDATE Custom_Captions SET capt_ES='Suministro y Servicio' WHERE capt_family='comp_PRIndustryType           ' AND capt_Code = 'S'
UPDATE Custom_Captions SET capt_ES='Transporte' WHERE capt_family='comp_PRIndustryType           ' AND capt_Code = 'T'
UPDATE Custom_Captions SET capt_ES='Eliminado Antes de Desplazamiento' WHERE capt_family='comp_PRListingStatus          ' AND capt_Code = 'D'
UPDATE Custom_Captions SET capt_ES='Retenido' WHERE capt_family='comp_PRListingStatus          ' AND capt_Code = 'H'
UPDATE Custom_Captions SET capt_ES='Listado' WHERE capt_family='comp_PRListingStatus          ' AND capt_Code = 'L'
UPDATE Custom_Captions SET capt_ES='Verificación de Perfil de Empresa Pendiente' WHERE capt_family='comp_PRListingStatus          ' AND capt_Code = 'LUV'
UPDATE Custom_Captions SET capt_ES='No Listado - Únicamente Servicio' WHERE capt_family='comp_PRListingStatus          ' AND capt_Code = 'N1'
UPDATE Custom_Captions SET capt_ES='No Listado - Prospecto de Membresía de Perfil de Empresa ' WHERE capt_family='comp_PRListingStatus          ' AND capt_Code = 'N2'
UPDATE Custom_Captions SET capt_ES='No Listado - Sin factor' WHERE capt_family='comp_PRListingStatus          ' AND capt_Code = 'N3'
UPDATE Custom_Captions SET capt_ES='No Listado - Perfil de Empresa Anteriormente/Prospecto M' WHERE capt_family='comp_PRListingStatus          ' AND capt_Code = 'N4'
UPDATE Custom_Captions SET capt_ES='No Listado - Recientemente Fuera de Negocios' WHERE capt_family='comp_PRListingStatus          ' AND capt_Code = 'N5'
UPDATE Custom_Captions SET capt_ES='No Listado - Fuera Del Negocio' WHERE capt_family='comp_PRListingStatus          ' AND capt_Code = 'N6'
UPDATE Custom_Captions SET capt_ES='Sucursal' WHERE capt_family='comp_PRType                   ' AND capt_Code = 'B'
UPDATE Custom_Captions SET capt_ES='Oficina Central' WHERE capt_family='comp_PRType                   ' AND capt_Code = 'H'
UPDATE Custom_Captions SET capt_ES='CSV' WHERE capt_family='ContactExportFormat           ' AND capt_Code = 'CSV'
UPDATE Custom_Captions SET capt_ES='MS Outlook' WHERE capt_family='ContactExportFormat           ' AND capt_Code = 'MSO'
UPDATE Custom_Captions SET capt_ES='1 día' WHERE capt_family='NewListingDaysOld             ' AND capt_Code = '1'
UPDATE Custom_Captions SET capt_ES='2 semanas' WHERE capt_family='NewListingDaysOld             ' AND capt_Code = '14'
UPDATE Custom_Captions SET capt_ES='6 meses' WHERE capt_family='NewListingDaysOld             ' AND capt_Code = '180'
UPDATE Custom_Captions SET capt_ES='9 meses' WHERE capt_family='NewListingDaysOld             ' AND capt_Code = '270'
UPDATE Custom_Captions SET capt_ES='1 mes' WHERE capt_family='NewListingDaysOld             ' AND capt_Code = '30'
UPDATE Custom_Captions SET capt_ES='12 meses' WHERE capt_family='NewListingDaysOld             ' AND capt_Code = '365'
UPDATE Custom_Captions SET capt_ES='2 meses' WHERE capt_family='NewListingDaysOld             ' AND capt_Code = '60'
UPDATE Custom_Captions SET capt_ES='1 semana' WHERE capt_family='NewListingDaysOld             ' AND capt_Code = '7'
UPDATE Custom_Captions SET capt_ES='3 meses' WHERE capt_family='NewListingDaysOld             ' AND capt_Code = '90'
UPDATE Custom_Captions SET capt_ES='por Industria' WHERE capt_family='peli_PRCSSortOption           ' AND capt_Code = 'I'
UPDATE Custom_Captions SET capt_ES='por Industria, luego por Cambios Clave' WHERE capt_family='peli_PRCSSortOption           ' AND capt_Code = 'I-K'
UPDATE Custom_Captions SET capt_ES='por Cambios Clave, luego por Industria' WHERE capt_family='peli_PRCSSortOption           ' AND capt_Code = 'K-I'
UPDATE Custom_Captions SET capt_ES='por Cambios Clave' WHERE capt_family='peli_PRCSSortOption           ' AND capt_Code = 'K-L'
UPDATE Custom_Captions SET capt_ES='por Ubicación' WHERE capt_family='peli_PRCSSortOption           ' AND capt_Code = 'L'
UPDATE Custom_Captions SET capt_ES='Administración' WHERE capt_family='peli_PRRole                   ' AND capt_Code = 'A'
UPDATE Custom_Captions SET capt_ES='Compras/Adquisiciones' WHERE capt_family='peli_PRRole                   ' AND capt_Code = 'B'
UPDATE Custom_Captions SET capt_ES='Crédito' WHERE capt_family='peli_PRRole                   ' AND capt_Code = 'C'
UPDATE Custom_Captions SET capt_ES='Ejecutivo' WHERE capt_family='peli_PRRole                   ' AND capt_Code = 'E'
UPDATE Custom_Captions SET capt_ES='Finanzas' WHERE capt_family='peli_PRRole                   ' AND capt_Code = 'F'
UPDATE Custom_Captions SET capt_ES='Jefe de Compras' WHERE capt_family='peli_PRRole                   ' AND capt_Code = 'HB'
UPDATE Custom_Captions SET capt_ES='Jefe de Crédito' WHERE capt_family='peli_PRRole                   ' AND capt_Code = 'HC'
UPDATE Custom_Captions SET capt_ES='Jefe Ejecutivo' WHERE capt_family='peli_PRRole                   ' AND capt_Code = 'HE'
UPDATE Custom_Captions SET capt_ES='Jefe de Finanzas' WHERE capt_family='peli_PRRole                   ' AND capt_Code = 'HF'
UPDATE Custom_Captions SET capt_ES='Jefe de Tecnología de Información' WHERE capt_family='peli_PRRole                   ' AND capt_Code = 'HI'
UPDATE Custom_Captions SET capt_ES='Jefe de Mercadeo' WHERE capt_family='peli_PRRole                   ' AND capt_Code = 'HM'
UPDATE Custom_Captions SET capt_ES='Jefe de Operaciones' WHERE capt_family='peli_PRRole                   ' AND capt_Code = 'HO'
UPDATE Custom_Captions SET capt_ES='Jefe de Ventas' WHERE capt_family='peli_PRRole                   ' AND capt_Code = 'HS'
UPDATE Custom_Captions SET capt_ES='Jefe de Transporte' WHERE capt_family='peli_PRRole                   ' AND capt_Code = 'HT'
UPDATE Custom_Captions SET capt_ES='Tecnología de Información' WHERE capt_family='peli_PRRole                   ' AND capt_Code = 'I'
UPDATE Custom_Captions SET capt_ES='Mercadeo' WHERE capt_family='peli_PRRole                   ' AND capt_Code = 'K'
UPDATE Custom_Captions SET capt_ES='Gerente' WHERE capt_family='peli_PRRole                   ' AND capt_Code = 'M'
UPDATE Custom_Captions SET capt_ES='Operaciones' WHERE capt_family='peli_PRRole                   ' AND capt_Code = 'O'
UPDATE Custom_Captions SET capt_ES='Ventas' WHERE capt_family='peli_PRRole                   ' AND capt_Code = 'S'
UPDATE Custom_Captions SET capt_ES='Transporte/Despacho' WHERE capt_family='peli_PRRole                   ' AND capt_Code = 'T'
UPDATE Custom_Captions SET capt_ES='País de Origen' WHERE capt_family='prat_Type                     ' AND capt_Code = 'CO'
UPDATE Custom_Captions SET capt_ES='Método De Produccion' WHERE capt_family='prat_Type                     ' AND capt_Code = 'GM'
UPDATE Custom_Captions SET capt_ES='Tamaño del Grupo' WHERE capt_family='prat_Type                     ' AND capt_Code = 'SG'
UPDATE Custom_Captions SET capt_ES='Estado de Origen' WHERE capt_family='prat_Type                     ' AND capt_Code = 'SO'
UPDATE Custom_Captions SET capt_ES='Estilo' WHERE capt_family='prat_Type                     ' AND capt_Code = 'ST'
UPDATE Custom_Captions SET capt_ES='Tratamiento' WHERE capt_family='prat_Type                     ' AND capt_Code = 'TR'
UPDATE Custom_Captions SET capt_ES='África' WHERE capt_family='prcn_Region                   ' AND capt_Code = 'AF'
UPDATE Custom_Captions SET capt_ES='Australia/Nueva Zelanda' WHERE capt_family='prcn_Region                   ' AND capt_Code = 'ANZ'
UPDATE Custom_Captions SET capt_ES='Asia' WHERE capt_family='prcn_Region                   ' AND capt_Code = 'AS'
UPDATE Custom_Captions SET capt_ES='Centro América' WHERE capt_family='prcn_Region                   ' AND capt_Code = 'CA'
UPDATE Custom_Captions SET capt_ES='Caribe' WHERE capt_family='prcn_Region                   ' AND capt_Code = 'CR'
UPDATE Custom_Captions SET capt_ES='Europa' WHERE capt_family='prcn_Region                   ' AND capt_Code = 'EU'
UPDATE Custom_Captions SET capt_ES='Medio Oriente' WHERE capt_family='prcn_Region                   ' AND capt_Code = 'ME'
UPDATE Custom_Captions SET capt_ES='Norte América' WHERE capt_family='prcn_Region                   ' AND capt_Code = 'NA'
UPDATE Custom_Captions SET capt_ES='Zona del Pacífico' WHERE capt_family='prcn_Region                   ' AND capt_Code = 'PR'
UPDATE Custom_Captions SET capt_ES='Sur América' WHERE capt_family='prcn_Region                   ' AND capt_Code = 'SA'
UPDATE Custom_Captions SET capt_ES='Cooperativa' WHERE capt_family='prcp_CorporateStructure       ' AND capt_Code = 'COOP'
UPDATE Custom_Captions SET capt_ES='Corporación' WHERE capt_family='prcp_CorporateStructure       ' AND capt_Code = 'CORP'
UPDATE Custom_Captions SET capt_ES='Sociedad Anónima' WHERE capt_family='prcp_CorporateStructure       ' AND capt_Code = 'LLC'
UPDATE Custom_Captions SET capt_ES='Sociedad de Responsabilidad Limitada' WHERE capt_family='prcp_CorporateStructure       ' AND capt_Code = 'LLP'
UPDATE Custom_Captions SET capt_ES='Sociedad Limitada' WHERE capt_family='prcp_CorporateStructure       ' AND capt_Code = 'LPART'
UPDATE Custom_Captions SET capt_ES='Sociedad' WHERE capt_family='prcp_CorporateStructure       ' AND capt_Code = 'PART'
UPDATE Custom_Captions SET capt_ES='Propietario Único' WHERE capt_family='prcp_CorporateStructure       ' AND capt_Code = 'PROP'
UPDATE Custom_Captions SET capt_ES='Compañía de Responsabilidad Ilimitada' WHERE capt_family='prcp_CorporateStructure       ' AND capt_Code = 'ULC'
UPDATE Custom_Captions SET capt_ES='5' WHERE capt_family='prcp_Volume                   ' AND capt_Code = '01'
UPDATE Custom_Captions SET capt_ES='10' WHERE capt_family='prcp_Volume                   ' AND capt_Code = '02'
UPDATE Custom_Captions SET capt_ES='15' WHERE capt_family='prcp_Volume                   ' AND capt_Code = '03'
UPDATE Custom_Captions SET capt_ES='20' WHERE capt_family='prcp_Volume                   ' AND capt_Code = '04'
UPDATE Custom_Captions SET capt_ES='25' WHERE capt_family='prcp_Volume                   ' AND capt_Code = '05'
UPDATE Custom_Captions SET capt_ES='40' WHERE capt_family='prcp_Volume                   ' AND capt_Code = '06'
UPDATE Custom_Captions SET capt_ES='50' WHERE capt_family='prcp_Volume                   ' AND capt_Code = '07'
UPDATE Custom_Captions SET capt_ES='75' WHERE capt_family='prcp_Volume                   ' AND capt_Code = '08'
UPDATE Custom_Captions SET capt_ES='100' WHERE capt_family='prcp_Volume                   ' AND capt_Code = '09'
UPDATE Custom_Captions SET capt_ES='150' WHERE capt_family='prcp_Volume                   ' AND capt_Code = '10'
UPDATE Custom_Captions SET capt_ES='200' WHERE capt_family='prcp_Volume                   ' AND capt_Code = '11'
UPDATE Custom_Captions SET capt_ES='250' WHERE capt_family='prcp_Volume                   ' AND capt_Code = '12'
UPDATE Custom_Captions SET capt_ES='300' WHERE capt_family='prcp_Volume                   ' AND capt_Code = '13'
UPDATE Custom_Captions SET capt_ES='350' WHERE capt_family='prcp_Volume                   ' AND capt_Code = '14'
UPDATE Custom_Captions SET capt_ES='400' WHERE capt_family='prcp_Volume                   ' AND capt_Code = '15'
UPDATE Custom_Captions SET capt_ES='500' WHERE capt_family='prcp_Volume                   ' AND capt_Code = '16'
UPDATE Custom_Captions SET capt_ES='600' WHERE capt_family='prcp_Volume                   ' AND capt_Code = '17'
UPDATE Custom_Captions SET capt_ES='700' WHERE capt_family='prcp_Volume                   ' AND capt_Code = '18'
UPDATE Custom_Captions SET capt_ES='750' WHERE capt_family='prcp_Volume                   ' AND capt_Code = '19'
UPDATE Custom_Captions SET capt_ES='800' WHERE capt_family='prcp_Volume                   ' AND capt_Code = '20'
UPDATE Custom_Captions SET capt_ES='900' WHERE capt_family='prcp_Volume                   ' AND capt_Code = '21'
UPDATE Custom_Captions SET capt_ES='1000' WHERE capt_family='prcp_Volume                   ' AND capt_Code = '22'
UPDATE Custom_Captions SET capt_ES='1250' WHERE capt_family='prcp_Volume                   ' AND capt_Code = '23'
UPDATE Custom_Captions SET capt_ES='1500' WHERE capt_family='prcp_Volume                   ' AND capt_Code = '24'
UPDATE Custom_Captions SET capt_ES='1750' WHERE capt_family='prcp_Volume                   ' AND capt_Code = '25'
UPDATE Custom_Captions SET capt_ES='2000' WHERE capt_family='prcp_Volume                   ' AND capt_Code = '26'
UPDATE Custom_Captions SET capt_ES='2500' WHERE capt_family='prcp_Volume                   ' AND capt_Code = '27'
UPDATE Custom_Captions SET capt_ES='3000' WHERE capt_family='prcp_Volume                   ' AND capt_Code = '28'
UPDATE Custom_Captions SET capt_ES='4000' WHERE capt_family='prcp_Volume                   ' AND capt_Code = '29'
UPDATE Custom_Captions SET capt_ES='5000' WHERE capt_family='prcp_Volume                   ' AND capt_Code = '30'
UPDATE Custom_Captions SET capt_ES='6000' WHERE capt_family='prcp_Volume                   ' AND capt_Code = '31'
UPDATE Custom_Captions SET capt_ES='7000' WHERE capt_family='prcp_Volume                   ' AND capt_Code = '32'
UPDATE Custom_Captions SET capt_ES='8000' WHERE capt_family='prcp_Volume                   ' AND capt_Code = '33'
UPDATE Custom_Captions SET capt_ES='10000' WHERE capt_family='prcp_Volume                   ' AND capt_Code = '34'
UPDATE Custom_Captions SET capt_ES='15000' WHERE capt_family='prcp_Volume                   ' AND capt_Code = '35'
UPDATE Custom_Captions SET capt_ES='20000' WHERE capt_family='prcp_Volume                   ' AND capt_Code = '36'
UPDATE Custom_Captions SET capt_ES='30000' WHERE capt_family='prcp_Volume                   ' AND capt_Code = '37'
UPDATE Custom_Captions SET capt_ES='40000' WHERE capt_family='prcp_Volume                   ' AND capt_Code = '38'
UPDATE Custom_Captions SET capt_ES='50000' WHERE capt_family='prcp_Volume                   ' AND capt_Code = '39'
UPDATE Custom_Captions SET capt_ES='65000' WHERE capt_family='prcp_Volume                   ' AND capt_Code = '40'
UPDATE Custom_Captions SET capt_ES='Más de 100000' WHERE capt_family='prcp_Volume                   ' AND capt_Code = '50'
UPDATE Custom_Captions SET capt_ES='La mayoría del patrimonio neto representado por los activos intangibles y/o cantidades que son propiedad de los afiliados o directores.' WHERE capt_family='prcw_Name                     ' AND capt_Code = '(142)'
UPDATE Custom_Captions SET capt_ES='La mayoría del patrimonio neto representado por activos fijos.' WHERE capt_family='prcw_Name                     ' AND capt_Code = '(143)'
UPDATE Custom_Captions SET capt_ES='Evaluación de solvencia no asignada' WHERE capt_family='prcw_Name                     ' AND capt_Code = '(144)'
UPDATE Custom_Captions SET capt_ES='Las cifras financieras más recientes reflejan un capital de trabajo negativo y/o una posición de valor neto negativo.' WHERE capt_family='prcw_Name                     ' AND capt_Code = '(145)'
UPDATE Custom_Captions SET capt_ES='El estado de cuenta financiero de esta subsidiaria no disponible. La compañía matriz proporciona cifras financieras consolidadas incluyendo subsidiarias.' WHERE capt_family='prcw_Name                     ' AND capt_Code = '(150)'
UPDATE Custom_Captions SET capt_ES='La solvencia de crédito reportado es ambiguo.' WHERE capt_family='prcw_Name                     ' AND capt_Code = '(154)'
UPDATE Custom_Captions SET capt_ES='La información financiera dificulta asignar la calificación de Solvencia definitiva, la calificación de las prácticas comerciales es respaldada por informes comerciales.' WHERE capt_family='prcw_Name                     ' AND capt_Code = '(62)'
UPDATE Custom_Captions SET capt_ES='Información financiera enviada, pero los informes comerciales prohíben la asignación de la calificación de Solvencia.' WHERE capt_family='prcw_Name                     ' AND capt_Code = '(68)'
UPDATE Custom_Captions SET capt_ES='Posición financiera bajo revisión.' WHERE capt_family='prcw_Name                     ' AND capt_Code = '(78)'
UPDATE Custom_Captions SET capt_ES='Calificación de Solvencia financiera retirada - La Información financiera ya no es actual.' WHERE capt_family='prcw_Name                     ' AND capt_Code = '(79)'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $10,000,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '10,000K'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $10,000,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '10,000M'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $100,000,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '100,000K'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $100,000,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '100,000M'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $1,000,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '1000K'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $1,000,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '1000M'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $100,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '100K'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $100,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '100M'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $10,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '10K'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $10,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '10M'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $15,000,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '15,000K'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $15,000,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '15,000M'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $1,500,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '1500K'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $1,500,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '1500M'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $150,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '150K'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $150,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '150M'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $15,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '15K'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $15,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '15M'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $20,000,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '20,000K'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $20,000,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '20,000M'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $2,000,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '2000K'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $2,000,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '2000M'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $200,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '200K'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $200,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '200M'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $20,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '20K'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $20,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '20M'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $25,000,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '25,000K'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $25,000,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '25,000M'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $250,000,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '250,000K'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $250,000,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '250,000M'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $2,500,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '2500K'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $2,500,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '2500M'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $250,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '250K'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $250,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '250M'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $25,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '25K'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $25,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '25M'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $30,000,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '30,000K'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $30,000,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '30,000M'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $3,000,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '3000K'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $3,000,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '3000M'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $300,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '300K'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $300,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '300M'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $40,000,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '40,000K'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $40,000,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '40,000M'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $4,000,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '4000K'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $4,000,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '4000M'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $400,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '400K'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $400,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '400M'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $40,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '40K'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $40,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '40M'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $50,000,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '50,000K'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $50,000,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '50,000M'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $500,000,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '500,000K'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $500,000,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '500,000M'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $5,000,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '5000K'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $5,000,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '5000M'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $500,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '500K'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $500,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '500M'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $50,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '50K'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $50,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '50M'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $5,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '5K'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $5,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '5M'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $75,000,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '75,000K'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $75,000,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '75,000M'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $7,500,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '7500K'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $7,500,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '7500M'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $750,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '750K'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $750,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '750M'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $75,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '75K'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estándar de $75,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '75M'
UPDATE Custom_Captions SET capt_ES='Valor de crédito estimado menor que $1,000' WHERE capt_family='prcw_Name                     ' AND capt_Code = '-M'
UPDATE Custom_Captions SET capt_ES='Deficiente' WHERE capt_family='prin_Name                     ' AND capt_Code = 'X'
UPDATE Custom_Captions SET capt_ES='Insatisfactorio' WHERE capt_family='prin_Name                     ' AND capt_Code = 'XX'
UPDATE Custom_Captions SET capt_ES='Informes conflictivos: algunos informan mejor que la experiencia XX.' WHERE capt_family='prin_Name                     ' AND capt_Code = 'XX147'
UPDATE Custom_Captions SET capt_ES='Bueno' WHERE capt_family='prin_Name                     ' AND capt_Code = 'XXX'
UPDATE Custom_Captions SET capt_ES='Informes conflictivos: algunos informan menos de XXX experiencias.' WHERE capt_family='prin_Name                     ' AND capt_Code = 'XXX148'
UPDATE Custom_Captions SET capt_ES='Excelente' WHERE capt_family='prin_Name                     ' AND capt_Code = 'XXXX'
UPDATE Custom_Captions SET capt_ES='Licencia de CFIA' WHERE capt_family='prli_Type                     ' AND capt_Code = 'CFIA'
UPDATE Custom_Captions SET capt_ES='DOT' WHERE capt_family='prli_Type                     ' AND capt_Code = 'DOT'
UPDATE Custom_Captions SET capt_ES='FF' WHERE capt_family='prli_Type                     ' AND capt_Code = 'FF'
UPDATE Custom_Captions SET capt_ES='MC' WHERE capt_family='prli_Type                     ' AND capt_Code = 'MC'
UPDATE Custom_Captions SET capt_ES='Licencia de PACA' WHERE capt_family='prli_Type                     ' AND capt_Code = 'PACA'
UPDATE Custom_Captions SET capt_ES='American Express' WHERE capt_family='prpay_CreditCardType          ' AND capt_Code = 'AE'
UPDATE Custom_Captions SET capt_ES='Discover Card' WHERE capt_family='prpay_CreditCardType          ' AND capt_Code = 'DC'
UPDATE Custom_Captions SET capt_ES='MasterCard' WHERE capt_family='prpay_CreditCardType          ' AND capt_Code = 'MC'
UPDATE Custom_Captions SET capt_ES='Visa' WHERE capt_family='prpay_CreditCardType          ' AND capt_Code = 'VISA'
UPDATE Custom_Captions SET capt_ES='Documento' WHERE capt_family='prpbar_MediaTypeCode          ' AND capt_Code = 'Doc'
UPDATE Custom_Captions SET capt_ES='Página Web' WHERE capt_family='prpbar_MediaTypeCode          ' AND capt_Code = 'URL'
UPDATE Custom_Captions SET capt_ES='Vídeo' WHERE capt_family='prpbar_MediaTypeCode          ' AND capt_Code = 'Video'
UPDATE Custom_Captions SET capt_ES='Los informes recibidos indican la variable de pago y/o más allá de los términos con los proveedores, suministradores y/o empresas de transporte.' WHERE capt_family='prpy_Name                     ' AND capt_Code = '(149)'
UPDATE Custom_Captions SET capt_ES='Pago es informado como variable; descripción de pago específico no asignable.' WHERE capt_family='prpy_Name                     ' AND capt_Code = '(81)'
UPDATE Custom_Captions SET capt_ES='15 a 21 días en promedio' WHERE capt_family='prpy_Name                     ' AND capt_Code = 'A'
UPDATE Custom_Captions SET capt_ES='1 a 14 días en promedio' WHERE capt_family='prpy_Name                     ' AND capt_Code = 'AA'
UPDATE Custom_Captions SET capt_ES='15 a 21 días en promedio' WHERE capt_family='prpy_Name                     ' AND capt_Code = 'AB'
UPDATE Custom_Captions SET capt_ES='22 a 28 días en promedio' WHERE capt_family='prpy_Name                     ' AND capt_Code = 'B'
UPDATE Custom_Captions SET capt_ES='29 a 35 días en promedio' WHERE capt_family='prpy_Name                     ' AND capt_Code = 'C'
UPDATE Custom_Captions SET capt_ES='36 a 45 días en promedio' WHERE capt_family='prpy_Name                     ' AND capt_Code = 'D'
UPDATE Custom_Captions SET capt_ES='46 a 60 días en promedio' WHERE capt_family='prpy_Name                     ' AND capt_Code = 'E'
UPDATE Custom_Captions SET capt_ES='Más de 60 días en promedio' WHERE capt_family='prpy_Name                     ' AND capt_Code = 'F'
UPDATE Custom_Captions SET capt_ES='Se reportó la solicitud de extensión general.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(1)'
UPDATE Custom_Captions SET capt_ES='Se reportó haber tenido una reunión con los acreedores.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(10)'
UPDATE Custom_Captions SET capt_ES='Se reportó daños provocados por incendio.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(105)'
UPDATE Custom_Captions SET capt_ES='Reportado en liquidación.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(108)'
UPDATE Custom_Captions SET capt_ES='Reportado acusado.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(11)'
UPDATE Custom_Captions SET capt_ES='Se reportaron operaciones suspendidas; se reportó que las obligaciones no se liquidaron en su totalidad.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(113)'
UPDATE Custom_Captions SET capt_ES='Perfil de empresa eliminado. No hay evidencia de operaciones continúas.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(114)'
UPDATE Custom_Captions SET capt_ES='Se reportó acusación cerrado.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(12)'
UPDATE Custom_Captions SET capt_ES='La calificación suspendia pendiente de reinvestigación.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(124)'
UPDATE Custom_Captions SET capt_ES='Se reportó la disolución de la sociedad.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(129)'
UPDATE Custom_Captions SET capt_ES='Se reportó la sentencia del juicio o gravamen en los registros públicos.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(13)'
UPDATE Custom_Captions SET capt_ES='Evaluacion suspendida. Informacion de comercio muy limitada para respaldar la evaluación actual.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(131)'
UPDATE Custom_Captions SET capt_ES='Calificación retirada.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(132)'
UPDATE Custom_Captions SET capt_ES='Membresía Comercial o Membresía de Transporte retirada.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(133)'
UPDATE Custom_Captions SET capt_ES='Se informó el uso del sello de Membresía comercial o Membresía de transporte y no estaba autorizado para hacerlo.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(134)'
UPDATE Custom_Captions SET capt_ES='Se reportó rechazo a arbitraje.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(135)'
UPDATE Custom_Captions SET capt_ES='El capital social o interés por propiedad adquiridos - cambio en la mayoría de propiedad.  La calificación de las prácticas comerciales continúan según los propietarios anteriores y/o ejecutivos principales que continúan con la ejecución de las operaciones diarias.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(136)'
UPDATE Custom_Captions SET capt_ES='Activos de una compañía anterior adquiridos - nueva entidad establecida.  La calificación de prácticas comerciales continúan según los propietarios anteriores y/o ejecutivos principales que continúan con la ejecución de las operaciones diarias de la nueva entidad.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(137)'
UPDATE Custom_Captions SET capt_ES='Se reportó que el receptor realizó una solicitud.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(14)'
UPDATE Custom_Captions SET capt_ES='Se reportó que una o más partes actualmente presentes asociadas estuvieron relacionadas de forma responsable con un negocio que descontinuó las operaciones con las obligaciones reportadas no liquidadas en su totalidad, la clasificación refleja los informes comerciales actuales.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(146)'
UPDATE Custom_Captions SET capt_ES='Se reportó el nombramiento del receptor.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(15)'
UPDATE Custom_Captions SET capt_ES='Se reportó la reinstalación de la licencia de PACA o CFIA.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(151)'
UPDATE Custom_Captions SET capt_ES='Se reportó la suspensión de la licencia de PACA o CFIA con sanciones impuesta a la compañía.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(152)'
UPDATE Custom_Captions SET capt_ES='Se reportó la revocación de la licencia de PACA o CFIA.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(153)'
UPDATE Custom_Captions SET capt_ES='Se reportó la multa o penalidad civil otorgada por el gobierno o agencia reguladora.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(155)'
UPDATE Custom_Captions SET capt_ES='Se reportó la cancelación de la membresía de la Corporación de Resolución de Controversias (DRC, en Inglés).' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(156)'
UPDATE Custom_Captions SET capt_ES='Se reportó que se expulsó al miembro de la Corporación de Resolución de Controversias (DRC, en Inglés).' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(157)'
UPDATE Custom_Captions SET capt_ES='Se reportó que se restableció la membresía de la Corporación de Resolución de Controversias (DRC, en Inglés).' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(158)'
UPDATE Custom_Captions SET capt_ES='Se reportó que se publicó un acuerdo de garantía o un título de garantía de USDA.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(159)'
UPDATE Custom_Captions SET capt_ES='Se reportó la presentación de un documento adjunto.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(16)'
UPDATE Custom_Captions SET capt_ES='Se reportó la presentación de la demanda en bancarrota.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(17)'
UPDATE Custom_Captions SET capt_ES='Se reportó la presentación de la demanda voluntaria en bancarrota.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(18)'
UPDATE Custom_Captions SET capt_ES='Se reportó la presentación de la demanda involuntaria en bancarrota.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(19)'
UPDATE Custom_Captions SET capt_ES='Se reportó la extensión general otorgada' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(2)'
UPDATE Custom_Captions SET capt_ES='Se reportó la declaración en bancarrota aprobada.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(20)'
UPDATE Custom_Captions SET capt_ES='Se reportó que el tribunal aprobó el plan de re-organización.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(21)'
UPDATE Custom_Captions SET capt_ES='Se reportó que se hizo o se acordó realizar pagos parciales o a plazos sobre un saldo pendiente o vencido.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(26)'
UPDATE Custom_Captions SET capt_ES='Se reportó pago más lento.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(27)'
UPDATE Custom_Captions SET capt_ES='Se reportó la solicitud de uno o más acreedores para la extensión temporal' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(3)'
UPDATE Custom_Captions SET capt_ES='Se reportó tener afiliacion con intermediarios de transporte.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(30)'
UPDATE Custom_Captions SET capt_ES='Se reportó tener afiliacion con embarcadores.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(31)'
UPDATE Custom_Captions SET capt_ES='Se reportó tener afiliacion con agencia de corredores.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(32)'
UPDATE Custom_Captions SET capt_ES='Se reportó tener afiliación con recibidores, vendedores locales y/o con distribuidores.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(35)'
UPDATE Custom_Captions SET capt_ES='Se reportó que uno o más acreedores otorgaron extensión temporal' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(4)'
UPDATE Custom_Captions SET capt_ES='Se reportó afiliación con una o más empresas o personas en la misma línea de negocios.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(40)'
UPDATE Custom_Captions SET capt_ES='Se reportó que tiene afiliaciones al por menor.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(45)'
UPDATE Custom_Captions SET capt_ES='Se reportó que tiene una relación de compras o ventas exclusivas o de restricción con otras empresas.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(46)'
UPDATE Custom_Captions SET capt_ES='Se reportó cheque o se aceptó giro, devuelto sin pagar.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(49)'
UPDATE Custom_Captions SET capt_ES='Se reportó oferta de compromiso' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(5)'
UPDATE Custom_Captions SET capt_ES='Se reportó haber licitado o emitido uno o más cheques prefechados.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(52)'
UPDATE Custom_Captions SET capt_ES='Se realizaron reclamos contra la empresa ante nosotros con un monto de $__.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(54)'
UPDATE Custom_Captions SET capt_ES='Se estableció un cobro o reclamo ante nosotros.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(55)'
UPDATE Custom_Captions SET capt_ES='Cobro o reclamo ante nosotros contra una empresa por la cantidad de $ ____.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(56)'
UPDATE Custom_Captions SET capt_ES='Se reportaron las deducciones tomadas por la empresa sin autorización ni prueba de reclamo por la cantidad de $ ____.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(57)'
UPDATE Custom_Captions SET capt_ES='Cobro o reclamo referido a una agencia externa.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(58)'
UPDATE Custom_Captions SET capt_ES='Se otorgó un mandato u orden de restricción temporal.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(6)'
UPDATE Custom_Captions SET capt_ES='La información comercial no es suficiente para respaldar una calificación definitiva.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(60)'
UPDATE Custom_Captions SET capt_ES='Se rechazó identificar y/o proporcionar información de antecedentes sobre los directores y/o proporcionar detalles sobre el negocio.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(63)'
UPDATE Custom_Captions SET capt_ES='Se reportó que se emitió un retiro voluntario del producto.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(64)'
UPDATE Custom_Captions SET capt_ES='Se reportó un compromiso con los acreedores.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(7)'
UPDATE Custom_Captions SET capt_ES='Practicas de pago bajo revisión.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(74)'
UPDATE Custom_Captions SET capt_ES='Bajo investigación; calificación bajo revisión.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(76)'
UPDATE Custom_Captions SET capt_ES='Se reportó la asignación realizada para beneficio de acreedores.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(8)'
UPDATE Custom_Captions SET capt_ES='La calificación indica la confianza comercial anunciada o paga esta ubicación (también vea la lista completa de la sede).' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(80)'
UPDATE Custom_Captions SET capt_ES='Los informes comerciales son demasiado limitados para asignar una calificación definitiva aunque uno o más informes reflejen el pago que se lleva a cabo más allá de los términos.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(82)'
UPDATE Custom_Captions SET capt_ES='Información con relación a circunstancias especiales disponible en el Informe comercial.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(83)'
UPDATE Custom_Captions SET capt_ES='Se reportó el funcionamiento bajo la supervisión del tribunal como parte de la presentación de bancarrota/reorganización.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(84)'
UPDATE Custom_Captions SET capt_ES='Informe comercial detallado disponible a solicitud.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(85)'
UPDATE Custom_Captions SET capt_ES='Consideraciones financieras y/o informes comerciales que prohíben la elaboración de una calificación definitiva. Informe comercial detallado disponible a solicitud.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(86)'
UPDATE Custom_Captions SET capt_ES='Se reportó el inicio reciente de negocios.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(87)'
UPDATE Custom_Captions SET capt_ES='Se reportó fuera del negocio.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(88)'
UPDATE Custom_Captions SET capt_ES='Se reportó esta sucursal eliminada.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(89)'
UPDATE Custom_Captions SET capt_ES='Se reportó reunión llamado de acreedores.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(9)'
UPDATE Custom_Captions SET capt_ES='Anteriormente surgió de bancarrota / reorganización.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(90)'
UPDATE Custom_Captions SET capt_ES='Se reportó la disolución de la sociedad.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(96)'
UPDATE Custom_Captions SET capt_ES='Sucedido por _________________.' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(99)'
UPDATE Custom_Captions SET capt_ES='Informe anteriormente reportado debe ser revisado para leer -' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(69)'
UPDATE Custom_Captions SET capt_ES='Lo siguiente es cambio en, o adición a, información al Perfil -' WHERE capt_family='prrn_Name                     ' AND capt_Code = '(71)'
UPDATE Custom_Captions SET capt_ES='facebook.com' WHERE capt_family='prsm_SocialMediaDomain        ' AND capt_Code = 'facebook'
UPDATE Custom_Captions SET capt_ES='linkedin.com' WHERE capt_family='prsm_SocialMediaDomain        ' AND capt_Code = 'linkedin'
UPDATE Custom_Captions SET capt_ES='twitter.com' WHERE capt_family='prsm_SocialMediaDomain        ' AND capt_Code = 'twitter'
UPDATE Custom_Captions SET capt_ES='youtube.com' WHERE capt_family='prsm_SocialMediaDomain        ' AND capt_Code = 'youtube'
UPDATE Custom_Captions SET capt_ES='Artículo de BluePrints' WHERE capt_family='prsuu_UsageTypeCode           ' AND capt_Code = 'BP'
UPDATE Custom_Captions SET capt_ES='Cancelado' WHERE capt_family='prsuu_UsageTypeCode           ' AND capt_Code = 'C'
UPDATE Custom_Captions SET capt_ES='Informe Comercial por Correo Electrónico' WHERE capt_family='prsuu_UsageTypeCode           ' AND capt_Code = 'EBR'
UPDATE Custom_Captions SET capt_ES='Informe Comercial por Fax' WHERE capt_family='prsuu_UsageTypeCode           ' AND capt_Code = 'FBR'
UPDATE Custom_Captions SET capt_ES='Informe Comercial por Correo' WHERE capt_family='prsuu_UsageTypeCode           ' AND capt_Code = 'MBR'
UPDATE Custom_Captions SET capt_ES='Informe Comercial En Linea' WHERE capt_family='prsuu_UsageTypeCode           ' AND capt_Code = 'OBR'
UPDATE Custom_Captions SET capt_ES='Búsqueda En Línea' WHERE capt_family='prsuu_UsageTypeCode           ' AND capt_Code = 'OLS'
UPDATE Custom_Captions SET capt_ES='Lista de Mercadeo en Línea' WHERE capt_family='prsuu_UsageTypeCode           ' AND capt_Code = 'OML'
UPDATE Custom_Captions SET capt_ES='Informe Comercial Verbal' WHERE capt_family='prsuu_UsageTypeCode           ' AND capt_Code = 'VBR'
UPDATE Custom_Captions SET capt_ES='Ninguno' WHERE capt_family='prtr_AmountPastDue            ' AND capt_Code = 'A'
UPDATE Custom_Captions SET capt_ES='Menos de 25 mil' WHERE capt_family='prtr_AmountPastDue            ' AND capt_Code = 'B'
UPDATE Custom_Captions SET capt_ES='25 mil a 100 mil' WHERE capt_family='prtr_AmountPastDue            ' AND capt_Code = 'C'
UPDATE Custom_Captions SET capt_ES='Más de 100 mil' WHERE capt_family='prtr_AmountPastDue            ' AND capt_Code = 'D'
UPDATE Custom_Captions SET capt_ES='10 Días' WHERE capt_family='prtr_CreditTerms              ' AND capt_Code = 'A'
UPDATE Custom_Captions SET capt_ES='21 Días' WHERE capt_family='prtr_CreditTerms              ' AND capt_Code = 'B'
UPDATE Custom_Captions SET capt_ES='30 Días' WHERE capt_family='prtr_CreditTerms              ' AND capt_Code = 'C'
UPDATE Custom_Captions SET capt_ES='Más Allá de 30 Días' WHERE capt_family='prtr_CreditTerms              ' AND capt_Code = 'D'
UPDATE Custom_Captions SET capt_ES='5 a 10 mil' WHERE capt_family='prtr_HighCredit               ' AND capt_Code = 'A'
UPDATE Custom_Captions SET capt_ES='10 a 50 mil' WHERE capt_family='prtr_HighCredit               ' AND capt_Code = 'B'
UPDATE Custom_Captions SET capt_ES='50 a 75 mil' WHERE capt_family='prtr_HighCredit               ' AND capt_Code = 'C'
UPDATE Custom_Captions SET capt_ES='75 a 100 mil' WHERE capt_family='prtr_HighCredit               ' AND capt_Code = 'D'
UPDATE Custom_Captions SET capt_ES='100 a 250 mil' WHERE capt_family='prtr_HighCredit               ' AND capt_Code = 'E'
UPDATE Custom_Captions SET capt_ES='Más de 250 mil' WHERE capt_family='prtr_HighCredit               ' AND capt_Code = 'F'
UPDATE Custom_Captions SET capt_ES='1 a 6 Meses' WHERE capt_family='prtr_LastDealtDate            ' AND capt_Code = 'A'
UPDATE Custom_Captions SET capt_ES='7 a 12 Meses' WHERE capt_family='prtr_LastDealtDate            ' AND capt_Code = 'B'
UPDATE Custom_Captions SET capt_ES='Más de 1 Año' WHERE capt_family='prtr_LastDealtDate            ' AND capt_Code = 'C'
UPDATE Custom_Captions SET capt_ES='Nunca' WHERE capt_family='prtr_LastDealtDate            ' AND capt_Code = 'D'
UPDATE Custom_Captions SET capt_ES='Deteriorarando' WHERE capt_family='prtr_OverallTrend             ' AND capt_Code = 'D'
UPDATE Custom_Captions SET capt_ES='Mejorando' WHERE capt_family='prtr_OverallTrend             ' AND capt_Code = 'I'
UPDATE Custom_Captions SET capt_ES='Sin Cambio' WHERE capt_family='prtr_OverallTrend             ' AND capt_Code = 'U'
UPDATE Custom_Captions SET capt_ES='Menos de 1 Año' WHERE capt_family='prtr_RelationshipLength       ' AND capt_Code = 'B'
UPDATE Custom_Captions SET capt_ES='1 a 10 Años' WHERE capt_family='prtr_RelationshipLength       ' AND capt_Code = 'C'
UPDATE Custom_Captions SET capt_ES='Más de 10 Años' WHERE capt_family='prtr_RelationshipLength       ' AND capt_Code = 'D'
UPDATE Custom_Captions SET capt_ES='General' WHERE capt_family='prwu_DefaultCompanySearchPage ' AND capt_Code = 'CompanySearch.aspx'
UPDATE Custom_Captions SET capt_ES='Clasificación' WHERE capt_family='prwu_DefaultCompanySearchPage ' AND capt_Code = 'CompanySearchClassification.aspx'
UPDATE Custom_Captions SET capt_ES='Producto' WHERE capt_family='prwu_DefaultCompanySearchPage ' AND capt_Code = 'CompanySearchCommodity.aspx'
UPDATE Custom_Captions SET capt_ES='Aduana' WHERE capt_family='prwu_DefaultCompanySearchPage ' AND capt_Code = 'CompanySearchCustom.aspx'
UPDATE Custom_Captions SET capt_ES='Ubicación' WHERE capt_family='prwu_DefaultCompanySearchPage ' AND capt_Code = 'CompanySearchLocation.aspx'
UPDATE Custom_Captions SET capt_ES='Perfil de Operaciones' WHERE capt_family='prwu_DefaultCompanySearchPage ' AND capt_Code = 'CompanySearchProfile.aspx'
UPDATE Custom_Captions SET capt_ES='Calificaciones' WHERE capt_family='prwu_DefaultCompanySearchPage ' AND capt_Code = 'CompanySearchRating.aspx'
UPDATE Custom_Captions SET capt_ES='(UTC+04:30) Kabul' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Afghanistan Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC-09:00) Alaska' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Alaskan Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+03:00) Kuwait, Riyadh' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Arab Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+04:00) Abu Dhabi, Muscat' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Arabian Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+03:00) Bagdad' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Arabic Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC-03:00) Buenos Aires' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Argentina Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC-04:00) Hora del Atlántico (Canadá)' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Atlantic Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+09:30) Darwin' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'AUS Central Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+10:00) Canberra, Melbourne, Sidney' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'AUS Eastern Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+04:00) Bakú' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Azerbaijan Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC-01:00) Azores' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Azores Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC-03:00) Salvador' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Bahia Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+06:00) Dhaka' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Bangladesh Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC-06:00) Saskatchewan' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Canada Central Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC-01:00) Isla Cabo Verde' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Cape Verde Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+04:00) Ereván' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Caucasus Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+09:30) Adelaide' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Cen. Australia Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC-06:00) Centro América' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Central America Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+06:00) Astaná' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Central Asia Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC-04:00) Cuiaba' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Central Brazilian Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+01:00) Belgrado, Bratislava, Budapest, Liubliana, Praga' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Central Europe Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+01:00) Sarajevo, Skopie, Varsovia, Zagreb' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Central European Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+11:00) Isla Salomón, Nueva Caledonia' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Central Pacific Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC-06:00) Hora del Centro (Estados Unidos y Canadá)' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Central Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC-06:00) Guadalajara, Ciudad de México, Monterrey' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Central Standard Time (Mexico)'
UPDATE Custom_Captions SET capt_ES='(UTC+08:00) Beijing, Chongqing, Hong Kong, Urumqi' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'China Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC-12:00) Línea de Fecha Internacional Oeste' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Dateline Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+03:00) Nairobi' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'E. Africa Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+10:00) Brisbane' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'E. Australia Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+02:00) Europa del Este' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'E. Europe Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC-03:00) Brasilia' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'E. South America Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC-05:00) Hora del Este (Estados Unidos y Canadá)' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Eastern Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+02:00) Cairo' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Egypt Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+06:00) Ekaterinburg' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Ekaterinburg Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+12:00) Fiji' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Fiji Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+02:00) Helsinki, Kyiv, Riga, Sofia, Tallin, Vilnius' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'FLE Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+04:00) Tbilisi' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Georgian Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC) Dublín, Edimburgo, Lisboa, Londres' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'GMT Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC-03:00) Groenlandia' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Greenland Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC) Monrovia, Reykjavik' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Greenwich Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+02:00) Atenas, Bucarest' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'GTB Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC-10:00) Hawái' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Hawaiian Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+05:30) Chennai, Calcuta, Bombay, Nueva Delhi' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'India Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+03:30) Teherán' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Iran Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+02:00) Jerusalén' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Israel Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+02:00) Amán' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Jordan Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+03:00) Kaliningrado, Minsk' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Kaliningrad Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+12:00) Petropavlovsk-Kamchatsky - Anterior' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Kamchatka Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+09:00) Seúl' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Korea Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+02:00) Trípoli' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Libya Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+14:00) Isla Kiritimati' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Line Islands Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+12:00) Magadán' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Magadan Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+04:00) Puerto Luis' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Mauritius Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC-02:00) Atlántico Medio - Anterior' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Mid-Atlantic Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+02:00) Beirut' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Middle East Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC-03:00) Montevideo' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Montevideo Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC) Casablanca' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Morocco Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC-07:00) Hora de la Montaña (Estados Unidos y Canadá)' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Mountain Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC-07:00) Chihuahua, La Paz, Mazatlán' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Mountain Standard Time (Mexico)'
UPDATE Custom_Captions SET capt_ES='(UTC+06:30) Yangon (Rangún)' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Myanmar Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+07:00) Novosibirsk' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'N. Central Asia Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+01:00) Windhoek' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Namibia Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+05:45) Katmandú' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Nepal Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+12:00) Auckland, Wellington' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'New Zealand Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC-03:30) Terranova' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Newfoundland Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+09:00) Irkutsk' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'North Asia East Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+08:00) Krasnoyarsk' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'North Asia Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC-04:00) Santiago' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Pacific SA Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC-08:00) Hora del Pacífico (Estados Unidos y Canadá)' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Pacific Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC-08:00) Baja California' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Pacific Standard Time (Mexico)'
UPDATE Custom_Captions SET capt_ES='(UTC+05:00) Islamabad, Karachi' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Pakistan Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC-04:00) Asunción' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Paraguay Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+01:00) Bruselas, Copenhague, Madrid, Paris' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Romance Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+04:00) Moscú, San Petersburgo, Volgogrado' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Russian Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC-03:00) Cayena, Fortaleza' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'SA Eastern Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC-05:00) Bogota, Lima, Quito, Río Blanco' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'SA Pacific Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC-04:00) Georgetown, La Paz, Manaus, San Juan' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'SA Western Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+13:00) Samoa' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Samoa Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+07:00) Bangkok, Hanoi, Jakarta' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'SE Asia Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+08:00) Kuala Lumpur, Singapur' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Singapore Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+02:00) Harare, Pretoria' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'South Africa Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+05:30) Sri Jayawardenepura' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Sri Lanka Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+02:00) Damasco' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Syria Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+08:00) Taipéi' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Taipei Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+10:00) Hobart' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Tasmania Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+09:00) Osaka, Sapporo, Tokio' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Tokyo Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+13:00) Nuku''alofa' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Tonga Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+02:00) Estanbul' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Turkey Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+08:00) Ulaanbaatar' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Ulaanbaatar Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC-05:00) Indiana (Este)' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'US Eastern Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC-07:00) Arizona' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'US Mountain Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC) Hora Universal Coordinada' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'UTC'
UPDATE Custom_Captions SET capt_ES='(UTC+12:00) Hora Universal Coordinada +12' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'UTC+12'
UPDATE Custom_Captions SET capt_ES='(UTC-02:00) Hora Universal Coordinada -02' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'UTC-02'
UPDATE Custom_Captions SET capt_ES='(UTC-11:00) Hora Universal Coordinada -11' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'UTC-11'
UPDATE Custom_Captions SET capt_ES='(UTC-04:30) Caracas' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Venezuela Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+11:00) Vladivostok' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Vladivostok Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+08:00) Perth' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'W. Australia Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+01:00) África Central y Occidental' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'W. Central Africa Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+01:00) Amsterdam, Berlin, Berna, Roma, Estocolmo, Viena' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'W. Europe Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+05:00) Asjabad, Taskent' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'West Asia Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+10:00) Guam, Puerto Moresby' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'West Pacific Standard Time'
UPDATE Custom_Captions SET capt_ES='(UTC+10:00) Yakutsk' WHERE capt_family='prwu_Timezone                 ' AND capt_Code = 'Yakutsk Standard Time'
UPDATE Custom_Captions SET capt_ES='Categoría Negra' WHERE capt_family='prwucl_CategoryIcon           ' AND capt_Code = 'Category Black.png'
UPDATE Custom_Captions SET capt_ES='Categoría Azul' WHERE capt_family='prwucl_CategoryIcon           ' AND capt_Code = 'Category Blue.png'
UPDATE Custom_Captions SET capt_ES='Categoría Verde' WHERE capt_family='prwucl_CategoryIcon           ' AND capt_Code = 'Category Green.png'
UPDATE Custom_Captions SET capt_ES='Categoría Roja' WHERE capt_family='prwucl_CategoryIcon           ' AND capt_Code = 'Category Red.png'
UPDATE Custom_Captions SET capt_ES='Categoría Amarilla' WHERE capt_family='prwucl_CategoryIcon           ' AND capt_Code = 'Category Yellow.png'
UPDATE Custom_Captions SET capt_ES='Aduana' WHERE capt_family='RelativeDateRange             ' AND capt_Code = ''
UPDATE Custom_Captions SET capt_ES='Mes Anterior' WHERE capt_family='RelativeDateRange             ' AND capt_Code = 'Last Month'
UPDATE Custom_Captions SET capt_ES='Trimestre Anterior' WHERE capt_family='RelativeDateRange             ' AND capt_Code = 'Last Quarter'
UPDATE Custom_Captions SET capt_ES='Semana Anterior' WHERE capt_family='RelativeDateRange             ' AND capt_Code = 'Last Week'
UPDATE Custom_Captions SET capt_ES='Este Mes' WHERE capt_family='RelativeDateRange             ' AND capt_Code = 'This Month'
UPDATE Custom_Captions SET capt_ES='Este Trimestre' WHERE capt_family='RelativeDateRange             ' AND capt_Code = 'This Quarter'
UPDATE Custom_Captions SET capt_ES='Esta Semana' WHERE capt_family='RelativeDateRange             ' AND capt_Code = 'This Week'
UPDATE Custom_Captions SET capt_ES='Hoy' WHERE capt_family='RelativeDateRange             ' AND capt_Code = 'Today'
UPDATE Custom_Captions SET capt_ES='Ayer' WHERE capt_family='RelativeDateRange             ' AND capt_Code = 'Yesterday'

--Added extras
UPDATE Custom_Captions SET capt_ES='Madera' WHERE capt_family='comp_PRIndustryTypeBBOS' AND capt_Code = 'L'
UPDATE Custom_Captions SET capt_ES='Producto' WHERE capt_family='comp_PRIndustryTypeBBOS' AND capt_Code = 'P'
UPDATE Custom_Captions SET capt_ES='Suministro y Servicio' WHERE capt_family='comp_PRIndustryTypeBBOS' AND capt_Code = 'S'
UPDATE Custom_Captions SET capt_ES='Transporte' WHERE capt_family='comp_PRIndustryTypeBBOS' AND capt_Code = 'T'
UPDATE Custom_Captions SET capt_ES='SU' WHERE capt_family='comp_PRType_BBOS' AND capt_Code = 'B'
UPDATE Custom_Captions SET capt_ES='OC' WHERE capt_family='comp_PRType_BBOS' AND capt_Code = 'H'
UPDATE Custom_Captions SET capt_ES='Última Búsqueda no Guardada {0}' WHERE capt_family='LastUnsavedSearch' AND capt_Code = '1'
UPDATE Custom_Captions SET capt_ES='Actividad de Reclamación' WHERE capt_family='prsc_SearchType               ' AND capt_Code = 'ClaimActivity'
UPDATE Custom_Captions SET capt_ES='Compañía' WHERE capt_family='prsc_SearchType               ' AND capt_Code = 'Company'
UPDATE Custom_Captions SET capt_ES='Actualización de la Compañía' WHERE capt_family='prsc_SearchType               ' AND capt_Code = 'CompanyUpdate'
UPDATE Custom_Captions SET capt_ES='HojaCrédito' WHERE capt_family='prsc_SearchType               ' AND capt_Code = 'CreditSheet'
UPDATE Custom_Captions SET capt_ES='CentroAprendizaje' WHERE capt_family='prsc_SearchType               ' AND capt_Code = 'Learning'
UPDATE Custom_Captions SET capt_ES='Persona' WHERE capt_family='prsc_SearchType               ' AND capt_Code = 'Person'


UPDATE PRClassification SET prcl_Name_ES='Comprador de Producto', prcl_Description_ES='Compra (tiene el título de) producto.' WHERE prcl_ClassificationID=1
UPDATE PRClassification SET prcl_Name_ES='Vendedor del Producto', prcl_Description_ES='Vende el producto.  [NOTA: La definición necesita tomar en cuenta al agente del productor].' WHERE prcl_ClassificationID=2
UPDATE PRClassification SET prcl_Name_ES='Formadores de Caja', prcl_Description_ES='Actúa como un agente para la venta y/o compra del producto (no tiene el título del producto).' WHERE prcl_ClassificationID=3
UPDATE PRClassification SET prcl_Name_ES='Servicios de Cadena de Suministros', prcl_Description_ES='Proporciona instalaciones para el almacenamiento del producto.  No compra ni vende producto.' WHERE prcl_ClassificationID=4
UPDATE PRClassification SET prcl_Name_ES='Corredor de Compras', prcl_Description_ES='Actúa como un agente de compras, generalmente para un comprador distante.' WHERE prcl_ClassificationID=110
UPDATE PRClassification SET prcl_Name_ES='Corredor de Ventas', prcl_Description_ES='Generalmente representa al transportista.' WHERE prcl_ClassificationID=120
UPDATE PRClassification SET prcl_Name_ES='Formadores de Caja', prcl_Description_ES='Ubicación enfocada en la compra del producto.  Las compras generalmente se envían a puntos que no sean la Oficina de compras.' WHERE prcl_ClassificationID=130
UPDATE PRClassification SET prcl_Name_ES='Enlatador', prcl_Description_ES='Produce producto enlatado.' WHERE prcl_ClassificationID=140
UPDATE PRClassification SET prcl_Name_ES='Cortador de Papas Fritas', prcl_Description_ES='Produce papas fritas.' WHERE prcl_ClassificationID=150
UPDATE PRClassification SET prcl_Name_ES='Comerciante Por Comisión', prcl_Description_ES='Actúa como agente para la venta de mercadería en consignación.' WHERE prcl_ClassificationID=160
UPDATE PRClassification SET prcl_Name_ES='Deshidratador', prcl_Description_ES='Produce producto deshidratado.' WHERE prcl_ClassificationID=170
UPDATE PRClassification SET prcl_Name_ES='Distribuidor', prcl_Description_ES='Compra producto en su propio nombre generalmente de transportistas u otros distribuidores, y generalmente vende fuera de sus áreas locales; sin embargo, en la mayoría de los casos no toma posesión física de la mercadería.' WHERE prcl_ClassificationID=180
UPDATE PRClassification SET prcl_Name_ES='Servicios de Alimentación', prcl_Description_ES='Compra y recibe producto para distribución para las cuentas institucionales como escuelas y restaurantes.' WHERE prcl_ClassificationID=190
UPDATE PRClassification SET prcl_Name_ES='Congelador', prcl_Description_ES='La ubicación tiene equipo y experiencia para congelar frutas y/o vegetales frescos.' WHERE prcl_ClassificationID=200
UPDATE PRClassification SET prcl_Name_ES='Procesador de Cortes Frescos', prcl_Description_ES='Físicamente altera la forma (es decir, rodaja, corta en dados, desmenuza, extrae el corazón, mezcla, etc.) del producto sin comprometer su estado fresco.' WHERE prcl_ClassificationID=210
UPDATE PRClassification SET prcl_Name_ES='Importador', prcl_Description_ES='Compra producto de proveedores que se encuentran en otro país.' WHERE prcl_ClassificationID=220
UPDATE PRClassification SET prcl_Name_ES='Mayorista', prcl_Description_ES='Vende localmente en pequeños lotes y compra de receptores en sus mercados locales.' WHERE prcl_ClassificationID=230
UPDATE PRClassification SET prcl_Name_ES='Máquina Para Hacer Jugos', prcl_Description_ES='Produce jugo.' WHERE prcl_ClassificationID=240
UPDATE PRClassification SET prcl_Name_ES='Empacadora', prcl_Description_ES='Toma el producto a granel o sin procesar y lo prepara para almacenamiento, envío y venta.' WHERE prcl_ClassificationID=250
UPDATE PRClassification SET prcl_Name_ES='Pelador', prcl_Description_ES='Pela el producto.' WHERE prcl_ClassificationID=260
UPDATE PRClassification SET prcl_Name_ES='Máquina Para Hacer Salmueras', prcl_Description_ES='Produce salmueras.' WHERE prcl_ClassificationID=270
UPDATE PRClassification SET prcl_Name_ES='Máquina Para Hacer Conservas', prcl_Description_ES='Produce conservas.' WHERE prcl_ClassificationID=280
UPDATE PRClassification SET prcl_Name_ES='Procesador', prcl_Description_ES='Altera físicamente la forma del producto y la mezcla como un ingrediente con otros artículos no producidos (es decir, ensalada de papas) y/o lo prepara al cocinarlo, congelarlo o disecarlo.' WHERE prcl_ClassificationID=290
UPDATE PRClassification SET prcl_Name_ES='Receptor', prcl_Description_ES='Compra y toma la posesión física de los lotes de camiones o carros y los vuelve a vender localmente intactos o en lotes para trabajos temporales.' WHERE prcl_ClassificationID=300
UPDATE PRClassification SET prcl_Name_ES='Reempacadora', prcl_Description_ES='Toma el producto a granel o de emergencia y lo vuelve a empacar para empaques del tamaño del consumidor.' WHERE prcl_ClassificationID=310
UPDATE PRClassification SET prcl_Name_ES='Restaurante', prcl_Description_ES='Restaurante.' WHERE prcl_ClassificationID=320
UPDATE PRClassification SET prcl_Name_ES='Minorista', prcl_Description_ES='Vende producto al consumidor.' WHERE prcl_ClassificationID=330
UPDATE PRClassification SET prcl_Name_ES='Vendedor al Por Mayor', prcl_Description_ES='Compra y recibe el producto para distribución a cuentas al por menor.' WHERE prcl_ClassificationID=340
UPDATE PRClassification SET prcl_Name_ES='Compañía de Transporte de Recorridos Cortos', prcl_Description_ES='Empresa de producto que es propietaria de camiones y proporciona transporte corto de camiones para otras compañías.' WHERE prcl_ClassificationID=345
UPDATE PRClassification SET prcl_Name_ES='Exportador', prcl_Description_ES='Vende el producto a compradores ubicados en otro país.' WHERE prcl_ClassificationID=350
UPDATE PRClassification SET prcl_Name_ES='Centro de Alimentos', prcl_Description_ES='Consolida, distribuye o comercializa producto local y/o regional para la venta a mayoristas, minoristas y cuentas institucionales.' WHERE prcl_ClassificationID=355
UPDATE PRClassification SET prcl_Name_ES='Productor', prcl_Description_ES='Aumenta el producto.' WHERE prcl_ClassificationID=360
UPDATE PRClassification SET prcl_Name_ES='Encargado de Subastas de Productos', prcl_Description_ES='Compra o vende el producto en subastas' WHERE prcl_ClassificationID=370
UPDATE PRClassification SET prcl_Name_ES='Oficina de Ventas', prcl_Description_ES='Ubicación enfocada en vender producto que generalmente se envía a otra instalación.  Puede manejar ventas para varios sitios de envío.' WHERE prcl_ClassificationID=380
UPDATE PRClassification SET prcl_Name_ES='Compañía de Transporte', prcl_Description_ES='Tiene a la venta en su nombre mercadería que ha aumentado y/o empacado o puede vender para la cuenta de cultivadores u otros transportistas.' WHERE prcl_ClassificationID=390
UPDATE PRClassification SET prcl_Name_ES='Almacenamiento en Frío', prcl_Description_ES='Instalación de almacenamiento con temperatura controlada' WHERE prcl_ClassificationID=400
UPDATE PRClassification SET prcl_Name_ES='Almacenamiento de Congelador', prcl_Description_ES='Instalación de almacenamiento con congelador' WHERE prcl_ClassificationID=410
UPDATE PRClassification SET prcl_Name_ES='Oficina de Inspección', prcl_Description_ES='Proporciona clasificación, inspección y certificación de servicios' WHERE prcl_ClassificationID=420
UPDATE PRClassification SET prcl_Name_ES='Consolidador de Carga', prcl_Description_ES='Asimila uno o más lotes de carga consolidada en una unidad para el envío.' WHERE prcl_ClassificationID=430
UPDATE PRClassification SET prcl_Name_ES='Punto de carga', prcl_Description_ES='Envía al punto de instalación para la carga del producto en camiones' WHERE prcl_ClassificationID=440
UPDATE PRClassification SET prcl_Name_ES='Preenfriador', prcl_Description_ES='Enfría el producto previo a la carga' WHERE prcl_ClassificationID=450
UPDATE PRClassification SET prcl_Name_ES='Almacén de Producto', prcl_Description_ES='Proporciona instalaciones para el almacenamiento del producto.' WHERE prcl_ClassificationID=460
UPDATE PRClassification SET prcl_Name_ES='Servicios de Cuarto Para Maduración', prcl_Description_ES='Instalación para ayudar en la maduración del producto' WHERE prcl_ClassificationID=470
UPDATE PRClassification SET prcl_Name_ES='Almacenamiento', prcl_Description_ES='Instalación para el almacenamiento del producto' WHERE prcl_ClassificationID=480
UPDATE PRClassification SET prcl_Name_ES='Servicio de Carga y Descarga de Camiones', prcl_Description_ES='Servicio de carga y descarga del camión' WHERE prcl_ClassificationID=490
UPDATE PRClassification SET prcl_Name_ES='Transporte', prcl_Description_ES='Transporta y/o proporciona servicios de transporte.' WHERE prcl_ClassificationID=5
UPDATE PRClassification SET prcl_Name_ES='Compañía de Transporte Aéreo', prcl_Description_ES='El director que acuerda transportar un bien en una tarifa de flete acordada y es responsable por la pérdida directamente relacionada para proporcionar un servicio de transporte no satisfactorio.' WHERE prcl_ClassificationID=500
UPDATE PRClassification SET prcl_Name_ES='Intermediario de Transporte de Flete', prcl_Description_ES='Un intermediario que ordena el transporte y la coordinación de documentación; generalmente funciona como parte de movimientos de flete internacional.' WHERE prcl_ClassificationID=520
UPDATE PRClassification SET prcl_Name_ES='Intermodal', prcl_Description_ES='Flete con contenedores que utilizan varios modos de transporte.' WHERE prcl_ClassificationID=530
UPDATE PRClassification SET prcl_Name_ES='Compañía de Transporte Por Océano', prcl_Description_ES='El director que acuerda transportar un bien en una tarifa de flete acordada y es responsable por la pérdida directamente relacionada para proporcionar un servicio de transporte no satisfactorio.' WHERE prcl_ClassificationID=540
UPDATE PRClassification SET prcl_Name_ES='Compañía de Transporte Por Tren', prcl_Description_ES='El director que acuerda transportar un bien en una tarifa de flete acordada y es responsable por la pérdida directamente relacionada para proporcionar un servicio de transporte no satisfactorio.' WHERE prcl_ClassificationID=550
UPDATE PRClassification SET prcl_Name_ES='Vagones de Ferrocarril (Combinado)', prcl_Description_ES='Transporte de mercancía cargada en van por medio de vagones planos de ferrocarril (combinado).' WHERE prcl_ClassificationID=560
UPDATE PRClassification SET prcl_Name_ES='Otros Servicios de Transporte/Logística', prcl_Description_ES='Asume la responsabilidad para el movimiento de bienes "puerta a puerta".  Puede utilizar varios modos y tipos de transporte.' WHERE prcl_ClassificationID=580
UPDATE PRClassification SET prcl_Name_ES='Corredor de Camiones/Transportista', prcl_Description_ES='Persona o entidad que arregla y/o contrata para el transporte de bienes como un servicio para su cliente.' WHERE prcl_ClassificationID=590
UPDATE PRClassification SET prcl_Name_ES='Encargado de Camiones', prcl_Description_ES='El director que acuerda transportar un bien en una tarifa de flete acordada y es responsable por la pérdida directamente relacionada para proporcionar un servicio de transporte no satisfactorio.' WHERE prcl_ClassificationID=610
UPDATE PRClassification SET prcl_Name_ES='Proveedor de Servicio o Proveedor Industrial', prcl_Description_ES='Proporciona servicios o suministros que no son de productos para las compañías que venden, compran, son intermediarios, almacenan o transportan el producto.' WHERE prcl_ClassificationID=6
UPDATE PRClassification SET prcl_Name_ES='Renta', prcl_Description_ES='Renta' WHERE prcl_ClassificationID=1415

UPDATE PRClassification SET prcl_Name_ES='Oficina de Sucursal de Compras', prcl_Description_ES=NULL WHERE prcl_ClassificationID=2080
UPDATE PRClassification SET prcl_Name_ES='Oficina de Compras', prcl_Description_ES=NULL WHERE prcl_ClassificationID=2090
UPDATE PRClassification SET prcl_Name_ES='Oficina de Adquisiciones', prcl_Description_ES=NULL WHERE prcl_ClassificationID=2100
UPDATE PRClassification SET prcl_Name_ES='Oficina de Compras de Estación', prcl_Description_ES=NULL WHERE prcl_ClassificationID=2110
UPDATE PRClassification SET prcl_Name_ES='Reempacadora', prcl_Description_ES=NULL WHERE prcl_ClassificationID=2120
UPDATE PRClassification SET prcl_Name_ES='Oficina de Sucursal de Ventas', prcl_Description_ES=NULL WHERE prcl_ClassificationID=2140
UPDATE PRClassification SET prcl_Name_ES='Oficina de Ventas de Distrito', prcl_Description_ES=NULL WHERE prcl_ClassificationID=2150
UPDATE PRClassification SET prcl_Name_ES='Oficina de División de Ventas', prcl_Description_ES=NULL WHERE prcl_ClassificationID=2160
UPDATE PRClassification SET prcl_Name_ES='Oficina de Ventas Regionales', prcl_Description_ES=NULL WHERE prcl_ClassificationID=2170
UPDATE PRClassification SET prcl_Name_ES='Oficina de Ventas', prcl_Description_ES=NULL WHERE prcl_ClassificationID=2180
UPDATE PRClassification SET prcl_Name_ES='Publicidad', prcl_Description_ES=NULL WHERE prcl_ClassificationID=620
UPDATE PRClassification SET prcl_Name_ES='Propiedades de Agricultura', prcl_Description_ES=NULL WHERE prcl_ClassificationID=630
UPDATE PRClassification SET prcl_Name_ES='Productos de Red Agrícola', prcl_Description_ES=NULL WHERE prcl_ClassificationID=640
UPDATE PRClassification SET prcl_Name_ES='Servicio y Equipo de Control de Atmósfera', prcl_Description_ES=NULL WHERE prcl_ClassificationID=650
UPDATE PRClassification SET prcl_Name_ES='Abogados', prcl_Description_ES=NULL WHERE prcl_ClassificationID=660
UPDATE PRClassification SET prcl_Name_ES='Soporte para Bolsas', prcl_Description_ES=NULL WHERE prcl_ClassificationID=670
UPDATE PRClassification SET prcl_Name_ES='Empaquetadora', prcl_Description_ES=NULL WHERE prcl_ClassificationID=680
UPDATE PRClassification SET prcl_Name_ES='Bolsas', prcl_Description_ES=NULL WHERE prcl_ClassificationID=690
UPDATE PRClassification SET prcl_Name_ES='Sistemas de Codificación Por Barras', prcl_Description_ES=NULL WHERE prcl_ClassificationID=700
UPDATE PRClassification SET prcl_Name_ES='Canastas', prcl_Description_ES=NULL WHERE prcl_ClassificationID=710
UPDATE PRClassification SET prcl_Name_ES='Correas', prcl_Description_ES=NULL WHERE prcl_ClassificationID=720
UPDATE PRClassification SET prcl_Name_ES='Cajas y Cartones', prcl_Description_ES=NULL WHERE prcl_ClassificationID=730
UPDATE PRClassification SET prcl_Name_ES='Cepillos', prcl_Description_ES=NULL WHERE prcl_ClassificationID=740
UPDATE PRClassification SET prcl_Name_ES='Estopa', prcl_Description_ES=NULL WHERE prcl_ClassificationID=750
UPDATE PRClassification SET prcl_Name_ES='Revestimiento de Papel Para Automóviles', prcl_Description_ES=NULL WHERE prcl_ClassificationID=760
UPDATE PRClassification SET prcl_Name_ES='Tiras Para Automóviles', prcl_Description_ES=NULL WHERE prcl_ClassificationID=770
UPDATE PRClassification SET prcl_Name_ES='Contenedores de Carga', prcl_Description_ES=NULL WHERE prcl_ClassificationID=780
UPDATE PRClassification SET prcl_Name_ES='Formadores de Caja', prcl_Description_ES=NULL WHERE prcl_ClassificationID=790
UPDATE PRClassification SET prcl_Name_ES='Selladores de Caja', prcl_Description_ES=NULL WHERE prcl_ClassificationID=800
UPDATE PRClassification SET prcl_Name_ES='Químicos', prcl_Description_ES=NULL WHERE prcl_ClassificationID=810
UPDATE PRClassification SET prcl_Name_ES='Servicio de Reclamos', prcl_Description_ES=NULL WHERE prcl_ClassificationID=820
UPDATE PRClassification SET prcl_Name_ES='Tintas Codificadoras', prcl_Description_ES=NULL WHERE prcl_ClassificationID=830
UPDATE PRClassification SET prcl_Name_ES='Puertas de Almacenamiento En Frío', prcl_Description_ES=NULL WHERE prcl_ClassificationID=840
UPDATE PRClassification SET prcl_Name_ES='Asistencia de Recopilación', prcl_Description_ES=NULL WHERE prcl_ClassificationID=850
UPDATE PRClassification SET prcl_Name_ES='Empaque y Cosecha Comercial', prcl_Description_ES=NULL WHERE prcl_ClassificationID=860
UPDATE PRClassification SET prcl_Name_ES='Equipo/Sistemas/Software de Computadoras', prcl_Description_ES=NULL WHERE prcl_ClassificationID=870
UPDATE PRClassification SET prcl_Name_ES='Servicios de Computadoras', prcl_Description_ES=NULL WHERE prcl_ClassificationID=880
UPDATE PRClassification SET prcl_Name_ES='Construcción', prcl_Description_ES=NULL WHERE prcl_ClassificationID=885
UPDATE PRClassification SET prcl_Name_ES='Consultores', prcl_Description_ES=NULL WHERE prcl_ClassificationID=890
UPDATE PRClassification SET prcl_Name_ES='Paquetes Para Consumidores', prcl_Description_ES=NULL WHERE prcl_ClassificationID=900
UPDATE PRClassification SET prcl_Name_ES='Equipo de Atmósfera Congelada', prcl_Description_ES=NULL WHERE prcl_ClassificationID=910
UPDATE PRClassification SET prcl_Name_ES='Transportadores', prcl_Description_ES=NULL WHERE prcl_ClassificationID=920
UPDATE PRClassification SET prcl_Name_ES='Suministros Para Cantoneras y Angulares', prcl_Description_ES=NULL WHERE prcl_ClassificationID=930
UPDATE PRClassification SET prcl_Name_ES='Cajas y Material Para Cajas', prcl_Description_ES=NULL WHERE prcl_ClassificationID=940
UPDATE PRClassification SET prcl_Name_ES='Corredor de Aduanas', prcl_Description_ES=NULL WHERE prcl_ClassificationID=950
UPDATE PRClassification SET prcl_Name_ES='Cortadores y Secadores', prcl_Description_ES=NULL WHERE prcl_ClassificationID=960
UPDATE PRClassification SET prcl_Name_ES='Calcomanías', prcl_Description_ES=NULL WHERE prcl_ClassificationID=970
UPDATE PRClassification SET prcl_Name_ES='Descargo de Mercadería', prcl_Description_ES=NULL WHERE prcl_ClassificationID=3010
UPDATE PRClassification SET prcl_Name_ES='Servicio e Imaginería Digital', prcl_Description_ES=NULL WHERE prcl_ClassificationID=980
UPDATE PRClassification SET prcl_Name_ES='Resolución de Disputas', prcl_Description_ES=NULL WHERE prcl_ClassificationID=990
UPDATE PRClassification SET prcl_Name_ES='Equipo de Muelle', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1000
UPDATE PRClassification SET prcl_Name_ES='Máquinas de Descarga', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1010
UPDATE PRClassification SET prcl_Name_ES='Educación', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1020
UPDATE PRClassification SET prcl_Name_ES='Relaciones de Empleados', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1030
UPDATE PRClassification SET prcl_Name_ES='Servicios de Ingeniería', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1040
UPDATE PRClassification SET prcl_Name_ES='Servicios Ambientales', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1050
UPDATE PRClassification SET prcl_Name_ES='Servicio de Subasta de Equipo', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1060
UPDATE PRClassification SET prcl_Name_ES='Control de Erosión', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1070
UPDATE PRClassification SET prcl_Name_ES='Equipo de Producción de Etileno', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1080
UPDATE PRClassification SET prcl_Name_ES='Equipo de Retiro de Etileno', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1090
UPDATE PRClassification SET prcl_Name_ES='Promoción de Exportación', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1100
UPDATE PRClassification SET prcl_Name_ES='Servicio de Exportación', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1110
UPDATE PRClassification SET prcl_Name_ES='Factoraje', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1120
UPDATE PRClassification SET prcl_Name_ES='Equipo y Maquinaria de Granja', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1130
UPDATE PRClassification SET prcl_Name_ES='Sujetadores', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1140
UPDATE PRClassification SET prcl_Name_ES='Fertilizador', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1150
UPDATE PRClassification SET prcl_Name_ES='Llenadores', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1160
UPDATE PRClassification SET prcl_Name_ES='Servicios y Consultores Financieros', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1170
UPDATE PRClassification SET prcl_Name_ES='Instituciones Financieras', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1180
UPDATE PRClassification SET prcl_Name_ES='Contenedores de Espuma', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1190
UPDATE PRClassification SET prcl_Name_ES='Reciclado de Alimentos', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1195
UPDATE PRClassification SET prcl_Name_ES='Seguridad de Alimentos', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1200
UPDATE PRClassification SET prcl_Name_ES='Equipo de Procesamiento de Corte de Frescos', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1210
UPDATE PRClassification SET prcl_Name_ES='Control de Pestes/Fumigadores/Fumigación', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1220
UPDATE PRClassification SET prcl_Name_ES='Insecticida/Herbicida/Fungicida', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1230
UPDATE PRClassification SET prcl_Name_ES='Pegamento y Pasta', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1240
UPDATE PRClassification SET prcl_Name_ES='Gobierno', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1245
UPDATE PRClassification SET prcl_Name_ES='Clasificadora/Corte/Motoniveladora', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1250
UPDATE PRClassification SET prcl_Name_ES='Cubierta del suelo', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1260
UPDATE PRClassification SET prcl_Name_ES='Hidroenfriadores', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1270
UPDATE PRClassification SET prcl_Name_ES='Trituradores de Hielo', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1280
UPDATE PRClassification SET prcl_Name_ES='Maquina de Hielo', prcl_Description_ES=NULL WHERE prcl_ClassificationID=3000
UPDATE PRClassification SET prcl_Name_ES='Suministradores y Fabricantes de Hielo', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1290
UPDATE PRClassification SET prcl_Name_ES='Cubiertas de Tinta', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1300
UPDATE PRClassification SET prcl_Name_ES='Sistemas de Inyección de Tinta', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1310
UPDATE PRClassification SET prcl_Name_ES='Venenos Para el Control de Insectos y Roedores', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1320
UPDATE PRClassification SET prcl_Name_ES='Servicio de Inspección (Comercial)', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1330
UPDATE PRClassification SET prcl_Name_ES='Aislamiento', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1340
UPDATE PRClassification SET prcl_Name_ES='Seguro', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1350
UPDATE PRClassification SET prcl_Name_ES='Servicios de Consultoría de Internet', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1360
UPDATE PRClassification SET prcl_Name_ES='Servicios de Internet', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1370
UPDATE PRClassification SET prcl_Name_ES='Promoción de Inversión', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1380
UPDATE PRClassification SET prcl_Name_ES='Equipo de Irrigación', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1390
UPDATE PRClassification SET prcl_Name_ES='Cuchillos', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1400
UPDATE PRClassification SET prcl_Name_ES='Dispositivos de Etiquetado y Etiquetas', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1410
UPDATE PRClassification SET prcl_Name_ES='Revestimientos', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1420
UPDATE PRClassification SET prcl_Name_ES='Cargadores', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1430
UPDATE PRClassification SET prcl_Name_ES='Máquinas', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1440
UPDATE PRClassification SET prcl_Name_ES='Consultores de Mercadeo/Administración', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1450
UPDATE PRClassification SET prcl_Name_ES='Equipo de Manejo de Material', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1460
UPDATE PRClassification SET prcl_Name_ES='Comercialización', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1470
UPDATE PRClassification SET prcl_Name_ES='Motores', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1480
UPDATE PRClassification SET prcl_Name_ES='Clavos y Máquinas Para Clavar', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1490
UPDATE PRClassification SET prcl_Name_ES='Equipo de Empaque', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1500
UPDATE PRClassification SET prcl_Name_ES='Protección de Empaque', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1510
UPDATE PRClassification SET prcl_Name_ES='Suministros de Empaque', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1520
UPDATE PRClassification SET prcl_Name_ES='Tazas de Empaque', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1530
UPDATE PRClassification SET prcl_Name_ES='Almohadillas', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1540
UPDATE PRClassification SET prcl_Name_ES='Película de Estiramiento de Pallet', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1550
UPDATE PRClassification SET prcl_Name_ES='Pallets y Contenedores', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1560
UPDATE PRClassification SET prcl_Name_ES='Papel y Productos de Papel', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1570
UPDATE PRClassification SET prcl_Name_ES='Servicios Personales', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1580
UPDATE PRClassification SET prcl_Name_ES='Cubiertas de Planta', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1590
UPDATE PRClassification SET prcl_Name_ES='Cierres de Bolsas de Plástico', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1600
UPDATE PRClassification SET prcl_Name_ES='Contenedores Plásticos', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1610
UPDATE PRClassification SET prcl_Name_ES='Película para Cobertura Plástica', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1620
UPDATE PRClassification SET prcl_Name_ES='Malla Plástica', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1630
UPDATE PRClassification SET prcl_Name_ES='Equipo de Enfriamiento Previo', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1640
UPDATE PRClassification SET prcl_Name_ES='Impresoras/Formularios y Litógrafos', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1650
UPDATE PRClassification SET prcl_Name_ES='Mercados del producto', prcl_Description_ES=NULL WHERE prcl_ClassificationID=3012
UPDATE PRClassification SET prcl_Name_ES='Lavado de Productos', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1660
UPDATE PRClassification SET prcl_Name_ES='Prueba de Productos', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1670
UPDATE PRClassification SET prcl_Name_ES='Relaciones Públicas', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1680
UPDATE PRClassification SET prcl_Name_ES='Control de Calidad', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1690
UPDATE PRClassification SET prcl_Name_ES='Equipo de Reciclado', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1700
UPDATE PRClassification SET prcl_Name_ES='Sistemas y Reparación de Refrigeración', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1710
UPDATE PRClassification SET prcl_Name_ES='Mercadeo e Investigación', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1720
UPDATE PRClassification SET prcl_Name_ES='Empaque y Contenedores Retornables', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1730
UPDATE PRClassification SET prcl_Name_ES='Suministros y Equipo de Maduración', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1740
UPDATE PRClassification SET prcl_Name_ES='Bandas de Hule', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1750
UPDATE PRClassification SET prcl_Name_ES='Sellos de Hule', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1760
UPDATE PRClassification SET prcl_Name_ES='Servicio de Higiene', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1765
UPDATE PRClassification SET prcl_Name_ES='Básculas', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1770
UPDATE PRClassification SET prcl_Name_ES='Máquinas de Coser-Bolsa', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1780
UPDATE PRClassification SET prcl_Name_ES='Paño de Cortina', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1790
UPDATE PRClassification SET prcl_Name_ES='Extensión de la Vida Útil', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1800
UPDATE PRClassification SET prcl_Name_ES='Suministros de Compañías de Transporte y Productores', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1810
UPDATE PRClassification SET prcl_Name_ES='Película Retráctil', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1820
UPDATE PRClassification SET prcl_Name_ES='Suministros y Equipo de Rocío', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1830
UPDATE PRClassification SET prcl_Name_ES='Grapas', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1840
UPDATE PRClassification SET prcl_Name_ES='Equipo de Almacenamiento', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1850
UPDATE PRClassification SET prcl_Name_ES='Fleje', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1860
UPDATE PRClassification SET prcl_Name_ES='Equipo y Envoltorio Estirable', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1870
UPDATE PRClassification SET prcl_Name_ES='Puertas Con Tiras Protectoras', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1880
UPDATE PRClassification SET prcl_Name_ES='Productos Sostenibles', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1885
UPDATE PRClassification SET prcl_Name_ES='Etiquetas', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1890
UPDATE PRClassification SET prcl_Name_ES='Cinta Adhesiva y Máquinas Para Cintas Adhesivas', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1900
UPDATE PRClassification SET prcl_Name_ES='Lonas', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1910
UPDATE PRClassification SET prcl_Name_ES='Temperatura y Supervisión de Humedad', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1920
UPDATE PRClassification SET prcl_Name_ES='Asociaciones Comerciales', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1930
UPDATE PRClassification SET prcl_Name_ES='Desarrollo Comercial', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1940
UPDATE PRClassification SET prcl_Name_ES='Publicaciones Comerciales y Medios', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1950
UPDATE PRClassification SET prcl_Name_ES='Ferias y Exhibiciones', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1960
UPDATE PRClassification SET prcl_Name_ES='Remolque', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1970
UPDATE PRClassification SET prcl_Name_ES='Bandejas', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1980
UPDATE PRClassification SET prcl_Name_ES='Tubos', prcl_Description_ES=NULL WHERE prcl_ClassificationID=1990
UPDATE PRClassification SET prcl_Name_ES='Hilo y Cordelería', prcl_Description_ES=NULL WHERE prcl_ClassificationID=2000
UPDATE PRClassification SET prcl_Name_ES='Lavadoras y Limpiadoras', prcl_Description_ES=NULL WHERE prcl_ClassificationID=2020
UPDATE PRClassification SET prcl_Name_ES='Cubierta de Cera ', prcl_Description_ES=NULL WHERE prcl_ClassificationID=2030
UPDATE PRClassification SET prcl_Name_ES='Información del Clima', prcl_Description_ES=NULL WHERE prcl_ClassificationID=2040
UPDATE PRClassification SET prcl_Name_ES='Paños Para Limpiar', prcl_Description_ES=NULL WHERE prcl_ClassificationID=2050
UPDATE PRClassification SET prcl_Name_ES='Productos de Madera', prcl_Description_ES=NULL WHERE prcl_ClassificationID=2060
UPDATE PRClassification SET prcl_Name_ES='Envoltorios', prcl_Description_ES=NULL WHERE prcl_ClassificationID=2070


UPDATE PRAttribute SET prat_Name_ES ='Argentina' WHERE prat_AttributeID=1
UPDATE PRAttribute SET prat_Name_ES ='Australia' WHERE prat_AttributeID=2
UPDATE PRAttribute SET prat_Name_ES ='Chile' WHERE prat_AttributeID=3
UPDATE PRAttribute SET prat_Name_ES ='China' WHERE prat_AttributeID=4
UPDATE PRAttribute SET prat_Name_ES ='Holanda' WHERE prat_AttributeID=5
UPDATE PRAttribute SET prat_Name_ES ='India' WHERE prat_AttributeID=6
UPDATE PRAttribute SET prat_Name_ES ='Israel' WHERE prat_AttributeID=7
UPDATE PRAttribute SET prat_Name_ES ='Italia' WHERE prat_AttributeID=8
UPDATE PRAttribute SET prat_Name_ES ='Japón' WHERE prat_AttributeID=9
UPDATE PRAttribute SET prat_Name_ES ='Corea' WHERE prat_AttributeID=10
UPDATE PRAttribute SET prat_Name_ES ='México' WHERE prat_AttributeID=11
UPDATE PRAttribute SET prat_Name_ES ='Marruecos' WHERE prat_AttributeID=12
UPDATE PRAttribute SET prat_Name_ES ='Nueva Zelanda (Aotearoa)' WHERE prat_AttributeID=13
UPDATE PRAttribute SET prat_Name_ES ='Perú' WHERE prat_AttributeID=14
UPDATE PRAttribute SET prat_Name_ES ='España' WHERE prat_AttributeID=15
UPDATE PRAttribute SET prat_Name_ES ='Tailandia' WHERE prat_AttributeID=16
UPDATE PRAttribute SET prat_Name_ES ='Pequeño' WHERE prat_AttributeID=17
UPDATE PRAttribute SET prat_Name_ES ='Largo' WHERE prat_AttributeID=18
UPDATE PRAttribute SET prat_Name_ES ='Mini' WHERE prat_AttributeID=19
UPDATE PRAttribute SET prat_Name_ES ='Disecado' WHERE prat_AttributeID=20
UPDATE PRAttribute SET prat_Name_ES ='Congelado' WHERE prat_AttributeID=21
UPDATE PRAttribute SET prat_Name_ES ='En Escabeche' WHERE prat_AttributeID=22
UPDATE PRAttribute SET prat_Name_ES ='Invernadero' WHERE prat_AttributeID=23
UPDATE PRAttribute SET prat_Name_ES ='Hidropónico' WHERE prat_AttributeID=24
UPDATE PRAttribute SET prat_Name_ES ='Orgánico' WHERE prat_AttributeID=25
UPDATE PRAttribute SET prat_Name_ES ='Enlatado' WHERE prat_AttributeID=26
UPDATE PRAttribute SET prat_Name_ES ='Chips' WHERE prat_AttributeID=27
UPDATE PRAttribute SET prat_Name_ES ='Sidra' WHERE prat_AttributeID=28
UPDATE PRAttribute SET prat_Name_ES ='Concentrado' WHERE prat_AttributeID=29
UPDATE PRAttribute SET prat_Name_ES ='Jugo' WHERE prat_AttributeID=30
UPDATE PRAttribute SET prat_Name_ES ='Mezcla' WHERE prat_AttributeID=31
UPDATE PRAttribute SET prat_Name_ES ='Aceite' WHERE prat_AttributeID=32
UPDATE PRAttribute SET prat_Name_ES ='Pasta' WHERE prat_AttributeID=33
UPDATE PRAttribute SET prat_Name_ES ='Planta' WHERE prat_AttributeID=34
UPDATE PRAttribute SET prat_Name_ES ='Procesado' WHERE prat_AttributeID=35
UPDATE PRAttribute SET prat_Name_ES ='Pulpa' WHERE prat_AttributeID=36
UPDATE PRAttribute SET prat_Name_ES ='Semillas' WHERE prat_AttributeID=37
UPDATE PRAttribute SET prat_Name_ES ='Árbol' WHERE prat_AttributeID=38
UPDATE PRAttribute SET prat_Name_ES ='Colombia' WHERE prat_AttributeID=1000
UPDATE PRAttribute SET prat_Name_ES ='Brasil' WHERE prat_AttributeID=1001
UPDATE PRAttribute SET prat_Name_ES ='Puré' WHERE prat_AttributeID=1002
UPDATE PRAttribute SET prat_Name_ES ='Pelada' WHERE prat_AttributeID=1003


UPDATE PRCommodity SET prcm_Name_ES ='Flor/Planta/Árbol', prcm_FullName_ES ='Flor/Planta/Árbol' WHERE prcm_CommodityID=1
UPDATE PRCommodity SET prcm_Name_ES ='Aloe Vera', prcm_FullName_ES ='Aloe Vera' WHERE prcm_CommodityID=4
UPDATE PRCommodity SET prcm_Name_ES ='Plantas de Jardín', prcm_FullName_ES ='Plantas de Jardín' WHERE prcm_CommodityID=5
UPDATE PRCommodity SET prcm_Name_ES ='Follaje Navideño', prcm_FullName_ES ='Follaje Navideño' WHERE prcm_CommodityID=7
UPDATE PRCommodity SET prcm_Name_ES ='Árboles de Navidad', prcm_FullName_ES ='Árboles de Navidad' WHERE prcm_CommodityID=8
UPDATE PRCommodity SET prcm_Name_ES ='Flores Comestibles', prcm_FullName_ES ='Flores Comestibles' WHERE prcm_CommodityID=2
UPDATE PRCommodity SET prcm_Name_ES ='Flor', prcm_FullName_ES ='Flor' WHERE prcm_CommodityID=14
UPDATE PRCommodity SET prcm_Name_ES ='Planta', prcm_FullName_ES ='Planta' WHERE prcm_CommodityID=15
UPDATE PRCommodity SET prcm_Name_ES ='Alimento (no productos frescos)', prcm_FullName_ES ='Alimento (no productos frescos)' WHERE prcm_CommodityID=16
UPDATE PRCommodity SET prcm_Name_ES ='Dulce', prcm_FullName_ES ='Dulce' WHERE prcm_CommodityID=17
UPDATE PRCommodity SET prcm_Name_ES ='Queso', prcm_FullName_ES ='Queso' WHERE prcm_CommodityID=18
UPDATE PRCommodity SET prcm_Name_ES ='Chocolate', prcm_FullName_ES ='Chocolate' WHERE prcm_CommodityID=19
UPDATE PRCommodity SET prcm_Name_ES ='Cocoa', prcm_FullName_ES ='Cocoa' WHERE prcm_CommodityID=20
UPDATE PRCommodity SET prcm_Name_ES ='Café', prcm_FullName_ES ='Café' WHERE prcm_CommodityID=21
UPDATE PRCommodity SET prcm_Name_ES ='Ensalada de Repollo', prcm_FullName_ES ='Ensalada de Repollo' WHERE prcm_CommodityID=22
UPDATE PRCommodity SET prcm_Name_ES ='Mezcla', prcm_FullName_ES ='Mezcla de Ensalada de Repollo' WHERE prcm_CommodityID=23
UPDATE PRCommodity SET prcm_Name_ES ='Cuscús', prcm_FullName_ES ='Cuscús' WHERE prcm_CommodityID=24
UPDATE PRCommodity SET prcm_Name_ES ='Huevo', prcm_FullName_ES ='Huevo' WHERE prcm_CommodityID=25
UPDATE PRCommodity SET prcm_Name_ES ='Guacamol', prcm_FullName_ES ='Guacamol' WHERE prcm_CommodityID=26
UPDATE PRCommodity SET prcm_Name_ES ='Guaje', prcm_FullName_ES ='Guaje' WHERE prcm_CommodityID=568
UPDATE PRCommodity SET prcm_Name_ES ='Miel', prcm_FullName_ES ='Miel' WHERE prcm_CommodityID=27
UPDATE PRCommodity SET prcm_Name_ES ='Jalea', prcm_FullName_ES ='Jalea' WHERE prcm_CommodityID=28
UPDATE PRCommodity SET prcm_Name_ES ='Pasta', prcm_FullName_ES ='Pasta' WHERE prcm_CommodityID=29
UPDATE PRCommodity SET prcm_Name_ES ='Ensalada de Papa', prcm_FullName_ES ='Ensalada de Papa' WHERE prcm_CommodityID=30
UPDATE PRCommodity SET prcm_Name_ES ='Conservas', prcm_FullName_ES ='Conservas' WHERE prcm_CommodityID=31
UPDATE PRCommodity SET prcm_Name_ES ='Semillas de Calabaza', prcm_FullName_ES ='Semillas de Calabaza' WHERE prcm_CommodityID=1507
UPDATE PRCommodity SET prcm_Name_ES ='Sazonador', prcm_FullName_ES ='Sazonador' WHERE prcm_CommodityID=32
UPDATE PRCommodity SET prcm_Name_ES ='Arroz', prcm_FullName_ES ='Arroz' WHERE prcm_CommodityID=33
UPDATE PRCommodity SET prcm_Name_ES ='Semillas de Ajonjolí', prcm_FullName_ES ='Semillas de Ajonjolí' WHERE prcm_CommodityID=34
UPDATE PRCommodity SET prcm_Name_ES ='Sorgo', prcm_FullName_ES ='Sorgo' WHERE prcm_CommodityID=12
UPDATE PRCommodity SET prcm_Name_ES ='Caña de Azúcar', prcm_FullName_ES ='Caña de Azúcar' WHERE prcm_CommodityID=13
UPDATE PRCommodity SET prcm_Name_ES ='Semillas de Girasol', prcm_FullName_ES ='Semillas de Girasol' WHERE prcm_CommodityID=35
UPDATE PRCommodity SET prcm_Name_ES ='Tofu', prcm_FullName_ES ='Tofu' WHERE prcm_CommodityID=36
UPDATE PRCommodity SET prcm_Name_ES ='Fruta', prcm_FullName_ES ='Fruta' WHERE prcm_CommodityID=37
UPDATE PRCommodity SET prcm_Name_ES ='Fruta Asiática', prcm_FullName_ES ='Fruta Asiática' WHERE prcm_CommodityID=38
UPDATE PRCommodity SET prcm_Name_ES ='Durian', prcm_FullName_ES ='Durian' WHERE prcm_CommodityID=40
UPDATE PRCommodity SET prcm_Name_ES ='Longan', prcm_FullName_ES ='Longan' WHERE prcm_CommodityID=42
UPDATE PRCommodity SET prcm_Name_ES ='Loquat', prcm_FullName_ES ='Loquat' WHERE prcm_CommodityID=43
UPDATE PRCommodity SET prcm_Name_ES ='Lichi', prcm_FullName_ES ='Lichi' WHERE prcm_CommodityID=44
UPDATE PRCommodity SET prcm_Name_ES ='Caqui', prcm_FullName_ES ='Caqui' WHERE prcm_CommodityID=45
UPDATE PRCommodity SET prcm_Name_ES ='Membrillo', prcm_FullName_ES ='Membrillo' WHERE prcm_CommodityID=46
UPDATE PRCommodity SET prcm_Name_ES ='Bayas', prcm_FullName_ES ='Bayas' WHERE prcm_CommodityID=47
UPDATE PRCommodity SET prcm_Name_ES ='Zarzamora', prcm_FullName_ES ='Zarzamora' WHERE prcm_CommodityID=51
UPDATE PRCommodity SET prcm_Name_ES ='Mora de Marion', prcm_FullName_ES ='Mora de Marion' WHERE prcm_CommodityID=52
UPDATE PRCommodity SET prcm_Name_ES ='Arándano Azul', prcm_FullName_ES ='Arándano Azul' WHERE prcm_CommodityID=53
UPDATE PRCommodity SET prcm_Name_ES ='Baya de Boysen', prcm_FullName_ES ='Baya de Boysen' WHERE prcm_CommodityID=49
UPDATE PRCommodity SET prcm_Name_ES ='Arándano Rojo', prcm_FullName_ES ='Arándano Rojo' WHERE prcm_CommodityID=54
UPDATE PRCommodity SET prcm_Name_ES ='Pasa de Corinto', prcm_FullName_ES ='Pasa de Corinto' WHERE prcm_CommodityID=55
UPDATE PRCommodity SET prcm_Name_ES ='Rojo', prcm_FullName_ES ='Pasa Roja' WHERE prcm_CommodityID=56
UPDATE PRCommodity SET prcm_Name_ES ='Uva Espina', prcm_FullName_ES ='Baya de Uva Espina' WHERE prcm_CommodityID=50
UPDATE PRCommodity SET prcm_Name_ES ='Frambuesa', prcm_FullName_ES ='Frambuesa' WHERE prcm_CommodityID=57
UPDATE PRCommodity SET prcm_Name_ES ='Cítrico', prcm_FullName_ES ='Cítrico' WHERE prcm_CommodityID=59
UPDATE PRCommodity SET prcm_Name_ES ='Mano de Buda', prcm_FullName_ES ='Mano de Buda' WHERE prcm_CommodityID=60
UPDATE PRCommodity SET prcm_Name_ES ='Esquejes Cítricos', prcm_FullName_ES ='Esquejes Cítricos' WHERE prcm_CommodityID=557
UPDATE PRCommodity SET prcm_Name_ES ='Etrog', prcm_FullName_ES ='Etrog' WHERE prcm_CommodityID=61
UPDATE PRCommodity SET prcm_Name_ES ='Genipa', prcm_FullName_ES ='Genipa' WHERE prcm_CommodityID=563
UPDATE PRCommodity SET prcm_Name_ES ='Toronja', prcm_FullName_ES ='Toronja' WHERE prcm_CommodityID=62
UPDATE PRCommodity SET prcm_Name_ES ='Fortunella', prcm_FullName_ES ='Fortunella' WHERE prcm_CommodityID=63
UPDATE PRCommodity SET prcm_Name_ES ='Limón', prcm_FullName_ES ='Limón' WHERE prcm_CommodityID=64
UPDATE PRCommodity SET prcm_Name_ES ='Lima', prcm_FullName_ES ='Lima' WHERE prcm_CommodityID=65
UPDATE PRCommodity SET prcm_Name_ES ='Lima', prcm_FullName_ES ='Lima Limón' WHERE prcm_CommodityID=66
UPDATE PRCommodity SET prcm_Name_ES ='Mexicano', prcm_FullName_ES ='Lima Limón Mexicano' WHERE prcm_CommodityID=67
UPDATE PRCommodity SET prcm_Name_ES ='Persa', prcm_FullName_ES ='Limón Persa' WHERE prcm_CommodityID=68
UPDATE PRCommodity SET prcm_Name_ES ='Dulce', prcm_FullName_ES ='Lima Dulce' WHERE prcm_CommodityID=69
UPDATE PRCommodity SET prcm_Name_ES ='Mandarina', prcm_FullName_ES ='Mandarina' WHERE prcm_CommodityID=70
UPDATE PRCommodity SET prcm_Name_ES ='Clementina', prcm_FullName_ES ='Mandarina Clementina' WHERE prcm_CommodityID=558
UPDATE PRCommodity SET prcm_Name_ES ='Ponkan', prcm_FullName_ES ='Mandarina de Ponkan' WHERE prcm_CommodityID=575
UPDATE PRCommodity SET prcm_Name_ES ='Naranja', prcm_FullName_ES ='Naranja' WHERE prcm_CommodityID=71
UPDATE PRCommodity SET prcm_Name_ES ='Sangre', prcm_FullName_ES ='Naranja de Sangre' WHERE prcm_CommodityID=76
UPDATE PRCommodity SET prcm_Name_ES ='Jugo', prcm_FullName_ES ='Juego de Naranja' WHERE prcm_CommodityID=78
UPDATE PRCommodity SET prcm_Name_ES ='Minneola', prcm_FullName_ES ='Naranaja de Minneola' WHERE prcm_CommodityID=77
UPDATE PRCommodity SET prcm_Name_ES ='Navel', prcm_FullName_ES ='Naranja de Navel' WHERE prcm_CommodityID=75
UPDATE PRCommodity SET prcm_Name_ES ='Naranja Agria', prcm_FullName_ES ='Naranja Agria' WHERE prcm_CommodityID=74
UPDATE PRCommodity SET prcm_Name_ES ='Temple', prcm_FullName_ES ='Naranja Temple' WHERE prcm_CommodityID=73
UPDATE PRCommodity SET prcm_Name_ES ='Valencia', prcm_FullName_ES ='Naranja Valencia' WHERE prcm_CommodityID=72
UPDATE PRCommodity SET prcm_Name_ES ='Pomelo', prcm_FullName_ES ='Naranja Pomelo' WHERE prcm_CommodityID=80
UPDATE PRCommodity SET prcm_Name_ES ='Tangelo', prcm_FullName_ES ='Tangelo' WHERE prcm_CommodityID=81
UPDATE PRCommodity SET prcm_Name_ES ='Naranja Mandarina', prcm_FullName_ES ='Mandarina' WHERE prcm_CommodityID=82
UPDATE PRCommodity SET prcm_Name_ES ='Frutales Caducifolios', prcm_FullName_ES ='Frutales Caducifolios' WHERE prcm_CommodityID=559
UPDATE PRCommodity SET prcm_Name_ES ='Canasta de Regalos', prcm_FullName_ES ='Canasta de Regalos' WHERE prcm_CommodityID=246
UPDATE PRCommodity SET prcm_Name_ES ='Fruta Hispana', prcm_FullName_ES ='Fruta Hispana' WHERE prcm_CommodityID=247
UPDATE PRCommodity SET prcm_Name_ES ='Fruta Blanda', prcm_FullName_ES ='Fruta Blanda' WHERE prcm_CommodityID=83
UPDATE PRCommodity SET prcm_Name_ES ='Fresa', prcm_FullName_ES ='Fresa' WHERE prcm_CommodityID=84
UPDATE PRCommodity SET prcm_Name_ES ='Fruta Especial', prcm_FullName_ES ='Fruta Especial' WHERE prcm_CommodityID=85
UPDATE PRCommodity SET prcm_Name_ES ='Carambola', prcm_FullName_ES ='Carambola' WHERE prcm_CommodityID=86
UPDATE PRCommodity SET prcm_Name_ES ='Chirimoya', prcm_FullName_ES ='Chirimoya' WHERE prcm_CommodityID=87
UPDATE PRCommodity SET prcm_Name_ES ='Pitahaya', prcm_FullName_ES ='Pitahaya' WHERE prcm_CommodityID=88
UPDATE PRCommodity SET prcm_Name_ES ='Yaca', prcm_FullName_ES ='Yaca' WHERE prcm_CommodityID=89
UPDATE PRCommodity SET prcm_Name_ES ='Fruta de Hueso', prcm_FullName_ES ='Fruta de Hueso' WHERE prcm_CommodityID=90
UPDATE PRCommodity SET prcm_Name_ES ='Albaricoque', prcm_FullName_ES ='Albaricoque' WHERE prcm_CommodityID=91
UPDATE PRCommodity SET prcm_Name_ES ='Interespecífico', prcm_FullName_ES ='Albaricoque Interespecífico' WHERE prcm_CommodityID=92
UPDATE PRCommodity SET prcm_Name_ES ='Aguacate', prcm_FullName_ES ='Aguacate' WHERE prcm_CommodityID=93
UPDATE PRCommodity SET prcm_Name_ES ='Cereza', prcm_FullName_ES ='Cereza' WHERE prcm_CommodityID=94
UPDATE PRCommodity SET prcm_Name_ES ='Cereza Agria', prcm_FullName_ES ='Cereza Agria' WHERE prcm_CommodityID=1509
UPDATE PRCommodity SET prcm_Name_ES ='Mango', prcm_FullName_ES ='Mango' WHERE prcm_CommodityID=98
UPDATE PRCommodity SET prcm_Name_ES ='Verde', prcm_FullName_ES ='Mango Verde' WHERE prcm_CommodityID=567
UPDATE PRCommodity SET prcm_Name_ES ='Nectarina', prcm_FullName_ES ='Nectarina' WHERE prcm_CommodityID=99
UPDATE PRCommodity SET prcm_Name_ES ='Blanca', prcm_FullName_ES ='Nectarina Blanca' WHERE prcm_CommodityID=100
UPDATE PRCommodity SET prcm_Name_ES ='Aceituna', prcm_FullName_ES ='Aceituna' WHERE prcm_CommodityID=101
UPDATE PRCommodity SET prcm_Name_ES ='Melocotón', prcm_FullName_ES ='Melocotón' WHERE prcm_CommodityID=102
UPDATE PRCommodity SET prcm_Name_ES ='Blanco', prcm_FullName_ES ='Melocotón Blanco' WHERE prcm_CommodityID=103
UPDATE PRCommodity SET prcm_Name_ES ='Ciruela', prcm_FullName_ES ='Ciruela' WHERE prcm_CommodityID=104
UPDATE PRCommodity SET prcm_Name_ES ='Cereza', prcm_FullName_ES ='Ciruela Cereza' WHERE prcm_CommodityID=1508
UPDATE PRCommodity SET prcm_Name_ES ='Ciruelo Damasco', prcm_FullName_ES ='Ciruelo Damasco' WHERE prcm_CommodityID=583
UPDATE PRCommodity SET prcm_Name_ES ='Ciruela Albaricoque', prcm_FullName_ES ='Ciruela Albaricoque' WHERE prcm_CommodityID=105
UPDATE PRCommodity SET prcm_Name_ES ='Ciruela Pasa', prcm_FullName_ES ='Ciruela Pasa' WHERE prcm_CommodityID=106
UPDATE PRCommodity SET prcm_Name_ES ='Italiana', prcm_FullName_ES ='Ciruela Italiana' WHERE prcm_CommodityID=107
UPDATE PRCommodity SET prcm_Name_ES ='Rambután', prcm_FullName_ES ='Rambután' WHERE prcm_CommodityID=108
UPDATE PRCommodity SET prcm_Name_ES ='Árbol de fruta', prcm_FullName_ES ='Árbol de fruta' WHERE prcm_CommodityID=109
UPDATE PRCommodity SET prcm_Name_ES ='Manzana', prcm_FullName_ES ='Manzana' WHERE prcm_CommodityID=110
UPDATE PRCommodity SET prcm_Name_ES ='Silvestre', prcm_FullName_ES ='Manzano Silvestre' WHERE prcm_CommodityID=111
UPDATE PRCommodity SET prcm_Name_ES ='Fuji', prcm_FullName_ES ='Manzana Fuji' WHERE prcm_CommodityID=112
UPDATE PRCommodity SET prcm_Name_ES ='Plátano', prcm_FullName_ES ='Plátano' WHERE prcm_CommodityID=116
UPDATE PRCommodity SET prcm_Name_ES ='Burro', prcm_FullName_ES ='Plátano Burro' WHERE prcm_CommodityID=123
UPDATE PRCommodity SET prcm_Name_ES ='Flor', prcm_FullName_ES ='Flor de Plátano' WHERE prcm_CommodityID=556
UPDATE PRCommodity SET prcm_Name_ES ='Hoja', prcm_FullName_ES ='Hoja de Plátano' WHERE prcm_CommodityID=117
UPDATE PRCommodity SET prcm_Name_ES ='Manzano', prcm_FullName_ES ='Plátano Manzano' WHERE prcm_CommodityID=122
UPDATE PRCommodity SET prcm_Name_ES ='Poovan', prcm_FullName_ES ='Plátano Poovan' WHERE prcm_CommodityID=576
UPDATE PRCommodity SET prcm_Name_ES ='Plátano', prcm_FullName_ES ='Plátano Banano' WHERE prcm_CommodityID=118
UPDATE PRCommodity SET prcm_Name_ES ='Hawaiano', prcm_FullName_ES ='Plátano Banano Hawaiano' WHERE prcm_CommodityID=119
UPDATE PRCommodity SET prcm_Name_ES ='Rojo', prcm_FullName_ES ='Plátano Rojo' WHERE prcm_CommodityID=121
UPDATE PRCommodity SET prcm_Name_ES ='Panapen', prcm_FullName_ES ='Panapen' WHERE prcm_CommodityID=124
UPDATE PRCommodity SET prcm_Name_ES ='Dátiles', prcm_FullName_ES ='Dátiles' WHERE prcm_CommodityID=128
UPDATE PRCommodity SET prcm_Name_ES ='Nopales', prcm_FullName_ES ='Nopales' WHERE prcm_CommodityID=10
UPDATE PRCommodity SET prcm_Name_ES ='Medjool', prcm_FullName_ES ='Dátiles Medjool' WHERE prcm_CommodityID=129
UPDATE PRCommodity SET prcm_Name_ES ='Pera', prcm_FullName_ES ='Pera' WHERE prcm_CommodityID=161
UPDATE PRCommodity SET prcm_Name_ES ='Asiática', prcm_FullName_ES ='Pera Asiática' WHERE prcm_CommodityID=165
UPDATE PRCommodity SET prcm_Name_ES ='Nashi', prcm_FullName_ES ='Pera Asiática Nashi' WHERE prcm_CommodityID=166
UPDATE PRCommodity SET prcm_Name_ES ='Tuna', prcm_FullName_ES ='Tuna' WHERE prcm_CommodityID=164
UPDATE PRCommodity SET prcm_Name_ES ='Fruta Tropical', prcm_FullName_ES ='Fruta Tropical' WHERE prcm_CommodityID=182
UPDATE PRCommodity SET prcm_Name_ES ='Atemoya', prcm_FullName_ES ='Atemoya' WHERE prcm_CommodityID=183
UPDATE PRCommodity SET prcm_Name_ES ='Chico Sapote', prcm_FullName_ES ='Chico Sapote' WHERE prcm_CommodityID=195
UPDATE PRCommodity SET prcm_Name_ES ='Coco', prcm_FullName_ES ='Coco' WHERE prcm_CommodityID=196
UPDATE PRCommodity SET prcm_Name_ES ='Agua', prcm_FullName_ES ='Agua de Coco' WHERE prcm_CommodityID=197
UPDATE PRCommodity SET prcm_Name_ES ='Dominicos', prcm_FullName_ES ='Plátano Dominicos' WHERE prcm_CommodityID=198
UPDATE PRCommodity SET prcm_Name_ES ='Feijoa', prcm_FullName_ES ='Feijoa' WHERE prcm_CommodityID=199
UPDATE PRCommodity SET prcm_Name_ES ='Higo', prcm_FullName_ES ='Higo' WHERE prcm_CommodityID=200
UPDATE PRCommodity SET prcm_Name_ES ='Café', prcm_FullName_ES ='Higo Café' WHERE prcm_CommodityID=551
UPDATE PRCommodity SET prcm_Name_ES ='Turquía', prcm_FullName_ES ='Higo Café de Turquía' WHERE prcm_CommodityID=552
UPDATE PRCommodity SET prcm_Name_ES ='Sierra', prcm_FullName_ES ='Higo de Sierra' WHERE prcm_CommodityID=553
UPDATE PRCommodity SET prcm_Name_ES ='Guayaba', prcm_FullName_ES ='Guayaba' WHERE prcm_CommodityID=201
UPDATE PRCommodity SET prcm_Name_ES ='Azufaifo', prcm_FullName_ES ='Azufaifo' WHERE prcm_CommodityID=202
UPDATE PRCommodity SET prcm_Name_ES ='Kiwi', prcm_FullName_ES ='Kiwi' WHERE prcm_CommodityID=203
UPDATE PRCommodity SET prcm_Name_ES ='Griego', prcm_FullName_ES ='Kiwi Griego' WHERE prcm_CommodityID=564
UPDATE PRCommodity SET prcm_Name_ES ='Mamey', prcm_FullName_ES ='Mamey' WHERE prcm_CommodityID=205
UPDATE PRCommodity SET prcm_Name_ES ='Mangostán', prcm_FullName_ES ='Mangostán' WHERE prcm_CommodityID=207
UPDATE PRCommodity SET prcm_Name_ES ='Papaya', prcm_FullName_ES ='Papaya' WHERE prcm_CommodityID=208
UPDATE PRCommodity SET prcm_Name_ES ='Verde', prcm_FullName_ES ='Papaya Verde' WHERE prcm_CommodityID=209
UPDATE PRCommodity SET prcm_Name_ES ='Aire Hawaiano', prcm_FullName_ES ='Papaya de Aire Hawaiano' WHERE prcm_CommodityID=210
UPDATE PRCommodity SET prcm_Name_ES ='Maracuyá', prcm_FullName_ES ='Maracuyá' WHERE prcm_CommodityID=211
UPDATE PRCommodity SET prcm_Name_ES ='Piña', prcm_FullName_ES ='Piña' WHERE prcm_CommodityID=213
UPDATE PRCommodity SET prcm_Name_ES ='Pitaya', prcm_FullName_ES ='Pitaya' WHERE prcm_CommodityID=214
UPDATE PRCommodity SET prcm_Name_ES ='Granada', prcm_FullName_ES ='Granada' WHERE prcm_CommodityID=215
UPDATE PRCommodity SET prcm_Name_ES ='Arilo', prcm_FullName_ES ='Granada de Arilo' WHERE prcm_CommodityID=1505
UPDATE PRCommodity SET prcm_Name_ES ='Sapotillo', prcm_FullName_ES ='Sapotillo' WHERE prcm_CommodityID=217
UPDATE PRCommodity SET prcm_Name_ES ='Zapote', prcm_FullName_ES ='Zapote' WHERE prcm_CommodityID=218
UPDATE PRCommodity SET prcm_Name_ES ='Tamarillo', prcm_FullName_ES ='Tamarillo' WHERE prcm_CommodityID=219
UPDATE PRCommodity SET prcm_Name_ES ='Tamarindo', prcm_FullName_ES ='Tamarindo' WHERE prcm_CommodityID=220
UPDATE PRCommodity SET prcm_Name_ES ='Fruta de la Vid', prcm_FullName_ES ='Fruta de la Vid' WHERE prcm_CommodityID=221
UPDATE PRCommodity SET prcm_Name_ES ='Melón', prcm_FullName_ES ='Melón' WHERE prcm_CommodityID=222
UPDATE PRCommodity SET prcm_Name_ES ='Uva', prcm_FullName_ES ='Uva' WHERE prcm_CommodityID=223
UPDATE PRCommodity SET prcm_Name_ES ='Vino', prcm_FullName_ES ='Uva de Vino' WHERE prcm_CommodityID=224
UPDATE PRCommodity SET prcm_Name_ES ='Melón Verde', prcm_FullName_ES ='Melón Verde' WHERE prcm_CommodityID=226
UPDATE PRCommodity SET prcm_Name_ES ='Jugo de Uva', prcm_FullName_ES ='Jugo de Uva' WHERE prcm_CommodityID=227
UPDATE PRCommodity SET prcm_Name_ES ='Kiwano', prcm_FullName_ES ='Kiwano' WHERE prcm_CommodityID=228
UPDATE PRCommodity SET prcm_Name_ES ='Melón', prcm_FullName_ES ='Melón' WHERE prcm_CommodityID=229
UPDATE PRCommodity SET prcm_Name_ES ='Amargo', prcm_FullName_ES ='Melón Amargo' WHERE prcm_CommodityID=569
UPDATE PRCommodity SET prcm_Name_ES ='Agrio', prcm_FullName_ES ='Melón Agrio' WHERE prcm_CommodityID=231
UPDATE PRCommodity SET prcm_Name_ES ='Casaba', prcm_FullName_ES ='Melón Casaba' WHERE prcm_CommodityID=235
UPDATE PRCommodity SET prcm_Name_ES ='Crenchar', prcm_FullName_ES ='Melón Crenchar' WHERE prcm_CommodityID=236
UPDATE PRCommodity SET prcm_Name_ES ='Melón Galia', prcm_FullName_ES ='Melón Galia' WHERE prcm_CommodityID=237
UPDATE PRCommodity SET prcm_Name_ES ='Encornado', prcm_FullName_ES ='Melón Encornado' WHERE prcm_CommodityID=233
UPDATE PRCommodity SET prcm_Name_ES ='Persa', prcm_FullName_ES ='Melón Persa' WHERE prcm_CommodityID=230
UPDATE PRCommodity SET prcm_Name_ES ='Invierno', prcm_FullName_ES ='Melón de Invierno' WHERE prcm_CommodityID=232
UPDATE PRCommodity SET prcm_Name_ES ='Pasas', prcm_FullName_ES ='Pasas' WHERE prcm_CommodityID=241
UPDATE PRCommodity SET prcm_Name_ES ='Sandía', prcm_FullName_ES ='Sandía' WHERE prcm_CommodityID=243
UPDATE PRCommodity SET prcm_Name_ES ='Sin Semilla', prcm_FullName_ES ='Sandía sin Semilla' WHERE prcm_CommodityID=244
UPDATE PRCommodity SET prcm_Name_ES ='Hierbas', prcm_FullName_ES ='Hierbas' WHERE prcm_CommodityID=248
UPDATE PRCommodity SET prcm_Name_ES ='Albahaca', prcm_FullName_ES ='Albahaca' WHERE prcm_CommodityID=249
UPDATE PRCommodity SET prcm_Name_ES ='Tailandia', prcm_FullName_ES ='Albahaca Tailandia' WHERE prcm_CommodityID=578
UPDATE PRCommodity SET prcm_Name_ES ='Hoja de Laurel', prcm_FullName_ES ='Hoja de Laurel' WHERE prcm_CommodityID=250
UPDATE PRCommodity SET prcm_Name_ES ='Perifollo', prcm_FullName_ES ='Perifollo' WHERE prcm_CommodityID=251
UPDATE PRCommodity SET prcm_Name_ES ='Cebollino', prcm_FullName_ES ='Cebollino' WHERE prcm_CommodityID=252
UPDATE PRCommodity SET prcm_Name_ES ='Cilantro', prcm_FullName_ES ='Cilantro' WHERE prcm_CommodityID=253
UPDATE PRCommodity SET prcm_Name_ES ='Culantro', prcm_FullName_ES ='Culantro' WHERE prcm_CommodityID=254
UPDATE PRCommodity SET prcm_Name_ES ='Menta vietnamita', prcm_FullName_ES ='Menta vietnamita' WHERE prcm_CommodityID=255
UPDATE PRCommodity SET prcm_Name_ES ='Eneldo', prcm_FullName_ES ='Eneldo' WHERE prcm_CommodityID=256
UPDATE PRCommodity SET prcm_Name_ES ='Epazote', prcm_FullName_ES ='Epazote' WHERE prcm_CommodityID=257
UPDATE PRCommodity SET prcm_Name_ES ='Hinojo', prcm_FullName_ES ='Hinojo' WHERE prcm_CommodityID=258
UPDATE PRCommodity SET prcm_Name_ES ='Fenogreco', prcm_FullName_ES ='Fenogreco' WHERE prcm_CommodityID=1506
UPDATE PRCommodity SET prcm_Name_ES ='Limoncillo', prcm_FullName_ES ='Limoncillo' WHERE prcm_CommodityID=259
UPDATE PRCommodity SET prcm_Name_ES ='Mejorana', prcm_FullName_ES ='Mejorana' WHERE prcm_CommodityID=260
UPDATE PRCommodity SET prcm_Name_ES ='Menta', prcm_FullName_ES ='Menta' WHERE prcm_CommodityID=261
UPDATE PRCommodity SET prcm_Name_ES ='Hierbabuena', prcm_FullName_ES ='Menta de hierbabuena' WHERE prcm_CommodityID=262
UPDATE PRCommodity SET prcm_Name_ES ='Menta verde', prcm_FullName_ES ='Menta verde' WHERE prcm_CommodityID=554
UPDATE PRCommodity SET prcm_Name_ES ='Orégano', prcm_FullName_ES ='Orégano' WHERE prcm_CommodityID=263
UPDATE PRCommodity SET prcm_Name_ES ='Perejil', prcm_FullName_ES ='Perejil' WHERE prcm_CommodityID=264
UPDATE PRCommodity SET prcm_Name_ES ='Persicaria', prcm_FullName_ES ='Persicaria' WHERE prcm_CommodityID=265
UPDATE PRCommodity SET prcm_Name_ES ='Romero', prcm_FullName_ES ='Romero' WHERE prcm_CommodityID=266
UPDATE PRCommodity SET prcm_Name_ES ='Salvia', prcm_FullName_ES ='Salvia' WHERE prcm_CommodityID=267
UPDATE PRCommodity SET prcm_Name_ES ='Ajedrea', prcm_FullName_ES ='Ajedrea' WHERE prcm_CommodityID=268
UPDATE PRCommodity SET prcm_Name_ES ='Estragón', prcm_FullName_ES ='Estragón' WHERE prcm_CommodityID=269
UPDATE PRCommodity SET prcm_Name_ES ='Tomillo', prcm_FullName_ES ='Tomillo' WHERE prcm_CommodityID=270
UPDATE PRCommodity SET prcm_Name_ES ='Nueces', prcm_FullName_ES ='Nueces' WHERE prcm_CommodityID=271
UPDATE PRCommodity SET prcm_Name_ES ='Almendras', prcm_FullName_ES ='Almendras' WHERE prcm_CommodityID=272
UPDATE PRCommodity SET prcm_Name_ES ='Nuez brasileña', prcm_FullName_ES ='Nuez brasileña' WHERE prcm_CommodityID=273
UPDATE PRCommodity SET prcm_Name_ES ='Anacardo', prcm_FullName_ES ='Anacardo' WHERE prcm_CommodityID=274
UPDATE PRCommodity SET prcm_Name_ES ='Castaña', prcm_FullName_ES ='Castaña' WHERE prcm_CommodityID=275
UPDATE PRCommodity SET prcm_Name_ES ='Italiana', prcm_FullName_ES ='Castaña italiana' WHERE prcm_CommodityID=276
UPDATE PRCommodity SET prcm_Name_ES ='Avellana', prcm_FullName_ES ='Avellana' WHERE prcm_CommodityID=277
UPDATE PRCommodity SET prcm_Name_ES ='Avellana', prcm_FullName_ES ='Avellana' WHERE prcm_CommodityID=278
UPDATE PRCommodity SET prcm_Name_ES ='Macadamia', prcm_FullName_ES ='Macadamia' WHERE prcm_CommodityID=279
UPDATE PRCommodity SET prcm_Name_ES ='Maní', prcm_FullName_ES ='Maní' WHERE prcm_CommodityID=280
UPDATE PRCommodity SET prcm_Name_ES ='Fresco', prcm_FullName_ES ='Maní fresco' WHERE prcm_CommodityID=281
UPDATE PRCommodity SET prcm_Name_ES ='Pacana', prcm_FullName_ES ='Pacana' WHERE prcm_CommodityID=282
UPDATE PRCommodity SET prcm_Name_ES ='Piñón', prcm_FullName_ES ='Piñón' WHERE prcm_CommodityID=283
UPDATE PRCommodity SET prcm_Name_ES ='Pistacho', prcm_FullName_ES ='Pistacho' WHERE prcm_CommodityID=284
UPDATE PRCommodity SET prcm_Name_ES ='Nuez', prcm_FullName_ES ='Nuez' WHERE prcm_CommodityID=285
UPDATE PRCommodity SET prcm_Name_ES ='Especia', prcm_FullName_ES ='Especia' WHERE prcm_CommodityID=287
UPDATE PRCommodity SET prcm_Name_ES ='Anís', prcm_FullName_ES ='Anís' WHERE prcm_CommodityID=288
UPDATE PRCommodity SET prcm_Name_ES ='Semillas de Fenogreco', prcm_FullName_ES ='Semillas de Fenogreco' WHERE prcm_CommodityID=289
UPDATE PRCommodity SET prcm_Name_ES ='Vegetales', prcm_FullName_ES ='Vegetales' WHERE prcm_CommodityID=291
UPDATE PRCommodity SET prcm_Name_ES ='Vegetal Asiático', prcm_FullName_ES ='Vegetal Asiático' WHERE prcm_CommodityID=292
UPDATE PRCommodity SET prcm_Name_ES ='Bac Ha', prcm_FullName_ES ='Bac Ha' WHERE prcm_CommodityID=293
UPDATE PRCommodity SET prcm_Name_ES ='Brote de Bambú', prcm_FullName_ES ='Brote de Bambú' WHERE prcm_CommodityID=294
UPDATE PRCommodity SET prcm_Name_ES ='Col China', prcm_FullName_ES ='Col China' WHERE prcm_CommodityID=295
UPDATE PRCommodity SET prcm_Name_ES ='Daikon', prcm_FullName_ES ='Daikon' WHERE prcm_CommodityID=296
UPDATE PRCommodity SET prcm_Name_ES ='Gai Choy', prcm_FullName_ES ='Gai Choy' WHERE prcm_CommodityID=297
UPDATE PRCommodity SET prcm_Name_ES ='Rau Day', prcm_FullName_ES ='Rau Day' WHERE prcm_CommodityID=298
UPDATE PRCommodity SET prcm_Name_ES ='Tindora', prcm_FullName_ES ='Tindora' WHERE prcm_CommodityID=299
UPDATE PRCommodity SET prcm_Name_ES ='Yu Choy Sum', prcm_FullName_ES ='Yu Choy Sum' WHERE prcm_CommodityID=300
UPDATE PRCommodity SET prcm_Name_ES ='Bulbo', prcm_FullName_ES ='Bulbo' WHERE prcm_CommodityID=301
UPDATE PRCommodity SET prcm_Name_ES ='Ajo', prcm_FullName_ES ='Ajo' WHERE prcm_CommodityID=302
UPDATE PRCommodity SET prcm_Name_ES ='Trenzado', prcm_FullName_ES ='Ajo Trenzado' WHERE prcm_CommodityID=303
UPDATE PRCommodity SET prcm_Name_ES ='Elefante', prcm_FullName_ES ='Ajo Grande (Elefante)' WHERE prcm_CommodityID=304
UPDATE PRCommodity SET prcm_Name_ES ='Verde', prcm_FullName_ES ='Ajo Verde' WHERE prcm_CommodityID=566
UPDATE PRCommodity SET prcm_Name_ES ='Cebolla Verde', prcm_FullName_ES ='Cebolla Verde' WHERE prcm_CommodityID=305
UPDATE PRCommodity SET prcm_Name_ES ='Cebollín', prcm_FullName_ES ='Cebollín Cebolla' WHERE prcm_CommodityID=306
UPDATE PRCommodity SET prcm_Name_ES ='Colinabo', prcm_FullName_ES ='Colinabo' WHERE prcm_CommodityID=307
UPDATE PRCommodity SET prcm_Name_ES ='Puerro', prcm_FullName_ES ='Puerro' WHERE prcm_CommodityID=308
UPDATE PRCommodity SET prcm_Name_ES ='Cebolla', prcm_FullName_ES ='Cebolla' WHERE prcm_CommodityID=309
UPDATE PRCommodity SET prcm_Name_ES ='Cipolino', prcm_FullName_ES ='Cebolla Cipolino' WHERE prcm_CommodityID=315
UPDATE PRCommodity SET prcm_Name_ES ='Perla', prcm_FullName_ES ='Cebolla Perla' WHERE prcm_CommodityID=316
UPDATE PRCommodity SET prcm_Name_ES ='Rojo', prcm_FullName_ES ='Cebolla Roja' WHERE prcm_CommodityID=314
UPDATE PRCommodity SET prcm_Name_ES ='Semilla', prcm_FullName_ES ='Semilla de Cebolla' WHERE prcm_CommodityID=313
UPDATE PRCommodity SET prcm_Name_ES ='Conjunto', prcm_FullName_ES ='Conjunto de Cebolla' WHERE prcm_CommodityID=574
UPDATE PRCommodity SET prcm_Name_ES ='Española', prcm_FullName_ES ='Cebolla Española' WHERE prcm_CommodityID=317
UPDATE PRCommodity SET prcm_Name_ES ='Dulce', prcm_FullName_ES ='Cebolla Dulce' WHERE prcm_CommodityID=311
UPDATE PRCommodity SET prcm_Name_ES ='Blanco', prcm_FullName_ES ='Cebolla Blanca' WHERE prcm_CommodityID=312
UPDATE PRCommodity SET prcm_Name_ES ='Amarilla', prcm_FullName_ES ='Cebolla Amarilla' WHERE prcm_CommodityID=310
UPDATE PRCommodity SET prcm_Name_ES ='Semilla de Ajo', prcm_FullName_ES ='Semilla de Ajo' WHERE prcm_CommodityID=318
UPDATE PRCommodity SET prcm_Name_ES ='Chalote', prcm_FullName_ES ='Chalote' WHERE prcm_CommodityID=319
UPDATE PRCommodity SET prcm_Name_ES ='Maíz', prcm_FullName_ES ='Maíz' WHERE prcm_CommodityID=484
UPDATE PRCommodity SET prcm_Name_ES ='Indio', prcm_FullName_ES ='Maíz Indio' WHERE prcm_CommodityID=485
UPDATE PRCommodity SET prcm_Name_ES ='Ornamental', prcm_FullName_ES ='Maíz Ornamental' WHERE prcm_CommodityID=486
UPDATE PRCommodity SET prcm_Name_ES ='Dulce', prcm_FullName_ES ='Maíz Dulce' WHERE prcm_CommodityID=487
UPDATE PRCommodity SET prcm_Name_ES ='Hoja de maíz', prcm_FullName_ES ='Hoja de maíz' WHERE prcm_CommodityID=489
UPDATE PRCommodity SET prcm_Name_ES ='Palomitas de Maíz', prcm_FullName_ES ='Palomitas de Maíz' WHERE prcm_CommodityID=488
UPDATE PRCommodity SET prcm_Name_ES ='Pepino', prcm_FullName_ES ='Pepino' WHERE prcm_CommodityID=491
UPDATE PRCommodity SET prcm_Name_ES ='Inglés', prcm_FullName_ES ='Pepino Inglés' WHERE prcm_CommodityID=498
UPDATE PRCommodity SET prcm_Name_ES ='Europeo', prcm_FullName_ES ='Pepino Europeo' WHERE prcm_CommodityID=497
UPDATE PRCommodity SET prcm_Name_ES ='Japonés', prcm_FullName_ES ='Pepino Japonés' WHERE prcm_CommodityID=494
UPDATE PRCommodity SET prcm_Name_ES ='Persa', prcm_FullName_ES ='Pepino Persa' WHERE prcm_CommodityID=495
UPDATE PRCommodity SET prcm_Name_ES ='En Escabeche', prcm_FullName_ES ='Pepino Persa en Escabeche' WHERE prcm_CommodityID=496
UPDATE PRCommodity SET prcm_Name_ES ='En Escabeche', prcm_FullName_ES ='Pepino en Escabeche' WHERE prcm_CommodityID=499
UPDATE PRCommodity SET prcm_Name_ES ='Sin Semilla', prcm_FullName_ES ='Pepino sin Semilla' WHERE prcm_CommodityID=492
UPDATE PRCommodity SET prcm_Name_ES ='Berenjena', prcm_FullName_ES ='Berenjena' WHERE prcm_CommodityID=544
UPDATE PRCommodity SET prcm_Name_ES ='China', prcm_FullName_ES ='Berenjena China' WHERE prcm_CommodityID=549
UPDATE PRCommodity SET prcm_Name_ES ='Indio', prcm_FullName_ES ='Berenjena India' WHERE prcm_CommodityID=548
UPDATE PRCommodity SET prcm_Name_ES ='Italiana', prcm_FullName_ES ='Berenjena Italiana' WHERE prcm_CommodityID=547
UPDATE PRCommodity SET prcm_Name_ES ='Japonés', prcm_FullName_ES ='Berenjena Japonesa' WHERE prcm_CommodityID=545
UPDATE PRCommodity SET prcm_Name_ES ='Tailandia', prcm_FullName_ES ='Berenjena Tailandesa' WHERE prcm_CommodityID=546
UPDATE PRCommodity SET prcm_Name_ES ='Calabacín', prcm_FullName_ES ='Calabacín' WHERE prcm_CommodityID=321
UPDATE PRCommodity SET prcm_Name_ES ='Chayote', prcm_FullName_ES ='Chayote' WHERE prcm_CommodityID=322
UPDATE PRCommodity SET prcm_Name_ES ='Calabaza', prcm_FullName_ES ='Calabaza' WHERE prcm_CommodityID=338
UPDATE PRCommodity SET prcm_Name_ES ='Ornamental', prcm_FullName_ES ='Calabaza Ornamental' WHERE prcm_CommodityID=339
UPDATE PRCommodity SET prcm_Name_ES ='Calabaza', prcm_FullName_ES ='Calabaza' WHERE prcm_CommodityID=323
UPDATE PRCommodity SET prcm_Name_ES ='Calabacín', prcm_FullName_ES ='Calabacín' WHERE prcm_CommodityID=324
UPDATE PRCommodity SET prcm_Name_ES ='China', prcm_FullName_ES ='Calabancín Chino' WHERE prcm_CommodityID=335
UPDATE PRCommodity SET prcm_Name_ES ='Zapallo', prcm_FullName_ES ='Zapallo' WHERE prcm_CommodityID=334
UPDATE PRCommodity SET prcm_Name_ES ='Cáscara Dura', prcm_FullName_ES ='Zapallo de Cáscara Cura' WHERE prcm_CommodityID=328
UPDATE PRCommodity SET prcm_Name_ES ='Bellota', prcm_FullName_ES ='Zapallo de Cáscara Dura tipo Bellota' WHERE prcm_CommodityID=331
UPDATE PRCommodity SET prcm_Name_ES ='Banano', prcm_FullName_ES ='Zapallo de Cáscara Dura tipo Banano' WHERE prcm_CommodityID=329
UPDATE PRCommodity SET prcm_Name_ES ='Kabocha', prcm_FullName_ES ='Zapallo de Cáscara Dura tipo Kabocha' WHERE prcm_CommodityID=330
UPDATE PRCommodity SET prcm_Name_ES ='Espagueti', prcm_FullName_ES ='Zapallo de Cáscara Dura tipo Espagueti' WHERE prcm_CommodityID=332
UPDATE PRCommodity SET prcm_Name_ES ='Italiana', prcm_FullName_ES ='Zapallo Italiano' WHERE prcm_CommodityID=333
UPDATE PRCommodity SET prcm_Name_ES ='Mexicano', prcm_FullName_ES ='Zapallo Mexicano' WHERE prcm_CommodityID=327
UPDATE PRCommodity SET prcm_Name_ES ='Mo Qua', prcm_FullName_ES ='Zapallo Mo Qua' WHERE prcm_CommodityID=561
UPDATE PRCommodity SET prcm_Name_ES ='Peludo', prcm_FullName_ES ='Zapallo Mo Qua Peludo' WHERE prcm_CommodityID=562
UPDATE PRCommodity SET prcm_Name_ES ='Ornamental', prcm_FullName_ES ='Zapallo Ornamental' WHERE prcm_CommodityID=573
UPDATE PRCommodity SET prcm_Name_ES ='Amarillo', prcm_FullName_ES ='Zapallo Amarillo' WHERE prcm_CommodityID=336
UPDATE PRCommodity SET prcm_Name_ES ='Calabacita', prcm_FullName_ES ='Zapallo tipo Calabacita' WHERE prcm_CommodityID=326
UPDATE PRCommodity SET prcm_Name_ES ='Vegetales Hispanos', prcm_FullName_ES ='Vegetales Hispanos' WHERE prcm_CommodityID=340
UPDATE PRCommodity SET prcm_Name_ES ='Jícama', prcm_FullName_ES ='Jícama' WHERE prcm_CommodityID=341
UPDATE PRCommodity SET prcm_Name_ES ='Inflorescencia', prcm_FullName_ES ='Inflorescencia' WHERE prcm_CommodityID=342
UPDATE PRCommodity SET prcm_Name_ES ='Alcachofa', prcm_FullName_ES ='Alcachofa' WHERE prcm_CommodityID=343
UPDATE PRCommodity SET prcm_Name_ES ='Col Romana', prcm_FullName_ES ='Col Romana' WHERE prcm_CommodityID=344
UPDATE PRCommodity SET prcm_Name_ES ='Brócoli', prcm_FullName_ES ='Brócoli' WHERE prcm_CommodityID=345
UPDATE PRCommodity SET prcm_Name_ES ='Corona', prcm_FullName_ES ='Brócoli de Corona' WHERE prcm_CommodityID=346
UPDATE PRCommodity SET prcm_Name_ES ='Rabé', prcm_FullName_ES ='Brócoli Rabé' WHERE prcm_CommodityID=347
UPDATE PRCommodity SET prcm_Name_ES ='Coliflor', prcm_FullName_ES ='Coliflor' WHERE prcm_CommodityID=348
UPDATE PRCommodity SET prcm_Name_ES ='Vegetal de Hojas', prcm_FullName_ES ='Vegetal de Hojas' WHERE prcm_CommodityID=349
UPDATE PRCommodity SET prcm_Name_ES ='Arúgula', prcm_FullName_ES ='Arúgula' WHERE prcm_CommodityID=350
UPDATE PRCommodity SET prcm_Name_ES ='Repollo', prcm_FullName_ES ='Repollo' WHERE prcm_CommodityID=352
UPDATE PRCommodity SET prcm_Name_ES ='Asiático', prcm_FullName_ES ='Repollo Aasiático' WHERE prcm_CommodityID=353
UPDATE PRCommodity SET prcm_Name_ES ='Chino', prcm_FullName_ES ='Repollo Asiático, Chino' WHERE prcm_CommodityID=354
UPDATE PRCommodity SET prcm_Name_ES ='Verde', prcm_FullName_ES ='Repollo Verde' WHERE prcm_CommodityID=356
UPDATE PRCommodity SET prcm_Name_ES ='Rojo', prcm_FullName_ES ='Repollo Rojo' WHERE prcm_CommodityID=357
UPDATE PRCommodity SET prcm_Name_ES ='Milán', prcm_FullName_ES ='Col de Milán' WHERE prcm_CommodityID=355
UPDATE PRCommodity SET prcm_Name_ES ='Calaloo', prcm_FullName_ES ='Calaloo' WHERE prcm_CommodityID=358
UPDATE PRCommodity SET prcm_Name_ES ='Acelga', prcm_FullName_ES ='Acelga' WHERE prcm_CommodityID=359
UPDATE PRCommodity SET prcm_Name_ES ='Chicorria', prcm_FullName_ES ='Chicorria' WHERE prcm_CommodityID=360
UPDATE PRCommodity SET prcm_Name_ES ='Lechuga Endigia', prcm_FullName_ES ='Lechuga Endigia' WHERE prcm_CommodityID=361
UPDATE PRCommodity SET prcm_Name_ES ='Endibia', prcm_FullName_ES ='Endibia' WHERE prcm_CommodityID=362
UPDATE PRCommodity SET prcm_Name_ES ='Belga', prcm_FullName_ES ='Endibia belga' WHERE prcm_CommodityID=363
UPDATE PRCommodity SET prcm_Name_ES ='Escarola', prcm_FullName_ES ='Escarola' WHERE prcm_CommodityID=365
UPDATE PRCommodity SET prcm_Name_ES ='Helecho', prcm_FullName_ES ='Helecho' WHERE prcm_CommodityID=366
UPDATE PRCommodity SET prcm_Name_ES ='Frisee', prcm_FullName_ES ='Frisee' WHERE prcm_CommodityID=368
UPDATE PRCommodity SET prcm_Name_ES ='Hojas', prcm_FullName_ES ='Hojas' WHERE prcm_CommodityID=370
UPDATE PRCommodity SET prcm_Name_ES ='Remolacha', prcm_FullName_ES ='Hojas de Remolacha' WHERE prcm_CommodityID=380
UPDATE PRCommodity SET prcm_Name_ES ='Berza', prcm_FullName_ES ='Hojas de Berza' WHERE prcm_CommodityID=379
UPDATE PRCommodity SET prcm_Name_ES ='Diente de León', prcm_FullName_ES ='Hojas de Diente de León' WHERE prcm_CommodityID=378
UPDATE PRCommodity SET prcm_Name_ES ='Donqua', prcm_FullName_ES ='Hojas de Donqua' WHERE prcm_CommodityID=377
UPDATE PRCommodity SET prcm_Name_ES ='Rábano', prcm_FullName_ES ='Hojas de Rábano' WHERE prcm_CommodityID=371
UPDATE PRCommodity SET prcm_Name_ES ='Kim Chee', prcm_FullName_ES ='Hojas de Kim Chee' WHERE prcm_CommodityID=373
UPDATE PRCommodity SET prcm_Name_ES ='Mesclun', prcm_FullName_ES ='Mesclun' WHERE prcm_CommodityID=374
UPDATE PRCommodity SET prcm_Name_ES ='Hojas Micro', prcm_FullName_ES ='Hojas Verdes Micro' WHERE prcm_CommodityID=383
UPDATE PRCommodity SET prcm_Name_ES ='Mostaza', prcm_FullName_ES ='Hojas de Mostaza' WHERE prcm_CommodityID=381
UPDATE PRCommodity SET prcm_Name_ES ='Nabo', prcm_FullName_ES ='Hojas de Nabo' WHERE prcm_CommodityID=372
UPDATE PRCommodity SET prcm_Name_ES ='Sherlihon', prcm_FullName_ES ='Hojas de Sherlihon' WHERE prcm_CommodityID=577
UPDATE PRCommodity SET prcm_Name_ES ='Nabo', prcm_FullName_ES ='Hojas de Nabo' WHERE prcm_CommodityID=375
UPDATE PRCommodity SET prcm_Name_ES ='Col Rizada', prcm_FullName_ES ='Col Rizada' WHERE prcm_CommodityID=384
UPDATE PRCommodity SET prcm_Name_ES ='Gas lan', prcm_FullName_ES ='Gai Lan Col Rizada' WHERE prcm_CommodityID=1500
UPDATE PRCommodity SET prcm_Name_ES ='Lechuga', prcm_FullName_ES ='Lechuga' WHERE prcm_CommodityID=385
UPDATE PRCommodity SET prcm_Name_ES ='Bibb', prcm_FullName_ES ='Lechuga Bibb' WHERE prcm_CommodityID=386
UPDATE PRCommodity SET prcm_Name_ES ='Boston', prcm_FullName_ES ='Lechuga Boston' WHERE prcm_CommodityID=387
UPDATE PRCommodity SET prcm_Name_ES ='Mantequilla', prcm_FullName_ES ='Lechuga Mantequilla' WHERE prcm_CommodityID=392
UPDATE PRCommodity SET prcm_Name_ES ='Hoja', prcm_FullName_ES ='Hoja de Lechuga' WHERE prcm_CommodityID=388
UPDATE PRCommodity SET prcm_Name_ES ='Maché', prcm_FullName_ES ='Lechuga de Maché' WHERE prcm_CommodityID=389
UPDATE PRCommodity SET prcm_Name_ES ='Rojo', prcm_FullName_ES ='Lechuga Roja' WHERE prcm_CommodityID=390
UPDATE PRCommodity SET prcm_Name_ES ='Romana', prcm_FullName_ES ='Lechuga Romana' WHERE prcm_CommodityID=391
UPDATE PRCommodity SET prcm_Name_ES ='Achicoria', prcm_FullName_ES ='Achicoria' WHERE prcm_CommodityID=393
UPDATE PRCommodity SET prcm_Name_ES ='Grelo', prcm_FullName_ES ='Grelo' WHERE prcm_CommodityID=394
UPDATE PRCommodity SET prcm_Name_ES ='Ensalada', prcm_FullName_ES ='Ensalada' WHERE prcm_CommodityID=396
UPDATE PRCommodity SET prcm_Name_ES ='Alazán', prcm_FullName_ES ='Alazán' WHERE prcm_CommodityID=397
UPDATE PRCommodity SET prcm_Name_ES ='Espinaca', prcm_FullName_ES ='Espinaca' WHERE prcm_CommodityID=398
UPDATE PRCommodity SET prcm_Name_ES ='Ong Choy', prcm_FullName_ES ='Espinaca Ong Choy' WHERE prcm_CommodityID=399
UPDATE PRCommodity SET prcm_Name_ES ='Mezcla de Primavera', prcm_FullName_ES ='Mezcla de Primavera' WHERE prcm_CommodityID=400
UPDATE PRCommodity SET prcm_Name_ES ='Berro', prcm_FullName_ES ='Berro' WHERE prcm_CommodityID=401
UPDATE PRCommodity SET prcm_Name_ES ='Legumbre', prcm_FullName_ES ='Legumbre' WHERE prcm_CommodityID=403
UPDATE PRCommodity SET prcm_Name_ES ='Alfalfa', prcm_FullName_ES ='Alfalfa' WHERE prcm_CommodityID=582
UPDATE PRCommodity SET prcm_Name_ES ='Frijoles', prcm_FullName_ES ='Frijoles' WHERE prcm_CommodityID=404
UPDATE PRCommodity SET prcm_Name_ES ='Negros', prcm_FullName_ES ='Frijoles Negros' WHERE prcm_CommodityID=407
UPDATE PRCommodity SET prcm_Name_ES ='Largos Chinos', prcm_FullName_ES ='Frijoles Largos Chinos' WHERE prcm_CommodityID=415
UPDATE PRCommodity SET prcm_Name_ES ='Haba', prcm_FullName_ES ='Habas' WHERE prcm_CommodityID=423
UPDATE PRCommodity SET prcm_Name_ES ='Judía', prcm_FullName_ES ='Ejote Frances' WHERE prcm_CommodityID=421
UPDATE PRCommodity SET prcm_Name_ES ='Garbanzo', prcm_FullName_ES ='Garbanzos' WHERE prcm_CommodityID=420
UPDATE PRCommodity SET prcm_Name_ES ='Verde', prcm_FullName_ES ='Ejote' WHERE prcm_CommodityID=419
UPDATE PRCommodity SET prcm_Name_ES ='Guar', prcm_FullName_ES ='Vaina de Guar' WHERE prcm_CommodityID=418
UPDATE PRCommodity SET prcm_Name_ES ='Alubias', prcm_FullName_ES ='Alubias Rojas' WHERE prcm_CommodityID=417
UPDATE PRCommodity SET prcm_Name_ES ='Lentejas', prcm_FullName_ES ='Lentejas' WHERE prcm_CommodityID=416
UPDATE PRCommodity SET prcm_Name_ES ='Lima', prcm_FullName_ES ='Frijoles Lima' WHERE prcm_CommodityID=422
UPDATE PRCommodity SET prcm_Name_ES ='Largo', prcm_FullName_ES ='Alubias Largas' WHERE prcm_CommodityID=405
UPDATE PRCommodity SET prcm_Name_ES ='Guisantes', prcm_FullName_ES ='Guisantes' WHERE prcm_CommodityID=413
UPDATE PRCommodity SET prcm_Name_ES ='Judías negras', prcm_FullName_ES ='Alverjas' WHERE prcm_CommodityID=414
UPDATE PRCommodity SET prcm_Name_ES ='Pinto', prcm_FullName_ES ='Frijoles pintos' WHERE prcm_CommodityID=412
UPDATE PRCommodity SET prcm_Name_ES ='Judías', prcm_FullName_ES ='Judías' WHERE prcm_CommodityID=411
UPDATE PRCommodity SET prcm_Name_ES ='Ejote', prcm_FullName_ES ='Ejotes' WHERE prcm_CommodityID=410
UPDATE PRCommodity SET prcm_Name_ES ='Retoños de Soja', prcm_FullName_ES ='Retoños de soja' WHERE prcm_CommodityID=409
UPDATE PRCommodity SET prcm_Name_ES ='Frijoles Germinado', prcm_FullName_ES ='Frijoles Germinado' WHERE prcm_CommodityID=408
UPDATE PRCommodity SET prcm_Name_ES ='Ejote', prcm_FullName_ES ='Ejote blanco' WHERE prcm_CommodityID=406
UPDATE PRCommodity SET prcm_Name_ES ='Frijoles Secos', prcm_FullName_ES ='Frijoles secos' WHERE prcm_CommodityID=424
UPDATE PRCommodity SET prcm_Name_ES ='Frijoles Secos Chinos', prcm_FullName_ES ='Frijoles Secos Chinos' WHERE prcm_CommodityID=425
UPDATE PRCommodity SET prcm_Name_ES ='Edamame', prcm_FullName_ES ='Edamame' WHERE prcm_CommodityID=426
UPDATE PRCommodity SET prcm_Name_ES ='Chícharo', prcm_FullName_ES ='Chícharo' WHERE prcm_CommodityID=427
UPDATE PRCommodity SET prcm_Name_ES ='Chino', prcm_FullName_ES ='Arveja China' WHERE prcm_CommodityID=431
UPDATE PRCommodity SET prcm_Name_ES ='Inglés', prcm_FullName_ES ='Arveja Inglesa' WHERE prcm_CommodityID=432
UPDATE PRCommodity SET prcm_Name_ES ='Ejote', prcm_FullName_ES ='Ejote' WHERE prcm_CommodityID=433
UPDATE PRCommodity SET prcm_Name_ES ='Bisalto', prcm_FullName_ES ='Bisalto' WHERE prcm_CommodityID=428
UPDATE PRCommodity SET prcm_Name_ES ='Hebra', prcm_FullName_ES ='Guisante sin Hebra' WHERE prcm_CommodityID=429
UPDATE PRCommodity SET prcm_Name_ES ='Ejote', prcm_FullName_ES ='Guisantes Azucarados' WHERE prcm_CommodityID=430
UPDATE PRCommodity SET prcm_Name_ES ='Chile Mexicano', prcm_FullName_ES ='Chile Mexicano' WHERE prcm_CommodityID=500
UPDATE PRCommodity SET prcm_Name_ES ='Hongos', prcm_FullName_ES ='Hongos' WHERE prcm_CommodityID=501
UPDATE PRCommodity SET prcm_Name_ES ='Matsutake', prcm_FullName_ES ='Hongo Matsutake' WHERE prcm_CommodityID=571
UPDATE PRCommodity SET prcm_Name_ES ='Morel', prcm_FullName_ES ='Hongo Morel' WHERE prcm_CommodityID=503
UPDATE PRCommodity SET prcm_Name_ES ='Shiitake', prcm_FullName_ES ='Hongo Shiitake' WHERE prcm_CommodityID=502
UPDATE PRCommodity SET prcm_Name_ES ='Okra', prcm_FullName_ES ='Okra' WHERE prcm_CommodityID=504
UPDATE PRCommodity SET prcm_Name_ES ='On choy', prcm_FullName_ES ='On choy' WHERE prcm_CommodityID=580
UPDATE PRCommodity SET prcm_Name_ES ='Chile', prcm_FullName_ES ='Chile' WHERE prcm_CommodityID=505
UPDATE PRCommodity SET prcm_Name_ES ='Ají Cachucha', prcm_FullName_ES ='Pimienta Ají Cachucha' WHERE prcm_CommodityID=520
UPDATE PRCommodity SET prcm_Name_ES ='Anaheim', prcm_FullName_ES ='Pimienta Anaheim' WHERE prcm_CommodityID=519
UPDATE PRCommodity SET prcm_Name_ES ='Blanco', prcm_FullName_ES ='Pimiento Blanco' WHERE prcm_CommodityID=1502
UPDATE PRCommodity SET prcm_Name_ES ='Pimentón', prcm_FullName_ES ='Pimentón' WHERE prcm_CommodityID=521
UPDATE PRCommodity SET prcm_Name_ES ='Naranja', prcm_FullName_ES ='Pimiento Morrón Naranja' WHERE prcm_CommodityID=527
UPDATE PRCommodity SET prcm_Name_ES ='Morado', prcm_FullName_ES ='Pimiento Morrón Morado' WHERE prcm_CommodityID=526
UPDATE PRCommodity SET prcm_Name_ES ='Rojo', prcm_FullName_ES ='Pimiento Morrón Rojo' WHERE prcm_CommodityID=525
UPDATE PRCommodity SET prcm_Name_ES ='Blanco', prcm_FullName_ES ='Pimiento Morrón Blanco' WHERE prcm_CommodityID=524
UPDATE PRCommodity SET prcm_Name_ES ='Amarillo', prcm_FullName_ES ='Pimiento Morrón Amarillo' WHERE prcm_CommodityID=523
UPDATE PRCommodity SET prcm_Name_ES ='Caribe', prcm_FullName_ES ='Pimiento del Caribe' WHERE prcm_CommodityID=581
UPDATE PRCommodity SET prcm_Name_ES ='Cayena Roja', prcm_FullName_ES ='Pimienta de Cayena Rojo' WHERE prcm_CommodityID=518
UPDATE PRCommodity SET prcm_Name_ES ='Chile', prcm_FullName_ES ='Chile' WHERE prcm_CommodityID=517
UPDATE PRCommodity SET prcm_Name_ES ='Picante Delgado', prcm_FullName_ES ='Chile Picante Delgado' WHERE prcm_CommodityID=1511
UPDATE PRCommodity SET prcm_Name_ES ='Verde', prcm_FullName_ES ='Pimiento Verde' WHERE prcm_CommodityID=565
UPDATE PRCommodity SET prcm_Name_ES ='Manzano', prcm_FullName_ES ='Chile Manzano' WHERE prcm_CommodityID=570
UPDATE PRCommodity SET prcm_Name_ES ='Cubanelle', prcm_FullName_ES ='Chile Cubanelle' WHERE prcm_CommodityID=529
UPDATE PRCommodity SET prcm_Name_ES ='Fresno', prcm_FullName_ES ='Chile Fresno' WHERE prcm_CommodityID=506
UPDATE PRCommodity SET prcm_Name_ES ='Rojo', prcm_FullName_ES ='Chile Fresno Rojo' WHERE prcm_CommodityID=507
UPDATE PRCommodity SET prcm_Name_ES ='Habanero', prcm_FullName_ES ='Chile Habanero' WHERE prcm_CommodityID=516
UPDATE PRCommodity SET prcm_Name_ES ='Jalapeño', prcm_FullName_ES ='Chile Jalapeño' WHERE prcm_CommodityID=514
UPDATE PRCommodity SET prcm_Name_ES ='Picante', prcm_FullName_ES ='Chile Jalapeño Picante' WHERE prcm_CommodityID=515
UPDATE PRCommodity SET prcm_Name_ES ='Pasilla', prcm_FullName_ES ='Chile Pasilla' WHERE prcm_CommodityID=513
UPDATE PRCommodity SET prcm_Name_ES ='Poblano', prcm_FullName_ES ='Chile Poblano' WHERE prcm_CommodityID=512
UPDATE PRCommodity SET prcm_Name_ES ='Rojo', prcm_FullName_ES ='Chile Rojo' WHERE prcm_CommodityID=511
UPDATE PRCommodity SET prcm_Name_ES ='Pimientos', prcm_FullName_ES ='Aji Chombo' WHERE prcm_CommodityID=509
UPDATE PRCommodity SET prcm_Name_ES ='Serrano', prcm_FullName_ES ='Chile Serrano' WHERE prcm_CommodityID=510
UPDATE PRCommodity SET prcm_Name_ES ='Tailandés', prcm_FullName_ES ='Pimiento Thai' WHERE prcm_CommodityID=528
UPDATE PRCommodity SET prcm_Name_ES ='Amarillo', prcm_FullName_ES ='Pimiento Amarillo' WHERE prcm_CommodityID=508
UPDATE PRCommodity SET prcm_Name_ES ='Pimiento', prcm_FullName_ES ='Pimiento' WHERE prcm_CommodityID=530
UPDATE PRCommodity SET prcm_Name_ES ='Hortaliza de Raíz', prcm_FullName_ES ='Hortaliza de Raíz' WHERE prcm_CommodityID=434
UPDATE PRCommodity SET prcm_Name_ES ='Arrurrúz', prcm_FullName_ES ='Arrurrúz' WHERE prcm_CommodityID=435
UPDATE PRCommodity SET prcm_Name_ES ='Remolacha', prcm_FullName_ES ='Remolacha' WHERE prcm_CommodityID=436
UPDATE PRCommodity SET prcm_Name_ES ='Boniato', prcm_FullName_ES ='Boniato' WHERE prcm_CommodityID=437
UPDATE PRCommodity SET prcm_Name_ES ='Zanahoria', prcm_FullName_ES ='Zanahoria' WHERE prcm_CommodityID=438
UPDATE PRCommodity SET prcm_Name_ES ='Mandioca', prcm_FullName_ES ='Mandioca' WHERE prcm_CommodityID=439
UPDATE PRCommodity SET prcm_Name_ES ='Raíz de Apio', prcm_FullName_ES ='Raíz de Apio' WHERE prcm_CommodityID=440
UPDATE PRCommodity SET prcm_Name_ES ='Jengibre', prcm_FullName_ES ='Jengibre' WHERE prcm_CommodityID=442
UPDATE PRCommodity SET prcm_Name_ES ='Raíz', prcm_FullName_ES ='Raíz de Jengibre' WHERE prcm_CommodityID=443
UPDATE PRCommodity SET prcm_Name_ES ='Regular', prcm_FullName_ES ='Raíz de Jengibre Regular' WHERE prcm_CommodityID=444
UPDATE PRCommodity SET prcm_Name_ES ='Tailandés', prcm_FullName_ES ='Raíz de Jengibre Tailandés' WHERE prcm_CommodityID=445
UPDATE PRCommodity SET prcm_Name_ES ='Rábano', prcm_FullName_ES ='Rábano Picante' WHERE prcm_CommodityID=376
UPDATE PRCommodity SET prcm_Name_ES ='Raíz de Loto', prcm_FullName_ES ='Raíz de Loto' WHERE prcm_CommodityID=447
UPDATE PRCommodity SET prcm_Name_ES ='Malanga', prcm_FullName_ES ='Malanga' WHERE prcm_CommodityID=448
UPDATE PRCommodity SET prcm_Name_ES ='Tagarninas', prcm_FullName_ES ='Tagarninas' WHERE prcm_CommodityID=449
UPDATE PRCommodity SET prcm_Name_ES ='Chirivia', prcm_FullName_ES ='Chirivia' WHERE prcm_CommodityID=450
UPDATE PRCommodity SET prcm_Name_ES ='Papa', prcm_FullName_ES ='Papa' WHERE prcm_CommodityID=451
UPDATE PRCommodity SET prcm_Name_ES ='Triturador', prcm_FullName_ES ='Triturador de papas' WHERE prcm_CommodityID=454
UPDATE PRCommodity SET prcm_Name_ES ='Procesamiento', prcm_FullName_ES ='Procesamiento de Papas' WHERE prcm_CommodityID=452
UPDATE PRCommodity SET prcm_Name_ES ='Rábano', prcm_FullName_ES ='Rábano' WHERE prcm_CommodityID=455
UPDATE PRCommodity SET prcm_Name_ES ='Raíz', prcm_FullName_ES ='Raíz' WHERE prcm_CommodityID=457
UPDATE PRCommodity SET prcm_Name_ES ='Calabaza', prcm_FullName_ES ='Raíz de calabaza' WHERE prcm_CommodityID=458
UPDATE PRCommodity SET prcm_Name_ES ='Galanga', prcm_FullName_ES ='Raíz de Galanga' WHERE prcm_CommodityID=459
UPDATE PRCommodity SET prcm_Name_ES ='Gobo', prcm_FullName_ES ='Raíz de Gobo' WHERE prcm_CommodityID=460
UPDATE PRCommodity SET prcm_Name_ES ='Lis', prcm_FullName_ES ='Raíz de Lis' WHERE prcm_CommodityID=461
UPDATE PRCommodity SET prcm_Name_ES ='Nabo Sueco', prcm_FullName_ES ='Nabo Sueco' WHERE prcm_CommodityID=462
UPDATE PRCommodity SET prcm_Name_ES ='Patatas de Siembra', prcm_FullName_ES ='Patatas de Siembra' WHERE prcm_CommodityID=463
UPDATE PRCommodity SET prcm_Name_ES ='Tupinambo', prcm_FullName_ES ='Tupinambo' WHERE prcm_CommodityID=464
UPDATE PRCommodity SET prcm_Name_ES ='Camote', prcm_FullName_ES ='Camote' WHERE prcm_CommodityID=465
UPDATE PRCommodity SET prcm_Name_ES ='Okinawa', prcm_FullName_ES ='Camote de Okinawa' WHERE prcm_CommodityID=572
UPDATE PRCommodity SET prcm_Name_ES ='Raíz de Taro', prcm_FullName_ES ='Raíz de Taro' WHERE prcm_CommodityID=466
UPDATE PRCommodity SET prcm_Name_ES ='Cúrcuma', prcm_FullName_ES ='Cúrcuma' WHERE prcm_CommodityID=1510
UPDATE PRCommodity SET prcm_Name_ES ='Nabo', prcm_FullName_ES ='Nabo' WHERE prcm_CommodityID=467
UPDATE PRCommodity SET prcm_Name_ES ='Castaña de Agua', prcm_FullName_ES ='Castaña de Agua' WHERE prcm_CommodityID=468
UPDATE PRCommodity SET prcm_Name_ES ='Batata', prcm_FullName_ES ='Batata' WHERE prcm_CommodityID=469
UPDATE PRCommodity SET prcm_Name_ES ='Yampi', prcm_FullName_ES ='Batata Yampi' WHERE prcm_CommodityID=470
UPDATE PRCommodity SET prcm_Name_ES ='Amarillo', prcm_FullName_ES ='Batata Amarilla' WHERE prcm_CommodityID=471
UPDATE PRCommodity SET prcm_Name_ES ='Raíz de Yuca', prcm_FullName_ES ='Raíz de Yuca' WHERE prcm_CommodityID=472
UPDATE PRCommodity SET prcm_Name_ES ='Germinado', prcm_FullName_ES ='Germinado' WHERE prcm_CommodityID=531
UPDATE PRCommodity SET prcm_Name_ES ='Alfalfa', prcm_FullName_ES ='Germinado de Alfalfa' WHERE prcm_CommodityID=532
UPDATE PRCommodity SET prcm_Name_ES ='Brócoli', prcm_FullName_ES ='Germinado de Brócoli' WHERE prcm_CommodityID=533
UPDATE PRCommodity SET prcm_Name_ES ='Pasto de Trigo', prcm_FullName_ES ='Germinado de pasto de Trigo' WHERE prcm_CommodityID=534
UPDATE PRCommodity SET prcm_Name_ES ='Especialidad de Vegetal', prcm_FullName_ES ='Especialidad de Vegetal' WHERE prcm_CommodityID=550
UPDATE PRCommodity SET prcm_Name_ES ='Vegetales en Tallo', prcm_FullName_ES ='Vegetales en Tallo' WHERE prcm_CommodityID=473
UPDATE PRCommodity SET prcm_Name_ES ='Espárrago', prcm_FullName_ES ='Espárrago' WHERE prcm_CommodityID=474
UPDATE PRCommodity SET prcm_Name_ES ='Raíz', prcm_FullName_ES ='Raíz de Espárrago' WHERE prcm_CommodityID=555
UPDATE PRCommodity SET prcm_Name_ES ='Germinado de Bruselas', prcm_FullName_ES ='Germinado de Bruselas' WHERE prcm_CommodityID=475
UPDATE PRCommodity SET prcm_Name_ES ='Cardo', prcm_FullName_ES ='Cardo' WHERE prcm_CommodityID=476
UPDATE PRCommodity SET prcm_Name_ES ='Apio', prcm_FullName_ES ='Apio' WHERE prcm_CommodityID=477
UPDATE PRCommodity SET prcm_Name_ES ='Repollo', prcm_FullName_ES ='Apio y Repollo' WHERE prcm_CommodityID=478
UPDATE PRCommodity SET prcm_Name_ES ='Corazón', prcm_FullName_ES ='Corazón de Apio' WHERE prcm_CommodityID=479
UPDATE PRCommodity SET prcm_Name_ES ='Ruibarbo', prcm_FullName_ES ='Ruibarbo' WHERE prcm_CommodityID=480
UPDATE PRCommodity SET prcm_Name_ES ='Tomate', prcm_FullName_ES ='Tomate' WHERE prcm_CommodityID=535
UPDATE PRCommodity SET prcm_Name_ES ='Cereza', prcm_FullName_ES ='Tomate Cereza' WHERE prcm_CommodityID=541
UPDATE PRCommodity SET prcm_Name_ES ='Corazón de Buey', prcm_FullName_ES ='Tomate Corazón de Buey' WHERE prcm_CommodityID=1503
UPDATE PRCommodity SET prcm_Name_ES ='Racimo', prcm_FullName_ES ='Tomate en Racimo' WHERE prcm_CommodityID=1504
UPDATE PRCommodity SET prcm_Name_ES ='Uva', prcm_FullName_ES ='Tomate Uva' WHERE prcm_CommodityID=540
UPDATE PRCommodity SET prcm_Name_ES ='Heirloom', prcm_FullName_ES ='Tomate Heirloom' WHERE prcm_CommodityID=1501
UPDATE PRCommodity SET prcm_Name_ES ='Ciruela', prcm_FullName_ES ='Tomate Ciruela' WHERE prcm_CommodityID=539
UPDATE PRCommodity SET prcm_Name_ES ='Roma', prcm_FullName_ES ='Tomate Roma' WHERE prcm_CommodityID=536
UPDATE PRCommodity SET prcm_Name_ES ='Lágrima', prcm_FullName_ES ='Tomate Lágrima' WHERE prcm_CommodityID=538
UPDATE PRCommodity SET prcm_Name_ES ='Tomatillo', prcm_FullName_ES ='Tomatillo' WHERE prcm_CommodityID=543
UPDATE PRCommodity SET prcm_Name_ES ='Amarillo', prcm_FullName_ES ='Tomate Amarillo' WHERE prcm_CommodityID=537
UPDATE PRCommodity SET prcm_Name_ES ='Vegetales Tropicales', prcm_FullName_ES ='Vegetales Tropicales' WHERE prcm_CommodityID=481
UPDATE PRCommodity SET prcm_Name_ES ='Palmito', prcm_FullName_ES ='Palmito' WHERE prcm_CommodityID=482
UPDATE PRCommodity SET prcm_Name_ES ='Tubérculo', prcm_FullName_ES ='Tubérculo' WHERE prcm_CommodityID=579


UPDATE PRCountry SET prcn_Country_ES ='Argelia' WHERE prcn_CountryID=107
UPDATE PRCountry SET prcn_Country_ES ='Samoa Americana' WHERE prcn_CountryID=88
UPDATE PRCountry SET prcn_Country_ES ='Antigua y Barbados' WHERE prcn_CountryID=5
UPDATE PRCountry SET prcn_Country_ES ='Argentina' WHERE prcn_CountryID=6
UPDATE PRCountry SET prcn_Country_ES ='Aruba' WHERE prcn_CountryID=7
UPDATE PRCountry SET prcn_Country_ES ='Australia' WHERE prcn_CountryID=8
UPDATE PRCountry SET prcn_Country_ES ='Austria' WHERE prcn_CountryID=9
UPDATE PRCountry SET prcn_Country_ES ='Bahamas' WHERE prcn_CountryID=10
UPDATE PRCountry SET prcn_Country_ES ='Bahrein, Reino de' WHERE prcn_CountryID=104
UPDATE PRCountry SET prcn_Country_ES ='Bangladesh' WHERE prcn_CountryID=92
UPDATE PRCountry SET prcn_Country_ES ='Barbados' WHERE prcn_CountryID=11
UPDATE PRCountry SET prcn_Country_ES ='Bélgica' WHERE prcn_CountryID=12
UPDATE PRCountry SET prcn_Country_ES ='Belice' WHERE prcn_CountryID=13
UPDATE PRCountry SET prcn_Country_ES ='Bermuda' WHERE prcn_CountryID=14
UPDATE PRCountry SET prcn_Country_ES ='Bolivia' WHERE prcn_CountryID=15
UPDATE PRCountry SET prcn_Country_ES ='Brasil' WHERE prcn_CountryID=16
UPDATE PRCountry SET prcn_Country_ES ='Islas Vírgenes Británicas' WHERE prcn_CountryID=103
UPDATE PRCountry SET prcn_Country_ES ='Camerún' WHERE prcn_CountryID=17
UPDATE PRCountry SET prcn_Country_ES ='Canadá' WHERE prcn_CountryID=2
UPDATE PRCountry SET prcn_Country_ES ='Islas Caimán' WHERE prcn_CountryID=18
UPDATE PRCountry SET prcn_Country_ES ='Chile' WHERE prcn_CountryID=19
UPDATE PRCountry SET prcn_Country_ES ='China' WHERE prcn_CountryID=20
UPDATE PRCountry SET prcn_Country_ES ='Colombia' WHERE prcn_CountryID=21
UPDATE PRCountry SET prcn_Country_ES ='Costa Rica' WHERE prcn_CountryID=22
UPDATE PRCountry SET prcn_Country_ES ='Croacia' WHERE prcn_CountryID=23
UPDATE PRCountry SET prcn_Country_ES ='Curacao' WHERE prcn_CountryID=59
UPDATE PRCountry SET prcn_Country_ES ='Chipre' WHERE prcn_CountryID=24
UPDATE PRCountry SET prcn_Country_ES ='República Checa' WHERE prcn_CountryID=25
UPDATE PRCountry SET prcn_Country_ES ='Dinamarca' WHERE prcn_CountryID=26
UPDATE PRCountry SET prcn_Country_ES ='Dominica' WHERE prcn_CountryID=27
UPDATE PRCountry SET prcn_Country_ES ='República Dominicana' WHERE prcn_CountryID=28
UPDATE PRCountry SET prcn_Country_ES ='Ecuador' WHERE prcn_CountryID=29
UPDATE PRCountry SET prcn_Country_ES ='Egipto' WHERE prcn_CountryID=30
UPDATE PRCountry SET prcn_Country_ES ='El Salvador' WHERE prcn_CountryID=31
UPDATE PRCountry SET prcn_Country_ES ='Inglaterra' WHERE prcn_CountryID=32
UPDATE PRCountry SET prcn_Country_ES ='Estonia' WHERE prcn_CountryID=105
UPDATE PRCountry SET prcn_Country_ES ='Islas Fiji, República de' WHERE prcn_CountryID=33
UPDATE PRCountry SET prcn_Country_ES ='Finlandia' WHERE prcn_CountryID=34
UPDATE PRCountry SET prcn_Country_ES ='Francia' WHERE prcn_CountryID=35
UPDATE PRCountry SET prcn_Country_ES ='Alemania' WHERE prcn_CountryID=36
UPDATE PRCountry SET prcn_Country_ES ='Ghana' WHERE prcn_CountryID=96
UPDATE PRCountry SET prcn_Country_ES ='Grecia' WHERE prcn_CountryID=37
UPDATE PRCountry SET prcn_Country_ES ='Guatemala' WHERE prcn_CountryID=39
UPDATE PRCountry SET prcn_Country_ES ='Guyana' WHERE prcn_CountryID=40
UPDATE PRCountry SET prcn_Country_ES ='Haití' WHERE prcn_CountryID=41
UPDATE PRCountry SET prcn_Country_ES ='Honduras' WHERE prcn_CountryID=42
UPDATE PRCountry SET prcn_Country_ES ='Hong Kong' WHERE prcn_CountryID=43
UPDATE PRCountry SET prcn_Country_ES ='Hungría' WHERE prcn_CountryID=44
UPDATE PRCountry SET prcn_Country_ES ='Islandia' WHERE prcn_CountryID=45
UPDATE PRCountry SET prcn_Country_ES ='India' WHERE prcn_CountryID=46
UPDATE PRCountry SET prcn_Country_ES ='Indonesia' WHERE prcn_CountryID=47
UPDATE PRCountry SET prcn_Country_ES ='Irlanda' WHERE prcn_CountryID=48
UPDATE PRCountry SET prcn_Country_ES ='Israel' WHERE prcn_CountryID=49
UPDATE PRCountry SET prcn_Country_ES ='Italia' WHERE prcn_CountryID=50
UPDATE PRCountry SET prcn_Country_ES ='Jamaica' WHERE prcn_CountryID=51
UPDATE PRCountry SET prcn_Country_ES ='Japón' WHERE prcn_CountryID=52
UPDATE PRCountry SET prcn_Country_ES ='Jordania' WHERE prcn_CountryID=90
UPDATE PRCountry SET prcn_Country_ES ='Kenia' WHERE prcn_CountryID=95
UPDATE PRCountry SET prcn_Country_ES ='Corea, República de' WHERE prcn_CountryID=53
UPDATE PRCountry SET prcn_Country_ES ='Kuwait' WHERE prcn_CountryID=54
UPDATE PRCountry SET prcn_Country_ES ='Letonia' WHERE prcn_CountryID=99
UPDATE PRCountry SET prcn_Country_ES ='Macedonia, República de' WHERE prcn_CountryID=101
UPDATE PRCountry SET prcn_Country_ES ='Madagascar, República de' WHERE prcn_CountryID=108
UPDATE PRCountry SET prcn_Country_ES ='Malasia' WHERE prcn_CountryID=55
UPDATE PRCountry SET prcn_Country_ES ='Mauricio' WHERE prcn_CountryID=91
UPDATE PRCountry SET prcn_Country_ES ='México' WHERE prcn_CountryID=3
UPDATE PRCountry SET prcn_Country_ES ='Mónaco' WHERE prcn_CountryID=56
UPDATE PRCountry SET prcn_Country_ES ='Marruecos' WHERE prcn_CountryID=57
UPDATE PRCountry SET prcn_Country_ES ='Holanda' WHERE prcn_CountryID=58
UPDATE PRCountry SET prcn_Country_ES ='Nueva Zelanda' WHERE prcn_CountryID=60
UPDATE PRCountry SET prcn_Country_ES ='Nicaragua' WHERE prcn_CountryID=61
UPDATE PRCountry SET prcn_Country_ES ='Nigeria, República federal de' WHERE prcn_CountryID=62
UPDATE PRCountry SET prcn_Country_ES ='Irlanda del Norte' WHERE prcn_CountryID=63
UPDATE PRCountry SET prcn_Country_ES ='Noruega' WHERE prcn_CountryID=64
UPDATE PRCountry SET prcn_Country_ES ='Pakistán' WHERE prcn_CountryID=65
UPDATE PRCountry SET prcn_Country_ES ='Panamá' WHERE prcn_CountryID=66
UPDATE PRCountry SET prcn_Country_ES ='Perú' WHERE prcn_CountryID=67
UPDATE PRCountry SET prcn_Country_ES ='Filipinas' WHERE prcn_CountryID=68
UPDATE PRCountry SET prcn_Country_ES ='Polonia' WHERE prcn_CountryID=69
UPDATE PRCountry SET prcn_Country_ES ='Portugal' WHERE prcn_CountryID=70
UPDATE PRCountry SET prcn_Country_ES ='Rumania' WHERE prcn_CountryID=93
UPDATE PRCountry SET prcn_Country_ES ='Rusia' WHERE prcn_CountryID=71
UPDATE PRCountry SET prcn_Country_ES ='Arabia Saudita, Reino de' WHERE prcn_CountryID=97
UPDATE PRCountry SET prcn_Country_ES ='Escocia' WHERE prcn_CountryID=89
UPDATE PRCountry SET prcn_Country_ES ='Senegal' WHERE prcn_CountryID=100
UPDATE PRCountry SET prcn_Country_ES ='Singapur, República de' WHERE prcn_CountryID=72
UPDATE PRCountry SET prcn_Country_ES ='Sudáfrica, República de' WHERE prcn_CountryID=73
UPDATE PRCountry SET prcn_Country_ES ='España' WHERE prcn_CountryID=74
UPDATE PRCountry SET prcn_Country_ES ='Santa Lucía' WHERE prcn_CountryID=75
UPDATE PRCountry SET prcn_Country_ES ='Suecia' WHERE prcn_CountryID=76
UPDATE PRCountry SET prcn_Country_ES ='Suiza' WHERE prcn_CountryID=77
UPDATE PRCountry SET prcn_Country_ES ='Taiwán' WHERE prcn_CountryID=78
UPDATE PRCountry SET prcn_Country_ES ='Tanzania' WHERE prcn_CountryID=102
UPDATE PRCountry SET prcn_Country_ES ='Tailandia' WHERE prcn_CountryID=79
UPDATE PRCountry SET prcn_Country_ES ='Trinidad y Tobago' WHERE prcn_CountryID=80
UPDATE PRCountry SET prcn_Country_ES ='Turquía' WHERE prcn_CountryID=81
UPDATE PRCountry SET prcn_Country_ES ='Ucraina' WHERE prcn_CountryID=106
UPDATE PRCountry SET prcn_Country_ES ='Emiratos Árabes Unidos' WHERE prcn_CountryID=82
UPDATE PRCountry SET prcn_Country_ES ='Uruguay' WHERE prcn_CountryID=83
UPDATE PRCountry SET prcn_Country_ES ='Estados Unidos de América' WHERE prcn_CountryID=1
UPDATE PRCountry SET prcn_Country_ES ='Venezuela' WHERE prcn_CountryID=84
UPDATE PRCountry SET prcn_Country_ES ='Vietnam' WHERE prcn_CountryID=85
UPDATE PRCountry SET prcn_Country_ES ='Gales' WHERE prcn_CountryID=98
UPDATE PRCountry SET prcn_Country_ES ='Zambia' WHERE prcn_CountryID=87



UPDATE PRState SET prst_State_ES ='Alberta' WHERE prst_StateID=52
UPDATE PRState SET prst_State_ES ='Columbia Británica' WHERE prst_StateID=53
UPDATE PRState SET prst_State_ES ='Manitoba' WHERE prst_StateID=54
UPDATE PRState SET prst_State_ES ='Nuevo Brunswick' WHERE prst_StateID=55
UPDATE PRState SET prst_State_ES ='Terranova y Labrador' WHERE prst_StateID=56
UPDATE PRState SET prst_State_ES ='Territorios del Noroeste' WHERE prst_StateID=57
UPDATE PRState SET prst_State_ES ='Nueva Escocia' WHERE prst_StateID=58
UPDATE PRState SET prst_State_ES ='Ontario' WHERE prst_StateID=59
UPDATE PRState SET prst_State_ES ='Isla del Príncipe Eduardo' WHERE prst_StateID=60
UPDATE PRState SET prst_State_ES ='Quebec' WHERE prst_StateID=61
UPDATE PRState SET prst_State_ES ='Saskatchewan' WHERE prst_StateID=62
UPDATE PRState SET prst_State_ES ='Yukón' WHERE prst_StateID=63
UPDATE PRState SET prst_State_ES ='Suffolk' WHERE prst_StateID=180
UPDATE PRState SET prst_State_ES ='Aguascalientes' WHERE prst_StateID=64
UPDATE PRState SET prst_State_ES ='Baja California' WHERE prst_StateID=65
UPDATE PRState SET prst_State_ES ='Baja California Sur' WHERE prst_StateID=66
UPDATE PRState SET prst_State_ES ='Campeche' WHERE prst_StateID=67
UPDATE PRState SET prst_State_ES ='Chiapas' WHERE prst_StateID=68
UPDATE PRState SET prst_State_ES ='Chihuahua' WHERE prst_StateID=69
UPDATE PRState SET prst_State_ES ='Coahuila' WHERE prst_StateID=70
UPDATE PRState SET prst_State_ES ='Colima' WHERE prst_StateID=71
UPDATE PRState SET prst_State_ES ='Durango' WHERE prst_StateID=72
UPDATE PRState SET prst_State_ES ='Estado de México' WHERE prst_StateID=73
UPDATE PRState SET prst_State_ES ='Distrito Federal' WHERE prst_StateID=74
UPDATE PRState SET prst_State_ES ='Guanajuato' WHERE prst_StateID=75
UPDATE PRState SET prst_State_ES ='Guerrero' WHERE prst_StateID=76
UPDATE PRState SET prst_State_ES ='Jalisco' WHERE prst_StateID=78
UPDATE PRState SET prst_State_ES ='Michoacán' WHERE prst_StateID=79
UPDATE PRState SET prst_State_ES ='Morelos' WHERE prst_StateID=80
UPDATE PRState SET prst_State_ES ='Nayarit' WHERE prst_StateID=81
UPDATE PRState SET prst_State_ES ='Nuevo León' WHERE prst_StateID=82
UPDATE PRState SET prst_State_ES ='Oaxaca' WHERE prst_StateID=83
UPDATE PRState SET prst_State_ES ='Puebla' WHERE prst_StateID=84
UPDATE PRState SET prst_State_ES ='Queretaro' WHERE prst_StateID=85
UPDATE PRState SET prst_State_ES ='Quintana Roo' WHERE prst_StateID=86
UPDATE PRState SET prst_State_ES ='San Luis Potosí' WHERE prst_StateID=87
UPDATE PRState SET prst_State_ES ='Sinaloa' WHERE prst_StateID=88
UPDATE PRState SET prst_State_ES ='Sonora' WHERE prst_StateID=89
UPDATE PRState SET prst_State_ES ='Tabasco' WHERE prst_StateID=90
UPDATE PRState SET prst_State_ES ='Tamaulipas' WHERE prst_StateID=91
UPDATE PRState SET prst_State_ES ='Veracruz' WHERE prst_StateID=93
UPDATE PRState SET prst_State_ES ='Yucatán' WHERE prst_StateID=94
UPDATE PRState SET prst_State_ES ='Zacatecas' WHERE prst_StateID=95
UPDATE PRState SET prst_State_ES ='Alabama' WHERE prst_StateID=1
UPDATE PRState SET prst_State_ES ='Alaska' WHERE prst_StateID=2
UPDATE PRState SET prst_State_ES ='Arizona' WHERE prst_StateID=3
UPDATE PRState SET prst_State_ES ='Arkansas' WHERE prst_StateID=4
UPDATE PRState SET prst_State_ES ='California' WHERE prst_StateID=5
UPDATE PRState SET prst_State_ES ='Colorado' WHERE prst_StateID=6
UPDATE PRState SET prst_State_ES ='Connecticut' WHERE prst_StateID=7
UPDATE PRState SET prst_State_ES ='Delaware' WHERE prst_StateID=8
UPDATE PRState SET prst_State_ES ='Distrito de Columbia' WHERE prst_StateID=9
UPDATE PRState SET prst_State_ES ='Florida' WHERE prst_StateID=10
UPDATE PRState SET prst_State_ES ='Georgia' WHERE prst_StateID=11
UPDATE PRState SET prst_State_ES ='Guam' WHERE prst_StateID=1016
UPDATE PRState SET prst_State_ES ='Hawai' WHERE prst_StateID=12
UPDATE PRState SET prst_State_ES ='Idaho' WHERE prst_StateID=13
UPDATE PRState SET prst_State_ES ='Illinois' WHERE prst_StateID=14
UPDATE PRState SET prst_State_ES ='Indiana' WHERE prst_StateID=15
UPDATE PRState SET prst_State_ES ='Iowa' WHERE prst_StateID=16
UPDATE PRState SET prst_State_ES ='Kansas' WHERE prst_StateID=17
UPDATE PRState SET prst_State_ES ='Kentucky' WHERE prst_StateID=18
UPDATE PRState SET prst_State_ES ='Louisiana' WHERE prst_StateID=19
UPDATE PRState SET prst_State_ES ='Maine' WHERE prst_StateID=20
UPDATE PRState SET prst_State_ES ='Maryland' WHERE prst_StateID=21
UPDATE PRState SET prst_State_ES ='Massachusetts' WHERE prst_StateID=22
UPDATE PRState SET prst_State_ES ='Michigan' WHERE prst_StateID=23
UPDATE PRState SET prst_State_ES ='Minnesota' WHERE prst_StateID=24
UPDATE PRState SET prst_State_ES ='Mississippi' WHERE prst_StateID=25
UPDATE PRState SET prst_State_ES ='Missouri' WHERE prst_StateID=26
UPDATE PRState SET prst_State_ES ='Montana' WHERE prst_StateID=27
UPDATE PRState SET prst_State_ES ='Nebraska' WHERE prst_StateID=28
UPDATE PRState SET prst_State_ES ='Nevada' WHERE prst_StateID=29
UPDATE PRState SET prst_State_ES ='New Hampshire' WHERE prst_StateID=30
UPDATE PRState SET prst_State_ES ='New Jersey' WHERE prst_StateID=31
UPDATE PRState SET prst_State_ES ='New Mexico' WHERE prst_StateID=32
UPDATE PRState SET prst_State_ES ='New York' WHERE prst_StateID=33
UPDATE PRState SET prst_State_ES ='North Carolina' WHERE prst_StateID=34
UPDATE PRState SET prst_State_ES ='North Dakota' WHERE prst_StateID=35
UPDATE PRState SET prst_State_ES ='Ohio' WHERE prst_StateID=36
UPDATE PRState SET prst_State_ES ='Oklahoma' WHERE prst_StateID=37
UPDATE PRState SET prst_State_ES ='Oregon' WHERE prst_StateID=38
UPDATE PRState SET prst_State_ES ='Pennsylvania' WHERE prst_StateID=39
UPDATE PRState SET prst_State_ES ='Puerto Rico' WHERE prst_StateID=1015
UPDATE PRState SET prst_State_ES ='Rhode Island' WHERE prst_StateID=40
UPDATE PRState SET prst_State_ES ='South Carolina' WHERE prst_StateID=41
UPDATE PRState SET prst_State_ES ='South Dakota' WHERE prst_StateID=42
UPDATE PRState SET prst_State_ES ='Tennessee' WHERE prst_StateID=43
UPDATE PRState SET prst_State_ES ='Texas' WHERE prst_StateID=44
UPDATE PRState SET prst_State_ES ='Utah' WHERE prst_StateID=45
UPDATE PRState SET prst_State_ES ='Vermont' WHERE prst_StateID=46
UPDATE PRState SET prst_State_ES ='Islas Vírgenes' WHERE prst_StateID=1017
UPDATE PRState SET prst_State_ES ='Virginia' WHERE prst_StateID=47
UPDATE PRState SET prst_State_ES ='Washington' WHERE prst_StateID=48
UPDATE PRState SET prst_State_ES ='West Virginia' WHERE prst_StateID=49
UPDATE PRState SET prst_State_ES ='Wisconsin' WHERE prst_StateID=50
UPDATE PRState SET prst_State_ES ='Wyoming' WHERE prst_StateID=51
Go


DECLARE @AdEligiblePageID int = 6047
DELETE FROM PRAdEligiblePage WHERE pradep_AdEligiblePageID = @AdEligiblePageID
INSERT INTO PRAdEligiblePage
(pradep_AdEligiblePageID,pradep_AdCampaignType,pradep_DisplayName,pradep_PageName,pradep_MaxAdCount,pradep_MinAdCount,pradep_MaxImageHeight,pradep_MaxImageWidth,pradep_CreatedBy,pradep_CreatedDate,pradep_UpdatedBy,pradep_UpdatedDate,pradep_TimeStamp)
VALUES (@AdEligiblePageID,'CSG','Chain Store Guide','CompanyDetailsCSG.aspx',1,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());
EXEC usp_UpdateSQLIdentity 'PRAdEligiblePage', 'pradep_AdEligiblePageID'
Go



--
--  Add a few new commodities
--
INSERT INTO PRCommodity (prcm_CommodityID, prcm_Name, prcm_CommodityCode, prcm_RootParentID, prcm_ParentID, prcm_Level, prcm_PathNames, prcm_PathCodes, prcm_ShortDescription, prcm_FullName, prcm_DisplayOrder, prcm_CreatedBy, prcm_CreatedDate, prcm_UpdatedBy, prcm_UpdatedDate, prcm_Timestamp)
    VALUES (1512, 'Bread Nut', 'Breadn', 37, 109, 3, 'Fruit,Tree Fruit,Bread Nut', 'F,Treef,Breadn', 'Bread Nut', 'Bread Nut', 1265, 3, GETDATE(), 3, GETDATE(), GETDATE());

INSERT INTO PRCommodity (prcm_CommodityID, prcm_Name, prcm_CommodityCode, prcm_RootParentID, prcm_ParentID, prcm_Level, prcm_PathNames, prcm_PathCodes, prcm_ShortDescription, prcm_FullName, prcm_DisplayOrder, prcm_PublicationArticleID, prcm_CreatedBy, prcm_CreatedDate, prcm_UpdatedBy, prcm_UpdatedDate, prcm_Timestamp)
    VALUES (1513, 'Ash', 'Ash', 37, 118, 5, 'Fruit,Tree Fruit,Banana,Plantain,Ash', 'F,Treef,Ban,Plantain,Ash', 'Ash', 'Ash Plantain Banana', 1235, 6088, 3, GETDATE(), 3, GETDATE(), GETDATE());

INSERT INTO PRCommodity (prcm_CommodityID, prcm_Name, prcm_CommodityCode, prcm_RootParentID, prcm_ParentID, prcm_Level, prcm_PathNames, prcm_PathCodes, prcm_ShortDescription, prcm_FullName, prcm_DisplayOrder, prcm_PublicationArticleID, prcm_CreatedBy, prcm_CreatedDate, prcm_UpdatedBy, prcm_UpdatedDate, prcm_Timestamp)
    VALUES (1514, 'Mocha', 'Mocha', 37, 118, 5, 'Fruit,Tree Fruit,Banana,Plantain,Mocha', 'F,Treef,Ban,Plantain,Mocha', 'Mocha', 'Mocha Plantain Banana', 1245, 6088, 3, GETDATE(), 3, GETDATE(), GETDATE());

INSERT INTO PRCommodity (prcm_CommodityID, prcm_Name, prcm_CommodityCode, prcm_RootParentID, prcm_ParentID, prcm_Level, prcm_PathNames, prcm_PathCodes, prcm_ShortDescription, prcm_FullName, prcm_DisplayOrder, prcm_CreatedBy, prcm_CreatedDate, prcm_UpdatedBy, prcm_UpdatedDate, prcm_Timestamp)
    VALUES (1515, 'Dosakai', 'Dosakai', 291, 491, 5, 'Vegetable,,Cucumber,,Dosakai', 'V,,Ck,,Dosakai', 'Dosakai', 'Dosakai Cucumber', 2635, 3, GETDATE(), 3, GETDATE(), GETDATE());

INSERT INTO PRCommodity (prcm_CommodityID, prcm_Name, prcm_CommodityCode, prcm_RootParentID, prcm_ParentID, prcm_Level, prcm_PathNames, prcm_PathCodes, prcm_ShortDescription, prcm_FullName, prcm_DisplayOrder, prcm_CreatedBy, prcm_CreatedDate, prcm_UpdatedBy, prcm_UpdatedDate, prcm_Timestamp)
    VALUES (1516, 'Parval', 'Parval', 291, 491, 5, 'Vegetable,,Cucumber,,Parval', 'V,,Ck,,Parval', 'Parval', 'Parval Cucumber', 2665, 3, GETDATE(), 3, GETDATE(), GETDATE());

INSERT INTO PRCommodity (prcm_CommodityID, prcm_Name, prcm_CommodityCode, prcm_RootParentID, prcm_ParentID, prcm_Level, prcm_PathNames, prcm_PathCodes, prcm_ShortDescription, prcm_FullName, prcm_DisplayOrder, prcm_CreatedBy, prcm_CreatedDate, prcm_UpdatedBy, prcm_UpdatedDate, prcm_Timestamp)
    VALUES (1517, 'Snake Gourd', 'Snakegourd', 291, 491, 5, 'Vegetable,,Cucumber,,Snake Gourd', 'V,,Ck,,Snakegourd', 'Snake Gourd', 'Snake Gourd Cucumber', 2665, 3, GETDATE(), 3, GETDATE(), GETDATE());

INSERT INTO PRCommodity (prcm_CommodityID, prcm_Name, prcm_CommodityCode, prcm_RootParentID, prcm_ParentID, prcm_Level, prcm_PathNames, prcm_PathCodes, prcm_ShortDescription, prcm_FullName, prcm_DisplayOrder, prcm_CreatedBy, prcm_CreatedDate, prcm_UpdatedBy, prcm_UpdatedDate, prcm_Timestamp)
    VALUES (1518, 'Kantola ', 'Kantola', 291, 338, 5, 'Vegetable,,Gourd,,Kantola', 'V,,Gourds,,Kantola', 'Kantola', 'Kantola', 2805, 3, GETDATE(), 3, GETDATE(), GETDATE());

INSERT INTO PRCommodity (prcm_CommodityID, prcm_Name, prcm_CommodityCode, prcm_RootParentID, prcm_ParentID, prcm_Level, prcm_PathNames, prcm_PathCodes, prcm_ShortDescription, prcm_FullName, prcm_DisplayOrder, prcm_CreatedBy, prcm_CreatedDate, prcm_UpdatedBy, prcm_UpdatedDate, prcm_Timestamp)
    VALUES (1519, 'Pigeon ', 'Pigeon', 291, 427, 5, 'Vegetable,Legume,Pea,,Pigeon', 'V,Legume,Pe,,Pigeon', 'Pigeon', 'Pigeon Pea', 3845, 3, GETDATE(), 3, GETDATE(), GETDATE());

INSERT INTO PRCommodity (prcm_CommodityID, prcm_Name, prcm_CommodityCode, prcm_RootParentID, prcm_ParentID, prcm_Level, prcm_PathNames, prcm_PathCodes, prcm_ShortDescription, prcm_FullName, prcm_DisplayOrder, prcm_CreatedBy, prcm_CreatedDate, prcm_UpdatedBy, prcm_UpdatedDate, prcm_Timestamp)
    VALUES (1520, 'Valor ', 'Valor', 291, 404, 5, 'Vegetable,Legume,Bean,,Valor', 'V,Legume,Bn,,Valor', 'Valor', 'Valor Bean', 3775, 3, GETDATE(), 3, GETDATE(), GETDATE());

INSERT INTO PRCommodity (prcm_CommodityID, prcm_Name, prcm_CommodityCode, prcm_RootParentID, prcm_ParentID, prcm_Level, prcm_PathNames, prcm_PathCodes, prcm_ShortDescription, prcm_FullName, prcm_DisplayOrder, prcm_CreatedBy, prcm_CreatedDate, prcm_UpdatedBy, prcm_UpdatedDate, prcm_Timestamp)
    VALUES (1521, 'Bread Nut Seeds', 'Breadnseeds', 16, 16, 3,'Food (non-produce),,Bread Nut Seeds', 'Otherfood,,Breadnseeds', 'Bread Nut Seeds', 'Bread Nut Seeds', 175, 3, GETDATE(), 3, GETDATE(), GETDATE());

EXEC usp_PopulatePRCommodityTranslation
Go

--DEFECT #4426 - Kathi - we would like the data correction to change everyone to "INCLUDE" local source, as the default. Per MDE.
UPDATE PRWebUser SET prwu_LocalSourceSearch='ILS'
Go


--- NEW RECORDS FOR ITA BR Purchases by credit card
INSERT INTO ProductFamily (PrFa_ProductFamilyID, PrFa_CreatedBy, PrFA_CreatedDate, PrFa_UpdatedBy, PrFa_UpdatedDate, PrFa_TimeStamp, prfa_name, prfa_Description, prfa_active)
VALUES (16, -100, GETDATE(), 6, GETDATE(), GETDATE(), 'ITA BR', 'ITA Business Reports', 'Y')
INSERT INTO NewProduct (Prod_ProductID, Prod_CreatedBy, Prod_CreatedDate, Prod_Updatedby, Prod_UpdatedDate, Prod_TimeStamp, prod_Active, prod_UOMCategory, prod_name, prod_code, prod_productfamilyid, prod_PRSequence, prod_PRDescription, prod_PRNameES, prod_PRDescriptionES, prod_PRServiceUnits, prod_IndustryTypeCode, prod_PurchaseInBBOS, prod_Name_ES, prod_PRDescription_ES) 
VALUES (94, -100, GETDATE(), -100, GETDATE(), GETDATE(), 'Y', 6000, 'Business Report', 'BR4', 16, 1,'<div style="font-weight:bold">Blue Book Business Report including Experian Credit Information</div><p style="margin-top:0em">Creditors such as sellers, transporters and suppliers use this report type for performing a high-level account evaluation, where there is typically a specific interest in current and trend facts such as pay and trade experiences. Tabular and graphic presentation of the company''s rating information makes it quick & easy to make informed decisions.</p><p>The Business Report includes:  ownership, basic company contact information such as Blue Book ID#, company name, listing location, addresses, phones, faxes, e-mails, web URLs, and alternate trade names. Also included - if available/applicable - are current headquarter rating & rating definition, headquarter rating trend, Trading Member year, recent company developments, bankruptcy events, business background, people background, business profile, financial information, year-to-date trade report summary, previous two calendar years of trade reports, trade report details for the past 18 months, the current Blue Book Score, recent Blue Book Score history, affiliated businesses, and branch locations. Select credit information such as public record information, trade payment/legal filings, and business facts provided by <span style="font-weight:bold">Experian</span>, will be included with your Business Report, as available/applicable. When used in conjunction with Blue Book data, information provided by <span style="font-weight:bold">Experian</span> can help provide a comprehensive financial picture of a company as a whole, including financial activities outside of the produce industry.</p>', 'Business Report Plus (es)', '<div style="font-weight:bold">Blue Book Business Report including Experian Credit Information</div><p style="margin-top:0em">Creditors such as sellers, transporters and suppliers use this report type for performing a high-level account evaluation, where there is typically a specific interest in current and trend facts such as pay and trade experiences. Tabular and graphic presentation of the company''s rating information makes it quick & easy to make informed decisions.</p><p>The Business Report includes:  ownership, basic company contact information such as Blue Book ID#, company name, listing location, addresses, phones, faxes, e-mails, web URLs, and alternate trade names. Also included - if available/applicable - are current headquarter rating & rating definition, headquarter rating trend, Trading Member year, recent company developments, bankruptcy events, business background, people background, business profile, financial information, year-to-date trade report summary, previous two calendar years of trade reports, trade report details for the past 18 months, the current Blue Book Score, recent Blue Book Score history, affiliated businesses, and branch locations. Select credit information such as public record information, trade payment/legal filings, and business facts provided by <span style="font-weight:bold">Experian</span>, will be included with your Business Report, as available/applicable. When used in conjunction with Blue Book data, information provided by <span style="font-weight:bold">Experian</span> can help provide a comprehensive financial picture of a company as a whole, including financial activities outside of the produce industry.</p>', 0, ',P,', 'Y','Informe Comercial','<div style="font-weight:bold">Informe comercial de Blue Book que incluye la Información de crédito de Experian</div><p style="margin-top:0em">Los acreedores como los vendedores, transportistas y proveedores utilizan este tipo de informe para realizar una evaluación de cuentas de alto nivel, en las que generalmente existe un interés específico en los datos actuales y de tendencia como experiencias de pago y comerciales. La presentación tabular y gráfica de la información de clasificación de la compañía hace que sea fácil y rápido tomar decisiones informadas.</p><p>El Informe comercial incluye:  información de propiedad, información básica de contacto de la compañía como # de ID de Blue Book, nombre de la compañía, ubicación del perfil de empresa, direcciones, teléfonos, faxes, correos electrónicos, URL del sitio Web y nombres comerciales alternos. También se incluye, si está disponible/aplica, la calificación actual de la sede y la definicion, con la tendencia de la calificación, año de Miembro Comercial, desarrollos recientes de la compañía, eventos de bancarrota, antecedentes comerciales, antecedentes personales, Perfil de operaciones, información financiera, resumen de informe comercial a la fecha, informes comerciales de los ultimos 2 años, detalles del informe comercial durante los últimos 18 meses, el actual Puntaje de crédito del Blue Book, el historial Puntaje de crédito del Blue Book, negocios afiliados y ubicaciones de las sucursales. Seleccione la información de crédito como información de registro público, presentaciones legales/pago comercial y datos comerciales proporcionados por <span style="font-weight:bold">Experian</span>, se incluirán con su Informe comercial, según esté disponible/aplique. Cuando se utiliza junto con los datos de Blue Book, la información proporcionada por <span style="font-weight:bold">Experian</span> puede ayudarle a obtener una imagen integral financiera de una compañía como un todo, incluso las actividades financieras fuera de la industria de producción.</p>')
INSERT INTO Pricing (Pric_PricingID, Pric_CreatedBy, Pric_CreatedDate, Pric_UpdatedBy, Pric_UpdatedDate, Pric_TimeStamp, pric_Productid, pric_price, pric_price_CID, pric_PricingListID, pric_Active)
VALUES (79, -100, GETDATE(), -100, GETDATE(), GETDATE(), 94, 30.0, 16010, 16010, 'Y')