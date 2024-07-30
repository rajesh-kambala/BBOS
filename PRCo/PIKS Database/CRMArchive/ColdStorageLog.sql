USE [CRMArchive]
GO

/****** Object:  Table [dbo].[ColdStorageLog]    Script Date: 4/21/2021 3:33:29 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ColdStorageLog](
	[ColdStorageLogID] [int] IDENTITY(1,1) NOT NULL,
	[SourceTable] [varchar](100) NOT NULL,
	[TargetDatabase] [varchar](100) NOT NULL,
	[ThresholdDate] [datetime] NOT NULL,
	[BeforeCount] [int] NULL,
	[ColdStorageCount] [int] NULL,
	[AfterCount] [int] NULL,
	[StartDateTime] [datetime] NULL,
	[EndDateTime] [datetime] NULL,
 CONSTRAINT [PK_ColdStorageLog] PRIMARY KEY CLUSTERED 
(
	[ColdStorageLogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


	-- Shrink and backup our database, packing it up nicely!
	DBCC SHRINKDATABASE('CRMArchive_2015')
	BACKUP DATABASE [CRMArchive_2015] TO  DISK = N'D:\Applications\SQLServer_Data\Backups\Archive\CRMArchive_2015.bak' WITH NOFORMAT, COMPRESSION, INIT, SKIP, STATS = 10

	-- 52,072,488
	DBCC SHRINKDATABASE('CRMArchive')