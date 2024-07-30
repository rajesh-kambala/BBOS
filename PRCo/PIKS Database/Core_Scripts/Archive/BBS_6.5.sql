EXEC usp_AccpacCreateTable @EntityName='PRConnectionList', @ColPrefix='prcl2', @IDField='prcl2_ConnectionListID'
EXEC usp_AccpacCreateKeyField          'PRConnectionList', 'prcl2_ConnectionListID', 'Connection List ID'
EXEC usp_AccpacCreateSearchSelectField 'PRConnectionList', 'prcl2_CompanyID', 'Company', 'Company', 50 
EXEC usp_AccpacCreateSearchSelectField 'PRConnectionList', 'prcl2_PersonID', 'Submitted By', 'Person', 50 
EXEC usp_AccpacCreateDateField         'PRConnectionList', 'prcl2_ConnectionListDate', 'Date'
EXEC usp_AccpacCreateSelectField       'PRConnectionList', 'prcl2_Source', 'Source', 'prcl2_Source'
EXEC usp_AccpacCreateCheckboxField	   'PRConnectionList', 'prcl2_Current', 'Current'

EXEC usp_AccpacCreateTable @EntityName='PRConnectionListCompany', @ColPrefix='prclc', @IDField='prclc_ConnectionListCompanyID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyField          'PRConnectionListCompany', 'prclc_ConnectionListCompanyID', 'Connection List Company ID'
EXEC usp_AccpacCreateIntegerField      'PRConnectionListCompany', 'prclc_ConnectionListID', 'Connection List ID'
EXEC usp_AccpacCreateSearchSelectField 'PRConnectionListCompany', 'prclc_RelatedCompanyID', 'Related Company', 'Company', 50 
Go

EXEC usp_DeleteCustom_ScreenObject 'PRConnectionListGrid'
EXEC usp_AddCustom_ScreenObjects 'PRConnectionListGrid', 'List', 'PRConnectionList', 'N', 0, 'vPRConnectionList'
EXEC usp_AddCustom_Lists 'PRConnectionListGrid', 10, 'prcl2_ConnectionListDate', null, 'Y', 'Y', 'CENTER', 'Custom', '', '', 'PRCompany/PRConnectionList.asp', 'prcl2_ConnectionListID'
EXEC usp_AddCustom_Lists 'PRConnectionListGrid', 20, 'prcl2_PersonID'
EXEC usp_AddCustom_Lists 'PRConnectionListGrid', 40, 'prcl2_Source'
EXEC usp_AddCustom_Lists 'PRConnectionListGrid', 50, 'CLCount', null, 'Y', null, 'RIGHT'

EXEC usp_AddCustom_Captions 'Tags', 'ColNames', 'CLCount', 0, 'Count'
UPDATE Custom_Lists
   SET grip_DefaultOrderBy = 'Y'
 WHERE grip_GridName = 'PRConnectionListGrid'
   AND grip_ColName = 'prcl2_ConnectionListDate';
Go

EXEC usp_DefineCaptions 'PRConnectionList', 'Connection List', 'Connection Lists', null, null, null, null
EXEC usp_DefineCaptions 'PRConnectionListCompany', 'Related Company', 'Related Companies', null, null, null, null



EXEC usp_DeleteCustom_ScreenObject 'PRConnectionList'
EXEC usp_AddCustom_ScreenObjects 'PRConnectionList', 'Screen', 'PRConnectionList', 'N', 0, 'PRConnectionList'
EXEC usp_AddCustom_Screens 'PRConnectionList', 10, 'prcl2_CompanyID',          1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRConnectionList', 20, 'prcl2_ConnectionListDate', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRConnectionList', 30, 'prcl2_PersonID',           0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRConnectionList', 40, 'prcl2_Source',             1, 1, 1, 0
--EXEC usp_AddCustom_Screens 'PRConnectionList', 50, 'CLCount',                  0, 1, 1, 0

