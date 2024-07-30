--EXEC usp_AccpacGetBlockInfo 'PREmailGrid'
--EXEC usp_AccpacGetBlockInfo 'PersonPhoneGrid'
--EXEC usp_AccpacGetBlockInfo 'CompanyPhoneGrid'




EXEC usp_AccpacRegisterViewAsTable 'vCompanyEmail'
EXEC usp_AccpacRegisterViewAsTable 'vPersonEmail'
EXEC usp_AccpacRegisterViewAsTable 'vPRCompanyPhone'
EXEC usp_AccpacRegisterViewAsTable 'vPRPersonPhone'

EXEC usp_AccpacCreateSearchSelectField 'Email', 'emai_CompanyID', 'Company', 'Company', 100 
EXEC usp_AccpacCreateSearchSelectField 'Phone', 'phon_CompanyID', 'Company', 'Company', 100 

EXEC usp_AddCustom_Screens 'PhoneNewEntry', 10, 'phon_CompanyID', 1, 1, 5, 0
EXEC usp_AddCustom_Screens 'EmailNewEntry', 10, 'emai_CompanyID', 1, 1, 4, 0

UPDATE Custom_ScreenObjects
   SET cobj_TargetTable = 'vCompanyEmail'
 WHERE cobj_TableID = 10544

UPDATE Custom_Lists
   SET grip_colname = 'elink_type'
 WHERE grip_GridPropsID = 12796;

 --SELECT * FROM custom_Captions WHERE capt_code = 'emai_Type'
--EXEC usp_AddCustom_Captions 'Tags', 'ColNames', 'elink_type', 0, 'Type', 'Type', 'Type', 'Type', 'Type', 'Type', 'Type'
EXEC usp_AccpacCreateSelectField 'Email', 'elink_type', 'Type', 'elink_type', NULL, NULL, NULL, NULL, 'Y'

EXEC usp_DeleteCustom_List 'PRPersonEmailGrid', 'emai_PRWebAddress'
Go

UPDATE Custom_ScreenObjects
   SET cobj_TargetTable = 'vPRCompanyPhone'
 WHERE cobj_TableID = 10615;


UPDATE Custom_ScreenObjects
   SET cobj_TargetTable = 'vPRPersonPhone'
 WHERE cobj_TableID = 10616;

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_Email_ins]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
	drop trigger [dbo].[trg_Email_ins]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_Phone_Company_insupd]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
	drop trigger [dbo].[trg_Phone_Company_insupd]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_Phone_Company_insupd]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
	drop trigger [dbo].[trg_Phone_Company_insupd]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_Phone_Company_del]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
	drop trigger [dbo].[trg_Phone_Company_del]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PhoneLink_InstUpd]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
	drop trigger [dbo].[PhoneLink_InstUpd]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_Phone_insdel]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
	drop trigger [dbo].[trg_Phone_insdel]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[EmailLink_InstUpd]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
	drop trigger [dbo].[EmailLink_InstUpd]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_Email_insdel]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_Email_insdel]
GO


--DROP INDEX ndx_Phone_01 ON Phone;
--DROP INDEX ndx_Phone_02 ON Phone;
--DROP INDEX ndx_Phone_03 ON Phone;
--DROP INDEX ndx_Phone_04 ON Phone;
GO



EXEC usp_AddCustom_ScreenObjects 'PRPersonEmailGrid', 'List', 'Email', 'N', 0, 'vPersonEmail'
EXEC usp_AddCustom_Lists 'PRPersonEmailGrid', 10, 'elink_Type', null, 'Y', null, null, 'Custom', 'NULL', 'NULL', 'PRGeneral/PREmail.asp', 'emai_EmailId'
EXEC usp_AddCustom_Lists 'PRPersonEmailGrid', 20, 'emai_EmailAddress', null, 'Y', null, null, 'Custom', 'NULL', 'NULL', 'PRGeneral/PREmail.asp', 'emai_EmailId'
EXEC usp_AddCustom_Lists 'PRPersonEmailGrid', 30, 'emai_PRWebAddress', null, 'Y', null, null, 'Custom', 'NULL', 'NULL', 'PRGeneral/PREmail.asp', 'emai_EmailId'
EXEC usp_AddCustom_Lists 'PRPersonEmailGrid', 40, 'emai_CompanyID', null, 'Y', null, null
EXEC usp_AddCustom_Lists 'PRPersonEmailGrid', 50, 'emai_PRDescription', null, 'Y', null, null
EXEC usp_AddCustom_Lists 'PRPersonEmailGrid', 60, 'emai_PRPreferredInternal', null, 'Y', null, 'center'
EXEC usp_AddCustom_Lists 'PRPersonEmailGrid', 70, 'emai_PRPublish', null, 'Y', null, 'center'
EXEC usp_AddCustom_Lists 'PRPersonEmailGrid', 80, 'emai_PRPreferredPublished', null, 'Y', null, 'center'

EXEC usp_AddCustom_Lists 'PersonPhoneGrid', 30, 'phon_CompanyID', null, 'Y', null, null
Go


