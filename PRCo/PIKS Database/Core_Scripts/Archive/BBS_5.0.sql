UPDATE custom_tabs
   SET tabs_caption = 'Interactions'
 WHERE tabs_caption = 'Communications';

EXEC usp_AddCustom_Tabs 8, 'company', 'Relationships', 'customfile', 'PRCompany/PRCompanyRelationshipListing.asp'


UPDATE custom_screenobjects
   SET cobj_CustomContent = '<script language=javascript src="/CRM/CustomPages/PRCoGeneral.js"></script><script language=javascript src="/CRM/CustomPages/PRGeneral/PRInteraction.js"></script><script language=javascript>hideButton("/Buttons/NewCompany.gif", "TD");hideButton("/Buttons/NewIndividual.gif", "TD");</script>'
 where cobj_name = 'CommunicationSchedulingBox';



EXEC usp_AddCustom_Screens 'PRTradeReportSearchBox', 2, 'comp_PRIndustryType', 0, 1, 1, 1


EXEC usp_AccpacCreateCheckboxField     'PRAdCampaign', 'pradc_Premium', 'Premium'
EXEC usp_AccpacCreateSelectField       'PRAdCampaign', 'pradc_PlannedSection', 'Planned Section', 'pradc_PlannedSection'
EXEC usp_AccpacCreateCheckboxField     'PRAdCampaign', 'pradc_Renewal', 'Renewal'

EXEC usp_AddCustom_Screens 'PRAdCampaignBP', 30, 'pradc_BluePrintsEdition', 1, 4, 1
EXEC usp_AddCustom_Screens 'PRAdCampaignBP', 45, 'pradc_PlannedSection', 1, 1, 1
EXEC usp_AddCustom_Screens 'PRAdCampaignBP', 63, 'pradc_Renewal', 1, 1, 1
EXEC usp_AddCustom_Screens 'PRAdCampaignBP', 66, 'pradc_Premium', 0, 1, 1
UPDATE custom_edits SET colp_EntrySize = 7  WHERE colp_colname = 'pradc_BluePrintsEdition'

EXEC usp_DefineCaptions 'CompanyExceptions', 'Company Exception', 'Company Exceptions', 'comp_Name', 'comp_CompanyID', NULL, NULL   


UPDATE custom_tabs
   SET tabs_CustomFileName='PRPerson/PRPersonRelationshipListing.asp'
WHERE tabs_entity = 'person'
  AND tabs_caption = 'Relationships'
  AND tabs_DeviceID IS NULL;   
  
UPDATE custom_tabs
   SET tabs_CustomFileName='PRCase/PRCaseListing.asp'
WHERE tabs_entity = 'User'
  AND tabs_caption = 'Cases'  
  AND tabs_DeviceID IS NULL;   
  
UPDATE custom_tabs
   SET tabs_CustomFileName='PROpportunity/PROpportunityListing.asp'
WHERE tabs_entity = 'User'
  AND tabs_caption = 'Opportunities'    
  AND tabs_DeviceID IS NULL; 
Go  

-- These indexes will be redefined when the Indexes.sql
-- script executes
DROP INDEX ndx_prdr_CompanyId ON PRDRCLicense
DROP INDEX ndx_PRDRCLicense_01 ON PRDRCLicense
ALTER TABLE PRDRCLicense ALTER COLUMN prdr_CompanyId int NOT NULL;
Go

-- These indexes will be redefined when the Indexes.sql
-- script executes
DROP INDEX ndx_prcp_CompanyId ON PRCompanyProfile
ALTER TABLE PRCompanyProfile ALTER COLUMN prcp_CompanyId int NOT NULL;
Go


EXEC usp_AddCustom_Screens 'PROpportunityMembershipSummary', 10, 'oppo_Status', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PROpportunityMembershipSummary', 20, 'oppo_Opened', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PROpportunityMembershipSummary', 30, 'oppo_Stage', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PROpportunityMembershipSummary', 40, 'oppo_Closed', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PROpportunityMembershipSummary', 90, 'oppo_PRLostReason', 0, 1, 1, 0

EXEC usp_AddCustom_Screens 'PRBlueprintsOpportunitySummary', 10, 'oppo_Status', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRBlueprintsOpportunitySummary', 20, 'oppo_Opened', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRBlueprintsOpportunitySummary', 25, 'oppo_SignedAuthReceivedDate', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRBlueprintsOpportunitySummary', 30, 'oppo_Stage', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRBlueprintsOpportunitySummary', 40, 'oppo_Closed', 0, 1, 1, 0

UPDATE Custom_Captions
   SET capt_code = 'DealLost'
 WHERE capt_code = 'Deal Lost'
   AND capt_family = 'oppo_PRStage';


exec usp_AddCustom_ScreenObjects 'PROpportunityGrid', 'List', 'vPROpportunityListing', 'N', 0, 'vPROpportunityListing'
exec usp_AddCustom_Lists 'PROpportunityGrid', 10, 'oppo_Opened', null, 'Y', 'Y', '', 'Custom', '', '', 'PROpportunity/PROpportunityRedirect.asp', 'oppo_opportunityid'
exec usp_AddCustom_Lists 'PROpportunityGrid', 20, 'oppo_PrimaryCompanyId', null, 'Y', '', 'Custom', '', '', 'PRCompany/PRCompanySummary.asp', 'comp_companyid'
exec usp_AddCustom_Lists 'PROpportunityGrid', 30, 'CityStateCountryShort', null, 'Y'
exec usp_AddCustom_Lists 'PROpportunityGrid', 40, 'oppo_Type', null, 'Y'
exec usp_AddCustom_Lists 'PROpportunityGrid', 50, 'oppo_PRType', null, 'Y'
exec usp_AddCustom_Lists 'PROpportunityGrid', 60, 'OppoStage', null, 'Y'
exec usp_AddCustom_Lists 'PROpportunityGrid', 70, 'oppo_PRPipeline', null, 'Y'
exec usp_AddCustom_Lists 'PROpportunityGrid', 80, 'oppo_AssignedUserId', null, 'Y'