if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[address]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[address]
GO

CREATE TABLE [dbo].[address](
	[BBID] [float] NULL,
	[ADDRSEQ] [float] NULL,
	[DEFSHIP] [varchar](1) NULL,
	[DEFMAIL] [varchar](1) NULL,
--	[DEFBILL] [varchar](1) NULL,
	[DEFATTN] [varchar](44) NULL,
--	[SHOWTRADESTYLE] [varchar](1) NULL,
--	[ADDRHEAD] [varchar](34) NULL,
	[STREETADDR] varchar(200) NULL,
	[CITY] [varchar](34) NULL,
--	[STATE] [varchar](30) NULL,
	[STATEABBREV] [varchar](2) NULL,
	[COUNTRY] [varchar](30) NULL,
	[POSTALCODE] [varchar](15) NULL,
--	[SHOWPOSTALCODE] [varchar](1) NULL,
--	[ZONE] [varchar](2) NULL,
	[ADDRTYPE] [varchar](9) NULL,
    [LIST] [varchar](1) NULL,
	[LISTSEQ] [smallint] NULL,
--	[ADDRESS] [text] NULL,
--	[CUSTLABEL] [varchar](1) NULL,
	[COUNTY] [varchar](25) NULL,
	[TAXADDR] [varchar](1) NULL,
--	[TAXINDICATOR] [varchar](1) NULL,
--	[STD_STREETADDR] [varchar](50) NULL,
--	[STD_CITY] [varchar](28) NULL,
--	[STD_STATEABBREV] [varchar](2) NULL,
--	[STD_POSTALCODE] [varchar](10) NULL,
	[BILLADDR] [varchar](1) NULL,
	[LISTADDR] [varchar](1) NULL
)
Go


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[affil]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[affil]
GO

CREATE TABLE [dbo].[affil](
	[BBID1] [float] NULL,
	[BBID2] [float] NULL,
--	[AFFTYPE] [varchar](2) NULL,
--	[LOWSHARE] [float] NULL,
--	[HIGHSHARE] [float] NULL
)
GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[brands]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[brands]
GO

CREATE TABLE [dbo].[brands](
	[BBID] [float] NULL,
	[LISTSEQ] [smallint] NULL,
	[BRAND] [varchar](34) NULL,
--	[DESC] [varchar](60) NULL,
--	[CUSTOM] [varchar](1) NULL,
	[LIST] [varchar](1) NULL
)
Go


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[classval]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[classval]
GO

CREATE TABLE [dbo].[classval](
	[CLASSIF] [varchar](50) NULL,
	[DESC] [varchar](50) NULL,
	[DESC_SPANISH] [varchar](50) NULL,
--	[SECTION] [varchar](1) NULL
)	
Go



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[license]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[license]
GO

CREATE TABLE [dbo].[license](
	[BBID] [float] NULL,
	[SEQ] [float] NULL,
	[TYPE] [varchar](8) NULL,
	[NUMBER] [varchar](34) NULL,
	[LIST] [varchar](1) NULL
--	[LISTSEQ] [smallint] NULL
)


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[listing]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[listing]
GO


