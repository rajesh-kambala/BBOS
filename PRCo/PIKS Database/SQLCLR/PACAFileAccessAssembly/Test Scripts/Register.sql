sp_configure 'clr enabled', 1
Go

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PACALicenseFile]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[PACALicenseFile]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PACAPrincipalFile]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[PACAPrincipalFile]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PACATradeFile]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[PACATradeFile]
GO

IF  EXISTS (SELECT * FROM sys.assemblies asms WHERE asms.name = N'PACAFileAccessAssembly')
	DROP ASSEMBLY [PACAFileAccessAssembly]
GO

DECLARE @CLRAssemblyPath varchar(512)
SELECT @CLRAssemblyPath = capt_US 
  FROM custom_captions 
 WHERE capt_Family = 'SQLCLR_BIN_PATH'

BEGIN TRY
	--EXECUTE AS User = 'DBFileAccess'; 
	CREATE ASSEMBLY PacaFileAccessAssembly FROM @CLRAssemblyPath + 'PACAFileAccessAssembly.dll' WITH PERMISSION_SET = UNSAFE
/*
	CREATE ASSEMBLY PacaFileAccessAssembly
		FROM @CLRAssemblyPath+'PACAFileAccessAssembly.dll'
		WITH PERMISSION_SET = EXTERNAL_ACCESS; 
		REVERT
	*/
END TRY
BEGIN CATCH
	-- always revert the user context back
	REVERT
	-- now rethrow
	exec usp_RethrowError				
END CATCH;
GO

CREATE FUNCTION [dbo].[PACALicenseFile](@sDirectory [nvarchar](4000), @sFileDate [nvarchar](4000))
RETURNS  TABLE (
	[LicenseNumber] [nvarchar](max) NULL,
	[ExpirationDate] [datetime] NULL,
	[PrimaryTradeName] [nvarchar](max) NULL,
	[CompanyName] [nvarchar](max) NULL,
	[CustomerFirstName] [nvarchar](max) NULL,
	[CustomerMiddleInitial] [nvarchar](max) NULL,
	[City] [nvarchar](max) NULL,
	[State] [nvarchar](max) NULL,
	[Address1] [nvarchar](max) NULL,
	[Address2] [nvarchar](max) NULL,
	[PostCode] [nvarchar](max) NULL,
	[TypeFruitVeg] [nvarchar](max) NULL,
	[ProfCode] [nvarchar](max) NULL,
	[OwnCode] [nvarchar](max) NULL,
	[IncState] [nvarchar](max) NULL,
	[IncDate] [datetime] NULL,
	[MailAddress1] [nvarchar](max) NULL,
	[MailAddress2] [nvarchar](max) NULL,
	[MailCity] [nvarchar](max) NULL,
	[MailState] [nvarchar](max) NULL,
	[MailPostCode] [nvarchar](max) NULL,
	[AreaCode] [nvarchar](max) NULL,
	[Exchange] [nvarchar](max) NULL,
	[Telephone] [nvarchar](max) NULL,
	[TerminateDate] [datetime] NULL,
	[TerminateCode] [nvarchar](max) NULL,
	[PACARunDate] [datetime] NULL
) AS EXTERNAL NAME PacaFileAccessAssembly.[UserDefinedFunctions].[PACALicenseFile]
GO

CREATE FUNCTION [dbo].[PACAPrincipalFile](@sDirectory [nvarchar](4000), @sFileDate [nvarchar](4000))
RETURNS  TABLE (
	[LicenseNumber] [nvarchar](max) NULL,
	[LastName] [nvarchar](max) NULL,
	[FirstName] [nvarchar](max) NULL,
	[MiddleInitial] [nvarchar](max) NULL,
	[Title] [nvarchar](max) NULL,
	[City] [nvarchar](max) NULL,
	[State] [nvarchar](max) NULL,
	[PACARunDate] [datetime] NULL
) AS EXTERNAL NAME PacaFileAccessAssembly.[UserDefinedFunctions].[PACAPrincipalFile]
GO

CREATE FUNCTION [dbo].[PACATradeFile](@sDirectory [nvarchar](4000), @sFileDate [nvarchar](4000))
RETURNS  TABLE (
	[LicenseNumber] [nvarchar](max) NULL,
	[AdditionalTradeName] [nvarchar](max) NULL,
	[City] [nvarchar](max) NULL,
	[State] [nvarchar](max) NULL,
	[PACARunDate] [datetime] NULL
) AS EXTERNAL NAME PacaFileAccessAssembly.[UserDefinedFunctions].[PACATradeFile]
GO