EXEC usp_DeleteCustom_ScreenObject 'PRConnectionListDetailsGrid'
EXEC usp_AddCustom_ScreenObjects 'PRConnectionListDetailsGrid', 'List', 'PRConnectionListCompany', 'N', 0, 'vPRConnectionListDetails'
EXEC usp_AddCustom_Lists 'PRConnectionListDetailsGrid', 10, 'comp_CompanyID', null, 'Y'
EXEC usp_AddCustom_Lists 'PRConnectionListDetailsGrid', 20, 'comp_Name', null, 'Y', null, null, 'Custom', '', '', 'PRCompany/PRCompanySummary.asp', 'comp_CompanyID'
EXEC usp_AddCustom_Lists 'PRConnectionListDetailsGrid', 40, 'CityStateCountryShort'
EXEC usp_AddCustom_Lists 'PRConnectionListDetailsGrid', 50, 'comp_PRIndustryType', null, 'Y'

Go



EXEC usp_AccpacCreateDateField 'PRPublicationArticle', 'prpbar_CompanyExpirationDate', 'Company Expiration Date'
EXEC usp_AddCustom_Screens 'PRNewsArticleEntry', 70,  'prpbar_CompanyExpirationDate',  0, 1, 1
EXEC usp_AddCustom_Screens 'PRNewsArticleEntry', 80,  'prpbar_ViewCount',  1, 1, 1
Go

EXEC usp_AddCustom_Lists 'PRTESToGrid', 45, 'prtesr_SentDateTime', '', 'Y'
EXEC usp_AddCustom_Lists 'PRTESAboutGrid', 27, 'prtesr_SentDateTime', '', 'Y'
Go
--EXEC usp_AccpacGetBlockInfo 'PRTESToGrid'





DROP INDEX [IDX_Tabs_Entity_Caption] ON [dbo].[Custom_Tabs]
GO

ALTER TABLE Custom_Tabs ALTER COLUMN tabs_caption varchar(500) NOT NULL
Go

CREATE NONCLUSTERED INDEX [IDX_Tabs_Entity_Caption] ON [dbo].[Custom_Tabs] ([Tabs_Entity] ASC, [Tabs_Caption] ASC) 
GO

UPDATE Custom_tabs
   SET tabs_deleted = 1
 WHERE tabs_tabid IN (151, 152, 153, 10777, 189, 10753, 10754, 10707, 10635)

DELETE FROM Custom_Tabs where tabs_Entity='find' AND tabs_Order IN (200, 300, 400, 500, 600)
DECLARE @Now datetime = GETDATE()
DECLARE @bord_TableId int, @NextId int
SELECT @bord_TableId = Bord_TableId FROM Custom_Tables WHERE Bord_Caption = N'Custom_Tabs' AND Bord_Deleted IS NULL

EXEC @NextId = crm_next_id @bord_TableId
INSERT INTO Custom_Tabs (tabs_TabID, tabs_Entity, tabs_Caption, tabs_Order, tabs_Action, tabs_Customfilename, tabs_Bitmap, tabs_Component, tabs_Permission, tabs_Perlevel, tabs_CreatedBy, tabs_CreatedDate, tabs_UpdatedBy, tabs_TimeStamp, tabs_UpdatedDate)  
VALUES (@NextId,'find', '<span class=GRIDHEAD style=width=100%;padding-top:3px;padding-bottom:3px;>&nbsp;&nbsp;<b>Generate</b></span>', 200, '-- noaction --', null, 'transparent.gif', 'Changed', 0, 0, -1, @Now, -1, @Now, @Now)

EXEC @NextId = crm_next_id @bord_TableId
INSERT INTO Custom_Tabs (tabs_TabID, tabs_Entity, tabs_Caption, tabs_Order, tabs_Action, tabs_Customfilename, tabs_Bitmap, tabs_Component, tabs_Permission, tabs_Perlevel, tabs_CreatedBy, tabs_CreatedDate, tabs_UpdatedBy, tabs_TimeStamp, tabs_UpdatedDate)  
VALUES (@NextId,'find', '<span class=GRIDHEAD style=width=100%;padding-top:3px;padding-bottom:3px;>&nbsp;&nbsp;<b>Import</b></span>', 300, '-- noaction --', null, 'transparent.gif', 'Changed', 0, 0, -1, @Now, -1, @Now, @Now)

