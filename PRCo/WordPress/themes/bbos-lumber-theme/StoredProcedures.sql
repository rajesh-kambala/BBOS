USE [WordPressLumber]
GO
/****** Object:  StoredProcedure [dbo].[usp_CompanySearchByFirstLetter]    Script Date: 10/17/2023 9:50:53 PM ******/
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
/****** Object:  StoredProcedure [dbo].[usp_CompanySearchByID]    Script Date: 10/17/2023 9:50:53 PM ******/
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
/****** Object:  StoredProcedure [dbo].[usp_FixDuplicateAuthorCustomField]    Script Date: 10/17/2023 9:50:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Patrick Johnson
-- Create date: 10/16/2023
-- Description:	Fix Duplicate Author Custom Field By Meta ID
-- =============================================
CREATE PROCEDURE [dbo].[usp_FixDuplicateAuthorCustomField]
	@MetaID int = 0
AS
BEGIN
	SET NOCOUNT ON;

	SELECT TOP 1 meta_id
	FROM [wp_postmeta]
	WHERE post_id IN (
		SELECT post_id
		FROM [wp_postmeta]
		WHERE meta_id = @MetaID
	)
	AND meta_key = 'author'
	AND meta_id <> @MetaID
END

GO
/****** Object:  StoredProcedure [dbo].[usp_GetCompanyByID]    Script Date: 10/17/2023 9:50:53 PM ******/
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
/****** Object:  StoredProcedure [dbo].[usp_GetCompanyClassificationByCompanyID]    Script Date: 10/17/2023 9:50:53 PM ******/
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
/****** Object:  StoredProcedure [dbo].[usp_GetCompanyCommodityAttributeByCompanyID]    Script Date: 10/17/2023 9:50:53 PM ******/
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
/****** Object:  StoredProcedure [dbo].[usp_GetSocialMediaByCompanyID]    Script Date: 10/17/2023 9:50:53 PM ******/
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
