--8.3 Release
USE CRM

--DEFECT 4403
EXEC usp_DeleteCustom_Tab 'find','News Articles'
EXEC usp_DeleteCustom_Tab 'Find','Dow Jones Company' 
Go
 
EXEC usp_AccpacCreateTextField 'PRImportPACAPrincipal', 'prip_Title', 'Title', 50, 500
EXEC usp_AccpacCreateTextField 'PRPACAPrincipal', 'prpp_Title', 'Title', 50, 500
Go

--***************    AD REFACTORING -- BEGIN DATA MODEL  *****************************
DROP TABLE IF EXISTS PRAdCampaignBackup
SELECT * INTO PRAdCampaignBackup FROM PRAdCampaign;
Go

EXEC usp_AccpacDropTable               'PRAdCampaignHeader'
EXEC usp_AccpacCreateTable			   'PRAdCampaignHeader', 'pradch', 'pradch_AdCampaignHeaderID'
EXEC usp_AccpacCreateKeyField          'PRAdCampaignHeader', 'pradch_AdCampaignHeaderID', 'Ad Campaign Header ID'
EXEC usp_AccpacCreateSearchSelectField 'PRAdCampaignHeader', 'pradch_HQID', 'Company', 'Company', 50 
EXEC usp_AccpacCreateSearchSelectField 'PRAdCampaignHeader', 'pradch_CompanyID', 'Company', 'Company', 50 
EXEC usp_AccpacCreateTextField         'PRAdCampaignHeader', 'pradch_Name', 'Name', 50, 50
EXEC usp_AccpacCreateTextField         'PRAdCampaignHeader', 'pradch_AltTradeName', 'Advertising Trade Name', 50, 104
EXEC usp_AccpacCreateSelectField       'PRAdCampaignHeader', 'pradch_TypeCode', 'Ad Campaign Type', 'pradch_TypeCode'
EXEC usp_AccpacCreateSearchSelectField 'PRAdCampaignHeader', 'pradch_ApprovedByPersonID', 'Approved By', 'Person', 50 
EXEC usp_AccpacCreateUserSelectField   'PRAdCampaignHeader', 'pradch_SoldBy', 'Sold By'
EXEC usp_AccpacCreateDateField		   'PRAdCampaignHeader', 'pradch_SoldDate', 'Sold Date'
EXEC usp_AccpacCreateNumericField     'PRAdCampaignHeader', 'pradch_Cost', 'Cost Amount', 10
EXEC usp_AccpacCreateNumericField     'PRAdCampaignHeader', 'pradch_Discount', 'Discount Amount', 10
EXEC usp_AccpacCreateCheckboxField     'PRAdCampaignHeader', 'pradch_ReceivedSignedAgreement', 'Received Signed Agreement'
EXEC usp_AccpacCreateDateField		   'PRAdCampaignHeader', 'pradch_ReceivedSignedAgreementDate', 'Received Signed Agreement Date'
EXEC usp_AccpacCreateCheckboxField     'PRAdCampaignHeader', 'pradch_Renewal', 'Renewal'
EXEC usp_AccpacCreateCheckboxField     'PRAdCampaignHeader', 'pradch_Terms', 'Terms'
EXEC usp_AccpacCreateTextField         'PRAdCampaignHeader', 'pradch_TermsDescription', 'Terms Description', 50, 100
EXEC usp_AccpacCreateMultilineField	   'PRAdCampaignHeader', 'pradch_Notes', 'Notes (Not Placement Instructions)'
Go

EXEC usp_AccpacCreateIntegerField      'PRAdCampaign', 'pradc_AdCampaignHeaderID', 'Ad Campaign Header ID'
Go

EXEC usp_AccpacCreateDateField      'PRAdCampaignTerms', 'pract_InvoiceDate', 'Invoice Date', 'Y', 'N'
EXEC usp_AccpacCreateDateField      'PRAdCampaignTerms', 'pract_BillingDate', 'Billing Date', 'Y', 'N'
EXEC usp_AccpacCreateTextField      'PRAdCampaignTerms', 'pract_OrderNumber', 'Order Number', 15
EXEC usp_AccpacCreateCheckboxField  'PRAdCampaignTerms', 'pract_Processed', 'Processed'
EXEC usp_AccpacCreateIntegerField  'PRAdCampaignTerms', 'pract_AdCampaignHeaderID', 'Ad Campaign Header ID'
EXEC usp_AccpacCreateTextField      'PRAdCampaignTerms', 'pract_InvoiceDescription', 'Invoice Description', 30, 30