UPDATE Custom_ScreenObjects
   SET cobj_TargetTable = 'vPREmail'
 WHERE cobj_TableID = 10945

UPDATE Custom_Screens
   SET SeaP_ColName = 'elink_type'
 WHERE SeaP_SearchEntryPropsId = 7399;

UPDATE Custom_Edits
   SET colp_EntrySize = 50
 WHERE colp_ColName = 'emai_EmailAddress'


EXEC usp_AddCustom_Screens 'EmailNewEntry', 30, 'emai_PRDescription',  0, 1, 3, 0
EXEC usp_AddCustom_Screens 'EmailNewEntry', 40, 'emai_EmailAddress',  1, 1, 2, 0
EXEC usp_AddCustom_Screens 'EmailNewEntry', 50, 'emai_PRWebAddress',  0, 1, 2, 0

UPDATE Custom_Screens
   SET SeaP_ColName = 'plink_Type'
 WHERE SeaP_SearchEntryPropsId = 7410;

EXEC usp_AccpacCreateSelectField 'Phone', 'plink_Type', 'Type', 'plink_Type', NULL, NULL, NULL, NULL, 'Y'

UPDATE Custom_Lists
   SET grip_Alignment = 'center'
 WHERE grip_GridPropsID = 12802;

UPDATE Custom_Lists
   SET grip_Alignment = 'center'
 WHERE grip_GridPropsID = 12530;
 

UPDATE Custom_Lists
   SET grip_Alignment = 'center'
 WHERE grip_GridPropsID = 12894;

EXEC usp_AddCustom_Lists 'CommunicationToDoList', 75, 'comm_hasattachments', null, 'Y', null, 'CENTER', 'communication', 'Y', NULL, NULL, NULL

--SELECT * FROM Custom_Lists WHERE GriP_ColName = 'comm_hasattachments' AND grip_DeviceID IS NULL

--ATTACHMENT
UPDATE Custom_Lists
   SET grip_ViewMode = 'GIF',
       GriP_CustomEditsIDFK = 820,
	   GriP_AllowOrderBy = NULL
 WHERE grip_ColName = 'comm_hasattachments'
--   AND grip_GridName = 'CommunicationToDoList'
   


UPDATE Custom_ScreenObjects
   SET Cobj_CustomContent = '<script type="text/javascript" src="../CustomPages/PRCoGeneral.js"></script><script "text/javascript" src="../CustomPages/PRGeneral/PRInteraction.js"></script><script type="text/javascript">RedirectInteraction();</script>'
 WHERE Cobj_Name = 'CustomCommunicationDetailBox';

UPDATE Custom_ScreenObjects
   SET Cobj_CustomContent = '<script type="text/javascript" src="../CustomPages/PRCoGeneral.js"></script><script type="text/javascript" src="../CustomPages/PRGeneral/PRInteraction.js"></script><script type="text/javascript">WriteArchiveReportButtonTable();initOnLoad();</script>'
 WHERE cobj_Name = 'CommunicationFilterBox'



UPDATE Custom_ScreenObjects
   SET Cobj_FTable = NULL,
       cobj_FTableFCol = NULL
WHERE cobj_name = 'CustomCommunicationDetailBox'

EXEC usp_DeleteCustom_Screen 'CustomCommunicationDetailBox', 'Comm_Location'
EXEC usp_DeleteCustom_Screen 'CommWebPicker', 'Comm_OpportunityId'
Go

 UPDATE Custom_ScreenObjects
    SET cobj_CustomContent = '<script type="text/javascript" src="/CRM/CustomPages/PRCoGeneral.js"></script><script type="text/javascript" src="/CRM/CustomPages/PRPerson/PersonSearch.js"></script><script type="text/javascript">if (window.addEventListener) { window.addEventListener("load", initializeSearch); } else {window.attachEvent("onload", initializeSearch); }</script>'
  WHERE cobj_Name = 'PersonSearchBox'	

 UPDATE Custom_ScreenObjects
    SET cobj_CustomContent = '<script type="text/javascript" src="/CRM/CustomPages/PRCoGeneral.js"></script><script type="text/javascript" src="/CRM/CustomPages/PRCompany/CompanySearch.js"></script><script type="text/javascript">if (window.addEventListener) { window.addEventListener("load", initializeSearch); } else {window.attachEvent("onload", initializeSearch); }</script>'
  WHERE cobj_Name = 'CompanySearchBox'

 UPDATE Custom_ScreenObjects
    SET cobj_CustomContent = '<script type="text/javascript" src="/CRM/CustomPages/PRCoGeneral.js"></script><script type="text/javascript" src="PRCompanyAdvancedSearch.js"></script><script type="text/javascript">if (window.addEventListener) { window.addEventListener("load", initCompanyAdvancedSearch); } else {window.attachEvent("onload", initCompanyAdvancedSearch); }</script>'
  WHERE cobj_Name = 'CompanyAdvancedSearchBox'

 UPDATE Custom_ScreenObjects
    SET cobj_CustomContent = '<script type="text/javascript" src="/CRM/CustomPages/PRCoGeneral.js"></script><script type="text/javascript" src="PRPersonAdvancedSearch.js"></script><script type="text/javascript">if (window.addEventListener) { window.addEventListener("load", initPersonAdvancedSearch); } else {window.attachEvent("onload", initPersonAdvancedSearch); }</script>'
  WHERE cobj_Name = 'PersonAdvancedSearchBox'
