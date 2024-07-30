--8.16 Release

--Defect 7161
EXEC usp_TravantCRM_CreateNumericField	'PRBBScore', 'prbs_OldBBScore', 'Old Model Score', 10

/* MOVED statements below to DropdownValues.sql
IF NOT EXISTS(SELECT 'x' FROM custom_captions where capt_family='BBSUseBothModelsForLineChart')
BEGIN
	EXEC usp_TravantCRM_CreateDropdownValue 'BBSUseBothModelsForLineChart', 'BBSUseBothModelsForLineChart', 0, 'false'
END

IF NOT EXISTS(SELECT 'x' FROM custom_captions where capt_family='BBSSuppressAUSandReport')
BEGIN
	EXEC usp_TravantCRM_CreateDropdownValue 'BBSSuppressAUSandReport', 'BBSSuppressAUSandReport', 0, 'false'
END
*/

/*
Remove Madison Lumber
Super high priority - must be done and in production by 9/30/23:
•	Remove Madison’s Directory Data page, logo (company detail home page), company page header, etc. from BBOS (example 290651)   CompanyDetailsMadison.aspx
•	Permanently delete/remove any data housed in “Madison’s data field” in our database.  (not sure where this is?) On PRCompanySummary.asp I see a flag "Has madison's data" 
*/

IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'PRMadisonLumber'))
BEGIN
    EXEC usp_TravantCRM_DropTable 'PRMadisonLumber'
END
IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'PRMadisonLumberContact'))
BEGIN
    EXEC usp_TravantCRM_DropTable 'PRMadisonLumberContact'
END
IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'PRMadisonLumberPhone'))
BEGIN
    EXEC usp_TravantCRM_DropTable 'PRMadisonLumberPhone'
END
IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'PRMadisonLumberAddress'))
BEGIN
    EXEC usp_TravantCRM_DropTable 'PRMadisonLumberAddress'
END
IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'PRMadisonLumberInternet'))
BEGIN
    EXEC usp_TravantCRM_DropTable 'PRMadisonLumberInternet'
END
IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'PRMadisonLumberData'))
BEGIN
    EXEC usp_TravantCRM_DropTable 'PRMadisonLumberData'
END


--Defect 7160 - edit PRSalesOrderAuditTrail data for DSIR report
EXEC usp_TravantCRM_DeleteCustom_ScreenObject 'PRSalesOrderAuditTrailSearchBox'
EXEC usp_TravantCRM_AddCustom_ScreenObjects 'PRSalesOrderAuditTrailSearchBox', 'SearchScreen', 'PRSalesOrderAuditTrail', 'N', 0, 'vPRSalesOrderAuditTrailListing'
EXEC usp_TravantCRM_AddCustom_Screens 'PRSalesOrderAuditTrailSearchBox', 10, 'prsoat_CreatedDate', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRSalesOrderAuditTrailSearchBox', 20, 'prsoat_SoldBy', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRSalesOrderAuditTrailSearchBox', 30, 'comp_CompanyId', 1, 1, 1, 0

