-- Delete one instance of Cypress, convert to the other
UPDATE PRCompanySpecie SET prcspc_SpecieID = 18 WHERE prcspc_SpecieID = 240
DELETE FROM PRSpecie WHERE prspc_SpecieID = 240
Go

UPDATE NewProduct SET prod_Name ='5 Additional Online Business Reports', prod_PRServiceUnits=5, Prod_UpdatedDate=GETDATE(), Prod_UpdatedBy=3 WHERE prod_ProductID=12
UPDATE NewProduct SET prod_Name ='10 Additional Online Business Reports', prod_PRServiceUnits=10, Prod_UpdatedDate=GETDATE(), Prod_UpdatedBy=3 WHERE prod_ProductID=13
UPDATE NewProduct SET prod_Name ='15 Additional Online Business Reports', prod_PRServiceUnits=15, Prod_UpdatedDate=GETDATE(), Prod_UpdatedBy=3 WHERE prod_ProductID=14
UPDATE NewProduct SET prod_Name ='20 Additional Online Business Reports', prod_PRServiceUnits=20, Prod_UpdatedDate=GETDATE(), Prod_UpdatedBy=3 WHERE prod_ProductID=15
UPDATE NewProduct SET prod_Name ='40 Additional Online Business Reports', prod_PRServiceUnits=40, Prod_UpdatedDate=GETDATE(), Prod_UpdatedBy=3 WHERE prod_ProductID=16

UPDATE NewProduct
   SET prod_PRServiceUnits = prod_PRServiceUnits / 30,
       Prod_UpdatedDate=GETDATE(), 
	   Prod_UpdatedBy=3
 WHERE Prod_ProductFamilyID = 5

UPDATE Pricing SET pric_Price = 150, pric_UpdatedDate=GETDATE(), pric_UpdatedBy=3 WHERE pric_ProductID = 12
UPDATE Pricing SET pric_Price = 300, pric_UpdatedDate=GETDATE(), pric_UpdatedBy=3 WHERE pric_ProductID = 13
UPDATE Pricing SET pric_Price = 450, pric_UpdatedDate=GETDATE(), pric_UpdatedBy=3 WHERE pric_ProductID = 14
UPDATE Pricing SET pric_Price = 600, pric_UpdatedDate=GETDATE(), pric_UpdatedBy=3 WHERE pric_ProductID = 15
UPDATE Pricing SET pric_Price = 1200, pric_UpdatedDate=GETDATE(), pric_UpdatedBy=3 WHERE pric_ProductID = 16

UPDATE Pricing SET pric_Price = 1, pric_UpdatedDate=GETDATE(), pric_UpdatedBy=3 WHERE pric_ProductID IN (46, 47)



UPDATE PRServiceUnitAllocation
   SET prun_UnitsAllocated = CEILING(CAST(prun_UnitsAllocated as Decimal) / 30.00),
       prun_UnitsRemaining = CEILING(CAST(prun_UnitsRemaining as Decimal) / 30.00)
WHERE prun_ExpirationDate >= '2011-01-01'   


UPDATE PRServiceUnitUsage
   SET prsuu_Units = prsuu_Units / 30.00
WHERE prsuu_CreatedDate >= '2011-01-01'   
Go


--SELECT prun_UnitsAllocated, CAST(prun_UnitsAllocated as Decimal) / 30.00 as Raw,  CEILING(CAST(prun_UnitsAllocated as Decimal) / 30.00) as NewAllocation,
--       prun_UnitsRemaining,  CAST(prun_UnitsRemaining as Decimal) / 30.00 as Raw,  CEILING(CAST(prun_UnitsRemaining as Decimal) / 30.00) as NewRemaining
--  FROM PRServiceUnitAllocation 
-- WHERE prun_ExpirationDate >= '2011-01-01'


