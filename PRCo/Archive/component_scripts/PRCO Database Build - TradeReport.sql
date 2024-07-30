SET NOCOUNT ON
GO
DECLARE @CustomContent varchar(8000)
-- create the physical table 
-- search for PRCompanyClassification to see how this is used   
DECLARE @DEFAULT_COMPONENT_NAME nvarchar(20)
SET @DEFAULT_COMPONENT_NAME = 'PRTradeReport'

IF not exists (select 1 from sysobjects where id = object_id('tAccpacComponentName') 
			and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
  CREATE TABLE dbo.tAccpacComponentName ( ComponentName nvarchar(20) NULL )
  -- Create a default row so that all we have to do are updates
  Insert into tAccpacComponentName Values (@DEFAULT_COMPONENT_NAME)
END

-- ****************************************************************************
-- *******************  General  ********************************************

-- ARAGING Report (This is the Header/Summary information) 
exec usp_AccpacCreateTable 'PRARAging', 'praa', 'praa_ARAgingId'
exec usp_AccpacCreateKeyField           'PRARAging', 'praa_ARAgingId', 'A/R Aging Report Id'
exec usp_AccpacCreateSearchSelectField  'PRARAging', 'praa_CompanyId', 'Company', 'Company', 10, '17', NULL, 'Y' 
exec usp_AccpacCreateSearchSelectField  'PRARAging', 'praa_PersonId', 'Person', 'Person', 10, '0' 
exec usp_AccpacCreateDateField          'PRARAging', 'praa_Date', 'Aging Date'
exec usp_AccpacCreateDateField          'PRARAging', 'praa_RunDate', 'Run Date'
exec usp_AccpacCreateSelectField        'PRARAging', 'praa_DateSelectionCriteria', 'Date Selection Criteria', 'praa_DateSelectionCriteria' 
exec usp_AccpacCreateAdvSearchSelectField 'PRARAging', 'praa_ARAgingImportFormatID', 'AR Arging Import Format', 'PRARAgingImportFormat'
exec usp_AccpacCreateDateField          'PRARAging', 'praa_ImportedDate', 'Imported'
exec usp_AccpacCreateUserSelectField    'PRARAging', 'praa_ImportedByUserId', 'Imported By'
exec usp_AccpacCreateCheckboxField      'PRARAging', 'praa_ManualEntry', 'Manually Entered'

-- AR AGING DETAIL START
exec usp_AccpacCreateTable 'PRARAgingDetail', 'praad', 'praad_ARAgingDetailId'
exec usp_AccpacCreateKeyField 'PRARAgingDetail', 'praad_ARAgingDetailId', 'A/R Aging Detail Id'

exec usp_AccpacCreateSearchSelectField 'PRARAgingDetail', 'praad_ARAgingId', 'A/R Aging', 'PRARAging', 10, '0', NULL, 'Y' 
--exec usp_AccpacCreateSearchSelectField 'PRARAgingDetail', 'praad_ARTranslationId', 'A/R Translation', 'PRARTranslation', 10, '0'
exec usp_AccpacCreateTextField         'PRARAgingDetail', 'praad_ARCustomerId', 'Cust Id', 15, 15
exec usp_AccpacCreateTextField         'PRARAgingDetail', 'praad_FileCompanyName', 'Company Name', 200
exec usp_AccpacCreateTextField         'PRARAgingDetail', 'praad_FileCityName',    'City', 100
exec usp_AccpacCreateTextField         'PRARAgingDetail', 'praad_FileStateName', 'State/Country', 10
exec usp_AccpacCreateTextField         'PRARAgingDetail', 'praad_FileZipCode', 'Zip', 10
exec usp_AccpacCreateNumericField      'PRARAgingDetail', 'praad_Amount0to29', '0-29 ($)'
exec usp_AccpacCreateNumericField      'PRARAgingDetail', 'praad_Amount30to44', '30-44 ($)'
exec usp_AccpacCreateNumericField      'PRARAgingDetail', 'praad_Amount45to60', '45-60 ($)'
exec usp_AccpacCreateNumericField      'PRARAgingDetail', 'praad_Amount61Plus', '61+ ($)'
exec usp_AccpacCreateCheckboxField     'PRARAgingDetail', 'praad_Exception', 'Exception'
exec usp_AccpacCreateIntegerField      'PRARAgingDetail', 'praad_CreditTerms', 'Credit Terms'
exec usp_AccpacCreateSearchSelectField 'PRARAgingDetail', 'praad_ManualCompanyId', 'Company', 'Company', '17', NULL, 'Y' 
-- TODO: This field is currently set to the default datatype of varchar 100; this may not be correct
exec usp_AccpacCreateTextField         'PRARAgingDetail', 'praad_TimeAged', 'Time Aged', 100

-- AR TRANSLATION
exec usp_AccpacCreateTable 'PRARTranslation', 'prar', 'prar_ARTranslationId'
exec usp_AccpacCreateKeyField 'PRARTranslation', 'prar_ARTranslationId', 'A/R Translation Id' 

exec usp_AccpacCreateSearchSelectField 'PRARTranslation', 'prar_CompanyId', 'Company', 'Company', 50, '17', NULL, 'Y' 
exec usp_AccpacCreateTextField         'PRARTranslation', 'prar_CustomerNumber', 'Cust Number', 15, 15
exec usp_AccpacCreateSearchSelectField 'PRARTranslation', 'prar_PRCoCompanyId', 'PRCo Company', 'Company', 50, '0'

-- AR AGING IMPORT FILE FORMAT
exec usp_AccpacCreateTable			'PRARAgingImportFormat', 'praaif', 'praaif_ARAgingImportFormatID'
exec usp_AccpacCreateKeyField		'PRARAgingImportFormat', 'praaif_ARAgingImportFormatID', 'A/R Aging Import Format ID' 
exec usp_AccpacCreateTextField      'PRARAgingImportFormat', 'praaif_Name', 'Format Name', 50, 50, 'N', 'Y', 'Y', 'N'
exec usp_AccpacCreateSelectField	'PRARAgingImportFormat', 'praaif_FileFormat', 'File Format', 'praaif_FileFormat'
exec usp_AccpacCreateSelectField	'PRARAgingImportFormat', 'praaif_DateFormat', 'Date Format', 'praaif_DateFormat'
exec usp_AccpacCreateTextField      'PRARAgingImportFormat', 'praaif_DelimiterChar', 'Delimiter', 1, 1, 'N', 'Y', 'Y', 'N'
exec usp_AccpacCreateIntegerField   'PRARAgingImportFormat', 'praaif_NumberHeaderLines', 'Number of Header Lines', 10, 'N', 'Y', 'Y', 'N'
exec usp_AccpacCreateIntegerField   'PRARAgingImportFormat', 'praaif_DateSelectionCriteriaColIndex', 'Date Selection Field Column Index', 10, 'N', 'Y', 'Y', 'N'
exec usp_AccpacCreateIntegerField   'PRARAgingImportFormat', 'praaif_DateSelectionCriteriaRowIndex', 'Date Selection Field Row Index', 10, 'N', 'Y', 'Y', 'N'
exec usp_AccpacCreateIntegerField   'PRARAgingImportFormat', 'praaif_RunDateColIndex', 'Run Date Field Column Index', 10, 'N', 'Y', 'Y', 'N'
exec usp_AccpacCreateIntegerField   'PRARAgingImportFormat', 'praaif_RunDateRowIndex', 'Run Date Field Row Index', 10, 'N', 'Y', 'Y', 'N'
exec usp_AccpacCreateIntegerField   'PRARAgingImportFormat', 'praaif_AsOfDateColIndex', 'As Of Date Field Column Index', 10, 'N', 'Y', 'Y', 'N'
exec usp_AccpacCreateIntegerField   'PRARAgingImportFormat', 'praaif_AsOfDateRowIndex', 'As Of Date Field Row Index', 10, 'N', 'Y', 'Y', 'N'
exec usp_AccpacCreateIntegerField   'PRARAgingImportFormat', 'praaif_CompanyIDColIndex', 'Company ID Field Column Index', 10, 'N', 'Y', 'Y', 'N'
exec usp_AccpacCreateIntegerField   'PRARAgingImportFormat', 'praaif_CompanyNameColIndex', 'Company Name Field Column Index', 10, 'N', 'Y', 'Y', 'N'
exec usp_AccpacCreateIntegerField   'PRARAgingImportFormat', 'praaif_CityNameColIndex', 'City Name Field Column Index', 10, 'N', 'Y', 'Y', 'N'
exec usp_AccpacCreateIntegerField   'PRARAgingImportFormat', 'praaif_StateNameColIndex', 'State Name Field Column Index', 10, 'N', 'Y', 'Y', 'N'
exec usp_AccpacCreateIntegerField   'PRARAgingImportFormat', 'praaif_ZipCodeColIndex', 'Zip Code Field Column Index', 10, 'N', 'Y', 'Y', 'N'
exec usp_AccpacCreateIntegerField   'PRARAgingImportFormat', 'praaif_Amount0to29ColIndex', 'Amount 0 to 29 Field Column Index', 10, 'N', 'Y', 'Y', 'N'
exec usp_AccpacCreateIntegerField   'PRARAgingImportFormat', 'praaif_Amount30to44ColIndex', 'Amount 30 to 44 Field Column Index', 10, 'N', 'Y', 'Y', 'N'
exec usp_AccpacCreateIntegerField   'PRARAgingImportFormat', 'praaif_Amount45to60ColIndex', 'Amount 45 to 60 Field Column Index', 10, 'N', 'Y', 'Y', 'N'
exec usp_AccpacCreateIntegerField   'PRARAgingImportFormat', 'praaif_Amount61PlusColIndex', 'Amount 61+ Field Column Index', 10, 'N', 'Y', 'Y', 'N'
exec usp_AccpacCreateIntegerField   'PRARAgingImportFormat', 'praaif_CreditTermsColIndex' , 'Credit Terms Field Column Index', 10, 'N', 'Y', 'Y', 'N'
exec usp_AccpacCreateIntegerField   'PRARAgingImportFormat', 'praaif_TimeAgedColIndex', 'Time Aged Field Column Index', 10, 'N', 'Y', 'Y', 'N'
exec usp_AccpacCreateSelectField	'PRARAgingImportFormat', 'praaif_DefaultDateSelectionCriteria', 'Default Date Selection Criteria', 'praa_DateSelectionCriteria'

-- TES 
exec usp_AccpacCreateTable 'PRTES', 'prte', 'prte_TESId'
exec usp_AccpacCreateKeyField 'PRTES', 'prte_TESId', 'TES Id' 
exec usp_AccpacCreateSearchSelectField 'PRTES', 'prte_ResponderCompanyId', 'Company', 'Company', 10, '17', NULL, 'Y'
exec usp_AccpacCreateDateField 'PRTES', 'prte_Date', 'Date'
exec usp_AccpacCreateDateField 'PRTES', 'prte_ResponseDate', 'Response Date'
exec usp_AccpacCreateSelectField 'PRTES', 'prte_HowSent', 'How Sent', 'prte_HowSent'

-- TES DETAIL
exec usp_AccpacCreateTable 'PRTESDetail', 'prt2', 'prt2_TESDetailId'
exec usp_AccpacCreateKeyField 'PRTESDetail', 'prt2_TESDetailId', 'TES Detail Id' 
exec usp_AccpacCreateSearchSelectField 'PRTESDetail', 'prt2_TESId', 'TES', 'PRTES', 10, '19', NULL, 'Y'
exec usp_AccpacCreateSearchSelectField 'PRTESDetail', 'prt2_SubjectCompanyId', 'Subject Company', 'Company', 10, '17', NULL, 'Y'
exec usp_AccpacCreateSearchSelectField 'PRTESDetail', 'prt2_TESFormID', 'TES Form', 'PRTESForm', 10, '19', 'Y', 'N'
exec usp_AccpacCreateCheckboxField 'PRTESDetail', 'prt2_Received', 'Response Received'

-- TES Form Batch
exec usp_AccpacCreateTable 'PRTESFormBatch', 'prtfb', 'prtfb_TESFormBatchId'
exec usp_AccpacCreateKeyField 'PRTESFormBatch', 'prtfb_TESFormBatchId', 'TES Form Batch Id' 
exec usp_AccpacCreateDateField 'PRTESFormBatch', 'prtfb_LastFileCreation', 'Last Extract File Creation Date'

-- TES Form
exec usp_AccpacCreateTable 'PRTESForm', 'prtf', 'prtf_TESFormId'
exec usp_AccpacCreateKeyField 'PRTESForm', 'prtf_TESFormId', 'TES Form Id' 
-- TODO: determine whether the following field needs to be non-nullable
exec usp_AccpacCreateSearchSelectField 'PRTESForm', 'prtf_TESFormBatchId', 'TES Form Batch', 'PRTESFormBatch', 10, '19'
exec usp_AccpacCreateSearchSelectField 'PRTESForm', 'prtf_CompanyId', 'Company', 'Company', 10, '17', NULL, 'Y'
exec usp_AccpacCreateIntegerField      'PRTESForm', 'prtf_SerialNumber', 'Serial Number'
exec usp_AccpacCreateSelectField       'PRTESForm', 'prtf_FormType', 'Form Type', 'prtf_FormType'
exec usp_AccpacCreateDateField		   'PRTESForm', 'prtf_SentDateTime', 'Sent Date'
exec usp_AccpacCreateSelectField       'PRTESForm', 'prtf_SentMethod', 'Sent Method', 'prtf_SentMethod'
exec usp_AccpacCreateDateField         'PRTESForm', 'prtf_ReceivedDateTime', 'Received Date'
exec usp_AccpacCreateSelectField       'PRTESForm', 'prtf_ReceivedMethod', 'Received Method', 'prtf_ReceivedMethod'
exec usp_AccpacCreateTextField		   'PRTESForm', 'prtf_FaxFileName', 'Fax File Name', 30
exec usp_AccpacCreateTextField		   'PRTESForm', 'prtf_TeleformId', 'Teleform Id', 10


-- TRADE REPORT
exec usp_AccpacCreateTable 'PRTradeReport', 'prtr', 'prtr_TradeReportId'
exec usp_AccpacCreateKeyField 'PRTradeReport', 'prtr_TradeReportId', 'Trade Report Id' 

exec usp_AccpacCreateSearchSelectField 'PRTradeReport', 'prtr_ResponderId', 'Responder Company', 'Company', 50, '17', NULL, 'Y'
exec usp_AccpacCreateSearchSelectField 'PRTradeReport', 'prtr_SubjectId', 'Subject Company', 'Company', 50, '17', NULL, 'Y'
exec usp_AccpacCreateDateField 'PRTradeReport', 'prtr_Date', 'Date'
exec usp_AccpacCreateCheckboxField 'PRTradeReport', 'prtr_NoTrade', 'No Trade'
exec usp_AccpacCreateCheckboxField 'PRTradeReport', 'prtr_OutOfBusiness', 'Out Of Business'
exec usp_AccpacCreateSelectField 'PRTradeReport', 'prtr_LastDealtDate', 'Last Dealt Date', 'prtr_LastDealtDate' 
exec usp_AccpacCreateSelectField 'PRTradeReport', 'prtr_RelationshipLength', 'Relationship Length', 'prtr_RelationshipLength' 
exec usp_AccpacCreateCheckboxField 'PRTradeReport', 'prtr_Regularity', 'Regularity'
exec usp_AccpacCreateCheckboxField 'PRTradeReport', 'prtr_Seasonal', 'Seasonal'
exec usp_AccpacCreateSelectField 'PRTradeReport', 'prtr_RelationshipType', 'Relationship Type', 'prtr_RelationshipType' 
exec usp_AccpacCreateMultiselectField 'PRTradeReport', 'prtr_Terms', 'Terms', 'prtr_Terms', 5
exec usp_AccpacCreateCheckboxField 'PRTradeReport', 'prtr_ProductKickers', 'Product Kickers'
exec usp_AccpacCreateCheckboxField 'PRTradeReport', 'prtr_CollectRemit', 'Collect Remit'
exec usp_AccpacCreateCheckboxField 'PRTradeReport', 'prtr_PromptHandling', 'Prompt Handling'
exec usp_AccpacCreateCheckboxField 'PRTradeReport', 'prtr_ProperEquipment', 'Proper Equipment'
exec usp_AccpacCreateSelectField 'PRTradeReport', 'prtr_Pack', 'Pack', 'prtr_Pack' 
exec usp_AccpacCreateCheckboxField 'PRTradeReport', 'prtr_DoubtfulAccounts', 'Doubtful Accounts'
exec usp_AccpacCreateCheckboxField 'PRTradeReport', 'prtr_PayFreight', 'Pay Freight'
exec usp_AccpacCreateCheckboxField 'PRTradeReport', 'prtr_TimelyArrivals', 'Timely Arrivals'
exec usp_AccpacCreateIntegerField 'PRTradeReport', 'prtr_IntegrityId', 'Integrity'
exec usp_AccpacCreateIntegerField 'PRTradeReport', 'prtr_PayRatingId', 'Pay Rating'
exec usp_AccpacCreateSelectField 'PRTradeReport', 'prtr_HighCredit', 'High Credit', 'prtr_HighCredit' 
exec usp_AccpacCreateSelectField 'PRTradeReport', 'prtr_CreditTerms', 'Credit Terms', 'prtr_CreditTerms' 
exec usp_AccpacCreateSelectField 'PRTradeReport', 'prtr_AmountPastDue', 'Amount Past Due', 'prtr_AmountPastDue' 
exec usp_AccpacCreateCheckboxField 'PRTradeReport', 'prtr_InvoiceOnDayShipped', 'Invoice Same Day As Shipped'
exec usp_AccpacCreateCheckboxField 'PRTradeReport', 'prtr_DisputeInvolved', 'Dispute Involved'
exec usp_AccpacCreateSelectField 'PRTradeReport', 'prtr_PaymentTrend', 'Payment Trend', 'prtr_OverallTrend' 
exec usp_AccpacCreateSelectField 'PRTradeReport', 'prtr_LoadsPerYear', 'Loads Per Year', 'prtr_LoadsPerYear' 
exec usp_AccpacCreateMultilineField 'PRTradeReport', 'prtr_Comments', 'Comments', 75, '5'
exec usp_AccpacCreateIntegerField 'PRTradeReport', 'prtr_TESFormID', 'TES Form ID', 10
exec usp_AccpacCreateSelectField 'PRTradeReport', 'prtr_ResponseSource', 'Response Source', 'prtr_ResponseSource' 
exec usp_AccpacCreateCheckboxField 'PRTradeReport', 'prtr_Duplicate', 'Duplicate'

-- Prototype fields
exec usp_AccpacCreateCheckboxField 'PRTradeReport', 'prtr_Exception', 'Exception'
exec usp_AccpacCreateCheckboxField 'PRTradeReport', 'prtr_CommentsFlag', 'Comments'

-- this uncommon call to CreateField makes the vPRTradeReport's view-defined field appear as a date field on the screen
exec usp_AccpacCreateField @EntityName = 'PRTradeReport', 
          @FieldName = 'prtr_StartDate',@Caption = 'Start Date',
          @AccpacEntryType = 42,@AccpacEntrySize = 0,
          @DBFieldType = 'datetime',@SkipColumnCreation='Y'
exec usp_AccpacCreateField @EntityName = 'PRTradeReport', 
          @FieldName = 'prtr_EndDate',@Caption = 'End Date',
          @AccpacEntryType = 42,@AccpacEntrySize = 0,
          @DBFieldType = 'datetime',@SkipColumnCreation='Y'

exec usp_AccpacCreateField @EntityName = 'PRTradeReport', 
          @FieldName = '_StartDate',@Caption = 'Start Date',
          @AccpacEntryType = 42,@AccpacEntrySize = 0,
          @DBFieldType = 'datetime',@SkipColumnCreation='Y'
exec usp_AccpacCreateField @EntityName = 'PRTradeReport', 
          @FieldName = '_EndDate',@Caption = 'End Date',
          @AccpacEntryType = 42,@AccpacEntrySize = 0,
          @DBFieldType = 'datetime',@SkipColumnCreation='Y'

exec usp_AccpacCreateField @EntityName = 'PRTradeReport', 
          @FieldName = '_Exception', @Caption = 'Exception',
          @AccpacEntryType = 45, @AccpacEntrySize = 0,
          @DBFieldType = 'nchar', @DBFieldSize = 1,
          @SkipColumnCreation='Y'
exec usp_AccpacCreateField @EntityName = 'PRTradeReport', 
          @FieldName = '_ExceptionSelect', @Caption = 'Exception',
          @AccpacEntryType = 21, @AccpacEntrySize = 1, @LookupFamily = '_ExceptionSelect',
          @DBFieldType = 'nvarchar', @DBFieldSize = 40,
          @SkipColumnCreation='Y'
exec usp_AccpacCreateField @EntityName = 'PRTradeReport', 
          @FieldName = '_DisputeInvolvedSelect', @Caption = 'Dispute Involved',
          @AccpacEntryType = 21, @AccpacEntrySize = 1, @LookupFamily = '_DisputeInvolvedSelect',
          @DBFieldType = 'nvarchar', @DBFieldSize = 40,
          @SkipColumnCreation='Y'


DROP TABLE tAccpacComponentName 
GO


/**
The next four PRTESResponse tables are for the TES Teleform 
interface.  ACCPAC does not need to be aware of these tables as
the data is intercepted by an "Instead Of" trigger and PRTradeReport
records are created instead.  Data is never actually stored in
these tables.
**/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PRTESResponseME.*]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[PRTESResponseME.*]
GO

