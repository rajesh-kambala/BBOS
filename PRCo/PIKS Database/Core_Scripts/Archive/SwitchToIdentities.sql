--
--  Switching the tables this way means we don't have to shuffle tables around.
--  However, we do have redefine any triggers and indexes.   Execute this prior
--  to those SQL scripts.
--
DECLARE @SQL varchar(8000)
DECLARE @MaxID int

SELECT @MaxID = MAX(prte_TESId) FROM PRTES;
SET @MaxID = @MaxID+1

-- Define our new table
SET @SQL = 
'CREATE TABLE [dbo].[PRTES2]( ' +
'	[prte_TESId] [int] IDENTITY(' + CONVERT(VARCHAR(20), @MaxID) + ',1) NOT NULL, ' +
'	[prte_Deleted] [int] NULL, ' +
'	[prte_WorkflowId] [int] NULL, ' +
'	[prte_Secterr] [int] NULL, ' +
'	[prte_CreatedBy] [int] NULL, ' +
'	[prte_CreatedDate] [datetime] NULL DEFAULT (getdate()), ' +
'	[prte_UpdatedBy] [int] NULL,' +
'	[prte_UpdatedDate] [datetime] NULL DEFAULT (getdate()), ' +
'	[prte_TimeStamp] [datetime] NULL DEFAULT (getdate()), ' +
'	[prte_ResponderCompanyId] [int] NOT NULL DEFAULT ((-1)), ' +
'	[prte_Date] [datetime] NULL, ' +
'	[prte_ResponseDate] [datetime] NULL, ' +
'	[prte_HowSent] [nvarchar](40) NULL, ' +
'	[prte_FaxNumber] [nvarchar](50) NULL, ' +
'PRIMARY KEY CLUSTERED  ' +
'( ' +
'	[prte_TESId] ASC ' +
')WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ' +
')'
EXEC(@SQL)

-- Switch the table partitions so that the data
-- from the old table is now the data for the new
-- table
ALTER TABLE PRTES SWITCH TO PRTES2

-- Drop our old table
DROP TABLE PRTES

-- Rename our new table, thus replacing
-- the old table
EXEC sp_rename 'PRTES2' ,'PRTES'

SELECT  MAX(prte_TESId) As MaxIDValue, 
		ident_seed('PRTES') As IdentitySeedValue 
  FROM PRTES;



SELECT @MaxID = MAX(prt2_TESDetailId) FROM PRTESDetail;
SET @MaxID = @MaxID+1

-- Define our new table
SET @SQL = 
'CREATE TABLE [dbo].[PRTESDetail2]( ' +
'	[prt2_TESDetailId] [int] IDENTITY(' + CONVERT(VARCHAR(20), @MaxID) + ',1) NOT NULL, ' +
'	[prt2_Deleted] [int] NULL, ' +
'	[prt2_WorkflowId] [int] NULL, ' +
'	[prt2_Secterr] [int] NULL, ' +
'	[prt2_CreatedBy] [int] NULL, ' +
'	[prt2_CreatedDate] [datetime] NULL DEFAULT (getdate()), ' +
'	[prt2_UpdatedBy] [int] NULL, ' +
'	[prt2_UpdatedDate] [datetime] NULL DEFAULT (getdate()), ' +
'	[prt2_TimeStamp] [datetime] NULL DEFAULT (getdate()), ' +
'	[prt2_TESId] [int] NOT NULL DEFAULT ((-1)), ' +
'	[prt2_SubjectCompanyId] [int] NOT NULL DEFAULT ((-1)), ' +
'	[prt2_TESFormID] [int] NULL, ' +
'	[prt2_Received] [nchar](1) NULL, ' +
--'	[prt2_Source] [nvarchar](40) NULL, ' +
'PRIMARY KEY CLUSTERED  ' +
'( ' +
'	[prt2_TESDetailId] ASC ' +
')WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ' +
')'
EXEC(@SQL)

-- Switch the table partitions so that the data
-- from the old table is now the data for the new
-- table
ALTER TABLE PRTESDetail SWITCH TO PRTESDetail2

-- Drop our old table
DROP TABLE PRTESDetail

-- Rename our new table, thus replacing
-- the old table
EXEC sp_rename 'PRTESDetail2' ,'PRTESDetail'

SELECT  MAX(prt2_TESDetailId) As MaxIDValue, 
		ident_seed('PRTESDetail') As IdentitySeedValue 
  FROM PRTESDetail;



SELECT @MaxID = MAX(prtf_TESFormId) FROM PRTESForm;
SET @MaxID = @MaxID+1