DELETE
	FROM PRWebUserSearchCriteria 
	WHERE prsc_Name IN ('Asian Produce Handlers', 'Organic Produce Sellers', 'Organic Produce Buyers', 'Frozen Produce Handlers', 'E-mail Directory', 'Chinese Produce Handlers', 'Chilean Produce Handlers')
	AND prsc_ExecutionCount = 0 
	AND prsc_LastExecutionDateTime IS NULL;
Go


DELETE FROM PRBBOSPrivilege WHERE Privilege = 'CompanyDetailsARReportsPage' AND IndustryType = 'L'
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege, Role, Visible, Enabled) VALUES ('L', 400, 'CompanyDetailsARReportsPage', 'ARReportAccess', 1, 0);
Go


SET NOCOUNT ON
DECLARE @MyTable table (
	ndx int identity(1,1),
	CompanyID int,
	UnloadHours varchar(1000))

INSERT INTO @MyTable (CompanyID, UnloadHours)
SELECT comp_CompanyID, comp_PRUnloadHours
 FROM Company
 WHERE comp_PRUnloadHours IS NOT NULL
ORDER BY comp_CompanyID


DECLARE @Count int, @Index int, @CompanyID int
DECLARE @UnloadHours varchar(max)

SELECT @Count = COUNT(1) FROM @MyTable
SET @Index = 0

WHILE @Index < @Count BEGIN

	SET @Index = @Index + 1
	SELECT @CompanyID = CompanyID,
	       @UnloadHours = UnloadHours
	  FROM @MyTable
	 WHERE ndx = @Index;

	 --PRINT @UnloadHours

	 IF (CHARINDEX(CHAR(13), @UnloadHours) > 0) OR (CHARINDEX(CHAR(10), @UnloadHours) > 0) BEGIN
		--PRINT 'Found Line Break'
		 SET @UnloadHours = REPLACE(@UnloadHours, CHAR(13)+CHAR(10), '|')
		 SET @UnloadHours = REPLACE(@UnloadHours, CHAR(10)+CHAR(13), '|')
		 SET @UnloadHours = REPLACE(@UnloadHours, CHAR(13), '|')
		 SET @UnloadHours = REPLACE(@UnloadHours, CHAR(10), '|')

	 END ELSE BEGIN
		SET @UnloadHours = dbo.ufn_ApplyListingLineBreaks2(@UnloadHours, '|', 34);
	 END

	 --PRINT @UnloadHours
		
	 INSERT INTO PRUnloadHours (pruh_CompanyID, pruh_LineContent, pruh_CreatedBy, pruh_CreatedDate, pruh_TimeStamp)
		SELECT @CompanyID, value, -1, GETDATE(), GETDATE()
		FROM dbo.Tokenize(@UnloadHours, '|')
		WHERE value <> ''

END

--SELECT * FROM PRUnloadHours WHERE LEN(pruh_LineContent) > 35 ORDER BY pruh_UnloadHoursID
--SELECT * FROM PRUnloadHours ORDER BY pruh_UnloadHoursID
Go


ALTER TABLE Company DISABLE TRIGGER ALL
UPDATE Company SET comp_PRARReportAccess = 'Y' 
 WHERE comp_CompanyID IN (SELECT DISTINCT comp_CompanyID
						   FROM Company
								INNER JOIN PRARAging ON comp_CompanyID = praa_CompanyID
						  WHERE comp_PRIndustryType = 'L')
ALTER TABLE Company ENABLE TRIGGER ALL
Go




DECLARE @MyTable table (
	CompanyID int
)

INSERT INTO @MyTable
SELECT DISTINCT prcca_CompanyID
  FROM PRCompanyCommodityAttribute
 WHERE prcca_CommodityID IN (6, 9, 3, 11)
ORDER BY prcca_CompanyID

ALTER TABLE PRCompanyCommodityAttribute DISABLE TRIGGER ALL
DELETE FROM PRCompanyCommodityAttribute WHERE prcca_CommodityID IN (6, 9)
ALTER TABLE PRCompanyCommodityAttribute ENABLE TRIGGER ALL
DELETE FROM PRCommodity WHERE prcm_CommodityID IN (6, 9)


