--8.17 Release

--Defect 7160 - edit PRSalesOrderAuditTrail data for DSIR report
EXEC usp_TravantCRM_DeleteCustom_ScreenObject 'PRSalesOrderAuditTrailSearchBox'
EXEC usp_TravantCRM_AddCustom_ScreenObjects 'PRSalesOrderAuditTrailSearchBox', 'SearchScreen', 'PRSalesOrderAuditTrail', 'N', 0, 'vPRSalesOrderAuditTrailListing'
EXEC usp_TravantCRM_AddCustom_Screens 'PRSalesOrderAuditTrailSearchBox', 10, 'prsoat_CreatedDate', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRSalesOrderAuditTrailSearchBox', 20, 'prsoat_SoldBy', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRSalesOrderAuditTrailSearchBox', 30, 'comp_CompanyId', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRSalesOrderAuditTrailSearchBox', 40, 'prsoat_Pipeline', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRSalesOrderAuditTrailSearchBox', 50, 'prsoat_Up_Down', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRSalesOrderAuditTrailSearchBox', 60, 'prsoat_CancelReasonCode', 0, 1, 1, 0
Go

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
GO

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

--Stripe Invoice Integration
/*
IF OBJECT_ID('dbo.PRInvoice', 'U') IS NULL 
BEGIN
	EXEC usp_TravantCRM_DropTable 'PRInvoice'
	EXEC usp_TravantCRM_CreateTable @EntityName='PRInvoice', @ColPrefix='prinv', @IDField='prinv_InvoiceID', @UseIdentityForKey='N'
	EXEC usp_TravantCRM_CreateKeyField          'PRInvoice', 'prinv_InvoiceID',  'Invoice ID'
	EXEC usp_TravantCRM_CreateIntegerField      'PRInvoice', 'prinv_CompanyID',	 'CompanyID', @AllowNull_In='N'
	EXEC usp_TravantCRM_CreateTextField			'PRInvoice', 'prinv_InvoiceNbr', 'Invoice Nbr', 8, 8, @AllowNull_In='N'
	EXEC usp_TravantCRM_CreateTextField			'PRInvoice', 'prinv_SentMethodCode', 'Sent Method Code', 10, 10, @AllowNull_In='N'
	EXEC usp_TravantCRM_CreateDateField			'PRInvoice', 'prinv_SentDateTime', 'Sent Date Time', 'N', 'N'
	EXEC usp_TravantCRM_CreateTextField			'PRInvoice', 'prinv_StripePaymentURL', 'Stripe Payment URL', 200, 200, @AllowNull_In='Y'
	EXEC usp_TravantCRM_CreateTextField			'PRInvoice', 'prinv_StripeInvoiceId', 'Stripe Invoice Id', 30, 30, @AllowNull_In='Y'
	EXEC usp_TravantCRM_CreateTextField			'PRInvoice', 'prinv_PaymentURLKey', 'Payment URL Key', 15, 15, @AllowNull_In='Y'
	EXEC usp_TravantCRM_CreateDateField			'PRInvoice', 'prinv_PaymentDateTime', 'Payment Date Time', 'Y', 'N'
	EXEC usp_TravantCRM_CreateTextField			'PRInvoice', 'prinv_PaymentMethodCode', 'Payment Method Code', 10, 10, @AllowNull_In='Y'
	EXEC usp_TravantCRM_CreateTextField			'PRInvoice', 'prinv_PaymentMethod', 'Payment Method', 50, 50, @AllowNull_In='Y'
	EXEC usp_TravantCRM_CreateTextField			'PRInvoice', 'prinv_PaymentBrand', 'Payment Brand', 50, 50, @AllowNull_In='Y'
	EXEC usp_TravantCRM_CreateTextField			'PRInvoice', 'prinv_PaymentImportedIntoMAS', 'Payment Imported Into MAS', 1, 1, @AllowNull_In='Y'
END
*/
GO

