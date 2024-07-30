EXEC usp_AccpacDropField 'PRWebUser', 'prwu_PRServiceID'
EXEC usp_AccpacDropField 'PRWebUser', 'prwu_PreviousServiceID'
EXEC usp_AccpacDropField 'PRAdCampaign', 'pradc_ServiceID'
EXEC usp_AccpacDropField 'PRServiceUnitAllocation', 'prun_ServiceID'
EXEC usp_AccpacDropField 'PRAttentionLine', 'prattn_ServiceID'

ALTER TABLE PRAdCampaignMirror DROP COLUMN pradc_ServiceID
Go

EXEC usp_AccpacCreateUserSelectField 'PRFinancial', 'prfs_AssignedToUser', 'Assigned To'

--EXEC usp_AccpacGetBlockInfo 'PRFinancialHeader'
EXEC usp_AddCustom_Screens 'PRFinancialHeader', 10, 'prfs_CompanyId',           1, 1, 1, 'N', NULL, NULL, NULL, 'ReadOnly = true;'
EXEC usp_AddCustom_Screens 'PRFinancialHeader', 20, 'prfs_StatementDate',       0, 1, 1, 'N', NULL, NULL, NULL, NULL
EXEC usp_AddCustom_Screens 'PRFinancialHeader', 30, 'prfs_Currency',            0, 1, 1, 'N', NULL, NULL, NULL, NULL
EXEC usp_AddCustom_Screens 'PRFinancialHeader', 40, 'prfs_Type',                0, 1, 1, 'N', NULL, NULL, NULL, NULL
EXEC usp_AddCustom_Screens 'PRFinancialHeader', 50, 'prfs_Analysis',            1, 2, 2, 'N', NULL, NULL, NULL, NULL
EXEC usp_AddCustom_Screens 'PRFinancialHeader', 60, 'prfs_EntryStatus',         0, 1, 1, 'N', NULL, NULL, NULL, NULL
EXEC usp_AddCustom_Screens 'PRFinancialHeader', 70, 'prfs_InterimMonth',        0, 1, 1, 'N', NULL, NULL, NULL, NULL
EXEC usp_AddCustom_Screens 'PRFinancialHeader', 80, 'prfs_Publish',             1, 1, 1, 'N', NULL, NULL, NULL, NULL
EXEC usp_AddCustom_Screens 'PRFinancialHeader', 90, 'prfs_PreparationMethod',   1, 1, 1, 'N', NULL, NULL, NULL, NULL
EXEC usp_AddCustom_Screens 'PRFinancialHeader', 100, 'prfs_AssignedToUser',     0, 1, 1, 'N', NULL, NULL, NULL, NULL
EXEC usp_AddCustom_Screens 'PRFinancialHeader', 110, 'prfs_CreatedDate',        0, 1, 1, 'N', NULL, NULL, NULL, NULL
EXEC usp_AddCustom_Screens 'PRFinancialHeader', 120, 'prfs_UpdatedDate',        0, 1, 1, 'N', NULL, NULL, NULL, NULL
EXEC usp_AddCustom_Screens 'PRFinancialHeader', 130, 'prfs_Reviewed',           1, 1, 1, 'N', NULL, NULL, NULL, NULL
EXEC usp_AddCustom_Screens 'PRFinancialHeader', 140, 'prfs_ReviewDate',         0, 1, 1, 'N', NULL, NULL, NULL, 'ReadOnly = true;'
EXEC usp_AddCustom_Screens 'PRFinancialHeader', 150, 'prfs_ReviewedBy',         0, 1, 1, 'N', NULL, NULL, NULL, 'ReadOnly = true;'
EXEC usp_AddCustom_Screens 'PRFinancialHeader', 160, 'prfs_StatementImageFile', 1, 1, 4, 'N', NULL, NULL, NULL, NULL
Go




EXEC usp_AccpacCreateSelectField 'PRPublicationArticle', 'prpbar_AccessLevel', 'Access Level (=>)', 'prwu_AccessLevel'
EXEC usp_AccpacCreateSelectField 'PRPublicationArticle', 'prpbar_Size', 'Size', 'prpbar_Size'

EXEC usp_AccpacCreateIntegerField 'PRWebUser', 'prwu_LastBBOSPopupID', 'Last BBOS Popup Article'
EXEC usp_AccpacCreateDateField    'PRWebUser', 'prwu_LastBBOSPopupViewDate', 'Last BBOS Popup Article Viewed Date'

EXEC usp_DeleteCustom_ScreenObject 'PRBBOSPopupGrid'
EXEC usp_AddCustom_ScreenObjects 'PRBBOSPopupGrid', 'List', 'PRPublicationArticle', 'N', 0, 'PRPublicationArticle'
EXEC usp_AddCustom_Lists 'PRBBOSPopupGrid', 10, 'prpbar_PublishDate', null, 'Y'
EXEC usp_AddCustom_Lists 'PRBBOSPopupGrid', 20, 'prpbar_Name', null, 'Y', 'Y', '', 'Custom', '', '', 'PRPublication/PRBBOSPopup.asp', 'prpbar_PublicationArticleID'
EXEC usp_AddCustom_Lists 'PRBBOSPopupGrid', 30, 'prpbar_IndustryTypeCode', null, 'Y'
EXEC usp_AddCustom_Lists 'PRBBOSPopupGrid', 40, 'prpbar_AccessLevel', null, 'Y'
EXEC usp_AddCustom_Lists 'PRBBOSPopupGrid', 50, 'prpbar_Size', null, 'Y'

