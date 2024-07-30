--SELECT * FROM custom_Tables WHERE bord_prefix LIKE 'prxex%' ORDER BY bord_prefix
--  prex is taken.

EXEC usp_AccpacCreateTable @EntityName='PRCompanyExperian', @ColPrefix='prcex', @IDField='prcex_CompanyExperianID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyField          'PRCompanyExperian', 'prcex_CompanyExperianID', 'Company Experian ID'
EXEC usp_AccpacCreateSearchSelectField 'PRCompanyExperian', 'prcex_CompanyID', 'Company', 'Company', 100 
EXEC usp_AccpacCreateTextField         'PRCompanyExperian', 'prcex_BIN', 'Experian BIN', 15, 15
EXEC usp_AccpacCreateDateTimeField	   'PRCompanyExperian', 'prcex_LastLookupDateTime', 'Last Lookup Date/Time'
EXEC usp_AccpacCreateIntegerField      'PRCompanyExperian', 'prcex_LookupCount', 'Lookup Count'
EXEC usp_AccpacCreateIntegerField      'PRCompanyExperian', 'prcex_MatchConfidence', 'Match Confidence'
Go
--  ="INSERT INTO PRCompanyExperian (prcex_CompanyID, prcex_BIN, prcex_CreatedBy, prcex_CreatedDate, prcex_UpdatedBy, prcex_UpdatedDate, prcex_TimeStamp) VALUES (" & C2 & ", '" &B2 & "', 1, GETDATE(), 1, GETDATE(), GETDATE());"

CREATE UNIQUE NONCLUSTERED INDEX [ndx_CompanyID] ON [dbo].[PRCompanyExperian] ([prcex_CompanyID] ASC)
GO

EXEC usp_AccpacCreateTable @EntityName='PRExperianAuditLog', @ColPrefix='prexal', @IDField='prexal_ExperianAuditLogID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyField          'PRExperianAuditLog', 'prexal_ExperianAuditLogID', 'Experian Audit Log ID'
EXEC usp_AccpacCreateIntegerField      'PRExperianAuditLog', 'prexal_RequestID', 'Request ID'
EXEC usp_AccpacCreateIntegerField      'PRExperianAuditLog', 'prexal_WebUserID', 'BBOS User ID'
EXEC usp_AccpacCreateSearchSelectField 'PRExperianAuditLog', 'prexal_RequestingCompanyID', 'Requesting Company', 'Company', 100 
EXEC usp_AccpacCreateSearchSelectField 'PRExperianAuditLog', 'prexal_SubjectCompanyID', 'Subject Company', 'Company', 100 
EXEC usp_AccpacCreateSelectField       'PRExperianAuditLog', 'prexal_StatusCode', 'Status Code', 'prexal_StatusCode'  -- E=Error, R=Data Returned, N=No Data Returned
EXEC usp_AccpacCreateTextField         'PRExperianAuditLog', 'prexal_ExceptionMsg', 'Exception Message', 100, 500
EXEC usp_AccpacCreateCheckboxField     'PRExperianAuditLog', 'prexal_HasPaymentFilingsSummary', 'Has Credit Status'
EXEC usp_AccpacCreateCheckboxField     'PRExperianAuditLog', 'prexal_HasTaxLienDetails', 'Has Tax Liens Details'
EXEC usp_AccpacCreateCheckboxField     'PRExperianAuditLog', 'prexal_HasJudgmentDetails', 'Has Judgment Details'
EXEC usp_AccpacCreateCheckboxField     'PRExperianAuditLog', 'prexal_HasTradeContinous', 'Has Trade Continous'
EXEC usp_AccpacCreateCheckboxField     'PRExperianAuditLog', 'prexal_HasTradeNew', 'Has Trade New'
EXEC usp_AccpacCreateCheckboxField     'PRExperianAuditLog', 'prexal_HasTradeAdditional', 'Has Trade Additional'
EXEC usp_AccpacCreateCheckboxField     'PRExperianAuditLog', 'prexal_HasTradeDetails', 'Has Trade Details'
EXEC usp_AccpacCreateCheckboxField     'PRExperianAuditLog', 'prexal_HasBusinessFacts', 'Has Business Facts'
Go


