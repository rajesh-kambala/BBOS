EXEC usp_AccpacDropTable 'PRCreditSheetBatch'
EXEC usp_AccpacCreateTable @EntityName='PRCreditSheetBatch', @ColPrefix='prcsb', @IDField='prcsb_CreditSheetBatchID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyField          'PRCreditSheetBatch', 'prcsb_CreditSheetBatchID', 'Credit Sheet Batch ID'
EXEC usp_AccpacCreateSelectField       'PRCreditSheetBatch', 'prcsb_TypeCode', 'Type Code', 'prcsb_TypeCode'
EXEC usp_AccpacCreateSelectField       'PRCreditSheetBatch', 'prcsb_StatusCode', 'Status Code', 'prcsb_StatusCode'
EXEC usp_AccpacCreateDateTimeField     'PRCreditSheetBatch', 'prcsb_ReportDateTime', 'Report Date Time'
EXEC usp_AccpacCreateDateTimeField     'PRCreditSheetBatch', 'prcsb_StartDateTime', 'Start Date Time'
EXEC usp_AccpacCreateDateTimeField     'PRCreditSheetBatch', 'prcsb_EndDateTime', 'End Date Time'
EXEC usp_AccpacCreateIntegerField      'PRCreditSheetBatch', 'prcsb_EmailCount', 'Email Count'
EXEC usp_AccpacCreateIntegerField      'PRCreditSheetBatch', 'prcsb_FaxCount', 'Fax Count'
EXEC usp_AccpacCreateTextField         'PRCreditSheetBatch', 'prcsb_ReportHdr', 'Report Message Header', 100, 100
EXEC usp_AccpacCreateTextField         'PRCreditSheetBatch', 'prcsb_ReportMsg', 'Report Message', 100, 500
EXEC usp_AccpacCreateTextField         'PRCreditSheetBatch', 'prcsb_EmailImgURL', 'Email Image', 100, 500
EXEC usp_AccpacCreateTextField         'PRCreditSheetBatch', 'prcsb_EmailURL', 'Email URL', 100, 500
EXEC usp_AccpacCreateCheckboxField     'PRCreditSheetBatch', 'prcsb_Test', 'Test'
EXEC usp_AccpacCreateTextField         'PRCreditSheetBatch', 'prcsb_TestLogons', 'Test Logons', 100, 100
Go

--DELETE FROM Custom_Captions WHERE capt_family = 'PRCompanyCSImageDirectory'
--EXEC usp_AddCustom_Captions 'Choices', 'PRCompanyCSImageDirectory', '/Campaigns/CS', 0, 'C:\temp\CS'
 
                                                    
EXEC usp_AccpacCreateSelectField    'Person_Link', 'peli_PRCSReceiveMethod', 'Credit Sheet Receive Method', 'peli_PRCSReceiveMethod'
EXEC usp_AccpacCreateSelectField	'Person_Link', 'peli_PRCSSortOption', 'Credit Sheet Sort Option', 'peli_PRCSSortOption'
Go



EXEC usp_DeleteCustom_ScreenObject 'PRPersonLinkHistory'
EXEC usp_AddCustom_ScreenObjects 'PRPersonLinkHistory', 'Screen', 'Person_Link', 'N', 0, 'Person_Link'
EXEC usp_AddCustom_Screens 'PRPersonLinkHistory', 10, 'peli_CompanyId',           1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRPersonLinkHistory', 20, 'peli_PRStatus',		      0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRPersonLinkHistory', 30, 'peli_PRTitleCode',         1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRPersonLinkHistory', 40, 'peli_PRBRPublish',         0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRPersonLinkHistory', 50, 'peli_PRTitle',             1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRPersonLinkHistory', 60, 'peli_PREBBPublish',        0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRPersonLinkHistory', 70, 'peli_PRDLTitle',	          1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRPersonLinkHistory', 80, 'peli_PRStartDate',   	  1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRPersonLinkHistory', 90, 'peli_PROwnershipRole',     1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRPersonLinkHistory', 100, 'peli_PREndDate',		  0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRPersonLinkHistory', 110, 'peli_PRPctOwned',	      1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRPersonLinkHistory', 120, 'peli_PRExitReason',	      0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRPersonLinkHistory', 130, 'peli_PRRole',		      1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRPersonLinkHistory', 140, 'peli_PRWhenVisited',	  0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRPersonLinkHistory', 150, 'peli_PRResponsibilities', 1, 1, 1, 0

