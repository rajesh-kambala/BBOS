IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'cscr_Disabled' AND OBJECT_ID = OBJECT_ID(N'Custom_Scripts'))
BEGIN
	ALTER TABLE Custom_Scripts ADD cscr_Disabled nchar(1);
END
Go


EXEC usp_AccpacDropTable 'PRDeleteQueue'
EXEC usp_AccpacCreateTable @EntityName='PRDeleteQueue', @ColPrefix='prdq', @IDField='prdq_PRDeleteQueueID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyField          'PRDeleteQueue', 'prdq_PRDeleteQueueID', 'Delete Queue ID'
EXEC usp_AccpacCreateSearchSelectField 'PRDeleteQueue', 'prdq_CompanyID', 'Company', 'Company', 50 
Go

-- Add this to the vPRBBOSPersonList view
EXEC usp_AccpacCreateIntegerField 'Person_Link', 'peli_PRSequence', 'BBOS Sequence'
Go

EXEC usp_AccpacCreateIntegerField   'PRCommodity', 'prcm_RootParentID', 'Root ParentID'
EXEC usp_AccpacCreateCheckboxField  'PRCommodity', 'prcm_HideInBBOSSearch', 'Hide in BBOS Search'
Go


EXEC usp_AccpacCreateCheckboxField 'PRARAgingDetail', 'praad_DoNotMatch', 'Do Not Match'
Go


EXEC usp_AccpacCreateSelectField 'Opportunity', 'oppo_PRAdSize', 'Ad Size', 'oppo_PRAdSize'
EXEC usp_AccpacCreateSelectField 'Opportunity', 'oppo_PRPremium', 'Premium', 'oppo_PRPremium'
EXEC usp_AccpacCreateSelectField 'Opportunity', 'oppo_PRPlacement', 'Ad Placement', 'oppo_PRPlacement'
EXEC usp_AccpacCreateSelectField 'Opportunity', 'oppo_PRSponsorship', 'Sponsorship', 'oppo_PRSponsorship'

EXEC usp_DeleteCustom_ScreenObject 'PROpportunityBPAd'
EXEC usp_AddCustom_ScreenObjects 'PROpportunityBPAd', 'Screen', 'Opportunity', 'N', 0, 'Opportunity'
EXEC usp_AddCustom_Screens 'PROpportunityBPAd', 10, 'oppo_Type', 1, 1, 1
EXEC usp_AddCustom_Screens 'PROpportunityBPAd', 20, 'oppo_Status', 0, 1, 1
EXEC usp_AddCustom_Screens 'PROpportunityBPAd', 30, 'oppo_Stage', 0, 1, 1
EXEC usp_AddCustom_Screens 'PROpportunityBPAd', 40, 'oppo_PrimaryCompanyId', 1, 1, 1
EXEC usp_AddCustom_Screens 'PROpportunityBPAd', 50, 'oppo_PrimaryPersonId', 0, 1, 1
EXEC usp_AddCustom_Screens 'PROpportunityBPAd', 60, 'oppo_PRSecondaryPersonID', 0, 1, 1
EXEC usp_AddCustom_Screens 'PROpportunityBPAd', 70, 'oppo_Opened', 1, 1, 1
EXEC usp_AddCustom_Screens 'PROpportunityBPAd', 80, 'oppo_Closed', 0, 1, 1
EXEC usp_AddCustom_Screens 'PROpportunityBPAd', 90, 'oppo_AssignedUserId', 0, 1, 1

EXEC usp_AddCustom_Screens 'PROpportunityBPAd', 100, 'oppo_PRAdSize', 1, 1, 1, 'Y'
EXEC usp_AddCustom_Screens 'PROpportunityBPAd', 110, 'oppo_PRPremium', 0, 1, 1
EXEC usp_AddCustom_Screens 'PROpportunityBPAd', 120, 'oppo_PRTrigger', 0, 1, 1, 'Y'