-- Define our new table
SET @SQL = 
'CREATE TABLE [dbo].[PRTESForm2]( ' +
'	[prtf_TESFormId] [int] IDENTITY(' + CONVERT(VARCHAR(20), @MaxID) + ',1) NOT NULL, ' +
'	[prtf_Deleted] [int] NULL, ' +
'	[prtf_WorkflowId] [int] NULL, ' +
'	[prtf_Secterr] [int] NULL, ' +
'	[prtf_CreatedBy] [int] NULL, ' +
'	[prtf_CreatedDate] [datetime] NULL DEFAULT (getdate()), ' +
'	[prtf_UpdatedBy] [int] NULL, ' +
'	[prtf_UpdatedDate] [datetime] NULL DEFAULT (getdate()), ' +
'	[prtf_TimeStamp] [datetime] NULL DEFAULT (getdate()), ' +
'	[prtf_TESFormBatchId] [int] NULL, ' +
'	[prtf_CompanyId] [int] NOT NULL DEFAULT ((-1)), ' +
'	[prtf_SerialNumber] [int] NULL, ' +
'	[prtf_FormType] [nvarchar](40) NULL, ' +
'	[prtf_SentDateTime] [datetime] NULL, ' +
'	[prtf_SentMethod] [nvarchar](40) NULL, ' +
'	[prtf_ReceivedDateTime] [datetime] NULL, ' +
'	[prtf_ReceivedMethod] [nvarchar](40) NULL, ' +
'	[prtf_FaxFileName] [nvarchar](30) NULL, ' +
'	[prtf_TeleformId] [nvarchar](10) NULL, ' +
'PRIMARY KEY CLUSTERED  ' +
'( ' +
'	[prtf_TESFormId] ASC ' +
')WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ' +
')'
EXEC(@SQL)

-- Switch the table partitions so that the data
-- from the old table is now the data for the new
-- table
ALTER TABLE PRTESForm SWITCH TO PRTESForm2

-- Drop our old table
DROP TABLE PRTESForm

-- Rename our new table, thus replacing
-- the old table
EXEC sp_rename 'PRTESForm2' ,'PRTESForm'

SELECT  MAX(prtf_TESFormId) As MaxIDValue, 
		ident_seed('PRTESForm') As IdentitySeedValue 
  FROM PRTESForm;




SELECT @MaxID = MAX(prtfb_TESFormBatchId) FROM PRTESFormBatch;
SET @MaxID = @MaxID+1

-- Define our new table
SET @SQL = 
'CREATE TABLE [dbo].[PRTESFormBatch2]( ' +
'	[prtfb_TESFormBatchId] [int] IDENTITY(' + CONVERT(VARCHAR(20), @MaxID) + ',1) NOT NULL, ' +
'	[prtfb_Deleted] [int] NULL, ' +
'	[prtfb_WorkflowId] [int] NULL, ' +
'	[prtfb_Secterr] [int] NULL, ' +
'	[prtfb_CreatedBy] [int] NULL, ' +
'	[prtfb_CreatedDate] [datetime] NULL DEFAULT (getdate()), ' +
'	[prtfb_UpdatedBy] [int] NULL, ' +
'	[prtfb_UpdatedDate] [datetime] NULL DEFAULT (getdate()), ' +
'	[prtfb_TimeStamp] [datetime] NULL DEFAULT (getdate()), ' +
'	[prtfb_LastFileCreation] [datetime] NULL, ' +
'PRIMARY KEY CLUSTERED  ' +
'( ' +
'	[prtfb_TESFormBatchId] ASC ' +
')WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ' +
')'
EXEC(@SQL)

-- Switch the table partitions so that the data
-- from the old table is now the data for the new
-- table
ALTER TABLE PRTESFormBatch SWITCH TO PRTESFormBatch2

-- Drop our old table
DROP TABLE PRTESFormBatch

-- Rename our new table, thus replacing
-- the old table
EXEC sp_rename 'PRTESFormBatch2' ,'PRTESFormBatch'

SELECT  MAX(prtfb_TESFormBatchId) As MaxIDValue, 
		ident_seed('PRTESFormBatch') As IdentitySeedValue 
  FROM PRTESFormBatch;



SELECT @MaxID = MAX(prbs_BBScoreId) FROM PRBBScore;
SET @MaxID = @MaxID+1