EXEC @NextId = crm_next_id @bord_TableId
INSERT INTO Custom_Tabs (tabs_TabID, tabs_Entity, tabs_Caption, tabs_Order, tabs_Action, tabs_Customfilename, tabs_Bitmap, tabs_Component, tabs_Permission, tabs_Perlevel, tabs_CreatedBy, tabs_CreatedDate, tabs_UpdatedBy, tabs_TimeStamp, tabs_UpdatedDate)  
VALUES (@NextId,'find', '<span class=GRIDHEAD style=width=100%;padding-top:3px;padding-bottom:3px;>&nbsp;&nbsp;<b>Export</b></span>', 400, '-- noaction --', null, 'transparent.gif', 'Changed', 0, 0, -1, @Now, -1, @Now, @Now)

EXEC @NextId = crm_next_id @bord_TableId
INSERT INTO Custom_Tabs (tabs_TabID, tabs_Entity, tabs_Caption, tabs_Order, tabs_Action, tabs_Customfilename, tabs_Bitmap, tabs_Component, tabs_Permission, tabs_Perlevel, tabs_CreatedBy, tabs_CreatedDate, tabs_UpdatedBy, tabs_TimeStamp, tabs_UpdatedDate)  
VALUES (@NextId,'find', '<span class=GRIDHEAD style=width=100%;padding-top:3px;padding-bottom:3px;>&nbsp;&nbsp;<b>Publish</b></span>', 500, '-- noaction --', null, 'transparent.gif', 'Changed', 0, 0, -1, @Now, -1, @Now, @Now)

EXEC @NextId = crm_next_id @bord_TableId
INSERT INTO Custom_Tabs (tabs_TabID, tabs_Entity, tabs_Caption, tabs_Order, tabs_Action, tabs_Customfilename, tabs_Bitmap, tabs_Component, tabs_Permission, tabs_Perlevel, tabs_CreatedBy, tabs_CreatedDate, tabs_UpdatedBy, tabs_TimeStamp, tabs_UpdatedDate)  
VALUES (@NextId,'find', '<span class=GRIDHEAD style=width=100%;padding-top:3px;padding-bottom:3px;>&nbsp;&nbsp;<b>Queues</b></span>', 600, '-- noaction --', null, 'transparent.gif', 'Changed', 0, 0, -1, @Now, -1, @Now, @Now)




UPDATE custom_tabs SET tabs_order = 20 WHERE tabs_tabid = 149
UPDATE custom_tabs SET tabs_order = 30 WHERE tabs_tabid = 10598
UPDATE custom_tabs SET tabs_order = 40 WHERE tabs_tabid = 150
UPDATE custom_tabs SET tabs_order = 50 WHERE tabs_tabid = 10669
UPDATE custom_tabs SET tabs_order = 60, tabs_Bitmap = 'useractivity.gif' WHERE tabs_tabid = 10724
UPDATE custom_tabs SET tabs_order = 70, tabs_Bitmap = 'cases.gif' WHERE tabs_tabid = 10687
UPDATE custom_tabs SET tabs_order = 80, tabs_Bitmap = 'emptycompany.gif' WHERE tabs_tabid = 10681
UPDATE custom_tabs SET tabs_order = 90, tabs_Bitmap = 'CRMQuote.gif', tabs_caption = 'Credit Sheet Items' WHERE tabs_tabid = 10612
UPDATE custom_tabs SET tabs_order = 100, tabs_Bitmap = 'P_icon.jpg' WHERE tabs_tabid = 10614
UPDATE custom_tabs SET tabs_order = 110, tabs_Bitmap = 'P_icon.jpg' WHERE tabs_tabid = 10657
UPDATE custom_tabs SET tabs_order = 120, tabs_Bitmap = 'emptycompany.gif' WHERE tabs_tabid = 10616
UPDATE custom_tabs SET tabs_order = 130, tabs_Bitmap = 'summaryreportbrowser.gif' WHERE tabs_tabid = 10615
UPDATE custom_tabs SET tabs_order = 140, tabs_caption = 'AR Aging Imp Formats', tabs_Bitmap = 'summaryreportbrowser.gif' WHERE tabs_tabid = 10680
UPDATE custom_tabs SET tabs_order = 150, tabs_caption = 'Dow Jones Company', tabs_Bitmap = 'summaryreportbrowser.gif' WHERE tabs_tabid = 10786