EXEC usp_TravantCRM_AddCustom_Tabs 170, 'find', 'DSIR Edits', 'customfile', 'PRSalesOrderAuditTrail/PRSalesOrderAuditTrailListing.asp', null, 'CRMQuote.gif'
Go

IF NOT EXISTS(SELECT 1 FROM sys.columns WHERE Name = N'prci2_StripeCustomerId' AND Object_ID = Object_ID(N'dbo.PRCompanyIndicators'))
BEGIN
    EXEC usp_TravantCRM_CreateTextField 'PRCompanyIndicators', 'prci2_StripeCustomerId', 'Stripe Customer Id', 50, 50, @AllowNull_In='Y'
END


EXEC usp_TravantCRM_CreateTextField 'PRCompanySearch', 'prce_WordPressSlug', 'WordPress Slug', 550, 500, @AllowNull_In='Y'
Go



IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].usp_GenerateTESFormForFax'))
     DROP PROCEDURE dbo.usp_GenerateTESFormForFax
GO

EXEC usp_TravantCRM_CreateSelectField 'PRCommunicationLog', 'prcoml_FailedTypeCode', 'Failure Type', 'prcoml_FailedTypeCode'
Go

/*
-EXEC usp_TravantCRM_DropTable 'PRPostalCode'
EXEC usp_TravantCRM_CreateTable @EntityName='PRPostalCode', @ColPrefix='prpc', @IDField='prpc_PostalCodeID', @UseIdentityForKey='Y'
EXEC usp_TravantCRM_CreateKeyField          'PRPostalCode', 'prpc_PostalCodeID',  'Postal Code ID'
EXEC usp_TravantCRM_CreateTextField			'PRPostalCode', 'prpc_PostalCode', 'Postal Code', 10, 10, @AllowNull_In='N'
EXEC usp_TravantCRM_CreateTextField			'PRPostalCode', 'prpc_City', 'City', 50, 50, @AllowNull_In='Y'
EXEC usp_TravantCRM_CreateTextField			'PRPostalCode', 'prpc_State', 'State', 50, 50, @AllowNull_In='Y'
EXEC usp_TravantCRM_CreateTextField			'PRPostalCode', 'prpc_County', 'County', 50, 50, @AllowNull_In='Y'
EXEC usp_TravantCRM_CreateNumericField		'PRPostalCode', 'prpc_Latitude', 'Latitude'
EXEC usp_TravantCRM_CreateNumericField		'PRPostalCode', 'prpc_Longitude', 'Longitude'
EXEC usp_TravantCRM_CreateNumericField		'PRPostalCode', 'prpc_TimezoneOffset', 'Timezone Offset'
EXEC usp_TravantCRM_CreateTextField			'PRPostalCode', 'prpc_DST', 'DST', 1, 1, @AllowNull_In='Y'
*/
GO

EXEC usp_TravantCRM_DeleteCustom_ScreenObject 'PRBackgroundCheckRequestSearchBox'
EXEC usp_TravantCRM_DeleteCustom_ScreenObject 'PRBackgroundCheckRequestGrid'
EXEC usp_TravantCRM_DeleteCustom_ScreenObject 'PRBackgroundCheckRequest'
EXEC usp_TravantCRM_DeleteCustom_ScreenObject 'PRBackgroundCheckGrid'
EXEC usp_TravantCRM_DropView 'vPRBackgroundCheck'
EXEC usp_TravantCRM_DeleteCustom_ScreenObject 'PRBackgroundCheck'
EXEC usp_TravantCRM_DeleteCustom_ScreenObject 'PRBackgroundCheckResponseGrid'
EXEC usp_TravantCRM_DeleteCustom_ScreenObject 'PRBackgroundCheckGrid'



