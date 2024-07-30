IF EXISTS (SELECT 'x' FROM dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetYearMonth]') AND xtype IN (N'FN', N'IF', N'TF'))
	DROP FUNCTION [dbo].[ufn_GetYearMonth]
GO

CREATE FUNCTION dbo.ufn_GetYearMonth
(
	@ReportDate datetime = NULL
)
RETURNS varchar(6)
AS
BEGIN

	IF @ReportDate IS NULL BEGIN
		SET @ReportDate = GETDATE()
	END

	DECLARE @ReportYear int = YEAR(@ReportDate)
	DECLARE @ReportMonth int = MONTH(@ReportDate)

	DECLARE @YearMonth varchar(6) = CAST(@ReportYear as varchar(4)) +  CASE WHEN @ReportMonth <= 9 THEN '0' ELSE '' END + CAST(@ReportMonth as varchar(2))

	RETURN @YearMonth
END
Go


IF EXISTS (SELECT 'x' FROM dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetYearQuarter]') AND xtype IN (N'FN', N'IF', N'TF'))
	DROP FUNCTION [dbo].[ufn_GetYearQuarter]
GO

CREATE FUNCTION dbo.ufn_GetYearQuarter
(
	@ReportDate datetime = NULL
)
RETURNS varchar(6)
AS
BEGIN

	IF @ReportDate IS NULL BEGIN
		SET @ReportDate = GETDATE()
	END

	DECLARE @ReportYear int = YEAR(@ReportDate)
	DECLARE @ReportMonth int = MONTH(@ReportDate)

	DECLARE @YearQuarter varchar(6) = CAST(@ReportYear as varchar(4)) + CASE WHEN @ReportMonth <= 3 THEN '01'  WHEN @ReportMonth <= 6 THEN '02'  WHEN @ReportMonth <= 9 THEN '03' ELSE '04' END

	RETURN @YearQuarter
END
Go





IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[usp_UpdateMembershipNewTrend]') AND Type IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[usp_UpdateMembershipNewTrend]
GO

CREATE PROCEDURE [dbo].[usp_UpdateMembershipNewTrend]
        @ReportDate datetime = NULL
AS 
BEGIN

	IF (@ReportDate IS NULL) BEGIN
		SET @ReportDate = GETDATE()
	END

	DECLARE @StartDate datetime, @EndDate datetime
	SET @StartDate = CAST(MONTH(@ReportDate) as varchar) + '-1-' + CAST(YEAR(@ReportDate) as varchar(10))
	SET @EndDate = DATEADD(minute, 1439, DATEADD(day, -1, DATEADD(month, 1, @StartDate)))


	DECLARE @YearMonth varchar(6) = dbo.ufn_GetYearMonth(@ReportDate);
	DECLARE @YearQuarter varchar(6)  = dbo.ufn_GetYearQuarter(@ReportDate);


	IF NOT EXISTS (SELECT 'x' FROM MembershipNewTrend WHERE YearMonth = @YearMonth) BEGIN
		INSERT INTO MembershipNewTrend (YearMonth, YearQuarter, SalesTerritory, ServiceCode, [Count], Revenue)
		SELECT DISTINCT @YearMonth, @YearQuarter, SalesTerritory, ItemCode, 0, 0
		       FROM MAS_PRC.dbo.CI_Item WITH (NOLOCK) 
			   CROSS JOIN (SELECT DISTINCT LEFT(prci_SalesTerritory, 2) as SalesTerritory 
			                 FROM CRM.dbo.PRCity WITH (NOLOCK) 
							WHERE prci_SalesTerritory IS NOT NULL) T1
		 WHERE Category2 = 'Primary'
		  
	END ELSE BEGIN

		UPDATE MembershipNewTrend
		   SET [Count] =0, 
		       Revenue = 0,
			   CreatedDateTime = GETDATE()
         WHERE YearMonth = @YearMonth

	END


	UPDATE MembershipNewTrend
	   SET [Count] = [Count] + tmpCount,
	       [Revenue] = [Revenue] + tmpRevenue
      FROM (
			SELECT prsoat_ItemCode,
				   LEFT(prci_SalesTerritory, 2) as tmpSalesTerritory, 
				   COUNT(1) as tmpCount,
				   SUM(prsoat_ExtensionAmt) as tmpRevenue
			  FROM CRM.dbo.PRSalesOrderAuditTrail WITH (NOLOCK)
				   INNER JOIN MAS_PRC.dbo.CI_Item WITH (NOLOCK) ON prsoat_ItemCode = ItemCode
				   INNER JOIN CRM.dbo.Company WITH (NOLOCK) ON prsoat_SoldToCompany = comp_CompanyID
				   INNER JOIN CRM.dbo.vPRLocation ON comp_PRListingCityID = prci_CityID
			 WHERE prsoat_CreatedDate BETWEEN @StartDate AND @EndDate
			   AND Category2 = 'Primary'
			   AND prsoat_ActionCode = 'I'
			   AND prsoat_SoldToCompany NOT IN (SELECT prsoat_SoldToCompany 
												  FROM CRM.dbo.PRSalesOrderAuditTrail WITH (NOLOCK)
													   INNER JOIN MAS_PRC.dbo.CI_Item WITH (NOLOCK) ON prsoat_ItemCode = ItemCode
												 WHERE prsoat_CreatedDate BETWEEN @StartDate AND @EndDate
												   AND Category2 = 'Primary'
												   AND prsoat_ActionCode = 'C'
												   AND prsoat_CancelReasonCode NOT IN ('C24', 'C30'))
			GROUP BY prsoat_ItemCode,
					 LEFT(prci_SalesTerritory, 2)
			) T1
  WHERE YearMonth = @YearMonth
    AND SalesTerritory = tmpSalesTerritory
	AND ServiceCode = prsoat_ItemCode

