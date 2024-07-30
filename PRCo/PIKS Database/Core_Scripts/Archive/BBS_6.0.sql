-- Expand some company name fields.
EXEC usp_AccpacCreateTextField 'Company', 'comp_PROriginalName', 'Original Name', 50, 100
EXEC usp_AccpacCreateTextField 'Company', 'comp_PROldName1', 'Old Name 1', 50, 100
EXEC usp_AccpacCreateTextField 'Company', 'comp_PROldName2', 'Old Name 2', 50, 100
EXEC usp_AccpacCreateTextField 'Company', 'comp_PROldName3', 'Old Name 3', 50, 100
Go


--
-- Chain Store Guide functionality
---
EXEC usp_AccpacCreateTable @EntityName='PRCSG', @ColPrefix='prcsg', @IDField='prcsg_CSGID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyField          'PRCSG', 'prcsg_CSGID', 'CSG ID'
EXEC usp_AccpacCreateSearchSelectField 'PRCSG', 'prcsg_CompanyID', 'Company', 'Company', 100 
EXEC usp_AccpacCreateTextField         'PRCSG', 'prcsg_CSGCompanyID', 'CSG Company ID', 25, 25
EXEC usp_AccpacCreateIntegerField      'PRCSG', 'prcsg_TotalUnits', 'Total Units'
EXEC usp_AccpacCreateIntegerField      'PRCSG', 'prcsg_TotalSquareFootage', 'Total Selling Square Footage'

EXEC usp_AccpacCreateTable @EntityName='PRCSGData', @ColPrefix='prcsgd', @IDField='prcsgd_CSGDataID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyField          'PRCSGData', 'prcsgd_CSGDataID', 'CSG Data ID'
EXEC usp_AccpacCreateIntegerField      'PRCSGData', 'prcsgd_CSGID', 'CSG ID'
EXEC usp_AccpacCreateTextField         'PRCSGData', 'prcsgd_Value', 'Value', 100, 100
EXEC usp_AccpacCreateSelectField       'PRCSGData', 'prcsgd_TypeCode', 'Type Code', 'prcsgd_TypeCode'
Go

--
--  Widget Functionality
--
EXEC usp_AccpacCreateTable @EntityName='PRWidgetAuditTrail', @ColPrefix='prwat', @IDField='prwat_WidgetAuditTrailID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyField          'PRWidgetAuditTrail', 'prwat_WidgetAuditTrailID', 'Widget Audit Trail ID'
EXEC usp_AccpacCreateSearchSelectField 'PRWidgetAuditTrail', 'prwat_SubjectCompanyID', 'Subject Company', 'Company', 100 
EXEC usp_AccpacCreateIntegerField      'PRWidgetAuditTrail', 'prwat_WidgetKeyID', 'WidgetKeyID'
EXEC usp_AccpacCreateTextField         'PRWidgetAuditTrail', 'prwat_LandingApplication', 'Landing Application', 100, 100
EXEC usp_AccpacCreateTextField         'PRWidgetAuditTrail', 'prwat_IPAddress', 'IP Address', 50, 50
Go

--
-- MAS Functionality
--
EXEC usp_AccpacCreateTable @EntityName='PRChangeDetection', @ColPrefix='prchngd', @IDField='prchngd_ChangeDetectionID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyField          'PRChangeDetection', 'prchngd_ChangeDetectionID', 'Change Detection ID'
EXEC usp_AccpacCreateSearchSelectField 'PRChangeDetection', 'prchngd_CompanyID', 'Company', 'Company', 100 
EXEC usp_AccpacCreateIntegerField      'PRChangeDetection', 'prchngd_AssociatedID', 'Associated ID'
EXEC usp_AccpacCreateTextField         'PRChangeDetection', 'prchngd_AssociatedType', 'Associated Type', 40, 40
EXEC usp_AccpacCreateSelectField       'PRChangeDetection', 'prchngd_ChangeType', 'Change Type', 'prchngd_ChangeType'


EXEC usp_AccpacCreateTable             'PRCompanyIndicators', 'prci2', 'prci2_CompanyIndicatorID'
EXEC usp_AccpacCreateKeyField          'PRCompanyIndicators', 'prci2_CompanyIndicatorID', 'Company Indicator ID'
EXEC usp_AccpacCreateSearchSelectField 'PRCompanyIndicators', 'prci2_CompanyID', 'Company', 'Company', 100, '0', 'N', 'Y' 
EXEC usp_AccpacCreateTextField         'PRCompanyIndicators', 'prci2_TaxCode', 'MAS Tax Code', 40, 40
EXEC usp_AccpacCreateSelectField       'PRCompanyIndicators', 'prci2_CustomerCategory', 'Customer Category', 'prci_CustomerCategory'
EXEC usp_AccpacCreateCheckboxField     'PRCompanyIndicators', 'prci2_TaxExempt', 'Tax Exempt'
EXEC usp_AccpacCreateCheckboxField     'PRCompanyIndicators', 'prci2_DoNotSuspend', 'Do Not Suspend'
EXEC usp_AccpacCreateCheckboxField     'PRCompanyIndicators', 'prci2_BillingException', 'Billing Exception'
EXEC usp_AccpacCreateCheckboxField     'PRCompanyIndicators', 'prci2_Suspended', 'Suspended'
EXEC usp_AccpacCreateCheckboxField     'PRCompanyIndicators', 'prci2_SuspensionPending', 'Suspension Pending'

EXEC usp_AccpacCreateCheckboxField     'PRAttentionLine', 'prattn_IncludeWireTransferInstructions', 'Include Wire Transfer Instructions'


ALTER TABLE PRCompanyIndicators ALTER COLUMN prci2_CompanyID int not null

DECLARE @SQL VARCHAR(4000)
SET @SQL = 'ALTER TABLE PRCompanyIndicators DROP CONSTRAINT |ConstraintName| '
SET @SQL = REPLACE(@SQL, '|ConstraintName|', ( SELECT name FROM sysobjects WHERE xtype = 'PK' AND parent_obj = OBJECT_ID('PRCompanyIndicators')))
EXEC (@SQL)

ALTER TABLE [dbo].[PRCompanyIndicators] ADD CONSTRAINT PK_PRCompanyIndicators PRIMARY KEY NONCLUSTERED (prci2_CompanyID)




EXEC usp_AccpacCreateSelectField 'PRShipmentLog', 'prshplg_Type', 'Shipment Type', 'prshplg_Type'

EXEC usp_AccpacCreateTable @EntityName='PRShipmentLogDetail', @ColPrefix='prshplgd', @IDField='prshplgd_ShipmentLogDetailID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyField          'PRShipmentLogDetail', 'prshplgd_ShipmentLogDetailID', 'Shipment Log Detail ID'
EXEC usp_AccpacCreateIntegerField      'PRShipmentLogDetail', 'prshplgd_ShipmentLogID', 'Shipment Log ID'
EXEC usp_AccpacCreateSelectField       'PRShipmentLogDetail', 'prshplgd_ItemCode', 'Item Code', 'prshplgd_ItemCode'


