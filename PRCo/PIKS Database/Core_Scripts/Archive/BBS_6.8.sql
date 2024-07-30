USE CRM

EXEC usp_AccpacCreateTextField 'users', 'user_FaxUserID', 'Fax User ID', 30, 30
EXEC usp_AccpacCreateTextField 'users', 'user_FaxPassword', 'Fax Password', 30, 30

EXEC usp_AddCustom_Screens 'UserAdminExtraBox', 10, 'user_FaxUserID',             1, 1, 1, 0
EXEC usp_AddCustom_Screens 'UserAdminExtraBox', 10, 'user_FaxPassword',             1, 1, 1, 0

EXEC usp_AccpacCreateTextField 'PRCommunicationLog', 'prcoml_FaxID', 'Fax ID', 30, 30
EXEC usp_AccpacCreateTextField 'PRCommunicationLog', 'prcoml_FaxStatus', 'Fax Status', 100, 100
Go


EXEC usp_AccpacCreateCheckboxField     'PRCompanyProfile', 'prcp_SalvageDistressedProduce', 'Salvages Distressed Produce on behalf of others'
EXEC usp_AddCustom_Screens 'PRCompanyProfile', 290, 'prcp_SrcTakePhysicalPossessionPct', 1, 1, 2, 0
EXEC usp_AddCustom_Screens 'PRCompanyProfile', 295, 'prcp_SalvageDistressedProduce', 0, 1, 2, 0

EXEC usp_AccpacCreateSelectField       'PRCompanyProfile', 'prcp_StorageOwnLease', 'Own or Lease Warehousing', 'prcp_StorageOwnLease'
EXEC usp_AddCustom_Screens 'PRCompanyProfile', 1325, 'prcp_StorageOwnLease', 0, 1, 2, 0

EXEC usp_DeleteCustom_Screen 'PRCompanyProfile', 'prcp_ColdStorage'
EXEC usp_DeleteCustom_Screen 'PRCompanyProfile', 'prcp_RipeningStorage'
EXEC usp_DeleteCustom_Screen 'PRCompanyProfile', 'prcp_StorageCF'
EXEC usp_DeleteCustom_Screen 'PRCompanyProfile', 'prcp_HumidityStorage'
EXEC usp_DeleteCustom_Screen 'PRCompanyProfile', 'prcp_StorageBushel'
EXEC usp_DeleteCustom_Screen 'PRCompanyProfile', 'prcp_AtmosphereStorage'
EXEC usp_DeleteCustom_Screen 'PRCompanyProfile', 'prcp_StorageCarlots'
EXEC usp_DeleteCustom_Screen 'PRCompanyProfile', 'prcp_ColdStorageLeased'
EXEC usp_DeleteCustom_Screen 'PRCompanyProfile', 'prcp_SellBuyOthers'
EXEC usp_DeleteCustom_Screen 'PRCompanyProfile', 'prcp_TrkrTeams'
EXEC usp_DeleteCustom_Screen 'PRCompanyProfile', 'prcp_TrnBkrCollectsFrom'
EXEC usp_DeleteCustom_Screen 'PRCompanyProfile', 'prcp_TrnBkrAdvPaymentsToCarrier'

EXEC usp_AccpacGetBlockInfo 'PRCompanyProfile'                                           
         

--SELECT * FROM custom_captions WHERE capt_code = 'prcp_SellWholesalePct'
UPDATE custom_captions 
   SET capt_us = 'Sell Locally %', capt_uk = 'Sell Locally %', capt_es = 'Sell Locally %', capt_fr = 'Sell Locally %', capt_de = 'Sell Locally %' 
 WHERE capt_code = 'prcp_SellWholesalePct'

EXEC usp_AddCustom_Screens 'PRCompanyProfile', 341, 'prcp_SellDomesticBuyersPct', 1, 1, 2, 0
EXEC usp_AddCustom_Screens 'PRCompanyProfile', 342, 'prcp_SellExportersPct', 1, 1, 2, 0

EXEC usp_AccpacCreateIntegerField 'PRCompanyProfile', 'prcp_SellBuyOthersPct', 'Buy from other shippers or growers %', 10
EXEC usp_AddCustom_Screens 'PRCompanyProfile', 343, 'prcp_SellBuyOthersPct', 1, 1, 2, 0