EXEC usp_AddCustom_Screens 'PROpportunityBPAd', 200, 'oppo_PRPlacement', 1, 1, 1, 'Y'
EXEC usp_AddCustom_Screens 'PROpportunityBPAd', 210, 'oppo_PRSponsorship', 0, 1, 1
EXEC usp_AddCustom_Screens 'PROpportunityBPAd', 220, 'oppo_PRCertainty', 0, 1, 1, 'Y'

EXEC usp_AddCustom_Screens 'PROpportunityBPAd', 300, 'oppo_Forecast', 1, 1, 1, 'Y'
EXEC usp_AddCustom_Screens 'PROpportunityBPAd', 310, 'oppo_PRLostReason', 0, 1, 1

EXEC usp_AddCustom_Screens 'PROpportunityBPAd', 400, 'oppo_Note', 1, 1, 3, 'Y'

EXEC usp_AddCustom_Screens 'PROpportunityBPAd', 500, 'oppo_PRTargetStartYear', 1, 1, 1, 'Y'
EXEC usp_AddCustom_Screens 'PROpportunityBPAd', 510, 'oppo_PRTargetStartMonth', 0, 1, 1, 'Y'
EXEC usp_AddCustom_Screens 'PROpportunityBPAd', 520, 'oppo_PRAdRenewal', 1, 1, 1
EXEC usp_AddCustom_Screens 'PROpportunityBPAd', 530, 'Oppo_WaveItemId', 0, 1, 1

EXEC usp_AccpacGetBlockInfo 'PROpportunityBPAd'

EXEC usp_AddCustom_Lists 'PROpportunityGrid', 55, 'oppo_PRAdSize', null, 'Y'
Go



EXEC usp_AccpacCreateSelectField 'Opportunity', 'oppo_PRDigitalPlacement', 'Digital Placement', 'oppo_PRDigitalPlacement'


EXEC usp_DeleteCustom_ScreenObject 'PROpportunityDigitalAd'
EXEC usp_AddCustom_ScreenObjects 'PROpportunityDigitalAd', 'Screen', 'Opportunity', 'N', 0, 'Opportunity'
EXEC usp_AddCustom_Screens 'PROpportunityDigitalAd', 10, 'oppo_Type', 1, 1, 1
EXEC usp_AddCustom_Screens 'PROpportunityDigitalAd', 20, 'oppo_Status', 0, 1, 1
EXEC usp_AddCustom_Screens 'PROpportunityDigitalAd', 30, 'oppo_Stage', 0, 1, 1
EXEC usp_AddCustom_Screens 'PROpportunityDigitalAd', 40, 'oppo_PrimaryCompanyId', 1, 1, 1
EXEC usp_AddCustom_Screens 'PROpportunityDigitalAd', 50, 'oppo_PrimaryPersonId', 0, 1, 1
EXEC usp_AddCustom_Screens 'PROpportunityDigitalAd', 60, 'oppo_PRSecondaryPersonID', 0, 1, 1
EXEC usp_AddCustom_Screens 'PROpportunityDigitalAd', 70, 'oppo_Opened', 1, 1, 1
EXEC usp_AddCustom_Screens 'PROpportunityDigitalAd', 80, 'oppo_Closed', 0, 1, 1
EXEC usp_AddCustom_Screens 'PROpportunityDigitalAd', 90, 'oppo_AssignedUserId', 0, 1, 1

EXEC usp_AddCustom_Screens 'PROpportunityDigitalAd', 100, 'oppo_PRDigitalPlacement', 1, 1, 1
EXEC usp_AddCustom_Screens 'PROpportunityDigitalAd', 120, 'oppo_PRTrigger', 0, 1, 1, 'Y'
EXEC usp_AddCustom_Screens 'PROpportunityDigitalAd', 130, 'oppo_PRCertainty', 0, 1, 1

EXEC usp_AddCustom_Screens 'PROpportunityDigitalAd', 200, 'oppo_Forecast', 1, 1, 1
EXEC usp_AddCustom_Screens 'PROpportunityDigitalAd', 210, 'oppo_PRLostReason', 0, 1, 1

EXEC usp_AddCustom_Screens 'PROpportunityDigitalAd', 300, 'oppo_Note', 1, 1, 3, 'Y'