EXEC usp_TravantCRM_DropTable 'PRBackgroundCheckRequest'
EXEC usp_TravantCRM_CreateTable @EntityName='PRBackgroundCheckRequest', @ColPrefix='prbcr', @IDField='prbcr_BackgroundCheckRequestID', @UseIdentityForKey='Y'
EXEC usp_TravantCRM_CreateKeyField          'PRBackgroundCheckRequest', 'prbcr_BackgroundCheckRequestID',  'Background Check Request ID'
EXEC usp_TravantCRM_CreateSearchSelectField 'PRBackgroundCheckRequest', 'prbcr_RequestingCompanyID', 'Requesting Company', 'Company', 100 
EXEC usp_TravantCRM_CreateSearchSelectField 'PRBackgroundCheckRequest', 'prbcr_RequestingPersonD', 'Requesting Person', 'Person', 100 
EXEC usp_TravantCRM_CreateSearchSelectField 'PRBackgroundCheckRequest', 'prbcr_SubjectCompanyID', 'Subject Company', 'Company', 100 
EXEC usp_TravantCRM_CreateDateTimeField		'PRBackgroundCheckRequest', 'prbcr_RequestDateTime', 'Request Date Time', 'Y', 'N'
EXEC usp_TravantCRM_CreateSelectField	    'PRBackgroundCheckRequest', 'prbcr_StatusCode', 'Status', 'prbcr_StatusCode'
EXEC usp_TravantCRM_CreateDateTimeField		'PRBackgroundCheckRequest', 'prbcr_SentDateTime', 'Sent Date Time', 'Y', 'N'
EXEC usp_TravantCRM_CreateUserSelectField   'PRBackgroundCheckRequest', 'prbcr_ProcessedBy', 'Processed By'

EXEC usp_TravantCRM_DropTable 'PRBackgroundCheck'
EXEC usp_TravantCRM_CreateTable @EntityName='PRBackgroundCheck', @ColPrefix='prbc', @IDField='prbc_BackgroundCheckID', @UseIdentityForKey='N'
EXEC usp_TravantCRM_CreateKeyField          'PRBackgroundCheck', 'prbc_BackgroundCheckID',  'Background Check ID'
EXEC usp_TravantCRM_CreateSearchSelectField 'PRBackgroundCheck', 'prbc_SubjectCompanyID', 'Subject Company', 'Company', 100 
EXEC usp_TravantCRM_CreateSearchSelectField 'PRBackgroundCheck', 'prbc_SubjectPersonID', 'Subject Person', 'Person', 100 
EXEC usp_TravantCRM_CreateDateTimeField		'PRBackgroundCheck', 'prbc_BackgroundCheckDate', 'Background Check Date', 'Y', 'N'
EXEC usp_TravantCRM_CreateUserSelectField   'PRBackgroundCheck', 'prbc_CheckCreatedBy', 'Background Check Created By'

EXEC usp_TravantCRM_DropTable 'PRBackgroundCheckResponse'
EXEC usp_TravantCRM_CreateTable @EntityName='PRBackgroundCheckResponse', @ColPrefix='prbcr2', @IDField='prbcr2_BackgroundCheckResponseID', @UseIdentityForKey='N'
EXEC usp_TravantCRM_CreateKeyField          'PRBackgroundCheckResponse', 'prbcr2_BackgroundCheckResponseID',  'Background Check Response ID'
EXEC usp_TravantCRM_CreateSearchSelectField 'PRBackgroundCheckResponse', 'prbcr2_BackgroundCheckID', 'Background Check Header', 'PRBackgroundCheckRequest', 100 
EXEC usp_TravantCRM_CreateSelectField	    'PRBackgroundCheckResponse', 'prbcr2_SubjectCode', 'Subject', 'prbcr2_SubjectCode'
EXEC usp_TravantCRM_CreateSelectField	    'PRBackgroundCheckResponse', 'prbcr2_QuestionCode', 'Question', 'prbcr2_QuestionCode'
EXEC usp_TravantCRM_CreateSelectField	    'PRBackgroundCheckResponse', 'prbcr2_ResponseCode', 'Response', 'prbcr2_ResponseCode'
Go	