EXEC usp_AccpacCreateTable @EntityName='PRExperianData', @ColPrefix='prexd', @IDField='prexd_ExperianData', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyField          'PRExperianData', 'prexd_ExperianData', 'Experian Data ID'
EXEC usp_AccpacCreateIntegerField      'PRExperianData', 'prexd_RequestID', 'Request ID'
EXEC usp_AccpacCreateSearchSelectField 'PRExperianData', 'prexd_CompanyID', 'Subject Company', 'Company', 100 
EXEC usp_AccpacCreateSelectField       'PRExperianData', 'prexd_StatusCode', 'Status Code', 'prexal_StatusCode'  -- E=Error, R=Data Returned, N=No Data Returned
EXEC usp_AccpacCreateIntegerField      'PRExperianData', 'prexd_EmployeeSize', 'Employee Size'
EXEC usp_AccpacCreateNumericField      'PRExperianData', 'prexd_SalesRevenue', 'Sales Revenue'
EXEC usp_AccpacCreateIntegerField      'PRExperianData', 'prexd_CurrentDBT', 'Current DBT'
EXEC usp_AccpacCreateIntegerField      'PRExperianData', 'prexd_MonthlyAverageDBT', 'Monthly Average DBT'
EXEC usp_AccpacCreateIntegerField      'PRExperianData', 'prexd_HighestDBT6Months', 'Highest DBT 6 Months'
EXEC usp_AccpacCreateIntegerField      'PRExperianData', 'prexd_HighestDBT5Quarters', 'Highest DBT 5 Quarters'
EXEC usp_AccpacCreateIntegerField      'PRExperianData', 'prexd_TradeCollectionCount', 'Total Trade and Collection Count'
EXEC usp_AccpacCreateNumericField      'PRExperianData', 'prexd_TradeCollectionAmount', 'Total Trade and Collection Amount'
EXEC usp_AccpacCreateIntegerField      'PRExperianData', 'prexd_TradelinesCount', 'All Trades Count'
EXEC usp_AccpacCreateNumericField      'PRExperianData', 'prexd_TradelinesAmount', 'All Trades Amount'
EXEC usp_AccpacCreateIntegerField      'PRExperianData', 'prexd_CollectionsCount', 'All Collections Count'
EXEC usp_AccpacCreateNumericField      'PRExperianData', 'prexd_CollectionsAmount', 'All Collections Amount'
EXEC usp_AccpacCreateIntegerField      'PRExperianData', 'prexd_ContiniousTradelinesCount', 'Continuous Trade Count'
EXEC usp_AccpacCreateNumericField      'PRExperianData', 'prexd_ContiniousTradelinesAmount', 'Continuous Trade Amount'
EXEC usp_AccpacCreateNumericField      'PRExperianData', 'prexd_SingleHighCredit', 'Highest Credt Amt Extended'
EXEC usp_AccpacCreateCheckboxField     'PRExperianData', 'prexd_BankruptcyIndicator', 'Bankruptcy'
EXEC usp_AccpacCreateIntegerField      'PRExperianData', 'prexd_LienCount', 'Lien Count'
EXEC usp_AccpacCreateNumericField      'PRExperianData', 'prexd_LienBalance', 'LienBalance'
EXEC usp_AccpacCreateIntegerField      'PRExperianData', 'prexd_JudgementCount', 'Judgement Count'
EXEC usp_AccpacCreateNumericField      'PRExperianData', 'prexd_JudgementBalance', 'Judgement Balance'

