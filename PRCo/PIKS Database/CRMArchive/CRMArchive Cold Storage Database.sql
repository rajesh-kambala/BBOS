--
--  Search and Replace the Year being moved into Cold Storage.  9 occurrences
--
--  FIND: CRMArchive_2019
--  REPLACE: CRMArchive_YYYY
--


USE master

CREATE DATABASE CRMArchive_2019
	CONTAINMENT = NONE
		ON  PRIMARY ( NAME = N'CRMArchive_2019', FILENAME = N'D:\Applications\SQLServer_Data\CRMArchive_2019.mdf' , SIZE = 1048576KB , MAXSIZE = UNLIMITED, FILEGROWTH = 10240KB )  -- 1 GB w/ 10 MB growth
			LOG ON ( NAME = N'CRMArchive_2019_log', FILENAME = N'D:\Applications\SQLServer_Data\CRMArchive_2019.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 10240KB)  -- 1 MB w/ 10 MB growth  Start it small so we can release the space later.

GO
ALTER DATABASE CRMArchive_2019 SET RECOVERY SIMPLE 


USE CRMArchive_2019


CREATE TABLE [dbo].[PRAdCampaignAuditTrail](
	[pradcat_AdCampaignAuditTrailID] [int] NOT NULL,
	[pradcat_Deleted] [int] NULL,
	[pradcat_WorkflowId] [int] NULL,
	[pradcat_Secterr] [int] NULL,
	[pradcat_CreatedBy] [int] NULL,
	[pradcat_CreatedDate] [datetime] NULL,
	[pradcat_UpdatedBy] [int] NULL,
	[pradcat_UpdatedDate] [datetime] NULL,
	[pradcat_TimeStamp] [datetime] NULL,
	[pradcat_AdCampaignID] [int] NULL,
	[pradcat_AdEligiblePageID] [int] NULL,
	[pradcat_WebUserID] [int] NULL,
	[pradcat_CompanyID] [int] NULL,
	[pradcat_Rank] [int] NULL,
	[pradcat_SponsoredLinkType] [nvarchar](40) NULL,
	[pradcat_SearchAuditTrailID] [int] NULL,
	[pradcat_Clicked] [nchar](1) NULL,
	[pradcat_PageRequestID] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[pradcat_AdCampaignAuditTrailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO


CREATE TABLE [dbo].[PRAdCampaignAuditTrailSummary](
	[pradcats_AdCampaignAuditTrailSummaryID] [int] NOT NULL,
	[pradcats_Deleted] [int] NULL,
	[pradcats_WorkflowId] [int] NULL,
	[pradcats_Secterr] [int] NULL,
	[pradcats_CreatedBy] [int] NULL,
	[pradcats_CreatedDate] [datetime] NULL,
	[pradcats_UpdatedBy] [int] NULL,
	[pradcats_UpdatedDate] [datetime] NULL,
	[pradcats_TimeStamp] [datetime] NULL,
	[pradcats_AdCampaignID] [int] NOT NULL,
	[pradcats_DisplayDate] [datetime] NULL,
	[pradcats_ImpressionCount] [int] NOT NULL,
	[pradcats_ClickCount] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[pradcats_AdCampaignAuditTrailSummaryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO



CREATE TABLE [dbo].[PRCommunicationLog](
	[prcoml_CommunicationLog] [int] NOT NULL,
	[prcoml_Deleted] [int] NULL,
	[prcoml_WorkflowId] [int] NULL,
	[prcoml_Secterr] [int] NULL,
	[prcoml_CreatedBy] [int] NULL,
	[prcoml_CreatedDate] [datetime] NULL,
	[prcoml_UpdatedBy] [int] NULL,
	[prcoml_UpdatedDate] [datetime] NULL,
	[prcoml_TimeStamp] [datetime] NULL,
	[prcoml_AttachmentName] [varchar](max) NULL,
	[prcoml_Source] [varchar](100) NULL,
	[prcoml_Codes] [varchar](500) NULL,
	[prcoml_Subject] [varchar](255) NULL,
	[prcoml_MethodCode] [nvarchar](40) NULL,
	[prcoml_CompanyID] [int] NULL,
	[prcoml_PersonID] [int] NULL,
	[prcoml_FaxID] [varchar](30) NULL,
	[prcoml_FaxStatus] [varchar](100) NULL,
	[prcoml_TranslatedFaxID] [varchar](50) NULL,
	[prcoml_Failed] [nchar](1) NULL,
	[prcoml_FailedMessage] [varchar](500) NULL,
	[prcoml_Destination] [varchar](500) NULL,
	[prcoml_FailedCategory] [nvarchar](40) NULL,
PRIMARY KEY CLUSTERED 
(
	[prcoml_CommunicationLog] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
 
CREATE TABLE [dbo].[PREquifaxAuditLog](
	[preqfal_EquifaxAuditLogID] [int] NOT NULL,
	[preqfal_Deleted] [int] NULL,
	[preqfal_WorkflowId] [int] NULL,
	[preqfal_Secterr] [int] NULL,
	[preqfal_CreatedBy] [int] NULL,
	[preqfal_CreatedDate] [datetime] NULL,
	[preqfal_UpdatedBy] [int] NULL,
	[preqfal_UpdatedDate] [datetime] NULL,
	[preqfal_TimeStamp] [datetime] NULL,
	[preqfal_RequestID] [int] NULL,
	[preqfal_WebUserID] [int] NULL,
	[preqfal_RequestingCompanyID] [int] NULL,
	[preqfal_SubjectCompanyID] [int] NULL,
	[preqfal_StatusCode] [nvarchar](40) NULL,
	[preqfal_HasBankingData] [nchar](1) NULL,
	[preqfal_HasNonBankingData] [nchar](1) NULL,
	[preqfal_HasCreditUsageData] [nchar](1) NULL,
	[preqfal_ActiveBankingTradelineCount] [int] NULL,
	[preqfal_InactiveBankingTradelineCount] [int] NULL,
	[preqfal_ActiveNonBankingTradelineCount] [int] NULL,
	[preqfal_InactiveNonBankingTradelineCount] [int] NULL,
	[preqfal_SuccessfulAddressID] [int] NULL,
	[preqfal_LookupCount] [int] NULL,
	[preqfal_ExceptionMsg] [varchar](8000) NULL,
 CONSTRAINT [PK__PREquifaxAuditLo__24927208] PRIMARY KEY CLUSTERED 
(
	[preqfal_EquifaxAuditLogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
 
CREATE TABLE [dbo].[PREquifaxAuditLogDetail](
	[preqfald_EquifaxAuditLogDetailID] [int] NOT NULL,
	[preqfald_Deleted] [int] NULL,
	[preqfald_WorkflowId] [int] NULL,
	[preqfald_Secterr] [int] NULL,
	[preqfald_CreatedBy] [int] NULL,
	[preqfald_CreatedDate] [datetime] NULL,
	[preqfald_UpdatedBy] [int] NULL,
	[preqfald_UpdatedDate] [datetime] NULL,
	[preqfald_TimeStamp] [datetime] NULL,
	[preqfald_EquifaxAuditLogID] [int] NULL,
	[preqfald_Type] [varchar](50) NULL,
	[preqfald_Code] [varchar](50) NULL,
	[preqfald_Description] [varchar](1000) NULL,
	[preqfald_RequestedAddressID] [int] NULL,
 CONSTRAINT [PK__PREquifaxAuditLo__29572725] PRIMARY KEY CLUSTERED 
(
	[preqfald_EquifaxAuditLogDetailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PRExternalLinkAuditTrail](
	[prelat_ExternalLinkAuditTrailID] [int] NOT NULL,
	[prelat_Deleted] [int] NULL,
	[prelat_WorkflowId] [int] NULL,
	[prelat_Secterr] [int] NULL,
	[prelat_CreatedBy] [int] NULL,
	[prelat_CreatedDate] [datetime] NULL,
	[prelat_UpdatedBy] [int] NULL,
	[prelat_UpdatedDate] [datetime] NULL,
	[prelat_TimeStamp] [datetime] NULL,
	[prelat_WebUserID] [int] NULL,
	[prelat_CompanyID] [int] NULL,
	[prelat_AssociatedID] [int] NOT NULL,
	[prelat_AssociatedType] [nvarchar](40) NOT NULL,
	[prelat_URL] [varchar](1000) NULL,
	[prelat_TriggerPage] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[prelat_ExternalLinkAuditTrailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PRRequest](
	[prreq_RequestID] [int] NOT NULL,
	[prreq_Deleted] [int] NULL,
	[prreq_WorkflowId] [int] NULL,
	[prreq_Secterr] [int] NULL,
	[prreq_CreatedBy] [int] NULL,
	[prreq_CreatedDate] [datetime] NULL,
	[prreq_UpdatedBy] [int] NULL,
	[prreq_UpdatedDate] [datetime] NULL,
	[prreq_TimeStamp] [datetime] NULL,
	[prreq_WebUserID] [int] NOT NULL,
	[prreq_CompanyID] [int] NULL,
	[prreq_HQID] [int] NULL,
	[prreq_RequestTypeCode] [nvarchar](40) NULL,
	[prreq_Price] [numeric](24, 6) NULL,
	[prreq_ProductID] [int] NULL,
	[prreq_PriceListID] [int] NULL,
	[prreq_Name] [varchar](50) NULL,
	[prreq_TriggerPage] [varchar](50) NULL,
	[prreq_SourceID] [int] NULL,
	[prreq_SourceEntity] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[prreq_RequestID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PRRequestDetail](
	[prrc_RequestDetailID] [int] NOT NULL,
	[prrc_Deleted] [int] NULL,
	[prrc_WorkflowId] [int] NULL,
	[prrc_Secterr] [int] NULL,
	[prrc_CreatedBy] [int] NULL,
	[prrc_CreatedDate] [datetime] NULL,
	[prrc_UpdatedBy] [int] NULL,
	[prrc_UpdatedDate] [datetime] NULL,
	[prrc_TimeStamp] [datetime] NULL,
	[prrc_RequestID] [int] NOT NULL,
	[prrc_AssociatedID] [int] NOT NULL,
	[prrc_AssociatedType] [nvarchar](40) NULL,
PRIMARY KEY CLUSTERED 
(
	[prrc_RequestDetailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PRSearchAuditTrail](
	[prsat_SearchAuditTrailID] [int] NOT NULL,
	[prsat_Deleted] [int] NULL,
	[prsat_WorkflowId] [int] NULL,
	[prsat_Secterr] [int] NULL,
	[prsat_CreatedBy] [int] NULL,
	[prsat_CreatedDate] [datetime] NULL,
	[prsat_UpdatedBy] [int] NULL,
	[prsat_UpdatedDate] [datetime] NULL,
	[prsat_TimeStamp] [datetime] NULL,
	[prsat_WebUserID] [int] NOT NULL,
	[prsat_CompanyID] [int] NULL,
	[prsat_SearchType] [nvarchar](40) NULL,
	[prsat_SearchWizardAuditTrailID] [int] NULL,
	[prsat_WebUserSearchCritieraID] [int] NULL,
	[prsat_UserType] [nvarchar](40) NULL,
	[prsat_ResultCount] [int] NULL,
	[prsat_IsQuickFind] [nchar](1) NULL,
	[prsat_IsCompanyGeneral] [nchar](1) NULL,
	[prsat_IsCompanyLocation] [nchar](1) NULL,
	[prsat_IsClassification] [nchar](1) NULL,
	[prsat_IsCommodity] [nchar](1) NULL,
	[prsat_IsRating] [nchar](1) NULL,
	[prsat_IsProfile] [nchar](1) NULL,
	[prsat_IsCustom] [nchar](1) NULL,
	[prsat_IsHeader] [nchar](1) NULL,
	[prsat_IsLocalSource] [nchar](1) NULL,
 CONSTRAINT [PK__PRSearchAuditTra__412EB0B6] PRIMARY KEY CLUSTERED 
(
	[prsat_SearchAuditTrailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PRSearchAuditTrailCriteria](
	[prsatc_SearchAuditTrailCriteriaID] [int] NOT NULL,
	[prsatc_Deleted] [int] NULL,
	[prsatc_WorkflowId] [int] NULL,
	[prsatc_Secterr] [int] NULL,
	[prsatc_CreatedBy] [int] NULL,
	[prsatc_CreatedDate] [datetime] NULL,
	[prsatc_UpdatedBy] [int] NULL,
	[prsatc_UpdatedDate] [datetime] NULL,
	[prsatc_TimeStamp] [datetime] NULL,
	[prsatc_SearchAuditTrailID] [int] NOT NULL,
	[prsatc_CriteriaTypeCode] [nvarchar](40) NULL,
	[prsatc_CriteriaSubtypeCode] [nvarchar](40) NULL,
	[prsatc_IntValue] [int] NULL,
	[prsatc_StringValue] [varchar](4000) NULL,
 CONSTRAINT [PK__PRSearchAuditTra__46E78A0C] PRIMARY KEY CLUSTERED 
(
	[prsatc_SearchAuditTrailCriteriaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PRSearchWizardAuditTrail](
	[prswau_SearchWizardAuditTrailID] [int] NOT NULL,
	[prswau_Deleted] [int] NULL,
	[prswau_WorkflowId] [int] NULL,
	[prswau_Secterr] [int] NULL,
	[prswau_CreatedBy] [int] NULL,
	[prswau_CreatedDate] [datetime] NULL,
	[prswau_UpdatedBy] [int] NULL,
	[prswau_UpdatedDate] [datetime] NULL,
	[prswau_TimeStamp] [datetime] NULL,
	[prswau_SearchWizardID] [int] NOT NULL,
	[prswau_WebUserID] [int] NOT NULL,
	[prswau_CompanyID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[prswau_SearchWizardAuditTrailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PRSearchWizardAuditTrailDetail](
	[prswaud_SearchWizardAuditTrailDetailID] [int] NOT NULL,
	[prswaud_Deleted] [int] NULL,
	[prswaud_WorkflowId] [int] NULL,
	[prswaud_Secterr] [int] NULL,
	[prswaud_CreatedBy] [int] NULL,
	[prswaud_CreatedDate] [datetime] NULL,
	[prswaud_UpdatedBy] [int] NULL,
	[prswaud_UpdatedDate] [datetime] NULL,
	[prswaud_TimeStamp] [datetime] NULL,
	[prswaud_SearchWizardAuditTrailID] [int] NOT NULL,
	[prswaud_Question] [int] NOT NULL,
	[prswaud_Answer] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[prswaud_SearchWizardAuditTrailDetailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PRWebAuditTrail](
	[prwsat_WebSiteAuditTrailID] [int] NOT NULL,
	[prwsat_Deleted] [int] NULL,
	[prwsat_WorkflowId] [int] NULL,
	[prwsat_Secterr] [int] NULL,
	[prwsat_CreatedBy] [int] NULL,
	[prwsat_CreatedDate] [datetime] NULL,
	[prwsat_UpdatedBy] [int] NULL,
	[prwsat_UpdatedDate] [datetime] NULL,
	[prwsat_TimeStamp] [datetime] NULL,
	[prwsat_WebUserID] [int] NOT NULL,
	[prwsat_CompanyID] [int] NULL,
	[prwsat_PageName] [varchar](500) NOT NULL,
	[prwsat_QueryString] [varchar](8000) NULL,
	[prwsat_AssociatedID] [int] NULL,
	[prwsat_AssociatedType] [nvarchar](40) NULL,
	[prwsat_Browser] [varchar](50) NULL,
	[prwsat_BrowserVersion] [varchar](50) NULL,
	[prwsat_BrowserPlatform] [varchar](50) NULL,
	[prwsat_IPAddress] [varchar](50) NULL,
	[prwsat_IsTrial] [nchar](1) NULL,
	[prwsat_BrowserUserAgent] [varchar](500) NULL,
 CONSTRAINT [PK__PRWebAuditTrail__7C8480AE] PRIMARY KEY CLUSTERED 
(
	[prwsat_WebSiteAuditTrailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PRWebServiceAuditTrail](
	[prwsat2_WebServiceAuditTrailID] [int] NOT NULL,
	[prwsat2_Deleted] [int] NULL,
	[prwsat2_WorkflowId] [int] NULL,
	[prwsat2_Secterr] [int] NULL,
	[prwsat2_CreatedBy] [int] NULL,
	[prwsat2_CreatedDate] [datetime] NULL,
	[prwsat2_UpdatedBy] [int] NULL,
	[prwsat2_UpdatedDate] [datetime] NULL,
	[prwsat2_TimeStamp] [datetime] NULL,
	[prwsat2_WebMethodName] [varchar](100) NOT NULL,
	[prwsat2_WebServiceLicenseKeyID] [int] NOT NULL,
	[prwsat2_WebUserID] [int] NULL,
	[prwsat2_BBIDRequestCount] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[prwsat2_WebServiceAuditTrailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_preqfald_EquifaxAuditLogID] ON [dbo].[PREquifaxAuditLogDetail]
(
	[preqfald_EquifaxAuditLogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_prcc_RequestID] ON [dbo].[PRRequestDetail]
(
	[prrc_RequestID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PRSearchAuditTrailCriteria] ON [dbo].[PRSearchAuditTrailCriteria]
(
	[prsatc_SearchAuditTrailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PRSearchWizardAuditTrailDetail] ON [dbo].[PRSearchWizardAuditTrailDetail]
(
	[prswaud_SearchWizardAuditTrailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