-- Define our new table
SET @SQL = 
'CREATE TABLE [dbo].[PRBBScore2]( ' +
'	[prbs_BBScoreId] [int] IDENTITY(' + CONVERT(VARCHAR(20), @MaxID) + ',1) NOT NULL, ' +
'	[prbs_Deleted] [int] NULL, ' +
'	[prbs_WorkflowId] [int] NULL, ' +
'	[prbs_Secterr] [int] NULL, ' +
'	[prbs_CreatedBy] [int] NULL, ' +
'	[prbs_CreatedDate] [datetime] NULL DEFAULT (getdate()), ' +
'   [prbs_UpdatedBy] [int] NULL, ' +
'	[prbs_UpdatedDate] [datetime] NULL DEFAULT (getdate()), ' +
'	[prbs_TimeStamp] [datetime] NULL DEFAULT (getdate()), ' +
'	[prbs_CompanyId] [int] NOT NULL DEFAULT ((-1)), ' +
'	[prbs_Date] [datetime] NULL, ' +
'	[prbs_Current] [nchar](1) NULL, ' +
'	[prbs_P80Surveys] [int] NULL, ' +
'	[prbs_P90Surveys] [int] NULL, ' +
'	[prbs_P95Surveys] [int] NULL, ' +
'	[prbs_P975Surveys] [int] NULL, ' +
'	[prbs_BBScore] [numeric](24, 6) NULL, ' +
'	[prbs_NewBBScore] [numeric](24, 6) NULL, ' +
'	[prbs_ConfidenceScore] [numeric](24, 6) NULL, ' +
'	[prbs_Recency] [nvarchar](20) NULL, ' +
'	[prbs_ObservationPeriodTES] [nvarchar](20) NULL, ' +
'	[prbs_RecentTES] [nvarchar](20) NULL, ' +
'	[prbs_Model] [nvarchar](30) NULL, ' +
'	[prbs_Deviation] [numeric](24, 6) NULL, ' +
'	[prbs_RunDate] [datetime] NULL, ' +
'	[prbs_RequiredReportCount] [int] NULL, ' +
'	[prbs_Exception] [nchar](1) NULL, ' +
'PRIMARY KEY CLUSTERED  ' +
'( ' +
'	[prbs_BBScoreId] ASC ' +
')WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ' +
')'
EXEC(@SQL)

-- Switch the table partitions so that the data
-- from the old table is now the data for the new
-- table
ALTER TABLE PRBBScore SWITCH TO PRBBScore2

-- Drop our old table
DROP TABLE PRBBScore

-- Rename our new table, thus replacing
-- the old table
EXEC sp_rename 'PRBBScore2' ,'PRBBScore'

SELECT  MAX(prbs_BBScoreId) As MaxIDValue, 
		ident_seed('PRBBScore') As IdentitySeedValue 
  FROM PRBBScore;




SELECT @MaxID = MAX(prtd_TransactionDetailId) FROM PRTransactionDetail;
SET @MaxID = @MaxID+1

-- Define our new table
SET @SQL = 
'CREATE TABLE [dbo].[PRTransactionDetail2]( ' +
'	[prtd_TransactionDetailId] [int] IDENTITY(' + CONVERT(VARCHAR(20), @MaxID) + ',1) NOT NULL, ' +
'	[prtd_Deleted] [int] NULL, ' +
'	[prtd_WorkflowId] [int] NULL, ' +
'	[prtd_Secterr] [int] NULL, ' +
'	[prtd_CreatedBy] [int] NULL, ' +
'	[prtd_CreatedDate] [datetime] NULL DEFAULT (getdate()), ' +
'	[prtd_UpdatedBy] [int] NULL, ' +
'	[prtd_UpdatedDate] [datetime] NULL DEFAULT (getdate()), ' +
'	[prtd_TimeStamp] [datetime] NULL DEFAULT (getdate()), ' +
'	[prtd_TransactionId] [int] NOT NULL DEFAULT ((-1)), ' +
'	[prtd_EntityName] [nvarchar](50) NULL, ' +
'	[prtd_ColumnName] [nvarchar](250) NULL, ' +
'	[prtd_Action] [nvarchar](10) NULL, ' +
'	[prtd_ColumnType] [nvarchar](40) NULL, ' +
'	[prtd_OldValue] [nvarchar](1800) NULL, ' +
'	[prtd_NewValue] [nvarchar](1800) NULL, ' +
'	[prtd_OldText] [ntext] NULL, ' +
'	[prtd_NewText] [ntext] NULL, ' +
'PRIMARY KEY CLUSTERED  ' +
'( ' +
'	[prtd_TransactionDetailId] ASC ' +
')WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ' +
')'
EXEC(@SQL)

-- Switch the table partitions so that the data
-- from the old table is now the data for the new
-- table
ALTER TABLE PRTransactionDetail SWITCH TO PRTransactionDetail2

-- Drop our old table
DROP TABLE PRTransactionDetail

-- Rename our new table, thus replacing
-- the old table
EXEC sp_rename 'PRTransactionDetail2' ,'PRTransactionDetail'

SELECT  MAX(prtd_TransactionDetailId) As MaxIDValue, 
		ident_seed('PRTransactionDetail') As IdentitySeedValue 
  FROM PRTransactionDetail;




SELECT @MaxID = MAX(preq_ExceptionQueueId) FROM PRExceptionQueue;
SET @MaxID = @MaxID+1

