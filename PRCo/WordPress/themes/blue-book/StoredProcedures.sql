USE [WordPressProduce]
GO
/****** Object:  StoredProcedure [dbo].[sp_WhatSQLIsExecuting]    Script Date: 10/17/2023 9:46:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[sp_WhatSQLIsExecuting]
AS
/*--------------------------------------------------------------------
Purpose: Shows what individual SQL statements are currently executing.
----------------------------------------------------------------------
Parameters: None.
Revision History:
	24/07/2008  Ian_Stirk@yahoo.com Initial version
Example Usage:
	1. exec YourServerName.master.dbo.dba_WhatSQLIsExecuting               
---------------------------------------------------------------------*/
BEGIN
    -- Do not lock anything, and do not get held up by any locks.
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

    -- What SQL Statements Are Currently Running?
    SELECT [Spid] = session_Id
	, ecid
	, [Database] = DB_NAME(sp.dbid)
	, [User] = nt_username
	, [Status] = er.status
	, [Wait] = wait_type
	, [Individual Query] = SUBSTRING (qt.text, 
             er.statement_start_offset/2,
	(CASE WHEN er.statement_end_offset = -1
	       THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2
		ELSE er.statement_end_offset END - 
                                er.statement_start_offset)/2)
	,[Parent Query] = qt.text
	, Program = program_name
	, Hostname
	, nt_domain
	, start_time
    FROM sys.dm_exec_requests er
    INNER JOIN sys.sysprocesses sp ON er.session_id = sp.spid
    CROSS APPLY sys.dm_exec_sql_text(er.sql_handle)as qt
    WHERE session_Id NOT IN (@@SPID)     -- Ignore this current statement.
    ORDER BY 1, 2
END

GO
/****** Object:  StoredProcedure [dbo].[usp_CompanySearchByFirstLetter]    Script Date: 10/17/2023 9:46:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Patrick Johnson
-- Create date: 10/16/2023
-- Description:	Search Companies by the first letter
-- =============================================
CREATE PROCEDURE [dbo].[usp_CompanySearchByFirstLetter]
	@SearchValue nvarchar(100) = ''
AS
BEGIN
	SET NOCOUNT ON;

	IF(@SearchValue != '0')
	BEGIN
		SELECT *
		FROM vPRCompanySearch
		WHERE comp_PRCorrTradestyle LIKE @SearchValue + '%'
		ORDER BY comp_PRCorrTradestyle
	END
	ELSE
	BEGIN
		SELECT *
		FROM vPRCompanySearch
		WHERE SUBSTRING(comp_PRCorrTradestyle, 1, 1) LIKE '[^a-z]%'
		ORDER BY comp_PRCorrTradestyle
	END
END

GO
/****** Object:  StoredProcedure [dbo].[usp_CompanySearchByID]    Script Date: 10/17/2023 9:46:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Patrick Johnson
-- Create date: 10/16/2023
-- Description:	Search Companies by ID
-- =============================================
CREATE PROCEDURE [dbo].[usp_CompanySearchByID]
	@ID int = 0
AS
BEGIN
	SET NOCOUNT ON;

	SELECT * FROM vPRCompanySearch WHERE comp_CompanyID = @ID
END

GO
/****** Object:  StoredProcedure [dbo].[usp_GetCompanyByID]    Script Date: 10/17/2023 9:46:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Patrick Johnson
-- Create date: 10/16/2023
-- Description:	Get Company by ID
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetCompanyByID]
	@ID int = 0
AS
BEGIN
	SET NOCOUNT ON;

	SELECT TOP 1 * FROM vPRBBOSCompany WHERE comp_CompanyID = @ID
END

GO
/****** Object:  StoredProcedure [dbo].[usp_GetCompanyClassificationByCompanyID]    Script Date: 10/17/2023 9:46:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Patrick Johnson
-- Create date: 10/16/2023
-- Description:	Get Company Classification By Company ID
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetCompanyClassificationByCompanyID]
	@ID int = 0
AS
BEGIN
	SET NOCOUNT ON;

	SELECT COUNT(1) AS classificationcount FROM vPRCompanyClassification WHERE prc2_CompanyID = @ID
END

GO
/****** Object:  StoredProcedure [dbo].[usp_GetCompanyCommodityAttributeByCompanyID]    Script Date: 10/17/2023 9:46:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Patrick Johnson
-- Create date: 10/16/2023
-- Description:	Get Company Commodity Attribute By Company ID
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetCompanyCommodityAttributeByCompanyID]
	@ID int = 0
AS
BEGIN
	SET NOCOUNT ON;

	SELECT COUNT(1) AS commoditycount FROM vPRCompanyCommodityAttribute WHERE prcca_CompanyID = @ID
END

GO
/****** Object:  StoredProcedure [dbo].[usp_GetSocialMediaByCompanyID]    Script Date: 10/17/2023 9:46:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Patrick Johnson
-- Create date: 10/16/2023
-- Description:	Get Social Media Data By Company ID
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetSocialMediaByCompanyID]
	@ID int = 0
AS
BEGIN
	SET NOCOUNT ON;

	SELECT * FROM vPRSocialMedia WHERE prsm_CompanyID = @ID
END

GO