EXEC usp_AccpacCreateIntegerField 'PRCompanyProfile', 'prcp_GrowsOwnProducePct', 'Grows Own Product %', 10
EXEC usp_AddCustom_Screens 'PRCompanyProfile', 344, 'prcp_GrowsOwnProducePct', 1, 1, 2, 0

EXEC usp_AddCustom_Screens 'PRCompanyProfile', 330, 'prcp_SellDomesticAccountTypes', 0, 6, 2, 0

UPDATE custom_captions 
   SET capt_us = 'Sell to International Importers %', capt_uk = 'Sell to International Importers %', capt_es = 'Sell to International Importers %', capt_fr = 'Sell to International Importers %', capt_de = 'Sell to International Importers %' 
 WHERE capt_code = 'prcp_SellExportersPct'
Go


EXEC usp_AddCustom_Lists 'PRSubjectCompanyHasOwnership', 12, 'RightListingStatus', null, 'Y'
EXEC usp_AddCustom_Lists 'PRSubjectCompanyHasOwnership', 14, 'RightRating', null, null

EXEC usp_AddCustom_Lists 'PRSubjectCompanyOwnedBy', 12, 'LeftListingStatus', null, 'Y'
EXEC usp_AddCustom_Lists 'PRSubjectCompanyOwnedBy', 14, 'LeftRating', null, null

EXEC usp_AddCustom_Lists 'PRSubjectCompanyAffiliations', 12, 'comp_PRListingStatus', null, 'Y'
EXEC usp_AddCustom_Lists 'PRSubjectCompanyAffiliations', 14, 'prra_RatingLine', null, null


EXEC usp_AddCustom_Captions  'Tags' , 'ColNames', 'RightListingStatus', 0, 'Listing Status'
EXEC usp_AddCustom_Captions  'Tags' , 'ColNames', 'RightRating', 0, 'Rating'
EXEC usp_AddCustom_Captions  'Tags' , 'ColNames', 'LeftListingStatus', 0, 'Listing Status'
EXEC usp_AddCustom_Captions  'Tags' , 'ColNames', 'LeftRating', 0, 'Rating'
Go


EXEC usp_DeleteCustom_Screen 'PRCompanyInfo', 'comp_PRBusinessReport'
EXEC usp_DeleteCustom_Screen 'PRCompanyInfo', 'comp_PRPrincipalsBackgroundText'
EXEC usp_DeleteCustom_Screen 'PRCompanyInfo', 'comp_PRTradeAssociationLogo'

EXEC usp_DeleteCustom_ScreenObject 'PRPeopleBackground'
EXEC usp_AddCustom_ScreenObjects 'PRPeopleBackground', 'Screen', 'Company', 'N', 0, 'Company'
EXEC usp_AddCustom_Screens 'PRPeopleBackground', 10, 'comp_PRPrincipalsBackgroundText',      1, 1, 1, 0



UPDATE custom_captions 
   SET capt_us = 'Original Background Text Migrated from Old BB System', capt_uk = 'Original Background Text Migrated from Old BB System', capt_es = 'Original Background Text Migrated from Old BB System', capt_fr = 'Original Background Text Migrated from Old BB System', capt_de = 'Original Background Text Migrated from Old BB System' 
 WHERE capt_code = 'comp_PRPrincipalsBackgroundText'

UPDATE custom_captions 
SET capt_us = 'Date Time Terms Accepted By', capt_uk = 'Date Time Terms Accepted By', capt_es = 'Date Time Terms Accepted By', capt_fr = 'Date Time Terms Accepted By', capt_de = 'Date Time Terms Accepted By' 
WHERE capt_code = 'comp_PREBBTermsAcceptedBy'
Go



EXEC usp_AccpacCreateSelectField 'PRPublicationArticle', 'prpbar_CommunicationLanguage', 'Language', 'comp_PRCommunicationLanguage'
EXEC usp_AddCustom_Screens 'PRPublicationArticleEntry', 70, 'prpbar_CommunicationLanguage',      1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRPublicationArticleEntry', 80, 'prpbar_CategoryCode',      1, 1, 1, 0
Go