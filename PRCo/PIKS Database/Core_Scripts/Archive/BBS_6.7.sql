USE CRMArchive
IF NOT  EXISTS(SELECT * FROM sys.columns WHERE Name = N'pradcat_PageRequestID' and Object_ID = Object_ID(N'dbo.PRAdCampaignAuditTrail')) BEGIN 
	ALTER TABLE PRAdCampaignAuditTrail ADD pradcat_PageRequestID varchar(50)
END
Go

USE CRM
EXEC usp_AccpacCreateTextField 'PRAdCampaignAuditTrail', 'pradcat_PageRequestID', 'Page Request ID', 50, 50
Go



EXEC usp_AccpacDropTable 'PRGetListedRequest'
EXEC usp_AccpacCreateTable @EntityName='PRGetListedRequest', @ColPrefix='prglr', @IDField='prglr_GetListedRequestID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyField          'PRGetListedRequest', 'prglr_GetListedRequestID', 'Get Listed Request ID'
EXEC usp_AccpacCreateTextField         'PRGetListedRequest', 'prglr_SubmitterName', 'Submitter Name', 100, 100
EXEC usp_AccpacCreateTextField         'PRGetListedRequest', 'prglr_SubmitterPhone', 'Submitter Phone', 25, 25
EXEC usp_AccpacCreateTextField         'PRGetListedRequest', 'prglr_SubmitterEmail', 'Submitter Email', 50, 255
EXEC usp_AccpacCreateCheckboxField     'PRGetListedRequest', 'prglr_SubmitterIsOwner', 'Submitter Is Owner'
EXEC usp_AccpacCreateTextField         'PRGetListedRequest', 'prglr_SubmitterIPAddress', 'Sumbitter IP Address', 50, 50
EXEC usp_AccpacCreateTextField         'PRGetListedRequest', 'prglr_CompanyName', 'Company Name', 50, 200
EXEC usp_AccpacCreateTextField         'PRGetListedRequest', 'prglr_Street1', 'Street 1', 40, 40
EXEC usp_AccpacCreateTextField         'PRGetListedRequest', 'prglr_Street2', 'Street 2', 40, 40
EXEC usp_AccpacCreateTextField         'PRGetListedRequest', 'prglr_City', 'City', 34, 34
EXEC usp_AccpacCreateTextField         'PRGetListedRequest', 'prglr_State', 'State', 30, 30
EXEC usp_AccpacCreateTextField         'PRGetListedRequest', 'prglr_PostalCode', 'Postal Code', 10, 10
EXEC usp_AccpacCreateTextField         'PRGetListedRequest', 'prglr_Country', 'State', 30, 30
EXEC usp_AccpacCreateTextField         'PRGetListedRequest', 'prglr_CompanyPhone', 'Company Phone', 25, 25
EXEC usp_AccpacCreateTextField         'PRGetListedRequest', 'prglr_CompanyEmail', 'Company Email', 50, 255
EXEC usp_AccpacCreateTextField         'PRGetListedRequest', 'prglr_CompanyWebsite', 'Company Website', 50, 255
EXEC usp_AccpacCreateSelectField       'PRGetListedRequest', 'prglr_PrimaryFunction', 'Primary Function', 'prglr_PrimaryFunction'
EXEC usp_AccpacCreateSelectField       'PRGetListedRequest', 'prglr_HowLearned', 'How Learned', 'prwu_HowLearned'
EXEC usp_AccpacCreateMultilineField	   'PRGetListedRequest', 'prglr_Principals', 'Principals'
EXEC usp_AccpacCreateCheckboxField     'PRGetListedRequest', 'prglr_RequestsMembershipInfo', 'Requests Membership Info'
EXEC usp_AccpacCreateSelectField       'PRGetListedRequest', 'prglr_IndustryType', 'Industry Type', 'comp_PRIndustryType'
Go

EXEC usp_AccpacCreateDropdownValue 'prglr_PrimaryFunction', 'PB', 10, 'Produce Buyer'  
EXEC usp_AccpacCreateDropdownValue 'prglr_PrimaryFunction', 'PS', 20, 'Produce Seller'  
EXEC usp_AccpacCreateDropdownValue 'prglr_PrimaryFunction', 'T',  30, 'Transportation'  
EXEC usp_AccpacCreateDropdownValue 'prglr_PrimaryFunction', 'S',  40, 'Industry Supply/Service'  
EXEC usp_AccpacCreateDropdownValue 'prglr_PrimaryFunction', 'O',  50, 'Other'  
Go