EXEC usp_TravantCRM_AddCustom_ScreenObjects 'PRBackgroundCheckRequestSearchBox', 'SearchScreen', 'PRBackgroundCheckRequest', 'N', 0, 'PRBackgroundCheckRequest'
EXEC usp_TravantCRM_AddCustom_Screens 'PRBackgroundCheckRequestSearchBox', 10, 'prbcr_RequestDateTime', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRBackgroundCheckRequestSearchBox', 20, 'prbcr_RequestingCompanyID', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRBackgroundCheckRequestSearchBox', 30, 'prbcr_SubjectCompanyID', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRBackgroundCheckRequestSearchBox', 40, 'prbcr_StatusCode', 0, 1, 1, 0
Go

EXEC usp_TravantCRM_DeleteCustom_ScreenObject 'PRBackgroundCheckRequestGrid'
EXEC usp_TravantCRM_AddCustom_ScreenObjects 'PRBackgroundCheckRequestGrid', 'List', 'PRBackgroundCheckRequest', 'N', 0, 'PRBackgroundCheckRequest'
EXEC usp_TravantCRM_AddCustom_Lists 'PRBackgroundCheckRequestGrid', 5, 'prbcr_RequestDateTime', null, 'Y', @Jump='customdotnetdll', @CustomAction='TravantCRM.dll', @CustomFunction='RunBackgroundCheckRequest', @CustomIdField='prbcr_BackgroundCheckRequestID'
--EXEC usp_TravantCRM_AddCustom_Lists 'PRBackgroundCheckRequestGrid', 10, 'prbcr_RequestingCompanyID', null, 'Y', @Jump='Custom', @CustomAction='PRCompany/PRCompanySummary.asp', @CustomIdField='prbcr_RequestingCompanyID'
--EXEC usp_TravantCRM_AddCustom_Lists 'PRBackgroundCheckRequestGrid', 20, 'prbcr_SubjectCompanyID', null, 'Y', @Jump='Custom', @CustomAction='PRCompany/PRCompanySummary.asp', @CustomIdField='prbcr_SubjectCompanyID'
EXEC usp_TravantCRM_AddCustom_Lists 'PRBackgroundCheckRequestGrid', 10, 'prbcr_RequestingCompanyID', null, 'Y', @Jump='Company'
EXEC usp_TravantCRM_AddCustom_Lists 'PRBackgroundCheckRequestGrid', 20, 'prbcr_SubjectCompanyID', null, 'Y', @Jump='Company'

EXEC usp_TravantCRM_AddCustom_Lists 'PRBackgroundCheckRequestGrid', 30, 'prbcr_StatusCode', null, 'Y'
EXEC usp_TravantCRM_AddCustom_Lists 'PRBackgroundCheckRequestGrid', 40, 'prbcr_SentDateTime', null, 'Y'
EXEC usp_TravantCRM_AddCustom_Lists 'PRBackgroundCheckRequestGrid', 50, 'prbcr_ProcessedBy', null, 'Y'
GO


SELECT * FROM Custom_Lists WHERE GriP_ColName LIKE '%companyID%'


EXEC usp_TravantCRM_DeleteCustom_ScreenObject 'PRBackgroundCheckRequest'
EXEC usp_TravantCRM_AddCustom_ScreenObjects 'PRBackgroundCheckRequest', 'Screen', 'PRBackgroundCheckRequest', 'N', 0, 'PRBackgroundCheckRequest'
EXEC usp_TravantCRM_AddCustom_Screens 'PRBackgroundCheckRequest', 10, 'prbcr_RequestingCompanyID', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRBackgroundCheckRequest', 20, 'prbcr_RequestingPersonD', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRBackgroundCheckRequest', 30, 'prbcr_SubjectCompanyID', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRBackgroundCheckRequest', 40, 'prbcr_StatusCode', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRBackgroundCheckRequest', 50, 'prbcr_RequestDateTime', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRBackgroundCheckRequest', 60, 'prbcr_SentDateTime', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRBackgroundCheckRequest', 70, 'prbcr_ProcessedBy', 1, 1, 1, 0
Go