EXEC usp_AccpacCreateTable @EntityName='PRExperianBusinessCode', @ColPrefix='prexbc', @IDField='prexbc_ExperianBusinessCodeID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyField          'PRExperianBusinessCode', 'prexbc_ExperianBusinessCodeID', 'Experian Business Code ID'
EXEC usp_AccpacCreateIntegerField      'PRExperianBusinessCode', 'prexbc_RequestID', 'Request ID'
EXEC usp_AccpacCreateSearchSelectField 'PRExperianBusinessCode', 'prexbc_CompanyID', 'Subject Company', 'Company', 100 
EXEC usp_AccpacCreateSelectField       'PRExperianBusinessCode', 'prexbc_TypeCode', 'SIC or NAICS', 'prexbc_TypeCode'
EXEC usp_AccpacCreateTextField         'PRExperianBusinessCode', 'prexbc_Code', 'Filing Type', 10, 50
EXEC usp_AccpacCreateTextField         'PRExperianBusinessCode', 'prexbc_Description', 'Filing Type', 10, 100


EXEC usp_AccpacCreateTable @EntityName='PRExperianLegalFiling', @ColPrefix='prexlf', @IDField='prexlf_ExperianLegalFilingID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyField          'PRExperianLegalFiling', 'prexlf_ExperianLegalFilingID', 'Experian Legal Filing ID'
EXEC usp_AccpacCreateIntegerField      'PRExperianLegalFiling', 'prexlf_RequestID', 'Request ID'
EXEC usp_AccpacCreateSearchSelectField 'PRExperianLegalFiling', 'prexlf_CompanyID', 'Subject Company', 'Company', 100 
EXEC usp_AccpacCreateSelectField       'PRExperianLegalFiling', 'prexlf_TypeCode', 'TaxLien or Judgement', 'prexlf_TypeCode'
EXEC usp_AccpacCreateDateField         'PRExperianLegalFiling', 'prexlf_Date', 'File Date'
EXEC usp_AccpacCreateTextField         'PRExperianLegalFiling', 'prexlf_LegalType', 'Filing Type', 50, 50
EXEC usp_AccpacCreateTextField         'PRExperianLegalFiling', 'prexlf_LegalAction', 'Filing Status', 50, 50
EXEC usp_AccpacCreateNumericField      'PRExperianLegalFiling', 'prexlf_LiabilityAmount', 'Liability Amount'
EXEC usp_AccpacCreateTextField         'PRExperianLegalFiling', 'prexlf_DocumentNumber', 'Document Number', 50, 50
EXEC usp_AccpacCreateTextField         'PRExperianLegalFiling', 'prexlf_FilingLocation', 'Jurisdiction', 50, 50
EXEC usp_AccpacCreateTextField         'PRExperianLegalFiling', 'prexlf_Owner', 'Filed By', 50, 100
EXEC usp_AccpacCreateTextField         'PRExperianLegalFiling', 'prexlf_PlaintiffName', 'Plaintiff', 50, 100