EXEC usp_AccpacDropTable 'PRTaxRate'
EXEC usp_AccpacCreateTable @EntityName='PRTaxRate', @ColPrefix='prtax', @IDField='prtax_TaxRateID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyField          'PRTaxRate', 'prtax_TaxRateID', 'Tax Rate ID'
EXEC usp_AccpacCreateTextField         'PRTaxRate', 'prtax_PostalCode', 'Postal Code', 5, 5
EXEC usp_AccpacCreateTextField         'PRTaxRate', 'prtax_County', 'County', 30, 30
EXEC usp_AccpacCreateTextField         'PRTaxRate', 'prtax_City', 'City', 50, 50
EXEC usp_AccpacCreateTextField         'PRTaxRate', 'prtax_State', 'State', 2, 2
EXEC usp_AccpacCreateTextField         'PRTaxRate', 'prtax_TaxCode', 'TaxCode', 9, 9



EXEC usp_AccpacDropView 'vAUSSubscriber'
EXEC usp_AccpacCreateDropdownValue 'AccountingExportLastRunDate', 'Jan  1 2012  12:01AM', 0, 'Accounting Export Last Run Date/Time'

--
-- Make a backup of the PRService table.
--
IF EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='PRService') BEGIN

	IF EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='PRService_Backup') DROP TABLE PRService_Backup;
	SELECT * INTO PRService_Backup FROM PRService
	
	DROP TABLE PRService
END	

IF EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='PRServicePayment') BEGIN
	IF EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='PRServicePayment_Backup') DROP TABLE PRServicePayment_Backup;
	SELECT * INTO PRServicePayment_Backup FROM PRServicePayment
	
	DROP TABLE PRServicePayment
END	

Go


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_ConvertPersonLinkToBBOS]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[usp_ConvertPersonLinkToBBOS]
GO

IF EXISTS (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AssociateWebUserToPersonLink]'))
    drop procedure [dbo].[usp_AssociateWebUserToPersonLink]
GO

EXEC usp_AccpacDropView 'vPRCaseServiceInfo'

EXEC usp_DeleteCustom_ScreenObject 'PRCaseServicesGrid'
EXEC usp_AddCustom_ScreenObjects 'PRCaseServicesGrid', 'List', 'PRService', 'N', 0, 'PRService'
EXEC usp_AddCustom_Lists 'PRCaseServicesGrid', 10, 'prse_ServiceCode', null, 'Y'
EXEC usp_AddCustom_Lists 'PRCaseServicesGrid', 20, 'ItemCodeDesc', null, 'Y'
EXEC usp_AddCustom_Lists 'PRCaseServicesGrid', 30, 'QuantityOrdered', null, 'Y', null, 'RIGHT'

EXEC usp_AddCustom_Captions 'Tags', 'ColNames', 'ItemCodeDesc', 0, 'Service Description'
EXEC usp_AddCustom_Captions 'Tags', 'ColNames', 'QuantityOrdered', 0, 'Quantity'

Go

EXEC usp_AccpacCreateField @EntityName = 'Company', 
                           @FieldName = 'UDF_MASTER_INVOICE', 
                           @Caption = 'Invoice Number',
                           @AccpacEntryType = 10,
                           @AccpacEntrySize = 50,
                           @IsRequired = 'N', 
                           @SkipColumnCreation = 'Y';
                           
EXEC usp_DeleteCustom_Screen 'CompanyAdvancedSearchBox', 'prse_ServiceID'
EXEC usp_AddCustom_Screens 'CompanyAdvancedSearchBox', 110, 'UDF_MASTER_INVOICE', 1, 1, 1;
Go


EXEC usp_DeleteCustom_ScreenObject 'PRServiceGrid'
EXEC usp_DeleteCustom_ScreenObject 'PRServicesThrough'

EXEC usp_DeleteCustom_ScreenObject 'PRBillingInfo'
EXEC usp_AddCustom_ScreenObjects 'PRBillingInfo', 'Screen', 'PRCompanyIndicators', 'N', 0, 'PRCompanyIndicators'
EXEC usp_AddCustom_Screens 'PRBillingInfo', 10, 'prci2_TaxCode',          1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRBillingInfo', 20, 'prci2_CustomerCategory', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRBillingInfo', 30, 'prci2_TaxExempt',        1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRBillingInfo', 40, 'prci2_BillingException', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRBillingInfo', 50, 'prci2_DoNotSuspend',     1, 1, 1, 0


EXEC usp_DeleteCustom_ScreenObject 'PRRepeatOrderInfo'
EXEC usp_AddCustom_ScreenObjects 'PRRepeatOrderInfo', 'Screen', 'vPRRepeatOrders', 'N', 0, 'vPRRepeatOrders'
EXEC usp_AddCustom_Screens 'PRRepeatOrderInfo', 10, 'CycleCode',        1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRRepeatOrderInfo', 20, 'InvoiceDate',      0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRRepeatOrderInfo', 30, 'AmtInvoiced',      0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRRepeatOrderInfo', 40, 'EnteredCompanyID', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRRepeatOrderInfo', 50, 'TermsCode',        0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRRepeatOrderInfo', 60, 'AmtDue',           0, 1, 1, 0

EXEC usp_AddCustom_Captions 'Tags', 'ColNames', 'CycleCode', 0, 'Billing Month'
EXEC usp_AddCustom_Captions 'Tags', 'ColNames', 'AmtInvoiced', 0, 'Amount Billed'
EXEC usp_AddCustom_Captions 'Tags', 'ColNames', 'TermsCode', 0, 'Terms Code'

EXEC usp_AccpacCreateField @EntityName = 'vPRRepeatOrders', 
                           @FieldName = 'EnteredCompanyID', 
                           @Caption = 'Order Location',
                           @AccpacEntryType = 26,
                           @AccpacEntrySize = 100,
                           @DBFieldType = 'int',
                           @DBFieldSize = NULL,
                           @LookupFamily = 'PRCompanySearch',
                           @SearchValue =  '0',
                           @AllowNull = 'Y',
                           @IsRequired = 'N', 
                           @AllowEdit = 'Y', 
                           @IsUnique = 'N',
                           @SkipColumnCreation = 'Y'
Go                           


EXEC usp_DeleteCustom_ScreenObject 'PRStandardOrderGrid'
EXEC usp_AddCustom_ScreenObjects 'PRStandardOrderGrid', 'List', 'vPRStandardOrders', 'N', 0, 'vPRStandardOrders'
EXEC usp_AddCustom_Lists 'PRStandardOrderGrid', 10, 'Service', null, 'Y'
EXEC usp_AddCustom_Lists 'PRStandardOrderGrid', 20, 'InvoiceDate', null, 'Y'
EXEC usp_AddCustom_Lists 'PRStandardOrderGrid', 30, 'AmtInvoiced', null, 'Y', null, 'RIGHT'
EXEC usp_AddCustom_Lists 'PRStandardOrderGrid', 40, 'AmtDue', null, 'Y', null, 'RIGHT'

