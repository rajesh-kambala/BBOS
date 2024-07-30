ALTER TABLE Company DISABLE TRIGGER ALL
	UPDATE Company
	   SET comp_PROnlineOnly = 'Y'
	  FROM vPRLocation 
	 WHERE comp_PRListingCityID = prci_CityID
	   AND (prcn_CountryID NOT IN (1, 2, 3)
	        OR comp_PRIndustryType = 'L');
ALTER TABLE Company ENABLE TRIGGER ALL
Go


UPDATE PRBookImageFile
   SET prbif_Order = prbif_Order * 10

UPDATE PRBookImageFile
   SET prbif_Criteria = prbif_Criteria + ' AND comp_CompanyID NOT IN (SELECT prc2_CompanyID FROM PRCompanyClassification WHERE prc2_ClassificationID = 1245)'
 WHERE prbif_BookImageFileID IN (66, 67, 69, 70)


 INSERT INTO PRBookImageFile (prbif_FileName, prbif_FileType, prbif_Description, prbif_Criteria, prbif_Order)
 VALUES ('PR.TXT', 'BI', 'Puerto Rico Produce', ' AND comp_PRIndustryType = ''P'' AND prst_StateID = 1015', 395);

 INSERT INTO PRBookImageFile (prbif_FileName, prbif_FileType, prbif_Description, prbif_Criteria, prbif_Order)
 VALUES ('GU.TXT', 'BI', 'Guam Produce', ' AND comp_PRIndustryType = ''P'' AND prst_StateID = 1016', 115);

 INSERT INTO PRBookImageFile (prbif_FileName, prbif_FileType, prbif_Description, prbif_Criteria, prbif_Order)
 VALUES ('VI.TXT', 'BI', 'Virgin Islands Produce', ' AND comp_PRIndustryType = ''P'' AND prst_StateID = 1017', 465);

 INSERT INTO PRBookImageFile (prbif_FileName, prbif_FileType, prbif_Description, prbif_Criteria, prbif_Order)
 VALUES ('GOVRNMNT.TXT', 'BI', 'Government', ' AND comp_PRIndustryType = ''S'' AND prc2_ClassificationID <> 1245', 710);

UPDATE PRClassification
   SET prcl_Line1 = 'PRODUCE MARKETS'
 WHERE prcl_ClassificationID =3012;
Go



DECLARE @AdEligiblePageID int
SELECT @AdEligiblePageID = MAX(pradep_AdEligiblePageID) FROM PRAdEligiblePage

INSERT INTO PRAdEligiblePage (pradep_AdEligiblePageID, pradep_AdCampaignType, pradep_DisplayName, pradep_PageName, pradep_CreatedBy, pradep_CreatedDate, pradep_UpdatedBy, pradep_UpdatedDate, pradep_TimeStamp)
SELECT ROW_NUMBER() OVER(ORDER BY pradep_AdEligiblePageID DESC) + @AdEligiblePageID AS ID, 
       'IA_180x570', pradep_DisplayName, pradep_PageName, 
       -1, GETDATE(), -1, GETDATE(), GETDATE()
  FROM PRAdEligiblePage
 WHERE pradep_AdCampaignType LIKE 'IA'
   AND pradep_DisplayName IN (
				'Blue Book Services',
				'Blueprints', 
				'Blueprints Archive', 
				'Blueprints Edition', 
				'Company Search Results', 
				'Know Your Commodity', 
				'Learning Center', 
				'New Hire Academy', 
				'News', 
				'News Article', 
				'Reference Guide') 
Go



UPDATE Company
   SET comp_PRReceiveCSSurvey = 'Y', -- CASE WHEN prcn_CountryID = 2 THEN NULL ELSE 'Y' END,
	   comp_PRReceivePromoFaxes = 'Y', -- CASE WHEN prcn_CountryID = 2 THEN NULL ELSE 'Y' END,
	   comp_PRReceivePromoEmails = 'Y' -- CASE WHEN prcn_CountryID = 2 THEN NULL ELSE 'Y' END,
  FROM Company c 
	   LEFT OUTER JOIN vPRLocation ON c.comp_PRListingCityID = prci_CityID
 WHERE prcn_CountryID = 2;
