/*
 * Begin Mods to CRM Archvie due to CRM 6.2 Changes
 */

--ALTER TABLE CRMArchive.dbo.Comm_Link ADD cmli_Comm_AccountId int
--ALTER TABLE CRMArchive.dbo.Communication ADD comm_Organizer nvarchar(385)
--ALTER TABLE CRMArchive.dbo.Communication ADD comm_OrderId int
--ALTER TABLE CRMArchive.dbo.Communication ADD comm_QuoteId int
--ALTER TABLE CRMArchive.dbo.Communication ADD comm_OutlookID nvarchar(30)
--ALTER TABLE CRMArchive.dbo.Communication ADD comm_MeetingID nvarchar(200)

--ALTER TABLE CRMArchive.dbo.PRRequest ADD prreq_SourceID int
--ALTER TABLE CRMArchive.dbo.PRRequest ADD prreq_SourceEntity varchar(100)
--Go



/*
 * Begin External News Modifications 
 */
EXEC usp_AccpacCreateTable @EntityName='PRCompanyExternalNews', @ColPrefix='prcen', @IDField='prcen_CompanyCodeID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyField          'PRCompanyExternalNews', 'prcen_CompanyCodeID', 'Company Code ID'
EXEC usp_AccpacCreateSearchSelectField 'PRCompanyExternalNews', 'prcen_CompanyID', 'Company', 'Company', 100 
EXEC usp_AccpacCreateTextField         'PRCompanyExternalNews', 'prcen_Code', 'Code', 50, 50
EXEC usp_AccpacCreateSelectField       'PRCompanyExternalNews', 'prcen_PrimarySourceCode', 'Primary Source', 'ExternalNewsPrimarySource'
EXEC usp_AccpacCreateDateTimeField     'PRCompanyExternalNews', 'prcen_LastRetrievalDateTime', 'Last Retrieval Date/Time'
EXEC usp_AccpacCreateCheckboxField     'PRCompanyExternalNews', 'prcen_Exclude', 'Exclude'


EXEC usp_AccpacCreateTable @EntityName='PRExternalNews', @ColPrefix='pren', @IDField='pren_ExternalNewsID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyField          'PRExternalNews', 'pren_ExternalNewsID', 'External News ID'
EXEC usp_AccpacCreateSearchSelectField 'PRExternalNews', 'pren_SubjectCompanyID', 'Company', 'Company', 100 
EXEC usp_AccpacCreateTextField         'PRExternalNews', 'pren_Name', 'Name', 50, 500
EXEC usp_AccpacCreateTextField         'PRExternalNews', 'pren_URL', 'Web Address', 50, 500
EXEC usp_AccpacCreateTextField         'PRExternalNews', 'pren_Description', 'Description', 50, 1000
EXEC usp_AccpacCreateSelectField       'PRExternalNews', 'pren_PrimarySourceCode', 'Primary Source', 'ExternalNewsPrimarySource'
EXEC usp_AccpacCreateTextField         'PRExternalNews', 'pren_SecondarySourceCode', 'Secondary Source Code', 50, 50
EXEC usp_AccpacCreateTextField         'PRExternalNews', 'pren_SecondarySourceName', 'Secondary Source Name', 50, 150
EXEC usp_AccpacCreateDateTimeField     'PRExternalNews', 'pren_PublishDateTime', 'Publish Date/Time'
EXEC usp_AccpacCreateTextField         'PRExternalNews', 'pren_ExternalID', 'External ID', 50, 50

EXEC usp_AccpacCreateTable @EntityName='PRExternalNewsAuditTrail', @ColPrefix='prenat', @IDField='prenat_ExternalNewsAuditTrailID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyField          'PRExternalNewsAuditTrail', 'prenat_ExternalNewsAuditTrailID', 'External News Audit Trail ID'
EXEC usp_AccpacCreateIntegerField      'PRExternalNewsAuditTrail', 'prenat_WebUserID', 'Web User'
EXEC usp_AccpacCreateSearchSelectField 'PRExternalNewsAuditTrail', 'prenat_SubjectCompanyID', 'Company', 'Subject Company', 100 
EXEC usp_AccpacCreateTextField         'PRExternalNewsAuditTrail', 'prenat_Name', 'Name', 50, 500
EXEC usp_AccpacCreateTextField         'PRExternalNewsAuditTrail', 'prenat_URL', 'Web Address', 50, 500
EXEC usp_AccpacCreateSelectField       'PRExternalNewsAuditTrail', 'prenat_PrimarySource', 'Primary Source', 'ExternalNewsPrimarySource'
EXEC usp_AccpacCreateTextField         'PRExternalNewsAuditTrail', 'prenat_SecondarySource', 'Secondary Source', 50, 50
EXEC usp_AccpacCreateTextField         'PRExternalNewsAuditTrail', 'prenat_TriggerPage', 'Trigger Page', 50, 500