UPDATE custom_tabs SET tabs_order = 210, tabs_caption = 'Blue Book Images', tabs_Bitmap = 'Appointment.gif' WHERE tabs_tabid = 10728
UPDATE custom_tabs SET tabs_order = 220, tabs_caption = 'Invoices', tabs_Bitmap = 'CRMQuote.gif' WHERE tabs_tabid = 10789
UPDATE custom_tabs SET tabs_order = 230, tabs_caption = 'Listing Report Letters', tabs_Bitmap = 'newemail.gif' WHERE tabs_tabid = 10727
UPDATE custom_tabs SET tabs_order = 240, tabs_caption = 'Convert HQ to Branch', tabs_Bitmap = 'Company.gif' WHERE tabs_tabid = 10795
UPDATE custom_tabs SET tabs_order = 250 WHERE tabs_tabid = 10725
UPDATE custom_tabs SET tabs_order = 260, tabs_caption = 'Shipment Addr Lists', tabs_Bitmap = 'emptycompany.gif' WHERE tabs_tabid = 10730

UPDATE custom_tabs SET tabs_order = 310, tabs_caption = '3rd Party News', tabs_Bitmap = 'dataupload.gif' WHERE tabs_tabid = 10787
UPDATE custom_tabs SET tabs_order = 320, tabs_caption = 'BB Scores', tabs_Bitmap = 'dataupload.gif' WHERE tabs_tabid = 10642
UPDATE custom_tabs SET tabs_order = 330, tabs_caption = 'Court Cases', tabs_Bitmap = 'dataupload.gif' WHERE tabs_tabid = 10794
--UPDATE custom_tabs SET tabs_order = 340, tabs_caption = 'DRC Licenses', tabs_Bitmap = 'dataupload.gif' WHERE tabs_tabid = 10635

UPDATE custom_tabs SET tabs_order = 410, tabs_caption = 'TES Form Batch', tabs_Bitmap = 'mydesk.gif' WHERE tabs_tabid = 10643
UPDATE custom_tabs SET tabs_order = 420, tabs_caption = 'Weekly Credit Sheet', tabs_Bitmap = 'mydesk.gif' WHERE tabs_tabid = 10644

UPDATE custom_tabs SET tabs_order = 510, tabs_caption = 'Blueprints Articles', tabs_Bitmap = 'CRMQuote.gif' WHERE tabs_tabid = 10793
UPDATE custom_tabs SET tabs_order = 520, tabs_Bitmap = 'CRMQuote.gif' WHERE tabs_tabid = 10792
UPDATE custom_tabs SET tabs_order = 530, tabs_caption = 'BBOS Training Item', tabs_Bitmap = 'customercare.gif' WHERE tabs_tabid = 10790
UPDATE custom_tabs SET tabs_order = 540, tabs_caption = 'Daily Credit Sheet', tabs_Bitmap = 'CRMQuote.gif' WHERE tabs_tabid = 10729
UPDATE custom_tabs SET tabs_order = 550, tabs_caption = 'News Articles', tabs_Bitmap = 'CRMQuote.gif' WHERE tabs_tabid = 10682
UPDATE custom_tabs SET tabs_order = 560, tabs_caption = 'NHA Video' WHERE tabs_tabid = 10791
UPDATE custom_tabs SET tabs_order = 570, tabs_caption = 'Learning Center PDFs', tabs_Bitmap = 'CRMQuote.gif' WHERE tabs_tabid = 10683

UPDATE custom_tabs SET tabs_order = 610, tabs_caption = 'Shipment Log', tabs_Bitmap = 'products.gif' WHERE tabs_tabid = 10788
UPDATE custom_tabs SET tabs_order = 620, tabs_caption = 'Verbal Invest Calls', tabs_Bitmap = 'small_outboundcategory.gif' WHERE tabs_tabid = 10731

--SELECT tabs_tabid, tabs_caption, tabs_Bitmap, tabs_order FROM custom_tabs where tabs_Entity = 'find' and tabs_deviceID IS NULL ORDER BY tabs_order
Go


