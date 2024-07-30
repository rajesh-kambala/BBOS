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
SET @DEFAULT_COMPONENT_NAME = 'PRGeneral'

IF not exists (select 1 from sysobjects where id = object_id('tAccpacComponentName') 
			and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
  CREATE TABLE dbo.tAccpacComponentName ( ComponentName nvarchar(20) NULL )
  -- Create a default row so that all we have to do are updates
  Insert into tAccpacComponentName Values (@DEFAULT_COMPONENT_NAME)
END

-- ****************************************************************************
-- *******************  General  ********************************************

-- Register this view as an accpac table
exec usp_AccpacRegisterViewAsTable 'PRGeneral', 'vCommunication'

-- This statement updates the default date format for users to be 'mm/dd/yyyy'; 
-- UserPreferences records can still override this
Update custom_sysparams set Parm_Value = 'mm/dd/yyyy' where Parm_Name = 'DefaultUserDateFormat'
-- Chage the default location for the document drop.  This appears as the 
-- "Physical root directory for mail merged documents:" variable in the admin interface
update custom_sysparams SET parm_value = 'D:\SageCRM5.8\CRM\Library\' where parm_Name = 'DocStore'

-- Change the Find string next to the magnifying glass icon to read "Search"
update custom_captions set capt_US = 'Search' where Capt_Family = 'Button' and Capt_Code = 'Search'

-- Change the native values for the Opportunities listing on the Company, Person, My CRM and Team CRM pages
-- changing from 'opportunitieslist' and NULL, respectively
Update Custom_Tabs set tabs_action = 'customfile', tabs_CustomFileName = 'PROpportunity/PROpportunityListing.asp'
 WHERE rtrim(tabs_caption) = 'Opportunities' and Tabs_DeviceId is NULL
   and Tabs_Entity IN ('Company', 'Person', 'Channel', 'User')  

UPDATE Custom_Tabs SET Tabs_Action = 'customfile', Tabs_CustomFileName = 'PRUser/PRUserCases.asp' 
where rtrim(tabs_caption) = 'Cases' and Tabs_Entity = 'User' and Tabs_DeviceId is NULL
UPDATE Custom_Tabs SET Tabs_Action = 'customfile', Tabs_CustomFileName = 'PRChannel/PRChannelCases.asp' 
where rtrim(tabs_caption) = 'Cases' and Tabs_Entity = 'Channel' and Tabs_DeviceId is NULL


-- Update the link action from the CommunicationList grid
--UPDATE Custom_Lists SET grip_Jump = 'custom', grip_CustomAction = 'PRGeneral/PRInteraction.asp', grip_CustomIdField = 'comm_communicationid' 
 --WHERE grip_GridName = 'CommunicationList' And grip_ColName in ('Comm_Action', 'comm_HasAttachments') AND grip_DeviceId is null

-- Hide the "Library" and Leads tab from all screens
-- Currently this is "Case, Company, Opportunity, Person, PRBusinessEvent, PRFile, 
-- PRPersonEvent, Solutions, User (My CRM), and campaign (Team CRM)" for Library
UPDATE Custom_Tabs SET Tabs_Deleted = 1 WHERE tabs_Caption in ('Library', 'glibrarylist', 'Leads')

-- Hide the "Contacts" & "Dashboard" tabs for the User and Channel screens
UPDATE Custom_Tabs SET Tabs_Deleted = 1 WHERE Tabs_Entity in ('User', 'Channel')
        AND (tabs_Caption in ('My Contacts','My eCRM') ) and Tabs_DeviceId is NULL

-- Hide the "Notes", & "Tracking" tabs for the Case screens
UPDATE Custom_Tabs SET Tabs_Deleted = 1 WHERE Tabs_Entity ='Case'
        AND (tabs_Caption in ('Tracking','Notes') ) and Tabs_DeviceId is NULL
UPDATE Custom_Tabs SET Tabs_Action = 'customfile', Tabs_CustomFileName = 'PRCase/PRCustomerCare.asp' 
where rtrim(tabs_caption) = 'Summary' and Tabs_Entity = 'Case' and Tabs_DeviceId is NULL
-- Setting the tabs_Sensitive field to null removes the team restriction for users accessing
-- these tabs; this was showing as the red "no access" icon for these tabs
update custom_tabs set tabs_Sensitive = null
 where tabs_entity = 'Case' and tabs_caption in ('Communications','Solutions') and tabs_deviceid is null 
  


-- Hide these tabs for the Opportunity screens
UPDATE Custom_Tabs SET Tabs_Deleted = 1 WHERE Tabs_Entity ='Opportunity'
        AND (tabs_Caption in ('Quotes', 'Orders', 'OpportunityItems', 'Notes', 'Library', 'Tracking') ) 
        and Tabs_DeviceId is NULL
UPDATE Custom_Tabs SET Tabs_Action = 'customfile', Tabs_CustomFileName = 'PROpportunity/PROpportunityRedirect.asp' 
where rtrim(tabs_caption) = 'Summary' and Tabs_Entity = 'Opportunity' and Tabs_DeviceId is NULL

-- update the custom content of the native accpac Communication Filter box
SET @CustomContent = 
		'<script language=javascript src="../CustomPages/PRCoGeneral.js"></script>' +
        '<script language=javascript > ' + 
            'document.body.onload=function(){' + 
            'hideButton("/crm/img/Buttons/NewAppointment.gif");' + 
            'hideButton("/crm/img/Buttons/Delete.gif");' + 
            'RemoveDropdownItemByValue("comm_action", "M"); ' +
            'RemoveDropdownItemByValue("comm_action", "P"); ' +
            'RemoveDropdownItemByValue("comm_action", "E"); ' +
            'RemoveDropdownItemByValue("comm_action", "F"); ' +
            'RemoveDropdownItemByValue("comm_action", "T"); ' +
            'RemoveDropdownItemByValue("comm_action", "S"); ' +
            'RemoveDropdownItemByValue("comm_action", "L"); ' +
            'RemoveDropdownItemByValue("comm_action", "R"); ' +
            'RemoveDropdownItemByValue("comm_action", "O"); ' +
	        '}'+
        '</script>'

SET @CustomContent = 
        '<script language=javascript src="../CustomPages/PRCoGeneral.js"></script>' +
        '<script language=javascript src="../CustomPages/PRGeneral/PRInteraction.js"></script>' + 
        '<script language=javascript>'+ 
        'document.body.onload=function(){' + 
        '  Initialize();' + 
		'}'+
        '</script>'
update custom_ScreenObjects set cobj_CustomContent = @CustomContent where cobj_Name = 'CustomCommunicationDetailBox'

SET @CustomContent = 
        '<script language=javascript src="../CustomPages/PRCoGeneral.js"></script>' +
        '<script language=javascript src="../CustomPages/PRGeneral/PRInteraction.js"></script>' + 
        '<script language=javascript>'+ 
            'document.body.onload=function(){' + 
        'InitializeListing();' + 
	        '}'+
        '</script>'
update custom_ScreenObjects set cobj_CustomContent = @CustomContent where cobj_Name = 'CommunicationFilterBox'

SET @CustomContent = 
        '<script language=javascript src="../CustomPages/PRCoGeneral.js"></script>' +
        '<script language=javascript src="../CustomPages/PROpportunity/PROpportunity.js"></script>' + 
        '<script language=javascript>'+ 
        'document.body.onload=function(){' + 
        '  Initialize();' + 
		'}'+
        '</script>'
UPDATE Custom_ScreenObjects set CObj_CustomContent = @CustomContent WHERE CObj_Name = 'OpportunityWebPicker'

-- update the 'CustomCommunicationDetailBox' to create space to work and to set the details box
update custom_screens set seap_order = seap_order * 20 
 where seap_SearchBoxName = 'CustomCommunicationDetailBox' and seap_DeviceId is null
   and seap_Order < 12
-- now let the comm_note field move to it's own row
update custom_screens set seap_newline=1, seap_colspan=3 
 where seap_colName = 'comm_note'
   and seap_SearchBoxName = 'CustomCommunicationDetailBox' and seap_DeviceId is null
-- finally, make the comm_Note field a bit bigger than its native accpac width
update custom_edits set colp_EntrySize = 70 where colp_ColName = 'comm_note'

-- Change the label of the phone 'area' column.
UPDATE custom_captions SET capt_us = 'Area/City Code' WHERE capt_code='phon_AreaCode' AND capt_us='Area' AND capt_family='ColNames';

-- Change the label of the address line columns
UPDATE custom_captions SET capt_us = 'Address Line 1' WHERE capt_code='addr_Address1' AND capt_us='Address 1' AND capt_family='ColNames';	
UPDATE custom_captions SET capt_us = 'Address Line 2' WHERE capt_code='addr_Address2' AND capt_us='Address 2' AND capt_family='ColNames';	
UPDATE custom_captions SET capt_us = 'Address Line 3' WHERE capt_code='addr_Address3' AND capt_us='Address 3' AND capt_family='ColNames';	
UPDATE custom_captions SET capt_us = 'Address Line 4' WHERE capt_code='addr_Address4' AND capt_us='Address 4' AND capt_family='ColNames';	
UPDATE custom_captions SET capt_us = 'Address Line 5' WHERE capt_code='addr_Address5' AND capt_us='Address 5' AND capt_family='ColNames';	



-- ADDRESS
-- Add the additional fields to the base object
exec usp_AccpacCreateSearchSelectField 'Address', 'addr_PRCityId',   'City', 'vPRLocation', 50
exec usp_AccpacCreateTextField         'Address', 'addr_PRCounty',   'County', 30
exec usp_AccpacCreateSelectField       'Address', 'addr_PRZone',     'Zone', 'addr_PRZone' 
-- Removed per RSH implementation of adli_Slot
--exec usp_AccpacCreateIntegerField   'Address', 'addr_PRSequence', 'Sequence', 10
exec usp_AccpacCreateCheckboxField  'Address', 'addr_PRPublish', 'Publish'
exec usp_AccpacCreateTextField		'Address', 'addr_PRDescription', 'Description', 100, 100
exec usp_AccpacCreateIntegerField  'Address', 'addr_PRReplicatedFromId', 'Replicated From Address Id'
exec usp_AccpacCreateIntegerField  'Address', 'addr_PRAttentionLineType', 'Attention Line Type'
exec usp_AccpacCreateTextField		'Address', 'addr_PRAttentionLineCustom', 'Attention Line', 100, 100
exec usp_AccpacCreateSearchSelectField 'Address', 'addr_PRAttentionLinePersonId', 'Attention Line', 'Person', 100
-- Removed per RSH implementation of adli_Slot
--exec usp_AccpacCreateIntegerField   'Address', 'addr_PRSlot', 'BBS Slot Number', 10

-- ADDRESS LINK
-- Add the additional fields to the base object
exec usp_AccpacCreateSelectField   'Address_Link', 'adli_Type', 'Type', 'adli_Type' 
exec usp_AccpacCreateCheckboxField  'Address_Link', 'adli_PRDefaultMailing', 'Default Mailing'
exec usp_AccpacCreateCheckboxField  'Address_Link', 'adli_PRDefaultShipping', 'Default Shipping'
exec usp_AccpacCreateCheckboxField  'Address_Link', 'adli_PRDefaultTax', 'Default Tax'
exec usp_AccpacCreateCheckboxField  'Address_Link', 'adli_PRDefaultTES', 'Default TES'
exec usp_AccpacCreateCheckboxField  'Address_Link', 'adli_PRDefaultJeopardy', 'Default Jeopardy'
exec usp_AccpacCreateCheckboxField  'Address_Link', 'adli_PRDefaultListing', 'Default LRL'
exec usp_AccpacCreateCheckboxField  'Address_Link', 'adli_PRDefaultBilling', 'Default Billing'
exec usp_AccpacCreateIntegerField   'Address_Link', 'adli_PRSlot', 'BBS Slot Number', 10
--  set the component = null for default accpac fields so that uninstall scripts do not remove them
UPDATE Custom_Edits set colp_component = null where colp_colname in ('adli_Type')

--exec usp_AccpacCreateCheckboxField  'Address_Link', 'adli_PRDefault', 'Default'


-- BUSINESS EVENT
exec usp_AccpacCreateTable 'PRBusinessEvent', 'prbe', 'prbe_BusinessEventId'
exec usp_AccpacCreateKeyField 'PRBusinessEvent', 'prbe_BusinessEventId', 'Business Event Id' 

exec usp_AccpacCreateSearchSelectField 'PRBusinessEvent', 'prbe_CompanyId', 'Company', 'Company', 10, '17', NULL, 'Y' 
exec usp_AccpacCreateSelectField 'PRBusinessEvent', 'prbe_BusinessEventTypeId', 'Business Event Type', 'prbe_BusinessEventType'
--exec usp_AccpacCreateSearchSelectField 'PRBusinessEvent', 'prbe_BusinessEventTypeId', 'Business Event Type', 'PRBusinessEventType', 10, '0', NULL, 'Y' 
exec usp_AccpacCreateDateField 'PRBusinessEvent', 'prbe_EffectiveDate', 'Effective Date'
exec usp_AccpacCreateCheckboxField 'PRBusinessEvent', 'prbe_CreditSheetPublish', 'CS Publish'
exec usp_AccpacCreateMultilineField 'PRBusinessEvent', 'prbe_CreditSheetNote', 'Note', 75, '5'
exec usp_AccpacCreateMultilineField 'PRBusinessEvent', 'prbe_PublishedAnalysis', 'Published Analysis', 75, '5'
exec usp_AccpacCreateMultilineField 'PRBusinessEvent', 'prbe_InternalAnalysis', 'Internal Analysis', 75, '5'
exec usp_AccpacCreateDateField 'PRBusinessEvent', 'prbe_PublishUntilDate', 'Publish Until Date'
exec usp_AccpacCreateTextField 'PRBusinessEvent', 'prbe_AnticipatedCompletionDate', 'Ant Completion Date', 15
exec usp_AccpacCreateSelectField 'PRBusinessEvent', 'prbe_DisasterImpact', 'Disaster Impact', 'prbe_DisasterImpact'
exec usp_AccpacCreateTextField 'PRBusinessEvent', 'prbe_AttorneyName', 'Attorney Name', 30
exec usp_AccpacCreateTextField 'PRBusinessEvent', 'prbe_AttorneyPhone', 'Attorney Phone', 20
exec usp_AccpacCreateTextField 'PRBusinessEvent', 'prbe_CaseNumber', 'Case Number', 15
exec usp_AccpacCreateNumericField 'PRBusinessEvent', 'prbe_Amount', 'Amount', 10
exec usp_AccpacCreateNumericField 'PRBusinessEvent', 'prbe_AssetAmount', 'Asset Amount', 10
exec usp_AccpacCreateNumericField 'PRBusinessEvent', 'prbe_LiabilityAmount', 'Liability Amount', 10
exec usp_AccpacCreateSearchSelectField 'PRBusinessEvent', 'prbe_IndividualBuyerId', 'Individual Buyer', 'Person', 50 
exec usp_AccpacCreateSearchSelectField 'PRBusinessEvent', 'prbe_IndividualSellerId', 'Individual Seller', 'Person', 50 
exec usp_AccpacCreateSearchSelectField 'PRBusinessEvent', 'prbe_RelatedCompany1Id', 'Company', 'Company', 50 
exec usp_AccpacCreateSearchSelectField 'PRBusinessEvent', 'prbe_RelatedCompany2Id', 'Company', 'Company', 50 
exec usp_AccpacCreateSelectField 'PRBusinessEvent', 'prbe_AgreementCategory', 'Agreement Category', 'prbe_AgreementCategory' 
exec usp_AccpacCreateTextField 'PRBusinessEvent', 'prbe_AssigneeTrusteeName', 'Assignee Trustee Name', 30
exec usp_AccpacCreateTextField 'PRBusinessEvent', 'prbe_AssigneeTrusteeAddress', 'Assignee Trustee Address', 100, 200
exec usp_AccpacCreateTextField 'PRBusinessEvent', 'prbe_AssigneeTrusteePhone', 'Assignee Trustee Phone', 30
exec usp_AccpacCreateSelectField 'PRBusinessEvent', 'prbe_SpecifiedCSNumeral', 'Specified CS Numeral', 'prbe_SpecifiedCSNumeral' 
exec usp_AccpacCreateCheckboxField 'PRBusinessEvent', 'prbe_USBankruptcyVoluntary', 'US Bankruptcy Voluntary'
exec usp_AccpacCreateSelectField 'PRBusinessEvent', 'prbe_USBankruptcyEntity', 'Bankruptcy Entity', 'prbe_USBankruptcyEntity' 
exec usp_AccpacCreateSelectField 'PRBusinessEvent', 'prbe_USBankruptcyCourt', 'Bankruptcy Court', 'prbe_USBankruptcyCourt'
exec usp_AccpacCreateSearchSelectField 'PRBusinessEvent', 'prbe_StateId', 'State', 'PRState' 
exec usp_AccpacCreateTextField 'PRBusinessEvent', 'prbe_Names', 'Names', 100
exec usp_AccpacCreateNumericField 'PRBusinessEvent', 'prbe_PercentSold', '% Sold', 10
exec usp_AccpacCreateTextField 'PRBusinessEvent', 'prbe_CourtDistrict', 'Court District', 50
exec usp_AccpacCreateIntegerField 'PRBusinessEvent', 'prbe_NumberSellers', 'Number of Sellers', 10
exec usp_AccpacCreateTextField 'PRBusinessEvent', 'prbe_NonPromptStart', 'Non Prompt Start', 20
exec usp_AccpacCreateTextField 'PRBusinessEvent', 'prbe_NonPromptEnd', 'Non Prompt End', 20
exec usp_AccpacCreateDateField 'PRBusinessEvent', 'prbe_BusinessOperateUntil', 'Business Operate Until'
exec usp_AccpacCreateDateField 'PRBusinessEvent', 'prbe_IndividualOperateUntil', 'Individual Operate Until'
exec usp_AccpacCreateTextField 'PRBusinessEvent', 'prbe_DisplayedEffectiveDate', 'Displayed Effective Date', 20
exec usp_AccpacCreateSelectField 'PRBusinessEvent', 'prbe_DisplayedEffectiveDateStyle', 'Displayed Effective Date Style', 'prbe_DisplayedEffectiveDateStyle'
exec usp_AccpacCreateSelectField 'PRBusinessEvent', 'prbe_DetailedType', 'Type' 
exec usp_AccpacCreateMultilineField 'PRBusinessEvent', 'prbe_OtherDescription', 'Other Description', 75, '5'


-- BUSINESS REPORT REQUEST START

-- Set a component name because of the 20 character limitation
--UPDATE tAccpacComponentName SET ComponentName = 'PRBusReportRequest'

exec usp_AccpacCreateTable 'PRBusinessReportRequest', 'prbr', 'prbr_BusinessReportRequestId'
exec usp_AccpacCreateKeyField 'PRBusinessReportRequest', 'prbr_BusinessReportRequestId', 'Bus Rpt Request Id' 

exec usp_AccpacCreateSearchSelectField 'PRBusinessReportRequest', 'prbr_RequestingCompanyId', 'Requesting Company', 'Company', 50, '0', NULL 
exec usp_AccpacCreateSearchSelectField 'PRBusinessReportRequest', 'prbr_RequestingPersonId', 'Requesting Person', 'Person', 50, '0'
exec usp_AccpacCreateSearchSelectField 'PRBusinessReportRequest', 'prbr_RequestedCompanyId', 'Business Report On', 'Company', 50, '0', NULL 
exec usp_AccpacCreateSelectField 'PRBusinessReportRequest', 'prbr_MethodSent', 'Method Sent', 'prbr_MethodSent'
exec usp_AccpacCreateTextField 'PRBusinessReportRequest', 'prbr_RequestorInfo', 'Requestor Info', 50
exec usp_AccpacCreateTextField 'PRBusinessReportRequest', 'prbr_AddressLine1', 'Address', 50
exec usp_AccpacCreateTextField 'PRBusinessReportRequest', 'prbr_AddressLine2', 'Address 2', 50
exec usp_AccpacCreateTextField 'PRBusinessReportRequest', 'prbr_CityStateZip', 'City, State and Zip', 50
exec usp_AccpacCreateTextField 'PRBusinessReportRequest', 'prbr_Country', 'Country', 50
exec usp_AccpacCreateTextField 'PRBusinessReportRequest', 'prbr_Fax', 'Fax', 20
exec usp_AccpacCreateEmailField 'PRBusinessReportRequest', 'prbr_EmailAddress', 'Email'
exec usp_AccpacCreateCheckboxField  'PRBusinessReportRequest', 'prbr_DoNotChargeUnits', 'Do Not Charge Units'
exec usp_AccpacCreateCheckboxField  'PRBusinessReportRequest', 'prbr_SurveyIncluded', 'Survey Included'


-- CASES 
exec usp_AccpacCreateTextField 'Cases', 'case_PRCompanyITRep', 'Company IT Rep/Consultant/Other ', 50
exec usp_AccpacCreateIntegerField 'Cases', 'case_PRCallDuration', 'Call(s) Duration (minutes)'
exec usp_AccpacCreateSelectField 'Cases', 'case_PRServiceOffering', 'Service Offering', 'case_PRServiceOffering' 
exec usp_AccpacCreateMultiSelectField 'Cases', 'case_PROperatingSystem', 'Operating System', 'case_PROperatingSystem' 
exec usp_AccpacCreateSelectField 'Cases', 'case_PREBBNetworkStatus', 'EBB Network Status', 'case_PREBBNetworkStatus' 
exec usp_AccpacCreateSelectField 'Cases', 'case_PRResearchingReason', 'Researching Reason', 'case_PRResearchingReason' 
exec usp_AccpacCreateSelectField 'Cases', 'case_PRClosedReason', 'Closed Reason', 'case_PRClosedReason' 
-- modify the custom caption for the caption on Problem Type
update custom_captions set capt_US = 'EBB Problem Type' where capt_family = 'ColNames' and capt_code = 'case_problemtype'
-- modify the "area" field to be multiselect
update custom_edits set colp_EntryType = 28 where colp_ColName = 'case_productarea' 


-- CLASSIFICATION
exec usp_AccpacCreateTable 'PRClassification', 'prcl', 'prcl_ClassificationId'
exec usp_AccpacCreateKeyField 'PRClassification', 'prcl_ClassificationId', 'Classification Id' 

exec usp_AccpacCreateSelectField 'PRClassification', 'prcl_Level', 'Level', 'prcl_Level'
--exec usp_AccpacCreateIntegerField 'PRClassification', 'prcl_LevelAbove', 'Level Above', 10
exec usp_AccpacCreateIntegerField 'PRClassification', 'prcl_ParentId', 'ParentId', 10
exec usp_AccpacCreateTextField 'PRClassification', 'prcl_Name', 'Classification', 100
exec usp_AccpacCreateTextField 'PRClassification', 'prcl_SpanishName', 'Spanish Classification', 100
exec usp_AccpacCreateTextField 'PRClassification', 'prcl_Abbreviation', 'Abbreviation', 34
exec usp_AccpacCreateTextField 'PRClassification', 'prcl_Description', 'Description', 100, 200
exec usp_AccpacCreateTextField 'PRClassification', 'prcl_SpanishDescription', 'Spanish Description', 100, 200
exec usp_AccpacCreateSelectField 'PRClassification', 'prcl_BookSection', 'Book Section', 'prcl_BookSection' 
exec usp_AccpacCreateTextField 'PRClassification', 'prcl_Path', 'Path Ids', 100
exec usp_AccpacCreateTextField 'PRClassification', 'prcl_Line1', 'Line 1', 40
exec usp_AccpacCreateTextField 'PRClassification', 'prcl_Line2', 'Line 2', 40
exec usp_AccpacCreateTextField 'PRClassification', 'prcl_Line3', 'Line 3', 40
exec usp_AccpacCreateTextField 'PRClassification', 'prcl_Line4', 'Line 4', 40

-- COMMODITY
exec usp_AccpacCreateTable 'PRCommodity', 'prcm', 'prcm_CommodityId'
exec usp_AccpacCreateKeyField 'PRCommodity', 'prcm_CommodityId', 'Commodity Id' 

--exec usp_AccpacCreateIntegerField 'PRCommodity', 'prcm_CommodityNumber', 'Commodity #', 10
exec usp_AccpacCreateIntegerField 'PRCommodity', 'prcm_ParentId', 'Parent', 10
exec usp_AccpacCreateIntegerField 'PRCommodity', 'prcm_Level', 'Level', 10
--exec usp_AccpacCreateIntegerField 'PRCommodity', 'prcm_LevelAbove', 'Level Above', 10
exec usp_AccpacCreateTextField 'PRCommodity', 'prcm_Name', 'Commodity', 50
exec usp_AccpacCreateTextField 'PRCommodity', 'prcm_CommodityCode', 'Commodity Code', 34
exec usp_AccpacCreateTextField 'PRCommodity', 'prcm_Alias', 'Alias', 50, 200
exec usp_AccpacCreateTextField 'PRCommodity', 'prcm_SpanishName', 'Spanish Name', 50
exec usp_AccpacCreateCheckboxField 'PRCommodity', 'prcm_IPDFlag', 'IPD Flag'
--exec usp_AccpacCreateTextField 'PRCommodity', 'prcm_Path', 'Path', 50
exec usp_AccpacCreateTextField 'PRCommodity', 'prcm_PathNames', 'Path', 300
exec usp_AccpacCreateTextField 'PRCommodity', 'prcm_PathCodes', 'Path', 300
exec usp_AccpacCreateIntegerField 'PRCommodity', 'prcm_DisplayOrder', 'Display Order'

-- COMMUNICATIONS START
exec usp_AccpacCreateSearchSelectField 'Communication', 'comm_PRBusinessEventId', 'Business Event', 'PRBusinessEvent', 10, '19'
exec usp_AccpacCreateSearchSelectField 'Communication', 'comm_PRPersonEventId', 'Person Event', 'PRPersonEvent', 10, '19'
exec usp_AccpacCreateSearchSelectField 'Communication', 'comm_PRTESId', 'TES', 'PRTES', 10, '19'
exec usp_AccpacCreateSearchSelectField 'Communication', 'comm_PRCreditSheetId', 'Credit Sheet', 'PRCreditSheet', 10, '19'
exec usp_AccpacCreateSearchSelectField 'Communication', 'comm_PRFileId', 'File', 'PRFile', 10, '19'
exec usp_AccpacCreateSelectField 'Communication', 'comm_PRCategory', 'Category', 'comm_PRCategory' 
exec usp_AccpacCreateSelectField 'Communication', 'comm_PRSubcategory', 'Subcategory', 'comm_PRSubcategory' 
exec usp_AccpacCreateUserSelectField 'Communication','comm_PRAuthorId', 'Author'
exec usp_AccpacCreateIntegerField 'Communication','comm_PRCallAttemptCount', 'Call Attempt Counter', 5
-- this field is used internally to further identify the source of a task.  For instance, this field is set 
-- to prfi_DisputeRequestDueDate when creating a task for due date expiration review. if the dispute request 
-- response is received prior to the task due date, this field helps identify the task to be cancelled or deleted.
exec usp_AccpacCreateTextField 'Communication','comm_PRAssociatedColumnName', 'Col Name', 40

-- CREDIT SHEET ITEM
exec usp_AccpacCreateTable 'PRCreditSheet', 'prcs', 'prcs_CreditSheetId'
exec usp_AccpacCreateKeyField 'PRCreditSheet', 'prcs_CreditSheetId', 'Credit Sheet Id' 

exec usp_AccpacCreateSearchSelectField 'PRCreditSheet', 'prcs_CompanyId', 'Company', 'Company', 50, '0'
exec usp_AccpacCreateIntegerField   'PRCreditSheet', 'prcs_SourceId', 'Source Id', 10 
exec usp_AccpacCreateSelectField    'PRCreditSheet', 'prcs_SourceType', 'Type', 'prcs_SourceType' 
exec usp_AccpacCreateSelectField    'PRCreditSheet', 'prcs_Status', 'Status', 'prcs_Status' 
exec usp_AccpacCreateDateField      'PRCreditSheet', 'prcs_PublishableDate', 'Publishable Date'
exec usp_AccpacCreateUserSelectField 'PRCreditSheet','prcs_AuthorId', 'Author'
exec usp_AccpacCreateUserSelectField 'PRCreditSheet','prcs_ApproverId', 'Approver'
exec usp_AccpacCreateMultilineField 'PRCreditSheet', 'prcs_AuthorNotes', 'Author Notes', 75, '5'
exec usp_AccpacCreateCheckboxField  'PRCreditSheet', 'prcs_KeyFlag', 'Key'
exec usp_AccpacCreateMultilineField 'PRCreditSheet', 'prcs_ListingSpecialistNotes', 'Listing Specialist Notes', 75, '5'
exec usp_AccpacCreateMultilineField 'PRCreditSheet', 'prcs_Tradestyle', 'Tradestyle', 75, '2'
exec usp_AccpacCreateTextField      'PRCreditSheet', 'prcs_Numeral', 'Numeral', 75, '75'
exec usp_AccpacCreateMultilineField 'PRCreditSheet', 'prcs_Parenthetical', 'Parenthetical', 75, '4'
exec usp_AccpacCreateMultilineField 'PRCreditSheet', 'prcs_Change', 'Change', 75, '10'
exec usp_AccpacCreateMultilineField 'PRCreditSheet', 'prcs_RatingChangeVerbiage', 'Rating Change Verbiage', 75, '4'
exec usp_AccpacCreateTextField      'PRCreditSheet', 'prcs_RatingValue', 'Rating Value', 75, '75'
exec usp_AccpacCreateTextField      'PRCreditSheet', 'prcs_PreviousRatingValue', 'Previous Rating Value', 75, '75'
exec usp_AccpacCreateMultilineField 'PRCreditSheet', 'prcs_Notes', 'Notes', 75, '5'
exec usp_AccpacCreateDateField      'PRCreditSheet', 'prcs_EBBUpdatePubDate', 'EBB Update Publish Date'
exec usp_AccpacCreateDateField      'PRCreditSheet', 'prcs_ExpressUpdatePubDate', 'Express Update Publish Date'
exec usp_AccpacCreateDateField      'PRCreditSheet', 'prcs_WeeklyCSPubDate', 'Weekly CS Publish Date'
exec usp_AccpacCreateDateField      'PRCreditSheet', 'prcs_AUSDate', 'AUS Date'
exec usp_AccpacCreateTeamField      'PRCreditSheet', 'prcs_ChannelId', 'Team'
exec usp_AccpacCreateSearchSelectField 'PRCreditSheet', 'prcs_CityId', 'Listing City', 'vPRLocation', 50, '0'


-- DEAL
exec usp_AccpacCreateTable 'PRDeal', 'prde', 'prde_DealId'
exec usp_AccpacCreateKeyField 'PRDeal', 'prde_DealId', 'Deal Id' 

exec usp_AccpacCreateDateField 'PRDeal', 'prde_StartDate', 'Start Date'
exec usp_AccpacCreateDateField 'PRDeal', 'prde_EndDate', 'End Date'

-- DEAL COMMODITY START
exec usp_AccpacCreateTable 'PRDealCommodity', 'prdc', 'prdc_DealCommodityId'
exec usp_AccpacCreateKeyField 'PRDealCommodity', 'prdc_DealCommodityId', 'Deal Commodity Id' 

exec usp_AccpacCreateSearchSelectField 'PRDealCommodity', 'prdc_DealId', 'Deal', 'PRDeal', 10, '0', NULL, 'Y'
exec usp_AccpacCreateIntegerField 'PRDealCommodity', 'prdc_CommodityNumber', 'Commodity', 10

-- DEAL TERRITORY START
exec usp_AccpacCreateTable 'PRDealTerritory', 'prdt', 'prdt_DealTerritoryId'
exec usp_AccpacCreateKeyField 'PRDealTerritory', 'prdt_DealTerritoryId', 'Deal Territory Id' 

exec usp_AccpacCreateSearchSelectField 'PRDealTerritory', 'prdt_DealId', 'Deal', 'PRDeal', 10, '0', NULL, 'Y'
exec usp_AccpacCreateTextField 'PRDealTerritory', 'prdt_SalesTerritory', 'Territory', 50

-- DESCRIPTIVE LINE 
exec usp_AccpacCreateTable 'PRDescriptiveLine', 'prdl', 'prdl_DescriptiveLineId'
exec usp_AccpacCreateKeyField 'PRDescriptiveLine', 'prdl_DescriptiveLineId', 'Descriptive Line Id' 

exec usp_AccpacCreateSearchSelectField 'PRDescriptiveLine', 'prdl_CompanyId', 'Company', 'Company', 10 , '17'
exec usp_AccpacCreateTextField 'PRDescriptiveLine', 'prdl_LineContent', 'Line Content', 100

-- DESCRIPTIVE LINE USAGE
exec usp_AccpacCreateTable 'PRDescriptiveLineUsage', 'prd3', 'prd3_DescriptiveLineUsageId'
exec usp_AccpacCreateKeyField 'PRDescriptiveLineUsage', 'prd3_DescriptiveLineUsageId', 'DL Usage Id' 
exec usp_AccpacCreateSearchSelectField 'PRDescriptiveLineUsage', 'prd3_CompanyId', 'Company', 'Company', 10 , '17'
exec usp_AccpacCreateTextField 'PRDescriptiveLineUsage', 'prd3_FieldPointer', 'Field Pointer', 100

-- REGION 
exec usp_AccpacCreateTable 'PRRegion', 'prd2', 'prd2_RegionId'
exec usp_AccpacCreateKeyField 'PRRegion', 'prd2_RegionId', 'Region Id' 

exec usp_AccpacCreateSearchSelectField 'PRRegion', 'prd2_ParentId', 'Parent', 'PRRegion' 
exec usp_AccpacCreateIntegerField 'PRRegion', 'prd2_Level', 'Level', 10
exec usp_AccpacCreateTextField 'PRRegion', 'prd2_Name', 'Name', 50
exec usp_AccpacCreateMultilineField 'PRRegion', 'prd2_Description', 'Description', 75, '5'
exec usp_AccpacCreateSelectField 'PRRegion', 'prd2_Type', 'Region Type', 'prd2_Type' 

-- DRC LICENSE
exec usp_AccpacCreateTable 'PRDRCLicense', 'prdr', 'prdr_DRCLicenseId'
exec usp_AccpacCreateKeyField 'PRDRCLicense', 'prdr_DRCLicenseId', 'DRC License Id' 

exec usp_AccpacCreateSearchSelectField 'PRDRCLicense', 'prdr_CompanyId', 'Company', 'Company', 10, '17'
exec usp_AccpacCreateTextField 'PRDRCLicense', 'prdr_LicenseNumber', 'License Number', 5
exec usp_AccpacCreateTextField 'PRDRCLicense', 'prdr_MemberName', 'Member Name', 50
exec usp_AccpacCreateTextField 'PRDRCLicense', 'prdr_Salutation', 'Salutation', 5
exec usp_AccpacCreateTextField 'PRDRCLicense', 'prdr_ContactFirstAndMiddleName', 'Contact First and Middle', 50
exec usp_AccpacCreateTextField 'PRDRCLicense', 'prdr_ContactLastName', 'Contact Last Name', 50
exec usp_AccpacCreateTextField 'PRDRCLicense', 'prdr_ContactJobTitle', 'Contact Job Title', 50
exec usp_AccpacCreateTextField 'PRDRCLicense', 'prdr_BusinessType', 'Business Type', 25
exec usp_AccpacCreateTextField 'PRDRCLicense', 'prdr_Address', 'Address', 50
exec usp_AccpacCreateTextField 'PRDRCLicense', 'prdr_City', 'City', 20
exec usp_AccpacCreateTextField 'PRDRCLicense', 'prdr_State', 'State', 10
exec usp_AccpacCreateTextField 'PRDRCLicense', 'prdr_PostalCode', 'PostalCode', 10
exec usp_AccpacCreateTextField 'PRDRCLicense', 'prdr_Country', 'Country', 50
exec usp_AccpacCreateTextField 'PRDRCLicense', 'prdr_Address2', 'Address 2', 50
exec usp_AccpacCreateTextField 'PRDRCLicense', 'prdr_City2', 'City 2', 20
exec usp_AccpacCreateTextField 'PRDRCLicense', 'prdr_State2', 'State 2', 10
exec usp_AccpacCreateTextField 'PRDRCLicense', 'prdr_PostalCode2', 'PostalCode 2', 10
exec usp_AccpacCreateTextField 'PRDRCLicense', 'prdr_Country2', 'Country 2', 50
exec usp_AccpacCreateTextField 'PRDRCLicense', 'prdr_Phone', 'Phone', 20
exec usp_AccpacCreateTextField 'PRDRCLicense', 'prdr_Fax', 'Fax', 20
exec usp_AccpacCreateDateField 'PRDRCLicense', 'prdr_CoverageDate', 'Coverage Date'
exec usp_AccpacCreateDateField 'PRDRCLicense', 'prdr_PaidToDate', 'Paid To Date'
exec usp_AccpacCreateSelectField 'PRDRCLicense', 'prdr_LicenseStatus', 'License Status', 'prdr_LicenseStatus'
exec usp_AccpacCreateCheckboxField 'PRDRCLicense', 'prdr_Publish', 'Publish'

-- EXCEPTION QUEUE
exec usp_AccpacCreateTable 'PRExceptionQueue', 'preq', 'preq_ExceptionQueueId'
exec usp_AccpacCreateKeyField 'PRExceptionQueue', 'preq_ExceptionQueueId', 'Exception Id' 

exec usp_AccpacCreateSearchSelectField 'PRExceptionQueue', 'preq_TradeReportId', 'Trade Report', 'PRTradeReport', 10, '19'
exec usp_AccpacCreateSearchSelectField 'PRExceptionQueue', 'preq_ARAgingId', 'A/R Aging', 'PRARAging', 10, '19'
exec usp_AccpacCreateSearchSelectField 'PRExceptionQueue', 'preq_CompanyId', 'Company', 'Company', 10, '17'
exec usp_AccpacCreateDateField 'PRExceptionQueue', 'preq_Date', 'Date'
exec usp_AccpacCreateSelectField 'PRExceptionQueue', 'preq_Type', 'Type', 'preq_Type'
exec usp_AccpacCreateSelectField 'PRExceptionQueue', 'preq_Status', 'Status', 'preq_Status'
exec usp_AccpacCreateNumericField 'PRExceptionQueue', 'preq_ThreeMonthIntegrityRating', '3 Mo Integrity Rating', 10
exec usp_AccpacCreateNumericField 'PRExceptionQueue', 'preq_ThreeMonthPayRating', '3 Mo Pay Rating', 10
exec usp_AccpacCreateTextField 'PRExceptionQueue', 'preq_RatingLine', 'Rating', 50
exec usp_AccpacCreateIntegerField 'PRExceptionQueue', 'preq_NumTradeReports3Months', '# of Trade Reports (3 Mos)', 10
exec usp_AccpacCreateIntegerField 'PRExceptionQueue', 'preq_NumTradeReports6Months', '# of Trade Reports (6 Mos)', 10
exec usp_AccpacCreateIntegerField 'PRExceptionQueue', 'preq_NumTradeReports12Months', '# of Trade Reports (12 Mos)', 10
exec usp_AccpacCreateNumericField 'PRExceptionQueue', 'preq_BlueBookScore', 'BB Score', 10
exec usp_AccpacCreateUserSelectField 'PRExceptionQueue', 'preq_AssignedUserId', 'Assigned Analyst'
exec usp_AccpacCreateDateField 'PRExceptionQueue', 'preq_DateClosed', 'Date Closed'
exec usp_AccpacCreateUserSelectField 'PRExceptionQueue', 'preq_ClosedById', 'Closed By'
exec usp_AccpacCreateTeamField 'PRExceptionQueue', 'preq_ChannelId', 'Team'


-- FILE START
exec usp_AccpacCreateTable 'PRFile', 'prfi', 'prfi_FileId'
exec usp_AccpacCreateKeyField 'PRFile', 'prfi_FileId', 'File Id' 
exec usp_AccpacCreateTeamField 'PRFile', 'prfi_ChannelId', 'Team'

exec usp_AccpacCreateMultilineField 'PRFile', 'prfi_IssueDescription', 'Issue Description', 100, '5'
exec usp_AccpacCreateUserSelectField 'PRFile', 'prfi_AssignedUserId', 'Assigned User'
exec usp_AccpacCreateSelectField 'PRFile', 'prfi_Type', 'Type', 'prfi_Type' 
exec usp_AccpacCreateSelectField 'PRFile', 'prfi_Subtype', 'Subtype', 'prfi_Subtype' 
exec usp_AccpacCreateSelectField 'PRFile', 'prfi_Stage', 'Stage', 'prfi_Stage' 
exec usp_AccpacCreateSelectField 'PRFile', 'prfi_Status', 'Status', 'Status_OpenClosed' 

exec usp_AccpacCreateSearchSelectField 'PRFile', 'prfi_Company1Id', 'Claimant', 'Company',50
exec usp_AccpacCreateSelectField 'PRFile', 'prfi_Company1Role', 'Role', 'prfi_Role'
exec usp_AccpacCreateSearchSelectField 'PRFile', 'prfi_Company1Contact1Id', 'Contact 1', 'Person'
exec usp_AccpacCreateTextField 'PRFile', 'prfi_Company1Contact1Address', 'Contact 1 Address', 50
exec usp_AccpacCreateTextField 'PRFile', 'prfi_Company1Contact1CityStateZip', 'Contact 1 City, State and Zip', 50
exec usp_AccpacCreateTextField 'PRFile', 'prfi_Company1Contact1Telephone', 'Contact 1 Telephone', 20
exec usp_AccpacCreateTextField 'PRFile', 'prfi_Company1Contact1Fax', 'Contact 1 Fax', 20
exec usp_AccpacCreateEmailField 'PRFile', 'prfi_Company1Contact1Email', 'Contact 1 Email'

exec usp_AccpacCreateSearchSelectField 'PRFile', 'prfi_Company1Contact2Id', 'Contact 2', 'Person'
exec usp_AccpacCreateTextField 'PRFile', 'prfi_Company1Contact2Address', 'Contact 2 Address', 50
exec usp_AccpacCreateTextField 'PRFile', 'prfi_Company1Contact2CityStateZip', 'Contact 2 City, State and Zip', 50
exec usp_AccpacCreateTextField 'PRFile', 'prfi_Company1Contact2Telephone', 'Contact 2 Telephone', 20
exec usp_AccpacCreateTextField 'PRFile', 'prfi_Company1Contact2Fax', 'Contact 2 Fax', 20
exec usp_AccpacCreateEmailField 'PRFile', 'prfi_Company1Contact2Email', 'Contact 2 Email'

exec usp_AccpacCreateSearchSelectField 'PRFile', 'prfi_Company2Id', 'Respondent', 'Company',50
exec usp_AccpacCreateSelectField 'PRFile', 'prfi_Company2Role', 'Role', 'prfi_Role' 
exec usp_AccpacCreateSearchSelectField 'PRFile', 'prfi_Company2Contact1Id', 'Contact 1', 'Person'
exec usp_AccpacCreateTextField 'PRFile', 'prfi_Company2Contact1Address', 'Contact 1 Address', 50
exec usp_AccpacCreateTextField 'PRFile', 'prfi_Company2Contact1CityStateZip', 'Contact 1 City, State and Zip', 50
exec usp_AccpacCreateTextField 'PRFile', 'prfi_Company2Contact1Telephone', 'Contact 1 Telephone', 20
exec usp_AccpacCreateTextField 'PRFile', 'prfi_Company2Contact1Fax', 'Contact 1 Fax', 20
exec usp_AccpacCreateEmailField 'PRFile', 'prfi_Company2Contact1Email', 'Contact 1 Email'

exec usp_AccpacCreateSearchSelectField 'PRFile', 'prfi_Company2Contact2Id', 'Contact 2', 'Person'
exec usp_AccpacCreateTextField 'PRFile', 'prfi_Company2Contact2Address', 'Contact 2 Address', 50
exec usp_AccpacCreateTextField 'PRFile', 'prfi_Company2Contact2CityStateZip', 'Contact 2 City, State and Zip', 50
exec usp_AccpacCreateTextField 'PRFile', 'prfi_Company2Contact2Telephone', 'Contact 2 Telephone', 20
exec usp_AccpacCreateTextField 'PRFile', 'prfi_Company2Contact2Fax', 'Contact 2 Fax', 20
exec usp_AccpacCreateEmailField 'PRFile', 'prfi_Company2Contact2Email', 'Contact 2 Email'

exec usp_AccpacCreateSearchSelectField 'PRFile', 'prfi_Company3Id', 'Company', 'Company',50
exec usp_AccpacCreateSelectField 'PRFile', 'prfi_Company3Role', 'Role', 'prfi_Role' 

exec usp_AccpacCreateSearchSelectField 'PRFile', 'prfi_Company3Contact1Id', 'Contact 1', 'Person'
exec usp_AccpacCreateTextField 'PRFile', 'prfi_Company3Contact1Address', 'Contact 1 Address', 50
exec usp_AccpacCreateTextField 'PRFile', 'prfi_Company3Contact1CityStateZip', 'Contact 1 City, State and Zip', 50
exec usp_AccpacCreateTextField 'PRFile', 'prfi_Company3Contact1Telephone', 'Contact 1 Telephone', 20
exec usp_AccpacCreateTextField 'PRFile', 'prfi_Company3Contact1Fax', 'Contact 1 Fax', 20
exec usp_AccpacCreateEmailField 'PRFile', 'prfi_Company3Contact1Email', 'Contact 1 Email'

exec usp_AccpacCreateSearchSelectField 'PRFile', 'prfi_Company3Contact2Id', 'Contact 2', 'Person'
exec usp_AccpacCreateTextField 'PRFile', 'prfi_Company3Contact2Address', 'Contact 2 Address', 50
exec usp_AccpacCreateTextField 'PRFile', 'prfi_Company3Contact2CityStateZip', 'Contact 2 City, State and Zip', 50
exec usp_AccpacCreateTextField 'PRFile', 'prfi_Company3Contact2Telephone', 'Contact 2 Telephone', 20
exec usp_AccpacCreateTextField 'PRFile', 'prfi_Company3Contact2Fax', 'Contact 2 Fax', 20
exec usp_AccpacCreateEmailField 'PRFile', 'prfi_Company3Contact2Email', 'Contact 2 Email'

exec usp_AccpacCreateSearchSelectField 'PRFile', 'prfi_RepresentingCompany1Id', 'Company', 'Company',50
exec usp_AccpacCreateTextField 'PRFile', 'prfi_RepresentingCompany1Name', 'Name', 50
exec usp_AccpacCreateTextField 'PRFile', 'prfi_RepresentingCompany1Address', 'Address', 50
exec usp_AccpacCreateTextField 'PRFile', 'prfi_RepresentingCompany1CityStateZip', 'City, State and Zip', 50
exec usp_AccpacCreateTextField 'PRFile', 'prfi_RepresentingCompany1Telephone', 'Telephone', 20
exec usp_AccpacCreateTextField 'PRFile', 'prfi_RepresentingCompany1Fax', 'Fax', 20
exec usp_AccpacCreateEmailField 'PRFile', 'prfi_RepresentingCompany1Email', 'Email'

exec usp_AccpacCreateSearchSelectField 'PRFile', 'prfi_RepresentingCompany1PersonId', 'Person', 'Person'
exec usp_AccpacCreateCheckboxField 'PRFile', 'prfi_RepresentingCompany1PersonSigned', 'Signature Required'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_RepresentingCompany1PersonSigDate', 'Authorization Received'
exec usp_AccpacCreateMultilineField 'PRFile', 'prfi_RepresentingCompany1Info', 'Free-form Attorney Information', 75, '5'

exec usp_AccpacCreateSearchSelectField 'PRFile', 'prfi_RepresentingCompany2Id', 'Company', 'Company',50
exec usp_AccpacCreateTextField 'PRFile', 'prfi_RepresentingCompany2Name', 'Name', 50
exec usp_AccpacCreateTextField 'PRFile', 'prfi_RepresentingCompany2Address', 'Address', 50
exec usp_AccpacCreateTextField 'PRFile', 'prfi_RepresentingCompany2CityStateZip', 'City, State and Zip', 50
exec usp_AccpacCreateTextField 'PRFile', 'prfi_RepresentingCompany2Telephone', 'Telephone', 20
exec usp_AccpacCreateTextField 'PRFile', 'prfi_RepresentingCompany2Fax', 'Fax', 20
exec usp_AccpacCreateEmailField 'PRFile', 'prfi_RepresentingCompany2Email', 'Email'

exec usp_AccpacCreateSearchSelectField 'PRFile', 'prfi_RepresentingCompany2PersonId', 'Person', 'Person'
exec usp_AccpacCreateCheckboxField 'PRFile', 'prfi_RepresentingCompany2PersonSigned', 'Signature Required'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_RepresentingCompany2PersonSigDate', 'Authorization Received'
exec usp_AccpacCreateMultilineField 'PRFile', 'prfi_RepresentingCompany2Info', 'Free-form Attorney Information', 75, '5'

exec usp_AccpacCreateSearchSelectField 'PRFile', 'prfi_RepresentingCompany3Id', 'Company', 'Company',50
exec usp_AccpacCreateTextField 'PRFile', 'prfi_RepresentingCompany3Name', 'Name', 50
exec usp_AccpacCreateTextField 'PRFile', 'prfi_RepresentingCompany3Address', 'Address', 50
exec usp_AccpacCreateTextField 'PRFile', 'prfi_RepresentingCompany3CityStateZip', 'City, State and Zip', 50
exec usp_AccpacCreateTextField 'PRFile', 'prfi_RepresentingCompany3Telephone', 'Telephone', 20
exec usp_AccpacCreateTextField 'PRFile', 'prfi_RepresentingCompany3Fax', 'Fax', 20
exec usp_AccpacCreateEmailField 'PRFile', 'prfi_RepresentingCompany3Email', 'Email'

exec usp_AccpacCreateSearchSelectField 'PRFile', 'prfi_RepresentingCompany3PersonId', 'Person', 'Person'
exec usp_AccpacCreateCheckboxField 'PRFile', 'prfi_RepresentingCompany3PersonSigned', 'Signature Required'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_RepresentingCompany3PersonSigDate', 'Authorization Received'
exec usp_AccpacCreateMultilineField 'PRFile', 'prfi_RepresentingCompany3Info', 'Free-form Attorney Information', 75, '5'

-- ********** Fields refer to all SS File types
exec usp_AccpacCreateDateField 'PRFile', 'prfi_ClosingDate', 'Closing Date'
exec usp_AccpacCreateSelectField 'PRFile', 'prfi_ClosingReason', 'Closing Reason', 'prfi_ClosingReason' 
exec usp_AccpacCreateSelectField 'PRFile', 'prfi_PaperworkLocation', 'Paperwork Location', 'prfi_PaperworkLocation' 
-- Referred By on Collections; Inquiry Source on dispute
exec usp_AccpacCreateSelectField 'PRFile', 'prfi_InquirySource', 'Inquiry Source', 'prfi_InquirySource' 
-- used by Colection and Dispute
exec usp_AccpacCreateSelectField 'PRFile', 'prfi_Topic', 'Topic', 'prfi_Topic' 
exec usp_AccpacCreateIntegerField 'PRFile', 'prfi_InitialCallDuration', 'Initial Call (minutes)', 10

exec usp_AccpacCreateNumericField 'PRFile', 'prfi_AmountPRCoInvoiced', 'Amount PRCo Invoiced', 10
exec usp_AccpacCreateSelectField 'PRFile', 'prfi_5657LetterType', '56/57 Letter Type Sent', 'prfi_5657LetterType' 
exec usp_AccpacCreateDateField 'PRFile', 'prfi_5657WarningSentDate', '56/57 Warning Letter Sent Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_5657WarningDueDate', '56/57 Warning Response Due Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_5657WarningResponseDate', '56/57 Warning Response Rcvd Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_5657ReportSentDate', '56/57 Report Letter Sent Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_5657ReportDueDate', '56/57 Report Response Due Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_5657ReportResponseDate', '56/57 Report Response Rcvd Date'

-- ********** Collections Specific
exec usp_AccpacCreateNumericField 'PRFile', 'prfi_InitialAmountOwed', 'Initial Amount Owed', 10
exec usp_AccpacCreateNumericField 'PRFile', 'prfi_RemainingBalance', 'Remaining Balance', 10
exec usp_AccpacCreateDateField 'PRFile', 'prfi_OldestInvoiceDate', 'Oldest Invoice Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_PACADeadline', 'PACA Complaint Deadline'
exec usp_AccpacCreateCheckboxField 'PRFile', 'prfi_TrustProtection', 'Trust Protection'
-- this is an internal flag used by the workflows to determine if the FormalCollection block should be displayed.
-- For some states, this would be difficult to determine based upon the paths the collection workflow takes.
exec usp_AccpacCreateCheckboxField 'PRFile', 'prfi_EnteredFormalCollection', 'Has Entered Formal Collection'
-- was prfi_InitialNumberInvoices
exec usp_AccpacCreateIntegerField 'PRFile', 'prfi_TotalNumberInvoices', 'Total # of Invoices', 10
-- New fields - 9/22/06 
exec usp_AccpacCreateTextField 'PRFile', 'prfi_InvoiceNumber', 'Invoice Number', 30
exec usp_AccpacCreateIntegerField 'PRFile', 'prfi_Terms', 'Terms (Days)', 10
exec usp_AccpacCreateDateField 'PRFile', 'prfi_DueDate', 'Due Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_DateA1LetterSent', 'Date A1 Letter Sent'
exec usp_AccpacCreateNumericField 'PRFile', 'prfi_AmountCreditorReceived', 'Amount Creditor Received', 10
exec usp_AccpacCreateNumericField 'PRFile', 'prfi_AmountStillOwing', 'Amount Still Owing', 10
exec usp_AccpacCreateSelectField 'PRFile', 'prfi_CreditorCollectedReason', 'Reason', 'prfi_CreditorCollectedReason' 
exec usp_AccpacCreateNumericField 'PRFile', 'prfi_PRCoFormallyCollectingAmount', 'Amount PRCo is formally collecting', 10
exec usp_AccpacCreateNumericField 'PRFile', 'prfi_PRCoCollectedAmount', 'Amount PRCo collected', 10
exec usp_AccpacCreateNumericField 'PRFile', 'prfi_PRCoStillCollectingAmount', 'Amount PRCo is still trying to collect', 10
exec usp_AccpacCreateSelectField 'PRFile', 'prfi_CollectionSubCategory', 'Collection Sub-category', 'prfi_CollectionSubCategory' 
exec usp_AccpacCreateDateField 'PRFile', 'prfi_DateAcceptanceLetterSent', 'Date Acceptance Letter sent'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_DateAcceptanceLetterRcvd', 'Date Acceptance Letter received'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_DateConfirmedPaymentRcvd', 'Date Creditor confirmed payment received'

-- PLAN Info (9/22/06 - New Fields)
exec usp_AccpacCreateDateField 'PRFile', 'prfi_PLANDateAcceptanceLetterSent', 'Date PLAN Acceptance Letter sent'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_PLANDateAcceptanceLetterRcvd', 'Date PLAN Acceptance Letter received'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_PLANDateFileMailed', 'Date File mailed to PLAN'
exec usp_AccpacCreateSelectField 'PRFile', 'prfi_PLANPartnerUsed', 'PLAN Partner Used', 'prfi_PLANPartnerUsed' 
exec usp_AccpacCreateTextField 'PRFile', 'prfi_PLANFileNumber', 'PLAN File #', 30


-- ********** Arbitration Specific
exec usp_AccpacCreateDateField 'PRFile', 'prfi_ArbFormClaimantRcvdDate', 'Arb Form Rcvd by Claimant Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_ArbFormRespondentRcvdDate', 'Arb Form Rcvd by Respondent Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_DocSentArbitratorDate', 'Doc Sent to Arb Date'
exec usp_AccpacCreateSelectField 'PRFile', 'prfi_DocArbitratorShipMethod', 'Doc Sent to Arb Method', 'prfi_DocArbitratorShipMethod' 
exec usp_AccpacCreateTextField 'PRFile', 'prfi_DocArbitratorShipTracking', 'Doc Sent to Arb Tracking #', 50
exec usp_AccpacCreateCheckboxField 'PRFile', 'prfi_DocArbitratorReceived', 'Doc Rcvd by Arbitrator'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_ArbitratorDecisionDate', 'Arb Decision Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_ArbitratorDecisionRcvdDate', 'Arb Decision Rcvd Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_AwardDocFaxDate', 'Award Doc Rcvd by Fax Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_AwardDocEmailDate', 'Award Doc Rcvd by Email Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_AwardDocMailDate', 'Award Doc Rcvd by Mail Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_OrigDocRcvdByPRCoDate', 'Orig Doc Rcvd by PRCo Date'
exec usp_AccpacCreateCheckboxField 'PRFile', 'prfi_ClaimantRequestReview', 'Claimant Review Requested'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_ClaimantRequestRcvdDate', 'Claimant Review Request Rcvd Date'
exec usp_AccpacCreateCheckboxField 'PRFile', 'prfi_RespondentRequestReview', 'Respondent Review Requested'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_RespondentRequestRcvdDate', 'Respondent Review Request Rcvd Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_ArbitratorDecisionReviewDate', 'Arbitrator Decision Review Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_ArbitratorDecisionReviewRcvdDate', 'Arbitrator Decision Review Rcvd Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_ReviewedAwardDocRcvdFaxDate', 'Reviewed Award Doc Rcvd Fax Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_ReviewedAwardDocRcvdEmailDate', 'Reviewed Award Doc Rcvd Email Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_ReviewedAwardDocRcvdMailDate', 'Reviewed Award Doc Rcvd Mail Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_ReviewOrigDocRcvdByPRCoDate', 'Review Orig Doc Rcvd by PRCo Date'
exec usp_AccpacCreateNumericField 'PRFile', 'prfi_FinalAwardClaimantAmount', 'Final Award Claimant Amt', 10
exec usp_AccpacCreateNumericField 'PRFile', 'prfi_FinalAwardRespondentAmount', 'Final Award Respondent Amt', 10
exec usp_AccpacCreateDateField 'PRFile', 'prfi_ArbitrationRcvdDate', 'Arbitration Rcvd Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_SubmissionClosedDate', 'Submission Closed Date'
exec usp_AccpacCreateNumericField 'PRFile', 'prfi_ClaimAmount', 'Claim Amount', 10
exec usp_AccpacCreateNumericField 'PRFile', 'prfi_CounterClaimAmount', 'Counter Claim Amount', 10
exec usp_AccpacCreateCheckboxField 'PRFile', 'prfi_ArbitrationFeeRcvd', 'Arbitration Fee Rcvd'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_JoinLetterPrintedDate', 'Join Letter Printed Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_SubmissionsClosedLetterPrintedDate', 'Submissions Closed Letter Printed Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_ForwardedToBoardDate', 'Forwarded to Board Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_BoardDecisionDate', 'Board Decision Date'

-- ********** DRC Specific
/*
exec usp_AccpacCreateMultilineField 'PRFile', 'prfi_SpecialInstruction', 'Special Instructions', 75, '5'
exec usp_AccpacCreateCheckboxField 'PRFile', 'prfi_AttemptedClaimantSettle', 'Claimant Attempted Settle'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_NODDate', 'NOD'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_CNODDate', 'CNOD'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_RNODReceivedDate', 'RNOD Rcvd Date'
exec usp_AccpacCreateCheckboxField 'PRFile', 'prfi_RNODCounterClaim', 'RNOD Counter Claim'
exec usp_AccpacCreateNumericField 'PRFile', 'prfi_RNODCounterClaimAmount', 'RNOD Counter Claim Amt', 10
exec usp_AccpacCreateDateField 'PRFile', 'prfi_SOCReceivedFaxDate', 'SOC Rcvd Fax Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_SOCReceivedMailDate', 'SOC Rcvd Mail Date'
exec usp_AccpacCreateSelectField 'PRFile', 'prfi_DRCArbitrationType', 'DRC Arbitration Type', 'prfi_DRCArbitrationType' 
exec usp_AccpacCreateDateField 'PRFile', 'prfi_DRCClaimantPaymentRcvdDate', 'DRC Claimant Pymt Rcvd Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_CSOCDate', 'CSOC'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_SOISentDate', 'SOI Sent Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_COASentDate', 'COA Sent Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_SOIReceivedDate', 'SOI Rcvd Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_SODReceivedDate', 'SOD Rcvd Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_CSODSentDate', 'CSOD Sent Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_RSODReceivedDate', 'RSOD Rcvd Date'
exec usp_AccpacCreateNumericField 'PRFile', 'prfi_InformalCounterClaimAmount', 'Informal Counter Claim Amt', 10
exec usp_AccpacCreateNumericField 'PRFile', 'prfi_FormalCounterClaimFee', 'Formal Counter Claim Fee', 10
exec usp_AccpacCreateDateField 'PRFile', 'prfi_FormalCounterClaimFeeDate', 'Formal Counter Claim Fee Date'
exec usp_AccpacCreateNumericField 'PRFile', 'prfi_FormalCounterClaimAmt', 'Formal Counter Claim Amt', 10
exec usp_AccpacCreateDateField 'PRFile', 'prfi_FormalCounterClaimAmtDate', 'Formal Counter Claim Amt Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_CSOCSentDate', 'CSOC Sent Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_CounterClaimSODRcvdDate', 'Counter Claim SOD Rcvd Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_CSODSentDate', 'CSOD Sent Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_CounterClaimRSODRcvdDate', 'Counter Claim RSOD Rcvd Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_COSSentDate', 'COS Sent Date'
*/
-- ********** Dispute Specific
exec usp_AccpacCreateNumericField 'PRFile', 'prfi_SettlementAmount', 'Settlement Amt', 10
exec usp_AccpacCreateDateField 'PRFile', 'prfi_OpinionFeeLetterSentDate', 'Opinion Fee Letter Sent Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_OpinionFeeAuthorizedDate', 'Opinion Fee Authorized Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_OpinionLetterSentDate', 'Opinion Letter Sent Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_DisputeFeeLetterSentDate', 'Dispute Fee Letter Sent Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_DisputeFeeAuthorizedDate', 'Dispute Fee Authorized Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_DisputeRequestLetterDate', 'Dispute Request Letter Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_DisputeRequestDueDate', 'Dispute Request Due Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_DisputeRequestResponseDate', 'Dispute Request Response Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_DisputeRequestLetterDate2', 'Second Dispute Request Letter Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_DisputeRequestDueDate2', 'Second Dispute Request Due Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_DisputeRequestResponseDate2', 'Second Dispute Request Response Date'


-- ********** Potentially Unused
/*
exec usp_AccpacCreateCheckboxField 'PRFile', 'prfi_VoluntaryAgreementRequired', 'VoluntaryAgreementRequired'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_VoluntaryAgreementRcvdDate', 'Voluntary Agmt Rcvd Date'
exec usp_AccpacCreateSelectField 'PRFile', 'prfi_CurrencyType', 'Currency Type', 'prfi_CurrencyType' 
exec usp_AccpacCreateSelectField 'PRFile', 'prfi_IssueCategory', 'Issue Category', 'prfi_IssueCategory' 
exec usp_AccpacCreateSelectField 'PRFile', 'prfi_Language', 'Language', 'prfi_Language' 
*/


exec usp_AccpacCreateNumericField 'PRFile', 'prfi_FilingFeeAmount', 'Filing Fee Amount', 10
exec usp_AccpacCreateDateField 'PRFile', 'prfi_ClosingLetterSentDate', 'Closing Letter Sent Date'
exec usp_AccpacCreateNumericField 'PRFile', 'prfi_FeeAmount', 'Fee Amount', 10

-- Unsure if these are arbitration or DRC
/*
exec usp_AccpacCreateCheckboxField 'PRFile', 'prfi_NoAwardGiven', 'No Award Given'
exec usp_AccpacCreateCheckboxField 'PRFile', 'prfi_AwardClaimant', 'Award Claimant'
exec usp_AccpacCreateNumericField 'PRFile', 'prfi_AwardClaimantAmount', 'Award Claimant Amount', 10
exec usp_AccpacCreateSelectField 'PRFile', 'prfi_AwardClaimantPayer', 'Award Claimant Payer', 'prfi_AwardClaimantPayer' 
exec usp_AccpacCreateDateField 'PRFile', 'prfi_AwardClaimantDueDate', 'Award Claimant Due Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_AwardClaimantDate', 'Award Claimant Date'
exec usp_AccpacCreateCheckboxField 'PRFile', 'prfi_AwardRespondent', 'Award Respondent'
exec usp_AccpacCreateNumericField 'PRFile', 'prfi_AwardRespondentAmount', 'Award Respondent Amount', 10
exec usp_AccpacCreateSelectField 'PRFile', 'prfi_AwardRespondentPayer', 'Award Respondent Payer', 'prfi_AwardClaimantPayer' 
exec usp_AccpacCreateDateField 'PRFile', 'prfi_AwardRespondentDueDate', 'Award Respondent Due Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_AwardRespondentDate', 'Award Respondent Date'
exec usp_AccpacCreateCheckboxField 'PRFile', 'prfi_ReviewNoAwardGiven', 'Review No Award Given'
exec usp_AccpacCreateCheckboxField 'PRFile', 'prfi_ReviewAwardClaimant', 'Review Award Claimant'
exec usp_AccpacCreateNumericField 'PRFile', 'prfi_ReviewAwardClaimantAmount', 'Review Award Claimant Amount', 10
*/

-- Prototype only
exec usp_AccpacCreateSearchSelectField 'PRFile', 'prfi_CompanyId', 'Company', 'Company'
exec usp_AccpacCreateTextField 'PRFile', 'prfi_BBId', 'BBId', 5
exec usp_AccpacCreateTextField 'PRFile', 'prfi_DRCNumber', 'DRC #', 5
exec usp_AccpacCreateDateField 'PRFile', 'prfi_StartDate', 'Start Date'
exec usp_AccpacCreateDateField 'PRFile', 'prfi_EndDate', 'End Date'
exec usp_AccpacCreateCheckboxField 'PRFile', 'prfi_ClaimantCreditor', 'Claimant / Creditor'
exec usp_AccpacCreateCheckboxField 'PRFile', 'prfi_RespondentDebtor', 'Respondent / Debtor'

--exec usp_AccpacCreateTeamField 'PRFile', 'prfi_ChannelId', 'Team'

-- FILE PAYMENT
exec usp_AccpacCreateTable 'PRFilePayment', 'prfp', 'prfp_FilePaymentId'
exec usp_AccpacCreateKeyField 'PRFilePayment', 'prfp_FilePaymentId', 'File Payment Id' 

exec usp_AccpacCreateSearchSelectField 'PRFilePayment', 'prfp_FileId', 'File', 'PRFile', 10, '0', NULL, 'Y'
exec usp_AccpacCreateNumericField 'PRFilePayment', 'prfp_PaymentAmount', 'Payment Amt', 10
exec usp_AccpacCreateDateField 'PRFilePayment', 'prfp_DueDate', 'Due Date'
exec usp_AccpacCreateDateField 'PRFilePayment', 'prfp_ReceivedDate', 'Received Date'

-- FINANCIAL STATEMENT START
exec usp_AccpacCreateTable 'PRFinancial', 'prfs', 'prfs_FinancialId'
exec usp_AccpacCreateKeyField 'PRFinancial', 'prfs_FinancialId', 'Financial Stmt Id' 

exec usp_AccpacCreateSearchSelectField 'PRFinancial', 'prfs_CompanyId', 'Company', 'Company', 10, '17'
exec usp_AccpacCreateSearchSelectField 'PRFinancial', 'prfs_LibraryId', 'Library', 'Library'
exec usp_AccpacCreateDateField 'PRFinancial', 'prfs_StatementDate', 'Statement Date'
exec usp_AccpacCreateSelectField 'PRFinancial', 'prfs_Currency', 'Currency', 'prfs_Currency' 
exec usp_AccpacCreateSelectField 'PRFinancial', 'prfs_Type', 'Type', 'prfs_Type' 
exec usp_AccpacCreateSelectField 'PRFinancial', 'prfs_InterimMonth', 'Interim Month', 'prfs_InterimMonth' 
exec usp_AccpacCreateSelectField 'PRFinancial', 'prfs_EntryStatus', 'Status', 'prfs_EntryStatus' 
exec usp_AccpacCreateSelectField 'PRFinancial', 'prfs_PreparationMethod', 'Preparation Method', 'prfs_PreparationMethod' 

exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_CashEquivalents', 'Cash Equv', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_ARTrade', 'A/R Trade', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_GrowerAdvances', 'Grower Advances', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_DueFromRelatedParties', 'Due From Related Parties', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_LoansNotesReceivable', 'Loans / Notes Receivables', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_MarketableSecurities', 'Marketable Securities', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_Inventory', 'Inventory', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_OtherCurrentAssets', 'Other Current Assets', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_TotalCurrentAssets', 'Total Current Assets', 10

exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_AccountsPayable', 'Accounts Payable', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_CurrentMaturity', 'Current Maturity', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_CreditLine', 'Credit Line', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_CurrentLoanPayableShldr', 'Current Loan/Payable Shareholder', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_OtherCurrentLiabilities', 'Other Current Liabilities', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_TotalCurrentLiabilities', 'Total Current Liabilities', 10

exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_Property', 'Property', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_LeaseholdImprovements', 'Leasehold Improvements', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_OtherFixedAssets', 'Other Fixed Assets', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_AccumulatedDepreciation', 'Accumulated Depreciation', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_NetFixedAssets', 'Net Fixed Assets', 10

exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_LongTermDebt', 'Long Term Debt', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_LoansNotesPayableShldr', 'Loans/Notes Payable Shareholder', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_OtherLongLiabilities', 'Other Long Liabilities', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_TotalLongLiabilities', 'Total Long Liabilities', 10

exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_OtherLoansNotesReceivable', 'Other Loans/Notes Receivable', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_Goodwill', 'Goodwill', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_OtherMiscAssets', 'Other Misc Assets', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_TotalOtherAssets', 'Total Other Assets', 10

exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_OtherEquity', 'Other Equity', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_OtherMiscLiabilities', 'Other Misc Liabilities', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_RetainedEarnings', 'Retained Earnings', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_TotalEquity', 'Total Equity', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_TotalAssets', 'Total Assets', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_TotalLiabilities', 'Total Liabilities', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_TotalLiabilityAndEquity', 'Total Liabilities And Equity', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_WorkingCapital', 'Working Capital', 10


exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_Sales', 'Sales', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_CostGoodsSold', 'Cost of Goods Sold', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_GrossProfitMargin', 'Gross Profit Margin', 10

exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_OperatingExpenses', 'Operating Expenses', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_OperatingIncome', 'Operating Income', 10

exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_InterestIncome', 'Interest Income', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_OtherIncome', 'Other Income', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_ExtraordinaryGainLoss', 'Extraordinary Gain/Loss', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_InterestExpense', 'Interest Expense', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_OtherExpenses', 'Other Expenses', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_TaxProvision', 'Provision for Income Taxes', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_NetIncome', 'Net Income', 10

exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_Depreciation', 'Depreciation', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_Amortization', 'Amortization', 10

exec usp_AccpacCreateMultilineField 'PRFinancial', 'prfs_Analysis', 'Analysis', 75, '5'
exec usp_AccpacCreateMultilineField 'PRFinancial', 'prfs_AnalysisInternal', 'Internal Analysis', 75, '5'
exec usp_AccpacCreateCheckboxField 'PRFinancial', 'prfs_Publish', 'Publish'
exec usp_AccpacCreateTextField 'PRFinancial', 'prfs_NetProfitLoss', 'Net Profit / Loss', 10

exec usp_AccpacCreateCheckboxField  'PRFinancial', 'prfs_Reviewed', 'Reviewed By Analyst'
exec usp_AccpacCreateDateField 'PRFinancial', 'prfs_ReviewDate', 'Review Date'

-- RATIOS -- Only in here for Prototype!!!!
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_CurrentRatio', 'Current Ratio', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_QuickRatio', 'Quick Ratio', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_ARTurnover', 'Accounts Receivable Turnover', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_DaysPayableOutstanding', 'Days Payable Outstanding', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_DebtToEquity', 'Debt to Equity', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_FixedAssetsToNetWorth', 'Fixed Assets to Net Worth', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_DebtServiceAbility', 'Debt Service Ability', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_OperatingRatio', 'Operating Ratio', 10
exec usp_AccpacCreateNumericField 'PRFinancial', 'prfs_ZScore', 'Z Score', 10

-- FINANCIAL STATEMENT DETAIL
exec usp_AccpacCreateTable 'PRFinancialDetail', 'prfd', 'prfd_FinancialDetailId'
exec usp_AccpacCreateKeyField 'PRFinancialDetail', 'prfd_FinancialDetailId', 'Financial Stmt Detail Id' 

exec usp_AccpacCreateSearchSelectField 'PRFinancialDetail', 'prfd_FinancialId', 'Financial Statement', 'PRFinancialStatement'
exec usp_AccpacCreateTextField 'PRFinancialDetail', 'prfd_FieldName', 'Field', 50
exec usp_AccpacCreateTextField 'PRFinancialDetail', 'prfd_Description', 'Description', 100
exec usp_AccpacCreateNumericField 'PRFinancialDetail', 'prfd_Amount', 'Amount', 10

-- GENERAL INFORMATION
exec usp_AccpacCreateTable 'PRGeneralInformation', 'prgi', 'prgi_GeneralInformationId'
exec usp_AccpacCreateKeyField 'PRGeneralInformation', 'prgi_GeneralInformationId', 'General Information Id' 

exec usp_AccpacCreateTextField 'PRGeneralInformation', 'prgi_Content', 'Content', 100

-- LIBRARY
exec usp_AccpacCreateSearchSelectField 'Library', 'libr_PRBusinessEventId', 'Business Event', 'PRBusinessEvent', 10, '19'
exec usp_AccpacCreateSearchSelectField 'Library', 'libr_PRPersonEventId', 'Person Event', 'PRCreditEvent', 10, '19'
exec usp_AccpacCreateSearchSelectField 'Library', 'libr_PRCreditSheetId', 'Credit Sheet', 'PRCreditSheet', 10, '19'
exec usp_AccpacCreateSearchSelectField 'Library', 'libr_PRFileId', 'PRFile', 'File', 10, '19'

-- BBScore (formerly OPEN DATA)
exec usp_AccpacCreateTable 'PRBBScore', 'prbs', 'prbs_BBScoreId'
exec usp_AccpacCreateKeyField 'PRBBScore', 'prbs_BBScoreId', 'BB SCore Id' 

exec usp_AccpacCreateSearchSelectField 'PRBBScore', 'prbs_CompanyId', 'Company', 'Company', 10, '17', NULL, 'Y'
exec usp_AccpacCreateDateField      'PRBBScore', 'prbs_Date', 'Date'
exec usp_AccpacCreateCheckboxField  'PRBBScore', 'prbs_Current', 'Current'
exec usp_AccpacCreateIntegerField   'PRBBScore', 'prbs_P80Surveys', 'P80 Surveys', 10
exec usp_AccpacCreateIntegerField   'PRBBScore', 'prbs_P90Surveys', 'P90 Surveys', 10
exec usp_AccpacCreateIntegerField   'PRBBScore', 'prbs_P95Surveys', 'P95 Surveys', 10
exec usp_AccpacCreateIntegerField   'PRBBScore', 'prbs_P975Surveys', 'P975 Surveys', 10
exec usp_AccpacCreateNumericField   'PRBBScore', 'prbs_BBScore', 'Score', 10
exec usp_AccpacCreateNumericField   'PRBBScore', 'prbs_NewBBScore', 'New Model Score', 10
exec usp_AccpacCreateNumericField   'PRBBScore', 'prbs_ConfidenceScore', 'Conf', 10
exec usp_AccpacCreateTextField      'PRBBScore', 'prbs_Recency', 'Recency', 20
exec usp_AccpacCreateTextField      'PRBBScore', 'prbs_ObservationPeriodTES', 'Obs Per TES', 20
exec usp_AccpacCreateTextField      'PRBBScore', 'prbs_RecentTES', 'Recent TES', 20
exec usp_AccpacCreateTextField      'PRBBScore', 'prbs_Model', 'Model', 30
exec usp_AccpacCreateNumericField   'PRBBScore', 'prbs_Deviation', 'Prv Month Diff', 10
exec usp_AccpacCreateDateField      'PRBBScore', 'prbs_RunDate', 'RunDate'
exec usp_AccpacCreateIntegerField   'PRBBScore', 'prbs_RequiredReportCount', 'Required Reports', 10
exec usp_AccpacCreateCheckboxField  'PRBBScore', 'prbs_Exception', 'Exception'


-- OPPORTUNITY
-- modify a native field to change the custom_caption list
update custom_edits 
   set colp_LookupFamily = 'Status_OpenClosed', colp_DefaultValue = 'Open' 
 where colp_Entity =  'Opportunity' and colp_ColName = 'oppo_Status'
exec usp_AccpacCreateSelectField 'Opportunity', 'oppo_PRLostReason', 'Lost Reason', 'oppo_PRLostReason'
exec usp_AccpacCreateSelectField 'Opportunity', 'oppo_PRType', 'Type', 'oppo_PRType'
exec usp_AccpacCreateSelectField 'Opportunity', 'oppo_PRPrimaryPersonRole', 'Primary Person Role', 'Oppo_PersonRole'
exec usp_AccpacCreateSelectField 'Opportunity', 'oppo_PRSecondaryPersonRole', 'Secondary Person Role', 'Oppo_PersonRole'
exec usp_AccpacCreateSearchSelectField 'Opportunity', 'oppo_PRSecondaryPersonID', 'Secondary Point Person', 'Person'
exec usp_AccpacCreateTextField 'Opportunity', 'oppo_PRAdvertisingAgency', 'Advertising Agency', 100

--exec usp_AccpacCreateSelectField 'Opportunity', 'oppo_PRTargetYear', 'Target Year', 'Oppo_PRTargetYear'
exec usp_AccpacCreateSelectField 'Opportunity', 'oppo_PRTeam', 'Team', 'oppo_PRTeam'
exec usp_AccpacCreateSelectField 'Opportunity', 'oppo_PRTargetIssue', 'Target Issue', 'Oppo_PRTargetIssue'
exec usp_AccpacCreateMultiselectField 'Opportunity', 'oppo_PRAdvertiseIn', 'Other Publications Advertised In', 'oppo_PRAdvertiseIn'
/* removed checkboxes in leiu of oppo_PRAdvertiseIn multiselect
exec usp_AccpacCreateCheckboxField 'Opportunity', 'oppo_PRAdvertiseProduceNews', 'In Produce News'
exec usp_AccpacCreateCheckboxField 'Opportunity', 'oppo_PRAdvertiseWGA', 'In WGA'
exec usp_AccpacCreateCheckboxField 'Opportunity', 'oppo_PRAdvertiseThePacker', 'In The Packer'
exec usp_AccpacCreateCheckboxField 'Opportunity', 'oppo_PRAdvertiseRBCS', 'In RBCS'
exec usp_AccpacCreateCheckboxField 'Opportunity', 'oppo_PRAdvertiseProduceBusiness', 'In Produce Business'
exec usp_AccpacCreateCheckboxField 'Opportunity', 'oppo_PRAdvertiseSupermarket', 'In Supermarket'
exec usp_AccpacCreateCheckboxField 'Opportunity', 'oppo_PRAdvertiseOther', 'In Other'
*/
exec usp_AccpacCreateSelectField 'Opportunity', 'oppo_PRAdRun', 'Run Length', 'Oppo_PRAdRun'
-- oppo_PRAdSize is being removed; the oppo_PRType field will be used for this purpose and display in the Opp Listing
--exec usp_AccpacCreateSelectField 'Opportunity', 'oppo_PRAdSize', 'Ad Size', 'Oppo_PRAdRun'
-- these fields replace oppo_PRExternalReference and oppo_PRInternalReference
exec usp_AccpacCreateSearchSelectField 'Opportunity', 'oppo_PRReferredByCompanyId', 'Referring Company', 'Company', 50
exec usp_AccpacCreateSearchSelectField 'Opportunity', 'oppo_PRReferredByPersonId', 'Referring Person', 'Person'
exec usp_AccpacCreateUserSelectField 'Opportunity', 'oppo_PRReferredByUserId', 'Referring PRCo Employee'
exec usp_AccpacCreateDateField      'Opportunity', 'oppo_SignedAuthReceivedDate', 'Date Signed Auth Rcv''d'

-- OWNERSHIP START
exec usp_AccpacCreateTable 'PROwnership', 'prow', 'prow_OwnershipId'
exec usp_AccpacCreateKeyField 'PROwnership', 'prow_OwnershipId', 'Ownership Id' 

exec usp_AccpacCreateSearchSelectField 'PROwnership', 'prow_CompanyId', 'Company', 'Company', 10, '17', NULL, 'Y'
exec usp_AccpacCreateTextField 'PROwnership', 'prow_Company1Ownership', 'ABC Corporation Pct', 10
exec usp_AccpacCreateTextField 'PROwnership', 'prow_Individual1Ownership', 'John Smith Pct', 10
exec usp_AccpacCreateTextField 'PROwnership', 'prow_Individual2Ownership', 'Jane Doe Pct', 10
exec usp_AccpacCreateTextField 'PROwnership', 'prow_UnattributedOwnerDesc', 'Unattributed Owner Desc', 20
exec usp_AccpacCreateTextField 'PROwnership', 'prow_UnattributedOwnerPct', 'Unattributed Owner Pct', 10
exec usp_AccpacCreateTextField 'PROwnership', 'prow_Total', 'Total', 10

-- PHONE
exec usp_AccpacCreateSelectField   'Phone', 'phon_Type',           'Type', 'phon_Type' 
exec usp_AccpacCreateCheckboxField 'Phone', 'phon_Default',        'Default'
exec usp_AccpacCreateTextField	   'Phone', 'phon_Number',         'Phone Number', 34
--  set the component = null for default accpac fields so that uninstall scripts do not remove them
UPDATE Custom_Edits set colp_component = null where colp_colname in ('phon_Type','phon_Default', 'phon_Number')
exec usp_AccpacCreateTextField     'Phone', 'phon_PRDescription',  'Description', 34
exec usp_AccpacCreateTextField     'Phone', 'phon_PRExtension',    'Extension', 5
-- International code and citycode are becoming obsolete
exec usp_AccpacCreateCheckboxField 'Phone', 'phon_PRInternational','International'
exec usp_AccpacCreateTextField     'Phone', 'phon_PRCityCode',    'City Code (Outside US/Canada)', 5
exec usp_AccpacCreateCheckboxField 'Phone', 'phon_PRPublish',      'Publish'
exec usp_AccpacCreateCheckboxField 'Phone', 'phon_PRDisconnected', 'Disconnected'
exec usp_AccpacCreateIntegerField  'Phone', 'phon_PRSequence',     'Sequence'
exec usp_AccpacCreateIntegerField  'Phone', 'phon_PRReplicatedFromId', 'Replicated From Phone Id'
exec usp_AccpacCreateIntegerField  'Phone', 'phon_PRSlot', 'BBS Slot Number'

--
-- SERVICE START
--
exec usp_AccpacCreateTable 'PRService', 'prse', 'prse_ServiceId'
exec usp_AccpacCreateKeyField 'PRService', 'prse_ServiceId', 'Service Id' 

-- Reset the prse_ServiceId so that it is NOT an
-- advanced search select, but instead just an integer
-- textbox
UPDATE custom_edits
   SET colp_EntryType = 31, -- Integer
       colp_EntrySize = 10,
       colp_Required = 'N'
 WHERE colp_Entity = 'PRService'
   AND colp_ColName = 'prse_ServiceID';

exec usp_AccpacCreateSearchSelectField 'PRService', 'prse_CompanyId', 'Company', 'Company', 10, '17', NULL, 'Y'
exec usp_AccpacCreateSelectField 'PRService', 'prse_ServiceCode', 'Code', 'prse_ServiceCode' 
exec usp_AccpacCreateSelectField 'PRService', 'prse_ServiceSubCode', 'Sub Code', 'prse_ServiceSubCode' 
exec usp_AccpacCreateCheckboxField 'PRService', 'prse_Primary', 'Primary'
exec usp_AccpacCreateDateField 'PRService', 'prse_CodeStartDate', 'Code Start'
exec usp_AccpacCreateDateField 'PRService', 'prse_NextAnniversaryDate', 'Next Anniv.'
exec usp_AccpacCreateDateField 'PRService', 'prse_CodeEndDate', 'Code End'
exec usp_AccpacCreateDateField 'PRService', 'prse_StopServiceDate', 'Stop Service'
exec usp_AccpacCreateSelectField 'PRService', 'prse_CancelCode', 'Cancel Code', 'prse_CancelCode' 
exec usp_AccpacCreateDateField 'PRService', 'prse_ServiceSinceDate', 'Service Since'
exec usp_AccpacCreateSelectField 'PRService', 'prse_InitiatedBy', 'Initiated By', 'prse_InitiatedBy' 
exec usp_AccpacCreateSearchSelectField 'PRService', 'prse_BillToCompanyId', 'Bill To', 'Company', 10, '17', NULL, 'Y'
exec usp_AccpacCreateSelectField 'PRService', 'prse_Terms', 'Terms', 'prse_Terms' 
exec usp_AccpacCreateTextField 'PRService', 'prse_HoldShipmentId', 'Hold Shipment ID', 5
exec usp_AccpacCreateTextField 'PRService', 'prse_HoldMailId', 'Hold Mail ID', 5
exec usp_AccpacCreateTextField 'PRService', 'prse_EBBSerialNumber', 'EBB Serial Number', 20
exec usp_AccpacCreateCheckboxField 'PRService', 'prse_ContractOnHand', 'Contract On Hand'
exec usp_AccpacCreateSelectField 'PRService', 'prse_DeliveryMethod', 'Delivery Method', 'prse_DeliveryMethod' 
exec usp_AccpacCreateTextField 'PRService', 'prse_ReferenceNumber', 'Reference Number', 20
exec usp_AccpacCreateDateField 'PRService', 'prse_ShipmentDate', 'Shipment Date'
exec usp_AccpacCreateTextField 'PRService', 'prse_ShipmentDescription', 'Shipment Description', 50
exec usp_AccpacCreateTextField 'PRService', 'prse_Description', 'Service Description', 50
exec usp_AccpacCreateIntegerField 'PRService', 'prse_ServicePrice', 'Service Price', 10
exec usp_AccpacCreateIntegerField 'PRService', 'prse_UnitsPackaged', 'Units Packaged', 10


-- SERVICE PAYMENT
exec usp_AccpacCreateTable 'PRServicePayment', 'prsp', 'prsp_ServicePaymentId'
exec usp_AccpacCreateKeyField 'PRServicePayment', 'prsp_ServicePaymentId', 'Service Delivery Id' 
exec usp_AccpacCreateSearchSelectField 'PRServicePayment', 'prsp_ServiceId', 'Service', 'PRService', 10, '0', NULL, 'Y'
exec usp_AccpacCreateDateField 'PRServicePayment', 'prsp_InvoiceDate', 'Invoice Date'
exec usp_AccpacCreateTextField 'PRServicePayment', 'prsp_MasterInvoiceNumber', 'Master Invoice Number', 20
exec usp_AccpacCreateTextField 'PRServicePayment', 'prsp_SubInvoiceNumber', 'Sub Invoice Number', 20
exec usp_AccpacCreateNumericField 'PRServicePayment', 'prsp_BilledAmount', 'Billed Amount', 10
exec usp_AccpacCreateNumericField 'PRServicePayment', 'prsp_ReceivedAmount', 'Received Amount', 10
exec usp_AccpacCreateDateField 'PRServicePayment', 'prsp_BillingPeriodStart', 'Billing Period Start'
exec usp_AccpacCreateDateField 'PRServicePayment', 'prsp_BillingPeriodEnd', 'Billing Period End'
exec usp_AccpacCreateNumericField 'PRServicePayment', 'prsp_Tax', 'Tax', 10
exec usp_AccpacCreateTextField 'PRServicePayment', 'prsp_CheckNumber', 'Check Number', 20
exec usp_AccpacCreateNumericField 'PRServicePayment', 'prsp_Balance', 'Balance', 10
exec usp_AccpacCreateDateField 'PRServicePayment', 'prsp_TransactionDate', 'Transaction Date'
exec usp_AccpacCreateSelectField 'PRServicePayment', 'prsp_Activity', 'Activity', 'prsp_Activity' 
exec usp_AccpacCreateNumericField 'PRServicePayment', 'prsp_Effect', 'Payment Affect', 10
exec usp_AccpacCreateTextField 'PRServicePayment', 'prsp_ServiceCode', 'Service Code', 2

-- SERVICE UNIT ALLOCATION
exec usp_AccpacCreateTable 'PRServiceUnitAllocation', 'prun', 'prun_ServiceUnitAllocationId'
exec usp_AccpacCreateKeyField 'PRServiceUnitAllocation', 'prun_ServiceUnitAllocationId', 'Service Unit Allocation ID' 
exec usp_AccpacCreateSearchSelectField 'PRServiceUnitAllocation', 'prun_CompanyId', 'Company', 'Company', 10, '17', NULL, 'Y'
exec usp_AccpacCreateSearchSelectField 'PRServiceUnitAllocation', 'prun_PersonId', 'Person', 'Person', 10, '0', 'Y' 
exec usp_AccpacCreateSearchSelectField 'PRServiceUnitAllocation', 'prun_ServiceId', 'Service', 'PRService', 10, '0', 'Y'
exec usp_AccpacCreateSelectField 'PRServiceUnitAllocation', 'prun_SourceCode', 'Source', 'prun_SourceCode' 
exec usp_AccpacCreateSelectField 'PRServiceUnitAllocation', 'prun_AllocationTypeCode', 'Allocation Type', 'prun_AllocationTypeCode' 
exec usp_AccpacCreateDateField 'PRServiceUnitAllocation', 'prun_StartDate', 'Start Date'
exec usp_AccpacCreateDateField 'PRServiceUnitAllocation', 'prun_ExpirationDate', 'Expiration Date'
exec usp_AccpacCreateIntegerField 'PRServiceUnitAllocation', 'prun_UnitsAllocated', 'Units Allocated', 10
exec usp_AccpacCreateIntegerField 'PRServiceUnitAllocation', 'prun_UnitsRemaining', 'Units Remaining', 10

-- SERVICE UNIT USAGE
exec usp_AccpacCreateTable 'PRServiceUnitUsage', 'prsuu', 'prsuu_ServiceUnitUsageId'
exec usp_AccpacCreateKeyField 'PRServiceUnitUsage', 'prsuu_ServiceUnitUsageId', 'Service Unit Usage ID' 
exec usp_AccpacCreateSearchSelectField 'PRServiceUnitUsage', 'prsuu_CompanyId', 'Company', 'Company', 10, '17', NULL, 'Y'
exec usp_AccpacCreateSearchSelectField 'PRServiceUnitUsage', 'prsuu_PersonId', 'Person', 'Person', 10, '0', 'Y' 
exec usp_AccpacCreateIntegerField 'PRServiceUnitUsage', 'prsuu_Units', 'Units', 10
exec usp_AccpacCreateSelectField 'PRServiceUnitUsage', 'prsuu_SourceCode', 'Source', 'prsuu_SourceCode' 
exec usp_AccpacCreateSelectField 'PRServiceUnitUsage', 'prsuu_TransactionTypeCode', 'Transaction Type', 'prsuu_TransactionTypeCode' 
exec usp_AccpacCreateIntegerField 'PRServiceUnitUsage', 'prsuu_ReversalServiceUnitUsageID', 'Reversal ID', 10
exec usp_AccpacCreateSelectField 'PRServiceUnitUsage', 'prsuu_ReversalReasonCode', 'Reversal Reason', 'prsuu_ReversalReasonCode' 
exec usp_AccpacCreateSelectField 'PRServiceUnitUsage', 'prsuu_UsageTypeCode', 'Usage Type', 'prsuu_UsageTypeCode' 
exec usp_AccpacCreateIntegerField 'PRServiceUnitUsage', 'prsuu_RegardingObjectID', 'Regarding Object ID', 10
exec usp_AccpacCreateTextField 'PRServiceUnitUsage', 'prsuu_SearchCriteria', 'Search Criteria', 3500

-- SERVICE UNIT ALLOCATION USAGE
exec usp_AccpacCreateTable 'PRServiceUnitAllocationUsage', 'prsua', 'prsua_ServiceUnitUsageAllocationId'
exec usp_AccpacCreateKeyField 'PRServiceUnitAllocationUsage', 'prsua_ServiceUnitUsageAllocationId', 'Service Unit Allocation Usage ID' 
exec usp_AccpacCreateIntegerField 'PRServiceUnitAllocationUsage', 'prsua_ServiceUnitAllocationId', 'Service Unit Allocation', 10
exec usp_AccpacCreateIntegerField 'PRServiceUnitAllocationUsage', 'prsua_ServiceUnitUsageId', 'Service Unit Usage', 10

-- SERVICE UNIT ALA CARTE
exec usp_AccpacCreateTable 'PRServiceAlaCarte', 'prsac', 'prsac_PRServiceAlaCarteId'
exec usp_AccpacCreateKeyField 'PRServiceAlaCarte', 'prsac_PRServiceAlaCarteId', 'Service Unit Ala Carte ID' 
exec usp_AccpacCreateIntegerField 'PRServiceAlaCarte', 'prsac_ID', 'ID'
exec usp_AccpacCreateIntegerField 'PRServiceAlaCarte', 'prsac_NonmemberUsageID', 'Nonmember Usage ID'
exec usp_AccpacCreateSelectField 'PRServiceAlaCarte', 'prsac_PurchaseType', 'Purchase Type', 'prsac_PurchaseType' 
exec usp_AccpacCreateDateField 'PRServiceAlaCarte', 'prsac_PurchaseDate', 'Purchase Date'
exec usp_AccpacCreateTextField 'PRServiceAlaCarte', 'prsac_RefNum', 'Reference Number', 50
exec usp_AccpacCreateNumericField 'PRServiceAlaCarte', 'prsac_Amount', 'Amount', 10
exec usp_AccpacCreateTextField 'PRServiceAlaCarte', 'prsac_IPAddress', 'IP Address', 15
exec usp_AccpacCreateTextField 'PRServiceAlaCarte', 'prsac_CreditCardNumber', 'Credit Card Number', 4
exec usp_AccpacCreateSelectField 'PRServiceAlaCarte', 'prsac_CreditCardType', 'Credit Card Type', 'prsac_CreditCardType' 
exec usp_AccpacCreateIntegerField 'PRServiceAlaCarte', 'prsac_ExpirationDateMonth', 'Expiration Date Month'
exec usp_AccpacCreateIntegerField 'PRServiceAlaCarte', 'prsac_ExpirationDateYear', 'Expiration Date Year'
exec usp_AccpacCreateTextField 'PRServiceAlaCarte', 'prsac_BBID', 'BBID?', 1
exec usp_AccpacCreateTextField 'PRServiceAlaCarte', 'prsac_FirstName', 'First Name', 17
exec usp_AccpacCreateTextField 'PRServiceAlaCarte', 'prsac_MI', 'Middle Initial', 1
exec usp_AccpacCreateTextField 'PRServiceAlaCarte', 'prsac_LastName', 'Last Name', 19
exec usp_AccpacCreateTextField 'PRServiceAlaCarte', 'prsac_CompanyName', 'Company Name', 48
exec usp_AccpacCreateTextField 'PRServiceAlaCarte', 'prsac_Address1', 'Address 1', 35
exec usp_AccpacCreateTextField 'PRServiceAlaCarte', 'prsac_Address2', 'Address 2', 35
exec usp_AccpacCreateTextField 'PRServiceAlaCarte', 'prsac_City', 'City', 25
exec usp_AccpacCreateTextField 'PRServiceAlaCarte', 'prsac_County', 'County', 1
exec usp_AccpacCreateTextField 'PRServiceAlaCarte', 'prsac_State', 'State', 11
exec usp_AccpacCreateTextField 'PRServiceAlaCarte', 'prsac_Country', 'Country', 36
exec usp_AccpacCreateTextField 'PRServiceAlaCarte', 'prsac_PostalCode', 'Postal Code', 10
exec usp_AccpacCreateTextField 'PRServiceAlaCarte', 'prsac_Phone', 'Phone', 19
exec usp_AccpacCreateTextField 'PRServiceAlaCarte', 'prsac_Fax', 'Fax', 19
exec usp_AccpacCreateTextField 'PRServiceAlaCarte', 'prsac_Email', 'Email', 36
exec usp_AccpacCreateTextField 'PRServiceAlaCarte', 'prsac_WebSite', 'Website', 29
exec usp_AccpacCreateTextField 'PRServiceAlaCarte', 'prsac_JobTitle', 'Job Title', 42
exec usp_AccpacCreateTextField 'PRServiceAlaCarte', 'prsac_Classification', 'Classification', 14
exec usp_AccpacCreateTextField 'PRServiceAlaCarte', 'prsac_CompanySize', 'Company Size', 10
exec usp_AccpacCreateTextField 'PRServiceAlaCarte', 'prsac_AutoEmail', 'Auto Email', 5
exec usp_AccpacCreateTextField 'PRServiceAlaCarte', 'prsac_UnitAllocationID', 'Unit Allocation ID', 1
exec usp_AccpacCreateTextField 'PRServiceAlaCarte', 'prsac_PurchaseTerms', 'Perchase Terms', 8
exec usp_AccpacCreateTextField 'PRServiceAlaCarte', 'prsac_LearnedText', 'Learned Text', 82
exec usp_AccpacCreateTextField 'PRServiceAlaCarte', 'prsac_UsageType', 'Usage Type', 1
exec usp_AccpacCreateIntegerField 'PRServiceAlaCarte', 'prsac_SubjectBBID', 'Subject BBID'
exec usp_AccpacCreateTextField 'PRServiceAlaCarte', 'prsac_Field037', 'Field037', 255
exec usp_AccpacCreateIntegerField 'PRServiceAlaCarte', 'prsac_MLCount', 'ML Count'
exec usp_AccpacCreateTextField 'PRServiceAlaCarte', 'prsac_UsageLevel', 'Learned Text', 1

-- The PRPubAddr is a mirror of the BBS PubAddr table
-- PIKS needs to be aware of this data when maintaining address
-- data.  PIKS does not maintain this data.

-- PRPubAddr
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PRPubAddr]') AND type in (N'U'))
	DROP TABLE [dbo].[PRPubAddr]