Go



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

Go

DELETE FROM PRBBOSPrivilege

INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 500, 'CompanyAnalysisPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 200, 'ClaimActivitySearchPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege, Role) VALUES ('P', 200, 'CompanyEditListingPage', 'EditListing');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege, Role) VALUES ('P', 200, 'CompanyEditReferenceListPage', 'UpdateConnectionList');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 200, 'CompanyEditFinancialStatementPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 250, 'CompanyDetailsBranchesAffiliationsPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 200, 'CompanyDetailsChainStoreGuidePage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 200, 'CompanyDetailsClaimActivityPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 200, 'CompanyDetailsClassificationsCommoditesPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 400, 'CompanyDetailsContactsPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 300, 'CompanyDetailsCustomPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 200, 'CompanyDetailsNewsPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 200, 'CompanyDetailsListingPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 400, 'CompanyDetailsUpdatesPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 200, 'CompanySearchPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 300, 'CompanySearchByListingStatus');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 250, 'CompanySearchByPhoneFaxNumber');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 250, 'CompanySearchByEmail');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 250, 'CompanySearchByHasEmail');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 250, 'CompanySearchByHasFax');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 400, 'CompanySearchByNewListings');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 200, 'CompanySearchRatingPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 300, 'CompanySearchByTMFMMembershipYear');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 500, 'CompanySearchByBBScore');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 300, 'CompanySearchByCreditWorthRating');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 300, 'CompanySearchByIntegrityRating');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 300, 'CompanySearchByPayRating');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 200, 'CompanySearchLocationPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 400, 'CompanySearchByRadius');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 400, 'CompanySearchByTerminalMarket');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 200, 'CompanySearchCommoditiesPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 250, 'CompanySearchByCommodities');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 250, 'CompanySearchByCommodityAttributes');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 200, 'CompanySearchClassificationsPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 250, 'CompanySearchByClassifications');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 250, 'CompanySearchByNumberofRestaraunts');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 250, 'CompanySearchByNumberofRetailStores');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 200, 'CompanySearchProfilePage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 300, 'CompanySearchByLicense');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 300, 'CompanySearchByBrand');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 300, 'CompanySearchByCorporateStructure');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 300, 'CompanySearchByMiscListing');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 300, 'CompanySearchByVolume');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 200, 'CompanySearchCustomPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 300, 'CompanySearchByHasNotes');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 300, 'CompanySearchByWatchdogList');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 300, 'SaveSearches');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 200, 'CompanySearchResultsAutoRedirect1Result');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 200, 'CompanyUpdatesDownloadPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 400, 'CompanyUpdatesSearchPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 300, 'CustomFields');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 300, 'DataExportPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 300, 'DataExportBasicCompanyDataExport');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 400, 'DataExportDetailedCompanyDataExport');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 500, 'DataExportCompanyDataExportWBBScore');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 500, 'DataExportContactExportAllContacts');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 500, 'DataExportContactExportHeadExecutive');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 200, 'LearningCenterPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 200, 'BlueprintsPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 200, 'KnowYourCommodityPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 200, 'ReferenceGuidePage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 200, 'MembershipGuidePage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 200, 'BBOSTrainingPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 200, 'NewHireAcademyPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 200, 'DownloadsPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege, Role) VALUES ('P', 200, 'BusinessReportPurchase', 'UseServiceUnits');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 200, 'GetTMFMWidget');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 200, 'ManageMembershipPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 200, 'MembershipUpgrade');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 200, 'NewsPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 200, 'RSS');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 300, 'Notes');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 300, 'ViewBBScore');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 200, 'ViewRating');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 400, 'PersonDetailsPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 400, 'PersonSearchPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 400, 'PersonSearchLocationPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 400, 'PersonSearchByRadius');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 400, 'PersonSearchByTerminalMarket');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 400, 'PersonSearchCustomPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 400, 'PersonSearchByNotes');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 400, 'PersonSearchByWatchdogList');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 400, 'PersonvCard');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 200, 'PurchasesPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 300, 'RecentViewsPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 200, 'CompanyReportsPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 400, 'PersonReportsPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 200, 'ReportAdCampaign');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 200, 'ReportBankruptcy');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 400, 'ReportCompanyUpdateList');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 400, 'ReportCreditSheet');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 400, 'ReportCreditSheetExport');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 500, 'ReportBBScore');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 500, 'ReportCompanyAnalysis');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 500, 'ReportCompanyAnalysisExport');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 200, 'ReportCompanyListing');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 200, 'ReportFullBlueBookListing');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 300, 'ReportMailingLabels');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 300, 'ReportNotes');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 200, 'ReportQuickList');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 400, 'ReportRatingComparison');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 400, 'ReportPersonnel');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege, Role) VALUES ('P', 200, 'TradeExperienceSurveyPage', 'SubmitTES');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 200, 'BusinessReportSurvey');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege, Role) VALUES ('P', 200, 'TradingAssistancePage', 'UseSpecialServices');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 400, 'UserContacts');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 200, 'PersonAccessListPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 300, 'WatchdogListAdd');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 200, 'WatchdogListsPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 500, 'WebServices');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('P', 999999, 'SystemAdmin');


INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege, Role) 
SELECT 'T', AccessLevel, Privilege, Role
  FROM PRBBOSPrivilege
WHERE IndustryType = 'P';

INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege, Role) 
SELECT 'S', AccessLevel, Privilege, Role
  FROM PRBBOSPrivilege
WHERE IndustryType = 'P';

DELETE FROM PRBBOSPrivilege WHERE IndustryType = 'S' AND Privilege = 'CompanyEditReferenceListPage'
DELETE FROM PRBBOSPrivilege WHERE IndustryType = 'S' AND Privilege = 'CompanyEditFinancialStatementPage'





INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'CompanyDetailsListingPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'CompanyDetailsBranchesAffiliationsPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'CompanyDetailsClassificationsCommoditesProductSerivcesSpeciesPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'CompanyDetailsContactsPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'CompanyDetailsCustomPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'CompanyDetailsNewsPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'CompanyDetailsUpdatesPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege, Role) VALUES ('L', 400, 'CompanyEditListingPage', 'EditListing');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege, Role) VALUES ('L', 400, 'CompanyEditReferenceListPage', 'UpdateConnectionList');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'CompanyEditFinancialStatementPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'CompanySearchPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'CompanySearchByPhoneFaxNumber');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'CompanySearchByEmail');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'CompanySearchByHasEmail');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'CompanySearchByHasFax');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'CompanySearchByListingStatus');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'CompanySearchByNewListings');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'CompanySearchRatingPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'CompanySearchByPayIndicator');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'CompanySearchByPayReportCount');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'CompanySearchByCreditWorthRating');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'CompanySearchLocationPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'CompanySearchByRadius');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'CompanySearchSpeciePage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'CompanySearchBySpecie');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'CompanySearchProductsPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'CompanySearchByProducts');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'CompanySearchServicesPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'CompanySearchByServices');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'CompanySearchClassificationsPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'CompanySearchByClassifications');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'CompanySearchProfilePage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'CompanySearchByBrand');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'CompanySearchByCorporateStructure');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'CompanySearchByMiscListing');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'CompanySearchByVolume');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'CompanySearchCustomPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'CompanySearchByHasNotes');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'CompanySearchByWatchdogList');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'SaveSearches');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'BBOSTrainingPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'MembershipGuidePage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'ViewRating');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'CompanySearchResultsAutoRedirect1Result');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'CompanyUpdatesDownloadPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'CompanyUpdatesSearchPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'CustomFields');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'DataExportPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'DataExportCompanyDataExport');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'DataExportDetailedCompanyDataExport');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'DataExportContactExportAllContacts');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'DataExportContactExportHeadExecutive');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'PersonvCard');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'DownloadsPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege, Role) VALUES ('L', 400, 'BusinessReportPurchase', 'UseServiceUnits');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'BusinessReportSurvey');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'ManageMembershipPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'NewsPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'Notes');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'PersonDetailsPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'PersonSearchPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'PersonSearchLocationPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'PersonSearchByRadius');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'PersonSearchCustomPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'PersonSearchByNotes');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'PersonSearchByWatchdogList');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'PurchasesPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'RecentViewsPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'CompanyReportsPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'PersonReportsPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'ReportCompanyListing');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'ReportFullBlueBookListing');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'ReportMailingLabels');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'ReportNotes');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'ReportQuickList');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'ReportPersonnel');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'ReportCompanyUpdateList');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'ReportCreditSheet');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'ReportCreditSheetExport');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege, Role) VALUES ('L', 400, 'TradeExperienceSurveyPage', 'SubmitTES');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'UserContacts');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'PersonAccessListPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'WatchdogListAdd');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 400, 'WatchdogListsPage');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 999999, 'SystemAdmin');