EXEC usp_DefineCaptions 'vPRStandardOrders', 'Standard Order', 'Standard Orders', null, null, null, null

EXEC usp_AddCustom_Captions 'Tags', 'ColNames', 'AmtDue', 0, 'Amt Due'
EXEC usp_AccpacCreateField @EntityName = 'vPRStandardOrders', 
                           @FieldName = 'InvoiceDate', 
                           @Caption = 'Invoice Date',
                           @AccpacEntryType = 42,
                           @AccpacEntrySize = 0,
                           @DBFieldType = 'datetime',
                           @DBFieldSize = NULL,
                           @AllowNull = 'Y',
                           @IsRequired = 'N', 
                           @AllowEdit = 'Y', 
                           @IsUnique = 'N',
                           @SkipColumnCreation = 'Y'
                           
/*
EXEC usp_DeleteCustom_ScreenObject 'PRServicePaymentGrid'
EXEC usp_AddCustom_ScreenObjects 'PRServicePaymentGrid', 'List', 'vPRServicePayment', 'N', 0, 'vPRServicePayment'
EXEC usp_AddCustom_Lists 'PRServicePaymentGrid', 10, 'UDF_MASTER_INVOICE', null, 'Y'
EXEC usp_AddCustom_Lists 'PRServicePaymentGrid', 20, 'InvoiceDate', null, 'Y'
EXEC usp_AddCustom_Lists 'PRServicePaymentGrid', 30, 'AmtInvoiced', null, 'Y', null, 'RIGHT'
EXEC usp_AddCustom_Lists 'PRServicePaymentGrid', 40, 'TransactionAmt', null, 'Y', null, 'RIGHT'
EXEC usp_AddCustom_Lists 'PRServicePaymentGrid', 50, 'TransactionDate', null, 'Y', null

EXEC usp_DefineCaptions 'vPRServicePayment', 'Payment History', 'Payment History', null, null, null, null
EXEC usp_AddCustom_Captions 'Tags', 'ColNames', 'TransactionAmt', 0, 'Transaction Amt'
--EXEC usp_AddCustom_Captions 'Tags', 'ColNames', 'TransactionDate', 0, 'Transaction Date'
EXEC usp_AccpacCreateField @EntityName = 'vPRServicePayment', 
                             @FieldName = 'TransactionDate', 
                             @Caption = 'Transaction Date',
                             @AccpacEntryType = 42,
                             @AccpacEntrySize = 0,
                             @DBFieldType = 'datetime',
                             @DBFieldSize = NULL,
                             @DefaultValue = NULL,
                             @AllowNull = 'Y',
                             @IsRequired = 'N', 
                             @AllowEdit = 'Y', 
                             @IsUnique = 'N',
                             @SkipColumnCreation = 'Y'      
*/

Go


EXEC usp_AccpacCreateTextField 'PRWebUser', 'prwu_ServiceCode', 'Service Code', 40, 40
EXEC usp_AccpacCreateTextField 'PRWebUser', 'prwu_PreviousServiceCode', 'Previous Service Code', 40, 40

EXEC usp_AddCustom_Lists 'PRWebUserGrid', 30, 'IsMember', '', 'Y', null, 'CENTER'
EXEC usp_AddCustom_Lists 'PRWebUserGrid', 40, 'IsTrial', '', 'Y', null, 'CENTER'
EXEC usp_AddCustom_Lists 'PRWebUserGrid', 50, 'prwu_LastLoginDateTime', '', 'Y', null, 'CENTER'
EXEC usp_AddCustom_Lists 'PRWebUserGrid', 60, 'prwu_LoginCount', '', 'Y', null, 'RIGHT'
EXEC usp_AddCustom_Lists 'PRWebUserGrid', 70, 'prwu_Disabled', '', 'Y', null, 'CENTER'
Go

EXEC usp_DeleteCustom_List 'PRCompanyAttentionLineGrid', 'prattn_ServiceID'
UPDATE Custom_Lists
   SET grip_DefaultOrderBy = 'Y'
 WHERE grip_GridName = 'PRCompanyAttentionLineGrid'
   AND grip_ColName = 'prattn_ItemCode';
Go     


EXEC usp_AccpacCreateMultilineField 'PRShipmentLog', 'prshplg_MailRoomComments', 'Mail Room Comments', 50

EXEC usp_DeleteCustom_ScreenObject 'PRShipmentLogGrid'
EXEC usp_AddCustom_ScreenObjects 'PRShipmentLogGrid', 'List', 'PRShipmentLog', 'N', 0, 'vPRShipmentLogDetails'
EXEC usp_AddCustom_Lists 'PRShipmentLogGrid', 10, 'prshplg_CreatedDate', null, 'Y', 'Y'
EXEC usp_AddCustom_Lists 'PRShipmentLogGrid', 20, 'ItemList', null, 'Y'
EXEC usp_AddCustom_Lists 'PRShipmentLogGrid', 30, 'prshplg_Addressee', null, 'Y'
EXEC usp_AddCustom_Lists 'PRShipmentLogGrid', 40, 'prshplg_DeliveryAddress', null, 'Y'
EXEC usp_AddCustom_Lists 'PRShipmentLogGrid', 50, 'prshplg_CarrierCode', null, 'Y'
EXEC usp_AddCustom_Lists 'PRShipmentLogGrid', 60, 'prshplg_TrackingNumber', null, 'Y', null, null, 'Custom', '', '', 'javascript:SomeFunction();', 'prshplg_TrackingNumber'




EXEC usp_DeleteCustom_ScreenObject 'PRShipmentLogQueueGrid'
EXEC usp_AddCustom_ScreenObjects 'PRShipmentLogQueueGrid', 'List', 'vPRShipmentLogQueue', 'N', 0, 'vPRShipmentLogQueue'
EXEC usp_AddCustom_Lists 'PRShipmentLogQueueGrid', 10, 'ShipmentLogID', null, 'Y', null, 'CENTER', 'Custom', '', '', 'PRGeneral/ShipmentLogEdit.asp', 'ShipmentLogID'
EXEC usp_AddCustom_Lists 'PRShipmentLogQueueGrid', 20, 'prshplg_CreatedDate', null, 'Y', null, 'CENTER'
EXEC usp_AddCustom_Lists 'PRShipmentLogQueueGrid', 30, 'ItemList', null, 'Y'
EXEC usp_AddCustom_Lists 'PRShipmentLogQueueGrid', 40, 'Addressee', null, 'Y'
EXEC usp_AddCustom_Lists 'PRShipmentLogQueueGrid', 50, 'DeliveryAddress', null, 'Y'

