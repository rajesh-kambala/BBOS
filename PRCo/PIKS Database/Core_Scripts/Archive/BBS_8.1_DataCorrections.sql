--8.1 Release

INSERT INTO PRBBOSPrivilege(IndustryType, AccessLevel, Privilege, Role, Visible, Enabled) VALUES('P', 200, 'ViewMap', null, 0, 0)
INSERT INTO PRBBOSPrivilege(IndustryType, AccessLevel, Privilege, Role, Visible, Enabled) VALUES('S', 200, 'ViewMap', null, 0, 0)
INSERT INTO PRBBOSPrivilege(IndustryType, AccessLevel, Privilege, Role, Visible, Enabled) VALUES('T', 200, 'ViewMap', null, 0, 0)
INSERT INTO PRBBOSPrivilege(IndustryType, AccessLevel, Privilege, Role, Visible, Enabled) VALUES('L', 250, 'ViewMap', null, 0, 0)

GO

--Rebuild Listing cache for DRC records
DECLARE @Start datetime = GETDATE()
UPDATE PRListing
   SET prlst_Listing = dbo.ufn_GetListingFromCompany(prlst_CompanyID, 0, 0),
		prlst_UpdatedDate = @Start,
		prlst_UpdatedBy = 1
 WHERE prlst_CompanyID IN (   SELECT prdr_CompanyId
          FROM PRDRCLicense WITH(NOLOCK)
				 WHERE prdr_LicenseNumber is not null
				 )
Go				 

--PRRetailerOnlineOnly and Mexican Online Only data correction
UPDATE Company SET comp_PROnlineOnlyReasonCode = 'R' WHERE comp_PROnlineOnly = 'Y' and comp_PRRetailerOnlineOnly = 'Y'
	

--
--  KYC Digital Ad Conversion
--
DECLARE @MaxAdID int, @Start datetime = GETDATE()
SELECT @MaxAdID = MAX(pradc_AdCampaignID) FROM PRAdCampaign

INSERT INTO PRAdCampaign (pradc_AdCampaignID, pradc_CompanyID, pradc_HQID, pradc_Name, pradc_AdCampaignType, pradc_AdImageName, pradc_StartDate, pradc_EndDate, pradc_Cost, pradc_Discount, pradc_Notes, pradc_SoldBy, pradc_ApprovedByPersonID, pradc_CreativeStatus, pradc_Renewal, pradc_AdFileCreatedBy, pradc_SoldDate, pradc_AdCampaignCode, pradc_CreatedBy, pradc_CreatedDate, pradc_UpdatedBy, pradc_UpdatedDate, pradc_TimeStamp)
SELECT ROW_NUMBER() OVER (ORDER BY pradc_AdCampaignID) + @MaxAdID  as RowNum,
	   pradc_CompanyID,
	   pradc_HQID,
	   pradc_Name,
	   'KYCD',
	   pradc_AdImageName,
	   pradc_StartDate,
	   pradc_EndDate,
	   pradc_Cost,
	   pradc_Discount,
	   pradc_Notes,
	   pradc_SoldBy,
	   pradc_ApprovedByPersonID,
	   pradc_CreativeStatus,
	   pradc_Renewal,
	   pradc_AdFileCreatedBy,
	   pradc_SoldDate,
	   prcm_CommodityCode,
       1,
	   @Start,
	   1,
	   @Start,
	   @Start
  FROM PRAdCampaign 
	   LEFT OUTER JOIN (SELECT * FROM (
							SELECT  prcm_PublicationArticleID, prcm_CommodityId, prcm_Name, prcm_CommodityCode, 
									RANK() OVER (PARTITION BY prcm_PublicationArticleID ORDER BY prcm_Level) as Rnk
							FROM PRCommodity 
							WHERE prcm_PublicationArticleID IS NOT NULL
							  AND prcm_PublicationArticleID NOT IN (14695)
							) T1 WHERE Rnk=1) T2 ON pradc_PublicationArticleID = prcm_PublicationArticleID
		 WHERE pradc_AdCampaignType = 'PUB'
   AND GETDATE() BETWEEN pradc_StartDate AND ISNULL(pradc_EndDate, DATEADD(day, 1, GETDATE()))
   AND pradc_PublicationCode = 'KYC'
   AND prcm_CommodityCode IS NOT NULL
   

SELECT pradc_AdCampaignID, 
	   'xcopy "\\AZ-NC-SAGE-P1\Library\' + pradc_AdImageName + '" "\\AZ-NC-BBOS-Q1\Campaigns\' + CAST(pradc_CompanyID as varchar(10)) + '\" /i /y'
  FROM PRAdCampaign 
 WHERE pradc_AdCampaignType = 'KYCD'

UPDATE PRAdCampaign
  SET pradc_AdImageName = CAST(pradc_CompanyID as varchar(10)) + '\' + right(pradc_AdImageName, charindex('\', reverse(pradc_AdImageName) + '\') - 1)
WHERE pradc_AdCampaignType = 'KYCD'

UPDATE PRAdCampaign
   SET pradc_Sequence = Rnk
  FROM (SELECT pradc_AdCampaignID AdCampaignID,
	 	       pradc_AdCampaignCode AdCampaignCode,
		       RANK() OVER (PARTITION BY pradc_AdCampaignCode ORDER BY pradc_SoldDate) as Rnk
	      FROM PRAdCampaign 
	     WHERE pradc_AdCampaignType = 'KYCD') T1
WHERE pradc_AdCampaignType = 'KYCD'
  AND pradc_AdCampaignID = AdCampaignID