Go

EXEC usp_AccpacDropTable               'PRAdCampaignFile'
EXEC usp_AccpacCreateTable						'PRAdCampaignFile', 'pracf', 'pracf_AdCampaignFileID'
EXEC usp_AccpacCreateKeyField          'PRAdCampaignFile', 'pracf_AdCampaignFileID', 'Ad Campaign File ID'
EXEC usp_AccpacCreateSearchSelectField 'PRAdCampaignFile', 'pracf_AdCampaignID', 'Ad Campaign', 'PRAdCampaign', 50 
EXEC usp_AccpacCreateSelectField       'PRAdCampaignFile', 'pracf_FileTypeCode', 'File Type', 'pracf_FileTypeCode'
EXEC usp_AccpacCreateTextField         'PRAdCampaignFile', 'pracf_FileName', 'File Name', 50, 500
EXEC usp_AccpacCreateIntegerField			'PRAdCampaignFile', 'pracf_Sequence', 'Sequence'
EXEC usp_AccpacCreateSelectField       'PRAdCampaignFile', 'pracf_Language', 'Language', 'comp_PRCommunicationLanguage'
Go

EXEC usp_AccpacDropTable								'PRKYCCommodity'
EXEC usp_AccpacCreateTable							'PRKYCCommodity', 'prkycc', 'prkycc_KYCCommodityID'
EXEC usp_AccpacCreateKeyField						'PRKYCCommodity', 'prkycc_KYCCommodityID', 'KYC Commodity ID'
EXEC usp_AccpacCreateIntegerField				'PRKYCCommodity', 'prkycc_ArticleID', 'Article ID'
EXEC usp_AccpacCreateTextField					'PRKYCCommodity', 'prkycc_PostName', 'Post Name', 50, 1000
EXEC usp_AccpacCreateIntegerField				'PRKYCCommodity', 'prkycc_CommodityID', 'Commodity ID'
EXEC usp_AccpacCreateIntegerField				'PRKYCCommodity', 'prkycc_AttributeID', 'Attribute ID'
EXEC usp_AccpacCreateIntegerField				'PRKYCCommodity', 'prkycc_GrowingMethodID', 'Growing Method ID'
EXEC usp_AccpacCreateCheckboxField			'PRKYCCommodity', 'prkycc_HasAd', 'Has Ad'
Go

--Remove deprecated fields
EXEC usp_AccpacDropField 'PRAdCampaign', 'pradc_HQID'

   --EXEC usp_AccpacDropField 'PRAdCampaign', 'pradc_CompanyID' --keeping this for now -- DO NOT EXECUTE -- too many reports use it
   --EXEC usp_AccpacDropField 'PRAdCampaign', 'pradc_Name' -- KEEPING BP, Digital both have separate name field apart from header name, and this field reused for that

EXEC usp_AccpacDropField 'PRAdCampaign', 'pradc_AltTradeName' 
EXEC usp_AccpacDropField 'PRAdCampaign', 'pradc_ApprovedByPersonID'
EXEC usp_AccpacDropField 'PRAdCampaign', 'pradc_SoldBy'
EXEC usp_AccpacDropField 'PRAdCampaign', 'pradc_SoldDate'
EXEC usp_AccpacDropField 'PRAdCampaign', 'pradc_Renewal'

		--EXEC usp_AccpacDropField 'PRAdCampaign', 'pradc_Cost' -- DO NOT REMOVE
		--EXEC usp_AccpacDropField 'PRAdCampaign', 'pradc_Discount' -- DO NOT REMOVE

EXEC usp_AccpacDropField 'PRAdCampaign', 'pradc_Terms'
EXEC usp_AccpacDropField 'PRAdCampaign', 'pradc_TermsDescription'
EXEC usp_AccpacDropField 'PRAdCampaign', 'pradc_TermsAmt'
EXEC usp_AccpacDropField 'PRAdCampaign', 'pradc_AdImageName'

EXEC usp_AccpacDropTable 'PRAdCampaignPage'
EXEC usp_AccpacDropTable 'PRAdEligiblePage'

Go

--***************    AD REFACTORING -- END DATA MODEL  *****************************

--***************    AD REFACTORING -- BEGIN JMT CUSTOM CHANGES  *****************************
UPDATE Custom_Tabs SET Tabs_CustomFileName = 'PRAdvertising/CompanyAdvertisementListing.asp' WHERE Tabs_CustomFileName = 'PRCompany/PRCompanyAdvertismentListing.asp'