EXEC usp_AccpacCreateCheckboxField     'PRAdEligiblePage', 'pradep_MarketingPage', 'MarketingPage'
Go

EXEC usp_AddCustom_Screens 'CommunicationFilterBox', 8, 'comm_DateTime', 1
Go


EXEC usp_AccpacDropTable 'PRWebSiteVisitor'
EXEC usp_AccpacCreateTable @EntityName='PRWebSiteVisitor', @ColPrefix='prwsv', @IDField='prwsv_WebSiteVisitorID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyField          'PRWebSiteVisitor', 'prwsv_WebSiteVisitorID', 'Web Site Visitor ID'
EXEC usp_AccpacCreateTextField         'PRWebSiteVisitor', 'prwsv_SubmitterEmail', 'Submitter Email', 50, 255
EXEC usp_AccpacCreateTextField         'PRWebSiteVisitor', 'prwsv_CompanyName', 'Company Name', 50, 200
EXEC usp_AccpacCreateCheckboxField     'PRWebSiteVisitor', 'prwsv_RequestsMembershipInfo', 'Requests Membership Info'
EXEC usp_AccpacCreateSelectField       'PRWebSiteVisitor', 'prwsv_PrimaryFunction', 'Primary Function', 'prglr_PrimaryFunction'
EXEC usp_AccpacCreateTextField         'PRWebSiteVisitor', 'prwsv_SubmitterIPAddress', 'Sumbitter IP Address', 50, 50
EXEC usp_AccpacCreateSearchSelectField 'PRWebSiteVisitor', 'prwsv_CompanyID', 'Company', 'Company', 50 
EXEC usp_AccpacCreateSelectField       'PRWebSiteVisitor', 'prwsv_IndustryType', 'Industry Type', 'comp_PRIndustryType'
EXEC usp_AccpacCreateTextField         'PRWebSiteVisitor', 'prwsv_Referrer', 'Referrer', 50, 5000
Go


EXEC usp_AccpacDropTable 'PRBusinessReportPurchase'
EXEC usp_AccpacCreateTable @EntityName='PRBusinessReportPurchase', @ColPrefix='prbrp', @IDField='prbrp_BusinessReportPurchaseID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyField          'PRBusinessReportPurchase', 'prbrp_BusinessReportPurchaseID', 'Business Report Purchase ID'
EXEC usp_AccpacCreateTextField         'PRBusinessReportPurchase', 'prbrp_SubmitterEmail', 'Submitter Email', 50, 255
EXEC usp_AccpacCreateIntegerField      'PRBusinessReportPurchase', 'prbrp_PaymentID', 'Payment ID'
EXEC usp_AccpacCreateIntegerField      'PRBusinessReportPurchase', 'prbrp_ProductID', 'Product ID'
EXEC usp_AccpacCreateCheckboxField     'PRBusinessReportPurchase', 'prbrp_RequestsMembershipInfo', 'Requests Membership Info'
EXEC usp_AccpacCreateSelectField       'PRBusinessReportPurchase', 'prbrp_IndustryType', 'Industry Type', 'comp_PRIndustryType'
EXEC usp_AccpacCreateSearchSelectField 'PRBusinessReportPurchase', 'prbrp_CompanyID', 'Subject Company', 'Company', 50 
Go

EXEC usp_AccpacCreateSelectField       'PRMembershipPurchase', 'prmp_IndustryType', 'Industry Type', 'comp_PRIndustryType'
Go
--SELECT * FROM Custom_Tables where bord_prefix LIKE 'prbr%'


EXEC usp_DeleteCustom_ScreenObject 'PRBusinessReportPurchaseGrid'
EXEC usp_AddCustom_ScreenObjects 'PRBusinessReportPurchaseGrid', 'List', 'PRBusinessReportPurchase', 'N', 0, 'vPRBusinessReportPurchase'
EXEC usp_AddCustom_Lists 'PRBusinessReportPurchaseGrid', 10, 'prbrp_CreatedDate', null, 'Y', 'Y', 'Center', 'Custom', '', '', 'PRGeneral/BusinessReportPurchase.asp', 'prbrp_BusinessReportPurchaseID'
EXEC usp_AddCustom_Lists 'PRBusinessReportPurchaseGrid', 20, 'prpay_NameOnCard', null, 'Y'
EXEC usp_AddCustom_Lists 'PRBusinessReportPurchaseGrid', 40, 'prbrp_SubmitterEmail', null, 'Y'
EXEC usp_AddCustom_Lists 'PRBusinessReportPurchaseGrid', 50, 'prod_Name', null, 'Y'
EXEC usp_AddCustom_Lists 'PRBusinessReportPurchaseGrid', 60, 'prpay_Amount', null, 'Y'
EXEC usp_AddCustom_Lists 'PRBusinessReportPurchaseGrid', 70, 'comp_Name', null, 'Y'