UPDATE NewProduct 
   SET prod_PRDescription = 'Our premium membership package provides access to the full suite of Blue Book benefits for a larger user base. This level provides the same features & functionality as the Series 300 - except, you can now leverage these tools among 20 users and take advantage of 3,600 membership units to access comprehensive Business Reports. Confidently identify, build and maintain profitable business connections by using the full portfolio of rating tools Blue Book Services offers.'
 WHERE Prod_ProductID = 7;
Go


DECLARE @NextId int
EXEC @NextId = crm_next_id 39 -- custom captions key
INSERT INTO Custom_Captions (Capt_CaptionId, Capt_FamilyType, Capt_Family, Capt_Code, Capt_US, Capt_Order, Capt_CreatedBy, Capt_CreatedDate, Capt_UpdatedBy, Capt_UpdatedDate,Capt_TimeStamp, Capt_Component) 
   VALUES (@NextId, 'Tags' , 'ColNames', 'RelationshipList', 'Relationship(s)', 0, -1, GETDATE(), -1, GETDATE(), GETDATE(), 'PRCo');


EXEC usp_AddCustom_Lists 'PRTESVISubjectCompaniesGrid', 65, 'RelationshipList'
Go


EXEC usp_AccpacCreateDateField 'Company', 'comp_PROriginalServiceStartDate', 'Original Service Start Date'
EXEC usp_AccpacCreateDateField 'Company', 'comp_PRServiceStartDate', 'Current Service Start Date'
EXEC usp_AccpacCreateDateField 'Company', 'comp_PRServiceEndDate', 'Current Service End Date'
Go



EXEC usp_AccpacCreateCheckboxField	 'PRCreditSheet', 'prcs_Locked', 'Locked'
EXEC usp_AccpacCreateDateField       'PRCreditSheet', 'prcs_LockedDate', 'Locked Date'
EXEC usp_AccpacCreateUserSelectField 'PRCreditSheet', 'prcs_LockedByUser', 'Locked By'
EXEC usp_AccpacCreateDateTimeField   'PRCreditSheet', 'prcs_KilledDate', 'Killed Date'
EXEC usp_AccpacCreateUserSelectField 'PRCreditSheet', 'prcs_KilledByUser', 'Killed By'


EXEC usp_AddCustom_Screens 'PRCreditSheetHeader', 80, 'prcs_NewListing',   1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCreditSheetHeader', 90, 'prcs_CreatedDate',  0, 1, 1, 0

EXEC usp_AddCustom_Screens 'PRCreditSheetHeader', 100, 'prcs_LockedDate',   1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCreditSheetHeader', 110, 'prcs_LockedByUser', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCreditSheetHeader', 111, 'prcs_Locked',		1, 1, 1, 0


EXEC usp_AddCustom_Screens 'PRCreditSheetHeader', 120, 'prcs_KilledDate',   1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCreditSheetHeader', 130, 'prcs_KilledByUser', 0, 1, 1, 0

EXEC usp_AddCustom_Screens 'PRCreditSheetHeader', 140, 'prcs_AuthorNotes',            1, 1, 3, 0
EXEC usp_AddCustom_Screens 'PRCreditSheetHeader', 150, 'prcs_ListingSpecialistNotes', 1, 1, 3, 0
Go




UPDATE Custom_Captions
   SET capt_us = 'Sub-Section'
WHERE capt_family = 'ColNames'
  AND capt_Code = 'pradc_PlannedSection'

EXEC usp_AccpacCreateSelectField       'PRAdCampaign', 'pradc_AdFileCreatedBy', 'Ad File Created By', 'pradc_GraphicArtists'
EXEC usp_AccpacCreateSelectField       'PRAdCampaign', 'pradc_AdFileUpdatedBy', 'Ad File Updated By', 'pradc_GraphicArtists'

EXEC usp_AddCustom_Screens 'PRAdCampaignBP', 203, 'pradc_AdFileCreatedBy', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRAdCampaignBP', 204, 'pradc_AdFileUpdatedBy', 0, 1, 1, 0