/*
 * Begin Sales Modifications 
 */
EXEC usp_AccpacCreateSelectField	'Opportunity', 'oppo_PRDisposition', 'Stage Disposition', 'oppo_PRDisposition'
EXEC usp_AccpacCreateDateTimeField  'Opportunity', 'oppo_PRLeadDateTime', 'Lead Date/Time'
EXEC usp_AccpacCreateDateTimeField  'Opportunity', 'oppo_PRProspectDateTime', 'Prospect Date/Time'
EXEC usp_AccpacCreateDateTimeField  'Opportunity', 'oppo_PROpportunityDateTime', 'Opportuinty Date/Time'
EXEC usp_AccpacCreateIntegerField   'Opportunity', 'oppo_EmailWaveID', 'Email Wave ID'
EXEC usp_AccpacCreateDateTimeField  'Opportunity', 'oppo_EmailSentDateTime', 'Email Sent Date/Time'
EXEC usp_AccpacCreateDateTimeField  'Opportunity', 'oppo_EmailOpenDateTime', 'Email Opened Date/Time'
EXEC usp_AccpacCreateDateTimeField  'Opportunity', 'oppo_EmailClickDateTime', 'Email Clicked Date/Time'

EXEC usp_AddCustom_ScreenObjects 'PRSalesManagementFilter', 'SearchScreen', 'Opportunity', 'N', 0, 'Opportunity'
EXEC usp_AddCustom_Screens 'PRSalesManagementFilter', 10, 'oppo_PrimaryCompanyId', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRSalesManagementFilter', 20, 'oppo_Status', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRSalesManagementFilter', 30, 'oppo_Type', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRSalesManagementFilter', 40, 'oppo_PRCertainty', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRSalesManagementFilter', 50, 'Oppo_Stage', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRSalesManagementFilter', 60, 'oppo_PRTargetIssue', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRSalesManagementFilter', 70, 'oppo_Opened', 1, 2, 1, 0
EXEC usp_AddCustom_Screens 'PRSalesManagementFilter', 80, 'oppo_WaveItemId', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRSalesManagementFilter', 90, 'oppo_PRPipeline', 0, 1, 1, 0

exec usp_AddCustom_Lists 'PROpportunityGrid', 10, 'oppo_Opened', null, 'Y', 'Y', '', 'Custom', '', '', 'PROpportunity/PROpportunitySummary.asp', 'oppo_opportunityid'

EXEC usp_AddCustom_ScreenObjects 'PROpportunitySummary', 'Screen', 'Opportunity', 'N', 0, 'Opportunity'
EXEC usp_AddCustom_Screens 'PROpportunitySummary', 10, 'oppo_Type', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PROpportunitySummary', 20, 'oppo_Status', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PROpportunitySummary', 30, 'oppo_Stage', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PROpportunitySummary', 40, 'oppo_PrimaryCompanyId', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PROpportunitySummary', 50, 'oppo_PrimaryPersonId', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PROpportunitySummary', 60, 'oppo_PRSecondaryPersonID', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PROpportunitySummary', 70, 'oppo_Opened', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PROpportunitySummary', 80, 'oppo_Closed', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PROpportunitySummary', 90, 'oppo_AssignedUserId', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PROpportunitySummary', 200, 'oppo_PRPipeline', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PROpportunitySummary', 210, 'oppo_PRTrigger', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PROpportunitySummary', 220, 'oppo_Source', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PROpportunitySummary', 220, 'oppo_PRType', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PROpportunitySummary', 240, 'oppo_Forecast', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PROpportunitySummary', 250, 'oppo_PRCertainty', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PROpportunitySummary', 260, 'oppo_Note', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PROpportunitySummary', 270, 'oppo_Priority', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PROpportunitySummary', 280, 'oppo_PRLostReason', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PROpportunitySummary', 300, 'oppo_PRAdRun', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PROpportunitySummary', 310, 'oppo_PRTargetStartYear', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PROpportunitySummary', 320, 'oppo_PRTargetStartMonth', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PROpportunitySummary', 330, 'oppo_PRAdRenewal', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PROpportunitySummary', 340, 'oppo_SignedAuthReceivedDate', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PROpportunitySummary', 400, 'oppo_PRReferredByCompanyId', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PROpportunitySummary', 410, 'oppo_PRReferredByPersonId', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PROpportunitySummary', 420, 'oppo_PRReferredByUserId', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PROpportunitySummary', 430, 'Oppo_WaveItemId', 1, 1, 1, 0


