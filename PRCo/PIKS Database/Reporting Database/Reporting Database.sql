IF OBJECT_ID('dbo.ServiceDetail') IS NOT NULL
	DROP TABLE dbo.ServiceDetail
GO

CREATE TABLE [dbo].[ServiceDetail](
	[ServiceDetailID] [int] identity(1, 1) NOT NULL,
	[YearMonth] [int] NOT NULL,
	[YearQuarter] [int] NOT NULL,
	[ServiceCode] varchar(40) NOT NULL,
	[ServiceCodeOrder] varchar(40) NOT NULL,
	[SalesTerritory] varchar(10) NULL,
	--[CountryID] varchar(10) NULL,
	--[StateID] varchar(10) NULL,
	[TMFMAward] varchar(1) NULL,
	[Primary] varchar(1) NULL,
	[ServiceType] varchar(10) NULL,
	[CompanyID] int NOT NULL,
	[QuantityOrdered] int NULL,
	[DiscountPct] decimal(24,6) NULL,
	[ExtensionAmt] decimal(24,6) NULL,
	[StandardUnitPrice] decimal(24,6) NULL,
	[CreatedDateTime] [datetime] NOT NULL CONSTRAINT DF_ServiceDetail_CreatedDateTime DEFAULT (getdate())
 CONSTRAINT [PK_ServiceDetailID] PRIMARY KEY NONCLUSTERED 
(
	[ServiceDetailID] ASC
))


IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[ServiceDetail]') AND name = N'ndx_ServiceDetail_01')
	CREATE CLUSTERED INDEX [ndx_ServiceDetail_01] ON [dbo].ServiceDetail (YearMonth, ServiceCode) 
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[ServiceDetail]') AND name = N'ndx_ServiceDetail_02')
	CREATE NONCLUSTERED INDEX [ndx_ServiceDetail_02] ON [dbo].ServiceDetail(YearQuarter, ServiceCode) 
GO



IF OBJECT_ID('dbo.MembershipGeographicTrend') IS NOT NULL
	DROP TABLE dbo.MembershipGeographicTrend
GO

CREATE TABLE [dbo].[MembershipGeographicTrend](
	[MembershipGeographicTrendID] [int] identity(1, 1) NOT NULL,
	[YearMonth] [int] NOT NULL,
	[YearQuarter] [int] NOT NULL,
	[ServiceCode] varchar(50) NOT NULL,
	[ServiceCodeOrder] int,
	[CountryID] varchar(10) NULL,
	[StateID] varchar(10) NULL,
	[Count] int NULL,
	[Revenue] decimal(24,6) NULL,
	[CreatedDateTime] [datetime] NOT NULL CONSTRAINT DF_MembershipGeographicTrend_CreatedDateTime DEFAULT (getdate())
 CONSTRAINT [PK_MembershipGeographicTrendID] PRIMARY KEY NONCLUSTERED 
(
	[MembershipGeographicTrendID] ASC
))



IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[MembershipGeographicTrend]') AND name = N'ndx_MembershipGeographicTrend_01')
	CREATE CLUSTERED INDEX [ndx_MembershipGeographicTrend_01] ON [dbo].MembershipGeographicTrend (YearMonth, ServiceCode) 
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[MembershipGeographicTrend]') AND name = N'ndx_MembershipGeographicTrend_02')
	CREATE NONCLUSTERED INDEX [ndx_MembershipGeographicTrend_02] ON [dbo].MembershipGeographicTrend (YearQuarter, ServiceCode) 
GO





IF OBJECT_ID('dbo.MembershipTrend') IS NOT NULL
	DROP TABLE dbo.MembershipTrend
GO

CREATE TABLE [dbo].[MembershipTrend](
	[MembershipTrendID] [int] identity(1, 1) NOT NULL,
	[YearMonth] [int] NOT NULL,
	[YearQuarter] [int] NOT NULL,
	[ServiceCode] varchar(50) NOT NULL,
	[ServiceCodeOrder] int,
	[SalesTerritory] varchar(10) NULL,
	[Count] int NULL,
	[Revenue] decimal(24,6) NULL,
	[CreatedDateTime] [datetime] NOT NULL CONSTRAINT DF_MembershipTrend_CreatedDateTime DEFAULT (getdate())
 CONSTRAINT [PK_MembershipTrendID] PRIMARY KEY NONCLUSTERED 
(
	[MembershipTrendID] ASC
))



IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[MembershipTrend]') AND name = N'ndx_MembershipTrend_01')
	CREATE CLUSTERED INDEX [ndx_MembershipTrend_01] ON [dbo].MembershipTrend (YearMonth, ServiceCode) 
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[MembershipTrend]') AND name = N'ndx_MembershipTrend_02')
	CREATE NONCLUSTERED INDEX [ndx_MembershipTrend_02] ON [dbo].MembershipTrend (YearQuarter, ServiceCode) 
