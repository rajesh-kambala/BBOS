SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET CONCAT_NULL_YIELDS_NULL ON
SET NUMERIC_ROUNDABORT OFF
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON

USE MAS_PRC
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[SO_SalesOrderDetail]') AND name = N'ndx_SalesOrderDetail_01')
	CREATE NONCLUSTERED INDEX [ndx_SalesOrderDetail_01] ON [dbo].[SO_SalesOrderDetail]
	(
		[SalesOrderNo] ASC,
		[ItemCode] ASC,
		[TaxClass] ASC
	)
	INCLUDE ([QuantityOrdered])
GO


IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[SO_SalesOrderDetail]') AND name = N'[ndx_SalesOrderHeader_01')
	CREATE NONCLUSTERED INDEX [ndx_SalesOrderHeader_01] ON [dbo].[SO_SalesOrderHeader]
	(
		[OrderType] ASC,
		[UserCreatedKey] ASC,
		[CustomerNo] ASC,
		[SalesOrderNo] ASC,
		[TaxSchedule] ASC
	)
GO


IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[CI_Item]') AND name = N'[ndx_CI_Item_01')
	CREATE NONCLUSTERED INDEX [ndx_CI_Item_01] ON [dbo].[CI_Item] ([Category2] ASC)
GO


IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[CI_Item]') AND name = N'[ndx_CI_Item_02')
	CREATE NONCLUSTERED INDEX [ndx_CI_Item_02] ON [dbo].[CI_Item] ([Category1] ASC)
GO

/*
CREATE STATISTICS [_dta_stat_854294103_38_1] ON [dbo].[SO_SalesOrderDetail]([TaxClass], [SalesOrderNo])
go

CREATE STATISTICS [_dta_stat_854294103_4_1_38] ON [dbo].[SO_SalesOrderDetail]([ItemCode], [SalesOrderNo], [TaxClass])
go

CREATE STATISTICS [_dta_stat_918294331_3_8] ON [dbo].[SO_SalesOrderHeader]([OrderType], [CustomerNo])
go

CREATE STATISTICS [_dta_stat_918294331_124_3_8] ON [dbo].[SO_SalesOrderHeader]([UserCreatedKey], [OrderType], [CustomerNo])
go

CREATE STATISTICS [_dta_stat_918294331_8_124_1_36] ON [dbo].[SO_SalesOrderHeader]([CustomerNo], [UserCreatedKey], [SalesOrderNo], [TaxSchedule])
go

CREATE STATISTICS [_dta_stat_918294331_3_36_8_124] ON [dbo].[SO_SalesOrderHeader]([OrderType], [TaxSchedule], [CustomerNo], [UserCreatedKey])
go

CREATE STATISTICS [_dta_stat_918294331_1_3_8_124_36] ON [dbo].[SO_SalesOrderHeader]([SalesOrderNo], [OrderType], [CustomerNo], [UserCreatedKey], [TaxSchedule])
go

CREATE STATISTICS [_dta_stat_151671588_1_41] ON [dbo].[CI_Item]([ItemCode], [Category2])
go

CREATE STATISTICS [_dta_stat_151671588_16_1_41] ON [dbo].[CI_Item]([PrintReceiptLabels], [ItemCode], [Category2])
go

use [MAS_SYSTEM]
go

CREATE STATISTICS [_dta_stat_1877581727_3_2_1] ON [dbo].[SY_SalesTaxCodeDetail]([SalesTaxable], [TaxClass], [TaxCode])
go

*/


IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[AR_OpenInvoice]') AND name = N'[ndx_AR_OpenInvoice_01')
	CREATE NONCLUSTERED INDEX [ndx_AR_OpenInvoice_01] ON [dbo].[AR_OpenInvoice] ([Balance] ASC)
GO

/*
CREATE STATISTICS [_dta_stat_507148852_3_2] ON [dbo].[AR_OpenInvoice]([InvoiceNo], [CustomerNo])
go

CREATE STATISTICS [_dta_stat_507148852_2_4_3] ON [dbo].[AR_OpenInvoice]([CustomerNo], [InvoiceType], [InvoiceNo])
go

CREATE STATISTICS [_dta_stat_507148852_2_32_4_3] ON [dbo].[AR_OpenInvoice]([CustomerNo], [Balance], [InvoiceType], [InvoiceNo])
go

CREATE STATISTICS [_dta_stat_507148852_2_32_1_3] ON [dbo].[AR_OpenInvoice]([CustomerNo], [Balance], [ARDivisionNo], [InvoiceNo])
go

CREATE STATISTICS [_dta_stat_507148852_4_2_1_3_32] ON [dbo].[AR_OpenInvoice]([InvoiceType], [CustomerNo], [ARDivisionNo], [InvoiceNo], [Balance])
go
*/

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[SO_SalesOrderHistoryHeader]') AND name = N'[ndx_BBSI_SO_SalesOrderHistoryHeader_01')
	CREATE NONCLUSTERED INDEX [ndx_BBSI_SO_SalesOrderHistoryHeader_01] ON [dbo].[SO_SalesOrderHistoryHeader] ([MasterRepeatingOrderNo],[OrderStatus],[DateCreated])