Go



UPDATE Custom_edits
   SET colp_EntrySize = 50,
       ColP_LookupFamily = 'Company'
 WHERE colp_ColName ='peli_CompanyId'
 Go

 
 UPDATE custom_tabs SET tabs_CustomFileName = 'PRTES/PRTESFormBatchViewRedirect.asp' WHERE tabs_TabId=10643
 Go

-- UPDATE Custom_Screens
--   SET SeaP_CreateScript = 'DefaultValue="sagecrm_code_all"'
-- WHERE SeaP_SearchEntryPropsId IN (8118, 180, 460)

UPDATE Custom_Lists SET grip_Order = 55, grip_Jump = 'Custom', GriP_CustomAction='PRGeneral/PRInteraction.asp', grip_CustomIDField = 'comm_communicationid' WHERE grip_GridName = 'CommunicationToDoList' AND grip_ColName = 'comm_Subject'
UPDATE Custom_Lists SET grip_Jump = 'Custom', GriP_CustomAction='PRGeneral/PRInteraction.asp', grip_CustomIDField = 'comm_communicationid'  WHERE grip_GridName = 'CommunicationToDoList' AND grip_ColName = 'comm_action' AND grip_Order = 10
UPDATE Custom_Lists SET grip_Jump = null, GriP_CustomAction=null, grip_CustomIDField =null WHERE grip_GridName = 'CommunicationToDoList' AND grip_ColName = 'comm_action' AND grip_Order = 50

EXEC usp_DeleteCustom_List 'CommunicationList', 'CmLi_IsExternalAttendee'
 
UPDATE Custom_Lists
   SET grip_Jump = 'custom',
       GriP_CustomAction = 'PRGeneral/PRInteraction.asp',
	   GriP_CustomIDField = 'comm_communicationid'
WHERE grip_GridName = 'CommunicationList'
  AND GriP_ColName = 'comm_subject'

UPDATE Custom_Lists
   SET grip_Jump = null,
       GriP_CustomAction = null,
	   GriP_CustomIDField = null
WHERE grip_GridName = 'CommunicationList'
  AND GriP_ColName IN ('Comm_Action', 'Comm_DateTime')

EXEC usp_AddCustom_Screens 'CustomCommunicationDetailBox', 10, 'comm_action', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'CustomCommunicationDetailBox', 20, 'comm_organizer', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'CustomCommunicationDetailBox', 30, 'comm_PRCallAttemptCount', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'CustomCommunicationDetailBox', 40, 'comm_PRCategory', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'CustomCommunicationDetailBox', 50, 'comm_PRSubcategory', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'CustomCommunicationDetailBox', 60, 'comm_subject', 1, 1, 3, 0
EXEC usp_AddCustom_Screens 'CustomCommunicationDetailBox', 70, 'comm_location', 1, 1, 3, 0
EXEC usp_AddCustom_Screens 'CustomCommunicationDetailBox', 80, 'comm_note', 1, 1, 3, 0
EXEC usp_AddCustom_Screens 'CustomCommunicationDetailBox', 90, 'comm_status', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'CustomCommunicationDetailBox', 100, 'comm_priority', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'CustomCommunicationDetailBox', 110, 'comm_private', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'CustomCommunicationDetailBox', 120, 'comm_createdby', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'CustomCommunicationDetailBox', 130, 'comm_createddate', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'CustomCommunicationDetailBox', 140, 'comm_percentcomplete', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'CustomCommunicationDetailBox', 150, 'comm_completedtime', 0, 1, 1, 0
Go

EXEC usp_AddCustom_Screens 'PRCreateInteraction', 75, 'comm_Subject', 1, 1, 4, 0
Go




UPDATE Custom_tabs
   SET Tabs_Caption = REPLACE(Tabs_Caption, 'width=100%', 'width:100%')
WHERE tabs_Bitmap = 'transparent.gif'

UPDATE Custom_tabs
   SET Tabs_Caption = REPLACE(Tabs_Caption, '</b>', '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</b>')
WHERE tabs_Bitmap = 'transparent.gif';

UPDATE Custom_Tabs
   SET Tabs_Deleted = '1'
 WHERE tabs_entity = 'User'
   AND Tabs_DeviceID IS NULL
   AND Tabs_Caption IN ('My Contacts', 'Leads', 'Opportunities', 'glibrarylist');
Go

UPDATE custom_tabs
   SET Tabs_Deleted = 1
 WHERE tabs_caption IN ('Cases', 'Self Service')
   AND tabs_DeviceID IS NULL
   AND tabs_entity IN ('company', 'person', 'user');
Go



