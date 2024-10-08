USE [CRMArchive]
GO
/****** Object:  Table [dbo].[PRFile]    Script Date: 11/20/2009 09:15:46 ******/
DROP TABLE [dbo].[PRFile]
GO
/****** Object:  Table [dbo].[PRFilePayment]    Script Date: 11/20/2009 09:15:49 ******/
DROP TABLE [dbo].[PRFilePayment]
GO
/****** Object:  Table [dbo].[PRServiceAlaCarte]    Script Date: 11/20/2009 09:16:24 ******/
DROP TABLE [dbo].[PRServiceAlaCarte]
GO
/****** Object:  Table [dbo].[PRARAging]    Script Date: 11/20/2009 09:14:40 ******/
DROP TABLE [dbo].[PRARAging]
GO
/****** Object:  Table [dbo].[PRARAgingDetail]    Script Date: 11/20/2009 09:14:47 ******/
DROP TABLE [dbo].[PRARAgingDetail]
GO
/****** Object:  Table [dbo].[PRRequest]    Script Date: 11/20/2009 09:15:53 ******/
DROP TABLE [dbo].[PRRequest]
GO
/****** Object:  Table [dbo].[PRRequestDetail]    Script Date: 11/20/2009 09:15:56 ******/
DROP TABLE [dbo].[PRRequestDetail]
GO
/****** Object:  Table [dbo].[PRTES]    Script Date: 11/20/2009 09:16:27 ******/
DROP TABLE [dbo].[PRTES]
GO
/****** Object:  Table [dbo].[PRTESDetail]    Script Date: 11/20/2009 09:16:31 ******/
DROP TABLE [dbo].[PRTESDetail]
GO
/****** Object:  Table [dbo].[PRTransactionDetail]    Script Date: 11/20/2009 09:16:41 ******/
DROP TABLE [dbo].[PRTransactionDetail]
GO
/****** Object:  Table [dbo].[PRTransaction]    Script Date: 11/20/2009 09:16:37 ******/
DROP TABLE [dbo].[PRTransaction]
GO
/****** Object:  Table [dbo].[ArchiveLog]    Script Date: 11/20/2009 09:14:12 ******/
DROP TABLE [dbo].[ArchiveLog]
GO
/****** Object:  Table [dbo].[PRWebAuditTrail]    Script Date: 11/20/2009 09:16:46 ******/
DROP TABLE [dbo].[PRWebAuditTrail]
GO
/****** Object:  Table [dbo].[Comm_Link]    Script Date: 11/20/2009 09:14:17 ******/
DROP TABLE [dbo].[Comm_Link]
GO
/****** Object:  Table [dbo].[Communication]    Script Date: 11/20/2009 09:14:31 ******/
DROP TABLE [dbo].[Communication]
GO
/****** Object:  Table [dbo].[PRAdCampaignAuditTrail]    Script Date: 11/20/2009 09:14:36 ******/
DROP TABLE [dbo].[PRAdCampaignAuditTrail]
GO
/****** Object:  Table [dbo].[PREquifaxAuditLog]    Script Date: 11/20/2009 09:14:53 ******/
DROP TABLE [dbo].[PREquifaxAuditLog]
GO
/****** Object:  Table [dbo].[PREquifaxAuditLogDetail]    Script Date: 11/20/2009 09:14:57 ******/
DROP TABLE [dbo].[PREquifaxAuditLogDetail]
GO
/****** Object:  Table [dbo].[PRExternalLinkAuditTrail]    Script Date: 11/20/2009 09:15:01 ******/
DROP TABLE [dbo].[PRExternalLinkAuditTrail]
GO
/****** Object:  Table [dbo].[PRSearchAuditTrailCriteria]    Script Date: 11/20/2009 09:16:06 ******/
DROP TABLE [dbo].[PRSearchAuditTrailCriteria]
GO
/****** Object:  Table [dbo].[PRSearchAuditTrail]    Script Date: 11/20/2009 09:16:02 ******/
DROP TABLE [dbo].[PRSearchAuditTrail]
GO
/****** Object:  Table [dbo].[PRSearchWizardAuditTrail]    Script Date: 11/20/2009 09:16:09 ******/
DROP TABLE [dbo].[PRSearchWizardAuditTrail]
GO
/****** Object:  Table [dbo].[PRSearchWizardAuditTrailDetail]    Script Date: 11/20/2009 09:16:13 ******/
DROP TABLE [dbo].[PRSearchWizardAuditTrailDetail]
GO
/****** Object:  Table [dbo].[PRWebServiceAuditTrail]    Script Date: 11/20/2009 09:16:49 ******/
DROP TABLE [dbo].[PRWebServiceAuditTrail]
GO

DROP TABLE [dbo].[PRAUS]
GO