CREATE TABLE [dbo].[PRTESResponseME.*](
	[Time_Stamp] [varchar](30) NULL,
	[CSID] [varchar](30) NULL,
	[Form_Id] [numeric](10, 0) NULL,
	[BBID_1] [numeric](6, 0) NULL,
	[SERIAL_NO] [numeric](8, 0) NULL,
	[INTEG_1] [numeric](1, 0) NULL,
	[PAY_1] [char](2) NULL,
	[DONTDEAL_1] [char](1) NULL,
	[OUTOFBUSINESS_1] [char](1) NULL,
	[DEST_ID] [numeric](6, 0) NULL,
	[HIGH_CREDIT_1] [char](1) NULL,
	[INTEG_2] [numeric](1, 0) NULL,
	[PAY_2] [char](2) NULL,
	[DONTDEAL_2] [char](1) NULL,
	[OUTOFBUSINESS_2] [char](1) NULL,
	[BBID_2] [numeric](6, 0) NULL,
	[HIGH_CREDIT_2] [char](1) NULL,
	[INTEG_3] [numeric](1, 0) NULL,
	[PAY_3] [char](2) NULL,
	[DONTDEAL_3] [char](1) NULL,
	[OUTOFBUSINESS_3] [char](1) NULL,
	[BBID_3] [numeric](6, 0) NULL,
	[HIGH_CREDIT_3] [char](1) NULL,
	[INTEG_4] [numeric](1, 0) NULL,
	[PAY_4] [char](2) NULL,
	[DONTDEAL_4] [char](1) NULL,
	[OUTOFBUSINESS_4] [char](1) NULL,
	[BBID_4] [numeric](6, 0) NULL,
	[HIGH_CREDIT_4] [char](1) NULL,
	[INTEG_5] [numeric](1, 0) NULL,
	[PAY_5] [char](2) NULL,
	[DONTDEAL_5] [char](1) NULL,
	[OUTOFBUSINESS_5] [char](1) NULL,
	[BBID_5] [numeric](6, 0) NULL,
	[HIGH_CREDIT_5] [char](1) NULL,
	[INTEG_6] [numeric](1, 0) NULL,
	[PAY_6] [char](2) NULL,
	[DONTDEAL_6] [char](1) NULL,
	[OUTOFBUSINESS_6] [char](1) NULL,
	[BBID_6] [numeric](6, 0) NULL,
	[HIGH_CREDIT_6] [char](1) NULL,
	[INTEG_7] [numeric](1, 0) NULL,
	[PAY_7] [char](2) NULL,
	[DONTDEAL_7] [char](1) NULL,
	[OUTOFBUSINESS_7] [char](1) NULL,
	[BBID_7] [numeric](6, 0) NULL,
	[HIGH_CREDIT_7] [char](1) NULL,
	[INTEG_8] [numeric](1, 0) NULL,
	[PAY_8] [char](2) NULL,
	[DONTDEAL_8] [char](1) NULL,
	[OUTOFBUSINESS_8] [char](1) NULL,
	[BBID_8] [numeric](6, 0) NULL,
	[HIGH_CREDIT_8] [char](1) NULL
)


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PRTESResponseMS.*]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[PRTESResponseMS.*]
GO