END
Go





IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[usp_UpdateMembershipTrend]') AND Type IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[usp_UpdateMembershipTrend]
GO

CREATE PROCEDURE [dbo].[usp_UpdateMembershipTrend]
        @ReportDate datetime = NULL
AS 
BEGIN

	DECLARE @YearMonth varchar(6) = dbo.ufn_GetYearMonth(@ReportDate);
	DECLARE @YearQuarter varchar(6)  = dbo.ufn_GetYearQuarter(@ReportDate);

	IF NOT EXISTS (SELECT 'x' FROM MembershipTrend WHERE YearMonth = @YearMonth) BEGIN
		INSERT INTO MembershipTrend (YearMonth, YearQuarter, ServiceCode, ServiceCodeOrder, SalesTerritory, [Count], Revenue)
		SELECT DISTINCT @YearMonth, @YearQuarter, ItemCode, Category1, SalesTerritory, 0, 0
		       FROM MAS_PRC.dbo.CI_Item WITH (NOLOCK) 
			   CROSS JOIN (SELECT DISTINCT LEFT(prci_SalesTerritory, 2) as SalesTerritory 
			                 FROM CRM.dbo.PRCity WITH (NOLOCK) 
							WHERE prci_SalesTerritory IS NOT NULL) T1
		 WHERE Category2 = 'Primary'
		  
	END ELSE BEGIN

		UPDATE MembershipTrend
		   SET [Count] =0, 
		       Revenue = 0,
			   CreatedDateTime = GETDATE()
         WHERE YearMonth = @YearMonth

	END


	UPDATE MembershipTrend
	   SET [Count] = [Count] + tmpCount,
	       [Revenue] = [Revenue] + tmpRevenue
      FROM (
			SELECT prse_ServiceCode,
			       LEFT(prci_SalesTerritory, 2) as tmpSalesTerritory, 
				   SUM(QuantityOrdered) as tmpCount,
				   SUM(ExtensionAmt) as tmpRevenue
			  FROM CRM.dbo.PRService WITH (NOLOCK)
				   INNER JOIN CRM.dbo.Company WITH (NOLOCK) ON prse_CompanyID = comp_CompanyID
				   INNER JOIN CRM.dbo.vPRLocation WITH (NOLOCK) ON comp_PRListingCityID = prci_CityID
				   --INNER JOIN MAS_PRC.dbo.CI_Item WITH (NOLOCK)ON prse_ServiceCode = ItemCode
			 WHERE prse_Primary = 'Y'
  		  GROUP BY prse_ServiceCode, 
		           LEFT(prci_SalesTerritory, 2)
			) T1
  WHERE YearMonth = @YearMonth
    AND SalesTerritory = tmpSalesTerritory
	AND ServiceCode = prse_ServiceCode