/****** Object:  Table [dbo].[ArchiveLog]    Script Date: 11/20/2009 09:14:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ArchiveLog](
	[ArchiveLogID] [int] IDENTITY(1,1) NOT NULL,
	[SourceTable] [varchar](100) NOT NULL,
	[TargetTable] [varchar](100) NOT NULL,
	[DateField] [varchar](50) NOT NULL,
	[ArchiveThresholdDate] [datetime] NULL,
	[BeforeCount] [int] NULL,
	[ArchiveCount] [int] NULL,
	[AfterCount] [int] NULL,
	[Status] [varchar](50) NOT NULL,
	[StartDateTime] [datetime] NULL,
	[EndDateTime] [datetime] NULL,
	[StatusMsg] [varchar](5000) NULL,
 CONSTRAINT [PK_ArchiveLog] PRIMARY KEY CLUSTERED 
(
	[ArchiveLogID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PRWebAuditTrail]    Script Date: 11/20/2009 09:16:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
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
    [prwsat_IsTrial] nchar(1) NULL
 CONSTRAINT [PK__PRWebAuditTrail__7C8480AE] PRIMARY KEY CLUSTERED 
(
	[prwsat_WebSiteAuditTrailID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PRFile]    Script Date: 11/20/2009 09:15:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PRFile](
	[prfi_FileId] [int] NOT NULL,
	[prfi_Deleted] [int] NULL,
	[prfi_WorkflowId] [int] NULL,
	[prfi_Secterr] [int] NULL,
	[prfi_CreatedBy] [int] NULL,
	[prfi_CreatedDate] [datetime] NULL,
	[prfi_UpdatedBy] [int] NULL,
	[prfi_UpdatedDate] [datetime] NULL,
	[prfi_TimeStamp] [datetime] NULL,
	[prfi_ChannelId] [int] NULL,
	[prfi_IssueDescription] [ntext] NULL,
	[prfi_AssignedUserId] [int] NULL,
	[prfi_Type] [nvarchar](40) NULL,
	[prfi_Subtype] [nvarchar](40) NULL,
	[prfi_Stage] [nvarchar](40) NULL,
	[prfi_Status] [nvarchar](40) NULL,
	[prfi_Company1Id] [int] NULL,
	[prfi_Company1Role] [nvarchar](40) NULL,
	[prfi_Company1Contact1Id] [int] NULL,
	[prfi_Company1Contact1Address] [nvarchar](50) NULL,
	[prfi_Company1Contact1CityStateZip] [nvarchar](50) NULL,
	[prfi_Company1Contact1Telephone] [nvarchar](20) NULL,
	[prfi_Company1Contact1Fax] [nvarchar](20) NULL,
	[prfi_Company1Contact1Email] [nvarchar](255) NULL,
	[prfi_Company1Contact2Id] [int] NULL,
	[prfi_Company1Contact2Address] [nvarchar](50) NULL,
	[prfi_Company1Contact2CityStateZip] [nvarchar](50) NULL,
	[prfi_Company1Contact2Telephone] [nvarchar](20) NULL,
	[prfi_Company1Contact2Fax] [nvarchar](20) NULL,
	[prfi_Company1Contact2Email] [nvarchar](255) NULL,
	[prfi_Company2Id] [int] NULL,
	[prfi_Company2Role] [nvarchar](40) NULL,
	[prfi_Company2Contact1Id] [int] NULL,
	[prfi_Company2Contact1Address] [nvarchar](50) NULL,
	[prfi_Company2Contact1CityStateZip] [nvarchar](50) NULL,
	[prfi_Company2Contact1Telephone] [nvarchar](20) NULL,
	[prfi_Company2Contact1Fax] [nvarchar](20) NULL,
	[prfi_Company2Contact1Email] [nvarchar](255) NULL,
	[prfi_Company2Contact2Id] [int] NULL,
	[prfi_Company2Contact2Address] [nvarchar](50) NULL,
	[prfi_Company2Contact2CityStateZip] [nvarchar](50) NULL,
	[prfi_Company2Contact2Telephone] [nvarchar](20) NULL,
	[prfi_Company2Contact2Fax] [nvarchar](20) NULL,
	[prfi_Company2Contact2Email] [nvarchar](255) NULL,
	[prfi_Company3Id] [int] NULL,
	[prfi_Company3Role] [nvarchar](40) NULL,
	[prfi_Company3Contact1Id] [int] NULL,
	[prfi_Company3Contact1Address] [nvarchar](50) NULL,
	[prfi_Company3Contact1CityStateZip] [nvarchar](50) NULL,
	[prfi_Company3Contact1Telephone] [nvarchar](20) NULL,
	[prfi_Company3Contact1Fax] [nvarchar](20) NULL,
	[prfi_Company3Contact1Email] [nvarchar](255) NULL,
	[prfi_Company3Contact2Id] [int] NULL,
	[prfi_Company3Contact2Address] [nvarchar](50) NULL,
	[prfi_Company3Contact2CityStateZip] [nvarchar](50) NULL,
	[prfi_Company3Contact2Telephone] [nvarchar](20) NULL,
	[prfi_Company3Contact2Fax] [nvarchar](20) NULL,
	[prfi_Company3Contact2Email] [nvarchar](255) NULL,
	[prfi_RepresentingCompany1Id] [int] NULL,
	[prfi_RepresentingCompany1Name] [nvarchar](50) NULL,
	[prfi_RepresentingCompany1Address] [nvarchar](50) NULL,
	[prfi_RepresentingCompany1CityStateZip] [nvarchar](50) NULL,
	[prfi_RepresentingCompany1Telephone] [nvarchar](20) NULL,
	[prfi_RepresentingCompany1Fax] [nvarchar](20) NULL,
	[prfi_RepresentingCompany1Email] [nvarchar](255) NULL,
	[prfi_RepresentingCompany1PersonId] [int] NULL,
	[prfi_RepresentingCompany1PersonSigned] [nchar](1) NULL,
	[prfi_RepresentingCompany1PersonSigDate] [datetime] NULL,
	[prfi_RepresentingCompany1Info] [ntext] NULL,
	[prfi_RepresentingCompany2Id] [int] NULL,
	[prfi_RepresentingCompany2Name] [nvarchar](50) NULL,
	[prfi_RepresentingCompany2Address] [nvarchar](50) NULL,
	[prfi_RepresentingCompany2CityStateZip] [nvarchar](50) NULL,
	[prfi_RepresentingCompany2Telephone] [nvarchar](20) NULL,
	[prfi_RepresentingCompany2Fax] [nvarchar](20) NULL,
	[prfi_RepresentingCompany2Email] [nvarchar](255) NULL,
	[prfi_RepresentingCompany2PersonId] [int] NULL,
	[prfi_RepresentingCompany2PersonSigned] [nchar](1) NULL,
	[prfi_RepresentingCompany2PersonSigDate] [datetime] NULL,
	[prfi_RepresentingCompany2Info] [ntext] NULL,
	[prfi_RepresentingCompany3Id] [int] NULL,
	[prfi_RepresentingCompany3Name] [nvarchar](50) NULL,
	[prfi_RepresentingCompany3Address] [nvarchar](50) NULL,
	[prfi_RepresentingCompany3CityStateZip] [nvarchar](50) NULL,
	[prfi_RepresentingCompany3Telephone] [nvarchar](20) NULL,
	[prfi_RepresentingCompany3Fax] [nvarchar](20) NULL,
	[prfi_RepresentingCompany3Email] [nvarchar](255) NULL,
	[prfi_RepresentingCompany3PersonId] [int] NULL,
	[prfi_RepresentingCompany3PersonSigned] [nchar](1) NULL,
	[prfi_RepresentingCompany3PersonSigDate] [datetime] NULL,
	[prfi_RepresentingCompany3Info] [ntext] NULL,
	[prfi_ClosingDate] [datetime] NULL,
	[prfi_ClosingReason] [nvarchar](40) NULL,
	[prfi_PaperworkLocation] [nvarchar](40) NULL,
	[prfi_InquirySource] [nvarchar](40) NULL,
	[prfi_Topic] [nvarchar](40) NULL,
	[prfi_InitialCallDuration] [int] NULL,
	[prfi_AmountPRCoInvoiced] [numeric](24, 6) NULL,
	[prfi_5657LetterType] [nvarchar](40) NULL,
	[prfi_5657WarningSentDate] [datetime] NULL,
	[prfi_5657WarningDueDate] [datetime] NULL,
	[prfi_5657WarningResponseDate] [datetime] NULL,
	[prfi_5657ReportSentDate] [datetime] NULL,
	[prfi_5657ReportDueDate] [datetime] NULL,
	[prfi_5657ReportResponseDate] [datetime] NULL,
	[prfi_InitialAmountOwed] [numeric](24, 6) NULL,
	[prfi_RemainingBalance] [numeric](24, 6) NULL,
	[prfi_OldestInvoiceDate] [datetime] NULL,
	[prfi_PACADeadline] [datetime] NULL,
	[prfi_TrustProtection] [nchar](1) NULL,
	[prfi_EnteredFormalCollection] [nchar](1) NULL,
	[prfi_TotalNumberInvoices] [int] NULL,
	[prfi_InvoiceNumber] [nvarchar](30) NULL,
	[prfi_Terms] [int] NULL,
	[prfi_DueDate] [datetime] NULL,
	[prfi_DateA1LetterSent] [datetime] NULL,
	[prfi_AmountCreditorReceived] [numeric](24, 6) NULL,
	[prfi_AmountStillOwing] [numeric](24, 6) NULL,
	[prfi_CreditorCollectedReason] [nvarchar](40) NULL,
	[prfi_PRCoFormallyCollectingAmount] [numeric](24, 6) NULL,
	[prfi_PRCoCollectedAmount] [numeric](24, 6) NULL,
	[prfi_PRCoStillCollectingAmount] [numeric](24, 6) NULL,
	[prfi_CollectionSubCategory] [nvarchar](40) NULL,
	[prfi_DateAcceptanceLetterSent] [datetime] NULL,
	[prfi_DateAcceptanceLetterRcvd] [datetime] NULL,
	[prfi_DateConfirmedPaymentRcvd] [datetime] NULL,
	[prfi_PLANDateAcceptanceLetterSent] [datetime] NULL,
	[prfi_PLANDateAcceptanceLetterRcvd] [datetime] NULL,
	[prfi_PLANDateFileMailed] [datetime] NULL,
	[prfi_PLANPartnerUsed] [nvarchar](40) NULL,
	[prfi_PLANFileNumber] [nvarchar](30) NULL,
	[prfi_ArbFormClaimantRcvdDate] [datetime] NULL,
	[prfi_ArbFormRespondentRcvdDate] [datetime] NULL,
	[prfi_DocSentArbitratorDate] [datetime] NULL,
	[prfi_DocArbitratorShipMethod] [nvarchar](40) NULL,
	[prfi_DocArbitratorShipTracking] [nvarchar](50) NULL,
	[prfi_DocArbitratorReceived] [nchar](1) NULL,
	[prfi_ArbitratorDecisionDate] [datetime] NULL,
	[prfi_ArbitratorDecisionRcvdDate] [datetime] NULL,
	[prfi_AwardDocFaxDate] [datetime] NULL,
	[prfi_AwardDocEmailDate] [datetime] NULL,
	[prfi_AwardDocMailDate] [datetime] NULL,
	[prfi_OrigDocRcvdByPRCoDate] [datetime] NULL,
	[prfi_ClaimantRequestReview] [nchar](1) NULL,
	[prfi_ClaimantRequestRcvdDate] [datetime] NULL,
	[prfi_RespondentRequestReview] [nchar](1) NULL,
	[prfi_RespondentRequestRcvdDate] [datetime] NULL,
	[prfi_ArbitratorDecisionReviewDate] [datetime] NULL,
	[prfi_ArbitratorDecisionReviewRcvdDate] [datetime] NULL,
	[prfi_ReviewedAwardDocRcvdFaxDate] [datetime] NULL,
	[prfi_ReviewedAwardDocRcvdEmailDate] [datetime] NULL,
	[prfi_ReviewedAwardDocRcvdMailDate] [datetime] NULL,
	[prfi_ReviewOrigDocRcvdByPRCoDate] [datetime] NULL,
	[prfi_FinalAwardClaimantAmount] [numeric](24, 6) NULL,
	[prfi_FinalAwardRespondentAmount] [numeric](24, 6) NULL,
	[prfi_ArbitrationRcvdDate] [datetime] NULL,
	[prfi_SubmissionClosedDate] [datetime] NULL,
	[prfi_ClaimAmount] [numeric](24, 6) NULL,
	[prfi_CounterClaimAmount] [numeric](24, 6) NULL,
	[prfi_ArbitrationFeeRcvd] [nchar](1) NULL,
	[prfi_JoinLetterPrintedDate] [datetime] NULL,
	[prfi_SubmissionsClosedLetterPrintedDate] [datetime] NULL,
	[prfi_ForwardedToBoardDate] [datetime] NULL,
	[prfi_BoardDecisionDate] [datetime] NULL,
	[prfi_SettlementAmount] [numeric](24, 6) NULL,
	[prfi_OpinionFeeLetterSentDate] [datetime] NULL,
	[prfi_OpinionFeeAuthorizedDate] [datetime] NULL,
	[prfi_OpinionLetterSentDate] [datetime] NULL,
	[prfi_DisputeFeeLetterSentDate] [datetime] NULL,
	[prfi_DisputeFeeAuthorizedDate] [datetime] NULL,
	[prfi_DisputeRequestLetterDate] [datetime] NULL,
	[prfi_DisputeRequestDueDate] [datetime] NULL,
	[prfi_DisputeRequestResponseDate] [datetime] NULL,
	[prfi_DisputeRequestLetterDate2] [datetime] NULL,
	[prfi_DisputeRequestDueDate2] [datetime] NULL,
	[prfi_DisputeRequestResponseDate2] [datetime] NULL,
	[prfi_FilingFeeAmount] [numeric](24, 6) NULL,
	[prfi_ClosingLetterSentDate] [datetime] NULL,
	[prfi_FeeAmount] [numeric](24, 6) NULL,
	[prfi_CompanyId] [int] NULL,
	[prfi_BBId] [nvarchar](5) NULL,
	[prfi_DRCNumber] [nvarchar](5) NULL,
	[prfi_StartDate] [datetime] NULL,
	[prfi_EndDate] [datetime] NULL,
	[prfi_ClaimantCreditor] [nchar](1) NULL,
	[prfi_RespondentDebtor] [nchar](1) NULL,
	[prfi_AmountPRCoInvoiced_CID] [int] NULL,
	[prfi_InitialAmountOwed_CID] [int] NULL,
	[prfi_RemainingBalance_CID] [int] NULL,
	[prfi_AmountCreditorReceived_CID] [int] NULL,
	[prfi_AmountStillOwing_CID] [int] NULL,
	[prfi_PRCoFormallyCollectingAmount_CID] [int] NULL,
	[prfi_PRCoCollectedAmount_CID] [int] NULL,
	[prfi_PRCoStillCollectingAmount_CID] [int] NULL,
	[prfi_FinalAwardClaimantAmount_CID] [int] NULL,
	[prfi_FinalAwardRespondentAmount_CID] [int] NULL,
	[prfi_ClaimAmount_CID] [int] NULL,
	[prfi_CounterClaimAmount_CID] [int] NULL,
	[prfi_SettlementAmount_CID] [int] NULL,
	[prfi_FilingFeeAmount_CID] [int] NULL,
	[prfi_FeeAmount_CID] [int] NULL,
	[prfi_LockedById] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Communication]    Script Date: 11/20/2009 09:14:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Communication](
	[Comm_CommunicationId] [int] NOT NULL,
	[Comm_OpportunityId] [int] NULL,
	[Comm_CaseId] [int] NULL,
	[Comm_ChannelId] [int] NULL,
	[Comm_Type] [nchar](40) NULL,
	[Comm_Action] [nchar](40) NULL,
	[Comm_Status] [nchar](40) NULL,
	[Comm_Priority] [nchar](40) NULL,
	[Comm_DateTime] [datetime] NULL,
	[Comm_ToDateTime] [datetime] NULL,
	[Comm_Private] [nchar](1) NULL,
	[Comm_OutCome] [nchar](40) NULL,
	[Comm_Note] [ntext] NULL,
	[Comm_Email] [ntext] NULL,
	[Comm_CreatedBy] [int] NULL,
	[Comm_CreatedDate] [datetime] NULL,
	[Comm_UpdatedBy] [int] NULL,
	[Comm_UpdatedDate] [datetime] NULL,
	[Comm_TimeStamp] [datetime] NULL,
	[Comm_Deleted] [tinyint] NULL,
	[Comm_DocDir] [nvarchar](255) NULL,
	[Comm_DocName] [nvarchar](255) NULL,
	[Comm_TargetListId] [int] NULL,
	[Comm_NotifyTime] [datetime] NULL,
	[Comm_NotifyDelta] [int] NULL,
	[Comm_Description] [nvarchar](255) NULL,
	[Comm_SMSMessageSent] [nchar](5) NULL,
	[Comm_SMSNotification] [nchar](5) NULL,
	[Comm_WaveItemId] [int] NULL,
	[Comm_RecurrenceId] [int] NULL,
	[Comm_SegmentID] [int] NULL,
	[Comm_LeadID] [int] NULL,
	[Comm_SecTerr] [int] NULL,
	[Comm_WorkflowId] [int] NULL,
	[comm_messageid] [int] NULL,
	[Comm_From] [ntext] NULL,
	[Comm_TO] [ntext] NULL,
	[Comm_CC] [ntext] NULL,
	[Comm_BCC] [ntext] NULL,
	[Comm_ReplyTo] [ntext] NULL,
	[Comm_IsReplyToMsgId] [int] NULL,
	[Comm_SolutionId] [int] NULL,
	[Comm_IsHtml] [nchar](1) NULL,
	[Comm_HasAttachments] [nchar](1) NULL,
	[Comm_EmailLinksCreated] [nchar](1) NULL,
	[comm_completedtime] [datetime] NULL,
	[comm_percentcomplete] [int] NULL,
	[comm_taskreminder] [nchar](1) NULL,
	[Comm_CRMOnly] [nchar](1) NULL,
	[Comm_UID] [nchar](140) NULL,
	[Comm_OriginalDateTime] [datetime] NULL,
	[Comm_OriginalToDateTime] [datetime] NULL,
	[Comm_Exception] [nchar](1) NULL,
	[comm_PRBusinessEventId] [int] NULL,
	[comm_PRPersonEventId] [int] NULL,
	[comm_PRTESId] [int] NULL,
	[comm_PRCreditSheetId] [int] NULL,
	[comm_PRFileId] [int] NULL,
	[comm_PRCategory] [nvarchar](40) NULL,
	[comm_PRSubcategory] [nvarchar](40) NULL,
	[comm_PRAuthorId] [int] NULL,
	[comm_PRCallAttemptCount] [int] NULL,
	[comm_PRAssociatedColumnName] [nvarchar](40) NULL,
	[comm_RequestID] [int] NULL,
 CONSTRAINT [PK_Communication] PRIMARY KEY CLUSTERED 
(
	[Comm_CommunicationId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PRFilePayment]    Script Date: 11/20/2009 09:15:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PRFilePayment](
	[prfp_FilePaymentId] [int] NOT NULL,
	[prfp_Deleted] [int] NULL,
	[prfp_WorkflowId] [int] NULL,
	[prfp_Secterr] [int] NULL,
	[prfp_CreatedBy] [int] NULL,
	[prfp_CreatedDate] [datetime] NULL,
	[prfp_UpdatedBy] [int] NULL,
	[prfp_UpdatedDate] [datetime] NULL,
	[prfp_TimeStamp] [datetime] NULL,
	[prfp_FileId] [int] NOT NULL,
	[prfp_PaymentAmount] [numeric](24, 6) NULL,
	[prfp_DueDate] [datetime] NULL,
	[prfp_ReceivedDate] [datetime] NULL,
	[prfp_PaymentAmount_CID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PRServiceAlaCarte]    Script Date: 11/20/2009 09:16:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PRServiceAlaCarte](
	[prsac_PRServiceAlaCarteId] [int] NOT NULL,
	[prsac_Deleted] [int] NULL,
	[prsac_WorkflowId] [int] NULL,
	[prsac_Secterr] [int] NULL,
	[prsac_CreatedBy] [int] NULL,
	[prsac_CreatedDate] [datetime] NULL,
	[prsac_UpdatedBy] [int] NULL,
	[prsac_UpdatedDate] [datetime] NULL,
	[prsac_TimeStamp] [datetime] NULL,
	[prsac_ID] [int] NULL,
	[prsac_NonmemberUsageID] [int] NULL,
	[prsac_PurchaseType] [nvarchar](40) NULL,
	[prsac_PurchaseDate] [datetime] NULL,
	[prsac_RefNum] [nvarchar](50) NULL,
	[prsac_Amount] [numeric](24, 6) NULL,
	[prsac_IPAddress] [nvarchar](15) NULL,
	[prsac_CreditCardNumber] [nvarchar](4) NULL,
	[prsac_CreditCardType] [nvarchar](40) NULL,
	[prsac_ExpirationDateMonth] [int] NULL,
	[prsac_ExpirationDateYear] [int] NULL,
	[prsac_BBID] [nvarchar](1) NULL,
	[prsac_FirstName] [nvarchar](17) NULL,
	[prsac_MI] [nvarchar](1) NULL,
	[prsac_LastName] [nvarchar](19) NULL,
	[prsac_CompanyName] [nvarchar](48) NULL,
	[prsac_Address1] [nvarchar](35) NULL,
	[prsac_Address2] [nvarchar](35) NULL,
	[prsac_City] [nvarchar](25) NULL,
	[prsac_County] [nvarchar](1) NULL,
	[prsac_State] [nvarchar](11) NULL,
	[prsac_Country] [nvarchar](36) NULL,
	[prsac_PostalCode] [nvarchar](10) NULL,
	[prsac_Phone] [nvarchar](19) NULL,
	[prsac_Fax] [nvarchar](19) NULL,
	[prsac_Email] [nvarchar](36) NULL,
	[prsac_WebSite] [nvarchar](29) NULL,
	[prsac_JobTitle] [nvarchar](42) NULL,
	[prsac_Classification] [nvarchar](14) NULL,
	[prsac_CompanySize] [nvarchar](10) NULL,
	[prsac_AutoEmail] [nvarchar](5) NULL,
	[prsac_UnitAllocationID] [nvarchar](1) NULL,
	[prsac_PurchaseTerms] [nvarchar](8) NULL,
	[prsac_LearnedText] [nvarchar](82) NULL,
	[prsac_UsageType] [nvarchar](1) NULL,
	[prsac_SubjectBBID] [int] NULL,
	[prsac_Field037] [nvarchar](255) NULL,
	[prsac_MLCount] [int] NULL,
	[prsac_UsageLevel] [nvarchar](1) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Comm_Link]    Script Date: 11/20/2009 09:14:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Comm_Link](
	[CmLi_CommLinkId] [int] NOT NULL,
	[CmLi_Comm_UserId] [int] NULL,
	[CmLi_Comm_CommunicationId] [int] NOT NULL,
	[CmLi_CreatedBy] [int] NULL,
	[CmLi_CreatedDate] [datetime] NULL,
	[CmLi_UpdatedBy] [int] NULL,
	[CmLi_UpdatedDate] [datetime] NULL,
	[CmLi_TimeStamp] [datetime] NULL,
	[CmLi_Deleted] [tinyint] NULL,
	[CmLi_Comm_PersonId] [int] NULL,
	[CmLi_Comm_CompanyId] [int] NULL,
	[CmLi_Comm_NotifyTime] [datetime] NULL,
	[CmLi_Comm_InitialWave] [nchar](1) NULL,
	[CmLi_Comm_WaveResponse] [nchar](40) NULL,
	[CmLi_Comm_LeadID] [int] NULL,
	[Cmli_SMSMessageSent] [nchar](2) NULL,
	[Cmli_MassEmailSent] [nchar](1) NULL,
	[cmli_status] [int] NULL,
	[cmli_recipient] [nchar](255) NULL,
	[cmli_reminder] [nchar](1) NULL,
 CONSTRAINT [PK_Comm_Link] PRIMARY KEY CLUSTERED 
(
	[CmLi_CommLinkId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CmLi_Comm_CommunicationId] ON [dbo].[Comm_Link] 
(
	[CmLi_Comm_CommunicationId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PRARAging]    Script Date: 11/20/2009 09:14:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PRARAging](
	[praa_ARAgingId] [int] NOT NULL,
	[praa_Deleted] [int] NULL,
	[praa_WorkflowId] [int] NULL,
	[praa_Secterr] [int] NULL,
	[praa_CreatedBy] [int] NULL,
	[praa_CreatedDate] [datetime] NULL,
	[praa_UpdatedBy] [int] NULL,
	[praa_UpdatedDate] [datetime] NULL,
	[praa_TimeStamp] [datetime] NULL,
	[praa_CompanyId] [int] NOT NULL,
	[praa_PersonId] [int] NULL,
	[praa_Date] [datetime] NULL,
	[praa_RunDate] [datetime] NULL,
	[praa_DateSelectionCriteria] [nvarchar](40) NULL,
	[praa_ARAgingImportFormatID] [int] NULL,
	[praa_ImportedDate] [datetime] NULL,
	[praa_ImportedByUserId] [int] NULL,
	[praa_ManualEntry] [nchar](1) NULL,
PRIMARY KEY CLUSTERED 
(
	[praa_ARAgingId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PRARAgingDetail]    Script Date: 11/20/2009 09:14:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PRARAgingDetail](
	[praad_ARAgingDetailId] [int] NOT NULL,
	[praad_Deleted] [int] NULL,
	[praad_WorkflowId] [int] NULL,
	[praad_Secterr] [int] NULL,
	[praad_CreatedBy] [int] NULL,
	[praad_CreatedDate] [datetime] NULL,
	[praad_UpdatedBy] [int] NULL,
	[praad_UpdatedDate] [datetime] NULL,
	[praad_TimeStamp] [datetime] NULL,
	[praad_ARAgingId] [int] NOT NULL,
	[praad_ARCustomerId] [nvarchar](15) NULL,
	[praad_FileCompanyName] [nvarchar](200) NULL,
	[praad_FileCityName] [nvarchar](100) NULL,
	[praad_FileStateName] [nvarchar](10) NULL,
	[praad_FileZipCode] [nvarchar](10) NULL,
	[praad_Amount0to29] [numeric](24, 6) NULL,
	[praad_Amount30to44] [numeric](24, 6) NULL,
	[praad_Amount45to60] [numeric](24, 6) NULL,
	[praad_Amount61Plus] [numeric](24, 6) NULL,
	[praad_Exception] [nchar](1) NULL,
	[praad_CreditTerms] [int] NULL,
	[praad_ManualCompanyId] [int] NULL,
	[praad_TimeAged] [nvarchar](100) NULL,
	[praad_CreditTermsText] [varchar](50) NULL,
	[praad_AmountCurrent] [numeric](24, 6) NULL,
	[praad_Amount1to30] [numeric](24, 6) NULL,
	[praad_Amount31to60] [numeric](24, 6) NULL,
	[praad_Amount61to90] [numeric](24, 6) NULL,
	[praad_Amount91Plus] [numeric](24, 6) NULL,
	[praad_PhoneNumber] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[praad_ARAgingDetailId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
CREATE NONCLUSTERED INDEX [ndx_praad_ARAgingId] ON [dbo].[PRARAgingDetail] 
(
	[praad_ARAgingId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PRRequest]    Script Date: 11/20/2009 09:15:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
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
PRIMARY KEY CLUSTERED 
(
	[prreq_RequestID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PRRequestDetail]    Script Date: 11/20/2009 09:15:56 ******/
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
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_prcc_RequestID] ON [dbo].[PRRequestDetail] 
(
	[prrc_RequestID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PRTransaction]    Script Date: 11/20/2009 09:16:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PRTransaction](
	[prtx_TransactionId] [int] NOT NULL,
	[prtx_Deleted] [int] NULL,
	[prtx_WorkflowId] [int] NULL,
	[prtx_Secterr] [int] NULL,
	[prtx_CreatedBy] [int] NULL,
	[prtx_CreatedDate] [datetime] NULL,
	[prtx_UpdatedBy] [int] NULL,
	[prtx_UpdatedDate] [datetime] NULL,
	[prtx_TimeStamp] [datetime] NULL,
	[prtx_CompanyId] [int] NULL,
	[prtx_PersonId] [int] NULL,
	[prtx_BusinessEventId] [int] NULL,
	[prtx_PersonEventId] [int] NULL,
	[prtx_EffectiveDate] [datetime] NULL,
	[prtx_AuthorizedById] [int] NULL,
	[prtx_AuthorizedInfo] [nvarchar](50) NULL,
	[prtx_NotificationType] [nvarchar](40) NULL,
	[prtx_NotificationStimulus] [nvarchar](40) NULL,
	[prtx_CreditSheetId] [int] NULL,
	[prtx_Explanation] [ntext] NOT NULL,
	[prtx_RedbookDate] [datetime] NULL,
	[prtx_Status] [nvarchar](40) NULL,
	[prtx_CloseDate] [datetime] NULL,
	[prtx_Listing] [varchar](8000) NULL,
	[prtx_ParentTransactionID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[prtx_TransactionId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PRAdCampaignAuditTrail]    Script Date: 11/20/2009 09:14:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
PRIMARY KEY CLUSTERED 
(
	[pradcat_AdCampaignAuditTrailID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PRTransactionDetail]    Script Date: 11/20/2009 09:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PRTransactionDetail](
	[prtd_TransactionDetailId] [int] NOT NULL,
	[prtd_Deleted] [int] NULL,
	[prtd_WorkflowId] [int] NULL,
	[prtd_Secterr] [int] NULL,
	[prtd_CreatedBy] [int] NULL,
	[prtd_CreatedDate] [datetime] NULL,
	[prtd_UpdatedBy] [int] NULL,
	[prtd_UpdatedDate] [datetime] NULL,
	[prtd_TimeStamp] [datetime] NULL,
	[prtd_TransactionId] [int] NOT NULL,
	[prtd_EntityName] [nvarchar](50) NULL,
	[prtd_ColumnName] [nvarchar](250) NULL,
	[prtd_Action] [nvarchar](10) NULL,
	[prtd_ColumnType] [nvarchar](40) NULL,
	[prtd_OldValue] [varchar](max) NULL,
	[prtd_NewValue] [varchar](max) NULL,
 CONSTRAINT [PK__PRTransactionDet__1F98B2C1] PRIMARY KEY CLUSTERED 
(
	[prtd_TransactionDetailId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
CREATE NONCLUSTERED INDEX [ndx_prtd_TransactionId] ON [dbo].[PRTransactionDetail] 
(
	[prtd_TransactionId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PREquifaxAuditLog]    Script Date: 11/20/2009 09:14:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
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
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PREquifaxAuditLogDetail]    Script Date: 11/20/2009 09:14:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
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
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
CREATE NONCLUSTERED INDEX [IX_preqfald_EquifaxAuditLogID] ON [dbo].[PREquifaxAuditLogDetail] 
(
	[preqfald_EquifaxAuditLogID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PRExternalLinkAuditTrail]    Script Date: 11/20/2009 09:15:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
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
	[prelat_URL] [varchar](500) NOT NULL,
	[prelat_TriggerPage] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[prelat_ExternalLinkAuditTrailID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PRSearchAuditTrailCriteria]    Script Date: 11/20/2009 09:16:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
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
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
CREATE NONCLUSTERED INDEX [IX_PRSearchAuditTrailCriteria] ON [dbo].[PRSearchAuditTrailCriteria] 
(
	[prsatc_SearchAuditTrailID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PRSearchAuditTrail]    Script Date: 11/20/2009 09:16:02 ******/
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
 CONSTRAINT [PK__PRSearchAuditTra__412EB0B6] PRIMARY KEY CLUSTERED 
(
	[prsat_SearchAuditTrailID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PRSearchWizardAuditTrail]    Script Date: 11/20/2009 09:16:09 ******/
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
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PRSearchWizardAuditTrailDetail]    Script Date: 11/20/2009 09:16:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
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
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
CREATE NONCLUSTERED INDEX [IX_PRSearchWizardAuditTrailDetail] ON [dbo].[PRSearchWizardAuditTrailDetail] 
(
	[prswaud_SearchWizardAuditTrailID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PRWebServiceAuditTrail]    Script Date: 11/20/2009 09:16:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
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
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PRTES]    Script Date: 11/20/2009 09:16:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PRTES](
	[prte_TESId] [int] NOT NULL,
	[prte_Deleted] [int] NULL,
	[prte_WorkflowId] [int] NULL,
	[prte_Secterr] [int] NULL,
	[prte_CreatedBy] [int] NULL,
	[prte_CreatedDate] [datetime] NULL,
	[prte_UpdatedBy] [int] NULL,
	[prte_UpdatedDate] [datetime] NULL,
	[prte_TimeStamp] [datetime] NULL,
	[prte_ResponderCompanyId] [int] NOT NULL,
	[prte_Date] [datetime] NULL,
	[prte_ResponseDate] [datetime] NULL,
	[prte_HowSent] [nvarchar](40) NULL,
	[prte_FaxNumber] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[prte_TESId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PRTESDetail]    Script Date: 11/20/2009 09:16:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PRTESDetail](
	[prt2_TESDetailId] [int] NOT NULL,
	[prt2_Deleted] [int] NULL,
	[prt2_WorkflowId] [int] NULL,
	[prt2_Secterr] [int] NULL,
	[prt2_CreatedBy] [int] NULL,
	[prt2_CreatedDate] [datetime] NULL,
	[prt2_UpdatedBy] [int] NULL,
	[prt2_UpdatedDate] [datetime] NULL,
	[prt2_TimeStamp] [datetime] NULL,
	[prt2_TESId] [int] NOT NULL,
	[prt2_SubjectCompanyId] [int] NOT NULL,
	[prt2_TESFormID] [int] NULL,
	[prt2_Received] [nchar](1) NULL,
	[prt2_Source] [nvarchar](40) NULL,
PRIMARY KEY CLUSTERED 
(
	[prt2_TESDetailId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PRTESDetail] ON [dbo].[PRTESDetail] 
(
	[prt2_TESId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO


/****** Object:  Table [dbo].[PRAUS]    Script Date: 12/21/2009 15:02:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PRAUS](
	[prau_AUSId] [int] NOT NULL,
	[prau_Deleted] [int] NULL,
	[prau_WorkflowId] [int] NULL,
	[prau_Secterr] [int] NULL,
	[prau_CreatedBy] [int] NULL,
	[prau_CreatedDate] [datetime] NULL DEFAULT (getdate()),
	[prau_UpdatedBy] [int] NULL,
	[prau_UpdatedDate] [datetime] NULL DEFAULT (getdate()),
	[prau_TimeStamp] [datetime] NULL DEFAULT (getdate()),
	[prau_PersonId] [int] NOT NULL DEFAULT ((-1)),
	[prau_CompanyId] [int] NOT NULL DEFAULT ((-1)),
	[prau_MonitoredCompanyId] [int] NOT NULL DEFAULT ((-1)),
	[prau_ShowOnHomePage] [nchar](1) NULL,
PRIMARY KEY CLUSTERED 
(
	[prau_AUSId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO