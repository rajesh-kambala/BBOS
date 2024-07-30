EXEC usp_AccpacDropTable 'PRAdCampaignTerms'
EXEC usp_AccpacCreateTable             'PRAdCampaignTerms', 'pract', 'pract_AdCampaignTermsID'
EXEC usp_AccpacCreateKeyField          'PRAdCampaignTerms', 'pract_AdCampaignTermsID', 'Ad Campaign Terms ID'
EXEC usp_AccpacCreateSearchSelectField 'PRAdCampaignTerms', 'pract_AdCampaignID', 'Ad Campaign', 'PRAdCampaign', 100 
EXEC usp_AccpacCreateSelectField       'PRAdCampaignTerms', 'pract_BlueprintsEdition', 'Blueprints Edition', 'pradc_BlueprintsEdition'
EXEC usp_AccpacCreateCurrencyField     'PRAdCampaignTerms', 'pract_TermsAmount', 'Terms Amt'


EXEC usp_DeleteCustom_ScreenObject 'PRAdCampaignBilling'
EXEC usp_AddCustom_ScreenObjects 'PRAdCampaignBilling', 'Screen', 'PRAdCampaign', 'N', 0, 'PRAdCampaign'
EXEC usp_AddCustom_Screens 'PRAdCampaignBilling', 10, 'pradc_Name',              1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRAdCampaignBilling', 20, 'pradc_Cost',              1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRAdCampaignBilling', 30, 'pradc_Discount',          1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRAdCampaignBilling', 40, 'pradc_TermsDescription',  1, 1, 1, 0
Go

EXEC usp_AddCustom_Screens 'PRAdCampaignBP', 305, 'pradc_CreatedBy',  0, 1, 1, 0
Go

/*
EXEC usp_AddCustom_Screens 'PRAdCampaignBilling', 30, 'pradc_Notes',        1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRAdCampaignBilling', 50, 'pradc_Premium',     1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRAdCampaignBilling', 50, 'pradc_Renewal',     1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRAdCampaignBilling', 50, 'pradc_SoldBy',     1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRAdCampaignBilling', 50, 'pradc_SoldDate',     1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRAdCampaignBilling', 50, 'pradc_Terms',     1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRAdCampaignBilling', 50, 'pradc_TermsDescription',     1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRAdCampaignBilling', 50, 'pradc_TermsAmt',     1, 1, 1, 0

EXEC usp_AccpacGetBlockInfo 'PRAdCampaignBP'
*/


-- DELETE FROM PRAdCampaignTerms


BEGIN TRANSACTION

SELECT pradc_AdCampaignID, pradc_CompanyID, pradc_Name, pradc_BluePrintsEdition, pradc_Cost, pradc_Terms, pract_BlueprintsEdition, pract_TermsAmount
  FROM PRAdCampaign
       LEFT OUTER JOIN PRAdCampaignTerms ON pradc_AdCampaignID = pract_AdCampaignID
 WHERE pradc_BluePrintsEdition IS NOT NULL
   AND pradc_Cost > 0
ORDER BY pradc_CreatedDate DESC

DECLARE @tblWork table (
	ndx int identity(1, 1),
	AdCampaignID int
)

INSERT INTO @tblWork 
SELECT pradc_AdCampaignID
  FROM PRAdCampaign
       LEFT OUTER JOIN PRAdCampaignTerms ON pradc_AdCampaignID = pract_AdCampaignID
 WHERE pradc_BluePrintsEdition IS NOT NULL
   AND pradc_Cost > 0
   AND pract_BlueprintsEdition IS NULL
ORDER BY pradc_CreatedDate DESC

		DECLARE @Count int, @Index int, @AdCampaignID int

		SELECT @Count = COUNT(1) FROM @tblWork

		SET @Index = 0
		WHILE (@Index < @Count) BEGIN
			SET @Index = @Index + 1

			SELECT @AdCampaignID = AdCampaignID
				FROM @tblWork
				WHERE ndx = @Index

			UPDATE PRAdCampaign
			   SET pradc_FileID = pradc_FileID
			 WHERE pradc_AdCampaignID = @AdCampaignID

		END

SELECT pradc_AdCampaignID, pradc_CompanyID, pradc_Name, pradc_BluePrintsEdition, pradc_Cost, pradc_Terms, pract_BlueprintsEdition, pract_TermsAmount
  FROM PRAdCampaign
       LEFT OUTER JOIN PRAdCampaignTerms ON pradc_AdCampaignID = pract_AdCampaignID
 WHERE pradc_BluePrintsEdition IS NOT NULL
   AND pradc_Cost > 0
ORDER BY pradc_CreatedDate DESC

ROLLBACK



ALTER TABLE Company DISABLE TRIGGER ALL

UPDATE Company
   SET comp_PRListingStatus = 'N6'
  FROM vPRCompanyRating
 WHERE comp_CompanyID = prra_CompanyID 
   AND comp_PRListingStatus = 'N3'
   AND prra_Current = 'Y'
   AND (prra_AssignedRatingNumerals LIKE ('%(88)%')
        OR prra_AssignedRatingNumerals LIKE ('%(113)%')
		OR prra_AssignedRatingNumerals LIKE ('%(114)%'))

ALTER TABLE Company ENABLE TRIGGER ALL