END
Go




IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[usp_UpdateMembershipGeographicTrend]') AND Type IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[usp_UpdateMembershipGeographicTrend]
GO

CREATE PROCEDURE [dbo].[usp_UpdateMembershipGeographicTrend]
        @ReportDate datetime = NULL
AS 
BEGIN

	DECLARE @YearMonth varchar(6) = dbo.ufn_GetYearMonth(@ReportDate);
	DECLARE @YearQuarter varchar(6)  = dbo.ufn_GetYearQuarter(@ReportDate);

	IF NOT EXISTS (SELECT 'x' FROM MembershipGeographicTrend WHERE YearMonth = @YearMonth) BEGIN
		INSERT INTO MembershipGeographicTrend (YearMonth, YearQuarter, ServiceCode, ServiceCodeOrder, CountryID, StateID, [Count], Revenue)
		SELECT DISTINCT @YearMonth, @YearQuarter, ItemCode, Category1, prst_CountryID, prst_StateID, 0, 0
		       FROM MAS_PRC.dbo.CI_Item WITH (NOLOCK) 
			        CROSS JOIN CRM.dbo.PRState WITH (NOLOCK)
		 WHERE Category2 = 'Primary'
		   AND prst_CountryID > 0
		  
	END ELSE BEGIN

		UPDATE MembershipGeographicTrend
		   SET [Count] =0, 
		       Revenue = 0,
			   CreatedDateTime = GETDATE()
         WHERE YearMonth = @YearMonth

	END


	UPDATE MembershipGeographicTrend
	   SET [Count] = [Count] + tmpCount,
	       [Revenue] = [Revenue] + tmpRevenue
      FROM (
			SELECT prse_ServiceCode,
			       prcn_CountryID, 
				   prst_StateID,
				   SUM(QuantityOrdered) as tmpCount,
				   SUM(ExtensionAmt) as tmpRevenue
			  FROM CRM.dbo.PRService
				   INNER JOIN CRM.dbo.Company ON prse_CompanyID = comp_CompanyID
				   INNER JOIN CRM.dbo.vPRLocation ON comp_PRListingCityID = prci_CityID
				   --INNER JOIN MAS_PRC.dbo.CI_Item WITH (NOLOCK) ON prse_ServiceCode = ItemCode
			 WHERE prse_Primary = 'Y'
  		  GROUP BY prse_ServiceCode, 
		           prcn_CountryID,
				   prst_StateID
			) T1
  WHERE YearMonth = @YearMonth
    AND CountryID = prcn_CountryID
	AND StateID = prst_StateID
	AND ServiceCode = prse_ServiceCode

END
Go





IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[usp_PopulateServiceDetail]') AND Type IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[usp_PopulateServiceDetail]
GO

CREATE PROCEDURE [dbo].[usp_PopulateServiceDetail]
        @ReportDate datetime = NULL
AS 
BEGIN

	DECLARE @YearMonth varchar(6) = dbo.ufn_GetYearMonth(@ReportDate);
	DECLARE @YearQuarter varchar(6)  = dbo.ufn_GetYearQuarter(@ReportDate);

	DELETE FROM ServiceDetail
	 WHERE YearMonth = @YearMonth;


	INSERT INTO ServiceDetail 
		(YearMonth, YearQuarter, ServiceCode, ServiceCodeOrder, SalesTerritory,
		 TMFMAward, [Primary], ServiceType, CompanyID, QuantityOrdered,
		 DiscountPct, ExtensionAmt, StandardUnitPrice)
	SELECT @YearMonth,
	       @YearQuarter,
	       prse_ServiceCode, 
		   Category1,
		   LEFT(prci_SalesTerritory, 2) as SalesTerritory, 
		   ISNULL(comp_PRTMFMAward, 'N') as TMFM,
		   prse_Primary,
		   CASE CI_Item.Category2 
				WHEN 'PRIMARY' THEN 'Primary' 
				WHEN 'LICENSE' THEN 'License' 
				ELSE 'Ancillary' END as ServiceType,
		   comp_CompanyID,
		   QuantityOrdered,
		   prse_DiscountPct,
		   ExtensionAmt,
		   StandardUnitPrice
	FROM CRM.dbo.PRService
		INNER JOIN CRM.dbo.Company WITH (NOLOCK) ON prse_CompanyID = comp_CompanyID
		INNER JOIN CRM.dbo.vPRLocation ON comp_PRListingCityID = prci_CityID
		INNER JOIN MAS_PRC.dbo.CI_Item WITH (NOLOCK) ON prse_ServiceCode = ItemCode
	WHERE SalesKitItem = 'N'
	   AND MAS_PRC.dbo.CI_Item.ProductLine IN ('ASP', 'ASE', 'MSE', 'MSP', 'MSL', 'LCP')
	   AND StandardUnitPrice > 0