--Define Captions
EXEC usp_DefineCaptions 'PRAdCampaignCaptions', 'Ad Campaign', 'Ad Campaigns', NULL, NULL, NULL, NULl
EXEC usp_DefineCaptions 'PRAdvertisementCaptions', 'Advertisement', 'Advertisements', NULL, NULL, NULL, NULl

EXEC usp_DeleteCustom_List 'PRAdCampaignHeaderGrid'
EXEC usp_DeleteCustom_ScreenObject 'PRAdCampaignHeaderGrid'
EXEC usp_AddCustom_ScreenObjects 'PRAdCampaignHeaderGrid', 'List', 'PRAdCampaignHeader', 'N', 0, 'vPRAdCampaignHeaderGrid'
EXEC usp_AddCustom_Lists 'PRAdCampaignHeaderGrid', 10, 'pradch_CreatedDate', null, 'Y', 'Y', @Jump='Custom', @CustomAction='PRAdvertising/AdCampaignBP.asp', @CustomIdField='pradch_AdCampaignHeaderID'
--EXEC usp_AddCustom_Lists 'PRAdCampaignHeaderGrid', 10, 'pradch_CreatedDate', null, 'Y', 'Y', @Jump='Custom', @CustomAction='PRAdvertising/CompanyAdvertisement.asp', @CustomIdField='pradch_AdCampaignHeaderID'
EXEC usp_AddCustom_Lists 'PRAdCampaignHeaderGrid', 20, 'pradch_SoldDate', null, 'Y'
EXEC usp_AddCustom_Lists 'PRAdCampaignHeaderGrid', 30, 'pradch_Name', null, 'Y'
EXEC usp_AddCustom_Lists 'PRAdCampaignHeaderGrid', 40, 'pradch_TypeCode', null, 'Y'
EXEC usp_AddCustom_Lists 'PRAdCampaignHeaderGrid', 50, 'pradch_SoldBy', null, 'Y'

EXEC usp_DeleteCustom_List 'PRAdCampaignHeaderGridFilter'
EXEC usp_AddCustom_ScreenObjects 'PRAdCampaignHeaderGridFilter', 'SearchScreen', 'Cases', 'N', 0, 'PRAdCampaignHeader' --was 'vPRAdCampaign'
EXEC usp_AddCustom_Screens 'PRAdCampaignHeaderGridFilter', 10, 'pradch_CreatedDate', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRAdCampaignHeaderGridFilter', 20, 'pradch_SoldDate', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRAdCampaignHeaderGridFilter', 30, 'pradch_TypeCode', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRAdCampaignHeaderGridFilter', 40, 'pradch_SoldBy', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRAdCampaignHeaderGridFilter', 50, 'pradc_StartDate', 1, 1, 1, 0

EXEC usp_DeleteCustom_ScreenObject 'AdCampaignHeader'
EXEC usp_AddCustom_ScreenObjects 'AdCampaignHeader', 'Screen', 'PRAdCampaignHeader', 'N', 0, 'PRAdCampaignHeader'
EXEC usp_AddCustom_Screens 'AdCampaignHeader', 10, 'pradch_Name', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignHeader', 20, 'pradch_AltTradeName', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignHeader', 30, 'pradch_TypeCode', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignHeader', 40, 'pradch_ApprovedByPersonID', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignHeader', 50, 'pradch_SoldBy', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignHeader', 60, 'pradch_SoldDate', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignHeader', 70, 'pradch_Cost', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignHeader', 80, 'pradch_Discount', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignHeader', 90, 'pradch_ReceivedSignedAgreement', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignHeader', 100, 'pradch_ReceivedSignedAgreementDate', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignHeader', 110, 'pradch_Renewal', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignHeader', 120, 'pradch_Terms', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignHeader', 130, 'pradch_TermsDescription', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignHeader', 140, 'pradch_Notes', 1, 1, 2, 0
EXEC usp_AddCustom_Screens 'AdCampaignHeader', 150, 'pradch_CompanyId', 1, 1, 1, 0

