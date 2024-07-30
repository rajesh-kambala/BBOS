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
SET @DEFAULT_COMPONENT_NAME = 'PRCompany'

IF not exists (select 1 from sysobjects where id = object_id('tAccpacComponentName') 
			and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
  CREATE TABLE dbo.tAccpacComponentName ( ComponentName nvarchar(20) NULL )
  -- Create a default row so that all we have to do are updates
  Insert into tAccpacComponentName Values (@DEFAULT_COMPONENT_NAME)
END

-- ****************************************************************************
-- *******************  PRCompany  ********************************************
UPDATE tAccpacComponentName SET ComponentName = 'PRCompany'

-- Update the tab's targets
UPDATE Custom_Tabs SET Tabs_Action = 'customfile', Tabs_CustomFileName = 'PRCompany/PRCompanyCases.asp' 
 WHERE Tabs_Entity = 'Company'And Tabs_caption = 'Cases' and Tabs_DeviceId is NULL


-- Setting the tabs_Sensitive field to null removes the team restriction for users accessing
-- these tabs; this was showing as the red "no access" icon for these tabs after a new
-- company was created
update custom_tabs set tabs_Sensitive = null
 where tabs_entity = 'Company'
  and tabs_deviceid is null 
  and tabs_caption in ('CompanyDashboard', 'Opportunities', 'Cases', 'Communications')

-- * Perform Specific updates without changing the component name

-- Hide these tabs
UPDATE Custom_Tabs SET Tabs_Deleted = 1 WHERE Tabs_Entity = 'Company'
        AND (
                tabs_Caption = 'Notes' or 
                tabs_Caption = 'Addresses' or
                tabs_Caption = 'QuickLook' or
                tabs_Caption = 'Key Attribute Data' or
                tabs_Caption = 'Phone/Email' or
                tabs_Caption = 'Marketing' or
                tabs_Caption = 'Team' or
                tabs_Caption = 'People' or
                tabs_Caption = 'CompanyDashboard' 
            )
-- Update the display order of these tabs
UPDATE Custom_Tabs SET Tabs_Order = 11 WHERE Tabs_Entity = 'Company' And Tabs_Caption = 'Opportunities' AND tabs_DeviceId is null
UPDATE Custom_Tabs SET Tabs_Order = 1, Tabs_Action = 'customfile', Tabs_CustomFileName = 'PRCompany/PRCompanySummary.asp'
 WHERE Tabs_Entity = 'Company' And Tabs_Caption = 'Summary' AND tabs_DeviceId is null
UPDATE Custom_Tabs SET Tabs_Order = 12 WHERE Tabs_Entity = 'Company' And Tabs_Caption = 'Cases'
UPDATE Custom_Tabs SET Tabs_Order = 14 WHERE Tabs_Entity = 'Company' And Tabs_Caption = 'Communications'
UPDATE Custom_Tabs SET Tabs_Order = 15 WHERE Tabs_Entity = 'Company' And Tabs_Caption = 'Library'

-- COMPANY
-- Change the custom_content scripts for out-of-the-box accpac screens; don't do this in 
-- screen scripts because the entity and compoent names get updated, then standard accpac 
-- fields will get removed by our unistall scripts
SET @CustomContent = 
        '<script language=javascript src="../CustomPages/PRCoGeneral.js"></script>' +
        '<script language=javascript src="../CustomPages/PRCompany/CompanyClient.js"></script>' + 
        '<script language=javascript>'+ 
        'document.write(new String( location.href ));RedirectCompany();' + 
        '</script>'
UPDATE Custom_ScreenObjects set CObj_CustomContent = @CustomContent WHERE CObj_Name = 'CompanyBoxDedupe'
UPDATE Custom_ScreenObjects set CObj_CustomContent = @CustomContent WHERE CObj_Name = 'CompanyBoxLong'

-- Modify the results grid to add custom content for removing the workflow table
/* Custom content for the ComapnySearchBox has moved to the PRCompany.es file because this entity 
   is completely rebuild in that module.
*/
--UPDATE Custom_ScreenObjects set CObj_CustomContent = @CustomContent WHERE CObj_Name = 'CompanySearchBox'

-- remove the index or we cannot change comp_Name's size
IF exists (select * from sysindexes where name = 'IDX_Comp_Name') 
BEGIN
    DROP INDEX company.IDX_Comp_Name
END
-- This call replaces a AddCustom_Data call originally in the .es script
UPDATE Custom_Edits SET colp_System = '', colp_Component = NULL Where colp_ColName = 'comp_CompanyId'
-- Change the size of name using our process but then set the component
-- name back to NULL so that it is not part of PRCompany component, otherwise uninstall 
-- will try to remove it 
exec usp_AccpacCreateTextField 'Company', 'comp_Name', 'Company Name', 50, 104, 'Y', 'N', 'N'
UPDATE Custom_Edits SET colp_Component = NULL Where colp_ColName = 'comp_Name'
exec usp_AccpacCreateSearchSelectField 'Company', 'comp_PRHQId', 'HQ', 'Company', 10, '0'
exec usp_AccpacCreateTextField 'Company', 'comp_PRCorrTradestyle', 'Correspondence Tradestyle', 50, 104, 'Y', 'N', 'N'
exec usp_AccpacCreateTextField 'Company', 'comp_PRBookTradestyle', 'Book Tradestyle', 50, 104, 'Y', 'N', 'N'
exec usp_AccpacCreateCheckboxField 'Company', 'comp_PRSubordinationAgrProvided', 'Subordination Agmt Provided'
exec usp_AccpacCreateDateField 'Company', 'comp_PRSubordinationAgrDate', 'Subordination Agmt Provided Date'
exec usp_AccpacCreateCheckboxField 'Company', 'comp_PRRequestFinancials', 'Request Financials'
exec usp_AccpacCreateMultilineField 'Company', 'comp_PRSpecialInstruction', 'Special Instructions', 75, '5'
exec usp_AccpacCreateSelectField 'Company', 'comp_PRDataQualityTier', 'Data Quality Tier', 'comp_PRDataQualityTier' 
exec usp_AccpacCreateSearchSelectField 'Company', 'comp_PRListingCityId', 'Listing City', 'vPRLocation', 50, '0'
exec usp_AccpacCreateSelectField 'Company', 'comp_PRListingStatus', 'Listing Status', 'comp_PRListingStatus' 
exec usp_AccpacCreateSelectField 'Company', 'comp_PRAccountTier', 'Account Tier', 'comp_PRAccountTier' 
exec usp_AccpacCreateSelectField 'Company', 'comp_PRBusinessStatus', 'Business Status', 'comp_PRBusinessStatus' 
exec usp_AccpacCreateIntegerField 'Company', 'comp_PRDaysPastDue', 'Days Past Due', 10
exec usp_AccpacCreateCheckboxField 'Company', 'comp_PRSuspendedService', 'Suspended Service'
exec usp_AccpacCreateTextField 'Company', 'comp_PRTradestyle1', 'Tradestyle 1', 50, 104, 'N', 'Y'
exec usp_AccpacCreateTextField 'Company', 'comp_PRTradestyle2', 'Tradestyle 2', 50, 104
exec usp_AccpacCreateTextField 'Company', 'comp_PRTradestyle3', 'Tradestyle 3', 50, 104
exec usp_AccpacCreateTextField 'Company', 'comp_PRTradestyle4', 'Tradestyle 4', 50, 104
exec usp_AccpacCreateTextField 'Company', 'comp_PRLegalName', 'Legal Name', 60
exec usp_AccpacCreateTextField 'Company', 'comp_PROriginalName', 'Original Name', 50
exec usp_AccpacCreateTextField 'Company', 'comp_PROldName1', 'Old Name 1', 50
exec usp_AccpacCreateDateField 'Company', 'comp_PROldName1Date', 'Date of Change 1'
exec usp_AccpacCreateTextField 'Company', 'comp_PROldName2', 'Old Name 2', 50
exec usp_AccpacCreateDateField 'Company', 'comp_PROldName2Date', 'Date of Change 2'
exec usp_AccpacCreateTextField 'Company', 'comp_PROldName3', 'Old Name 3', 50
exec usp_AccpacCreateDateField 'Company', 'comp_PROldName3Date', 'Date of Change 3'
exec usp_AccpacCreateSelectField 'Company', 'comp_PRType', 'Type', 'comp_PRType' 
exec usp_AccpacCreateMultilineField 'Company', 'comp_PRUnloadHours', 'Unload Hours', 75, '5'
exec usp_AccpacCreateCheckboxField 'Company', 'comp_PRPublishUnloadHours', 'Publish Unload Hours'
exec usp_AccpacCreateTextField 'Company', 'comp_PRMoralResponsibility', 'Moral Resp', 10
exec usp_AccpacCreateMultilineField 'Company', 'comp_PRSpecialHandlingInstruction', 'Spcl Handling Instructions', 75, '5'
exec usp_AccpacCreateCheckboxField 'Company', 'comp_PRHandlesInvoicing', 'Handles Own Invoicing for Produce Trx'
exec usp_AccpacCreateCheckboxField 'Company', 'comp_PRReceiveLRL', 'Receive LRL'
exec usp_AccpacCreateCheckboxField 'Company', 'comp_PRTMFMAward', 'TM/FM Awarded'
exec usp_AccpacCreateDateField 'Company', 'comp_PRTMFMAwardDate', 'TM/FM Awarded Date'
exec usp_AccpacCreateCheckboxField 'Company', 'comp_PRTMFMCandidate', 'TM/FM Candidate'
exec usp_AccpacCreateDateField 'Company', 'comp_PRTMFMCandidateDate', 'TM/FM Candidate Date'
exec usp_AccpacCreateMultilineField 'Company', 'comp_PRTMFMComments', 'TM/FM Comments', 75, '5'
exec usp_AccpacCreateSelectField 'Company', 'comp_PRAdministrativeUsage', 'Admin Usage', 'comp_PRAdministrativeUsage'
exec usp_AccpacCreateUserSelectField 'Company', 'comp_PRListingUserId', 'Listing Maintenance'
exec usp_AccpacCreateUserSelectField 'Company', 'comp_PRRatingUserId', 'Rating Analyst'
exec usp_AccpacCreateUserSelectField 'Company', 'comp_PRCustomerServiceUserId', 'Customer Service'
exec usp_AccpacCreateUserSelectField 'Company', 'comp_PRMarketingUserId', 'Marketing'
exec usp_AccpacCreateUserSelectField 'Company', 'comp_PRFieldRepUserId', 'Field Rep'
exec usp_AccpacCreateSelectField 'Company', 'comp_PRInvestigationMethodGroup', 'Investigation Method Grp', 'comp_PRInvMethodGroup'
exec usp_AccpacCreateCheckboxField 'Company', 'comp_PRReceiveTES', 'Receive TES','Y','N','Y','N','''Y'''
exec usp_AccpacCreateCheckboxField 'Company', 'comp_PRTESNonresponder', 'Does Not Respond To Surveys'
exec usp_AccpacCreateIntegerField 'Company', 'comp_PRCreditWorthCap', 'Credit Worth Cap', 10
exec usp_AccpacCreateMultilineField 'Company', 'comp_PRCreditWorthCapReason', 'Credit Worth Cap Reason', 75, '5'
exec usp_AccpacCreateCheckboxField 'Company', 'comp_PRConfidentialFS', 'Financial Statements are Confidential'
exec usp_AccpacCreateDateField 'Company', 'comp_PRJeopardyDate', 'Jeopardy Date'
exec usp_AccpacCreateTextField 'Company', 'comp_PRSpotlight', 'Spotlight', 10, 255
exec usp_AccpacCreateTextField 'Company', 'comp_PRLogo', 'Logo Image File', 10, 255
exec usp_AccpacCreateIntegerField 'Company', 'comp_PRUnattributedOwnerPct', 'Unattributed Owner Pct', 10
exec usp_AccpacCreateMultilineField 'Company', 'comp_PRUnattributedOwnerDesc', 'Unattributed Owner Desc', 75, '5'
-- note that a bug in accpac requires us to put an extra & before only the first &nbsp;
exec usp_AccpacCreateDateField 'Company', 'comp_PRConnectionListDate', 'Last&&nbsp;Connection List&nbsp;Date'
exec usp_AccpacCreateDateField 'Company', 'comp_PRFinancialStatementDate', 'Last Financial Stmt Date'
exec usp_AccpacCreateCheckboxField 'Company', 'comp_PRBusinessReport', 'Use People Background In Business Report'
exec usp_AccpacCreateMultilineField 'Company', 'comp_PRPrincipalsBackgroundText', 'People Background Business Report Text', 75, '5'
exec usp_AccpacCreateSelectField 'Company', 'comp_PRMethodSourceReceived', 'Method Received', 'comp_PRMethodSourceReceived' 
exec usp_AccpacCreateSelectField 'Company', 'comp_PRIndustryType', 'Industry Type', 'comp_PRIndustryType' 
exec usp_AccpacCreateSelectField 'Company', 'comp_PRCommunicationLanguage', 'Language', 'comp_PRCommunicationLanguage' 
exec usp_AccpacCreateCheckboxField 'Company', 'comp_PRTradestyleFlag', 'Non-Standard Tradestyle'
exec usp_AccpacCreateCheckboxField 'Company', 'comp_PRPublishDL', 'Publish DL','Y','N','Y','N','''Y'''
exec usp_AccpacCreateCheckboxField 'Company', 'comp_DLBillFlag', 'Bill For DL'
exec usp_AccpacCreateIntegerField 'Company', 'comp_PRDLDaysPastDue', 'DL Days Past Due'
exec usp_AccpacCreateCheckboxField 'Company', 'comp_PRWebActivated', 'Permit Access to Web Site'
exec usp_AccpacCreateDateField 'Company', 'comp_PRWebActivatedDate', 'Last Date/Time Access to Web Site Changed'
exec usp_AccpacCreateCheckboxField 'Company', 'comp_PRReceivesBBScoreReport', 'Receives BB Score Report'
exec usp_AccpacCreateCheckboxField 'Company', 'comp_PRReceiveCSSurvey', 'Receives Customer Service Survey','Y','N','Y','N','''Y'''
exec usp_AccpacCreateCheckboxField 'Company', 'comp_PRReceivePromoFaxes', 'Receives Promo Faxes','Y','N','Y','N','''Y'''
exec usp_AccpacCreateCheckboxField 'Company','comp_PRReceivePromoEmails','Receives Promo E-mails','Y','N','Y','N','''Y'''

-- This field records the companyId that Services are provided through such as a parent company or affiliate
exec usp_AccpacCreateSearchSelectField 'Company', 'comp_PRServicesThroughCompanyId', 'Services Through', 'Company', 50, '0'
exec usp_AccpacCreateDateField 'Company', 'comp_PRLastVisitDate', 'Last Visit Date'
exec usp_AccpacCreateUserSelectField 'Company', 'comp_PRLastVisitedBy', 'Last Visited By'

-- Set the non-custom name field to readonly 
Update Custom_Edits Set ColP_AllowEdit = 'N' WHERE ColP_ColName = 'Comp_Name'


-- Put the comp_name index back
CREATE  CLUSTERED  INDEX [IDX_Comp_Name] ON [dbo].[Company]([Comp_Name]) ON [PRIMARY]

-- COMPANY ALIAS 
exec usp_AccpacCreateTable 'PRCompanyAlias', 'pral', 'pral_CompanyAliasId'
exec usp_AccpacCreateKeyField 'PRCompanyAlias', 'pral_CompanyAliasId', 'Company Alias Id'

exec usp_AccpacCreateAdvSearchSelectField 'PRCompanyAlias', 'pral_CompanyId', 'Company', 'Company', 10, '', NULL, 'Y' 
exec usp_AccpacCreateTextField 'PRCompanyAlias', 'pral_Alias', 'Alias', 50

-- COMPANY BANK
exec usp_AccpacCreateTable 'PRCompanyBank', 'prcb', 'prcb_CompanyBankId'
exec usp_AccpacCreateKeyField 'PRCompanyBank', 'prcb_CompanyBankId', 'Company Bank Id' 

exec usp_AccpacCreateAdvSearchSelectField 'PRCompanyBank', 'prcb_CompanyId', 'Company', 'Company', 10, '17', NULL, 'Y'
exec usp_AccpacCreateTextField 'PRCompanyBank', 'prcb_Name', 'Bank', 100
exec usp_AccpacCreateTextField 'PRCompanyBank', 'prcb_Address1', 'Address 1', 50
exec usp_AccpacCreateTextField 'PRCompanyBank', 'prcb_Address2', 'Address 2',  50
exec usp_AccpacCreateTextField 'PRCompanyBank', 'prcb_City', 'City', 20
exec usp_AccpacCreateTextField 'PRCompanyBank', 'prcb_State', 'State', 10
exec usp_AccpacCreateTextField 'PRCompanyBank', 'prcb_PostalCode', 'Postal Code', 10
exec usp_AccpacCreateTextField 'PRCompanyBank', 'prcb_Telephone', 'Telephone', 20
exec usp_AccpacCreateTextField 'PRCompanyBank', 'prcb_Fax', 'Fax', 20
exec usp_AccpacCreateURLField  'PRCompanyBank', 'prcb_Website', 'Website'
exec usp_AccpacCreateMultilineField 'PRCompanyBank', 'prcb_AdditionalInfo', 'Additional Info', 75, '5'
exec usp_AccpacCreateCheckboxField 'PRCompanyBank', 'prcb_Publish', 'Publish'

-- COMPANY BRAND
exec usp_AccpacCreateTable 'PRCompanyBrand', 'prc3', 'prc3_CompanyBrandId'
exec usp_AccpacCreateKeyField 'PRCompanyBrand', 'prc3_CompanyBrandId', 'Company Brand Id' 

exec usp_AccpacCreateAdvSearchSelectField 'PRCompanyBrand', 'prc3_CompanyId', 'Company', 'Company', 10, '17', NULL, 'Y'
exec usp_AccpacCreateTextField 'PRCompanyBrand', 'prc3_Brand', 'Brand', 34
exec usp_AccpacCreateMultilineField 'PRCompanyBrand', 'prc3_Description', 'Description', 75, '5'
exec usp_AccpacCreateTextField 'PRCompanyBrand', 'prc3_ViewableImageLocation', 'Viewable Image Location', 100
exec usp_AccpacCreateTextField 'PRCompanyBrand', 'prc3_PrintableImageLocation', 'Printable Image Location', 100
exec usp_AccpacCreateTextField 'PRCompanyBrand', 'prc3_OwningCompany', 'Owning Company', 100
exec usp_AccpacCreateCheckboxField 'PRCompanyBrand', 'prc3_Publish', 'Publish'
exec usp_AccpacCreateIntegerField 'PRCompanyBrand', 'prc3_Sequence', 'Sequence', 10

-- COMPANY CLASSIFICATION
exec usp_AccpacCreateTable 'PRCompanyClassification', 'prc2', 'prc2_CompanyClassificationId'
exec usp_AccpacCreateKeyField 'PRCompanyClassification', 'prc2_CompanyClassificationId', 'Company Classification Id' 

exec usp_AccpacCreateAdvSearchSelectField 'PRCompanyClassification', 'prc2_CompanyId', 'Company', 'Company', 10, '17', NULL, 'Y'
exec usp_AccpacCreateSearchSelectField 'PRCompanyClassification', 'prc2_ClassificationId', 'Classification', 'PRClassification' 
exec usp_AccpacCreateNumericField 'PRCompanyClassification', 'prc2_Percentage', 'Percentage', 10
exec usp_AccpacCreateCheckboxField 'PRCompanyClassification', 'prc2_PercentageSource', '% Provided by Company'
exec usp_AccpacCreateSelectField 'PRCompanyClassification', 'prc2_NumberOfStores', '# Stores', 'prc2_StoreCount' 
exec usp_AccpacCreateCheckboxField 'PRCompanyClassification', 'prc2_ComboStores', 'Combo Stores'
exec usp_AccpacCreateSelectField 'PRCompanyClassification', 'prc2_NumberOfComboStores', '# Combo Stores', 'prc2_StoreCount'
exec usp_AccpacCreateCheckboxField 'PRCompanyClassification', 'prc2_ConvenienceStores', 'Convenience Stores'
exec usp_AccpacCreateSelectField 'PRCompanyClassification', 'prc2_NumberOfConvenienceStores', '# Convenience Stores', 'prc2_StoreCount' 
exec usp_AccpacCreateCheckboxField 'PRCompanyClassification', 'prc2_GourmetStores', 'Gourmet Stores'
exec usp_AccpacCreateSelectField 'PRCompanyClassification', 'prc2_NumberOfGourmetStores', '# Gourmet Stores', 'prc2_StoreCount'
exec usp_AccpacCreateCheckboxField 'PRCompanyClassification', 'prc2_HealthFoodStores', 'Health Food Stores'
exec usp_AccpacCreateSelectField 'PRCompanyClassification', 'prc2_NumberOfHealthFoodStores', '# Health Food Stores', 'prc2_StoreCount' 
exec usp_AccpacCreateCheckboxField 'PRCompanyClassification', 'prc2_ProduceOnlyStores', 'Produce Only Stores'
exec usp_AccpacCreateSelectField 'PRCompanyClassification', 'prc2_NumberOfProduceOnlyStores', '# Produce Only Stores', 'prc2_StoreCount' 
exec usp_AccpacCreateCheckboxField 'PRCompanyClassification', 'prc2_SupermarketStores', 'Supermarket Stores'
exec usp_AccpacCreateSelectField 'PRCompanyClassification', 'prc2_NumberOfSupermarketStores', '# Supermarket Stores', 'prc2_StoreCount' 
exec usp_AccpacCreateCheckboxField 'PRCompanyClassification', 'prc2_SuperStores', 'Super Stores'
exec usp_AccpacCreateSelectField 'PRCompanyClassification', 'prc2_NumberOfSuperStores', '# Super Stores', 'prc2_StoreCount' 
exec usp_AccpacCreateCheckboxField 'PRCompanyClassification', 'prc2_WarehouseStores', 'Warehouse Stores'
exec usp_AccpacCreateSelectField 'PRCompanyClassification', 'prc2_NumberOfWarehouseStores', '# Warehouse Stores', 'prc2_StoreCount' 
exec usp_AccpacCreateCheckboxField 'PRCompanyClassification', 'prc2_AirFreight', 'Air Freight'
exec usp_AccpacCreateCheckboxField 'PRCompanyClassification', 'prc2_OceanFreight', 'Ocean Freight'
exec usp_AccpacCreateCheckboxField 'PRCompanyClassification', 'prc2_GroundFreight', 'Ground Freight'
exec usp_AccpacCreateCheckboxField 'PRCompanyClassification', 'prc2_RailFreight', 'Rail Freight'

-- COMPANY COMMODITY
exec usp_AccpacCreateTable 'PRCompanyCommodity', 'prcc', 'prcc_CompanyCommodityId'
exec usp_AccpacCreateKeyField 'PRCompanyCommodity', 'prcc_CompanyCommodityId', 'Company Commodity Id' 

exec usp_AccpacCreateAdvSearchSelectField 'PRCompanyCommodity', 'prcc_CompanyId', 'Company', 'Company', 10, '17', NULL, 'Y'
exec usp_AccpacCreateIntegerField         'PRCompanyCommodity', 'prcc_CommodityId', 'Commodity #', 10
exec usp_AccpacCreateIntegerField         'PRCompanyCommodity', 'prcc_Sequence', 'Sequence', 10
exec usp_AccpacCreateCheckboxField        'PRCompanyCommodity', 'prcc_Publish', 'Publish'
--exec usp_AccpacCreateSearchSelectField    'PRCompanyCommodity', 'prcc_AttributeId', 'Attribute', 'PRAttribute'
--exec usp_AccpacCreateIntegerField         'PRCompanyCommodity', 'prcc_GrowingMethodAttributeId', 'Growing Method Id', 10
exec usp_AccpacCreateTextField            'PRCompanyCommodity', 'prcc_PublishedDisplay', 'List Display', 50

-- COMPANY COMMODITY ATTRIBUTE
exec usp_AccpacCreateTable 'PRCompanyCommodityAttribute', 'prcca', 'prcca_CompanyCommodityAttributeId'
exec usp_AccpacCreateKeyField 'PRCompanyCommodityAttribute', 'prcca_CompanyCommodityAttributeId', 'Company Commodity Attribute Id' 

exec usp_AccpacCreateIntegerField   'PRCompanyCommodityAttribute', 'prcca_CompanyId', 'Company BBID', 10
exec usp_AccpacCreateIntegerField   'PRCompanyCommodityAttribute', 'prcca_CommodityId', 'Commodity Id', 10
exec usp_AccpacCreateIntegerField   'PRCompanyCommodityAttribute', 'prcca_AttributeId', 'Attribute Id', 10
exec usp_AccpacCreateIntegerField   'PRCompanyCommodityAttribute', 'prcca_Sequence', 'Sequence', 10
exec usp_AccpacCreateCheckboxField  'PRCompanyCommodityAttribute', 'prcca_Publish', 'Publish'
exec usp_AccpacCreateCheckboxField  'PRCompanyCommodityAttribute', 'prcca_PublishWithGM', 'Publish W/&nbsp;GM'
exec usp_AccpacCreateTextField      'PRCompanyCommodityAttribute', 'prcca_PublishedDisplay', 'List Display', 50
exec usp_AccpacCreateIntegerField   'PRCompanyCommodityAttribute', 'prcca_GrowingMethodId', 'Grow Mtd Id', 10

-- COMPANY REGION
exec usp_AccpacCreateTable 'PRCompanyRegion', 'prcd', 'prcd_CompanyRegionId'
exec usp_AccpacCreateKeyField 'PRCompanyRegion', 'prcd_CompanyRegionId', 'Company Region Id' 

exec usp_AccpacCreateAdvSearchSelectField 'PRCompanyRegion', 'prcd_CompanyId', 'Company', 'Company', 10, '17', NULL, 'Y'
exec usp_AccpacCreateSearchSelectField 'PRCompanyRegion', 'prcd_RegionId', 'Region', 'PRRegion'
exec usp_AccpacCreateTextField 'PRCompanyRegion', 'prcd_Type', 'Type', 5

-- COMPANY STOCK EXCHANGE 
exec usp_AccpacCreateTable 'PRCompanyStockExchange', 'prc4', 'prc4_CompanyStockExchangeId'
exec usp_AccpacCreateKeyField 'PRCompanyStockExchange ', 'prc4_CompanyStockExchangeId', 'Company Stock Exchange Id' 

exec usp_AccpacCreateAdvSearchSelectField 'PRCompanyStockExchange', 'prc4_CompanyId', 'Company', 'Company', 10, '17'
exec usp_AccpacCreateSearchSelectField 'PRCompanyStockExchange', 'prc4_StockExchangeId', 'Stock Exchange', 'PRStockExchange' 
exec usp_AccpacCreateTextField 'PRCompanyStockExchange', 'prc4_Symbol1', 'Symbol 1', 10
exec usp_AccpacCreateTextField 'PRCompanyStockExchange', 'prc4_Symbol2', 'Symbol 2', 10
exec usp_AccpacCreateTextField 'PRCompanyStockExchange', 'prc4_Symbol3', 'Symbol 3', 10

-- COMPANY INFO PROFILE
exec usp_AccpacCreateTable 'PRCompanyInfoProfile', 'prc5', 'prc5_CompanyInfoProfileId'
exec usp_AccpacCreateKeyField 'PRCompanyInfoProfile', 'prc5_CompanyInfoProfileId', 'Company Info Profile Id' 

exec usp_AccpacCreateAdvSearchSelectField 'PRCompanyInfoProfile', 'prc5_CompanyId', 'Company', 'Company', 10, '17', NULL, 'Y'

exec usp_AccpacCreateDateField 'PRCompanyInfoProfile', 'prc5_InformationProfileDate', 'Information Profile Date'
exec usp_AccpacCreateUserSelectField 'PRCompanyInfoProfile', 'prc5_InformationProfileUserId', 'Information Profile Updated By'

exec usp_AccpacCreateCheckboxField 'PRCompanyInfoProfile', 'prc5_BBUse', 'BB Use'
exec usp_AccpacCreateSelectField 'PRCompanyInfoProfile', 'prc5_BBServiceBenefits', 'BB Service Benefits', 'prc5_BBServiceBenefits'
exec usp_AccpacCreateSelectField 'PRCompanyInfoProfile', 'prc5_BBRankingUsage', 'BB Ranking Usage', 'prc5_RankingUsage' 
exec usp_AccpacCreateSelectField 'PRCompanyInfoProfile', 'prc5_BBAmountSpent', 'BB Amount Spent', 'prc5_AmountSpent' 
exec usp_AccpacCreateMultilineField 'PRCompanyInfoProfile', 'prc5_BBComments', 'BB Comments', 75, '5'

exec usp_AccpacCreateCheckboxField 'PRCompanyInfoProfile', 'prc5_RBCSUse', 'RBCS Use'
exec usp_AccpacCreateSelectField 'PRCompanyInfoProfile', 'prc5_RBCSServiceBenefits', 'RBCS Service Benefits', 'prc5_RBCSServiceBenefits' 
exec usp_AccpacCreateSelectField 'PRCompanyInfoProfile', 'prc5_RBCSRankingUsage', 'RBCS Ranking Usage', 'prc5_RankingUsage' 
exec usp_AccpacCreateSelectField 'PRCompanyInfoProfile', 'prc5_RBCSAmountSpent', 'RBCS Amount Spent', 'prc5_AmountSpent' 
exec usp_AccpacCreateMultilineField 'PRCompanyInfoProfile', 'prc5_RBCSComments', 'RBCS Comments', 75, '5'

exec usp_AccpacCreateCheckboxField 'PRCompanyInfoProfile', 'prc5_DBUse', 'DB Use'
exec usp_AccpacCreateSelectField 'PRCompanyInfoProfile', 'prc5_DBServiceBenefits', 'DB Service Benefits', 'prc5_DBServiceBenefits' 
exec usp_AccpacCreateSelectField 'PRCompanyInfoProfile', 'prc5_DBRankingUsage', 'DB Ranking Usage', 'prc5_RankingUsage' 
exec usp_AccpacCreateSelectField 'PRCompanyInfoProfile', 'prc5_DBAmountSpent', 'DB Amount Spent', 'prc5_AmountSpent' 
exec usp_AccpacCreateMultilineField 'PRCompanyInfoProfile', 'prc5_DBComments', 'DB Comments', 75, '5'

exec usp_AccpacCreateCheckboxField 'PRCompanyInfoProfile', 'prc5_ExperianUse', 'Experian Use'
exec usp_AccpacCreateSelectField 'PRCompanyInfoProfile', 'prc5_ExperianServiceBenefits', 'Experian Service Benefits', 'prc5_ExperianServiceBenefits' 
exec usp_AccpacCreateSelectField 'PRCompanyInfoProfile', 'prc5_ExperianRankingUsage', 'Experian Ranking Usage', 'prc5_RankingUsage' 
exec usp_AccpacCreateSelectField 'PRCompanyInfoProfile', 'prc5_ExperianAmountSpent', 'Experian Amount Spent', 'prc5_AmountSpent' 
exec usp_AccpacCreateMultilineField 'PRCompanyInfoProfile', 'prc5_ExperianComments', 'Experian Comments', 75, '5'

exec usp_AccpacCreateCheckboxField 'PRCompanyInfoProfile', 'prc5_CompunetUse', 'Compunet Use'
exec usp_AccpacCreateSelectField 'PRCompanyInfoProfile', 'prc5_CompunetServiceBenefits', 'Compunet Service Benefits', 'prc5_CompunetServiceBenefits' 
exec usp_AccpacCreateSelectField 'PRCompanyInfoProfile', 'prc5_CompunetRankingUsage', 'Compunet Ranking Usage', 'prc5_RankingUsage' 
exec usp_AccpacCreateSelectField 'PRCompanyInfoProfile', 'prc5_CompunetAmountSpent', 'Compunet Amount Spent', 'prc5_AmountSpent' 
exec usp_AccpacCreateMultilineField 'PRCompanyInfoProfile', 'prc5_CompunetComments', 'Compunet Comments', 75, '5'

exec usp_AccpacCreateCheckboxField 'PRCompanyInfoProfile', 'prc5_CreditApplication', 'Credit Application'
exec usp_AccpacCreateCheckboxField 'PRCompanyInfoProfile', 'prc5_CreditPolicy', 'Credit Policy'

exec usp_AccpacCreateSelectField 'PRCompanyInfoProfile', 'prc5_NewSaleCreditApprover', 'New Sale Credit Approver', 'prc5_Approver' 
exec usp_AccpacCreateSelectField 'PRCompanyInfoProfile', 'prc5_CreditIncreaseApprover', 'Credit Increase Approver', 'prc5_Approver' 
exec usp_AccpacCreateSelectField 'PRCompanyInfoProfile', 'prc5_CreditCutoffApprover', 'Credit Cutoff Approver', 'prc5_Approver' 
exec usp_AccpacCreateSelectField 'PRCompanyInfoProfile', 'prc5_NoPayApprover', 'No Pay Approver', 'prc5_Approver' 
exec usp_AccpacCreateMultilineField 'PRCompanyInfoProfile', 'prc5_CreditComments', 'Credit Comments', 75, '5'



exec usp_AccpacCreateSelectField 'PRCompanyInfoProfile', 'prc5_AccountingSoftware', 'Actg Software', 'prc5_AccountingSoftware' 
exec usp_AccpacCreateTextField 'PRCompanyInfoProfile', 'prc5_OtherActgSoftware', 'Other Actg Software', 50
exec usp_AccpacCreateAdvSearchSelectField 'PRCompanyInfoProfile', 'prc5_ARAgingImportFormatID', 'AR Arging Import Format', 'PRARAgingImportFormat', 'praaif_Name'

-- COMPANY LICENSE
exec usp_AccpacCreateTable 'PRCompanyLicense', 'prli', 'prli_CompanyLicenseId'
exec usp_AccpacCreateKeyField 'PRCompanyLicense', 'prli_CompanyLicenseId', 'License Id' 

exec usp_AccpacCreateSearchSelectField 'PRCompanyLicense', 'prli_CompanyId', 'Company', 'Company', 10, '17', NULL, 'Y'
exec usp_AccpacCreateSelectField 'PRCompanyLicense', 'prli_Type', 'Type', 'prli_Type'
exec usp_AccpacCreateTextField 'PRCompanyLicense', 'prli_Number', 'Number', 34
exec usp_AccpacCreateCheckboxField 'PRCompanyLicense', 'prli_Publish', 'Publish'

-- COMPANY PROFILE 
exec usp_AccpacCreateTable 'PRCompanyProfile', 'prcp', 'prcp_CompanyProfileId'
exec usp_AccpacCreateKeyField 'PRCompanyProfile', 'prcp_CompanyProfileId', 'Company Profile Id' 

exec usp_AccpacCreateAdvSearchSelectField 'PRCompanyProfile', 'prcp_CompanyId', 'Company', 'Company', 10, '17', NULL, 'Y'
exec usp_AccpacCreateMultilineField 'PRCompanyProfile', 'prcp_MigratedProfileDescription', 'Migrated Profile Description', 75, 5
exec usp_AccpacCreateSelectField 'PRCompanyProfile', 'prcp_CorporateStructure', 'Corporate Structure', 'prcp_CorporateStructure' 

exec usp_AccpacCreateSelectField 'PRCompanyProfile', 'prcp_Volume', 'Volume', 'prcp_Volume' 
exec usp_AccpacCreateSelectField 'PRCompanyProfile', 'prcp_FTEmployees', 'Full-time Employees', 'NumEmployees' 
exec usp_AccpacCreateSelectField 'PRCompanyProfile', 'prcp_PTEmployees', 'Seasonal Employees', 'NumEmployees' 

exec usp_AccpacCreateIntegerField 'PRCompanyProfile', 'prcp_SrcBuyBrokersPct', 'Buy via<br>Brokers/Dstrs %', 10
exec usp_AccpacCreateIntegerField 'PRCompanyProfile', 'prcp_SrcBuyWholesalePct', 'Buy via<br>Local Wholesalers %', 10
exec usp_AccpacCreateIntegerField 'PRCompanyProfile', 'prcp_SrcBuyShippersPct', 'Buy via<br>Domestic Shippers %', 10
exec usp_AccpacCreateIntegerField 'PRCompanyProfile', 'prcp_SrcBuyExportersPct', 'Buy via<br>International Exporters %', 10
--exec usp_AccpacCreateSelectField 'PRCompanyProfile', 'prcp_SrcBuyExportersRegion', 'Intl Sourcing Region', 'prcp_PRForeignRegion' 
--exec usp_AccpacCreateMultiselectField 'PRCompanyProfile', 'prcp_SrcDomesticRegion', 'Domestic Sourcing Region', 'prcp_PRForeignRegion' 

exec usp_AccpacCreateIntegerField 'PRCompanyProfile', 'prcp_SellBrokersPct', 'Sell via Brokers/Dstrs %', 10
exec usp_AccpacCreateIntegerField 'PRCompanyProfile', 'prcp_SellWholesalePct', 'Sell to Local Wholesalers %', 10
exec usp_AccpacCreateIntegerField 'PRCompanyProfile', 'prcp_SellDomesticBuyersPct', 'Sell to Domestic Buyers %', 10
exec usp_AccpacCreateIntegerField 'PRCompanyProfile', 'prcp_SellExportersPct', 'Sell to Intl Importers %', 10
--exec usp_AccpacCreateSelectField 'PRCompanyProfile', 'prcp_SellExportersRegion', 'Intl Selling Region', 'prcp_PRForeignRegion' 

-- This field only in here for Prototype!!!
exec usp_AccpacCreateCheckboxField 'PRCompanyProfile', 'prcp_SellBuyOthers', 'Buy from other shippers or growers?'

--exec usp_AccpacCreateMultiselectField 'PRCompanyProfile', 'prcp_SellDomesticRegion', 'Domestic Selling Region', 'prcp_PRForeignRegion' 
exec usp_AccpacCreateMultiselectField 'PRCompanyProfile', 'prcp_SellDomesticAccountTypes', 'Domestic Account Types', 'prcp_SellDomesticAccountTypes', 7

exec usp_AccpacCreateIntegerField 'PRCompanyProfile', 'prcp_BkrTakeTitlePct', 'Broker Take Title to Product %', 10
exec usp_AccpacCreateIntegerField 'PRCompanyProfile', 'prcp_BkrTakePossessionPct', 'Broker Take Possession of Product %', 10
exec usp_AccpacCreateIntegerField 'PRCompanyProfile', 'prcp_BkrCollectPct', 'Broker Collect & Remit for Shipper %', 10
exec usp_AccpacCreateCheckboxField 'PRCompanyProfile', 'prcp_BkrTakeFrieght', 'Broker Take Billing on Freight?'
exec usp_AccpacCreateCheckboxField 'PRCompanyProfile', 'prcp_BkrConfirmation', 'Issue Broker Confirmations?'
exec usp_AccpacCreateSelectField 'PRCompanyProfile', 'prcp_BkrReceive', 'Receive Brokerage From', 'prcp_BkrReceive' 
exec usp_AccpacCreateCheckboxField 'PRCompanyProfile', 'prcp_BkrGroundInspections', 'Conduct/Arrange On Ground Inspections?'

exec usp_AccpacCreateIntegerField 'PRCompanyProfile', 'prcp_TrkrDirectHaulsPct', 'Trucker Direct Hauls %', 10
exec usp_AccpacCreateIntegerField 'PRCompanyProfile', 'prcp_TrkrTPHaulsPct', 'Trucker 3rd Party Hauls %', 10
--exec usp_AccpacCreateMultiselectField 'PRCompanyProfile', 'prcp_TrkrDomesticRegion', 'Areas Served', 'prcp_PRForeignRegion' 

exec usp_AccpacCreateIntegerField 'PRCompanyProfile', 'prcp_TrkrProducePct', 'Volume that is Produce %', 10
exec usp_AccpacCreateIntegerField 'PRCompanyProfile', 'prcp_TrkrOtherColdPct', 'Volume that is Non-Produce Refrig/Frozen %', 10
exec usp_AccpacCreateIntegerField 'PRCompanyProfile', 'prcp_TrkrOtherWarmPct', 'Volume that is Non-Produce, Non-Refrig %', 10
exec usp_AccpacCreateCheckboxField 'PRCompanyProfile', 'prcp_TrkrTeams', 'Use Driving Teams?'

exec usp_AccpacCreateSelectField 'PRCompanyProfile', 'prcp_TrkrTrucksOwned', 'Number of Trucks Owned', 'TruckEquip' 
exec usp_AccpacCreateSelectField 'PRCompanyProfile', 'prcp_TrkrTrucksLeased', 'Number of Trucks Leased', 'TruckEquip' 
exec usp_AccpacCreateSelectField 'PRCompanyProfile', 'prcp_TrkrTrailersOwned', 'Number of Trailers Owned', 'TruckEquip' 
exec usp_AccpacCreateSelectField 'PRCompanyProfile', 'prcp_TrkrTrailersLeased', 'Number of Trailers Leased', 'TruckEquip' 
exec usp_AccpacCreateSelectField 'PRCompanyProfile', 'prcp_TrkrPowerUnits', 'Number of Power Units', 'TruckEquip' 
exec usp_AccpacCreateSelectField 'PRCompanyProfile', 'prcp_TrkrReefer', 'Number of Reefer Trailers', 'TruckEquip' 
exec usp_AccpacCreateSelectField 'PRCompanyProfile', 'prcp_TrkrDryVan', 'Number of Dry Van Trailers', 'TruckEquip' 
exec usp_AccpacCreateSelectField 'PRCompanyProfile', 'prcp_TrkrFlatbed', 'Number of Flatbed Trailers', 'TruckEquip' 
exec usp_AccpacCreateSelectField 'PRCompanyProfile', 'prcp_TrkrPiggyback', 'Number of Piggyback Trailers', 'TruckEquip' 
exec usp_AccpacCreateSelectField 'PRCompanyProfile', 'prcp_TrkrTanker', 'Number of Tankers', 'TruckEquip' 
exec usp_AccpacCreateSelectField 'PRCompanyProfile', 'prcp_TrkrContainer', 'Number of Containers', 'TruckEquip' 
exec usp_AccpacCreateSelectField 'PRCompanyProfile', 'prcp_TrkrOther', 'Other Units', 'TruckEquip' 

exec usp_AccpacCreateNumericField 'PRCompanyProfile', 'prcp_TrkrLiabilityAmount', 'Gen. Liability Coverage Amt', 10
exec usp_AccpacCreateMultilineField 'PRCompanyProfile', 'prcp_TrkrLiabilityCarrier', 'Liability Carrier Name/Address', 75, '5'
exec usp_AccpacCreateNumericField 'PRCompanyProfile', 'prcp_TrkrCargoAmount', 'Cargo Insurance Coverage Amt', 10
exec usp_AccpacCreateMultilineField 'PRCompanyProfile', 'prcp_TrkrCargoCarrier', 'Cargo Insurance Carrier Name/Address', 75, '5'

exec usp_AccpacCreateIntegerField  'PRCompanyProfile', 'prcp_StorageWarehouses', 'Number of Warehouses', 10
exec usp_AccpacCreateIntegerField  'PRCompanyProfile', 'prcp_SquareFootage', 'Square Footage', 10
exec usp_AccpacCreateSelectField   'PRCompanyProfile', 'prcp_StorageSF', 'Combined Warehousing Square Ft', 'prcp_StorageSF' 
exec usp_AccpacCreateSelectField   'PRCompanyProfile', 'prcp_StorageCF', 'Combined Warehousing Cubic Ft', 'prcp_StorageCF' 
exec usp_AccpacCreateSelectField   'PRCompanyProfile', 'prcp_StorageBushel', 'Combined Warehousing Size (in Bushels)', 'prcp_StorageBushel' 
exec usp_AccpacCreateSelectField   'PRCompanyProfile', 'prcp_StorageCarlots', 'Combined Warehousing Size (in Carlots)', 'prcp_StorageCarlots' 
exec usp_AccpacCreateCheckboxField 'PRCompanyProfile', 'prcp_ColdStorage', 'Have Climate Controlled/Cold Storage Facilities?'
exec usp_AccpacCreateCheckboxField 'PRCompanyProfile', 'prcp_RipeningStorage', 'Have Ripening Rooms/Facilities?'
exec usp_AccpacCreateCheckboxField 'PRCompanyProfile', 'prcp_HumidityStorage', 'Have Humidity Control Rooms/Facilities?'
exec usp_AccpacCreateCheckboxField 'PRCompanyProfile', 'prcp_AtmosphereStorage', 'Have Cont. Atmosphere (CA) Rooms/Facilities?'
exec usp_AccpacCreateCheckboxField 'PRCompanyProfile', 'prcp_ColdStorageLeased', 'Have Leased Climate Controlled/Cold Storage Facilities?'

exec usp_AccpacCreateCheckboxField 'PRCompanyProfile', 'prcp_HAACP', 'HAACP'
exec usp_AccpacCreateTextField     'PRCompanyProfile', 'prcp_HAACPCertifiedBy', 'HAACP Certified By', 30
exec usp_AccpacCreateCheckboxField 'PRCompanyProfile', 'prcp_QTV', 'QTV'
exec usp_AccpacCreateTextField     'PRCompanyProfile', 'prcp_QTVCertifiedBy', 'QTV Certified By', 30
exec usp_AccpacCreateCheckboxField 'PRCompanyProfile', 'prcp_Organic', 'Certified Organic?'
exec usp_AccpacCreateSelectField   'PRCompanyProfile', 'prcp_OrganicCertifiedBy', 'Certified Organic By', 'prcp_OrganicCertifiedBy'
exec usp_AccpacCreateTextField     'PRCompanyProfile', 'prcp_OtherCertification', 'Other Certification', 30

exec usp_AccpacCreateCheckboxField 'PRCompanyProfile', 'prcp_SellFoodWholesaler', 'Sell Food Wholesaler'
exec usp_AccpacCreateCheckboxField 'PRCompanyProfile', 'prcp_SellRetailGrocery', 'Sell Retail Grocery'
exec usp_AccpacCreateCheckboxField 'PRCompanyProfile', 'prcp_SellInstitutions', 'Sell Institutions'
exec usp_AccpacCreateCheckboxField 'PRCompanyProfile', 'prcp_SellRestaurants', 'Sell Restaurants'
exec usp_AccpacCreateCheckboxField 'PRCompanyProfile', 'prcp_SellMilitary', 'Sell Military'
exec usp_AccpacCreateCheckboxField 'PRCompanyProfile', 'prcp_SellDistributors', 'Sell Distributors'

-- COMPANY RELATIONSHIP
exec usp_AccpacCreateTable 'PRCompanyRelationship', 'prcr', 'prcr_CompanyRelationshipId'
exec usp_AccpacCreateKeyField 'PRCompanyRelationship', 'prcr_CompanyRelationshipId', 'Company Relationship Id' 

-- Both left and right company IDs have the same generic label because they are never displayed together
-- on the same screen.
exec usp_AccpacCreateSearchSelectField 'PRCompanyRelationship', 'prcr_LeftCompanyId', 'Related Company', 'Company', 50, '0', NULL, 'Y'
exec usp_AccpacCreateSearchSelectField 'PRCompanyRelationship', 'prcr_RightCompanyId', 'Related Company', 'Company', 50, '0', NULL, 'Y'
exec usp_AccpacCreateSelectField 'PRCompanyRelationship', 'prcr_Type', 'Type', 'prcr_TypeFilter' 
exec usp_AccpacCreateSelectField 'PRCompanyRelationship', 'prcr_Source', 'Source', 'prcr_Source' 
exec usp_AccpacCreateDateField 'PRCompanyRelationship', 'prcr_EnteredDate', 'Date First Entered'
exec usp_AccpacCreateDateField 'PRCompanyRelationship', 'prcr_LastReportedDate', 'Last Reported Date'
exec usp_AccpacCreateIntegerField 'PRCompanyRelationship', 'prcr_TimesReported', 'Times Reported', 10
exec usp_AccpacCreateDateField 'PRCompanyRelationship', 'prcr_UpdatedDate', 'Date Last Updated'
exec usp_AccpacCreateSelectField 'PRCompanyRelationship', 'prcr_TransactionVolume', 'Txn Volume', 'prcr_TransactionVolume' 
exec usp_AccpacCreateSelectField 'PRCompanyRelationship', 'prcr_TransactionFrequency', 'Txn Frequency', 'prcr_TransactionFrequency' 
exec usp_AccpacCreateNumericField 'PRCompanyRelationship', 'prcr_OwnershipPct', 'Ownership Pct', 10
exec usp_AccpacCreateCheckboxField 'PRCompanyRelationship', 'prcr_Active', 'Active Relationship'
exec usp_AccpacCreateSelectField 'PRCompanyRelationship', 'prcr_OwnershipDescription', 'Ownership Description', 'prcr_OwnershipDescription'  

-- use our CreateField capabilities to make view-defined fields appear normal columns
-- the last parameter ('Y') is for the @SkipColumnCreation value
exec usp_AccpacCreateSelectField 'PRCompanyRelationship', 'prcr_CategoryType', 'Category Type', 'prcr_CategoryType', 'Y', NULL, 'Y', NULL, 'Y'
exec usp_AccpacCreateSelectField 'PRCompanyRelationship', 'prcr_ReportingCompanyType', 'Reporting Company', 'prcr_ReportingCompanyType', 'Y', NULL, 'Y', NULL, 'Y'

-- COMPANY TERMINAL MARKET
exec usp_AccpacCreateTable 'PRCompanyTerminalMarket', 'prct', 'prct_CompanyTerminalMarketId'
exec usp_AccpacCreateKeyField 'PRCompanyTerminalMarket', 'prct_CompanyTerminalMarketId', 'Company Terminal Market Id' 

exec usp_AccpacCreateAdvSearchSelectField 'PRCompanyTerminalMarket', 'prct_CompanyId', 'Company', 'Company', 10, '17', NULL, 'Y'
exec usp_AccpacCreateAdvSearchSelectField 'PRCompanyTerminalMarket', 'prct_TerminalMarketId', 'Terminal Market', 'PRTerminalMarket', 10, '0'



-- *******************  END PRCompany  ****************************************
-- ****************************************************************************



DROP TABLE tAccpacComponentName 

GO

SET NOCOUNT OFF
GO

-- ********************* END TABLE AND FIELD CREATION *************************