EXEC usp_TravantCRM_DeleteCustom_ScreenObject 'PRBackgroundCheck'
EXEC usp_TravantCRM_AddCustom_ScreenObjects 'PRBackgroundCheck', 'Screen', 'PRBackgroundCheck', 'N', 0, 'PRBackgroundCheck'
EXEC usp_TravantCRM_AddCustom_Screens 'PRBackgroundCheck', 10, 'prbc_SubjectCompanyID', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRBackgroundCheck', 20, 'prbc_SubjectPersonID', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRBackgroundCheck', 30, 'prbc_BackgroundCheckDate', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRBackgroundCheck', 40, 'prbc_CheckCreatedBy', 0, 1, 1, 0
Go

EXEC usp_TravantCRM_DeleteCustom_ScreenObject 'PRBackgroundCheckResponseGrid'
EXEC usp_TravantCRM_AddCustom_ScreenObjects 'PRBackgroundCheckResponseGrid', 'List', 'PRBackgroundCheckResponse', 'N', 0, 'vPRBackgroundCheckResponse'
EXEC usp_TravantCRM_AddCustom_Lists 'PRBackgroundCheckResponseGrid', 0, 'Capt_Order', null, null, NULL, NULL, NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL, 'Y'
EXEC usp_TravantCRM_AddCustom_Lists 'PRBackgroundCheckResponseGrid', 10, 'prbcr2_ResponseCode', null, null
EXEC usp_TravantCRM_AddCustom_Lists 'PRBackgroundCheckResponseGrid', 20, 'prbcr2_QuestionCode', null, null
GO


EXEC usp_TravantCRM_DeleteCustom_ScreenObject 'PRBackgroundCheckGrid'
EXEC usp_TravantCRM_AddCustom_ScreenObjects 'PRBackgroundCheckGrid', 'List', 'PRBackgroundCheck', 'N', 0, 'PRBackgroundCheck'
EXEC usp_TravantCRM_AddCustom_Lists 'PRBackgroundCheckGrid', 10, 'prbc_BackgroundCheckDate', null, null
EXEC usp_TravantCRM_AddCustom_Lists 'PRBackgroundCheckGrid', 20, 'prbc_CheckCreatedBy', null, null
EXEC usp_TravantCRM_AddCustom_Lists 'PRBackgroundCheckGrid', 20, 'prbc_SubjectPersonID', null, null
GO

EXEC usp_TravantCRM_AddCustom_Tabs 175, 'find', 'Background Check Requests', 'customdotnetdll', 'TravantCRM', null, 'dataupload.gif'
UPDATE Custom_Tabs SET Tabs_CustomFunction='RunBackgroundCheckRequestListing' WHERE Tabs_Entity='find' AND Tabs_Caption='Background Check Requests' AND Tabs_Action='customdotnetdll'
Go


	
EXEC usp_TravantCRM_DeleteCustom_ScreenObject 'PRBackgroundCheckGrid'
EXEC usp_TravantCRM_AddCustom_ScreenObjects 'PRBackgroundCheckGrid', 'List', 'PRBackgroundCheck', 'N', 0, 'PRBackgroundCheck'
EXEC usp_TravantCRM_AddCustom_Lists 'PRBackgroundCheckGrid', 5, 'prbc_BackgroundCheckDate', null, 'Y', @Jump='customdotnetdll', @CustomAction='TravantCRM.dll', @CustomFunction='RunBackgroundCheck', @CustomIdField='prbc_BackgroundCheckID'
EXEC usp_TravantCRM_AddCustom_Lists 'PRBackgroundCheckGrid', 20, 'prbc_SubjectPersonID', null, 'Y', @Jump='Custom', @CustomAction='PRPerson/PRPersonSummary.asp', @CustomIdField='prbc_SubjectPersonID'
EXEC usp_TravantCRM_AddCustom_Lists 'PRBackgroundCheckGrid', 30, 'prbc_CheckCreatedBy', null, 'Y'
UPDATE custom_lists SET grip_DefaultOrderBy = 'Y', GriP_OrderByDesc='Y' WHERE grip_GridName = 'PRBackgroundCheckGrid' AND grip_ColName='prbc_BackgroundCheckDate';
GO