END
Go




IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[usp_UpdateAddlLicenseTrend]') AND Type IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[usp_UpdateAddlLicenseTrend]
GO

CREATE PROCEDURE [dbo].[usp_UpdateAddlLicenseTrend]
        @ReportDate datetime = NULL
AS 
BEGIN

	DECLARE @YearMonth varchar(6) = dbo.ufn_GetYearMonth(@ReportDate);
	DECLARE @YearQuarter varchar(6)  = dbo.ufn_GetYearQuarter(@ReportDate);

	IF NOT EXISTS (SELECT 'x' FROM AddlLicenseTrend WHERE YearMonth = @YearMonth) BEGIN
		INSERT INTO AddlLicenseTrend (YearMonth, YearQuarter, ServiceCode, ServiceCodeOrder, SalesTerritory, [Count], Revenue)
		SELECT DISTINCT @YearMonth, @YearQuarter, ItemCode, Category1, SalesTerritory, 0, 0
		       FROM MAS_PRC.dbo.CI_Item WITH (NOLOCK) 
			   CROSS JOIN (SELECT DISTINCT LEFT(prci_SalesTerritory, 2) as SalesTerritory 
			                 FROM CRM.dbo.PRCity WITH (NOLOCK) 
							WHERE prci_SalesTerritory IS NOT NULL) T1
		 WHERE Category2 = 'LICENSE'
		  
	END ELSE BEGIN

		UPDATE AddlLicenseTrend
		   SET [Count] =0, 
		       Revenue = 0,
			   CreatedDateTime = GETDATE()
         WHERE YearMonth = @YearMonth

	END


	UPDATE AddlLicenseTrend
	   SET [Count] = [Count] + tmpCount,
	       [Revenue] = [Revenue] + tmpRevenue
      FROM (
			SELECT prse_ServiceCode,
			       LEFT(prci_SalesTerritory, 2) as tmpSalesTerritory, 
				   SUM(QuantityOrdered) as tmpCount,
				   SUM(ExtensionAmt) as tmpRevenue
			  FROM CRM.dbo.PRService WITH (NOLOCK)
				   INNER JOIN CRM.dbo.Company WITH (NOLOCK) ON prse_CompanyID = comp_CompanyID
				   INNER JOIN CRM.dbo.vPRLocation WITH (NOLOCK) ON comp_PRListingCityID = prci_CityID
			 WHERE Category2 = 'LICENSE'
  		  GROUP BY prse_ServiceCode, 
		           LEFT(prci_SalesTerritory, 2)
			) T1
  WHERE YearMonth = @YearMonth
    AND SalesTerritory = tmpSalesTerritory
	AND ServiceCode = prse_ServiceCode

END
Go





IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[usp_UpdateAddlLicenseGeographicTrend]') AND Type IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[usp_UpdateAddlLicenseGeographicTrend]
GO

CREATE PROCEDURE [dbo].[usp_UpdateAddlLicenseGeographicTrend]
        @ReportDate datetime = NULL