EXEC usp_DefineCaptions 'PRBusinessReportPurchase', 'Business Report Purchase', 'Business Report Purchases', null, null, null, null

EXEC usp_DeleteCustom_ScreenObject 'PRBusinessReportPurchaseFilterBox'
EXEC usp_AddCustom_ScreenObjects 'PRBusinessReportPurchaseFilterBox', 'SearchScreen', 'PRBusinessReportPurchase', 'N', 0, 'vPRBusinessReportPurchase'
EXEC usp_AddCustom_Screens 'PRBusinessReportPurchaseFilterBox', 10, 'prbrp_CreatedDate', 1, 1, 1
EXEC usp_AddCustom_Screens 'PRBusinessReportPurchaseFilterBox', 20, 'prpay_NameOnCard', 0, 1, 1
EXEC usp_AddCustom_Screens 'PRBusinessReportPurchaseFilterBox', 30, 'prbrp_SubmitterEmail', 1, 1, 1
EXEC usp_AddCustom_Screens 'PRBusinessReportPurchaseFilterBox', 40, 'prbrp_CompanyID', 0, 1, 1
Go

--SELECT tabs_tabid, tabs_caption, tabs_Bitmap, tabs_order FROM custom_tabs where tabs_Entity = 'find' and tabs_deviceID IS NULL ORDER BY tabs_order
EXEC usp_AddCustom_Tabs 160, 'find', 'BR Purchases', 'customfile', 'PRGeneral/BusinessReportPurchaseListing.asp', null, 'CRMQuote.gif'
Go


EXEC usp_DeleteCustom_ScreenObject 'PRBusinessReportPurchase'
EXEC usp_AddCustom_ScreenObjects 'PRBusinessReportPurchase', 'Screen', 'vPRBusinessReportPurchase', 'N', 0, 'vPRBusinessReportPurchase'
EXEC usp_AddCustom_Screens 'PRBusinessReportPurchase', 10, 'prbrp_CreatedDate',      1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRBusinessReportPurchase', 20, 'prpay_NameOnCard',       0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRBusinessReportPurchase', 30, 'prbrp_SubmitterEmail',   0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRBusinessReportPurchase', 40, 'prod_Name',              1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRBusinessReportPurchase', 50, 'prpay_Amount',           0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRBusinessReportPurchase', 60, 'prbrp_CompanyID',        1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRBusinessReportPurchase', 70, 'prbrp_IndustryType',     0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRBusinessReportPurchase', 80, 'prpay_CreditCardType',   1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRBusinessReportPurchase', 90, 'prpay_CreditCardNumber', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRBusinessReportPurchase', 100, 'prpay_ExpirationMonth',  0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRBusinessReportPurchase', 110, 'prpay_ExpirationYear',   0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRBusinessReportPurchase', 120, 'prpay_Street1',          1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRBusinessReportPurchase', 130, 'prpay_Street2',          0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRBusinessReportPurchase', 140, 'prpay_City',             0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRBusinessReportPurchase', 150, 'prpay_StateID',          1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRBusinessReportPurchase', 160, 'prpay_CountryID',        0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRBusinessReportPurchase', 170, 'prpay_PostalCode',       0, 1, 1, 0
Go


--ALTER TABLE PRAdCampaign ALTER COLUMN pradc_CreativeStatus varchar(100)
--ALTER TABLE PRAdCampaign ALTER COLUMN pradc_Section varchar(100)
ALTER TABLE PRAdCampaign ALTER COLUMN pradc_PlannedSection varchar(100)
Go

SELECT MAX(LEN(pradc_PlannedSection)) FROM PRAdCampaign