CREATE TABLE [dbo].[listing](
	[BBID] [float] NOT NULL,
	[BOOKSECTION] [varchar](1) NULL,
	[COUNTRY] [varchar](30) NULL,
	[STATE] [varchar](30) NULL,
	[CITY] [varchar](34) NULL,
	[ORDERTRDSTYL] [varchar](104) NULL,
	[BOOKTRDSTYL] [varchar](104) NULL,
	[STATEABBREV] [varchar](2) NULL,
        [CHAINSTORES_MEMO] [text] NULL,
	[TRADESTYLEMEMO] [text] NULL,
	[PARENMEMO] [text] NULL,
	[ADDRMEMO] [text] NULL,
	[PHONEMEMO] [text] NULL,
	[INTERNETMEMO] [varchar](255) NULL,
	[DLLMEMO] [text] NULL,
	[BRANDSMEMO] [text] NULL,
	[WHULHRSMEMO] [text] NULL,
	[BANKSMEMO] [varchar](150) NULL,
	[STOCKMEMO] [varchar](100) NULL,
	[LICENSEMEMO] [varchar](100) NULL,
	[MBRDATE] [varchar](4) NULL,
	[CLASSIFMEMO] [varchar](250) NULL,
	[VOLUME] [float] NULL,
	[COMMODMEMO] [text] NULL,
	[SUPPLYMEMO] [text] NULL,
	[RATINGMEMO] [varchar](100) NULL,
	[LISTINGMEMO] [text] NULL,
	[PAIDLINES] [smallint] NULL,
	[STATUS] [varchar](2) NULL,
	[HOLD] [varchar](1) NULL,
	[SENDFSREQ] [varchar](8) NULL,
	[CORRTRDSTYL] [varchar](104) NULL,
	[CHNSTRS] [varchar](1) NULL,
	[HQBBID] [float] NULL,
	[HQBR] [varchar](1) NULL,
	[FSDATE] [datetime] NULL,
	[CLDATE] [datetime] NULL,
        [RATINGDESC] [varchar] (15) NULL,
	[WEBSTATUS] [varchar](1) NULL,
	[WEBACTIVATEDATE] [datetime] NULL,
	[BILLATTN] [varchar](44) NULL,
	[LISTATTN] [varchar](44) NULL,
	[COMMCODE] [varchar](2) NULL,
	[ACCT_TIER] [varchar](1) NULL
)
GO

ALTER TABLE [dbo].[listing] WITH NOCHECK ADD 
	CONSTRAINT [PK_listing] PRIMARY KEY CLUSTERED ([BBID]) WITH  FILLFACTOR = 90,
	CONSTRAINT [DF_CHNSTRS] DEFAULT ('N') FOR [CHNSTRS]
GO

CREATE  INDEX [IX_status] ON [dbo].[listing]([STATUS])
GO



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[persaff]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[persaff]
GO

CREATE TABLE [dbo].[persaff](
	[BBID] [float] NULL,
	[PERSONID] [int] NULL,
	[STATUS] [varchar](1) NULL,
--	[TRIP] [varchar](1) NULL,
--	[WHENVISITED] [varchar](21) NULL,
--	[BRSEQ] [smallint] NULL,
	[TITLE] [varchar](45) NULL,
	[SHARE] [varchar](6) NULL,
--	[STARTYEAR] [smallint] NULL,
--	[REVSTARTYEAR] [smallint] NULL,
--	[ENDYEAR] [smallint] NULL,
--	[ENDREASON] [varchar](1) NULL,
	[PRESIDENT] [varchar](1) NULL,
	[TREASURER] [varchar](1) NULL,
	[SALES] [varchar](1) NULL,
	[MARKETING] [varchar](1) NULL,
	[OPERATIONS] [varchar](1) NULL,
	[INFORMATION] [varchar](1) NULL,
	[CREDIT] [varchar](1) NULL,
	[BUYER] [varchar](1) NULL,
	[DISPATCHER] [varchar](1) NULL,
	[WEBPASSWORD] [varchar](8) NULL,
	[WEBSTATUS] [varchar](1) NULL,
	[LISTSEQ] [smallint] NULL,
	[LISTYN] [varchar](1) NULL
--	[BRYN] [varchar](1) NULL,
--	[GENERICTITLE] [varchar](45) NULL,
--	[RESPCONN] [varchar](1) NULL
)

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PERSON]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[PERSON]
GO

