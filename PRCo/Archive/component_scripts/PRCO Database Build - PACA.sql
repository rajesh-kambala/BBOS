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
-- *******************  PRPACA  ********************************************
-- Set up the Lookup Tables and fields into their own Component called PRLookups
UPDATE tAccpacComponentName SET ComponentName = 'PRPACA'

-- IMPORT PACA LICENSE
exec usp_AccpacCreateTable 'PRImportPACALicense', 'pril', 'pril_ImportPACALicenseId'
exec usp_AccpacCreateKeyField 'PRImportPACALicense', 'pril_ImportPACALicenseId', 'PACA License Id', 20, 'Y', 'N', 'N'

exec usp_AccpacCreateTextField 'PRImportPACALicense', 'pril_FileName', 'File Name', 50, 50, 'Y',  'N', 'N'
exec usp_AccpacCreateDateField 'PRImportPACALicense', 'pril_ImportDate', 'Import Date', 'Y',  'N', 'N'
exec usp_AccpacCreateTextField 'PRImportPACALicense', 'pril_LicenseNumber', 'License #', 8, 8, 'Y',  'N', 'N'
exec usp_AccpacCreateDateField 'PRImportPACALicense', 'pril_ExpirationDate', 'Expiration Date', 'Y',  'N', 'N'
--exec usp_AccpacCreateSelectField 'PRImportPACALicense', 'pril_LicenseStatus', 'License Status', 'pril_LicenseStatus' 
--exec usp_AccpacCreateCheckboxField 'PRImportPACALicense', 'pril_Current', 'Current'
exec usp_AccpacCreateTextField 'PRImportPACALicense', 'pril_CompanyName', 'Company Name', 80, 80, 'Y',  'N', 'N'
exec usp_AccpacCreateTextField 'PRImportPACALicense', 'pril_Address1', 'Address 1', 64, 64, 'Y',  'N', 'N'
exec usp_AccpacCreateTextField 'PRImportPACALicense', 'pril_Address2', 'Address 2', 64, 64, 'Y',  'N', 'N'
exec usp_AccpacCreateTextField 'PRImportPACALicense', 'pril_City', 'City', 25, 25, 'Y',  'N', 'N'
exec usp_AccpacCreateTextField 'PRImportPACALicense', 'pril_State', 'State', 2, 2, 'Y',  'N', 'N'
exec usp_AccpacCreateTextField 'PRImportPACALicense', 'pril_Country', 'Country', 20, 20, 'Y', 'N', 'N'
exec usp_AccpacCreateTextField 'PRImportPACALicense', 'pril_PostCode', 'Post Code', 10, 10, 'Y', 'N', 'N'
exec usp_AccpacCreateTextField 'PRImportPACALicense', 'pril_MailAddress1', 'Mail Address 1', 64, 64, 'Y', 'N', 'N'
exec usp_AccpacCreateTextField 'PRImportPACALicense', 'pril_MailAddress2', 'Mail Address 2', 64,64, 'Y', 'N', 'N'
exec usp_AccpacCreateTextField 'PRImportPACALicense', 'pril_MailCity', 'Mail City', 25, 25, 'Y', 'N', 'N'
exec usp_AccpacCreateTextField 'PRImportPACALicense', 'pril_MailState', 'Mail State', 2, 2, 'Y', 'N', 'N'
exec usp_AccpacCreateTextField 'PRImportPACALicense', 'pril_MailCountry', 'Mail Country', 20, 20, 'Y', 'N', 'N'
exec usp_AccpacCreateTextField 'PRImportPACALicense', 'pril_MailPostCode', 'Mail Post Code', 10, 10, 'Y', 'N', 'N'
exec usp_AccpacCreateTextField 'PRImportPACALicense', 'pril_IncState', 'Inc State', 2, 2, 'Y', 'N', 'N'
exec usp_AccpacCreateDateField 'PRImportPACALicense', 'pril_IncDate', 'Inc Date', 'Y', 'N', 'N'
exec usp_AccpacCreateSelectField 'PRImportPACALicense', 'pril_OwnCode', 'Own Code', 'OwnershipTypeCode', 'Y', 'N', 'N'
exec usp_AccpacCreateTextField 'PRImportPACALicense', 'pril_Telephone', 'Telephone', 20, 20, 'Y', 'N', 'N'
exec usp_AccpacCreateDateField 'PRImportPACALicense', 'pril_TerminateDate', 'Terminate Date', 'Y', 'N', 'N'
exec usp_AccpacCreateTextField 'PRImportPACALicense', 'pril_TerminateCode', 'Terminate Code', 2, 2, 'Y', 'N', 'N'
exec usp_AccpacCreateDateField 'PRImportPACALicense', 'pril_PACARunDate', 'PACA File Date', 'Y', 'N', 'N'
exec usp_AccpacCreateSelectField 'PRImportPACALicense', 'pril_TypeFruitVeg', 'Fruit/Veg Type', 'TypeFruitVeg', 'Y', 'N', 'N'
exec usp_AccpacCreateSelectField 'PRImportPACALicense', 'pril_ProfCode', 'PROF Code', 'ProfCode', 'Y', 'N', 'N'

