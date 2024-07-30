EXEC usp_AccpacDropTable 'PRWebUserCustomField'
EXEC usp_AccpacCreateTable @EntityName='PRWebUserCustomField', @ColPrefix='prwucf', @IDField='prwucf_WebUserCustomFieldID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyField          'PRWebUserCustomField', 'prwucf_WebUserCustomFieldID', 'Web User Custom Field ID'
EXEC usp_AccpacCreateSearchSelectField 'PRWebUserCustomField', 'prwucf_HQID', 'Company', 'Company', 50 
EXEC usp_AccpacCreateSearchSelectField 'PRWebUserCustomField', 'prwucf_CompanyID', 'Company', 'Company', 50 
EXEC usp_AccpacCreateSelectField       'PRWebUserCustomField', 'prwucf_FieldTypeCode', 'Field Type', 'prwucd_FieldTypeCode'
EXEC usp_AccpacCreateTextField         'PRWebUserCustomField', 'prwucf_Label', 'Label', 50, 50
EXEC usp_AccpacCreateCheckboxField     'PRWebUserCustomField', 'prwucf_Pinned', 'Pinned'
EXEC usp_AccpacCreateIntegerField      'PRWebUserCustomField', 'prwucf_Sequence', 'Sequence'
EXEC usp_AccpacCreateCheckboxField     'PRWebUserCustomField', 'prwucf_Hide', 'Hide'

EXEC usp_AccpacDropTable 'PRWebUserCustomFieldLookup'
EXEC usp_AccpacCreateTable @EntityName='PRWebUserCustomFieldLookup', @ColPrefix='prwucfl', @IDField='prwucfl_WebUserCustomFieldLookupID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyField          'PRWebUserCustomFieldLookup', 'prwucfl_WebUserCustomFieldLookupID', 'Web User Custom Field Lookup ID'
EXEC usp_AccpacCreateSearchSelectField 'PRWebUserCustomFieldLookup', 'prwucfl_WebUserCustomFieldID', 'PRWebUserCustomField', 'Custom Field', 50 
EXEC usp_AccpacCreateTextField         'PRWebUserCustomFieldLookup', 'prwucfl_LookupValue', 'Lookup Value', 50, 50
EXEC usp_AccpacCreateIntegerField      'PRWebUserCustomFieldLookup', 'prwucfl_Sequence', 'Sequence'
Go

EXEC usp_AccpacCreateSearchSelectField 'PRWebUserCustomData', 'prwucd_WebUserCustomFieldID', 'PRWebUserCustomField', 'Custom Field', 50 
EXEC usp_AccpacCreateSearchSelectField 'PRWebUserCustomData', 'prwucd_WebUserCustomFieldLookupID', 'PRWebUserCustomFieldLookup', 'Custom Field Lookup', 50 
ALTER TABLE PRWebUserCustomData ALTER COLUMN prwucd_LabelCode nvarchar(40) NULL
Go






EXEC usp_AccpacCreateCheckboxField     'PRWebUserList', 'prwucl_Pinned', 'Pinned'
EXEC usp_AccpacCreateSelectField       'PRWebUserList', 'prwucl_CategoryIcon', 'Category Icon', 'prwucl_CategoryIcon'
Go

EXEC usp_AccpacCreateCheckboxField     'PRWebUserNote', 'prwun_Key', 'Key'
EXEC usp_AccpacCreateDateField	   	   'PRWebUserNote', 'prwun_Date', 'Date'
EXEC usp_AccpacCreateDateField	   	   'PRWebUserNote', 'prwun_DateUTC', 'Date UTC'
EXEC usp_AccpacCreateSelectField       'PRWebUserNote', 'prwun_Hour', 'Hour', 'prwun_Hour'
EXEC usp_AccpacCreateSelectField       'PRWebUserNote', 'prwun_Minute', 'Minute', 'prwun_Minute'
EXEC usp_AccpacCreateSelectField       'PRWebUserNote', 'prwun_AMPM', 'AM/PM', 'prwun_AMPM'
EXEC usp_AccpacCreateSelectField       'PRWebUserNote', 'prwun_Timezone', 'Time Zone', 'prwu_Timezone'