CREATE TABLE [dbo].[PERSON](
	[PERSONID] [int] NULL,
	[FIRSTNAME] [varchar](20)  NULL,
	[NICKNAME] [varchar](20)  NULL,
	[MIDDLENAME] [varchar](20)  NULL,
	[LASTNAME] [varchar](35)  NULL,
	[AFTERNAME] [varchar](8)  NULL,
	[FULLNAME] [varchar](86)  NULL,
	[FULLNICKNAME] [varchar](86)  NULL,
	[GENDER] [varchar](1)  NULL
--	[INDUSTRYSTARTYEAR] [smallint] NULL,
--	[BIRTHYEAR] [smallint] NULL,
--	[DEATHYEAR] [smallint] NULL,
--	[CITIZENSHIP] [varchar](8)  NULL,
--	[EDUCATION] [varchar](8)  NULL,
--	[RESPHONE] [varchar](20)  NULL,
--	[NOTES] [ntext]  NULL,
--	[WEBUSERID] [varchar](20)  NULL,
--	[MAIDENNAME] [varchar](35)  NULL
)


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[phones]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[phones]
GO

CREATE TABLE [dbo].[phones](
	[BBID] [float] NULL,
	[SEQ] [smallint] NULL,
	[PHONETYPE] [varchar](8) NULL,
--	[HEADER] [varchar](34) NULL,
--	[CUSTPHONE] [varchar](1) NULL,
	[PHONE] [varchar](34) NULL,
--	[DESC] [varchar](34) NULL,
	[LIST] [varchar](1) NULL,
	[LISTSEQ] [smallint] NULL,
	[DEFFAX] [varchar](1) NULL,
--	[INTERNATIONAL] [varchar](1) NULL,
	[DEFPHONE] [varchar](1) NULL,
        [AREACODE] [varchar](20) NULL,
        [COUNTRYCODE] [varchar](5) NULL
)


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[cmdval]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[cmdval]
GO

CREATE TABLE [dbo].[cmdval](
	[COMMOD] [varchar](45) NULL,
	[DESC] [varchar](40) NULL,
	[DESC_SPANISH] [varchar](45) NULL,
--	[CATEGORY] [varchar](8) NULL,
	[KEY] [varchar](1) NULL
) 


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[commod]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[commod]
GO

CREATE TABLE [dbo].[commod](
    ID bigint identity(1,1),
	[BBID] [float] NULL,
	[COMMOD] [varchar](34) NULL,
--	[LIST] [varchar](1) NULL,
	[LISTSEQ] [smallint] NULL
)

ALTER TABLE [dbo].[commod] WITH NOCHECK ADD CONSTRAINT [PK_commod] PRIMARY KEY CLUSTERED (ID) WITH  FILLFACTOR = 90
CREATE  INDEX [IX_BBID] ON [dbo].[commod](BBID)
CREATE  INDEX [IX_COMMOD] ON [dbo].[commod]([COMMOD])
GO

GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[classif]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[classif]
GO

CREATE TABLE [dbo].[classif](
    ID bigint identity(1,1),
	[BBID] [float] NULL,
	[CLASSIF] [varchar](50) NULL,
--	[LIST] [varchar](1) NULL,
	[LISTSEQ] [smallint] NULL
)
Go

ALTER TABLE [dbo].[classif] WITH NOCHECK ADD CONSTRAINT [PK_classif] PRIMARY KEY CLUSTERED (ID) WITH  FILLFACTOR = 90
CREATE  INDEX [IX_classif] ON [dbo].[classif](BBID)
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[supply]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[supply]
GO

CREATE TABLE [dbo].[supply](
	ID bigint identity(1,1),
	[BBID] [float] NULL,
	[LISTSEQ] [smallint] NULL,
	[SUPPLY] [varchar](34) NULL
--	[LIST] [varchar](1) NULL
) 

ALTER TABLE [dbo].[supply] WITH NOCHECK ADD CONSTRAINT [PK_supply] PRIMARY KEY CLUSTERED (ID) WITH  FILLFACTOR = 90
CREATE  INDEX [IX_supply] ON [dbo].[supply](BBID)
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[suppval]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[suppval]
GO

CREATE TABLE [dbo].[suppval](
	[SUPPLY] [varchar](34) NULL,
--	[REFERENCE] [varchar](1) NULL,
	[LINE1] [varchar](40) NULL,
	[LINE2] [varchar](40) NULL,
	[LINE3] [varchar](40) NULL,
	[LINE4] [varchar](40) NULL,
	[SUPPKEY] [varchar](10) NULL,
	[SUPPLY_SPANISH] [varchar](50) NULL
) ON [PRIMARY]
Go



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rating]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[rating]
GO