-- SELECT * FROM PRAdCampaign WHERE pradc_AdCampaignType = 'KYCD'
-- SELECT * FROM PRAdCampaign WHERE pradc_AdCampaignType = 'KYCD' AND pradc_AdCampaignCode = 'Tom'
-- UPDATE PRAdCampaign SET pradc_TargetURL = 'www.bluebookservices.com' WHERE pradc_AdCampaignType = 'KYCD' AND pradc_AdCampaignCode = 'Tom'
Go
				 

				 --
--  If we insert our own ID, the next time we use usp_AccpacCreateDropdownValue
--  it will crash due to a duplicate ID.  Why not use usp_AccpacCreateDropdownValue instead?
--				 
--INSERT INTO Custom_Captions (Capt_CaptionId, Capt_FamilyType, Capt_Family, Capt_Code, Capt_US, Capt_UK, Capt_FR, Capt_DE, Capt_ES, Capt_Order, Capt_System, Capt_CreatedBy, Capt_CreatedDate, Capt_UpdatedBy, Capt_UpdatedDate, Capt_TimeStamp, Capt_Deleted, Capt_Context, Capt_DU, Capt_JP, Capt_Component, capt_deviceid, capt_integrationid, capt_CS) 
--values (((select max(capt_captionid) from Custom_Captions) + 1),'Choices', 'prproduce_LastRunDate', NULL, 'Produce BB Last Run Date/Time', 'Produce BB Last Run Date/Time', 'Produce BB Last Run Date/Time', 'Produce BB Last Run Date/Time', 'Produce BB Last Run Date/Time', 0, NULL, -1, GETDATE(), -1000, GETDATE(), GETDATE(), NULL, NULL, NULL, NULL, 'PRDropdownValues', NULL, NULL, NULL)				 
EXEC usp_AccpacCreateDropdownValue 'prproduce_LastRunDate', NULL, 0, 'Produce BB Last Run Date/Time'
Go
 
DELETE FROM NewProduct WHERE prod_ProductID = 95
INSERT INTO NewProduct
	   (Prod_ProductID,prod_Active,prod_UOMCategory,prod_name,prod_PRServiceUnits,prod_code,prod_productfamilyid,prod_IndustryTypeCode,prod_PRSequence,Prod_CreatedBy,Prod_CreatedDate,Prod_UpdatedBy,Prod_UpdatedDate,Prod_TimeStamp)
VALUES (95,'Y',6000,'Level 1 Business Report', 1,'BR1',3, ',L,', 1, -1, GETDATE(),-1,GETDATE(),GETDATE());

DELETE FROM Pricing WHERE pric_ProductID = 95
 INSERT INTO Pricing (pric_PricingID, pric_ProductID, pric_Price, pric_Price_CID, pric_PricingListID, pric_Active, pric_CreatedBy, pric_CreatedDate, pric_UpdatedBy, pric_UpdatedDate, pric_TimeStamp)
 VALUES (80, 95, 10, 16010, 16010, 'Y', -1, GETDATE(), -1, GETDATE(), GETDATE()); 
Go

 --DEFECT 4441 - There is a flag/checkbox on this page that says " Is Eligible For Equifax Data:" and it should be changed to "...Experian..."
UPDATE Custom_Captions
SET Capt_US = 'Is Eligible For Experian Data' ,
    Capt_UK = 'Is Eligible For Experian Data' ,
    Capt_FR = 'Is Eligible For Experian Data' ,
    Capt_DE = 'Is Eligible For Experian Data' ,
    Capt_ES = 'Is Eligible For Experian Data'
WHERE Capt_FamilyType='Tags' AND Capt_Family='ColNames' AND Capt_Code = 'comp_PRIsEligibleForEquifaxData'
Go

UPDATE Company
   SET comp_PRHasITAAccess = 'Y'
 WHERE comp_PRIsIntlTradeAssociation = 'Y';
Go




--Defect 4324 - CRM: Move Allow AR Report Access checkbox to Info Profile pg
DECLARE @MyTable table (
		ndx int identity(1,1),
		CompanyID int
	)

INSERT INTO @MyTable
	SELECT c.comp_companyid FROM Company c 
		LEFT OUTER JOIN PRCompanyInfoProfile prcip ON prcip.prc5_CompanyId = c.comp_companyid
	WHERE c.comp_prarreportaccess='Y'
		AND prcip.prc5_CompanyID IS NULL

DECLARE @Count int, @Index int

SELECT @Count = COUNT(1) FROM @MyTable
SET @Index = 0

--INSERT NEW RECORDS INTO PRCompanyInfoProfile
WHILE (@Index < @Count) BEGIN
	SET @Index = @Index + 1

	DECLARE @NextID int
	EXEC usp_GetNextId 'PRCompanyInfoProfile', @NextID output

	DECLARE @CompanyID int
	SELECT @CompanyID = CompanyID FROM @MyTable WHERE ndx = @Index;
	INSERT INTO PRCompanyInfoProfile (prc5_CompanyInfoProfileID, prc5_CreatedBy, prc5_UpdatedBy, prc5_CompanyId, prc5_PRARReportAccess) 
		VALUES(@NextID, -1, -1, @CompanyID, 'Y')
END

--UPDATE RECORDS setting prc5_PRARReportAccess = 'Y'
UPDATE PRCompanyInfoProfile
	SET PRCompanyInfoProfile.prc5_PRARReportAccess = 'Y'
FROM Company c 
WHERE c.comp_prarreportaccess='Y'
	AND PRCompanyInfoProfile.prc5_CompanyId = c.comp_companyid

GO