EXEC usp_DefineCaptions 'vPRShipmentLogQueue', 'Shipping Queue', 'Shipping Queue', null, null, null, null
EXEC usp_AddCustom_Captions 'Tags', 'ColNames', 'ShipmentLogID', 0, 'Shipment ID'
EXEC usp_AddCustom_Captions 'Tags', 'ColNames', 'ItemList', 0, 'Item(s)'
UPDATE Custom_Lists
   SET grip_DefaultOrderBy = 'Y'
 WHERE grip_GridName = 'PRShipmentLogQueueGrid'
   AND grip_ColName = 'prshplg_CreatedDate';
   
EXEC usp_AddCustom_Tabs 51, 'find', 'Shipment Log Queue', 'customfile', 'PRGeneral/ShipmentLogQueue.asp'   


EXEC usp_DeleteCustom_ScreenObject 'PRShipmentLogQueue'
EXEC usp_AddCustom_ScreenObjects 'PRShipmentLogQueue', 'Screen', 'vPRShipmentLogQueue', 'N', 0, 'vPRShipmentLogQueue'
EXEC usp_AddCustom_Screens 'PRShipmentLogQueue', 10, 'ShipmentLogID',   1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRShipmentLogQueue', 20, 'Addressee',       0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRShipmentLogQueue', 30, 'ItemList',        1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRShipmentLogQueue', 40, 'DeliveryAddress', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRShipmentLogQueue', 50, 'prshplg_MailRoomComments', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRShipmentLogQueue', 60, 'prshplg_CarrierCode',    1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRShipmentLogQueue', 70, 'prshplg_TrackingNumber', 0, 1, 1, 0
Go

EXEC usp_AddCustom_Tabs 52, 'find', 'Generate Invoices', 'customfile', 'PRGeneral/GenerateInvoicesRedirect.asp'   
Go


ALTER TABLE Company ALTER COLUMN comp_PRUnloadHours varchar(max)
Go


--
--  Sales Management Functionality
--
EXEC usp_DefineCaptions 'vPROpportunityListingBBOSInq', 'BBOS Inquiry Opportunity', 'BBOS Inquiry Opportunities', 'oppo_Opened', 'oppo_opportunityid', NULL, NULL   

EXEC usp_DeleteCustom_ScreenObject 'PROpportunityGridBBOSInquiry'
EXEC usp_AddCustom_ScreenObjects 'PROpportunityGridBBOSInquiry', 'List', 'vPROpportunityListingBBOSInq', 'N', 0, 'vPROpportunityListingBBOSInq'
EXEC usp_AddCustom_Lists 'PROpportunityGridBBOSInquiry', 10, 'oppo_Opened', null, 'Y', 'Y', '', 'Custom', '', '', 'PROpportunity/PROpportunityRedirect.asp', 'oppo_opportunityid'
EXEC usp_AddCustom_Lists 'PROpportunityGridBBOSInquiry', 20, 'prwu_Email', null, 'Y'
EXEC usp_AddCustom_Lists 'PROpportunityGridBBOSInquiry', 30, 'PersonName', null, 'Y'
EXEC usp_AddCustom_Lists 'PROpportunityGridBBOSInquiry', 40, 'prwu_CompanyName', null, 'Y'
EXEC usp_AddCustom_Lists 'PROpportunityGridBBOSInquiry', 50, 'CityStateCountryShort', null, 'Y'
EXEC usp_AddCustom_Lists 'PROpportunityGridBBOSInquiry', 60, 'OppoStage', null, 'Y'
EXEC usp_AddCustom_Lists 'PROpportunityGridBBOSInquiry', 70, 'Oppo_PRType', null, 'Y'
EXEC usp_AddCustom_Lists 'PROpportunityGridBBOSInquiry', 80, 'oppo_PRCertainty', null, 'Y'


EXEC usp_DeleteCustom_ScreenObject 'PROpportunitySearchBoxBBOSInquiry'
EXEC usp_AddCustom_ScreenObjects 'PROpportunitySearchBoxBBOSInquiry', 'SearchScreen', 'Opportunity', 'N', 0, 'vPROpportunityListingBBOSInq'
EXEC usp_AddCustom_Screens 'PROpportunitySearchBoxBBOSInquiry', 10, 'oppo_Opened', 1, 2, 1, 0
EXEC usp_AddCustom_Screens 'PROpportunitySearchBoxBBOSInquiry', 20, 'prwu_Email', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PROpportunitySearchBoxBBOSInquiry', 30, 'PersonName', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PROpportunitySearchBoxBBOSInquiry', 40, 'prwu_CompanyName', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PROpportunitySearchBoxBBOSInquiry', 50, 'CityStateCountryShort', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PROpportunitySearchBoxBBOSInquiry', 60, 'OppoStage', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PROpportunitySearchBoxBBOSInquiry', 70, 'Oppo_PRType', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PROpportunitySearchBoxBBOSInquiry', 80, 'oppo_PRCertainty', 0, 1, 1, 0
Go


--
--  Reorganized the fields on Email, Phone, and Address to be consistent between
--  each other.  These blocks are now added to the New Company page.
--
EXEC usp_DeleteCustom_ScreenObject 'EmailNewEntry'
EXEC usp_AddCustom_ScreenObjects 'EmailNewEntry', 'Screen', 'Email', 'N', 0, 'Email'
EXEC usp_AddCustom_Screens 'EmailNewEntry', 10, 'emai_CompanyID', 1, 1, 4, 0
EXEC usp_AddCustom_Screens 'EmailNewEntry', 20, 'emai_Type', 1, 1, 2, 0
EXEC usp_AddCustom_Screens 'EmailNewEntry', 30, 'emai_PRDescription', 0, 1, 3, 0
EXEC usp_AddCustom_Screens 'EmailNewEntry', 40, 'emai_EmailAddress', 1, 1, 2, 0
EXEC usp_AddCustom_Screens 'EmailNewEntry', 50, 'emai_PRWebAddress', 0, 1, 2, 0
EXEC usp_AddCustom_Screens 'EmailNewEntry', 60, 'emai_PRPublish', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'EmailNewEntry', 70, 'emai_PRPreferredPublished', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'EmailNewEntry', 80, 'emai_PRPreferredInternal', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'EmailNewEntry', 90, 'emai_PRSequence', 0, 1, 1, 0

EXEC usp_DeleteCustom_ScreenObject 'EmailCompanyNewEntry'
EXEC usp_AddCustom_ScreenObjects 'EmailCompanyNewEntry', 'Screen', 'Email', 'N', 0, 'Email'
EXEC usp_AddCustom_Screens 'EmailCompanyNewEntry', 10, 'emai_PRWebAddress', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'EmailCompanyNewEntry', 20, 'emai_PRPublish', 1, 1, 1, 0