GO
CREATE TABLE [dbo].[PRPubAddr](
	puba_svcid int NULL,
	puba_pubtype nvarchar(5) NULL,
	puba_startmmdd nvarchar(4) NULL,
	puba_how nvarchar(1) NULL,
	puba_include nvarchar(1) NULL,
	puba_attn nvarchar(44) NULL,
	puba_addrid int NULL,
    puba_exc nvarchar(1) NULL)


-- EMAIL
exec usp_AccpacCreateIntegerField   'Email', 'emai_PRSequence', 'Sequence'
exec usp_AccpacCreateUrlField   'Email', 'emai_PRWebAddress', 'Web Address'
exec usp_AccpacCreateTextField		'Email', 'emai_PRDescription', 'Description', 50
exec usp_AccpacCreateCheckboxField  'Email', 'emai_PRPublish', 'Publish'
exec usp_AccpacCreateCheckboxField  'Email', 'emai_PRDefault', 'Default'
exec usp_AccpacCreateIntegerField   'Email', 'emai_PRReplicatedFromId', 'Replicated From'
exec usp_AccpacCreateIntegerField   'Email', 'emai_PRSlot', 'BBS Slot Number'
-- special script to modify the email type field
-- cannot use usp_getNextId because it doesn't exist yet
Declare @NextId int
Declare @NOW datetime
set @NOW = getdate()
Declare @TableId int
select @TableId = Bord_TableId from custom_tables where bord_Name = 'custom_edits'
exec @NextId = crm_next_id @TableId
Insert into custom_edits 
    (ColP_ColPropsId, ColP_Entity, ColP_ColName, ColP_EntryType, ColP_LookupFamily, 
     ColP_CreatedBy, ColP_CreatedDate, ColP_UpdatedBy,ColP_UpdatedDate,ColP_TimeStamp,ColP_Component)
    Values (@NextId, 'Email', 'emai_Type', 21, 'emai_Type',-1, @NOW, -1, @NOW, @NOW, 'PRGeneral')
-- special script to make the email address field larger
update custom_edits set colp_entrysize = 50 where colp_colname = 'emai_EmailAddress'

DROP TABLE tAccpacComponentName 

GO




-- 
-- Written to by the usp_CreateEmail proc and read from by
-- the BBSMonitor windows service.  Used to send faxes.
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PRFaxQueue]') AND type in (N'U'))
	DROP TABLE [dbo].[PRFaxQueue]
GO

CREATE TABLE [dbo].[PRFaxQueue](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Who] [varchar](50) NULL,
	[Attachment] [varchar](500)  NULL,
    [IsLibraryDocument] [varchar](1)  NULL,
	[FaxNumber] [varchar](50)  NOT NULL,
	[PersonName] [varchar](100)  NULL,
	[ScheduledDateTime] datetime NULL,
    [Priority] [varchar](40)  NOT NULL,
	[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_PRFaxQueue_CreatedDate]  DEFAULT (getdate()),
 CONSTRAINT [PK_PRFaxQueue] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)
)
Go






SET NOCOUNT OFF
GO

-- ********************* END TABLE AND FIELD CREATION *************************