EXEC usp_TravantCRM_CreateNumericField 'PRAdCampaignHeader', 'pradch_ContractTotal', 'Contract Total'
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignHeader', 115, 'pradch_ContractTotal', 0, 1, 1, 0
Go


EXEC usp_TravantCRM_DropTable 'PRBackgroundCheckAllocation'
EXEC usp_TravantCRM_CreateTable @EntityName='PRBackgroundCheckAllocation', @ColPrefix='prbca', @IDField='prbca_BackgroundCheckAllocationID', @UseIdentityForKey='Y'
EXEC usp_TravantCRM_CreateKeyField          'PRBackgroundCheckAllocation', 'prbca_BackgroundCheckAllocationID',  'Background Check Allocation ID'
EXEC usp_TravantCRM_CreateSearchSelectField 'PRBackgroundCheckAllocation', 'prbca_HQID', 'Company', 'HQ', 100 
EXEC usp_TravantCRM_CreateSearchSelectField 'PRBackgroundCheckAllocation', 'prbca_CompanyID', 'Company', 'Company', 100 
EXEC usp_TravantCRM_CreateSelectField       'PRBackgroundCheckAllocation', 'prbca_AllocationTypeCode', 'Allocation Type'
EXEC usp_TravantCRM_CreateIntegerField      'PRBackgroundCheckAllocation', 'prbca_Allocation', 'Allocation', 10, 'N'
EXEC usp_TravantCRM_CreateIntegerField      'PRBackgroundCheckAllocation', 'prbca_Remaining', 'Remaining', 10, 'N'
EXEC usp_TravantCRM_CreateDateField		    'PRBackgroundCheckAllocation', 'prbca_StartDate', 'Start Date', 'Y', 'N'
EXEC usp_TravantCRM_CreateDateField		    'PRBackgroundCheckAllocation', 'prbca_ExpirationDate', 'Expiration Date', 'Y', 'N'
GO

EXEC usp_TravantCRM_CreateIntegerField 'PRBackgroundCheckRequest', 'prbcr_BackgroundCheckAllocationID', 'Background Check Allocation'
GO

EXEC usp_TravantCRM_CreateIntegerField 'NewProduct', 'prod_PRBackgroundChecks', 'Background Checks'
GO

EXEC usp_TravantCRM_DeleteCustom_ScreenObject 'PRBackgroundCheckAllocationGrid'
EXEC usp_TravantCRM_AddCustom_ScreenObjects 'PRBackgroundCheckAllocationGrid', 'List', 'PRBackgroundCheckAllocation', 'N', 0, 'PRBackgroundCheckAllocation'
EXEC usp_TravantCRM_AddCustom_Lists 'PRBackgroundCheckAllocationGrid', 5, 'prbca_StartDate', null, 'Y'
EXEC usp_TravantCRM_AddCustom_Lists 'PRBackgroundCheckAllocationGrid', 10, 'prbca_ExpirationDate', null, 'Y'
EXEC usp_TravantCRM_AddCustom_Lists 'PRBackgroundCheckAllocationGrid', 20, 'prbca_AllocationTypeCode', null, 'Y'
EXEC usp_TravantCRM_AddCustom_Lists 'PRBackgroundCheckAllocationGrid', 30, 'prbca_Allocation', null, 'Y'
EXEC usp_TravantCRM_AddCustom_Lists 'PRBackgroundCheckAllocationGrid', 40, 'prbca_Remaining', null, 'Y'
Go