GO





IF OBJECT_ID('dbo.AddlLicenseTrend') IS NOT NULL
	DROP TABLE dbo.AddlLicenseTrend
GO

CREATE TABLE [dbo].[AddlLicenseTrend](
	[AddlLicenseTrendID] [int] identity(1, 1) NOT NULL,
	[YearMonth] [int] NOT NULL,
	[YearQuarter] [int] NOT NULL,
	[ServiceCode] varchar(50) NOT NULL,
	[ServiceCodeOrder] int,
	[SalesTerritory] varchar(10) NULL,
	[Count] int NULL,
	[Revenue] decimal(24,6) NULL,
	[CreatedDateTime] [datetime] NOT NULL CONSTRAINT DF_AddlLicenseTrend_CreatedDateTime DEFAULT (getdate())
 CONSTRAINT [PKAddlLicenseTrendID] PRIMARY KEY NONCLUSTERED 
(
	[AddlLicenseTrendID] ASC
))



IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[AddlLicenseTrend]') AND name = N'ndx_AddlLicenseTrend_01')
	CREATE CLUSTERED INDEX [ndx_AddlLicenseTrend_01] ON [dbo].AddlLicenseTrend (YearMonth, ServiceCode) 
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[AddlLicenseTrend]') AND name = N'ndx_AddlLicenseTrend_02')
	CREATE NONCLUSTERED INDEX [ndx_AddlLicenseTrend_02] ON [dbo].AddlLicenseTrend (YearQuarter, ServiceCode) 
GO



IF OBJECT_ID('dboAddlLicenseGeographicTrend') IS NOT NULL
	DROP TABLE dbo.AddlLicenseGeographicTrend
GO

CREATE TABLE [dbo].[AddlLicenseGeographicTrend](
	[AddlLicenseGeographicTrendID] [int] identity(1, 1) NOT NULL,
	[YearMonth] [int] NOT NULL,
	[YearQuarter] [int] NOT NULL,
	[ServiceCode] varchar(50) NOT NULL,
	[ServiceCodeOrder] int,
	[CountryID] varchar(10) NULL,
	[StateID] varchar(10) NULL,
	[Count] int NULL,
	[Revenue] decimal(24,6) NULL,
	[CreatedDateTime] [datetime] NOT NULL CONSTRAINT DF_AddlLicenseGeographicTrend_CreatedDateTime DEFAULT (getdate())
 CONSTRAINT [PK_AddlLicenseGeographicTrendID] PRIMARY KEY NONCLUSTERED 
(
	[AddlLicenseGeographicTrendID] ASC
))



IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[AddlLicenseGeographicTrend]') AND name = N'ndx_AddlLicenseGeographicTrend_01')
	CREATE CLUSTERED INDEX [ndx_AddlLicenseGeographicTrend_01] ON [dbo].AddlLicenseGeographicTrend (YearMonth, ServiceCode) 
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[AddlLicenseGeographicTrend]') AND name = N'ndx_AddlLicenseGeographicTrend_02')
	CREATE NONCLUSTERED INDEX [ndx_AddlLicenseGeographicTrend_02] ON [dbo].AddlLicenseGeographicTrend (YearQuarter, ServiceCode) 
GO







IF OBJECT_ID('dbo.AuxServiceTrend') IS NOT NULL
	DROP TABLE dbo.AuxServiceTrend
GO

CREATE TABLE [dbo].[AuxServiceTrend](
	[AuxServiceTrendID] [int] identity(1, 1) NOT NULL,
	[YearMonth] [int] NOT NULL,
	[YearQuarter] [int] NOT NULL,
	[ServiceCode] varchar(50) NOT NULL,
	[ServiceCodeOrder] int,
	[SalesTerritory] varchar(10) NULL,
	[Count] int NULL,
	[Revenue] decimal(24,6) NULL,
	[CreatedDateTime] [datetime] NOT NULL CONSTRAINT DF_AuxServiceTrend_CreatedDateTime DEFAULT (getdate())
 CONSTRAINT [PKAuxServiceTrendID] PRIMARY KEY NONCLUSTERED 
(
	[AuxServiceTrendID] ASC
))



IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[AuxServiceTrend]') AND name = N'ndx_AuxServiceTrend_01')
	CREATE CLUSTERED INDEX [ndx_AuxServiceTrend_01] ON [dbo].AuxServiceTrend (YearMonth, ServiceCode) 
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[AuxServiceTrend]') AND name = N'ndx_AuxServiceTrend_02')
	CREATE NONCLUSTERED INDEX [ndx_AuxServiceTrend_02] ON [dbo].AuxServiceTrend (YearQuarter, ServiceCode) 
