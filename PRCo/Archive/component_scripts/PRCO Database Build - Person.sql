SET NOCOUNT ON
GO
DECLARE @CustomContent varchar(8000)
-- Create a table named "tAccpacComponent" that has a single column and value, the Accpac 
-- Component name value.  All create methods will look to this table first to determine 
-- if a vlue is set.  If it finds it, this value will be used; if not, the entity name is
-- used as the component name value
-- This allows us to "block" together components as we set up the custom tables and fields.

-- create the physical table 
-- search for PRCompanyClassification to see how this is used   
DECLARE @DEFAULT_COMPONENT_NAME nvarchar(20)
SET @DEFAULT_COMPONENT_NAME = 'PRPerson'

IF not exists (select 1 from sysobjects where id = object_id('tAccpacComponentName') 
			and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
  CREATE TABLE dbo.tAccpacComponentName ( ComponentName nvarchar(20) NULL )
  -- Create a default row so that all we have to do are updates
  Insert into tAccpacComponentName Values (@DEFAULT_COMPONENT_NAME)
END


-- ****************************************************************************
-- *******************  PRPerson  ********************************************
-- * Perform Specific updates without changing the component name
-- Hide these tabs
UPDATE Custom_Tabs SET Tabs_Deleted = 1 WHERE Tabs_Entity = 'Person' AND tabs_deviceid is null
        AND (
                tabs_Caption in ('QuickLook','SelfService','Marketing','Addresses','Phone/Email', 'Notes')
            )
-- Update the tab's targets
UPDATE Custom_Tabs SET Tabs_Action = 'customfile', Tabs_CustomFileName = 'PRPerson/PRPersonCases.asp' 
 WHERE Tabs_Entity = 'Person' and Tabs_caption = 'Cases' and Tabs_DeviceId is NULL

-- Setting the tabs_Sensitive field to null removes the team restriction for users accessing
-- these tabs; this was showing as the red "no access" icon for these tabs after a new
-- person was created
update custom_tabs set tabs_Sensitive = null
 where tabs_entity = 'Person'
  and tabs_deviceid is null 
  and tabs_caption in ('Opportunities', 'Cases', 'Communications')

-- Change the custom_content scripts for out-of-the-box accpac screens; don't do this in 
-- screen scripts because the entity and compoent names get updated, then standard accpac 
-- fields will get removed by our unistall scripts
SET @CustomContent = 
        '<script language=javascript src="../CustomPages/PRCoGeneral.js"></script>' +
        '<script language=javascript src="../CustomPages/PRPerson/PRPersonInclude.js"></script>' +
        '<script language=javascript>' + 
        'document.write(new String( location.href ));RedirectPerson();' + 
        '</script>'
UPDATE Custom_ScreenObjects set CObj_CustomContent = @CustomContent WHERE CObj_Name = 'PersonBoxDedupe'
UPDATE Custom_ScreenObjects set CObj_CustomContent = @CustomContent WHERE CObj_Name = 'PersonBoxLong'

SET @CustomContent = 
        '<script language=javascript src="../CustomPages/PRCoGeneral.js"></script>' +
        '<script language=javascript src="../CustomPages/PRPerson/PRPersonInclude.js"></script>' +
        '<script language=javascript>' + 
        '    var sUrl = String(location.href); '+
        '    var ndxAct = sUrl.indexOf("Act=186"); '+
        '    if (ndxAct > -1){ '+
        '        window.onload = ProcessPersonNotes; '+
        '            ' + 
        '    }' + 
        '</script>'
UPDATE Custom_ScreenObjects set CObj_CustomContent = @CustomContent WHERE CObj_Name = 'NoteFilterBox'



--
-- Remove some fields from the default PersonSearchBox
--
UPDATE custom_screens
   SET seap_Deleted = 1
 WHERE seap_SearchBoxName='PersonSearchBox'
   AND seap_DeviceID IS NULL
   AND seap_ColName in ('pers_phoneareacode', 'pers_phonenumber', 'pers_emailaddress', 'addr_city', 'addr_postcode', 'pers_secterr', 'pers_primaryuserid');

-- Update the ordering on the PersonSearchBox so that we can insert a few fields
UPDATE custom_screens
   SET seap_Order = seap_Order * 20
 WHERE seap_SearchBoxName='PersonSearchBox' AND seap_DeviceID IS NULL AND seap_Order <= 19;

-- Update the ordering on the PersonGrid so that we can insert a few fields
UPDATE custom_lists
   SET grip_Order = grip_Order * 20
 WHERE grip_GridName = 'PersonGrid' AND grip_DeviceID IS NULL and grip_order <= 19;
-- remove the hyperlink from the company name column
update custom_lists set grip_Jump = null 
 where grip_GridName = 'PersonGrid' AND grip_DeviceID IS NULL and grip_colname = 'comp_name'


-- PERSON

exec usp_AccpacCreateTextField 'Person', 'pers_PRYearBorn', 'Year Born', 10
exec usp_AccpacCreateTextField 'Person', 'pers_PRDeathDate', 'Date of Death', 10
exec usp_AccpacCreateMultiselectField 'Person', 'pers_PRLanguageSpoken', 'Languages Spoken', 'pers_PRLanguageSpoken', 10
exec usp_AccpacCreateTextField 'Person', 'pers_PRPaternalLastName', 'Paternal Last Name', 15
exec usp_AccpacCreateTextField 'Person', 'pers_PRMaternalLastName', 'Maternal Last Name', 15
exec usp_AccpacCreateTextField 'Person', 'pers_PRNickname1', 'Nickname 1', 20
exec usp_AccpacCreateTextField 'Person', 'pers_PRNickname2', 'Nickname 2', 15
exec usp_AccpacCreateTextField 'Person', 'pers_PRMaidenName', 'Maiden Name', 20
exec usp_AccpacCreateTextField 'Person', 'pers_PRIndustryStartDate', 'Industry Start Year', 10
exec usp_AccpacCreateMultilineField     'Person', 'pers_PRNotes', 'Notes', 75, '5'
exec usp_AccpacCreateIntegerField 'Person', 'pers_PRDefaultEmailId', 'Default Email'

-- AUS
exec usp_AccpacCreateTable 'PRAUS', 'prau', 'prau_AUSId'
exec usp_AccpacCreateKeyField 'PRAUS', 'prau_AUSId', 'AUS Id' 

exec usp_AccpacCreateSearchSelectField 'PRAUS', 'prau_PersonId', 'Person', 'Person', 50, '18', NULL, 'Y'  
exec usp_AccpacCreateSearchSelectField 'PRAUS', 'prau_CompanyId', 'Company', 'Company', 50, '17', NULL, 'Y' 
exec usp_AccpacCreateSearchSelectField 'PRAUS', 'prau_MonitoredCompanyId', 'Monitored Company', 'Company', 50, '17', NULL, 'Y' 
exec usp_AccpacCreateCheckboxField 'PRAUS', 'prau_ShowOnHomePage', 'Show On Home Page'


-- PERSON BACKGROUND
exec usp_AccpacCreateTable 'PRPersonBackground', 'prba', 'prba_PersonBackgroundId'
exec usp_AccpacCreateKeyField 'PRPersonBackground', 'prba_PersonBackgroundId', 'Person Background Id' 

exec usp_AccpacCreateSearchSelectField 'PRPersonBackground', 'prba_PersonId', 'Person', 'Person',10, '0', NULL, 'Y'
exec usp_AccpacCreateTextField 'PRPersonBackground', 'prba_StartDate', 'Start', 50
exec usp_AccpacCreateTextField 'PRPersonBackground', 'prba_EndDate', 'End', 50
exec usp_AccpacCreateTextField 'PRPersonBackground', 'prba_Company', 'Company', 50
exec usp_AccpacCreateTextField 'PRPersonBackground', 'prba_Title', 'Title', 50

-- PERSON EVENT
exec usp_AccpacCreateTable 'PRPersonEvent', 'prpe', 'prpe_PersonEventId'
exec usp_AccpacCreateKeyField 'PRPersonEvent', 'prpe_PersonEventId', 'Person Event Id' 

exec usp_AccpacCreateSearchSelectField 'PRPersonEvent', 'prpe_PersonId', 'Person', 'Person', 10, '0', NULL, 'Y'
exec usp_AccpacCreateSearchSelectField 'PRPersonEvent', 'prpe_PersonEventTypeId', 'Type', 'PRPersonEventType', 10, '0', NULL, 'Y'
exec usp_AccpacCreateDateField 'PRPersonEvent', 'prpe_Date', 'Date'
exec usp_AccpacCreateTextField 'PRPersonEvent', 'prpe_Description', 'Description', 75
exec usp_AccpacCreateTextField 'PRPersonEvent', 'prpe_EducationalInstitution', 'Educational Institution', 75
exec usp_AccpacCreateTextField 'PRPersonEvent', 'prpe_EducationalDegree', 'Educational Degree', 75
exec usp_AccpacCreateSelectField 'PRPersonEvent', 'prpe_BankruptcyType', 'Bankruptcy Type', 'prpe_BankruptcyType' 
exec usp_AccpacCreateCheckboxField 'PRPersonEvent', 'prpe_USBankruptcyVoluntary', 'US Bankruptcy Voluntary'
exec usp_AccpacCreateSelectField 'PRPersonEvent', 'prpe_USBankruptcyCourt', 'US Bankruptcy Court', 'prpe_USBankruptcyCourt' 
exec usp_AccpacCreateTextField 'PRPersonEvent', 'prpe_CaseNumber', 'Case #', 25
exec usp_AccpacCreateSelectField 'PRPersonEvent', 'prpe_DischargeType', 'Discharge Type', 'prpe_DischargeType' 
exec usp_AccpacCreateMultilineField 'PRPersonEvent', 'prpe_PublishedAnalysis', 'Published Analysis', 75, '5'
exec usp_AccpacCreateMultilineField 'PRPersonEvent', 'prpe_InternalAnalysis', 'Internal Analysis', 75, '5'
exec usp_AccpacCreateDateField 'PRPersonEvent', 'prpe_PublishUntilDate', 'Publish Until Date'
exec usp_AccpacCreateCheckboxField 'PRPersonEvent', 'prpe_PublishCreditSheet', 'Publish Credit Sheet Item'

-- PERSON LINK
exec usp_AccpacCreateAdvSearchSelectField 'Person_Link', 'peli_PRCompanyId', 'Company', 'Company', 10, 'Y', 'Y', 'Y', NULL, 50
exec usp_AccpacCreateMultiSelectField 'Person_Link', 'peli_PRRole', 'Role', 'peli_PRRole'
-- adding peli_PROwnershipRole and peli_PRAttentionLineRole which will be split out of peli_PRRole.
exec usp_AccpacCreateSelectField 'Person_Link', 'peli_PROwnershipRole', 'Ownership Role', 'peli_PROwnershipRole' 
exec usp_AccpacCreateMultiSelectField 'Person_Link', 'peli_PRRecipientRole', 'Recipient Role', 'peli_PRRecipientRole'
exec usp_AccpacCreateSelectField 'Person_Link', 'peli_PRTitleCode', 'Generic Title', 'Pers_TitleCode' 
exec usp_AccpacCreateTextField 'Person_Link', 'peli_PRDLTitle', 'D/L Title', 30
exec usp_AccpacCreateTextField 'Person_Link', 'peli_PRTitle', 'Published Title', 45
exec usp_AccpacCreateTextField 'Person_Link', 'peli_PRResponsibilities', 'Responsibilities (published)', 75
exec usp_AccpacCreateNumericField 'Person_Link', 'peli_PRPctOwned', 'Pct Owned', 10
exec usp_AccpacCreateCheckboxField 'Person_Link', 'peli_PREBBPublish', 'EBB Publish'
exec usp_AccpacCreateCheckboxField 'Person_Link', 'peli_PRBRPublish', 'BR Publish'
exec usp_AccpacCreateSelectField 'Person_Link', 'peli_PRExitReason', 'Exit Reason', 'peli_PRExitReason'
exec usp_AccpacCreateTextField 'Person_Link', 'peli_PRRatingLine', 'Rating Line', 50
exec usp_AccpacCreateTextField 'Person_Link', 'peli_PRStartDate', 'Start Year', 4
exec usp_AccpacCreateTextField 'Person_Link', 'peli_PREndDate', 'End Year', 4
exec usp_AccpacCreateSelectField 'Person_Link', 'peli_PRStatus', 'Status', 'peli_PRStatus' 
exec usp_AccpacCreateCheckboxField 'Person_Link', 'peli_WebStatus', 'Web Status'
exec usp_AccpacCreateTextField 'Person_Link', 'peli_WebPassword', 'Web Password', 8
-- fields for AUS Preferences; these are global for all AUS entries; moving these to PersonLink to 
-- tie a company to the settings also
exec usp_AccpacCreateSelectField 'Person_Link', 'peli_PRAUSReceiveMethod', 'AUS Receive Method', 'peli_PRAUSReceiveMethod'
exec usp_AccpacCreateSelectField 'Person_Link', 'peli_PRAUSChangePreference', 'AUS Change Preference', 'peli_PRAUSChangePreference' 
exec usp_AccpacCreateTextField 'Person_Link', 'peli_PRWhenVisited', 'When Visited', 50
exec usp_AccpacCreateCheckboxField 'Person_Link', 'peli_PRReceivesBBScoreReport', 'Receives BB Score Report for Company'

-- PERSON RELATIONSHIP
exec usp_AccpacCreateTable 'PRPersonRelationship', 'prpr', 'prpr_PersonRelationshipId'
exec usp_AccpacCreateKeyField 'PRPersonRelationship', 'prpr_PersonRelationshipId', 'Person Relationship Id' 

exec usp_AccpacCreateSearchSelectField 'PRPersonRelationship', 'prpr_LeftPersonId', 'Primary Person', 'Person', 50, '0', NULL, 'Y'
exec usp_AccpacCreateSearchSelectField 'PRPersonRelationship', 'prpr_RightPersonId', 'Related Person', 'Person', 50, '0', NULL, 'Y'
exec usp_AccpacCreateTextField 'PRPersonRelationship', 'prpr_Description', 'Description', 50, 200
exec usp_AccpacCreateSelectField 'PRPersonRelationship', 'prpr_Source', 'Source', 'prpr_Source' 

-- Set up the Component name back to the original value
UPDATE tAccpacComponentName SET ComponentName = @DEFAULT_COMPONENT_NAME

-- *******************  END PRPerson  ****************************************
-- ****************************************************************************


DROP TABLE tAccpacComponentName 

GO

SET NOCOUNT OFF
GO

-- ********************* END TABLE AND FIELD CREATION *************************