EXEC usp_AddCustom_Screens 'PROpportunityDigitalAd', 400, 'oppo_PRTargetStartYear', 1, 1, 1
EXEC usp_AddCustom_Screens 'PROpportunityDigitalAd', 410, 'oppo_PRTargetStartMonth', 0, 1, 1
EXEC usp_AddCustom_Screens 'PROpportunityDigitalAd', 420, 'oppo_PRAdRenewal', 1, 1, 1
EXEC usp_AddCustom_Screens 'PROpportunityDigitalAd', 430, 'Oppo_WaveItemId', 0, 1, 1
Go


EXEC usp_DeleteCustom_Screen 'PROpportunitySummary', 'oppo_Priority'
EXEC usp_DeleteCustom_Screen 'PROpportunitySummary', 'Oppo_WaveItemId'

EXEC usp_DeleteCustom_Screen 'PROpportunitySummary', 'oppo_Priority'
EXEC usp_DeleteCustom_Screen 'PROpportunitySummary', 'Oppo_WaveItemId'
EXEC usp_DeleteCustom_ScreenObject 'PROpportunityMembershipSummary'
EXEC usp_DeleteCustom_ScreenObject 'PRBlueprintsOpportunitySummary'
UPDATE custom_captions SET capt_us = 'BBS Level', capt_uk = 'BBS Level', capt_es = 'BBS Level', capt_fr = 'BBS Level', capt_de = 'BBS Level' WHERE capt_code = 'oppo_PRType'
Go

EXEC usp_AddCustom_Screens 'PRAdCampaignBP', 170, 'pradc_Terms',  1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRAdCampaignBP', 190, 'pradc_TermsDescription',  0, 1, 0
EXEC usp_DeleteCustom_Screen 'PRAdCampaignBP', 'pradc_TermsAmt'
Go

EXEC usp_DeleteCustom_Screen 'CommunicationSchedulingBox', 'Comm_IsAllDayEvent'
UPDATE custom_screens SET seap_Required='Y' WHERE seap_SearchBoxName = 'CustomCommunicationDetailBox' AND seap_ColName = 'comm_Note'

Go

EXEC usp_DeleteCustom_List 'PRPersonEmailGrid', 'emai_PRWebAddress'
Go


EXEC usp_AccpacCreateCheckboxField 'Company', 'comp_PRLocalSource', 'Local Source'
EXEC usp_AccpacCreateCheckboxField 'Person', 'pers_PRLocalSource', 'Local Source'
EXEC usp_AccpacCreateTextField     'Person', 'pers_PRMMWID', 'MMW ID', 25, 50
EXEC usp_AccpacCreateTextField 'PRCompanyAlias', 'pral_AliasMatch', 'Alias Match', 50, 104
EXEC usp_AccpacCreateTextField 'PRPACALicense', 'prpa_CompanyNameMatch', 'Company Name Match', 50, 104
Go


EXEC usp_AccpacCreateTable @EntityName='PRLocalSourceRegion', @ColPrefix='prlsr', @IDField='prlsr_LocalSourceRegionID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyField          'PRLocalSourceRegion', 'prlsr_LocalSourceRegionID', 'Local Source Region ID'
EXEC usp_AccpacCreateTextField         'PRLocalSourceRegion', 'prlsr_ServiceCode', 'Service Code', 25, 25
EXEC usp_AccpacCreateIntegerField	   'PRLocalSourceRegion', 'prlsr_StateID', 'State'
Go


