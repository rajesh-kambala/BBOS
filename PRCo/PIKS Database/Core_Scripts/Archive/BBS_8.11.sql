--8.11 Release
USE CRM

--Increase TriggerPage field from 255 to 500 chars to prevent runtime errors on long referral urls
ALTER TABLE PRExternalLinkAuditTrail ALTER COLUMN prelat_TriggerPage nvarchar(500) NULL
ALTER TABLE CRMArchive.dbo.PRExternalLinkAuditTrail ALTER COLUMN prelat_TriggerPage nvarchar(500) NULL

--Defect 6903
EXEC usp_TravantCRM_DeleteCustom_List 'PRPersonList', 'LocalSourceDataAccess'
EXEC usp_TravantCRM_AddCustom_Lists 'PRPersonList', 39, 'Cell', null, 'Y', null, 'center'
Go

--New PRIISLogData table (Defect 4438)
EXEC usp_TravantCRM_DropTable       'PRIISLogData'
EXEC usp_TravantCRM_CreateTable     'PRIISLogData', 'priisld', 'priisld_IISLogDataId'
EXEC usp_TravantCRM_CreateKeyField  'PRIISLogData', 'priisld_IISLogDataId', 'IIS Log Data Id' 
EXEC usp_TravantCRM_CreateTextField 'PRIISLogData', 'priisld_IPAddress', 'IP Address', 200, 200, @AllowNull_In='N'
EXEC usp_TravantCRM_CreateDateField 'PRIISLogData', 'priisld_LogDate', 'Log Date', @AllowNull_In='N'
EXEC usp_TravantCRM_CreateTextField 'PRIISLogData', 'priisld_URI', 'URI', 300, 300, @AllowNull_In='N'
EXEC usp_TravantCRM_CreateTextField 'PRIISLogData', 'priisld_LogType', 'Log Type', 200, 200, @AllowNull_In='N'
EXEC usp_TravantCRM_CreateIntegerField 'PRIISLogData', 'priisld_Month', 'Month'
EXEC usp_TravantCRM_CreateIntegerField 'PRIISLogData', 'priisld_Year', 'Year'
GO

--Madison Lumber new tables
EXEC usp_TravantCRM_DropTable 'PRMadisonLumber'
EXEC usp_TravantCRM_CreateTable 'PRMadisonLumber', 'prml', 'prml_MadisonLumberID', Default, Default, Default, Default, 'Y'
EXEC usp_TravantCRM_CreateIntegerField 'PRMadisonLumber', 'prml_CompanyID', 'Company Id', 10, 'N'
EXEC usp_TravantCRM_CreateTextField 'PRMadisonLumber', 'prml_Name', 'Name', 50, 255, 'N'
EXEC usp_TravantCRM_CreateTextField 'PRMadisonLumber', 'prml_TypeOfMill', 'Type of Mill', 50, 200, 'Y'
EXEC usp_TravantCRM_CreateTextField 'PRMadisonLumber', 'prml_Region', 'Region', 50, 50, 'Y'
EXEC usp_TravantCRM_CreateTextField 'PRMadisonLumber', 'prml_Curtailed', 'Curtailed', 1, 1, 'Y'
EXEC usp_TravantCRM_CreateTextField 'PRMadisonLumber', 'prml_Employees', 'Employees', 50, 50, 'Y'
EXEC usp_TravantCRM_CreateTextField 'PRMadisonLumber', 'prml_MillStatus', 'Mill Status', 50, 50, 'Y'

EXEC usp_TravantCRM_DropTable 'PRMadisonLumberContact'
EXEC usp_TravantCRM_CreateTable 'PRMadisonLumberContact', 'prmlc', 'prmlc_MadisonLumberContactID', Default, Default, Default, Default, 'Y'
EXEC usp_TravantCRM_CreateIntegerField 'PRMadisonLumberContact', 'prmlc_MadisonLumberID', 'Madison Lumber ID', 10, 'N'
EXEC usp_TravantCRM_CreateTextField 'PRMadisonLumberContact', 'prmlc_FirstName', 'First Name', 50, 50, 'N'
EXEC usp_TravantCRM_CreateTextField 'PRMadisonLumberContact', 'prmlc_LastName', 'Last Name', 50, 50, 'Y'
EXEC usp_TravantCRM_CreateTextField 'PRMadisonLumberContact', 'prmlc_Title', 'Title', 100, 100, 'Y'
EXEC usp_TravantCRM_CreateTextField 'PRMadisonLumberContact', 'prmlc_Email', 'Email', 50, 255, 'Y'
EXEC usp_TravantCRM_CreateTextField 'PRMadisonLumberContact', 'prmlc_Phone', 'Phone', 50, 50, 'Y'