EXEC usp_DeleteCustom_ScreenObject 'AdCampaignBP'
EXEC usp_AddCustom_ScreenObjects 'AdCampaignBP', 'Screen', 'PRAdCampaign', 'N', 0, 'PRAdCampaign'
EXEC usp_AddCustom_Screens 'AdCampaignBP', 10, 'pradch_Name', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignBP', 20, 'pradch_AltTradeName', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignBP', 30, 'pradch_TypeCode', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignBP', 40, 'pradch_ApprovedByPersonID', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignBP', 50, 'pradch_SoldBy', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignBP', 60, 'pradch_SoldDate', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignBP', 70, 'pradch_Cost', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignBP', 80, 'pradch_Discount', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignBP', 90, 'pradch_ReceivedSignedAgreement', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignBP', 100, 'pradch_ReceivedSignedAgreementDate', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignBP', 110, 'pradch_Renewal', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignBP', 120, 'pradch_Terms', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignBP', 130, 'pradch_TermsDescription', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignBP', 140, 'pradch_Notes', 1, 1, 2, 0

EXEC usp_DeleteCustom_ScreenObject 'AdCampaignAdHeader'
EXEC usp_AddCustom_ScreenObjects 'AdCampaignAdHeader', 'Screen', 'PRAdCampaignHeader', 'N', 0, 'PRAdCampaignHeader'
EXEC usp_AddCustom_Screens 'AdCampaignAdHeader', 10, 'pradch_Name', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdHeader', 20, 'pradch_TypeCode', 0, 1, 1, 0

EXEC usp_DeleteCustom_ScreenObject 'AdCampaignHeaderTerms'
EXEC usp_AddCustom_ScreenObjects 'AdCampaignHeaderTerms', 'Screen', 'PRAdCampaignHeader', 'N', 0, 'PRAdCampaignHeader'
EXEC usp_AddCustom_Screens 'AdCampaignHeaderTerms', 10, 'pradch_Name', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignHeaderTerms', 20, 'pradch_TypeCode', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignHeaderTerms', 30, 'pradch_Cost', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignHeaderTerms', 40, 'pradch_Discount', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignHeaderTerms', 50, 'pradch_Terms', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignHeaderTerms', 60, 'pradch_TermsDescription', 0, 1, 1, 0

--Rename field, add field
EXEC usp_AccpacRenameField 'PRAdCampaign', 'pradc_ContentSourceContactVia', 'pradc_ContentSourceContactName', 'Content Source Contact Name'
EXEC usp_AccpacCreateTextField 'PRAdCampaign', 'pradc_ContentSourceContactInfo', 'Content Source Contact Info', 100, 200

--AdCampaignAdBP
EXEC usp_DeleteCustom_ScreenObject 'AdCampaignAdBP'
EXEC usp_AddCustom_ScreenObjects 'AdCampaignAdBP', 'Screen', 'PRAdCampaign', 'N', 0, 'PRAdCampaign'
EXEC usp_AddCustom_Screens 'AdCampaignAdBP', 1, 'pradc_CompanyID', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdBP', 3, 'pradc_AdCampaignHeaderID', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdBP', 5, 'pradc_AdCampaignType', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdBP', 10, 'pradc_Name', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdBP', 20, 'pradc_BluePrintsEdition', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdBP', 30, 'pradc_CreativeStatus', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdBP', 40, 'pradc_Section', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdBP', 50, 'pradc_PlannedSection', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdBP', 60, 'pradc_AdSize', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdBP', 70, 'pradc_Orientation', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdBP', 80, 'pradc_AdColor', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdBP', 90, 'pradc_SectionDetailsCode', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdBP', 100, 'pradc_SectionDetails', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdBP', 110, 'pradc_Placement', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdBP', 120, 'pradc_Premium', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdBP', 130, 'pradc_PlacementInstructions', 0, 1, 3, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdBP', 140, 'pradc_ContentSourceRequest', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdBP', 150, 'pradc_ContentSourceRequestDate', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdBP', 160, 'pradc_ContentSourceContactName', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdBP', 170, 'pradc_ContentSourceContactInfo', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdBP', 180, 'pradc_Cost', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdBP', 190, 'pradc_Discount', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdBP', 200, 'pradc_Notes', 1, 1, 2, 0


--AdCampaignAdDigital
EXEC usp_DeleteCustom_ScreenObject 'AdCampaignAdDigital'
EXEC usp_AddCustom_ScreenObjects 'AdCampaignAdDigital', 'Screen', 'PRAdCampaign', 'N', 0, 'PRAdCampaign'
EXEC usp_AddCustom_Screens 'AdCampaignAdDigital', 1, 'pradc_CompanyID', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdDigital', 3, 'pradc_AdCampaignHeaderID', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdDigital', 5, 'pradc_AdCampaignType', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdDigital', 10, 'pradc_Name', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdDigital', 20, 'pradc_StartDate', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdDigital', 30, 'pradc_AdCampaignTypeDigital', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdDigital', 40, 'pradc_EndDate', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdDigital', 50, 'pradc_CreativeStatus', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdDigital', 60, 'pradc_TargetURL', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdDigital', 65, 'pradc_Sequence', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdDigital', 70, 'pradc_Cost', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdDigital', 80, 'pradc_Discount', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdDigital', 90, 'pradc_IndustryType', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdDigital', 100, 'pradc_Language', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdDigital', 110, 'pradc_Notes', 1, 1, 2, 0