-- Define our new table
SET @SQL = 
'CREATE TABLE [dbo].[PRExceptionQueue2]( ' +
'	[preq_ExceptionQueueId] [int] IDENTITY(' + CONVERT(VARCHAR(20), @MaxID) + ',1) NOT NULL, ' +
'	[preq_Deleted] [int] NULL, ' +
'	[preq_WorkflowId] [int] NULL, ' +
'	[preq_Secterr] [int] NULL, ' +
'	[preq_CreatedBy] [int] NULL, ' +
'	[preq_CreatedDate] [datetime] NULL DEFAULT (getdate()), ' +
'	[preq_UpdatedBy] [int] NULL, ' +
'	[preq_UpdatedDate] [datetime] NULL DEFAULT (getdate()), ' +
'	[preq_TimeStamp] [datetime] NULL DEFAULT (getdate()), ' +
'	[preq_TradeReportId] [int] NULL, ' +
'	[preq_ARAgingId] [int] NULL, ' +
'	[preq_CompanyId] [int] NULL, ' +
'	[preq_Date] [datetime] NULL, ' +
'	[preq_Type] [nvarchar](40) NULL, ' +
'	[preq_Status] [nvarchar](40) NULL, ' +
'	[preq_ThreeMonthIntegrityRating] [numeric](24, 6) NULL, ' +
'	[preq_ThreeMonthPayRating] [numeric](24, 6) NULL, ' +
'	[preq_RatingLine] [nvarchar](50) NULL, ' +
'	[preq_NumTradeReports3Months] [int] NULL, ' +
'	[preq_NumTradeReports6Months] [int] NULL, ' +
'	[preq_NumTradeReports12Months] [int] NULL, ' +
'	[preq_BlueBookScore] [numeric](24, 6) NULL, ' +
'	[preq_AssignedUserId] [int] NULL, ' +
'	[preq_DateClosed] [datetime] NULL, ' +
'	[preq_ClosedById] [int] NULL, ' +
'	[preq_ChannelId] [int] NULL, ' +
'PRIMARY KEY CLUSTERED  ' +
'( ' +
'	[preq_ExceptionQueueId] ASC ' +
')WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ' +
')'
EXEC(@SQL)

-- Switch the table partitions so that the data
-- from the old table is now the data for the new
-- table
ALTER TABLE PRExceptionQueue SWITCH TO PRExceptionQueue2

-- Drop our old table
DROP TABLE PRExceptionQueue

-- Rename our new table, thus replacing
-- the old table
EXEC sp_rename 'PRExceptionQueue2' ,'PRExceptionQueue'

SELECT  MAX(preq_ExceptionQueueId) As MaxIDValue, 
		ident_seed('PRExceptionQueue') As IdentitySeedValue 
  FROM PRExceptionQueue;






/* PRDescriptionLine Table */
Select @MaxID = Max(prdl_DescriptiveLineId) From PRDescriptiveLine;
Set @MaxID = @MaxID + 1;

SET @SQL =
'CREATE TABLE [dbo].[PRDescriptiveLine2] ( ' +
'	[prdl_DescriptiveLineId] [int] IDENTITY(' + CONVERT(varchar(20), @MaxID) + ', 1) NOT NULL, ' +
'	[prdl_Deleted] [int] NULL, ' +
'	[prdl_WorkflowId] [int] NULL, ' +
'	[prdl_Secterr] [int] NULL, ' +
'	[prdl_CreatedBy] [int] NULL, ' +
'	[prdl_CreatedDate] [datetime] NULL DEFAULT (getdate()), ' +
'	[prdl_UpdatedBy] [int] NULL, ' +
'	[prdl_UpdatedDate] [datetime] NULL DEFAULT (getdate()), ' +
'	[prdl_TimeStamp] [datetime] NULL DEFAULT (getdate()), ' +
'	[prdl_CompanyId] [int] NULL, ' +
'	[prdl_LineContent] [nvarchar](100) NULL, ' +
'PRIMARY KEY CLUSTERED ' +
'( ' +
'	[prdl_DescriptiveLineId] ASC ' +
')WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY] ' +
') ON [PRIMARY] ';

EXEC(@SQL);

-- Switch the table partitions; Old table's data is remapped to the new table
ALTER TABLE PRDescriptiveLine Switch To PRDescriptiveLine2;

-- Drop the now obsolete table
DROP TABLE PRDescriptiveLine;

-- Rename new table to the old table name
Exec sp_rename 'PRDescriptiveLine2', 'PRDescriptiveLine';

-- Show some stats
Select Max(prdl_DescriptiveLineId) As MaxIDValue, ident_seed('PRDescriptiveLine') As IdentitySeedValue From PRDescriptiveLine;
