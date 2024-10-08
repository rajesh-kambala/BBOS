INSERT INTO PRWebUserCustomField (prwucf_HQID, prwucf_CompanyID, prwucf_FieldTypeCode, prwucf_Label, prwucf_Sequence, prwucf_CreatedBy, prwucf_CreatedDate, prwucf_UpdatedBy, prwucf_UpdatedDate, prwucf_TimeStamp)
SELECT DISTINCT prwucd_HQID, prwucd_CompanyID, 'Text', 'Custom Identifier', 0, -1, GETDATE(), -1 , GETDATE(), GETDATE()  
  FROM PRWebUserCustomData 
 WHERE prwucd_LabelCode = '1';


UPDATE PRWebUserCustomData
   SET prwucd_WebUserCustomFieldID = prwucf_WebUserCustomFieldID
  FROM PRWebUserCustomField
 WHERE prwucf_HQID = prwucd_HQID
   AND prwucf_Label = 'Custom Identifier';
GO

--
--  All person notes will be private
--
UPDATE a
   SET a.prwun_Note = CAST(a.prwun_Note as varchar(max)) + '<p>Migrated from public note:<br/>' + CAST(b.prwun_Note as varchar(max)) + '</p>'
  FROM PRWebUserNote a
       INNER JOIN PRWebUserNote b ON a.prwun_WebUserID = b.prwun_WebUserID AND a.prwun_AssociatedID = b.prwun_AssociatedID AND a.prwun_IsPrivate = 'Y' AND b.prwun_IsPrivate IS NULL
 WHERE a.prwun_AssociatedType = 'P'
   AND a.prwun_WebUserID IN (13204, 16896, 29692, 29902, 34401, 38315, 43847)
   AND a.prwun_AssociatedID IN (55984, 87678, 55120, 67712, 34201, 61677, 2999)

DELETE FROM PRWebUserNote
 WHERE prwun_AssociatedType = 'P'
   AND prwun_WebUserID IN (13204, 16896, 29692, 29902, 34401, 38315, 43847)
   AND prwun_AssociatedID IN (55984, 87678, 55120, 67712, 34201, 61677, 2999)
   AND prwun_IsPrivate IS NULL 

UPDATE PRWebUserNote
   SET prwun_IsPrivate = 'Y'
 WHERE prwun_AssociatedType = 'P'
   AND prwun_IsPrivate IS NULL ;
Go

UPDATE PRWebUser
   SET prwu_Timezone = 'Eastern Standard Time';

UPDATE PRWebUser
   SET prwu_Timezone = 'Central Standard Time'
 WHERE prwu_BBID IN (100002, 204482);

Go

DECLARE @NextId int
EXEC @NextId = crm_next_id 39 -- custom captions key
INSERT INTO Custom_Captions (Capt_CaptionId, Capt_FamilyType, Capt_Family, Capt_Code, Capt_US, Capt_Order, Capt_CreatedBy, Capt_CreatedDate, Capt_UpdatedBy, Capt_UpdatedDate,Capt_TimeStamp, Capt_Component) 
   VALUES (@NextId, 'Choices' , 'BBScoreImageLastRunDate', 'Aug 1 2014  12:01AM', 'BBScore Image Last Run Date/Time', 0, -1, GETDATE(), -1, GETDATE(), GETDATE(), 'PRCo');
Go   


UPDATE PRPublicationArticle
   SET prpbar_PublishDate = prpbed.prpbed_PublishDate
  FROM PRPublicationArticle prpbar WITH (NOLOCK)
	   INNER JOIN PRPublicationEdition prpbed WITH (NOLOCK) ON prpbar_PublicationEditionID = prpbed.prpbed_PublicationEditionID
 WHERE prpbar_PublicationCode IN ('BP', 'BPS')
   AND prpbar_PublishDate IS NULL;
Go

UPDATE Company
   SET comp_PRSessionTrackerIDCheckDisabled = 'Y'
 WHERE comp_CompanyID IN (100002, 204482);
Go



UPDATE PRAdEligiblePage
   SET pradep_AdCampaignType = 'IA',
       pradep_MaxAdCount = 4
 WHERE pradep_AdEligiblePageID = 6000;

DELETE FROM PRAdCampaignPage WHERE pradcp_AdEligiblePageID = 6000


DECLARE @AdCampaignPageID int
SELECT @AdCampaignPageID = MAX(pradcp_AdCampaignPageID) FROM PRAdCampaignPage

INSERT INTO PRAdCampaignPage (pradcp_AdCampaignPageID, pradcp_CreatedBy, pradcp_CreatedDate, pradcp_UpdatedBy, pradcp_UpdatedDate, pradcp_TimeStamp, pradcp_AdCampaignID, pradcp_AdEligiblePageID)
SELECT ROW_NUMBER() OVER(ORDER BY pradcp_AdCampaignPageID DESC) + @AdCampaignPageID AS ID, 
       -1, GETDATE(), -1, GETDATE(), GETDATE(), pradcp_AdCampaignID, 6000 
  FROM PRAdCampaignPage
       INNER JOIN PRAdCampaign ON pradcp_AdCampaignID = pradc_AdCampaignID
   WHERE pradcp_AdEligiblePageID = 6003
   AND GETDATE() BETWEEN pradc_StartDate AND pradc_EndDate

EXEC usp_DTSPostExecute 'PRAdCampaignPage', 'pradcp_AdCampaignPageID'
Go