CREATE TABLE [dbo].[PRTESResponseMS.*](
	[Time_Stamp] [varchar](30) NULL,
	[CSID] [varchar](30) NULL,
	[Form_Id] [numeric](10, 0) NULL,
	[BBID_1] [numeric](6, 0) NULL,
	[SERIAL_NO] [numeric](8, 0) NULL,
	[INTEG_1] [numeric](1, 0) NULL,
	[PAY_1] [char](2) NULL,
	[DONTDEAL_1] [char](1) NULL,
	[OUTOFBUSINESS_1] [char](1) NULL,
	[DEST_ID] [numeric](6, 0) NULL,
	[HIGH_CREDIT_1] [char](1) NULL,
	[INTEG_2] [numeric](1, 0) NULL,
	[PAY_2] [char](2) NULL,
	[DONTDEAL_2] [char](1) NULL,
	[OUTOFBUSINESS_2] [char](1) NULL,
	[BBID_2] [numeric](6, 0) NULL,
	[HIGH_CREDIT_2] [char](1) NULL,
	[INTEG_3] [numeric](1, 0) NULL,
	[PAY_3] [char](2) NULL,
	[DONTDEAL_3] [char](1) NULL,
	[OUTOFBUSINESS_3] [char](1) NULL,
	[BBID_3] [numeric](6, 0) NULL,
	[HIGH_CREDIT_3] [char](1) NULL,
	[INTEG_4] [numeric](1, 0) NULL,
	[PAY_4] [char](2) NULL,
	[DONTDEAL_4] [char](1) NULL,
	[OUTOFBUSINESS_4] [char](1) NULL,
	[BBID_4] [numeric](6, 0) NULL,
	[HIGH_CREDIT_4] [char](1) NULL,
	[INTEG_5] [numeric](1, 0) NULL,
	[PAY_5] [char](2) NULL,
	[DONTDEAL_5] [char](1) NULL,
	[OUTOFBUSINESS_5] [char](1) NULL,
	[BBID_5] [numeric](6, 0) NULL,
	[HIGH_CREDIT_5] [char](1) NULL,
	[INTEG_6] [numeric](1, 0) NULL,
	[PAY_6] [char](2) NULL,
	[DONTDEAL_6] [char](1) NULL,
	[OUTOFBUSINESS_6] [char](1) NULL,
	[BBID_6] [numeric](6, 0) NULL,
	[HIGH_CREDIT_6] [char](1) NULL,
	[INTEG_7] [numeric](1, 0) NULL,
	[PAY_7] [char](2) NULL,
	[DONTDEAL_7] [char](1) NULL,
	[OUTOFBUSINESS_7] [char](1) NULL,
	[BBID_7] [numeric](6, 0) NULL,
	[HIGH_CREDIT_7] [char](1) NULL,
	[INTEG_8] [numeric](1, 0) NULL,
	[PAY_8] [char](2) NULL,
	[DONTDEAL_8] [char](1) NULL,
	[OUTOFBUSINESS_8] [char](1) NULL,
	[BBID_8] [numeric](6, 0) NULL,
	[HIGH_CREDIT_8] [char](1) NULL
)

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PRTESResponseSE.*]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[PRTESResponseSE.*]
GO