--AdCampaignAdTT
EXEC usp_DeleteCustom_ScreenObject 'AdCampaignAdTT'
EXEC usp_AddCustom_ScreenObjects 'AdCampaignAdTT', 'Screen', 'PRAdCampaign', 'N', 0, 'PRAdCampaign'
EXEC usp_AddCustom_Screens 'AdCampaignAdTT', 1, 'pradc_CompanyID', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdTT', 3, 'pradc_AdCampaignHeaderID', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdTT', 4, 'pradc_Name', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdTT', 5, 'pradc_AdCampaignType', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdTT', 10, 'pradc_TTEdition', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdTT', 20, 'pradc_CreativeStatus', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdTT', 30, 'pradc_Placement', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdTT', 40, 'pradc_Premium', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdTT', 60, 'pradc_AdSize', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdTT', 70, 'pradc_Cost', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdTT', 80, 'pradc_Discount', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdTT', 90, 'pradc_Notes', 1, 1, 1, 0

--AdCampaignAdKYC
EXEC usp_DeleteCustom_ScreenObject 'AdCampaignAdKYC'
EXEC usp_AddCustom_ScreenObjects 'AdCampaignAdKYC', 'Screen', 'PRAdCampaign', 'N', 0, 'PRAdCampaign'
EXEC usp_AddCustom_Screens 'AdCampaignAdKYC', 1, 'pradc_CompanyID', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdKYC', 3, 'pradc_AdCampaignHeaderID', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdKYC', 4, 'pradc_Name', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdKYC', 5, 'pradc_AdCampaignType', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdKYC', 10, 'pradc_KYCEdition', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdKYC', 20, 'pradc_KYCCommodityID', 0, 1, 1, 0 
EXEC usp_AddCustom_Screens 'AdCampaignAdKYC', 30, 'pradc_Placement', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdKYC', 40, 'pradc_Premium', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdKYC', 50, 'pradc_Cost', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdKYC', 60, 'pradc_Discount', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdKYC', 70, 'pradc_Notes', 1, 1, 2, 0

--AdCampaignAdKYCDigital
EXEC usp_DeleteCustom_ScreenObject 'AdCampaignAdKYCDigital'
EXEC usp_AddCustom_ScreenObjects 'AdCampaignAdKYCDigital', 'Screen', 'PRAdCampaign', 'N', 0, 'PRAdCampaign'
EXEC usp_AddCustom_Screens 'AdCampaignAdKYCDigital', 10, 'pradc_StartDate', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdKYCDigital', 20, 'pradc_EndDate', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdKYCDigital', 30, 'pradc_CreativeStatus', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdKYCDigital', 40, 'pradc_TargetURL', 1, 1, 1, 0

--AdCampaignAdKYCPrint
EXEC usp_DeleteCustom_ScreenObject 'AdCampaignAdKYCPrint'
EXEC usp_AddCustom_ScreenObjects 'AdCampaignAdKYCPrint', 'Screen', 'PRAdCampaign', 'N', 0, 'PRAdCampaign'
EXEC usp_AddCustom_Screens 'AdCampaignAdKYCPrint', 10, 'pradc_CreativeStatusPrint', 1, 1, 1, 0

--AdCampaignDetailsView
EXEC usp_DeleteCustom_ScreenObject 'AdCampaignDetailsView'
EXEC usp_AddCustom_ScreenObjects 'AdCampaignDetailsView', 'Screen', 'vPRAdCampaign', 'N', 0, 'vPRAdCampaign'
EXEC usp_AddCustom_Screens 'AdCampaignDetailsView', 10, 'pradc_AdFileCreatedBy', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignDetailsView', 20, 'pradc_AdFileUpdatedBy', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignDetailsView', 30, 'pracf_FileName', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignDetailsView', 40, 'pradc_CreatedDate', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignDetailsView', 50, 'pradc_CreatedBy', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignDetailsView', 60, 'pradc_UpdatedDate', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignDetailsView', 70, 'pradc_UpdatedBy', 0, 1, 1, 0