UPDATE custom_captions SET capt_us = 'Type' WHERE capt_code = 'oppo_Type' AND capt_family = 'ColNames';
UPDATE custom_captions SET capt_us = 'Primary Person' WHERE capt_code = 'oppo_PrimaryPersonId' AND capt_family = 'ColNames';
UPDATE custom_captions SET capt_us = 'Secondary Person' WHERE capt_code = 'oppo_PRSecondaryPersonID' AND capt_family = 'ColNames';
UPDATE custom_captions SET capt_us = 'Date Opened' WHERE capt_code = 'oppo_Opened' AND capt_family = 'ColNames';
UPDATE custom_captions SET capt_us = 'Date Closed' WHERE capt_code = 'oppo_Closed' AND capt_family = 'ColNames';
UPDATE custom_captions SET capt_us = 'Source' WHERE capt_code = 'oppo_Source' AND capt_family = 'ColNames';
UPDATE custom_captions SET capt_us = 'Sub Type' WHERE capt_code = 'oppo_PRType' AND capt_family = 'ColNames';
UPDATE custom_captions SET capt_us = 'Forecast Amount' WHERE capt_code = 'oppo_Forecast' AND capt_family = 'ColNames';
UPDATE custom_captions SET capt_us = 'Certainty' WHERE capt_code = 'oppo_PRCertainty' AND capt_family = 'ColNames';
UPDATE custom_captions SET capt_us = 'Note/Details' WHERE capt_code = 'oppo_Note' AND capt_family = 'ColNames';
UPDATE custom_captions SET capt_us = 'Ad Run Time' WHERE capt_code = 'oppo_PRAdRun' AND capt_family = 'ColNames';
UPDATE custom_captions SET capt_us = 'Signed Auth Received Date' WHERE capt_code = 'oppo_SignedAuthReceivedDate' AND capt_family = 'ColNames';
UPDATE custom_captions SET capt_us = 'Referred By Company' WHERE capt_code = 'oppo_PRReferredByCompanyId' AND capt_family = 'ColNames';
UPDATE custom_captions SET capt_us = 'Referred by Person' WHERE capt_code = 'oppo_PRReferredByPersonId' AND capt_family = 'ColNames';
UPDATE custom_captions SET capt_us = 'Referred by BBSI Employee' WHERE capt_code = 'oppo_PRReferredByUserId' AND capt_family = 'ColNames';
UPDATE custom_captions SET capt_us = 'Ad Campaign' WHERE capt_code = 'Oppo_WaveItemId' AND capt_family = 'ColNames';

UPDATE custom_tabs
   SET tabs_caption = 'Sales Mgmt'
 WHERE tabs_caption = 'Opportunities'

/*
 * Begin Company Search Modifications 
 */
EXEC usp_AccpacCreateTextField 'PRCompanySearch', 'prcse_NameMatch', 'Company Name Match', 104, 104
EXEC usp_AccpacCreateTextField 'PRCompanySearch', 'prcse_LegalNameMatch', 'Company Legal Name Match', 104, 104
EXEC usp_AccpacCreateTextField 'PRCompanySearch', 'prcse_CorrTradestyleMatch', 'Company Correspondence Name Match', 104, 104



EXEC usp_AccpacCreateIntegerField 'PRWebUser', 'prwu_MessageLoginCount', 'Message Login Count'



UPDATE custom_tabs
   SET tabs_Action = 'customfile',
       tabs_CustomFileName = 'InteractionRedirect.asp',
       tabs_Sensitive = null
 WHERE tabs_Caption = 'Interactions'	
   AND tabs_DeviceID IS NULL
   AND tabs_action = 'communicationlist';   
   
UPDATE custom_tabs
   SET tabs_CustomFileName = 'PROpportunity/PROpportunitySummary.asp'
 WHERE tabs_CustomFileName = 'PROpportunity/PROpportunityRedirect.asp'
   AND tabs_deviceid is null;   
Go   
   