EXEC usp_DeleteCustom_ScreenObject 'PhoneNewEntry'
EXEC usp_AddCustom_ScreenObjects 'PhoneNewEntry', 'Screen', 'vPRPhone', 'N', 0, 'vPRPhone'
EXEC usp_AddCustom_Screens 'PhoneNewEntry', 10, 'phon_CompanyID', 1, 1, 5, 0
EXEC usp_AddCustom_Screens 'PhoneNewEntry', 20, 'phon_Type', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PhoneNewEntry', 30, 'phon_PRDescription', 0, 1, 4, 0
EXEC usp_AddCustom_Screens 'PhoneNewEntry', 40, 'phon_CountryCode', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PhoneNewEntry', 50, 'phon_AreaCode', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PhoneNewEntry', 65, 'phon_Number', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PhoneNewEntry', 70, 'phon_PRExtension', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PhoneNewEntry', 80, 'phon_PRPublish', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PhoneNewEntry', 90, 'phon_PRPreferredPublished', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PhoneNewEntry', 100, 'phon_PRPreferredInternal', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PhoneNewEntry', 110, 'phon_PRDisconnected', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PhoneNewEntry', 120, 'phon_PRSequence', 0, 1, 1, 0


EXEC usp_DeleteCustom_ScreenObject 'PhoneCompanyNewEntry'
EXEC usp_AddCustom_ScreenObjects 'PhoneCompanyNewEntry', 'Screen', 'Phone', 'N', 0, 'Phone'
EXEC usp_AddCustom_Screens 'PhoneCompanyNewEntry', 10, 'phon_CountryCode', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PhoneCompanyNewEntry', 20, 'phon_AreaCode', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PhoneCompanyNewEntry', 35, 'phon_Number', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PhoneCompanyNewEntry', 40, 'phon_PRExtension', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PhoneCompanyNewEntry', 50, 'phon_PRPublish', 1, 1, 1, 0



EXEC usp_DeleteCustom_ScreenObject 'PRAddressNewEntry'
EXEC usp_AddCustom_ScreenObjects 'PRAddressNewEntry', 'Screen', 'Address', 'N', 0, 'vPRAddress'
EXEC usp_AddCustom_Screens 'PRAddressNewEntry', 10, 'adli_Type', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRAddressNewEntry', 20, 'addr_PRDescription', 1, 1, 3, 0
EXEC usp_AddCustom_Screens 'PRAddressNewEntry', 30, 'addr_Address1', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRAddressNewEntry', 40, 'addr_Address2', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRAddressNewEntry', 50, 'addr_Address3', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRAddressNewEntry', 60, 'addr_Address4', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRAddressNewEntry', 70, 'addr_PRCityID', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRAddressNewEntry', 80, 'addr_PostCode', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRAddressNewEntry', 90, 'addr_PRCounty', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRAddressNewEntry', 100, 'addr_PRPublish', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRAddressNewEntry', 110, 'adli_PRDefaultMailing', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRAddressNewEntry', 120, 'adli_PRDefaultTax', 0, 1, 1, 0


EXEC usp_DeleteCustom_ScreenObject 'PRCompanyAddressNew'
EXEC usp_AddCustom_ScreenObjects 'PRCompanyAddressNew', 'Screen', 'Address', 'N', 0, 'Address'
EXEC usp_AddCustom_Screens 'PRCompanyAddressNew', 30, 'addr_Address1', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCompanyAddressNew', 40, 'addr_Address2', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCompanyAddressNew', 50, 'addr_Address3', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCompanyAddressNew', 60, 'addr_Address4', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCompanyAddressNew', 70, 'addr_PRCityID', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCompanyAddressNew', 80, 'addr_PostCode', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCompanyAddressNew', 90, 'addr_PRCounty', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCompanyAddressNew', 100, 'addr_PRPublish', 1, 1, 1, 0

UPDATE Custom_edits
   SET colp_EntrySize = 40
 WHERE colp_ColName IN ('addr_Address1', 'addr_Address2', 'addr_Address3', 'addr_Address4');
 
DECLARE @NextId int 

EXEC @NextId = crm_next_id 44 -- custom_edits key
INSERT INTO Custom_Edits
		(ColP_ColPropsId, ColP_ColName, ColP_Entity, ColP_EntryType, ColP_EntrySize, 
		 colp_CreatedDate,colp_TimeStamp,colp_UpdatedDate)  
VALUES (@NextId, 'addr_Address2', 'Address', 10, 40,
		 GETDATE(),GETDATE(),GETDATE())

EXEC @NextId = crm_next_id 44 -- custom_edits key
INSERT INTO Custom_Edits
		(ColP_ColPropsId, ColP_ColName, ColP_Entity, ColP_EntryType, ColP_EntrySize, 
		 colp_CreatedDate,colp_TimeStamp,colp_UpdatedDate)  
VALUES (@NextId, 'addr_Address3', 'Address', 10, 40,
		 GETDATE(),GETDATE(),GETDATE())

EXEC @NextId = crm_next_id 44 -- custom_edits key
INSERT INTO Custom_Edits
		(ColP_ColPropsId, ColP_ColName, ColP_Entity, ColP_EntryType, ColP_EntrySize, 
		 colp_CreatedDate,colp_TimeStamp,colp_UpdatedDate)  
VALUES (@NextId, 'addr_Address4', 'Address', 10, 40,
		 GETDATE(),GETDATE(),GETDATE())
Go		 


EXEC usp_AccpacCreateTextField 'PRPersonBackground', 'prba_Company', 'Company', 50, 500
Go

EXEC usp_AccpacCreateCheckboxField 'PRWebUser', 'prwu_EmailPurchases', 'Email Purchases'
EXEC usp_AccpacCreateCheckboxField 'PRWebUser', 'prwu_CompressEmailedPurchases', 'Zip Emailed Purchases'
Go

EXEC usp_AccpacCreateTable @EntityName='PRHoliday', @ColPrefix='prhldy', @IDField='prhldy_HolidayID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyField          'PRHoliday', 'prhldy_HolidayID', 'Holiday ID'
EXEC usp_AccpacCreateDateField         'PRHoliday', 'prhldy_Date', 'Date'
EXEC usp_AccpacCreateTextField         'PRHoliday', 'prhldy_Description', 'Description', 50, 50
EXEC usp_AccpacCreateSelectField       'PRHoliday', 'prhldy_TypeCode', 'Type Code', 'prhldy_TypeCode'
Go


--
--  NHA and Training Functionality
--
EXEC usp_AccpacCreateTextField   'PRPublicationArticle', 'prpbar_Length', 'Length (mm:ss)', 25, 25
EXEC usp_AccpacCreateSelectField 'PRPublicationArticle', 'prpbar_MediaTypeCode', 'Media Type', 'prpbar_MediaTypeCode'
Go



