USE [NACMImport]
GO
/****** Object:  Table [dbo].[Creditor]    Script Date: 05/06/2009 07:56:04 ******/
DROP TABLE [dbo].[Creditor]
GO
/****** Object:  Table [dbo].[Debtor]    Script Date: 05/06/2009 07:56:08 ******/
DROP TABLE [dbo].[Debtor]
GO
/****** Object:  UserDefinedFunction [dbo].[ufn_ProcessName]    Script Date: 05/06/2009 07:56:09 ******/
DROP FUNCTION [dbo].[ufn_ProcessName]
GO
/****** Object:  Table [dbo].[ARAging]    Script Date: 05/06/2009 07:56:01 ******/
DROP TABLE [dbo].[ARAging]
GO
/****** Object:  UserDefinedFunction [dbo].[ufn_GetLowerAlpha]    Script Date: 05/06/2009 07:56:09 ******/
DROP FUNCTION [dbo].[ufn_GetLowerAlpha]
GO
/****** Object:  UserDefinedFunction [dbo].[ufn_GetLowerAlpha]    Script Date: 05/06/2009 07:56:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ufn_GetLowerAlpha](@sText varchar(max))
RETURNS varchar(max)
AS
BEGIN
    DECLARE @AlphaOnly varchar(8000), @CurrentChar varchar(1)
    DECLARE @idx smallint,
              @bcontinue bit,
            @Ascii int
    SET @idx = 0
    SET @sText = LTrim(RTrim(@sText))
    SET @sText = Lower(@sText)
    SET @bcontinue = 1
    SET @AlphaOnly = '';
    WHILE (@idx <= DataLength(@sText)) BEGIN
        SET @CurrentChar = SubString(@sText, @idx, 1)
        SET @Ascii = ASCII(@CurrentChar)
        IF (@Ascii >= ASCII('a')) BEGIN
            IF (@Ascii <= ASCII('z')) BEGIN
                SET @AlphaOnly = @AlphaOnly + @CurrentChar
            END 
        END
        IF (@Ascii >= ASCII('0')) BEGIN
            IF (@Ascii <= ASCII('9')) BEGIN
                SET @AlphaOnly = @AlphaOnly + @CurrentChar
            END 
        END
        SET @idx = @idx + 1
    END
    RETURN @AlphaOnly
END
GO
/****** Object:  Table [dbo].[Creditor]    Script Date: 05/06/2009 07:56:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Creditor](
	[CreditorID] [int] IDENTITY(1,1) NOT NULL,
	[CreditorName] [varchar](50) NOT NULL,
	[ExtractDate] [datetime] NULL,
	[RecordCount] [int] NULL,
	[TotalRHC] [decimal](24, 6) NULL,
	[TotalAcctbal] [decimal](24, 6) NULL,
	[TotalCurrent] [decimal](24, 6) NULL,
	[TotalPD30] [decimal](24, 6) NULL,
	[TotalPD60] [decimal](24, 6) NULL,
	[TotalPD90] [decimal](24, 6) NULL,
	[TotalPD90over] [decimal](24, 6) NULL,
 CONSTRAINT [PK_Creditor] PRIMARY KEY CLUSTERED 
(
	[CreditorID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Debtor]    Script Date: 05/06/2009 07:56:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Debtor](
	[DebtorID] [int] IDENTITY(1,1) NOT NULL,
	[DupNameValue] [varchar](100) NOT NULL,
	[AccountName] [varchar](100) NULL,
	[AdditionalName] [varchar](100) NULL,
	[street] [varchar](100) NULL,
	[street2] [varchar](50) NULL,
	[city] [varchar](50) NULL,
	[stateProvince] [varchar](50) NULL,
	[postalcode] [varchar](50) NULL,
	[AccountID] [varchar](50) NULL,
	[SIC] [varchar](50) NULL,
	[AccountPhone] [varchar](25) NULL,
	[IsEstimatedYearsOpen] [varchar](10) NULL,
	[YearsOpen] [int] NULL,
 CONSTRAINT [PK_Debitor] PRIMARY KEY CLUSTERED 
(
	[DebtorID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
CREATE NONCLUSTERED INDEX [IX_Debtor] ON [dbo].[Debtor] 
(
	[DupNameValue] ASC,
	[city] ASC,
	[stateProvince] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Debtor_1] ON [dbo].[Debtor] 
(
	[AccountPhone] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ARAging]    Script Date: 05/06/2009 07:56:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ARAging](
	[ARAgingID] [int] IDENTITY(1,1) NOT NULL,
	[DebtorID] [int] NOT NULL,
	[CreditorID] [int] NOT NULL,
	[ExtractDate] [datetime] NULL,
	[AccountID] [varchar](50) NULL,
	[AmtTotal] [decimal](24, 6) NULL,
	[AmtCurrent] [decimal](24, 6) NULL,
	[AmtPD30] [decimal](24, 6) NULL,
	[AmtPD60] [decimal](24, 6) NULL,
	[AmtPD90] [decimal](24, 6) NULL,
	[AmtPD90over] [decimal](24, 6) NULL,
	[DateOfLastActivity] [datetime] NULL,
	[TermsIDExperian] [varchar](50) NULL,
	[HighCredit] [decimal](24, 6) NULL,
 CONSTRAINT [PK_ARAging] PRIMARY KEY CLUSTERED 
(
	[ARAgingID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  UserDefinedFunction [dbo].[ufn_ProcessName]    Script Date: 05/06/2009 07:56:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ufn_ProcessName](@sText varchar(max))
RETURNS varchar(max)
AS
BEGIN

	DECLARE @ProcessName varchar(max)
	SET @ProcessName = dbo.ufn_GetLowerAlpha(@sText)

	IF (@ProcessName LIKE '%inc') BEGIN
		SET @ProcessName = SUBSTRING(@ProcessName, 1, LEN(@ProcessName)-3)
	END


	IF (@ProcessName LIKE '%llc') BEGIN
		SET @ProcessName = SUBSTRING(@ProcessName, 1, LEN(@ProcessName)-3)
	END

	IF (@ProcessName LIKE '%co') BEGIN
		SET @ProcessName = SUBSTRING(@ProcessName, 1, LEN(@ProcessName)-2)
	END

	IF (@ProcessName LIKE '%company') BEGIN
		SET @ProcessName = SUBSTRING(@ProcessName, 1, LEN(@ProcessName)-7)
	END

	IF (@ProcessName LIKE '%corp') BEGIN
		SET @ProcessName = SUBSTRING(@ProcessName, 1, LEN(@ProcessName)-4)
	END

    RETURN @ProcessName
END
GO