-- Convert To flower
SELECT comp_CompanyID
  FROM Company
 WHERE comp_CompanyID IN (SELECT prcca_CompanyID FROM PRCompanyCommodityAttribute WHERE prcca_CommodityID IN (3))
   AND comp_CompanyID NOT IN (SELECT prcca_CompanyID FROM PRCompanyCommodityAttribute WHERE prcca_CommodityID IN (14))
  
ALTER TABLE PRCompanyCommodityAttribute DISABLE TRIGGER ALL
UPDATE PRCompanyCommodityAttribute 
   SET prcca_CommodityID = 14
 WHERE prcca_CommodityID IN (3)
   AND prcca_CompanyID IN (SELECT prcca_CompanyID FROM PRCompanyCommodityAttribute WHERE prcca_CommodityID IN (3))
   AND prcca_CompanyID NOT IN (SELECT prcca_CompanyID FROM PRCompanyCommodityAttribute WHERE prcca_CommodityID IN (14))
ALTER TABLE PRCompanyCommodityAttribute ENABLE TRIGGER ALL


-- Flower exists, just delete
SELECT comp_CompanyID
  FROM Company
 WHERE comp_CompanyID IN (SELECT prcca_CompanyID FROM PRCompanyCommodityAttribute WHERE prcca_CommodityID IN (3))
   AND comp_CompanyID IN (SELECT prcca_CompanyID FROM PRCompanyCommodityAttribute WHERE prcca_CommodityID IN (14))

ALTER TABLE PRCompanyCommodityAttribute DISABLE TRIGGER ALL
DELETE FROM PRCompanyCommodityAttribute 
 WHERE prcca_CommodityID IN (3)
   AND prcca_CompanyID IN (SELECT prcca_CompanyID FROM PRCompanyCommodityAttribute WHERE prcca_CommodityID IN (3))
   AND prcca_CompanyID IN (SELECT prcca_CompanyID FROM PRCompanyCommodityAttribute WHERE prcca_CommodityID IN (14))
ALTER TABLE PRCompanyCommodityAttribute ENABLE TRIGGER ALL



-- Convert To flower
SELECT comp_CompanyID
  FROM Company
 WHERE comp_CompanyID IN (SELECT prcca_CompanyID FROM PRCompanyCommodityAttribute WHERE prcca_CommodityID IN (11))
   AND comp_CompanyID NOT IN (SELECT prcca_CompanyID FROM PRCompanyCommodityAttribute WHERE prcca_CommodityID IN (14))
  
ALTER TABLE PRCompanyCommodityAttribute DISABLE TRIGGER ALL
UPDATE PRCompanyCommodityAttribute 
   SET prcca_CommodityID = 14,
       prcca_PublishedDisplay = 'Flower'
 WHERE prcca_CommodityID IN (11)
   AND prcca_CompanyID IN (SELECT prcca_CompanyID FROM PRCompanyCommodityAttribute WHERE prcca_CommodityID IN (11))
   AND prcca_CompanyID NOT IN (SELECT prcca_CompanyID FROM PRCompanyCommodityAttribute WHERE prcca_CommodityID IN (14))
ALTER TABLE PRCompanyCommodityAttribute ENABLE TRIGGER ALL

ALTER TABLE PRCompanyCommodityAttribute DISABLE TRIGGER ALL
UPDATE PRCompanyCommodityAttribute 
   SET prcca_PublishedDisplay = 'Flower'
 WHERE prcca_CommodityID = 14 AND prcca_PublishedDisplay <> 'Flower'
ALTER TABLE PRCompanyCommodityAttribute ENABLE TRIGGER ALL


-- Flower exists, just delete
SELECT comp_CompanyID
  FROM Company
 WHERE comp_CompanyID IN (SELECT prcca_CompanyID FROM PRCompanyCommodityAttribute WHERE prcca_CommodityID IN (11))
   AND comp_CompanyID IN (SELECT prcca_CompanyID FROM PRCompanyCommodityAttribute WHERE prcca_CommodityID IN (14))