CREATE TABLE [dbo].[rating](
	[BBID] [float] NULL,
--	[JEOPARDY] [varchar](1) NULL,
--	[REASON] [varchar](40) NULL,
--	[AUTHOR] [varchar](5) NULL,
--	[DATRTG] [datetime] NULL,
--	[TIME] [float] NULL,
--	[DATFS] [datetime] NULL,
--	[DATCLR] [datetime] NULL,
--	[DATCL] [datetime] NULL,
--	[DATINVEST] [datetime] NULL,
--	[DATREVIEW] [datetime] NULL,
--	[CLRCAND] [varchar](1) NULL,
--	[FSFORM] [varchar](20) NULL,
	[MORALID] [float] NULL,
	[PAYID] [float] NULL,
	[WORTHID] [float] NULL,
--	[RTGREV] [varchar](1) NULL,
	[RTGNUMS] [varchar](50) NULL,
	[AFLNUMS] [varchar](12) NULL,
--	[PREVRATING] [varchar](40) NULL,
	[RATING] [varchar](40) NULL,
    [81Flag] int NULL
)
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[towns]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[towns]
GO

CREATE TABLE [dbo].[towns](
	[CITY] [varchar](34) NULL,
	[STATE] [varchar](30) NULL,
	[COUNTRY] [varchar](30) NULL,
	[STATEABBREV] [varchar](2) NULL,
	[COUNTY] [varchar](30) NULL
--	[DEFTRIPID] [varchar](8) NULL,
--	[DEFINVGRPID] [varchar](9) NULL
)
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[internet]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[internet]
GO

CREATE TABLE [dbo].[internet](
	[BBID] [float] NULL,
	[SEQ] [smallint] NULL,
	[HEADER] [varchar](50) NULL,
	[INTTYPE] [varchar](5) NULL,
	[INTLOC] [varchar](50) NULL,
	[LISTSEQ] [smallint] NULL,
	[LIST] [varchar](1) NULL,
	[DEFEMAIL] [varchar](1) NULL
)
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ChangeDetection]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[ChangeDetection]
GO

CREATE TABLE [dbo].[ChangeDetection] (
	[BBID] [float] NOT NULL,
	[LastUpdatedDateTime] [datetime] NULL
)

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CompanyFilter]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[CompanyFilter]
GO

CREATE TABLE [dbo].[CompanyFilter] (
	[BBID] int NOT NULL
)



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[service]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[service]
GO

CREATE TABLE [dbo].[service](
	[SVCID] [float] NOT NULL primary key,
	[BBID] [float] NULL,
	[SVCTYPE] [varchar](15) NULL,
	[BILLBBID] [float] NULL,
	[INITDATE] [datetime] NULL,
	[STARTDATE] [datetime] NULL,
	[BILLDATE] [datetime] NULL,
	[EXPDATE] [datetime] NULL,
	--[BILLTODATE] [datetime] NULL,
	--[CANCELFROMDATE] [datetime] NULL,
	--[TAXAUTHORITY] [varchar](4) NULL,
	--[HOUSEORFIELD] [varchar](1) NULL,
	[STATUS] [varchar](3) NULL,
	[HOLDSHIP] [varchar](5) NULL,
	[HOLDMAIL] [varchar](5) NULL,
	--[HOLDBILL] [varchar](5) NULL,
	--[CHANGETIME] [datetime] NULL,
	--[CHANGEDBY] [varchar](5) NULL,
	[SUBCODE] [varchar](15) NULL,
	[EBBSERIAL] [varchar](9) NULL,
	--[COMBO] [varchar](9) NULL,
	[PRIMARY] [varchar](1) NULL,
	[CODEENDDATE] [datetime] NULL,
	[CONTRACTSTATUS] [varchar](1) NULL,
	[TERMS] [varchar](2) NULL,
	[INQWHO] [varchar](8) NULL,
	--[INQTYPE] [varchar](8) NULL,
	--[INQINIT] [varchar](8) NULL,
	--[INQREASON] [varchar](8) NULL,
	--[INQDETAIL] [varchar](8) NULL,
	--[INVOICELETTER] [varchar](1) NULL,
	--[PONUMBER] [varchar](15) NULL,
	--[OLDSVCID] [float] NULL,
	--[OLDSVCCODE] [varchar](2) NULL,
	--[NEWDATE] [datetime] NULL,
	--[NEWTYPE] [varchar](1) NULL,
	--[CANDATE] [datetime] NULL,
	--[CANTYPE] [varchar](1) NULL,
	--[CANACCTTIER] [varchar](1) NULL,
	--[INIT_ALLOC_ID] [int] NULL,
	--[INIT_ALLOC_YEAR] [smallint] NULL,
	--[MAIL_CS] [varchar](1) NULL,
	--[CANCEL_PENDING] [varchar](1) NULL,
	--[BBSS_STATUS] [varchar](1) NULL,
	--[BBSS_ATTN] [varchar](44) NULL,
	--[BBSS_EMAIL] [varchar](80) NULL,
	--[CANUNITS] [smallint] NULL,
	[DISCOUNTPCT] [int] NULL,
    [ComboCode] [varchar](25) NULL,
    [ApprovalDate] varchar(50) NULL
)
Go


CREATE NONCLUSTERED INDEX [ndx_ServiceBBID] ON [dbo].[service] 
(
	[BBID] ASC
)

GO


CREATE NONCLUSTERED INDEX [ndx_Service2] ON [dbo].[service] 
(
	[BBID] ASC,
	[SVCTYPE] ASC,
	[STATUS] ASC
)
Go


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PRServicePayment]') AND type in (N'U'))
	DROP TABLE [dbo].[PRServicePayment]
GO
CREATE TABLE [dbo].[PRServicePayment](
	[prsp_ServicePaymentId] [int] NOT NULL,
	[prsp_Deleted] [int] NULL,
	[prsp_WorkflowId] [int] NULL,
	[prsp_Secterr] [int] NULL,
	[prsp_CreatedBy] [int] NULL,
	[prsp_CreatedDate] [datetime] NULL DEFAULT (getdate()),
	[prsp_UpdatedBy] [int] NULL,
	[prsp_UpdatedDate] [datetime] NULL DEFAULT (getdate()),
	[prsp_TimeStamp] [datetime] NULL DEFAULT (getdate()),
	[prsp_ServiceId] [int] NOT NULL DEFAULT ((-1)),
	[prsp_InvoiceDate] [datetime] NULL,
	[prsp_MasterInvoiceNumber] [nvarchar](20) NULL,
	[prsp_SubInvoiceNumber] [nvarchar](20) NULL,
	[prsp_BilledAmount] [numeric](24, 6) NULL,
	[prsp_PaymentDueDate] [datetime] NULL,
	[prsp_PaymentReceivedDate] [datetime] NULL,
	[prsp_ReceivedAmount] [numeric](24, 6) NULL,
	[prsp_BillingPeriodStart] [datetime] NULL,
	[prsp_BillingPeriodEnd] [datetime] NULL,
	[prsp_Tax] [numeric](24, 6) NULL,
	[prsp_CheckNumber] [nvarchar](20) NULL,
	[prsp_Balance] [numeric](24, 6) NULL,
	[prsp_TransactionDate] [datetime] NULL,
	[prsp_Activity] [nvarchar](40) NULL,
	[prsp_Effect] [numeric](24, 6) NULL,
	[prsp_ServiceCode] [nvarchar](15) NULL
)
GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[outbooks]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[outbooks]
GO