--AdCampaignDetailsViewKYC
EXEC usp_DeleteCustom_ScreenObject 'AdCampaignDetailsViewKYC'
EXEC usp_AddCustom_ScreenObjects 'AdCampaignDetailsViewKYC', 'Screen', 'vPRAdCampaign', 'N', 0, 'vPRAdCampaign'
EXEC usp_AddCustom_Screens 'AdCampaignDetailsViewKYC', 10, 'pradc_AdFileCreatedBy', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignDetailsViewKYC', 20, 'pradc_AdFileUpdatedBy', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignDetailsViewKYC', 30, 'pradc_CreatedDate', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignDetailsViewKYC', 40, 'pradc_CreatedBy', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignDetailsViewKYC', 50, 'pradc_UpdatedDate', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignDetailsViewKYC', 60, 'pradc_UpdatedBy', 0, 1, 1, 0

--AdCampaignDetailsEdit
EXEC usp_DeleteCustom_ScreenObject 'AdCampaignDetailsEdit'
EXEC usp_AddCustom_ScreenObjects 'AdCampaignDetailsEdit', 'Screen', 'PRAdCampaign', 'N', 0, 'PRAdCampaign'
EXEC usp_AddCustom_Screens 'AdCampaignDetailsEdit', 10, 'pradc_AdFileCreatedBy', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignDetailsEdit', 20, 'pradc_AdFileUpdatedBy', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignDetailsEdit', 40, 'pradc_CreatedDate', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignDetailsEdit', 50, 'pradc_CreatedBy', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignDetailsEdit', 60, 'pradc_UpdatedDate', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignDetailsEdit', 70, 'pradc_UpdatedBy', 0, 1, 1, 0

--make blueprintsedition not be multi-select field
EXEC usp_AccpacCreateSelectField 'PRAdCampaign', 'pradc_BluePrintsEdition', 'Blueprints Edition', 'pradc_BlueprintsEdition'

--add new pradc_AdCampaignTypeDigital
EXEC usp_AccpacCreateSelectField 'PRAdCampaign', 'pradc_AdCampaignTypeDigital', 'Digital Type', 'pradc_AdCampaignTypeDigital'

--add new pradc_TTEdition
EXEC usp_AccpacCreateSelectField 'PRAdCampaign', 'pradc_TTEdition', 'Edition', 'pradc_TTEdition'

--add new pradc_KYCEdition
EXEC usp_AccpacCreateSelectField 'PRAdCampaign', 'pradc_KYCEdition', 'Edition', 'pradc_KYCEdition'

--add new pradc_KYCCommodityID
EXEC usp_AccpacCreateIntegerField 'PRAdCampaign', 'pradc_KYCCommodityID', 'KYC Commodity ID'

--add new pradc_PostName but don't add it to database (it's for block building only)
exec usp_AccpacCreateField @EntityName = 'PRAdCampaign', 
          @FieldName = 'pradc_PostName', @Caption = 'Commodity',
          @AccpacEntryType = 10, @AccpacEntrySize = 50, 
          @DBFieldType = 'nvarchar', @DBFieldSize = 1000,
          @SkipColumnCreation='Y'

--add new pradc_CreativeStatusPrint
EXEC usp_AccpacCreateSelectField 'PRAdCampaign', 'pradc_CreativeStatusPrint', 'Creative Status', 'pradc_CreativeStatus'

--AdCampaignAdListBP
EXEC usp_DeleteCustom_List 'AdCampaignAdListBP'
EXEC usp_AddCustom_ScreenObjects 'AdCampaignAdListBP', 'List', 'PRAdCampaign', 'N', 0, 'PRAdCampaign'
EXEC usp_AddCustom_Lists 'AdCampaignAdListBP', 10, 'pradc_BluePrintsEdition', null, 'Y', 'Y', @Jump='Custom', @CustomAction='PRAdvertising/AdCampaignAdBP.asp', @CustomIdField='pradc_AdCampaignID'
EXEC usp_AddCustom_Lists 'AdCampaignAdListBP', 20, 'pradc_Section', null, 'Y', 'Y', @Jump='Custom', @CustomAction='PRAdvertising/AdCampaignAdBP.asp', @CustomIdField='pradc_AdCampaignID'
EXEC usp_AddCustom_Lists 'AdCampaignAdListBP', 30, 'pradc_PlannedSection', null, 'Y', 'Y', @Jump='Custom', @CustomAction='PRAdvertising/AdCampaignAdBP.asp', @CustomIdField='pradc_AdCampaignID'
EXEC usp_AddCustom_Lists 'AdCampaignAdListBP', 40, 'pradc_CreativeStatus', null, 'Y', 'Y', @Jump='Custom', @CustomAction='PRAdvertising/AdCampaignAdBP.asp', @CustomIdField='pradc_AdCampaignID'
EXEC usp_AddCustom_Lists 'AdCampaignAdListBP', 50, 'pradc_Name', null, 'Y' 
EXEC usp_AddCustom_Lists 'AdCampaignAdListBP', 60, 'pradc_Cost', null, 'Y' 

