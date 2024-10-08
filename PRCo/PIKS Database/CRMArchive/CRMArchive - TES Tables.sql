USE [CRMArchive]
GO

DROP TABLE PRTES
DROP TABLE PRTESDETAIL
DROP TABLE PRTESFORM


CREATE TABLE [dbo].[PRTESRequest](
	[prtesr_TESRequestID] [int] NOT NULL,
	[prtesr_Deleted] [int] NULL,
	[prtesr_WorkflowId] [int] NULL,
	[prtesr_Secterr] [int] NULL,
	[prtesr_CreatedBy] [int] NULL,
	[prtesr_CreatedDate] [datetime] NULL,
	[prtesr_UpdatedBy] [int] NULL,
	[prtesr_UpdatedDate] [datetime] NULL,
	[prtesr_TimeStamp] [datetime] NULL,
	[prtesr_ResponderCompanyID] [int] NULL,
	[prtesr_SubjectCompanyID] [int] NULL,
	[prtesr_Source] [nvarchar](40) NULL,
	[prtesr_TESFormID] [int] NULL,
	[prtesr_VerbalInvestigationID] [int] NULL,
	[prtesr_ProcessedByUserID] [int] NULL,
	[prtesr_SentMethod] [nvarchar](40) NULL,
	[prtesr_SentDateTime] [datetime] NULL,
	[prtesr_OverrideAddress] [varchar](100) NULL,
	[prtesr_OverridePersonID] [int] NULL,
	[prtesr_OverrideCustomAttention] [varchar](100) NULL,
	[prtesr_ReceivedDateTime] [datetime] NULL,
	[prtesr_ReceivedMethod] [nvarchar](40) NULL,
	[prtesr_Received] [nchar](1) NULL,
PRIMARY KEY CLUSTERED 
(
	[prtesr_TESRequestID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


CREATE TABLE [dbo].[PRTESForm](
	[prtf_TESFormId] [int] NOT NULL,
	[prtf_Deleted] [int] NULL,
	[prtf_WorkflowId] [int] NULL,
	[prtf_Secterr] [int] NULL,
	[prtf_CreatedBy] [int] NULL,
	[prtf_CreatedDate] [datetime] NULL,
	[prtf_UpdatedBy] [int] NULL,
	[prtf_UpdatedDate] [datetime] NULL,
	[prtf_TimeStamp] [datetime] NULL,
	[prtf_TESFormBatchId] [int] NULL,
	[prtf_CompanyId] [int] NOT NULL,
	[prtf_SerialNumber] [int] NULL,
	[prtf_FormType] [nvarchar](40) NULL,
	[prtf_SentDateTime] [datetime] NULL,
	[prtf_SentMethod] [nvarchar](40) NULL,
	[prtf_ReceivedDateTime] [datetime] NULL,
	[prtf_ReceivedMethod] [nvarchar](40) NULL,
	[prtf_FaxFileName] [nvarchar](30) NULL,
	[prtf_TeleformId] [nvarchar](10) NULL,
	[prtf_ExpirationDateTime] [datetime] NULL,
	[prtf_Key] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[prtf_TESFormId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