EXEC usp_AccpacCreateTable @EntityName='PRLocalSource', @ColPrefix='prls', @IDField='prls_LocalSourceID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyField          'PRLocalSource', 'prls_LocalSourceID', 'Local Source ID'
EXEC usp_AccpacCreateSearchSelectField 'PRLocalSource', 'prls_CompanyID', 'Company', 'Company', 100 
--EXEC usp_AccpacCreateSelectField       'PRLocalSource', 'prls_LocalSourceRegion', 'Local Source Region', 'prls_LocalSourceRegion'
EXEC usp_AccpacCreateIntegerField	   'PRLocalSource', 'prls_RegionStateID', 'State'
EXEC usp_AccpacCreateTextField         'PRLocalSource', 'prls_AlsoOperates', 'Also Operates', 50, 125
EXEC usp_AccpacCreateCheckboxField     'PRLocalSource', 'prls_Organic', 'Organic'
EXEC usp_AccpacCreateSelectField       'PRLocalSource', 'prls_TotalAcres', 'Total Acres', 'prls_TotalAcres'
EXEC usp_AccpacCreateTextField         'PRLocalSource', 'prls_EnhancedListing', 'Enhanced Listing', 50, 1000
Go

EXEC usp_AccpacCreateTable @EntityName='PRWebUserLocalSource', @ColPrefix='prwuls', @IDField='prwuls_WebUserLocalSourceID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyField          'PRWebUserLocalSource', 'prwuls_WebUserLocalSourceID', 'Web UserLocal Source ID'
EXEC usp_AccpacCreateSearchSelectField 'PRWebUserLocalSource', 'prwuls_WebUserID', 'Web User ID', 'PRWebUser', 100 
EXEC usp_AccpacCreateTextField         'PRWebUserLocalSource', 'prwuls_ServiceCode', 'ServiceCode', 25, 25
Go

EXEC usp_DeleteCustom_ScreenObject 'PRLocalSourceSummary'
EXEC usp_AddCustom_ScreenObjects 'PRLocalSourceSummary', 'Screen', 'vPRLocalSource', 'N', 0, 'vPRLocalSource'
--EXEC usp_AddCustom_Screens 'PRLocalSourceSummary', 10, 'Region', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRLocalSourceSummary', 20, 'prls_AlsoOperates', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRLocalSourceSummary', 30, 'prls_Organic', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRLocalSourceSummary', 40, 'prls_TotalAcres', 0, 1, 1, 0
Go

EXEC usp_AddCustom_Screens 'PRCompanyInfo', 62, 'comp_PRLocalSource', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCompanyInfo', 72, 'comp_PRAccountTier', 0, 1, 1, 0

EXEC usp_AddCustom_Screens 'CompanyAdvancedSearchBox', 110, 'comp_PRUnconfirmed', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'CompanyAdvancedSearchBox', 120, 'comp_PRLocalSource', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'CompanyAdvancedSearchBox', 600, 'UDF_MASTER_INVOICE', 1, 1, 1, 0

EXEC usp_AddCustom_Screens 'PersonAdvancedSearchBox', 140, 'pers_PRLocalSource', 1, 1, 1, 0
Go

EXEC usp_AddCustom_Lists 'PRPersonList', 80, 'LocalSourceDataAccess', null, null
EXEC usp_AddCustom_Captions 'Tags', 'ColNames', 'LocalSourceDataAccess', 0, 'Local Source Data Access'
Go


EXEC usp_AccpacCreateTextField 'PRState', 'prst_FIPSCode', 'FIPSCode', 5, 5
Go

EXEC usp_AccpacCreateSelectField 'PRRating', 'prra_UpgradeDowngrade', 'Upgrade/Downgrade', 'prra_UpgradeDowngrade'

EXEC usp_AddCustom_Screens 'PRRatingNewEntry', 10, 'prra_CompanyId', 1, 1, 3
EXEC usp_AddCustom_Screens 'PRRatingNewEntry', 20, 'prra_Date', 1, 1, 1
EXEC usp_AddCustom_Screens 'PRRatingNewEntry', 30, 'prra_Current', 0, 1, 1
EXEC usp_AddCustom_Screens 'PRRatingNewEntry', 40, 'prra_Rated', 0, 1, 1
EXEC usp_AddCustom_Screens 'PRRatingNewEntry', 50, 'prra_UpgradeDowngrade', 1, 1, 1
EXEC usp_AddCustom_Screens 'PRRatingNewEntry', 60, 'prra_InternalAnalysis', 1, 1, 3
EXEC usp_AddCustom_Screens 'PRRatingNewEntry', 70, 'prra_PublishedAnalysis', 1, 1, 3
Go