--AdCampaignAdListDigital
EXEC usp_DeleteCustom_List 'AdCampaignAdListDigital'
EXEC usp_AddCustom_ScreenObjects 'AdCampaignAdListDigital', 'List', 'PRAdCampaign', 'N', 0, 'PRAdCampaign'
EXEC usp_AddCustom_Lists 'AdCampaignAdListDigital', 10, 'pradc_Name', null, 'Y', 'Y', @Jump='Custom', @CustomAction='PRAdvertising/AdCampaignAdDigital.asp', @CustomIdField='pradc_AdCampaignID'
EXEC usp_AddCustom_Lists 'AdCampaignAdListDigital', 20, 'pradc_CreativeStatus', null, 'Y', 'Y', @Jump='Custom', @CustomAction='PRAdvertising/AdCampaignAdDigital.asp', @CustomIdField='pradc_AdCampaignID'
EXEC usp_AddCustom_Lists 'AdCampaignAdListDigital', 30, 'pradc_AdCampaignTypeDigital', null, 'Y', 'Y', @Jump='Custom', @CustomAction='PRAdvertising/AdCampaignAdDigital.asp', @CustomIdField='pradc_AdCampaignID'
EXEC usp_AddCustom_Lists 'AdCampaignAdListDigital', 40, 'pradc_StartDate', null, 'Y', 'Y', @Jump='Custom', @CustomAction='PRAdvertising/AdCampaignAdDigital.asp', @CustomIdField='pradc_AdCampaignID'
EXEC usp_AddCustom_Lists 'AdCampaignAdListDigital', 50, 'pradc_EndDate', null, 'Y', 'Y', @Jump='Custom', @CustomAction='PRAdvertising/AdCampaignAdDigital.asp', @CustomIdField='pradc_AdCampaignID'
EXEC usp_AddCustom_Lists 'AdCampaignAdListDigital', 60, 'pradc_Cost', null, 'Y', 'Y', @Jump='Custom', @CustomAction='PRAdvertising/AdCampaignAdDigital.asp', @CustomIdField='pradc_AdCampaignID'

--AdCampaignAdListTT
EXEC usp_DeleteCustom_List 'AdCampaignAdListTT'
EXEC usp_AddCustom_ScreenObjects 'AdCampaignAdListTT', 'List', 'PRAdCampaign', 'N', 0, 'PRAdCampaign'
EXEC usp_AddCustom_Lists 'AdCampaignAdListTT', 10, 'pradc_TTEdition', null, 'Y', 'Y', @Jump='Custom', @CustomAction='PRAdvertising/AdCampaignAdTT.asp', @CustomIdField='pradc_AdCampaignID'
EXEC usp_AddCustom_Lists 'AdCampaignAdListTT', 20, 'pradc_CreativeStatus', null, 'Y', 'Y', @Jump='Custom', @CustomAction='PRAdvertising/AdCampaignAdTT.asp', @CustomIdField='pradc_AdCampaignID'
EXEC usp_AddCustom_Lists 'AdCampaignAdListTT', 30, 'pradc_Cost', null, 'Y', 'Y', @Jump='Custom', @CustomAction='PRAdvertising/AdCampaignAdTT.asp', @CustomIdField='pradc_AdCampaignID'