UPDATE PRBBOSPrivilege SET Visible = 1, Enabled = 0; 
UPDATE PRBBOSPrivilege SET Visible = 0 WHERE Privilege = 'ViewBBScore';

Go

UPDATE PRCountry SET prcn_Region = 'NA' WHERE prcn_CountryID IN (1,2,3)
UPDATE PRCountry SET prcn_Region = 'AF' WHERE prcn_CountryID IN (17,30,40,57,62,73,87,91,95,96,100,102)
UPDATE PRCountry SET prcn_Region = 'AS' WHERE prcn_CountryID IN (20,46,53,71,85,92)
UPDATE PRCountry SET prcn_Region = 'ANZ' WHERE prcn_CountryID IN (8,60)
UPDATE PRCountry SET prcn_Region = 'CR' WHERE prcn_CountryID IN (4,5,7,10,11,14,18,27,28,33,41,51,59,75,80,86,88,103)
UPDATE PRCountry SET prcn_Region = 'CA' WHERE prcn_CountryID IN (13,22,31,39,42,61,66)
UPDATE PRCountry SET prcn_Region = 'EU' WHERE prcn_CountryID IN (9,12,23,24,25,26,32,34,35,36,37,44,45,48,50,56,58,63,64,69,70,74,76,77,81,89,93,98,99,101)
UPDATE PRCountry SET prcn_Region = 'ME' WHERE prcn_CountryID IN (49,54,65,82,90,97,104)
UPDATE PRCountry SET prcn_Region = 'PR' WHERE prcn_CountryID IN (38,43,47,52,55,68,72,78,79)
UPDATE PRCountry SET prcn_Region = 'SA' WHERE prcn_CountryID IN (6,15,16,19,21,29,67,83,84)



SELECT prcn_CountryID, prcn_Country, prcn_Region FROM PRCountry
Go


EXEC usp_UpdateListing 137930
Go

DELETE FROM NewProduct WHERE prod_ProductID=81
INSERT INTO NewProduct
	   (Prod_ProductID,prod_Active,prod_UOMCategory,prod_name,prod_code,prod_productfamilyid,prod_IndustryTypeCode,prod_PRRecurring,prod_PRSequence,prod_PRDescription,Prod_CreatedBy,Prod_CreatedDate,Prod_UpdatedBy,Prod_UpdatedDate,Prod_TimeStamp)
VALUES (81, 'Y', 6000, 'Business Reports', 'UNITS-PRODUCE', 99, ',P,T,S,', 'Y', 1, null,-1,GETDATE(),-1,GETDATE(),GETDATE());

DELETE FROM NewProduct WHERE prod_ProductID=82
INSERT INTO NewProduct
	   (Prod_ProductID,prod_Active,prod_UOMCategory,prod_name,prod_code,prod_productfamilyid,prod_IndustryTypeCode,prod_PRRecurring,prod_PRSequence,prod_PRDescription,Prod_CreatedBy,Prod_CreatedDate,Prod_UpdatedBy,Prod_UpdatedDate,Prod_TimeStamp)
VALUES (82, 'Y', 6000, 'Business Reports', 'UNITS-LUMBER', 99, ',L,', 'Y', 1, null,-1,GETDATE(),-1,GETDATE(),GETDATE());
Go