ALTER TABLE PRCompanyCommodityAttribute DISABLE TRIGGER ALL
DELETE FROM PRCompanyCommodityAttribute 
 WHERE prcca_CommodityID IN (11)
   AND prcca_CompanyID IN (SELECT prcca_CompanyID FROM PRCompanyCommodityAttribute WHERE prcca_CommodityID IN (11))
   AND prcca_CompanyID IN (SELECT prcca_CompanyID FROM PRCompanyCommodityAttribute WHERE prcca_CommodityID IN (14))
ALTER TABLE PRCompanyCommodityAttribute ENABLE TRIGGER ALL


DELETE FROM PRCommodity WHERE prcm_CommodityID IN (3, 11)


UPDATE PRListing
   SET prlst_Listing = dbo.ufn_GetListingFromCompany(prlst_CompanyID, 0, 0),
		prlst_UpdatedDate = GETDATE(),
		prlst_Timestamp = GETDATE()
 WHERE prlst_CompanyID IN (SELECT CompanyID FROM @MyTable);


UPDATE PRCommodity
   SET prcm_ParentId = 16,
       prcm_RootParentID = 16,
	   prcm_PathNames = 'Food (non-produce),,Guaje',
	   prcm_PathCodes = 'Otherfood,,Guaje',
	   prcm_DisplayOrder = 274,
	   prcm_UpdatedDate = GETDATE(),
	   prcm_UpdatedBy = 3
 WHERE prcm_CommodityId = 568

UPDATE PRCommodity
   SET prcm_ParentId = 16,
       prcm_RootParentID = 16,
	   prcm_PathNames = 'Food (non-produce),,Sorghum',
	   prcm_PathCodes = 'Otherfood,,Sorghum',
	   prcm_DisplayOrder = 354,
	   prcm_UpdatedDate = GETDATE(),
	   prcm_UpdatedBy = 3
 WHERE prcm_CommodityId = 12

 UPDATE PRCommodity
   SET prcm_ParentId = 16,
       prcm_RootParentID = 16,
	   prcm_PathNames = 'Food (non-produce),,Sugar Cane',
	   prcm_PathCodes = 'Otherfood,,Sugarcane',
	   prcm_DisplayOrder = 356,
	   prcm_UpdatedDate = GETDATE(),
	   prcm_UpdatedBy = 3
 WHERE prcm_CommodityId = 13

UPDATE PRCommodity
   SET prcm_ParentId = 109,
       prcm_RootParentID = 37,
	   prcm_PathNames = 'Fruit,Tree Fruit,Nopales',
	   prcm_PathCodes = 'F,Treef,Nopales',
	   prcm_Alias = NULL,
	   prcm_DisplayOrder = 1274,
	   prcm_UpdatedDate = GETDATE(),
	   prcm_UpdatedBy = 3
 WHERE prcm_CommodityId = 10

Go


/*
UPDATE [MAS_PRC].[dbo].[IM_SalesKitDetail]
   SET [QuantityPerAssembly] = [QuantityPerAssembly] / 30
WHERE ComponentItemCode IN ('UNITS-PRODUCE', 'UNITS-LUMBER')

ALTER TABLE [MAS_PRC].[dbo].[SO_SalesOrderDetail] DISABLE TRIGGER ALL
UPDATE [MAS_PRC].[dbo].[SO_SalesOrderDetail]
   SET [QuantityOrdered] = [QuantityOrdered] / 30
  FROM MAS_PRC.dbo.SO_SalesOrderHeader
 WHERE OrderType = 'R'
   AND SO_SalesOrderHeader.SalesOrderNo = SO_SalesOrderDetail.SalesOrderNo
  AND ItemCode IN ('UNITS-PRODUCE', 'UNITS-LUMBER')

UPDATE [MAS_PRC].[dbo].[SO_SalesOrderDetail]
   SET [QuantityOrdered] = 500
  FROM MAS_PRC.dbo.SO_SalesOrderHeader
 WHERE OrderType = 'R'
   AND SO_SalesOrderHeader.SalesOrderNo = SO_SalesOrderDetail.SalesOrderNo
   AND ItemCode IN ('UNITS-PRODUCE', 'UNITS-LUMBER')
   AND CustomerNo = '0100002'
   AND SO_SalesOrderDetail.SalesOrderNo = '0034213'
ALTER TABLE [MAS_PRC].[dbo].[SO_SalesOrderDetail] ENABLE TRIGGER ALL
*/