AS 
BEGIN

	DECLARE @YearMonth varchar(6) = dbo.ufn_GetYearMonth(@ReportDate);
	DECLARE @YearQuarter varchar(6)  = dbo.ufn_GetYearQuarter(@ReportDate);

	IF NOT EXISTS (SELECT 'x' FROM AddlLicenseGeographicTrend WHERE YearMonth = @YearMonth) BEGIN
		INSERT INTO AddlLicenseGeographicTrend (YearMonth, YearQuarter, ServiceCode, ServiceCodeOrder, CountryID, StateID, [Count], Revenue)
		SELECT DISTINCT @YearMonth, @YearQuarter, ItemCode, Category1, prst_CountryID, prst_StateID, 0, 0
		       FROM MAS_PRC.dbo.CI_Item WITH (NOLOCK) 
			        CROSS JOIN CRM.dbo.PRState WITH (NOLOCK)
		 WHERE Category2 = 'LICENSE'
		   AND prst_CountryID > 0
		  
	END ELSE BEGIN

		UPDATE AddlLicenseGeographicTrend
		   SET [Count] =0, 
		       Revenue = 0,
			   CreatedDateTime = GETDATE()
         WHERE YearMonth = @YearMonth

	END


	UPDATE AddlLicenseGeographicTrend
	   SET [Count] = [Count] + tmpCount,
	       [Revenue] = [Revenue] + tmpRevenue
      FROM (
			SELECT prse_ServiceCode,
			       prcn_CountryID, 
				   prst_StateID,
				   SUM(QuantityOrdered) as tmpCount,
				   SUM(ExtensionAmt) as tmpRevenue
			  FROM CRM.dbo.PRService
				   INNER JOIN CRM.dbo.Company ON prse_CompanyID = comp_CompanyID
				   INNER JOIN CRM.dbo.vPRLocation ON comp_PRListingCityID = prci_CityID
				   --INNER JOIN MAS_PRC.dbo.CI_Item WITH (NOLOCK) ON prse_ServiceCode = ItemCode
			 WHERE Category2 = 'LICENSE'
  		  GROUP BY prse_ServiceCode,	
		           prcn_CountryID,
				   prst_StateID
			) T1
  WHERE YearMonth = @YearMonth
    AND CountryID = prcn_CountryID
	AND StateID = prst_StateID
	AND ServiceCode = prse_ServiceCode

END
Go




IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[usp_UpdateAuxServiceTrend]') AND Type IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[usp_UpdateAuxServiceTrend]
GO

CREATE PROCEDURE [dbo].[usp_UpdateAuxServiceTrend]
        @ReportDate datetime = NULL
AS 
BEGIN

	DECLARE @YearMonth varchar(6) = dbo.ufn_GetYearMonth(@ReportDate);
	DECLARE @YearQuarter varchar(6)  = dbo.ufn_GetYearQuarter(@ReportDate);

	IF NOT EXISTS (SELECT 'x' FROM AuxServiceTrend WHERE YearMonth = @YearMonth) BEGIN
		INSERT INTO AuxServiceTrend (YearMonth, YearQuarter, ServiceCode, ServiceCodeOrder, SalesTerritory, [Count], Revenue)
		SELECT DISTINCT @YearMonth, @YearQuarter, ItemCode, Category1, SalesTerritory, 0, 0
		       FROM MAS_PRC.dbo.CI_Item WITH (NOLOCK) 
			   CROSS JOIN (SELECT DISTINCT LEFT(prci_SalesTerritory, 2) as SalesTerritory 
			                 FROM CRM.dbo.PRCity WITH (NOLOCK) 
							WHERE prci_SalesTerritory IS NOT NULL) T1
		 WHERE Category2 NOT IN ('PRIMARY', 'LICENSE')
	       AND MAS_PRC.dbo.CI_Item.ProductLine IN ('ASP', 'ASE', 'MSE', 'MSP', 'MSL', 'LCP')		
		   AND StandardUnitPrice > 0  
	END ELSE BEGIN

		UPDATE AuxServiceTrend
		   SET [Count] =0, 
		       Revenue = 0,
			   CreatedDateTime = GETDATE()
         WHERE YearMonth = @YearMonth

	END


	UPDATE AuxServiceTrend
	   SET [Count] = [Count] + tmpCount,
	       [Revenue] = [Revenue] + tmpRevenue
      FROM (
			SELECT prse_ServiceCode,
			       LEFT(prci_SalesTerritory, 2) as tmpSalesTerritory, 
				   SUM(QuantityOrdered) as tmpCount,
				   SUM(ExtensionAmt) as tmpRevenue
			  FROM CRM.dbo.PRService WITH (NOLOCK)
				   INNER JOIN CRM.dbo.Company WITH (NOLOCK) ON prse_CompanyID = comp_CompanyID
				   INNER JOIN CRM.dbo.vPRLocation WITH (NOLOCK) ON comp_PRListingCityID = prci_CityID
		 WHERE Category2 NOT IN ('PRIMARY', 'LICENSE')
	       AND SalesKitItem = 'N'
  		  GROUP BY prse_ServiceCode, 
		           LEFT(prci_SalesTerritory, 2)
			) T1
  WHERE YearMonth = @YearMonth
    AND SalesTerritory = tmpSalesTerritory
	AND ServiceCode = prse_ServiceCode