UPDATE Custom_Captions SET capt_us = '', capt_es = '' WHERE capt_Family = 'EmailTemplate' and capt_code IN ('MarketingMessageP', 'MarketingMessageL')
Go



UPDATE NewProduct
   SET prod_PRDescription = REPLACE(prod_PRDescription, '<ul class="bulletList">', '<ul class="Bullets">')
WHERE prod_ProductFamilyID=5
  AND prod_PRDescription IS NOT NULL

UPDATE NewProduct
   SET prod_PRDescription = REPLACE(prod_PRDescription, '<li class="bulletListItem">', '<li>')
WHERE prod_ProductFamilyID=5
  AND prod_PRDescription IS NOT NULL
Go

DELETE FROM NewProduct WHERE prod_ProductID=80
INSERT INTO NewProduct
	   (Prod_ProductID,prod_Active,prod_UOMCategory,prod_name,prod_code,prod_productfamilyid,prod_IndustryTypeCode,prod_PRSequence,prod_PRDescription,Prod_CreatedBy,Prod_CreatedDate,Prod_UpdatedBy,Prod_UpdatedDate,Prod_TimeStamp)
VALUES (80,'Y',6000,'Business Report','BR4',2, ',L,', 130, '<div style="font-weight:bold">Blue Book Business Report including Equifax Credit Information</div><p style="margin-top:0em">Creditors—such as sellers, transporters and suppliers—use this report type for performing a high-level connection/prospect evaluation, where there is typically a specific interest in current and trend facts such as pay and trade experiences. Tabular and graphic presentation of the company''s rating information makes it quick & easy to reach informed decisions.</p><p>The Business Report includes: basic company contact information such as Blue Book ID#, company name, listing location, addresses, phones, faxes, e-mails, web URLs, ownership, and alternate trade names. Also included - if available/applicable - are current headquarter rating & rating definition, affiliated businesses, branch locations, headquarter rating trend, recent company developments, bankruptcy events, business background, people background, business profile, financial information, and year-to-date trade report summary. Select credit information such as public record information, and banking and non-banking account highlights provided by <span style="font-weight:bold">Equifax</span>, will be included with your Business Report, as available/applicable. When used in conjunction with Blue Book data, information provided by <span style="font-weight:bold">Equifax</span> can help provide a comprehensive financial picture of a company as a whole, including financial activities outside of the lumber industry.</p> ',-1,GETDATE(),-1,GETDATE(),GETDATE());

DELETE FROM Pricing WHERE pric_ProductID=80
 INSERT INTO Pricing (pric_PricingID, pric_ProductID, pric_Price, pric_Price_CID, pric_PricingListID, pric_Active, pric_CreatedBy, pric_CreatedDate, pric_UpdatedBy, pric_UpdatedDate, pric_TimeStamp)
 VALUES (70, 80, 30, 16010, 16010, 'Y', -1, GETDATE(), -1, GETDATE(), GETDATE());

UPDATE NewProduct
   SET prod_IndustryTypeCode = ',P,T,S,'
 WHERE Prod_ProductID = 47;
Go


UPDATE Company
   SET comp_PRServiceStartDate = DATEADD(dd, 0, DATEDIFF(dd, 0, prse_CreatedDate)),
	   comp_PRServiceEndDate = NULL
  FROM PRService
 WHERE comp_CompanyID = prse_CompanyID
   AND prse_Primary = 'Y'
   AND comp_PRServiceStartDate IS NULL

UPDATE Company
   SET comp_PROriginalServiceStartDate = DATEADD(dd, 0, DATEDIFF(dd, 0, prse_CreatedDate))
  FROM PRService
 WHERE comp_CompanyID = prse_CompanyID
   AND prse_Primary = 'Y'
   AND comp_PROriginalServiceStartDate IS NULL

UPDATE Company
   SET comp_PRServiceEndDate = CancelDate
 FROM (SELECT comp_CompanyID, comp_PRServiceStartDate, comp_PRServiceEndDate, CancelDate
	  FROM Company
		   INNER JOIN (SELECT prsoat_SoldToCompany, MAX(prsoat_CreatedDate) as CancelDate 
						 FROM PRSalesOrderAuditTrail 
						WHERE prsoat_ActionCode = 'C' GROUP BY prsoat_SoldToCompany) T1 ON comp_CompanyID = prsoat_SoldToCompany
	 WHERE comp_PRServiceStartDate IS NOT NULL
	   AND comp_PRServiceEndDate IS NULL
	   AND comp_CompanyID NOT IN (SELECT prse_CompanyID FROM PRService WHERE prse_Primary = 'Y')
	   AND comp_PRServiceStartDate < CancelDate) T1
WHERE Company.comp_CompanyID = T1.comp_CompanyID;
Go


UPDATE PRPublicationArticle
   SET prpbar_FileName = REPLACE(prpbar_FileName, 'BP\', 'BP\' + prpbed_Name + '\'),
       prpbar_CategoryCode = prpbar_PublicationCode
  FROM PRPublicationEdition
 WHERE prpbar_PublicationEditionID = prpbed_PublicationEditionID
   AND prpbar_FileName LIKE 'BP\BP%'
Go

UPDATE PRListing
   SET prlst_Listing =  dbo.ufn_GetListingFromCompany(prlst_CompanyID, 0, 0)
 WHERE prlst_CompanyID = 272961
Go