--AdCampaignAdListKYC
EXEC usp_DeleteCustom_List 'AdCampaignAdListKYC'
EXEC usp_AddCustom_ScreenObjects 'AdCampaignAdListKYC', 'List', 'vPRAdCampaignKYCList', 'N', 0, 'vPRAdCampaignKYCList'
EXEC usp_AddCustom_Lists 'AdCampaignAdListKYC', 10, 'pradc_KYCEdition', null, 'Y', 'Y', @Jump='Custom', @CustomAction='PRAdvertising/AdCampaignAdKYC.asp', @CustomIdField='pradc_AdCampaignID'
EXEC usp_AddCustom_Lists 'AdCampaignAdListKYC', 20, 'pradc_CreativeStatus', null, 'Y', 'Y', @Jump='Custom', @CustomAction='PRAdvertising/AdCampaignAdKYC.asp', @CustomIdField='pradc_AdCampaignID'
EXEC usp_AddCustom_Lists 'AdCampaignAdListKYC', 30, 'pradc_PostName', null, 'Y', 'Y', @Jump='Custom', @CustomAction='PRAdvertising/AdCampaignAdKYC.asp', @CustomIdField='pradc_AdCampaignID'
EXEC usp_AddCustom_Lists 'AdCampaignAdListKYC', 40, 'pradc_StartDate', null, 'Y', 'Y', @Jump='Custom', @CustomAction='PRAdvertising/AdCampaignAdKYC.asp', @CustomIdField='pradc_AdCampaignID'
EXEC usp_AddCustom_Lists 'AdCampaignAdListKYC', 50, 'pradc_EndDate', null, 'Y', 'Y', @Jump='Custom', @CustomAction='PRAdvertising/AdCampaignAdKYC.asp', @CustomIdField='pradc_AdCampaignID'
EXEC usp_AddCustom_Lists 'AdCampaignAdListKYC', 60, 'pradc_Cost', null, 'Y', 'Y', @Jump='Custom', @CustomAction='PRAdvertising/AdCampaignAdKYC.asp', @CustomIdField='pradc_AdCampaignID'

--AdCampaignTermsList
EXEC usp_DeleteCustom_List 'AdCampaignTermsList'
EXEC usp_AddCustom_ScreenObjects 'AdCampaignTermsList', 'List', 'PRAdCampaignTerms', 'N', 0, 'PRAdCampaignTerms'
EXEC usp_AddCustom_Lists 'AdCampaignTermsList', 10, 'pract_BillingDate', null, 'Y' 
EXEC usp_AddCustom_Lists 'AdCampaignTermsList', 20, 'pract_TermsAmount', null, 'Y'
EXEC usp_AddCustom_Lists 'AdCampaignTermsList', 30, 'pract_Processed', null, 'Y'
EXEC usp_AddCustom_Lists 'AdCampaignTermsList', 40, 'pract_InvoiceDescription', null, 'Y'
--EXEC usp_AddCustom_Lists 'AdCampaignTermsList', 30, 'pract_InvoiceDate', null, 'Y'
--EXEC usp_AddCustom_Lists 'AdCampaignTermsList', 40, 'pract_OrderNumber', null, 'Y'

--Resize fields to fit prototype look/feel (per Chris)
EXEC usp_AccpacCreateTextField 'PRAdCampaign', 'pradc_ContentSourceContactName', 'Content Source Contact Name', 50, 200 --EntryType 10
EXEC usp_AccpacCreateTextField 'PRAdCampaign', 'pradc_ContentSourceContactInfo', 'Content Source Contact Info', 50, 200 --EntryType 10
EXEC usp_AccpacCreateTextField 'PRAdCampaign', 'pradc_TargetURL', 'Target URL', 50, 500 --EntryType 10

EXEC usp_AccpacCreateMultilineField 'PRAdCampaign', 'pradc_PlacementInstructions', 'Special Placement Instructions', 75 --EntryType 11

ALTER TABLE [dbo].[PRAdCampaign] DROP CONSTRAINT DF__PRAdCampa__pradc__05113BBC

--stored procedures

--usp_DeleteAdCampaign modified and changes put in Stored Procedures.sql
--usp_DeleteAdCampaignHeader modified and changes put in Stored Procedures.sql
--vPRAdCampaign modified and changes put in Views.sql
--vPRAdCampaignKYCList modified and changes put in Views.sql

--***************    AD REFACTORING -- END JMT CUSTOM CHANGES  *****************************

--Get rid of vPRCompanyTradeShowContact and replace with just the direct table
EXEC usp_AddCustom_ScreenObjects 'CompanyTradeShowContactNewEntry', 'Screen', 'PRCompanyTradeShowContact', 'Y', 0, 'PRCompanyTradeShowContact'
EXEC usp_AddCustom_ScreenObjects 'CompanyTradeShowContactNewEntry', 'Screen', 'PRCompanyTradeShowContact_Link', 'Y', 0, 'PRCompanyTradeShowContact'

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[vPRCompanyTradeShowContact]') )
    drop View [dbo].[vPRCompanyTradeShowContact]
GO

EXEC usp_AccpacCreateCheckboxField 'PRWebUser', 'prwu_CompanyLinksNewTab', 'Company Links in New Tab'

