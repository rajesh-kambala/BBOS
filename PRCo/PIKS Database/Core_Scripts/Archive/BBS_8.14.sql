--8.14 Release
USE CRM

--Defect 7041
--AdCampaignAdBP
EXEC usp_TravantCRM_DeleteCustom_ScreenObject 'AdCampaignAdBP'
EXEC usp_TravantCRM_AddCustom_ScreenObjects 'AdCampaignAdBP', 'Screen', 'PRAdCampaign', 'N', 0, 'PRAdCampaign'
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdBP', 1, 'pradc_CompanyID', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdBP', 3, 'pradc_AdCampaignHeaderID', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdBP', 5, 'pradc_AdCampaignType', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdBP', 10, 'pradc_Name', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdBP', 20, 'pradc_BluePrintsEdition', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdBP', 30, 'pradc_CreativeStatus', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdBP', 40, 'pradc_Section', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdBP', 50, 'pradc_PlannedSection', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdBP', 60, 'pradc_AdSize', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdBP', 70, 'pradc_Orientation', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdBP', 80, 'pradc_AdColor', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdBP', 90, 'pradc_SectionDetailsCode', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdBP', 100, 'pradc_SectionDetails', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdBP', 110, 'pradc_PlacementInstructions', 0, 1, 3, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdBP', 120, 'pradc_Placement', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdBP', 130, 'pradc_Premium', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdBP', 140, 'pradc_Notes', 0, 1, 3, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdBP', 150, 'pradc_ContentSourceRequest', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdBP', 160, 'pradc_ContentSourceRequestDate', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdBP', 170, 'pradc_ContentSourceContactName', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdBP', 180, 'pradc_ContentSourceContactInfo', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdBP', 190, 'pradc_Cost', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdBP', 200, 'pradc_Discount', 0, 1, 1, 0

--Defect 7024 - AM/PM on digital ads
--add new pradc_AdCampaignTypeDigital
EXEC usp_TravantCRM_CreateCheckboxField 'PRAdCampaign', 'pradc_AdCampaignTypeDigitalAMEdition', 'AM Edition'
EXEC usp_TravantCRM_CreateCheckboxField 'PRAdCampaign', 'pradc_AdCampaignTypeDigitalPMEdition', 'PM Edition'

EXEC usp_TravantCRM_DeleteCustom_ScreenObject 'AdCampaignAdDigital'
EXEC usp_TravantCRM_AddCustom_ScreenObjects 'AdCampaignAdDigital', 'Screen', 'PRAdCampaign', 'N', 0, 'PRAdCampaign'
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdDigital', 1, 'pradc_CompanyID', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdDigital', 3, 'pradc_AdCampaignHeaderID', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdDigital', 5, 'pradc_AdCampaignType', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdDigital', 10, 'pradc_Name', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdDigital', 20, 'pradc_StartDate', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdDigital', 30, 'pradc_AdCampaignTypeDigital', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdDigital', 40, 'pradc_EndDate', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdDigital', 50, 'pradc_CreativeStatus', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdDigital', 60, 'pradc_AdCampaignTypeDigitalAMEdition', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdDigital', 70, 'pradc_TargetURL', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdDigital', 80, 'pradc_AdCampaignTypeDigitalPMEdition', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdDigital', 90, 'pradc_Sequence', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdDigital', 100, 'pradc_Cost', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdDigital', 110, 'pradc_Discount', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdDigital', 120, 'pradc_IndustryType', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdDigital', 130, 'pradc_Language', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdDigital', 140, 'pradc_Notes', 0, 1, 1, 0

--Defect 5734
--Remove New Person from + menu
UPDATE Custom_Tabs SET Tabs_WhereSQL='1=2', Tabs_UpdatedDate=GETDATE(), Tabs_UpdatedBy=-1 WHERE tabs_entity='new' AND tabs_Caption='Person' AND tabs_action='newperson'

--Defect 7051
EXEC usp_TravantCRM_AddCustom_Lists 'CompanyGrid', 15, 'prse_ServiceCode', null, 'Y', null, 'CENTER'