ALTER TABLE [MAS_PRC].[dbo].[SO_SalesOrderDetail] DISABLE TRIGGER ALL
UPDATE MAS_PRC.dbo.[SO_SalesOrderDetail] 
   SET ItemCodeDesc = 'Bus. Reports - Produce Members' 
  FROM MAS_PRC.dbo.SO_SalesOrderHeader
 WHERE OrderType = 'R' 
   AND SO_SalesOrderHeader.SalesOrderNo = SO_SalesOrderDetail.SalesOrderNo
   AND ItemCode = 'UNITS-PRODUCE'


UPDATE MAS_PRC.dbo.[SO_SalesOrderDetail] 
   SET ItemCodeDesc = 'Bus. Reports - Lumber Members' 
  FROM MAS_PRC.dbo.SO_SalesOrderHeader
 WHERE OrderType = 'R' 
   AND SO_SalesOrderHeader.SalesOrderNo = SO_SalesOrderDetail.SalesOrderNo
   AND ItemCode = 'UNITS-LUMBER'
ALTER TABLE [MAS_PRC].[dbo].[SO_SalesOrderDetail] ENABLE TRIGGER ALL


ALTER TABLE [MAS_PRC].[dbo].[SO_SalesOrderDetail] DISABLE TRIGGER ALL
UPDATE MAS_PRC.dbo.[SO_SalesOrderDetail] 
   SET [QuantityOrdered] = 20
 WHERE ItemCode = 'UNITS-PRODUCE'
   AND [QuantityOrdered] <> 20
   AND SalesOrderNo IN (
			SELECT SO_SalesOrderHeader.SalesOrderNo
			 FROM MAS_PRC.dbo.[SO_SalesOrderDetail]
				  INNER JOIN MAS_PRC.dbo.SO_SalesOrderHeader ON SO_SalesOrderHeader.SalesOrderNo = SO_SalesOrderDetail.SalesOrderNo
			WHERE OrderType = 'R' 
			  AND ItemCode = 'BBS200')


UPDATE MAS_PRC.dbo.[SO_SalesOrderDetail] 
   SET [QuantityOrdered] = 150
 WHERE ItemCode = 'UNITS-PRODUCE'
   AND [QuantityOrdered] <> 150
   AND SalesOrderNo IN (
			SELECT SO_SalesOrderHeader.SalesOrderNo
			 FROM MAS_PRC.dbo.[SO_SalesOrderDetail]
				  INNER JOIN MAS_PRC.dbo.SO_SalesOrderHeader ON SO_SalesOrderHeader.SalesOrderNo = SO_SalesOrderDetail.SalesOrderNo
			WHERE OrderType = 'R' 
			  AND ItemCode = 'BBS350')
ALTER TABLE [MAS_PRC].[dbo].[SO_SalesOrderDetail] ENABLE TRIGGER ALL


UPDATE MAS_PRC.dbo.CI_Item SET StandardUnitPrice = 30, ItemCodeDesc = 'Bus. Reports - Produce Members' WHERE ItemCode = 'UNITS-PRODUCE'
UPDATE MAS_PRC.dbo.CI_Item SET StandardUnitPrice = 30, ItemCodeDesc = 'Bus. Reports - Lumber Members' WHERE ItemCode = 'UNITS-LUMBER'
Go