EXEC usp_TravantCRM_DropTable 'PRMadisonLumberPhone'
EXEC usp_TravantCRM_CreateTable 'PRMadisonLumberPhone', 'prmlp', 'prmlp_MadisonLumberPhoneID', Default, Default, Default, Default, 'Y'
EXEC usp_TravantCRM_CreateIntegerField 'PRMadisonLumberPhone', 'prmlp_MadisonLumberID', 'Madison Lumber ID', 10, 'N'
EXEC usp_TravantCRM_CreateTextField 'PRMadisonLumberPhone', 'prmlp_PhoneTypeCode', 'Phone Type Code', 40, 40, 'N'
EXEC usp_TravantCRM_CreateTextField 'PRMadisonLumberPhone', 'prmlp_PhoneType', 'Phone Type', 50, 50, 'Y'
EXEC usp_TravantCRM_CreateTextField 'PRMadisonLumberPhone', 'prmlp_Phone', 'Phone', 50, 50, 'Y'

EXEC usp_TravantCRM_DropTable 'PRMadisonLumberAddress'
EXEC usp_TravantCRM_CreateTable 'PRMadisonLumberAddress', 'prmla', 'prmla_MadisonLumberAddressID', Default, Default, Default, Default, 'Y'
EXEC usp_TravantCRM_CreateIntegerField 'PRMadisonLumberAddress', 'prmla_MadisonLumberID', 'Madison Lumber ID', 10, 'N'
EXEC usp_TravantCRM_CreateTextField 'PRMadisonLumberAddress', 'prmla_AddressTypeCode', 'Address Type Code', 40, 40, 'N'
EXEC usp_TravantCRM_CreateTextField 'PRMadisonLumberAddress', 'prmla_AddressLine1', 'Address Line 1', 40, 40, 'Y'
EXEC usp_TravantCRM_CreateTextField 'PRMadisonLumberAddress', 'prmla_AddressLine2', 'Address Line 2', 40, 40, 'Y'
EXEC usp_TravantCRM_CreateTextField 'PRMadisonLumberAddress', 'prmla_AddressLine3', 'Address Line 3', 40, 40, 'Y'
EXEC usp_TravantCRM_CreateTextField 'PRMadisonLumberAddress', 'prmla_City', 'City', 50, 50, 'Y'
EXEC usp_TravantCRM_CreateTextField 'PRMadisonLumberAddress', 'prmla_StateProvince', 'State Province', 2, 2, 'Y'
EXEC usp_TravantCRM_CreateTextField 'PRMadisonLumberAddress', 'prmla_PostalCode', 'Postal Code', 10, 10, 'Y'

EXEC usp_TravantCRM_DropTable 'PRMadisonLumberInternet'
EXEC usp_TravantCRM_CreateTable 'PRMadisonLumberInternet', 'prmli', 'prmli_MadisonLumberInternetID', Default, Default, Default, Default, 'Y'
EXEC usp_TravantCRM_CreateIntegerField 'PRMadisonLumberInternet', 'prmli_MadisonLumberID', 'Madison Lumber ID', 10, 'N'
EXEC usp_TravantCRM_CreateTextField 'PRMadisonLumberInternet', 'prmli_InternetTypeCode', 'Internet Type Code', 40, 40, 'N'
EXEC usp_TravantCRM_CreateTextField 'PRMadisonLumberInternet', 'prmli_Address', 'Address', 50, 200, 'N'

EXEC usp_TravantCRM_DropTable 'PRMadisonLumberData'
EXEC usp_TravantCRM_CreateTable 'PRMadisonLumberData', 'prmld', 'prmld_MadisonLumberDataID', Default, Default, Default, Default, 'Y'
EXEC usp_TravantCRM_CreateIntegerField 'PRMadisonLumberData', 'prmld_MadisonLumberID', 'Madison Lumber ID', 10, 'N'
EXEC usp_TravantCRM_CreateTextField 'PRMadisonLumberData', 'prmld_DataTypeCode', 'Data Type Code', 40, 40, 'N'
EXEC usp_TravantCRM_CreateTextField 'PRMadisonLumberData', 'prmld_Data', 'Data', 50, 1000, 'N'
Go