EXEC usp_DeleteCustom_ScreenObject 'PRPersonLinkUpdateSettings'
EXEC usp_AddCustom_ScreenObjects 'PRPersonLinkUpdateSettings', 'Screen', 'Person_Link', 'N', 0, 'Person_Link'
EXEC usp_AddCustom_Screens 'PRPersonLinkUpdateSettings', 10, 'peli_PRCSReceiveMethod',      1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRPersonLinkUpdateSettings', 20, 'peli_PRAUSReceiveMethod',	    0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRPersonLinkUpdateSettings', 30, 'peli_PRCSSortOption',         1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRPersonLinkUpdateSettings', 40, 'peli_PRAUSChangePreference',  0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRPersonLinkUpdateSettings', 50, 'peli_PRReceivesCreditSheetReport', 1, 1, 1, 0


EXEC usp_DeleteCustom_ScreenObject 'PRPersonLinkMembershipSettings'
EXEC usp_AddCustom_ScreenObjects 'PRPersonLinkMembershipSettings', 'Screen', 'Person_Link', 'N', 0, 'Person_Link'
EXEC usp_AddCustom_Screens 'PRPersonLinkMembershipSettings', 10, 'peli_PRSubmitTES',             1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRPersonLinkMembershipSettings', 20, 'peli_PRReceivesTrainingEmail', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRPersonLinkMembershipSettings', 30, 'peli_PRUseServiceUnits',       1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRPersonLinkMembershipSettings', 40, 'peli_PRReceivesPromoEmail',    0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRPersonLinkMembershipSettings', 50, 'peli_PRUpdateCL',              1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRPersonLinkMembershipSettings', 60, 'peli_PRReceiveBRSurvey',	     0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRPersonLinkMembershipSettings', 70, 'peli_PRUseSpecialServices',    1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRPersonLinkMembershipSettings', 80, 'peli_PRReceivesBBScoreReport', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRPersonLinkMembershipSettings', 90, 'peli_PREditListing',           1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRPersonLinkMembershipSettings', 100, 'peli_PRWillSubmitARAging',    1, 1, 1, 0
Go


EXEC usp_AccpacCreateTextField         'PRCommunicationLog', 'prcoml_TranslatedFaxID', 'Translated Fax ID', 50, 50
EXEC usp_AccpacCreateCheckboxField     'PRCommunicationLog', 'prcoml_Failed', 'Failed'
EXEC usp_AccpacCreateTextField         'PRCommunicationLog', 'prcoml_FailedMessage', 'Failed Message', 100, 500
EXEC usp_AccpacCreateTextField         'PRCommunicationLog', 'prcoml_Destination', 'Destination', 100, 500
EXEC usp_AccpacCreateSelectField       'PRCommunicationLog', 'prcoml_FailedCategory', 'Failed Category', 'prcoml_FailedCategory'
Go

EXEC usp_AccpacCreateMultilineField 'Company', 'comp_PRTradeActivityNotes', 'Trade Activity Notes', 150, 10
Go

EXEC usp_DeleteCustom_ScreenObject 'PRTradeActivityNotes'
EXEC usp_AddCustom_ScreenObjects 'PRTradeActivityNotes', 'Screen', 'Company', 'N', 0, 'Company'
EXEC usp_AddCustom_Screens 'PRTradeActivityNotes', 10, 'comp_PRTradeActivityNotes', 1, 1, 1, 0
Go


UPDATE Custom_Edits SET colp_EntrySize = 25 WHERE colp_ColName IN ('pril_Fax', 'pril_Email', 'pril_WebAddress')
Go


EXEC usp_AccpacCreateCurrencyField 'PRAdCampaign', 'pradc_TermsAmt', 'Terms Amount'
EXEC usp_AddCustom_Screens 'PRAdCampaignBP', 195, 'pradc_TermsAmt', 0, 1, 1, 0
Go


UPDATE Custom_ScreenObjects
   SET cobj_TargetTable = 'vPRPACALicense'
 WHERE cobj_Name = 'PRPACALicenseGrid';

EXEC usp_AddCustom_Lists 'PRPACALicenseGrid', 65, 'comp_PRListingStatus', null, 'Y'
Go