EXEC usp_DeleteCustom_ScreenObject 'PPRNewsArticleSearchBox'
EXEC usp_AddCustom_ScreenObjects 'PPRNewsArticleSearchBox', 'SearchScreen', 'PRPublicationArticle', 'N', 0, 'PRPublicationArticle'
EXEC usp_AddCustom_Screens 'PPRNewsArticleSearchBox', 10, 'prpbar_Name', 1, 1, 1
EXEC usp_AddCustom_Screens 'PPRNewsArticleSearchBox', 20, 'prpbar_CategoryCode', 0, 1, 1
EXEC usp_AddCustom_Screens 'PPRNewsArticleSearchBox', 30, 'prpbar_PublishDate', 1, 1, 1
EXEC usp_AddCustom_Screens 'PPRNewsArticleSearchBox', 40, 'prpbar_IndustryTypeCode', 0, 2, 1
EXEC usp_AddCustom_Screens 'PPRNewsArticleSearchBox', 50, 'prpbar_ExpirationDate', 1, 1, 1
Go


EXEC usp_DeleteCustom_ScreenObject 'PRTrainingSearchBox'
EXEC usp_AddCustom_ScreenObjects 'PRTrainingSearchBox', 'SearchScreen', 'PRPublicationArticle', 'N', 0, 'PRPublicationArticle'
EXEC usp_AddCustom_Screens 'PRTrainingSearchBox', 10, 'prpbar_Name', 1, 1, 1
EXEC usp_AddCustom_Screens 'PRTrainingSearchBox', 20, 'prpbar_MediaTypeCode', 0, 1, 1
EXEC usp_AddCustom_Screens 'PRTrainingSearchBox', 30, 'prpbar_PublishDate', 1, 1, 1
EXEC usp_AddCustom_Screens 'PRTrainingSearchBox', 40, 'prpbar_IndustryTypeCode', 0, 1, 1
Go

EXEC usp_DeleteCustom_ScreenObject 'PRTrainingGrid'
EXEC usp_AddCustom_ScreenObjects 'PRTrainingGrid', 'List', 'PRPublicationArticle', 'N', 0, 'PRPublicationArticle'
EXEC usp_AddCustom_Lists 'PRTrainingGrid', 10, 'prpbar_MediaTypeCode', null, 'Y'
EXEC usp_AddCustom_Lists 'PRTrainingGrid', 20, 'prpbar_Sequence', null, 'Y'
EXEC usp_AddCustom_Lists 'PRTrainingGrid', 30, 'prpbar_Name', null, 'Y', 'Y', '', 'Custom', '', '', 'PRPublication/PRTraining.asp', 'prpbar_PublicationArticleID'
EXEC usp_AddCustom_Lists 'PRTrainingGrid', 40, 'prpbar_IndustryTypeCode', null, 'Y'
EXEC usp_AddCustom_Lists 'PRTrainingGrid', 50, 'prpbar_PublishDate', null, 'Y'
UPDATE custom_lists SET grip_DefaultOrderBy = 'Y' WHERE grip_GridName = 'PRTrainingGrid' AND grip_ColName='prpbar_MediaTypeCode';
EXEC usp_AddCustom_Tabs 16, 'find', 'BBOS Training', 'customfile', 'PRPublication/PRTrainingArticleListing.asp'   

EXEC usp_DeleteCustom_ScreenObject 'PRPATraining'
EXEC usp_AddCustom_ScreenObjects 'PRPATraining', 'Screen', 'PRPublicationArticle', 'N', 0, 'PRPublicationArticle'
EXEC usp_AddCustom_Screens 'PRPATraining', 10, 'prpbar_Name',             1, 1, 2, 0
EXEC usp_AddCustom_Screens 'PRPATraining', 20, 'prpbar_Sequence',         0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRPATraining', 30, 'prpbar_Abstract',         1, 1, 3, 0
EXEC usp_AddCustom_Screens 'PRPATraining', 40, 'prpbar_PublishDate',      1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRPATraining', 50, 'prpbar_MediaTypeCode',    0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRPATraining', 60, 'prpbar_Length',           0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRPATraining', 70, 'prpbar_FileName',         1, 1, 3, 0
EXEC usp_AddCustom_Screens 'PRPATraining', 80, 'prpbar_CoverArtFileName', 1, 1, 3, 0
Go

EXEC usp_DeleteCustom_ScreenObject 'PRNHAGrid'
EXEC usp_AddCustom_ScreenObjects 'PRNHAGrid', 'List', 'PRPublicationArticle', 'N', 0, 'PRPublicationArticle'
EXEC usp_AddCustom_Lists 'PRNHAGrid', 10, 'prpbar_Sequence', null, 'Y'
EXEC usp_AddCustom_Lists 'PRNHAGrid', 20, 'prpbar_Name', null, 'Y', null, '', 'Custom', '', '', 'PRPublication/PRNHA.asp', 'prpbar_PublicationArticleID'
EXEC usp_AddCustom_Lists 'PRNHAGrid', 30, 'prpbar_IndustryTypeCode', null, 'Y'
EXEC usp_AddCustom_Lists 'PRNHAGrid', 40, 'prpbar_PublishDate', null, 'Y'
UPDATE custom_lists SET grip_DefaultOrderBy = 'Y' WHERE grip_GridName = 'PRNHA' AND grip_ColName='prpbar_Sequence';
EXEC usp_AddCustom_Tabs 16, 'find', 'New Hire Academy', 'customfile', 'PRPublication/PRNHAListing.asp'   

EXEC usp_DeleteCustom_ScreenObject 'PRNHA'
EXEC usp_AddCustom_ScreenObjects 'PRNHA', 'Screen', 'PRPublicationArticle', 'N', 0, 'PRPublicationArticle'
EXEC usp_AddCustom_Screens 'PRNHA', 10, 'prpbar_Name',             1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRNHA', 10, 'prpbar_Sequence',         0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRNHA', 20, 'prpbar_Abstract',         1, 1, 2, 0
EXEC usp_AddCustom_Screens 'PRNHA', 30, 'prpbar_PublishDate',      1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRNHA', 40, 'prpbar_Length',           0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRNHA', 50, 'prpbar_FileName',         1, 1, 2, 0
EXEC usp_AddCustom_Screens 'PRNHA', 60, 'prpbar_CoverArtFileName', 1, 1, 2, 0
EXEC usp_AddCustom_Screens 'PRNHA', 70, 'prpbar_CoverArtThumbFileName', 1, 1, 2, 0


EXEC usp_AccpacCreateTable @EntityName='PRSurveyResponse', @ColPrefix='prsr', @IDField='prsr_SurveyResponseID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyField          'PRSurveyResponse', 'prsr_SurveyResponseID', 'Survey Response ID'
EXEC usp_AccpacCreateSearchSelectField 'PRSurveyResponse', 'prsr_WebUserID', 'Web User', 'PRWebUser', 100 
EXEC usp_AccpacCreateSearchSelectField 'PRSurveyResponse', 'prsr_CompanyID', 'Company', 'Company', 100 
EXEC usp_AccpacCreateIntegerField      'PRSurveyResponse', 'prsr_HQID', 'HQ ID'
EXEC usp_AccpacCreateSelectField	   'PRSurveyResponse', 'prsr_SurveyCode', 'Survey Code', 'prsa_SurveyCode'