DELETE FROM Users WHERE user_UserID < 0;   
INSERT INTO Users (user_UserID, User_Logon, user_FirstName, user_LastName, user_Disabled) VALUES (-1, 'sg1', 'System', 'Generated', 'Y');   
INSERT INTO Users (user_UserID, User_Logon, user_FirstName, user_LastName, user_Disabled) VALUES (-1000, 'sg1000', 'System', 'Generated', 'Y');   
INSERT INTO Users (user_UserID, User_Logon, user_FirstName, user_LastName, user_Disabled) VALUES (-350, 'sg350', 'System', 'Generated', 'Y');   
INSERT INTO Users (user_UserID, User_Logon, user_FirstName, user_LastName, user_Disabled) VALUES (-200, 'sg200', 'System', 'Generated', 'Y');   
INSERT INTO Users (user_UserID, User_Logon, user_FirstName, user_LastName, user_Disabled) VALUES (-100, 'sg100', 'System', 'Generated', 'Y');   
INSERT INTO Users (user_UserID, User_Logon, user_FirstName, user_LastName, user_Disabled) VALUES (-55, 'sg55', 'System', 'Generated', 'Y');           
Go



-- PRARAgingOnLumberGrid
EXEC usp_DeleteCustom_Screen 'PRARAgingOnLumberGrid'
EXEC usp_AddCustom_ScreenObjects 'PRARAgingOnLumberGrid', 'List', 'PRARAging', 'N', 0, 'vPRARAgingDetailOn'
EXEC usp_AddCustom_Lists 'PRARAgingOnLumberGrid', 5, 'praa_Date', '', 'Y';
EXEC usp_AddCustom_Lists 'PRARAgingOnLumberGrid', 10, 'praad_ReportingCompanyId', '', 'Y';
EXEC usp_AddCustom_Lists 'PRARAgingOnLumberGrid', 15, 'praad_ReportingCompanyName', '', 'Y';
EXEC usp_AddCustom_Lists 'PRARAgingOnLumberGrid', 20, 'Level1ClassificationValues', '', 'Y';
EXEC usp_AddCustom_Lists 'PRARAgingOnLumberGrid', 30, 'praad_AmountCurrent', '', 'Y', '', 'RIGHT'
EXEC usp_AddCustom_Lists 'PRARAgingOnLumberGrid', 35, 'praad_AmountCurrentPercent', '', 'Y', '', 'RIGHT'
EXEC usp_AddCustom_Lists 'PRARAgingOnLumberGrid', 40, 'praad_Amount1to30', '', 'Y', '', 'RIGHT'
EXEC usp_AddCustom_Lists 'PRARAgingOnLumberGrid', 45, 'praad_Amount1to30Percent', '', 'Y', '', 'RIGHT'
EXEC usp_AddCustom_Lists 'PRARAgingOnLumberGrid', 50, 'praad_Amount31to60', '', 'Y', '', 'RIGHT'
EXEC usp_AddCustom_Lists 'PRARAgingOnLumberGrid', 55, 'praad_Amount31to60Percent', '', 'Y', '', 'RIGHT'
EXEC usp_AddCustom_Lists 'PRARAgingOnLumberGrid', 60, 'praad_Amount61to90', '', 'Y', '', 'RIGHT'
EXEC usp_AddCustom_Lists 'PRARAgingOnLumberGrid', 65, 'praad_Amount61to90Percent', '', 'Y', '', 'RIGHT'
EXEC usp_AddCustom_Lists 'PRARAgingOnLumberGrid', 70, 'praad_Amount91Plus', '', 'Y', '', 'RIGHT'
EXEC usp_AddCustom_Lists 'PRARAgingOnLumberGrid', 75, 'praad_Amount91PlusPercent', '', 'Y', '', 'RIGHT'
EXEC usp_AddCustom_Lists 'PRARAgingOnLumberGrid', 80, 'praad_TotalAmount2', '', 'Y', '', 'RIGHT'
EXEC usp_AddCustom_Lists 'PRARAgingOnLumberGrid', 200, 'praad_Exception', '', 'Y', '', 'CENTER'

EXEC usp_AddCustom_Captions 'Tags', 'ColNames', 'praad_AmountCurrentPercent', 0, 'Current (%)', 'Current (%)', 'Current (%)', 'Current (%)', 'Current (%)', 'Current (%)', 'Current (%)'
Go

EXEC usp_AddCustom_Lists 'PRPublicationArticleGrid', 10, 'prpbar_Name', '', 'Y', '', '', 'Y', '', '', '', 'prpbar_PublicationArticleID'
Go


UPDATE custom_captions
   SET capt_us = 'Close Reason'
 WHERE CAST(capt_us As varchar(max)) = 'Lost Reason'
Go