EXEC usp_AddCustom_Screens 'PRAdCampaignPUB', 47, 'pradc_AdFileCreatedBy', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRAdCampaignPUB', 48, 'pradc_AdFileUpdatedBy', 0, 1, 1, 0

EXEC usp_AddCustom_Screens 'PRAdCampaignNewEntry', 150, 'pradc_Notes', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRAdCampaignNewEntry', 160, 'pradc_Terms', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRAdCampaignNewEntry', 67, 'pradc_AdFileCreatedBy', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRAdCampaignNewEntry', 68, 'pradc_AdFileUpdatedBy', 0, 1, 1, 0


EXEC usp_AddCustom_Screens 'PRAdCampaignPUB', 55, 'pradc_Notes', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRAdCampaignPUB', 57, 'pradc_Terms', 0, 1, 1, 0


EXEC usp_AccpacGetBlockInfo 'PRAdCampaignNewEntry'
Go


EXEC usp_AccpacCreateSelectField 'PRWebUser', 'prwu_CompanyUpdateMessageType', 'Company Update Message Type', 'prwu_CompanyUpdateMessageType'
Go




EXEC usp_AccpacCreateCheckboxField	 'PRTESRequest', 'prtesr_SecondRequest', 'Second Request'

EXEC usp_AccpacCreateField @EntityName = 'PRTESRequest', 
                            @FieldName = '_ConnectionListOnly', 
                            @Caption = 'Connection List Only',
                            @AccpacEntryType = 45,
                            @AccpacEntrySize = 0,
                            @DBFieldType = 'nchar',
                            @DBFieldSize = 1,
                            @AllowNull = 'Y',
                            @IsRequired = 'N', 
                            @AllowEdit = 'Y', 
                            @IsUnique = 'N',
  			                @SkipColumnCreation = 'Y'  


EXEC usp_AccpacCreateSelectField 'PRTESRequest', 
                                 '_RequestAge', 
                                 'TES Sent in the Past N Days',
                                 'prte_CustomTESRequestAge',
                                 'Y',
                                 'N', 
                                 'Y', 
                                 'N',
  			                     'Y'  
EXEC usp_AccpacGetBlockInfo 'CustomTESOption6FilterBox'

EXEC usp_DeleteCustom_ScreenObject 'CustomTESOption6FilterBox'
EXEC usp_AddCustom_ScreenObjects 'CustomTESOption6FilterBox', 'SearchScreen', 'PRTESRequest', 'N', 0, 'PRTESRequest'
EXEC usp_AddCustom_Screens 'CustomTESOption6FilterBox', 10, '_RequestAge', 1, 1, 1
EXEC usp_AddCustom_Screens 'CustomTESOption6FilterBox', 20, 'comp_PRListingStatus', 0, 1, 1
EXEC usp_AddCustom_Screens 'CustomTESOption6FilterBox', 30, 'prcr_Type', 1, 1, 1
EXEC usp_AddCustom_Screens 'CustomTESOption6FilterBox', 40, '_ConnectionListOnly', 0, 1, 1
Go



EXEC usp_DeleteCustom_Screen 'PersonSearchBox', 'pers_lastname'
EXEC usp_DeleteCustom_Screen 'PersonSearchBox', 'pers_firstname'


EXEC usp_AccpacCreateTextField 'Person', 'pers_LastNameAlphaOnly', 'Last Name', 30, 40
EXEC usp_AccpacCreateTextField 'Person', 'pers_FirstNameAlphaOnly', 'First Name', 30, 30

EXEC usp_AddCustom_Screens 'PersonSearchBox', 20, 'pers_LastNameAlphaOnly',  1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PersonSearchBox', 40, 'pers_FirstNameAlphaOnly', 0, 1, 1, 0


 UPDATE Custom_ScreenObjects
    SET cobj_CustomContent = '<script type="text/javascript" src="/CRM/CustomPages/PRCoGeneral.js"></script><script type="text/javascript" src="/CRM/CustomPages/PRPerson/PersonSearch.js"></script><script type="text/javascript"> document.body.onload=function(){ initializeSearch();  LoadComplete("");} </script>'
  WHERE cobj_Name = 'PersonSearchBox'	