GO



IF OBJECT_ID('dbo.AuxServiceGeographicTrend') IS NOT NULL
	DROP TABLE dbo.AuxServiceGeographicTrend
GO

CREATE TABLE [dbo].[AuxServiceGeographicTrend](
	[AuxServiceGeographicTrendID] [int] identity(1, 1) NOT NULL,
	[YearMonth] [int] NOT NULL,
	[YearQuarter] [int] NOT NULL,
	[ServiceCode] varchar(50) NOT NULL,
	[ServiceCodeOrder] int,
	[CountryID] varchar(10) NULL,
	[StateID] varchar(10) NULL,
	[Count] int NULL,
	[Revenue] decimal(24,6) NULL,
	[CreatedDateTime] [datetime] NOT NULL CONSTRAINT DF_AuxServiceGeographicTrend_CreatedDateTime DEFAULT (getdate())
 CONSTRAINT [PK_AuxServiceGeographicTrendID] PRIMARY KEY NONCLUSTERED 
(
	[AuxServiceGeographicTrendID] ASC
))



IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[AuxServiceGeographicTrend]') AND name = N'ndx_AuxServiceGeographicTrend_01')
	CREATE CLUSTERED INDEX [ndx_AuxServiceGeographicTrend_01] ON [dbo].AuxServiceGeographicTrend (YearMonth, ServiceCode) 
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[AuxServiceGeographicTrend]') AND name = N'ndx_AuxServiceGeographicTrend_02')
	CREATE NONCLUSTERED INDEX [ndx_AuxServiceGeographicTrend_02] ON [dbo].AuxServiceGeographicTrend (YearQuarter, ServiceCode) 
GO





IF OBJECT_ID('dbo.MembershipNewTrend') IS NOT NULL
	DROP TABLE dbo.MembershipNewTrend
GO

CREATE TABLE [dbo].[MembershipNewTrend](
	[MembershipNewTrendID] [int] identity(1, 1) NOT NULL,
	[YearMonth] [int] NOT NULL,
	[YearQuarter] [int] NOT NULL,
	[SalesTerritory] varchar(10) NULL,
	[ServiceCode] varchar(50) NOT NULL,
	[Count] int NULL,
	[Revenue] decimal(24,6) NULL,
	[CreatedDateTime] [datetime] NOT NULL CONSTRAINT DF_MembershipNewTrend_CreatedDateTime DEFAULT (getdate())
 CONSTRAINT [PK_MembershipNewTrendID] PRIMARY KEY NONCLUSTERED 
(
	[MembershipNewTrendID] ASC
))



IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[MembershipNewTrend]') AND name = N'ndx_MembershipNewTrend_01')
	CREATE CLUSTERED INDEX [ndx_MembershipNewTrend_01] ON [dbo].[MembershipNewTrend] (YearMonth, ServiceCode) 
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[MembershipNewTrend]') AND name = N'ndx_MembershipNewTrend_02')
	CREATE NONCLUSTERED INDEX [ndx_MembershipNewTrend_02] ON [dbo].[MembershipNewTrend] (YearQuarter, ServiceCode) 
GO




IF OBJECT_ID('dbo.MembershipCancelTrend') IS NOT NULL
	DROP TABLE dbo.MembershipCancelTrend
GO

CREATE TABLE [dbo].[MembershipCancelTrend](
	[MembershipCancelTrendID] [int] identity(1, 1) NOT NULL,
	[YearMonth] [int] NOT NULL,
	[YearQuarter] [int] NOT NULL,
	[SalesTerritory] varchar(10) NULL,
	[ServiceCode] varchar(50) NOT NULL,
	[Count] int NULL,
	[Revenue] decimal(24,6) NULL,
	[CreatedDateTime] [datetime] NOT NULL CONSTRAINT DF_MembershipCancelTrend_CreatedDateTime DEFAULT (getdate())
 CONSTRAINT [PK_MembershipCancelTrendID] PRIMARY KEY NONCLUSTERED 
(
	[MembershipCancelTrendID] ASC
))



IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[MembershipCancelTrend]') AND name = N'ndx_MembershipCancelTrend_01')
	CREATE CLUSTERED INDEX [ndx_MembershipCancelTrend_01] ON [dbo].[MembershipCancelTrend] (YearMonth, ServiceCode) 
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[MembershipCancelTrend]') AND name = N'ndx_MembershipCancelTrend_02')
	CREATE NONCLUSTERED INDEX [ndx_MembershipCancelTrend_02] ON [dbo].[MembershipCancelTrend] (YearQuarter, ServiceCode) 
GO