EXEC usp_AccpacGetBlockInfo 'PRCompanyProfile'

EXEC usp_AccpacCreateCheckboxField 'PRCompanyProfile', 'prcp_FoodSafetyCertified', 'Food Safety Certified'
EXEC usp_AddCustom_Screens 'PRCompanyProfile', 1500, 'prcp_Organic',  1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCompanyProfile', 1510, 'prcp_FoodSafetyCertified',  0, 1, 1, 0

EXEC usp_DeleteCustom_Screen 'PRCompanyProfile', 'prcp_HAACP'
EXEC usp_DeleteCustom_Screen 'PRCompanyProfile', 'prcp_HAACPCertifiedBy'
EXEC usp_DeleteCustom_Screen 'PRCompanyProfile', 'prcp_QTV'
EXEC usp_DeleteCustom_Screen 'PRCompanyProfile', 'prcp_QTVCertifiedBy'
EXEC usp_DeleteCustom_Screen 'PRCompanyProfile', 'prcp_OrganicCertifiedBy'
EXEC usp_DeleteCustom_Screen 'PRCompanyProfile', 'prcp_OtherCertification'

UPDATE custom_captions SET capt_US = 'Certified Organic' WHERE capt_code = 'prcp_Organic' AND capt_Family = 'ColNames'
Go

EXEC usp_AccpacCreateSelectField 'PRWebUser', 'prwu_LocalSourceSearch', 'Local Source Data', 'BBOSSearchLocalSoruce'
Go


EXEC usp_AddCustom_Screens 'PRAdCampaignPUB', 41, 'pradc_Placement', 1, 1, 1
EXEC usp_AddCustom_Screens 'PRAdCampaignPUB', 42, 'pradc_Premium', 0, 1, 1
EXEC usp_AddCustom_Screens 'PRAdCampaignPUB', 43, 'pradc_CreativeStatus', 1, 1, 1
Go

EXEC usp_DeleteCustom_ScreenObject 'PRBBScoreLumberGrid'
EXEC usp_AddCustom_ScreenObjects 'PRBBScoreLumberGrid', 'List', 'PRBBscore', 'N', 0, 'vPRBBScoreLumber'
EXEC usp_AddCustom_Lists 'PRBBScoreLumberGrid', 10, 'prbs_Date', null, 'Y'
EXEC usp_AddCustom_Lists 'PRBBScoreLumberGrid', 20, 'Model1Score', null, 'Y'
EXEC usp_AddCustom_Lists 'PRBBScoreLumberGrid', 30, 'Model2Score', null, 'Y'

 exec usp_AccpacCreateField @EntityName = 'PRBBscore', 
                             @FieldName = 'Model1Score', 
                             @Caption = 'Model 1 Score',
                             @AccpacEntryType = 31,
                             @AccpacEntrySize = 10,
                             @DBFieldType = 'int',
                             @DBFieldSize = NULL,
                             @AllowNull = 'Y',
                             @IsRequired = 'N', 
                             @AllowEdit = 'Y', 
                             @IsUnique = 'N',
							 @SkipColumnCreation = 'Y'

exec usp_AccpacCreateField @EntityName = 'PRBBscore', 
                             @FieldName = 'Model2Score', 
                             @Caption = 'Model 2 Score',
                             @AccpacEntryType = 31,
                             @AccpacEntrySize = 10,
                             @DBFieldType = 'int',
                             @DBFieldSize = NULL,
                             @AllowNull = 'Y',
                             @IsRequired = 'N', 
                             @AllowEdit = 'Y', 
                             @IsUnique = 'N',
							 @SkipColumnCreation = 'Y'
Go


ALTER TABLE PRCreditSheet ALTER COLUMN prcs_Parenthetical varchar(1000)
Go

UPDATE Custom_screens
  SET SeaP_Required = 'Y'
WHERE seap_ColName = 'comm_Subject'
  AND SeaP_SearchBoxName IN ('CustomCommunicationDetailBox', 'PRCreateInteraction')
Go