DECLARE @ColName varchar(50)='Primary Service' --was previously Code
UPDATE custom_captions SET capt_us=@ColName,capt_UK=@ColName,capt_FR=@ColName,capt_DE=@ColName,capt_ES=@ColName,Capt_UpdatedDate=GETDATE(), Capt_UpdatedBy=-1 WHERE capt_code = 'prse_ServiceCode' AND capt_family = 'ColNames';

EXEC usp_TravantCRM_AddCustom_Screens 'CompanySearchBox', 17, 'prse_ServiceCode', 0, 1, 1

-- Unique Click Count added to vPRAdCampaignSummary
EXEC usp_TravantCRM_AddCustom_Screens 'PRAdCampaignSummary', 25, 'UniqueClickCount', 0, 1, 1, 0

--Defect 7077 - PRLocalSourceMatchExclusion
--DROP TABLE dbo.PRLocalSourceMatchExclusion
IF OBJECT_ID('dbo.PRLocalSourceMatchExclusion', 'U') IS NULL 
BEGIN
	EXEC usp_TravantCRM_DropTable 'PRLocalSourceMatchExclusion'
	EXEC usp_TravantCRM_CreateTable @EntityName='PRLocalSourceMatchExclusion', @ColPrefix='prlse', @IDField='prlse_LocalSourceMatchExclusionID', @UseIdentityForKey='Y'
	EXEC usp_TravantCRM_CreateKeyField          'PRLocalSourceMatchExclusion', 'prlse_LocalSourceMatchExclusionID', 'Local Source Match Exclusion ID'
	EXEC usp_TravantCRM_CreateTextField			'PRLocalSourceMatchExclusion', 'prlse_Key', 'Key', 100, 100, @AllowNull_In='N'
	EXEC usp_TravantCRM_CreateIntegerField      'PRLocalSourceMatchExclusion', 'prlse_CompanyID', 'CompanyID', @AllowNull_In='N'
END
Go

EXEC usp_TravantCRM_CreateCheckboxField 'PRTradeReport', 'prtr_ExcludeFromAnalysis', 'Exclude from Analysis'
Go

EXEC usp_TravantCRM_DropTable 'PRTESRequestExclusion'
EXEC usp_TravantCRM_CreateTable 'PRTESRequestExclusion', 'prtesre', 'prtesre_TESRequestExclusionID', Default, Default, Default, Default, 'Y'
EXEC usp_TravantCRM_CreateIntegerField 'PRTESRequestExclusion', 'prtesre_CompanyID', 'Responder Company Id', 10, 'N'
EXEC usp_TravantCRM_CreateIntegerField 'PRTESRequestExclusion', 'prtesre_SubjectCompanyID', 'Subject Company Id', 10, 'N'
Go

EXEC usp_TravantCRM_AddCustom_Lists 'PRTradeReportOnGrid', 116, 'prtr_ExcludeFromAnalysis', null, 'Y', null, 'CENTER'
Go

--Defect 7059 = classification sequence (like prcca_Sequence)
IF COL_LENGTH('dbo.PRCompanyClassification', 'prc2_Sequence') IS NOT NULL
BEGIN
	DECLARE @Exists int
END
ELSE
BEGIN
	DECLARE @NotExists int
	EXEC usp_TravantCRM_CreateIntegerField  'PRCompanyClassification', 'prc2_Sequence', 'Sequence', 10
END

EXEC usp_TravantCRM_AddCustom_Lists 'PRCompanyClassificationGrid', 10, 'prc2_Sequence', null, 'Y'
EXEC usp_TravantCRM_AddCustom_Screens 'PRCompClassProps_All', 10, 'prc2_Sequence', 1, 1, 1, 0
Go

--ILLINOIS TAX RATE FIX
IF NOT EXISTS(SELECT 'x' FROM PRTaxRate WHERE prtax_TaxCode='TAX-IL' AND prtax_City='CAROL STREAM')
BEGIN
	INSERT INTO PRTaxRate (prtax_CreatedBy, prtax_UpdatedBy, prtax_PostalCode, prtax_County, prtax_City, prtax_State, prtax_TaxCode, prtax_TaxRate)
	VALUES (-1, -1, 60188, 'DUPAGE', 'CAROL STREAM', 'IL', 'TAX-IL', 8.00)