EXEC usp_AccpacCreateTable @EntityName='PRSurveyResponseDetail', @ColPrefix='prsrd', @IDField='prsrd_SurveyResponseDetailID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyField          'PRSurveyResponseDetail', 'prsrd_SurveyResponseDetailID', 'Survey Response Detail ID'
EXEC usp_AccpacCreateIntegerField      'PRSurveyResponseDetail', 'prsrd_SurveyResponseID', 'Survey Response ID'
EXEC usp_AccpacCreateTextField         'PRSurveyResponseDetail', 'prsad_QuestionID', 'QuestionID', 25, 25
EXEC usp_AccpacCreateTextField         'PRSurveyResponseDetail', 'prsad_Answer', 'Answer', 100, 1000
Go





--
--  Reorganized the Person History block
--
EXEC usp_DeleteCustom_ScreenObject 'PRPersonLinkNewEntry'
EXEC usp_AddCustom_ScreenObjects 'PRPersonLinkNewEntry', 'Screen', 'Person_Link', 'N', 0, 'Person_Link'
EXEC usp_AddCustom_Screens 'PRPersonLinkNewEntry', 10, 'peli_CompanyId',          1, 1, 1
EXEC usp_AddCustom_Screens 'PRPersonLinkNewEntry', 20, 'peli_PRStatus',           0, 1, 1
EXEC usp_AddCustom_Screens 'PRPersonLinkNewEntry', 30, 'peli_PROwnershipRole',    0, 1, 1
EXEC usp_AddCustom_Screens 'PRPersonLinkNewEntry', 40, 'peli_PRTitleCode',        1, 1, 1, 'Y', null, 'onTitleCodeChange()'
EXEC usp_AddCustom_Screens 'PRPersonLinkNewEntry', 50, 'peli_PRDLTitle',          0, 1, 1
EXEC usp_AddCustom_Screens 'PRPersonLinkNewEntry', 60, 'peli_PRTitle',            1, 1, 1
EXEC usp_AddCustom_Screens 'PRPersonLinkNewEntry', 70, 'peli_PRRole',             0, 1, 1
EXEC usp_AddCustom_Screens 'PRPersonLinkNewEntry', 80, 'peli_PRResponsibilities', 1, 1, 1
EXEC usp_AddCustom_Screens 'PRPersonLinkNewEntry', 90, 'peli_PRPctOwned',         0, 1, 1
EXEC usp_AddCustom_Screens 'PRPersonLinkNewEntry', 100, 'peli_PRStartDate',       1, 1, 1
EXEC usp_AddCustom_Screens 'PRPersonLinkNewEntry', 110, 'peli_PREndDate',         0, 1, 1
EXEC usp_AddCustom_Screens 'PRPersonLinkNewEntry', 120, 'peli_PRExitReason',      1, 1, 1
EXEC usp_AddCustom_Screens 'PRPersonLinkNewEntry', 130, 'peli_PRWhenVisited',      0, 1, 1
EXEC usp_AddCustom_Screens 'PRPersonLinkNewEntry', 140, 'peli_PRAUSReceiveMethod', 1, 1, 1
EXEC usp_AddCustom_Screens 'PRPersonLinkNewEntry', 150, 'peli_PRAUSChangePreference',  0, 1, 1
EXEC usp_AddCustom_Screens 'PRPersonLinkNewEntry', 200, 'peli_PRBRPublish',       1, 1, 1
EXEC usp_AddCustom_Screens 'PRPersonLinkNewEntry', 210, 'peli_PREBBPublish',      0, 1, 1
EXEC usp_AddCustom_Screens 'PRPersonLinkNewEntry', 220, 'peli_PRSubmitTES',        1, 1, 1
EXEC usp_AddCustom_Screens 'PRPersonLinkNewEntry', 230, 'peli_PRUpdateCL',         0, 1, 1
EXEC usp_AddCustom_Screens 'PRPersonLinkNewEntry', 240, 'peli_PRUseServiceUnits',  1, 1, 1
EXEC usp_AddCustom_Screens 'PRPersonLinkNewEntry', 250, 'peli_PRUseSpecialServices', 0, 1, 1
EXEC usp_AddCustom_Screens 'PRPersonLinkNewEntry', 260, 'peli_PRReceivesTrainingEmail', 1, 1, 1
EXEC usp_AddCustom_Screens 'PRPersonLinkNewEntry', 270, 'peli_PRReceivesCreditSheetReport', 0, 1, 1
EXEC usp_AddCustom_Screens 'PRPersonLinkNewEntry', 280, 'peli_PRReceivesPromoEmail', 1, 1, 1
EXEC usp_AddCustom_Screens 'PRPersonLinkNewEntry', 290, 'peli_PREditListing',       0, 1, 1
EXEC usp_AddCustom_Screens 'PRPersonLinkNewEntry', 300, 'peli_PRReceivesBBScoreReport', 1, 1, 1
EXEC usp_AddCustom_Screens 'PRPersonLinkNewEntry', 310, 'peli_PRWillSubmitARAging', 0, 1, 1
Go

--
--  Sales Order Audit Trail - Used to track MAS Repeat Order Changes
--
EXEC usp_AccpacDropTable 'PRSalesOrderAuditTrail'
EXEC usp_AccpacCreateTable @EntityName='PRSalesOrderAuditTrail', @ColPrefix='prsoat', @IDField='prsoat_SalesOrderAuditTrailID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyField          'PRSalesOrderAuditTrail', 'prsoat_SalesOrderAuditTrailID', 'Sales Order Audit Trail ID'
EXEC usp_AccpacCreateTextField         'PRSalesOrderAuditTrail', 'prsoat_SalesOrderNo', 'Sales Order No', 7, 7
EXEC usp_AccpacCreateIntegerField      'PRSalesOrderAuditTrail', 'prsoat_SoldToCompany', 'Company'
EXEC usp_AccpacCreateIntegerField      'PRSalesOrderAuditTrail', 'prsoat_BillToCompany', 'Bill To Company'
EXEC usp_AccpacCreateTextField         'PRSalesOrderAuditTrail', 'prsoat_CycleCode', 'Cycle Code', 2, 2
EXEC usp_AccpacCreateTextField         'PRSalesOrderAuditTrail', 'prsoat_ItemCode', 'Item Code', 30, 30
EXEC usp_AccpacCreateNumericField	   'PRSalesOrderAuditTrail', 'prsoat_Quantity', 'Quantity'
EXEC usp_AccpacCreateNumericField	   'PRSalesOrderAuditTrail', 'prsoat_LineDiscountPercent', 'Discount Pct'
EXEC usp_AccpacCreateCurrencyField	   'PRSalesOrderAuditTrail', 'prsoat_ExtensionAmt', 'Extension Amt'
EXEC usp_AccpacCreateNumericField	   'PRSalesOrderAuditTrail', 'prsoat_QuantityChange', 'Quantity Change'
EXEC usp_AccpacCreateNumericField	   'PRSalesOrderAuditTrail', 'prsoat_LineDiscountPerctChnge', 'Discount Pct Change'
EXEC usp_AccpacCreateCurrencyField	   'PRSalesOrderAuditTrail', 'prsoat_ExtensionAmtChange', 'Extension Amt Change'
EXEC usp_AccpacCreateSelectField	   'PRSalesOrderAuditTrail', 'prsoat_ActionCode', 'Action Code', 'prsoat_ActionCode'
EXEC usp_AccpacCreateTextField	       'PRSalesOrderAuditTrail', 'prsoat_UserLogon', 'User Logon', 30, 30
EXEC usp_AccpacCreateTextField	       'PRSalesOrderAuditTrail', 'prsoat_CancelReasonCode', 'Cancel Reason', 5, 5
Go