CREATE TABLE [dbo].[outbooks](
	[BOOKID] [varchar](10) NULL,
	[BBID] [float] NULL,
	[SVCID] [float] NULL,
	[PUBNUM] [varchar](3) NULL,
	[HOW] [varchar](1) NULL,
	--[STATE] [varchar](2) NULL,
	[LABELDATE] [datetime] NULL,
	--[MASS] [varchar](1) NULL,
	--[LINE1] [varchar](44) NULL,
	--[LINE2] [varchar](44) NULL,
	--[LINE3] [varchar](44) NULL,
	--[LINE4] [varchar](44) NULL,
	--[LINE5] [varchar](44) NULL,
	--[LINE6] [varchar](44) NULL,
	--[LINE7] [varchar](44) NULL,
	--[LASTATTNLINE] [smallint] NULL,
	--[LOCATION] [varchar](44) NULL,
	--[ZONE] [smallint] NULL,
	--[EBBSERIAL] [varchar](9) NULL,
	--[PRESORT] [varchar](1) NULL,
	--[SHIP_COMPANY] [varchar](35) NULL,
	--[SHIP_ATTENTION] [varchar](35) NULL,
	--[SHIP_ADDRESS1] [varchar](35) NULL,
	--[SHIP_ADDRESS2] [varchar](35) NULL,
	--[SHIP_CITY] [varchar](30) NULL,
	--[SHIP_STATE] [varchar](5) NULL,
	--[SHIP_COUNTRY] [varchar](30) NULL,
	--[SHIP_ZIP] [varchar](10) NULL,
	--[SHIP_PHONE] [varchar](15) NULL,
	[TRACKINGNO] [varchar](50) NULL
)


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[svctyval]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[svctyval]
GO

CREATE TABLE [dbo].[svctyval](
	[SVCTYPE] [varchar](15) NULL,
	[DESC] [varchar](50) NULL,
	--[SORTORDER] [smallint] NULL,
	--[CHLABEL] [varchar](1) NULL,
	[AMOUNT] [float] NULL,
	[WEBUNITS] [smallint] NULL
	--[PRIMARY] [varchar](1) NULL,
	--[GROUP] [varchar](1) NULL,
	--[GROUPORDER] [smallint] NULL,
	--[TAXEXEMPT] [varchar](1) NULL,
	--[CHARGETYPE] [varchar](1) NULL,
	--[UPSFIELD] [smallint] NULL,
	--[FEDEXKEY] [varchar](8) NULL,
	--[CHANGETO] [varchar](2) NULL,
	--[M90DESC] [varchar](30) NULL,
	--[CSASGROUP] [smallint] NULL,
	--[HOMEPAGE] [varchar](1) NULL,
	--[LOGO] [varchar](1) NULL,
	--[FUTURES] [varchar](1) NULL,
	--[SERIES] [varchar](5)
)



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[bkcodevl]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[bkcodevl]
GO

CREATE TABLE [dbo].[bkcodevl](
	[BOOKCODE] [varchar](1) NULL,
	[DESC] [varchar](30) NULL
)


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ar]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[ar]
GO

CREATE TABLE [dbo].[ar](
	[KEYFIELD] [int] NOT NULL,
	--[BILLTOBBID] [int] NULL,
	[LISTBBID] [int] NULL,
	[SVCID] [int] NULL,
	[MASTINVNO] [varchar](7) NULL,
	[SUBINVNO] [varchar](7) NULL,
	--[TRANSDATE] [datetime] NULL,
	--[ACTIVITY] [varchar](1) NULL,
	[BILLPERSTART] [datetime] NULL,
	[BILLPEREND] [datetime] NULL,
	[AMOUNT] [float] NULL,
	[TAX] [float] NULL,
	--[PAYDATE] [datetime] NULL,
	[PAYAMOUNT] [float] NULL,
	[CHECKNO] [varchar](10) NULL
	--[TAXSTATE] [varchar](2) NULL,
	--[TAXCOUNTY] [varchar](25) NULL,
	--[TAXCITY] [varchar](28) NULL,
	--[TAXZIP] [varchar](5) NULL,
	--[TAXRATE] [float] NULL,
	--[LOCTAXEXEMPT] [varchar](1) NULL,
	--[EFFECT] [float] NULL,
	--[BALANCEDUE] [float] NULL,
	--[SVCCODE] [varchar](2) NULL,
	--[INVOICEDATE] [datetime] NULL
) ON [PRIMARY]


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[pubaddr]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[pubaddr]
GO