END

--BBOS Marketing Site Ad Refactoring
IF COL_LENGTH('dbo.PRAdCampaignFile', 'pracf_FileName_Disk') IS NULL
BEGIN
	EXEC usp_TravantCRM_CreateTextField  'PRAdCampaignFile', 'pracf_FileName_Disk', 'File Name Disk', 50, 500
END
GO

--Defect 7131 - KYCAD3
DECLARE @KYC TABLE
(
	ID int,
	post_title varchar(500),
	AD3Exists bit
)
INSERT INTO @KYC
SELECT ID, post_title, NULL FROM WordPressProduce.dbo.wp_posts WITH(NOLOCK)
WHERE
	post_name IN('Avocados', 
					'Cantaloupe', 
					'Chile-Peppers', 
					'Cucumbers',  
					'Dragon-Fruit',
					'Grapefruit', 
					'Grapes', 
					'Kiwifruit', 
					'Lemons', 
					'Limes', 
					'Mangos',
					'mandarins-tangerines-clementines',
					'Onions', 
					'Oranges', 
					'Peppers', 
					'Squash', 
					'Tomatillos',
					'Tomatoes', 
					'Tomatoes-greenhouse'
				)
	AND post_status='Publish'
	AND post_type='KYC'
ORDER BY post_name

UPDATE @KYC SET Ad3Exists=1 WHERE ID IN (SELECT post_id FROM WordPressProduce.dbo.wp_postmeta WHERE meta_key='KYCAD3')

INSERT INTO WordPressProduce.dbo.wp_postmeta (post_id, meta_key, meta_value)
SELECT wpp.ID, 'KYCAD3', '<script type="text/javascript">var ad1 = new BBSiGetKYCDAdsWidget("kycd3", null, ' + CAST(wpp.ID AS varchar(50)) + ', "KYCPage3");</script>'
FROM @KYC
	INNER JOIN WordPressProduce.dbo.wp_posts wpp WITH(NOLOCK) ON wpp.ID = [@KYC].ID
WHERE
	[@KYC].AD3Exists IS NULL
	AND wpp.post_status='Publish'
GO

EXEC usp_TravantCRM_CreateTextField 'PRSalesOrderAuditTrail', 'prsoat_SoldBy', 'SoldBy', 5, 5, 'Y'
Go

-- PACA Copmplaint Analysis (2/2/2023)
--DROP TABLE dbo.PRPACAComplaintDetail
IF OBJECT_ID('dbo.PRPACAComplaintDetail', 'U') IS NULL 
BEGIN
	EXEC usp_TravantCRM_DropTable 'PRPACAComplaintDetail'
	EXEC usp_TravantCRM_CreateTable @EntityName='PRPACAComplaintDetail', @ColPrefix='prpacd', @IDField='prpacd_PRPACAComplaintDetailID', @UseIdentityForKey='Y'
	EXEC usp_TravantCRM_CreateKeyField          'PRPACAComplaintDetail', 'prpacd_PRPACAComplaintDetailID', 'PACA Complaint Detail ID'
	EXEC usp_TravantCRM_CreateIntegerField      'PRPACAComplaintDetail', 'prpacd_PACALicenseID', 'PACALicenseID', @AllowNull_In='Y'
	EXEC usp_TravantCRM_CreateTextField			'PRPACAComplaintDetail', 'prpacd_LicenseNumber', 'LicenseNumber', 8, 8, 'Y'
	EXEC usp_TravantCRM_CreateDateField			'PRPACAComplaintDetail', 'prpacd_ChangeDate', 'Change Date'
	EXEC usp_TravantCRM_CreateIntegerField      'PRPACAComplaintDetail', 'prpacd_InfRepComplaintCount', 'InfRepComplaingCount', @AllowNull_In='Y'
	EXEC usp_TravantCRM_CreateIntegerField      'PRPACAComplaintDetail', 'prpacd_ForRepComplaintCount ', 'ForRepComplaintCount', @AllowNull_In='Y'
END
Go