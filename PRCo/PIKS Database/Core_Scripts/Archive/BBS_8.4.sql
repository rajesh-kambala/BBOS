--8.4 Release
USE CRM

--Remove deprecated fields
EXEC usp_AccpacDropField 'PRAdCampaign', 'pradc_HQID'
Go

   --EXEC usp_AccpacDropField 'PRAdCampaign', 'pradc_CompanyID' --keeping this for now -- DO NOT EXECUTE -- too many reports use it
   --EXEC usp_AccpacDropField 'PRAdCampaign', 'pradc_Name' -- KEEPING BP, Digital both have separate name field apart from header name, and this field reused for that

EXEC usp_AccpacDropField 'PRAdCampaign', 'pradc_AltTradeName' 
EXEC usp_AccpacDropField 'PRAdCampaign', 'pradc_ApprovedByPersonID'
Go

EXEC usp_AccpacDropField 'PRAdCampaign', 'pradc_SoldBy'
EXEC usp_AccpacDropField 'PRAdCampaign', 'pradc_SoldDate'
EXEC usp_AccpacDropField 'PRAdCampaign', 'pradc_Renewal'
Go
		--EXEC usp_AccpacDropField 'PRAdCampaign', 'pradc_Cost' -- DO NOT REMOVE
		--EXEC usp_AccpacDropField 'PRAdCampaign', 'pradc_Discount' -- DO NOT REMOVE

EXEC usp_AccpacDropField 'PRAdCampaign', 'pradc_Terms'
EXEC usp_AccpacDropField 'PRAdCampaign', 'pradc_TermsDescription'
EXEC usp_AccpacDropField 'PRAdCampaign', 'pradc_TermsAmt'
EXEC usp_AccpacDropField 'PRAdCampaign', 'pradc_TermsAmt_CID'
EXEC usp_AccpacDropField 'PRAdCampaign', 'pradc_AdImageName'
Go

EXEC usp_AccpacDropTable 'PRAdCampaignPage'
EXEC usp_AccpacDropTable 'PRAdEligiblePage'

GO

-- Recreate PRAdCampaignSummary that somehow was lost in the SQL scripts but still existed (copied from what was there)
EXEC usp_DeleteCustom_ScreenObject 'PRAdCampaignSummary'
EXEC usp_AddCustom_ScreenObjects 'PRAdCampaignSummary', 'Screen', 'vPRAdCampaignSummary', 'N', 0, 'vPRAdCampaignSummary'
EXEC usp_AddCustom_Screens 'PRAdCampaignSummary', 10, 'pradc_ImpressionCount', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRAdCampaignSummary', 20, 'pradc_ClickCount', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRAdCampaignSummary', 30, 'AvgRank', 0, 1, 1, 0

Go

--***************    AD REFACTORING -- END DATA MODEL  *****************************

--DEFECT 4649
EXEC usp_AccpacCreateCheckboxField 'PRCompanyInfoProfile', 'prc5_PRARYearRoundBPAdvertiser', 'Year-Round Blueprints Advertiser'
EXEC usp_AddCustom_Screens 'PRCompanyInfoProfileFlags',  40, 'prc5_PRARYearRoundBPAdvertiser', 0, 1,  1, 'N'
GO

--Defect 5721 remove RSS
EXEC usp_DeleteCustom_Screen 'PRPublicationArticleEntry', 'prpbar_RSS'
Go

--DEFECT 5714 - NewsletterMetrics Import
EXEC usp_AccpacDropTable			'PRNewsletterMetricsHeader'
EXEC usp_AccpacCreateTable			'PRNewsletterMetricsHeader', 'prnlmh', 'prnlmh_NewsletterMetricsHeaderID'
EXEC usp_AccpacCreateKeyField		'PRNewsletterMetricsHeader', 'prnlmh_NewsletterMetricsHeaderID', 'Newsletter Metrics Header ID'
EXEC usp_AccpacCreateDateField		'PRNewsletterMetricsHeader', 'prnlmh_SentDate', 'Sent Date'
EXEC usp_AccpacCreateIntegerField	'PRNewsletterMetricsHeader', 'prnlmh_EmailCount', 'Email Count'
GO

EXEC usp_AccpacDropTable			'PRNewsletterMetricsDetail'
EXEC usp_AccpacCreateTable			'PRNewsletterMetricsDetail', 'prnlmd', 'prnlmd_NewsLetterMetricsDetailID'
EXEC usp_AccpacCreateKeyField		'PRNewsletterMetricsDetail', 'prnlmd_NewsLetterMetricsDetailID', 'Newsletter Metrics Detail ID'
EXEC usp_AccpacCreateIntegerField	'PRNewsletterMetricsDetail', 'prnlmd_NewsletterMetricsHeaderID', 'Newsletter Metrics Header ID'
EXEC usp_AccpacCreateTextField      'PRNewsletterMetricsDetail', 'prnlmd_EmailAddress', 'Email Address', 500, 500
EXEC usp_AccpacCreateTextField      'PRNewsletterMetricsDetail', 'prnlmd_FirstName', 'First Name', 500, 500
EXEC usp_AccpacCreateTextField      'PRNewsletterMetricsDetail', 'prnlmd_LastName', 'Last Name', 500, 500
EXEC usp_AccpacCreateIntegerField   'PRNewsletterMetricsDetail', 'prnlmd_BBID', 'BBID'
EXEC usp_AccpacCreateTextField      'PRNewsletterMetricsDetail', 'prnlmd_State', 'State', 500, 500
EXEC usp_AccpacCreateTextField      'PRNewsletterMetricsDetail', 'prnlmd_Country', 'Country', 500, 500
EXEC usp_AccpacCreateTextField      'PRNewsletterMetricsDetail', 'prnlmd_CSGID', 'CSGID', 500, 500
EXEC usp_AccpacCreateTextField      'PRNewsletterMetricsDetail', 'prnlmd_CompanyName', 'Company Name', 500, 500
EXEC usp_AccpacCreateTextField      'PRNewsletterMetricsDetail', 'prnlmd_ListingLocation', 'Listing Location', 500, 500
EXEC usp_AccpacCreateTextField      'PRNewsletterMetricsDetail', 'prnlmd_PrimaryService', 'PrimaryService', 500, 500
EXEC usp_AccpacCreateTextField      'PRNewsletterMetricsDetail', 'prnlmd_Lists', 'Lists', 5000, 5000
--EXEC usp_AccpacCreateDateField    'PRNewsletterMetricsDetail', 'prnlmd_TimeStamp', 'TimeStamp'
EXEC usp_AccpacCreateTextField      'PRNewsletterMetricsDetail', 'prnlmd_BounceType', 'Bounce Type', 500, 500
EXEC usp_AccpacCreateTextField      'PRNewsletterMetricsDetail', 'prnlmd_Event', 'Event', 500, 500
EXEC usp_AccpacCreateTextField      'PRNewsletterMetricsDetail', 'prnlmd_IsMember', 'IsMember', 1, 1
EXEC usp_AccpacCreateTextField      'PRNewsletterMetricsDetail', 'prnlmd_BusinessType', 'BusinessType', 500, 500
GO

EXEC usp_AddCustom_Tabs 340, 'find', 'Import Newsletter Metrics', 'customfile', 'PRGeneral/ImportNewsletterMetricsRedirect.asp', null, 'dataupload.gif'
GO