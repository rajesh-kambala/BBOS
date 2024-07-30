ALTER TABLE Person_Link DISABLE TRIGGER ALL
UPDATE Person_Link 
   SET peli_PRReceiveBRSurvey = 'Y'
  FROM Person_Link
       INNER JOIN Company ON PeLi_CompanyID = Comp_CompanyId
       INNER JOIN vPRLocation ON comp_PRListingCityId = prci_CityID
 WHERE prcn_CountryID <> 2;
ALTER TABLE Person_Link ENABLE TRIGGER ALL


ALTER TABLE COMPANY DISABLE TRIGGER ALL
UPDATE Company
   SET comp_PRReceiveCSSurvey = NULL,
       comp_PRReceivePromoFaxes = NULL,
	   comp_PRReceivePromoEmails = NULL
  FROM Company
       INNER JOIN vPRLocation ON comp_PRListingCityId = prci_CityID
 WHERE prcn_CountryID = 2;
 ALTER TABLE COMPANY ENABLE TRIGGER ALL
Go

ALTER TABLE PRARAgingDetail DISABLE TRIGGER ALL
UPDATE PRARAgingDetail
   SET praad_SubjectCompanyID = NULL


UPDATE PRARAgingDetail
   SET praad_SubjectCompanyID = praad_ManualCompanyId
 WHERE praad_ManualCompanyId IS NOT NULL;

UPDATE PRARAgingDetail
   SET praad_SubjectCompanyID = prar_PRCoCompanyId
  FROM PRARAging
       INNER JOIN PRARAgingDetail ON praa_ARAgingId = praad_ARAgingId
       INNER JOIN PRARTranslation ON prar_CompanyId = praa_CompanyId AND praad_ARCustomerId = prar_CustomerNumber
 WHERE praad_SubjectCompanyID IS NULL;
ALTER TABLE PRARAgingDetail ENABLE TRIGGER ALL 


UPDATE PRARAging
   SET praa_Count = praa_ARAgingDetailCount,
       praa_Total = praad_TotalAmountCurrent  + praad_TotalAmount1to30 + praad_TotalAmount31to60 + praad_TotalAmount61to90 + praad_TotalAmount91Plus +  praad_TotalAmount0to29 + praad_TotalAmount30to44 + praad_TotalAmount45to60 + praad_TotalAmount61Plus,
       praa_TotalCurrent = praad_TotalAmountCurrent,
       praa_Total1to30 = praad_TotalAmount1to30,
       praa_Total31to60 = praad_TotalAmount31to60,
       praa_Total61to90 = praad_TotalAmount61to90,
       praa_Total91Plus = praad_TotalAmount91Plus,
       praa_Total0to29 = praad_TotalAmount0to29,
       praa_Total30to44 = praad_TotalAmount30to44,
       praa_Total45to60 = praad_TotalAmount45to60,
       praa_Total61Plus = praad_TotalAmount61Plus       
  FROM  (
		SELECT praad_ARAgingId, 
			   praa_ARAgingDetailCount = COUNT(1), 
			   praad_TotalAmountCurrent = ISNULL(SUM(praad_AmountCurrent), 0),
			   praad_TotalAmount1to30 = ISNULL(SUM(praad_Amount1to30),  0),
			   praad_TotalAmount31to60 = ISNULL(SUM(praad_Amount31to60), 0),
			   praad_TotalAmount61to90 = ISNULL(SUM(praad_Amount61to90), 0),
			   praad_TotalAmount91Plus = ISNULL(SUM(praad_Amount91Plus), 0),
			   praad_TotalAmount0to29 = ISNULL(SUM(praad_Amount0to29),  0),
			   praad_TotalAmount30to44 = ISNULL(SUM(praad_Amount30to44), 0),
			   praad_TotalAmount45to60 = ISNULL(SUM(praad_Amount45to60), 0),
			   praad_TotalAmount61Plus = ISNULL(SUM(praad_Amount61Plus), 0)
		  FROM PRARAgingDetail WITH (NOLOCK) 
	  GROUP BY praad_ARAgingId) T1
WHERE praa_ARAgingId = T1.praad_ARAgingId;
 Go


DELETE FROM PRAdEligiblePage WHERE pradep_AdEligiblePageID = 6013
INSERT INTO PRAdEligiblePage
(pradep_AdEligiblePageID,pradep_AdCampaignType,pradep_DisplayName,pradep_PageName,pradep_MaxAdCount,pradep_MinAdCount,pradep_MaxImageHeight,pradep_MaxImageWidth,pradep_CreatedBy,pradep_CreatedDate,pradep_UpdatedBy,pradep_UpdatedDate,pradep_TimeStamp)
VALUES (6013,'IA','Blueprints','Blueprints.aspx',25,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());

DELETE FROM PRAdEligiblePage WHERE pradep_AdEligiblePageID = 6014
INSERT INTO PRAdEligiblePage
(pradep_AdEligiblePageID,pradep_AdCampaignType,pradep_DisplayName,pradep_PageName,pradep_MaxAdCount,pradep_MinAdCount,pradep_MaxImageHeight,pradep_MaxImageWidth,pradep_CreatedBy,pradep_CreatedDate,pradep_UpdatedBy,pradep_UpdatedDate,pradep_TimeStamp)
VALUES (6014,'IA','Blueprints Edition','BlueprintsEdition.aspx',25,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());

DELETE FROM PRAdEligiblePage WHERE pradep_AdEligiblePageID = 6015
INSERT INTO PRAdEligiblePage
(pradep_AdEligiblePageID,pradep_AdCampaignType,pradep_DisplayName,pradep_PageName,pradep_MaxAdCount,pradep_MinAdCount,pradep_MaxImageHeight,pradep_MaxImageWidth,pradep_CreatedBy,pradep_CreatedDate,pradep_UpdatedBy,pradep_UpdatedDate,pradep_TimeStamp)
VALUES (6015,'IA','Blueprints Archive','BlueprintsArchive.aspx',25,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());

EXEC usp_UpdateSQLIdentity 'PRAdEligiblePage', 'pradep_AdEligiblePageID'
Go

UPDATE PRPublicationArticle
   SET prpbar_PublicationCode = 'BPS'
 WHERE prpbar_PublicationArticleID IN (
 6731,6732,
6733,6763,6764,6765,6806,6807,6808,6811,6812,6813,6814,6829,
6830,7023,7024,7026,7025,7171,7169,7170,7167,7168,7166,7524,
7520,7521,7522,7523,7612,7639,7624,7625,7626,7642,7643,7644,
7635,7636,7637,7641,7741,7742,7743,7744,8026,8027,8029,8028,
8149,8150,8151,8152,8154,8155,8308,8309,8310,8311,8450,8451,
8642,8643,8644,8645,8785,8786,8787,8790,8791,8960,8958,8959,
8961,9135,9136,9137,9159,9158,9160,9291,9292,9293,9294,9451,
9449,9450,9452,9471,9466,9468,9469,10655,10652,10653,10654)
Go


UPDATE PRPublicationEdition
   SET prpbed_PublishDate = '2010-01-01'
WHERE prpbed_PublicationEditionID = 6036
Go