CREATE TABLE [dbo].[PRTESResponseSE.*](
	[SERIAL_NO] [numeric](8, 0) NULL,
	[Form_Id] [numeric](10, 0) NULL,
	[Time_Stamp] [varchar](30) NULL,
	[SUBJECT_BBID] [numeric](6, 0) NULL,
	[DEST_ID] [numeric](6, 0) NULL,
	[INTEGRITY_ABILITY] [char](1) NULL,
	[PAY] [char](2) NULL,
	[DEAL_REGULARLY] [char](1) NULL,
	[HOW_DOES_SUBJECT_FIRM_ACT] [char](2) NULL,
	[CASH_ONLY] [numeric](1, 0) NULL,
	[FIRM_PRICE] [numeric](1, 0) NULL,
	[ON_CONSIGNMENT] [numeric](1, 0) NULL,
	[OTHER_TERMS] [numeric](1, 0) NULL,
	[INVOICE_ON_SHIP_DAY] [char](1) NULL,
	[PAYMENT_TREND] [char](1) NULL,
	[HOW_LONG_DEALT] [char](1) NULL,
	[HOW_RECENTLY_DEALT] [varchar](54) NULL,
	[PRODUCT_KICKERS] [char](1) NULL,
	[PACK] [char](1) NULL,
	[ENCOURAGE_SALES] [char](1) NULL,
	[COLLECT_REMIT] [char](1) NULL,
	[CREDIT_TERMS] [char](1) NULL,
	[HIGH_CREDIT] [char](1) NULL,
	[AMOUNT_PAST_DUE] [char](1) NULL,
	[CSID] [varchar](30) NULL,
	[GOOD_EQUIPMENT] [char](1) NULL,
	[CLAIMS_HANDLED_PROPERLY] [char](1) NULL,
	[LOADS_PER_YEAR] [char](1) NULL,
	[PAYS_FREIGHT] [char](1) NULL,
	[RELIABLE_CARRIERS] [char](1) NULL,
	[DONTDEAL] [char](1) NULL,
	[OUTOFBUSINESS] [char](1) NULL,
	[PAY_DISPUTE] [char](1) NULL,
	[DEALT1TO6] [numeric](1, 0) NULL,
	[DEALT7TO12] [numeric](1, 0) NULL,
	[DEALTOVER1YEAR] [numeric](1, 0) NULL,
	[DEALTSEASONAL] [numeric](1, 0) NULL
)


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PRTESResponseSS.*]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[PRTESResponseSS.*]
GO

CREATE TABLE [dbo].[PRTESResponseSS.*](
	[SERIAL_NO] [numeric](8, 0) NULL,
	[Form_Id] [numeric](10, 0) NULL,
	[Time_Stamp] [varchar](30) NULL,
	[SUBJECT_BBID] [numeric](6, 0) NULL,
	[DEST_ID] [numeric](6, 0) NULL,
	[INTEGRITY_ABILITY] [char](1) NULL,
	[PAY] [char](2) NULL,
	[DEAL_REGULARLY] [char](1) NULL,
	[PAY_DISPUTE] [char](1) NULL,
	[PAYMENT_TREND] [char](1) NULL,
	[HOW_LONG_DEALT] [char](1) NULL,
	[HOW_RECENTLY_DEALT] [char](1) NULL,
	[CREDIT_TERMS] [char](1) NULL,
	[HIGH_CREDIT] [char](1) NULL,
	[AMOUNT_PAST_DUE] [char](1) NULL,
	[CSID] [varchar](30) NULL
)




SET NOCOUNT OFF
GO

-- ********************* END TABLE AND FIELD CREATION *************************


