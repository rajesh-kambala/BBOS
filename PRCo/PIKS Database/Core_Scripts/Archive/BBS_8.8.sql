--8.8 Release
USE CRM

--Defect 5749
EXEC usp_TravantCRM_AddCustom_Screens 'PRBusinessEvent_Core', 30, 'prbe_UpdatedBy', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRBusinessEvent_Core', 40, 'prbe_UpdatedDate', 0, 1, 1, 0

--Defect 4290 - link company id to company rec on PersonAdvancedSearchGrid
EXEC usp_TravantCRM_AddCustom_Lists 'PersonAdvancedSearchGrid', 200, 'comp_companyid', null, 'Y', null, null, 'company'

--Defect 5759 - Salvages distressed produce --> Handles rejected shipments
EXEC usp_TravantCRM_CreateCheckboxField 'PRCompanyProfile', 'prcp_SalvageDistressedProduce', 'Handles rejected shipments'

--Defect 6836 CRM: Changes to Email Ads used on Alert Emails
--6.1.2 PREmailImages table [MODIFIED]
EXEC usp_TravantCRM_CreateSelectField		'PREmailImages', 'prei_Industry', 'Industry', 'prei_Industry'
EXEC usp_TravantCRM_CreateTextField         'PREmailImages', 'prei_Hyperlink', 'Email Image Hyperlink', 200, 200, @AllowNull_In='Y'

--PREmailImage
EXEC usp_TravantCRM_DeleteCustom_ScreenObject 'PREmailImage'
EXEC usp_TravantCRM_AddCustom_ScreenObjects 'PREmailImage', 'Screen', 'PREmailImages', 'N', 0, 'PREmailImages'
EXEC usp_TravantCRM_AddCustom_Screens 'PREmailImage', 10, 'prei_StartDate', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PREmailImage', 20, 'prei_EndDate', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PREmailImage', 30, 'prei_EmailTypeCode', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PREmailImage', 40, 'prei_EmailImgFileName', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PREmailImage', 50, 'prei_LocationCode', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PREmailImage', 60, 'prei_Industry', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PREmailImage', 70, 'prei_Hyperlink', 1, 1, 1, 0

--EmailImageGrid
EXEC usp_TravantCRM_DeleteCustom_ScreenObject 'EmailImageGrid'
EXEC usp_TravantCRM_AddCustom_ScreenObjects 'EmailImageGrid', 'List', 'PREmailImages', 'N', 0, 'PREmailImages'
EXEC usp_TravantCRM_AddCustom_Lists 'EmailImageGrid', 10, 'prei_StartDate', null, 'Y', @Jump='customdotnetdll', @CustomAction='TravantCRM.dll', @CustomFunction='RunEmailImage', @CustomIdField='prei_EmailImageID'
EXEC usp_TravantCRM_AddCustom_Lists 'EmailImageGrid', 20, 'prei_EndDate', null, 'Y', 'Y'
EXEC usp_TravantCRM_AddCustom_Lists 'EmailImageGrid', 30, 'prei_EmailTypeCode', null, 'Y'
EXEC usp_TravantCRM_AddCustom_Lists 'EmailImageGrid', 40, 'prei_EmailImgFileName', null, 'Y'
EXEC usp_TravantCRM_AddCustom_Lists 'EmailImageGrid', 50, 'prei_LocationCode', null, 'Y'
EXEC usp_TravantCRM_AddCustom_Lists 'EmailImageGrid', 60, 'prei_Industry', null, 'Y'
EXEC usp_TravantCRM_AddCustom_Lists 'EmailImageGrid', 70, 'prei_Hyperlink', null, 'Y'

UPDATE custom_lists SET grip_DefaultOrderBy = 'Y', GriP_OrderByDesc='Y' WHERE grip_GridName = 'EmailImageGrid' AND grip_ColName='prei_StartDate';

--For the last bbscore run date lumber, default that to the Max PRBBScore.prbs_RuntDate for lumber companies.
DECLARE @MaxLumberRunDate datetime
SELECT @MaxLumberRunDate = MAX(prbs_RunDate) FROM PRBBScore
	INNER JOIN Company on Comp_CompanyId = prbs_CompanyId
WHERE comp_PRIndustryType = 'L'
DECLARE @DateStr varchar(50) = FORMAT(@MaxLumberRunDate, 'MMM  d yyyy h:mmtt') --ex: 6/6/2020

--DELETE FROM Custom_Captions WHERE capt_family='LastBBScoreRunDate_Lumber'
IF NOT EXISTS(SELECT * FROM Custom_Captions WHERE capt_family='LastBBScoreRunDate_Lumber') BEGIN
	EXEC dbo.usp_TravantCRM_AddCustom_Captions 'Choices', 'LastBBScoreRunDate_Lumber', 'LastBBScoreRunDate_Lumber', 1, @DateStr
END

--Then for the last report date, set that to the computed bbscore run date + 1 day.
SET @DateStr = FORMAT(DATEADD(d, 1, @MaxLumberRunDate), 'MMM  d yyyy h:mmtt') --ex: Jun 6 2020 12:00AM

--DELETE FROM Custom_Captions WHERE capt_family='LastBBScoreReportDate_Lumber'
IF NOT EXISTS(SELECT * FROM Custom_Captions WHERE capt_family='LastBBScoreReportDate_Lumber') BEGIN
	EXEC dbo.usp_TravantCRM_AddCustom_Captions 'Choices', 'LastBBScoreReportDate_Lumber', @DateStr, 0, 'LastBBScoreReportDate_Lumber'
END

-- Defect #6822
UPDATE Custom_Tabs SET tabs_action = 'customdotnetdll', Tabs_CustomFileName='TravantCRM', Tabs_CustomFunction='RunCompanyInteractionListing' WHERE Tabs_TabId=34
UPDATE Custom_Tabs SET tabs_action = 'customdotnetdll', Tabs_CustomFileName='TravantCRM', Tabs_CustomFunction='RunPersonInteractionListing' WHERE Tabs_TabId=17