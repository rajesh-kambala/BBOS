USE [CRMExperian]
GO

/****** Object:  UserDefinedFunction [dbo].[ufn_GetCompanyRelationshipsList]    Script Date: 11/25/2017 2:43:58 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

alter FUNCTION [dbo].[ufn_GetExperianStatusCode]
(
    @RequestId int = NULL,
    @CompanyId int = NULL
)
RETURNS nchar(1)
AS 
BEGIN
    
	declare @status_code nchar(1) = '?'

	set @status_code = (select top 1 [prexd_StatusCode] from dbo.[PRExperianData] where [prexd_RequestID] = @RequestId and [prexd_CompanyID] = @CompanyId)

	return @status_code

END
GO


