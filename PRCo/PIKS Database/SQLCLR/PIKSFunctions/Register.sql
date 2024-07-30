USE CRM

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ufnclr_EncryptText]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[ufnclr_EncryptText]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ufnclr_DecryptText]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[ufnclr_DecryptText]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ufnclr_GetEncryptionKey]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[ufnclr_GetEncryptionKey]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspclr_PopulateEquifaxData]'))
	DROP PROCEDURE [dbo].[uspclr_PopulateEquifaxData]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ufnclr_DoesLogoExist]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[ufnclr_DoesLogoExist]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ufnclr_GetLogoWidth]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[ufnclr_GetLogoWidth]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[HTTPS_POST_JSON_UTF8]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[HTTPS_POST_JSON_UTF8]
GO



IF  EXISTS (SELECT * FROM sys.assemblies asms WHERE asms.name = N'PIKSUtils')
	DROP ASSEMBLY [PIKSUtils]
GO

IF  EXISTS (SELECT * FROM sys.assemblies asms WHERE asms.name = N'System_Drawing')
	DROP ASSEMBLY [System_Drawing]
GO

BEGIN TRY
	CREATE ASSEMBLY System_Drawing FROM 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\System.Drawing.dll' WITH PERMISSION_SET = UNSAFE
	--CREATE ASSEMBLY System_Drawing FROM 'C:\Windows\Microsoft.NET\Framework64\v2.0.50727\System.Drawing.dll' WITH PERMISSION_SET = UNSAFE
END TRY
BEGIN CATCH
	-- now rethrow
	exec usp_RethrowError				
END CATCH;
GO


DECLARE @CLRAssemblyPath varchar(512)
SELECT @CLRAssemblyPath = capt_US 
  FROM custom_captions 
 WHERE capt_Family = 'SQLCLR_BIN_PATH'


BEGIN TRY
	CREATE ASSEMBLY PIKSUtils FROM @CLRAssemblyPath + 'PIKSUtils.dll' WITH PERMISSION_SET = UNSAFE
END TRY
BEGIN CATCH
	-- now rethrow
	exec usp_RethrowError				
END CATCH;
GO






CREATE FUNCTION ufnclr_EncryptText(@Text nvarchar(50)) RETURNS nvarchar(100) AS EXTERNAL NAME PIKSUtils.PIKSUtils.EncryptText;
Go

CREATE FUNCTION ufnclr_DecryptText(@Text nvarchar(50)) RETURNS nvarchar(100) AS EXTERNAL NAME PIKSUtils.PIKSUtils.DecryptText;
Go

CREATE FUNCTION ufnclr_GetEncryptionKey() RETURNS nvarchar(100) AS EXTERNAL NAME PIKSUtils.PIKSUtils.GetEncryptionKey;
Go

CREATE PROCEDURE uspclr_PopulateEquifaxData(@RequestID int, @SubjectCompanyID int) AS EXTERNAL NAME PIKSUtils.EquifaxUtils.PopulateEquifaxData
Go

CREATE FUNCTION ufnclr_DoesLogoExist(@Text nvarchar(500)) RETURNS int AS EXTERNAL NAME PIKSUtils.PIKSUtils.DoesLogoExist;
Go

CREATE FUNCTION ufnclr_GetLogoWidth(@Text nvarchar(500)) RETURNS int AS EXTERNAL NAME PIKSUtils.PIKSUtils.GetLogoWidth;
Go

CREATE FUNCTION [dbo].[HTTPS_POST_JSON_UTF8](@url [nvarchar](max), @json_body [nvarchar](max), @custom_headers_name_value_pairs_with_semicomma_delim [nvarchar](max))
RETURNS [nvarchar](max) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME PIKSUtils.[UserDefinedFunctions].[HTTPS_POST_JSON_UTF8]
Go