UPDATE PRAdCampaign
   SET pradc_Section = capt_us
  FROM Custom_Captions
 WHERE capt_family = 'pradc_Section'
   AND pradc_Section = capt_code
   AND capt_code IN ('NIB', 'Dir', 'EB', 'KYC')



UPDATE PRAdCampaign
   SET pradc_PlannedSection = capt_us
  FROM Custom_Captions
 WHERE capt_family = 'pradc_PlannedSection'
   AND pradc_PlannedSection = capt_code
   AND capt_code IN ('100', '1', '101', '2', '3', '4', '5', '50', '6', '7', '8', '9', '10', '30', '31', '13', '55', '11', '14', '103', '36', '102', '12', '38', '104', '33', '16', '17', '37', '18', '34', '56', '57', '58', '59', '19', '20', '106', '35', '25', '26', '27', '105', '28')

/*
UPDATE PRAdCampaign
   SET pradc_CreativeStatus = capt_us
  FROM Custom_Captions
 WHERE capt_family = 'pradc_CreativeStatus'
   AND pradc_CreativeStatus = capt_code
   AND capt_code IN ('PIC', 'POC', 'PPSI', 'A')
*/

UPDATE Custom_Captions
   SET capt_us = 'Special Placement Instructions'
WHERE capt_family = 'ColNames'
  AND capt_Code = 'pradc_PlacementInstructions'

UPDATE Custom_Captions
   SET capt_us = 'Advertising Trade Name'
WHERE capt_family = 'ColNames'
  AND capt_Code = 'pradc_AltTradeName'

UPDATE Custom_Captions
   SET capt_us = 'Notes Only (Not Placement Instructions)'
WHERE capt_family = 'ColNames'
  AND capt_Code = 'pradc_Notes'
                               
UPDATE Custom_Captions
   SET capt_us = 'Record Updated By'
WHERE capt_family = 'ColNames'
  AND capt_Code = 'pradc_UpdatedBy'



EXEC usp_DeleteCustom_Screen 'PRAdCampaignBP', 'pradc_FinalPlacement'
EXEC usp_DeleteCustom_Screen 'PRAdCampaignBP', 'pradc_FinalPageNumber'
Go

EXEC usp_AccpacCreateSelectField 'PRAdCampaign', 'pradc_SectionDetailsCode', 'Section Details', 'pradc_SectionDetailsCode'
Go

UPDATE Custom_Captions
   SET capt_us = 'Section Details - If Other'
WHERE capt_family = 'ColNames'
  AND capt_Code = 'pradc_SectionDetails'
  

UPDATE PRAdCampaign
   SET pradc_SectionDetailsCode = 'Other'
 WHERE pradc_SectionDetails IS NOT NULL;


EXEC usp_AddCustom_Screens 'PRAdCampaignBP', 30, 'pradc_BluePrintsEdition',   1, 4, 1, 0, null, 'setAdName();'
EXEC usp_AddCustom_Screens 'PRAdCampaignBP', 50, 'pradc_SectionDetailsCode',  1, 1, 1, 0, null, 'toggleSectionDetails();'
EXEC usp_AddCustom_Screens 'PRAdCampaignBP', 52, 'pradc_SectionDetails',      1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRAdCampaignBP', 60, 'pradc_Placement',           1, 1, 1, 0


EXEC usp_AccpacGetBlockInfo 'PRAdCampaignBP'

Go


EXEC usp_AccpacCreateDropdownValue 'AutoRemoveRatingNumerals', 'User', 1, 'chw'
EXEC usp_AccpacCreateDropdownValue 'AutoRemoveRatingNumerals', 'Date', 1, 'February 7 2014 11:02AM'
Go


EXEC usp_AccpacCreateTextField 'PRCourtCases', 'prcc_Notes', 'Notes', 50, 5000
Go

EXEC usp_AccpacCreateMultilineField 'Company', 'comp_PRFinancialNotes', 'FS Analysis Notes', 150, 10
Go

EXEC usp_DeleteCustom_ScreenObject 'PRFinancialNotes'
EXEC usp_AddCustom_ScreenObjects 'PRFinancialNotes', 'Screen', 'Company', 'N', 0, 'Company'
EXEC usp_AddCustom_Screens 'PRFinancialNotes', 10, 'comp_PRFinancialNotes',      1, 1, 1, 0
Go

SELECT * FROM Custom_Edits where colp_ColName IN ('comp_PRFinancialNotes', 'comp_PRSpecialHandlingInstruction')