UPDATE custom_lists SET grip_DefaultOrderBy = 'Y', GriP_OrderByDesc='Y' WHERE grip_GridName = 'PRBBOSPopuupGrid' AND grip_ColName='prpbar_PublishDate';
EXEC usp_AddCustom_Tabs 16, 'find', 'BBOS Pop-Ups', 'customfile', 'PRPublication/PRBBOSPopupListing.asp'   


EXEC usp_DeleteCustom_ScreenObject 'PRBBOSPopup'
EXEC usp_AddCustom_ScreenObjects 'PRBBOSPopup', 'Screen', 'PRPublicationArticle', 'N', 0, 'PRPublicationArticle'
EXEC usp_AddCustom_Screens 'PRBBOSPopup', 10, 'prpbar_Name',             1, 1, 2, 0
EXEC usp_AddCustom_Screens 'PRBBOSPopup', 20, 'prpbar_PublishDate',      1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRBBOSPopup', 30, 'prpbar_AccessLevel',      0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRBBOSPopup', 40, 'prpbar_ExpirationDate',   1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRBBOSPopup', 50, 'prpbar_IndustryTypeCode', 0, 2, 1, 0
EXEC usp_AddCustom_Screens 'PRBBOSPopup', 60, 'prpbar_Size',             1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRBBOSPopup', 70, 'prpbar_Body',             1, 1, 2, 0
Go


ALTER FULLTEXT INDEX ON PRPublicationArticle DISABLE
DROP FULLTEXT INDEX ON PRPublicationArticle
Go

ALTER TABLE PRPublicationArticle ALTER COLUMN prpbar_Abstract VARCHAR(MAX) null
ALTER TABLE PRPublicationArticle ALTER COLUMN prpbar_Body VARCHAR(MAX) null
Go

UPDATE PRPublicationArticle 
   SET prpbar_Body = prpbar_Body,
       prpbar_Abstract = prpbar_Abstract;
Go

IF NOT EXISTS (SELECT * FROM sysfulltextcatalogs ftc WHERE ftc.name = N'LearningCenter') BEGIN
	CREATE FULLTEXT CATALOG [LearningCenter]
END

IF not EXISTS (SELECT * FROM sys.fulltext_indexes fti WHERE fti.object_id = OBJECT_ID(N'[dbo].[PRPublicationArticle]')) BEGIN
	CREATE FULLTEXT INDEX ON [dbo].[PRPublicationArticle](
	[prpbar_Abstract] LANGUAGE [English], 
	[prpbar_Body] LANGUAGE [English], 
	[prpbar_FileName] LANGUAGE [English], 
	[prpbar_Name] LANGUAGE [English])
	KEY INDEX [PK__PRPublicationArt__1922560A] ON [LearningCenter]
	WITH CHANGE_TRACKING AUTO
END
Go

EXEC usp_AccpacCreateCheckboxField 'Person_Link', 'peli_PRReceiveBRSurvey', 'Receive BR Survey'
EXEC usp_AddCustom_Screens 'PRPersonLinkNewEntry', 320, 'peli_PRReceiveBRSurvey', 1, 1, 1
Go


ALTER TABLE [dbo].[Company] DROP CONSTRAINT DF__Company__comp_PR__5832119F
ALTER TABLE [dbo].[Company] DROP CONSTRAINT DF__Company__comp_PR__592635D8
ALTER TABLE [dbo].[Company] DROP CONSTRAINT DF__Company__comp_PR__5A1A5A11
ALTER TABLE [dbo].[Company] DROP CONSTRAINT DF__Company__comp_PR__5B0E7E4A
ALTER TABLE [dbo].[Company] DROP CONSTRAINT DF__Company__comp_PR__5C02A283
ALTER TABLE [dbo].[Company] DROP CONSTRAINT DF__Company__comp_PR__5CF6C6BC
Go


EXEC usp_AddCustom_Lists 'PRPersonList', 37, 'peli_PREBBPublish', null, 'Y', null, 'center'
Go

EXEC usp_AccpacCreateDropdownValue 'CreditMonitorReportDate', '2012-01-01', 0, ''
Go


EXEC usp_AccpacCreateCheckboxField 'PRAdCampaign', 'pradc_ContentSourceRequest', 'Content Source Request'
EXEC usp_AccpacCreateDateField     'PRAdCampaign', 'pradc_ContentSourceRequestDate', 'Content Source Request Date'
EXEC usp_AccpacCreateTextField     'PRAdCampaign', 'pradc_ContentSourceContactVia', 'Content Source Contact Via', 100, 200