--
--  Obsolete
--
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_CreateRatingNumeralTasks]'))
	drop Procedure [dbo].[usp_CreateRatingNumeralTasks]
GO


EXEC usp_AccpacCreateDateField 'PRFinancial', 'prfs_PublishedDate', 'Published Date'
Go


--
--  Person Event Changes
--
EXEC usp_DeleteCustom_Screen 'PRPersonEventNewEntry', 'prpe_PublishCreditSheet'
UPDATE Custom_Captions
   SET Capt_US = 'Person Event Type'
 WHERE Capt_Code = 'prpe_personeventtypeid'   
 
UPDATE Custom_Captions
   SET Capt_US = 'Effective Date'
 WHERE Capt_Code = 'prpe_Date'  
 
EXEC usp_AccpacCreateTextField 'PRPersonEvent', 'prpe_DisplayedEffectiveDate', 'Displayed Effective Date', 20
EXEC usp_AccpacCreateSelectField 'PRPersonEvent', 'prpe_DisplayedEffectiveDateStyle', 'Displayed Effective Date Style', 'prbe_DisplayedEffectiveDateStyle'
EXEC usp_AddCustom_Screens 'PRPersonEventNewEntry', 3, 'prpe_Date', 1, 1, 1
EXEC usp_AddCustom_Screens 'PRPersonEventNewEntry', 3, 'prpe_DisplayedEffectiveDate', 0, 1, 1
EXEC usp_AddCustom_Screens 'PRPersonEventNewEntry', 3, 'prpe_DisplayedEffectiveDateStyle', 0, 1, 1
EXEC usp_AddCustom_Screens 'PRPersonEventNewEntry', 4, 'prpe_EducationalInstitution', 1, 1, 1
EXEC usp_AddCustom_Screens 'PRPersonEventNewEntry', 5, 'prpe_EducationalDegree', 0, 1, 1
Go


--
--  PACA Import Changes
-- 
EXEC usp_AccpacCreateTextField 'PRImportPACALicense', 'pril_Email', 'Email', 255
EXEC usp_AccpacCreateTextField 'PRImportPACALicense', 'pril_WebAddress', 'Web Address', 255
EXEC usp_AccpacCreateTextField 'PRImportPACALicense', 'pril_Fax', 'FAX', 255
EXEC usp_AccpacCreateTextField 'PRPACALicense', 'prpa_Email', 'Email', 255
EXEC usp_AccpacCreateTextField 'PRPACALicense', 'prpa_WebAddress', 'Web Address', 255
EXEC usp_AccpacCreateTextField 'PRPACALicense', 'prpa_Fax', 'FAX', 255

UPDATE custom_screens
   SET seap_order = seap_order * 10
 WHERE seap_SearchBoxName = 'PRImportPACALicenseNewEntry'   
 
EXEC usp_AddCustom_Screens 'PRImportPACALicenseNewEntry', 182, 'pril_Fax', 1, 1, 1
EXEC usp_AddCustom_Screens 'PRImportPACALicenseNewEntry', 184, 'pril_Email', 0, 1, 1
EXEC usp_AddCustom_Screens 'PRImportPACALicenseNewEntry', 186, 'pril_WebAddress', 0, 1, 1
Go


If Exists (Select name from sysobjects where name = 'usp_ReconcileOnlineAllocation' and type='P') Drop Procedure dbo.usp_ReconcileOnlineAllocation
Go

EXEC dbo.usp_DefineCaptions 'PRServiceUnitAllocation', 
	'Service Unit Allocation',
	'Service Unit Allocations', 
	'prun_AllocationTypeCode',
	'prun_ServiceUnitAllocationId',
	NULL,
	NULL


EXEC usp_DeleteCustom_ScreenObject 'PRServiceUnitAllocationGrid'
EXEC usp_AddCustom_ScreenObjects 'PRServiceUnitAllocationGrid', 'List', 'PRServiceUnitAllocation', 'N', 0, 'vPRServiceUnitAllocation';
EXEC usp_AddCustom_Lists 'PRServiceUnitAllocationGrid', '10', 'prun_StartDate', '', 'Y', 'Y', 'CENTER'
EXEC usp_AddCustom_Lists 'PRServiceUnitAllocationGrid', '20', 'prun_ExpirationDate', '', 'Y', null, 'CENTER'
EXEC usp_AddCustom_Lists 'PRServiceUnitAllocationGrid', '30', 'prun_AllocationTypeCode', '', 'Y', null, '', 'Custom', '', '', 'PRCompany/PRCompanyServiceUnitAllocation.asp', 'prun_ServiceUnitAllocationId'
EXEC usp_AddCustom_Lists 'PRServiceUnitAllocationGrid', '40', 'prun_UnitsAllocated', '', 'Y', null, 'RIGHT'
EXEC usp_AddCustom_Lists 'PRServiceUnitAllocationGrid', '50', 'UnitsUsed', '', 'Y', null, 'RIGHT'
EXEC usp_AddCustom_Lists 'PRServiceUnitAllocationGrid', '60', 'prun_UnitsRemaining', '', 'Y', null, 'RIGHT'


EXEC usp_DeleteCustom_ScreenObject 'PRServiceUnitAllocationEntry'
EXEC usp_AddCustom_ScreenObjects 'PRServiceUnitAllocationEntry', 'Screen', 'PRServiceUnitAllocation', 'N', 0, 'PRServiceUnitAllocation'
EXEC usp_AddCustom_Screens 'PRServiceUnitAllocationEntry', 10, 'prun_CompanyId',			 1, 1, 1
EXEC usp_AddCustom_Screens 'PRServiceUnitAllocationEntry', 20, 'prun_AllocationTypeCode',    1, 1, 1
EXEC usp_AddCustom_Screens 'PRServiceUnitAllocationEntry', 30, 'prun_StartDate',			 0, 1, 1
EXEC usp_AddCustom_Screens 'PRServiceUnitAllocationEntry', 40, 'prun_UnitsAllocated',        1, 1, 1
EXEC usp_AddCustom_Screens 'PRServiceUnitAllocationEntry', 50, 'prun_ExpirationDate',		 0, 1, 1
Go