-- IMPORT PACA PRINCIPAL
exec usp_AccpacCreateTable 'PRImportPACAPrincipal', 'prip', 'prip_ImportPACAPrincipalId'
exec usp_AccpacCreateKeyField 'PRImportPACAPrincipal', 'prip_ImportPACAPrincipalId', 'PACA Principal Id' 

exec usp_AccpacCreateSearchSelectField 'PRImportPACAPrincipal', 'prip_ImportPACALicenseId', 'PACA', 'PRImportPACALicense', 10, '17', NULL, 'Y'
exec usp_AccpacCreateTextField 'PRImportPACAPrincipal', 'prip_FileName', 'File Name', 50
exec usp_AccpacCreateDateField 'PRImportPACAPrincipal', 'prip_ImportDate', 'Import Date'
exec usp_AccpacCreateIntegerField 'PRImportPACAPrincipal', 'prip_Sequence', 'Sequence', 10
exec usp_AccpacCreateTextField 'PRImportPACAPrincipal', 'prip_LastName', 'Last Name', 52
exec usp_AccpacCreateTextField 'PRImportPACAPrincipal', 'prip_FirstName', 'First Name', 20
exec usp_AccpacCreateTextField 'PRImportPACAPrincipal', 'prip_MiddleInitial', 'Middle Initial', 1
exec usp_AccpacCreateTextField 'PRImportPACAPrincipal', 'prip_Title', 'Title', 10
exec usp_AccpacCreateTextField 'PRImportPACAPrincipal', 'prip_City', 'City', 25
exec usp_AccpacCreateTextField 'PRImportPACAPrincipal', 'prip_State', 'State', 2
exec usp_AccpacCreateTextField 'PRImportPACAPrincipal', 'prip_LicenseNumber', 'LicenseNumber', 8
exec usp_AccpacCreateDateField 'PRImportPACAPrincipal', 'prip_PACARunDate', 'PACA Run Date'

-- IMPORT PACA TRADE
exec usp_AccpacCreateTable 'PRImportPACATrade', 'prit', 'prit_ImportPACATradeId'
exec usp_AccpacCreateKeyField 'PRImportPACATrade', 'prit_ImportPACATradeId', 'PACA Trade Id' 

exec usp_AccpacCreateSearchSelectField 'PRImportPACATrade', 'prit_ImportPACALicenseId', 'PACA', 'PRImportPACALicense', 10, '17', NULL, 'Y'
exec usp_AccpacCreateTextField 'PRImportPACATrade', 'prit_FileName', 'File Name', 50
exec usp_AccpacCreateDateField 'PRImportPACATrade', 'prit_ImportDate', 'Import Date'
exec usp_AccpacCreateTextField 'PRImportPACATrade', 'prit_LicenseNumber', 'LicenseNumber', 8
exec usp_AccpacCreateTextField 'PRImportPACATrade', 'prit_AdditionalTradeName', 'Additional Trade Name', 80
exec usp_AccpacCreateTextField 'PRImportPACATrade', 'prit_City', 'City', 25
exec usp_AccpacCreateTextField 'PRImportPACATrade', 'prit_State', 'State', 2
exec usp_AccpacCreateDateField 'PRImportPACATrade', 'prit_PACARunDate', 'PACA Run Date'



-- PACA LICENSE START
exec usp_AccpacCreateTable 'PRPACALicense', 'prpa', 'prpa_PACALicenseId'
exec usp_AccpacCreateKeyField 'PRPACALicense', 'prpa_PACALicenseId', 'PACA License' 

exec usp_AccpacCreateSearchSelectField 'PRPACALicense', 'prpa_CompanyId', 'Company', 'Company', 50, '17', NUll, 'Y'
exec usp_AccpacCreateTextField 'PRPACALicense', 'prpa_LicenseNumber', 'License #', 8
exec usp_AccpacCreateDateField 'PRPACALicense', 'prpa_EffectiveDate', 'Effective Date'
exec usp_AccpacCreateDateField 'PRPACALicense', 'prpa_ExpirationDate', 'Expiration Date'
--exec usp_AccpacCreateSelectField 'PRPACALicense', 'prpa_LicenseStatus', 'License Status', 'prpa_LicenseStatus' 
exec usp_AccpacCreateCheckboxField 'PRPACALicense', 'prpa_Current', 'Current'
exec usp_AccpacCreateTextField 'PRPACALicense', 'prpa_CompanyName', 'Company Name', 80
exec usp_AccpacCreateTextField 'PRPACALicense', 'prpa_Address1', 'Address 1', 64
exec usp_AccpacCreateTextField 'PRPACALicense', 'prpa_Address2', 'Address 2', 64
exec usp_AccpacCreateTextField 'PRPACALicense', 'prpa_City', 'City', 25
exec usp_AccpacCreateTextField 'PRPACALicense', 'prpa_State', 'State', 2
--exec usp_AccpacCreateTextField 'PRPACALicense', 'prpa_Country', 'Country', 20
exec usp_AccpacCreateTextField 'PRPACALicense', 'prpa_PostCode', 'Post Code', 10
exec usp_AccpacCreateTextField 'PRPACALicense', 'prpa_MailAddress1', 'Mail Address 1', 64
exec usp_AccpacCreateTextField 'PRPACALicense', 'prpa_MailAddress2', 'Mail Address 2', 64
exec usp_AccpacCreateTextField 'PRPACALicense', 'prpa_MailCity', 'Mail City', 25
exec usp_AccpacCreateTextField 'PRPACALicense', 'prpa_MailState', 'Mail State', 2
--exec usp_AccpacCreateTextField 'PRPACALicense', 'prpa_MailCountry', 'Mail Country', 50
exec usp_AccpacCreateTextField 'PRPACALicense', 'prpa_MailPostCode', 'Mail Post Code', 10
exec usp_AccpacCreateTextField 'PRPACALicense', 'prpa_IncState', 'Inc State', 2
exec usp_AccpacCreateDateField 'PRPACALicense', 'prpa_IncDate', 'Inc Date'
exec usp_AccpacCreateSelectField 'PRPACALicense', 'prpa_OwnCode', 'Own Code', 'OwnershipTypeCode'
exec usp_AccpacCreateTextField 'PRPACALicense', 'prpa_Telephone', 'Telephone', 20
exec usp_AccpacCreateDateField 'PRPACALicense', 'prpa_TerminateDate', 'Terminate Date'
exec usp_AccpacCreateTextField 'PRPACALicense', 'prpa_TerminateCode', 'Terminate Code', 2
exec usp_AccpacCreateDateField 'PRPACALicense', 'prpa_ExpireDate', 'Expire Date'
exec usp_AccpacCreateSelectField 'PRPACALicense', 'prpa_TypeFruitVeg', 'Fruit/Veg Type', 'TypeFruitVeg'
exec usp_AccpacCreateSelectField 'PRPACALicense', 'prpa_ProfCode', 'Prof Code', 'ProfCode'
exec usp_AccpacCreateSelectField 'PRPACALicense', 'prpa_DataSource', 'Source', 'prpa_DataSource'
exec usp_AccpacCreateCheckboxField 'PRPACALicense', 'prpa_Publish', 'Publish'

-- PACA PRINCIPAL
exec usp_AccpacCreateTable 'PRPACAPrincipal', 'prpp', 'prpp_PACAPrincipalId'
exec usp_AccpacCreateKeyField 'PRPACAPrincipal', 'prpp_PACAPrincipalId', 'PACA Principal Id' 

exec usp_AccpacCreateSearchSelectField 'PRPACAPrincipal', 'prpp_PACALicenseId', 'PACA', 'PRPACALicense', 10, '17', NULL, 'Y'
--exec usp_AccpacCreateIntegerField 'PRPACAPrincipal', 'prpp_Sequence', 'Sequence', 10 
exec usp_AccpacCreateTextField 'PRPACAPrincipal', 'prpp_LastName', 'Last Name', 52
exec usp_AccpacCreateTextField 'PRPACAPrincipal', 'prpp_FirstName', 'First Name', 20
exec usp_AccpacCreateTextField 'PRPACAPrincipal', 'prpp_MiddleInitial', 'Middle Initial', 1
exec usp_AccpacCreateTextField 'PRPACAPrincipal', 'prpp_Title', 'Title', 10
exec usp_AccpacCreateTextField 'PRPACAPrincipal', 'prpp_City', 'City', 25
exec usp_AccpacCreateTextField 'PRPACAPrincipal', 'prpp_State', 'State', 2
--exec usp_AccpacCreateTextField 'PRPACAPrincipal', 'prpp_LicenseNumber', 'License', 8

-- PACA TRADE
exec usp_AccpacCreateTable 'PRPACATrade', 'ptrd', 'ptrd_PACATradeId'
exec usp_AccpacCreateKeyField 'PRPACATrade', 'ptrd_PACATradeId', 'PACA Trade Id' 

exec usp_AccpacCreateSearchSelectField 'PRPACATrade', 'ptrd_PACALicenseId', 'PACA', 'PRPACALicense', 10, '17', NULL, 'Y'
--exec usp_AccpacCreateTextField 'PRPACATrade', 'ptrd_LicenseNumber', 'LicenseNumber', 8
exec usp_AccpacCreateTextField 'PRPACATrade', 'ptrd_AdditionalTradeName', 'Name', 80
exec usp_AccpacCreateTextField 'PRPACATrade', 'ptrd_City', 'City', 25
exec usp_AccpacCreateTextField 'PRPACATrade', 'ptrd_State', 'State', 2
--exec usp_AccpacCreateDateField 'PRPACATrade', 'ptrd_PACARunDate', 'PACA Run Date'

-- Set up the Component name back to the original value
UPDATE tAccpacComponentName SET ComponentName = @DEFAULT_COMPONENT_NAME
-- *******************  END PRPACA  ****************************************
-- ****************************************************************************

DROP TABLE tAccpacComponentName 
GO

SET NOCOUNT OFF
GO

-- ********************* END TABLE AND FIELD CREATION *************************

GO