EXEC usp_AccpacDropTable 'PRWebUserNoteReminder'
EXEC usp_AccpacCreateTable @EntityName='PRWebUserNoteReminder', @ColPrefix='prwunr', @IDField='prwunr_WebUserNoteReminderID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyField          'PRWebUserNoteReminder', 'prwunr_WebUserNoteReminderID', 'Web User Note Reminder ID'
EXEC usp_AccpacCreateSearchSelectField 'PRWebUserNoteReminder', 'prwunr_WebUserNoteID', 'PRWebUserNote', 'Note', 50 
EXEC usp_AccpacCreateSearchSelectField 'PRWebUserNoteReminder', 'prwunr_WebUserID', 'PRWebUser', 'BBOS User', 50 
EXEC usp_AccpacCreateSelectField       'PRWebUserNoteReminder', 'prwunr_Threshold', 'Threshold', 'prwu_Threshold'
EXEC usp_AccpacCreateSelectField       'PRWebUserNoteReminder', 'prwunr_Type', 'Type', 'prwu_Type'
EXEC usp_AccpacCreateTextField         'PRWebUserNoteReminder', 'prwunr_Email', 'Email', 255, 255
EXEC usp_AccpacCreateTextField         'PRWebUserNoteReminder', 'prwunr_Phone', 'Phone', 25, 25
EXEC usp_AccpacCreateDateTimeField     'PRWebUserNoteReminder', 'prwunr_SentDateTime', 'Sent Date Time'
EXEC usp_AccpacCreateDateTimeField     'PRWebUserNoteReminder', 'prwunr_SentDateTimeUTC', 'Sent Date Time'
Go

EXEC usp_AccpacCreateSelectField    'PRWebUser', 'prwu_Timezone', 'Time Zone', 'prwu_Timezone'
Go


EXEC usp_DeleteCustom_ScreenObject 'PRCreateInteraction'
EXEC usp_AddCustom_ScreenObjects 'PRCreateInteraction', 'Screen', 'Communication', 'N', 0, 'Communication'
EXEC usp_AddCustom_Screens 'PRCreateInteraction', 10, 'comm_DateTime',       1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCreateInteraction', 20, 'comm_Action',		 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCreateInteraction', 40, 'comm_Status',         1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCreateInteraction', 50, 'comm_Priority',       0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCreateInteraction', 60, 'comm_PRCategory',     1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCreateInteraction', 70, 'comm_PRSubcategory',  0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCreateInteraction', 80, 'Comm_Note',			 1, 1, 4, 0



EXEC usp_AddCustom_Tabs 270, 'find', 'Interactions', 'customfile', 'PRGeneral/Createinteractions.asp', null, 'small_outboundcategory.gif'
Go



EXEC usp_AccpacCreateTextField         'PRWebSiteVisitor', 'prwsv_SubmitterPhone', 'Submitter Phone', 25, 25
EXEC usp_AccpacCreateTextField         'PRWebSiteVisitor', 'prwsv_State', 'State', 30, 30
EXEC usp_AccpacCreateTextField         'PRWebSiteVisitor', 'prwsv_Country', 'Country', 30, 30
Go



EXEC usp_DeleteCustom_ScreenObject 'PPRCourtCasesGrid'
EXEC usp_AddCustom_ScreenObjects 'PPRCourtCasesGrid', 'List', 'vPRCourtCases', 'N', 0, 'vPRCourtCases'
EXEC usp_AddCustom_Lists 'PPRCourtCasesGrid', 10, 'prcc_FiledDate', null, 'Y', 'Y', 'Center'
EXEC usp_AddCustom_Lists 'PPRCourtCasesGrid', 20, 'prcc_CaseNumber', null, 'Y'
EXEC usp_AddCustom_Lists 'PPRCourtCasesGrid', 40, 'Court', null, 'Y'
EXEC usp_AddCustom_Lists 'PPRCourtCasesGrid', 50, 'prcc_SuitType', null, 'Y'
EXEC usp_AddCustom_Lists 'PPRCourtCasesGrid', 60, 'prcc_ClaimAmt', null, 'Y', 'Right'
EXEC usp_AddCustom_Lists 'PPRCourtCasesGrid', 70, 'prcc_CaseOperatingStatus', null, 'Y'
EXEC usp_AddCustom_Lists 'PPRCourtCasesGrid', 80, 'prcc_Notes', null, null

EXEC usp_DefineCaptions 'vPRCourtCases', 'Federal Civil Case', 'Federal Civil Cases', null, null, null, null
Go