CREATE TABLE [dbo].[pubaddr](
	[SVCID] [float] NULL,
	[PUBTYPE] [varchar](5) NULL,
	[STARTMMDD] [varchar](4) NULL,
	[HOW] [varchar](1) NULL,
	[INCLUDE] [varchar](1) NULL,
	[ATTN] [varchar](44) NULL,
	[ADDRID] [smallint] NULL,
	[EXC] [varchar](1) NULL
)


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[dpastdue]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[dpastdue]
GO

CREATE TABLE [dbo].[dpastdue](
	[BBID] [int] NOT NULL,
	[DAYS] [smallint] NULL
)
Go

ALTER TABLE [dbo].[dpastdue] WITH NOCHECK ADD CONSTRAINT [PK_dpastdue] PRIMARY KEY CLUSTERED (BBID) WITH  FILLFACTOR = 90
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[servsusp]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[servsusp]
GO

CREATE TABLE [dbo].[servsusp](
	[SVCID] [int] NULL,
	[BBID] [int] NULL
)
Go

CREATE  INDEX [IX_servsusp] ON [dbo].[servsusp](BBID)
GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[dpastdue]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[dpastdue]
GO

CREATE TABLE [dbo].[dpastdue](
	[BBID] [int] NOT NULL,
	[DAYS] [smallint] NULL,
 CONSTRAINT [PK_dpastdue] PRIMARY KEY CLUSTERED 
(
	[BBID] ASC
) 
)



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Logo]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[Logo]
GO

CREATE TABLE [dbo].[Logo](
	[BBID] [int] NOT NULL,
	[Logo] [int] NULL,
 CONSTRAINT [PK_Logo] PRIMARY KEY CLUSTERED 
(
	[BBID] ASC
) 
)



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DeleteDetection]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[DeleteDetection]
GO

CREATE TABLE [dbo].[DeleteDetection](
	[BBID] [int] NOT NULL,
	[DeleteDateTime] [datetime] NULL,
)



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MAS90ChangeDetection]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[MAS90ChangeDetection]
GO

CREATE TABLE [dbo].[MAS90ChangeDetection](
	[BBID] [int] NOT NULL,
	[ChangeDateTime] [datetime] NULL,
)



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[InterfaceStatus]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[InterfaceStatus]
GO

CREATE TABLE [dbo].[InterfaceStatus](
	ID bigint identity(1,1),
	[InterfaceID] [int] NOT NULL,
	[IsExecuting] [int] NOT NULL,
    [StartDateTime] [datetime] NOT NULL,
	[EndDateTime] [datetime] NULL,
	[UserID] varchar(200) NULL,
	[Notes] varchar(5000) NULL
 CONSTRAINT [PK_InterfaceStatusID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
) 
);



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[EBBUpdate]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[EBBUpdate]
GO

CREATE TABLE [dbo].[EBBUpdate](
	CSEXPDATE	datetime NULL,
	BBID	float NULL,
	BOOKTRDSTYL	varchar(104) NULL,
	CITY	varchar(34) NULL,
	STATEABBREV	varchar(2) NULL,
	COUNTRY	varchar(34) NULL,
	CHANGEDATE datetime NULL,
	KEYITEM	char(1) NULL,
	ITEMTEXT text NULL);
Go

-- NOTE: This same code is in the PRCo Database Build - Security.sql
-- file.  If this is changed, most likely this other script will need
-- to be changed.
USE [BBSInterface]
If NOT EXISTS (SELECT Name FROM sysusers WHERE Name = 'accpac') BEGIN
	CREATE USER accpac FOR LOGIN accpac;
	EXEC sp_addrolemember 'db_owner', 'accpac'
END
GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[gfx]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[gfx]
GO

CREATE TABLE [dbo].[gfx](
	[SVCID] [int] NULL,
    [BBID] [int] NULL,
    [LogoID] [int] NULL
)
Go