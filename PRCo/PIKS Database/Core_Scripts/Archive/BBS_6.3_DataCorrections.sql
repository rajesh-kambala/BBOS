--
--  Do this AFTER fixing the PRARTranslation records.
--
ALTER TABLE PRARAgingDetail DISABLE  TRIGGER ALL 

 UPDATE PRARAgingDetail
   SET praad_SubjectCompanyID = prar_PRCoCompanyId,
       praad_UpdatedBy = -1,
	   praad_UpdatedDate = GETDATE()
  FROM PRARAging
       INNER JOIN PRARAgingDetail ON praa_ARAgingId = praad_ARAgingId
       INNER JOIN PRARTranslation ON prar_CompanyId = praa_CompanyId AND praad_ARCustomerId = prar_CustomerNumber
 WHERE praad_SubjectCompanyID IS NOT NULL
   AND praad_SubjectCompanyID <> prar_PRCoCompanyId;

ALTER TABLE PRARAgingDetail ENABLE TRIGGER ALL 



UPDATE PRWebUser
   SET prwu_ServiceCode = null
 WHERE prwu_ServiceCode = 'None';
Go


DECLARE @AdEligiblePageID int
EXEC usp_GetNextId 'PRAdEligiblePage', @AdEligiblePageID output
INSERT INTO PRAdEligiblePage (pradep_AdEligiblePageID,pradep_AdCampaignType,pradep_DisplayName,pradep_PageName,pradep_MaxAdCount,pradep_MinAdCount,pradep_MaxImageHeight,pradep_MaxImageWidth,pradep_CreatedBy,pradep_CreatedDate,pradep_UpdatedBy,pradep_UpdatedDate,pradep_TimeStamp)
VALUES (@AdEligiblePageID,'IA','New Hire Academy','NewHireAcademy',1,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());


DECLARE @AdCampaignID int
EXEC usp_GetNextId 'PRAdCampaign', @AdCampaignID output
INSERT INTO PRAdCampaign
    (pradc_AdCampaignID, pradc_CompanyID, pradc_HQID, pradc_Name, pradc_AdCampaignType, pradc_AdImageName, 
	 pradc_TargetURL, pradc_StartDate, pradc_EndDate,
	 pradc_CreatedBy, pradc_CreatedDate,pradc_UpdatedBy,pradc_UpdatedDate,pradc_TimeStamp)
VALUES (@AdCampaignID,118561,118561, 'NHA Sponsorship', 'IA', '118561\NHASponsor.jpg',
        NULL, '2013-05-01', '2020-12-31', 
		-100, GETDATE(), -100,GETDATE(), GETDATE());

DECLARE @RecordID int
EXEC usp_GetNextId 'PRAdCampaignPage', @RecordID output
INSERT INTO PRAdCampaignPage (pradcp_AdCampaignPageID,pradcp_AdCampaignID,pradcp_AdEligiblePageID,pradcp_CreatedBy,pradcp_CreatedDate,pradcp_UpdatedBy,pradcp_UpdatedDate,pradcp_TimeStamp)
VALUES (@RecordID, @AdCampaignID, @AdEligiblePageID, -100, GETDATE(), -100, GETDATE(), GETDATE());
Go


ALTER TABLE Email DISABLE TRIGGER ALL
UPDATE Email
   SET emai_PRDescription = 'Web Site'
 WHERE emai_PRDescription = 'Website';
ALTER TABLE Email ENABLE TRIGGER ALL
Go


UPDATE PRCSPhrase
   SET prcsp_Phrase = 'USDA reports'
 WHERE prcsp_CSPhraseId = 11

UPDATE PRCSPhrase
   SET prcsp_Phrase = 'and then only with USDA approval'
 WHERE prcsp_CSPhraseId = 18
Go

DELETE FROM PRPublicationArticle WHERE prpbar_PublicationArticleID=101
INSERT INTO PRPublicationArticle
(prpbar_PublicationArticleID,prpbar_PublicationCode,prpbar_PublishDate,prpbar_CategoryCode,prpbar_MediaTypeCode,prpbar_Sequence,prpbar_Name,prpbar_FileName,prpbar_IndustryTypeCode,prpbar_CreatedBy,prpbar_CreatedDate,prpbar_UpdatedBy,prpbar_UpdatedDate,prpbar_TimeStamp)
Values (101,'TRN','7/22/2013 00:00','BT','Doc', 22,'Blueprints Flip Page FAQ', 'TRN\22 Blueprints Fip Page FAQ.pdf', ',P,T,S,', -1, GETDATE(), -1, GETDATE(), GETDATE()); 
