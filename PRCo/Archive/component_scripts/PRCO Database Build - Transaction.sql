SET NOCOUNT ON
GO
DECLARE @CustomContent varchar(8000)
DECLARE @DEFAULT_COMPONENT_NAME nvarchar(20)
SET @DEFAULT_COMPONENT_NAME = 'PRTransaction'

IF not exists (select 1 from sysobjects where id = object_id('tAccpacComponentName') 
			and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
  CREATE TABLE dbo.tAccpacComponentName ( ComponentName nvarchar(20) NULL )
  -- Create a default row so that all we have to do are updates
  Insert into tAccpacComponentName Values (@DEFAULT_COMPONENT_NAME)
END

-- ****************************************************************************
-- *******************  PRTransaction  ********************************************


-- TRANSACTION START
exec usp_AccpacCreateTable 'PRTransaction', 'prtx', 'prtx_TransactionId'
exec usp_AccpacCreateKeyField 'PRTransaction', 'prtx_TransactionId', 'Transaction Id' 

exec usp_AccpacCreateSearchSelectField  'PRTransaction', 'prtx_CompanyId', 'Company', 'Company', 50, '17'
exec usp_AccpacCreateSearchSelectField  'PRTransaction', 'prtx_PersonId', 'Person', 'Person', 50, '17'
exec usp_AccpacCreateSearchSelectField  'PRTransaction', 'prtx_BusinessEventId', 'Business Event', 'PRBusinessEvent' 
exec usp_AccpacCreateSearchSelectField  'PRTransaction', 'prtx_PersonEventId', 'Person Event', 'PRPersonEvent' 
exec usp_AccpacCreateDateField          'PRTransaction', 'prtx_EffectiveDate', 'Effective Date'
exec usp_AccpacCreateSearchSelectField  'PRTransaction', 'prtx_AuthorizedById', 'Authorized By', 'Person', 50, '17'
exec usp_AccpacCreateTextField          'PRTransaction', 'prtx_AuthorizedInfo', 'Authorized Info', 50
exec usp_AccpacCreateSelectField        'PRTransaction', 'prtx_NotificationType', 'Notification Type', 'prtx_NotificationType' 
exec usp_AccpacCreateSelectField        'PRTransaction', 'prtx_NotificationStimulus', 'Notification Stimulus', 'prtx_NotificationStimulus' 
exec usp_AccpacCreateSearchSelectField  'PRTransaction', 'prtx_CreditSheetId', 'Credit Sheet', 'PRCreditSheet' 
exec usp_AccpacCreateMultilineField     'PRTransaction', 'prtx_Explanation', 'Explanation', 75, '5', 'N', 'Y'
exec usp_AccpacCreateDateField          'PRTransaction', 'prtx_RedbookDate', 'Red Book Date'
exec usp_AccpacCreateSelectField        'PRTransaction', 'prtx_Status', 'Status', 'prtx_Status' 
exec usp_AccpacCreateDateField          'PRTransaction', 'prtx_CloseDate', 'Close Date'

-- TRANSACTION DETAIL START
exec usp_AccpacCreateTable 'PRTransactionDetail', 'prtd', 'prtd_TransactionDetailId'
exec usp_AccpacCreateKeyField 'PRTransactionDetail', 'prtd_TransactionDetailId', 'Transaction Detail Id' 

exec usp_AccpacCreateSearchSelectField 'PRTransactionDetail', 'prtd_TransactionId', 'Transaction', 'PRTransaction', 10, '19', NULL, 'Y'
exec usp_AccpacCreateTextField 'PRTransactionDetail', 'prtd_EntityName', 'Entity Name', 50
exec usp_AccpacCreateTextField 'PRTransactionDetail', 'prtd_ColumnName', 'Column Name', 250
exec usp_AccpacCreateTextField 'PRTransactionDetail', 'prtd_Action', 'Action', 10
exec usp_AccpacCreateSelectField 'PRTransactionDetail', 'prtd_ColumnType', 'Column Type', 'prtd_ColumnType' 
exec usp_AccpacCreateTextField 'PRTransactionDetail', 'prtd_OldValue', 'Old Value', 1800
exec usp_AccpacCreateTextField 'PRTransactionDetail', 'prtd_NewValue', 'New Value', 1800
exec usp_AccpacCreateMultilineField 'PRTransactionDetail', 'prtd_OldText', 'Old Text', 1800
exec usp_AccpacCreateMultilineField 'PRTransactionDetail', 'prtd_NewText', 'New Text', 1800




DROP TABLE tAccpacComponentName 

GO

SET NOCOUNT OFF
GO

-- ********************* END TABLE AND FIELD CREATION *************************