EXEC usp_AccpacCreateTable @EntityName='PRExperianTradePaymentSummary', @ColPrefix='prextps', @IDField='prextpsd_ExperianTradePaymentSummaryID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyField          'PRExperianTradePaymentSummary', 'prextps_ExperianTradePaymentSummaryID', 'Experian Trade Payment Summary ID'
EXEC usp_AccpacCreateIntegerField      'PRExperianTradePaymentSummary', 'prextps_RequestID', 'Request ID'
EXEC usp_AccpacCreateSearchSelectField 'PRExperianTradePaymentSummary', 'prextps_CompanyID', 'Subject Company', 'Company', 100 
EXEC usp_AccpacCreateSelectField       'PRExperianTradePaymentSummary', 'prextps_TypeCode', 'Continuous, New, Additional', 'prextps_TypeCode'
EXEC usp_AccpacCreateIntegerField      'PRExperianTradePaymentSummary', 'prextps_TradeLineCount', 'Lines Reported'
EXEC usp_AccpacCreateIntegerField      'PRExperianTradePaymentSummary', 'prextps_CurrentDBT', 'DBT'
EXEC usp_AccpacCreateTextField         'PRExperianTradePaymentSummary', 'prextps_TotalHighCreditAmount', 'Recent Hight Credit', 50, 50
EXEC usp_AccpacCreateTextField         'PRExperianTradePaymentSummary', 'prextps_TotalAccountBalance', 'Balance', 50, 50
EXEC usp_AccpacCreateIntegerField      'PRExperianTradePaymentSummary', 'prextps_CurrentPercentage', 'Current'
EXEC usp_AccpacCreateIntegerField      'PRExperianTradePaymentSummary', 'prextps_DBT30', '01-30'
EXEC usp_AccpacCreateIntegerField      'PRExperianTradePaymentSummary', 'prextps_DBT60', '31-60'
EXEC usp_AccpacCreateIntegerField      'PRExperianTradePaymentSummary', 'prextps_DBT90', '61-90'
EXEC usp_AccpacCreateIntegerField      'PRExperianTradePaymentSummary', 'prextps_DBT91Plus', '91+'

EXEC usp_AccpacCreateTable @EntityName='PRExperianTradePaymentDetail', @ColPrefix='prextpd', @IDField='prextpd_ExperianTradePaymentDetail', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyField          'PRExperianTradePaymentDetail', 'prextpd_ExperianTradePaymentDetail', 'Experian Trade Payment Detail ID'
EXEC usp_AccpacCreateIntegerField      'PRExperianTradePaymentDetail', 'prextpd_RequestID', 'Request ID'
EXEC usp_AccpacCreateSearchSelectField 'PRExperianTradePaymentDetail', 'prextpd_CompanyID', 'Subject Company', 'Company', 100 
EXEC usp_AccpacCreateSelectField       'PRExperianTradePaymentDetail', 'prextpd_TypeCode', 'NewContinuous,  Additional', 'prextps_TypeCode'
EXEC usp_AccpacCreateTextField         'PRExperianTradePaymentDetail', 'prextpd_BusinessCategory', 'BusinessCategory', 50, 50
EXEC usp_AccpacCreateDateField         'PRExperianTradePaymentDetail', 'prextpd_DateReported', 'Date Reported'
EXEC usp_AccpacCreateDateField         'PRExperianTradePaymentDetail', 'prextpd_DateLastActivity', 'Last Sale'
EXEC usp_AccpacCreateTextField         'PRExperianTradePaymentDetail', 'prextpd_Terms', 'Payment Terms', 10, 10
EXEC usp_AccpacCreateNumericField      'PRExperianTradePaymentDetail', 'prextpd_RecentHighCredit', 'Recent High Credit'
EXEC usp_AccpacCreateNumericField      'PRExperianTradePaymentDetail', 'prextpd_AccountBalance', 'Account Balance'
EXEC usp_AccpacCreateIntegerField      'PRExperianTradePaymentDetail', 'prextpd_CurrentPercentage', 'Current'
EXEC usp_AccpacCreateIntegerField      'PRExperianTradePaymentDetail', 'prextpd_DBT30', '01-30'
EXEC usp_AccpacCreateIntegerField      'PRExperianTradePaymentDetail', 'prextpd_DBT60', '31-60'
EXEC usp_AccpacCreateIntegerField      'PRExperianTradePaymentDetail', 'prextpd_DBT90', '61-90'
EXEC usp_AccpacCreateIntegerField      'PRExperianTradePaymentDetail', 'prextpd_DBT91Plus', '91+'
EXEC usp_AccpacCreateCheckboxField     'PRExperianTradePaymentDetail', 'prextpd_NewlyReported', 'Newly Reported'
EXEC usp_AccpacCreateTextField         'PRExperianTradePaymentDetail', 'prextpd_Comments', 'Comments', 50, 100