EXEC usp_TravantCRM_DeleteCustom_ScreenObject 'PRSalesOrderAuditTrailGrid'
EXEC usp_TravantCRM_AddCustom_ScreenObjects 'PRSalesOrderAuditTrailGrid', 'List', 'PRSalesOrderAuditTrail', 'N', 0, 'vPRSalesOrderAuditTrailListing'
EXEC usp_TravantCRM_AddCustom_Lists 'PRSalesOrderAuditTrailGrid', 5, 'comp_companyid', null, 'Y'
EXEC usp_TravantCRM_AddCustom_Lists 'PRSalesOrderAuditTrailGrid', 10, 'prsoat_CreatedDate', null, 'Y'
EXEC usp_TravantCRM_AddCustom_Lists 'PRSalesOrderAuditTrailGrid', 20, 'prsoat_ItemCode', null, 'Y', 'Y', '', 'Custom', '', '', 'PRSalesOrderAuditTrail/PRSalesOrderAuditTrail.asp', 'prsoat_SalesOrderAuditTrailID'
EXEC usp_TravantCRM_AddCustom_Lists 'PRSalesOrderAuditTrailGrid', 30, 'prsoat_Pipeline', null, 'Y'
EXEC usp_TravantCRM_AddCustom_Lists 'PRSalesOrderAuditTrailGrid', 40, 'prsoat_Up_Down', null, 'Y'
EXEC usp_TravantCRM_AddCustom_Lists 'PRSalesOrderAuditTrailGrid', 50, 'prsoat_ActionCode', null, 'Y'
EXEC usp_TravantCRM_AddCustom_Lists 'PRSalesOrderAuditTrailGrid', 60, 'prsoat_CancelReasonCode', null, 'Y'
EXEC usp_TravantCRM_AddCustom_Lists 'PRSalesOrderAuditTrailGrid', 80, 'prsoat_SoldBy', null, 'Y'
EXEC usp_TravantCRM_AddCustom_Lists 'PRSalesOrderAuditTrailGrid', 100, 'prsoat_ExtensionAmt', null, 'Y'
EXEC usp_TravantCRM_AddCustom_Lists 'PRSalesOrderAuditTrailGrid', 120, 'prsoat_QuantityChange', null, 'Y'

EXEC usp_TravantCRM_DeleteCustom_ScreenObject 'PRSalesOrderAuditTrailNewEntry'
EXEC usp_TravantCRM_AddCustom_ScreenObjects 'PRSalesOrderAuditTrailNewEntry', 'Screen', 'PRSalesOrderAuditTrail', 'N', 0, 'PRSalesOrderAuditTrail'
EXEC usp_TravantCRM_AddCustom_Screens 'PRSalesOrderAuditTrailNewEntry', 10, 'prsoat_CreatedDate', 1, 1, 1, 1
EXEC usp_TravantCRM_AddCustom_Screens 'PRSalesOrderAuditTrailNewEntry', 20, 'prsoat_ItemCode', 0, 1, 1, 1
EXEC usp_TravantCRM_AddCustom_Screens 'PRSalesOrderAuditTrailNewEntry', 30, 'prsoat_Pipeline', 1, 1, 1, 1
EXEC usp_TravantCRM_AddCustom_Screens 'PRSalesOrderAuditTrailNewEntry', 40, 'prsoat_Up_Down', 0, 1, 1, 1
EXEC usp_TravantCRM_AddCustom_Screens 'PRSalesOrderAuditTrailNewEntry', 50, 'prsoat_ActionCode', 1, 1, 1, 1
EXEC usp_TravantCRM_AddCustom_Screens 'PRSalesOrderAuditTrailNewEntry', 60, 'prsoat_CancelReasonCode', 0, 1, 1, 1
EXEC usp_TravantCRM_AddCustom_Screens 'PRSalesOrderAuditTrailNewEntry', 80, 'prsoat_SoldBy', 0, 1, 1, 1
EXEC usp_TravantCRM_AddCustom_Screens 'PRSalesOrderAuditTrailNewEntry', 90, 'prsoat_ExtensionAmt', 1, 1, 1, 1
EXEC usp_TravantCRM_AddCustom_Screens 'PRSalesOrderAuditTrailNewEntry', 110, 'prsoat_QuantityChange', 0, 1, 1, 1

EXEC usp_TravantCRM_AddCustom_Tabs 170, 'find', 'DSIR Edits', 'customfile', 'PRSalesOrderAuditTrail/PRSalesOrderAuditTrailListing.asp', null, 'CRMQuote.gif'

--Remove Madison Lumber items
IF OBJECT_ID('dbo.usp_DeleteMadisonLumberData', 'P') IS NOT NULL
	DROP PROC dbo.usp_DeleteMadisonLumberData

EXEC usp_TravantCRM_DropTable 'PRMadisonLumber'
EXEC usp_TravantCRM_DropTable 'PRMadisonLumberContact'
EXEC usp_TravantCRM_DropTable 'PRMadisonLumberPhone'
EXEC usp_TravantCRM_DropTable 'PRMadisonLumberAddress'
EXEC usp_TravantCRM_DropTable 'PRMadisonLumberInternet'
EXEC usp_TravantCRM_DropTable 'PRMadisonLumberData'