EXEC usp_AccpacCreateCheckboxField 'PRAdCampaignMirror', 'pradc_ContentSourceRequest', 'Content Source Request'
EXEC usp_AccpacCreateDateField     'PRAdCampaignMirror', 'pradc_ContentSourceRequestDate', 'Content Source Request Date'
EXEC usp_AccpacCreateTextField     'PRAdCampaignMirror', 'pradc_ContentSourceContactVia', 'Content Source Contact Via', 100, 200

EXEC usp_AddCustom_Screens 'PRAdCampaignBP', 104, 'pradc_ContentSourceRequest',     1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRAdCampaignBP', 106, 'pradc_ContentSourceRequestDate', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRAdCampaignBP', 108, 'pradc_ContentSourceContactVia',  1, 1, 1, 0
Go


EXEC usp_AccpacCreateSearchSelectField 'PRARAgingDetail', 'praad_SubjectCompanyID', 'Company', 'Company', 100 
Go


EXEC usp_AccpacCreateDateField 'Company', 'comp_PRServiceStartDate', 'Service Start Date'
EXEC usp_AccpacCreateDateField 'Company', 'comp_PRServiceEndDate', 'Service End Date'
Go


/* PRBlueprintEditionListingGrid */
EXEC usp_DeleteCustom_ScreenObject 'PRBlueprintEditionListingGrid'
EXEC usp_AddCustom_ScreenObjects  'PRBlueprintEditionListingGrid', 'List', 'vPRBluePrintEdition', 'N', 0, 'vPRBluePrintEdition'
EXEC usp_AddCustom_Lists 'PRBlueprintEditionListingGrid', 10, 'prpbed_Name', '', '', '', '', 'Custom', '', '', 'PRPublication/PRPublicationEdition.asp', 'prpbed_PublicationEditionID'
EXEC usp_AddCustom_Lists 'PRBlueprintEditionListingGrid', 20, 'prpbed_PublishDate', '', 'Y', 'Y', 'CENTER'
EXEC usp_DefineCaptions 'vPRBluePrintEdition', 'Blueprint Edition', 'Blueprint Editions', 'prpbed_Name', 'prpbed_PublicationEditionID', NULL, NULL
EXEC usp_DefineCaptions 'vPRBluePrintEditionArticle', 'Blueprint Article', 'Blueprint Articles', 'prpbar_Name', 'prpbar_PublicationArticleID', NULL, NULL
Go
UPDATE custom_lists SET grip_DefaultOrderBy = 'Y' WHERE grip_GridName = 'PRBlueprintEditionListingGrid' AND grip_ColName='prpbed_PublishDate';


EXEC usp_AddCustom_Tabs '16', 'Find', 'Blueprints', 'customfile', 'PRPublication/BluePrintsEditionListing.asp'

EXEC usp_DeleteCustom_Screen 'PRPublicationArticleEntry', 'prpbar_ProductID'
EXEC usp_DeleteCustom_Screen 'PRPublicationArticleEntry', 'prpbar_NoChargeExpiration'
EXEC usp_DeleteCustom_Screen 'PRPublicationArticleEntry', 'prpbar_PricingListID'

EXEC usp_DeleteCustom_Screen 'PRPublicationArticleSearchBox', 'prpbed_PublishDate'
EXEC usp_DeleteCustom_Screen 'PRPublicationArticleSearchBox', 'prpbed_Name'

EXEC usp_DeleteCustom_List 'PRPublicationArticleListingGrid', 'prpbed_PublishDate'
EXEC usp_DeleteCustom_List 'PRPublicationArticleListingGrid', 'prpbed_Name'

EXEC usp_AddCustom_Screens 'PRPublicationArticleEntry',  10, 'prpbar_PublicationEditionID', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRPublicationArticleEntry',  20, 'prpbar_PublicationCode', 1, 1, 1, 0

DELETE FROM Custom_ScreenObjects WHERE cobj_Name = 'PRPublicationEditionListingGrid'
EXEC usp_AddCustom_ScreenObjects  'PRPublicationEditionListingGrid', 'List', 'vPRBluePrintEditionArticle', 'N', 0, 'vPRBluePrintEditionArticle'
EXEC usp_AddCustom_Lists 'PRPublicationEditionListingGrid', 30, 'prpbar_PublicationCode'

DELETE FROM Custom_ScreenObjects WHERE cobj_Name = 'PRPublicationArticleListingGrid'
EXEC usp_AddCustom_ScreenObjects  'PRPublicationArticleListingGrid', 'List', 'vPRPublicationArticle', 'N', 0, 'vPRPublicationArticle'

--SELECT TOP 10 * FROM Custom_ScreenObjects WHERE cobj_Name = 'PRPublicationArticleListingGrid'

Go



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetConsumedUnitsForService]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    drop function [dbo].[ufn_GetConsumedUnitsForService]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_IsOnlineAllocationReconciliationValid]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    drop function [dbo].[ufn_IsOnlineAllocationReconciliationValid]
GO

If Exists (Select name from sysobjects where name = 'ufn_CurrentAllocationId' and type in (N'FN', N'IF', N'TF')) 
	Drop Function dbo.ufn_CurrentAllocationId
Go