END
Go






IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[usp_UpdateAuxServiceGeographicTrend]') AND Type IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[usp_UpdateAuxServiceGeographicTrend]
GO

CREATE PROCEDURE [dbo].[usp_UpdateAuxServiceGeographicTrend]
        @ReportDate datetime = NULL
AS 
BEGIN

	DECLARE @YearMonth varchar(6) = dbo.ufn_GetYearMonth(@ReportDate);
	DECLARE @YearQuarter varchar(6)  = dbo.ufn_GetYearQuarter(@ReportDate);

	IF NOT EXISTS (SELECT 'x' FROM AuxServiceGeographicTrend WHERE YearMonth = @YearMonth) BEGIN
		INSERT INTO AuxServiceGeographicTrend (YearMonth, YearQuarter, ServiceCode, ServiceCodeOrder, CountryID, StateID, [Count], Revenue)
		SELECT DISTINCT @YearMonth, @YearQuarter, ItemCode, Category1, prst_CountryID, prst_StateID, 0, 0
		       FROM MAS_PRC.dbo.CI_Item WITH (NOLOCK) 
			        CROSS JOIN CRM.dbo.PRState WITH (NOLOCK)
		 WHERE Category2 NOT IN ('PRIMARY', 'LICENSE')
	       AND MAS_PRC.dbo.CI_Item.ProductLine IN ('ASP', 'ASE', 'MSE', 'MSP', 'MSL', 'LCP')		
		   AND StandardUnitPrice > 0  
		   AND prst_CountryID > 0
		  
	END ELSE BEGIN

		UPDATE AuxServiceGeographicTrend
		   SET [Count] =0, 
		       Revenue = 0,
			   CreatedDateTime = GETDATE()
         WHERE YearMonth = @YearMonth

	END


	UPDATE AuxServiceGeographicTrend
	   SET [Count] = [Count] + tmpCount,
	       [Revenue] = [Revenue] + tmpRevenue
      FROM (
			SELECT prse_ServiceCode,
			       prcn_CountryID, 
				   prst_StateID,
				   SUM(QuantityOrdered) as tmpCount,
				   SUM(ExtensionAmt) as tmpRevenue
			  FROM CRM.dbo.PRService
				   INNER JOIN CRM.dbo.Company ON prse_CompanyID = comp_CompanyID
				   INNER JOIN CRM.dbo.vPRLocation ON comp_PRListingCityID = prci_CityID
		    WHERE Category2 NOT IN ('PRIMARY', 'LICENSE')
	          AND SalesKitItem = 'N'
  		  GROUP BY prse_ServiceCode,	
		           prcn_CountryID,
				   prst_StateID
			) T1
  WHERE YearMonth = @YearMonth
    AND CountryID = prcn_CountryID
	AND StateID = prst_StateID
	AND ServiceCode = prse_ServiceCode

END
Go





IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[usp_UpdateReportData]') AND Type IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[usp_UpdateReportData]
GO

CREATE PROCEDURE [dbo].[usp_UpdateReportData]
        @ReportDate datetime = NULL
AS 
BEGIN

	IF @ReportDate IS NULL BEGIN
		SET @ReportDate = GETDATE()
	END

	EXEC usp_PopulateServiceDetail @ReportDate
	EXEC usp_UpdateMembershipGeographicTrend @ReportDate
	EXEC usp_UpdateMembershipTrend @ReportDate
	EXEC usp_UpdateMembershipNewTrend @ReportDate
	EXEC usp_UpdateAddlLicenseTrend @ReportDate
	EXEC usp_UpdateAddlLicenseGeographicTrend @ReportDate
	EXEC usp_UpdateAuxServiceTrend @ReportDate
	EXEC usp_UpdateAuxServiceGeographicTrend @ReportDate

END